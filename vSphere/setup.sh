#!/bin/bash

apt-get update && apt-get -y install curl jq

# install govc
curl -L -O https://github.com/vmware/govmomi/releases/download/v0.17.1/govc_linux_amd64.gz
gunzip govc_linux_amd64.gz
chmod +x govc_linux_amd64
mv govc_linux_amd64 /usr/local/bin/govc
