#!/bin/bash

cd /OCI-Bucket-Antivirus
git pull

cp template.html /var/www/html/index.html
cat /var/log/messages | grep cloud-init>>/var/www/html/index.html
echo "</body></html>">>/var/www/html/index.html