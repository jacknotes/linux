#Service Mesh
<pre>
技术所处5个阶段：创新者、早期采纳者、早期大众者、晚期大众者、落后者

服务网格课程大章：
1. Service Mesh Basics
2. Envoy Basics
3. 基础配置及应用
4. xDS协议及API动态配置
5. 层级化运行时
6. 服务韧性
7. 流量治理
8. 分布式跟踪
9. 风格安全
10. istio基础
11. istio实践

. 介绍微服务：1
. envoy：2-9
. istio: 10-11

注：istio建立在envoy之上，kubernetes通过CRD进行配置istio来实现envoy，但是配置语法跟envoy不一样，但原理一样。



#微服务和服务治理基础
. 程序架构风格与微服务
. 微服务架构的弊端
. 微服务系统中的通信
. 微服务治理和服务网格

#sidercar方式实现服务网格
微服务的业务程序独立运行，而网络功能则以独立的工作于客户端与服务之间（透明代理方式），专门为代理的服务提供熔断、限流、追踪、指标采集和服务发现等功能；而这些由各服务的专用代理层联合组成的服务通信网络称之为服务网格（Service Mesh）

#服务网格的实现方案
在实现上，数据平面的主流解决方案有Linkerd、Nginx、Envoy、HAProxy和Traefik等，而控制平面的实现主要有Istio、Nelson和SmartStack等几种
Linkerd：
	1. 由Buoyant公司于2016年率先创建的开源高性能网络代理程序（数据平面），是业界第一款Service Mesh产品，引领并促进了相关技术的快速发展
	2. Linkerd使用Namerd提供控制平面，实现中心化管理和存储路由规划、服务发现配置、支持运行时动态路由等功能
Envoy：
	1. 核心功能在于数据平面，于2016年由Lyft公司创建并开源，目标是成为通用的数据平面
	2. 云原生应用，既可用作前端代理，亦可实现Service Mesh中的服务间通信
	3.Envoy常被用于实现API Gateway（如Ambassador）以及Kubernetes的Ingress Controller（例如gloo等），不过，基于Envoy实现的Service Mesh产品Istio有着更广泛的用户基础
Istio：
	1. 相比前两者来说，Istio发布时间稍晚，它于2017年5月方才面世，但却是目前最火热的Service Mesh解决方案，得到了Google、IBM、Lyft及Redhat等公司的大力推广及支持
	2. 目前仅支持部署在Kubernetes之止，其数据平面由Envoy实现
注：目前有人说Istio性能上不如Linkerd

#服务网格的部署模式
服务网格的部署模式有两种：主机共享代理及Sidercar代理
主机共享代理：
	1. 适用于同一主机上存在许多容器的场景，并且还可利用连接池来提高吞吐量
	2. 但一个代理进程故障将终止其所在主机上的整个容器队列，受影响的不仅仅是单个服务
	3. 实现方式中，常见的是运行为Kubernetes之上的DaemonSet
Sidercar代理：
	1. 代理进程注入每个Pod定义以与主容器一同运行
	2. Sidercar进程应该尽可能轻量且功能完善
	3. 实现方案：Linkerd、Envoy和Conduit
注：Istio默认使用的是Sidercar代理

#服务网格上的南北及东西向流量
南北流量：指的是服务网格外部客户端请求进入服务网格而后去请求服务网格内的服务的流量 
东西流量：指的是服务网格内部的各服务之间的通信流量 


#envoy basic
xDS API常用术语
1. 集群（Cluster）：集群是Envoy连接到的一组逻辑上相似的端点；在v2中，RDS通过路由指向集群，CDS提供集群配置，而Envoy通过EDS发现集群成员，即端点；
2. 下游（Downstream）：下游主机连接到Envoy，发送请求并接收响应，它们是Envoy的客户端；
3. 上游（Upstream）：上游主机接收来自Envoy的连接和请求并返回响应，Envoy代理的后端服务器；
4. 端点（Endpoint）：端点即上游主机，是一个或多个集群的成员，可通过EDS发现；
5. 侦听器（Listener）：侦听器是能够由下游客户端连接的命令网络位置，例如商品或unix套接字等；
6. 位置（Locality）：上游端点运行的区域拓扑，包括地域、区域和子区域等；
7. 管理服务器（Managerment Server）：实现v2 API的服务器，它支持复制和分片，并且能够在不同的物理机器上实现针对不同xDS API的API服务；
8. 地域（Region）：区域所属地址位置；
9. 区域（Zone）：AWS中的可用区（AZ）或GCP中的区域乖；
10. 子区域（Subzone）：Envoy实例或端点运行的区域内的位置，用于支持区域内的多个负载均衡目标；
11. xDS：CDS(Cluster Discovery Server),EDS(Endpoint Discovery Server){在cluster中也可以使用DNS服务发现},HDS,LDS(Listener Discovery Server),RLS(Rate Limit),RDS(Route Discovery Server),SDS(Secret Discovery Server){如果集群使用TLS进行通信，则可以用SDS生成私钥和证书来进行通信},VHDS和RTDS等API的统称； 

