'use strict';

const { Contract } = require('fabric-contract-api');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');

class UserManagement extends Contract {
    // Đăng ký người dùng
    async registerUser(ctx, name, mail, password) {
        mail = mail.toLowerCase().trim(); // Convert email to lowercase and trim spaces

        // Kiểm tra xem email đã tồn tại chưa
        const userExists = await this.userExists(ctx, mail);
        if (userExists) {
            throw new Error('Email already exists');
        }

        // Mã hóa mật khẩu
        const hashedPassword = await bcrypt.hash(password, 10);

        // Tạo ID duy nhất
        const id = crypto.randomUUID();

        // Tạo thông tin người dùng
        const user = {
            _id: id, // ID duy nhất
            name,
            mail,
            password: hashedPassword,
            role: 'user', // Vai trò mặc định là 'user'
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        };

        // Lưu user vào blockchain với ID là key
        await ctx.stub.putState(id, Buffer.from(JSON.stringify(user)));

        return { message: 'User registered successfully', user };
    }

    // Đăng nhập người dùng
    async loginUser(ctx, mail, password) {
        mail = mail.toLowerCase().trim();
        const user = await this.getUserByMail(ctx, mail);

        // Kiểm tra mật khẩu
        const isPasswordMatch = await bcrypt.compare(password, user.password);
        if (!isPasswordMatch) {
            throw new Error('Invalid email or password');
        }

        // Trả về thông tin người dùng (không bao gồm mật khẩu)
        delete user.password;
        return { message: 'Login successful', user };
    }

    // Lấy thông tin người dùng
    async getUserProfile(ctx, id) {
        const userString = await ctx.stub.getState(id);
        if (!userString || userString.length === 0) {
            throw new Error('User not found');
        }

        const user = JSON.parse(userString.toString());
        delete user.password; // Không trả về mật khẩu
        return user;
    }

    // Lấy danh sách tất cả người dùng
    async getAllUsers(ctx) {
        const iterator = await ctx.stub.getStateByRange('', '');
        const users = [];

        for await (const res of iterator) {
            const user = JSON.parse(res.value.toString());
            delete user.password; // Loại bỏ mật khẩu
            users.push(user);
        }

        if (users.length === 0) {
            throw new Error('No users found');
        }

        return users;
    }

    // Xóa người dùng
    async deleteUser(ctx, id) {
        const userString = await ctx.stub.getState(id);
        if (!userString || userString.length === 0) {
            throw new Error('User not found');
        }

        await ctx.stub.deleteState(id);
        return { message: 'User deleted successfully' };
    }

    // Đăng ký hàng loạt bởi admin
    async registerAdminUsers(ctx, role, userList) {
        const results = [];

        for (const username of userList) {
            const id = crypto.randomUUID();
            const email = `${username.toLowerCase()}@example.com`.toLowerCase();
            const password = this.generateRandomPassword();
            const hashedPassword = await bcrypt.hash(password, 10);

            const user = {
                _id: id,
                name: username,
                mail: email,
                password: hashedPassword,
                role,
                createdAt: new Date().toISOString(),
                updatedAt: new Date().toISOString()
            };

            const emailExists = await this.userExists(ctx, email);
            if (emailExists) {
                results.push({ username, email, message: 'Email already exists', status: 'failed' });
                continue;
            }

            await ctx.stub.putState(id, Buffer.from(JSON.stringify(user)));
            results.push({ username, email, password, message: 'User created successfully', status: 'success' });
        }

        return results;
    }

    // Kiểm tra xem người dùng có tồn tại không
    async userExists(ctx, mail) {
        const iterator = await ctx.stub.getStateByRange('', '');
        for await (const res of iterator) {
            const user = JSON.parse(res.value.toString());
            if (user.mail === mail) {
                return true;
            }
        }
        return false;
    }

    // Lấy người dùng theo email
    async getUserByMail(ctx, mail) {
        const iterator = await ctx.stub.getStateByRange('', '');
        for await (const res of iterator) {
            const user = JSON.parse(res.value.toString());
            if (user.mail === mail) {
                return user;
            }
        }
        throw new Error('User not found');
    }

    // Hàm tạo mật khẩu ngẫu nhiên
    generateRandomPassword() {
        const randomDigits = Math.floor(Math.random() * 10000).toString().padStart(4, '0');
        const randomChars = Math.random().toString(36).substring(2, 5);
        return `${randomDigits}${randomChars}`;
    }
}

module.exports = UserManagement;
