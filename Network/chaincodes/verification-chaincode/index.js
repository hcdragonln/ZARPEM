const { Contract } = require('fabric-contract-api');
const VerificationContract = require('./VerificationContract');
module.exports.VerificationContract = VerificationContract 
module.exports.contracts = [VerificationContract];
