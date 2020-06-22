#Apollo Config Center
<pre>
refrence: https://github.com/ctripcorp/apollo/wiki/%E5%88%86%E5%B8%83%E5%BC%8F%E9%83%A8%E7%BD%B2%E6%8C%87%E5%8D%97
#注：一个环境一个节点，例如FAT：192.168.1.1，UAT:192.168.1.10,PRO:192.168.1.20, portal:192.168.1.100.为实现双活，可以一个环境多个节点，例如：FAT:192.168.1.1，192.168.1.2 UAT:192.168.1.10,192.168.1.11  PRO:192.168.1.20,192.168.1.21,portal:192.168.1.100(无论如何，portal只有一个节点)
#config和admin注意事项：当一个环境多个节点时，需要在每节点中的ApolloConfigDB.ServerConfig表中设置eureka.service.url的值为每个节点的configService地址，因为apollo-configservice本身就是一个eureka服务，所以只需要填入apollo-configservice的地址即可，并且以/eureka/后缀结束，这个表明每个节点都要向eureka服务注册
#portal注意事项：ApolloPortalDB.ServerConfig表中，也可以通过管理员工具 - 系统参数页面进行配置，无特殊说明则修改完一分钟实时生效。apollo.portal.envs默认值是dev，如果portal需要管理多个环境的话，以逗号分隔即可（大小写不敏感）修改完需要重启生效。Apollo Portal需要在不同的环境访问不同的meta service(apollo-configservice)地址,所以apollo.portal.meta.servers就是config service的地址，例如：{
    "FAT":"http://node1:8080",
    "PRO":"http://node2:8080"
}

#规划：
node2: 192.168.15.202 #portal服务器，pro环境
node1: 192.168.15.201 #fat环境
#apollo配置中心安装和部署(node2)
1. 获取安装包或源码
	1. https://github.com/ctripcorp/apollo/releases #下载github释放的版本或clone源码
	2. https://gitee.com/nobodyiam/apollo?_from=gitee_search #clone码云(gitee)上的源码
[root@node2 /download]# git clone https://gitee.com/nobodyiam/apollo.git
#安装java1.8+和mysql5.6.0+
#jdk安装
[root@node2 /download]# cd /download/tar xf jdk-8u201-linux-x64.tar.gz -C /usr/local/
[root@node2 /download]# cd /download/ln -sv /usr/local/jdk1.8.0_201/ /usr/local/jdk
[root@node2 /download]# cd /download/echo 'PATH=$PATH:/usr/local/jdk/bin' > /etc/profile.d/jdk.sh
[root@node2 /download]# source /etc/profile
[root@node2 /download]# java -version
java version "1.8.0_201"
Java(TM) SE Runtime Environment (build 1.8.0_201-b09)
Java HotSpot(TM) 64-Bit Server VM (build 25.201-b09, mixed mode)
#mysql安装 
[root@node2 /download]# tar xf mysql-5.6.48-linux-glibc2.12-x86_64.tar.gz  -C /usr/local/
[root@node2 /download]# ln -sv /usr/local/mysql-5.6.48-linux-glibc2.12-x86_64/ /usr/local/mysql
[root@node2 /download]# echo 'PATH=$PATH:/usr/local/mysql/bin' > /etc/profile.d/mysql.sh
[root@node2 /download]# mkdir -p /data/mysql
[root@node2 /download]# chown -R root.mysql /data/mysql/
[root@node2 /download]# chmod -R 775 /data/mysql/
[root@node2 /download]# chown -R root.mysql /usr/local/mysql-5.6.48-linux-glibc2.12-x86_64/
[root@node2 /download]# chmod -R 775 /usr/local/mysql-5.6.48-linux-glibc2.12-x86_64/
[root@node2 /download]# yum install -y autoconf
[root@node2 /usr/local/mysql/scripts]# ./mysql_install_db --datadir=/data/mysql --user=mysql --basedir=/usr/local/mysql
[root@node2 /usr/local/mysql]# cp support-files/mysql.server /etc/init.d/
[root@node2 /usr/local/mysql]# cat /etc/my.cnf
-----------
[client]
socket = /tmp/mysql.sock

