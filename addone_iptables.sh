#!/bin/sh

#  addone_iptables.sh
#  
#
#  Created by HSP SI Viet Nam on 5/21/14.
#
tf=`echo $0`
read -p"Nhap Dia Chi MAC can them: " macad
if [ "$macad" = "" ]; then
echo "Dia chi MAC khong duoc la rong! Nhap Lai"
sh $tf
exit 1
fi
checkmac=`cat /etc/sysconfig/iptables | grep FORWARD | grep mac | grep $macad`
if [ "$checkmac" != "" ]; then
echo "Dia chi MAC da co trong danh sach han che"
sleep 3
exit 1
fi
iptables -t nat -A FORWARD -i eth2 -m mac --mac-source $macad -j DROP
/etc/init.d/iptables save
echo "Success"
sleep 3
exit 1