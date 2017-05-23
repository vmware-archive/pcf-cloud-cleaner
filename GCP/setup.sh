#!/bin/bash

apt-get update && apt-get -y install curl jq

# Add the Cloud SDK distribution URI as a package source
echo "deb http://packages.cloud.google.com/apt cloud-sdk-xenial main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Import the Google Cloud Platform public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

# Update the package list and install the Cloud SDK
apt-get update && apt-get -y install google-cloud-sdk
