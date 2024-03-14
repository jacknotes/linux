# kubernetes v1.19.0

截至目前，kubeadm可以支持在ubuntu 16.04+,debian 9+, centos7与rhel7,fedora 25+,hypriotOS v1.0.1和Container Linux系统上
构建kubernetes集群 
部署的基础环境要求：每个独立的主机应有2GB以上的内存及2个以上的CPU核心，有唯一的主机名、MAC、产品标识，禁用了SWAP且
各主机彼止间具有完整意义上的网络连通性。

**kubenetes集群高可用：**

1. 一般来说，高可用控制平面至少3个master节点来承受最多1个master节点的丢失，才能保证处于等待状态的master节点保持半数以上，以满足节点选举时的法定票数。
2. apiserver利用etcd进行数据存储，它自身是无状态应用，支持多副本同时工作，多副本间能无差别地服务客户端请求。
3. controller manager和scheduler都不支持多副本同时工作，它们各自需要选举出一个主节点作为活动实例，余下的实例在指定时间点监测不到主实例的“心跳”信息后，
将启动新一轮的选举操作以表决出新的主实例。
4. 一般来说对于etcd分布式存储集群来说，3节点可容错一个节点，5个节点可容错2个节点，7个节点可容错3个节点，依此类推，但通常多于7个节点的集群规模是不必要的，
而且对系统性能也会产生负面影响。
5. 具体部署方案的选择方面，我们可以把etcd与kubernetes控制平面的其他组件以“堆叠”的形式部署在同一组的3个节点之上。也可以把二者分开，让etcd运行为独立的外部集群，
控制平面部署为另一组集群，apiserver作为客户端远程访问etcd服务。
6. 堆叠式etcd集群拓扑将相同节点上的控制平面同etcd成员耦合在一起，每个控制平面节点分别运行一个apiserver、controlller manager、scheduler和etcd实例。
而以kubeadm部署的该类控制平面中，各apiserver实例仅与本地节点上的etcd成员通信，而各controlller manager、scheduler也仅与本地节点上的apiserver通信。
7.使用独立etcd集群的设计方案中，etcd集群与控制平面集群各自独立运行，它们各自遵循自有的节点拓扑要求和能承载各自需求的成员节点数量，例如etcd集群存在3个成员节点，
而控制平面集群有4个成员节点等。apiserver通常基于专用的域名与etcd集群中的任何成员进行通信，而各controlller manager、scheduler实例也可以通过专用域名及外部的负载均衡器
与任一apiserver实例进行通信。这样就实现了apiserver与etcd以及控制平面其他组件在本地节点上的解耦。
这两种拓扑结构各有利弊：堆叠式etcd方案节点需求量较小，适合中小规模的生产类集群，独立etcd方案节点需求量大，有较好的承载力及故障隔离能力，较适合中大型规模的生产类集群。

**kubernetes集群可部署为3种运行模式：**

1. 独立组件模式（master各组件和node各组件直接以守护进程方式运行于节点之上，以二进制程序部署的集群隶属于此种类型）
2. 静态pod模式（控制平面的各组件以静态pod对象形式运行在master主机之上，而node主机上的kubelet和docker运行为系统级守护进程，kube-proxy托管于集群上的daemonset控制器，kubeadm部署的就是此种类型。）
3. 自托管模式，类似于静态pod模式，开启时可使用：kubeadm init --features-gates=selfHosting选项激活（类似于第二种模式，但控制平面的各组件运行pod对象{非静态}，并且这些pod同样托管运行在集群之上，且同样受控于daemonset类型的控制器，类似kube-proxy）



## 集群部署

**kubernetes集群主机环境：**

192.168.13.50	tengine					reverse	
192.168.13.51	master01.k8s.hs.com  k8s-api.k8s.hs.com		master01
192.168.13.52	master02.k8s.hs.com				master02
192.168.13.53	master03.k8s.hs.com				master03
192.168.13.56	node01.k8s.hs.com				node01
192.168.13.57	node02.k8s.hs.com				node02

docker version: 20.10.5
kubernetes version: v1.19
kubeadm version: 1.18.8-0 



### 1.1 配置DNS

k8s-api.k8s.hs.com --> 192.168.13.50



### 1.2 tengine 配置四层代理

```BASH
[root@tengine /usr/local/tengine/conf]# cat nginx.conf
    upstream k8s-api.k8s.hs.com {
        server 192.168.13.51:6443;
        #server 192.168.13.52:6443;
        #server 192.168.13.53:6443;
    }

    server {
        listen 6443;
        proxy_pass k8s-api.k8s.hs.com;
    }

[root@tengine /usr/local/tengine/conf]# netstat -tnlp | grep 6443
tcp        0      0 0.0.0.0:6443            0.0.0.0:*               LISTEN      2232/nginx: worker  
```



### 1.3 部署k8s



#### 1.3.1 安装集群

```bash
# salt-ssh deploy key

# salt-master:
sudo rpm --import https://repo.saltproject.io/py3/redhat/7/x86_64/3002/SALTSTACK-GPG-KEY.pub
curl -fsSL https://repo.saltproject.io/py3/redhat/7/x86_64/3002.repo | sudo tee /etc/yum.repos.d/salt.repo

# salt-minion:
[root@salt ~/salt]# salt-ssh 'node*' -r 'curl http://mirrors.aliyun.com/repo/Centos-7.repo | tee /etc/yum.repos.d/Centos-7.repo'
[root@salt ~/salt]# salt-ssh 'node*' -r 'yum install -y python3'
[root@salt ~/salt]# salt-ssh '*' -i --key-deploy test.ping
[root@salt /srv/salt/base/init]# salt-ssh '*' state.sls init.init-for-saltssh saltenv=base

# 安装docker
[root@salt /srv/salt/base]# salt '*k8s*' state.highstate
[root@salt /srv/salt/base]# salt '*k8s*' cmd.run 'docker version | grep Version'
master02.k8s.hs.com:
  Version:           20.10.5

[root@master01 ~]# rpm --import https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
[root@master01 ~]# cat /etc/yum.repos.d/kubernetes.repo 
[kubernetes-repo]
name=kubernetes repo for RHEL/CentOS 7
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=0
[root@salt /srv/salt/base/init]# salt '*k8s*' state.sls init.k8s-repo saltenv=base 

# [root@salt ~]# salt '*k8s*' cmd.run 'yum remove -y kubeadm kubelet kubectl'
[root@salt ~]# salt '*k8s*' cmd.run 'yum install -y kubeadm-1.19.0-0 kubelet-1.19.0-0 kubectl-1.19.0-0'
[root@salt /etc/salt]# salt '*k8s*' cmd.run 'yum list installed | grep kube'
master02.k8s.hs.com:
    cri-tools.x86_64                 1.13.0-0                       @kubernetes-repo
    kubeadm.x86_64                   1.19.0-0                       @kubernetes-repo
    kubectl.x86_64                   1.19.0-0                       @kubernetes-repo
    kubelet.x86_64                   1.19.0-0                       @kubernetes-repo
    kubernetes-cni.x86_64            0.8.7-0                        @kubernetes-repo

[root@salt /srv/salt/base]# ssh -i /etc/salt/pki/master/ssh/salt-ssh.rsa 192.168.13.51

# 初始化控制平面
[root@master01 ~]# kubeadm  init \
--image-repository registry.aliyuncs.com/google_containers \
--kubernetes-version v1.19.0 \
--control-plane-endpoint k8s-api.k8s.hs.com \
--apiserver-advertise-address 192.168.13.51 \
--pod-network-cidr 10.244.0.0/16 \
--token-ttl 0 \
| tee kubeadm-init.txt

# kubeadm  init --image-repository registry.aliyuncs.com/google_containers --kubernetes-version v1.19.0 --control-plane-endpoint k8s-api.k8s.hs.com --apiserver-advertise-address 192.168.13.51 --pod-network-cidr 10.244.0.0/16 --token-ttl 0

# 初始化环境配置
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
[root@master01 k8s]# kubectl get nodes
NAME                  STATUS     ROLES    AGE   VERSION
master01.k8s.hs.com   NotReady   master   62s   v1.19.0
```



#### 1.3.1 部署网络组件

```bash
[root@master01 manifests]# kubectl apply -f addons/network/kube-flannel.yml 
[root@master01 manifests]# kubectl get nodes 
NAME                  STATUS   ROLES    AGE    VERSION
master01.k8s.hs.com   Ready    master   5m4s   v1.19.0
[root@master01 manifests]# kubectl get pods -n kube-system
NAME                                          READY   STATUS    RESTARTS   AGE
coredns-6d56c8448f-m8pjm                      1/1     Running   0          5m11s
coredns-6d56c8448f-sdk7q                      1/1     Running   0          5m11s
etcd-master01.k8s.hs.com                      1/1     Running   0          5m18s
kube-apiserver-master01.k8s.hs.com            1/1     Running   0          5m18s
kube-controller-manager-master01.k8s.hs.com   1/1     Running   0          5m18s
kube-flannel-ds-amd64-q789l                   1/1     Running   0          46s
kube-proxy-2s8z7                              1/1     Running   0          5m11s
kube-scheduler-master01.k8s.hs.com            1/1     Running   0          5m18s
```



#### 1.3.2 工作节点加入集群 

```bash
[root@node01 ~]# kubeadm join k8s-api.k8s.hs.com:6443 --token fi0e8y.luxmfi3knk0x151d \

>     --discovery-token-ca-cert-hash sha256:31851ba359ffec9d50fb3576908e37a69f5df60fcae6910304527b8438435387 
>     [root@node02 ~]# kubeadm join k8s-api.k8s.hs.com:6443 --token fi0e8y.luxmfi3knk0x151d \
>     --discovery-token-ca-cert-hash sha256:31851ba359ffec9d50fb3576908e37a69f5df60fcae6910304527b8438435387 

[root@master01 yum.repos.d]# kubectl get pods -n kube-system
NAME                                          READY   STATUS    RESTARTS   AGE
coredns-6d56c8448f-m8pjm                      1/1     Running   0          10m
coredns-6d56c8448f-sdk7q                      1/1     Running   0          10m
etcd-master01.k8s.hs.com                      1/1     Running   0          10m
kube-apiserver-master01.k8s.hs.com            1/1     Running   0          10m
kube-controller-manager-master01.k8s.hs.com   1/1     Running   0          10m
kube-flannel-ds-amd64-5vbdz                   1/1     Running   0          38s
kube-flannel-ds-amd64-7b6hs                   1/1     Running   0          113s
kube-flannel-ds-amd64-q789l                   1/1     Running   0          5m40s
kube-proxy-2s8z7                              1/1     Running   0          10m
kube-proxy-f69lx                              1/1     Running   0          38s
kube-proxy-vdbtl                              1/1     Running   0          112s
kube-scheduler-master01.k8s.hs.com            1/1     Running   0          10m
[root@master01 yum.repos.d]# kubectl get nodes 
NAME                  STATUS   ROLES    AGE    VERSION
master01.k8s.hs.com   Ready    master   10m    v1.19.0
node01.k8s.hs.com     Ready    <none>   117s   v1.19.0
node02.k8s.hs.com     Ready    <none>   42s    v1.19.0
```



### 1.4 部署高可用控制平面

这里部署的是堆叠式etcd拓扑（另外是外部etcd拓扑，适合于中大型k8s集群），适合于中小型集群。
高可用控制平面节点的拓扑中，我们需要为无状态的API Server实例配置外部的高可用负载均衡器，这些负载均衡器
的VIP将作为各个客户端（包括kube-scheduler和kube-controller-manager组件）访问API Server时使用的目标地址，
但是，kubedm init初始化第一个控制平面节点时默认会将各大组件的kubeconfig配置文件及admin.conf中的集群访问
入口定义为该节点的IP地址，且随后加入的各节点的TLS Bootstrap也会配置kubelet的kubeconfig使用该地址作为集群
访问入口，这将不利于后期高可用控制平面的配置。
解决办法是为kubedm init命令使用--control-plane-endpoint选项，指定API Server的访问端口为专用的DNS名称，
并将其临时解析到第一个控制平面节点的IP地址，等扩展控制平面完成且配置好负载均衡后，再将该DNS名称解析至
负载均衡器，以接收访问API Server的VIP。



#### 1.4.1 增加两个控制平面节点

**获取上传证书及密钥数据**

同一高可用控制平面集群中的各节点需要共享CA和front-proxy的数字证书和密钥，以及专用的ServiceAccount帐户的公钥和私钥，我们可以采用手动或者自动方式，这里采用自动的方式，因而首先需要在k8s-master01节点上运行如下命令：

```bash
# 此命令可以多次执行
[root@master01 ~]# kubeadm init phase upload-certs --upload-certs
I0411 19:24:28.467881   23419 version.go:252] remote version is much newer: v1.21.0; falling back to: stable-1.19
W0411 19:24:29.109595   23419 configset.go:348] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
[upload-certs] Storing the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
[upload-certs] Using certificate key:
b33d9f79a32d1762aca0a16af0852ba07e75bd157418b2ed60d970c1c86c13bc
```

**添加控制平台**

在新的两个控制平面节点使用kubeadm join --control-plane 命令加入集群成为master节点

```bash
# master02
# --certificate-key是自动上传数字证书和密钥、以及专用的ServiceAccount帐户的公钥和私钥产生的key，拿着这个key就可以加入控制平台了。
[root@master02 ~]# kubeadm join k8s-api.k8s.hs.com:6443 --token fi0e8y.luxmfi3knk0x151d \
--discovery-token-ca-cert-hash sha256:31851ba359ffec9d50fb3576908e37a69f5df60fcae6910304527b8438435387 \
--control-plane \
--certificate-key b33d9f79a32d1762aca0a16af0852ba07e75bd157418b2ed60d970c1c86c13bc
[root@master02 ~]# mkdir -p $HOME/.kube
[root@master02 ~]# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
[root@master02 ~]# sudo chown $(id -u):$(id -g) $HOME/.kube/config
[root@master02 ~]# kubectl get nodes 
NAME                  STATUS   ROLES    AGE    VERSION
master01.k8s.hs.com   Ready    master   107m   v1.19.0
master02.k8s.hs.com   Ready    master   40s    v1.19.0
node01.k8s.hs.com     Ready    <none>   98m    v1.19.0
node02.k8s.hs.com     Ready    <none>   97m    v1.19.0

# master03
[root@master03 ~]# kubeadm join k8s-api.k8s.hs.com:6443 --token fi0e8y.luxmfi3knk0x151d \
--discovery-token-ca-cert-hash sha256:31851ba359ffec9d50fb3576908e37a69f5df60fcae6910304527b8438435387 \
--control-plane \
--certificate-key b33d9f79a32d1762aca0a16af0852ba07e75bd157418b2ed60d970c1c86c13bc
[root@master03 ~]# mkdir -p $HOME/.kube
[root@master03 ~]# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
[root@master03 ~]# sudo chown $(id -u):$(id -g) $HOME/.kube/config
[root@master03 ~]# kubectl get nodes
NAME                  STATUS     ROLES    AGE     VERSION
master01.k8s.hs.com   Ready      master   110m    v1.19.0
master02.k8s.hs.com   Ready      master   3m54s   v1.19.0
master03.k8s.hs.com   NotReady   master   26s     v1.19.0
node01.k8s.hs.com     Ready      <none>   101m    v1.19.0
node02.k8s.hs.com     Ready      <none>   100m    v1.19.0
[root@master03 ~]# kubectl get pods -n kube-system
NAME                                          READY   STATUS    RESTARTS   AGE
coredns-6d56c8448f-m8pjm                      1/1     Running   0          119m
coredns-6d56c8448f-sdk7q                      1/1     Running   0          119m
etcd-master01.k8s.hs.com                      1/1     Running   0          119m
etcd-master02.k8s.hs.com                      1/1     Running   0          13m
etcd-master03.k8s.hs.com                      1/1     Running   0          9m59s
kube-apiserver-master01.k8s.hs.com            1/1     Running   0          119m
kube-apiserver-master02.k8s.hs.com            1/1     Running   0          13m
kube-apiserver-master03.k8s.hs.com            1/1     Running   0          10m
kube-controller-manager-master01.k8s.hs.com   1/1     Running   1          119m
kube-controller-manager-master02.k8s.hs.com   1/1     Running   0          13m
kube-controller-manager-master03.k8s.hs.com   1/1     Running   0          10m
kube-flannel-ds-amd64-5vbdz                   1/1     Running   0          110m
kube-flannel-ds-amd64-7b6hs                   1/1     Running   0          111m
kube-flannel-ds-amd64-cwlbk                   1/1     Running   0          13m
kube-flannel-ds-amd64-ntlq4                   1/1     Running   0          10m
kube-flannel-ds-amd64-q789l                   1/1     Running   0          115m
kube-proxy-2s8z7                              1/1     Running   0          119m
kube-proxy-crwhp                              1/1     Running   0          13m
kube-proxy-f69lx                              1/1     Running   0          110m
kube-proxy-fnmnp                              1/1     Running   0          10m
kube-proxy-vdbtl                              1/1     Running   0          111m
kube-scheduler-master01.k8s.hs.com            1/1     Running   1          119m
kube-scheduler-master02.k8s.hs.com            1/1     Running   0          13m
kube-scheduler-master03.k8s.hs.com            1/1     Running   0          10m
```



部署完成后，获取集群状态时会出现如下信息，这时需要到每个master中将/etc/kubernetes/manifests/kube-controller-manager.yaml和/etc/kubernetes/manifests/kube-scheduler.yaml两个文件的端口--port=0注释掉，然后重启kubelet 服务（其实改完保存后自己会重建，此步骤需要一个一个来，不能并行来）

```bash
[root@master02 ~]# kubectl get cs 
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS      MESSAGE                                                                                       ERROR
scheduler            Unhealthy   Get "http://127.0.0.1:10251/healthz": dial tcp 127.0.0.1:10251: connect: connection refused   
controller-manager   Unhealthy   Get "http://127.0.0.1:10252/healthz": dial tcp 127.0.0.1:10252: connect: connection refused   
etcd-0               Healthy     {"health":"true"}   

[root@master02 ~]# vim /etc/kubernetes/manifests/kube-controller-manager.yaml
#    - --port=0
[root@master02 ~]# vim /etc/kubernetes/manifests/kube-scheduler.yaml
#    - --port=0
[root@master02 ~]# kubectl get cs
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS    MESSAGE             ERROR
scheduler            Healthy   ok                  
controller-manager   Healthy   ok                  
etcd-0               Healthy   {"health":"true"}   
```



### 1.5 etcd

**etcd集群相关知识**

1. lead选举：
    谁先感受到宕机的etcd节点，谁就是新的 leader，这个也和进程初始的启动时间有关。

2. 必须是奇数节点吗？
    etcd官方推荐3、5、7个节点，虽然raft算法也是半数以上投票才能有 leader，但奇数只是推荐，其实偶数也是可以的。如 2、4、8个节点。分情况说明：
    1 个节点：就是单实例，没有集群概念，不做讨论
    2 个节点：是集群，但没人会这么配，这里说点废话：双节点的etcd能启动，启动时也能有主，可以正常提供服务，但是一台挂掉之后，就选不出主了，因为他只能拿到1票，剩下的那台也无法提供服务，也就是双节点无容错能力，不要使用。
    你会发现偶数节点虽然多了一台机器，但是容错能力是一样的，也就是说，你可以设置偶数节点，但没增加什么能力，还浪费了一台机器。同时etcd 是通过复制数据给所有节点来达到一致性，因此偶数的多一台机器增加不了性能，反而会拉低写入速度。

3. etcd集群机器越多越好吗？
    etcd 集群是一个 Raft Group，没有 shared。所以它的极限有两部分，一是单机的容量限制，内存和磁盘；二是网络开销，每次 Raft 操作需要所有节点参与，每一次写操作需要集群中大多数节点将日志落盘成功后，Leader 节点才能修改内部状态机，并将结果返回给客户端。因此节点越多性能越低，所以扩展很多 etcd 节点是没有意义的，一般是 3、5、7， 5 个也足够了。
    在 k8s 中一般是3*master机器做高可用，也就是 3节点的 etcd。也有人将 etcd独立于 k8s集群之外，来更好地扩展 etcd 集群，或者根据 k8s 的资源来拆分 etcd，如 events 放在单独的 etcd 集群中。不同的副本数视业务规模而定，3，5，7 都可以。
    脑裂问题？
    集群化的软件总会提到脑裂问题，如ElasticSearch、Zookeeper集群，脑裂就是同一个集群中的不同节点，对于集群的状态有了不一样的理解。

4. etcd集群中有没有脑裂问题？答案是： 没有  （注：如果节点是偶数节点，那么还是有脑残的风险）
    以网络分区导致脑裂为例，一开始有5个节点, Node 5 为 Leader
    由于出现网络故障，124 成为一个分区，35 成为一个分区， Node 5的leader 任期还没结束的一段时间内，仍然认为自己是当前leader，但是此时另外一边的分区，因为124无法连接5，于是选出了新的leader 1，网络分区形成。
    35分区是否可用？如果写入了1而读取了5，是否会读取旧数据(stale read)?
    答：35分区属于少数派，被认为是异常节点，无法执行写操作。写入 1 的可以成功，并在网络分区恢复后，35 因为任期旧，会自动成为 follower，异常期间的新数据也会从 1 同步给 35。
    而 5 的读请求也会失败，etcd 通过ReadIndex、Lease read保证线性一致读，即节点5在处理读请求时，首先需要与集群多数节点确认自己依然是Leader并查询 commit index，5做不到多数节点确认，因此读失败。
    因此 etcd 不存在脑裂问题。

5. etcd快照备份和查看

  ```bash
  [root@master01 ~]#  docker exec -it $(docker ps -f name=etcd_etcd -q) etcdctl --endpoints "https://192.168.13.51:2379"  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key snapshot save backup.db001 --write-out="table"
  {"level":"info","ts":1619755055.642756,"caller":"snapshot/v3_snapshot.go:119","msg":"created temporary db file","path":"backup.db001.part"}
  {"level":"info","ts":"2021-04-30T03:57:35.666Z","caller":"clientv3/maintenance.go:200","msg":"opened snapshot stream; downloading"}
  {"level":"info","ts":1619755055.6663518,"caller":"snapshot/v3_snapshot.go:127","msg":"fetching snapshot","endpoint":"https://192.168.13.51:2379"}
  {"level":"info","ts":"2021-04-30T03:57:35.808Z","caller":"clientv3/maintenance.go:208","msg":"completed snapshot read; closing"}
  {"level":"info","ts":1619755055.881549,"caller":"snapshot/v3_snapshot.go:142","msg":"fetched snapshot","endpoint":"https://192.168.13.51:2379","size":"4.2 MB","took":0.238622176}
  {"level":"info","ts":1619755055.8817613,"caller":"snapshot/v3_snapshot.go:152","msg":"saved","path":"backup.db001"}
  Snapshot saved at backup.db001
  [root@master01 ~]#  docker exec -it $(docker ps -f name=etcd_etcd -q) etcdctl --endpoints "https://192.168.13.51:2379"  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key snapshot status backup.db001 --write-out="table"
  +----------+----------+------------+------------+
  |   HASH   | REVISION | TOTAL KEYS | TOTAL SIZE |
  +----------+----------+------------+------------+
  | 7f59e2f5 |   151932 |       1503 |     4.2 MB |
  +----------+----------+------------+------------+
  ```

6. learner 角色
    learner 是 etcd 3.4 版本中增加的新角色，类似于 zookeeper 的 observer, 不参与 raft 投票选举。通过这个新角色的引入，降低了加入新节点时给老集群的额外压力，增强了集群的稳定性。除此之外还可以使用它作为集群的热备或服务一些读请求。
    举例，如果 etcd集群需要加入一个新节点，新加入的 etcd 成员因为没有任何数据，因此需要从 leader 那里同步数据，直到赶上领导者的日志为止。这样就会导致 leader 的网络过载，导致 leader 和 member 之间的心跳可能阻塞。然后就开始了新的leader选举，也就是说，具有新成员的集群更容易受到领导人选举的影响。领导者的选举以及随后向新成员的更新都容易导致一段时间的群集不可用，这种是不符合预期，风险也是很大的。
    因此为了解决这个问题，raft 4.2.1 论文中介绍了一种新的节点角色：Learner。加入集群的节点不参与投票选举，只接收 leader 的 replication message，直到与 leader 保持同步为止。



**etcd命令**
证书太长就不写了，以下命令均为无证书版：
version: 查看版本
member list: 查看节点状态，learner 情况
endpoint status: 节点状态，leader 情况
endpoint health: 健康状态与耗时
alarm list: 查看警告，如存储满时会切换为只读，产生 alarm
alarm disarm：清除所有警告
set app demo: 写入
get app: 获取
update app demo1:更新
rm app: 删除
mkdir demo 创建文件夹
rmdir dir 删除文件夹
backup 备份
compaction： 压缩
defrag：整理碎片
watch key 监测 key 变化
get / –prefix –keys-only: 查看所有 key
–write-out= tables，可以用表格形式输出更清晰，注意有些输出并不支持tables
在etcd中删除cluster信息





### 1.6 k8s集群监控

为避免重蹈hepster的覆辙，资源指标API和自定义指标API，他们作为聚合API集成到kubernetes集群中。
heapster用于提供核心指标API的功能也被采用聚合方式的指标API服务器metrics server所取代。

**新一代监控体系与指标系统**
我们知道，kubernetes通过API Aggregator（聚合器）为开发人员提供了轻松扩展API资源的能力，为集群添加
指标数据API的自定义指标API、资源指标API（简称为指标API）和外部指标API都属于这种类型的扩展。
总结起来：新一代的kubernetes监控系统架构主要同核心指标流水线和监控指标流水线共同组成。



#### 1.6.1 核心指标与metrics server

```bash
[root@master01 ~/k8s/manifests/addons/monitor/metrics-server]# curl https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.7/components.yaml | tee metrics-server-deploy.yaml
[root@master01 ~/k8s/manifests/addons/monitor/metrics-server]# vim metrics-server-deploy.yaml
  containers:
   - name: metrics-server
     image: k8s.gcr.io/metrics-server/metrics-server:v0.3.7
     imagePullPolicy: IfNotPresent
     args:
       - --cert-dir=/tmp
       - --secure-port=4443
       - --kubelet-preferred-address-types=InternalIP
       - --kubelet-insecure-tls
         注：kubelet通常是在Bootstrap过程中生成自签证书，这类证书无法由Metrics server完成CA验证，因此需要使用--kubelet-insecure-tls选项来禁用这验证功能。另外 ，节点的DNS域（hs.com）与kubernetes集群使用的DNS域（cluster.local）不相同，则coreDNS通常无法解析各节点的主机名称，这类问题有两种，方案一是使用--kubelet-preferred-address-types=InternalIP来使用内部IP来与各节点通信。另外一种是为CoreDNS添加类似hosts解析的资源记录。推荐方案一。
# 由于国内无法访问google镜像站，所以需要提前下载
[root@node02 ~]# docker pull bitnami/metrics-server:0.3.7
[root@node02 ~]# docker tag bitnami/metrics-server:0.3.7 k8s.gcr.io/metrics-server/metrics-server:v0.3.7
[root@master01 ~/k8s/manifests/addons/monitor/metrics-server/3.7]# kubectl apply -f metrics-server-deploy.yaml 

# 测试metrics server是否收集到指标，如果收集到指标则表示metrics server工作正常了
[root@master01 ~/k8s/manifests]# yum install -y jq
[root@master01 ~/k8s/manifests]# kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes" | jq
{
  "kind": "NodeMetricsList",
  "apiVersion": "metrics.k8s.io/v1beta1",
  "metadata": {
"selfLink": "/apis/metrics.k8s.io/v1beta1/nodes"
  }

[root@master01 ~/k8s/manifests]# kubectl top nodes
NAME                  CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
master01.k8s.hs.com   1006m        25%    1606Mi          20%       
master02.k8s.hs.com   76m          1%     1502Mi          40%       
master03.k8s.hs.com   297m         7%     1456Mi          39%       
node01.k8s.hs.com     85m          2%     937Mi           25%       
node02.k8s.hs.com     89m          2%     942Mi           29%   
```



