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

#consul流程
首先需要有一个正常的Consul集群，有Server，有Leader。这里在服务器Server1、Server2、Server3上分别部署了Consul Server。（这些服务器上最好只部署Consul程序，以尽量维护Consul Server的稳定）
服务器Server4和Server5上通过Consul Client分别注册Service A、B、C，这里每个Service分别部署在了两个服务器上，这样可以避免Service的单点问题。（一般微服务和Client绑定）
在服务器Server6中Program D需要访问Service B，这时候Program D首先访问本机Consul Client提供的HTTP API，本机Client会将请求转发到Consul Server，Consul Server查询到Service B当前的信息返回

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
为了防止死节点（处于失败或离开 状态的节点）的积累，Consul 会自动将死节点从目录中删除。这个过程称为收割。这是目前在 72 小时的可配置间隔内完成的。Reaping 类似于离开，导致所有相关服务被注销。
不建议出于美学原因更改收割间隔以减少失败或左节点的数量（处于失败或左状态的节点不会对 Consul 造成任何额外负担



#配置Consul优雅启动与重启
[jack@ubuntu:~]$ sudo salt 'ceph*' cmd.run 'sudo groupadd -r consul'
[jack@ubuntu:~]$ sudo salt 'ceph*' cmd.run 'sudo useradd -M -r -g consul -s /sbin/nologin consul'
[root@ceph04 /usr/local/consul/conf]# chown -R consul:consul /usr/local/consul/



</pre>






#consul命令行
#获取监控日志信息
[root@ceph01 ~]# consul monitor -log-level=trace -log-json   
#查找consul集群server的信息
[root@ceph01 /usr/local/consul]# consul operator raft list-peers 
Node     ID                                    Address             State     Voter  RaftProtocol
agent33  5ad2e9d6-7bb0-5607-e0d7-612ba0196160  192.168.13.33:8300  follower  true   3
agent32  62d45a3d-1985-bde8-e3fa-bdb8633ffe6a  192.168.13.32:8300  follower  true   3
agent31  596a53f1-3397-545d-8857-68eeb1372837  192.168.13.31:8300  leader    true   3
#consul创建kv
[root@ceph03 /usr/local/consul]# consul kv put name jack
Success! Data written to: name
[root@ceph03 /usr/local/consul]# consul kv get name
jack
#创建您的第一个备份，在我们的一台服务器上运行基本快照命令，使用所有默认设置，包括consistent模式，备份将本地保存在我们运行命令的目录中。
[root@ceph03 /usr/local/consul]# consul snapshot save backup01.snap
Saved and verified snapshot to index 1477
#可以使用inspect子命令查看有关备份的元数据。
[root@ceph03 /usr/local/consul]# consul snapshot inspect backup01.snap
ID           2-1477-1635410758989
Size         9615
Index        1477
Term         2
Version      1
------------
检查快照时会显示以下字段：
ID - 快照的唯一 ID，仅用于区分目的。
Size - 快照的大小，以字节为单位。
Index - 快照中最新日志条目的 Raft 索引。
Term - 快照中最新日志条目的 Raft term。
Version- 快照格式版本。这仅指快照的结构，而不是其中包含的数据。
读取快照中的每种数据类型、大小和计数。
------------
#通过指定陈旧模式从非领导者那里收集数据中心数据
[root@ceph03 /usr/local/consul]# consul snapshot save -stale backup02.snap
Saved and verified snapshot to index 1510
注：在操作上，备份过程不需要在每台服务器上执行。

#从备份恢复
运行该restore过程应该很简单。但是，您可以采取一些措施来确保流程顺利进行。首先，确保您要恢复的数据中心稳定并且有领导者。您可以使用consul operator raft list-peers和检查服务器日志和遥测数据来查看领导者选举或网络问题的迹象。
您只需要在领导者上运行该过程一次。Raft 共识协议确保所有服务器恢复相同的状态。或者在任一server上执行
--恢复kv值数据 
[root@ceph02 /usr/local/consul]# consul snapshot restore backup01.snap
Restored snapshot
--恢复注册的服务
[root@ceph02 /usr/local/consul]# consul snapshot restore backup02.snap
Restored snapshot



#Consul 常见问题
（1）节点和服务注销#
当服务或者节点失效，Consul不会对注册的信息进行剔除处理，仅仅标记已状态进行标记（并且不可使用）。如果担心失效节点和失效服务过多影响监控。可以通过调用HTTP API的形式进行处理节点和服务的注销可以使用HTTP API:
　　注销任意节点和服务：/catalog/deregister
　　注销当前节点的服务：/agent/service/deregister/:service_id
如果某个节点不继续使用了，也可以在本机使用consul leave命令，或者在其它节点使用consul force-leave 节点Id。
（2）健康检查与故障转移#
在集群环境下，健康检查是由服务注册到的Agent来处理的，那么如果这个Agent挂掉了，那么此节点的健康检查就处于无人管理的状态。 
从实际应用看，节点上的服务可能既要被发现，又要发现别的服务，如果节点挂掉了，仅提供被发现的功能实际上服务还是不可用的。当然发现别的服务也可以不使用本机节点，可以通过访问一个Nginx实现的若干Consul节点的负载均衡来实现。


------
有两种不同的系统需要单独配置以加密数据中心内的通信：八卦加密和 TLS。TLS 用于保护代理之间的 RPC 调用。八卦通信使用对称密钥进行保护，因为代理之间的八卦是通过 UDP 完成的。在本教程中，您将只配置八卦加密
要启用八卦加密，您需要在启动 Consul 代理时使用加密密钥。可以使用encrypt代理配置文件中的参数设置密钥。或者，加密密钥可以放在一个单独的配置文件中，只有该encrypt字段，因为代理可以合并多个配置文件。密钥必须是 32 字节，Base64 编码。
#您可以使用 Consul CLI 命令consul keygen生成适合加密的密钥
 consul keygen
#在新的 Consul 数据中心启用
要在新数据中心启用 gossip，您需要将加密密钥参数添加到代理配置文件中，然后在启动时使用-config-dir标志传递该文件。
注意：同一数据中心内的所有节点必须共享相同的加密密钥才能发送和接收数据中心信息，包括客户端和服务器。此外，如果您使用多个加入 WAN 的数据中心，请确保在所有数据中心使用相同的加密密钥。



####配置文件方式启动集群
#TLS
#创建证书
[root@ceph01 ~/consul/new/cert]# consul tls ca create
==> Saved consul-agent-ca.pem
==> Saved consul-agent-ca-key.pem
#接下来创建一组证书，每个 Consul 代理一个。您现在需要为您的主数据中心选择一个名称，以便正确命名证书。首先，对于您的 Consul 服务器，使用以下命令为每个服务器创建一个证书。文件名自动增加。
[root@ceph01 ~/consul/new/cert]# consul tls cert create -server -dc homsom
==> WARNING: Server Certificates grants authority to become a
    server and access all state in the cluster including root keys
    and all ACL tokens. Do not distribute them to production hosts
    that are not server nodes. Store them as securely as CA keys.
