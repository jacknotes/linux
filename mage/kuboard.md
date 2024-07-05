
# docker安装kuboard



## 1. 使用内建用户库 


```bash
sudo docker run -d \
  --restart=unless-stopped \
  --name=kuboard \
  -e KUBOARD_ADMIN_DERAULT_PASSWORD='p@ss123.com' \
  -p 10080:80/tcp \
  -p 20081:10081/tcp \
  -e KUBOARD_ENDPOINT="http://kuboard.k8s.hs.com" \
  -e KUBOARD_AGENT_SERVER_TCP_PORT="20081" \
  -v /data/kuboard-data:/data \
  harborrepo.hs.com/ops/kuboard:v3
 

参数注意：
	* 也可以使用镜像 swr.cn-east-2.myhuaweicloud.com/kuboard/kuboard:v3 ，可以更快地完成镜像下载。
	* 请不要使用 127.0.0.1 或者 localhost 作为内网 IP \
	* Kuboard 不需要和 K8S 在同一个网段，Kuboard Agent 甚至可以通过代理访问 Kuboard Server \
  
  
参数解释
	* 建议将此命令保存为一个 shell 脚本，例如 start-kuboard.sh，后续升级 Kuboard 或恢复 Kuboard 时，需要通过此命令了解到最初安装 Kuboard 时所使用的参数；
	* 第 4 行，将 Kuboard Web 端口 80 映射到宿主机的 10080 端口（您可以根据自己的情况选择宿主机的其他端口）；
	* 第 5 行，将 Kuboard Agent Server 的端口 10081/tcp 映射到宿主机的 20081 端口（您可以根据自己的情况选择宿主机的其他端口）；
	* 第 6 行，指定 KUBOARD_ENDPOINT 为 http://内网IP，如果后续修改此参数，需要将已导入的 Kubernetes 集群从 Kuboard 中删除，再重新导入；
	* 第 7 行，指定 KUBOARD_AGENT_SERVER 的端口为 20081，此参数与第 5 行中的宿主机端口应保持一致，修改此参数不会改变容器内监听的端口 10081，例如，如果第 5 行为 -p 30081:10081/tcp 则第 7 行应该修改为 -e KUBOARD_AGENT_SERVER_TCP_PORT="30081"；
	* 第 8 行，将持久化数据 /data 目录映射到宿主机的 /root/kuboard-data 路径，请根据您自己的情况调整宿主机路径；
	* 在启动命令行中增加环境变量 KUBOARD_ADMIN_DERAULT_PASSWORD，可以设置 admin 用户的初始默认密码。默认密码为Kuboard123
```





### 反向代理配置

```bash
# Kuboard Use
map $http_upgrade $connection_upgrade {
        default upgrade;	#http_upgrade如果不为''，connection_upgrade默认为upgrade
        '' close;			#http_upgrade如果为''，connection_upgrade则为close
}


upstream k8s_kuboard {
        server 192.168.13.237:10080;
}

server {
        listen       80;
        server_name kuboard.k8s.hs.com;

        location / {
                proxy_redirect off;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Real-Port $remote_port;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_http_version 1.1;
                proxy_pass  http://k8s_kuboard;
                root   /usr/share/nginx/html;
                index  index.html index.htm;

                error_page   500 502 503 504  /50x.html;
                location = /50x.html {
                        root   /usr/share/nginx/html;
                }
         }

    	location /k8s-ws/ {
    		proxy_pass  http://k8s_kuboard/k8s-ws/;  # 替换成你的 Kuboard IP 地址和端口
    		proxy_http_version 1.1;
    		proxy_pass_header Authorization;
    		proxy_set_header Upgrade "websocket";
    		proxy_set_header Connection "upgrade";
    		proxy_set_header Host $host;
    		proxy_set_header X-Real-IP $remote_addr;
    		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    		# proxy_set_header X-Forwarded-Proto https; # 如果您在反向代理上启用了 HTTPS
    	}

    	location /k8s-proxy/ {
    		proxy_pass  http://k8s_kuboard/k8s-proxy/;  # 替换成你的 Kuboard IP 地址和端口
    		proxy_http_version 1.1;
    		proxy_pass_header Authorization;
    		proxy_set_header Upgrade $http_upgrade;
    		proxy_set_header Connection $connection_upgrade;
    		proxy_set_header Host $host;
    		proxy_set_header X-Real-IP $remote_addr;
    		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    		# proxy_set_header X-Forwarded-Proto https; # 如果您在反向代理上启用了 HTTPS
    		gzip on;
    	}
}
```





