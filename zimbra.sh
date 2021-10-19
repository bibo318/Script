#!/bin/bash
# Script date: 17-06-2019
# Script cai dat ELK tren CentOS 7.x
#--------------------------------------------------
## Chức năng danh sách: 
# 1. f_check_root: kiểm tra để đảm bảo tập lệnh có thể được chạy bởi người dùng root 
# 2. f_disable_selinux: kiểm tra trạng thái selinux, vô hiệu hóa nếu nó thực thi 
# 3. f_update_os: cập nhật tất cả các gói # 4. f_install_lamp: funtion cài đặt LEMP stack 
f_check_root () {
if (( $EUID == 0 )); then
   # If user is root, continue to function f_sub_main
   f_sub_main
    else
        # If user not is root, print message and exit script
        echo "Please run this script by user root !"
        exit
    fi
}

f_disable_selinux () {
    SE=`cat /etc/selinux/config | grep ^SELINUX= | awk -F'=' '{print $2}'`
    echo "Checking SELinux status ..."
    echo ""
    sleep 1

    if [[ "$SE" == "enforcing" ]]; then
        sed -i 's|SELINUX=enforcing|SELINUX=disabled|g' /etc/selinux/config
        echo "Disable SElinux and reboot after 5s. Press Ctrl+C to stop script."
        echo "After system reboot, please run script again."
        echo ""
        sleep 5
        reboot
    fi
}

f_update_os () {
    echo "Starting update os ..."
    sleep 1

    yum update
    yum upgrade -y

    echo ""
    sleep 1
}
f_install_webmin () {
	systemctl stop firewalld
	systemctl disable firewalld
	echo ""
	sleep 1
	rpm -Uvh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
	rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-5.rpm
	sleep 1
	yum install wget screen lsof rsync nmap net-tools unzip sudo sysstat perl-core -y
	echo ""
	yum update -y
	reboot
	cat >/etc/yum.repos.d/webmin.repo <<"EOF"
	[Webmin]
	name=Webmin Distribution Neutral
	#baseurl=http://download.webmin.com/download/yum
	mirrorlist=http://download.webmin.com/download/yum/mirrorlist
	enabled=1
EOF
	sleep 1
	rpm --import http://www.webmin.com/jcameron-key.asc

	yum install webmin perl-Net-SSLeay -y
	service webmin start
	lsof -i :10000
	chkconfig webmin on
	yum install bind bind-utils bind-chroot –y
	systemctl enable named	
	systemctl start named
	sleep 1
	cat /etc/resolv.conf
	cat /etc/hosts
}

f_install_zimbra () {
	cd /
	wget https://files.zimbra.com/downloads/8.8.12_GA/zcs-8.8.12_GA_3794.RHEL7_64.20190329045002.tgz
	tar -vxzf zcs-8.8.12_GA_3794.RHEL7_64.20190329045002.tgz
	cd zcs-8.8.12_GA_3794.RHEL7_64.20190329045002
	./install.sh --platform-override
}
echo "truy cap https://ip-may:7071" 
echo "truy cap mail https://ip-may"
exit