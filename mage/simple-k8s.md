k8s知识重点：

##k8s集群的管理方式：
	1. 命令式：create,run,delete,expose,edit....
	2. 命令式配置文件:create -f filename,delete -f ,replace -f
	3. 声明式配置文件:apply -f ,patch
#kubectl命令行常用命令操作：
1. [root@k8s-master ~]# kubectl get pods -l "release in (alpha,beta,canary)"
2. [root@k8s-master ~]# kubectl get pods -l "release notin (alpha,beta,canary)"
3. [root@k8s-master ~]# kubectl get pods -l release=canary --show-labels #精确查找，多个标签时为and关系
4. [root@k8s-master ~]# kubectl label pods pod-demo release=canary #打新标签
5. [root@k8s-master ~]# kubectl label pods pod-demo release=stable --overwrite #更改标签
6. [root@k8s-master ~]# kubectl get pods -L app,run --show-labels #显示所有pod中app,run这两个字段信息
7. [root@k8s-master ~]# kubectl create -f manifests/pod-demo.yaml 
8. [root@k8s-master manifests]# kubectl get pods -w #监控
9. [root@k8s-master ~]# kubectl explain pods.metadata #查看pod对象二级字段用法
10. [root@k8s-master ~]# kubectl set image deployment test2 test2=nginx:1.14-alpine #设置更新镜像
11. [root@k8s-master ~]# kubectl rollout status deployment test2 #查看指定控制器的回滚更新状态
12. [root@k8s-master ~]# kubectl rollout undo deployment test2 #指定控制器回滚到上一个版本
13. [root@k8s-master ~]# kubectl edit svc test2 #编辑最外面的service，使其类型为NodePort
14. [root@k8s-master ~]# kubectl scale --replicas=5 deployment test2 #把控制器test2下的pod动态扩展为5个
15. [root@k8s-master ~]# kubectl scale --replicas=3 deployment test2 #动态缩容为3个
16. [root@k8s-master ~]# kubectl run client -it --image=busybox --replicas=1 --restart=Never #新建一个pod客户端，失败后从不重启
17. [root@k8s-master ~]# kubectl get services #或者使用简写svc，查看接口,ip是动态生成的
18. [root@k8s-master ~]# kubectl get svc -n kube-system #查看kube-system 中的dns service
19. [root@k8s-master ~]# kubectl expose deployment nginx-deploy --name=nginx --port=80 --target-port=80 --protocol=TCP  #新建一个Service
20. [root@k8s-master ~]# kubectl get pods -o wide
21. [root@k8s-master ~]# kubectl get deployment #查看deployment类型的控制器
22. [root@k8s-master ~]# kubectl run nginx-deploy --image=nginx:1.14-alpine --port=80 --replicas=1 #增加一个deployment类型控制器叫nginx-deploy
23. [root@k8s-master ~]# kubectl version #查看k8s客户端和服务端的版本信息
24. [root@k8s-master ~]# kubectl cluster-info #查看集群信息
25. [root@k8s-master ~]# kubectl describe node k8s-master #查看节点的详细信息
26. [root@k8s-master ~]# kubectl get nodes #node2节点也已成功加入k8s集群
27. [root@node1 ~]# kubectl api-versions #查看k8s支持的api版本

#附件：
1. coreDNS,  2. kube-proxy  #这是集群建好后就好的。
2. 另外还有5个重要的：1. ingress controller 2. prometheus（监控组件），3. heapstar(收集k8s集群信息) ,4. dashboard ，5. flannal

#service支持4种类型：
1. clusterIP
2. NodePort
3. externelName
4. loadBlance
service支持无头ip(headless):只需要将值设为：clusterIP: None
service支持会话绑定sessionAffinity：ClientIP(源ip绑定),None(随机，默认)

#控制器：
replicaSet,deployMent,DaemonSet,job,cronJob.statefulSet
1. DaemonSet的yaml编写主要由selector和template两部分组成
2. deployMent的yaml编写主要由replicas、selector和template三部分组成
3. deployMent管理replicaSet,replicaSet最终管理pod，deployMent支持金丝雀发布，滚动更新(灰度发布),蓝绿部署。支持回滚上一个版本和指定版本。
4. 针对支持deploy管理的pod，可以使用yaml文件、edit、patch、set、scale等进行配置和更改运行状态。

#pod：
注：k8s的容器端口暴露只是给用户好看，不暴露的话pod与pod之间仍然可以互访，因为k8s使用的是叠加网络。
1. 支持对pod存活性探测(livenessProbe)、就绪性探测(readinessProbe)、启动后勾子(postStart)、结束前勾子(preStop)
2. pod的勾子由lifecycle字段引用，然后才是postStart和preStop，而探测则是直接用livenessProbe和readinessProbe引用 
3. pod生命周期状态：Pending(挂起),Running,Failed,Succeeded,Unknown,Ready
注：docker的entrypoint,cmd和k8s的command,args的比较
1. 当k8s没有传入command和args时，则使用docker的entrypoint和cmd。
2. 如果k8s只传入了command，则使用command
3. 如果k8s只传入了args,则使用entrypoint和args组合使用
4. 如果k8s都传入了command和args，则使用k8s的command和args组合使用。

#labels:
1. pod、controller、svc、node等都可以打标签，从而可以使用svc和controller manager用标签选择器进行选择匹配。
2. yaml配置清单中selector的标签匹配模式有两种：
	1. matchLabels: 直接给定键值
	2. matchExpressions: 基于给定的表达式来定义使用标签选择器，例如：{key:"KEY",operator:"OPERATOR",values:[value1,value2,....]}

#yaml语法：
Pod资源：
	spec.containers <[]Objects>
	- name <string>
	  image <string>
	  imagePullPolicy <string>
	    Always,Never,IfNotPresent
		注：Always：如果是latest版本，则永远去registry下载，如果不是latest，则本地有则使用本地，本地没有则去registry下载。
			Never:无论有没有，都不去registry下载
			IfNotPresent：本地有则使用本地，本地没有则去registry下载。
	修改镜像中的默认应用：
	  command,args
	标签：
		key=value #key和value分别最大63个字符（字母、数字、_、-）,key不能为空，value可以为空，都只能以字母数字开头及结尾。key前缀可以是域名(最长253个字符)

RESTful:
	web:GET,PUT,DELETE,POST,.....
	k8s:kubectl run,get,edit... #k8s以增删改查来使用GET,PUT等方法
资源：实例化后为对象
	名称空间级别资源：
		workload:Pod,ReplicaSet,Deployment,StatefulSet,DaemonSet,Job,Cronjob,....
		服务发现及均衡：Service,Ingress,....
		配置与存储:Volume,CSI(容器存储接口，CNI：容器网络接口)
			configMap,Secret
			DownwardAPI
			本地分布式网络存储：ceph,glusterFS,NFS
	集群级资源：
		Namespace,Node,Role,ClusterRole,RoleBinding,ClusterRoleBinding
	元数据资源
		HPA,PodTemplate,LimitRange	
创建资源的方法：
	apiserver仅接收JSON格式的资源定义，run命令默认把其转换为JSON格式
	yaml格式提供配置清单，apiserver可自动将yaml格式转化为JSON格式，然后提交;
大部分资源的配置清单：
	apiVersion: group/version | core  #api版本，可使用kubectl api-versions查看api版本
	kind：    #资源类别
	metadata:   #元数据
		name   #名称
		namespace   #名称空间
		labels     #标签
		annotations  #资源注解
		selfLink    #每个资源的引用PATH:/api/"GROUP/VERSION"/namespace/NAMESPACE/TYPE/NAME
	spec:		#期望的状态（目标状态），disired state。最重要字段，不同资源类型有不同的必选值，
	status: #当前状态，current state,本字段由kubenetes集群维护，用户不能更改
注：pod是最核心资源，所以属于core/v1,deployment是应用程序，属于apps/v1。可以使用kubectl proxy开启6443端口代理，开启http明文访问

#ingress controller和ingress
1. Ingress Controll自己独立运行的一个或一组pod资源，拥有七层代理能力和调度能力的应用程序，在做微服务的有三种：Nginx,Traefik,Envoy
2. 怎么定义Ingress规则,有两种方法：
	1. 基于虚拟主机名访问。
	2. 基于url路径访问。
3. 操作ingress controller总体步骤：
	1. 先运行后端http pod，并建立一个固定访问端点(service)
	2. 安装intress controller,测试ingress controller是否正常运行(通过ingress controller前端的service的NodePort端口进行访问，返回404说明ingresscontroller成功安装并运行)
	3. 配置运行ingress，让ingress关联到后端http pod。
4. 流程：用户访问最外层的四层负载均衡LVS的VIP,然后LVS代理到集群部分节点(特定节点打上污点，使DaemonSet能容忍污点)，类型是DaemonSet的pod，,且每个pod共享节点的网络空间，这个共享节点网络空间的pod是Ingress Controller，是七层负载均衡器(有Nginx,Traefik,Envoy,Haproxy[最不受待见])，Ingress Controller通过ingress(其实就是规则)指向后端的http pod，他们之间是明文传输的，而对集群外提供的Ingress Controller七层负载均衡器是https协议的，可以卸载用户ssl会话和重载pod的ssl会话，从而实现大量http网站的https部署。因为后端的pod随时会变化，所以要建一个service，这个service会从APIServer上实时收集变动的信息来重新分类pod,而ingress会watch收集service的pod信息，并且会注入到ingress-nginx的配置文件当中,从而实现配置文件的动态扩展。
5. ingress controller和ingress是通过ingress配置清单中的annotations:注释进行联系的，如：kubernetes.io/ingress.class: "nginx"

#存储卷
类型：empDir,hostPath,nfs,{存储系统，pv,pvc，pod引用}，动态pv
动态pv：k8s用户通过请求glusterFS存储集群的RESTful风格API接口自己生成满足用户需要的pv大小并自动挂载。注：glusterFS本身不提供RESTful风格API接口，需要借助第三方项目进行实现。ceph rdb存储集群系统带。
1. 先创建存储系统，例如nfs，可以导出多个目录，大小分别为1G，2G，3G，目录是/data/valumes/v{1,2,3},服务器是master,节点可以解析。
2. 在集群中创建pv，pv是集群级别，不是名称空间级别，定义pv的名称、存储系统类型(这里是nfs)、指定存储系统路径、读写模式、服务器地址，设定pv被pvc访问模式，pv的容量，pv的回收策略。
3. 建立pvc，指定pvc的访问模式，pvc的大小，从而会自动去匹配合适需求的pv，并bound pv和pvc的关联关系.
4. 建立pod引用，将pvc卷先挂载在node节点上，设定卷名称、指定pvc名称及是否对pvc进行读写。然后在pod中的容器配置卷挂载，指定挂载在node上的卷名称以及将要挂载在容器上的路径
如下是存储配置清单文件：
1. [root@node1 ~/manifests/storage]# cat pod-volume-emptyDir.yaml 
apiVersion: v1
kind: Pod
metadata: 
  name: pod-emptydir
  namespace: default
  labels: 
    app: myapp
    tier: frontend
spec:
  containers:
  - name: myapp
    image: busybox:latest
    ports:
    - name: http
      containerPort: 80
    command: ["/bin/sh","-c","/bin/httpd -f -h /data/web/html"]
    volumeMounts:
    - name: html
      mountPath: /data/web/html
  - name: busybox
    image: busybox:latest
    imagePullP
olicy: IfNotPresent
    volumeMounts:
    - name: html
      mountPath: /data
    command:
    - "/bin/sh"
    - "-c"
    - "while true;do echo $(date) >> /data/index.html;sleep 2;done"
  volumes:
  - name: html
    emptyDir: {}

