#SkyWalking
<pre>
#部署zookeeper高可用集群
--node01:
[root@newgitlab download]# curl -OL https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-3.6.3/apache-zookeeper-3.6.3-bin.tar.gz
[root@newgitlab download]# tar xf apache-zookeeper-3.6.3-bin.tar.gz -C /usr/local/
[root@newgitlab download]# mv /usr/local/apache-zookeeper-3.6.3-bin/ /usr/local/zookeeper01
[root@newgitlab download]# cp /usr/local/zookeeper01/conf/zoo_sample.cfg{,.bak}
[root@newgitlab download]# vim /usr/local/zookeeper01/conf/zoo_sample.cfg
[root@newgitlab download]# grep -Ev '#|^$' /usr/local/zookeeper01/conf/zoo_sample.cfg
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/tmp/zookeeper/data01
clientPort=2181
server.1=192.168.13.76:2287:3387
server.2=192.168.13.76:2288:3388
server.3=192.168.13.76:2289:3389
[root@newgitlab download]# mv /usr/local/zookeeper01/conf/zoo_sample.cfg /usr/local/zookeeper01/conf/zoo.cfg
--node02&node03:
[root@newgitlab download]# cp -a /usr/local/zookeeper01/ /usr/local/zookeeper02
[root@newgitlab download]# cp -a /usr/local/zookeeper01/ /usr/local/zookeeper03
[root@newgitlab download]# vim /usr/local/zookeeper02/conf/zoo.cfg
[root@newgitlab download]# grep -Ev '#|^$' /usr/local/zookeeper02/conf/zoo.cfg
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/tmp/zookeeper/data02
clientPort=2182
server.1=192.168.13.76:2287:3387
server.2=192.168.13.76:2288:3388
server.3=192.168.13.76:2289:3389
[root@newgitlab download]# vim /usr/local/zookeeper03/conf/zoo.cfg
[root@newgitlab download]# grep -Ev '#|^$' /usr/local/zookeeper03/conf/zoo.cfg
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/tmp/zookeeper/data03
clientPort=2183
server.1=192.168.13.76:2287:3387
server.2=192.168.13.76:2288:3388
server.3=192.168.13.76:2289:3389
[root@newgitlab download]# mkdir -p /tmp/zookeeper/data{01,02,03}
[root@newgitlab download]# echo 1 > /tmp/zookeeper/data01/myid
[root@newgitlab download]# echo 2 > /tmp/zookeeper/data02/myid
[root@newgitlab download]# echo 3 > /tmp/zookeeper/data03/myid
[root@newgitlab download]# /usr/local/zookeeper01/bin/zkServer.sh start
/usr/bin/java
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper01/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED
[root@newgitlab download]# netstat -tnlp | grep -E '2181|2287|3387'
tcp6       0      0 192.168.13.76:3387      :::*                    LISTEN      7710/java           
tcp6       0      0 :::2181                 :::*                    LISTEN      7710/java    
[root@newgitlab download]# /usr/local/zookeeper02/bin/zkServer.sh start
/usr/bin/java
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper02/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED
[root@newgitlab download]# netstat -tnlp | grep -E '2181|2182|2183|2287|2288|2289|3387|3388|3389'
tcp6       0      0 192.168.13.76:2288      :::*                    LISTEN      7825/java           
tcp6       0      0 192.168.13.76:3387      :::*                    LISTEN      7710/java           
tcp6       0      0 192.168.13.76:3388      :::*                    LISTEN      7825/java           
tcp6       0      0 :::2181                 :::*                    LISTEN      7710/java           
tcp6       0      0 :::2182                 :::*                    LISTEN      7825/java   
[root@newgitlab download]# /usr/local/zookeeper03/bin/zkServer.sh start
/usr/bin/java
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper03/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED
[root@newgitlab download]# netstat -tnlp | grep -E '2181|2182|2183|2287|2288|2289|3387|3388|3389'
tcp6       0      0 :::2183                 :::*                    LISTEN      7914/java           
tcp6       0      0 192.168.13.76:2288      :::*                    LISTEN      7825/java           
tcp6       0      0 192.168.13.76:3387      :::*                    LISTEN      7710/java           
tcp6       0      0 192.168.13.76:3388      :::*                    LISTEN      7825/java           
tcp6       0      0 192.168.13.76:3389      :::*                    LISTEN      7914/java           
tcp6       0      0 :::2181                 :::*                    LISTEN      7710/java           
tcp6       0      0 :::2182                 :::*                    LISTEN      7825/java      
[root@newgitlab download]# /usr/local/zookeeper02/bin/zkServer.sh status
/usr/bin/java
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper02/bin/../conf/zoo.cfg
Client port found: 2182. Client address: localhost. Client SSL: false.
Mode: leader
注：监听端口2288就是server.2开启的，因为zookeeper02是leader角色