[mysqld]
basedir = /usr/local/mysql
datadir = /data/mysql
port = 3306
server_id = 1
socket = /tmp/mysql.sock

join_buffer_size = 4M
sort_buffer_size = 2M
read_rnd_buffer_size = 2M 
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES,ANSI_QUOTES
default_storage_engine = INNODB
thread_concurrency = 10
innodb_read_io_threads = 6
innodb_write_io_threads = 6
innodb_flush_log_at_trx_commit =1
innodb_log_buffer_size = 16M
innodb_log_file_size = 5M
innodb_log_files_in_group = 2
innodb_file_per_table = 1
innodb_buffer_pool_size = 300M
transaction-isolation = REPEATABLE-READ
binlog_format = MIXED
log_bin = mysql-binlog
slow_query_log_file = /data/mysql/mysql-slow.log
slow_query_log = 1
log_error = /data/mysql/mysql.err
-----------
[root@node2 /usr/local/mysql]# /etc/init.d/mysql.server start
[root@node2 /usr/local/mysql]# chkconfig --add mysql.server
[root@node2 /usr/local/mysql]# chkconfig --level 35 mysql.server on
[root@node2 /usr/local/mysql]# netstat -tnlp | grep 3306
tcp6       0      0 :::3306                 :::*                    LISTEN      7253/mysqld
[root@node2 /usr/local/mysql]# mysqld -V
mysqld  Ver 5.6.48 for linux-glibc2.12 on x86_64 (MySQL Community Server (GPL))
#创建数据库并导入表结构
mysql> source /download/apollo/scripts/sql/apolloportaldb.sql #导入portalDB
mysql> source /download/apollo/scripts/sql/apolloconfigdb.sql #导入configDB
mysql> grant all on ApolloPortalDB.* to apollo@'localhost' identified by 'apollo';
Query OK, 0 rows affected (0.00 sec)
mysql> grant all on ApolloConfigDB.* to apollo@'localhost' identified by 'apollo';
Query OK, 0 rows affected (0.00 sec)

#编辑和打包apollo
[root@node2 /download/apollo/scripts]# vim /download/apollo/scripts/build.sh
---------------------
#!/bin/sh

# apollo config db info
apollo_config_db_url=jdbc:mysql://localhost:3306/ApolloConfigDB?characterEncoding=utf8 #更改configdb的数据库连接信息
apollo_config_db_username=apollo
apollo_config_db_password=apollo

# apollo portal db info
apollo_portal_db_url=jdbc:mysql://localhost:3306/ApolloPortalDB?characterEncoding=utf8 #更改portaldb的数据库连接信息
apollo_portal_db_username=apollo
apollo_portal_db_password=apollo

# meta server url, different environments should have different meta server addresses #设置常用的环境，目前只支持DEV,FAT,UAT,PRO，如果需要自定义别的环境，请参考github上的官方文档
fat_meta=http://node1:8080
pro_meta=http://node2:8080

META_SERVERS_OPTS="-Dfat_meta=$fat_meta -Dpro_meta=$pro_meta"  #这里引用也要修改，与上对应
---------------------
[root@node2 /download/apollo/scripts]# yum install -y maven #安装源码所需编译工具
[root@node2 /download/apollo/scripts]# vim /etc/maven/settings.xml #在文件里配置mirrors的子节点，添加如下mirror，使用国内阿里源编译和打包会很快
---------------------
    <mirror>
                <id>nexus-aliyun</id>
                <mirrorOf>*</mirrorOf>
                <name>Nexus aliyun</name>
                <url>http://maven.aliyun.com/nexus/content/groups/public</url>
    </mirror>
