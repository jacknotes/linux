#!/bin/bash

### 1. ipset config
# sudo ipset destroy blacklist
# sudo ipset create blacklist hash:ip maxelem 1000000
# sudo ipset create whitelist hash:ip maxelem 1000000
# sudo ipset add whitelist 222.66.21.210
# sudo ipset add blacklist 47.103.112.73
# sudo ipset list
# sudo ipset save whitelist -f /root/iptables/whitelist.txt
# sudo ipset restore -! -f /root/iptables/whitelist.txt


### 2. iptables config
## create whitelist rule
# sudo iptables -I INPUT 1 -m set --match-set whitelist src -p tcp --dport 8022 -j ACCEPT
## create blacklist rule
# sudo iptables -I INPUT 2 -m set --match-set blacklist src -p tcp --dport 8022 -j DROP




SSH_LOGIN_FILE='/var/log/secure'
IPTABLE_LOG_PREFIX='authentication failure;'
IPTABLES_LOG_FILE='/root/iptables/iptables-ssh.log'


#filter ip to file
grep -i 'authentication failure;' ${SSH_LOGIN_FILE} | awk -F 'rhost=' '{print $2}' | awk -F ' ' '{print $1}' | sort -d | uniq -c > ${IPTABLES_LOG_FILE}
 
#add ip to blacklist
sudo grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' ${IPTABLES_LOG_FILE} | awk '{print "sudo ipset add -! blacklist",$0}' | sh
 
