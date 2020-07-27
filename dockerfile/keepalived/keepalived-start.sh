#!/bin/sh
#
VIRTUAL_IP=192.168.15.50
INTERFACE=eth0
NETMASK_BIT=24
CHECK_PORT=6444
RID=60
VRID=120
MCAST_GROUP=244.0.0.18

docker run -d --restart=always --name=keepalived-k8s \
	--net=host --cap-add=NET_ADMIN \
	-e VIRTUAL_IP=$VIRTUAL_IP \
	-e INTERFACE=$INTERFACE \
	-e NETMASK_BIT=$NETMASK_BIT \
	-e CHECK_PORT=$CHECK_PORT \
	-e RID=$RID \
	-e VRID=$VRID \
	-e MCAST_GROUP=$MCAST_GROUP \
	192.168.15.200:8888/k8s/keepalived-k8s:latest
