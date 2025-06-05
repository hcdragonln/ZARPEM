#!/usr/bin/env bash

source "$FABLO_NETWORK_ROOT/fabric-docker/scripts/channel-query-functions.sh"

set -eu

channelQuery() {
  echo "-> Channel query: " + "$@"

  if [ "$#" -eq 1 ]; then
    printChannelsHelp

  elif [ "$1" = "list" ] && [ "$2" = "user" ] && [ "$3" = "peer0" ]; then

    peerChannelListTls "cli.user.realestate.com" "peer0.user.realestate.com:7041" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif
    [ "$1" = "list" ] && [ "$2" = "user" ] && [ "$3" = "peer1" ]
  then

    peerChannelListTls "cli.user.realestate.com" "peer1.user.realestate.com:7042" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif
    [ "$1" = "list" ] && [ "$2" = "bank" ] && [ "$3" = "peer0" ]
  then

    peerChannelListTls "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif
    [ "$1" = "list" ] && [ "$2" = "bank" ] && [ "$3" = "peer1" ]
  then

    peerChannelListTls "cli.bank.realestate.com" "peer1.bank.realestate.com:7062" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif
    [ "$1" = "list" ] && [ "$2" = "landauthority" ] && [ "$3" = "peer0" ]
  then

    peerChannelListTls "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif
    [ "$1" = "list" ] && [ "$2" = "landauthority" ] && [ "$3" = "peer1" ]
  then

    peerChannelListTls "cli.landauthority.realestate.com" "peer1.landauthority.realestate.com:7082" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif
    [ "$1" = "list" ] && [ "$2" = "court" ] && [ "$3" = "peer0" ]
  then

    peerChannelListTls "cli.court.realestate.com" "peer0.court.realestate.com:7101" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif
    [ "$1" = "list" ] && [ "$2" = "court" ] && [ "$3" = "peer1" ]
  then

    peerChannelListTls "cli.court.realestate.com" "peer1.court.realestate.com:7102" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif
    [ "$1" = "list" ] && [ "$2" = "inspector" ] && [ "$3" = "peer0" ]
  then

    peerChannelListTls "cli.inspector.realestate.com" "peer0.inspector.realestate.com:7121" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif
    [ "$1" = "list" ] && [ "$2" = "inspector" ] && [ "$3" = "peer1" ]
  then

    peerChannelListTls "cli.inspector.realestate.com" "peer1.inspector.realestate.com:7122" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif

    [ "$1" = "getinfo" ] && [ "$2" = "main-channel" ] && [ "$3" = "user" ] && [ "$4" = "peer0" ]
  then

    peerChannelGetInfoTls "main-channel" "cli.user.realestate.com" "peer0.user.realestate.com:7041" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "main-channel" ] && [ "$4" = "user" ] && [ "$5" = "peer0" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfigTls "main-channel" "cli.user.realestate.com" "$TARGET_FILE" "peer0.user.realestate.com:7041" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$3" = "main-channel" ] && [ "$4" = "user" ] && [ "$5" = "peer0" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlockTls "main-channel" "cli.user.realestate.com" "${BLOCK_NAME}" "peer0.user.realestate.com:7041" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" "$TARGET_FILE"

  elif
    [ "$1" = "getinfo" ] && [ "$2" = "main-channel" ] && [ "$3" = "user" ] && [ "$4" = "peer1" ]
  then

    peerChannelGetInfoTls "main-channel" "cli.user.realestate.com" "peer1.user.realestate.com:7042" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "main-channel" ] && [ "$4" = "user" ] && [ "$5" = "peer1" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfigTls "main-channel" "cli.user.realestate.com" "$TARGET_FILE" "peer1.user.realestate.com:7042" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$3" = "main-channel" ] && [ "$4" = "user" ] && [ "$5" = "peer1" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlockTls "main-channel" "cli.user.realestate.com" "${BLOCK_NAME}" "peer1.user.realestate.com:7042" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" "$TARGET_FILE"

  elif
    [ "$1" = "getinfo" ] && [ "$2" = "main-channel" ] && [ "$3" = "bank" ] && [ "$4" = "peer0" ]
  then

    peerChannelGetInfoTls "main-channel" "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "main-channel" ] && [ "$4" = "bank" ] && [ "$5" = "peer0" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfigTls "main-channel" "cli.bank.realestate.com" "$TARGET_FILE" "peer0.bank.realestate.com:7061" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$3" = "main-channel" ] && [ "$4" = "bank" ] && [ "$5" = "peer0" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlockTls "main-channel" "cli.bank.realestate.com" "${BLOCK_NAME}" "peer0.bank.realestate.com:7061" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" "$TARGET_FILE"

  elif
    [ "$1" = "getinfo" ] && [ "$2" = "main-channel" ] && [ "$3" = "bank" ] && [ "$4" = "peer1" ]
  then

    peerChannelGetInfoTls "main-channel" "cli.bank.realestate.com" "peer1.bank.realestate.com:7062" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "main-channel" ] && [ "$4" = "bank" ] && [ "$5" = "peer1" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfigTls "main-channel" "cli.bank.realestate.com" "$TARGET_FILE" "peer1.bank.realestate.com:7062" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$3" = "main-channel" ] && [ "$4" = "bank" ] && [ "$5" = "peer1" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlockTls "main-channel" "cli.bank.realestate.com" "${BLOCK_NAME}" "peer1.bank.realestate.com:7062" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" "$TARGET_FILE"

  elif
    [ "$1" = "getinfo" ] && [ "$2" = "main-channel" ] && [ "$3" = "landauthority" ] && [ "$4" = "peer0" ]
  then

    peerChannelGetInfoTls "main-channel" "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "main-channel" ] && [ "$4" = "landauthority" ] && [ "$5" = "peer0" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfigTls "main-channel" "cli.landauthority.realestate.com" "$TARGET_FILE" "peer0.landauthority.realestate.com:7081" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$3" = "main-channel" ] && [ "$4" = "landauthority" ] && [ "$5" = "peer0" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlockTls "main-channel" "cli.landauthority.realestate.com" "${BLOCK_NAME}" "peer0.landauthority.realestate.com:7081" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" "$TARGET_FILE"

  elif
    [ "$1" = "getinfo" ] && [ "$2" = "main-channel" ] && [ "$3" = "landauthority" ] && [ "$4" = "peer1" ]
  then

    peerChannelGetInfoTls "main-channel" "cli.landauthority.realestate.com" "peer1.landauthority.realestate.com:7082" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "main-channel" ] && [ "$4" = "landauthority" ] && [ "$5" = "peer1" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfigTls "main-channel" "cli.landauthority.realestate.com" "$TARGET_FILE" "peer1.landauthority.realestate.com:7082" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$3" = "main-channel" ] && [ "$4" = "landauthority" ] && [ "$5" = "peer1" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlockTls "main-channel" "cli.landauthority.realestate.com" "${BLOCK_NAME}" "peer1.landauthority.realestate.com:7082" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" "$TARGET_FILE"

  elif
    [ "$1" = "getinfo" ] && [ "$2" = "main-channel" ] && [ "$3" = "court" ] && [ "$4" = "peer0" ]
  then

    peerChannelGetInfoTls "main-channel" "cli.court.realestate.com" "peer0.court.realestate.com:7101" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "main-channel" ] && [ "$4" = "court" ] && [ "$5" = "peer0" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfigTls "main-channel" "cli.court.realestate.com" "$TARGET_FILE" "peer0.court.realestate.com:7101" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$3" = "main-channel" ] && [ "$4" = "court" ] && [ "$5" = "peer0" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlockTls "main-channel" "cli.court.realestate.com" "${BLOCK_NAME}" "peer0.court.realestate.com:7101" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" "$TARGET_FILE"

  elif
    [ "$1" = "getinfo" ] && [ "$2" = "main-channel" ] && [ "$3" = "court" ] && [ "$4" = "peer1" ]
  then

    peerChannelGetInfoTls "main-channel" "cli.court.realestate.com" "peer1.court.realestate.com:7102" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "main-channel" ] && [ "$4" = "court" ] && [ "$5" = "peer1" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfigTls "main-channel" "cli.court.realestate.com" "$TARGET_FILE" "peer1.court.realestate.com:7102" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$3" = "main-channel" ] && [ "$4" = "court" ] && [ "$5" = "peer1" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlockTls "main-channel" "cli.court.realestate.com" "${BLOCK_NAME}" "peer1.court.realestate.com:7102" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" "$TARGET_FILE"

  elif
    [ "$1" = "getinfo" ] && [ "$2" = "main-channel" ] && [ "$3" = "inspector" ] && [ "$4" = "peer0" ]
  then

    peerChannelGetInfoTls "main-channel" "cli.inspector.realestate.com" "peer0.inspector.realestate.com:7121" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "main-channel" ] && [ "$4" = "inspector" ] && [ "$5" = "peer0" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfigTls "main-channel" "cli.inspector.realestate.com" "$TARGET_FILE" "peer0.inspector.realestate.com:7121" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$3" = "main-channel" ] && [ "$4" = "inspector" ] && [ "$5" = "peer0" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlockTls "main-channel" "cli.inspector.realestate.com" "${BLOCK_NAME}" "peer0.inspector.realestate.com:7121" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" "$TARGET_FILE"

  elif
    [ "$1" = "getinfo" ] && [ "$2" = "main-channel" ] && [ "$3" = "inspector" ] && [ "$4" = "peer1" ]
  then

    peerChannelGetInfoTls "main-channel" "cli.inspector.realestate.com" "peer1.inspector.realestate.com:7122" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "main-channel" ] && [ "$4" = "inspector" ] && [ "$5" = "peer1" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfigTls "main-channel" "cli.inspector.realestate.com" "$TARGET_FILE" "peer1.inspector.realestate.com:7122" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$3" = "main-channel" ] && [ "$4" = "inspector" ] && [ "$5" = "peer1" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlockTls "main-channel" "cli.inspector.realestate.com" "${BLOCK_NAME}" "peer1.inspector.realestate.com:7122" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" "$TARGET_FILE"

  elif
    [ "$1" = "getinfo" ] && [ "$2" = "verification-channel" ] && [ "$3" = "bank" ] && [ "$4" = "peer0" ]
  then

    peerChannelGetInfoTls "verification-channel" "cli.bank.realestate.com" "peer0.bank.realestate.com:7061" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "verification-channel" ] && [ "$4" = "bank" ] && [ "$5" = "peer0" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfigTls "verification-channel" "cli.bank.realestate.com" "$TARGET_FILE" "peer0.bank.realestate.com:7061" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$3" = "verification-channel" ] && [ "$4" = "bank" ] && [ "$5" = "peer0" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlockTls "verification-channel" "cli.bank.realestate.com" "${BLOCK_NAME}" "peer0.bank.realestate.com:7061" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" "$TARGET_FILE"

  elif
    [ "$1" = "getinfo" ] && [ "$2" = "verification-channel" ] && [ "$3" = "landauthority" ] && [ "$4" = "peer0" ]
  then

    peerChannelGetInfoTls "verification-channel" "cli.landauthority.realestate.com" "peer0.landauthority.realestate.com:7081" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "verification-channel" ] && [ "$4" = "landauthority" ] && [ "$5" = "peer0" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfigTls "verification-channel" "cli.landauthority.realestate.com" "$TARGET_FILE" "peer0.landauthority.realestate.com:7081" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$3" = "verification-channel" ] && [ "$4" = "landauthority" ] && [ "$5" = "peer0" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlockTls "verification-channel" "cli.landauthority.realestate.com" "${BLOCK_NAME}" "peer0.landauthority.realestate.com:7081" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" "$TARGET_FILE"

  elif
    [ "$1" = "getinfo" ] && [ "$2" = "verification-channel" ] && [ "$3" = "court" ] && [ "$4" = "peer0" ]
  then

    peerChannelGetInfoTls "verification-channel" "cli.court.realestate.com" "peer0.court.realestate.com:7101" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "verification-channel" ] && [ "$4" = "court" ] && [ "$5" = "peer0" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfigTls "verification-channel" "cli.court.realestate.com" "$TARGET_FILE" "peer0.court.realestate.com:7101" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$3" = "verification-channel" ] && [ "$4" = "court" ] && [ "$5" = "peer0" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlockTls "verification-channel" "cli.court.realestate.com" "${BLOCK_NAME}" "peer0.court.realestate.com:7101" "crypto-orderer/tlsca.orderer1.realestate.com-cert.pem" "$TARGET_FILE"

  else

    echo "$@"
    echo "$1, $2, $3, $4, $5, $6, $7, $#"
    printChannelsHelp
  fi

}

