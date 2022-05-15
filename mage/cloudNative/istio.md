##istio
<pre>
- 提升可用性的策略（反脆弱）：弹性处理局部故障
  - 快速失败和故障转移
    - 超时并重新请求，由调度器将请求发往另一副本（冗余）
  - 优雅降级
    - 所有副本都故障时，"熔断"上游服务，当前应用以"降级"形式提供服务
  - 金丝雀发布
    - 变更是导致脆弱更重要的原因，任何服务上线新版本时都应该基于灰度模式进行
	
#Istio程序组件 
- istiod
- istio-ingressgateway
- istio-egressgateway
- Addons: grafana, prometheus, kiali(istio图形化接口)和zipkin/jaeger

#为什么要使用Istio
- Istio可以轻松创建带有负载均衡、service-to-service的身份认证、细粒度的可观测性等功能的服务网格，而应用程序代码却无须或很少而做出改变
- 通过整个服务环境中为每一个应用部署一个特殊的Sidecar形式的Proxy拦截各服务之间的所有网络通信，并由控制平面Istio进行配置和管理，进而为服务无侵入式添加如下功能
  - HTTP, gRPC, WebSocket和TCP通信的自动负载均衡
  - 通过丰富的路由规则、重试、故障转移和故障注入对流量进行细粒度控制
  - 支持访问控制、速率限制和配额的可插拔的策略层及配置API，在1.5版本后被弱化。
  - 集群内所有流量的自动度量、记录日志和分布式跟踪，包括集群的入口和出口
  - 强大身份验证和授权，以及在集群中进行安全的服务间通信
- 在Kubernetes环境中，服务网格就像一个仪表板，用于解决问题、执行流量策略、分配限制和测试代码，它允许一个中央节点来监视、跟踪和控制所有服务之间的交互

#istio系统架构 
- 从完整意义上讲，istio服务网格逻辑上分为数据平面和控制平面
  - istio: 控制平面，由多个组件组合完成控制机制
    - istio的控制面板在底层集群管理平台（如Kubernetes，Mesos等）上提供了一个抽象层
  - envoy：数据平面，以Sidercar的形式与服务进程运行在一起的智能代理Envoy，在Istio中被称为istio-proxy
- 迄今，Istio架构经历了三次重要变革
  - 2018年7月，Istio v1.0
	- 生产可用
  - 2019年3月，Istio v1.1
    - 完全分布式
  - 2020年3月，Istio v1.5
    - 回归单体
#istio v1.5
- 回归单体
  - 抛弃影响性能的Mixer, 遥测功能将由Envoy自行完成
  - 将Pilot, Citadel, Galley和Sidecar Injector整合为一个单体应用Istiod
- Istiod
  - Istiod充当控制平面，将配置分发到所有Sidecar代理和网关
  - 它能够为支持网络的应用实现智能化的负载均衡机制，且相关流量绕过了kube-proxy
 
#Pilot功能简介
- Pilot的功能
  - 服务发现
  - 配置Sidecar
  - 流量治理
    - A/B testing
	- Failover
	- Fault Injection
	- Canary rollout
	- Circuit breaker
	- Retries
	- Timeouts

#Citadel功能简介
- Citadel是Istio控制平面的核心安全组件，负责服务的私钥和数字证书管理，用于提供自动生成、分发、轮换及撤销私钥和数据证书的功能
  - Kubernetes平台上，Citadel的传统工作方式是基于Secret资源将证书及私钥注入到Sidecar容器中
  - 非容器环境中，首先通过系统上运行的Node Agent生成CSR，而后向Citadel发起证书签署请求，并将接收到的证书和私钥存储于本地文件系统提供给Envoy使用
  - Istio 1.1 版本起支持基于SDS API动态配置Secret给Envoy
- 另外，除了Istio的Citadel之外，还有Vault等其它证书和私钥管理系统可用
- Istio的安全模型需要多个组件协同工作
  - Citadel管理私钥和数字证书
  - Sidecar和perimeter proxies执行服务间的安全通信
  - Pilot向代理分发认证策略和名称信息
  
#Ingress Gateway和Egress Gateway
- Istio Gateway用于将Istio功能（例如，监控和路由规则）应用于进入服务网格的流量
  - 通过将Envoy代理部署在服务之前，运维人员可以针对面向用户的服务进行A/B测试、金丝雀部署等
  - Istio Gateway不同于Kubernetes Ingress
  - 类似地，有必要时，也可以部署专用的Egress Gateway，运维人员可以为这些服务添加超时控制、重试、断路器等功能，同时还能从服务连接中获取各种细节指标
- 程序文件istio-ingressgateway和istio-egressgateway是独立部署的
- gateway(入站Proxy定义的CR), serviceEntry(出站Proxy定义的CR)

#Istio可视化
- Grafana
- Kiali
  - Kiali提供以下功能
    - 服务拓扑图
	- 分布式跟踪
	- 指标度量收集和图标
	- 配置校验
	- 健康检查和显示

#基于Kubernetes CRD描述规则
- Istio的所有路由规则和控制策略都基于Kubernetes CRD实现，于是，其各种配置策略的定义也都保存于kube-apiserveer后端的存储etcd中
  - 这意味着kube-apiserver也就是Istio的APIServer
  - Galley负责从kube-apiserver加载配置并进行分发
- Istio提供了许多的CRD，它们大体可分为如下几类
  - Network相关：实现流量治理，例如VirtualService、DestinationRule、Gateway、ServiceEntry、Sidecar和EnvoyFilter等，它们都由Pilot使用
  - Security
    - 认证策略：Policy
	- 授权策略：Rule
	


#部署Istio控制平面--v1.12
- 控制平台：默认部署于istio-system名称空间
  - istiod
  - ingress-gateway（可选）
  - egress-gateway（可选）
  - Addons
    - Kiali
	- Prometheus
	- Grafana
	- Jaeger
- 数据平面：默认部署为某名称空间下的各Pod的sidecar Container
  - istio-proxy
- 部署方法
  - istioctl
    - Istio的专用管理工具，支持定制控制平面及数据平面
	- 通过命令行的选项支持完整的IstioOperatorAPI(内置install.isto API规范)
	- 命令行各选项可用于单独设备、以及接收包含IstioOperator自定义资源(CR)的yaml文件
	  - 各CR资源对应组件的升级等功能，需要由管理员手动进行
  - Istio Operator
    - Istio相关的自定义资源（CR）的专用控制器，负责自动维护由CR定义的资源对象
	- 管理员根据需要定义相应的CR配置文件，提交至Kubernetes APIServer后，即可由Operator完成相应的操作
  - helm
	- 基于特定的Chart，亦可由Helm安装及配置Istio
    - 截止目前，该功能仍处于alpha阶段
  - 提示
    - 各部署工具依赖的前提条件会有所不同，使用前，需要分别按照其实际要求事先进行准备
    - 各工具的部署操作，最终都要转换为Kubernetes的资源配置文件，并创建于集群上

#Istio内置的部署档案
- istioctl提供了内置配置文件（配置档案）用于快速部署
  - default：根据IstioOperator API的默认设置启用相关的组件，适用于生产环境
  - demo：会部署较多的组件，旨在演示istio的功能，适合运行Bookinfo一类的应用程序
  - minimal: 类似于default profile, 但仅部署控制平面组件
  - remote: 用于配置共享Control Plane的多集群环境
  - empty：不部署任何组件，通常帮助用户在自定义profile时生成基础配置信息
  - preview：包含预览性配置的profile，用于探索Istio的新功能，但不保证稳定性、安全性和性能
  - 提示：还有另外两种(external, openshift)，不常用，因此未罗列出来。主要使用前3种
- 配置档案
  - 各配置档案，事实上是IstioOperator API内置的特定CR格式的配置文件
    - CR名称：istiooperators
	- 所属的资源群组：install.istio.io/v1alpha1
  - 因此，各配置档案也是该资源类型下的资源对象的定义
- 了解内置的配置档案
  - ~$ istioctl profile list
  - ~$ istioctl profile dump [PROFILE]
    - 例如，打印default档案的资源配置信息
	   - ~$ istioctl profile dump default
	- ~$ istioctl profile diff PROFILE1 PROFILE2
- 内置的各profile默认启用的组件会有所不同
  - default: istiod, istio-ingressgateway
  - demo: istiod, istio-ingressgateway, istio-egressgateway
  - minimal: istiod

###正式部署istio  
1. k8s集群环境
root@k8s-master01:~# kubectl get nodes			
NAME            STATUS                     ROLES    AGE   VERSION
172.168.2.21    Ready,SchedulingDisabled   master   48d   v1.21.5
172.168.2.22    Ready,SchedulingDisabled   master   48d   v1.21.5
172.168.2.23    Ready,SchedulingDisabled   master   47d   v1.21.5
172.168.2.24    Ready                      node     48d   v1.21.5
172.168.2.25    Ready                      node     48d   v1.21.5
172.168.2.26    Ready                      node     47d   v1.21.5
192.168.13.63   Ready                      node     32d   v1.21.5

2. 部署istio
istio：https://istio.io/latest/docs/setup/getting-started/
2.1 下载1.12.0
root@k8s-master01:~# export HTTP_PROXY="http://172.168.2.29:8118"		--配置代理
root@k8s-master01:~# export HTTPS_PROXY="http://172.168.2.29:8118"
root@k8s-master01:~# curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.12.0 TARGET_ARCH=x86_64 sh -
root@k8s-master01:~# ls istio-1.12.0/
bin  LICENSE  manifests  manifest.yaml  README.md  samples  tools
root@k8s-master01:~# mv istio-1.12.0/ /usr/local/
root@k8s-master01:~# ln -sv /usr/local/istio-1.12.0/ /usr/local/istio
root@k8s-master01:/usr/local/istio# unset HTTPS_PROXY		#取消代理，以免内部集群报错
root@k8s-master01:/usr/local/istio# unset HTTP_PROXY
root@k8s-master01:/usr/local/istio# istioctl version
no running Istio pods in "istio-system"
1.12.0
Available Commands:
  admin                Manage control plane (istiod) configuration
  analyze              Analyze Istio configuration and print validation messages
  authz                (authz is experimental. Use `istioctl experimental authz`)
  bug-report           Cluster information and log capture support tool.
  completion           generate the autocompletion script for the specified shell
  create-remote-secret Create a secret with credentials to allow Istio to access remote Kubernetes apiservers
  dashboard            Access to Istio web UIs
  experimental         Experimental commands that may be modified or deprecated		#开启实验性命令，可简写为x, exp
  help                 Help about any command
  install              Applies an Istio manifest, installing or reconfiguring Istio on a cluster.
  kube-inject          Inject Istio sidecar into Kubernetes pod resources
  manifest             Commands related to Istio manifests
  operator             Commands related to Istio operator controller.
  profile              Commands related to Istio configuration profiles
  proxy-config         Retrieve information about proxy configuration from Envoy [kube only]
  proxy-status         Retrieves the synchronization status of each Envoy in the mesh [kube only]
  remote-clusters      Lists the remote clusters each istiod instance is connected to.
  tag                  Command group used to interact with revision tags
  upgrade              Upgrade Istio control plane in-place
  validate             Validate Istio policy and rules files
  verify-install       Verifies Istio Installation Status
  version              Prints out build version information
root@k8s-master01:/usr/local/istio# istioctl profile --help
Available Commands:
  diff        Diffs two Istio configuration profiles
  dump        Dumps an Istio configuration profile
  list        Lists available Istio configuration profiles
root@k8s-master01:/usr/local/istio# istioctl profile dump default
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  components:
    base:
      enabled: true
    cni:
      enabled: false
    egressGateways:
    - enabled: false
      name: istio-egressgateway
    ingressGateways:
    - enabled: true
      name: istio-ingressgateway
    istiodRemote:
      enabled: false
    pilot:
      enabled: true
  hub: docker.io/istio
  meshConfig:
    defaultConfig:
      proxyMetadata: {}
    enablePrometheusMerge: true
  profile: default
  tag: 1.12.0
  values:
    base:
      enableCRDTemplates: false
      validationURL: ""
    defaultRevision: ""
    gateways:
      istio-egressgateway:
        autoscaleEnabled: true
        env: {}
        name: istio-egressgateway
        secretVolumes:
        - mountPath: /etc/istio/egressgateway-certs
          name: egressgateway-certs
          secretName: istio-egressgateway-certs
        - mountPath: /etc/istio/egressgateway-ca-certs
          name: egressgateway-ca-certs
          secretName: istio-egressgateway-ca-certs
        type: ClusterIP
      istio-ingressgateway:
        autoscaleEnabled: true
        env: {}
        name: istio-ingressgateway
        secretVolumes:
        - mountPath: /etc/istio/ingressgateway-certs
          name: ingressgateway-certs
          secretName: istio-ingressgateway-certs
        - mountPath: /etc/istio/ingressgateway-ca-certs
          name: ingressgateway-ca-certs
          secretName: istio-ingressgateway-ca-certs
        type: LoadBalancer
    global:
      configValidation: true
      defaultNodeSelector: {}
      defaultPodDisruptionBudget:
        enabled: true
      defaultResources:
        requests:
          cpu: 10m
      imagePullPolicy: ""
      imagePullSecrets: []
      istioNamespace: istio-system
      istiod:
        enableAnalysis: false
      jwtPolicy: third-party-jwt
      logAsJson: false
      logging:
        level: default:info
      meshNetworks: {}
      mountMtlsCerts: false
      multiCluster:
        clusterName: ""
        enabled: false
      network: ""
      omitSidecarInjectorConfigMap: false
      oneNamespace: false
      operatorManageWebhooks: false
      pilotCertProvider: istiod
      priorityClassName: ""
      proxy:
        autoInject: enabled
        clusterDomain: cluster.local
        componentLogLevel: misc:error
        enableCoreDump: false
        excludeIPRanges: ""
        excludeInboundPorts: ""
        excludeOutboundPorts: ""
        image: proxyv2
        includeIPRanges: '*'
        logLevel: warning
        privileged: false
        readinessFailureThreshold: 30
        readinessInitialDelaySeconds: 1
        readinessPeriodSeconds: 2
        resources:
          limits:
            cpu: 2000m
            memory: 1024Mi
          requests:
            cpu: 100m
            memory: 128Mi
        statusPort: 15020
        tracer: zipkin
      proxy_init:
        image: proxyv2
        resources:
          limits:
            cpu: 2000m
            memory: 1024Mi
          requests:
            cpu: 10m
            memory: 10Mi
      sds:
        token:
          aud: istio-ca
      sts:
        servicePort: 0
      tracer:
        datadog: {}
        lightstep: {}
        stackdriver: {}
        zipkin: {}
      useMCP: false
    istiodRemote:
      injectionURL: ""
    pilot:
      autoscaleEnabled: true
      autoscaleMax: 5
      autoscaleMin: 1
      configMap: true
      cpu:
        targetAverageUtilization: 80
      enableProtocolSniffingForInbound: true
      enableProtocolSniffingForOutbound: true
      env: {}
      image: pilot
      keepaliveMaxServerConnectionAge: 30m
      nodeSelector: {}
      podLabels: {}
      replicaCount: 1
      traceSampling: 1
    telemetry:
      enabled: true
      v2:
        enabled: true
        metadataExchange:
          wasmEnabled: false
        prometheus:
          enabled: true
          wasmEnabled: false
        stackdriver:
          configOverride: {}
          enabled: false
          logging: false
          monitoring: false
          topology: false
		  
2.2 安装istio demo档案		  
root@k8s-master01:/usr/local/istio# istioctl install --set profile=demo -y
✔ Istio core installed
✔ Istiod installed
✔ Egress gateways installed
✔ Ingress gateways installed
✔ Installation complete

2.3 检查istio是否正常安装
root@k8s-master01:/usr/local/istio# istioctl x precheck		
✔ No issues found when checking the cluster. Istio is safe to install or upgrade!
  To get started, check out https://istio.io/latest/docs/setup/getting-started/
  
2.4 查看istio pod
root@k8s-master01:/usr/local/istio# kubectl get ns
NAME                   STATUS   AGE
default                Active   49d
ingress-nginx          Active   27d
istio-system           Active   4m12s		#默认会创建名称空间
kube-node-lease        Active   49d
kube-public            Active   49d
kube-system            Active   49d
kubernetes-dashboard   Active   47d
monitoring             Active   18d
root@k8s-master01:/usr/local/istio# kubectl get pods -n istio-system	#此时控制平面已经部署完成，但是数据平面还未部署
NAME                                   READY   STATUS    RESTARTS   AGE
istio-egressgateway-7f4864f59c-npp42   1/1     Running   0          3m15s		#egressgateway
istio-ingressgateway-55d9fb9f-lb2tw    1/1     Running   0          3m15s		#ingressgateway
istiod-555d47cb65-c2vc4                1/1     Running   0          3m59s		#istiod

2.5 部署kiali，kiali依赖prometheus,grafana,jaeger
root@k8s-master01:/usr/local/istio# ls samples/addons/
extras  grafana.yaml  jaeger.yaml  kiali.yaml  prometheus.yaml  README.md
root@k8s-master01:/usr/local/istio# kubectl apply -f samples/addons/	#开始部署kiali

2.6 将istio配置清单转换为kubernetes配置清单安装，可选方式
root@k8s-master01:/usr/local/istio# istioctl manifest generate --set profile=demo > istio-istall-manifest.yml
root@k8s-master01:/usr/local/istio# kubectl apply -f istio-istall-manifest.yml  #这样安装也行

2.7 卸载istio
- 使用istio命令卸载istio
  - istioctl experimental uninstall		#experimental可以简写为x
- 卸载方法
  - 卸载指定的控制平面
    - 卸载指定文件中定义的控制平面
	  - istioctl x uninstall -f <FILE>
	- 卸载指定的Revision
	  - istioctl x uninstall --revision <NAME>
	- 基于安装时的选项生成配置信息后经由kubectl命令删除
	  - istioctl manifest generate --set profile=demo | kubectl delete -f -
  - 清除集群上部署的所有控制平面
    - istioctl x uninstall --purge
- 提示：控制平面的名称空间默认并不会删除，如果确认不再需要时，需自行进行删除操作

2.8 配置特定名称空间以后自动注入envoy sidecar
root@k8s-master01:/usr/local/istio# kubectl label namespace default istio-injection=enabled		#对特定名称空间打上自动注入sidecar标签，取消则删除此标签即可
root@k8s-master01:/usr/local/istio# kubectl get namespace default --show-labels
NAME      STATUS   AGE   LABELS
default   Active   49d   istio-injection=enabled,kubernetes.io/metadata.name=default

2.9 测试是否自动注入sidecar envoy
root@k8s-master01:/usr/local/istio# kubectl run demoapp --image=ikubernetes/demoapp:v1.0 --restart=Never
root@k8s-master01:/usr/local/istio# kubectl get pods
NAME      READY   STATUS    RESTARTS   AGE
demoapp   2/2     Running   0          73s		#其实从这就可以看出来有两个容器，其中一个就是sidecar
root@k8s-master01:/usr/local/istio# kubectl get  pods demoapp -o yaml		#此可以可以查看到自动注入了sidecar envoy容器
 - args:
    - proxy
    - sidecar
    - --domain
    - $(POD_NAMESPACE).svc.cluster.local
    - --proxyLogLevel=warning
    - --proxyComponentLogLevel=misc:error
    - --log_output_level=default:info
    - --concurrency
    - "2"
    env:
    - name: JWT_POLICY
      value: third-party-jwt
    - name: PILOT_CERT_PROVIDER
      value: istiod
    - name: CA_ADDR
      value: istiod.istio-system.svc:15012
    - name: POD_NAME
      valueFrom:
        fieldRef:
          apiVersion: v1
          fieldPath: metadata.name
    - name: POD_NAMESPACE
      valueFrom:
        fieldRef:
          apiVersion: v1
          fieldPath: metadata.namespace
    - name: INSTANCE_IP
      valueFrom:
        fieldRef:
          apiVersion: v1
          fieldPath: status.podIP
    - name: SERVICE_ACCOUNT
      valueFrom:
        fieldRef:
          apiVersion: v1
          fieldPath: spec.serviceAccountName
    - name: HOST_IP
      valueFrom:
        fieldRef:
          apiVersion: v1
          fieldPath: status.hostIP
    - name: PROXY_CONFIG
      value: |
        {}
    - name: ISTIO_META_POD_PORTS
      value: |-
        [
        ]
    - name: ISTIO_META_APP_CONTAINERS
      value: demoapp
    - name: ISTIO_META_CLUSTER_ID
      value: Kubernetes
    - name: ISTIO_META_INTERCEPTION_MODE
      value: REDIRECT
    - name: ISTIO_META_WORKLOAD_NAME
      value: demoapp
    - name: ISTIO_META_OWNER
      value: kubernetes://apis/v1/namespaces/default/pods/demoapp
    - name: ISTIO_META_MESH_ID
      value: cluster.local
    - name: TRUST_DOMAIN
      value: cluster.local
    image: docker.io/istio/proxyv2:1.12.0		#sidecar envoy
    imagePullPolicy: IfNotPresent
    name: istio-proxy

