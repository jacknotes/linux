# Kubernetes FAQ



## 问题1：节点无法调度

**问题**：

K8s节点pod无法调度，kubectl describe pods POD_NAME 显示以下报错：

0/6 nodes are available: 3 Insufficient cpu, 3 node(s) were unschedulable. 



**原因**：因为K8s节点上CPU resource allocated（CPU已分配的资源 ）达到99%左右了，无法为新的pod分配cpu资源，所以无法调度成功，可通过kubectl describe nodes 192.168.13.36 | grep -A 10 Allocated 查看使用情况



**解决**：调小所有服务的request resource值

```shell
[root@prometheus ~]# for i in 36 37 38;do kubectl describe nodes 192.168.13.$i | grep -A 10 Allocated;done
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests      Limits
  --------           --------      ------
  cpu                9906m (30%)   97 (303%)
  memory             7770Mi (24%)  39042Mi (122%)
  ephemeral-storage  0 (0%)        0 (0%)
  hugepages-1Gi      0 (0%)        0 (0%)
  hugepages-2Mi      0 (0%)        0 (0%)
Events:
  Type     Reason         Age                       From     Message
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests      Limits
  --------           --------      ------
  cpu                10506m (32%)  99 (309%)
  memory             7682Mi (16%)  40738Mi (84%)
  ephemeral-storage  0 (0%)        0 (0%)
  hugepages-1Gi      0 (0%)        0 (0%)
  hugepages-2Mi      0 (0%)        0 (0%)
Events:              <none>
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests      Limits
  --------           --------      ------
  cpu                11560m (36%)  41 (128%)
  memory             9016Mi (22%)  32000Mi (80%)
  ephemeral-storage  0 (0%)        0 (0%)
  hugepages-1Gi      0 (0%)        0 (0%)
  hugepages-2Mi      0 (0%)        0 (0%)
Events:              <none>
```



## 问题2： HPA限制问题

**问题**：当在一个微服务项目中添加HPA控制器时，配置了内存/CPU使用率，例如配置内存/CPU使用率为80%时，总是不生效，Pod一直在创建/删除中



**原因**：这个是正常现象，因为以你的Request Resource为基准，如果Request Resource配置内存为100Mi、CPU为100m，则内存达到100Mi*0.8=80Mi或者CPU达到100m*0.8=80m则会创建pod，而java服务一跑起来就会占用600Mi左右内存，所以会一直增加，而删除是因为随着内存使用的减少而删除



**解决**: 

* 调整HPA的使用率值，例如将80调整为800，则当Request Resource内存为100Mi、CPU为100m时，则需要内存达到800Mi、CPU达到800m才进行pod扩展
* 调大Request Resource的内存和CPU值，例如Request Resource内存为1000Mi、CPU为2000m时，当HPA内存/CPU使用率值为80时，则内存达到800Mi、CPU达到1600m时才进行pod扩展
* 建议将Request Resource配置小点，调大HPA的使用率值，因为Request Resource配置太大，集群的资源很快被耗尽，会致使pod无法被成功调度(因为request resource不足)
* 如下为HPA状态

```
[root@prometheus k8s-deploy]# kubectl describe hpa pro-java-flightrefund-order-service-hs-com-rollout -n pro-java
Warning: autoscaling/v2beta2 HorizontalPodAutoscaler is deprecated in v1.23+, unavailable in v1.26+; use autoscaling/v2 HorizontalPodAutoscaler
Name:                                                     pro-java-flightrefund-order-service-hs-com-rollout
Namespace:                                                pro-java
Labels:                                                   app.kubernetes.io/instance=pro-java-flightrefund-order-service-hs-com
Annotations:                                              <none>
CreationTimestamp:                                        Mon, 10 Apr 2023 17:34:05 +0800
Reference:                                                Rollout/pro-java-flightrefund-order-service-hs-com-rollout
Metrics:                                                  ( current / target )
  resource memory on pods  (as a percentage of request):  595% (624543744) / 800%
Min replicas:                                             2
Max replicas:                                             4
Rollout pods:                                             2 current / 2 desired
Conditions:
  Type            Status  Reason              Message
  ----            ------  ------              -------
  AbleToScale     True    ReadyForNewScale    recommended size matches current size
  ScalingActive   True    ValidMetricFound    the HPA was able to successfully calculate a replica count from memory resource utilization (percentage of request)
  ScalingLimited  False   DesiredWithinRange  the desired count is within the acceptable range
Events:
  Type    Reason             Age                 From                       Message
  ----    ------             ----                ----                       -------
  Normal  SuccessfulRescale  55m (x19 over 59m)  horizontal-pod-autoscaler  New size: 4; reason:

```

