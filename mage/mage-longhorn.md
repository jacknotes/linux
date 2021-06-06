#Longhorn

<pre>
Longhorn存储架构 
1. 基于Longhorn存储类创建PVC/PV卷
2. Pod绑定存储卷PVC/PV并且运行
2. Longhorn存储系统会根据创建的PVC生成对应的Volumes和engines（都是由自己提供的一个独立资源类型）,并且volumes和engines会在对应运行pod的节点上。
3. 每个Volumes对应一个Engines(控制器)，生命周期与存储卷相同，Engine与运行的pod在同一个节点上
4. 每个Engine都有特定的副本数，默认是3个，可以在部署Longhorn时定义副本数，建议为2，如果为1，此副本不能保证跟运行的pod在同一节点，因为pvc需要大小限额，longhorn自己会找到最优的节点创建副本。
5. 一个副本代表只有一份数据存储，两个副本代表有两个份数据存储，以此类推。

目前版本v1.0.1的Longhorn要求支行在docker v1.13或更高的版本下，以及kubernetes v1.4或更改的版本下，并且要求各节点部署了iscsi-initiator-utils curl findmnt grep awk blkid lsblk等程序包
--环境检查
curl -sSfL https://raw.githubusercontent.com/longhorn/longhorn/master/scripts/environment_check.sh | bash
1.各个kubernetes节点安装必要程序包：
yum install -y iscsi-initiator-utils curl findmnt grep awk blkid lsblk
2.基础环境准备完成后，我们使用类似如下的命令即能完成 Longhorn应用的部署：
注：默认副本是3，如果对数据可靠性要求不高则可以修改副本数后再进行部署，例如：
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: longhorn-storageclass
  namespace: longhorn-system
data:
  storageclass.yaml: |
    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
      name: longhorn
    provisioner: driver.longhorn.io
    allowVolumeExpansion: true
    reclaimPolicy: Delete
    volumeBindingMode: Immediate
    parameters:
      numberOfReplicas: "2"   #修改为2即可
      staleReplicaTimeout: "2880"
      fromBackup: ""
---
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/master/deploy/longhorn.yaml
应用后如下效果：
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy]# kubectl get all -n longhorn-system
NAME                                           READY   STATUS    RESTARTS   AGE
pod/csi-attacher-5dcdcd5984-brq78              1/1     Running   0          4m54s
pod/csi-attacher-5dcdcd5984-pwqvz              1/1     Running   0          4m54s
pod/csi-attacher-5dcdcd5984-qqqn8              1/1     Running   0          4m54s
pod/csi-provisioner-5c9dfb6446-8v694           1/1     Running   0          4m54s
pod/csi-provisioner-5c9dfb6446-kt9r8           1/1     Running   0          4m54s
pod/csi-provisioner-5c9dfb6446-sjjx2           1/1     Running   0          4m54s
pod/csi-resizer-6696d857b6-2jsdz               1/1     Running   0          4m53s
pod/csi-resizer-6696d857b6-gh9cz               1/1     Running   0          4m53s
pod/csi-resizer-6696d857b6-vxh48               1/1     Running   0          4m53s
pod/csi-snapshotter-96bfff7c9-64bxz            1/1     Running   0          4m53s
pod/csi-snapshotter-96bfff7c9-bvfwb            1/1     Running   0          4m53s
pod/csi-snapshotter-96bfff7c9-vz5dq            1/1     Running   0          4m53s
pod/engine-image-ei-611d1496-ft6lg             1/1     Running   0          5m33s
pod/engine-image-ei-611d1496-smrzx             1/1     Running   0          5m33s
pod/instance-manager-e-af346b0b                1/1     Running   0          5m29s
pod/instance-manager-e-d94bb2d6                1/1     Running   0          5m33s
pod/instance-manager-r-0b9db013                1/1     Running   0          5m29s
pod/instance-manager-r-6c584454                1/1     Running   0          5m32s
pod/longhorn-csi-plugin-hhf8f                  2/2     Running   0          4m53s
pod/longhorn-csi-plugin-q8xtv                  2/2     Running   0          4m53s
pod/longhorn-driver-deployer-ccb9974d5-qj6xs   1/1     Running   0          6m26s
pod/longhorn-manager-dm4pw                     1/1     Running   0          6m26s
pod/longhorn-manager-ls9ww                     1/1     Running   1          6m26s
pod/longhorn-ui-5b864949c4-wm7f5               1/1     Running   0          6m26s

