# 部署预生产环境

服务器：
* DNS服务器			1台			IP: 192.168.13.199
* nginx				1台			IP: 192.168.13.208
* webserver集群		3台			IP: 192.168.13.203,192.168.13.227,192.168.13.231
* k8s集群			3台			IP: 192.168.13.90,192.168.13.91,192.168.13.92(单master集群)



## 安装部署DNS



### 安装DNS服务

1. 安装Windows Server 2008R2系统，并安装DNS角色。
2. 配置DNS服务器网络信息，DNS地址指向本机：127.0.0.1



### 备份DNS配置

```powershell
<#
前提：
  1.该脚本需要模块DnsServer
  2.执行脚本的主机与DNS服务器保持网络连接
  3.执行脚本的用户需要在远程DNS服务器上有相应权限
使用方式：
  利用任务计划程序来调用脚本，参数：-File <脚本文件路径> -ComputerName <远程DNS服务器FQDN> -ErrorAction SilentlyContinue
结果：
  1.脚本执行后，会在远程DNS服务器上的DNS目录（默认为：c:\windows\system32\dns）生成DNS区域的备份文件（AD类型）
  2.每天每个区域只能有一个文件，之后的同名文件会创建失败
恢复DNS区域：
  1.将备份文件复制到DNS服务器上的DNS目录（默认为：c:\windows\system32\dns）
  2.执行命令：dnscmd <远程DNS服务器FQDN> /ZoneAdd <ZoneName> /Primary /file <备份的区域文件名> /load
  3.打开DNS服务器管理器，将相应区域的类型更改为：Active Directory 集成区域，动态类型更改为：安全
  4.如果是非域环境，第3步可不做
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$ComputerName
)

$Prefix = "Dns - " + (Get-Date -Format "yyyyMMdd") + " - " 
$Suffix = ".bak"
#$Zones = Get-DnsServerZone -ComputerName $ComputerName
$Zones = (Get-WmiObject -Namespace root\MicrosoftDNS -Class MicrosoftDNS_Zone -ComputerName $ComputerName).Name

foreach($zone in $Zones){
    #$zonename = $zone.ZoneName
    $zonename = $zone
    if ($zonename -eq "TrustAnchors"){
        #$zonename = "_msdcs.hs.com"
    }
    $filename = $Prefix + $zonename + $Suffix
    #Export-DnsServerZone -FileName $filename -Name $zonename -ComputerName $ComputerName
    dnscmd $ComputerName /ZoneExport $zonename $filename
}
```



### 恢复DNS配置

1. 复制备份的DNS到本机存放
2. 更改需要恢复的DNS配置文件，使用notepad++软件打开，批量替换192.168.13.207为192.168.13.208
3. 使用Powershell进行恢复到本机DNS

```Powershell
# ad域对象需要使用_msdcs.hs.com下的dc/domains/gc/pdc下面的域解析，否则指向新的DNS无法登录域
dnscmd srv-pre-dns /zoneadd _msdcs.hs.com /primary /file "Dns - 20230515 - _msdcs.hs.com.bak" /load
  
# 恢复步骤：可以用notepad++打开"Dns - 20230515 - hs.com.bak"，把192.168.13.207批量替换为192.168.13.208
dnscmd srv-pre-dns /zoneadd hs.com /primary /file "Dns - 20230515 - hs.com.bak" /load
```



### 测试DNS服务器

1. 使用ping命令进行测试解析
2. 部署新的win10操作系统，DNS指向DNS地址：192.168.13.199，进行加域测试、域名解析测试。





## 安装部署nginx

1. 初始化Centos7系统环境，/etc/resolv.conf中DNS地址为预生产环境DNS: 192.168.13.199
2. 安装tengine，跟生产环境nginx配置一样
3. 复制生产环境nginx.conf以及其它*.conf配置文件到此nginx配置目录下，并将upstream server中的webserver集群地址替换为IP: 192.168.13.203,192.168.13.227,192.168.13.231、k8s集群地址替换为192.168.13.90,192.168.13.91,192.168.13.92
4. 重载nginx服务





## 安装部署WebServer集群



### 192.168.13.203 WebServer部署

1. 备份192.168.13.204Webserver IIS配置
2. 安装 192.168.13.203操作系统，为Windows Server 2008R2 Enterprise
3. 安装IIS角色
4. 安装.NetFramwork 4.6.1 
5. 恢复IIS配置
6. 复制192.168.13.204站点目录数据到192.168.13.203
7. 配置站点目录权限等其它权限
8. 测试IIS服务是否跟192.168.13.204一样，一定要保持一致
9. 此服务器不可以克隆，经过测试会有问题
注：备份恢复步骤详见githbu.com/jacknotes/windows/notebook/IISBackupRestore.md



### 192.168.13.227 WebServer部署

方法1：
1. 克隆192.168.13.228
2. 执行以下命令更新UUID
C:\Windows\System32\Sysprep 
Sysprep /generalize /oobe /shutdown
3. 测试IIS服务是否跟192.168.13.228一样，一定要保持一致
4. 此服务器可以克隆，经过测试无问题

方法2：
1. 备份192.168.13.228 Webserver IIS配置
2. 安装 192.168.13.227操作系统，为Windows Server 2012R2 Datacenter
3. 安装IIS角色
4. 安装IIS URL重写模块
5. 恢复IIS配置
6. 复制192.168.13.228站点目录数据到192.168.13.227
7. 配置站点目录权限等其它权限
8. 测试IIS服务是否跟192.168.13.228一样，一定要保持一致
注：备份恢复步骤详见githbu.com/jacknotes/windows/notebook/IISBackupRestore.md



### 192.168.13.231 WebServer部署

方法1：
1. 克隆192.168.13.232
2. 执行以下命令更新UUID
C:\Windows\System32\Sysprep 
Sysprep /generalize /oobe /shutdown
3. 测试IIS服务是否跟192.168.13.232一样，一定要保持一致
4. 此服务器可以克隆，经过测试无问题

方法2：
1. 备份192.168.13.232Webserver IIS配置
2. 安装 192.168.13.231操作系统，为Windows Server 2008R2 Enterprise
3. 安装IIS角色
4. 安装.NetFramwork 4.6.1 
5. 恢复IIS配置
6. 复制192.168.13.232站点目录数据到192.168.13.231
7. 配置站点目录权限等其它权限
8. 测试IIS服务是否跟192.168.13.232一样，一定要保持一致
注：备份恢复步骤详见githbu.com/jacknotes/windows/notebook/IISBackupRestore.md





## 安装部署k8s集群



