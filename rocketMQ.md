# RocketMQ



## RocketMQ 读写分离原理

* 读写分离机制是高性能、高可用架构中常见的设计，例如Mysql实现读写分离机制，Client只能从Master服务器写数据，可以从Master服务器和Slave服务器都读数据。
* RocketMQ的Consumer在拉取消息时，Broker会判断Master服务器的消息堆积量来决定Consumer是否从Slave服务器拉取消息消费。默认一开始从Master服务器拉取消息，如果Master服务器的消息堆积超过物理内存40%，则会返回给Consumer的消息结果并告知Consumer，下次从其他Slave服务器上拉取消息。
* RocketMQ采用Broker数据主从复制机制，当消息发送到Master服务器后会将消息同步到Slave服务器，如果Master服务器宕机，消息消费者还可以继续从Slave拉取消息。





## 单节点部署



### 安装RocketMQ nameServer

```
sudo docker pull apache/rocketmq:latest
sudo docker run -d -v /data/rocketmq/rocketmq/logs/:/home/rocketmq/logs --name rocketmq -p 9876:9876 apache/rocketmq:latest sh mqnamesrv
```



### 安装RocketMQ Broker

```
mkdir -pv /data/rocketmq/rocketmq-broker/conf
cat >> /data/rocketmq/rocketmq-broker/conf/broker-Default.conf << EOF
brokerClusterName = Homsom.Cluster
brokerName = master-broker
brokerId = 0
deleteWhen = 04
fileReservedTime = 48
brokerRole = ASYNC_MASTER
flushDiskType = ASYNC_FLUSH
brokerIP1 = 192.168.13.50
EOF

sudo docker run -d --memory 8589934592 -v /data/rocketmq/rocketmq-broker/logs:/home/rocketmq/logs -v /data/rocketmq/rocketmq-broker/store:/home/rocketmq/store -v /data/rocketmq/rocketmq-broker/conf/broker-Default.conf:/home/rocketmq/conf/broker.conf --name rocketmq-broker --link rocketmq:namesrv -e "NAMESRV_ADDR=namesrv:9876" -p 10909:10909 -p 10911:10911 -p 10912:10912 apache/rocketmq:latest sh mqbroker -c /home/rocketmq/conf/broker.conf
```



### 安装RocketMQ Dashboard

```
sudo docker pull apacherocketmq/rocketmq-dashboard:latest
sudo docker run -d --name rocketmq-dashboard -e "JAVA_OPTS=-Drocketmq.namesrv.addr=192.168.13.50:9876" -e "ROCKETMQ_CONFIG_LOGIN_REQUIRED=true" -p 18080:8080 -t apacherocketmq/rocketmq-dashboard:latest
```



### 模拟生产消费

```
export NAMESRV_ADDR='127.0.0.1:9876'
./tools.sh org.apache.rocketmq.example.quickstart.Producer
./tools.sh org.apache.rocketmq.example.quickstart.Consumer
```









## 集群部署



### Master-Slave 架构部署 配置

