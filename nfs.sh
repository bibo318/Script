echo -e "\e[32mAuto nfs Server\e[0m"
sleep 2
echo -e "\e[33mInstall NFS\e[0m"
sleep 1.5
if [[ -f /etc/nfs.conf ]]; then
	echo "Installed"
	exit
else
yum install nfs-utils -y
systemctl start nfs
systemctl enable nfs
systemctl stop firewalld
setenforce 0
echo -e "\e[33mCreate Folder Share\e[0m"
echo -n -e "\e[32mEnter Your Folder Or Path To Folder: \e[0m"
read folder
mkdir -p /$folder
echo "Test NFS" > /$folder/test.txt
sleep 1
echo -e -n "\e[32mEnter Your IP: \e[0m"
read ip
echo -e "\e[33mConfig NFS Server\e[0m"
cat >> /etc/exports << EOF
/$folder $ip/24(rw)
EOF
echo "Success"
sleep 2
fi