#部署skywalking集群
node01:
[root@newgitlab bin]# yum install -y java-1.8.0-openjdk
[root@newgitlab bin]# mv apache-skywalking-apm-es7-8.5.0.tar.gz  /usr/local/src/
[root@newgitlab bin]# tar xf apache-skywalking-apm-es7-8.5.0.tar.gz 
[root@newgitlab bin]# mv apache-skywalking-apm-bin-es7/ /usr/local/skywalking01
[root@newgitlab skywalking01]# vim /usr/local/skywalking01/config/application.yml 
cluster:
  selector: ${SW_CLUSTER:zookeeper}     --集群方式默认是standalone，表示不是集群
  zookeeper:
    nameSpace: ${SW_NAMESPACE:""}
    hostPort: ${SW_CLUSTER_ZK_HOST_PORT:192.168.13.76:2181,192.168.13.76:2182,192.168.13.76:2183}
    baseSleepTimeMs: ${SW_CLUSTER_ZK_SLEEP_TIME:1000} # initial amount of time to wait between retries
    maxRetries: ${SW_CLUSTER_ZK_MAX_RETRIES:3} # max number of times to retry
core:
  selector: ${SW_CORE:default}
  default:
    restHost: ${SW_CORE_REST_HOST:192.168.13.76}
    restPort: ${SW_CORE_REST_PORT:12800}
    gRPCHost: ${SW_CORE_GRPC_HOST:192.168.13.76}
    gRPCPort: ${SW_CORE_GRPC_PORT:11800}
storage:
  selector: ${SW_STORAGE:elasticsearch7}   
  elasticsearch7:
    nameSpace: ${SW_NAMESPACE:""}
    clusterNodes: ${SW_STORAGE_ES_CLUSTER_NODES:192.168.13.50:9401}


node02:
[root@newgitlab bin]# yum install -y java-1.8.0-openjdk
[root@newgitlab src]# \cp -a apache-skywalking-apm-bin-es7/ /usr/local/skywalking02
[root@newgitlab bin]# vim /usr/local/skywalking02/config/application.yml
cluster:
  selector: ${SW_CLUSTER:zookeeper}
  zookeeper:
    nameSpace: ${SW_NAMESPACE:""}
    hostPort: ${SW_CLUSTER_ZK_HOST_PORT:192.168.13.76:2181,192.168.13.76:2182,192.168.13.76:2183}
    baseSleepTimeMs: ${SW_CLUSTER_ZK_SLEEP_TIME:1000} # initial amount of time to wait between retries
    maxRetries: ${SW_CLUSTER_ZK_MAX_RETRIES:3} # max number of times to retry
core:
  selector: ${SW_CORE:default}
  default:
    restHost: ${SW_CORE_REST_HOST:192.168.13.76}
    restPort: ${SW_CORE_REST_PORT:12801}
    gRPCHost: ${SW_CORE_GRPC_HOST:192.168.13.76}
    gRPCPort: ${SW_CORE_GRPC_PORT:11801}
storage:
  selector: ${SW_STORAGE:elasticsearch7}   
  elasticsearch7:
    nameSpace: ${SW_NAMESPACE:""}
    clusterNodes: ${SW_STORAGE_ES_CLUSTER_NODES:192.168.13.50:9401}

node03:
[root@newgitlab bin]# yum install -y java-1.8.0-openjdk
[root@newgitlab src]# \cp -a apache-skywalking-apm-bin-es7/ /usr/local/skywalking03
[root@newgitlab bin]# vim /usr/local/skywalking03/config/application.yml
cluster:
  selector: ${SW_CLUSTER:zookeeper}
  zookeeper:
    nameSpace: ${SW_NAMESPACE:""}
    hostPort: ${SW_CLUSTER_ZK_HOST_PORT:192.168.13.76:2181,192.168.13.76:2182,192.168.13.76:2183}
    baseSleepTimeMs: ${SW_CLUSTER_ZK_SLEEP_TIME:1000} # initial amount of time to wait between retries
    maxRetries: ${SW_CLUSTER_ZK_MAX_RETRIES:3} # max number of times to retry