2. [root@node1 ~/manifests/storage]# cat pod-volume-hostPath.yaml
apiVersion: v1
kind: Pod
metadata: 
  name: pod-hostpath
  namespace: default
spec:
  containers:
  - name: myapp
    image: busybox:latest
    imagePullPolicy: IfNotPresent
    ports:
    - name: http
      containerPort: 80
    command: ["/bin/sh","-c","/bin/httpd -f -h /data/web/html"]
    volumeMounts:
    - name: html
      mountPath: /data/web/html
  volumes:
  - name: html
    hostPath:
      path: /data/pod/volume1
      type: DirectoryOrCreate
  
3. [root@node1 ~/manifests/storage]# cat pod-volume-nfs.yaml 
apiVersion: v1
kind: Pod
metadata: 
  name: pod-nfs
  namespace: default
spec:
  containers:
  - name: myapp
    image: busybox:latest
    imagePullPolicy: IfNotPresent
    ports:
    - name: http
      containerPort: 80
    command: ["/bin/sh","-c","/bin/httpd -f -h /data/web/html"]
    volumeMounts:
    - name: html
      mountPath: /data/web/html
  volumes:
  - name: html
    nfs:
      path: /data/volumes
      server: master
      readOnly: false

4. [root@node1 ~/manifests/storage]# cat pod-volume-pv.yaml 
apiVersion: v1
kind: PersistentVolume 
metadata: 
  name: pv001
  labels:
    name: pv001
spec:
  nfs:
    path: /data/volumes/v1
    server: master
    readOnly: false
  accessModes:
  - "ReadWriteOnce"
  - "ReadOnlyMany"
  - "ReadWriteMany"
  capacity:
    storage: 1Gi
  persistentVolumeReclaimPolicy: Retain
---
apiVersion: v1
kind: PersistentVolume 
metadata: 
  name: pv002
  labels:
    name: pv002
spec:
  nfs:
    path: /data/volumes/v2
    server: master
    readOnly: false
  accessModes:
  - "ReadWriteOnce"
  - "ReadOnlyMany"
  - "ReadWriteMany"
  capacity:
    storage: 2Gi
  persistentVolumeReclaimPolicy: Retain
---
apiVersion: v1
kind: PersistentVolume 
metadata: 
  name: pv003
  labels:
    name: pv003
spec:
  nfs:
    path: /data/volumes/v3
    server: master
    readOnly: false
  accessModes:
  - "ReadWriteOnce"
  - "ReadOnlyMany"
  - "ReadWriteMany"
  capacity:
    storage: 3Gi
  persistentVolumeReclaimPolicy: Retain

5. [root@node1 ~/manifests/storage]# cat pod-volume-pvc.yaml 
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mypvc
  namespace: default
spec:
  accessModes: ["ReadWriteMany"]
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata: 
  name: pod-pvc
  namespace: default
spec:
  containers:
  - name: myapp
    image: busybox:latest
    imagePullPolicy: IfNotPresent
    ports:
    - name: http
      containerPort: 80
    command: ["/bin/sh","-c","/bin/httpd -f -h /data/web/html"]
    volumeMounts:
    - name: html
      mountPath: /data/web/html
  volumes:
  - name: html
    persistentVolumeClaim:
      claimName: mypvc
      readOnly: false

#configmap和secret比较：一个是明文一个是密文，都可以被容器当作变量值传入或者当共享卷挂载
#configmap
注：是明文的，KV格式，可以把整个配置文件当作值。
1. 可以被容器挂载为存储卷。 (更改configmap配置更改后，pod中引入的存储卷将会自动慢慢变更)
2. 当作变量值引入容器变量。(更改configmap配置更改后，不会自动慢慢变更，需要重启容器)
[root@node1 ~/manifests/storage]# cat www.conf 
server {
	server_name myapp.magedu.com;
	listen 80;
	root /data/web/html/;
}
[root@node1 ~/manifests/storage]# kubectl create configmap nginx-www --from-file=./www.conf
[root@node1 ~/manifests/storage]# kubectl create configmap nginx-config --from-literal=nginx_port=80 --from-literal=server_name=myapp.magedu.com
[root@node1 ~/manifests/storage]# kubectl get cm
NAME           DATA   AGE
nginx-config   2      18m
nginx-www      1      5s
1. [root@node1 ~/manifests/storage]# cat pod-configmap-env.yaml 
apiVersion: v1
kind: Pod
metadata: 
  name: pod-configmap-env
  namespace: default
  labels: 
    app: myapp
    tier: frontend
  annotations:
    magedu.com/created-by: "cluster admin"
spec:
  containers:
  - name: myapp
    image: ikubernetes/myapp:v1
    ports:
    - name: http
      containerPort: 80
    env: 
    - name: NGINX_SERVER_PORT
      valueFrom:
        configMapKeyRef:
          name: nginx-config
          key: nginx_port
          optional: true
    - name: NGINX_SERVER_NAME
      valueFrom:
        configMapKeyRef:
          name: nginx-config
          key: server_name
          optional: true
2. [root@node1 ~/manifests/storage]# cat pod-configmap-volume.yaml 
apiVersion: v1
kind: Pod
metadata: 
  name: pod-configmap-volume
  namespace: default
  labels: 
    app: myapp
    tier: frontend
  annotations:
    magedu.com/created-by: "cluster admin"
spec:
  containers:
  - name: myapp
    image: ikubernetes/myapp:v1
    ports:
    - name: http
      containerPort: 80
    volumeMounts:
    - name: nginxconf
      mountPath: /etc/nginx/config.d
      readOnly: true
  volumes:
  - name: nginxconf
    configMap:
      name: nginx-config
3. [root@node1 ~/manifests/storage]# cat pod-configmap-volume-example.yaml 
apiVersion: v1
kind: Pod
metadata: 
  name: pod-configmap-nginx
  namespace: default
  labels: 
    app: myapp
    tier: frontend
  annotations:
    magedu.com/created-by: "cluster admin"
spec:
  containers:
  - name: myapp
    image: ikubernetes/myapp:v1
    ports:
    - name: http
      containerPort: 80
    volumeMounts:
    - name: nginxconf
      mountPath: /etc/nginx/conf.d
      readOnly: true
  volumes:
  - name: nginxconf
    configMap:
      name: nginx-www

#secret
secret有3种类型：
1. docker-registry：当从私有仓库中pull镜像是需要认证时需要用这种类型创建secret.		配置清单中使用：pods.spec.imagePullSecrets
2. generic：当使用其他帐号和密码时使用这种  
3. tls：使用私钥和证书时使用这种
[root@node1 ~/manifests/storage]# kubectl create secret generic mysql-userpassword --from-literal=password=MyP@ssword
[root@node1 ~/manifests/storage]# kubectl get secret
[root@node1 ~/manifests/storage]# kubectl describe secret mysql-userpassword
Name:         mysql-userpassword
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
password:  10 bytes
[root@node1 ~/manifests/storage]# kubectl get secret mysql-userpassword -o yaml
apiVersion: v1
data:
  password: TXlQQHNzd29yZA==
kind: Secret
metadata:
  creationTimestamp: "2020-06-29T07:06:12Z"
  name: mysql-userpassword
  namespace: default
  resourceVersion: "188869"
  selfLink: /api/v1/namespaces/default/secrets/mysql-userpassword
  uid: 6b0a29fc-8b03-4b08-8041-d259a8e0d61a
type: Opaque
[root@node1 ~/manifests/storage]# echo TXlQQHNzd29yZA== | base64 -d
MyP@ssword  #base64可以解码
1. [root@node1 ~/manifests/storage]#  cat pod-secret-env.yaml #也可以将secret 
apiVersion: v1
kind: Pod
metadata: 
  name: pod-secret-env
  namespace: default
  labels: 
    app: myapp
    tier: frontend
  annotations:
    magedu.com/created-by: "cluster admin"
spec:
  containers:
  - name: myapp
    image: ikubernetes/myapp:v1
    ports:
    - name: http
      containerPort: 80
    env: 
    - name: MYSQL_PASSWORD
      valueFrom:
        secretKeyRef:
          name: mysql-userpassword
          key: password 
          optional: true

#statefulSet控制器
特性：
1. 稳定且惟一的网络标识符;  #pod名称是固定唯一的
2. 稳定且持久的存储;   #采用pvc来绑定pod名称，pvc策略为数据不会删除
3. 有序、平滑地部署和扩展;  
4. 有序、平滑地终止和删除;
5. 有序的流动更新;
6. pod_name.service_name.namespace_name.cluster.local #集群解析名称格式，在sts控制器下的pod他们之间的pod名称是可以直接解析的
7. 有状态应用需要的三个组件：headless service(必需使用无头service), statefulSet, volumeClaimTemplate(自动生成PVC向PV建立关联关系)
8. statefulSet控制器也支持金丝雀、滚动更新发布策略
注：有状态应用在k8s上现在还是很难操作
1. [root@node1 ~/manifests]# cat statefulSet-ct.yaml 
apiVersion: v1
kind: Service
metadata: 
  name: myapp
  labels:
    app: myapp
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None  
  selector: 
    app: myapp-pod
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: myapp
spec:
  serviceName: myapp 
  replicas: 2
  selector:
    matchLabels:
      app: myapp-pod
  template:
    metadata:
      labels:
        app: myapp-pod
    spec: 
        containers:
        - name: myapp
          image: ikubernetes/myapp:v1
          ports:
          - containerPort: 80
            name: web
          volumeMounts:   
          - name: myappdata
            mountPath: /usr/share/nginx/html/
  volumeClaimTemplates:  
  - metadata:
      name: myappdata
    spec:
      accessModes: ['ReadWriteOnce']
      resources:
        requests:
          storage: 1Gi 
2. [root@k8s-master configmap]# kubectl patch sts myapp -p '{"spec":{"updateStrategy":{"rollingUpdate":{"partition":2}}}}' #设置更新策略，为分区(pod名称最后以数字结尾的数字就是分区号)大于等于2的更新
3. [root@k8s-master configmap]# kubectl set image sts myapp myapp=ikubernetes/myapp:v2 #设置镜像更新

#k8s认证、授权、准入控制(这个用得少)
[root@k8s-master ~]# kubectl proxy --port=8080  #在本地127.0.0.1:8080开启代理
[root@node1 ~/manifests]# kubectl get svc #kubernetes service是k8s自动在每个名称空间下建立的，用于映射节点的APIserver到service，所以pod可以直接访问service跟apiserver进行操作
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   28h
#认证
认证方式：1. token, 2. tls（重点使用） 3.user/password
注：k8s有两类帐户：
1. userAccount：一般人使用到的  
2. serviceAccount：pod中使用的
#serviceAccount
1. [root@node1 ~/manifests]# kubectl create serviceaccount admin #手动建立sa，后面可以授权
serviceaccount/admin created
2. [root@node1 ~/manifests]# kubectl get sa #default sa帐户k8s默认建立的
NAME      SECRETS   AGE
admin     1         4s
default   1         3d1h
3. [root@node1 ~/manifests]# kubectl get secret #并根据sa自动生成secret,自动生成的secret权限很小
NAME                    TYPE                                  DATA   AGE
admin-token-wgm42       kubernetes.io/service-account-token   3      117s
default-token-wsbxh     kubernetes.io/service-account-token   3      3d1h
4. [root@node1 ~/manifests]# cat pod-sa-demo.yaml  #绑定新建立sa
apiVersion: v1
kind: Pod
metadata: 
  name: pod-sa-demo
  namespace: default
  labels: 
    app: myapp
    tier: frontend
