#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -o pipefail

CIRCUIT_NAME="AssetOwnerMerkle"
INPUT_DATA="0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d"
PTAU_NAME="pot21"
ZKEY_NAME="${CIRCUIT_NAME}.zkey"
PHASE2_ZKEY="${CIRCUIT_NAME}_0001.zkey"

echo "1. Compile Circom circuit..."
circom ${CIRCUIT_NAME}.circom --r1cs --wasm --sym

echo "2. Generate input JSON..."
node input_1_data ${INPUT_DATA}

echo "3. Generate witness..."
node ${CIRCUIT_NAME}_js/generate_witness.js ${CIRCUIT_NAME}_js/${CIRCUIT_NAME}.wasm input/input_1_data.json witness.wtns

echo "4. Start Powers of Tau ceremony (2^21)..."
snarkjs powersoftau new bn128 21 ${PTAU_NAME}_0000.ptau -v
snarkjs powersoftau contribute ${PTAU_NAME}_0000.ptau ${PTAU_NAME}_0001.ptau --name="First contribution" -v

echo "5. Prepare phase 2..."
snarkjs powersoftau prepare phase2 ${PTAU_NAME}_0001.ptau ${PTAU_NAME}_final.ptau -v

echo "6. Run Groth16 setup..."
node --max-old-space-size=9216 $(which snarkjs) groth16 setup ${CIRCUIT_NAME}.r1cs ${PTAU_NAME}_final.ptau ${ZKEY_NAME}
snarkjs zkey contribute ${ZKEY_NAME} ${PHASE2_ZKEY} --name="1st Contributor Name" -v

echo "7. Export verification key..."
snarkjs zkey export verificationkey ${PHASE2_ZKEY} verification_key.json

echo "8. Generate proof..."
mkdir -p ../../proof
snarkjs groth16 prove ${PHASE2_ZKEY} witness.wtns ../../proof/proof.json ../../proof/public.json

echo "9. Verify proof..."
snarkjs groth16 verify verification_key.json ../../proof/public.json ../../proof/proof.json

echo "All steps completed successfully."