* 如下为hpa配置清单，内存和CPU指标只能生效一个

```bash
[root@prometheus k8s-deploy]# cat java-h5apiv2-api-hs-com/hpa.yaml 
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: pro-java-h5apiv2-api-hs-com-rollout
spec:
  maxReplicas: 4
  minReplicas: 2
  scaleTargetRef:
    apiVersion: argoproj.io/v1alpha1
    kind: Rollout
    name: pro-java-h5apiv2-api-hs-com-rollout
  metrics:
  - type: Resource
    resource:
      #name: memory
      #target: 
      #  type: Utilization
      #  averageUtilization: 1000
      name: cpu
      target: 
        type: Utilization
        averageUtilization: 1000
```







## 问题3：istio VS重名

**背景：**生产2号环境，通过istio的 ingress-gateway来代理service，达到访问k8s的服务，例如：用户请求 -> otherorder.service.hs.com -> DNS解析 -> nginx代理 -> istio-ingress-gateway -> 关联到otherorder.service.hs.com服务的svc -> 访问pod中的服务。

生产2号环境中不光只有otherorder.service.hs.com一个服务，有好多的服务都是通过这样来访问的



**问题：**发布新版本服务并且已经在k8s中部署，通过切换virtualservice流量达到蓝绿/灰度部署时，始终未生效，二次排查生产2号环境的pod，已经存在最新的编译文件，表示此镜像已经是最新，并且virtualservice canary的流量为100，但是用户访问到的还是老版本服务。

**原因：**经过排错得知，virtualservice有多个重复的域名，例如`otherorder.service.hs.com`，所以导致istio对部分服务的virtualservice进行流量切换时失效。流量切换失效的服务不只是`otherorder.service.hs.com`，失效的还有其它不确定的服务。



**问题：**某时刻，访问量大了起来，使istio ingress-gateway的pod带来了压力，ingress-gateway的HPA进行扩容，有一个pod始终被pending，因为ingress-gateway deployment使用了硬亲和，所以扩容无法完成，部分配置如下：

```
# 注释代码为原代码
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution: 
          - weight: 2
            podAffinityTerm: 
              topologyKey: kubernetes.io/hostname
              labelSelector: 
                matchLabels:
                  istio: ingressgateway
          #requiredDuringSchedulingIgnoredDuringExecution:
          #- labelSelector:
          #    matchLabels:
          #      istio: ingressgateway
          #  topologyKey: kubernetes.io/hostname
```

在编辑并应用ingress-gateway deployment后，所有新ingress-gateway一直被pending，手动删除一个running的ingress-gateway，此时所有新创建的ingress-gateway已经创建成功，但是此时所有的生产业务报`404`，`所有服务挂了`。



**解决：**回滚ingress-gateway deployment、重新创建ingress-gateway、istiod、gateway（匹配域名的网关）后，服务依旧如此，此时头脑空白，不知道原因何在，查看所有ingress-gateway的pod输出的日志，日志如下：

```
gRPC config for type.googleapis.com/envoy.config.route.v3.RouteConfiguration rejected: Only unique values for domains are permitted. Duplicate entry of domain otherorder.service.hs.com in route http.8080

# 中文翻译
已拒绝 type.googleapis.com/envoy.config.route.v3.RouteConfiguration 的 gRPC 配置： 只允许域的唯一值。路由 http.8080 中的 otherorder.service.hs.com 域名条目重复
```