### 安装操作系统

1. master和node节点的操作系统为18.04.5
2. 配置网络信息和主机名等信息
3. 将网卡名称由"ens开头"更改为"eth开头"格式
4. 被ansible管理
```bash
[root@prometheus ~]# ansible '~192.168.13.9[0-9]' -m shell -a "hostname; cat /etc/os-release | grep 'PRETTY_NAME'; ip a s | grep eth"
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see details
192.168.13.90 | CHANGED | rc=0 >>
pre-pro-k8s-master01
PRETTY_NAME="Ubuntu 18.04.5 LTS"
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:50:56:84:be:4c brd ff:ff:ff:ff:ff:ff
    inet 192.168.13.90/24 brd 192.168.13.255 scope global eth0
192.168.13.91 | CHANGED | rc=0 >>
pre-pro-k8s-node01
PRETTY_NAME="Ubuntu 18.04.5 LTS"
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:50:56:84:63:0b brd ff:ff:ff:ff:ff:ff
    inet 192.168.13.91/24 brd 192.168.13.255 scope global eth0
192.168.13.92 | CHANGED | rc=0 >>
pre-pro-k8s-node02
PRETTY_NAME="Ubuntu 18.04.5 LTS"
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:50:56:84:fc:37 brd ff:ff:ff:ff:ff:ff
    inet 192.168.13.92/24 brd 192.168.13.255 scope global eth0
```

4. 更新ubuntu操作系统
```bash
[root@prometheus ~]# ansible '~192.168.13.9[0-9]' -m shell -a "apt upgrade -y"
[root@prometheus ~]# ansible '~192.168.13.9[0-9]' -m shell -a "reboot"
[root@prometheus ~]# ansible '~192.168.13.9[0-9]' -m shell -a "cat /etc/os-release | grep 'PRETTY_NAME';"
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see details
192.168.13.91 | CHANGED | rc=0 >>
PRETTY_NAME="Ubuntu 18.04.6 LTS"
192.168.13.90 | CHANGED | rc=0 >>
PRETTY_NAME="Ubuntu 18.04.6 LTS"
192.168.13.92 | CHANGED | rc=0 >>
PRETTY_NAME="Ubuntu 18.04.6 LTS"
```

5. 使用ansible初始化k8s节点系统配置
[root@prometheus roles]# ansible-playbook /etc/ansible/playbook/base.yml



### 安装部署k8s集群

```bash
ezctl setup k8s-pre-pro 01
ezctl setup k8s-pre-pro 02
ezctl setup k8s-pre-pro 03
ezctl setup k8s-pre-pro 04
ezctl setup k8s-pre-pro 05
ezctl setup k8s-pre-pro 06
[root@prometheus prometheus]# kubectl get nodes
NAME            STATUS                     ROLES    AGE     VERSION
192.168.13.90   Ready,SchedulingDisabled   master   2d19h   v1.23.7
192.168.13.91   Ready                      node     2d19h   v1.23.7
192.168.13.92   Ready                      node     2d19h   v1.23.7
```



### 部署coredns

```bash
kubectl apply -f 01-coredns.yaml
[root@prometheus prometheus]# kubectl get svc/kube-dns -o wide -n kube-system
NAME       TYPE       CLUSTER-IP   EXTERNAL-IP   PORT(S)                                    AGE     SELECTOR
kube-dns   NodePort   10.68.0.2    <none>        53:34982/UDP,53:34982/TCP,9153:30000/TCP   2d18h   k8s-app=kube-dns
[root@prometheus ~]# kubectl exec -it net-test1 -- nslookup passport.hs.com
Server:		10.68.0.2
Address:	10.68.0.2:53

Name:	passport.hs.com
Address: 192.168.13.208

```



### 部署dashboard

```bash
kubectl apply -f 02-dashboard.yaml
kubectl apply -f 03-dashboard-rbac-admin-user.yaml
[root@prometheus prometheus]# kubectl get svc/kubernetes-dashboard -o wide -n kubernetes-dashboard
NAME                   TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)         AGE     SELECTOR
kubernetes-dashboard   NodePort   10.68.176.205   <none>        443:30001/TCP   2d18h   k8s-app=kubernetes-dashboard
```



### 部署metrics-server

```bash
kubectl apply -f 04-metrics-server.yaml
[root@prometheus prometheus]# kubectl get svc/metrics-server -o wide -n kube-system
NAME             TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE     SELECTOR
metrics-server   ClusterIP   10.68.31.167   <none>        443/TCP   2d18h   k8s-app=metrics-server
[root@prometheus prometheus]# kubectl top nodes
NAME            CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
192.168.13.90   226m         2%     2147Mi          13%       
192.168.13.91   185m         0%     1769Mi          5%        
192.168.13.92   203m         0%     1757Mi          5%        
```





### RBAC授权

#### 生成kubeconfig

```bash
[root@prometheus homsom-ssl]# cat Jack-csr.json 
{
  "CN": "Jack",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Shanghai",
      "L": "Shanghai",
      "O": "homsom:ops",
      "OU": "System"
    }
  ]
}


[root@prometheus homsom-ssl]# cat kubeconfig-gaterate.sh 
#!/bin/sh

if [ -z $1 ];then
	echo $"Usage: $0 Jack-csr.json"
	exit 10
fi

CSR_JSON_FILENAME=`basename $1`
RESULT=`echo "${CSR_JSON_FILENAME}" | grep '\-csr.json' >& /dev/null && echo 0 || echo 1`

if [ ${RESULT} == '0' ];then
	USER=`echo "${CSR_JSON_FILENAME}" | awk -F '-' '{print $1}'`
else
	echo $" \$1 format == './\$\{user\}-csr.json' "
	exit 10
fi


CLUSTER='k8s-pre-pro'
APISERVER='https://192.168.13.90:6443'
DEFAULT_NAMESPACE='default'


cfssl gencert -ca=/etc/kubeasz/clusters/${CLUSTER}/ssl/ca.pem  -ca-key=/etc/kubeasz/clusters/${CLUSTER}/ssl/ca-key.pem -config=/etc/kubeasz/clusters/${CLUSTER}/ssl/ca-config.json -profile=kubernetes ${CSR_JSON_FILENAME} | cfssljson -bare ${USER} && \
	sleep 1 && \
	kubectl config set-cluster ${CLUSTER} --certificate-authority=/etc/kubeasz/clusters/${CLUSTER}/ssl/ca.pem --embed-certs=true --server=${APISERVER} --kubeconfig=${USER}.kubeconfig && \
	kubectl config set-credentials ${USER} --client-certificate=/etc/kubeasz/clusters/${CLUSTER}/ssl/homsom-ssl/${USER}.pem --client-key=/etc/kubeasz/clusters/${CLUSTER}/ssl/homsom-ssl/${USER}-key.pem --embed-certs=true --kubeconfig=${USER}.kubeconfig && \
	kubectl config set-context ${CLUSTER}-context --cluster=${CLUSTER} --user=${USER} --namespace=${DEFAULT_NAMESPACE} --kubeconfig=${USER}.kubeconfig && \
	kubectl config use-context ${CLUSTER}-context --kubeconfig=${USER}.kubeconfig && \
	echo "[INFO] generate kubeconfig for ${USER}.kubeconfig successful!" || echo "[ERROE] generate kubeconfig for ${USER}.kubeconfig failure!"

[root@prometheus homsom-ssl]# ./kubeconfig-gaterate.sh ./Jack-csr.json 
```



