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
11. xDS：CDS(Cluster Discovery Server),EDS(Endpoint Discovery Server),HDS,LDS(Listener Discovery Server),RLS(Rate Limit),RDS(Route Discovery Server),SDS,VHDS和RTDS等API的统称； 

流程：
Donwstream --> Listener --> Filter Chains(Route) --> Cluster --> Endpoint

#Deployment Types 
Service to service、front proxy，and double proxy
#Service to service:
Engress: 正向代理
Ingress：反向代理
无论微服务是暴露给服务网格内部还是服务网格外部或者API Gateway时，都需要使用Listener侦听器暴躁给外部，Envoy无论后端endpoint是一个还是多个，都需要定义Cluster
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



</pre>