NAME                        TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)     AGE
service/csi-attacher        ClusterIP   10.99.177.150    <none>        12345/TCP   4m54s
service/csi-provisioner     ClusterIP   10.102.114.64    <none>        12345/TCP   4m54s
service/csi-resizer         ClusterIP   10.108.152.197   <none>        12345/TCP   4m53s
service/csi-snapshotter     ClusterIP   10.96.173.238    <none>        12345/TCP   4m53s
service/longhorn-backend    ClusterIP   10.107.124.218   <none>        9500/TCP    6m26s
service/longhorn-frontend   ClusterIP   10.111.250.138   <none>        80/TCP      6m26s

NAME                                      DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/engine-image-ei-611d1496   2         2         2       2            2           <none>          5m33s
daemonset.apps/longhorn-csi-plugin        2         2         2       2            2           <none>          4m53s
daemonset.apps/longhorn-manager           2         2         2       2            2           <none>          6m26s

NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/csi-attacher               3/3     3            3           4m54s
deployment.apps/csi-provisioner            3/3     3            3           4m54s
deployment.apps/csi-resizer                3/3     3            3           4m53s
deployment.apps/csi-snapshotter            3/3     3            3           4m53s
deployment.apps/longhorn-driver-deployer   1/1     1            1           6m26s
deployment.apps/longhorn-ui                1/1     1            1           6m26s

NAME                                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/csi-attacher-5dcdcd5984              3         3         3       4m54s
replicaset.apps/csi-provisioner-5c9dfb6446           3         3         3       4m54s
replicaset.apps/csi-resizer-6696d857b6               3         3         3       4m53s
replicaset.apps/csi-snapshotter-96bfff7c9            3         3         3       4m53s
replicaset.apps/longhorn-driver-deployer-ccb9974d5   1         1         1       6m26s
replicaset.apps/longhorn-ui-5b864949c4               1         1         1       6m26s
--默认会创建一个存储类longhorn
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy]# kubectl get sc
NAME                  PROVISIONER          RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
longhorn              driver.longhorn.io   Delete          Immediate           true                   5m52s
managed-nfs-storage   fuseim.pri/ifs       Delete          Immediate           false                  31d
--基于存储类创建pvc
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy]# cat pvc-dynamic-longhorn-demo.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: default
  name: pvc-dynamic-longhorn-demo
spec: 
  accessModes: ["ReadWriteOnce"]
  volumeMode: Filesystem
  resources:
    requests:
      storage: 2Gi
  storageClassName: longhorn
