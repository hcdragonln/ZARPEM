const { Contract } = require('fabric-contract-api');

class ZoneContract extends Contract {

  // Lấy tất cả các vùng
  async getAllZones(ctx) {
    const iterator = await ctx.stub.getStateByRange('', '');
    const allZones = [];

    // Duyệt qua từng zone và lưu vào array
    while (true) {
      const res = await iterator.next();
      if (res.done) {
        break;
      }

      const zone = JSON.parse(res.value.value.toString());
      allZones.push(zone);
    }

    return JSON.stringify(allZones);
  }

  // Tạo mới một vùng
async createZone(ctx, zoneId, coordinates, type) {
  // Validate input: Ensure coordinates is an array with at least 3 points
  if (typeof coordinates === 'string') {
    coordinates = JSON.parse(coordinates); // Parse if coordinates is a string
  }
  if (!Array.isArray(coordinates) || coordinates.length < 3) {
    throw new Error(`Cần ít nhất 3 điểm để tạo một vùng. Dữ liệu hiện tại: ${JSON.stringify(coordinates)}`);
  }

  // Check the MSP of the creator
  const creator = ctx.clientIdentity.getMSPID();
  if (creator !== 'landauthorityMSP') {
    throw new Error("Tổ chức không có quyền tạo vùng.");
  }

  // Create the zone object
  const newZone = {
    zoneId,       // Add zoneId to the object
    coordinates,  // Coordinates of the zone
    type,         // Type of the zone
    creator,      // Store the creator's MSP
    timestamp: new Date().toISOString(), // Add a timestamp for reference
  };

  // Save the zone data to the ledger
  await ctx.stub.putState(zoneId, Buffer.from(JSON.stringify(newZone)));

  return JSON.stringify(newZone); // Return the created zone as a response
}



  // Xóa vùng theo ID
  async deleteZone(ctx, zoneId) {
    const exists = await this.zoneExists(ctx, zoneId);
    if (!exists) {
      throw new Error(`Vùng với ID ${zoneId} không tồn tại.`);
    }
    const creator = ctx.clientIdentity.getMSPID();
    if (creator !== 'landauthorityMSP') {
      throw new Error("Tổ chức không có quyền xoa vùng.");
    }
    // Xóa zone khỏi ledger
    await ctx.stub.deleteState(zoneId);

    return JSON.stringify({ message: "Vùng đã được xóa" });
  }

  // Kiểm tra vùng tồn tại hay không
  async zoneExists(ctx, zoneId) {
    const data = await ctx.stub.getState(zoneId);
    return data && data.length > 0;
  }
}

module.exports = ZoneContract;
