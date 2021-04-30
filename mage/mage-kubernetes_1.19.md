kubernetes v1.19.0
<pre>
截至目前，kubeadm可以支持在ubuntu 16.04+,debian 9+, centos7与rhel7,fedora 25+,hypriotOS v1.0.1和Container Linux系统上
构建kubernetes集群 
部署的基础环境要求：每个独立的主机应有2GB以上的内存及2个以上的CPU核心，有唯一的主机名、MAC、产品标识，禁用了SWAP且
各主机彼止间具有完整意义上的网络连通性。

kubenetes集群高可用：
1. 一般来说，高可用控制平面至少3个master节点来承受最多1个master节点的丢失，才能保证处于等待状态的master节点保持半数以上，以满足节点选举时的法定票数。
2. apiserver利用etcd进行数据在你，它自身是无状态应用，支持多副本同时工作，多副本间能无差别地服务客户端请求。
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

kubernetes集群可部署为3种运行模式：
1. 独立组件模式（master各组件和node各组件直接以守护进程方式运行于节点之上，以二进制程序部署的集群隶属于此种类型）
2. 静态pod模式（控制平面的各组件以静态pod对象形式运行在master主机之上，而node主机上的kubelet和docker运行为系统级守护进程，kube-proxy托管于集群上的daemonset控制器，
kubeadm部署的就是此种类型。）
3. 自托管模式，类似于静态pod模式，开启时可使用：kubeadm init --features-gates=selfHosting选项激活（类似于第二种模式，但控制平面的各组件运行pod对象{非静态}，并且这些pod
同样托管运行在集群之上，且同样受控于daemonset类型的控制器，类似kube-proxy）

kubernetes集群主机环境：
192.168.13.50	tengine					reverse	
192.168.13.51	master01.k8s.hs.com  k8s-api.k8s.hs.com		master	XEN02  ok
192.168.13.52	master02.k8s.hs.com				master	ESXI01  ok
192.168.13.53	master03.k8s.hs.com				master	XEN08  ok
192.168.13.56	node01.k8s.hs.com				node	XEN01  ok
192.168.13.57	node02.k8s.hs.com				node	XEN06  ok

docker version: 20.10.5
kubernetes version: v1.19
kubeadm version: 1.18.8-0 

1.1 在DNS Server中配置k8s主机记录
k8s-api.k8s.hs.com --> 192.168.13.50
1.2 tengine 配置四层代理
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


2. salt-ssh deploy key
--salt-master:
sudo rpm --import https://repo.saltproject.io/py3/redhat/7/x86_64/3002/SALTSTACK-GPG-KEY.pub
curl -fsSL https://repo.saltproject.io/py3/redhat/7/x86_64/3002.repo | sudo tee /etc/yum.repos.d/salt.repo
--salt-minion:
[root@salt ~/salt]# salt-ssh 'node*' -r 'curl http://mirrors.aliyun.com/repo/Centos-7.repo | tee /etc/yum.repos.d/Centos-7.repo'
[root@salt ~/salt]# salt-ssh 'node*' -r 'yum install -y python3'
[root@salt ~/salt]# salt-ssh '*' -i --key-deploy test.ping
[root@salt /srv/salt/base/init]# salt-ssh '*' state.sls init.init-for-saltssh saltenv=base

3. salt deploy base env and install docker
[root@salt /srv/salt/base]# salt '*k8s*' state.highstate
[root@salt /srv/salt/base]# salt '*k8s*' cmd.run 'docker version | grep Version'
master02.k8s.hs.com:
     Version:           20.10.5

4. install k8s for kubelet kubeadm kubectl
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

5. remote to minion console. Example:
[root@salt /srv/salt/base]# ssh -i /etc/salt/pki/master/ssh/salt-ssh.rsa 192.168.13.51