#### 授权kubeconfig

```bash
[root@prometheus rbac]# ezctl checkout k8s-pre-pro
2023-05-24 11:49:36 INFO set default kubeconfig: cluster k8s-pre-pro (current)
[root@prometheus rbac]# kubectl get nodes
NAME            STATUS                     ROLES    AGE     VERSION
192.168.13.90   Ready,SchedulingDisabled   master   4d20h   v1.23.7
192.168.13.91   Ready                      node     4d20h   v1.23.7
192.168.13.92   Ready                      node     4d20h   v1.23.7

[root@prometheus rbac]# cat jack-cluster-ua.yaml 
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: clusterrolebinding-jack-ua-admin
subjects:
- kind: User 
  name: Jack
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
---
[root@prometheus rbac]# kubectl apply -f jack-cluster-ua.yaml
clusterrolebinding.rbac.authorization.k8s.io/clusterrolebinding-jack-ua-admin created

```



#### 授权sa集群权限

```bash
[root@prometheus rbac]# cat jack-admin-sa.yaml 
apiVersion: v1
kind: ServiceAccount
metadata:
  name: sa-jack-admin
  namespace: kube-system
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: clusterrolebinding-jack-admin
subjects:
- kind: ServiceAccount
  name: sa-jack-admin
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
---
[root@prometheus rbac]# kubectl apply -f jack-admin-sa.yaml
serviceaccount/sa-jack-admin created
clusterrolebinding.rbac.authorization.k8s.io/clusterrolebinding-jack-admin created
```



#### sa集群权限合并至kubeconfig

