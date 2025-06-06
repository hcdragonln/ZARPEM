// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./Groth16Verifier.sol";

contract RealEstateTransaction is ReentrancyGuard, Groth16Verifier {

    enum TransactionStatus { Pending, Completed, Cancelled }

    struct Transaction {
        uint256 transactionId;
        address payer;
        address payee;
        uint256 amount;
        bytes32 realEstateId;
        uint256 timestamp;
        TransactionStatus status;
        string userId;
        string assetId;
        uint256 nullifier; // nullifier đi kèm proof
    }

    uint256 public transactionCount;
    mapping(uint256 => Transaction) public transactions;
    mapping(bytes32 => uint256[]) public realEstateTransactions;

    mapping(uint256 => bool) public nullifiers;  // nullifier đã được dùng (chỉ khi completeTransaction đánh dấu)

    event TransactionCreated(
        uint256 transactionId,
        address payer,
        address payee,
        uint256 amount,
        bytes32 realEstateId,
        string userId,
        string assetId,
        uint256 nullifier
    );
    event TransactionCancelled(uint256 transactionId, string userId, string assetId);
    event TransactionCompleted(uint256 transactionId, string userId, string assetId);

    struct Proof {
        uint256[2] a;
        uint256[2][2] b;
        uint256[2] c;
    }

    // Tạo giao dịch, verify proof + nullifier vẫn chưa bị dùng
    function createTransaction(
        address _payee,
        uint256 _amount,
        bytes32 _realEstateId,
        string memory _userId,
        string memory _assetId,
        Proof calldata proof,
        uint256[38] calldata publicSignals
    ) public payable {
        require(msg.value == _amount, "Amount sent mismatch");
        uint256 nullifier = publicSignals[1];
        require(!nullifiers[nullifier], "Nullifier already used");
	bool valid;
	try this.verifyProof(proof.a, proof.b, proof.c, publicSignals) returns (bool result) {
    		valid = result;
	} catch {
    		revert("Proof verification failed unexpectedly");
	}
	require(valid, "Invalid zk-SNARK proof");  
        transactionCount++;

        transactions[transactionCount] = Transaction({
            transactionId: transactionCount,
            payer: msg.sender,
            payee: _payee,
            amount: _amount,
            realEstateId: _realEstateId,
            timestamp: block.timestamp,
            status: TransactionStatus.Pending,
            userId: _userId,
            assetId: _assetId,
            nullifier: nullifier
        });

        realEstateTransactions[_realEstateId].push(transactionCount);

        emit TransactionCreated(transactionCount, msg.sender, _payee, _amount, _realEstateId, _userId, _assetId, nullifier);
    }

    // Hoàn thành giao dịch, đánh dấu nullifier đã dùng
    function completeTransaction(uint256 _transactionId) public nonReentrant {
        Transaction storage txn = transactions[_transactionId];
        require(txn.status == TransactionStatus.Pending, "Transaction not pending");
        require(msg.sender == txn.payee, "Only payee can complete");
        require(!nullifiers[txn.nullifier], "Nullifier already used");

        // Đánh dấu nullifier đã dùng
        nullifiers[txn.nullifier] = true;

        txn.status = TransactionStatus.Completed;
        payable(txn.payee).transfer(txn.amount);

        emit TransactionCompleted(_transactionId, txn.userId, txn.assetId);

        // Huỷ các giao dịch khác cùng assetId
        for (uint256 i = 1; i <= transactionCount; i++) {
            Transaction storage otherTxn = transactions[i];
            if (
                keccak256(abi.encodePacked(otherTxn.assetId)) == keccak256(abi.encodePacked(txn.assetId)) &&
                otherTxn.transactionId != _transactionId &&
                otherTxn.status == TransactionStatus.Pending
            ) {
                otherTxn.status = TransactionStatus.Cancelled;
                payable(otherTxn.payer).transfer(otherTxn.amount);
                emit TransactionCancelled(otherTxn.transactionId, otherTxn.userId, otherTxn.assetId);
            }
        }
    }

    function cancelTransaction(uint256 _transactionId) public nonReentrant {
        Transaction storage txn = transactions[_transactionId];
        require(txn.status == TransactionStatus.Pending, "Not pending");
        require(msg.sender == txn.payer, "Only payer cancel");

        txn.status = TransactionStatus.Cancelled;
        payable(txn.payer).transfer(txn.amount);
        emit TransactionCancelled(_transactionId, txn.userId, txn.assetId);

        // Lưu ý: nullifier không bị giải phóng ở đây vì nullifier chỉ đánh dấu khi completeTransaction
    }
}
