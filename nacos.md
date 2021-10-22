#Nacos
<pre>
--文档
https://nacos.io/zh-cn/docs/quick-start.html

consul、eureka、nacos对比
配置中心
eureka 不支持
consul 支持 但用起来偏麻烦，不太符合springBoot框架的命名风格，支持动态刷新
nacos 支持 用起来简单，符合springBoot的命名风格，支持动态刷新
注册中心

eureka
应用内/外：直接集成到应用中，依赖于应用自身完成服务的注册与发现，
CAP原则：遵循AP（可用性+分离容忍）原则，有较强的可用性，服务注册快，但牺牲了一定的一致性。
版本迭代：目前已经不进行升级
集成支持：只支持SpringCloud集成
访问协议：HTTP
雪崩保护：支持雪崩保护
界面：英文界面，不符合国人习惯
上手：容易

consul
应用内/外：属于外部应用，侵入性小
CAP原则：遵循CP原则（一致性+分离容忍） 服务注册稍慢，由于其一致性导致了在Leader挂掉时重新选举期间真个consul不可用。
版本迭代：目前仍然进行版本迭代
集成支持：支持SpringCloud K8S集成
访问协议：HTTP/DNS
雪崩保护：不支持雪崩保护
界面：英文界面，不符合国人习惯
上手：复杂一点

nacos
应用内/外：属于外部应用，侵入性小
CAP原则：通知遵循CP原则（一致性+分离容忍） 和AP原则（可用性+分离容忍）
版本迭代：目前仍然进行版本迭代
集成支持：支持Dubbo 、SpringCloud、K8S集成
访问协议：HTTP/动态DNS/UDP
雪崩保护：支持雪崩保护
界面：中文界面，符合国人习惯
上手：极易，中文文档，案例，社区活跃

1. Nacos中的 CP一致性
Spring Cloud Alibaba Nacos 在 1.0.0 正式支持 AP 和 CP 两种一致性协议，其中 CP一致性协议实现，是基于简化的 Raft 的 CP 一致性。
2. Nacos AP 实现
AP协议：Distro协议。Distro是阿里巴巴的私有协议，目前流行的 Nacos服务管理框架就采用了 Distro协议。Distro 协议被定位为 临时数据的一致性协议 ：该类型协议， 
不需要把数据存储到磁盘或者数据库 ，因为临时数据通常和服务器保持一个session会话， 该会话只要存在，数据就不会丢失 。
Distro 协议保证写必须永远是成功的，即使可能会发生网络分区。当网络恢复时，把各数据分片的数据进行合并。
3. Distro 协议具有以下特点：
专门为了注册中心而创造出的协议；
客户端与服务端有两个重要的交互，服务注册与心跳发送；
客户端以服务为维度向服务端注册，注册后每隔一段时间向服务端发送一次心跳，心跳包需要带上注册服务的全部信息，在客户端看来，服务端节点对等，所以请求的节点是随机的；
客户端请求失败则换一个节点重新发送请求；
服务端节点都存储所有数据，但每个节点只负责其中一部分服务，在接收到客户端的“写”（注册、心跳、下线等）请求后，服务端节点判断请求的服务是否为自己负责，如果是，则处理，否则交由负责的节点处理；
每个服务端节点主动发送健康检查到其他节点，响应的节点被该节点视为健康节点；
服务端在接收到客户端的服务心跳后，如果该服务不存在，则将该心跳请求当做注册请求来处理；
服务端如果长时间未收到客户端心跳，则下线该服务；
负责的节点在接收到服务注册、服务心跳等写请求后将数据写入后即返回，后台异步地将数据同步给其他节点；
节点在收到读请求后直接从本机获取后返回，无论数据是否为最新。



--docker部署单节点
git clone https://github.com/nacos-group/nacos-docker.git
cd nacos-docker
docker-compose -f example/standalone-derby.yaml up

-- 服务注册
curl -X POST 'http://127.0.0.1:8848/nacos/v1/ns/instance?serviceName=nacos.naming.serviceName&ip=20.18.7.10&port=8080'
-- 服务发现
curl -X GET 'http://127.0.0.1:8848/nacos/v1/ns/instance/list?serviceName=nacos.naming.serviceName'
-- 发布配置
curl -X POST "http://127.0.0.1:8848/nacos/v1/cs/configs?dataId=nacos.cfg.dataId&group=test&content=helloWorld"
-- 获取配置
curl -X GET "http://127.0.0.1:8848/nacos/v1/cs/configs?dataId=nacos.cfg.dataId&group=test"




