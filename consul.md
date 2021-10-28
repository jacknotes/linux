#Consul
<pre>
Gossip和Raft算法：
参考：http://wuwenliang.net/2019/05/13/%E6%88%91%E8%AF%B4%E5%88%86%E5%B8%83%E5%BC%8F%E4%B9%8BGossip%E5%8D%8F%E8%AE%AE%E4%B8%8ERaft%E7%AE%97%E6%B3%95%E6%A6%82%E8%A7%88/
如果说分布式领域是一片蓝海，那各种分布式一致性算法就是其中闪耀的明珠。两个有趣且应用广泛的分布式一致性算法，Gossip协议与Raft算法。
#Gossip协议：
首先介绍一下Gossip协议，它的通俗解释如下：
Gossip protocol 也叫 Epidemic Protocol （流行病协议），它还有很多别名，如：“谣言算法”、“疫情传播算法”等。
这个协议的作用就像其名字表示的意思一样容易理解，它的运行方式在我们日常生活中也很常见，如疾病致病病菌的传播，森林大火扩散等。
Gossip协议的思想比较有趣，它的集群拓扑是去中心化的。每个节点均为运行着Gossip协议的Agent，包括服务器节点与普通节点，他们均加入了此Gossip集群并收发Gossip消息。
每经过一段固定的时间，每个节点都会随机选取几个与它保持连接的若干节点发送Gossip消息，与此同时，其他节点也会选择与自己保持连接的几个节点进行消息的传递。如此经过一点时间之后，整个集群都收到了这条Gossip消息，从而达到最终一致。
注意 每次消息传递都会选择 尚未发送过的节点 进行散播，即收到消息的节点不会再往发送的节点散播，eg:A->B, 则当B进行散播的时候，不会再发送给A。
这样做的好处是当集群中的节点总量增加，分摊到每个节点的压力基本是稳定的，在一致性时间窗的忍耐限度内，整个集群的规模可以达到数千节点。
Gossip已经落地的产品包括但不限于Consul、Cassandra。其中Consul主要使用Gossip做为集群成员管理及消息广播的主要手段。Consul的Agent之间通过Gossip协议进行状态检查，通过节点之间互ping而减轻了作为server的节点的压力。如果有节点down机，任意与其保持连接的节点发现即可通过Gossip广播给整个集群。当该down机的节点重启后重新加入集群，一段时间后，它的状态也能够通过Gossip协议与其他的节点达成一致，这体现出Gossip协议具有的天然的分布式容错的特点。
Gossip算法又被称为反熵（Anti-Entropy），表示在杂乱无章中寻求一致，这充分说明了Gossip的特点：在一个有界网络中，每个节点都随机地与其他节点通信，经过一番杂乱无章的通信，最终所有节点的状态都会达成一致。每个节点可能知道所有其他节点，也可能仅知道几个邻居节点，只要这些节可以通过网络连通，最终他们的状态都是一致的，当然这也是疫情传播的特点。