---------------------
[root@node2 ~]# /download/apollo/scripts/build.sh #执行编译、打包
#注：该脚本会依次打包apollo-configservice, apollo-adminservice, apollo-portal。打好的包在/download/apollo/下的各项目下target文件夹中
[root@node2 /download/apollo/scripts]# ls /download/apollo/apollo-configservice/target/  
#apollo-configservice-1.7.0-SNAPSHOT-github.zip 是我们需要的包
apollo-configservice-1.7.0-SNAPSHOT-github.zip    archive-tmp             maven-archiver
apollo-configservice-1.7.0-SNAPSHOT.jar           classes                 maven-status
apollo-configservice-1.7.0-SNAPSHOT.jar.original  generated-sources       test-classes
apollo-configservice-1.7.0-SNAPSHOT-sources.jar   generated-test-sources
[root@node2 /download/apollo/scripts]# ls /download/apollo/apollo-adminservice/target/
#apollo-adminservice-1.7.0-SNAPSHOT-github.zip  是我们需要的包
apollo-adminservice-1.7.0-SNAPSHOT-github.zip    archive-tmp             maven-archiver
apollo-adminservice-1.7.0-SNAPSHOT.jar           classes                 maven-status
apollo-adminservice-1.7.0-SNAPSHOT.jar.original  generated-sources       test-classes
apollo-adminservice-1.7.0-SNAPSHOT-sources.jar   generated-test-sources
[root@node2 /download/apollo/scripts]# ls /download/apollo/apollo-portal/target/
#apollo-portal-1.7.0-SNAPSHOT-github.zip  是我们需要的包
apollo-portal-1.7.0-SNAPSHOT-github.zip    archive-tmp             maven-archiver
apollo-portal-1.7.0-SNAPSHOT.jar           classes                 maven-status
apollo-portal-1.7.0-SNAPSHOT.jar.original  generated-sources       test-classes
apollo-portal-1.7.0-SNAPSHOT-sources.jar   generated-test-sources

#部署Apollo服务端
将对应环境的apollo-configservice-x.x.x-github.zip上传到服务器上，解压后执行scripts/startup.sh即可。如需停止服务，执行scripts/shutdown.sh.
#复制包到目标路径
[root@node2 /download/apollo]# mkdir -p /opt/apollosrv/{config,admin,portal}
[root@node2 /download/apollo]# cp /download/apollo/apollo-configservice/target/apollo-configservice-1.7.0-SNAPSHOT-github.zip /opt/apollosrv/config/
[root@node2 /download/apollo]# cp /download/apollo/apollo-adminservice/target/apollo-adminservice-1.7.0-SNAPSHOT-github.zip /opt/apollosrv/admin/
[root@node2 /download/apollo]# cp /download/apollo/apollo-portal/target/apollo-portal-1.7.0-SNAPSHOT-github.zip /opt/apollosrv/portal/
[root@node2 /download/apollo]# cd /opt/apollosrv/config && unzip apollo-configservice-1.7.0-SNAPSHOT-github.zip
[root@node2 /download/apollo]# cd /opt/apollosrv/admin && unzip apollo-adminservice-1.7.0-SNAPSHOT-github.zip
[root@node2 /download/apollo]# cd /opt/apollosrv/portal && unzip apollo-portal-1.7.0-SNAPSHOT-github.zip
记得在scripts/startup.sh中按照实际的环境设置一个JVM内存，以下是默认设置，供参考：
export JAVA_OPTS="-server -Xms6144m -Xmx6144m -Xss256k -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=384m -XX:NewSize=4096m -XX:MaxNewSize=4096m -XX:SurvivorRatio=18"
#配置启动configservice
[root@node2 /download/apollo/scripts]# vim /opt/apollosrv/config/scripts/startup.sh 
--------
#!/bin/bash
SERVICE_NAME=apollo-configservice
## Adjust log dir if necessary
LOG_DIR=/opt/logs/100003171
## Adjust server port if necessary
SERVER_PORT=${SERVER_PORT:=8080}

## Create log directory if not existed because JDK 8+ won't do that
mkdir -p $LOG_DIR

## Adjust memory settings if necessary
export JAVA_OPTS="-Xms512m -Xmx512m -Xss256k -XX:MetaspaceSize=64m -XX:MaxMetaspaceSize=150m -XX:NewSize=256m -XX:MaxNewSize=256m -XX:SurvivorRatio=8"  #修改jvm使用内存情况，适合自己电脑即可
--------
[root@node2 /download/apollo/scripts]# /opt/apollosrv/config/scripts/startup.sh #启动configservice
#配置启动adminservice
[root@node2 /download/apollo/scripts]# vim /opt/apollosrv/admin/scripts/startup.sh
--------
#!/bin/bash
SERVICE_NAME=apollo-adminservice
## Adjust log dir if necessary
LOG_DIR=/opt/logs/100003172
## Adjust server port if necessary
SERVER_PORT=${SERVER_PORT:=8090}

