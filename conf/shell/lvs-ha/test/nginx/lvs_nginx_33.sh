#!/bin/bash
# lvs for nginx network operation shell.
# author: jackli
# date: 20230927
# chkconfig: 2345 90 10


INTERFACE='lo:'
VIP01='172.168.2.33'
VIP01_INTERFACE="${INTERFACE}0"
VIP_COUNT='1'
DATETIME='date +"%Y-%m-%d-%H:%M:%S"'


start(){
	sysctl -w net.ipv4.conf.eth0.arp_ignore=1 && \
	sysctl -w net.ipv4.conf.eth0.arp_announce=2 && \
	sysctl -w net.ipv4.conf.all.arp_ignore=1 && \
	sysctl -w net.ipv4.conf.all.arp_announce=2 && \
	ip address add ${VIP01}/32 broadcast ${VIP01} scope global dev ${VIP01_INTERFACE}
	ip route add ${VIP01}/32 dev ${VIP01_INTERFACE} 

	if [ $? == 0 ];then
		echo "`${DATETIME}`: [INFO] lvs nginx node newtork start successful."
	else
		echo "`${DATETIME}`: [ERROR] lvs nginx node newtork start failure."
	fi
}


stop(){
	ip route del ${VIP01}/32 dev ${VIP01_INTERFACE} 
	ip address del ${VIP01}/32 dev ${VIP01_INTERFACE}
	sysctl -w net.ipv4.conf.eth0.arp_ignore=0 && \
	sysctl -w net.ipv4.conf.eth0.arp_announce=0 && \
	sysctl -w net.ipv4.conf.all.arp_ignore=0 && \
	sysctl -w net.ipv4.conf.all.arp_announce=0

	if [ $? == 0 ];then
                echo "`${DATETIME}`: [INFO] lvs nginx node newtork stop successful."
        else
                echo "`${DATETIME}`: [ERROR] lvs nginx node newtork stop failure."
        fi
}


restart(){
	stop
	sleep 1
	start
}

status(){
	[ `route -n | grep -E "${VIP01}" | wc -l` == "${VIP_COUNT}" ] && \
	[ `ip address show ${INTERFACE} | grep -E "${VIP01}" | wc -l` == "${VIP_COUNT}" ]  && \
	[ `sysctl -n net.ipv4.conf.eth0.arp_ignore` == 1 ] && \
	[ `sysctl -n net.ipv4.conf.eth0.arp_announce` == 2 ] && \
	[ `sysctl -n net.ipv4.conf.all.arp_ignore` == 1 ] && \
	[ `sysctl -n net.ipv4.conf.all.arp_announce` == 2 ]

	if [ $? == 0 ];then
                echo "`${DATETIME}`: [INFO] lvs nginx node newtork is running."
        else
                echo "`${DATETIME}`: [INFO] lvs nginx node newtork is stop."
        fi

}

case "$1" in 
	start)
		start;;
	stop)
		stop;;
	restart)
		restart;;
	status)
		status;;
	*)
		echo "Usage: $0 { start | stop | restart | status}"	
	;;	

esac
