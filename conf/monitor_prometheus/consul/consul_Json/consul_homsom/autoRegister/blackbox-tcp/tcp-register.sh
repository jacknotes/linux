#!/bin/sh
# description: the shell is auto generate json file and auto register to consul server.
# time: 202104091312

ROSTER_NAME=./roster-register
TCP_NUMBER=`cat ${ROSTER_NAME} | grep -v '^$' | wc -l`
TMP_DIR=./tmp
TEMPLATE_FILE=./template.json
TEMPLATE_STATEMENT_ip='ip'
TEMPLATE_STATEMENT_port='port'
TEMPLATE_STATEMENT_app='sshd'
FILR_PREFIX='consul-blackbox_tcp-'
FILE_SUBFIX='.json'
CONSUL_REGISTER_ADDRESS='http://localhost:8500/v1/agent/service/register'
FILE_HOME=/usr/local/consul/consul_homsom/blackbox_tcp


mkdir -p ${TMP_DIR}

for i in `seq 1 ${TCP_NUMBER}`;do 
	CURRENT_NUMBER=`sed -n "${i}p" ${ROSTER_NAME}`
	COLUMN_TCP=`sed -n "${i}p" ${ROSTER_NAME}| awk '{print $1}'` 
	COLUMN_TCP_IP=`sed -n "${i}p" ${ROSTER_NAME}| awk '{print $1}' | awk -F ':' '{print $1}'`
	COLUMN_TCP_PORT=`sed -n "${i}p" ${ROSTER_NAME}| awk '{print $1}' | awk -F ':' '{print $2}'`
	COLUMN_MIRROR_ADDRESS=`sed -n "${i}p" ${ROSTER_NAME}| awk '{print $2}'`
	NEW_FILENAME=${TMP_DIR}/${FILR_PREFIX}${COLUMN_TCP_IP}:${COLUMN_TCP_PORT}${FILE_SUBFIX}
	FILENAME=${FILR_PREFIX}${COLUMN_TCP_IP}:${COLUMN_TCP_PORT}${FILE_SUBFIX}
	cp ${TEMPLATE_FILE} ${NEW_FILENAME}
	sed -i "s#${TEMPLATE_STATEMENT_ip}#${COLUMN_TCP_IP}#g" ${NEW_FILENAME}
	sed -i "s#${TEMPLATE_STATEMENT_port}#${COLUMN_TCP_PORT}#g" ${NEW_FILENAME}
	sed -i "s#${TEMPLATE_STATEMENT_app}#${COLUMN_MIRROR_ADDRESS}#g" ${NEW_FILENAME}
	if [ $? == 0 ];then
		echo "generate json file(${NEW_FILENAME}) successful."
		curl -X PUT --data @${NEW_FILENAME} ${CONSUL_REGISTER_ADDRESS}
		if [ $? == 0 ];then
			echo "Service: ${COLUMN_TCP_IP}:${COLUMN_TCP_PORT} register successful."
			mv -f ${NEW_FILENAME} ${FILE_HOME}
			[ $? == 0 ] && echo "save file(${FILENAME}) in current directory successful." || echo "save file(${FILENAME}) in current directory failure."
		else
			echo "Service: ${COLUMN_TCP_IP}:${COLUMN_TCP_PORT} register failure."
		fi
	else
		echo "generate json file(${NEW_FILENAME}) failure."
	fi
	echo ''
done

if [ $? == 0 ]; then
	rm -rf ${TMP_DIR}
	[ $? == 0 ] && echo "${TMP_DIR} delete successful." || echo "${TMP_DIR} delete failure."
fi
