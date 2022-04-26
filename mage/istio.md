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
root@k8s-master01:~# istioctl proxy-config clusters $InGW.istio-system		#查看ingress gateway中的clster
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
root@k8s-master01:~# istioctl proxy-config routes $InGW.istio-system	#有VIRTUAL SERVICE是生动生成，无VIRTUAL SERVICE是自动生成
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





















</pre>