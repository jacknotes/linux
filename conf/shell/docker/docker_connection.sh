#!/bin/bash
# description: show docker ESTABLISHED number
# author: jackli
# date: 20240320

CONTAINER_NAMES=`sudo docker ps | awk '{print $NF}' | grep -v NAMES`

for i in $CONTAINER_NAMES;do
        container_pid=`sudo docker inspect $i | grep -i 'pid"' | awk -F':' '{print $2}' | tr -dc '0-9'`
        echo "[INFO]: ${i}-PID-${container_pid}"
        #established_total=`sudo nsenter -t ${container_pid} -n netstat -antlp | grep ESTABLISHED | wc -l`
        #sudo nsenter -t ${container_pid} -n netstat -antlp | grep ESTABLISHED
        established_total=`sudo nsenter -t ${container_pid} -n netstat -antlp | grep ESTABLISHED | grep 10.10.10.201:9200 | wc -l`
        echo "[INFO]: established total: ${established_total}"
        sudo nsenter -t ${container_pid} -n netstat -antlp | grep ESTABLISHED | grep 10.10.10.201:9200
        #sleep 3
done