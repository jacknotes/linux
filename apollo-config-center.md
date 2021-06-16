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

#访问http://192.168.15.202:8070web图形化界面
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



#apollo
#datetime: 20210616
<pre>
DOC: https://www.apolloconfig.com/#/zh/deployment/distributed-deployment-guide?id=_31-%e8%b0%83%e6%95%b4apolloportaldb%e9%85%8d%e7%bd%ae
#运行时环境：
OS: 服务端基于Spring Boot，启动脚本理论上支持所有Linux发行版，建议CentOS 7。
JAVA: 最好1.8 
Apollo服务端：1.8+
Apollo客户端：1.7+
MYSQL: 版本要求：5.6.5+

#Apollo目前支持以下环境：
DEV		开发环境
FAT		测试环境，相当于alpha环境(功能测试)
UAT		集成环境，相当于beta环境（回归测试）
PRO		生产环境

#环境：
Portal部署在生产环境的机房，通过它来直接管理FAT、UAT、PRO等环境的配置
Meta Server、Config Service和Admin Service在每个环境都单独部署，使用独立的数据库
Meta Server、Config Service和Admin Service在生产环境部署在两个机房，实现双活
Meta Server和Config Service部署在同一个JVM进程内，Admin Service部署在同一台服务器的另一个JVM进程内

#网络策略：
分布式部署的时候，apollo-configservice和apollo-adminservice需要把自己的IP和端口注册到Meta Server（apollo-configservice本身）。
Apollo客户端和Portal会从Meta Server获取服务的地址（IP+端口），然后通过服务地址直接访问。
需要注意的是，apollo-configservice和apollo-adminservice是基于内网可信网络设计的，所以出于安全考虑，请不要将apollo-configservice和apollo-adminservice直接暴露在公网。
所以如果实际部署的机器有多块网卡（如docker），或者存在某些网卡的IP是Apollo客户端和Portal无法访问的（如网络安全限制），那么我们就需要在apollo-configservice和apollo-adminservice中做相关配置来解决连通性问题。

#忽略某些网卡：
可以分别修改apollo-configservice和apollo-adminservice的startup.sh，通过JVM System Property传入-D参数，也可以通过OS Environment Variable传入，下面的例子会把docker0和veth开头的网卡在注册到Eureka时忽略掉。
JVM System Property示例：
-Dspring.cloud.inetutils.ignoredInterfaces[0]=docker0
-Dspring.cloud.inetutils.ignoredInterfaces[1]=veth.*
OS Environment Variable示例：
SPRING_CLOUD_INETUTILS_IGNORED_INTERFACES[0]=docker0
SPRING_CLOUD_INETUTILS_IGNORED_INTERFACES[1]=veth.*

#指定要注册的URL：
可以分别修改apollo-configservice和apollo-adminservice的startup.sh，通过JVM System Property传入-D参数，也可以通过OS Environment Variable传入，下面的例子会指定注册的URL为http://1.2.3.4:8080。
JVM System Property示例：
-Deureka.instance.homePageUrl=http://1.2.3.4:8080
-Deureka.instance.preferIpAddress=false
OS Environment Variable示例：
EUREKA_INSTANCE_HOME_PAGE_URL=http://1.2.3.4:8080
EUREKA_INSTANCE_PREFER_IP_ADDRESS=false

#直接指定apollo-configservice地址
如果Apollo部署在公有云上，本地开发环境无法连接，但又需要做开发测试的话，客户端可以升级到0.11.0版本及以上，然后配置跳过Apollo Meta Server服务发现

#部署环境
DB:
DEV: 192.168.13.50
FAT: 192.168.13.196
UAT: 192.168.13.214
PRO: 192.168.13.235

Application:
apollo-configservice:
DEV: 192.168.13.50:8085  192.168.13.196:8086
FAT: 192.168.13.196:8085 192.168.13.50:8086
UAT: 192.168.13.214:8085 192.168.13.235:8086
PRO: 192.168.13.235:8085 192.168.13.214:8086
apollo-adminservice:
DEV: 192.168.13.50:8090  192.168.13.196:8091
FAT: 192.168.13.196:8090 192.168.13.50:8091
UAT: 192.168.13.214:8090 192.168.13.235:8091
PRO: 192.168.13.235:8090 192.168.13.214:8091