spec:
  containers:
  - name: myapp
    image: ikubernetes/myapp:v1
  serviceAccountName: admin
5. pod在获取镜像时可以用两种方式把docker login需要用到的帐号和密码进行加密
	1. 建立一个secret，里面包含用户名和密码，然后在新建pod时的配置清单中使用imagePullSecret字段进行添加这个secret。
	2. 建立一个sa帐户，把docker login需要用到的帐号和密码配置进sa，然后在新建pod时的配置清单中使用serviceAccountName字段进行添加。

#sa
1. [root@node1 /etc/kubernetes/pki]# kubectl config view #当前用户的配置信息
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://192.168.15.201:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
注：配置一个新用户则首先要获取由ca签署的证书和私钥，然后用kubectl config命令添加用户，需要用到的四个命令：set-cluster、set-credentials、set-context、use-context
2. [root@node1 ~]# cd /etc/kubernetes/pki/
3. [root@node1 /etc/kubernetes/pki]# (umask 077; openssl genrsa -out magedu.key 2048)
4. [root@node1 /etc/kubernetes/pki]# openssl req -new -key magedu.key -out magedu.csr -subj "/CN=magedu" #生成证书签署请求，CN就是用户名
5. [root@node1 /etc/kubernetes/pki]# openssl x509 -req -in magedu.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out magedu.crt -days 365 #指定ca证书、key、并且用ca生成序列号，最终输出证书
6. [root@node1 /etc/kubernetes/pki]# openssl x509 -in magedu.crt -text -noout #查看证书
------将证书添加到连接k8s集群中的信息
7. [root@node1 /etc/kubernetes/pki]# kubectl config set-credentials magedu --client-certificate=./magedu.crt --client-key=./magedu.key --embed-certs=true #向当前配置文件添加magedu用户，并且将敏感信息隐藏
8. [root@node1 /etc/kubernetes/pki]# kubectl config set-context magedu@kubernetes --cluster=kubernetes --user=magedu #将用户跟集群进行绑定
9. [root@node1 /etc/kubernetes/pki]# kubectl config use-context magedu@kubernetes #切换用户为magedu，此时magedu用户没有权限的
10. [root@node1 /etc/kubernetes/pki]# kubectl config set-cluster mycluster --kubeconfig=/tmp/test.conf --server=https://192.168.15.201:6443 --certificate-authority=/etc/kubernetes/pki/ca.crt --embed-certs=true #前面有cluster,这里是新建一个cluster并且将配置文件保存在/tmp/test.conf下，还可以向里面添加context,user。

#授权-RBAC
RBAC: Role-Base Access Controller
名称空间：Role,Rolebinding
集群级别：clusterRole,clusterRolebinding
1. 使用rolebinding去绑定role和user,此时user有了名称空间级别的role权限
2. 使用clusterrolebinding去绑定clusterrole和user，此时user有了集群级别的clusterrole权限
3. 使用rolebinding绑定clusterrole和user，此时user有了名称空间的clusterrole权限，也就是user有了自己所在名称空间的所有关于clusterrole角色当中的权限
4. 绑定角色可以绑定在user,group,serviceaccount上。{group和user是在证书（tls方式）生成的时候指定的}
#role
4. [root@node1 ~/manifests]# kubectl create role pods-reader --verb=get,list,watch --resource=pods --dry-run -o yaml > ./pods-reader.yaml #新建role
5. [root@node1 ~/manifests]# cat pods-reader.yaml 
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pods-reader
  namespace: default
rules:
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - get
  - list
  - watch
6. [root@node1 ~/manifests]# kubectl apply -f ./pods-reader.yaml 
role.rbac.authorization.k8s.io/pods-reader created
[root@node1 ~/manifests]# kubectl get role
NAME          AGE
pods-reader   5s
7. [root@node1 ~/manifests]# kubectl create rolebinding magedu-pods-read --role=pod-reader --user=magedu -o yaml --dry-run > pods-rolebinding.yaml  #新建rolebinding
8. [root@node1 ~/manifests]# kubectl apply -f pods-rolebinding.yaml
9. [root@node1 ~/manifests]# kubectl get rolebinding
NAME               AGE
magedu-pods-read   10s
10. [root@node1 ~/manifests]# kubectl describe rolebinding magedu-pods-rea
Role:
  Kind:  Role
  Name:  pods-reader
Subjects:
  Kind  Name    Namespace
  ----  ----    ---------
  User  magedu  
11. [root@node1 ~/manifests]# kubectl config use-context magedu@kubernetes
Switched to context "magedu@kubernetes".
[root@node1 ~/manifests]# kubectl get pods
NAME          READY   STATUS    RESTARTS   AGE
myapp-0       1/1     Running   0          4h51m
myapp-1       1/1     Running   0          4h51m
pod-sa-demo   1/1     Running   0          172m
12. [root@node1 ~/manifests]# kubectl get pods -n ingress-nginx
Error from server (Forbidden): pods is forbidden: User "magedu" cannot list resource "pods" in API group "" in the namespace "ingress-nginx"
#clusterrole
13. [root@node1 ~/manifests]# kubectl create clusterrolebinding magedu-readall-pods --clusterrole=cluster-reader --user=magedu --dry-run -o yaml > clusterrolebinding-demo.yaml
14. [root@node1 ~/manifests]# kubectl apply -f clusterrolebinding-demo.yaml
注：kubeadm集群默认管理员是属于O=system:masters这个组的，而这个组则跟cluster-admin这个clusterrole角色绑定了，这个cluster-admin集群角色权限很大。因为如果我们要自定义一个管理员，则在生成证书的时候可以设定/O=system:masters这个组就可以了

#dashboard认证及分级授权
dashboard是GUI,只是k8s的代理，认证和授权都是k8s来进行的，不是dashboard进行的。
#安装
1. [root@node1 /download/k8s]# wget https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended.yaml
2. [root@node1 /download/k8s]# mv recommended.yaml dashboard-recommended.yaml 
3. [root@node1 /download/k8s]# kubectl apply -f dashboard-recommended.yaml 
4. [root@node1 /download/k8s]# kubectl patch svc kubernetes-dashboard -p '{"spec":{"type": "NodePort"}}' -n kubernetes-dashboard
5. [root@node1 /download/k8s]#   kubectl get svc kubernetes-dashboard -n kubernetes-dashboard
NAME                   TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)         AGE
kubernetes-dashboard   NodePort   10.99.4.100   <none>        443:31313/TCP   18m
#dashboard有两种认证方式：Token和kubeconfig
注：dashboard认证都是基于serviceaccount用户进行认证的，useraccount用户是不行的，useraccount用户只能在kubectl中进行使用
#Token认证：
1. [root@node1 /download/k8s]# kubectl create serviceaccount dashboard-admin -n kubernetes-dashboard
2. [root@node1 /download/k8s]# kubectl get sa dashboard-admin -n kubernetes-dashboard
NAME              SECRETS   AGE
dashboard-admin   1         11s
3. [root@node1 /download/k8s]# kubectl get secret -n kubernetes-dashboard
NAME                               TYPE                                  DATA   AGE
dashboard-admin-token-25wds        kubernetes.io/service-account-token   3      34s  #这个自动生成的，现在权限是最小权限
4. [root@node1 /download/k8s]# kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:dashboard-admin #给serviceaccount帐户绑定集群管理员角色，此时上面的secret权限已经很大了
5. [root@node1 /download/k8s]# kubectl describe secret dashboard-admin-token-25wds  -n kubernetes-dashboard 
Name:         dashboard-admin-token-25wds
Namespace:    kubernetes-dashboard
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: dashboard-admin
              kubernetes.io/service-account.uid: 915c951b-337f-432b-a6bb-f9463392df28

Type:  kubernetes.io/service-account-token

Data
====
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJkYXNoYm9hcmQtYWRtaW4tdG9rZW4tMjV3ZHMiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGFzaGJvYXJkLWFkbWluIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiOTE1Yzk1MWItMzM3Zi00MzJiLWE2YmItZjk0NjMzOTJkZjI4Iiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50Omt1YmVybmV0ZXMtZGFzaGJvYXJkOmRhc2hib2FyZC1hZG1pbiJ9.X5ROlNj6Q5c6B_G4n1fyIlKPm8tX9YlFh2r4OjzYQ8UTik8xYSLRPKrXXP4NWIdzkPDmgRn2gSdPuEevfByJruUz0WWXdZkJIqplHDE-o4vStyxn8dJ-niYaD4SxDA-TuDyJ5_MEj0TAU_TGxZv7DQ6Z3jhYO8yAjyjJtzs865Vg_dVV9AEch_UesNtXmjaWsw-Vl9FYAbLjyFV0rlaJ0QqaOXdfBZ32JImAkS76WmlC0I-k5VcCnlJ_BxlV1ZWVif98jFhQbym0Li4p1cNnNkak-cIvAoyHDLTClxLVbNCbzfWVsmq3cJZpnGB3B0tW5vHSlJ_svHHpV9VQnS7t1A  
ca.crt:     1025 bytes
namespace:  20 bytes
注：#上面的token就是新建的serviceaccount令牌
#kubeconfig认证：
1. [root@node1 /download/k8s]# kubectl create serviceaccount def-ns-admin
2. [root@node1 /download/k8s]# kubectl create rolebinding def-ns-admin --clusterrole=admin --serviceaccount=default:def-ns-admin
3. [root@node1 /download/k8s]# kubectl get secret def-ns-admin-token-kcnms -o jsonpath={.data.token} | base64 -d  #需要对serviceaacount的帐户权限secret的token进行解码后才能使用
eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImRlZi1ucy1hZG1pbi10b2tlbi1rY25tcyIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJkZWYtbnMtYWRtaW4iLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiJiMWNlNGYwYS1mZjA0LTQxZTAtYTYyOC0zYjRmMTM5ODIzOTIiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6ZGVmYXVsdDpkZWYtbnMtYWRtaW4ifQ.Vaj7xv-NHv-NsVsRLY-CVafQpFcJFhtuCXqUIOwEMUm14_wVJ0S46M_zj0sh8n9WkXC27H3BXRsXg1Pwq1Jbe4pzqGX_ymhU-BbogjCTkTlFqqgDRcV88aBEBwlgynMOBpvxwSzrNdeGMpm9KL8AdQq18fgNkGUsls39Rox7yhDMwVUsx7lrwWdvV2daSdFK9ea3gwifv6xuUO0dhuaeLMbsnbJ3Gx-D0Cmf6iAHG0viBEl3UrE8_Av1NbBvfNZHGjp0tbT1FSjDBI8yj-J11jzaNhUbDdMdi0z4zlLKt4Cna7DE2b9YtnkJtRFsipZfcjtaYKnRX4Mz_audSs2AQw
4. [root@node1 ~]# DEF_NS_ADMIN_TOKEN=$(kubectl get secret def-ns-admin-token-kcnms -o jsonpath={.data.token} | base64 -d )
5. [root@node1 ~]# kubectl config set-cluster kubernetes --certificate-authority=/etc/kubernetes/pki/ca.crt --server=server="https://192.168.15.201:6443" --kubeconfig=/root/def-ns-admin.conf
6. [root@node1 ~]# kubectl config set-credentials def-ns-admin --token=$DEF_NS_ADMIN_TOKEN --kubeconfig=/root/def-ns-admin.conf
7. [root@node1 ~]# kubectl config set-context def-ns-admin@kubernetes --cluster=kubernetes --user=def-ns-admin --kubeconfig=/root/def-ns-admin.conf
8. [root@node1 ~]# kubectl config use-context def-ns-admin@kubernetes --kubeconfig=/root/def-ns-admin.conf
注：最后把生成的def-ns-admin.conf给用户即可
--k8s-admin
[root@node3 ~]# kubectl create serviceaccount k8s-admin
[root@node3 ~]# kubectl create clusterrolebinding k8s-admin --clusterrole=cluster-admin --serviceaccount=default:k8s-admin
[root@node3 ~]# K8S_ADMIN="eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Ims4cy1hZG1pbi10b2tlbi04cjR0dCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJrOHMtYWRtaW4iLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI1YTc1ZjBkMi0xMmU2LTQ5OTItYTNjMy0wYTllODI2ZWJkNTgiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6ZGVmYXVsdDprOHMtYWRtaW4ifQ.ezD_aLohTDTz6y8kdw_P0ctYJkOgjmyn4Ylj89hSGx2pabf6gLepzU1IHyUjyDiSdOwiK0kSIZ8rFUjxHEScsgfbX-8l8d-4mrx_FD0pjLUe6zd2UwSOGr__123UwV8mhTvht9IUH4XmEKsSx-vY-KH-Du8MQWzQ8km4xJ8-Ca96B-1ncg7qeiE7v-KWziCrfoLpVXhciHnxM68ctJMU2CpPdKbCxpN6Vppd8cG8r8jAkxW4_XcUFmGVfaZCdbRYfD6utLs7oxu2_znY0vowavyGN2urAPSdCTqorZHCPNPNRuYRWj5ASdyTE8x7ZVZ2zxZiBI75Su88Xv_WjJuOzg"  #kubectl describe secret k8s-admin-token-8r4tt得来
[root@node1 /download/k8s]# kubectl config set-credentials k8s-admin --token=$K8S_ADMIN --kubeconfig=/root/k8s-admin.conf
[root@node1 /download/k8s]# kubectl config set-context k8s-admin@kubernetes --cluster=kubernetes --user=k8s-admin --kubeconfig=/root/k8s-admin.conf
[root@node1 /download/k8s]# kubectl config use-context k8s-admin@kubernetes --kubeconfig=/root/k8s-admin.conf
[root@node1 /download/k8s]# kubectl config view --kubeconfig=/root/k8s-admin.conf
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /etc/kubernetes/pki/ca.crt
    server: https://192.168.15.201:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: k8s-admin
  name: k8s-admin@kubernetes
