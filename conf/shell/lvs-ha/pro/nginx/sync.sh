#!/bin/bash
# sync nginx config to destiantion host


# require suffix '/*/'
NGINX_CONF='/usr/local/nginx/conf/'
NGINX_HTML='/usr/local/nginx/html/'
HOST=""
AUTH_PASSWORD="nginx"

auth(){
	read -s -t 30 -n 16 -p 'please input password:' CMD_PASSWORD
	if [ "${CMD_PASSWORD}" != "${AUTH_PASSWORD}" ];then
		echo -e '\n[ERROR]: password error!'
		exit 1
	else
		echo -e '\n[INFO]: password creect!'
	fi
}

check(){
	HOST="$1"
	ping -q -A -s 500 -W 1000 -c 2 ${HOST} >& /dev/null
	if [ $? != 0 ];then
		echo "[ERROR] DEST_HOST incrrect!"
		exit 1
	fi
}

sync(){
	rsync -avPz ${NGINX_CONF}* ${HOST}:${NGINX_CONF} >& /dev/null
	rsync -avPz ${NGINX_HTML}* ${HOST}:${NGINX_HTML} >& /dev/null
}

remote_reload(){
	ssh ${HOST} 'systemctl reload nginx' 
	if [ $? == 0 ];then
		echo "[INFO] relaod successful!"
	else
		echo "[ERROR] reload fail!"
		exit 1
	fi
}

case $1 in
	sync)
		echo '[INFO] start sync local nginx config file to remote host'
		auth		
		check $2
		sync
		remote_reload
	;;
	
	*)
		echo "Usage: $0 sync DEST_HOST "
		exit 1
	;;
esac

