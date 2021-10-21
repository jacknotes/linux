#!/bin/bash
set -e
 
#查看mysql服务的状态，方便调试，这条语句可以删除
echo `service mysql status`
 
echo '1.启动mysql....'
#启动mysql
service mysql start
sleep 1
echo `service mysql status`
 
echo '2.开始导入数据....'
#导入数据
mysql < /mysql/apolloconfigdb.sql
sleep 1
mysql < /mysql/apolloportaldb.sql
echo '3.导入数据完毕....'
 
echo `service mysql status`
 
#重新设置mysql密码
if [ ! -z ${MYSQL_USER} ] && [ ! -z ${MYSQL_PASSWD} ];then
	echo '4.开始修改密码....'
	sed -i "s/\${user}/${MYSQL_USER}/g" /mysql/user.sql
	sed -i "s/\${passwd}/${MYSQL_PASSWD}/g" /mysql/user.sql
	mysql < /mysql/user.sql
	echo '5.修改密码完毕....'
fi
 
echo `service mysql status`
echo `mysql容器启动完毕,且数据导入成功`
 
tail -f /dev/null