current-context: k8s-admin@kubernetes
kind: Config
preferences: {}
users:
- name: k8s-admin
  user:
    token: eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Ims4cy1hZG1pbi10b2tlbi04cjR0dCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJrOHMtYWRtaW4iLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI1YTc1ZjBkMi0xMmU2LTQ5OTItYTNjMy0wYTllODI2ZWJkNTgiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6ZGVmYXVsdDprOHMtYWRtaW4ifQ.ezD_aLohTDTz6y8kdw_P0ctYJkOgjmyn4Ylj89hSGx2pabf6gLepzU1IHyUjyDiSdOwiK0kSIZ8rFUjxHEScsgfbX-8l8d-4mrx_FD0pjLUe6zd2UwSOGr__123UwV8mhTvht9IUH4XmEKsSx-vY-KH-Du8MQWzQ8km4xJ8-Ca96B-1ncg7qeiE7v-KWziCrfoLpVXhciHnxM68ctJMU2CpPdKbCxpN6Vppd8cG8r8jAkxW4_XcUFmGVfaZCdbRYfD6utLs7oxu2_znY0vowavyGN2urAPSdCTqorZHCPNPNRuYRWj5ASdyTE8x7ZVZ2zxZiBI75Su88Xv_WjJuOzg



#配置网络插件flanner
docker网络：
	1. bridge（自由网络名称空间）
	2. joined（共享使用另外空间的名称空间）
	3. open(容器共享宿主机网络名称空间)
	4. none（不使用任何网络名称空间）
k8s网络通信：
	1. 容器间通信：同一个pod内的多个容器间的通信，lo接口通信
	2. pod通信：pod IP<--> pod IP  ,ip直达，overlay网络 
	3. pod与service通信： pod IP <-->cluster IP ,iptables与ipvs的规则进行通信,ipvs取代不了iptables,因为ipvs不能nat
	4. service与集群外部客户端的通信
k8s需要CNI接口的网络插件：
	1. flannel
	2. calico
	3. canel
	4. kube-router
	5. ......
	解决方案：
		1. 虚拟网桥
		2. 多路复用：MacVLAN(基于宿主机mac地址划分vlan)
		3. 硬件交换：SR-IOV（单臂路由）
三大类：men,metadata,IPAM
flannel网络插件对名称空间与名称空间之间的网络是没有隔离的，因为flannel没有网络策略（networkPolicy），可以使用flannel+calico一起使用，flannel分配地址，calico部署网络策略
kubelet启动时去/etc/cni/net.d/下加载配置文件从而实现地址分配
[root@k8s-master ~]# ls /etc/cni/net.d/
10-flannel.conflist
注：flannel支持多种后端承载网络：
	1. VxLAN:overlay网络（可以跨三层网络，可以扩展与host-gw一起使用，当node在一个网络时使用host-gw(Directrouting),当不在同一网络时使用overlay网络(vxlan)）
	2. host-gw:HOST Gateway（性能比VxLAN好，但是不能跨三层网络）
	3. UDP: 基于普通UDP转发，性能最差，在以上两种不能使用时才使用这种。
注：k8s上flannel有两种部署方式：
	1. 使用宿主机service服务启动方式部署  
	2. 使用kubeadm来部署，只是把kubelet和docker独立出来，其他都运行为pod
kubelet启动pod，而Pod需要网络，所以kubelet调flannel而启动网络插件，所以flannel必须跟kubelet安装在一起。但是flannel是第三方插件，所以部署k8s时首先要部署flannel第三方网络插件，否则k8s集群无法启动起来
#flannel的配置参数：
	Network: flannel使用的CIDR格式的网络地址，用于为pod配置网络功能
		10.244.0.0/16为全集群的ip，master为10.244.0.0/24,node1为10.244.1.0/24...
	SubnetLen: 把Network切分子网供各节点使用时，使用多长的掩码进行切分，默认是24位掩码
	SubnetMin: 设置分配给节点的最小子网，例:10.244.10.0/24，就是pod网络从10.0开始，11.0，依次类推
	SubnetMax: 设置分配给节点的最大子网，10.244.100.0/24
	Backend: VxLAN,host-gw,UDP
		VxLAN:1.overlay 2.Directrouting
	--vxlan默认是overlay网络(一直使用隧道传输数据，比起host-gw有点慢)，建议开启Directrouting网络(当节点在同一个lan时，使用host-gw网络，当跨路由时使用overlay网络，会自动调节)，host-gw网络最快(但是必须要求节点网络必须在一个lan中)，UDP最慢，不建议使用
注：当集群节点大于500时，网络性能问题会突现，在部署集群时就应该把flannel的模式由overlay2网络改为Directrouting
1. [root@node1 ~]# kubectl get configmap kube-flannel-cfg -o yaml -n kube-system #查看flannel的配置
2. 编辑kube-flannel.yml 配置清单文件，开启Directrouting，最后应用flannel清单文件即可，这个操作应该是建立集群开始就应该做好。
net-conf.json: |
    {
      "Network": "10.244.0.0/16",
      "Backend": {
        "Type": "vxlan", 
        "Directrouting": true 
      }
    }
注：如果需要可以调小子网掩码，例如"Network": "10.244.0.0/14",

#canel网络策略
作用：控制名称空间与名称空间的网络访问，pod与pod之间的访问等
calico:BGP协议,基于IPIP的遂道
calico只支持iptables,flannel支持iptables和ipvs的。
reference: https://docs.projectcalico.org/getting-started/kubernetes/flannel/flannel
calico数据储存方式：
	Kubernetes API数据存储（推荐）
	etcd数据存储
calico不支持ipvs,只支持iptables。如果开启calico网络策略，请一定将kube-proxy设成ipvs

1. 将kube-proxy设为iptables模式：[root@node2 ~]# kubectl edit configmap kube-proxy -n kube-syste #将mode设为空
2. 逐一启动Kube-proxy的pod:[root@node2 ~]# kubectl delete pods kube-proxy-ctdwx  -n kube-system
3. 检验是否关闭ipvs：[root@node2 ~]# kubectl logs kube-proxy-74rsg -n kube-system | grep ipvs #没有ipvs表明开启了iptables
#设置canal
确保Kubernetes控制器管理器设置了以下标志：
--cluster-cidr=<your-pod-cidr>和--allocate-node-cidrs=true。 #--allocate-node-cidrs=true在kubeadm安装是默认是开启了
1. 下载canal:[root@node1 ~/manifests/addons]# curl https://docs.projectcalico.org/v3.7/manifests/canal.yaml -O
2. [root@node1 ~/manifests/addons]# kubectl apply -f canal.yaml
----如何控制pod间的通信
动作：
	posSelector:pod选择
	Egress:出站方向
	Ingress:进站方向
	policyTypes:设定Egress和Ingress是一起生效还是各自单独生效，当都定义时，而且定义了Ingress规则，但Egress没有定义,则生效的规则是Ingress自定义规则和Egress默认规则。如果不定义任何，则只生效自定义的进出站规则。
[root@k8s-master flannel]# kubectl explain networkpolicy
--定义拒绝某个名称空间下所有pod的入站请求
[root@node1 ~/manifests]# cat ingress-def.yaml 
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
spec:
  podSelector: {}  
  #Ingress:
  #- {}
  policyTypes:
  - Ingress
----podSelector为{}表示选择应用在哪个名称空间下的所有pod
注：Ingress和Egress默认规则：
	1. 在policyTypes中调用了Ingress，但没有自定义Igress规则，则表明拒绝所有。如果在policyTypes中调用了Ingress，且自定义了Igress规则，并且规则为空，则表示允许所有
	2. 在policyTypes中没有调用Ingress，则表明允许所有。
[root@node1 ~/manifests]# kubectl create ns dev
[root@node1 ~/manifests]# kubectl create ns prod
[root@node1 ~/manifests]# kubectl apply -f ingress-def.yaml -n dev
[root@node1 ~/manifests]# kubectl get netpol -n dev
NAME               POD-SELECTOR   AGE
deny-all-ingress   <none>         6s
[root@node1 ~/manifests]# kubectl get pods -n dev -o wide
NAME       READY   STATUS    RESTARTS   AGE   IP           NODE    NOMINATED NODE   READINESS GATES
pod-demo   1/1     Running   0          8s    10.244.2.2   node3   <none>           <none>
[root@node1 ~/manifests]# kubectl get pods -n prod -o wide
NAME       READY   STATUS    RESTARTS   AGE   IP           NODE    NOMINATED NODE   READINESS GATES
pod-demo   1/1     Running   0          14s   10.244.2.3   node3   <none>           <none>
[root@node1 ~/manifests]# curl 10.244.2.3
Hello MyApp | Version: v1 | <a href="hostname.html">Pod Name</a>
[root@node1 ~/manifests]# curl 10.244.2.2 #访问dev下的pod访问不了，因为定义了dev名称空间下只要进程都拒绝
^C
#设置某个名称空间下某个pod的某个端口进站请求放行
[root@node1 ~/manifests]# kubectl label pods pod-demo app=myapp -n dev
[root@node1 ~/manifests]# cat allow-netpol-pod.yaml 
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-myapp-ingress
spec:
  podSelector:
    matchLabels:
      app: myapp
  ingress:
  - from:
    - ipBlock:
        cidr: 10.244.0.0/16
	except:
	- 10.244.1.2/24
    ports:
    - protocol: TCP
      port: 80
