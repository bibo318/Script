echo "check httpd packages"
sleep 1
if [[ -f /etc/httpd/conf/httpd.conf ]]; then
echo "Da cai dat"
else
yum install -y httpd
systemctl start httpd
systemctl stop firewalld
setenforce 0
echo "Cau Hinh"
sleep 2
echo "Nhap Domain muon tao: "
read domain
cat >> /etc/httpd/conf.d/vhost.conf << EOF
<VirtualHost *:80>
	ServerAdmin web@$domain
	ServerName  www.$domain
	DocumentRoot /var/www/html/$domain
</VirtualHost>
EOF
echo "Tao Thu Muc"
mkdir -p /var/www/html/$domain
echo "Xin chao" > /var/www/html/$domain/index.html
sed -i -e '65 i NameVirtualHost *:80' /etc/httpd/conf/httpd.conf
systemctl restart httpd
fi