core:
  selector: ${SW_CORE:default}
  default:
    restHost: ${SW_CORE_REST_HOST:192.168.13.76}
    restPort: ${SW_CORE_REST_PORT:12802}
    gRPCHost: ${SW_CORE_GRPC_HOST:192.168.13.76}
    gRPCPort: ${SW_CORE_GRPC_PORT:11802}
storage:
  selector: ${SW_STORAGE:elasticsearch7}   
  elasticsearch7:
    nameSpace: ${SW_NAMESPACE:""}
    clusterNodes: ${SW_STORAGE_ES_CLUSTER_NODES:192.168.13.50:9401}

#三个节点启动collector 集群
注：节点启动时需要在一定时间内同时启动，例如在1分钟内三个节点都需要启动，这样才能进行组播交换数据，集群才可建立成功。
[root@test ~]# /usr/local/skywalking01/bin/oapService.sh
SkyWalking OAP started successfully!
[root@test ~]# tail -f /usr/local/skywalking01/logs/skywalking-oap-server.log   --查看日志debug
[root@test ~]# /usr/local/skywalking02/bin/oapService.sh
SkyWalking OAP started successfully!
[root@test ~]# /usr/local/skywalking03/bin/oapService.sh
SkyWalking OAP started successfully!


#dashboard配置及启动
node01:
---配置
[root@newgitlab bin]# vim /usr/local/skywalking01/webapp/webapp.yml
server:
  port: 8051
collector:
  path: /graphql
  ribbon:
    ReadTimeout: 10000
    listOfServers: 192.168.13.76:12800,192.168.13.76:12801,192.168.13.76:12802
---启动
[root@newgitlab skywalking01]# /usr/local/skywalking01/bin/webappService.sh 
SkyWalking Web Application started successfully!
[root@test skywalking01]# tail -f /usr/local/skywalking01/logs/webapp.log  --查看日志debug

node02:
---配置
[root@newgitlab bin]# vim /usr/local/skywalking02/webapp/webapp.yml
server:
  port: 8052
collector:
  path: /graphql
  ribbon:
    ReadTimeout: 10000
    listOfServers: 192.168.13.76:12800,192.168.13.76:12801,192.168.13.76:12802
---启动
[root@newgitlab skywalking02]# /usr/local/skywalking02/bin/webappService.sh 
SkyWalking Web Application started successfully!
[root@test skywalking02]# tail -f /usr/local/skywalking02/logs/webapp.log  --查看日志debug

node03:
---配置
[root@newgitlab bin]# vim /usr/local/skywalking03/webapp/webapp.yml
server:
  port: 8053
collector:
  path: /graphql
  ribbon:
    ReadTimeout: 10000
    listOfServers: 192.168.13.76:12800,192.168.13.76:12801,192.168.13.76:12802
---启动
[root@newgitlab skywalking03]# /usr/local/skywalking03/bin/webappService.sh 
SkyWalking Web Application started successfully!
[root@test skywalking03]# tail -f /usr/local/skywalking03/logs/webapp.log  --查看日志debug

#skyworking模拟故障
注：3个节点在zookeeper集群下可以容许一个节点故障。


#安装Skywalking agent端测试
--上传java项目进行测试，例如上传jar包到/tmp/boss-caring-0.0.1-SNAPSHOT.jar
[root@test tmp]# ls /tmp/boss-caring-0.0.1-SNAPSHOT.jar 
/tmp/boss-caring-0.0.1-SNAPSHOT.jar
--运行项目进行测试
[root@test tmp]# nohup /usr/bin/java -javaagent:/usr/local/skywalking01/agent/skywalking-agent.jar -Dskywalking.agent.service_name=boss-caring -Dskywalking.collector.backend_service=192.168.13.76:11800,192.168.13.76:11800:11801,192.168.13.76:11802 -Xms256m -Xmx256m -XX:PermSize=128M -XX:MaxPermSize=256M -jar /tmp/boss-caring-0.0.1-SNAPSHOT.jar&



