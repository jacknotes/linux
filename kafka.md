## Kafka



### 消息队列使用场景

* 作为消息队列来说，企业中选择mq的还是多数，因为像Rabbit，Rocket等mq中间件都属于很成熟的产品，性能一般但可靠性较强，
* 而kafka原本设计的初衷是日志统计分析，现在基于大数据的背景下也可以做运营数据的分析统计，
* 而redis的主要场景是内存数据库，作为消息队列来说可靠性太差，而且速度太依赖网络IO，在服务器本机上的速度较快，且容易出现数据堆积的问题，在比较轻量的场合下能够适用。

### kafka和RabbitMQ

* RabbitMQ,遵循AMQP协议，由内在高并发的erlanng语言开发，用在实时的对可靠性要求比较高的消息传递上。
* kafka是Linkedin于2010年12月份开源的消息发布订阅系统,它主要用于处理活跃的流式数据,大数据量的数据处理上。

#### 架构模型方面

* RabbitMQ遵循AMQP协议，RabbitMQ的broker由Exchange,Binding,queue组成，其中exchange和binding组成了消息的路由键；客户端Producer通过连接channel和server进行通信，Consumer从queue获取消息进行消费（长连接，queue有消息会推送到consumer端，consumer循环从输入流读取数据）。rabbitMQ以broker为中心；有消息的确认机制。

* kafka遵从一般的MQ结构，producer，broker，consumer，以consumer为中心，消息的消费信息保存客户端consumer上，consumer根据消费的点，从broker上批量pull数据；无消息确认机制。

#### 吞吐量

* rabbitMQ在吞吐量方面稍逊于kafka，他们的出发点不一样，rabbitMQ支持对消息的可靠的传递，支持事务，不支持批量的操作；基于存储的可靠性的要求存储可以采用内存或者硬盘。
* kafka具有高的吞吐量，内部采用消息的批量处理，zero-copy机制，数据的存储和获取是本地磁盘顺序批量操作，具有O(1)的复杂度，消息处理的效率很高。

#### 可用性

* rabbitMQ支持miror的queue，主queue失效，miror queue接管。
* kafka的broker支持主备模式。

#### 集群负载均衡

* rabbitMQ的负载均衡需要单独的load balancer进行支持。
* kafka采用zookeeper对集群中的broker、consumer进行管理，可以注册topic到zookeeper上；通过zookeeper的协调机制，producer保存对应topic的broker信息，可以随机或者轮询发送到broker上；并且producer可以基于语义指定分片，消息发送到broker的某分片上。



### 消息队列
* 消息队列技术是分布式应用间交换信息的一种技术。常用的消息队列技术是 Message Queue。
* 分布式协调技术，所谓分布式协调技术主要是用来解决分布式环境当中多个进程之间的同步控制，让他们有序的去访问某种共享资源，防止造成资源竞争（脑裂）的后果。

#### Message Queue 的通讯模式

* 点对点通讯：点对点方式是最为传统和常见的通讯方式，它支持一对一、一对多、多对多、多对一等多种配置方式，支持树状、网状等多种拓扑结构。
* 多点广播：MQ适用于不同类型的应用。其中重要的，也是正在发展中的是"多点广播"应用，即能够将消息发送到多个目标站点 (Destination List)。可以使用一条 MQ 指令将单一消息发送到多个目标站点，并确保为每一站点可靠地提供信息。MQ 不仅提供了多点广播的功能，而且还拥有智能消息分发功能，在将一条消息发送到同一系统上的多个用户时，MQ 将消息的一个复制版本和该系统上接收者的名单发送到目标 MQ 系统。目标 MQ 系统在本地复制这些消息，并将它们发送到名单上的队列，从而尽可能减少网络的传输量。
* 发布/订阅 (Publish/Subscribe) 模式：发布/订阅功能使消息的分发可以突破目的队列地理指向的限制，使消息按照特定的主题甚至内容进行分发，用户或应用程序可以根据主题或内容接收到所需要的消息。发布/订阅功能使得发送者和接收者之间的耦合关系变得更为松散，发送者不必关心接收者的目的地址，而接收者也不必关心消息的发送地址，而只是根据消息的主题进行消息的收发。
* 群集 (Cluster)：为了简化点对点通讯模式中的系统配置，MQ 提供 Cluster(群集) 的解决方案。群集类似于一个域 (Domain)，群集内部的队列管理器之间通讯时，不需要两两之间建立消息通道，而是采用群集 (Cluster) 通道与其它成员通讯，从而大大简化了系统配置。此外，群集中的队列管理器之间能够自动进行负载均衡，当某一队列管理器出现故障时，其它队列管理器可以接管它的工作，从而大大提高系统的高可靠性。


#### Kafka概念

* Broker：任何正在运行中的Kafka示例都称为Broker。
* Topic：Topic其实就是一个传统意义上的消息队列。
* Partition：即分区。一个Topic将由多个分区组成，每个分区将存在独立的持久化文件，任何一个Consumer在分区上的消费一定是顺序的；当一个Consumer同时在多个分区上消费时，Kafka不能保证总体上的强顺序性（对于强顺序性的一个实现是Exclusive Consumer，即独占消费，一个队列同时只能被一个Consumer消费，并且从该消费开始消费某个消息到其确认才算消费完成，在此期间任何Consumer不能再消费）。（通常有几个节点就初始化几个Partition，Partition指的是一个topic有几个，例如有四个Partition，把四个partition的数据分布在四个节点上实现均衡）
* Producer：消息的生产者。
* Consumer：消息的消费者。
* Consumer Group：即消费组。一个消费组是由一个或者多个Consumer组成的，对于同一个Topic，不同的消费组都将能消费到全量的消息，而同一个消费组中的Consumer将竞争每个消息（在多个Consumer消费同一个Topic时，Topic的任何一个分区将同时只能被一个Consumer消费）。

#### Kafka特性

* 高吞吐量、低延迟：kafka每秒可以处理几十万条消息，它的延迟最低只有几毫秒，每个topic可以分多个partition, consumer group 对partition进行consume操作；
* 可扩展性：kafka集群支持热扩展；
* 持久性、可靠性：消息被持久化到本地磁盘，并且支持数据备份防止数据丢失；
* 容错性：允许集群中节点失败（若副本数量为n,则允许n-1个节点失败）；
* 高并发：支持数千个客户端同时读写；
* 支持实时在线处理和离线处理：可以使用Storm这种实时流处理系统对消息进行实时进行处理，同时还可以使用Hadoop这种批处理系统进行离线处理；

#### Kafka Leader的选举机制

* Kafka的Leader是什么？
  * 首先Kafka会将接收到的消息分区（partition），每个主题（topic）的消息有不同的分区。这样一方面消息的存储就不会受到单一服务器存储空间大小的限制，另一方面消息的处理也可以在多个服务器上并行。
  * 其次为了保证高可用，每个分区都会有一定数量的副本（replica）。这样如果有部分服务器不可用，副本所在的服务器就会接替上来，保证应用的持续性。
  * 但是，为了保证较高的处理效率，消息的读写都是在固定的一个副本上完成。这个副本就是所谓的Leader，而其他副本则是Follower。而Follower则会定期地到Leader上同步数据。
* Leader选举
  * 如果某个分区所在的服务器出了问题，不可用，kafka会从该分区的其他的副本中选择一个作为新的Leader。之后所有的读写就会转移到这个新的Leader上。现在的问题是应当选择哪个作为新的Leader。显然，只有那些跟Leader保持同步的Follower才应该被选作新的Leader。
  * Kafka会在Zookeeper上针对每个Topic维护一个称为ISR（in-sync replica，已同步的副本）的集合，该集合中是一些分区的副本。只有当这些副本都跟Leader中的副本同步了之后，kafka才会认为消息已提交，并反馈给消息的生产者。如果这个集合有增减，kafka会更新zookeeper上的记录。
  * 如果某个分区的Leader不可用，Kafka就会从ISR集合中选择一个副本作为新的Leader。
  * 显然通过ISR，kafka需要的冗余度较低，可以容忍的失败数比较高。假设某个topic有f+1个副本，kafka可以容忍f个服务器不可用。
