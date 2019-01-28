#!/bin/bash
set -e

echo "---- set locale"
sudo localectl set-locale LANG=en_US.utf8
sudo /bin/bash -c 'echo "export LANG=en_US.utf8" >> /etc/skel/.bashrc'

echo "---- Update and Upgrade"
sudo yum upgrade -y
sudo yum install -y https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm
sudo yum install -y curl unzip zip jq
