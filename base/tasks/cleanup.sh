#!/bin/bash
set -e

echo "---- cleanup"
echo CentOS Provision Cleanup
sudo yum clean all

sudo rm -rf /var/lib/yum
sudo rm -rf /var/cache/yum
sudo rm -rf /tmp/*
