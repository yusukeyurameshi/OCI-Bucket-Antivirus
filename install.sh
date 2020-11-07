#!/bin/bash

yum install -y git
pip3 install oci oci-cli
#requests pandas

git clone https://github.com/yusukeyurameshi/OCI-Bucket-Antivirus.git

#crontab
## Update ClamAV virus definitions
#0 10 * * * /usr/bin/freshclam


cat /OCI-Bucket-Antivirus/crontab.txt | crontab -


yum -y install clamav clamav-scanner-systemd

ln -s /etc/clamd.d/scan.conf /etc/clamd.conf

echo "LocalSocket /run/clamd.scan/clamd.sock" >>/etc/clamd.d/scan.conf
setsebool -P antivirus_can_scan_system 1

freshclam


yum -y install clamav-update


systemctl start clamd@scan
systemctl enable clamd@scan




