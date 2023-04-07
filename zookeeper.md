

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
![ACL访问控制流程图](.\image\zookeeper\zookeeper01.png)



**zookeeper ACL的特性**

```
zookeeper的权限控制是基于zookeeper node节点的，需要对每个节点设置权限。
每个zookeeper node支持设置多种权限控制方案和多个权限。
子节点不会继承父节点的权限。客户端无法访问某个节点，但是可以访问他的子节点。
```
![ACL规则命令](.\image\zookeeper\zookeeper02.png)



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