#运维命令行工具
[root@newgitlab download]# curl -OL https://mirrors.tuna.tsinghua.edu.cn/apache/skywalking/cli/0.7.0/skywalking-cli-0.7.0-bin.tgz
[root@newgitlab download]# tar xf skywalking-cli-0.7.0-bin.tgz -C /usr/local/
[root@newgitlab download]# ln -sv /usr/local/skywalking-cli-0.7.0-bin/ /usr/local/skywalking-cli
‘/usr/local/skywalking-cli’ -> ‘/usr/local/skywalking-cli-0.7.0-bin/’
[root@newgitlab download]# ln -sv /usr/local/skywalking-cli/bin/swctl-0.7.0-linux-amd64 /usr/local/bin/swctl
‘/usr/local/bin/swctl’ -> ‘/usr/local/skywalking-cli/bin/swctl-0.7.0-linux-amd64’
[root@newgitlab download]# swctl --base-url http://192.168.13.76:12800/graphql service ls
[{"id":"Ym9zcy1jYXJpbmc=.1","name":"boss-caring","group":""}]
[root@newgitlab download]# swctl --base-url http://192.168.13.76:12800/graphql instance ls --service-id Ym9zcy1jYXJpbmc=.1
[{"id":"Ym9zcy1jYXJpbmc=.1_NzFkYjNjZTM2NTJmNGMxMjhlOGQwY2Q3YWU2YzcxMThAMTkyLjE2OC4xMy43Ng==","name":"71db3ce3652f4c128e8d0cd7ae6c7118@192.168.13.76","attributes":[{"name":"OS Name","value":"Linux"},{"name":"hostname","value":"test"},{"name":"Process No.","value":"6593"},{"name":"ipv4s","value":"192.168.13.76"}],"language":"JAVA","instanceUUID":"Ym9zcy1jYXJpbmc=.1_NzFkYjNjZTM2NTJmNGMxMjhlOGQwY2Q3YWU2YzcxMThAMTkyLjE2OC4xMy43Ng=="}]
[root@newgitlab download]# swctl --base-url http://192.168.13.76:12800/graphql instance ls --service-name boss-caring
[{"id":"Ym9zcy1jYXJpbmc=.1_NzFkYjNjZTM2NTJmNGMxMjhlOGQwY2Q3YWU2YzcxMThAMTkyLjE2OC4xMy43Ng==","name":"71db3ce3652f4c128e8d0cd7ae6c7118@192.168.13.76","attributes":[{"name":"OS Name","value":"Linux"},{"name":"hostname","value":"test"},{"name":"Process No.","value":"6593"},{"name":"ipv4s","value":"192.168.13.76"}],"language":"JAVA","instanceUUID":"Ym9zcy1jYXJpbmc=.1_NzFkYjNjZTM2NTJmNGMxMjhlOGQwY2Q3YWU2YzcxMThAMTkyLjE2OC4xMy43Ng=="}]
[root@newgitlab download]# swctl --base-url http://192.168.13.76:12800/graphql endpoint ls --service-id Ym9zcy1jYXJpbmc=.1
[{"id":"Ym9zcy1jYXJpbmc=.1_e1BPU1R9L2FwaS9zZXJ2aWNlSW5mby9nZXQtdG90YWw=","name":"{POST}/api/serviceInfo/get-total"},{"id":"Ym9zcy1jYXJpbmc=.1_e0dFVH0vdjIvYXBpLWRvY3M=","name":"{GET}/v2/api-docs"},{"id":"Ym9zcy1jYXJpbmc=.1_Lw==","name":"/"},{"id":"Ym9zcy1jYXJpbmc=.1_L3N3YWdnZXItcmVzb3VyY2VzL2NvbmZpZ3VyYXRpb24vdWk=","name":"/swagger-resources/configuration/ui"},{"id":"Ym9zcy1jYXJpbmc=.1_L3N3YWdnZXItcmVzb3VyY2Vz","name":"/swagger-resources"},{"id":"Ym9zcy1jYXJpbmc=.1_e1BPU1R9L2FwaS9ib3NzQ2FyaW5nL2luc2VydEludGxGbGlnaHRPcmRlckFuZFNlcnZlckluZm8=","name":"{POST}/api/bossCaring/insertIntlFlightOrderAndServerInfo"},{"id":"Ym9zcy1jYXJpbmc=.1_e1BPU1R9L2FwaS9zZXJ2aWNlSW5mby9xdWVyeUxpc3RCeU5hbWU=","name":"{POST}/api/serviceInfo/queryListByName"}]


#访问http://skywalking.hs.com/graphql报500错误
原因：hostPort：11800服务异常，



</pre>