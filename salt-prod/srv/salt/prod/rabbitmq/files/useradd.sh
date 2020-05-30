#!/bin/sh

#rabbitmqctl clear_password guest
rabbitmqctl change_password guest password
rabbitmqctl add_user admin password 
rabbitmqctl set_user_tags admin administrator 
rabbitmqctl set_permissions -p '/' admin '.*' '.*' '.*' 
