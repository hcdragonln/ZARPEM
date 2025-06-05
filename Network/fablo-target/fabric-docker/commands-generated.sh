#!/usr/bin/env bash

generateArtifacts() {
  printHeadline "Generating basic configs" "U1F913"

  printItalics "Generating crypto material for Orderer1" "U1F512"
  certsGenerate "$FABLO_NETWORK_ROOT/fabric-config" "crypto-config-orderer1.yaml" "peerOrganizations/orderer1.realestate.com" "$FABLO_NETWORK_ROOT/fabric-config/crypto-config/"

  printItalics "Generating crypto material for user" "U1F512"
  certsGenerate "$FABLO_NETWORK_ROOT/fabric-config" "crypto-config-user.yaml" "peerOrganizations/user.realestate.com" "$FABLO_NETWORK_ROOT/fabric-config/crypto-config/"

  printItalics "Generating crypto material for bank" "U1F512"
  certsGenerate "$FABLO_NETWORK_ROOT/fabric-config" "crypto-config-bank.yaml" "peerOrganizations/bank.realestate.com" "$FABLO_NETWORK_ROOT/fabric-config/crypto-config/"

  printItalics "Generating crypto material for landauthority" "U1F512"
  certsGenerate "$FABLO_NETWORK_ROOT/fabric-config" "crypto-config-landauthority.yaml" "peerOrganizations/landauthority.realestate.com" "$FABLO_NETWORK_ROOT/fabric-config/crypto-config/"

  printItalics "Generating crypto material for court" "U1F512"
  certsGenerate "$FABLO_NETWORK_ROOT/fabric-config" "crypto-config-court.yaml" "peerOrganizations/court.realestate.com" "$FABLO_NETWORK_ROOT/fabric-config/crypto-config/"

  printItalics "Generating crypto material for inspector" "U1F512"
  certsGenerate "$FABLO_NETWORK_ROOT/fabric-config" "crypto-config-inspector.yaml" "peerOrganizations/inspector.realestate.com" "$FABLO_NETWORK_ROOT/fabric-config/crypto-config/"

  printItalics "Generating genesis block for group group1" "U1F3E0"
  genesisBlockCreate "$FABLO_NETWORK_ROOT/fabric-config" "$FABLO_NETWORK_ROOT/fabric-config/config" "Group1Genesis"

  # Create directories to avoid permission errors on linux
  mkdir -p "$FABLO_NETWORK_ROOT/fabric-config/chaincode-packages"
  mkdir -p "$FABLO_NETWORK_ROOT/fabric-config/config"
}

startNetwork() {
  printHeadline "Starting network" "U1F680"
  (cd "$FABLO_NETWORK_ROOT"/fabric-docker && docker compose up -d)
  sleep 4
}

generateChannelsArtifacts() {
  printHeadline "Generating config for 'main-channel'" "U1F913"
  createChannelTx "main-channel" "$FABLO_NETWORK_ROOT/fabric-config" "MainChannel" "$FABLO_NETWORK_ROOT/fabric-config/config"
  printHeadline "Generating config for 'verification-channel'" "U1F913"
  createChannelTx "verification-channel" "$FABLO_NETWORK_ROOT/fabric-config" "VerificationChannel" "$FABLO_NETWORK_ROOT/fabric-config/config"
}

installChannels() {
  printHeadline "Creating 'main-channel' on user/peer0" "U1F63B"
  docker exec -i cli.user.realestate.com bash -c "source scripts/channel_fns.sh; createChannelAndJoinTls 'main-channel' 'userMSP' 'peer0.user.realestate.com:7041' 'crypto/users/Admin@user.realestate.com/msp' 'crypto/users/Admin@user.realestate.com/tls' 'crypto-orderer/tlsca.orderer1.realestate.com-cert.pem' 'orderer0.group1.orderer1.realestate.com:7030';"

  printItalics "Joining 'main-channel' on user/peer1" "U1F638"
  docker exec -i cli.user.realestate.com bash -c "source scripts/channel_fns.sh; fetchChannelAndJoinTls 'main-channel' 'userMSP' 'peer1.user.realestate.com:7042' 'crypto/users/Admin@user.realestate.com/msp' 'crypto/users/Admin@user.realestate.com/tls' 'crypto-orderer/tlsca.orderer1.realestate.com-cert.pem' 'orderer0.group1.orderer1.realestate.com:7030';"
  printItalics "Joining 'main-channel' on bank/peer0" "U1F638"
  docker exec -i cli.bank.realestate.com bash -c "source scripts/channel_fns.sh; fetchChannelAndJoinTls 'main-channel' 'bankMSP' 'peer0.bank.realestate.com:7061' 'crypto/users/Admin@bank.realestate.com/msp' 'crypto/users/Admin@bank.realestate.com/tls' 'crypto-orderer/tlsca.orderer1.realestate.com-cert.pem' 'orderer0.group1.orderer1.realestate.com:7030';"
  printItalics "Joining 'main-channel' on bank/peer1" "U1F638"
  docker exec -i cli.bank.realestate.com bash -c "source scripts/channel_fns.sh; fetchChannelAndJoinTls 'main-channel' 'bankMSP' 'peer1.bank.realestate.com:7062' 'crypto/users/Admin@bank.realestate.com/msp' 'crypto/users/Admin@bank.realestate.com/tls' 'crypto-orderer/tlsca.orderer1.realestate.com-cert.pem' 'orderer0.group1.orderer1.realestate.com:7030';"
  printItalics "Joining 'main-channel' on landauthority/peer0" "U1F638"
  docker exec -i cli.landauthority.realestate.com bash -c "source scripts/channel_fns.sh; fetchChannelAndJoinTls 'main-channel' 'landauthorityMSP' 'peer0.landauthority.realestate.com:7081' 'crypto/users/Admin@landauthority.realestate.com/msp' 'crypto/users/Admin@landauthority.realestate.com/tls' 'crypto-orderer/tlsca.orderer1.realestate.com-cert.pem' 'orderer0.group1.orderer1.realestate.com:7030';"
  printItalics "Joining 'main-channel' on landauthority/peer1" "U1F638"
  docker exec -i cli.landauthority.realestate.com bash -c "source scripts/channel_fns.sh; fetchChannelAndJoinTls 'main-channel' 'landauthorityMSP' 'peer1.landauthority.realestate.com:7082' 'crypto/users/Admin@landauthority.realestate.com/msp' 'crypto/users/Admin@landauthority.realestate.com/tls' 'crypto-orderer/tlsca.orderer1.realestate.com-cert.pem' 'orderer0.group1.orderer1.realestate.com:7030';"
  printItalics "Joining 'main-channel' on court/peer0" "U1F638"
  docker exec -i cli.court.realestate.com bash -c "source scripts/channel_fns.sh; fetchChannelAndJoinTls 'main-channel' 'courtMSP' 'peer0.court.realestate.com:7101' 'crypto/users/Admin@court.realestate.com/msp' 'crypto/users/Admin@court.realestate.com/tls' 'crypto-orderer/tlsca.orderer1.realestate.com-cert.pem' 'orderer0.group1.orderer1.realestate.com:7030';"
  printItalics "Joining 'main-channel' on court/peer1" "U1F638"
  docker exec -i cli.court.realestate.com bash -c "source scripts/channel_fns.sh; fetchChannelAndJoinTls 'main-channel' 'courtMSP' 'peer1.court.realestate.com:7102' 'crypto/users/Admin@court.realestate.com/msp' 'crypto/users/Admin@court.realestate.com/tls' 'crypto-orderer/tlsca.orderer1.realestate.com-cert.pem' 'orderer0.group1.orderer1.realestate.com:7030';"
  printItalics "Joining 'main-channel' on inspector/peer0" "U1F638"
  docker exec -i cli.inspector.realestate.com bash -c "source scripts/channel_fns.sh; fetchChannelAndJoinTls 'main-channel' 'inspectorMSP' 'peer0.inspector.realestate.com:7121' 'crypto/users/Admin@inspector.realestate.com/msp' 'crypto/users/Admin@inspector.realestate.com/tls' 'crypto-orderer/tlsca.orderer1.realestate.com-cert.pem' 'orderer0.group1.orderer1.realestate.com:7030';"
  printItalics "Joining 'main-channel' on inspector/peer1" "U1F638"
  docker exec -i cli.inspector.realestate.com bash -c "source scripts/channel_fns.sh; fetchChannelAndJoinTls 'main-channel' 'inspectorMSP' 'peer1.inspector.realestate.com:7122' 'crypto/users/Admin@inspector.realestate.com/msp' 'crypto/users/Admin@inspector.realestate.com/tls' 'crypto-orderer/tlsca.orderer1.realestate.com-cert.pem' 'orderer0.group1.orderer1.realestate.com:7030';"
  printHeadline "Creating 'verification-channel' on bank/peer0" "U1F63B"
  docker exec -i cli.bank.realestate.com bash -c "source scripts/channel_fns.sh; createChannelAndJoinTls 'verification-channel' 'bankMSP' 'peer0.bank.realestate.com:7061' 'crypto/users/Admin@bank.realestate.com/msp' 'crypto/users/Admin@bank.realestate.com/tls' 'crypto-orderer/tlsca.orderer1.realestate.com-cert.pem' 'orderer0.group1.orderer1.realestate.com:7030';"

  printItalics "Joining 'verification-channel' on landauthority/peer0" "U1F638"
  docker exec -i cli.landauthority.realestate.com bash -c "source scripts/channel_fns.sh; fetchChannelAndJoinTls 'verification-channel' 'landauthorityMSP' 'peer0.landauthority.realestate.com:7081' 'crypto/users/Admin@landauthority.realestate.com/msp' 'crypto/users/Admin@landauthority.realestate.com/tls' 'crypto-orderer/tlsca.orderer1.realestate.com-cert.pem' 'orderer0.group1.orderer1.realestate.com:7030';"
  printItalics "Joining 'verification-channel' on court/peer0" "U1F638"
  docker exec -i cli.court.realestate.com bash -c "source scripts/channel_fns.sh; fetchChannelAndJoinTls 'verification-channel' 'courtMSP' 'peer0.court.realestate.com:7101' 'crypto/users/Admin@court.realestate.com/msp' 'crypto/users/Admin@court.realestate.com/tls' 'crypto-orderer/tlsca.orderer1.realestate.com-cert.pem' 'orderer0.group1.orderer1.realestate.com:7030';"
}

