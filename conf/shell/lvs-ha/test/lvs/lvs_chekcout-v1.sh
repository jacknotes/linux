#!/bin/bash
# chekcout lvs RS host.
# autor: JackLi
# 20230928


VS_FILE='/etc/keepalived/conf.d/virtual_server/vs_*.conf'
RS_FILE='/etc/keepalived/conf.d/real_server/rs_*.conf'
IP_PREFIX='172.168.2.'
DATETIME='date +"%Y-%m-%d-%H:%M:%S"'
VS_MATCH_STRING='vs_'
RS_MATCH_STRING='rs_'


list(){
	echo "###############################"
	ipvsadm -ln
	echo "###############################"
}

checkout(){
	VS_IP=$1
	RS_IP=$2
	STATE=$3
	CURRENT_VS_PORT_FILELIST=`ls ${VS_FILE} | grep ${VS_MATCH_STRING}${IP_PREFIX}${VS_IP}`
	CURRENT_RS_PORT_FILELIST=`ls ${RS_FILE} | grep ${RS_MATCH_STRING}${IP_PREFIX}${RS_IP}`


	if [[ ! ${VS_IP} =~ ^[0-9]{1,3}$ ]];then
		echo "`${DATETIME}`: [ERROR] checkout VS_IP is incorrect, VS_IP={ 1..254 }"
		exit 1
	elif [[ ! ${RS_IP} =~ ^[0-9]{1,3}$ ]];then
		echo "`${DATETIME}`: [ERROR] checkout RS_IP is incorrect, RS_IP={ 1..254 }"
		exit 1
	elif [ "${STATE}" != "on" -a "${STATE}" != "off" ];then
		echo "`${DATETIME}`: [ERROR] chekcout STATE is incorrect, STATE={ on | off }"
		exit 1
	fi

	if [ -z "${CURRENT_VS_PORT_FILELIST}" ];then
		echo "`${DATETIME}`: [ERROR] variable CURRENT_VS_PORT_FILELIST is NULL, VirtualServer is not exists."
		exit 1
	fi
	if [ -z "${CURRENT_RS_PORT_FILELIST}" ];then
		echo "`${DATETIME}`: [ERROR] variable CURRENT_RS_PORT_FILELIST is NULL, RealServer is not exists."
		exit 1
	fi


	echo  "`${DATETIME}`: [INFO] BEGIN list LVS info"
	list

	if [ "${STATE}" == "on" ];then
		for i in ${CURRENT_VS_PORT_FILELIST};do
			echo "[DEBUG] $i"
			# match all RS from files to make changes 
			grep ${RS_MATCH_STRING}${IP_PREFIX}${RS_IP} $i && sed -i "/${RS_MATCH_STRING}${IP_PREFIX}${RS_IP}/{s/!\|#//g}" $i
			if [ $? == 0 ];then 
				echo  "`${DATETIME}`: [INFO] cancel comment { `grep ${RS_MATCH_STRING}${IP_PREFIX}${RS_IP} $i` } successful."
			else
				echo "`${DATETIME}`: [ERROR] cancel comment { `grep ${RS_MATCH_STRING}${IP_PREFIX}${RS_IP} $i` } failure." 
				exit 1
			fi
		done
	elif [ "${STATE}" == "off" ];then
		for i in ${CURRENT_VS_PORT_FILELIST};do
			echo "[DEBUG] $i"
			# match all RS from files to make changes 
			sed -i "/${RS_MATCH_STRING}${IP_PREFIX}${RS_IP}/{s/^/!/g}" $i
			if [ $? == 0 ];then 
				echo  "`${DATETIME}`: [INFO] comment { `grep ${RS_MATCH_STRING}${IP_PREFIX}${RS_IP} $i` } successful."
			else
				echo "`${DATETIME}`: [ERROR] comment { `grep ${RS_MATCH_STRING}${IP_PREFIX}${RS_IP} $i` } failure." 
				exit 1
			fi
		done
	fi

	systemctl reload keepalived
	if [ $? == 0 ];then
		echo "`${DATETIME}`: [INFO] systemctl reload keepalived successful."
	else
		echo "`${DATETIME}`: [ERROR] systemctl reload keepalived failure."
		exit 1
	fi

	echo  "`${DATETIME}`: [INFO] AFTER list LVS info"
	
	sleep 1
	list

}


case $1 in
	list)
		list
	;;

	co)
		if [ $# -gt 4 ];then echo '[ERROR] args is grant then 4.'; exit 1; fi;
		if [ -z "${2}" ];then echo 'checkout METHOD args $1 is null' ; exit 1 
			elif [ -z "${3}" ];then echo 'checkout METHOD args $2 is null' ; exit 1 
			elif [ -z "${4}" ];then echo 'checkout METHOD args $3 is null' ; exit 1 
		fi
		checkout $2 $3 $4
	;;

	*)
		echo "Usage: $0 list | co VS_IP RS_IP STATE"
		echo ''
		echo "VS_IP = 'virtual server ip address'"
		echo "RS_IP = 'real server ip address'"
		echo "STATE = { on | off }"
		echo ''
		echo "Example: $0 list"
		echo "Example: $0 co 33 34 off"
		echo "Example: $0 co 33 35 on"
		echo ''
		exit 1
	;;	
esac
