import requests
import base64
import json

BASE_URL = "http://localhost:6000"

def test_home():
    r = requests.get(f"{BASE_URL}/")
    print("Home:", r.status_code, r.text)

def test_setup():
    r = requests.post(f"{BASE_URL}/setup")
    print("Setup:", r.status_code, r.json())

def test_keygen():
    payload = {
        "attributes": ["admin", "it"]
    }
    r = requests.post(f"{BASE_URL}/keygen", json=payload)
    print("Keygen:", r.status_code, r.json())
    return r.json().get("key_data")

def test_encrypt(policy, plaintext_bytes):
    plaintext_b64 = base64.b64encode(plaintext_bytes).decode("utf-8")
    payload = {
        "policy": policy,
        "plaintext": plaintext_b64
    }
    r = requests.post(f"{BASE_URL}/encrypt", json=payload)
    print("Encrypt:", r.status_code, r.json())
    return r.json().get("encrypted_data")

def test_decrypt(secret_key, encrypted_data):
    payload = {
        "secret_key": secret_key,
        "encrypted_data": encrypted_data
    }
    r = requests.post(f"{BASE_URL}/decrypt", json=payload)
    print("Decrypt:", r.status_code)
    
    response_data = r.json()
    
    # Kiểm tra status
    if response_data.get("status") == "error":
        print("Error:", response_data.get("message"))
        return None
        
    # Kiểm tra decrypted flag
    if not response_data.get("decrypted", False):
        print("Cannot decrypt:", response_data.get("message"))
        return None
        
    # Nếu decrypt thành công
    decrypted_base64 = response_data.get("decrypted_plaintext_base64")
    if decrypted_base64:
        decoded = base64.b64decode(decrypted_base64)
        print("Decrypted Text:", decoded.decode())
        return decoded
    
    return None

def test_keys_status():
    r = requests.get(f"{BASE_URL}/api/cpabe/keys/status")
    print("Keys status:", r.status_code, r.json())

if __name__ == "__main__":
    test_home()
    test_setup()
    key_data = test_keygen()

    sample_text = b"This is a test message for CP-ABE hybrid encryption"
    policy = '(admin and it)'
    policy1= '(admin and it and now)'
    policy2= '(it and now) or admin'
    
    print("\nTest 1 - Should succeed:")
    encrypted_data = test_encrypt(policy, sample_text)
    decrypted_text = test_decrypt(key_data, encrypted_data)
    
    print("\nTest 2 - Should fail (insufficient attributes):")
    encrypted_data1 = test_encrypt(policy1, sample_text)
    decrypted_text1 = test_decrypt(key_data, encrypted_data1)
    
    print("\nTest 3 - Should succeed:")
    encrypted_data2 = test_encrypt(policy2, sample_text)
    decrypted_text2 = test_decrypt(key_data, encrypted_data2)