### kuboard角色绑定

第一阶段授权

- 新建用户`test`
- 新建用户组`ops`
- 配置用户组`ops`，将用户`test`加入用户组`ops`，并在`角色绑定(集群)`下绑定集群`test-k8s`和kuboard自带角色`sso-user`，因为`sso-user`角色有`act-as-impersonate-user`权限



第二阶段授权

- 进行集群配置页面
- 找到`访问控制` -> `第二阶段授权` -> `用户组` -> `为新Group授权` -> `选择组ops`进行配置
- 进行配置页面后，指定名称空间，按需绑定rolebinding | clusterrolebinding赋予组权限，例如绑定集群角色`clusterrole-homsom-develop`给组ops

```bash
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ops-rolebinding-dzwy8
  namespace: uat-frontend
  resourceVersion: '7309239'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: clusterrole-homsom-develop
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: Group
    name: ops
```
`Role | ClusterRole权限必须有列出名称空间权限，否则用户无法查看指定名称空间，形成`无任何权限`假象`

```bash
- apiGroups:
  - ""
  resources:
  - namespaces
  verbs:
  - get
  - list
  - watch
```
`用户重新登录并刷新页面，权限即可更新`



### 重置admin密码

在 Kuboard 容器的命令行界面中执行` kuboard-admin reset-password `命令



### 创建ServiceAccount额外secret

````bash
## 创建额外的secret 
```bash
root@test-k8s-master:~# kubectl  get sa -n fat-frontend
NAME          SECRETS   AGE
default       1         47d
sa-frontend   1         41d

root@test-k8s-master:/tmp# cat secret.json 
{
    "kind": "Secret",
    "apiVersion": "v1",
    "metadata": {
        "name": "sa-frontend-token-t6xl2",	# 新的secret名称，必须唯一
        "annotations": {
            "kubernetes.io/service-account.name": "sa-frontend"		# 对应的Service Account名称，控制器将为其创建一个新的 token
        }
    },
    "type": "kubernetes.io/service-account-token"
}

root@test-k8s-master:/tmp# kubectl create -f secret.json -n fat-frontend 
root@test-k8s-master:/tmp# kubectl  get secret -n fat-frontend
NAME                      TYPE                                  DATA   AGE
default-token-lsvck       kubernetes.io/service-account-token   3      47d
sa-frontend-token-t6xl2   kubernetes.io/service-account-token   3      7s
sa-frontend-token-t6xlp   kubernetes.io/service-account-token   3      41d

root@test-k8s-master:/tmp# kubectl  describe secret sa-frontend-token-t6xl2 -n fat-frontend
Name:         sa-frontend-token-t6xl2
Namespace:    fat-frontend
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: sa-frontend
              kubernetes.io/service-account.uid: d973dcbf-ca9c-4f6c-a207-18e2c2ba3f75

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1302 bytes
namespace:  12 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6InVQOXEwZkg5d0pTRXFnVUVpTlJmVGZkT0ZBR1BFdjRIa0ZTaXphTWVvS28ifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJmYXQtZnJvbnRlbmQiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoic2EtZnJvbnRlbmQtdG9rZW4tdDZ4bDIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoic2EtZnJvbnRlbmQiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiJkOTczZGNiZi1jYTljLTRmNmMtYTIwNy0xOGUyYzJiYTNmNzUiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6ZmF0LWZyb250ZW5kOnNhLWZyb250ZW5kIn0.M0UTK-7CRD02H6yqWsxlHXabII6pJbD-Fqjcbc2rlPBwODKIPjKaDJijB6D2-ITqFETy-xAGRIWtqlLDrInGpHntQJmPESrTddbCqVx8KcyXd8Ycq02UaAJMYjPueYzts66P7rCZYFjmgnv09C9iMZ5BXo0a1NtUowr5B1qJVOJ7iNUSabZjfJFEnULhTMc5EakGq9qRgiQ66L2JvOKmR-PTZyHynxUQCTJbUyeuAe9QNJINkqwbDkwQD7IIvSitZ0GqXTCsQOQIjTEBL-mnHouwqfOc6yHG3k57rTk8xPEfw-fWG2d1pqoxoZH1FPPBpKD7u5WqnHEVxAFHo2OBMg
```