installChaincodes() {
  if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/auth-chaincode")" ]; then
    local version="0.0.3"
    printHeadline "Packaging chaincode 'auth-cc'" "U1F60E"
    chaincodeBuild "auth-cc" "node" "$CHAINCODES_BASE_DIR/./chaincodes/auth-chaincode" "16"
    chaincodePackage "cli.user.realestate.com" "peer0.user.realestate.com:7041" "auth-cc" "$version" "node" printHeadline "Installing 'auth-cc' for user" "U1F60E"
    chaincodeInstall "cli.user.realestate.com" "peer0.user.realestate.com:7041" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeInstall "cli.user.realestate.com" "peer1.user.realestate.com:7042" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeApprove "cli.user.realestate.com" "peer0.user.realestate.com:7041" "main-channel" "auth-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
    printHeadline "Installing 'auth-cc' for bank" "U1F60E"
    chaincodeInstall "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeInstall "cli.bank.realestate.com" "peer1.bank.realestate.com:7062" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeApprove "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "main-channel" "auth-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
    printHeadline "Installing 'auth-cc' for landauthority" "U1F60E"
    chaincodeInstall "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeInstall "cli.landauthority.realestate.com" "peer1.landauthority.realestate.com:7082" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeApprove "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "main-channel" "auth-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
    printHeadline "Installing 'auth-cc' for court" "U1F60E"
    chaincodeInstall "cli.court.realestate.com" "peer0.court.realestate.com:7101" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeInstall "cli.court.realestate.com" "peer1.court.realestate.com:7102" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeApprove "cli.court.realestate.com" "peer0.court.realestate.com:7101" "main-channel" "auth-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
    printHeadline "Installing 'auth-cc' for inspector" "U1F60E"
    chaincodeInstall "cli.inspector.realestate.com" "peer0.inspector.realestate.com:7121" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeInstall "cli.inspector.realestate.com" "peer1.inspector.realestate.com:7122" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeApprove "cli.inspector.realestate.com" "peer0.inspector.realestate.com:7121" "main-channel" "auth-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
    printItalics "Committing chaincode 'auth-cc' on channel 'main-channel' as 'user'" "U1F618"
    chaincodeCommit "cli.user.realestate.com" "peer0.user.realestate.com:7041" "main-channel" "auth-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" "peer0.user.realestate.com:7041,peer0.bank.realestate.com:7061,peer0.landauthority.realestate.com:7081,peer0.court.realestate.com:7101,peer0.inspector.realestate.com:7121" "crypto-peer/peer0.user.realestate.com/tls/ca.crt,crypto-peer/peer0.bank.realestate.com/tls/ca.crt,crypto-peer/peer0.landauthority.realestate.com/tls/ca.crt,crypto-peer/peer0.court.realestate.com/tls/ca.crt,crypto-peer/peer0.inspector.realestate.com/tls/ca.crt" ""
  else
    echo "Warning! Skipping chaincode 'auth-cc' installation. Chaincode directory is empty."
    echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/auth-chaincode'"
  fi
  if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/asset-chaincode")" ]; then
    local version="0.0.3"
    printHeadline "Packaging chaincode 'Asset-cc'" "U1F60E"
    chaincodeBuild "Asset-cc" "node" "$CHAINCODES_BASE_DIR/./chaincodes/asset-chaincode" "16"
    chaincodePackage "cli.user.realestate.com" "peer0.user.realestate.com:7041" "Asset-cc" "$version" "node" printHeadline "Installing 'Asset-cc' for user" "U1F60E"
    chaincodeInstall "cli.user.realestate.com" "peer0.user.realestate.com:7041" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeInstall "cli.user.realestate.com" "peer1.user.realestate.com:7042" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeApprove "cli.user.realestate.com" "peer0.user.realestate.com:7041" "main-channel" "Asset-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
    printHeadline "Installing 'Asset-cc' for bank" "U1F60E"
    chaincodeInstall "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeInstall "cli.bank.realestate.com" "peer1.bank.realestate.com:7062" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeApprove "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "main-channel" "Asset-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
    printHeadline "Installing 'Asset-cc' for landauthority" "U1F60E"
    chaincodeInstall "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeInstall "cli.landauthority.realestate.com" "peer1.landauthority.realestate.com:7082" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeApprove "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "main-channel" "Asset-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
    printHeadline "Installing 'Asset-cc' for court" "U1F60E"
    chaincodeInstall "cli.court.realestate.com" "peer0.court.realestate.com:7101" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeInstall "cli.court.realestate.com" "peer1.court.realestate.com:7102" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeApprove "cli.court.realestate.com" "peer0.court.realestate.com:7101" "main-channel" "Asset-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
    printHeadline "Installing 'Asset-cc' for inspector" "U1F60E"
    chaincodeInstall "cli.inspector.realestate.com" "peer0.inspector.realestate.com:7121" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeInstall "cli.inspector.realestate.com" "peer1.inspector.realestate.com:7122" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeApprove "cli.inspector.realestate.com" "peer0.inspector.realestate.com:7121" "main-channel" "Asset-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
    printItalics "Committing chaincode 'Asset-cc' on channel 'main-channel' as 'user'" "U1F618"
    chaincodeCommit "cli.user.realestate.com" "peer0.user.realestate.com:7041" "main-channel" "Asset-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" "peer0.user.realestate.com:7041,peer0.bank.realestate.com:7061,peer0.landauthority.realestate.com:7081,peer0.court.realestate.com:7101,peer0.inspector.realestate.com:7121" "crypto-peer/peer0.user.realestate.com/tls/ca.crt,crypto-peer/peer0.bank.realestate.com/tls/ca.crt,crypto-peer/peer0.landauthority.realestate.com/tls/ca.crt,crypto-peer/peer0.court.realestate.com/tls/ca.crt,crypto-peer/peer0.inspector.realestate.com/tls/ca.crt" ""
  else
    echo "Warning! Skipping chaincode 'Asset-cc' installation. Chaincode directory is empty."
    echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/asset-chaincode'"
  fi
  if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/zone-chaincode")" ]; then
    local version="0.0.3"
    printHeadline "Packaging chaincode 'zone-cc'" "U1F60E"
    chaincodeBuild "zone-cc" "node" "$CHAINCODES_BASE_DIR/./chaincodes/zone-chaincode" "16"
    chaincodePackage "cli.user.realestate.com" "peer0.user.realestate.com:7041" "zone-cc" "$version" "node" printHeadline "Installing 'zone-cc' for user" "U1F60E"
    chaincodeInstall "cli.user.realestate.com" "peer0.user.realestate.com:7041" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeInstall "cli.user.realestate.com" "peer1.user.realestate.com:7042" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeApprove "cli.user.realestate.com" "peer0.user.realestate.com:7041" "main-channel" "zone-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
    printHeadline "Installing 'zone-cc' for bank" "U1F60E"
    chaincodeInstall "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeInstall "cli.bank.realestate.com" "peer1.bank.realestate.com:7062" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeApprove "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "main-channel" "zone-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
    printHeadline "Installing 'zone-cc' for landauthority" "U1F60E"
    chaincodeInstall "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeInstall "cli.landauthority.realestate.com" "peer1.landauthority.realestate.com:7082" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeApprove "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "main-channel" "zone-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
    printHeadline "Installing 'zone-cc' for court" "U1F60E"
    chaincodeInstall "cli.court.realestate.com" "peer0.court.realestate.com:7101" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeInstall "cli.court.realestate.com" "peer1.court.realestate.com:7102" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeApprove "cli.court.realestate.com" "peer0.court.realestate.com:7101" "main-channel" "zone-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
    printHeadline "Installing 'zone-cc' for inspector" "U1F60E"
    chaincodeInstall "cli.inspector.realestate.com" "peer0.inspector.realestate.com:7121" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeInstall "cli.inspector.realestate.com" "peer1.inspector.realestate.com:7122" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeApprove "cli.inspector.realestate.com" "peer0.inspector.realestate.com:7121" "main-channel" "zone-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
    printItalics "Committing chaincode 'zone-cc' on channel 'main-channel' as 'user'" "U1F618"
    chaincodeCommit "cli.user.realestate.com" "peer0.user.realestate.com:7041" "main-channel" "zone-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" "peer0.user.realestate.com:7041,peer0.bank.realestate.com:7061,peer0.landauthority.realestate.com:7081,peer0.court.realestate.com:7101,peer0.inspector.realestate.com:7121" "crypto-peer/peer0.user.realestate.com/tls/ca.crt,crypto-peer/peer0.bank.realestate.com/tls/ca.crt,crypto-peer/peer0.landauthority.realestate.com/tls/ca.crt,crypto-peer/peer0.court.realestate.com/tls/ca.crt,crypto-peer/peer0.inspector.realestate.com/tls/ca.crt" ""
  else
    echo "Warning! Skipping chaincode 'zone-cc' installation. Chaincode directory is empty."
    echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/zone-chaincode'"
  fi
  if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/verification-chaincode")" ]; then
    local version="0.0.3"
    printHeadline "Packaging chaincode 'verification-cc'" "U1F60E"
    chaincodeBuild "verification-cc" "node" "$CHAINCODES_BASE_DIR/./chaincodes/verification-chaincode" "16"
    chaincodePackage "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "verification-cc" "$version" "node" printHeadline "Installing 'verification-cc' for bank" "U1F60E"
    chaincodeInstall "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "verification-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeApprove "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "verification-channel" "verification-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
    printHeadline "Installing 'verification-cc' for landauthority" "U1F60E"
    chaincodeInstall "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "verification-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeApprove "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "verification-channel" "verification-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
    printHeadline "Installing 'verification-cc' for court" "U1F60E"
    chaincodeInstall "cli.court.realestate.com" "peer0.court.realestate.com:7101" "verification-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
    chaincodeApprove "cli.court.realestate.com" "peer0.court.realestate.com:7101" "verification-channel" "verification-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
    printItalics "Committing chaincode 'verification-cc' on channel 'verification-channel' as 'bank'" "U1F618"
    chaincodeCommit "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "verification-channel" "verification-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" "peer0.bank.realestate.com:7061,peer0.landauthority.realestate.com:7081,peer0.court.realestate.com:7101" "crypto-peer/peer0.bank.realestate.com/tls/ca.crt,crypto-peer/peer0.landauthority.realestate.com/tls/ca.crt,crypto-peer/peer0.court.realestate.com/tls/ca.crt" ""
  else
    echo "Warning! Skipping chaincode 'verification-cc' installation. Chaincode directory is empty."
    echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/verification-chaincode'"
  fi

}