#源码方式部署集群
1. 预备环境准备
64 bit OS Linux/Unix/Mac，推荐使用Linux系统，这里使用Ubuntu18.04 。
64 bit JDK 1.8+。
3个或3个以上Nacos节点才能构成集群。
1.1 安装openjdk
sudo salt 'ceph0[123]*' cmd.run 'sudo apt install -y openjdk-8-jdk'
[jack@ubuntu:/srv/salt/prod/nacos/nacos]$ sudo salt 'ceph0[123]*' cmd.run 'java -version'
ceph03.hs.com:
    openjdk version "1.8.0_292"
    OpenJDK Runtime Environment (build 1.8.0_292-8u292-b10-0ubuntu1~18.04-b10)
    OpenJDK 64-Bit Server VM (build 25.292-b10, mixed mode)
ceph02.hs.com:
    openjdk version "1.8.0_292"
    OpenJDK Runtime Environment (build 1.8.0_292-8u292-b10-0ubuntu1~18.04-b10)
    OpenJDK 64-Bit Server VM (build 25.292-b10, mixed mode)
ceph01.hs.com:
    openjdk version "1.8.0_292"
    OpenJDK Runtime Environment (build 1.8.0_292-8u292-b10-0ubuntu1~18.04-b10)
    OpenJDK 64-Bit Server VM (build 25.292-b10, mixed mode)


2. 下载安装包
sudo curl -OL https://github.com/alibaba/nacos/releases/download/2.0.3/nacos-server-2.0.3.tar.gz
sudo tar -xvf nacos-server-2.0.3.tar.gz
cd nacos

3. 配置集群配置文件
sudo cp conf/cluster.conf.example conf/cluster.conf
[jack@ubuntu:/srv/salt/prod/nacos/nacos]$ sudo cat conf/cluster.conf
#it is ip
#example
192.168.13.31
192.168.13.32
192.168.13.33

