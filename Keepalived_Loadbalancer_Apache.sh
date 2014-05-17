#!/bin/sh

#  Keepalived_Loadbalancer_Apache.sh
#  
#
#  Created by HSP SI Viet Nam on 5/17/14.
#
if [ $(id -u) != "0"]; then
printf "Error: Ban khong phai la supper admin!\n"
printf "Vui long dang nhap bang tai khoan supper admin de co the tien hanh cai dat!\n"
sleep 3
exit
fi
abc=`rpm -qa | grep httpd`
intef=`route -n | awk ' / UG / {print $8}'`
yum -y remove $abc
yum -y install httpd httpd-* wget lsof mlocate
yum -y install gcc kernel-headers kernel-devel openssl-devel
wget http://www.keepalived.org/software/keepalived-1.2.13.tar.gz
/etc/init.d/httpd restart
/etc/init.d/iptables stop
tar -xvf keepalived-1.2.13.tar.gz
cd keepalived-1.2.13
./configure --with-kernel-dir=/lib/modules/$(uname -r)/build
make && make install
cd /etc/sysconfig/
ln -s /usr/local/etc/sysconfig/keepalived .

cd /etc/rc3.d/
ln -s /usr/local/etc/rc.d/init.d/keepalived S100keepalived

cd /etc/init.d/
ln -s /usr/local/etc/rc.d/init.d/keepalived .
chmod +x keepalived

cd /usr/local/etc/keepalived
cp keepalived.conf keepalived.conf.bak

cd /etc/
ln -s /usr/local/etc/keepalived/ .

ln -s /usr/local/sbin/keepalived /usr/bin/keepalived

cat > /usr/local/etc/keepalived/keepalived.conf << eof
global_defs {
notification_email {
namnt@hsp-vn.com
}
notification_email_from service.vietsi@gmail.com
smtp_server localhost
smtp_connect_timeout 30
! UNIQUE:
router_id LVS_PRI
}
vrrp_instance VirtIP_10 {
state MASTER
interface $intef
virtual_router_id 10
! UNIQUE:
priority 111
advert_int 3
smtp_alert
authentication {
auth_type PASS
auth_pass MY_PASS
}
virtual_ipaddress {
172.16.6.169
}

lvs_sync_daemon_interface $intef
}
virtual_server 172.16.6.169 80 {
delay_loop 10
lvs_sched wlc
lvs_method DR
persistence_timeout 5
protocol TCP

real_server 172.16.6.64 80 {
weight 50
TCP_CHECK {
connect_timeout 3
}
}

real_server 172.16.6.67 80 {
weight 50
TCP_CHECK {
connect_timeout 3
}
}

}

eof
/etc/init.d/keepalived restart

modprobe dummy numdummies=1
ifconfig dummy0 172.16.6.169 netmask 255.255.255.0

cp /etc/sysctl.conf /etc/sysctl.conf.bk
cat > /etc/sysctl.conf << eof
net.ipv4.ip_forward=1
net.ipv4.conf.all.rp_filter=1
net.ipv4.icmp_echo_ignore_broadcasts=1
net.ipv4.conf.default.proxy_arp=1

net.ipv4.conf.all.promote_secondaries=1
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 2

net.ipv4.conf.eth1.arp_announce = 0
eof
sysctl -p
chkconfig --add keepalived
chkconfig keepalived on
chkconfig httpd on
/etc/init.d/keepalived restart