installChaincode() {
  local chaincodeName="$1"
  if [ -z "$chaincodeName" ]; then
    echo "Error: chaincode name is not provided"
    exit 1
  fi

  local version="$2"
  if [ -z "$version" ]; then
    echo "Error: chaincode version is not provided"
    exit 1
  fi

  if [ "$chaincodeName" = "auth-cc" ]; then
    if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/auth-chaincode")" ]; then
      printHeadline "Packaging chaincode 'auth-cc'" "U1F60E"
      chaincodeBuild "auth-cc" "node" "$CHAINCODES_BASE_DIR/./chaincodes/auth-chaincode" "16"
      chaincodePackage "cli.user.realestate.com" "peer0.user.realestate.com:7041" "auth-cc" "$version" "node" printHeadline "Installing 'auth-cc' for user" "U1F60E"
      chaincodeInstall "cli.user.realestate.com" "peer0.user.realestate.com:7041" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.user.realestate.com" "peer1.user.realestate.com:7042" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.user.realestate.com" "peer0.user.realestate.com:7041" "main-channel" "auth-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'auth-cc' for bank" "U1F60E"
      chaincodeInstall "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.bank.realestate.com" "peer1.bank.realestate.com:7062" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "main-channel" "auth-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'auth-cc' for landauthority" "U1F60E"
      chaincodeInstall "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.landauthority.realestate.com" "peer1.landauthority.realestate.com:7082" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "main-channel" "auth-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'auth-cc' for court" "U1F60E"
      chaincodeInstall "cli.court.realestate.com" "peer0.court.realestate.com:7101" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.court.realestate.com" "peer1.court.realestate.com:7102" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.court.realestate.com" "peer0.court.realestate.com:7101" "main-channel" "auth-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'auth-cc' for inspector" "U1F60E"
      chaincodeInstall "cli.inspector.realestate.com" "peer0.inspector.realestate.com:7121" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.inspector.realestate.com" "peer1.inspector.realestate.com:7122" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.inspector.realestate.com" "peer0.inspector.realestate.com:7121" "main-channel" "auth-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printItalics "Committing chaincode 'auth-cc' on channel 'main-channel' as 'user'" "U1F618"
      chaincodeCommit "cli.user.realestate.com" "peer0.user.realestate.com:7041" "main-channel" "auth-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" "peer0.user.realestate.com:7041,peer0.bank.realestate.com:7061,peer0.landauthority.realestate.com:7081,peer0.court.realestate.com:7101,peer0.inspector.realestate.com:7121" "crypto-peer/peer0.user.realestate.com/tls/ca.crt,crypto-peer/peer0.bank.realestate.com/tls/ca.crt,crypto-peer/peer0.landauthority.realestate.com/tls/ca.crt,crypto-peer/peer0.court.realestate.com/tls/ca.crt,crypto-peer/peer0.inspector.realestate.com/tls/ca.crt" ""

    else
      echo "Warning! Skipping chaincode 'auth-cc' install. Chaincode directory is empty."
      echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/auth-chaincode'"
    fi
  fi
  if [ "$chaincodeName" = "Asset-cc" ]; then
    if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/asset-chaincode")" ]; then
      printHeadline "Packaging chaincode 'Asset-cc'" "U1F60E"
      chaincodeBuild "Asset-cc" "node" "$CHAINCODES_BASE_DIR/./chaincodes/asset-chaincode" "16"
      chaincodePackage "cli.user.realestate.com" "peer0.user.realestate.com:7041" "Asset-cc" "$version" "node" printHeadline "Installing 'Asset-cc' for user" "U1F60E"
      chaincodeInstall "cli.user.realestate.com" "peer0.user.realestate.com:7041" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.user.realestate.com" "peer1.user.realestate.com:7042" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.user.realestate.com" "peer0.user.realestate.com:7041" "main-channel" "Asset-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'Asset-cc' for bank" "U1F60E"
      chaincodeInstall "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.bank.realestate.com" "peer1.bank.realestate.com:7062" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "main-channel" "Asset-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'Asset-cc' for landauthority" "U1F60E"
      chaincodeInstall "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.landauthority.realestate.com" "peer1.landauthority.realestate.com:7082" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "main-channel" "Asset-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'Asset-cc' for court" "U1F60E"
      chaincodeInstall "cli.court.realestate.com" "peer0.court.realestate.com:7101" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.court.realestate.com" "peer1.court.realestate.com:7102" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.court.realestate.com" "peer0.court.realestate.com:7101" "main-channel" "Asset-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'Asset-cc' for inspector" "U1F60E"
      chaincodeInstall "cli.inspector.realestate.com" "peer0.inspector.realestate.com:7121" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.inspector.realestate.com" "peer1.inspector.realestate.com:7122" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.inspector.realestate.com" "peer0.inspector.realestate.com:7121" "main-channel" "Asset-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printItalics "Committing chaincode 'Asset-cc' on channel 'main-channel' as 'user'" "U1F618"
      chaincodeCommit "cli.user.realestate.com" "peer0.user.realestate.com:7041" "main-channel" "Asset-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" "peer0.user.realestate.com:7041,peer0.bank.realestate.com:7061,peer0.landauthority.realestate.com:7081,peer0.court.realestate.com:7101,peer0.inspector.realestate.com:7121" "crypto-peer/peer0.user.realestate.com/tls/ca.crt,crypto-peer/peer0.bank.realestate.com/tls/ca.crt,crypto-peer/peer0.landauthority.realestate.com/tls/ca.crt,crypto-peer/peer0.court.realestate.com/tls/ca.crt,crypto-peer/peer0.inspector.realestate.com/tls/ca.crt" ""

    else
      echo "Warning! Skipping chaincode 'Asset-cc' install. Chaincode directory is empty."
      echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/asset-chaincode'"
    fi
  fi
  if [ "$chaincodeName" = "zone-cc" ]; then
    if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/zone-chaincode")" ]; then
      printHeadline "Packaging chaincode 'zone-cc'" "U1F60E"
      chaincodeBuild "zone-cc" "node" "$CHAINCODES_BASE_DIR/./chaincodes/zone-chaincode" "16"
      chaincodePackage "cli.user.realestate.com" "peer0.user.realestate.com:7041" "zone-cc" "$version" "node" printHeadline "Installing 'zone-cc' for user" "U1F60E"
      chaincodeInstall "cli.user.realestate.com" "peer0.user.realestate.com:7041" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.user.realestate.com" "peer1.user.realestate.com:7042" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.user.realestate.com" "peer0.user.realestate.com:7041" "main-channel" "zone-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'zone-cc' for bank" "U1F60E"
      chaincodeInstall "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.bank.realestate.com" "peer1.bank.realestate.com:7062" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "main-channel" "zone-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'zone-cc' for landauthority" "U1F60E"
      chaincodeInstall "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.landauthority.realestate.com" "peer1.landauthority.realestate.com:7082" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "main-channel" "zone-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'zone-cc' for court" "U1F60E"
      chaincodeInstall "cli.court.realestate.com" "peer0.court.realestate.com:7101" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.court.realestate.com" "peer1.court.realestate.com:7102" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.court.realestate.com" "peer0.court.realestate.com:7101" "main-channel" "zone-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'zone-cc' for inspector" "U1F60E"
      chaincodeInstall "cli.inspector.realestate.com" "peer0.inspector.realestate.com:7121" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.inspector.realestate.com" "peer1.inspector.realestate.com:7122" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.inspector.realestate.com" "peer0.inspector.realestate.com:7121" "main-channel" "zone-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printItalics "Committing chaincode 'zone-cc' on channel 'main-channel' as 'user'" "U1F618"
      chaincodeCommit "cli.user.realestate.com" "peer0.user.realestate.com:7041" "main-channel" "zone-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" "peer0.user.realestate.com:7041,peer0.bank.realestate.com:7061,peer0.landauthority.realestate.com:7081,peer0.court.realestate.com:7101,peer0.inspector.realestate.com:7121" "crypto-peer/peer0.user.realestate.com/tls/ca.crt,crypto-peer/peer0.bank.realestate.com/tls/ca.crt,crypto-peer/peer0.landauthority.realestate.com/tls/ca.crt,crypto-peer/peer0.court.realestate.com/tls/ca.crt,crypto-peer/peer0.inspector.realestate.com/tls/ca.crt" ""

    else
      echo "Warning! Skipping chaincode 'zone-cc' install. Chaincode directory is empty."
      echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/zone-chaincode'"
    fi
  fi
  if [ "$chaincodeName" = "verification-cc" ]; then
    if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/verification-chaincode")" ]; then
      printHeadline "Packaging chaincode 'verification-cc'" "U1F60E"
      chaincodeBuild "verification-cc" "node" "$CHAINCODES_BASE_DIR/./chaincodes/verification-chaincode" "16"
      chaincodePackage "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "verification-cc" "$version" "node" printHeadline "Installing 'verification-cc' for bank" "U1F60E"
      chaincodeInstall "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "verification-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "verification-channel" "verification-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'verification-cc' for landauthority" "U1F60E"
      chaincodeInstall "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "verification-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "verification-channel" "verification-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'verification-cc' for court" "U1F60E"
      chaincodeInstall "cli.court.realestate.com" "peer0.court.realestate.com:7101" "verification-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.court.realestate.com" "peer0.court.realestate.com:7101" "verification-channel" "verification-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printItalics "Committing chaincode 'verification-cc' on channel 'verification-channel' as 'bank'" "U1F618"
      chaincodeCommit "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "verification-channel" "verification-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" "peer0.bank.realestate.com:7061,peer0.landauthority.realestate.com:7081,peer0.court.realestate.com:7101" "crypto-peer/peer0.bank.realestate.com/tls/ca.crt,crypto-peer/peer0.landauthority.realestate.com/tls/ca.crt,crypto-peer/peer0.court.realestate.com/tls/ca.crt" ""

    else
      echo "Warning! Skipping chaincode 'verification-cc' install. Chaincode directory is empty."
      echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/verification-chaincode'"
    fi
  fi
}