# 列出kuboard名称空间的所有资源
kubectl api-resources --namespaced=true --verbs=list | grep -v NAME | awk '{print $1}' | xargs | sed 's/ /,/g' | xargs -I {} kubectl get {} -n kuboard 
````





## 2. 使用ldap用户库 

```bash
sudo docker run -d \
  --restart=unless-stopped \
  --name=kuboard \
  -p 10080:80/tcp \
  -p 20081:10081/tcp \
  -e KUBOARD_ENDPOINT="http://kuboard.k8s.hs.com" \
  -e KUBOARD_AGENT_SERVER_TCP_PORT="20081" \
  -v /data/kuboard-data:/data \
  -e KUBOARD_LOGIN_TYPE="ldap" \
  -e KUBOARD_ROOT_USER="user01" \
  -e LDAP_HOST="192.168.10.251:389" \
  -e LDAP_SKIP_SSL_VERIFY="true" \
  -e LDAP_BIND_DN="CN=域管理员,OU=Services,OU=Headquarter,dc=hs,dc=com" \
  -e LDAP_BIND_PASSWORD="password" \
  -e LDAP_BASE_DN="OU=技术研发中心,OU=部门员工,OU=Users,OU=Headquarter,DC=hs,DC=com" \
  -e LDAP_FILTER="(objectClass=user)" \
  -e LDAP_ID_ATTRIBUTE="sAMAccountName" \
  -e LDAP_USER_NAME_ATTRIBUTE="sAMAccountName" \
  -e LDAP_EMAIL_ATTRIBUTE="mail" \
  -e LDAP_DISPLAY_NAME_ATTRIBUTE="displayName" \
  -e LDAP_GROUP_SEARCH_BASE_DN="OU=Roles,OU=Groups,OU=Headquarter,DC=hs,DC=com" \
  -e LDAP_GROUP_SEARCH_FILTER="(objectClass=group)" \
  -e LDAP_USER_MACHER_USER_ATTRIBUTE="memberOf" \
  -e LDAP_USER_MACHER_GROUP_ATTRIBUTE="DistinguishedName" \
  -e LDAP_GROUP_NAME_ATTRIBUTE="name" \
  harborrepo.hs.com/ops/kuboard:v3


LDAP_GROUP_SEARCH_FILTER			#按组搜索
LDAP_USER_MACHER_USER_ATTRIBUTE		#搜索用户memberOf属性
LDAP_USER_MACHER_GROUP_ATTRIBUTE	#搜索组属性
```



### 使用域用户

* 使用域用户登录，此时登录上去会是空的，什么都不能做
* 用管理账号user01进行配置，配置`OU=Roles,OU=Groups,OU=Headquarter,DC=hs,DC=com`下的组，对组进行进行角色绑定，使用户可以查看相应的集群
* 用管理账号user01进行配置，对相应的组进行`第二阶段授权绑定`，使相应的用户有k8s集群相应的权限





### 通过docker控制台增加管理员

```bash
[root@prometheus02 shell]# cat >> kuboard-admin-testuser.yaml < EOF
kind: KuboardAuthGlobalRoleBinding
metadata:
  cluster: GLOBAL
  name: user.tt.administrator
spec:
  subject:
    kind: KuboardAuthUser
    name: testuser
  role:
    name: administrator
EOF
	
[root@prometheus02 shell]# docker cp kuboard-admin-testuser.yaml kuboard:/init-etcd-scripts/
[root@prometheus02 shell]# docker exec kuboard cat /init-etcd-scripts/kuboard-admin-testuser.yaml
kind: KuboardAuthGlobalRoleBinding
metadata:
  cluster: GLOBAL
  name: user.tt.administrator
spec:
  subject:
    kind: KuboardAuthUser
    name: testuser
  role:
    name: administrator
```

