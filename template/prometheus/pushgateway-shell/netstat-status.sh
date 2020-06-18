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
PushgatewayServer="192.168.15.201:9091"

netstat_listen_label="netstat_listen_count" 
netstat_listen_value=`netstat -natu | grep -ic listen`
echo "${netstat_listen_label} ${netstat_listen_value}"
netstat_established_label="netstat_established_connections" 
netstat_established_value=`netstat -natu | grep -ic established`
echo "${netstat_established_label} ${netstat_established_value}"
netstat_wait_label="netstat_wait_connections" 
netstat_wait_value=`netstat -na | grep -ic wait`
echo "${netstat_wait_label} ${netstat_wait_value}"

#"--data-binary" default is POST method,"@-" is from file and stdin input,"http://${PushgatewayServer}/metrics/job/pushgateway" is pushgateway address and job_name,"instance/${instance_name}" is set K/V,K=instance,V=${instance_name}
cat << EOF | curl --data-binary @- http://${PushgatewayServer}/metrics/job/pushgateway/instance/${instance_name}
# TYPE ${netstat_listen_label} gauge
${netstat_listen_label} ${netstat_listen_value}
# TYPE ${netstat_established_label} gauge
${netstat_established_label} ${netstat_established_value}
# TYPE ${netstat_wait_label} gauge
${netstat_wait_label} ${netstat_wait_value}
EOF