2.10 curl命令测试pod
root@k8s-master01:/usr/local/istio# curl 172.20.217.80
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoapp, ServerIP: 172.20.217.80!		#客户端IP是127.0.0.6，就是sidecar地址，也就是自身被代理了
root@k8s-master01:/usr/local/istio# curl -I 172.20.217.80
HTTP/1.1 200 OK
content-type: text/html; charset=utf-8
content-length: 95
server: istio-envoy
date: Sat, 23 Apr 2022 04:07:46 GMT
x-envoy-upstream-service-time: 2		#envoy标头
x-envoy-decorator-operation: :0/*

2.11 进行容器通过admin接口查看listener
root@k8s-master01:/usr/local/istio# kubectl exec -it demoapp -- curl localhost:15000/listeners	#管理接口默认是15000
e535b5e1-b2da-49e2-878f-787efd9bb50f::0.0.0.0:15090		#下面都是service被istio转换为了Egress listener，所以有这么多listener，还将有自己的一个Ingress listener
e2b88a90-85ef-433f-a66d-469f29423bf2::0.0.0.0:15021
10.68.0.1_443::10.68.0.1:443
172.168.2.22_10250::172.168.2.22:10250
10.68.24.41_443::10.68.24.41:443
10.68.73.229_443::10.68.73.229:443
172.168.2.26_10250::172.168.2.26:10250
10.68.24.41_15012::10.68.24.41:15012
172.168.2.21_10250::172.168.2.21:10250
192.168.13.63_10250::192.168.13.63:10250
10.68.155.123_443::10.68.155.123:443
172.168.2.23_10250::172.168.2.23:10250
172.168.2.24_10250::172.168.2.24:10250
10.68.73.229_15443::10.68.73.229:15443
10.68.147.77_443::10.68.147.77:443
10.68.72.41_443::10.68.72.41:443
10.68.73.229_31400::10.68.73.229:31400
10.68.230.242_443::10.68.230.242:443
10.68.0.2_53::10.68.0.2:53
172.168.2.25_10250::172.168.2.25:10250
192.168.13.63_4194::192.168.13.63:4194
10.68.113.201_3000::10.68.113.201:3000
0.0.0.0_15014::0.0.0.0:15014
0.0.0.0_16685::0.0.0.0:16685
10.68.127.217_443::10.68.127.217:443
10.68.20.27_8000::10.68.20.27:8000
0.0.0.0_80::0.0.0.0:80
10.68.16.146_8080::10.68.16.146:8080
10.68.53.65_14268::10.68.53.65:14268
172.168.2.21_4194::172.168.2.21:4194
10.68.252.108_9090::10.68.252.108:9090
10.68.0.2_9153::10.68.0.2:9153
10.68.53.65_14250::10.68.53.65:14250
0.0.0.0_15010::0.0.0.0:15010
10.68.73.229_15021::10.68.73.229:15021
0.0.0.0_20001::0.0.0.0:20001
0.0.0.0_9090::0.0.0.0:9090
0.0.0.0_10255::0.0.0.0:10255
172.168.2.22_4194::172.168.2.22:4194
172.168.2.24_4194::172.168.2.24:4194
172.168.2.25_4194::172.168.2.25:4194
172.168.2.26_4194::172.168.2.26:4194
172.168.2.23_4194::172.168.2.23:4194
0.0.0.0_9411::0.0.0.0:9411
virtualOutbound::0.0.0.0:15001
virtualInbound::0.0.0.0:15006

2.12 进行容器通过admin接口查看cluster
root@k8s-master01:/usr/local/istio# kubectl exec -it demoapp -- curl localhost:15000/clusters	#listener对应的cluster，是istio中的pliod发现service并转换为istio的配置格式并通过xDS下发到envoy中的，所以有这么多cluster
BlackHoleCluster::observability_name::BlackHoleCluster
BlackHoleCluster::default_priority::max_connections::1024
BlackHoleCluster::default_priority::max_pending_requests::1024
BlackHoleCluster::default_priority::max_requests::1024
BlackHoleCluster::default_priority::max_retries::3
BlackHoleCluster::high_priority::max_connections::1024
BlackHoleCluster::high_priority::max_pending_requests::1024
BlackHoleCluster::high_priority::max_requests::1024
BlackHoleCluster::high_priority::max_retries::3
BlackHoleCluster::added_via_api::true
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::observability_name::outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::default_priority::max_connections::4294967295
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::default_priority::max_pending_requests::4294967295
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::default_priority::max_requests::4294967295
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::default_priority::max_retries::4294967295
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::high_priority::max_connections::1024
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::high_priority::max_pending_requests::1024
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::high_priority::max_requests::1024
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::high_priority::max_retries::3
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::added_via_api::true
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::172.20.217.75:31400::cx_active::0
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::172.20.217.75:31400::cx_connect_fail::0
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::172.20.217.75:31400::cx_total::0
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::172.20.217.75:31400::rq_active::0
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::172.20.217.75:31400::rq_error::0
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::172.20.217.75:31400::rq_success::0
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::172.20.217.75:31400::rq_timeout::0
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::172.20.217.75:31400::rq_total::0
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::172.20.217.75:31400::hostname::
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::172.20.217.75:31400::health_flags::healthy
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::172.20.217.75:31400::weight::1
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::172.20.217.75:31400::region::
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::172.20.217.75:31400::zone::
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::172.20.217.75:31400::sub_zone::
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::172.20.217.75:31400::canary::false
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::172.20.217.75:31400::priority::0
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::172.20.217.75:31400::success_rate::-1.0
outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local::172.20.217.75:31400::local_origin_success_rate::-1.0
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::observability_name::outbound|8080||kube-state-metrics.kube-system.svc.cluster.local
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::default_priority::max_connections::4294967295
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::default_priority::max_pending_requests::4294967295
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::default_priority::max_requests::4294967295
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::default_priority::max_retries::4294967295
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::high_priority::max_connections::1024
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::high_priority::max_pending_requests::1024
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::high_priority::max_requests::1024
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::high_priority::max_retries::3
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::added_via_api::true
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::172.20.217.71:8080::cx_active::0
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::172.20.217.71:8080::cx_connect_fail::0
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::172.20.217.71:8080::cx_total::0
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::172.20.217.71:8080::rq_active::0
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::172.20.217.71:8080::rq_error::0
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::172.20.217.71:8080::rq_success::0
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::172.20.217.71:8080::rq_timeout::0
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::172.20.217.71:8080::rq_total::0
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::172.20.217.71:8080::hostname::
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::172.20.217.71:8080::health_flags::healthy
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::172.20.217.71:8080::weight::1
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::172.20.217.71:8080::region::
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::172.20.217.71:8080::zone::
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::172.20.217.71:8080::sub_zone::
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::172.20.217.71:8080::canary::false
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::172.20.217.71:8080::priority::0
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::172.20.217.71:8080::success_rate::-1.0
outbound|8080||kube-state-metrics.kube-system.svc.cluster.local::172.20.217.71:8080::local_origin_success_rate::-1.0
...........

2.12 查看代理状态
root@k8s-master01:/usr/local/istio# istioctl proxy-status
NAME                                                  CDS        LDS        EDS        RDS          ISTIOD                      VERSION
demoapp.default                                       SYNCED     SYNCED     SYNCED     SYNCED       istiod-555d47cb65-c2vc4     1.12.0	#这个就是我们自己运行的pod，显示CDS, LDS, EDS, RDS状态都已经是SYNCED的，表示已经同步完成
istio-egressgateway-7f4864f59c-npp42.istio-system     SYNCED     SYNCED     SYNCED     NOT SENT     istiod-555d47cb65-c2vc4     1.12.0
istio-ingressgateway-55d9fb9f-lb2tw.istio-system      SYNCED     SYNCED     SYNCED     NOT SENT     istiod-555d47cb65-c2vc4     1.12.0

2.13 为pod创建一个service并关联到此pod
root@k8s-master01:/usr/local/istio# kubectl label pod demoapp app=demoapp	#给pod打开app=demoapp标签
root@k8s-master01:/usr/local/istio# kubectl create svc clusterip demoapp --tcp=80:80	#创建service，clusterip端口为80,容器端口为80，并且service默认会创建一个标签app=<自身service名称>的标签，所以上面我们给pod打上了标签，所以会自动关联到后端pod了
service/demoapp created
root@k8s-master01:/usr/local/istio# kubectl get svc
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
demoapp      ClusterIP   10.68.24.133   <none>        80/TCP    6s
kubernetes   ClusterIP   10.68.0.1      <none>        443/TCP   49d
root@k8s-master01:/usr/local/istio# kubectl describe svc demoapp
Name:              demoapp
Namespace:         default
Labels:            app=demoapp
Annotations:       <none>
Selector:          app=demoapp
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.68.24.133
IPs:               10.68.24.133
Port:              80-80  80/TCP
TargetPort:        80/TCP
Endpoints:         172.20.217.80:80		#已经成功关联到了
Session Affinity:  None
Events:            <none>

2.14 验证istio自动注入service到sidecar，并映射Egress listener和cluster,EDS
[root@demoapp /]# curl -s localhost:15000/listeners | grep 10.68.24.133
10.68.24.133_80::10.68.24.133:80
[root@demoapp /]# curl -s localhost:15000/clusters | grep demoapp
outbound|80||demoapp.default.svc.cluster.local::observability_name::outbound|80||demoapp.default.svc.cluster.local
outbound|80||demoapp.default.svc.cluster.local::default_priority::max_connections::4294967295
outbound|80||demoapp.default.svc.cluster.local::default_priority::max_pending_requests::4294967295
outbound|80||demoapp.default.svc.cluster.local::default_priority::max_requests::4294967295
outbound|80||demoapp.default.svc.cluster.local::default_priority::max_retries::4294967295
outbound|80||demoapp.default.svc.cluster.local::high_priority::max_connections::1024
outbound|80||demoapp.default.svc.cluster.local::high_priority::max_pending_requests::1024
outbound|80||demoapp.default.svc.cluster.local::high_priority::max_requests::1024
outbound|80||demoapp.default.svc.cluster.local::high_priority::max_retries::3
outbound|80||demoapp.default.svc.cluster.local::added_via_api::true
outbound|80||demoapp.default.svc.cluster.local::172.20.217.80:80::cx_active::0
outbound|80||demoapp.default.svc.cluster.local::172.20.217.80:80::cx_connect_fail::0
outbound|80||demoapp.default.svc.cluster.local::172.20.217.80:80::cx_total::0
outbound|80||demoapp.default.svc.cluster.local::172.20.217.80:80::rq_active::0
outbound|80||demoapp.default.svc.cluster.local::172.20.217.80:80::rq_error::0
outbound|80||demoapp.default.svc.cluster.local::172.20.217.80:80::rq_success::0
outbound|80||demoapp.default.svc.cluster.local::172.20.217.80:80::rq_timeout::0
outbound|80||demoapp.default.svc.cluster.local::172.20.217.80:80::rq_total::0
outbound|80||demoapp.default.svc.cluster.local::172.20.217.80:80::hostname::
outbound|80||demoapp.default.svc.cluster.local::172.20.217.80:80::health_flags::healthy
outbound|80||demoapp.default.svc.cluster.local::172.20.217.80:80::weight::1
outbound|80||demoapp.default.svc.cluster.local::172.20.217.80:80::region::
outbound|80||demoapp.default.svc.cluster.local::172.20.217.80:80::zone::
outbound|80||demoapp.default.svc.cluster.local::172.20.217.80:80::sub_zone::
outbound|80||demoapp.default.svc.cluster.local::172.20.217.80:80::canary::false
outbound|80||demoapp.default.svc.cluster.local::172.20.217.80:80::priority::0
outbound|80||demoapp.default.svc.cluster.local::172.20.217.80:80::success_rate::-1.0
outbound|80||demoapp.default.svc.cluster.local::172.20.217.80:80::local_origin_success_rate::-1.0

2.15 istioctl查看代理配置
root@k8s-master01:~# istioctl proxy-config --help
Available Commands:
  all            Retrieves all configuration for the Envoy in the specified pod
  bootstrap      Retrieves bootstrap configuration for the Envoy in the specified pod
  cluster        Retrieves cluster configuration for the Envoy in the specified pod
  endpoint       Retrieves endpoint configuration for the Envoy in the specified pod
  listener       Retrieves listener configuration for the Envoy in the specified pod
  log            (experimental) Retrieves logging levels of the Envoy in the specified pod
  rootca-compare Compare ROOTCA values for the two given pods
  route          Retrieves route configuration for the Envoy in the specified pod
  secret         Retrieves secret configuration for the Envoy in the specified pod
--查看LDS
root@k8s-master01:~# istioctl proxy-config listener demoapp
ADDRESS       PORT  MATCH                                                                    DESTINATION
10.68.0.2     53    ALL                                                                      Cluster: outbound|53||kube-dns.kube-system.svc.cluster.local
0.0.0.0       80    Trans: raw_buffer; App: HTTP                                             Route: 80
0.0.0.0       80    ALL                                                                      PassthroughCluster
10.68.24.133  80    Trans: raw_buffer; App: HTTP                                             Route: demoapp.default.svc.cluster.local:80	#ingress
10.68.24.133  80    ALL                                                                      Cluster: outbound|80||demoapp.default.svc.cluster.local #egress
10.68.0.1     443   ALL                                                                      Cluster: outbound|443||kubernetes.default.svc.cluster.local
10.68.127.217 443   Trans: raw_buffer; App: HTTP                                             Route: kubernetes-dashboard.kubernetes-dashboard.svc.cluster.local:443
10.68.127.217 443   ALL                                                                      Cluster: outbound|443||kubernetes-dashboard.kubernetes-dashboard.svc.cluster.local
10.68.147.77  443   ALL                                                                      Cluster: outbound|443||metrics-server.kube-system.svc.cluster.local
10.68.155.123 443   ALL                                                                      Cluster: outbound|443||ingress-nginx-controller.ingress-nginx.svc.cluster.local
10.68.230.242 443   ALL                                                                      Cluster: outbound|443||ingress-nginx-controller-admission.ingress-nginx.svc.cluster.local
10.68.24.41   443   ALL                                                                      Cluster: outbound|443||istiod.istio-system.svc.cluster.local
10.68.72.41   443   ALL                                                                      Cluster: outbound|443||istio-egressgateway.istio-system.svc.cluster.local
10.68.73.229  443   ALL                                                                      Cluster: outbound|443||istio-ingressgateway.istio-system.svc.cluster.local
10.68.113.201 3000  Trans: raw_buffer; App: HTTP                                             Route: grafana.istio-system.svc.cluster.local:3000
10.68.113.201 3000  ALL                                                                      Cluster: outbound|3000||grafana.istio-system.svc.cluster.local
172.168.2.21  4194  Trans: raw_buffer; App: HTTP                                             Route: kubelet.kube-system.svc.cluster.local:4194
172.168.2.21  4194  ALL                                                                      Cluster: outbound|4194||kubelet.kube-system.svc.cluster.local
172.168.2.22  4194  Trans: raw_buffer; App: HTTP                                             Route: kubelet.kube-system.svc.cluster.local:4194
172.168.2.22  4194  ALL                                                                      Cluster: outbound|4194||kubelet.kube-system.svc.cluster.local
172.168.2.23  4194  Trans: raw_buffer; App: HTTP                                             Route: kubelet.kube-system.svc.cluster.local:4194
172.168.2.23  4194  ALL                                                                      Cluster: outbound|4194||kubelet.kube-system.svc.cluster.local
172.168.2.24  4194  Trans: raw_buffer; App: HTTP                                             Route: kubelet.kube-system.svc.cluster.local:4194
172.168.2.24  4194  ALL                                                                      Cluster: outbound|4194||kubelet.kube-system.svc.cluster.local
172.168.2.25  4194  Trans: raw_buffer; App: HTTP                                             Route: kubelet.kube-system.svc.cluster.local:4194
172.168.2.25  4194  ALL                                                                      Cluster: outbound|4194||kubelet.kube-system.svc.cluster.local
172.168.2.26  4194  Trans: raw_buffer; App: HTTP                                             Route: kubelet.kube-system.svc.cluster.local:4194
172.168.2.26  4194  ALL                                                                      Cluster: outbound|4194||kubelet.kube-system.svc.cluster.local
192.168.13.63 4194  Trans: raw_buffer; App: HTTP                                             Route: kubelet.kube-system.svc.cluster.local:4194
192.168.13.63 4194  ALL                                                                      Cluster: outbound|4194||kubelet.kube-system.svc.cluster.local
10.68.20.27   8000  Trans: raw_buffer; App: HTTP                                             Route: dashboard-metrics-scraper.kubernetes-dashboard.svc.cluster.local:8000
10.68.20.27   8000  ALL                                                                      Cluster: outbound|8000||dashboard-metrics-scraper.kubernetes-dashboard.svc.cluster.local
10.68.16.146  8080  Trans: raw_buffer; App: HTTP                                             Route: kube-state-metrics.kube-system.svc.cluster.local:8080
10.68.16.146  8080  ALL                                                                      Cluster: outbound|8080||kube-state-metrics.kube-system.svc.cluster.local
0.0.0.0       9090  Trans: raw_buffer; App: HTTP                                             Route: 9090
0.0.0.0       9090  ALL                                                                      PassthroughCluster
10.68.252.108 9090  Trans: raw_buffer; App: HTTP                                             Route: prometheus.monitoring.svc.cluster.local:9090
10.68.252.108 9090  ALL                                                                      Cluster: outbound|9090||prometheus.monitoring.svc.cluster.local
10.68.0.2     9153  Trans: raw_buffer; App: HTTP                                             Route: kube-dns.kube-system.svc.cluster.local:9153
10.68.0.2     9153  ALL                                                                      Cluster: outbound|9153||kube-dns.kube-system.svc.cluster.local
0.0.0.0       9411  Trans: raw_buffer; App: HTTP                                             Route: 9411
0.0.0.0       9411  ALL                                                                      PassthroughCluster
172.168.2.21  10250 ALL                                                                      Cluster: outbound|10250||kubelet.kube-system.svc.cluster.local
172.168.2.22  10250 ALL                                                                      Cluster: outbound|10250||kubelet.kube-system.svc.cluster.local
172.168.2.23  10250 ALL                                                                      Cluster: outbound|10250||kubelet.kube-system.svc.cluster.local
172.168.2.24  10250 ALL                                                                      Cluster: outbound|10250||kubelet.kube-system.svc.cluster.local
172.168.2.25  10250 ALL                                                                      Cluster: outbound|10250||kubelet.kube-system.svc.cluster.local
172.168.2.26  10250 ALL                                                                      Cluster: outbound|10250||kubelet.kube-system.svc.cluster.local
192.168.13.63 10250 ALL                                                                      Cluster: outbound|10250||kubelet.kube-system.svc.cluster.local
0.0.0.0       10255 Trans: raw_buffer; App: HTTP                                             Route: 10255
0.0.0.0       10255 ALL                                                                      PassthroughCluster
10.68.53.65   14250 Trans: raw_buffer; App: HTTP                                             Route: jaeger-collector.istio-system.svc.cluster.local:14250
10.68.53.65   14250 ALL                                                                      Cluster: outbound|14250||jaeger-collector.istio-system.svc.cluster.local
10.68.53.65   14268 Trans: raw_buffer; App: HTTP                                             Route: jaeger-collector.istio-system.svc.cluster.local:14268
10.68.53.65   14268 ALL                                                                      Cluster: outbound|14268||jaeger-collector.istio-system.svc.cluster.local
0.0.0.0       15001 ALL                                                                      PassthroughCluster
0.0.0.0       15001 Addr: *:15001                                                            Non-HTTP/Non-TCP
0.0.0.0       15006 Addr: *:15006                                                            Non-HTTP/Non-TCP
0.0.0.0       15006 Trans: tls; App: istio-http/1.0,istio-http/1.1,istio-h2; Addr: 0.0.0.0/0 InboundPassthroughClusterIpv4
0.0.0.0       15006 Trans: raw_buffer; App: HTTP; Addr: 0.0.0.0/0                            InboundPassthroughClusterIpv4
0.0.0.0       15006 Trans: tls; App: TCP TLS; Addr: 0.0.0.0/0                                InboundPassthroughClusterIpv4
0.0.0.0       15006 Trans: raw_buffer; Addr: 0.0.0.0/0                                       InboundPassthroughClusterIpv4
0.0.0.0       15006 Trans: tls; Addr: 0.0.0.0/0                                              InboundPassthroughClusterIpv4
0.0.0.0       15006 Trans: tls; App: istio-http/1.0,istio-http/1.1,istio-h2; Addr: *:80      Cluster: inbound|80||
0.0.0.0       15006 Trans: raw_buffer; App: HTTP; Addr: *:80                                 Cluster: inbound|80||
0.0.0.0       15006 Trans: tls; App: TCP TLS; Addr: *:80                                     Cluster: inbound|80||
0.0.0.0       15006 Trans: raw_buffer; Addr: *:80                                            Cluster: inbound|80||
0.0.0.0       15006 Trans: tls; Addr: *:80                                                   Cluster: inbound|80||
0.0.0.0       15010 Trans: raw_buffer; App: HTTP                                             Route: 15010
0.0.0.0       15010 ALL                                                                      PassthroughCluster
10.68.24.41   15012 ALL                                                                      Cluster: outbound|15012||istiod.istio-system.svc.cluster.local
0.0.0.0       15014 Trans: raw_buffer; App: HTTP                                             Route: 15014
0.0.0.0       15014 ALL                                                                      PassthroughCluster
0.0.0.0       15021 ALL                                                                      Inline Route: /healthz/ready*
10.68.73.229  15021 Trans: raw_buffer; App: HTTP                                             Route: istio-ingressgateway.istio-system.svc.cluster.local:15021
10.68.73.229  15021 ALL                                                                      Cluster: outbound|15021||istio-ingressgateway.istio-system.svc.cluster.local
0.0.0.0       15090 ALL                                                                      Inline Route: /stats/prometheus*
10.68.73.229  15443 ALL                                                                      Cluster: outbound|15443||istio-ingressgateway.istio-system.svc.cluster.local
0.0.0.0       16685 Trans: raw_buffer; App: HTTP                                             Route: 16685
0.0.0.0       16685 ALL                                                                      PassthroughCluster
0.0.0.0       20001 Trans: raw_buffer; App: HTTP                                             Route: 20001
0.0.0.0       20001 ALL                                                                      PassthroughCluster
10.68.73.229  31400 ALL                                                                      Cluster: outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local
root@k8s-master01:~# istioctl proxy-config listener demoapp --port 80 --address 10.68.24.133	#过滤
ADDRESS      PORT MATCH                        DESTINATION
10.68.24.133 80   Trans: raw_buffer; App: HTTP Route: demoapp.default.svc.cluster.local:80
10.68.24.133 80   ALL                          Cluster: outbound|80||demoapp.default.svc.cluster.local
root@k8s-master01:~# istioctl proxy-config listener demoapp --port 80 --address 10.68.24.133 -o yaml	#默认是short，可通过yaml格式输出

  
--查看CDS
root@k8s-master01:~# istioctl proxy-config cluster demoapp
SERVICE FQDN                                                           PORT      SUBSET     DIRECTION     TYPE             DESTINATION RULE
                                                                       80        -          inbound       ORIGINAL_DST
BlackHoleCluster                                                       -         -          -             STATIC
InboundPassthroughClusterIpv4                                          -         -          -             ORIGINAL_DST
PassthroughCluster                                                     -         -          -             ORIGINAL_DST
agent                                                                  -         -          -             STATIC
dashboard-metrics-scraper.kubernetes-dashboard.svc.cluster.local       8000      -          outbound      EDS
demoapp.default.svc.cluster.local                                      80        -          outbound      EDS
grafana.istio-system.svc.cluster.local                                 3000      -          outbound      EDS
ingress-nginx-controller-admission.ingress-nginx.svc.cluster.local     443       -          outbound      EDS
ingress-nginx-controller.ingress-nginx.svc.cluster.local               80        -          outbound      EDS
ingress-nginx-controller.ingress-nginx.svc.cluster.local               443       -          outbound      EDS
istio-egressgateway.istio-system.svc.cluster.local                     80        -          outbound      EDS
istio-egressgateway.istio-system.svc.cluster.local                     443       -          outbound      EDS
istio-ingressgateway.istio-system.svc.cluster.local                    80        -          outbound      EDS
istio-ingressgateway.istio-system.svc.cluster.local                    443       -          outbound      EDS
istio-ingressgateway.istio-system.svc.cluster.local                    15021     -          outbound      EDS
istio-ingressgateway.istio-system.svc.cluster.local                    15443     -          outbound      EDS
istio-ingressgateway.istio-system.svc.cluster.local                    31400     -          outbound      EDS
istiod.istio-system.svc.cluster.local                                  443       -          outbound      EDS
istiod.istio-system.svc.cluster.local                                  15010     -          outbound      EDS
istiod.istio-system.svc.cluster.local                                  15012     -          outbound      EDS
istiod.istio-system.svc.cluster.local                                  15014     -          outbound      EDS
jaeger-collector.istio-system.svc.cluster.local                        9411      -          outbound      EDS
jaeger-collector.istio-system.svc.cluster.local                        14250     -          outbound      EDS
jaeger-collector.istio-system.svc.cluster.local                        14268     -          outbound      EDS
kiali.istio-system.svc.cluster.local                                   9090      -          outbound      EDS
kiali.istio-system.svc.cluster.local                                   20001     -          outbound      EDS
kube-dns.kube-system.svc.cluster.local                                 53        -          outbound      EDS
kube-dns.kube-system.svc.cluster.local                                 9153      -          outbound      EDS
kube-state-metrics.kube-system.svc.cluster.local                       8080      -          outbound      EDS
kubelet.kube-system.svc.cluster.local                                  4194      -          outbound      ORIGINAL_DST
kubelet.kube-system.svc.cluster.local                                  10250     -          outbound      ORIGINAL_DST
kubelet.kube-system.svc.cluster.local                                  10255     -          outbound      ORIGINAL_DST
kubernetes-dashboard.kubernetes-dashboard.svc.cluster.local            443       -          outbound      EDS
kubernetes.default.svc.cluster.local                                   443       -          outbound      EDS
metrics-server.kube-system.svc.cluster.local                           443       -          outbound      EDS
prometheus.istio-system.svc.cluster.local                              9090      -          outbound      EDS
prometheus.monitoring.svc.cluster.local                                9090      -          outbound      EDS
prometheus_stats                                                       -         -          -             STATIC
sds-grpc                                                               -         -          -             STATIC
tracing.istio-system.svc.cluster.local                                 80        -          outbound      EDS
tracing.istio-system.svc.cluster.local                                 16685     -          outbound      EDS
xds-grpc                                                               -         -          -             STATIC
zipkin                                                                 -         -          -             STRICT_DNS
zipkin.istio-system.svc.cluster.local                                  9411      -          outbound      EDS
--查看RDS
root@k8s-master01:~# istioctl proxy-config route demoapp
NAME                                                                      DOMAINS                                                   MATCH                  VIRTUAL SERVICE
80                                                                        demoapp, demoapp.default + 1 more...                      /*
80                                                                        ingress-nginx-controller.ingress-nginx, 10.68.155.123     /*
80                                                                        istio-egressgateway.istio-system, 10.68.72.41             /*
80                                                                        istio-ingressgateway.istio-system, 10.68.73.229           /*
80                                                                        tracing.istio-system, 10.68.71.170                        /*
9090                                                                      kiali.istio-system, 10.68.133.71                          /*
9090                                                                      prometheus.istio-system, 10.68.159.9                      /*
9090                                                                      prometheus.monitoring, 10.68.252.108                      /*
9411                                                                      jaeger-collector.istio-system, 10.68.53.65                /*
9411                                                                      zipkin.istio-system, 10.68.59.39                          /*
10255                                                                     kubelet.kube-system, *.kubelet.kube-system                /*
15010                                                                     istiod.istio-system, 10.68.24.41                          /*
15014                                                                     istiod.istio-system, 10.68.24.41                          /*
16685                                                                     tracing.istio-system, 10.68.71.170                        /*
dashboard-metrics-scraper.kubernetes-dashboard.svc.cluster.local:8000     *                                                         /*
grafana.istio-system.svc.cluster.local:3000                               *                                                         /*
jaeger-collector.istio-system.svc.cluster.local:14268                     *                                                         /*
inbound|80||                                                              *                                                         /*
prometheus.monitoring.svc.cluster.local:9090                              *                                                         /*
kube-state-metrics.kube-system.svc.cluster.local:8080                     *                                                         /*
istio-ingressgateway.istio-system.svc.cluster.local:15021                 *                                                         /*
kube-dns.kube-system.svc.cluster.local:9153                               *                                                         /*
jaeger-collector.istio-system.svc.cluster.local:14250                     *                                                         /*
kubernetes-dashboard.kubernetes-dashboard.svc.cluster.local:443           *                                                         /*
demoapp.default.svc.cluster.local:80                                      *                                                         /*
kubelet.kube-system.svc.cluster.local:4194                                *                                                         /*
InboundPassthroughClusterIpv4                                             *                                                         /*
                                                                          *                                                         /healthz/ready*
InboundPassthroughClusterIpv4                                             *                                                         /*
                                                                          *                                                         /stats/prometheus*
20001                                                                     kiali.istio-system, 10.68.133.71                          /*
inbound|80||                                                              *                                                         /*
--查看EDS
root@k8s-master01:~# istioctl proxy-config endpoints demoapp --port 80
ENDPOINT             STATUS      OUTLIER CHECK     CLUSTER
172.168.2.25:80      HEALTHY     OK                outbound|80||ingress-nginx-controller.ingress-nginx.svc.cluster.local
172.20.217.80:80     HEALTHY     OK                outbound|80||demoapp.default.svc.cluster.local
--查看其它命令
root@k8s-master01:~# istioctl proxy-config bootstrap demoapp
root@k8s-master01:~# istioctl proxy-config all demoapp
注：istio原生支持LDS,RDS,CDS,EDS，像日志，跟踪需要借助其它方式实现


3. 流量治理

3.1 istio流量治理的关键配置
- istio通过Ingress Gateway为网格引入外部流量
  - Gateway中运行的主程序亦为Envoy，它同样从控制平面接收配置，并负责完成相关的流量传输
  - 换言之，Gateway资源对象用于将外部访问映射到内部服务，它自身只负责通信子网的相关功能，例如套接字，而七层路由功能则由VirtualService实现
- Istio基于ServiceEntry资源对象将外部服务注册到网格内，从而像将外部服务以类同内部服务一样的方式进行访问治理
  - 对于外部服务，网格内Sidecar方式运行的Envoy即能执行治理
  - 若需要将外出流量收束于特定几个节点时则需要使用专用的Egress Gateway完成，并基于此Egress Gateway执行相应的流量治理
- Virtual Services和Destication Rules是Istio流量路由功能的核心组件 
- Virtual Services用于将分类流量并将其路由到指定的目的地(Destination)，而Destination Rules则用于配置那个指定Destination如何处理流量
  - Virtual Services
    - 用于在Istio及其底层平台（例如Kubernetes）的基础上配置如何将请求路由到风格中的各Service之上
	- 通常由一组路由规则（routing rules）组成，这些路由规则按顺序进行评估，从而使istio能够将那些Virtual Service的每个给定请求匹配到网格内特定的目标之上
	- 事实上，其定义的是分发给网格内各Envoy的VirtualHost和Route的相关配置
  - Destination Rules
    - 定义流量在"目标"内部的各端点之间的分发机制，例如将各端点进行分组，分组内端点间的流量均衡机制，异常探测等
	- 事实上，其定义的是分发给网格内各Envoy的Cluster的相关配置
- VirtualService定义虚拟主机及相关的路由规则，包括路由至哪个目标（集群或子集）
- DestinationRule定义集群或子集内部的流量分发机制

3.2 配置Istio流量治理
- 流量治理基础
  - 集群外部的入站流量会经由Ingress Gateway到达集群内部
    - 需要经由Gateway定义Ingress Gateway上的"虚拟主机"
	- 包括目标流量访问的"host"，以及虚拟主机监听的端口等
  - 集群内部的流量仅会在Sidecar之间流动
    - VirtualService为Sidecar Envoy定义Listener（主要定义流量路由机制等）
	- DestinationRule为Sidecar Envoy定义Cluster（包括发现端点等）

3.3 流量治理
- istio的流量路由规则使运维人员可以轻松控制服务之间的流量和API调用
  - Istio简化了诸如断路器，超时和重试之类的服务级别属性的配置，并使其易于设置重要任务（如A/B测试，canary部署和基于百分比的流量拆分的分段部署）
  - 它还提供了开箱即用的故障恢复功能，有助于使用应用程序更强大，以防止相关服务或网络的故障
- 使用istio进行流量管理从本质上是将流量与底层基础架构的伸缩机制相解耦，从而让运维工程师能够通过Pilot指定他们希望流量自身需要遵循哪些规则，而非仅仅只能定义由哪些特定的pod/VM接收流量，并在这些pod/VM之间以受限于数量比例的方式分配流量
  - Pilot和Envoy proxy负责实现流量规则中定义的流量传输机制
  - 例如，可以通过Pilot指定您希望特定服务的5%流量转到Canary版本，而与Canary部署的大小无关，或者根据请求的内容将流量发送到特定版本
- Istio的所有路由规则和控制策略都基于Kubernetes CRD实现，这包括网络功能相关的VirtualService、DestinationRule、Gateway、ServiceEntry和EnvoyFilter等
- 针对IngressGateway而言，会自动发现clusters, endpoints，但不会发现listeners, routes

3.4 配置ingress gateway引入流量到kiali
3.4.1 查看istio API群组及使用帮助
root@k8s-master01:/usr/local/istio# kubectl get crds
NAME                                       CREATED AT
authorizationpolicies.security.istio.io    2022-04-23T03:21:59Z
destinationrules.networking.istio.io       2022-04-23T03:21:59Z
envoyfilters.networking.istio.io           2022-04-23T03:22:00Z
gateways.networking.istio.io               2022-04-23T03:22:01Z
istiooperators.install.istio.io            2022-04-23T03:22:02Z
peerauthentications.security.istio.io      2022-04-23T03:22:04Z
requestauthentications.security.istio.io   2022-04-23T03:22:04Z
serviceentries.networking.istio.io         2022-04-23T03:22:06Z
sidecars.networking.istio.io               2022-04-23T03:22:07Z
telemetries.telemetry.istio.io             2022-04-23T03:22:08Z
virtualservices.networking.istio.io        2022-04-23T03:22:10Z
wasmplugins.extensions.istio.io            2022-04-23T03:22:14Z
workloadentries.networking.istio.io        2022-04-23T03:22:15Z
workloadgroups.networking.istio.io         2022-04-23T03:22:17Z
root@k8s-master01:/usr/local/istio# kubectl api-resources --api-group networking.istio.io
NAME               SHORTNAMES   APIVERSION                     NAMESPACED   KIND
destinationrules   dr           networking.istio.io/v1beta1    true         DestinationRule
envoyfilters                    networking.istio.io/v1alpha3   true         EnvoyFilter
gateways           gw           networking.istio.io/v1beta1    true         Gateway
serviceentries     se           networking.istio.io/v1beta1    true         ServiceEntry
sidecars                        networking.istio.io/v1beta1    true         Sidecar
virtualservices    vs           networking.istio.io/v1beta1    true         VirtualService
workloadentries    we           networking.istio.io/v1beta1    true         WorkloadEntry
workloadgroups     wg           networking.istio.io/v1alpha3   true         WorkloadGroup
root@k8s-master01:/usr/local/istio# kubectl explain gw.spec

3.4.2 编写Gateway yaml配置清单--定义侦听器
root@k8s-master01:/usr/local/istio# kubectl get pods -n istio-system --show-labels -l app=istio-ingressgateway
NAME                                  READY   STATUS    RESTARTS   AGE     LABELS
istio-ingressgateway-55d9fb9f-lb2tw   1/1     Running   0          4h38m   app=istio-ingressgateway,chart=gateways,heritage=Tiller,install.operator.istio.io/owning-resource=unknown,istio.io/rev=default,istio=ingressgateway,operator.istio.io/component=IngressGateways,pod-template-hash=55d9fb9f,release=istio,service.istio.io/canonical-name=istio-ingressgateway,service.istio.io/canonical-revision=latest,sidecar.istio.io/inject=false
root@k8s-master01:~/istio# cat kiali-gateway.yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: kiali-gateway
  namespace: istio-system		#ingress gateway所在的名称空间
spec:
  selector:
    app: istio-ingressgateway		#标签选择哪个ingress gateway 
  servers:
  - port:
      number: 20001		#ingress gatway暴露的服务端口
      name: http-kiali	#http开头表明使用http协议，否则默认是4层tcp协议
      protocol: HTTP	#也需要表示是HTTP协议
    hosts:
    - "kiali.magedu.com"	#主机头，需要与VirtualService主机名一相。也可以用*代替
root@k8s-master01:/usr/local/istio# istioctl proxy-status
NAME                                                  CDS        LDS        EDS        RDS          ISTIOD                      VERSION
demoapp.default                                       SYNCED     SYNCED     SYNCED     SYNCED       istiod-555d47cb65-c2vc4     1.12.0
istio-egressgateway-7f4864f59c-npp42.istio-system     SYNCED     SYNCED     SYNCED     NOT SENT     istiod-555d47cb65-c2vc4     1.12.0
istio-ingressgateway-55d9fb9f-lb2tw.istio-system      SYNCED     SYNCED     SYNCED     NOT SENT     istiod-555d47cb65-c2vc4     1.12.0
root@k8s-master01:~/istio# kubectl apply -f kiali-gateway.yaml	#应用gateway
root@k8s-master01:/usr/local/istio# istioctl proxy-status
NAME                                                  CDS        LDS        EDS        RDS          ISTIOD                      VERSION
demoapp.default                                       SYNCED     SYNCED     SYNCED     SYNCED       istiod-555d47cb65-c2vc4     1.12.0
istio-egressgateway-7f4864f59c-npp42.istio-system     SYNCED     SYNCED     SYNCED     NOT SENT     istiod-555d47cb65-c2vc4     1.12.0
istio-ingressgateway-55d9fb9f-lb2tw.istio-system      SYNCED     SYNCED     SYNCED     SYNCED       istiod-555d47cb65-c2vc4     1.12.0	#RDS状态从NOT SENT变成SYNCED了

3.4.3 查看listener和route
root@k8s-master01:/usr/local/istio# InGW=$(kubectl get pods -n istio-system -l app=istio-ingressgateway -o jsonpath={.items[0].metadata.name})	#将pod名称保存至变量
root@k8s-master01:/usr/local/istio# echo $InGW
istio-ingressgateway-55d9fb9f-lb2tw
root@k8s-master01:/usr/local/istio# istioctl proxy-config listeners $InGW -n istio-system
ADDRESS PORT  MATCH DESTINATION
0.0.0.0 15021 ALL   Inline Route: /healthz/ready*
0.0.0.0 15090 ALL   Inline Route: /stats/prometheus*
0.0.0.0 20001 ALL   Route: http.20001					#此为定义的listener
root@k8s-master01:/usr/local/istio# istioctl proxy-config routes $InGW -n istio-system
NAME           DOMAINS     MATCH                  VIRTUAL SERVICE
http.20001     *           /*                     404			#返回404，因为ingress gateway不会自动生成侦听器和路由信息，需要自行配置
               *           /healthz/ready*
               *           /stats/prometheus*

3.4.4 定义VirtualService----定义主机名和匹配路由
root@k8s-master01:~/istio# kubectl get gw -n istio-system	#查看定义好的gateway
NAME            AGE
kiali-gateway   25m
root@k8s-master01:~/istio# cat kiali-virtualservice.yaml	#配置virtualservice
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: kiali-virtualservice
  namespace: istio-system
spec:
  hosts:
  - "kiali.magedu.com"		#与gateway中哪个虚拟主机名相关联
  gateways:
  - kiali-gateway			#与哪个gateway相关联，就是此前定义好的gateway
  http:
  - match:
    - port: 20001			#匹配访问kiali.magedu.com:20001后将执行以下操作
    route:
    - destination:
        host: kiali			#路由到istio-system名称空间下名称为kiali并且端口为20001的service
        port:
          number: 20001
root@k8s-master01:~/istio# kubectl apply -f kiali-virtualservice.yaml
root@k8s-master01:~/istio# kubectl get vs -n istio-system				#查看virtualservice
NAME                   GATEWAYS            HOSTS                  AGE
kiali-virtualservice   ["kiali-gateway"]   ["kiali.magedu.com"]   2m58s
root@k8s-master01:~# istioctl proxy-config routes $InGW.istio-system	#查看ingress gatewy POD的路由匹配
NAME           DOMAINS              MATCH                  VIRTUAL SERVICE
http.20001     kiali.magedu.com     /*                     kiali-virtualservice.istio-system	#此时不是404，可以路由到对应的VS上了
               *                    /healthz/ready*
               *                    /stats/prometheus*
root@k8s-master01:~# istioctl proxy-config clusters $InGW.istio-system		#查看ingress gateway中的cluster
SERVICE FQDN                                                           PORT      SUBSET     DIRECTION     TYPE           DESTINATION RULE
BlackHoleCluster                                                       -         -          -             STATIC
agent                                                                  -         -          -             STATIC
dashboard-metrics-scraper.kubernetes-dashboard.svc.cluster.local       8000      -          outbound      EDS
demoapp.default.svc.cluster.local                                      80        -          outbound      EDS
grafana.istio-system.svc.cluster.local                                 3000      -          outbound      EDS
ingress-nginx-controller-admission.ingress-nginx.svc.cluster.local     443       -          outbound      EDS
ingress-nginx-controller.ingress-nginx.svc.cluster.local               80        -          outbound      EDS
ingress-nginx-controller.ingress-nginx.svc.cluster.local               443       -          outbound      EDS
istio-egressgateway.istio-system.svc.cluster.local                     80        -          outbound      EDS
istio-egressgateway.istio-system.svc.cluster.local                     443       -          outbound      EDS
istio-ingressgateway.istio-system.svc.cluster.local                    80        -          outbound      EDS
istio-ingressgateway.istio-system.svc.cluster.local                    443       -          outbound      EDS
istio-ingressgateway.istio-system.svc.cluster.local                    15021     -          outbound      EDS
istio-ingressgateway.istio-system.svc.cluster.local                    15443     -          outbound      EDS
istio-ingressgateway.istio-system.svc.cluster.local                    31400     -          outbound      EDS
istiod.istio-system.svc.cluster.local                                  443       -          outbound      EDS
istiod.istio-system.svc.cluster.local                                  15010     -          outbound      EDS
istiod.istio-system.svc.cluster.local                                  15012     -          outbound      EDS
istiod.istio-system.svc.cluster.local                                  15014     -          outbound      EDS
jaeger-collector.istio-system.svc.cluster.local                        9411      -          outbound      EDS
jaeger-collector.istio-system.svc.cluster.local                        14250     -          outbound      EDS
jaeger-collector.istio-system.svc.cluster.local                        14268     -          outbound      EDS
kiali.istio-system.svc.cluster.local                                   9090      -          outbound      EDS
kiali.istio-system.svc.cluster.local                                   20001     -          outbound      EDS		#自动发现为EGRESS方向的集群，此时可以正常访问kiali
kube-dns.kube-system.svc.cluster.local                                 53        -          outbound      EDS
kube-dns.kube-system.svc.cluster.local                                 9153      -          outbound      EDS
kube-state-metrics.kube-system.svc.cluster.local                       8080      -          outbound      EDS
kubelet.kube-system.svc.cluster.local                                  4194      -          outbound      EDS
kubelet.kube-system.svc.cluster.local                                  10250     -          outbound      EDS
kubelet.kube-system.svc.cluster.local                                  10255     -          outbound      EDS
kubernetes-dashboard.kubernetes-dashboard.svc.cluster.local            443       -          outbound      EDS
kubernetes.default.svc.cluster.local                                   443       -          outbound      EDS
metrics-server.kube-system.svc.cluster.local                           443       -          outbound      EDS
prometheus.istio-system.svc.cluster.local                              9090      -          outbound      EDS
prometheus.monitoring.svc.cluster.local                                9090      -          outbound      EDS
prometheus_stats                                                       -         -          -             STATIC
sds-grpc                                                               -         -          -             STATIC
tracing.istio-system.svc.cluster.local                                 80        -          outbound      EDS
tracing.istio-system.svc.cluster.local                                 16685     -          outbound      EDS
xds-grpc                                                               -         -          -             STATIC
zipkin                                                                 -         -          -             STRICT_DNS
zipkin.istio-system.svc.cluster.local                                  9411      -          outbound      EDS

3.4.5 定义LoadBalancer类型的service istio-ingressgateway的EXTERNAL-IP为172.168.2.27(配置node02 eth0接口),172.168.2.28(配置node03 eth0接口)
root@k8s-master01:~# kubectl get svc -n istio-system
NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                                                                      AGE
grafana                ClusterIP      10.68.113.201   <none>        3000/TCP                                                                     5h33m
istio-egressgateway    ClusterIP      10.68.72.41     <none>        80/TCP,443/TCP                                                               5h40m
istio-ingressgateway   LoadBalancer   10.68.73.229    <pending>     15021:52853/TCP,80:35143/TCP,443:56986/TCP,31400:59801/TCP,15443:55554/TCP   5h40m
root@k8s-master01:~# kubectl edit svc istio-ingressgateway -n istio-system		#编辑SVC
spec:
  clusterIP: 10.68.73.229
  clusterIPs:
  - 10.68.73.229
  externalTrafficPolicy: Cluster
  externalIPs:		#增加各节点上的IP，以达到模拟IaaS上公有云的公网IP地址，方便在测试时固定此两个IP地址
  - 172.168.2.27
  - 172.168.2.28
  ports:
  - name: http-kiali
    port: 20001
    protocol: TCP
    targetPort: 20001
root@k8s-master01:~# kubectl get svc/istio-ingressgateway -n istio-system			#此时已经配置成功，可以通过172.168.2.27:20001或172.168.2.28:20001进行访问
NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP                 PORT(S)                                                                                      AGE
istio-ingressgateway   LoadBalancer   10.68.73.229   172.168.2.27,172.168.2.28   15021:52853/TCP,80:35143/TCP,443:56986/TCP,31400:59801/TCP,15443:55554/TCP,20001:34154/TCP   5h54m
	
root@k8s-master01:~# istioctl proxy-config listeners $InGW.istio-system
ADDRESS PORT  MATCH DESTINATION
0.0.0.0 15021 ALL   Inline Route: /healthz/ready*
0.0.0.0 15090 ALL   Inline Route: /stats/prometheus*
0.0.0.0 20001 ALL   Route: http.20001		#此端口是ingress-gateway暴露的端口
注：LoadBalancer是公司云上的LBaaS，此处进行模拟

3.4.6 配置hosts解析，并测试kiali服务是否正常
root@k8s-master01:~# vim /etc/hosts
172.168.2.27 ceph01 kiali.magedu.com
172.168.2.28 ceph02 kiali.magedu.com

3.4.7 配置DestinationRule实现高级扩展功能
root@k8s-master01:~/istio# cat kiali-destinationrule.yaml	#此处只是定义一个DR，并没有实现高级功能
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: kiali-destinationrule
  namespace: istio-system
spec:
  host: kiali
  trafficPolicy:
    tls:
      mode: DISABLE		#关闭tls
root@k8s-master01:~/istio# kubectl apply -f kiali-destinationrule.yaml
root@k8s-master01:~# istioctl proxy-config clusters $InGW.istio-system --port 20001
SERVICE FQDN                                            PORT      SUBSET     DIRECTION     TYPE     DESTINATION RULE
istio-ingressgateway.istio-system.svc.cluster.local     20001     -          outbound      EDS
kiali.istio-system.svc.cluster.local                    20001     -          outbound      EDS      kiali-destinationrule.istio-system		#此时有DR了
root@k8s-master01:~# istioctl proxy-config routes $InGW.istio-system	#有VIRTUAL SERVICE是自动生成
NAME           DOMAINS              MATCH                  VIRTUAL SERVICE
http.20001     kiali.magedu.com     /*                     kiali-virtualservice.istio-system
               *                    /healthz/ready*
               *                    /stats/prometheus*

3.5 将grafana通过ingress-gateway暴露出来 
3.5.1 配置grafana的GW, VS, DR
root@k8s-master01:~/istio/grafana# cat grafana-gateway
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: grafana-gateway
  namespace: istio-system
spec:
  selector:
    app: istio-ingressgateway
  servers:
  - port:
      number: 80
      name: http-grafana
      protocol: HTTP
    hosts:
    - "grafana.magedu.com"
root@k8s-master01:~/istio/grafana# cat grafana-virtualservice.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: grafana-virtualservice
  namespace: istio-system
spec:
  hosts:
  - "grafana.magedu.com"
  gateways:
  - grafana-gateway
  http:
  - match:
    - uri:
        prefix: '/'
    route:
    - destination:
        host: grafana
        port:
          number: 3000
root@k8s-master01:~/istio/grafana# cat grafana-destinationrule.yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: grafana-destinationrule
  namespace: istio-system
spec:
  host: grafana
  trafficPolicy:
    tls:
      mode: DISABLE
root@k8s-master01:~/istio/grafana# kubectl apply -f grafana-gateway
root@k8s-master01:~/istio/grafana# kubectl apply -f grafana-virtualservice.yaml
root@k8s-master01:~/istio/grafana# kubectl apply -f grafana-destinationrule.yaml
root@k8s-master01:~/istio/grafana# kubectl get gw -n istio-system
NAME              AGE
grafana-gateway   36s
kiali-gateway     141m
root@k8s-master01:~/istio/grafana# kubectl get vs -n istio-system
NAME                     GATEWAYS              HOSTS                    AGE
grafana-virtualservice   ["grafana-gateway"]   ["grafana.magedu.com"]   2m18s
kiali-virtualservice     ["kiali-gateway"]     ["kiali.magedu.com"]     114m
root@k8s-master01:~/istio/grafana# kubectl get dr -n istio-system
NAME                      HOST      AGE
grafana-destinationrule   grafana   2m22s
kiali-destinationrule     kiali     42m
root@k8s-master01:~# istioctl proxy-config listeners $InGW.istio-system		#查看ingress-gateway的侦听器
ADDRESS PORT  MATCH DESTINATION
0.0.0.0 8080  ALL   Route: http.8080		#看似是8080，其实是80端口暴露转发到8080端点，主要是流量拦截机制
0.0.0.0 15021 ALL   Inline Route: /healthz/ready*
0.0.0.0 15090 ALL   Inline Route: /stats/prometheus*
0.0.0.0 20001 ALL   Route: http.20001

3.5.2 添加hosts指向 grafana.magedu.com，然后浏览器访问即可

3.6 将kiali由20001端口切换为80端口访问
root@k8s-master01:~/istio/kiali# cat kiali-gateway.yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: kiali-gateway
  namespace: istio-system
spec:
  selector:
    app: istio-ingressgateway
  servers:
  - port:
      number: 80
      name: http-kiali
      protocol: HTTP
    hosts:
    - "kiali.magedu.com"
root@k8s-master01:~/istio/kiali# cat kiali-virtualservice.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: kiali-virtualservice
  namespace: istio-system
spec:
  hosts:
  - "kiali.magedu.com"
  gateways:
  - kiali-gateway
  http:
  - match:
    - uri:
        prefix: '/'
    route:
    - destination:
        host: kiali
        port:
          number: 20001
root@k8s-master01:~/istio/kiali# cat kiali-destinationrule.yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: kiali-destinationrule
  namespace: istio-system
spec:
  host: kiali
  trafficPolicy:
    tls:
      mode: DISABLE
root@k8s-master01:~/istio/kiali# kubectl apply -f kiali-gateway.yaml -f kiali-virtualservice.yaml -f kiali-destinationrule.yaml

3.7 网格流量治理和服务发现
- 网格内服务发送和接收的所有流量（DataPlane流量）都要经由Envoy代理进行
  - 绑定到服务的所有流量都会通过Sidecar Envoy自动进行重新路由
- Istio借助于服务注册中心完成服务发现
  - Istio自身并不进行服务发现功能，它需要借助于服务注册中心发现所有的Service及相应的各Endpoint
  - Istio还假设服务的新实例会自动注册到服务注册表，并且会自动删除不集群的实例
  - Kubernetes、Mesos等平台能够为基于容器的应用程序提供服务发现功能，另外也存在大量针对基于VM的应用程序的解决方案
- Kubernetes系统上，Istio会将网格中的每个Service的端口创建为Listener，而其匹配到的endpoint将组合成为一个Cluster
  - 这些Listener和Cluster将配置在网格内的每个Sidecar Envoy之上
  - 对于某个特定的Sidecar Envoy来说，仅其自身所属的Service生成的Listener为Inbound Listener，而所有Service生成Listener都将配置为其上的Outbound Listener
    - Inbound Listener: 接收其所属Service的部分或全部流量
	- Outbound Listener：代理本地应用访问集群内的其它服务
  - 进出应用的所有流量都将被Sidecar Envoy拦截并基于重写向的方式进行处理
- Sidecar Envoy的功能
  - 在负载均衡池中的实例之间分配流量
  - 对后端端点进行健康状态检测
  .....

istio课程源码：git clone https://github.com/iKubernetes/istio-in-practise.git
4 在网格内实现微服务流量间通信
client --> proxy(sidecar, proxyapp) --> backend(sidecar, app)

4.1 创建deployment和service
root@k8s-master01:~/istio/istio-demo# kubectl create deployment demoappv10 --image=ikubernetes/demoapp:v1.0 --replicas=3 --dry-run=client -o yaml > deploy-demoapp-v10.yaml
root@k8s-master01:~/istio/istio-demo# vim deploy-demoapp-v10.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: demoapp
  name: demoappv10
spec:
  replicas: 3
  selector:
    matchLabels:
      app: demoapp
      version: v1.0
  strategy: {}
  template:
    metadata:
      labels:
        app: demoapp
        version: v1.0
    spec:
      containers:
      - image: ikubernetes/demoapp:v1.0
        name: demoapp
        env:
        - name: PORT
          value: '8080'
        resources: {}
root@k8s-master01:~/istio/istio-demo# kubectl create service clusterip demoappv10 --tcp=8080:8080 --dry-run=client -o yaml > service-demoapp-v10.yaml
root@k8s-master01:~/istio/istio-demo# vim service-demoapp-v10.yaml	
apiVersion: v1
kind: Service
metadata:
  labels:
    app: demoapp
  name: demoappv10
spec:
  ports:
  - name: http-8080		#必须是以http开头，这样ingress gateway才会识别为7层应用
    port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    app: demoapp
    version: v1.0
  type: ClusterIP

root@k8s-master01:~/istio/istio-demo# ll
total 8
drwxr-xr-x 2 root root  69 Apr 23 19:15 ./
drwxr-xr-x 5 root root  52 Apr 23 19:03 ../
-rw-r--r-- 1 root root 458 Apr 23 19:15 deploy-demoapp-v10.yaml
-rw-r--r-- 1 root root 245 Apr 23 19:14 service-demoapp-v10.yaml
root@k8s-master01:~/istio/istio-demo# kubectl apply -f .		#应用service和deployment 
root@k8s-master01:~/istio/istio-demo# kubectl get pods -o wide
NAME                          READY   STATUS    RESTARTS   AGE    IP               NODE            NOMINATED NODE   READINESS GATES
demoappv10-5c497c6f7c-fgb4n   2/2     Running   0          101s   172.20.217.72    192.168.13.63   <none>           <none>	#都注入了sidecar
demoappv10-5c497c6f7c-l9pnf   2/2     Running   0          101s   172.20.135.157   172.168.2.26    <none>           <none>
demoappv10-5c497c6f7c-wzvnn   2/2     Running   0          101s   172.20.217.101   192.168.13.63   <none>           <none>
root@k8s-master01:~/istio/istio-demo# kubectl describe svc demoappv10
Name:              demoappv10
Namespace:         default
Labels:            app=demoapp
Annotations:       <none>
Selector:          app=demoapp,version=v1.0
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.68.2.60
IPs:               10.68.2.60
Port:              http-8080  8080/TCP
TargetPort:        8080/TCP
Endpoints:         172.20.135.157:8080,172.20.217.101:8080,172.20.217.72:8080
Session Affinity:  None
Events:            <none>
root@k8s-master01:~/istio/istio-demo# DEMOAPP=$(kubectl get pods -l app=demoapp -o jsonpath={.items[0].metadata.name})
root@k8s-master01:~/istio/istio-demo# istioctl proxy-status | grep demoappv10	#显示已经成功同步
demoappv10-5c497c6f7c-fgb4n.default                   SYNCED     SYNCED     SYNCED     SYNCED       istiod-555d47cb65-c2vc4     1.12.0
demoappv10-5c497c6f7c-l9pnf.default                   SYNCED     SYNCED     SYNCED     SYNCED       istiod-555d47cb65-c2vc4     1.12.0
demoappv10-5c497c6f7c-wzvnn.default                   SYNCED     SYNCED     SYNCED     SYNCED       istiod-555d47cb65-c2vc4     1.12.0
root@k8s-master01:~/istio/istio-demo# istioctl proxy-config listeners $DEMOAPP --port 8080	#随机查看demoapp pod的监听器，一个8080为ingress,另一个8080为egress
ADDRESS      PORT MATCH                        DESTINATION
0.0.0.0      8080 Trans: raw_buffer; App: HTTP Route: 8080
0.0.0.0      8080 ALL                          PassthroughCluster
10.68.16.146 8080 Trans: raw_buffer; App: HTTP Route: kube-state-metrics.kube-system.svc.cluster.local:8080
10.68.16.146 8080 ALL                          Cluster: outbound|8080||kube-state-metrics.kube-system.svc.cluster.local
	
root@k8s-master01:~/istio/istio-demo# istioctl proxy-config routes $DEMOAPP | grep demoapp	#查看route，一个反向代理时的路由
8080                                                                      demoappv10, demoappv10.default + 1 more...                /*

root@k8s-master01:~/istio/istio-demo# istioctl proxy-config clusters $DEMOAPP --port 8080	#查看集群，一个8080为ingress,另一个8080为egress
SERVICE FQDN                                         PORT     SUBSET     DIRECTION     TYPE             DESTINATION RULE
                                                     8080     -          inbound       ORIGINAL_DST
demoappv10.default.svc.cluster.local                 8080     -          outbound      EDS
kube-state-metrics.kube-system.svc.cluster.local     8080     -          outbound      EDS

root@k8s-master01:~/istio/istio-demo# istioctl proxy-config endpoints $DEMOAPP | grep demoapp	#查看endpoints
172.20.135.157:8080              HEALTHY     OK                outbound|8080||demoappv10.default.svc.cluster.local
172.20.217.101:8080              HEALTHY     OK                outbound|8080||demoappv10.default.svc.cluster.local
172.20.217.72:8080               HEALTHY     OK                outbound|8080||demoappv10.default.svc.cluster.local

4.2 运行admin-box容器进行测试
root@k8s-master01:~# kubectl run client --image=ikubernetes/admin-box -it --rm --command -- /bin/sh
root@k8s-master01:~/istio/istio-demo# kubectl get pods		#client也被注入sidecar
NAME                          READY   STATUS    RESTARTS   AGE
client                        2/2     Running   0          41s
root@client # curl demoappv10:8080		#测试是由本地0.0.0.0:8080的Egress进行拦截流量，从而代理到后端的
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-wzvnn, ServerIP: 172.20.217.101!
root@client # curl demoappv10:8080
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-l9pnf, ServerIP: 172.20.135.157!
root@client # curl demoappv10:8080
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-fgb4n, ServerIP: 172.20.217.72!

4.3 运行前端pod
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/01-demoapp-v10# cat deploy-proxy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: proxy
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  selector:
    matchLabels:
      app: proxy
  template:
    metadata:
      labels:
        app: proxy
    spec:
      containers:
        - env:
          - name: PROXYURL
            value: http://demoappv10:8080
          image: ikubernetes/proxy:v0.1.1
          imagePullPolicy: IfNotPresent
          name: proxy
          ports:
            - containerPort: 8080
              name: web
              protocol: TCP
          resources:
            limits:
              cpu: 50m
---
apiVersion: v1
kind: Service
metadata:
  name: proxy
spec:
  ports:
    - name: http-80
      port: 80
      protocol: TCP
      targetPort: 8080
  selector:
    app: proxy
---
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/01-demoapp-v10# kubectl apply -f deploy-proxy.yaml
root@k8s-master01:~# kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
client                        2/2     Running   0          94m
demoappv10-5c497c6f7c-fgb4n   2/2     Running   0          116m
demoappv10-5c497c6f7c-l9pnf   2/2     Running   0          116m
demoappv10-5c497c6f7c-wzvnn   2/2     Running   0          116m
proxy-5cf6d4cc8d-j85dc        2/2     Running   0          19m

4.4 客户端进行测试访问proxy的效果
root@client # while true;do curl proxy; sleep 0.$RANDOM;done
 - Took 7 milliseconds.
Proxying value: iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-l9pnf, ServerIP: 172.20.135.157!
 - Took 16 milliseconds.
Proxying value: iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-l9pnf, ServerIP: 172.20.135.157!
 - Took 116 milliseconds.
Proxying value: iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-wzvnn, ServerIP: 172.20.217.101!
 - Took 23 milliseconds.
注：此时client pod --> proxy --> demoappv10 已经成功实现

4.5 demoappv10 和 demoappv11并存，实现灰度发布
--安装demoappv11
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/02-demoapp-v11# cat deploy-demoapp-v11.yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: demoappv11
    version: v1.1
  name: demoappv11
spec:
  progressDeadlineSeconds: 600
  replicas: 2
  selector:
    matchLabels:
      app: demoapp
      version: v1.1
  template:
    metadata:
      labels:
        app: demoapp
        version: v1.1
    spec:
      containers:
      - image: ikubernetes/demoapp:v1.1
        imagePullPolicy: IfNotPresent
        name: demoapp
        env:
        - name: "PORT"
          value: "8080"
        ports:
        - containerPort: 8080
          name: web
          protocol: TCP
        resources:
          limits:
            cpu: 50m
---
apiVersion: v1
kind: Service
metadata:
  name: demoappv11
spec:
  ports:
    - name: http-8080
      port: 8080
      protocol: TCP
      targetPort: 8080
  selector:
    app: demoapp
    version: v1.1
  type: ClusterIP
---
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/02-demoapp-v11# kubectl apply -f deploy-demoapp-v11.yaml

4.6 创建demoapp service，同时纳管demoappv10 和 demoappv11
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/02-demoapp-v11# cat service-demoapp.yaml
---
apiVersion: v1
kind: Service
metadata:
  name: demoapp
spec:
  ports:
    - name: http
      port: 8080
      protocol: TCP
      targetPort: 8080
  selector:
    app: demoapp
  type: ClusterIP
---
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/02-demoapp-v11# kubectl apply -f service-demoapp.yaml

4.7 将proxy控制器从访问demoappv10:8080改成demoapp:8080，从而可以路由到demoappv10和demoappv11
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/02-demoapp-v11# cat deploy-proxy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: proxy
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  selector:
    matchLabels:
      app: proxy
  template:
    metadata:
      labels:
        app: proxy
    spec:
      containers:
        - env:
          - name: PROXYURL
            value: http://demoapp:8080		#此处更改
          image: ikubernetes/proxy:v0.1.1
          imagePullPolicy: IfNotPresent
          name: proxy
          ports:
            - containerPort: 8080
              name: web
              protocol: TCP
          resources:
            limits:
              cpu: 50m
---
apiVersion: v1
kind: Service
metadata:
  name: proxy
spec:
  ports:
    - name: http-80
      port: 80
      protocol: TCP
      targetPort: 8080
  selector:
    app: proxy
---
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/02-demoapp-v11# kubectl apply -f deploy-proxy.yaml

4.8 测试访问proxy时是否在demoappv10 和 demoappv11之间随机调度
root@client # while true;do curl proxy/hostname; sleep 0.$RANDOM;done
Proxying value: ServerName: demoappv11-7984f579f5-9r68w
 - Took 798 milliseconds.
Proxying value: ServerName: demoappv11-7984f579f5-dbhd9
 - Took 66 milliseconds.
Proxying value: ServerName: demoappv10-5c497c6f7c-wzvnn
 - Took 60 milliseconds.
Proxying value: ServerName: demoappv10-5c497c6f7c-fgb4n
 - Took 21 milliseconds.
Proxying value: ServerName: demoappv10-5c497c6f7c-l9pnf
 - Took 96 milliseconds.
Proxying value: ServerName: demoappv11-7984f579f5-9r68w

4.9 配置canary灰度发布--定义virtualService，此VirtualService是针对网格内所有sidecar的
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/02-demoapp-v11# cat virutalservice-demoapp.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: demoapp				
spec:
  hosts:
  - demoapp		#匹配主机头域名为demoapp的将执行以下匹配路由操作，这里没有使用selector选择ingress-gateway,所以此VirtualService是针对网格内所有sidecar的
  http:
  - name: canary
    match:
    - uri:
        prefix: /canary		#匹配URI/canary的访问语法重写到/，并且路由到demoappv11 
    rewrite:
      uri: /
    route:
    - destination:
        host: demoappv11
  - name: default
    route:					#其它默认路由到demoappv10
    - destination:
        host: demoappv10
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/02-demoapp-v11# kubectl apply -f virutalservice-demoapp.yaml
root@k8s-master01:~# kubectl get vs
NAME      GATEWAYS   HOSTS         AGE
demoapp              ["demoapp"]   8m34s
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/02-demoapp-v11# kubectl get svc -o wide
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE   SELECTOR
demoapp      ClusterIP   10.68.120.190   <none>        8080/TCP   17h   app=demoapp
demoappv10   ClusterIP   10.68.2.60      <none>        8080/TCP   19h   app=demoapp,version=v1.0
demoappv11   ClusterIP   10.68.224.68    <none>        8080/TCP   17h   app=demoapp,version=v1.1
kubernetes   ClusterIP   10.68.0.1       <none>        443/TCP    50d   <none>
proxy        ClusterIP   10.68.56.59     <none>        80/TCP     17h   app=proxy

4.10 查看proxy自动发现xDS结果
root@k8s-master01:~# istioctl proxy-config listeners $DEMOAPP --port 80
ADDRESS PORT MATCH                        DESTINATION
0.0.0.0 80   Trans: raw_buffer; App: HTTP Route: 80
0.0.0.0 80   ALL                          PassthroughCluster
root@k8s-master01:~# istioctl proxy-config routes $DEMOAPP --name 80 | grep proxy
80       proxy, proxy.default + 1 more...                          /*
root@k8s-master01:~# istioctl proxy-config clusters $DEMOAPP --port 80 | grep proxy
proxy.default.svc.cluster.local                              80       -          outbound      EDS
注：当访问proxy:80时将会被路由到proxy.default.svc.cluster.local，此service的后端pod又会代理到http://demoapp:8080，而此主机头将会匹配到如下demoapp 8080 Egress

4.11 查看demoapp自动发现xDS结果
root@k8s-master01:~# istioctl proxy-config listeners $DEMOAPP --port 8080		#LDS
ADDRESS      PORT MATCH                        DESTINATION
0.0.0.0      8080 Trans: raw_buffer; App: HTTP Route: 8080
0.0.0.0      8080 ALL                          PassthroughCluster
root@k8s-master01:~# istioctl proxy-config routes $DEMOAPP --name 8080			#RDS,请求http://demoapp:8080特定URI会匹配VS,将会被路由到特定的集群
NAME     DOMAINS                                          MATCH        VIRTUAL SERVICE
8080     demoapp, demoapp.default + 1 more...             /canary*     demoapp.default		#demoapp的主机头匹配到了VS demoapp
8080     demoapp, demoapp.default + 1 more...             /*           demoapp.default		#demoapp的主机头匹配到了VS demoapp
8080     demoappv10, demoappv10.default + 1 more...       /*
8080     demoappv11, demoappv11.default + 1 more...       /*
root@k8s-master01:~# istioctl proxy-config clusters $DEMOAPP --port 8080		#CDS
SERVICE FQDN                                         PORT     SUBSET     DIRECTION     TYPE             DESTINATION RULE
                                                     8080     -          inbound       ORIGINAL_DST
demoapp.default.svc.cluster.local                    8080     -          outbound      EDS
demoappv10.default.svc.cluster.local                 8080     -          outbound      EDS
demoappv11.default.svc.cluster.local                 8080     -          outbound      EDS
root@k8s-master01:~# istioctl proxy-config endpoints $DEMOAPP --port 8080 | sort -k 4 | grep demoapp		#EDS
172.20.135.157:8080     HEALTHY     OK                outbound|8080||demoapp.default.svc.cluster.local
172.20.217.101:8080     HEALTHY     OK                outbound|8080||demoapp.default.svc.cluster.local
172.20.217.72:8080      HEALTHY     OK                outbound|8080||demoapp.default.svc.cluster.local
172.20.217.83:8080      HEALTHY     OK                outbound|8080||demoapp.default.svc.cluster.local
172.20.217.90:8080      HEALTHY     OK                outbound|8080||demoapp.default.svc.cluster.local
172.20.135.157:8080     HEALTHY     OK                outbound|8080||demoappv10.default.svc.cluster.local
172.20.217.101:8080     HEALTHY     OK                outbound|8080||demoappv10.default.svc.cluster.local
172.20.217.72:8080      HEALTHY     OK                outbound|8080||demoappv10.default.svc.cluster.local
172.20.217.83:8080      HEALTHY     OK                outbound|8080||demoappv11.default.svc.cluster.local
172.20.217.90:8080      HEALTHY     OK                outbound|8080||demoappv11.default.svc.cluster.local

4.12 测试基于URI灰度发布结果
root@client # while true;do curl proxy/canary; sleep 0.$RANDOM;done		#访问/canary都将被路由到demoappv11
Proxying value: iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-dbhd9, ServerIP: 172.20.217.90!
 - Took 69 milliseconds.
Proxying value: iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-9r68w, ServerIP: 172.20.217.83!
 - Took 20 milliseconds.
Proxying value: iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-dbhd9, ServerIP: 172.20.217.90!
 - Took 7 milliseconds.
Proxying value: iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-dbhd9, ServerIP: 172.20.217.90!
 - Took 33 milliseconds.
root@client # while true;do curl proxy/hostname; sleep 0.$RANDOM;done	#访问除/canary以外都将被路由到demoappv10
Proxying value: ServerName: demoappv10-5c497c6f7c-l9pnf
 - Took 8 milliseconds.
Proxying value: ServerName: demoappv10-5c497c6f7c-wzvnn
 - Took 7 milliseconds.
Proxying value: ServerName: demoappv10-5c497c6f7c-fgb4n
 - Took 7 milliseconds.
Proxying value: ServerName: demoappv10-5c497c6f7c-l9pnf
 - Took 9 milliseconds.
Proxying value: ServerName: demoappv10-5c497c6f7c-l9pnf
 - Took 8 milliseconds.

4.13 配置集群子集
4.13.1 拆出VS
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/03-demoapp-subset# kubectl delete vs demoapp
root@client # while true;do curl proxy/hostname; sleep 0.$RANDOM;done	#此时又在两个版本之间随机调度
Proxying value: ServerName: demoappv10-5c497c6f7c-l9pnf
 - Took 23 milliseconds.
Proxying value: ServerName: demoappv11-7984f579f5-dbhd9
 - Took 18 milliseconds.

4.13.2 配置DestinationRule，针对demoapp集群配置子集
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/03-demoapp-subset# cat destinationrule-demoapp.yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: demoapp
spec:
  host: demoapp
  subsets:
  - name: v10
    labels:
      version: v1.0		#后端Pod标签为version: v1.0	的划分为v10子集
  - name: v11
    labels:
      version: v1.1		#后端Pod标签为version: v1.1	的划分为v11子集
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/03-demoapp-subset# kubectl apply -f destinationrule-demoapp.yaml
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/03-demoapp-subset# kubectl get dr
NAME      HOST      AGE
demoapp   demoapp   12s
--验证DR
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/03-demoapp-subset# istioctl proxy-config clusters $DEMOAPP --port 8080
SERVICE FQDN                                         PORT     SUBSET     DIRECTION     TYPE             DESTINATION RULE
                                                     8080     -          inbound       ORIGINAL_DST
demoapp.default.svc.cluster.local                    8080     -          outbound      EDS              demoapp.default		#这个是全集，加子集共3个
demoapp.default.svc.cluster.local                    8080     v10        outbound      EDS              demoapp.default		#新增加的两个子集
demoapp.default.svc.cluster.local                    8080     v11        outbound      EDS              demoapp.default
demoappv10.default.svc.cluster.local                 8080     -          outbound      EDS
demoappv11.default.svc.cluster.local                 8080     -          outbound      EDS

4.13.3 配置VirtualService
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/03-demoapp-subset# cat virutalservice-demoapp.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: demoapp
spec:
  hosts:
  - demoapp
  http:
  - name: canary
    match:
    - uri:
        prefix: /canary
    rewrite:
      uri: /
    route:
    - destination:
        host: demoapp		#匹配条件路由到demoapp集群的子集v11
        subset: v11
  - name: default
    route:
    - destination:
        host: demoapp		#其它条件路由到demoapp集群的子集v10
        subset: v10
注：有一个奇怪的功能，当定义demoapp VirtualService后，竟然80和8080端口上都有此主机名，而增加测试7070的svc却不生效demoapp主机名功能。
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/03-demoapp-subset# kubectl apply -f virutalservice-demoapp.yaml
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/03-demoapp-subset# kubectl get vs
NAME      GATEWAYS   HOSTS         AGE
demoapp              ["demoapp"]   4s
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/03-demoapp-subset# istioctl proxy-config routes $DEMOAPP --name 8080
NAME     DOMAINS                                          MATCH        VIRTUAL SERVICE
8080     demoapp, demoapp.default + 1 more...             /canary*     demoapp.default
8080     demoapp, demoapp.default + 1 more...             /*           demoapp.default

4.13.4 测试集群子集功能
root@client # while true;do curl proxy/hostname; sleep 0.$RANDOM;done
Proxying value: ServerName: demoappv10-5c497c6f7c-wzvnn
 - Took 24 milliseconds.
Proxying value: ServerName: demoappv10-5c497c6f7c-fgb4n
 - Took 16 milliseconds.
root@client # while true;do curl proxy/canary; sleep 0.$RANDOM;done
Proxying value: iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-9r68w, ServerIP: 172.20.217.83!
 - Took 21 milliseconds.
Proxying value: iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-9r68w, ServerIP: 172.20.217.83!
 - Took 8 milliseconds.

root@k8s-master01:~# kubectl delete svc demoappv10 demoappv11	#删除svc后服务仍然正常，因为走的是集群子集
root@client # while true;do curl proxy/canary; sleep 0.$RANDOM;done
Proxying value: iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-9r68w, ServerIP: 172.20.217.83!
 - Took 49 milliseconds.
Proxying value: iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-9r68w, ServerIP: 172.20.217.83!
 - Took 25 milliseconds.
root@client # while true;do curl proxy/hostname; sleep 0.$RANDOM;done
Proxying value: ServerName: demoappv10-5c497c6f7c-wzvnn
 - Took 64 milliseconds.
Proxying value: ServerName: demoappv10-5c497c6f7c-fgb4n
 - Took 198 milliseconds.


4.14 将proxy使用ingress-gateway暴露在外网使用

4.14.1 针对ingressgateway创建gateway
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/04-proxy-gateway# cat gateway-proxy.yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: proxy-gateway
  namespace: istio-system        # 要指定为ingress gateway pod所在名称空间
spec:
  selector:
    app: istio-ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "fe.magedu.com"
	
4.14.2 针对ingressgateway创建VirtualService
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/04-proxy-gateway# cat virtualservice-proxy.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: proxy
spec:
  hosts:
  - "fe.magedu.com"                     # 对应于gateways/proxy-gateway
  gateways:
  - istio-system/proxy-gateway       	# 相关定义仅应用于Ingress Gateway上
  #- mesh								# 如果也需要应用网格内所有sidecar则将此开启
  http:
  - name: default
    route:
    - destination:
        host: proxy						#此proxy集群被istio自动发现，所以ingress-gateway已经自动发现，不需要再定义DR了
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/04-proxy-gateway# kubectl apply -f gateway-proxy.yaml -f virtualservice-proxy.yaml
root@k8s-master01:~# istioctl proxy-config routes $InGW.istio-system
NAME          DOMAINS                MATCH                  VIRTUAL SERVICE
http.8080     fe.magedu.com          /*                     proxy.default
http.8080     grafana.magedu.com     /*                     grafana-virtualservice.istio-system
http.8080     kiali.magedu.com       /*                     kiali-virtualservice.istio-system
              *                      /healthz/ready*
              *                      /stats/prometheus*

4.14.3 外网配置fe.magedu.com域名解析测试
内网测试v1.1: root@client # while true;do curl proxy/canary; sleep 0.$RANDOM;done
外网测试v1.0: $ while true;do curl -s fe.magedu.com;sleep 0.$RANDOM;done


#高级流量路由机制
5.1 url重定向和重写
场景一：
client -> ingress-gateway 	-> front-proxy/backend -> backend app 
							-> front-proxy/canary -> canary app 
							-> front-proxy/ ->  app 
场景二：
client 			-> 			front-proxy/backend -> backend app 
							-> front-proxy/canary -> canary app 
							-> front-proxy/ ->  app 
注：以上场景都需要满足

5.2 部署backend app
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/05-url-redirect-and-rewrite# cat deploy-backend.yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: backend
    version: v3.6
  name: backendv36
spec:
  progressDeadlineSeconds: 600
  replicas: 2
  selector:
    matchLabels:
      app: backend
      version: v3.6
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: backend
        version: v3.6
    spec:
      containers:
      - image: ikubernetes/gowebserver:v0.1.0
        imagePullPolicy: IfNotPresent
        name: gowebserver
        env:
        - name: "SERVICE_NAME"
          value: "backend"
        - name: "SERVICE_PORT"
          value: "8082"
        - name: "SERVICE_VERSION"
          value: "v3.6"
        ports:
        - containerPort: 8082
          name: web
          protocol: TCP
        resources:
          limits:
            cpu: 50m
---
apiVersion: v1
kind: Service
metadata:
  name: backend
spec:
  ports:
    - name: http-web
      port: 8082
      protocol: TCP
      targetPort: 8082
  selector:
    app: backend
    version: v3.6
---
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/05-url-redirect-and-rewrite# kubectl apply -f deploy-backend.yaml
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/05-url-redirect-and-rewrite# kubectl get svc/backend
NAME      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
backend   ClusterIP   10.68.155.165   <none>        8082/TCP   28s

5.3 部署virtual service，应用在ingress-gateway和整个网格内，应用主机名为proxy和fe.magedu.com的配置
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/05-url-redirect-and-rewrite# cat virtualservice-proxy.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: proxy
spec:
  gateways:
  - istio-system/proxy-gateway		#应用ingress-gateway代理
  - mesh							#应用网格内代理
  hosts:
  - proxy
  - fe.magedu.com
  http:
  - name: redirect
    match:
    - uri:
        prefix: "/backend"
    redirect:
      uri: /
      authority: backend
      port: 8082
  - name: default
    route:
    - destination:
        host: proxy
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/05-url-redirect-and-rewrite# kubectl apply -f virtualservice-proxy.yaml

5.4 测试
root@client # while true;do curl proxy/hostname; sleep 0.$RANDOM;done
Proxying value: ServerName: demoappv10-5c497c6f7c-l9pnf
 - Took 11 milliseconds.
Proxying value: ServerName: demoappv10-5c497c6f7c-l9pnf
 - Took 8 milliseconds.
Proxying value: ServerName: demoappv10-5c497c6f7c-wzvnn
 - Took 6 milliseconds.
Proxying value: ServerName: demoappv10-5c497c6f7c-fgb4n
 - Took 6 milliseconds.
^C
root@client # while true;do curl proxy/canary; sleep 0.$RANDOM;done
Proxying value: iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-dbhd9, ServerIP: 172.20.217.90!
 - Took 7 milliseconds.
Proxying value: iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-9r68w, ServerIP: 172.20.217.83!
 - Took 16 milliseconds.
Proxying value: iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-9r68w, ServerIP: 172.20.217.83!
 - Took 6 milliseconds.
Proxying value: iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-dbhd9, ServerIP: 172.20.217.90!
 - Took 6 milliseconds.
^C
root@client # while true;do curl proxy/^Csleep 0.$RANDOM;done
root@client # curl proxy/backend
root@client # curl -I  proxy/backend
HTTP/1.1 301 Moved Permanently
location: http://backend:8082/
date: Sun, 24 Apr 2022 12:36:27 GMT
server: envoy
transfer-encoding: chunked

6.1 基于集群子集实现金丝雀发布
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/06-weight-based-routing# cat virtualservice-demoapp.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: demoapp
spec:
  hosts:
  - demoapp
  http:
  - name: weight-based-routing
    route:
    - destination:
        host: demoapp
        subset: v10
      weight: 90
    - destination:
        host: demoapp
        subset: v11
      weight: 10
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/06-weight-based-routing# kubectl apply -f virtualservice-demoapp.yaml

7.1 操纵http Head，实现高级流量治理
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/07-headers-operation# cat virtualservice-demoapp.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: demoapp
spec:
  hosts:
  - demoapp
  http:
  - name: canary
    match:
    - headers:
        x-canary:					#对请求标头进行匹配，如果标头为"x-canary": "true"，则路由到v11子集集群，并且将envoy请求上游服务的标头User-Agent设置为Chrome，并且在envoy响应给下游客户端的标头上增加一个标头x-canary: "true"
          exact: "true"
    route:
    - destination:
        host: demoapp
        subset: v11
      headers:
        request:
          set:
            User-Agent: Chrome
        response:
          add:
            x-canary: "true"
  - name: default					#当没有匹配到标头为"x-canary": "true"的请求，则在envoy响应给下游客户端的标头上增加一个标头X-Envoy: test，并且路由给v10子集集群，headers没有在match字段里面都是配置头，这个headers而且是全局标头，并不只限定于某个集群
    headers:
      response:
        add:
          X-Envoy: test
    route:
    - destination:
        host: demoapp
        subset: v10
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/07-headers-operation# kubectl apply -f virtualservice-demoapp.yaml

7.2 测试
--匹配'x-canary: true'标头
root@client # curl -H 'x-canary: true' demoapp:8080
iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-dbhd9, ServerIP: 172.20.217.90!
root@client # curl -I -H 'x-canary: true' demoapp:8080
HTTP/1.1 200 OK
content-type: text/html; charset=utf-8
content-length: 115
server: envoy
date: Tue, 26 Apr 2022 14:03:23 GMT
x-envoy-upstream-service-time: 12
x-canary: true
root@client # curl -H 'x-canary: true' demoapp:8080/user-agent
User-Agent: Chrome

--未匹配'x-canary: true'标头
root@client # curl demoapp:8080
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-l9pnf, ServerIP: 172.20.135.157!
root@client # curl -I demoapp:8080
HTTP/1.1 200 OK
content-type: text/html; charset=utf-8
content-length: 116
server: envoy
date: Tue, 26 Apr 2022 14:04:14 GMT
x-envoy-upstream-service-time: 3
x-envoy: test

root@client # curl demoapp:8080/user-agent
User-Agent: curl/7.67.0

8.1 故障注入--服务韧性配置有关，主要做用是测试服务韧性，好让前端可以做重试、做超时的配置
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/08-fault-injection# cat virtualservice-demoapp.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: demoapp
spec:
  hosts:
  - demoapp
  http:
  - name: canary
    match:
    - uri:
        prefix: /canary			#当匹配到demoapp/canary时重写为demoapp/，并且路由到v11集群，并且将20%的流量做了中断故障，错误响应码为555
    rewrite:
      uri: /
    route:
    - destination:
        host: demoapp
        subset: v11
    fault:
      abort:
        percentage:
          value: 20
        httpStatus: 555
  - name: default
    route:
    - destination:				#未匹配到的流量路由到v10，并且对20%流量做延迟故障，延迟时间为3秒
        host: demoapp
        subset: v10
    fault:
      delay:
        percentage:
          value: 20
        fixedDelay: 3s
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/08-fault-injection# kubectl apply -f virtualservice-demoapp.yaml

8.2 测试
--中断测试
root@client # while true;do curl proxy/canary; sleep 0.$RANDOM;done
Proxying value: iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-dbhd9, ServerIP: 172.20.217.90!
 - Took 7 milliseconds.
Proxying value: iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-9r68w, ServerIP: 172.20.217.83!
 - Took 6 milliseconds.
Proxying value: iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-dbhd9, ServerIP: 172.20.217.90!
 - Took 7 milliseconds.
Proxying value: fault filter abort - Took 4 milliseconds.		#此处有中断
Proxying value: iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-9r68w, ServerIP: 172.20.217.83!
 - Took 8 milliseconds.
Proxying value: fault filter abort - Took 20 milliseconds.
Proxying value: fault filter abort - Took 2 milliseconds.
Proxying value: fault filter abort - Took 4 milliseconds.
Proxying value: iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-dbhd9, ServerIP: 172.20.217.90!
 - Took 7 milliseconds.
Proxying value: iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-9r68w, ServerIP: 172.20.217.83!

--延迟测试
$ while true;do curl -s fe.magedu.com;sleep 0.$RANDOM;done
Proxying value: iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-l9pnf, ServerIP: 172.20.135.157!
 - Took 8 milliseconds.
Proxying value: iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-wzvnn, ServerIP: 172.20.217.101!
 - Took 8 milliseconds.
Proxying value: iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-wzvnn, ServerIP: 172.20.217.101!
 - Took 3047 milliseconds.			#此处有延迟
Proxying value: iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-fgb4n, ServerIP: 172.20.217.72!
 - Took 7 milliseconds.

9 超时、重试--服务韧性上做的应对处理
9.1 配置demoapp VS
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/09-http-retry# cat virtualservice-demoapp.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: demoapp
spec:
  hosts:
  - demoapp
  http:
  - name: canary
    match:
    - uri:
        prefix: /canary
    rewrite:
      uri: /
    route:
    - destination:
        host: demoapp
        subset: v11
    fault:
      abort:
        percentage:
          value: 50				#将中断和延迟率调高到50%，便于测试
        httpStatus: 555
  - name: default
    route:
    - destination:
        host: demoapp
        subset: v10
    fault:
      delay:
        percentage:
          value: 50
        fixedDelay: 3s
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/09-http-retry# kubectl apply -f virtualservice-demoapp.yaml

9.2 配置proxy VS，ingress-gateway -> proxy -> demoapp
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/09-http-retry# cat virtualservice-proxy.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: proxy
spec:
  hosts:
  - "fe.magedu.com"                     # 对应于gateways/proxy-gateway
  gateways:
  - istio-system/proxy-gateway       # 相关定义仅应用于Ingress Gateway上
  #- mesh
  http:
  - name: default
    route:
    - destination:
        host: proxy
    timeout: 1s						# 在前端proxy是做了超时机制，当达到1s后直接响应给客户端超时，让其重试操作
    retries:						
      attempts: 5					
      perTryTimeout: 1s
      retryOn: 5xx,connect-failure,refused-stream	# 重试条件为HTTP 5xx等，重试次数为5次，并且每次重试时间最大为1s，当超过1s执行第二次重试
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/09-http-retry# kubectl apply -f virtualservice-proxy.yaml

9.3 测试
--针对v10集群延迟测试
$ while true;do curl -s fe.magedu.com;sleep 0.$RANDOM;done
upstream request timeoutProxying value: iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-l9pnf, ServerIP: 172.20.135.157!
 - Took 8 milliseconds.
Proxying value: iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-wzvnn, ServerIP: 172.20.217.101!
 - Took 6 milliseconds.
upstream request timeoutProxying value: iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-l9pnf, ServerIP: 172.20.135.157!
 - Took 7 milliseconds.		#前面一个请求达到3s，被前端代理执行1s超时，随即客户端重新发请求，后面一次请求就成功了
Proxying value: iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-fgb4n, ServerIP: 172.20.217.72!
 - Took 8 milliseconds.
upstream request timeoutProxying value: iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-fgb4n, ServerIP: 172.20.217.72!
 - Took 7 milliseconds.
 
--针对v11集群中断测试
$ while true;do curl -s fe.magedu.com/canary;sleep 0.$RANDOM;done
Proxying value: fault filter abort - Took 2 milliseconds.	#中断故障
Proxying value: fault filter abort - Took 2 milliseconds.
Proxying value: fault filter abort - Took 2 milliseconds.
Proxying value: iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-9r68w, ServerIP: 172.20.217.83!	#第3次重试才成功
 - Took 6 milliseconds.
Proxying value: iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-9r68w, ServerIP: 172.20.217.83!
 - Took 6 milliseconds.
Proxying value: iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-dbhd9, ServerIP: 172.20.217.90!
 - Took 7 milliseconds.
Proxying value: iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-dbhd9, ServerIP: 172.20.217.90!
 - Took 7 milliseconds.
Proxying value: fault filter abort - Took 2 milliseconds.
Proxying value: fault filter abort - Took 3 milliseconds.
Proxying value: fault filter abort - Took 3 milliseconds.
Proxying value: iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-9r68w, ServerIP: 172.20.217.83!

10 流量镜像
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/10-traffic-mirror# cat virtualservice-demoapp.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: demoapp
spec:
  hosts:
  - demoapp
  http:
  - name: traffic-mirror
    route:
    - destination:
        host: demoapp
        subset: v10			#100%流量到v10
    mirror:					#100%流量镜像到v11
      host: demoapp
      subset: v11
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/10-traffic-mirror# kubectl apply -f virtualservice-demoapp.yaml


11 集群负载均衡策略
11.1 去除上面的故障注入
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/11-cluster-loadbalancing# cat ../03-demoapp-subset/virutalservice-demoapp.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: demoapp
spec:
  hosts:
  - demoapp
  http:
  - name: canary
    match:
    - uri:
        prefix: /canary
    rewrite:
      uri: /
    route:
    - destination:
        host: demoapp
        subset: v11
  - name: default
    route:
    - destination:
        host: demoapp
        subset: v10
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/11-cluster-loadbalancing# kubectl apply -f ../03-demoapp-subset/virutalservice-demoapp.yaml

11.2 定义负载均衡策略
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/11-cluster-loadbalancing# cat destinationrule-demoapp.yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: demoapp
spec:
  host: demoapp					#访问demoapp集群目标时
  trafficPolicy:
    loadBalancer:
      simple: LEAST_CONN		#全局负载均衡策略为最少连接
  subsets:
  - name: v10
    labels:
      version: v1.0
    trafficPolicy:
      loadBalancer:
        consistentHash:			#针对上游pod标签为version: v1.0的，使用一致性哈希算法，使用一致性哈希算法条件为请求标头为httpHeaderName: X-User，当未匹配到此标头时将使用最少连接算法
          httpHeaderName: X-User
  - name: v11
    labels:
      version: v1.1				#针对上游pod标签为version: v1.1的，未定义负载均衡策略则继承全局负载均衡策略
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/11-cluster-loadbalancing# kubectl apply -f destinationrule-demoapp.yaml

11.3 测试--这里只能使用demoapp进行测试，proxy微服务应用未实现该功能
--针对访问demoapp:8080/canary，会调度到子集v11，到达DestinationRule这里，匹配到v11，由于未定义负载均衡策略则继承全局负载均衡策略
root@client # while true;do curl demoapp:8080/canary; sleep 0.$RANDOM;done
iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-9r68w, ServerIP: 172.20.217.83!
iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-9r68w, ServerIP: 172.20.217.83!
iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-dbhd9, ServerIP: 172.20.217.90!
iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-9r68w, ServerIP: 172.20.217.83!
iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-9r68w, ServerIP: 172.20.217.83!
iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-9r68w, ServerIP: 172.20.217.83!
iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-7984f579f5-dbhd9, ServerIP: 172.20.217.90!

--针对demoapp:8080，会调度到子集v10，到达DestinationRule这里，匹配到v10，由于请求标头不包含标头X-User所以将使用最少连接算法
root@client # while true;do curl demoapp:8080; sleep 0.$RANDOM;done
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-fgb4n, ServerIP: 172.20.217.72!
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-wzvnn, ServerIP: 172.20.217.101!
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-fgb4n, ServerIP: 172.20.217.72!
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-l9pnf, ServerIP: 172.20.135.157!

--针对demoapp:8080，会调度到子集v10，到达DestinationRule这里，匹配到v10，由于请求标头包含标头X-User所以将使用一致性哈希算法
root@client # while true;do curl -H 'X-User: test' demoapp:8080; sleep 0.$RANDOM;done
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-fgb4n, ServerIP: 172.20.217.72!
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-fgb4n, ServerIP: 172.20.217.72!
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-fgb4n, ServerIP: 172.20.217.72!
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-fgb4n, ServerIP: 172.20.217.72!

12 连接池
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/12-connection-pool# cat destinationrule-demoapp.yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: demoapp
spec:
  host: demoapp
  trafficPolicy:
    loadBalancer:
      simple: LEAST_CONN
    connectionPool:
      tcp:						#针对tcp协议
        maxConnections: 100		#最大连接数
        connectTimeout: 30ms	#连接超时时间
        tcpKeepalive:			#tcp长连接
          time: 7200s			#长连接时间
		  interval: 75s			#每次检测时间为75s一次，当7200秒内没有新会话则将断开
      http:								#针对http
        http2MaxRequests: 1000			#http2 最大请求数
        maxRequestsPerConnection: 10	#针对每个连接的最大请求数
  subsets:
  - name: v10
    labels:
      version: v1.0
    trafficPolicy:
      loadBalancer:
        consistentHash:
          httpHeaderName: X-User	
  - name: v11
    labels:
      version: v1.1

13 istio断路器----envoy叫异常值探测，envoy有真正的断路器
13.1 部署istio断路器
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/13-outlier-detection# cat destinationrule-demoapp.yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: demoapp
spec:
  host: demoapp
  trafficPolicy:
    loadBalancer:
      simple: RANDOM
    connectionPool:
      tcp:
        maxConnections: 100
        connectTimeout: 30ms
        tcpKeepalive:
          time: 7200s
          interval: 75s
      http:
        http2MaxRequests: 1000
        maxRequestsPerConnection: 10
    outlierDetection:					#断路器
      maxEjectionPercent: 50			#最大弹出为50%
      consecutive5xxErrors: 5			#连续的5xx错误达到5次将弹出1次
      interval: 10s						#每隔10s钟对弹出的洗衣机进行检测，看是否正常，如若还未正常将在弹出时间X次数
      baseEjectionTime: 1m				#基础弹出时间为1m
      minHealthPercent: 40				#最小健康节点为40%，当小于此百分比时将禁用断路器功能
  subsets:
  - name: v10
    labels:
      version: v1.0
  - name: v11
    labels:
      version: v1.1
root@k8s-master01:~/istio/istio-in-practise/Traffic-Management-Basics/ms-demo/13-outlier-detection# kubectl apply -f destinationrule-demoapp.yaml

13.2 测试
--将v10的上游一节点置为5XX错误
root@k8s-master01:~# curl -X POST -d 'livez=FAIL' 172.20.217.72:8080/livez
root@k8s-master01:~# curl 172.20.217.72:8080/livez
FAIL
root@k8s-master01:~# curl -I 172.20.217.72:8080/livez
HTTP/1.1 506 Variant Also Negotiates				#此时为5XX错误
content-type: text/html; charset=utf-8
content-length: 4
server: istio-envoy
date: Tue, 26 Apr 2022 15:38:39 GMT
x-envoy-upstream-service-time: 1
x-envoy-decorator-operation: demoapp.default.svc.cluster.local:8080/*

--请求proxy/livez测试看弹出效果
root@client # while true;do curl proxy/livez; sleep 0.$RANDOM;done
Proxying value: OK - Took 7 milliseconds.
Proxying value: OK - Took 19 milliseconds.
Proxying value: OK - Took 8 milliseconds.
Proxying value: FAIL - Took 34 milliseconds.				#错误5XX 1次
Proxying value: OK - Took 19 milliseconds.
Proxying value: OK - Took 7 milliseconds.
Proxying value: OK - Took 7 milliseconds.
Proxying value: FAIL - Took 5 milliseconds.
Proxying value: OK - Took 8 milliseconds.
Proxying value: OK - Took 6 milliseconds.
Proxying value: OK - Took 9 milliseconds.
Proxying value: OK - Took 8 milliseconds.
Proxying value: FAIL - Took 5 milliseconds.
Proxying value: FAIL - Took 15 milliseconds.
Proxying value: OK - Took 16 milliseconds.
Proxying value: OK - Took 5 milliseconds.
Proxying value: OK - Took 6 milliseconds.
Proxying value: OK - Took 6 milliseconds.
Proxying value: FAIL - Took 7 milliseconds.					#错误5XX 5次，将弹出上游节点1次，第一次1分钟，第二次2分钟，第三次3分钟
Proxying value: OK - Took 8 milliseconds.
Proxying value: OK - Took 8 milliseconds.
Proxying value: OK - Took 10 milliseconds.
Proxying value: OK - Took 9 milliseconds.
Proxying value: OK - Took 18 milliseconds.
Proxying value: OK - Took 7 milliseconds.

--将上游节点状态由5xx调整为200，则弹出上游节点此后将不会在被弹出
root@k8s-master01:~# curl -X POST -d 'livez=OK' 172.20.217.72:8080/livez
root@k8s-master01:~# curl -I 172.20.217.72:8080/livez
HTTP/1.1 200 OK
content-type: text/html; charset=utf-8
content-length: 2
server: istio-envoy
date: Tue, 26 Apr 2022 15:45:18 GMT
x-envoy-upstream-service-time: 2
x-envoy-decorator-operation: demoapp.default.svc.cluster.local:8080/*




#istio核心功能：
- 流量治理
  - VirtualService
  - DestinationRule
- 安全
- 可观测性

####Sidecar及流量拦截机制

#Istio环境中运行Pod的要求
- Service association(服务关联)
  - Pod必须从属于某个Service，哪怕Pod不需要暴露任何端口
  - 同时从属于多个Service时，这些Service不能为该类Pod的同一端口标识使用不同的协议
- Application UIDs
  - UID 1337预留给了Sidecar Proxy使用，业务应用不能以这一UID运行
- NET_ADMIN and NET_RAW capabilities
  - 强制启用了PSP（Pod Security Policy）的Kubernetes环境中，必须允许在网格内的Pod上使用NET_ADMIN和NET_RAW这两个capability，以确保Sidecar Envoy依赖的初始化Pod能够正常运行
  - 未启用PSP，或者启用了PSP但使用了专用的Istio CNI Plugin的场景，可以不用
- Pods with app and version labels
  - 显示地为Pod使用app和version标签
  - app标签用于为分布式追踪生成context，而label则用于指示应用的版本化
- Named service ports
  - Service Port应该明确指定使用的协议
  - 命令格式：
    - <protocol>[-<suffix>]
	- Kubernetes v1.18及之后的版本中，可以直接使用appProtocol字段进行标识。(推荐使用此新格式)

#协议选择
- Istio支持代理的协议
  - 支持代理任何类型的TCP流量，包括HTTP、HTTPS、gRPC及原始TCP（raw tcp）协议
  - 但为了提供额外的能力，比如路由和更加丰富的指标，Istio需要确定更具体的协议（应用层协议）
  - Istio不会代理UDP协议
- 协议选择
  - Istio能够自动检测并识别HTTP和HTTP/2的流量，未检测出的协议类型将一律视为普通的TCP流量
  - 也支持由用户手动指定
- 手动指定协议
  - Service Port应该明确指定使用的协议
  - 命令格式：
    - <protocol>[-<suffix>]，通过name定义
	- Kubernetes v1.18及之后的版本中，可以直接使用appProtocol字段进行标识。(推荐使用此新格式)
- Istio支持的协议类型如下：
  - http, http2 可以自动识别
  - https, tcp, tls, grpc
  - grpc-web, mongo, mysql, redis
  
#Sidecar代理方式简介
- Kubernetes平台上，Envoy Sidecar容器与application容器于同一个Pod中共存，它们共享NETWORK、UTS、和IPC等名称空间，因此也共用同一个网络协议栈
  - Envoy Sidecar基于init容器（需要使用NET_ADMIN和NET_RAW Capability于Pod启动时设置Iptables规则以实现流量拦截）
    - 入站流量由Iptables拦截后转发给Envoy Sidecar
	- Envoy Sidecar根据配置完成入站流量代理
	- 后端应用程序生成的出站流量依然由Iptables拦截并转发给Envoy Sidecar
	- Envoy Sidecar根据配置完成出站流量代理
- 流量拦截模式
  - REDIRECT: 重定向模式
  - TPROXY: 透明代理模式
 
#Istio注入的Envoy Sidecar
- Istio基于Kubernetes Admission Controller webhook完成sidecar自动注入，它会为每个微服务分别添加两个相关的容器
  - istio-init: 隶属于Init Containers，即初始化容器，负责在微服务相关的Pod中生成iptables规则以进行流量拦截并向Envoy Proxy进行转发；运行完成后退出；
  - istio-proxy: 隶属于Containers，即Pod中的正常窗口，程序为Envoy Proxy；
#Istio初始化容器
- istio-init初始化容器基于istio/proxyv2镜像启动，它运行istio-iptables程序以生成流量拦截规则
  - 拦截的流量将转发至两个相关的端口
    - 15006：由z选项定义，指定用于接收拦截所有发往当前Pod/VM的入站流量的目标商品，该配置仅用于REDIRECT转发模式
	- 15001：由p选项定义，指定用于接收拦截的所有TCP流量的目标端口
  - 流量拦截模式由-m选项指定，目前支持REDIRECT和TPROXY两种模式
  - 流量拦截时要包含的目标端口列表使用-o选项指定，而要排除的目标端口列表则使用-d选项指定
  - 流量拦截时要包含的目标CIDR地址列表可使用-i选项指定，而要排除的目标CIDR格式的地址列表则使用-x选项指定
- 此前版本中，该初始化容器会运行一个用于生成iptables规则的相关脚本来生成iptables规则，脚本地址为：https://github.com/istio/cni/blob/master/tools/packaging/common/istio-iptables.sh 
  
#istio-init初始化容器配置的iptables规则 
[root@k8s-node04 ~]# nsenter -t 25088 -n iptables -t nat -S
-P PREROUTING ACCEPT
-P INPUT ACCEPT
-P OUTPUT ACCEPT
-P POSTROUTING ACCEPT
-N ISTIO_INBOUND
-N ISTIO_IN_REDIRECT
-N ISTIO_OUTPUT
-N ISTIO_REDIRECT
-A PREROUTING -p tcp -j ISTIO_INBOUND
-A OUTPUT -p tcp -j ISTIO_OUTPUT
-A ISTIO_INBOUND -p tcp -m tcp --dport 15008 -j RETURN
-A ISTIO_INBOUND -p tcp -m tcp --dport 22 -j RETURN
-A ISTIO_INBOUND -p tcp -m tcp --dport 15090 -j RETURN
-A ISTIO_INBOUND -p tcp -m tcp --dport 15021 -j RETURN
-A ISTIO_INBOUND -p tcp -m tcp --dport 15020 -j RETURN
-A ISTIO_INBOUND -p tcp -j ISTIO_IN_REDIRECT
-A ISTIO_IN_REDIRECT -p tcp -j REDIRECT --to-ports 15006			#入向流量重写向端口
-A ISTIO_OUTPUT -s 127.0.0.6/32 -o lo -j RETURN
-A ISTIO_OUTPUT ! -d 127.0.0.1/32 -o lo -m owner --uid-owner 1337 -j ISTIO_IN_REDIRECT
-A ISTIO_OUTPUT -o lo -m owner ! --uid-owner 1337 -j RETURN
-A ISTIO_OUTPUT -m owner --uid-owner 1337 -j RETURN
-A ISTIO_OUTPUT ! -d 127.0.0.1/32 -o lo -m owner --gid-owner 1337 -j ISTIO_IN_REDIRECT
-A ISTIO_OUTPUT -o lo -m owner ! --gid-owner 1337 -j RETURN
-A ISTIO_OUTPUT -m owner --gid-owner 1337 -j RETURN
-A ISTIO_OUTPUT -d 127.0.0.1/32 -j RETURN
-A ISTIO_OUTPUT -j ISTIO_REDIRECT
-A ISTIO_REDIRECT -p tcp -j REDIRECT --to-ports 15001				#出向流量重写向端口
#istio-proxy使用的端口
[root@k8s-node04 ~]# nsenter -t 25088 -n ss -tnl
State       Recv-Q Send-Q                    Local Address:Port                                   Peer Address:Port
LISTEN      0      4096                                  *:15090                                             *:*	#Envoy prometheus telemetry
LISTEN      0      4096                                  *:15090                                             *:*
LISTEN      0      4096                          127.0.0.1:15000                                             *:*	#envoy admin port
LISTEN      0      4096                                  *:15001                                             *:*	#envoy outbound
LISTEN      0      4096                                  *:15001                                             *:*
LISTEN      0      4096                          127.0.0.1:15004                                             *:*	#debut port
LISTEN      0      4096                                  *:15006                                             *:*	#envoy inbound
LISTEN      0      4096                                  *:15006                                             *:*
LISTEN      0      4096                                  *:15021                                             *:*	#Health checks
LISTEN      0      4096                                  *:15021                                             *:*	
LISTEN      0      128                                   *:8080                                              *:*
LISTEN      0      4096                               [::]:15020                                          [::]:*	#merged prometheus telemetry from istio agent,Envoy, and application
注：另外端口:
- 15008 HBONE mTLS tunnel port 
- 15009	HBONE port for secure networks
- 15053	DNS port,if capture is enabled 
注：流量拦截规则只在sidecar envoy上应用，在gateway envoy上不是应用的
#控制平面使用的端点
443 	HTTPS			Webhooks service port
8080	HTTP			Debug interface(deprecated, container port only)
15010	GRPC			XDS and CA services(Plaintext, only for secure networks)
15012	GRPC 			XDS and CA services(TLS and mTLS, recommended for production use)
15014	HTTP			Control plane monitoring
15017	HTTPS			Webhook container port, forwarded from 443




#istio-proxy容器
- istio-proxy即所谓的sidecar容器，它运行两个进程
  - pilot-agent
    - 基于k8s api server为envoy初始化出可用的bootstrap配置文件并启动envoy
	- 监控并管理envoy的运行状态，包括envoy出错时重启envoy，以及envoy配置变更后将其重载等
  - envoy
    - envoy由pilot-agent进程基于生成bootstrap配置进行启动，而后根据配置中指定的pilot地址，通过xDS API获取动态配置信息
	- Sidecar形式的Envoy通过流量拦截机制为应用程序实现入站和出站代理功能
root@k8s-master01:~# kubectl exec demoappv10-5c497c6f7c-fgb4n -c istio-proxy -- ps -ef
UID        PID  PPID  C STIME TTY          TIME CMD
istio-p+     1     0  0 Apr23 ?        00:11:59 /usr/local/bin/pilot-agent proxy sidecar --domain default.svc.cluster.local --proxyLogLevel=warning --proxyComponentLogLevel=misc:error --log_output_level=default:info --concurrency 2
istio-p+    18     1  0 Apr23 ?        00:16:30 /usr/local/bin/envoy -c etc/istio/proxy/envoy-rev0.json --restart-epoch 0 --drain-time-s 45 --drain-strategy immediate --parent-shutdown-time-s 60 --local-address-ip-version v4 --file-flush-interval-msec 1000 --disable-hot-restart --log-format %Y-%m-%dT%T.%fZ.%l.envoy %n.%v -l warning --component-log-level misc:error --concurrency 2
istio-p+    36     0  0 10:05 ?        00:00:00 ps -ef
----以后可以通过pilot-agent命令进行调试
root@k8s-master01:~# kubectl exec demoappv10-5c497c6f7c-fgb4n -c istio-proxy -- pilot-agent --help
root@k8s-master01:~# kubectl exec demoappv10-5c497c6f7c-fgb4n -c istio-proxy -- pilot-agent request GET /listeners		
6c3eeea6-af8f-4539-9570-6b0e5af640ea::0.0.0.0:15090
28a0e75b-1a73-4a25-8696-a9d88fab7758::0.0.0.0:15021
172.168.2.22_10250::172.168.2.22:10250
172.168.2.21_10250::172.168.2.21:10250
192.168.13.63_10250::192.168.13.63:10250
10.68.73.229_31400::10.68.73.229:31400
172.168.2.23_10250::172.168.2.23:10250
10.68.72.41_443::10.68.72.41:443
10.68.155.123_443::10.68.155.123:443
10.68.24.41_15012::10.68.24.41:15012
10.68.24.41_443::10.68.24.41:443
10.68.147.77_443::10.68.147.77:443
10.68.73.229_443::10.68.73.229:443
10.68.0.2_53::10.68.0.2:53
10.68.230.242_443::10.68.230.242:443
172.168.2.26_10250::172.168.2.26:10250
172.168.2.25_10250::172.168.2.25:10250
10.68.73.229_15443::10.68.73.229:15443
10.68.0.1_443::10.68.0.1:443
172.168.2.24_10250::172.168.2.24:10250
0.0.0.0_8080::0.0.0.0:8080
10.68.16.146_8080::10.68.16.146:8080
0.0.0.0_9411::0.0.0.0:9411
0.0.0.0_10255::0.0.0.0:10255
172.168.2.22_4194::172.168.2.22:4194
192.168.13.63_4194::192.168.13.63:4194
10.68.20.27_8000::10.68.20.27:8000

#istio-proxy Listener
- Envoy Listener支持绑定于IP Socket或Unix Domain Socket之上，也可以不予绑定，而是接收由其它的Listener转发来的数据
  - VirtualOutboundListener通过一个端口接收所有的出向流量(此端口也可以不绑定在套接字之上，通过netstat看不到)，而后再按照请求的端口分别转发给相应的Listener进行处理
  - VirtualInboundListener的功能相似，但它主要用于处理入向流量
- VirtualOutbound Listener
  - iptables将其所在的Pod中的外发流量拦截后转发至监听于15001的Listener，而该Listener通过在配置中将"use_origin_dest参数"设置为true，从而实现将接收到的请求转交给同请求原目标地址关联的Listener之上
  - 若不存在可接收转发报文的Listener，则Envoy将根据istio的全局配置选项outboundTrafficPolicy参数的值决定如何进行处理
    - ALLOW_ANY：允许外发至任何服务的请求，无论目标服务是否存在于Pilot的注册表中；此时，没有匹配的目标Listener的流量将由该侦听器上tcp_proxy过滤器指向的PassthroughCluster进行透传
	- REGISTRY_ONLY：仅允许外发请求至注册Pilot中的服务；此时，没有匹配的目标Listener的流量将由该侦听器上tcp_proxy过滤器指向的BlackHoleCluster将流量直接丢弃
  - Envoy将按需为其所处网格中的各外部服务按端口创建多个Listener以处理出站流量，以productpage为例，它将存在：
    - 0.0.0.0_9080: 处理发往details, reviews和rating等服务的流量;实际就是类似demoapp的微服务程序
    - 0.0.0.0_9411: 处理发往zipkin的流量
    - 0.0.0.0_3000: 处理发往grafana的流量
    - 0.0.0.0_9090: 处理发往prometheus的流量
    ...
- VirtualInbound Listener 
  - 入向流量劫持
    - 较早版本的Istio基于同一个VirtualListener在15001端口上同时处理入站和出站流量
	- 自1.4版本起，Istio引入了REDIRECT代理模式，它通过监听于15006端口的专用VirtualInboundListener处理入向流量代理以规避潜在的死循环问题
  - 入向流量处理
    - 对于进入到侦听器"0.0.0.0:15006"的流量，VirtualInboundListener会在filterChains中，通过一系列的filter_chain_match对流量进行匹配检测，以确定应该由哪个或哪些过滤器进行流量处理
- 注：不管是VirtualOutbound Listener或VirtualInbound Listener，sidecar都不会监听本地套接字的(除开自身提供服务的套接字)，都是由15001和15006 Listener接收并去匹配条目后到达目标地址的
  
root@k8s-master01:~# istioctl pc listeners demoappv10-5c497c6f7c-fgb4n
0.0.0.0       15006 Addr: *:15006                                                                                   Non-HTTP/Non-TCP
0.0.0.0       15006 Trans: tls; App: istio-http/1.0,istio-http/1.1,istio-h2; Addr: 0.0.0.0/0                        InboundPassthroughClusterIpv4
0.0.0.0       15006 Trans: raw_buffer; App: HTTP; Addr: 0.0.0.0/0                                                   InboundPassthroughClusterIpv4
0.0.0.0       15006 Trans: tls; App: TCP TLS; Addr: 0.0.0.0/0                                                       InboundPassthroughClusterIpv4
0.0.0.0       15006 Trans: raw_buffer; Addr: 0.0.0.0/0                                                              InboundPassthroughClusterIpv4
0.0.0.0       15006 Trans: tls; Addr: 0.0.0.0/0                                                                     InboundPassthroughClusterIpv4
0.0.0.0       15006 Trans: tls; App: istio,istio-peer-exchange,istio-http/1.0,istio-http/1.1,istio-h2; Addr: *:8080 Cluster: inbound|8080||
0.0.0.0       15006 Trans: raw_buffer; Addr: *:8080                                                                 Cluster: inbound|8080||
注：tls表示https加密，raw_buffer表示http明文

#Istio-proxy上的动态集群
- 动态集群类型
  - Inbound Cluster: Sidecar Envoy直接代理的应用，同一Pod中，由Sidecar Envoy反向代理的应用容器
  - Outbound Cluster：网格中的所有服务，包括当前Sidecar Envoy直接代理的服务，该类Cluster占了Envoy可用集群中的绝大多数
  - PassthroughCluster和InboundPassthroughClusterv4：发往此类集群的请求报文会被直接透传至其请求中的原始目标地址，Envoy不会进行重新路由
  - BlackHoleCluster：Envoy的一个特殊集群，它没有任何可用的endpoint，接收到的请求会被直接丢弃；未能正确匹配到目标服务的请求通常会被发往此Cluster
  

###流量劫持

#Sidecar CR
- Sidecar CR
  - 默认情况下，Istio会配置每一个Sidecar Envoy能够与同一网格内所有的workload实例通信，并且能够在与其代理的workload相关的所有端口上接收流量
  - 从实际通信需求来说，网格内的每个workload未必需要同当前网格内的所有其它workload通信，于是，Sidecar CR提供了"为Sidecar Envoy微调其用于workload间通信时支持的端口集和协议"等配置的方式
  - 另外，转发来自其代理的workload实例的出向流量时，Sidecar CR资源对象还能够限制Sidecar Envoy可以访问的外部服务集
- Sidecar CR的生效机制
  - Sidecar CR通过workloadSelector字段挑选同一名称空间中的一个或多个workload实例来应用其提供的配置
  - 对于未提供workloadSelector字段Sidecar资源，其配置将应用于同一名称空间中的所有workload实例
  - namespace中同时存在带有workloadSelector字段以及未附带此字段的Sidecar资源对象时，workload实例将优先应用带有此字段的Sidecar对象
  - 每个namespace中仅应该提供一个未附带workloadSelector字段的Sidecar资源，否则其配置结果将难以确定
  - 另外，每个workload也应该仅应用一个带有workloadSelector字段Sidecar资源，否则其行为同样难以明确
  
#sidecar示例
root@client # curl 127.0.0.1:15000/listeners		#没有配置任何sidecar时，所有service将自动配置为Egress
97a71e13-18b6-4fa0-a169-1ff8ed5d5cf1::0.0.0.0:15090
b12160f3-31ca-4934-8b0c-3496d5f183c8::0.0.0.0:15021
10.68.0.2_53::10.68.0.2:53
10.68.73.229_443::10.68.73.229:443
10.68.73.229_15443::10.68.73.229:15443
10.68.147.77_443::10.68.147.77:443
172.168.2.25_10250::172.168.2.25:10250
10.68.73.229_31400::10.68.73.229:31400
10.68.155.123_443::10.68.155.123:443
10.68.24.41_443::10.68.24.41:443
10.68.72.41_443::10.68.72.41:443
10.68.0.1_443::10.68.0.1:443
172.168.2.26_10250::172.168.2.26:10250
10.68.230.242_443::10.68.230.242:443
172.168.2.23_10250::172.168.2.23:10250
172.168.2.24_10250::172.168.2.24:10250
192.168.13.63_10250::192.168.13.63:10250
172.168.2.21_10250::172.168.2.21:10250
10.68.24.41_15012::10.68.24.41:15012
172.168.2.22_10250::172.168.2.22:10250
0.0.0.0_15014::0.0.0.0:15014
10.68.113.201_3000::10.68.113.201:3000
10.68.53.65_14250::10.68.53.65:14250
0.0.0.0_8080::0.0.0.0:8080
0.0.0.0_15010::0.0.0.0:15010
10.68.252.108_9090::10.68.252.108:9090
10.68.16.146_8080::10.68.16.146:8080
0.0.0.0_9411::0.0.0.0:9411
10.68.53.65_14268::10.68.53.65:14268
172.168.2.23_4194::172.168.2.23:4194
0.0.0.0_10255::0.0.0.0:10255
172.168.2.24_4194::172.168.2.24:4194
192.168.13.63_4194::192.168.13.63:4194
0.0.0.0_16685::0.0.0.0:16685
10.68.0.2_9153::10.68.0.2:9153
10.68.127.217_443::10.68.127.217:443
172.168.2.21_4194::172.168.2.21:4194
172.168.2.22_4194::172.168.2.22:4194
172.168.2.26_4194::172.168.2.26:4194
0.0.0.0_20001::0.0.0.0:20001
0.0.0.0_80::0.0.0.0:80
0.0.0.0_9090::0.0.0.0:9090
172.168.2.25_4194::172.168.2.25:4194
10.68.73.229_15021::10.68.73.229:15021
10.68.20.27_8000::10.68.20.27:8000
virtualOutbound::0.0.0.0:15001
virtualInbound::0.0.0.0:15006
0.0.0.0_8082::0.0.0.0:8082
--配置sidecar
root@k8s-master01:~/istio/istio-in-practise# cat sidecar-demo.yaml
apiVersion: networking.istio.io/v1beta1
kind: Sidecar
metadata:
  name: client
  namespace: default
spec:
  workloadSelector:
    labels:
      run: client			#在default名称空间匹配标签run: client的pod生效以下配置，这里匹配到的是client
  egress:
  - port:
      number: 8080
      name: demoapp
      protocol: HTTP	
    hosts:					#生成egress配置的目标，在当前名称空间下(default)/所有service(*)中，service名称为demoapp、端口为8080、协议是HTTP的service将会被映射为egerss
    - "./*"
  outboundTrafficPolicy:	#service名称不是demoapp、端口为8080、协议是HTTP的service的出方向流量策略，REGISTRY_ONLY将会被丢弃(BlackHoleCluster)，如果是ALLOW_ANY则会使用透传功能(PassthroughCluster)
    mode: REGISTRY_ONLY
root@k8s-master01:~/istio/istio-in-practise# kubectl apply -f sidecar-demo.yaml		#应用sidecar

--客户端查看是否只有demoapp相关的listener
root@client # curl 127.0.0.1:15000/listeners
97a71e13-18b6-4fa0-a169-1ff8ed5d5cf1::0.0.0.0:15090		#prometheus相关接口
b12160f3-31ca-4934-8b0c-3496d5f183c8::0.0.0.0:15021		#health check相关接口
0.0.0.0_8080::0.0.0.0:8080				#此是我们定义demoapp的service
virtualOutbound::0.0.0.0:15001							#OutBoundListener
virtualInbound::0.0.0.0:15006							#InBoundListener

--测试sidecar配置是否如预期一样
root@client # curl demoapp:8080		#访问成功
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-fgb4n, ServerIP: 172.20.217.72!
root@client # curl proxy			#因为没有egress，将会使用REGISTRY_ONLY流量策略
curl: (56) Recv failure: Connection reset by peer

--调整流量策略为ALLOW_ANY
root@k8s-master01:~/istio/istio-in-practise# cat sidecar-demo.yaml
apiVersion: networking.istio.io/v1beta1
kind: Sidecar
metadata:
  name: client
  namespace: default
spec:
  workloadSelector:
    labels:
      run: client
  egress:
  - port:
      number: 8080
      name: demoapp
      protocol: HTTP
    hosts:
    - "./*"
  outboundTrafficPolicy:
   #mode: REGISTRY_ONLY
    mode: ALLOW_ANY			
root@k8s-master01:~/istio/istio-in-practise# kubectl apply -f sidecar-demo.yaml

--调整流量策略为ALLOW_ANY
root@client # curl demoapp:8080
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-fgb4n, ServerIP: 172.20.217.72!
root@client # curl proxy		#因为流量策略为ALLOW_ANY，所以使用透传，这里的流量将不会经过sidecar envoy，所以也无法通过istio实现高级流量治理
Proxying value: iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-l9pnf, ServerIP: 172.20.135.157!
 - Took 8 milliseconds.

#访问网格外部目标--ServiceEntry
##出向流量治理、出向流量网关
- Sidecar Egress Listener如何处理访问外部目标的流量？
  - 在默认"ALLOW_ANY"外部流量策略下，Sidecar Envoy支持将这些流量直接Passthrough到外部的端口之上
  - 但这些外部目标流量无法纳入到治理体系中，实施如retry, timeout, fault injection一类的功能
- ServiceEntry CR就用于向Istio内部维护的服务注册表(Registry)上手动添加注册项（即Entry）从而将那些未能自动添加至网格中的服务，以手动形式添加至网格中
  - 向Istio的服务注册表添加一个ServiceEntry后，网格中的Envoy可以流量发送给该Service，其行为与访问网格中原有的服务并无本质上的不同
  - 于是，有了ServiceEntry，用户也就能像治理网格内部流量一样来治理那些访问到网格外部的服务的流量
#ServiceEntry
- ServiceEntry的功能
  - 重定向和转发访问外部目标的流量，例如那些访问网格外部的传统服务的流量
  - 为外部的目标添加retry, timeout, fault injection, circuit breaker等一类的功能
  - 将VM（Virtual Machine）添加至网格中，从而能够在VM上运行网格的服务
  - 将不同集群中的服务添加至网格中，从而在Kubernetes上配置多集群的Istio网格
- 注意事项
  - 访问外部服务时，Sidecar Envoy本身就支持将这些流量直接Passthrough到外部的端点之上，因此，定义ServiceEntry并非必须进行的操作
  - ServiceEntry主要是为更好地治理这些流量而设计
  - 但ServiceEntry只是为更好地治理这些访问到外部的流量提供了接口，具体的治理机制还要靠VirtualService和DestinationRule进行定义
- ServiceEntry用于将未能自动添加至网格中的服务，以手动形式添加网格中，以使得网格内的自动发现机制能够访问或路由到这些服务
  - 未能自动添加至网格中的服务的类型
    - 网格外部的服务
	  - 运行行Kubernetes上，但却不是Istio网格管理的名称空间中的Pod，或者是Kuberentes集群外部的VM或裸服务器上
	  - 在ServiceEntry中，这类服务称为MESH_EXTERNAL
- ServiceEntry CR资源的定义
  - ServiceEntry本身用于描述要引入的外部服务的属性，主要包括服务的DNS名称、IP地址、端口、协议和相关的端点等
  - 端点的获取方式有三种：
    - DNS名称解析
	- 静态指定：直接指定要使用端点
	- 使用workloadSelector：基于标签选择器匹配Kubernetes Pod，或者由WorkloadEntry CR引入到网格中的外部端点
#ServiceEntry如何定义外部服务
- 关键配置项
  - hosts: 用于在VirtualServices和DestinationRules中选择匹配的主机，通常需要指定外部服务对应的主机名或DNS域名
    - HTTP流量中，对应于HTTP标头中的Host/Authority
	- HTTPS/TLS流量中，对应于SNI
  - location: 服务的位置
    - MESH_EXTERNAL: 表示服务在网格外部，需要通过API进行访问接口
	- MESH_INTERNAL: 表示服务是网格中的一部分，通常用于在扩展风格时显式进行服务添加
  - ports: 服务使用的端口
  - resolution: 服务的解析方式，用于指定如何解析与服务关联的各端点的IP地址
    - NONE: 假设传入的连接已经被解析到特定的IP地址
	- STATIC：使用endpoints字段中指定的静态IP地址作为与服务关系的实例
	- DNS：通过异步查询DNS来解析IP地址；类似于Envoy Cluster发现Endpoint的STRICT_DNS
	- DNS_ROUND_ROBIN: 通过异步查询DNS来解析IP地址，但与前者不同的是，仅在需要启动新连接时使用返回的第一个IP地址，而不依赖于DNS解析的完整结果；类似于Envoy Cluster发现Endpoint的LOGICAL_DNS
  - endpoints: 静态指定的各端点，定义端点的关键字段为address和ports
  - workloadSelector：使用标签选择器动态选择ServiceEntry要用到的端点，但不能与endpoints同时使用；劫持选择
    - 由WorkloadEntry CR定义的外部端点对象
	- Kubernetes集群上特定Pod对象
#ServiceEntry的逻辑意义
- ServiceEntry之于Istio来说，其功能类似于自动发现并注册的Service对象，主要负责于网格中完成如下功能
  - 基于指定的端口创建Listener，若已存在相应的侦听器，则于侦听器上基于hosts的定义，生成VirtualHost
  - 基于解析(resolution)得到的端点创建Cluster
  - 生成Route Rule，设定侦听器将接收到的发往相应VirtualHost的流量，路由至生成的Cluster
- 自定义流量管理机制
  - 可自定义VirtualService修改ServiceEntry默认生成的Routes
    - 通过指定的hosts(主机名)适配到要修改的Route的位置
    - 路由目标配置等可按需进行定义，包括将流量路由至其它目标
  - 可自定义DestinationRule修改ServiceEntry默认生成的Cluster
    - 通过指定的hosts(主机名)适配到要修改的Cluster
    - 常用于集群添加各种高级设定，例如subset, circuit breaker, traffic policy等

#模拟外部服务引入网格示例
1. 配置多个地址
root@front-envoy:~# ip a s eth0
eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:0c:29:f8:c8:91 brd ff:ff:ff:ff:ff:ff
    inet 172.168.2.32/24 brd 172.168.2.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet 172.168.2.33/24 brd 172.168.2.255 scope global secondary eth0
       valid_lft forever preferred_lft forever
    inet 172.168.2.34/24 brd 172.168.2.255 scope global secondary eth0
       valid_lft forever preferred_lft forever
    inet 172.168.2.35/24 brd 172.168.2.255 scope global secondary eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fef8:c891/64 scope link
       valid_lft forever preferred_lft forever

2. 运行nginx服务，模拟集群外3个实例
root@front-envoy:~/istio-in-practise/ServiceEntry-and-WorkloadEntry/00-Deploy-Nginx# cat docker-compose.yml
version: '3.3'

services:
  nginx2001:
    image: nginx:1.20-alpine
    volumes:
      - ./html/nginx2001:/usr/share/nginx/html/
    networks:
      envoymesh:
        ipv4_address: 172.31.201.11
        aliases:
        - nginx
    expose:
      - "80"
    ports:
      - "172.168.2.33:8091:80"

  nginx2002:
    image: nginx:1.20-alpine
    volumes:
      - ./html/nginx2002:/usr/share/nginx/html/
    networks:
      envoymesh:
        ipv4_address: 172.31.201.12
        aliases:
        - nginx
    expose:
      - "80"
    ports:
      - "172.168.2.34:8091:80"

  nginx2101:
    image: nginx:1.21-alpine
    volumes:
      - ./html/nginx2101:/usr/share/nginx/html/
    networks:
      envoymesh:
        ipv4_address: 172.31.201.13
        aliases:
        - nginx
        - canary
    expose:
      - "80"
    ports:
      - "172.168.2.35:8091:80"

networks:
  envoymesh:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.201.0/24
root@front-envoy:~/istio-in-practise/ServiceEntry-and-WorkloadEntry# cat 00-Deploy-Nginx/html/nginx2*/*
<title>nginx.magedu.com</title>
Nginx 2001 ~~
<title>nginx.magedu.com</title>
Nginx 2002 ~~
<title>nginx.magedu.com</title>
Nginx 2101 ~~
root@front-envoy:~/istio-in-practise/ServiceEntry-and-WorkloadEntry/00-Deploy-Nginx# docker-compose up -d
--本机测试	
root@front-envoy:~/istio-in-practise/ServiceEntry-and-WorkloadEntry/00-Deploy-Nginx# curl 172.168.2.33:8091
<title>nginx.magedu.com</title>
Nginx 2001 ~~
root@front-envoy:~/istio-in-practise/ServiceEntry-and-WorkloadEntry/00-Deploy-Nginx# curl 172.168.2.34:8091
<title>nginx.magedu.com</title>
Nginx 2002 ~~
root@front-envoy:~/istio-in-practise/ServiceEntry-and-WorkloadEntry/00-Deploy-Nginx# curl 172.168.2.35:8091
<title>nginx.magedu.com</title>
Nginx 2101 ~~

