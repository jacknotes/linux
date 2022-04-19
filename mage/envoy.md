##云原生、服务网格（Service Mesh）

<pre>
####第一课：服务风格、Envoy和Istio入门
学习方法：
1. 先完成，再完善。
2. 时间再充裕，也不可能将一件事情做完美，但总有时间做完一件事情。

#技术所处5个阶段：创新者、早期采纳者、早期大众者、晚期大众者、落后者
#分布式应用的需求：
Lifecycle(生命周期，Kubernetes解决生命周期的问题)
Networking(网络，istio服务网格解决大部分)
Binding(绑定，产品有Knative和Dapr)
State(状态，产品有Dapr)
注：Kubernetes解决生命周期的问题，Service Mesh解决网络的问题

#微服务架构:
Apache Dubbo: rpc风格
Spring Cloud: Restful风格

##网络通信是服务架构的痛点
#分布式计算的8个谬论
- 网络是可靠的
- 网络延迟是0
- 带宽是无限的
- 网络是安全的
- 网络拓扑从不改变
- 只有一个管理员
- 传输成本是0 
- 网络是同构的
解决方法：超时，重试机制

#什么是服务网格(Service Mesh)？
1. 每个服务都使用一个专门的代理Sidecar来完成高级网络功能
2. 各服务之间仅通过sidecar代理(网络代理，http代理)互相通信
3. 各代理之间形成了一个网状网络，2017年，William为其创建一个专用定义，并称之为Service Mesh
注：网络通信是服务架构的痛点，服务网络是解决高级网络功能的。
注：istio建立在envoy之上，kubernetes通过CRD进行配置istio来实现envoy，但是配置语法跟envoy不一样，但原理一样。

#服务网格优缺点：
优点：
- 独立进程，用户业务非侵入、语言无关
- 治理逻辑升级业务无感知
- 可以渐进的微服务化
缺点：
- 代理的性能和资源开销

#服务网格基本功能：
- 控制服务间通信：熔断、重试、超时、故障注入、负载均衡和故障转移等
服务发现：通过专用的服务总线发现服务端点
可观测：指标数据采集、监控、分布式日志记录和分布式追踪
安全性：TLS/SSL通信和密钥管理
身份认证和授权检查：身份认证，以及基于黑白名单或RBAC的访问控制功能
部署：对容器技术的原生支持，例如Docker和Kubernetes等
服务间的通信协议：HTTP1.1,HTTP2.0和gRPC等
健康状态检测：监测上游服务的健康状态
......

#服务网格版本
1.0 无控制平面
2.0 有控制平面

#规范
数据平面规范：UDPA(Universal Data Plane API)
	产品：envoy绝对主流
控制平面规范：SMI(Service Mesh Interface)
	产品：多家竞争，有istio,linkerd等

#控制平面
----数据平面与控制平面：
- 数据平面：触及系统中的每个数据包或请求，负责服务发现、健康检查、路由、负载均衡、身份验证/授权和可观测性等
- 控制平面：为网格中的所有正在运行的数据平面提供策略和配置，从而将所有数据平面联合构建为分布式系统，它不接触系统中的任何数据包或请求
	负责的任务包括例如确定两个服务Service X到Service Y之间的路由，Service Y相关集群的负载均衡机制的负载均衡机制、断路策略、流量转移机制等，并将决策下发给Service X和Service Y的Sidecar
----控制平面组件
- 工作负载调度程序：借助于底层的基础设施（例如Kubernetes）完成服务及其Sidecar运行位置的调度决策
- 服务发现：服务网格中的服务发现
- Sidecar代理配置API: 各Sidecar代理以最终一致的方式从各种系统组件获取配置
- 控制平面UI：管理人员的操作接口，用于配置全局级别的设置，例如部署、身份认证和授权、路由及负载均衡等

#服务网格
- Mesh解决方案极大降低了业务逻辑与网络功能之间的耦合度，能够快捷、方便地集成到现有的业务环境中，并提供了多语言、多协议支持，运维和管理成本被大大压缩，且开发人员能够将精力集中于业务逻辑本身，而无须再关注业务代码以外的其它功能
- 一旦启用Service Mesh，服务间的通信将遵循以下通信逻辑
	- 微服务彼此间不会直接进行通信，而是由各服务前端的称为Service Mesh的代理程序进行
	- Service Mesh内置支持服务发现、熔断、负载均衡等网络相关的用于控制服务间通信的各种高级功能
	- Service Mesh与编程语言无关，开发人员可以使用任何编程语言编写微服务的业务逻辑，各服务之间也可以使用不同的编程语言开发
	- 服务间的通信的局部故障可由Service Mesh自动处理
	- Service Mesh中的各服务的代理程序由控制平面(control plane)集中管理；各代理程序之间的通信网络也称为数据平面(data plane)
	- 部署于容器编排平台时，各代理程序会以微服务容器的Sidecar模式运行
	
#sidercar方式实现服务网格
微服务的业务程序独立运行，而网络功能则以独立的工作于客户端与服务之间（透明代理方式），专门为代理的服务提供熔断、限流、追踪、指标采集和服务发现等功能；而这些由各服务的专用代理层联合组成的服务通信网络称之为服务网格（Service Mesh）

#Service Mesh代表产品
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
	2. 目前仅支持部署在Kubernetes之上，其数据平面由Envoy实现
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
	

###第二课：微服务系统中的进程间通信
#本课内容
- 什么是Envoy
- Envoy组件拓扑
- Envoy xDS核心术语
- Envoy的部署类型
- Envoy核心配置组件 
	- Listener
	- Filter
	- Cluster
- Envoy线程模型的连接处理机制

#envoy代理
front proxy单独运行为一个Pod
sidecar proxy运行在pod里面的(workload旁边)

#envoy数据路径
request -->  listener(侦听器) --> filter chains(过虑链规则) --> cluster manager(集群管理器) --> cluster(集群)
流程：Donwstream --> Listener --> Filter Chains(Route) --> Cluster --> Endpoint

#envoy的几个显著特性
- 性能、可扩展性及动态可配置性
	- 性能：除了大量功能外，Envoy还提供极高的吞吐量和低尾延迟差异，同时消耗相对较少的CPU和RAM
	- 可扩展性：Envoy在L4和L7上提供丰富的可插拔过滤器功能，允许用户轻松添加新功能
	- API可配置性：Envoy提供了一组可由控制平面服务实现的管理API，也称为xDS API
		- 若控制平面实现了这所有的API，则可以使用通用引导配置在整个基础架构中运行Envoy
		- 所有进一步的配置更改都可通过管理服务器无缝地进行动态传递，使得Envoy永远不需要重新启动
		- 于是，这使得Envoy成为一个通用数据平面，当与足够复杂的控制平面相结合时，可大大降低整体操作复杂性
- Envoy xDS API存在V1、V2、V3三个版本
	- V1 API仅使用JSON/REST，本质上是轮询
	- V2 API是V1的演进，而不是革命，它是V1功能的超集，新的API模式使用proto3指定，并同时以gRPC和REST + JSON/YAML端点实现
	- V3 API：当前支持的版本，支持start_tls、拒绝传入的tcp连接、4096位的tls密钥、SkyWalking和WASM等
- Envoy已成为现代服务网格和边缘网关的"通用数据平面API"，Istio、Ambassador和Gloo等项目均是为此数据平面代理提供的控制平面

#envoy基础
xDS API常用术语
0. 主机（Host）: 一个具有网络通信能力的端点，例如服务器、移动智能设备等。
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


#Deployment Types（部署类型）
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

#http请求和响应流程
#http请求流程，是通过read filter进来的
用户请求 -> worker线程 -> listener filters -> connection(建立连接) -> TCP filter manager -> TCP Read Filters  -> http_connection_manager(四层过滤器) -> HTTP codec(http解码和封装) -> HTTP conn manager -> HTTP read filters -> service route -> upstream conn pool -> backend server
#http响应流程，是通过write filter出去的
响应请求 <- worker线程 <- listener filters <- connection(建立连接) <- TCP filter manager <- TCP Write Filters  http_connection_manager(四层过滤器) <- HTTP codec(http解码和封装)  <- HTTP conn manager  <- HTTP write filters  <- service route  <- upstream conn pool <- backend server





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
Bootstrap配置中几个重要的基础概念：
	node: 节点标识，以呈现给管理服务器并且例如用于标识目的
	*static_resources: 静态配置资源，用于配置静态的listener、cluster和secret 
	*dynamic_resource: 动态配置的资源，用于配置基于xDS API获取listener,cluster和secret配置的lds_config,cds_config和ads_config
	*admin: Envoy内置的管理接口
	tracing: 分布式跟踪
	layered_runtime: 层级化的运行时，支持使用RTDS从管理服务器动态加载
	hds_config: 使用HDS从管理服务器加载上游主机健康状态检测相关的配置
	overload_manager: 过载管理器
	stats_sinks: 统计信息接收器
一般来说，侦听器和集群是最为常用基础配置，无论是以静态或者是动态方式提供；
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

#Network(L3/L4) filters：
	Envoy内置了许多L3/L4过滤器，例如：
		代理类：TCP Proxy、HTTP connection manager、Thrift Proxy、Mongo proxy、Dubbo Proxy、ZooKeeper Proxy、MySQL Proxy和Redis Proxy等
	其它：Client TLS authentication、Rate Limit、Role Based Access Control（RBAC）、Network Filter和Upstream Cluster from SNI等
#HTTP connection manager：
	HTTP connection manager自身是L3/L4过滤器，它能够将原始字节转换为HTTP级别消息和事件（例如，headers和body等）；
	它还处理所有HTTP连接和请求共有的功能，例如访问日志记录、请求ID生成和跟踪、请求/响应头操作、路由表管理和统计信息等；
	与L3/L4过滤器堆栈相似，Envoy还支持在HTTP连接管理器中使用HTTP级过滤器堆栈；
		HTTP过滤器在L7运行，它们访问和操作HTTP请求和响应；例如，gRPC-JSON Transcoder Filter为gRPC后端公开REST API，并将请求和响应转换为相应的格式；
		常用的HTTP过滤器Router、Rate Limit、Health check、Gzip和Fault Injection等；
#Upstream Clusters
Envoy可配置任意数量的上游集群，并使用Cluster Manager进行管理
	- 由集群管理器负责管理的各集群可以由用户静态配置，也可借助于CDS API动态获取
	- 集群中的每个成员由endpoint进行标识，它可由用户静态配置，也可通过EDS或DNS服务动态发现：
		- Static: 静态配置
		- Strict DNS：严格DNS，Envoy将持续和异步地解析指定的DNS目标，并将DNS结果中的返回的每个IP地址视为上游集群中可用成员
		- Logical DNS：逻辑DNS，集群仅使用在需要启动新连接时返回的第一个IP地址，而非严格获取DNS查询的结果并假设它们构成整个上游集群；适用于必须通过DNS访问的大规模Web服务集群
		- Original destination: 当传入连接通过iptables的REDIRECT或TPROXY target或使用代理协议重定向到Envoy时，可以使用原始目标集群
		- Endpoint dicovery service(EDS): EDS是一种基于GRPC或REST-JSON API的xDS管理服务器获取集群成员的服务发现方式
		- Custom cluster：Envoy还支持在集群配置上的cluster_type字段中指定使用自定义集群发现机制

#cluster简单静态配置注解：
- 通常，集群代表了一组提供相同服务的上游服务器(端点)的组合，它可由用户静态配置，也能够通过CDS动态获取
- 集群需要在"预热"环节完成之后方能转为可用状态，这意味着集群管理器通过DNS解析或EDS服务完成端点初始化，以及健康状态检测成功之后才可用
  clusters:
  - name: web_cluster		#集群的惟一名称，且未提供alt_stat_name时将会被用于统计信息中
    alt_state_name: ...		#统计信息中使用的集群代名称
	type: STRICT_DNS		#用于解析集群(生成集群端点)时使用的服务发现类型，可用值有STATIC,STRICT_DNS,LOGICAL_DNS,ORIGINAL_DST和EDS等
    lb_policy: ROUND_ROBIN	#负载均衡算法，支持ROUND_ROBIN,LEAST_REQUEST,RING_HASH,RANDOM,MAGLEV和CLUSTER_PROVIDED	
    load_assignment:		#为STATIC,STRICT_DNS或LOGICAL_DNS类型的集群指定成员获取方式；EDS类型的集成要使用eds_cluster_config字段配置
      cluster_name: web_cluster		#集群名称，过路器调用集群名称时会从此处调用
      endpoints:					#端点列表
      - locality: {}				#标识上游主机所处的位置，通常以region,zone等进行标识
	    lb_endpoints:				#属于指定位置的端点列表
        - endpoint_name: ...			#端点的名称
		  endpoint:					#端点定义
            address:				#地址
              socket_address: 		#socket地址
			    address: myservice	#域名或IP
				port_value: 80		#地址端口
				protocol: tcp		#协议类型

#L4过滤器tcp_proxy
- TCP代理过滤器在下游客户端及上游集群之间执行1:1网络连接代理
	- 它可以单独用作隧道替换，也可以同其他过滤器(如MongoDB过滤器或速率限制过滤器)结合使用
	- TCP代理过滤器严格执行由全局资源管理于为每个上游集群的全局资源管理器设定的连接限制
		- TCP代理过滤器检查上游集群的资源管理器是否可以在不超过该集群的最大连接数的情况下创建连接
	- TCP代理过滤器可直接将请求路由至指定的集群，也能够在多个目标集群间基于权重进行调度转发
- 配置语法：
{
  stat_prefix: .../	#用于统计数据中心输出时使用的前缀字符
  cluster: ...,		#路由到的目标集群标识 
  weighted_clusters: ...,
  metadata_match: ...,
  idle_timeout: ...,	 #上下游连接间的超时时长，即没有发送和接收报文的超时时长
  access_log: ...,		#访问日志
  max_connect_attempts:	...	#最大连接尝试次数
}

#L4过滤器http_connection_manager
- http_connection_manager通过引入L7过滤器链实现了对http协议的操纵，其中router过滤器用于配置路由转发
- 配置语法：
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 127.0.0.1, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager		#固定写法
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager	#固定写法
          stat_prefix: ingress_http		#统计信息中使用的易读性的信息前缀
          codec_type: AUTO				
          route_config:					#静态路由配置，动态配置应该使用rds字段进行指定
            name: local_route			#路由配置的名称
            virtual_hosts:				#虚拟主机列表，用于构成路由表
            - name: web_service_1		#虚拟主机的逻辑名称，用于统计信息，与路由无关
              domains: ["*"]			#当前虚拟主机匹配的域名列表，支持使用"*"通配符;匹配搜索次序为精确匹配、前缀通配、后缀通配及完全通配
              routes:					#指定的域名下的路由列表，执行时按顺序搜索，第一个匹配到路由信息即为使用的路由机制
              - match: { prefix: "/" }
                route: { cluster: web_cluster }
          http_filters:							#定义http过滤器链
          - name: envoy.filters.http.router		#调用7层的路由过滤器
- 提示
  - 处理请求时，Envoy首先根据下游客户端请求的"host"来搜索虚拟主机列表中各virtual_host中的domains列表中的定义，第一个匹配到的Domain的定义所属的virtual_host即可处理请求的虚拟主机
  - 而后搜索当前虚拟主机中的routes列表中的路由列表中各路由条目的match的定义，第一个匹配到的match后的路由机制(route,redirect或direct_response)即生效 

#路由基础配置概览
- match
  - 基于prefix、patch或regex三者其中任何一个进行URI匹配
    - 提示：regex将会被safe_regex取代
  - 可额外根据headers和query_parameters完成报文匹配
  - 匹配的到报文可有三种路由机制
    - redirect
	- direct_response
	- route 
- route路由机制
  - 支持cluster, weighted_clusters和cluster_header三者之一定义目标路由
  - 转发期间可根据prefix_rewrite和host_rewrite完成URI重写
  - 可额外配置流量管理机制，例如timeout, retry_policy, cors, request_mirror_policy和rate_limits等

#HTTP L7路由基本配置
- route_config.virtual_hosts.routes配置的路由信息用于将下游的客户端请求路由至合适的上游集群中某Server上
  - 其路由方式是将url匹配match字段的定义
    - match字段可通过prefix(前缀)、path(路径)或safe_regex(正则表达式)三者之一来表示匹配模式
	- 与match相关的请求将由route(路由规则)、redirect(重写向规则)或direct_response(直接响应)三个字段其中之一完成路由。
	- 由route定义的路由目标必须是cluster(上游集群名称)、cluster_header(根据请求标头中的cluster_header的值确定目标集群)或weightted_clusters(路由目标有多个集群，每个集群拥有一定的权重)其中之一
- 配置示例
  routes:
  - name: ...		#此路由条目的名称
    match:
	  prefix: ...	#请求的URL的前缀
	route:			#路由条目
	  cluster: 		#目标上游集群


#管理接口admin
- Envoy内建了一个管理服务(administration server)，它支持查询和修改操作，甚至有可能暴露私有数据(例如统计数据、集群名称和证书信息等)，因此非常有必要精心编排其访问控制机制以避免非授权访问
  - 配置示例
    admin:
	  access_log: []	#访问日志协议的相关配置，通常需要指定日志过滤器及日志配置等
	  access_log_path: ...	#管理接口的访问日志文件路径，无须记录访问日志时使用/dev/null
	  profile_path: ...		#cpu profiler的输出路径，默认为/var/log/envoy/envoy.prof
	  address:				#监听的套接字
	    socket_address:
		  protocol: ...
		  address: ...
		  port_value: ...
- 下面是一个简单的配置示例
admin:
  access_log_path: /tmp/admin_access.log
  address:
    socket_address: {address: 0.0.0.0, port_value: 9901}
	#提示：此处仅为出于方便测试的目的，才设定其监听于对外通信的任意IP地址，安全起见，应该使用127.0.0.1
	
	
#数据平面标准：UPDA		控制平面标准：SMI
	
	
		  


#envoy入门测试
1. clone代码
root@front-envoy:~# git clone https://gitee.com/mageedu/servicemesh_in_practise.git
root@front-envoy:~# cd servicemesh_in_practise/
root@front-envoy:~/servicemesh_in_practise# ls
admin-interface     eds-filesystem  envoy.echo               http-egress   LICENSE                 security  tls-front-proxy
cds-eds-filesystem  eds-grpc        front-proxy              http-ingress  monitoring-and-tracing  tcpproxy
cluster-manager     eds-rest        http-connection-manager  lds-cds-grpc  README.md               template
root@front-envoy:~/servicemesh_in_practise# git branch -v --remotes
  origin/HEAD    -> origin/master
  origin/develop d0720de Update Envoy Basics
  origin/master  1404981 add LICENSE.
root@front-envoy:~/servicemesh_in_practise# git checkout origin/develop		#切换到develop分支
root@front-envoy:~/servicemesh_in_practise# ls
Cluster-Manager        Envoy-Basics  HTTP-Connection-Manager  README.md  template
Dynamic-Configuration  Envoy-Mesh    Monitoring-and-Tracing   Security

2. #sidecar-proxy Igress
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/http-ingress# cat docker-compose.yaml
version: '3'

