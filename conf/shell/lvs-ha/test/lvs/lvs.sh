#!/bin/bash
# chekcout lvs RS host.
# autor: JackLi
# 20231010


VS_FILE='/etc/keepalived/conf.d/virtual_server/vs_*.conf'
RS_FILE='/etc/keepalived/conf.d/real_server/rs_*.conf'
IP_PREFIX='172.168.2.'
DATETIME='date +"%Y-%m-%d-%H:%M:%S"'
VS_MATCH_STRING='vs_'
RS_MATCH_STRING='rs_'
LOGFILE="`echo ~/lvs.log`"
VS_IP='' 
RS_IP1=''
STATE=''
RS_IP2=''
CURRENT_VS_PORT_FILELIST=''
CURRENT_RS_PORT_FILELIST=''
TAG=''


log(){
	if [ "$1" == "debug" ];then	
		echo -e "`${DATETIME}`: [DEBUG] $2" >> ${LOGFILE}
	elif [ "$1" == "info" ];then
		echo -e "`${DATETIME}`: [INFO] $2" >> ${LOGFILE}
	elif [ "$1" == "error" ];then	
		echo -e "`${DATETIME}`: [ERROR] $2" | tee -a ${LOGFILE}
	elif [ "$1" == "success" ];then	
		echo -e "`${DATETIME}`: [SUCCESS] $2" >> ${LOGFILE}
	elif [ "$1" == "title" ];then	
		echo -e "`${DATETIME}`: $2" >> ${LOGFILE}
	fi
}


list(){
	echo "-------------------------------"
	ipvsadm -ln
	echo "-------------------------------"
}

reload(){
	systemctl reload keepalived
	if [ $? == 0 ];then
		log info "systemctl reload keepalived successful."
	else
		log error "systemctl reload keepalived failure."
		exit 1
	fi
}

# 检查op和swap函数传递进来的参数是否合法
check(){
	VS_IP=$1
	RS_IP1=$2
	CURRENT_VS_PORT_FILELIST=`ls ${VS_FILE} | grep ${VS_MATCH_STRING}${IP_PREFIX}${VS_IP}`
	CURRENT_RS_PORT_FILELIST=`ls ${RS_FILE} | grep ${RS_MATCH_STRING}${IP_PREFIX}${RS_IP1}`
	VS_IP_FILE=(`ls ${VS_FILE} | grep ${IP_PREFIX}${VS_IP}`)

	if [[ ! ${VS_IP} =~ ^[0-9]{1,3}$ ]];then
		log error "VS_IP is incorrect, VS_IP={ 1..254 }"
		exit 1
	elif [[ ! ${RS_IP1} =~ ^[0-9]{1,3}$ ]];then
		log error "RS_IP1 is incorrect, RS_IP1={ 1..254 }"
		exit 1
	fi

	if [ -z "${CURRENT_VS_PORT_FILELIST}" ];then
		log error "variable CURRENT_VS_PORT_FILELIST is NULL, VirtualServer ${IP_PREFIX}${VS_IP} is not exists."
		exit 1
	fi

	if [ -z "${CURRENT_RS_PORT_FILELIST}" ];then
		log error "variable CURRENT_RS_PORT_FILELIST is NULL, RealServer ${IP_PREFIX}${RS_IP1} is not exists."
		exit 1
	fi

	# 函数控制参数
	if [ "$TAG" == "op" ];then
		STATE=$3

		if [ "${STATE}" != "on" -a "${STATE}" != "off" ];then
			log error "chekcout STATE is incorrect, STATE={ on | off }"
			exit 1
		fi
	elif [ "$TAG" == "swap" ];then
		RS_IP2=$3	
		CURRENT_RS2_PORT_FILELIST=`ls ${RS_FILE} | grep ${RS_MATCH_STRING}${IP_PREFIX}${RS_IP2}`

		if [[ ! ${RS_IP2} =~ ^[0-9]{1,3}$ ]];then
			log error "RS_IP2 is incorrect, RS_IP2={ 1..254 }"
			exit 1
		fi

		if [ ${RS_IP1} == ${RS_IP2} ];then
			log error "RS_IP1 == RS_IP2, not execute swap operation"
                        exit 1
		fi

		if [ -z "${CURRENT_RS2_PORT_FILELIST}" ];then
			log error "variable CURRENT_RS2_PORT_FILELIST is NULL, RealServer ${IP_PREFIX}${RS_IP2} is not exists."
			exit 1
		fi
	fi

	# 判断用户传入VS的配置文件中是否全部包含2个RS，否则退出
 	for i in ${VS_IP_FILE[*]};do
		grep 'include' $i | grep -E "${IP_PREFIX}${RS_IP1}" >& /dev/null && grep 'include' $i | grep -E "${IP_PREFIX}${RS_IP2}" >& /dev/null
		if [ ! $? == 0 ];then
			log error "VirtualServer does not contain all RealServer of $i"
	                exit 1
		fi 
	done
}