#### 1.6.2 自定义指标与prometheus
promQL --> k8s-prometheus-adapter -->custom-metrics.k8s.io <-- client get



**kube-state-metrics**

已经有了cadvisor、heapster、metric-server，几乎容器运行的所有指标都能拿到，但是下面这种情况却无能为力：
我调度了多少个replicas？现在可用的有几个？
多少个Pod是running/stopped/terminated状态？
Pod重启了多少次？
我有多少job在运行中?
而这些则是kube-state-metrics提供的内容，它基于client-go开发，轮询Kubernetes API，并将Kubernetes的结构化信息转换为metrics。



**HPA V2**

基于CPU和内存进行压测
```bash
[root@master02 ~/manifests/hpa]# cat hpa-v2-deployment.yaml 
apiVersion: v1
kind: Service
metadata:
  name: daemonapp
  namespace: fat
spec:
  selector:
    app: demonapp
  ports:
  - name: http
    port: 80
    targetPort: 80  
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demonapp
  namespace: fat
spec:
  replicas: 2
  selector:
    matchLabels:
      app: demonapp
  template:
    metadata:
      labels:
        app: demonapp
    spec:
      containers:
      - name: demonapp-container
        image: ikubernetes/myapp:v1
        imagePullPolicy: IfNotPresent
        ports:
        - name: http
          containerPort: 80
        livenessProbe:
          httpGet:
            port: http
            path: /index.html
          initialDelaySeconds: 1 
          periodSeconds: 3 
        readinessProbe:
          httpGet:
            port: http
            path: /index.html
          initialDelaySeconds: 1 
          periodSeconds: 3 
        resources:
          requests:
            memory: "256Mi"
            cpu: "50m"
          limits:
            memory: "256Mi"
            cpu: "50m"
[root@master02 ~/manifests/hpa]# cat hpa-v2.yaml 
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: demoapp
spec:
  scaleTargetRef: 
    apiVersion: apps/v1
    kind: Deployment
    name: demoapp   
  minReplicas: 2
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 30
  - type: Resource
    resource:
      name: memory
      target:
        type: AverageValue
        averageValue: 30Mi
```

基于web请求数进行压测(自定义指标)

```bash
# 运行metrics-app
[root@master02 ~/manifests/hpa]# cat hpa-v2-web-deployment.yaml 
apiVersion: v1
kind: Service
metadata:
  name: demonapp-web
  namespace: fat
spec:
  selector:
    app: demonapp-web
  ports:
  - name: http
    port: 80
    targetPort: 80  
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demonapp-web
  namespace: fat
spec:
  replicas: 2
  selector:
    matchLabels:
      app: demonapp-web
  template:
    metadata:
      labels:
        app: demonapp-web
    spec:
      containers:
      - name: demonapp-web-container
        image: ikubernetes/metrics-app
        imagePullPolicy: IfNotPresent
        ports:
        - name: http
          containerPort: 80
        livenessProbe:
          httpGet:
            port: http
            path: /index.html
          initialDelaySeconds: 1 
          periodSeconds: 3 
        readinessProbe:
          httpGet:
            port: http
            path: /index.html
          initialDelaySeconds: 1 
          periodSeconds: 3 
        resources:
          requests:
            memory: "256Mi"
            cpu: "50m"
          limits:
            memory: "256Mi"
            cpu: "50m"
```



测试 

```bash
[root@master02 ~]# kubectl run client --image="ikubernetes/admin-toolbox:v1.0" -it --rm --command /bin/sh 
[root@client /]# curl demonapp-web.fat.svc.cluster.local/metrics
# HELP http_requests_total The amount of requests in total
# TYPE http_requests_total counter
http_requests_total 161
# HELP http_requests_per_second The amount of requests per second the latest ten seconds
# TYPE http_requests_per_second gauge
http_requests_per_second 0.7

#运行hpa
[root@master02 ~/manifests/hpa]# cat hpa-v2-web.yaml 
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: demoapp-web
spec:
  scaleTargetRef: 
    apiVersion: apps/v1
    kind: Deployment
    name: demoapp-web 
  minReplicas: 2
  maxReplicas: 5
  metrics:
  - type: Pods
    pods:
      metric: 
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: 5
    behavior:
    scaleDown:
      stabilizationWindowSeconds: 120
    [root@master02 ~/manifests/hpa]# kubectl apply -f hpa-v2-web.yaml

#在k8s-prometheus-adapter上配置自定义规则进行暴露http_requests_per_second指标，默认不会进行公开。
[root@master02 ~/manifests/hpa]# wget https://raw.githubusercontent.com/iKubernetes/Kubernetes_Advanced_Practical_2rd/main/chapter15/prometheus/prometheus-adapter-values-with-custom-rules.yaml
[root@master02 ~/manifests/hpa]# helm list -n monitoring 
NAME   	NAMESPACE 	REVISION	UPDATED                                	STATUS  	CHART                   	APP VERSION
adapter	monitoring	2       	2021-06-06 21:41:13.268408214 +0800 CST	deployed	prometheus-adapter-2.5.1	v0.7.0     
grafana	monitoring	1       	2021-06-06 18:29:08.869634606 +0800 CST	deployed	grafana-5.5.7           	7.1.1      
prom   	monitoring	2       	2021-06-06 22:17:36.115755585 +0800 CST	deployed	prometheus-11.12.1      	2.20.1     
[root@master02 ~/manifests/hpa]# helm upgrade adapter -f prometheus-adapter-values-with-custom-rules.yaml stable/prometheus-adapter -n monitoring 

#请求压测
[root@master02 ~]# kubectl get svc -n fat
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
daemonapp      ClusterIP   10.100.14.43    <none>        80/TCP    52m
demonapp-web   ClusterIP   10.106.129.82   <none>        80/TCP    26m
[root@master02 ~]# ab -c 100 -n 10000 http://10.106.129.82/

```



### 1.7 存储

1. 临时存储卷emptyDir和gitRepo的生命周期同pod，但gitRepo能够通过引用外部git仓库的数据实现数据持久化
2. 节点存储卷hostPath和local提供了节点级别的数据持久能力。
3. 网络存储卷NFS、GlusterFS和RBD等是企业内部较为常用的独立部署的持久存储系统。
4. PV和PVC可将存储管理与存储使用解耦为消费者模型。
5. 基于Storage可以实现PV的动态预配，GlusterFS和Ceph RBD以及去端存储AWS EBS等都可实现此类功能。
6. CSI是由CNCF社区维护的开源容器存储接口标准，目前在kubernetes上得到了广泛应用，著名的存储解决方案Longhorn就是该类插件的代表之一。

CSI代表类插件：Longhorn:
1. pod --> kubernetes存储卷 --> engine(基于longhorn存储卷，PVC被pod引用后，pod所在的节点就是engind所在的节点) --> 管理replica(可以是多副本)
2. 应用Longhorn:
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/master/deploy/longhorn.yaml
该部署清单会在默认的longhorn-system名称空间下部署csi-attacher,csi-provisioner,csi-resizer,engine-image-ei,longhorn-csi-plugin,longhorn-manager等
应用相关的pod对象。
该部署清单还在默认创建名义longhorn的StorageClass资源，它以部署好的Longhorn为后端存储系统，支持存储卷动态预配机制。我们也能够以类似的方式定义
基于Longhorn存储系统的、使用了不同配置的其他StorageClass资源。例如仅有一个副本以用于测试场景或对数据可靠性要求并非特别高的应用等。



### 1.8 service、endpoint、容器探针
1. 当创建service和pod时，service会通过标签选择器关联后端pod，其实在创建service时service还会创建跟自己同名的endpoint(端点)，
此端点用于选择后端pod，从而完成service跟pod的关联。
2. 容器探针：有存活性探测和就绪性控制，当pod未就绪时则会移到subnets.notReadyaddresses字段中，如果就绪则在subnets.addresses字段。
3. endpoint可以自定义，而调用这类endpoint对象的同名service对象无须再使用标签选择器即可完成与pod的关联。
4. 自定义endpoint常将那些不是由编排程序编排的应用定义为Kubernetes系统的service对象，从而让客户端像访问集群上的pod应用一样请求
外部服务。



### 1.9 iptables和ipvs
单个service对象的iptables数量与后端端点(pod)的数量正相关，对于拥有较多service对象和大规模pod对象的kubernetes集群，每个节点的内核上将充斥着大量的iptables规则。
service对象的变动会导致所有节点刷新netfilter上的iptables规则，而且每次的service请求也都将经历多次的规则匹配检测和处理过程，这会占用节点上相当比例的系统资源。因此，
iptables代理模型不适用于service和pod数量较多的集群。ipvs代理模型通过将流量匹配和分发功能配置为少量ipvs规则，有效降低了对系统资源的占用，从而是能够承载更大规模
的kubernetes集群。
1. 调整kube-proxy代理模型：
可直接使用kubetctl edit configmaps/kube-proxy -n kube-system命令编辑该configmap对象设置代理模型为ipvs:
mode: "ipvs"
注：配置完成后，以灰度模式手动逐个或分批次删除kube-system名称空间下的kube-proxy旧版本的pod，等待新pod运行起来便切换到了ipvs代理模型。用于生产环境时，应在
部署kubernetes集群时直接待定要使用的代理模型，或在集群部署完成生立即调整代理模型，而后再部署其他应用。



### 1.10 服务发现
1. 服务发现机制的基本实现：一般是事先部署好一个网络位置较为稳定的服务注册中心(也称为服务总线)，由服务代理者向注册中心“注册”自己的位置信息，并在变动后及时予以更新，
相应地服务消费方周期性地从注册中心获取服务提供者的最新位置信息，从而“发现”要访问的目标服务资源。复杂的服务发现机制还会让服务提供者提供其描述信息，状态信息及
资源使用信息等，以供消费者实现更为服务选择逻辑。
2. 实践中，根据其发现过程的实现方式，服务发现还可分为两种类型：客户端发现和服务端发现。
客户端发现：由客户端到服务注册中心发现其依赖的服务的相关信息，因此，它需要内置特定的服务发现程序和发现逻辑。
服务端发现：这种方式额外要用到一个称为中央路由器或者 服务均衡器的组件；服务消费者将请求发往中央路由器或服务均衡器，由它们负责查询服务注册中心获取服务提供者的位置
信息，并将服务消费者的语法转发给服务提供者。
3. 由此可见，服务注册中心是服务发现得以落地的核心组件。事实上DNS可以算得上是最为原始的服务发现系统之一，但DNS记录的传播速度可能跟不上服务的变更速度，因此不适用于
微服务环境。
4. pod的DNS解析策略与配置: 它们分别使用spec.dnsPolicy和spec.dnsConfi进行定义，并组件生效。
```bash
   spec.dnsPolicy: Default, ClusterFirst, ClusterFirstWithHostNet, None
   spec.dnsConfig: nameservers, searches, options   --这些选项都附加在dnsPolicy配置之后
# pod的/etc/resolve.conf中dns服务器的搜索域都会变为指定的信息。
   spec: 
    dnsPolicy: None
    dnsConfig: 
    nameservers:
      - 10.96.0.10
      - 223.5.5.5
    searches:
      - svc.cluster.local
      - cluster.local
      - ilinux.io
    options:
      - name: ndots
        values: "5"
```
5. externalName Service: 只要在service中定义externalName：redis.ik8s.io类似字段信息，则集群中的pod通过coreDNS解析service名称的地址信息为redis.ik8s.io，然后解析最终IP
6. Headless Service: 只要在service中定义clusterIP: None即可定义无头service，当pod请求service名称时，coreDNS直接解析到后端的podIP，而不是clusterIP，从而避免iptables规则匹配。
增加速度。



### 1.11 准入控制器

一个准入控制器可以是验证型、变异型或兼具此两项功能。
LimitRange  --验证型
1. LimitRange支持在Pod级别与容器级别分别设置CPU和内存两种计算资源的可用范围，它们对应的资源范围限制类型分类pod和container。一旦在名称空间上启用LimitRange，该名称空间中
的Pod或容器的Requests和Limits的各大项属性值必须在对应的可用资源范围内，否则将会被描绘，这是验证型准备控制器的功能。
以Pod级别的CPU资源为例，若某个LimitRange资源为其设定了[0.5,4]的区间，则相应名称空间下任何Pod资源的requests.cpu的属性值必须大于等于500m，同时limits.cpu的属性值必必须要
小于等于4。而未显示指定Requests和Limit属性的容器，将会从LimitRange资源上分别自动继承相应的默认设置，这是变异型准入控制器的功能。
2. 可以配置一个LimitRange对象资源清单，针对Pod，Container，PVC进行资源限制。LImitRange是名称级别的验证型准入控制器。
kubectl apply -f limitrange-demo.ymal
kubectl describe limitranges/resource-limits -n dev 
3. 若Pod、Container、PVC对象的requests和limits值不在LimitRange相应资源的范围内，就会触发LimitRange准入控制器拒绝相关的请求。需要注意的是，LimitRange生效生名称空间级别，
它需要定义在每个名称空间之上；另外定义的限制仅对该资源创建后的Pod和PVC资源创建请求有效，对之前已然存在的资源无效；再者，不建议在生效于同一名称空间的多个LimitRange资源
上，对同一个计算资源限制进行分别定义，以免产生歧义或导致冲突。

ResourceQuota --验证型
1. ResourceQuota资源可限制名称空间中牌非终止状态的所有pod对象的计算资源需求及计算资源限制问题。
2. ResourceQuota资源还支持为本地名称空间中的PVC存储资源的需求总量和限制总量设置限额，它能够分别从名称空间中的全部PVC、隶属于特定存储类的PVC以及基于本地临时存储的PVC分别进行定义。
3. 自Kubernetes v1.9版本起，开始支持以count/<resource>.<group>的格式对所有的资源类型对象的计数配额。例如：count/deployments.apps、count/deployments.extensions和count/services等。
4. 每个ResourceQuota资源对象上还支持定义一组作用域，用于定义资源上的配额仅生效于这组作用域交集范围内的对象，目前适用范围包括Terminating，NotTerminating，BestEffort，NotBestEffort。
5. 自Kubernetes v1.11版本起，管理员还可以在ResourceQuota资源上使用scopeSelector字段定义其生效的作用域、它支持基于Pod对象的优先级来控制Pod对系统资源的消耗。
6. 可以配置一个ResourceQuota对象资源清单，ResourceQuota是名称级别的验证型准入控制器。
kubectl apply -f resourcequota-demo.ymal
kubectl describe resourcequota/ resourcequota-demo -n dev 

PosSecurityPolicy
1. 新部署的Kubernetes集群默认并不会自动生成任何PSP资源，因而该准入控制器默认处于禁用状态。PSP资源的API接口（policy/v1beta1/podsecuritypolicy）独立于PSP准入控制器，因此管理员
可以先定义好必要的Pod安全策略，再设置kube-apiserver启用PSP准入控制器。不当的Pod安全策略可能会产生难以预料的副作用，因此请确保添加的任何PSP对象都经过了充分测试。
2. 主要3个步骤：设置特权及受限的PSP对象、创建ClusterRole并完成帐户绑定、启用PSP准入控制器。
注意：将任何Pod安全策略应用到生产环境之前请务必做到充分测试。



### 1.12 k8s master节点移除和添加

#### 1.12.1  master节点移除


```bash
# 打印加入集群命令
[root@master02 ~/manifests/addons/network]# kubeadm token create --print-join-command
W0430 09:26:33.276319   14024 configset.go:348] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
kubeadm join k8s-api.k8s.hs.com:6443 --token poz5y3.206amiyzawdzlueo     --discovery-token-ca-cert-hash sha256:437e89e657eca27c9d0311c4f76d7dd3f9d3fe9de7eb10016d626ac1133dd5bb 
[root@master02 ~/manifests/addons/network]# kubeadm init phase upload-certs --upload-certs
I0430 09:26:42.090495   14118 version.go:252] remote version is much newer: v1.21.0; falling back to: stable-1.19
W0430 09:26:43.442826   14118 configset.go:348] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
[upload-certs] Storing the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
[upload-certs] Using certificate key:
be1fd45e9911967deef4cdbf35ee5a16671df886956270fd9a26591e190648ea
# 因为加入集群为master命令组合为
kubeadm join k8s-api.k8s.hs.com:6443 --token poz5y3.206amiyzawdzlueo     --discovery-token-ca-cert-hash sha256:437e89e657eca27c9d0311c4f76d7dd3f9d3fe9de7eb10016d626ac1133dd5bb  --control-plane --certificate-key be1fd45e9911967deef4cdbf35ee5a16671df886956270fd9a26591e190648ea

--查看etcd集群节点的状态
[root@master02 ~]# kubectl drain --delete-local-data --force --ignore-daemonsets  master01.k8s.hs.com
node/master01.k8s.hs.com cordoned
WARNING: ignoring DaemonSet-managed Pods: kube-system/kube-proxy-55p57
evicting pod kube-system/coredns-6d56c8448f-4grh8
evicting pod kube-system/coredns-6d56c8448f-vsjct
pod/coredns-6d56c8448f-4grh8 evicted
pod/coredns-6d56c8448f-vsjct evicted
node/master01.k8s.hs.com evicted
[root@master03 ~/.kube]# kubectl get nodes
NAME                  STATUS                     ROLES    AGE   VERSION
master01.k8s.hs.com   Ready,SchedulingDisabled   master   31m   v1.19.0
master02.k8s.hs.com   Ready                      master   20m   v1.19.0
master03.k8s.hs.com   Ready                      master   13m   v1.19.0
[root@master03 ~/.kube]# kubectl delete nodes master01.k8s.hs.com
node "master01.k8s.hs.com" deleted
[root@master03 ~/.kube]# kubectl get nodes
NAME                  STATUS   ROLES    AGE   VERSION
master02.k8s.hs.com   Ready    master   20m   v1.19.0
master03.k8s.hs.com   Ready    master   13m   v1.19.0


# 查看etcd状态
[root@master03 ~/.kube]# kubectl -n kube-system exec etcd-master02.k8s.hs.com -- etcdctl --endpoints=https://192.168.13.52:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key endpoint status
https://192.168.13.52:2379, 30d66d597f2cc725, 3.4.9, 2.8 MB, false, false, 3, 6677, 6677, 
[root@master03 ~/.kube]# kubectl -n kube-system exec etcd-master02.k8s.hs.com -- etcdctl --endpoints=https://192.168.13.51:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key endpoint status
https://192.168.13.51:2379, a78dd15fd54968fb, 3.4.9, 2.9 MB, true, false, 3, 6691, 6691, 
[root@master03 ~/.kube]# kubectl -n kube-system exec etcd-master02.k8s.hs.com -- etcdctl --endpoints=https://192.168.13.53:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key endpoint status
https://192.168.13.53:2379, 8b52db2527e288df, 3.4.9, 2.8 MB, false, false, 3, 6710, 6710, 
[root@master03 ~/.kube]# kubectl -n kube-system exec etcd-master02.k8s.hs.com -- etcdctl --endpoints=https://192.168.13.52:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key endpoint health
https://192.168.13.52:2379 is healthy: successfully committed proposal: took = 9.015595ms
[root@master03 ~/.kube]# kubectl -n kube-system exec etcd-master02.k8s.hs.com -- etcdctl --endpoints=https://192.168.13.51:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key endpoint health
https://192.168.13.51:2379 is healthy: successfully committed proposal: took = 17.182973ms
[root@master03 ~/.kube]# kubectl -n kube-system exec etcd-master02.k8s.hs.com -- etcdctl --endpoints=https://192.168.13.53:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key endpoint health
https://192.168.13.53:2379 is healthy: successfully committed proposal: took = 20.595421ms

# 重置集群节点:master01.k8s.hs.com:
kubeadm reset 


[root@master02 ~]# docker exec -it $(docker ps -f name=etcd_etcd -q) /bin/sh
sh-5.0# etcdctl --endpoints "https://127.0.0.1:2379"  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key member list --write-out="table"
+------------------+---------+---------------------+----------------------------+----------------------------+------------+
|        ID        | STATUS  |        NAME         |         PEER ADDRS         |        CLIENT ADDRS        | IS LEARNER |
+------------------+---------+---------------------+----------------------------+----------------------------+------------+
| 30d66d597f2cc725 | started | master02.k8s.hs.com | https://192.168.13.52:2380 | https://192.168.13.52:2379 |      false |
| 8b52db2527e288df | started | master03.k8s.hs.com | https://192.168.13.53:2380 | https://192.168.13.53:2379 |      false |
| a78dd15fd54968fb | started | master01.k8s.hs.com | https://192.168.13.51:2380 | https://192.168.13.51:2379 |      false |
+------------------+---------+---------------------+----------------------------+----------------------------+------------+
sh-5.0# etcdctl --endpoints "https://192.168.13.51:2379,https://192.168.13.52:2379,https://192.168.13.53:2379"  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key endpoint status --write-out="table"
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|          ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://192.168.13.51:2379 | a78dd15fd54968fb |   3.4.9 |  4.2 MB |      true |      false |         3 |       9170 |               9170 |        |
| https://192.168.13.52:2379 |  8715488046f0887 |   3.4.9 |  4.2 MB |     false |      false |         3 |       9171 |               9171 |        |
| https://192.168.13.53:2379 | 676ef70c3ee42b24 |   3.4.9 |  4.1 MB |     false |      false |         3 |       9171 |               9171 |        |
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
[root@master02 /etc/kubernetes/manifests]# docker exec -it $(docker ps -f name=etcd_etcd -q) etcdctl --endpoints "https://192.168.13.51:2379,https://192.168.13.52:2379,https://192.168.13.53:2379"  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key endpoint status --write-out="table"
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|          ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://192.168.13.51:2379 | a78dd15fd54968fb |   3.4.9 |  4.2 MB |      true |      false |         3 |       9546 |               9546 |        |
| https://192.168.13.52:2379 |  8715488046f0887 |   3.4.9 |  4.2 MB |     false |      false |         3 |       9546 |               9546 |        |
| https://192.168.13.53:2379 | 676ef70c3ee42b24 |   3.4.9 |  4.1 MB |     false |      false |         3 |       9546 |               9546 |        |
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+

# master01.k8s.hs.com模拟故障，此时已经关机，etcd状态如下：
[root@master02 /etc/kubernetes/manifests]# docker exec -it $(docker ps -f name=etcd_etcd -q) etcdctl --endpoints "https://192.168.13.51:2379,https://192.168.13.52:2379,https://192.168.13.53:2379"  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key endpoint status --write-out="table"
{"level":"warn","ts":"2021-04-29T12:34:21.772Z","caller":"clientv3/retry_interceptor.go:62","msg":"retrying of unary invoker failed","target":"passthrough:///https://192.168.13.51:2379","attempt":0,"error":"rpc error: code = DeadlineExceeded desc = context deadline exceeded"}
Failed to get the status of endpoint https://192.168.13.51:2379 (context deadline exceeded)
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|          ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://192.168.13.52:2379 |  8715488046f0887 |   3.4.9 |  4.2 MB |      true |      false |         4 |       9729 |               9729 |        |                          --master02单选为leader了
| https://192.168.13.53:2379 | 676ef70c3ee42b24 |   3.4.9 |  4.1 MB |     false |      false |         4 |       9729 |               9729 |        |
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
[root@master02 ~/manifests/addons/network]# docker exec -it $(docker ps -f name=etcd_etcd -q) etcdctl --endpoints "https://192.168.13.51:2379,https://192.168.13.52:2379,https://192.168.13.53:2379"  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key member list --write-out="table"
+------------------+---------+---------------------+----------------------------+----------------------------+------------+
|        ID        | STATUS  |        NAME         |         PEER ADDRS         |        CLIENT ADDRS        | IS LEARNER |
+------------------+---------+---------------------+----------------------------+----------------------------+------------+
|  8715488046f0887 | started | master02.k8s.hs.com | https://192.168.13.52:2380 | https://192.168.13.52:2379 |      false |
| 676ef70c3ee42b24 | started | master03.k8s.hs.com | https://192.168.13.53:2380 | https://192.168.13.53:2379 |      false |
| a78dd15fd54968fb | started | master01.k8s.hs.com | https://192.168.13.51:2380 | https://192.168.13.51:2379 |      false |
+------------------+---------+---------------------+----------------------------+----------------------------+------------+
注：成员还有3个，确定此节点是故障节点需要member remove进行删除，否则不要轻易删除(节点关机，开机会回归集群时不能删除)，另外learner和leader很像，不要看错,learner是etcd3.0加入的对象机制。

# 配置tengine，移除192.168.13.51:6443，然后获取节点状态
[root@master03 /etc/kubernetes/manifests]# kubectl get nodes -o wide 
NAME                  STATUS     ROLES    AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION          CONTAINER-RUNTIME
master01.k8s.hs.com   NotReady   master   43m   v1.19.0   192.168.13.51   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.6
master02.k8s.hs.com   Ready      master   40m   v1.19.0   192.168.13.52   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
master03.k8s.hs.com   Ready      master   38m   v1.19.0   192.168.13.53   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
node01.k8s.hs.com     Ready      <none>   36m   v1.19.0   192.168.13.56   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
node02.k8s.hs.com     Ready      <none>   36m   v1.19.0   192.168.13.57   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5

# 移除节点
--驱逐节点master01.k8s.hs.com上的pod，并且忽略本地的daemonset控制器：
[root@master02 ~]# kubectl drain master01.k8s.hs.com --delete-local-data --ignore-daemonsets --force   --一直卡住，使用ctrl+c结束

# 期间遇到小插曲，node上flannel接口存在，始终报cni接口已经存在，不能创建，需要在相关node上进行删除相关接口，等待集群重建
[root@salt /shell]# cat resetk8snet.sh 
#!/bin/sh
systemctl stop kubelet
systemctl stop docker
ifconfig cni0 down
ifconfig flannel.1 down
ifconfig del flannel.1
ifconfig del cni0
ip link del flannel.1
ip link del cni0
yum install bridge-utils
brctl delbr flannel.1
brctl delbr cni0
rm -rf /var/lib/cni/flannel/* && rm -rf /var/lib/cni/networks/cbr0/* && ip link delete cni0 && rm -rf /var/lib/cni/network/cni0/*
systemctl start docker
systemctl start kubelet

[root@master02 /etc/kubernetes/manifests]# kubectl get nodes -o wide
NAME                  STATUS                        ROLES    AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION          CONTAINER-RUNTIME
master01.k8s.hs.com   NotReady,SchedulingDisabled   master   46m   v1.19.0   192.168.13.51   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.6
master02.k8s.hs.com   Ready                         master   43m   v1.19.0   192.168.13.52   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
master03.k8s.hs.com   Ready                         master   41m   v1.19.0   192.168.13.53   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
node01.k8s.hs.com     Ready                         <none>   39m   v1.19.0   192.168.13.56   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
node02.k8s.hs.com     Ready                         <none>   39m   v1.19.0   192.168.13.57   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
[root@master02 ~]# kubectl delete nodes master01.k8s.hs.com    --删除此节点
node "master01.k8s.hs.com" deleted
[root@master02 ~]# kubectl get pods -n kube-system -o wide  

# 查看时始终还在master01.k8s.hs.com，过一会自动删除已经删除节点的相关信息Pod
NAME                                          READY   STATUS        RESTARTS   AGE   IP              NODE                  NOMINATED NODE   READINESS GATES
coredns-6d56c8448f-m8pjm                      1/1     Terminating   1          17d   10.244.0.5      master01.k8s.hs.com   <none>           <none>
coredns-6d56c8448f-sdk7q                      1/1     Terminating   1          17d   10.244.0.4      master01.k8s.hs.com   <none>           <none>
etcd-master01.k8s.hs.com                      1/1     Running       1          17d   192.168.13.51   master01.k8s.hs.com   <none>           <none>
etcd-master02.k8s.hs.com                      1/1     Running       0          17d   192.168.13.52   master02.k8s.hs.com   <none>           <none>
etcd-master03.k8s.hs.com                      1/1     Running       1          17d   192.168.13.53   master03.k8s.hs.com   <none>           <none>
kube-apiserver-master01.k8s.hs.com            1/1     Running       0          10d   192.168.13.51   master01.k8s.hs.com   <none>           <none>
kube-apiserver-master02.k8s.hs.com            1/1     Running       0          10d   192.168.13.52   master02.k8s.hs.com   <none>           <none>
kube-apiserver-master03.k8s.hs.com            1/1     Running       0          10d   192.168.13.53   master03.k8s.hs.com   <none>           <none>
kube-controller-manager-master01.k8s.hs.com   1/1     Running       3          17d   192.168.13.51   master01.k8s.hs.com   <none>           <none>
kube-controller-manager-master02.k8s.hs.com   1/1     Running       1          17d   192.168.13.52   master02.k8s.hs.com   <none>           <none>
kube-controller-manager-master03.k8s.hs.com   1/1     Running       2          17d   192.168.13.53   master03.k8s.hs.com   <none>           <none>
kube-flannel-ds-amd64-76prw                   1/1     Running       0          10d   192.168.13.56   node01.k8s.hs.com     <none>           <none>
kube-flannel-ds-amd64-9snfq                   1/1     Running       0          10d   192.168.13.53   master03.k8s.hs.com   <none>           <none>
kube-flannel-ds-amd64-ljgkb                   1/1     Running       0          10d   192.168.13.51   master01.k8s.hs.com   <none>           <none>
kube-flannel-ds-amd64-s9prl                   1/1     Running       0          10d   192.168.13.57   node02.k8s.hs.com     <none>           <none>
kube-flannel-ds-amd64-v85nk                   1/1     Running       0          10d   192.168.13.52   master02.k8s.hs.com   <none>           <none>
kube-proxy-2s8z7                              1/1     Running       1          17d   192.168.13.51   master01.k8s.hs.com   <none>           <none>
kube-proxy-crwhp                              1/1     Running       0          17d   192.168.13.52   master02.k8s.hs.com   <none>           <none>
kube-proxy-f69lx                              1/1     Running       1          17d   192.168.13.57   node02.k8s.hs.com     <none>           <none>
kube-proxy-fnmnp                              1/1     Running       1          17d   192.168.13.53   master03.k8s.hs.com   <none>           <none>
kube-proxy-vdbtl                              1/1     Running       0          17d   192.168.13.56   node01.k8s.hs.com     <none>           <none>
kube-scheduler-master01.k8s.hs.com            1/1     Running       2          17d   192.168.13.51   master01.k8s.hs.com   <none>           <none>
kube-scheduler-master02.k8s.hs.com            1/1     Running       2          17d   192.168.13.52   master02.k8s.hs.com   <none>           <none>
kube-scheduler-master03.k8s.hs.com            1/1     Running       1          17d   192.168.13.53   master03.k8s.hs.com   <none>           <none>
metrics-server-554df5cbcf-zt44l               1/1     Running       1          17d   10.244.2.3      node02.k8s.hs.com     <none>           <none>

# 因为模拟节点故障，所以要删除etcd中的master01.k8s.hs.com信息
[root@master02 ~/manifests/addons/network]# docker exec -it $(docker ps -f name=etcd_etcd -q) etcdctl --endpoints "https://192.168.13.51:2379,https://192.168.13.52:2379,https://192.168.13.53:2379"  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key member remove a78dd15fd54968fb
Member a78dd15fd54968fb removed from cluster 788c742b9ad97c82
[root@master02 ~/manifests/addons/network]# docker exec -it $(docker ps -f name=etcd_etcd -q) etcdctl --endpoints "https://192.168.13.51:2379,https://192.168.13.52:2379,https://192.168.13.53:2379"  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key member list --write-out="table"
+------------------+---------+---------------------+----------------------------+----------------------------+------------+
|        ID        | STATUS  |        NAME         |         PEER ADDRS         |        CLIENT ADDRS        | IS LEARNER |
+------------------+---------+---------------------+----------------------------+----------------------------+------------+
|  8715488046f0887 | started | master02.k8s.hs.com | https://192.168.13.52:2380 | https://192.168.13.52:2379 |      false |
| 676ef70c3ee42b24 | started | master03.k8s.hs.com | https://192.168.13.53:2380 | https://192.168.13.53:2379 |      false |
+------------------+---------+---------------------+----------------------------+----------------------------+------------+
注：已经在etcd中删除集群节点信息
```



