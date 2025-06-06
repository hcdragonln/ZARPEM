import * as circomlib from 'circomlibjs';
import { randomBytes } from 'crypto';
import { ecsign, privateToAddress, toBuffer, privateToPublic } from 'ethereumjs-util';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

// Derive __dirname equivalent for ES Modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

/**
 * Helper function to convert a 256-bit value (either Buffer or hex string)
 * into an array of 4x 64-bit BigInt limbs, ordered as little-endian.
 * This is suitable for privateKey, r, s, msghash, pubkeyX, pubkeyY.
 * @param {Buffer | string} input - The 32-byte Buffer or 0x-prefixed/unprefixed 64-char hex string.
 * @returns {BigInt[]} An array of 4 BigInts representing the limbs in little-endian order.
 */
function split256BitValueToLimbs(input) {
    let hexStr;
    if (Buffer.isBuffer(input)) {
        hexStr = input.toString('hex');
    } else if (typeof input === 'string') {
        hexStr = input.startsWith('0x') ? input.slice(2) : input;
    } else {
        throw new Error("Input must be a Buffer or a hex string for limb conversion.");
    }

    // Pad to ensure it's exactly 64 hex characters (256 bits)
    const paddedHex = hexStr.padStart(64, '0');

    const limbs = [];
    const limbHexLength = 16; // 64 bits = 16 hex characters

    // Process from right to left (LSB to MSB) for little-endian limbs
    // This means limb 0 (LSB) comes from the rightmost 16 hex chars, limb 1 from the next 16, etc.
    for (let i = 0; i < 4; i++) {
        const start = paddedHex.length - (i + 1) * limbHexLength;
        const end = paddedHex.length - i * limbHexLength;
        const limbHex = paddedHex.slice(start, end);
        limbs.push(BigInt('0x' + limbHex));
    }
    
    return limbs; // Resulting array is [LSB_limb, ..., MSB_limb]
}

// NOTE: bytesToBigInt is not directly used for poseidon.F.toObject conversions.
// Keeping it in case other parts of your code still rely on it for general byte arrays.
/**
 * Helper function to convert an array of bytes (Uint8Array or number[]) to a BigInt.
 * This assumes the array represents a big-endian number.
 * @param {Uint8Array | number[]} bytes - The array of bytes.
 * @returns {BigInt} The BigInt representation of the bytes.
 */
function bytesToBigInt(bytes) {
    let hex = '0x';
    for (const byte of bytes) {
        hex += byte.toString(16).padStart(2, '0');
    }
    return BigInt(hex);
}

// --- Your existing createMerkleTree function, adapted for direct use ---
export const createMerkleTree = async (assetId, buyerAddress) => {
    console.time("createMerkleTree");
    const poseidon = await circomlib.buildPoseidon(); // Khởi tạo poseidon một lần

    async function createValue() {
        // Đây là giá trị lá Merkle: Poseidon(assetID, buyerAddress)
        const hashArray = poseidon([BigInt(assetId), BigInt(buyerAddress)]);
        const leafValue = poseidon.F.toString(hashArray); // Trả về chuỗi thập phân
        console.log(`[JS DEBUG] Merkle Leaf Value (Poseidon(${assetId.toString()}, ${buyerAddress})): ${leafValue}`);
        return leafValue;
    }

    // function getRandomValue() { // Removed, as we're not generating random nodes
    //     return BigInt('0x' + randomBytes(16).toString('hex')).toString();
    // }

    async function getMerkleProof(smt, key, treeHeight) { // Added treeHeight as parameter
        const F = smt.F;
        // Đảm bảo key là BigInt trước khi đưa vào smt.find
        const keyScalar = F.e(BigInt(key)); 

        const resFind = await smt.find(keyScalar);

        if (!resFind.found) {
            throw new Error("Key not found in the Merkle tree");
        }

        const path = resFind.siblings.map((sibling) => poseidon.F.toString(sibling));
        // Pad to ensure the path always has 'treeHeight' elements
        while (path.length < treeHeight) { // Use treeHeight parameter
            path.push("0"); // Pad with zeros for missing siblings in a sparse tree
        }

        return {
            key: key, // key có thể giữ dạng ban đầu (chuỗi BigInt)
            value: poseidon.F.toString(resFind.foundValue),
            path: path,
        };
    }

    const smt = await circomlib.newMemEmptyTrie();
    
    // Chèn key và value gốc. Key và Value cho SMT.insert() đều phải là BigInt.
    // Đây là lá duy nhất trong cây Merkle của bạn
    await smt.insert(BigInt(assetId), BigInt(await createValue()));

    // --- REMOVED: Loop for inserting random values ---
    // for (let i = assetId + 1; i <= assetId + 99; i++) {
    //     const randomValue = getRandomValue();
    //     await smt.insert(BigInt(i), BigInt(randomValue));
    // }

    console.time("Create Proof");
    // getMerkleProof cần key là BigInt (hoặc chuỗi BigInt có thể chuyển đổi được)
    const treeHeight_value = 20; // Re-declare or pass this value as argument to createMerkleTree if it's dynamic
    const proofKey = await getMerkleProof(smt, assetId.toString(), treeHeight_value);
    console.timeEnd("Create Proof");

    console.timeEnd("createMerkleTree");
    return {
        root: poseidon.F.toString(smt.root), // Root của SMT dưới dạng chuỗi thập phân
        proof: proofKey,
        computedValue: await createValue() // Giá trị lá đã được tính toán
    };
};
// --- End of your existing createMerkleTree function ---