## Create log directory if not existed because JDK 8+ won't do that
mkdir -p $LOG_DIR

## Adjust memory settings if necessary
export JAVA_OPTS="-Xms512m -Xmx512m -Xss256k -XX:MetaspaceSize=64m -XX:MaxMetaspaceSize=150m -XX:NewSize=256m -XX:MaxNewSize=256m -XX:SurvivorRatio=8" #修改jvm使用内存情况，适合自己电脑即可
--------
[root@node2 /download/apollo/scripts]# /opt/apollosrv/admin/scripts/startup.sh #启动adminservice
#配置启动portal
[root@node2 /download/apollo/scripts]# vim /opt/apollosrv/portal/scripts/startup.sh
--------
#!/bin/bash
SERVICE_NAME=apollo-portal
## Adjust log dir if necessary
LOG_DIR=/opt/logs/100003173
## Adjust server port if necessary
SERVER_PORT=${SERVER_PORT:=8070}

## Create log directory if not existed because JDK 8+ won't do that
mkdir -p $LOG_DIR

## Adjust memory settings if necessary
export JAVA_OPTS="-Xms512m -Xmx512m -Xss256k -XX:MetaspaceSize=64m -XX:MaxMetaspaceSize=150m -XX:NewSize=256m -XX:MaxNewSize=256m -XX:SurvivorRatio=8"#修改jvm使用内存情况，适合自己电脑即可
--------
[root@node2 /download/apollo/scripts]# /opt/apollosrv/portal/scripts/startup.sh #启动portal
[root@node2 /download/apollo]# netstat -tnlp | grep 80
tcp6       0      0 :::8080                 :::*                    LISTEN      16187/java          
tcp6       0      0 :::8090                 :::*                    LISTEN      16518/java          
tcp6       0      0 :::8070                 :::*                    LISTEN      17254/java  
#注：因为编译时已经填好数据库连接信息了，这里面解压过后如果需要更改数据库连接信息，则可以修改/opt/admin/config/application-github.properties(adminservice),/opt/config/config/application-github.properties(configservice)，此/opt/apollosrv/portal/config/apollo-env.properties文件可以更改环境。
#修改portal数据库配置
--修改部门
select `value` from `ApolloPortalDB`.`ServerConfig` where `key`= 'organizations'
update `ApolloPortalDB`.`ServerConfig` set `value`='[{"orgId":"Tech","orgName":"技术部"},{"orgId":"Oper","orgName":"运维组"}]' where `key`= 'organizations'
--更改设置环境
update `ApolloPortalDB`.`ServerConfig` set `value`='pro' where `key` = 'apollo.portal.envs'
#注：数据库配置好后要重启下portal，然后再能建项目，如果在配置数据库之前创建项目，则会导致项目使用异常

  
#apollo配置中心安装和部署(node1)
#安装java1.8+和mysql5.6.0+
#jdk安装
[root@node2 /download]# cd /download/tar xf jdk-8u201-linux-x64.tar.gz -C /usr/local/
[root@node2 /download]# cd /download/ln -sv /usr/local/jdk1.8.0_201/ /usr/local/jdk
[root@node2 /download]# cd /download/echo 'PATH=$PATH:/usr/local/jdk/bin' > /etc/profile.d/jdk.sh
[root@node2 /download]# source /etc/profile
[root@node2 /download]# java -version
java version "1.8.0_201"
Java(TM) SE Runtime Environment (build 1.8.0_201-b09)
Java HotSpot(TM) 64-Bit Server VM (build 25.201-b09, mixed mode)
#mysql安装 
[root@node2 /download]# tar xf mysql-5.6.48-linux-glibc2.12-x86_64.tar.gz  -C /usr/local/
[root@node2 /download]# ln -sv /usr/local/mysql-5.6.48-linux-glibc2.12-x86_64/ /usr/local/mysql
[root@node2 /download]# echo 'PATH=$PATH:/usr/local/mysql/bin' > /etc/profile.d/mysql.sh
[root@node2 /download]# mkdir -p /data/mysql
[root@node2 /download]# chown -R root.mysql /data/mysql/
[root@node2 /download]# chmod -R 775 /data/mysql/
[root@node2 /download]# chown -R root.mysql /usr/local/mysql-5.6.48-linux-glibc2.12-x86_64/
[root@node2 /download]# chmod -R 775 /usr/local/mysql-5.6.48-linux-glibc2.12-x86_64/
[root@node2 /download]# yum install -y autoconf
[root@node2 /usr/local/mysql/scripts]# ./mysql_install_db --datadir=/data/mysql --user=mysql --basedir=/usr/local/mysql
[root@node2 /usr/local/mysql]# cp support-files/mysql.server /etc/init.d/
[root@node2 /usr/local/mysql]# cat /etc/my.cnf
-----------
[client]
socket = /tmp/mysql.sock