* 为什么不用少数服从多数的方法？
  * 少数服从多数是一种比较常见的一致性算法和Leader选举法。它的含义是只有超过半数的副本同步了，系统才会认为数据已同步；选择Leader时也是从超过半数的同步的副本中选择。这种算法需要较高的冗余度。譬如只允许一台机器失败，需要有三个副本；而如果只容忍两台机器失败，则需要五个副本。而kafka的ISR集合方法，分别只需要两个和三个副本。
* 如果所有的ISR副本都失败了怎么办？
  * 此时有两种方法可选，一种是等待ISR集合中的副本复活，一种是选择任何一个立即可用的副本，而这个副本不一定是在ISR集合中。这两种方法各有利弊，实际生产中按需选择。
  * 如果要等待ISR副本复活，虽然可以保证一致性，但可能需要很长时间。而如果选择立即可用的副本，则很可能该副本并不一致。


#### kafka集群partition分布原理分析

Kafka集群partition replication默认自动分配分析
![](.\image\kafka\kafka01.png)

副本分配逻辑规则如下：
* 在Kafka集群中，每个Broker都有均等分配Partition的Leader机会。
* 上述图Broker Partition中，箭头指向为副本，以Partition-0为例:broker1中parition-0为Leader，Broker2中Partition-0为副本。
* 上述图种每个Broker(按照BrokerId有序)依次分配主Partition,下一个Broker为副本，如此循环迭代分配，多副本都遵循此规则。
副本分配算法如下：
 * 将所有N Broker和待分配的i个Partition排序.
* 将第i个Partition分配到第(i mod n)个Broker上.
* 将第i个Partition的第j个副本分配到第((i + j) mod n)个Broker上.


#### Zookeeper在kafka的作用

无论是kafka集群，还是producer和consumer都依赖于zookeeper来保证系统可用性集群保存一些meta信息。
Kafka使用zookeeper作为其分布式协调框架，很好的将消息生产、消息存储、消息消费的过程结合在一起。
同时借助zookeeper，kafka能够将生产者、消费者和broker在内的所有组件在无状态的情况下，建立起生产者和消费者的订阅关系，并实现生产者与消费者的负载均衡。





### kafka单机安装 

```
环境配置:
操作系统：CentOS 7.6.1810
JDK版本：1.8.0_201
Zookeeper版本:zookeeper-3.4.14
Kafka版本：kafka_2.12-2.2.2
```

#### 安装步骤：

```
## 1.先安装zookeeper
curl -L -O http://apache.fayea.com/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz
tar xf zookeeper-3.4.14.tar.gz -C /usr/local/
ln -sv /usr/local/zookeeper-3.4.14/ /usr/local/zookeeper
[root@jack kafka]# cat /etc/profile.d/jdk.sh 
#!/bin/sh
JAVA_HOME=/usr/local/jdk
export PATH=$PATH:$JAVA_HOME/bin
---
[root@jack kafka]# cat /etc/profile.d/zookeeper.sh 
#!/bin/sh
ZOOKEEPER_HOME=/usr/local/zookeeper
export PATH=$PATH:$ZOOKEEPER_HOME/bin
---
[root@jack kafka]# cd /usr/local/zookeeper/conf
[root@jack conf]# cp zoo_sample.cfg zoo_sample.cfg.bak
[root@jack conf]# grep -v '^#' zoo.cfg 
tickTime=2000   #这个时间是作为 Zookeeper 服务器之间或客户端与服务器之间维持心跳的时间间隔，也就是每个 tickTime 时间就会发送一个心跳
initLimit=10
syncLimit=5
dataDir=/tmp/zookeeper  #Zookeeper 保存数据的目录,默认情况下，Zookeeper 将写数据的日志文件也保存在这个目录里
clientPort=2181  #这个端口就是客户端连接 Zookeeper 服务器的端口，Zookeeper 会监听这个端口，接受客户端的访问请求
---
[root@jack conf]# zkServer.sh start  #启动zookeeper
[root@jack conf]# zkServer.sh stop  #停止zookeeper
[root@jack conf]# netstat -tunlp | grep 2181
tcp6       0      0 :::2181                 :::*                    LISTEN      13529/java	

## 2.安装kafka:
curl -L -O https://mirrors.cnnic.cn/apache/kafka/2.2.2/kafka_2.12-2.2.2.tgz
tar xfz kafka_2.12-2.2.2.tgz -C /usr/local
ln -sv /usr/local/kafka_2.12-2.2.2/ /usr/local/kafka
[root@jack ~]# cat /etc/profile.d/kafka.sh 
#!/bin/sh
KAFKA_HOME=/usr/local/kafka
export PATH=$PATH:$KAFKA_HOME/bin
---
[root@jack kafka]# cd /usr/local/kafka/config/
[root@jack config]# cp server.properties server.properties.bak
[root@jack config]# egrep -v '^$|^#' server.properties
broker.id=0 #每一个broker在集群中的唯一表示，要求是正数。当该服务器的IP地址发生改变时，broker.id没有变化，则不会影响consumers的消息情况
listeners=PLAINTEXT://:9092  #kafka监听端口
num.network.threads=4 #broker处理消息的最大线程数，一般情况下数量为cpu核数
num.io.threads=8 #broker处理磁盘IO的线程数，数值为cpu核数2倍
socket.send.buffer.bytes=1024000 #socket的发送缓冲区，socket的调优参数SO_SNDBUFF
socket.receive.buffer.bytes=1024000 #socket的接受缓冲区，socket的调优参数SO_RCVBUFF
socket.request.max.bytes=104857600 #表示消息体的最大大小，单位是字节 
log.dirs=/tmp/kafka-logs #kafka数据的存放地址，多个地址的话用逗号分割,多个目录分布在不同磁盘上可以提高读写性能  /data/kafka-logs-1，/data/kafka-logs-2
num.partitions=2 #每个topic的分区个数，若是在topic创建时候没有指定的话会被topic创建时的指定参数覆盖
num.recovery.threads.per.data.dir=1 
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=168  #数据文件保留多长时间， 存储的最大时间超过这个时间会根据log.cleanup.policy设置数据清除策略log.retention.bytes和log.retention.minutes或log.retention.hours任意一个达到要求，都会执行删除
log.segment.bytes=1073741824  #topic的分区是以一堆segment文件存储的，这个控制每个segment的大小，会被topic创建时的指定参数覆盖
log.retention.check.interval.ms=300000 #文件大小检查的周期时间，是否处罚 log.cleanup.policy中设置的策略
zookeeper.connect=localhost:2181 #zookeeper集群的地址，可以是多个，多个之间用逗号分割 hostname1:port1,hostname2:port2,hostname3:port3
zookeeper.connection.timeout.ms=6000  #ZooKeeper的连接超时时间
group.initial.rebalance.delay.ms=0
---
[root@jack config]# kafka-server-start.sh \$KAFKA_HOME/config/server.properties &  #启动kafka
[root@jack ~]# netstat -tunlp | grep 9092
tcp6       0      0 :::9092                 :::*                    LISTEN      20797/java
[root@jack config]# jps
13529 QuorumPeerMain   #对应的zookeeper实例
21148 Jps
20797 Kafka  #kafka实例

## 3.单机连通性测试
consumer注意事项：
对于消费者，kafka中有两个设置的地方：对于老的消费者，由--zookeeper参数设置；对于新的消费者，由--bootstrap-server参数设置
如果使用了--zookeeper参数,那么consumer的信息将会存放在zk之中,则使用bin/kafka-console-consumer.sh --zookeeper 172.168.2.222:2181 --topic dblab01 
如果使用了--bootstrap-server参数,那么consumer的信息将会存放在kafka之中,则使用bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic dblab01 --from-beginning

[root@jack ~]# kafka-topics.sh --create --bootstrap-server 127.0.0.1:9092 --topic test2 --partitions 1 --replication-factor 1 #新建1个topic
[root@jack ~]# kafka-topics.sh --list --bootstrap-server 127.0.0.1:9092 #查看topic消息队列
__consumer_offsets
dblab01
test
test1
test2
[root@jack config]# kafka-console-producer.sh --broker-list 127.0.0.1:9092 --topic test1
>hello jack
[root@jack ~]# kafka-console-consumer.sh --bootstrap-server 127.0.0.1:9092 --topic test1 --from-beginning
adfadfa
sdfadafsdfas
safsdaf
jack    
hello world  #这些都是之前的消息
hello jack  #这是新接收到的消息
```


