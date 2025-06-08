import base64
import json
import time
import statistics
import matplotlib.pyplot as plt
import os

from cpabe_schemes import CPABEScheme

cpabe_instance = CPABEScheme()
cpabe_instance.setup()
PLOTS_DIR = "benchmark_plots"

# --- Test Functions ---
def test_keygen(attributes):
    return cpabe_instance.keygen(attributes)

def test_encrypt(policy, plaintext_bytes):
    return cpabe_instance.encrypt_data(policy, plaintext_bytes)

def test_decrypt(secret_key, encrypted_data, show=0):
    result = cpabe_instance.decrypt_data(secret_key, encrypted_data)
    if result is None:
        return None
    if show == 1:
        print("Decrypted Text:", result.decode())
    return result

# --- Benchmarking Logic ---
def run_benchmark(iterations=50):
    print(f"\n--- Running Benchmark ({iterations} iterations) ---")

    keygen_results = {}
    encrypt_results = {}
    decrypt_results = {}
    ciphertext_sizes = {}

    attribute_counts = [5, 10, 30, 50, 100]

    # Mở rộng danh sách attribute giả định đủ 100 phần tử
    all_possible_attributes = [
        "admin", "it", "dev", "hr", "finance", "support", "manager", "engineer", "designer", "qa",
        "product", "sales", "marketing", "legal", "ceo", "cto", "cfo", "intern", "contractor", "consultant",
        "security", "network", "database", "sysadmin", "research", "development", "testing", "audit", "compliance",
        "operations", "logistics", "customer_service", "training", "analytics", "data_science", "ux", "ui", "mobile",
        "web", "cloud", "devops", "qa_lead", "team_lead", "project_manager", "business_analyst", "accounting",
        "recruiter", "hr_manager", "product_owner", "scrum_master", "legal_advisor", "communications",
        "public_relations", "event_manager", "content_writer", "graphic_designer", "seo_specialist", "security_officer",
        "quality_assurance", "support_engineer", "technical_writer", "data_engineer", "solutions_architect",
        "system_engineer", "network_engineer", "application_developer", "database_administrator", "marketing_manager",
        "sales_manager", "finance_manager", "ceo_assistant", "cto_assistant", "cfo_assistant", "office_manager",
        "executive_assistant", "legal_counsel", "media_specialist", "social_media_manager", "content_manager",
        "video_editor", "photographer", "translator", "interpreter", "logistics_manager", "warehouse_manager",
        "security_manager", "training_manager", "operations_manager", "research_assistant", "lab_technician",
        "field_engineer", "maintenance_technician", "helpdesk"
    ]

    print("\nBenchmarking Key Generation with varying attribute counts...")
    for num_attrs in attribute_counts:
        current_attributes = all_possible_attributes[:num_attrs]
        keygen_times = []
        for _ in range(iterations):
            start_time = time.perf_counter()
            key_data = test_keygen(current_attributes)
            end_time = time.perf_counter()
            if key_data:
                keygen_times.append(end_time - start_time)
            else:
                print(f"Keygen failed for {num_attrs} attributes.")
                break

        if keygen_times:
            keygen_results[num_attrs] = keygen_times
            print(f"  Keygen ({num_attrs} attrs, avg): {statistics.mean(keygen_times):.6f} seconds")

    comprehensive_key_data = test_keygen(all_possible_attributes)
    if not comprehensive_key_data:
        print("Failed to generate key for full attribute set.")
        return keygen_results, {}, {}, {}, {}

    policies = {
        "P1 (Simple)": '(admin and it)',
        "P2 (Medium)": '(admin and (it or dev) and hr)',
        "P3 (Complex)": '((admin and finance) or (it and support)) and manager and (qa or designer)'
    }

    plaintext_sizes = {
        "1KB": b"A" * 1024,
        "10KB": b"B" * 10 * 1024,
        "100KB": b"C" * 100 * 1024,
        "1MB": b"D" * 1024 * 1024,
        "2MB": b"E" * 2 * 1024 * 1024,
        "4MB": b"F" * 4 * 1024 * 1024
    }

    for size_label, plaintext_bytes in plaintext_sizes.items():
        encrypt_results[size_label] = {}
        decrypt_results[size_label] = {}
        ciphertext_sizes[size_label] = {}

        print(f"\nBenchmarking Encryption/Decryption for {size_label} ({len(plaintext_bytes)} bytes):")
        for policy_label, policy_str in policies.items():
            encrypt_times = []
            decrypt_times = []
            ciphertext_lengths = []

            for _ in range(iterations):
                start_time_enc = time.perf_counter()
                encrypted_data = test_encrypt(policy_str, plaintext_bytes)
                end_time_enc = time.perf_counter()

                if encrypted_data:
                    encrypt_times.append(end_time_enc - start_time_enc)
                    ciphertext_lengths.append(len(json.dumps(encrypted_data).encode('utf-8')))
                else:
                    print(f"Encryption failed for {size_label}, policy '{policy_label}'")
                    break

                start_time_dec = time.perf_counter()
                decrypted = test_decrypt(comprehensive_key_data, encrypted_data)
                end_time_dec = time.perf_counter()
                if decrypted and decrypted == plaintext_bytes:
                    decrypt_times.append(end_time_dec - start_time_dec)
                else:
                    print(f"Decryption failed or mismatch for {size_label}, policy '{policy_label}'")

            if encrypt_times:
                encrypt_results[size_label][policy_label] = encrypt_times
                print(f"    Encrypt avg: {statistics.mean(encrypt_times):.6f} seconds")
            if decrypt_times:
                decrypt_results[size_label][policy_label] = decrypt_times
                print(f"    Decrypt avg: {statistics.mean(decrypt_times):.6f} seconds")
            if ciphertext_lengths:
                ciphertext_sizes[size_label][policy_label] = statistics.mean(ciphertext_lengths)

    print("\n--- Benchmark Complete ---")
    return keygen_results, encrypt_results, decrypt_results, plaintext_sizes, ciphertext_sizes

