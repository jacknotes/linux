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
1. coreDNS, 2. flannal 3. kube-proxy  #这是集群建好后就好的。另外还有两个重要的：1. ingress controller 2. prometheus（监控组件），3. heapstar,4. dashboard

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