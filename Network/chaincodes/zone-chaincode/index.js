const { Contract } = require('fabric-contract-api');
const zoneContract = require('./zoneContract');
module.exports.zoneContract = zoneContract 
module.exports.contracts = [zoneContract];