![](..\image\k8s\faq\01.png)



最后在argoCD中将prepro-java-otherorder-service-hs-com(实际删除virtualservice、destination、deployment、servicee、hpa)项目删除后，服务恢复正常。



**究其原因：**因为这个项目otherorder.service.hs.com从阿里云docker环境`切换`到本地k8s环境，所以在本地生产2号部署了一套argoCD项目，此项目自动会创建virtualservice(有域名：otherorder.service.hs.com)，而本地生产2号已经存在这个域名，在prepro-dotnet-hsabservice-homsom-com这个项目的virtualservice中(也有域名：otherorder.service.hs.com)，在创建的时候istio能创建成功，所以当时并没有发现什么问题。

但是在扩容ingressgateway时，进行pod删除并重建操作，ingressgateway会重新读取virtualservice的所有域名和发现对应的service，此时因为有重复的otherorder.service.hs.com，所以ingressgateway检验不通过报`Duplicate entry of domain otherorder.service.hs.com in route http.8080`，虽然pod状态是running，但实际上ingressgateway并没有真正的运行起来，可以从上面的日志可以看出来，`最终解决办法就是只让virtualservice存在一个域名即可解决404问题。`







## 问题4:  pod无法重新创建

问题：测试k8s所有节点重新启动后，一直有服务卡住起不来，原因是测试k8s节点资源不好，硬盘、CPU、内存不好，所以一直有好多pod未成功运行，卡在`0/1`的状态

解决：优先启动`kube-system`名称空间的服务，特别是`网络组件`和`监控组件`的运行。其它是其它中间件服务的运行，最后才是基础服务的运行



问题：测试环境k8s所有pod都已运行，就是一个pod `calico-node-6dvvf`无法运行，查看信息报错如下：

```
root@test-k8s-master:~# kubectl  describe pods calico-node-6dvvf -n kube-system
Events:
  Type     Reason                  Age                     From               Message
  ----     ------                  ----                    ----               -------
  Normal   Scheduled               3m35s                   default-scheduler  Successfully assigned kube-system/calico-node-6dvvf to 192.168.13.223
  Warning  FailedCreatePodSandBox  3m20s (x13 over 3m34s)  kubelet            Failed to create pod sandbox: rpc error: code = Unknown desc = failed to start sandbox container for pod "calico-node-6dvvf": Error response from daemon: failed to start shim: fork/exec /usr/local/bin/containerd-shim: resource temporarily unavailable: unknown
  Normal   SandboxChanged          3m20s (x12 over 3m33s)  kubelet            Pod sandbox changed, it will be killed and re-created.
```

解决：将节点`192.168.13.223`置为不可调度，并删除部分pod，给223腾资源（实际资源是足够的，内存共：228G，用了30G，CPU使用率20%多，硬盘空间足够，就是硬盘是HDD，不过此时硬盘并不繁忙），然后删除`calico-node-6dvvf`，但是还不能运行，状态如下：

```
root@test-k8s-master:~# kubectl  get pods -o wide -n kube-system
calico-node-6dvvf                          0/1     Init:0/2   0              3m37s   192.168.13.223   192.168.13.223   <none>           <none>
```

最后将`docker服务重新启动`后，此问题解决，状态如下：

```
# 重新启动docker后，k8s节点192.168.13.223的服务并没有重启，不影响已经运行的pod
root@test-k8s-node03:~# systemctl restart docker 
root@test-k8s-node03:~# systemctl status docker 
* docker.service - Docker Application Container Engine
   Loaded: loaded (/etc/systemd/system/docker.service; enabled; vendor preset: enabled)
   Active: active (running) since Tue 2024-06-25 14:25:57 CST; 3s ago

# 此时192.168.13.223节点的calico-node-cndqk很快起来，状态不会有`Init:0/2`，此时正常了
root@test-k8s-node03:~# kubectl  get pods -o wide -n kube-system  
NAME                                       READY   STATUS    RESTARTS       AGE    IP               NODE             NOMINATED NODE   READINESS GATES
calico-kube-controllers-754966f84c-nvfcw   1/1     Running   1 (40m ago)    85m    192.168.13.222   192.168.13.222   <none>           <none>
calico-node-4cmqc                          1/1     Running   9 (40m ago)    276d   192.168.13.222   192.168.13.222   <none>           <none>
calico-node-cndqk                          1/1     Running   0              32s    192.168.13.223   192.168.13.223   <none>     
```

