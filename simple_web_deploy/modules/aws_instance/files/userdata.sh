#!/usr/bin/env bash

# Log everything we do.
set -x
exec > /var/log/user-data.log 2>&1

# update yum and install apache
yum update -y
yum install -y httpd

# Create a simple page showing our local hostname.
echo "<p>Hello from $(curl http://169.254.169.254/latest/meta-data/local-hostname)</p>" >> /var/www/html/index.html

# restart apache.
systemctl restart httpd