#安装java1.8
步骤忽略

#数据库部署
1. 安装数据库；：
略
2. 重置密码
先在/etc/my.cnf配置文件上增加配置: skip-grant-tables=1,然后重启启动mysqld服务，在进入数据库设立密码：
update mysql.user set authentication_string=password('homsom') where user='root' and host='localhost';
flush privileges;
最后在/etc/my.cnf配置文件上删除配置: skip-grant-tables=1,然后重启启动mysqld服务，在进入数据库更改密码：
alter user root@'localhost' identified by 'homsom123';
3. 数据库版本结果：
DEV--192.168.13.50:
MySQL [(none)]> SHOW VARIABLES WHERE Variable_name = 'version';
+---------------+------------+
| Variable_name | Value      |
+---------------+------------+
| version       | 5.7.31-log |
+---------------+------------+
FAT--192.168.13.196:
mysql> SHOW VARIABLES WHERE Variable_name = 'version';
+---------------+------------+
| Variable_name | Value      |
+---------------+------------+
| version       | 5.7.33-log |
+---------------+------------+
UAT--192.168.13.214:
mysql> SHOW VARIABLES WHERE Variable_name = 'version';
+---------------+------------+
| Variable_name | Value      |
+---------------+------------+
| version       | 5.7.33-log |
+---------------+------------+
PRO--192.168.13.235:
mysql> SHOW VARIABLES WHERE Variable_name = 'version';
+---------------+------------+
| Variable_name | Value      |
+---------------+------------+
| version       | 5.7.33-log |
+---------------+------------+


#部署步骤
4. 创建数据库
Apollo服务端共需要两个数据库：ApolloPortalDB和ApolloConfigDB，我们把数据库、表的创建和样例数据都分别准备了sql文件，只需要导入数据库即可。
需要注意的是ApolloPortalDB只需要在生产环境部署一个即可，而ApolloConfigDB需要在每个环境部署一套，如fat、uat和pro分别部署3套ApolloConfigDB。

PRO--192.168.13.235:
4.1.1 创建ApolloPortalDB:
mysql> create database ApolloPortalDB;
4.1.2 手动导入SQL创建:
[root@harbor /download/apollo]# curl -OL https://raw.githubusercontent.com/ctripcorp/apollo/master/scripts/sql/apolloportaldb.sql
mysql> \. /download/apollo/apolloportaldb.sql
4.1.3 验证:
[root@harbor ~]# mysql -uapollo -papollo@123 -e 'select `Id`, `Key`, `Value`, `Comment` from `ApolloPortalDB`.`ServerConfig` limit 1;'
mysql> select `Id`, `Key`, `Value`, `Comment` from `ApolloPortalDB`.`ServerConfig` limit 1;
+----+--------------------+-------+--------------------------+
| Id | Key                | Value | Comment                  |
+----+--------------------+-------+--------------------------+
|  1 | apollo.portal.envs | dev   | 可支持的环境列表         |
+----+--------------------+-------+--------------------------+

DEV,FAT,UAT,PRO:
4.2.1 创建ApolloConfigDB:
mysql> create database ApolloConfigDB;
4.2.2 手动导入SQL创建:
[root@harbor apollo]# curl -OL https://raw.githubusercontent.com/ctripcorp/apollo/master/scripts/sql/apolloconfigdb.sql
mysql> \. /download/apollo/apolloconfigdb.sql
4.2.3 验证:
mysql -uapollo -papollo@123 -e 'select `Id`, `Key`, `Value`, `Comment` from `ApolloConfigDB`.`ServerConfig` limit 1;'
mysql> select `Id`, `Key`, `Value`, `Comment` from `ApolloConfigDB`.`ServerConfig` limit 1;
+----+--------------------+-------------------------------+------------------------------------------------------+
| Id | Key                | Value                         | Comment                                              |
+----+--------------------+-------------------------------+------------------------------------------------------+
|  1 | eureka.service.url | http://localhost:8080/eureka/ | Eureka服务Url，多个service以英文逗号分隔             |
+----+--------------------+-------------------------------+------------------------------------------------------+
4.2.4 复制apolloconfigdb.sql到其它环境中并如上运行：
[root@harbor apollo]# for i in 50 196 214;do scp apolloconfigdb.sql root@192.168.13.$i:/download/apollo/;done
创建管理员：
grant all on *.* to admin@'%' identified by 'devapollo' with grant option;
grant all on *.* to admin@'%' identified by 'fatapollo' with grant option;
grant all on *.* to admin@'%' identified by 'uatapollo' with grant option;
grant all on *.* to admin@'%' identified by 'proapollo' with grant option;

