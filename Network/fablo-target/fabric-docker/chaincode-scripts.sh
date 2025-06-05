#!/usr/bin/env bash

chaincodeList() {
  if [ "$#" -ne 2 ]; then
    echo "Expected 2 parameters for chaincode list, but got: $*"
    exit 1

  elif [ "$1" = "peer0.user.realestate.com" ]; then

    peerChaincodeListTls "cli.user.realestate.com" "peer0.user.realestate.com:7041" "$2" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" # Third argument is channel name

  elif
    [ "$1" = "peer1.user.realestate.com" ]
  then

    peerChaincodeListTls "cli.user.realestate.com" "peer1.user.realestate.com:7042" "$2" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" # Third argument is channel name

  elif
    [ "$1" = "peer0.bank.realestate.com" ]
  then

    peerChaincodeListTls "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "$2" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" # Third argument is channel name

  elif
    [ "$1" = "peer1.bank.realestate.com" ]
  then

    peerChaincodeListTls "cli.bank.realestate.com" "peer1.bank.realestate.com:7062" "$2" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" # Third argument is channel name

  elif
    [ "$1" = "peer0.landauthority.realestate.com" ]
  then

    peerChaincodeListTls "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "$2" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" # Third argument is channel name

  elif
    [ "$1" = "peer1.landauthority.realestate.com" ]
  then

    peerChaincodeListTls "cli.landauthority.realestate.com" "peer1.landauthority.realestate.com:7082" "$2" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" # Third argument is channel name

  elif
    [ "$1" = "peer0.court.realestate.com" ]
  then

    peerChaincodeListTls "cli.court.realestate.com" "peer0.court.realestate.com:7101" "$2" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" # Third argument is channel name

  elif
    [ "$1" = "peer1.court.realestate.com" ]
  then

    peerChaincodeListTls "cli.court.realestate.com" "peer1.court.realestate.com:7102" "$2" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" # Third argument is channel name

  elif
    [ "$1" = "peer0.inspector.realestate.com" ]
  then

    peerChaincodeListTls "cli.inspector.realestate.com" "peer0.inspector.realestate.com:7121" "$2" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" # Third argument is channel name

  elif
    [ "$1" = "peer1.inspector.realestate.com" ]
  then

    peerChaincodeListTls "cli.inspector.realestate.com" "peer1.inspector.realestate.com:7122" "$2" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" # Third argument is channel name

  else

    echo "Fail to call listChaincodes. No peer or channel found. Provided peer: $1, channel: $2"
    exit 1

  fi
}

# Function to perform chaincode invoke. Accepts 5 parameters:
#   1. comma-separated peers
#   2. channel name
#   3. chaincode name
#   4. chaincode command
#   5. transient data (optional)
chaincodeInvoke() {
  if [ "$#" -ne 4 ] && [ "$#" -ne 5 ]; then
    echo "Expected 4 or 5 parameters for chaincode list, but got: $*"
    echo "Usage: fablo chaincode invoke <peer_domains_comma_separated> <channel_name> <chaincode_name> <command> [transient]"
    exit 1
  fi
  cli=""
  peer_addresses=""

  peer_certs=""

  if [[ "$1" == *"peer0.user.realestate.com"* ]]; then
    cli="cli.user.realestate.com"
    peer_addresses="$peer_addresses,peer0.user.realestate.com:7041"

    peer_certs="$peer_certs,crypto/peers/peer0.user.realestate.com/tls/ca.crt"

  fi
  if [[ "$1" == *"peer1.user.realestate.com"* ]]; then
    cli="cli.user.realestate.com"
    peer_addresses="$peer_addresses,peer1.user.realestate.com:7042"

    peer_certs="$peer_certs,crypto/peers/peer1.user.realestate.com/tls/ca.crt"

  fi
  if [[ "$1" == *"peer0.bank.realestate.com"* ]]; then
    cli="cli.bank.realestate.com"
    peer_addresses="$peer_addresses,peer0.bank.realestate.com:7061"

    peer_certs="$peer_certs,crypto/peers/peer0.bank.realestate.com/tls/ca.crt"

  fi
  if [[ "$1" == *"peer1.bank.realestate.com"* ]]; then
    cli="cli.bank.realestate.com"
    peer_addresses="$peer_addresses,peer1.bank.realestate.com:7062"

    peer_certs="$peer_certs,crypto/peers/peer1.bank.realestate.com/tls/ca.crt"

  fi
  if [[ "$1" == *"peer0.landauthority.realestate.com"* ]]; then
    cli="cli.landauthority.realestate.com"
    peer_addresses="$peer_addresses,peer0.landauthority.realestate.com:7081"

    peer_certs="$peer_certs,crypto/peers/peer0.landauthority.realestate.com/tls/ca.crt"

  fi
  if [[ "$1" == *"peer1.landauthority.realestate.com"* ]]; then
    cli="cli.landauthority.realestate.com"
    peer_addresses="$peer_addresses,peer1.landauthority.realestate.com:7082"

    peer_certs="$peer_certs,crypto/peers/peer1.landauthority.realestate.com/tls/ca.crt"

  fi
  if [[ "$1" == *"peer0.court.realestate.com"* ]]; then
    cli="cli.court.realestate.com"
    peer_addresses="$peer_addresses,peer0.court.realestate.com:7101"

    peer_certs="$peer_certs,crypto/peers/peer0.court.realestate.com/tls/ca.crt"

  fi
  if [[ "$1" == *"peer1.court.realestate.com"* ]]; then
    cli="cli.court.realestate.com"
    peer_addresses="$peer_addresses,peer1.court.realestate.com:7102"

    peer_certs="$peer_certs,crypto/peers/peer1.court.realestate.com/tls/ca.crt"

  fi
  if [[ "$1" == *"peer0.inspector.realestate.com"* ]]; then
    cli="cli.inspector.realestate.com"
    peer_addresses="$peer_addresses,peer0.inspector.realestate.com:7121"

    peer_certs="$peer_certs,crypto/peers/peer0.inspector.realestate.com/tls/ca.crt"

  fi
  if [[ "$1" == *"peer1.inspector.realestate.com"* ]]; then
    cli="cli.inspector.realestate.com"
    peer_addresses="$peer_addresses,peer1.inspector.realestate.com:7122"

    peer_certs="$peer_certs,crypto/peers/peer1.inspector.realestate.com/tls/ca.crt"

  fi
  if [ -z "$peer_addresses" ]; then
    echo "Unknown peers: $1"
    exit 1
  fi

  if [ "$2" = "main-channel" ]; then
    ca_cert="crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
  fi

  if [ "$2" = "verification-channel" ]; then
    ca_cert="crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
  fi

  peerChaincodeInvokeTls "$cli" "${peer_addresses:1}" "$2" "$3" "$4" "$5" "${peer_certs:1}" "$ca_cert"

}
