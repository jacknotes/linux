#!/bin/sh
#
echo 'export PATH=$PATH:/usr/local/nginx/sbin/:/usr/local/jdk/bin/:/usr/local/redis/bin/' > /etc/profile.d/root.sh

#redis-server start
redis-server /usr/local/redis/redis.conf
#nginx start
nginx

PASSWD=${ROOT_PASSWORD:-haohong}
echo "${PASSWD}" | passwd --stdin root
[ $? == 0 ]  && /usr/sbin/sshd -D -f /etc/ssh/sshd_config 