==> Using consul-agent-ca.pem and consul-agent-ca-key.pem
==> Saved homsom-server-consul-0.pem
==> Saved homsom-server-consul-0-key.pem
[root@ceph01 ~/consul/new/cert]# consul tls cert create -server -dc homsom
==> WARNING: Server Certificates grants authority to become a
    server and access all state in the cluster including root keys
    and all ACL tokens. Do not distribute them to production hosts
    that are not server nodes. Store them as securely as CA keys.
==> Using consul-agent-ca.pem and consul-agent-ca-key.pem
==> Saved homsom-server-consul-1.pem
==> Saved homsom-server-consul-1-key.pem
[root@ceph01 ~/consul/new/cert]# consul tls cert create -server -dc homsom
==> WARNING: Server Certificates grants authority to become a
    server and access all state in the cluster including root keys
    and all ACL tokens. Do not distribute them to production hosts
    that are not server nodes. Store them as securely as CA keys.
==> Using consul-agent-ca.pem and consul-agent-ca-key.pem
==> Saved homsom-server-consul-2.pem
==> Saved homsom-server-consul-2-key.pem

#使用带有-client标志的以下命令来创建客户端证书,文件名自动增加。
[root@ceph01 ~/consul/new/cert]# consul tls cert create -client -dc homsom
==> Using consul-agent-ca.pem and consul-agent-ca-key.pem
==> Saved homsom-client-consul-0.pem
==> Saved homsom-client-consul-0-key.pem
[root@ceph01 ~/consul/new/cert]# consul tls cert create -client -dc homsom
==> Using consul-agent-ca.pem and consul-agent-ca-key.pem
==> Saved homsom-client-consul-1.pem
==> Saved homsom-client-consul-1-key.pem

#将证书分发给代理
您必须将 CA 证书分发consul-agent-ca.pem给每个 Consul 代理以及代理特定的证书和私钥。
[jack@ubuntu:/usr/local/consul]$ sudo salt '*' cmd.run 'sudo mkdir -p /etc/consul.d'
--分发给服务端agent
[root@ceph01 ~/consul/new/cert]# scp consul-agent-ca.pem homsom-server-consul-0* root@192.168.13.31:/etc/consul.d/
[root@ceph01 ~/consul/new/cert]# scp consul-agent-ca.pem homsom-server-consul-1* root@192.168.13.32:/etc/consul.d/
[root@ceph01 ~/consul/new/cert]# scp consul-agent-ca.pem homsom-server-consul-2* root@192.168.13.33:/etc/consul.d/
--分发给客户端agent
[root@ceph01 ~/consul/new/cert]# scp consul-agent-ca.pem homsom-client-consul-0* root@192.168.13.34:/etc/consul.d/
[root@ceph01 ~/consul/new/cert]# scp consul-agent-ca.pem homsom-client-consul-1* root@172.168.2.224:/etc/consul.d/

#启用 Consul ACL
Consul 使用访问控制列表 (ACL) 来保护 UI、API、CLI 和 Consul 目录，包括服务和代理注册。在保护数据中心时，您应该首先配置 ACL。
将 ACL 配置添加到consul.hcl或者consul.json配置文件并选择默认策略“允许”（除非明确拒绝，否则允许所有流量）或“拒绝”（除非明确允许，否则拒绝所有流量）。
 "acl": {
  "enabled": true,
  "default_policy": "allow",
  "enable_token_persistence": true
 }



#审计--暂时未启用
"audit": {
  "enabled: true,
  "sink 'My sink'" {
    "type": "file",
    "format": "json",
    "path": "data/audit/audit.json",
    "delivery_guarantee": "best-effort",
    "rotate_duration": "24h",
    "rotate_max_files": 15,
    "rotate_bytes": 25165824
  }
}


#添加到systemd服务
[root@ceph01 ~/consul/new]# cat /lib/systemd/system/consul.service
----------
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/usr/local/consul/conf/consul.json

[Service]
Type=notify
User=consul
Group=consul
ExecStart=/usr/local/consul/bin/consul agent -config-dir=/usr/local/consul/conf/
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
----------

#配置目录权限
[jack@ubuntu:/usr/local/consul]$ sudo salt '*' cmd.run 'id consul'
ubuntu:
    uid=996(consul) gid=996(consul) groups=996(consul)
ceph03.hs.com:
    uid=999(consul) gid=998(consul) groups=998(consul)
ceph02.hs.com:
    uid=999(consul) gid=998(consul) groups=998(consul)
ceph04.hs.com:
    uid=999(consul) gid=998(consul) groups=998(consul)
ceph01.hs.com:
    uid=998(consul) gid=997(consul) groups=997(consul)
[jack@ubuntu:/usr/local/consul]$ sudo salt '*' cmd.run 'sudo chown -R consul.consul /etc/consul.d /usr/local/consul'

#启动节点192.168.13.31-server-agent
[root@ceph01 ~/consul/new]# ls /etc/consul.d/
consul-agent-ca.pem  homsom-server-consul-0-key.pem  homsom-server-consul-0.pem
[root@ceph01 ~/consul/new]# ls /usr/local/consul/conf/
consul.json
[root@ceph01 ~/consul/new]# cat /usr/local/consul/conf/consul.json 
---------
{
 "node_name": "agent31",
 "server": true,
 "datacenter": "homsom",
 "data_dir": "/usr/local/consul/data",
 "log_level": "INFO",
 "retry_join": [ 
  "192.168.13.31",
  "192.168.13.32",
  "192.168.13.33"
 ],
 "bind_addr": "192.168.13.31",      
 "client_addr": "192.168.13.31",  
 "encrypt": "BuIYviAYi+BbNkOJxZ4YW4xogpF1eFkeZzXgQCA0GFw=",
 "log_file": "/usr/local/consul/log/consul.log",    
 "log_json": true,
 "log_rotate_duration": "24h",   
 "pid_file": "/usr/local/consul/log/consul.pid",    
 "enable_syslog": false,       
 "enable_debug": true,
 "ui": true,
 "performance": {
  "raft_multiplier": 1
 },
 "bootstrap_expect": 3, 
 "leave_on_terminate": false,
 "skip_leave_on_interrupt": true,
 "rejoin_after_leave": true,
 "ca_file": "/etc/consul.d/consul-agent-ca.pem",
 "cert_file": "/etc/consul.d/homsom-server-consul-0.pem",
 "key_file": "/etc/consul.d/homsom-server-consul-0-key.pem",
 "verify_incoming": true,
 "verify_outgoing": true,
 "verify_server_hostname": true,
 "acl": {
  "enabled": true,
  "default_policy": "allow",
  "enable_token_persistence": true
 }
}
---------
#测试配置文件
[root@ceph01 ~/consul/new]# consul validate /usr/local/consul/conf/consul.json
bootstrap_expect > 0: expecting 3 servers
Configuration is valid!
#启动服务
[root@ceph01 ~/consul/new]# systemctl start consul
[root@ceph01 ~/consul/new]# systemctl status consul
[root@ceph01 ~/consul/new]# systemctl enable consul
[root@ceph01 ~/consul/new]# netstat -tunlp | grep consul
tcp        0      0 192.168.13.31:8300      0.0.0.0:*               LISTEN      13487/consul        
tcp        0      0 192.168.13.31:8301      0.0.0.0:*               LISTEN      13487/consul        
tcp        0      0 192.168.13.31:8302      0.0.0.0:*               LISTEN      13487/consul        
tcp        0      0 192.168.13.31:8500      0.0.0.0:*               LISTEN      13487/consul        
tcp        0      0 192.168.13.31:8600      0.0.0.0:*               LISTEN      13487/consul        
udp        0      0 192.168.13.31:8301      0.0.0.0:*                           13487/consul        
udp        0      0 192.168.13.31:8302      0.0.0.0:*                           13487/consul        
udp        0      0 192.168.13.31:8600      0.0.0.0:*                           13487/consul 