6. 初始化控制平面
[root@master01 ~]# kubeadm  init \
> --image-repository registry.aliyuncs.com/google_containers \
> --kubernetes-version v1.19.0 \
> --control-plane-endpoint k8s-api.k8s.hs.com \
> --apiserver-advertise-address 192.168.13.51 \
> --pod-network-cidr 10.244.0.0/16 \
> --token-ttl 0
# kubeadm  init --image-repository registry.aliyuncs.com/google_containers --kubernetes-version v1.19.0 --control-plane-endpoint k8s-api.k8s.hs.com --apiserver-advertise-address 192.168.13.51 --pod-network-cidr 10.244.0.0/16 --token-ttl 0

#初始化环境配置
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
[root@master01 k8s]# kubectl get nodes
NAME                  STATUS     ROLES    AGE   VERSION
master01.k8s.hs.com   NotReady   master   62s   v1.19.0

#部署网络组件
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

# 工作节点加入集群 
[root@node01 ~]# kubeadm join k8s-api.k8s.hs.com:6443 --token fi0e8y.luxmfi3knk0x151d \
>     --discovery-token-ca-cert-hash sha256:31851ba359ffec9d50fb3576908e37a69f5df60fcae6910304527b8438435387 
[root@node02 ~]# kubeadm join k8s-api.k8s.hs.com:6443 --token fi0e8y.luxmfi3knk0x151d \
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

#高可用控制平面
这里部署的是堆叠式etcd拓扑（另外是外部etcd拓扑，适合于中大型k8s集群），适合于中小型集群。
高可用控制平面节点的拓扑中，我们需要为无状态的API Server实例配置外部的高可用负载均衡器，这些负载均衡器
的VIP将作为各个客户端（包括kube-scheduler和kube-controller-manager组件）访问API Server时使用的目标地址，
但是，kubedm init初始化第一个控制平面节点时默认会将各大组件的kubeconfig配置文件及admin.conf中的集群访问
入口定义为该节点的IP地址，且随后加入的各节点的TLS Bootstrap也会配置kubelet的kubeconfig使用该地址作为集群
访问入口，这将不利于后期高可用控制平面的配置。
解决办法是为kubedm init命令使用--control-plane-endpoint选项，指定API Server的访问端口为专用的DNS名称，
并将其临时解析到第一个控制平面节点的IP地址，等扩展控制平面完成且配置好负载均衡后，再将该DNS名称解析至
负载均衡器，以接收访问API Server的VIP。

#增加两个控制平面节点
1. 同一高可用控制平面集群中的各节点需要共享CA和front-proxy的数字证书和密钥，
以及专用的ServiceAccount帐户的公钥和私钥，我们可以采用手动或者自动方式，这里
采用自动的方式，因而首先需要在k8s-master01节点上运行如下命令上传证书及密钥数据：
[root@master01 ~]# kubeadm init phase upload-certs --upload-certs   --此命令可以多次执行
I0411 19:24:28.467881   23419 version.go:252] remote version is much newer: v1.21.0; falling back to: stable-1.19
W0411 19:24:29.109595   23419 configset.go:348] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
[upload-certs] Storing the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
[upload-certs] Using certificate key:
b33d9f79a32d1762aca0a16af0852ba07e75bd157418b2ed60d970c1c86c13bc

