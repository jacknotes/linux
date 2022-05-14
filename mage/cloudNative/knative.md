#knative

<pre>
#分布式应用程序的需求
- 生命周期（lifecycle）
- 网络（networking）
- 绑定（binding）
- 状态（state）

#多运行时微服务
- 生命周期管理：Kubernetes
- 网络：Service Mesh（Istio）
  - 分布式应用的高级网络通信需求
- 绑定：Knative
  - 专注于Serviceless，同时兼顾了服务编排和事件驱动的绑定需求
- 状态：Dapr
  - 建立在Kubernetes、Knative和服务网格的思想之上，并深入应用程序运行时以解决状态化工作负载、绑定和集成的需求，充当现代分布式中间件

#Serverless基础
- Serverless的基础概念
  - 云原生开发模型的一种，可使开发人员专注于构建和运行应用，而无需管理服务器
  - Serverless方案中仍然需要服务器，但它们已从应用开发人员的关注中抽离了出来
    - 云提供商负责置备、维护和扩展服务器基础架构等例行工作
	- 开发人员可以简单地将代码打包到容器中进行部署
	- 部署之后，无服务器应用即可响应需求，并根据需要自动扩容
- Serverless与其它云计算模型的核心区别
  - 由云服务商负责管理基础架构和应用扩展
  - 应用部署于容器中，这些容器在被调用时将会自动按需启动
    - 出现能够触发应用代码运行的事件时，云架构才会为这一代码分配资源
	- 代码执行结束后，占用的大部分资源便即释放
	- 帮助公司避免服务器等资源的过度采购，提高资源效益
  - 操作系统、文件系统、安全补丁、负载均衡、容量管理、扩展、日志和监控等例行任务都由底层的云服务完成，从而将开发人员从应用扩展和服务器置备相关的琐碎日常任务中解放出来
- 现代应用架构通常是Serverless、Microservices和传统分布式应用的混合模式
- Serverless产品通常可分为两类
  - BaaS（Backend as a Service）
  - FaaS（Function as a Service）
- Baas
  - 云服务端将后端需要的各种服务，例如认证服务、数据库、消息队列、文件存储、代码构建等各种后端功能封装为API提供给用户
  - 用户只需要根据BaaS的API编写并提交代码即可自动完成应用构建、部署、运行、扩缩容等功能
- FaaS
  - 由事件驱动计算执行的应用架构模型
  - 开发人员编写逻辑代码，并将其部署到完全由平台（云服务商）管理的容器中，然后按需执行
    - 开发人员通过API调用Serverless应用
	- FaaS服务商通过API网关来处理API调用请求
  - 运行Serverless代码的容器的特点
    - 无状态 - 让数据集成变得更加简单
	- 寿命短 - 可以只运行非常短的时间
	- 由事件触发 - 可在需要时自动运行
	- 完全由云提供商管理
	
#BaaS模型
- 较之PaaS，BaaS能够为用户实现更多的价值
  - IaaS=数据中心+服务器+存储+网络
  - PaaS=IaaS+部署+管理+扩展
  - BaaS=PaaS+自动化构建（有些PaaS也提供自动化构建）
- 缺点
  - 供应商锁定

#BaaS与FaaS的区别
- BaaS处理整个后端功能，而FaaS仅处理应用程序中支持响应的事件

#Serverless的优缺点
- 优点
  - 较低的运维成本
  - 较低的开发成本
  - 自动化弹性扩展
  - 较高的计算资源利用率
- 缺点
  - 仅支持无状态服务
  - 延迟问题
    - 高度分布式导致延迟增大
	- 冷启动存在延迟
  - 尚未形成统一标准
  - 存在厂商锁定的可能性
  
#Serverless的主流产品
- 云厂商的FaaS产品
  - AWS Lambda
  - Google Cloud Functions
  - Microsoft Azure Functions(open source)
  - Aliyun Function Compute
  - Huawei Cloud FunctionGraph(函数工作流)
  - ...
- 开源解决方案
  - Apache OpenWhisk
  - OpenFaaS
  - Fission
  - Kubeless
  - Knative（是serverless平台，不是FaaS的实现，是FaaS的平台）
  


#Knative基础
Knative是什么？
1. 基于Kubernetes平台，用于部署和管理现代serverless工作负载，是serverless平台，而非Serverless的实现
2. 若能够把Kubernetes看作是一个分布式的内核，则Knative也可被类比为该内核之上的"分布式的libc"

#Knative项目
- Knative项目简介
  - 读音为"kay-nay-tiv"，由Google于2018年7月正式发布
  - Kubernetes平台的原生扩展组件，让其能够轻松地部署、运行和管理Serverless类型的云原生应用
  - 由RedHat、Google和IBM等公司，以及各种初创公司组成的开源社区共同维护
  - 目标在于Serverless技术标准化
- Knative的组件
  - Serving
    - 部署、管理及扩展无状态应用
	- 支持由请求驱动计算
	- 支持缩容至0
  - Eventing
    - 以声明的方式创建对事件源的订阅，并将事件路由到目标端点
	- 事件订阅、传递和处理
	- 基于pub/sub模型连接Knative的工作负载
  - Build
    - 从源代码构建出应用镜像
	- 已经由独立的Tekton项目取代，新的Knative不包括Build了
	
#Knative的架构体系
- 遵照Kubernetes的范式，以扩展的方式，通过自定义API资源类型支持
  - 自动化完成服务的部署的扩缩容(Serving)
  - 标准化事件驱动基础设施(Eventing)
- Serving(BaaS组件)
  - Serving Controller
  - Rosources API
    - Service(kService)
	- Configuration
	- Revision
	- Route
- Eventing(FaaS组件)
  - Eventing Controller
  - Resource API
    - Broker
	- Trigger
	- EventType
	- ...
	
#Knative Serving架构
- 相关的资源API定义在"serving.knative.dev"群组中
- 主要包括四个CRD
  - Service(kNative)
    - 对自动编排Serverless类型应用的功能的抽象，负责自动管理工作负载的整个生命周期
	- 它能自动控制下面三个类型的资源对象的管理
  - Configuration
    - 反映子Service(kNative)当前期望状态（Spec）的配置
	- Service(kNative)对象的更新，也将导致Configuration的更新
  - Revision
    - Service的每次代码或配置变更都会生成一个Revision
	- 快照型数据，不可变
  - Route
    - 将请求流量路由到目标Revison
	- 支持将流量按比例切分并路由到多个Revision
	
#事件与Knative Eventing
- Knative Eventing
  - 负责为事件的生产和消费提供基础设施，可将事件从生产者路由到目标消费者，从而让开发人员能够使用事件驱动架构
  - 各资源者是松散耦合亲在么，可分别独立开发和部署
  - 遵循CloudEvents规范
- 需要特别说明的几个问题？
  - Knative是FaaS解决方案吗？
    - Knative并未提供FaaS（Knative是运行接口，并不是编程接口）
	- 用户可在Knative和Kubernetes之上，借助于第三方项目自行构建FaaS系统，例如Kyma Project
  - Knative与Kubernetes扩展出的功能
    - Serving
	  - 替代Deplooyment控制器，负责编排运行基于HTTP协议的无状态应用
	  - 基于单个请求进行负载均衡
	  - 基于请求的快速、自动化扩缩容，并支持收缩至0实例
	  - 通过在Pod扩展时缓冲请求来削峰填谷
	  - 流量切分
	  - ...
	- Eventing
	  - 声明式事件配置接口

#Knative适合运行的应用类型
- Knative仅适合运行特定类型的应用：无状态、容器化的服务器应用
  - 监听于某套接字之上提供服务的应用，不适合运行批处理作业
  - 仅支持无状态应用，同一服务的各实例间无差别，可简单进行扩容和缩容
  - 仅支持通过HTTP/1, HTTP/2或gRPC通信的服务端应用
  - 应用程序要能够构建为OCI容器镜像
  
#部署Knative
- 示例环境
  - Kubernetes：v1.23
  - Knative: v1.2
  - networking layer: istio 1.12
- 可用部署方式
  - 基于YAML配置文档直接部署
    - Serving和Eventing需要分别进行部署
  - 借助Knative Operator进行部署
    - 首先部署Knative Operator 
	- 通过Operator的KnativeServing资源部署Serving
	- 通过Operator的KnativeEventing资源部署Eventing
- 需要部署的Knative组件
  - Serving
  - Eventing
  - kn(Knative CLI)
  
#部署Serving
- 环境要求
  - 测试环境
    - 单节点的Kubernetes集群，有2个可用的CPU核心，以及4G内存
  - 生产环境
    - 单节点的Kubernetes集群，至少有6个可用的CPU核心，以及6G内存和30G磁盘空间
	- 多节点的Kubernetes集群，每个节点至少有2个CPU核心，4G内存和20G磁盘空间
	- Kubernetes版本最低为v1.21
- 安装步骤
  - 部署Serving核心组件
  - 部署网络层（networking layer）组件
    - Istio, Contour(ingress controller，基于envoy), Kourie(knative自己研发，目前处于alpha)三选一
  - （可选）部署DNS
  - （可选）部署Serving扩展
    - HPA：用于支持Kubernetes的HPA，Knative的HPA是基于并发连接、每秒连接请求数来进行限制的
	- Cert Manager：用于为工作负载自动签发TLS证书
	- Encrypt HTTP01：用于为工作负载自动签发TLS证书
	- 注：istio有自动签发证书，如果使用istio，则Cert Manager和Encrypt HTTP01将不需要部署
	- 注：Serving是不依赖Eventing，后面单独部署Eventing
#Serving的子组件
- Serving依赖于几个关键的组件协同其管理能力
  - Activator：Revision中的Pod数量收缩至0时，activator负责接收并缓存相关的请求，同时报告指标数据给Autoscaler，并在Autoscaler在Revision上扩展出必要的Pod后，再将请求路由至相应的Revision
  - Autoscaler：Knative通过注入一个称为queue-proxy容器的sidecar代理来了解它部署的Pod上的请求，而Autoscaler会为每个服务使用"每秒请求数"来自动缩放其Revision上的Pod
  - Controller：负责监视Serving CRD（KService、Configuration、Route和Revision）相关的API对象并管理它们的生命周期，是Service声明式API的关键保障
  - webhook：为Kubernetes提供的外置Admission Controller，兼具Validation和Mutation的功能，主要作用于Serving专有的几个API资源类型之上，以及相关的ConfigMap资源上
  - Domain-mapping：将指定的域名映射至Service、KService，甚至是Knative Route之上，从而使用自定义域名访问特定的服务
  - Domainmapping-Webhook: Domain-mapping专用的Admission Controller
  - net-certmanager-controller: 与Cert Manager协同时使用的专用的控制器
  - net-istio-controller: 与istio协同时使用的专用控制器
  
	
###部署knative
官方文档：https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml/

1. 查看kubernetes版本，为1.21.5。
--问题：不知道为啥后续查看kubectl get routes时，READY为Unknown,REASON为Uninitialized，
--解决：后面重新部署了单master集群，版本为v1.23.1，然后一样的操作就成功了。master配置为4C4G,node02和node03为4C8G
root@k8s-master01:~# kubectl get nodes
NAME            STATUS                     ROLES    AGE   VERSION
172.168.2.21    Ready,SchedulingDisabled   master   62d   v1.21.5
172.168.2.22    Ready,SchedulingDisabled   master   62d   v1.21.5
172.168.2.23    Ready,SchedulingDisabled   master   61d   v1.21.5
172.168.2.24    Ready                      node     62d   v1.21.5
172.168.2.25    Ready                      node     62d   v1.21.5
172.168.2.26    Ready                      node     61d   v1.21.5
192.168.13.63   Ready                      node     46d   v1.21.5

2. 查看节点CPU和内存状态
----cpu核心数
root@ansible:~# ansible k8s -m shell -a 'cat /proc/cpuinfo | grep -i processor | wc -l'
192.168.13.63 | SUCCESS | rc=0 >>
8

172.168.2.26 | SUCCESS | rc=0 >>
2

172.168.2.21 | SUCCESS | rc=0 >>
2

172.168.2.22 | SUCCESS | rc=0 >>
2

172.168.2.25 | SUCCESS | rc=0 >>
2

172.168.2.24 | SUCCESS | rc=0 >>
2

172.168.2.23 | SUCCESS | rc=0 >>
2
----内存大小，worker节点都是4G以上
root@ansible:~# ansible k8s -m shell -a 'free -h'
172.168.2.25 | SUCCESS | rc=0 >>
              total        used        free      shared  buff/cache   available
Mem:           3.8G        378M        2.8G         13M        652M        3.2G
Swap:            0B          0B          0B

192.168.13.63 | SUCCESS | rc=0 >>
              total        used        free      shared  buff/cache   available
Mem:            11G        5.4G        737M        568M        5.6G        5.6G
Swap:            0B          0B          0B

172.168.2.24 | SUCCESS | rc=0 >>
              total        used        free      shared  buff/cache   available
Mem:           3.8G        473M        2.6G         14M        747M        3.1G
Swap:            0B          0B          0B

172.168.2.22 | SUCCESS | rc=0 >>
              total        used        free      shared  buff/cache   available
Mem:           1.9G        1.1G         76M         10M        817M        887M
Swap:            0B          0B          0B

172.168.2.26 | SUCCESS | rc=0 >>
              total        used        free      shared  buff/cache   available
Mem:           3.8G        1.0G        611M         15M        2.2G        2.8G
Swap:            0B          0B          0B

172.168.2.23 | SUCCESS | rc=0 >>
              total        used        free      shared  buff/cache   available
Mem:           1.9G        1.2G         71M         11M        697M        759M
Swap:            0B          0B          0B

172.168.2.21 | SUCCESS | rc=0 >>
              total        used        free      shared  buff/cache   available
Mem:           1.9G        1.2G         79M         10M        710M        768M
Swap:            0B          0B          0B

3. 安装kanative v1.2
----先安装serving-crds，再安装serving-core
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.2.0/serving-crds.yaml
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.2.0/serving-core.yaml
--从马哥github上获取Knative yaml清单文件进行部署
root@front-envoy:~/knative# git clone https://github.com/iKubernetes/knative-in-practise.git
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/serving# ls
README.md  serving-core.yaml  serving-crds.yaml
--部署serving-crds.yaml
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/serving# kubectl apply -f serving-crds.yaml	#部署crd资源
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/serving# kubectl api-versions | grep knative	#查看crd资源，用以支持部署knative
autoscaling.internal.knative.dev/v1alpha1
caching.internal.knative.dev/v1alpha1
networking.internal.knative.dev/v1alpha1
serving.knative.dev/v1
serving.knative.dev/v1alpha1
serving.knative.dev/v1beta1
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/serving# kubectl api-resources | grep knative
metrics                                           autoscaling.internal.knative.dev/v1alpha1   true         Metric
podautoscalers                    kpa,pa          autoscaling.internal.knative.dev/v1alpha1   true         PodAutoscaler
images                            img             caching.internal.knative.dev/v1alpha1       true         Image
certificates                      kcert           networking.internal.knative.dev/v1alpha1    true         Certificate
clusterdomainclaims               cdc             networking.internal.knative.dev/v1alpha1    false        ClusterDomainClaim
ingresses                         kingress,king   networking.internal.knative.dev/v1alpha1    true         Ingress
serverlessservices                sks             networking.internal.knative.dev/v1alpha1    true         ServerlessService
configurations                    config,cfg      serving.knative.dev/v1                      true         Configuration
domainmappings                    dm              serving.knative.dev/v1beta1                 true         DomainMapping
revisions                         rev             serving.knative.dev/v1                      true         Revision
routes                            rt              serving.knative.dev/v1                      true         Route
services                          kservice,ksvc   serving.knative.dev/v1                      true         Service
#Serving的API
- Serving有如下几个专用的CRD
  - serving.knative.dev群组
    - Service
	- Configuration
	- Revision
	- Route
	- Domainmapping-Webhook
  - autoscaling.internal.knative.dev群组
    - Metric
	- PodAutoscaler
  - networking.internal.knative.dev群组
    - ServerlessService
	- ClusterDomainClaim
	- Certificate
	
--部署serving-core.yaml
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/serving# kubectl apply -f serving-core.yaml	
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/serving# kubectl get ns | grep knative	#此时会自动创建knative相关的名称空间knative-serving
knative-serving        Active   52s

5. 因为需要去gcr下载镜像，国内无法访问，需要配置代理
root@k8s-master01:~# kubectl get pods -n knative-serving	#无法下载镜像
NAME                                     READY   STATUS             RESTARTS   AGE
activator-85bd4ddcbb-gmblt               0/1     ImagePullBackOff   0          17h
autoscaler-84fcdc5449-w8wgm              0/1     ImagePullBackOff   0          17h
controller-6fd5bb86df-zjgmv              0/1     ImagePullBackOff   0          17h
domain-mapping-74d5d688bd-8z7d7          0/1     ImagePullBackOff   0          17h
domainmapping-webhook-8484d5fd8b-5sncn   0/1     ImagePullBackOff   0          17h
webhook-97c648588-g4lpd                  0/1     ImagePullBackOff   0          17h
root@ansible:~/ansible# cat docker.service.d/http-proxy.conf		#配置代理，使node节点可下载gcr镜像
[Service]
Environment="HTTP_PROXY=http://172.168.2.29:8118"
Environment="HTTPS_PROXY=http://172.168.2.29:8118"
Environment="NO_PROXY=localhost,127.0.0.1,192.168.10.0/24,192.168.13.0/24,172.168.2.0/24,.hs.com"
root@ansible:~/ansible# ansible k8s -m copy -a 'src=./docker.service.d dest=/etc/systemd/system/'
root@ansible:~/ansible# ansible k8s -m shell -a 'systemctl daemon-reload && systemctl restart docker.service' #重启docker使代理配置生效，docker reload不会生效
root@k8s-master01:~# kubectl get all -n knative-serving		#knative-serving名称空间所有信息
NAME                                         READY   STATUS    RESTARTS   AGE
pod/activator-85bd4ddcbb-7fw5q               1/1     Running   0          13m
pod/autoscaler-84fcdc5449-w8wgm              1/1     Running   0          17h
pod/controller-6fd5bb86df-br4g6              1/1     Running   0          13m
pod/domain-mapping-74d5d688bd-8z7d7          1/1     Running   0          17h
pod/domainmapping-webhook-8484d5fd8b-gcrwp   1/1     Running   0          13m
pod/webhook-97c648588-mhtzs                  1/1     Running   0          13m

NAME                                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                           AGE
service/activator-service            ClusterIP   10.68.162.128   <none>        9090/TCP,8008/TCP,80/TCP,81/TCP   17h
service/autoscaler                   ClusterIP   10.68.175.94    <none>        9090/TCP,8008/TCP,8080/TCP        17h
service/autoscaler-bucket-00-of-01   ClusterIP   10.68.162.230   <none>        8080/TCP                          18m
service/controller                   ClusterIP   10.68.123.227   <none>        9090/TCP,8008/TCP                 17h
service/domainmapping-webhook        ClusterIP   10.68.234.252   <none>        9090/TCP,8008/TCP,443/TCP         17h
service/webhook                      ClusterIP   10.68.24.177    <none>        9090/TCP,8008/TCP,443/TCP         17h

NAME                                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/activator               1/1     1            1           17h
deployment.apps/autoscaler              1/1     1            1           17h
deployment.apps/controller              1/1     1            1           17h
deployment.apps/domain-mapping          1/1     1            1           17h
deployment.apps/domainmapping-webhook   1/1     1            1           17h
deployment.apps/webhook                 1/1     1            1           17h

NAME                                               DESIRED   CURRENT   READY   AGE
replicaset.apps/activator-85bd4ddcbb               1         1         1       17h
replicaset.apps/autoscaler-84fcdc5449              1         1         1       17h
replicaset.apps/controller-6fd5bb86df              1         1         1       17h
replicaset.apps/domain-mapping-74d5d688bd          1         1         1       17h
replicaset.apps/domainmapping-webhook-8484d5fd8b   1         1         1       17h
replicaset.apps/webhook-97c648588                  1         1         1       17h

NAME                                            REFERENCE              TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/activator   Deployment/activator   0%/100%   1         20        1          17h
horizontalpodautoscaler.autoscaling/webhook     Deployment/webhook     7%/100%   1         5         1          17h


6. 安装networking layer
注：先清除原有的istio
root@k8s-master01:~# istioctl experimental uninstall --purge
All Istio resources will be pruned from the cluster
Proceed? (y/N) y
root@k8s-master01:~# kubectl delete ns istio-system  --force --grace-period=0	#删除名称空间下所有资源

----有3个选择，Kourier(默认)、Istio、Contour，这里我们安装istio
6.1 部署高可用版istio
kubectl apply -l knative.dev/crd-install=true -f https://github.com/knative/net-istio/releases/download/knative-v1.2.0/istio.yaml
kubectl apply -f https://github.com/knative/net-istio/releases/download/knative-v1.2.0/istio.yaml
--使用已经下载的清单直接应用
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/istio# ls
istio.yaml  net-istio.yaml  README.md
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/istio# kubectl apply -l knative.dev/crd-install=true -f istio.yaml	#先配置knative的crd与istio相结合使用，有报错不用管它
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/istio# kubectl apply -f istio.yaml	#再来安装isto 
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/istio# kubectl get all -n istio-system
NAME                                       READY   STATUS    RESTARTS   AGE
pod/istio-ingressgateway-fbb76f5df-j9z8t   1/1     Running   0          2m35s
pod/istio-ingressgateway-fbb76f5df-v9dnd   1/1     Running   0          2m34s
pod/istio-ingressgateway-fbb76f5df-z5xln   1/1     Running   0          2m34s
pod/istiod-6fb996b56-7t6tw                 1/1     Running   0          2m16s
pod/istiod-6fb996b56-v9gck                 1/1     Running   0          2m35s
pod/istiod-6fb996b56-w7vfg                 1/1     Running   0          2m16s

NAME                            TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                                      AGE
service/istio-ingressgateway    LoadBalancer   10.68.205.10   <pending>     15021:49887/TCP,80:62968/TCP,443:33085/TCP   2m34s
service/istiod                  ClusterIP      10.68.89.157   <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP        2m33s
service/knative-local-gateway   ClusterIP      10.68.27.100   <none>        80/TCP                                       36s

NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/istio-ingressgateway   3/3     3            3           2m35s
deployment.apps/istiod                 3/3     3            3           2m35s

NAME                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/istio-ingressgateway-fbb76f5df   3         3         3       2m35s
replicaset.apps/istiod-6fb996b56                 3         3         3       2m35s

NAME                                         REFERENCE           TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/istiod   Deployment/istiod   1%/60%    3         10        3          2m31s
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/istio# kubectl --namespace istio-system get service istio-ingressgateway
NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                                      AGE
istio-ingressgateway   LoadBalancer   10.68.205.10   <pending>     15021:49887/TCP,80:62968/TCP,443:33085/TCP   2m41s	#测试环境配置externalIPs
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/istio# kubectl edit -n istio-system service istio-ingressgateway
spec:
  externalIPs:
  - 172.168.2.28
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/istio# kubectl --namespace istio-system get service istio-ingressgateway
NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)                                      AGE
istio-ingressgateway   LoadBalancer   10.68.205.10   172.168.2.28   15021:49887/TCP,80:62968/TCP,443:33085/TCP   3m59s

6.2 安装Knative Istio 控制器	
kubectl apply -f https://github.com/knative/net-istio/releases/download/knative-v1.2.0/net-istio.yaml
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/istio# kubectl apply -f net-istio.yaml
root@k8s-master01:~# kubectl get pods -n knative-serving | grep istio
net-istio-controller-86b67bc8-g7ndq      1/1     Running   0          13m
net-istio-webhook-65fb676674-qs2qh       1/1     Running   0          13m


7. 配置DNS，略
1. 可使用DNS server进行泛解析配置
2. 可使用/etc/hosts进行测试
3. 可使用curl -H 'Host: abc.test.com' http://192.168.10.1


8. 安装扩展HPA autoscaling
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.2.0/serving-hpa.yaml
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/serving-extensions# kubectl apply -f serving-hpa.yaml

9. 安装kn CLI
文档：https://knative.dev/docs/install/client/install-kn/
下载：https://github.com/knative/client/releases/download/knative-v1.2.0/kn-linux-amd64
root@front-envoy:~# curl -OL https://github.com/knative/client/releases/download/knative-v1.2.0/kn-linux-amd64
root@front-envoy:~# scp kn-linux-amd64 root@172.168.2.21:/usr/local/bin/
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2# mv /usr/local/bin/kn-linux-amd64 /usr/local/bin/kn
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2# chmod +x /usr/local/bin/kn
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2# kn version
Version:      v1.2.0
Build Date:   2022-01-26 03:13:06
Git Revision: 5030b5df
Supported APIs:
* Serving
  - serving.knative.dev/v1 (knative-serving v0.29.0)
* Eventing
  - sources.knative.dev/v1 (knative-eventing v0.29.0)
  - eventing.knative.dev/v1 (knative-eventing v0.29.0)



