#!/bin/sh

#  addlist_iptables.sh
#  
#
#  Created by HSP SI Viet Nam on 5/21/14.
#
tf=`echo $0`
read -p"Nhap Vao Duong Dan Danh Sach: " danhsach
if [ "$danhsach" = "" ]; then
echo " Danh Sach Khong Duoc La Rong. Dien Lai."
sh $tf
fi
for i in $( cat $danhsach );
do
checkmac=`cat /etc/sysconfig/iptables | grep FORWARD | grep mac | grep $i`
if [ "$checkmac" != "" ]; then
echo "Dia chi MAC: $i da co trong danh sach han che"
fi
iptables -t nat -A FORWARD -i eth2 -m mac --mac-source $i -j DROP
echo "$i Add";
done
echo "Success"
sleep 3
exit 1