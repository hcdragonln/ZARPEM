const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
    console.log("🚀 Starting Hardhat script for RealEstateTransaction...");

    // --- Configuration: Define Buyer and Seller Addresses ---
    // These are typically the default accounts provided by Hardhat's local network.
    const buyerAddress = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"; // Hardhat default account 0
    const sellerAddress = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"; // Hardhat default account 1

    const buyer = await hre.ethers.getSigner(buyerAddress);
    const seller = await hre.ethers.getSigner(sellerAddress);

    console.log(`\n👤 Buyer account: ${buyer.address}`);
    console.log(`👤 Seller account: ${seller.address}`);

    // --- Load Contract Address: Ensure the contract is deployed ---
    const contractInfoPath = path.join(__dirname, "../contracts-info/realestate_address.json");
    if (!fs.existsSync(contractInfoPath)) {
        console.error("❌ Contract chưa deploy. Vui lòng deploy contract trước khi chạy script này.");
        console.error("   (Contract not deployed. Please deploy the contract before running this script.)");
        process.exit(1);
    }
    const contractInfo = JSON.parse(fs.readFileSync(contractInfoPath, "utf8"));
    const contractAddress = contractInfo.address;

    console.log(`\n✅ Contract RealEstateTransaction deployed at: ${contractAddress}`);

    // --- Get Contract Instances: Connect to the deployed contract with specific signers ---
    const contractBuyer = await hre.ethers.getContractAt("RealEstateTransaction", contractAddress, buyer);
    const contractSeller = await hre.ethers.getContractAt("RealEstateTransaction", contractAddress, seller);
    console.log("🔗 Contract instances loaded for buyer and seller accounts.");

    // --- Load Proof Data: Required for Zero-Knowledge Proof (ZKP) verification ---
    const proofDataPath = path.join(__dirname, "../proof/calldata.js");
    if (!fs.existsSync(proofDataPath)) {
        console.error(`❌ File proof calldata không tìm thấy tại: ${proofDataPath}`);
        console.error("   (Proof calldata file not found at the specified path.)");
        process.exit(1);
    }
    const proofData = require(proofDataPath);

    if (!proofData.a || !proofData.b || !proofData.c || !proofData.Input) {
        console.error("❌ Dữ liệu proof calldata không hợp lệ. Thiếu 'a', 'b', 'c' hoặc 'Input'.");
        console.error("   (Invalid proof calldata structure. Missing 'a', 'b', 'c', or 'Input'.)");
        process.exit(1);
    }

    const proof = {
        a: proofData.a,
        b: proofData.b,
        c: proofData.c,
    };
    console.log("📖 Dữ liệu proof đã được tải thành công.");

    // --- Define Transaction Parameters ---
    // These parameters are passed to the `createTransaction` function and are often
    // derived from or related to the public inputs of your ZKP circuit.
    const payee = sellerAddress;
    const amount = hre.ethers.utils.parseEther("1.0"); // Example: 1 Ether
    const realEstateId = hre.ethers.utils.formatBytes32String("estate123"); // Unique ID for the real estate asset
    const userId = "buyer1"; // Identifier for the user (may be part of ZKP)
    const assetId = "asset001"; // Identifier for the asset (used for cancelling other offers)
    const nullifier = proofData.Input[1]; // Assuming nullifier is at index 1 in your publicSignals array (proofData.Input)

    console.log("\n--- Thông tin chi tiết giao dịch (dùng cho createTransaction) ---");
    console.log(`Payee (Người nhận): ${payee}`);
    console.log(`Amount (Số tiền): ${hre.ethers.utils.formatEther(amount)} ETH`);
    console.log(`Real Estate ID (Mã BĐS): ${hre.ethers.utils.parseBytes32String(realEstateId)} (Bytes32: ${realEstateId})`);
    console.log(`User ID (Mã người dùng): ${userId}`);
    console.log(`Asset ID (Mã tài sản): ${assetId}`);
    console.log(`Nullifier (từ proofData.Input[1]): ${nullifier.toString()}`);

    // --- Step 1: Buyer Creates a New Transaction ---
    console.log("\n--- Bước 1: Buyer gọi createTransaction ---");
    let initialTransactionCount = await contractBuyer.transactionCount();
    console.log(`Số lượng giao dịch ban đầu trên contract: ${initialTransactionCount.toString()}`);

    try {
        console.log("Đang gửi giao dịch createTransaction từ buyer...");
        const txCreate = await contractBuyer.createTransaction(
            payee,
            amount,
            realEstateId,
            userId,
            assetId,
            proof,
            proofData.Input,
            { value: amount, gasLimit: 1500000 } // Tăng gasLimit cho các giao dịch ZKP thường tốn gas
        );
        console.log(`Transaction đã được gửi. Hash: ${txCreate.hash}`);
        console.log("Đang chờ xác nhận giao dịch...");
        const receiptCreate = await txCreate.wait(); // Wait for the transaction to be mined and confirmed
        
        // Check transaction status from receipt
        if (receiptCreate.status === 1) {
            console.log(`✅ Giao dịch tạo thành công! (Transaction created successfully!)`);
        } else {
            // This case might be rare if tx.wait() doesn't throw, but useful as a double-check
            console.error(`❌ Giao dịch tạo thất bại trên chuỗi (status: ${receiptCreate.status}).`);
            console.error("   (Transaction creation failed on-chain.)");
            process.exit(1);
        }
        
        console.log(`Gas đã dùng cho createTransaction: ${receiptCreate.gasUsed.toString()}`);

        // Verify if the 'TransactionCreated' event was emitted
        const createEvent = receiptCreate.events?.find(e => e.event === "TransactionCreated");
        if (createEvent) {
            console.log("🎉 Event 'TransactionCreated' đã được phát ra!");
            console.log(`   Transaction ID (từ event): ${createEvent.args.transactionId.toString()}`);
            console.log(`   Payer (từ event): ${createEvent.args.payer}`);
            console.log(`   Payee (từ event): ${createEvent.args.payee}`);
            console.log(`   Amount (từ event): ${hre.ethers.utils.formatEther(createEvent.args.amount)} ETH`);
            console.log(`   Nullifier (từ event): ${createEvent.args.nullifier.toString()}`);
        } else {
            console.warn("⚠️ Cảnh báo: Không tìm thấy event 'TransactionCreated' trong receipt. Điều này có thể chỉ ra một lỗi ẩn.");
            console.warn("   (Warning: 'TransactionCreated' event not found. This might indicate a silent error.)");
        }

    } catch (error) {
        console.error("❌ Lỗi khi gọi createTransaction: (Error calling createTransaction)");
        // This is the most crucial part for debugging. The error.message will contain the revert reason.
        console.error(`   Thông báo lỗi: ${error.message || error}`);
        console.error("   Điều này thường có nghĩa giao dịch đã bị revert trên chuỗi. Vui lòng kiểm tra proof và public signals của bạn.");
        console.error("   (This usually means the transaction reverted on-chain. Please check your proof and public signals.)");
        process.exit(1); // Exit if transaction creation fails
    }

    // --- Verify Transaction State After Creation ---
    const currentTxnCount = await contractBuyer.transactionCount();
    console.log(`\nSố lượng giao dịch hiện tại trên contract sau khi tạo: ${currentTxnCount.toString()}`);

    // If transactionCount is 0, it means the creation failed despite initial logs.
    if (currentTxnCount.eq(0)) { // Use .eq() for BigNumber comparison
        console.error("❌ Lỗi nghiêm trọng: transactionCount vẫn là 0. Giao dịch createTransaction đã bị revert.");
        console.error("   (Critical Error: transactionCount is still 0. createTransaction must have reverted.)");
        process.exit(1);
    }

    // The transaction ID should be the currentTransactionCount as per your contract logic
    const latestTxnId = currentTxnCount;
    const txn = await contractBuyer.transactions(latestTxnId);
    console.log("--- Thông tin chi tiết giao dịch vừa tạo (lấy từ trạng thái contract) ---");
    console.log({
        transactionId: txn.transactionId.toString(),
        payer: txn.payer,
        payee: txn.payee,
        amount: hre.ethers.utils.formatEther(txn.amount),
        realEstateId: hre.ethers.utils.parseBytes32String(txn.realEstateId),
        userId: txn.userId,
        assetId: txn.assetId,
        nullifier: txn.nullifier.toString(),
        status: txn.status.toString() // 0: Pending, 1: Completed, 2: Cancelled
    });

    // Check nullifier status after creation (it should be false)
    const isNullifierUsedBeforeComplete = await contractSeller.nullifiers(nullifier);
    console.log(`Nullifier '${nullifier.toString()}' đã được đánh dấu dùng chưa (trước khi complete): ${isNullifierUsedBeforeComplete}`);
    if (isNullifierUsedBeforeComplete) {
        console.error("❌ Lỗi nghiêm trọng: Nullifier đã được đánh dấu dùng trước khi hoàn thành giao dịch. Điều này không nên xảy ra!");
        console.error("   (Critical Error: Nullifier already marked as used before completion. This should not happen!)");
        process.exit(1);
    }

    // --- Step 2: Seller Completes the Transaction ---
    console.log("\n--- Bước 2: Seller gọi completeTransaction ---");
    console.log(`Seller address (signer): ${seller.address}`);
    console.log(`Đang cố gắng hoàn thành giao dịch ID: ${latestTxnId.toString()}`);

    try {
        const txComplete = await contractSeller.completeTransaction(latestTxnId, { gasLimit: 500000 });
        console.log(`Giao dịch hoàn thành đã được gửi. Hash: ${txComplete.hash}`);
        console.log("Đang chờ xác nhận giao dịch...");
        const receiptComplete = await txComplete.wait();

        if (receiptComplete.status === 1) {
            console.log("✅ Giao dịch hoàn thành thành công! (Transaction completed successfully!)");
        } else {
            console.error(`❌ Giao dịch hoàn thành thất bại trên chuỗi (status: ${receiptComplete.status}).`);
            process.exit(1);
        }

        console.log(`Gas đã dùng cho completeTransaction: ${receiptComplete.gasUsed.toString()}`);

        const completeEvent = receiptComplete.events?.find(e => e.event === "TransactionCompleted");
        if (completeEvent) {
            console.log("🎉 Event 'TransactionCompleted' đã được phát ra!");
            console.log(`   Completed Transaction ID (từ event): ${completeEvent.args.transactionId.toString()}`);
        } else {
            console.warn("⚠️ Cảnh báo: Không tìm thấy event 'TransactionCompleted' trong receipt.");
        }

        // Check for any TransactionCancelled events emitted by the loop in completeTransaction
        const cancelledEvents = receiptComplete.events?.filter(e => e.event === "TransactionCancelled");
        if (cancelledEvents && cancelledEvents.length > 0) {
            console.log(`\n🔔 Đã huỷ ${cancelledEvents.length} giao dịch khác cùng assetId:`);
            cancelledEvents.forEach(event => {
                console.log(`   - Giao dịch ID: ${event.args.transactionId.toString()}, Asset ID: ${event.args.assetId}`);
            });
        }

    } catch (error) {
        console.error("❌ Lỗi khi gọi completeTransaction: (Error calling completeTransaction)");
        console.error(`   Thông báo lỗi: ${error.message || error}`);
        console.error("   Kiểm tra xem giao dịch có đang Pending không và người gọi có phải là Payee không.");
        console.error("   (Check if the transaction is pending, and if the caller is the payee.)");
        process.exit(1); // Exit if completion fails
    }

    // --- Verify Nullifier Status After Completion ---
    const isNullifierUsedAfterComplete = await contractSeller.nullifiers(nullifier);
    console.log(`\nNullifier '${nullifier.toString()}' đã được đánh dấu dùng chưa (sau khi complete): ${isNullifierUsedAfterComplete}`);
    if (!isNullifierUsedAfterComplete) {
        console.error("❌ Lỗi nghiêm trọng: Nullifier không được đánh dấu dùng sau khi hoàn thành giao dịch thành công!");
        console.error("   (Critical Error: Nullifier not marked as used after successful completion!)");
        process.exit(1);
    }
    const completedTxnStatus = await contractBuyer.transactions(latestTxnId);
    console.log(`Trạng thái của giao dịch đã hoàn thành (${latestTxnId}): ${completedTxnStatus.status.toString()} (0: Pending, 1: Completed, 2: Cancelled)`);


    // --- Step 3: Buyer Tries to Create New Transaction with the *Same* Proof (Expected to Fail) ---
    console.log("\n--- Bước 3: Buyer cố gắng tạo giao dịch mới với CÙNG proof cũ ---");
    console.log("Điều này phải thất bại vì nullifier đã được sử dụng.");
    try {
        const txCreate2 = await contractBuyer.createTransaction(
            payee,
            amount,
            realEstateId,
            userId,
            assetId,
            proof,
            proofData.Input,
            { value: amount, gasLimit: 1500000 }
        );
        // If this line is reached, it means the transaction didn't revert immediately.
        // It should revert during tx.wait() due to "Nullifier already used"
        await txCreate2.wait();
        console.error("❌ Lỗi: Giao dịch thứ 2 vẫn tạo thành công. Đây là lỗ hổng tái sử dụng nullifier!");
        console.error("   (Error: Second transaction created successfully. This indicates a nullifier reuse vulnerability!)");
        process.exit(1);
    } catch (error) {
        console.log("✅ Giao dịch thứ 2 đã thất bại đúng logic. (Second transaction failed as expected.)");
        console.log(`   Thông báo lỗi dự kiến: ${error.message || error}`);
        console.log("   Điều này xác nhận cơ chế nullifier đang hoạt động đúng như dự định.");
    }

    // --- Final Check: Transaction Count After Second Attempt ---
    const finalTxnCount = await contractBuyer.transactionCount();
    console.log(`\nSố lượng giao dịch cuối cùng trên contract: ${finalTxnCount.toString()}`);
    if (finalTxnCount.eq(latestTxnId)) {
        console.log("✅ Số lượng giao dịch không tăng sau lần tạo thứ hai thất bại, đúng như dự kiến.");
    } else {
        console.error("❌ Lỗi: Số lượng giao dịch đã tăng sau lần tạo thứ hai lẽ ra phải thất bại.");
        process.exit(1);
    }

    console.log("\n--- Script đã hoàn thành ---");
}

// --- Global Error Handling for the Main Function ---
main().catch(err => {
    console.error("\n❌ Lỗi tổng quát khi chạy script:");
    console.error(err);
    process.exit(1);
});