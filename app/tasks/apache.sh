#!/bin/bash
set -e

echo '---- install Apache'

yum install -y httpd

cat > /var/www/html/index.html <<HERE
Plain text FTW!
HERE
