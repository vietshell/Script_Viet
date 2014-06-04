#!/bin/sh

#  install_mysql_57.sh
#  
#
#  Created by HSP SI Viet Nam on 6/4/14.
#
#check mysql old
clear
check_mysql-`rpm -qa | grep mysql`
if [ "$check_mysql" != "" ]; then
echo "Remove package MySQL Old"
echo $check_mysql
sleep 5
yum -y remove $check_mysql
fi

#check wget install
check_wget=`rpm -qa | grep wget`
if [ "$check_mysql" = "" ]; then
echo "Install wget"
sleep 5
yum -y install wget
fi


#install MySQL New Version 5.7
wget