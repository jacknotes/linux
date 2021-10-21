#!/bin/bash
#description: will localhost tcp and udp LISTEN status count to pushgateway
#author: jackli
#date: 2020-06-08
#email: jacknotes@163.com

instance_name=$(hostname -f | cut -d '.' -f 1)
if [ ${instance_name} == "localhost" ];then
	echo "hostanem Must FQDN"
	exit 1
fi

PingServer="192.168.15.201"
PushgatewayServer="192.168.15.201:9091"
ping_result=`ping -q -A -s 500 -W 1000 -c 100 ${PingServer}` 
if [ $? != 0 ];then 
	echo "hostname not result,ping failure"
	exit 1
fi
ping_value=`ping -q -A -s 500 -W 1000 -c 100 ${PingServer} | grep rtt | awk -F '=' '{print $2}' | awk -F '/' '{sub(/\ /,"");print $1,$2,$3}'`

#get min,avg,max delay value
ping_delay_min=`echo $ping_value | awk '{print $1}'`
ping_delay_avg=`echo $ping_value | awk '{print $2}'`
ping_delay_max=`echo $ping_value | awk '{print $3}'`

#ping loss rate
ping_loss_lable="ping_loss" 
ping_loss_value=`ping -q -A -s 500 -W 1000 -c 100 ${PingServer} | grep loss | awk -F ',' '{print $3}' | awk '{sub(/%/,"");print $1}'`
echo "${ping_loss_lable} ${ping_loss_value}"

#ping delay value,unit is ms
ping_delay_lable="ping_delay" 
ping_delay_value=${ping_delay_avg}
echo "${ping_delay_lable} ${ping_delay_value}"

#ping zheng and fu shake value,unit is ms
ping_shake_zheng_lable="ping_shake_zheng" 
ping_shake_zheng_value=`echo "scale=3; $ping_delay_max-$ping_delay_avg" | bc`
ping_shake_fu_lable="ping_shake_fu" 
#ping_shake_fu_value=`echo "scale=3; $ping_delay_min-$ping_delay_avg" | bc | awk '{sub(/\-/,"");print $NF}'`
ping_shake_fu_value=`echo "scale=3; $ping_delay_min-$ping_delay_avg" | bc`
echo "${ping_shake_zheng_lable} ${ping_shake_zheng_value}"
echo "${ping_shake_fu_lable} ${ping_shake_fu_value}"

#"--data-binary" default is POST mode,"@-" is from file and stdin input,"http://${PushgatewayServer}/metrics/job/pushgateway" is pushgateway address and job_name,"instance/${instance_name}" is set K/V,K=instance,V=${instance_name}
cat << EOF | curl --data-binary @- http://${PushgatewayServer}/metrics/job/pushgateway/instance/${instance_name}
# TYPE ${ping_loss_lable} gauge
# HELP ${ping_loss_lable} loss package rate
${ping_loss_lable} ${ping_loss_value}
# TYPE ${ping_delay_lable} gauge
# HELP ${ping_delay_lable} delay avg time,unit is ms
${ping_delay_lable} ${ping_delay_value}
# TYPE ${ping_shake_zheng_lable} gauge
# HELP ${ping_shake_zheng_lable} shake zheng time,unit is ms
${ping_shake_zheng_lable} ${ping_shake_zheng_value}
# TYPE ${ping_shake_fu_lable} gauge
# HELP ${ping_shake_fu_lable} shake fu time,unit is ms
${ping_shake_fu_lable} ${ping_shake_fu_value}
EOF