```
#在各服务器执行以下命令创建数据目录
[admin@rocketmq1 rocketmq]$ mkdir -p /home/admin/rocketmq/data/store
[admin@rocketmq1 rocketmq]$ mkdir -p /home/admin/rocketmq/data/store/commitlog
[admin@rocketmq1 rocketmq]$ mkdir -p /home/admin/rocketmq/data/store/consumequeue
[admin@rocketmq1 rocketmq]$ mkdir -p /home/admin/rocketmq/data/store/index


#在各服务器执行以下命令修改日志存储路径
[admin@rocketmq1 rocketmq]$ sed -i  's#${user.home}#/home/admin/rocketmq/data#g' conf/*.xml


#配置Broker_Master-1
[admin@rocketmq1 rocketmq]$ cat conf/2m-2s-async/broker-a.properties
brokerClusterName=rocketmq-2m-slave-cluster-async
brokerName=rocketmq-broker-m1
brokerId=0
namesrvAddr=192.168.10.76:9876;192.168.10.77:9876;192.168.10.78:9876;192.168.10.79:9876
defaultTopicQueueNums=4
autoCreateTopicEnable=true
autoCreateSubscriptionGroup=true
listenPort=10911
deleteWhen=04
fileReservedTime=120
mapedFileSizeCommitLog=1073741824
mapedFileSizeConsumeQueue=50000000
destroyMapedFileIntervalForcibly=120000
redeleteHangedFileInterval=120000
diskMaxUsedSpaceRatio=88
maxMessageSize=65536
sendMessageThreadPoolNums=128
pullMessageThreadPoolNums=128
storePathRootDir=/home/admin/rocketmq/data/store
storePathCommitLog=/home/admin/rocketmq/data/store/commitlog
storePathConsumeQueue=/home/admin/rocketmq/data/store/consumequeue
storePathIndex=/home/admin/rocketmq/data/store/index
storeCheckpoint=/home/admin/rocketmq/data/store/checkpoint
abortFile=/home/admin/rocketmq/data/store/abort
brokerRole=ASYNC_MASTER
flushDiskType=ASYNC_FLUSH


#配置Broker_Master-2
[admin@rocketmq2 rocketmq]$ cat conf/2m-2s-async/broker-b.properties
brokerClusterName=rocketmq-2m-slave-cluster-async
brokerName=rocketmq-broker-m2
brokerId=0
namesrvAddr=192.168.10.76:9876;192.168.10.77:9876;192.168.10.78:9876;192.168.10.79:9876
defaultTopicQueueNums=4
autoCreateTopicEnable=true
autoCreateSubscriptionGroup=true
listenPort=10911
deleteWhen=04
fileReservedTime=120
mapedFileSizeCommitLog=1073741824
mapedFileSizeConsumeQueue=50000000
destroyMapedFileIntervalForcibly=120000
redeleteHangedFileInterval=120000
diskMaxUsedSpaceRatio=88
maxMessageSize=65536
sendMessageThreadPoolNums=128
pullMessageThreadPoolNums=128
storePathRootDir=/home/admin/rocketmq/data/store
storePathCommitLog=/home/admin/rocketmq/data/store/commitlog
storePathConsumeQueue=/home/admin/rocketmq/data/store/consumequeue
storePathIndex=/home/admin/rocketmq/data/store/index
storeCheckpoint=/home/admin/rocketmq/data/store/checkpoint
abortFile=/home/admin/rocketmq/data/store/abort
brokerRole=ASYNC_MASTER
flushDiskType=ASYNC_FLUSH


#配置Broker_Master_slave-1
[admin@rocketmq3 rocketmq]$ cat conf/2m-2s-async/broker-a-s.properties
brokerClusterName=rocketmq-2m-slave-cluster-async
brokerName=rocketmq-broker-m1
brokerId=1
namesrvAddr=192.168.10.76:9876;192.168.10.77:9876;192.168.10.78:9876;192.168.10.79:9876
defaultTopicQueueNums=4
autoCreateTopicEnable=true
autoCreateSubscriptionGroup=true
listenPort=10911
deleteWhen=04
fileReservedTime=120
mapedFileSizeCommitLog=1073741824
mapedFileSizeConsumeQueue=50000000
destroyMapedFileIntervalForcibly=120000
redeleteHangedFileInterval=120000
diskMaxUsedSpaceRatio=88
maxMessageSize=65536
sendMessageThreadPoolNums=128
pullMessageThreadPoolNums=128
storePathRootDir=/home/admin/rocketmq/data/store
storePathCommitLog=/home/admin/rocketmq/data/store/commitlog
storePathConsumeQueue=/home/admin/rocketmq/data/store/consumequeue
storePathIndex=/home/admin/rocketmq/data/store/index
storeCheckpoint=/home/admin/rocketmq/data/store/checkpoint
abortFile=/home/admin/rocketmq/data/store/abort
brokerRole=SLAVE
flushDiskType=ASYNC_FLUSH


#配置Broker_Master_slave-2
[admin@rocketmq3 rocketmq]$ cat conf/2m-2s-async/broker-b-s.properties
brokerClusterName=rocketmq-2m-slave-cluster-async
brokerName=rocketmq-broker-m2
brokerId=1
namesrvAddr=192.168.10.76:9876;192.168.10.77:9876;192.168.10.78:9876;192.168.10.79:9876
defaultTopicQueueNums=4
autoCreateTopicEnable=true
autoCreateSubscriptionGroup=true
listenPort=10911
deleteWhen=04
fileReservedTime=120
mapedFileSizeCommitLog=1073741824
mapedFileSizeConsumeQueue=50000000
destroyMapedFileIntervalForcibly=120000
redeleteHangedFileInterval=120000
diskMaxUsedSpaceRatio=88
maxMessageSize=65536
sendMessageThreadPoolNums=128
pullMessageThreadPoolNums=128
storePathRootDir=/home/admin/rocketmq/data/store1
storePathCommitLog=/home/admin/rocketmq/data/store/commitlog1
storePathConsumeQueue=/home/admin/rocketmq/data/store/consumequeue1
storePathIndex=/home/admin/rocketmq/data/store/index1
storeCheckpoint=/home/admin/rocketmq/data/store/checkpoint1
abortFile=/home/admin/rocketmq/data/store/abort1
brokerRole=SLAVE
flushDiskType=ASYNC_FLUSH


#启动Nameserver1
[admin@rocketmq1 rocketmq]$ nohup bash bin/mqnamesrv &

#启动Nameserver2
[admin@rocketmq2 rocketmq]$ nohup bash bin/mqnamesrv &

#启动Nameserver3
[admin@rocketmq3 rocketmq]$ nohup bash bin/mqnamesrv &

#启动Nameserver4
[admin@rocketmq4 rocketmq]$ nohup bash bin/mqnamesrv &



#启动Broker_Master-1
[admin@rocketmq1 rocketmq]$ nohup bash bin/mqbroker -c conf/2m-2s-async/broker-a.properties &

#启动Broker_Master-2
[admin@rocketmq2 rocketmq]$ nohup bash bin/mqbroker -c conf/2m-2s-async/broker-b.properties &

#启动Broker_Master_slave-1
[admin@rocketmq3 rocketmq]$ nohup bash bin/mqbroker -c conf/2m-2s-async/broker-a-s.properties &

#启动Broker_Master_slave-2
[admin@rocketmq4 rocketmq]$ nohup bash bin/mqbroker -c conf/2m-2s-async/broker-b-s.properties &

#关闭NameServer
[admin@rocketmq1 rocketmq]$ bash bin/mqshutdown namesrv

#关闭Broker
[admin@rocketmq1 rocketmq]$ bash bin/mqshutdown broker

```