此时，使用LDAP的`testuser`用户登录即是管理员，user.tt.administrator中的tt表示名称

![](../image/kuboard/01.png)



![](../image/kuboard/02.png)



`删除自定义管理员`

```bash
docker exec kuboard rm -rf /init-etcd-scripts/kuboard-admin-testuser.yaml
```





## 3. 自定义ClusterRole

```yaml
[root@prometheus kuboard]# cat clusterrole-homsom-ops.yaml 
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: clusterrole-homsom-ops
rules:
- apiGroups:
  - ""
  resources:
  - configmaps
  - endpoints
  - persistentvolumeclaims
  - persistentvolumeclaims/status
  - replicationcontrollers
  - replicationcontrollers/scale
  - serviceaccounts
  - services
  - services/status
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - '*'
  resources:
  - pods
  verbs:
  - get
  - list
  - watch
  - delete
- apiGroups:
  - '*'
  resources:
  - pods/exec
  verbs:
  - get
  - list
  - watch
  - create
  - delete
- apiGroups:
  - ""
  resources:
  - bindings
  - events
  - limitranges
  - namespaces/status
  - pods/log
  - pods/status
  - replicationcontrollers/status
  - resourcequotas
  - resourcequotas/status
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - namespaces
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - discovery.k8s.io
  resources:
  - endpointslices
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - apps
  resources:
  - controllerrevisions
  - daemonsets
  - daemonsets/status
  - deployments
  - deployments/scale
  - deployments/status
  - replicasets
  - replicasets/scale
  - replicasets/status
  - statefulsets
  - statefulsets/scale
  - statefulsets/status
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - autoscaling
  resources:
  - horizontalpodautoscalers
  - horizontalpodautoscalers/status
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - batch
  resources:
  - cronjobs
  - cronjobs/status
  - jobs
  - jobs/status
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - extensions
  resources:
  - daemonsets
  - daemonsets/status
  - deployments
  - deployments/scale
  - deployments/status
  - ingresses
  - ingresses/status
  - networkpolicies
  - replicasets
  - replicasets/scale
  - replicasets/status
  - replicationcontrollers/scale
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - policy
  resources:
  - poddisruptionbudgets
  - poddisruptionbudgets/status
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses
  - ingresses/status
  - networkpolicies
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - metrics.k8s.io
  resources:
  - nodes
  verbs:
  - get
  - list
  - watch
[root@prometheus kuboard]# cat pro-clusterrole-homsom-dev.yaml 
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pro-clusterrole-homsom-dev
rules:
#- apiGroups:
#  - ""
#  resources:
#  - configmaps
#  - endpoints
#  - persistentvolumeclaims
#  - persistentvolumeclaims/status
#  - replicationcontrollers
#  - replicationcontrollers/scale
##  - serviceaccounts
##  - services
##  - services/status
#  verbs:
#  - get
#  - list
#  - watch
- apiGroups:
  - '*'
  resources:
  - pods
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - '*'
  resources:
  - pods/exec
  verbs:
  - get
  - list
  - watch
  - create
  - delete
- apiGroups:
  - ""
  resources:
  - bindings
#  - events
  - limitranges
  - namespaces/status
  - pods/log
  - pods/status
  - replicationcontrollers/status
  - resourcequotas
  - resourcequotas/status
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - namespaces
  verbs:
  - get
  - list
  - watch
##- apiGroups:
##  - discovery.k8s.io
##  resources:
##  - endpointslices
##  verbs:
##  - get
##  - list
##  - watch
- apiGroups:
  - apps
  resources:
  - controllerrevisions
  - daemonsets
  - daemonsets/status
  - deployments
  - deployments/scale
  - deployments/status
  - replicasets
  - replicasets/scale
  - replicasets/status
  - statefulsets
  - statefulsets/scale
  - statefulsets/status
  verbs:
  - get
  - list
  - watch
#- apiGroups:
#  - autoscaling
#  resources:
#  - horizontalpodautoscalers
#  - horizontalpodautoscalers/status
#  verbs:
#  - get
#  - list
#  - watch
- apiGroups:
  - batch
  resources:
  - cronjobs
  - cronjobs/status
  - jobs
  - jobs/status
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - extensions
  resources:
  - daemonsets
  - daemonsets/status
  - deployments
  - deployments/scale
  - deployments/status
  - ingresses
  - ingresses/status
  - networkpolicies
  - replicasets
  - replicasets/scale
  - replicasets/status
  - replicationcontrollers/scale
  verbs:
  - get
  - list
  - watch
#- apiGroups:
#  - policy
#  resources:
#  - poddisruptionbudgets
#  - poddisruptionbudgets/status
#  verbs:
#  - get
#  - list
#  - watch
#- apiGroups:
#  - networking.k8s.io
#  resources:
#  - ingresses
#  - ingresses/status
#  - networkpolicies
#  verbs:
#  - get
#  - list
#  - watch
#- apiGroups:
#  - metrics.k8s.io
#  resources:
#  - nodes
#  verbs:
#  - get
#  - list
#  - watch
[root@prometheus kuboard]# cat test-clusterrole-homsom-dev.yaml 
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: test-clusterrole-homsom-dev
rules:
#- apiGroups:
#  - ""
#  resources:
#  - configmaps
#  - endpoints
#  - persistentvolumeclaims
#  - persistentvolumeclaims/status
#  - replicationcontrollers
#  - replicationcontrollers/scale
##  - serviceaccounts
##  - services
##  - services/status
#  verbs:
#  - get
#  - list
#  - watch
- apiGroups:
  - '*'
  resources:
  - pods
  verbs:
  - get
  - list
  - watch
  - delete
- apiGroups:
  - '*'
  resources:
  - pods/exec
  verbs:
  - get
  - list
  - watch
  - create
  - delete
- apiGroups:
  - ""
  resources:
  - bindings
#  - events
  - limitranges
  - namespaces/status
  - pods/log
  - pods/status
  - replicationcontrollers/status
  - resourcequotas
  - resourcequotas/status
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - namespaces
  verbs:
  - get
  - list
  - watch
##- apiGroups:
##  - discovery.k8s.io
##  resources:
##  - endpointslices
##  verbs:
##  - get
##  - list
##  - watch
- apiGroups:
  - apps
  resources:
  - controllerrevisions
  - daemonsets
  - daemonsets/status
  - deployments
  - deployments/scale
  - deployments/status
  - replicasets
  - replicasets/scale
  - replicasets/status
  - statefulsets
  - statefulsets/scale
  - statefulsets/status
  verbs:
  - get
  - list
  - watch
#- apiGroups:
#  - autoscaling
#  resources:
#  - horizontalpodautoscalers
#  - horizontalpodautoscalers/status
#  verbs:
#  - get
#  - list
#  - watch
- apiGroups:
  - batch
  resources:
  - cronjobs
  - cronjobs/status
  - jobs
  - jobs/status
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - extensions
  resources:
  - daemonsets
  - daemonsets/status
  - deployments
  - deployments/scale
  - deployments/status
  - ingresses
  - ingresses/status
  - networkpolicies
  - replicasets
  - replicasets/scale
  - replicasets/status
  - replicationcontrollers/scale
  verbs:
  - get
  - list
  - watch
#- apiGroups:
#  - policy
#  resources:
#  - poddisruptionbudgets
#  - poddisruptionbudgets/status
#  verbs:
#  - get
#  - list
#  - watch
#- apiGroups:
#  - networking.k8s.io
#  resources:
#  - ingresses
#  - ingresses/status
#  - networkpolicies
#  verbs:
#  - get
#  - list
#  - watch
#- apiGroups:
#  - metrics.k8s.io
#  resources:
#  - nodes
#  verbs:
#  - get
#  - list
#  - watch
```





