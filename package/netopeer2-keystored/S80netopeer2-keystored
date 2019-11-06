#!/bin/bash

set -eu -o pipefail

shopt -s failglob

local_path=$(dirname $0)

: ${SYSREPOCFG:=sysrepocfg}
: ${CHMOD:=chmod}
: ${OPENSSL:=openssl}
: ${SSH_KEYGEN:=ssh-keygen}
: ${STOCK_KEY_CONFIG:=$local_path/../stock_key_config.xml}
: ${KEYSTORED_KEYS_DIR:=/etc/keystored/keys}

if [ -r ${KEYSTORED_KEYS_DIR}/ssh_host_rsa_key.pem -a -r ${KEYSTORED_KEYS_DIR}/ssh_host_rsa_key.pem.pub ]; then
	echo "- SSH hostkey found, no need to generate a new one."
else
	echo "- SSH hostkey not found, generating a new one..."
	$SSH_KEYGEN -m pem -t rsa -q -N "" -f ${KEYSTORED_KEYS_DIR}/ssh_host_rsa_key.pem
	# public key format cannot be specified, it is always in the openssh format
	# force convert it to PEM as well
	$CHMOD go-rw ${KEYSTORED_KEYS_DIR}/ssh_host_rsa_key.pem.pub
	$SSH_KEYGEN -e -m pem -f ${KEYSTORED_KEYS_DIR}/ssh_host_rsa_key.pem.pub > ${KEYSTORED_KEYS_DIR}/pub.pem
	mv -f ${KEYSTORED_KEYS_DIR}/pub.pem ${KEYSTORED_KEYS_DIR}/ssh_host_rsa_key.pem.pub
	$CHMOD go-rw ${KEYSTORED_KEYS_DIR}/ssh_host_rsa_key.pem
	$CHMOD go+r ${KEYSTORED_KEYS_DIR}/ssh_host_rsa_key.pem.pub
fi