```bash
[root@prometheus rbac]# kubectl get sa -n kube-system sa-jack-admin
NAME            SECRETS   AGE
sa-jack-admin   1         81s
[root@prometheus rbac]# kubectl describe sa -n kube-system sa-jack-admin
Name:                sa-jack-admin
Namespace:           kube-system
Labels:              <none>
Annotations:         <none>
Image pull secrets:  <none>
Mountable secrets:   sa-jack-admin-token-tl4w6
Tokens:              sa-jack-admin-token-tl4w6
Events:              <none>

[root@prometheus rbac]# kubectl describe secret -n kube-system sa-jack-admin-token-tl4w6
Name:         sa-jack-admin-token-tl4w6
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: sa-jack-admin
              kubernetes.io/service-account.uid: 10465f8b-961e-48b6-bc9a-5a1c4602b788

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1302 bytes
namespace:  11 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6ImZEcVVHSGxYZnpfby01UXc2WFBER19xSm5YaE5RYnlfblNUV2VxZU5JaEEifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJzYS1qYWNrLWFkbWluLXRva2VuLXRsNHc2Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6InNhLWphY2stYWRtaW4iLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiIxMDQ2NWY4Yi05NjFlLTQ4YjYtYmM5YS01YTFjNDYwMmI3ODgiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZS1zeXN0ZW06c2EtamFjay1hZG1pbiJ9.oW6z7KoqIY1uVyCqe9VOjUNHUgJLRZYtq8YgFEOw39m4JV4aZeG-MBQ3hhhTozmPmIhmx31zLsSdH2dplABnuA6Qpf5keQys-


[root@prometheus rbac]# cat jack.kubeconfig
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURsRENDQW55Z0F3SUJBZ0lVV0pZc09UaXRMUlB4ZFFiVUN3QjU3ckpOcU1Nd0RRWUpLb1pJaHZjTkFRRUwKQlFBd1lURUxNQWtHQTFVRUJoTUNRMDR4RVRBUEJnTlZCQWdUQ0VoaGJtZGFhRzkxTVFzd0NRWURWUVFIRXdKWQpVekVNTUFvR0ExVUVDaE1EYXpoek1ROHdEUVlEVlFRTEV3WlRlWE4wWlcweEV6QVJCZ05WQkFNVENtdDFZbVZ5CmJtVjBaWE13SUJjTk1qTXdOVEU1TURZeU9UQXdXaGdQTWpFeU16QTBNalV3TmpJNU1EQmFNR0V4Q3pBSkJnTlYKQkFZVEFrTk9NUkV3RHdZRFZRUUlFd2hJWVc1bldtaHZkVEVMTUFrR0ExVUVCeE1DV0ZNeEREQUtCZ05WQkFvVApBMnM0Y3pFUE1BMEdBMVVFQ3hNR1UzbHpkR1Z0TVJNd0VRWURWUVFERXdwcmRXSmxjbTVsZEdWek1JSUJJakFOCkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQXZBMDdtN1hVQTRWTU9wb0RUZ21XSlpmZUFDdUwKSVQzU1pkTjQ5K0xjVk5meVBUdUdmRzVkZHFTY3BnWitpRG5VRVZCUzh1MDFsMDNUdGJoWVJSQmxwNHZkT3JJTQpNZmcwOUhrWHo5SGJMVXBtMUkzWVBaMkV6TUg2ZEJaRUF6YkNGYkNNREkvVUdhdVRSajdkREpMUEFwMjZ2eVRhClQ5V1h3d2prZUE4QXdBN0kzcUNDeWV0RVM0Tmo5K2lMRmJqUHRKdk53cGdHaWs0eG13RXNMczZwck5kRmtwL2sKOExZOHRIcXN3MjBaWi91cHVQN1BrcThUVGJENlIwN0UwVDVxcEtLZ3AzUjlJdnY2ampPZzdER1g2ZWdyR01lSwpxYVIzU2l0QXpvT2R2bnJzcE5LcFR2V2xkS3VycmNPWDY4c2E5SWErUzZTbFhaZjdrMTk2dDRONkt3SURBUUFCCm8wSXdRREFPQmdOVkhROEJBZjhFQkFNQ0FRWXdEd1lEVlIwVEFRSC9CQVV3QXdFQi96QWRCZ05WSFE0RUZnUVUKZERSSVlZNkFRbU5NZGhJMkdieFVaSmV2dG93d0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFKV0tYLzlqdlc5SgplTjBpQmdNYWR6T0FyVFRvUDcyWlhrbnhxUkthSmRHZ3JxMERIWWpUUGJ2WW1FTTJnSTVnZ1U2SVc2cEk5R0dUClFiR0J2WGNudXlRbXF6WFNMWG9LMWViUUcwRFlvTUJXaVJleFZsbzlxVVAwSFN2OUNVOHdLejMwcHdYR2YvMDUKVVFFeTFkYzRrZ2FIKzg5Z1lCVW5GNFI4SDdncFFuQ094d201OXJadUVtcFpqRytOYTN2ekxJM2dRMUVFQW83RApiS
    server: https://192.168.13.90:6443
  name: k8s-pre-pro
contexts:
- context:
    cluster: k8s-pre-pro
    namespace: default
    user: Jack
  name: k8s-pre-pro-context
current-context: k8s-pre-pro-context
kind: Config
preferences: {}
users:
- name: Jack
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUQyRENDQXNDZ0F3SUJBZ0lVSFh0QWpja1pXZUcyTGxHYU00U0VtSGNTdG5Fd0RRWUpLb1pJaHZjTkFRRUwKQlFBd1lURUxNQWtHQTFVRUJoTUNRMDR4RVRBUEJnTlZCQWdUQ0VoaGJtZGFhRzkxTVFzd0NRWURWUVFIRXdKWQpVekVNTUFvR0ExVUVDaE1EYXpoek1ROHdEUVlEVlFRTEV3WlRlWE4wWlcweEV6QVJCZ05WQkFNVENtdDFZbVZ5CmJtVjBaWE13SUJjTk1qTXdOVEkwTURNd09EQXdXaGdQTWpBM016QTFNVEV3TXpBNE1EQmFNR2d4Q3pBSkJnTlYKQkFZVEFrTk9NUkV3RHdZRFZRUUlFd2hUYUdGdVoyaGhhVEVSTUE4R0ExVUVCeE1JVTJoaGJtZG9ZV2t4RXpBUgpCZ05WQkFvVENtaHZiWE52YlRwdmNITXhEekFOQmdOVkJBc1RCbE41YzNSbGJURU5NQXNHQTFVRUF4TUVTbUZqCmF6Q0NBU0l3RFFZSktvWklodmNOQVFFQkJRQURnZ0VQQURDQ0FRb0NnZ0VCQUx3MFplUkdKNmY3WmlDWW0rRUwKcVFmSHZ5VjdiajJJdzdyOTRaSXlMY28ybnlXK29QeDVqVkR5TjUzakVPZkxMdmVnRDlDTlJCTVFwb0I4bStXNApyK1pCSElmWjdja0Z3V2hEZ0NpTXlyWnVwN0tzRUdBY3NQMHpUbTk0V2dJeHNjc0oyR1pzaXRGM2pGeUxkcldaCk9WU0IvVjBWMGRVc0lTSXZDUGVkT0xuZ0pKUUdmOXZQWmZhMzhQYjgwd0YwQ1NCQ1EwRHIvWld3cW00QzZDK1UKbnhSbXJNZWNWeVliOG83VHpJd2F2K1YvZmFQRkt6cFJOcURCK2k2aEUvSVlpTmFsd0tudTZGemJVTWl2cWNQTgpWUXBOdzU3OVVFdUVDclYyeGlQajM4SnpObWd1dlQvTUJ0TjRrSkFYVkJZZWNXWCtXMjJlMGx4S0trcGxqeVVRCkxPOENBd0VBQWFOL01IMHdEZ1lEVlIwUEFRSC9CQVFEQWdXZ01CMEdBMVVkSlFRV01CUUdDQ3NHQVFVRkJ3TUIKQmdnckJnRUZCUWNEQWpBTUJnTlZIUk1CQWY4RUFqQUFNQjBHQTFVZERnUVdCQlMwblpVWGluL2JRbjMyclcrbApNTGhONlJQMnN6QWZCZ05WSFNNRUdEQVdnQlIwTkVoaGpvQkNZMHgyRWpZWnZGUmtsNisyakRBTkJna3Foa2lHCjl3MEJBUXNGQUFPQ0FRRUFqOFFOMHZuUFpzUWVuOXJYaVZVTjRlMlloWHBGZ0dmbGwwUVd6TXc1NzBseFNwejIKYlN1NjNaeUZRMG51VFNDY2I4NUFpSVhDQWc5VmpHSW9pVkN6N1Jmb1IyS3NZck8vNzRqL0kydCtVd3ozTTFGRwpwejFoRk9BdU9tZDhPYTZ1WUNSdndBYlZyRy9nNEhoaGxpTmFBQjVBZE5ackxRbExMTWlWZWN0ODV3QnkwclhFCnhxc2
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBdkRSbDVFWW5wL3RtSUppYjRRdXBCOGUvSlh0dVBZakR1djNoa2pJdHlqYWZKYjZnCi9IbU5VUEkzbmVNUTU4c3U5NkFQMEkxRUV4Q21nSHliNWJpdjVrRWNoOW50eVFYQmFFT0FLSXpLdG02bnNxd1EKWUJ5dy9UTk9iM2hhQWpHeHl3bllabXlLMFhlTVhJdDJ0Wms1VklIOVhSWFIxU3doSWk4STk1MDR1ZUFrbEFaLwoyODlsOXJmdzl2elRBWFFKSUVKRFFPdjlsYkNxYmdMb0w1U2ZGR2FzeDV4WEpodnlqdFBNakJxLzVYOTlvOFVyCk9sRTJvTUg2THFFVDhoaUkxcVhBcWU3b1hOdFF5SytwdzgxVkNrM0RudjFRUzRRS3RYYkdJK1Bmd25NMmFDNjkKUDh3RzAzaVFrQmRVRmg1eFpmNWJiWjdTWEVvcVNtV1BKUkFzN3dJREFRQUJBb0lCQVFDZnpsNDJWdHVWWjRKdwpheVR4RWxXVXBhZEl6R1h2R2hJWTFUcVVTTWRZek1pVjVDZ09PYWdrODRjR0thaFJLZFhYcmJIQUJET3BmSm5rCnYrb2dSWklXa1hNSVo2UGc3V0lzaGlSc1NpQldoOThkZDd6djMyenBrb2NuWDZvTjh1Ums0eGM4NFMxK2IyUmYKc0l3NzVyOG5ZcmtnTVViYkczMkc2U2xVRjh2ekIwb0lyMW5UdWo0Zkh3NXpWNUdRTjRjaWozSXg0Tno3MDBCOApGUWFSdE1Fb3JMcDJCM01mTHh6ZzV4aVRmNjE1Rm90SW4rOVJUSTZVdFFtQURUYXVISVhqaWhuMSsxdVMxdXd6CjlQSEhXdmVicXZWSEoyL0V2Q1VmR0FRZ1g3L0swVDhKYTc4ZFZORWpNNC9sb1FhSkF3czJjdEUzeFZmaHlNVE8KajhWUDEyb0JBb0dCQU1wZEg4K2N2MnMzVnBzS2F5dCtJMTFZSG1yUUlXVHlKUjJEbkRCTGtoQjZybkRYY25UMwpmKzhUNmZybGMyUy85Z0xRcklHbk9TdVN2dmVQLzRsa0d1Ry9DcHBRZ0VMbWFJNE15TktFYzF1UVVrS0YzSjRTCjdkWWV1MWNvMVZmeWg5K21DSk5UOUNZMFBJL0M4WHhKN3NQK3lrdnJTZVRGaFVVcEg2ZE43eUxwQW9HQkFPNFcKaTQyak9JY1Irb1VZSGFFbHBhYk54d0hOQVVwV2VxTmVUZm1FRE1abndGRDZCSmpYSitIWG8xVzVZcHFndS9QNwpyTXMwNWRoQzJBaHBQSE1yYXhYeEhFUHdPYmVCSEE3S3c4YzM3cW1WZjhUaERqQjQzUGYxc2txbmtmMDg3SjVUCjFxRnFOTE4zQmk3bzVKS1A3cys3dGlqdGkzaXJxNHRmQWMxOXlYb1hBb0dBTXRsN3FOdW1iZmFWMkplaG5tZ3YKMHNEVnc5bFF5dURkMnJDN2lwY3l1TmxiQkJmZk51MEtSTFVvVWxkZHk2OUF6aXhKYkxyc2JycU5LZ0FSSWlENQpjRWhsRGFtMDBScThveFVyVVZyZThkOHVESEUrb3FuM0FacnZVRk4rYUg4VkRXblhOYzRleDRyUXZQOHJWeVBzCnoyc3l3aWo1aEhidHFoZFBVT2NRZENFQ2dZQVFFSWxlQnpOYk9jVlRrYXIrSXBJb3pSMnVhMnk0M1ZqdENRSHQKNGhFU21oR0o1VFRHTTA1SG1NczJqNG10c1VhOVVhLzVEaHFzR3VhRXVzVVBhRkNUYkc5aHppVzIwZ2xZbmluVAptVnlMS01FMFFaTTVoZzR5MU9zd3lsbTVZcEQ4cGQrSGlLa0JxdmhKMWdFR09wdjhmRWZ3UHdiNEgyMDF2RFZjCjdpM1lCUUtCZ1FDTFBpZGR1ZUs3eDlvVGNBUW4xOExjZ1pIN1ZXNUxXU3hsZ0NVZGppZVcybndoVUYrZjVIcjYKWi9JUlQwOXE
    token: eyJhbGciOiJSUzI1NiIsImtpZCI6ImZEcVVHSGxYZnpfby01UXc2WFBER19xSm5YaE5RYnlfblNUV2VxZU5JaEEifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJzYS1qYWNrLWFkbWluLXRva2VuLXRsNHc2Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6InNhLWphY2stYWRtaW4iLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiIxMDQ2NWY4Yi05NjFlLTQ4YjYtYmM5YS01YTFjNDYwMmI3ODgiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZS1zeXN0ZW06c2EtamFjay1hZG1pbiJ9.oW6z7KoqIY1uVyCqe9VOjUNHUgJLRZYtq8YgFEOw39m4JV4aZeG-MBQ3hhhTozmPmIhmx31zLsSdH2dplABnuA6Qpf5keQys-
```