#复制配置文件到各节点
[root@ceph01 ~/consul/new]# scp consul-server32.json /lib/systemd/system/consul.service root@192.168.13.32:/usr/local/consul/conf
[root@ceph01 ~/consul/new]# scp consul-server33.json /lib/systemd/system/consul.service root@192.168.13.33:/usr/local/consul/conf
[root@ceph01 ~/consul/new]# scp consul-client34.json /lib/systemd/system/consul.service root@192.168.13.34:/usr/local/consul/conf   
[root@ceph01 ~/consul/new]# scp consul-client224.json /lib/systemd/system/consul.service root@172.168.2.224:/usr/local/consul/conf


#启动节点192.168.13.32-server-agent
[root@ceph02 /usr/local/consul]# ls conf/
consul-server32.json  consul.service
[root@ceph02 /usr/local/consul]# mv conf/consul.service /lib/systemd/system/   
[root@ceph02 /usr/local/consul]# mv conf/consul-server32.json conf/consul.json
[root@ceph02 /usr/local/consul]# consul validate /usr/local/consul/conf/consul.json
bootstrap_expect > 0: expecting 3 servers
Configuration is valid!
[root@ceph02 /usr/local/consul]# ls /etc/consul.d/
consul-agent-ca.pem  homsom-server-consul-1-key.pem  homsom-server-consul-1.pem
[root@ceph02 /usr/local/consul]# ls /usr/local/consul/conf/            
consul.json
[root@ceph02 /usr/local/consul]# cat conf/consul.json 
---------
{
 "node_name": "agent32",
 "server": true,
 "datacenter": "homsom",
 "data_dir": "/usr/local/consul/data",
 "log_level": "INFO",
 "retry_join": [ 
  "192.168.13.31",
  "192.168.13.32",
  "192.168.13.33"
 ],
 "bind_addr": "192.168.13.32",      
 "client_addr": "192.168.13.32",  
 "encrypt": "BuIYviAYi+BbNkOJxZ4YW4xogpF1eFkeZzXgQCA0GFw=",
 "log_file": "/usr/local/consul/log/consul.log",    
 "log_json": true,
 "log_rotate_duration": "24h",   
 "pid_file": "/usr/local/consul/log/consul.pid",    
 "enable_syslog": false,       
 "enable_debug": true,
 "ui": true,
 "performance": {
  "raft_multiplier": 1
 },
 "bootstrap_expect": 3, 
 "leave_on_terminate": false,
 "skip_leave_on_interrupt": true,
 "rejoin_after_leave": true,
 "ca_file": "/etc/consul.d/consul-agent-ca.pem",
 "cert_file": "/etc/consul.d/homsom-server-consul-1.pem",
 "key_file": "/etc/consul.d/homsom-server-consul-1-key.pem",
 "verify_incoming": true,
 "verify_outgoing": true,
 "verify_server_hostname": true,
 "acl": {
  "enabled": true,
  "default_policy": "allow",
  "enable_token_persistence": true
 }
}
---------
[root@ceph02 /usr/local/consul]# systemctl start consul
[root@ceph02 /usr/local/consul]# systemctl status consul
[root@ceph02 /usr/local/consul]# systemctl enable consul



#启动节点192.168.13.33-server-agent
[root@ceph03 /usr/local/consul]# ls conf/
consul-server33.json  consul.service
[root@ceph03 /usr/local/consul]# mv conf/consul.service /lib/systemd/system/
[root@ceph03 /usr/local/consul]# mv conf/consul-server33.json conf/consul.json
[root@ceph03 /usr/local/consul]# ls /etc/consul.d/
consul-agent-ca.pem  homsom-server-consul-2-key.pem  homsom-server-consul-2.pem
[root@ceph03 /usr/local/consul]# ls conf/
consul.json
[root@ceph03 /usr/local/consul]# cat conf/consul.json
---------
{
 "node_name": "agent33",
 "server": true,
 "datacenter": "homsom",
 "data_dir": "/usr/local/consul/data",
 "log_level": "INFO",
 "retry_join": [ 
  "192.168.13.31",
  "192.168.13.32",
  "192.168.13.33"
 ],
 "bind_addr": "192.168.13.33",      
 "client_addr": "192.168.13.33",  
 "encrypt": "BuIYviAYi+BbNkOJxZ4YW4xogpF1eFkeZzXgQCA0GFw=",
 "log_file": "/usr/local/consul/log/consul.log",    
 "log_json": true,
 "log_rotate_duration": "24h",   
 "pid_file": "/usr/local/consul/log/consul.pid",    
 "enable_syslog": false,       
 "enable_debug": true,
 "ui": true,
 "performance": {
  "raft_multiplier": 1
 },
 "bootstrap_expect": 3, 
 "leave_on_terminate": false,
 "skip_leave_on_interrupt": true,
 "rejoin_after_leave": true,
 "ca_file": "/etc/consul.d/consul-agent-ca.pem",
 "cert_file": "/etc/consul.d/homsom-server-consul-2.pem",
 "key_file": "/etc/consul.d/homsom-server-consul-2-key.pem",
 "verify_incoming": true,
 "verify_outgoing": true,
 "verify_server_hostname": true,
 "acl": {
  "enabled": true,
  "default_policy": "allow",
  "enable_token_persistence": true
 }
}
---------
[root@ceph03 /usr/local/consul]# systemctl start consul
[root@ceph03 /usr/local/consul]# systemctl status consul
[root@ceph03 /usr/local/consul]# systemctl enable consul


#查看集群成员信息
[root@ceph01 ~/consul/new]# consul members -http-addr=http://192.168.13.31:8500
Node     Address             Status  Type    Build  Protocol  DC      Segment
agent31  192.168.13.31:8301  alive   server  1.8.3  2         homsom  <all>
agent32  192.168.13.32:8301  alive   server  1.8.3  2         homsom  <all>
agent33  192.168.13.33:8301  alive   server  1.8.3  2         homsom  <all>