#### 1.12.2 master节点添加

```bash
# 在新节点上配置环境和安装命令行工具
[root@salt /srv/salt/base]# salt 'master01*' state.highstate 
[root@salt /srv/salt/base/init]#  salt 'master01.k8s*' state.sls init.k8s-repo saltenv=base 
[root@salt /srv/salt/base/init]#  salt 'master01.k8s*' cmd.run 'yum install -y kubeadm-1.19.0-0 kubelet-1.19.0-0 kubectl-1.19.0-0'
[root@salt /srv/salt/base/init]#  salt 'master01.k8s*' cmd.run 'yum list installed | grep kube'
master01.k8s.hs.com:
    cri-tools.x86_64                 1.13.0-0                       @kubernetes-repo
    kubeadm.x86_64                   1.19.0-0                       @kubernetes-repo
    kubectl.x86_64                   1.19.0-0                       @kubernetes-repo
    kubelet.x86_64                   1.19.0-0                       @kubernetes-repo
    kubernetes-cni.x86_64            0.8.7-0                        @kubernetes-repo

# 在新节点上加入到现有集群：
kubeadm join k8s-api.k8s.hs.com:6443 --token poz5y3.206amiyzawdzlueo     --discovery-token-ca-cert-hash sha256:437e89e657eca27c9d0311c4f76d7dd3f9d3fe9de7eb10016d626ac1133dd5bb  --control-plane --certificate-key be1fd45e9911967deef4cdbf35ee5a16671df886956270fd9a26591e190648ea
[root@master01 ~]# mkdir -p $HOME/.kube
[root@master01 ~]# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
[root@master01 ~]# sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 加入集群成功，查看集群状态信息
[root@master01 ~]# kubectl get nodes -o wide 
NAME                  STATUS   ROLES    AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION          CONTAINER-RUNTIME
master01.k8s.hs.com   Ready    master   38s   v1.19.0   192.168.13.51   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.6
master02.k8s.hs.com   Ready    master   13h   v1.19.0   192.168.13.52   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
master03.k8s.hs.com   Ready    master   13h   v1.19.0   192.168.13.53   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
node01.k8s.hs.com     Ready    <none>   13h   v1.19.0   192.168.13.56   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
node02.k8s.hs.com     Ready    <none>   13h   v1.19.0   192.168.13.57   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
# 最后把192.168.13.51:6443加入到k8s-api-.k8s.hs.com后端服务端点
```



### 1.13 节点维护
```bash
# 将节点master01.k8s.hs.com置为不可调度
[root@master02 ~]# kubectl cordon master01.k8s.hs.com
node/master01.k8s.hs.com cordoned
# 驱逐节点上的pod到别的节点运行
[root@master01 ~]# kubectl drain master01.k8s.hs.com --ignore-daemonsets 
node/master01.k8s.hs.com already cordoned
WARNING: ignoring DaemonSet-managed Pods: kube-system/kube-flannel-ds-amd64-hrzj4, kube-system/kube-proxy-8jrgb
node/master01.k8s.hs.com drained
[root@master01 ~]# kubectl get nodes  -o wide 
NAME                  STATUS                     ROLES    AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION          CONTAINER-RUNTIME
master01.k8s.hs.com   Ready,SchedulingDisabled   master   72m   v1.19.0   192.168.13.51   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.6
master02.k8s.hs.com   Ready                      master   15h   v1.19.0   192.168.13.52   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
master03.k8s.hs.com   Ready                      master   15h   v1.19.0   192.168.13.53   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
node01.k8s.hs.com     Ready                      <none>   15h   v1.19.0   192.168.13.56   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
node02.k8s.hs.com     Ready                      <none>   15h   v1.19.0   192.168.13.57   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
# 恢复集群为可调度
[root@master01 ~]# kubectl uncordon master01.k8s.hs.com  
node/master01.k8s.hs.com uncordoned
[root@master01 ~]# kubectl get nodes 
NAME                  STATUS   ROLES    AGE   VERSION
master01.k8s.hs.com   Ready    master   74m   v1.19.0
master02.k8s.hs.com   Ready    master   15h   v1.19.0
master03.k8s.hs.com   Ready    master   15h   v1.19.0
node01.k8s.hs.com     Ready    <none>   15h   v1.19.0
node02.k8s.hs.com     Ready    <none>   15h   v1.19.0
# 查看scheduler的leader在哪个master上
[root@master01 ~]# kubectl get endpoints kube-scheduler -n kube-system -o yaml | grep holderIdentity
    control-plane.alpha.kubernetes.io/leader: '{"holderIdentity":"master02.k8s.hs.com_5dbd75ef-b62e-47ea-9b78-631d7fde8645","leaseDurationSeconds":15,"acquireTime":"2021-04-29T16:23:27Z","renewTime":"2021-04-30T05:52:44Z","leaderTransitions":5}'
# 查看ontroller-manager的leader在哪个master上
[root@master01 ~]# kubectl get endpoints kube-controller-manager -n kube-system -o yaml | grep holderIdentity
    control-plane.alpha.kubernetes.io/leader: '{"holderIdentity":"master03.k8s.hs.com_575ffaa6-ff7b-48a4-896b-014d2ab8c730","leaseDurationSeconds":15,"acquireTime":"2021-04-29T16:23:27Z","renewTime":"2021-04-30T05:52:54Z","leaderTransitions":4}'
# apiserver端口是6443，使用kubectl命令时会去请求master，所以不能返回时代理apiserver是故障的。apiserver是无状态的。
# 查看etcd集群状态 
[root@master01 ~]#  docker exec -it $(docker ps -f name=etcd_etcd -q) etcdctl --endpoints "https://192.168.13.51:2379,https://192.168.13.52:2379,https://192.168.13.53:2379"  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key endpoint status --write-out="table"
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|          ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://192.168.13.51:2379 | 6b31542d4962986f |   3.4.9 |  4.2 MB |     false |      false |         9 |     186012 |             186012 |        |
| https://192.168.13.52:2379 |  8715488046f0887 |   3.4.9 |  4.2 MB |      true |      false |         9 |     186012 |             186012 |        |
| https://192.168.13.53:2379 | 676ef70c3ee42b24 |   3.4.9 |  4.1 MB |     false |      false |         9 |     186012 |             186012 |        |
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
# 查看集群状态
[root@master02 ~]# kubectl get cs 
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS    MESSAGE             ERROR
scheduler            Healthy   ok                  
controller-manager   Healthy   ok                  
etcd-0               Healthy   {"health":"true"}   
```

### 1.14 集群升级

一、给正在对外提供服务的 Kubernetes 集群升级，就好比是“给飞行中的飞机换引擎”。因为集群升级面临着众多难点，也使得众多的 Kubernetes 集群维护者对集群升级这件事情比较紧张。
我们可以通过详细的升级预检，来消除集群升级的不确定性。对于上面列举的集群升级的难点，我们也可以分别进行详细的升级预检，对症下药，将难点逐一击破。升级预检主要可以分为三个方面：
核心组件健康检查、节点配置检查、云资源检查
1. 核心组件健康检查
说到核心组件健康检查，就不得不剖析一下集群的健康对于集群升级的重要性。一个不健康的集群很可能会在升级中出现各种异常的问题，就算侥幸完成了升级，各种问题也会在后续使用中逐渐凸显出来。
有人会说，我的集群看起来挺健康的，但是升级之后就出现问题了。一般来说，之所以会发生这种情况，是因为在集群在升级之前，这个问题已经存在了，只不过是在经历了集群升级之后才显现出来。
在了解了核心组件健康检查的必要性之后，我们来看一下都需要对那些组件进行检查：
网络组件：需要确保网络组件版本和需要升级到的目标 Kubernetes 版本兼容；
apiservice：需要确保集群内的 apiservice 都可用；
2. 节点配置检查
节点作为承载 Kubernetes 的底层元计算资源，不仅运行着 Kubelet、Docker 等重要的系统进程，也充当着集群和底层硬件交互接口的角色。
确保节点的健康性和配置的正确性是确保整个集群健康性重要的一环。下面就对所需的检查项进行讲解。
操作系统配置：需要确定基础的系统组件（yum、systemd 和 ntp 等系统服务是否正常）和内核参数是否配置合理；
kubelet：需要确定 kubelet 的进程健康、配置正确；
Docker：需要确定 Docker 的进程健康、配置正确。
3. 云资源检查
运行在云上的 Kubernetes 集群依赖着众多云资源，一旦集群所依赖的云资源不健康或者配置错误，就会影响到整个集群的正常运行。我们主要对下列云资源的状态和配置进行预检：
apiserver 所使用的 SLB：需要确定实例的健康状态和端口配置（转发配置和访问控制配置等）；
集群所使用的 VPC 和 VSwitch：需要确定实例的健康状况；
集群内的 ECS 实例：需要确定其健康状况和网络配置。

二、两种常见的升级方式
在软件升级领域，有两种主流的软件升级方式，即原地升级和替换升级。这两种升级方式同样适用于 Kubernetes 集群，它们采用了不同软件升级思路，但也都存在着各自的利弊。下面我们来对这两种集群升级方式进行逐一讲解。
1. 原地升级
原地升级是一种精细化的、对这个那个集群改动量相对较小的一种升级方式。在升级容器的 worker 节点时，该升级方式会通过在 ECS 上原地替换 Kubernetes 组件的方式（主要为 kubelet 和其相关组件），完成整个集群的升级工作。阿里云容器服务 Kubernetes 为客户提供的集群升级就是基于这种方式的。
以将 Kubernetes 的版本从 1.14 升级到 1.16 为例。首先我们会对 ECS A 上的原本为 1.14 的 Kubelet 及其配置升级为 1.16，在完成节点 ECS A 上的组件升级之后，该节点也就被成功的升级到了 1.16。然后我们再对 ECS B 进行相同的操作，将其升级为 1.16，从而完成整个集群的升级工作。
1）优点
原地升级通过原地替换 kubelet 组件的方式对节点进行版本升级，从而保证了节点上的 Pod 不会因为集群升级而重建，确保了业务的连贯性；
该种升级方式不会对底层 ECS 本身进行修改和替换，保证了依赖特定节点调度的业务可以正常运行，也对 ECS 的包年包月客户更加友好。
2）缺点
原地升级方式需要在节点上进行一系列升级操作，才能完成整个节点的升级工作，这就导致整个升级过程不够原子化，可能会在中间的某一步骤失败，从而导致该节点升级失败；
原地升级的另一个缺点是需要预留一定量的资源，只有在资源足够的情况下升级程序才能在 ECS 上完成对节点的升级。
2. 替换升级
替换升级又称轮转升级，相对于原地升级，替换升级是一种更加粗狂和原子化的升级方式。替换升级会逐个将旧版本的节点从集群中移除，并用新版本全新的节点来替换，从而完成整个 Kubernetes 集群的升级工作。

同样以将 Kubernetes 的版本从 1.14 升级到 1.16 为例。使用替代轮转方式的情况下，我们会将集群中 1.14 版本的节点依次进行排水并从集群中移除，并直接加入 1.16 版本的节点。即将 1.14 节点的 ECS A 从节点剔除，并将 1.16 节点的 ECS C 加入集群，再将 ECS B 从集群中删除，最后将 ECS D 加入到集群中。
1）优点
替代升级通过将旧版本的节点替换为新版本的节点从而完成集群升级。这个替换的过程相较于原地升级更为原子化，也不存在那么复杂的中间状态，所以也不需要在升级之前进行太多的前置检查。相对应地，升级过程中可能会出现的各种稀奇古怪的问题也会减少很多。

2）缺点
替代升级将集群内的节点全部进行替换和重置，所有节点都会经历排水的过程，这就会使集群内的 pod 进行大量迁移重建，对于 pod 重建容忍度比较低的业务、只有单副本的应用、stateful set 等相关应用不够友好，可能会因此发生不可用或者故障；
所有的节点经历重置，储存在节点本地磁盘上的数据都会丢失；
这种升级方式可能会带来宿主机 IP 变化等问题，对包年包月用户也不够友好。

三、集群升级三部曲
一个 Kubernetes 集群主要由负责集群管控的 master，执行工作负载的 worker 和众多功能性的系统组件组成。对一个 Kubernetes 集群升级，也就是对集群中的这三个部分进行分别升级。
故集群升级的三部曲为：
滚动升级 master
分批升级 worker
系统组件升级（主要为 CoreDNS，kube-proxy 等核心组件）

1. 滚动升级 master
master 作为集群的大脑，承担了与使用者交互、任务调度和各种功能性的任务处理。集群 master 的部署方式也比较多样，可以通过 static pod 进行部署，可以通过本地进程进行部署，也可以通过 Kubernetes on Kubernetes 的方式在另一个集群内通过 pod 的方式部署。
总而言之，无论 master 为哪种部署方式，想要升级 master 主要就是对 master 中的三大件进行版本升级，主要包括：
升级 kube-apiserver
升级 kube-controller-manager
升级 kube-scheduler
需要注意，为了保证 Kubernetes apiserver 的可用性不中断，master 中的 kube-apiserver 最少需要有两个，这样才可以实现滚动升级，从而保证 apiserver 不会出现 downtime。

2. 分批升级 worker
在完成 master 的升级工作之后，我们才可以开始对 worker 进行升级。Worker 升级主要是对节点上的 kubelet 及其依赖组件（如 cni 等）进行升级。为了保证集群中 worker 不会同时发生大批量的 kubelet 重启，所以我们需要对 worker 节点进行分批升级。
需要注意，我们必须要先升级 master，再升级 worker。因为高版本的 kubelet 在连接低版本的 master 时，很可能会出现不兼容的情况，从而导致节点 not ready。对于低版本的 kubelet 连接高版本的 apiserver，开源社区保证了 apiserver 对于 kubelet 两个版本的向后兼容性，即 1.14 的 kubelet 可以连接到 1.16 的 apiserver，而不会发生兼容性问题。

3. 核心系统组件升级
为了保证集群中各个组件的兼容性，我们需要在升级集群的同时对集群中的核心系统组件进行同步升级，主要包括：
Dns 组件：根据社区的版本兼容矩阵，将 CoreDNS 的版本升级为与集群版本相对应的版本；
社区的版本兼容矩阵：https://github.com/coredns/deployment/blob/master/kubernetes/CoreDNS-k8s_version.md
网络转发组件：Kube-proxy 的版本是跟随 Kubernetes 的版本进行演进的，所以我们需要将 kube-proxy 的版本升级到与 Kubernetes 版本相同的版本。


#### 1.14.1 kubernetes v1.19.0证书更新
```bash
[root@master01 ~]# kubeadm alpha certs check-expiration
CERTIFICATE                EXPIRES                  RESIDUAL TIME   CERTIFICATE AUTHORITY   EXTERNALLY MANAGED
admin.conf                 Apr 30, 2022 01:46 UTC   364d                                    no      
apiserver                  Apr 30, 2022 01:46 UTC   364d            ca                      no      
apiserver-etcd-client      Apr 30, 2022 01:46 UTC   364d            etcd-ca                 no      
apiserver-kubelet-client   Apr 30, 2022 01:46 UTC   364d            ca                      no      
controller-manager.conf    Apr 30, 2022 01:46 UTC   364d                                    no      
etcd-healthcheck-client    Apr 30, 2022 01:46 UTC   364d            etcd-ca                 no      
etcd-peer                  Apr 30, 2022 01:46 UTC   364d            etcd-ca                 no      
etcd-server                Apr 30, 2022 01:46 UTC   364d            etcd-ca                 no      
front-proxy-client         Apr 30, 2022 01:46 UTC   364d            front-proxy-ca          no      
scheduler.conf             Apr 30, 2022 01:46 UTC   364d                                    no      

CERTIFICATE AUTHORITY   EXPIRES                  RESIDUAL TIME   EXTERNALLY MANAGED
ca                      Apr 27, 2031 11:51 UTC   9y              no      
etcd-ca                 Apr 27, 2031 11:51 UTC   9y              no      
front-proxy-ca          Apr 27, 2031 11:51 UTC   9y              no      


# 自kubernentes v1.15以后，可以使用官方命令续订证书，每次续订将会是一年，命令如下：
[root@master01 ~]# kubeadm alpha certs check-expiration
CERTIFICATE                EXPIRES                  RESIDUAL TIME   CERTIFICATE AUTHORITY   EXTERNALLY MANAGED
admin.conf                 Apr 30, 2022 06:18 UTC   364d                                    no      
apiserver                  Apr 30, 2022 06:18 UTC   364d            ca                      no      
apiserver-etcd-client      Apr 30, 2022 06:18 UTC   364d            etcd-ca                 no      
apiserver-kubelet-client   Apr 30, 2022 06:18 UTC   364d            ca                      no      
controller-manager.conf    Apr 30, 2022 06:18 UTC   364d                                    no      
etcd-healthcheck-client    Apr 30, 2022 06:18 UTC   364d            etcd-ca                 no      
etcd-peer                  Apr 30, 2022 06:18 UTC   364d            etcd-ca                 no      
etcd-server                Apr 30, 2022 06:18 UTC   364d            etcd-ca                 no      
front-proxy-client         Apr 30, 2022 06:18 UTC   364d            front-proxy-ca          no      
scheduler.conf             Apr 30, 2022 06:18 UTC   364d                                    no      

CERTIFICATE AUTHORITY   EXPIRES                  RESIDUAL TIME   EXTERNALLY MANAGED
ca                      Apr 27, 2031 11:51 UTC   9y              no      
etcd-ca                 Apr 27, 2031 11:51 UTC   9y              no      
front-proxy-ca          Apr 27, 2031 11:51 UTC   9y              no      

# 也可使用此链接更新master端的证书，node端的kubelet证书会自动更新，不用手动更新。
URL: https://github.com/jacknotes/update-kube-cert
该脚本用于处理已过期或者即将过期的kubernetes集群证书
kubeadm生成的证书有效期为为1年，该脚本可将kubeadm生成的证书有效期更新为10年
该脚本只处理master节点上的证书：kubeadm默认配置了kubelet证书自动更新，node节点kubelet.conf所指向的证书会自动更新
小于v1.17版本的master初始化节点(执行kubeadm init的节点) kubelet.conf里的证书并不会自动更新，这算是一个bug，该脚本会一并处理更新master节点的kubelet.conf所包含的证书
```



#### 1.14.2 集群升级

基于kubeadm部署的k8s集群从kubernetes v1.19.0升级到kubernetes v1.19.1，升级工作的基本流程如下：
升级主控制平面节点
升级其他控制平面节点
升级工作节点


**查看当前集群状态**
```bash
[root@master01 ~]# kubectl get nodes -o wide 
NAME                  STATUS   ROLES    AGE     VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION          CONTAINER-RUNTIME
master01.k8s.hs.com   Ready    master   4h10m   v1.19.0   192.168.13.51   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.6
master02.k8s.hs.com   Ready    master   18h     v1.19.0   192.168.13.52   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
master03.k8s.hs.com   Ready    master   18h     v1.19.0   192.168.13.53   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
node01.k8s.hs.com     Ready    <none>   17h     v1.19.0   192.168.13.56   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
node02.k8s.hs.com     Ready    <none>   17h     v1.19.0   192.168.13.57   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
[root@master01 ~]# kubectl get endpoints kube-scheduler -n kube-system -o yaml | grep holderIdentity
    control-plane.alpha.kubernetes.io/leader: '{"holderIdentity":"master02.k8s.hs.com_5dbd75ef-b62e-47ea-9b78-631d7fde8645","leaseDurationSeconds":15,"acquireTime":"2021-04-29T16:23:27Z","renewTime":"2021-04-30T05:52:44Z","leaderTransitions":5}'
[root@master01 ~]# kubectl get endpoints kube-controller-manager -n kube-system -o yaml | grep holderIdentity
    control-plane.alpha.kubernetes.io/leader: '{"holderIdentity":"master03.k8s.hs.com_575ffaa6-ff7b-48a4-896b-014d2ab8c730","leaseDurationSeconds":15,"acquireTime":"2021-04-29T16:23:27Z","renewTime":"2021-04-30T05:52:54Z","leaderTransitions":4}'
[root@master01 ~]# docker exec -it $(docker ps -f name=etcd_etcd -q) etcdctl --endpoints "https://192.168.13.51:2379,https://192.168.13.52:2379,https://192.168.13.53:2379"  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key endpoint status --write-out="table"
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|          ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://192.168.13.51:2379 | 6b31542d4962986f |   3.4.9 |  4.2 MB |     false |      false |         9 |     216798 |             216798 |        |
| https://192.168.13.52:2379 |  8715488046f0887 |   3.4.9 |  4.2 MB |      true |      false |         9 |     216798 |             216798 |        |
| https://192.168.13.53:2379 | 676ef70c3ee42b24 |   3.4.9 |  4.1 MB |     false |      false |         9 |     216798 |             216798 |        |
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
[root@master01 ~]# kubectl get cs
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS    MESSAGE             ERROR
controller-manager   Healthy   ok                  
scheduler            Healthy   ok                  
etcd-0               Healthy   {"health":"true"}  
```

