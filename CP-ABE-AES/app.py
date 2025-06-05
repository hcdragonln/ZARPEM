from flask import Flask, request, jsonify
from cpabe_schemes import CPABEScheme
import json
import base64
import logging

# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

app = Flask(__name__)
cpabe_instance = CPABEScheme()

# Initialize CP-ABE system
with app.app_context():
    if not cpabe_instance.load_keys():
        logger.error("Failed to load or initialize CP-ABE keys")
        raise RuntimeError("Failed to initialize CP-ABE system")

@app.route('/')
def home():
    return "CP-ABE API is running with AES-GCM!"

@app.route('/setup', methods=['POST'])
def setup():
    try:
        success = cpabe_instance.setup()
        if success:
            return jsonify({"status": "success", "message": "CP-ABE system initialized successfully"})
        else:
            return jsonify({"status": "error", "message": "Failed to initialize CP-ABE system"}), 500
    except Exception as e:
        logger.error(f"Setup failed: {str(e)}")
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/keygen', methods=['POST'])
def keygen():
    try:
        data = request.get_json()
        if not data or 'attributes' not in data:
            return jsonify({"status": "error", "message": "Missing attributes in request"}), 400
        
        attributes = data['attributes']
        if not isinstance(attributes, list) or not attributes:
            return jsonify({"status": "error", "message": "Attributes must be a non-empty list"}), 400

        key_data = cpabe_instance.keygen(attributes)
        return jsonify({"status": "success", "key_data": key_data})
    except Exception as e:
        logger.error(f"Key generation failed: {str(e)}")
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/encrypt', methods=['POST'])
def encrypt():
    try:
        data = request.get_json()
        if not data or 'policy' not in data or 'plaintext' not in data:
            return jsonify({"status": "error", "message": "Missing policy or plaintext in request"}), 400

        policy = data['policy']
        plaintext_base64 = data['plaintext']

        try:
            plaintext = base64.b64decode(plaintext_base64)
        except Exception as e:
            return jsonify({"status": "error", "message": "Invalid base64 plaintext"}), 400

        encrypted_data = cpabe_instance.encrypt_data(policy, plaintext)
        return jsonify({"status": "success", "encrypted_data": encrypted_data})
    except Exception as e:
        logger.error(f"Encryption failed: {str(e)}")
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/decrypt', methods=['POST'])
def decrypt():
    try:
        data = request.get_json()
        if not data or 'secret_key' not in data or 'encrypted_data' not in data:
            return jsonify({
                "status": "error", 
                "message": "Missing secret key or encrypted data in request"
            }), 400

        secret_key = data['secret_key']
        encrypted_data = data['encrypted_data']

        # Gọi hàm decrypt_data
        decrypted_data = cpabe_instance.decrypt_data(secret_key, encrypted_data)
        
        # Kiểm tra kết quả None
        if decrypted_data is None:
            return jsonify({
                "status": "success",  # Đổi thành success vì đây không phải lỗi
                "decrypted": False,   # Flag cho biết không decrypt được
                "message": "Cannot decrypt - Insufficient attributes"
            }), 200  # HTTP 200 vì đây là kết quả hợp lệ
            
        # Nếu decrypt thành công
        return jsonify({
            "status": "success",
            "decrypted": True,        # Flag cho biết decrypt thành công
            "decrypted_plaintext_base64": base64.b64encode(decrypted_data).decode('utf-8')
        }), 200
        
    except Exception as e:
        logger.error(f"Decryption failed: {str(e)}")
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

@app.route('/api/cpabe/keys/status', methods=['GET'])
def keys_status_api():
    try:
        status = cpabe_instance.check_keys_status()
        return jsonify(status), 200
    except Exception as e:
        logger.error(f"Failed to check keys status: {str(e)}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=6000)