而后，在新的两个控制平面节点使用kubeadm join --control-plane 命令加入为master节点:
----master02:
#[root@master02 ~]# kubeadm join k8s-api.k8s.hs.com:6443 --token fi0e8y.luxmfi3knk0x151d     --discovery-token-ca-cert-hash sha256:31851ba359ffec9d50fb3576908e37a69f5df60fcae6910304527b8438435387     --control-plane     --certificate-key b33d9f79a32d1762aca0a16af0852ba07e75bd157418b2ed60d970c1c86c13bc
[root@master02 ~]# kubeadm join k8s-api.k8s.hs.com:6443 --token fi0e8y.luxmfi3knk0x151d \
>     --discovery-token-ca-cert-hash sha256:31851ba359ffec9d50fb3576908e37a69f5df60fcae6910304527b8438435387 \
>     --control-plane \
>     --certificate-key b33d9f79a32d1762aca0a16af0852ba07e75bd157418b2ed60d970c1c86c13bc
注：--certificate-key是自动上传数字证书和密钥、以及专用的ServiceAccount帐户的公钥和私钥产生的key，拿着
这个key就可以加入控制平台了。
[root@master02 ~]# mkdir -p $HOME/.kube
[root@master02 ~]# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
[root@master02 ~]# sudo chown $(id -u):$(id -g) $HOME/.kube/config
[root@master02 ~]# kubectl get nodes 
NAME                  STATUS   ROLES    AGE    VERSION
master01.k8s.hs.com   Ready    master   107m   v1.19.0
master02.k8s.hs.com   Ready    master   40s    v1.19.0
node01.k8s.hs.com     Ready    <none>   98m    v1.19.0
node02.k8s.hs.com     Ready    <none>   97m    v1.19.0
----master03:
[root@master03 ~]# kubeadm join k8s-api.k8s.hs.com:6443 --token fi0e8y.luxmfi3knk0x151d \
>     --discovery-token-ca-cert-hash sha256:31851ba359ffec9d50fb3576908e37a69f5df60fcae6910304527b8438435387 \
>     --control-plane \
>     --certificate-key b33d9f79a32d1762aca0a16af0852ba07e75bd157418b2ed60d970c1c86c13bc
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
--部署完成后，获取集群状态时会出现这个，这时需要到每个master中将/etc/kubernetes/manifests/kube-controller-manager.yaml和/etc/kubernetes/manifests/kube-scheduler.yaml两个文件
的端口--port=0注释掉，然后重启kubelet 服务（其实改完保存后自己会重建，此步骤需要一个一个来，不能并行来）即可：
[root@master02 ~]# kubectl get cs 
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS      MESSAGE                                                                                       ERROR
scheduler            Unhealthy   Get "http://127.0.0.1:10251/healthz": dial tcp 127.0.0.1:10251: connect: connection refused   
controller-manager   Unhealthy   Get "http://127.0.0.1:10252/healthz": dial tcp 127.0.0.1:10252: connect: connection refused   
etcd-0               Healthy     {"health":"true"}                  
[root@master02 ~]# vim /etc/kubernetes/manifests/kube-controller-manager.yaml
#    - --port=0
[root@master02 ~]# kubectl get cs
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS    MESSAGE             ERROR
scheduler            Healthy   ok                  
controller-manager   Healthy   ok                  
etcd-0               Healthy   {"health":"true"}   

#etcd集群相关知识
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
由于出现网络故障，124 成为一个分区，35 成为一个分区， Node 5 的 leader 任期还没结束的一段时间内，仍然认为自己是当前leader，但是此时另外一边的分区，因为124无法连接 5，于是选出了新的leader 1，网络分区形成。
35分区是否可用？如果写入了1而读取了 5，是否会读取旧数据(stale read)?
答：35分区属于少数派，被认为是异常节点，无法执行写操作。写入 1 的可以成功，并在网络分区恢复后，35 因为任期旧，会自动成为 follower，异常期间的新数据也会从 1 同步给 35。
而 5 的读请求也会失败，etcd 通过ReadIndex、Lease read保证线性一致读，即节点5在处理读请求时，首先需要与集群多数节点确认自己依然是Leader并查询 commit index，5做不到多数节点确认，因此读失败。
因此 etcd 不存在脑裂问题。
5. etcd快照备份和查看
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
6. learner 角色
learner 是 etcd 3.4 版本中增加的新角色，类似于 zookeeper 的 observer, 不参与 raft 投票选举。通过这个新角色的引入，降低了加入新节点时给老集群的额外压力，增强了集群的稳定性。除此之外还可以使用它作为集群的热备或服务一些读请求。
举例，如果 etcd集群需要加入一个新节点，新加入的 etcd 成员因为没有任何数据，因此需要从 leader 那里同步数据，直到赶上领导者的日志为止。这样就会导致 leader 的网络过载，导致 leader 和 member 之间的心跳可能阻塞。然后就开始了新的leader选举，也就是说，具有新成员的集群更容易受到领导人选举的影响。领导者的选举以及随后向新成员的更新都容易导致一段时间的群集不可用，这种是不符合预期，风险也是很大的。
因此为了解决这个问题，raft 4.2.1 论文中介绍了一种新的节点角色：Learner。加入集群的节点不参与投票选举，只接收 leader 的 replication message，直到与 leader 保持同步为止。