--Longhorn存储设备支持动态预配，于是以默认创建的存储类Longhorn为模板的PVC在无满足其请求条件的PV时，可由控制器自动创建出适配的PV卷来。下面两条命令及结果也反映了这种预配机制：
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy]# kubectl apply -f pvc-dynamic-longhorn-demo.yaml
persistentvolumeclaim/pvc-dynamic-longhorn-demo created
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy]# kubectl get pvc
NAME                        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
pvc-dynamic-longhorn-demo   Bound    pvc-45aee2f2-922b-4e9a-bd8c-b6c45d43cc6c   2Gi        RWO            longhorn       44s
--对于每个存储卷，Longhorn存储系统都会使用自定义的Volumes类型资源对象维持及跟踪其运行状态，每个volumes资源都会有一个Engines资源对象作为其存储控制器，如下面的两个命令及结果所示：
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy]# kubectl get volumes -n longhorn-system
NAME                                       STATE      ROBUSTNESS   SCHEDULED   SIZE         NODE   AGE
pvc-45aee2f2-922b-4e9a-bd8c-b6c45d43cc6c   detached   unknown      True        2147483648          7m32s
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy]# kubectl get engines -n longhorn-system
NAME                                                  STATE     NODE   INSTANCEMANAGER   IMAGE   AGE
pvc-45aee2f2-922b-4e9a-bd8c-b6c45d43cc6c-e-7b4801f5   stopped                                    7m40s
--Engine资源对象的详细描述或资源规范中的spec和status字段记录有当前资源的详细信息，包括关联的副本、purge状态、恢复状态和快照信息等。
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy/longhorn]# kubectl describe engines/pvc-45aee2f2-922b-4e9a-bd8c-b6c45d43cc6c-e-7b4801f5 -n longhorn-system
NodeID:   #绑定的节点，它必须也该存储卷的pod运行于同一节点
Replica Address Map:   #关联的存储卷副本
注：replicas也是Longhorn提供的一个独立资源类型，每个资源对象对应着一个存储卷副本，如下面的命令所示：
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy/longhorn]# kubectl get replicas -n longhorn-system   --因为node只有两个节点，所以会有一个故障，而且此replicas是由下面的pod资源对象应用绑定pvc后才会生成，否则不会有replicas
NAME                                                  STATE     NODE                DISK                                   INSTANCEMANAGER               IMAGE                               AGE
pvc-45aee2f2-922b-4e9a-bd8c-b6c45d43cc6c-r-3c2b68b5   running   node01.k8s.hs.com   c8d53b15-6efd-45e4-beea-441782778e63   instance-manager-r-0b9db013   longhornio/longhorn-engine:v1.1.1   40m
pvc-45aee2f2-922b-4e9a-bd8c-b6c45d43cc6c-r-55b3ae42   running   node02.k8s.hs.com   c9c1d94b-5899-48d4-80bf-c1064acd4abe   instance-manager-r-6c584454   longhornio/longhorn-engine:v1.1.1   40m
pvc-45aee2f2-922b-4e9a-bd8c-b6c45d43cc6c-r-9f70c55e   stopped                                                                                                                                40m
注：基于Longhorn存储卷的PVC被Pod引用后，Pod所在的节点该存储卷Engine对象运行所在的节点，Engine的状态也才会由Stopped转为Running。
--运行绑定的pvc
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy/longhorn]# cat volumes-pvc-longhorn-demo.yaml
# Maintainer: MageEdu <mage@magedu.com>
# URL: http://www.magedu.com
---
apiVersion: v1
kind: Pod
metadata:
  name: volumes-pvc-longhorn-demo
  namespace: default
spec:
  containers:
  - name: redis
    image: redis:alpine
    imagePullPolicy: IfNotPresent
    ports:
    - containerPort: 6379
      name: redisport
    volumeMounts:
    - mountPath: /data
      name: redis-data-vol
  volumes:
  - name: redis-data-vol
    persistentVolumeClaim:
      claimName: pvc-dynamic-longhorn-demo
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy/longhorn]# kubectl apply -f volumes-pvc-longhorn-demo.yaml
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy/longhorn]# kubectl get pods/volumes-pvc-longhorn-demo
NAME                        READY   STATUS    RESTARTS   AGE
volumes-pvc-longhorn-demo   1/1     Running   0          3m55s
--基于Longhorn的存储卷PVC被，Pod所在的节点该存储卷Engine对象运行所有的节点，Engine的状态也才会由Stopped转为Running。因为该Pod所在的节点便是该PVC后端PV相关的Engine绑定的节点：
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy/longhorn]# kubectl get pods/volumes-pvc-longhorn-demo -o jsonpath='{.spec.nodeName}';echo
node02.k8s.hs.com
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy/longhorn]# kubectl get engines/pvc-45aee2f2-922b-4e9a-bd8c-b6c45d43cc6c-e-7b4801f5 -n longhorn-system -o jsonpath='{.spec.nodeID}';echo
node02.k8s.hs.com
注：由以上Longhorn存储系统的部署及测试结果可知，该存储系统不依赖于任何外部存储设备，仅基于Kubernetes集群工作节点本地的存储即能正常提供存储卷服务，且支持动态预配等功能。但应用于生产环境，还是有许多步骤需要优化，例如：将数据存储与操作系统等分离到不同的磁盘设备，是否可以考虑关闭底层的RAID设备等。具体请参考Longhorn文档中的最佳实践。