## 部署Rollouts



### 在生产集群中添加预生产集群到argocd

```bash
# /bin/cp -f "clusters/$1/kubectl.kubeconfig" ~/.kube/config
[root@prometheus frontend-nginx-hs-com]# argocd cluster add context-cluster1 --kubeconfig /tmp/kubectl.kubeconfig --name pre-pro-cluster
WARNING: This will create a service account `argocd-manager` on the cluster referenced by context `context-cluster1` with full cluster level admin privileges. Do you want to continue [y/N]? y
INFO[0021] ServiceAccount "argocd-manager" created in namespace "kube-system" 
INFO[0021] ClusterRole "argocd-manager-role" created    
INFO[0021] ClusterRoleBinding "argocd-manager-role-binding" created 
Cluster 'https://192.168.13.90:6443' added
[root@prometheus frontend-nginx-hs-com]# argocd cluster list
SERVER                          NAME             VERSION  STATUS      MESSAGE                                              PROJECT
https://192.168.13.90:6443      pre-pro-cluster           Unknown     Cluster has no application and not being monitored.  	#此时fat-cluster还未部署application状态所以是unknow
https://kubernetes.default.svc  in-cluster       1.23     Successful                  
```



### 在预生产集群上安装argo rollouts

```bash
# 集群级别安装argo rollouts
[root@prometheus argocd]# kubectl create namespace argo-rollouts
[root@prometheus argocd]# kubectl apply -f argo-rollout-install.yaml -n argo-rollouts
[root@prometheus argocd]# kubectl get pods -A | grep argo
argo-rollouts          argo-rollouts-7969ff8dd8-fpj8q              1/1     Running   0          102s
```



### 在预生产集群上安装istio