**根本原因：是docker的Tasks达到limit值了，设定为不限制即可**

```bash
# 查看docker Task的状态，限制为7372，已经使用7359了，应该是此限制导致docker无法启动了
root@test-k8s-node03:~# systemctl status docker | grep -i tasks
    Tasks: 7359 (limit: 7372)


# 设置docker服务task最大值为`无限的`，自己会重载服务
root@test-k8s-node03:~# systemctl set-property docker TasksMax=infinity 
root@test-k8s-node03:~# systemctl status docker | grep -i tasks
           `-50-TasksMax.conf
    Tasks: 7458

# 实际是生成了/etc/systemd/system.control/docker.service.d/50-TasksMax.conf 这个配置文件，并让docker加载此文件从而生效
root@test-k8s-node03:~# cat /etc/systemd/system.control/docker.service.d/50-TasksMax.conf 
# This is a drop-in unit file extension, created via "systemctl set-property"
# or an equivalent operation. Do not edit.
[Service]
TasksMax=infinity

# 如果未生效，执行重启docker服务并验证是否生效
root@test-k8s-node03:~# systemctl daemon-reload
root@test-k8s-node03:~# systemctl restart docker
root@test-k8s-node03:~# systemctl show docker --property=TasksMax
TasksMax=infinity
root@test-k8s-node03:~# systemctl status docker | grep -i tasks
           `-50-TasksMax.conf
    Tasks: 7459
    
# 此时CrashLoopBackOff的pod变成Running慢慢启动了
root@test-k8s-node01:~# kubectl get pods -o wide -A  | grep  '0/1'
fat-frontend     frontend-regionalsource-hs-com-deployment-56b57ccfc7-p2lvn        0/1     Running            0                12m     172.20.31.236    192.168.13.223   <none>           <none>
fat-java         java-dingtalkhotel-service-hs-com-deployment-6779f7c595-bk9c2     0/1     Running            0                6m11s   172.20.31.231    192.168.13.223   <none>           <none>
fat-java         java-jiyinapi-hs-com-deployment-65595bbbf-nwgqb                   0/1     CrashLoopBackOff   30 (3m22s ago)   155m    172.20.0.139     192.168.13.222   <none>           <none>
fat-java         java-jiyinapi-hs-com-deployment-7fb88784c-k4zzn                   0/1     CrashLoopBackOff   25 (10s ago)     119m    172.20.0.221     192.168.13.222   <none>           <none>
fat-java         java-regionalsource-service-hs-com-deployment-6557b776f-6z226     0/1     Running            0                12m     172.20.31.232    192.168.13.223   <none>           <none>
uat-dotnet       dotnet-appmessage-hs-com-deployment-74ff4fd5b7-bfhhx              0/1     Running            0                21m     172.20.31.196    192.168.13.223   <none>           <none>
uat-dotnet       dotnet-boss-hs-com-deployment-7559588bbd-pp96m                    0/1     Running            0                18m     172.20.31.199    192.168.13.223   <none>           <none>


```



**linux系统相关限制**

```bash
# 查看linux系统的文件句柄数使用情况
# 第一列：使用的文件句柄数，第二列：空闲的句柄数，第三列：最大可用的句柄数
root@test-k8s-node03:~# cat /proc/sys/fs/file-nr 
53888	0	52706963

# 查看最大pid数量 
root@test-k8s-node03:~# sysctl -a | grep kernel.pid_max
kernel.pid_max = 49152
# 查看当前使用的pid数量
root@test-k8s-node03:~# ps -eLf | wc -l 
14768
```

