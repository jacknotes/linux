# Kubernetes FAQ



## 问题一

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



## 问题二

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