#Raft算法
Raft是一种共识算法，旨在替代Paxos。 它通过逻辑分离比Paxos更容易理解，但它也被正式证明是安全的，并提供了一些额外的功能。[1] Raft提供了一种在计算系统集群中分布状态机的通用方法，确保集群中的每个节点都同意一系列相同的状态转换。
Raft通过当选的领导者达成共识。筏集群中的服务器是领导者或追随者，并且在选举的精确情况下可以是候选者（领导者不可用）。领导者负责将日志复制到关注者。它通过发送心跳消息定期通知追随者它的存在。每个跟随者都有一个超时（通常在150到300毫秒之间），它期望领导者的心跳。接收心跳时重置超时。如果没有收到心跳，则关注者将其状态更改为候选人并开始领导选举。
##Raft算法的主要包含如下要点：
leader选取
日志复制
安全
#它们的职责描述如下：
概念： raft 集群中的每个节点都可以根据集群运行的情况在三种状态间切换：follower（从节点）, candidate（候选者节点） 与 leader（主节点）。
leader节点: leader节点向follower节点进行日志同步
follower节点: follower节点只能从leader节点获取日志。
Raft基本流程
1. 正常情况下，leader节点定时向follower节点发送heartbeat心跳包。
2. 由于某些异常情况发生，leader不再发送心跳包，或者因为网络超时，导致follower无法收到心跳包。此时，如果在一个时间周期（election timeout），follower没有收到来自leader的心跳包，则节点将会发起leader选举。
某个节点发生election timeout，节点的 raft 状态机将自己的状态变更为candidate（候选者），并向其余的follower发起投票。
3. 当该候选节点收到了集群中超过半数的节点的接受投票响应后，该候选节点成为leader节点，并开始接受并保存client的数据对外提供服务，并向其余的follower节点同步日志。它作为leader节点同时还会向其余的存活的follower节点发送heartbeat心跳包来保持其leader地位。
4. 当经过一点时间后，原先的leader重启并重新加入到集群中，此时需要比较两个leader的步进数，步进数低的那个leader将切换为follower节点（此处即为重启恢复的那个leader）
5. 此时leader节点已经变更，因此之前的那个leader节点（此时已经是follower）中的日志将会被清理，并作为follower接受当前leader的日志同步，从而保持一致。


#consul概念
Agent：是在 Consul 集群的每个成员上长期运行的守护进程，通过命令 consul agent 启动运行。由于所有节点都必须运行一个 Agent，因此 Agent 可以分为 client 或 Server。
       所有的 Agent 都可以运行DNS或HTTP接口，并负责运行监测和保持服务同步
Client：是将所有RPC转发到 Server 的 Agent。Client 是相对无状态的，Client 唯一执行的后台活动是加入 LAN gossip 池。这只有最小的资源开销，且只消耗少量的网络带宽
Server：是一个有一组扩展功能的 Agent，这些功能包括参与 Raft 选举、维护集群状态、响应RPC查询、与其他数据中心交互 WAN gossip 和转发查询给 leader 或远程的数据中心
Datacenter：是一个私有的、低延迟和高带宽的网络环境。这不包括通过公网的通信，但就目的而言，单个 EC2 中的多个可用区域被视为数据中心的一部分
Consensus：一致性。Consul 使用 Consensus 协议（具体由 Raft 算法实现）来提供一致性（由 CAP 定义），表明 leader 选举和事务的顺序达成一致
Gossip：Consul 使用 Gossip 协议来管理成员资格并向集群广播消息。Serf 提供了完整的 Gossip 协议，可用于多种目的，而 Consul 建立在 Serf 之上。
        Gossip 涉及节点到节点的随机通信，主要是通过UDP。Gossip 协议也被称为 Epidemic 协议（流行病协议）