runDevModeChaincode() {
  local chaincodeName=$1
  if [ -z "$chaincodeName" ]; then
    echo "Error: chaincode name is not provided"
    exit 1
  fi

  if [ "$chaincodeName" = "auth-cc" ]; then
    local version="0.0.3"
    printHeadline "Approving 'auth-cc' for user (dev mode)" "U1F60E"
    chaincodeApprove "cli.user.realestate.com" "peer0.user.realestate.com:7041" "main-channel" "auth-cc" "0.0.3" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "" ""
    printHeadline "Approving 'auth-cc' for bank (dev mode)" "U1F60E"
    chaincodeApprove "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "main-channel" "auth-cc" "0.0.3" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "" ""
    printHeadline "Approving 'auth-cc' for landauthority (dev mode)" "U1F60E"
    chaincodeApprove "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "main-channel" "auth-cc" "0.0.3" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "" ""
    printHeadline "Approving 'auth-cc' for court (dev mode)" "U1F60E"
    chaincodeApprove "cli.court.realestate.com" "peer0.court.realestate.com:7101" "main-channel" "auth-cc" "0.0.3" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "" ""
    printHeadline "Approving 'auth-cc' for inspector (dev mode)" "U1F60E"
    chaincodeApprove "cli.inspector.realestate.com" "peer0.inspector.realestate.com:7121" "main-channel" "auth-cc" "0.0.3" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "" ""
    printItalics "Committing chaincode 'auth-cc' on channel 'main-channel' as 'user' (dev mode)" "U1F618"
    chaincodeCommit "cli.user.realestate.com" "peer0.user.realestate.com:7041" "main-channel" "auth-cc" "0.0.3" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "" "peer0.user.realestate.com:7041,peer0.bank.realestate.com:7061,peer0.landauthority.realestate.com:7081,peer0.court.realestate.com:7101,peer0.inspector.realestate.com:7121" "" ""

  fi
  if [ "$chaincodeName" = "Asset-cc" ]; then
    local version="0.0.3"
    printHeadline "Approving 'Asset-cc' for user (dev mode)" "U1F60E"
    chaincodeApprove "cli.user.realestate.com" "peer0.user.realestate.com:7041" "main-channel" "Asset-cc" "0.0.3" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "" ""
    printHeadline "Approving 'Asset-cc' for bank (dev mode)" "U1F60E"
    chaincodeApprove "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "main-channel" "Asset-cc" "0.0.3" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "" ""
    printHeadline "Approving 'Asset-cc' for landauthority (dev mode)" "U1F60E"
    chaincodeApprove "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "main-channel" "Asset-cc" "0.0.3" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "" ""
    printHeadline "Approving 'Asset-cc' for court (dev mode)" "U1F60E"
    chaincodeApprove "cli.court.realestate.com" "peer0.court.realestate.com:7101" "main-channel" "Asset-cc" "0.0.3" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "" ""
    printHeadline "Approving 'Asset-cc' for inspector (dev mode)" "U1F60E"
    chaincodeApprove "cli.inspector.realestate.com" "peer0.inspector.realestate.com:7121" "main-channel" "Asset-cc" "0.0.3" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "" ""
    printItalics "Committing chaincode 'Asset-cc' on channel 'main-channel' as 'user' (dev mode)" "U1F618"
    chaincodeCommit "cli.user.realestate.com" "peer0.user.realestate.com:7041" "main-channel" "Asset-cc" "0.0.3" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "" "peer0.user.realestate.com:7041,peer0.bank.realestate.com:7061,peer0.landauthority.realestate.com:7081,peer0.court.realestate.com:7101,peer0.inspector.realestate.com:7121" "" ""

  fi
  if [ "$chaincodeName" = "zone-cc" ]; then
    local version="0.0.3"
    printHeadline "Approving 'zone-cc' for user (dev mode)" "U1F60E"
    chaincodeApprove "cli.user.realestate.com" "peer0.user.realestate.com:7041" "main-channel" "zone-cc" "0.0.3" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "" ""
    printHeadline "Approving 'zone-cc' for bank (dev mode)" "U1F60E"
    chaincodeApprove "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "main-channel" "zone-cc" "0.0.3" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "" ""
    printHeadline "Approving 'zone-cc' for landauthority (dev mode)" "U1F60E"
    chaincodeApprove "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "main-channel" "zone-cc" "0.0.3" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "" ""
    printHeadline "Approving 'zone-cc' for court (dev mode)" "U1F60E"
    chaincodeApprove "cli.court.realestate.com" "peer0.court.realestate.com:7101" "main-channel" "zone-cc" "0.0.3" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "" ""
    printHeadline "Approving 'zone-cc' for inspector (dev mode)" "U1F60E"
    chaincodeApprove "cli.inspector.realestate.com" "peer0.inspector.realestate.com:7121" "main-channel" "zone-cc" "0.0.3" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "" ""
    printItalics "Committing chaincode 'zone-cc' on channel 'main-channel' as 'user' (dev mode)" "U1F618"
    chaincodeCommit "cli.user.realestate.com" "peer0.user.realestate.com:7041" "main-channel" "zone-cc" "0.0.3" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "" "peer0.user.realestate.com:7041,peer0.bank.realestate.com:7061,peer0.landauthority.realestate.com:7081,peer0.court.realestate.com:7101,peer0.inspector.realestate.com:7121" "" ""

  fi
  if [ "$chaincodeName" = "verification-cc" ]; then
    local version="0.0.3"
    printHeadline "Approving 'verification-cc' for bank (dev mode)" "U1F60E"
    chaincodeApprove "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "verification-channel" "verification-cc" "0.0.3" "orderer0.group1.orderer1.realestate.com:7030" "OR('landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member')" "false" "" ""
    printHeadline "Approving 'verification-cc' for landauthority (dev mode)" "U1F60E"
    chaincodeApprove "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "verification-channel" "verification-cc" "0.0.3" "orderer0.group1.orderer1.realestate.com:7030" "OR('landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member')" "false" "" ""
    printHeadline "Approving 'verification-cc' for court (dev mode)" "U1F60E"
    chaincodeApprove "cli.court.realestate.com" "peer0.court.realestate.com:7101" "verification-channel" "verification-cc" "0.0.3" "orderer0.group1.orderer1.realestate.com:7030" "OR('landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member')" "false" "" ""
    printItalics "Committing chaincode 'verification-cc' on channel 'verification-channel' as 'bank' (dev mode)" "U1F618"
    chaincodeCommit "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "verification-channel" "verification-cc" "0.0.3" "orderer0.group1.orderer1.realestate.com:7030" "OR('landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member')" "false" "" "peer0.bank.realestate.com:7061,peer0.landauthority.realestate.com:7081,peer0.court.realestate.com:7101" "" ""

  fi
}