--通过浏览器访问用户接口
#取消：[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy/longhorn]#  kubectl patch service/longhorn-frontend --type='json' -p='[{"op": "replace","path": "/spec/type","value": "ClusterIP"},{"op": "remove", "path": "/spec/ports/0/nodePort"}]' -n longhorn-system
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy/longhorn]# kubectl patch service/longhorn-frontend -p '{"spec": {"type": "NodePort"}}' -n longhorn-system
service/longhorn-frontend patched
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy/longhorn]# kubectl get service/longhorn-frontend -o jsonpath='{.spec.ports[0].nodePort}' -n longhorn-system;echo
31762
浏览器访问：http://192.168.13.56:31762/#/dashboard

----通过ingress进行代理并且进行认证访问
--生成htpasswd文件及配置帐号密码，文件名称必须为auth，否则nginx会返回503
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy/longhorn]# htpasswd -c auth jack
New password: 
Re-type new password: 
Adding password for user jack
--生成secret
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy/longhorn]# kubectl create secret generic longhornauth --from-file="auth" -n longhorn-system
secret/longhornauth created
注：secret名称不能违背DNS规范，例如不能有下划线及大写等
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy/longhorn]# kubectl get secret longhornauth -n longhorn-system -o yaml
---
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy/longhorn]# cat longhorn-secret.yaml 
apiVersion: v1
kind: Secret
metadata:
  name: longhornauth
  namespace: longhorn-system
type: Opaque
data:
  auth: amFjazokYXByMSRLSVNVRjBjSyQ5dVhyRVVkenhsek5LbnJsYTdLZkExCg==
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy/longhorn]# kubectl apply -f longhorn-secret.yaml
---
apiVersion: v1
data:
  auth: amFjazokYXByMSRLSVNVRjBjSyQ5dVhyRVVkenhsek5LbnJsYTdLZkExCg==
kind: Secret
metadata:
  creationTimestamp: "2021-06-05T07:00:39Z"
  managedFields:
  - apiVersion: v1
    fieldsType: FieldsV1
    fieldsV1:
      f:data:
        .: {}
        f:auth: {}
      f:type: {}
    manager: kubectl-create
    operation: Update
    time: "2021-06-05T07:00:39Z"
  name: longhornauth
  namespace: longhorn-system
  resourceVersion: "10466836"
  selfLink: /api/v1/namespaces/longhorn-system/secrets/longhornauth
  uid: 9031cece-c893-4191-94b9-c712d05f6599
type: Opaque
---
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy/longhorn]# cat ingress-ui.yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: longhorn-ui
  namespace: longhorn-system
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "60"
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: longhornauth
    nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required - jack'
    #nginx.ingress.kubernetes.io/canary: "true"
    #nginx.ingress.kubernetes.io/canary-weight: "100"
spec:
  rules:
  - host: longhorn.hs.com
    http:
      paths: 
      - path: /
        backend:
          serviceName: longhorn-frontend
          servicePort: 80
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy/longhorn]# kubectl apply -f ingress-ui.yaml
ingress.extensions/longhorn-ui created
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy/longhorn]# curl -Is -u jack:jack -H 'Host: longhorn.hs.com' http://192.168.13.56 | grep HTTP
HTTP/1.1 200 OK
注：新建htpasswd文件时，名称必须是auth,否则建不成功。

