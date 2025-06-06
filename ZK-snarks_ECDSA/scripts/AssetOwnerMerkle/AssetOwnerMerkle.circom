pragma circom 2.1.2;

include "../../circuits/ecdsa.circom";
include "../../circuits/pubToAddress.circom";
include "../../node_modules/circomlib/circuits/poseidon.circom";
include "../../node_modules/circomlib/circuits/smt/smtverifier.circom";

template AssetOwnerMerkle(n, k, treeHeight) {
    // Inputs
    signal input privatekey[k];
    signal input r[k];
    signal input s[k];
    signal input msghash[k];
    signal input assetID;
    signal input nullifier;
    signal input counter; // New input for the nullifier calculation

    // NEW INPUT: Hashed private key from off-chain
    signal input privateKeyHashed; // This will be the poseidon hash of privatekey[k]

    // Merkle proof
    signal input siblings[treeHeight];
    signal input root;

    // Outputs
    signal output address;
    signal output computedNullifier;

    // 1. Derive public key
    component privToPub = ECDSAPrivToPub(n, k);
    for (var i = 0; i < k; i++) {
        privToPub.privkey[i] <== privatekey[i];
    }

    // 2. Flatten public key to bits for address derivation
    component flatten = FlattenPubkey(n, k);
    for (var i = 0; i < k; i++) {
        flatten.chunkedPubkey[0][i] <== privToPub.pubkey[0][i];
        flatten.chunkedPubkey[1][i] <== privToPub.pubkey[1][i];
    }

    // 3. Get Ethereum-style address
    component addr = PubkeyToAddress();
    for (var i = 0; i < 512; i++) {
        addr.pubkeyBits[i] <== flatten.pubkeyBits[i];
    }
    address <== addr.address;

    // 4. Verify ECDSA Signature
    component sig = ECDSAVerifyNoPubkeyCheck(n, k);
    for (var i = 0; i < k; i++) {
        sig.r[i] <== r[i];
        sig.s[i] <== s[i];
        sig.msghash[i] <== msghash[i];
        sig.pubkey[0][i] <== privToPub.pubkey[0][i];
        sig.pubkey[1][i] <== privToPub.pubkey[1][i];
    }

    // 5. Compute Merkle value (leaf) = Poseidon(assetID, address)
    component valHash = Poseidon(2);
    valHash.inputs[0] <== assetID;
    valHash.inputs[1] <== address;

    // Merkle key = assetID
    signal merkleKey;
    merkleKey <== assetID;

    // 6. Verify Merkle proof inclusion
    component smt = SMTVerifier(treeHeight);
    smt.enabled <== 1;
    smt.root <== root;
    smt.key <== merkleKey;
    smt.value <== valHash.out;
    for (var i = 0; i < treeHeight; i++) {
        smt.siblings[i] <== siblings[i];
    }
    smt.fnc <== 0;      // inclusion proof
    smt.oldKey <== 0;
    smt.oldValue <== 0;
    smt.isOld0 <== 0;    // important to mark oldKey/oldValue unused

    // 7. Compute Nullifier = Poseidon(assetID, privateKeyHashed, counter)
    // Directly use the provided privateKeyHashed input
    component nullifierHash = Poseidon(3);
    nullifierHash.inputs[0] <== assetID;
    nullifierHash.inputs[1] <== privateKeyHashed; // Use the provided hashed private key
    nullifierHash.inputs[2] <== counter;
    computedNullifier <== nullifierHash.out;

    // 8. Check input nullifier consistency
    nullifier === computedNullifier;
}

// Public signals (add privateKeyHashed if you want it public, but usually kept private)
component main { public [msghash, nullifier, assetID, root, counter, siblings, r, s] } = AssetOwnerMerkle(64, 4, 20);