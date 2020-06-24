#!/bin/bash
Spriority="priority 150"  #priority master and backup unlike
Cpriority="priority 10"   #priority master and backup unlike
CONF='/etc/keepalived/keepalived.conf'
d=`date --date today +%Y%m%d_%H:%M:%S`
[ `ps -C nginx --no-heading|wc -l` -gt 0 ] && curl -Is http://127.0.0.1 | grep '200 OK'
if [ $? -ne '0' ];then
        systemctl restart nginx
	[ `ps -C nginx --no-heading|wc -l` -gt 0 ] && curl -Is http://127.0.0.1 | grep '200 OK'
        if [ $? -ne "0"  ]; then
                echo "$d nginx is down,keepalived will change BACKUP" >> /var/log/chk_nginx.log
		sed -i "s/${Spriority}/${Cpriority}/g" ${CONF}
                systemctl reload keepalived
        fi
else
        grep "${Spriority}" ${CONF}
        if [ $? -ne '0' ];then
                echo "$d nginx is up,keepalived will change MASTER" >> /var/log/chk_nginx.log
                sed -i "s/${Cpriority}/${Spriority}/g" ${CONF}
                systemctl reload keepalived
	fi
fi
