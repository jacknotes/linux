#!/bin/sh

systemctl restart rabbitmq-server.service 
rabbitmqctl stop_app  
rabbitmqctl join_cluster rabbit@{{ rabbitmqMaster  }} 
rabbitmqctl start_app
rabbitmqctl set_policy --vhost / --priority 10 --apply-to 'all' all ".*" '{"ha-mode":"all","ha-sync-mode":"automatic"}' 