```bash
[root@prometheus istio]# cat default-1.13.5.yaml 
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
      k8s:
        nodeSelector:
          gateway.k8s.hs.com: istio
        tolerations:
        - effect: "NoSchedule"
          key: node.kubernetes.io/unschedulable
          operator: "Equal"
        affinity:
          podAntiAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchLabels:
                  istio: ingressgateway
              topologyKey: kubernetes.io/hostname
    istiodRemote:
      enabled: false
    pilot:
      enabled: true
      k8s:
        nodeSelector:
          gateway.k8s.hs.com: istio
        tolerations:
        - effect: "NoSchedule"
          key: node.kubernetes.io/unschedulable
          operator: "Equal"
        resources:
          requests:
            cpu: 500m
            memory: 500Mi
        affinity:
          podAntiAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchLabels:
                  istio: pilot
              topologyKey: kubernetes.io/hostname
  hub: docker.io/istio
  meshConfig:
    defaultConfig:
      proxyMetadata: {}
    enablePrometheusMerge: true
  profile: default
  tag: 1.13.5
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
        autoscaleMin: 2
        autoscaleMax: 3
        env: {}
        name: istio-ingressgateway
        secretVolumes:
        - mountPath: /etc/istio/ingressgateway-certs
          name: ingressgateway-certs
          secretName: istio-ingressgateway-certs
        - mountPath: /etc/istio/ingressgateway-ca-certs
          name: ingressgateway-ca-certs
          secretName: istio-ingressgateway-ca-certs
        type: NodePort
    global:
      configValidation: true
      defaultNodeSelector: {}
      defaultPodDisruptionBudget:
        enabled: true
      defaultResources:
        requests:
          cpu: 10m
      imagePullPolicy: "IfNotPresent"
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
      autoscaleMax: 3
      autoscaleMin: 2
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
      replicaCount: 2
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
```

```bash
[root@prometheus istio]# kubectl label node 192.168.13.90 gateway.k8s.hs.com=istio
[root@prometheus istio]# kubectl label node 192.168.13.91 gateway.k8s.hs.com=istio
[root@prometheus istio]# kubectl label node 192.168.13.92 gateway.k8s.hs.com=istio

[root@prometheus istio]# istioctl install -f default-1.13.5.yaml 
This will install the Istio 1.13.5 default profile with ["Istio core" "Istiod" "Ingress gateways"] components into the cluster. Proceed? (y/N) y  
✔ Istio core installed                                                                                                                                                      
✔ Istiod installed                                                                                                                                                          
✔ Ingress gateways installed                                                                                                                                                
✔ Installation complete                                                                                                                                                     Making this installation the default for injection and validation.

Thank you for installing Istio 1.13.  Please take a few minutes to tell us about your install/upgrade experience!  https://forms.gle/pzWZpAvMVBecaQ9h9
[root@prometheus istio]# istioctl x precheck
✔ No issues found when checking the cluster. Istio is safe to install or upgrade!
  To get started, check out https://istio.io/latest/docs/setup/getting-started/

[root@prometheus istio]# kubectl get pods -o wide -n istio-system 
NAME                                    READY   STATUS    RESTARTS   AGE     IP               NODE            NOMINATED NODE   READINESS GATES
istio-ingressgateway-686c79496b-72w94   1/1     Running   0          116s    172.20.182.198   192.168.13.92   <none>           <none>
istio-ingressgateway-686c79496b-x9vmq   1/1     Running   0          101s    172.20.57.70     192.168.13.91   <none>           <none>
istiod-d46bd4c9d-h8t52                  1/1     Running   0          3m48s   172.20.124.1     192.168.13.90   <none>           <none>
istiod-d46bd4c9d-hdgrd                  1/1     Running   0          3m48s   172.20.57.69     192.168.13.91   <none>           <none>
```



### 在生产环境创建预生产环境的application

```bash
[root@prometheus frontend-wallet-hs-com]# kubectl get nodes
NAME            STATUS                     ROLES    AGE    VERSION
192.168.13.31   Ready,SchedulingDisabled   master   335d   v1.23.7
192.168.13.32   Ready,SchedulingDisabled   master   335d   v1.23.7
192.168.13.33   Ready,SchedulingDisabled   master   335d   v1.23.7
192.168.13.36   Ready                      node     335d   v1.23.7
192.168.13.37   Ready                      node     335d   v1.23.7
192.168.13.38   Ready                      node     335d   v1.23.7

# 创建发布预生产环境的project 名称
[root@prometheus argocd]# cat argocd-create-project.yaml 
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: prepro-homsom
  namespace: argocd
spec:
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'
  destinations:
  - namespace: '*'
    server: '*'
  sourceRepos:
  - '*'
[root@prometheus argocd]# kubectl apply -f argocd-create-project.yaml

[root@prometheus frontend-wallet-hs-com]# cat rollout-application.yaml 
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: prepro-frontend-wallet-hs-com
  namespace: argocd
spec:
  destination:
    namespace: pro-frontend
    server: https://192.168.13.90:6443
  project: prepro-homsom
  source:
    path: deploy/
    repoURL: git@gitlab.hs.com:k8s-deploy/frontend-wallet-hs-com.git
    targetRevision: prepro
  syncPolicy:
    automated:
      selfHeal: true
      prune: true
      allowEmpty: false
    syncOptions:
    - Validate=false
    - CreateNamespace=true
    - PrunePropagationPolicy=foreground
    - PruneLast=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
  ignoreDifferences:
  - group: networking.istio.io
    kind: VirtualService
    jsonPointers:
    - /spec/http/0	
[root@prometheus frontend-wallet-hs-com]# kubectl apply -f rollout-application.yaml


# 部署istio gateway
[root@prometheus frontend-wallet-hs-com]# cat istio-general-gateway.yaml 
---
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: general-gateway
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
    - "*"
---
[root@prometheus frontend-wallet-hs-com]# kubectl apply -f istio-general-gateway.yaml

##### 小插曲 #####
部署application依赖的gitlab repository地址时，经过测试，删除application依赖的gitlab repository地址的secret删除后几分钟，application依然正常工作，但为避免未知问题，仍然需要创建新名称为private-repo-frontend-nginx-hs-com的secret
---#old
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-000001
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: git@gitlab.hs.com:k8s-deploy/frontend-nginx-hs-com.git
---#new
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-frontend-nginx-hs-com
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: git@gitlab.hs.com:k8s-deploy/frontend-nginx-hs-com.git
---
####################
```





## 配置jenkins脚本，集成prepro环境

