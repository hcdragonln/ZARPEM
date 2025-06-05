const { Contract } = require('fabric-contract-api');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const assetContract = require('./assetContract');
module.exports.assetContract = assetContract;
module.exports.contracts = [assetContract];