### kafka高可用集群部署

选举优先级：
1. 对比事务ID，谁大谁为leader,集群初始没有事务ID，需要看第二步
2. 对比server ID,谁大谁为leader


#### zookeeper高可用伪集群部署
```
curl -L -O http://apache.fayea.com/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz
tar xf zookeeper-3.4.14.tar.gz -C /usr/local/
ln -sv /usr/local/zookeeper-3.4.14/ /usr/local/zookeeper

## zookeeper01部署
[root@jack ~]# vim /usr/local/zookeeper/conf/zoo.cfg 
tickTime=2000  #用于计算的基础时间单元。比如session超时：N*tickTime
initLimit=10   #用于集群，允许从节点连接并同步到 master节点的初始化连接时间，以tickTime的倍数来表示
syncLimit=5    #用于集群， master主节点与从节点之间发送消息，请求和应答时间长度（心跳机制）
dataDir=/tmp/zookeeper/data1    #数据存储位置
dataLogDir=/tmp/zookeeper/log1  #日志目录
clientPort=2181    #用于客户端连接的端口，默认2181
server.1=127.0.0.1:2287:3387   #指定集群间通讯端口和选举端口
server.2=127.0.0.1:2288:3388
server.3=127.0.0.1:2289:3389   
---
#上面server.1 这个1是服务器的标识，可以是任意有效数字，标识这是第几个服务器节点，这个标识要写到dataDir目录下面myid文件里

## zookeeper02部署
[root@jack ~]# cp -a /usr/local/zookeeper-3.4.14 /usr/local/zookeeper2
[root@jack ~]# cp -a /usr/local/zookeeper-3.4.14 /usr/local/zookeeper3
[root@jack ~]# vim /usr/local/zookeeper2/conf/zoo.cfg
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/tmp/zookeeper/data2
dataLogDir=/tmp/zookeeper/log2
clientPort=2182
server.1=127.0.0.1:2287:3387
server.2=127.0.0.1:2288:3388
server.3=127.0.0.1:2289:3389

## zookeeper03部署
[root@jack ~]# vim /usr/local/zookeeper3/conf/zoo.cfg
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/tmp/zookeeper/data3
dataLogDir=/tmp/zookeeper/log3
clientPort=2183
server.1=127.0.0.1:2287:3387
server.2=127.0.0.1:2288:3388
server.3=127.0.0.1:2289:3389

## 标识节点
分别在三个节点的数据存储目录下新建myid文件,并写入对应的节点标识。Zookeeper集群通过myid文件识别集群节点，并通过上文配置的节点通信端口和选举端口来进行节点通信，选举出leader节点。
mkdir -p  /tmp/zookeeper/data{1,2,3}
mkdir -p  /tmp/zookeeper/log{1,2,3}
[root@jack zookeeper]# echo 1 > /tmp/zookeeper/data1/myid 
[root@jack zookeeper]# echo 2 > /tmp/zookeeper/data2/myid 
[root@jack zookeeper]# echo 3 > /tmp/zookeeper/data3/myid 

## 启动zookeeper
/usr/local/zookeeper/bin/zkServer.sh start   
/usr/local/zookeeper2/bin/zkServer.sh start
/usr/local/zookeeper3/bin/zkServer.sh start
[root@jack zookeeper]# netstat -tunlp  | egrep '218|338'
tcp6       0      0 :::2183                 :::*                    LISTEN      9581/java           
tcp6       0      0 127.0.0.1:3387          :::*                    LISTEN      9535/java           
tcp6       0      0 127.0.0.1:3388          :::*                    LISTEN      9551/java           
tcp6       0      0 127.0.0.1:3389          :::*                    LISTEN      9581/java           
tcp6       0      0 :::2181                 :::*                    LISTEN      9535/java           
tcp6       0      0 :::2182                 :::*                    LISTEN      9551/java      

[root@jack zookeeper]# /usr/local/zookeeper/bin/zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper/bin/../conf/zoo.cfg
Mode: follower
[root@jack zookeeper]# /usr/local/zookeeper2/bin/zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper2/bin/../conf/zoo.cfg
Mode: follower
[root@jack zookeeper]# /usr/local/zookeeper3/bin/zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper3/bin/../conf/zoo.cfg
Mode: leader    		#zookeeper3为leader
```

#### kafka高可用伪集群部署

