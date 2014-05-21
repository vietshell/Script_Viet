#!/bin/sh

#  delete_iptables.sh
#  
#
#  Created by HSP SI Viet Nam on 5/21/14.
#
df=`pwd`
tf=`echo $0`
read -p"Dia Chi MAC Can Remove: " macrm

if [ "$macrm" = "" ]; then
echo "Dia chi Mac khong duoc la rong, dien lai"
sh $tf
exit 1
fi
checkmac=`cat /etc/sysconfig/iptables | grep $macrm`
if [ "$checkmac" = "" ]; then
echo "Success"
exit 1
fi
iptables -t nat -D $( cat /etc/sysconfig/iptables | grep $macrm | sed 's/-A //' )
/etc/init.d/iptables save
exit 1