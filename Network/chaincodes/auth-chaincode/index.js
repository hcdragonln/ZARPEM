const { Contract } = require('fabric-contract-api');
const bcrypt = require('bcryptjs');

class UserContract extends Contract {
  constructor() {
    super("UserContract");
  }

  async initLedger(ctx) {
    const defaultAdminEmail = "admin@gm.realestate.com";
    const defaultAdminPassword = "admin@123";

    // Tạo admin mặc định nếu chưa tồn tại
    const adminExists = await ctx.stub.getState(defaultAdminEmail);
    if (adminExists && adminExists.length > 0) {
      console.log("Default admin already exists. Skipping initialization.");
    } else {
      const hashedPassword = await bcrypt.hash(defaultAdminPassword, 10);
      const adminUser = {
        name: "Default Admin",
        mail: defaultAdminEmail,
        password: hashedPassword,
        role: "admin",
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };
      await ctx.stub.putState(defaultAdminEmail, Buffer.from(JSON.stringify(adminUser)));
      console.log("Default admin created successfully.");
    }

    const roleCountersExists = await ctx.stub.getState("roleCounters");
    if (roleCountersExists && roleCountersExists.length > 0) {
      console.log("Role counters already initialized. Skipping initialization.");
    } else {
      const defaultRoleCounters = {
        bank: 0,
        landauthority: 0,
        court: 0,
        inspector: 0,
      };
      await ctx.stub.putState("roleCounters", Buffer.from(JSON.stringify(defaultRoleCounters)));
      console.log("Role counters initialized.");
    }
}

  // Lấy roleCounters từ ledger
  async getRoleCounters(ctx) {
    const countersAsBytes = await ctx.stub.getState("roleCounters");
    if (!countersAsBytes || countersAsBytes.length === 0) {
      const defaultRoleCounters = {
        bank: 0,
        landauthority: 0,
        court: 0,
        inspector: 0,
      };
      await ctx.stub.putState("roleCounters", Buffer.from(JSON.stringify(defaultRoleCounters)));
      // Trả về giá trị mặc định nếu chưa tồn tại
      return {
        bank: 0,
        landauthority: 0,
        court: 0,
        inspector: 0,
      };
    }
    return JSON.parse(countersAsBytes.toString());
  }

  // Cập nhật roleCounters trong ledger
  async updateRoleCounters(ctx, roleCounters) {
    await ctx.stub.putState("roleCounters", Buffer.from(JSON.stringify(roleCounters)));
  }

  async registerUser(ctx, name, mail, password) {
    mail = mail.toLowerCase().trim();

    // Check if email exists
    const userExists = await this.userExists(ctx, mail);
    if (userExists) {
      throw new Error('Email already exists');
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = {
      name,
      mail,
      password: hashedPassword,
      role: 'user',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    await ctx.stub.putState(mail, Buffer.from(JSON.stringify(user)));
    return { message: 'User registered successfully', user };
  }

  async loginUser(ctx, mail, password) {
    mail = mail.toLowerCase().trim();
    const user = await this.getUserByMail(ctx, mail);

    if (!user) {
      throw new Error('User not found');
    }

    const isPasswordMatch = await bcrypt.compare(password, user.password);
    if (!isPasswordMatch) {
      throw new Error('Invalid email or password');
    }

    delete user.password;
    return { message: 'Login successful', user };
  }
async getAllUsers(ctx) {
  const allResults = [];

  const iterator = await ctx.stub.getStateByRange("", "");
  let result = await iterator.next();
  
  while (!result.done) {
    const strValue = Buffer.from(result.value.value.toString()).toString("utf8");
    let record;
    try {
      record = JSON.parse(strValue);
    } catch (err) {
      console.log(err);
      record = strValue; // Handle case where the record isn't a JSON object
    }
    
    // Filter out records that are not user objects
    if (record && record.mail) {
      allResults.push(record);
    }
    
    result = await iterator.next();
  }

  await iterator.close(); // Close the iterator
  return allResults;
}


  // Optimized method: Direct lookup by email
  async getUserByMail(ctx, mail) {
    const userString = await ctx.stub.getState(mail);
    if (!userString || userString.length === 0) {
      return null; // User not found
    }

    return JSON.parse(userString.toString());
  }

  async getUserProfile(ctx, mail) {
    const user = await this.getUserByMail(ctx, mail);
    if (!user) {
      throw new Error('User not found');
    }

    delete user.password;
    return user;
  }

  async deleteUser(ctx, mail) {
    const userString = await ctx.stub.getState(mail);
    if (!userString || userString.length === 0) {
      throw new Error('User not found');
    }

    await ctx.stub.deleteState(mail);
    return { message: 'User deleted successfully' };
  }

  // Utility method to check if user exists by email
  async userExists(ctx, mail) {
    const userString = await ctx.stub.getState(mail);
    return userString && userString.length > 0;
  }

  // Admin user registration in bulk
async registerAdminUsers(ctx, role, userList) {
    const results = [];
    let roleCounters = await this.getRoleCounters(ctx); // Lấy trạng thái hiện tại

    if (typeof userList === 'string') {
        userList = JSON.parse(userList); // Chuyển chuỗi thành mảng nếu cần
    }

    for (const username of userList) {
      roleCounters[role]++;  // Tăng bộ đếm role

      const email = `${role.toLowerCase()}${roleCounters[role]}@gm.realestate.com`;
      const password = this.generateRandomPassword();
      const hashedPassword = await bcrypt.hash(password, 10);

      const user = {
        name: username,
        mail: email,
        password: hashedPassword,
        role,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };

      // Kiểm tra email đã tồn tại chưa
      const emailExists = await this.userExists(ctx, email);
      if (emailExists) {
        results.push({ username, email, message: 'Email already exists', status: 'failed' });
        continue;  // Bỏ qua người dùng này nếu email đã tồn tại
      }

      // Lưu người dùng vào ledger
      await ctx.stub.putState(email, Buffer.from(JSON.stringify(user)));
      results.push({ username, email, password, message: 'User created successfully', status: 'success' });
    }

    // Cập nhật roleCounters trong ledger
    await this.updateRoleCounters(ctx, roleCounters);
    return results;
}


  // Helper method to generate random password
  generateRandomPassword() {
    const randomDigits = Math.floor(Math.random() * 10000).toString().padStart(4, '0');
    const randomChars = Math.random().toString(36).substring(2, 5);
    return `${randomDigits}${randomChars}`;
  }
}

exports.contracts = [UserContract];