upgradeChaincode() {
  local chaincodeName="$1"
  if [ -z "$chaincodeName" ]; then
    echo "Error: chaincode name is not provided"
    exit 1
  fi

  local version="$2"
  if [ -z "$version" ]; then
    echo "Error: chaincode version is not provided"
    exit 1
  fi

  if [ "$chaincodeName" = "auth-cc" ]; then
    if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/auth-chaincode")" ]; then
      printHeadline "Packaging chaincode 'auth-cc'" "U1F60E"
      chaincodeBuild "auth-cc" "node" "$CHAINCODES_BASE_DIR/./chaincodes/auth-chaincode" "16"
      chaincodePackage "cli.user.realestate.com" "peer0.user.realestate.com:7041" "auth-cc" "$version" "node" printHeadline "Installing 'auth-cc' for user" "U1F60E"
      chaincodeInstall "cli.user.realestate.com" "peer0.user.realestate.com:7041" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.user.realestate.com" "peer1.user.realestate.com:7042" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.user.realestate.com" "peer0.user.realestate.com:7041" "main-channel" "auth-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'auth-cc' for bank" "U1F60E"
      chaincodeInstall "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.bank.realestate.com" "peer1.bank.realestate.com:7062" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "main-channel" "auth-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'auth-cc' for landauthority" "U1F60E"
      chaincodeInstall "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.landauthority.realestate.com" "peer1.landauthority.realestate.com:7082" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "main-channel" "auth-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'auth-cc' for court" "U1F60E"
      chaincodeInstall "cli.court.realestate.com" "peer0.court.realestate.com:7101" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.court.realestate.com" "peer1.court.realestate.com:7102" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.court.realestate.com" "peer0.court.realestate.com:7101" "main-channel" "auth-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'auth-cc' for inspector" "U1F60E"
      chaincodeInstall "cli.inspector.realestate.com" "peer0.inspector.realestate.com:7121" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.inspector.realestate.com" "peer1.inspector.realestate.com:7122" "auth-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.inspector.realestate.com" "peer0.inspector.realestate.com:7121" "main-channel" "auth-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printItalics "Committing chaincode 'auth-cc' on channel 'main-channel' as 'user'" "U1F618"
      chaincodeCommit "cli.user.realestate.com" "peer0.user.realestate.com:7041" "main-channel" "auth-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" "peer0.user.realestate.com:7041,peer0.bank.realestate.com:7061,peer0.landauthority.realestate.com:7081,peer0.court.realestate.com:7101,peer0.inspector.realestate.com:7121" "crypto-peer/peer0.user.realestate.com/tls/ca.crt,crypto-peer/peer0.bank.realestate.com/tls/ca.crt,crypto-peer/peer0.landauthority.realestate.com/tls/ca.crt,crypto-peer/peer0.court.realestate.com/tls/ca.crt,crypto-peer/peer0.inspector.realestate.com/tls/ca.crt" ""

    else
      echo "Warning! Skipping chaincode 'auth-cc' upgrade. Chaincode directory is empty."
      echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/auth-chaincode'"
    fi
  fi
  if [ "$chaincodeName" = "Asset-cc" ]; then
    if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/asset-chaincode")" ]; then
      printHeadline "Packaging chaincode 'Asset-cc'" "U1F60E"
      chaincodeBuild "Asset-cc" "node" "$CHAINCODES_BASE_DIR/./chaincodes/asset-chaincode" "16"
      chaincodePackage "cli.user.realestate.com" "peer0.user.realestate.com:7041" "Asset-cc" "$version" "node" printHeadline "Installing 'Asset-cc' for user" "U1F60E"
      chaincodeInstall "cli.user.realestate.com" "peer0.user.realestate.com:7041" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.user.realestate.com" "peer1.user.realestate.com:7042" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.user.realestate.com" "peer0.user.realestate.com:7041" "main-channel" "Asset-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'Asset-cc' for bank" "U1F60E"
      chaincodeInstall "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.bank.realestate.com" "peer1.bank.realestate.com:7062" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "main-channel" "Asset-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'Asset-cc' for landauthority" "U1F60E"
      chaincodeInstall "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.landauthority.realestate.com" "peer1.landauthority.realestate.com:7082" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "main-channel" "Asset-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'Asset-cc' for court" "U1F60E"
      chaincodeInstall "cli.court.realestate.com" "peer0.court.realestate.com:7101" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.court.realestate.com" "peer1.court.realestate.com:7102" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.court.realestate.com" "peer0.court.realestate.com:7101" "main-channel" "Asset-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'Asset-cc' for inspector" "U1F60E"
      chaincodeInstall "cli.inspector.realestate.com" "peer0.inspector.realestate.com:7121" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.inspector.realestate.com" "peer1.inspector.realestate.com:7122" "Asset-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.inspector.realestate.com" "peer0.inspector.realestate.com:7121" "main-channel" "Asset-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printItalics "Committing chaincode 'Asset-cc' on channel 'main-channel' as 'user'" "U1F618"
      chaincodeCommit "cli.user.realestate.com" "peer0.user.realestate.com:7041" "main-channel" "Asset-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" "peer0.user.realestate.com:7041,peer0.bank.realestate.com:7061,peer0.landauthority.realestate.com:7081,peer0.court.realestate.com:7101,peer0.inspector.realestate.com:7121" "crypto-peer/peer0.user.realestate.com/tls/ca.crt,crypto-peer/peer0.bank.realestate.com/tls/ca.crt,crypto-peer/peer0.landauthority.realestate.com/tls/ca.crt,crypto-peer/peer0.court.realestate.com/tls/ca.crt,crypto-peer/peer0.inspector.realestate.com/tls/ca.crt" ""

    else
      echo "Warning! Skipping chaincode 'Asset-cc' upgrade. Chaincode directory is empty."
      echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/asset-chaincode'"
    fi
  fi
  if [ "$chaincodeName" = "zone-cc" ]; then
    if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/zone-chaincode")" ]; then
      printHeadline "Packaging chaincode 'zone-cc'" "U1F60E"
      chaincodeBuild "zone-cc" "node" "$CHAINCODES_BASE_DIR/./chaincodes/zone-chaincode" "16"
      chaincodePackage "cli.user.realestate.com" "peer0.user.realestate.com:7041" "zone-cc" "$version" "node" printHeadline "Installing 'zone-cc' for user" "U1F60E"
      chaincodeInstall "cli.user.realestate.com" "peer0.user.realestate.com:7041" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.user.realestate.com" "peer1.user.realestate.com:7042" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.user.realestate.com" "peer0.user.realestate.com:7041" "main-channel" "zone-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'zone-cc' for bank" "U1F60E"
      chaincodeInstall "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.bank.realestate.com" "peer1.bank.realestate.com:7062" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "main-channel" "zone-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'zone-cc' for landauthority" "U1F60E"
      chaincodeInstall "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.landauthority.realestate.com" "peer1.landauthority.realestate.com:7082" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "main-channel" "zone-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'zone-cc' for court" "U1F60E"
      chaincodeInstall "cli.court.realestate.com" "peer0.court.realestate.com:7101" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.court.realestate.com" "peer1.court.realestate.com:7102" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.court.realestate.com" "peer0.court.realestate.com:7101" "main-channel" "zone-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'zone-cc' for inspector" "U1F60E"
      chaincodeInstall "cli.inspector.realestate.com" "peer0.inspector.realestate.com:7121" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeInstall "cli.inspector.realestate.com" "peer1.inspector.realestate.com:7122" "zone-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.inspector.realestate.com" "peer0.inspector.realestate.com:7121" "main-channel" "zone-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printItalics "Committing chaincode 'zone-cc' on channel 'main-channel' as 'user'" "U1F618"
      chaincodeCommit "cli.user.realestate.com" "peer0.user.realestate.com:7041" "main-channel" "zone-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('userMSP.member','landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member','inspectorMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" "peer0.user.realestate.com:7041,peer0.bank.realestate.com:7061,peer0.landauthority.realestate.com:7081,peer0.court.realestate.com:7101,peer0.inspector.realestate.com:7121" "crypto-peer/peer0.user.realestate.com/tls/ca.crt,crypto-peer/peer0.bank.realestate.com/tls/ca.crt,crypto-peer/peer0.landauthority.realestate.com/tls/ca.crt,crypto-peer/peer0.court.realestate.com/tls/ca.crt,crypto-peer/peer0.inspector.realestate.com/tls/ca.crt" ""

    else
      echo "Warning! Skipping chaincode 'zone-cc' upgrade. Chaincode directory is empty."
      echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/zone-chaincode'"
    fi
  fi
  if [ "$chaincodeName" = "verification-cc" ]; then
    if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/verification-chaincode")" ]; then
      printHeadline "Packaging chaincode 'verification-cc'" "U1F60E"
      chaincodeBuild "verification-cc" "node" "$CHAINCODES_BASE_DIR/./chaincodes/verification-chaincode" "16"
      chaincodePackage "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "verification-cc" "$version" "node" printHeadline "Installing 'verification-cc' for bank" "U1F60E"
      chaincodeInstall "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "verification-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "verification-channel" "verification-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'verification-cc' for landauthority" "U1F60E"
      chaincodeInstall "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "verification-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "verification-channel" "verification-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printHeadline "Installing 'verification-cc' for court" "U1F60E"
      chaincodeInstall "cli.court.realestate.com" "peer0.court.realestate.com:7101" "verification-cc" "$version" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
      chaincodeApprove "cli.court.realestate.com" "peer0.court.realestate.com:7101" "verification-channel" "verification-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" ""
      printItalics "Committing chaincode 'verification-cc' on channel 'verification-channel' as 'bank'" "U1F618"
      chaincodeCommit "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "verification-channel" "verification-cc" "$version" "orderer0.group1.orderer1.realestate.com:7030" "OR('landauthorityMSP.member', 'bankMSP.member', 'courtMSP.member')" "false" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" "peer0.bank.realestate.com:7061,peer0.landauthority.realestate.com:7081,peer0.court.realestate.com:7101" "crypto-peer/peer0.bank.realestate.com/tls/ca.crt,crypto-peer/peer0.landauthority.realestate.com/tls/ca.crt,crypto-peer/peer0.court.realestate.com/tls/ca.crt" ""

    else
      echo "Warning! Skipping chaincode 'verification-cc' upgrade. Chaincode directory is empty."
      echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/verification-chaincode'"
    fi
  fi
}