#启用节点192.168.13.34-client-agent:
[root@ceph04 /usr/local/consul]# ls conf/
consul-client34.json  consul.service
[root@ceph04 /usr/local/consul]# mv conf/consul.service /lib/systemd/system/
[root@ceph04 /usr/local/consul]# mv conf/consul-client34.json conf/consul.json
[root@ceph04 /usr/local/consul]# ls /etc/consul.d/
consul-agent-ca.pem  homsom-client-consul-0-key.pem  homsom-client-consul-0.pem
[root@ceph04 /usr/local/consul]# cat conf/consul.json 
---------
{
 "node_name": "client34",
 "server": false,
 "datacenter": "homsom",
 "data_dir": "/usr/local/consul/data",
 "log_level": "INFO",
 "retry_join": [ 
  "192.168.13.31",
  "192.168.13.32",
  "192.168.13.33"
 ],
 "bind_addr": "192.168.13.34",      
 "client_addr": "192.168.13.34",  
 "encrypt": "BuIYviAYi+BbNkOJxZ4YW4xogpF1eFkeZzXgQCA0GFw=",
 "log_file": "/usr/local/consul/log/consul.log",    
 "log_json": true,
 "log_rotate_duration": "24h",   
 "pid_file": "/usr/local/consul/log/consul.pid",    
 "enable_syslog": false,       
 "enable_debug": true,
 "ui": true,
 "leave_on_terminate": false,
 "skip_leave_on_interrupt": true,
 "rejoin_after_leave": true,
 "ca_file": "/etc/consul.d/consul-agent-ca.pem",
 "cert_file": "/etc/consul.d/homsom-client-consul-0.pem",
 "key_file": "/etc/consul.d/homsom-client-consul-0-key.pem",
 "verify_incoming": true,
 "verify_outgoing": true,
 "verify_server_hostname": true,
 "acl": {
  "enabled": true,
  "default_policy": "allow",
  "enable_token_persistence": true
 },
 "service": {
    "id": "dns",
    "name": "dns34",
    "tags": ["primary"],
    "address": "192.168.13.34",
    "port": 8600,
    "check": {
      "id": "dns",
      "name": "Consul DNS TCP on port 8600",
      "tcp": "192.168.13.34:8600",
      "interval": "10s",
      "timeout": "1s"
   }
 }
}
---------
[root@ceph04 /usr/local/consul]# systemctl daemon-reload 
[root@ceph04 /usr/local/consul]# systemctl start consul 
[root@ceph04 /usr/local/consul]# systemctl status consul
[root@ceph04 /usr/local/consul]# systemctl enable consul
[root@ceph04 /usr/local/consul]# consul members -http-addr=192.168.13.34:8500
Node      Address             Status  Type    Build  Protocol  DC      Segment
agent31   192.168.13.31:8301  alive   server  1.8.3  2         homsom  <all>
agent32   192.168.13.32:8301  alive   server  1.8.3  2         homsom  <all>
agent33   192.168.13.33:8301  alive   server  1.8.3  2         homsom  <all>
client34  192.168.13.34:8301  alive   client  1.8.3  2         homsom  <default>


#启用节点172.168.2.224-client-agent:
[jack@ubuntu:/usr/local/consul]$ ls conf/
consul-client224.json  consul.service
[jack@ubuntu:/usr/local/consul]$ sudo mv conf/consul.service /lib/systemd/system/
[jack@ubuntu:/usr/local/consul]$ sudo mv conf/consul-client224.json conf/consul.json
[jack@ubuntu:/usr/local/consul]$ ls /etc/consul.d/
consul-agent-ca.pem  homsom-client-consul-1-key.pem  homsom-client-consul-1.pem
[jack@ubuntu:/usr/local/consul]$ ls conf
consul.json
[jack@ubuntu:/usr/local/consul]$ cat conf/consul.json 
---------
{
 "node_name": "client224",
 "server": false,
 "datacenter": "homsom",
 "data_dir": "/usr/local/consul/data",
 "log_level": "INFO",
 "retry_join": [ 
  "192.168.13.31",
  "192.168.13.32",
  "192.168.13.33"
 ],
 "bind_addr": "172.168.2.224",      
 "client_addr": "172.168.2.224",  
 "encrypt": "BuIYviAYi+BbNkOJxZ4YW4xogpF1eFkeZzXgQCA0GFw=",
 "log_file": "/usr/local/consul/log/consul.log",    
 "log_json": true,
 "log_rotate_duration": "24h",   
 "pid_file": "/usr/local/consul/log/consul.pid",    
 "enable_syslog": false,       
 "enable_debug": true,
 "ui": true,
 "leave_on_terminate": false,
 "skip_leave_on_interrupt": true,
 "rejoin_after_leave": true,
 "ca_file": "/etc/consul.d/consul-agent-ca.pem",
 "cert_file": "/etc/consul.d/homsom-client-consul-1.pem",
 "key_file": "/etc/consul.d/homsom-client-consul-1-key.pem",
 "verify_incoming": true,
 "verify_outgoing": true,
 "verify_server_hostname": true,
 "acl": {
  "enabled": true,
  "default_policy": "allow",
  "enable_token_persistence": true
 },
 "service": {
    "id": "dns",
    "name": "dns224",
    "tags": ["primary"],
    "address": "172.168.2.224",
    "port": 8600,
    "check": {
      "id": "dns",
      "name": "Consul DNS TCP on port 8600",
      "tcp": "172.168.2.224:8600",
      "interval": "10s",
      "timeout": "1s"
   }
 }
}
---------
[jack@ubuntu /usr/local/consul]$source /etc/profile.d/consul.sh
[jack@ubuntu /usr/local/consul]$consul validate /usr/local/consul/conf/consul.json
[jack@ubuntu /usr/local/consul]$sudo systemctl start consul
[jack@ubuntu /usr/local/consul]$sudo systemctl status consul
[jack@ubuntu /usr/local/consul]$sudo systemctl enable consul


#HTTP API 结构
consul 的主要接口是一个 RESTful HTTP API。API 可以对节点、服务、检查、配置等执行基本的 CRUD 操作
验证
启用身份验证后，应使用X-Consul-Token标头或授权标头中的 Bearer 方案向 API 请求提供 Consul 令牌。这降低了令牌意外被记录或暴露的可能性。使用身份验证时，客户端应通过 TLS 进行通信。如果您未在请求中提供令牌，则将使用代理默认令牌。
下面是一个使用curlwith的例子X-Consul-Token。
 curl  \
     --header "X-Consul-Token: <consul token>"  \
     http://127.0.0.1:8500/v1/agent/members
下面是一个使用curl承载方案的例子。
curl \
    --header "Authorization: Bearer <consul token>" \
    http://127.0.0.1:8500/v1/agent/members
注：以前这是通过?token=查询参数提供的。此功能存在于许多端点上以实现向后兼容性，但强烈建议不要使用它，因为它可以作为 URL 的一部分出现在访问日志中。
#默认 ACL 策略
1.9 之后的 Consul 版本的所有 API 响应都将包含一个 HTTP 响应标头，该标头X-Consul-Default-ACL-Policy设置为“允许”或“拒绝”，它反映了代理acl.default_policy选项的当前值 。
如果没有意图匹配，这也是默认的意图强制操作。
即使禁用了 ACL，也会返回此值。

#规则文档解释了所有规则资源。以下四种资源类型对于任何启用了 ACL 的运行数据中心都至关重要。
规则	概括
acl	ACL 规则授予 ACL 操作的权限，包括创建、更新或查看令牌和策略。
node 和 node_prefix	节点规则授予节点级注册的权限，包括向数据中心和目录添加代理。
service 和 service_prefix	服务规则授予服务级别注册的权限，包括向目录添加服务。
operator	操作员授予数据中心操作的权限，包括与 Raft 交互。
#如果您有一个动态或非常大的环境，您可能需要考虑创建一个适用于所有代理的策略，以减少运营团队的工作量。
agent_prefix "" {
  policy = "read"
  }
