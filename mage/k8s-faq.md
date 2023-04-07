# Kubernetes FAQ



## 问题一

问题描述：

K8s节点pod无法调度，kubectl describe pods POD_NAME 显示以下报错：

0/6 nodes are available: 3 Insufficient cpu, 3 node(s) were unschedulable. 

原因：因为K8s节点上CPU resource allocated（CPU已分配的资源 ）达到99%左右了，无法为新的pod分配cpu资源，所以无法调度成功，可通过kubectl describe nodes 192.168.13.36 | grep -A 10 Allocated 查看使用情况

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