[root@node1 ~/manifests]# kubectl apply -f allow-netpol-pod.yaml -n dev
[root@node1 ~/manifests]# curl 10.244.2.2
Hello MyApp | Version: v1 | <a href="hostname.html">Pod Name</a> #又可以访问了
[root@node1 ~/manifests]# curl 10.244.2.2:443 #443访问不了，因为被网络策略挡了，我们并没有旅行443端口
^C

#调试器、预先策略及优先函数
Predicate(预选)-->Priority(优先)-->Select(选择，随机选择需求个数)
对节点进行标签分类：ssd,gpu等
REFERENCE：https://github.com/kubernetes/kubernetes/blob/master/pkg/scheduler/algorithm/predicates/predicates.go
注：选择用什么策略看什么需求调用
----预先策略(不符合一票否决，符合所有才能调度)：
	1. CheckNodeCondition(检查节点是否准备就绪)，默认启用
	2. GeneralPredicates，默认启用
		1. HostName:检查Pod对象是否定义了pods.spec.hostname,并且在调度的节点上检查pod名称是否有同名的pod，无则在此节点运行
		2. PodFitsHostPorts:pods.spec.containers.ports.hostPort，检查pod开放的端口是否能被节点所满足
		3. MatchNodeSelector:pods.spec.nodeSelector，匹配标签的节点进行pod部署
		4. PodFitsResources:检查pod的资源需求是否能被节点所满足
	3. NoDiskConflict：检查pod依赖的存储卷在节点上是否能满足需求;默认启用
	4. PodToleratesNodeTaints:检查pod上的spec.tolerations可容忍的污点是否完全包含节点上的污点，节点后期又加了污点而这个污点不能被pod接收时，也不会驱离pod;默认启用
	5. PodToleratesNodeNoExecuteTaints:节点部署在污点的节点上，节点后期又加了污点而这个污点不能被pod接收时，使用此预先策略则会让已运行的pod驱离此node。默认不启用
	6. CheckNodeLabelPresence:检查指定节点标签是否存在，默认不启用
	7. CheckServiceAffinity:检查service的亲和性，如果新增pod是属于这个service时,是否调并在已经运行在这个service下的pod所在的节点，默认不启用
	8. MaxGCEPDVolumeCountPred：google公有云上支持存储卷的，默认启用
	9. MaxEBSVolumeCountPred:AWS公有云上支持存储卷的，默认启用
	10. MaxAzureDiskVolumeCountPred：微软公有云上支持存储卷的，默认启用
	11. CheckVolumeBinding:检查pvc是否被绑定，默认不启用
	12. NoVolumeZoneConflict:检查给定区域节点上的存储卷是否与pod有冲突，默认不启用
	13. CheckNodeMemoryPressure:检查节点内存资源是否处在压力过大的状态，默认不启用
	14. CheckNodePIDPressure:检查节点的PID是否处在压力过大的状态。默认不启用
	15. CheckNodeDiskPressure:检查节点的磁盘io是否过大
	16. MatchInterPodAffinity:匹配节点是否匹配pod间的亲和性或反亲和性条件。												
----优先函数(每个策略得分相加得分越高的节点则被选取)：
	1. LeastRequisted(最小的需求):(cpu((capacity_sum(requested))*10/capacity)+memory((capacity_sum(requested))*10/capacity))/2  占用率越低的得分越高，默认启用
	2. BalanceResourceAllocation：评估cpu和memeory被占用率越接近越被匹配，使cpu和内存使用率平衡，需跟LeastRequisted策略一起使用，默认启用
	3. NodePreferAvoidPods：优先级很高，根据节点注解信息，默认启用"scheduler.alpha.kubernetes.io/preferAvoidPods"判定,节点上是否有这个注解存在，如果没有则得分为10，权重为10000，如果存在注解时，得分是0，默认启用
	4. TaintToleration:将pod对象的spec.tolerations列表项与节点的taints列表项进行匹配度检查，匹配条目越多，得分越低;，默认启用
	5. SelectorSpreading:对节点进行同一类pod控制器标签选择，节点越没被pod控制器使用则这个节点得分最高，默认启用
	6. InterPodAffinity:在所有node上遍历pod对象的亲和性条目，匹配条目越多的node得分越高，默认启用
	7. MostRequested:跟LeastRequisted相反，不能同时使用，占用率越高的得分越高，默认不启用
	8. NodeLabel:根据node标签来评判，有标签则得分越高，无标签则得分越低，并且跟据标签数量来评判分数。默认不启用
	9. ImageLocality:根据node节点本地中是否有镜像，而且根据已有镜像容量大小来评判得分，镜像容量越大的得分越高，默认不启用
	10. NodeAffinity:节点亲和性，pod中的nodeSelector中匹配到node的标签越多，则得分越高，默认启用。
----选择：选择得分最高的node，当得分一样时则会随机选择一个node		

#kubernetes高级调度方式
高级调度设置机制：
	一、 节点选择器：nodeSelector,nodeName
	二、 节点亲和性调度：Affinity
		1. nodeAffinity：requiredDuringSchedulingIgnoredDuringExecution(node硬亲和性),preferredDuringSchedulingIgnoredDuringExecution(node软亲和性)
		2. podAffinity(pod亲和性)：topologyKey--通过拓扑key来分类哪些节点在一个zone(域)上,其它pod在标签选择器上匹配第一个pod的标签来使所有pod在一个共同的zone(域)上.--也分硬亲和和软亲和
		3. podAntiAffinity(pod反亲和性)：与podAffinity相反，只要其它pod在标签选择器上匹配第一个pod的标签，则第一个pod与其它的pod不会在同一个zone(域)上。--也分硬亲和和软亲和
	三、污点调度
#一、节点选择器
1. nodeName使用：在配置清单中spec字段下使用，nodeName: node1,指定特定节点即可,如果节点名称不存在将会被Pendding
2. nodeSelector使用：
[root@k8s-master scheduler]# cat pod-demo.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: pod-demo
  namespace: default
  labels:
    app: myapp
    tier: frontend
spec:
  containers:
  - name: myapp
    image: nginx:1.14-alpine
    imagePullPolicy: IfNotPresent
  nodeSelector:
    disktype: harddisk 
注：如果配置清单中nodeSelector选定的节点标签现在还没有，这个pod任务将会被Pendding,将不会运行，直至被匹配到节点标签为止
#二、节点亲和性调度
1.1 nodeAffinity硬亲和性
[root@node1 ~/manifests/scheduler]# cat nodeaffinity-require-pod.yaml 
apiVersion: v1
kind: Pod
metadata: 
  name: nodeaffinity-require-pod
  labels: 
    app: myapp
    tier: frontend
spec:
  containers:
  - name: myapp
    image: ikubernetes/myapp:v1
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: zone
            operator: In
            values:
            - foo
            - ba
[root@node1 ~/manifests/scheduler]# kubectl apply -f nodeaffinity-pod.yaml 
[root@node1 ~/manifests/scheduler]# kubectl get pods
NAME           READY   STATUS    RESTARTS   AGE
nodeaffinity-pod   0/1     Pending   0          6s  #因为是requiredDuringSchedulingIgnoredDuringExecution，硬亲和性，所以没有符合节点将会被pendding
1.2 nodeAffinity软亲和性：
[root@node1 ~/manifests/scheduler]# cat nodeaffinity-preferred-pod.yaml 
apiVersion: v1
kind: Pod
metadata: 
  name: nodeaffinity-preferred-pod
  labels: 
    app: myapp
    tier: frontend
spec:
  containers:
  - name: myapp
    image: ikubernetes/myapp:v1
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - preference:
          matchExpressions:
          - key: zone
            operator: In
            values:
            - foo
            - ba
        weight: 60
[root@node1 ~/manifests/scheduler]# kubectl apply -f affinity-preferred-pod.yaml 
[root@node1 ~/manifests/scheduler]# kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
nodeaffinity-preferred-pod   1/1     Running   0          6s
2. podAffinity
----pod硬亲和性，软亲和性也一样配置
[root@node1 ~/manifests/scheduler]# cat podaffinity-require-pod.yaml 
apiVersion: v1
kind: Pod
metadata: 
  name: podaffinity-require-firstpod
  labels: 
    app: myapp
    tier: frontend
spec:
  containers:
  - name: myapp
    image: ikubernetes/myapp:v1
---
apiVersion: v1
kind: Pod
metadata:
  name: podaffinity-require-secondpod
  labels:
    app: db
    tier: db
spec:
  containers:
  - name: busybox
    image: busybox:latest
    imagePullPolicy: IfNotPresent
    command:
    - "/bin/sh"
    - "-c"
    - "sleep 3600"
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:  
      - topologyKey: kubernetes.io/hostname
        labelSelector: 
          matchExpressions: 
          - key: app
            operator: In
            values: 
            - myapp 
[root@node1 ~/manifests/scheduler]# kubectl apply -f podaffinity-require-pod.yaml
[root@node1 ~/manifests/scheduler]# kubectl get pods -o wide
[root@node1 ~/manifests/scheduler]# kubectl get pods -o wide
NAME                            READY   STATUS    RESTARTS   AGE     IP            NODE    NOMINATED NODE   READINESS GATES
podaffinity-require-firstpod    1/1     Running   0          2m23s   10.244.2.10   node3   <none>           <none>
podaffinity-require-secondpod   1/1     Running   0          66s     10.244.2.11   node3   <none>           <none>
3. podAntiAffinity
[root@node1 ~/manifests/scheduler]# kubectl label nodes node2 rack=rack1
[root@node1 ~/manifests/scheduler]# kubectl label nodes node3 rack=rack1
[root@node1 ~/manifests/scheduler]# cat podAntiaffinity-require-pod.yaml
apiVersion: v1
kind: Pod
metadata: 
  name: podaffinity-require-firstpod
  labels: 
    app: myapp
    tier: frontend
spec:
  containers:
  - name: myapp
    image: ikubernetes/myapp:v1
---
apiVersion: v1
kind: Pod
metadata:
  name: podaffinity-require-secondpod
  labels:
    app: db
    tier: db
spec:
  containers:
  - name: busybox
    image: busybox:latest
    imagePullPolicy: IfNotPresent
    command:
    - "/bin/sh"
    - "-c"
    - "sleep 3600"
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - topologyKey: rack
        labelSelector: 
          matchExpressions: 
          - key: app
            operator: In
            values: 
            - myapp 
[root@node1 ~/manifests/scheduler]# kubectl apply -f podAntiaffinity-require-pod.yaml 
[root@node1 ~/manifests/scheduler]# kubectl get pods -o wide #因为是反亲和性，所以第二个pod永远是pendding状态
NAME                            READY   STATUS    RESTARTS   AGE   IP            NODE     NOMINATED NODE   READINESS GATES
podaffinity-require-firstpod    1/1     Running   0          12s   10.244.2.12   node3    <none>           <none>
podaffinity-require-secondpod   0/1     Pending   0          12s   <none>        <none>   <none>           <none>
#三、污点调度
1.节点调度  2. pod调度 3. 污点调度
label(标签)和annotations(注解)所有对象可以使用，污点是只定义在节点上的键值型数据。
	taints是键值形数据，用在节点上，定义污点。
	tolerations是键值形数据,用在pod上，定义容忍度，容忍哪些污点。
taints的effect定义对pod的排斥等级：
	1. NoSchedule:仅影响调度过程，对现存的pod对象不产生影响
	2. NoExecute：既影响调度过程也影响现存的pod对象，不容忍的pod对象将被驱逐
	3. PreferNoSchedule：不能调度到不能容忍的节点上，但是没有节点可用时也可以运行在不能容忍的节点上