[mysqld]
basedir = /usr/local/mysql
datadir = /data/mysql
port = 3306
server_id = 1
socket = /tmp/mysql.sock

join_buffer_size = 4M
sort_buffer_size = 2M
read_rnd_buffer_size = 2M 
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES,ANSI_QUOTES
default_storage_engine = INNODB
thread_concurrency = 10
innodb_read_io_threads = 6
innodb_write_io_threads = 6
innodb_flush_log_at_trx_commit =1
innodb_log_buffer_size = 16M
innodb_log_file_size = 5M
innodb_log_files_in_group = 2
innodb_file_per_table = 1
innodb_buffer_pool_size = 300M
transaction-isolation = REPEATABLE-READ
binlog_format = MIXED
log_bin = mysql-binlog
slow_query_log_file = /data/mysql/mysql-slow.log
slow_query_log = 1
log_error = /data/mysql/mysql.err
-----------
[root@node2 /usr/local/mysql]# /etc/init.d/mysql.server start
[root@node2 /usr/local/mysql]# chkconfig --add mysql.server
[root@node2 /usr/local/mysql]# chkconfig --level 35 mysql.server on
[root@node2 /usr/local/mysql]# netstat -tnlp | grep 3306
tcp6       0      0 :::3306                 :::*                    LISTEN      7253/mysqld
[root@node2 /usr/local/mysql]# mysqld -V
mysqld  Ver 5.6.48 for linux-glibc2.12 on x86_64 (MySQL Community Server (GPL))
#创建数据库并导入表结构
mysql> source /download/apollo/scripts/sql/apolloconfigdb.sql #导入configDB
mysql> grant all on ApolloConfigDB.* to apollo@'localhost' identified by 'apollo';
Query OK, 0 rows affected (0.00 sec)

#复制包到目标路径,只需要config和admin，每一个环境部署一套,而portal在整个配置中心中只需要一个
[root@node1 /download]# mkdir -p /opt/apollosrv/{admin,config}
[root@node2 /download/apollo]# scp /download/apollo/apollo-configservice/target/apollo-configservice-1.7.0-SNAPSHOT-github.zip root@node1:/opt/apollosrv/config/
[root@node2 /download/apollo]# scp /download/apollo/apollo-adminservice/target/apollo-adminservice-1.7.0-SNAPSHOT-github.zip root@node1:/opt/apollosrv/admin/
[root@node1 /download]# cd /opt/apollosrv/config && unzip apollo-configservice-1.7.0-SNAPSHOT-github.zip
[root@node1 /download]# cd /opt/apollosrv/admin && unzip apollo-adminservice-1.7.0-SNAPSHOT-github.zip
[root@node2 /download]# vim /opt/apollosrv/config/scripts/startup.sh
--------
#!/bin/bash
SERVICE_NAME=apollo-configservice
## Adjust log dir if necessary
LOG_DIR=/opt/logs/100003171
## Adjust server port if necessary
SERVER_PORT=${SERVER_PORT:=8080}

## Create log directory if not existed because JDK 8+ won't do that
mkdir -p $LOG_DIR