services:
  envoy:
    image: envoyproxy/envoy-alpine:v1.20.0
    volumes:
    - ./envoy.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        ipv4_address: 172.31.3.2
        aliases:
        - ingress

  webserver01:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080			#通过变量改变服务端口
      - HOST=127.0.0.1
    network_mode: "service:envoy"
    depends_on:
    - envoy

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.3.0/24
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/http-ingress# cat envoy.yaml
static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: web_service_1
              domains: ["*"]
              routes:
              - match: { prefix: "/" }
                route: { cluster: local_cluster }
          http_filters:
          - name: envoy.filters.http.router
  clusters:
  - name: local_cluster
    connect_timeout: 0.25s
    type: STATIC
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: local_cluster
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address: { address: 127.0.0.1, port_value: 8080 }
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/http-ingress# docker-compose up		#运行
root@front-envoy:~# curl 172.31.3.2
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.1, ServerName: 78be29c0a50f, ServerIP: 172.31.3.2!	#因为代理是envoy，所以app返回客户端地址是127.0.0.1
root@front-envoy:~# curl -v 172.31.3.2
* Rebuilt URL to: 172.31.3.2/
*   Trying 172.31.3.2...
* TCP_NODELAY set
* Connected to 172.31.3.2 (172.31.3.2) port 80 (#0)
> GET / HTTP/1.1
> Host: 172.31.3.2
> User-Agent: curl/7.58.0
> Accept: */*
>
< HTTP/1.1 200 OK
< content-type: text/html; charset=utf-8
< content-length: 97
< server: envoy
< date: Sun, 10 Apr 2022 12:47:17 GMT
< x-envoy-upstream-service-time: 13
<
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.1, ServerName: 78be29c0a50f, ServerIP: 172.31.3.2!
* Connection #0 to host 172.31.3.2 left intact

#sidecar-proxy Egress
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/http-egress# cat docker-compose.yaml
version: '3.3'

services:
  envoy:
    image: envoyproxy/envoy-alpine:v1.20.0
    volumes:
    - ./envoy.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        ipv4_address: 172.31.4.2
        aliases:
        - front-proxy
    depends_on:
    - webserver01
    - webserver02

  client:
    image: ikubernetes/admin-toolbox:v1.0
    network_mode: "service:envoy"
    depends_on:
    - envoy

  webserver01:
    image: ikubernetes/demoapp:v1.0
    hostname: webserver01
    networks:
      envoymesh:
        ipv4_address: 172.31.4.11
        aliases:
        - webserver01

  webserver02:
    image: ikubernetes/demoapp:v1.0
    hostname: webserver02
    networks:
      envoymesh:
        ipv4_address: 172.31.4.12
        aliases:
        - webserver02

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.4.0/24
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/http-egress# cat envoy.yaml
# Author: MageEdu <mage@magedu.com>
# Site: www.magedu.com
static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 127.0.0.1, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: web_service_1
              domains: ["*"]
              routes:
              - match: { prefix: "/" }
                route: { cluster: web_cluster }
          http_filters:
          - name: envoy.filters.http.router

  clusters:
  - name: web_cluster
    connect_timeout: 0.25s
    type: STATIC
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: web_cluster
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address: { address: 172.31.4.11, port_value: 80 }
        - endpoint:
            address:
              socket_address: { address: 172.31.4.12, port_value: 80 }
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/http-egress# docker-compose up
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/http-egress# docker-compose exec client /bin/sh
[root@9a98f0ededcc /]# curl 127.0.0.1:80
iKubernetes demoapp v1.0 !! ClientIP: 172.31.4.2, ServerName: webserver02, ServerIP: 172.31.4.12!
[root@9a98f0ededcc /]# curl 127.0.0.1:80
iKubernetes demoapp v1.0 !! ClientIP: 172.31.4.2, ServerName: webserver01, ServerIP: 172.31.4.11!


#tcp-front-envoy
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/tcp-front-proxy# cat docker-compose.yaml
# Author: MageEdu <mage@magedu.com>
# Site: www.magedu.com
version: '3.3'

services:
  envoy:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./envoy.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        ipv4_address: 172.31.1.2
        aliases:
        - front-proxy
    depends_on:
    - webserver01
    - webserver02

  webserver01:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
    hostname: webserver01
    networks:
      envoymesh:
        ipv4_address: 172.31.1.11
        aliases:
        - webserver01

  webserver02:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
    hostname: webserver02
    networks:
      envoymesh:
        ipv4_address: 172.31.1.12
        aliases:
        - webserver02

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.1.0/24
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/tcp-front-proxy# cat envoy.yaml
# Author: MageEdu <mage@magedu.com>
# Site: www.magedu.com
static_resources:
  listeners:
    name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.tcp_proxy
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.tcp_proxy.v3.TcpProxy
          stat_prefix: tcp
          cluster: local_cluster

  clusters:
  - name: local_cluster
    connect_timeout: 0.25s
    type: STATIC
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: local_cluster
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address: { address: 172.31.1.11, port_value: 8080 }
        - endpoint:
            address:
              socket_address: { address: 172.31.1.12, port_value: 8080 }
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/tcp-front-proxy# docker-compose up
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/tcp-front-proxy# curl 172.31.1.2
iKubernetes demoapp v1.0 !! ClientIP: 172.31.1.2, ServerName: webserver01, ServerIP: 172.31.1.11!
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/tcp-front-proxy# curl 172.31.1.2
iKubernetes demoapp v1.0 !! ClientIP: 172.31.1.2, ServerName: webserver02, ServerIP: 172.31.1.12!

#egress使用cluster类型为strict_dns
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/http-egress# cat docker-compose.yaml
version: '3.3'

services:
  envoy:
    image: envoyproxy/envoy-alpine:v1.20.0
    volumes:
    - ./envoy.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        ipv4_address: 172.31.4.2
        aliases:
        - front-proxy
    depends_on:
    - webserver01
    - webserver02

  client:
    image: ikubernetes/admin-toolbox:v1.0
    network_mode: "service:envoy"
    depends_on:
    - envoy

  webserver01:
    image: ikubernetes/demoapp:v1.0
    hostname: webserver01
    networks:
      envoymesh:
        ipv4_address: 172.31.4.11
        aliases:
        - webserver01
        - myservice					#myservice是dns名称，可以解析为IP地址，在同一个service当中，每一个容器可以互相解析

  webserver02:
    image: ikubernetes/demoapp:v1.0
    hostname: webserver02
    networks:
      envoymesh:
        ipv4_address: 172.31.4.12
        aliases:
        - webserver02
        - myservice					#myservice是dns名称，可以解析为IP地址

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.4.0/24
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/http-egress# cat envoy.yaml
static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 127.0.0.1, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: web_service_1
              domains: ["*"]
              routes:
              - match: { prefix: "/" }
                route: { cluster: web_cluster }
          http_filters:
          - name: envoy.filters.http.router

  clusters:
  - name: web_cluster
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: web_cluster
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address: { address: myservice, port_value: 80 }			#myservice是dns名称，可以解析为IP地址
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/http-egress# docker-compose up
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/http-egress# docker-compose exec client /bin/sh
[root@5e7e878a241c /]# curl 127.0.0.1:80
iKubernetes demoapp v1.0 !! ClientIP: 172.31.4.2, ServerName: webserver02, ServerIP: 172.31.4.12!
[root@5e7e878a241c /]# curl 127.0.0.1:80
iKubernetes demoapp v1.0 !! ClientIP: 172.31.4.2, ServerName: webserver01, ServerIP: 172.31.4.11!



#admin管理接口
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/admin-interface# cat docker-compose.yaml
version: '3.3'

services:
  envoy:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./envoy.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        ipv4_address: 172.31.5.2
        aliases:
        - front-proxy
    depends_on:
    - webserver01
    - webserver02

  webserver01:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
    hostname: webserver01
    networks:
      envoymesh:
        ipv4_address: 172.31.5.11
        aliases:
        - webserver01

  webserver02:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
    hostname: webserver02
    networks:
      envoymesh:
        ipv4_address: 172.31.5.12
        aliases:
        - webserver02

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.5.0/24
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/admin-interface# cat envoy.yaml
# Author: MageEdu <mage@magedu.com>
# Version: v1.0.2
# Site: www.magedu.com
#
admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: web_service_1
              domains: ["*.ik8s.io", "ik8s.io"]
              routes:
              - match: { prefix: "/" }
                route: { cluster: local_cluster }
            - name: web_service_2
              domains: ["*.magedu.com",“magedu.com"]
              routes:
              - match: { prefix: "/" }
                redirect:
                  host_redirect: "www.ik8s.io"
          http_filters:
          - name: envoy.filters.http.router
  clusters:
  - name: local_cluster
    connect_timeout: 0.25s
    type: STATIC
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: local_cluster
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address: { address: 172.31.5.11, port_value: 8080 }
        - endpoint:
            address:
              socket_address: { address: 172.31.5.12, port_value: 8080 }
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/admin-interface# docker-compose up
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/admin-interface# curl 172.31.5.2:9901/help		#查看帮助
#管理接口admin速览
- admin接口内置了多个/path，不同的path可能会分别接受不同的GET或POST请求
admin commands are:
  /: Admin home page	#GET
  /certs: print certs on machine				#GET, 列出已加载的所有TLS证书及机关的信息
  /clusters: upstream cluster status			#GET, 额外支持使用”GET /clusters?format=json"
  /config_dump: dump current Envoy configs (experimental)	#GET, 打印Envoy加载的各类配置信息，支持include_eds, master和resource等查询参数
  /contention: dump current Envoy mutex contention stats (if enabled)	#GET, 互斥跟踪
  /cpuprofiler: enable/disable the CPU profiler				#POST, 启用或禁用cpuprofiler
  /drain_listeners: drain listeners				#POST, 驱逐所有的listener，支持使用inboundonly（仅入站侦听器）和graceful（优雅关闭）等查询参数
  /healthcheck/fail: cause the server to fail health checks	#POST, 强制设定HTTP健康状态检查为失败
  /healthcheck/ok: cause the server to pass health checks	#POST, 强制设定HTTP健康状态检查为成功
  /heapprofiler: enable/disable the heap profiler			#POST, 启用或禁用heapprofiler
  /help: print out list of admin commands
  /hot_restart_version: print the hot restart compatibility version			#GET, 打印热重启相关的信息
  /init_dump: dump current Envoy init manager information (experimental)	
  /listeners: print listener info				#GET,列出所有侦听器，支持使用"GET /listener?format=json"
  /logging: query/change logging levels
  /memory: print current allocation/heap usage	
  /quitquitquit: exit the server				#POST，干净退出服务器
  /ready: print server state, return 200 if LIVE, otherwise return 503	
  /reopen_logs: reopen access logs
  /reset_counters: reset all counters to zero	#POST，重置所有计数器
  /runtime: print runtime values				#GET, 以json格式输出所有运行时相关值 
  /runtime_modify: modify runtime values		#POST /runtime_modify?key1=value&key2=value2,添加或修改在查询参数中传递的运行时值 
  /server_info: print server version/status information		#GET,打印当前Envoy server的相关信息
  /stats: print server stats					#按需输出统计数据，例如GET /stats?filter=reges,另外还支持json和prometheus两种输出格式
  /stats/prometheus: print server stats in prometheus format				#输出prometheus格式的统计信息
  /stats/recentlookups: Show recent stat-name lookups
  /stats/recentlookups/clear: clear list of stat-name lookups and counter
  /stats/recentlookups/disable: disable recording of reset stat-name lookup names
  /stats/recentlookups/enable: enable recording of reset stat-name lookup names
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/admin-interface# curl 172.31.5.2:9901/listeners		#列出侦听器
listener_0::0.0.0.0:80
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/admin-interface# curl 172.31.5.2:9901/clusters		#列出集群及状态
local_cluster::observability_name::local_cluster
local_cluster::default_priority::max_connections::1024
local_cluster::default_priority::max_pending_requests::1024
local_cluster::default_priority::max_requests::1024
local_cluster::default_priority::max_retries::3
local_cluster::high_priority::max_connections::1024
local_cluster::high_priority::max_pending_requests::1024
local_cluster::high_priority::max_requests::1024
local_cluster::high_priority::max_retries::3
local_cluster::added_via_api::false
local_cluster::172.31.5.11:8080::cx_active::0
local_cluster::172.31.5.11:8080::cx_connect_fail::0
local_cluster::172.31.5.11:8080::cx_total::0
local_cluster::172.31.5.11:8080::rq_active::0
local_cluster::172.31.5.11:8080::rq_error::0
local_cluster::172.31.5.11:8080::rq_success::0
local_cluster::172.31.5.11:8080::rq_timeout::0
local_cluster::172.31.5.11:8080::rq_total::0
local_cluster::172.31.5.11:8080::hostname::
local_cluster::172.31.5.11:8080::health_flags::healthy
local_cluster::172.31.5.11:8080::weight::1
local_cluster::172.31.5.11:8080::region::
local_cluster::172.31.5.11:8080::zone::
local_cluster::172.31.5.11:8080::sub_zone::
local_cluster::172.31.5.11:8080::canary::false
local_cluster::172.31.5.11:8080::priority::0
local_cluster::172.31.5.11:8080::success_rate::-1.0
local_cluster::172.31.5.11:8080::local_origin_success_rate::-1.0
local_cluster::172.31.5.12:8080::cx_active::0
local_cluster::172.31.5.12:8080::cx_connect_fail::0
local_cluster::172.31.5.12:8080::cx_total::0
local_cluster::172.31.5.12:8080::rq_active::0
local_cluster::172.31.5.12:8080::rq_error::0
local_cluster::172.31.5.12:8080::rq_success::0
local_cluster::172.31.5.12:8080::rq_timeout::0
local_cluster::172.31.5.12:8080::rq_total::0
local_cluster::172.31.5.12:8080::hostname::
local_cluster::172.31.5.12:8080::health_flags::healthy
local_cluster::172.31.5.12:8080::weight::1
local_cluster::172.31.5.12:8080::region::
local_cluster::172.31.5.12:8080::zone::
local_cluster::172.31.5.12:8080::sub_zone::
local_cluster::172.31.5.12:8080::canary::false
local_cluster::172.31.5.12:8080::priority::0
local_cluster::172.31.5.12:8080::success_rate::-1.0
local_cluster::172.31.5.12:8080::local_origin_success_rate::-1.0
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/admin-interface# curl 172.31.5.2:9901/server_info	#列出服务器信息
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/admin-interface# curl 172.31.5.2:9901/ready		#检查是否健康
LIVE
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/admin-interface# curl 172.31.5.2:9901/certs		#查看证书
{
 "certificates": []
}
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/admin-interface# curl 172.31.5.2:9901/stats/prometheus		#以prometheus指标形势查看状态
注：其它URI可以通过POST进行修改，所以说需要对admin接口进行安全把控


##envoy支持两种配置：1. xDS 2. Runtime
##Envoy运行时配置概述
- 相对于静态资源配置来说，xDS API的动态配置机制使得Envoy的配置系统极具弹性
  - 但有时候配置的变动仅需要修改个别的功能特性，若通过xDS接口完成未免有些动静过大，Runtime便是面向这种场景的配置接口
  - Runtime就是一个虚拟文件系统树，可通过一至多个本地文件系统目录、静态资源、RTDS动态发现和Admin Interface进行定义和配置
    - 每个配置称为一个Layer，因而也称为"Layered Runtime"，这些Layer最终叠加生效
- 换句话说，Runtime是与Envoy一起部署的外置实时配置系统，用于支持更改配置设置而无需重启Envoy或更改主配置
  - 运行时配置相关的运行时参数也称为"功能标志(feature flags)"或"决策者(decider)"
  - 通过运行时参数更改配置将实时生效
- 运行时配置的实现也称为运行时配置供应者
  - Envoy当前支持的运行时配置的实现是由多个层级组成的虚拟文件系统
    - Envoy在配置的目录中监视符号链接的交换空间，并在发生交换时重新加载文件树
  - 但Envoy会使用默认运行时值和"null"提供给程序以确保其正确运行，因此，运行时配置系统并不必不可少

#配置Envoy运行时环境
- 启用Envoy的运行时配置机制需要在Bootstrap文件中予以启用和配置
  - 定义在bootstrap配置中文件的layered_runtime顶级字段之下
  - 一旦在bootstrap中给出layered_runtime字段，则至少要定义出一个layer
-配置示例
layered_runtime:	#配置运行配置供应者，未指定时则使用null供应者，即所有参数均加载其默认值 
  layers:			#运行时的层级列表，后面的层将覆盖先前层上的配置
  - name: ...				#运行时的层级名称，仅用于"GET /runtime"时的输出 
    static_layer: {...}		#静态运行时层级，遵循运行时probobuf JSON表示编码格式，不同于静态的xDS资源，静态运行时层一样可被后面的层所覆盖；此项配置，以及后面三个层级类型彼此互斥，因此一个列表项中仅可定义一层
	disk_layer: {...}		#基于本地磁盘的运行时层级
	  symlink_root: ...		#通过符号链接访问的文件系统树
	  subdirectory: ...		#指定要在根目录中加载的子目录
	  append_service_cluster: ...		#是否将服务集群附加至符号链接根目录下的子路径上
	admin_layer: {...}		#管理控制台运行时层级，即通过/runtime管理端点查看，通过/runtime_modify管理端点修改的配置方式
	rtds_layer: {...}		#运行时发现服务（runtime discovery service）层级，即通过xDS API中的RTDS API动态发现相关的层级配置
	  name: ...				#在rtds_config上为RTDS层订阅的资源
	  rtds_config: 			#RTDS的ConfigSource

#运行docmer-compose示例
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/admin-interface# cat envoy.yaml
# Author: MageEdu <mage@magedu.com>
# Version: v1.0.2
# Site: www.magedu.com
#
admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

layered_runtime:
  layers:
  - name: admin_layer_0
    admin_layer: {}

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: web_service_1
              domains: ["*.ik8s.io", "ik8s.io"]
              routes:
              - match: { prefix: "/" }
                route: { cluster: local_cluster }
            - name: web_service_2
              domains: ["*.magedu.com",“magedu.com"]
              routes:
              - match: { prefix: "/" }
                redirect:
                  host_redirect: "www.ik8s.io"
          http_filters:
          - name: envoy.filters.http.router
  clusters:
  - name: local_cluster
    connect_timeout: 0.25s
    type: STATIC
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: local_cluster
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address: { address: 172.31.5.11, port_value: 8080 }
        - endpoint:
            address:
              socket_address: { address: 172.31.5.12, port_value: 8080 }
---
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/admin-interface# cat docker-compose.yaml
version: '3.3'

services:
  envoy:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./envoy.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        ipv4_address: 172.31.5.2
        aliases:
        - front-proxy
    depends_on:
    - webserver01
    - webserver02

  webserver01:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
    hostname: webserver01
    networks:
      envoymesh:
        ipv4_address: 172.31.5.11
        aliases:
        - webserver01

  webserver02:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
    hostname: webserver02
    networks:
      envoymesh:
        ipv4_address: 172.31.5.12
        aliases:
        - webserver02

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.5.0/24
root@front-envoy:~/servicemesh_in_practise/Envoy-Basics/admin-interface# docker-compose up
root@front-envoy:~# curl -s 172.31.5.2:9901/help | grep runtime
  /runtime: print runtime values
  /runtime_modify: modify runtime values
root@front-envoy:~# curl -X POST 172.31.5.2:9901/runtime_modify?		#此时可以通过此接口进行修改配置，也可以配置disk_layer来通过文件系统进行修改


###Front Proxy和TLS
#Front Proxy
- 在Envoy Mesh中，作为Front Proxy的Envoy通常是独立运行的进程，它将客户端请求代理至Mesh中的各Service，而这些Service中的每个应用实例都会隐藏于一个Sidecar Proxy模式的envoy实例背后

#TLS
- Envoy Mesh中的TLS模式大体有如下几种常用场景
  - Front Proxy面向下游客户端提供https服务，但Front Proxy、Mesh内部的各服务间依然使用http协议
    - https -> http
  - Front Proxy面向下游客户端提供https服务，而且Front Proxy、Mesh内部的各服务间依然使用https协议
    - https -> https
	- 但是内部各Service间的通信也有如下两种情形
	  - 仅客户端验证服务端证书
	  - 客户端与服务端之间互相验证彼此的证书(mTLS)，类似银行U盾
	- Front Proxy直接以TCP Proxy的代理模式，在下游客户端与上游服务端之间透传tls协议
	  - https -> passthrough
	  - 集群内部的东西向流量同样工作于https协议模型
	  
#docker-compose运行示例，使用方法见~/servicemesh_in_practise/Security/tls-static/README.md
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# cat docker-compose.yaml		#docker-compose文件
version: '3.3'

services:
  front-envoy:
    image: envoyproxy/envoy-alpine:v1.20.0
    volumes:
      - ./front-envoy.yaml:/etc/envoy/envoy.yaml
      - ./certs/front-envoy/:/etc/envoy/certs/
      - ./certs/CA/:/etc/envoy/ca/
    networks:
      envoymesh:
        ipv4_address: 172.31.90.10
        aliases:
        - front-envoy
    expose:
      # Expose ports 80 (for general traffic) and 9901 (for the admin server)
      - "80"
      - "443"
      - "9901"
    ports:
      - "8080:80"
      - "8443:443"
      - "9901:9901"

  blue:
    image: ikubernetes/servicemesh-app:latest
    networks:
      envoymesh:
        aliases:
          - myservice
          - service-blue
          - blue
    environment:
      - SERVICE_NAME=blue
    expose:
      - "80"

  green:
    image: ikubernetes/servicemesh-app:latest
    networks:
      envoymesh:
        aliases:
          - myservice
          - service-green
          - green
    environment:
      - SERVICE_NAME=green
    expose:
      - "80"

  red:
    image: ikubernetes/servicemesh-app:latest
    networks:
      envoymesh:
        aliases:
          - myservice
          - service-red
          - red
    environment:
      - SERVICE_NAME=red
    expose:
      - "80"

  gray:
    image: ikubernetes/servicemesh-app:latest
    volumes:
      - ./service-gray.yaml:/etc/envoy/envoy.yaml
      - ./certs/service-gray/:/etc/envoy/certs/
    networks:
      envoymesh:
        ipv4_address: 172.31.90.15
        aliases:
          - gray
          - service-gray
    environment:
      - SERVICE_NAME=gray
    expose:
      - "80"
      - "443"

  purple:
    image: ikubernetes/servicemesh-app:latest
    volumes:
      - ./service-purple.yaml:/etc/envoy/envoy.yaml
      - ./certs/service-purple/:/etc/envoy/certs/
      - ./certs/CA/:/etc/envoy/ca/
    networks:
      envoymesh:
        ipv4_address: 172.31.90.16
        aliases:
          - purple
          - service-purple
    environment:
      - SERVICE_NAME=purple
    expose:
      - "80"
      - "443"

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.90.0/24
---
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# cat service-gray.yaml		#3个envoy相关配置文件
admin:
  access_log_path: "/dev/null"
  address:
    socket_address:
      address: 0.0.0.0
      port_value: 9901

static_resources:
  listeners:
  - name: listener_http
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 80
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          codec_type: auto
          stat_prefix: ingress_http
          access_log:
          - name: envoy.access_loggers.file
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.access_loggers.file.v3.FileAccessLog
              path: "/dev/stdout"
          route_config:
            name: local_route
            virtual_hosts:
            - name: service
              domains:
              - "*"
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: local_service
          http_filters:
          - name: envoy.filters.http.router
            typed_config: {}

  - name: listener_https
    address:
      socket_address: { address: 0.0.0.0, port_value: 443 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_https
          codec_type: AUTO
          access_log:
          - name: envoy.access_loggers.file
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.access_loggers.file.v3.FileAccessLog
              path: "/dev/stdout"
          route_config:
            name: https_route
            virtual_hosts:
            - name: https_route
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: local_service
          http_filters:
          - name: envoy.filters.http.router
            typed_config: {}
      transport_socket:  # DownstreamTlsContext
        name: envoy.transport_sockets.tls
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.DownstreamTlsContext
          common_tls_context:
            tls_certificates:    # 基于DataSource，直接给出证书和私钥文件
              certificate_chain:
                filename: "/etc/envoy/certs/server.crt"
              private_key:
                filename: "/etc/envoy/certs/server.key"

  clusters:
  - name: local_service
    connect_timeout: 0.25s
    type: strict_dns
    lb_policy: round_robin
    load_assignment:
      cluster_name: local_service
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: 127.0.0.1
                port_value: 8080
---
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# cat service-purple.yaml
admin:
  access_log_path: "/dev/null"
  address:
    socket_address:
      address: 0.0.0.0
      port_value: 9901

static_resources:
  listeners:
  - name: listener_http
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 80
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          codec_type: auto
          stat_prefix: ingress_http
          access_log:
          - name: envoy.access_loggers.file
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.access_loggers.file.v3.FileAccessLog
              path: "/dev/stdout"
          route_config:
            name: local_route
            virtual_hosts:
            - name: service
              domains:
              - "*"
              routes:
              - match:
                  prefix: "/"
                redirect:
                  https_redirect: true
                  port_redirect: 443
          http_filters:
          - name: envoy.filters.http.router
            typed_config: {}

  - name: listener_https
    address:
      socket_address: { address: 0.0.0.0, port_value: 443 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_https
          codec_type: AUTO
          access_log:
          - name: envoy.access_loggers.file
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.access_loggers.file.v3.FileAccessLog
              path: "/dev/stdout"
          route_config:
            name: https_route
            virtual_hosts:
            - name: https_route
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: local_service
          http_filters:
          - name: envoy.filters.http.router
            typed_config: {}
      transport_socket:  # DownstreamTlsContext
        name: envoy.transport_sockets.tls
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.DownstreamTlsContext
          common_tls_context:
            tls_certificates:    # 基于DataSource，直接给出证书和私钥文件
              certificate_chain:
                filename: "/etc/envoy/certs/server.crt"
              private_key:
                filename: "/etc/envoy/certs/server.key"
          require_client_certificate: true   # 强制验证客户端证书

  clusters:
  - name: local_service
    connect_timeout: 0.25s
    type: strict_dns
    lb_policy: round_robin
    load_assignment:
      cluster_name: local_service
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: 127.0.0.1
                port_value: 8080
---
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# cat front-envoy.yaml
node:
  id: front-envoy
  cluster: front-envoy

admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

layered_runtime:
  layers:
  - name: admin
    admin_layer: {}

static_resources:
  secrets:
  - name: server_cert
    tls_certificate:
      certificate_chain:
        filename: "/etc/envoy/certs/server.crt"
      private_key:
        filename: "/etc/envoy/certs/server.key"
  - name: client_cert
    tls_certificate:
      certificate_chain:
        filename: "/etc/envoy/certs/client.crt"
      private_key:
        filename: "/etc/envoy/certs/client.key"
  - name: validation_context
    validation_context:
      trusted_ca:
        filename: "/etc/envoy/ca/ca.crt"

  listeners:
  - name: listener_http
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 80
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          codec_type: auto
          stat_prefix: ingress_http
          access_log:
          - name: envoy.access_loggers.file
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.access_loggers.file.v3.FileAccessLog
              path: "/dev/stdout"
          route_config:
            name: local_route
            virtual_hosts:
            - name: backend
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                redirect:
                  https_redirect: true
                  port_redirect: 443
          http_filters:
          - name: envoy.filters.http.router
            typed_config: {}

  - name: listener_https
    address:
      socket_address: { address: 0.0.0.0, port_value: 443 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_https
          codec_type: AUTO
          access_log:
          - name: envoy.access_loggers.file
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.access_loggers.file.v3.FileAccessLog
              path: "/dev/stdout"
          route_config:
            name: https_route
            virtual_hosts:
            - name: https_route
              domains: ["*"]
              routes:
              - match:
                  prefix: "/service/gray"
                route:
                  cluster: service-gray
              - match:
                  prefix: "/service/purple"
                route:
                  cluster: service-purple
              - match:
                  prefix: "/"
                route:
                  cluster: mycluster
          http_filters:
          - name: envoy.filters.http.router
            typed_config: {}
      transport_socket:  # DownstreamTlsContext
        name: envoy.transport_sockets.tls
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.DownstreamTlsContext
          common_tls_context:
            tls_certificate_sds_secret_configs:
            - name: server_cert

  clusters:
  - name: mycluster
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: mycluster
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: myservice
                port_value: 80

  - name: service-gray
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: service-gray
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: service-gray
                port_value: 443
    transport_socket:
      name: envoy.transport_sockets.tls
      typed_config:
        "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext
        common_tls_context:
          validation_context_sds_secret_config:
            name: validation_context

  - name: service-purple
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: service-purple
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: service-purple
                port_value: 443
    transport_socket:
      name: envoy.transport_sockets.tls
      typed_config:
        "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext
        common_tls_context:
          tls_certificate_sds_secret_configs:
          - name: client_cert
          validation_context_sds_secret_config:
            name: validation_context
---
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# cat openssl.conf	#生成证书需要的openssl配置文件
# environment variable values
BASE_DOMAIN=ilinux.io
CERT_DIR=

[ ca ]
# `man ca`
default_ca = CA_default

[ CA_default ]
# Directory and file locations.
dir               = ${ENV::CERT_DIR}
certs             = $dir
crl_dir           = $dir/crl
new_certs_dir     = $dir
database          = $dir/index.txt
serial            = $dir/serial
# certificate revocation lists.
crlnumber         = $dir/crlnumber
crl               = $dir/crl/intermediate-ca.crl
crl_extensions    = crl_ext
default_crl_days  = 30
default_md        = sha256

name_opt          = ca_default
cert_opt          = ca_default
default_days      = 375
preserve          = no
policy            = policy_loose

[ policy_loose ]
# Allow the CA to sign a range of certificates.
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ req ]
# `man req`
default_bits        = 4096
distinguished_name  = req_distinguished_name
string_mask         = utf8only
default_md          = sha256

[ req_distinguished_name ]
countryName                    = Country Name (2 letter code)
stateOrProvinceName            = State or Province Name
localityName                   = Locality Name
0.organizationName             = Organization Name
organizationalUnitName         = Organizational Unit Name
commonName                     = Common Name

# Certificate extensions (`man x509v3_config`)

[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ client_cert ]
basicConstraints = CA:FALSE
nsCertType = client
nsComment = "OpenSSL Generated Client Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth

[ server_cert ]
basicConstraints = CA:FALSE
nsCertType = server
nsComment = "OpenSSL Generated Server Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[ envoy_server_cert ]
basicConstraints = CA:FALSE
nsCertType = server
nsComment = "OpenSSL Generated Server Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
#subjectAltName = DNS.1:*.${ENV::BASE_DOMAIN}

[ peer_cert ]
basicConstraints = CA:FALSE
nsCertType = server
nsComment = "OpenSSL Generated Server Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = DNS.1:*.${ENV::BASE_DOMAIN}

[ envoy_client_cert ]
basicConstraints = CA:FALSE
nsCertType = client
nsComment = "OpenSSL Generated Client Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth
---
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# cat gencerts.sh		#生成证书脚本
#!/bin/bash -e

function usage() {
    >&2 cat << EOF
Usage: ./envoy-certs-gen.sh
Set the following environment variables to run this script:
    BASE_DOMAIN     Base domain name of the cluster. For example if your API
                    server is running on "my-cluster-k8s.example.com", the
                    base domain is "example.com"
    CA_CERT(optional)         Path to the pem encoded CA certificate of your cluster.
    CA_KEY(optional)          Path to the pem encoded CA key of your cluster.
EOF
    exit 1
}

BASE_DOMAIN=ilinux.io

if [ -z $BASE_DOMAIN ]; then
    usage
fi

export DIR="certs"
if [ $# -eq 1 ]; then
    DIR="$1"
fi

export CERT_DIR=$DIR
[ ! -e $CERT_DIR ] && mkdir -p $CERT_DIR

CA_CERT="$CERT_DIR/CA/ca.crt"
CA_KEY="$CERT_DIR/CA/ca.key"

# Configure expected OpenSSL CA configs.

touch $CERT_DIR/index
touch $CERT_DIR/index.txt
touch $CERT_DIR/index.txt.attr
echo 1000 > $CERT_DIR/serial
# Sign multiple certs for the same CN
echo "unique_subject = no" > $CERT_DIR/index.txt.attr

function openssl_req() {
    openssl genrsa -out ${1}/${2}.key 2048
    echo "Generating ${1}/${2}.csr"
    openssl req -config openssl.conf -new -sha256 \
        -key ${1}/${2}.key -out ${1}/${2}.csr -subj "$3"
}

function openssl_sign() {
    echo "Generating ${3}/${4}.crt"
    openssl ca -batch -config openssl.conf -extensions ${5} -days 3650 -notext \
        -md sha256 -in ${3}/${4}.csr -out ${3}/${4}.crt \
        -cert ${1} -keyfile ${2}
}

if [ ! -e "$CA_KEY" -o ! -e "$CA_CERT" ]; then
    mkdir $CERT_DIR/CA
    openssl genrsa -out $CERT_DIR/CA/ca.key 4096
    openssl req -config openssl.conf \
        -new -x509 -days 3650 -sha256 \
        -key $CERT_DIR/CA/ca.key -extensions v3_ca \
        -out $CERT_DIR/CA/ca.crt -subj "/CN=envoy-ca"
    export CA_KEY="$CERT_DIR/CA/ca.key"
    export CA_CERT="$CERT_DIR/CA/ca.crt"
fi

read -p "Certificate Name and Certificate Extenstions(envoy_server_cert/envoy_client_cert): " CERT EXT
while [ -n "$CERT" -a -n "$EXT" ]; do
    [ ! -e $CERT_DIR/$CERT ] && mkdir $CERT_DIR/$CERT
    if [ "$EXT" == "envoy_server_cert" ]; then
        openssl_req $CERT_DIR/$CERT server "/CN=$CERT"
        openssl_sign $CERT_DIR/CA/ca.crt $CERT_DIR/CA/ca.key $CERT_DIR/$CERT server $EXT
    else
        openssl_req $CERT_DIR/$CERT client "/CN=$CERT"
        openssl_sign $CERT_DIR/CA/ca.crt $CERT_DIR/CA/ca.key $CERT_DIR/$CERT client $EXT
    fi
    read -p "Certificate Name and Certificate Extenstions(envoy_server_cert/envoy_client_cert): " CERT EXT
done

# Add debug information to directories
#for CERT in $CERT_DIR/*; do
#    [ -d $CERT ] && openssl x509 -in $CERT/*.crt -noout -text > "${CERT%.crt}.txt"
#done

# Clean up openssl config
rm $CERT_DIR/index*
rm $CERT_DIR/100*
rm $CERT_DIR/serial*
for CERT in $CERT_DIR/*; do
    [ -d $CERT ] && rm -f $CERT/*.csr
done
---生成证书，名称都是固定的，不能改变
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# ./gencerts.sh
Certificate Name and Certificate Extenstions(envoy_server_cert/envoy_client_cert): front-envoy envoy_server_cert		#front-envoy表示新建的目录，envoy_server_cert表示服务端证书，envoy_client_cert表示客户端证书
Certificate Name and Certificate Extenstions(envoy_server_cert/envoy_client_cert): front-envoy envoy_client_cert
Certificate Name and Certificate Extenstions(envoy_server_cert/envoy_client_cert): service-gray envoy_server_cert
Certificate Name and Certificate Extenstions(envoy_server_cert/envoy_client_cert): service-purple envoy_server_cert
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# tree certs/
certs/
|-- CA
|   |-- ca.crt
|   `-- ca.key
|-- front-envoy
|   |-- client.crt
|   |-- client.key
|   |-- server.crt
|   `-- server.key
|-- service-gray
|   |-- server.crt
|   `-- server.key
`-- service-purple
    |-- server.crt
    `-- server.key
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# chown -R 100.101 certs/
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# docker-compose up		#启动
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# curl 172.31.90.10:9901/listeners		#列出侦听器
listener_http::0.0.0.0:80
listener_https::0.0.0.0:443
root@front-envoy:~/servicemesh_in_practise/Security/tls-static#     curl 172.31.90.10:9901/certs		#列出front-envoy的证书
{
 "certificates": [
  {
   "ca_cert": [
    {
     "path": "/etc/envoy/ca/ca.crt",
     "serial_number": "2e83ac398058147270321e1ac3eef856024ecb3b",
     "subject_alt_names": [],
     "days_until_expiration": "3649",
     "valid_from": "2022-04-13T09:00:43Z",
     "expiration_time": "2032-04-10T09:00:43Z"
    }
   ],
   "cert_chain": []
  },
  {
   "ca_cert": [
    {
     "path": "/etc/envoy/ca/ca.crt",
     "serial_number": "2e83ac398058147270321e1ac3eef856024ecb3b",
     "subject_alt_names": [],
     "days_until_expiration": "3649",
     "valid_from": "2022-04-13T09:00:43Z",
     "expiration_time": "2032-04-10T09:00:43Z"
    }
   ],
   "cert_chain": [
    {
     "path": "/etc/envoy/certs/client.crt",
     "serial_number": "1001",
     "subject_alt_names": [],
     "days_until_expiration": "3649",
     "valid_from": "2022-04-13T09:01:28Z",
     "expiration_time": "2032-04-10T09:01:28Z"
    }
   ]
  },
  {
   "ca_cert": [],
   "cert_chain": [
    {
     "path": "/etc/envoy/certs/server.crt",
     "serial_number": "1000",
     "subject_alt_names": [],
     "days_until_expiration": "3649",
     "valid_from": "2022-04-13T09:01:00Z",
     "expiration_time": "2032-04-10T09:01:00Z"
    }
   ]
  }
 ]
}
---列出后面服务的侦听器和certs
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# curl 172.31.90.15:9901/listeners
listener_http::0.0.0.0:80
listener_https::0.0.0.0:443
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# curl 172.31.90.16:9901/listeners
listener_http::0.0.0.0:80
listener_https::0.0.0.0:443
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# curl 172.31.90.15:9901/certs
{
 "certificates": [
  {
   "ca_cert": [],
   "cert_chain": [
    {
     "path": "/etc/envoy/certs/server.crt",
     "serial_number": "1002",
     "subject_alt_names": [],
     "days_until_expiration": "3649",
     "valid_from": "2022-04-13T09:01:49Z",
     "expiration_time": "2032-04-10T09:01:49Z"
    }
   ]
  }
 ]
}
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# curl 172.31.90.16:9901/certs
{
 "certificates": [
  {
   "ca_cert": [],
   "cert_chain": [
    {
     "path": "/etc/envoy/certs/server.crt",
     "serial_number": "1003",
     "subject_alt_names": [],
     "days_until_expiration": "3649",
     "valid_from": "2022-04-13T09:02:00Z",
     "expiration_time": "2032-04-10T09:02:00Z"
    }
   ]
  }
 ]
}
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# curl -I 172.31.90.10/ #直接向front-envoy发起的http请求，将会被自动跳转至https服务上。
HTTP/1.1 301 Moved Permanently
location: https://172.31.90.10:443/
date: Wed, 13 Apr 2022 09:08:11 GMT
server: envoy
transfer-encoding: chunked

root@front-envoy:~/servicemesh_in_practise/Security/tls-static# openssl s_client -connect 172.31.90.10:443	#https侦听器监听的443端口也能够正常接收客户端访问，这里可以直接使用openssl s_client命令进行测试。
CONNECTED(00000005)
depth=0 CN = front-envoy
verify error:num=20:unable to get local issuer certificate
verify return:1
depth=0 CN = front-envoy
verify error:num=21:unable to verify the first certificate
verify return:1
---
Certificate chain
 0 s:CN = front-envoy
   i:CN = envoy-ca
---
Server certificate
-----BEGIN CERTIFICATE-----
MIIEkDCCAnigAwIBAgICEAAwDQYJKoZIhvcNAQELBQAwEzERMA8GA1UEAww
.....
----请求front-envoy 443端口，默认转发到后端red,green,blue服务器
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# curl -k https://172.31.90.10
Hello from App behind Envoy! Hostname: 12f307104428, Address: 172.31.90.4!
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# curl -k https://172.31.90.10
Hello from App behind Envoy! Hostname: 08facbdadc4c, Address: 172.31.90.2!
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# curl -k https://172.31.90.10
Hello from App behind Envoy! Hostname: a12b452cb368, Address: 172.31.90.3!
----请求service-gray 443端口，默认转发到后端service-gray服务器
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# curl -k https://172.31.90.10/service/gray
Hello from App behind Envoy (service gray)! hostname: 20045f5fcd90 resolved hostname: 172.31.90.15
----请求service-purple 443端口，默认转发到后端service-purple服务器
root@front-envoy:~/servicemesh_in_practise/Security/tls-static#    curl -k https://172.31.90.10/service/purple
Hello from App behind Envoy (service purple)! hostname: 516e9e2b4679 resolved hostname: 172.31.90.16
----从front-envoy的日志信息中可以看出，它向上游的gray或者purple发起请求时，使用的都是https连接。
front-envoy_1  | [2022-04-13T09:15:06.940Z] "GET / HTTP/1.1" 200 - 0 75 1004 1004 "-" "curl/7.58.0" "a3dcfb85-0499-4a2c-a216-ee1858805d2c" "172.31.90.10" "172.31.90.4:80"
front-envoy_1  | [2022-04-13T09:15:09.073Z] "GET / HTTP/1.1" 200 - 0 75 1004 1004 "-" "curl/7.58.0" "1d996a02-4513-4f37-8149-8e56770d43c8" "172.31.90.10" "172.31.90.2:80"
front-envoy_1  | [2022-04-13T09:15:11.052Z] "GET / HTTP/1.1" 200 - 0 75 1007 1006 "-" "curl/7.58.0" "14c2a4d4-deea-4642-aa61-31c0ede085a2" "172.31.90.10" "172.31.90.3:80"
front-envoy_1  | [2022-04-13T09:11:18.214Z] "GET /service/gray HTTP/1.1" 200 - 0 99 47 46 "-" "curl/7.58.0" "d3ffcfb4-d549-47e3-b6fa-fd2db8abc06f" "172.31.90.10" "172.31.90.15:443"
front-envoy_1  | [2022-04-13T09:11:24.755Z] "GET /service/purple HTTP/1.1" 200 - 0 101 8 8 "-" "curl/7.58.0" "c98bc5a5-aa28-415b-b670-a88207f2fc57" "172.31.90.10" "172.31.90.16:443"
	

#请求流程
request -> listener过滤器 -> listener(Ingress) -> L4 filter chains -> L7 filter chains -> route -> cluster     ->      eds
              |----------------------------------------------------------------------------------------|		  sidecar-proxy
														front-proxy

注：基于route可以调度到cluster，在front-proxy可以实现流量镜像(复制同一份流量到新cluster)、流量分割(基于流量优先级)、故障注入(调试超时、重连等机制)


####xDS API与动态配置
#动态配置
- xDS API为Envoy提供了资源的动态配置机制，它也被称为Data Plane API
- Envoy支持三种类型的配置信息的动态发现机制，相关的发现服务及其相应的API联合起来称为xDS API
  - 基于文件系统发现：指定要监视的文件系统路径
  - 通过查询一到多个管理服务器(Management Server)发现：通过DiscoveryRequest协议报文发送请求，并要求服务方以DiscoveryResponse协议报文进行响应
    - gRPC服务：启动gRPC流，效率高
	- REST服务：轮询REST-JSON URL，效率低
- v3 xDS支持如下几种资源类型：
  - envoy.config.listener.v3.Listener					#LDS
  - envoy.config.listener.v3.RouteConfiguration			#RDS
  - envoy.config.listener.v3.ScopeRouteConfiguration	#SRDS
  - envoy.config.listener.v3.VirtualHost				#VHDS
  - envoy.config.listener.v3.Cluster					#CDS
  - envoy.config.listener.v3.ClusterLoadAssignment		#EDS
  - envoy.config.listener.v3.Secret						#SDS
  - envoy.config.listener.v3.Runtime					#RTDS
#xDS API概述
- Envoy对xDS API的管理由后端服务器实现，包括LDS,CDS,RDS,SRDS,VHDS,EDS,SDS,RTDS等
  - 所有这些API都提供了最终的一致性，并且彼此间不存在相互影响
  - 部分更高级别的操作（例如执行服务的A/B部署）需要进行排序以防止流量被丢弃，因此，基于一个管理服务器提供多类API时还需要使用聚合发现服务（ADS）API
    - ADS API允许所有其他AIP通过来自单个管理服务器的单个gRPC双向流进行编组，从而允许对操作进行确定性排序
  - 另外，xDS的各API还支持增量传输机制，包括ADS
#Bootstrap node配置段
- 一个Management Server实例可能需要同时响应多个不同的Envoy实例的资源发现请求
  - Management Server上的配置需要为适配到不同的Envoy实例
  - Envoy实例请求发现配置时，需要在请求报文中上报自身的信息
    - 例如id,cluster,metadata和locality等
	- 这些配置信息定义在Bootstrap配置文件中
	  - 专用的顶级配置段"node"
#API流程
- 对于典型的HTTP路由方案，xDS API的Management Server需要为其客户端（Envoy实例）配置的核心资源类型为Listener、RouteConfiguration、Cluster和ClusterLoadAssignment四个
  - 每个Listener资源可以指向一个RouteConfiguration资源，该资源可以指向一个或多个Cluster资源，并且每个Cluster资源可以指向一个ClusterLoadAssignment资源
- Envoy实例在启动时请求加载所有Listener和Cluster资源，而后，再获取由这些Listener和Cluster所依赖的RouteConfiguration和ClusterLoadAssignment配置
  - 此种场景中，Listener资源和Cluster资源分别代表着客户端配置树上的"根(root)"配置，Listener是RouteConfiguration的根，Cluster是ClusterLoadAssignment的根，因而可并行加载
- 但是，类似gRPC一类的非代理式客户端可以仅在启动时请求加载其感兴趣的Listener资源，而后再加载这些特定Listener相关的RouteConfiguration资源，再然后，是这些RouteConfiguration资源指向的Cluster资源，以及由这些Cluster资源依赖的ClusterLoadAssignment资源
  - 该种场景中，Listener资源是客户端整个配置树的"根"
#Envoy资源的配置源
- 配置源(ConfigSource)用于指定资源配置数据的来源，用于为Listener、Cluster、Route、Endpoint、Secret、和VirtualHost等资源提供配置数据
- 目前，Envoy支持的资源配置源只能是path,api_config_source或ads其中之一
  - path：通过文件系统路径来发现
  - api_config_source：通过指定api_type来决定使用何种api，api_type有REST-JSON API, GRPC API, DATA GRPC(增量GRPC)
  - ads：可以有多种组合，例如LDS,RDS,CDS等
- api_config_source或ads的数据来自于xDS API Server，即Management Server

#配置示例：基于文件系统订阅（EDS）
cluster:
- name:
  ...
  eds_cluster_config:
    service_name:
	eds_config:
	  path: ...  		#ConfigSource，支持使用path, api_config_source或ads三者之一
注：基于文件系统的eds，文件/etc/envoy/eds.yaml，提示：文件后缀名为conf，则资源要以json格式定义；文件后缀名为yaml，则资源以yaml格式定义；另外，动态配置中，各Envoy实例需要有惟一的id标识，linux基于inotify来发现文件更新

#docker-compose配置示例
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/eds-filesystem# cat docker-compose.yaml
version: '3.3'

services:
  envoy:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./front-envoy.yaml:/etc/envoy/envoy.yaml
    - ./eds.conf.d/:/etc/envoy/eds.conf.d/
    networks:
      envoymesh:
        ipv4_address: 172.31.11.2
        aliases:
        - front-proxy
    depends_on:
    - webserver01-sidecar
    - webserver02-sidecar

  webserver01-sidecar:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./envoy-sidecar-proxy.yaml:/etc/envoy/envoy.yaml
    hostname: webserver01
    networks:
      envoymesh:
        ipv4_address: 172.31.11.11
        aliases:
        - webserver01-sidecar

  webserver01:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
      - HOST=127.0.0.1
    network_mode: "service:webserver01-sidecar"
    depends_on:
    - webserver01-sidecar

  webserver02-sidecar:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./envoy-sidecar-proxy.yaml:/etc/envoy/envoy.yaml
    hostname: webserver02
    networks:
      envoymesh:
        ipv4_address: 172.31.11.12
        aliases:
        - webserver02-sidecar

  webserver02:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
      - HOST=127.0.0.1
    network_mode: "service:webserver02-sidecar"
    depends_on:
    - webserver02-sidecar

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.11.0/24
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/eds-filesystem# cat front-envoy.yaml
node:
  id: envoy_front_proxy
  cluster: MageEdu_Cluster

admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: web_service_01
              domains: ["*"]
              routes:
              - match: { prefix: "/" }
                route: { cluster: webcluster }
          http_filters:
          - name: envoy.filters.http.router

  clusters:
  - name: webcluster
    connect_timeout: 0.25s
    type: EDS						#这里是启用EDS
    lb_policy: ROUND_ROBIN
    eds_cluster_config:				#EDS开始配置
      service_name: webcluster
      eds_config:
        path: '/etc/envoy/eds.conf.d/eds.yaml'			#path表示是基于文件系统的服务发现
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/eds-filesystem# cat envoy-sidecar-proxy.yaml
admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: local_service
              domains: ["*"]
              routes:
              - match: { prefix: "/" }
                route: { cluster: local_cluster }
          http_filters:
          - name: envoy.filters.http.router

  clusters:
  - name: local_cluster
    connect_timeout: 0.25s
    type: STATIC
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: local_cluster
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address: { address: 127.0.0.1, port_value: 8080 }
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/eds-filesystem# cat eds.conf.d/eds.yaml
resources:
- "@type": type.googleapis.com/envoy.config.endpoint.v3.ClusterLoadAssignment
  cluster_name: webcluster
  endpoints:
  - lb_endpoints:
    - endpoint:
        address:
          socket_address:
            address: 172.31.11.11
            port_value: 80
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/eds-filesystem# cat eds.conf.d/eds.yaml.v2
version_info: '2'
resources:
- "@type": type.googleapis.com/envoy.config.endpoint.v3.ClusterLoadAssignment
  cluster_name: webcluster
  endpoints:
  - lb_endpoints:
    - endpoint:
        address:
          socket_address:
            address: 172.31.11.11
            port_value: 80
    - endpoint:
        address:
          socket_address:
            address: 172.31.11.12
            port_value: 80
----运行测试 
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/eds-filesystem# docker-compose up 
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/eds-filesystem# curl 172.31.11.2:9901/listeners
listener_0::0.0.0.0:80
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/eds-filesystem# curl 172.31.11.2:9901/clusters
webcluster::observability_name::webcluster
webcluster::default_priority::max_connections::1024
webcluster::default_priority::max_pending_requests::1024
webcluster::default_priority::max_requests::1024
webcluster::default_priority::max_retries::3
webcluster::high_priority::max_connections::1024
webcluster::high_priority::max_pending_requests::1024
webcluster::high_priority::max_requests::1024
webcluster::high_priority::max_retries::3
webcluster::added_via_api::false
webcluster::172.31.11.11:8080::cx_active::0
webcluster::172.31.11.11:8080::cx_connect_fail::1
webcluster::172.31.11.11:8080::cx_total::1
webcluster::172.31.11.11:8080::rq_active::0
webcluster::172.31.11.11:8080::rq_error::1
webcluster::172.31.11.11:8080::rq_success::0
webcluster::172.31.11.11:8080::rq_timeout::0
webcluster::172.31.11.11:8080::rq_total::0
webcluster::172.31.11.11:8080::hostname::
webcluster::172.31.11.11:8080::health_flags::healthy
webcluster::172.31.11.11:8080::weight::1
webcluster::172.31.11.11:8080::region::
webcluster::172.31.11.11:8080::zone::
webcluster::172.31.11.11:8080::sub_zone::
webcluster::172.31.11.11:8080::canary::false
webcluster::172.31.11.11:8080::priority::0
webcluster::172.31.11.11:8080::success_rate::-1.0
webcluster::172.31.11.11:8080::local_origin_success_rate::-1.0
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/eds-filesystem# curl 172.31.11.2	#此时只有172.31.11.11
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.1, ServerName: webserver01, ServerIP: 172.31.11.11!
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/eds-filesystem# docker-compose exec envoy /bin/sh
/etc/envoy/eds.conf.d # vim eds.yaml			#增加1个endpoint 172.31.11.12
resources:
- "@type": type.googleapis.com/envoy.config.endpoint.v3.ClusterLoadAssignment
  cluster_name: webcluster
  endpoints:
  - lb_endpoints:
    - endpoint:
        address:
          socket_address:
            address: 172.31.11.11
            port_value: 80
    - endpoint:
        address:
          socket_address:
            address: 172.31.11.12
            port_value: 80

/etc/envoy/eds.conf.d # mv eds.yaml bak			#在容器里面，看到的内核视图不是宿主机的内核视图，所以需要强制触发inotify，让宿主机内核视图发现
/etc/envoy/eds.conf.d # mv bak eds.yaml
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/eds-filesystem# curl 172.31.11.2:9901/clusters		#此时发现了172.31.11.12
webcluster::observability_name::webcluster
webcluster::default_priority::max_connections::1024
webcluster::default_priority::max_pending_requests::1024
webcluster::default_priority::max_requests::1024
webcluster::default_priority::max_retries::3
webcluster::high_priority::max_connections::1024
webcluster::high_priority::max_pending_requests::1024
webcluster::high_priority::max_requests::1024
webcluster::high_priority::max_retries::3
webcluster::added_via_api::false
webcluster::172.31.11.11:80::cx_active::2
webcluster::172.31.11.11:80::cx_connect_fail::0
webcluster::172.31.11.11:80::cx_total::2
webcluster::172.31.11.11:80::rq_active::0
webcluster::172.31.11.11:80::rq_error::0
webcluster::172.31.11.11:80::rq_success::3
webcluster::172.31.11.11:80::rq_timeout::0
webcluster::172.31.11.11:80::rq_total::3
webcluster::172.31.11.11:80::hostname::
webcluster::172.31.11.11:80::health_flags::healthy
webcluster::172.31.11.11:80::weight::1
webcluster::172.31.11.11:80::region::
webcluster::172.31.11.11:80::zone::
webcluster::172.31.11.11:80::sub_zone::
webcluster::172.31.11.11:80::canary::false
webcluster::172.31.11.11:80::priority::0
webcluster::172.31.11.11:80::success_rate::-1.0
webcluster::172.31.11.11:80::local_origin_success_rate::-1.0
webcluster::172.31.11.12:80::cx_active::0
webcluster::172.31.11.12:80::cx_connect_fail::0
webcluster::172.31.11.12:80::cx_total::0
webcluster::172.31.11.12:80::rq_active::0
webcluster::172.31.11.12:80::rq_error::0
webcluster::172.31.11.12:80::rq_success::0
webcluster::172.31.11.12:80::rq_timeout::0
webcluster::172.31.11.12:80::rq_total::0
webcluster::172.31.11.12:80::hostname::
webcluster::172.31.11.12:80::health_flags::healthy
webcluster::172.31.11.12:80::weight::1
webcluster::172.31.11.12:80::region::
webcluster::172.31.11.12:80::zone::
webcluster::172.31.11.12:80::sub_zone::
webcluster::172.31.11.12:80::canary::false
webcluster::172.31.11.12:80::priority::0
webcluster::172.31.11.12:80::success_rate::-1.0
webcluster::172.31.11.12:80::local_origin_success_rate::-1.0
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/eds-filesystem# curl 172.31.11.2
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.1, ServerName: webserver01, ServerIP: 172.31.11.11!
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/eds-filesystem# curl 172.31.11.2		#也能访问到基于文件系统动态加载的endpoint了
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.1, ServerName: webserver02, ServerIP: 172.31.11.12!

#配置示例：基于文件系统发现订阅(LDS和CDS)
- 我们也可以基于lds和cds实现Envoy基本全动态的配置方式
  - 各Listener的定义以Discovery Response的标准格式积存于一个文件中
  - 各Cluster的定义同样以Discovery Response的标准格式积存于一个文件中
---
node:
  id: envoy_front_proxy
  cluster: Magedu_Cluster

admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
      address: 0.0.0.0
      port_value: 9901

dynamic_resource:
  lds_config:
    path: /etc/envoy/conf.d/lds.yaml
  cds_config:	
	path: /etc/envoy/conf.d/cds.yaml
 ---
#docker-compose运行示例
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/lds-cds-filesystem# cat docker-compose.yaml
version: '3.3'

services:
  envoy:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./front-envoy.yaml:/etc/envoy/envoy.yaml
    - ./conf.d/:/etc/envoy/conf.d/
    networks:
      envoymesh:
        ipv4_address: 172.31.12.2
        aliases:
        - front-proxy
    depends_on:
    - webserver01
    - webserver01-app
    - webserver02
    - webserver02-app

  webserver01:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./envoy-sidecar-proxy.yaml:/etc/envoy/envoy.yaml
    hostname: webserver01
    networks:
      envoymesh:
        ipv4_address: 172.31.12.11
        aliases:
        - webserver01-sidecar

  webserver01-app:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
      - HOST=127.0.0.1
    network_mode: "service:webserver01"
    depends_on:
    - webserver01

  webserver02:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./envoy-sidecar-proxy.yaml:/etc/envoy/envoy.yaml
    hostname: webserver02
    networks:
      envoymesh:
        ipv4_address: 172.31.12.12
        aliases:
        - webserver02-sidecar

  webserver02-app:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
      - HOST=127.0.0.1
    network_mode: "service:webserver02"
    depends_on:
    - webserver02

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.12.0/24
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/lds-cds-filesystem# cat front-envoy.yaml
node:
  id: envoy_front_proxy
  cluster: MageEdu_Cluster

admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

dynamic_resources:
  lds_config:
    path: /etc/envoy/conf.d/lds.yaml
  cds_config:
    path: /etc/envoy/conf.d/cds.yaml
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/lds-cds-filesystem# cat envoy-sidecar-proxy.yaml	#sidecar Ingress
admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: local_service
              domains: ["*"]
              routes:
              - match: { prefix: "/" }
                route: { cluster: local_cluster }
          http_filters:
          - name: envoy.filters.http.router

  clusters:
  - name: local_cluster
    connect_timeout: 0.25s
    type: STATIC
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: local_cluster
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address: { address: 127.0.0.1, port_value: 8080 }
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/lds-cds-filesystem# cat conf.d/lds.yaml
resources:
- "@type": type.googleapis.com/envoy.config.listener.v3.Listener
  name: listener_http
  address:
    socket_address: { address: 0.0.0.0, port_value: 80 }
  filter_chains:
  - filters:
      name: envoy.http_connection_manager
      typed_config:
        "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
        stat_prefix: ingress_http
        route_config:
          name: local_route
          virtual_hosts:
          - name: local_service
            domains: ["*"]
            routes:
            - match:
                prefix: "/"
              route:
                cluster: webcluster
        http_filters:
        - name: envoy.filters.http.router
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/lds-cds-filesystem# cat conf.d/cds.yaml
resources:
- "@type": type.googleapis.com/envoy.config.cluster.v3.Cluster
  name: webcluster
  connect_timeout: 1s
  type: STRICT_DNS
  load_assignment:
    cluster_name: webcluster
    endpoints:
    - lb_endpoints:
      - endpoint:
          address:
            socket_address:
              address: webserver01
              port_value: 80
      - endpoint:
          address:
            socket_address:
              address: webserver02
              port_value: 80
---

#基于gRPC的动态配置格式
- 以LDS为例，它配置Listener以动态方式发现和加载，而内部的路由可由发现的Listener直接提供，也可配置再经由RDS发现
  - 下面为LDS配置格式，CDS等的配置格式类同
dynamic_resource:
  lds_config:
    api_type: ...				#API可经由REST或gRPC获取，支持的类型包括REST、gRPC和delta_gRPC
	resource_api_version: ...	#xDS资源的API版本，对于1.19及之后的Envoy版本，要使用v3，1.14-1.18支持v2和v3
	rate_limit_settings: {...}	#速率限制
	grpc_services:				#提供grpc服务的一到多个服务器
	  transport_api_version: ...#xDS传输协议使用的API版本，对于1.19及之后的Envoy版本，要使用v3
	  envoy_grpc:				#Envoy内建的grpc客户端，envoy_grpc和google_grpc二者仅能用其一
	    cluster_name: ...		#grpc集群的名称
      google_grpc:				#Google的C++ grpc客户端
	  timeout: ...				#gRPC超时时长
- 注意：提供gRPC API服务的Management Server（控制平面）也需要定义为Envoy上的集群，并由envoy实例通过xDS API进行请求
  - 通常，这些管理服务器需要以静态资源的格式提供
  - 类似于，DHCP协议的Server端的地址必须静态配置，而不能经由DHCP协议获取 
  
#配置示例：基于gRPC管理服务器订阅（LDS和CDS）  
- 基于gRPC的订阅功能需要向专用的Management Server请求配置信息
- 下面的示例配置使用了lds和cds分别动态获取Listener和Cluster相关的配置，front-envoy实现了LDS和CDS动态配置通过ManagementServer发现
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/lds-cds-grpc# cat docker-compose.yaml
version: '3.3'

services:
  envoy:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./front-envoy.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        ipv4_address: 172.31.15.2
        aliases:
        - front-proxy
    depends_on:
    - webserver01
    - webserver02
    - xdsserver

  webserver01:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
      - HOST=127.0.0.1
    hostname: webserver01
    networks:
      envoymesh:
        ipv4_address: 172.31.15.11

  webserver01-sidecar:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./envoy-sidecar-proxy.yaml:/etc/envoy/envoy.yaml
    network_mode: "service:webserver01"
    depends_on:
    - webserver01

  webserver02:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
      - HOST=127.0.0.1
    hostname: webserver02
    networks:
      envoymesh:
        ipv4_address: 172.31.15.12

  webserver02-sidecar:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./envoy-sidecar-proxy.yaml:/etc/envoy/envoy.yaml
    network_mode: "service:webserver02"
    depends_on:
    - webserver02

  xdsserver:																#自己构建的简单ManagementServer，为Envoy代理提供配置的
    image: ikubernetes/envoy-xds-server:v0.1
    environment:
      - SERVER_PORT=18000
      - NODE_ID=envoy_front_proxy
      - RESOURCES_FILE=/etc/envoy-xds-server/config/config.yaml
    volumes:
    - ./resources:/etc/envoy-xds-server/config/
    networks:
      envoymesh:
        ipv4_address: 172.31.15.5
        aliases:
        - xdsserver
        - xds-service
    expose:
    - "18000"

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.15.0/24
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/lds-cds-grpc# cat front-envoy.yaml		#front-envoy实现LDS和CDS通过ManagementServer动态配置
node:
  id: envoy_front_proxy
  cluster: webcluster

admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

dynamic_resources:
  lds_config:
    resource_api_version: V3
    api_config_source:
      api_type: GRPC
      transport_api_version: V3
      grpc_services:
      - envoy_grpc:
          cluster_name: xds_cluster				#Management Server的地址，在static_resources中定义

  cds_config:
    resource_api_version: V3
    api_config_source:
      api_type: GRPC
      transport_api_version: V3
      grpc_services:
      - envoy_grpc:
          cluster_name: xds_cluster

static_resources:
  clusters:
  - name: xds_cluster
    connect_timeout: 0.25s
    type: STRICT_DNS
    # The extension_protocol_options field is used to provide extension-specific protocol options for upstream connections.
    typed_extension_protocol_options:
      envoy.extensions.upstreams.http.v3.HttpProtocolOptions:
        "@type": type.googleapis.com/envoy.extensions.upstreams.http.v3.HttpProtocolOptions
        explicit_http_config:
          http2_protocol_options: {}
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: xds_cluster
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: xdsserver
                port_value: 18000						#xdsserver就是ManagermentServer
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/lds-cds-grpc# cat envoy-sidecar-proxy.yaml			#sidecar envoy配置
admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: local_service
              domains: ["*"]
              routes:
              - match: { prefix: "/" }
                route: { cluster: local_cluster }
          http_filters:
          - name: envoy.filters.http.router

  clusters:
  - name: local_cluster
    connect_timeout: 0.25s
    type: STATIC
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: local_cluster
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address: { address: 127.0.0.1, port_value: 8080 }
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/lds-cds-grpc# cat resources/config.yaml		#默认配置,xds-server会把格式转换为envoy的格式
name: myconfig
spec:
  listeners:
  - name: listener_http
    address: 0.0.0.0
    port: 80
    routes:
    - name: local_route
      prefix: /
      clusters:
      - webcluster
  clusters:
  - name: webcluster
    endpoints:
    - address: 172.31.15.11
      port: 8080
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/lds-cds-grpc# cat resources/config.yaml-v2
name: myconfig
spec:
  listeners:
  - name: listener_http
    address: 0.0.0.0
    port: 80
    routes:
    - name: local_route
      prefix: /
      clusters:
      - webcluster
  clusters:
  - name: webcluster
    endpoints:
    - address: 172.31.15.11
      port: 8080
    - address: 172.31.15.12
      port: 8080
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/lds-cds-grpc# docker-compose up		#启动
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/lds-cds-grpc# docker-compose exec xdsserver /bin/sh
se/Dynamic-Configuration/lds-cds-grpc# curl 172.31.15.2:9901/listeners
listener_http::0.0.0.0:80
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/lds-cds-grpc# curl -s 172.31.15.2:9901/config_dump | jq '.configs[1].dynamic_active_clusters'	#获取动态发现激的cluster
[
  {
    "version_info": "411",
    "cluster": {
      "@type": "type.googleapis.com/envoy.config.cluster.v3.Cluster",
      "name": "webcluster",										#发现了webclster
      "type": "EDS",
      "eds_cluster_config": {
        "eds_config": {
          "api_config_source": {
            "api_type": "GRPC",
            "grpc_services": [
              {
                "envoy_grpc": {
                  "cluster_name": "xds_cluster"					#上游服务是xds_cluster，就是Management Server
                }
              }
            ],
            "set_node_on_first_message_only": true,
            "transport_api_version": "V3"
          },
          "resource_api_version": "V3"
        }
      },
      "connect_timeout": "5s",
      "dns_lookup_family": "V4_ONLY"
    },
    "last_updated": "2022-04-15T05:32:36.625Z"
  }
]
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/lds-cds-grpc# curl -s 172.31.15.2:9901/clusters | grep -E 'webcluster::172.31.15.1[12]:8080::zone::'			#此时webcluster只有一个endpoint 
webcluster::172.31.15.11:8080::zone::
/etc/envoy-xds-server/config # cat config.yaml-v2 > config.yaml		#更改config.yaml配置
/etc/envoy-xds-server/config # cat config.yaml
name: myconfig
spec:
  listeners:
  - name: listener_http
    address: 0.0.0.0
    port: 80
    routes:
    - name: local_route
      prefix: /
      clusters:
      - webcluster
  clusters:
  - name: webcluster
    endpoints:
    - address: 172.31.15.11
      port: 8080
    - address: 172.31.15.12
      port: 8080
root@front-envoy:~/servicemesh_in_practise/Dynamic-Configuration/lds-cds-grpc# curl -s 172.31.15.2:9901/clusters | grep -E 'webcluster::172.31.15.1[12]:8080::zone::'		#立即生效，gRPC一直在watch自己的配置文件，一有变化立即生效。跟path的inotify不一样
webcluster::172.31.15.11:8080::zone::
webcluster::172.31.15.12:8080::zone::

- 下面的示例配置使用了ADS分别动态获取Listener和Cluster相关的配置，跟上面效果一样，只是处理逻辑有所改变
---
node:
  id: envoy_front_proxy
  cluster: Magedu_Cluster

admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
      address: 0.0.0.0
      port_value: 9901

dynamic_resource:
  ads_config:
    api_type: GRPC
	transport_api_version: V3
	grpc_services:
    - envoy_grpc:
	    cluster_name: xds_cluster			#Management Server的地址，在static_resources中定义
    set_node_on_first_message_only: true
  cds_config:	
    resource_api_version: V3
	ads: {}
  lds_config:	
    resource_api_version: V3
	ads: {}  
 ---
 static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: local_service
              domains: ["*"]
              routes:
              - match: { prefix: "/" }
                route: { cluster: local_cluster }
          http_filters:
          - name: envoy.filters.http.router
 ---

#REST-JSON轮询订阅
- 通过REST端点进行的同步（长）轮询也可用于xDS单例API
- 上面的消息顺序是类似的，除了没有维护到管理服务器的持久流
- 预计在任何时间点只有一个未完成的请求，因此响应none在REST-JSON中是可选的
- proto3的JSON规范转换用于编码DiscoveryRequest和DiscoveryResponse消息
- ADS不适用于REST-JSON轮询
- 当轮询周期设置为较小的值时，为了进行长轮询，则还需要避免发送DiscoveryResponse，除非发生了对底层资源的更改。
Envoy V2版本REST-JSON用得最多，性能低。现在有了V3版，大量的ManagementServer基于gRPC协议的，不推荐使用REST-JSON了


###集群管理和侦听器管理是Envoy两大重点
##集群管理
- Envoy支持同时配置任意数量的上游集群，并基于Cluster Manager管理它们
  - Cluster Manager负责为集群管理上游主机的集群状态、负载均衡机制、连接类型及适用协议等
  - 生成集群配置的方式由静态或动态（CDS）两种
- 集群预热
  - 集群在服务器启动或者通过CDS进行初始化时需要一个预热的过程，这意味着集群存在下列状况：
    - 初始服务发现加载（例如DNS解析、EDS更新等）完成之前不可用
	- 配置了主动健康状态检查机制时，Envoy会主动发送健康状态检测请求报文至发现的每个上游主机；于是，初始的主动健康检查成功完成之前不可用
- 于是，新增集群初始化完成之前对Envoy的其它组件来说不可见；而对于需要更新的集群，在其预热完成后通过与旧集群的原子交换来确保不会发生流量中断类的错误

#最终一致的服务发现
- Envoy的服务发现并未采用完全一致的机制，而是假设主机以最终一致的方式加入或离开网格，它结合主动健康状态检查机制来判定集群的健康状态
  - 健康与否的决策机制以完全分布式的方式进行，因此可以很好地应对网络分区
  - 为集群启用主机健康状态检查机制后，Envoy基于如下方式判定是否路由请求到一个主机
  DiscoveryStatus					HealthCheckOK 					HealthCheckFailed
  Discovered						Route							Don't Route
  Absent							Route							Don't Route/Delete

#故障处理机制
- Envoy提供了一系列开箱即用的故障处理机制
  - 超时
  - 有限次数的重试，并支持可变的重试延迟
  - 主动健康检查与异常探测
  - 连接池
  - 断路器
- 所有这些特性，都可以在运行时动态配置
- 结合流量管理机制，用户可为每个服务/版本定制所需的故障恢复机制

#Upstreams健康状态检测
- 健康状态检测用于确保代理服务器不会将下游客户端的请求代理至工作异常的上游主机
- Envoy支持两种类型的健康状态检测，二者均基于集群进行定义
  - 主动检测：Envoy周期性地发送探测报文至上游主机，并根据其响应判断其健康状态；Envoy目前支持三种类型的主动检测
    - HTTP：向上游主机发送HTTP请求报文
	- L3/L4：向上游主机发送L3/L4请求报文，基于响应的结果判定其健康状态，或仅通过连接状态进行判定
	- Redis：向上游的Redis服务器发送Redis PING
  - 被动检测：Envoy通过异常检测（Outlier Detection）机制进行被动模式的健康状态检测
    - 目前，仅http router, tcp proxy和redis proxy三个过滤器支持异常值检测
	- Envoy支持以下类型的异常检测
	  - 连续5XX：意指所有类型的错误，非http router过滤器生成的错误也会在内部映射为5XX错误代码
	  - 连接网关故障：连续5XX的子集，单纯用于http的502、503、504错误，即网关故障
	  - 连接的本地原因故障：Envoy无法连接到上游主机或与上游主机的通信被反复中断
	  - 成功率：主机的聚合成功率数据阈值

#Upstreams主动健康状态检测
- 集群的主机健康状态检测机制需要显式定义，否则，发现的所有上游主机即被视为可用；定义语法：
clusters:
- name: ...
  ...
  load_assignment:
  endpoint:
  - lb_endpoints:
    - endpoint:  
        health_check_config:
          port_value: ...   #自定义健康状态检测时使用的端口
...
  health_checks:
  - timeout: ...					#超时时长
    interval: ...					#时间间隔
	intial_jitter: ...				#初始检测时间点散开量，以毫秒为单位
	interval_jitter: ...			#间隔检测时间点散开量，以毫秒为单位
	unhealthy_threshold: ... 		#将主机标记为不健康状态的检测阈值，即至少多少次不健康的检测后才将其标记为不可用
	healthy_threshold: ...			#将主机标记为健康状态的检测阈值，但初始检测成功一次即视主机为健康
	http_health_check: ...			#HTTP类型的检测；包括此种类型在内的以下四种检测类型必须设置一种
	tcp_health_check: ...			#TCP类型的检测
	grpc_health_check: ...			#GRPC专用的检测
	custom_health_check: ...		#自定义检测
	reuse_connection: ...			#布尔型值 ，是否在多次检测之间重用连接，默认值为true
	no_traffic_interfal: ...		#定义未曾调度任何流量至集群时其端点健康检测时间间隔，一旦其接收流量即转为正常的时间音阶 
	unhealthy_interval: ...			#标记为"unhealthy"状态的端点的健康检测时间间隔，一旦重新标记为"healthy"即转为正常的时间间隔
	unhealthy_edge_interval: ...	#端点刚被标记为"unhealthy"状态时的健康检测时间间隔，随后即转为同unhealty_interval的定义
	healthy_edge_interval: ...		#端点刚被标记为"healthy"状态时的健康检测时间间隔，随后即转为同interval的定义
    tls_options: {...}				#tls相关的配置
	transport_socket_match_criteria: {...}
  
#主动健康状态检查：TCP
- TCP类型的检测
  - 非空负载的tcp检测意味着仅通过连接状态判定其检测结果
  - 非空负载的tcp检测可以使用send和receive来分别指定请求负荷及于响应报文中期望模型匹配的结果
   health_checks: 
   - timeout: 5s
     interval: 10s
	 unhealthy_threshold: 2
	 healthy_threshold: 2
	 tcp_health_check: {}
  
#主动健康状态检查：HTTP
- http类型的检测可以自定义使用的path、host和期望的响应码等，并能够在必要时修改(添加/删除)请求报文的标头
- 具体配置语法如下：
   health_checks: 
   - timeout: 5s
     interval: 10s
	 unhealthy_threshold: 2
	 healthy_threshold: 2
	 http_health_check: 
	   "host": "..."					#检测时使用的主机标头，默认为空，此时使用集群名称
	   "path": "..."					#检测时使用的路径，例如/healthz; 必选参数
	   "service_name_matcher": "..."	#用于验证检测目标集群服务名称的参数，可选
	   "request_header_to_add": "..."	#向检测报文添加的自定义标头列表
	   "request_headers_to_remove": "..."	#从检测报文中移除的标头列表
	   "expected_statues": []			#期望的响应码列表
	   
#docker-compose运行示例
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/health-check# ll
total 20
drwxr-xr-x  2 root root  145 Apr 10 18:24 ./
drwxr-xr-x 11 root root  198 Apr 10 18:24 ../
-rw-r--r--  1 root root 1481 Apr 10 18:24 docker-compose.yaml
-rw-r--r--  1 root root 1301 Apr 10 18:24 envoy-sidecar-proxy.yaml
-rw-r--r--  1 root root 1353 Apr 10 18:24 front-envoy-with-tcp-check.yaml
-rw-r--r--  1 root root 1439 Apr 10 18:24 front-envoy.yaml
-rw-r--r--  1 root root 1226 Apr 10 18:24 README.md
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/health-check# cat docker-compose.yaml
# Author: MageEdu <mage@magedu.com>
# Version: v1.0.1
# Site: www.magedu.com
#
version: '3.3'

services:
  envoy:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./front-envoy.yaml:/etc/envoy/envoy.yaml
    # - ./front-envoy-with-tcp-check.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        ipv4_address: 172.31.18.2
        aliases:
        - front-proxy
    depends_on:
    - webserver01-sidecar
    - webserver02-sidecar

  webserver01-sidecar:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./envoy-sidecar-proxy.yaml:/etc/envoy/envoy.yaml
    hostname: red
    networks:
      envoymesh:
        ipv4_address: 172.31.18.11
        aliases:
        - myservice

  webserver01:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
      - HOST=127.0.0.1
    network_mode: "service:webserver01-sidecar"
    depends_on:
    - webserver01-sidecar

  webserver02-sidecar:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./envoy-sidecar-proxy.yaml:/etc/envoy/envoy.yaml
    hostname: blue
    networks:
      envoymesh:
        ipv4_address: 172.31.18.12
        aliases:
        - myservice

  webserver02:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
      - HOST=127.0.0.1
    network_mode: "service:webserver02-sidecar"
    depends_on:
    - webserver02-sidecar

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.18.0/24
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/health-check# cat front-envoy.yaml
admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address: { address: 0.0.0.0, port_value: 9901 }

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: webservice
              domains: ["*"]
              routes:
              - match: { prefix: "/" }
                route: { cluster: web_cluster_01 }
          http_filters:
          - name: envoy.filters.http.router
  clusters:
  - name: web_cluster_01
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: web_cluster_01
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address: { address: myservice, port_value: 80 }
    health_checks:
    - timeout: 5s
      interval: 10s
      unhealthy_threshold: 2
      healthy_threshold: 2
      http_health_check:
        path: /livez
        expected_statuses:
          start: 200
          end: 399
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/health-check# cat envoy-sidecar-proxy.yaml
# Author: MageEdu <mage@magedu.com>
# Version: v1.0.1
# Site: www.magedu.com
#
admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: local_service
              domains: ["*"]
              routes:
              - match: { prefix: "/" }
                route: { cluster: local_cluster }
          http_filters:
          - name: envoy.filters.http.router

  clusters:
  - name: local_cluster
    connect_timeout: 0.25s
    type: STATIC
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: local_cluster
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address: { address: 127.0.0.1, port_value: 8080 }
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/health-check# cat front-envoy-with-tcp-check.yaml
admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address: { address: 0.0.0.0, port_value: 9901 }

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: webservice
              domains: ["*"]
              routes:
              - match: { prefix: "/" }
                route: { cluster: web_cluster_01 }
          http_filters:
          - name: envoy.filters.http.router
  clusters:
  - name: web_cluster_01
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: web_cluster_01
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address: { address: myservice, port_value: 80 }
    health_checks:
    - timeout: 5s
      interval: 10s
      unhealthy_threshold: 2
      healthy_threshold: 2
      tcp_health_check: {}
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/health-check# docker-compose up
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/health-check# curl 172.31.18.2	#此时endpoint都可以被访问
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.1, ServerName: red, ServerIP: 172.31.18.11!
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/health-check# curl 172.31.18.2
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.1, ServerName: blue, ServerIP: 172.31.18.12!
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/health-check# curl 172.31.18.11/livez #值是OK就会返回200-399响应码，否则其它值返回非200-399响应码
OK
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/health-check# curl -I 172.31.18.11/livez	
HTTP/1.1 200 OK
content-type: text/html; charset=utf-8
content-length: 2
server: envoy
date: Fri, 15 Apr 2022 09:07:26 GMT
x-envoy-upstream-service-time: 2
------以下是控制台输出的创建状态检测日志，是为200
webserver01_1          | 127.0.0.1 - - [15/Apr/2022 09:08:28] "GET /livez HTTP/1.1" 200 -
webserver02_1          | 127.0.0.1 - - [15/Apr/2022 09:08:28] "GET /livez HTTP/1.1" 200 -
webserver01_1          | 127.0.0.1 - - [15/Apr/2022 09:08:38] "GET /livez HTTP/1.1" 200 -
webserver02_1          | 127.0.0.1 - - [15/Apr/2022 09:08:38] "GET /livez HTTP/1.1" 200 -
------人为将后端172.31.18.11响应码变成非200-399响应码
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/health-check# curl -X POST -d 'livez=FAIL' http://172.31.18.11/livez
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/health-check# curl -I  http://172.31.18.11/livez		#此时响应码为506
HTTP/1.1 506 Variant Also Negotiates
content-type: text/html; charset=utf-8
content-length: 4
server: envoy
date: Fri, 15 Apr 2022 09:10:38 GMT
x-envoy-upstream-service-time: 2
------以下是控制台输出的创建状态检测日志，172.31.18.11响应码是506了
webserver01_1          | 127.0.0.1 - - [15/Apr/2022 09:10:29] "GET /livez HTTP/1.1" 506 -
webserver02_1          | 127.0.0.1 - - [15/Apr/2022 09:10:29] "GET /livez HTTP/1.1" 200 -
webserver01_1          | 127.0.0.1 - - [15/Apr/2022 09:10:38] "HEAD /livez HTTP/1.1" 506 -
webserver01_1          | 127.0.0.1 - - [15/Apr/2022 09:10:39] "GET /livez HTTP/1.1" 506 -
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/health-check# curl 172.31.18.2		#此时endpoint被移除，无法访问到172.31.18.11
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.1, ServerName: blue, ServerIP: 172.31.18.12!
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/health-check# curl 172.31.18.2
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.1, ServerName: blue, ServerIP: 172.31.18.12!
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/health-check# curl 172.31.18.2
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.1, ServerName: blue, ServerIP: 172.31.18.12!
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/health-check# curl -X POST -d 'livez=OK' http://172.31.18.11/livez	#将172.31.18.11状态码改为200
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/health-check# curl -I  http://172.31.18.11/livez
HTTP/1.1 200 OK
content-type: text/html; charset=utf-8
content-length: 2
server: envoy
date: Fri, 15 Apr 2022 09:12:56 GMT
x-envoy-upstream-service-time: 2
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/health-check# curl 172.31.18.2
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.1, ServerName: red, ServerIP: 172.31.18.11!		#此时172.31.18.11回来了，变成健康状态了
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/health-check# curl 172.31.18.2
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.1, ServerName: blue, ServerIP: 172.31.18.12!

#异常探测-被动状态检测
- 异常主机驱逐机制
  - 确定主机异常 -> 若尚未驱逐主机，且已驱逐的数量低于允许的阈值，则已经驱逐主机 -> 主机牌驱逐状态一定时长 -> 超出时长后自动恢复服务
- 异常探测通过outlier_dection字段定义在集群上下文中
cluster:
- name: ...
  ...
  outlier_detection:
    consecutive_5xx: ...			#因连续5XX错误而弹出主机之前允许出现的连续5XX响应或本地原始错误的数量，默认为5
	interval: ...					#弹射分析扫描之间的时间间隔，默认为10000ms或10s
	base_ejection_time:...			#主机被弹出的基准时长，实际时长等于基准时长乘以主机已经弹出的次数；默认为30000ms或30s
	max_ejection_percent: ...		#因异常探测而允许弹出的上游集群中的主机数量百分比，默认为10%；不过，无论如何，至少要弹出一个主机
	enforcing_consecutive_5xx: ...	#基于连续的5xx检测到主机异常时主机将被弹出的几率，可用于禁止弹出或缓慢弹出；默认为100
	enforcing_success_rate: ...		#基于成功率检测到主机异常时主机将被弹出的几率，可用于禁止弹出或缓慢弹出；默认为100
	success_rate_minimum_hosts: ...	#对集群启动成功率异常检测的最少主机数，默认值为5
	success_rate_request_volume: ...	#在检测的一次时间间隔中必须收集的总请求的最小值，默认值为100
	success_rate_stdev_factor: ...	#用确定成功率异常值弹出的弹射阈值的因子；弹射阈值=均值-(因子*平均成功率标准差)；不过，此处设置的值 需要除以1000以得到因子，例如，需要使用1.3为因子时，需要将该参数值设定为1300
	consecutive_gateway_failure: ...	#因连续网关故障而弹出主机的最少连续故障数，默认为5
	enforcing_consecutive_gateway_failure: ...	#基于连续网关故障检测到异常状态时而弹出主机的几率的百分比，默认为0
	split_external_local_origin_errors: ...	#是否区分本地原因而导致的故障和外部故障，默认为false；此项设置为true时，以下三项方能生效
	consecutive_local_origin_failure: ...   #因本地原因的故障而弹出主机的最少故障次数，默认为5
	enforcing_consecutive_local_origin_failure: ...		#基于连续的本地故障检测到异常状态而弹出主机的几率百分比，默认为100
	enforcing_local_origin_success_rate: ...			#基于本地故障检测的成功率统计检测到异常状态而弹出主机的几率，默认为100
	failure_percentage_threshold: {...}		#确定基于故障百分比的离群值检测时要使用的故障百分比，如果给定主机的故障百分比大于或等于该值 ，它将被弹出；默认为85
    enforcing_failure_percentage: {...}		#基于故障百分比统计信息检测到异常状态时，实际弹出主机的几率的百分比；此设置可用于禁用弹出或使其缓慢上升；默认为0
    enforcing_failure_percentage_local_origin: {...}	#基于本地故障百分比统计信息检测到异常状态时，实际主机的概率的百分比；默认为0
	failure_percentage_minimum_hosts: {...}				#集群中执行基于故障百分比的弹出的主机的最小数量；若集群中的主机总数小于此值，将不会执行基于故障百分比的弹出；默认为5
	failure_percentage_request_volume: {...}	#必须在一个时间间隔（由上面的时间间隔持续时间定义）中收集总请求的最小数量，以对此主机执行基于故障百分比的弹出；如果数量低于此设置，则不会对此主机执行基于故障百分比的弹出；默认为50
	max_ejection_time: {...}		#主机弹出的最长时间；如果未指定，则使用默认值（300000ms或300s）或base_ejection_time值中的大者
		  
#使用异常探测
- 同主动健康检查一样，异常检测也要配置在集群级别；下面的示例用于配置在返回3个连续5XX错误时将主机弹出30秒
consecutive_5xx: "3"
base_ejection_time: "30s"
- 在新服务上启用异常检测时应该从不太严格的规则集开始，以便仅弹出具有网关连接错误的主机(HTTP503)，并且仅在10%的时间内弹出它们
consecutive_gateway_failure: "3"
base_ejection_time: "30s"
enforcing_consecutive_gateway_failure: "10"
- 同时，高流量、稳定的服务可以使用统计信息来弹出频繁异常容的主机；下面的配置示例将弹出错误率低于群集平均值1个标准差的任何端点，统计信息每10秒进行一次评估，并且算法不会针对任何在10秒内少于500个请求的主机运行
interval: "10s"
base_ejection_time: "30s"
success_rate_minimum_hosts: "10"
success_rate_request_volume: "500"
success_rate_stdev_factor: "1000"

root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/outlier-detection# cat docker-compose.yaml
# Author: MageEdu <mage@magedu.com>
# Version: v1.0.1
# Site: www.magedu.com
#
version: '3.3'

services:
  envoy:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./front-envoy.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        ipv4_address: 172.31.20.2
        aliases:
        - front-proxy
    depends_on:
    - webserver01-sidecar
    - webserver02-sidecar
    - webserver03-sidecar

  webserver01-sidecar:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./envoy-sidecar-proxy.yaml:/etc/envoy/envoy.yaml
    hostname: red
    networks:
      envoymesh:
        ipv4_address: 172.31.20.11
        aliases:
        - myservice

  webserver01:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
      - HOST=127.0.0.1
    network_mode: "service:webserver01-sidecar"
    depends_on:
    - webserver01-sidecar

  webserver02-sidecar:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./envoy-sidecar-proxy.yaml:/etc/envoy/envoy.yaml
    hostname: blue
    networks:
      envoymesh:
        ipv4_address: 172.31.20.12
        aliases:
        - myservice

  webserver02:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
      - HOST=127.0.0.1
    network_mode: "service:webserver02-sidecar"
    depends_on:
    - webserver02-sidecar

  webserver03-sidecar:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./envoy-sidecar-proxy.yaml:/etc/envoy/envoy.yaml
    hostname: green
    networks:
      envoymesh:
        ipv4_address: 172.31.20.13
        aliases:
        - myservice

  webserver03:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
      - HOST=127.0.0.1
    network_mode: "service:webserver03-sidecar"
    depends_on:
    - webserver03-sidecar

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.20.0/24
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/outlier-detection# cat front-envoy.yaml
admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address: { address: 0.0.0.0, port_value: 9901 }

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: webservice
              domains: ["*"]
              routes:
              - match: { prefix: "/" }
                route: { cluster: web_cluster_01 }
          http_filters:
          - name: envoy.filters.http.router
  clusters:
  - name: web_cluster_01
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: web_cluster_01
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address: { address: myservice, port_value: 80 }
    outlier_detection:				#异常探测或叫被动健康探测(用户访问时才探测)
      consecutive_5xx: 3			#连续5XX错误次数才弹出
      base_ejection_time: 10s		#异常基准弹出时间
      max_ejection_percent: 10		#因异常探测而允许弹出的上游集群中的主机数量百分比，向上取整
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/outlier-detection# cat envoy-sidecar-proxy.yaml
# Author: MageEdu <mage@magedu.com>
# Version: v1.0.1
# Site: www.magedu.com
#
admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: local_service
              domains: ["*"]
              routes:
              - match: { prefix: "/" }
                route: { cluster: local_cluster }
          http_filters:
          - name: envoy.filters.http.router

  clusters:
  - name: local_cluster
    connect_timeout: 0.25s
    type: STATIC
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: local_cluster
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address: { address: 127.0.0.1, port_value: 8080 }
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/outlier-detection# while true; do curl 172.31.20.2/livez && echo; sleep 1; done	#测试后端服务器是否OK，目前全部OK
OK
OK
OK
OK
root@front-envoy:~# curl -X POST -d 'livez=FAIL' http://172.31.20.11/livez	#将172.31.20.11置为不OK，在用户请求172.31.20.2/livez时将会触发被动健康状态检测，当异常达到3次时将被弹出10秒，最大弹出主机数量为10% max_ejection_percent: 10，向上取整为1，envoy会定时再去探测异常的端点，异常时间=次数*10s
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/outlier-detection# while true; do curl 172.31.20.2/livez && echo; sleep 1; done
OK
OK
OK
OK
OK
OK
OK
FAIL		#第一次失败
OK
OK
OK
OK
FAIL	
OK
OK
OK	
FAIL		#第三次失败
OK
webserver01_1          | 127.0.0.1 - - [15/Apr/2022 12:43:05] "GET /livez HTTP/1.1" 506 -
webserver03_1          | 127.0.0.1 - - [15/Apr/2022 12:43:06] "GET /livez HTTP/1.1" 200 -
webserver02_1          | 127.0.0.1 - - [15/Apr/2022 12:43:08] "GET /livez HTTP/1.1" 200 -
webserver02_1          | 127.0.0.1 - - [15/Apr/2022 12:43:09] "GET /livez HTTP/1.1" 200 -
webserver03_1          | 127.0.0.1 - - [15/Apr/2022 12:43:10] "GET /livez HTTP/1.1" 200 -
webserver01_1          | 127.0.0.1 - - [15/Apr/2022 12:43:11] "GET /livez HTTP/1.1" 506 -
webserver02_1          | 127.0.0.1 - - [15/Apr/2022 12:43:12] "GET /livez HTTP/1.1" 200 -
webserver03_1          | 127.0.0.1 - - [15/Apr/2022 12:43:13] "GET /livez HTTP/1.1" 200 -
webserver03_1          | 127.0.0.1 - - [15/Apr/2022 12:43:14] "GET /livez HTTP/1.1" 200 -
webserver01_1          | 127.0.0.1 - - [15/Apr/2022 12:43:15] "GET /livez HTTP/1.1" 506 -		#第三次失败后webserver01将不会被调度
webserver03_1          | 127.0.0.1 - - [15/Apr/2022 12:43:16] "GET /livez HTTP/1.1" 200 -
webserver02_1          | 127.0.0.1 - - [15/Apr/2022 12:43:17] "GET /livez HTTP/1.1" 200 -
webserver03_1          | 127.0.0.1 - - [15/Apr/2022 12:43:18] "GET /livez HTTP/1.1" 200 -
webserver02_1          | 127.0.0.1 - - [15/Apr/2022 12:43:19] "GET /livez HTTP/1.1" 200 -
webserver03_1          | 127.0.0.1 - - [15/Apr/2022 12:43:20] "GET /livez HTTP/1.1" 200 -
webserver03_1          | 127.0.0.1 - - [15/Apr/2022 12:43:21] "GET /livez HTTP/1.1" 200 -
webserver03_1          | 127.0.0.1 - - [15/Apr/2022 12:43:22] "GET /livez HTTP/1.1" 200 -
webserver02_1          | 127.0.0.1 - - [15/Apr/2022 12:43:23] "GET /livez HTTP/1.1" 200 -
webserver03_1          | 127.0.0.1 - - [15/Apr/2022 12:43:24] "GET /livez HTTP/1.1" 200 -
root@front-envoy:~# curl -X POST -d 'livez=OK' http://172.31.20.11/livez		#将172.31.20.11置为OK
webserver01_1          | 127.0.0.1 - - [15/Apr/2022 12:43:43] "POST /livez HTTP/1.1" 200 -
webserver02_1          | 127.0.0.1 - - [15/Apr/2022 12:43:43] "GET /livez HTTP/1.1" 200 -
webserver03_1          | 127.0.0.1 - - [15/Apr/2022 12:43:44] "GET /livez HTTP/1.1" 200 -
webserver03_1          | 127.0.0.1 - - [15/Apr/2022 12:43:45] "GET /livez HTTP/1.1" 200 -
webserver02_1          | 127.0.0.1 - - [15/Apr/2022 12:43:46] "GET /livez HTTP/1.1" 200 -
webserver02_1          | 127.0.0.1 - - [15/Apr/2022 12:43:47] "GET /livez HTTP/1.1" 200 -
webserver02_1          | 127.0.0.1 - - [15/Apr/2022 12:43:49] "GET /livez HTTP/1.1" 200 -
webserver03_1          | 127.0.0.1 - - [15/Apr/2022 12:43:50] "GET /livez HTTP/1.1" 200 -
webserver03_1          | 127.0.0.1 - - [15/Apr/2022 12:43:51] "GET /livez HTTP/1.1" 200 -
webserver02_1          | 127.0.0.1 - - [15/Apr/2022 12:43:52] "GET /livez HTTP/1.1" 200 -
webserver02_1          | 127.0.0.1 - - [15/Apr/2022 12:43:53] "GET /livez HTTP/1.1" 200 -
webserver03_1          | 127.0.0.1 - - [15/Apr/2022 12:43:54] "GET /livez HTTP/1.1" 200 -
webserver03_1          | 127.0.0.1 - - [15/Apr/2022 12:43:55] "GET /livez HTTP/1.1" 200 -
webserver02_1          | 127.0.0.1 - - [15/Apr/2022 12:43:56] "GET /livez HTTP/1.1" 200 -
webserver03_1          | 127.0.0.1 - - [15/Apr/2022 12:43:57] "GET /livez HTTP/1.1" 200 -
webserver01_1          | 127.0.0.1 - - [15/Apr/2022 12:43:58] "GET /livez HTTP/1.1" 200 -	#此时自动正常上线了
webserver02_1          | 127.0.0.1 - - [15/Apr/2022 12:43:59] "GET /livez HTTP/1.1" 200 -
webserver02_1          | 127.0.0.1 - - [15/Apr/2022 12:44:00] "GET /livez HTTP/1.1" 200 -
webserver01_1          | 127.0.0.1 - - [15/Apr/2022 12:44:01] "GET /livez HTTP/1.1" 200 -
webserver03_1          | 127.0.0.1 - - [15/Apr/2022 12:44:02] "GET /livez HTTP/1.1" 200 -

#负载均衡策略
- Evnoy提供了几种不同的负载均衡策略，并可大体分为全局负载均衡和分布式负载均衡两类；
  - 分布式负载均衡：Envoy自身基于上游主机（区域感知）的位置及健康状态等来确定如何分配负载至相关端点
    - 主动健康检查
	- 区域感知路由
	- 负载均衡算法
  - 全局负载均衡：这是一种通过单个具有全局权限的组件来统一决策负载机制，Envoy的控制平面即是该类组件之一，它能够通过指定各种参数来调整应用于各端点的负载
    - 优先级
	- 位置权重
	- 端点权重 
	- 端点健康状态
- 复杂的部署场景可以混合使用两类负载均衡策略，全局负载均衡通过定义高级路由优先级和权重以控制同级别的流量，而分布式负载均衡用于对系统中的微观变动作出反应(例如主动健康检查)

#Cluster中与负载均衡相关的配置参数速览
clustes:
- name: ...
  ...
  load_assignment: {...}
    cluster_name: ...
	endpoints: []								#LocalityLBEndpoints列表，每个列表项主要由位置、端点列表、权重和优先级四项组成
	- locality: {...}							#位置定义
	    region: ...
		zone: ...
		sub_zone: ...
	  lb_endpoints: []							#端点列表
	  - endpoint: {...}							#端点定义
	      address: {...}						#端点地址
		  health_check_config: {...}			#当前端点与健康状态检查相关的配置
	    load_balancing_weight: ...				#当前端点的负载均衡权重 ，可选
		metadata: {...}					#基于匹配的侦听器、过滤器链、路由和端点等为过滤器提供额外信息的元数据，常用用于提供服务配置或辅助负载均衡
		health_status: ...				#端点是经EDS发现时，此配置项用于管理式设定端点的健康状态，可用值有UNKNOW,HEALTHY,UNHEALTHY,DRAINING,TIMEOUT,DEGRADED
	  load_balancing_weight: {...}				#权重
	  priority: ...								#优先级
	policy: {...}								#负载均衡策略设定
	  drop_overloads: []						#过载保护机制，丢弃过载流量的机制
	  overprovisioning_factor: ...				#整数值，定义超配因子（百分比），默认值为140，即1.4
	  endpoint_state_after: ...					#过期时长，过期之前未收到任何新流量分配的端点将被视为过时，并标记为不健康；默认值0表示永不过时
	lb_subset_config: {...} 					
	ring_hash_lb_config: {...}
	original_dst_lb_config: {...}
	least_request_lb_config: {...}
	common_lb_config: {...}
	  health_panic_threshold: ...				#Panic阈值，默认为50%
	  zone_aware_lb_config: {...}				#区域感知路由的相关配置
	  locality_weighted_lb_config: {...}		#局部权重负载均衡相关的配置
	  ignore_new_hosts_until_first_hc: ...		#是否在新加入的主机经历第一次健康状态检查之前不予考虑进负载均衡
	  
#Envoy的负载均衡算法概述
- Cluster Manager使用负载均衡策略将下游请求调度至选中的上游主机，它支持如下几个算法
  - 加权轮询：算法名称为ROUND_ROBIN
  - 加权最少请求：算法名称为LEAST_REQUEST
  - 环哈希：算法名称为RING_HASH，其工作方式类似于一致性哈希算法
  - 磁悬浮：类似环哈希，但其大小固定为65537，并需要各主机映射的节点填满整个环；无论配置的主机和位置权重如何，算法都会尝试确保将每个主机至少映射一次；算法名称为MAGLEV
  - 随机：未配置健康检查策略，则随机负载均衡算法通常比轮询更好
- 另外，还有原始目标集群负载均衡机制，其算法为ORIGINAL_DST_LB，但仅适用于原始目标集群的调度

----LEAST_REQUEST算法
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/least-requests# cat front-envoy.yaml		
... 
  clusters:
  - name: web_cluster_01
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: LEAST_REQUEST
    load_assignment:
      cluster_name: web_cluster_01
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: red
                port_value: 80
          load_balancing_weight: 1
        - endpoint:
            address:
              socket_address:
                address: blue
                port_value: 80
          load_balancing_weight: 3
        - endpoint:
            address:
              socket_address:
                address: green
                port_value: 80
          load_balancing_weight: 5
		  
 ----配置路由哈希策略
 - 路由哈希策略定义在路由配置中
 route_config:
   ...
   virtual_hosts:
   - ...
     routes:
	 - match:
	   ...
	   route:
	     ...
		 hash_policy: []		#指定哈希策略列表，每个列表项仅可设置如下header, cookie或connection_properties三者之一
		   header: {...}
		     header_name: ...	#要哈希的首部名称
		   cookie: {...}
             name: ...			#cookie的名称，其值将用于哈希计算，必选项
             ttl: ...			#持续时长，不存在带有ttl的cookie将自动生成该cookie；如果TTL存在且为零，则生成的cookie将是会话cookie
		     path: ...			#cookie的路径
		   connection_properties: {...}	
		     source_ip: ...		#布尔型值，是否哈希源IP地址
		   terminal: ...		#是否启用哈希算法的短路标志，即一旦当前策略生成哈希值，将不再考虑列表中后续的其它哈希策略		 
----RING_HASH算法----当后端某端点故障，将会在哈希环上逆时针找下一个节点，影响是局部的，不是全局的(而nginx hash影响是全局的)
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/ring-hash# cat front-envoy.yaml
admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address: { address: 0.0.0.0, port_value: 9901 }

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: webservice
              domains: ["*"]
              routes:
              - match: { prefix: "/" }
                route:
                  cluster: web_cluster_01
                  hash_policy:			#需要指定hash_policy，跟cluster中ring_hash一起设置才行
                  # - connection_properties:
                  #     source_ip: true
                  - header:
                      header_name: User-Agent
          http_filters:
          - name: envoy.filters.http.router

  clusters:
  - name: web_cluster_01
    connect_timeout: 0.5s
    type: STRICT_DNS
    lb_policy: RING_HASH
    ring_hash_lb_config:
      maximum_ring_size: 1048576		#环最大值
      minimum_ring_size: 512			#环最小值
    load_assignment:
      cluster_name: web_cluster_01
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: myservice
                port_value: 80
    health_checks:
    - timeout: 5s
      interval: 10s
      unhealthy_threshold: 2
      healthy_threshold: 2
      http_health_check:
        path: /livez
        expected_statuses:
          start: 200
          end: 399
		 
#磁悬浮算法	 ----和ringhash没有本质区别，主要是环大小是固定的
- Maglev是环哈希算法的一种特殊形式，它使用固定为65537的环大小
  - 环构建算法将每个主机按其权重成比例地放置在环上，直到环完全填满为止；例如，如果主机A的权重为1，主机B的权重为2，则主机A将具有21846项，而主机B将具有43691项（总计65537项）
  - 该算法尝试将每个主机至少放置一次在表中，而不管配置的主机和位置权重如何，因此在某些极端情况下，实际比例可能与配置的权重不同
  - 最佳做法是监视min_entries_per_host和max_entries_per_host指标以确保没有主机出现异常配置
- 在需要一致哈希的任何地方，Maglev都可以取代环哈希；同时，与环形哈希算法一样，Maglev仅在使用协议路由指定要哈希的值时才有效
  - 通常，与环哈希ketama算法相比，Maglev具有显着更快的表查找建立时间以及主机选择时间
  - 稳定性略逊于环哈希
  

#节点优先级及优先级调度
- EDS配置中，属于某个特定位置的一组端点称为LocalityLbEndpoints，它们具有相同的位置（locality）、权重（load_balancing_weight）和优先级（priority）
  - locality: 从大到小可由region, zone, sub_zone进行逐级标识
  - load_balancing_weight: 可选参数，用于为每个priority/region/zone/sub_zone配置权重，取值范围(1,n)；通常，一个locality权重除以具有相同优先级的所有locality的权重之和即为当前locality的流量比例
    - 此配置仅启用了位置加权负载均衡机制时才会生效
- 通常，Envoy调度时仅挑选最高优先级的一组端点，且仅此优先级的所有端点均不可用时才进行故障转移至下一个优先级的相关端点
- 注意，也可在同一位置配置多个LbEndpoints，但这通常仅在不同组需要具有不同的负载均衡权重或不同的优先级时才需要
{
  "locality": "{...}",
  "lb_endpoints": [],
  "load_balancing_weight": "{...}",
  "priority": "..."			#0为最高优先级，可用范围为[0,N]，但配置时必须按顺序使用各优先级数字，而不能跳过；默认为0
}

#优先级调度
- 调度时，Envoy仅将流量调度至最高优先级的一组端点（LocalityLbEndpoints）
  - 在最高优先级的端点变得不健康时，流量才会按比例转移至次一个优先级的端点；例如一个优先级中20%的端点不健康时，也将有20%的流量转移至次一个优先级端点
  - 超配因子：也可为一组端点设定超配因子，实现部分端点故障时仍将更大比例的流量导向至本组端点
    - 计算公式：转移的流量=100%-健康的端点比例*超配因子；于是，对于1.4的因子来说，20%的故障比例时，所有流量仍将保留在当前组；当健康的端点比例低于72%时，才会有部分流量转移至次优先级端点
	- 一个优先级别当前处理流量的能力也自然流产为健康评分（健康主机比例*超配因子，上限为100%）
  - 若各个优先级的健康评分总和（也称为标准化的总健康状态）小于100，则Envoy会认为没有足够的健康端点来分配所有待处理的流量，此时，各级别会根据其健康分值的比例重新分配100%的流量；例如，对于具有{20，30}健康评分的两个组（标准化的总健康状况为50）将被标准化，并导致负载比例为40%和60%
- 另外，优先级调度还支持同一优先级内部的端点阶级（DEGRADED）机制，其工作方式类同于在两个不同优先级之间的端点分配流量的机制
  - 非降级端点健康比例*超配因子大于等于100%时，阶级端点不承接流量
  - 非降级端点的健康比例*超配因子小于100%时，降级端点承接与100%差额部分的流量
  
#Panic阈值
- 调度期间，Envoy仅考虑上游主机列表中的可用（健康或降级）端点，但可用端点的百分比过低时，Envoy将忽略所有端点的健康状态并将流量调度给所有端点；此百分比即为Panic阈值，也称为恐慌阈值
  - 默认的Panic阈值为50%
  - Panic阈值用于避免在流量增长时导致主机故障进入级联状态
- 恐慌阈值可与优先级一同使用
  - 给定优先级中的可用端点数量下降时，Envoy会将一些流量转移至较低优先级的端点
    - 若在低优先级中找到的承载所有流量的端点，则忽略恐慌阈值
	- 否则，Envoy会在所有优先级之间分配流量，并在给定的优先级的可用性低于恐慌阈值时将该优先的流量分配至该优先级的所有主机
#Cluster.CommonLbConfig		#集群顶级配置参数
{
  "healthy_panic_threshold": "{...}",		#百分比数值，定义恐慌阈值，默认为50%
  "zone_aware_lb_config": "{...}",
  "locality_weighted_lb_config": "{...}",
  "update_merge_window": "{...}",
  "ignore_new_hosts_until_first_hc": "{...}"
}
  
#docker-compose示例----使用envoy v2版本
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/priority-levels# cat docker-compose.yaml
version: '3'

services:
  front-envoy:
    image: envoyproxy/envoy-alpine:v1.13-latest
    volumes:
      - ./front-envoy-v2.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        ipv4_address: 172.31.29.2
    expose:
      # Expose ports 80 (for general traffic) and 9901 (for the admin server)
      - "80"
      - "9901"

  webserver01-sidecar:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./envoy-sidecar-proxy.yaml:/etc/envoy/envoy.yaml
    hostname: red
    networks:
      envoymesh:
        ipv4_address: 172.31.29.11
        aliases:
        - webservice1
        - red

  webserver01:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
      - HOST=127.0.0.1
    network_mode: "service:webserver01-sidecar"
    depends_on:
    - webserver01-sidecar

  webserver02-sidecar:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./envoy-sidecar-proxy.yaml:/etc/envoy/envoy.yaml
    hostname: blue
    networks:
      envoymesh:
        ipv4_address: 172.31.29.12
        aliases:
        - webservice1
        - blue

  webserver02:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
      - HOST=127.0.0.1
    network_mode: "service:webserver02-sidecar"
    depends_on:
    - webserver02-sidecar

  webserver03-sidecar:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./envoy-sidecar-proxy.yaml:/etc/envoy/envoy.yaml
    hostname: green
    networks:
      envoymesh:
        ipv4_address: 172.31.29.13
        aliases:
        - webservice1
        - green

  webserver03:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
      - HOST=127.0.0.1
    network_mode: "service:webserver03-sidecar"
    depends_on:
    - webserver03-sidecar

  webserver04-sidecar:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./envoy-sidecar-proxy.yaml:/etc/envoy/envoy.yaml
    hostname: gray
    networks:
      envoymesh:
        ipv4_address: 172.31.29.14
        aliases:
        - webservice2
        - gray

  webserver04:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
      - HOST=127.0.0.1
    network_mode: "service:webserver04-sidecar"
    depends_on:
    - webserver04-sidecar

  webserver05-sidecar:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./envoy-sidecar-proxy.yaml:/etc/envoy/envoy.yaml
    hostname: black
    networks:
      envoymesh:
        ipv4_address: 172.31.29.15
        aliases:
        - webservice2
        - black

  webserver05:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
      - HOST=127.0.0.1
    network_mode: "service:webserver05-sidecar"
    depends_on:
    - webserver05-sidecar

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.29.0/24
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/priority-levels# cat front-envoy-v2.yaml
admin:
  access_log_path: "/dev/null"
  address:
    socket_address:
      address: 0.0.0.0
      port_value: 9901

static_resources:
  listeners:
  - address:
      socket_address:
        address: 0.0.0.0
        port_value: 80
    name: listener_http
    filter_chains:
    - filters:
      - name: envoy.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.config.filter.network.http_connection_manager.v2.HttpConnectionManager
          codec_type: auto
          stat_prefix: ingress_http
          route_config:
            name: local_route
            virtual_hosts:
            - name: backend
              domains:
              - "*"
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: webcluster1
          http_filters:
          - name: envoy.router

  clusters:
  - name: webcluster1
    connect_timeout: 0.5s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    http2_protocol_options: {}
    load_assignment:
      cluster_name: webcluster1
      policy:
        overprovisioning_factor: 140	#超配因子，例如cn-north-1有3个端点，当故障2个端点，转移流量=100%-33%*1.4=0.538,约等于2个端点的流量将会被转移到cn-north-2，就是当用户请求3次时，1次到cn-north-1，2次到cn-north-2
      endpoints:
      - locality:
          region: cn-north-1
        priority: 0						#优先级为0，优先调度
        lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: webservice1
                port_value: 80
      - locality:
          region: cn-north-2
        priority: 1						#优先级为1，当优先级为0的endpoint有故障时，会被调度到此
        lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: webservice2
                port_value: 80
    health_checks:						#主动健康状态检测
    - timeout: 5s
      interval: 10s
      unhealthy_threshold: 2
      healthy_threshold: 1
      http_health_check:
        path: /livez

#位置加权负载均衡即为特定的Locality及相关的LbEndpoints组显示赋予权重，并根据此权重比在各Locality之间分配流量
- 所有Locality的所有Endpoint均可用时，则根据位置权重在各Locality之间进行加权轮询
  - 例如，cn-north-1和cn-north-2两个region的权重分别为1和2时，且各region内的端点均处于健康状态，则流量分配比例为"1:2"，即一个33%，一个是67%
  - 启用位置加权负载均衡及位置权重定义的方法
cluster:
- name: ...
  ...
  common_lb_config:
    locality_weighted_lb_config: {}		#启用位置加权负载均衡机制，它没有可用的子参数
	...
  load_assignment:
    endpoints:
	  locality: {...}
	  lb_endpoints: []
	  load_balancing_weight: {...}		#整数值，定义当前位置或优先级的权重，最小值为1
	  priority: ...
  - 注意：位置加权负载均衡同区域感知负载均衡互斥，因此，用户仅可在Cluster级别设置locality_weight_lb_config或zone_aware_lb_config其中之一，以明确指定启用的负载均衡策略
#位置加权负载均衡---此步骤未测试
- 当某Locality的某些Endpoint不可用时，Envoy则按比例动态调整该Locality的权重
  - 位置加权负载均衡方式也支持LbEndpoint配置超配因子，默认为1.4
  - 例如，假设位置X和Y分别拥有1和2的权重，则Y的健康端点比例只有50%时，其权重调整为"2X(1.4X0.5)=1.4"，于是流量分配比例变为"1:1.4"
- 若同时配置了优先级和权重，负载均衡器将会以如下步骤进行调度
  - 选择priority
  - 从选出的priority中反选Locality
  - 从选出的locality中选择Endpoint
  
#负载均衡器子集
- Envoy还支持在一个集群中基于子集实现更细粒度的流量分发
  - 首先：在集群的上游主机上添加元数据（键值标签），并使用子集选择器（分类元数据）将上游主机划分为子集
  - 而后，在路由配置中指定负载均衡器可以选择的且必须具有匹配的元数据的上游主机，从而实现向特定子集的路由
  - 各子集内的主机间的负载均衡采用集群定义的策略(lb_policy)
- 配置了子集，但路由并未指定元数据或不存在与指定元数据匹配的子集时，则子集均衡器为其应用"回退策略",fallback_policy
  - NO_FALLBACK: 请求失败，类似集群中不存在任何主机；此为默认策略
  - ANY_ENDPOINT: 在所有主机间进行调度，不再考虑主机元数据
  - DEFAULT_SUBSET: 调度至默认的子集，该子集需要事先定义
#配置负载均衡器子集
- 子集必须预定义方可由子集负载均衡器在调度时使用
  - 定义主机元数据：键值数据
    - 主机的子集元数据必须要定义在"envoy.lb"过滤器下
	- 仅当使用ClusterLoadAssignments定义主机时才支持主机元数据
	  - 通过EDS发现的端点
	  - 通过load_assginment字段定义的端点
load_assignment:
  cluster_name: webcluster1
  endpoints:
  - lb_endpoints:
    - endpoint:
	    address:
	      socket_address:
		  ...
	  metadata:
	    filter_metadata:	#给后端端点打上标准，才能在前端调度子集
		  envoy.lb:			#过滤器名称
		    version: '1.0'
			stage: 'prod'
 
 ----docker-compose 负载均衡子集示例
 root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/lb-subsets# ll
total 20
drwxr-xr-x  2 root root   89 Apr 10 18:24 ./
drwxr-xr-x 11 root root  198 Apr 10 18:24 ../
-rw-r--r--  1 root root 1792 Apr 10 18:24 docker-compose.yaml
-rw-r--r--  1 root root 5241 Apr 10 18:24 front-envoy.yaml
-rw-r--r--  1 root root 1333 Apr 10 18:24 README.md
-rwxr-xr-x  1 root root  293 Apr 10 18:24 test.sh*
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/lb-subsets# cat docker-compose.yaml
# Author: MageEdu <mage@magedu.com>
# Version: v1.0.2
# Site: www.magedu.com
#
version: '3'

services:
  front-envoy:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
      - ./front-envoy.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        ipv4_address: 172.31.33.2
    expose:
      # Expose ports 80 (for general traffic) and 9901 (for the admin server)
      - "80"
      - "9901"

  e1:
    image: ikubernetes/demoapp:v1.0
    hostname: e1
    networks:
      envoymesh:
        ipv4_address: 172.31.33.11
        aliases:
          - e1
    expose:
      - "80"

  e2:
    image: ikubernetes/demoapp:v1.0
    hostname: e2
    networks:
      envoymesh:
        ipv4_address: 172.31.33.12
        aliases:
          - e2
    expose:
      - "80"

  e3:
    image: ikubernetes/demoapp:v1.0
    hostname: e3
    networks:
      envoymesh:
        ipv4_address: 172.31.33.13
        aliases:
          - e3
    expose:
      - "80"

  e4:
    image: ikubernetes/demoapp:v1.0
    hostname: e4
    networks:
      envoymesh:
        ipv4_address: 172.31.33.14
        aliases:
          - e4
    expose:
      - "80"

  e5:
    image: ikubernetes/demoapp:v1.0
    hostname: e5
    networks:
      envoymesh:
        ipv4_address: 172.31.33.15
        aliases:
          - e5
    expose:
      - "80"

  e6:
    image: ikubernetes/demoapp:v1.0
    hostname: e6
    networks:
      envoymesh:
        ipv4_address: 172.31.33.16
        aliases:
          - e6
    expose:
      - "80"

  e7:
    image: ikubernetes/demoapp:v1.0
    hostname: e7
    networks:
      envoymesh:
        ipv4_address: 172.31.33.17
        aliases:
          - e7
    expose:
      - "80"

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.33.0/24
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/lb-subsets# cat front-envoy.yaml
# Author: MageEdu <mage@magedu.com>
# Version: v1.0.2
# Site: www.magedu.com
#
admin:
  access_log_path: "/dev/null"
  address:
    socket_address: { address: 0.0.0.0, port_value: 9901 }

static_resources:
  listeners:
  - address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    name: listener_http
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          codec_type: auto
          stat_prefix: ingress_http
          route_config:
            name: local_route
            virtual_hosts:
            - name: backend
              domains:
              - "*"
              routes:
              - match:								#匹配特定header
                  prefix: "/"
                  headers:							
                  - name: x-custom-version
                    exact_match: pre-release
                route:								#路由到此cluster
                  cluster: webcluster1
                  metadata_match:					#负载均衡子集，路由到key和value相等的endpoint上
                    filter_metadata:
                      envoy.lb:
                        version: "1.2-pre"			
                        stage: "dev"
              - match:
                  prefix: "/"
                  headers:
                  - name: x-hardware-test
                    exact_match: memory
                route:
                  cluster: webcluster1
                  metadata_match:
                    filter_metadata:
                      envoy.lb:
                        type: "bigmem"
                        stage: "prod"
              - match:
                  prefix: "/"
                route:
                  weighted_clusters:			#基于权重的集群，主是流量分割
                    clusters:
                    - name: webcluster1
                      weight: 90				#权重90
                      metadata_match:			#负载均衡子集，路由到key和value相等的endpoint上
                        filter_metadata:
                          envoy.lb:
                            version: "1.0"
                    - name: webcluster1
                      weight: 10				#权重10
                      metadata_match:
                        filter_metadata:
                          envoy.lb:
                            version: "1.1"
                  metadata_match:	#为当前route下的公共标签，例如stage: "prod",version: "1.0"的承载了90的流量，stage: "prod",version: "1.1"为承载了10的流量
                    filter_metadata:
                      envoy.lb:
                        stage: "prod"
          http_filters:
          - name: envoy.filters.http.router

  clusters:
  - name: webcluster1
    connect_timeout: 0.5s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: webcluster1
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: e1
                port_value: 80
          metadata:								#定义负载均衡子集，必须先在此定义，而后才能在route过滤器上使用
            filter_metadata:
              envoy.lb:
                stage: "prod"					#为e1这个端点打开标签，而后在route上进行选择调用
                version: "1.0"
                type: "std"
                xlarge: true
        - endpoint:
            address:
              socket_address:
                address: e2
                port_value: 80
          metadata:
            filter_metadata:
              envoy.lb:
                stage: "prod"
                version: "1.0"
                type: "std"
        - endpoint:
            address:
              socket_address:
                address: e3
                port_value: 80
          metadata:
            filter_metadata:
              envoy.lb:
                stage: "prod"
                version: "1.1"
                type: "std"
        - endpoint:
            address:
              socket_address:
                address: e4
                port_value: 80
          metadata:
            filter_metadata:
              envoy.lb:
                stage: "prod"
                version: "1.1"
                type: "std"
        - endpoint:
            address:
              socket_address:
                address: e5
                port_value: 80
          metadata:
            filter_metadata:
              envoy.lb:
                stage: "prod"
                version: "1.0"
                type: "bigmem"
        - endpoint:
            address:
              socket_address:
                address: e6
                port_value: 80
          metadata:
            filter_metadata:
              envoy.lb:
                stage: "prod"
                version: "1.1"
                type: "bigmem"
        - endpoint:
            address:
              socket_address:
                address: e7
                port_value: 80
          metadata:
            filter_metadata:
              envoy.lb:
                stage: "dev"
                version: "1.2-pre"
                type: "std"
    lb_subset_config:
      fallback_policy: DEFAULT_SUBSET
      default_subset:
        stage: "prod"
        version: "1.0"
        type: "std"
      subset_selectors:
      - keys: ["stage", "type"]
      - keys: ["stage", "version"]
      - keys: ["version"]
      - keys: ["xlarge", "version"]
    health_checks:
    - timeout: 5s
      interval: 10s
      unhealthy_threshold: 2
      healthy_threshold: 1
      http_health_check:
        path: /livez
        expected_statuses:
          start: 200
          end: 399
---


#熔断----断路器
----应对级联故障(雪崩效应)才会使用熔断
- 熔断：上游服务（被调用者，即服务提供者）因压力过大而变得响应过慢甚至失败时，下游服务（服务消费者）通过暂时切断对上游的请求调用达到牺牲局部，保全上游甚至是整体之目的
  - 熔断打开（Open）：在固定时间窗口内，检测到的失败指标达到指定的阈值时启动熔断
    - 所有请求会直接失败而不再发往后端端点
  - 熔断半打开（Half Open）：断口器在工作一段时间后自动切换至半打开状态，并根据下一次请求的返回结果判定状态切换
    - 请求成功：转为熔断关闭状态
	- 请求失败：切回熔断打开状态
  - 熔断关闭（Closed）：一定时长后上游服务可能会变得再次可用，此时下游即可关闭熔断，并再次请求其服务
- 总结起来，熔断是分布式应用常用的一种流量管理模式，它能够让应用程序免受上游服务失败，延迟峰值或其它网络异常的侵害
- Envoy在网络级别强制进行断路限制，于是不必独立配置和编码每个应用
- Envoy支持多种类型的完全分布式断路机制，达到由其定义的阈值时，相应的断路器即会溢出
  - 集群最大连接数：Envoy同上游集群建立的最大连接数，仅适用于HTTP/1.1，因为HTTP/2可以链路复用
  - 集群最大请求数：在给定的时间，集群中的所有主机未完成的最大请求数，仅适用于HTTP/2
  - 集群可挂起的最大请求数：连接池满载时所允许的等待队列的最大长度
  - 集群最大活动并发重试次数：给定时间内集群中所有主机可以执行的最大并发重试次数
  - 集群最大并发连接池：可以同时实例化出的最大连接池数量 
- 每个断路器都可在每个集群及每个优先级的基础上进行配置和跟踪，它们可分别拥有各自不同的设定
- 注意：在Istio中，熔断的功能通过连接池（连接池管理）和故障实例隔离（异常点检测）进行定义，而Envoy的断路器通常仅对于Istio中的连接池功能。
  - 通过限制某个客户端对目标服务的连接数、访问请求、队列长度和重试次数等，避免对一个服务的过量访问
  - 某个服务实例频繁超时或者出错时将其逐出，以避免影响整个服务
#连接池和断路器
- 连接池的常用指标
  - 最大连接数：表示在任何给定时间内，Envoy与上游集群建立的最大连接数，适用于HTTP/1.1
  - 每连接最大请求数：表示在任何给定时间内，上游集群中所有主机可以处理的最大请求数；若设为1则会禁止keepalive特性
  - 最大请求重试次数：在指定时间内对目标主机最大重试次数
  - 连接超时时间：TCP连接超时时间，最小值必须大于1ms；最大连接数和连接超时时间是对TCP和HTTP都有效的通用连接设置
  - 最大等待请求数：待处理请求队列的长度，若该断路器溢出，集群的upstream_rq_pending_overflow计数器就会递增
- 熔断器的常用指标（Istio上下文）
  - 连接错误响应个数：在一个检查周期内，连续出现5xx错误的个数，例502，503状态码
  - 检查周期：将会对检查周期内的响应码进行筛选
  - 隔离实例比例：上游实例中，允许被隔离的最大比例；采用向上取整机制，假设有10个实例，13%则最多会隔离2个实例
  - 最短隔离时间：实例第一次被隔离的时间，之后每次隔离时间为隔离次数与最短隔离时间的乘积
#配置连接池和熔断器
- 断路器的相关设置由circuit_breakers定义
- 与连接池相关的参数有两个定义在cluster的上下文
...
clusters:
- name: ...
  ...
  connect_timeout: ...				#TCP连接的超时时长，即主机网络连接超时，合理的设置可以能够改善因调用服务变慢而导致整个链接变慢的情形
  max_requests_per_connection: ...	#每个连接可以承载的最大请求数，HTTP/1.1和HTTP/2的连接池均受限于此设置，无设置则无限制，1表示禁用keep-alive
  ...
  circuit_breakers: {...}			#熔断相关的配置，可选
    threasholds: []					#适用于特定路由优先级的相关指标及阈值的列表
	- priority: ...					#当前断路器适用的路由优先级
	  max_connections: ...			#可发往上游集群的最大并发连接数，仅适用于HTTP/1,默认为1024；超过指定数量的连接则将其短路
	  max_pending_requests: ...		#允许请求服务时的可挂起的最大请求数，默认为1024，超过指定数量的连接则将其短路
	  max_requests: ...				#Envoy可调度给上游集群的最大并发请求数，默认为1024，仅适用于HTTP/2
	  max_retries: ...				#允许发往上游集群的最大并发重试数量（假设配置了retry_policy),默认为3
	  track_remaining: ...			#其值为true时表示将公布统计数据以显示断路器打开前所剩余的资源数量；默认为false
	  max_connection_pools:			#每个集群可同时打开的最大连接池数量，默认为无限制
  - 显然，将max_connections和max_pending_requests都设置为1，表示 如果超过了1个连接同时发起请求，Envoy就会熔断，从而阻止后续的请求或连接

#docker-compose 断路器示例
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/circuit-breaker# cat docker-compose.yaml
version: '3'

services:
  front-envoy:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
      - ./front-envoy.yaml:/etc/envoy/envoy.yaml
    networks:
      - envoymesh
    expose:
      # Expose ports 80 (for general traffic) and 9901 (for the admin server)
      - "80"
      - "9901"

  webserver01-sidecar:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./envoy-sidecar-proxy.yaml:/etc/envoy/envoy.yaml
    hostname: red
    networks:
      envoymesh:
        ipv4_address: 172.31.35.11
        aliases:
        - webservice1
        - red

  webserver01:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
      - HOST=127.0.0.1
    network_mode: "service:webserver01-sidecar"
    depends_on:
    - webserver01-sidecar

  webserver02-sidecar:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./envoy-sidecar-proxy.yaml:/etc/envoy/envoy.yaml
    hostname: blue
    networks:
      envoymesh:
        ipv4_address: 172.31.35.12
        aliases:
        - webservice1
        - blue

  webserver02:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
      - HOST=127.0.0.1
    network_mode: "service:webserver02-sidecar"
    depends_on:
    - webserver02-sidecar

  webserver03-sidecar:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./envoy-sidecar-proxy.yaml:/etc/envoy/envoy.yaml
    hostname: green
    networks:
      envoymesh:
        ipv4_address: 172.31.35.13
        aliases:
        - webservice1
        - green

  webserver03:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
      - HOST=127.0.0.1
    network_mode: "service:webserver03-sidecar"
    depends_on:
    - webserver03-sidecar

  webserver04-sidecar:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./envoy-sidecar-proxy.yaml:/etc/envoy/envoy.yaml
    hostname: gray
    networks:
      envoymesh:
        ipv4_address: 172.31.35.14
        aliases:
        - webservice2
        - gray

  webserver04:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
      - HOST=127.0.0.1
    network_mode: "service:webserver04-sidecar"
    depends_on:
    - webserver04-sidecar

  webserver05-sidecar:
    image: envoyproxy/envoy-alpine:v1.18-latest
    volumes:
    - ./envoy-sidecar-proxy.yaml:/etc/envoy/envoy.yaml
    hostname: black
    networks:
      envoymesh:
        ipv4_address: 172.31.35.15
        aliases:
        - webservice2
        - black

  webserver05:
    image: ikubernetes/demoapp:v1.0
    environment:
      - PORT=8080
      - HOST=127.0.0.1
    network_mode: "service:webserver05-sidecar"
    depends_on:
    - webserver05-sidecar

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.35.0/24
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/circuit-breaker# cat front-envoy.yaml
admin:
  access_log_path: "/dev/null"
  address:
    socket_address: { address: 0.0.0.0, port_value: 9901 }

static_resources:
  listeners:
  - address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    name: listener_http
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          codec_type: auto
          stat_prefix: ingress_http
          route_config:
            name: local_route
            virtual_hosts:
            - name: backend
              domains:
              - "*"
              routes:
              - match:
                  prefix: "/livez"
                route:
                  cluster: webcluster2
              - match:
                  prefix: "/"				#请求根直接到达webcluster1
                route:
                  cluster: webcluster1
          http_filters:
          - name: envoy.filters.http.router

  clusters:
  - name: webcluster1
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: webcluster1
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: webservice1
                port_value: 80
    circuit_breakers:					#针对webcluster1进行断路器配置
      thresholds:
        max_connections: 1				#最大连接数为1
        max_pending_requests: 1			#并且最大挂载连接数为1时
        max_retries: 3					#重试3次后仍然失败则启用熔断器

  - name: webcluster2
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: webcluster2
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: webservice2
                port_value: 80
    outlier_detection:
      interval: "1s"
      consecutive_5xx: "3"
      consecutive_gateway_failure: "3"
      base_ejection_time: "10s"
      enforcing_consecutive_gateway_failure: "100"
      max_ejection_percent: "30"
      success_rate_minimum_hosts: "2"

root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/circuit-breaker# cat send-requests.sh	#测试脚本
#!/bin/bash
#
if [ $# -ne 2 ]
then
    echo "USAGE: $0 <URL> <COUNT>"
    exit 1;
fi

URL=$1
COUNT=$2
c=1
#interval="0.2"

while [[ ${c} -le ${COUNT} ]];
do
  #echo "Sending GET request: ${URL}"
  curl -o /dev/null -w '%{http_code}\n' -s ${URL} &			#放到后台执行，输出http_code状态码
  (( c++ ))
#  sleep $interval
done

wait
---
root@front-envoy:~/servicemesh_in_practise/Cluster-Manager/circuit-breaker# ./send-requests.sh 172.31.35.2 300
200
200
200
503
503			#有显示503就是断路器打开了，而后又恢复正常了，所以后面有200
200
200
503
200
503
200



####流量管理基础
1. 虚拟主机及路由配置概述
2. 路由配置
  - 路由匹配
    - 基础匹配：prefix, path, safe_regex
    - 高级匹配：headers, query_patameters
  - 路由
    - 路由
    - 重定向
    - 直接响应

#HTTP高级路由
- Envoy基于HTTP router过滤器基于路由表完成多种高级路由机制，包括ADS
  - 将域名映射到虚拟主机
  - path的前缀（prefix）匹配、精确匹配或正则表达式匹配
  - 虚拟主机级别的TLS重定向
  - path级别的path/host重写向
  - 由Envoy直接生成响应报文
  - 显示host rewrite
  - prefix rewrite
  - 基于HTTP标头或路由配置的请求重试或请求超时
  - 基于运行时参数的流量迁移
  - 基于权重或百分比的跨集群流量分割
  - 基于任意标头匹配路由规则
  - 基于优先级的路由
  - 基于hash策略的路由
  - .....  
 ----配置示例 
static_resources:
  listeners:
  - address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    name: listener_http
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          codec_type: auto
          stat_prefix: ingress_http
          route_config:
            name: local_route
            virtual_hosts:
            - name: backend
              domains:				#虚拟主机的名称，路由匹配时将请求报文中的host标头值与此处列表项进行匹配检测
              - "*"
              routes:				#路由条目，匹配到当前虚拟主机的请求中的path匹配检测将针对各route中由match定义条件进行
              - match:				#常用内嵌字段prerix|path|safe_regex|connect_matcher,用于定义基于路径前缀、路径、正则表达式或连接匹配器四者之一定义匹配条件
                  prefix: "/livez"
                route:				#常用内嵌字段cluster|cluster_header|weighted_clusters,基于集群、请求报文中的集群标头或加权集群(流量分割)定义路由目标
                  cluster: webcluster2
              - match:
                  prefix: "/"				
                route:
                  cluster: webcluster1
				redirect: {...}			#重定向请求，但不可与route和redirect一同使用
				direct_response: {...}	#直接响应请求，不可与route和redirect一同使用
			  virtual_clusters: []		#为此虚拟主机定义的用于收集统计信息的虚拟集群列表
          http_filters:
          - name: envoy.filters.http.router
  
 - 域名搜索顺序
  - 将请求报文中的host标头值依次与路由表中定义的各Virtualhost的domain属性值进行比较，并于第一次匹配时终止搜索(短路匹配)：
    - 精确匹配 --> 前缀匹配 --> 后缀匹配 --> '*'通配符  

#docker-compose simple-match示例
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/httproute-simple-match# cat docker-compose.yaml
version: '3'

services:
  front-envoy:
    image: envoyproxy/envoy-alpine:v1.20.0
    volumes:
      - ./front-envoy.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        ipv4_address: 172.31.50.10
    expose:
      # Expose ports 80 (for general traffic) and 9901 (for the admin server)
      - "80"
      - "9901"

  light_blue:
    image: ikubernetes/servicemesh-app:latest
    networks:
      envoymesh:
        aliases:
          - light_blue
          - blue
    environment:
      - SERVICE_NAME=light_blue
    expose:
      - "80"

  dark_blue:
    image: ikubernetes/servicemesh-app:latest
    networks:
      envoymesh:
        aliases:
          - dark_blue
          - blue
    environment:
      - SERVICE_NAME=dark_blue
    expose:
      - "80"

  light_green:
    image: ikubernetes/servicemesh-app:latest
    networks:
      envoymesh:
        aliases:
          - light_green
          - green
    environment:
      - SERVICE_NAME=light_green
    expose:
      - "80"

  dark_green:
    image: ikubernetes/servicemesh-app:latest
    networks:
      envoymesh:
        aliases:
          - dark_green
          - green
    environment:
      - SERVICE_NAME=dark_green
    expose:
      - "80"

  light_red:
    image: ikubernetes/servicemesh-app:latest
    networks:
      envoymesh:
        aliases:
          - light_red
          - red
    environment:
      - SERVICE_NAME=light_red
    expose:
      - "80"

  dark_red:
    image: ikubernetes/servicemesh-app:latest
    networks:
      envoymesh:
        aliases:
          - dark_red
          - red
    environment:
      - SERVICE_NAME=dark_red
    expose:
      - "80"

  gray:
    image: ikubernetes/servicemesh-app:latest
    networks:
      envoymesh:
        aliases:
          - gray
          - grey
    environment:
      - SERVICE_NAME=gray
    expose:
      - "80"

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.50.0/24
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/httproute-simple-match# cat front-envoy.yaml
admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: vh_001
              domains: ["ilinux.io", "*.ilinux.io", "ilinux.*"]
              routes:
              - match:
                  path: "/service/blue"				#基于path,sage_regex,prefix的路由
                route:
                  cluster: blue
              - match:
                  safe_regex:
                    google_re2: {}
                    regex: "^/service/.*blue$"
                redirect:
                  path_redirect: "/service/blue"
              - match:
                  prefix: "/service/yellow"
                direct_response:
                  status: 200
                  body:
                    inline_string: "This page will be provided soon later.\n"
              - match:
                  prefix: "/"
                route:
                  cluster: red
            - name: vh_002
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: gray
          http_filters:
          - name: envoy.filters.http.router

  clusters:
  - name: blue
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    http2_protocol_options: {}
    load_assignment:
      cluster_name: blue
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: blue
                port_value: 80

  - name: red
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    http2_protocol_options: {}
    load_assignment:
      cluster_name: red
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: red
                port_value: 80

  - name: green
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    http2_protocol_options: {}
    load_assignment:
      cluster_name: green
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: green
                port_value: 80

  - name: gray
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    http2_protocol_options: {}
    load_assignment:
      cluster_name: gray
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: gray
                port_value: 80
#docker-compose header-match示例
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/httproute-headers-match# cat docker-compose.yaml
version: '3'

services:
  front-envoy:
    image: envoyproxy/envoy-alpine:v1.20.0
    volumes:
      - ./front-envoy.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        ipv4_address: 172.31.52.10
    expose:
      # Expose ports 80 (for general traffic) and 9901 (for the admin server)
      - "80"
      - "9901"

  demoapp-v1.0-1:
    image: ikubernetes/demoapp:v1.0
    hostname: demoapp-v1.0-1
    networks:
      envoymesh:
        aliases:
          - demoappv10
    expose:
      - "80"

  demoapp-v1.0-2:
    image: ikubernetes/demoapp:v1.0
    hostname: demoapp-v1.0-2
    networks:
      envoymesh:
        aliases:
          - demoappv10
    expose:
      - "80"

  demoapp-v1.1-1:
    image: ikubernetes/demoapp:v1.1
    hostname: demoapp-v1.1-1
    networks:
      envoymesh:
        aliases:
          - demoappv11
    expose:
      - "80"

  demoapp-v1.1-2:
    image: ikubernetes/demoapp:v1.1
    hostname: demoapp-v1.1-2
    networks:
      envoymesh:
        aliases:
          - demoappv11
    expose:
      - "80"

  demoapp-v1.2-1:
    image: ikubernetes/demoapp:v1.2
    hostname: demoapp-v1.2-1
    networks:
      envoymesh:
        aliases:
          - demoappv12
    expose:
      - "80"

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.52.0/24
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/httproute-headers-match# cat front-envoy.yaml
admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: vh_001
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                  headers:						#基于header的路由
                  - name: X-Canary
                    exact_match: "true"
                route:
                  cluster: demoappv12
              - match:
                  prefix: "/"
                  query_parameters:
                  - name: "username"
                    string_match:
                      prefix: "vip_"
                route:
                  cluster: demoappv11
              - match:
                  prefix: "/"
                route:
                  cluster: demoappv10
          http_filters:
          - name: envoy.filters.http.router

  clusters:
  - name: demoappv10
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: demoappv10
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: demoappv10
                port_value: 80

  - name: demoappv11
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: demoappv11
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: demoappv11
                port_value: 80

  - name: demoappv12
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: demoappv12
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: demoappv12
                port_value: 80

	
####流量管理进阶
- 流量迁移
- 流量分割
- 流量镜像
- 故障注入
- 超时和重试
- CORS（跨域资源共享）

#灰度发布的实施方式
- 基于负载均衡器进行灰度发布
  - 在服务入口的支持流量策略的负载均衡器上配置流量分布机制
  - 仅支持入口服务进行灰度，无法支撑后端服务需求
- 基于Kubernetes进行灰度发布
  - 根据新旧版本应用所在的Pod数量比例进行流量分配
  - 不断滚动更新旧版本Pod到新版本
    - 先增后减、先减后增、又增又减
- 基于服务网格进行灰度发布
  - 对于Envoy或Istio来说，灰度发布仅是流量治理机制的一种典型应用
  - 通过控制平面，将流量配置策略分发至对目标服务的请求发起方的envoy sidecar上即可
  - 支持基于请求内容的流量分配机制，例如浏览器类型、cookie等
  - 服务访问入口通常是一个单独部署的Envoy Gateway
#高级路由：流量迁移
- 通过在路由中配置运行时对象选择特定路由以及相应集群的概率的变动，从而实现将虚拟主机中特定路由的流量逐渐从一个集群迁移到另一个集群
...
routes:
- match:								#定义路由匹配参数
    prefix|path|safe_regex:...			#流量过滤条件，三者之一来表示匹配模式
    runtime_fraction: 					#额外匹配指定的运行时键值，每次评估匹配路径时，它必需低于此字段指示的匹配百分比；支持渐进式修改	
      default_value:					#运行时键值不可用时，则使用此默认值
	    numerator:						#指定分子，默认为0
		denominator:					#指定分母，小于分子时，最终百分比为1，分母可固定使用HUNDRED(默认), TEN_THOUSAND和MILLION
	  runtime_key: routing.traffic_shift.KEY		#指定要使用的运行时键，其值需要用户自定义
  route:
	cluster: app1_v1
- match:
    prefix|path|safe_regex:...			#此处的匹配条件应该与前一个路由匹配条件相同，以确保能够分割流量
  route:
	cluster: app1_v2  					#此处的集群通常是前一个路由项目中的目标集群应用程序的不同版本
- 在路由匹配方面，Envoy在检测到第一个匹配时即终止后续检测；因而，流量迁移应该如此配置
  - 配置两个使用相同的match条件的路由条目
  - 在第一个路由条目中配置runtime_fraction对象，并设定其接收的流量比例
  - 该流量比例之外的其它请求将由第二个路由条目所捕获
- 用户再通过不断地通过Envoy的admin接口修改runtime_fraction对象的值完成流量迁移
  - 例如：curl -X POST http://envoy_ip:admin_port/runtime_modify?routing.traffic_shift.KEY=90		#routing.traffic_shift.KEY此值就是分子的大小
  
#docker-compose流量迁移示例
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/http-traffic-shifting# ls
docker-compose.yaml  front-envoy.yaml  README.md  send-request.sh
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/http-traffic-shifting# cat docker-compose.yaml
version: '3'

services:
  front-envoy:
    image: envoyproxy/envoy-alpine:v1.20.0
    volumes:
      - ./front-envoy.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        ipv4_address: 172.31.55.10
    expose:
      # Expose ports 80 (for general traffic) and 9901 (for the admin server)
      - "80"
      - "9901"

  demoapp-v1.0-1:
    image: ikubernetes/demoapp:v1.0
    hostname: demoapp-v1.0-1
    networks:
      envoymesh:
        aliases:
          - demoappv10
    expose:
      - "80"

  demoapp-v1.0-2:
    image: ikubernetes/demoapp:v1.0
    hostname: demoapp-v1.0-2
    networks:
      envoymesh:
        aliases:
          - demoappv10
    expose:
      - "80"

  demoapp-v1.0-3:
    image: ikubernetes/demoapp:v1.0
    hostname: demoapp-v1.0-3
    networks:
      envoymesh:
        aliases:
          - demoappv10
    expose:
      - "80"

  demoapp-v1.1-1:
    image: ikubernetes/demoapp:v1.1
    hostname: demoapp-v1.1-1
    networks:
      envoymesh:
        aliases:
          - demoappv11
    expose:
      - "80"

  demoapp-v1.1-2:
    image: ikubernetes/demoapp:v1.1
    hostname: demoapp-v1.1-2
    networks:
      envoymesh:
        aliases:
          - demoappv11
    expose:
      - "80"

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.55.0/24
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/http-traffic-shifting# cat front-envoy.yaml
admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

layered_runtime:			#这里需要打开运行时环境层，后面才能通过管理接口进行POST修改
  layers:
  - name: admin
    admin_layer: {}

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: demoapp
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"							#匹配条件
                  runtime_fraction:						#打开流量迁移功能
                    default_value:
                      numerator: 100					#分子为100
                      denominator: HUNDRED				#分母为100
                    runtime_key: routing.traffic_shift.demoapp		#可以调整此key来改变分子的大小，当分子/分母=1时，流量全部流下来，当值为0时流量将会迁移到同样匹配条件的集群之上
                route:
                  cluster: demoappv10
              - match:
                  prefix: "/"							#匹配条件中上面一样，envoy匹配到第一个条件后将不会向后进行检测，当进行流量迁移时此匹配将会生效
                route:
                  cluster: demoappv11
          http_filters:
          - name: envoy.filters.http.router

  clusters:
  - name: demoappv10
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: demoappv10
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: demoappv10
                port_value: 80

  - name: demoappv11
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: demoappv11
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: demoappv11
                port_value: 80
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/http-traffic-shifting# docker-compose up
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/http-traffic-shifting# cat send-request.sh
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/http-traffic-shifting# cat send-request.sh
#!/bin/bash
declare -i ver10=0
declare -i ver11=0

interval="0.2"

while true; do
        if curl -s http://$1 | grep 'demoapp v1.0' &> /dev/null; then
                # $1 is the host address of the front-envoy.
                ver10=$[$ver10+1]
        else
                ver11=$[$ver11+1]
        fi
        echo "demoapp-v1.0:demoapp-v1.1 = $ver10:$ver11"
        sleep $interval
done
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/http-traffic-shifting# ./send-request.sh 172.31.55.10
demoapp-v1.0:demoapp-v1.1 = 1:0
demoapp-v1.0:demoapp-v1.1 = 2:0
demoapp-v1.0:demoapp-v1.1 = 3:0
demoapp-v1.0:demoapp-v1.1 = 4:0
demoapp-v1.0:demoapp-v1.1 = 5:0
demoapp-v1.0:demoapp-v1.1 = 6:0
demoapp-v1.0:demoapp-v1.1 = 7:0
demoapp-v1.0:demoapp-v1.1 = 8:0
demoapp-v1.0:demoapp-v1.1 = 9:0
----通过POST方法进行流量迁移
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/http-traffic-shifting# curl -X POST 172.31.55.10:9901/runtime_modify?routing.traffic_shift.demoapp=95		#老集群保留95%的流量，迁移5%的流量到新集群之上，front-envoy.yaml需要开启layered_runtime方可使用POST进行修改，routing.traffic_shift.demoapp此为front-envoy.yaml中定义的key，更改此会就是更改分子的值
OK			
demoapp-v1.0:demoapp-v1.1 = 97:5	#此时流量过来了
demoapp-v1.0:demoapp-v1.1 = 98:5
demoapp-v1.0:demoapp-v1.1 = 99:5
demoapp-v1.0:demoapp-v1.1 = 100:5
demoapp-v1.0:demoapp-v1.1 = 101:5
demoapp-v1.0:demoapp-v1.1 = 102:5

#高级路由：流量分割
- HTTP router过滤器支持在一个路由中指定多个上游具有权重属性的集群，而后将流量基于权重调度至此些集群其中之一
...
routes:
- match: {...}
  route:
    weight_clusters: {...} 
	  clusters: []					#与当前路由关联的一个或多个集群，必选参数
	  - name: ...					#目标集群名称；也可以使用"cluster_header"字段来指定集群；二者互斥
	    weight: ...					#集群权重，取值范围为0至total_weight
		metadata_match: {...}	#子集负载均衡器使用的端点元数据匹配条件，可选参数，仅用于上游集群中具有与此字段中设置的元数据匹配的元数据端点以进行流量分配
	  total_weight: ...				#总权重值，默认为100
	  runtime_key_prefix: ...		#可选参数，用于设定键前缀，从而每个集群以"runtime_key_prefix + . + cluster[i].name"为其键名，并能够以运行时键值的方式为每个集群提供权重；其中，cluster[i].name表示列表中第i个集群名称
	  ...
- 类似流量迁移，流量分割中，分配给每个集群的权重也可以使用运行时参数进行调整；不同的是流量迁移是在route中的match中配置，而流量分割是在route中的route中配置
  
#docker-compose流量分割示例
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/http-traffic-splitting# cat docker-compose.yaml
version: '3'

services:
  front-envoy:
    image: envoyproxy/envoy-alpine:v1.20.0
    volumes:
      - ./front-envoy.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        ipv4_address: 172.31.57.10
    expose:
      # Expose ports 80 (for general traffic) and 9901 (for the admin server)
      - "80"
      - "9901"

  demoapp-v1.0-1:
    image: ikubernetes/demoapp:v1.0
    hostname: demoapp-v1.0-1
    networks:
      envoymesh:
        aliases:
          - demoappv10
    expose:
      - "80"

  demoapp-v1.0-2:
    image: ikubernetes/demoapp:v1.0
    hostname: demoapp-v1.0-2
    networks:
      envoymesh:
        aliases:
          - demoappv10
    expose:
      - "80"

  demoapp-v1.0-3:
    image: ikubernetes/demoapp:v1.0
    hostname: demoapp-v1.0-3
    networks:
      envoymesh:
        aliases:
          - demoappv10
    expose:
      - "80"

  demoapp-v1.1-1:
    image: ikubernetes/demoapp:v1.1
    hostname: demoapp-v1.1-1
    networks:
      envoymesh:
        aliases:
          - demoappv11
    expose:
      - "80"

  demoapp-v1.1-2:
    image: ikubernetes/demoapp:v1.1
    hostname: demoapp-v1.1-2
    networks:
      envoymesh:
        aliases:
          - demoappv11
    expose:
      - "80"

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.57.0/24
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/http-traffic-splitting# cat front-envoy.yaml
admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

layered_runtime:
  layers:
  - name: admin
    admin_layer: {}

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: demoapp
              domains: ["*"]
              routes:
              routes:
              - match:
                  prefix: "/"
                route:												#与前面流量迁移不同的时，配置定义在route配置段中
                  weighted_clusters:						
                    clusters:
                    - name: demoappv10
                      weight: 100
                    - name: demoappv11
                      weight: 0
                    total_weight: 100								#多个集群权重值必须等于此定义的值
                    runtime_key_prefix: routing.traffic_split.demoapp		#通过此key来调整集群权重值
          http_filters:
          - name: envoy.filters.http.router

  clusters:
  - name: demoappv10
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: demoappv10
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: demoappv10
                port_value: 80

  - name: demoappv11
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: demoappv11
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: demoappv11
                port_value: 80
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/http-traffic-splitting# cat send-request.sh
#!/bin/bash
declare -i ver10=0
declare -i ver11=0

interval="0.2"

while true; do
        if curl -s http://$1/hostname | grep "demoapp v1.0" &> /dev/null; then
                # $1 is the host address of the front-envoy.
                ver10=$[$ver10+1]
        else
                ver11=$[$ver11+1]
        fi
        echo "demoapp-v1.0:demoapp-v1.1 = $ver10:$ver11"
        sleep $interval
done
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/http-traffic-splitting# ./send-request.sh 172.31.57.10
demoapp-v1.0:demoapp-v1.1 = 1:0		#百分百流量到v1.0
demoapp-v1.0:demoapp-v1.1 = 2:0
demoapp-v1.0:demoapp-v1.1 = 3:0
demoapp-v1.0:demoapp-v1.1 = 4:0
demoapp-v1.0:demoapp-v1.1 = 5:0
demoapp-v1.0:demoapp-v1.1 = 6:0
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/http-traffic-splitting# curl -XPOST 'http://172.31.57.10:9901/runtime_modify?routing.traffic_split.demoapp.demoappv10=0&routing.traffic_split.demoapp.demoappv11=100'	#此时进行流量分割，针对此key: routing.traffic_split.demoapp + . + 集群名称进行权重值赋值，将v1.0流量全部迁移到v1.1
OK
demoapp-v1.0:demoapp-v1.1 = 498:149		#此后流量全都走向v1.1
demoapp-v1.0:demoapp-v1.1 = 498:150
demoapp-v1.0:demoapp-v1.1 = 498:151
demoapp-v1.0:demoapp-v1.1 = 498:152
demoapp-v1.0:demoapp-v1.1 = 498:153
demoapp-v1.0:demoapp-v1.1 = 498:154
demoapp-v1.0:demoapp-v1.1 = 498:155
demoapp-v1.0:demoapp-v1.1 = 498:156
demoapp-v1.0:demoapp-v1.1 = 498:157
demoapp-v1.0:demoapp-v1.1 = 498:158

#HTTP流量镜像
- 关于流量镜像
  - 流量镜像，也称为流量复制或影子镜像
  - 流量镜像功能通常用于在生产环境进行测试，通过将生产流量镜像拷贝到测试集群或者新版本集群，实现新版本接近真实环境的测试，旨在有效地降低新版本上线的风险
- 流量镜像可用于以下场景
  - 验证新版本：实时对比镜像流量与生产流量的输出结果，完成新版本目标验证
  - 测试：用生产实例的真实流量进行模拟测试
  - 隔离测试数据库：与数据处理相关的业务，可使用空的数据存储并加载测试数据，针对该数据进行镜像流量操作，实现测试数据的隔离
#配置HTTP流量镜像
- 将流量转发至一个集群(主集群)的同时再转发到另一个集群(影子集群)
  - 无须等待影子集群返回响应
  - 支持收集影子集群的常规统计信息，常用于测试
route:
  cluster|weight_clusters:
  ...
  request_mirror_policies: []
  - cluster: ...
    runtime_fraction: {...}
	  default_value:				#运行时键值不可用时，则使用此默认值
	    numerator:					#指定分子，默认为0
		denominator:				#指定分母，小于分子时，最终百分比为1，分母可固定使用HUNDRED(默认)、TEN_THOUSAND和MILLION
	  runtime_key: routing.request_mirror.KEY	#指定要使用的运行时键，其值需要用户自定义
	trace_sampled: {...}			#是否对trace span进行采样，默认为true
- 默认情况下，路由器会镜像所有请求；也可以使用如下参数配置转发的流量比例
  - runtime_key: 运行时键，用于明确定义向影子集群转发的流量的百分比，取值范围为0-10000，每个数字表示0.01%的请求比例；定义了此键却未指定其值时，默认为0
  
#docker-compose流量镜像示例
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/http-request-mirror# cat docker-compose.yaml
version: '3'

services:
  front-envoy:
    image: envoyproxy/envoy-alpine:v1.20.0
    volumes:
      - ./front-envoy.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        ipv4_address: 172.31.60.10
    expose:
      # Expose ports 80 (for general traffic) and 9901 (for the admin server)
      - "80"
      - "9901"

  demoapp-v1.0-1:
    image: ikubernetes/demoapp:v1.0
    hostname: demoapp-v1.0-1
    networks:
      envoymesh:
        aliases:
          - demoappv10
    expose:
      - "80"

  demoapp-v1.0-2:
    image: ikubernetes/demoapp:v1.0
    hostname: demoapp-v1.0-2
    networks:
      envoymesh:
        aliases:
          - demoappv10
    expose:
      - "80"

  demoapp-v1.0-3:
    image: ikubernetes/demoapp:v1.0
    hostname: demoapp-v1.0-3
    networks:
      envoymesh:
        aliases:
          - demoappv10
    expose:
      - "80"

  demoapp-v1.1-1:
    image: ikubernetes/demoapp:v1.1
    hostname: demoapp-v1.1-1
    networks:
      envoymesh:
        aliases:
          - demoappv11
    expose:
      - "80"

  demoapp-v1.1-2:
    image: ikubernetes/demoapp:v1.1
    hostname: demoapp-v1.1-2
    networks:
      envoymesh:
        aliases:
          - demoappv11
    expose:
      - "80"

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.60.0/24
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/http-request-mirror# cat front-envoy.yaml
admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

layered_runtime:
  layers:
  - name: admin
    admin_layer: {}

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: demoapp
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: demoappv10
                  request_mirror_policies:
                  - cluster: demoappv11
                    runtime_fraction:
                      default_value:
                        numerator: 20				# 默认只镜像demoappv10集群上20%的流量到该集群
                        denominator: HUNDRED
                      runtime_key: routing.request_mirror.demoapp
          http_filters:
          - name: envoy.filters.http.router

  clusters:
  - name: demoappv10
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: demoappv10
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: demoappv10
                port_value: 80

  - name: demoappv11
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: demoappv11
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: demoappv11
                port_value: 80
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/http-request-mirror# docker-compose up
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/http-request-mirror# curl 172.31.60.10
iKubernetes demoapp v1.0 !! ClientIP: 172.31.60.10, ServerName: demoapp-v1, ServerIP: 172.31.60.3!
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/http-request-mirror# curl 172.31.60.10	#第二次请求，输出仍然是demoappv10的结果，镜像集群是不会影响结果的
iKubernetes demoapp v1.0 !! ClientIP: 172.31.60.10, ServerName: demoapp-v1, ServerIP: 172.31.60.5!
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/http-request-mirror# curl 172.31.60.10
iKubernetes demoapp v1.0 !! ClientIP: 172.31.60.10, ServerName: demoapp-v1, ServerIP: 172.31.60.4!
--控制台输出结果 
demoapp-v1.0-3_1  | 172.31.60.10 - - [17/Apr/2022 05:48:40] "GET / HTTP/1.1" 200 -
demoapp-v1.1-1_1  | 172.31.60.10 - - [17/Apr/2022 05:48:44] "GET / HTTP/1.1" 200 -		#此流量是第二次请求到镜像集群返回的结果，因为默认镜像20%流量
demoapp-v1.0-1_1  | 172.31.60.10 - - [17/Apr/2022 05:48:44] "GET / HTTP/1.1" 200 -		#此流量是第二次请求返回的结果 
demoapp-v1.0-2_1  | 172.31.60.10 - - [17/Apr/2022 05:48:45] "GET / HTTP/1.1" 200 -
----我们可以通过runtime_layer中的routing.request_mirror.demoapp键来调整镜像的流量的比例，例如，将其调整到100%，即镜像所有流量的方法如下；
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/http-request-mirror# curl -XPOST 'http://172.31.60.10:9901/runtime_modify?routing.request_mirror.demoapp=100'
OK
demoapp-v1.0-2_1  | 172.31.60.10 - - [17/Apr/2022 05:52:40] "GET / HTTP/1.1" 200 -		#此时是100%镜像，每一个请求都会发往两个集群
demoapp-v1.1-1_1  | 172.31.60.10 - - [17/Apr/2022 05:52:41] "GET / HTTP/1.1" 200 -
demoapp-v1.0-2_1  | 172.31.60.10 - - [17/Apr/2022 05:52:41] "GET / HTTP/1.1" 200 -
demoapp-v1.1-1_1  | 172.31.60.10 - - [17/Apr/2022 05:52:41] "GET / HTTP/1.1" 200 -
demoapp-v1.0-2_1  | 172.31.60.10 - - [17/Apr/2022 05:52:41] "GET / HTTP/1.1" 200 -
demoapp-v1.1-2_1  | 172.31.60.10 - - [17/Apr/2022 05:52:42] "GET / HTTP/1.1" 200 -
demoapp-v1.0-3_1  | 172.31.60.10 - - [17/Apr/2022 05:52:42] "GET / HTTP/1.1" 200 -
demoapp-v1.0-3_1  | 172.31.60.10 - - [17/Apr/2022 05:52:42] "GET / HTTP/1.1" 200 -
demoapp-v1.1-2_1  | 172.31.60.10 - - [17/Apr/2022 05:52:42] "GET / HTTP/1.1" 200 -

#其它可定义的路由管理机制
- 路由过滤器额外还可执行如下操作
  - metadata_match: 子集负载均衡器使用的端点元数据匹配条件
  - prefix_rewrite: 前缀重写，即将下游请求的path转发至上游主机时重写为另一个path
  - host_rewrite: 主机头重写
  - auto_host_rewrite: 自动主机头重写，仅适用于strict_dns或logical_dns类型的集群
  - timeout: 上游超时时长，默认为15s
  - idle_timeout: 路由的空间超时时长，未指定时表示不超时
  - retry_policy: 重试策略，优先于虚拟主机级别的重试策略
  - cors: 跨域资源共享
  - priority: 路由优先级
  - rate_limits: 速率限制
  - host_policy: 上游集群使用环哈希算法时为其指定用于环形哈希负载均衡的哈希策略表；通常哈希计算的目标是指定的标头、cookie或者请求报文的源IP地址
  

#混沌工作和故障注入
- 复杂的分布式服务体系中，故障发生的随机性和不可预测性都大大增加
  - 随着服务化、微服务和持续集成的逐渐普及，快速迭代的门槛越来越低，但是对复杂系统稳定性的考验却在成倍增长
    - 分布式系统天生包含大量的交互、依赖点，故障点层出不穷；硬盘故障、网络故障、流量激增压垮某些组件、外部系统故障、不合理的降级方案等等都会成为常见问题
	- 人力无法改变此种局面，更需要做的是致力于在这些异常被触发之前尽可能多地识别出导致此类异常的系统脆弱环节或组件，进而有针对性地对其加固，以避免故障发生，打造出更具弹性的系统；这正是混沌工程诞生的原因之一
- 混沌工程是一种通过实践探究的方式来理解系统行为的方法，也是一套通过在系统基础设施上进行实验，主动找出系统中的脆弱环节的方法学
  - 混沌工程是在分布式系统上进行实验的学科，旨在提升系统容错性，建立系统抵御生产环境中发生不可预知问题的信心
  - 混沌工程的意义在于，能让复杂系统中根深蒂固的混乱和不稳定性浮出表面，让工程师可以更全面地理解这些系统性固有现象，从而在分布式系统中实现更好的工程设计，不断提高系统弹性
#混沌工程的现实功用
- 对于架构师：验证系统架构的容错能力，比如验证现在提倡的面向失败设计的系统
- 对于开发和运维： 提高故障的应急效率，实现故障告警、定位、恢复的有效和高效性
- 对于测试：弥补传统测试方法留下的空白，混沌工程从系统的角度进行测试，降低故障复发率，这有别于传统测试方法从用户角度的进行方式
- 对于产品和设计：通过混沌事件查看产品的表现，提升客户使用体验
#故障注入输入样例
- CPU高负载
- 磁盘高负载，频繁读写磁盘
- 磁盘空间不足
- 优雅的下线应用，使用应用的stop脚本平滑的停止应用
- 通过kill进程直接停止应用，可能造成数据不一致
- 网络恶化：随机改变一些包数据，使数据内容不正确
- 网络延迟：将包延迟一个特定范围的时间
- 网络丢包：构造一个tcp不完全失败的丢包率
- 网络黑洞：忽略来自某个IP的包
- 外部服务不可达：将外部服务的域名指向本地环回地址或将访问外部服务的端口的OUTPUT数据包丢弃

#HTTP故障注入过滤器
- 故障注入在Envoy中的实现上类似于重写向、重写和重试，它们通过修改HTTP请求或应答的内容完成
  - 它由专用的故障注入过滤器(fault.injection)实现，用于测试微服务对不同形式的故障韧性
    - 需要使用名称envoy.filters.http.fault配置此过滤器
  - 通过用户指定的错误代码注入延迟（delay）和请求中止（abort），从而模拟出分阶段的不同故障情形
  - 故障范围仅限于通过网络进行通信的应用程序可观察到的范围，不支持模拟本地主机上的CPU和磁盘故障
- 过滤器配置格式
{
  delay: {...},					#注入延迟，延迟和请求中止至少要定义一个
  abort: {...},					#注入请求中止
  upstream_cluster: {...},		#过滤器适配的上游集群，即仅生效于指定的目标集群
  headers: [],					#过滤器适配的请求报文标头列表，匹配检测时，各标头间为"与"关系
  downstream_nodes: [],			#要注入故障的下游主机列表，未指定时将匹配所有主机
  max_active_faults: {...},		#在同一个时间点所允许的最大活动故障数，默认为不限制；可以被运行时参数config_http_filters_fault_injection_runtime所覆盖
  response_rate_limit: {...},	#响应速率限制，可以被运行时参数fault.http.rate_limit.response_percent所覆盖；此为单流或连接级别的限制
  ...
}
#HTTP故障注入
- 注入"延迟"
{
  fixed_delay: {...},		#持续时长，将请求转发至上游主机之前添加固定延迟
  header_delay: {...},		#基于HTTP标头的指定控制故障延迟
  percentage: {...},		#将注入迟延的 操作/连接/请求（operations/connections/requests）的百分比，意指将错误注入到多大比例的请求操作上
}
- 注入"请求中止"
{
  http_status: ...,			#用于中止HTTP请求的状态码；http_status, grpc_status和header_status三者仅能且必须定义一个
  grpc_status: ...,			#用于中止grpc请求的状态码
  header_abort: {...},		#由HTTP标头控制的中止
  percentage: {...}			#将使用的错误代码中止的 请求/操作/连接 的百分比
}
- 响应报文的速率限制 
{
  fixed_limit: {limit_kbps: ...},		#固定速率，单KiB/s
  header_limit: {...},					#限制为HTTP首部的指定的速率
  percentage: {...},					#将注入的速率限制为 操作/连接/请求（operations/connections/requests）的百分比
}

#docker-compose故障注入示例
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/fault-injection# cat docker-compose.yaml
version: '3.3'

services:
  envoy:
    image: envoyproxy/envoy-alpine:v1.20.0
    volumes:
    - ./front-envoy.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        ipv4_address: 172.31.62.10
        aliases:
        - front-proxy
    expose:
      # Expose ports 80 (for general traffic) and 9901 (for the admin server)
      - "80"
      - "9901"

  service_blue:
    image: ikubernetes/servicemesh-app:latest
    volumes:
      - ./service-envoy-fault-injection-abort.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        aliases:
          - service_blue
          - colored
    environment:
      - SERVICE_NAME=blue
    expose:
      - "80"

  service_green:
    image: ikubernetes/servicemesh-app:latest
    networks:
      envoymesh:
        aliases:
          - service_green
          - colored
    environment:
      - SERVICE_NAME=green
    expose:
      - "80"

  service_red:
    image: ikubernetes/servicemesh-app:latest
    volumes:
      - ./service-envoy-fault-injection-delay.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        aliases:
          - service_red
          - colored
    environment:
      - SERVICE_NAME=red
    expose:
      - "80"

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.62.0/24
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/fault-injection# cat front-envoy.yaml
admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

layered_runtime:
  layers:
  - name: admin
    admin_layer: {}

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: backend
              domains:
              - "*"
              routes:
              - match:
                  prefix: "/service/blue"
                route:
                  cluster: blue_abort
              - match:
                  prefix: "/service/red"
                route:
                  cluster: red_delay
              - match:
                  prefix: "/service/green"
                route:
                  cluster: green
              - match:
                  prefix: "/service/colors"
                route:
                  cluster: mycluster
          http_filters:
          - name: envoy.filters.http.router

  clusters:
  - name: red_delay
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: red_delay
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: service_red
                port_value: 80

  - name: blue_abort
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: blue_abort
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: service_blue
                port_value: 80

  - name: green
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: green
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: service_green
                port_value: 80

  - name: mycluster
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: mycluster
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: colored
                port_value: 80
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/fault-injection# cat service-envoy-fault-injection-abort.yaml
admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

layered_runtime:
  layers:
  - name: admin
    admin_layer: {}

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: service
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: local_service
          http_filters:
          - name: envoy.filters.http.fault				#故障注入7层过滤器
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.fault.v3.HTTPFault
              max_active_faults: 100
              abort:									#请求中止故障注入
                http_status: 503				
                percentage:
                  numerator: 10							#向10%的请求注入503中断
                  denominator: HUNDRED
          - name: envoy.filters.http.router
            typed_config: {}

  clusters:
  - name: local_service
    connect_timeout: 0.25s
    type: strict_dns
    lb_policy: round_robin
    load_assignment:
      cluster_name: local_service
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: 127.0.0.1
                port_value: 8080
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/fault-injection# cat service-envoy-fault-injection-delay.yaml
admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

layered_runtime:
  layers:
  - name: admin
    admin_layer: {}

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: service
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: local_service
          http_filters:
          - name: envoy.filters.http.fault
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.fault.v3.HTTPFault
              max_active_faults: 100		#在同一个时间点所允许的最大活动故障数，默认为不限制
              delay:						#延迟故障注入
                fixed_delay: 10s
                percentage:
                  numerator: 10				#向10%的请求注入10秒钟的延迟
                  denominator: HUNDRED
          - name: envoy.filters.http.router
            typed_config: {}

  clusters:
  - name: local_service
    connect_timeout: 0.25s
    type: strict_dns
    lb_policy: round_robin
    load_assignment:
      cluster_name: local_service
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: 127.0.0.1
                port_value: 8080
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/fault-injection# docker-compose up
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/fault-injection# cat curl_format.txt
    time_namelookup:  %{time_namelookup}\n
       time_connect:  %{time_connect}\n
    time_appconnect:  %{time_appconnect}\n
   time_pretransfer:  %{time_pretransfer}\n
      time_redirect:  %{time_redirect}\n
 time_starttransfer:  %{time_starttransfer}\n
                    ----------\n
         time_total:  %{time_total}\n
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/fault-injection# curl -w"@curl_format.txt" -o /dev/null -s "http://172.31.62.10/service/red"			#反复向/service/red发起多次请求，被注入延迟的请求，会有较长的响应时长；
    time_namelookup:  0.000035
       time_connect:  0.000263
    time_appconnect:  0.000000
   time_pretransfer:  0.000317
      time_redirect:  0.000000
 time_starttransfer:  10.003420
                    ----------
         time_total:  10.003508				#延迟了10s
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/fault-injection# curl -o /dev/null -w '%{http_code}\n' -s "http://172.31.62.10/service/blue"		#反复向/service/blue发起多次请求，被注入中断的请求，则响应以503代码；
503
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/fault-injection# curl -o /dev/null -w '%{http_code}\n' -s "http://172.31.62.10/service/green"		#反复向/service/green发起多次请求，将无故障注入
200
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/fault-injection# while true;do curl -o /dev/null -w '%{http_code}\n' -s "http://172.31.62.10/service/colors";sleep 0.5;done		#发往/service/colors的请求，会被调度至red_delay、blue_abort和green三个集群，它们有的可能被延迟、有的可能被中断；


#CORS
- 跨域资源共享是HTTP的访问控制机制
  - 它使用额外的HTTP头来告诉浏览器让运行在一个origin(domain)上的Web应用被准许访问来自不同源服务器上的指定的资源
  - 当一个资源从与该资源本身所在的服务器不同的域、协议或端口请求一个资源时，资源会发起一个跨域HTTP请求
  - 比如，站点http://domain-a.com的某个HTML页面通过<img>的src请求http://domain-b.com/image.jpg；网络上的许多页面都会加载来自不同域的CSS样式表，图像和脚本等资源
- 出于安全原因，浏览器限制从脚本内发起的跨源HTTP请求
  - 例如，XMLHttpRequest和Fetch API遵循同源策略
  - 这意味着使用这些API的Web应用程序只能从加载应用程序的同一个域请求HTTP资源，除非响应报文包含了正确CORS响应头
- 跨域资源共享(CORS)机制允许Web应用服务器进行跨域访问控制，从而使跨域数据传输得以安全进行


#局部故障处理机制
- retry: 分布式环境中对远程资源和服务的调用可能会由瞬态故障（短时间内可自行恢复的故障）而失败，一般情况下，重试机制可解决此类问题
  - 常见的瞬态故障有网络连接速度慢、超时、资源过量使用或暂时不可用等
- timeout: 此外，也存在因意外事件而导致故障，并且可能需要较长的时间才能得以恢复；
  - 此类故障的严重性范围涵盖从部分连接中断到服务完全失败
    - 连续重试和长时间的等待对该类场景都没有太大意义
	- 应用程序应迅速接受该操作已失败并主动地应对该失败
  - 可以将调用服务的操作配置为实施"超时"，若该服务在超时时长内未能响应，则以失败消息响应
- circuit-breaker: 还有，若服务非常繁忙，则系统某一部分的故障可能会导致级联故障；
  - 对此，简单的超时策略可能导致对同一操作的许多并发请求被阻止，直到超时时长耗尽为止
  - 这些被阻止的请求可能包含关键的系统资源，例如内存、线程和数据库连接等
    - 这类资源的耗尽可能导致需要使用相同资源的系统其他可能不相关的部分出现故障
	- 于是，此时最好立即使操作失败，并且仅在可能成功的情况下才尝试调用服务
#HTTP请求重试（route.RetryPolicy） 
- Envoy支持在虚拟主机及路由级别配置中以及通过特定请求的标头配置重试
  - 路由级别重试的优先级高于虚拟主机级别
- 重试策略的相关属性包括重试次数和重试条件等
  - 最大重试次数：可重试的最大次数
    - 在每次重试之间使用指数退避算法
	- 单次重试操作有其超时时长
	- 所有重试都包含在整个请求的超时时长之内，以避免由于大量重试而导致的越长请求时间
  - 重试条件：是指进行重试的前提条件，例如网络故障、5xx类的响应码等
retry_policy: {...}
  retry_on: ...				#重试发生的条件，其功能同x-envoy-retry-on和x-envoy-retry-grpc-on标头相同
  num_retries: {...}			#重试次数，默认值为1，其功能同x-envoy-max-retries标头相同，但采用二者中配置的最大值 
  per_try_timeout: {...}		#每次重试时同上游端点建立连接的超时时长
  retry_priority: {...}		#配置重试优先级策略，用于在各优先级之间分配负载
  retry_host_predicate: []	#重试时使用的主机断言(predicate)列表，各断言用于拒绝主机；在选择重试主机时将参考该列表中的各断言，若存在任何断言拒绝了该主机，则需要重新尝试选择其它主机
  retry_options_predicates: []
  host_selection_retry_max_attempts: ...		#允许尝试重新选择主机的最大次数，默认为1
  retriable_status_codes: [] 					#除了retry_on指定的条件之外，用于触发重试操作的http状态码列表
  retry_back_off: {...}							#配置用于控制回退算法的参数，默认基本间隔为25ms，给定基本间隔B和重试次数N，重试的退避范围为(0,(2^N-1)B),最大间隔默认为基本间隔(250ms)的10倍
  rate_limited_retry_back_off: {...}			#定义控制重试回退策略的参数
  retriable_headers: [] 						#触发重试的HTTP响应标头列表，上游端点的响应报文与列表中的任何标头匹配时将触发重试
  retriable_requests_headers: []				#必须在用于重试的请求报文中使用的HTTP标头列表
#HTTP请求重试条件（route.RetryPolicy）
- 重试条件(同x-envoy-retry-on)
  - 5xx: 上游主机返回5xx响应码，或者根本未予响应（断开/重置/读取超时）
  - gateway-error: 网关错误，类似于5xx策略，但仅为502、503或504的应用进行重试
  - connection-failure: 在TCP级别与上游服务建立连接失败时进行重试
  - retriable-4xx: 上游服务器返回可重复的4xx响应码时进行重试
  - refused-stream: 上游服务使用REFUSED--STREAM错误重置时进行重试
  - retriable-status-codes: 上游服务器的响应码与重试策略或x-envoy-retriable-status-codes标头中定义的响应码匹配时进行重试
  - reset: 上游主机完全不响应时(disconnect/reset/read超时)，Envoy将进行重试
  - retriable-headers: 如果上游服务器响应报文匹配重试策略或x-envoy-retriable-header-names标头中包含的任何标头，则Envoy将尝试重试
  - envoy-ratelimited: 标头中存在x-envoy-ratelimited时进行重试
- 重试条件2(同x-envoy-retry-grpc-on)
  - cancelled: gRPC应答标头中的状态码是"cancelled"时进行重试
  - deadline-exceeded: gRPC应答标头中的状态码是"deadline-exceeded"时进行重试
  - internal: gRPC应答标头中的状态码是"internel"时进行重试
  - resource_exhausted: gRPC应答标头中的状态码是"resource-exhausted"时进行重试
  - unavailable: gRPC应答标头中的状态码是"unavailable"时进行重试
- 默认情况下，Envoy不会进行任何类型的重试操作，除非明确定义

#docmer-compose 超时重试示例
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/timeout-retries# cat docker-compose.yaml
version: '3.3'

services:
  envoy:
    image: envoyproxy/envoy-alpine:v1.20.0
    volumes:
    - ./front-envoy.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        ipv4_address: 172.31.65.10
        aliases:
        - front-proxy
    expose:
      # Expose ports 80 (for general traffic) and 9901 (for the admin server)
      - "80"
      - "9901"

  service_blue:
    image: ikubernetes/servicemesh-app:latest
    volumes:
      - ./service-envoy-fault-injection-abort.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        ipv4_address: 172.31.65.5
        aliases:
          - service_blue
          - colored
    environment:
      - SERVICE_NAME=blue
    expose:
      - "80"

  service_green:
    image: ikubernetes/servicemesh-app:latest
    networks:
      envoymesh:
        ipv4_address: 172.31.65.6
        aliases:
          - service_green
          - colored
    environment:
      - SERVICE_NAME=green
    expose:
      - "80"

  service_red:
    image: ikubernetes/servicemesh-app:latest
    volumes:
      - ./service-envoy-fault-injection-delay.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        ipv4_address: 172.31.65.7
        aliases:
          - service_red
          - colored
    environment:
      - SERVICE_NAME=red
    expose:
      - "80"

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.65.0/24
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/timeout-retries# cat front-envoy.yaml
admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

layered_runtime:
  layers:
  - name: admin
    admin_layer: {}

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: backend
              domains:
              - "*"
              routes:
              - match:
                  prefix: "/service/blue"
                route:
                  cluster: blue_abort	#此集群有故障注入"请求中断"
                  retry_policy:			#重试策略
                    retry_on: "5xx"		#响应码为5xx时，则进行重试，重试最大次数为3次；
                    num_retries: 3
              - match:
                  prefix: "/service/red"
                route:
                  cluster: red_delay	#此集群有故障注入"延迟"
                  timeout: 1s			#超时时长为1秒，长于1秒，则执行超时操作；
              - match:
                  prefix: "/service/green"
                route:
                  cluster: green
              - match:
                  prefix: "/service/colors"
                route:
                  cluster: mycluster
                  retry_policy:			 #超时和重试策略同时使用； 
                    retry_on: "5xx"
                    num_retries: 3
                  timeout: 1s
          http_filters:
          - name: envoy.filters.http.router

  clusters:
  - name: red_delay
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: red_delay
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: service_red
                port_value: 80

  - name: blue_abort
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: blue_abort
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: service_blue
                port_value: 80

  - name: green
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: green
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: service_green
                port_value: 80

  - name: mycluster
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: mycluster
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: colored
                port_value: 80
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/timeout-retries# cat service-envoy-fault-injection-abort.yaml
admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

layered_runtime:
  layers:
  - name: admin
    admin_layer: {}

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: service
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: local_service
          http_filters:
          - name: envoy.filters.http.fault
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.fault.v3.HTTPFault
              max_active_faults: 100
              abort:
                http_status: 503
                percentage:
                  numerator: 50				 #为一半的请求注入中断故障，以便于在路由侧模拟重试的效果；
                  denominator: HUNDRED
          - name: envoy.filters.http.router
            typed_config: {}

  clusters:
  - name: local_service
    connect_timeout: 0.25s
    type: strict_dns
    lb_policy: round_robin
    load_assignment:
      cluster_name: local_service
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: 127.0.0.1
                port_value: 8080

root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/timeout-retries# cat service-envoy-fault-injection-delay.yaml
admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

layered_runtime:
  layers:
  - name: admin
    admin_layer: {}

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: service
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: local_service
          http_filters:
          - name: envoy.filters.http.fault
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.fault.v3.HTTPFault
              max_active_faults: 100
              delay:
                fixed_delay: 10s
                percentage:
                  numerator: 50						#为一半的请求注入延迟故障，以便于在路由侧模拟超时的效果；
                  denominator: HUNDRED
          - name: envoy.filters.http.router
            typed_config: {}

  clusters:
  - name: local_service
    connect_timeout: 0.25s
    type: strict_dns
    lb_policy: round_robin
    load_assignment:
      cluster_name: local_service
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: 127.0.0.1
                port_value: 8080
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/timeout-retries# docker-compose up
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/timeout-retries# cat curl_format.txt
    time_namelookup:  %{time_namelookup}\n
       time_connect:  %{time_connect}\n
    time_appconnect:  %{time_appconnect}\n
   time_pretransfer:  %{time_pretransfer}\n
      time_redirect:  %{time_redirect}\n
 time_starttransfer:  %{time_starttransfer}\n
                    ----------\n
         time_total:  %{time_total}\n
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/timeout-retries# curl -w"@curl_format.txt" -o /dev/null -s "http://172.31.65.10/service/red"		#反复向/service/red发起多次请求，被注入延迟的请求，会有较长的响应时长；# 在后端Envoy上被注入10秒延迟的请求，在请求时长超过一秒钟后即会触发前端Envoy上的重试操作，进而进行请求重试，直至首次遇到未被注入延迟的请求，因此其总的响应时长一般为1秒多一点：
    time_namelookup:  0.000053
       time_connect:  0.000424
    time_appconnect:  0.000000
   time_pretransfer:  0.000502
      time_redirect:  0.000000
 time_starttransfer:  1.006594
                    ----------
         time_total:  1.006780
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/timeout-retries# curl -w"@curl_format.txt" -o /dev/null -s "http://172.31.65.10/service/red"
    time_namelookup:  0.000049
       time_connect:  0.000581
    time_appconnect:  0.000000
   time_pretransfer:  0.000665
      time_redirect:  0.000000
 time_starttransfer:  0.008219
                    ----------
         time_total:  0.009219
----反复向/service/blue发起多次请求，后端被Envoy注入中断的请求，会因为响应的503响应码而触发自定义的
----重试操作；最大3次的重试，仍有可能在连续多次的错误响应后，仍然响应以错误信息，但其比例会大大降低。
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/timeout-retries# ./send-requests.sh 172.31.65.10/service/blue 100
200
200
200
200
503
200
503
200
200
----发往/service/green的请求，因后端无故障注入而几乎全部得到正常响应
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/timeout-retries# ./send-requests.sh 172.31.65.10/service/green 100
----发往/service/colors的请求，会被调度至red_delay、blue_abort和green三个集群，它们有的可能被延迟、有的可能被中断；
root@front-envoy:~/servicemesh_in_practise/HTTP-Connection-Manager/timeout-retries# ./send-requests.sh 172.31.65.10/service/colors 100


####可观测应用之指标和日志
#统计
- Envoy状态统计
  - Stats Sink
  - 配置案例
  - 将指标数据纳入监控系统：statsd_exporter + Prometheus + grafana
- 访问日志
  - 格式规则和命令操作符
  - 配置语法和配置案例
  - 日志存储检索系统：filebeat + elasticsearch + kibana
- 分布式跟踪
  - 分布式跟踪基础概念
  - 分布式跟踪的工作机制
  - Envoy的分布式跟踪

#可观测性应用
- 日志、指标和跟踪是应用程序可观测性的三大支柱，前二者更多的是属于传统的"以主机为中心"的模型，而跟踪则"以流程为中心"

#stats相关的配置
- stats的配置参数位于Bootstrap配置文件的顶级配置段
{
  stats_sinks: []			#stats_sink列表
  stats_config: {...}		#stats内部处理机制
  stats_flush_interval: {...}	#stats数据刷写至sinks的频率，出于性能考虑，Envoy仅周期性刷写counters和gauges，默认时长为5000ms
  stats_flush_on_admin: ...		#仅在admin接口上收到查询请求时才刷写数据 
}
- stats_sinks为Envoy的可选配置，统计数据默认没有配置任何暴露机制，但需要存储长期的指标数据则应该手动定制此配置
stats_sinks:
  name: ...		#要初始化的sink的名称，名称必须匹配于Envoy内置支持的Sink，包括envoy.stat_sinks.dog_statsd, envoy.stat_sinks.graphite_statsd, envoy.stat_sinks.hystrix, envoy.stat_sinks.metrics_service, envoy.stat_sinks.statsd和envoy.stat_sinks.wasm几个；它们的功能类似于Prometheus的exporter
  typed_config: {...}	#sink的配置，各sink的配置方式有所不同，下面给出的参数是statd专用
  address: {...}		#StatsdSink服务的访问端点，也可以使用下面的tcp_cluster_name指定为配置在Envoy上的sink服务器组成集群
  tcp_cluster_name: ...	#StatsdSink集群的名称，与address互斥
  prefix: ...			#StatsdSink的自定义前缀，可选参数
- Envoy的统计信息由规范字符串表示法进行标识，这些字符串的动态部分可被剥离标签(tag)，并可由用户通过tag specifier进行配置
  - config.metrics.v3.StatsConfig
  - config.metrics.v3.TagSpecifier
- statsd_exporter导出envoy数据，这样Prometheus方可识别

#docker-compose抓取envoy指标示例
root@front-envoy:~/servicemesh_in_practise/Monitoring-and-Tracing/statsd-sink-and-prometheus# cat docker-compose.yaml
version: '3.3'

services:
  envoy:
    image: envoyproxy/envoy-alpine:v1.20.0
    volumes:
    - ./front-envoy.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        ipv4_address: 172.31.68.10
        aliases:
        - front-proxy
    expose:
      # Expose ports 80 (for general traffic) and 9901 (for the admin server)
      - "80"
      - "9901"

  service_blue:
    image: ikubernetes/servicemesh-app:latest
    volumes:
      - ./service_blue/service-envoy.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        ipv4_address: 172.31.68.11
        aliases:
          - myservice
          - blue
    environment:
      - SERVICE_NAME=blue
    expose:
      - "80"

  service_green:
    image: ikubernetes/servicemesh-app:latest
    volumes:
      - ./service_green/service-envoy.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        ipv4_address: 172.31.68.12
        aliases:
          - myservice
          - green
    environment:
      - SERVICE_NAME=green
    expose:
      - "80"

  service_red:
    image: ikubernetes/servicemesh-app:latest
    volumes:
      - ./service_red/service-envoy.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        ipv4_address: 172.31.68.13
        aliases:
          - myservice
          - red
    environment:
      - SERVICE_NAME=red
    expose:
      - "80"

  statsd_exporter:
    image: prom/statsd-exporter:v0.22.3			#运行statsd-exporter，envoy需要调用此服务器的9125端点，而后statsd-exporter将数据输出为Prometheus的数据，暴露端口为9102
    networks:
      envoymesh:
        ipv4_address: 172.31.68.6
        aliases:
        - statsd_exporter
    ports:
    - 9125:9125
    - 9102:9102

  prometheus:
    image: prom/prometheus:v2.30.3				#运行prometheus
    volumes:
    - "./prometheus/config.yaml:/etc/prometheus.yaml"		
    networks:
      envoymesh:
        ipv4_address: 172.31.68.7
        aliases:
        - prometheus
    ports:
    - 9090:9090
    command: "--config.file=/etc/prometheus.yaml"

  grafana:
    image: grafana/grafana:8.2.2				#运行grafana
    volumes:
    - "./grafana/grafana.ini:/etc/grafana/grafana.ini"
    - "./grafana/datasource.yaml:/etc/grafana/provisioning/datasources/datasource.yaml"
    networks:
      envoymesh:
        ipv4_address: 172.31.68.8
        aliases:
        - grafana
    ports:
    - 3000:3000

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.68.0/24
root@front-envoy:~/servicemesh_in_practise/Monitoring-and-Tracing/statsd-sink-and-prometheus# cat front-envoy.yaml
node:
  id: front-envoy
  cluster: mycluster

admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

layered_runtime:
  layers:
  - name: admin
    admin_layer: {}

stats_sinks:							#开启stats
- name: envoy.statsd
  typed_config:
    "@type": type.googleapis.com/envoy.config.metrics.v3.StatsdSink
    tcp_cluster_name: statsd_exporter		#此为cluster名称，在cluster配置段中已经定义
    prefix: front-envoy

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: service
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: colord
                  retry_policy:
                    retry_on: "5xx"
                    num_retries: 3
                  timeout: 1s
          http_filters:
          - name: envoy.filters.http.router

  clusters:
  - name: colord
    connect_timeout: 0.25s
    type: strict_dns
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: colord
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: myservice
                port_value: 80

  - name: statsd_exporter				#此为statsd_exporter服务器
    connect_timeout: 0.25s
    type: strict_dns
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: statsd_exporter
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: statsd_exporter
                port_value: 9125
root@front-envoy:~/servicemesh_in_practise/Monitoring-and-Tracing/statsd-sink-and-prometheus# cat service_blue/service-envoy.yaml	#service-blue集群
node:
  id: service_blue
  cluster: mycluster

stats_sinks:				#service-blue集群开启stats，并将指标数据写入到同一statsd_exporter中
- name: envoy.statsd
  typed_config:
    "@type": type.googleapis.com/envoy.config.metrics.v3.StatsdSink
    tcp_cluster_name: statsd_exporter
    prefix: service_blue

admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

layered_runtime:
  layers:
  - name: admin
    admin_layer: {}

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: service
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: local_service
          http_filters:
          - name: envoy.filters.http.fault
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.fault.v3.HTTPFault
              max_active_faults: 100
              abort:
                http_status: 503
                percentage:
                  numerator: 10
                  denominator: HUNDRED
          - name: envoy.filters.http.router
            typed_config: {}

  clusters:
  - name: local_service
    connect_timeout: 0.25s
    type: strict_dns
    lb_policy: round_robin
    load_assignment:
      cluster_name: local_service
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: 127.0.0.1
                port_value: 8080

  - name: statsd_exporter
    connect_timeout: 0.25s
    type: strict_dns
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: statsd_exporter
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: statsd_exporter
                port_value: 9125
root@front-envoy:~/servicemesh_in_practise/Monitoring-and-Tracing/statsd-sink-and-prometheus# cat service_red/service-envoy.yaml		#service-red集群
node:
  id: service_red
  cluster: mycluster

stats_sinks:				#service-red集群开启stats，并将指标数据写入到同一statsd_exporter中
- name: envoy.statsd
  typed_config:
    "@type": type.googleapis.com/envoy.config.metrics.v3.StatsdSink
    tcp_cluster_name: statsd_exporter
    prefix: service_red

admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

layered_runtime:
  layers:
  - name: admin
    admin_layer: {}

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: service
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: local_service
          http_filters:
          - name: envoy.filters.http.fault
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.fault.v3.HTTPFault
              max_active_faults: 100
              delay:
                fixed_delay: 2s
                percentage:
                  numerator: 10
                  denominator: HUNDRED
          - name: envoy.filters.http.router
            typed_config: {}

  clusters:
  - name: local_service
    connect_timeout: 0.25s
    type: strict_dns
    lb_policy: round_robin
    load_assignment:
      cluster_name: local_service
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: 127.0.0.1
                port_value: 8080

  - name: statsd_exporter
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: statsd_exporter
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: statsd_exporter
                port_value: 9125
root@front-envoy:~/servicemesh_in_practise/Monitoring-and-Tracing/statsd-sink-and-prometheus# cat service_green/service-envoy.yaml		#service-green集群
node:
  id: service_green
  cluster: mycluster

stats_sinks:					#service-green集群开启stats，并将指标数据写入到同一statsd_exporter中
- name: envoy.statsd
  typed_config:
    "@type": type.googleapis.com/envoy.config.metrics.v3.StatsdSink
    tcp_cluster_name: statsd_exporter
    prefix: service_green

admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

layered_runtime:
  layers:
  - name: admin
    admin_layer: {}

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: service
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: local_service
          http_filters:
          - name: envoy.filters.http.router

  clusters:
  - name: local_service
    connect_timeout: 0.25s
    type: strict_dns
    lb_policy: round_robin
    load_assignment:
      cluster_name: local_service
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: 127.0.0.1
                port_value: 8080

  - name: statsd_exporter
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: statsd_exporter
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: statsd_exporter
                port_value: 9125
root@front-envoy:~/servicemesh_in_practise/Monitoring-and-Tracing/statsd-sink-and-prometheus# cat prometheus/config.yaml	#prometheus配置
global:
  scrape_interval:  15s
  evaluation_interval:  15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'grafana'
    static_configs:
      - targets: ['grafana:3000']

  - job_name: 'statsd'
    scrape_interval: 5s
    static_configs:
      - targets: ['statsd_exporter:9102']
        labels:
          group: 'services'
root@front-envoy:~/servicemesh_in_practise/Monitoring-and-Tracing/statsd-sink-and-prometheus# cat grafana/datasource.yaml		#grafana配置
apiVersion: 1

datasources:
  - name: prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    editable: true
    isDefault:

root@front-envoy:~/servicemesh_in_practise/Monitoring-and-Tracing/statsd-sink-and-prometheus# cat grafana/grafana.ini
instance_name = "grafana"

[security]
admin_user = admin
admin_password = admin
----监控工作流程：envoy(front-envoy,sidecar-envoy) --> statsd_exporter <-- prometheus <-- grafana
root@front-envoy:~/servicemesh_in_practise/Monitoring-and-Tracing/statsd-sink-and-prometheus# docker-compose up


#访问日志
- Envoy的TCP Proxy和HTTP Connection Manager过滤器可通过特定的extension支持访问日志，在功能上，它具有如下特性：
  - 支持任意数量的访问日志
  - 访问日志过滤器支持自定义日志格式
  - 允许将不同类型的请求和响应写入不同的访问日志中
- 类似于统计数据，访问日志也支持将数据保存于相应的后端存储系统(Sink)中，目前Envoy支持以下几种与访问日志有关的Sink：
  - 文件
    - 异步IO架构，访问日志记录不会阻塞主线程
	- 可自定义的访问日志格式，使用预定义字段以及HTTP请求和响应报文的任意标头
  - gRPC
    - 将访问日志发送到gRPC访问日志记录服务中
  - Stdout
    - 将日志发送到进程的标准输出上，此种目前用得最多
  - Stderr
    - 将日志发送到进程的错误输出上
#配置访问日志
- 访问日志配置语法
  filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          access_log:
		    name: ...		#要实例化的访问日志实现的名称，该名称必须与静态注册的访问日志相匹配，当前的内置的日志记录器有envoy.access_loggers.file, envoy.access_loggers.http_grpc, envoy.access_loggers.open_telemetry, envoy.access_loggers.stream, envoy.access_loggers.tcp_grpc和envoy.access_loggers.wasm几种
			filter: {...}	#用于确定输出哪些日志信息的过滤器，但仅能选择使用其中一种
			typed_config: {...}		#与选定的日志记录器类型相关的专用配置
- 支持的过滤器，一次配置，只能选择其中一个
{
  status_code_filter: {...},
  duration_filter: {...},
  not_health_check_filter: {...},
  traceable_filter: {...},
  runtime_filter: {...},
  and_filter: {...},
  or_filter: {...},
  header_filter: {...},
  response_flag_filter: {...},
  grpc_status_filter: {...},
  extension_filter: {...},
  metadata_filter: {...}
}
#具体配置访问日志
- File Access Log
  - "@type": type.googleapis.com/envoy.extentions.access_loggers.file.v3.FileAccessLog
{
  path: ...					#本地文件系统上的日志文件路径
  format: ...				#访问日志格式字符串，Envoy有默认的日志格式，也支持用户自定义；该字段已废弃，将被log_format所取代
  json_format:  {...}		#json格式的访问日志字符串；该字段已废弃，将被log_format所取代
  typed_json_format: {...}	#json格式的访问日志字符串；该字段已废弃，将被log_format所取代
  log_format: {...}			#访问日志数据及格式定义，未定义时将使用默认值；format,json_format,typed_json_format和log_format仅可定义一个
}
  - log_format字段
{
  text_format: ...			#支持命令操作符的文本字串；text_format, json_format和text_format_source仅可定义一个
  json_format: {...}		#支持命令操作符的json字串
  text_format_source: {...}	#支持命令操作符的文本字串，字串来自filename, inline_bytes或inline_string数据源
  omit_empty_values: ...	#是否忽略空值
  content_type: ...			#内容类型，文本的默认类型为text/plain, json的默认类型为application/json
  formatters: []			#调用的日志格式化插件
}

#docker-compose日志收集示例
root@front-envoy:~/servicemesh_in_practise/Monitoring-and-Tracing/container-log-with-efk# cat docker-compose.yaml
# Author: MageEdu <mage@magedu.com>
version: '3.3'

services:
  front-envoy:
    image: envoyproxy/envoy-alpine:v1.20.0
    volumes:
    - ./front-envoy.yaml:/etc/envoy/envoy.yaml
    networks:
      envoymesh:
        ipv4_address: 172.31.76.10
        aliases:
        - front-envoy
    expose:
      # Expose ports 80 (for general traffic) and 9901 (for the admin server)
      - "80"
      - "9901"

  service_blue:
    image: ikubernetes/servicemesh-app:latest
    networks:
      envoymesh:
        aliases:
          - colored
          - blue
    environment:
      - SERVICE_NAME=blue
    expose:
      - "80"

  service_green:
    image: ikubernetes/servicemesh-app:latest
    networks:
      envoymesh:
        aliases:
          - colored
          - green
    environment:
      - SERVICE_NAME=green
    expose:
      - "80"

  service_red:
    image: ikubernetes/servicemesh-app:latest
    networks:
      envoymesh:
        aliases:
          - colored
          - red
    environment:
      - SERVICE_NAME=red
    expose:
      - "80"

  elasticsearch:
    image: "docker.elastic.co/elasticsearch/elasticsearch:7.14.2"
    environment:
    - "ES_JAVA_OPTS=-Xms1g -Xmx1g"
    - "discovery.type=single-node"
    - "cluster.name=myes"
    - "node.name=myes01"
    ulimits:
      memlock:
        soft: -1
        hard: -1
    networks:
      envoymesh:
        ipv4_address: 172.31.76.15
        aliases:
        - es
        - myes01
    ports:
    - "9200:9200"
    volumes:
    - elasticsearch_data:/usr/share/elasticsearch/data

  kibana:
    image: "docker.elastic.co/kibana/kibana:7.14.2"
    environment:
      ELASTICSEARCH_URL: http://myes01:9200
      ELASTICSEARCH_HOSTS: '["http://myes01:9200"]'
    networks:
      envoymesh:
        ipv4_address: 172.31.76.16
        aliases:
          - kibana
          - kib
    ports:
    - "5601:5601"

  filebeat:
    image: "docker.elastic.co/beats/filebeat:7.14.2"
    networks:
      envoymesh:
        ipv4_address: 172.31.76.17
        aliases:
          - filebeat
          - fb
    user: root
    command: ["--strict.perms=false"]
    volumes:
    - ./filebeat/filebeat.yaml:/usr/share/filebeat/filebeat.yml		#配置收集/var/lib/docker/containers/*/*.log日志
    - /var/lib/docker:/var/lib/docker:ro		#挂载宿主机上的日志目录到filebeat容器当中
    - /var/run/docker.sock:/var/run/docker.sock

volumes:
    elasticsearch_data:

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.76.0/24
root@front-envoy:~/servicemesh_in_practise/Monitoring-and-Tracing/container-log-with-efk# cat filebeat/filebeat.yaml
filebeat.inputs:
- type: container
  paths:
    - '/var/lib/docker/containers/*/*.log'

processors:
- add_docker_metadata:
    host: "unix:///var/run/docker.sock"

- decode_json_fields:		
    fields: ["message"]				#filebeat对message消息进行解码，分为多个字段
    target: "json"
    overwrite_keys: true

output.elasticsearch:
  hosts: ["elasticsearch:9200"]
  indices:
    - index: "filebeat-%{+yyyy.MM.dd}"

logging.json: true
logging.metrics.enabled: false
root@front-envoy:~/servicemesh_in_practise/Monitoring-and-Tracing/container-log-with-efk# cat front-envoy.yaml
node:
  id: front-envoy
  cluster: mycluster

admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

layered_runtime:
  layers:
  - name: admin
    admin_layer: {}

static_resources:
  listeners:
  - address:
      socket_address:
        address: 0.0.0.0
        port_value: 80
    name: listener_http
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          access_log:						#开启access log
          - name: envoy.access_loggers.file
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.access_loggers.file.v3.FileAccessLog
              path: "/dev/stdout"			#输出到标准输出之上
              log_format:
                json_format: {"start": "[%START_TIME%] ", "method": "%REQ(:METHOD)%", "url": "%REQ(X-ENVOY-ORIGINAL-PATH?:PATH)%", "protocol": "%PROTOCOL%", "status": "%RESPONSE_CODE%", "respflags": "%RESPONSE_FLAGS%", "bytes-received": "%BYTES_RECEIVED%", "bytes-sent": "%BYTES_SENT%", "duration": "%DURATION%", "upstream-service-time": "%RESP(X-ENVOY-UPSTREAM-SERVICE-TIME)%", "x-forwarded-for": "%REQ(X-FORWARDED-FOR)%", "user-agent": "%REQ(USER-AGENT)%", "request-id": "%REQ(X-REQUEST-ID)%", "authority": "%REQ(:AUTHORITY)%", "upstream-host": "%UPSTREAM_HOST%", "remote-ip": "%DOWNSTREAM_REMOTE_ADDRESS_WITHOUT_PORT%"}		#这个是定义的JSON格式
                #text_format: "[%START_TIME%] \"%REQ(:METHOD)% %REQ(X-ENVOY-ORIGINAL-PATH?:PATH)% %PROTOCOL%\" %RESPONSE_CODE% %RESPONSE_FLAGS% %BYTES_RECEIVED% %BYTES_SENT% %DURATION% %RESP(X-ENVOY-UPSTREAM-SERVICE-TIME)% \"%REQ(X-FORWARDED-FOR)%\" \"%REQ(USER-AGENT)%\" \"%REQ(X-REQUEST-ID)%\" \"%REQ(:AUTHORITY)%\" \"%UPSTREAM_HOST%\" \"%DOWNSTREAM_REMOTE_ADDRESS_WITHOUT_PORT%\"\n"
          stat_prefix: ingress_http
          route_config:
            name: local_route
            virtual_hosts:
            - name: vh_001
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: mycluster
          http_filters:
          - name: envoy.filters.http.router

  clusters:
  - name: mycluster
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: mycluster
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: colored
                port_value: 80
---


#可观测应用之分布式跟踪
SpanID：每个跟踪节点都有相同的SpanID
TraceID：每个跟踪节点有一个TraceID，每跟踪一个节点，TranceID增加1，例如,TraceID_1 -> TranceID_2 -> TranceID_3
ParentID：每个跟踪节点的父跟踪节点ID，第一个跟踪节点只有SpanID和TraceID_1两个ID，第二个跟踪节点则有SpanID、TraceID_2、ParentID_1(上一个跟踪节点的TraceID号)三个ID
#传播上下文
- Envoy提供了报告网络内服务间通信跟踪信息的能力
  - 为了能够关联由请求流程中的各种代理生成的跟踪信息，服务必须在入站和出站请求之间传播某些跟踪上下文
  - 无论使用哪个跟踪服务，都应该传播x-request-id，这样在被调用服务中启动相关性的记录
- 跟踪上下文也可以被服务手工进行传播(在一个请求时不会有问题。在高并发的业务场景下，业务代码需要添加针对特定跟踪器进行标头识别，以达到多个请求处理完成后ID始终 对应不乱)：
  - Zipkin跟踪器：Envoy依赖服务来传播B3 HTTP标头（x-b3-traceid, x-b3-spanid, x-b3-parentspanid, x-b3-sampled, x-b3-flags）
  - Datadog跟踪器：Envoy依赖该服务传播特定于Datadog的HTTP头（x-datadog-trace-id, x-datadog-parent-id,x-datadog-sampling-priority）
  - LightStep跟踪器：Envoy依赖服务来传播x-ot-span-context HTTP头，同时将HTTP请求发送到其它服务
注：就算业务代码增加了以上特定跟踪器标头识别代码，也只是满足envoy在高并发场景下的跟踪，并不能识别app的跟踪，因此，app的跟踪需要使用独立的跟踪器进行追踪。
#配置Envoy的跟踪机制
- 目前，Envoy仅支持HTTP协议的跟踪器
- 在Envoy配置跟踪机制通常由三部分组成
  - 定义分布式跟踪系统相关的集群
    - 将使用的Zipkin或Jaeger、Skywalking等分布式跟踪系统定义为Envoy可识别的集群
	- 定义在clusters配置段中，需要静态指定
  - tracing{}配置段
    - Envoy使用的跟踪器的全局设定
	- 可由Bootstrap配置在顶级配置段定义
  - 在http_connection_manager上启用tracing{}配置段
    - 用于定义是否向配置的跟踪系统发送跟踪数据
	- 侦听器级别的设定
----配置示例
...
static_resources:
  listeners;
  - name: ...
    address: {...}
	filter_chains:
	- filter:
	  - name: envoy.http-connection-manager
	    stat_prefix: ...
		route_config: {...}
		tracing: {...}			#向tracing provider发送跟踪数据
		...
	...
  clusters:
  - name: zipkin|jaeger|skywalking|...
  ...
tracing: {...}		#Envoy使用的跟踪器的全局设定，主要用于配置tracing provider;
  http: {...}		#HTTP跟踪器
----详细配置示例
- Envoy跟踪的全局配置，以Zipkin为例(Jager兼容)
tracing:
  http:
    name:
	typed_config:			#类型化配置，支持的类型有envoy.tracers.datadog, envoy.tracers.dynamic_ot, envoy.tracers.lightstep, envoy.tracers.opencensus, envoy.tracers.skywalking, envoy.tracers.xray和envoy.tracers.zipkin
	"@type": type.googleapis.com/envoy.config.trace.v3.ZipkinConfig		#以zipkin为例
	collector_cluster: 		#指定承载Zipkin收集器的集群名称，该集群必须在Bootstrap静态集群资源中定义
	collector_endpoint:		#Zipkin服务的用于接收Span数据的API端点；Zipkin的标准配置，其API端点为/api/v2/spans
	trace_id_128bit:		#是否创建128位的跟踪ID，默认为False，即使用64位的ID
	shared_span_context:	#客户端和服务端Span是否共享相同的span id,默认为True 
    collector_endpoint_version:		#Collecter端点的版本
	collector_hostname:				#向collector cluster发送span时使用的主机名，可选；默认为collector_cluster字段中定义的主机名
- 在http_connection_manager中发送跟踪数据 
filter_chains:
- filters:
  - name: envoy.http-connection-manager
    stat_prefix:
    route_config:
	tracing:
	  client.sampling: {...}			#由客户端通过x-client-trace-id标头指定进行跟踪时的采样，默认为100%
	  random_sampling: {...}			#随机抽样，默认为100%
	  overall_sampling: {...}			#整体抽样，默认为100%
	  verbose: ...						#是否为span标注额外信息，设定为true时，则span将包含stream事件的日志信息
	  max_path_tag_length: {...}		#记录HTTP URL时使用的最大长度
	  custom_tags: []					#自定义标签列表，各标签用于活动的span之上，且名称要唯一
	  provider: {...}					#指定要使用的外部tracing provider


#docker-compose tracing示例，以zipkin和jaeger为例，两者配置几乎一样
root@front-envoy:~/servicemesh_in_practise/Monitoring-and-Tracing/zipkin-tracing# cat docker-compose.yml
# Author: MageEdu <mage@magedu.com>
# www.magedu.com
version: '3.3'

services:

  front-envoy:
    image: envoyproxy/envoy-alpine:v1.20.0
    volumes:
    - "./front_envoy/envoy-config.yaml:/etc/envoy/envoy.yaml"
    networks:
      envoymesh:
        ipv4_address: 172.31.85.10
        aliases:
        - front-envoy
        - front
    ports:
    - 8080:80
    - 9901:9901

  service_a_envoy:
    image: envoyproxy/envoy-alpine:v1.20.0
    volumes:
    - "./service_a/envoy-config.yaml:/etc/envoy/envoy.yaml"
    networks:
      envoymesh:
        aliases:
        - service_a_envoy
        - service-a-envoy
    ports:
    - 8786
    - 8788
    - 8791

  service_a:
    build: service_a/
    network_mode: "service:service_a_envoy"
    #ports:
    #- 8081
    depends_on:
    - service_a_envoy

  service_b_envoy:
    image: envoyproxy/envoy-alpine:v1.20.0
    volumes:
    - "./service_b/envoy-config.yaml:/etc/envoy/envoy.yaml"
    networks:
      envoymesh:
        aliases:
        - service_b_envoy
        - service-b-envoy
    ports:
    - 8789

  service_b:
    build: service_b/
    network_mode: "service:service_b_envoy"
    #ports:
    #- 8082
    depends_on:
    - service_b_envoy

  service_c_envoy:
    image: envoyproxy/envoy-alpine:v1.20.0
    volumes:
    - "./service_c/envoy-config.yaml:/etc/envoy/envoy.yaml"
    networks:
      envoymesh:
        aliases:
        - service_c_envoy
        - service-c-envoy
    ports:
    - 8790

  service_c:
    build: service_c/
    network_mode: "service:service_c_envoy"
    #ports:
    #- 8083
    depends_on:
    - service_c_envoy

  zipkin:
    image: openzipkin/zipkin:2
    networks:
      envoymesh:
        ipv4_address: 172.31.85.15
        aliases:
        - zipkin
    ports:
    - "9411:9411"

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.85.0/24
root@front-envoy:~/servicemesh_in_practise/Monitoring-and-Tracing/zipkin-tracing# cat front_envoy/envoy-config.yaml
# Author: MageEdu <mage@magedu.com>
# Site: www.magedu.com
node:
  id: front-envoy
  cluster: front-envoy

admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

layered_runtime:
  layers:
  - name: admin
    admin_layer: {}

static_resources:
  listeners:
  - name: http_listener-service_a
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 80
    traffic_direction: OUTBOUND
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          generate_request_id: true			#最开始处生成spanID
          tracing:
            provider:
              name: envoy.tracers.zipkin	#跟踪类型为zipkin
              typed_config:
                "@type": type.googleapis.com/envoy.config.trace.v3.ZipkinConfig		
                collector_cluster: zipkin	#zipkin集群名称
                collector_endpoint: "/api/v2/spans"
                collector_endpoint_version: HTTP_JSON
          codec_type: AUTO
          stat_prefix: ingress_http
          route_config:
            name: local_route
            virtual_hosts:
            - name: backend
              domains:
              - "*"
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: service_a
                decorator:
                  operation: checkAvailability
              response_headers_to_add:
              - header:
                  key: "x-b3-traceid"				#增加x-b3-traceid头部，以达到后端服务高并发时识别此头部信息并复制此头部信息响应出去(需要在业务代码上导入Zipkin跟踪器库实现，因为此标头是zipkin识别的标头)
                  value: "%REQ(x-b3-traceid)%"
              - header:
                  key: "x-request-id"				#增加x-request-id头部，用于envoy在调用服务中启动相关性的记录，只需要在根启用即可
                  value: "%REQ(x-request-id)%"
          http_filters:
          - name: envoy.filters.http.router
  clusters:
  - name: zipkin
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: zipkin
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: zipkin
                port_value: 9411

  - name: service_a
    connect_timeout: 0.25s
    type: strict_dns
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: service_a
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: service_a_envoy
                port_value: 8786
root@front-envoy:~/servicemesh_in_practise/Monitoring-and-Tracing/zipkin-tracing# cat service_a/envoy-config.yaml
node:
  id: service-a
  cluster: service-a

admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

layered_runtime:
  layers:
  - name: admin
    admin_layer: {}


static_resources:
  listeners:
  - name: service-a-svc-http-listener
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 8786
    traffic_direction: INBOUND
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          tracing:
            provider:
              name: envoy.tracers.zipkin			#每个listener打开zipkin跟踪
              typed_config:
                "@type": type.googleapis.com/envoy.config.trace.v3.ZipkinConfig
                collector_cluster: zipkin
                collector_endpoint: "/api/v2/spans"
                collector_endpoint_version: HTTP_JSON
          route_config:
            name: service-a-svc-http-route
            virtual_hosts:
            - name: service-a-svc-http-route
              domains:
              - "*"
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: local_service
                decorator:
                  operation: checkAvailability
          http_filters:
          - name: envoy.filters.http.router
  - name: service-b-svc-http-listener
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 8788
    traffic_direction: OUTBOUND
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: egress_http_to_service_b
          codec_type: AUTO
          tracing:
            provider:
              name: envoy.tracers.zipkin		#每个listener打开zipkin跟踪
              typed_config:
                "@type": type.googleapis.com/envoy.config.trace.v3.ZipkinConfig
                collector_cluster: zipkin
                collector_endpoint: "/api/v2/spans"
                collector_endpoint_version: HTTP_JSON
          route_config:
            name: service-b-svc-http-route
            virtual_hosts:
            - name: service-b-svc-http-route
              domains:
              - "*"
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: service_b
                decorator:
                  operation: checkStock
          http_filters:
          - name: envoy.filters.http.router

  - name: service-c-svc-http-listener
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 8791
    traffic_direction: OUTBOUND
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: egress_http_to_service_c
          codec_type: AUTO
          tracing:
            provider:
              name: envoy.tracers.zipkin		#每个listener打开zipkin跟踪
              typed_config:
                "@type": type.googleapis.com/envoy.config.trace.v3.ZipkinConfig
                collector_cluster: zipkin
                collector_endpoint: "/api/v2/spans"
                collector_endpoint_version: HTTP_JSON
          route_config:
            name: service-c-svc-http-route
            virtual_hosts:
            - name: service-c-svc-http-route
              domains:
              - "*"
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: service_c
                decorator:
                  operation: checkStock
          http_filters:
          - name: envoy.filters.http.router

  clusters:
  - name: zipkin
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: zipkin
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: zipkin
                port_value: 9411

  - name: local_service
    connect_timeout: 0.25s
    type: strict_dns
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: local_service
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: 127.0.0.1
                port_value: 8081

  - name: service_b
    connect_timeout: 0.25s
    type: strict_dns
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: service_b
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: service_b_envoy
                port_value: 8789

  - name: service_c
    connect_timeout: 0.25s
    type: strict_dns
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: service_c
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: service_c_envoy
                port_value: 8790
root@front-envoy:~/servicemesh_in_practise/Monitoring-and-Tracing/zipkin-tracing# cat service_b/envoy-config.yaml
node:
  id: service-b
  cluster: service-b

admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

layered_runtime:
  layers:
  - name: admin
    admin_layer: {}

static_resources:
  listeners:
  - name: service-b-svc-http-listener
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 8789
    traffic_direction: INBOUND
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          tracing:
            provider:
              name: envoy.tracers.zipkin			#每个listener打开zipkin跟踪
              typed_config:
                "@type": type.googleapis.com/envoy.config.trace.v3.ZipkinConfig
                collector_cluster: zipkin
                collector_endpoint: "/api/v2/spans"
                collector_endpoint_version: HTTP_JSON
          route_config:
            name: service-b-svc-http-route
            virtual_hosts:
            - name: service-b-svc-http-route
              domains:
              - "*"
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: local_service
                decorator:
                  operation: checkAvailability
          http_filters:
          - name: envoy.filters.http.fault
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.fault.v3.HTTPFault
              max_active_faults: 100
              abort:
                http_status: 503
                percentage:
                  numerator: 15
                  denominator: HUNDRED
          - name: envoy.filters.http.router
            typed_config: {}

  clusters:
  - name: zipkin
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: zipkin
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: zipkin
                port_value: 9411

  - name: local_service
    connect_timeout: 0.25s
    type: strict_dns
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: local_service
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: 127.0.0.1
                port_value: 8082
root@front-envoy:~/servicemesh_in_practise/Monitoring-and-Tracing/zipkin-tracing# cat service_c/envoy-config.yaml
node:
  id: service-c
  cluster: service-c

admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

layered_runtime:
  layers:
  - name: admin
    admin_layer: {}

static_resources:
  listeners:
  - name: service-c-svc-http-listener
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 8790
    traffic_direction: INBOUND
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          codec_type: AUTO
          tracing:
            provider:
              name: envoy.tracers.zipkin			#每个listener打开zipkin跟踪
              typed_config:
                "@type": type.googleapis.com/envoy.config.trace.v3.ZipkinConfig
                collector_cluster: zipkin
                collector_endpoint: "/api/v2/spans"
                collector_endpoint_version: HTTP_JSON
          route_config:
            name: service-c-svc-http-route
            virtual_hosts:
            - name: service-c-svc-http-route
              domains:
              - "*"
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: local_service
                decorator:
                  operation: checkAvailability
          http_filters:
          - name: envoy.filters.http.fault
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.fault.v3.HTTPFault
              max_active_faults: 100
              delay:
                fixed_delay: 3s
                percentage:
                  numerator: 10
                  denominator: HUNDRED
          - name: envoy.filters.http.router
            typed_config: {}

  clusters:
  - name: zipkin
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: zipkin
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: zipkin
                port_value: 9411

  - name: local_service
    connect_timeout: 0.25s
    type: strict_dns
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: local_service
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: 127.0.0.1
                port_value: 8083
---



#####网格安全
- 本节话题
  - 服务网格的安全风险及常见解决方案
    - 网络级控制机制
	- 应用级控制机制：OAuth 2.0， OpenID Connect， JWT等
  - Envoy身份认证
    - TLS和mTLS
	- JWT身份认证
	  - JWT，JWK和JWS
	- 基于SPIFFE/SPIRE和SDS和mTLS
	  - SPIFFE Components：SPIFFE ID, SVID和Workload API
	  - SPIRE架构及组件：Server和Agent
	  - Node和Workload的Attestation
  - Envoy授权
    - RBAC
	- 外部授权和ABAC
	  - OPA：Open Policy Agent
	  - OPA决策机制
	  - Envoy OPA外部授权示例

#Envoy的身份认证机制
- Envoy支持两种类型的认证机制
  - 传输认证：即服务间的认证，它基于双向TLS实现传输认证（即mTLS）,包括双向认证、信道安全和证书自动管理；每个服务都需要有其用于服务间双向认证的标识，以实现此种谁机制；
  - 用户认证：也称为终端用户认证，用于认证请求的最终用户或者设备；Envoy通过JWT（Json Web Token）实现此类认证需求，以保护服务端的资源
    - 客户端基于HTTP标头向服务端发送JWT
	- 服务端验证签名
	- envoy.filters.http.jwt_authn过滤器
	
#Envoy TLS
- Listener：与客户端通信时的TLS终止
- Cluster：同上游建立TLS通信时的始发
#配置Envoy TLS
- Envoy v3 API中移除了v2使用了tls_context，而改用Transport sockets扩展来支持TLS通信
  - 扩展的专用名称为envoy.transport_sockets.tls
  - 针对TLS终止和TLS始发，分别存在一种类型的专用配置
    - TLS始发：extensions.transport_sockets.tls.v3.UpstreamTlsContext
    - TLS终止：extensions.transport_sockets.tls.v3.DownstreamTlsContext
- DownstreamTlsContext与UpstreamTlsContext各自的配置中，均可定义连接参数、数字证书等，但前者还可强制要求客户端请求证书，从而进行mutual TLS会话
#配置Envoy Downstream TLS
- Listener中的Transport sockets定义在filter_chains配置段中，与"filters[]"位于同一级别
listeners:
- name: ...
  address: {...}
  ...
  filter_chains:
  - filter_chain_match: {...}
    filters: []							#配置各种过滤器，包括http_connection_manager, tcp_proxy和redis_proxy等
	use_proxy_proto: {...}
	transport_socket: {...}				#定义transport socket, 用于为代理的各协议支持TLS支持
	transport_socket_connect_timeout: {...}
  ...
- extensions.transport_sockets.tls.v3.DownstreamTlsContext示例配置
filter_chains:
- filters:
  - name: envoy.filters.network.http_connection_manager
  ...
  transport_socket:
    name: envoy.transport_sockets.tls
	typed_config:
	  "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.DownstreamTlsContext
	  common_tls_context: {...}			#通用的TLS配置，包括TLS通信特征和证书等
	  require_client_certificate:		#是否强制校验客户端证书
	  session_ticket_keys: {...}		#为了能够恢复TLS session, 服务器会使用session key将session加密后发送给客户端保存；客户端需要透明地支持该功能
	  session_ticket_keys_sds_secret_config: {...}			#通过SDS API请求加载session ticket key的配置
	  disable_stateless_session_resumption: 				#布尔型值，true表示不生成session ticket，从而启用stateless session; false表示生成并加密会话，加密使用的key可由session_ticket_keys或session_ticket_keys_sds_secret_config定义，未定义时，将由TLS Server自行生成和管理
	  session_timeout: 					#会话超时时长
	  ocsp_staple_policy:
#配置Envoy Upstream TLS
- Clusters中的Transport sockets是集群级别的配置段，各集群可分别定义各自的TLS Upstream 
clusters:
- name: ...			#定义集群
  type:
  lb_policy:
  load_assignment:
  ...
  transport_socket: {...}			#该集群与上游通信时使用的TLS配置
- extensions.transport_sockets.tls.v3.DownstreamTlsContext配置示例
clusters:
- name:
  ...
  transport_socket:
    name: envoy.transport_sockets.tls
	typed_config:
	  "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.DownstreamTlsContext
	  common_tls_context: {...}		#通用的TLS配置，包括TLS通信特征和证书等
	  sni: ...						#SNI支持基于FQDN的TLS，创建TLS后端连接时使用的SNI字符串
	  allow_renegotiation: ...		#是否允许启用协调机制，不安全，不建议使用
	  max_session_keys: ...			#允许存储的用于进行session恢复的最大session key数量；默认为1，0表示禁止会话恢复
#Envoy中设定数字证书的方式
- 配置时，可以通过静态资源格式指定使用的TLS证书，也可以通过SDS动态获取TLS证书
  - SDS可以简化证书管理
    - 各实例的证书可由SDS统一推送
	- 证书过期后，SDS推送新证书至Envoy实例可立即生效而无需重启或重新部署
  - 获取到所需要的证书之后侦听器方能就绪；不过，若因同SDS服务器的连接失败或收到其错误响应而无法获取证书，则侦听器会打开端口，但会重置连接请求
  - Envoy同SDS服务器之间的通信必须使用安全连接
  - SDS服务器需要实现gRPC服务SecretDiscoveryService，它遵循与其它xDS相同的协议
- 设定数字证书的方式
  - 在transport_sockets配置段中，通过tls_certificates基于指定数据源直接加载证书及私钥
  - 在static_resources中定义出静态格式的Secret资源，而后在transport_sockets中的SDS配置里面通过指定Secret名称进行引用
  - 而通过SDS提供证书时，需要配置好SDS集群，并由listener或cluster在transport_sockets中通过sds_config引用
#配置Envoy TLS
- 通用会话配置中，与TLS协议特性、加载的证书和私钥等相关的配置
transport_socket:
  name: envoy.transport_sockets.tls
  typed_config:
    "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext
	common_tls_context:
	  tls_params:
	    tls_minimum_protocol_versions: ...			#支持的最小的TLS协议版本号，默认客户端是TLS1.2, 服务端是TLS 1.0
		tls_maximum_protocol_versions: ...			#支持的最大的TLS协议版本号，默认客户端是TLS1.2, 服务端是TLS 1.3
		cipher_suites: []					#TLS1.0-1.2版本协商中支持加密算法列表，TLS1.3不受影响
		ecdh_curves: []						#使用的ecdh curve算法
	  tls_certificates:			#tls通信中使用的证书，此为静态配置；动态配置则使用下面的tls_certificate_sds_secret_config配置段；二者不可同时定义
	    certificate_chain:		#加载的证书信息的数据源，相关数据源只能是下列三种之一而且仅可设置一种
		  filename:				#证书文件路径
		  inline_bytes:			#包含在配置文件中直接给出字节字串中
		  inline_string:		#包含在配置文件中直接给出字串中
		private_key:			#加载的私钥信息的数据源，格式同上面的certificat_chain
		watched_directory:		#基于SDS协议从文件系统中加载证书和私钥时监视的目录
		  path: ...				#监视的目标路径
		tls_certificate_sds_secret_configs:		#通过SDS API加载secret（从而加载证书和私钥）的配置，不能与tls_certificates配置段同时使用
		- name: ...				#引用的secret的唯一标识名, secret为静态配置；若同时给出了下面的sds_config配置，则会从其SDS API动态加载secret
		  sds_config:			#SDS API服务配置，path, api_config_resource和ads三种配置一次仅可定义一种
		    path: ...			#基于文件系统
			api_config_source:	#基于SDS订阅
			ads:				#基于ADS订阅
			initial_fetch_timeout:				#初始加载的超时时长
			resource_api_version:				#资源的API版本
		validation_context: {...}
		validation_context_sds_secret_config: {...}
		combined_validation_config: {...}
#配置Envoy TLS
- 通用会话配置中，与对端证书校验相关的配置
transport_socket:
  name: envoy.transport_sockets.tls
  typed_config:
    "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext
	common_tls_context:
	  tls_params: {...}
      tls_certificates: {...}
	  tls_certificate_sds_secret_configs: {...}
	  validation_context:				#用于校验对端证书的相关配置
	    trusted_ca: {...}				#集群的CA，相关信息可从filename，inline_bytes和inline_string三种数据源之一中加载
		watched_directory: {...}		#基于SDS协议从文件系统中加载CA时监视的目录
		verify_certificate_spki: []		#SPKI校验，经过Base64编码的SPKI(Subject Public Key Information)的SHA-256检验码列表
		verify_certificate_hash: []		#Hash校验，仅该列表中的hash码对应的证书会被接受
		match_subject_alt_names: []		#Subject的可替换名称列表
		crl: {...}						#证书吊销列表，相关信息可从filename,inline_bytes和inline_string三种数据源之一中加载
		allow_expired_certificate:		#是否接受已然过期的证书
		trust_chain_verification:		#证书信任链的检验模式，支持VERIFY_TRUST_CHAIN和ACCEPT_UNTRUSTED两种，前者为默认值
	  validation_context_sds_secret_config: 	#通过SDS API动态加载validation context
	    name: ...			#引用的secret的唯一标识名，secret为静态配置；若同时给出了下面的sds_config配置，则会从其SDS API动态加载secret
		sds_config: ...		#SDS API服务配置
	  combined_validation_config:		#混合模式的validation context加载机制，同时给了静态配置和SDS，SDS有返回数据时将二者合并后使用
	    default_validation_context:  {...}		#默认使用的静态配置的validation context
		validation_context_sds_secret_config: {...}		#动态加载vaildation context secret的SDS API

#docker-compose tls示例
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# cat docker-compose.yaml
version: '3.3'

services:
  front-envoy:
    image: envoyproxy/envoy-alpine:v1.20.0
    volumes:
      - ./front-envoy.yaml:/etc/envoy/envoy.yaml
      - ./certs/front-envoy/:/etc/envoy/certs/
      - ./certs/CA/:/etc/envoy/ca/
    networks:
      envoymesh:
        ipv4_address: 172.31.90.10
        aliases:
        - front-envoy
    expose:
      # Expose ports 80 (for general traffic) and 9901 (for the admin server)
      - "80"
      - "443"
      - "9901"
    ports:
      - "8080:80"
      - "8443:443"
      - "9901:9901"

  blue:
    image: ikubernetes/servicemesh-app:latest
    networks:
      envoymesh:
        aliases:
          - myservice
          - service-blue
          - blue
    environment:
      - SERVICE_NAME=blue
    expose:
      - "80"

  green:
    image: ikubernetes/servicemesh-app:latest
    networks:
      envoymesh:
        aliases:
          - myservice
          - service-green
          - green
    environment:
      - SERVICE_NAME=green
    expose:
      - "80"

  red:
    image: ikubernetes/servicemesh-app:latest
    networks:
      envoymesh:
        aliases:
          - myservice
          - service-red
          - red
    environment:
      - SERVICE_NAME=red
    expose:
      - "80"

  gray:
    image: ikubernetes/servicemesh-app:latest
    volumes:
      - ./service-gray.yaml:/etc/envoy/envoy.yaml
      - ./certs/service-gray/:/etc/envoy/certs/
    networks:
      envoymesh:
        ipv4_address: 172.31.90.15
        aliases:
          - gray
          - service-gray
    environment:
      - SERVICE_NAME=gray
    expose:
      - "80"
      - "443"

  purple:
    image: ikubernetes/servicemesh-app:latest
    volumes:
      - ./service-purple.yaml:/etc/envoy/envoy.yaml
      - ./certs/service-purple/:/etc/envoy/certs/
      - ./certs/CA/:/etc/envoy/ca/						#映射到envoy CA目录，CA证书可不用在envoy配置文件指定，就可默认调用此CA证书进行验证客户端证书
    networks:
      envoymesh:
        ipv4_address: 172.31.90.16
        aliases:
          - purple
          - service-purple
    environment:
      - SERVICE_NAME=purple
    expose:
      - "80"
      - "443"

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.90.0/24
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# tree certs/
certs/
|-- CA
|   |-- ca.crt
|   `-- ca.key
|-- front-envoy
|   |-- client.crt
|   |-- client.key
|   |-- server.crt
|   `-- server.key
|-- service-gray
|   |-- server.crt
|   `-- server.key
`-- service-purple
    |-- server.crt
    `-- server.key
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# cat front-envoy.yaml		#front-envoy实现http-https-http, http-https-https（单向和双向）
node:
  id: front-envoy
  cluster: front-envoy

admin:
  profile_path: /tmp/envoy.prof
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
       address: 0.0.0.0
       port_value: 9901

layered_runtime:
  layers:
  - name: admin
    admin_layer: {}

static_resources:
  secrets:					#静态指定证书，后面通过SDS发现调用这里证书
  - name: server_cert
    tls_certificate:
      certificate_chain:
        filename: "/etc/envoy/certs/server.crt"
      private_key:
        filename: "/etc/envoy/certs/server.key"
  - name: client_cert
    tls_certificate:
      certificate_chain:
        filename: "/etc/envoy/certs/client.crt"
      private_key:
        filename: "/etc/envoy/certs/client.key"
  - name: validation_context
    validation_context:
      trusted_ca:
        filename: "/etc/envoy/ca/ca.crt"

  listeners:
  - name: listener_http
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 80
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          codec_type: auto
          stat_prefix: ingress_http
          access_log:
          - name: envoy.access_loggers.file
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.access_loggers.file.v3.FileAccessLog
              path: "/dev/stdout"
          route_config:
            name: local_route
            virtual_hosts:
            - name: backend
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                redirect:
                  https_redirect: true
                  port_redirect: 443			#80重写向到443
          http_filters:
          - name: envoy.filters.http.router
            typed_config: {}

  - name: listener_https
    address:
      socket_address: { address: 0.0.0.0, port_value: 443 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_https
          codec_type: AUTO
          access_log:
          - name: envoy.access_loggers.file
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.access_loggers.file.v3.FileAccessLog
              path: "/dev/stdout"
          route_config:
            name: https_route
            virtual_hosts:
            - name: https_route
              domains: ["*"]
              routes:
              - match:
                  prefix: "/service/gray"
                route:
                  cluster: service-gray
              - match:
                  prefix: "/service/purple"
                route:
                  cluster: service-purple
              - match:
                  prefix: "/"
                route:
                  cluster: mycluster
          http_filters:
          - name: envoy.filters.http.router
            typed_config: {}
      transport_socket:  # DownstreamTlsContext
        name: envoy.transport_sockets.tls
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.DownstreamTlsContext
          common_tls_context:
            tls_certificate_sds_secret_configs:			#面向下游客户端时，提供给下游客户端的服务端证书，在front-envoy实现tls会话
            - name: server_cert

  clusters:
  - name: mycluster
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: mycluster
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: myservice
                port_value: 80

  - name: service-gray
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: service-gray
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: service-gray
                port_value: 443
    transport_socket:
      name: envoy.transport_sockets.tls
      typed_config:
        "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext
        common_tls_context:
          validation_context_sds_secret_config:				#验证service-gray的服务端证书
            name: validation_context

  - name: service-purple
    connect_timeout: 0.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: service-purple
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: service-purple
                port_value: 443
    transport_socket:
      name: envoy.transport_sockets.tls
      typed_config:
        "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext
        common_tls_context:
          tls_certificate_sds_secret_configs:			#提供客户端证书，因为service-purple需要验证客户端证书
          - name: client_cert
          validation_context_sds_secret_config:			#验证service-purple的服务端证书
            name: validation_context
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# cat service-gray.yaml			#单向TLS认证
admin:
  access_log_path: "/dev/null"
  address:
    socket_address:
      address: 0.0.0.0
      port_value: 9901

static_resources:
  listeners:
  - name: listener_http
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 80
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          codec_type: auto
          stat_prefix: ingress_http
          access_log:
          - name: envoy.access_loggers.file
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.access_loggers.file.v3.FileAccessLog
              path: "/dev/stdout"
          route_config:
            name: local_route
            virtual_hosts:
            - name: service
              domains:
              - "*"
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: local_service
          http_filters:
          - name: envoy.filters.http.router
            typed_config: {}

  - name: listener_https
    address:
      socket_address: { address: 0.0.0.0, port_value: 443 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_https
          codec_type: AUTO
          access_log:
          - name: envoy.access_loggers.file
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.access_loggers.file.v3.FileAccessLog
              path: "/dev/stdout"
          route_config:
            name: https_route
            virtual_hosts:
            - name: https_route
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: local_service
          http_filters:
          - name: envoy.filters.http.router
            typed_config: {}
      transport_socket:  # DownstreamTlsContext
        name: envoy.transport_sockets.tls
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.DownstreamTlsContext
          common_tls_context:
            tls_certificates:    # 基于DataSource，直接给出证书和私钥文件
              certificate_chain:
                filename: "/etc/envoy/certs/server.crt"
              private_key:
                filename: "/etc/envoy/certs/server.key"

  clusters:
  - name: local_service
    connect_timeout: 0.25s
    type: strict_dns
    lb_policy: round_robin
    load_assignment:
      cluster_name: local_service
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: 127.0.0.1
                port_value: 8080
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# cat service-purple.yaml		#双向tls认证(mTLS)
admin:
  access_log_path: "/dev/null"
  address:
    socket_address:
      address: 0.0.0.0
      port_value: 9901

static_resources:
  listeners:
  - name: listener_http
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 80
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          codec_type: auto
          stat_prefix: ingress_http
          access_log:
          - name: envoy.access_loggers.file
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.access_loggers.file.v3.FileAccessLog
              path: "/dev/stdout"
          route_config:
            name: local_route
            virtual_hosts:
            - name: service
              domains:
              - "*"
              routes:
              - match:
                  prefix: "/"
                redirect:
                  https_redirect: true
                  port_redirect: 443
          http_filters:
          - name: envoy.filters.http.router
            typed_config: {}

  - name: listener_https
    address:
      socket_address: { address: 0.0.0.0, port_value: 443 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_https
          codec_type: AUTO
          access_log:
          - name: envoy.access_loggers.file
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.access_loggers.file.v3.FileAccessLog
              path: "/dev/stdout"
          route_config:
            name: https_route
            virtual_hosts:
            - name: https_route
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: local_service
          http_filters:
          - name: envoy.filters.http.router
            typed_config: {}
      transport_socket:  # DownstreamTlsContext
        name: envoy.transport_sockets.tls
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.DownstreamTlsContext
          common_tls_context:
            tls_certificates:    # 基于DataSource，直接给出证书和私钥文件
              certificate_chain:
                filename: "/etc/envoy/certs/server.crt"
              private_key:
                filename: "/etc/envoy/certs/server.key"
          require_client_certificate: true   # 强制验证客户端证书	

  clusters:
  - name: local_service
    connect_timeout: 0.25s
    type: strict_dns
    lb_policy: round_robin
    load_assignment:
      cluster_name: local_service
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: 127.0.0.1
                port_value: 8080
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# curl http://172.31.90.10:9901/listeners
listener_http::0.0.0.0:80
listener_https::0.0.0.0:443
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# curl http://172.31.90.10:9901/certs
{
 "certificates": [
  {
   "ca_cert": [
    {
     "path": "/etc/envoy/ca/ca.crt",
     "serial_number": "2e83ac398058147270321e1ac3eef856024ecb3b",
     "subject_alt_names": [],
     "days_until_expiration": "3644",
     "valid_from": "2022-04-13T09:00:43Z",
     "expiration_time": "2032-04-10T09:00:43Z"
    }
   ],
   "cert_chain": []
  },
  {
   "ca_cert": [
    {
     "path": "/etc/envoy/ca/ca.crt",
     "serial_number": "2e83ac398058147270321e1ac3eef856024ecb3b",
     "subject_alt_names": [],
     "days_until_expiration": "3644",
     "valid_from": "2022-04-13T09:00:43Z",
     "expiration_time": "2032-04-10T09:00:43Z"
    }
   ],
   "cert_chain": [
    {
     "path": "/etc/envoy/certs/client.crt",
     "serial_number": "1001",
     "subject_alt_names": [],
     "days_until_expiration": "3644",
     "valid_from": "2022-04-13T09:01:28Z",
     "expiration_time": "2032-04-10T09:01:28Z"
    }
   ]
  },
  {
   "ca_cert": [],
   "cert_chain": [
    {
     "path": "/etc/envoy/certs/server.crt",
     "serial_number": "1000",
     "subject_alt_names": [],
     "days_until_expiration": "3644",
     "valid_from": "2022-04-13T09:01:00Z",
     "expiration_time": "2032-04-10T09:01:00Z"
    }
   ]
  }
 ]
}
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# curl -I http://172.31.90.10
HTTP/1.1 301 Moved Permanently
location: https://172.31.90.10:443/			#当访问front-envoy 80端口时会重定向到443
date: Tue, 19 Apr 2022 02:44:35 GMT
server: envoy
transfer-encoding: chunked
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# curl -k https://172.31.90.10/service/gray	#-k表示使用 SSL 时允许不安全的服务器连接，表示默认信息服务端证书
Hello from App behind Envoy (service gray)! hostname: 9612d4c4c7b8 resolved hostname: 172.31.90.15
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# curl -k https://172.31.90.10/service/purple
Hello from App behind Envoy (service purple)! hostname: 559173018c24 resolved hostname: 172.31.90.16
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# curl -k https://172.31.90.10/service/colors
Hello from App behind Envoy (service blue)! hostname: 12ae979d262a resolved hostname: 172.31.90.3
root@front-envoy:~/servicemesh_in_practise/Security/tls-static# curl -k https://172.31.90.10/service/colors
Hello from App behind Envoy (service green)! hostname: 3dc0e0583053 resolved hostname: 172.31.90.4
	
#SPIFFE基础概念---SPIFFE：全称(Secure Production Identity Framework for Everyone)
- SPIFFE是一套开源的安全生产身份框架，用于在动态和异构环境中安全地识别软件系统
  - 微服务、容器编排平台和云计算等分布式模式和实践导致生产环境越来越动态及异构化
  - 传统的安全实践（例如仅允许特定IP地址之间的流量策略）难以应对这种复杂性，因为，适用于识别所有工作负载的一等身份管理框架就成了迫切之需
- SPIFFE标准定义了一套能够跨异构环境和组织边界完成bootstrap以及向服务发布身份ID的安全框架
  - 这些规范的核心是定义短期加密身份文档的规范，自然流产为SVID；随后，工作负载可以在向其它工作负载进行身份验证时使用这些身份文档，例如通过建立TLS连接或通过签署和验证JWT令牌
    - SPIFFE规范标准化了向工作负载(workload)分配身份、验证和确认工作负载身份以及工作负载API以检索身份的过程；
	- SPIFFE身份包含在SVID(SPIFFE Verifiable Identity Document)中，SVID规范提供了实现SVID时必须支持的属性的要求；
  - 简单来说，SPIFFE是一个可信bootstrap和identification框架，它已作为标准提交并被CNCF接受
- SPIFFE规范的常见实现
  - SPIRE
  - Istio: Istio control plan负责向所有的工作负载发放SPIFFE ID
  - HashiCorp Consul
  - Kuma
#SPIRE
- SPIRE是SPIFFE API的可用于生产的具体实现之一，它负责执行node和workload的身份证明，以便根据一组预定义的条件安全地向workload签发SVID，并验证其它workload的SVID
- SPIIRE可以用于多种情况，并可以执行多种与身份相关的功能
  - 服务之间的安全身份验证
  - 安全地引入Vault和Pinterest Knox等secret stores;
  - 为服务网格中的sidecar代理服务提供身份认证的基础设施，这个就是我们主要使用的原因
  - 用于分布式系统组件的PKI的供给和轮替
#SPIRE认证组件
- SPIRE Server: 签名授权机构，它通过各SPIRE Agent接收请求
  - 负责管理和发布已配置的SPIFFE可信域中的所有身份；
  - 它存储注册条目(用于指定确定特定SPIFFE ID的发布条件的选择器）和签名密钥
  - 使用node attestation自动认证Agent的身份，并在经过认证的agent请求时为其本地的workload创建SVID
- SPIRE Agent: 运行于各工作节点，用于向节点上的workload提供workload API
  - 从服务器请求SVID并缓它们，直到workload请求其SVID
  - 将SPIFFE Workload API暴露给本地节点上的workload，并负责证明调用它的workload的身份
  - 提供已识别的workload及其SVID
#SPIRE Server
- SPIRE Server高度插件化，用户需要通过一系列插件来配置其行为
  - Node attestor插件负责结合各节点上运行的agent node attestor插件一同来验证节点身份
  - Node resolver为SPIRE Server提供一系列selector（选择器）从而让Server能够基于其它属性来验证节点身份
  - Datastore插件被SPIRE Server用于存储、查询和更新各种信息，例如registration entries，包括哪些节点身份已得到证明，以及这些节点各自相关的选择器等
    - 内置的数据存储插件支持使用SQLite 3ak PostgreSQL作为存储后端 
	- 默认情况下，它使用SQLite 3
  - Key manager插件负责控制服务器如何存储用于签署X.509-SVID和JWT-SVID的私钥 
  - 默认情况下，SPIRE Server充当其自己的证书颁发机构，必要时也可以使用Upstream certificate authority(CA)插件来使用来自不同PKI系统的不同CA
#SPIRE Agent
- SPIRE Agent 需要运行于每个运行有workload的节点上，并负责以下任务
  - 从SPIRE Server请求SVID并缓存它们，直到workload请求其SVID
  - 将SPIFFE Workload API暴露给节点是的workload，并证明调用它的workload的身份
  - 提供已识别的workload及其SVID
- SPIRE Agent同样基于组合配置一系列插件完成其工作
  - Node attestor插件同Server端的node attestor插件一起完成对agent程序所在节点的身份验证
  - Workload attestor插件通过从节点操作系统查询相关进程的信息，并将其与使用selector注册workload属性时提供给server的信息进行比较，比而验证节点上workload进程的身份
  - Key manager插件，负责让agent用来为发布给workload的X.509-SVID生成私钥
  
  
  
  
  
  
  



</pre>