请注意，空值""允许此规则应用于数据中心中的任何代理。在上面的示例中，此规则将适用于：server.one、client.one、client.two 和 client.three。
如果您有一个静态环境或为了最大程度的安全，您可能希望为每个代理创建单独的规则。这可能需要您在每次向数据中心添加新代理时创建新令牌。
agent "server.one" {
  policy = "read"
  }
agent "client.one" {
  policy = "read"
  }
agent "client.two" {
  policy = "read"
  }
agent "client.three" {
  policy = "read"
  }
#数据中心操作所需的权限
下表列出了一组常见操作所需的最低权限。在创建不太灵活的特定策略时，您还可以使用完全匹配规则。
命令行操作	所需权限
consul reload	agent_prefix "": policy = "write"
consul monitor	agent_prefix "": policy = "read"
consul leave	agent_prefix "": policy = "write"
consul members	node_prefix "": policy = "read"
consul acl	acl = "write"
consul catalog services	service_prefix "": policy = "read"
consul catalog nodes	node_prefix "": policy = "read"
consul services register	service_prefix "": policy = "write"
consul services register （连接代理）	service_prefix "": policy = "write", node_prefix "": policy = "read"
consul connect intention	service_prefix ""：intention=“write”
consul kv get	key_prefix "": policy = "read"
consul kv put	key_prefix "": policy = "write"

#常见故障问题
#agent成员
您可以在使用令牌配置代理时使用该consul members 命令来检查它们是否具有加入数据中心所需的权限。
如果成员列表中缺少代理、服务器或客户端，则表明该代理上的 ACL 配置不正确，或者令牌没有正确的权限。只有有权在目录中注册自己的代理才会包含在成员列表中。
使用consul acl以下部分中列出的命令来帮助对令牌权限进行故障排除。
#agent目录
该consul catalog nodes -detailed 命令将显示节点信息，包括“TaggedAddresses”。如果任何代理的“TaggedAddresses”为空，则该代理的 ACL 配置不正确。您可以通过查看所有服务器上的 Consul 日志来开始调试。如果正确启用了 ACL，您可以调查代理的令牌。
#重置 ACL 系统
如果遇到无法解决的问题，或错误放置引导令牌，您可以通过更新索引来重置 ACL 系统。首先，通过curl /v1/status/leader任何节点上的端点找到领导者。必须在领导者上执行 ACL 重置。
[root@prometheus snmp_exporter]# curl -XGET http://172.168.2.224:8500/v1/status/leader?pretty
"192.168.13.31:8300"
在此示例中，您可以看到领导者位于 IP192.168.13.31。需要在该服务器上运行以下命令。
重新运行 bootstrap 命令以获取索引号。
[root@ceph01 ~]# consul acl bootstrap -http-addr=192.168.13.34:8500
Failed ACL bootstrapping: Unexpected response code: 403 (Permission denied: rpc error making call: rpc error making call: ACL bootstrap no longer allowed (reset index: 46))
然后将重置索引写入bootstrap重置文件：（这里重置索引为46）
[root@ceph01 /usr/local/consul]# echo 46 >> /usr/local/consul/data/acl-bootstrap-reset
最后重置即可：
[root@ceph01 /usr/local/consul]# consul acl bootstrap -http-addr=192.168.13.34:8500
AccessorID:       00150f3e-6dda-8942-fcd7-c716bbe03d80
SecretID:         88c24ade-5b4b-fb92-2f4e-6aba8885f053
Description:      Bootstrap Token (Global Management)
Local:            false
Create Time:      2021-10-29 17:46:41.667765951 +0800 CST
Policies:
   00000000-0000-0000-0000-000000000001 - global-management



#设置 Consul 环境变量
请注意，由于启用了 TLS 加密，您现在需要使用服务器证书来完成所有其他任务。为了在设置的其余部分更轻松地使用 CLI，并完成 ACL 引导过程，请为所有代理设置以下环境变量。
--设置前
[root@ceph01 /usr/local/consul]# consul members
Error retrieving members: Get "http://127.0.0.1:8500/v1/agent/members?segment=_all": dial tcp 127.0.0.1:8500: connect: connection refused
[root@ceph01 ~/consul/new]# consul acl bootstrap -http-addr=http://192.168.13.31:8500
Failed ACL bootstrapping: Unexpected response code: 500 (The ACL system is currently in legacy mode.)
原因：在选举领导者之前（除非在群集中拥有预期的服务器数量，否则将一直被阻止），领事将继续处于旧版ACL模式。 进行领导者选举后，领导者将检测群集中的所有服务器是否都能够使用新的ACL系统，然后进行自我过渡。 然后，经过一段时间（从0到〜30s），其他服务器将其拾取并自行过渡。 然后，在另一个时间段（再次为0到〜30s）之后，客户端代理将检测到所有服务器都能够使用新的ACL并进行自我转换。
请注意，群集中的所有服务器都必须在1.4.0+上才能进行此转换。 因此，您不能只将1台服务器升级到1.4.0，然后再进行迁移。 我怀疑设置bootstrap_expect = 1有效地使该节点与其他服务器分开。
有关您的环境的任何更多信息（例如服务器/客户端数量及其版本）将有助于解决问题。

--设置后
[root@ceph01 ~/consul/new]# cat /etc/profile.d/consul.sh
export CONSUL_HOME=/usr/local/consul
export PATH=${PATH}:${CONSUL_HOME}/bin
export CONSUL_CACERT=/etc/consul.d/consul-agent-ca.pem
export CONSUL_CLIENT_CERT=/etc/consul.d/homsom-server-consul-0.pem
export CONSUL_CLIENT_KEY=/etc/consul.d/homsom-server-consul-0-key.pem
#使用一个代理生成 Consul 引导令牌，该令牌具有不受限制的权限。这将返回 Consul 引导令牌。所有后续的 Consul API 请求（包括 CLI 和 UI）都需要 SecretID。确保您保存了 SecretID。
[root@ceph01 ~/consul/new]# consul acl bootstrap -http-addr=http://192.168.13.31:8500
AccessorID:       867a6377-79b1-bded-d712-c182752f7ceb
SecretID:         e56a5420-22c0-ec7a-983a-886591243cdb
Description:      Bootstrap Token (Global Management)
Local:            false
Create Time:      2021-10-28 21:06:30.663835174 +0800 CST
Policies:
   00000000-0000-0000-0000-000000000001 - global-management
