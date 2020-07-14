#!/bin/sh
#
PASSWD=${ROOT_PASSWORD:-haohong}
echo "${PASSWD}" | passwd --stdin root
[ $? == 0 ]  && /usr/sbin/sshd -D -f /etc/ssh/sshd_config 
