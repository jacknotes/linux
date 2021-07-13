#!/bin/sh

if [[ -z $1 ]];then
	echo '$1 is null' 
	echo "Usage: $0 'from_files_command'"
	echo "Example: $0 'ls ./'"
	exit 1
fi

ADDRESS='http://localhost:8500/v1/agent/service/deregister'
DELETE_FROM_FILES=$1

for i in `eval ${DELETE_FROM_FILES}`;do
	CONSUL_OBJECT_ID=`cat $i | grep ID | awk -F '"' '{print $4}'`
	curl -X PUT ${ADDRESS}/${CONSUL_OBJECT_ID}
	if [ $? == 0 ];then
		echo "id: ${CONSUL_OBJECT_ID} is deregister successful."
	else
		echo "id: ${CONSUL_OBJECT_ID} is deregister failure."
	fi
done

echo ''	
echo "generate delete file command"
echo "-------------------------"
for i in `eval ${DELETE_FROM_FILES}`;do
	echo "rm -f ${i}"
done
echo "-------------------------"

