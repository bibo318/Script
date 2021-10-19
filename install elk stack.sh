#!/bin/bash
# Script date: 17-06-2019
# Script cai dat ELK tren CentOS 7.x
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
# Cấu hình và cài đặt ELK
_install_elk () {
##install OpenJDK 1.8.##
	yum -y install java-1.8.0 wget
	echo ""
	echo "kiem tra version"
	sleep 1
	java -version
##Them kho ELK##
	rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
##them kho luu tru Elasticsearch 
	cat > /etc/yum.repos.d/elk.repo <<"EOF"
[elasticsearch-6.x]
name=Elasticsearch repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
# Cập nhật gói mới
    echo "Update package for nginx ..."
    sleep 1
    yum update -y
##Install Elasticsearch
echo "install elasticsearch"
	yum install -y elasticsearch
#khoi dong lai elasticsearch
	systemctl daemon-reload
	systemctl enable elasticsearch
	systemctl start elasticsearch
#kiem tra elasticsearch
curl -X GET localhost:9200
sleep 1
#cai Logstash
echo "install Logstash"
yum -y install logstash
#cau hinh logstash
	cat > /etc/logstash/conf.d/logstash.conf <<"EOF"
	input {
 beats {
   port => 5044
   
   # Set to False if you do not use SSL 
   ssl => false
     }
}
filter {
if [type] == "syslog" {
    grok {
      match => { "message" => "%{SYSLOGLINE}" }
    }

    date {
match => [ "timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
}
  }

}
output {
 elasticsearch {
  hosts => localhost
    index => "%{[@metadata][beat]}-%{+YYYY.MM.dd}"
       }
stdout {
    codec => rubydebug
       }
}
EOF
#start va enable logstash
systemctl start logstash
systemctl enable logstash
sleep 1
#Install & Configure Kibana
echo "install kibana"
sed -i 's|#server.host: "localhost"|server.host: "192.168.122.21"|g' /etc/kibana/kibana.yml
sed -i 's|#elasticsearch.hosts: ["http://localhost:9200"]|elasticsearch.url: "http://localhost:9200"|g' /etc/kibana/kibana.yml
echo ""
sleep 1
systemctl start kibana
systemctl enable kibana
#mo firewalld
firewall-cmd --permanent --add-port=5044/tcp
firewall-cmd --permanent --add-port=5601/tcp
firewall-cmd --reload

systemctl restart Kibana Logstash Elasticsearch
echo "truy cap http://your-ip-address:5601/"
sleep 1
exit