notifyOrgsAboutChannels() {

  printHeadline "Creating new channel config blocks" "U1F537"
  createNewChannelUpdateTx "main-channel" "userMSP" "MainChannel" "$FABLO_NETWORK_ROOT/fabric-config" "$FABLO_NETWORK_ROOT/fabric-config/config"
  createNewChannelUpdateTx "main-channel" "bankMSP" "MainChannel" "$FABLO_NETWORK_ROOT/fabric-config" "$FABLO_NETWORK_ROOT/fabric-config/config"
  createNewChannelUpdateTx "main-channel" "landauthorityMSP" "MainChannel" "$FABLO_NETWORK_ROOT/fabric-config" "$FABLO_NETWORK_ROOT/fabric-config/config"
  createNewChannelUpdateTx "main-channel" "courtMSP" "MainChannel" "$FABLO_NETWORK_ROOT/fabric-config" "$FABLO_NETWORK_ROOT/fabric-config/config"
  createNewChannelUpdateTx "main-channel" "inspectorMSP" "MainChannel" "$FABLO_NETWORK_ROOT/fabric-config" "$FABLO_NETWORK_ROOT/fabric-config/config"
  createNewChannelUpdateTx "verification-channel" "bankMSP" "VerificationChannel" "$FABLO_NETWORK_ROOT/fabric-config" "$FABLO_NETWORK_ROOT/fabric-config/config"
  createNewChannelUpdateTx "verification-channel" "landauthorityMSP" "VerificationChannel" "$FABLO_NETWORK_ROOT/fabric-config" "$FABLO_NETWORK_ROOT/fabric-config/config"
  createNewChannelUpdateTx "verification-channel" "courtMSP" "VerificationChannel" "$FABLO_NETWORK_ROOT/fabric-config" "$FABLO_NETWORK_ROOT/fabric-config/config"

  printHeadline "Notyfing orgs about channels" "U1F4E2"
  notifyOrgAboutNewChannelTls "main-channel" "userMSP" "cli.user.realestate.com" "peer0.user.realestate.com" "orderer0.group1.orderer1.realestate.com:7030" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
  notifyOrgAboutNewChannelTls "main-channel" "bankMSP" "cli.bank.realestate.com" "peer0.bank.realestate.com" "orderer0.group1.orderer1.realestate.com:7030" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
  notifyOrgAboutNewChannelTls "main-channel" "landauthorityMSP" "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com" "orderer0.group1.orderer1.realestate.com:7030" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
  notifyOrgAboutNewChannelTls "main-channel" "courtMSP" "cli.court.realestate.com" "peer0.court.realestate.com" "orderer0.group1.orderer1.realestate.com:7030" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
  notifyOrgAboutNewChannelTls "main-channel" "inspectorMSP" "cli.inspector.realestate.com" "peer0.inspector.realestate.com" "orderer0.group1.orderer1.realestate.com:7030" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
  notifyOrgAboutNewChannelTls "verification-channel" "bankMSP" "cli.bank.realestate.com" "peer0.bank.realestate.com" "orderer0.group1.orderer1.realestate.com:7030" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
  notifyOrgAboutNewChannelTls "verification-channel" "landauthorityMSP" "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com" "orderer0.group1.orderer1.realestate.com:7030" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"
  notifyOrgAboutNewChannelTls "verification-channel" "courtMSP" "cli.court.realestate.com" "peer0.court.realestate.com" "orderer0.group1.orderer1.realestate.com:7030" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  printHeadline "Deleting new channel config blocks" "U1F52A"
  deleteNewChannelUpdateTx "main-channel" "userMSP" "cli.user.realestate.com"
  deleteNewChannelUpdateTx "main-channel" "bankMSP" "cli.bank.realestate.com"
  deleteNewChannelUpdateTx "main-channel" "landauthorityMSP" "cli.landauthority.realestate.com"
  deleteNewChannelUpdateTx "main-channel" "courtMSP" "cli.court.realestate.com"
  deleteNewChannelUpdateTx "main-channel" "inspectorMSP" "cli.inspector.realestate.com"
  deleteNewChannelUpdateTx "verification-channel" "bankMSP" "cli.bank.realestate.com"
  deleteNewChannelUpdateTx "verification-channel" "landauthorityMSP" "cli.landauthority.realestate.com"
  deleteNewChannelUpdateTx "verification-channel" "courtMSP" "cli.court.realestate.com"

}

