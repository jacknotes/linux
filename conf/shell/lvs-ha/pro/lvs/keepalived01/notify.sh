#!/bin/bash
#
contact='jack.li@homsom.com'
INTERFACE_NAME=`grep interface /etc/keepalived/keepalived.conf | awk '{print $2}' | head -n 1`
INTERFACE_NAME_IPADDR=`ip a s ${INTERFACE_NAME} | grep 192.168.13.255 | awk -F '/' '{print $1}' | awk '{print $2}'`
notify() {
local mailsubject="$(hostname) to be $1, vip floating"
local mailbody="$(date +'%F %T'): vrrp transition, $(hostname)-${INTERFACE_NAME_IPADDR} changed to be $1 for VIP $2"
echo "$mailbody" | mail -s "$mailsubject" $contact
}
  
case $1 in
master)
        notify master $2
        ;;
backup)
        notify backup $2
        ;;
fault)
        notify fault $2
        ;;
*)
        echo "Usage: $(basename $0) {master|backup|fault} ARG2"
        exit 1
        ;;
esac