#监控
为避免重蹈hepster的覆辙，资源指标API和自定义指标API，他们作为聚合API集成到kubernetes集群中。
heapster用于提供核心指标API的功能也被采用聚合方式的指标API服务器metrics server所取代。

#新一代监控体系与指标系统
我们知道，kubernetes通过API Aggregator（聚合器）为开发人员提供了轻松扩展API资源的能力，为集群添加
指标数据API的自定义指标API、资源指标API（简称为指标API）和外部指标API都属于这种类型的扩展。
总结起来：新一代的kubernetes监控系统架构主要同核心指标流水线和监控指标流水线共同组成。


----核心指标与metrics server
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
注：kubelet通常是在Bootstrap过程中生成自签证书，这类证书无法由Metrics server完成CA验证，因此需要
使用--kubelet-insecure-tls选项来禁用这验证功能。另外 ，节点的DNS域（hs.com）与kubernetes集群使用
的DNS域（cluster.local）不相同，则coreDNS通常无法解析各节点的主机名称，这类问题有两种，方案一是
使用--kubelet-preferred-address-types=InternalIP来使用内部IP来与各节点通信。另外一种是为CoreDNS
添加类似hosts解析的资源记录。推荐方案一。
-----由于国内无法访问google镜像站，所以需要提前下载
[root@node02 ~]# docker pull bitnami/metrics-server:0.3.7
[root@node02 ~]# docker tag bitnami/metrics-server:0.3.7 k8s.gcr.io/metrics-server/metrics-server:v0.3.7
[root@master01 ~/k8s/manifests/addons/monitor/metrics-server/3.7]# kubectl apply -f metrics-server-deploy.yaml 
[----测试metrics server是否收集到指标，如果收集到指标则表示metrics server工作正常了
root@master01 ~/k8s/manifests]# yum install -y jq
[root@master01 ~/k8s/manifests]# kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes" | jq
{
  "kind": "NodeMetricsList",
  "apiVersion": "metrics.k8s.io/v1beta1",
  "metadata": {
    "selfLink": "/apis/metrics.k8s.io/v1beta1/nodes"
  }
.........
[root@master01 ~/k8s/manifests]# kubectl top nodes
NAME                  CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
master01.k8s.hs.com   1006m        25%    1606Mi          20%       
master02.k8s.hs.com   76m          1%     1502Mi          40%       
master03.k8s.hs.com   297m         7%     1456Mi          39%       
node01.k8s.hs.com     85m          2%     937Mi           25%       
node02.k8s.hs.com     89m          2%     942Mi           29%   
注：另外，kubernetes dashboard能够根据核心指标生成节点及相关pod资源的使用情况。

----自定义指标与prometheus
promQL --> k8s-prometheus-adapter -->custom-metrics.k8s.io <-- client get



#存储
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



#service、endpoint、容器探针
1. 当创建service和pod时，service会通过标签选择器关联后端pod，其实在创建service时service还会创建跟自己同名的endpoint(端点)，
此端点用于选择后端pod，从而完成service跟pod的关联。
2. 容器探针：有存活性探测和就绪性控制，当pod未就绪时则会移到subnets.notReadyaddresses字段中，如果就绪则在subnets.addresses字段。
3. endpoint可以自定义，而调用这类endpoint对象的同名service对象无须再使用标签选择器即可完成与pod的关联。
4. 自定义endpoint常将那些不是由编排程序编排的应用定义为Kubernetes系统的service对象，从而让客户端像访问集群上的pod应用一样请求
外部服务。


#iptables和ipvs
单个service对象的iptables数量与后端端点(pod)的数量正相关，对于拥有较多service对象和大规模pod对象的kubernetes集群，每个节点的内核上将充斥着大量的iptables规则。
service对象的变动会导致所有节点刷新netfilter上的iptables规则，而且每次的service请求也都将经历多次的规则匹配检测和处理过程，这会占用节点上相当比例的系统资源。因此，
iptables代理模型不适用于service和pod数量较多的集群。ipvs代理模型通过将流量匹配和分发功能配置为少量ipvs规则，有效降低了对系统资源的占用，从而是能够承载更大规模
的kubernetes集群。
1. 调整kube-proxy代理模型：
可直接使用kubetctl edit configmaps/kube-proxy -n kube-system命令编辑该configmap对象设置代理模型为ipvs:
mode: "ipvs"
注：配置完成后，以灰度模式手动逐个或分批次删除kube-system名称空间下的kube-proxy旧版本的pod，等待新pod运行起来便切换到了ipvs代理模型。用于生产环境时，应在
部署kubernetes集群时直接待定要使用的代理模型，或在集群部署完成生立即调整代理模型，而后再部署其他应用。



#服务发现
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
spec.dnsPolicy: Default, ClusterFirst, ClusterFirstWithHostNet, None
spec.dnsConfig: nameservers, searches, options   --这些选项都附加在dnsPolicy配置之后
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
注：pod的/etc/resolve.conf中dns服务器手搜索域都会变为指定的信息。
5. externalName Service: 只要在service中定义externalName：redis.ik8s.io类似字段信息，则集群中的pod通过coreDNS解析service名称的地址信息为redis.ik8s.io，然后解析最终IP
6. Headless Service: 只要在service中定义clusterIP: None即可定义无头service，当pod请求service名称时，coreDNS直接解析到后端的podIP，而不是clusterIP，从而避免iptables规则匹配。
增加速度。


#准入控制器
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



#k8s master节点移除和添加
#预先准备：
打印加入集群命令：
[root@master02 ~/manifests/addons/network]# kubeadm token create --print-join-command
W0430 09:26:33.276319   14024 configset.go:348] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
kubeadm join k8s-api.k8s.hs.com:6443 --token poz5y3.206amiyzawdzlueo     --discovery-token-ca-cert-hash sha256:437e89e657eca27c9d0311c4f76d7dd3f9d3fe9de7eb10016d626ac1133dd5bb 
[root@master02 ~/manifests/addons/network]# kubeadm init phase upload-certs --upload-certs
I0430 09:26:42.090495   14118 version.go:252] remote version is much newer: v1.21.0; falling back to: stable-1.19
W0430 09:26:43.442826   14118 configset.go:348] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
[upload-certs] Storing the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
[upload-certs] Using certificate key:
be1fd45e9911967deef4cdbf35ee5a16671df886956270fd9a26591e190648ea
因为加入集群为master命令组合为：
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
查看etcd状态：
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
重置集群节点:master01.k8s.hs.com:
kubeadm reset 
--------------
etcd命令：
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
--------------
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
----master01.k8s.hs.com模拟故障，此时已经关机，etcd状态如下：
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