LAN Gossip：指包含所有位于同一局域网或数据中心的节点的 LAN gossip 池
WAN Gossip：指仅包含 Server 的 WAN gossip 池。这些 Server 主要分布在不同的数据中心，通常通过Internet或者广域网进行通信
RPC：远程过程调用。一种 请求/响应 机制，允许 Client 向 Server 发起请求
#consul集群概念：
每个数据中心中都有 Client 和 Server。Server的数量建议是 3 或 5 台，这能平衡故障情况下的可用性和集群性能。Server 数量越多，达成一致性也会越慢，但是 Client 的数量没有限制。
其次，数据中心中的所有 Agent 都加入 gossip 协议，这意味着存在一个给定数据中心的所有 Agent 的 gossip 池。这样做有几个目的：
1. 不需要为 Client 配置 Server 地址，发现是自动完成的；
2. 检测 Agent 故障的工作不是放在 Server 上、而是分布式的，这使得故障检测更具可伸缩性；
3. 它被用作一个消息层，已通知何时发生重要事件（例如 leader 选举）
每个数据中心的 Server 都是单个 Raft 对等集的一部分，这意味着它们将共同选举出一个 leader，leader 负责处理所有查询和事务。作为 consensus 协议的一部分，事务必须复制到所有对等方。由于这一需求，当 非 leader Server 收到RPC请求时，它将转发给 leader Server。
Server 还作为 WAN gossip 池的一部分运行。WAN gossip 池与 LAN gossip 池不同，因为它针对Internet更高的延迟进行了优化，并且仅包含其他 Consul Server。WAN gossip 池的目的是允许数据中心以一种低接触的方式发现彼此，在线连接新的数据中心就像加入现有的 WAN gossip 池一样简单。由于 Server 都在 WAN gossip 池中运行，因此它还支持跨数据中心请求。Server 收到其他数据中心的请求时，会将其转发到正确的数据中心的随机 Server，然后该 Server 可以转发给本地的 leader。这就让数据中心之间的耦合非常低，由于故障检测、连接缓存和多路复用，跨数据中心的请求相对较快且可靠。
通常，不会在不同的 Consul 数据中心之间复制数据。当请求另一个数据中心的资源时，本地 Consul Server 将RPC请求转发到该资源的远程 Consul Server 并返回结果。如果远程数据中心不可用，那么这些资源也将不可用，但这不会影响本地数据中心。在某些特殊情况下，可以复制有限的数据子集，例如使用 Consul 内置的 ACL复制 功能，或使用诸如 consul-replicate 之类的外部工具。
#consul特点：
多数据中心: Consul 支持任意数量的数据中心，而不需要复杂的配置
服务网格/服务细分：Consul Connect通过自动TLS加密和基于身份的授权来实现安全的服务间通信。
                 应用程序可以在服务网格配置中使用sidecar代理来为入站和出站连接建立TLS连接，而根本不知道Connect
服务发现: Consul 使服务易于注册自己，并通过DNS或HTTP接口发现其他服务。诸如SaaS提供程序之类的外部服务也可以注册
运行状态检测: Consul 提供了健康检查的机制，与服务发现的集成可防止将流量路由到不正常的主机，并启用服务级别的断路器
Key/Value 存储: 灵活的kv存储可以实现动态配置、功能标记、leader选举等，简单的HTTP API使它可以在任何地方轻松使用
#consul端口：
Consul最多需要6个不同的端口才能正常工作，某些端口需要使用TCP、UDP或同时使用这两种协议。
DNS：DNS server（TCP和UDP）     8600
HTTP：HTTP API（仅TCP）         8500
HTTPS：HTTPs API        disabled(8501)*
gRPC：gRPC API          disabled(8502)*
LAN Serf：Serf LAN 端口（TCP和UDP）         8301
Wan Serf：Serf WAN 端口（TCP和UDP）         8302
server：server RPC 地址（仅TCP）            8300
Sidecar Proxy Min：包含的最小端口号，用于自动分配的sidecar服务注册      21000
Sidecar Proxy Max：包含的最大端口号，用于自动分配的sidecar服务注册      21255
注：对于HTTPS和gRPC，上面指定的端口为推荐值。

