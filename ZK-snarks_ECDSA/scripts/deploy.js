const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  // Lấy contract factory
  const RealEstateTransaction = await hre.ethers.getContractFactory("RealEstateTransaction");

  // Triển khai contract
  const deployedRealEstate = await RealEstateTransaction.deploy();

  // Đợi deploy xong
  await deployedRealEstate.deployed();

  // Lấy địa chỉ deployed contract
  const deployedAddress = deployedRealEstate.address;
  console.log(`✅ RealEstateTransaction deployed to: ${deployedAddress}`);

  // Thư mục lưu địa chỉ contract
  const contractsDir = path.join(__dirname, "../contracts-info");
  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }

  // Đường dẫn file lưu địa chỉ
  const filePath = path.join(contractsDir, "realestate_address.json");

  // Dữ liệu lưu lại
  const dataToSave = {
    address: deployedAddress,
    network: hre.network.name,
  };

  // Ghi file JSON
  fs.writeFileSync(filePath, JSON.stringify(dataToSave, null, 2));
  console.log(`✅ Địa chỉ RealEstateTransaction đã được lưu vào: ${filePath}`);
}

main().catch((error) => {
  console.error("❌ Deploy failed:", error);
  process.exitCode = 1;
});