4. 确定数据源
4.1. 使用内置数据源
无需进行任何配置
4.2. 使用外置数据源
生产使用建议至少主备模式，或者采用高可用数据库。
4.2.1 初始化 MySQL 数据库--tar.gz包中conf目录下有nacos-mysql.sql和application.properties文件。conf/schema.sql文件不是mysql文件，不要导入错了，是 Derby 数据库的脚本
sudo curl -OL https://raw.githubusercontent.com/alibaba/nacos/master/distribution/conf/nacos-mysql.sql
use nacos;
source ./nacos-mysql.sql
grant all on nacos.* to nacos@'192.168.13.%' identified by 'nacos@service';
4.2.2 application.properties 配置
sudo curl -OL https://raw.githubusercontent.com/alibaba/nacos/master/distribution/conf/application.properties
4.2.3 修改conf/application.properties文件，增加支持mysql数据源配置（目前只支持mysql），添加mysql数据源的url、用户名和密码，mysql库名是nacos_config，并且开启metric提供监控
server.servlet.contextPath=/nacos
db.num=1
db.url.0=jdbc:mysql://devmysql.hs.com:3306/nacos_config?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=UTC
db.user.0=nacos
db.password.0=nacos@service
management.endpoints.web.exposure.include=*
4.2.4 
[jack@ubuntu:/srv/salt/prod/nacos/nacos]$ grep -Ev '#|^$' conf/application.properties
server.servlet.contextPath=/nacos     #http请求URI路径
server.port=8848
db.num=1
db.url.0=jdbc:mysql://devmysql.hs.com:3306/nacos?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=UTC
db.user.0=nacos
db.password.0=nacos@service
db.pool.config.connectionTimeout=30000
db.pool.config.validationTimeout=10000
db.pool.config.maximumPoolSize=20
db.pool.config.minimumIdle=2
nacos.naming.empty-service.auto-clean=true
nacos.naming.empty-service.clean.initial-delay-ms=50000
nacos.naming.empty-service.clean.period-time-ms=30000
management.metrics.export.elastic.enabled=false
management.metrics.export.influx.enabled=false
server.tomcat.accesslog.enabled=true
server.tomcat.accesslog.pattern=%h %l %u %t "%r" %s %b %D %{User-Agent}i %{Request-Source}i
server.tomcat.basedir=
nacos.security.ignore.urls=/,/error,/**/*.css,/**/*.js,/**/*.html,/**/*.map,/**/*.svg,/**/*.png,/**/*.ico,/console-ui/public/**,/v1/auth/**,/v1/console/health/**,/actuator/**,/v1/console/server/**
nacos.core.auth.system.type=nacos
nacos.core.auth.enabled=false
nacos.core.auth.default.token.expire.seconds=18000
nacos.core.auth.default.token.secret.key=SecretKey012345678901234567890123456789012345678901234567890123456789
nacos.core.auth.caching.enabled=true
nacos.core.auth.enable.userAgentAuthWhite=false
nacos.core.auth.server.identity.key=serverIdentity
nacos.core.auth.server.identity.value=security
nacos.istio.mcp.server.enabled=false
management.endpoints.web.exposure.include=*
4.2.5 配置JVM内存
sudo vim bin/startup.sh   
    JAVA_OPT="${JAVA_OPT} -server -Xms1g -Xmx1g -Xmn500m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=320m"
4.2.6 复制nacos目录到特定minion中
sudo salt 'ceph0[123]*' cp.get_dir salt://nacos-2.0.3 /usr/local/ saltenv=dev
或者
sudo salt 'ceph0[123]*' cp.get_dir salt://nacos/nacos /usr/local/ saltenv=prod 


5. 启动服务器
5.1 单节点模式
bash startup.sh -m standalone
--集群模式
5.3 使用外置数据源
bash  startup.sh
报错：nacos/bin/startup.sh: [[: not found
解决：将startup.sh和shudown.sh的shell改成#!/bin/bash
执行：bash /usr/local/nacos/bin/startup.sh

6. 查看端口监听状态
[jack@ubuntu:/srv/salt/prod/nacos/nacos]$ sudo salt 'ceph0[123]*' cmd.run 'netstat -tunlp | grep java' 
ceph03.hs.com:
    tcp        0      0 0.0.0.0:8848            0.0.0.0:*               LISTEN      22802/java          
    tcp        0      0 0.0.0.0:9848            0.0.0.0:*               LISTEN      22802/java          
    tcp        0      0 0.0.0.0:9849            0.0.0.0:*               LISTEN      22802/java          
    tcp        0      0 0.0.0.0:7848            0.0.0.0:*               LISTEN      22802/java          
    udp        0      0 0.0.0.0:53011           0.0.0.0:*                           22802/java          
    udp        0      0 0.0.0.0:33994           0.0.0.0:*                           22802/java
ceph02.hs.com:
    tcp        0      0 0.0.0.0:8848            0.0.0.0:*               LISTEN      4089/java           
    tcp        0      0 0.0.0.0:9848            0.0.0.0:*               LISTEN      4089/java           
    tcp        0      0 0.0.0.0:9849            0.0.0.0:*               LISTEN      4089/java           
    tcp        0      0 0.0.0.0:7848            0.0.0.0:*               LISTEN      4089/java           
    udp        0      0 0.0.0.0:21449           0.0.0.0:*                           4089/java           
    udp        0      0 0.0.0.0:64841           0.0.0.0:*                           4089/java
ceph01.hs.com:
    tcp        0      0 0.0.0.0:7848            0.0.0.0:*               LISTEN      17639/java          
    tcp        0      0 0.0.0.0:9848            0.0.0.0:*               LISTEN      17639/java          
    tcp        0      0 0.0.0.0:9849            0.0.0.0:*               LISTEN      17639/java          
    tcp6       0      0 :::8848                 :::*                    LISTEN      17639/java          
    udp6       0      0 :::17244                :::*                                17639/java          
    udp6       0      0 :::15940                :::*                                17639/java



7.测试功能
[root@prometheus rules]# curl -X POST 'http://nacos.k8s.hs.com:8848/nacos/v1/ns/instance?serviceName=nacos.naming.serviceName&ip=20.18.7.10&port=8080'
ok
[root@prometheus rules]# curl -X GET 'http://nacos.k8s.hs.com:8848/nacos/v1/ns/instance/list?serviceName=nacos.naming.serviceName'
{"name":"DEFAULT_GROUP@@nacos.naming.serviceName","groupName":"DEFAULT_GROUP","clusters":"","cacheMillis":10000,"hosts":[],"lastRefTime":1632885516403,"checksum":"","allIPs":false,"reachProtectionThreshold":false,"valid":true}
[root@prometheus rules]# curl -X POST "http://nacos.k8s.hs.com:8848/nacos/v1/cs/configs?dataId=nacos.cfg.dataId&group=test&content=helloWorld"
true
[root@prometheus rules]# curl -X GET "http://nacos.k8s.hs.com:8848/nacos/v1/cs/configs?dataId=nacos.cfg.dataId&group=test"
helloWorld
--注销实例
for i in `seq 1 10`;do curl -sX DELETE "http://192.168.13.31:8848/nacos/v1/ns/instance?serviceName=serverName-test$i&ip=20.18.7.10&port=8080" ;done
--批量注册
for i in `seq 1 10`;do curl -sX POST "http://192.168.13.33:8848/nacos/v1/ns/instance?serviceName=`date +'%S'`-test`openssl rand -hex 10`-test$i&ip=20.18.7.10&port=8080";echo ;done

8. 查看日志排错
for i in `ll -t logs/ | grep -v ' 0 ' | awk '{print $9}' | grep -Ev '^\..*$'`;do echo "jack------------------------logs/$i";tail -n 50 logs/$i;done




nacos扩缩容：
扩容：
node01: 192.168.13.31
node02: 192.168.13.32
node03: 192.168.13.33
新扩容节点: node04: 192.168.13.34
步骤：
1. 在集群所有节点(node01,node02,node03)中，添加新扩容节点ip:port到conf/cluster.conf中并保存
2. 配置添加所有节点包括自己节点到conf/cluster.conf，删除/usr/local/nacos-2.0.3/{data,logs,status,work}目录，然后启动node04的nacos服务。
3. 通过服务注册测试集群任意节点是否正常对外提供服务。
注：扩容过程中可能会短暂影响服务访问，如若新节点服务启动后未成功加入集群，需要重新启动服务重新加入。

缩容：
node01: 192.168.13.31
node02: 192.168.13.32
node03: 192.168.13.33
node04: 192.168.13.34
移除节点：node04: 192.168.13.34
注：移除节点必须在服务停止后移除，必须先停止服务再移除节点
步骤：
1. 停止需要下线节点的服务
2. 在所有节点集群配置文件conf/cluster.conf中删除需要下线的节点。（千万不要在UI下点节点下线，因为这样会使集群崩溃）
3. 通过服务注册测试集群任意节点是否正常对外提供服务。


问题：
1. 当你使用slb访问nacos时，在集群节点管理页面上点击某个节点下线时，会使整个集群崩溃千万不能点。
2. 在正常集群情况下，节点都正常在线，只要停掉其中一个任意节点，此时集群对外服务正常，只需要将停掉的节点修复上线即可使所有节点全部正常对外服务。
3. 在正常集群情况下，当node01停掉一后，再停掉node02，此时集群将不正常，集群正常服务必须最小两个节点同时在线。


#监控nacos
1. 暴露metrics数据
sudo salt 'ceph0[123]*' cmd.run 'sed -i "/management.endpoints.web.exposure.include/c management.endpoints.web.exposure.include=*" /usr/local/nacos-2.0.3/conf/application.properties'
2. 滚动重启服务
sudo salt 'ceph0[1]*' cmd.run 'bash /usr/local/nacos-2.0.3/bin/shutdown.sh && bash /usr/local/nacos-2.0.3/bin/startup.sh'
sudo salt 'ceph0[2]*' cmd.run 'bash /usr/local/nacos-2.0.3/bin/shutdown.sh && bash /usr/local/nacos-2.0.3/bin/startup.sh'
sudo salt 'ceph0[3]*' cmd.run 'bash /usr/local/nacos-2.0.3/bin/shutdown.sh && bash /usr/local/nacos-2.0.3/bin/startup.sh'
3. 配置prometheus.yml
--------------------------
  - job_name: 'consul-nacos'
    scrape_interval: 15s
    metrics_path: /nacos/actuator/prometheus
    consul_sd_configs:
    - server: '192.168.13.236:8500'
      services: []
    relabel_configs:
      - source_labels: [__meta_consul_service]
        regex: .*consul-nacos.*
        action: keep
      - regex: __meta_consul_service_metadata_(.+)
        action: labelmap
      - source_labels: [__address__]
        target_label: instance
--------------------------
4. curl -XPOST http://localhost:9090/-/reload
5. 配置consul
--------------------------
[root@prometheus nacos]# cat nacos_node01-192.168.13.31.json 
{
  "Name": "consul-nacos",
  "ID": "consul-nacos_node01-192.168.13.31",
  "Tags": [
    "nacos"
  ],
  "Address": "192.168.13.31",
  "Port": 8848,
  "Meta": {
    "app": "nacos_node01",
    "env": "pro",
    "project": "services",
    "team": "ops"
  },
  "EnableTagOverride": false,
  "Check": {
    "HTTP": "http://192.168.13.31:8848/nacos/actuator/prometheus",
    "Interval": "10s"
  },
  "Weights": {
    "Passing": 10,
    "Warning": 1
  }
}
--------------------------
6. grafana导入dashboard，dashboardID: 13221



</pre>

