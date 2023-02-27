# calico



## 一、Calico基础介绍

**官方网站**：https://www.tigera.io/project-calico/

参考文档：https://zhangzhuo.ltd/articles/2022/05/01/1651406979988.html

Calico 是一个 CNI 插件，为 Kubernetes 集群提供容器网络。它使用 Linux 原生工具来促进流量路由和执行网络策略。它还托管一个 BGP 守护进程，用于将路由分发到其他节点。Calico 的工具作为 DaemonSet 在 Kubernetes 集群上运行。这使管理员能够安装 Calico， `kubectl apply -f ${CALICO_MANIFESTS}.yaml`而无需设置额外的服务或基础设施。

**Calico部署建议**：

1.使用 Kubernetes 数据存储。
2.安装 Typha 以确保数据存储可扩展性。
3.对单个子网集群不使用封装。
4.对于多子网集群，在 CrossSubnet 模式下使用 IP-in-IP。
5.根据网络 MTU 和选择的路由模式配置 Calico MTU。
6.为能够增长到 50 个以上节点的集群添加全局路由反射器。
7.将 GlobalNetworkPolicy 用于集群范围的入口和出口规则。通过添加 namespace-scoped 来修改策略NetworkPolicy。



### 1.1 calico基础架构即组件介绍

calico在kubernetes中部署，有三种部署架构，他的架构模式取决于使用什么后端存放calico的数据，常见的一般为俩种分别是使用kubernetes api资源或直接使用etcd，但是官方推荐如果只部署到kubernetes使用kubernetes api即可，这样有利于管理calico的各种配置，他们会被定义为crd资源可以直接使用kubectl进行管理。如果直接使用etcd需要额外维护etcd集群，不推荐与Kubernetes集群共用一个etcd。

**calico各个组件介绍**：

- calico/node: 该agent作为Calico守护进程的一部分运行。它管理接口，路由和接点的状态报告及强制性策略。
- Calico Controller: Calico策略控制器。
- Typha：守护进程位于数据存储（例如 Kubernetes API 服务器）和许多Felix实例之间,来处理他们之间的请求。



### 1.2 calico-node

calico-node会在kubernetes的中以DaemonSet的方式在每个node节点进行运行主要实现俩个功能。

- 路由维护：维护node节点到自己运行的Pod的路由地址。
- 路由共享：基于每个node节点获取的地址池共享路由。

为了实现以上的两个功能，calico-node运行了两个进程

- Felix：calico的核心组件，运行在每个节点上。主要的功能有 接口管理、路由规则、ACL规则、状态报告
  1. `接口管理`：Felix为内核编写一些接口信息，以便让内核能正确的处理主机endpoint的流量。特别是主机之间的ARP请求和处理ip转发。
  2. `路由规则`：Felix负责主机之间路由信息写到linux内核的FIB（Forwarding Information Base）转发信息库，保证数据包可以在主机之间相互转发。
  3. `ACL规则`：Felix负责将ACL策略写入到linux内核中，保证主机endpoint的为有效流量不能绕过calico的安全措施。
  4. `状态报告`：Felix负责提供关于网络健康状况的数据。特别是，它报告配置主机时出现的错误和问题。这些数据被写入etcd，使其对网络的其他组件和操作人员可见。
- BIRD ：BGP客户端，Calico在每个节点上的都会部署一个BGP客户端，它的作用是将Felix的路由信息读入内核，并通过BGP协议在集群中分发。当Felix将路由插入到Linux内核FIB中时，BGP客户端将获取这些路由并将它们分发到部署中的其他节点。这可以确保在部署时有效地路由流量。VXLAN封装不需要BGP可以选择关闭。默认为TCP协议端口为(179)。

![calico-node](..\image\k8s\calico\calico-node.png)



### 1.3 Calico-Controller

Calico-Controller的主要作用为，负责识别Kubernetes对象中影响路由的变化。 控制器内部包含多个控制器，监视以下变化:

1. Network Policies：网络策略，被用作编写iptables来执行网络访问的能力
2. Pods：察Pod的变化，比如标签的变化
3. Namespaces：名称空间的变化
4. Service Accounts：SA设置Calico的配置文件
5. Nodes：通知节点路由变化

**控制器包括**

- policy-controller
- ns-controller
- sa-controller
- pod-controller
- node-controller

![calico-node](..\image\k8s\calico\calico-controller.png)

### 1.4 Typha

Typha 守护进程位于数据存储（例如 Kubernetes API 服务器）和许多 Felix 实例之间。Typha 的主要目的是通过减少每个节点对数据存储的影响来增加规模。Felix和conf等服务连接到 Typha，而不是直接连接到数据存储，因为 Typha 代表其所有客户端维护单个数据存储连接。它缓存数据存储状态并删除重复事件，以便可以将它们分散到许多侦听器。来减少后端的存储负载。

如果您使用的是 Kubernetes API 数据存储区，如果您有超过 50 个 Kubernetes 节点，我们建议您使用 Typha。虽然Typha可以与etcd一起使用，但etcd v3已经针对处理许多客户端进行了优化，因此使用它是多余的，不推荐使用。

- 由于一个 Typha 实例可以支持数百个 Felix 实例，因此它大大减少了数据存储的负载。
- 由于 Typha 可以过滤掉与 Felix 无关的更新，因此也降低了 Felix 的 CPU 使用率。在大规模（超过 100 个节点）Kubernetes 集群中，这是必不可少的，因为 API 服务器生成的更新数量会随着节点数量的增加而增加。

![calico-node](..\image\k8s\calico\typha.png)



## 二、Calico部署

kubernetes中部署calico官方分别提供了三种部署方式

1. calico-etcd: calico直接使用etcd作为后端数据存储，官方不建议将etcd数据库用于新安装。但是如果您将 Calico 作为 OpenStack 和 Kubernetes 的网络插件运行是可以这样运行的。
2. calico-typha: 使用 Kubernetes API 数据存储calico的数据，安装的kubernetes的node节点超过50个推荐使用，即使没有超过50也推荐使用。
3. calico：使用 Kubernetes API 数据存储calico的数据，安装的kubernetes的node节点未超过50个推荐使用，但是不推荐这样使用。



## 三、Calico常用异常

* 流量异常

1. k8s集群安装了istio，并部署了istio插件 for Prometheus-Server、Grafana、Kiali
2. 随着时间的增长，calico-node和node-exporter（以DaemonSet方式部署，二者接收和改善流量相似）流量不断增大
3. 特别是3台master(安装了istiod、istio-ingressgateway)上的calico-node和node-exporter发送流量增大，达到12M/s左右。
4. 而部署了istio for Prometheus-Server的节点192.168.13.38上接收流量变得很大，平均达到220M/s左右
5. 将istio插件 for Prometheus-Server、Grafana、Kiali从K8s移除后，流量降下来了，以此推测，是istio for prometheus-server收集istio metric时导致流量过大
6. 目前k8s集群还有prometheus-server，此收集还会有一定影响(用来收集k8s集群中的ArgoCD，默认收集监控k8s apiSserver，controller manager, scheduler, node, )，目前流量还可接收，暂不移除

![192.168.13.38-node-Received](..\image\k8s\calico\prometheus-node-received.png)

![192.168.13.31-node-Send](..\image\k8s\calico\prometheus-node-Send.png)



![192.168.13.38-pod-Received](..\image\k8s\calico\prometheus-pod-received.png)

![192.168.13.38-pod-Send](..\image\k8s\calico\prometheus-pod-send.png)





