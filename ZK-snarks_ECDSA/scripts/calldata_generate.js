const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

async function generateCalldata() {
    try {
        // Step 1: Run snarkjs zkesc and capture its raw output
        // We ensure a clean output by redirecting stderr to null
        const rawOutput = execSync('snarkjs zkesc proof/public.json proof/proof.json', { encoding: 'utf-8', stdio: ['pipe', 'pipe', 'ignore'] }).trim();

        // Step 2: Manually parse the raw output string
        // The output is a comma-separated list of arrays.
        // We need to wrap it in an outer array to parse it as a single entity.
        let parts;
        try {
            // Enclose the raw output in an array to make it a valid JS array of arrays
            // This is safer than direct eval on the raw output if it's not a single expression
            parts = JSON.parse(`[${rawOutput}]`);
        } catch (parseError) {
            // Fallback for more complex or slightly different formats if JSON.parse fails
            // This is less safe but might be needed if the format isn't strictly JSON-compatible
            console.warn("Cảnh báo: JSON.parse thất bại, thử sử dụng eval làm phương án dự phòng. Đảm bảo nguồn đáng tin cậy.");
            parts = eval(`[${rawOutput}]`);
        }

        if (parts.length !== 4) {
            throw new Error(`Đầu ra snarkjs zkesc không có 4 phần như mong đợi. Đã tìm thấy ${parts.length} phần.`);
        }

        // Step 3: Extract the components
        const proof_a = JSON.stringify(parts[0]);
        const proof_b = JSON.stringify(parts[1]);
        const proof_c = JSON.stringify(parts[2]);
        const public_inputs = JSON.stringify(parts[3]);

        // Step 4: Write to calldata.js
        const calldataContent = `
// calldata.js - Tự động tạo
// Dữ liệu được trích xuất từ snarkjs zkesc

const proof_a = ${proof_a};
const proof_b = ${proof_b};
const proof_c = ${proof_c};
const public_inputs = ${public_inputs};

module.exports = {
    a: proof_a,
    b: proof_b,
    c: proof_c,
    Input: public_inputs
};
        `;

        const outputPath = path.join(__dirname, '/proof/calldata.json');
        fs.writeFileSync(outputPath, calldataContent);

        console.log(`File ${outputPath} đã được tạo thành công.`);

    } catch (error) {
        console.error("Lỗi khi tạo calldata.js:", error.message);
        // Optionally, print the raw output for debugging if an error occurs
        // console.error("Raw snarkjs zkesc output:", rawOutput);
        process.exit(1);
    }
}

generateCalldata();