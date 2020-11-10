#!/bin/bash

echo "ClamAV Iniciado"

firewall-offline-cmd --service=myservice --add-port=80/tcp

yum install -y httpd
systemctl start httpd

yum install -y git
git clone https://github.com/yusukeyurameshi/OCI-Bucket-Antivirus.git
cat /OCI-Bucket-Antivirus/crontab.txt | crontab -

STREAMID=$(curl -L http://169.254.169.254/opc/v1/instance/metadata | jq -j ".StreamID")
echo "StreamID="$STREAMID > OCI-Bucket-Antivirus/.env

pip3 install --upgrade setuptools
pip3 install oci oci-cli
pip3 install wheel
pip3 install python-dotenv
#requests pandas

yum -y install clamav clamav-scanner-systemd clamav-update

ln -s /etc/clamd.d/scan.conf /etc/clamd.conf

echo "LocalSocket /run/clamd.scan/clamd.sock" >>/etc/clamd.d/scan.conf
setsebool -P antivirus_can_scan_system 1

freshclam
echo "ClamAV Atualizado"

systemctl start clamd@scan
systemctl enable clamd@scan

echo "ClamAV Finalizado"



