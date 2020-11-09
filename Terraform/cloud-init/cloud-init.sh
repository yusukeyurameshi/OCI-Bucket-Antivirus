#!/bin/bash

echo "Running $0"

bash -c "$(curl -L https://raw.githubusercontent.com/yusukeyurameshi/OCI-Bucket-Antivirus/main/install.sh)"

STREAMID=$(curl -L http://169.254.169.254/opc/v1/instance/metadata | jq -j ".StreamID")
echo "StreamID="$STREAMID > OCI-Bucket-Antivirus/.env