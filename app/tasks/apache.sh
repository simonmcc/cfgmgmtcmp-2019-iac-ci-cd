#!/bin/bash
set -e

echo '---- install Apache'

sudo yum install -y httpd
sudo systemctl enable httpd

cat > /var/www/html/index.html <<HERE
Plain text FTW!
HERE
