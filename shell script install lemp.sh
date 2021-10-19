#!/bin/bash
# Script date: 17-06-2019
# Script cai dat LEMP tren CentOS 7.x
#--------------------------------------------------
## Chức năng danh sách: 
# 1. f_check_root: kiểm tra để đảm bảo tập lệnh có thể được chạy bởi người dùng root 
# 2. f_disable_selinux: kiểm tra trạng thái selinux, vô hiệu hóa nếu nó thực thi 
# 3. f_update_os: cập nhật tất cả các gói # 4. f_install_lamp: funtion cài đặt LEMP stack 
# 4. f_open_port: config tường lửa để mở cổng 80, 443 

# Kiểm tra có phải tk root 
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
# Function to disable SELinux
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
# Cập nhật hệ thống 
f_update_os () {
    echo "Starting update os ..."
    sleep 1

    yum update
    yum upgrade -y

    echo ""
    sleep 1
}
# Cấu hình và cài đặt LEMP 
f_install_lemp () {
    ########## Cái đặt NGINX ##########
#Thêm kho nginx 
cat > /etc/yum.repos.d/nginx.repo <<"EOF"
[nginx]
name=nginx repo
baseurl=https://nginx.org/packages/mainline/centos/7/$basearch/
gpgcheck=0
enabled=1
EOF
# Cập nhật gói mới
    echo "Update package for nginx ..."
    sleep 1
    yum update -y
# Bắt đầu cài đặt
 yum install nginx -y

# Bật dịch vu nginx
sudo systemctl start nginx
sudo systemctl enable nginx
#Xác minh rằng Nginx đang hoạt động
curl -I 127.0.0.1
	########cấu hình MySQL 8.0##########
#Remove/Uninstall the MariaDB package if it’s installed in CentOS 7
	sudo yum remove mariadb mariadb-server
	sudo rm -rf /etc/my.cnf /etc/my.cnf.d   
#Thêm kho cho MySQL 8.0 
 cd /usr/local/src
 echo "download package"
 sudo  wget https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm
 echo ""
 sleep 1
 rpm -ivh mysql80-community-release-el7-1.noarch.rpm
 ###Install the MySQL 8.0 Server and Start MySQL Service###
 echo "Cai dat MySQL 8.0 and start mysql"
 sudo yum install mysql-server
 sudo systemctl start mysqld


