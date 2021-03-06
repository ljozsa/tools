#!/bin/bash
# install pip
rpm -iUvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
curl --fail https://bootstrap.pypa.io/get-pip.py -o get-pip.py
if [ -e get-pip.py ]; then
	python get-pip.py
else
    yum -y install python-pip
	pip install --upgrade pip
fi

# prepare mitmproxy dependencies
yum -y remove pyOpenSSL
yum -y install gcc python-devel libxml2-devel libxslt-devel libffi-devel openssl-devel libjpeg-turbo-devel tmux xsel

# install mitmproxy
pip install mitmproxy

# run mitmproxy
tmux new-session -n mitm-proxy -d \; send -t mitm-proxy "mitmproxy -p 3128" ENTER