#patch 增加，删除，替换，默认是替换
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy/longhorn]#  kubectl patch service/longhorn-frontend --type='json' -p='[{"op": "replace","path": "/spec/type","value": "ClusterIP"},{"op": "remove", "path": "/spec/ports/0/nodePort"}]' -n longhorn-system
service/longhorn-frontend patched

示例:
使用patch更新Node节点。
kubectl patch node k8s-node-1 -p '{"spec":{"unschedulable":true}}'

使用patch更新由“node.json”文件中指定的类型和名称标识的节点
kubectl patch -f node.json -p '{"spec":{"unschedulable":true}}'

更新容器的镜像
kubectl patch pod valid-pod -p '{"spec":{"containers":[{"name":"kubernetes-serve-hostname","image":"new image"}]}}'
kubectl patch pod valid-pod --type='json' -p='[{"op": "replace", "path": "/spec/containers/0/image", "value":"new image"}]'

更改service类型为NodePort形式
kubectl patch  svc schedule -n uat --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"add","path":"/spec/ports/0/nodePort","value":30930}]' 
kubectl patch svc schedule -n uat --type='json' -p '[{"op":"remove","path":"/spec/ports/0/nodePort"},{"op":"replace","path":"/spec/type","value":"ClusterIP"}]'



#名称空间一直是Terminating状态，如何删除？
--查看longhorn-system名称空间下有哪些资源未删除：
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy/longhorn]# kubectl api-resources -o name --verbs=list --namespaced | xargs -n 1 kubectl get --show-kind --ignore-not-found -n longhorn-system
Warning: extensions/v1beta1 Ingress is deprecated in v1.14+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
^C
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy/longhorn]# ^C
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy/longhorn]#  kubectl api-resources -o name --verbs=list --namespaced | xargs -n 1 kubectl get --show-kind --ignore-not-found -n longhorn-system 
Warning: extensions/v1beta1 Ingress is deprecated in v1.14+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
NAME                                  STATE      IMAGE                               REFCOUNT   BUILDDATE   AGE
engineimage.longhorn.io/ei-611d1496   deployed   longhornio/longhorn-engine:v1.1.1   1          43d         3h54m
NAME                                                                     STATE     NODE                INSTANCEMANAGER               IMAGE                               AGE
engine.longhorn.io/pvc-45aee2f2-922b-4e9a-bd8c-b6c45d43cc6c-e-7b4801f5   running   node02.k8s.hs.com   instance-manager-e-d94bb2d6   longhornio/longhorn-engine:v1.1.1   3h41m
NAME                                                      STATE     TYPE      NODE                AGE
instancemanager.longhorn.io/instance-manager-e-af346b0b   running   engine    node01.k8s.hs.com   3h54m
instancemanager.longhorn.io/instance-manager-e-d94bb2d6   running   engine    node02.k8s.hs.com   3h54m
instancemanager.longhorn.io/instance-manager-r-0b9db013   running   replica   node01.k8s.hs.com   3h54m
instancemanager.longhorn.io/instance-manager-r-6c584454   running   replica   node02.k8s.hs.com   3h54m
NAME                                 READY   ALLOWSCHEDULING   SCHEDULABLE   AGE
node.longhorn.io/node01.k8s.hs.com   True    true              True          3h54m
node.longhorn.io/node02.k8s.hs.com   True    true              True          3h55m
NAME                                                                      STATE     NODE                DISK                                   INSTANCEMANAGER               IMAGE                               AGE
replica.longhorn.io/pvc-45aee2f2-922b-4e9a-bd8c-b6c45d43cc6c-r-3c2b68b5   running   node01.k8s.hs.com   c8d53b15-6efd-45e4-beea-441782778e63   instance-manager-r-0b9db013   longhornio/longhorn-engine:v1.1.1   3h41m
replica.longhorn.io/pvc-45aee2f2-922b-4e9a-bd8c-b6c45d43cc6c-r-55b3ae42   running   node02.k8s.hs.com   c9c1d94b-5899-48d4-80bf-c1064acd4abe   instance-manager-r-6c584454   longhornio/longhorn-engine:v1.1.1   3h41m
replica.longhorn.io/pvc-45aee2f2-922b-4e9a-bd8c-b6c45d43cc6c-r-cb338f6a   stopped                                                                                                                                14m
NAME                                                          STATE      ROBUSTNESS   SCHEDULED   SIZE         NODE                AGE
volume.longhorn.io/pvc-45aee2f2-922b-4e9a-bd8c-b6c45d43cc6c   attached   degraded     False       2147483648   node02.k8s.hs.com   3h41m
--当强制也不行时，需要用到longhorn官网的卸载文件才行，地址：https://github.com/longhorn/longhorn/blob/master/uninstall/uninstall.yaml
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy/longhorn]# kubectl apply -f uninstall.yaml 



