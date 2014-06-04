#!/bin/sh

#  Script.sh
#  
#
#  Created by HSP SI Viet Nam on 5/27/14.
#
clear
#check super user
if [ $( id -u ) != "0" ]; then
echo "User not Supper User"
echo "Please Login Supper User."
echo "Thanks!"
exit 1
fi

#check install wget
check_wget=`rpm -qa | grep wget`
if [ "$check_wget" = "" ]; then
echo "Install wget"
yum -y install wget
clear
fi

#check install mysql-client
check_mysql=`rpm -qa | grep mysql-5.*`
if [ "$check_mysql" = "" ]; then
echo "Install MySQL Client"
yum -y install mysql
clear
fi

#check install nmap
check_nmap=`rpm -qa | grep nmap`
if [ "$check_nmap" = "" ]; then
echo "Install nmap"
yum -y install nmap
clear
fi

#check epel release
check_epel=`rpm -qa | grep epel`
if [ "$check_epel" = "" ]; then
echo "Install epel release"
yum -y install https://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
clear
fi

#check install ssmtp
check_ssmtp=`rpm -qa | grep ssmtp `
if [ "$check_ssmtp" = "" ]; then
echo "Install ssmtp"
yum -y install ssmtp
clear
fi

#open port iptables
/sbin/iptables -P INPUT ACCEPT
/sbin/iptables -P OUTPUT ACCEPT
/sbin/iptables -P FORWARD DROP
/sbin/iptables -F
/etc/init.d/iptables save

#configure ssmtp
cat > /etc/ssmtp/ssmtp.conf << eof
root=hotro.hspvn@gmail.com
AuthUser=hotro.hspvn
AuthPass=nguyenthenam2202
UseSTARTTLS=YES
mailhub=smtp.gmail.com:587
FromLineOverride=YES
UseTLS=YES
TLS_CA_File=/etc/pki/tls/certs/ca-bundle.crt
eof

#get day
get_day=`date`

#scan port
ip_scan=`echo "select Dia_Chi_Ket_Noi from IPBV" | mysql -u check_service -p123456a@ -h172.16.30.30 ipbv | sed 's/Dia_Chi_Ket_Noi//'`
for i in $ip_scan;
do
echo "================================"
echo "Check port for $i"
check_port=`nmap -sV -p 80,8080,1521 $i | grep -E 'Apache Tomcat|Oracle' | grep 'open'`
if [ "$check_port" != "" ]; then
ssmtp -t << eof
to:namnt@hsp-vn.com
from:hotro.hspvn@gmail.com
cc:hoangnd@hsp-vn.com
subject:Service $i die $get_day
$get_day
service server $i die:
$check_port
.

.


eof
wget -q -O - "http://172.16.6.21:13131/cgi-bin/sendsms?username=playsms&password=playsms&to=+84974039693&text=$i die $check_port"
fi
echo "================================";
done
echo success
exit 1