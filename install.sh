#!/bin/bash

yum install -y git
pip3 install oci oci-cli
#requests pandas

git clone https://github.com/yusukeyurameshi/OCI-Bucket-Antivirus.git

#crontab
## Update ClamAV virus definitions
#0 10 * * * /usr/bin/freshclam

yum -y install epel-release
yum clean all

yum -y install clamav clamav-update clamav-data clamav-scanner-systemd clamav-devel

setsebool -P antivirus_can_scan_system 1
setsebool -P clamd_use_jit 1
sed -i -e "s/^Example/#Example/" /etc/clamd.d/scan.conf
echo "LocalSocket /run/clamd.scan/clamd.sock" >>/etc/clamd.d/scan.conf

freshclam
systemctl start clamd@scan
systemctl enable clamd@scan