----配置tengine，移除192.168.13.51:6443，然后获取节点状态
[root@master03 /etc/kubernetes/manifests]# kubectl get nodes -o wide 
NAME                  STATUS     ROLES    AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION          CONTAINER-RUNTIME
master01.k8s.hs.com   NotReady   master   43m   v1.19.0   192.168.13.51   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.6
master02.k8s.hs.com   Ready      master   40m   v1.19.0   192.168.13.52   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
master03.k8s.hs.com   Ready      master   38m   v1.19.0   192.168.13.53   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
node01.k8s.hs.com     Ready      <none>   36m   v1.19.0   192.168.13.56   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
node02.k8s.hs.com     Ready      <none>   36m   v1.19.0   192.168.13.57   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
----移除节点：
--驱逐节点master01.k8s.hs.com上的pod，并且忽略本地的daemonset控制器：
[root@master02 ~]# kubectl drain master01.k8s.hs.com --delete-local-data --ignore-daemonsets --force   --一直卡住，使用ctrl+c结束
----期间遇到小插曲，node上flannel接口存在，始终报cni接口已经存在，不能创建，需要在相关node上进行删除相关接口，等待集群重建：
-----------
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
-----------

[root@master02 /etc/kubernetes/manifests]# kubectl get nodes -o wide
NAME                  STATUS                        ROLES    AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION          CONTAINER-RUNTIME
master01.k8s.hs.com   NotReady,SchedulingDisabled   master   46m   v1.19.0   192.168.13.51   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.6
master02.k8s.hs.com   Ready                         master   43m   v1.19.0   192.168.13.52   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
master03.k8s.hs.com   Ready                         master   41m   v1.19.0   192.168.13.53   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
node01.k8s.hs.com     Ready                         <none>   39m   v1.19.0   192.168.13.56   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
node02.k8s.hs.com     Ready                         <none>   39m   v1.19.0   192.168.13.57   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
[root@master02 ~]# kubectl delete nodes master01.k8s.hs.com    --删除此节点
node "master01.k8s.hs.com" deleted
[root@master02 ~]# kubectl get pods -n kube-system -o wide  --查看时始终还在master01.k8s.hs.com，过一会自动删除已经删除节点的相关信息Pod
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