注：为什么master节点不能被我们的pod任务所调度上去，因为master节点上有我们不能容忍的污点，而像系统组件flannel、kube-proxy等是因为它们容忍了master节点上的污点node-role.kubernetes.io/master:NoSchedule
例：
1. 给两个节点打上污点
[root@node1 ~]# kubectl taint node node2 node-type=prod:NoSchedule
[root@node1 ~]# kubectl taint node node3 node-type=dev:NoExecute
#----删除污点
#[root@k8s-master metrics]# kubectl taint node node2 node-type-
#[root@k8s-master metrics]# kubectl taint node node3 node-type-
--列出污点
[root@node1 ~/kibana]# cat nodes-taints.tmpl 
{{printf "%-50s %-12s\n" "Node" "Taint"}}
{{- range .items}}
    {{- if $taint := (index .spec "taints") }}
        {{- .metadata.name }}{{ "\t" }}
        {{- range $taint }}
            {{- .key }}={{ .value }}:{{ .effect }}{{ "\t" }}
        {{- end }}
        {{- "\n" }}
    {{- end}}
{{- end}}
[root@node1 ~/kibana]# kubectl get nodes -o go-template-file="./nodes-taints.tmpl"
Node                                               Taint       
node1	node-role.kubernetes.io/master=<no value>:NoSchedule	
node2	node.kubernetes.io/unreachable=<no value>:NoSchedule	node.kubernetes.io/unreachable=<no value>:NoExecute
----容忍node2上的污点
2. [root@node1 ~/manifests/schedule]# cat tains-deployment-pod.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: myapp
      release: canary
  template:
    metadata:
      labels:
        app: myapp
        release: canary
    spec:
      containers:
      - name: myapp-container
        image: ikubernetes/myapp:v2
        imagePullPolicy: IfNotPresent
        ports:
        - name: http
          containerPort: 80
      tolerations:
      - operator: Equal
        key: node-type
        value: prod
        effect: NoSchedule
3. [root@node1 ~/manifests/schedule]# kubectl apply -f tains-deployment-pod.yaml
[root@node1 ~/manifests/schedule]# kubectl get pods -o wide
NAME                                READY   STATUS    RESTARTS   AGE   IP           NODE    NOMINATED NODE   READINESS GATES
myapp-deployment-7975794857-6jfvx   1/1     Running   0          7s    10.244.1.6   node2   <none>           <none>
myapp-deployment-7975794857-c48d6   1/1     Running   0          7s    10.244.1.5   node2   <none>           <none>
----容忍只要有key是node-type并且effect是NoSchedule的污点，显然只有node2满足，因为node3的effect是NoExecute
[root@node1 ~/manifests/schedule]# cat tains-deployment-pod.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: myapp
      release: canary
  template:
    metadata:
      labels:
        app: myapp
        release: canary
    spec:
      containers:
      - name: myapp-container
        image: ikubernetes/myapp:v2
        imagePullPolicy: IfNotPresent
        ports:
        - name: http
          containerPort: 80
      tolerations:
      - operator: Exists
        key: node-type
        value: ""
        effect: NoSchedule
[root@node1 ~/manifests/schedule]# kubectl get pods -o wide
NAME                                READY   STATUS    RESTARTS   AGE     IP           NODE    NOMINATED NODE   READINESS GATES
myapp-deployment-7fdf7c7b48-7x4zp   1/1     Running   0          2m28s   10.244.1.8   node2   <none>           <none>
myapp-deployment-7fdf7c7b48-lkbwf   1/1     Running   0          2m29s   10.244.1.7   node2   <none>           <none>
----容忍只要有key是node-type的污点
[root@node1 ~/manifests/schedule]# cat tains-deployment-pod.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: myapp
      release: canary
  template:
    metadata:
      labels:
        app: myapp
        release: canary
    spec:
      containers:
      - name: myapp-container
        image: ikubernetes/myapp:v2
        imagePullPolicy: IfNotPresent
        ports:
        - name: http
          containerPort: 80
      tolerations:
      - operator: Exists
        key: node-type
        value: ""
        effect:
[root@node1 ~/manifests/schedule]# kubectl get pods -o wide
NAME                                READY   STATUS    RESTARTS   AGE   IP            NODE    NOMINATED NODE   READINESS GATES
myapp-deployment-765c9b575d-26dj5   1/1     Running   0          9s    10.244.2.13   node3   <none>           <none>
myapp-deployment-765c9b575d-ddrfm   1/1     Running   0          8s    10.244.1.9    node2   <none>           <none>

#容器资源需求、资源限制及HeapSter
requests:需求、最低保障;
limits:限制，硬限制的;
CPU:
	1颗逻辑CPU为一核心
	1=1000millicores(毫核)
		500m=0.5CPU
内存:
	E、P、T、G、M、K
	Ei、Pi、Ti……
----资源限制
[root@node1 ~/manifests/metrics]# cat resources-limit-pod.yaml 
apiVersion: v1
kind: Pod
metadata: 
  name: pod-demo
  labels: 
    app: myapp
    tier: frontend
spec:
  containers:
  - name: myapp
    image: ikubernetes/myapp:v1
    resources:
      requests:
        memory: "64Mi"
        cpu: "200m"
      limits:
        memory: "256Mi"
        cpu: "400m"
----QoS:k8s自动配置QoS的
QoS的资源类别：
	1. Guranteed:每个容器同时设置了cpu和内存的requests和limits。而且cpu.limits=cpu.requests,memory.limits=memory.request，优先级最高，优先运行，自动归类为Guranteed
	2. Bustable:至少有一个容器设置了CPU或内存资源的requests属性，就会自动成为Bustable,具有中等优先级，
	3. BestEffort:没有任何一个容器设置了requests或limits属性;最低优先级别
注：QoS类别是自动被归类的，当node上的资源不够用时，先后终止BestEffort-->Bustable-->Guranteed，以占用量与需求量的比例来计算，比例越大的越先被干掉

#heapstar组件：kubectl top命令依赖这个，dashboard有些资源用量显示也依赖heapstar，1.11以前有，1.11及以后正式废弃了
kubelet代理内嵌插件cAdvisor监听在4194端口，负责收集本节点,pod,container的cpu,内存，存储信息，最后发送给HeapSter,HeapSter将收到的数据存储在InfluxDB,达到持久存储目的，Grafana配置InfluxDB为数据源，于是可以愉快展示每一个节点、pod、容器的统计结果了。
指标：k8s系统指标，容器指标，应用指标
注：HeapSter依赖InfluxDB,所以先安装InfluxDB,Grafana做为查看数据的展示平台。部署InfluxDB(持续数据库系统)----InfluxDB配置清单在生产环境中要配置存储卷，例如NFS,GlusterFS等。InfluxDB也要提供Service固定名称访问。

#资源指标API及自定义指标API
#Metrics-server和prometheus替代HeapSter
资源指标：metrics-server(提供kubectl top命令获取信息以及dashboard获取某些资源信息) 
自定义指标：prometheus,k8s-prometheus-adpter(把监控数据转换为指标格式)
#新一代架构：
	1. 核心指标流水线：由kubelet、metrics-server以及由API server提供的api组成;CPU累积使用率、内存实时使用率、Pod的资源占用率及容器的磁盘占用率;
	2. 监控流水线：用于从系统收集各种指标数据并提供终端用户、存储系统以及HPA,它们包含核心指标及许多非核心指标。非核心指标本身不能被k8s所解析，所以有了k8s-prometheus-adpter来负责解析给k8s所认知。
metrics-server:API server（/apis/metrics.k8s.io/v1beta1）
k8s:API server
为了用户无缝调用api server,所以有了聚合器(kube-aggregator)，聚合器下放了所有有关的api server,例如：k8s的api server,metrics-server的api server等。用户只访问聚合器的api即可实现无缝调用所有api server。
#部署Metrics-server
REFERENCE:
安全参考链接：https://aeric.io/post/k8s-metrics-server-installation/
新版本参考链接：https://github.com/kubernetes-incubator/metrics-server/tree/master/deploy/1.8%2B
注：部署metrics-server后要等一会才能获取信息值
#部署prometheus监控
REFERENCE: https://github.com/coreos/kube-prometheus/tree/master/manifests
注：将清单下载下来，先apply里面的setup文件夹下所有yaml文件，再应用所有manifests下yaml文件即可,但这个无法使用持久卷
REFERENCE: https://github.com/jacknotes/linux/tree/master/kubernetes/manifests/addons/monitor/prometheus-storage
注：此链接可以配置持久卷


#HPA：水平pod自动伸缩
3个node负载率为90%，每个pod负载率为60%，最多可运行多少个pod:90%X3/60%
只支核心指标进行弹性缩放，HPA有三个版本：
[root@node1 ~/manifests/monitor/prometheus/k8s-prometheus-adapter]# kubectl api-versions
autoscaling/v1
autoscaling/v2beta1
autoscaling/v2beta2
[root@node1 ~/manifests/monitor/prometheus/k8s-prometheus-adapter] kubectl run myapp --image=ikubernetes/myapp:v1 --replicas=1 --requests='cpu=50m,memory=256Mi' --limits='cpu=50m,memory=256Mi' --labels='app=myapp' --expose --port=80
#当pod的cpu到达60%时开始自动伸缩，最小为1个，最多为8个(也要看系统资源空余率)，命令默认是v1版本控制器,只支持cpu
[root@node1 ~/manifests/monitor/prometheus/k8s-prometheus-adapter]#  kubectl autoscale deployment myapp --min=1 --max=8 --cpu-percent=60 
[root@node1 ~/manifests/monitor/prometheus/k8s-prometheus-adapter]# kubectl get hpa
NAME    REFERENCE          TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
myapp   Deployment/myapp   <unknown>/60%   1         8         0          2s
#hpa V2支持cpu和内存
[root@node1 ~/manifests/monitor/hpa]# cat hpa-v2-demo.yaml 
apiVersion: autoscaling/v2beta1
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa-v2
spec:
  scaleTargetRef: 
    apiVersion: apps/v1
    kind: Deployment
    name: myapp   
  minReplicas: 1
  maxReplicas: 10 
  metrics:
  - type: Resource
    resource:
      name: cpu
      targetAverageUtilization: 55
  - type: Resource
    resource:
      name: memory
      targetAverageValue: 50Mi 
[root@node1 ~/manifests/monitor/hpa]# kubectl apply -f hpa-v2-demo.yaml 
[root@node1 ~/manifests/monitor/hpa]# kubectl patch svc myapp -p '{"spec":{"type":"NodePort"}}'
[root@node1 ~]# yum install -y httpd-tools
[root@node1 ~]# ab -c 1000 -n 50000 http://192.168.15.202:31328/index.html
[root@node1 ~/manifests/monitor/hpa]# kubectl get hpa
NAME           REFERENCE          TARGETS                  MINPODS   MAXPODS   REPLICAS   AGE
myapp-hpa-v2   Deployment/myapp   1515520/50Mi, 100%/55%   1         10        1          8m59s
[root@node1 ~/manifests/monitor/hpa]# kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
myapp-5556cc5bf6-9gcrt   1/1     Running   0          26m
myapp-5556cc5bf6-zj7tr   1/1     Running   0          31s #自动伸缩了一个
#针对pod的metrics请求数来做自动伸缩
[root@node1 ~/manifests/monitor/hpa]# cat hpa-v2-custom.yaml 
apiVersion: apps/v1
kind: Deployment
metadata: 
  name: hpa-custom-deployment
  labels: 
    app: hpa-custom-deployment
  namespace: default