## 4. k8s部署kuboard



```bash
root@ansible:~/k8s/addons/kuboard# kubectl label node 192.168.13.63 app=kuboard
root@ansible:~/k8s/addons/kuboard# kubectl get nodes -l app=kuboard
NAME            STATUS   ROLES   AGE    VERSION
192.168.13.63   Ready    node    667d   v1.23.7

```





```yaml
root@ansible:~/k8s/addons/kuboard# cat kuboard.yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: kuboard
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kuboard-boostrap
  namespace: kuboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kuboard-boostrap-crb
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: kuboard-boostrap
  namespace: kuboard
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: kuboard-v3-config
  namespace: kuboard
data:
  KUBOARD_ENDPOINT: 'http://kuboard.test.k8s.hs.com'
  KUBOARD_AGENT_SERVER_UDP_PORT: '30081'
  KUBOARD_AGENT_SERVER_TCP_PORT: '30081'
  KUBOARD_SERVER_LOGRUS_LEVEL: info
  KUBOARD_AGENT_KEY: 32b7d6572c6255211b4eec9009e4a816
  KUBOARD_AGENT_IMAG: harborrepo.hs.com/ops/kuboard-agent:v3
  KUBOARD_QUESTDB_IMAGE: harborrepo.hs.com/ops/questdb:6.0.4
  KUBOARD_DISABLE_AUDIT: 'false'
  KUBOARD_ADMIN_DERAULT_PASSWORD: 'p@ss123.com'
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: kuboard-etcd
  namespace: kuboard
  labels:
    app: kuboard-etcd
spec:
  serviceName: kuboard-etcd
  replicas: 3
  selector:
    matchLabels:
      app: kuboard-etcd
  template:
    metadata:
      name: kuboard-etcd
      labels:
        app: kuboard-etcd
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: kubernetes.io/role
                    operator: In
                    values:
                    - master
      containers:
      - name: kuboard-etcd
        image: harborrepo.hs.com/ops/etcd-host:3.4.16-1
        ports:
        - containerPort: 2379
          name: client
        - containerPort: 2380
          name: peer
        env:
        - name: KUBOARD_ETCD_ENDPOINTS
          value: >-
            kuboard-etcd-0.kuboard-etcd:2379,kuboard-etcd-1.kuboard-etcd:2379,kuboard-etcd-2.kuboard-etcd:2379
        volumeMounts:
        - name: data
          mountPath: /data
        command:
          - /bin/sh
          - -c
          - |
            PEERS="kuboard-etcd-0=http://kuboard-etcd-0.kuboard-etcd:2380,kuboard-etcd-1=http://kuboard-etcd-1.kuboard-etcd:2380,kuboard-etcd-2=http://kuboard-etcd-2.kuboard-etcd:2380"
            exec etcd --name ${HOSTNAME} \
              --listen-peer-urls http://0.0.0.0:2380 \
              --listen-client-urls http://0.0.0.0:2379 \
              --advertise-client-urls http://${HOSTNAME}.kuboard-etcd:2379 \
              --initial-advertise-peer-urls http://${HOSTNAME}:2380 \
              --initial-cluster-token kuboard-etcd-cluster-1 \
              --initial-cluster ${PEERS} \
              --initial-cluster-state new \
              --data-dir /data/kuboard.etcd
      volumes:
        - hostPath:
            path: /usr/share/kuboard/etcd
          name: data
      serviceAccount: kuboard-boostrap
      serviceAccountName: kuboard-boostrap
      tolerations:
        - key: node.kubernetes.io/unschedulable
          operator: Exists
---
apiVersion: v1
kind: Service
metadata:
  name: kuboard-etcd
  namespace: kuboard
spec:
  #type: ClusterIP
  type: NodePort
  ports:
  - port: 2379
    name: client
    nodePort: 32379
  - port: 2380
    name: peer
  selector:
    app: kuboard-etcd
---
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    app: kuboard-v3
  labels:
    app: kuboard-v3
  name: kuboard-v3
  namespace: kuboard
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kuboard-v3
  template:
    metadata:
      labels:
        app: kuboard-v3
    spec:
      nodeSelector:
        app: kuboard
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: kubernetes.io/role
                    operator: In
                    values:
                    - master
                    - node
      containers:
        - env:
          - name: KUBOARD_ETCD_ENDPOINTS
            value: kuboard-etcd-0.kuboard-etcd:2379,kuboard-etcd-1.kuboard-etcd:2379,kuboard-etcd-2.kuboard-etcd:2379
          envFrom:
            - configMapRef:
                name: kuboard-v3-config
          image: 'harborrepo.hs.com/ops/kuboard:v3'
          imagePullPolicy: IfNotPresent
          name: kuboard
          livenessProbe:
            failureThreshold: 3
            httpGet:
              path: /kuboard-resources/version.json
              port: 80
              scheme: HTTP
            initialDelaySeconds: 30
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 1
          ports:
            - containerPort: 80
              name: web
              protocol: TCP
            - containerPort: 443
              name: https
              protocol: TCP
            - containerPort: 10081
              name: peer
              protocol: TCP
            - containerPort: 10081
              name: peer-u
              protocol: UDP
          readinessProbe:
            failureThreshold: 3
            httpGet:
              path: /kuboard-resources/version.json
              port: 80
              scheme: HTTP
            initialDelaySeconds: 30
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 1
          volumeMounts:
          - name: kuboard-data
            mountPath: /data
          resources: {}
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      serviceAccount: kuboard-boostrap
      serviceAccountName: kuboard-boostrap
      tolerations:
        - key: node.kubernetes.io/unschedulable
          operator: Exists
      volumes:
      - name: kuboard-data
        hostPath:
          path: /data/kuboard-data
          type: DirectoryOrCreate
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: kuboard-v3
  name: kuboard-v3
  namespace: kuboard
spec:
  ports:
    - name: webui
      nodePort: 30180
      port: 80
      protocol: TCP
      targetPort: 80
    - name: agentservertcp
      nodePort: 30181
      port: 10081
      protocol: TCP
      targetPort: 10081
    - name: agentserverudp
      nodePort: 30181
      port: 10081
      protocol: UDP
      targetPort: 10081
  selector:
    app: kuboard-v3
  sessionAffinity: None
  type: NodePort
```

