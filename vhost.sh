#!/bin/sh

#  vhost.sh
#  
#
#  Created by HSP SI Viet Nam on 5/22/14.
#
clear
tf=`echo $0`
if [ $(id -u) != "0" ]; then
echo "Ban Khong Phai La Supper User."
echo "Ban Khong Co Quyen Tao VHost"
echo "Vui long dang nhap vao tai khoan Supper User."
echo "Exxit ....."
sleep 5
clear
exit 1
fi
read -p"Nhap Ten Trang Web Ban Muon Them: " domain
if [ "$domain" = "" ]; then
    echo "Domain khong duoc la rong"
    echo "Vui Long Nhap Lai"
    sleep 5
    sh $tf
    exit 1
fi
checkdm=`ls /etc/httpd/conf.d/ | grep $domain`
if [ "$checkdm" != "" ]; then
    echo "Domain nay da ton tai, vui long nhap lai domain khac."
    echo "Neu Ban Muon Thoat ra, vui long an Ctrl + C de thoat".
    sleep 5
    sh $tf
    exit 1
fi
read -p"Create New Password: " -s pass1
echo ""
read -p"Type Password again: " -s pass2
echo ""
if [ "$pass1" != "$pass2" ]; then
echo "Error: Password khong khop"
echo "Chuong trinh se tu dong thoat"
echo "Good Bye"
sleep 5
exit 1
fi
useradd $domain
echo $pass1 | passwd $domain --stdin
homedr=`awk -F':' '{ print $6}' /etc/passwd | grep $domain`
mkdir -p $homedr/www
cat > /etc/httpd/conf.d/$domain.conf << newdomain
<VirtualHost *:80>
ServerAdmin admin@$domain
DocumentRoot $homedr/www
ServerName $domain
</VirtualHost>
newdomain

cat > $homedr/www/index.php << eof
<h3>Welcome to $domain</h3>
eof
chmod -R u=rwx,g=rwx,o= $homedr
chown -R $domain:apache $homedr

/etc/init.d/httpd reload
chkconfig httpd on
exit 1