3. 移除之前定义的sidecar，以免混乱
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/01-Service-Entry# kubectl delete sidecar --all
sidecar.networking.istio.io "client" deleted

4. 部署ServiceEntry，将外部流量引入网格内，
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/01-Service-Entry# cat 01-serviceentry-nginx.yaml
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: nginx-external
spec:
  hosts:
  - nginx.magedu.com		#引入网格内访问的域名主机头名称，如果不能解析可使用下面的IP地址当做主机头
  addresses:
  - "172.168.2.33"			#将IP地址当做主机头
  - "172.168.2.34"
  - "172.168.2.35"
  ports:
  - number: 8091			#指定服务端口，以及协议和名称，此端口是Listener上监听的端口
    name: http
    protocol: HTTP
 #location: MESH_INTERNAL
  location: MESH_EXTERNAL	#服务所在位置为网格外部
  resolution: STATIC		#解析方法为静态指定
  endpoints:
  - address: "172.168.2.33"		#后端端点信息，ports可以省略，表示使用前面ports的定义
    ports:
      http: 8091				#如若不省略则使用这里的端口
  - address: "172.168.2.34"
    ports:
      http: 8091
  - address: "172.168.2.35"
    ports:
      http: 8091
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/01-Service-Entry# kubectl apply -f 01-serviceentry-nginx.yaml