# --- Plotting ---
def plot_benchmarks(keygen_data, encrypt_data, decrypt_data, plaintext_sizes, ciphertext_sizes):
    if not os.path.exists(PLOTS_DIR):
        os.makedirs(PLOTS_DIR)

    keygen_avg_ms = {k: statistics.mean(v) * 1000 for k, v in keygen_data.items() if v}
    encrypt_avg_ms = {
        size: {p: statistics.mean(t) * 1000 for p, t in pdata.items()}
        for size, pdata in encrypt_data.items()
    }
    decrypt_avg_ms = {
        size: {p: statistics.mean(t) * 1000 for p, t in pdata.items()}
        for size, pdata in decrypt_data.items()
    }

    size_to_kb = {
        "1KB": 1, "10KB": 10, "100KB": 100,
        "1MB": 1024, "2MB": 2048, "4MB": 4096
    }
    sorted_sizes = sorted(plaintext_sizes.keys(), key=lambda s: size_to_kb[s])
    x_values_kb = [size_to_kb[s] for s in sorted_sizes]

    # --- Keygen ---
    if keygen_avg_ms:
        attr_counts = sorted(keygen_avg_ms.keys())
        y_values = [keygen_avg_ms[n] for n in attr_counts]

        plt.figure(figsize=(10, 6))
        plt.plot(attr_counts, y_values, marker='o', color='blue', label='Keygen Time')
        for x, y in zip(attr_counts, y_values):
            plt.text(x, y + 1, f"{y:.1f}", ha='center', fontsize=9)
        plt.title('Key Generation Time')
        plt.xlabel('Number of Attributes')
        plt.ylabel('Average Time (ms)')
        plt.grid(True)
        plt.xticks(attr_counts)
        plt.tight_layout()
        plt.savefig(os.path.join(PLOTS_DIR, 'keygen_benchmark.png'))
        plt.show()

    # --- Encryption ---
    if encrypt_avg_ms:
        plt.figure(figsize=(12, 7))
        policy_labels = sorted(next(iter(encrypt_avg_ms.values())).keys())

        for policy in policy_labels:
            y_values = [encrypt_avg_ms[s].get(policy, 0) for s in sorted_sizes]
            plt.plot(x_values_kb, y_values, marker='o', label=policy)
            for x, y in zip(x_values_kb, y_values):
                plt.text(x, y + 1, f"{y:.1f}", ha='center', fontsize=8)

        plt.title('Encryption Time')
        plt.xlabel('Plaintext Size (KB)')
        plt.ylabel('Average Time (ms)')
        plt.legend()
        plt.grid(True)
        plt.xscale('log')
        plt.xticks(x_values_kb, sorted_sizes, rotation=30)
        plt.tight_layout()
        plt.savefig(os.path.join(PLOTS_DIR, 'encryption_benchmark.png'))
        plt.show()

    # --- Decryption ---
    if decrypt_avg_ms:
        plt.figure(figsize=(12, 7))
        policy_labels = sorted(next(iter(decrypt_avg_ms.values())).keys())

        for policy in policy_labels:
            y_values = [decrypt_avg_ms[s].get(policy, 0) for s in sorted_sizes]
            plt.plot(x_values_kb, y_values, marker='o', label=policy)
            for x, y in zip(x_values_kb, y_values):
                plt.text(x, y + 1, f"{y:.1f}", ha='center', fontsize=8)

        plt.title('Decryption Time')
        plt.xlabel('Plaintext Size (KB)')
        plt.ylabel('Average Time (ms)')
        plt.legend()
        plt.grid(True)
        plt.xscale('log')
        plt.xticks(x_values_kb, sorted_sizes, rotation=30)
        plt.tight_layout()
        plt.savefig(os.path.join(PLOTS_DIR, 'decryption_benchmark.png'))
        plt.show()

    if ciphertext_sizes:
        avg_ciphertext_sizes = []
        for size in sorted_sizes:
            policies_data = ciphertext_sizes.get(size, {})
            if policies_data:
                avg_size = sum(policies_data.values()) / len(policies_data)
                avg_ciphertext_sizes.append(avg_size)
            else:
                avg_ciphertext_sizes.append(0)

        plt.figure(figsize=(10, 6))
        plt.bar(sorted_sizes, avg_ciphertext_sizes, color='purple', alpha=0.7)
        for i, val in enumerate(avg_ciphertext_sizes):
            plt.text(i, val + max(avg_ciphertext_sizes)*0.01, f"{val:.0f}", ha='center', fontsize=9)
        plt.title('Average Ciphertext Size (bytes) over all Policies')
        plt.xlabel('Plaintext Size')
        plt.ylabel('Ciphertext Size (bytes)')
        plt.grid(axis='y')
        plt.tight_layout()
        plt.savefig(os.path.join(PLOTS_DIR, 'ciphertext_size_average.png'))
        plt.show()

# --- Main ---
if __name__ == "__main__":
    key_data = test_keygen(["admin", "it"])
    sample_text = b"This is a test message for CP-ABE hybrid encryption"

    policy = '(admin and it)'
    policy1 = '(admin and it and now)'
    policy2 = '(it and now) or admin'

    print("\n--- Manual Test Cases ---")
    print("\nTest 1 - Should succeed:")
    encrypted_data = test_encrypt(policy, sample_text)
    if encrypted_data:
        test_decrypt(key_data, encrypted_data, show=1)

    print("\nTest 2 - Should fail (insufficient attributes):")
    encrypted_data1 = test_encrypt(policy1, sample_text)
    if encrypted_data1:
        test_decrypt(key_data, encrypted_data1, show=1)

    print("\nTest 3 - Should succeed:")
    encrypted_data2 = test_encrypt(policy2, sample_text)
    if encrypted_data2:
        test_decrypt(key_data, encrypted_data2, show=1)

    keygen_data, encrypt_data, decrypt_data, plaintext_sizes, ciphertext_sizes = run_benchmark(iterations=50)
    plot_benchmarks(keygen_data, encrypt_data, decrypt_data, plaintext_sizes, ciphertext_sizes)