#设置 CONSUL_MGMT_TOKEN 环境变量。
[root@ceph01 ~/consul/new]# export CONSUL_HTTP_TOKEN="e56a5420-22c0-ec7a-983a-886591243cdb"
[root@ceph01 ~/consul/new]# export CONSUL_MGMT_TOKEN="e56a5420-22c0-ec7a-983a-886591243cdb"
#创建节点策略文件 ( node-policy.hcl)，对节点相关操作具有写访问权限，对服务相关操作具有读访问权限。
[root@ceph01 /usr/local/consul]# cat /usr/local/consul/node-policy.hcl
agent_prefix "" {
  policy = "write"
}
node_prefix "" {
  policy = "write"
}
service_prefix "" {
  policy = "read"
}
session_prefix "" {
  policy = "read"
}
#使用新创建的策略文件生成 Consul 节点 ACL 策略
[root@ceph01 /usr/local/consul]# consul acl policy create   -token=${CONSUL_MGMT_TOKEN}   -name node-policy   -rules @node-policy.hcl -http-addr=http://192.168.13.31:8500
ID:           6b53aa87-88be-6e70-8b1b-35be50823c52
Name:         node-policy
Description:  
Datacenters:  
Rules:
agent_prefix "" {
  policy = "write"
}
node_prefix "" {
  policy = "write"
}
service_prefix "" {
  policy = "read"
}
session_prefix "" {
  policy = "read"
}
#使用新创建的策略创建节点令牌。
[root@ceph01 /usr/local/consul]# consul acl token create   -token=${CONSUL_MGMT_TOKEN}   -description "node token"   -policy-name node-policy -http-addr=http://192.168.13.31:8500
AccessorID:       10f82181-bfaf-1c30-62cc-150bac96bf97
SecretID:         9602275d-5329-0c29-f530-2aa32b4c3549
Description:      node token
Local:            false
Create Time:      2021-10-28 21:11:12.509786767 +0800 CST
Policies:
   6b53aa87-88be-6e70-8b1b-35be50823c52 - node-policy
#在所有agent服务器上添加节点令牌。
[root@ceph01 /usr/local/consul]# consul acl set-agent-token -token="e56a5420-22c0-ec7a-983a-886591243cdb" -http-addr=http://192.168.13.31:8500 agent "9602275d-5329-0c29-f530-2aa32b4c3549"                                     
ACL token "agent" set successfully
注："e56a5420-22c0-ec7a-983a-886591243cdb"是第一步生成的管理token，"9602275d-5329-0c29-f530-2aa32b4c3549"是刚刚生成的节点token
#获取所有token列表
[root@ceph01 ~]# consul acl token  list -http-addr=192.168.13.31:8500
AccessorID:       10f82181-bfaf-1c30-62cc-150bac96bf97
Description:      node token
Local:            false
Create Time:      2021-10-28 21:11:12.509786767 +0800 CST
Legacy:           false
Policies:
   6b53aa87-88be-6e70-8b1b-35be50823c52 - node-policy

AccessorID:       00000000-0000-0000-0000-000000000002
Description:      Anonymous Token
Local:            false
Create Time:      2021-10-28 21:01:58.044124553 +0800 CST
Legacy:           false

AccessorID:       867a6377-79b1-bded-d712-c182752f7ceb
Description:      Bootstrap Token (Global Management)
Local:            false
Create Time:      2021-10-28 21:06:30.663835174 +0800 CST
Legacy:           false
Policies:
   00000000-0000-0000-0000-000000000001 - global-management
#clone token
[root@ceph01 ~]# consul acl token clone -description='clone by node-policy' -id 10f82181-bfaf-1c30-62cc-150bac96bf97 -http-addr=192.168.13.31:8500
AccessorID:       9584b511-e3e3-6a6d-b068-b01b95395c4f
SecretID:         bbdd9663-228c-147c-86a9-b7074641dccc
Description:      clone by node-policy
Local:            false
Create Time:      2021-10-29 16:51:51.824495596 +0800 CST
Policies:
   6b53aa87-88be-6e70-8b1b-35be50823c52 - node-policy
#重新读取token
[root@ceph01 ~]# consul acl token read -id 10f82181-bfaf-1c30-62cc-150bac96bf97 -http-addr=192.168.13.34:8500
AccessorID:       10f82181-bfaf-1c30-62cc-150bac96bf97
SecretID:         9602275d-5329-0c29-f530-2aa32b4c3549
Description:      node token
Local:            false
Create Time:      2021-10-28 21:11:12.509786767 +0800 CST
Policies:
   6b53aa87-88be-6e70-8b1b-35be50823c52 - node-policy



#注册服务
[root@prometheus snmp_exporter]# curl -XPUT -H 'X-Consul-Token: e56a5420-22c0-ec7a-983a-886591243cdb' -d @consul-snmp_idrac_exporter-192.168.50.50.json http://172.168.2.224:8500/v1/agent/service/register
--获取服务1
[root@prometheus snmp_exporter]# curl -XGET -H 'X-Consul-Token: e56a5420-22c0-ec7a-983a-886591243cdb' http://172.168.2.224:8500/v1/agent/service/snmp_idrac_exporter-192.168.50.50?pretty
{"ID":"snmp_idrac_exporter-192.168.50.50","Service":"snmp_idrac_exporter","Tags":["snmp_idrac_exporter"],"Meta":{"env":"tiger","ip":"192.168.50.50","name":"r720xd","project":"idrac","team":"ops"},"Port":0,"Address":"192.168.50.50","TaggedAddresses":{"lan_ipv4":{"Address":"192.168.50.50","Port":0},"wan_ipv4":{"Address":"192.168.50.50","Port":0}},"Weights":{"Passing":1,"Warning":1},"EnableTagOverride":false,"ContentHash":"1deef0e6535739a9"}
--获取服务2
[root@prometheus tmp]# curl -XGET http://192.168.13.34:8500/v1/catalog/service/snmp_idrac_exporter
[{"ID":"be81717e-be1b-a86b-d06a-d92886b42c8a","Node":"client224","Address":"172.168.2.224","Datacenter":"homsom","TaggedAddresses":{"lan":"172.168.2.224","lan_ipv4":"172.168.2.224","wan":"172.168.2.224","wan_ipv4":"172.168.2.224"},"NodeMeta":{"consul-network-segment":""},"ServiceKind":"","ServiceID":"snmp_idrac_exporter-192.168.50.50","ServiceName":"snmp_idrac_exporter","ServiceTags":["snmp_idrac_exporter"],"ServiceAddress":"192.168.50.50","ServiceTaggedAddresses":{"lan_ipv4":{"Address":"192.168.50.50","Port":0},"wan_ipv4":{"Address":"192.168.50.50","Port":0}},"ServiceWeights":{"Passing":1,"Warning":1},"ServiceMeta":{"env":"tiger","ip":"192.168.50.50","name":"r720xd","project":"idrac","team":"ops"},"ServicePort":0,"ServiceEnableTagOverride":false,"ServiceProxy":{"MeshGateway":{},"Expose":{}},"ServiceConnect":{},"CreateIndex":11284,"ModifyIndex":11284}]
[root@prometheus tmp]# curl -XGET -H 'application/json' http://192.168.13.236:8500/v1/catalog/service/aliyun_node_exporter?pretty