### Dledger 模式

```
RocketMQ 4.5 以前的版本大多都是采用 Master-Slave 架构来部署，能在一定程度上保证数据的不丢失，也能保证一定的可用性。

但是那种方式 的缺陷很明显，最大的问题就是当 Master Broker 挂了之后 ，没办法让 Slave Broker 自动 切换为新的 Master Broker，需要手动更改配置将 Slave Broker 设置为 Master Broker，以及重启机器，这个非常麻烦。

在手动运维的期间，可能会导致系统的不可用。

使用 Dledger 技术要求至少由三个 Broker 组成 ，一个 Master 和两个 Slave，这样三个 Broker 就可以组成一个 Group ，也就是三个 Broker 可以分组来运行。一但 Master 宕机，Dledger 就可以从剩下的两个 Broker 中选举一个 Master 继续对外提供服务。
```



#### DLedger 多副本即主从切换核心配置参数

| 配置名称              | 含义                                                         |
| :-------------------- | :----------------------------------------------------------- |
| enableDLegerCommitLog | 是否启用 DLedger，即是否启用 RocketMQ 主从切换，默认值为 false。如果需要开启主从切换，则该值需要设置为 true。 |
| dLegerGroup           | 节点所属的 raft 组，建议与 brokerName 保持一致，例如 broker-a。 |
| dLegerPeers           | 集群节点信息，示例配置如下：n0-127.0.0.1:40911;n1-127.0.0.1:40912;n2-127.0.0.1:40913，多个节点用英文冒号隔开，单个条目遵循 legerSlefId-ip:端口，这里的端口用作 dledger 内部通信。 |
| dLegerSelfId          | 当前节点id。取自 legerPeers 中条目的开头，即上述示例中的 n0，并且特别需要强调，只能第一个字符为英文，其他字符需要配置成数字。 |
| storePathRootDir      | DLedger 日志文件的存储根目录，为了能够支持平滑升级，该值与 storePathCommitLog 设置为不同的目录 |