5. 调整服务端配置
Apollo自身的一些配置是放在数据库里面的，所以需要针对实际情况做一些调整，具体参数说明请参考三、服务端配置说明。
大部分配置可以先使用默认值，不过 apollo.portal.envs 和 eureka.service.url 请务必配置正确后再进行下面的部署步骤。
服务端配置说明: 配置除了支持在数据库中配置以外，也支持通过-D参数、application.properties等配置，且-D参数、application.properties等优先级高于数据库中的配置

5.1 调整ApolloPortalDB配置:
配置项统一存储在ApolloPortalDB.ServerConfig表中，也可以通过管理员工具 - 系统参数页面进行配置，无特殊说明则修改完一分钟实时生效。

5.1.1 apollo.portal.envs - 可支持的环境列表
默认值是dev，如果portal需要管理多个环境的话，以逗号分隔即可（大小写不敏感），如：DEV,FAT,UAT,PRO 
注：修改完需要重启生效。只在数据库添加环境是不起作用的，还需要为apollo-portal添加新增环境对应的meta server地址，一套Portal可以管理多个环境，但是每个环境都需要独立部署一套Config Service、Admin Service和ApolloConfigDB

5.1.2 eureka.service.url - Eureka服务Url
不管是apollo-configservice还是apollo-adminservice都需要向eureka服务注册，所以需要配置eureka服务地址。 按照目前的实现，apollo-configservice本身就是一个eureka服务，所以只需要填入apollo-configservice的地址即可，如有多个，用逗号分隔（注意不要忘了/eureka/后缀）。需要注意的是每个环境只填入自己环境的eureka服务地址，如下：

在DEV环境的ApolloConfigDB.ServerConfig表中设置eureka.service.url为： http://192.168.13.50:8085/eureka/,http://192.168.13.196:8086/eureka/
在FAT环境的ApolloConfigDB.ServerConfig表中设置eureka.service.url为： http://192.168.13.196:8085/eureka/,http://192.168.13.50:8086/eureka/
在UAT环境的ApolloConfigDB.ServerConfig表中设置eureka.service.url为： http://192.168.13.214:8085/eureka/,http://192.168.13.235:8086/eureka/
在PRO环境的ApolloConfigDB.ServerConfig表中设置eureka.service.url为： http://192.168.13.235:8085/eureka/,http://192.168.13.214:8086/eureka/

Application:
apollo-configservice:
DEV: 192.168.13.50:8085  192.168.13.196:8086
FAT: 192.168.13.196:8085 192.168.13.50:8086
UAT: 192.168.13.214:8085 192.168.13.235:8086
PRO: 192.168.13.235:8085 192.168.13.214:8086
apollo-adminservice:
DEV: 192.168.13.50:8090  192.168.13.196:8091
FAT: 192.168.13.196:8090 192.168.13.50:8091
UAT: 192.168.13.214:8090 192.168.13.235:8091
PRO: 192.168.13.235:8090 192.168.13.214:8091


#部署程序：
从https://github.com/ctripcorp/apollo/releases页面下载最新版本的apollo-configservice-x.x.x-github.zip、apollo-adminservice-x.x.x-github.zip和apollo-portal-x.x.x-github.zip即可。
# 1. 配置数据库连接信息
Apollo服务端需要知道如何连接到你前面创建的数据库，数据库连接串信息位于上一步下载的压缩包中的config/application-github.properties中

