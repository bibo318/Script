#!/bin/bash
# Script date: 13-06-2019
# Script cai dat LAMP tren CentOS 7.x
#--------------------------------------------------
#  phien ban cai dat :
# 1. OS: CentOS 7.x (Core) 64bit.
# 2. Apache: Apache/2.4.6 (CentOS)
# 3. MariaDB: 10.2.13-MariaDB
# 4. PHP 7: PHP 7.2.3 (cli)
#--------------------------------------------------
## Chức năng danh sách: 
# 1. f_check_root: kiểm tra để đảm bảo tập lệnh có thể được chạy bởi người dùng root 
# 2. f_disable_selinux: kiểm tra trạng thái selinux, vô hiệu hóa nếu nó thực thi 
# 3. f_update_os: cập nhật tất cả các gói # 4. f_install_lamp: funtion cài đặt LAMP stack 
# 5. f_open_port: config tường lửa để mở cổng 80, 443 
# 6. f_sub_main: chức năng sử dụng để gọi phần chính của cài đặt 
# 7. f_main: chức năng chính, thêm chức năng của bạn vào nơi này


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

# Cấu hình và cài đặt LAMP 
f_install_lamp () {
    ########## Cái đặt APACHE ##########
    echo "I
#[mariadb]
#name = MariaDB
#baseurl =http://yum.mariadb.org/10.4.4/centos8-amd64
#gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
#gpgcheck=1
#EOF

    # Cập nhật gói mới
  #  sleep 1
   # yum update -y
nstalling apache ..."
    sleep 1

    yum install httpd -y

    # Phần này được tối ưu hóa cho máy chủ RAM 2GB
    cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.original
    sed -i '/<IfModule prefork.c/,/<\/IfModule/{//!d}' /etc/httpd/conf/httpd.conf
    sed -i '/<IfModule prefork.c/a\ StartServers              4\n MinSpareServers           20\n MaxSpareServers           40\n MaxClients         200\n MaxRequestsPerChild    4500' /etc/httpd/conf/httpd.conf

    # Bật dịch vu httpd
    systemctl enable httpd.service
    systemctl restart httpd.service

    ########## INSTALL MARIADB ##########
  ##  sleep 1

    # Thêm kho MariaDB
    #baseurl = http://yum.mariadb.org/10.2/centos7-amd64
   # cat > /etc/yum.repos.d/MariaDB.repo <<"EOF"

#[mariadb]
#name = MariaDB
#baseurl =http://yum.mariadb.org/10.4.4/centos8-amd64
#gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
#gpgcheck=1
#EOF

    # Cập nhật gói mới
  #  sleep 1
   # yum update -y

    # Bắt đầu cài đặt MariaDB
    echo "Installing MariaDB server ..."
    sleep 1
    yum install mariadb-server mariadb -y

    # Bật và khởi động dịch vụ mysql
    systemctl enable mariadb
    systemctl start mariadb
    echo ""
    sleep 1

    ########## cài đặt  PHP7 ##########
    yum install epel-release -y
    yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
    yum install yum-utils -y
    yum-config-manager --enable remi-php72
    yum install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo php-pear -y

    # Cấu hình để sửa lỗi Apache không tải tập tin PHP
    chown -R apache:apache /var/www
    sed -i '/<Directory \/>/,/<\/Directory/{//!d}' /etc/httpd/conf/httpd.conf
    sed -i '/<Directory \/>/a\    Options Indexes FollowSymLinks\n    AllowOverride All\n    Require all granted' /etc/httpd/conf/httpd.conf

    # Khởi động lại  Apache
    systemctl restart httpd
}

# Mở các port 80,433 trong IPtables
f_open_port () {
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    firewall-cmd --permanent --add-port=80/tcp
    firewall-cmd --permanent --add-port=443/tcp
    firewall-cmd --reload
}

# Các chức năng chính phụ, sử dụng để gọi các chức năng cần thiết của cài đặt
f_sub_main () {
    f_disable_selinux
    f_update_os
    f_install_lamp
    f_open_port

    echo "<?php phpinfo(); ?>" > /var/www/html/info.php
    echo ""
    echo ""
    echo "Please run command to secure MariaDB: mysql_secure_installation"
    echo "You can access http://YOUR-SERVER-IP/info.php to see more informations about PHP"
    sleep 1
}

# Chức năng chính 
f_main () {
    f_check_root
}
f_main

exit