#!/bin/bash
#DINH-DUNG
echo "check samba4"
if [[ -f /etc/samba/smb.conf ]]; then
echo "Da cai dat"
else
yum instal -y vim
yum install -y samba4-* 
systemctl start smb
systemctl enable smb
systemctl stop firewalld
setenforce 0
sleep 1
echo "Cau hinh samba"
sed -i -e '11 i map to guest = Bad User' /etc/samba/smb.conf
echo "Tao duong dan foder:"
read foder
mkdir -p /$foder
echo "Nhap ten foder chia se Every one:"
read ten
echo "comment la gi:"
read comment
cat >> /etc/samba/smb.conf << EOF
[$ten]
		comment = $comment
		path = /$foder
		read only = yes
		browseable = yes
		guest ok = yes
EOF
systemctl restart smb nmb
echo "Ket thuc"
fi
exit