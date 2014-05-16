#!/bin/sh

#  install_mysql_centos.sh
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
read -p"password mysql user root: " -s dbpass
if [ "$dbpass" = "" ]; then
    printf "Error: Password Database not null"
    sleep 5
    sh $tf
fi
echo ""
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
echo "Remove Mysql Old"
yum -y remove mysql-*
clear
echo "Remove packet succes"
echo "Install mysql-server"
#install mysql-server
yum -y install mysql-server mlocate
updatedb
link_mycnf=`locate my.cnf`
clear
echo "Install MySQL Server Success"
echo "Start Service"
sed -i 's/bind-address/\#bind-address/g' $link_mycnf
sed -i '/\[mysqld\]/a character-set-server = utf8' $link_mycnf
sed -i '/\[mysqld\]/a init-connect = "SET NAMES utf8"' $link_mycnf
sed -i '/\[mysqld\]/a collation-server = utf8_general_ci' $link_mycnf
sed -i '/\[mysqld\]/a default-storage-engine = innodb' $link_mycnf
/etc/init.d/mysqld restart
chkconfig mysqld on

clear
echo "Configure MySQL User Root"
mysql -u root << eof
GRANT USAGE ON *.* TO root@'%' IDENTIFIED BY '$dbpass';
UPDATE mysql.user SET Password=PASSWORD('$dbpass') WHERE User='root';
delete from mysql.user where user='';
GRANT ALL PRIVILEGES ON * . * TO  'root'@'%' WITH GRANT OPTION MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0 ;
eof

echo "Reboot server for success install"
sleep 5
reboot
/etc/init.d/mysqld restart