# 操作VS下某一RS主机进行上线或下线操作
op(){
	TAG="op"
	check $1 $2 $3

	log debug "###\n VS_IP: $VS_IP \n RS_IP1: $RS_IP1 \n STATE: $STATE \n CURRENT_VS_PORT_FILELIST: $CURRENT_VS_PORT_FILELIST \n###"

	if [ "${STATE}" == "on" ];then
		for i in ${CURRENT_VS_PORT_FILELIST};do
			log debug "opration VS file $i"
			# match all RS from files to make changes 
			grep ${RS_MATCH_STRING}${IP_PREFIX}${RS_IP1} $i >& /dev/null && sed -i "/${RS_MATCH_STRING}${IP_PREFIX}${RS_IP1}/{s/!\|#//g}" $i
			if [ $? == 0 ];then 
				log info "cancel comment { `grep ${RS_MATCH_STRING}${IP_PREFIX}${RS_IP1} $i` } successful."
			else
				log error "cancel comment { `grep ${RS_MATCH_STRING}${IP_PREFIX}${RS_IP1} $i` } failure." 
				exit 1
			fi
		done
	elif [ "${STATE}" == "off" ];then
		for i in ${CURRENT_VS_PORT_FILELIST};do
			log debug "opration VS file $i"
			# match all RS from files to make changes 
			sed -i "/${RS_MATCH_STRING}${IP_PREFIX}${RS_IP1}/{s/^/!/g}" $i
			if [ $? == 0 ];then 
				log info "comment { `grep ${RS_MATCH_STRING}${IP_PREFIX}${RS_IP1} $i` } successful."
			else
				log error "comment { `grep ${RS_MATCH_STRING}${IP_PREFIX}${RS_IP1} $i` } failure." 
				exit 1
			fi
		done
	fi
}