##serving及实践
client request -> ingress gateway(istio) -> k8s service -> 当后端pod为0时 -> Activator -> Autoscaler -> deployment -> create pod
														   当后端pod不为0时 -> pod(queue-proxy缓存请求队列) <- Autoscaler(pull数据看是否需要自动伸缩)
注：当istio未给特定名称空间注入istio-proxy时，则knative使用的是ingress gateway功能(实现南北向流量)，此时knative需要自己部署knative-local-gateway(实现东西向流量的代理)
注：如果istio启用了特定名称空间注入istio-proxy时则knative不需要自己部署knative-local-gateway，而使用istio的网格功能实现东西向流量的治理，此时每个pod将会有两个sidecar，1个istio-proxy，1个queue-proxy，此时顺序是这样的：request -> istio-proxy -> queue-proxy -> pod
注：出向流量不是经过queue-proxy的，istio-proxy可以不注入，queue-proxy是一定会注入的(使用knative的service运行的清单文件时)

#Queue Proxy
- Knative Serving 会为每个Pod注入一个称为Queue Proxy的容器
  - 为业务代码提供代理功能
    - Ingress GW接收到请求后，将其发往目标Pod实例上由Queue Proxy监听的8012端口
	- 而后，Queue Proxy再将请求转发给业务代码容器监听的端口
  - 报告实例上的多个有关客户端请求的关键指标为给AutoScaler
  - Pod健康状态检测(Kubernetes探针)
  - 为超出实例最大并发量的请求提供缓冲队列
  - Queue Proxy预留使用了如下几个端口
    - 8012：HTTP协议的代理端口
	- 8013：HTTP/2端口，用于代理gRPC
	- 8022：管理端口，如健康状态检测等
	- 8090：暴露给Autoscaler进行指标采集的端口
	- 9091：暴露给Prometheus进行监控指标采集的端口
	
1. #运行Knative应用
- 在Serving上，可通过创建Knative Service对象来运行应用；该Service资源会自动创建
  - 一个Configuration对象，它会创建一个Revision，并由该Revision自动创建如下两个对象
    - 一个Deployment对象
	- 一个PodAutoscaler对象
  - 一个Route对象，它会创建
    - 一个Kubernetes Service对象
	- 一个Istio VirtualService对象
	  - {kservice-name}-ingress (南北向流量)
	  - {kservice-name}-mesh (当istio未启用网格，此对象将不起作用，从而使用的是knative-local-gateway)
- Knative Service资源（简称kservice或ksvc）的资源规范主要有两个字段
  - template：用于创建或更新Configuration，任何更新，都将创建新的Revision对象，里面的metadata定义中name建议不要定义，因为有特殊格式{kservice-name}-{revision-name}，并且每次应用不能重名
  - traffic：用于创建或更新Route对象

root@k8s-master01:~/knative-in-practise/serving/basic# cat hello-world.yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: hello
spec:
  template:
    metadata:
      # This is the name of our new "Revision," it must follow the convention {service-name}-{revision-name}
      name: hello-world
    spec:
      containers:
        #- image: gcr.io/knative-samples/helloworld-go
        - image: ikubernetes/helloworld-go
          ports:
            - containerPort: 8080
          env:
            - name: TARGET
              value: "World"
root@k8s-master01:~/knative-in-practise/serving/basic# kubectl apply -f hello-world.yaml
root@k8s-master01:~/knative-in-practise/serving/basic# kubectl get all
NAME                                          READY   STATUS        RESTARTS      AGE
pod/client                                    1/1     Running       1 (57m ago)   68m
pod/hello-world-deployment-5777cff46c-pzc2m   2/2     Terminating   0             82s	#有两个容器，一个queue-proxy被自动注入sidecar，是由knative service webhook完成的，因为没有流量，所以pod将被收缩至0

NAME                          TYPE           CLUSTER-IP      EXTERNAL-IP                                            PORT(S)                                      AGE
service/hello                 ExternalName   <none>          knative-local-gateway.istio-system.svc.cluster.local   80/TCP                                       78s
service/hello-world           ClusterIP      10.68.237.140   <none>                                                 80/TCP                                       83s
service/hello-world-private   ClusterIP      10.68.104.190   <none>                                                 80/TCP,9090/TCP,9091/TCP,8022/TCP,8012/TCP   83s
service/kubernetes            ClusterIP      10.68.0.1       <none>                                                 443/TCP                                      4h57m

NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hello-world-deployment   0/0     0            0           83s	#此时无流量，pod已经收缩为0了

NAME                                                DESIRED   CURRENT   READY   AGE
replicaset.apps/hello-world-deployment-5777cff46c   0         0         0       83s

NAME                                      LATESTCREATED   LATESTREADY   READY   REASON
configuration.serving.knative.dev/hello   hello-world     hello-world   True

NAME                                URL                                LATESTCREATED   LATESTREADY   READY   REASON
service.serving.knative.dev/hello   http://hello.default.example.com   hello-world     hello-world   True

NAME                              URL                                READY   REASON
route.serving.knative.dev/hello   http://hello.default.example.com   True

NAME                                       CONFIG NAME   K8S SERVICE NAME   GENERATION   READY   REASON   ACTUAL REPLICAS   DESIRED REPLICAS
revision.serving.knative.dev/hello-world   hello                            1            True             0                 0

root@k8s-master01:~/knative-in-practise/serving/basic# kubectl get ksvc
NAME    URL                                LATESTCREATED   LATESTREADY   READY   REASON
hello   http://hello.default.example.com   hello-world     hello-world   True

root@k8s-master01:~/knative-in-practise/serving/basic# kubectl get kpa
NAME          DESIREDSCALE   ACTUALSCALE   READY   REASON
hello-world   0              0             False   NoTraffic	#此时无流量，kpa已经收缩为0了

root@k8s-master01:~/knative-in-practise/serving/basic# kubectl get pods -n knative-serving
NAME                                     READY   STATUS    RESTARTS   AGE
webhook-97c648588-mhtzs                  1/1     Running   0          5h34m		#拦截注入queue-proxy，这是其中之一的功能

2. 更改ingress-gateway loadBalancer地址
root@k8s-master01:~/knative-in-practise/serving/basic# kubectl edit svc istio-ingressgateway -n istio-system
root@k8s-master01:~/knative-in-practise/serving/basic# kubectl get svc -n istio-system
NAME                    TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                                      AGE
istio-ingressgateway    LoadBalancer   10.68.44.78     172.168.2.27   15021:41258/TCP,80:34234/TCP,443:30652/TCP   55m
istiod                  ClusterIP      10.68.29.130    <none>         15010/TCP,15012/TCP,443/TCP,15014/TCP        55m
knative-local-gateway   ClusterIP      10.68.200.147   <none>         80/TCP                                       39m

3. 测试helloworld
--外部测试访问
root@k8s-master01:~/knative-in-practise/serving/basic# kubectl get routes
NAME    URL                                READY   REASON
hello   http://hello.default.example.com   True
root@k8s-master01:~/knative-in-practise/serving/basic# kubectl get pods
NAME     READY   STATUS    RESTARTS      AGE
client   1/1     Running   1 (62m ago)   74m
root@k8s-master01:~/knative-in-practise/serving/basic# curl -H 'Host: hello.default.example.com' 172.168.2.27	#第一次会有延迟，因为后端pod为0，所以去找activator -> Autoscaler来伸缩pod
Hello World!
root@k8s-master01:~/knative-in-practise/serving/basic# curl -H 'Host: hello.default.example.com' 172.168.2.27	#第二次就快了，因为后端有pod了
Hello World!
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/serving# kubectl get pods
NAME                                      READY   STATUS    RESTARTS      AGE
client                                    1/1     Running   1 (62m ago)   74m
hello-world-deployment-5777cff46c-p8fx2   2/2     Running   0             5s		#此时被Autoscaler激活，后续Autoscaler默认会隔2秒去抓取每个queue-proxy数据，来判定是否伸缩pod
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/serving# kubectl get pods		#过了一会，没有流量后，又缩至0个了
NAME     READY   STATUS    RESTARTS      AGE
client   1/1     Running   1 (65m ago)   77m
--内部测试访问
root@client # curl hello.default
Hello World!
root@k8s-master01:~/knative-in-practise/serving/basic# kubectl get pods
NAME                                      READY   STATUS    RESTARTS      AGE
client                                    1/1     Running   1 (82m ago)   93m
hello-world-deployment-5777cff46c-wrcrz   2/2     Running   0             5s	#都测试通过

4. 无流量时pod请求发送至activator
root@k8s-master01:~/knative-in-practise/serving/basic# kubectl get svc
NAME                  TYPE           CLUSTER-IP      EXTERNAL-IP                                            PORT(S)                                      AGE
hello                 ExternalName   <none>          knative-local-gateway.istio-system.svc.cluster.local   80/TCP                                       41m
hello-world           ClusterIP      10.68.237.140   <none>                                                 80/TCP                                       41m
hello-world-private   ClusterIP      10.68.104.190   <none>                                                 80/TCP,9090/TCP,9091/TCP,8022/TCP,8012/TCP   41m
kubernetes            ClusterIP      10.68.0.1       <none>                                                 443/TCP                                      5h37m
root@k8s-master01:~/knative-in-practise/serving/basic# kubectl describe svc hello-world | grep Endpoint
Endpoints:         172.20.58.200:8012
root@k8s-master01:~/knative-in-practise/serving/basic# kubectl get pods -o wide -n knative-serving | grep activator
activator-5c86d65d96-ht5dc               1/1     Running   0          98m   172.20.58.200   172.168.2.25   <none>   #当无流量时，请求会发送至activator
注：访问流程
- 内部访问：client -> 访问hello svc -> hello svc 通过ExternalName别名指向另外一个svc: knative-local-gateway.istio-system.svc.cluster.local -> 访问svc knative-local-gateway.istio-system的80端口会被调度到istio-system中名为istio-ingressgateway的任意一个pod的8081端口 -> 此时流量被先前创建的istio gateway对象knative-serving/knative-local-gateway规则匹配到 -> 此时有VirtualService引用了此gateway,对于hosts是hello.default并且gateways是knative-serving/knative-local-gateway的流量将会被路由到hello-world.default.svc.cluster.local的80端口
-- 外部访问：client -> 访问http://hello.default.example.com -> 此时流量被先前创建的istio gateway对象knative-serving/knative-ingress-gateway规则匹配到 -> 此时有VirtualService引用了此gateway,对于hosts是hello.default.example.com并且gateways是knative-serving/knative-ingress-gateway的流量将会被路由到hello-world.default.svc.cluster.local的80端口


5. 域名映射
- 实现外网域名映射至knative内部域名，将需要映射到外部的域名暴露出去，不需要的不暴露出去
- DomainMapping资源
  - DomainMapping的功能
    - 将外部域名映射至Knative Service或Knative Route
	- 支持跨Kubernetes Namespace对Knative Service进行名称映射
  - 创建Domainmapping
    - 命令式命令：kn domain create NAME --ref kroute:NAME|ksvc:NAME -n NAMESPACE
	- 声明多配置文件

5.1 查看ksvc和kroute
root@k8s-master01:~/knative-in-practise/serving/basic# kn service list
NAME    URL                                LATEST        AGE    CONDITIONS   READY   REASON
hello   http://hello.default.example.com   hello-world   100m   3 OK / 3     True
root@k8s-master01:~/knative-in-practise/serving/basic# kn route list
NAME    URL                                READY
hello   http://hello.default.example.com   True

5.2 创建domain
root@k8s-master01:~/knative-in-practise/serving/basic# kn domain create hello.magedu.com --ref ksvc:hello -n default
Domain mapping 'hello.magedu.com' created in namespace 'default'.

5.3 查看domain状态
root@k8s-master01:~/knative-in-practise/serving/domainmapping# kubectl get domainmapping
NAME               URL                       READY   REASON
hello.magedu.com   http://hello.magedu.com   True
root@k8s-master01:~/knative-in-practise/serving/basic# kn domain list
NAME               URL                       READY   KSVC
hello.magedu.com   http://hello.magedu.com   False   hello		#此时domain不正常
root@k8s-master01:~/knative-in-practise/serving/basic# kn domain describe hello.magedu.com	#查看详细信息
Name:       hello.magedu.com
Namespace:  default
Age:        38s

URL:  http://hello.magedu.com

Reference:
  APIVersion:  serving.knative.dev/v1
  Kind:        Service
  Name:        hello

Conditions:
  OK TYPE                      AGE REASON
  !! Ready                     38s DomainAlreadyClaimed		#此时domain不正常，报此域名已经被分配使用，原因是需要配置CDC
  ?? CertificateProvisioned    38s
  !! DomainClaimed             38s DomainAlreadyClaimed
  ?? IngressReady              38s IngressNotConfigured		#报ingress没有配置，正常后自己会新建一个VirtualService
  ?? ReferenceResolved         38s

5.4 配置CDC（clusterdomainclaims）,标明创建的domain是被自己使用的，好让其它人知道此域名被引用，从而不会出现多人抢占一个域名的错误，也可以配置随着domain的创建而自动创建CDC
root@k8s-master01:~/knative-in-practise/serving/basic# kubectl api-resources | grep knative
metrics                                           autoscaling.internal.knative.dev/v1alpha1   true         Metric
podautoscalers                    kpa,pa          autoscaling.internal.knative.dev/v1alpha1   true         PodAutoscaler
images                            img             caching.internal.knative.dev/v1alpha1       true         Image
certificates                      kcert           networking.internal.knative.dev/v1alpha1    true         Certificate
clusterdomainclaims               cdc             networking.internal.knative.dev/v1alpha1    false        ClusterDomainClaim
ingresses                         kingress,king   networking.internal.knative.dev/v1alpha1    true         Ingress
serverlessservices                sks             networking.internal.knative.dev/v1alpha1    true         ServerlessService
configurations                    config,cfg      serving.knative.dev/v1                      true         Configuration
domainmappings                    dm              serving.knative.dev/v1beta1                 true         DomainMapping
revisions                         rev             serving.knative.dev/v1                      true         Revision
routes                            rt              serving.knative.dev/v1                      true         Route
services                          kservice,ksvc   serving.knative.dev/v1                      true         Service
root@k8s-master01:~/knative-in-practise/serving/domainmapping# cat cdc-hello.magedu.com.yaml
apiVersion: networking.internal.knative.dev/v1alpha1
kind: ClusterDomainClaim
metadata:
  name: hello.magedu.com	#声明的域名地址
spec:
  namespace: default		#域名所有的名称空间
root@k8s-master01:~/knative-in-practise/serving/domainmapping# kubectl apply -f cdc-hello.magedu.com.yaml
--经过大概1分钟左右，状态正常了
root@k8s-master01:~/knative-in-practise/serving/domainmapping# kn domain describe hello.magedu.com
Name:       hello.magedu.com
Namespace:  default
Age:        5m

URL:  http://hello.magedu.com

Reference:
  APIVersion:  serving.knative.dev/v1
  Kind:        Service
  Name:        hello

Conditions:
  OK TYPE                      AGE REASON
  ++ Ready                     16s
  ++ CertificateProvisioned    17s TLSNotEnabled
  ++ DomainClaimed             17s
  ++ IngressReady              16s
  ++ ReferenceResolved         17s
root@k8s-master01:~/knative-in-practise/serving/domainmapping# kn domain list
NAME               URL                       READY   KSVC
hello.magedu.com   http://hello.magedu.com   True    hello
--查看创建的VirtualService
root@k8s-master01:~/knative-in-practise/serving/domainmapping# kubectl get vs hello.magedu.com-ingress -o yaml
  - match:
    - authority:
        prefix: hello.magedu.com
      gateways:
      - knative-serving/knative-ingress-gateway
    retries: {}
    rewrite:
      authority: hello.default.svc.cluster.local	#重写后地址
    route:
    - destination:
        host: hello.default.svc.cluster.local		#路由到的目的地址，而后又会经过内部的ingress-local-gateway进行匹配发送到hello-world.default.svc.cluster.local
        port:
          number: 80
      headers:
        request:
          set:
            K-Original-Host: hello.magedu.com
      weight: 100


5.5 外部客户端进行访问
--需要将hello.magedu.com映射到172.168.2.27
$ curl -s hello.magedu.com	#测试成功
Hello World!

5.6 配置随着domain的创建而自动创建CDC
root@k8s-master01:~/knative-in-practise/serving/domainmapping# kubectl get cm -n knative-serving | grep network
config-network           1      3h54m
root@k8s-master01:~/knative-in-practise/serving/domainmapping# kubectl edit cm config-network -n knative-serving
apiVersion: v1
data:
  autocreate-cluster-domain-claims: "true"
  _example: |	#以下划线开头的都是注释
root@k8s-master01:~/knative-in-practise/serving/domainmapping# kn domain create hi.magedu.com --ref kroute:hello -n default
root@k8s-master01:~/knative-in-practise/serving/domainmapping# kn domain list
NAME               URL                       READY   KSVC
hello.magedu.com   http://hello.magedu.com   True    hello
hi.magedu.com      http://hi.magedu.com      True    hello		#正常了
root@k8s-master01:~/knative-in-practise/serving/domainmapping# kubectl get cdc
NAME               AGE
hello.magedu.com   74m
hi.magedu.com      18s		#自动创建出来了
$ curl -s hi.magedu.com
Hello World!



######Revision和流量管理
#Revision
root@k8s-master01:~/knative-in-practise/serving/basic# cat hello-world-002.yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: hello
spec:
  template:
    metadata:
      # This is the name of our new "Revision," it must follow the convention {service-name}-{revision-name}
      name: hello-world-002
    spec:
      containerConcurrency: 10
      containers:
        #- image: gcr.io/knative-samples/helloworld-go
        - image: ikubernetes/helloworld-go
          ports:
            - containerPort: 8080
          env:
            - name: TARGET
              value: "World-002"
root@k8s-master01:~/knative-in-practise/serving/basic# kubectl apply -f hello-world-002.yaml
root@k8s-master01:~/knative-in-practise/serving/basic# kn revision list
NAME              SERVICE   TRAFFIC   TAGS   GENERATION   AGE    CONDITIONS   READY   REASON
hello-world-002   hello     100%             2            38s    4 OK / 4     True	#100%被高度到最新的revision
hello-world       hello                      1            3h6m   3 OK / 4     True
root@client # curl hello.default
Hello World-002!
root@client # curl hello-world.default.svc.cluster.local	#创建的revision都可以被访问
Hello World!
root@client # curl hello-world-002.default.svc.cluster.local
Hello World-002!


###流量管理
#Configuration Target和流量逐步迁移
- Configuration Target
  - ConfigurationName也可以作为路由项中的流量目标，意味着相关的流量部分由该Configurate下最新就绪的Revision承载
  - 存在问题
    - 在新的Revision就绪之后，ConfigurationTarget上的所有流量会立即转移至该Revision
	- 这可能会导致QueueProxy或Activator的请求队列过长，以至于部分请求可能会被拒绝
  - 解决方式
    - 在KService或Route上使用"serving.knative.dev/rollout-duration"注解来指定流量迁移过程的时长，例如值为380s
	- 新的Revision上线后，它会先从Configuration Target迁出%1的流量
	- 随后再等分迁出余下的流量部分
	
----查看Kservice
root@k8s-master01:~/knative-in-practise/serving/basic# kn service list
NAME    URL                                LATEST            AGE     CONDITIONS   READY   REASON
hello   http://hello.default.example.com   hello-world-002   3h18m   3 OK / 3     True
root@k8s-master01:~/knative-in-practise/serving/basic# kubectl get vs
NAME                       GATEWAYS                                                                              HOSTS                                                                                                 AGE
hello-ingress              ["knative-serving/knative-ingress-gateway","knative-serving/knative-local-gateway"]   ["hello.default","hello.default.example.com","hello.default.svc","hello.default.svc.cluster.local"]   3h15m
hello-mesh                 ["mesh"]                                                                              ["hello.default","hello.default.svc","hello.default.svc.cluster.local"]                               3h15m
hello.magedu.com-ingress   ["knative-serving/knative-ingress-gateway"]                                           ["hello.magedu.com"]                                                                                  89m
hi.magedu.com-ingress      ["knative-serving/knative-ingress-gateway"]                                           ["hi.magedu.com"]                                                                                     15m
----删除Kservice,此时相关的configuration,revision,deployment,kpa,route,相关的vs都被删除(domainmpping不会删除)
root@k8s-master01:~/knative-in-practise/serving/basic# kn service delete hello
Service 'hello' successfully deleted in namespace 'default'.
root@k8s-master01:~/knative-in-practise/serving/basic# kubectl get vs
NAME                       GATEWAYS                                      HOSTS                  AGE
hello.magedu.com-ingress   ["knative-serving/knative-ingress-gateway"]   ["hello.magedu.com"]   94m
hi.magedu.com-ingress      ["knative-serving/knative-ingress-gateway"]   ["hi.magedu.com"]      20m

----命令行创建Kservice，使用apply或者create创建，可以使用apply或者update进行更新
root@k8s-master01:~/knative-in-practise/serving/basic# kn service apply hello --image=ikubernetes/helloworld-go --env TARGET=world -n default
root@k8s-master01:~/knative-in-practise/serving/basic# kubectl get all
NAME                                          READY   STATUS        RESTARTS        AGE
pod/client                                    1/1     Running       1 (4h22m ago)   4h33m
pod/hello-00001-deployment-6b7bccd559-l5hvh   2/2     Terminating   0               70s

NAME                          TYPE           CLUSTER-IP      EXTERNAL-IP                                            PORT(S)                                      AGE
service/hello                 ExternalName   <none>          knative-local-gateway.istio-system.svc.cluster.local   80/TCP                                       66s
service/hello-00001           ClusterIP      10.68.136.196   <none>                                                 80/TCP                                       70s
service/hello-00001-private   ClusterIP      10.68.47.40     <none>                                                 80/TCP,9090/TCP,9091/TCP,8022/TCP,8012/TCP   70s
service/kubernetes            ClusterIP      10.68.0.1       <none>                                                 443/TCP                                      8h

NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hello-00001-deployment   0/0     0            0           70s

NAME                                                DESIRED   CURRENT   READY   AGE
replicaset.apps/hello-00001-deployment-6b7bccd559   0         0         0       70s

NAME                                       CONFIG NAME   K8S SERVICE NAME   GENERATION   READY   REASON   ACTUAL REPLICAS   DESIRED REPLICAS
revision.serving.knative.dev/hello-00001   hello                            1            True             0                 0

NAME                              URL                                READY   REASON
route.serving.knative.dev/hello   http://hello.default.example.com   True

NAME                                URL                                LATESTCREATED   LATESTREADY   READY   REASON
service.serving.knative.dev/hello   http://hello.default.example.com   hello-00001     hello-00001   True

NAME                                      LATESTCREATED   LATESTREADY   READY   REASON
configuration.serving.knative.dev/hello   hello-00001     hello-00001   True

NAME                                                 URL                       READY   REASON
domainmapping.serving.knative.dev/hello.magedu.com   http://hello.magedu.com   True
domainmapping.serving.knative.dev/hi.magedu.com      http://hi.magedu.com      True
----访问测试
jack@jackli MINGW64 /c/Windows/System32/drivers/etc
$ curl -s hi.magedu.com
Hello world!
----更新kservice
root@k8s-master01:~/knative-in-practise/serving/basic# kn service apply hello --image=ikubernetes/helloworld-go --env TARGET=Knative	
root@k8s-master01:~/knative-in-practise/serving/basic# kn revision list
NAME          SERVICE   TRAFFIC   TAGS   GENERATION   AGE     CONDITIONS   READY   REASON
hello-00002   hello     100%             2            23s     4 OK / 4     True
hello-00001   hello                      1            4m16s   3 OK / 4     True
----访问测试
jack@jackli MINGW64 /c/Windows/System32/drivers/etc
$ curl -s hi.magedu.com
Hello Knative!

#实现金丝雀发布，更改route，通过更改清单文件实现
root@k8s-master01:~/knative-in-practise/serving/revision-and-route# cat 004-hello-CloudNative.yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: hello
spec:
  template:
    spec:
      containers:
        - image: ikubernetes/helloworld-go
          ports:
            - containerPort: 8080
          env:
            - name: TARGET
              value: "Cloud-Native"	#更改此值后会生成一个新的revision，hello-00003
  traffic:
  - latestRevision: true	#hello-00003默认不会接收流量
    percent: 0
    tag: staging
  - revisionName: hello-00002
    percent: 90
  - revisionName: hello-00001
    percent: 10
root@k8s-master01:~/knative-in-practise/serving/revision-and-route# kubectl apply -f 004-hello-CloudNative.yaml
root@k8s-master01:~/knative-in-practise/serving/revision-and-route# kn revision list
NAME          SERVICE   TRAFFIC   TAGS      GENERATION   AGE   CONDITIONS   READY   REASON
hello-00003   hello               staging   3            30s   4 OK / 4     True	#默认没有流量，可以基于staging-hello来实现流量到达hello-00003 Revision
hello-00002   hello     90%                 2            20m   3 OK / 4     True
hello-00001   hello     10%                 1            24m   3 OK / 4     True
--内部客户端测试
root@client # while true;do curl hello.default.svc.cluster.local;sleep 1;done
Hello Knative!
Hello Knative!
Hello Knative!
Hello Knative!
Hello Knative!
Hello Knative!
Hello Knative!
Hello Knative!
Hello Knative!
Hello Knative!
Hello world!
Hello Knative!
Hello Knative!
Hello Knative!
Hello Knative!
Hello world!
Hello Knative!
Hello Knative!
Hello Knative!
Hello Knative!
Hello Knative!