**升级**
```bash
1. 查看最新版本
[root@master01 ~]# yum list --showduplicates kubeadm 
kubeadm.x86_64                                                                                     1.19.0-0                                                                                
kubeadm.x86_64                                                                                     1.19.10-0 
2. 升级控制平面节点
2.1 升级第一个控制面节点
2.1.1 在第一个控制平面节点上，升级 kubeadm :
[root@master01 ~]# yum install -y kubeadm-1.19.10-0 
2.1.2 验证下载操作正常，并且 kubeadm 版本正确：
[root@master01 ~]# kubeadm version
[root@master01 ~]# kubeadm version
kubeadm version: &version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.10", GitCommit:"98d5dc5d36d34a7ee13368a7893dcb400ec4e566", GitTreeState:"clean", BuildDate:"2021-04-15T03:26:23Z", GoVersion:"go1.15.10", Compiler:"gc", Platform:"linux/amd64"}
2.1.3 腾空控制平面节点：
[root@master01 ~]# kubectl drain master01.k8s.hs.com --ignore-daemonsets
node/master01.k8s.hs.com already cordoned
WARNING: ignoring DaemonSet-managed Pods: kube-system/kube-flannel-ds-amd64-hrzj4, kube-system/kube-proxy-8jrgb
node/master01.k8s.hs.com drained
2.1.4 在控制面节点上，运行升级计划信息：
[root@master01 ~]# sudo kubeadm upgrade plan
[upgrade/config] Making sure the configuration is correct:
[upgrade/config] Reading configuration from the cluster...
[upgrade/config] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[preflight] Running pre-flight checks.
[upgrade] Running cluster health checks
[upgrade] Fetching available versions to upgrade to
[upgrade/versions] Cluster version: v1.19.0
[upgrade/versions] kubeadm version: v1.19.10
I0430 14:27:16.722963    6378 version.go:255] remote version is much newer: v1.21.0; falling back to: stable-1.19
[upgrade/versions] Latest stable version: v1.19.10
[upgrade/versions] Latest stable version: v1.19.10
[upgrade/versions] Latest version in the v1.19 series: v1.19.10
[upgrade/versions] Latest version in the v1.19 series: v1.19.10

Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
COMPONENT   CURRENT       AVAILABLE
kubelet     5 x v1.19.0   v1.19.10

Upgrade to the latest version in the v1.19 series:

COMPONENT                 CURRENT   AVAILABLE
kube-apiserver            v1.19.0   v1.19.10
kube-controller-manager   v1.19.0   v1.19.10
kube-scheduler            v1.19.0   v1.19.10
kube-proxy                v1.19.0   v1.19.10
CoreDNS                   1.7.0     1.7.0
etcd                      3.4.9-1   3.4.13-0

You can now apply the upgrade by executing the following command:

	kubeadm upgrade apply v1.19.10

_____________________________________________________________________


The table below shows the current state of component configs as understood by this version of kubeadm.
Configs that have a "yes" mark in the "MANUAL UPGRADE REQUIRED" column require manual config upgrade or
resetting to kubeadm defaults before a successful upgrade can be performed. The version to manually
upgrade to is denoted in the "PREFERRED VERSION" column.

API GROUP                 CURRENT VERSION   PREFERRED VERSION   MANUAL UPGRADE REQUIRED
kubeproxy.config.k8s.io   v1alpha1          v1alpha1            no
kubelet.config.k8s.io     v1beta1           v1beta1             no
_____________________________________________________________________
[root@master01 ~]# kubeadm upgrade apply v1.19.10
[upgrade/config] Making sure the configuration is correct:
[upgrade/config] Reading configuration from the cluster...
[upgrade/config] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[preflight] Running pre-flight checks.
[upgrade] Running cluster health checks
[upgrade/version] You have chosen to change the cluster version to "v1.19.10"
[upgrade/versions] Cluster version: v1.19.0
[upgrade/versions] kubeadm version: v1.19.10
[upgrade/confirm] Are you sure you want to proceed with the upgrade? [y/N]: y
# 结果
upgrade/successful] SUCCESS! Your cluster was upgraded to "v1.19.10". Enjoy!
[upgrade/kubelet] Now that your control plane is upgraded, please proceed with upgrading your kubelets if you haven't already done so.
2.1.5 取消对控制面节点的驱逐保护：
[root@master01 ~]# kubectl uncordon master01.k8s.hs.com
node/master01.k8s.hs.com uncordoned
2.2 升级其他控制面节点 
2.2.1 在第二个控制平面上升级kubeadm：
[root@master02 ~]#  yum install -y kubeadm-1.19.10-0
2.2.2 升级第二个控制平面，期间此平面会对etcd,apiserver,controller-manager,scheduler的pod进行重新构建
[root@master02 ~]# kubeadm upgrade node   
2.2.3  在第三个控制平面上升级kubeadm：
[root@master03 ~]#  yum install -y kubeadm-1.19.10-0
2.2.4 升级第三个控制平面，期间此平面会对etcd,apiserver,controller-manager,scheduler的pod进行重新构建
[root@master03 ~]# kubeadm upgrade node   
2.3.1 升级第一个控制平面的kubelet 和 kubectl ----此操作为保险起见应一个一个来，等待完成后再升级第二个
[root@master01 ~]# yum install -y kubectl-1.19.10-0 kubelet-1.19.10-0
[root@master01 ~]# systemctl daemon-reload
[root@master01 ~]# systemctl restart kubelet    
[root@master01 ~]# kubectl get nodes -o wide  --重启kubelet后过几秒种就可以看到当前控制平面版本了
NAME                  STATUS   ROLES    AGE    VERSION    INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION          CONTAINER-RUNTIME
master01.k8s.hs.com   Ready    master   5h1m   v1.19.10   192.168.13.51   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.6
master02.k8s.hs.com   Ready    master   18h    v1.19.0    192.168.13.52   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
master03.k8s.hs.com   Ready    master   18h    v1.19.0    192.168.13.53   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
node01.k8s.hs.com     Ready    <none>   18h    v1.19.0    192.168.13.56   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
node02.k8s.hs.com     Ready    <none>   18h    v1.19.0    192.168.13.57   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
2.3.2 升级第二个控制平面的kubelet 和 kubectl
[root@master02 ~]# yum install -y kubectl-1.19.10-0 kubelet-1.19.10-0
[root@master02 ~]# systemctl daemon-reload
[root@master02 ~]# systemctl restart kubelet 
2.3.3 升级第三个控制平面的kubelet 和 kubectl
[root@master03 ~]# yum install -y kubectl-1.19.10-0 kubelet-1.19.10-0
[root@master03 ~]# systemctl daemon-reload
[root@master03 ~]# systemctl restart kubelet 
2.3.4 查看节点信息
[root@master01 ~]# kubectl get nodes -o wide 
NAME                  STATUS   ROLES    AGE    VERSION    INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION          CONTAINER-RUNTIME
master01.k8s.hs.com   Ready    master   5h5m   v1.19.10   192.168.13.51   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.6
master02.k8s.hs.com   Ready    master   18h    v1.19.10   192.168.13.52   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
master03.k8s.hs.com   Ready    master   18h    v1.19.10   192.168.13.53   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
node01.k8s.hs.com     Ready    <none>   18h    v1.19.0    192.168.13.56   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
node02.k8s.hs.com     Ready    <none>   18h    v1.19.0    192.168.13.57   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
2.4 升级工作节点：工作节点上的升级过程应该一次执行一个节点，或者一次执行几个节点，以不影响运行工作负载所需的最小容量。
2.4.1 升级 kubeadm：在所有工作节点升级 kubeadm
[root@node01 ~]#  yum install -y kubeadm-1.19.10-0
2.4.2 通过将节点标记为不可调度并逐出工作负载，为维护做好准备
[root@master01 ~]# kubectl drain node01.k8s.hs.com --ignore-daemonsets
node/node01.k8s.hs.com cordoned
WARNING: ignoring DaemonSet-managed Pods: kube-system/kube-flannel-ds-amd64-bfdsh, kube-system/kube-proxy-9jz7j
evicting pod kube-system/coredns-6d56c8448f-5557r
evicting pod default/myapp-deployment-b6bbc4f78-xsdwt
pod/myapp-deployment-b6bbc4f78-xsdwt evicted
pod/coredns-6d56c8448f-5557r evicted
node/node01.k8s.hs.com evicted
[root@master02 ~]# kubectl get pods -o wide -w   
# 在驱逐工作节点时我在另外的控制平面所查看到的。并且我的curl命令nginx服务也未断开，说明服务是可用的
NAME                               READY   STATUS    RESTARTS   AGE   IP           NODE                NOMINATED NODE   READINESS GATES
myapp-deployment-b6bbc4f78-qxhnk   1/1     Running   0          78m   10.244.4.3   node02.k8s.hs.com   <none>           <none>
myapp-deployment-b6bbc4f78-xsdwt   1/1     Running   0          78m   10.244.3.5   node01.k8s.hs.com   <none>           <none>
myapp-deployment-b6bbc4f78-xsdwt   1/1     Terminating   0          78m   10.244.3.5   node01.k8s.hs.com   <none>           <none>
myapp-deployment-b6bbc4f78-g4jlc   0/1     Pending       0          0s    <none>       <none>              <none>           <none>
myapp-deployment-b6bbc4f78-g4jlc   0/1     Pending       0          0s    <none>       node02.k8s.hs.com   <none>           <none>
myapp-deployment-b6bbc4f78-g4jlc   0/1     ContainerCreating   0          0s    <none>       node02.k8s.hs.com   <none>           <none>
myapp-deployment-b6bbc4f78-xsdwt   0/1     Terminating         0          78m   10.244.3.5   node01.k8s.hs.com   <none>           <none>
myapp-deployment-b6bbc4f78-g4jlc   0/1     Running             0          2s    10.244.4.4   node02.k8s.hs.com   <none>           <none>
myapp-deployment-b6bbc4f78-g4jlc   1/1     Running             0          5s    10.244.4.4   node02.k8s.hs.com   <none>           <none>
myapp-deployment-b6bbc4f78-xsdwt   0/1     Terminating         0          78m   10.244.3.5   node01.k8s.hs.com   <none>           <none>
myapp-deployment-b6bbc4f78-xsdwt   0/1     Terminating         0          78m   10.244.3.5   node01.k8s.hs.com   <none>           <none>
[root@master02 ~]# kubectl get pods -o wide   --此时都被驱逐到node02上了
NAME                               READY   STATUS    RESTARTS   AGE     IP           NODE                NOMINATED NODE   READINESS GATES
myapp-deployment-b6bbc4f78-g4jlc   1/1     Running   0          2m15s   10.244.4.4   node02.k8s.hs.com   <none>           <none>
myapp-deployment-b6bbc4f78-qxhnk   1/1     Running   0          81m     10.244.4.3   node02.k8s.hs.com   <none>           <none>
2.4.3 升级 kubelet 配置 
[root@node01 ~]# kubeadm upgrade node
[upgrade] Reading configuration from the cluster...
[upgrade] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[preflight] Running pre-flight checks
[preflight] Skipping prepull. Not a control plane node.
[upgrade] Skipping phase. Not a control plane node.
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[upgrade] The configuration for this node was successfully updated!
[upgrade] Now you should go ahead and upgrade the kubelet package using your package manager.
2.4.4 升级 kubelet 与 kubectl
[root@node01 ~]#  yum install -y kubectl-1.19.10-0 kubelet-1.19.10-0
[root@node01 ~]# systemctl daemon-reload 
[root@node01 ~]# systemctl restart kubelet
[root@master03 ~]# kubectl get nodes -o wide   
# 此时在控制平面上查看节点信息时，虽说还未被恢复为调度，但是控制平面从kubelete中获取信息node01已经升级为v1.19.10
NAME                  STATUS                     ROLES    AGE     VERSION    INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION          CONTAINER-RUNTIME
master01.k8s.hs.com   Ready                      master   5h17m   v1.19.10   192.168.13.51   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.6
master02.k8s.hs.com   Ready                      master   19h     v1.19.10   192.168.13.52   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
master03.k8s.hs.com   Ready                      master   19h     v1.19.10   192.168.13.53   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
node01.k8s.hs.com     Ready,SchedulingDisabled   <none>   19h     v1.19.10   192.168.13.56   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
node02.k8s.hs.com     Ready                      <none>   19h     v1.19.0    192.168.13.57   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
2.4.5 通过将节点标记为可调度，让节点重新上线
[root@master01 ~]# kubectl uncordon node01.k8s.hs.com 
node/node01.k8s.hs.com uncordoned
2.4.6 验证集群的状态
[root@master03 ~]# kubectl get nodes -o wide 
NAME                  STATUS   ROLES    AGE     VERSION    INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION          CONTAINER-RUNTIME
master01.k8s.hs.com   Ready    master   5h19m   v1.19.10   192.168.13.51   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.6
master02.k8s.hs.com   Ready    master   19h     v1.19.10   192.168.13.52   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
master03.k8s.hs.com   Ready    master   19h     v1.19.10   192.168.13.53   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
node01.k8s.hs.com     Ready    <none>   19h     v1.19.10   192.168.13.56   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
node02.k8s.hs.com     Ready    <none>   19h     v1.19.0    192.168.13.57   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
2.4.7 其它工作节点也是如此升级：
[root@master01 ~]# kubectl drain node02.k8s.hs.com --ignore-daemonsets
node/node02.k8s.hs.com cordoned
WARNING: ignoring DaemonSet-managed Pods: kube-system/kube-flannel-ds-amd64-6sglr, kube-system/kube-proxy-b2l8v
evicting pod kube-system/coredns-6d56c8448f-95jdf
evicting pod default/myapp-deployment-b6bbc4f78-g4jlc
evicting pod default/myapp-deployment-b6bbc4f78-qxhnk
pod/myapp-deployment-b6bbc4f78-g4jlc evicted
pod/myapp-deployment-b6bbc4f78-qxhnk evicted
pod/coredns-6d56c8448f-95jdf evicted
node/node02.k8s.hs.com evicted
2.4.8 升级node
[root@node02 ~]#  yum install -y kubeadm-1.19.10-0 && kubeadm upgrade node && yum install -y kubectl-1.19.10-0 kubelet-1.19.10-0 && systemctl daemon-reload && systemctl restart kubelet
2.4.9 通过将节点标记为可调度，让节点重新上线
[root@master01 ~]# kubectl uncordon node02.k8s.hs.com 
node/node02.k8s.hs.com uncordoned
2.5 升级后的集群状态：
[root@master03 ~]# kubectl get nodes -o wide 
NAME                  STATUS   ROLES    AGE     VERSION    INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION          CONTAINER-RUNTIME
master01.k8s.hs.com   Ready    master   5h26m   v1.19.10   192.168.13.51   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.6
master02.k8s.hs.com   Ready    master   19h     v1.19.10   192.168.13.52   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
master03.k8s.hs.com   Ready    master   19h     v1.19.10   192.168.13.53   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
node01.k8s.hs.com     Ready    <none>   19h     v1.19.10   192.168.13.56   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
node02.k8s.hs.com     Ready    <none>   19h     v1.19.10   192.168.13.57   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5                                                                         
[root@master02 ~]# kubectl get endpoints kube-scheduler -n kube-system -o yaml | grep holderIdentity
    control-plane.alpha.kubernetes.io/leader: '{"holderIdentity":"master01.k8s.hs.com_dad575bc-a5eb-4572-a4b8-66d9f453d3ce","leaseDurationSeconds":15,"acquireTime":"2021-04-30T06:37:12Z","renewTime":"2021-04-30T07:16:45Z","leaderTransitions":9}'
[root@master02 ~]# kubectl get endpoints kube-controller-manager -n kube-system -o yaml | grep holderIdentity
    control-plane.alpha.kubernetes.io/leader: '{"holderIdentity":"master02.k8s.hs.com_ec8edfa3-c6be-438c-b010-f979ddf0f79c","leaseDurationSeconds":15,"acquireTime":"2021-04-30T06:43:57Z","renewTime":"2021-04-30T07:16:51Z","leaderTransitions":7}'
[root@master02 ~]# docker exec -it $(docker ps -f name=etcd_etcd -q) etcdctl --endpoints "https://192.168.13.51:2379,https://192.168.13.52:2379,https://192.168.13.53:2379"  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key endpoint status --write-out="table"
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|          ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://192.168.13.51:2379 | 6b31542d4962986f |  3.4.13 |  4.2 MB |     false |      false |        14 |     235700 |             235700 |        |
| https://192.168.13.52:2379 |  8715488046f0887 |  3.4.13 |  4.2 MB |      true |      false |        14 |     235700 |             235700 |        |
| https://192.168.13.53:2379 | 676ef70c3ee42b24 |  3.4.13 |  4.1 MB |     false |      false |        14 |     235700 |             235700 |        |
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
[root@master02 ~]# kubectl get cs 
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS      MESSAGE                                                                                       ERROR
scheduler            Unhealthy   Get "http://127.0.0.1:10251/healthz": dial tcp 127.0.0.1:10251: connect: connection refused   
controller-manager   Unhealthy   Get "http://127.0.0.1:10252/healthz": dial tcp 127.0.0.1:10252: connect: connection refused   
etcd-0               Healthy     {"health":"true"}    
# 最后步骤将/etc/kubernetes/manifests中的kube-controller-manager.yaml和kube-scheduler.yaml 中的-- port=0 注释掉：
[root@master03 /etc/kubernetes/manifests]# vim kube-controller-manager.yaml 
[root@master03 /etc/kubernetes/manifests]# vim kube-scheduler.yaml 
```

**集群升级工作原理：**
kubeadm upgrade apply 做了以下工作：
检查你的集群是否处于可升级状态
API 服务器是可访问的
所有节点处于 Ready 状态
控制面是健康的
强制执行版本 skew 策略。
确保控制面的镜像是可用的或可拉取到服务器上。
升级控制面组件或回滚（如果其中任何一个组件无法启动）。
应用新的 kube-dns 和 kube-proxy 清单，并强制创建所有必需的 RBAC 规则。
如果旧文件在 180 天后过期，将创建 API 服务器的新证书和密钥文件并备份旧文件。

kubeadm upgrade node 在其他控制平节点上执行以下操作：
从集群中获取 kubeadm ClusterConfiguration。
可选地备份 kube-apiserver 证书。
升级控制平面组件的静态 Pod 清单。
为本节点升级 kubelet 配置

kubeadm upgrade node 在工作节点上完成以下工作：
从集群取回 kubeadm ClusterConfiguration。
为本节点升级 kubelet 配置




### 1.15 Prometheus Operator
一、什么是Prometheus Operator
1. Prometheus Operator的工作原理
Prometheus的本职就是一组用户自定义的CRD资源以及Controller的实现，Prometheus Operator负责监听这些自定义资源的变化，并且根据这些资源的定义自动化的完成如Prometheus Server自身以及配置的自动化管理工作。
要了解Prometheus Operator能做什么，其实就是要了解Prometheus Operator为我们提供了哪些自定义的Kubernetes资源，列出了Prometheus Operator目前提供的️4类资源：

2. Prometheus Operator能做什么
Prometheus：声明式创建和管理Prometheus Server实例；
ServiceMonitor：负责声明式的管理监控配置；
PrometheusRule：负责声明式的管理告警配置；
Alertmanager：声明式的创建和管理Alertmanager实例。
简言之，Prometheus Operator能够帮助用户自动化的创建以及管理Prometheus Server以及其相应的配置。


3. 在Kubernetes集群中部署Prometheus Operator
```bash
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# curl -OL https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/release-0.47/bundle.yaml
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# sed -i 's/namespace: default/namespace: prometheus/g' bundle.yaml 
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# grep 'namespace: prometheus' bundle.yaml
    namespace: prometheus
    namespace: prometheus
    namespace: prometheus
    namespace: prometheus
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# kubectl create namespace prometheus
namespace/prometheus created
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# kubectl apply -f bundle.yaml 
customresourcedefinition.apiextensions.k8s.io/alertmanagerconfigs.monitoring.coreos.com created
customresourcedefinition.apiextensions.k8s.io/alertmanagers.monitoring.coreos.com created
customresourcedefinition.apiextensions.k8s.io/podmonitors.monitoring.coreos.com created
customresourcedefinition.apiextensions.k8s.io/probes.monitoring.coreos.com created
customresourcedefinition.apiextensions.k8s.io/prometheuses.monitoring.coreos.com created
customresourcedefinition.apiextensions.k8s.io/prometheusrules.monitoring.coreos.com created
customresourcedefinition.apiextensions.k8s.io/servicemonitors.monitoring.coreos.com created
customresourcedefinition.apiextensions.k8s.io/thanosrulers.monitoring.coreos.com created
clusterrolebinding.rbac.authorization.k8s.io/prometheus-operator created
clusterrole.rbac.authorization.k8s.io/prometheus-operator created
deployment.apps/prometheus-operator created
serviceaccount/prometheus-operator created
service/prometheus-operator created
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# kubectl get pods -n prometheus -o wide 
NAME                                   READY   STATUS    RESTARTS   AGE   IP            NODE                NOMINATED NODE   READINESS GATES
prometheus-operator-5f949c9f97-r75k8   1/1     Running   0          20s   10.244.3.25   node01.k8s.hs.com   <none>           <none>
```

二、使用Operator管理Prometheus

1. 当集群中已经安装Prometheus Operator之后，对于部署Prometheus Server实例就变成了声明一个Prometheus资源，如下所示，我们在Monitoring命名空间下创建一个Prometheus实例：
```bash
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# vim prometheus-inst.yaml
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
    name: inst
    namespace: prometheus
spec:
    resources:
    requests:
      memory: 400Mi
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# kubectl apply -f prometheus-inst.yaml
prometheus.monitoring.coreos.com/inst created
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# kubectl get statefulsets -n prometheus -o wide 
NAME              READY   AGE   CONTAINERS                   IMAGES
prometheus-inst   1/1     79s   prometheus,config-reloader   quay.io/prometheus/prometheus,quay.io/prometheus-operator/prometheus-config-reloader:v0.47.1
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# kubectl get pods -n prometheus -o wide 
NAME                                   READY   STATUS    RESTARTS   AGE     IP            NODE                NOMINATED NODE   READINESS GATES
prometheus-inst-0                      2/2     Running   1          23s     10.244.3.26   node01.k8s.hs.com   <none>           <none>
prometheus-operator-5f949c9f97-r75k8   1/1     Running   0          2m57s   10.244.3.25   node01.k8s.hs.com   <none>           <none>
# 通过端口转发进行查看
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# kubectl port-forward -n prometheus statefulsets/prometheus-inst --address 0.0.0.0 9090:9090
Forwarding from 0.0.0.0:9090 -> 9090    --此端口代理是暂时的，因为代理会定时或超时关闭
--此时通过浏览器访问http://192.168.13.52:9090/config 可以看到配置信息：
global:
    scrape_interval: 1m
    scrape_timeout: 10s
    evaluation_interval: 1m

2. 使用ServiceMonitor管理监控配置
    修改监控配置项也是Prometheus下常用的运维操作之一，为了能够自动化的管理Prometheus的配置，Prometheus Operator使用了自定义资源类型ServiceMonitor来描述监控对象的信息。
    这里我们首先在集群中部署一个示例应用，将以下内容保存到example-app.yaml，并使用kubectl命令行工具创建：
    [root@master02 ~/manifests/addons/monitor/prometheus-operator]# cat example-app.yaml
    kind: Service
    apiVersion: v1
    metadata:
    name: example-app
    labels:
    app: example-app
    spec:
    selector:
    app: example-app
    ports:
  - name: web
    port: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: example-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: example-app
  template:
    metadata:
      labels:
        app: example-app
    spec:
      containers:
      - name: example-app
        image: fabxc/instrumented_app
        ports:
        - name: web
          containerPort: 8080
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# kubectl apply -f example-app.yaml
service/example-app created
deployment.apps/example-app created
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# kubectl get pods -o wide  
NAME                           READY   STATUS    RESTARTS   AGE     IP            NODE                NOMINATED NODE   READINESS GATES
example-app-7d95cbf666-5wsl6   1/1     Running   0          2m17s   10.244.3.27   node01.k8s.hs.com   <none>           <none>
example-app-7d95cbf666-9rlbj   1/1     Running   0          2m17s   10.244.4.20   node02.k8s.hs.com   <none>           <none>
example-app-7d95cbf666-jhtdj   1/1     Running   0          2m17s   10.244.4.19   node02.k8s.hs.com   <none>           <none>
# 通过浏览器访问http://192.168.13.52:8080/metrics可以看到许多metric指标
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# kubectl port-forward -n prometheus statefulsets/prometheus-inst --address 0.0.0.0 8080:8080
Forwarding from 0.0.0.0:8080 -> 8080


# 为了能够让Prometheus能够采集部署在Kubernetes下应用的监控数据，在原生的Prometheus配置方式中，我们在Prometheus配置文件中定义单独的Job，同时使用kubernetes_sd定义整个服务发现过程。而在Prometheus Operator中，则可以直接声明一个ServiceMonitor对象，如下所示：
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# cat example-app-service-monitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: example-app
  namespace: prometheus
  labels:
    team: frontend
spec:
  namespaceSelector:
    matchNames:
    - default
  selector:
    matchLabels:
      app: example-app
  endpoints:
  - port: web     --此web表示service中名称是web是端口

# 通过定义selector中的标签定义选择监控目标的Pod对象，同时在endpoints中指定port名称为web的端口。默认情况下ServiceMonitor和监控对象必须是在相同Namespace下的。在本示例中由于Prometheus是部署在prometheus命名空间下，因此为了能够关联default命名空间下的example对象，需要使用namespaceSelector定义让其可以跨命名空间关联ServiceMonitor资源。保存以上内容到example-app-service-monitor.yaml文件中，并通过kubectl创建：
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# kubectl apply -f example-app-service-monitor.yaml 
servicemonitor.monitoring.coreos.com/example-app created
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# kubectl get ServiceMonitor -n prometheus
NAME          AGE
example-app   7s
# 如果希望ServiceMonitor可以关联任意命名空间下的标签，则通过以下方式定义：
spec:
  namespaceSelector:
    any: true
# 如果监控的Target对象启用了BasicAuth认证，那在定义ServiceMonitor对象时，可以使用endpoints配置中定义basicAuth如下所示：
  endpoints:
  - basicAuth:
      password:
        name: basic-auth
        key: password
      username:
        name: basic-auth
        key: user
    port: web
# 其中basicAuth中关联了名为basic-auth的Secret对象，用户需要手动将认证信息保存到Secret中:
      apiVersion: v1
      kind: Secret
      metadata:
    name: basic-auth
      data:
    password: dG9vcg== # base64编码后的密码
    user: YWRtaW4= # base64编码后的用户名
      type: Opaque

3. 关联Promethues与ServiceMonitor
Prometheus与ServiceMonitor之间的关联关系使用serviceMonitorSelector定义，在Prometheus中通过标签选择当前需要监控的ServiceMonitor对象。修改prometheus-inst.yaml中Prometheus的定义如下所示： 为了能够让Prometheus关联到ServiceMonitor，需要在Pormtheus定义中使用serviceMonitorSelector，我们可以通过标签选择当前Prometheus需要监控的ServiceMonitor对象。修改prometheus-inst.yaml中Prometheus的定义如下所示：
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# cat prometheus-inst.yaml
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
    name: inst
    namespace: prometheus
spec:
    serviceMonitorSelector:
    matchLabels:
      team: frontend
    resources:
    requests:
      memory: 400Mi
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# kubectl apply -f prometheus-inst.yaml
prometheus.monitoring.coreos.com/inst configured
--此时访问http://192.168.13.52:9090/config，如果查看Prometheus配置信息，我们会惊喜的发现Prometheus中配置文件自动包含了一条名为monitoring/example-app/0的Job配置
4. 不过，如果细心的读者可能会发现，虽然Job配置有了，但是Prometheus的Target中并没包含任何的监控对象。查看Prometheus的Pod实例日志，可以看到如下信息：
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# kubectl logs prometheus-inst-0 prometheus -n prometheus| tail -n 2
level=error ts=2021-05-07T08:38:53.378Z caller=klog.go:96 component=k8s_client_runtime func=ErrorDepth msg="pkg/mod/k8s.io/client-go@v0.20.5/tools/cache/reflector.go:167: Failed to watch *v1.Service: failed to list *v1.Service: services is forbidden: User \"system:serviceaccount:prometheus:default\" cannot list resource \"services\" in API group \"\" in the namespace \"default\""
level=error ts=2021-05-07T08:39:07.824Z caller=klog.go:96 component=k8s_client_runtime func=ErrorDepth msg="pkg/mod/k8s.io/client-go@v0.20.5/tools/cache/reflector.go:167: Failed to watch *v1.Pod: failed to list *v1.Pod: pods is forbidden: User \"system:serviceaccount:prometheus:default\" cannot list resource \"pods\" in API group \"\" in the namespace \"default\""

5. 自定义ServiceAccount
由于默认创建的Prometheus实例使用的是monitoring命名空间下的default账号，该账号并没有权限能够获取default命名空间下的任何资源信息。
为了修复这个问题，我们需要在Monitoring命名空间下为创建一个名为Prometheus的ServiceAccount，并且为该账号赋予相应的集群访问权限
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# kubectl get sa -n prometheus
NAME                  SECRETS   AGE
default               1         33m
prometheus-operator   1         32m
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# cat prometheus-rbac.yaml]
apiVersion: v1
kind: ServiceAccount
metadata:
name: prometheus
namespace: prometheus
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: prometheus
rules:
- apiGroups: [""]
  resources:
  - nodes
  - services
  - endpoints
  - pods
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources:
  - configmaps
  verbs: ["get"]
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: prometheus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus
subjects:
- kind: ServiceAccount
  name: prometheus
  namespace: prometheus
  [root@master02 ~/manifests/addons/monitor/prometheus-operator]# kubectl apply -f prometheus-rbac.yaml]
  serviceaccount/prometheus created
  Warning: rbac.authorization.k8s.io/v1beta1 ClusterRole is deprecated in v1.17+, unavailable in v1.22+; use rbac.authorization.k8s.io/v1 ClusterRole
  clusterrole.rbac.authorization.k8s.io/prometheus created
  Warning: rbac.authorization.k8s.io/v1beta1 ClusterRoleBinding is deprecated in v1.17+, unavailable in v1.22+; use rbac.authorization.k8s.io/v1 ClusterRoleBinding
  clusterrolebinding.rbac.authorization.k8s.io/prometheus created
  在完成ServiceAccount创建后，修改prometheus-inst.yaml，并添加ServiceAccount如下所示：
  [root@master02 ~/manifests/addons/monitor/prometheus-operator]# cat prometheus-inst.yaml 
  apiVersion: monitoring.coreos.com/v1
  kind: Prometheus
  metadata:
  name: inst
  namespace: prometheus
  spec:
  serviceAccountName: prometheus
  serviceMonitorSelector:
    matchLabels:
      team: frontend
  resources:
    requests:
      memory: 400Mi
  [root@master02 ~/manifests/addons/monitor/prometheus-operator]# kubectl apply -f prometheus-inst.yaml
  prometheus.monitoring.coreos.com/inst configured
  [root@master02 ~/manifests/addons/monitor/prometheus-operator]# kubectl get pods -n prometheus 
  NAME                                   READY   STATUS    RESTARTS   AGE
  prometheus-inst-0                      2/2     Running   1          103s
  prometheus-operator-5f949c9f97-r75k8   1/1     Running   0          39m
  [root@master02 ~/manifests/addons/monitor/prometheus-operator]# kubectl logs prometheus-inst-0 prometheus -n prometheus| tail -n 2
  level=info ts=2021-05-07T08:45:26.151Z caller=kubernetes.go:266 component="discovery manager scrape" discovery=kubernetes msg="Using pod service account via in-cluster config"
  level=info ts=2021-05-07T08:45:26.154Z caller=main.go:975 msg="Completed loading of configuration file" filename=/etc/prometheus/config_out/prometheus.env.yaml totalDuration=5.666856ms remote_storage=6.136µs web_handler=2.884µs query_engine=3.729µs scrape=173.996µs scrape_sd=3.8158ms notify=0s notify_sd=0s rules=93.726µs
  --此时日志已经正常
  等待Prometheus Operator完成相关配置变更后，此时查看Prometheus，我们就能看到当前Prometheus已经能够正常的采集实例应用的相关监控数据了。

三、使用Operator管理告警
1. 使用PrometheusRule定义告警规则
    对于Prometheus而言，在原生的管理方式上，我们需要手动创建Prometheus的告警文件，并且通过在Prometheus配置中声明式的加载。而在Prometheus Operator模式中，告警规则也编程一个通过Kubernetes API 声明式创建的一个资源，如下所示：
    [root@master02 ~/manifests/addons/monitor/prometheus-operator]# cat example-rule.yaml
    apiVersion: monitoring.coreos.com/v1
    kind: PrometheusRule
    metadata:
    labels:
    prometheus: example
    role: alert-rules
    name: prometheus-example-rules
    namespace: prometheus
    spec:
    groups:
  - name: ./example.rules
    rules:
    - alert: ExampleAlert
      expr: vector(1)
      [root@master02 ~/manifests/addons/monitor/prometheus-operator]# kubectl apply -f example-rule.yaml
      prometheusrule.monitoring.coreos.com/prometheus-example-rules created
      告警规则创建成功后，通过在Prometheus中使用ruleSelector通过选择需要关联的PrometheusRule即可：
      [root@master02 ~/manifests/addons/monitor/prometheus-operator]# cat prometheus-inst.yaml
      apiVersion: monitoring.coreos.com/v1
      kind: Prometheus
      metadata:
      name: inst
      namespace: prometheus
      spec:
      serviceAccountName: prometheus
      ruleSelector:
      matchLabels:
      role: alert-rules
      prometheus: example
      serviceMonitorSelector:
      matchLabels:
      team: frontend
      resources:
      requests:
      memory: 400Mi
      [root@master02 ~/manifests/addons/monitor/prometheus-operator]# kubectl apply -f prometheus-inst.yaml 
      prometheus.monitoring.coreos.com/inst configured
      [root@master02 ~/manifests/addons/monitor/prometheus-operator]# kubectl get pods -n prometheus
      NAME                                   READY   STATUS    RESTARTS   AGE
      prometheus-inst-0                      2/2     Running   1          6m18s
      prometheus-operator-5f949c9f97-r75k8   1/1     Running   0          43m
      Prometheus重新加载配置后，从UI中我们可以查看到通过PrometheusRule自动创建的告警规则配置：

2. 使用Operator管理Alertmanager实例
到目前为止，我们已经通过Prometheus Operator的自定义资源类型管理了Promtheus的实例，监控配置以及告警规则等资源。通过Prometheus Operator将原本手动管理的工作全部变成声明式的管理模式，大大简化了Kubernetes下的Prometheus运维管理的复杂度。 接下来，我们将继续使用Promtheus Operator定义和管理Alertmanager相关的内容。
为了通过Prometheus Operator管理Alertmanager实例，用户可以通过自定义资源Alertmanager进行定义，通过replicas可以控制Alertmanager的实例数，当replicas大于1时，Prometheus Operator会自动通过集群的方式创建Alertmanager。将以上内容保存为文件alertmanager-inst.yaml，并通过以下命令创建：
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# cat alertmanager-inst.yaml
apiVersion: monitoring.coreos.com/v1
kind: Alertmanager
metadata:
    name: inst
    namespace: prometheus
spec:
    replicas: 3
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# kubectl apply -f alertmanager-inst.yaml
alertmanager.monitoring.coreos.com/inst created
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# kubectl get pods -n prometheus -o wide 
NAME                                   READY   STATUS    RESTARTS   AGE   IP            NODE                NOMINATED NODE   READINESS GATES
alertmanager-inst-0                    2/2     Running   0          81s   10.244.4.21   node02.k8s.hs.com   <none>           <none>
alertmanager-inst-1                    2/2     Running   0          81s   10.244.3.29   node01.k8s.hs.com   <none>           <none>
alertmanager-inst-2                    2/2     Running   0          81s   10.244.4.22   node02.k8s.hs.com   <none>           <none>
prometheus-inst-0                      2/2     Running   1          11m   10.244.3.28   node01.k8s.hs.com   <none>           <none>
prometheus-operator-5f949c9f97-r75k8   1/1     Running   0          48m   10.244.3.25   node01.k8s.hs.com   <none>           <none>
[root@master02 ~]# kubectl get pods -n prometheus
NAME                                   READY   STATUS    RESTARTS   AGE
alertmanager-inst-0                    2/2     Running   0          32m
alertmanager-inst-1                    2/2     Running   0          32m
alertmanager-inst-2                    2/2     Running   0          32m
prometheus-inst-0                      2/2     Running   1          42m
prometheus-operator-5f949c9f97-r75k8   1/1     Running   0          79m
---------此信息为可选---------
如果不是Running状态，通过kubectl describe命令查看该Alertmanager的Pod实例状态，如果可以看到类似于以下内容的告警信息：
MountVolume.SetUp failed for volume "config-volume" : secrets "alertmanager-inst" not found
这是由于Prometheus Operator通过Statefulset的方式创建的Alertmanager实例，在默认情况下，会通过alertmanager-{ALERTMANAGER_NAME}的命名规则去查找Secret配置并以文件挂载的方式，将Secret的内容作为配置文件挂载到Alertmanager实例当中。因此，这里还需要为Alertmanager创建相应的配置内容，如下所示，是Alertmanager的配置文件：
global:
    resolve_timeout: 5m
route:
    group_by: ['job']
    group_wait: 30s
    group_interval: 5m
    repeat_interval: 12h
    receiver: 'webhook'
receivers:
- name: 'webhook'
  webhook_configs:
  - url: 'http://alertmanagerwh:30500/'
  将以上内容保存为文件alertmanager.yaml，并且通过以下命令创建名为alrtmanager-inst的Secret资源：
  $ kubectl -n prometheus create secret generic alertmanager-inst --from-file=alertmanager.yaml
  secret/alertmanager-inst created
------------------
接下来，我们只需要修改我们的Prometheus资源定义，通过alerting指定使用的Alertmanager资源即可：
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# cat prometheus-inst.yaml 
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: inst
  namespace: prometheus
spec:
  serviceAccountName: prometheus
  ruleSelector:
    matchLabels:
      role: alert-rules
      prometheus: example
  alerting:
    alertmanagers:
    - name: alertmanager-example
      namespace: prometheus
      port: web
  serviceMonitorSelector:
    matchLabels:
      team: frontend
  resources:
    requests:
      memory: 400Mi
[root@master02 ~/manifests/addons/monitor/prometheus-operator]# kubectl apply -f prometheus-inst.yaml
prometheus.monitoring.coreos.com/inst configured
等待Prometheus重新加载后，我们可以看到Prometheus Operator在配置文件中添加了如下配置：
  alertmanagers:
  - follow_redirects: true
    scheme: http
    path_prefix: /
    timeout: 10s
    api_version: v2
    relabel_configs:
    - source_labels: [__meta_kubernetes_service_name]
      separator: ;
      regex: alertmanager-example
      replacement: $1
      action: keep
    - source_labels: [__meta_kubernetes_endpoint_port_name]
      separator: ;
      regex: web
      replacement: $1
      action: keep
      kubernetes_sd_configs:
    - role: endpoints
      follow_redirects: true
      namespaces:
        names:
        - prometheus

3. 在Prometheus Operator中使用自定义配置
在Prometheus Operator我们通过声明式的创建如Prometheus, ServiceMonitor这些自定义的资源类型来自动化部署和管理Prometheus的相关组件以及配置。而在一些特殊的情况下，对于用户而言，可能还是希望能够手动管理Prometheus配置文件，而非通过Prometheus Operator自动完成。 为什么？ 实际上Prometheus Operator对于Job的配置只适用于在Kubernetes中部署和管理的应用程序。如果你希望使用Prometheus监控一些其他的资源，例如AWS或者其他平台中的基础设施或者应用，这些并不在Prometheus Operator的能力范围之内。
为了能够在通过Prometheus Operator创建的Prometheus实例中使用自定义配置文件，我们只能创建一个不包含任何与配置文件内容相关的Prometheus实例
```