```
curl -L -O https://mirrors.cnnic.cn/apache/kafka/2.2.2/kafka_2.12-2.2.2.tgz
tar xfz kafka_2.12-2.2.2.tgz -C /usr/local
ln -sv /usr/local/kafka_2.12-2.2.2/ /usr/local/kafka

## kafka01部署
[root@jack zookeeper]# vim /usr/local/kafka/config/server.properties
broker.id=0
listeners=PLAINTEXT://:9092
num.network.threads=4
num.io.threads=8
socket.send.buffer.bytes=1024000
socket.receive.buffer.bytes=1024000
socket.request.max.bytes=104857600  
log.dirs=/tmp/kafka1
num.partitions=1
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect=localhost:2181,localhost:2182,localhost:2183
zookeeper.connection.timeout.ms=6000
group.initial.rebalance.delay.ms=0
replica.lag.max.messages =4000
## 如果follower落后leader太多,将会认为此follower[或者说partition relicas]已经失效,通常,在follower与leader通讯时,因为网络延迟或者链接断开,总会导致replicas中消息同步滞后,如果消息滞后太多,leader将认为此follower网络延迟较大或者消息吞吐能力有限,将会把此replicas迁移到其他follower中,在broker数量较少,或者网络不足的环境中,建议提高此值.
replica.lag.time.max.ms =10000
## replicas响应partition leader的最长等待时间，若是超过这个时间，就将replicas列入ISR(in-sync replicas)，并认为它是死的，不会再加入管理中

## kafka02部署
[root@jack zookeeper]# vim /usr/local/kafka/config/server.properties
broker.id=1
listeners=PLAINTEXT://:9093
num.network.threads=4
num.io.threads=8
socket.send.buffer.bytes=1024000
socket.receive.buffer.bytes=1024000
socket.request.max.bytes=104857600  
log.dirs=/tmp/kafka2
num.partitions=1
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect=localhost:2181,localhost:2182,localhost:2183
zookeeper.connection.timeout.ms=6000
group.initial.rebalance.delay.ms=0
replica.lag.max.messages =4000
replica.lag.time.max.ms =10000

## kafka03部署
[root@jack zookeeper]# vim /usr/local/kafka/config/server.properties
broker.id=2
listeners=PLAINTEXT://:9094
num.network.threads=4
num.io.threads=8
socket.send.buffer.bytes=1024000
socket.receive.buffer.bytes=1024000
socket.request.max.bytes=104857600  
log.dirs=/tmp/kafka3
num.partitions=1
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect=localhost:2181,localhost:2182,localhost:2183
zookeeper.connection.timeout.ms=6000
group.initial.rebalance.delay.ms=0
replica.lag.max.messages =4000
replica.lag.time.max.ms =10000

## 启动kafka
/usr/local/kafka/bin/kafka-server-start.sh -daemon /usr/local/kafka/config/server.properties
/usr/local/kafka2/bin/kafka-server-start.sh -daemon /usr/local/kafka2/config/server.properties
/usr/local/kafka3/bin/kafka-server-start.sh -daemon /usr/local/kafka3/config/server.properties
[root@jack zookeeper]# netstat -tunlp  | egrep '909'
tcp6       0      0 :::9092                 :::*                    LISTEN      9876/java           
tcp6       0      0 :::9093                 :::*                    LISTEN      10181/java          
tcp6       0      0 :::9094                 :::*                    LISTEN      10507/java    

## 新建一个叫topic的消息队列
[root@jack zookeeper]# /usr/local/kafka/bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 3 --partitions 3 --topic topic
[root@jack zookeeper]# /usr/local/kafka/bin/kafka-topics.sh --describe --bootstrap-server localhost:9092 --topic topic
Topic:topic	PartitionCount:3	ReplicationFactor:3	Configs:segment.bytes=1073741824
	Topic: topic	Partition: 0	Leader: 2	Replicas: 2,0,1	Isr: 2,0,1
	Topic: topic	Partition: 1	Leader: 1	Replicas: 1,2,0	Isr: 1,2,0
	Topic: topic	Partition: 2	Leader: 0	Replicas: 0,1,2	Isr: 0,1,2
# parttionCount:3表示有3个分区，ReplicationFactor:3表示每个分区复制了3份，第一行Topic:topic表示消息队列叫topic,Partition:0表示第一个分区，Leader:2表示这个分区的Leader在第三个节点上(也就是broker.id=2的kafka服务器上),Replicas:2,0,1表示这个分区有3个副本，其中2为Leader,其它为follower，ISR:2,0,1表示isr管理器维护和同步成功了这个分区上的三个副本.


## 测试集群

# 模拟生产者进行生产消息
[root@jack zookeeper]# /usr/local/kafka/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic topic 
>hello kafka

# 模拟消费者进行消费
[root@jack ~]# /usr/local/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9093 --topic topic --from-beginning 
hello kafka

## 模拟故障一台kafka broker.id=0,看topic消息队列是否受影响
[root@jack ~]# jps -m
17930 Kafka /usr/local/kafka2/config/server.properties
18298 Kafka /usr/local/kafka3/config/server.properties
16956 ConsoleConsumer --bootstrap-server localhost:9093 --topic topic --from-beginning
9581 QuorumPeerMain /usr/local/zookeeper3/bin/../conf/zoo.cfg
16669 ConsoleProducer --broker-list localhost:9092 --topic topic
17629 Kafka /usr/local/kafka/config/server.properties
9535 QuorumPeerMain /usr/local/zookeeper/bin/../conf/zoo.cfg
9551 QuorumPeerMain /usr/local/zookeeper2/bin/../conf/zoo.cfg

[root@jack ~]#  kill -9 17629  #此时kafka01已经下线,也就是9092已经下线
[root@jack ~]# /usr/local/kafka/bin/kafka-topics.sh --describe --bootstrap-server localhost:9093 --topic topic
Topic:topic	PartitionCount:3	ReplicationFactor:3	Configs:segment.bytes=1073741824
	Topic: topic	Partition: 0	Leader: 2	Replicas: 2,0,1	Isr: 1,2
	Topic: topic	Partition: 1	Leader: 1	Replicas: 1,2,0	Isr: 1,2
	Topic: topic	Partition: 2	Leader: 1	Replicas: 0,1,2	Isr: 1,2
	
[root@jack zookeeper]# /usr/local/kafka/bin/kafka-console-producer.sh --broker-list localhost:9094 --topic topic
>jack123

[root@jack kafka1]# /usr/local/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9094 --topic topic --from-beginning
jack123		# 此时消息队列可以很正常生产和消费。


## 模拟zookeeper一台故障
[root@jack ~]# /usr/local/zookeeper/bin/zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper/bin/../conf/zoo.cfg
Mode: follower

[root@jack ~]# /usr/local/zookeeper2/bin/zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper2/bin/../conf/zoo.cfg
Mode: leader

[root@jack ~]# /usr/local/zookeeper3/bin/zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper3/bin/../conf/zoo.cfg
Mode: follower

# 现在模拟zookeeper01故障
[root@jack ~]# /usr/local/zookeeper2/bin/zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper2/bin/../conf/zoo.cfg
Mode: leader

[root@jack ~]# /usr/local/zookeeper3/bin/zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper3/bin/../conf/zoo.cfg
Mode: follower

[root@jack ~]# /usr/local/zookeeper/bin/zkServer.sh status  #此时zookeeper01已经下线
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper/bin/../conf/zoo.cfg
Error contacting service. It is probably not running.

# 2181端口，zookeeper01快线下线
[root@jack ~]# netstat -tunlp | grep 218   
tcp6       0      0 :::2183                 :::*                    LISTEN      32192/java          
tcp6       0      0 :::2182                 :::*                    LISTEN      9551/java     

# 之前已经恢复kafka01节点，所以id为0的broker已经在ISR管理器中，而且kafka集群不受影响，而且生产者和消费者都可以正常的执行
[root@jack ~]# /usr/local/kafka/bin/kafka-topics.sh --describe --bootstrap-server localhost:9094 --topic topic
Topic:topic	PartitionCount:3	ReplicationFactor:3	Configs:segment.bytes=1073741824
	Topic: topic	Partition: 0	Leader: 2	Replicas: 2,0,1	Isr: 2,0,1
	Topic: topic	Partition: 1	Leader: 1	Replicas: 1,2,0	Isr: 2,0,1
	Topic: topic	Partition: 2	Leader: 0	Replicas: 0,1,2	Isr: 2,0,1


# 正常使用方法
[root@jack job]# /usr/local/kafka/bin/kafka-console-producer.sh --broker-list localhost:9092,localhost:9093,localhost:9094 --topic topic

[root@jack ~]# /usr/local/kafka/bin//kafka-console-consumer.sh --bootstrap-server localhost:9092,localhost:9093,localhost:9094 --topic topic


## 注意：
1. 当zookeeper集群只有一个节点在线时，则你只能通过监听端口来判断zookerper是否在线。通过zkServer.sh status是看不出来的。
2. 当你的kafka集群生产者连接的是kafka03,消费者连接的也是kafka03，此时当node3的kafka故障，则你的生产者和消费者会报错误日志，不能连接9094端口进行消息队列的执行。只能连接9092或9093端口进行生产和消费。
3. 只有生产者和消费者像上面这样进行生产和消费时，当其中任意2台broker故障时，生产者和消费者都能正常实现消息传输，因为Replicas为3，所以还会有1台broker是正常的
```



#### kafka的故障恢复及备份

1. zookeeper为多节点集群，当某台节点故障时，会自动选择新的leader进行故障转移。
2. 当zookeeper恢复备份时，复制zookeeper的安装包，并更改配置文件，然后在自己的data数据目录下新建一个myid文件，文件内容为自己所在的服务器id，等于本机zoo.cfg配置文件中server.1中的ID1。重启zookeeper服务会自动加入zookeeper集群
3. kafka多台集群，当某台集群故障时，只需要重新让好的kafka broker加入，并重启服务，此新的broker会从之前topic的leader中自动同步数据到新的broker,集群ID必须和故障的broker ID一样，否则不会同步topic信息
4. 注: 有多个节点时，把ReplicationFactor设成节点数量，可使集群高可用