##apollo-configservice
#DEV:配置apollo-configservice的数据库连接信息
#one-daemon: 192.168.13.50:8085
[root@tengine /download/apollo]# mkdir apollo-configservice && mv apollo-configservice-1.8.2-github.zip apollo-configservice && cd apollo-configservice && unzip apollo-configservice-1.8.2-github.zip
MySQL [(none)]> grant all on apolloconfigdb.* to apollo@'%' identified by 'apollo@123';
MySQL [(none)]> flush privileges;
[root@tengine /download/apollo/apollo-configservice]# cat config/application-github.properties
# DataSource
spring.datasource.url = jdbc:mysql://192.168.13.50:3306/ApolloConfigDB?characterEncoding=utf8
spring.datasource.username = apollo
spring.datasource.password = apollo@123
#two-daemon: 192.168.13.196:8086
[root@TestHotelES /usr/local/apollo-configservice-two]# cat config/application-github.properties
# DataSource
spring.datasource.url = jdbc:mysql://192.168.13.50:3306/ApolloConfigDB?characterEncoding=utf8
spring.datasource.username = apollo
spring.datasource.password = apollo@123


#FAT:配置apollo-configservice的数据库连接信息
#one-daemon: 192.168.13.196:8085
[root@TestHotelES /download/apollo]# mkdir apollo-configservice && mv apollo-configservice-1.8.2-github.zip apollo-configservice && cd apollo-configservice && unzip apollo-configservice-1.8.2-github.zip
mysql> grant all on ApolloConfigDB.* to apollo@'%' identified by 'apollo@123';
mysql> flush privileges;
[root@TestHotelES /download/apollo/apollo-configservice]# cat config/application-github.properties
# DataSource
spring.datasource.url = jdbc:mysql://192.168.13.196:3306/ApolloConfigDB?characterEncoding=utf8
spring.datasource.username = apollo
spring.datasource.password = apollo@123
#two-daemon: 192.168.13.50:8086
[root@tengine /usr/local/apollo-configservice-two]# cat config/application-github.properties
# DataSource
spring.datasource.url = jdbc:mysql://192.168.13.196:3306/ApolloConfigDB?characterEncoding=utf8
spring.datasource.username = apollo
spring.datasource.password = apollo@123


#UAT:配置apollo-configservice的数据库连接信息
#one-daemon: 192.168.13.214:8085
[root@BuildImage /download/apollo]# mkdir apollo-configservice && mv apollo-configservice-1.8.2-github.zip apollo-configservice && cd apollo-configservice && unzip apollo-configservice-1.8.2-github.zip
mysql> grant all on ApolloConfigDB.* to apollo@'%' identified by 'apollo@123';
mysql> flush privileges;
[root@BuildImage /download/apollo/apollo-configservice]# cat config/application-github.properties
# DataSource
spring.datasource.url = jdbc:mysql://192.168.13.214:3306/ApolloConfigDB?characterEncoding=utf8
spring.datasource.username = apollo
spring.datasource.password = apollo@123
#two-daemon: 192.168.13.235:8086
[root@harbor /usr/local/apollo-configservice-two]# cat config/application-github.properties
# DataSource
spring.datasource.url = jdbc:mysql://192.168.13.214:3306/ApolloConfigDB?characterEncoding=utf8
spring.datasource.username = apollo
spring.datasource.password = apollo@123


#PRO:配置apollo-configservice的数据库连接信息
#one-daemon: 192.168.13.235:8085
[root@harbor /download/apollo]# mkdir apollo-configservice && mv apollo-configservice-1.8.2-github.zip apollo-configservice && cd apollo-configservice && unzip apollo-configservice-1.8.2-github.zip
mysql> grant all on ApolloConfigDB.* to apollo@'%' identified by 'apollo@123';
mysql> flush privileges;
[root@harbor /download/apollo/apollo-configservice]# cat config/application-github.properties
# DataSource
spring.datasource.url = jdbc:mysql://192.168.13.235:3306/ApolloConfigDB?characterEncoding=utf8
spring.datasource.username = apollo
spring.datasource.password = apollo@123
#one-daemon: 192.168.13.214:8086
[root@BuildImage /usr/local/apollo-configservice-two]# cat config/application-github.properties
# DataSource
spring.datasource.url = jdbc:mysql://192.168.13.235:3306/ApolloConfigDB?characterEncoding=utf8
spring.datasource.username = apollo
spring.datasource.password = apollo@123


##apollo-adminservice
apollo-adminservice:
DEV: 192.168.13.50:8090  192.168.13.196:8091
FAT: 192.168.13.196:8090 192.168.13.50:8091
UAT: 192.168.13.214:8090 192.168.13.235:8091
PRO: 192.168.13.235:8090 192.168.13.214:8091