--因为模拟节点故障，所以要删除etcd中的master01.k8s.hs.com信息：
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

在新节点上配置环境和安装命令行工具：
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
在新节点上加入到现有集群：
kubeadm join k8s-api.k8s.hs.com:6443 --token poz5y3.206amiyzawdzlueo     --discovery-token-ca-cert-hash sha256:437e89e657eca27c9d0311c4f76d7dd3f9d3fe9de7eb10016d626ac1133dd5bb  --control-plane --certificate-key be1fd45e9911967deef4cdbf35ee5a16671df886956270fd9a26591e190648ea
[root@master01 ~]# mkdir -p $HOME/.kube
[root@master01 ~]# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
[root@master01 ~]# sudo chown $(id -u):$(id -g) $HOME/.kube/config
--加入集群成功，查看集群状态信息
[root@master01 ~]# kubectl get nodes -o wide 
NAME                  STATUS   ROLES    AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION          CONTAINER-RUNTIME
master01.k8s.hs.com   Ready    master   38s   v1.19.0   192.168.13.51   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.6
master02.k8s.hs.com   Ready    master   13h   v1.19.0   192.168.13.52   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
master03.k8s.hs.com   Ready    master   13h   v1.19.0   192.168.13.53   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
node01.k8s.hs.com     Ready    <none>   13h   v1.19.0   192.168.13.56   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
node02.k8s.hs.com     Ready    <none>   13h   v1.19.0   192.168.13.57   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://20.10.5
--最后把192.168.13.51:6443加入到k8s-api-.k8s.hs.com后端服务端点


#维护节点
[root@master02 ~]# kubectl cordon master01.k8s.hs.com  --将节点master01.k8s.hs.com置为不可调度
node/master01.k8s.hs.com cordoned
[root@master01 ~]# kubectl drain master01.k8s.hs.com --ignore-daemonsets   --驱逐节点上的pod到别的节点运行
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
[root@master01 ~]# kubectl uncordon master01.k8s.hs.com      --恢复集群为可调度
node/master01.k8s.hs.com uncordoned
[root@master01 ~]# kubectl get nodes 
NAME                  STATUS   ROLES    AGE   VERSION
master01.k8s.hs.com   Ready    master   74m   v1.19.0
master02.k8s.hs.com   Ready    master   15h   v1.19.0
master03.k8s.hs.com   Ready    master   15h   v1.19.0
node01.k8s.hs.com     Ready    <none>   15h   v1.19.0
node02.k8s.hs.com     Ready    <none>   15h   v1.19.0
--查看scheduler的leader在哪个master上
[root@master01 ~]# kubectl get endpoints kube-scheduler -n kube-system -o yaml | grep holderIdentity
    control-plane.alpha.kubernetes.io/leader: '{"holderIdentity":"master02.k8s.hs.com_5dbd75ef-b62e-47ea-9b78-631d7fde8645","leaseDurationSeconds":15,"acquireTime":"2021-04-29T16:23:27Z","renewTime":"2021-04-30T05:52:44Z","leaderTransitions":5}'