#### kafka日常使用命令

```
## 使用kafka消费组
[root@jack kafka3]# /usr/local/kafka/bin/kafka-consumer-groups.sh --list --bootstrap-server localhost:9092,localhost:9093,localhost:9094
console-consumer-13507

[root@jack kafka3]# /usr/local/kafka/bin/kafka-consumer-groups.sh --describe --bootstrap-server localhost:9092,localhost:9093,localhost:9094 --group console-consumer-13507

TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID                                     HOST            CLIENT-ID
topic           0          -               21              -               consumer-1-f2550944-f0a1-4f65-a144-c77ffd17490f /172.168.2.222  consumer-1
topic           1          -               19              -               consumer-1-f2550944-f0a1-4f65-a144-c77ffd17490f /172.168.2.222  consumer-1
topic           2          -               21              -               consumer-1-f2550944-f0a1-4f65-a144-c77ffd17490f /172.168.2.222  consumer-1

## 打开生产者会话窗口
[root@jack kafka3]# /usr/local/kafka/bin/kafka-console-producer.sh --broker-list localhost:9092,localhost:9093,localhost:9094 --topic test 
>1
>2
>3
>4
>5
>6

## 打开消费者会话窗口
# 指定--consumer-property group.id=mygroup，表示为一个消费组，否则是一个消费者
# 如果指定--consumer-property consumer.id=jack，表示为一个指定消费者ID
[root@jack ~]# /usr/local/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092,localhost:9093,localhost:9094 --topic test --consumer-property group.id=mygroup --from-beginning  
1
2
4
5

[root@jack job]# /usr/local/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092,localhost:9093,localhost:9094 --topic test --consumer-property group.id=mygroup --from-beginning
3
6

[root@jack ~]# /usr/local/kafka/bin/kafka-consumer-groups.sh --list --bootstrap-server localhost:9092,localhost:9093,localhost:9094
mygroup  					#此时已经有了这个消费组
console-consumer-13507
```











## Zookeeper



### 什么Zookeeper

什么是分布式系统？

* 很多台计算机组成一个整体，一个整体一致对外并且处理同一请求
* 内部的每台计算机偶可以相互通信（rest/rpc）
* 客户端到服务端的一次请求到响应结束会历经多台计算机

Zookeeper是一个分布式开源框架，提供了协调分布式应用的基本服务，它向外部应用暴露一组通用服务——分布式同步（Distributed Synchronization）、命名服务（Naming Service）、集群维护（Group Maintenance）等，简化分布式应用协调及其管理的难度，提供高性能的分布式服务。ZooKeeper本身可以以单机模式安装运行，不过它的长处在于通过分布式ZooKeeper集群（一个Leader，多个Follower），基于一定的策略来保证ZooKeeper集群的稳定性和可用性，从而实现分布式应用的可靠性。

- 1、zookeeper是为别的分布式程序服务的
- 2、Zookeeper本身就是一个分布式程序（只要有半数以上节点存活，zk就能正常服务）
- 3、Zookeeper所提供的服务涵盖：主从协调、服务器节点动态上下线、统一配置管理、分布式共享锁、统一名称服务等
- 4、虽然说可以提供各种服务，但是zookeeper在底层其实只提供了两个功能：
  - 管理(存储，读取)用户程序提交的数据（类似namenode中存放的metadata）； 
  - 并为用户程序提供数据节点监听服务；



### Zookeeper集群机制

Zookeeper集群的角色： Leader 和 follower

只要集群中有半数以上节点存活，集群就能提供服务



### Zookeeper特性

- 1、Zookeeper：一个leader，多个follower组成的集群
- 2、全局数据**一致性**：每个server保存一份相同的数据副本，client无论连接到哪个server，数据都是一致的
- 3、分布式读写，更新请求转发，由leader实施
- 4、更新请求顺序进行，来自同一个client的更新请求按其发送**顺序依次执行**
- 5、数据更新**原子性**，一次数据更新要么成功，要么失败
- 6、**实时性**，在一定时间范围内，client能读到最新数据



### Zookeeper数据结构