#DEV:配置apollo-adminservice的数据库连接信息
#one-daemon: 192.168.13.50:8090
[root@tengine /download/apollo]# mkdir apollo-adminservice && mv apollo-adminservice-1.8.2-github.zip apollo-adminservice && cd apollo-adminservice && unzip apollo-adminservice-1.8.2-github.zip
[root@TestHotelES /usr/local/apollo-adminservice]# cat config/application-github.properties
# DataSource
spring.datasource.url = jdbc:mysql://192.168.13.50:3306/ApolloConfigDB?characterEncoding=utf8
spring.datasource.username = apollo
spring.datasource.password = apollo@123
#two-daemon: 192.168.13.196:8091
[root@TestHotelES /usr/local/apollo-adminservice-two]# cat config/application-github.properties
# DataSource
spring.datasource.url = jdbc:mysql://192.168.13.50:3306/ApolloConfigDB?characterEncoding=utf8
spring.datasource.username = apollo
spring.datasource.password = apollo@123


#FAT:配置apollo-adminservice的数据库连接信息
#one-daemon: 192.168.13.196:8090
[root@TestHotelES /download/apollo]# mkdir apollo-adminservice && mv apollo-adminservice-1.8.2-github.zip apollo-adminservice && cd apollo-adminservice && unzip apollo-adminservice-1.8.2-github.zip
[root@TestHotelES /usr/local/apollo-adminservice]# cat config/application-github.properties
# DataSource
spring.datasource.url = jdbc:mysql://192.168.13.196:3306/ApolloConfigDB?characterEncoding=utf8
spring.datasource.username = apollo
spring.datasource.password = apollo@123
#two-daemon: 192.168.13.50:8091
[root@tengine /usr/local/apollo-adminservice-two]# cat config/application-github.properties
# DataSource
spring.datasource.url = jdbc:mysql://192.168.13.196:3306/ApolloConfigDB?characterEncoding=utf8
spring.datasource.username = apollo
spring.datasource.password = apollo@123


#UAT:配置apollo-adminservice的数据库连接信息
#one-daemon: 192.168.13.214:8090
[root@BuildImage /download/apollo]# mkdir apollo-adminservice && mv apollo-adminservice-1.8.2-github.zip apollo-adminservice && cd apollo-adminservice && unzip apollo-adminservice-1.8.2-github.zip
[root@BuildImage /download/apollo/apollo-adminservice]# cat config/application-github.properties
# DataSource
spring.datasource.url = jdbc:mysql://192.168.13.214:3306/ApolloConfigDB?characterEncoding=utf8
spring.datasource.username = apollo
spring.datasource.password = apollo@123
#two-daemon: 192.168.13.235:8091
[root@harbor /usr/local/apollo-adminservice-two]# cat config/application-github.properties
# DataSource
spring.datasource.url = jdbc:mysql://192.168.13.214:3306/ApolloConfigDB?characterEncoding=utf8
spring.datasource.username = apollo
spring.datasource.password = apollo@123


#PRO:配置apollo-adminservice的数据库连接信息
#one-daemon: 192.168.13.235:8090
[root@harbor /download/apollo]# mkdir apollo-adminservice && mv apollo-adminservice-1.8.2-github.zip apollo-adminservice && cd apollo-adminservice && unzip apollo-adminservice-1.8.2-github.zip
[root@harbor /download/apollo/apollo-adminservice]# cat config/application-github.properties
# DataSource
spring.datasource.url = jdbc:mysql://192.168.13.235:3306/ApolloConfigDB?characterEncoding=utf8
spring.datasource.username = apollo
spring.datasource.password = apollo@123
#two-daemon: 192.168.13.214:8091
[root@BuildImage /usr/local/apollo-adminservice-two]# cat config/application-github.properties
# DataSource
spring.datasource.url = jdbc:mysql://192.168.13.235:3306/ApolloConfigDB?characterEncoding=utf8
spring.datasource.username = apollo
spring.datasource.password = apollo@123



##apollo-portal
PRO:配置apollo-portal的数据库连接信息
[root@harbor /download/apollo/apollo-portal]# mkdir apollo-portal && mv apollo-portal-1.8.2-github.zip apollo-portal && cd apollo-portal && unzip apollo-portal-1.8.2-github.zip 
mysql> grant all on ApolloPortalDB.* to apollo@'%' identified by 'apollo@123';
mysql> flush privileges;
[root@harbor /download/apollo/apollo-portal]# cat config/application-github.properties
# DataSource
spring.datasource.url = jdbc:mysql://192.168.13.235:3306/ApolloPortalDB?characterEncoding=utf8
spring.datasource.username = apollo
spring.datasource.password = apollo@123


