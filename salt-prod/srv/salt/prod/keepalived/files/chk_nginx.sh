#!/bin/bash
d=`date --date today +%Y%m%d_%H:%M:%S`
[ `ps -C nginx --no-heading|wc -l` -gt 0 ] && curl -Is http://127.0.0.1:8443 | grep '200 OK'
if [ $? -ne '0' ];then
        systemctl restart nginx
	[ `ps -C nginx --no-heading|wc -l` -gt 0 ] && curl -Is http://127.0.0.1:8443 | grep '200 OK'
        if [ $? -ne "0"  ]; then
                echo "$d nginx down,keepalived will stop" >> /var/log/chk_nginx.log
                systemctl stop keepalived
        fi
fi
