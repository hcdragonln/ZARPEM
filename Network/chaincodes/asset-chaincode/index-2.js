const { Contract } = require('fabric-contract-api');
const crypto = require('crypto');

class assetContract extends Contract {
  constructor() {
    super("assetContract");
  }
    async registerLandAsset(ctx, assetId ,current_owner, price, location, landInfo, documentHashes) {

        const currentDate = new Date().toISOString();
       
        // Create the asset object
        const asset = {
            assetId: assetId,
            current_owner: current_owner,
            price: parseFloat(price),
            location: JSON.parse(location),
            landInfo: {
                ...JSON.parse(landInfo),
                document_hashes: JSON.parse(documentHashes),
            },
            ownershipHistory: [
                {
                    ownerId: current_owner, // Initial owner
                    ownershipStart: currentDate,
                    ownershipEnd: null,
                }
            ],
            wallet_address: "",
            createdAt: currentDate,
            updatedAt: currentDate,
        };

        // Store the asset in blockchain
        await ctx.stub.putState(assetId, Buffer.from(JSON.stringify(asset)));
        
        const eventPayload = {
            eventType: 'AssetRegistered',
            assetId: assetId,
        };
        
        ctx.stub.setEvent('AssetRegistered', Buffer.from(JSON.stringify(eventPayload)));

        return JSON.stringify({
            message: 'Tài sản được đăng ký thành công.',
            asset,
        });
    }

    // Check if asset exists
    async assetExists(ctx, assetId) {
        const assetBytes = await ctx.stub.getState(assetId);
        return assetBytes && assetBytes.length > 0;
    }

    // Verify document hash
    async verifyDocument(ctx, assetId, documentHash) {
        const assetBytes = await ctx.stub.getState(assetId);
        if (!assetBytes || assetBytes.length === 0) {
            throw new Error(`Không tìm thấy tài sản với ID ${assetId}`);
        }

        const asset = JSON.parse(assetBytes.toString());
        const valid = asset.landInfo.document_hashes.includes(documentHash);

        if (!valid) {
            throw new Error('Hash của tài liệu không khớp với blockchain.');
        }

        return JSON.stringify({ message: 'Tài liệu hợp lệ.' });
    }

    // Update asset details
    async updateAsset(ctx, assetId, updateDataJSON) {
        const updateData = JSON.parse(updateDataJSON);
        const assetBytes = await ctx.stub.getState(assetId);

        if (!assetBytes || assetBytes.length === 0) {
            throw new Error(`Tài sản với ID ${assetId} không tồn tại.`);
        }

        const asset = JSON.parse(assetBytes.toString());

        // Update asset information
        Object.assign(asset, updateData);
        asset.updatedAt = new Date().toISOString();

        await ctx.stub.putState(assetId, Buffer.from(JSON.stringify(asset)));
        return JSON.stringify(asset);
    }

    // Get assets not owned by the user
    async getAssets(ctx, userId) {
        const queryString = {
            selector: {
                current_owner_id: { $ne: userId }, // Filter assets not owned by userId
            },
        };

        const iterator = await ctx.stub.getQueryResult(JSON.stringify(queryString));
        const assets = [];

        while (true) {
            const res = await iterator.next();
            if (res.done) {
                await iterator.close();
                break;
            }
            const asset = JSON.parse(res.value.value.toString('utf8'));
            assets.push(asset);
        }

        return JSON.stringify(assets);
    }

    // Get assets owned by the user
    async getAssetsByUserID(ctx, userId) {
        const queryString = {
            selector: {
                current_owner_id: userId, // Filter assets owned by userId
            },
        };

        const iterator = await ctx.stub.getQueryResult(JSON.stringify(queryString));
        const assets = [];

        while (true) {
            const res = await iterator.next();
            if (res.done) {
                await iterator.close();
                break;
            }
            const asset = JSON.parse(res.value.value.toString('utf8'));
            assets.push(asset);
        }

        return JSON.stringify(assets);
    }

    // Get asset by assetId
    async getAssetByAssetId(ctx, assetId) {
        const assetBytes = await ctx.stub.getState(assetId);
        if (!assetBytes || assetBytes.length === 0) {
            throw new Error(`Không tìm thấy tài sản với ID ${assetId}`);
        }

        const asset = JSON.parse(assetBytes.toString());
        return JSON.stringify(asset);
    }

    // Get all assets
    async getAllAssets(ctx) {
        const iterator = await ctx.stub.getStateByRange('', '');
        const allAssets = [];

        while (true) {
            const res = await iterator.next();
            if (res.done) {
                await iterator.close();
                break;
            }
            const asset = JSON.parse(res.value.value.toString('utf8'));
            allAssets.push(asset);
        }

        return JSON.stringify(allAssets);
    }

    // Transfer asset ownership
    async transferOwnership(ctx, assetId, newOwnerId) {
        const assetBytes = await ctx.stub.getState(assetId);
        if (!assetBytes || assetBytes.length === 0) {
            throw new Error(`Không tìm thấy tài sản với ID ${assetId}`);
        }

        const asset = JSON.parse(assetBytes.toString());
        const ownershipHistory = asset.ownershipHistory || [];
        const currentDate = new Date().toISOString();

        // End the previous ownership
        if (ownershipHistory.length > 0) {
            ownershipHistory[ownershipHistory.length - 1].ownershipEnd = currentDate;
        }

        asset.current_owner_id = newOwnerId;
        ownershipHistory.push({
            ownerId: newOwnerId, // New owner
            ownershipStart: currentDate,
            ownershipEnd: null,
        });

        // Update ownership history
        asset.ownershipHistory = ownershipHistory;
        asset.updatedAt = currentDate;

        await ctx.stub.putState(assetId, Buffer.from(JSON.stringify(asset)));

        return JSON.stringify({
            message: `Quyền sở hữu tài sản ${assetId} đã được chuyển cho ${newOwnerId}`,
            asset,
        });
    }

    // Query all verification records from another contract
async queryAllVerificationRecords(ctx) {
    try {
        const result = await ctx.stub.invokeChaincode(
            'VerificationContract',
            ['getAllVerificationRecords'],
            'verifychannel'
        );

        if (!result || result.status !== 200) {
            throw new Error(`Failed to query VerificationContract: ${result.message || 'Unknown error'}`);
        }

        const payload = result.payload ? result.payload.toString() : null;
        if (!payload) {
            throw new Error('Response payload is empty.');
        }

        return JSON.parse(payload);
    } catch (error) {
        throw new Error(`Error querying VerificationContract: ${error.message}`);
    }
}
}


exports.contracts = [assetContract];