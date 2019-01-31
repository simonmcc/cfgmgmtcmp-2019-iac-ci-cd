#!/bin/bash
set -e

echo "---- set locale"
sudo localectl set-locale LANG=en_US.utf8
sudo /bin/bash -c 'echo "export LANG=en_US.utf8" >> /etc/skel/.bashrc'

echo "---- Update and Upgrade"
sudo yum upgrade -y
sudo yum install -y https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm
sudo yum install -y curl unzip zip jq

echo "---- Install SSH keys"
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEAmdv+rdGgJ7FmEZkVUH7eBpg0IAkXNLMg2srv38BQypm0kdhIBBm6Tp+1EkDNJ8cLmxJQCPQmA2R1ObD0LYsDBOVzvRYx1I49kNUJMXpO0vltf/66zQSWBNHH4DuGqRGqUwxVqL63TL48rfIP7I5lw3o1KSoqtxqvhEiYzvitzVc= simonm@vanquish" | sudo tee /home/centos/.ssh/authorized_keys