#配置apollo-portal的meta service信息
Apollo Portal需要在不同的环境访问不同的meta service(apollo-configservice)地址，所以我们需要在配置中提供这些信息。默认情况下，meta service和config service是部署在同一个JVM进程，所以meta service的地址就是config service的地址。
对于1.6.0及以上版本，可以通过ApolloPortalDB.ServerConfig中的配置项来配置Meta Service地址
Application:
configservice
DEV: apollo.dev.k8s.hs.com     -->      192.168.13.50:8085  192.168.13.196:8086
FAT: apollo.fat.k8s.hs.com     -->      192.168.13.196:8085 192.168.13.50:8086
UAT: apollo.uat.k8s.hs.com     -->      192.168.13.214:8085 192.168.13.235:8086
PRO: apollo.k8s.hs.com     	   -->     	192.168.13.235:8085 192.168.13.214:8086
[root@harbor /download/apollo/apollo-portal]# cat config/apollo-env.properties
dev.meta=http://apollo.dev.k8s.hs.com
fat.meta=http://apollo.fat.k8s.hs.com
uat.meta=http://apollo.uat.k8s.hs.com
pro.meta=http://apollo.k8s.hs.com
注：为了实现meta service的高可用，推荐通过SLB（Software Load Balancer）做动态负载均衡
注: meta service地址也可以填入IP，0.11.0版本之前只支持填入一个IP。从0.11.0版本开始支持填入以逗号分隔的多个地址，如http://1.1.1.1:8080,http://2.2.2.2:8080，不过生产环境还是建议使用域名（走slb），因为机器扩容、缩容等都可能导致IP列表的变化
除了通过apollo-env.properties方式配置meta service以外，apollo也支持在运行时指定meta service（优先级比apollo-env.properties高）：
1. 通过Java System Property ${env}_meta
	可以通过Java的System Property ${env}_meta来指定
	如java -Ddev_meta=http://config-service-url -jar xxx.jar
	也可以通过程序指定，如System.setProperty("dev_meta", "http://config-service-url");
2. 通过操作系统的System Environment${ENV}_META
	如DEV_META=http://config-service-url
	注意key为全大写，且中间是_分隔



