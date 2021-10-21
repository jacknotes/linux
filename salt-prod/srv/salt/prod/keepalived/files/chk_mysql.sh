#!/bin/bash
d=`date --date today +%Y%m%d_%H:%M:%S`
/usr/bin/netstat -tnlp | /usr/bin/grep :3306 >& /dev/null
if [ $? -ne '0' ];then
        /usr/bin/systemctl stop mysqld
	/usr/bin/systemctl start mysqld
	/usr/bin/netstat -tnlp | /usr/bin/grep :3306 >& /dev/null
        if [ $? -ne "0"  ]; then
                echo "$d: mysqld is down,keepalived will stop" >> /var/log/keepalived_chk_mysql.log
                /usr/bin/systemctl stop keepalived
        fi
fi