#### 环境如下

| 主机      | IP地址        | 组件划分                           |
| :-------- | :------------ | :--------------------------------- |
| rocketmq1 | 192.168.10.76 | Nameserver1、Broker_Master-1       |
| rocketmq2 | 192.168.10.77 | Nameserver2、Broker_Master_slave-1 |
| rocketmq3 | 192.168.10.78 | Nameserver3、Broker_Master_slave-2 |



#### Dledger 模式 配置

```
#在各服务器执行以下命令创建数据目录
[admin@rocketmq1 rocketmq]$ mkdir -p /home/admin/rocketmq/data/store
[admin@rocketmq1 rocketmq]$ mkdir -p /home/admin/rocketmq/data/store/commitlog
[admin@rocketmq1 rocketmq]$ mkdir -p /home/admin/rocketmq/data/store/consumequeue
[admin@rocketmq1 rocketmq]$ mkdir -p /home/admin/rocketmq/data/store/index

#在各服务器执行以下命令修改日志存储路径
[admin@rocketmq1 rocketmq]$ sed -i  's#${user.home}#/home/admin/rocketmq/data#g' conf/*.xml


#配置Broker_Master-1
[admin@rocketmq1 rocketmq]$ cat conf/2m-2s-sync/broker-a.properties
brokerClusterName=rocketmq-2m-slave-cluster
brokerName=rocketmq-broker-m1
brokerId=0
namesrvAddr=192.168.10.76:9876;192.168.10.77:9876;192.168.10.78:9876
defaultTopicQueueNums=4
autoCreateTopicEnable=true
autoCreateSubscriptionGroup=true
listenPort=10911
deleteWhen=04
fileReservedTime=120
mapedFileSizeCommitLog=1073741824
mapedFileSizeConsumeQueue=50000000
destroyMapedFileIntervalForcibly=120000
redeleteHangedFileInterval=120000
diskMaxUsedSpaceRatio=88
maxMessageSize=65536
sendMessageThreadPoolNums=128
pullMessageThreadPoolNums=128
storePathRootDir=/home/admin/rocketmq/data/store
storePathCommitLog=/home/admin/rocketmq/data/store/commitlog
storePathConsumeQueue=/home/admin/rocketmq/data/store/consumequeue
storePathIndex=/home/admin/rocketmq/data/store/index
storeCheckpoint=/home/admin/rocketmq/data/store/checkpoint
abortFile=/home/admin/rocketmq/data/store/abort
brokerRole=ASYNC_MASTER
flushDiskTyp=ASYNC_FLUSH
# dledger 相关的配置属性
enableDLegerCommitLog=true
storePathRootDir=/home/admin/rocketmq/data/store/dledger
dLegerGroup=rocketmq-broker-m1
dLegerPeers=n0-192.168.10.76:40911;n1-192.168.10.77:40911;n2-192.168.10.78:40911
dLegerSelfId=n0


#配置Broker_Master_slave-1
[admin@rocketmq2 rocketmq]$ cat conf/2m-2s-sync/broker-a-s.properties
brokerClusterName=rocketmq-2m-slave-cluster
brokerName=rocketmq-broker-m1
brokerId=1
namesrvAddr=192.168.10.76:9876;192.168.10.77:9876;192.168.10.78:9876
defaultTopicQueueNums=4
autoCreateTopicEnable=true
autoCreateSubscriptionGroup=true
listenPort=10911
deleteWhen=04
fileReservedTime=120
mapedFileSizeCommitLog=1073741824
mapedFileSizeConsumeQueue=50000000
destroyMapedFileIntervalForcibly=120000
redeleteHangedFileInterval=120000
diskMaxUsedSpaceRatio=88
maxMessageSize=65536
sendMessageThreadPoolNums=128
pullMessageThreadPoolNums=128
storePathRootDir=/home/admin/rocketmq/data/store
storePathCommitLog=/home/admin/rocketmq/data/store/commitlog
storePathConsumeQueue=/home/admin/rocketmq/data/store/consumequeue
storePathIndex=/home/admin/rocketmq/data/store/index
storeCheckpoint=/home/admin/rocketmq/data/store/checkpoint
abortFile=/home/admin/rocketmq/data/store/abort
brokerRole=SLAVE
flushDiskTyp=ASYNC_FLUSH
# dledger 相关的配置属性
enableDLegerCommitLog=true
storePathRootDir=/home/admin/rocketmq/data/store/dledger
dLegerGroup=rocketmq-broker-m1
dLegerPeers=n0-192.168.10.76:40911;n1-192.168.10.77:40911;n2-192.168.10.78:40911
dLegerSelfId=n1


#配置Broker_Master_slave-2
[admin@rocketmq3 rocketmq]$ cat conf/2m-2s-sync/broker-a-s.properties
brokerClusterName=rocketmq-2m-slave-cluster
brokerName=rocketmq-broker-m1
brokerId=2
namesrvAddr=192.168.10.76:9876;192.168.10.77:9876;192.168.10.78:9876
defaultTopicQueueNums=4
autoCreateTopicEnable=true
autoCreateSubscriptionGroup=true
listenPort=10911
deleteWhen=04
fileReservedTime=120
mapedFileSizeCommitLog=1073741824
mapedFileSizeConsumeQueue=50000000
destroyMapedFileIntervalForcibly=120000
redeleteHangedFileInterval=120000
diskMaxUsedSpaceRatio=88
maxMessageSize=65536
sendMessageThreadPoolNums=128
pullMessageThreadPoolNums=128
storePathRootDir=/home/admin/rocketmq/data/store
storePathCommitLog=/home/admin/rocketmq/data/store/commitlog
storePathConsumeQueue=/home/admin/rocketmq/data/store/consumequeue
storePathIndex=/home/admin/rocketmq/data/store/index
storeCheckpoint=/home/admin/rocketmq/data/store/checkpoint
abortFile=/home/admin/rocketmq/data/store/abort
brokerRole=SLAVE
flushDiskTyp=ASYNC_FLUSH
# dledger 相关的配置属性
enableDLegerCommitLog=true
storePathRootDir=/home/admin/rocketmq/data/store/dledger
dLegerGroup=rocketmq-broker-m1
dLegerPeers=n0-192.168.10.76:40911;n1-192.168.10.77:40911;n2-192.168.10.78:40911
dLegerSelfId=n2


#启动Nameserver1
[admin@rocketmq1 rocketmq]$ nohup bash bin/mqnamesrv &

#启动Nameserver2
[admin@rocketmq2 rocketmq]$ nohup bash bin/mqnamesrv &

#启动Nameserver3
[admin@rocketmq3 rocketmq]$ nohup bash bin/mqnamesrv &

#启动Broker_Master-1
[admin@rocketmq1 rocketmq]$ nohup bash bin/mqbroker -c conf/2m-2s-sync/broker-a.properties &

#启动Broker_Master_slave-1
[admin@rocketmq2 rocketmq]$ nohup bash bin/mqbroker -c conf/2m-2s-sync/broker-a-s.properties &

#启动Broker_Master_slave-2
[admin@rocketmq3 rocketmq]$ nohup bash bin/mqbroker -c conf/2m-2s-sync/broker-a-s.properties &


# 通过RocketMQ Dashboard查看集群，此时192.168.10.77为master，其它为slave,接下来停止192.168.10.77上的broker服务
[admin@rocketmq2 rocketmq]$ bash bin/mqshutdown broker
[admin@rocketmq2 rocketmq]$ jps
5530 NamesrvStartup
6956 Jps

# 再次从RocketMQ Dashboard 查看集群，此时master为192.168.10.78
```