printStartSuccessInfo() {
  printHeadline "Done! Enjoy your fresh network" "U1F984"
}

stopNetwork() {
  printHeadline "Stopping network" "U1F68F"
  (cd "$FABLO_NETWORK_ROOT"/fabric-docker && docker compose stop)
  sleep 4
}

networkDown() {
  printHeadline "Destroying network" "U1F916"
  (cd "$FABLO_NETWORK_ROOT"/fabric-docker && docker compose down)

  printf "Removing chaincode containers & images... \U1F5D1 \n"
  for container in $(docker ps -a | grep "dev-peer0.user.realestate.com-auth-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.user.realestate.com-auth-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer1.user.realestate.com-auth-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer1.user.realestate.com-auth-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer0.bank.realestate.com-auth-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.bank.realestate.com-auth-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer1.bank.realestate.com-auth-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer1.bank.realestate.com-auth-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer0.landauthority.realestate.com-auth-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.landauthority.realestate.com-auth-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer1.landauthority.realestate.com-auth-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer1.landauthority.realestate.com-auth-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer0.court.realestate.com-auth-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.court.realestate.com-auth-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer1.court.realestate.com-auth-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer1.court.realestate.com-auth-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer0.inspector.realestate.com-auth-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.inspector.realestate.com-auth-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer1.inspector.realestate.com-auth-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer1.inspector.realestate.com-auth-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer0.user.realestate.com-Asset-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.user.realestate.com-Asset-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer1.user.realestate.com-Asset-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer1.user.realestate.com-Asset-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer0.bank.realestate.com-Asset-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.bank.realestate.com-Asset-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer1.bank.realestate.com-Asset-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer1.bank.realestate.com-Asset-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer0.landauthority.realestate.com-Asset-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.landauthority.realestate.com-Asset-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer1.landauthority.realestate.com-Asset-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer1.landauthority.realestate.com-Asset-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer0.court.realestate.com-Asset-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.court.realestate.com-Asset-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer1.court.realestate.com-Asset-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer1.court.realestate.com-Asset-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer0.inspector.realestate.com-Asset-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.inspector.realestate.com-Asset-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer1.inspector.realestate.com-Asset-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer1.inspector.realestate.com-Asset-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer0.user.realestate.com-zone-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.user.realestate.com-zone-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer1.user.realestate.com-zone-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer1.user.realestate.com-zone-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer0.bank.realestate.com-zone-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.bank.realestate.com-zone-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer1.bank.realestate.com-zone-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer1.bank.realestate.com-zone-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer0.landauthority.realestate.com-zone-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.landauthority.realestate.com-zone-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer1.landauthority.realestate.com-zone-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer1.landauthority.realestate.com-zone-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer0.court.realestate.com-zone-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.court.realestate.com-zone-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer1.court.realestate.com-zone-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer1.court.realestate.com-zone-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer0.inspector.realestate.com-zone-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.inspector.realestate.com-zone-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer1.inspector.realestate.com-zone-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer1.inspector.realestate.com-zone-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer0.bank.realestate.com-verification-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.bank.realestate.com-verification-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer0.landauthority.realestate.com-verification-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.landauthority.realestate.com-verification-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer0.court.realestate.com-verification-cc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.court.realestate.com-verification-cc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done

  printf "Removing generated configs... \U1F5D1 \n"
  rm -rf "$FABLO_NETWORK_ROOT/fabric-config/config"
  rm -rf "$FABLO_NETWORK_ROOT/fabric-config/crypto-config"
  rm -rf "$FABLO_NETWORK_ROOT/fabric-config/chaincode-packages"

  printHeadline "Done! Network was purged" "U1F5D1"
}