--查看ontroller-manager的leader在哪个master上
[root@master01 ~]# kubectl get endpoints kube-controller-manager -n kube-system -o yaml | grep holderIdentity
    control-plane.alpha.kubernetes.io/leader: '{"holderIdentity":"master03.k8s.hs.com_575ffaa6-ff7b-48a4-896b-014d2ab8c730","leaseDurationSeconds":15,"acquireTime":"2021-04-29T16:23:27Z","renewTime":"2021-04-30T05:52:54Z","leaderTransitions":4}'
--apiserver端口是6443，
使用kubectl命令时会去请求master，所以不能返回时代理apiserver是故障的。apiserver是无状态的。
--查看etcd集群状态 
[root@master01 ~]#  docker exec -it $(docker ps -f name=etcd_etcd -q) etcdctl --endpoints "https://192.168.13.51:2379,https://192.168.13.52:2379,https://192.168.13.53:2379"  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key endpoint status --write-out="table"
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|          ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://192.168.13.51:2379 | 6b31542d4962986f |   3.4.9 |  4.2 MB |     false |      false |         9 |     186012 |             186012 |        |
| https://192.168.13.52:2379 |  8715488046f0887 |   3.4.9 |  4.2 MB |      true |      false |         9 |     186012 |             186012 |        |
| https://192.168.13.53:2379 | 676ef70c3ee42b24 |   3.4.9 |  4.1 MB |     false |      false |         9 |     186012 |             186012 |        |
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
--查看集群状态
[root@master02 ~]# kubectl get cs 
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS    MESSAGE             ERROR
scheduler            Healthy   ok                  
controller-manager   Healthy   ok                  
etcd-0               Healthy   {"health":"true"}   


----集群升级：
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


#kubernetes v1.19.0证书更新
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
---
--自kubernentes v1.15以后，可以使用官方命令续订证书，每次续订将会是一年，命令如下：
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
---
也可使用此链接更新master端的证书，node端的kubelet证书会自动更新，不用手动更新。
URL: https://github.com/jacknotes/update-kube-cert
该脚本用于处理已过期或者即将过期的kubernetes集群证书
kubeadm生成的证书有效期为为1年，该脚本可将kubeadm生成的证书有效期更新为10年
该脚本只处理master节点上的证书：kubeadm默认配置了kubelet证书自动更新，node节点kubelet.conf所指向的证书会自动更新
小于v1.17版本的master初始化节点(执行kubeadm init的节点) kubelet.conf里的证书并不会自动更新，这算是一个bug，该脚本会一并处理更新master节点的kubelet.conf所包含的证书
---


#实操升级集群
基于kubeadm部署的k8s集群从kubernetes v1.19.0升级到kubernetes v1.19.1，升级工作的基本流程如下：
升级主控制平面节点
升级其他控制平面节点
升级工作节点
--查看当前集群状态：
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
结果：
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
[root@master02 ~]# kubectl get pods -o wide -w   --在驱逐工作节点时我在另外的控制平面所查看到的。并且我的curl命令nginx服务也未断开，说明服务是可用的
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
[root@master03 ~]# kubectl get nodes -o wide   --此时在控制平面上查看节点信息时，虽说还未被恢复为调度，但是控制平面从kubelete中获取信息node01已经升级为v1.19.10
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
--最后步骤将/etc/kubernetes/manifests中的kube-controller-manager.yaml和kube-scheduler.yaml 中的-- port=0 注释掉：
[root@master03 /etc/kubernetes/manifests]# vim kube-controller-manager.yaml 
[root@master03 /etc/kubernetes/manifests]# vim kube-scheduler.yaml 

集群升级工作原理：
kubeadm upgrade apply 做了以下工作：
检查你的集群是否处于可升级状态:
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

</pre>