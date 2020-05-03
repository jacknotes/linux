#!/bin/sh

rabbitmqctl add_user admin password 
rabbitmqctl set_user_tags admin administrator 
rabbitmqctl set_permissions -p '/' admin '.*' '.*' '.*' 
