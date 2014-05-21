#!/bin/sh

#  install_apache_centos.sh
#  
#
#  Created by HSP SI Viet Nam on 5/16/14.
#
clear
tf=`echo $0`
if [ $(id -u) != "0"]; then
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

echo "Start Service"
/etc/init.d/httpd restart
chkconfig httpd on
echo "Reboot Server"
sleep 3
reboot
