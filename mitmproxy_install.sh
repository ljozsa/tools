#!/bin/bash
# install pip
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py

# prepare mitmproxy dependencies
yum -y remove pyOpenSSL
yum -y install gcc python-devel libxml2-devel libxslt-devel libffi-devel openssl-devel libjpeg-turbo-devel tmux

# install mitmproxy
pip install mitmproxy

# run mitmproxy
tmux new-session -n mitm-proxy -d \; send -t mitm-proxy mitmproxy ENTER
