#!/bin/bash
echo "bash-shell-script"
if [[ -f /etc/named ]]; then
echo "Da cai dat"
else
yum -y update 
systemclt stop firewalld
echo "cai dat goi"
yum install -y telnet 
yum install -y ntpdate 
yum install -y vim
yum install -y bind* 
sleep 1
echo "check bind packages"
sleep 1
echo "Nhap user va passwd muon tao:"
read user
read pass
useradd $user && echo '$pass' | passwd $user --stdin
smbpasswd -a $user
echo "KET THUC"
fi