spec:
  replicas: 1
  selector: 
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: ikubernetes/metrics-app
        ports:
        - name: http
          containerPort: 80
---
apiVersion: autoscaling/v2beta1
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa-v2-custom
  namespace: default
spec:
  scaleTargetRef: 
    apiVersion: apps/v1
    kind: Deployment
    name: myapp   
  minReplicas: 1
  maxReplicas: 10 
  metrics:
  - type: Pods
    pods:
      metricName: http_requests
      targetAverageValue: 800m
[root@node1 ~]# ab -c 1000 -n 50000 http://192.168.15.202:31328/

#helm工具
--helm官网：https://hub.kubeapps.com/charts/incubator
无状态：nginx
有状态：tomcat,redis,mysql,etcd..
helm是kubernetes的另外一个项目
helm提供专门的应用程序（chart）:deployment,service,hpa，模块，值文件等打包成一个程序清单，模块和值文件是自定义应用的修改点，开发者需要更改模块，应用值只需要更改值文件。
Chart repository:chart仓库
helm是Tiller的客户端，helm运行在用户的pc上，Tiller是守护进程最好部署在k8s集群内。helm请求部署时先发给tiller,然后由tiler请求给API Server,实现部署pod。
helm在用户pc上从chart repository获取chart后一般存储在用户的家目录下，当用户传入自定义参数给chart部署后就会在k8s集群运行，运行的对象叫release,不叫pod
Helm:
	核心术语：
		1. Chart:一个helm程序包，是配置清单并且解决了依赖关系
		2. Repository:Charts仓库，https/http服务器
		3. Release:特定的Chart部署于目标集群上的一个实例
		Chart -> Config -> Release
	程序架构：
		helm: 客户端，运行在用户pc,管理本地的chart仓库和远端的chart Repository,与Tiller服务器交互，发送chart,实例安装、查询、卸载等操作
		Tiller：服务端，可运行在集群内或集群外，但部署在集群外非常麻烦，多数部署在集群内。接收helm发来的charts与config,合并生成release
1. 安装helm客户端:
注：有linux，windows、OSX的客户端，linux下载即可用。helm初始化时需要使用~/.kube/config文件去跟APIserver进行认证
[root@node1 ~]# axel -n 30 https://get.helm.sh/helm-v3.2.4-linux-amd64.tar.gz
[root@node1 ~]# tar xf helm-v3.2.4-linux-amd64.tar.gz 
[root@node1 ~]# mv linux-amd64/helm /usr/local/bin/
helm常用命令：
	release管理：
		1. install
		2. delete
		3. upgrade/rollback
		4. list
		5. history：查看release的部署历史
		6. status:获取release的状态信息
	chart管理：
		1. create #新建一个chart
		2. fetch  #下载一个chart而且展开
		3. get  #获取一个chart但并展开
		4. inspect #查看底层信息
		5. package ：把本地的chart打包
		6. verify：校验
#---Helm 3移除 Tiller（helm3没有helm2稳定）
Helm 2 是 C/S 架构，主要分为客户端 helm 和服务端 Tiller; 与之前版本相同，Helm 3 同样在 Release 页面提供了预编译好的二进制文件。差别在于原先的二进制包下载下来你会看到 helm 和 tiller 。而 Helm 3 则只有 Helm 的存在了。Tiller 主要用于在 Kubernetes 集群中管理各种应用发布的版本，在 Helm 3 中移除了 Tiller, 版本相关的数据直接存储在了 Kubernetes 中。原先，由于有 RBAC 的存在，我们在开始使用时，必须先创建一个 ServiceAccount 而现在 Helm 的权限与当前的 Kubeconfig 中配置用户的权限相同，非常容易进行控制。
2. 部署chart
官网helm仓库：https://hub.kubeapps.com/
--添加helm仓库
[root@node1 ~/manifests/helm]# helm repo add stable https://kubernetes-charts.storage.googleapis.com/ 
"stable" has been added to your repositories
[root@node1 ~/manifests/helm]#  helm repo add aliyun https://apphub.aliyuncs.com 
"aliyun" has been added to your repositories
[root@node1 ~/manifests/helm]# helm repo list
NAME  	URL                                              
stable	https://kubernetes-charts.storage.googleapis.com/
aliyun	https://apphub.aliyuncs.com  
[root@node1 ~/manifests/helm]# helm search repo aliyun
--安装nginx
[root@node1 ~/manifests/helm]# helm install nginx-server aliyun/nginx
--查看状态 
[root@node1 ~/manifests/helm]# helm status nginx-server
--查看当前helm中有哪些应用
[root@node1 ~/manifests/helm]# helm list
NAME        	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART      	APP VERSION
nginx-server	default  	1       	2020-07-05 16:18:13.062026367 +0800 CST	deployed	nginx-5.1.5	1.16.1  
--卸载nginx
[root@node1 ~/manifests/helm]# helm uninstall nginx-server
#EFK日志收集系统--
elasticsearch-6.8.6
kibana-6.7.0 
fluentd-2.3.2
----注：新版本中kibana，elasticsearch，logstash都保持了同版本
[root@node1 ~/manifests]# kubectl create ns efk
--添加仓库
[root@node1 ~/elasticsearch]# helm repo add azure-stable http://mirror.azure.cn/kubernetes/charts/ 
[root@node1 ~]# helm repo update
----安装elasticsearch
[root@node1 ~]# helm pull azure-stable/elasticsearch --version 1.32.4
[root@node1 ~]# tar xf elasticsearch-1.32.4.tgz 
[root@node1 ~]# cd elasticsearch/
[root@node1 ~/elasticsearch]# ls
Chart.yaml  ci  README.md  templates  values.yaml
[root@node1 ~/elasticsearch]# grep -v '^(\ )+#\|^$' values.yaml
[root@node1 ~/elasticsearch]# grep -Ev '^(\ )+#|^#|^$' values.yaml
cluster:
  name: "elasticsearch-jack"
  xpackEnable: false
  config: {}
  additionalJavaOpts: ""
  bootstrapShellCommand: ""
  env:
    MINIMUM_MASTER_NODES: "2"   #最小2个节点存活才能选出master,生产最小是2，并且节点是sum/2+1
client:
  name: client
  replicas: 2   #生产最小是2
  serviceType: ClusterIP
master:
  name: master
  exposeHttp: false
  replicas: 3     #3个副本，生产应最低3个才能保持高可用
  heapSize: "512m"
  persistence:
    enabled: false   #生产应开启持久化存储
    accessMode: ReadWriteOnce
    name: data
    size: "4Gi"
data:
  name: data
  exposeHttp: false
  replicas: 2     #2个副本，生产应最低2个
  heapSize: "1536m"
  persistence:
    enabled: false
    accessMode: ReadWriteOnce
    name: data
    size: "30Gi"
  readinessProbe:
    httpGet:
      path: /_cluster/health?local=true
      port: 9200
    initialDelaySeconds: 5
[root@node1 ~/elasticsearch]# helm install elasticsearch-jack -f values.yaml --namespace=efk --version=1.32.4 azure-stable/elasticsearch
#----安装fluentd
[root@node1 ~]# helm pull azure-stable/fluentd-elasticsearch --version=2.0.7
[root@node1 ~]# tar xf fluentd-elasticsearch-2.0.7.tgz
[root@node1 ~]# cd fluentd-elasticsearch/
[root@node1 ~/fluentd-elasticsearch]# vim values.yaml  
elasticsearch:
  host: 'els1-elasticsearch-client'  #更改elasticsearch的service接口及端口以进行连接
  port: 9200
tolerations: 
  - key: node-role.kubernetes.io/master  #开启容忍master节点的污点进行部署，否则daemonset控制器也不会部署在master节点上
    operator: Exists
    effect: NoSchedule
[root@node1 ~/fluentd-elasticsearch]# helm install fluentd1 -f values.yaml --namespace=efk --version=2.0.7 azure-stable/fluentd-elasticsearch
#----安装kibana
[root@node1 ~]# helm pull azure-stable/kibana --version=3.2.6
[root@node1 ~]# tar xf kibana-3.2.6.tgz 
[root@node1 ~/kibana]# vim values.yaml 
    elasticsearch.hosts: http://els1-elasticsearch-client:9200 #更改连接elasticsearch地址及端口
service: 
  type: NodePort  #设置为集群端口
[root@node1 ~/kibana]# helm install kibana1 -f values.yaml --namespace=efk --version=3.2.6 azure-stable/kibana