// --- Main function to generate Circom input ---
async function generateCircomInput() {
    const k_value = 4; // Tương ứng với k trong mạch circom
    const treeHeight_value = 20; // Tương ứng với treeHeight trong mạch circom

    let privateKeyBuffer;
    let privateKeyHex;

    // Kiểm tra đối số dòng lệnh để lấy private key
    // node generateInput.js [private_key_hex_string_optional]
    if (process.argv.length > 2) {
        const inputPrivateKey = process.argv[2];
        if (inputPrivateKey.startsWith('0x') && inputPrivateKey.length === 66) { // 0x + 64 hex chars
            privateKeyHex = inputPrivateKey;
            privateKeyBuffer = toBuffer(privateKeyHex);
            console.log(`Using provided Private Key: ${privateKeyHex}`);
        } else if (inputPrivateKey.length === 64) { // 64 hex chars without 0x
            privateKeyHex = '0x' + inputPrivateKey;
            privateKeyBuffer = toBuffer(privateKeyHex);
            console.log(`Using provided Private Key (added 0x): ${privateKeyHex}`);
        } else {
            console.warn("Invalid private key format provided. Generating a random one instead.");
            privateKeyBuffer = randomBytes(32);
            privateKeyHex = '0x' + privateKeyBuffer.toString('hex');
            console.log(`Generated Random Private Key: ${privateKeyHex}`);
        }
    } else {
        privateKeyBuffer = randomBytes(32);
        privateKeyHex = '0x' + privateKeyBuffer.toString('hex');
        console.log(`Generated Random Private Key: ${privateKeyHex}`);
    }

    console.log(`[TEST/DEBUG] Raw Private Key (decimal): ${BigInt(privateKeyHex).toString()}`);

    // SỬ DỤNG HÀM MỚI split256BitValueToLimbs
    const privateKeyCircom = split256BitValueToLimbs(privateKeyBuffer);

    // Dẫn xuất public key (uncompressed)
    const publicKeyBuffer = privateToPublic(privateKeyBuffer); // 64 bytes: 32 bytes X, 32 bytes Y

    // Tách X và Y và chuyển đổi sang định dạng mảng BigInt cho Circom bằng hàm mới
    const pubkeyXBuffer = publicKeyBuffer.slice(0, 32);
    const pubkeyYBuffer = publicKeyBuffer.slice(32, 64);

    const pubkeyXCircom = split256BitValueToLimbs(pubkeyXBuffer);
    const pubkeyYCircom = split256BitValueToLimbs(pubkeyYBuffer);

    // In ra các giá trị public key để debug
    console.log(`[JS DEBUG] Public Key X (hex): 0x${pubkeyXBuffer.toString('hex')}`);
    console.log(`[JS DEBUG] Public Key Y (hex): 0x${pubkeyYBuffer.toString('hex')}`);
    console.log(`[JS DEBUG] Public Key X (decimal): ${BigInt('0x' + pubkeyXBuffer.toString('hex')).toString()}`);
    console.log(`[JS DEBUG] Public Key Y (decimal): ${BigInt('0x' + pubkeyYBuffer.toString('hex')).toString()}`);
    console.log(`[JS DEBUG] Public Key X (Circom limbs): ${pubkeyXCircom.map(val => val.toString())}`);
    console.log(`[JS DEBUG] Public Key Y (Circom limbs): ${pubkeyYCircom.map(val => val.toString())}`);


    const buyerAddressBuffer = privateToAddress(privateKeyBuffer);
    const buyerAddress = '0x' + buyerAddressBuffer.toString('hex');
    
    console.log(`[JS DEBUG] Derived Buyer Address (hex): ${buyerAddress}`);
    console.log(`[JS DEBUG] Derived Buyer Address (decimal): ${BigInt(buyerAddress).toString()}`);


    // 2. Định nghĩa assetID
    const assetID = 12345; // asset ID ví dụ
    const counter = 1; // Example counter value, can be incremented for subsequent transactions

    // 3. Tạo hash thông điệp để ký
    const poseidonForMsgHash = await circomlib.buildPoseidon();

    // msghashRaw là kết quả hash Poseidon (dưới dạng BigInt)
    // Đảm bảo cả hai đầu vào đều là BigInt
    const msghashRaw = poseidonForMsgHash([BigInt(assetID), BigInt(buyerAddress)]);

    // Chuyển đổi msghashRaw BigInt sang chuỗi hex có tiền tố 0x để ký
    let msghashHexForSigning = poseidonForMsgHash.F.toObject(msghashRaw).toString(16);
    msghashHexForSigning = msghashHexForSigning.padStart(64, '0');
    msghashHexForSigning = '0x' + msghashHexForSigning;

    // Chuyển đổi chuỗi hex có tiền tố 0x sang Buffer để ký
    const msghashBufferForSigning = toBuffer(msghashHexForSigning);

    // SỬ DỤNG HÀM MỚI split256BitValueToLimbs
    const msghashCircom = split256BitValueToLimbs(msghashBufferForSigning);

    // 4. Ký hash thông điệp
    const { v, r, s } = ecsign(msghashBufferForSigning, privateKeyBuffer);
    
    // SỬ DỤNG HÀM MỚI split256BitValueToLimbs
    const rCircom = split256BitValueToLimbs(r);
    const sCircom = split256BitValueToLimbs(s);

    console.log(`Generated Message Hash (signed): ${msghashHexForSigning}`);
    console.log(`Signature r: ${r.toString('hex')}`);
    console.log(`Signature s: ${s.toString('hex')}`);
    console.log(`Signature v: ${v}`);

    // 5. Tạo cây Merkle và lấy bằng chứng
    // Truyền treeHeight_value vào hàm createMerkleTree
    const { root, proof, computedValue } = await createMerkleTree(assetID, buyerAddress, treeHeight_value);

    // --- Nullifier Calculation (MUST match Circom logic) ---
    const poseidonForNullifier = await circomlib.buildPoseidon();
    
    // Private Key Hashing: Pass the BigInt limbs directly to poseidon
    // The output will be an F.t element. Convert it to BigInt using F.toObject.
    const privateKeyHashedFieldElement = poseidonForNullifier(privateKeyCircom.map(val => BigInt(val)));
    const privateKeyHashedInJs = poseidonForNullifier.F.toObject(privateKeyHashedFieldElement);

    console.log(`[JS DEBUG] Hashed Private Key (for nullifier, decimal): ${privateKeyHashedInJs.toString()}`);

    // Final Nullifier Hash: Hash assetID, hashed private key, and counter
    // The output will be an F.t element. Convert it to BigInt using F.toObject.
    const computedNullifierFieldElement = poseidonForNullifier([
        BigInt(assetID),
        privateKeyHashedInJs, // Use the pre-hashed private key
        BigInt(counter)
    ]);
    const computedNullifierBigInt = poseidonForNullifier.F.toObject(computedNullifierFieldElement);
    
    const nullifier = computedNullifierBigInt.toString();

    console.log(`\n--- DEBUG VALUES FROM JAVASCRIPT ---`);
    console.log(`[JS DEBUG] Merkle Root (calculated): ${root}`);
    console.log(`[JS DEBUG] Merkle Proof Key: ${proof.key}`);
    console.log(`[JS DEBUG] Merkle Proof Value (leaf hash): ${proof.value}`);
    console.log(`[JS DEBUG] Merkle Proof Siblings length: ${proof.path.length}`);
    console.log(`[JS DEBUG] Computed Nullifier: ${nullifier}`);
    console.log(`[JS DEBUG] Computed Leaf Value (from createValue): ${computedValue}`);


    // Xây dựng đối tượng đầu vào cho circom
    const circomInput = {
        privatekey: privateKeyCircom.map(val => val.toString()),
        r: rCircom.map(val => val.toString()),
        s: sCircom.map(val => val.toString()),
        msghash: msghashCircom.map(val => val.toString()),
        assetID: assetID.toString(),
        nullifier: nullifier,
        counter: counter.toString(),
        privateKeyHashed: privateKeyHashedInJs.toString(),
        siblings: proof.path,
        root: root,
    };

    // Ghi đầu vào vào file JSON
    const outputDir = path.join(__dirname, 'input');
    if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir);
    }
    const outputFile = path.join(outputDir, 'input_1_data.json');
    fs.writeFileSync(outputFile, JSON.stringify(circomInput, null, 2));

    console.log(`\nCircom input generated and saved to: ${outputFile}`);
    console.log("Bạn có thể biên dịch và chạy mạch circom của mình với đầu vào này.");
    console.log("Ví dụ: `snarkjs groth16 prove AssetOwnerMerkle.r1cs witness.wtns public.json proof.json`");
    console.log(`\n--- SAU KHI CHẠY SNARKJS, HÃY SO SÁNH VỚI public.json ---`);
    console.log(`    - "address" trong public.json (từ Circom)`);
    console.log(`    - "[JS DEBUG] Merkle Leaf Value" (từ JS) và "debug_circom_leaf_hash" trong public.json`);
    console.log(`    - "[JS DEBUG] Merkle Root" (từ JS) và "root" trong public.json`);
    console.log(`    - "nullifier" trong input.json (từ JS) và "nullifier" trong public.json`);
    console.log(`    - "assetID" trong input.json (từ JS) và "assetID" trong public.json`);
    console.log(`    - "counter" trong input.json (từ JS) và "counter" trong public.json`);
}

// Run the main function
generateCircomInput().catch(console.error);