#!/bin/bash

echo "Running $0"

su - opc -c bash -c "$(curl -L https://raw.githubusercontent.com/yusukeyurameshi/OCI-Bucket-Antivirus/main/install.sh)"

