#! /bin/sh 
#Bibo318
#Install DNS MASTER 
yum install -y bind-utils bind-libs bind bind-chroot bind-devel
systemctl start named
systemctl enable named

sed -i 's/127.0.0.1/any/g' /etc/named.conf
sed -i 's/localhost/any/g' /etc/named.conf
sed -i 's/dnssec-enable yes;/#dnssec-enable yes;/g' /etc/named.conf
sed -i 's/dnssec-validation yes;/#dnssec-validation yes;/g' /etc/named.conf
sed -i 's/bindkeys-file/#bindkeys-file/g' /etc/named.conf
sed -i 's/managed-keys-directory/#managed-keys-directory/g' /etc/named.conf
sed -i 's/session-keyfile/#session-keyfile/g' /etc/named.conf
sed -i '/options \{$/a pid-file "\/run\/named\/named.pid";' /etc/named.conf
echo 'Nhap domain cho DNS'
while :
do
        read domain
        case $domain in
        *.*)
        echo "Day la ten mien chinh xac="$domain""
            break
            ;;
          *)
            echo 'Nhap ten mien chinh xac'
            ;;
esac
done
echo "zone "$domain" IN {" >> /etc/named.rfc1912.zones
echo "type master;" >> /etc/named.rfc1912.zones
echo 'file "domain.zone";' >> /etc/named.rfc1912.zones
echo "allow-update { none; };" >> /etc/named.rfc1912.zones
echo "};" >>  /etc/named.rfc1912.zones
echo 'zone "1.168.192.in-addr.arpa" IN {' >>  /etc/named.rfc1912.zones
echo "type master;" >>  /etc/named.rfc1912.zones
echo 'file "reverse.zone";' >>  /etc/named.rfc1912.zones
echo "allow-update { none; };" >>  /etc/named.rfc1912.zones
echo "};" >>  /etc/named.rfc1912.zones

echo '$TTL 1D' | tee /var/named/domain.zone /var/named/reverse.zone >> /dev/null
echo '$ORIGIN' "$domain". >> /var/named/domain.zone
echo '$ORIGIN 1.168.192.in-addr.arpa.' >> /var/named/reverse.zone
HOST=$(hostname) 
echo "@       IN SOA "$HOST.$domain". root.$domain. ( " | tee -a /var/named/domain.zone /var/named/reverse.zone >> /dev/null
echo '                          2017090201         ; serial' | tee -a /var/named/domain.zone /var/named/reverse.zone >> /dev/null
echo '                          1H                ; refresh' | tee -a /var/named/domain.zone /var/named/reverse.zone >> /dev/null
echo '                          10M               ; retry'   | tee -a /var/named/domain.zone /var/named/reverse.zone >> /dev/null
echo '                          24H               ; expire'  | tee -a /var/named/domain.zone /var/named/reverse.zone >> /dev/null
echo '                          3H )              ; minimum' | tee -a /var/named/domain.zone /var/named/reverse.zone >> /dev/null
echo "              NS  "$HOST.$domain."" | tee -a /var/named/domain.zone /var/named/reverse.zone >> /dev/null
echo "              MX  10  "mail.$domain."" >> /var/named/domain.zone
echo "              MX  0   "mail.$domain."" >> /var/named/domain.zone
echo "webmail           CNAME   "$domain."" >> /var/named/domain.zone
echo "www           CNAME    @" >> /var/named/domain.zone
nmcli connection down virbr0
PCIP=$(hostname -I)
echo ""$HOST"                   A        "$PCIP"" >> /var/named/domain.zon
echo "@                         A        "$PCIP"" >> /var/named/domain.zone
echo "Them ban ghi cho Server"
while :

do
        echo "Nhan [1] de nhap Ten may chu va dia chi IP"
        echo "Nhan [2] de bo qua"
        read PRESS
        case $PRESS in
             1)
                echo "Nhap Ten May Chu="
                read ANAME
                echo "Nhap IP May Chu="
                read IP
                echo ""$ANAME"          A          "$IP"" >> /var/named/domain.zone
        echo ""$IP"             PTR        "$ANAME"" >> /var/named/reverse.zone
        sed -i '/^@$/a '$ANAME'    A      '$IP'' /var/named/domain.zone
                ;;
             2)
                echo "Going ahead"
                break
                ;;
        esac
done
chown root.named /var/named/reverse.zone
systemctl restart named
echo "Them Firewall rule"
firewall-cmd --permanent --add-service=dns
firewall-cmd --permanent --add-port=53/tcp
firewall-cmd --permanent --add-port=53/udp
firewall-cmd --reload
echo "Chinh Sua SELinux"
setsebool -P named_tcp_bind_http_port on
setsebool -P named_write_master_zones on
INTERFACE=$(route | grep '^default' | grep -o '[^ ]*$')
nmcli connection modify $INTERFACE ipv4.dns $PCIP
nmcli con reload 
sed -i '/^search$/a search '$domain'' /etc/resolv.conf
systemctl restart named
host -a $domain
named-checkconf /etc/named.conf
if nslookup localhost >> /dev/null; then
        echo "Xin chuc mung!! -------------- DNS duoc cai thanh cong"
else
        echo "Da xay ra loi"
fi