'use strict';

const { Contract } = require('fabric-contract-api');

class VerificationContract extends Contract {
    // Tạo bản ghi xác minh khi nhận được assetId từ AssetChannel
    async createVerificationRecord(ctx, assetId, current_owner) {
        const clientMSP = ctx.clientIdentity.getMSPID();
        if (clientMSP !== 'courtMSP') {
            throw new Error('Only members of courtMSP are allowed to create verification records.');
        }

        const clientID = ctx.clientIdentity.getID();
        const regex = /CN=([^/]+)/;
        const matches = clientID.match(regex);

        let username = null;
        if (matches && matches[1]) {
            username = matches[1].split('::')[0];
        }

        if (username !== 'admin') {
            throw new Error(`Only the enrolled admin of courtMSP can create verification records. ${username}`);
        }


        const verificationRecord = {
            assetId: assetId,
            current_owner: current_owner,
            document_validity: 'pending',
            dispute_status: 'pending',
            mortgage_status: 'pending',
            asset_status: 'pending',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        };

        await ctx.stub.putState(assetId, Buffer.from(JSON.stringify(verificationRecord)));

        return JSON.stringify({
            message: 'Verification record created successfully.',
            verificationRecord,
        });
    }

    // Cập nhật trạng thái document_validity
    async updateDocumentValidity(ctx, assetId, documentValidity) {
        const clientMSP = ctx.clientIdentity.getMSPID();
        if (clientMSP !== 'landauthorityMSP') {
            throw new Error('Only members of landauthorityMSP are allowed to update verification records.');
        }

        if (!['pending', 'refuse', 'accept'].includes(documentValidity)) {
            throw new Error('Invalid document_validity value');
        }

        const recordAsBytes = await ctx.stub.getState(assetId);
        if (!recordAsBytes || recordAsBytes.length === 0) {
            throw new Error(`Verification record for assetId ${assetId} does not exist.`);
        }

        const record = JSON.parse(recordAsBytes.toString());
        record.document_validity = documentValidity;

        const updatedRecord = await this.checkAndUpdateAssetStatus(ctx, record);
        await ctx.stub.putState(assetId, Buffer.from(JSON.stringify(updatedRecord)));

        return JSON.stringify(updatedRecord);
    }

    // Cập nhật trạng thái dispute_status
    async updateDisputeStatus(ctx, assetId, disputeStatus) {
        const clientMSP = ctx.clientIdentity.getMSPID();
        if (clientMSP !== 'courtMSP') {
            throw new Error('Only members of courtMSP are allowed to update verification records.');
        }

        if (!['pending', 'dispute', 'No dispute'].includes(disputeStatus)) {
            throw new Error('Invalid dispute_status value');
        }

        const recordAsBytes = await ctx.stub.getState(assetId);
        if (!recordAsBytes || recordAsBytes.length === 0) {
            throw new Error(`Verification record for assetId ${assetId} does not exist.`);
        }

        const record = JSON.parse(recordAsBytes.toString());
        record.dispute_status = disputeStatus;

        const updatedRecord = await this.checkAndUpdateAssetStatus(ctx, record);
        await ctx.stub.putState(assetId, Buffer.from(JSON.stringify(updatedRecord)));

        return JSON.stringify(updatedRecord);
    }

    // Cập nhật trạng thái mortgage_status
    async updateMortgageStatus(ctx, assetId, mortgageStatus) {
        const clientMSP = ctx.clientIdentity.getMSPID();
        if (clientMSP !== 'bankMSP') {
            throw new Error('Only members of bankMSP are allowed to update verification records.');
        }

        if (!['pending', 'mortgage', 'No mortgage'].includes(mortgageStatus)) {
            throw new Error('Invalid mortgage_status value');
        }

        const recordAsBytes = await ctx.stub.getState(assetId);
        if (!recordAsBytes || recordAsBytes.length === 0) {
            throw new Error(`Verification record for assetId ${assetId} does not exist.`);
        }

        const record = JSON.parse(recordAsBytes.toString());
        record.mortgage_status = mortgageStatus;

        const updatedRecord = await this.checkAndUpdateAssetStatus(ctx, record);
        await ctx.stub.putState(assetId, Buffer.from(JSON.stringify(updatedRecord)));

        return JSON.stringify(updatedRecord);
    }

    // Lấy tất cả các bản ghi xác minh
    async getAllVerificationRecords(ctx) {
        const allResults = [];
        const iterator = await ctx.stub.getStateByRange('', '');

        let result = await iterator.next();
        while (!result.done) {
            const record = JSON.parse(result.value.value.toString('utf8'));
            allResults.push(record);
            result = await iterator.next();
        }

        await iterator.close();
        return JSON.stringify(allResults);
    }

    // Lấy các bản ghi xác minh dựa trên current_owner
    async getRecordsByCurrentOwner(ctx, current_owner) {
        if (!current_owner) {
            throw new Error('The current_owner parameter is required.');
        }

        const allResults = [];
        const iterator = await ctx.stub.getStateByRange('', '');

        let result = await iterator.next();
        while (!result.done) {
            const record = JSON.parse(result.value.value.toString('utf8'));
            if (record.current_owner === current_owner) {
                allResults.push(record);
            }
            result = await iterator.next();
        }

        await iterator.close();
        return JSON.stringify(allResults);
    }

    // Kiểm tra và cập nhật asset_status
    async checkAndUpdateAssetStatus(ctx, record) {
        if ( record.document_validity === 'refuse')
         {  record.asset_status = 'refuse';
            record.updatedAt = new Date().toISOString();
         }
        else if (
            record.document_validity === 'accept' &&
            record.dispute_status === 'No dispute' &&
            record.mortgage_status === 'No mortgage'
        ) {
            record.asset_status = 'available';
            record.updatedAt = new Date().toISOString();
        }
        return record;
    }

    async updateAssetStatus(ctx, assetId, assetStatus, currentOwner) {

        const clientMSP = ctx.clientIdentity.getMSPID();
        if (clientMSP !== 'courtMSP') {
            throw new Error('Only members of courtMSP are allowed to create verification records.');
        }

        const clientID = ctx.clientIdentity.getID();
        const regex = /CN=([^/]+)/;
        const matches = clientID.match(regex);

        let username = null;
        if (matches && matches[1]) {
            username = matches[1].split('::')[0];
        }

        if (username !== 'admin') {
            throw new Error(`Only the enrolled admin of courtMSP can create verification records. ${username}`);
        }
    
    // Ensure the assetStatus is valid
    if (!['available', 'selling'].includes(assetStatus)) {
        throw new Error('Invalid asset_status value. Allowed values are: "available", "selling".');
    }
    
    // Retrieve the record
    const recordAsBytes = await ctx.stub.getState(assetId);
    if (!recordAsBytes || recordAsBytes.length === 0) {
        throw new Error(`Verification record for assetId ${assetId} does not exist.`);
    }

    const record = JSON.parse(recordAsBytes.toString());

    // Validate current_owner
    if (record.current_owner !== currentOwner) {
        throw new Error(`The current_owner provided does not match the record's owner.`);
    }

    // Check if the asset_status is "pending"
    if (record.asset_status === "pending") {
        throw new Error(`Cannot update status for assets in "pending" state.`);
    }

    // Update asset_status and timestamp
    record.asset_status = assetStatus;
    record.updatedAt = new Date().toISOString();

    // Save the updated record
    await ctx.stub.putState(assetId, Buffer.from(JSON.stringify(record)));

    return JSON.stringify({
        message: 'Asset status updated successfully.',
        updatedRecord: record,
    });
}


}

module.exports = VerificationContract;