printChannelsHelp() {
  echo "Channel management commands:"
  echo ""

  echo "fablo channel list user peer0"
  echo -e "\t List channels on 'peer0' of 'user'".
  echo ""

  echo "fablo channel list user peer1"
  echo -e "\t List channels on 'peer1' of 'user'".
  echo ""

  echo "fablo channel list bank peer0"
  echo -e "\t List channels on 'peer0' of 'bank'".
  echo ""

  echo "fablo channel list bank peer1"
  echo -e "\t List channels on 'peer1' of 'bank'".
  echo ""

  echo "fablo channel list landauthority peer0"
  echo -e "\t List channels on 'peer0' of 'landauthority'".
  echo ""

  echo "fablo channel list landauthority peer1"
  echo -e "\t List channels on 'peer1' of 'landauthority'".
  echo ""

  echo "fablo channel list court peer0"
  echo -e "\t List channels on 'peer0' of 'court'".
  echo ""

  echo "fablo channel list court peer1"
  echo -e "\t List channels on 'peer1' of 'court'".
  echo ""

  echo "fablo channel list inspector peer0"
  echo -e "\t List channels on 'peer0' of 'inspector'".
  echo ""

  echo "fablo channel list inspector peer1"
  echo -e "\t List channels on 'peer1' of 'inspector'".
  echo ""

  echo "fablo channel getinfo main-channel user peer0"
  echo -e "\t Get channel info on 'peer0' of 'user'".
  echo ""
  echo "fablo channel fetch config main-channel user peer0 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer0' of 'user'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> main-channel user peer0 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer0' of 'user'".
  echo ""

  echo "fablo channel getinfo main-channel user peer1"
  echo -e "\t Get channel info on 'peer1' of 'user'".
  echo ""
  echo "fablo channel fetch config main-channel user peer1 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer1' of 'user'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> main-channel user peer1 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer1' of 'user'".
  echo ""

  echo "fablo channel getinfo main-channel bank peer0"
  echo -e "\t Get channel info on 'peer0' of 'bank'".
  echo ""
  echo "fablo channel fetch config main-channel bank peer0 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer0' of 'bank'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> main-channel bank peer0 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer0' of 'bank'".
  echo ""

  echo "fablo channel getinfo main-channel bank peer1"
  echo -e "\t Get channel info on 'peer1' of 'bank'".
  echo ""
  echo "fablo channel fetch config main-channel bank peer1 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer1' of 'bank'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> main-channel bank peer1 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer1' of 'bank'".
  echo ""

  echo "fablo channel getinfo main-channel landauthority peer0"
  echo -e "\t Get channel info on 'peer0' of 'landauthority'".
  echo ""
  echo "fablo channel fetch config main-channel landauthority peer0 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer0' of 'landauthority'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> main-channel landauthority peer0 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer0' of 'landauthority'".
  echo ""

  echo "fablo channel getinfo main-channel landauthority peer1"
  echo -e "\t Get channel info on 'peer1' of 'landauthority'".
  echo ""
  echo "fablo channel fetch config main-channel landauthority peer1 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer1' of 'landauthority'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> main-channel landauthority peer1 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer1' of 'landauthority'".
  echo ""

  echo "fablo channel getinfo main-channel court peer0"
  echo -e "\t Get channel info on 'peer0' of 'court'".
  echo ""
  echo "fablo channel fetch config main-channel court peer0 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer0' of 'court'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> main-channel court peer0 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer0' of 'court'".
  echo ""

  echo "fablo channel getinfo main-channel court peer1"
  echo -e "\t Get channel info on 'peer1' of 'court'".
  echo ""
  echo "fablo channel fetch config main-channel court peer1 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer1' of 'court'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> main-channel court peer1 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer1' of 'court'".
  echo ""

  echo "fablo channel getinfo main-channel inspector peer0"
  echo -e "\t Get channel info on 'peer0' of 'inspector'".
  echo ""
  echo "fablo channel fetch config main-channel inspector peer0 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer0' of 'inspector'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> main-channel inspector peer0 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer0' of 'inspector'".
  echo ""

  echo "fablo channel getinfo main-channel inspector peer1"
  echo -e "\t Get channel info on 'peer1' of 'inspector'".
  echo ""
  echo "fablo channel fetch config main-channel inspector peer1 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer1' of 'inspector'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> main-channel inspector peer1 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer1' of 'inspector'".
  echo ""

  echo "fablo channel getinfo verification-channel bank peer0"
  echo -e "\t Get channel info on 'peer0' of 'bank'".
  echo ""
  echo "fablo channel fetch config verification-channel bank peer0 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer0' of 'bank'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> verification-channel bank peer0 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer0' of 'bank'".
  echo ""

  echo "fablo channel getinfo verification-channel landauthority peer0"
  echo -e "\t Get channel info on 'peer0' of 'landauthority'".
  echo ""
  echo "fablo channel fetch config verification-channel landauthority peer0 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer0' of 'landauthority'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> verification-channel landauthority peer0 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer0' of 'landauthority'".
  echo ""

  echo "fablo channel getinfo verification-channel court peer0"
  echo -e "\t Get channel info on 'peer0' of 'court'".
  echo ""
  echo "fablo channel fetch config verification-channel court peer0 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer0' of 'court'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> verification-channel court peer0 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer0' of 'court'".
  echo ""

}