### 1.16 ingress controller



#### 1.6.1 nginx ingress controller
1. 部署ingress Controller
```bash
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# curl -OL https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.46.0/deploy/static/provider/baremetal/deploy.yaml
# 更改镜像名称k8s.gcr.io/ingress-nginx/,并且容忍master上的污点controller:v0.46.0@sha256:52f0058bed0a17ab0fb35628ba97e8d52b5d32299fbc03cc0f6c7b9ff036b61a为k8s.gcr.io/ingress-nginx/controller:v0.46.0
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# vim deploy.yaml
image: k8s.gcr.io/ingress-nginx/controller:v0.46.0
   tolerations:
   - key: node-role.kubernetes.io/master
     operator: Exists
     effect: NoSchedule

# 部署
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl apply -f deploy.yaml
namespace/ingress-nginx created
serviceaccount/ingress-nginx created
configmap/ingress-nginx-controller created
clusterrole.rbac.authorization.k8s.io/ingress-nginx created
clusterrolebinding.rbac.authorization.k8s.io/ingress-nginx created
role.rbac.authorization.k8s.io/ingress-nginx created
rolebinding.rbac.authorization.k8s.io/ingress-nginx created
service/ingress-nginx-controller-admission created
service/ingress-nginx-controller created
deployment.apps/ingress-nginx-controller created
validatingwebhookconfiguration.admissionregistration.k8s.io/ingress-nginx-admission created
serviceaccount/ingress-nginx-admission created
clusterrole.rbac.authorization.k8s.io/ingress-nginx-admission created
clusterrolebinding.rbac.authorization.k8s.io/ingress-nginx-admission created
role.rbac.authorization.k8s.io/ingress-nginx-admission created
rolebinding.rbac.authorization.k8s.io/ingress-nginx-admission created
job.batch/ingress-nginx-admission-create created
job.batch/ingress-nginx-admission-patch created
# 镜像获取，由于防火墙原因：
[root@salt /git/kubernetes/ingress-nginx/v0.46.0]# docker pull willdockerhub/ingress-nginx-controller:v0.46.0
[root@salt /git/kubernetes/ingress-nginx/v0.46.0]# docker tag willdockerhub/ingress-nginx-controller:v0.46.0 k8s.gcr.io/ingress-nginx/controller:v0.46.0
[root@salt /git/kubernetes/ingress-nginx/v0.46.0]# docker tag k8s.gcr.io/ingress-nginx/controller:v0.46.0 192.168.13.235:8000/k8s/k8s.gcr.io/ingress-nginx/controller:v0.46.0
[root@salt /git/kubernetes/ingress-nginx/v0.46.0]# docker push 192.168.13.235:8000/k8s/k8s.gcr.io/ingress-nginx/controller:v0.46.0
# 从pod的描述信息中看到是被调试到node02了，此时需要在node02上获取镜像
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl describe pods ingress-nginx-controller-6748cc5bd5-r2rjg -n ingress-nginx
[root@node02 ~]# docker pull 192.168.13.235:8000/k8s/k8s.gcr.io/ingress-nginx/controller:v0.46.0 
[root@node02 ~]# docker tag 192.168.13.235:8000/k8s/k8s.gcr.io/ingress-nginx/controller:v0.46.0 k8s.gcr.io/ingress-nginx/controller:v0.46.0
# 查看ingress-nginx运行状态：（测试ingress controller是否正常运行(通过ingress controller前端的service的NodePort端口进行访问，返回404说明ingresscontroller成功安装并运行)）
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl get pods -n ingress-nginx
NAME                                        READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create-tw2t9        0/1     Completed   0          10m
ingress-nginx-admission-patch-kxzb9         0/1     Completed   1          10m
ingress-nginx-controller-6748cc5bd5-sw76x   1/1     Running     0          25s
注：上面获取镜像或者直接使用hub.docker.com的镜像：willdockerhub/ingress-nginx-controller:v0.46.0
2. 运行deployment类型的pod及clusterIP类型的service
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# cat deployment-ct.yaml 
apiVersion: v1
kind: Service
metadata:
  name: myapp
  namespace: default
spec:
  selector:
    app: myapp
    release: canary
    ports:
  - name: http
    port: 80
    targetPort: 80  
---
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
        image: ikubernetes/myapp:v1
        imagePullPolicy: IfNotPresent
        ports:
        - name: http
          containerPort: 80
        livenessProbe:
          httpGet:
            port: http
            path: /index.html
          initialDelaySeconds: 1 
          periodSeconds: 3 
        readinessProbe:
          httpGet:
            port: http
            path: /index.html
          initialDelaySeconds: 1 
          periodSeconds: 3 
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl get pods 
NAME                               READY   STATUS    RESTARTS   AGE
myapp-deployment-b6bbc4f78-764sp   1/1     Running   0          22h
myapp-deployment-b6bbc4f78-9zhpt   1/1     Running   0          22h
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl get svc
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP   9d
myapp        ClusterIP   10.107.161.244   <none>        80/TCP    22h
3. 运行ingress进行关联ingress controller和后端pod
# 先把证书和私钥做成secret
# 新建自签名证书
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# (umask 0077;openssl genrsa -out hs.com 3650)
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# openssl req -new -x509 -key hs.com -out hs.com.crt -subj /C=CN/ST=Shanghai/L=Shanghai/O=DevOps/CN=*.hs.com -days 3650
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# ls
deployment-ct.yaml  deploy.yaml  hscert  hs.com  hs.com.crt  ingress-myapp.yaml
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl create secret tls tls-ingress-hs.com --cert=hs.com.crt --key=hs.com
----------------
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl create secret tls tls-ingress-hs.com --cert=hscert/HSLocalhost.cer --key=hscert/HSLocalhost.pvk
secret/tls-ingress-hs.com created
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl get secret
NAME                  TYPE                                  DATA   AGE
default-token-jxblm   kubernetes.io/service-account-token   3      9d
tls-ingress-hs.com    kubernetes.io/tls                     2      4s
# 生成ingress规则
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# cat ingress-myapp.yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-myapp
  namespace: default
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - host: myapp.hs.com
    http:
      paths: 
      - path: 
        backend:
          serviceName: myapp
          servicePort: 80
        tls:
  - hosts: 
    - myapp.hs.com
    secretName: tls-ingress-hs.com
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl apply -f ingress-myapp.yaml 
Warning: extensions/v1beta1 Ingress is deprecated in v1.14+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
ingress.extensions/ingress-myapp created
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl get svc/ingress-nginx-controller -n ingress-nginx -o jsonpath="{.spec.ports[?(@.port==80)].nodePort}"
31470
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl get svc/ingress-nginx-controller -n ingress-nginx -o jsonpath="{.spec.ports[?rt==443)].nodePort}"
31174
# 因为没有在ingress资源清单中设置资源注解：nginx.ingress.kubernetes.io/ssl-redirect: "false"，所以会重定向到https。
[root@master02 ~/k8s-manifests/ingress-controller-nginx]#  curl -H 'host: myapp.hs.com' http://192.168.13.51:31470/  
<html>
<head><title>308 Permanent Redirect</title></head>
<body>
<center><h1>308 Permanent Redirect</h1></center>
<hr><center>nginx</center>
</body>
</html>
/etc/nginx $  curl -k -H 'host: myapp.hs.com' https://192.168.13.51:31174/
Hello MyApp | Version: v1 | <a href="hostname.html">Pod Name</a>
# 这里为设置禁用重写向后的结果：
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# curl -H 'host: myapp.hs.com' http://192.168.13.51:31470/
Hello MyApp | Version: v1 | <a href="hostname.html">Pod Name</a>
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# curl -k -H 'host: myapp.hs.com' https://192.168.13.51:31174/
Hello MyApp | Version: v1 | <a href="hostname.html">Pod Name</a>
注：当ingress中配置了tls,并且只标明多个主机中的一个主机使用https时，另外其它所有的主机也都可以使用https访问到，也就是说不受tls中的hosts限制。
```


#### 1.16.2 配置ingress nginx

除使用Ingress资源自定义流量路由相关的配置外，Ingress Nginx应用程序还存在许多其他配置需要，例如日志格式、CORS、URL重写、代理缓冲和SSL透传等。这类的配置通常有ConfigMap、Annotations和自定义模板3种实现方式。
IngressNginx的ConfigMap和Annotations配置接口都支持使用大量的参数来定制所需要的功能，不同的是，前者通过在IngressNginx引用ConfigMap资源规范中data字段特定的键及可用取值进行定义，且多用于Nginx全局特性的定制，因而是集群级别的配置；而后者则于Ingress资源上使用资源注解配置，多用于虚拟主机级别，因而通常是服务级别的配置。

**服务级别的配置** 
```bash
1. 我们通过为虚拟主机myapp.hs.com添加Basic认证为例：
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# yum install -y httpd-tools
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# htpasswd  -c -b -m ./ngxpasswd ilinux ilinux
Adding password for user ilinux
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# htpasswd -b -m ./ngxpasswd mageedu mageedu
Adding password for user mageedu
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl create secret generic ilinux-passwd --from-file=auth=./ngxpasswd -n default 
secret/ilinux-passwd created
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl get secret 
NAME                  TYPE                                  DATA   AGE
default-token-jxblm   kubernetes.io/service-account-token   3      9d
ilinux-passwd         Opaque                                1      6s
tls-ingress-hs-com    kubernetes.io/tls                     2      61m
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# cat ingress-myapp.yaml
    apiVersion: extensions/v1beta1
    kind: Ingress
    metadata:
    name: ingress-myapp
    namespace: default
    annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: ilinux-passwd
    nginx.ingress.kubernetes.io/auth-realm: "Authentication Required"
    spec:
    rules:
  - host: myapp.hs.com
    http:
      paths: 
      - path: /
        backend:
          serviceName: myapp
          servicePort: 80
  - host: test.hs.com
    http:
      paths: 
      - path: /
        backend:
          serviceName: test
          servicePort: 80
        tls:
  - secretName: tls-ingress-hs-com
    hosts: 
    - myapp.hs.com
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl apply -f ingress-myapp.yaml
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# curl -k -H 'host: myapp.hs.com' https://192.168.13.51:31174/
    <html>
<head><title>401 Authorization Required</title></head>
<body>
<center><h1>401 Authorization Required</h1></center>
<hr><center>nginx</center>
</body>
</html>
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# curl -u "mageedu:mageedu" -k -H 'host: myapp.hs.com' https://192.168.13.51:31174/
Hello MyApp | Version: v1 | <a href="hostname.html">Pod Name</a>
```

**全局级别的配置**
```bash
2. Ningx全局级别的配置通常由ConfigMap资源进行定义，默认部署的IngressNginx会引用ingress-nginx名称空间中的ConfigMap/ingress-nginx-controller资源，
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl get cm -n ingress-nginx
NAME                              DATA   AGE
ingress-controller-leader-nginx   0      171m
ingress-nginx-controller          0      3h1m
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl describe cm ingress-nginx-controller -n ingress-nginx
Name:         ingress-nginx-controller
Namespace:    ingress-nginx
Labels:       app.kubernetes.io/component=controller
              app.kubernetes.io/instance=ingress-nginx
              app.kubernetes.io/managed-by=Helm
              app.kubernetes.io/name=ingress-nginx
              app.kubernetes.io/version=0.46.0
              helm.sh/chart=ingress-nginx-3.30.0
Annotations:  <none>

Data
====
Events:  <none>
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# INGRESS_POD=$(kubectl get pods -l app.kubernetes.io/component=controller -n ingress-nginx -o jsonpath="{.items[0].metadata.name}")
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl exec $INGRESS_POD -n ingress-nginx -- nginx -T 2> /dev/null| grep -E 'use_gzip|gzip_level|worker_processes'
worker_processes 4;
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# cat cm-ingress-nginx-controller.yaml 
apiVersion: v1
kind: ConfigMap
metadata:
  name: ingress-nginx-controller
  namespace: ingress-nginx
data:
  use-gzip: "true"
  gzip-level: "6"
  worker-processes: "8"
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl apply -f cm-ingress-nginx-controller.yaml 
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl exec $INGRESS_POD -n ingress-nginx -- nginx -T 2> /dev/null| grep -E 'gzip_comp_level|worker_processes'
worker_processes 8;
	gzip_comp_level 6;

--通过ingress发布Dashboard
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# cat ingress-kubernetes-dashboard.yaml 
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-dashboard
  namespace: kubernetes-dashboard
  annotations: 
    kubernetes.io/ingress.class: "nginx"
    ingress.kubernetes.io/ssl-passthrough: "true"  #ssl 透传
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"  #后端使用TLS协议
    #nginx.ingress.kubernetes.io/rewrite-target: /$2   #URL重写向
spec:
  rules:
  - host: dashboard.k8s.hs.com
    http:   #未限定主机，表示可附着于任何主机之上进行访问
      paths:
      #- path: /dashboard(/|$)(.*)  #正则表达式格式的路径
      - path: /  #正则表达式格式的路径
        backend:
          serviceName: kubernetes-dashboard
          servicePort: 443
        [root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl apply -f ingress-kubernetes-dashboard.yaml
        --此时可以通过https进行访问dashboard:
        [root@master02 ~/k8s-manifests/dashboard]# curl -kI -H 'Host: dashboard.k8s.hs.com' https://192.168.13.56
        HTTP/1.1 200 OK
        Date: Fri, 11 Jun 2021 01:35:22 GMT
        Content-Type: text/html; charset=utf-8
        Content-Length: 1250
        Connection: keep-alive
        Accept-Ranges: bytes
        Cache-Control: no-cache, no-store, must-revalidate
        Last-Modified: Thu, 18 Feb 2021 14:45:44 GMT
        Strict-Transport-Security: max-age=15724800; includeSubDomains

#dashboard高可用--也可类似于ingress-nginx实现高可用
当dashboard为Delpoyment控制器时，将dashboard副本数设为2，当pod所在节点Down机时，endpoints会有一分钟的时效检测后端pod状态，一分钟后会判断后端pod是否正常，所以pod节点Down机时，会有1分钟的服务中断。
当知道当pod所在节点Down机时，可以驱逐Down机的节点以快速使endpoint对后端pod做出表决，判定是否健康。pod服务中断时间取决于驱逐的速度。

# 问题
--查看指定名称空间下有没有资源未结束,原因是pod节点未开机
[root@master02 ~/k8s-manifests/dashboard]# kubectl api-resources -o name --verbs=list --namespaced | xargs -n 1 kubectl get --show-kind --ignore-not-found -n kubernetes-dashboard
NAME                                        READY   STATUS        RESTARTS   AGE
pod/kubernetes-dashboard-6d87dc768b-9zkwg   1/1     Terminating   0          35m
--强制删除pod
[root@master02 ~/k8s-manifests/dashboard]# kubectl delete pods --force --grace-period=0 kubernetes-dashboard-6d87dc768b-9zkwg -n kubernetes-dashboard
warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
pod "kubernetes-dashboard-6d87dc768b-9zkwg" force deleted
--再次查看时没有pod未删除了，但是kubernetes-dashboard名称空间依旧是Terminating状态
[root@master02 ~/k8s-manifests/dashboard]# kubectl api-resources -o name --verbs=list --namespaced | xargs -n 1 kubectl get --show-kind --ignore-not-found -n kubernetes-dashboard
Warning: extensions/v1beta1 Ingress is deprecated in v1.14+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
--等过了一会已经正常删除了
[root@master02 ~/k8s-manifests/dashboard]# kubectl get ns
NAME              STATUS   AGE
default           Active   10d
ingress-nginx     Active   4h28m
kube-node-lease   Active   10d
kube-public       Active   10d
kube-system       Active   10d
storage-nfs       Active   5d22h
```



### 1.17 RBAC

认证、授权、准入控制