```bash
root@ansible:~/k8s/addons/kuboard# kubectl get pods -o wide -n kuboard
NAME                         READY   STATUS    RESTARTS      AGE     IP               NODE            NOMINATED NODE   READINESS GATES
kuboard-etcd-0               1/1     Running   2 (23m ago)   60d     172.20.0.2       172.168.2.23    <none>           <none>
kuboard-etcd-1               1/1     Running   0             138d    172.20.122.153   172.168.2.22    <none>           <none>
kuboard-etcd-2               1/1     Running   1 (28m ago)   138d    172.20.32.143    172.168.2.21    <none>           <none>
kuboard-v3-c7f6cb9b6-4qdrh   1/1     Running   0             2m19s   172.20.217.93    192.168.13.63   <none>           <none>



root@ansible:~/k8s/addons/kuboard# kubectl get svc -n kuboard
NAME           TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)                                        AGE
kuboard-etcd   NodePort   10.68.161.169   <none>        2379:32379/TCP,2380:41304/TCP                  3m3s
kuboard-v3     NodePort   10.68.241.184   <none>        80:30180/TCP,10081:30181/TCP,10081:30181/UDP   2m59s


# 用户访问 NODE_IP:30180 即可访问kuboard


# 上面是测试所以暴露ETCD端口，否则不要暴露
root@ansible:~/k8s/addons/kuboard# etcdctl get / --prefix --keys-only --endpoints=172.168.2.21:32379
/kind/KuboardAuditPolicy/cluster/GLOBAL/GLOBAL

/kind/KuboardAuthGlobalRoleBinding/cluster/GLOBAL/group.administrators.administrator

/kind/KuboardAuthGroup/cluster/GLOBAL/administrators

/kind/KuboardAuthRole/cluster/GLOBAL/administrator

/kind/KuboardAuthRole/cluster/GLOBAL/anonymous

/kind/KuboardAuthRole/cluster/GLOBAL/authenticated

/kind/KuboardAuthRole/cluster/GLOBAL/sso-user

/kind/KuboardAuthRole/cluster/GLOBAL/viewer

/kind/KuboardAuthUser/cluster/GLOBAL/admin

/kind/KuboardAuthUserInGroup/cluster/GLOBAL/admin.administrators

/kind/KuboardBrandSettings/cluster/GLOBAL/KuboardBrandSettings

/kind/KuboardLoginPolicySettings/cluster/GLOBAL/KuboardLoginPolicySettings

```

