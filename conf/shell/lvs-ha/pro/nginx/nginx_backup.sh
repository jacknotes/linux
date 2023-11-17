#/bin/bash
#
# Description: backup nginx conf

VIP='192.168.13.207'
LOCAL_IP=`ip ad s eth0 | grep inet | awk -F'/' '{print $1}' | awk '{print $2}'`  # nginx01
LOCAL_DIRECTORY="/backup"
REMOTE_DIRECTORY="/winbackup"
LOCAL_NGINX_CONF_DIRECTORY="/usr/local/nginx/conf"
LOCAL_NGINX_HTML_DIRECTORY="/usr/local/nginx/html"
CPDATE=$(date +%Y-%m-%d-%H%M%S)

/bin/mkdir -p ${LOCAL_DIRECTORY} && \
/bin/cp -a /usr/local/nginx/conf/nginx.conf ${LOCAL_DIRECTORY}/nginx.conf-$CPDATE && \
/bin/cp -a /usr/local/nginx/conf/conf.d ${LOCAL_DIRECTORY}/conf.d-$CPDATE && \
/usr/bin/rsync -avPz ${LOCAL_DIRECTORY}/* ${LOCAL_NGINX_CONF_DIRECTORY} ${LOCAL_NGINX_HTML_DIRECTORY} ${REMOTE_DIRECTORY}/${VIP}/${LOCAL_IP}/

if [[ $? = 0 ]];then 
	logger "backup $LOCAL_IP nginx conf successful"
	find ${LOCAL_DIRECTORY}/ -mtime +30 -exec rm -rf {} \;
else
	logger "backup $LOCAL_IP nginx conf failure"
	exit 1	
fi