5. 测试是否如K8s集群service一样自动添加相关信息到网格内
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/01-Service-Entry# istioctl pc listeners client | grep 8091	--listener
0.0.0.0       8091  Trans: raw_buffer; App: HTTP                                             Route: 8091
0.0.0.0       8091  ALL                                                                      PassthroughCluster
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/01-Service-Entry# istioctl pc routes client | grep 8091		--routes
8091                                                                      nginx.magedu.com, 172.168.2.35                            /*
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/01-Service-Entry# istioctl pc clusters client | grep 8091
nginx.magedu.com                                                       8091      -          outbound      EDS
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/01-Service-Entry# istioctl pc endpoints client | grep 8091	--endpoints
172.168.2.33:8091                HEALTHY     OK                outbound|8091||nginx.magedu.com
172.168.2.34:8091                HEALTHY     OK                outbound|8091||nginx.magedu.com
172.168.2.35:8091                HEALTHY     OK                outbound|8091||nginx.magedu.com

6. 在client中测试访问外部服务
root@client # curl nginx.magedu.com:8091		#因为不能解析所以访问失败
curl: (6) Could not resolve host: nginx.magedu.com
root@client # curl nginx.magedu.com:8091		#增加主机头后就访问成功了
<title>nginx.magedu.com</title>
Nginx 2002 ~~
root@client # curl 172.168.2.35:8091
<title>nginx.magedu.com</title>
Nginx 2002 ~~
root@client # curl 172.168.2.34:8091
<title>nginx.magedu.com</title>
Nginx 2002 ~~
root@client # curl 172.168.2.33:8091
<title>nginx.magedu.com</title>
Nginx 2001 ~~
注：经过测试得知，主机头有四个，分别为：nginx.magedu.com，172.168.2.33，172.168.2.34，172.168.2.35
注：此时流量到达网格后，在kiali上可以看到istio已经识别外部服务从tcp变成http流量了，说明可以做高级流量治理功能了

7. 为引入外部的服务配置destinationrule实现基于head的负载均衡算法(下面是一致性哈希)、异常探测检查等
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/01-Service-Entry# cat 02-destinationrule-nginx.yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: nginx-external
spec:
  host: nginx.magedu.com
  trafficPolicy:
    loadBalancer:
      consistentHash:
        httpHeaderName: X-User
    connectionPool:
      tcp:
        maxConnections: 10000
        connectTimeout: 10ms
        tcpKeepalive:
          time: 7200s
          interval: 75s
      http:
        http2MaxRequests: 1000
        maxRequestsPerConnection: 10
    outlierDetection:
      maxEjectionPercent: 50
      consecutive5xxErrors: 5
      interval: 2m
      baseEjectionTime: 1m
      minHealthPercent: 40

8. 测试destination是否如预期一样，例如一致性哈希
root@client # curl nginx.magedu.com:8091
<title>nginx.magedu.com</title>
Nginx 2001 ~~
root@client # curl nginx.magedu.com:8091
<title>nginx.magedu.com</title>
Nginx 2002 ~~
root@client # curl nginx.magedu.com:8091
<title>nginx.magedu.com</title>
Nginx 2101 ~~
root@client # curl -H 'X-User: true' nginx.magedu.com:8091		#基于Head的一致性哈希算法如预期一样
<title>nginx.magedu.com</title>
Nginx 2002 ~~
root@client # curl -H 'X-User: true' nginx.magedu.com:8091
<title>nginx.magedu.com</title>
Nginx 2002 ~~
root@client # curl -H 'X-User: true' nginx.magedu.com:8091
root@client # curl -H 'X-User: abc' nginx.magedu.com:8091
<title>nginx.magedu.com</title>
Nginx 2001 ~~
root@client # curl -H 'X-User: abc' nginx.magedu.com:8091
<title>nginx.magedu.com</title>
Nginx 2001 ~~

9. 配置VitualService实现故障注入（中断、延迟）等高级功能
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/01-Service-Entry# cat 03-virtualservice-nginx.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: nginx-external
spec:
  hosts:
  - nginx.magedu.com
  http:
  - name: falut-injection
    match:
    - headers:
        X-Testing:
          exact: "true"
    route:
    - destination:
        host: nginx.magedu.com
    fault:
      delay:
        percentage:
          value: 5
        fixedDelay: 2s
      abort:
        percentage:
          value: 5
        httpStatus: 555
  - name: nginx-external
    route:
    - destination:
        host: nginx.magedu.com
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/01-Service-Entry# kubectl apply -f 03-virtualservice-nginx.yaml

10. 进行测试故障注入是否如预期
root@client # while true; do curl -H 'X-Testing: true' nginx.magedu.com:8091;sleep 0.$RANDOM;done
<title>nginx.magedu.com</title>
Nginx 2002 ~~
<title>nginx.magedu.com</title>
Nginx 2101 ~~
<title>nginx.magedu.com</title>
Nginx 2101 ~~
fault filter abortfault filter abort<title>nginx.magedu.com</title>		#有中断，符合预期
Nginx 2002 ~~
fault filter abort<title>nginx.magedu.com</title>
Nginx 2002 ~~
<title>nginx.magedu.com</title>
Nginx 2002 ~~
<title>nginx.magedu.com</title>
Nginx 2101 ~~
<title>nginx.magedu.com</title>

#WorkloadEntry和WorkloadGroup
- 为什么需要WorkloadEntry CR？
  - 自v1.6开始，Istio在其流量管理功能组中引入了WorkloadEntry这一新的资源类型
  - WorkloadEntry CR用于抽象非Kubernetes托管的工作负载，例如虚拟机(VM)实例和裸服务器等，从而将虚拟机加入到网格中
  - 于是，这些VM或裸服务器，亦可作为与Kubernetes集群上的Pod等同的工作负载，并具备流量管理、安全管理、可视化等能力
  - ServiceEntry对象可根据指定的标签器筛选VM，从而让ServiceEntry专注于服务定义，而由WorkloadEntry负责定义各端点
  - 因此：WorkloadEntry CR的引入，大大简化了将VM加入Isito网格的复杂度
- Istio在其v1.8版本中对VM的支持有了进一步的增强
  - VM自动注册：使用WorkloadGroup CR，将VM实例自动注册为Istio上的WorkloadEntry
  - 智能DNS代理：使用Sidecar DNS Proxy，缓存网格中的endpoint，以及由ServiceEntry创建的endpoint
    - 虚拟机访问网格内的服务无需再配置/etc/hosts
  - 因此：WorkloadGroup和WorkloadEntry能够方便用户将虚拟机上的服务注册到网格内
  
#WorkloadEntry示例
##意图：使用WorkloadEntry创建两个endpoint，然后使用ServiceEntry通过标准选择workload，实现对外部服务的负载均衡，流量比为50:50
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/02-Workload-Entry# cat 01-workloadentry-nginx.yaml
apiVersion: networking.istio.io/v1beta1
kind: WorkloadEntry			#使用WorkloadEntry创建两个endpoint
metadata:
  name: workload-nginx2001
  labels:
    version: v1.20
spec:
  address: "172.168.2.33"
  ports:
    http: 8091		#endpoint IP地址及port
  labels:
    app: nginx			#标签，标准应至少定义app和version两个标签
    version: v1.20
    instance-id: Nginx2001
---
apiVersion: networking.istio.io/v1beta1
kind: WorkloadEntry
metadata:
  name: workload-nginx2002
  labels:
    version: v1.20
spec:
  address: "172.168.2.34"
  ports:
    http: 8091
  labels:
    app: nginx
    version: v1.20
    instance-id: Nginx2002
---
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/02-Workload-Entry# cat 02-serviceentry-nginx.yaml
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: nginx-external
spec:
  hosts:
  - nginx.magedu.com		#创建serviceEntry,访问的主机名名称，同名称的workload只能允许有一个ServiceEntry，如果创建2个后，则不能删除其中一个，否则会致使流量异常
  ports:
  - number: 80				#网格内部访问的端口为80
    name: http
    protocol: HTTP
  location: MESH_INTERNAL
  resolution: STATIC
  workloadSelector:
    labels:
      app: nginx		#标签选择app=nginx的端点
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/02-Workload-Entry# kubectl apply -f 01-workloadentry-nginx.yaml -f 02-serviceentry-nginx.yaml
root@client # while true;do curl nginx.magedu.com;sleep 0.$RANDOM;done	#客户端测试
<title>nginx.magedu.com</title>
Nginx 2001 ~~
<title>nginx.magedu.com</title>
Nginx 2002 ~~
<title>nginx.magedu.com</title>
Nginx 2002 ~~
<title>nginx.magedu.com</title>
Nginx 2001 ~~
<title>nginx.magedu.com</title>
Nginx 2001 ~~

##意图：再增加一个endpoint 172.168.2.35，使流量平均到3个endpoint，流量比：33:33:33
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/03-WorkloadEntry-Subsets# cat 01-workloadentry-nginx.yaml
apiVersion: networking.istio.io/v1beta1
kind: WorkloadEntry
metadata:
  name: workload-nginx2001
spec:
  address: "172.168.2.33"
  ports:
    http: 8091
  labels:
    app: nginx
    version: "v1.20"
    instance-id: Nginx2001
---
apiVersion: networking.istio.io/v1beta1
kind: WorkloadEntry
metadata:
  name: workload-nginx2002
spec:
  address: "172.168.2.34"
  ports:
    http: 8091
  labels:
    app: nginx
    version: "v1.20"
    instance-id: Nginx2002
---
apiVersion: networking.istio.io/v1beta1
kind: WorkloadEntry
metadata:
  name: workload-nginx2101
spec:
  address: "172.168.2.35"
  ports:
    http: 8091
  labels:
    app: nginx
    version: "v1.21"
    instance-id: Nginx2101
---
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/03-WorkloadEntry-Subsets# kubectl apply -f 01-workloadentry-nginx.yaml

#意图：创建子集，nginx1.20为一个子集，nginx1.21为一个子集，实现高级流量功能
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/03-WorkloadEntry-Subsets# cat 03-destinationrule-subsets.yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: nginx-external
spec:
  host: nginx.magedu.com
  trafficPolicy:
    loadBalancer:
      simple: RANDOM
    connectionPool:
      tcp:
        maxConnections: 10000
        connectTimeout: 10ms
        tcpKeepalive:
          time: 7200s
          interval: 75s
      http:
        http2MaxRequests: 1000
        maxRequestsPerConnection: 10
    outlierDetection:
      maxEjectionPercent: 50
      consecutive5xxErrors: 5
      interval: 2m
      baseEjectionTime: 1m
      minHealthPercent: 40
  subsets:
  - name: v20
    labels:
      version: "v1.20"
  - name: v21
    labels:
      version: "v1.21"
---注：子集会在kiali上报错，报在网格中未匹配查找到相关子集，其实已经匹配到外部endpoint定义的子集，此错误可忽略
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/03-WorkloadEntry-Subsets# kubectl apply -f 03-destinationrule-subsets.yaml
--实现基于权重的流量颁发，v21流量为5，v20流量为95
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/03-WorkloadEntry-Subsets# cat 04-virtualservice-wegit-based-routing.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: nginx-external
spec:
  hosts:
  - nginx.magedu.com
  http:
  - name: default
    route:
    - destination:
        host: nginx.magedu.com
        subset: v21
      weight: 5
    - destination:
        host: nginx.magedu.com
        subset: v20
      weight: 95
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/03-WorkloadEntry-Subsets# kubectl apply -f 04-virtualservice-wegit-based-routing.yaml
----实现基于head来实现流量治理，并注入故障中断、延迟
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/03-WorkloadEntry-Subsets# cat 05-virtualservice-headers-based-routing.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: nginx-external
spec:
  hosts:
  - nginx.magedu.com
  http:
  - name: falut-injection
    match:
    - headers:
        X-Canary:
          exact: "true"
    route:
    - destination:
        host: nginx.magedu.com
        subset: v21
    fault:
      delay:
        percentage:
          value: 5
        fixedDelay: 2s
  - name: default
    route:
    - destination:
        host: nginx.magedu.com
        subset: v20
    fault:
      abort:
        percentage:
          value: 5
        httpStatus: 555
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/03-WorkloadEntry-Subsets# kubectl apply -f 05-virtualservice-headers-based-routing.yaml

##Egress Gateway示例，重新定义
1. 部署WorkloadEntry
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/04-Egress-Gateway# cat 01-workloadentry-nginx.yaml
apiVersion: networking.istio.io/v1beta1
kind: WorkloadEntry
metadata:
  name: workload-nginx2001
spec:
  address: "172.168.2.33"
  ports:
    http: 8091
  labels:
    app: nginx
    version: "v1.20"
    instance-id: Nginx2001
---
apiVersion: networking.istio.io/v1beta1
kind: WorkloadEntry
metadata:
  name: workload-nginx2002
spec:
  address: "172.168.2.34"
  ports:
    http: 8091
  labels:
    app: nginx
    version: "v1.20"
    instance-id: Nginx2002
---
apiVersion: networking.istio.io/v1beta1
kind: WorkloadEntry
metadata:
  name: workload-nginx2101
spec:
  address: "172.168.2.35"
  ports:
    http: 8091
  labels:
    app: nginx
    version: "v1.21"
    instance-id: Nginx2101
---
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/04-Egress-Gateway# kubectl apply -f 01-workloadentry-nginx.yaml

2. 部署serviceEntry
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/04-Egress-Gateway# kubectl delete se nginx-external
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/04-Egress-Gateway# cat 02-serviceentry-nginx.yaml
---
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: nginx-external
spec:
  hosts:
  - nginx.magedu.com
  ports:
  - number: 80
    name: http
    protocol: HTTP
  location: MESH_EXTERNAL
  resolution: STATIC
  workloadSelector:
    labels:
      app: nginx
---
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/04-Egress-Gateway# kubectl apply -f 02-serviceentry-nginx.yaml

3. 配置集群子集
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/04-Egress-Gateway# cat 03-destinationrule-subsets.yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: nginx-external
spec:
  host: nginx.magedu.com
  trafficPolicy:
    loadBalancer:
      simple: RANDOM
    connectionPool:
      tcp:
        maxConnections: 10000
        connectTimeout: 10ms
        tcpKeepalive:
          time: 7200s
          interval: 75s
      http:
        http2MaxRequests: 1000
        maxRequestsPerConnection: 10
    outlierDetection:
      maxEjectionPercent: 50
      consecutive5xxErrors: 5
      interval: 2m
      baseEjectionTime: 1m
      minHealthPercent: 40
  subsets:
  - name: v20
    labels:
      version: "v1.20"
  - name: v21
    labels:
      version: "v1.21"
---
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/04-Egress-Gateway# kubectl apply -f 03-destinationrule-subsets.yaml

4. 配置egress gateway
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/04-Egress-Gateway# cat 04-gateway-egress.yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: egress
  namespace: istio-system
spec:
  selector:
    app: istio-egressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"		#创建一个egress gateway，匹配所有主机域名
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/04-Egress-Gateway# kubectl get svc/istio-egressgateway -n istio-system
NAME                  TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE
istio-egressgateway   ClusterIP   10.68.72.41   <none>        80/TCP,443/TCP   7d
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/04-Egress-Gateway# kubectl apply -f 04-gateway-egress.yaml

5. 部署VirtualService
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/04-Egress-Gateway# cat 05-virtualservice-wegit-based-routing.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: nginx-external
spec:
  hosts:
  - nginx.magedu.com		#当匹配主机名为nginx.magedu.com的动作
  gateways:
  - istio-system/egress		#实现位置为istio-system/egress和mesh
  - mesh
  http:
  - match:
    - gateways:
      - mesh					#当gateway是mesh时的动作
    route:
    - destination:
        host: istio-egressgateway.istio-system.svc.cluster.local	#路由到istio-egressgateway.istio-system.svc.homsom.local此svc，也就是egress gateway的svc地址，注意的是：我部署K8s集群后缀是homsom.local，但是此处应写cluster.local，否则会访问服务失败
  - match:
    - gateways:
      - istio-system/egress		#当gateway是istio-system/egress时的动作
    route:
    - destination:
        host: nginx.magedu.com		#当流量到达egress gateway后，主机名匹配到为nginx.magedu.com时，5%流量发往子集v21，95%流量发往子集v20
        subset: v21
      weight: 5
    - destination:
        host: nginx.magedu.com
        subset: v20
      weight: 95
--
root@k8s-master01:~# istioctl pc cluster istio-egressgateway-7f4864f59c-npp42 -n istio-system | grep istio-egressgateway	#此为istio-egressgateway地址
istio-egressgateway.istio-system.svc.cluster.local                     80        -          outbound      EDS
istio-egressgateway.istio-system.svc.cluster.local                     443       -          outbound      EDS
root@k8s-master01:~/istio/istio-in-practise/ServiceEntry-and-WorkloadEntry/04-Egress-Gateway# kubectl apply -f 05-virtualservice-wegit-based-routing.yaml

--查看virtualservice匹配的域名
root@k8s-master01:~# istioctl pc routes istio-egressgateway-7f4864f59c-npp42 -n istio-system
NAME          DOMAINS              MATCH                  VIRTUAL SERVICE
http.8080     nginx.magedu.com     /*                     nginx-external.default
              *                    /stats/prometheus*
              *                    /healthz/ready*
#ServiceEntry和Egress Gateway区别
- ServiceEntry：过于分散不利于集中管理，client -> virtualservice -> destinationrule -> cluster(serviceentry引入) -> endpoint(workloadentry引入)
- Egress Gateway：利于集中管理，client -> Egress-Gateway(集中配置) -> virtualservice -> destinationrule -> cluster(serviceentry引入) -> endpoint(workloadentry引入)



###Envoy Filter

#Istio的功能及其相关实现组件
- istio提供了如下开箱即用(Out Of The Box)的功能
  - Service Discovery / Load Balancing				->			ServiceEntry + DestinationRule
  - Secure service-to-service communication(mTLS)	->			DestinationRule
  - Traffic control / shaping /shifting				->			VirtualService
  - Policy / Intention based access control 		->			AuthorizationPolicy
  - Traffic metric collection						->			(built in)
- 以下功能不能做到OOTB，在一定程序上，依赖用户自行定义
  - Cross-cluster Networking						->			EnvoyFilter + ServiceEntry + Gateway
  - External Auth / Rate Limiting					->			EnvoyFilter
  - Traffic Failover								->			EnvoyFilter
  - WASM Filters									->			EnvoyFilter
  - Access Logging / many unexposed Envoy features	->			EnvoyFilter + ?
  
 #EnvoyFilter CR
 - EnvoyFilter
  - EnvoyFilter CR提供了自定义Sidecar Envoy配置的接口，其支持的配置功能包括修改指定字段的值、添加特定的过滤器甚至是新增Listener和Cluster等
  - 常在Istio原生的各CR未能提供足够的配置机制，或者无法支持到的配置场景中使用
    - 简单来说，EnvoyFilter提供的是直接向Envoy配置文件打补丁的接口，从而为网格中的各Envoy实例提供了以Envoy原生方式进行配置的机制
  - 同Sidecar等其它几个位于同一API群组(networking.istio.io/v1beta1)内的CR不同的是，EnvoyFilter CR资源对象通过自适应的方式应用于workload之上
    - 一个名称空间当中可同时存在多个应用于同一workload实例的EnvoyFilter CR资源对象
	- 多个EnvoyFilter资源对象在应用时会有着特定的次序：首先是root namespace中的所有EnvoyFilter，而后才是workload实例当前名称空间中所有匹配到的各EnvoyFilter资源对象
- 注意事项
  - 对于不同的Istio发行版来说，EnvoyFilter提供的配置可能不具有向后兼容性
  - Istio Proxy版本升级时，需要仔细识别配置字段的废弃和添加等所产生的影响
  - 多个EnvoyFilter资源对象在应用于同一个workload时，它们会根据创建的时间顺次生效，而配置冲突时其结果将无从预料
  - 切记要谨慎使用该功能，不当的配置定义，可能会破坏网格的稳定性；（EnvoyFilter基本不用，当做了解即可）

root@k8s-master01:~# kubectl get envoyfilter -n istio-system		#系统内置的6个filter
NAME                    AGE
stats-filter-1.10       7d5h
stats-filter-1.11       7d5h
stats-filter-1.12       7d5h
tcp-stats-filter-1.10   7d5h
tcp-stats-filter-1.11   7d5h
tcp-stats-filter-1.12   7d5h

#使用EnvoyFilter配置Envoy
- EnvoyFilter的关键组成部分
  - 使用workloadSelector指定要配置的Envoy实例
    - 省略该字段，意味着将配置到同一个名称空间下的所有Envoy实例
	- 若EnvoyFilter定义在了根名称空间，且省略了该字段，则意味着配置到网格中所有名称空间中的Envoy实例
  - 由configPatches给出配置补丁
  - 补丁排序
    - 多个补丁间存在依赖关系时，其应用次序举足轻重
	- EnvoyFilter API内置了两种应用次序
	  - 根名称空间下的EnvoyFilter将先于名称空间下的EnvoyFilter资源
	  - 补丁集中的多个补丁以它们定义的顺序完成打补丁操作
	- 也可以为EnvoyFilter使用priority字段定义其优先级，可用的取值范围是0至2^32-1
	  - 负数优先级，表示将于default EnvoyFilter之前应用
- 补丁及其位置
  - applyTo指定补丁在Envoy配置文件中要应用到的位置(配置段)
  - match指定补丁在Envoy配置文件中相应的位置上要应用到的具体配置对象（Listener、RouteConfiguration或Cluster）
  - 补丁的内容及相应的操作则由patch字段定义
  
  
###Telemetry V2(可观测性)
#Istio的可观测性
- Metrics：Istio会为所有服务的流量和自身控制平面的各组件生成详细的指标；但究竟要收集哪些指标则由运维人员通过配置来确定
  - Proxy-level metrics: 代理级指标，数据平面指标(envoy stats指标提供)
    - Envoy Proxy会为出入的所有流量生成丰富的一组指标
	- Envoy Proxy还会生成自身管理功能的详细统计信息，包括配置和运行状态等
  - Service-level metrics: 服务指标，用于监控服务通信，数据平面指标(istio通过WASM插件动静态装载从envoy得到)
    - 面向服务的指标主要包括服务监视的四个基本需要：延迟、流量、错误和饱和度
  - Control plane metrics, 控制平面指标(istio自己输出)
    - istiod还提供了一组自我监控的指标，这些指标允许监控Istio自身的行为
- Distributed Traces
  - Istio支持通过代理程序Envoy进行分布式跟踪
  - 这意味着被代理的应用程序只需要转发适当的context即可，实现了"近零侵入"
  - 支持Zipkin、Jaeger、LightStep和Datadog等后端系统
  - 支持运维人员自定义采样频率
- Access Log
  - 访问日志提供了从单个workload级别监视和了解服务行为的方法
  - 日志格式可由运维人员按需进行定义，且可把日志导出到自定义的后端，例如Fluentd等
- Istio的可观测性功能主要发生网格中的数据平面上
  - 因为数据平面代理istio-proxy(Envoy)位于服务间的请求路径上
  - Istio需要通过Envoy捕获与请求处理和服务交互相关的重要指标
  - Istio还附带了一些OOTB工具，例如Prometheus、Grafana和Kiali等
- Istio在网格代理上启用的可观测机制，可以在部署Istio时进行配置，也可随后通过MeshConfig或者Telemetry CR定义(目前推荐Telemetry CR定义，这样才符合声明式API)

#启用网格的可观测性配置
- 配置网格的观测功能
  - 部署网格时，通过IstioOperator配置中的MeshConfig段进行全局配置
  - 部署网格后，通过IstioOperator配置中的MeshConfig段进行全局配置
  - 通过Telemetry API（Telemetry CR资源）定义
    - 在root namespace(例如istio-system)中配置、
	- 为特定的namespace进行配置
	- 为namespace中的特定workload进行配置
  - 在工作负载的podTemplate资源上，通过"proxy.istio.io/config"注解进行配置

Telemetry V1:对于Envoy来说是主动式指标
Telemetry V２:对于Envoy来说是被动式指标
服务级指标: stats、metadata exchange输出
代理级指标：proxy本身支持
-- istio日志收集跟收集k8s日志一样
  
#Istio可测性产品部署位置
- Metrics：依赖isito提供的指标，prometheus一般部署在服务网格之内，然后通过外部高可用prometheus集群作为主联绑节点将服务网格中的prometheus进行监控
- Tracing: 可以直接使用外部链路追踪集群
- Log: 可以直接使用外部ELK集群

  
#代理级指标--如何开启未开启指标
#root@k8s-master01:~/istio/istio-in-practise/Observability/Proxy-Level# istioctl manifest generate --set profile=default  #这是生成kubernetes声明式ymal文件
root@k8s-master01:~/istio/istio-in-practise/Observability/Proxy-Level# istioctl profile dump default > default-2022.yaml  #这是生成istio配置文件
vim default-2022.yaml
  meshConfig:
    accessLogFile: /dev/stdout
    defaultConfig:
      proxyMetadata: {}		#更新此处，完成后使用命令：istioctl install default-2022.yaml，此命令跟kubectl apply一样，并不会拆出网格，而是apply上去的
或者
root@k8s-master01:~/istio/istio-in-practise/Observability/Proxy-Level# cat demo-meshConfig.yaml	#这是生成istio配置文件片段，基于全局的指标开关
apiVersion: install.istio.io/v1alpha1
kind: istioOperator
spec:
  profile: demo
  meshConfig:
    defaultConfig:
      proxyStatsMatcher:
        inclusionRegexps:			#基于正则匹配的指标
        - ".*circuit_breakers.*"
        inclusionPrefixes:			#基于前缀匹配的指标，inclusionSuffixes是基于后缀匹配的指标
        - "upstream_rq_retry"
        - "upstream_cx"
root@k8s-master01:~/istio/istio-in-practise/Observability/Proxy-Level# istioctl install -f demo-meshConfig.yaml		#进行重新应用配置
This will install the Istio 1.12.0 demo profile with ["Istio core" "Istiod" "Ingress gateways" "Egress gateways"] components into the cluster. Proceed? (y/N) y
✔ Istio core installed
✔ Istiod installed
✔ Ingress gateways installed
✔ Egress gateways installed
✔ Installation complete                                                                                                                                            Making this installation the default for injection and validation.
----测试启用的代理级指标是否变多
root@k8s-master01:~/istio/istio-in-practise/Observability/Proxy-Level# curl -sS 172.20.217.87:15020/stats/prometheus | grep 'circuit_breakers'                
# TYPE envoy_cluster_circuit_breakers_default_cx_open gauge
envoy_cluster_circuit_breakers_default_cx_open{cluster_name="xds-grpc"} 0
# TYPE envoy_cluster_circuit_breakers_default_cx_pool_open gauge
envoy_cluster_circuit_breakers_default_cx_pool_open{cluster_name="xds-grpc"} 0
# TYPE envoy_cluster_circuit_breakers_default_rq_open gauge
envoy_cluster_circuit_breakers_default_rq_open{cluster_name="xds-grpc"} 0
# TYPE envoy_cluster_circuit_breakers_default_rq_pending_open gauge
envoy_cluster_circuit_breakers_default_rq_pending_open{cluster_name="xds-grpc"} 0
# TYPE envoy_cluster_circuit_breakers_default_rq_retry_open gauge
envoy_cluster_circuit_breakers_default_rq_retry_open{cluster_name="xds-grpc"} 0
# TYPE envoy_cluster_circuit_breakers_high_cx_open gauge
envoy_cluster_circuit_breakers_high_cx_open{cluster_name="xds-grpc"} 0
# TYPE envoy_cluster_circuit_breakers_high_cx_pool_open gauge
envoy_cluster_circuit_breakers_high_cx_pool_open{cluster_name="xds-grpc"} 0
# TYPE envoy_cluster_circuit_breakers_high_rq_open gauge
envoy_cluster_circuit_breakers_high_rq_open{cluster_name="xds-grpc"} 0
# TYPE envoy_cluster_circuit_breakers_high_rq_pending_open gauge
envoy_cluster_circuit_breakers_high_rq_pending_open{cluster_name="xds-grpc"} 0
# TYPE envoy_cluster_circuit_breakers_high_rq_retry_open gauge
envoy_cluster_circuit_breakers_high_rq_retry_open{cluster_name="xds-grpc"} 0


#服务级指标
- Istio默认启用的服务级指标，是在首次部署Istio时由通过自动创建的EnvoyFilter资源定义的
  - 这些EnvoyFilter资源定义在网格名称空间（例如istio-system）下
    - 获取命令：~$ kubectl get envoyfilter -n istio-system
  - 以envoyfilter/stats-filter-1.12资源为例
    - 该EnvoyFilter用于配置名为envoy.wasm.stats的过滤器
	- 各指标为自动添加一个istio前缀
  - 三种类型的Envoy实例需要经context匹配后分别进行配置
    - SIDECAR_OUTBOUND
	- SIDECAR_INBOUND
	- GATEWAY
- 注意
  - 出于性能的考虑，该Wasm插件是直接编译进Envoy的，而非运行于Wasm VM中
  - 但Istio也提供独立的stats Wasm插件，或要Istio将之运行为独立插件，可在部署istio时使用如下选项进行启用
    - --set values.telemetry.v2.prometheus.wasmEnabled=true
	
root@k8s-master01:~/istio/istio-in-practise/Observability/Proxy-Level# curl -s 172.20.217.77:15020/stats/prometheus | grep -o 'istio_[a-zA-Z_]*' | sort -u
istio_agent_process_start_time_seconds
istio_agent_process_virtual_memory_bytes
istio_agent_process_virtual_memory_max_bytes
istio_agent_scrapes_total
istio_agent_startup_duration_seconds
istio_agent_wasm_cache_entries
istio_build
istio_request_bytes
istio_request_bytes_bucket
istio_request_bytes_count
istio_request_bytes_sum
istio_request_duration_milliseconds
istio_request_duration_milliseconds_bucket
istio_request_duration_milliseconds_count
istio_request_duration_milliseconds_sum
istio_requests_total
istio_response_bytes
istio_response_bytes_bucket
istio_response_bytes_count
istio_response_bytes_sum
istio_tcp_connections_closed_total
istio_tcp_connections_opened_total
istio_tcp_received_bytes_total
istio_tcp_sent_bytes_total
	
#增加、删除服务级指标方法一，不太稳定，建议测试通过在生产使用
root@k8s-master01:~/istio/istio-in-practise/Observability/Service-Level# cat istio-operator-new-dimesions.yaml	#新版本不好用且不稳定，建议不要用
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  profile: demo
  values:
    telemetry:
      v2:
        prometheus:
          configOverride:
            inboundSidecar:					#针对入向流量
              metrics:
                - name: requests_total		#针对metics名称
                  dimensions:				#增加标签
                    request_host: request.host			#request_host的标签值为request.host	
                    request_method: request.method
                  tags_to_remove:			#移除指定标签
                  - request_protocol
            outboundSidecar:				#针对出入流量
              metrics:
                - name: requests_total
                  dimensions:
                    request_host: request.host
                    request_method: request.method
                  tags_to_remove:
                  - request_protocol
            gateway:						#针对gateway
              metrics:
                - name: requests_total
                  dimensions:
                    request_host: request.host
                    request_method: request.method
                  tags_to_remove:
                  - request_protocol
注：如果单独应用此配置清单，那么会清除之前的配置(:~/istio/istio-in-practise/Observability/Proxy-Level/demo-meshConfig.yaml)，如不想清除之前的配置，应将此前的配置和本配置放在一个配置文件再进行应用
root@k8s-master01:~/istio/istio-in-practise/Observability/Service-Level# istioctl install -f istio-operator-new-dimesions.yaml	#应用
root@k8s-master01:~/istio/istio-in-practise/Observability/Service-Level# istioctl install --set profile=demo	#移除所有额外配置，恢复到默认配置

#增加、删除服务级指标方法二之telemetry
root@k8s-master01:~/istio/istio-in-practise/Observability/Service-Level# cat namespace-metrics.yaml
apiVersion: telemetry.istio.io/v1alpha1
kind: Telemetry
metadata:
  name: namespace-metrics
  namespace: default
spec:
  # no selector specified, applies to all workloads in the namespace
  metrics:
  - providers:
    - name: prometheus
    overrides:
    # match clause left off matches all istio metrics, client and server
    - tagOverrides:
        request_method:					#针对default整个名称空间生效，针对所有指标增加request_method标签
          value: "request.method"		
        request_host:	
          value: "request.host"			#针对所有指标增加request_host标签
root@k8s-master01:~/istio/istio-in-practise/Observability/Service-Level# cat deploy-demoapp.yaml	#针对特定workload生效
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: demoappv10
    version: v1.0
  name: demoappv10
spec:
  progressDeadlineSeconds: 600
  replicas: 3
  selector:
    matchLabels:
      app: demoapp
      version: v1.0
  template:
    metadata:
      labels:
        app: demoapp
        version: v1.0
      annotations:
        sidecar.istio.io/extraStatTags: request_method, request_host		#针对
    spec:
      containers:
      - image: ikubernetes/demoapp:v1.0
        imagePullPolicy: IfNotPresent
        name: demoapp
        env:
        - name: "PORT"
          value: "8080"
        ports:
        - containerPort: 8080
          name: web
          protocol: TCP
        resources:
          limits:
            cpu: 50m
---
root@k8s-master01:~/istio/istio-in-practise/Observability/Service-Level# cat namespace-root-metrics.yaml	#针对所有网格生效
apiVersion: telemetry.istio.io/v1alpha1
kind: Telemetry
metadata:
  name: namespace-metrics
  namespace: istio-system
spec:
  # no selector specified, applies to all workloads in the namespace
  metrics:
  - providers:
    - name: prometheus
    overrides:
    # match clause left off matches all istio metrics, client and server
    - tagOverrides:
        request_method:
          value: "request.method"
        request_host:
          value: "request.host"
注：telemetry方法测试后，和上面一样，目前对服务级指标进行增加和删除难度很大，无法生效，建议使用默认指标即可

#控制平面指标
root@k8s-master01:~/istio/istio-in-practise/Observability/Service-Level# kubectl get pods -o wide -n istio-system | grep istiod
istiod-555d47cb65-c2vc4                1/1     Running   0          9d    172.20.217.81    192.168.13.63   <none>           <none>
root@k8s-master01:~/istio/istio-in-practise/Observability/Service-Level# curl 172.20.217.81:15014/metrics
#注：istio metric监控，使用自带的附件部署，也就是部署自带的prometheus，然后通过自己外部的高可用prometheus联绑集群将网格内的istio prometheus服务纳入即可管理。


#启用网格访问日志
- 在istioOpertor中，通过MeshConfig启用
  - accessLogFile: 访问日志的日志文件路径，例如/dev/stdout，空值表示禁用该日志
  - accessLogFormat: 访问日志的日志格式，空值表示使用默认的日志格式
  - accessLogEncoding: 访问日志编码格式，支持TEXT和JSON两种，默认为TEXT
- 通过Telemetry API启用
  - 可以实现更为精细粒度的控制，例如，仅在指定的名称空间，甚至是仅在特定的工作负责上启用
----通过istioOperator启用日志功能
root@k8s-master01:~/istio/istio-in-practise/Observability/logging# cat log-meshConfig.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: accesslog-meshdefault
  namespace: istio-system
spec:
  profile: demo
  meshConfig:
    accessLogFile: /dev/stdout
    accessLogEncoding: JSON
root@k8s-master01:~/istio/istio-in-practise/Observability/logging# kubectl apply -f log-meshConfig.yaml
----通过Telemetry启用日志功能
root@k8s-master01:~/istio/istio-in-practise/Observability/logging# cat log.yaml		
apiVersion: telemetry.istio.io/v1alpha1
kind: Telemetry
metadata:
  name: mesh-default
  namespace: istio-system
spec:
  accessLogging:
  - {}
----查看istio的配置
root@k8s-master01:~/istio/istio-in-practise/Observability/Tracing# kubectl get istioOperator -n istio-system
NAME                    REVISION   STATUS   AGE
accesslog-meshdefault                       100s		#这个是我们刚刚定义的，打开日志功能并且设置格式为JSON的istioOperator
installed-state                             9d			#这个是我们使用profile demo运行的配置，可以查看具体配置
#注：在istio中，我们只要打开日志功能并且设置日志格式为JSON，然后就可以使用我们外部的ELK进行收集k8s节点上容器的日志文件即可(包括envoy数据平面的日志)


#链路追踪--需要应用程序添加context(少量代码，近零侵入)
----通过IstioOperator定义
root@k8s-master01:~/istio/istio-in-practise/Observability/Tracing# cat istiooperator-tracing.yaml		#全局级别
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  profile: demo
  meshConfig:
    enableTracing: true			#开启链路追踪
    defaultConfig:
      tracing:
        sampling: 100.0				#采样率为100%，繁忙时可适当减小此值
        max_path_tag_length: 256	#路径标签最大长度
----通过Telemetry定义
root@k8s-master01:~/istio/istio-in-practise/Observability/logging# cat trace.yaml
apiVersion: telemetry.istio.io/v1alpha1
kind: Telemetry
metadata:
  name: mesh-default
  namespace: istio-system			#网格全局级别，也可配置名称空间、指定workload级别
spec:
  tracing:
  - providers:
    - name: localtrace				#指定调用的tracing工具路径，需要事先定义，如使用skywalking需要事先定义。如不定义使用默认jaeger
    randomSamplingPercentage: 100
##注：profile demo默认启用Prometheus，Logging,Tracing功能，只是tracing使用的是内置的jaeger



###网格安全

#Istio的安全模型
- istio网格的安全体系涉及到多个组件 
  - 用于密钥和证书管理的证书颁发机构（CA），由istiod内置的citedal提供
  - 由API server（istio的api）分发给各代理（Envoy）的配置，包括认证策略、授权策略及名称标识信息
  - 各Sidecar Envoy和边缘代理(Ingress Gateway和Egress Gateway)作为PEP（Policy Enforcement Points）负责保护客户端和服务之间的通信安全
  - Envoy程序上用于遥测和审计的扩展
#Istio identity
- 身份标识是通信安全领域的基础概念
  - 安全的通信过程中，双方出于相互认证的目的而交换身份凭据
    - 客户端：根据安全命名信息核验服务器的标识，以检测其是否获取运行目标服务的授权
	- 服务端：根据授权策略来确定客户端可以访问哪些信息，并审核谁在什么时间访问了哪些信息
  - Istio的身份标识模型使用一等服务标识（first-class service identity）来标识请求者的身份，它支持标识人类用户、单个工作负载或一组工作负载
- Istio在不同的平台上可以使用的身份标识服务如下
  - Kubernetes：Kubernetes service account
  - GCE: GCP service account
  - On-premises(non-Kubernetes): user account, custom service account, service name, Istio service account, or GCP service account
- Istio兼容SPIFEE，不过，Citedal提供了比SPIRE更为强大的安全功能，包括认证、授权、审计等
  - Istio常用的SPIFFE ID格式：spiffe://<domain>/ns/<namespace>/sa/<serviceaccount> ，例如：spiffe://cluster.local/ns/default/sa/default

#身份标识和证书管理
- 每个istio-proxy运行两个进程，1个为envoy，另一个为pilot-agent
- Istio使用X.509证书为每个工作负载提供身份标识
- 每个istio-proxy容器中与envoy相伴运行的pilot-agent负责同istiod协同完成私钥和证书的轮换
- Istio提供私钥和证书的流程如下：
  - istiod提供gRPC服务来接受证书签名请求（CSRs）
  - 启动时，istio proxy容器中的pilot-agent会创建私钥和CSR，并将CSR及其凭据发送给istiod(cidetal)完成签名
  - istiod上的CA负责验证CSR中携带的凭据，并在成功验证后签署CSR以生成证书
  - 工作负载启动时，envoy通过SDS API从同一容器中的pilot-agent请求证书和私钥
  - pilog-agent通过Envoy SDS API将私钥及从istiod上收到的证书发送给本地的envoy
  - pilot-agent周期性地监视着工作负载证书的有效期限，以处理证书和密钥轮换
#Istio认证机制
- Istio沿用了Envoy所支持的认证方式，它为网格内的服务提供两种身份验证机制
  - Peer authentication: 即service-to-service身份认证，或简称为服务认证，用以验证发起连接请求的客户端；为此，Istio支持双向TLS谁，即mTLS，以实现以下特性
    - 为每个服务提供一个专用的可表示其角色的身份标识，以实现跨集群和跨云的互操作
	- 安全实现service-to-service通信
	- 提供密钥管理系统以自动完成密钥和证书生成、分发及轮替
  - Request authentication: 也称为最终用户认证，它将发出请求的原始客户端认证为最终用户或设备
    - Istio基于JWT验证机制启用请求级身份认证功能
	- 支持使用自定义的身份认证服务，或任何中OIDC认证系统，例如Keyclock, Auth0, Firebase Auth等
- Istio将身份认证策略通过Kubernetes API存储于Istio configuration storage之中
  - istiod负责确诊每个代理保持最新状态，并在适当时提供密钥
  - istio的认证还支持许可模式(permissive mode)
#Istio认证架构
- Istio基于身份认证策略来定义所使用的认证机制
  - 身份认证策略通过API群组"security.istio.io"中的两个CR进行定义
    - PeerAuthentication CR: 定义服务认证策略
	- RequestAuthentication CR: 定义最终用户认证策略
  - 认证策略保存于Istio配置存储（configuration storage）之中，并由Istio Controller负载监视
    - configuration storage中的任何变动，都将由istiod自动转换为合适配置信息，并应用至相关各PEP以执行必要的认证机制
	- 另外，针对JWT认证，控制平面还要将公钥信息附加至相应的配置之上；而针对mTLS认证，istiod则需要将私钥和证书配置到Pod之上
  - Istio将认证策略相关的配置以异步方式配置到目标端点，而Envoy在收到相应配置后，新的认证机制则即刻生效
  - 发送请求的客户端服务负责遵循必要的身份验证机制
    - 对于Request Authentication，应用程序负责获取JWT凭据并将其附加到请求中
	- 对于Peer Authentication, Istio会自动将两个PEP之间的所有流量升级为双向TLS
	- 若身份验证策略禁用了mTLS模式，Istio将继续在PEP之间使用纯文本
	- 用户也可使用DesticationRule显示禁用mTLS模式
- 成功认证后，Istio会将相关"身份"及"凭据"转到后续的授权步骤中使用

#认证策略的生效范围
- Peer和Request两种身份验证策略都使用selector字段选定工作负载
- 认证策略的生效范围由其所属的名称空间及使用的选择器（selector）所决定
  - 创建于根名称空间，且未使用selector或使用了空的selector，其生效范围为网格内的所有工作负载
  - 创建于特定名称空间，且未使用selector或使用了空的selector，其生效范围为该名称空间中的所有工作负载
  - 创建于特定名称空间，且使用了非空的selector，其生效范围为该名称空间中的特定工作负载
- 认证策略的生效机制
  - Peer Authentication
    - 网格范围的策略仅能有一个生效，名称空间级别的策略及其所属的名称空间上也仅能生效一个，同样，若存在多个匹配到某工作负载的策略时，也仅能生效一个
	- 以上场景中，都是最旧（最早创建）的那个策略生效
	- 生效（搜索）次序：特定工作负载的策略 -> 名称空间级的策略 -> 网格级的策略
  - Request Authentication
    - Request认证中多个策略会组合生效，这不同于Peer认证策略中的"用旧废新"
	- 强烈建议在网格和名称空间级别各自最多定义一个策略

#Peer Authentication Policy使用要点
- Peer Authentication Policy负责为工作负载指定其作为服务器端时实施TLS通信的方式，它支持如下模式
  - PERMISSIVE：工作负载支持mTLS流量和纯文本（明文）流量，通常仅应该于将应用迁移至网格过程中的过渡期间使用
  - STRICT: 工作负载仅支持mTLS流量
  - DISABLE: 禁用mTLS
  - UNSET: 从上级继承认证策略的设定
- 另外，在使用了非空selector（即特定于某工作负载）的Peer Authentication Policy上，还可以为不同的端口指定不同的mTLS设定
注1：VirtualService和DestinationRule是为客户端定义如何访问上游服务的
注2：服务间认证是为上游服务定义TLS的，而为客户端定义TLS证书是定义在DestinationRule的

#DestinationRule CR中的mTLS
- Client TLS Settings
  - mode: 要使用的TLS模式，该字段的值决定了其它哪些字段是为生效字段
  - clientCertificate: 客户端证书，TLS模式为MUTUAL时必须配置该字段，而ISTIO_MUTUAL则要求该字段必须为空
  - privateKey: 客户端私钥，要求同上
  - caCertificates: 验证服务端证书时使用的CA证书，省略时则不校验服务端证书；ISTIO_MUTUAL则要求该字段必须为空
  - credentialName: 含有客户端私钥、客户端证书和CA证书的Secret资源名称，仅目前适用于Gateway Envoy
  - subjectAltNames: 证书中的subject名称的可替换名称列表
  - SNI: TLS handshake中要使用的SNI
  - insecureSkipVerify: 是否跳过验证服务端证书签名的SAN的步骤
- 客户端可用的TLS模式
  - DISABLE: 禁止同上游端点创建TLS连接
  - SIMPLE：向上游发起一个TLS连接（单向验证服务端的证书）
  - MUTUAL: 同上游建立双向认证的TLS连接，向上游提供客户端证书由clientCertificate字段指定
  - ISTIO_MUTIAL: 同上游建立双向认证的TLS连接，但会使用istio自动生成的证书，因此，该模式要求ClientTLSSettings字段中嵌套其它字段统统使用空值
  
#DestinationRule上的TLS客户端与PeerAuthentication上的TLS服务端的组合要点：
- PeerAuthentication使用PERMISSIVE时，DestinationRule可以使用任意模式
- PeerAuthentication使用STRICT时，DestinationRule可以使用MUTUAL或ISTIO_MUTUAL模式
- PeerAuthentication使用DISABLE时，DestinationRule也需要使用DISABLE模式
注：主要着手服务端PeerAuthentication
注：istio安装完成后默认启用了mTLS，模式为PERMISSIVE

##PeerAuthentication及TLS示例
--未default名称空间启用mTLS,模式为PERMISSIVE
root@k8s-master01:~/istio/istio-in-practise/Security/01-PeerAuthentication-Policy-Basics# cat 01-namespace-default-peerauthn.yaml
---
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: default
spec:
  mtls:
    mode: PERMISSIVE		#启用mTLS的PERMISSIVE模式，istio安装好后默认就是如此
---
root@k8s-master01:~/istio/istio-in-practise/Security/01-PeerAuthentication-Policy-Basics# kubectl apply -f 01-namespace-default-peerauthn.yaml

--运行client进行测试
--网格内client测试抓包看是否是TLS
root@k8s-master01:~/istio/istio-in-practise/Security/01-PeerAuthentication-Policy-Basics# kubectl get pods -o wide | grep client	#网格内client信息
client                        2/2     Running   0          9d    172.20.217.77    192.168.13.63   <none>           <none>
root@client # while true;do curl demoapp:8080;sleep 0.$RANDOM;done
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-fgb4n, ServerIP: 172.20.217.72!
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-l9pnf, ServerIP: 172.20.135.157!
--pod_IP: 172.20.217.77 宿主机：192.168.13.63
[root@k8s-node04 ~]# route -n | grep 172.20.217.77
172.20.217.77   0.0.0.0         255.255.255.255 UH    0      0        0 calia7a3e029a7b
[root@k8s-node04 ~]# tcpdump -i calia7a3e029a7b -nn -X port 8080
22:47:05.879904 IP 172.20.217.72.8080 > 172.20.217.77.50380: Flags [P.], seq 1161:2321, ack 2140, win 501, options [nop,nop,TS val 869362894 ecr 209914126], length 1160: HTTP
        0x0000:  4500 04bc 27f6 4000 3f06 0487 ac14 d948  E...'.@.?......H		#从这信息就可以看出来是加密的
        0x0010:  ac14 d94d 1f90 c4cc e13d df5c 7042 60b9  ...M.....=.\pB`.
        0x0020:  8018 01f5 0f6e 0000 0101 080a 33d1 6cce  .....n......3.l.
        0x0030:  0c83 090e 1703 0304 8300 0000 0000 0000  ................
        0x0040:  06a0 1a40 39b4 4b56 1671 1aa3 3442 3dd0  ...@9.KV.q..4B=.
        0x0050:  10cf 42da 13a0 efb9 d11f 192a b9e3 42d7  ..B........*..B.
        0x0060:  43af d801 13f9 99ee 14d5 9abe c7f6 ed99  C...............
        0x0070:  08ef d2e5 e24b a468 8a3b 60b6 42af 408b  .....K.h.;`.B.@.
        0x0080:  e4ec 7761 76f7 821b 0813 19d9 0f02 0b45  ..wav..........E
        0x0090:  3c19 0280 cbfb 0495 7c59 71fd e525 5168  <.......|Yq..%Qh
        0x00a0:  0514 9e3b 6b0b 3091 5b72 61c1 8f06 5656  ...;k.0.[ra...VV
        0x00b0:  8c70 d8ab f46a 184b 3341 b911 b56c 2aea  .p...j.K3A...l*.
        0x00c0:  2ef9 8885 da72 6aea 7fbe 6002 4ead b361  .....rj...`.N..a
        0x00d0:  f1a3 39cf d56f 3dc4 8554 dc3f 0c2e 5c94  ..9..o=..T.?..\.
        0x00e0:  a88c d680 f88f 34e4 875f c306 e5f3 9210  ......4.._......
        0x00f0:  3b71 39cc 9d1e d4b8 3814 da70 8398 7ad6  ;q9.....8..p..z.
        0x0100:  b235 2c3a 0b16 677d 3fa6 f691 ad1e bbf5  .5,:..g}?.......
        0x0110:  78ae 131d 2976 c507 f555 7ef4 65ff 0b17  x...)v...U~.e...
        0x0120:  3389 251d cd65 2eed 7124 6b47 dff7 9769  3.%..e..q$kG...i
        0x0130:  3fef 4e63 0246 c95d 5748 0c99 f4cf e328  ?.Nc.F.]WH.....(
        0x0140:  137b 1a15 2053 55a5 84b7 7e95 b3e8 1101  .{...SU...~.....
        0x0150:  d01f b9b6 230f 0110 bd9b 74ac 6294 03f7  ....#.....t.b...
        0x0160:  7202 240f f04b b2d6 48fa 28be da2c d859  r.$..K..H.(..,.Y
        0x0170:  9c02 fe9f f7ef bb62 df6e 69d8 e235 6ea4  .......b.ni..5n.
        0x0180:  65df 0958 4e40 df65 c1bc ee48 0e42 ed68  e..XN@.e...H.B.h
        0x0190:  5141 6408 3607 4fc5 0cfc ee89 8fc4 5672  QAd.6.O.......Vr
        0x01a0:  04f5 4b2e 5565 10aa 50a2 1d71 a87d 80dc  ..K.Ue..P..q.}..
        0x01b0:  eaf6 307c 73e7 7e4f e240 7f6d 9503 9b0c  ..0|s.~O.@.m....
        0x01c0:  a4cd 55d2 2fd9 8e52 59e0 4a5f 0d7b 2fc0  ..U./..RY.J_.{/.
        0x01d0:  6f38 70a6 621f acbe 14a1 5c9b 6479 aea1  o8p.b.....\.dy..

--网格外client测试抓包看是否是明文
root@k8s-master01:~# kubectl run test-client --image=ikubernetes/admin-box:v1.2 -it --restart=Always -n test --command /bin/sh	#新建网格外cleint
root@k8s-master01:~/istio/istio-in-practise/Security/01-PeerAuthentication-Policy-Basics# kubectl get pods -o wide -n test | grep client #网格外client信息
test-client   1/1     Running   0          109s   172.20.217.92   192.168.13.63   <none>           <none>
[root@k8s-node04 ~]# route -n | grep 172.20.217.92
172.20.217.92   0.0.0.0         255.255.255.255 UH    0      0        0 califaa96795e30
[root@k8s-node04 ~]# tcpdump -i califaa96795e30 -nn -X port 8080
root@test-client # curl demoapp.default:8080
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-fgb4n, ServerIP: 172.20.217.72!
22:49:13.342866 IP 10.68.120.190.8080 > 172.20.217.92.37266: Flags [P.], seq 1:359, ack 85, win 509, options [nop,nop,TS val 451620832 ecr 3207492797], length 358: HTTP: HTTP/1.1 200 OK
        0x0000:  4500 019a 508a 4000 3f06 e160 0a44 78be  E...P.@.?..`.Dx.
        0x0010:  ac14 d95c 1f90 9192 df58 246e ba66 1979  ...\.....X$n.f.y
        0x0020:  8018 01fd 0a00 0000 0101 080a 1aeb 2fe0  ............../.
        0x0030:  bf2e 74bd 4854 5450 2f31 2e31 2032 3030  ..t.HTTP/1.1.200
        0x0040:  204f 4b0d 0a63 6f6e 7465 6e74 2d74 7970  .OK..content-typ
        0x0050:  653a 2074 6578 742f 6874 6d6c 3b20 6368  e:.text/html;.ch
        0x0060:  6172 7365 743d 7574 662d 380d 0a63 6f6e  arset=utf-8..con
        0x0070:  7465 6e74 2d6c 656e 6774 683a 2031 3135  tent-length:.115
        0x0080:  0d0a 7365 7276 6572 3a20 6973 7469 6f2d  ..server:.istio-
        0x0090:  656e 766f 790d 0a64 6174 653a 204d 6f6e  envoy..date:.Mon
        0x00a0:  2c20 3032 204d 6179 2032 3032 3220 3134  ,.02.May.2022.14
        0x00b0:  3a34 393a 3133 2047 4d54 0d0a 782d 656e  :49:13.GMT..x-en
        0x00c0:  766f 792d 7570 7374 7265 616d 2d73 6572  voy-upstream-ser
        0x00d0:  7669 6365 2d74 696d 653a 2032 0d0a 782d  vice-time:.2..x-
        0x00e0:  656e 766f 792d 6465 636f 7261 746f 722d  envoy-decorator-
        0x00f0:  6f70 6572 6174 696f 6e3a 2064 656d 6f61  operation:.demoa
        0x0100:  7070 2e64 6566 6175 6c74 2e73 7663 2e63  pp.default.svc.c
        0x0110:  6c75 7374 6572 2e6c 6f63 616c 3a38 3038  luster.local:808
        0x0120:  302f 2a0d 0a0d 0a69 4b75 6265 726e 6574  0/*....iKubernet
        0x0130:  6573 2064 656d 6f61 7070 2076 312e 3020  es.demoapp.v1.0.
        0x0140:  2121 2043 6c69 656e 7449 503a 2031 3237  !!.ClientIP:.127
        0x0150:  2e30 2e30 2e36 2c20 5365 7276 6572 4e61  .0.0.6,.ServerNa
        0x0160:  6d65 3a20 6465 6d6f 6170 7076 3130 2d35  me:.demoappv10-5
        0x0170:  6334 3937 6336 6637 632d 6667 6234 6e2c  c497c6f7c-fgb4n,
        0x0180:  2053 6572 7665 7249 503a 2031 3732 2e32  .ServerIP:.172.2		#可以看出来是明文通信，IP地址信息清晰可见
        0x0190:  302e 3231 372e 3732 210a                 0.217.72!.

----对default名称空间下匹配的标签pod启用严格mTLS通信
root@k8s-master01:~/istio/istio-in-practise/Security/01-PeerAuthentication-Policy-Basics# cat 02-demoapp-peerauthn.yaml
---
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: demoapp
  namespace: default
spec:
  selector:
    matchLabels:
      app: demoapp
  mtls:
    mode: STRICT
----针对访问demoapp的客户端启用ISTIO_MUTUAL mTLS,如果PeerAuthentication定义服务端是PERMISSIVE，那么网格之外的client将不会受此影响而使用的是明文通信
root@k8s-master01:~/istio/istio-in-practise/Security/01-PeerAuthentication-Policy-Basics# cat 03-destinationrule-demoapp-mtls.yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: demoapp
spec:
  host: demoapp
  trafficPolicy:
    loadBalancer:
      simple: LEAST_CONN
    tls:
      mode: ISTIO_MUTUAL
  subsets:
  - name: v10
    labels:
      version: v1.0
  - name: v11
    labels:
      version: v1.1

----针对在default名称空间下特定标签的pod不进行配置mTLS,则从根名称空间(istio-system)继承使用mTLS配置
root@k8s-master01:~/istio/istio-in-practise/Security/02-PeerAuthentication-Disable# cat 02-demoapp-peerauthn.yaml
---
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: demoapp
  namespace: default
spec:
  selector:
    matchLabels:
      app: demoapp
  mtls:
    mode: UNSET
----针对访问demoapp的客户端禁用mTLS
root@k8s-master01:~/istio/istio-in-practise/Security/02-PeerAuthentication-Disable# cat 03-destinationrule-demoapp-mtls.yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: demoapp
spec:
  host: demoapp
  trafficPolicy:
    loadBalancer:
      simple: LEAST_CONN
    tls:
      mode: DISABLE
  subsets:
  - name: v10
    labels:
      version: v1.0
  - name: v11
    labels:
      version: v1.1

###Secure Gateway--IngressGateway开启TLS认证
#为kiali开启TLS
----生成测试使用的证书
root@k8s-master01:/tmp# mkdir certs && cd certs
root@k8s-master01:/tmp/certs# openssl req -x509 -sha256 -nodes -days 3650 -newkey rsa:2048 -subj '/O=MageEdu Inc./CN=magedu.com' -keyout magedu.com.key -out magedu.com.crt			#生成CA公私钥证书
root@k8s-master01:/tmp/certs# openssl req -out kiali.magedu.com.csr -newkey rsa:2048 -nodes -keyout kiali.magedu.com.key -subj '/CN=kiali.magedu.com/O=kiali organization'			#生成kiali.magedu.com.csr
root@k8s-master01:/tmp/certs# openssl x509 -req -days 3650 -CA magedu.com.crt -CAkey magedu.com.key -set_serial 0 -in kiali.magedu.com.csr -out kiali.magedu.com.crt
注：如果多次制作证书，其Serial number要递增

----生成相关的Secret资源
root@k8s-master01:/tmp/certs# kubectl create secret tls kiali-credential --key=kiali.magedu.com.key --cert=kiali.magedu.com.crt -n istio-system

----配置Gateway
root@k8s-master01:~/istio/istio-in-practise/Security/03-Ingress-Gateway-TLS/kiali# cat kiali-gateway.yaml
---
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: kiali-gateway
  namespace: istio-system
spec:
  selector:
    app: istio-ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "kiali.magedu.com"
    tls:
      httpsRedirect: true		#启用重写向到https
  - port:
      number: 443				#https端口为443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE				#tls模式为SIMPLE，就是单向TLS
      credentialName: kiali-credential		#之前定义的k8s secret资源
    hosts:
    - "kiali.magedu.com"		#https主机名
root@k8s-master01:~/istio/istio-in-practise/Security/03-Ingress-Gateway-TLS/kiali# kubectl apply -f kiali-gateway.yaml

----配置virtualservice
root@k8s-master01:~/istio/istio-in-practise/Security/03-Ingress-Gateway-TLS/kiali# cat kiali-virtualservice.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: kiali-virtualservice
  namespace: istio-system
spec:
  hosts:
  - "kiali.magedu.com"
  gateways:
  - kiali-gateway
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: kiali
        port:
          number: 20001
---
root@k8s-master01:~/istio/istio-in-practise/Security/03-Ingress-Gateway-TLS/kiali# kubectl apply -f kiali-virtualservice.yaml



###最终用户认证
#Request Authentication使用要点
- Request Authentication Policy会验证JSON Web Token（JWT）中几个关键字段的值 
  - 请求中token所处的位置
  - Issuer或者请求
  - 公共的JWKS
- Istio检查token的方法
  - 若请求报文针对request authentication policy中的rules提供了token, Istio将会核验这些token，并会拒绝无效的token
  - 但Istio默认会接受那些并未提供token的请求；若需要拒绝该类请求，则要通过相应的"授权"规则完成，由这些类规则负责完成针对特定操作的限制 
- Requesst Authentication Policy的生效机制
  - 每个JWT均使用了唯一的location时，Requesst Authentication Policy上甚至可以指定多个JWT
  - 多个policy匹配到了同一个workload时，Istio会将这多个policy上的规则进行合并
  - 目前，请求报文上尚不允许附带一个以上的JWT
注：没有定义授权策略时，已认证身份相当于授权

#RequestAuthentication实战
- 由Keycloak提供身份管理和访问管理
  - 著名的开源身份和访问管理）Identity and Access Management，简称为IAM）解决方案
  - 支持基于OAuth 2.0标准的OpenID Connect协议对用户进行身份验证
  - 应用程序可通过OAuth 2.0将身份验证委托给外部系统（例如Keycloak），从而实现SSO
  - 支持集成不同的身份认证服务，例如Github, Google和Facebook等
  - 支持用户联绑功能，可以通过LDAP或Kerberos来导入用户
- 客户端访问服务的请求将由Envoy代理拦截后交由Keycloak进行认证
  - 应用程序需要在访问目标服务时，自行通过OAuth 2.0协议与Keycloak进行交互，并在请求到JWT之后携带JWT向服务端发起请求
  - Envoy自v1.19版开始已然可通过http.auth2过滤器直接支持与IdPs(Identity Providers)交互，因而也无须再由应用程序实现该功能
    - 但，目前Istio尚未提供该功能的CRD
	- 于是，我们需要手动来测试该功能
	
#部署keycloak
DocumentUrl: https://www.keycloak.org/getting-started/getting-started-kube
root@k8s-master01:~/istio/istio-in-practise/Security/04-RequestAuthn-and-AuthzPolicy# curl -sSLO https://raw.githubusercontent.com/keycloak/keycloak-quickstarts/latest/kubernetes-examples/keycloak.yaml
root@k8s-master01:~/istio/istio-in-practise/Security/04-RequestAuthn-and-AuthzPolicy# cat keycloak.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: keycloak
---
apiVersion: v1
kind: Service
metadata:
  name: keycloak
  namespace: keycloak
  labels:
    app: keycloak
spec:
  ports:
  - name: http
    port: 8090				#改变service端口，与现有端口冲突
    targetPort: 8080
  selector:
    app: keycloak
  type: LoadBalancer
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: keycloak
  namespace: keycloak
  labels:
    app: keycloak
spec:
  replicas: 1
  selector:
    matchLabels:
      app: keycloak
  template:
    metadata:
      labels:
        app: keycloak
    spec:
      containers:
      - name: keycloak
        image: quay.io/keycloak/keycloak:18.0.0
        args: ["start-dev"]
        env:
        - name: KEYCLOAK_ADMIN
          value: "admin"
        - name: KEYCLOAK_ADMIN_PASSWORD
          value: "admin"
        - name: KC_PROXY
          value: "edge"
        ports:
        - name: http
          containerPort: 8080
        readinessProbe:
          httpGet:
            path: /realms/master
            port: 8080
root@k8s-master01:~/istio/istio-in-practise/Security/04-RequestAuthn-and-AuthzPolicy# kubectl apply -f keycloak.yaml
root@k8s-master01:~/istio/istio-in-practise/Security/04-RequestAuthn-and-AuthzPolicy# kubectl get all -n keycloak
NAME                            READY   STATUS              RESTARTS   AGE
pod/keycloak-64db9874f7-fjjck   0/1     ContainerCreating   0          9s

NAME               TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/keycloak   LoadBalancer   10.68.210.217   <pending>     8080:38775/TCP   11s

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/keycloak   0/1     1            0           10s

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/keycloak-64db9874f7   1         1         0       9s

----编辑主机名，并配置LoadBalanceIP来提供外部访问
root@k8s-master01:~/istio/istio-in-practise/Security/04-RequestAuthn-and-AuthzPolicy# vim /etc/hosts
172.168.2.28 kiali.magedu.com keycloak.magedu.com auth.magedu.com keycloak.keycloak.svc.homsom.local

root@k8s-master01:~/istio/istio-in-practise/Security/04-RequestAuthn-and-AuthzPolicy# kubectl edit svc keycloak -n keycloak
  externalIPs:
  - 172.168.2.28
root@k8s-master01:~/istio/istio-in-practise/Security/04-RequestAuthn-and-AuthzPolicy# kubectl get svc -n keycloak
NAME       TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)          AGE
keycloak   LoadBalancer   10.68.210.217   172.168.2.28   8080:38775/TCP   9m40s
root@k8s-master01:~/istio/istio-in-practise/Security/04-RequestAuthn-and-AuthzPolicy# ping keycloak.magedu.com

----访问keycloak，默认用户和密码都为admin
http://keycloak.magedu.com:8090/
配置为中文，Realm Settings -> Themes -> Internationalization(Enabled) -> Default Local(ZH-CN)

#keycloak概念
- 在Keycloak中，Realm是专门用来管理项目的工作区，各Realm之间的资源彼此隔离。Realm可分为两类：
  - 一是master Realm, 由Keycloak刚启动时自动创建，用于管理admin帐号以及创建其他的Realm。
  - 第二类称为other realm,由master realm中的admin用户创建
  - 我们通常应该在专门创建的other realm中为指定的项目管理用户、凭据、角色和组等
- 在Keycloak中，Client表示允许向Keycloak发起身份验证的实体，一般是指那些希望使用Keycloak来为其提供SSO的应用程序或服务；例如，网格内的认证，发起认证请求的客户端就是Sidecar Envoy

1. realm中添加新的istio领域，用于将istio的认证环境同其它应用进行隔离
名称：istio
配置固定Frontend URL：http://keycloak.keycloak.svc.homsom.local:8090
服务路径：访问realm的入口，http://keycloak.magedu.com:8090/realms/istio/.well-known/openid-configuration

2. 查看keycloak的openid configuration
root@k8s-master01:~/istio/istio-in-practise/Security/04-RequestAuthn-and-AuthzPolicy# curl -s http://keycloak.magedu.com:8090/realms/istio/.well-known/openid-configuration | jq .
{
  "issuer": "http://keycloak.magedu.com:8090/realms/istio",
  "authorization_endpoint": "http://keycloak.magedu.com:8090/realms/istio/protocol/openid-connect/auth",
  "token_endpoint": "http://keycloak.magedu.com:8090/realms/istio/protocol/openid-connect/token",
  "introspection_endpoint": "http://keycloak.magedu.com:8090/realms/istio/protocol/openid-connect/token/introspect",
  "userinfo_endpoint": "http://keycloak.magedu.com:8090/realms/istio/protocol/openid-connect/userinfo",
  "end_session_endpoint": "http://keycloak.magedu.com:8090/realms/istio/protocol/openid-connect/logout",
  "frontchannel_logout_session_supported": true,
  "frontchannel_logout_supported": true,
  "jwks_uri": "http://keycloak.magedu.com:8090/realms/istio/protocol/openid-connect/certs",
  "check_session_iframe": "http://keycloak.magedu.com:8090/realms/istio/protocol/openid-connect/login-status-iframe.html",
  "grant_types_supported": [
    "authorization_code",
    "implicit",
    "refresh_token",
    "password",
    "client_credentials",
    "urn:ietf:params:oauth:grant-type:device_code",
    "urn:openid:params:grant-type:ciba"
  ],
  "acr_values_supported": [
    "0",
    "1"
  ],
  "response_types_supported": [
    "code",
    "none",
    "id_token",
    "token",
    "id_token token",
    "code id_token",
    "code token",
    "code id_token token"
  ],
  "subject_types_supported": [
    "public",
    "pairwise"
  ],
  "id_token_signing_alg_values_supported": [
    "PS384",
    "ES384",
    "RS384",
    "HS256",
    "HS512",
    "ES256",
    "RS256",
    "HS384",
    "ES512",
    "PS256",
    "PS512",
    "RS512"
  ],
  "id_token_encryption_alg_values_supported": [
    "RSA-OAEP",
    "RSA-OAEP-256",
    "RSA1_5"
  ],
  "id_token_encryption_enc_values_supported": [
    "A256GCM",
    "A192GCM",
    "A128GCM",
    "A128CBC-HS256",
    "A192CBC-HS384",
    "A256CBC-HS512"
  ],
  "userinfo_signing_alg_values_supported": [
    "PS384",
    "ES384",
    "RS384",
    "HS256",
    "HS512",
    "ES256",
    "RS256",
    "HS384",
    "ES512",
    "PS256",
    "PS512",
    "RS512",
    "none"
  ],
  "userinfo_encryption_alg_values_supported": [
    "RSA-OAEP",
    "RSA-OAEP-256",
    "RSA1_5"
  ],
  "userinfo_encryption_enc_values_supported": [
    "A256GCM",
    "A192GCM",
    "A128GCM",
    "A128CBC-HS256",
    "A192CBC-HS384",
    "A256CBC-HS512"
  ],
  "request_object_signing_alg_values_supported": [
    "PS384",
    "ES384",
    "RS384",
    "HS256",
    "HS512",
    "ES256",
    "RS256",
    "HS384",
    "ES512",
    "PS256",
    "PS512",
    "RS512",
    "none"
  ],
  "request_object_encryption_alg_values_supported": [
    "RSA-OAEP",
    "RSA-OAEP-256",
    "RSA1_5"
  ],
  "request_object_encryption_enc_values_supported": [
    "A256GCM",
    "A192GCM",
    "A128GCM",
    "A128CBC-HS256",
    "A192CBC-HS384",
    "A256CBC-HS512"
  ],
  "response_modes_supported": [
    "query",
    "fragment",
    "form_post",
    "query.jwt",
    "fragment.jwt",
    "form_post.jwt",
    "jwt"
  ],
  "registration_endpoint": "http://keycloak.magedu.com:8090/realms/istio/clients-registrations/openid-connect",
  "token_endpoint_auth_methods_supported": [
    "private_key_jwt",
    "client_secret_basic",
    "client_secret_post",
    "tls_client_auth",
    "client_secret_jwt"
  ],
  "token_endpoint_auth_signing_alg_values_supported": [
    "PS384",
    "ES384",
    "RS384",
    "HS256",
    "HS512",
    "ES256",
    "RS256",
    "HS384",
    "ES512",
    "PS256",
    "PS512",
    "RS512"
  ],
  "introspection_endpoint_auth_methods_supported": [
    "private_key_jwt",
    "client_secret_basic",
    "client_secret_post",
    "tls_client_auth",
    "client_secret_jwt"
  ],
  "introspection_endpoint_auth_signing_alg_values_supported": [
    "PS384",
    "ES384",
    "RS384",
    "HS256",
    "HS512",
    "ES256",
    "RS256",
    "HS384",
    "ES512",
    "PS256",
    "PS512",
    "RS512"
  ],
  "authorization_signing_alg_values_supported": [
    "PS384",
    "ES384",
    "RS384",
    "HS256",
    "HS512",
    "ES256",
    "RS256",
    "HS384",
    "ES512",
    "PS256",
    "PS512",
    "RS512"
  ],
  "authorization_encryption_alg_values_supported": [
    "RSA-OAEP",
    "RSA-OAEP-256",
    "RSA1_5"
  ],
  "authorization_encryption_enc_values_supported": [
    "A256GCM",
    "A192GCM",
    "A128GCM",
    "A128CBC-HS256",
    "A192CBC-HS384",
    "A256CBC-HS512"
  ],
  "claims_supported": [
    "aud",
    "sub",
    "iss",
    "auth_time",
    "name",
    "given_name",
    "family_name",
    "preferred_username",
    "email",
    "acr"
  ],
  "claim_types_supported": [
    "normal"
  ],
  "claims_parameter_supported": true,
  "scopes_supported": [
    "openid",
    "offline_access",
    "phone",
    "microprofile-jwt",
    "roles",
    "email",
    "acr",
    "web-origins",
    "address",
    "profile"
  ],
  "request_parameter_supported": true,
  "request_uri_parameter_supported": true,
  "require_request_uri_registration": true,
  "code_challenge_methods_supported": [
    "plain",
    "S256"
  ],
  "tls_client_certificate_bound_access_tokens": true,
  "revocation_endpoint": "http://keycloak.magedu.com:8090/realms/istio/protocol/openid-connect/revoke",
  "revocation_endpoint_auth_methods_supported": [
    "private_key_jwt",
    "client_secret_basic",
    "client_secret_post",
    "tls_client_auth",
    "client_secret_jwt"
  ],
  "revocation_endpoint_auth_signing_alg_values_supported": [
    "PS384",
    "ES384",
    "RS384",
    "HS256",
    "HS512",
    "ES256",
    "RS256",
    "HS384",
    "ES512",
    "PS256",
    "PS512",
    "RS512"
  ],
  "backchannel_logout_supported": true,
  "backchannel_logout_session_supported": true,
  "device_authorization_endpoint": "http://keycloak.magedu.com:8090/realms/istio/protocol/openid-connect/auth/device",
  "backchannel_token_delivery_modes_supported": [
    "poll",
    "ping"
  ],
  "backchannel_authentication_endpoint": "http://keycloak.magedu.com:8090/realms/istio/protocol/openid-connect/ext/ciba/auth",
  "backchannel_authentication_request_signing_alg_values_supported": [
    "PS384",
    "ES384",
    "RS384",
    "ES256",
    "RS256",
    "ES512",
    "PS256",
    "PS512",
    "RS512"
  ],
  "require_pushed_authorization_requests": false,
  "pushed_authorization_request_endpoint": "http://keycloak.magedu.com:8090/realms/istio/protocol/openid-connect/ext/par/request",
  "mtls_endpoint_aliases": {
    "token_endpoint": "http://keycloak.magedu.com:8090/realms/istio/protocol/openid-connect/token",
    "revocation_endpoint": "http://keycloak.magedu.com:8090/realms/istio/protocol/openid-connect/revoke",
    "introspection_endpoint": "http://keycloak.magedu.com:8090/realms/istio/protocol/openid-connect/token/introspect",
    "device_authorization_endpoint": "http://keycloak.magedu.com:8090/realms/istio/protocol/openid-connect/auth/device",
    "registration_endpoint": "http://keycloak.magedu.com:8090/realms/istio/clients-registrations/openid-connect",
    "userinfo_endpoint": "http://keycloak.magedu.com:8090/realms/istio/protocol/openid-connect/userinfo",
    "pushed_authorization_request_endpoint": "http://keycloak.magedu.com:8090/realms/istio/protocol/openid-connect/ext/par/request",
    "backchannel_authentication_endpoint": "http://keycloak.magedu.com:8090/realms/istio/protocol/openid-connect/ext/ciba/auth"
  }
}


3. 在istio realm中创建客户端
客户端ID: istio-client
客户端协议：openid-connect

4. 创建用户并设置密码
用户名：tom
密码：magedu.com

5. 访问token接口获取token
URL: "token_endpoint":"http://keycloak.magedu.com:8090/realms/istio/protocol/openid-connect/token"
root@k8s-master01:~# curl -s -d 'username=tom&password=magedu.com&grant_type=password&client_id=istio-client' http://keycloak.magedu.com:8090/realms/istio/protocol/openid-connect/token
{"access_token":"eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ2Z2tTci10MlJseFNuU3hDS2JUQkZXbzF3Szh6a2VOcFd4OTYwd2J5Y2h3In0.eyJleHAiOjE2NTE1NzI0MjAsImlhdCI6MTY1MTU3MjEyMCwianRpIjoiZDE2YzI1NWUtNzE4MC00YzZkLTkxZmUtN2NkNTJiOWNkNjY5IiwiaXNzIjoiaHR0cDovL2tleWNsb2FrLm1hZ2VkdS5jb206ODA5MC9yZWFsbXMvaXN0aW8iLCJhdWQiOiJhY2NvdW50Iiwic3ViIjoiNTIxMzhkMmEtZDIyOC00ODA4LWJlOTctYTVlODdhYWFkNTU3IiwidHlwIjoiQmVhcmVyIiwiYXpwIjoiaXN0aW8tY2xpZW50Iiwic2Vzc2lvbl9zdGF0ZSI6IjlmNjhkMDMyLTliNzUtNGQ3MS05Zjc5LTU3ZGZkYWNiMThiYiIsImFjciI6IjEiLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsib2ZmbGluZV9hY2Nlc3MiLCJ1bWFfYXV0aG9yaXphdGlvbiIsImRlZmF1bHQtcm9sZXMtaXN0aW8iXX0sInJlc291cmNlX2FjY2VzcyI6eyJhY2NvdW50Ijp7InJvbGVzIjpbIm1hbmFnZS1hY2NvdW50IiwibWFuYWdlLWFjY291bnQtbGlua3MiLCJ2aWV3LXByb2ZpbGUiXX19LCJzY29wZSI6ImVtYWlsIHByb2ZpbGUiLCJzaWQiOiI5ZjY4ZDAzMi05Yjc1LTRkNzEtOWY3OS01N2RmZGFjYjE4YmIiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsIm5hbWUiOiJ0b20gbWFnZWR1IiwicHJlZmVycmVkX3VzZXJuYW1lIjoidG9tIiwiZ2l2ZW5fbmFtZSI6InRvbSIsImZhbWlseV9uYW1lIjoibWFnZWR1IiwiZW1haWwiOiJ0b21AbWFnZWR1LmNvbSJ9.P749qkxXvxFuKsyGQK_uVYOlqfPoHIDo_vBDrrRsjOK3H1zq2yIQ4uP2bI55jDX7QhS1WU6WZSS7NlrsEV9v6Q7vvkf-Lb6lKg2KhYCUzw2UJSFJQSL-ipdAZMj_NNSQ4IZGwHRlexo3i8JasCgQUQRE49xyJ6cAWMjfIV_XUKZ3AT0c7IOZ7jk4kFV1B_xVfCyx-Btj8Cic29N8Hoy0SAhZz3hQpd3CRwPOIWKf7Qxp2tatoVl5x7OEFLqfE3Y9rR954f9ZtVo3JQSv66cUJcyF-CUBHcEcnmbl-KSZbXy3rovL0biZrG6rq3KK36nLrEc8Pbw1tWvDNBrxhsfzYQ","expires_in":300,"refresh_expires_in":1800,"refresh_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICIwNzllMGEzMS1kN2EyLTRiZDMtODcyNy0xOWM2YzE0ODA1ZjgifQ.eyJleHAiOjE2NTE1NzM5MjAsImlhdCI6MTY1MTU3MjEyMCwianRpIjoiOTBiNzQ3ZTMtZmE0Yi00NzI2LWEyYTUtMTg5ZTA4ZDI4MjZlIiwiaXNzIjoiaHR0cDovL2tleWNsb2FrLm1hZ2VkdS5jb206ODA5MC9yZWFsbXMvaXN0aW8iLCJhdWQiOiJodHRwOi8va2V5Y2xvYWsubWFnZWR1LmNvbTo4MDkwL3JlYWxtcy9pc3RpbyIsInN1YiI6IjUyMTM4ZDJhLWQyMjgtNDgwOC1iZTk3LWE1ZTg3YWFhZDU1NyIsInR5cCI6IlJlZnJlc2giLCJhenAiOiJpc3Rpby1jbGllbnQiLCJzZXNzaW9uX3N0YXRlIjoiOWY2OGQwMzItOWI3NS00ZDcxLTlmNzktNTdkZmRhY2IxOGJiIiwic2NvcGUiOiJlbWFpbCBwcm9maWxlIiwic2lkIjoiOWY2OGQwMzItOWI3NS00ZDcxLTlmNzktNTdkZmRhY2IxOGJiIn0.k1LnFekH3F-DVXICdptP-y7M1dhLGOFdtG3MGB3w8Hw","token_type":"Bearer","not-before-policy":0,"session_state":"9f68d032-9b75-4d71-9f79-57dfdacb18bb","scope":"email profile"}
root@k8s-master01:~# curl -s -d 'username=tom&password=magedu.com&grant_type=password&client_id=istio-client' http://keycloak.magedu.com:8090/realms/istio/protocol/openid-connect/token | jq .access_token		#token每次不同，是有效期的，默认5分钟
"eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ2Z2tTci10MlJseFNuU3hDS2JUQkZXbzF3Szh6a2VOcFd4OTYwd2J5Y2h3In0.eyJleHAiOjE2NTE1NzI1NjIsImlhdCI6MTY1MTU3MjI2MiwianRpIjoiYTE0Y2Y4ZTItYjM0Mi00ZjEzLTg1N2UtMGY1YjNmOWFiMDIzIiwiaXNzIjoiaHR0cDovL2tleWNsb2FrLm1hZ2VkdS5jb206ODA5MC9yZWFsbXMvaXN0aW8iLCJhdWQiOiJhY2NvdW50Iiwic3ViIjoiNTIxMzhkMmEtZDIyOC00ODA4LWJlOTctYTVlODdhYWFkNTU3IiwidHlwIjoiQmVhcmVyIiwiYXpwIjoiaXN0aW8tY2xpZW50Iiwic2Vzc2lvbl9zdGF0ZSI6ImNkMGRkNzY4LTA1MjAtNDlhZS05OGM3LTEyNGJjZTNiYWYwZiIsImFjciI6IjEiLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsib2ZmbGluZV9hY2Nlc3MiLCJ1bWFfYXV0aG9yaXphdGlvbiIsImRlZmF1bHQtcm9sZXMtaXN0aW8iXX0sInJlc291cmNlX2FjY2VzcyI6eyJhY2NvdW50Ijp7InJvbGVzIjpbIm1hbmFnZS1hY2NvdW50IiwibWFuYWdlLWFjY291bnQtbGlua3MiLCJ2aWV3LXByb2ZpbGUiXX19LCJzY29wZSI6ImVtYWlsIHByb2ZpbGUiLCJzaWQiOiJjZDBkZDc2OC0wNTIwLTQ5YWUtOThjNy0xMjRiY2UzYmFmMGYiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsIm5hbWUiOiJ0b20gbWFnZWR1IiwicHJlZmVycmVkX3VzZXJuYW1lIjoidG9tIiwiZ2l2ZW5fbmFtZSI6InRvbSIsImZhbWlseV9uYW1lIjoibWFnZWR1IiwiZW1haWwiOiJ0b21AbWFnZWR1LmNvbSJ9.Ugwa8SJpPTdicRLWyK3OY3vhHy4oLocyI_3He8cn66Ia0KAtmU8mTYDARKDrPG0hqvudXKLreXKFDQdR1dq6vN-L3OUtjDq7aTQ6WsaUsdFdS2IC8pU8zh9Ba9XOm_pju73stQMFJs4XYniNTacxab656I9NB9SlE_qQtapz4HUAmi_R5_SGext2YWqnvPEw8It8gfhWhZPins90DFykhqozvCmWF_izTCw69w1gB2b5lsnGFm4wSa0fEEt8VF7qgDyb4rsbyddkpZS9CSsxW_5jLo4-44LwuaFVCOglOyOP_VKnSGrrmBgU0TSZLeS2SdaQam7umsqOpEI41CyWZw"


6. 复制access_token JWT网站(jwt.io)进行解析，查看token信息是否如自己配置一样

7. 进入网格中的client
root@k8s-master01:~# kubectl exec -it client /bin/sh
root@client # apk add jq		#安装jq包
root@client # curl -s -d 'username=tom&password=magedu.com&grant_type=password&client_id=istio-client' http://keycloak.keycloak.svc.homsom.local:8090/realms/istio/
protocol/openid-connect/token | jq .access_token
"eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ2Z2tTci10MlJseFNuU3hDS2JUQkZXbzF3Szh6a2VOcFd4OTYwd2J5Y2h3In0.eyJleHAiOjE2NTE1NzI3MjgsImlhdCI6MTY1MTU3MjQyOCwianRpIjoiNGJjM2Q3ZmMtM2RjYS00NzliLTkzZDgtZTc1ZjE5YmRjYWVhIiwiaXNzIjoiaHR0cDovL2tleWNsb2FrLmtleWNsb2FrLnN2Yy5ob21zb20ubG9jYWwvcmVhbG1zL2lzdGlvIiwiYXVkIjoiYWNjb3VudCIsInN1YiI6IjUyMTM4ZDJhLWQyMjgtNDgwOC1iZTk3LWE1ZTg3YWFhZDU1NyIsInR5cCI6IkJlYXJlciIsImF6cCI6ImlzdGlvLWNsaWVudCIsInNlc3Npb25fc3RhdGUiOiJmOThjMzk0Ny02NTEzLTQ5M2EtYWQyMS0wOWNiZWFkNjIyNmIiLCJhY3IiOiIxIiwicmVhbG1fYWNjZXNzIjp7InJvbGVzIjpbIm9mZmxpbmVfYWNjZXNzIiwidW1hX2F1dGhvcml6YXRpb24iLCJkZWZhdWx0LXJvbGVzLWlzdGlvIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwic2NvcGUiOiJlbWFpbCBwcm9maWxlIiwic2lkIjoiZjk4YzM5NDctNjUxMy00OTNhLWFkMjEtMDljYmVhZDYyMjZiIiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJuYW1lIjoidG9tIG1hZ2VkdSIsInByZWZlcnJlZF91c2VybmFtZSI6InRvbSIsImdpdmVuX25hbWUiOiJ0b20iLCJmYW1pbHlfbmFtZSI6Im1hZ2VkdSIsImVtYWlsIjoidG9tQG1hZ2VkdS5jb20ifQ.iRPz62LUQzAhWWl_BKedK8f_YmrWHzuOTFWgwfCvruRIPjIIO-be_C-5_dvJhRNOHwgXCLxdua1SbH1B_LZeih-7WeL-ERz5XtffMBRcPh2oKCbaA-7P0eM8hRPgACNZS8VuQaRkW426T4Qr-5CuMuOtEvL1kbGdIF0j90Pf1r_aVNm8GCte701-DHJbCOKMG7MauI9raFHZ2uAEi5dLMPcb31PT-tkpLcTMbbite9QNFEOFAB-WVACTF2d9dVo2LV8nQkfSHipE9GcPNFchmCtiZvAunRL_2ChRBZlKBZyAfJS5PULlxbDQGp3ntzQrRIdr1T7GLpDNd15-nnjdNA"

8. 将token赋值给变量TOKEN
root@client # TOKEN=`curl -s -d 'username=tom&password=magedu.com&grant_type=password&client_id=istio-client' http://keycloak.keycloak.svc.homsom.local:8090/realms/istio/protocol/openid-connect/token | jq .access_token`

9. 用网格外部客户端测试访问demoapp，当前envoy未强制启用客户端进行认证，所以如下访问跟未添加TOKEN时访问效果一样
root@test-client # curl -H "Authorization: Bearer $TOKEN" demoapp.default:8080
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-fgb4n, ServerIP: 172.20.217.72!

10. 配置envoy启用客户端令牌认证
注：issuer和jwksUri地址必须是网格内client访问到的地址，与网格外地址不一样，信息如下：
  "issuer": "http://keycloak.keycloak.svc.homsom.local/realms/istio",
  "authorization_endpoint": "http://keycloak.keycloak.svc.homsom.local/realms/istio/protocol/openid-connect/auth",
  "token_endpoint": "http://keycloak.keycloak.svc.homsom.local/realms/istio/protocol/openid-connect/token",
  "introspection_endpoint": "http://keycloak.keycloak.svc.homsom.local/realms/istio/protocol/openid-connect/token/introspect",
  "userinfo_endpoint": "http://keycloak.keycloak.svc.homsom.local/realms/istio/protocol/openid-connect/userinfo",
  "end_session_endpoint": "http://keycloak.keycloak.svc.homsom.local/realms/istio/protocol/openid-connect/logout",
  "frontchannel_logout_session_supported": true,
  "frontchannel_logout_supported": true,
  "jwks_uri": "http://keycloak.keycloak.svc.homsom.local/realms/istio/protocol/openid-connect/certs",	#用私钥加密用户的token，envoy并用公钥进行解密，获取token校验码和解密后的校验码进行比较，看是否一样。因此此路径是公开访问的
  "check_session_iframe": "http://keycloak.keycloak.svc.homsom.local/realms/istio/protocol/openid-connect/login-status-iframe.html",
  
root@k8s-master01:~/istio/istio-in-practise/Security/04-RequestAuthn-and-AuthzPolicy# cat 02-requestauthn-policy.yaml	
apiVersion: security.istio.io/v1beta1
kind: RequestAuthentication
metadata:
  name: demoapp
  namespace: default
spec:
  selector:
    matchLabels:
      app: demoapp					#针对default名称空间下特定pod，也可以针对整个default名称空间，甚至所有网格中应用(istio-system中定义)
  jwtRules:
  - issuer: "http://keycloak.keycloak.svc.homsom.local:8090/realms/istio"		#此issuer必须跟网格内client访问到的issuer要一模一样，因为是在网格内访问
    jwksUri: "http://keycloak.keycloak.svc.homsom.local:8090/realms/istio/protocol/openid-connect/certs"		#如上一样
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: demoapp
  namespace: default
spec:
  selector:
    matchLabels:
      app: demoapp
  rules:
  - from:
    - source:
        requestPrincipals: ["*"]
    to:
    - operation:
        methods: ["GET"]
        paths: ["/*"]
root@k8s-master01:~/istio/istio-in-practise/Security/04-RequestAuthn-and-AuthzPolicy# kubectl apply -f 02-requestauthn-policy.yaml

11. 测试启用客户端认证后，使用token访问的效果
root@test-client # TOKEN=`curl -s -d 'username=tom&password=magedu.com&grant_type=password&client_id=istio-client' http://keycloak.keycloak.svc.homsom.local:8090/realms/istio/protocol/openid-connect/token | jq .access_token`
root@test-client # curl demoapp.default:8080
RBAC: access deniedroot@client #
root@test-client # curl -H "Authorization: Bearer $TOKEN" demoapp.default:8080
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-wzvnn, ServerIP: 172.20.217.101!
root@test-client # curl -H "Authorization: Bearer $TOKEN" demoapp.default:8080
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-5c497c6f7c-wzvnn, ServerIP: 172.20.217.101!
#注JWT主要针对外部浏览器用户，如果是内部用户访问需要内置OAuth2.0客户端才行

#Istio Authorization
- Istio的授权机制为Isto网格中的workload提供了mesh-level, namespace-level, workload-level的访问控制机制，它提供如下特性
  - Workload-to-workload和end-user-to-workload授权
  - 简单的API: 只包含一个简单的AuthorizationPolicy CRD，易于使用和维护
  - 灵活的语义：运维人员可以在Istio属性的基础上自定义检查条件
  - 较好的性能表现：授权检查仅在Envoy本地执行
  - 较好的兼容性：原生支持HTTP/HTTPS/HTTP2，以及更底层的通信TCP协议

#启用授权
- Istio的授权功能默认即为开启状态，用户定义出所需的Authorization Policy即可使用相关的功能
  - 未有相匹配的授权策略时，Istio默认将允许对其发出的所有操作。但只要有一个授权策略匹配到工作负载，其默认策略将自动成为DENY
  - 授权策略支持的action有CUSTOM, DENY, ALLOW三种
  - 多个策略关联至同一工作负载时，Istio会将相关的策略进行组合
- 策略生效机制
  - 三者同时作用于某工作负载时，评估次序依次为CUSTOM, DENY, ALLOW_ANY
    - 若存在与请求相匹配的任何CUSTOM策略，授权结果为DENY时，则拒绝请求
	- 若存在与请求相匹配的任何DENY策略，则拒绝请求
	- 工作负载上不存在ALLOW策略时，则允许请求
	- 存在与请求相匹配的任意ALLOW策略时，允许请求
	- 拒绝所有请求
  - AUDIT可确定是否记录请求，但它不生成授权结果

#AuthenrizationPolicy CR
- selector用于选定策略的适用的目标workload，策略的最终生效结果由selector和metadata.namespace共同决定
  - 设置为根名称空间时则该策略将应用于网格中的所有命名空间；根命名空间可配置，默认什来istio-system
  - 省略名称空间时表示应用于网格内的所有名称空间
  - workload selector可用于进一步限制策略的应用范围，它使用pod标签来选择目标workload
- rules用于定义根据指定何时触发动作
  - 嵌套的字段 
    - from字段：匹配的操作请求发出者
	- to字段：匹配的操作目标
	- when字段：应用该规则的触发条件
  - 注意
    - DENY策略优先于ALLOW策略；istio会优先评估DENY策略，以确保ALLOW策略无法绕过DENY策略
	- 空值的rules字段（即未定义任何有效的列表项），表示允许对目标workload的所有访问请求

#AuthorizationPolicy
root@k8s-master01:~/istio/istio-in-practise/Security/04-RequestAuthn-and-AuthzPolicy# cat 03-request-and-peer-authn-policy.yaml
apiVersion: security.istio.io/v1beta1
kind: RequestAuthentication
metadata:
  name: demoapp
  namespace: default
spec:
  selector:
    matchLabels:
      app: demoapp
  jwtRules:
  - issuer: "http://keycloak.keycloak.svc.homsom.local:8090/realms/istio"
    jwksUri: "http://keycloak.keycloak.svc.homsom.local:8090/realms/istio/protocol/openid-connect/certs"
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: demoapp
  namespace: default
spec:
  selector:
    matchLabels:
      app: demoapp
  rules:
  - from:		#第一步规则
    - source:
        principals: ["cluster.local/ns/default/sa/default"]		#表示客户端为此spiffe ID，需要网格上启用mTLS，否则不会成功，当跟istio有关系时集群后缀为cluster.local，否则为自定义集群后缀，此k8s后缀原为homsom.local
    - source:	#两者是或的关系
        namespaces: ["default", "dev", "istio-system"]			#或 表示客户端在注入sidecar的特定名称空间上的pod
    to:
    - operation:				#操作为GET所有路径
        methods: ["GET"]
        paths: ["/*"]
  - from:			#另外一条规则
    - source:
        requestPrincipals: ["*"]		#表示经过验证的TOKEN用户名称，例如tom，*表示所有，针对RequestAuthentication
        principals: ["cluster.local/ns/default/sa/default"]	#而且客户端为此spiffe ID，需要网格上启用mTLS，否则不会成功，针对PeerAuthentication
    to:
    - operation:				#操作为POST特定路径/livez，/readyz
        methods: ["POST"]
        paths: ["/livez", "/readyz"]
    when:
    - key: request.auth.claims[iss]		#当请求的TOKEN的issuer是http://keycloak.keycloak.svc.homsom.local:8090/realms/istio时，才进行上面的匹配操作
      values: ["http://keycloak.keycloak.svc.homsom.local:8090/realms/istio"]


####网格和SSO
###在Istio Ingress Gateway上实现SSO
#方法1：Ingress TLS passthrough, JWT Validation at Sidecars
- 工作流程：
  - 用户（客户端）自行向SSO进行身份验证并取得JWT
  - Istio Ingress Gateway将请求和JWT转发至目标服务相关的工作负载
  - ProductPage Pod的Istio-proxy容器根据相关的RequestAuthentication和AuthorizationPolicy验证JWT
  - 若JWT有效，则开放/productpage给用户，否则，将返回错误消息（RBAC denied）
- 优点：
  - 方法简便，只需要两个相关的CR对象
  - 基于JWT，实现细粒度的授权
- 缺点
  - 无OIDC工作流：用户必须要自己获取JWT，并自行附加于HTTP请求之上
  - 需要为每个应用各自定义RequestAuthentication和AuthenticationPolicy CR资源对象
 
 #方法2：由Ingress Gateway完成OIDC工作流
 - 有两种常用的方法
   - 为Ingress Gateway添加oauth2-proxy Sidecar, 或者将oauth2-proxy部署为独立服务
   - 使用新版本的Envoy自带oauth2 filter进行
 - 工作流程：
   - 用户执行未经身份验证的HTTP请求
   - 未经验证的请求，将会由oauth2-proxy启动OIDC工作流程，由用户参与完成身份验证
   - 用户执行经过身份验证的HTTP请求，而oauth2-proxy基于HTTP Cookie验证用户身份
   - oauth2-proxy将请求回传给Ingress Gateway，再由Gateway转给工作负载Pod上的istio-proxy容器
   - 用户获利目标服务的响应
 - 优点：
   - 在Ingress Gateway强制完成身份认证
   - 自动化OIDC工作流
 - 缺点：
   - 粗粒度授权（已认证==已授权），且配置较复杂
 
#方法3：组合JWT和oauth2-proxy自动化OIDC
- 要点：
  - 身份认证由oauth2-proxy自动完成
  - oauth2-proxy从cookie中自动提取JWT，并将其通过HTTP请求上的特定标头（X-Forwarded-Access-Token）转发至istio-proxy
- 工作流程：
  - 用户执行未经身份验证的HTTP请求
  - 未经验证的请求，将会由oauth2-proxy启动OIDC工作流程，由用户参与完成身份验证
  - 用户执行未经身份验证的HTTP请求，而oauth2-proxy基于HTTP Cookie验证用户身份
  - oauth2-proxy从请求报文的cookie中提取JWT，并将其使用特定标头发送至Ingress Gateway
  - Ingress Gateway将请求和JWT标头转发至目标工作负载的istio-proxy容器
  - 目标工作负载上的istio-proxy根据RequestAuthentication和AuthorizationPolicy确认JWT的有效性
  - 若JWT有效，则开放目标服务给用户，否则，将返回错误消息（RBAC denied）

#实现步骤
- 部署Keycloak，创建专用的Realm，并添加OAuth2-Proxy专用的Client
- 部署OAuth2-Proxy应用，配置专用的Client ID和Secret接入Keycloak
- 配置Istio网格，将OAuth2-Proxy添加为Provider
- 创建专用于Ingress Gateway的AuthorizationPolicy，通过CUSTOM action将特定主机的授权委托给外部的Provider
- 在Keycloak上添加用户后，测试访问 "kiali.magedu.com" 和 "prometheus.magedu.com"等应用
  - "已认证 == 已授权"
- 在Keycloak上精心编排用户、角色和组等，完成分组授权

#Keycloak上的Access Type共有三类：
- confidential: 适用于需要执行浏览器登录的应用，客户端会通过client secret来获取access token，多用于服务端渲染的web系统场景中
- public: 适用于需要执行浏览器登录的应用，多运用于使用vue和react实现的前端项目
- bearer-only: 适用于不需要执行浏览顺登录的应用，只允携带bearer token访问，多运用于RESTful API的使用场景
注：kiali, grafana, prometheus等的UI即是服务端渲染的web系统


1. 添加客户端
客户端 ID：ingress-gateway
访问类型：confidential
有效的重定向URI：*
注：此时ingress-gateway客户端就会有凭据选项卡了，凭据中有秘密：EKCuaLa56Ig34luBkZcIOV4geEq6RoV8，这个秘密后面会使用，不要点重置

2. 部署oauth2-proxy
root@k8s-master01:~/istio/istio-in-practise/Security/05-JWT-and-Keycloak# cat 01-deploy-oauth2.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: oauth2-proxy
  labels:
    istio-injection: enabled
---
apiVersion: v1
kind: Secret
metadata:
  name: oauth2-proxy
  namespace: oauth2-proxy
stringData:
  # change this to your Keycloak Realm Client Id
  OAUTH2_PROXY_CLIENT_ID: ingress-gateway
  # change this to your Keycloak Client Secret
  OAUTH2_PROXY_CLIENT_SECRET: EKCuaLa56Ig34luBkZcIOV4geEq6RoV8		#上一步获取的秘密
  # Generate by command: openssl rand -base64 32 | tr -- '+/' '-_'
  OAUTH2_PROXY_COOKIE_SECRET: vEBMxbw7NXfaUIJR4klhdvB678GUPxWTd7tR9hq2m8w=		#随机生成的ID
---
apiVersion: v1
kind: Service
metadata:
  name: oauth2-proxy
  namespace: oauth2-proxy
spec:
  selector:
    app: oauth2-proxy
  ports:
  - name: http
    port: 4180
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: oauth2-proxy
  namespace: oauth2-proxy
spec:
  selector:
    matchLabels:
      app: oauth2-proxy
  template:
    metadata:
      labels:
        app: oauth2-proxy
    spec:
      containers:
      - name: oauth2-proxy
        image: quay.io/oauth2-proxy/oauth2-proxy:v7.2.1
        args:
        - --provider=oidc
        - --oidc-issuer-url=http://keycloak.keycloak.svc.homsom.local:8090/realms/istio		#issuer地址，此地址确保网格外部可访问到
        - --profile-url=http://keycloak.keycloak.svc.homsom.local:8090/realms/istio/protocol/openid-connect/userinfo	#"userinfo_endpoint"地址
        - --validate-url=http://keycloak.keycloak.svc.homsom.local:8090/realms/istio/protocol/openid-connect/userinfo	#"userinfo_endpoint"地址
        - --set-authorization-header=true
        - --http-address=0.0.0.0:4180		#oauth2-proxy监听的地址
        - --pass-host-header=true
        - --reverse-proxy=true
        - --auth-logging=true
        - --cookie-httponly=true
        - --cookie-refresh=4m
        - --cookie-secure=false				#默认为true,需要部署为https模式。更改为false后可使用http访问，为方便测试使用http访问
        - --email-domain="*"
        - --pass-access-token=true
        - --pass-authorization-header=true
        - --request-logging=true
        - --set-xauthrequest=true
        - --silence-ping-logging=true
        - --skip-provider-button=true
        - --skip-auth-strip-headers=false
        - --ssl-insecure-skip-verify=true
        - --standard-logging=true
        - --upstream="static://200"
        - --whitelist-domain=".magedu.com,.homsom.local"		#白名单域，可自行添加
        env:
        - name: OAUTH2_PROXY_CLIENT_ID
          valueFrom:
            secretKeyRef:
              name: oauth2-proxy
              key: OAUTH2_PROXY_CLIENT_ID
        - name: OAUTH2_PROXY_CLIENT_SECRET
          valueFrom:
            secretKeyRef:
              name: oauth2-proxy
              key: OAUTH2_PROXY_CLIENT_SECRET
        - name: OAUTH2_PROXY_COOKIE_SECRET
          valueFrom:
            secretKeyRef:
              name: oauth2-proxy
              key: OAUTH2_PROXY_COOKIE_SECRET
        resources:
          requests:
            cpu: 10m
            memory: 100Mi
        ports:
        - containerPort: 4180
          protocol: TCP
        readinessProbe:
          periodSeconds: 3
          httpGet:
            path: /ping
            port: 4180
---
root@k8s-master01:~/istio/istio-in-practise/Security/05-JWT-and-Keycloak# kubectl apply -f 01-deploy-oauth2.yaml
--报错
root@k8s-master01:~/istio/istio-in-practise/Security/05-JWT-and-Keycloak# kubectl logs -f oauth2-proxy-bcd4989d5-wg754 -n oauth2-proxy
[2022/05/04 15:10:52] [main.go:54] oidc: issuer did not match the issuer returned by provider, expected "http://keycloak.keycloak.svc.homsom.local:8090/realms/istio" got "http://keycloak.keycloak.svc.homsom.local/realms/istio"
--解决，去领域istio中配置固定Frontend URL：http://keycloak.keycloak.svc.homsom.local:8090
root@k8s-master01:~/istio/istio-in-practise/Security/05-JWT-and-Keycloak# kubectl get pods -n oauth2-proxy
NAME                           READY   STATUS    RESTARTS   AGE
oauth2-proxy-bcd4989d5-89862   2/2     Running   1          64s

3. 将OAuth2-Proxy添加为Provider
root@k8s-master01:~/istio/istio-in-practise/Security/05-JWT-and-Keycloak# cat 02-istio-operator-update.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  profile: demo
  meshConfig:
    extensionProviders:				#添加外部providers，以后添加skywalking也是这样添加
    - name: oauth2-proxy			#providers名称
      envoyExtAuthzHttp:
        service: oauth2-proxy.oauth2-proxy.svc.cluster.local	#prodivers地址
        port: 4180												#prodivers端口
        timeout: 1.5s											#连接超时时间
        includeHeadersInCheck: ["authorization", "cookie"]		#对进入的流量，检查定义的标头是否认证通过，如果未认证通过将以重定向的方式请求认证
        headersToUpstreamOnAllow: ["x-forwarded-access-token", "authorization", "path", "x-auth-request-user", "x-auth-request-email", "x-auth-request-access-token"]								#认证通过了转发的标头
        headersToDownstreamOnDeny: ["content-type", "set-cookie"]	 #认证未通过转发的标头
root@k8s-master01:~/istio/istio-in-practise/Security/05-JWT-and-Keycloak# istioctl install -f 02-istio-operator-update.yaml	#多个配置段需要放在一起，否则会冲掉之前的配置

4. 为Ingress gateway配置请求认证策略
root@k8s-master01:~/istio/istio-in-practise/Security/05-JWT-and-Keycloak# cat 03-ext-auth-ingress-gateway.yaml
apiVersion: security.istio.io/v1beta1
kind: RequestAuthentication
metadata:
  name: istio-ingressgateway
  namespace: istio-system
spec:
  selector:
    matchLabels:
      app: istio-ingressgateway		#针对ingress gateway需要进行请求认证操作
  jwtRules:
  - issuer: http://keycloak.keycloak.svc.homsom.local:8090/realms/istio									#issuer地址
    jwksUri: http://keycloak.keycloak.svc.homsom.local:8090/realms/istio/protocol/openid-connect/certs	#jwksUri地址
    #audiences: ["ingress-gateway","istio-ingress-gateway"]		#此功能是过滤audiences
    # Forward JWT to Envoy Sidecar
    #forwardOriginalToken: true									#转发token到网格中workload，实现网络内认证策略
  - issuer: http://keycloak.magedu.com:8090/realms/istio												#可以添加多个
    jwksUri: http://keycloak.magedu.com:8090/realms/istio/protocol/openid-connect/certs
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: ext-authz-oauth2-proxy
  namespace: istio-system
spec:
  selector:
    matchLabels:
      app: istio-ingressgateway		#当匹配ingress gateway后的认证策略
  action: CUSTOM					#执行自定义操作
  provider:
    # Extension provider configured when we installed Istio
    name: oauth2-proxy				#指定由哪个provider进行操作，这里是我们上面自定义的provider
  rules:
  - to:
    - operation:	
        hosts: ["*.magedu.com"]		#针对"*.magedu.com"的主机域名将实现请求认证，包括kiali.magedu.com, prometheus.magedu.com等
        notPaths: ["/auth/*"]		#但不包括"/auth/*"路径，因为此路径需要转发给oauth2-proxy -> keycloak使用的
root@k8s-master01:~/istio/istio-in-practise/Security/05-JWT-and-Keycloak# kubectl apply -f 03-ext-auth-ingress-gateway.yaml

5. 现在可以访问kiali.magedu.com进行测试是否跳转到认证页面，此时之前的tom用户是无法认证通过的，需要创建用户进行访问
--添加用户
用户名：kiali
密码：magedu.com
电子邮件: kiali@magedu.com
电子邮件验证: 必须开启	#因为oauth-proxy需要验证邮件功能(并不会验证邮件真实性，但必须开启验证)，否则会拒绝认证的。此前tom用户就是未开启此功能，所以不会登录成功

--在客户端添加mappers，客户端 -> ingress-gateway -> Mappers -> 创建协议映射器
名称：audience-ingress-gateway
映射器类型：Audience
Included Client Audience：ingress-gateway		#这个名称在认证策略限制有用
Included Custom Audience：audience-ingress-gateway
添加到ID令牌：开

--测试
root@client # curl -s -d 'username=kiali&password=magedu.com&grant_type=password&client_id=ingress-gateway' http://keycloak.keycloak.svc.homsom.local:8090/realms/i
stio/protocol/openid-connect/token
{"error":"unauthorized_client","error_description":"Client secret not provided in request"}root@client #
--原因，因为需要secret参数
root@client # curl -s -d 'username=kiali&password=magedu.com&grant_type=password&client_id=ingress-gateway&client_secret=EKCuaLa56Ig34luBkZcIOV4geEq6RoV8' http://keycloak.keycloak.svc.homsom.local:8090/realms/istio/protocol/openid-connect/token	#此时可以认证
{"access_token":"eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ2Z2tTci10MlJseFNuU3hDS2JUQkZXbzF3Szh6a2VOcFd4OTYwd2J5Y2h3In0.eyJleHAiOjE2NTE3MTk4NTYsImlhdCI6MTY1MTcxOTU1NiwianRpIjoiZjQzYmRmMzgtNzQzNS00YmI3LTgwNGYtZDA3ODMxOTA1YTA4IiwiaXNzIjoiaHR0cDovL2tleWNsb2FrLmtleWNsb2FrLnN2Yy5ob21zb20ubG9jYWw6ODA5MC9yZWFsbXMvaXN0aW8iLCJhdWQiOlsiaW5ncmVzcy1nYXRld2F5IiwiYWNjb3VudCJdLCJzdWIiOiIxOTllNmI2ZS1iMzhkLTQ4OWUtYmIwZS1kYzU1OWNjMWJhMzUiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJpbmdyZXNzLWdhdGV3YXkiLCJzZXNzaW9uX3N0YXRlIjoiYjQ0NTRkNWUtMGYyNy00YmE2LThhNGEtZWRjYmY0ODZjOTQyIiwiYWNyIjoiMSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIiwiZGVmYXVsdC1yb2xlcy1pc3RpbyJdfSwicmVzb3VyY2VfYWNjZXNzIjp7ImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSIsInNpZCI6ImI0NDU0ZDVlLTBmMjctNGJhNi04YTRhLWVkY2JmNDg2Yzk0MiIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJuYW1lIjoia2lhbGkgbWFnZWR1IiwicHJlZmVycmVkX3VzZXJuYW1lIjoia2lhbGkiLCJnaXZlbl9uYW1lIjoia2lhbGkiLCJmYW1pbHlfbmFtZSI6Im1hZ2VkdSIsImVtYWlsIjoia2lhbGlAbWFnZWR1LmNvbSJ9.U5dK8SRzNUlaQMh6938JrtElG2-59DMptU_RGfDEgpLBpKYec3Rkrf7PCQywhhQ6qUp8onl644hhDRGLzwWi4zdUnsEjhuQuTS7FfCOYIdJtby0uLpwcW5TIjWukGuDx0pqy-rriOxpUp1k9X8TzPQD5aISQQsZkHFogrXGrDttXrPWY364_yEmXHGI_S3isUDQ5w4B5qCxdhMj8GVOnFSx6pNrvZqyS49WOi6Q4BChRmQZEbQ8SHeuNbqh9uK6gW5625ocx-4sSFdatsIg73A8ogJwo6fDJ4olAP2BC09QENvhyPgeQcTTLW_fbW3pc4zLtAXaQxZFwLiBBfzBVog","expires_in":300,"refresh_expires_in":1800,"refresh_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICIwNzllMGEzMS1kN2EyLTRiZDMtODcyNy0xOWM2YzE0ODA1ZjgifQ.eyJleHAiOjE2NTE3MjEzNTYsImlhdCI6MTY1MTcxOTU1NiwianRpIjoiZWE5ZTJlZTgtNWY3NS00NmQ1LTg0ODMtOTM3Yjg1ZTIzMjAzIiwiaXNzIjoiaHR0cDovL2tleWNsb2FrLmtleWNsb2FrLnN2Yy5ob21zb20ubG9jYWw6ODA5MC9yZWFsbXMvaXN0aW8iLCJhdWQiOiJodHRwOi8va2V5Y2xvYWsua2V5Y2xvYWsuc3ZjLmhvbXNvbS5sb2NhbDo4MDkwL3JlYWxtcy9pc3RpbyIsInN1YiI6IjE5OWU2YjZlLWIzOGQtNDg5ZS1iYjBlLWRjNTU5Y2MxYmEzNSIsInR5cCI6IlJlZnJlc2giLCJhenAiOiJpbmdyZXNzLWdhdGV3YXkiLCJzZXNzaW9uX3N0YXRlIjoiYjQ0NTRkNWUtMGYyNy00YmE2LThhNGEtZWRjYmY0ODZjOTQyIiwic2NvcGUiOiJlbWFpbCBwcm9maWxlIiwic2lkIjoiYjQ0NTRkNWUtMGYyNy00YmE2LThhNGEtZWRjYmY0ODZjOTQyIn0.ewXtIe5Nnl8NAkKOurJSAYsN7aDxnL53Kn3sFc_F3r8","token_type":"Bearer","not-before-policy":0,"session_state":"b4454d5e-0f27-4ba6-8a4a-edcbf486c942","scope":"email profile"}

--此时使用kiali用户可以正常访问了

6. 配置授权策略，如果CUSTOM没有明确deny，将会进入此授权策略
root@k8s-master01:~/istio/istio-in-practise/Security/05-JWT-and-Keycloak# cat 04-ingress-gateway-authz.yaml
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: istio-ingressgateway
  namespace: istio-system
spec:
  selector:
    matchLabels:
      app: istio-ingressgateway
  action: ALLOW
  rules:
  - when:
    - key: request.auth.claims[iss]
      values:
      - "http://keycloak.keycloak.svc.cluster.local:8080/auth/realms/istio"
      - "http://keycloak.magedu.com:8080/auth/realms/istio"
    - key: request.auth.audiences
      values:
      - "ingress-gateway"
root@k8s-master01:~/istio/istio-in-practise/Security/05-JWT-and-Keycloak# cat 05-authz-gateway-kiali.yaml
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: authz-kiali-ingressgw
  namespace: istio-system
spec:
  selector:
    matchLabels:
      app: istio-ingressgateway
  action: ALLOW
  rules:
  - to:
    - operation:
        hosts: ["kiali.magedu.com"]
        paths: ["/*"]
    when:									#多个是与条件
    - key: request.auth.claims[iss]
      values:
      - "http://keycloak.keycloak.svc.homsom.local:8090/realms/istio"
      - "http://keycloak.magedu.com:8090/realms/istio"
    - key: request.auth.claims[groups]
      values:
      - "/kiali-admin"
---
root@k8s-master01:~/istio/istio-in-practise/Security/05-JWT-and-Keycloak# kubectl apply -f 05-authz-gateway-kiali.yaml
--此时kiali用户会被访问拒绝，因为此用户不在组"/kiali-admin"中
在istio领域中新建组：kiali-admin
在用户kiali中加入组："/kiali-admin"
在客户端Ingress-gateway中Mappers添加：
	- 名称：group-members
	- 映射器类型：Group Membership
	- Token申请名: groups

--测试是否通过能获取token，--然后复制到Jwt.io确认是否有组信息，--最后测试访问kiali成功访问
root@client # curl -s -d 'username=kiali&password=magedu.com&grant_type=password&client_id=ingress-gateway&client_secret=EKCuaLa56Ig34luBkZcIOV4geEq6RoV8' http://k
eycloak.keycloak.svc.homsom.local:8090/realms/istio/protocol/openid-connect/token | jq .access_token
"eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ2Z2tTci10MlJseFNuU3hDS2JUQkZXbzF3Szh6a2VOcFd4OTYwd2J5Y2h3In0.eyJleHAiOjE2NTE3MjEwODYsImlhdCI6MTY1MTcyMDc4NiwianRpIjoiY2RjYWJhYmMtNDY0MC00YzUwLTk0ZmQtMDVhNzRmYTUyZmY5IiwiaXNzIjoiaHR0cDovL2tleWNsb2FrLmtleWNsb2FrLnN2Yy5ob21zb20ubG9jYWw6ODA5MC9yZWFsbXMvaXN0aW8iLCJhdWQiOlsiaW5ncmVzcy1nYXRld2F5IiwiYWNjb3VudCJdLCJzdWIiOiIxOTllNmI2ZS1iMzhkLTQ4OWUtYmIwZS1kYzU1OWNjMWJhMzUiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJpbmdyZXNzLWdhdGV3YXkiLCJzZXNzaW9uX3N0YXRlIjoiZjg2YWE1MmItNDFkYi00NTZkLTg3ZGQtMTY2ODUxZjZhMzIyIiwiYWNyIjoiMSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIiwiZGVmYXVsdC1yb2xlcy1pc3RpbyJdfSwicmVzb3VyY2VfYWNjZXNzIjp7ImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSIsInNpZCI6ImY4NmFhNTJiLTQxZGItNDU2ZC04N2RkLTE2Njg1MWY2YTMyMiIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJuYW1lIjoia2lhbGkgbWFnZWR1IiwiZ3JvdXBzIjpbIi9raWFsaS1hZG1pbiJdLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJraWFsaSIsImdpdmVuX25hbWUiOiJraWFsaSIsImZhbWlseV9uYW1lIjoibWFnZWR1IiwiZW1haWwiOiJraWFsaUBtYWdlZHUuY29tIn0.J3yl-AjaKCDwDfBUNmQ3XS5GH2oeXyIzEtIsl-SOP8I6bYegCNXnRzBWprv7RGrXf9TY29383WxFGYFUErM62dkMiETyuIltORQ_AZjnVqVmmbwHhNUAece3UGWhp9JOjaLIXEQokELp-hug-9l2zcxhn_RA7As3Mz8cqXGS6J7dIEx7SVFsIsPZgGByQwnXnmNvahKBZO5bc6AMgM0mPvcJlZO9Vsz7j6yEC4T6EY_-mEiSYZJ7sG3NL1WFhO4YW1v6VCksuykvxX-zhPR0u5mYi16lDGNE1_IJFXAH4OPmIzniSMzI3D-LyaidxzocRXkM93LrSfDPIm0gNHsr2w"
注：访问prometheus.magedu.com, fe.magedu.com跳转有问题，后续还要进行测试






#####Istio部署模型

#本节话题
- 单网格
  - 集群模型
    - 单集群
    - 多集群
  - 网络模型
    - 单网络
    - 多网络
  - 控制平面模型
    - 单控制平面单集群
    - 单控制平面多集群（主集群和远程集群，或者均为远程集群）
    - 多控制平面
- 多网格
  - 网格联邦：每个网格使用一个独占的ID进行标识
  - 网格互信：SPIFFE可信域联邦
- 租用模型
  - Namespace tenancy
  - Cluster tenancy
  - Mesh Tenancy

#集群模型
- 单集群单网格
  - 通常集群运行于单个网络中
  - 最简单的模型
  - 缺点：缺少故障隔离和故障转移能力
- 代表着多个维度下的同一个模型
  - 单集群
  - 单网络
  - 单控制平面
  - 单网格
- 多集群单网格：即横跨多个集群的单一网格，运行如下高级功能
  - 故障隔离和故障转移：cluster-1故障时，转移至cluster-2
  - 位置感知路由和故障转移
  - 支持多控制平面模型，实现更高级别的可用性
  - 支持团队或项目间的隔离
  - 缺点
    - 复杂性增加
    - 跨集群的DNS名称解析需要特殊处理
  - DNS配置方法
    - 手动配置
    - 自动化工具
      - Istio CoreDNS插件
      - DNS Sidecar代理

#网络模型
- 单一网络：服务网格在单个完全连接的网络上运行，所有工作负载实例无 需Istio网关即可直接互通；
- 多网络：跨越多个网络部署运行单个网格
  - 可实现如下功能增强 
    - 服务端点使用相同的IP地址 
    - 容错 
    - 扩展可用的网络地址空间 
  - 典型特点： 
    - 不同网络中的工作负载实例只能通过一个或多个Istio网关互通
    - 各网络中的所有服务都需要通过本地的Istio Gateway向外暴露
    - Istio使用“分区的服务发现机制”为客户端提供服务端点的不同视图

#控制平面模型
- 单控制平面：在单个集群上运行单个控制平面
  - 在集群本地拥有控制平面的集群，也称为主集群（primary cluster）
- 跨多个集群部署的网格，还可以共享控制平面
  - 控制平面可驻留于单个或多个主集群中，但每个主集群会于本地的Kubernetes API Server上存储网格资源配置
  - 在集群本地没有控制平面的集群，也称为远程集群（remote cluster）
  - 主集群中的控制平面必须拥有稳定的可达IP，跨网络时，可通过Istio Gateway将其公开
- 外部控制平面
  - 控制平面单独运行，与数据平面完全分离
  - 无主集群，所有集群都是远程集群
  - 云端托管的网格即为这种模型的典型表现

#控制平面高可用
- 跨地域（Region）、区域（Zone）或集群（Cluster）部署多个控制平面
- 常见部署模型
  - 每个地域（region）一个集群
  - 每个地域多个集群（即多集群共享一个控制平面）
  - 每个区域（zone）一个集群
  - 每个区域多个集群
  - 每个集群使用一个控制面
- 优点
  - 高可用
  - 配置隔离
  - 细粒度的可控发布
  - 配置服务的选择性可见

#多控制平面场景中的端点发现
- 针对一个服务，每个控制平面都会在其所在的一个或多个集群中发现相关的端点
- 多控制平面场景中，也支持跨集群的端点发现
  - 需要管理员生成一个remote secret，并将其部署到网格中的每个primary cluster
  - remote secret用于提供访问API Server的凭据
  - 启用跨集群的端点发现机制后，Istio将会把服务的流量分发至所有端点，这些端点分布于不同Region时，可能会对性能产生负面影响，因而应该使用Locality Load Balancing
    - 对应于Envoy中的“Locality Weighted LB”
    - 与“Zone Aware Routing”互斥

#网格模型总结
- 多网格：网格联邦
- 可提供单网格所不具有功能
  - 更加明晰的组织边界
  - Service Name及Namespace的重用
  - 更彻底的隔离机制
- 特殊要求
  - 需要为每个网格提供专用ID，以消弭各Service Name间的名称冲突
  - 网格间需要互相传递可信域

#网格间的可信域传递
- 若某网格中的服务依赖于另一网格中的服务，就需要在两个网格之间通过交换彼此的trust bundle以联合身份和信任关系
- 可用方案是使用SPIFFE协议进行手动或自动交换trust bundle
- 将trust bundle导入网格后，即可为这些身份配置本地策略

#网格诊断工具
- istioctl命令可用于调试和诊断服务网格，它有着可用的众多子命令，仍处于实验性阶段的命令均隶属于experimental子命令；
- 查看网格中的各Envoy从Pilot同步配置的状态，proxy-status命令可简写为ps；
  - istioctl proxy-status [<pod-name[.namespace]>] [flags]
    - SYNC：Envoy已经确认Pilot推送的配置数据；
    - NOT SENT：Pilot未向Envoy发送任何数据，这通常是因为Pilot无任何可用于发送的数据；
    - STALE：Pilot已经发送配置但尚未收到Envoy的确认，这一般是网络相关的原因所致；
- 获取代理配置，proxy-config命令可简写为pc；
  - istioctl proxy-config [command]
    - 获取bootstrap配置：bootstrap <pod-name[.namespace]> [flags]
    - 获取cluster配置信息：cluster <pod-name[.namespace]> [flags]
    - 获取listener配置信息：listener <pod-name[.namespace]> [flags]
    - 获取路由配置信息：route <pod-name[.namespace]> [flags]
    - 获取endpoint信息：endpoint <pod-name[.namespace]> [flags]
    - 获取secret信息：secret <pod-name[.namespace]> [flags]
    - 获取指定envoy实例的日志级别：log <pod-name[.namespace]> [flags]
- istioctl experimental describe命令可用于获取pod上有关网格的配置或service的路由配置信息；
  - 验证Pod的相关配置：istioctl experimental describe pod <pod> [flags]
  - 获取service的路由：istioctl experimental describe service <svc> [flags]

#四种集群类型
- 单网格单集群
- 单网格多集群（多集群需要eastwest-gatewy实现pod间的流量代理）
- 多网格单集群
- 多网格多集群（多集群需要eastwest-gatewy实现pod间的流量代理）



###部署示例:多网格多集群
https://istio.io/latest/docs/tasks/security/cert-management/plugin-ca-cert/
https://istio.io/latest/docs/setup/install/multicluster/multi-primary_multi-network/

#网格1：
cluster: k8s01
master01 172.168.2.21
node01 172.168.2.24
node02 172.168.2.25
ingress-gateway 172.168.2.27
eastwest-gateway 172.168.2.28
#k8s01:
root@k8s-master01:~# kubectl get nodes
NAME           STATUS                     ROLES    AGE     VERSION
172.168.2.21   Ready,SchedulingDisabled   master   6d21h   v1.23.1
172.168.2.24   Ready                      node     6d21h   v1.23.1
172.168.2.25   Ready                      node     6d21h   v1.23.1


#网格2：
cluster: k8s02
master01 172.168.2.31
node01 172.168.2.34
node02 172.168.2.35
ingress-gateway 172.168.2.37
eastwest-gateway 172.168.2.38
#k8s02:
root@k8s-master01:~# kubectl get nodes
NAME           STATUS                     ROLES    AGE     VERSION
172.168.2.31   Ready,SchedulingDisabled   master   7m10s   v1.23.1
172.168.2.34   Ready                      node     6m2s    v1.23.1
172.168.2.35   Ready                      node     6m2s    v1.23.1




#下载istio
--k8s01
root@k8s-master01:~# curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.13.3 TARGET_ARCH=x86_64 sh -
root@k8s-master01:~# cd istio-1.13.3/
root@k8s-master01:~/istio-1.13.3# ls
bin  LICENSE  manifests  manifest.yaml  README.md  samples  tools
root@k8s-master01:~/istio-1.13.3# export PATH=$PWD/bin:$PATH
--k8s02
root@k8s-master01:~# curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.13.3 TARGET_ARCH=x86_64 sh -
root@k8s-master01:~# cd istio-1.13.3/
root@k8s-master01:~/istio-1.13.3# ls
bin  LICENSE  manifests  manifest.yaml  README.md  samples  tools
root@k8s-master01:~/istio-1.13.3# export PATH=$PWD/bin:$PATH

#配置信任
--在 Istio 安装包的顶级目录中，创建一个保存证书和密钥的目录：
root@k8s-master01:~/istio-1.13.3# mkdir -p certs
root@k8s-master01:~/istio-1.13.3# pushd certs
~/istio-1.13.3/certs ~/istio-1.13.3

--生成根证书和密钥：
root@k8s-master01:~/istio-1.13.3/certs# make -f ../tools/certs/Makefile.selfsigned.mk root-ca
root@k8s-master01:~/istio-1.13.3/certs# ls
root-ca.conf  root-cert.csr  root-cert.pem  root-key.pem

----对于每个集群，为 Istio CA 生成一个中间证书和密钥。以下是两个集群示例：cluster1，cluster2
root@k8s-master01:~/istio-1.13.3/certs# make -f ../tools/certs/Makefile.selfsigned.mk cluster1-cacerts
root@k8s-master01:~/istio-1.13.3/certs# ls cluster1/
ca-cert.pem  ca-key.pem  cert-chain.pem  root-cert.pem

root@k8s-master01:~/istio-1.13.3/certs# make -f ../tools/certs/Makefile.selfsigned.mk cluster2-cacerts
root@k8s-master01:~/istio-1.13.3/certs# ls cluster2
ca-cert.pem  ca-key.pem  cert-chain.pem  root-cert.pem

----在每个群集中，创建一个包含所有输入文件的secret
--k8s01
root@k8s-master01:~/istio-1.13.3/certs# kubectl create ns istio-system && kubectl label namespace istio-system topology.istio.io/network=network1

kubectl create secret generic cacerts -n istio-system \
      --from-file=cluster1/ca-cert.pem \
      --from-file=cluster1/ca-key.pem \
      --from-file=cluster1/root-cert.pem \
      --from-file=cluster1/cert-chain.pem
root@k8s-master01:~/istio-1.13.3/certs# kubectl get secret cacerts -n istio-system
NAME      TYPE     DATA   AGE
cacerts   Opaque   4      14s
root@k8s-master01:~/istio-1.13.3/certs# scp -r ../certs root@172.168.2.31:~/istio-1.13.3/	#复制整个certs目录到k8s02控制节点

--k8s02
root@c2-k8s-master01:~/istio-1.13.3# cd certs/
root@c2-k8s-master01:~/istio-1.13.3/certs# ls
cluster1  cluster2  root-ca.conf  root-cert.csr  root-cert.pem  root-cert.srl  root-key.pem
root@k8s-master01:~/istio-1.13.3/certs# kubectl create ns istio-system && kubectl label namespace istio-system topology.istio.io/network=network2

kubectl create secret generic cacerts -n istio-system \
      --from-file=cluster2/ca-cert.pem \
      --from-file=cluster2/ca-key.pem \
      --from-file=cluster2/root-cert.pem \
      --from-file=cluster2/cert-chain.pem
root@k8s-master01:~/istio-1.13.3/certs# kubectl get secret cacerts -n istio-system
NAME      TYPE     DATA   AGE
cacerts   Opaque   4      9s



####安装多主集群在不同的网格之上
----k8s01
--配置为主节点cluster1
root@k8s-master01:~/istio-1.13.3# mkdir cluster1-config
cat <<EOF > cluster1-config/cluster1.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  values:
    global:
      meshID: mesh1
      multiCluster:
        clusterName: cluster1
      network: network1
EOF
root@k8s-master01:~/istio-1.13.3# cat cluster1-config/cluster1.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  values:
    global:
      meshID: mesh1				#网格ID
      multiCluster:
        clusterName: cluster1	#集群名称
      network: network1			#网络名称
root@k8s-master01:~/istio-1.13.3# istioctl apply -f cluster1-config/cluster1.yaml	#安装istio集群
This will install the Istio 1.13.3 default profile with ["Istio core" "Istiod" "Ingress gateways"] components into the cluster. Proceed? (y/N) y
✔ Istio core installed
✔ Istiod installed
✔ Ingress gateways installed
✔ Installation complete                                                                                                                                            root@k8s-master01:~# kubectl get pods -n istio-system
NAME                                   READY   STATUS    RESTARTS   AGE
istio-ingressgateway-fc6f6b68b-kg5w9   1/1     Running   0          51s
istiod-7765576944-7jr4s                1/1     Running   0          22m

root@k8s-master01:~/istio-in-practise/Muliti-Cluster-demo/cluster1# kubectl get svc -n istio-system
NAME                    TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                                                           AGE
istio-eastwestgateway   LoadBalancer   10.68.77.231   <pending>     15021:46485/TCP,15443:42031/TCP,15012:38508/TCP,15017:50438/TCP   12m
istio-ingressgateway    LoadBalancer   10.68.96.85    <pending>     15021:37104/TCP,80:56591/TCP,443:48749/TCP                        32m
istiod                  ClusterIP      10.68.18.144   <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP                             37m

root@k8s-master01:~/istio-in-practise/Muliti-Cluster-demo/cluster1# kubectl edit svc istio-ingressgateway -n istio-system
spec:
  externalIPs:
  - 172.168.2.27
root@k8s-master01:~/istio-in-practise/Muliti-Cluster-demo/cluster1# kubectl edit svc istio-eastwestgateway -n istio-system
spec:
  externalIPs:
  - 172.168.2.28
root@k8s-master01:~/istio-in-practise/Muliti-Cluster-demo/cluster1# kubectl get svc -n istio-system
NAME                    TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)                                                           AGE
istio-eastwestgateway   LoadBalancer   10.68.77.231   172.168.2.28   15021:46485/TCP,15443:42031/TCP,15012:38508/TCP,15017:50438/TCP   15m
istio-ingressgateway    LoadBalancer   10.68.96.85    172.168.2.27   15021:37104/TCP,80:56591/TCP,443:48749/TCP                        35m
istiod                  ClusterIP      10.68.18.144   <none>         15010/TCP,15012/TCP,443/TCP,15014/TCP                             39m


--在cluster1安装东西向网关
samples/multicluster/gen-eastwest-gateway.sh \
    --mesh mesh1 --cluster cluster1 --network network1 | \
    istioctl install -y -f -
root@k8s-master01:~/istio-1.13.3# samples/multicluster/gen-eastwest-gateway.sh \
>     --mesh mesh1 --cluster cluster1 --network network1 | \
>     istioctl install -y -f -
✔ Ingress gateways installed
✔ Installation complete   

root@k8s-master01:~# kubectl get pods -n istio-system
NAME                                     READY   STATUS    RESTARTS   AGE
istio-eastwestgateway-5cf6c5fbbb-6mm2p   1/1     Running   0          82s
istio-ingressgateway-fc6f6b68b-kg5w9     1/1     Running   0          3m42s
istiod-7765576944-7jr4s                  1/1     Running   0          25m

--在cluster1暴露服务
注：由于集群位于不同的网络上，因此我们需要在两个集群中公开东西向网关上的所有服务 （*.local）。虽然此网关在 Internet 上是公共的，但其后面的服务只能由具有受信任的 mTLS 证书和工作负载 ID 的服务访问，就像它们位于同一网络上一样。
kubectl apply -n istio-system -f \
    samples/multicluster/expose-services.yaml
root@k8s-master01:~/istio-1.13.3# kubectl apply -n istio-system -f \
>     samples/multicluster/expose-services.yaml
gateway.networking.istio.io/cross-network-gateway created


----k8s02
--配置为主节点cluster2
root@k8s-master01:~/istio-1.13.3# mkdir cluster2-config
cat <<EOF > cluster2-config/cluster2.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  values:
    global:
      meshID: mesh2
      multiCluster:
        clusterName: cluster2
      network: network2
EOF
root@k8s-master01:~/istio-1.13.3# cat cluster2-config/cluster2.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  values:
    global:
      meshID: mesh2				#网格ID，唯一
      multiCluster:
        clusterName: cluster2	#集群名称，唯一
      network: network2			#网络名称，唯一
root@k8s-master01:~/istio-1.13.3# istioctl apply -f cluster2-config/cluster2.yaml
This will install the Istio 1.13.3 default profile with ["Istio core" "Istiod" "Ingress gateways"] components into the cluster. Proceed? (y/N) y
✔ Istio core installed
✔ Istiod installed
✔ Ingress gateways installed
✔ Installation complete                                                                                                                                            root@k8s-master01:~# kubectl get pods -n istio-system
NAME                                    READY   STATUS    RESTARTS   AGE
istio-ingressgateway-7b4b88bf9f-cv9g4   1/1     Running   0          15m
istiod-69db545dd5-4q626                 1/1     Running   0          23m

root@k8s-master01:~/istio-in-practise/Muliti-Cluster-demo/cluster2# kubectl edit svc istio-ingressgateway -n istio-system
spec:
  externalIPs:
  - 172.168.2.37
root@k8s-master01:~/istio-in-practise/Muliti-Cluster-demo/cluster2# kubectl edit svc istio-eastwestgateway -n istio-system
spec:
  externalIPs:
  - 172.168.2.38
root@k8s-master01:~/istio-in-practise/Muliti-Cluster-demo/cluster2# kubectl get svc -n istio-system
NAME                    TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                                                           AGE
istio-eastwestgateway   LoadBalancer   10.68.26.202    172.168.2.38   15021:51351/TCP,15443:40605/TCP,15012:61976/TCP,15017:32740/TCP   16m
istio-ingressgateway    LoadBalancer   10.68.251.189   172.168.2.37   15021:30041/TCP,80:31594/TCP,443:54709/TCP                        33m
istiod                  ClusterIP      10.68.38.232    <none>         15010/TCP,15012/TCP,443/TCP,15014/TCP                             41m


--在cluster2安装东西向网关
samples/multicluster/gen-eastwest-gateway.sh \
    --mesh mesh2 --cluster cluster2 --network network2 | \
    istioctl install -y -f -
root@k8s-master01:~/istio-1.13.3# samples/multicluster/gen-eastwest-gateway.sh \
>     --mesh mesh2 --cluster cluster2 --network network2 | \
>     istioctl install -y -f -
✔ Ingress gateways installed
✔ Installation complete   

root@k8s-master01:~# kubectl get pods -n istio-system
NAME                                     READY   STATUS    RESTARTS   AGE
istio-eastwestgateway-7cd9fbd95d-69lt6   1/1     Running   0          82s
istio-ingressgateway-7b4b88bf9f-cv9g4    1/1     Running   0          18m
istiod-69db545dd5-4q626                  1/1     Running   0          26m


--在cluster2暴露服务
注：由于集群位于不同的网络上，因此我们需要在两个集群中公开东西向网关上的所有服务 （*.local）。虽然此网关在 Internet 上是公共的，但其后面的服务只能由具有受信任的 mTLS 证书和工作负载 ID 的服务访问，就像它们位于同一网络上一样。
kubectl apply -n istio-system -f \
    samples/multicluster/expose-services.yaml
root@k8s-master01:~/istio-1.13.3# kubectl apply -n istio-system -f \
>     samples/multicluster/expose-services.yaml
gateway.networking.istio.io/cross-network-gateway created


##启用终端节点发现
----配置ssh互信
root@k8s-master01:~/istio-in-practise/Muliti-Cluster-demo/cluster1# ssh-keygen -t rsa
root@k8s-master01:~/istio-in-practise/Muliti-Cluster-demo/cluster1# ssh-copy-id 172.168.2.31
root@k8s-master01:~/istio-in-practise/Muliti-Cluster-demo/cluster2# ssh-keygen -t rsa
root@k8s-master01:~/istio-in-practise/Muliti-Cluster-demo/cluster2# ssh-copy-id 172.168.2.21

----安装一个远程密钥，提供对API服务器的访问(cluster1 -> cluster2)
--cluster1上创建
root@k8s-master01:~/istio-1.13.3/cluster1-config# ssh 172.168.2.31 '/root/istio-1.13.3/bin/istioctl x create-remote-secret --name=cluster2' > cluster2-secret.yaml

root@k8s-master01:~/istio-1.13.3/cluster1-config# sed -i 's#https://127.0.0.1:6443#https://172.168.2.31:6443#' cluster2-secret.yaml
root@k8s-master01:~/istio-1.13.3/cluster1-config# grep 'server:' cluster2-secret.yaml
        server: https://172.168.2.31:6443
root@k8s-master01:~/istio-1.13.3/cluster1-config# kubectl apply -f cluster2-secret.yaml		#应用secret 
secret/istio-remote-secret-cluster2 created
root@k8s-master01:~/istio-1.13.3/cluster1-config# kubectl get secret -n istio-system | grep remote
istio-remote-secret-cluster2                        Opaque                                1      112s

----安装一个远程密钥，提供对API服务器的访问(cluster2 -> cluster1)
--cluster2上创建
root@k8s-master01:~/istio-1.13.3/cluster2-config# ssh 172.168.2.21 '/root/istio-1.13.3/bin/istioctl x create-remote-secret --name=cluster1' > cluster1-secret.yaml

root@k8s-master01:~/istio-1.13.3/cluster2-config# sed -i 's#https://127.0.0.1:6443#https://172.168.2.21:6443#' cluster1-secret.yaml
root@k8s-master01:~/istio-1.13.3/cluster2-config# grep 'server:' cluster1-secret.yaml
        server: https://172.168.2.21:6443
root@k8s-master01:~/istio-1.13.3/cluster2-config# kubectl apply -f cluster1-secret.yaml		#应用secret
secret/istio-remote-secret-cluster2 created
root@k8s-master01:~/istio-1.13.3/cluster2-config# kubectl get secret -n istio-system | grep remote
istio-remote-secret-cluster1                        Opaque                                1      5s














#测试
----为default名称空间配置自动注入sidecar
--cluster1:
root@k8s-master01:~/istio-in-practise/Muliti-Cluster-demo/cluster1# kubectl label namespace default istio-injection=enabled
--cluster2:
root@k8s-master01:~/istio-in-practise/Muliti-Cluster-demo/cluster2# kubectl label namespace default istio-injection=enabled


----cluster1部署服务v1.0:
root@k8s-master01:~/istio-in-practise/Muliti-Cluster-demo/cluster1# ls
01-deploy-demoapp-v10.yaml  02-service-demoapp.yaml  03-destinationrule-demoapp.yaml  04-virutalservice-demoapp.yaml
root@k8s-master01:~/istio-in-practise/Muliti-Cluster-demo/cluster1# kubectl apply -f .
deployment.apps/demoappv10 created
service/demoapp created
destinationrule.networking.istio.io/demoapp created
virtualservice.networking.istio.io/demoapp created

root@k8s-master01:~/istio-in-practise/Muliti-Cluster-demo/cluster1# kubectl get pods
NAME                         READY   STATUS    RESTARTS   AGE
demoappv10-b5d9576cc-hs99x   2/2     Running   0          56s
root@k8s-master01:~/istio-in-practise/Muliti-Cluster-demo/cluster1# kubectl get svc
NAME         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
demoapp      ClusterIP   10.68.229.2   <none>        8080/TCP   2m10s
kubernetes   ClusterIP   10.68.0.1     <none>        443/TCP    7d4h
root@k8s-master01:~/istio-in-practise/Muliti-Cluster-demo/cluster1# kubectl get vs
NAME      GATEWAYS   HOSTS         AGE
demoapp              ["demoapp"]   2m13s


----cluster2部署服务v1.1:
root@k8s-master01:~/istio-in-practise/Muliti-Cluster-demo/cluster2# ls
01-deploy-demoapp-v11.yaml  02-service-demoapp.yaml  03-destinationrule-demoapp.yaml  04-virutalservice-demoapp.yaml
root@k8s-master01:~/istio-in-practise/Muliti-Cluster-demo/cluster2# kubectl apply -f .
deployment.apps/demoappv11 created
service/demoapp created
destinationrule.networking.istio.io/demoapp created
virtualservice.networking.istio.io/demoapp created

root@k8s-master01:~/istio-in-practise/Muliti-Cluster-demo/cluster2# kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
demoappv11-77755cdc65-9nh5n   2/2     Running   0          95s
root@k8s-master01:~/istio-in-practise/Muliti-Cluster-demo/cluster2# kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
demoapp      ClusterIP   10.68.104.176   <none>        8080/TCP   12s
kubernetes   ClusterIP   10.68.0.1       <none>        443/TCP    54m
root@k8s-master01:~/istio-in-practise/Muliti-Cluster-demo/cluster2# kubectl get vs
NAME      GATEWAYS   HOSTS         AGE
demoapp              ["demoapp"]   17s

----在cluster1和cluster2上运行测试容器，请求demoapp:8080，看是否可以路由到v1.0和v1.1应用
--cluster1:
root@k8s-master01:~# kubectl run client --image=ikubernetes/admin-box:v1.2 --rm --restart=Never -it --command -- /bin/sh
root@client # while true;do curl demoapp:8080;sleep 0.$RANDOM;done
iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-77755cdc65-9nh5n, ServerIP: 172.20.85.198!	#能访问到cluster2上的pod
iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-77755cdc65-9nh5n, ServerIP: 172.20.85.198!
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-b5d9576cc-hs99x, ServerIP: 172.20.85.207!
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-b5d9576cc-hs99x, ServerIP: 172.20.85.207!
iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-77755cdc65-9nh5n, ServerIP: 172.20.85.198!
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-b5d9576cc-hs99x, ServerIP: 172.20.85.207!
iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-77755cdc65-9nh5n, ServerIP: 172.20.85.198!

--cluster2:
root@k8s-master01:~# kubectl run client --image=ikubernetes/admin-box:v1.2 --rm --restart=Never -it --command -- /bin/sh
root@client # while true;do curl demoapp:8080;sleep 0.$RANDOM;done
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-b5d9576cc-hs99x, ServerIP: 172.20.85.207!	#能访问到cluster1上的pod
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-b5d9576cc-hs99x, ServerIP: 172.20.85.207!
iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-77755cdc65-9nh5n, ServerIP: 172.20.85.198!
iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-77755cdc65-9nh5n, ServerIP: 172.20.85.198!
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-b5d9576cc-hs99x, ServerIP: 172.20.85.207!
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-b5d9576cc-hs99x, ServerIP: 172.20.85.207!

注：能访问到另一个地址的集群说明没有问题，可以在两个集群内部问题同一个服务，实现服务的冗余


#测试南北向流量
root@k8s-master01:/tmp/demoapp# cat demoapp-gateway.yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: demoapp-gateway
  namespace: istio-system
spec:
  selector:
    app: istio-ingressgateway
  servers:
  - port:
      number: 80
      name: http-demoapp
      protocol: HTTP
    hosts:
    - "demoapp.magedu.com"
---
root@k8s-master01:/tmp/demoapp# cat demoapp-virtualservice.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: demoapp-virtualservice
spec:
  hosts:
  - "demoapp.magedu.com"
  gateways:
  - istio-system/demoapp-gateway
  http:
  - name: default
    route:
    - destination:
        host: demoapp	#目标地址为demoapp.default.svc.cluster.local
        port:
          number: 8080
---
root@k8s-master01:/tmp/demoapp# kubectl apply -f demoapp-gateway.yaml -f demoapp-virtualservice.yaml
gateway.networking.istio.io/demoapp-gateway created
virtualservice.networking.istio.io/demoapp-virtualservice created

--测试南北向流量
$  while true;do curl -s demoapp.magedu.com;sleep 0.$RANDOM;done
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-b5d9576cc-hs99x, ServerIP: 172.20.85.207!
iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-77755cdc65-9nh5n, ServerIP: 172.20.85.198!
iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-77755cdc65-9nh5n, ServerIP: 172.20.85.198!
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-b5d9576cc-hs99x, ServerIP: 172.20.85.207!
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-b5d9576cc-hs99x, ServerIP: 172.20.85.207!
iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-77755cdc65-9nh5n, ServerIP: 172.20.85.198!
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-b5d9576cc-hs99x, ServerIP: 172.20.85.207!
iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-77755cdc65-9nh5n, ServerIP: 172.20.85.198!
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.6, ServerName: demoappv10-b5d9576cc-hs99x, ServerIP: 172.20.85.207!
iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-77755cdc65-9nh5n, ServerIP: 172.20.85.198!
iKubernetes demoapp v1.1 !! ClientIP: 127.0.0.6, ServerName: demoappv11-77755cdc65-9nh5n, ServerIP: 172.20.85.198!


####按配置部署istio网格
root@k8s-master01:~# istioctl profile dump default > istio-default.yaml
root@k8s-master01:~# cat istio-default.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  components:
    base:
      enabled: true
    cni:
      enabled: false
    egressGateways:
    - enabled: false
      name: istio-egressgateway
    ingressGateways:
    - enabled: true					#是否开启ingressGateways
      name: istio-ingressgateway
	  k8s:
        replicaCount: 2				#insgress副本
    istiodRemote:
      enabled: false
    pilot:
      enabled: true
  hub: docker.io/istio				#集群的根地址
  meshConfig:
    defaultConfig:
      proxyMetadata: {}
    enablePrometheusMerge: true
  profile: default					#istio profile名称
  tag: 1.13.3						#istio版本
  values:
    base:
      enableCRDTemplates: false
      validationURL: ""
    defaultRevision: ""
    gateways:
      istio-egressgateway:
        autoscaleEnabled: true
        env: {}
        name: istio-egressgateway
        secretVolumes:
        - mountPath: /etc/istio/egressgateway-certs
          name: egressgateway-certs
          secretName: istio-egressgateway-certs
        - mountPath: /etc/istio/egressgateway-ca-certs
          name: egressgateway-ca-certs
          secretName: istio-egressgateway-ca-certs
        type: ClusterIP
      istio-ingressgateway:
        autoscaleEnabled: true
        env: {}
        name: istio-ingressgateway
        secretVolumes:
        - mountPath: /etc/istio/ingressgateway-certs
          name: ingressgateway-certs
          secretName: istio-ingressgateway-certs
        - mountPath: /etc/istio/ingressgateway-ca-certs
          name: ingressgateway-ca-certs
          secretName: istio-ingressgateway-ca-certs
        type: LoadBalancer
    global:
      configValidation: true
      defaultNodeSelector: {}
      defaultPodDisruptionBudget:
        enabled: true
      defaultResources:
        requests:
          cpu: 10m
      imagePullPolicy: ""
      imagePullSecrets: []
      istioNamespace: istio-system			#部署在哪个名称空间
      istiod:
        enableAnalysis: false
      jwtPolicy: third-party-jwt
      logAsJson: false
      logging:
        level: default:info
      meshNetworks: {}
      mountMtlsCerts: false
      multiCluster:
        clusterName: ""
        enabled: false
      network: ""
      omitSidecarInjectorConfigMap: false
      oneNamespace: false
      operatorManageWebhooks: false
      pilotCertProvider: istiod
      priorityClassName: ""
      proxy:
        autoInject: enabled
        clusterDomain: cluster.local		#istio-proxy容器中显示的集群后缀，如果k8s集群是test.local，这里是cluster.local，则网格以此为准
        componentLogLevel: misc:error
        enableCoreDump: false
        excludeIPRanges: ""
        excludeInboundPorts: ""
        excludeOutboundPorts: ""
        image: proxyv2						#istio-proxy镜像名称，可以下载下来使用内部的镜像仓库
        includeIPRanges: '*'
        logLevel: warning
        privileged: false
        readinessFailureThreshold: 30
        readinessInitialDelaySeconds: 1
        readinessPeriodSeconds: 2
        resources:
          limits:
            cpu: 2000m
            memory: 1024Mi
          requests:
            cpu: 100m
            memory: 128Mi
        statusPort: 15020
        tracer: zipkin
      proxy_init:
        image: proxyv2						#istio-proxy镜像名称，可以下载下来使用内部的镜像仓库
        resources:
          limits:
            cpu: 2000m
            memory: 1024Mi
          requests:
            cpu: 10m
            memory: 10Mi
      sds:
        token:
          aud: istio-ca
      sts:
        servicePort: 0
      tracer:
        datadog: {}
        lightstep: {}
        stackdriver: {}
        zipkin: {}
      useMCP: false
    istiodRemote:
      injectionURL: ""
    pilot:
      autoscaleEnabled: true
      autoscaleMax: 5
      autoscaleMin: 1
      configMap: true
      cpu:
        targetAverageUtilization: 80
      enableProtocolSniffingForInbound: true
      enableProtocolSniffingForOutbound: true
      env: {}
      image: pilot							#istiod镜像名称，可以下载下来使用内部的镜像仓库
      keepaliveMaxServerConnectionAge: 30m
      nodeSelector: {}
      podLabels: {}
      replicaCount: 2						#多少个istiod副本
      traceSampling: 1
    telemetry:
      enabled: true
      v2:
        enabled: true
        metadataExchange:
          wasmEnabled: false
        prometheus:
          enabled: true
          wasmEnabled: false
        stackdriver:
          configOverride: {}
          enabled: false
          logging: false
          monitoring: false
          topology: false




</pre>