流程：
Donwstream --> Listener --> Filter Chains(Route) --> Cluster --> Endpoint

#Deployment Types 
Service to service、front proxy，and double proxy
#Service to service:
Engress: 正向代理
Ingress：反向代理
无论微服务是暴露给服务网格内部还是服务网格外部或者API Gateway时，都需要使用Listener侦听器暴露给外部，Envoy无论后端endpoint是一个还是多个，都需要定义Cluster
#front proxy
sidercar部署的代理只能支持东西向流量（网格内流量），如果需要支持南北向流量，需要使用边缘代理（类似nginx代理）
#double proxy
External Cients --> Internet --> Front Envoy Proxy #1 --> HTTP/2,TLS,Client auth --> Front Envoy Proxy #2 --> Private Service

#Envoy线程模型
单进程多线程架构类型，一个主线程和一些工作线程
主线程：负责Envoy程序的启动和关闭、xDS API调用处理（包括DNS、健康状态检测和集群管理等）、运行时配置、统计数据刷新、管理接口维护和其它线程管理（信号的热重启等）等，相关的所有事情均以异步非阻塞模式完成；
工作线程：默认情况下，Envoy根据当前主机CPU核心数来创建等同数量的工作线程，不过管理员也可以通过程序选项--concurrency具体指定；每个工作线程运行一个非阻塞型事件循环，负责为每个侦听器监听指定的套接字、接收新请求、为每个连接初始一个过滤器栈并处理此连接整个生命周期中的所有事件；
文件刷写线程：Envoy写入的每个文件都有一个专用、独立的阻塞型刷写线程，当工作线程需要写入文件时，数据实际上被移入内存缓冲区，最终通过文件刷写线程同步至文件中。

#Envoy连接处理（简洁工作流程）
侦听过滤器、L4（传输层）过滤器、L7（应用层）过滤器
统计数据相关的线程（Stats）
管理接口相关的线程（Admin）
集群管理器、侦听器管理器、路由管理器线程
xDS API线程


#xDS之间的通信和配置管理
Listener Discovery Server <----> xDS <----> Listener Manger -->动态生成配置侦听器配置文件
Cluster Discovery Server <----> xDS <----> Cluster Manger -->动态生成配置侦听器配置文件
...

#配置方式
1. 纯静态配置
2. 仅使用EDS
3. 使用EDS和CDS
4. EDS,CDS和RDS
5. EDS,CDS,RDS和LDS
6. EDS,CDS,RDS,LDS和SDS

如果CDS和EDS都是动态配置，其它都是静态配置，如果EDS配置先比CDS到达，那么集群配置就会出错，则需要ADS进行聚合，才能解决EDS配置比CDS到达的场景。

#Envoy配置中的重要概念
{
  "node": "{...}",
  "static_resources": "{...}",
  "dynamic_resources": "{...}",
  "cluster_manager": "{...}",
  "hds_config": "{...}",
  "flags_path": "...",
  "stats_sinks": [],
  "stats_config": "{...}",
  "stats_flush_interval": "{...}",
  "watchdog": "{...}",
  "tracing": "{...}",
  "runtime": "{...}",
  "layered_runtime": "{...}",
  "admin": "{...}",
  "overload_manager": "{...}",
  "enable_dispatcher_stats": "...",
  "header_prefix": "...",
  "stats_server_version_override": "{...}",
  "use_tcp_for_dns_lookups": "..."
}

Bootstrap配置中几个重要的基础概念：
	node: 节点标识，以呈现给管理服务器并且例如用于标识目的
	static_resources: 静态配置资源，用于配置静态的listener、cluster和secret 
	dynamic_resource: 动态配置的资源，用于配置基于xDS API获取listener,cluster和secret配置的lds_config,cds_config和ads_config
	admin: Envoy内置的管理接口
	tracing: 分布式跟踪
	layered_runtime: 层级化的运行时，支持使用RTDS从管理服务器动态加载
	hds_config: 使用HDS从管理服务器加载上游主机健康状态检测相关的配置
	overload_manager: 过载管理器
	stats_sinks: 统计信息接收器