--访问tag为staging的版本
root@k8s-master01:~/knative-in-practise/serving/revision-and-route# kubectl get vs hello-mesh
NAME         GATEWAYS   HOSTS                                                                                                                                                                   AGE
hello-mesh   ["mesh"]   ["hello.default","hello.default.svc","hello.default.svc.cluster.local","staging-hello.default","staging-hello.default.svc","staging-hello.default.svc.cluster.local"]   28m		#内部访问的域名
root@client # while true;do curl staging-hello.default.svc.cluster.local;sleep 1;done	#只需在kservice前面加上tag就行了
Hello Cloud-Native!
Hello Cloud-Native!
Hello Cloud-Native!
Hello Cloud-Native!
Hello Cloud-Native!
Hello Cloud-Native!
Hello Cloud-Native!
Hello Cloud-Native!
Hello Cloud-Native!

root@k8s-master01:~/knative-in-practise/serving/revision-and-route# kn service update hello --traffic hello-00003=10 --traffic hello-00002=90 --traffic hello-00001
root@client # while true;do curl hello.default.svc.cluster.local;sleep 1;done	#流量情况
Hello world!
Hello Knative!
Hello Knative!
Hello Knative!
Hello Knative!
Hello Knative!
Hello Knative!
Hello Knative!
Hello Knative!
Hello Knative!
Hello Knative!
Hello Knative!
Hello Cloud-Native!
Hello Knative!
Hello Knative!
Hello Knative!
Hello Knative!
Hello Knative!
Hello Knative!
Hello Knative!
Hello Cloud-Native!
Hello Knative!
root@k8s-master01:~/knative-in-practise/serving/revision-and-route# kn service update hello --traffic @latest=50 --traffic hello-00002=50	#最新版本的revision
root@k8s-master01:~/knative-in-practise/serving/revision-and-route# kn revision list
NAME          SERVICE   TRAFFIC   TAGS      GENERATION   AGE   CONDITIONS   READY   REASON
hello-00003   hello     50%       staging   3            12m   4 OK / 4     True
hello-00002   hello     50%                 2            33m   4 OK / 4     True
hello-00001   hello                         1            37m   3 OK / 4     True
root@client # while true;do curl hello.default.svc.cluster.local;sleep 1;done	#流量情况
Hello Knative!
Hello Cloud-Native!
Hello Cloud-Native!
Hello Knative!
Hello Cloud-Native!
Hello Cloud-Native!
Hello Cloud-Native!
Hello Knative!
Hello Knative!
Hello Cloud-Native!
Hello Cloud-Native!
Hello Cloud-Native!
Hello Cloud-Native!
Hello Cloud-Native!
Hello Cloud-Native!
Hello Knative!
Hello Knative!
Hello Cloud-Native!
Hello Knative!
Hello Knative!
Hello Knative!
Hello Cloud-Native!
Hello Cloud-Native!
root@k8s-master01:~/knative-in-practise/serving/revision-and-route# kn service update hello --tag hello-00001=oldtest	#为特定revision打上标签
root@k8s-master01:~/knative-in-practise/serving/revision-and-route# kn revision list
NAME          SERVICE   TRAFFIC   TAGS      GENERATION   AGE   CONDITIONS   READY   REASON
hello-00003   hello     50%       staging   3            15m   4 OK / 4     True
hello-00002   hello     50%                 2            35m   4 OK / 4     True
hello-00001   hello               oldtest   1            39m   3 OK / 4     True
root@client # while true;do curl oldtest-hello.default.svc.cluster.local;sleep 1;done	#访问tag为oldtest进行流量测试
Hello world!
Hello world!



###自动扩缩容
Knative的自动缩放机制
- "请求驱动计算"是Serverless的核心特性
  - 缩容至0：即没有请求时，系统不会分配资源给KService
  - 从0开始扩容：由Activator缓存请求，并报告指标数据给AutoScaler
  - 按需扩容：AutoScaler根据Revision中各实例的QP报告的指标数据不断调整Revision中的实例数量
- Knative系统中，AutoScaler、Activator和Queue-Proxy三者协同管理应用规模与流量规模的匹配
  - Knative附带了开箱即用的AutoScaler，简称为KPA
  - 同时，Knative还支持使用Kubernetes HPA进行Deployment缩放
- AutoScaler在扩缩容功能实现上的基本假设
  - 用户不能仅因为服务实例收缩为0而收到错误响应(由activator负责响应)
  - 请求不能导致应用过载(假设pod最大数量足以支撑高并发访问)
  - 系统不能造成无谓的资源浪费(收缩为0)

#请求如何驱动计算？
- Knative的自动扩缩容机制依赖于两个前提
  - 为Pod实例配置支持的目标并发数（在给定的时间里可同时处理的请求数）
  - 应用实例支持的缩放边界
    - 最少实例数，0即表示支持缩容至0实例
	- 最大实例数
- AutoScaler的基本缩放逻辑
  - AutoScaler基于过去一段时间内（由stable window指定）统计的指标（metric）数据和单个实例的目标并发数（target)来计算目标实例数
  - 计算出的目标实例数将发送给相应Revision的Deployment执行缩放操作
  
#AutoScaler执行扩缩容的基本流程
- 目标Revision零实例
  - 初次请求由Ingress GW转发给Activator进行缓存，同时报告数据给Autoscaler，进而控制相应的Deployment来完成Pod实例扩展
  - Pod副本的状态Ready之后，Activator将缓存的请求转发至相应的Pod对象
  - 随后，存在Ready状态的Pod期间，Ingress GW会将后续的请求直接转给Pod，而不再转给Activator
- 目标Revision存在至少一个Ready状态的Pod
  - Autoscaler根据Revision中各Pod的Queue-Proxy容器持续报告指标数据持续计算Pod副本数
  - Deployment根据Autoscaler的计算结果进行实例数量调整
- Revision实例数不为0，但请求数持续为0
  - Autoscaler在Queue-Proxy持续一段时间报告指标为0之后，即为将其Pod数缩减为0
  - 随后，Ingress GW(不光指的是istio ingress-gateway，还有其它的ingress-gateway)会将收到的请求再次转发为Activator

#绽放窗口和Panic(恐慌)
- 负载变动频繁时，Knative可能会因为响应负载变动而导致频繁创建或销毁Pod实例
- 为避免服务规模"抖动"，AutoScaler支持两种扩缩容模式
  - Stable：根据稳定窗口期（stable window，默认为60秒）的请求平均数（平均并发数）及每个pod的目标并发数计算Pod数
  - Panic：短期内收到大量请求时，将启用Panic模式
    - 十分之一窗口期（6秒）的平均并发数>=2*单实例目标并发数
	- 进入Panic模式60秒后，系统会重新返回stable模式
	
#排除算法基础
- 排除系统的三个关键要素
  - 输入过程：顾客（即服务请求者）到来的方式
    - 定长输入：匀速到达
	- 随机（存在峰值 ）：通常符合某种分布模型，例如k阶Erlang分布等
  - 排除规则：排除的方式，即到达的顾客按何种方式接受服务
    - 损失制：顾客到达时所有服务台均被占用，则顾客自动消失
	- 等待制：顾客到达时所有服务台均被占用，则将顾客排队
	- 混合制：混合上述两种情形，等候区满载时到达的顾客自动消失，否则即进行等候区等待
  - 服务机构：服务提供者，例如服务器
    - 服务器的个数
	- 服务器之间的串并联结构
	- 服务于每位顾客所需要的时长，通常满足某种分布特征
- 排队系统的数量指标
  - 等待队长：排队等待的顾客数或请求数
  - 等待时长：顾客处于排除等待状态的时长
  - 服务时长：顾客在服务台接受服务过程所经历的时长
  - 逗留时长：等待时长+服务时长
  - 并发度：处于等待或接受服务状态的顾客数
  - 到达率：单位时间内到达的顾客数或请求数
  - 服务率：单位时间内可服务的顾客数或请求数
  - 利用率：服务器牌繁忙状态的时间比例
- 队列理论中的几个计算公式
  - 平均并发度=平均到达率*平均服务时长
  - 利用率=到达率/服务率

#Autoscaler计算pod数的基本逻辑
- 指标收集周期与决策周期
  - Autoscaler每2秒钟计算一次Revision上所需要Pod实例数量
  - Autoscaler每2秒钟从Revision的Pod实例（Queue-Proxy容器）上抓取一次指标数据，并将其（每秒的）平均值存储于单独的bucket中
    - 实例较少时，则从每个实例抓取指标
	- 实例较多时，则从实例的一个子集上抓取指标，因而计算出的Pod实例数量并非精准数值
- 决策过程
  - Autoscaler在Revision中检索就绪状态的Pod实例数量
    - 若就绪实例数量为0，则将其设定为1，即使用Activator作为实例处理请求
	- Autoscaler检查累积收集的可用指标
	  - 若不存在任何可用指标，则将所需要的Pod实例数设置为0
	  - 若存在累积的指标，则计算出窗口期内的平均并发请求数
	  - 根据平均并发请求数和每实例的并发目标值计算出所需要的Pod实例数
	    - 窗口期内每实例的平均并发请求数 = Bucket中的样本值之和 / Bucket数量
		- 每实例的目标并发请求数 = 单实例目标并发数 * 目标利用率
		- 期望的Pod数 = 窗口期内每实例的并发请求数 / 每实例目标并发请求数
	  - Panic的触发条件
	    - 期望的Pod数 / 现有的Pod数 >= 2
		- 60秒之后返回至Stable

#Knative支持的Autoscaler
- Knative支持基于KPA和HPA的自动缩放机制，但二者的功能略有不同
  - Knative Pod Autoscaler
    - Knative Serving的核心组件，且默认即为启用状态
	- 支持缩容至0
	- 不支持基于CPU的自动缩放机制
  - Kubernetes Horizontal Pod Autoscaler
    - Kubernetes系统上的组件
	- 不支持缩容至0
	- 支持基于CPU的自动绽放机制
- 另外，二者支持的指标也不尽相同

#配置要使用的Autosacler
- Autoscaler的功能设定方式
  - 全局配置：ConfigMap/config-autoscaler
  - 每Revision配置：Revision Annotations
- 配置要使用的Autoscler
  - 全局配置参数pod-autoscaler-class
    - 位于knative-serving名称空间下的ConfigMap资源config-autoscaler之中
  - 在特定的Revision上使用注解"autoscaling.knative.dev/class"
  - 这两种配置的可用取值相同，均支持如下两个值
    - kpa.autoscaling.knative.dev: 使用KPA，默认配置
	- hpa.autoscaling.knative.dev：使用HPA
- 可用的指标
  - KPA: concurrency和rpc
  - HPA: CPU, memory和custom
  
#Autoscaler的全局配置
- 全局配置参数定义在knative-serving名称空间中的configmap/auto-scaler之中
- 相关的参数
  - container-concurrency-target-default: 实例的目标并发数，即最大并发数，默认值为100
  - container-concurrency-target-percentage: 实例的目标利用率，默认为"0.7"
  - enable-scale-to-zero: 是否支持缩容至0，默认为true；仅KPA支持
  - max-scale-up-rate: 最大扩容速率，默认为1000
    - 当前可最大扩容数 = 最大扩容速率 * Ready状态的Pod数量
  - max-scale-down-rate: 最大缩容速率，默认为2
    - 当前可最大缩容数 = Ready状态的POd数量 / 最大缩容速率
  - panic-window-percentage: Panic窗口期时长相当于Stable窗口期时长的百分比，默认为10，即百分之十
  - panic-threshold-percentage: 因Pod数量偏差而触发Panic阈值百分比，默认为200，即2倍
  - scale-to-zero-grace-period: 缩容至0的宽限期，即等待最后一个Pod删除的最大时长，默认为30s
  - scale-to-zero-pod-retention-period: 决定缩容至0后，允许最后一个Pod处于活动状态的最小时长，默认为0s
  - stable-window: 稳定窗口期的时长，默认为60s
  - target-burst-capacity: 突发请求容量，默认为200
  - requests-per-second-target-default: 每秒并发（RPC）的默认值，默认为200；使用rps指标时生效
  
#配置支持缩容至0实例
- 配置支持Revision自动缩放至0实例的参数
  - enable-scale-to-zero
    - 不支持Revision级别的配置
  - scale-to-zero-grace-period
    - 不支持Revision级别的配置
  - scale-to-zero-pod-retention-period
    - Revision级别配置时，使用注解键"autoscaling.knative.dev/scale-to-zero-pod-retention-period"
root@k8s-master01:~/knative-in-practise/serving/autoscaling# cat autoscaling-scale-to-zero.yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: hello
  namespace: default
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/scale-to-zero-pod-retention-period: "1m5s"	#配置为当没有请求时，最后一个活动pod延迟65秒后再进行删除动作
    spec:
      containers:
        - image: ikubernetes/helloworld-go
          ports:
            - containerPort: 8080
          env:
            - name: TARGET
              value: "Knative Autoscaling Scale-to-Zero"
root@k8s-master01:~/knative-in-practise/serving/autoscaling# kubectl apply -f autoscaling-scale-to-zero.yaml
root@k8s-master01:~/knative-in-practise/serving/autoscaling# kn revision list
NAME          SERVICE   TRAFFIC   TAGS   GENERATION   AGE   CONDITIONS   READY     REASON
hello-00004   hello                      4            5s    0 OK / 4     Unknown   Deploying
hello-00003   hello     100%             3            14h   3 OK / 4     True
hello-00002   hello                      2            15h   3 OK / 4     True
hello-00001   hello                      1            15h   3 OK / 4     True
root@k8s-master01:~/knative-in-practise/serving/autoscaling# kubectl get pods
NAME                                      READY   STATUS    RESTARTS      AGE
client                                    1/1     Running   1 (19h ago)   19h
hello-00004-deployment-568c946b4c-9cxp9   2/2     Running   0             92s	#当没有请求时，会过65s后再删除pod

#配置实例并发数
- 单实例并发数相关的设定参数
  - 软限制：流量突发尖峰期允许超出
    - 全局默认配置参数：container-concurrency-target-default
	- Revision级的注解：autoscaling.knative.dev/target
  - 硬限制：不允许超出，达到上限的请求需进行缓冲(在QueueProxy上)
    - 全局默认配置参数：container-concurrency
	  - 位于config-default中
	Revision级的注解：containerConcurrency
  - Target目标利用率
    - 全局配置参数：container-concurrency-target-percentage
	- Revision级的注解：autoscaling.knative.dev/target-utilization-percentage

root@k8s-master01:~/knative-in-practise/serving/autoscaling# cat autoscaling-concurrency.yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: hello
  namespace: default
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/target-utilization-percentage: "60"	#实例的目标利用率大小，10 * 0.6 = 6，当并发达到6个后将执行扩容操作
        autoscaling.knative.dev/target: "10"	#实例的最大并发数
    spec:
      containers:
        - image: ikubernetes/helloworld-go
          ports:
            - containerPort: 8080
          env:
            - name: TARGET
              value: "Knative Autoscaling Concurrency"
root@k8s-master01:~/knative-in-practise/serving/autoscaling# kubectl apply -f autoscaling-concurrency.yaml
root@k8s-master01:~/knative-in-practise/serving/autoscaling# kn revision list
NAME          SERVICE   TRAFFIC   TAGS   GENERATION   AGE   CONDITIONS   READY   REASON
hello-00005   hello     100%             5            15s   4 OK / 4     True
hello-00004   hello                      4            17m   3 OK / 4     True
hello-00003   hello                      3            15h   3 OK / 4     True
hello-00002   hello                      2            15h   3 OK / 4     True
hello-00001   hello                      1            15h   3 OK / 4     True
root@k8s-master01:~/knative-in-practise/serving/autoscaling# kubectl get pods
NAME                                      READY   STATUS    RESTARTS      AGE
client                                    1/1     Running   1 (19h ago)   20h
hello-00005-deployment-6685b8bc6c-dw4ht   2/2     Running   0             7s
--安装压测工具，ubuntu系统之上
root@front-envoy:~# curl -OL https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64
root@front-envoy:~# mv hey_linux_amd64 hey
root@front-envoy:~# chmod +x hey 
root@front-envoy:~# mv hey /usr/local/bin/
root@front-envoy:~# hey -z 60s -c 20 -host "hello.magedu.com" 'http://172.168.2.27?sleep=100&prime=10000&bload=5' #在60s内并发请求数为20
root@k8s-master01:~/knative-in-practise/serving/autoscaling# kubectl get pods
NAME                                      READY   STATUS    RESTARTS      AGE
client                                    1/1     Running   1 (20h ago)   20h
hello-00005-deployment-6685b8bc6c-4plw7   2/2     Running   0             19s		#立马创建了4个pod，因为只要达到6个请求就创建1个，20/6=3.2=4个
hello-00005-deployment-6685b8bc6c-5drkm   2/2     Running   0             19s
hello-00005-deployment-6685b8bc6c-rtk75   2/2     Running   0             19s
hello-00005-deployment-6685b8bc6c-t4tnd   2/2     Running   0             20s

#配置Revision的扩缩容边界
root@k8s-master01:~/knative-in-practise/serving/autoscaling# kubectl get cm -n knative-serving | grep autoscaler
config-autoscaler        1      21h
- 相关的配置参数
  - 最小实例数
    - Revision级别的Annotation: autoscaling.knative.dev/min-scale
	  - 说明：KPA且支持缩容至0时，该参数的默认值为0；其它情况下，默认值为1
  - 最大实例数
    - 全局参数：max-scale
    - Revision级别的Annotation: autoscaling.knative.dev/max-scale
	  - 整数型取值，0表示无限制
  - 初始规模：创建Revision，需要立即初始创建的实例数，满足该条件后Revision才能Ready，默认值为1；
    - 全局参数：initial-scale和allow-zero-initial-scale
	- Revision级别的Annotation：autoscaling.knative.dev/initial-scale
	  - 说明: 其实际规模依然可以根据流量进行自动调整
  - 缩容延迟：时间窗口，在应用缩容决策前，该时间窗口内并发请求必须处于递减状态，取值范围[0s,1h]
    - 全局参数：scale-down-delay
	- Revision级别的Annotation: autoscaling.knative.dev/scale-down-delay
  - Stable窗口期：取值范围[6s,1h]
    - 全局参数：stable-window
	- Revision级别的Annotation：autoscaling.knative.dev/window
root@k8s-master01:~/knative-in-practise/serving/autoscaling# cat autoscaling-scale-bounds.yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: hello
  namespace: default
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/target-utilization-percentage: "60"	#10*0.6=6，当并发请求每到达6个将创建一个新的pod
        autoscaling.knative.dev/target: "10"		#每个pod处理最大并发请求数为10
        autoscaling.knative.dev/max-scale: "3"		#最大pod为3个
        autoscaling.knative.dev/initial-scale: "1"	#初始pod为1个
        autoscaling.knative.dev/scale-down-delay: "1m"	#删除pod时延迟时间为60s
        autoscaling.knative.dev/stable-window: "60s"	#稳定窗口时间为60s
    spec:
      containers:
        - image: ikubernetes/helloworld-go
          ports:
            - containerPort: 8080
          env:
            - name: TARGET
              value: "Knative Autoscaling Scale Bounds"
root@k8s-master01:~/knative-in-practise/serving/autoscaling# kubectl apply -f autoscaling-scale-bounds.yaml
root@k8s-master01:~/knative-in-practise/serving/autoscaling# kn revision list
NAME          SERVICE   TRAFFIC   TAGS   GENERATION   AGE   CONDITIONS   READY   REASON
hello-00006   hello     100%             6            12s   4 OK / 4     True
hello-00005   hello                      5            57m   3 OK / 4     True
hello-00004   hello                      4            74m   3 OK / 4     True
hello-00003   hello                      3            16h   3 OK / 4     True
hello-00002   hello                      2            16h   3 OK / 4     True
hello-00001   hello                      1            16h   3 OK / 4     True
--测试
root@front-envoy:~# hey -z 60s -c 50 -host "hello.magedu.com" 'http://172.168.2.27?sleep=100&prime=10000&bload=5'
root@k8s-master01:~/knative-in-practise/serving/autoscaling# kubectl get pods
NAME                                      READY   STATUS    RESTARTS      AGE
client                                    1/1     Running   1 (20h ago)   21h
hello-00006-deployment-65d665cf49-blt5q   2/2     Running   0             12s
hello-00006-deployment-65d665cf49-ftfjz   2/2     Running   0             13s
hello-00006-deployment-65d665cf49-hxch6   2/2     Running   0             12s
root@k8s-master01:~/knative-in-practise/serving/autoscaling# kubectl get pods
NAME                                      READY   STATUS    RESTARTS      AGE
client                                    1/1     Running   1 (20h ago)   21h
hello-00006-deployment-65d665cf49-blt5q   2/2     Running   0             22s	#因为限制最大pod为3，所以再多请求也只有3个pod
hello-00006-deployment-65d665cf49-ftfjz   2/2     Running   0             23s
hello-00006-deployment-65d665cf49-hxch6   2/2     Running   0             22s

#使用rps指标，rps是请求率,concurrency是到达率，显示rps比concurrency更具有敏感性
- 相关的配置参数
  - 定义使用rps指标
    - Revision级别的Annotation：autoscaling.knative.dev/metric
	  - 取值为rps
  - 为rps指标指定目标请求数
    - 全局参数：requests-per-second-target-default
	- Revision级别的Annotation：autoscaling.knative.dev/target
	  - 整数取值，默认值为200
root@k8s-master01:~/knative-in-practise/serving/autoscaling# cat autoscaling-metrics-and-targets.yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: hello
  namespace: default
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/target-utilization-percentage: "60"	#pod使用率为0.6
        autoscaling.knative.dev/metric: "rps"	#使用rps指标
        autoscaling.knative.dev/target: "100"	#pod最大请求数
        autoscaling.knative.dev/max-scale: "10"		#最多10个pod活动
        autoscaling.knative.dev/initial-scale: "1"	#最少1个pod活动，当没有请求时，会使用activator
        autoscaling.knative.dev/stable-window: "2m"	#稳定窗口时间为120s，panic(恐慌)窗口为10%=12s
    spec:
      containers:
        - image: ikubernetes/helloworld-go
          ports:
            - containerPort: 8080
          env:
            - name: TARGET
              value: "Knative Autoscaling Metrics and Targets"
root@k8s-master01:~/knative-in-practise/serving/autoscaling# kubectl apply -f autoscaling-metrics-and-targets.yaml
--测试
root@front-envoy:~# hey -z 60s -c 60 -host "hello.magedu.com" 'http://172.168.2.27?sleep=100&prime=10000&bload=5'
root@k8s-master01:~/knative-in-practise/serving/autoscaling# kubectl get pods
NAME                                      READY   STATUS    RESTARTS      AGE
client                                    1/1     Running   1 (21h ago)   21h
hello-00007-deployment-5766976c8d-c7pr6   2/2     Running   0             61s
hello-00007-deployment-5766976c8d-ck4pg   2/2     Running   0             62s
hello-00007-deployment-5766976c8d-j9jx4   2/2     Running   0             63s
hello-00007-deployment-5766976c8d-lqpzq   2/2     Running   0             70s
hello-00007-deployment-5766976c8d-nzm22   2/2     Running   0             63s
hello-00007-deployment-5766976c8d-tccmd   2/2     Running   0             33s


###Knative Eventing
#CloudEvents 概念
- CloudEvents规范最初由CNCF旗下的Serverless Working group创建，但自v0.1之后，该规范即被提升为一个独立CNCF沙箱项目
  - 常用于分布式系统环境，帮助用户构建松散耦合且可独立部署的分布式系统
  - 为行业订立一个规范以提升互操作性
- CloudEvents中的事件
  - 事件包括某个实际情景（occurrence）的上下文和数据，以及一个惟一标识；
  - 事件通常用于后端代码中，负责连接不同的代码块（子系统），其中一个代码块的状态变动会触发另一个代码块的运行
  - 其中，事件源（source）生成的事件（Event）被封装在协议中生成传输单元（message）以方便传输；事件到达目的端后，将触发基于事件数据的动作（action）
    - 传输协议：支持行业的各种标准协议（如HTTP、AMQP、MQTT和SMTP等）、开源协议（如Kafka和NATS），以及平台/供应商的特有协议；
	- 动作通常是由特定来源的特定事件触发，是专门负责处理该类事件代码块，这些代码块可运行于Serverless Function逻辑中；