#2. 部署Apollo服务端
######DEV:
#部署apollo-configservice
#one-daemon:
[root@tengine /download/apollo]# mv apollo-configservice/ /usr/local/
[root@tengine /download/apollo]# mv apollo-adminservice/ /usr/local/
[root@tengine /usr/local/apollo-configservice]# vim scripts/startup.sh
LOG_DIR=/var/log/apollo-configservice
SERVER_PORT=${SERVER_PORT:=8085}
export JAVA_OPTS="-Xms512m -Xmx512m -Xss256k -XX:MetaspaceSize=64m -XX:MaxMetaspaceSize=182m -XX:NewSize=256m -XX:MaxNewSize=256m -XX:SurvivorRatio=8"
[root@tengine /usr/local/apollo-configservice]# vim apollo-configservice.conf 
LOG_FOLDER=/var/log/apollo-configservice
#two-daemon:
[root@tengine /usr/local/apollo-configservice]# cp -a /usr/local/apollo-configservice/ /usr/local/apollo-configservice-two
[root@tengine /usr/local/apollo-configservice]# cd /usr/local/apollo-configservice-two
[root@tengine /usr/local/apollo-configservice-two]# vim scripts/startup.sh 
LOG_DIR=/var/log/apollo-configservice-two
SERVER_PORT=${SERVER_PORT:=8086}
export JAVA_OPTS="-Xms512m -Xmx512m -Xss256k -XX:MetaspaceSize=64m -XX:MaxMetaspaceSize=182m -XX:NewSize=256m -XX:MaxNewSize=256m -XX:SurvivorRatio=8"
[root@tengine /usr/local/apollo-configservice-two]# vim apollo-configservice.conf
LOG_FOLDER=/var/log/apollo-configservice-two
#部署apollo-adminservice
#one-daemon:
[root@tengine /usr/local/apollo-configservice]# cd /usr/local/apollo-adminservice
[root@tengine /usr/local/apollo-adminservice]# vim scripts/startup.sh
LOG_DIR=/var/log/apollo-adminservice
SERVER_PORT=${SERVER_PORT:=8090}
export JAVA_OPTS="-Xms256m -Xmx256m -Xss256k -XX:MetaspaceSize=64m -XX:MaxMetaspaceSize=128m -XX:NewSize=256m -XX:MaxNewSize=256m -XX:SurvivorRatio=8"
[root@tengine /usr/local/apollo-adminservice]# vim apollo-adminservice.conf
LOG_FOLDER=/var/log/apollo-adminservice  
#two-daemon:
[root@tengine /usr/local/apollo-adminservice]# cp -a /usr/local/apollo-adminservice/ /usr/local/apollo-adminservice-two
[root@tengine /usr/local/apollo-adminservice]# cd /usr/local/apollo-adminservice-two
[root@tengine /usr/local/apollo-adminservice-two]# vim scripts/startup.sh 
LOG_DIR=/var/log/apollo-adminservice
SERVER_PORT=${SERVER_PORT:=8091}
export JAVA_OPTS="-Xms256m -Xmx256m -Xss256k -XX:MetaspaceSize=64m -XX:MaxMetaspaceSize=128m -XX:NewSize=256m -XX:MaxNewSize=256m -XX:SurvivorRatio=8"
[root@tengine /usr/local/apollo-adminservice-two]# vim apollo-adminservice.conf
LOG_FOLDER=/var/log/apollo-adminservice-two 
#运行
/usr/local/apollo-configservice/scripts/startup.sh
/usr/local/apollo-configservice-two/scripts/startup.sh
/usr/local/apollo-adminservice/scripts/startup.sh 
/usr/local/apollo-adminservice-two/scripts/startup.sh 
[root@tengine /usr/local]# netstat -tnlp | grep -E ':(8085|8086|8090|8091)'
tcp        0      0 0.0.0.0:8086            0.0.0.0:*               LISTEN      28683/java          
tcp        0      0 0.0.0.0:8090            0.0.0.0:*               LISTEN      28996/java          
tcp        0      0 0.0.0.0:8091            0.0.0.0:*               LISTEN      29313/java          
tcp        0      0 0.0.0.0:8085            0.0.0.0:*               LISTEN      28350/java       

######PRO:
#部署apollo-configservice
#one-daemon:
[root@harbor /download/apollo]# mv /download/apollo/apollo-portal/ /usr/local/
[root@harbor /download/apollo]# mv /download/apollo/apollo-configservice /usr/local/
[root@harbor /download/apollo]# mv /download/apollo/apollo-adminservice/ /usr/local/
[root@harbor /usr/local/apollo-configservice]# vim scripts/startup.sh
LOG_DIR=/var/log/apollo-configservice
SERVER_PORT=${SERVER_PORT:=8085}
export JAVA_OPTS="-Xms512m -Xmx512m -Xss256k -XX:MetaspaceSize=64m -XX:MaxMetaspaceSize=182m -XX:NewSize=256m -XX:MaxNewSize=256m -XX:SurvivorRatio=8"
[root@harbor /usr/local/apollo-configservice]# vim apollo-configservice.conf 
LOG_FOLDER=/var/log/apollo-configservice
#two-daemon:
[root@harbor /usr/local/apollo-configservice]# cp -a /usr/local/apollo-configservice/ /usr/local/apollo-configservice-two
[root@harbor /usr/local/apollo-configservice]# cd /usr/local/apollo-configservice-two
[root@harbor /usr/local/apollo-configservice-two]# vim scripts/startup.sh 
LOG_DIR=/var/log/apollo-configservice-two
SERVER_PORT=${SERVER_PORT:=8086}
export JAVA_OPTS="-Xms512m -Xmx512m -Xss256k -XX:MetaspaceSize=64m -XX:MaxMetaspaceSize=182m -XX:NewSize=256m -XX:MaxNewSize=256m -XX:SurvivorRatio=8"
[root@harbor /usr/local/apollo-configservice-two]# vim apollo-configservice.conf
LOG_FOLDER=/var/log/apollo-configservice-two
#部署apollo-adminservice
#one-daemon:
[root@harbor /usr/local/apollo-configservice-two]# cd /usr/local/apollo-adminservice
[root@harbor /usr/local/apollo-adminservice]# vim scripts/startup.sh
LOG_DIR=/var/log/apollo-adminservice
SERVER_PORT=${SERVER_PORT:=8090}
export JAVA_OPTS="-Xms256m -Xmx256m -Xss256k -XX:MetaspaceSize=64m -XX:MaxMetaspaceSize=128m -XX:NewSize=256m -XX:MaxNewSize=256m -XX:SurvivorRatio=8"
[root@harbor /usr/local/apollo-adminservice]# vim apollo-adminservice.conf
LOG_FOLDER=/var/log/apollo-adminservice
#two-daemon:
[root@harbor /usr/local/apollo-adminservice]# cp -a /usr/local/apollo-adminservice/ /usr/local/apollo-adminservice-two
[root@harbor /usr/local/apollo-adminservice]# cd /usr/local/apollo-adminservice-two
[root@harbor /usr/local/apollo-adminservice-two]# vim scripts/startup.sh 
LOG_DIR=/var/log/apollo-adminservice
SERVER_PORT=${SERVER_PORT:=8091}
export JAVA_OPTS="-Xms256m -Xmx256m -Xss256k -XX:MetaspaceSize=64m -XX:MaxMetaspaceSize=128m -XX:NewSize=256m -XX:MaxNewSize=256m -XX:SurvivorRatio=8"
[root@harbor /usr/local/apollo-adminservice-two]# vim apollo-adminservice.conf
LOG_FOLDER=/var/log/apollo-adminservice-two 