</pre>


#prometheus部署
<pre>
1. 部署prometheus
基于helm中的stable/prometheus和stable/grafana协协同完成部署：
[root@master02 /etc/pki/ca-trust/source/anchors]# kubectl create ns monitoring 
[root@master02 ~/k8s-manifests/prometheus/helm]# helm search repo stable/prometheus
NAME                                 	CHART VERSION	APP VERSION	DESCRIPTION                                       
stable/prometheus                    	11.12.1      	2.20.1     	DEPRECATED Prometheus is a monitoring system an...
[root@master02 ~/k8s-manifests/prometheus/helm]# helm show values stable/prometheus >> prometheus-values-with-longhorn-volumes.yaml
[root@master02 ~/k8s-manifests/prometheus/helm]# vim prometheus-values-with-longhorn-volumes.yaml 
[root@master02 ~/k8s-manifests/prometheus/helm]# helm install prom -f prometheus-values-with-longhorn-volumes.yaml stable/prometheus -n monitoring --dry-run
[root@master02 ~/k8s-manifests/prometheus/helm]# helm install prom -f prometheus-values-with-longhorn-volumes.yaml stable/prometheus -n monitoring 
[root@master02 ~/k8s-manifests/prometheus/helm]# kubectl get all -n monitoring
NAME                                               READY   STATUS    RESTARTS   AGE
pod/prom-kube-state-metrics-649d77c759-zvwlv       1/1     Running   0          14m
pod/prom-prometheus-alertmanager-0                 2/2     Running   0          14m
pod/prom-prometheus-node-exporter-62mnz            1/1     Running   0          14m
pod/prom-prometheus-node-exporter-7mx4q            1/1     Running   0          14m
pod/prom-prometheus-node-exporter-b4z62            1/1     Running   0          14m
pod/prom-prometheus-node-exporter-bfnvr            1/1     Running   0          14m
pod/prom-prometheus-node-exporter-hvqm8            1/1     Running   0          14m
pod/prom-prometheus-pushgateway-79f585d544-h2jcs   1/1     Running   0          14m
pod/prom-prometheus-server-0                       2/2     Running   0          14m

NAME                                            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/prom-kube-state-metrics                 ClusterIP   10.105.48.195    <none>        8080/TCP   14m
service/prom-prometheus-alertmanager            ClusterIP   10.106.173.231   <none>        80/TCP     14m
service/prom-prometheus-alertmanager-headless   ClusterIP   None             <none>        80/TCP     14m
service/prom-prometheus-node-exporter           ClusterIP   None             <none>        9100/TCP   14m
service/prom-prometheus-pushgateway             ClusterIP   10.96.15.177     <none>        9091/TCP   14m
service/prom-prometheus-server                  ClusterIP   10.109.107.120   <none>        80/TCP     14m
service/prom-prometheus-server-headless         ClusterIP   None             <none>        80/TCP     14m

