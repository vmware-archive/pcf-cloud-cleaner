#!/bin/bash
apt-get update
apt-get -y install python3 python3-venv jq
pyvenv env
. ./env/bin/activate
pip install --upgrade pip
pip install --upgrade awscli
aws --version