**集群自带角色**
```bash
[root@master02 ~/k8s-manifests/dashboard/rbac/sa]# kubectl get clusterrole | egrep "^(cluster-admin|admin|edit|view)"
admin                                                                  2021-04-29T11:52:18Z       --用于名称空间级别管理员
cluster-admin                                                          2021-04-29T11:52:18Z		  --用于整个集群级别管理员
edit                                                                   2021-04-29T11:52:18Z		  --可写角色
view                                                                   2021-04-29T11:52:18Z		  --可读角色

一： 所有命令行进行管理的，需要用到基于证书的kubeconfig进行认证授权
二： 所有dashboard进行登录的，都需要用到serviceaccount的token才能进行认证授权

kubectl options --此命令可查看所有通用命令
[root@master02 ~/k8s-manifests/dashboard]# kubectl options
The following options can be passed to any command:
      --add-dir-header=false: If true, adds the file directory to the header of the log messages
      --alsologtostderr=false: log to standard error as well as files
      --as='': Username to impersonate for the operation
      --as-group=[]: Group to impersonate for the operation, this flag can be repeated to specify multiple groups.
      --cache-dir='/root/.kube/cache': Default cache directory
      --certificate-authority='': Path to a cert file for the certificate authority
      --client-certificate='': Path to a client certificate file for TLS
      --client-key='': Path to a client key file for TLS
      --cluster='': The name of the kubeconfig cluster to use
      --context='': The name of the kubeconfig context to use
      --insecure-skip-tls-verify=false: If true, the server's certificate will not be checked for validity. This will
make your HTTPS connections insecure
      --kubeconfig='': Path to the kubeconfig file to use for CLI requests.
      --log-backtrace-at=:0: when logging hits line file:N, emit a stack trace
      --log-dir='': If non-empty, write log files in this directory
      --log-file='': If non-empty, use this log file
      --log-file-max-size=1800: Defines the maximum size a log file can grow to. Unit is megabytes. If the value is 0,
the maximum file size is unlimited.
      --log-flush-frequency=5s: Maximum number of seconds between log flushes
      --logtostderr=true: log to standard error instead of files
      --match-server-version=false: Require server version to match client version
  -n, --namespace='': If present, the namespace scope for this CLI request
      --password='': Password for basic authentication to the API server
      --profile='none': Name of profile to capture. One of (none|cpu|heap|goroutine|threadcreate|block|mutex)
      --profile-output='profile.pprof': Name of the file to write the profile to
      --request-timeout='0': The length of time to wait before giving up on a single server request. Non-zero values
should contain a corresponding time unit (e.g. 1s, 2m, 3h). A value of zero means don't timeout requests.
  -s, --server='': The address and port of the Kubernetes API server
      --skip-headers=false: If true, avoid header prefixes in the log messages
      --skip-log-headers=false: If true, avoid headers when opening log files
      --stderrthreshold=2: logs at or above this threshold go to stderr
      --tls-server-name='': Server name to use for server certificate validation. If it is not provided, the hostname
used to contact the server is used
      --token='': Bearer token for authentication to the API server
      --user='': The name of the kubeconfig user to use
      --username='': Username for basic authentication to the API server
  -v, --v=0: number for the log level verbosity
      --vmodule=: comma-separated list of pattern=N settings for file-filtered logging
      --warnings-as-errors=false: Treat warnings received from the server as errors and exit with a non-zero exit code
#--新建配置kubeconfig文件,用于命令行身份认证，UA用户
1. 生成用户证书信息
[root@master02 ~/k8s-manifests/dashboard/rbac]# (umask 077; openssl genrsa -out homsom-admin.key 2048)
[root@master02 ~/k8s-manifests/dashboard/rbac]# openssl req -new -key homsom-admin.key -out homsom-admin.csr -subj "/O=homsom/CN=homsom-admin" 
[root@master02 ~/k8s-manifests/dashboard/rbac]# openssl x509 -req -in homsom-admin.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out homsom-admin.crt -days 3650 
Signature ok
subject=/O=homsom/CN=homsom-admin
Getting CA Private Key
2. 配置集群信息
[root@master02 ~/k8s-manifests/dashboard/rbac]# kubectl config set-cluster homsom-kubernetes --kubeconfig='/root/homsom-kubernetes.conf' --server=https://k8s-api.k8s.hs.com:6443 --certificate-authority=/etc/kubernetes/pki/ca.crt --embed-certs=true 
3. 配置上下文信息
[root@master02 ~/k8s-manifests/dashboard/rbac]# kubectl config set-context homsom-admin@homsom-kubernetes --cluster=homsom-kubernetes --user=homsom-admin --kubeconfig='/root/homsom-kubernetes.conf'
4. 配置用户信息
[root@master02 ~/k8s-manifests/dashboard/rbac]# kubectl config set-credentials homsom-admin --client-certificate=./homsom-admin.crt --client-key=./homsom-admin.key --embed-certs=true --kubeconfig='/root/homsom-kubernetes.conf'
5. 切换上下文
[root@master02 ~/k8s-manifests/dashboard/rbac]# kubectl config use-context homsom-admin@homsom-kubernetes --kubeconfig='/root/homsom-kubernetes.conf'
[root@master02 ~/k8s-manifests/dashboard/rbac]# kubectl config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://k8s-api.k8s.hs.com:6443
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
6. 此时使用配置文件时还是无权限，如下：
[root@master02 ~/k8s-manifests/dashboard/rbac]# kubectl get pods --kubeconfig='/root/homsom-kubernetes.conf'
Error from server (Forbidden): pods is forbidden: User "homsom-admin" cannot list resource "pods" in API group "" in the namespace "default"
7. 授权GROUP: homsom权限 
[root@master02 ~/k8s-manifests/dashboard/rbac]# kubectl create clusterrolebinding homsom-admin --clusterrole=cluster-admin --group=homsom  --dry-run -o yaml 
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
    creationTimestamp: null
    name: homsom-admin
roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: ClusterRole
    name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: homsom
  [root@master02 ~/k8s-manifests/dashboard/rbac]# cat homsom-admin-clusterrolebinding.yaml
  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRoleBinding
  metadata:
  creationTimestamp: null
  name: homsom-admin
  roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
  subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: homsom
  [root@master02 ~/k8s-manifests/dashboard/rbac]# kubectl apply -f homsom-admin-clusterrolebinding.yaml
  [root@master02 ~/k8s-manifests/dashboard/rbac]# kubectl get clusterrolebinding | grep homsom-admin
  homsom-admin                                           ClusterRole/cluster-admin                                                          11s
8. 此时查看权限
[root@master02 ~/k8s-manifests/dashboard/rbac]#  kubectl get pods --kubeconfig='/root/homsom-kubernetes.conf'
NAME                                    READY   STATUS    RESTARTS   AGE
jack-base-795f8d97fc-xshwc              1/1     Running   0          5h42m
jack-canary-weight-5d7d98c98b-bh5sw     1/1     Running   0          5h41m
jack-canary-weight-5d7d98c98b-bk57p     1/1     Running   0          5h41m
jack-canary-weight-5d7d98c98b-xqb7p     1/1     Running   0          5h41m
jackli-base-5fddf784cd-xw28j            1/1     Running   0          5h41m
jackli-canary-weight-6c47c6cd97-7md27   1/1     Running   0          5h41m
jackli-canary-weight-6c47c6cd97-ghz5d   1/1     Running   0          5h41m
jackli-canary-weight-6c47c6cd97-jz9p6   1/1     Running   0          5h41m
[root@master02 ~/k8s-manifests/dashboard/rbac]#  kubectl get pods --kubeconfig='/root/homsom-kubernetes.conf' -n kube-system | wc -l    --kube-system名称空间也是有权限的
26
9.将基于证书的kubeconfig文件复制到其它服务器以便进行远程管理k8s集群：
[root@salt ~]# mkdir .kube && cd .kube
[root@salt ~/.kube]# chmod 600 homsom-kubernetes.conf 
[root@salt ~/.kube]# mv homsom-kubernetes.conf config
[root@salt ~/.kube]# kubectl get pods
NAME                                    READY   STATUS    RESTARTS   AGE
jack-base-795f8d97fc-xshwc              1/1     Running   0          5h58m
jack-canary-weight-5d7d98c98b-bh5sw     1/1     Running   0          5h57m
jack-canary-weight-5d7d98c98b-bk57p     1/1     Running   0          5h57m
jack-canary-weight-5d7d98c98b-xqb7p     1/1     Running   0          5h57m
jackli-base-5fddf784cd-xw28j            1/1     Running   0          5h58m
jackli-canary-weight-6c47c6cd97-7md27   1/1     Running   0          5h57m
jackli-canary-weight-6c47c6cd97-ghz5d   1/1     Running   0          5h57m
jackli-canary-weight-6c47c6cd97-jz9p6   1/1     Running   0          5h57m
注：
----新建用户认证信息，默认到当前用户的家目录下，路径：~/.kube/config
--------[root@master02 ~/k8s-manifests/dashboard/rbac]# kubectl config set-credentials homsom-admin --client-certificate=./homsom-admin.crt --client-key=./homsom-admin.key --embed-certs=true
----撤销设置
--------[root@master02 ~/k8s-manifests/dashboard/rbac]# kubectl config unset users.homsom-admin


#--配置SA用户
#----建立集群管理员
[root@master02 ~/k8s-manifests/dashboard]# kubectl get sa -n kubernetes-dashboard
NAME                   SECRETS   AGE
default                1         31d
kubernetes-dashboard   1         31d
1. 新建serviceaccount以及绑定集群角色cluster-admin
    [root@master02 ~/k8s-manifests/dashboard/rbac/sa]# cat ui-admin.yaml 
    apiVersion: v1
    kind: ServiceAccount
    metadata:
    name: ui-admin
    namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ui-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: ui-admin
  namespace: kubernetes-dashboard
  [root@master02 ~/k8s-manifests/dashboard/rbac/sa]# kubectl apply -f ui-admin.yaml
  serviceaccount/ui-admin created
  clusterrolebinding.rbac.authorization.k8s.io/ui-admin created
  [root@master02 ~/k8s-manifests/dashboard/rbac/sa]#  kubectl describe sa/ui-admin -n kubernetes-dashboard | grep -i token
  Mountable secrets:   ui-admin-token-55z9q
  Tokens:              ui-admin-token-55z9q
  [root@master02 ~/k8s-manifests/dashboard/rbac/sa]# kubectl describe secret/ui-admin-token-55z9q -n kubernetes-dashboard
  Name:         ui-admin-token-55z9q
  Namespace:    kubernetes-dashboard
  Labels:       <none>
  Annotations:  kubernetes.io/service-account.name: ui-admin
              kubernetes.io/service-account.uid: a42e440d-0ffa-442f-8af0-3c08073fc77e

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1066 bytes
namespace:  20 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IlZpNkVfREh1aGlLNXlZZkZaUzU1TXlrVjZUMzNrU3BTeFlwZnZ1YS05T3cifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJ1aS1hZG1pbi10b2tlbi01NXo5cSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJ1aS1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImE0MmU0NDBkLTBmZmEtNDQyZi04YWYwLTNjMDgwNzNmYzc3ZSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlcm5ldGVzLWRhc2hib2FyZDp1aS1hZG1pbiJ9.koBp77SmKw5bxH-jN-ZGCsDGG3Mkfk3pxYNh_1A-Yr6R141CNwBSQNpFpszHPEJouwsyXQOt1wQqDpN-3K9pOn1VlQmIaE2LiTyPfLyW-P2-m_zPhVbEwBeAahrC_MaqKmJy6QyzqvGKxntbHGSukw-77IKOe6G5-Nqt3Bq5KU9IX6hpc8guWDYIkQ9am9dUYS1RXSrk_dfI37jQVtUi1C5x5s7RxIKhHmx9xM8ZWYuSfpmDIfQC11zEuJbFvyQNNJNpO9zpdu1qVdpxY6HGM4JVDqU_QT4rSDKwJZ952qKJClENHOyoCDgRtJS6JZ0RRwM6g8GwtxC54zZ3JFHQ7A
注：带上这个token就可以去dashboard进行认证了

----将token制作成kubeconfig文件
1. 取出token
[root@master02 ~/k8s-manifests/dashboard/rbac/sa]# kubectl get secret/ui-admin-token-55z9q -n kubernetes-dashboard -o jsonpath='{.data.token}' | base64 -d ;echo
eyJhbGciOiJSUzI1NiIsImtpZCI6IlZpNkVfREh1aGlLNXlZZkZaUzU1TXlrVjZUMzNrU3BTeFlwZnZ1YS05T3cifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJ1aS1hZG1pbi10b2tlbi01NXo5cSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJ1aS1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImE0MmU0NDBkLTBmZmEtNDQyZi04YWYwLTNjMDgwNzNmYzc3ZSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlcm5ldGVzLWRhc2hib2FyZDp1aS1hZG1pbiJ9.koBp77SmKw5bxH-jN-ZGCsDGG3Mkfk3pxYNh_1A-Yr6R141CNwBSQNpFpszHPEJouwsyXQOt1wQqDpN-3K9pOn1VlQmIaE2LiTyPfLyW-P2-m_zPhVbEwBeAahrC_MaqKmJy6QyzqvGKxntbHGSukw-77IKOe6G5-Nqt3Bq5KU9IX6hpc8guWDYIkQ9am9dUYS1RXSrk_dfI37jQVtUi1C5x5s7RxIKhHmx9xM8ZWYuSfpmDIfQC11zEuJbFvyQNNJNpO9zpdu1qVdpxY6HGM4JVDqU_QT4rSDKwJZ952qKJClENHOyoCDgRtJS6JZ0RRwM6g8GwtxC54zZ3JFHQ7A
2. 配置集群
[root@master02 ~/k8s-manifests/dashboard/rbac/sa]# kubectl config set-cluster homsom-kubernetes --kubeconfig="./homsom-dashboard-ui_admin.conf" --server=https://k8s-api.k8s.hs.com:6443 --certificate-authority=/etc/kubernetes/pki/ca.crt --embed-certs=true
3. 配置上下文
[root@master02 ~/k8s-manifests/dashboard/rbac/sa]# kubectl config set-context ui-admin@homsom-kubernetes --cluster=homsom-kubernetes --user=ui-admin --kubeconfig="./homsom-dashboard-ui_admin.conf"
4. 配置凭据
[root@master02 ~/k8s-manifests/dashboard/rbac/sa]# kubectl config set-credentials ui-admin --token=`kubectl get secret/ui-admin-token-55z9q -n kubernetes-dashboard -o jsonpath='{.data.token}' | base64 -d` --kubeconfig="./homsom-dashboard-ui_admin.conf" 
5. 使用上下文
[root@master02 ~/k8s-manifests/dashboard/rbac/sa]# kubectl config use-context ui-admin@homsom-kubernetes --kubeconfig="./homsom-dashboard-ui_admin.conf"
6. 查看kubeconfig文件配置
[root@master02 ~/k8s-manifests/dashboard/rbac/sa]# kubectl config view --kubeconfig="./homsom-dashboard-ui_admin.conf"
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://k8s-api.k8s.hs.com:6443
  name: homsom-kubernetes
    contexts:
- context:
    cluster: homsom-kubernetes
    user: ui-admin
  name: ui-admin@homsom-kubernetes
    current-context: ui-admin@homsom-kubernetes
    kind: Config
    preferences: {}
    users:
- name: ui-admin
  user:
    token: REDACTED
7. 基于sa的token生成的kubeconfig文件既可以用做ui，也可用作kubectl
[root@master02 ~/k8s-manifests/dashboard/rbac/sa]# kubectl get pod --kubeconfig="./homsom-dashboard-ui_admin.conf"
NAME                                    READY   STATUS    RESTARTS   AGE
jack-base-795f8d97fc-xshwc              1/1     Running   0          20h
jack-canary-weight-5d7d98c98b-bh5sw     1/1     Running   0          20h
jack-canary-weight-5d7d98c98b-bk57p     1/1     Running   0          20h
jack-canary-weight-5d7d98c98b-xqb7p     1/1     Running   0          20h
jackli-base-5fddf784cd-xw28j            1/1     Running   0          20h
jackli-canary-weight-6c47c6cd97-7md27   1/1     Running   0          20h
jackli-canary-weight-6c47c6cd97-ghz5d   1/1     Running   0          20h
jackli-canary-weight-6c47c6cd97-jz9p6   1/1     Running   0          20h
[root@master02 ~/k8s-manifests/dashboard/rbac/sa]# kubectl get pod -n monitoring  --kubeconfig="./homsom-dashboard-ui_admin.conf"
NAME                                           READY   STATUS    RESTARTS   AGE
adapter-prometheus-adapter-7df9c4f77-wdfhg     1/1     Running   0          4d13h
grafana-566fc59d75-d4hqz                       1/1     Running   0          42h
prom-kube-state-metrics-649d77c759-zvwlv       1/1     Running   0          4d16h
prom-prometheus-alertmanager-0                 2/2     Running   0          42h
prom-prometheus-node-exporter-62mnz            1/1     Running   0          4d16h
prom-prometheus-node-exporter-7mx4q            1/1     Running   0          4d16h
prom-prometheus-node-exporter-b4z62            1/1     Running   0          4d16h
prom-prometheus-node-exporter-bfnvr            1/1     Running   0          4d16h
prom-prometheus-node-exporter-hvqm8            1/1     Running   0          4d16h
prom-prometheus-pushgateway-79f585d544-4pg59   1/1     Running   0          42h
prom-prometheus-server-0                       2/2     Running   0          42h


#----建立名称空间级别管理员
[root@master02 ~/k8s-manifests/dashboard/rbac/sa]# cat clusterrolebinding-namespace-monitoring-uiadmin.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: namespace-monitoring-uiadmin
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: namespace-monitoring-uiadmin
  namespace: monitoring    #生效的名称空间在这,不是serviceaccount所在的名称空间，而是rolebinding所在的名称空间所决定的。
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: admin
subjects:
- kind: ServiceAccount
  name: namespace-monitoring-uiadmin
  namespace: kubernetes-dashboard
  [root@master02 ~/k8s-manifests/dashboard/rbac/sa]# kubectl apply -f clusterrolebinding-namespace-monitoring-uiadmin.yaml
  [root@master02 ~/k8s-manifests/dashboard/rbac/sa]# kubectl describe sa/namespace-monitoring-uiadmin -n kubernetes-dashboard | grep -i ^token
  Tokens:              namespace-monitoring-uiadmin-token-zj7fq
  [root@master02 ~/k8s-manifests/dashboard/rbac/sa]# kubectl config set-cluster homsom-kubernetes --kubeconfig="./homsom-dashboard-monitoring-uiadmin.conf" --server=https://k8s-api.k8s.hs.com:6443 --certificate-authority=/etc/kubernetes/pki/ca.crt --embed-certs=true
  [root@master02 ~/k8s-manifests/dashboard/rbac/sa]# kubectl config set-context monitoring-uiadmin@homsom-kubernetes --cluster=homsom-kubernetes --user=monitoring-uiadmin --kubeconfig="./homsom-dashboard-monitoring-uiadmin.conf"
  [root@master02 ~/k8s-manifests/dashboard/rbac/sa]# kubectl config set-credentials monitoring-uiadmin --token=`kubectl get secret/namespace-monitoring-uiadmin-token-zj7fq -n kubernetes-dashboard -o jsonpath='{.data.token}' | base64 -d` --kubeconfig="./homsom-dashboard-monitoring-uiadmin.conf"
  [root@master02 ~/k8s-manifests/dashboard/rbac/sa]# kubectl config use-context monitoring-uiadmin@homsom-kubernetes --kubeconfig="./homsom-dashboard-monitoring-uiadmin.conf"
  [root@master02 ~/k8s-manifests/dashboard/rbac/sa]# kubectl config view --kubeconfig="./homsom-dashboard-monitoring-uiadmin.conf"
  apiVersion: v1
  clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://k8s-api.k8s.hs.com:6443
  name: homsom-kubernetes
    contexts:
- context:
    cluster: homsom-kubernetes
    user: monitoring-uiadmin
  name: monitoring-uiadmin@homsom-kubernetes
    current-context: monitoring-uiadmin@homsom-kubernetes
    kind: Config
    preferences: {}
    users:
- name: monitoring-uiadmin
  user:
    token: REDACTED
  [root@master02 ~/k8s-manifests/dashboard/rbac/sa]# kubectl get pod --kubeconfig="./homsom-dashboard-monitoring-uiadmin.conf"  --default名称空间无权限
  Error from server (Forbidden): pods is forbidden: User "system:serviceaccount:kubernetes-dashboard:namespace-monitoring-uiadmin" cannot list resource "pods" in API group "" in the namespace "default"
  [root@master02 ~/k8s-manifests/dashboard/rbac/sa]# kubectl get pod -n monitoring --kubeconfig="./homsom-dashboard-monitoring-uiadmin.conf"   --monitoring名称空间有权限
  NAME                                           READY   STATUS    RESTARTS   AGE
  adapter-prometheus-adapter-7df9c4f77-wdfhg     1/1     Running   0          4d13h
  grafana-566fc59d75-d4hqz                       1/1     Running   0          43h
  prom-kube-state-metrics-649d77c759-zvwlv       1/1     Running   0          4d17h
  prom-prometheus-alertmanager-0                 2/2     Running   0          43h
  prom-prometheus-node-exporter-62mnz            1/1     Running   0          4d17h
  prom-prometheus-node-exporter-7mx4q            1/1     Running   0          4d17h
  prom-prometheus-node-exporter-b4z62            1/1     Running   0          4d17h
  prom-prometheus-node-exporter-bfnvr            1/1     Running   0          4d17h
  prom-prometheus-node-exporter-hvqm8            1/1     Running   0          4d17h
  prom-prometheus-pushgateway-79f585d544-4pg59   1/1     Running   0          43h
  prom-prometheus-server-0                       2/2     Running   0          42h
  注：最后可以将此文件发送给对应人员，进行dashboard认证，进入dashboard后需要手动输入dev名称空间进行，否则会报错

#--建立整个集群可读用户
[root@master02 ~/k8s-manifests/dashboard/rbac/sa]# cat clusterrolebinding-readonly-admin.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: readonly-uiadmin
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: readonly-uiadmin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: view
subjects:
- kind: ServiceAccount
  name: readonly-uiadmin
  namespace: kubernetes-dashboard
  [root@master02 ~/k8s-manifests/dashboard/rbac/sa]# kubectl apply -f clusterrolebinding-readonly-admin.yaml
  [root@master02 ~/k8s-manifests/dashboard/rbac/sa]# kubectl describe sa/readonly-uiadmin -n kubernetes-dashboard | grep -i ^token
  Tokens:              readonly-uiadmin-token-kvgjb
  [root@master02 ~/k8s-manifests/dashboard/rbac/sa]# kubectl config set-context readonly-uiadmin@homsom-kubernetes --cluster=homsom-kubernetes --user=readonly-uiadmin --kubeconfig="./homsom-dashboard-readonly-uiadmin.conf"
  [root@master02 ~/k8s-manifests/dashboard/rbac/sa]# kubectl config set-credentials readonly-uiadmin --token=`kubectl get secret/readonly-uiadmin-token-kvgjb -n kubernetes-dashboard -o jsonpath='{.data.token}' | base64 -d` --kubeconfig="./homsom-dashboard-readonly-uiadmin.conf"
  [root@master02 ~/k8s-manifests/dashboard/rbac/sa]# kubectl config use-context readonly-uiadmin@homsom-kubernetes --kubeconfig="./homsom-dashboard-readonly-uiadmin.conf"
  [root@master02 ~/k8s-manifests/dashboard/rbac/sa]# kubectl config view --kubeconfig="./homsom-dashboard-readonly-uiadmin.conf"
  apiVersion: v1
  clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://k8s-api.k8s.hs.com:6443
  name: homsom-kubernetes
    contexts:
- context:
    cluster: homsom-kubernetes
    user: readonly-uiadmin
  name: readonly-uiadmin@homsom-kubernetes
    current-context: readonly-uiadmin@homsom-kubernetes
    kind: Config
    preferences: {}
    users:
- name: readonly-uiadmin
  user:
    token: REDACTED
  [root@master02 ~/k8s-manifests/dashboard/rbac/sa]#  kubectl get pod --kubeconfig="./homsom-dashboard-readonly-uiadmin.conf"  --可读集群所有对象
  NAME                                    READY   STATUS    RESTARTS   AGE
  jack-base-795f8d97fc-xshwc              1/1     Running   0          21h
  jack-canary-weight-5d7d98c98b-bh5sw     1/1     Running   0          21h
  jack-canary-weight-5d7d98c98b-bk57p     1/1     Running   0          21h
  jack-canary-weight-5d7d98c98b-xqb7p     1/1     Running   0          21h
  jackli-base-5fddf784cd-xw28j            1/1     Running   0          21h
  jackli-canary-weight-6c47c6cd97-7md27   1/1     Running   0          21h
  jackli-canary-weight-6c47c6cd97-ghz5d   1/1     Running   0          21h
  jackli-canary-weight-6c47c6cd97-jz9p6   1/1     Running   0          21h
  [root@master02 ~/k8s-manifests/dashboard/rbac/sa]#  kubectl get svc -n monitoring --kubeconfig="./homsom-dashboard-readonly-uiadmin.conf"  --可读集群所有对象
  NAME                                    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
  adapter-prometheus-adapter              ClusterIP   10.101.4.19      <none>        443/TCP    4d14h
  grafana                                 ClusterIP   10.106.137.45    <none>        80/TCP     4d17h
  prom-kube-state-metrics                 ClusterIP   10.105.48.195    <none>        8080/TCP   4d18h
  prom-prometheus-alertmanager            ClusterIP   10.106.173.231   <none>        80/TCP     4d18h
  prom-prometheus-alertmanager-headless   ClusterIP   None             <none>        80/TCP     4d18h
  prom-prometheus-node-exporter           ClusterIP   None             <none>        9100/TCP   4d18h
  prom-prometheus-pushgateway             ClusterIP   10.96.15.177     <none>        9091/TCP   4d18h
  prom-prometheus-server                  ClusterIP   10.109.107.120   <none>        80/TCP     4d18h
  prom-prometheus-server-headless         ClusterIP   None             <none>        80/TCP     4d18h
  [root@master02 ~/k8s-manifests/dashboard/rbac/sa]#  kubectl edit svc/grafana -n monitoring --kubeconfig="./homsom-dashboard-readonly-uiadmin.conf"   --不可编辑，没有写仅限
  error: services "grafana" could not be patched: services "grafana" is forbidden: User "system:serviceaccount:kubernetes-dashboard:readonly-uiadmin" cannot patch resource "services" in API group "" in the namespace "monitoring"
  You can run `kubectl replace -f /tmp/kubectl-edit-vl5kb.yaml` to try this update again.
  注：--edit角色如上，不做案例分享：

#查看sa用户绑定的role权限
[root@LocalServer ~]# kubectl describe sa/prometheus -n monitoring
Name:                prometheus
Namespace:           monitoring
Labels:              app=prometheus
                     app.kubernetes.io/managed-by=Helm
                     chart=prometheus-11.12.1
                     component=server
                     heritage=Helm
                     release=prom
Annotations:         meta.helm.sh/release-name: prom
                     meta.helm.sh/release-namespace: monitoring
Image pull secrets:  <none>
Mountable secrets:   prometheus-token-jdb7t
Tokens:              prometheus-token-jdb7t
Events:              <none>
----查看rolebinding
[root@LocalServer ~]# for i in `kubectl get rolebinding | awk '{print $1}' | grep -v NAME`;do kubectl get clusterrolebinding/$i -o jsonpath='{.metadata.name}: {.subjects},{.roleRef}';echo;done | grep '"monitoring"' | grep '"prometheus"'
No resources found in default namespace.
----查看clusterrolebinding，从下面可知是引用的哪个角色
[root@LocalServer ~]# for i in `kubectl get clusterrolebinding | awk '{print $1}' | grep -v NAME`;do kubectl get clusterrolebinding/$i -o jsonpath='{.metadata.name}: {.subjects},{.roleRef}';echo;done | grep '"monitoring"' | grep '"prometheus"'
prometheus: [{"kind":"ServiceAccount","name":"prometheus","namespace":"monitoring"}],{"apiGroup":"rbac.authorization.k8s.io","kind":"ClusterRole","name":"cluster-admin"}
```


### 1.18 helm

