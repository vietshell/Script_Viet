#!/bin/sh

#  install_apache_centos.sh
#  
#
#  Created by HSP SI Viet Nam on 5/16/14.
#
clear
tf=`echo $0`
if [ $(id -u) != "0" ]; then
printf "Error: Ban khong phai la supper admin!\n"
printf "Vui long dang nhap bang tai khoan supper admin de co the tien hanh cai dat!\n"
sleep 3
exit
fi
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
ip_pub=`ifconfig $( route -n | awk '/ UG / {print $8}' ) | grep "inet addr:" | awk '{print $2}' | sed 's/addr://'`
check_httpd_php=`rpm -qa | grep -E 'httpd|php'`
echo "Clean All Cache Yum"
#clean all install error.
yum clean all
clear
echo "Clean Success"
echo "Check for Update System"
#update os
yum -y update
clear
echo "Success"
#remove old mysql
echo "Remove apache, php Old"
if [ "$check_httpd_php" != "" ]; then
yum -y remove $check_httpd_php
fi
clear
echo "Install php apache"
yum -y install httpd httpd-* php php-*
clear
echo "Install success"
echo "Configure apache"
sed -i 's/ServerTokens OS/ServerTokens Prod/g' /etc/httpd/conf/httpd.conf
sed -i 's/KeepAlive Off/KeepAlive On/g' /etc/httpd/conf/httpd.conf
sed -i 's/\#ServerName www.example.com:80/ServerName www.example.com\:80/g' /etc/httpd/conf/httpd.conf
sed -i 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf
sed -i 's/ServerSignature On/ServerSignature Off/g' /etc/httpd/conf/httpd.conf
sed -i 's/\#NameVirtualHost \*\:80/NameVirtualHost \*\:80/g' /etc/httpd/conf/httpd.conf
rm -rf /etc/httpd/conf.d/welcome.conf
cat > /var/www/html/index.php << eof
<?php
phpinfo();
?>
eof

cat > /etc/httpd/conf.d/1.conf << eof
<VirtualHost *:80>
    ServerAdmin namnt2202@gmail.com
    DocumentRoot /var/www/html
    ServerName $ip_pub
</VirtualHost>
eof

#Setting Iptables
IPTABLES='/sbin/iptables'
$IPTABLES -P INPUT ACCEPT
$IPTABLES -P OUTPUT ACCEPT
$IPTABLES -P FORWARD DROP
$IPTABLES -t nat -P OUTPUT ACCEPT
$IPTABLES -t nat -P POSTROUTING ACCEPT
$IPTABLES -t nat -P PREROUTING ACCEPT
$IPTABLES -t mangle -P INPUT ACCEPT
$IPTABLES -t mangle -P OUTPUT ACCEPT
$IPTABLES -t mangle -P FORWARD DROP
$IPTABLES -t mangle -P POSTROUTING ACCEPT
$IPTABLES -t mangle -P PREROUTING ACCEPT

#clear rule old
$IPTABLES -F
$IPTABLES -X
$IPTABLES -Z
$IPTABLES -t nat -F
$IPTABLES -t nat -X
$IPTABLES -t nat -Z
$IPTABLES -t mangle -F
$IPTABLES -t mangle -X
$IPTABLES -t mangle -Z

#Add policy
$IPTABLES -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
$IPTABLES -A INPUT -p icmp -j ACCEPT
$IPTABLES -A INPUT -i lo -j ACCEPT
$IPTABLES -A INPUT -p tcp --dport 22 -j ACCEPT
$IPTABLES -A INPUT -p tcp --dport 80 -j ACCEPT
$IPTABLES -A INPUT -p tcp --dport 443 -j ACCEPT

$IPTABLES -P INPUT DROP

/etc/init.d/iptables save
/etc/init.d/iptables restart
chkconfig iptables on


echo "Start Service"
/etc/init.d/httpd restart
chkconfig httpd on
echo "Reboot Server"
sleep 3
reboot