#通过catalog服务注册与服务注销
[root@prometheus tmp]# cat consul-register.json 
--------------
{
  "Datacenter": "homsom",
  "ID": "40e4a748-2192-161a-0510-9bf59fe950b5",
  "Node": "t2.320",
  "Address": "192.168.10.10",
  "TaggedAddresses": {
    "lan": "192.168.10.10",
    "wan": "10.0.10.10"
  },
  "NodeMeta": {
    "somekey": "somevalue"
  },
  "Service": {
    "ID": "redis1",
    "Service": "redis",
    "Tags": ["primary", "v1"],
    "Address": "127.0.0.1",
    "TaggedAddresses": {
      "lan": {
        "address": "127.0.0.1",
        "port": 8000
      },
      "wan": {
        "address": "198.18.0.1",
        "port": 80
      }
    },
    "Meta": {
      "redis_version": "4.0"
    },
    "Port": 8000
  },
  "Check": {
    "Node": "t2.320",
    "CheckID": "service:redis1",
    "Name": "Redis health check",
    "Notes": "Script based health check",
    "Status": "passing",
    "ServiceID": "redis1",
    "Definition": {
      "TCP": "localhost:8888",
      "Interval": "5s",
      "Timeout": "1s",
      "DeregisterCriticalServiceAfter": "30s"
    }
  },
  "SkipNodeUpdate": false
}
--------------
[root@prometheus tmp]# curl -XPUT -d @consul-register.json http://192.168.13.34:8500/v1/catalog/register
true
[root@prometheus tmp]# cat consul-deregister.json
--------------
{
  "Datacenter": "homsom",
  "Node": "t2.320",
  "ServiceID": "redis1"
}
--------------
[root@prometheus tmp]# curl -XPUT -d @consul-deregister.json http://192.168.13.34:8500/v1/catalog/deregister
true


#HTTP API
consul的主要接口是RESTful HTTP API，该API可以用来增删查改nodes、services、checks、configguration。所有的endpoints主要分为以下类别：
kv - Key/Value存储
agent - Agent控制
catalog - 管理nodes和services
health - 管理健康监测
session - Session操作
acl - ACL创建和管理
event - 用户Events
status - Consul系统状态

#status endpoint
[root@prometheus tmp]# curl -XGET -H 'application/json' http://192.168.13.31:8500/v1/status/leader
"192.168.13.31:8300"
[root@prometheus tmp]# curl -XGET -H 'application/json' http://192.168.13.31:8500/v1/status/peers
["192.168.13.31:8300","192.168.13.32:8300","192.168.13.33:8300"]

#event endpoint
[root@prometheus tmp]# curl -XPUT -H 'application/json' http://192.168.13.31:8500/v1/event/fire/test
{"ID":"3648f52e-22a1-58ab-b813-0b35fe510ff9","Name":"test","Payload":null,"NodeFilter":"","ServiceFilter":"","TagFilter":"","Version":1,"LTime":0}[root@prometheus tmp]# 
[root@prometheus tmp]# curl -XGET -H 'application/json' http://192.168.13.31:8500/v1/event/list
[{"ID":"3648f52e-22a1-58ab-b813-0b35fe510ff9","Name":"test","Payload":null,"NodeFilter":"","ServiceFilter":"","TagFilter":"","Version":1,"LTime":2}]ttp://192.168.13.31:8500/v1/event/fire/<name>

#acl endpoint
[root@prometheus tmp]# curl -XGET -H 'X-Consul-Token: 90d1a2ae-4bab-d530-c9e0-da8e013c69d7' http://192.168.13.31:8500/v1/acl/list
[{"ID":"90d1a2ae-4bab-d530-c9e0-da8e013c69d7","Name":"Bootstrap Token (Global Management)","Type":"management","Rules":"","CreateIndex":52339,"ModifyIndex":52339}]
/v1/acl/create: Creates a new token with policy
/v1/acl/update: Update the policy of a token
/v1/acl/destroy/<id>: Destroys a given token
/v1/acl/info/<id>: Queries the policy of a given token
/v1/acl/clone/<id>: Creates a new token by cloning an existing token
/v1/acl/list: Lists all the active tokens

#session endpoint
/v1/session/create: Creates a new session
/v1/session/destroy/<session>: Destroys a given session
/v1/session/info/<session>: Queries a given session
/v1/session/node/<node>: Lists sessions belonging to a node
/v1/session/list: Lists all the active sessions
[root@prometheus tmp]# curl -XGET -H 'X-Consul-Token: 90d1a2ae-4bab-d530-c9e0-da8e013c69d7' http://192.168.13.31:8500/v1/session/list
[]

#health endpoint
/v1/healt/node/<node>: 返回node所定义的检查，可用参数?dc=
/v1/health/checks/<service>: 返回和服务相关联的检查，可用参数?dc=
/v1/health/service/<service>: 返回给定datacenter中给定node中service
/v1/health/state/<state>: 返回给定datacenter中指定状态的服务，state可以是"any", "unknown", "passing", "warning", or "critical"，可用参数?dc=
[root@prometheus tmp]# curl -XGET -H 'X-Consul-Token: 90d1a2ae-4bab-d530-c9e0-da8e013c69d7' http://192.168.13.31:8500/v1/health/state/any?pretty

#catalog endpint
catalog endpoints用来注册/注销nodes、services、checks
/v1/catalog/register : Registers a new node, service, or check
/v1/catalog/deregister : Deregisters a node, service, or check
/v1/catalog/datacenters : Lists known datacenters
/v1/catalog/nodes : Lists nodes in a given DC
/v1/catalog/services : Lists services in a given DC
/v1/catalog/service/<service> : Lists the nodes in a given service
/v1/catalog/node/<node> : Lists the services provided by a node
[root@prometheus tmp]# curl -XGET -H 'X-Consul-Token: 90d1a2ae-4bab-d530-c9e0-da8e013c69d7' http://192.168.13.31:8500/v1/catalog/services
{"consul":[],"dns224":["primary"],"dns34":["primary"],"redis":["primary","v1"],"snmp_idrac_exporter":["snmp_idrac_exporter"]}
[root@prometheus tmp]# curl -XGET -H 'X-Consul-Token: 90d1a2ae-4bab-d530-c9e0-da8e013c69d7' http://192.168.13.31:8500/v1/catalog/service/snmp_idrac_exporter
[{"ID":"be81717e-be1b-a86b-d06a-d92886b42c8a","Node":"client224","Address":"172.168.2.224","Datacenter":"homsom","TaggedAddresses":{"lan":"172.168.2.224","lan_ipv4":"172.168.2.224","wan":"172.168.2.224","wan_ipv4":"172.168.2.224"},"NodeMeta":{"consul-network-segment":""},"ServiceKind":"","ServiceID":"snmp_idrac_exporter-192.168.50.50","ServiceName":"snmp_idrac_exporter","ServiceTags":["snmp_idrac_exporter"],"ServiceAddress":"192.168.50.50","ServiceTaggedAddresses":{"lan_ipv4":{"Address":"192.168.50.50","Port":0},"wan_ipv4":{"Address":"192.168.50.50","Port":0}},"ServiceWeights":{"Passing":1,"Warning":1},"ServiceMeta":{"env":"tiger","ip":"192.168.50.50","name":"r720xd","project":"idrac","team":"ops"},"ServicePort":0,"ServiceEnableTagOverride":false,"ServiceProxy":{"MeshGateway":{},"Expose":{}},"ServiceConnect":{},"CreateIndex":11284,"ModifyIndex":11284}]

