#!/bin/bash

cd /OCI-Bucket-Antivirus
git pull

cp template.html /var/www/html/index.html


$content=`cat /var/log/messages | grep cloud-init`
sed "s/@@@CONTEUDOINSTALACAO@@@/${content}/g /var/www/html/index.html"
