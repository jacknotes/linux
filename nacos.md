# Nacos



[Nacos文档1.0](https://nacos.io/zh-cn/docs/quick-start.html)

[Nacos文档2.0](https://nacos.io/zh-cn/docs/v2/quickstart/quick-start.html)



## 一、服务注册发现产品对比

1. 配置中心:
   	eureka: 不支持
   	consul: 支持，但用起来偏麻烦，不太符合springBoot框架的命名风格，支持动态刷新
   	nacos: 支持，用起来简单，符合springBoot的命名风格，支持动态刷新
2. 注册中心
   1. eureka
      应用内/外：直接集成到应用中，依赖于应用自身完成服务的注册与发现，
      CAP原则：遵循AP（可用性+分离容忍）原则，有较强的可用性，服务注册快，但牺牲了一定的一致性。
      版本迭代：目前已经不进行升级
      集成支持：只支持SpringCloud集成
      访问协议：HTTP
      雪崩保护：支持雪崩保护
      界面：英文界面，不符合国人习惯
      上手：容易
   2. consul
      应用内/外：属于外部应用，侵入性小
      CAP原则：遵循CP原则（一致性+分离容忍） 服务注册稍慢，由于其一致性导致了在Leader挂掉时重新选举期间真个consul不可用。
      版本迭代：目前仍然进行版本迭代
      集成支持：支持SpringCloud、K8S集成
      访问协议：HTTP/DNS
      雪崩保护：不支持雪崩保护
      界面：英文界面，不符合国人习惯
      上手：复杂一点
   3. nacos
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
  1. AP协议：Distro协议。
  2. Distro是阿里巴巴的私有协议，目前流行的 Nacos服务管理框架就采用了 Distro协议。Distro 协议被定位为 临时数据的一致性协议 ：该类型协议不需要把数据存储到磁盘或者数据库 ，因为临时数据通常和服务器保持一个session会话， 该会话只要存在，数据就不会丢失 。
  3. Distro 协议保证写必须永远是成功的，即使可能会发生网络分区。当网络恢复时，把各数据分片的数据进行合并。

3. Distro 协议具有以下特点：
  1. 专门为了注册中心而创造出的协议；
  2. 客户端与服务端有两个重要的交互，服务注册与心跳发送；客户端以服务为维度向服务端注册，注册后每隔一段时间向服务端发送一次心跳，心跳包需要带上注册服务的全部信息，在客户端看来，服务端节点对等，所以请求的节点是随机的；客户端请求失败则换一个节点重新发送请求；
  3. 服务端节点都存储所有数据，但每个节点只负责其中一部分服务，在接收到客户端的“写”（注册、心跳、下线等）请求后，服务端节点判断请求的服务是否为自己负责，如果是，则处理，否则交由负责的节点处理；
  4. 每个服务端节点主动发送健康检查到其他节点，响应的节点被该节点视为健康节点；
  5. 服务端在接收到客户端的服务心跳后，如果该服务不存在，则将该心跳请求当做注册请求来处理；服务端如果长时间未收到客户端心跳，则下线该服务；
  6. 负责的节点在接收到服务注册、服务心跳等写请求后将数据写入后即返回，后台异步地将数据同步给其他节点；
  7. 节点在收到读请求后直接从本机获取后返回，无论数据是否为最新。




## 二、部署nacos2.0.3



### 2.1 docker部署单节点

```bash
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
#初始帐户密码		nacos:nacos
#http端口8848,grpc端口加1000是9848
```



### 2.2 源码方式部署集群

#### 2.2.1 环境准备
64 bit OS Linux/Unix/Mac，推荐使用Linux系统，这里使用Ubuntu18.04 。
64 bit JDK 1.8+。
3个或3个以上Nacos节点才能构成集群。



#### 2.2.2 安装openjdk
```bash
[jack@ubuntu:/srv/salt/prod/nacos/nacos]$ sudo salt 'ceph0[123]*' cmd.run 'sudo apt install -y openjdk-8-jdk'
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
```



#### 2.2.3 安装和配置nacos
```bash
# 下载nacos安装包
sudo curl -OL https://github.com/alibaba/nacos/releases/download/2.0.3/nacos-server-2.0.3.tar.gz
sudo tar -xvf nacos-server-2.0.3.tar.gz
cd nacos


# 配置集群配置文件
[jack@ubuntu:/srv/salt/prod/nacos/nacos]$ sudo cp conf/cluster.conf.example conf/cluster.conf
[jack@ubuntu:/srv/salt/prod/nacos/nacos]$ sudo cat conf/cluster.conf
#it is ip
#example
192.168.13.31
192.168.13.32
192.168.13.33

# 确定数据源
使用内置数据源: 无需进行任何配置
使用外置数据源: 生产使用建议至少主备模式，或者采用高可用数据库。

# 使用外置数据源，配置数据库
## 初始化 MySQL 数据库--tar.gz包中conf目录下有nacos-mysql.sql和application.properties文件。conf/schema.sql文件不是mysql文件，不要导入错了，是 Derby 数据库的脚本
sudo curl -OL https://raw.githubusercontent.com/alibaba/nacos/master/distribution/conf/nacos-mysql.sql
use nacos_config;
source ./nacos-mysql.sql
grant all on nacos_config.* to nacos@'192.168.13.%' identified by 'nacos@service';

# application.properties 配置
sudo curl -OL https://raw.githubusercontent.com/alibaba/nacos/master/distribution/conf/application.properties
## 修改conf/application.properties文件，增加支持mysql数据源配置（目前只支持mysql），添加mysql数据源的url、用户名和密码，mysql库名是nacos_config，并且开启metric提供监控
server.servlet.contextPath=/nacos
db.num=1
db.url.0=jdbc:mysql://devmysql.hs.com:3306/nacos_config?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=UTC
db.user.0=nacos
db.password.0=nacos@service
management.endpoints.web.exposure.include=*

# 更改后的conf/application.properties配置
[jack@ubuntu:/srv/salt/prod/nacos/nacos]$ grep -Ev '#|^$' conf/application.properties
server.servlet.contextPath=/nacos     #http请求URI路径
server.port=8848
db.num=1
db.url.0=jdbc:mysql://devmysql.hs.com:3306/nacos_config?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=UTC
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

# 配置JVM内存
sudo vim bin/startup.sh   
 JAVA_OPT="${JAVA_OPT} -server -Xms1g -Xmx1g -Xmn500m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=320m"

# 复制nacos目录到特定minion中
sudo salt 'ceph0[123]*' cp.get_dir salt://nacos-2.0.3 /usr/local/ saltenv=dev
或者
sudo salt 'ceph0[123]*' cp.get_dir salt://nacos/nacos /usr/local/ saltenv=prod 
```



#### 2.2.4 启动nacos服务
##### 2.2.4.1 单节点模式
bash startup.sh -m standalone

##### 2.2.4.2 集群模式
bash  startup.sh

报错：nacos/bin/startup.sh: [[: not found
解决：将startup.sh和shudown.sh的shell改成#!/bin/bash
执行：bash /usr/local/nacos/bin/startup.sh



#### 2.2.5 检查端口监听状态
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



#### 2.2.6 测试nacos功能
```bash
[root@prometheus rules]# curl -X POST 'http://nacos.k8s.hs.com:8848/nacos/v1/ns/instance?serviceName=nacos.naming.serviceName&ip=20.18.7.10&port=8080'
ok
[root@prometheus rules]# curl -X GET 'http://nacos.k8s.hs.com:8848/nacos/v1/ns/instance/list?serviceName=nacos.naming.serviceName'
{"name":"DEFAULT_GROUP@@nacos.naming.serviceName","groupName":"DEFAULT_GROUP","clusters":"","cacheMillis":10000,"hosts":[],"lastRefTime":1632885516403,"checksum":"","allIPs":false,"reachProtectionThreshold":false,"valid":true}
[root@prometheus rules]# curl -X POST "http://nacos.k8s.hs.com:8848/nacos/v1/cs/configs?dataId=nacos.cfg.dataId&group=test&content=helloWorld"
true
[root@prometheus rules]# curl -X GET "http://nacos.k8s.hs.com:8848/nacos/v1/cs/configs?dataId=nacos.cfg.dataId&group=test"
helloWorld
# 注销实例
for i in `seq 1 10`;do curl -sX DELETE "http://192.168.13.31:8848/nacos/v1/ns/instance?serviceName=serverName-test$i&ip=20.18.7.10&port=8080" ;done
# 批量注册
for i in `seq 1 10`;do curl -sX POST "http://192.168.13.33:8848/nacos/v1/ns/instance?serviceName=`date +'%S'`-test`openssl rand -hex 10`-test$i&ip=20.18.7.10&port=8080";echo ;done
```



#### 2.2.7 查看日志排错
```bash
for i in `ll -t logs/ | grep -v ' 0 ' | awk '{print $9}' | grep -Ev '^\..*$'`;do echo "jack------------------------logs/$i";tail -n 50 logs/$i;done
```





### 2.3 nacos扩缩容：

#### 2.3.1 扩容

原有节点：
node01: 192.168.13.31
node02: 192.168.13.32
node03: 192.168.13.33

新扩容节点: 

node04: 192.168.13.34

步骤：

1. 在集群所有节点(node01,node02,node03)中，添加新扩容节点ip:port到conf/cluster.conf中并保存

2. 配置添加所有节点包括本身节点到conf/cluster.conf，删除/usr/local/nacos-2.0.3/{data,logs,status,work}目录，然后启动node04的nacos服务。

3. 通过服务注册测试集群任意节点是否正常对外提供服务。
    注：扩容过程中可能会短暂影响服务访问，如若新节点服务启动后未成功加入集群，需要重新启动服务重新加入。

  

#### 2.3.2 缩容
现有节点：

node01: 192.168.13.31
node02: 192.168.13.32
node03: 192.168.13.33
node04: 192.168.13.34

移除节点：

node04: 192.168.13.34

`注：移除节点必须在服务停止后移除，必须先停止服务再移除节点`

步骤：

1. 停止需要下线节点的服务
2. 在所有节点集群配置文件conf/cluster.conf中删除需要下线的节点。（千万不要在UI下点节点下线，因为这样会使集群崩溃）
3. 通过服务注册测试集群任意节点是否正常对外提供服务。


问题：
1. 当你使用slb访问nacos时，在集群节点管理页面上点击某个节点下线时，会使整个集群崩溃千万不能点。
2. 在正常集群情况下，节点都正常在线，只要停掉其中一个任意节点，此时集群对外服务正常，只需要将停掉的节点修复上线即可使所有节点全部正常对外服务。
3. 在正常集群情况下，当node01停掉一后，再停掉node02，此时集群将不正常，集群正常服务必须最小两个节点同时在线。



### 2.4 nacos监控

```bash
# 暴露metrics数据
sudo salt 'ceph0[123]*' cmd.run 'sed -i "/management.endpoints.web.exposure.include/c management.endpoints.web.exposure.include=*" /usr/local/nacos-2.0.3/conf/application.properties'

# 滚动重启服务
sudo salt 'ceph0[1]*' cmd.run 'bash /usr/local/nacos-2.0.3/bin/shutdown.sh && bash /usr/local/nacos-2.0.3/bin/startup.sh'
sudo salt 'ceph0[2]*' cmd.run 'bash /usr/local/nacos-2.0.3/bin/shutdown.sh && bash /usr/local/nacos-2.0.3/bin/startup.sh'
sudo salt 'ceph0[3]*' cmd.run 'bash /usr/local/nacos-2.0.3/bin/shutdown.sh && bash /usr/local/nacos-2.0.3/bin/startup.sh'

# 配置prometheus.yml
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

# 重载prometheus服务
curl -XPOST http://localhost:9090/-/reload

# 配置consul
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

# grafana导入dashboard，dashboardID: 13221
```









## 三、部署nacos2.2.3



### 3.1 Nacos部署环境

Nacos定义为一个IDC内部应用组件，并非面向公网环境的产品，建议在内部隔离网络环境中部署，强烈不建议部署在公共网络环境。



### 3.2 Nacos支持三种部署模式

- 单机模式 - 用于测试和单机试用。
- 集群模式 - 用于生产环境，确保高可用。
- 多集群模式 - 用于多数据中心场景。



### 3.3 源码方式部署单集群

当前推荐的稳定版本为2.2.3



#### 3.3.1 环境准备

你可以通过源码和发行包两种方式来获取 Nacos。

Nacos 依赖 [Java](https://docs.oracle.com/cd/E19182-01/820-7851/inst_cli_jdk_javahome_t/) 环境来运行。如果您是从代码开始构建并运行Nacos，还需要为此配置 [Maven](https://maven.apache.org/index.html)环境，请确保是在以下版本环境中安装使用:

1. 64 bit OS，支持 Linux/Unix/Mac/Windows，推荐选用 Linux/Unix/Mac。
2. 64 bit JDK 1.8+；
3. Maven 3.2.x+；

- 安装好 JDK，需要 1.8 及其以上版本
- 建议: 2核 CPU / 4G 内存 及其以上
- 建议: 生产环境 3 个节点 及其以上

```bash
nacos01 172.168.2.18
nacos02 172.168.2.19
nacos03 172.168.2.20
nginx 172.168.2.12
```



#### 3.3.2 发行包方式安装

##### 3.3.2.1 安装jdk1.8

[jdk下载地址](https://repo.huaweicloud.com/java/jdk/)

```bash
root@ansible:~# ansible nacos -m copy -a 'src=/download/jdk-8u201-linux-x64.tar.gz dest=/download/'
root@ansible:~# ansible nacos -m shell -a 'tar xf /download/jdk-8u201-linux-x64.tar.gz -C /usr/local && ln -s /usr/local/jdk1.8.0_201 /usr/local/jdk'
root@ansible:~# ansible nacos -m shell -a "echo 'export PATH=$PATH:/usr/local/jdk/bin' > /etc/profile.d/jdk.sh && source /etc/profile"

root@ansible:~# ansible nacos -m shell -a "java -version"
172.168.2.20 | SUCCESS | rc=0 >>
java version "1.8.0_201"
Java(TM) SE Runtime Environment (build 1.8.0_201-b09)
Java HotSpot(TM) 64-Bit Server VM (build 25.201-b09, mixed mode)

172.168.2.19 | SUCCESS | rc=0 >>
java version "1.8.0_201"
Java(TM) SE Runtime Environment (build 1.8.0_201-b09)
Java HotSpot(TM) 64-Bit Server VM (build 25.201-b09, mixed mode)

172.168.2.18 | SUCCESS | rc=0 >>
java version "1.8.0_201"
Java(TM) SE Runtime Environment (build 1.8.0_201-b09)
Java HotSpot(TM) 64-Bit Server VM (build 25.201-b09, mixed mode)

```



##### 3.3.2.2 ansible分发软件包

[nacos2.2.3发行包](https://github.com/alibaba/nacos/releases/download/2.2.3/nacos-server-2.2.3.tar.gz)

```bash
root@ansible:/download# curl -OL https://github.com/alibaba/nacos/releases/download/2.2.3/nacos-server-2.2.3.tar.gz
root@ansible:/download# ls nacos-server-2.2.3.tar.gz 
nacos-server-2.2.3.tar.gz
# 分发软件包
root@ansible:/download# ansible nacos -m copy -a 'src=/download/nacos-server-2.2.3.tar.gz dest=/download/'
root@ansible:/download# ansible nacos -m shell -a 'tar -xf /download/nacos-server-2.2.3.tar.gz -C /usr/local/'
```



##### 3.3.2.3 配置集群配置文件

```bash
# 配置cluster.conf
root@ansible:~/tmp/nacos# cat conf/cluster.conf
# ip:port
172.168.2.18:8848
172.168.2.19:8848
172.168.2.20:8848
root@ansible:~/tmp/nacos# ansible nacos -m copy -a 'src=./conf/cluster.conf dest=/usr/local/nacos/conf/'

root@ansible:~/tmp/nacos# ansible nacos -m shell -a 'cat /usr/local/nacos/conf/cluster.conf'
172.168.2.18 | SUCCESS | rc=0 >>
# ip:port
172.168.2.18:8848
172.168.2.19:8848
172.168.2.20:8848

172.168.2.20 | SUCCESS | rc=0 >>
# ip:port
172.168.2.18:8848
172.168.2.19:8848
172.168.2.20:8848

172.168.2.19 | SUCCESS | rc=0 >>
# ip:port
172.168.2.18:8848
172.168.2.19:8848
172.168.2.20:8848
```



##### 3.3.2.4 确定并配置数据源

`使用内置数据源：则无需配置`

`使用外置数据源，目前仅支持mysql`

我们使用外置数据源，使用mysql主主集群

```bash
# 下载sql语句源文件
root@ansible:~/tmp/nacos# curl -OL https://github.com/alibaba/nacos/blob/master/distribution/conf/mysql-schema.sql

# 配置数据库
create database nacos_config;
source ./nacos-mysql.sql
grant all on nacos_config.* to nacos@'%' identified by 'nacos@service';
```



##### 3.3.2.5  配置application.properties

```bash
root@ansible:~/tmp/nacos# curl -OL https://github.com/alibaba/nacos/blob/master/distribution/conf/application.properties
## 配置application.properties，信息如下
server.servlet.contextPath=/nacos
server.port=8848
spring.sql.init.platform=mysql
db.num=1
db.url.0=jdbc:mysql://devmysql.hs.com:3306/nacos_config?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=Asia/Shanghai
db.user.0=nacos
db.password.0=nacos@service
## 开启prometheus监控
management.endpoints.web.exposure.include=*	

## 整个配置文件如下
root@ansible:~/tmp/nacos/conf# grep -Ev '#|^$' application.properties
server.servlet.contextPath=/nacos
server.error.include-message=ALWAYS
server.port=8848
spring.sql.init.platform=mysql
db.num=1
db.url.0=jdbc:mysql://devmysql.hs.com:3306/nacos_config?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=Asia/Shanghai
db.user.0=nacos
db.password.0=nacos@service
db.pool.config.connectionTimeout=30000
db.pool.config.validationTimeout=10000
db.pool.config.maximumPoolSize=20
db.pool.config.minimumIdle=2
nacos.config.push.maxRetryTime=50
server.tomcat.mbeanregistry.enabled=true
management.endpoints.web.exposure.include=*
management.metrics.export.elastic.enabled=false
management.metrics.export.influx.enabled=false
server.tomcat.accesslog.enabled=true
server.tomcat.accesslog.rotate=true
server.tomcat.accesslog.file-date-format=.yyyy-MM-dd-HH
server.tomcat.accesslog.pattern=%h %l %u %t "%r" %s %b %D %{User-Agent}i %{Request-Source}i
server.tomcat.basedir=file:.
nacos.security.ignore.urls=/,/error,/**/*.css,/**/*.js,/**/*.html,/**/*.map,/**/*.svg,/**/*.png,/**/*.ico,/console-ui/public/**,/v1/auth/**,/v1/console/health/**,/actuator/**,/v1/console/server/**
nacos.core.auth.system.type=nacos
nacos.core.auth.enabled=false
nacos.core.auth.caching.enabled=true
nacos.core.auth.enable.userAgentAuthWhite=false
nacos.core.auth.server.identity.key=
nacos.core.auth.server.identity.value=
nacos.core.auth.plugin.nacos.token.cache.enable=false
nacos.core.auth.plugin.nacos.token.expire.seconds=18000
nacos.core.auth.plugin.nacos.token.secret.key=
nacos.istio.mcp.server.enabled=false

# 分发配置文件到所有nacos节点(3个节点)
root@ansible:~/tmp/nacos/conf# ansible nacos -mcopy -a 'src=./application.properties dest=/usr/local/nacos/conf/ backup=true'

# 验证下发的配置是否更改生效
root@ansible:~/tmp/nacos/conf# ansible nacos -m shell -a 'grep "devmysql.hs.com" /usr/local/nacos/conf/application.properties'
172.168.2.18 | SUCCESS | rc=0 >>
db.url.0=jdbc:mysql://devmysql.hs.com:3306/nacos_config?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=Asia/Shanghai

172.168.2.19 | SUCCESS | rc=0 >>
db.url.0=jdbc:mysql://devmysql.hs.com:3306/nacos_config?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=Asia/Shanghai

172.168.2.20 | SUCCESS | rc=0 >>
db.url.0=jdbc:mysql://devmysql.hs.com:3306/nacos_config?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=Asia/Shanghai
```



##### 3.3.2.6 配置JVM内存限制 

```bash
# 复制启动脚本模板文件
root@ansible:~/tmp/nacos/conf# ansible 172.168.2.18 -m fetch -a 'src=/usr/local/nacos/bin/startup.sh dest=./ flat=true'

# 编辑内存配置
root@ansible:~/tmp/nacos/conf# grep -C 5 'Xmx' startup.sh

#===========================================================================================
# JVM Configuration
#===========================================================================================
if [[ "${MODE}" == "standalone" ]]; then
    JAVA_OPT="${JAVA_OPT} -Xms512m -Xmx512m -Xmn256m"
    JAVA_OPT="${JAVA_OPT} -Dnacos.standalone=true"
else
    if [[ "${EMBEDDED_STORAGE}" == "embedded" ]]; then
        JAVA_OPT="${JAVA_OPT} -DembeddedStorage=true"
    fi
    JAVA_OPT="${JAVA_OPT} -server -Xms1g -Xmx1g -Xmn500m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=320m"
    JAVA_OPT="${JAVA_OPT} -XX:-OmitStackTraceInFastThrow -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${BASE_DIR}/logs/java_heapdump.hprof"
    JAVA_OPT="${JAVA_OPT} -XX:-UseLargePages"

fi


# 复制start.sh脚本到所有nacos节点(3节点)
root@ansible:~/tmp/nacos/conf# ansible nacos -m copy -a 'src=./startup.sh dest=/usr/local/nacos/bin/startup.sh backup=yes'

# 验证下发的配置
root@ansible:~/tmp/nacos/conf# ansible nacos -m shell -a "grep -C 2 'Xmx' /usr/local/nacos/bin/startup.sh"
172.168.2.18 | SUCCESS | rc=0 >>
        JAVA_OPT="${JAVA_OPT} -DembeddedStorage=true"
    fi
    JAVA_OPT="${JAVA_OPT} -server -Xms256m -Xmx256m -Xmn128m -XX:MetaspaceSize=16m -XX:MaxMetaspaceSize=32m"
    JAVA_OPT="${JAVA_OPT} -XX:-OmitStackTraceInFastThrow -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${BASE_DIR}/logs/java_heapdump.hprof"
    JAVA_OPT="${JAVA_OPT} -XX:-UseLargePages"

172.168.2.19 | SUCCESS | rc=0 >>
        JAVA_OPT="${JAVA_OPT} -DembeddedStorage=true"
    fi
    JAVA_OPT="${JAVA_OPT} -server -Xms256m -Xmx256m -Xmn128m -XX:MetaspaceSize=16m -XX:MaxMetaspaceSize=32m"
    JAVA_OPT="${JAVA_OPT} -XX:-OmitStackTraceInFastThrow -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${BASE_DIR}/logs/java_heapdump.hprof"
    JAVA_OPT="${JAVA_OPT} -XX:-UseLargePages"

172.168.2.20 | SUCCESS | rc=0 >>
        JAVA_OPT="${JAVA_OPT} -DembeddedStorage=true"
    fi
    JAVA_OPT="${JAVA_OPT} -server -Xms256m -Xmx256m -Xmn128m -XX:MetaspaceSize=16m -XX:MaxMetaspaceSize=32m"
    JAVA_OPT="${JAVA_OPT} -XX:-OmitStackTraceInFastThrow -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${BASE_DIR}/logs/java_heapdump.hprof"
    JAVA_OPT="${JAVA_OPT} -XX:-UseLargePages"
```



##### 3.3.2.7 启动nacos集群

```bash
# 启动集群服务命令
bash /usr/local/nacos/bin/startup.sh

如果报错：nacos/bin/startup.sh: [[: not found
解决办法：将startup.sh和shudown.sh的shell从/bin/sh改成/bin/bash
最终执行：bash /usr/local/nacos/bin/startup.sh

# 启动所有节点nacos服务
root@ansible:~/tmp/nacos/conf# ansible nacos -m shell -a 'bash /usr/local/nacos/bin/startup.sh'

# 查看所有nacos节点运行状态
root@ansible:~/tmp/nacos/conf# ansible nacos -m shell -a 'ps -ef | grep nacos'
root@ansible:~/tmp/nacos/conf# ansible nacos -m shell -a 'netstat -tnlp | grep java'
172.168.2.19 | SUCCESS | rc=0 >>
tcp        0      0 0.0.0.0:7848            0.0.0.0:*               LISTEN      45932/java
tcp        0      0 0.0.0.0:8848            0.0.0.0:*               LISTEN      45932/java
tcp        0      0 0.0.0.0:9848            0.0.0.0:*               LISTEN      45932/java
tcp        0      0 0.0.0.0:9849            0.0.0.0:*               LISTEN      45932/java

172.168.2.18 | SUCCESS | rc=0 >>
tcp        0      0 0.0.0.0:9848            0.0.0.0:*               LISTEN      46825/java
tcp        0      0 0.0.0.0:9849            0.0.0.0:*               LISTEN      46825/java
tcp        0      0 0.0.0.0:7848            0.0.0.0:*               LISTEN      46825/java
tcp        0      0 0.0.0.0:8848            0.0.0.0:*               LISTEN      46825/java

172.168.2.20 | SUCCESS | rc=0 >>
tcp        0      0 0.0.0.0:8848            0.0.0.0:*               LISTEN      45798/java
tcp        0      0 0.0.0.0:9848            0.0.0.0:*               LISTEN      45798/java
tcp        0      0 0.0.0.0:9849            0.0.0.0:*               LISTEN      45798/java
tcp        0      0 0.0.0.0:7848            0.0.0.0:*               LISTEN      45798/java

# 停止所有节点nacos服务
root@ansible:~/tmp/nacos/conf# ansible nacos -m shell -a 'bash /usr/local/nacos/bin/shutdown.sh'
```



#### 3.3.3 配置SLB

| 端口 | 与主端口的偏移量 | 描述                                                       |
| ---- | ---------------- | ---------------------------------------------------------- |
| 8848 | 0                | 主端口，客户端、控制台及OpenAPI所使用的HTTP端口            |
| 9848 | 1000             | 客户端gRPC请求服务端端口，用于客户端向服务端发起连接和请求 |
| 9849 | 1001             | 服务端gRPC请求服务端端口，用于服务间同步等                 |
| 7848 | -1000            | Jraft请求服务端端口，用于处理服务端间的Raft相关请求        |

**使用VIP/nginx请求时，需要配置成TCP转发，不能配置http2转发，否则连接会被nginx断开。** **9849和7848端口为服务端之间的通信端口，请勿暴露到外部网络环境和客户端测。**



**nginx L4 proxy**

```bash
# nginx ip: 172.168.2.12
root@ansible:/usr/local/nginx/conf# cat nginx.conf
worker_processes  2;
worker_rlimit_nofile 65535;
error_log  logs/error.log;

events {
        use epoll;
        worker_connections  65535;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  logs/access.log  main;
    sendfile        on;
    keepalive_timeout  65;
    gzip  on;

    server {
        listen       80;
        server_name  localhost;


        location / {
            root   html;
            index  index.html index.htm;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
}


stream {
        upstream nacos_http {
                server 172.168.2.18:8848;
                server 172.168.2.19:8848;
                server 172.168.2.20:8848;
                ## 需要增加nginx编译模块方可支持--add-module=modules/ngx_http_upstream_check_module
                #check interval=3000 rise=2 fall=3 timeout=3000 type=tcp;
        }

        upstream nacos_grpc {
                server 172.168.2.18:9848;
                server 172.168.2.19:9848;
                server 172.168.2.20:9848;
                #check interval=3000 rise=2 fall=3 timeout=3000 type=tcp;
        }

        server {
                listen 8848;
                proxy_connect_timeout 5s;
                proxy_pass nacos_http;
        }

        server {
                listen 9848;
                proxy_connect_timeout 5s;
                proxy_pass nacos_grpc;
        }
}

# 应用nginx
root@ansible:/usr/local/nginx/conf# service nginx reload
root@ansible:/usr/local/nginx/conf# ss -tnl
State                          Recv-Q                          Send-Q                                                    Local Address:Port                                                   Peer Address:Port
LISTEN                         0                               128                                                             0.0.0.0:8848                                                        0.0.0.0:*
LISTEN                         0                               128                                                             0.0.0.0:80                                                          0.0.0.0:*
LISTEN                         0                               128                                                             0.0.0.0:22                                                          0.0.0.0:*
LISTEN                         0                               128                                                             0.0.0.0:9848                                                        0.0.0.0:*
LISTEN                         0                               128                                                                [::]:22                                                             [::]:*
```



#### 3.3.4 nacos测试

```bash
# 服务注册
root@ansible:/usr/local/nginx/conf# curl -X POST 'http://172.168.2.12:8848/nacos/v1/ns/instance?serviceName=nacos.naming.serviceName&ip=20.18.7.10&port=8080';echo
ok

# 服务发现
root@ansible:/usr/local/nginx/conf# curl -s -X GET 'http://172.168.2.12:8848/nacos/v1/ns/instance/list?serviceName=nacos.naming.serviceName' | jq .
{
  "name": "DEFAULT_GROUP@@nacos.naming.serviceName",
  "groupName": "DEFAULT_GROUP",
  "clusters": "",
  "cacheMillis": 10000,
  "hosts": [
    {
      "instanceId": "20.18.7.10#8080#DEFAULT#DEFAULT_GROUP@@nacos.naming.serviceName",
      "ip": "20.18.7.10",
      "port": 8080,
      "weight": 1,
      "healthy": false,
      "enabled": true,
      "ephemeral": true,
      "clusterName": "DEFAULT",
      "serviceName": "DEFAULT_GROUP@@nacos.naming.serviceName",
      "metadata": {},
      "instanceHeartBeatInterval": 5000,
      "instanceHeartBeatTimeOut": 15000,
      "ipDeleteTimeout": 30000,
      "instanceIdGenerator": "simple"
    }
  ],
  "lastRefTime": 1700745082854,
  "checksum": "",
  "allIPs": false,
  "reachProtectionThreshold": false,
  "valid": true
}

# 配置注册
root@ansible:/usr/local/nginx/conf# curl -X POST "http://172.168.2.12:8848/nacos/v1/cs/configs?dataId=nacos.cfg.dataId&group=test&content=helloWorld"
true

# 配置获取
root@ansible:/usr/local/nginx/conf# curl -s -X GET "http://172.168.2.12:8848/nacos/v1/cs/configs?dataId=nacos.cfg.dataId&group=test";echo
helloWorld

# 批量注册
for i in `seq 1 10`;do curl -sX POST "http://172.168.2.12:8848/nacos/v1/ns/instance?serviceName=`date +'%S'`-test`openssl rand -hex 10`-test$i&ip=20.18.7.10&port=8080";echo ;done

# 注销实例
for i in `seq 1 10`;do curl -sX DELETE "http://172.168.2.18:8848/nacos/v1/ns/instance?serviceName=serverName-test$i&ip=20.18.7.10&port=8080" ;done
```



#### 3.3.5 nacos监控

```bash
# 配置consul
[root@prometheus nacos]# cat nacos_node01-192.168.13.31.json 
{
  "Name": "consul-nacos",
  "ID": "consul-nacos01-172.168.2.18",
  "Tags": [
    "nacos"
  ],
  "Address": "172.168.2.18",
  "Port": 8848,
  "Meta": {
    "app": "nacos01",
    "env": "test",
    "project": "services",
    "team": "ops"
  },
  "EnableTagOverride": false,
  "Check": {
    "HTTP": "http://172.168.2.18:8848/nacos/actuator/prometheus",
    "Interval": "10s"
  },
  "Weights": {
    "Passing": 10,
    "Warning": 1
  }
}


# 配置prometheus.yml
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

# 重载prometheus服务
curl -XPOST http://localhost:9090/-/reload

# grafana导入dashboard，dashboardID: 13221
```



#### 3.3.6 单节点服务重启测试

##### 3.3.6.1 节点列表

![节点列表](./image/nacos/nacos01.png)

leader信息查看

![leader查看](./image/nacos/nacos02.png)



##### 3.3.6.2 停止leader节点服务

```bash
# 停止nacos02-172.168.2.19，此节点为leader
root@ansible:~# ansible 172.168.2.19 -m shell -a 'bash /usr/local/nacos/bin/shutdown.sh'
172.168.2.19 | SUCCESS | rc=0 >>
The nacosServer(47951) is running...
Send shutdown request to nacosServer(47951) OK

root@ansible:~# ansible nacos -m shell -a 'netstat -tnlp | grep java'
172.168.2.18 | SUCCESS | rc=0 >>
tcp        0      0 0.0.0.0:9848            0.0.0.0:*               LISTEN      48902/java
tcp        0      0 0.0.0.0:9849            0.0.0.0:*               LISTEN      48902/java
tcp        0      0 0.0.0.0:7848            0.0.0.0:*               LISTEN      48902/java
tcp        0      0 0.0.0.0:8848            0.0.0.0:*               LISTEN      48902/java

172.168.2.20 | SUCCESS | rc=0 >>
tcp        0      0 0.0.0.0:8848            0.0.0.0:*               LISTEN      47822/java
tcp        0      0 0.0.0.0:9848            0.0.0.0:*               LISTEN      47822/java
tcp        0      0 0.0.0.0:9849            0.0.0.0:*               LISTEN      47822/java
tcp        0      0 0.0.0.0:7848            0.0.0.0:*               LISTEN      47822/java

172.168.2.19 | FAILED | rc=1 >>
non-zero return code
```

![节点下线后状态](./image/nacos/nacos03.png)



![新leader查看](./image/nacos/nacos04.png)



##### 3.3.6.3 启动停止的节点服务

```bash
root@ansible:~# ansible 172.168.2.19 -m shell -a 'bash /usr/local/nacos/bin/startup.sh'
root@ansible:~# ansible nacos -m shell -a 'netstat -tnlp | grep java'
172.168.2.19 | SUCCESS | rc=0 >>
tcp        0      0 0.0.0.0:7848            0.0.0.0:*               LISTEN      88406/java
tcp        0      0 0.0.0.0:8848            0.0.0.0:*               LISTEN      88406/java
tcp        0      0 0.0.0.0:9848            0.0.0.0:*               LISTEN      88406/java
tcp        0      0 0.0.0.0:9849            0.0.0.0:*               LISTEN      88406/java

172.168.2.18 | SUCCESS | rc=0 >>
tcp        0      0 0.0.0.0:9848            0.0.0.0:*               LISTEN      48902/java
tcp        0      0 0.0.0.0:9849            0.0.0.0:*               LISTEN      48902/java
tcp        0      0 0.0.0.0:7848            0.0.0.0:*               LISTEN      48902/java
tcp        0      0 0.0.0.0:8848            0.0.0.0:*               LISTEN      48902/java

172.168.2.20 | SUCCESS | rc=0 >>
tcp        0      0 0.0.0.0:8848            0.0.0.0:*               LISTEN      47822/java
tcp        0      0 0.0.0.0:9848            0.0.0.0:*               LISTEN      47822/java
tcp        0      0 0.0.0.0:9849            0.0.0.0:*               LISTEN      47822/java
tcp        0      0 0.0.0.0:7848            0.0.0.0:*               LISTEN      47822/java
```

![节点列表](./image/nacos/nacos05.png)

![重新上线节点的leader信息](./image/nacos/nacos04.png)



#### 3.3.7 所有节点服务重启测试

```bash
# 所有nacos节点服务关闭
root@ansible:~# ansible nacos -m shell -a 'bash /usr/local/nacos/bin/shutdown.sh'

root@ansible:~# ansible nacos -m shell -a 'ps -ef | grep nacos'
172.168.2.19 | SUCCESS | rc=0 >>
root      89340  89335  0 17:12 pts/0    00:00:00 /bin/sh -c ps -ef | grep nacos
root      89342  89340  0 17:12 pts/0    00:00:00 grep nacos

172.168.2.20 | SUCCESS | rc=0 >>
root      88856  88851 48 17:12 pts/0    00:00:00 /bin/sh -c ps -ef | grep nacos
root      88858  88856  0 17:12 pts/0    00:00:00 grep nacos

172.168.2.18 | SUCCESS | rc=0 >>
root      90186  90181 49 17:12 pts/1    00:00:00 /bin/sh -c ps -ef | grep nacos
root      90188  90186  0 17:12 pts/1    00:00:00 grep nacos

# 确定停止nacos服务
root@ansible:~# ansible nacos -m shell -a 'netstat -tnlp | grep java'
172.168.2.19 | FAILED | rc=1 >>
non-zero return code

172.168.2.20 | FAILED | rc=1 >>
non-zero return code

172.168.2.18 | FAILED | rc=1 >>
non-zero return code


# 启动所有nacos节点服务
root@ansible:~# ansible nacos -m shell -a 'bash /usr/local/nacos/bin/startup.sh'

# 经过2分钟，服务已经正常启动
root@ansible:~# ansible nacos -m shell -a 'netstat -tnlp | grep java'
172.168.2.18 | SUCCESS | rc=0 >>
tcp        0      0 0.0.0.0:9848            0.0.0.0:*               LISTEN      90340/java
tcp        0      0 0.0.0.0:9849            0.0.0.0:*               LISTEN      90340/java
tcp        0      0 0.0.0.0:7848            0.0.0.0:*               LISTEN      90340/java
tcp        0      0 0.0.0.0:8848            0.0.0.0:*               LISTEN      90340/java

172.168.2.19 | SUCCESS | rc=0 >>
tcp        0      0 0.0.0.0:7848            0.0.0.0:*               LISTEN      89495/java
tcp        0      0 0.0.0.0:8848            0.0.0.0:*               LISTEN      89495/java
tcp        0      0 0.0.0.0:9848            0.0.0.0:*               LISTEN      89495/java
tcp        0      0 0.0.0.0:9849            0.0.0.0:*               LISTEN      89495/java

172.168.2.20 | SUCCESS | rc=0 >>
tcp        0      0 0.0.0.0:8848            0.0.0.0:*               LISTEN      89011/java
tcp        0      0 0.0.0.0:9848            0.0.0.0:*               LISTEN      89011/java
tcp        0      0 0.0.0.0:9849            0.0.0.0:*               LISTEN      89011/java
tcp        0      0 0.0.0.0:7848            0.0.0.0:*               LISTEN      89011/java

# 经过测试，结果正常
root@ansible:~# for i in `seq 1 10`;do curl -sX POST "http://172.168.2.12:8848/nacos/v1/ns/instance?accessToken=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwMDAxIiwiZXhwIjoxNzAwODIxNDgzfQ.u62DGzo3ce0zn2JW2NIB63aDWpUDdsd9bRouQC2vUgE&serviceName=`date +'%S'`-test`openssl rand -hex 10`-test$i&ip=20.18.7.10&port=8080";echo ;done
ok
ok
ok
ok
ok
ok
ok
ok
ok
ok
```

经过重启leader又到172.168.2.19这个节点上来了

![查看新leader](./image/nacos/nacos07.png)





#### 3.3.8 上下线节点

##### 3.3.8.1 下线节点

**移除节点时必须先停止服务再移除节点**

步骤：

1. 停止需要下线节点的服务
2. 在所有节点集群配置文件conf/cluster.conf中删除需要下线的节点。
3. 通过服务注册测试集群任意节点是否正常对外提供服务。
4. 控制台下线按键，经过测试，点击无用，可忽略。



###### 3.3.8.1.1 停止需要下线的节点服务

![查看新leader](./image/nacos/nacos08.png)

```bash
# 这里下线节点172.168.2.19
[root@nacos02 /usr/local/nacos]# /usr/local/nacos/bin/shutdown.sh
The nacosServer(89495) is running...
Send shutdown request to nacosServer(89495) OK
[root@nacos02 /usr/local/nacos]# ps -ef | grep nacos
root      91170  90732  0 17:32 pts/0    00:00:00 grep --color=auto nacos
[root@nacos02 /usr/local/nacos]# netstat -tnlp | grep java
[root@nacos02 /usr/local/nacos]#
```

![查看新leader](./image/nacos/nacos09.png)



###### 3.3.8.1.2 配置所有节点的集群文件

所有nacos节点集群配置信息

```bash
root@ansible:~# ansible nacos -m shell -a 'cat /usr/local/nacos/conf/cluster.conf'
172.168.2.18 | SUCCESS | rc=0 >>
#2023-11-24T17:14:25.411
172.168.2.18:8848
172.168.2.19:8848
172.168.2.20:8848

172.168.2.19 | SUCCESS | rc=0 >>
#2023-11-24T17:14:23.321
172.168.2.18:8848
172.168.2.19:8848
172.168.2.20:8848

172.168.2.20 | SUCCESS | rc=0 >>
#2023-11-24T17:14:26.344
172.168.2.18:8848
172.168.2.19:8848
172.168.2.20:8848
```

从所有nacos节点集群配置信息中删除172.168.2.19(此节点已经停止服务)

```bash
root@ansible:~# ansible nacos -m shell -a "sed -i '/172.168.2.19/d' /usr/local/nacos/conf/cluster.conf"

root@ansible:~# ansible nacos -m shell -a 'cat /usr/local/nacos/conf/cluster.conf'
172.168.2.20 | SUCCESS | rc=0 >>
#2023-11-24T17:44:00.120
172.168.2.18:8848
172.168.2.20:8848

172.168.2.18 | SUCCESS | rc=0 >>
#2023-11-24T17:44:00.127
172.168.2.18:8848
172.168.2.20:8848

172.168.2.19 | SUCCESS | rc=0 >>
#2023-11-24T17:14:23.321
172.168.2.18:8848
172.168.2.20:8848
```

此时刷新页面，节点自动下线

![查看新leader](./image/nacos/nacos10.png)

测试集群服务是否正常

```bash
root@ansible:~# for i in `seq 1 10`;do curl -sX POST "http://172.168.2.20:8848/nacos/v1/ns/instance?accessToken=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwMDAyIiwiZXhwIjoxNzAwODM1ODA0fQ.AGk0Vekkyi2G2QuplSQlqIgPl0omEnlA_QdHs2Us-E8&serviceName=`date +'%S'`-test`openssl rand -hex 10`-test$i&ip=20.18.7.10&port=8080";echo ;done
ok
ok
ok
ok
ok
ok
ok
ok
ok
ok
```



##### 3.3.8.2 上线节点

步骤：

1. 删除新上线节点上/usr/local/nacos-2.2.3/{data,logs,status}的目录
2. 在nacos集群所有节点上添加新扩容节点ip:port到conf/cluster.conf中并保存，包括新添加的节点。
3. 然后启动新的nacos节点服务。
4. 通过服务注册测试集群任意节点是否正常对外提供服务。



###### 3.3.8.2.1 删除新上线节点脏数据

```bash
[root@nacos02 /usr/local/nacos]# rm -rf /usr/local/nacos/data/* status/* logs/*
```



###### 3.3.8.2.2 配置所有节点集群配置文件

```bash
# 查看当前的集群配置文件
root@ansible:~# ansible nacos -m shell -a 'cat /usr/local/nacos/conf/cluster.conf'
172.168.2.18 | SUCCESS | rc=0 >>
#2023-11-24T17:44:00.127
172.168.2.18:8848
172.168.2.20:8848

172.168.2.20 | SUCCESS | rc=0 >>
#2023-11-24T17:44:00.120
172.168.2.18:8848
172.168.2.20:8848

172.168.2.19 | SUCCESS | rc=0 >>
#2023-11-24T17:14:23.321
172.168.2.18:8848
172.168.2.20:8848

# 添加新节点信息到/usr/local/nacos/conf/cluster.conf
root@ansible:~# ansible nacos -m shell -a 'echo '172.168.2.19:8848' >> /usr/local/nacos/conf/cluster.conf'
172.168.2.19 | SUCCESS | rc=0 >>


172.168.2.20 | SUCCESS | rc=0 >>


172.168.2.18 | SUCCESS | rc=0 >>

# 查看添加新节点后的集群配置文件
root@ansible:~# ansible nacos -m shell -a 'cat /usr/local/nacos/conf/cluster.conf'
172.168.2.18 | SUCCESS | rc=0 >>
#2023-11-24T18:12:39.746
172.168.2.18:8848
172.168.2.19:8848
172.168.2.20:8848

172.168.2.20 | SUCCESS | rc=0 >>
#2023-11-24T18:12:39.751
172.168.2.18:8848
172.168.2.19:8848
172.168.2.20:8848

172.168.2.19 | SUCCESS | rc=0 >>
#2023-11-24T17:14:23.321
172.168.2.18:8848
172.168.2.20:8848
172.168.2.19:8848
```

此时刷新页面，节点自动上线

![查看新节点](./image/nacos/nacos11.png)



###### 3.3.8.2.3 启动新节点nacos服务

```bash
[root@nacos02 /usr/local/nacos]# grep -Ev '#|^$' conf/application.properties
server.servlet.contextPath=/nacos
server.error.include-message=ALWAYS
server.port=8848
spring.sql.init.platform=mysql
db.num=1
db.url.0=jdbc:mysql://devmysql.hs.com:3306/nacos_config?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=Asia/Shanghai
db.user.0=nacos
db.password.0=nacos@service
db.pool.config.connectionTimeout=30000
db.pool.config.validationTimeout=10000
db.pool.config.maximumPoolSize=20
db.pool.config.minimumIdle=2
nacos.config.push.maxRetryTime=50
server.tomcat.mbeanregistry.enabled=true
management.endpoints.web.exposure.include=*
management.metrics.export.elastic.enabled=false
management.metrics.export.influx.enabled=false
server.tomcat.accesslog.enabled=true
server.tomcat.accesslog.rotate=true
server.tomcat.accesslog.file-date-format=.yyyy-MM-dd-HH
server.tomcat.accesslog.pattern=%h %l %u %t "%r" %s %b %D %{User-Agent}i %{Request-Source}i
server.tomcat.basedir=file:.
nacos.security.ignore.urls=/,/error,/**/*.css,/**/*.js,/**/*.html,/**/*.map,/**/*.svg,/**/*.png,/**/*.ico,/console-ui/public/**,/v1/auth/**,/v1/console/health/**,/actuator/**,/v1/console/server/**
nacos.core.auth.system.type=nacos
nacos.core.auth.enabled=true
nacos.core.auth.caching.enabled=true
nacos.core.auth.enable.userAgentAuthWhite=false
nacos.core.auth.server.identity.key=Nacos-Server-Identity
nacos.core.auth.server.identity.value=homsom
nacos.core.auth.plugin.nacos.token.cache.enable=true
nacos.core.auth.plugin.nacos.token.expire.seconds=18000
nacos.core.auth.plugin.nacos.token.secret.key=SlVwSXhTU1pBeXVLcU1WT2tlQ21rUHBUYXlTR3dKQzg=
nacos.istio.mcp.server.enabled=false

[root@nacos02 /usr/local/nacos]# bash ./bin/startup.sh
[root@nacos02 /usr/local/nacos]# netstat -tnlp | grep java
tcp        0      0 0.0.0.0:7848            0.0.0.0:*               LISTEN      92253/java
tcp        0      0 0.0.0.0:8848            0.0.0.0:*               LISTEN      92253/java
tcp        0      0 0.0.0.0:9848            0.0.0.0:*               LISTEN      92253/java
tcp        0      0 0.0.0.0:9849            0.0.0.0:*               LISTEN      92253/java
```

刷新控制台页面，节点已正常上线

![查看新节点](./image/nacos/nacos12.png)

![查看新leader](./image/nacos/nacos13.png)



###### 3.3.8.2.4 测试新集群服务

```bash
root@ansible:~# for i in `seq 1 10`;do curl -sX POST "http://172.168.2.12:8848/nacos/v1/ns/instance?accessToken=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwMDAyIiwiZXhwIjoxNzAwODM1ODA0fQ.AGk0Vekkyi2G2QuplSQlqIgPl0omEnlA_QdHs2Us-E8&serviceName=`date +'%S'`-test`openssl rand -hex 10`-test$i&ip=20.18.7.10&port=8080";echo ;done
ok
ok
ok
ok
ok
ok
ok
ok
ok
^[[Aok
root@ansible:~# for i in `seq 1 10`;do curl -sX POST "http://172.168.2.12:8848/nacos/v1/ns/instance?accessToken=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwMDAyIiwiZXhwIjoxNzAwODM1ODA0fQ.AGk0Vekkyi2G2QuplSQlqIgPl0omEnlA_QdHs2Us-E8&serviceName=`date +'%S'`-test`openssl rand -hex 10`-test$i&ip=20.18.7.10&port=8080";echo ;done
ok
ok
ok
ok
ok
ok
ok
ok
ok
ok
root@ansible:~# for i in `seq 1 10`;do curl -sX POST "http://172.168.2.12:8848/nacos/v1/ns/instance?accessToken=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwMDAyIiwiZXhwIjoxNzAwODM1ODA0fQ.AGk0Vekkyi2G2QuplSQlqIgPl0omEnlA_QdHs2Us-E8&serviceName=`date +'%S'`-test`openssl rand -hex 10`-test$i&ip=20.18.7.10&port=8080";echo ;done
ok
ok
ok
ok
ok
ok
ok
ok
ok
ok
```



###### 3.3.8.2.5 所有节点服务重启测试

```bash
# 停止
root@ansible:~# ansible nacos -m shell -a 'bash /usr/local/nacos/bin/shutdown.sh '
root@ansible:~# ansible nacos -m shell -a 'ps -ef | grep nacos'
172.168.2.18 | SUCCESS | rc=0 >>
root      93774  93769  0 18:26 pts/1    00:00:00 /bin/sh -c ps -ef | grep nacos
root      93776  93774  0 18:26 pts/1    00:00:00 grep nacos

172.168.2.19 | SUCCESS | rc=0 >>
root      93016  93011  0 18:26 pts/1    00:00:00 /bin/sh -c ps -ef | grep nacos
root      93018  93016  0 18:26 pts/1    00:00:00 grep nacos

172.168.2.20 | SUCCESS | rc=0 >>
root      92480  92475  0 18:26 pts/0    00:00:00 /bin/sh -c ps -ef | grep nacos
root      92482  92480  0 18:26 pts/0    00:00:00 grep nacos

# 启动
root@ansible:~# ansible nacos -m shell -a 'netstat -tnlp | grep java'
172.168.2.18 | SUCCESS | rc=0 >>
tcp        0      0 0.0.0.0:9848            0.0.0.0:*               LISTEN      93924/java
tcp        0      0 0.0.0.0:9849            0.0.0.0:*               LISTEN      93924/java
tcp        0      0 0.0.0.0:7848            0.0.0.0:*               LISTEN      93924/java
tcp        0      0 0.0.0.0:8848            0.0.0.0:*               LISTEN      93924/java

172.168.2.19 | SUCCESS | rc=0 >>
tcp        0      0 0.0.0.0:7848            0.0.0.0:*               LISTEN      93166/java
tcp        0      0 0.0.0.0:8848            0.0.0.0:*               LISTEN      93166/java
tcp        0      0 0.0.0.0:9848            0.0.0.0:*               LISTEN      93166/java
tcp        0      0 0.0.0.0:9849            0.0.0.0:*               LISTEN      93166/java

172.168.2.20 | SUCCESS | rc=0 >>
tcp        0      0 0.0.0.0:8848            0.0.0.0:*               LISTEN      92630/java
tcp        0      0 0.0.0.0:9848            0.0.0.0:*               LISTEN      92630/java
tcp        0      0 0.0.0.0:9849            0.0.0.0:*               LISTEN      92630/java
tcp        0      0 0.0.0.0:7848            0.0.0.0:*               LISTEN      92630/java

# 测试
## 原因：因为所有节点已经重启，token所有失效，需要重新获取
root@ansible:~# for i in `seq 1 10`;do curl -sX POST "http://172.168.2.12:8848/nacos/v1/ns/instance?accessToken=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwMDAxIiwiZXhwIjoxNzAwODIxNDgzfQ.u62DGzo3ce0zn2JW2NIB63aDWpUDdsd9bRouQC2vUgE&serviceName=`date +'%S'`-test`openssl rand -hex 10`-test$i&ip=20.18.7.10&port=8080";echo ;done
{"timestamp":"2023-11-24T18:28:04.625+08:00","status":403,"error":"Forbidden","message":"token expired!","path":"/nacos/v1/ns/instance"}
{"timestamp":"2023-11-24T18:28:04.739+08:00","status":403,"error":"Forbidden","message":"token expired!","path":"/nacos/v1/ns/instance"}
{"timestamp":"2023-11-24T18:28:04.856+08:00","status":403,"error":"Forbidden","message":"token expired!","path":"/nacos/v1/ns/instance"}
{"timestamp":"2023-11-24T18:28:04.887+08:00","status":403,"error":"Forbidden","message":"token expired!","path":"/nacos/v1/ns/instance"}
{"timestamp":"2023-11-24T18:28:04.908+08:00","status":403,"error":"Forbidden","message":"token expired!","path":"/nacos/v1/ns/instance"}
{"timestamp":"2023-11-24T18:28:04.935+08:00","status":403,"error":"Forbidden","message":"token expired!","path":"/nacos/v1/ns/instance"}
{"timestamp":"2023-11-24T18:28:04.954+08:00","status":403,"error":"Forbidden","message":"token expired!","path":"/nacos/v1/ns/instance"}
{"timestamp":"2023-11-24T18:28:04.977+08:00","status":403,"error":"Forbidden","message":"token expired!","path":"/nacos/v1/ns/instance"}
{"timestamp":"2023-11-24T18:28:05.003+08:00","status":403,"error":"Forbidden","message":"token expired!","path":"/nacos/v1/ns/instance"}
{"timestamp":"2023-11-24T18:28:05.021+08:00","status":403,"error":"Forbidden","message":"token expired!","path":"/nacos/v1/ns/instance"}

## 再次重试
root@ansible:~# curl -X POST 'http://172.168.2.12:8848/nacos/v1/auth/login' -d 'username=0002&password=0002';echo
{"accessToken":"eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwMDAyIiwiZXhwIjoxNzAwODM5NzYwfQ.y7RG2ZnrQ914lCPJBm2NSEhwdnJ-3cTsILf_MATu1gI","tokenTtl":17999,"globalAdmin":false,"username":"0002"}

root@ansible:~# for i in `seq 1 10`;do curl -sX POST "http://172.168.2.12:8848/nacos/v1/ns/instance?accessToken=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwMDAyIiwiZXhwIjoxNzAwODM5NzYwfQ.y7RG2ZnrQ914lCPJBm2NSEhwdnJ-3cTsILf_MATu1gI&serviceName=`date +'%S'`-test`openssl rand -hex 10`-test$i&ip=20.18.7.10&port=8080";echo ;done
ok
ok
ok
ok
ok
ok
ok
ok
ok
ok
```







### 3.4 鉴权

#### 3.4.1 默认控制台登录页

2.2.2版本之前的Nacos默认控制台，无论服务端是否开启鉴权，都会存在一个登录页；这导致很多用户被**误导**认为Nacos默认是存在鉴权的。在社区安全工程师的建议下，Nacos自**2.2.2**版本开始，在未开启鉴权时，默认控制台将不需要登录即可访问，同时在控制台中给予提示，提醒用户当前集群未开启鉴权。

在用户开启鉴权后，控制台才需要进行登录访问。 同时针对不同的鉴权插件，提供新的接口方法，用于提示控制台是否开启登录页；同时在`2.2.3`版本后，Nacos可支持关闭开源控制台，并引导到用户自定义的Nacos控制台，详情可查看[Nacos鉴权插件-服务端插件](https://nacos.io/zh-cn/docs/v2/plugin/auth-plugin.html)及[控制台手册-关闭登录功能](https://nacos.io/zh-cn/docs/v2/guide/admin/console-guide.html#1.1)



#### 3.4.2 服务端如何开启鉴权

##### 3.4.2.1 非Docker环境

按照官方文档配置启动,默认是不需要登录的，这样会导致配置中心对外直接暴露。而启用鉴权之后，需要在使用用户名和密码登录之后，才能正常使用nacos。

开启鉴权之前，application.properties中的配置信息为：

```java
### If turn on auth system:
nacos.core.auth.enabled=false
```

开启鉴权之后，application.properties中的配置信息为：

```java
### If turn on auth system:
nacos.core.auth.system.type=nacos
nacos.core.auth.enabled=true
```



**自定义密钥**

开启鉴权之后，你可以自定义用于生成JWT令牌的密钥，application.properties中的配置信息为：

> 注意：
>
> 1. 文档中提供的密钥为公开密钥，在实际部署时请更换为其他密钥内容，防止密钥泄漏导致安全风险。
> 2. 在2.2.0.1版本后，社区发布版本将移除以文档如下值作为默认值，需要自行填充，否则无法启动节点。
> 3. 密钥需要保持节点间一致，长时间不一致可能导致403 invalid token错误。

```properties
### The default token(Base64 String):
nacos.core.auth.default.token.secret.key=SecretKey012345678901234567890123456789012345678901234567890123456789

### 2.1.0 版本后
nacos.core.auth.plugin.nacos.token.secret.key=SecretKey012345678901234567890123456789012345678901234567890123456789
```

自定义密钥时，推荐将配置项设置为**Base64编码**的字符串，且**原始密钥长度不得低于32字符**。例如下面的的例子：

```properties
### The default token(Base64 String):
nacos.core.auth.default.token.secret.key=VGhpc0lzTXlDdXN0b21TZWNyZXRLZXkwMTIzNDU2Nzg=

### 2.1.0 版本后
nacos.core.auth.plugin.nacos.token.secret.key=VGhpc0lzTXlDdXN0b21TZWNyZXRLZXkwMTIzNDU2Nzg=
```

> 注意：鉴权开关是修改之后立马生效的，不需要重启服务端。动态修改`token.secret.key`时，请确保token是有效的，如果修改成无效值，会导致后续无法登录，请求访问异常。



##### 3.4.2.2 Docker环境

###### 3.4.2.2.1 官方镜像

如果使用官方镜像，请在启动docker容器时，添加如下环境变量

```powershell
NACOS_AUTH_ENABLE=true
```

例如，可以通过如下命令运行开启了鉴权的容器:

```powershell
docker run --env PREFER_HOST_MODE=hostname --env MODE=standalone --env NACOS_AUTH_ENABLE=true -p 8848:8848 nacos/nacos-server
```

除此之外，还可以添加其他鉴权相关的环境变量信息：

| name                            | description                                        | option                                                       |
| ------------------------------- | -------------------------------------------------- | ------------------------------------------------------------ |
| NACOS_AUTH_ENABLE               | 是否开启权限系统                                   | 默认:false                                                   |
| NACOS_AUTH_TOKEN_EXPIRE_SECONDS | token 失效时间                                     | 默认:18000                                                   |
| NACOS_AUTH_TOKEN                | token                                              | 默认:SecretKey012345678901234567890123456789012345678901234567890123456789 |
| NACOS_AUTH_CACHE_ENABLE         | 权限缓存开关 ,开启后权限缓存的更新默认有15秒的延迟 | 默认 : false                                                 |

然后运行docker-compose构建命令,例如

```powershell
docker-compose -f example/standalone-derby.yaml up
```



###### 3.4.2.2.2 自定义镜像

如果选择自定义镜像，请在构建镜像之前，修改nacos工程中的application.properties文件，

将下面这一行配置信息

```
nacos.core.auth.enabled=false
```

修改为

```
nacos.core.auth.system.type=nacos
nacos.core.auth.enabled=true
```

然后再配置nacos启动命令。



#### 3.4.3 开启Token缓存功能

服务端自2.2.1版本后，默认鉴权插件模块支持token缓存功能，可参见[ISSUE #9906](https://github.com/alibaba/nacos/issues/9906)

`背景`

无论是客户端SDK还是OpenAPI，在调用login接口获取accessToken之后，携带accessToken访问服务端，服务端解析Token进行鉴权。解析的动作比较耗时，如果想要提升接口的性能，可以考虑开启缓存Token的功能，用字符串比较代替Token解析。

`开启方式`

```
nacos.core.auth.plugin.nacos.token.cache.enable=true
```

`注意事项`

在开启Token缓存功能之前，服务端对每一个携带用户名密码访问login接口的请求都会生成新的token，接口的返回值中的tokenTtl字段跟服务端配置文件中设置的值相等，配置如下：

```
nacos.core.auth.plugin.nacos.token.expire.seconds=18000
```

在开启Token缓存功能之后，服务端对每一个携带用户名密码访问login接口的请求，会先检查缓存中是否存在该用户名对应的token。若不存在，生成新的Token，插入缓存再返回；若存在，返回该token，此时tokenTtl字段的值为配置文件中设置的值减去该Token在缓存中存留的时长。 如果Token在缓存中存留的时长超过配置文件设置的值的90%，当login接口收到请求时，尽管缓存中存在该用户名对应的Token，服务端会重新生成Token返回给请求方，并更新缓存。因此，最差情况下，请求方收到的tokenTtl只有配置文件设置的值的10%。



#### 3.4.4 开启服务身份识别功能

开启鉴权功能后，服务端之间的请求也会通过鉴权系统的影响。考虑到服务端之间的通信应该是可信的，因此在1.2~1.4.0版本期间，通过User-Agent中是否包含Nacos-Server来进行判断请求是否来自其他服务端。

但这种实现由于过于简单且固定，导致可能存在安全问题。因此从1.4.1版本开始，Nacos添加服务身份识别功能，用户可以自行配置服务端的Identity，不再使用User-Agent作为服务端请求的判断标准。

开启方式:

```
### 开启鉴权
nacos.core.auth.enabled=true

### 关闭使用user-agent判断服务端请求并放行鉴权的功能
nacos.core.auth.enable.userAgentAuthWhite=false

### 配置自定义身份识别的key（不可为空）和value（不可为空）
nacos.core.auth.server.identity.key=example
nacos.core.auth.server.identity.value=example
```

** 注意 ** 所有集群均需要配置相同的`server.identity`信息，否则可能导致服务端之间数据不一致或无法删除实例等问题。



#### 3.4.5 开启鉴权、token缓存、服务身份识别

```bash
# 开启鉴权，并配置用于生成JWT令牌的密钥
nacos.core.auth.system.type=nacos
nacos.core.auth.enabled=true
nacos.core.auth.plugin.nacos.token.secret.key=SlVwSXhTU1pBeXVLcU1WT2tlQ21rUHBUYXlTR3dKQzg=
# token是否缓存、token缓存时间
nacos.core.auth.plugin.nacos.token.cache.enable=true
nacos.core.auth.plugin.nacos.token.expire.seconds=18000
# 自行配置服务端的Identity
nacos.core.auth.enable.userAgentAuthWhite=false
nacos.core.auth.server.identity.key=Nacos-Server-Identity
nacos.core.auth.server.identity.value=homsom
```

```bash
root@ansible:~/tmp/nacos/conf# grep -Ev '#|^$' application.properties
server.servlet.contextPath=/nacos
server.error.include-message=ALWAYS
server.port=8848
spring.sql.init.platform=mysql
db.num=1
db.url.0=jdbc:mysql://devmysql.hs.com:3306/nacos_config?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=Asia/Shanghai
db.user.0=nacos
db.password.0=nacos@service
db.pool.config.connectionTimeout=30000
db.pool.config.validationTimeout=10000
db.pool.config.maximumPoolSize=20
db.pool.config.minimumIdle=2
nacos.config.push.maxRetryTime=50
server.tomcat.mbeanregistry.enabled=true
management.endpoints.web.exposure.include=*
management.metrics.export.elastic.enabled=false
management.metrics.export.influx.enabled=false
server.tomcat.accesslog.enabled=true
server.tomcat.accesslog.rotate=true
server.tomcat.accesslog.file-date-format=.yyyy-MM-dd-HH
server.tomcat.accesslog.pattern=%h %l %u %t "%r" %s %b %D %{User-Agent}i %{Request-Source}i
server.tomcat.basedir=file:.
nacos.security.ignore.urls=/,/error,/**/*.css,/**/*.js,/**/*.html,/**/*.map,/**/*.svg,/**/*.png,/**/*.ico,/console-ui/public/**,/v1/auth/**,/v1/console/health/**,/actuator/**,/v1/console/server/**
nacos.core.auth.system.type=nacos
nacos.core.auth.enabled=true
nacos.core.auth.caching.enabled=true
nacos.core.auth.enable.userAgentAuthWhite=false
nacos.core.auth.server.identity.key=Nacos-Server-Identity
nacos.core.auth.server.identity.value=homsom
nacos.core.auth.plugin.nacos.token.cache.enable=true
nacos.core.auth.plugin.nacos.token.expire.seconds=18000
nacos.core.auth.plugin.nacos.token.secret.key=SlVwSXhTU1pBeXVLcU1WT2tlQ21rUHBUYXlTR3dKQzg=
nacos.istio.mcp.server.enabled=false
```

下发配置到所有节点，无需重启服务即可生效

```bash
root@ansible:~/tmp/nacos/conf# ansible nacos -mcopy -a 'src=./application.properties dest=/usr/local/nacos/conf/ backup=true'

# 用户：nacos	密码：nacos
访问：http://172.168.2.18:8848/nacos/
```



#### 3.4.6 开启鉴权后访问

`Open-API鉴权`

首先需要使用用户名和密码登陆nacos。

```bash
curl -X POST '127.0.0.1:8848/nacos/v1/auth/login' -d 'username=nacos&password=nacos'
```

若用户名和密码正确,返回信息如下:

```bash
{"accessToken":"eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJuYWNvcyIsImV4cCI6MTYwNTYyOTE2Nn0.2TogGhhr11_vLEjqKko1HJHUJEmsPuCxkur-CfNojDo","tokenTtl":18000,"globalAdmin":true}
```

接下来进行配置信息或服务信息时,应当使用该accessToken鉴权,在url后添加参数accessToken={accessToken},其中{accessToken}为登录时返回的token信息，例如

```bash
curl -X GET '127.0.0.1:8848/nacos/v1/cs/configs?accessToken=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJuYWNvcyIsImV4cCI6MTYwNTYyMzkyM30.O-s2yWfDSUZ7Svd3Vs7jy9tsfDNHs1SuebJB4KlNY8Q&dataId=nacos.example.1&group=nacos_group'
curl -X POST 'http://127.0.0.1:8848/nacos/v1/ns/instance?accessToken=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ

curl -X POST 'http://127.0.0.1:8848/nacos/v1/ns/instance?accessToken=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJuYWNvcyIsImV4cCI6MTYwNTYyMzkyM30.O-s2yWfDSUZ7Svd3Vs7jy9tsfDNHs1SuebJB4KlNY8Q&port=8848&healthy=true&ip=11.11.11.11&weight=1.0&serviceName=nacos.test.3&encoding=GBK&namespaceId=n1'
```

实操

```bash
# 此时无权限，需要使用token访问
[root@nacos01 ~]# curl -X POST 'http://172.168.2.12:8848/nacos/v1/ns/instance?serviceName=nacos.naming.serviceName&ip=20.18.7.10&port=8080';echo
{"timestamp":"2023-11-24T13:14:27.661+08:00","status":403,"error":"Forbidden","message":"user not found!","path":"/nacos/v1/ns/instance"}

# 获取token
[root@nacos01 ~]# curl -X POST 'http://172.168.2.12:8848/nacos/v1/auth/login' -d 'username=0001&password=0001';echo
{"accessToken":"eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwMDAxIiwiZXhwIjoxNzAwODIwODE4fQ.fuuc9QNuUi1cJH30Nv8zlEEJyyguwcDzywAeNICzZHk","tokenTtl":18000,"globalAdmin":false,"username":"0001"}


# 使用token访问配置

## 配置注册
[root@nacos01 ~]# curl -X POST "http://172.168.2.12:8848/nacos/v1/cs/configs?accessToken=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwMDAxIiwiZXhwIjoxNzAwODIxNDgzfQ.u62DGzo3ce0zn2JW2NIB63aDWpUDdsd9bRouQC2vUgE&dataId=nacos.cfg.dataId&group=test&content=helloWorld"
{"timestamp":"2023-11-24T13:25:23.849+08:00","status":403,"error":"Forbidden","message":"authorization failed!","path":"/nacos/v1/cs/configs"}   # 报此错，是因为0001用户只有只读权限，无写权限
## 经过赋予读写权限后配置注册正常
[root@nacos01 ~]# curl -X POST "http://172.168.2.12:8848/nacos/v1/cs/configs?accessToken=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwMDAxIiwiZXhwIjoxNzAwODIxNDgzfQ.u62DGzo3ce0zn2JW2NIB63aDWpUDdsd9bRouQC2vUgE&dataId=nacos.cfg.dataId&group=test&content=helloWorld"
true
## 配置读取
[root@nacos01 ~]# curl -s -X GET "http://172.168.2.12:8848/nacos/v1/cs/configs?accessToken=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwMDAxIiwiZXhwIjoxNzAwODIxNDgzfQ.u62DGzo3ce0zn2JW2NIB63aDWpUDdRouQC2vUgE&dataId=nacos.cfg.dataId&group=test&content=helloWorld";echo
helloWorld


# 使用token访问服务

## 服务注册
root@ansible:~# curl -X POST 'http://172.168.2.12:8848/nacos/v1/ns/instance?accessToken=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwMDAxIiwiZXhwIjoxNzAwODIxNDgzfQ.u62DGzo3ce0zn2JW2NIB63aDWpUDdsd9bRouQC2vUgE&serviceName=nacos.naming.serviceName&ip=20.18.7.10&port=8080';echo
ok
## 服务发现
root@ansible:~# curl -s -X GET 'http://172.168.2.12:8848/nacos/v1/ns/instance/list?accessToken=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwMDAxIiwiZXhwIjoxNzAwODIxNDgzfQ.u62DGzo3ce0zn2JW2NIB63aDWpUDdsd9bRouQC2vUgE&serviceName=nacos.naming.serviceName' | jq .
{
  "name": "DEFAULT_GROUP@@nacos.naming.serviceName",
  "groupName": "DEFAULT_GROUP",
  "clusters": "",
  "cacheMillis": 10000,
  "hosts": [
    {
      "instanceId": "20.18.7.10#8080#DEFAULT#DEFAULT_GROUP@@nacos.naming.serviceName",
      "ip": "20.18.7.10",
      "port": 8080,
      "weight": 1,
      "healthy": true,
      "enabled": true,
      "ephemeral": true,
      "clusterName": "DEFAULT",
      "serviceName": "DEFAULT_GROUP@@nacos.naming.serviceName",
      "metadata": {},
      "instanceHeartBeatInterval": 5000,
      "instanceHeartBeatTimeOut": 15000,
      "ipDeleteTimeout": 30000,
      "instanceIdGenerator": "simple"
    }
  ],
  "lastRefTime": 1700805247392,
  "checksum": "",
  "allIPs": false,
  "reachProtectionThreshold": false,
  "valid": true
}


# 创建服务
curl -X POST 'http://172.168.2.12:8848/nacos/v1/ns/service?accessToken=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwMDAxIiwiZXhwIjoxNzAwODIxNDgzfQ.u62DGzo3ce0zn2JW2NIB63aDWpUDdsd9bRouQC2vUgE&serviceName=nacos.test.2&metadata=k1%3dv1';echo

# 查询服务
curl -X POST 'http://172.168.2.12:8848/nacos/v1/ns/service?accessToken=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwMDAxIiwiZXhwIjoxNzAwODIxNDgzfQ.u62DGzo3ce0zn2JW2NIB63aDWpUDdsd9bRouQC2vUgE&serviceName=nacos.test.2';echo
```