#agent endpoint
agent endpoints用来和本地agent进行交互，一般用来服务注册和检查注册，支持以下接口
/v1/agent/checks : 返回本地agent注册的所有检查(包括配置文件和HTTP接口)
/v1/agent/services : 返回本地agent注册的所有 服务
/v1/agent/members : 返回agent在集群的gossip pool中看到的成员
/v1/agent/self : 返回本地agent的配置和成员信息
/v1/agent/join/<address> : 触发本地agent加入node
/v1/agent/force-leave/<node>>: 强制删除node
/v1/agent/check/register : 在本地agent增加一个检查项，使用PUT方法传输一个json格式的数据
/v1/agent/check/deregister/<checkID> : 注销一个本地agent的检查项
/v1/agent/check/pass/<checkID> : 设置一个本地检查项的状态为passing
/v1/agent/check/warn/<checkID> : 设置一个本地检查项的状态为warning
/v1/agent/check/fail/<checkID> : 设置一个本地检查项的状态为critical
/v1/agent/service/register : 在本地agent增加一个新的服务项，使用PUT方法传输一个json格式的数据
/v1/agent/service/deregister/<serviceID> : 注销一个本地agent的服务项
[root@prometheus tmp]# curl -XGET -H 'X-Consul-Token: 90d1a2ae-4bab-d530-c9e0-da8e013c69d7' http://192.168.13.31:8500/v1/agent/members?pretty
[
    {
        "Name": "agent31",
        "Addr": "192.168.13.31",
        "Port": 8301,
        "Tags": {
            "acls": "1",
            "build": "1.8.3:a9322b9c",
            "dc": "homsom",
            "expect": "3",
            "ft_fs": "1",
            "id": "445bf299-02ea-557e-94fb-6462eff04b64",
            "port": "8300",
            "raft_vsn": "3",
            "role": "consul",
            "segment": "",
            "use_tls": "1",
            "vsn": "2",
            "vsn_max": "3",
            "vsn_min": "2",
            "wan_join_port": "8302"
        },
        "Status": 1,
        "ProtocolMin": 1,
        "ProtocolMax": 5,
        "ProtocolCur": 2,
        "DelegateMin": 2,
        "DelegateMax": 5,
        "DelegateCur": 4
    },
    {
        "Name": "agent32",
        "Addr": "192.168.13.32",
        "Port": 8301,
        "Tags": {
            "acls": "1",
            "build": "1.8.3:a9322b9c",
            "dc": "homsom",
            "expect": "3",
            "ft_fs": "1",
            "id": "edfd3d8b-851d-4007-85c8-fd7e1e0d1e23",
            "port": "8300",
            "raft_vsn": "3",
            "role": "consul",
            "segment": "",
            "use_tls": "1",
            "vsn": "2",
            "vsn_max": "3",
            "vsn_min": "2",
            "wan_join_port": "8302"
        },
        "Status": 1,
        "ProtocolMin": 1,
        "ProtocolMax": 5,
        "ProtocolCur": 2,
        "DelegateMin": 2,
        "DelegateMax": 5,
        "DelegateCur": 4
    },
    {
        "Name": "agent33",
        "Addr": "192.168.13.33",
        "Port": 8301,
        "Tags": {
            "acls": "1",
            "build": "1.8.3:a9322b9c",
            "dc": "homsom",
            "expect": "3",
            "ft_fs": "1",
            "id": "251539ec-76b7-128d-a45a-055837e7c956",
            "port": "8300",
            "raft_vsn": "3",
            "role": "consul",
            "segment": "",
            "use_tls": "1",
            "vsn": "2",
            "vsn_max": "3",
            "vsn_min": "2",
            "wan_join_port": "8302"
        },
        "Status": 1,
        "ProtocolMin": 1,
        "ProtocolMax": 5,
        "ProtocolCur": 2,
        "DelegateMin": 2,
        "DelegateMax": 5,
        "DelegateCur": 4
    },
    {
        "Name": "client34",
        "Addr": "192.168.13.34",
        "Port": 8301,
        "Tags": {
            "acls": "1",
            "build": "1.8.3:a9322b9c",
            "dc": "homsom",
            "id": "04f58b79-e007-855d-074b-47a6b99b05c4",
            "role": "node",
            "segment": "",
            "vsn": "2",
            "vsn_max": "3",
            "vsn_min": "2"
        },
        "Status": 1,
        "ProtocolMin": 1,
        "ProtocolMax": 5,
        "ProtocolCur": 2,
        "DelegateMin": 2,
        "DelegateMax": 5,
        "DelegateCur": 4
    },
    {
        "Name": "client224",
        "Addr": "172.168.2.224",
        "Port": 8301,
        "Tags": {
            "acls": "1",
            "build": "1.8.3:a9322b9c",
            "dc": "homsom",
            "id": "be81717e-be1b-a86b-d06a-d92886b42c8a",
            "role": "node",
            "segment": "",
            "vsn": "2",
            "vsn_max": "3",
            "vsn_min": "2"
        },
        "Status": 1,
        "ProtocolMin": 1,
        "ProtocolMax": 5,
        "ProtocolCur": 2,
        "DelegateMin": 2,
        "DelegateMax": 5,
        "DelegateCur": 4
    }
]

#config endpoint










#
[root@ceph03 /usr/local/consul/data]# consul leave -http-addr=192.168.13.34:8500
[root@ceph03 /usr/local/consul/data]# consul members -http-addr=192.168.13.31:8500
Node       Address             Status  Type    Build  Protocol  DC      Segment
agent31    192.168.13.31:8301  alive   server  1.8.3  2         homsom  <all>
agent32    192.168.13.32:8301  alive   server  1.8.3  2         homsom  <all>
agent33    192.168.13.33:8301  alive   server  1.8.3  2         homsom  <all>
client224  172.168.2.224:8301  alive   client  1.8.3  2         homsom  <default>
client34   192.168.13.34:8301  left    client  1.8.3  2         homsom  <default>
[root@prometheus tmp]# curl -XGET -H 'X-Consul-Token: 90d1a2ae-4bab-d530-c9e0-da8e013c69d7' http://192.168.13.31:8500/v1/catalog/service/snmp_idrac_exporter?pretty  --此时可获取值,因为获取的service注册是在172.168.2.224agent,当初注册时使用/v1/agent/service/register进行注册的，而不是/v1/catalog/register进行注册的
[root@ceph03 /usr/local/consul/data]# consul members -http-addr=192.168.13.31:8500
Node       Address             Status  Type    Build  Protocol  DC      Segment
agent31    192.168.13.31:8301  alive   server  1.8.3  2         homsom  <all>
agent32    192.168.13.32:8301  alive   server  1.8.3  2         homsom  <all>
agent33    192.168.13.33:8301  alive   server  1.8.3  2         homsom  <all>
client224  172.168.2.224:8301  left    client  1.8.3  2         homsom  <default>
client34   192.168.13.34:8301  left    client  1.8.3  2         homsom  <default>
[root@prometheus tmp]# curl -XGET -H 'X-Consul-Token: 90d1a2ae-4bab-d530-c9e0-da8e013c69d7' http://192.168.13.31:8500/v1/catalog/service/snmp_idrac_exporter?pretty
[]   --此时不可获取值,因为172.168.2.224agent已经down了，所以注册的服务也就down了

#acl默认策略在线滚动变更 
以下命令都可以在同一台服务器上完成：