部署helm-v3.5.3
```bash
1. 安装helm:  注意：helm 客户端需要下载到安装了 kubectl 并且能执行能正常通过 kubectl 操作 kubernetes 的服务器上，否则 helm 将不可用。
[root@master02 ~/k8s-manifests/helm]# axel -n 60 https://get.helm.sh/helm-v3.5.3-linux-amd64.tar.gz
[root@master02 ~/k8s-manifests/helm]# tar xf helm-v3.5.3-linux-amd64.tar.gz
[root@master02 ~/k8s-manifests/helm]# cd linux-amd64/
[root@master02 ~/k8s-manifests/helm/linux-amd64]# mv helm  /usr/local/bin/
[root@master02 ~/k8s-manifests/helm/linux-amd64]# helm env
HELM_BIN="helm"
HELM_CACHE_HOME="/root/.cache/helm"
HELM_CONFIG_HOME="/root/.config/helm"
HELM_DATA_HOME="/root/.local/share/helm"
HELM_DEBUG="false"
HELM_KUBEAPISERVER=""
HELM_KUBEASGROUPS=""
HELM_KUBEASUSER=""
HELM_KUBECAFILE=""
HELM_KUBECONTEXT=""
HELM_KUBETOKEN=""
HELM_MAX_HISTORY="10"
HELM_NAMESPACE="default"
HELM_PLUGINS="/root/.local/share/helm/plugins"
HELM_REGISTRY_CONFIG="/root/.config/helm/registry.json"
HELM_REPOSITORY_CACHE="/root/.cache/helm/repository"
HELM_REPOSITORY_CONFIG="/root/.config/helm/repositories.yaml"
[root@master02 ~/k8s-manifests/helm/linux-amd64]# helm repo list 
Error: no repositories to show
2. 添加helm仓库
[root@master02 ~/k8s-manifests/helm/linux-amd64]# helm repo add stable http://mirror.azure.cn/kubernetes/charts
"stable" has been added to your repositories
[root@master02 ~/k8s-manifests/helm/linux-amd64]# helm repo add aliyun https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts   #(helm3使用不了，有坑未更新)
"aliyun" has been added to your repositories
[root@master02 ~/k8s-manifests/helm/linux-amd64]# helm repo list 
NAME  	URL                                                   
stable	https://charts.helm.sh/stable             
aliyun	https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
[root@master02 ~/k8s-manifests/helm/linux-amd64]# helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "aliyun" chart repository
...Successfully got an update from the "stable" chart repository
Update Complete. ⎈Happy Helming!⎈
--其它repo
helm repo add  elastic    https://helm.elastic.co
helm repo add  gitlab     https://charts.gitlab.io
helm repo add  harbor     https://helm.goharbor.io
helm repo add  bitnami    https://charts.bitnami.com/bitnami
helm repo add  incubator  https://kubernetes-charts-incubator.storage.googleapis.com
[root@master02 ~/k8s-manifests/helm/linux-amd64]# helm repo list 
NAME   	URL                                                   
aliyun 	https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
elastic	https://helm.elastic.co                               
gitlab 	https://charts.gitlab.io                              
harbor 	https://helm.goharbor.io                              
bitnami	https://charts.bitnami.com/bitnami                    
stable 	http://mirror.azure.cn/kubernetes/charts      
4. 指定对应的k8s集群
这一步非常关键，它是helm与k8s通讯的保证，这一步就是把k8s环境变量KUBECONFIG进行配置
[root@master02 ~/k8s-manifests/helm/linux-amd64]# echo 'export KUBECONFIG=/root/.kube/config' >> /etc/profile
[root@master02 ~/k8s-manifests/helm/linux-amd64]# . /etc/profile
5. helm应用：
--安装
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# helm search repo nginx
NAME                            	CHART VERSION	APP VERSION	DESCRIPTION                                       
aliyun/nginx-ingress            	0.9.5        	0.10.2     	An nginx Ingress controller that uses ConfigMap...
aliyun/nginx-lego               	0.3.1        	           	Chart for nginx-ingress-controller and kube-lego  
bitnami/nginx                   	8.9.0        	1.19.10    	Chart for the nginx server                        
bitnami/nginx-ingress-controller	7.6.6        	0.46.0     	Chart for the nginx Ingress controller            
stable/nginx-ingress            	1.41.3       	v0.34.1    	DEPRECATED! An nginx Ingress controller that us...
stable/nginx-ldapauth-proxy     	0.1.6        	1.13.5     	DEPRECATED - nginx proxy with ldapauth            
stable/nginx-lego               	0.3.1        	           	Chart for nginx-ingress-controller and kube-lego  
bitnami/kong                    	3.7.2        	2.4.0      	Kong is a scalable, open source API layer (aka ...
aliyun/gcloud-endpoints         	0.1.0        	           	Develop, deploy, protect and monitor your APIs ...
stable/gcloud-endpoints         	0.1.2        	1          	DEPRECATED Develop, deploy, protect and monitor...
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# helm install nginx bitnami/nginx -n web
NAME: nginx
LAST DEPLOYED: Sat May  8 17:44:41 2021
NAMESPACE: web
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
** Please be patient while the chart is being deployed **

NGINX can be accessed through the following DNS name from within your cluster:

    nginx.web.svc.cluster.local (port 80)

To access NGINX from outside the cluster, follow the steps below:

1. Get the NGINX URL by running these commands:

  NOTE: It may take a few minutes for the LoadBalancer IP to be available.
        Watch the status with: 'kubectl get svc --namespace web -w nginx'

    export SERVICE_PORT=$(kubectl get --namespace web -o jsonpath="{.spec.ports[0].port}" services nginx)
    export SERVICE_IP=$(kubectl get svc --namespace web nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    echo "http://${SERVICE_IP}:${SERVICE_PORT}"
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# curl -I http://localhost:31905
HTTP/1.1 200 OK
--查看安装的应用
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# helm list -n web
NAME 	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART      	APP VERSION
nginx	web      	1       	2021-05-08 17:44:41.758624134 +0800 CST	deployed	nginx-8.9.0	1.19.10   
--查看应用状态 
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# helm status nginx -n web
NAME: nginx
LAST DEPLOYED: Sat May  8 17:44:41 2021
NAMESPACE: web
STATUS: deployed
REVISION: 1
TEST SUITE: None
-------自定义参数安装应用
--查看应用 chart 可配置参数
[root@master02 ~/k8s-manifests/ingress-controller-nginx]#  helm show values bitnami/nginx | grep -Ev '#|^$' 
方式一：使用自定义 values.yaml 文件安装应用
[root@master02 ~/k8s-manifests/helm]# cat values.yaml 
image:
  registry: docker.io
  repository: bitnami/nginx
resources:
  limits: 
     cpu: 1000m
     memory: 1024Mi
  requests: 
     cpu: 1000m
     memory: 1024Mi
[root@master02 ~/k8s-manifests/helm]# helm install nginx -f values.yaml bitnami/nginx -n default
方式二：使用 --set 配置参数进行安装
--set 参数是在使用 helm 命令时候添加的参数，可以在执行 helm 安装与更新应用时使用，多个参数间用","隔开，使用如下：
如果配置文件和 --set 同时使用，则 --set 设置的参数会覆盖配置文件中的参数配置
helm install nginx --set 'image.registry=docker.io,image.repository=bitnami/nginx' bitnami/nginx -n default
--卸载应用，不保留安装记录:
[root@master02 ~/k8s-manifests/helm]# helm uninstall nginx
release "nginx" uninstalled
--卸载应用，并保留安装记录
[root@master02 ~/k8s-manifests/helm]# helm uninstall nginx -n web --keep-history
release "nginx" uninstalled
--查看全部安装的应用
[root@master02 ~/k8s-manifests/helm]# helm list --all-namespaces
NAME	NAMESPACE	REVISION	UPDATED	STATUS	CHART	APP VERSION
--查看全部应用（包含安装和卸载的应用）
[root@master02 ~/k8s-manifests/helm]# helm list --all-namespaces --all
NAME 	NAMESPACE	REVISION	UPDATED                                	STATUS     	CHART      	APP VERSION
nginx	web      	1       	2021-05-08 17:44:41.758624134 +0800 CST	uninstalled	nginx-8.9.0	1.19.10    
--卸载应用，不保留安装记录，也可仅删除安装记录
[root@master02 ~/k8s-manifests/helm]# helm delete nginx -n web
release "nginx" uninstalled
--应用升级
[root@master02 ~/k8s-manifests/helm]# cat values.yaml 
service.type: NodePort
service.nodePorts.http: 30002
[root@master02 ~/k8s-manifests/helm]# kubectl get svc -n web 
NAME    TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
nginx   LoadBalancer   10.102.7.48   <pending>     80:32335/TCP   40s
[root@master02 ~/k8s-manifests/helm]#  helm upgrade -f values.yaml nginx bitnami/nginx -n web
[root@master02 ~/k8s-manifests/helm]# helm get values nginx -n web
USER-SUPPLIED VALUES:
service.nodePorts.http: 30002
service.type: NodePort
```

### 1.19 ingress高可用

```bash
1. 修改Deployment为DaemonSet，并注释掉副本数
    apiVersion: apps/v1
    #kind: Deployment
    kind: DaemonSet
    metadata:
    labels:
    helm.sh/chart: ingress-nginx-3.30.0
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.46.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: controller
    name: ingress-nginx-controller
    namespace: ingress-nginx
    spec:
    #replicas: 2
2. 启用hostNetwork网络
   spec:
    spec:
      hostNetwork: true
      nodeSelector:
        ingresscontroller: 'true'
3. 修改镜像地址
      containers:
        - name: controller
          image: k8s.gcr.io/ingress-nginx/controller:v0.46.0
4. 修改容器端口定义并注释使用的协议，因为是http协议
         ports:
            - name: http
              containerPort: 80
              #protocol: TCP
            - name: https
              containerPort: 443
              #protocol: TCP
5. 增加master节点容忍并指定节点运行
      nodeSelector:
        ingresscontroller: 'true'
      tolerations:
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule

6. 给特定节点打要标签
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl label --overwrite node node01.k8s.hs.com ingresscontroller=true
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl label --overwrite node node02.k8s.hs.com ingresscontroller=true
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl get node -l ingresscontroller=true --show-labels
NAME                STATUS     ROLES    AGE   VERSION    LABELS
node01.k8s.hs.com   NotReady   <none>   10d   v1.19.10   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,ingresscontroller=true,kubernetes.io/arch=amd64,kubernetes.io/hostname=node01.k8s.hs.com,kubernetes.io/os=linux
node02.k8s.hs.com   Ready      <none>   10d   v1.19.10   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,ingresscontroller=true,kubernetes.io/arch=amd64,kubernetes.io/hostname=node02.k8s.hs.com,kubernetes.io/os=linux
7. ingress节点扩展
-- 比如给master节点打上标签，此时master节点立马构建一个ingress controller pod
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl label node master01.k8s.hs.com ingresscontroller=true
node/master01.k8s.hs.com labeled
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl get pods -n ingress-nginx -o wide 
NAME                                   READY   STATUS              RESTARTS   AGE     IP              NODE                  NOMINATED NODE   READINESS GATES
ingress-nginx-admission-create-rgvvz   0/1     Completed           0          4m25s   10.244.3.57     node01.k8s.hs.com     <none>           <none>
ingress-nginx-admission-patch-rv8dn    0/1     Completed           1          4m25s   10.244.3.58     node01.k8s.hs.com     <none>           <none>
ingress-nginx-controller-8qtjp         0/1     ContainerCreating   0          2s      192.168.13.51   master01.k8s.hs.com   <none>           <none>
ingress-nginx-controller-rm8gk         1/1     Running             0          4m25s   192.168.13.57   node02.k8s.hs.com     <none>           <none>
ingress-nginx-controller-z4hpx         1/1     Running             0          4m25s   192.168.13.56   node01.k8s.hs.com     <none>           <none>
8. 删除多余ingress controller节点
-- 删除标签
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl label node master01.k8s.hs.com ingresscontroller-
node/master01.k8s.hs.com labeled
[root@master02 ~/k8s-manifests/ingress-controller-nginx]# kubectl get pods -n ingress-nginx -o wide 
NAME                                   READY   STATUS        RESTARTS   AGE     IP              NODE                  NOMINATED NODE   READINESS GATES
ingress-nginx-admission-create-rgvvz   0/1     Completed     0          6m44s   10.244.3.57     node01.k8s.hs.com     <none>           <none>
ingress-nginx-admission-patch-rv8dn    0/1     Completed     1          6m44s   10.244.3.58     node01.k8s.hs.com     <none>           <none>
ingress-nginx-controller-8qtjp         1/1     Terminating   0          2m21s   192.168.13.51   master01.k8s.hs.com   <none>           <none>   --当去除标签时，master节点上的ingress controller pod立即被删除
ingress-nginx-controller-rm8gk         1/1     Running       0          6m44s   192.168.13.57   node02.k8s.hs.com     <none>           <none>
ingress-nginx-controller-z4hpx         1/1     Running       0          6m44s   192.168.13.56   node01.k8s.hs.com     <none>           <none>
9. 此时在两个节点 node01.k8s.hs.com、node02.k8s.hs.com上有两个ingress controller pod，无论访问哪一个pod都可以访问后端的服务，实现了高可用，可以结合keepalived软件实现VIP

```

### 1.20 ingress 使用

**ingress nginx灰度发布**

```bash
# 发布base容器
[root@master02 ~/k8s-manifests/app]# cat hs-app-base.yaml
apiVersion: v1
kind: Service
metadata:
  name: hotelresourcejinjiang-base
  namespace: default
spec:
  selector:
    app: hotelresourcejinjiang.hs.com
    Language: netCore
    env: test
    team: ops
    tag: base
  ports:
  - name: http
    port: 80
    targetPort: 80  
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hotelresourcejinjiang-base
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hotelresourcejinjiang.hs.com
      Language: netCore
      env: test
      team: ops
      tag: base
  template:
    metadata:
      labels:
        app: hotelresourcejinjiang.hs.com
        Language: netCore
        env: test
        team: ops
        tag: base
    spec:
      containers:
      - name: hotelresourcejinjiang
        image: ikubernetes/myapp:v1
        imagePullPolicy: IfNotPresent
        ports:
        - name: http
          containerPort: 80
        livenessProbe:
          httpGet:
            port: http
            path: /index.html
          initialDelaySeconds: 1 
          periodSeconds: 3 
        readinessProbe:
          httpGet:
            port: http
            path: /index.html
          initialDelaySeconds: 1 
          periodSeconds: 3 
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "640Mi"
            cpu: "500m"
[root@master02 ~/k8s-manifests/app]# kubectl apply -f hs-app-base.yaml
---配置ingress 
[root@master02 ~/k8s-manifests/app]# cat ingress-hotelresourcejinjiang-base.yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: hotelresourcejinjiang-base
  namespace: default
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "60"
spec:
  rules:
  - host: hotelresourcejinjiang.hs.com
    http:
      paths: 
      - path: /
        backend:
          serviceName: hotelresourcejinjiang-base
          servicePort: 80
        [root@master02 ~/k8s-manifests/app]# kubectl apply -f ingress-hotelresourcejinjiang-base.yaml
        ---测试hotelresourcejinjiang.hs.com是否为v1
        [root@salt ~]# while true;do date;curl -H 'host: hotelresourcejinjiang.hs.com' http://192.168.13.57;sleep 0.5;done
        2021年 05月 12日 星期三 17:39:13 CST
        Hello MyApp | Version: v1 | <a href="hostname.html">Pod Name</a>

---升级v2版本，并且配置通过Header来判断访问后端Endpoints
1. 先部署deployment
    [root@master02 ~/k8s-manifests/app]# cat hs-app-canary-header.yaml 
    apiVersion: v1
    kind: Service
    metadata:
    name: hotelresourcejinjiang-canary-header
    namespace: default
    spec:
    selector:
    app: hotelresourcejinjiang.hs.com
    Language: netCore
    env: test
    team: ops
    tag: canary-header
    ports:
  - name: http
    port: 80
    targetPort: 80  
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hotelresourcejinjiang-canary-header
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hotelresourcejinjiang.hs.com
      Language: netCore
      env: test
      team: ops
      tag: canary-header
  template:
    metadata:
      labels:
        app: hotelresourcejinjiang.hs.com
        Language: netCore
        env: test
        team: ops
        tag: canary-header
    spec:
      containers:
      - name: hotelresourcejinjiang
        image: ikubernetes/myapp:v2
        imagePullPolicy: IfNotPresent
        ports:
        - name: http
          containerPort: 80
        livenessProbe:
          httpGet:
            port: http
            path: /index.html
          initialDelaySeconds: 1 
          periodSeconds: 3 
        readinessProbe:
          httpGet:
            port: http
            path: /index.html
          initialDelaySeconds: 1 
          periodSeconds: 3 
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "640Mi"
            cpu: "500m"
[root@master02 ~/k8s-manifests/app]# kubectl apply -f hs-app-canary-header.yaml
2. 最后部署ingress
    [root@master02 ~/k8s-manifests/app]# cat ingress-hotelresourcejinjiang-canary-header.yaml 
    apiVersion: extensions/v1beta1
    kind: Ingress
    metadata:
    name: hotelresourcejinjiang-canary-header
    namespace: default
    annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "60"
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-header: "x-app-canary"
    nginx.ingress.kubernetes.io/canary-by-header-value: "true"
    spec:
    rules:
  - host: hotelresourcejinjiang.hs.com
    http:
      paths: 
      - backend:
          serviceName: hotelresourcejinjiang-canary-header
          servicePort: 80
          [root@master02 ~/k8s-manifests/app]# kubectl apply -f ingress-hotelresourcejinjiang-canary-header.yaml
3. 测试通过指定头部获取的结果是否为v2
[root@salt ~]# while true;do date;curl -H 'x-app-canary: true' http://hotelresourcejinjiang.hs.com;sleep 1;done
2021年 05月 12日 星期三 21:01:23 CST
Hello MyApp | Version: v2 | <a href="hostname.html">Pod Name</a>
----通过主机名访问依旧为v1
[root@salt ~]# while true;do date;curl -H 'host: hotelresourcejinjiang.hs.com' http://192.168.13.57;sleep 1;done
2021年 05月 13日 星期四 09:05:15 CST
Hello MyApp | Version: v1 | <a href="hostname.html">Pod Name</a>

# 通过权重值和通过head来发布时，只能生效一种，虽然两个ingress清单可以配置，但是实际生效的是其中一个
1. 通过权重值进行灰度发布，先发布后端pod
    [root@master02 ~/k8s-manifests/app]# cat hs-app-canary-weight.yaml
    apiVersion: v1
    kind: Service
    metadata:
    name: hotelresourcejinjiang-canary-weight
    namespace: default
    spec:
    selector:
    app: hotelresourcejinjiang.hs.com
    Language: netCore
    env: test
    team: ops
    tag: canary-weight
    ports:
  - name: http
    port: 80
    targetPort: 80  
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hotelresourcejinjiang-canary-weight
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hotelresourcejinjiang.hs.com
      Language: netCore
      env: test
      team: ops
      tag: canary-weight
  template:
    metadata:
      labels:
        app: hotelresourcejinjiang.hs.com
        Language: netCore
        env: test
        team: ops
        tag: canary-weight
    spec:
      containers:
      - name: hotelresourcejinjiang
        image: ikubernetes/myapp:v3
        imagePullPolicy: IfNotPresent
        ports:
        - name: http
          containerPort: 80
        livenessProbe:
          httpGet:
            port: http
            path: /index.html
          initialDelaySeconds: 1 
          periodSeconds: 3 
        readinessProbe:
          httpGet:
            port: http
            path: /index.html
          initialDelaySeconds: 1 
          periodSeconds: 3 
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "640Mi"
            cpu: "500m"
[root@master02 ~/k8s-manifests/app]# kubectl apply -f hs-app-canary-weight.yaml
[root@master02 ~/k8s-manifests/app]# kubectl get pods -o wide 
NAME                                                   READY   STATUS    RESTARTS   AGE     IP             NODE                NOMINATED NODE   READINESS GATES
hotelresourcejinjiang-base-c6dfd948c-clxtd             1/1     Running   0          4m24s   10.244.4.171   node02.k8s.hs.com   <none>           <none>
hotelresourcejinjiang-base-c6dfd948c-sbjg5             1/1     Running   0          4m24s   10.244.3.252   node01.k8s.hs.com   <none>           <none>
hotelresourcejinjiang-canary-header-88c79bb8f-bvfj6    1/1     Running   0          2m58s   10.244.4.172   node02.k8s.hs.com   <none>           <none>
hotelresourcejinjiang-canary-header-88c79bb8f-gxcmf    1/1     Running   0          2m58s   10.244.3.253   node01.k8s.hs.com   <none>           <none>
hotelresourcejinjiang-canary-weight-5c79dc4bb5-sft25   1/1     Running   0          38s     10.244.4.173   node02.k8s.hs.com   <none>           <none>
hotelresourcejinjiang-canary-weight-5c79dc4bb5-sq99l   1/1     Running   0          38s     10.244.3.254   node01.k8s.hs.com   <none>           <none>
[root@master02 ~/k8s-manifests/app]# kubectl get ingress 
NAME                                  CLASS    HOSTS                          ADDRESS                       PORTS   AGE
hotelresourcejinjiang-base            <none>   hotelresourcejinjiang.hs.com   192.168.13.56,192.168.13.57   80      3m59s
hotelresourcejinjiang-canary-header   <none>   hotelresourcejinjiang.hs.com   192.168.13.56,192.168.13.57   80      2m4s
2. 部署基于weight的ingress
[root@master02 ~/k8s-manifests/app]# cat ingress-hotelresourcejinjiang-canary-weight.yaml
    apiVersion: extensions/v1beta1
    kind: Ingress
    metadata:
    name: hotelresourcejinjiang-canary-weight
    namespace: default
    annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "60"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: "100"
    spec:
    rules:
  - host: hotelresourcejinjiang.hs.com
    http:
      paths: 
      - path: /
        backend:
          serviceName: hotelresourcejinjiang-canary-weight
          servicePort: 80
        [root@master02 ~/k8s-manifests/app]# kubectl apply -f ingress-hotelresourcejinjiang-canary-weight.yaml
        [root@master02 ~/k8s-manifests/app]# kubectl get ingress -o wide
        NAME                                  CLASS    HOSTS                          ADDRESS                       PORTS   AGE
        hotelresourcejinjiang-base            <none>   hotelresourcejinjiang.hs.com   192.168.13.56,192.168.13.57   80      6m16s
        hotelresourcejinjiang-canary-header   <none>   hotelresourcejinjiang.hs.com   192.168.13.56,192.168.13.57   80      4m21s
        hotelresourcejinjiang-canary-weight   <none>   hotelresourcejinjiang.hs.com   192.168.13.56,192.168.13.57   80      79s
        ----此时，生效的还是v1和v2，而hotelresourcejinjiang-canary-weight没有生效，因为此域名基于权重值和header都已经发布ingress,所以只能生效其一
        [root@salt ~]# while true;do date;curl -H 'x-app-canary: true' http://hotelresourcejinjiang.hs.com;sleep 1;done
        2021年 05月 12日 星期三 21:01:23 CST
        Hello MyApp | Version: v2 | <a href="hostname.html">Pod Name</a>
        ----通过主机名访问依旧为v1
        [root@salt ~]# while true;do date;curl -H 'host: hotelresourcejinjiang.hs.com' http://192.168.13.57;sleep 1;done
        2021年 05月 13日 星期四 09:05:15 CST
        Hello MyApp | Version: v1 | <a href="hostname.html">Pod Name</a>
3. 移除基于header的ingress、deployment及service，并且使基于权重值的canary生效，因为权重值是50，所以是灰度发布
[root@master02 ~/k8s-manifests/app]# kubectl delete -f ingress-hotelresourcejinjiang-canary-header.yaml 
[root@master02 ~/k8s-manifests/app]# kubectl delete -f hs-app-canary-header.yaml
[root@master02 ~/k8s-manifests/app]# kubectl get ingress -o wide 
NAME                                  CLASS    HOSTS                          ADDRESS                       PORTS   AGE
hotelresourcejinjiang-base            <none>   hotelresourcejinjiang.hs.com   192.168.13.56,192.168.13.57   80      12h
hotelresourcejinjiang-canary-weight   <none>   hotelresourcejinjiang.hs.com   192.168.13.56,192.168.13.57   80      3m5s
4. 测试
[root@salt ~]# while true;do date;curl -H 'host: hotelresourcejinjiang.hs.com' http://192.168.13.57;sleep 1;done
2021年 05月 13日 星期四 09:33:31 CST
Hello MyApp | Version: v1 | <a href="hostname.html">Pod Name</a>
2021年 05月 13日 星期四 09:33:32 CST
Hello MyApp | Version: v3 | <a href="hostname.html">Pod Name</a>
注：此时已经生效，因为权重值为50，所以一半是v1,一半是v3。权重值范围为0-100

#进行真正的灰度发布
1. 假如v3新版本没有问题，那么将权重值设为100，使所有请求都到新发布的pod上来，实现了滚动更新灰度发布新版本
    [root@master02 ~/k8s-manifests/app]# \cp -a ingress-hotelresourcejinjiang-canary-weight.yaml ingress-hotelresourcejinjiang-canary-weight.yaml.backup
    [root@master02 ~/k8s-manifests/app]# sed -i 's/canary-weight: "50"/canary-weight: "100"/g' ingress-hotelresourcejinjiang-canary-weight.yaml
    [root@master02 ~/k8s-manifests/app]# cat ingress-hotelresourcejinjiang-canary-weight.yaml 
    apiVersion: extensions/v1beta1
    kind: Ingress
    metadata:
    name: hotelresourcejinjiang-canary-weight
    namespace: default
    annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "60"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: "100"
    spec:
    rules:
  - host: hotelresourcejinjiang.hs.com
    http:
      paths: 
      - path: /
        backend:
          serviceName: hotelresourcejinjiang-canary-weight
          servicePort: 80
        [root@master02 ~/k8s-manifests/app]# kubectl apply -f ingress-hotelresourcejinjiang-canary-weight.yaml
2. 假如又发布了一个新版本为v4，此时需要进行直接蓝绿发布,需要在hotelresourcejinjiang-base的配置清单中更改service和deployment关联的后端pod版本
    [root@master02 ~/k8s-manifests/app]# \cp -a hs-app-base.yaml hs-app-base.yaml.backup
    [root@master02 ~/k8s-manifests/app]# sed -i 's#ikubernetes/myapp:v1#ikubernetes/myapp:v4#g' hs-app-base.yaml
    [root@master02 ~/k8s-manifests/app]# cat hs-app-base.yaml
    apiVersion: v1
    kind: Service
    metadata:
    name: hotelresourcejinjiang-base
    namespace: default
    spec:
    selector:
    app: hotelresourcejinjiang.hs.com
    Language: netCore
    env: test
    team: ops
    tag: base
    ports:
  - name: http
    port: 80
    targetPort: 80  
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hotelresourcejinjiang-base
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hotelresourcejinjiang.hs.com
      Language: netCore
      env: test
      team: ops
      tag: base
  template:
    metadata:
      labels:
        app: hotelresourcejinjiang.hs.com
        Language: netCore
        env: test
        team: ops
        tag: base
    spec:
      containers:
      - name: hotelresourcejinjiang
        image: ikubernetes/myapp:v4
        imagePullPolicy: IfNotPresent
        ports:
        - name: http
          containerPort: 80
        livenessProbe:
          httpGet:
            port: http
            path: /index.html
          initialDelaySeconds: 1 
          periodSeconds: 3 
        readinessProbe:
          httpGet:
            port: http
            path: /index.html
          initialDelaySeconds: 1 
          periodSeconds: 3 
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "640Mi"
            cpu: "500m"
[root@master02 ~/k8s-manifests/app]# kubectl apply -f hs-app-base.yaml
3. 更改canary权重值从100为0，实行蓝绿部署
    [root@master02 ~/k8s-manifests/app]# \cp -a ingress-hotelresourcejinjiang-canary-weight.yaml ingress-hotelresourcejinjiang-canary-weight.yaml.backup
    [root@master02 ~/k8s-manifests/app]# sed -i 's/canary-weight: "100"/canary-weight: "0"/g' ingress-hotelresourcejinjiang-canary-weight.yaml 
    [root@master02 ~/k8s-manifests/app]# cat ingress-hotelresourcejinjiang-canary-weight.yaml  
    apiVersion: extensions/v1beta1
    kind: Ingress
    metadata:
    name: hotelresourcejinjiang-canary-weight
    namespace: default
    annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "60"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: "0"
    spec:
    rules:
  - host: hotelresourcejinjiang.hs.com
    http:
      paths: 
      - path: /
        backend:
          serviceName: hotelresourcejinjiang-canary-weight
          servicePort: 80
        [root@master02 ~/k8s-manifests/app]# kubectl apply -f ingress-hotelresourcejinjiang-canary-weight.yaml
4. 测试，已经到v4版本了
[root@salt ~]# while true;do date;curl -H 'x-app-canary: true' http://hotelresourcejinjiang.hs.com;sleep 1;done   
2021年 05月 13日 星期四 11:02:28 CST
Hello MyApp | Version: v4 | <a href="hostname.html">Pod Name</a>

#回滚
1. 判断权重值是多少
[root@master02 ~/k8s-manifests/app]# kubectl get ingress/hotelresourcejinjiang-canary-weight -o yaml 2>  /dev/null | grep 'canary-weight: "' | awk -F '"' '{print $2}'
0
2. 如果值是0则将值设置为100，如果值是100，则将值设为0，并重新应用基于权重的ingress
[root@master02 ~/k8s-manifests/app]# sed -i 's/canary-weight: "0"/canary-weight: "100"/g' ingress-hotelresourcejinjiang-canary-weight.yaml 
[root@master02 ~/k8s-manifests/app]# kubectl apply -f ingress-hotelresourcejinjiang-canary-weight.yaml
--给ingress权重打补丁实现蓝绿部署、灰度发布、回滚到上一个版本
kubectl patch ingress/hotelresourcejinjiang-canary-weight -p '{"metadata":{"annotations":{"nginx.ingress.kubernetes.io/canary-weight": "0"}}}'

#回滚到指定版本/或者发布到指定版本
1. 判断权重值是否为0
[root@master02 ~/k8s-manifests/app]# kubectl get ingress/hotelresourcejinjiang-canary-weight -o yaml 2>  /dev/null | grep 'canary-weight: "' | awk -F '"' '{print $2}'
0
2. 如果为0，表示ingress-canary-weight未生效，生效的是ingress-base,此时应该更新ingress-canary-weight对应的service绑定后端的deployment的pod镜像版本，将镜像版本更改为目标版本，例如为v2：
kubectl patch deployment/hotelresourcejinjiang-canary-weight -p '{"spec": {"template": {"spec": {"containers": [{"name": "hotelresourcejinjiang","image": "ikubernetes/myapp:v2"}]}}}}'
当镜像版本变更后，需要配置权重值为100并应用
kubectl patch ingress/hotelresourcejinjiang-canary-weight -p '{"metadata":{"annotations":{"nginx.ingress.kubernetes.io/canary-weight": "100"}}}'
3. 如果为100，表示ngress-canary-weight已生效，未生产的是ingress-base，此时应该更新ingress-base对应的service绑定后端的deployment的pod镜像版本，将镜像版本更改为目标版本，例如为v5：
kubectl patch deployment/hotelresourcejinjiang-base -p '{"spec": {"template": {"spec": {"containers": [{"name": "hotelresourcejinjiang","image": "ikubernetes/myapp:v5"}]}}}}'
当镜像版本变更后，需要配置权重值为0并应用
kubectl patch ingress/hotelresourcejinjiang-canary-weight -p '{"metadata":{"annotations":{"nginx.ingress.kubernetes.io/canary-weight": "0"}}}'

#如何判断后端endpoints是否健康就绪
DEPLOYMENT_NAME='hotelresourcejinjiang-base'
POD_RESULT=`kubectl get pods | grep hotelresourcejinjiang-base* | awk '{print $1}'`
POD_COUNT=`kubectl get pods | grep hotelresourcejinjiang-base* | wc -l`
tmp_count=0
while [ ! ${tmp_count} == ${POD_COUNT} ]; do for i in ${POD_RESULT};do kubectl get pods -n default | grep $i; [ $? == 0 ] && echo 'pod is live' || ((tmp_count++)) ;done ;sleep 1;done
```



