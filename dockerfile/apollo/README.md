#install step
#Environment: CentOS-7.6,Linux node2 3.10.0-957.el7.x86_64
#Author: Jackli
#Email: jacknotes@163.com
---------------START------------------
#mysql5.7
[root@node2 ~]# docker pull 192.168.15.200:8888/zabbix/mysql:5.7
[root@node2 /opt]# docker run -d --name mysql --hostname mysql --restart always -m 1G -e MYSQL_ROOT_PASSWORD=123456 -v /data/docker/mysql:/var/lib/mysql -p 3307:3306 192.168.15.200:8888/zabbix/mysql:5.7 --character-set-server=utf8 --collation-server=utf8_bin
[root@node2 /opt]# docker cp /download/apollo/scripts/sql mysql:/tmp
#导入apollo数据库表结构
[root@node2 /opt]# docker exec mysql mysql -uroot -p123456 -e 'source /tmp/sql/apolloconfigdb.sql'
[root@node2 /opt]# docker exec mysql mysql -uroot -p123456 -e 'source /tmp/sql/apolloportaldb.sql'
#设置密码
[root@node1 ~]# docker exec mysql mysql -uroot -p123456 -e "grant all on ApolloConfigDB.* to apollo@'%' identified by 'apollo';"
[root@node1 ~]# docker exec mysql mysql -uroot -p123456 -e "grant all on ApolloPortalDB.* to apollo@'%' identified by 'apollo';"
--以上是详细步骤，以下是自己封装的mysql镜像后快速步骤

#run apollo-mysql
docker run -d --name mysql --hostname mysql --restart always -p 3307:3306 -e MYSQL_USER=apollo -e MYSQL_PASSWD=apollo -v /data/docker/mysql:/var/lib/mysql apollo-mysql:v8
--${MYSQL_USER} ${MYSQL_PASSWD}变量是设定apollo mysql访问用户名及密码

#run apollo-adminservice
docker run -d --link mysql --name apollo-adminservice -p 8090:8090 -v /data/docker/apollo-adminservice/logs:/opt/logs -e MYSQL_SERVER=mysql -e MYSQL_USER=apollo -e MYSQL_PASSWD=apollo  apollo-adminservice-1.7.0:v2

#run apollo-configservice
docker run -d --link mysql --name apollo-configservice -p 8080:8080 -v /data/docker/apollo-configservice/logs:/opt/logs -e MYSQL_SERVER=mysql -e MYSQL_USER=apollo -e MYSQL_PASSWD=apollo  apollo-configservice-1.7.0:v1

#run apollo-portal
docker run -d --link mysql --name apollo-portal -p 8070:8070 -v /data/docker/apollo-portal/logs:/opt/logs -e MYSQL_SERVER=mysql -e MYSQL_USER=apollo -e MYSQL_PASSWD=apollo -e pro_meta=http://192.168.15.202:8080  apollo-portal-1.7.0:v2

#容器启动后续设置
#portalDB进行环境配置
select * from `ApolloPortalDB`.`ServerConfig` 
update `ApolloPortalDB`.`ServerConfig` set `value`='pro' where `key` = 'apollo.portal.envs'
#configDB进行环境配置
select * from `ApolloConfigDB`.`ServerConfig`
update `ApolloConfigDB`.`ServerConfig` set `value`='http://192.168.15.202:8080/eureka/' where `key`='eureka.service.url'
#以上数据库配置好后需要重启portal服务。
docker restart apollo-portal


---------apollo-adminservice变量----------------
[root@node2 /download/docker-apollo]# cat apollo-adminservice/application-github.properties 
# DataSource
spring.datasource.url = jdbc:mysql://${MYSQL_SERVER}:3306/ApolloConfigDB?characterEncoding=utf8
spring.datasource.username = ${MYSQL_USER}
spring.datasource.password = ${MYSQL_PASSWD}
-------------------------------------------------
---------apollo-adminservice变量----------------
[root@node2 /download/docker-apollo]# cat apollo-configservice/application-github.properties 
# DataSource
spring.datasource.url = jdbc:mysql://${MYSQL_SERVER}:3306/ApolloConfigDB?characterEncoding=utf8
spring.datasource.username = ${MYSQL_USER}
spring.datasource.password = ${MYSQL_PASSWD}
-------------------------------------------------
--------------apollo-portal变量------------------
[root@node2 /download/docker-apollo]# cat apollo-portal/apollo-env.properties 
dev.meta=${dev_meta}
fat.meta=${fat_meta}
uat.meta=${uat_meta}
lpt.meta=${lpt_meta}
pro.meta=${pro_meta}
[root@node2 /download/docker-apollo]# cat apollo-portal/application-github.properties 
# DataSource
spring.datasource.url = jdbc:mysql://${MYSQL_SERVER}:3306/ApolloPortalDB?characterEncoding=utf8
spring.datasource.username = ${MYSQL_USER}
spring.datasource.password = ${MYSQL_PASSWD}
-------------------------------------------------
-----------------------END-----------------------