#######helmv2.16.9部署efk
[root@master /kubernetes/manifests/helm]# wget https://get.helm.sh/helm-v2.16.9-linux-amd64.tar.gz
[root@master /kubernetes/manifests/helm]# cat tiller-rbac.yaml 
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
[root@master /kubernetes/manifests/helm]# helm init --service-account tiller
注：会部署一个tiller pod，此时镜像在gcr，所以需要自己手动从别处下载，我这里制作了阿里云镜像docker pull registry.cn-hangzhou.aliyuncs.com/jack-k8s/tiller:v2.16.9
[root@master /kubernetes/manifests/helm]# helm version
Client: &version.Version{SemVer:"v2.16.9", GitCommit:"8ad7037828e5a0fca1009dabe290130da6368e39", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.16.9", GitCommit:"8ad7037828e5a0fca1009dabe290130da6368e39", GitTreeState:"clean"}
[root@master /kubernetes/manifests/helm]# helm repo list
NAME  	URL                                             
stable	https://kubernetes-charts.storage.googleapis.com
local 	http://127.0.0.1:8879/charts 
###部署elasticsearch
[root@master /kubernetes/manifests/helm]# helm search elasticsearch
[root@master /kubernetes/manifests/helm]# helm fetch stable/elasticsearch --version 1.32.5
[root@master /kubernetes/manifests/helm]# vim elasticsearch/values.yaml 
#client:开启NodePort
   name: client
   replicas: 2
   serviceType: NodePort

#master:设置持久卷size和storageClass，需提前准备好动态pv
  persistence:
    enabled: true
    accessMode: ReadWriteOnce
    name: data
    size: "30Gi"
    storageClass: "managed-nfs-storage"
#data:设置持久卷size和storageClass，需提前准备好动态pv
  persistence:
    enabled: true
    accessMode: ReadWriteOnce
    name: data
    size: "50Gi"
    storageClass: "managed-nfs-storage"
[root@master /kubernetes/manifests/helm/elasticsearch]# helm repo update
[root@master /kubernetes/manifests/helm]# kubectl create ns efk
[root@master /kubernetes/manifests/helm/elasticsearch]# helm install -f values.yaml --name elasticsearch stable/elasticsearch --version 1.32.5 --namespace efk
[root@master /kubernetes/manifests/helm/elasticsearch]# helm list 
NAME         	REVISION	UPDATED                 	STATUS  	CHART               	APP VERSION	NAMESPACE
elasticsearch	1       	Wed Jul 29 14:35:01 2020	DEPLOYED	elasticsearch-1.32.5	6.8.6      	default 
[root@master /kubernetes/manifests/helm/elasticsearch]# helm list
NAME         	REVISION	UPDATED                 	STATUS  	CHART               	APP VERSION	NAMESPACE
elasticsearch	1       	Wed Jul 29 14:42:04 2020	DEPLOYED	elasticsearch-1.32.5	6.8.6      	efk   
[root@master /kubernetes/manifests/helm]# kubectl get pvc -n efk
NAME                          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS          AGE
data-elasticsearch-data-0     Bound    pvc-7b2a230b-0dd4-4199-84f6-01859996ca1b   50Gi       RWO            managed-nfs-storage   3m1s
data-elasticsearch-data-1     Bound    pvc-d3d34c44-faa5-4afb-aaed-cca98769e56d   50Gi       RWO            managed-nfs-storage   93s
data-elasticsearch-master-0   Bound    pvc-d191d3ab-e2d5-4f90-99cc-cef17de7bb38   30Gi       RWO            managed-nfs-storage   3m1s
data-elasticsearch-master-1   Bound    pvc-7f3e2081-1114-48b0-a2c3-42181eb3b7e9   30Gi       RWO            managed-nfs-storage   98s
data-elasticsearch-master-2   Bound    pvc-6a6541b0-7f61-427c-acb6-8e9c716a9f88   30Gi       RWO            managed-nfs-storage   59s
[root@master /kubernetes/manifests/helm]# kubectl get pods -n efk
NAME                                    READY   STATUS    RESTARTS   AGE
elasticsearch-client-56b4c6c5b7-92nvt   1/1     Running   0          3m9s
elasticsearch-client-56b4c6c5b7-plbf8   1/1     Running   0          3m9s
elasticsearch-data-0                    1/1     Running   0          3m9s
elasticsearch-data-1                    1/1     Running   0          101s
elasticsearch-master-0                  1/1     Running   0          3m9s
elasticsearch-master-1                  1/1     Running   0          106s
elasticsearch-master-2                  1/1     Running   0          67s
#部署fluentd
[root@master /kubernetes/manifests/helm]# helm fetch stable/fluentd-elasticsearch --version 2.0.7
[root@master /kubernetes/manifests/helm/fluentd-elasticsearch]# vim values.yaml
注：需要指向9200的elasticsearch的service name.并要添加一个容忍度，使fluentd能容易master上的污点
elasticsearch:
  host: 'elasticsearch-client'
  port: 9200
  scheme: 'http'
tolerations: 
  - key: node-role.kubernetes.io/master
    operator: Exists
    effect: NoSchedule
[root@master /kubernetes/manifests/helm/fluentd-elasticsearch]# helm install -f values.yaml --name fluentd stable/fluentd-elasticsearch --version 2.0.7 --namespace efk
[root@master /kubernetes/manifests/helm/fluentd-elasticsearch]# helm list
NAME         	REVISION	UPDATED                 	STATUS  	CHART                         APP VERSION	NAMESPACE
elasticsearch	1       	Wed Jul 29 14:42:04 2020	DEPLOYED	elasticsearch-1.32.5          6.8.6      	efk      
fluentd      	1       	Wed Jul 29 14:56:32 2020	DEPLOYED	fluentd-elasticsearch-2.0.7   2.3.2      	efk 
注：由于fluentd在gcr，所以每台节点需要手动下载镜像：[root@master /kubernetes/manifests]# ./pull.sh gcr.io/google-containers/fluentd-elasticsearch:v2.3.2
[root@master /kubernetes/manifests]# kubectl get pods -n efk -o wide 
NAME                                    READY   STATUS    RESTARTS   AGE     IP            NODE     NOMINATED NODE   READINESS GATES
elasticsearch-client-56b4c6c5b7-92nvt   1/1     Running   0          17m     10.244.1.29   node2    <none>           <none>
elasticsearch-client-56b4c6c5b7-plbf8   1/1     Running   0          17m     10.244.2.23   node1    <none>           <none>
elasticsearch-data-0                    1/1     Running   0          17m     10.244.2.24   node1    <none>           <none>
elasticsearch-data-1                    1/1     Running   0          16m     10.244.1.31   node2    <none>           <none>
elasticsearch-master-0                  1/1     Running   0          17m     10.244.1.30   node2    <none>           <none>
elasticsearch-master-1                  1/1     Running   0          16m     10.244.2.25   node1    <none>           <none>
elasticsearch-master-2                  1/1     Running   0          15m     10.244.1.32   node2    <none>           <none>
fluentd-fluentd-elasticsearch-27jhm     1/1     Running   0          3m24s   10.244.1.33   node2    <none>           <none>
fluentd-fluentd-elasticsearch-8jcxg     1/1     Running   0          3m24s   10.244.2.27   node1    <none>           <none>
fluentd-fluentd-elasticsearch-sv2mj     1/1     Running   0          3m24s   10.244.0.2    master   <none>           <none>
#部署kibana
[root@master /kubernetes/manifests/helm]# helm fetch stable/kibana --version 3.2.7
[root@master /kubernetes/manifests/helm/kibana]# vim values.yaml 
注：设定kibana连接elasticsearch的service名称及端口，以及更改kibana的集群端口类型
    elasticsearch.hosts: http://elasticsearch-client:9200
service:
  type: NodePort
[root@master /kubernetes/manifests/helm/kibana]# helm install -f values.yaml --name kibana stable/kibana --version 3.2.7 --namespace efk
[root@master /kubernetes/manifests/helm/kibana]# helm list
NAME         	REVISION	UPDATED                 	STATUS  	CHART                         APP VERSION	NAMESPACE
elasticsearch	1       	Wed Jul 29 14:42:04 2020	DEPLOYED	elasticsearch-1.32.5          6.8.6      	efk      
fluentd      	1       	Wed Jul 29 14:56:32 2020	DEPLOYED	fluentd-elasticsearch-2.0.7   2.3.2      	efk      
kibana       	1       	Wed Jul 29 15:07:05 2020	DEPLOYED	kibana-3.2.7                  6.7.0      	efk  
注：由于不能下载，所以自己做了个镜像从阿里云下载：
[root@node1 /kubernetes]# docker pull registry.cn-hangzhou.aliyuncs.com/jack-k8s/kibana-oss:6.7.0
[root@node1 /kubernetes]# docker tag registry.cn-hangzhou.aliyuncs.com/jack-k8s/kibana-oss:6.7.0 docker.elastic.co/kibana/kibana-oss:6.7.0
[root@master /kubernetes/manifests/helm/kibana]# kubectl get pods -n efk
NAME                                    READY   STATUS    RESTARTS   AGE
elasticsearch-client-56b4c6c5b7-92nvt   1/1     Running   0          41m
elasticsearch-client-56b4c6c5b7-plbf8   1/1     Running   0          41m
elasticsearch-data-0                    1/1     Running   0          41m
elasticsearch-data-1                    1/1     Running   0          40m
elasticsearch-master-0                  1/1     Running   0          41m
elasticsearch-master-1                  1/1     Running   0          40m
elasticsearch-master-2                  1/1     Running   0          39m
fluentd-fluentd-elasticsearch-27jhm     1/1     Running   0          27m
fluentd-fluentd-elasticsearch-8jcxg     1/1     Running   0          27m
fluentd-fluentd-elasticsearch-sv2mj     1/1     Running   0          27m
kibana-7cbb579679-g7cbm                 1/1     Running   0          16m
[root@master /kubernetes/manifests/helm/kibana]# kubectl get svc -n efk
NAME                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
elasticsearch-client      NodePort    10.102.220.32   <none>        9200:32009/TCP   42m
elasticsearch-discovery   ClusterIP   None            <none>        9300/TCP         42m
kibana                    NodePort    10.106.59.188   <none>        443:32053/TCP    17m


<pre>

#动态PVC--NFS
https://kubernetes.io/docs/concepts/storage/storage-classes/#glusterfs
注：官方插件是不支持NFS动态供给的，但是我们可以用第三方的插件来实现：
GitHub地址：https://github.com/kubernetes-incubator/external-storage/tree/master/nfs-client/deploy
[root@master /kubernetes/manifests/dynamic-pv]# ls
class.yaml  deployment.yaml  rbac.yaml  test-claim.yaml  test-nginx.yaml  test-pod.yaml

[root@master /kubernetes/manifests/dynamic-pv]# for file in class.yaml deployment.yaml rbac.yaml  ; do curl -OL http://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs-client/deploy/$file ; done

[root@master /kubernetes/manifests/dynamic-pv]# cat class.yaml 
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: managed-nfs-storage
provisioner: fuseim.pri/ifs # or choose another name, must match deployment's env PROVISIONER_NAME'
parameters:
  archiveOnDelete: "false"
[root@master /kubernetes/manifests/dynamic-pv]# cat class.yaml 
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: managed-nfs-storage
provisioner: fuseim.pri/ifs # or choose another name, must match deployment's env PROVISIONER_NAME'
parameters:
  archiveOnDelete: "false"

[root@master /kubernetes/manifests/dynamic-pv]# cat rbac.yaml 
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nfs-client-provisioner
  namespace: default
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: nfs-client-provisioner-runner
rules:
  - apiGroups: [""]
    resources: ["persistentvolumes"]
    verbs: ["get", "list", "watch", "create", "delete"]
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list", "watch", "update"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["create", "update", "patch"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: run-nfs-client-provisioner
subjects:
  - kind: ServiceAccount
    name: nfs-client-provisioner
    namespace: default
roleRef:
  kind: ClusterRole
  name: nfs-client-provisioner-runner
  apiGroup: rbac.authorization.k8s.io
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: leader-locking-nfs-client-provisioner
  namespace: default
rules:
  - apiGroups: [""]
    resources: ["endpoints"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: leader-locking-nfs-client-provisioner
  namespace: default
subjects:
  - kind: ServiceAccount
    name: nfs-client-provisioner
    namespace: default
roleRef:
  kind: Role
  name: leader-locking-nfs-client-provisioner
  apiGroup: rbac.authorization.k8s.io

[root@master /kubernetes/manifests/dynamic-pv]# cat deployment.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nfs-client-provisioner
  labels:
    app: nfs-client-provisioner
  namespace: default
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: nfs-client-provisioner
  template:
    metadata:
      labels:
        app: nfs-client-provisioner
    spec:
      serviceAccountName: nfs-client-provisioner
      containers:
        - name: nfs-client-provisioner
          image: quay.io/external_storage/nfs-client-provisioner:latest
          volumeMounts:
            - name: nfs-client-root
              mountPath: /persistentvolumes
          env:
            - name: PROVISIONER_NAME
              value: fuseim.pri/ifs
            - name: NFS_SERVER
              value: 192.168.3.201
            - name: NFS_PATH
              value: /data/dynamicPV
      volumes:
        - name: nfs-client-root
          nfs:
            server: 192.168.3.201
            path: /data/dynamicPV

[root@master /kubernetes/manifests/dynamic-pv]# cat test-claim.yaml 
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: test-claim
  annotations:
    volume.beta.kubernetes.io/storage-class: "managed-nfs-storage"
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Mi

[root@master /kubernetes/manifests/dynamic-pv]# cat test-pod.yaml 
---
kind: Pod
apiVersion: v1
metadata:
  name: test-pod
spec:
  containers:
  - name: test-pod
    image: busybox:1.24
    command:
      - "/bin/sh"
    args:
      - "-c"
      - "touch /mnt/SUCCESS && exit 0 || exit 1"
    volumeMounts:
      - name: nfs-pvc
        mountPath: "/mnt"
  restartPolicy: "Never"
  volumes:
    - name: nfs-pvc
      persistentVolumeClaim:
        claimName: test-claim

[root@master /kubernetes/manifests/dynamic-pv]# cat test-nginx.yaml 
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: web
  type: NodePort
  selector:
    app: nginx
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  selector:
    matchLabels:
      app: nginx
  serviceName: "nginx"
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "managed-nfs-storage"
      resources:
        requests:
          storage: 1Gi
注：当使用kubectl delete -f test-nginx.yaml应用配置清单时，不会删除pvc(不会删除卷申请模板),从而保留pv,即使pv回收策略是Delete也不会被删除，因为pvc没有被删除


</pre>