#consul架构图
![Aaron Swartz](https://raw.githubusercontent.com/jacknotes/linux/master/image/consul-cluster.png)


#环境准备
主机说明：
Ubuntu 18.04.5 LTS   192.168.13.31	server
Ubuntu 18.04.5 LTS   192.168.13.32	server
Ubuntu 18.04.5 LTS   192.168.13.33	server
Ubuntu 18.04.5 LTS   192.168.13.34	client
Ubuntu 20.04.2 LTS   172.168.2.224	client

--节点192.168.13.31
1. Consul安装
[root@ceph01 ~]# cd /usr/local/src/
[root@ceph01 /usr/local/src]# curl -OL https://releases.hashicorp.com/consul/1.10.3/consul_1.10.3_linux_amd64.zip
#[root@ceph01 /usr/local/src]# axel -n 30 https://releases.hashicorp.com/consul/1.8.3/consul_1.8.3_linux_amd64.zip
[root@ceph01 /usr/local/src]# for i in 32 33 34;do scp consul_1.10.3_linux_amd64.zip root@192.168.13.$i:/usr/local/src;done
[root@ceph01 /usr/local/src]# unzip consul_1.10.3_linux_amd64.zip
[root@ceph01 /usr/local/src]# mkdir -p /usr/local/consul/{bin,log,conf,data}
[root@ceph01 /usr/local/src]# mv consul /usr/local/consul/bin/
2. 配置环境变量
[root@ceph01 /usr/local/src]# echo 'export CONSUL_HOME=/usr/local/consul' | sudo tee /etc/profile.d/consul.sh
[root@ceph01 /usr/local/src]# echo 'export PATH=${PATH}:${CONSUL_HOME}/bin' | sudo tee -a /etc/profile.d/consul.sh
[root@ceph01 /usr/local/src]# cat /etc/profile.d/consul.sh
export CONSUL_HOME=/usr/local/consul
export PATH=${PATH}:${CONSUL_HOME}/bin
[root@ceph01 /usr/local/src]# source /etc/profile.d/consul.sh 
[root@ceph01 /usr/local/src]# echo $PATH 
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/bin:/usr/local/consul/bin
[root@ceph01 /usr/local/src]# consul version
Consul v1.10.3
Revision c976ffd2d
Protocol 2 spoken by default, understands 2 to 3 (agent will automatically use protocol >2 when speaking to compatible agents)

--节点192.168.13.32
1. Consul安装
[root@ceph02 ~]# cd /usr/local/src/
[root@ceph02 /usr/local/src]# unzip consul_1.10.3_linux_amd64.zip                 
[root@ceph02 /usr/local/src]# mkdir -p /usr/local/consul/{bin,log,conf,data}
[root@ceph02 /usr/local/src]# mv consul /usr/local/consul/bin/
2. 配置环境变量
[root@ceph02 /usr/local/src]# echo 'export CONSUL_HOME=/usr/local/consul' | sudo tee /etc/profile.d/consul.sh
[root@ceph02 /usr/local/src]# echo 'export PATH=${PATH}:${CONSUL_HOME}/bin' | sudo tee -a /etc/profile.d/consul.sh
[root@ceph02 /usr/local/src]# cat /etc/profile.d/consul.sh
export CONSUL_HOME=/usr/local/consul
export PATH=${PATH}:${CONSUL_HOME}/bin
[root@ceph02 /usr/local/src]# source /etc/profile.d/consul.sh 
[root@ceph02 /usr/local/src]# echo $PATH 
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/local/consul/bin
[root@ceph02 /usr/local/src]# consul version
Consul v1.10.3
Revision c976ffd2d
Protocol 2 spoken by default, understands 2 to 3 (agent will automatically use protocol >2 when speaking to compatible agents)

--节点192.168.13.33
1. Consul安装
[root@ceph03 ~]# cd /usr/local/src/
[root@ceph03 /usr/local/src]# unzip consul_1.10.3_linux_amd64.zip
[root@ceph03 /usr/local/src]# mkdir -p /usr/local/consul/{bin,log,conf,data}
[root@ceph03 /usr/local/src]# mv consul /usr/local/consul/bin/
2. 配置环境变量
[root@ceph03 /usr/local/src]# echo 'export CONSUL_HOME=/usr/local/consul' | sudo tee /etc/profile.d/consul.sh
[root@ceph03 /usr/local/src]# echo 'export PATH=${PATH}:${CONSUL_HOME}/bin' | sudo tee -a /etc/profile.d/consul.sh
[root@ceph03 /usr/local/src]# cat /etc/profile.d/consul.sh
export CONSUL_HOME=/usr/local/consul
export PATH=${PATH}:${CONSUL_HOME}/bin
[root@ceph03 /usr/local/src]# source /etc/profile.d/consul.sh 
[root@ceph03 /usr/local/src]# echo $PATH 
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/bin:/usr/local/consul/bin
[root@ceph03 /usr/local/src]# consul version
Consul v1.10.3
Revision c976ffd2d
Protocol 2 spoken by default, understands 2 to 3 (agent will automatically use protocol >2 when speaking to compatible agents)

--节点192.168.13.34和172.168.2.224同样安装
1. Consul安装
[root@ceph04 ~]# cd /usr/local/src/
[root@ceph04 /usr/local/src]# unzip consul_1.10.3_linux_amd64.zip
[root@ceph04 /usr/local/src]# mkdir -p /usr/local/consul/{bin,log,conf,data}
[root@ceph04 /usr/local/src]# mv consul /usr/local/consul/bin/
2. 配置环境变量
[root@ceph04 /usr/local/src]# echo 'export CONSUL_HOME=/usr/local/consul' | sudo tee /etc/profile.d/consul.sh
[root@ceph04 /usr/local/src]# echo 'export PATH=${PATH}:${CONSUL_HOME}/bin' | sudo tee -a /etc/profile.d/consul.sh
[root@ceph04 /usr/local/src]# cat /etc/profile.d/consul.sh
export CONSUL_HOME=/usr/local/consul
export PATH=${PATH}:${CONSUL_HOME}/bin
[root@ceph04 /usr/local/src]# source /etc/profile.d/consul.sh 
[root@ceph04 /usr/local/src]# echo $PATH 
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/bin:/usr/local/consul/bin
[root@ceph04 /usr/local/src]# consul version
Consul v1.10.3
Revision c976ffd2d
Protocol 2 spoken by default, understands 2 to 3 (agent will automatically use protocol >2 when speaking to compatible agents)

#在开发模式运行
[root@ceph01 /usr/local/src]# consul agent -dev 
[root@ceph04 /usr/local/consul/bin]# consul -autocomplete-install  #开启命令补全
Error executing CLI: 1 error occurred:
	* already installed in /root/.bashrc

--新开一个窗口：
[root@ceph01 ~]# netstat -tunlp | grep consul
tcp        0      0 127.0.0.1:8300          0.0.0.0:*               LISTEN      5566/consul         
tcp        0      0 127.0.0.1:8301          0.0.0.0:*               LISTEN      5566/consul         
tcp        0      0 127.0.0.1:8302          0.0.0.0:*               LISTEN      5566/consul         
tcp        0      0 127.0.0.1:8500          0.0.0.0:*               LISTEN      5566/consul         
tcp        0      0 127.0.0.1:8502          0.0.0.0:*               LISTEN      5566/consul         
tcp        0      0 127.0.0.1:8600          0.0.0.0:*               LISTEN      5566/consul         
udp        0      0 127.0.0.1:8301          0.0.0.0:*                           5566/consul         
udp        0      0 127.0.0.1:8302          0.0.0.0:*                           5566/consul         
udp        0      0 127.0.0.1:8600          0.0.0.0:*                           5566/consul 
[root@ceph01 ~]# consul members
Node    Address         Status  Type    Build   Protocol  DC   Segment
ceph01  127.0.0.1:8301  alive   server  1.10.3  2         dc1  <all>
[root@ceph01 ~]# consul members -detailed
Node    Address         Status  Tags
ceph01  127.0.0.1:8301  alive   acls=0,build=1.10.3:c976ffd2,dc=dc1,ft_fs=1,ft_si=1,id=a58b5306-058b-9267-2a5f-06535b2c9d85,port=8300,raft_vsn=3,role=consul,segment=<all>,vsn=2,vsn_max=3,vsn_min=2,wan_join_port=8302
--分别使用HTTP和DNS接口查看信息：
[root@ceph01 ~]# curl localhost:8500/v1/catalog/nodes
[
    {
        "ID": "a58b5306-058b-9267-2a5f-06535b2c9d85",
        "Node": "ceph01",
        "Address": "127.0.0.1",
        "Datacenter": "dc1",
        "TaggedAddresses": {
            "lan": "127.0.0.1",
            "lan_ipv4": "127.0.0.1",
            "wan": "127.0.0.1",
            "wan_ipv4": "127.0.0.1"
        },
        "Meta": {
            "consul-network-segment": ""
        },
        "CreateIndex": 11,
        "ModifyIndex": 12
    }
]
[root@ceph01 ~]# dig @127.0.0.1 -p 8600 ceph01.node.consul  #dns
;; QUESTION SECTION:
;ceph01.node.consul.		IN	A
;; ANSWER SECTION:
ceph01.node.consul.	0	IN	A	127.0.0.1
--停止Agent：
[root@ceph01 ~]# consul leave -http-addr=127.0.0.1:8500   --正常退出
Graceful leave complete
[root@ceph01 ~]# consul force-leave -http-addr=127.0.0.1:8500 ceph01  --强制退出
--注册服务：
[root@ceph01 /usr/local/src]# echo '{"service": {"name": "nginx", "tags": ["web"], "port": 80}}' | jq .
{
  "service": {
    "name": "nginx",
    "tags": [
      "web"
    ],
    "port": 80
  }
}
[root@ceph01 /usr/local/consul/conf]# echo '{"service": {"name": "nginx", "tags": ["web"], "port": 80}}' | sudo tee ./nginx.json
[root@ceph01 /usr/local/consul/conf]# consul agent -dev -config-dir=/usr/local/consul/conf/nginx.json
通过HTTP API和DNS接口查看：
[root@ceph01 /usr/local/src]# curl http://localhost:8500/v1/catalog/service/nginx
[
    {
        "ID": "520a6c84-ccec-2e9e-4e3d-8f770993e394",
        "Node": "ceph01",
        "Address": "127.0.0.1",
        "Datacenter": "dc1",
        "TaggedAddresses": {
            "lan": "127.0.0.1",
            "lan_ipv4": "127.0.0.1",
            "wan": "127.0.0.1",
            "wan_ipv4": "127.0.0.1"
        },
        "NodeMeta": {
            "consul-network-segment": ""
        },
        "ServiceKind": "",
        "ServiceID": "nginx",
        "ServiceName": "nginx",
        "ServiceTags": [
            "web"
        ],
        "ServiceAddress": "",
        "ServiceWeights": {
            "Passing": 1,
            "Warning": 1
        },
        "ServiceMeta": {},
        "ServicePort": 80,
        "ServiceSocketPath": "",
        "ServiceEnableTagOverride": false,
        "ServiceProxy": {
            "Mode": "",
            "MeshGateway": {},
            "Expose": {}
        },
        "ServiceConnect": {},
        "CreateIndex": 13,
        "ModifyIndex": 13
    }
]
[root@ceph01 /usr/local/src]# dig @127.0.0.1 -p 8600 nginx.service.consul  --DNS接口查看
; <<>> DiG 9.11.3-1ubuntu1.12-Ubuntu <<>> @127.0.0.1 -p 8600 nginx.service.consul
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 6408
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;nginx.service.consul.		IN	A

;; ANSWER SECTION:
nginx.service.consul.	0	IN	A	127.0.0.1

;; Query time: 1 msec
;; SERVER: 127.0.0.1#8600(127.0.0.1)
;; WHEN: Wed Oct 27 14:56:24 CST 2021
;; MSG SIZE  rcvd: 65
[root@ceph01 /usr/local/src]# consul leave -http-addr=127.0.0.1:8500   #停止agent



#Consul集群模式运行
##创建 consul server：
--节点：192.168.13.31:
consul agent -server -bootstrap-expect=3  \
    -data-dir=/usr/local/consul/data \
    -node=agent31 -bind=192.168.13.31 \
    -enable-script-checks=true -config-dir=/usr/local/consul/conf \
    -client 0.0.0.0 -ui >/usr/local/consul/log/consul.log 2>&1 &

--节点：192.168.13.32:
consul agent -server -bootstrap-expect=3  \
    -data-dir=/usr/local/consul/data \
    -node=agent32 -bind=192.168.13.32 \
    -enable-script-checks=true -config-dir=/usr/local/consul/conf \
    -client 0.0.0.0 -ui >/usr/local/consul/log/consul.log 2>&1 &

--节点：192.168.13.33:
consul agent -server -bootstrap-expect=3  \
    -data-dir=/usr/local/consul/data \
    -node=agent33 -bind=192.168.13.33 \
    -enable-script-checks=true -config-dir=/usr/local/consul/conf \
    -client 0.0.0.0 -ui >/usr/local/consul/log/consul.log 2>&1 &


-node：节点的名称 
-bind：绑定的一个地址，用于节点之间通信的地址，可以是内外网，必须是可以访问到的地址 
-server：表示这个节点是个Server
-bootstrap-expect：表示期望提供的Server节点数目。数目一达到，它就会被激活，然后就是leader了
-data-dir：Agent用于存储状态的数据目录，这是所有Agent所必需的
-datacenter：指明数据中心的名字，默认是"dc1"。同一数据中心中的节点应位于单个LAN上
-client：将Client接口（包括HTTP和DNS服务器）绑定到的地址
-ui：启动UI

##创建 consul client：
--节点：192.168.13.34:
consul agent -data-dir=/usr/local/consul/data \
    -node=agent34 -bind=192.168.13.34 \
    -enable-script-checks=true -config-dir=/usr/local/consul/conf \
    -client 0.0.0.0 -ui >/usr/local/consul/log/consul.log 2>&1 &

--节点：172.168.2.224
consul agent -data-dir=/usr/local/consul/data \
    -node=agent224 -bind=172.168.2.224 \
    -enable-script-checks=true -config-dir=/usr/local/consul/conf \
    -client 0.0.0.0 -ui >/usr/local/consul/log/consul.log 2>&1 &

##加入集群：
--192.168.13.33加入192.168.13.31
[root@ceph03 ~]# consul join 192.168.13.31:8301
Successfully joined cluster by contacting 1 nodes.
[root@ceph03 ~]# consul members
Node     Address             Status  Type    Build  Protocol  DC   Segment
agent31  192.168.13.31:8301  alive   server  1.8.3  2         dc1  <all>
agent33  192.168.13.33:8301  alive   server  1.8.3  2         dc1  <all>

--192.168.13.32加入192.168.13.33
[root@ceph02 /usr/local/consul]# consul join 192.168.13.33:8301
Successfully joined cluster by contacting 1 nodes.
[root@ceph02 /usr/local/consul]# consul members
Node     Address             Status  Type    Build  Protocol  DC   Segment
agent31  192.168.13.31:8301  alive   server  1.8.3  2         dc1  <all>
agent32  192.168.13.32:8301  alive   server  1.8.3  2         dc1  <all>
agent33  192.168.13.33:8301  alive   server  1.8.3  2         dc1  <all>

--192.168.13.34和172.168.2.224客户端加入服务端 
[root@ceph04 /usr/local/consul]# consul join 192.168.13.31:8301
[root@ubuntu /usr/local]#consul join 192.168.13.34
Successfully joined cluster by contacting 1 nodes.
[root@ubuntu /usr/local]#consul members
Node      Address             Status  Type    Build  Protocol  DC   Segment
agent31   192.168.13.31:8301  alive   server  1.8.3  2         dc1  <all>
agent32   192.168.13.32:8301  alive   server  1.8.3  2         dc1  <all>
agent33   192.168.13.33:8301  alive   server  1.8.3  2         dc1  <all>
agent224  172.168.2.224:8301  alive   client  1.8.3  2         dc1  <default>
agent34   192.168.13.34:8301  alive   client  1.8.3  2         dc1  <default>


--查看consul信息
[root@ceph02 /usr/local/consul]# consul info 
agent:
	check_monitors = 0
	check_ttls = 0
	checks = 0
	services = 1
build:
	prerelease = 
	revision = a9322b9c
	version = 1.8.3
consul:
	acl = disabled
	bootstrap = false
	known_datacenters = 1
	leader = false
	leader_addr = 192.168.13.31:8300
	server = true
raft:
	applied_index = 316
	commit_index = 316
	fsm_pending = 0
	last_contact = 18.384233ms
	last_log_index = 316
	last_log_term = 2
	last_snapshot_index = 0
	last_snapshot_term = 0
	latest_configuration = [{Suffrage:Voter ID:62d45a3d-1985-bde8-e3fa-bdb8633ffe6a Address:192.168.13.32:8300} {Suffrage:Voter ID:596a53f1-3397-545d-8857-68eeb1372837 Address:192.168.13.31:8300} {Suffrage:Voter ID:5ad2e9d6-7bb0-5607-e0d7-612ba0196160 Address:192.168.13.33:8300}]
	latest_configuration_index = 0
	num_peers = 2
	protocol_version = 3
	protocol_version_max = 3
	protocol_version_min = 0
	snapshot_version_max = 1
	snapshot_version_min = 0
	state = Follower
	term = 2
runtime:
	arch = amd64
	cpu_count = 4
	goroutines = 100
	max_procs = 4
	os = linux
	version = go1.14.7
serf_lan:
	coordinate_resets = 0
	encrypted = false
	event_queue = 0
	event_time = 2
	failed = 0
	health_score = 0
	intent_queue = 0
	left = 0
	member_time = 5
	members = 5
	query_queue = 0
	query_time = 1
serf_wan:
	coordinate_resets = 0
	encrypted = false
	event_queue = 0
	event_time = 1
	failed = 0
	health_score = 0
	intent_queue = 0
	left = 0
	member_time = 4
	members = 3
	query_queue = 0
	query_time = 1

--server和client监听的端口 
[root@ceph03 ~]# netstat -tunlp | grep consul
tcp        0      0 192.168.13.33:8300      0.0.0.0:*               LISTEN      19222/consul        
tcp        0      0 192.168.13.33:8301      0.0.0.0:*               LISTEN      19222/consul        
tcp        0      0 192.168.13.33:8302      0.0.0.0:*               LISTEN      19222/consul        
tcp6       0      0 :::8500                 :::*                    LISTEN      19222/consul        
tcp6       0      0 :::8600                 :::*                    LISTEN      19222/consul        
udp        0      0 192.168.13.33:8301      0.0.0.0:*                           19222/consul        
udp        0      0 192.168.13.33:8302      0.0.0.0:*                           19222/consul        
udp6       0      0 :::8600                 :::*                                19222/consul        
[root@ceph04 /usr/local/consul]# netstat -tnulp | grep consul
tcp        0      0 192.168.13.34:8301      0.0.0.0:*               LISTEN      22832/consul        
tcp6       0      0 :::8500                 :::*                    LISTEN      22832/consul        
tcp6       0      0 :::8600                 :::*                    LISTEN      22832/consul        
udp        0      0 192.168.13.34:8301      0.0.0.0:*                           22832/consul        
udp6       0      0 :::8600                 :::*                                22832/consul    






»问：是否删除了失败或遗留的节点？
为了防止死节点（处于失败或离开 状态的节点）的积累，Consul 会自动将死节点从目录中删除。这个过程称为收割。这是目前在 72 小时的可配置间隔内完成的。Reaping 类似于离开，导致所有相关服务被注销。不建议出于美学原因更改收割间隔以减少失败或左节点的数量（处于失败或左状态的节点不会对 Consul 造成任何额外负担



#配置Consul优雅启动与重启
[jack@ubuntu:~]$ sudo salt 'ceph*' cmd.run 'sudo groupadd -r consul'
[jack@ubuntu:~]$ sudo salt 'ceph*' cmd.run 'sudo useradd -M -r -g consul -s /sbin/nologin consul'
[root@ceph04 /usr/local/consul/conf]# chown -R consul:consul /usr/local/consul/



</pre>






#consul命令行
[root@ceph01 ~]# consul monitor -log-level=trace -log-json   --监控日志信息