### 1.21 promehteus 监控Ingress

**prometheus serviceaccount定义**
```bash
[root@master02 ~/k8s-manifests/prometheus/prometheus-legecy]# cat prometheus-rbac-setup-monitoring.yml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prometheus
rules:
- apiGroups: ["*"]
  resources:
  - "*"
  verbs: ["get","list","watch"]
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus
  namespace: monitoring
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: prometheus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus
subjects:
- kind: ServiceAccount
  name: prometheus
  namespace: monitoring
---
```


**promehteus 监控Ingress**
在部署ingerss清单中，对service名为ingress-nginx-controller的配置段进行添加资源注解，并且重新应用配置即可，此后就可在prometheus上的target中找到名为kubernetes-service-endpoints的job，就可看到ingress的endpoints:
```bash
apiVersion: v1
kind: Service
metadata:
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "10254"
  labels:
    helm.sh/chart: ingress-nginx-3.30.0
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.46.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: controller
  name: ingress-nginx-controller
  namespace: ingress-nginx
spec:
  type: NodePort
---
注：主要是在资源注解中注明prometheus抓取metric的端口以及开关。


# prometheus rules定义：
[root@LocalServer /shell]# kubectl edit cm/prom-prometheus-server -n monitoring
-------------------
    rule_files:
    - /etc/config/kubernetes_pods.yml
    - /etc/config/apiserver_rules.yml
    - /etc/config/node-exporter_rules.yml
    - /etc/config/KubernetesPods_rules.yml
-------------------
data:
  KubernetesPods_rules.yml: |
    groups:
    - name: KubernetesIngressStatusAlert
      rules:
      - alert: KubernetesIngressRequestLatencyAlert
        expr: histogram_quantile(0.90, sum(rate(nginx_ingress_controller_request_duration_seconds_bucket{ingress!="",controller_class=~"nginx"}[2m])) by (le, ingress, namespace, controller_namespace,controller_class, job, instance)) > 0.1
        for: 5m
        labels:
          severity: warnning
        annotations:
          summary: "Kubernetes Ingress Request Latency High"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}}, controller_class: {{ $labels.controller_class }}, controller_namespace: {{$labels.controller_namespace}}, namespace: {{ $labels.namespace }}, ingress: {{$labels.ingress}} Kubernetes Ingress P90 Request Latency above 100ms/5m (current value: {{ $value }})"		  		  
      - alert: KubernetesIngressConnectNumberAlert
        expr: sum by(job, instance, controller_class, controller_namespace, controller_pod,) (avg_over_time((nginx_ingress_controller_nginx_process_connections[5m]))) > 100
        for: 5m
        labels:
          severity: warnning
        annotations:
          summary: "Kubernetes Ingress Connect Number Many"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}}, controller_class: {{ $labels.controller_class }}, controller_namespace: {{$labels.controller_namespace}}, controller_pod: {{$labels.controller_pod}} Kubernetes Ingress Connect Number above 100/5m (current value: {{ $value }})"		  		  
  kubernetes_pods.yml: |		#custom kubernetes_pods rules
    groups:
    - name: KubernetesPodsStatusAlert
      rules:
      - alert: KubernetesAllPodsCPUUsageAlert
        expr: sum by (instance,job) (irate(container_cpu_usage_seconds_total{image!="",name=~"^k8s_.*"}[5m])) / sum by (instance,job) (machine_cpu_cores) * 100 > 70 
        for: 5m
        labels:
          severity: warnning
        annotations:
          summary: "Kubernetes Node All Pods CPU Usage Rate High"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}} Kubernetes Node All Pods CPU Usage Rate above 70%/5m (current value: {{ $value }})"
      - alert: KubernetesAllPodsMemoryUsageAlert
        expr: sum by (instance,job) (container_memory_working_set_bytes{image!="",name=~"^k8s_.*"}) / sum by (instance,job) (machine_memory_bytes) * 100 > 70
        for: 5m
        labels:
          severity: warnning
        annotations:
          summary: "Kubernetes Node All Pods Memory Usage Rate High"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}} Kubernetes Node All Pods Memory Usage Rate above 70%/5m (current value: {{ $value }})"
      - alert: KubernetesAllPodsNetworkSendAlert
        expr: sum by(instance,job) (irate(container_network_transmit_bytes_total[5m])) /1024 /1024 > 50
        for: 5m
        labels:
          severity: warnning
        annotations:
          summary: "Kubernetes Node All Pods Network Send Rate High"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}} Kubernetes Node All Pods Network Send Rate above 50M/5m (current value: {{ $value }})"  
      - alert: KubernetesAllPodsNetworkReceivedAlert
        expr: sum by(instance,job) (irate(container_network_receive_bytes_total[5m])) /1024 /1024 > 50
        for: 5m
        labels:
          severity: warnning
        annotations:
          summary: "Kubernetes Node All Pods Network Received Rate High"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}} Kubernetes Node All Pods Network Received Rate above 50M/5m (current value: {{ $value }})"  		  
      - alert: KubernetesSinglePodsCPUUsageAlert
        expr: sum by(instance,job,namespace,pod) (irate(container_cpu_usage_seconds_total{image!="",name=~"^k8s_.*"}[5m])) * 1000 > 1000 
        for: 5m
        labels:
          severity: warnning
        annotations:
          summary: "Kubernetes Node Single Pods CPU Usage Rate High"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}}, namespace: {{$labels.namespace}}, pod: {{$labels.pod}} Kubernetes Node Single Pods CPU Usage Rate above 1000m(1000m=1core)/5m (current value: {{ $value }})"
      - alert: KubernetesSinglePodsMemoryUsageAlert
        expr: sum by(instance,job,namespace,pod) (container_memory_working_set_bytes{image!="",name=~"^k8s_.*"}) /1024 /1024 > 1024
        for: 5m
        labels:
          severity: warnning
        annotations:
          summary: "Kubernetes Node Single Pods Memory Usage Rate High"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}}, namespace: {{$labels.namespace}}, pod: {{$labels.pod}} Kubernetes Node Single Pods Memory Usage Rate above 1G/5m (current value: {{ $value }})"		  
      - alert: KubernetesSinglePodsNetworkSenddAlert
        expr: sum by(instance,job,namespace,pod) (irate(container_network_transmit_bytes_total{image!="",name=~"^k8s_.*"}[5m])) /1024 /1024 > 20
        for: 5m
        labels:
          severity: warnning
        annotations:
          summary: "Kubernetes Node Single Pods Network Send Rate High"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}}, namespace: {{$labels.namespace}}, pod: {{$labels.pod}} Kubernetes Node Single Pods Network Send Rate above 20M/5m (current value: {{ $value }})"			  
      - alert: KubernetesSinglePodsNetworkReceivedAlert
        expr: sum by(instance,job,namespace,pod) (irate(container_network_receive_bytes_total{image!="",name=~"^k8s_.*"}[5m])) /1024 /1024 > 20
        for: 5m
        labels:
          severity: warnning
        annotations:
          summary: "Kubernetes Node Single Pods Network Received Rate High"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}}, namespace: {{$labels.namespace}}, pod: {{$labels.pod}} Kubernetes Node Single Pods Network Received Rate above 20M/5m (current value: {{ $value }})"	
  apiserver_rules.yml: |         #custom apiserver rules
    groups:
    - name: KubernetesAPIServerAlert
      rules:
      - alert: KubernetesAPIServerDown		
        expr: up{instance=~".*:6443"} == 0
        for: 15s
        labels:
          severity: High
        annotations:
          summary: "Kubernetes APIServer Down"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}} Kubernetes APIServer is Down, time keep 15s (current value: {{ $value }})"  	  
      - alert: KubernetesAPIServerRestfulCommandAlert		
        expr: sum(rate(apiserver_request_total[5m])) by (verb)  > 100 
        for: 5m
        labels:
          severity: warnning
        annotations:
          summary: "Kubernetes APIServer Restful Command Many"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}} Kubernetes APIServer Restful Command above 100/5m (current value: {{ $value }})"     
      - alert: KubernetesAPIServerWorkQueueAlert		
        expr: histogram_quantile(0.90, sum(rate(workqueue_queue_duration_seconds_bucket[5m])) by (le)) > 0.01
        for: 5m
        labels:
          severity: warnning
        annotations:
          summary: "Kubernetes APIServer Work Queue Wait Time Long"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}} Kubernetes APIServer Work Queue Wait Time Long, P90 value above 10ms/5m (current value: {{ $value }})" 
      - alert: KubernetesAPIServerWorkQueueAlert		
        expr: histogram_quantile(0.90, sum(rate(workqueue_work_duration_seconds_bucket[5m])) by (le)) > 0.01
        for: 5m
        labels:
          severity: warnning
        annotations:
          summary: "Kubernetes APIServer Work Queue Processing Time Long"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}} Kubernetes APIServer Work Queue Processing Time Long, P90 value above 10ms/5m (current value: {{ $value }})"    		  
      - alert: KubernetesAPIServerRequestLatencyAlert		
        expr: histogram_quantile(0.90, sum(rate(apiserver_request_duration_seconds_bucket{verb!~"CONNECT|WATCH"}[5m])) by (le,job,instance)) > 0.5 
        for: 5m
        labels:
          severity: warnning
        annotations:
          summary: "Kubernetes APIServer Request Latency High"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}} Kubernetes APIServer Request Latency High, P90 value above 500ms/5m (current value: {{ $value }})"  
      - alert: KubernetesAPIServerRequestLatencyAlert		
        expr: histogram_quantile(0.90, sum(rate(etcd_request_duration_seconds_bucket[5m])) by (le,job,instance)) > 0.05 
        for: 5m
        labels:
          severity: warnning
        annotations:
          summary: "Kubernetes Etcd Request Latency High"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}} Kubernetes APIServer Request Latency High, P90 value above 50ms/5m (current value: {{ $value }})" 
  node-exporter_rules.yml: |    #custom node_exporter rules
    groups:
    - name: KubernetesHostStatusAlert
      rules:
      - alert: KubernetesNodeDown
        expr: up{job=~"kubernetes-nodes"} == 0
        for: 15s
        labels:
          severity: High
        annotations:
          summary: "Kubernetes Node is Down"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}} is Down,Server Machine can shutdown,time keep 15s(current value: {{ $value }})"
      - alert: KubernetesHostCpuUsageAlert
        expr: sum by(job,instance) (avg without(cpu) (irate(node_cpu_seconds_total{job="kubernetes-service-endpoints",mode!="idle"}[5m]))) * 100 > 85
        for: 5m
        labels:
          severity: High
        annotations:
          summary: "Host CPU[5m] usage High"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}} CPU Usage above 85%/5m (current value: {{ $value }})"
      - alert: KubernetesHostCpuUsage100%Alert
        expr: sum by(job,instance) (avg without(cpu) (irate(node_cpu_seconds_total{job="kubernetes-service-endpoints",mode!="idle"}[5m]))) * 100 >= 99
        for: 5m
        labels:
          severity: High
        annotations:
          summary: "Host CPU[5m] usage High"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}} CPU Usage above equal 99%/5m (current value: {{ $value }})"
      - alert: KubernetesHostMemUsageAlert
        expr: (1 - ((node_memory_Buffers_bytes{job="kubernetes-service-endpoints"}+ node_memory_Cached_bytes{job="kubernetes-service-endpoints"} + node_memory_MemFree_bytes{job="kubernetes-service-endpoints"}) /node_memory_MemTotal_bytes{job="kubernetes-service-endpoints"})) * 100 > 85
        for: 5m
        labels:
          severity: High
        annotations:
          summary: "Host Memory usage High"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}} Memory Usage above 85% (current value: {{ $value }})"
      - alert: KubernetesHostMemUsage100%Alert
        expr: (1 - ((node_memory_Buffers_bytes{job="kubernetes-service-endpoints"}+ node_memory_Cached_bytes{job="kubernetes-service-endpoints"} + node_memory_MemFree_bytes{job="kubernetes-service-endpoints"}) /node_memory_MemTotal_bytes{job="kubernetes-service-endpoints"})) * 100 >= 99
        for: 5m
        labels:
          severity: High
        annotations:
          summary: "Host Memory usage High"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}} Memory Usage above equal 99% (current value: {{ $value }})"
      - alert: KubernetesHostDiskUsageCapacityAlert
        expr: (100-(node_filesystem_free_bytes{fstype=~"ext4|xfs",job="kubernetes-service-endpoints"}/node_filesystem_size_bytes {fstype=~"ext4|xfs",job="kubernetes-service-endpoints"}*100)) > 90
        for: 5m
        labels:
          severity: warnning
        annotations:
          summary: "Host Disk Usage Capacity High"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}} Host Disk Capacity Usage above 90% (path: {{ $labels.mountpoint }},value: {{ $value }})"
      - alert: KubernetesHostDiskAvailableCapacityAlert
        expr: node_filesystem_free_bytes{fstype=~"ext4|xfs",mountpoint!="/boot",job="kubernetes-service-endpoints"} / 1024 /1024 /1024 < 1
        for: 1m
        labels:
          severity: High
        annotations:
          summary: "Host Disk Available Capacity Low"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}} Host Disk Available Capacity under 1G (path: {{ $labels.mountpoint }},value: {{ $value }})"
      - alert: KubernetesHostDiskReadRateAlert
        expr: irate(node_disk_read_bytes_total{job="kubernetes-service-endpoints"}[5m]) /1024 /1024 > 60
        for: 5m
        labels:
          severity: warnning
        annotations:
          summary: "Host Disk Read Rate High"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}} Disk Read Rate above 60M/5m (device: {{ $labels.device }},value: {{ $value }})"
      - alert: KubernetesHostDiskWriteRateAlert
        expr: irate(node_disk_written_bytes_total{job="kubernetes-service-endpoints"}[5m]) /1024 /1024 > 60
        for: 5m
        labels:
          severity: warnning
        annotations:
          summary: "Host Disk Write Rate High"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}} Disk Write Rate above 60M/5m (device: {{ $labels.device }},value: {{ $value }})"
      - alert: KubernetesHostDiskIOPSReadRateAlert
        expr: topk(1,irate(node_disk_reads_completed_total{job="kubernetes-service-endpoints"}[5m])) > 1500
        for: 5m
        labels:
          severity: warnning
        annotations:
          summary: "Host Disk[5m] IOPS Read Rate High"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}} Disk Read IOPS Rate above 1500/5m (device: {{ $labels.device }},value: {{ $value }})"
      - alert: KubernetesHostDiskIOPSWriteRateAlert
        expr: topk(1,irate(node_disk_writes_completed_total{job="kubernetes-service-endpoints"}[5m])) > 1500
        for: 5m
        labels:
          severity: warnning
        annotations:
          summary: "Host Disk[5m] IOPS Write Rate High"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}} Disk Write IOPS Rate above 1500/5m (device: {{ $labels.device }},value: {{ $value }})"
      - alert: KubernetesHostNetworkReceiveAlert
        expr: irate(node_network_receive_bytes_total{device!~"tap.*|veth.*|br.*|docker.*|virbr*|lo*",job="kubernetes-service-endpoints"}[5m]) * 8 / 1024 / 1024 > 80
        for: 5m
        labels:
          severity: warnning
        annotations:
          summary: "Host Network[5m] Receive Rate High"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}} Network Download rate above 80Mbps/5m (current value: {{ $value }})"		  
      - alert: KubernetesHostNetworkSendAlert
        expr: irate(node_network_transmit_bytes_total{device!~"tap.*|veth.*|br.*|docker.*|virbr*|lo*",job="kubernetes-service-endpoints"}[5m]) * 8 / 1024 / 1024 > 80
        for: 5m
        labels:
          severity: warnning
        annotations:
          summary: "Host Network[5m] Send Rate High"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}} Network Send rate above 80Mbps/5m (current value: {{ $value }})" 
      - alert: KubernetesHostNetworkEstablishedConnectionAlert
        expr: node_netstat_Tcp_CurrEstab  > 1500
        for: 5m
        labels:
          severity: warnning
        annotations:
          summary: "Host Network[5m] Established Connection High"
          description: "job: {{ $labels.job }}, instance: {{$labels.instance}} Network Established Connection above 1500 (current value: {{ $value }})"  

# alertmanager告警定义
1. [root@LocalServer ~]# kubectl edit cm/prom-prometheus-alertmanager -n monitoring
data:
  alertmanager.yml: |
    global:
      resolve_timeout: 5m
      smtp_require_tls: false
      smtp_smarthost: 'smtp.qiye.163.com:465'
      smtp_hello: 'alertmanager'
      smtp_from: 'alert@hom.com'
      smtp_auth_username: 'alert@hom.com'
      smtp_auth_password: 'alert@46!@#'
    templates:
      - '/etc/config/email.tmpl'
    route:
      receiver: 'email'
      group_by: ['alertname']
      group_wait: 15s
      group_interval: 15s
      repeat_interval: 4h
      routes:
      - receiver: 'email'
        group_wait: 10s
        continue: true
        match_re:
          job: .*[a-z].*
      - receiver: 'webhook'
        group_wait: 10s
        continue: true
        match_re:
          job: .*[a-z].*
    receivers:
    - name: 'email'
      email_configs:
      - to: '{{ template "email.to" . }}'
        html: '{{ template "email.html" . }}'
        send_resolved: true
    - name: 'webhook'
      webhook_configs:
      - url: 'http://192.168.13.235:8060/dingtalk/webhook1/send'
        send_resolved: true
    inhibit_rules:
    - source_match_re:
        alertname: .*Down.*
      target_match_re:
        job: .*blackbox.*
      equal: 
      - ops   
---------------------邮件模板-------------------
  email.tmpl: |
    {{ define "email.from" }}jack.li@homsom.com{{ end }}
    {{ define "email.to" }}jack.li@homsom.com{{ end }}
    {{ define "email.html" }}
    {{ range .Alerts }}
     <pre>
    状态：{{   .Status }}
    实例: {{ .Labels.instance }}
    信息: {{ .Annotations.summary }}
    详情: {{ .Annotations.description }}
    时间: {{ (.StartsAt.Add 28800e9).Format "2006-01-02 15:04:05" }}
     </pre>
    {{ end }}
    {{ end }}
-------------------
```



### 1.22 IngressController for Ingress规则

**Canary**
在某些情况下，您可能希望通过向与生产服务不同的服务发送少量请求来“金丝雀”一组新的更改。金丝雀注解使 Ingress 规范能够根据应用的规则充当路由请求的替代服务。nginx.ingress.kubernetes.io/canary: "true"设置后可以启用以下用于配置金丝雀的注释：

nginx.ingress.kubernetes.io/canary-by-header：用于通知 Ingress 将请求路由到 Canary Ingress 中指定的服务的标头。当请求头设置为 时always，它将被路由到金丝雀。当标头设置为 时never，它永远不会被路由到金丝雀。对于任何其他值，标头将被忽略，并按优先级将请求与其他金丝雀规则进行比较。

nginx.ingress.kubernetes.io/canary-by-header-value：要匹配的标头值，用于通知 Ingress 将请求路由到 Canary Ingress 中指定的服务。当请求头设置为这个值时，它将被路由到金丝雀。对于任何其他标头值，标头将被忽略，并按优先级将请求与其他金丝雀规则进行比较。此注释必须与 一起使用。注释是 的扩展，nginx.ingress.kubernetes.io/canary-by-header允许自定义标头值而不是使用硬编码值。如果nginx.ingress.kubernetes.io/canary-by-header未定义注释，则没有任何影响。

nginx.ingress.kubernetes.io/canary-by-header-pattern：这与canary-by-header-valuePCRE 正则表达式匹配的工作方式相同。请注意，canary-by-header-value设置此注释时将被忽略。当给定的 Regex 在请求处理过程中导致错误时，该请求将被视为不匹配。

nginx.ingress.kubernetes.io/canary-by-cookie：用于通知 Ingress 将请求路由到 Canary Ingress 中指定的服务的 cookie。当 cookie 值设置为 时always，它将被路由到金丝雀。当 cookie 设置为 时never，它永远不会被路由到金丝雀。对于任何其他值，cookie 将被忽略，并按优先级将请求与其他金丝雀规则进行比较。

nginx.ingress.kubernetes.io/canary-weight：应路由到 Canary Ingress 中指定的服务的基于整数 (0 - 100) 的随机请求百分比。权重为 0 意味着此金丝雀规则不会向 Canary 入口中的服务发送任何请求。权重为 100 意味着所有请求都将发送到 Ingress 中指定的替代服务。

Canary 规则按优先顺序进行评估。优先级如下：canary-by-header -> canary-by-cookie -> canary-weight

请注意： 当您将入口标记为 Canary 时，除nginx.ingress.kubernetes.io/load-balance and nginx.ingress.kubernetes.io/upstream-hash-by之外的所有其他非 Canary 注释都将被忽略（从相应的主入口继承）
已知限制： 目前，每个 Ingress 规则最多可以应用一个 Canary Ingress。

**Rewrite**

Rewrite Target

在某些情况下，后端服务中暴露的 URL 与 Ingress 规则中指定的路径不同。如果没有重写，任何请求都将返回 404。将注释设置nginx.ingress.kubernetes.io/rewrite-target为服务预期的路径。
创建带有重写注释的 Ingress 规则：
```bash
$ echo '
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
  name: rewrite
  namespace: default
spec:
  rules:
  - host: rewrite.bar.com
    http:
      paths:
      - backend:
          serviceName: http-svc
          servicePort: 80
        path: /something(/|$)(.*)
          ' | kubectl create -f -
          在这个入口定义中，捕获的任何字符(.*)都将分配给占位符$2，然后将其用作rewrite-target注释中的参数。例如，上面的入口定义将导致以下重写：
          rewrite.bar.com/something 改写为 rewrite.bar.com/
          rewrite.bar.com/something/ 改写为 rewrite.bar.com/
          rewrite.bar.com/something/new 改写为 rewrite.bar.com/new
          注：此目的是将重定向的URL路径/something去掉，多余的URL参数将重写到后端的service中，例如：rewrite.bar.com/something/test  -->  rewrite.bar.com/test

# 创建带有 app-root 注释的 Ingress 规则：
$ echo "
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/app-root: /app1
  name: approot
  namespace: default
spec:
  rules:
  - host: approot.bar.com
    http:
      paths:
      - backend:
          serviceName: http-svc
          servicePort: 80
        path: /
          " | kubectl create -f -
          检查重写是否有效
          $ curl -I -k http://approot.bar.com/
          HTTP/1.1 302 Moved Temporarily
          Server: nginx/1.11.10
          Date: Mon, 13 Mar 2017 14:57:15 GMT
          Content-Type: text/html
          Content-Length: 162
          Location: http://stickyingress.example.com/app1
          Connection: keep-alive
          注：此目的是将URL路径/app1作为根加入到访问的url路径中，前提访问的URL需要匹配到ingress路径，例如：approot.bar.com/  -->  approot.bar.com/app1

# 简写ingress规则 ，使用&符号进行变量设置，用*号引用变量
spec:
  rules:
  - host: alertmanager.k8s.hs.com
    http: &http_rules
      paths:
      - backend:
          serviceName: prom-prometheus-alertmanager
          servicePort: 80
        path: /
        pathType: ImplementationSpecific
  - host: alert.k8s.hs.com
    http: *http_rules
    注：当ingress(ingress-nginx)使用canary时,其它ingress再引用canary ingress所在的service时，将不会起作用，而引用base ingress所在的service时会起作用,并且canary ingress的weight权重值将影响其它ingress的引用，例如当weight=100，则引用base ingress所在的service不会生效。当weight=0，则引用base ingress所在的service会生效。

# 基本认证
此示例说明如何使用身份验证htpasswd在 Ingress 规则中添加。重要的是生成的文件被命名auth（实际上 - 秘密有一个密钥data.auth），否则入口控制器返回 503。
htpasswd -c auth foo
kubectl create secret generic basic-auth --from-file=auth
kubectl get secret basic-auth -o yaml
curl -v http://10.2.29.4/ -H 'Host: foo.bar.com' -u 'foo:bar'

# 客户端证书认证
如果它们是二进制 DER 格式，您可以按如下方式转换它们：
openssl x509 -in certificate.der -inform der -out certificate.crt -outform pem
然后，您可以将它们全部连接到一个名为“ca.crt”的文件中，如下所示：
cat certificate1.crt certificate2.crt certificate3.crt >> ca.crt
注意：对于生成的每个证书，请确保密钥大小大于 1024 并且哈希算法（摘要）比 md5 更好。否则，您将收到错误消息。

# 使用位于的外部服务（基本身份验证） https://httpbin.org
$ kubectl get ing external-auth -o yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/auth-url: https://httpbin.org/basic-auth/user/passwd
  name: external-auth
  namespace: default
spec:
  rules:
  - host: external-auth-01.sample.com
    http:
      paths:
      - backend:
          serviceName: http-svc
          servicePort: 80
        path: /

# 向 Nginx 配置添加了一个自定义标头，该标头仅适用于该特定 Ingress
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: nginx-configuration-snippet
  annotations:
    nginx.ingress.kubernetes.io/configuration-snippet: |
      more_set_headers "Request-Id: $req_id";
spec:
  rules:
  - host: custom.configuration.com
    http:
      paths:
      - backend:
          serviceName: http-svc
          servicePort: 80
        path: /
          --测试：使用以下命令检查 nginx.conf 文件中是否存在注释的内容： kubectl exec ingress-nginx-controller-873061567-4n3k2 -n kube-system -- cat /etc/nginx/nginx.conf

# 自定义配置
使用ConfigMap可以自定义 NGINX 配置，例如，如果我们想更改超时，我们需要创建一个 ConfigMap：
$ cat configmap.yaml
apiVersion: v1
data:
  proxy-connect-timeout: "10"
  proxy-read-timeout: "120"
  proxy-send-timeout: "120"
kind: ConfigMap
metadata:
  name: ingress-nginx-controller
--如果 Configmap 更新，NGINX 将使用新配置重新加载。

# 自定义错误
1. 首先，创建自定义default-backend. 稍后将被 Ingress 控制器使用。
$ kubectl create -f custom-default-backend.yaml
service "nginx-errors" created
deployment.apps "nginx-errors" created
2. 入口控制器配置
编辑ingress-nginx-controller deployment 并将--default-backend-service标志的值设置为新创建的错误后端的名称,例如：
- --default-backend-service=fat/hsapp-errorpage
  编辑ingress-nginx-controllerConfigMap 并创建custom-http-errors值为的键404,503
  data: 
  custom-http-errors: '404,503'
```