#CloudEvents 中的序列化规范
- CloudEvents还提供了如何以不同格式（如JSON）和协议（如HTTP、AMQP和Kafka）等将事件进行序列化的规范
  - HTTP消息映射（方式一）
    - Content-Type标头：负责代表CloudEvents中的datacontenttype属性
	- 报文的Body部分代表CloudEvents中Data属性中的事件数据
	- CloudEvents中的其它属性字段，必须各自映射为报文中标头，例如id要定义为“ce-id”标头；
  - HTTP消息映射（方式二）
    - Content-Type标头：使用application/cloudevents
	- 其它部分以json格式的body数据提供
- 另外，CloudEvents还定义了一组Adapter规范，以便于帮助用户构建Adapter，从而将那些非CloudEvents规范的事件转为CloudEvents格式；


###Eventing及实践
#Knative Eventing的相关组件
- Knative Eventing具有四个最基本的组件：Sources、Brokers、Triggers 和 Sinks
  - 事件会从Source发送至Sink
  - Sink是能够接收传入的事件可寻址（Addressable）或可调用（Callable）资源
    - Knative Service、Channel和Broker都可用作Sink
- Knative Eventing的关键术语
  - Event Source
    - Knative Eventing中的事件源主要就是指事件的生产者
    - 事件将被发往Sink或Subscriber
  - Channel和Subscription
    - 事件管道模型，负责在Channel及其各Subscription之间格式化和路由事件
  - Broker和Trigger
    - 事件网格（mesh）模型，Producer把事件发往Broker，再由Broker统一经Trigger发往各Consumer
    - 各Consumer利用Trigger向Broker订阅其感兴趣的事件
  - Event Registry
    - Knative Eventing使用EventType来帮助Consumer从Broker上发现其能够消费的事件类型
    - Event Registry即为存储着EventType的集合，这些EventType含有Consumer创建Trigger的所有必要信息

#Event 处理示意图
- Event Source：事件源，即生产者抽象，负责从真正的事件源导入事件至Eventing拓扑中
- Event Type：事件类型，它们定义于Event Registry中
- Flow：事件处理流，可简单地手工定义流，也可使用专用的API进行定义
- Event Sinks：能接收Event的可寻址（Addressable）或可调用（Callable）资源，例如KService等

#Knative的事件传递模式
- Knative Eventing中的Sink（接收事件）的用例主要有Knative Service、Channels和Brokers三种
- Knative Eventing支持的事件传递模式
  - Sources to Sink
    - 单一Sink模式，事件接收过程中不存在排队和过滤等操作
    - Event Source的职责仅是传递消息，且无需等待Sink响应
    - fire and forget
  - Channels and Subscriptions
    - Event Source将事件发往Channel
    - Channel可以有一到多个Subscription（即Sink）
    - Channel中的每个事件都被格式化Cloud Event并发送至各Subscription
    - 不支持消息过滤机制
  - Brokers and Triggers
    - 功能类似于Channel和Subscription模式，但支持消息过滤机制
    - 事件过滤机制允许Subscription使用基于事件属性的条件表达式（Trigger）筛选感兴趣的事件
    - Trigger负责订阅Broker，并对Broker上的消息进行过滤
    - Trigger将消息传递给感兴趣的Subscription之前，还需要负责完成消息的格式化
    - 这是在生产中推荐使用的消息投递模式


#部署Eventing
部署文档：https://knative.dev/docs/install/yaml-install/eventing/install-eventing-with-yaml/
----eventing-crds
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.2.2/eventing-crds.yaml
----eventing-core
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.2.2/eventing-core.yaml
----Channel (messaging) layer
--In-Memory (standalone)，此消息不对持久，当做测试，不能用于生产，生产应使用Apache Kafka Channel
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.2.2/in-memory-channel.yaml
----Broker layer，生产也使用MT-Channel-based，Openshift说Apache Kafka Broker不保证生产稳定
--MT-Channel-based
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.2.2/mt-channel-broker.yaml
1. 安装eventing-crds
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/eventing# kubectl apply -f eventing-crds.yaml
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/eventing# kubectl api-resources | grep knative
parallels                                         flows.knative.dev/v1                        true         Parallel
sequences                                         flows.knative.dev/v1                        true         Sequence
channels                          ch              messaging.knative.dev/v1                    true         Channel
subscriptions                     sub             messaging.knative.dev/v1                    true         Subscription
apiserversources                                  sources.knative.dev/v1                      true         ApiServerSource
containersources                                  sources.knative.dev/v1                      true         ContainerSource
pingsources                                       sources.knative.dev/v1                      true         PingSource
sinkbindings                                      sources.knative.dev/v1                      true         SinkBinding

2. 安装eventing-core
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/eventing# kubectl apply -f eventing-core.yaml
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/eventing# kubectl get ns | grep knative
knative-eventing   Active   15s
knative-serving    Active   28h
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/eventing# kubectl get all -n knative-eventing
NAME                                       READY   STATUS    RESTARTS   AGE
pod/eventing-controller-5657cc89f6-bfbr5   1/1     Running   0          8m11s	#控制器，用于支持eventing的功能的
pod/eventing-webhook-6f4d7fd9d8-zxm5v      1/1     Running   0          8m11s	#eventing的admission controller(准入控制 器),为检查eventing资源和填充未定义字段的

NAME                       TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/eventing-webhook   ClusterIP   10.68.46.76   <none>        443/TCP   8m11s

NAME                                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/eventing-controller     1/1     1            1           8m11s
deployment.apps/eventing-webhook        1/1     1            1           8m11s
deployment.apps/pingsource-mt-adapter   0/0     0            0           8m11s

NAME                                              DESIRED   CURRENT   READY   AGE
replicaset.apps/eventing-controller-5657cc89f6    1         1         1       8m11s
replicaset.apps/eventing-webhook-6f4d7fd9d8       1         1         1       8m11s
replicaset.apps/pingsource-mt-adapter-ffcbfcbd7   0         0         0       8m11s

NAME                                                   REFERENCE                     TARGETS          MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/eventing-webhook   Deployment/eventing-webhook   <unknown>/100%   1         5         1          8m11s

3. 安装In-Memory channel
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/eventing# kubectl apply -f in-memory-channel.yaml
root@k8s-master01:~/knative-in-practise/serving/autoscaling# kubectl get pods -n knative-eventing
NAME                                   READY   STATUS    RESTARTS   AGE
eventing-controller-5657cc89f6-bfbr5   1/1     Running   0          23m
eventing-webhook-6f4d7fd9d8-zxm5v      1/1     Running   0          23m
imc-controller-7764b644d7-wvv64        1/1     Running   0          13m		#In-Memory控制器
imc-dispatcher-c54db58c9-vjwgz         1/1     Running   0          13m		#In-Memory分发器

4. 安装MT-Channel-based broker
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/eventing# kubectl apply -f mt-channel-broker.yaml
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/eventing# kubectl get pods -n knative-eventing | grep broker
mt-broker-controller-58dfb6556c-dttmq   1/1     Running   0          18m	#控制器，确保broker CRD能实现的
mt-broker-filter-57dfcdf887-vr7tz       1/1     Running   0          18m	#过滤器，trigger触发器
mt-broker-ingress-9df77f754-fn268       1/1     Running   0          18m	#入口，可寻址的，接事件过来的

#Eventing的逻辑组件
- Eventing API群组及相应的CRD
  - sources.knative.dev # 声明式配置Event Source的API，提供了四个开箱即用的Source；
    - ApiServerSource：监听Kubernetes API事件
    - ContainerSource：在特定的容器中发出针对Sink的事件
    - PingSource：以周期性任务（cron）的方式生具有固定负载的事件
    - SinkBinding：链接任何可寻址的Kubernetes资源，以接收来自可能产生事件的任何其他Kubernetes资源的事件
  - eventing.knative.dev # 声明式配置“事件网格模型”的API
    - Broker
    - EventType
    - Trigger
  - messaging.knative.dev # 声明式配置“事件管道模型”的API
    - Channel
    - Subscription
  - flows.knative.dev # 事件流模型，即事件是以并行还是串行的被多个函数处理
    - Parallel	#并行
    - Sequence	#串行

#CloudEvents示例
- 最为简单的Event发送示例
  - Source：curl命令，基于HTTP消息映射规范手动编制消息及事件内容
  - Sink：基于能够接收、解析事件，并将其存入日志的event_display应用为例来模拟事件处理
    - event_display可运行为Kubernetes Service，或者Knative Service
- 步骤
  - 将event_display运行为KService，并为其创建外部域名映射（非必须，使用的话还依赖外部名称解析服务）
    - kn service create event-display --image ikubernetes/event_display --port 8080 --scale-min 1
    - kn domain create event.magedu.com --ref "ksvc:event-display"
  - 发起请求测试，并通过event_display验证日志中的事件
