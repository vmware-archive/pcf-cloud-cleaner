#!/bin/bash

apt-get update

apt-get install -y jq curl gnupg

echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ bionic main" | tee /etc/apt/sources.list.d/azure-cli.list
curl -L https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
apt-get install -y apt-transport-https
apt-get update && apt-get install -y --allow azure-cli
