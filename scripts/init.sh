#!/bin/bash
apt-get update -y
apt-get -y install python3-pip
cd ~
git clone https://github.com/strategio-tech/fp-sim4-byte-size.git
cd fp-sim4-byte-size
apt install software-properties-common
add-apt-repository -y ppa:deadsnakes/ppa
apt update -y
apt install python3.8 -y
pip3 install -t /usr/local/lib/python3.8/dist-packages -r requirements.txt
python3.8 manage.py