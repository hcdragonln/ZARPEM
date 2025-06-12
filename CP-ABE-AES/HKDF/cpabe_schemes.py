import base64
from charm.toolbox.pairinggroup import PairingGroup, GT
from charm.schemes.abenc.abenc_bsw07 import CPabe_BSW07
from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes
from cryptography.hazmat.primitives.kdf.hkdf import HKDF
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.backends import default_backend
import logging
import json
import os

# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

class CPABEScheme:
    def __init__(self):
        try:
            # Initialize with SS512 curve
            self.group = PairingGroup('SS512')
            logger.debug("PairingGroup initialized successfully")
            self.cpabe = CPabe_BSW07(self.group)
            logger.debug("CPabe_BSW07 scheme initialized")
            self.public_key = None
            self.master_key = None
            self.MAX_PLAINTEXT_SIZE = 1024 * 1024 * 10  # 10MB limit
            
            # Setup keys directory and file paths
            self.KEYS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "keys")
            if not os.path.exists(self.KEYS_DIR):
                os.makedirs(self.KEYS_DIR)
                logger.debug(f"Created keys directory: {self.KEYS_DIR}")
            
            # Define key file paths
            self.PUBLIC_KEY_FILE = os.path.join(self.KEYS_DIR, "public_key.pem")
            self.MASTER_KEY_FILE = os.path.join(self.KEYS_DIR, "master_key.pem")
            
        except Exception as e:
            logger.error(f"Initialization error: {str(e)}")
            raise

    def _to_pem_format(self, key_type, key_data):
        """Convert key data to PEM format"""
        # Convert dictionary to JSON and encode to base64
        key_json = json.dumps(key_data, sort_keys=True)
        key_b64 = base64.b64encode(key_json.encode()).decode()
        
        # Split into 64-character lines
        lines = [key_b64[i:i+64] for i in range(0, len(key_b64), 64)]
        
        # Create PEM format
        pem_lines = [
            f"-----BEGIN {key_type} KEY-----",
            *lines,
            f"-----END {key_type} KEY-----"
        ]
        return "\n".join(pem_lines)

    def _from_pem_format(self, pem_data):
        """Extract key data from PEM format"""
        try:
            # Remove header and footer
            lines = pem_data.strip().split('\n')
            if len(lines) < 3:
                raise ValueError("Invalid PEM format")
                
            # Extract base64 content
            content = ''.join(lines[1:-1])
            
            # Decode base64 and parse JSON
            json_data = base64.b64decode(content).decode()
            return json.loads(json_data)
        except Exception as e:
            logger.error(f"Failed to parse PEM data: {str(e)}")
            return None

    def serialize_key_element(self, element):
        """Serialize a single key element to base64"""
        try:
            if hasattr(element, 'initPP'):  # Check if it's a pairing element
                element_bytes = self.group.serialize(element)
                return base64.b64encode(element_bytes).decode('utf-8')
            return str(element)
        except Exception as e:
            logger.error(f"Failed to serialize key element: {str(e)}")
            return None

    def deserialize_key_element(self, element_str):
        """Deserialize a single key element from base64"""
        try:
            # Special handling for 'S' field which should remain as string
            if isinstance(element_str, str) and element_str.startswith('[') and element_str.endswith(']'):
                return element_str
            
            # For base64 encoded elements
            if isinstance(element_str, str):
                try:
                    element_bytes = base64.b64decode(element_str)
                    return self.group.deserialize(element_bytes)
                except Exception as e:
                    logger.debug(f"Not a serialized group element, returning as is: {str(e)}")
                    return element_str
        
            # For numeric values, convert to string to maintain consistency
            if isinstance(element_str, (int, float)):
                return str(element_str)
            
            return element_str
        except Exception as e:
            logger.error(f"Failed to deserialize element: {str(e)}")
            return None

    def save_keys(self):
        """Save public key and master key to separate PEM files"""
        try:
            if not self.public_key or not self.master_key:
                logger.error("Keys not initialized")
                return False

            # Ensure keys directory exists
            os.makedirs(self.KEYS_DIR, exist_ok=True)

            # Serialize public key components
            pk_data = {}
            for k, v in self.public_key.items():
                serialized = self.serialize_key_element(v)
                if serialized:
                    pk_data[k] = serialized

            # Serialize master key components
            mk_data = {}
            for k, v in self.master_key.items():
                serialized = self.serialize_key_element(v)
                if serialized:
                    mk_data[k] = serialized

            # Convert to PEM format and save
            public_pem = self._to_pem_format("CP-ABE PUBLIC", pk_data)
            master_pem = self._to_pem_format("CP-ABE MASTER", mk_data)

            # Save to files
            with open(self.PUBLIC_KEY_FILE, 'w') as f:
                f.write(public_pem)
            with open(self.MASTER_KEY_FILE, 'w') as f:
                f.write(master_pem)

            logger.debug(f"Keys saved successfully to {self.KEYS_DIR}")
            return True

        except Exception as e:
            logger.error(f"Failed to save keys: {str(e)}")
            return False

    def load_keys(self):
        """Load public key and master key from PEM files"""
        try:
            if not os.path.exists(self.PUBLIC_KEY_FILE) or not os.path.exists(self.MASTER_KEY_FILE):
                logger.debug("Key files not found, running setup")
                return self.setup()

            # Read PEM files
            with open(self.PUBLIC_KEY_FILE, 'r') as f:
                public_pem = f.read()
            with open(self.MASTER_KEY_FILE, 'r') as f:
                master_pem = f.read()

            # Parse PEM data
            pk_data = self._from_pem_format(public_pem)
            mk_data = self._from_pem_format(master_pem)

            if not pk_data or not mk_data:
                logger.error("Failed to parse key files")
                return False

            # Deserialize public key
            pk = {}
            for k, v in pk_data.items():
                pk[k] = self.deserialize_key_element(v)

            # Deserialize master key
            mk = {}
            for k, v in mk_data.items():
                mk[k] = self.deserialize_key_element(v)

            # Set the keys
            self.public_key = pk
            self.master_key = mk

            logger.debug("Keys loaded successfully")
            return True

        except Exception as e:
            logger.error(f"Failed to load keys: {str(e)}")
            return False

    def setup(self):
        try:
            logger.debug("Starting setup...")
            (pk, mk) = self.cpabe.setup()
            if pk and mk:
                self.public_key = pk
                self.master_key = mk
                # Save keys after successful setup
                if self.save_keys():
                    logger.debug("Setup completed and keys saved successfully")
                    return True
                else:
                    logger.error("Setup completed but failed to save keys")
                    return False
            else:
                logger.error("Setup failed: public key or master key is None")
                return False
        except Exception as e:
            logger.error(f"Setup failed with error: {str(e)}")
            return False

    def normalize_attribute(self, attr):
        """Helper function to normalize attribute names"""
        if not attr:
            return None
        # Convert to uppercase and replace spaces/special chars
        return attr.strip().upper().replace(" ", "_")

    def clean_base64(self, s):
        """Clean and normalize base64 string"""
        try:
            if not isinstance(s, str):
                return None
            # Remove whitespace and newlines
            s = ''.join(s.split())
            # Remove any invalid characters (keep only base64 valid chars)
            s = ''.join(c for c in s if c in 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=')
            return s
        except Exception as e:
            logger.error(f"Failed to clean base64 string: {str(e)}")
            return None

    def pad_base64(self, s):
        """Helper function to ensure base64 string is properly padded"""
        try:
            if not isinstance(s, str):
                return None
            # Clean the string first
            s = self.clean_base64(s)
            if not s:
                return None
            # Remove any existing padding
            s = s.rstrip('=')
            # Add proper padding
            mod = len(s) % 4
            if mod:
                s += '=' * (4 - mod)
            return s
        except Exception as e:
            logger.error(f"Failed to pad base64 string: {str(e)}")
            return None

    def serialize_element(self, element):
        """Helper function to safely serialize group elements"""
        try:
            if element is None:
                return None

            # Handle pairing elements
            if hasattr(element, 'initPP'):
                try:
                    serialized = self.group.serialize(element)
                    if not serialized:
                        logger.error("Failed to serialize pairing element")
                        return None
                    encoded = base64.b64encode(serialized)
                    return encoded.decode('utf-8')
                except Exception as e:
                    logger.error(f"Failed to serialize pairing element: {str(e)}")
                    return None

            # Handle bytes
            if isinstance(element, bytes):
                try:
                    encoded = base64.b64encode(element)
                    return encoded.decode('utf-8')
                except Exception as e:
                    logger.error(f"Failed to encode bytes: {str(e)}")
                    return None

            # Handle strings
            if isinstance(element, str):
                return element

            # Handle other types
            return str(element)

        except Exception as e:
            logger.error(f"Failed to serialize element: {str(e)}")
            return None

    def deserialize_element(self, element_str):
        """Helper function to safely deserialize group elements"""
        try:
            if element_str is None:
                return None

            # Special handling for 'S' field which should remain as string
            if isinstance(element_str, str) and element_str.startswith('[') and element_str.endswith(']'):
                return element_str

            # Handle numeric values (including lists of numbers)
            if isinstance(element_str, (int, float, list)):
                return element_str

            # Handle string values
            if isinstance(element_str, str):
                try:
                    # Clean and pad base64 string
                    clean_str = self.pad_base64(element_str)
                    if not clean_str:
                        logger.debug("Invalid base64 string after cleaning")
                        return element_str

                    # Try to decode base64
                    decoded = base64.b64decode(clean_str)
                    if not decoded:
                        logger.debug("Base64 decoding resulted in empty bytes")
                        return element_str

                    # Try to deserialize as a group element
                    try:
                        result = self.group.deserialize(decoded)
                        if result is not None:
                            return result
                    except Exception as e:
                        logger.debug(f"Group deserialization failed: {str(e)}")
                        # If not a group element, return the original string
                        return element_str

                except Exception as e:
                    logger.debug(f"Base64 decoding failed: {str(e)}")
                    # If decoding fails, return the original string
                    return element_str

            return element_str

        except Exception as e:
            logger.error(f"Failed to deserialize element: {str(e)}")
            return element_str

    def serialize_cpabe_cipher(self, cpabe_cipher):
        """Helper function to serialize CP-ABE ciphertext"""
        try:
            if not isinstance(cpabe_cipher, dict):
                raise ValueError("CP-ABE cipher must be a dictionary")

            serialized = {}
            for key, value in cpabe_cipher.items():
                if value is None:
                    continue

                # Special handling for policy and attributes
                if key in ['policy', 'attributes']:
                    serialized[key] = str(value)
                    continue

                if isinstance(value, dict):
                    # Handle nested dictionaries (like 'C' component)
                    component_dict = {}
                    for sub_k, sub_v in value.items():
                        if sub_v is not None:
                            serialized_val = self.serialize_element(sub_v)
                            if serialized_val is not None:
                                component_dict[sub_k] = serialized_val
                    if component_dict:
                        serialized[key] = component_dict
                else:
                    # Handle direct elements
                    serialized_val = self.serialize_element(value)
                    if serialized_val is not None:
                        serialized[key] = serialized_val

            if not serialized:
                raise ValueError("Failed to serialize any cipher components")

            return serialized
        except Exception as e:
            logger.error(f"Failed to serialize CP-ABE cipher: {str(e)}")
            raise

    def deserialize_cpabe_cipher(self, serialized_cipher):
        """Helper function to deserialize CP-ABE ciphertext"""
        try:
            if not isinstance(serialized_cipher, dict):
                raise ValueError("Serialized cipher must be a dictionary")

            deserialized = {}
            for key, value in serialized_cipher.items():
                if value is None:
                    continue

                # Special handling for policy and attributes
                if key in ['policy', 'attributes']:
                    deserialized[key] = str(value)
                    continue

                if isinstance(value, dict):
                    # Handle nested dictionaries
                    component_dict = {}
                    for sub_k, sub_v in value.items():
                        if sub_v is not None:
                            deserialized_val = self.deserialize_element(sub_v)
                            if deserialized_val is not None:
                                component_dict[sub_k] = deserialized_val
                    if component_dict:
                        deserialized[key] = component_dict
                else:
                    # Handle direct elements
                    deserialized_val = self.deserialize_element(value)
                    if deserialized_val is not None:
                        deserialized[key] = deserialized_val

            if not deserialized:
                raise ValueError("Failed to deserialize any cipher components")

            # Verify required components are present
            required_components = {'C_tilde', 'C', 'Cy', 'Cyp', 'policy'}
            missing = required_components - set(deserialized.keys())
            if missing:
                raise ValueError(f"Missing required cipher components: {missing}")

            # Ensure policy is a string
            if not isinstance(deserialized.get('policy'), str):
                raise ValueError("Policy must be a string")

            return deserialized
        except Exception as e:
            logger.error(f"Failed to deserialize CP-ABE cipher: {str(e)}")
            raise

    def keygen(self, attributes):
        # Validate initialization
        if not self.public_key or not self.master_key:
            raise RuntimeError("CPABEScheme not initialized. Call setup() first")

        # Validate attributes
        if not attributes or not isinstance(attributes, list):
            raise ValueError("Attributes must be a non-empty list")

        try:
            # Clean and normalize attributes
            cleaned_attributes = []
            for attr in attributes:
                if isinstance(attr, str):
                    normalized_attr = self.normalize_attribute(attr)
                    if normalized_attr:
                        cleaned_attributes.append(normalized_attr)
                        logger.debug(f"Normalized attribute: {normalized_attr}")

            if not cleaned_attributes:
                raise ValueError("No valid attributes after cleaning")

            # Log the attributes being used
            logger.debug(f"Generating key for attributes: {cleaned_attributes}")

            # Generate the secret key
            try:
                sk = self.cpabe.keygen(self.public_key, self.master_key, cleaned_attributes)
                if not sk:
                    raise ValueError("Key generation failed - empty key returned")
                logger.debug(f"Generated key components: {list(sk.keys())}")
            except Exception as e:
                logger.error(f"Failed to generate key: {str(e)}")
                raise ValueError(f"Key generation failed: {str(e)}")

            # Validate key components
            required_components = {'D', 'Dj', 'Djp'}
            if not all(k in sk for k in required_components):
                missing = required_components - set(sk.keys())
                raise ValueError(f"Generated key missing required components: {missing}")

            # Validate component types
            if not isinstance(sk['D'], (bytes, object)) or not hasattr(sk['D'], 'initPP'):
                raise ValueError("Invalid type for key component 'D'")
            if not isinstance(sk['Dj'], dict):
                raise ValueError("Invalid type for key component 'Dj'")
            if not isinstance(sk['Djp'], dict):
                raise ValueError("Invalid type for key component 'Djp'")
            
            # Serialize each component
            serialized_sk = {}
            for k, v in sk.items():
                try:
                    if v is not None:
                        if isinstance(v, dict):
                            # Handle dictionary components (like 'Dj')
                            component_dict = {}
                            for sub_k, sub_v in v.items():
                                if sub_v is not None:
                                    serialized = self.serialize_element(sub_v)
                                    if serialized is not None:
                                        component_dict[sub_k] = serialized
                            if component_dict:
                                serialized_sk[k] = component_dict
                        else:
                            # Handle direct elements
                            serialized = self.serialize_element(v)
                            if serialized is not None:
                                serialized_sk[k] = serialized
                except Exception as e:
                    logger.error(f"Failed to serialize key component {k}: {str(e)}")
                    continue

            if not serialized_sk:
                raise ValueError("Failed to serialize any key components")

            # Validate serialized key components
            if not all(k in serialized_sk for k in required_components):
                missing = required_components - set(serialized_sk.keys())
                raise ValueError(f"Serialized key missing required components: {missing}")

            # Create the final key structure
            result = {
                "secret_key": serialized_sk
            }

            # Validate the final structure
            if not isinstance(result["secret_key"], dict):
                raise ValueError("Invalid secret key structure")

            logger.debug("Key generation completed successfully")
            logger.debug(f"Final key structure: secret_key components={list(serialized_sk.keys())}")
            
            return result

        except Exception as e:
            logger.error(f"Key generation failed: {str(e)}")
            raise RuntimeError(f"Key generation failed: {str(e)}")

    def parse_policy(self, policy):
        """Parse a policy string into a structured format"""
        if not isinstance(policy, str) or not policy:
            raise ValueError("Policy must be a non-empty string")
        
        # Add spaces around parentheses to ensure proper tokenization
        policy = policy.replace('(', ' ( ').replace(')', ' ) ')
        # Split into tokens and remove empty strings
        tokens = [t for t in policy.split() if t.strip()]
        
        def parse_expression(tokens, start=0):
            result = {"type": "AND", "children": []}
            current_op = "AND"
            i = start
            
            while i < len(tokens):
                token = tokens[i].upper()
                
                if token == "AND" or token == "OR":
                    current_op = token
                    result["type"] = token
                    i += 1
                    continue
                    
                if token == "(":
                    sub_expr, new_i = parse_expression(tokens, i + 1)
                    result["children"].append(sub_expr)
                    i = new_i
                    continue
                    
                if token == ")":
                    return result, i + 1
                
                # Handle attributes
                if token not in ["(", ")", "AND", "OR"]:
                    result["children"].append({"type": "ATTR", "value": self.normalize_attribute(token)})
                i += 1
                
            return result, i
        
        parsed, _ = parse_expression(tokens)
        return parsed

    def evaluate_policy(self, policy_tree, attributes):
        """Evaluate if a set of attributes satisfies a policy tree"""
        if not policy_tree:
            return False
            
        if policy_tree["type"] == "ATTR":
            return policy_tree["value"] in attributes
            
        if policy_tree["type"] == "AND":
            return all(self.evaluate_policy(child, attributes) for child in policy_tree["children"])
            
        if policy_tree["type"] == "OR":
            return any(self.evaluate_policy(child, attributes) for child in policy_tree["children"])
            
        return False

    def validate_policy(self, policy):
        """Validate policy format and structure"""
        if not isinstance(policy, str) or not policy:
            raise ValueError("Policy must be a non-empty string")
            
        try:
            # Try to parse the policy to validate its structure
            policy_tree = self.parse_policy(policy)
            return True
        except Exception as e:
            raise ValueError(f"Invalid policy structure: {str(e)}")


    def encrypt_data(self, policy: str, plaintext_bytes: bytes) -> dict:
        """
        Encrypts plaintext data using a hybrid approach:
        1. Generates a random session key (GT element).
        2. Encrypts the session key using CP-ABE under the specified policy.
        3. Derives an AES key from the session key using HKDF.
        4. Encrypts the actual plaintext data with AES-256 GCM using the derived key.

        Args:
            policy (str): The access policy string (e.g., "ROLE:DOCTOR AND LOCATION:HOSPITAL_A").
            plaintext_bytes (bytes): The data to be encrypted, as bytes.

        Returns:
            dict: A dictionary containing the encrypted data components (nonce, ciphertext, tag,
                  CP-ABE ciphertext, and the policy used), all base64-encoded.

        Raises:
            RuntimeError: If CPABEScheme is not initialized.
            ValueError: If input data is invalid or encryption fails.
        """
        # Ensure the public key is loaded/set up
        if not self.public_key:
            raise RuntimeError("CPABEScheme not initialized. Call setup() first.")

        # Validate plaintext data
        if not isinstance(plaintext_bytes, bytes):
            raise TypeError("Plaintext data must be provided as bytes.")
        if len(plaintext_bytes) > self.MAX_PLAINTEXT_SIZE:
            raise ValueError(f"Data size ({len(plaintext_bytes)} bytes) exceeds maximum limit of {self.MAX_PLAINTEXT_SIZE} bytes.")

        try:
            # Normalize attributes within the policy string while preserving operators and structure
            # Example: "admin AND (finance OR HR)"
            policy_tokens = policy.split()
            normalized_policy_tokens = []
            for token in policy_tokens:
                upper_token = token.upper()
                # Keep logical operators and parentheses as they are
                if upper_token in ['AND', 'OR', '(', ')', 'OF']: # 'OF' for threshold policies, though BSW07 primarily handles AND/OR
                    normalized_policy_tokens.append(upper_token)
                else:
                    # Normalize actual attributes
                    normalized_attr = self.normalize_attribute(token)
                    if normalized_attr:
                        normalized_policy_tokens.append(normalized_attr)
                    else:
                        logger.warning(f"Attribute '{token}' normalized to an empty string. This might cause policy validation issues.")
                        # Decide how to handle empty normalized attributes: omit, replace, or raise error.
                        # For now, it's included, but validation will likely catch it.
                        normalized_policy_tokens.append(token) # Keep original if normalization results in empty string to avoid breaking policy syntax.

            normalized_policy = ' '.join(normalized_policy_tokens)
            
            # Validate the normalized policy format and structure
            self.validate_policy(normalized_policy)
            logger.debug(f"Policy normalized and validated for encryption: '{normalized_policy}'.")

            # 1. Generate a random element from the GT group to serve as the session key
            session_key_gt = self.group.random(GT)
            logger.debug("Random GT element (session key) generated for encryption.")

            # 2. Encrypt the session key using CP-ABE under the specified policy
            cpabe_ciphertext_elements = self.cpabe.encrypt(self.public_key, session_key_gt, normalized_policy)
            if not cpabe_ciphertext_elements:
                raise RuntimeError("CP-ABE encryption of session key failed.")
            
            # Store the original policy string within the CP-ABE ciphertext structure for later use
            cpabe_ciphertext_elements['policy'] = normalized_policy 
            logger.debug("CP-ABE encryption of session key successful.")

            # Serialize the CP-ABE ciphertext components into a JSON-serializable dictionary
            serialized_cpabe_cipher = self.serialize_cpabe_cipher(cpabe_ciphertext_elements)
            # Convert the serialized dictionary to a JSON string, then encode to bytes for base64
            cpabe_cipher_json_bytes = json.dumps(serialized_cpabe_cipher).encode('utf-8')

            # 3. Derive a fixed-length AES key from the session key (GT element) using HKDF
            session_key_bytes = self.group.serialize(session_key_gt)
            
            # IMPORTANT: The 'info' parameter MUST be identical during encryption and decryption
            # to ensure the same AES key is derived.
            hkdf_info = b'cpabe-hybrid-aes-key-derivation' # Consistent HKDF info string
            
            hkdf = HKDF(
                algorithm=hashes.SHA256(), # Use SHA256 as the hash function
                length=32,                  # Derive a 256-bit (32-byte) key for AES-256
                salt=None,                  # No salt used in this specific scheme, but generally recommended
                info=hkdf_info,             # Application-specific context information
                backend=default_backend()   # Use default cryptographic backend
            )
            aes_key = hkdf.derive(session_key_bytes)
            logger.debug("AES key derived from session key using HKDF.")

            # 4. Encrypt the actual plaintext data with AES-256 in GCM (Galois/Counter Mode)
            aes_nonce = get_random_bytes(12) # GCM recommends a 12-byte (96-bit) nonce
            aes_cipher = AES.new(aes_key, AES.MODE_GCM, nonce=aes_nonce)
            
            # encrypt_and_digest returns the ciphertext and the authentication tag
            ciphertext, tag = aes_cipher.encrypt_and_digest(plaintext_bytes)
            logger.debug("Plaintext data encrypted with AES-256 GCM.")

            # Assemble all encrypted components, base64-encoded for easy transfer/storage
            encrypted_result = {
                "nonce": base64.b64encode(aes_nonce).decode('utf-8'),
                "ciphertext": base64.b64encode(ciphertext).decode('utf-8'),
                "tag": base64.b64encode(tag).decode('utf-8'),
                "cpabe_cipher": base64.b64encode(cpabe_cipher_json_bytes).decode('utf-8'),
                "policy": normalized_policy # Store the policy used for encryption
            }
            logger.debug("Encryption process completed successfully.")
            return encrypted_result

        except Exception as e:
            logger.error(f"Encryption failed: {str(e)}")
            raise RuntimeError(f"Encryption failed: {str(e)}")

    def decrypt_data(self, secret_key_dict: dict, encrypted_dict: dict) -> bytes:
        """
        Decrypts data that was encrypted using the `encrypt_data` method.
        The process involves:
        1. Deserializing and validating the provided secret key.
        2. Deserializing the CP-ABE ciphertext from the encrypted dictionary.
        3. Decrypting the session key (GT element) using the secret key.
        4. Deriving the same AES key from the recovered session key using HKDF.
        5. Decrypting the actual data using AES-256 GCM with the derived key.

        Args:
            secret_key_dict (dict): The serialized secret key dictionary
                                    (as returned by keygen, under "secret_key").
            encrypted_dict (dict): The dictionary containing encrypted data components
                                   (nonce, ciphertext, tag, cpabe_cipher, policy).

        Returns:
            bytes: The original decrypted plaintext data.

        Raises:
            ValueError: If input dictionaries are invalid, components are missing,
                        or decryption fails at any stage (e.g., policy not satisfied,
                        invalid AES tag).
            RuntimeError: For unexpected errors during the decryption process.
        """
        try:
            # 1. Validate input secret key dictionary structure
            if not isinstance(secret_key_dict, dict) or "secret_key" not in secret_key_dict:
                raise ValueError("Secret key dictionary must be a dictionary and contain a 'secret_key' field.")
            
            sk_components_serialized = secret_key_dict["secret_key"]
            if not isinstance(sk_components_serialized, dict):
                raise ValueError("'secret_key' field in secret key dictionary must be a dictionary of components.")

            # Required components for the Charm-Crypto secret key
            required_sk_components = {'D', 'Dj', 'Djp'}
            missing_sk_comps = required_sk_components - set(sk_components_serialized.keys())
            if missing_sk_comps:
                raise ValueError(f"Missing required secret key components: {missing_sk_comps}.")

            # Deserialize the secret key components
            sk = {}
            for k, v in sk_components_serialized.items():
                try:
                    if isinstance(v, dict): # Handle nested dictionaries (e.g., Dj, Djp)
                        nested_dict = {}
                        for sub_k, sub_v in v.items():
                            deserialized_val = self.deserialize_element(sub_v)
                            if deserialized_val is not None:
                                nested_dict[sub_k] = deserialized_val
                        if nested_dict:
                            sk[k] = nested_dict
                    else: # Handle direct elements (e.g., D)
                        deserialized_val = self.deserialize_element(v)
                        if deserialized_val is not None:
                            sk[k] = deserialized_val
                except Exception as e:
                    logger.error(f"Failed to deserialize secret key component '{k}': {str(e)}")
                    raise ValueError(f"Failed to deserialize secret key component: {str(e)}")
            logger.debug("Secret key successfully deserialized.")

            # 2. Decode and deserialize the CP-ABE ciphertext from the encrypted_dict
            cpabe_cipher_b64 = encrypted_dict.get('cpabe_cipher')
            if not cpabe_cipher_b64:
                raise ValueError("Encrypted dictionary missing 'cpabe_cipher' component.")

            try:
                cpabe_cipher_json_bytes = base64.b64decode(cpabe_cipher_b64)
                serialized_cpabe_cipher = json.loads(cpabe_cipher_json_bytes.decode('utf-8'))
                cpabe_cipher_elements = self.deserialize_cpabe_cipher(serialized_cpabe_cipher)
                logger.debug("CP-ABE ciphertext successfully decoded and deserialized.")
            except Exception as e:
                logger.error(f"Failed to decode or deserialize CP-ABE cipher from input: {str(e)}")
                raise ValueError(f"Failed to decode or deserialize CP-ABE cipher: {str(e)}")

            # 3. Decrypt the session key (GT element) using the CP-ABE scheme
            try:
                # Need the public key for decryption as well
                if not self.public_key:
                    raise RuntimeError("Public key not loaded. Cannot perform CP-ABE decryption.")

                session_key_gt = self.cpabe.decrypt(self.public_key, sk, cpabe_cipher_elements)
                
                # Charm-Crypto's decrypt returns None if policy is not satisfied
                if session_key_gt is None:
                    logger.info("CP-ABE decryption failed: policy not satisfied by the provided attributes.")
                    return None # Indicate decryption failure due to policy mismatch
                logger.debug("CP-ABE decryption successful, session key (GT element) recovered.")
            except Exception as e:
                # Catch specific exceptions from Charm-Crypto for policy issues
                if "insufficient attributes" in str(e).lower() or "policy not satisfied" in str(e).lower():
                    logger.info(f"CP-ABE decryption failed due to policy mismatch: {str(e)}")
                    return None
                else:
                    logger.error(f"CP-ABE decryption failed with an unexpected error: {str(e)}")
                    raise ValueError(f"CP-ABE decryption failed: {str(e)}")

            # 4. Derive the AES key using HKDF from the recovered session key
            try:
                if not hasattr(session_key_gt, 'initPP'):
                    logger.error("Recovered session key is not a valid Charm group element (GT).")
                    return None # Invalid session key format
                
                session_key_bytes = self.group.serialize(session_key_gt)
                if not session_key_bytes:
                    logger.error("Serialization of decrypted session key resulted in empty bytes.")
                    return None

                # IMPORTANT: 'info' parameter MUST match the one used during encryption
                hkdf_info = b'cpabe-hybrid-aes-key-derivation' # Consistent HKDF info string
                
                hkdf = HKDF(
                    algorithm=hashes.SHA256(),
                    length=32, # Expected AES-256 key length
                    salt=None,
                    info=hkdf_info,
                    backend=default_backend()
                )
                aes_key = hkdf.derive(session_key_bytes)
                logger.debug("AES key successfully derived from decrypted session key.")

            except Exception as e:
                logger.error(f"Failed to reconstruct AES key from decrypted session key: {str(e)}")
                raise ValueError(f"Failed to reconstruct AES key: {str(e)}")

            # 5. Decode AES parameters and perform AES-GCM decryption
            try:
                nonce_b64 = encrypted_dict.get('nonce')
                tag_b64 = encrypted_dict.get('tag')
                ciphertext_b64 = encrypted_dict.get('ciphertext')

                if not (nonce_b64 and tag_b64 and ciphertext_b64):
                    raise ValueError("Missing one or more AES components (nonce, tag, or ciphertext) in encrypted_dict.")

                nonce = base64.b64decode(nonce_b64)
                tag = base64.b64decode(tag_b64)
                ciphertext = base64.b64decode(ciphertext_b64)

                aes_cipher = AES.new(aes_key, AES.MODE_GCM, nonce=nonce)
                decrypted_plaintext = aes_cipher.decrypt_and_verify(ciphertext, tag)
                logger.debug("AES-GCM data decryption successful.")
                return decrypted_plaintext

            except Exception as e:
                logger.error(f"AES-GCM data decryption failed. This could be due to an incorrect key, "
                             f"invalid authentication tag, or corrupted ciphertext: {str(e)}")
                raise ValueError(f"AES-GCM decryption failed: {str(e)}")

        except ValueError as ve:
            logger.error(f"Decryption input validation error: {str(ve)}")
            raise # Re-raise ValueErrors for clear input issues
        except RuntimeError as re:
            logger.error(f"Decryption runtime error: {str(re)}")
            raise # Re-raise RuntimeErrors for critical operational failures
        except Exception as e:
            logger.error(f"An unexpected error occurred during the overall decryption process: {str(e)}")
            raise RuntimeError(f"Unexpected error during decryption: {str(e)}")