- 1、层次化的目录结构，命名符合常规文件系统规范(类似文件系统） 

![img](https://1760849258-files.gitbook.io/~/files/v0/b/gitbook-legacy-files/o/assets%2F-LfnT31deyW842ExZVDh%2F-LfnTAqGO4YVUXXW5O6w%2F-LfnTMRb8Vn24uIRH-x1%2F1.1.png?generation=1558862986354043&alt=media)

- 2、每个节点在zookeeper中叫做znode,并且其有一个唯一的路径标识
- 3、节点Znode可以包含数据和子节点（但是EPHEMERAL类型的节点不能有子节点）

节点类型

> a、Znode有两种类型：
>
> 短暂（ephemeral）（create -e /app1/test1 “test1” 客户端断开连接zk删除ephemeral类型节点）
>
> 持久（persistent） （create -s /app1/test2 “test2” 客户端断开连接zk不删除persistent类型节点）
>
> b、Znode有四种形式的目录节点（默认是persistent ）
>
> PERSISTENT
>
> PERSISTENT_SEQUENTIAL（持久序列/test0000000019 ）
>
> EPHEMERAL
>
> EPHEMERAL_SEQUENTIAL
>
> c、创建znode时设置顺序标识，znode名称后会附加一个值，顺序号是一个单调递增的计数器，由父节点维护
>
> ![img](https://1760849258-files.gitbook.io/~/files/v0/b/gitbook-legacy-files/o/assets%2F-LfnT31deyW842ExZVDh%2F-LfnTAqGO4YVUXXW5O6w%2F-LfnTMRdo4vu5c08UdHs%2F1.2.png?generation=1558862988229758&alt=media)
>
> d、在分布式系统中，顺序号可以被用于为所有的事件进行全局排序，这样客户端可以通过顺序号推断事件的顺序



#### 文件系统

* ZooKeeper使用树形结构管理数据。而且以“/”作为树形结构的根节点。树形结构中的每一个节点都称为“znode”。文件系统中的目录可以存放其他目录和文件，znode中可以存放其他znode，也可以对应一个具体的值。znode和它对应的值之间是键值对的关系。
* 每一个znode上同时还有一套状态信息，称为：stat。

#### 通知机制

* 在分布式项目中随着业务功能越来越多，具体的功能模块也会越来越多，一个大型的电商项目能达到几十个模块甚至更多。这么多业务模块的工程有可能需要共享一些信息，这些信息一旦发生变化，在各个相关模块工程中手动逐一修改会非常麻烦，甚至可能发生遗漏，严重的可能导致系统崩溃，造成经济损失。
* 使用ZooKeeper的通知机制后，各个模块工程在特定znode上设置Watcher（观察者）来监控当前节点上值的变化。一旦Watcher检测到了数据变化就会立即通知模块工程，从而自动实现“一处修改，处处生效”的效果。



### Zookeeper主要目录结构

|      目录      |                 功能                 |
| :------------: | :----------------------------------: |
|      bin       |          主要的一些运行命令          |
|      conf      | 存放配置文件，其中我们需要修改zk.cfg |
|    contrib     |            附加的一些功能            |
| dist-maven:mvn |             编译后的目录             |
|      docs      |                 目录                 |
|      lib       |           需要依赖的jar包            |
|    recipes     |             安全demo代码             |
|      src       |                 源码                 |



### zookeeper常用命令

* ls命令

​		查看某个节点下子节点情况。注意：节点的路径必须以/开始。

- ls2命令

  在ls命令的基础上，不仅显示子节点，还显示节点的状态

- set命令

  设置指定节点的值

- get命令

  获取指定节点的值和状态信息

- stat命令

  查看指定节点的状态信息

- create命令

  创建新节点

- create [-s][-e] path data acl

​		-s参数：给创建出来的新节点名后面自动附加一个序列值

​		-e参数：创建临时节点，临时节点在Zookeeper服务器重启后会消失。非临时节点我们称之为：持久化节点。

- delete命令

  删除空节点，无法删除非空节点

- rmr命令

  删除节点，空与非空都可以删除



#### Zookeeper 节点类型

i. **PERSISTENT-持久化目录节点**

 客户端与zookeeper断开连接后，该节点依旧存在

ii. **PERSISTENT_SEQUENTIAL-持久化顺序编号目录节点**

 客户端与zookeeper断开连接后，该节点依旧存在，只是Zookeeper给该节点名称进行顺序编号

iii. **EPHEMERAL-临时目录节点**

 客户端与zookeeper断开连接后，该节点被删除

iv. **EPHEMERAL_SEQUENTIAL-临时顺序编号目录节点**

 客户端与zookeeper断开连接后，该节点被删除，只是Zookeeper给该节点名称进行顺序编号



#### stat

##### i. **介绍**

 znode维护了一个stat结构，这个stat包含数据变化的版本号、访问控制列表变化、还有时间戳。版本号和时间戳一起，可让ZooKeeper验证缓存和协调更新。每次znode的数据发生了变化，版本号就增加。

 例如：无论何时客户端检索数据，它也一起检索数据的版本号。并且当客户端执行更新或删除时，客户端必须提供他正在改变的znode的版本号。如果它提供的版本号和真实的数据版本号不一致，更新将会失败。

##### i. **属性**

**czxid**：引起这个znode创建的zxid，创建节点的事务的zxid（ZooKeeper Transaction Id）

**ctime：**znode被创建的毫秒数(从1970年开始)

**mzxid**：znode最后更新的zxid

**mtime：**znode最后修改的毫秒数(从1970年开始)

**pZxid：** znode最后更新的子节点zxid

**cversion** ：znode子节点变化号，znode子节点修改次数

**dataversion** ：znode数据变化号

**aclVersion** ：znode访问控制列表的变化号

**ephemeralOwner**：如果是临时节点，这个是znode拥有者的session id。如果不是临时节点则是0。

**dataLength** ：znode的数据长度

**numChildren**：znode子节点数量



#### 四字命令

##### **介绍**

ZooKeeper支持某些特定的四字命令，他们大多是用来查询ZooKeeper服务的当前状态及相关信息的，使用时通过telnet或nc向ZooKeeper提交相应命令。

```powershell
[root@right bin]# echo ruok | nc localhost 2181

imok[root@right bin]#
```

```
# 如果在使用四字命令时出现下面这个提示，说明该命令不在zookeeper的白名单里
[root@go bin]# echo ruok | nc 172.168.2.14 2181
ruok is not executed because it is not in the whitelist.

# 解决步骤: 找到conf文件夹下的zoo.cfg，在文件最后添加4lw.commands.whitelist=*，保存退出，所有命令都可以使用了。
[root@kafka conf]# cat zoo.cfg
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/data/zookeeper01
dataLogDir=/data/zookeeper01/zookeeper
clientPort=2181
maxClientCnxns=200
autopurge.snapRetainCount=3
autopurge.purgeInterval=1
server.1=172.168.2.14:2287:3387
server.2=172.168.2.14:2288:3388
server.3=172.168.2.14:2289:3389
4lw.commands.whitelist=*		#增加白名单命令
---
[root@kafka conf]# systemctl restart zookeeper01.service	#重启服务
[root@go bin]# echo ruok | nc 172.168.2.14 2181	
imok
```





##### **常用四字命令**

> **ruok**：测试服务是否处于正确状态。如果确实如此，那么服务返回“imok ”，否则不做任何响应
>
> **stat**：输出关于性能和连接的客户端的列表
>
> **conf**：输出相关服务配置的详细信息
>
> **cons**：列出所有连接到服务器的客户端的完全的连接 /会话的详细信息。包括“接受 / 发送”的包数量、会话id 、操作延迟、最后的操作执行等等信息
>
> **dump**：列出未经处理的会话和临时节点
>
> **envi**：输出关于服务环境的详细信息（区别于conf命令）
>
> **reqs**：列出未经处理的请求
>
> **wchs**：列出服务器watch的详细信息
>
> **wchc**：通过session列出服务器watch的详细信息，它的输出是一个与watch相关的会话的列表
>
> **wchp**：通过路径列出服务器 watch的详细信息。它输出一个与 session相关的路径











## zookeeper安全加固



### 什么情况下使用zookeeper认证机制呢？

zookeeper作为分布式架构中的一个重要中间件，通常会在其上面以节点的方式存储数据，默认情况下，所有应用都可以在zk读写任何节点，在复杂且对数据敏感性的应用中，这显然不安全，所以此时我们可以对zk做一些安全策略设置，可以使用以下几种手段：

* 修改zk 默认端口，使用其它端口服务；
* 限制访问来源地址；
* 添加访问控制；
* 不要将 zk 暴露在外网；
* 设置 zk 用户认证和 ACL。



### 配置zookeeper访问控制列表

**zookeeper ACL访问控制规则原理**

* zk可以使用ACL访问控制列表来对节点的权限进行控制, 它与UNIX 文件访问权限非常相似，zk的节点类比文件，客户端可以删除节点、创建节点、修改节点：它使用权限位来允许/禁止对节点的各种操作以及这些位适用的范围。

* ACL 指定一组 id 和与这些 id 关联的权限。acl权限控制使用scheme/id/permission来标志，主要包括三个方面：

```
·scheme     #权限模式
·id：       #权限对象
·permission   #权限类型
```

![ACL访问控制流程图](E:\DocFile\git\linux\image\zookeeper\zookeeper01.png)



**zookeeper ACL的特性**

```
zookeeper的权限控制是基于zookeeper node节点的，需要对每个节点设置权限。
每个zookeeper node支持设置多种权限控制方案和多个权限。
子节点不会继承父节点的权限。客户端无法访问某个节点，但是可以访问他的子节点。
```

![ACL规则命令](E:\DocFile\git\linux\image\zookeeper\zookeeper02.png)



### 使用zookeeper  ACL访问控制规则

1. world权限模式
   world权限模式只有一种设置模式。就是 setAcl world:anyone:[r][w][c][d][a]
   其中id:为固定的anyone，表示任何用户。

```
[zk: 172.168.2.14:2181(CONNECTED) 9] setAcl / world:anyone:cdrwa	#配置所有用户可以访问
[zk: 172.168.2.14:2181(CONNECTED) 10] getAcl /
'world,'anyone
: cdrwa
```

2. IP模式
   该模式使用的acl方式是 ip:192.168.XXX.12:[a][d][c][w][r]

```
## 172.168.2.14:2181上登录zookeepr
[root@kafka bin]# ./zkCli.sh -server 172.168.2.14:2181
[zk: localhost:2181(CONNECTED) 1] getAcl /
'world,'anyone	#表示任何人都可以访问，这是默认权限
: cdrwa

# 添加一个ip地址后会覆盖之前添加的ip地址，切记将自己的本机IP添加进来，否则只能重装。
# 每次修改需要写全ip，这个是覆盖不是新增
[zk: 172.168.2.14:2181(CONNECTED) 2] setAcl / ip:172.168.2.14:cdrwa,ip:172.168.2.13:cdrwa,ip:172.168.2.32:cdrwa

[zk: 172.168.2.14:2181(CONNECTED) 3] getAcl /
'ip,'172.168.2.14
: cdrwa
'ip,'172.168.2.13
: cdrwa
'ip,'172.168.2.32
: cdrwa


## 172.168.2.32上连接zookeeper 172.168.2.14:2181
[zk: 172.168.2.14:2181(CONNECTED) 0] getAcl /
'ip,'172.168.2.14
: cdrwa
'ip,'172.168.2.13
: cdrwa
'ip,'172.168.2.32
: cdrwa
[zk: 172.168.2.14:2181(CONNECTED) 1] setAcl / ip:172.168.2.14:cdrwa,ip:172.168.2.13:cdrwa
[zk: 172.168.2.14:2181(CONNECTED) 2] getAcl /
Authentication is not valid : /		#上面删除了172.168.2.32，所以32无权限访问了

```

3. 设置auth方式的身份认证机制

```
[zk: 172.168.2.14:2183(CONNECTED) 10] addauth digest jack:123456
[zk: 172.168.2.14:2183(CONNECTED) 11] setAcl / auth:jack:cdrwa
[zk: 172.168.2.14:2183(CONNECTED) 12] getAcl /
'digest,'jack:tgi9UCnyPo5FJjVylKr05nAlWeg=
: cdrwa

## 172.168.2.32上连接zookeeper 172.168.2.14:2181
[zk: 172.168.2.14:2181(CONNECTED) 0] ls /
Authentication is not valid : /
[zk: 172.168.2.14:2181(CONNECTED) 1] addauth digest jack:123456		#添加用户认证
[zk: 172.168.2.14:2181(CONNECTED) 2] ls /
[admin, brokers, cluster, config, consumers, controller_epoch, isr_change_notification, latest_producer_id_block, log_dir_event_notification, zookeeper]
```

```
## digest认证方式密码生成公式
[root@prometheus ~]# echo -n jack:123456 | openssl dgst -binary -sha1 | openssl base64
tgi9UCnyPo5FJjVylKr05nAlWeg=
```



## zookeeper UI部署



**maven安装**

```bash
$ wget http://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
$ tar xf apache-maven-3.3.9-bin.tar.gz -C /usr/local/
$ ln -sv /usr/local/apache-maven-3.3.9/ /usr/local/maven
$ cat - > /etc/profile.d/maven.sh << EOF
export PATH=$PATH:/usr/local/maven/bin/
EOF
$ source /etc/profile
```



**安装zkui**

```bash
$ git clone https://github.com/DeemOpen/zkui.git
$ cd zkui/ && make build
$ docker build -t zkui:2.0-SNAPSHOT --no-cache --rm docker
$ cat ./run.sh
$ docker run \
  -d \
  -e ZK_SERVER='172.168.2.14:2181,172.168.2.14:2182,172.168.2.14:2183' \
  --name zkui \
  -p 9090:9090 \
  zkui:2.0-SNAPSHOT

```



**效果图**

![效果图](.\image\zookeeper\zookeeper03.png)







# kafka调优



## 调优目标

在做调优之前，我们必须明确优化 Kafka 的目标是什么。通常来说，调优是为了满足系统常见的非功能性需求。在众多的非功能性需求中，性能绝对是我们最关心的那一个。不同的系统对性能有不同的诉求，比如对于数据库用户而言，性能意味着请求的响应时间，用户总是希望查询或更新请求能够被更快地处理完并返回。

对 Kafka 而言，性能一般是指吞吐量和延时。

吞吐量，也就是 TPS，是指 Broker 端进程或 Client 端应用程序每秒能处理的字节数或消息数，这个值自然是越大越好。

延时和我们刚才说的响应时间类似，它表示从 Producer 端发送消息到 Broker 端持久化完成之间的时间间隔。这个指标也可以代表端到端的延时（End-to-End，E2E），也就是从 Producer 发送消息到 Consumer 成功消费该消息的总时长。和 TPS 相反，我们通常希望延时越短越好。

总之，高吞吐量、低延时是我们调优 Kafka 集群的主要目标，一会儿我们会详细讨论如何达成这些目标。在此之前，我想先谈一谈优化漏斗的问题。

## 优化漏斗

优化漏斗是一个调优过程中的分层漏斗，我们可以在每一层上执行相应的优化调整。总体来说，层级越靠上，其调优的效果越明显，整体优化效果是自上而下衰减的，如下图所示：

![](.\image\kafka\kafka02.png)



**第 1 层：应用程序层**。它是指优化 Kafka 客户端应用程序代码。比如，使用合理的数据结构、缓存计算开销大的运算结果，抑或是复用构造成本高的对象实例等。这一层的优化效果最为明显，通常也是比较简单的。

**第 2 层：框架层**。它指的是合理设置 Kafka 集群的各种参数。毕竟，直接修改 Kafka 源码进行调优并不容易，但根据实际场景恰当地配置关键参数的值，还是很容易实现的。

**第 3 层：JVM 层**。Kafka Broker 进程是普通的 JVM 进程，各种对 JVM 的优化在这里也是适用的。优化这一层的效果虽然比不上前两层，但有时也能带来巨大的改善效果。

**第 4 层：操作系统层**。对操作系统层的优化很重要，但效果往往不如想象得那么好。与应用程序层的优化效果相比，它是有很大差距的。







## 基础性调优



### 操作系统调优

我先来说说操作系统层的调优。在操作系统层面，你最好在挂载（Mount）文件系统时禁掉 atime 更新。atime 的全称是 access time，记录的是文件最后被访问的时间。记录 atime 需要操作系统访问 inode 资源，而禁掉 atime 可以避免 inode 访问时间的写入操作，减少文件系统的写操作数。你可以执行**mount -o noatime 命令**进行设置。

至于文件系统，我建议你至少选择 ext4 或 XFS。尤其是 XFS 文件系统，它具有高性能、高伸缩性等特点，特别适用于生产服务器。值得一提的是，在去年 10 月份的 Kafka 旧金山峰会上，有人分享了 ZFS 搭配 Kafka 的案例，我们在专栏[第 8 讲]提到过与之相关的[数据报告](https://www.confluent.io/kafka-summit-sf18/kafka-on-zfs)。该报告宣称 ZFS 多级缓存的机制能够帮助 Kafka 改善 I/O 性能，据说取得了不错的效果。如果你的环境中安装了 ZFS 文件系统，你可以尝试将 Kafka 搭建在 ZFS 文件系统上。

另外就是 swap 空间的设置。我个人建议将 swappiness 设置成一个很小的值，比如 1～10 之间，以防止 Linux 的 OOM Killer 开启随意杀掉进程。你可以执行 sudo sysctl vm.swappiness=N 来临时设置该值，如果要永久生效，可以修改 /etc/sysctl.conf 文件，增加 vm.swappiness=N，然后重启机器即可。

操作系统层面还有两个参数也很重要，它们分别是**ulimit -n 和 vm.max_map_count**。前者如果设置得太小，你会碰到 Too Many File Open 这类的错误，而后者的值如果太小，在一个主题数超多的 Broker 机器上，你会碰到**OutOfMemoryError：Map failed**的严重错误，因此，我建议在生产环境中适当调大此值，比如将其设置为 655360。具体设置方法是修改 /etc/sysctl.conf 文件，增加 vm.max_map_count=655360，保存之后，执行 sysctl -p 命令使它生效。

最后，不得不提的就是操作系统页缓存大小了，这对 Kafka 而言至关重要。在某种程度上，我们可以这样说：给 Kafka 预留的页缓存越大越好，最小值至少要容纳一个日志段的大小，也就是 Broker 端参数 log.segment.bytes 的值。该参数的默认值是 1GB。预留出一个日志段大小，至少能保证 Kafka 可以将整个日志段全部放入页缓存，这样，消费者程序在消费时能直接命中页缓存，从而避免昂贵的物理磁盘 I/O 操作。

```bash
mount -o noatime -t xfs /data/kafka

[root@prometheus ~]# cat /etc/ansible/roles/base/files/limits.conf
*             soft    core            unlimited
*             hard    core            unlimited
*	      soft    nproc           1000000
*             hard    nproc           1000000
root	      soft    nproc           unlimited
root          hard    nproc           unlimited
# nofile最大值为 1048576(2**20)
*             soft    nofile          1000000
*             hard    nofile          1000000
root          soft    nofile          1000000
root          hard    nofile          1000000
*             soft    memlock         unlimited
*             hard    memlock         unlimited
*             soft    msgqueue        8192000
*             hard    msgqueue        8192000
---

cat >> /etc/sysctl.conf << EOF
vm.swappiness=0
vm.max_map_count=655360
EOF

```



### JVM 层调优

说完了操作系统层面的调优，我们来讨论下 JVM 层的调优，其实，JVM 层的调优，我们还是要重点关注堆设置以及 GC 方面的性能。

1. **设置堆大小**

如何为 Broker 设置堆大小，这是很多人都感到困惑的问题。我来给出一个朴素的答案：**将你的 JVM 堆大小设置成 6～8GB**。

在很多公司的实际环境中，这个大小已经被证明是非常合适的，你可以安心使用。如果你想精确调整的话，我建议你可以查看 GC log，特别是关注 Full GC 之后堆上存活对象的总大小，然后把堆大小设置为该值的 1.5～2 倍。如果你发现 Full GC 没有被执行过，手动运行 jmap -histo:live < pid > 就能人为触发 Full GC。

2. **GC 收集器的选择**

**我强烈建议你使用 G1 收集器，主要原因是方便省事，至少比 CMS 收集器的优化难度小得多**。另外，你一定要尽力避免 Full GC 的出现。其实，不论使用哪种收集器，都要竭力避免 Full GC。在 G1 中，Full GC 是单线程运行的，它真的非常慢。如果你的 Kafka 环境中经常出现 Full GC，你可以配置 JVM 参数 -XX:+PrintAdaptiveSizePolicy，来探查一下到底是谁导致的 Full GC。

使用 G1 还很容易碰到的一个问题，就是**大对象（Large Object）**，反映在 GC 上的错误，就是“too many humongous allocations”。所谓的大对象，一般是指至少占用半个区域（Region）大小的对象。举个例子，如果你的区域尺寸是 2MB，那么超过 1MB 大小的对象就被视为是大对象。要解决这个问题，除了增加堆大小之外，你还可以适当地增加区域大小，设置方法是增加 JVM 启动参数 -XX:+G1HeapRegionSize=N。默认情况下，如果一个对象超过了 N/2，就会被视为大对象，从而直接被分配在大对象区。如果你的 Kafka 环境中的消息体都特别大，就很容易出现这种大对象分配的问题。

3. **注意事项与相关参数**

对于单纯运行Kafka的集群而言，首先要注意的就是为Kafka设置合适（不那么大）的JVM堆大小。从上面的分析可知，Kafka的性能与堆内存关系并不大，而对page cache需求巨大。根据经验值，为Kafka分配6~8GB的堆内存就已经足足够用了，将剩下的系统内存都作为page cache空间，可以最大化I/O效率。





### Broker 端调优

我们继续沿着漏斗往上走，来看看 Broker 端的调优。

Broker 端调优很重要的一个方面，就是合理地设置 Broker 端参数值，以匹配你的生产环境。不过，后面我们在讨论具体的调优目标时再详细说这部分内容。这里我想先讨论另一个优化手段，**即尽力保持客户端版本和 Broker 端版本一致**。不要小看版本间的不一致问题，它会令 Kafka 丧失很多性能收益，比如 Zero Copy。下面我用一张图来说明一下。

![](.\image\kafka\kafka03.png)





### 应用层调优

现在，我们终于来到了漏斗的最顶层。其实，这一层的优化方法各异，毕竟每个应用程序都是不一样的。不过，有一些公共的法则依然是值得我们遵守的。

- **不要频繁地创建 Producer 和 Consumer 对象实例**。构造这些对象的开销很大，尽量复用它们。
- **用完及时关闭**。这些对象底层会创建很多物理资源，如 Socket 连接、ByteBuffer 缓冲区等。不及时关闭的话，势必造成资源泄露。
- **合理利用多线程来改善性能**。Kafka 的 Java Producer 是线程安全的，你可以放心地在多个线程中共享同一个实例；







## kafka生产环境配置

```bash
############################# Server Basics #############################
#broker 的 id,必须唯一
broker.id=0

############################# Socket Server Settings #############################
#监听地址
listeners=PLAINTEXT://192.168.1.6:9092

#Broker 用于处理网络请求的线程数
num.network.threads=6

#Broker 用于处理 I/O 的线程数，推荐值 8 * 磁盘数
num.io.threads=120

#在网络线程停止读取新请求之前，可以排队等待 I/O 线程处理的最大请求个数
queued.max.requests=1000

#socket 发送缓冲区大小
socket.send.buffer.bytes=102400

#socket 接收缓冲区大小
socket.receive.buffer.bytes=102400

#socket 接收请求的最大值（防止 OOM）
socket.request.max.bytes=104857600


############################# Log Basics #############################

#数据目录
log.dirs=/data1,/data2,/data3,/data4,/data5,/data6,/data7,/data8,/data9,/data10,/data11,/data12,/data13,/data14,/data15

#清理过期数据线程数
num.recovery.threads.per.data.dir=3

#单条消息最大 10 M
message.max.bytes=10485760

############################# Topic Settings #############################

#不允许自动创建 Topic
auto.create.topics.enable=false

#不允许 Unclean Leader 选举。
unclean.leader.election.enable=false

#不允许定期进行 Leader 选举。
auto.leader.rebalance.enable=false

#默认分区数
num.partitions=3

#默认分区副本数
default.replication.factor=3

#当生产者将 acks 设置为 "all"（或"-1"）时，此配置指定必须确认写入的副本的最小数量，才能认为写入成功
min.insync.replicas=2

#允许删除主题
delete.topic.enable=true

############################# Log Flush Policy #############################

#建议由操作系统使用默认设置执行后台刷新
#日志落盘消息条数阈值
#log.flush.interval.messages=10000
#日志落盘时间间隔
#log.flush.interval.ms=1000
#检查是否达到flush条件间隔
#log.flush.scheduler.interval.ms=200

############################# Log Retention Policy #############################

#日志留存时间 7 天
log.retention.hours=168

#最多存储 58TB 数据
log.retention.bytes=63771674411008
                    
#日志文件中每个 segment 的大小为 1G
log.segment.bytes=1073741824

#检查 segment 文件大小的周期 5 分钟
log.retention.check.interval.ms=300000

#开启日志压缩
log.cleaner.enable=true

#日志压缩线程数
log.cleaner.threads=8

############################# Zookeeper #############################

#Zookeeper 连接参数
zookeeper.connect=192.168.1.6:2181,192.168.1.7:2181,192.168.1.8:2181

#连接 Zookeeper 的超时时间
zookeeper.connection.timeout.ms=6000


############################# Group Coordinator Settings #############################

#为了缩短多消费者首次平衡的时间，这段延时期间 10s 内允许更多的消费者加入组
group.initial.rebalance.delay.ms=10000

#心跳超时时间默认 10s，设置成 6s 主要是为了让 Coordinator 能够更快地定位已经挂掉的 Consumer
session.timeout.ms = 6s。

#心跳间隔时间，session.timeout.ms >= 3 * heartbeat.interval.ms。
heartbeat.interval.ms=2s

#最长消费时间 5 分钟
max.poll.interval.ms=300000
```