```bash
[root@BuildImage /shell]# cat cicd.sh
#!/bin/sh
#describe: image build and k8s deploy
#author: Jackli
#datetime: 2023-05-23


#init variables
JobName=${JOB_NAME}
ProjectName=${PublishEnvironment}
MirrorName=${JobName}
DeployENV=${DeployENV}
TagName="v"$(date +"%Y%m%d%H%M%S")
Repository='mirror_address'
Username='user'
Password='password'
ALiYunRepository='mirror_address'
ALiYunUsername='user'
ALiYunPassword='password'
ALiYunProjectName=${DeployENV}
shelldir="/shell"
DateFile="${shelldir}/.date"
CurrentDate=$(date +"%d")
LANGUAGE=${Language-null}
VUE=$1
JENKINS_USER='jenkins'
JENKINS_WORKSPACE="/var/lib/jenkins/workspace/${JobName}"
PUBLISH_PASSWORD='password'

### k8s code
GIT_K8S_ADDRESS_PREFIX='git@gitlab.hs.com:k8s-deploy'
[ ${LANGUAGE} == 'null' ] && LANGUAGE=frontend
[ ${LANGUAGE} == '.netCore' ] && LANGUAGE=dotnet
[ ${LANGUAGE} == 'java' ] && LANGUAGE=java
GIT_K8S_PROJECT_NAME=`echo ${JobName,,} | sed 's/\./-/g'`
GIT_K8S_PROJECT_FULLNAME=${GIT_K8S_ADDRESS_PREFIX}/${LANGUAGE}-${GIT_K8S_PROJECT_NAME}.git
GIT_K8S_ZONE_ENV=${DeployENV}
GIT_K8S_PROJECT_ENV=${ProjectName}
GIT_K8S_PROJECT_BRANCH=${GIT_K8S_PROJECT_ENV}
GIT_K8S_LOCAL_REPODIR=/git
DATETIME_STAMP="date +'%F %T'"

# fat uat env
FAT_SERVER='192.168.13.223'
FAT_SERVER_SHELL='testenv_deploy.sh'


export PATH=$PATH:/usr/local/node/bin:/usr/local/maven/bin

echo '----------------------------------'
echo "DeployENV: ${DeployENV}"
echo "Env: ${ProjectName}"
echo "Language: ${LANGUAGE}"
echo "GitBrance: ${GitBranchName}"
echo '----------------------------------'


#init Date Parameter,use whether delete clear_docker
group=`ls -l -d /shell | awk '{print $4}'`
[ ${group} == ${JENKINS_USER} ] || (sudo /usr/bin/chgrp -R ${JENKINS_USER} ${shelldir}; sudo /usr/bin/chmod -R 770 ${shelldir})
[ -f ${DateFile} ] || (sudo /usr/bin/touch ${DateFile}; sudo /usr/bin/chgrp ${JENKINS_USER} ${DateFile}; sudo /usr/bin/chmod 770 ${DateFile})
[ -z ${DateFile} ] && echo $(date +"%d") > ${DateFile}
Date=$(cat ${DateFile})

if [ "${PublishEnvironment}" == 'pro' -a "${PublishPassword}" != "${PUBLISH_PASSWORD}" ] || [ "${PublishEnvironment}" == 'prepro' -a "${PublishPassword}" != "${PUBLISH_PASSWORD}" ]; then
	echo "[ERROR]: Publish Password Wrong" 
	exit 10
fi

#change to workspace
cd ${JENKINS_WORKSPACE}

#java
if [[ ${LANGUAGE} == 'java' ]];then
        #/shell/java.sh ${JobName} ${shelldir} ${ProjectName}
	#[ $? != 0 ] && echo "[ERROR]: java project generator Dockerfile failure" && exit 10
        sudo mvn clean package -U -Dmaven.test.skip=true
        if [ $? == 0 ];then
                echo "[INFO]: Java Project Build Succeed" 
        else
                echo "[ERROE]: Java Project Build Failure" 
                exit 10
        fi

fi

#build vue frontend project
if [[ ${VUE} == "vue" ]];then
	echo "[INFO]: start build vue frontend project"
	echo $PATH
	sudo npm install && sudo npm run build
	if [ $? == 0 ];then
	        echo "[INFO]: Vue FrontEnd Project Build Succeed" 
	else
	        echo "[ERROE]: Vue FrontEnd Project Build Failure" 
	        exit 10
	fi
fi

#convert to lower
MirrorName=`echo ${JOB_NAME,,}` 

#build docker image
docker_build(){
	echo "[INFO]: Build Image ${ProjectName}/${MirrorName}:${TagName}"
	sudo docker build -t ${ProjectName}/${MirrorName}:${TagName} . 
	if [ $? == 0 ];then
		echo "[INFO]: Build Image Succeed" 
	else
		echo "[ERROR]: Build Image Failure" 
		delete_cache_container
		exit 10
	fi
}

docker_login(){
	echo "[INFO]: Login ${Repository}"
	sudo docker login -u ${Username} -p ${Password} ${Repository} >& /dev/null
	if [ $? == 0 ];then
		echo "[INFO]: Login Succeed"
	else
		echo "[ERROR]: Login Failure"
		exit 10
	fi
}

docker_tag_image(){
	echo "[INFO]: Tag Image ${ProjectName}/${MirrorName}:${TagName} To ${Repository}/${ProjectName}/${MirrorName}:${TagName}"
	sudo docker tag ${ProjectName}/${MirrorName}:${TagName} ${Repository}/${ProjectName}/${MirrorName}:${TagName} 
	if [ $? == 0 ];then
		echo "[INFO]: Tag Image Succeed"
	else
		echo "[ERROR]: Tag Image Failure"
		exit 10
	fi
}


docker_push_image(){
	echo "[INFO]: Push Image ${Repository}/${ProjectName}/${MirrorName}:${TagName}"
	sudo docker push ${Repository}/${ProjectName}/${MirrorName}:${TagName} 
	if [ $? == 0 ];then
		echo "[INFO]: Push Image Succeed"
	else
		echo "[ERROR]: Push Image Failure"
		exit 10
	fi
	
}

aliyun_docker_login(){
	echo "[INFO]: Login ${ALiYunRepository}"
        sudo docker login -u ${ALiYunUsername} -p ${ALiYunPassword} ${ALiYunRepository} >& /dev/null
	if [ $? == 0 ];then
		echo "[INFO]: Login Aliyun Repository Succeed"
	else
		echo "[ERROR]: Login Aliyun Repository Failure"
		exit 10
	fi
}

aliyun_docker_tag_image(){
	echo "[INFO]: Tag Image ${Repository}/${ProjectName}/${MirrorName}:${TagName} To ${ALiYunRepository}/${ALiYunProjectName}/${MirrorName}:${TagName}"
	sudo docker tag ${Repository}/${ProjectName}/${MirrorName}:${TagName} ${ALiYunRepository}/${ALiYunProjectName}/${MirrorName}:${TagName}
	if [ $? == 0 ];then
		echo "[INFO]: Tag Aliyun Image Succeed"
	else
		echo "[ERROR]: Tag Aliyun Image Failure"
		exit 10
	fi

}

aliyun_docker_push_image(){
	echo "[INFO]: Push Aliyun Image"
	sudo docker push ${ALiYunRepository}/${ALiYunProjectName}/${MirrorName}:${TagName}
	if [ $? == 0 ];then
		echo "[INFO]: Push Aliyun Image Succeed"
	else
		echo "[ERROR]: Push Aliyun Image Failure"
		exit 10
	fi

}

delete_aliyun_local_image(){
	echo "[INFO]: Delete Local Image ${ALiYunRepository}/${ALiYunProjectName}/${MirrorName}:${TagName}"
	sudo docker image rm ${ALiYunRepository}/${ALiYunProjectName}/${MirrorName}:${TagName}
	if [ $? == 0 ];then
		echo "[INFO]: Delete Aliyun Local Image Succeed"
	else
		echo "[ERROR]: Delete Aliyun Local Image Failure"
		exit 10
	fi
}

delete_local_image(){
	echo "[INFO]: Delete Local Image ${ProjectName}/${MirrorName}:${TagName}, ${Repository}/${ProjectName}/${MirrorName}:${TagName}"
	sudo docker image rm ${ProjectName}/${MirrorName}:${TagName} ${Repository}/${ProjectName}/${MirrorName}:${TagName} 
	if [ $? == 0 ];then
		echo "[INFO]: Delete Local Image Succeed"
	else
		echo "[ERROR]: Delete Local Image Failure"
		exit 10
	fi
}

delete_cache_container(){
	#delete docker container is Exited.
	echo "[INFO]: Delete Docker Container Status Is Exited"
	Exited_Containers=$(sudo docker ps -a | egrep -v 'CONTAINER|redis|uatHotelES|cadvisor' | grep 'Exited' |  awk '{print $1}')
	for i in ${Exited_Containers};do
		sudo docker rm -fv $i 
	done
	
	#delete local name is <none> image
	echo "[INFO]: Delete Docker Image Name Is <none>"
	NoNameImage=$(sudo docker image ls | grep '<none>' | awk '{print $3}') 
	for i in ${NoNameImage};do
		sudo docker image rm $i 
	done
}




git_k8s_clone(){
	echo "[INFO]: Clone -b ${GIT_K8S_PROJECT_BRANCH} ${GIT_K8S_PROJECT_FULLNAME}"
	[ -d ${GIT_K8S_LOCAL_REPODIR} ] || sudo mkdir -p ${GIT_K8S_LOCAL_REPODIR}
	cd ${GIT_K8S_LOCAL_REPODIR}
	sudo rm -rf ${LANGUAGE}-${GIT_K8S_PROJECT_NAME} && sudo git clone -b ${GIT_K8S_PROJECT_BRANCH} ${GIT_K8S_PROJECT_FULLNAME} 
	if [ $? == 0 ];then
		echo "[INFO]: Clone Successful" 
	else
		echo "[ERROE]: Clone Failure"
		exit 10
	fi
}

git_k8s_imageUpdate(){
	echo "[INFO]: Update Image Version"
	cd ${LANGUAGE}-${GIT_K8S_PROJECT_NAME} && sudo sed -i "s#image:.*#image: ${1}#" deploy/01-rollout.yaml
	if [ $? == 0 ];then
		sudo git config --global user.name "Jenkins@master" && sudo git config --global user.email "Jenkins@homsom.com"
		sudo git add -A && sudo git commit -m "${ProjectName}/${MirrorName}:${TagName}" && sudo git push origin ${GIT_K8S_PROJECT_BRANCH}
		if [ $? == 0 ];then
			echo "[INFO]: k8s Deploying......, See https://argocd.k8s.hs.com/applications/${GIT_K8S_PROJECT_ENV}-${LANGUAGE}-${GIT_K8S_PROJECT_NAME}"
		else
			echo "[ERROE]: Git Push Origin ${GIT_K8S_PROJECT_BRANCH} Failure"
			exit 10
		fi
	else
		echo "[ERROE]: Update Image Version Failure"
		exit 10
	fi
}

Fat_Uat_deploy(){
	if [ "${DeployENV}" == 'homsom-hs' -a "${ProjectName}" != 'pro' -a "${ProjectName}" != 'prepro' -a -n "${APPID}" ];then
		container_image="${Repository}/${ProjectName}/${MirrorName}:${TagName}"
		container_name=${MirrorName}
		container_env=${ProjectName}
		if [ "${ProjectName}" == 'fat' ];then
			container_port=${APPID}0
		elif [ "${ProjectName}" == 'uat' ];then
			container_port=${APPID}1
		fi
		echo "
----------------------------------------------

	[INFO]: ${container_env} server deploy stage
	
----------------------------------------------
		"
		echo "[INFO]: BEGIN_ITME `eval $DATETIME_STAMP`"
		echo "
container_image: $container_image
container_name: $container_name
container_env: $container_env
container_port: $container_port"
		sudo ssh root@${FAT_SERVER} "~/${FAT_SERVER_SHELL} ${container_image} ${container_env}-${container_name} ${container_env} ${container_port}"
		echo "[INFO]: END_TIME `eval $DATETIME_STAMP`"
	fi
}

k8s_deploy(){
	if [ ${GIT_K8S_ZONE_ENV} == 'homsom-hs' -a ${GIT_K8S_PROJECT_ENV}  == 'pro' ] || [ ${GIT_K8S_ZONE_ENV} == 'homsom-hs' -a ${GIT_K8S_PROJECT_ENV}  == 'prepro' ];then
		echo '
----------------------------------------------

	[INFO]: k8s stage
	
----------------------------------------------
		'
		echo "[INFO]: BEGIN_ITME `eval $DATETIME_STAMP`"
		git_k8s_clone
		git_k8s_imageUpdate "${Repository}/${ProjectName}/${MirrorName}:${TagName}"
		echo "[INFO]: END_TIME `eval $DATETIME_STAMP`"
	fi
}


main(){
	docker_build
	docker_login
	docker_tag_image
	docker_push_image

	if [ ${DeployENV} == 'homsom-aliyun' ];then
		aliyun_docker_login
		aliyun_docker_tag_image
		aliyun_docker_push_image
		delete_aliyun_local_image
	fi

	delete_local_image

	if [[ ${CurrentDate} != ${Date} ]];then
		delete_cache_container
		echo $(date +"%d") > ${DateFile}
	fi

	Fat_Uat_deploy
	k8s_deploy
}

main
```



## 预生产和生产环境访问测试结果对比

发布页面
![](./image/jenkins/01.png)

预生产环境访问结果
![预生产环境](./image/jenkins/02.png)

生产环境访问结果
![生产环境](./image/jenkins/03.png)