NAME                                           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/prom-prometheus-node-exporter   5         5         5       5            5           <none>          14m

NAME                                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/prom-kube-state-metrics       1/1     1            1           14m
deployment.apps/prom-prometheus-pushgateway   1/1     1            1           14m

NAME                                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/prom-kube-state-metrics-649d77c759       1         1         1       14m
replicaset.apps/prom-prometheus-pushgateway-79f585d544   1         1         1       14m

NAME                                            READY   AGE
statefulset.apps/prom-prometheus-alertmanager   1/1     14m
statefulset.apps/prom-prometheus-server         1/1     14m


2. 部署grafana:
[root@master02 ~/k8s-manifests/prometheus/helm]# helm search repo stable/grafana
NAME          	CHART VERSION	APP VERSION	DESCRIPTION                                       
stable/grafana	5.5.7        	7.1.1      	DEPRECATED - The leading tool for querying and ...
[root@master02 ~/k8s-manifests/prometheus/helm]# helm show values stable/grafana >> grafana-values.yaml
[root@master02 ~/k8s-manifests/prometheus/helm]# vim grafana-values.yaml
[root@master02 ~/k8s-manifests/prometheus/helm]# helm install grafana -f grafana-values.yaml stable/grafana -n monitoring --dry-run 
[root@master02 ~/k8s-manifests/prometheus/helm]# helm install grafana -f grafana-values.yaml stable/grafana -n monitoring
[root@master02 ~/k8s-manifests/prometheus/helm]# kubectl get all -n monitoring | grep grafana
pod/grafana-566fc59d75-cm8rn                       1/1     Running   0          4m19s
service/grafana                                 ClusterIP   10.106.137.45    <none>        80/TCP     4m19s
deployment.apps/grafana                       1/1     1            1           4m19s
replicaset.apps/grafana-566fc59d75                       1         1         1       4m19s

3. 自定义指标适配器，k8s-prometheus-adapter
[root@master02 ~/k8s-manifests/prometheus/helm]# helm show values stable/prometheus-adapter >> prometheus-adapter-values.yaml
[root@master02 ~/k8s-manifests/prometheus/helm]# vim prometheus-adapter-values.yaml
[root@master02 ~/k8s-manifests/prometheus/helm]# helm install adapter -f prometheus-adapter-values.yaml stable/prometheus-adapter -n monitoring --dry-run
[root@master02 ~/k8s-manifests/prometheus/helm]# helm install adapter -f prometheus-adapter-values.yaml stable/prometheus-adapter -n monitoring
--部署完成后查看新增加的自定义API
[root@master02 ~/k8s-manifests/prometheus/helm]# kubectl api-versions | grep custom
custom.metrics.k8s.io/v1beta1

[root@master02 ~/k8s-manifests/prometheus/helm]# vim prometheus-adapter-values.yaml
--k8s-prometheus-adapter规则定义
rules:
  default: true
  custom:  
  - seriesQuery: 'http_requests_total{kubernetes_namespace!="",kubernetes_pod_name!=""}'
    resources:
      overrides:
        kubernetes_namespace: {resource: "namespace"}
        kubernetes_pod_name: {resource: "pod"}
    name:
      matches: "^(.*)_total"
      as: "${1}_pre_second"
    metricsQuery: rate(<<.Series>>{<<.LabelMatchers>>}[2m])
[root@master02 ~/k8s-manifests/prometheus/helm]# helm upgrade adapter -f prometheus-adapter-values.yaml stable/prometheus-adapter -n monitoring --dry-run
--更新值文件
[root@master02 ~/k8s-manifests/prometheus/helm]# helm upgrade adapter -f prometheus-adapter-values.yaml stable/prometheus-adapter -n monitoring 


</pre>