一般来说，侦听器和集群是最为常用基础配置，无论是以静态或者是动态方式提供；

#Envoy配置概述
启动时从Bootstarp配置文件中加载初始配置
支持动态配置
	xDS API
		从配置文件加载配置
		从管理服务器（Management Server）基于xds协议加载配置
	runtime
		某些关键特性（Feature flags）保存为Key/value数据
		支持多层配置和覆盖机制
启动全动态配置机制后，仅极少数场景需要重新启动进程
	支持热重启
注：envoy启动时需要一个Bootstarp配置文件中加载初始配置，无论是静态还是动态都从Bootstarp配置文件中加载

Network(L3/L4) filters：
	Envoy内置了许多L3/L4过滤器，例如：
		代理类：TCP Proxy、HTTP connection manager、Thrift Proxy、Mongo proxy、Dubbo Proxy、ZooKeeper Proxy、MySQL Proxy和Redis Proxy等
	其它：Client TLS authentication、Rate Limit、Role Based Access Control（RBAC）、Network Filter和Upstream Cluster from SNI等
HTTP connection manager：
	HTTP connection manager自身是L3/L4过滤器，它能够将原始字节转换为HTTP级别消息和事件（例如，headers和body等）；
	它还处理所有HTTP连接和请求共有的功能，例如访问日志记录、请求ID生成和跟踪、请求/响应头操作、路由表管理和统计信息等；
	与L3/L4过滤器堆栈相似，Envoy还支持在HTTP连接管理器中使用HTTP级过滤器堆栈；
		HTTP过滤器在L7运行，它们访问和操作HTTP请求和响应；例如，gRPC-JSON Transcoder Filter为gRPC后端公开REST API，并将请求和响应转换为相应的格式；
		常用的HTTP过滤器Router、Rate Limit、Health check、Gzip和Fault Injection等；



#ceph
版本区分，生产环境一定要使用小版本号为2的版本安装 
x.0.z：开发版
x.1.z：候选版
x.2.z：稳定版

3节点ceph集群：
一主两备，3副本
一块盘一个OSD进程，每个OSD ID都是唯一的
没有选举概念
系统盘做RAID1，每个系统数据盘做RAID0，可以节省磁盘空间，统一SSD硬盘（统一规格大小）。
客户端挂载使用的是Ceph协议，也可以通过NFS转Ceph协议进行挂载，但是有损耗

#一个ceph集群的组成部分：
若干的Ceph OSD(对象存储守护程序)
至少需要一个Ceph Monitors监视器（1，3，5，7...）
两个或以上的Ceph管理器managers,运行Ceph文件系统客户端时还需要高可用的Ceph Metadata Server（文件系统元数据服务器）
RADOS cluster: 由多台host存储服务器组成的ceph集群
OSD(Object Storage Daemon): 每台存储服务器的磁盘组成的存储空间
Mon（Monitor）：ceph的监视器，维护OSD和PG的集群状态，一个ceph集群至少要有一个mon,可以是一三五七等等这样的奇数个。
Mgr(Manager): 负责跟踪运行时指标和Ceph集群的当前状态，包括存储利用率，当前性能指标和系统负载等。


ceph中的pg，是把一组比较大的数据进行拆分，几个pg就拆分为几份，然后每个pg中都是3副本（一主两备）

file_name(oid) --> object -->　pg --> （Crush算法）写入数据到pg所关联的主OSD中


ceph将一个对象映射到RADOS集群的时候分为两步走：
	1. 首先使用一致性hash算法将对象名称映射到PG2.7(例如，pool为2，PG为7)
	2. 然后将PG ID 基于CRUSH算法映射到OSD即可查到对象
以上两个过程都是以“实时计算”的方式完成，而没有使用传统的查询数据与块设备的对应表的方式，这样有效避免了组件的“中心化”问题，也解决了查询 性能和冗余问题，使得ceph集群扩展不再受查询的性能限制。

这个实时计算操作使用的就是CRUSH算法：
	Controllers replication under scalable hashing #可控的、可复制的、可伸缩的一致性hash算法
	CRUSH是一种分布式算法，类似于一致性hash算法，用于为RADOS存储集群控制数据的分配。



#部署ceph集群：
硬件规划：
元数据服务器对CPU敏感：大于4核CPU
元数据服务器和监视器必须可以尽快地提供它们的数据 ，所以他们应该有足够的内存，至少每进程1G

16C32G


mon: 16c 16g 200g
mgr(manager): 16c 16g 200g
存储服务器osd：企业级SSD
网卡：万兆网卡，或者PCIE万兆网卡












</pre>