# 使用如下命令发起请求测试
~$ curl -v "http://event.magedu.com/" \
-X POST \
-H "Ce-Id: say-hello" \
-H "Ce-Specversion: 1.0" \
-H "Ce-Type: com.magedu.sayhievent" \
-H "Ce-Time: 2022-02-17T11:35:56.7181741Z" \
-H "Ce-Source: sendoff" \
-H "Content-Type: application/json" \
-d '{"msg":"Hello MageEdu Knative!"}
# 获取event-display中的日志信息，验证是否进行了事件发送
~$ EVENT_POD=$(kubectl get pods -l serving.knative.dev/service=event-display -o jsonpath={.items[0].metadata.name})
~$ kubectl logs $EVENT_POD -c user-container 
☁️ cloudevents.Event
Context Attributes,
specversion: 1.0
type: com.magedu.sayhievent
source: sendoff
id: say-hello
time: 2022-02-17T11:20:56.7181741Z
datacontenttype: application/json
Data,
{
"msg": "Hello MageEdu Knative!"
}
#自定义curl source
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/eventing# kn service create event-display --image ikubernetes/event_display --port 8080 --scale-min 1	#最上pod为1个，不会收缩为0
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/eventing# kubectl get pods
NAME                                              READY   STATUS    RESTARTS      AGE
client                                            1/1     Running   1 (29h ago)   29h
event-display-00001-deployment-775b6f6749-nsc7x   2/2     Running   0             61s
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/eventing# kn route list
NAME            URL                                        READY
event-display   http://event-display.default.example.com   True
hello           http://hello.default.example.com           True
root@k8s-master01:~/knative-in-practise/knative-deploy-v1.2/eventing# kubectl get vs | grep event-display
event-display-ingress      ["knative-serving/knative-ingress-gateway","knative-serving/knative-local-gateway"]   ["event-display.default","event-display.default.example.com","event-display.default.svc","event-display.default.svc.cluster.local"]   72s
event-display-mesh         ["mesh"]                                                                              ["event-display.default","event-display.default.svc","event-display.default.svc.cluster.local"]                                       72s
```
curl -v "http://event-display.default.svc.cluster.local/" \
-X POST \
-H "Ce-Id: 00001" \
-H "Ce-Specversion: 1.0" \
-H "Ce-Type: com.magedu.file.image" \
-H "Ce-Source: curl" \
-H "Content-Type: application/json" \
-d '{"msg":"Hello MageEdu Knative!"}'
```
root@client # curl -v "http://event-display.default.svc.cluster.local/" \	#测试pod请求命令
> -X POST \
> -H "Ce-Id: 00001" \
> -H "Ce-Specversion: 1.0" \
> -H "Ce-Type: com.magedu.file.image" \
> -H "Ce-Source: curl" \
> -H "Content-Type: application/json" \
> -d '{"msg":"Hello MageEdu Knative!"}'
Note: Unnecessary use of -X or --request, POST is already inferred.
*   Trying 10.68.200.147:80...
* TCP_NODELAY set
* Connected to event-display.default.svc.cluster.local (10.68.200.147) port 80 (#0)
> POST / HTTP/1.1
> Host: event-display.default.svc.cluster.local
> User-Agent: curl/7.67.0
> Accept: */*
> Ce-Id: 00001
> Ce-Specversion: 1.0
> Ce-Type: com.magedu.file.image
> Ce-Source: curl
> Content-Type: application/json
> Content-Length: 32
>
* upload completely sent off: 32 out of 32 bytes
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< content-length: 0
< date: Mon, 09 May 2022 13:44:15 GMT
< x-envoy-upstream-service-time: 3
< server: istio-envoy
<
* Connection #0 to host event-display.default.svc.cluster.local left intact
--外部访问
root@k8s-master01:~# POD=$(kubectl get pods -l serving.knative.dev/configuration=event-display -o jsonpath={.items[0].metadata.name})
root@k8s-master01:~# echo $POD
event-display-00001-deployment-775b6f6749-nsc7x
root@k8s-master01:~# kubectl logs $POD -c user-container	#验证日志中的事件是否是使用curl发起的测试source
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: com.magedu.file.image
  source: curl
  id: 00001
  datacontenttype: application/json
Data,
  {
    "msg": "Hello MageEdu Knative!"
  }

#开箱即用PingSource(之前叫cronSource)
root@k8s-master01:~# kn source ping create pingsource01 --schedule "* * * * *" --data '{"message": "event from pingsource01"}' --sink ksvc:event-display:default	#每分钟执行一次pingsource,sink为之前新建的ksvc(sink就是接收者)
root@k8s-master01:~# kn source ping list
NAME           SCHEDULE    SINK                 AGE     CONDITIONS   READY   REASON
pingsource01   * * * * *   ksvc:event-display   2m18s   3 OK / 3     True
root@k8s-master01:~# kubectl get pingsources pingsource01 -o yaml > pingsource.yaml
root@k8s-master01:~# cat pingsource.yaml	#命令式清单创建
apiVersion: sources.knative.dev/v1
kind: PingSource
metadata:
  name: pingsource02
  namespace: default
spec:
  data: '{"message": "event from pingsource02"}'
  schedule: '* * * * *'
  sink:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: event-display
      namespace: default
root@k8s-master01:~# kubectl apply -f pingsource.yaml
root@k8s-master01:~# kn source ping list
NAME           SCHEDULE    SINK                 AGE    CONDITIONS   READY   REASON
pingsource01   * * * * *   ksvc:event-display   5m4s   3 OK / 3     True
pingsource02   * * * * *   ksvc:event-display   9s     3 OK / 3     True
root@k8s-master01:~# kubectl logs -f $POD -c user-container		#测试pingsource信息
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: dev.knative.sources.ping
  source: /apis/v1/namespaces/default/pingsources/pingsource01
  id: 4d25daaf-1e0e-40d7-a96f-afdac45afe1a
  time: 2022-05-09T14:07:00.31915484Z
Data,
  {"message": "event from pingsource01"}
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: dev.knative.sources.ping
  source: /apis/v1/namespaces/default/pingsources/pingsource02
  id: 3538dd8b-f93b-4e73-a4b1-b337a3cbef0a
  time: 2022-05-09T14:07:00.427599091Z
Data,
  {"message": "event from pingsource02"}
root@k8s-master01:~# kubectl delete pingsources pingsource0{1,2}	#删除pingsource
pingsource.sources.knative.dev "pingsource01" deleted
pingsource.sources.knative.dev "pingsource02" deleted
#- PingSource → Kubernetes Service Sink
#- PingSource → Knative Service Sink


#---获取event-display中的日志信息，验证是否进行了事件发送
~$ POD=$(kubectl get pods -l serving.knative.dev/service=event-display -n event-demo -o jsonpath={.items[0].metadata.name})
~$ kubectl logs $POD -c user-container -n event-demo
☁️ cloudevents.Event
Context Attributes,
specversion: 1.0
type: dev.knative.sources.ping
source: /apis/v1/namespaces/event-demo/pingsources/pingsource-00001
id: 56304c9e-61c8-407c-a43f-a42203fd98bf
time: 2022-02-18T09:09:00.027218425Z
datacontenttype: application/json
Data,
{
"message": "Hello Eventing!"
}


#@ContainerSource
---- ContainerSource → Knative Service Sink
root@k8s-master01:~/knative-in-practise/eventing/sources/03-containersource-to-knative-service# cat 03-containersource-to-event-display.yaml
apiVersion: sources.knative.dev/v1
kind: ContainerSource
metadata:
  name: containersource-heartbeat
spec:
  template:
    spec:
      containers:
        - image: ikubernetes/containersource-heartbeats:latest
          name: heartbeats
          env:
          - name: POD_NAME
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
          - name: POD_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
  sink:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: event-display
root@k8s-master01:~/knative-in-practise/eventing/sources/03-containersource-to-knative-service# kubectl apply -f 03-containersource-to-event-display.yaml
root@k8s-master01:~/knative-in-practise/eventing/sources/03-containersource-to-knative-service# kn source container list
NAME                        IMAGE                                           SINK                 AGE     CONDITIONS   READY   REASON
containersource-heartbeat   ikubernetes/containersource-heartbeats:latest   ksvc:event-display   4m26s   3 OK / 3     True
root@k8s-master01:~# kubectl logs -f $POD -c user-container	#测试事件
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: dev.knative.eventing.samples.heartbeat
  source: https://knative.dev/eventing-contrib/cmd/heartbeats/#default/containersource-heartbeat-deployment-56c7896d86-qd255	#生成的事件
  id: 78d11261-c080-437a-b602-6770b0bcfc7c
  time: 2022-05-09T14:27:11.377498709Z
  datacontenttype: application/json
Extensions,
  beats: true
  heart: yes
  the: 42
Data,
  {
    "id": 27,
    "label": ""
  }
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: dev.knative.eventing.samples.heartbeat
  source: https://knative.dev/eventing-contrib/cmd/heartbeats/#default/containersource-heartbeat-deployment-56c7896d86-qd255
  id: b9cdae50-178f-43c9-803c-3762858ad76c
  time: 2022-05-09T14:27:16.371666867Z
  datacontenttype: application/json
Extensions,
  beats: true
  heart: yes
  the: 42
Data,
  {
    "id": 28,
    "label": ""
  }
root@k8s-master01:~# kubectl get containersource
NAME                        SINK                                             AGE     READY   REASON
containersource-heartbeat   http://event-display.default.svc.cluster.local   6m11s   True
root@k8s-master01:~# kubectl delete containersource containersource-heartbeat

#ApiServerSource
---- ApiServerSource → Knative Service Sink
root@k8s-master01:~/knative-in-practise/eventing/sources/04-apiserversource-to-knative-service# cat 03-serviceaccount-and-rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pod-watcher
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
rules:
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pod-reader
subjects:
- kind: ServiceAccount
  name: pod-watcher
root@k8s-master01:~/knative-in-practise/eventing/sources/04-apiserversource-to-knative-service# kubectl apply -f 03-serviceaccount-and-rbac.yaml
root@k8s-master01:~/knative-in-practise/eventing/sources/04-apiserversource-to-knative-service# cat 04-ApiServerSource-to-knative-service.yaml
apiVersion: sources.knative.dev/v1
kind: ApiServerSource
metadata:
  name: pods-event
spec:
  serviceAccountName: pod-watcher
  mode: Reference
  resources:
  - apiVersion: v1
    kind: Pod		#针对pod资源进行事件获取
    #selector:
    #  matchLabels:
    #    app: demoapp
  sink:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: event-display
root@k8s-master01:~/knative-in-practise/eventing/sources/04-apiserversource-to-knative-service# kubectl apply -f 04-ApiServerSource-to-knative-service.yaml
root@k8s-master01:~# kubectl get pods
NAME                                                              READY   STATUS    RESTARTS      AGE
apiserversource-pods-event-36368d6c-f78f-4676-a9cb-6d40883fmggh   1/1     Running   0             6m3s
client                                                            1/1     Running   1 (30h ago)   30h
event-display-00001-deployment-775b6f6749-nsc7x                   2/2     Running   0             70m
----测试
root@k8s-master01:~# kubectl run client02 --image=ikubernetes/admin-box:v1.2 --rm -it --command -- /bin/sh	#运行客户端
If you don't see a command prompt, try pressing enter.
root@client02 # exit	#退出后就会删除
Session ended, resume using 'kubectl attach client02 -c client02 -i -t' command when the pod is running
pod "client02" deleted

root@k8s-master01:~# kubectl logs -f $POD -c user-container
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: dev.knative.apiserver.ref.update	#获取了pod创建的事件
  source: https://10.68.0.1:443
  subject: /apis/v1/namespaces/default/pods/client02
  id: 6eefa2ba-11f4-4db1-9dc5-8c2dcddc6d80
  time: 2022-05-09T14:43:32.878498878Z
  datacontenttype: application/json
Extensions,
  kind: Pod
  name: client02
  namespace: default
Data,
  {
    "kind": "Pod",
    "namespace": "default",
    "name": "client02",
    "apiVersion": "v1"
  }
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: dev.knative.apiserver.ref.delete	#获取了pod删除的事件
  source: https://10.68.0.1:443
  subject: /apis/v1/namespaces/default/pods/client02
  id: 91e3a099-ab3d-4b5f-9748-72baef2678dd
  time: 2022-05-09T14:43:32.892575032Z
  datacontenttype: application/json
Extensions,
  kind: Pod
  name: client02
  namespace: default
Data,
  {
    "kind": "Pod",
    "namespace": "default",
    "name": "client02",
    "apiVersion": "v1"
  }


##Gitlab Source
- 关于GitLabSource
  - 将GitLab仓库上的事件转换为CloudEvents
  - GitLabSource为指定的事件类型创建一个Webhook，监听传入的事件，并将其传递给消费者
- GitLabSource支持的事件类型包括如下这些
  - 推送事件：push_events
    - 对应的CloudEvents的类型为“dev.knative.sources.gitlab.push”，以下类同
  - tag推送事件：tag_push_events
  - 议题事件：issues_events
  - 合并请求事件：merge_requests_events
  - 私密议题事件：confidential_issues_events
  - 私密评论：confidential_note_events
  - 部署事件：deployment_events
  - 作业事件：job_events
  - 评论：note_events
  - 流水线事件：pipeline_events
  - Wiki页面事件：wiki_page_events

#GitLab Source 实践
- 示例环境说明
  - 一个部署可用的GitLab服务
  - GitLab服务上隶于某个用户（例如root）的代码仓库（例如myproject）
  - 负责接收CloudEvents的kservice/event-display
- 测试步骤
  - 部署GitLab
  - GitLab上的操作
    - 为GitLab用户设置Personal Access Token
    - 准备示例仓库myproject
  - 在Knative上部署GitLabSource
  - 在Knative上部署KService/event-display
  - 创建Secret资源，包含两个数据项
    - GitLab上的Personal Access Token
    - GitLab调用GitLabSource与Webhook Secret
  - 创建GitLabSource资源
    - 从GitLab仓库加载事件
    - 将事件转为CloudEvents，并发往Sink
	
#GitLab Source 实践2
- 部署GitLab，并完成如下几项管理设定
  - 通用→可见性：设定“自定义HTTP(S)协议Git克隆URL”，如http://code.gitlab.svc.cluster.local
  - 网络→外发请求(Outbound requests)：设定“Allow requests to the local network from web hooks and services”
  - 创建示例仓库，以myproject为例
- 建Personal Access Token（简单起见，直接以root为例）
  - 个人设定 → 偏好设置 → 访问令牌（必须是api scope）(api权限包含下面的权限){名称：root-access-token, TOKEN: U5cj8X-Jobqn-T-WVYyd}
  - 注：生成的令牌信息仅会显示一次，因此对于生成的令牌要妥善保存，而且后面创建Secret资源时，要将Access Token修改为此处生成的内容
  
#部署gitlab
root@k8s-master01:~/knative-in-practise/eventing/gitlab/deploy# ls
01-namespace.yaml  02-redis.yaml  03-secret.yaml  04-postgresql.yaml  05-gitlab.yaml  06-virtualservice-gitlab.yaml
root@k8s-master01:~/knative-in-practise/eventing/gitlab/deploy# cat 03-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: gitlab
  namespace: gitlab
data:
  db_pass: bWFnZWR1LmNvbQ==
  db_user: Z2l0bGFi
  gitlab_root_pass: bWFnZWR1LmNvbQ==	
  # root pass: magedu.com	#编码后面是上面的密码
  gitlab_secrets_db_key_base: bE92U1NTcHMwSDJVU2tBTS9VajhZVUZMRjhPS25xUGhwTG5ocG41N0drTQ==
  gitlab_secrets_otp_key_base: aVZ6Z01OUFoybjFKRk1US1ltUUVUS3lYL3VpbWpKaDBMeVhFemlmTmhVNA==
  gitlab_secrets_secret_key_base: VFVFNWk3SW1wT0lQSzN6cnZCTnFUU09UWjI3ZjRkTm56cVNXejF6eW5BWQ==
type: Opaque
root@k8s-master01:~/knative-in-practise/eventing/gitlab/deploy# kubectl apply -f .
root@k8s-master01:~/knative-in-practise/eventing/gitlab/deploy# kubectl get pods -n gitlab -o wide
NAME                            READY   STATUS    RESTARTS   AGE    IP              NODE           NOMINATED NODE   READINESS GATES
gitlab-9869ddd86-rhnmz          1/1     Running   0          155m   172.20.58.198   172.168.2.25   <none>           <none>
gitlab-pgsql-c7977cf54-xkw9k    1/1     Running   0          6h2m   172.20.58.193   172.168.2.25   <none>           <none>
gitlab-redis-6447c65847-zxmjj   1/1     Running   0          6h2m   172.20.85.222   172.168.2.24   <none>           <none>
root@k8s-master01:~/knative-in-practise/eventing/gitlab/deploy# kubectl get svc -n gitlab
NAME                TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                           AGE
code                ClusterIP      10.68.104.74    <none>        80/TCP,22/TCP                     6h7m	#集群内部访问gitlab地址
gitlab              LoadBalancer   10.68.35.213    <pending>     31080:34377/TCP,31022:62339/TCP   6h7m
gitlab-postgresql   ClusterIP      10.68.177.138   <none>        5432/TCP                          6h7m
gitlab-redis        ClusterIP      10.68.208.40    <none>        6379/TCP                          6h7m
root@k8s-master01:~/knative-in-practise/eventing/gitlab/deploy# kubectl get vs -n gitlab
NAME                    GATEWAYS                          HOSTS                                     AGE
gitlab-virtualservice   ["istio-system/gitlab-gateway"]   ["gitlab.magedu.com","code.magedu.com"]   6h9m	#对外访问
#配置gitlab UI
  - 通用→可见性：设定“自定义HTTP(S)协议Git克隆URL”，如http://code.gitlab.svc.cluster.local
  - 网络→外发请求(Outbound requests)：设定“Allow requests to the local network from web hooks and services”
  - 创建示例仓库，以myproject为例
- 建Personal Access Token（简单起见，直接以root为例）
  - 个人设定 → 偏好设置 → 访问令牌（必须是api scope）(api权限包含下面的权限){名称：root-access-token, SECRET: U5cj8X-Jobqn-T-WVYyd}
  - 注：生成的令牌信息仅会显示一次，因此对于生成的令牌要妥善保存，而且后面创建Secret资源(gitlab source需要)时，要将Access Token修改为此处生成的内容
  
#GitLab Source 实践3
- 部署GitLabSource
  - 在knative-sandbox/eventing-gitlab仓库中定位到合适的版本，而后利用其release的配置文件即可完成部署
    - kubectl apply -f https://github.com/knative-sandbox/eventing-gitlab/releases/download/knative-v1.2.0/gitlab.yaml
  - 相关资源部署于knative-sources名称空间，主要生成两个Deployment
    - gitlab-controller-manager(用于支撑CRD资源运行的控制器)
    - gitlab-webhook(admission控制器)
- 部署KService/event-display作为Sink
  - kn service apply event-display --image ikubernetes/event_display --port 8080 -n event-demo
  - 其中的secretToken则可以由openssl命令手动生成 ~$ openssl rand -base64 16		#6TRmhJeotxTk7PAcHzdo8A==
- 创建Secret资源
---
apiVersion: v1
kind: Secret
metadata:
  name: gitlabsecret
  namespace: event-demo
type: Opaque
  stringData:
    accessToken: U5cj8X-Jobqn-T-WVYyd		#gitlab生成的token
    secretToken: JQ1ambOFdXGZPFWsOov0iQ		#自己生的随机字符串
---
#部署gitlab source
root@k8s-master01:~/knative-in-practise/eventing/gitlab/gitlab-source# kubectl apply -f gitlab-v1.2.yaml
root@k8s-master01:~/knative-in-practise/eventing/gitlab/gitlab-source# kubectl api-resources | grep source
resourcequotas                    quota           v1                                          true         ResourceQuota
customresourcedefinitions         crd,crds        apiextensions.k8s.io/v1                     false        CustomResourceDefinition
apiserversources                                  sources.knative.dev/v1                      true         ApiServerSource
containersources                                  sources.knative.dev/v1                      true         ContainerSource
gitlabsources                                     sources.knative.dev/v1alpha1                true         GitLabSource	#新部署的source
pingsources                                       sources.knative.dev/v1                      true         PingSource
sinkbindings                                      sources.knative.dev/v1                      true         SinkBinding
root@k8s-master01:~/knative-in-practise/eventing/gitlab/gitlab-source# kubectl get pods -n knative-sources
NAME                                        READY   STATUS    RESTARTS   AGE
gitlab-controller-manager-6684c879c-dnb54   1/1     Running   0          2m49s
gitlab-webhook-58877c574c-rdlwf             1/1     Running   0          2m47s
root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# ll
total 16
drwxr-xr-x 2 root root 144 May 10 20:50 ./
drwxr-xr-x 7 root root 221 May  8 15:03 ../
-rw-r--r-- 1 root root  64 May  8 15:03 01-namespace.yaml
-rw-r--r-- 1 root root 329 May  8 15:03 02-kservice-event-display.yaml
-rw-r--r-- 1 root root 182 May 10 20:50 03-secret-token.yaml
-rw-r--r-- 1 root root 579 May  8 15:03 04-GitLabSource-to-knative-service.yaml	#实现gitlab source
root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# kubectl apply -f 01-namespace.yaml -f 02-kservice-event-display.yaml

#GitLab Source 实践4
- 创建GitLabSource
  - eventType
    - 指定要监视的事件类型
    - 示例中指定监视了四类事件
  - projectUrl
    - 即要监视的目标代码仓库的URL
    - 示例中使用了Kubernetes集群上GitLab Service的名称
  - sslverify
    - 是否进行ssl认证
  - accessToken
    - GitLab上仓库所属的用户的personal access token
    - 通常要从Secret资源上引用
  - secretToken
    - 由GitLab经Webhook调用GitLabSource时使用的Secret
    - 通常要从Secret资源上引用
  - sink
    - 事件的输出目标
root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# cat 03-secret-token.yaml	#配置token
apiVersion: v1
kind: Secret
metadata:
  name: gitlabsecret
  namespace: event-demo
type: Opaque
stringData:
  accessToken: U5cj8X-Jobqn-T-WVYyd		#gitlab生成的token
  secretToken: JQ1ambOFdXGZPFWsOov0iQ	#自己生的随机字符串，用于gitlab访问gitlab source的
root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# cat 04-GitLabSource-to-knative-service.yaml
apiVersion: sources.knative.dev/v1alpha1
kind: GitLabSource
metadata:
  name: gitlabsource-demo
  namespace: event-demo
spec:
  eventTypes:
    - push_events
    - issues_events
    - merge_requests_events
    - tag_push_events
  projectUrl: http://code.gitlab.svc.cluster.local/root/myproject	#配置项目地址，不要带.git结尾，对外URL域前面已经更改过
  sslverify: false
  accessToken:
    secretKeyRef:
      name: gitlabsecret
      key: accessToken		#gitlab source 访问gitlab时的token
  secretToken:
    secretKeyRef:
      name: gitlabsecret
      key: secretToken		#gitlab访问gitlab source时的secret 
  sink:
    ref:
      apiVersion: serving.knative.dev/v1	#sink的地址信息
      kind: Service
      name: event-display
root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# kubectl apply -f 03-secret-token.yaml -f 04-GitLabSource-to-knative-service.yaml	#gitlabsource生成的对象跟kservice一样，而且还多了个gitlabsource对象
root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# kubectl get all -n event-demo
NAME                                                            READY   STATUS    RESTARTS   AGE
pod/event-display-00001-deployment-7f6d979c94-s4fnr             2/2     Running   0          5h48m
pod/gitlabsource-demo-6ck9p-00001-deployment-7bcdf56f45-gfs5m   2/2     Running   0          27s

NAME                                            TYPE           CLUSTER-IP     EXTERNAL-IP                                            PORT(S)                                      AGE
service/event-display                           ExternalName   <none>         knative-local-gateway.istio-system.svc.cluster.local   80/TCP                                       5h48m
service/event-display-00001                     ClusterIP      10.68.159.81   <none>                                                 80/TCP                                       5h48m
service/event-display-00001-private             ClusterIP      10.68.90.140   <none>                                                 80/TCP,9090/TCP,9091/TCP,8022/TCP,8012/TCP   5h48m
service/gitlabsource-demo-6ck9p                 ExternalName   <none>         knative-local-gateway.istio-system.svc.cluster.local   80/TCP                                       20s
service/gitlabsource-demo-6ck9p-00001           ClusterIP      10.68.10.40    <none>                                                 80/TCP                                       26s
service/gitlabsource-demo-6ck9p-00001-private   ClusterIP      10.68.15.77    <none>                                                 80/TCP,9090/TCP,9091/TCP,8022/TCP,8012/TCP   27s

NAME                                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/event-display-00001-deployment             1/1     1            1           5h48m
deployment.apps/gitlabsource-demo-6ck9p-00001-deployment   1/1     1            1           27s

NAME                                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/event-display-00001-deployment-7f6d979c94             1         1         1       5h48m
replicaset.apps/gitlabsource-demo-6ck9p-00001-deployment-7bcdf56f45   1         1         1       27s

NAME                                                        LATESTCREATED                   LATESTREADY                     READY   REASON
configuration.serving.knative.dev/event-display             event-display-00001             event-display-00001             True
configuration.serving.knative.dev/gitlabsource-demo-6ck9p   gitlabsource-demo-6ck9p-00001   gitlabsource-demo-6ck9p-00001   True

NAME                                                         CONFIG NAME               K8S SERVICE NAME   GENERATION   READY   REASON   ACTUAL REPLICAS   DESIRED REPLICAS
revision.serving.knative.dev/event-display-00001             event-display                                1            True             1                 1
revision.serving.knative.dev/gitlabsource-demo-6ck9p-00001   gitlabsource-demo-6ck9p                      1            True             1                 1

NAME                                                  URL                                                     LATESTCREATED                   LATESTREADY                     READY   REASON
service.serving.knative.dev/event-display             http://event-display.event-demo.example.com             event-display-00001             event-display-00001             True
service.serving.knative.dev/gitlabsource-demo-6ck9p   http://gitlabsource-demo-6ck9p.event-demo.example.com   gitlabsource-demo-6ck9p-00001   gitlabsource-demo-6ck9p-00001   True

NAME                                                URL                                                     READY   REASON
route.serving.knative.dev/event-display             http://event-display.event-demo.example.com             True
route.serving.knative.dev/gitlabsource-demo-6ck9p   http://gitlabsource-demo-6ck9p.event-demo.example.com   True

NAME                                                 READY   REASON   SINK                                                AGE
gitlabsource.sources.knative.dev/gitlabsource-demo   True             http://event-display.event-demo.svc.cluster.local   28s

root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# kubectl get vs -n event-demo  | grep gitlabsource	#gitlabsource VS
gitlabsource-demo-6ck9p-ingress   ["knative-serving/knative-ingress-gateway","knative-serving/knative-local-gateway"]   ["gitlabsource-demo-6ck9p.event-demo","gitlabsource-demo-6ck9p.event-demo.example.com","gitlabsource-demo-6ck9p.event-demo.svc","gitlabsource-demo-6ck9p.event-demo.svc.cluster.local"]   2m16s
gitlabsource-demo-6ck9p-mesh      ["mesh"]                                                                              ["gitlabsource-demo-6ck9p.event-demo","gitlabsource-demo-6ck9p.event-demo.svc","gitlabsource-demo-6ck9p.event-demo.svc.cluster.local"]                                                    2m16s


#GitLab Source 实践5
- GitLabSource资源创建完成生，会有相应代码仓库Webhook上自动完成注册
  - myproject仓库 → 设置 → Webhooks
  - 示例环境中，GitLab无法通过GitLabSource外部地址访问到它，因而，这里可以将其编辑为内部格式的地址，方法是，将域名后缀修example.com修改为svc.cluster.local
  - 通过"测试"，手动推送测试事件即可完成测试，下面是从event-display上获取到的两个不同类型的事件
root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# EVENT_POD=$(kubectl get pods -n event-demo -l serving.knative.dev/service=event-display -o jsonpath='{.items[0].metadata.name}')
root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# echo $EVENT_POD
event-display-00001-deployment-7f6d979c94-s4fnr
root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# kubectl logs -f $EVENT_POD -c user-container -n event-demo		#监视从gitlab传来的事件日志
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: dev.knative.sources.gitlab.push
  source: http://code.gitlab.svc.cluster.local/root/myproject
  id: 79dae86c-964b-4c55-ac45-7b5408602e88
  time: 2022-05-10T13:08:08.443564349Z
  datacontenttype: application/json
Extensions,
  comgitlabevent: Push Hook		#生成的push事件
Data,
  {
    "object_kind": "push",
    "before": "042e605640ba88ab9b9d9dd08794d5a225c7b8ec",
    "after": "042e605640ba88ab9b9d9dd08794d5a225c7b8ec",
    "ref": "refs/heads/main",
    "checkout_sha": "042e605640ba88ab9b9d9dd08794d5a225c7b8ec",
    "user_id": 1,
    "user_name": "Administrator",
    "user_username": "root",
    "user_email": "",
    "user_avatar": "https://www.gravatar.com/avatar/dafa3f209d417114218e7c150f7f4215?s=80\u0026d=identicon",
    "project_id": 2,
    "Project": {
      "id": 2,
      "name": "Myproject",
      "description": "",
      "web_url": "http://code.gitlab.svc.cluster.local/root/myproject",
      "avatar_url": "",
      "git_ssh_url": "git@code.gitlab.svc.cluster.local:root/myproject.git",
      "git_http_url": "http://code.gitlab.svc.cluster.local/root/myproject.git",
      "namespace": "Administrator",
      "visibility_level": 20,
      "path_with_namespace": "root/myproject",
      "default_branch": "main",
      "homepage": "http://code.gitlab.svc.cluster.local/root/myproject",
      "url": "git@code.gitlab.svc.cluster.local:root/myproject.git",
      "ssh_url": "git@code.gitlab.svc.cluster.local:root/myproject.git",
      "http_url": "http://code.gitlab.svc.cluster.local/root/myproject.git"
    },
    "repository": {
      "name": "Myproject",
      "url": "git@code.gitlab.svc.cluster.local:root/myproject.git",
      "description": "",
      "homepage": "http://code.gitlab.svc.cluster.local/root/myproject"
    },
    "commits": [
      {
        "id": "042e605640ba88ab9b9d9dd08794d5a225c7b8ec",
        "message": "Initial commit",
        "timestamp": "2022-05-10T20:42:08+08:00",
        "url": "http://code.gitlab.svc.cluster.local/root/myproject/-/commit/042e605640ba88ab9b9d9dd08794d5a225c7b8ec",
        "author": {
          "name": "Administrator",
          "email": "mage@magedu.com"
        },
        "added": [
          "README.md"
        ],
        "modified": [],
        "removed": []
      }
    ],
    "total_commits_count": 1
  }


☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: dev.knative.sources.gitlab.tag_push
  source: http://code.gitlab.svc.cluster.local/root/myproject
  id: 9d17f524-4a37-47b3-b4d8-bbec71feab44
  time: 2022-05-10T13:08:24.825791483Z
  datacontenttype: application/json
Extensions,
  comgitlabevent: Tag Push Hook		#生成的tag push事件
Data,
  {
    "object_kind": "push",
    "before": "042e605640ba88ab9b9d9dd08794d5a225c7b8ec",
    "after": "042e605640ba88ab9b9d9dd08794d5a225c7b8ec",
    "ref": "refs/heads/main",
    "checkout_sha": "042e605640ba88ab9b9d9dd08794d5a225c7b8ec",
    "user_id": 1,
    "user_name": "Administrator",
    "user_username": "root",
    "user_avatar": "https://www.gravatar.com/avatar/dafa3f209d417114218e7c150f7f4215?s=80\u0026d=identicon",
    "project_id": 2,
    "Project": {
      "id": 2,
      "name": "Myproject",
      "description": "",
      "web_url": "http://code.gitlab.svc.cluster.local/root/myproject",
      "avatar_url": "",
      "git_ssh_url": "git@code.gitlab.svc.cluster.local:root/myproject.git",
      "git_http_url": "http://code.gitlab.svc.cluster.local/root/myproject.git",
      "namespace": "Administrator",
      "visibility_level": 20,
      "path_with_namespace": "root/myproject",
      "default_branch": "main",
      "homepage": "http://code.gitlab.svc.cluster.local/root/myproject",
      "url": "git@code.gitlab.svc.cluster.local:root/myproject.git",
      "ssh_url": "git@code.gitlab.svc.cluster.local:root/myproject.git",
      "http_url": "http://code.gitlab.svc.cluster.local/root/myproject.git"
    },
    "repository": {
      "name": "Myproject",
      "url": "git@code.gitlab.svc.cluster.local:root/myproject.git",
      "description": "",
      "homepage": "http://code.gitlab.svc.cluster.local/root/myproject"
    },
    "commits": [
      {
        "id": "042e605640ba88ab9b9d9dd08794d5a225c7b8ec",
        "message": "Initial commit",
        "timestamp": "2022-05-10T20:42:08+08:00",
        "url": "http://code.gitlab.svc.cluster.local/root/myproject/-/commit/042e605640ba88ab9b9d9dd08794d5a225c7b8ec",
        "author": {
          "name": "Administrator",
          "email": "mage@magedu.com"
        },
        "added": [
          "README.md"
        ],
        "modified": [],
        "removed": []
      }
    ],
    "total_commits_count": 1
  }


☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: dev.knative.sources.gitlab.issue
  source: http://code.gitlab.svc.cluster.local/root/myproject
  id: f914b76a-7831-4ce3-9826-4c84bbe49ddd
  time: 2022-05-10T13:08:52.354894174Z
  datacontenttype: application/json
Extensions,
  comgitlabevent: Issue Hook	#生成的issue事件
Data,
  {
    "object_kind": "issue",
    "user": {
      "name": "Administrator",
      "username": "root",
      "avatar_url": "https://www.gravatar.com/avatar/dafa3f209d417114218e7c150f7f4215?s=80\u0026d=identicon"
    },
    "project": {
      "id": 2,
      "name": "Myproject",
      "description": "",
      "web_url": "http://code.gitlab.svc.cluster.local/root/myproject",
      "avatar_url": "",
      "git_ssh_url": "git@code.gitlab.svc.cluster.local:root/myproject.git",
      "git_http_url": "http://code.gitlab.svc.cluster.local/root/myproject.git",
      "namespace": "Administrator",
      "visibility_level": 20,
      "path_with_namespace": "root/myproject",
      "default_branch": "main",
      "homepage": "http://code.gitlab.svc.cluster.local/root/myproject",
      "url": "git@code.gitlab.svc.cluster.local:root/myproject.git",
      "ssh_url": "git@code.gitlab.svc.cluster.local:root/myproject.git",
      "http_url": "http://code.gitlab.svc.cluster.local/root/myproject.git"
    },
    "repository": {
      "name": "Myproject",
      "url": "git@code.gitlab.svc.cluster.local:root/myproject.git",
      "description": "",
      "homepage": "http://code.gitlab.svc.cluster.local/root/myproject"
    },
    "object_attributes": {
      "id": 1,
      "title": "test",
      "assignee_id": 0,
      "author_id": 1,
      "project_id": 2,
      "created_at": "2022-05-10T21:08:51+08:00",
      "updated_at": "2022-05-10T21:08:51+08:00",
      "change_position": {
        "base_sha": "",
        "start_sha": "",
        "head_sha": "",
        "old_path": "",
        "new_path": "",
        "position_type": "",
        "old_line": 0,
        "new_line": 0,
        "width": 0,
        "height": 0,
        "x": 0,
        "y": 0
      },
      "original_position": {
        "base_sha": "",
        "start_sha": "",
        "head_sha": "",
        "old_path": "",
        "new_path": "",
        "position_type": "",
        "old_line": 0,
        "new_line": 0,
        "width": 0,
        "height": 0,
        "x": 0,
        "y": 0
      },
      "position": {
        "base_sha": "",
        "start_sha": "",
        "head_sha": "",
        "old_path": "",
        "new_path": "",
        "position_type": "",
        "old_line": 0,
        "new_line": 0,
        "width": 0,
        "height": 0,
        "x": 0,
        "y": 0
      },
      "branch_name": "",
      "description": "test",
      "milestone_id": 0,
      "state": "opened",
      "iid": 1,
      "url": "http://code.gitlab.svc.cluster.local/root/myproject/-/issues/1",
      "action": "open",
      "target_branch": "",
      "source_branch": "",
      "source_project_id": 0,
      "target_project_id": 0,
      "st_commits": "",
      "merge_status": "",
      "content": "",
      "format": "",
      "message": "",
      "slug": "",
      "ref": "",
      "tag": false,
      "sha": "",
      "before_sha": "",
      "status": "",
      "stages": null,
      "duration": 0,
      "note": "",
      "noteable_type": "",
      "attachment": "0001-01-01T00:00:00Z",
      "line_code": "",
      "commit_id": "",
      "noteable_id": 0,
      "system": false,
      "work_in_progress": false,
      "st_diffs": null,
      "source": {
        "name": "",
        "description": "",
        "web_url": "",
        "avatar_url": "",
        "git_ssh_url": "",
        "git_http_url": "",
        "namespace": "",
        "visibility_level": 0,
        "path_with_namespace": "",
        "default_branch": "",
        "homepage": "",
        "url": "",
        "ssh_url": "",
        "http_url": ""
      },
      "target": {
        "name": "",
        "description": "",
        "web_url": "",
        "avatar_url": "",
        "git_ssh_url": "",
        "git_http_url": "",
        "namespace": "",
        "visibility_level": 0,
        "path_with_namespace": "",
        "default_branch": "",
        "homepage": "",
        "url": "",
        "ssh_url": "",
        "http_url": ""
      },
      "last_commit": {
        "id": "",
        "message": "",
        "timestamp": "0001-01-01T00:00:00Z",
        "url": "",
        "author": {
          "name": "",
          "email": ""
        }
      },
      "assignee": {
        "name": "",
        "username": "",
        "avatar_url": ""
      }
    },
    "assignee": {
      "name": "",
      "username": "",
      "avatar_url": ""
    },
    "changes": {
      "labels": {
        "previous": null,
        "current": null
      }
    }
  }




##Pub/Sub
#Channel 和 Subscription
- 关于Channel
  - Eventing中的Channel CRD负责定义名称空间级别的消息总线
  - 它的后端要基于特定的实现，如In-Memory Channel（简称imc）、NATS Channel或Kafka Channel等
  - 每个Channel应该对应于一个特定Topic
  - 通常，Channels and Subscriptions消息投递模式中才需要自行创建Channel
    - Sources to Sink模式不需要Channel
    - Brokers and Triggers无须自行配置Channel
- 关于Subscription
  - Eventing中的Subscription CRD负责将Sink（例如Service或KService）连接至一个Channel之上；
  - 何时需要自行创建Subscription
    - Sources to Sink模式不需要Subscription，因为没有Channel可以订阅
    - Channels and Subscriptions消息投递模式，需要创建订阅至Channel的Subscription
    - Brokers and Triggers消息投递模式，需要创建订阅至Trigger的Subscription
#Channel 和 Subscription 实践(无法跨名称空间)
- 示例环境说明
  - 基于imc的channel/imc01作为消息总线
  - kservice/event-display订阅channel/imc01
  - curl命令作为event source，基于HTTP协议推送消息至channel/imc01
- 命令式命令
  - Channel
    - 创建：~$ kn channel create imc01 --type messaging.knative.dev:v1:InMemoryChannel
      - 该类型标识存在一个内置的别名“imc”，因而上面的类型也可简单地指定为该别名
    - 列出channel/imc01以获取其URL：~$ kn channel list imc01
      - URL的样式：http://imc01-kn-channel.default.svc.cluster.local
  - Sink: kservice/event-display
    - 若不存在，需要先创建：~$ kn service create event-display --image ikubernetes/event_display --port 8080 --scale-min 1
  - Subscription
    - 创建： ~$ kn subscription create sub01 --channel imc01 --sink ksvc:event-display
      - subscription/sub01负责连接kservice/event-display至channel/imc01
----创建chennel
root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# kn channel list-types
TYPE              NAME                                     DESCRIPTION
InMemoryChannel   inmemorychannels.messaging.knative.dev   The events are stored in memory
root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# kn channel create imc01 --type messaging.knative.dev:v1:InMemoryChannel	#创建chennel imc01
root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# kn channel list
NAME    TYPE              URL                                                 AGE   READY   REASON
imc01   InMemoryChannel   http://imc01-kn-channel.default.svc.cluster.local   4s    True

--查看sink
root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# kubectl get pods
kNAME                                              READY   STATUS    RESTARTS       AGE
client                                            1/1     Running   1 (2d6h ago)   2d6h
event-display-00001-deployment-775b6f6749-nsc7x   2/2     Running   0              24h
--查看两个ksvc
root@k8s-master01:~# kn ksvc list
NAME            URL                                        LATEST                AGE    CONDITIONS   READY   REASON
event-display   http://event-display.default.example.com   event-display-00001   24h    3 OK / 3     True
hello           http://hello.default.example.com           hello-00007           2d1h   3 OK / 3     True
----创建subscription
root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# kn subscription create sub01 --channel imc01 --sink ksvc:event-display:default	
Subscription 'sub01' created in namespace 'default'.
root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# kn subscription list
NAME    CHANNEL         SUBSCRIBER           REPLY   DEAD LETTER SINK   READY   REASON
sub01   Channel:imc01   ksvc:event-display                              True
----模拟curlSouce -> channel -> subscription -> sink(default)
root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# kn channel list
NAME    TYPE              URL                                                 AGE     READY   REASON
imc01   InMemoryChannel   http://imc01-kn-channel.default.svc.cluster.local   5m17s   True
--发送curl source
root@client# curl -v "http://imc01-kn-channel.default.svc.cluster.local" \
-X POST \
-H "Ce-Id: 00001" \
-H "Ce-Specversion: 1.0" \
-H "Ce-Type: com.magedu.file.image" \
-H "Ce-Source: curl" \
-H "Content-Type: application/json" \
-d '{"msg":"Hello IMC Channel!"}'
Note: Unnecessary use of -X or --request, POST is already inferred.
*   Trying 10.68.202.229:80...
* TCP_NODELAY set
* Connected to imc01-kn-channel.default.svc.cluster.local (10.68.202.229) port 80 (#0)
> POST / HTTP/1.1
> Host: imc01-kn-channel.default.svc.cluster.local
> User-Agent: curl/7.67.0
> Accept: */*
> Ce-Id: 00001
> Ce-Specversion: 1.0
> Ce-Type: com.magedu.file.image
> Ce-Source: curl
> Content-Type: application/json
> Content-Length: 28
>
* upload completely sent off: 28 out of 28 bytes
* Mark bundle as not supporting multiuse
< HTTP/1.1 202 Accepted
< Allow: POST, OPTIONS
< Date: Tue, 10 May 2022 14:36:25 GMT
< Content-Length: 0
<
* Connection #0 to host imc01-kn-channel.default.svc.cluster.local left intact

--查看事件日志
root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# DEFAULT_POD=$(kubectl get pods -l serving.knative.dev/service=event-display -o jsonpath='{.items[0].metadata.name}')
root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# echo $DEFAULT_POD
event-display-00001-deployment-775b6f6749-nsc7x
root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# kubectl logs -f $DEFAULT_POD -c user-container
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: com.magedu.file.image
  source: curl
  id: 00001
  datacontenttype: application/json
Data,
  {
    "msg": "Hello IMC Channel!"
  }

----在同名称空间下再创建一个event-display
root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# kn service create event-display-mirror --image ikubernetes/event_display --port 8080 --scale-min 1
root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# kn ksvc list
NAME                   URL                                               LATEST                       AGE     CONDITIONS   READY   REASON
event-display          http://event-display.default.example.com          event-display-00001          25h     3 OK / 3     True
event-display-mirror   http://event-display-mirror.default.example.com   event-display-mirror-00001   2m45s   3 OK / 3     True
hello                  http://hello.default.example.com                  hello-00007                  2d2h    3 OK / 3     True
root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# kn subscription create sub02 --channel imc01 --sink ksvc:event-display-mirror:default
root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# kn subscription list
ANAME    CHANNEL         SUBSCRIBER                  REPLY   DEAD LETTER SINK   READY   REASON
sub01   Channel:imc01   ksvc:event-display                                     True
sub02   Channel:imc01   ksvc:event-display-mirror                              True
--测试同名称空间下的两个sink是否都收到同样的消息
root@client# curl -v "http://imc01-kn-channel.default.svc.cluster.local" \
-X POST \
-H "Ce-Id: 00001" \
-H "Ce-Specversion: 1.0" \
-H "Ce-Type: com.magedu.file.image" \
-H "Ce-Source: curl" \
-H "Content-Type: application/json" \
-d '{"msg":"Hello IMC Channel! 00002"}'
root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# kubectl logs event-display-00001-deployment-775b6f6749-nsc7x -c user-container
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: com.magedu.file.image
  source: curl
  id: 00001
  datacontenttype: application/json
Data,
  {
    "msg": "Hello IMC Channel!"
  }
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: com.magedu.file.image
  source: curl
  id: 00001
  datacontenttype: application/json
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: com.magedu.file.image
  source: curl
  id: 00001
  datacontenttype: application/json
Data,
  {
    "msg": "Hello IMC Channel! 00002"
  }
root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# kubectl logs event-display-mirror-00001-deployment-f96544cdd-7dt4d -c user-container
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: com.magedu.file.image
  source: curl
  id: 00001
  datacontenttype: application/json
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: com.magedu.file.image
  source: curl
  id: 00001
  datacontenttype: application/json
Data,
  {
    "msg": "Hello IMC Channel! 00002"
  }

#实践gitlabsource
root@k8s-master01:~/knative-in-practise/eventing/sources/05-gitlabsource-to-knative-service# cat 04-GitLabSource-to-knative-service.yaml
apiVersion: sources.knative.dev/v1alpha1
kind: GitLabSource
metadata:
  name: gitlabsource-demo
spec:
  eventTypes:
    - push_events
    - issues_events
    - merge_requests_events
    - tag_push_events
  projectUrl: http://code.gitlab.svc.cluster.local/root/myproject
  sslverify: false
  accessToken:
    secretKeyRef:
      name: gitlabsecret
      key: accessToken
  secretToken:
    secretKeyRef:
      name: gitlabsecret
      key: secretToken
  sink:
    ref:
      apiVersion: messaging.knative.dev/v1		#此时推送的sink是channel
      kind: Channel
      name: imc01


##Message Broker
- Broker
  - 承载消息队列的组件，它从生产者接收消息，并根据消息交换规则将其交换至相应的队列（或Topic）
    - 生产者通过特定的协议将Message投递至Broker
  - 然后，通过队列（或Topic），将消息传递给消费者
  - Kafka、RabbitMQ、ActiveMQ和RocketMQ是较为常见的代表产品
- 消息代理模式
  - Point-to-point messaging
    - 消息的发送者与接收者之间存在“一对一”的关系，队列中的每条消息只发送一个接收者，并且只能被消费一次
    - 适合消息仅能被处理一次的场景，例工资单处理、金融交易处理等
  - Publish/subscribe messaging
    - 即“发布/订阅”模式，每条消息的生产者将消息发布到一个主题（Topic），多个消费者可以访问他们希望从中接收消息的Topic
    - 发布到Topic的所有消息，都会分发给订阅该Topic的消费者
      - Kafka的Topic内部由一到多个队列（Queue）组成，这些内部队列称为Partition
      - 消费者也可以在Partition级别订阅
    - 广播式分发机制，消息的发布者与消息的消费者之间存在“一对多”的关系

#Knative的Broker/Trigger 消息传递框架
- Broker
  - Knative Eventing提供的CRD，负责收集CloudEvents类型的事件
  - Broker对象会提供一个用于事件传入的入口端点，各生产者可以调用该入口将事件发往Broker
  - 将事件投递至目的地的任务则由Trigger资源负责
  - Trigger基于属性过滤事件，并将筛选出的的事件投递给订阅该Trigger的Subscriber
  - Subscriber还可生成响应事件，并将这些新生成的事件传入Broker

#Broker类型
- Knative Eventing支持以下几种类型的Broker
  - 基于Channel的多租户Broker （Multi-tenant channel-based broker，简称为MT-Channel-based Broker）
    - 基于Channel进行事件路由
    - 需要部署至少一种Channel的实现
      - InMemoryChannel：可用于开发和测试目的，但不为生产环境提供适当的事件交付保证
      - KafkaChannel：提供生产环境所需的事件交付保证
  - 其它的可用的Broker类型
    - Apache Kafka Broker
    - RabbitMQ Broker
    - GCP Broker

#使用默认的Broker
- Knative Serving在名称空间级别提供了一个名为default的默认Broker，但使用前需要通过某种方式先行完成创建
- 创建默认Broker的方法
  - 命令式命令，或使用配置文件
    - kn broker create default --namespace NS_NAME
  - 在Trigger资源上使用特定的Annotation自动创建
    - eventing.knative.dev/injection=enabled
  - 在名称空间上添加特定的Label自动创建
    - eventing.knative.dev/injection=enabled
- 删除默认的Broker
  - 第一种方法创建的默认Broker可直接进行删除
  - 后面两种是通过Injection的方式进行的资源创建，这类资源需要由管理员手动才能完成删除

#Broker/Trigger 实践
流程：gitlab source -> broker -> trigger(绑定broker和sink，并且添加过滤事件push) -> sink(ksvc，event-displlay)
							  -> trigger(绑定broker和sink，并且添加过滤事件issue) -> sink(ksvc，event-displlay-mirror)
gitlab source type: dev.knative.sources.gitlab.issue, dev.knative.sources.gitlab.push
						  
--配置sink（event-display）
root@k8s-master01:~# kubectl get pods
NAME                                                    READY   STATUS    RESTARTS        AGE
client                                                  1/1     Running   1 (2d22h ago)   2d22h
event-display-00001-deployment-775b6f6749-qrnvv         2/2     Running   0               4m22s
event-display-mirror-00001-deployment-f96544cdd-7dt4d   2/2     Running   0               15h

--创建broker
root@k8s-master01:/tmp# kn broker create broker01 --namespace default --class MTChannelBasedBroker
Broker 'broker01' successfully created in namespace 'default'.
root@k8s-master01:/tmp# kn broker list
NAME       URL                                                                         AGE   CONDITIONS   READY   REASON
broker01   http://broker-ingress.knative-eventing.svc.cluster.local/default/broker01   14s   6 OK / 6     True

--创建trigger
root@k8s-master01:/tmp# kn trigger create push-trigger --broker broker01 --filter type=dev.knative.sources.gitlab.push --sink ksvc:event-display:default
Trigger 'push-trigger' successfully created in namespace 'default'.
root@k8s-master01:/tmp# kn trigger create issue-trigger --broker broker01 --filter type=dev.knative.sources.gitlab.issue --sink ksvc:event-display-mirror:default
Trigger 'issue-trigger' successfully created in namespace 'default'.
root@k8s-master01:/tmp# kn trigger list
NAME            BROKER     SINK                        AGE   CONDITIONS   READY   REASON
issue-trigger   broker01   ksvc:event-display-mirror   6s    6 OK / 6     True
push-trigger    broker01   ksvc:event-display          29s   6 OK / 6     True

--创建gitlabSource
root@k8s-master01:/tmp# cat 03-secret-token.yaml
apiVersion: v1
kind: Secret
metadata:
  name: gitlabsecret
type: Opaque
stringData:
  accessToken: U5cj8X-Jobqn-T-WVYyd
  secretToken: JQ1ambOFdXGZPFWsOov0iQ
root@k8s-master01:/tmp# cat 04-GitLabSource-to-knative-service.yaml
apiVersion: sources.knative.dev/v1alpha1
kind: GitLabSource
metadata:
  name: gitlabsource-demo
spec:
  eventTypes:
    - push_events
    - issues_events
    - merge_requests_events
    - tag_push_events
  projectUrl: http://code.gitlab.svc.cluster.local/root/myproject
  sslverify: false
  accessToken:
    secretKeyRef:
      name: gitlabsecret
      key: accessToken
  secretToken:
    secretKeyRef:
      name: gitlabsecret
      key: secretToken
  sink:
    ref:
      apiVersion: eventing.knative.dev/v1	#gitlabsource消息到broker，此处为broker的地址
      kind: Broker
      name: broker01
root@k8s-master01:/tmp# kubectl apply -f 03-secret-token.yaml -f 04-GitLabSource-to-knative-service.yaml
secret/gitlabsecret created
gitlabsource.sources.knative.dev/gitlabsource-demo created
root@k8s-master01:/tmp# kubectl get pods
NAME                                                        READY   STATUS    RESTARTS        AGE
client                                                      1/1     Running   1 (2d22h ago)   2d22h
event-display-00001-deployment-775b6f6749-qrnvv             2/2     Running   0               29m
event-display-mirror-00001-deployment-f96544cdd-7dt4d       2/2     Running   0               15h
gitlabsource-demo-9j5r9-00001-deployment-6c47b5954f-2xknl   2/2     Running   0               9s
root@k8s-master01:/tmp# kubectl get gitlabsource	#查看创建的gitlabsource，必须是READY状态才行，依赖pod gitlabsource
NAME                READY   REASON   SINK                                                                        AGE
gitlabsource-demo   True             http://broker-ingress.knative-eventing.svc.cluster.local/default/broker01   12s

----gitlab.magedu.comUI界面测试push，issue事件，看是否推送到指定的sink
--push event
root@k8s-master01:~# kubectl logs -f event-display-00001-deployment-775b6f6749-qrnvv -c user-container	#event-display POD收到消息而event-display-mirror未收到消息

☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: dev.knative.sources.gitlab.push
  source: http://code.gitlab.svc.cluster.local/root/myproject
  id: 5ff51630-b38d-41bd-817c-3a55c9c51f31
  time: 2022-05-11T06:46:09.568450155Z
  datacontenttype: application/json
Extensions,
  comgitlabevent: Push Hook
  knativearrivaltime: 2022-05-11T06:46:09.602420578Z
Data,
  {
    "object_kind": "push",
    "before": "95790bf891e76fee5e1747ab589903a6a1f80f22",
    "after": "da1560886d4f094c3e6c9ef40349f7d38b5d27d7",
    "ref": "refs/heads/master",
    "checkout_sha": "da1560886d4f094c3e6c9ef40349f7d38b5d27d7",
    "user_id": 4,
    "user_name": "John Smith",
    "user_username": "",
    "user_email": "john@example.com",
    "user_avatar": "https://s.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?s=8://s.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?s=80",
    "project_id": 15,
    "Project": {
      "id": 15,
      "name": "gitlab",
      "description": "",
      "web_url": "http://test.example.com/gitlab/gitlab",
      "avatar_url": "https://s.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?s=8://s.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?s=80",
      "git_ssh_url": "git@test.example.com:gitlab/gitlab.git",
      "git_http_url": "http://test.example.com/gitlab/gitlab.git",
      "namespace": "gitlab",
      "visibility_level": 0,
      "path_with_namespace": "gitlab/gitlab",
      "default_branch": "master",
      "homepage": "",
      "url": "",
      "ssh_url": "",
      "http_url": ""
    },
    "repository": {
      "name": "",
      "url": "",
      "description": "",
      "homepage": ""
    },
    "commits": [
      {
        "id": "c5feabde2d8cd023215af4d2ceeb7a64839fc428",
        "message": "Add simple search to projects in public area\n\ncommit message body",
        "timestamp": "2013-05-13T18:18:08Z",
        "url": "https://test.example.com/gitlab/gitlab/-/commit/c5feabde2d8cd023215af4d2ceeb7a64839fc428",
        "author": {
          "name": "Test User",
          "email": "test@example.com"
        },
        "added": null,
        "modified": null,
        "removed": null
      }
    ],
    "total_commits_count": 1
  }

--issue event
root@k8s-master01:~# kubectl logs -f event-display-mirror-00001-deployment-f96544cdd-7dt4d -c user-container  #event-display-mirror POD收到消息而event-display未收到消息
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: dev.knative.sources.gitlab.issue
  source: http://code.gitlab.svc.cluster.local/root/myproject
  id: 2f8d0cc7-765e-46d3-967c-4bbf339de80b
  time: 2022-05-11T06:47:46.183736909Z
  datacontenttype: application/json
Extensions,
  comgitlabevent: Issue Hook
  knativearrivaltime: 2022-05-11T06:47:46.250008514Z
Data,
  {
    "object_kind": "issue",
    "user": {
      "name": "Administrator",
      "username": "root",
      "avatar_url": "https://www.gravatar.com/avatar/dafa3f209d417114218e7c150f7f4215?s=80\u0026d=identicon"
    },
    "project": {
      "id": 2,
      "name": "Myproject",
      "description": "",
      "web_url": "http://code.gitlab.svc.cluster.local/root/myproject",
      "avatar_url": "",
      "git_ssh_url": "git@code.gitlab.svc.cluster.local:root/myproject.git",
      "git_http_url": "http://code.gitlab.svc.cluster.local/root/myproject.git",
      "namespace": "Administrator",
      "visibility_level": 20,
      "path_with_namespace": "root/myproject",
      "default_branch": "",
      "homepage": "http://code.gitlab.svc.cluster.local/root/myproject",
      "url": "git@code.gitlab.svc.cluster.local:root/myproject.git",
      "ssh_url": "git@code.gitlab.svc.cluster.local:root/myproject.git",
      "http_url": "http://code.gitlab.svc.cluster.local/root/myproject.git"
    },
    "repository": {
      "name": "Myproject",
      "url": "git@code.gitlab.svc.cluster.local:root/myproject.git",
      "description": "",
      "homepage": "http://code.gitlab.svc.cluster.local/root/myproject"
    },
    "object_attributes": {
      "id": 1,
      "title": "test",
      "assignee_id": 0,
      "author_id": 1,
      "project_id": 2,
      "created_at": "2022-05-10T21:08:51.85+08:00",
      "updated_at": "2022-05-10T21:08:51.85+08:00",
      "change_position": {
        "base_sha": "",
        "start_sha": "",
        "head_sha": "",
        "old_path": "",
        "new_path": "",
        "position_type": "",
        "old_line": 0,
        "new_line": 0,
        "width": 0,
        "height": 0,
        "x": 0,
        "y": 0
      },
      "original_position": {
        "base_sha": "",
        "start_sha": "",
        "head_sha": "",
        "old_path": "",
        "new_path": "",
        "position_type": "",
        "old_line": 0,
        "new_line": 0,
        "width": 0,
        "height": 0,
        "x": 0,
        "y": 0
      },
      "position": {
        "base_sha": "",
        "start_sha": "",
        "head_sha": "",
        "old_path": "",
        "new_path": "",
        "position_type": "",
        "old_line": 0,
        "new_line": 0,
        "width": 0,
        "height": 0,
        "x": 0,
        "y": 0
      },
      "branch_name": "",
      "description": "test",
      "milestone_id": 0,
      "state": "opened",
      "iid": 1,
      "url": "http://code.gitlab.svc.cluster.local/root/myproject/-/issues/1",
      "action": "",
      "target_branch": "",
      "source_branch": "",
      "source_project_id": 0,
      "target_project_id": 0,
      "st_commits": "",
      "merge_status": "",
      "content": "",
      "format": "",
      "message": "",
      "slug": "",
      "ref": "",
      "tag": false,
      "sha": "",
      "before_sha": "",
      "status": "",
      "stages": null,
      "duration": 0,
      "note": "",
      "noteable_type": "",
      "attachment": "0001-01-01T00:00:00Z",
      "line_code": "",
      "commit_id": "",
      "noteable_id": 0,
      "system": false,
      "work_in_progress": false,
      "st_diffs": null,
      "source": {
        "name": "",
        "description": "",
        "web_url": "",
        "avatar_url": "",
        "git_ssh_url": "",
        "git_http_url": "",
        "namespace": "",
        "visibility_level": 0,
        "path_with_namespace": "",
        "default_branch": "",
        "homepage": "",
        "url": "",
        "ssh_url": "",
        "http_url": ""
      },
      "target": {
        "name": "",
        "description": "",
        "web_url": "",
        "avatar_url": "",
        "git_ssh_url": "",
        "git_http_url": "",
        "namespace": "",
        "visibility_level": 0,
        "path_with_namespace": "",
        "default_branch": "",
        "homepage": "",
        "url": "",
        "ssh_url": "",
        "http_url": ""
      },
      "last_commit": {
        "id": "",
        "message": "",
        "timestamp": "0001-01-01T00:00:00Z",
        "url": "",
        "author": {
          "name": "",
          "email": ""
        }
      },
      "assignee": {
        "name": "",
        "username": "",
        "avatar_url": ""
      }
    },
    "assignee": {
      "name": "",
      "username": "",
      "avatar_url": ""
    },
    "changes": {
      "labels": {
        "previous": null,
        "current": null
      }
    }
  }



###flow
#Knative Event Driven Flow
- Importer
  - 连接至期望使用的第3方消息系统
  - 基于HTTP协议POST CloudEvents到Channel、Broker、Sequence/Parallel或Service/KService
- Channel
  - 支持多路订阅
  - 为订阅者“持久化”消息数据
- Service
  - 接收CloudEvents
  - （可选）回复处理后的数据
- Sequence
  - Kubernetes CRD资源类型
  - 串联多个Processor
  - 由多个有序的Step组件成，每个Step定义一个Subscriber
  - Step间的Channel，由ChannelTemplate定义
- Parallel：根据不同的过滤条件对事件进行选择处理
  - Kubernetes CRD资源类型
  - 由多个条件式的并行Branch组成，每个Branch由一对Filter及Subscriber组成
    - 每个Filter即为一个Processor
  - Channel由ChannelTemplate定义

#Sequence Flow 示例
- 示例环境说明
  - Curl命令负责生成event
  - Event由Sequence中的各Step顺次处理
    - 各Step都运行一个appender应用
    - 分别向收到的数据尾部附加自定义的专有数据项
  - 最终结果发往ksvc/event-display
- 准备实践环境
  - Sequence里，三个Step中的Knative Service
    - ~$ kn service apply sq-appender-01 --image ikubernetes/appender --env MESSAGE=" - Handled by SQ-01" -n event-demo
    - ~$ kn service apply sq-appender-02 --image ikubernetes/appender --env MESSAGE=" - Handled by SQ-02" -n event-demo
    - ~$ kn service apply sq-appender-03 --image ikubernetes/appender --env MESSAGE=" - Handled by SQ-03" -n event-demo
  - 负责最后接收事件的KService/event-display
    - ~$ kn service apply event-display --image=ikubernetes/event_display --port 8080 --scale-min 1 -n event-demo
- 创建Sequence资源
apiVersion: flows.knative.dev/v1
kind: Sequence
metadata:
  name: sq-demo
  namespace: event-demo
spec:
  channelTemplate:
    apiVersion: messaging.knative.dev/v1
    kind: InMemoryChannel
  steps:
    - ref:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: sq-appender-01
    - ref:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: sq-appender-02
    - ref:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: sq-appender-03
  reply:
    ref:
      kind: Service
      apiVersion: serving.knative.dev/v1
      name: event-display
---
- Sequence资源的期望状态（spec）主要包括三个字段
  - steps
    - 定义序列中的目的地（processor或function）列表
    - 按顺序调用
    - 每个step中还可以定义其投递属性，主要定义event投递失败时的处理办法
  - channelTemplate
    - 指定要使用的Channel CRD
    - 未指定时，将使用当前namespace或者Cluster中默认的Channel CRD
  - reply
    - 序列中最后一个Subscriber处理后的信息所要发往的目的地
- 创建并查看Sequence资源
- ~$ kubectl get sequences -n event-demo

#示例部署在flow名称空间下
---- 流程：curlSource -> Sequence( steps -> sink(event-display))
--创建名称空间
root@k8s-master01:~/knative-in-practise/eventing/flow/sequence-demo# kubectl create ns flow
--部署3个appender
root@k8s-master01:~/knative-in-practise/eventing/flow/sequence-demo# kn service apply sq-appender-01 --image ikubernetes/appender --env MESSAGE=" - Handled by SQ-01" -n flow
root@k8s-master01:~/knative-in-practise/eventing/flow/sequence-demo# kn service apply sq-appender-02 --image ikubernetes/appender --env MESSAGE=" - Handled by SQ-02" -n flow
root@k8s-master01:~/knative-in-practise/eventing/flow/sequence-demo# kn service apply sq-appender-03 --image ikubernetes/appender --env MESSAGE=" - Handled by SQ-03" -n flow
root@k8s-master01:~/knative-in-practise/eventing/flow/sequence-demo# kn service list -n flow
NAME             URL                                      LATEST                 AGE   CONDITIONS   READY   REASON
sq-appender-01   http://sq-appender-01.flow.example.com   sq-appender-01-00001   89s   3 OK / 3     True
sq-appender-02   http://sq-appender-02.flow.example.com   sq-appender-02-00001   55s   3 OK / 3     True
sq-appender-03   http://sq-appender-03.flow.example.com   sq-appender-03-00001   34s   3 OK / 3     True
--部署event-display
root@k8s-master01:~/knative-in-practise/eventing/flow/sequence-demo# kn service apply event-display --image ikubernetes/event_display --port 8080 --scale-min 1 -n flow
root@k8s-master01:~/knative-in-practise/eventing/flow/sequence-demo# kn service list -n flow
NAME             URL                                      LATEST                 AGE     CONDITIONS   READY   REASON
event-display    http://event-display.flow.example.com    event-display-00001    17s     3 OK / 3     True
sq-appender-01   http://sq-appender-01.flow.example.com   sq-appender-01-00001   10m     3 OK / 3     True
sq-appender-02   http://sq-appender-02.flow.example.com   sq-appender-02-00001   10m     3 OK / 3     True
sq-appender-03   http://sq-appender-03.flow.example.com   sq-appender-03-00001   9m56s   3 OK / 3     True
--部署sequence
root@k8s-master01:~/knative-in-practise/eventing/flow/sequence-demo# cat 04-sequence-demo.yaml
apiVersion: flows.knative.dev/v1
kind: Sequence
metadata:
  name: sq-demo
  namespace: flow
spec:
  channelTemplate:
    apiVersion: messaging.knative.dev/v1
    kind: InMemoryChannel
  steps:
    - ref:
        apiVersion: serving.knative.dev/v1	#定义的appender01
        kind: Service
        name: sq-appender-01
    - ref:
        apiVersion: serving.knative.dev/v1	#定义的appender02
        kind: Service
        name: sq-appender-02
    - ref:
        apiVersion: serving.knative.dev/v1	#定义的appender03
        kind: Service
        name: sq-appender-03
  reply:
    ref:
      kind: Service
      apiVersion: serving.knative.dev/v1	#定义的event-display
      name: event-display
root@k8s-master01:~/knative-in-practise/eventing/flow/sequence-demo# kubectl apply -f 04-sequence-demo.yaml
root@k8s-master01:~/knative-in-practise/eventing/flow/sequence-demo# kubectl get sequence -n flow
NAME      URL                                                              AGE   READY   REASON
sq-demo   http://sq-demo-kn-sequence-0-kn-channel.flow.svc.cluster.local   9s    True
--测试事件
curl -v "http://sq-demo-kn-sequence-0-kn-channel.flow.svc.cluster.local" \
-X POST \
-H "Ce-Id: 00001" \
-H "Ce-Specversion: 1.0" \
-H "Ce-Type: com.magedu.file.image" \
-H "Ce-Source: curl" \
-H "Content-Type: application/json" \
-d '{"msg":"Hello Sequence"}'

root@client # curl -v "http://sq-demo-kn-sequence-0-kn-channel.flow.svc.cluster.local" \	#是sequence的地址
> -X POST \
> -H "Ce-Id: 00001" \
> -H "Ce-Specversion: 1.0" \
> -H "Ce-Type: com.magedu.file.image" \
> -H "Ce-Source: curl" \
> -H "Content-Type: application/json" \
> -d '{"msg":"Hello Sequence"}'
Note: Unnecessary use of -X or --request, POST is already inferred.
*   Trying 10.68.202.229:80...
* TCP_NODELAY set
* Connected to sq-demo-kn-sequence-0-kn-channel.flow.svc.cluster.local (10.68.202.229) port 80 (#0)
> POST / HTTP/1.1
> Host: sq-demo-kn-sequence-0-kn-channel.flow.svc.cluster.local
> User-Agent: curl/7.67.0
> Accept: */*
> Ce-Id: 00001
> Ce-Specversion: 1.0
> Ce-Type: com.magedu.file.image
> Ce-Source: curl
> Content-Type: application/json
> Content-Length: 24
>
* upload completely sent off: 24 out of 24 bytes
* Mark bundle as not supporting multiuse
< HTTP/1.1 202 Accepted
< Allow: POST, OPTIONS
< Date: Wed, 11 May 2022 08:27:41 GMT
< Content-Length: 0
<
* Connection #0 to host sq-demo-kn-sequence-0-kn-channel.flow.svc.cluster.local left intact
root@k8s-master01:~/knative-in-practise/eventing/flow/sequence-demo# kubectl logs event-display-00001-deployment-75797d657-m2r78 -c user-container -n flow	#验证日志
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: com.magedu.file.image
  source: curl
  id: 00001
  time: 2022-05-11T08:27:45.262726535Z
  datacontenttype: application/json
Data,
  {
    "id": 0,
    "message": " - Handled by SQ-01 - Handled by SQ-02 - Handled by SQ-03"	#经过appender01,appender02,appender03 处理后再到event-display
  }


##Parallel Flow 示例
- 示例环境说明
  - Curl命令负责生成event
  - Parallel中有两个Branch
    - 使用kservice/image-filter作为Filter，筛选类型为“com.magedu.file.image”的事件，相应的Subscriber为ksvc/para-appender-image，负责将该类事件信息标识为Image；
    - 使用kservice/text-filter作为Filter，筛选类型为“com.magedu.file.image”的事件，相应的Subscriber为ksvc/para-appender-text，负责将该类事件信息标识为Text；
  - 所有分支的最终结果均发往ksvc/event-display，内容格式化Cloud Event存储入日志
- 准备实践环境
  - 两个Filter
    - kn service apply image-filter --image villardl/filter-nodejs:0.1 --env FILTER='event.type == "com.magedu.file.image"' -n event-demo
    - kn service apply text-filter --image villardl/filter-nodejs:0.1 --env FILTER='event.type == "com.magedu.file.text"' -n event-demo
  - 两个Subscriber
    - kn service apply para-appender-image --image ikubernetes/appender --env MESSAGE=" - filetype/Image" -n event-demo
    - kn service apply para-appender-text --image ikubernetes/appender --env MESSAGE=" - filetype/Text" -n event-demo
  - 负责最后接收事件的KService/event-display
    - ~$ kn service apply event-display --image=ikubernetes/event_display --port 8080 --scale-min 1 -n event-demo
- Parallel资源的期望状态（spec）主要包括三个字段
  - branches
    - 每个分支由一个filter和一个subscriber组成
    - filter负责定义过滤器，将符合条件的事件发给相应的subscriber
    - subscriber负责定义processor，将filter过滤的事件做相应处理
    - 结果发往reply或全局的reply
  - channelTemplate
    - 指定要使用的Channel CRD
    - 未指定时，将使用当前namespace或者Cluster中默认的Channel CRD
  - reply
    - 为所有branch处理后的信息定义一个全局目的地
- 创建并查看Parallel资源
  - ~$ kubectl get parallels -n event-demo

#同样新建个名称空间测试，如para
---- 流程：curlSource -> Parallel( Filter -> Subscriber -> sink(event display))
root@k8s-master01:~/knative-in-practise/eventing/flow/parallel-demo# kubectl create ns para
namespace/para created

--部署2个Filter
root@k8s-master01:~/knative-in-practise/eventing/flow/parallel-demo# kn service apply image-filter --image villardl/filter-nodejs:0.1 --env FILTER='event.type == "com.magedu.file.image"' -n para	#image filter
root@k8s-master01:~/knative-in-practise/eventing/flow/parallel-demo# kn service apply text-filter --image villardl/filter-nodejs:0.1 --env FILTER='event.type == "com.magedu.file.text"' -n para	#text filter

--部署两个Subscriber
root@k8s-master01:~/knative-in-practise/eventing/flow/parallel-demo# kn service apply para-appender-image --image ikubernetes/appender --env MESSAGE=" - filetype/Image" -n para		#对应image filter
root@k8s-master01:~/knative-in-practise/eventing/flow/parallel-demo# kn service apply para-appender-text --image ikubernetes/appender --env MESSAGE=" - filetype/Text" -n para		   #对应text filter

--查看filter和subscriber
root@k8s-master01:~/knative-in-practise/eventing/flow/parallel-demo# kn service list -n para
NAME                  URL                                           LATEST                      AGE    CONDITIONS   READY   REASON
image-filter          http://image-filter.para.example.com          image-filter-00001          10m    3 OK / 3     True
para-appender-image   http://para-appender-image.para.example.com   para-appender-image-00001   43s    3 OK / 3     True
para-appender-text    http://para-appender-text.para.example.com    para-appender-text-00001    26s    3 OK / 3     True
text-filter           http://text-filter.para.example.com           text-filter-00001           6m5s   3 OK / 3     True

--部署event-display
root@k8s-master01:~/knative-in-practise/eventing/flow/parallel-demo# kn service apply event-display --image ikubernetes/event_display --port 8080 --scale-min 1 -n para
root@k8s-master01:~/knative-in-practise/eventing/flow/parallel-demo# kn service list -n para
NAME                  URL                                           LATEST                      AGE   CONDITIONS   READY   REASON
event-display         http://event-display.para.example.com         event-display-00001         24m   3 OK / 3     True
image-filter          http://image-filter.para.example.com          image-filter-00001          36m   3 OK / 3     True
para-appender-image   http://para-appender-image.para.example.com   para-appender-image-00001   26m   3 OK / 3     True
para-appender-text    http://para-appender-text.para.example.com    para-appender-text-00001    26m   3 OK / 3     True
text-filter           http://text-filter.para.example.com           text-filter-00001           31m   3 OK / 3     True

--部署Parallel
root@k8s-master01:~/knative-in-practise/eventing/flow/parallel-demo# cat 05-parallel.yaml
---
apiVersion: flows.knative.dev/v1
kind: Parallel
metadata:
  name: filetype-parallel
  namespace: para
spec:
  channelTemplate:
    apiVersion: messaging.knative.dev/v1
    kind: InMemoryChannel
  branches:
    - filter:
        ref:
          apiVersion: serving.knative.dev/v1
          kind: Service
          name: image-filter
      subscriber:
        ref:
          apiVersion: serving.knative.dev/v1
          kind: Service
          name: para-appender-image
    - filter:
        ref:
          apiVersion: serving.knative.dev/v1
          kind: Service
          name: text-filter
      subscriber:
        ref:
          apiVersion: serving.knative.dev/v1
          kind: Service
          name: para-appender-text
  reply:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: event-display
root@k8s-master01:~/knative-in-practise/eventing/flow/parallel-demo# kubectl apply -f 05-parallel.yaml
root@k8s-master01:~/knative-in-practise/eventing/flow/parallel-demo# kubectl get parallel -n para
NAME                URL                                                                      AGE   READY   REASON
filetype-parallel   http://filetype-parallel-kn-parallel-kn-channel.para.svc.cluster.local   17s   True

--测试image事件
curl -v "http://filetype-parallel-kn-parallel-kn-channel.para.svc.cluster.local" \
-X POST \
-H "Ce-Id: 00001" \
-H "Ce-Specversion: 1.0" \
-H "Ce-Type: com.magedu.file.image" \
-H "Ce-Source: curl" \
-H "Content-Type: application/json" \
-d '{"msg":"Hello Parallel"}'
root@k8s-master01:~/knative-in-practise/eventing/flow/parallel-demo# kubectl get pods -n para
NAME                                                   READY   STATUS    RESTARTS   AGE
event-display-00001-deployment-7b6fcdc5c5-vxz5x        2/2     Running   0          28m
image-filter-00001-deployment-77c8f866d4-ktlmp         2/2     Running   0          8s
para-appender-image-00001-deployment-c48b6dffd-mvbvp   0/2     Pending   0          0s
text-filter-00001-deployment-7f99c46b9f-g7bpk          2/2     Running   0          8s
root@k8s-master01:~/knative-in-practise/eventing/flow/parallel-demo# kubectl get pods -n para
NAME                                                   READY   STATUS    RESTARTS   AGE
event-display-00001-deployment-7b6fcdc5c5-vxz5x        2/2     Running   0          28m
image-filter-00001-deployment-77c8f866d4-ktlmp         2/2     Running   0          17s
para-appender-image-00001-deployment-c48b6dffd-mvbvp   2/2     Running   0          9s
text-filter-00001-deployment-7f99c46b9f-g7bpk          2/2     Running   0          17s
root@k8s-master01:~/knative-in-practise/eventing/flow/parallel-demo# kubectl logs event-display-00001-deployment-7b6fcdc5c5-vxz5x -c user-container -n para	#显示image事件
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: com.magedu.file.image
  source: curl
  id: 00001
  time: 2022-05-11T09:29:54.096246266Z
  datacontenttype: application/json
Data,
  {
    "id": 0,
    "message": " - filetype/Image"
  }
--测试text事件
curl -v "http://filetype-parallel-kn-parallel-kn-channel.para.svc.cluster.local" \
-X POST \
-H "Ce-Id: 00002" \
-H "Ce-Specversion: 1.0" \
-H "Ce-Type: com.magedu.file.text" \
-H "Ce-Source: curl" \
-H "Content-Type: application/json" \
-d '{"msg":"Hello Parallel"}'
root@k8s-master01:~/knative-in-practise/eventing/flow/parallel-demo# kubectl logs event-display-00001-deployment-7b6fcdc5c5-vxz5x -c user-container -n para	#查看日志事件
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: com.magedu.file.image
  source: curl
  id: 00001
  time: 2022-05-11T09:29:54.096246266Z
  datacontenttype: application/json
Data,
  {
    "id": 0,
    "message": " - filetype/Image"
  }
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: com.magedu.file.text
  source: curl
  id: 00002
  time: 2022-05-11T09:31:36.080515572Z
  datacontenttype: application/json
Data,
  {
    "id": 0,
    "message": " - filetype/Text"	#接收到text事件了
  }


####kafka与Eventing
#Knative Eventing 与 Kafka
- Knative Eventing中的Kafka存在三类组件,它们彼此间不存在依赖关系,各自可独立用于同Eventing中的其它组件协同，唯一的例外是，KafkaBroker依赖于KafkaChannel。
  - KafkaSource
    - 负责从Kafka集群中读取消息,并转换为CloudEvents后引入到Eventing之中
  - KafkaChannel
    - Knative Eventing Channel的实现之一
    - 功能与InMemoryChannel类似，但能够提供持久化等功能，是生产环境中推荐使用的类型
  - KafkaBroker
    - Knative Eventing Broker的实现之一，功能与MT-Channel-Based Broker功能类似;
    - 依赖于KafkaChannel类型的Channel实现

#kafka概念
broker----kafka节点
topic----相关于queue
partition----对一个topic进行分布，并且根据复制因子分布在各个broker节点之上

#部署Kafka
- Kafka集群的部署途径
  - Knative Eventing中的三类Kafka组件，在其后端都依赖于一个正常运行着的Kafka集群
  - Strimzi项目中的Kafka-Operator是专用于在Kubernetes集群上管理Kafka集群的Operator,它能够大大简化在Kubernetes上部署和使用Kafka的复杂度
- 部署kafka-operator
  - 创建专用的名称空间，例如kafka：kubectl create namespace kafka
  - 基于配置文件部署strimzi-cluster-operator
    - kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka
  - 查看部署的结果
    - kubectl get pods -l strimzi.io/kind=cluster-operator -n kafka
  - 查看生成的CRD
    - kubectl api-resources --api-group='kafka.strimzi.io'
- 部署Kafka示例集群
  - 为帮忙用户基于Kafka CRD快速部署Kafka集群,Strimzi提供了几个示例配置
    - kafka-ephemeral-single.yaml：非持久化存储，单节点集群；
    - kafka-ephemeral.yaml：非持久化存储，多节点集群；
    - kafka-jbod.yaml：jbod存储，多节点集群；
    - kafka-persistent-single.yaml：持久化存储，单节点集群；
    - kafka-persistent.yaml ：持久化存储，多节点集群；
  - 以定义了单节点、临时存储集群的kafka-ephemeral-single配置为例（这里采用目前最新的0.28.0版本）
    - kubectl apply -f https://github.com/strimzi/strimzi-kafka-operator/blob/0.28.0/examples/kafka/kafka-ephemeral-single.yaml
  - 等待集群部署完成
    - kubectl wait kafka/my-cluster --for=condition=Ready --timeout=300s -n kafka
  - 部署集群时,还会自动为集群生成几个相关的Service资源，其中的bootstrap是集群消息服务的访问端点，如下面示例中的my-cluster-kafka-bootstrap
    - kubectl get svc -n kafka

#KafkaSource 和 KafkaChannel
- 部署KafkaSource
  - KafkaSource负责将Kafka中的消息记录转为CloudEvents
  - 仅在需要从Kafka中加载消息并提供给Knative Eventing上的应用程序使用时才需要KafkaSource
  - 命令：kubectl apply -f https://storage.googleapis.com/knative-nightly/eventing-kafka/latest/source.yaml
    - 上面的部署操作，将会在knative-eventing名称空间中创建一组资源，其中会存在一个名称前缀为kafka-controller-manager的Pod资源
- 部署KafkaChannel
  - 负责在Knative Eventing上提供基于Kafka集群的Channel实现，后端基于Kafka Topic
  - 两种实现，它们分别定义在不同的资源配置文件
    - Consolidated Channel（channel-consolidated.yaml）：Knative KafkaChannel的原生实现；
    - Distributed Channel（channel-distributed.yaml）：由SAP的Kyma项目提供的KafkaChannel实现，
    - 提示：无论哪种配置，都需要将配置文件中的“REPLACE_WITH_CLUSTER_URL”替换为前面部署的Kafka集群的访问入口，例如“my-cluster-kafka-bootstrap.kafka:9092”
  - 以Consolidated Channel为例
    - kubectl apply -f https://storage.googleapis.com/knative-nightly/eventing-kafka/latest/channel-consolidated.yaml

#配置默认Channel
- Knative Eventing可以为Kubernetes Cluster或Namespace指定默认要使用的Channel类型
apiVersion: v1
kind: ConfigMap
metadata:
  name: default-ch-webhook
  namespace: knative-eventing
data:
  default-ch-config: |
    clusterDefault:
      apiVersion: messaging.knative.dev/v1
      kind: InMemoryChannel
    namespaceDefaults:
      default:
        apiVersion: messaging.knative.dev/v1beta1
        kind: KafkaChannel
        spec:
          numPartitions: 5
          replicationFactor: 1
---
注：clusterDefault配置段，指定了在Cluster级别使用InMemoryChannel作为默认的Channel类型；
注：namespaceDefaults配置段，指定了在event-demo这一特定的名称空间上使用KafkaChannel作为默认的Channel类型；该配置段可重复定义多次，以分别为不同的名称空间指定配置


#Knative Eventing上的KafkaBroker
- 关于KafkaBroker
  - Knative Kafka Broker是Apache Kafka针对Knative Broker API的原生实现
  - 它支持Kafka的任意版本，并且在与Broker/Trigger模型集成时有着更好的表现
  - 几个关键特性
    - Control plane High Availability
    - Horizontally scalable data plane
    - Extensively configurable
    - Ordered delivery of events based on CloudEvents partitioning extension
    - Support any Kafka version 
- 部署KafkaBroker
  - 首先,部署Kafka Broker相关的Kafka Controller
    - kubectl apply --filename https://github.com/knative-sandbox/eventing-kafka-broker/releases/download/knative-v1.2.0/eventing-kafka-controller.yaml
  - 而后,部署Kafka Broker的数据平面
    - kubectl apply --filename https://github.com/knative-sandbox/eventing-kafka-broker/releases/download/knative-v1.2.0/eventing-kafka-broker.yaml
  - 上面的部署步骤会于knative-eventing名称空间下创建kafka-controller、kafka-broker-receiver、kafka-broker-dispatcher和kafka-webhook-eventing几个应用相关的Deploymen

#配置Kafka Broker
- Kafka Broker的诸多配置都保存于knative-eventing名称空间下的多个相关ConfigMap资源中
  - kafka-broker-config
  - kafka-broker-brokers-triggers
  - kafka-channel-config
  - kafka-channel-channels-subscriptions
  - kafka-channel-config
  - kafka-config-logging
  - kafka-sink-sinks
  - kafka-source-sources
- 其中，kafka-broker-config中有三个关键参数
  - bootstrap.servers
    - 即Kafka集群的Bootstrap Server的访问入口,例如,对于前面基于Strimzi Operator在Kafka名称空间下部署Kafka集群my-cluster来说,其访问入口就是service资源my-cluster-kafka-bootstrap:9092；
  - default.topic.partitions
    - 在Topic上默认使用的partition的数量,默认为10；
  - default.topic.replication.factor
    - 在Topic上默认使用的复制因子，其值不能大于Kafka上的broker数量,即可用节点数，默认值为“3”；

#配置默认的Broker
- Knative Eventing可以为Kubernetes Cluster或Namespace指定默认要使用的Broker类别（class）
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-br-defaults
  namespace: knative-eventing
data:
  default-br-config: |
    clusterDefault:
      brokerClass: MTChannelBasedBroker
      apiVersion: v1
      kind: ConfigMap
      name: config-br-default-channel
      namespace: knative-eventing
      delivery:
        retry: 10
        backoffPolicy: exponential
        backoffDelay: PT0.2S
    namespaceDefaults:
      event-demo:
        brokerClass: Kafka
        apiVersion: v1
        kind: ConfigMap
        name: kafka-broker-config
        namespace: knative-eventing
---
注：clusterDefault配置段，指定了在Cluster级别使用MTChannelBasedBroker作为默认的Broker类别；
注：namespaceDefaults配置段，指定了在event-demo这一特定的名称空间上使用Kafka作为默认的Broker类别；该配置段可重复定义多次，以分别为不同的名称空间指定配置





###部署步骤

#部署kafka-operator
root@k8s-master01:~# kubectl create ns kafka
namespace/kafka created
root@k8s-master01:~# kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka
root@k8s-master01:~# kubectl get pods -l strimzi.io/kind=cluster-operator -n kafka
NAME                                        READY   STATUS    RESTARTS   AGE
strimzi-cluster-operator-7599bc57cb-87n5v   1/1     Running   0          55m

root@k8s-master01:~/knative-in-practise/eventing/kafka/01-create-kafka-cluster# kubectl api-resources --api-group='kafka.strimzi.io'
NAME                 SHORTNAMES   APIVERSION                 NAMESPACED   KIND
kafkabridges         kb           kafka.strimzi.io/v1beta2   true         KafkaBridge
kafkaconnectors      kctr         kafka.strimzi.io/v1beta2   true         KafkaConnector
kafkaconnects        kc           kafka.strimzi.io/v1beta2   true         KafkaConnect
kafkamirrormaker2s   kmm2         kafka.strimzi.io/v1beta2   true         KafkaMirrorMaker2
kafkamirrormakers    kmm          kafka.strimzi.io/v1beta2   true         KafkaMirrorMaker
kafkarebalances      kr           kafka.strimzi.io/v1beta2   true         KafkaRebalance
kafkas               k            kafka.strimzi.io/v1beta2   true         Kafka
kafkatopics          kt           kafka.strimzi.io/v1beta2   true         KafkaTopic
kafkausers           ku           kafka.strimzi.io/v1beta2   true         KafkaUser
#部署Kafka示例集群
#root@k8s-master01:~# kubectl apply -f https://github.com/strimzi/strimzi-kafkaoperator/blob/0.28.0/examples/kafka/kafka-ephemeral-single.yaml -n kafka
root@k8s-master01:~/knative-in-practise/eventing/kafka/01-create-kafka-cluster#kubectl apply -f 02-kafka-ephemeral-single.yaml #生产应使用高可用持久化存储版
root@k8s-master01:~# kubectl get pods -n kafka
NAME                                          READY   STATUS    RESTARTS   AGE
my-cluster-entity-operator-67cbb8f86f-xkkg7   3/3     Running   0          51s	#kafka和zookeeper组成的集群管理器
my-cluster-kafka-0                            1/1     Running   0          87s	#单kafka节点，无状态
my-cluster-zookeeper-0                        1/1     Running   0          68m	#zookeeper集群节点，奇数个
my-cluster-zookeeper-1                        1/1     Running   0          115s
my-cluster-zookeeper-2                        1/1     Running   0          68m
strimzi-cluster-operator-7599bc57cb-87n5v     1/1     Running   0          142m

root@k8s-master01:~# kubectl get kafka -n kafka
NAME         DESIRED KAFKA REPLICAS   DESIRED ZK REPLICAS   READY   WARNINGS
my-cluster   1                        3                     True    True

root@k8s-master01:~# kubectl get svc -n kafka
NAME                          TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                               AGE
my-cluster-kafka-bootstrap    ClusterIP   10.68.2.27     <none>        9091/TCP,9092/TCP,9093/TCP            3m6s
my-cluster-kafka-brokers      ClusterIP   None           <none>        9090/TCP,9091/TCP,9092/TCP,9093/TCP   3m6s
my-cluster-zookeeper-client   ClusterIP   10.68.48.207   <none>        2181/TCP                              70m
my-cluster-zookeeper-nodes    ClusterIP   None           <none>        2181/TCP,2888/TCP,3888/TCP            70m

#测试创建一个Kafka Topic
root@k8s-master01:~/knative-in-practise/eventing/kafka/01-create-kafka-cluster# cat 03-topic.yaml
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: my-topic
  labels:
    strimzi.io/cluster: my-cluster
spec:
  partitions: 3
  replicas: 1
root@k8s-master01:~/knative-in-practise/eventing/kafka/01-create-kafka-cluster# kubectl apply -f 03-topic.yaml 
root@k8s-master01:~/knative-in-practise/eventing/kafka/01-create-kafka-cluster# kubectl get kafkatopic 
NAME       CLUSTER      PARTITIONS   REPLICATION FACTOR   READY
my-topic   my-cluster   3            1

#测试使用Kafka集群
--在一个终端上，运行如下命令，向Kafka集群my-cluster上的topic/my-topic（不存在时，会自动创建）发送测试消息；
root@k8s-master01:~# kubectl run kafka-producer -it --image=quay.io/strimzi/kafka:0.28.0-kafka-3.1.0 --rm --restart=Never -n kafka -- bin/kafka-console-producer.sh --broker-list my-cluster-kafka-bootstrap:9092 --topic my-topic
If you don't see a command prompt, try pressing enter.
>Hello Kafka!	#生成的信息
--另启一个终端，运⾏如下命令，从topic/my-topic获取消息：
root@k8s-master01:~# kubectl run kafka-consumer -it --image=quay.io/strimzi/kafka:0.28.0-kafka-3.1.0 --rm --restart=Never -n kafka -- bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --topic my-topic --from-beginning
If you don't see a command prompt, try pressing enter.
Hello Kafka!	#获取到的信息

##在Eventing中使用Kafka

#部署Kafka Source
#kubectl apply -f https://storage.googleapis.com/knative-nightly/eventing-kafka/latest/source.yaml
root@k8s-master01:~/knative-in-practise/eventing/kafka/02-deploy-kafka-channel# ll
total 120
drwxr-xr-x 2 root root    96 May  8 15:03 ./
drwxr-xr-x 7 root root   145 May  8 15:03 ../
-rw-r--r-- 1 root root 19731 May  8 15:03 01-source.yaml
-rw-r--r-- 1 root root 41076 May  8 15:03 02-channel-consolidated.yaml
-rw-r--r-- 1 root root 53523 May  8 15:03 channel-distributed.yaml
root@k8s-master01:~/knative-in-practise/eventing/kafka/02-deploy-kafka-channel# kubectl apply -f 01-source.yaml
root@k8s-master01:~/knative-in-practise/eventing/kafka/02-deploy-kafka-channel# kubectl api-resources | grep kafkasource
kafkasources                                      sources.knative.dev/v1beta1                 true         KafkaSource

root@k8s-master01:~/knative-in-practise/eventing/kafka/02-deploy-kafka-channel# kubectl get pods -n knative-eventing | grep kafka
kafka-controller-manager-c4c6c7c6c-g9gz4   1/1     Running   0          2m49s
root@k8s-master01:~/knative-in-practise/eventing/kafka/02-deploy-kafka-channel# kubectl get svc -n knative-eventing | grep kafka-
kafka-controller          ClusterIP   10.68.171.168   <none>        443/TCP                     3m
kafka-source-webhook      ClusterIP   10.68.111.161   <none>        443/TCP                     3m


#部署Kafka Channel
--以下Kafka Channel中，"Consolidated" Channel和"Distributed" Channel两者仅能部署一个。
注意：需要事先将如下文件中的REPLACE_WITH_CLUSTER_URL替换为Kafka服务的访问入口，例如“my-cluster-kafka-bootstrap.kafka:9092”
kubectl apply -f https://storage.googleapis.com/knative-nightly/eventing-kafka/latest/channel-consolidated.yaml
或者，直接运行类似如下命令
curl -L "https://storage.googleapis.com/knative-nightly/eventing-kafka/latest/channel-consolidated.yaml" \
| sed 's/REPLACE_WITH_CLUSTER_URL/my-cluster-kafka-bootstrap.kafka:9092/' \
| kubectl apply -f -
-- 注意：需要事先将如下文件件中的REPLACE_WITH_CLUSTER_URL替换为Kafka服务的访问入口
root@k8s-master01:~/knative-in-practise/eventing/kafka/02-deploy-kafka-channel# kubectl apply -f channel-distributed.yaml
root@k8s-master01:~/knative-in-practise/eventing/kafka/02-deploy-kafka-channel# kubectl get pods -n knative-eventing | grep kafka- | sort -k 5
kafka-webhook-84fd44d488-ns597                       1/1     Running   0          101s	#刚创建的2个channel相关pod
kafka-ch-controller-66b554d68d-s5x8r			     1/1     Running   0          102s
root@k8s-master01:~/knative-in-practise/eventing/kafka/02-deploy-kafka-channel# kubectl get svc -n knative-eventing | grep kafka- 
kafka-webhook             ClusterIP   10.68.188.242   <none>        443/TCP                     16s

-- 而且API群组messaging.knative.dev之中会生成KafkaChannel CRD
root@k8s-master01:~/knative-in-practise/eventing/kafka/02-deploy-kafka-channel# kubectl api-resources --api-group='messaging.knative.dev'
NAME               SHORTNAMES   APIVERSION                      NAMESPACED   KIND
kafkachannels      kc           messaging.knative.dev/v1beta1   true         KafkaChannel	#刚创建的kafkachannel


#配置默认的Channel
root@k8s-master01:~/knative-in-practise/eventing/kafka/03-channel-defaults# cat default-channel-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: default-ch-webhook
  namespace: knative-eventing
data:
  default-ch-config: |
    clusterDefault:
      apiVersion: messaging.knative.dev/v1
      kind: InMemoryChannel
    namespaceDefaults:
      default:
        apiVersion: messaging.knative.dev/v1beta1
        kind: KafkaChannel
        spec:
          numPartitions: 5
          replicationFactor: 1
root@k8s-master01:~/knative-in-practise/eventing/kafka/03-channel-defaults# kubectl apply -f default-channel-config.yaml
注：将配置应用于集群之上，将会在default名称空间上，将KafkaChannel作为默认的Channel类型。但集群级别，默认的Channel类型仍是InMemoryChannel
root@k8s-master01:~/knative-in-practise/eventing/kafka/03-channel-defaults# kubectl get pods -n knative-eventing | grep kafka-ch-
kafka-ch-controller-66b554d68d-s5x8r       1/1     Running             0          19m
kafka-ch-dispatcher-6b469cc56b-5vwj7       0/1     ContainerCreating   0          54s

#测试，根据此前的配置，在default名称空间创建的Channel，将会自动使用KafkaChannel。
root@k8s-master01:~/knative-in-practise/eventing/kafka/03-channel-defaults# kn channel create kafka01
Channel 'kafka01' created in namespace 'default'.
root@k8s-master01:~/knative-in-practise/eventing/kafka/03-channel-defaults# kn channel list
NAME      TYPE           URL                                                   AGE     READY   REASON
kafka01   KafkaChannel   http://kafka01-kn-channel.default.svc.cluster.local   8m49s   True	#表示创建成功channel，之前配置显示数据平面不可用，最后将K8s删除重新部署后解决。问题重点


###使用KafkaChannel传输CloudEvents

#curl source生成CloudEvents发送到KafkaChanne
示例环境：Curl (生成Event) --> KafkaChannel <-- Subscription --> Sink (kservice/event-display)
-- 首先准备KService/event-display
root@k8s-master01:~/knative-in-practise/eventing/kafka# kn service create event-display --image ikubernetes/event_display --port 8080 --scale-min 1
root@k8s-master01:~/knative-in-practise/eventing/kafka# kn service list
NAME            URL                                        LATEST                AGE    CONDITIONS   READY   REASON
event-display   http://event-display.default.example.com   event-display-00001   4m4s   3 OK / 3     True

-- 设定kservice/event-display订阅前⾯在default名称空间下创建的kafkachannel/kafka01。
root@k8s-master01:~/knative-in-practise/eventing/kafka# kn subscription create ed-to-kafka01 --channel kafka01 --sink ksvc:event-display:default
Subscription 'ed-to-kafka01' created in namespace 'default'.
root@k8s-master01:~/knative-in-practise/eventing/kafka# kn subscription list
NAME            CHANNEL           SUBSCRIBER           REPLY   DEAD LETTER SINK   READY   REASON
ed-to-kafka01   Channel:kafka01   ksvc:event-display                              True
注：需要特别说明的是，如果引用的是某个kafkachannel，而kafkachannel并不是默认的Channel类型时，可以使用完全格式的名称对其进行引用，格式为“Group:Version:Kind:Name”(e.g. 'messaging.knative.dev:v1alpha1:KafkaChannel:mychannel').

-- 接下来，我们可以创建Event，并发往该KafkaChannel/kafka01
root@k8s-master01:~/knative-in-practise/eventing/kafka# kubectl run client-$RANDOM --image=ikubernetes/admin-box:v1.2 --restart=Never --rm -it --command -- /bin/bash
curl -v "http://kafka01-kn-channel.default.svc.cluster.local" \
-X POST \
-H "Ce-Id: 0" \
-H "Ce-Specversion: 1.0" \
-H "Ce-Type: com.magedu.file.image" \
-H "Ce-Source: Curl" \
-H "Content-Type: application/json" \
-d '{"message": "An Event to KafkaChannel"}'
root@client-25149 /# curl -v "http://kafka01-kn-channel.default.svc.cluster.local" \
> -X POST \
> -H "Ce-Id: 0" \
> -H "Ce-Specversion: 1.0" \
> -H "Ce-Type: com.magedu.file.image" \
> -H "Ce-Source: Curl" \
> -H "Content-Type: application/json" \
> -d '{"message": "An Event to KafkaChannel"}'
Note: Unnecessary use of -X or --request, POST is already inferred.
*   Trying 10.68.135.117:80...
* TCP_NODELAY set
* Connected to kafka01-kn-channel.default.svc.cluster.local (10.68.135.117) port 80 (#0)
> POST / HTTP/1.1
> Host: kafka01-kn-channel.default.svc.cluster.local
> User-Agent: curl/7.67.0
> Accept: */*
> Ce-Id: 0
> Ce-Specversion: 1.0
> Ce-Type: com.magedu.file.image
> Ce-Source: Curl
> Content-Type: application/json
> Content-Length: 39
>
* upload completely sent off: 39 out of 39 bytes
* Mark bundle as not supporting multiuse
< HTTP/1.1 202 Accepted
< Allow: POST, OPTIONS
< Date: Sat, 14 May 2022 09:14:43 GMT
< Content-Length: 0
<
* Connection #0 to host kafka01-kn-channel.default.svc.cluster.local left intact
-- 随后，于另⼀终端上，获取kservice/event-display相关的Pod中的日志
root@k8s-node01:~# kubectl logs event-display-00001-deployment-56f88d66b7-lfk4r -c user-container
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: com.magedu.file.image
  source: Curl
  id: 0
  datacontenttype: application/json
Data,
  {
    "message": "An Event to KafkaChannel"
  }


##KafkaSource从Kafka集群到读取数据并将其转换为CloudEvents。
示例环境：Kafka Client --> Kafka Cluster --> KafkaSource --> KafkaChannel <-- Subscription --> Sink（kservice/event-display）
为了便于测试，我们将示例环境简化为：Kafka Client (生成event)--> Kafka Cluster --> KafkaSource --> Sink（kservice/event-display）
--首先，我们使用Strimzi Kafka项止提供的KafkaTopic CRD在Kafka集群my-cluster上创建一个Topic。
root@k8s-master01:~/knative-in-practise/eventing/kafka/04-kafkasource-demo# cat 01-kafka-topic-demo.yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  name: topic01
  labels:
    strimzi.io/cluster: my-cluster
spec:
  partitions: 5
  replicas: 1
root@k8s-master01:~/knative-in-practise/eventing/kafka/04-kafkasource-demo# kubectl apply -f 01-kafka-topic-demo.yaml
kafkatopic.kafka.strimzi.io/topic01 created
root@k8s-master01:~/knative-in-practise/eventing/kafka/04-kafkasource-demo# kubectl get KafkaTopic
NAME      CLUSTER      PARTITIONS   REPLICATION FACTOR   READY
topic01   my-cluster   5            1

--接着，创建一个KafkaSource资源，它读取Kafka集群my-cluster上的topic01中的数据项，并逐步完成向CloudEvent的转换。
root@k8s-master01:~/knative-in-practise/eventing/kafka/04-kafkasource-demo# cat 02-kafkasource-demo.yaml
apiVersion: sources.knative.dev/v1beta1
kind: KafkaSource
metadata:
  name: kafkasource-demo
  namespace: default
spec:
  consumerGroup: knative-group
  bootstrapServers:
   - my-cluster-kafka-bootstrap.kafka:9092
  topics:
   - topic01
  sink:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: event-display
root@k8s-master01:~/knative-in-practise/eventing/kafka/04-kafkasource-demo# kubectl apply -f 02-kafkasource-demo.yaml
root@k8s-master01:~/knative-in-practise/eventing/kafka/04-kafkasource-demo# kubectl get pods | grep kafkasource
NAME                                                              READY   STATUS    RESTARTS   AGE
kafkasource-kafkasource-demo-a697c159eb107cc85453c4c2ebdccn8k7d   1/1     Running   0          4m8s
-- 列出创建的KafkaSource资源，并等待其状态转为就绪。
root@k8s-master01:~/knative-in-practise/eventing/kafka/04-kafkasource-demo# kubectl get kafkasource
NAME               TOPICS        BOOTSTRAPSERVERS                            READY   REASON   AGE
kafkasource-demo   ["topic01"]   ["my-cluster-kafka-bootstrap.kafka:9092"]   True             4m45s
root@k8s-master01:~/knative-in-practise/eventing/kafka/04-kafkasource-demo# kn source list
NAME               TYPE          RESOURCE                           SINK                 READY
kafkasource-demo   KafkaSource   kafkasources.sources.knative.dev   ksvc:event-display   True
注：对应于每个KafkaSource资源对象，在同一名称空间下还会生成一个Pod对象，并且该类的Pod对象都会有一个标签“eventing.knative.dev/sourceName”，其值为隶属的KafkaSource资源的名称。

----测试
--下面启动一个测试用的Kafka集群客户端，向my-cluster集群上的topic01发送一些测试数据。
root@k8s-node01:~# kubectl run kafka-producer -it --image=quay.io/strimzi/kafka:0.28.0-kafka-3.1.0 --rm=true --restart=Never -- bin/kafka-console-producer.sh --broker-list my-cluster-kafka-bootstrap.kafka:9092 --topic topic01
If you don't see a command prompt, try pressing enter.
>Hello kafkaSource!

--而后，另一个终端，到kservice/event-dispaly相关的Pod中验证是否有转换为CloudEvents的事件记录。
root@k8s-master01:~/knative-in-practise/eventing/kafka/04-kafkasource-demo# kn service list
NAME            URL                                        LATEST                AGE   CONDITIONS   READY   REASON
event-display   http://event-display.default.example.com   event-display-00001   24m   3 OK / 3     True
root@k8s-node02:~# POD_NAME=$(kubectl get pods -l serving.knative.dev/service=event-display -o jsonpath='{.items[0].metadata.name}')
root@k8s-node02:~# echo $POD_NAME
event-display-00001-deployment-56f88d66b7-lfk4r
root@k8s-node02:~# kubectl logs $POD_NAME -c user-container
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: dev.knative.kafka.event
  source: /apis/v1/namespaces/default/kafkasources/kafkasource-demo#topic01
  subject: partition:0#0
  id: partition:0/offset:0
  time: 2022-05-14T09:28:27.612Z
Data,
  Hello kafkaSource!



###Kafka Broker
Knative Kafka Broker，是Apache Kafka针对Knative Broker API的原生实现，它支持Kafka的任意版本，并且在与Broker/Trigger模型集成时有着更好的表现。比较典型的几个特点如下：
- Control plane High Availability
- Horizontally scalable data plane
- Extensively configurable
- Ordered delivery of events based on CloudEvents partitioning extension
- Support any Kafka version

#部署Kafka Broker
Kafka Broker是Knative Eventing的组件，需要单独部署使用。此外，它依赖于一个部署好的Eventing和Kafka集群。在满足依赖关系后即可以如下方式进行部署。
--首先，部署Kafka Broker相关的Kafka Controller。
#~$ kubectl apply --filename https://github.com/knative-sandbox/eventing-kafka-broker/releases/download/knative-v1.2.0/eventing-kafka-controller.yaml
root@k8s-master01:~/knative-in-practise/eventing/kafka/05-kafka-broker# ll
total 92
drwxr-xr-x 3 root root   230 May  8 15:03 ./
drwxr-xr-x 7 root root   145 May  8 15:03 ../
-rw-r--r-- 1 root root 58431 May  8 15:03 01-eventing-kafka-controller.yaml
-rw-r--r-- 1 root root 17623 May  8 15:03 02-eventing-kafka-broker.yaml
-rw-r--r-- 1 root root   399 May  8 15:03 03-configmap-kafka-broker-config.yaml
-rw-r--r-- 1 root root   572 May  8 15:03 04-default-channel-config.yaml
-rw-r--r-- 1 root root   585 May  8 15:03 05-configmap-default-br-config.yaml
drwxr-xr-x 2 root root   114 May  8 15:03 gitlabsource/
root@k8s-master01:~/knative-in-practise/eventing/kafka/05-kafka-broker# kubectl apply -f 01-eventing-kafka-controller.yaml
root@k8s-master01:~/knative-in-practise/eventing/kafka/05-kafka-broker# kubectl get pods -n knative-eventing 
kafka-controller-85496c8ddf-tw22q          1/1     Running 			   0          2m58s
kafka-webhook-eventing-5f89f44594-h8jd2    1/1     Running             0          2m58s


-- 而后，部署Kafka Broker的数据平面。
#~$ kubectl apply --filename https://github.com/knative-sandbox/eventing-kafka-broker/releases/download/knative-v1.2.0/eventing-kafka-broker.yaml
root@k8s-master01:~/knative-in-practise/eventing/kafka/05-kafka-broker# kubectl apply -f 02-eventing-kafka-broker.yaml

-- 上面部署步骤中的两个配置文件，会于knative-eventing名称空间下创建kafka-controller、kafka-broker-receiver、kafka-broker-dispatcher和kafka-webhook-eventing几个应用相关的Deployment。
root@k8s-master01:~/knative-in-practise/eventing/kafka/05-kafka-broker# kubectl get pods -n knative-eventing
kafka-broker-dispatcher-78dc5dfdf4-wgrk8   1/1     Running   0          114s
kafka-broker-receiver-64b5498c45-jzkjc     1/1     Running   0          114s


##配置Kafka Broker
Kafka Broker的诸多配置都保存于knative-eventing名称空间下的多个相关ConfigMap资源中。其中，configmap/kafka-broker-config中有三个关键参数：
- bootstrap.servers: 即Kafka集群的Bootstrap Server的访问入口，例如，对于前面基于Strimzi Operator在Kafka名称空间下部署Kafka集群my-cluster来说，其访问入口就是service资源my-cluster-kafka-bootstrap，其端口为9092，因此，完成的路径为my-cluster-kafka-bootstrap.kafka:9092；
- default.topic.partitions: 在Topic上默认使用的partition的数量，默认为10；
- default.topic.replication.factor: 在Topic上默认使用的复制因子，其值不能大于Kafka上的broker数量，即可用节点数，默认值为“3”；
- 考虑到我们前面部署的Kafka集群为单节点，因此，其Topic可使用的复制因子只能为"1"，这可以使用类似如下的ConfigMap配置来调整。（生产环境不建议如此操作）
root@k8s-master01:~/knative-in-practise/eventing/kafka/05-kafka-broker# cat 03-configmap-kafka-broker-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: kafka-broker-config
  namespace: knative-eventing
data:
  # Number of topic partitions
  default.topic.partitions: "10"
  # Replication factor of topic messages.
  default.topic.replication.factor: "1"
  # A comma separated list of bootstrap servers. (It can be in or out the k8s cluster)
  bootstrap.servers: "my-cluster-kafka-bootstrap.kafka:9092"
root@k8s-master01:~/knative-in-practise/eventing/kafka/05-kafka-broker# kubectl apply -f 03-configmap-kafka-broker-config.yaml

#配置默认的Channel和Broker类型
--因为在event-demo名称空间上创建KafkaBroker需要依赖KafkaChannel，需要首先配置为KafkaChannel
root@k8s-master01:~/knative-in-practise/eventing/kafka/05-kafka-broker# cat 04-default-channel-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: default-ch-webhook
  namespace: knative-eventing
data:
  default-ch-config: |
    clusterDefault:
      apiVersion: messaging.knative.dev/v1
      kind: InMemoryChannel
    namespaceDefaults:
      default:
        apiVersion: messaging.knative.dev/v1beta1
        kind: KafkaChannel
        spec:
          numPartitions: 5
          replicationFactor: 1
      event-demo:
        apiVersion: messaging.knative.dev/v1beta1
        kind: KafkaChannel
        spec:
          numPartitions: 5
          replicationFactor: 1
root@k8s-master01:~/knative-in-practise/eventing/kafka/05-kafka-broker# kubectl apply -f 04-default-channel-config.yaml

-- 事实上，Broker整合了Channel、Reply和Filter三类功能的单一资源，但在底层，它依然需要基于Channel完成数据的持久化。因而，创建Broker时，若未指定具体要使用的Channel类型，它将自动依次搜索并使用名称空间级别配置的默认Channel类型，以及Kubernetes集群级别配置默认要使用的Channel类型。MT-Channel-Based Broker支持使用InMemory Channel和Kafka Channel类型，但Kafka Broker则仅支持使用Kafka Channel。于是，为了便于快速创建Kafka Broker，我们可以使用前面“配置默认的Channel”一节中的配置，以及类似如下配置，在集群及特定的名称空间（event-demo）指定默认使用Kafka Broker。
root@k8s-master01:~/knative-in-practise/eventing/kafka/05-kafka-broker# cat 05-configmap-default-br-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-br-defaults
  namespace: knative-eventing
data:
  default-br-config: |
    clusterDefault:
      brokerClass: MTChannelBasedBroker
      apiVersion: v1
      kind: ConfigMap
      name: config-br-default-channel
      namespace: knative-eventing
      delivery:
        retry: 10
        backoffPolicy: exponential
        backoffDelay: PT0.2S
    namespaceDefaults:
      event-demo:
        brokerClass: Kafka
        apiVersion: v1
        kind: ConfigMap
        name: kafka-broker-config
        namespace: knative-eventing
root@k8s-master01:~/knative-in-practise/eventing/kafka/05-kafka-broker# kubectl apply -f 05-configmap-default-br-config.yaml


#在Eventing上使用KafkaBroker类型的Broker
假设前面已经设定了特定名称空间（event-demo）级别的默认Channel为KafkaChannel，随后即可按照配置，在特定名称空间下创建KafkaBroker资源。
root@k8s-master01:~/knative-in-practise/eventing/kafka/05-kafka-broker# kn broker create broker01 -n event-demo
注：如果不是在event-demo名称空间创建，需要加上参数 --class Kafka
root@k8s-master01:~/knative-in-practise/eventing/kafka/05-kafka-broker# kn broker list -n event-demo
NAME       URL                                                                                  AGE   CONDITIONS   READY   REASON
broker01   http://kafka-broker-ingress.knative-eventing.svc.cluster.local/event-demo/broker01   7s    7 OK / 7     True

--测试使用创建的KafkaBroker/broker01，示例环境：Curl (生成Event) --> KafkaBroker <-- Trigger --> Sink (kservice/event-display)
--于是，我们直接创建⼀个Trigger，关联⾄KafkaBroker/broker01，并将数据直接传递到default名称空间下的kservice/event-display。下⾯的命令中没有指定任何过滤条件，因而，发往KafkaBroker/broker01的所有事件，都将发往kservice/event-display。
root@k8s-master01:~/knative-in-practise/eventing/kafka/05-kafka-broker# kn trigger create trigger01 --broker broker01 --sink ksvc:event-display:default -n event-demo
root@k8s-master01:~/knative-in-practise/eventing/kafka/05-kafka-broker# kn trigger list -n event-demo
NAME        BROKER     SINK                 AGE   CONDITIONS   READY   REASON
trigger01   broker01   ksvc:event-display   11s   6 OK / 6     True

--创建Event，并发往该KafkaBroker/broker01
curl -v "http://kafka-broker-ingress.knative-eventing.svc.cluster.local/event-demo/broker01" \
-X POST \
-H "Ce-Id: 0" \
-H "Ce-Specversion: 1.0" \
-H "Ce-Type: com.magedu.file.image" \
-H "Ce-Source: Curl" \
-H "Content-Type: application/json" \
-d '{"message": "An Event to KafkaBroker"}'

root@k8s-node01:~# kubectl run client-$RANDOM --image=ikubernetes/admin-box:v1.2 --restart=Never --rm -it --command -- /bin/bash
root@client-4987 /# curl -v "http://kafka-broker-ingress.knative-eventing.svc.cluster.local/event-demo/broker01" \
> -X POST \
> -H "Ce-Id: 0" \
> -H "Ce-Specversion: 1.0" \
> -H "Ce-Type: com.magedu.file.image" \
> -H "Ce-Source: Curl" \
> -H "Content-Type: application/json" \
> -d '{"message": "An Event to KafkaBroker"}'
Note: Unnecessary use of -X or --request, POST is already inferred.
*   Trying 10.68.51.178:80...
* TCP_NODELAY set
* Connected to kafka-broker-ingress.knative-eventing.svc.cluster.local (10.68.51.178) port 80 (#0)
> POST /event-demo/broker01 HTTP/1.1
> Host: kafka-broker-ingress.knative-eventing.svc.cluster.local
> User-Agent: curl/7.67.0
> Accept: */*
> Ce-Id: 0
> Ce-Specversion: 1.0
> Ce-Type: com.magedu.file.image
> Ce-Source: Curl
> Content-Type: application/json
> Content-Length: 38
>
* upload completely sent off: 38 out of 38 bytes
* Mark bundle as not supporting multiuse
< HTTP/1.1 202 Accepted
< content-length: 0
<
* Connection #0 to host kafka-broker-ingress.knative-eventing.svc.cluster.local left intact

--随后，于另一终端上，获取kservice/event-display相关的Pod中的日志，查看其最后一个日志记录。
root@k8s-node02:~# kubectl logs $POD_NAME -c user-container
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: com.magedu.file.image
  source: Curl
  id: 0
  datacontenttype: application/json
Data,
  {
    "message": "An Event to KafkaBroker"
  }


</pre>