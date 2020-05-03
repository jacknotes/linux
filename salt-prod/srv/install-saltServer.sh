#!/bin/sh
#
sudo yum install -y https://repo.saltstack.com/py3/redhat/salt-py3-repo-latest.el7.noarch.rpm
sudo yum clean expire-cache
sudo yum install -y salt-master salt-minion
sudo systemctl start salt-master
sudo systemctl enable salt-master

CARD=''
for i in ens33 eth0;do
   ip add show ${i} >& /dev/null  && CARD=${i} 
done
IPADDR=$(ip add show ${CARD} | grep 'inet ' | sed 's/\// /g' | awk '{print $2}')
sed -i "s/#master: salt/master: ${IPADDR}/" /etc/salt/minion
sudo systemctl restart salt-minion
sudo systemctl enable salt-minion