# 对两个RS进行上下线切换操作
swap(){
	# 传递tag
	TAG="swap"
	check $1 $2 $3
	log debug "###\n VS_IP: $VS_IP \n RS_IP1: $RS_IP1 \n RS_IP2: $RS_IP2 \n CURRENT_VS_PORT_FILELIST: $CURRENT_VS_PORT_FILELIST \n CURRENT_RS_PORT_FILELIST: $CURRENT_RS_PORT_FILELIST \n###"

	VS_PORT_LIST=(`ipvsadm -ln | grep TCP | grep ${IP_PREFIX}${VS_IP} | awk '{print $2}'`)
	VS_PORT_COUNT="${#VS_PORT_LIST[*]}"
	RS1_VLAUE=0
	RS2_VLAUE=0

	# 判断RS1和RS2是否一上一下状态
	for i in ${VS_PORT_LIST[*]};do
		ipvsadm -ln -t $i | grep ${IP_PREFIX}${RS_IP1} >& /dev/null && RS1_STATUS=1 || RS1_STATUS=0
		log debug "RS1_STATUS:$RS1_STATUS "

		ipvsadm -ln -t $i | grep ${IP_PREFIX}${RS_IP2} >& /dev/null && RS2_STATUS=1 || RS2_STATUS=0
		log debug "RS2_STATUS:$RS2_STATUS "

		if [ ${RS1_STATUS} == ${RS2_STATUS} -a ${RS1_STATUS} == 1 ];then
			log error "RS_IP1: ${IP_PREFIX}${RS_IP1} and RS_IP2: ${IP_PREFIX}${RS_IP2} is total online"
			exit 1
		elif [ ${RS1_STATUS} == ${RS2_STATUS} -a ${RS1_STATUS} == 0 ];then
			log error "RS_IP1: ${IP_PREFIX}${RS_IP1} and RS_IP2: ${IP_PREFIX}${RS_IP2} is total offline"
			exit 1
		fi
		
		if [ ${RS1_STATUS} -gt 0 ];then
			let RS1_VLAUE+=1
		fi

		if [ ${RS2_STATUS} -gt 0 ];then
			let RS2_VLAUE+=1
		fi
	done

	if [ ${RS1_VLAUE} -eq ${VS_PORT_COUNT} -a ${RS2_VLAUE} -eq 0 ];then
		log info "start execute swap, change ${IP_PREFIX}${RS_IP1} to off AND change ${IP_PREFIX}${RS_IP2} to on"
		op ${VS_IP} ${RS_IP1} off
		op ${VS_IP} ${RS_IP2} on
	elif [ ${RS1_VLAUE} -eq 0 -a ${RS2_VLAUE} -eq ${VS_PORT_COUNT} ];then
		log info "start execute swap, change ${IP_PREFIX}${RS_IP1} to on AND change ${IP_PREFIX}${RS_IP2} to off"
		op ${VS_IP} ${RS_IP1} on
		op ${VS_IP} ${RS_IP2} off
	else
		log error "execute swap operation failure!"
                exit 1	
	fi
}

status(){
	echo "-------------------------------"
	grep 'include' ${VS_FILE}
	echo "-------------------------------"
}

case $1 in
	list)
		list
	;;

	status)
		status
	;;

	op)
		if [ $# -gt 4 ];then echo '[ERROR] args is grant then 4.'; exit 1; fi;
		if [ -z "${2}" ];then echo 'METHOD args $1 is null' ; exit 1 
			elif [ -z "${3}" ];then echo 'METHOD args $2 is null' ; exit 1 
			elif [ -z "${4}" ];then echo 'METHOD args $3 is null' ; exit 1 
		fi

		log title '\n\n'
		log title '-------------------- STEP BEGIN --------------------'
		echo "`${DATETIME}`: [INFO] BEGIN list LVS info"
		list

		log debug "op $2 $3 $4"
		op $2 $3 $4
		reload
		sleep 1

		echo "`${DATETIME}`: [INFO] AFTER list LVS info"
		list
		log title '-------------------- STEP END --------------------'
	;;

	swap)
		if [ $# -gt 4 ];then echo '[ERROR] args is grant then 4.'; exit 1; fi;
		if [ -z "${2}" ];then echo 'METHOD args $1 is null' ; exit 1 
			elif [ -z "${3}" ];then echo 'METHOD args $2 is null' ; exit 1 
			elif [ -z "${4}" ];then echo 'METHOD args $3 is null' ; exit 1 
		fi

		log title '\n\n'
		log title '-------------------- STEP BEGIN --------------------'
		echo "`${DATETIME}`: [INFO] BEGIN list LVS info"
		list

		log debug "swap $2 $3 $4"
		swap $2 $3 $4
		reload
		sleep 1

		echo "`${DATETIME}`: [INFO] AFTER list LVS info"
		list
		log title '-------------------- STEP END --------------------'
	;;

	*)
		echo "Usage: $0 list | status | op VS_IP RS_IP STATE | swap VS_IP RS_IP1 RS_IP2"
		echo ''
		echo "VS_IP = 'virtual server ip address'"
		echo "RS_IP = 'real server ip address'"
		echo "STATE = { on | off }"
		echo ''
		echo "Example: $0 list"
		echo "Example: $0 status"
		echo "Example: $0 op 33 34 off"
		echo "Example: $0 op 33 35 on"
		echo "Example: $0 swap 33 34 35"
		echo ''
		exit 1
	;;	
esac