## Adjust memory settings if necessary
export JAVA_OPTS="-Xms512m -Xmx512m -Xss256k -XX:MetaspaceSize=64m -XX:MaxMetaspaceSize=150m -XX:NewSize=256m -XX:MaxNewSize=256m -XX:SurvivorRatio=8"
--------
[root@node1 /opt/config]# /opt/apollosrv/config/scripts/startup.sh #node1上启动configservice 
[root@node2 /download]# vim /opt/apollosrv/admin/scripts/startup.sh
--------
#!/bin/bash
SERVICE_NAME=apollo-adminservice
## Adjust log dir if necessary
LOG_DIR=/opt/logs/100003172
## Adjust server port if necessary
SERVER_PORT=${SERVER_PORT:=8090}

## Create log directory if not existed because JDK 8+ won't do that
mkdir -p $LOG_DIR

## Adjust memory settings if necessary
export JAVA_OPTS="-Xms512m -Xmx512m -Xss256k -XX:MetaspaceSize=64m -XX:MaxMetaspaceSize=150m -XX:NewSize=256m -XX:MaxNewSize=256m -XX:SurvivorRatio=8"
--------
[root@node1 /opt/admin]# /opt/apollosrv/admin/scripts/startup.sh #node1上启动adminservice 
[root@node1 /opt/admin]# netstat -tnlp | grep 80
tcp6       0      0 :::8080                 :::*                    LISTEN      72089/java          
tcp6       0      0 :::8090                 :::*                    LISTEN      71644/java  
#注：因为编译时已经填好数据库连接信息了，这里面解压过后如果需要更改数据库连接信息，则可以修改/opt/admin/config/application-github.properties(adminservice),/opt/config/config/application-github.properties(configservice)

#访问http://192.168.15.202:8080web图形化界面
1. 建立项目，指定部门，AppId,应用名称，应用负责人等信息。
2. 一旦项目建立后就有两个配置好的FAT和PRO环境。可以建立配置信息等。
3. 建立一个key为'a',值为test123,并点发布。

#apollo python client，测试发布的效果
[root@node2 /download/pyapollo/pyapollo]# git clone https://github.com/BruceWW/pyapollo.git
[root@node2 /download/pyapollo/pyapollo]# yum install -y python36 python36-pip
[root@node2 /download/pyapollo/pyapollo]# pip3 install apollo_client
[root@node2 /download/pyapollo/pyapollo]# cat pyapollo/client.py 
-------------------
from apollo_client import ApolloClient 

client = ApolloClient(app_id='1', config_server_url="http://node1:8080") 
client.start()

print(client.get_value('a'))
-------------------
[root@node2 /download/pyapollo/pyapollo]# python3 /download/pyapollo/pyapollo/client.py 
test123

#注：实现环境高可用 
实现环境高可用，原理就是每个环境部署多个节点，然后每个节点连接数据库指向当前环境其中一个数据库节点，连接ApolloConfigDB,
1. 在ApolloConfigDB的表ServerConfig中设置key=eureka.service.url的value为每个configservice地址，例如：http://192.168.15.202:8080/eureka/,http://192.168.15.201:8080/eureka/。
2. 在ApolloAdminDB的表ServerConfig中设置key=apollo.portal.envs的value为你要设置的环境数据 ，例如：DEV,FAT,UAT,PRO #可以是其中一个
3. 更改portal根目录中的config文件apollo-env.properties的设置，例如单个环境设置多个metaservice，例如：pro.meta=http://192.168.15.202:8080,http://192.168.15.201:8080
4. 重启更改过的配置服务portal

</pre>

#Docker Deploy Apollo
<pre>
[root@node2 /download/docker-apollo]# cat README.md 
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
select * from `ApolloPortalDB`.`ServerConfig` ;
update `ApolloPortalDB`.`ServerConfig` set `value`='pro' where `key` = 'apollo.portal.envs';
#configDB进行环境配置
select * from `ApolloConfigDB`.`ServerConfig`;
update `ApolloConfigDB`.`ServerConfig` set `value`='http://192.168.15.202:8080/eureka/' where `key`='eureka.service.url';
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


</pre>