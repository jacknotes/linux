#!/bin/bash
d=`date --date today +%Y%m%d_%H:%M:%S`
S_PRIO=80
M_PRIO=200
CONF=/etc/keepalived/keepalived.conf
flag=`cat /tmp/tag.number`
M=`/usr/local/redis/bin/redis-cli info replication | grep role | awk -F ':' '{print $2}'`
[ -f /tmp/tag.number ] || echo 0 > /tmp/tag.number
[ `netstat -tlp | awk '{print $4}' | grep ':6379'` ]  
if [ $? -ne '0' ];then
	sed -i "s/priority\ ${M_PRIO}/priority\ ${S_PRIO}/" ${CONF}
	sed -i "s/state MASTER/state BACKUP/" ${CONF}
	rm -f /tmp/tag.number
        echo "$d redis down,keepalived will stop" >> /var/log/chk_shell.log
        systemctl stop keepalived
elif [ `echo ${M} | grep 'slave'` ] && ([ ${flag} -eq 0 ] || [ ${flag} -eq 1 ]);then
	sed -i "s/priority\ ${M_PRIO}/priority\ ${S_PRIO}/" ${CONF}
	sed -i "s/state MASTER/state BACKUP/" ${CONF}
	echo "$d this node is redis slave,will this redis node change keepalived BACKUP" >> /var/log/chk_shell.log	
	echo 2 > /tmp/tag.number
	systemctl restart keepalived
elif [ `echo ${M} | grep 'master'` ] && ([ ${flag} -eq 0 ] || [ ${flag} -eq 2 ]);then
	sed -i "s/priority\ ${S_PRIO}/priority\ ${M_PRIO}/" ${CONF}
	sed -i "s/state BACKUP/state MASTER/" ${CONF}
	echo "$d this node is redis master,will this redis node change keepalived MASTER" >> /var/log/chk_shell.log	
	echo 1 > /tmp/tag.number
	systemctl restart keepalived
fi