#部署apollo-portal
[root@harbor /usr/local/apollo-portal]# vim scripts/startup.sh
LOG_DIR=/var/log/apollo-portal
SERVER_PORT=${SERVER_PORT:=8070}
export JAVA_OPTS="-Xms256m -Xmx256m -Xss128k -XX:MetaspaceSize=64m -XX:MaxMetaspaceSize=128m -XX:NewSize=256m -XX:MaxNewSize=256m -XX:SurvivorRatio=8"
[root@harbor /usr/local/apollo-portal]# vim apollo-portal.conf
LOG_FOLDER=/var/log/apollo-portal
#运行
/usr/local/apollo-configservice/scripts/startup.sh
/usr/local/apollo-configservice-two/scripts/startup.sh
/usr/local/apollo-adminservice/scripts/startup.sh 
/usr/local/apollo-adminservice-two/scripts/startup.sh
/usr/local/apollo-portal/scripts/startup.sh
[root@harbor /usr/local/apollo-adminservice-two]# netstat -tnlp | grep -E ':(8085|8086|8090|8091|8070)'
tcp        0      0 0.0.0.0:8091            0.0.0.0:*               LISTEN      17540/java          
tcp        0      0 0.0.0.0:8070            0.0.0.0:*               LISTEN      16106/java          
tcp        0      0 0.0.0.0:8085            0.0.0.0:*               LISTEN      13842/java          
tcp        0      0 0.0.0.0:8086            0.0.0.0:*               LISTEN      14527/java          
tcp        0      0 0.0.0.0:8090            0.0.0.0:*               LISTEN      15216/java         
#即可访问portal: http://192.168.13.235:8070进行管理，帐户: apollo  密码: admin
停止：
/usr/local/apollo-configservice/scripts/shutdown.sh
/usr/local/apollo-configservice-two/scripts/shutdown.sh
/usr/local/apollo-adminservice/scripts/shutdown.sh
/usr/local/apollo-adminservice-two/scripts/shutdown.sh
/usr/local/apollo-portal/scripts/shutdown.sh


#apollo使用指南
#配置编辑、发布权限
配置权限分为编辑和发布：
编辑权限允许用户在Apollo界面上创建、修改、删除配置
	配置修改后只在Apollo界面上变化，不会影响到应用实际使用的配置
发布权限允许用户在Apollo界面上发布、回滚配置
	配置只有在发布、回滚动作后才会被应用实际使用到
	Apollo在用户操作发布、回滚动作后实时通知到应用，并使最新配置生效
项目创建完，默认没有分配配置的编辑和发布权限，需要项目管理员进行授权。





</pre>

