#mage-kubernetes 1.21

<pre>

###kubernetes高可用集群的典型架构
#控制面组件：
etcd：多实例并行运行，通过Raft保证一致；
apiserver：多实例并行运行；
controller-manager：多实例仅有1个节点active；
scheduler：多实例仅有1个节点active；
#工作节点组件：
kubelet
kube-proxy

1. apiserver多实例运行: apiserver是无状态的，所有数据保存在etcd中，apiserver不做缓存。apiserver多个实例并行运行，通过Loadbalancer负载均衡用户的请求。
2. scheuler和controller-manager单实例运行: scheduler和controller-manager会修改集群状态，多实例运行会产生竞争状态。通过--leader-elect机制，只有领导者实例才能运行，其它实例处于standby状态；当领导者实例宕机时，剩余的实例选举产生新的领导者。领导者选举的方法：多个实例抢占创建endpoints资源，创建成功者为领导者。比如多个scheduler实例，抢占创建子endpoints资源：kube-scheduler
# kubectl get endpoints kube-scheduler -n kube-system -oyaml
apiVersion: v1
kind: Endpoints
metadata:
  annotations:
    control-plane.alpha.kubernetes.io/leader: '{"holderIdentity":"master1_293eaef2-fd7e-4ae9-aae7-e78615454881","leaseDurationSeconds":15,"acquireTime":"2021-10-06T20:46:43Z","renewTime":"2021-10-19T02:49:21Z","leaderTransitions":165}'
  creationTimestamp: "2021-02-01T03:10:48Z"
......
查询kube-scheduler资源，可以看到此时master1上的scheduler是active状态，其它实例则为standby。
3. kubelet和kube-proxy在工作节点上运行
3.1 kubelet负责：
向apiserver创建一个node资源，以注册该节点；
持续监控apiserver，若有pod部署到该节点上，创建并启动pod；
持续监控运行的pod，向apiserver报告pod的状态、事件和资源消耗；
周期性的运行容器的livenessProbe，当探针失败时，则重启容器；
持续监控apiserver，若有pod删除，则终止该容器；
3.2 kube-proxy负责：
负责确保对服务ip和port的访问最终能到达pod中，通过节点上的iptables/ipvs来实现；
#控制平台组件开启和关闭实验结果：
3个kube-apiserver关掉2个，只保留1个，可以正常接收kubectl命令操作、
3个kube-scheduler和kube-controller-manager关掉2个节点，只保留1个节点可以正常操作
只保留1个kube-controller-manager，而kube-scheduler3个节点全部关闭，在创建deployment和service时候，任务会被创建成功，但是pod会被一直pending，因为pod没有调度器调试，此时开启一个kube-scheduler后，pending状态的pod正常运行。
只保留1个kube-scheduler，而kube-controller-manager3个节点全部关闭，在创建deployment和service时候，任务不会被创建成功，因为kube-controller-manager没有运行，无法使用deployment控制器创建pod，虽然kube-scheduler运行，但是控制器没有运行，后面的调度任务也就不会被运行。



#k8s生产集群部署：
kubernetes-master: 3个
etcd: 3个
harbor: 2个高可用
haproxy: 2个高可用
node: 最少3个

生产环境节点配置：
node: 48C 256G ssd/2T 10g/25g网卡 物理机
master: 16c 16G ssd/200G 物理机或虚拟机
etcd: 8c 16G ssd/150g

#测试环境配置：
172.168.2.11	ansible
172.168.2.21	kubernetes-master01		etcd01
172.168.2.22	kubernetes-master02		etcd02
172.168.2.23	kubernetes-master03		etcd03
192.168.13.197	harbor
192.168.13.50	nginx
172.168.2.24	node01
172.168.2.25	node02
172.168.2.26	node03
OS: ubuntu18
DeployMethod: Binary Install
注：etcd是镜像集群，任意etcd节点进行备份，任意etcd节点进行恢复即可。
DeployUrl: https://github.com/easzlab/kubeasz

#ubuntu20.04.3时区调整为24小时制
# ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/locltime
# cat /etc/default/locale
LANG=en_US.UTF-8
LC_TIME=en_DK.UTF-8

#habor使用自签名证书实现https
openssl genrsa -out harbor-ca.key
openssl req -x509 -new -nodes -key harbor-ca.key -subj "/CN=harbor.magedu.net" -days 7120 -out harbor-ca.crt
#docker信任自签名证书
mkdir -p /etc/docker/certs.d/harbor.magedu.net
scp 192.168.13.197:~/certs/harbor-ca.crt /etc/docker/certs.d/harbor.magedu.net/
systemctl restart docker 
docker login harbor.magedu.net

#haproxy tcp监控VIP地址及端口时需要更改的内核参数
net.ipv4.ip_nonlocal_bind = 1


#k8s二进制生产集群部署
1. cobbler安装ubuntu18.04.5并安装新版本ansible
root@ansible:~# apt install -y python3-pip
root@ansible:~# pip3 install ansible -i https://mirrors.aliyun.com/pypi/simple/
或者旧版本ansible也可以使用

2. ansible加入k8s节点进行管控，用ssh免密登录
root@ansible:~/ansible# cat ssh-cp.sh
-----------------
#!/bin/bash
#Destination Host Ip
IP="
172.168.2.21
172.168.2.22
172.168.2.23
172.168.2.24
172.168.2.25
172.168.2.26
"
for node in ${IP};do
        sshpass -p 123456 ssh-copy-id ${node} -o StrictHostKeyChecking=no
        if [ $? -eq 0 ];then
                echo "${node} secret copy successful."
        else
                echo "${node} secret copy failed."
        fi
done
-----------------
root@ansible:~/ansible# apt install -y sshpass
root@ansible:~/ansible# ./ssh-cp.sh


3. 测试ansible是否能管理k8s节点
root@ansible:~/ansible# ansible k8s -m ping
172.168.2.22 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
172.168.2.25 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
172.168.2.21 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
172.168.2.24 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
172.168.2.26 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
172.168.2.23 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}

4. 在k8s节点部署安装，使用kubeasz方式部署
DocumentUrl: https://github.com/easzlab/kubeasz/blob/master/docs/setup/00-planning_and_overall_intro.md
kubeasz3.1.0支持k8s的版本：	v1.21.0, v1.20.6, v.1.19.10, v1.18.18

4.1 下载需要的包
root@ansible:~# export release=3.1.0
root@ansible:~# wget https://github.com/easzlab/kubeasz/releases/download/${release}/ezdown
root@ansible:~# chmod +x ./ezdown
root@ansible:~# grep -E 'DOCKER_VER=|K8S_BIN_VER=' ezdown	--查看docker版本和k8s版本，这两个变量最重要
DOCKER_VER=19.03.15
K8S_BIN_VER=v1.21.0		--先装1.21.0，后续升级1.21.4
root@ansible:~# ./ezdown -D
--上述脚本运行成功后，所有文件（kubeasz代码、二进制、离线镜像）均已整理好放入目录/etc/kubeasz
root@ansible:~# docker  image ls
REPOSITORY                                    TAG                 IMAGE ID            CREATED             SIZE
easzlab/kubeasz                               3.1.0               57ebbb3aeaec        10 months ago       164MB
easzlab/kubeasz-ext-bin                       0.9.4               9428d8629ce2        10 months ago       398MB
easzlab/kubeasz-k8s-bin                       v1.21.0             a23b83929702        10 months ago       499MB
easzlab/nfs-subdir-external-provisioner       v4.0.1              686d3731280a        11 months ago       43.8MB
kubernetesui/dashboard                        v2.2.0              5c4ee6ca42ce        12 months ago       225MB
easzlab/k8s-dns-node-cache                    1.17.0              3a187183b3a8        13 months ago       123MB
easzlab/pause-amd64                           3.4.1               0f8457a4c2ec        13 months ago       683kB
coredns/coredns                               1.8.0               296a6d5035e2        16 months ago       42.5MB
kubernetesui/metrics-scraper                  v1.0.6              48d79e554db6        16 months ago       34.5MB
easzlab/flannel                               v0.13.0-amd64       e708f4bb69e3        16 months ago       57.2MB
calico/node                                   v3.15.3             d45bf977dfbf        18 months ago       262MB
calico/pod2daemon-flexvol                     v3.15.3             963564fb95ed        18 months ago       22.8MB
calico/cni                                    v3.15.3             ca5564c06ea0        18 months ago       110MB
calico/kube-controllers                       v3.15.3             0cb2976cbb7d        18 months ago       52.9MB
mirrorgooglecontainers/metrics-server-amd64   v0.3.6              9dd718864ce6        2 years ago         39.9MB

root@ansible:~# ls -l /etc/kubeasz/
total 84
-rw-rw-r--  1 root root 20304 Apr 26  2021 ansible.cfg
drwxr-xr-x  3 root root  4096 Mar  4 16:49 bin
drwxrwxr-x  8 root root    92 Apr 26  2021 docs
drwxr-xr-x  3 root root  4096 Mar  4 18:04 down
drwxrwxr-x  2 root root    70 Apr 26  2021 example
-rwxrwxr-x  1 root root 24629 Apr 26  2021 ezctl
-rwxrwxr-x  1 root root 15075 Apr 26  2021 ezdown
drwxrwxr-x 10 root root   145 Apr 26  2021 manifests
drwxrwxr-x  2 root root   322 Apr 26  2021 pics
drwxrwxr-x  2 root root  4096 Apr 26  2021 playbooks
-rw-rw-r--  1 root root  5953 Apr 26  2021 README.md
drwxrwxr-x 22 root root   323 Apr 26  2021 roles
drwxrwxr-x  2 root root    48 Apr 26  2021 tools
root@ansible:~# ls -l /etc/kubeasz/bin/		--好多k8s相关的执行文件
total 863524
-rwxr-xr-x 1 root root   4665324 Aug 27  2020 bridge
-rw-r--r-- 1 root root  40783872 Apr 12  2021 calicoctl
-rw-r--r-- 1 root root  10376657 Apr 12  2021 cfssl
-rw-r--r-- 1 root root   6595195 Apr 12  2021 cfssl-certinfo
-rw-r--r-- 1 root root   2277873 Apr 12  2021 cfssljson
-rwxr-xr-x 1 root root   1046424 Apr 12  2021 chronyd
-rwxr-xr-x 1 root root  36789288 Mar  4 17:50 containerd
drwxr-xr-x 2 root root       146 Apr 12  2021 containerd-bin
-rwxr-xr-x 1 root root   7172096 Mar  4 17:50 containerd-shim
-rwxr-xr-x 1 root root  19161064 Mar  4 17:50 ctr
-rwxr-xr-x 1 root root  61133792 Mar  4 17:50 docker
-rw-r--r-- 1 root root  11748168 Apr 12  2021 docker-compose
-rwxr-xr-x 1 root root  71555008 Mar  4 17:50 dockerd
-rwxr-xr-x 1 root root    708616 Mar  4 17:50 docker-init
-rwxr-xr-x 1 root root   2928566 Mar  4 17:50 docker-proxy
-rwxr-xr-x 1 root root  23847904 Aug 25  2020 etcd
-rwxr-xr-x 1 root root  17620576 Aug 25  2020 etcdctl
-rwxr-xr-x 1 root root   3439780 Aug 27  2020 flannel
-rwxr-xr-x 1 root root  41603072 Dec  9  2020 helm
-rwxr-xr-x 1 root root   3745368 Aug 27  2020 host-local
-rwxr-xr-x 1 root root   1305408 Apr 12  2021 keepalived
-rwxr-xr-x 1 root root 122064896 Apr  9  2021 kube-apiserver
-rwxr-xr-x 1 root root 116281344 Apr  9  2021 kube-controller-manager
-rwxr-xr-x 1 root root  46436352 Apr  9  2021 kubectl
-rwxr-xr-x 1 root root 118062928 Apr  9  2021 kubelet
-rwxr-xr-x 1 root root  43130880 Apr  9  2021 kube-proxy
-rwxr-xr-x 1 root root  47104000 Apr  9  2021 kube-scheduler
-rwxr-xr-x 1 root root   3566204 Aug 27  2020 loopback
-rwxr-xr-x 1 root root   1777808 Apr 12  2021 nginx
-rwxr-xr-x 1 root root   3979034 Aug 27  2020 portmap
-rwxr-xr-x 1 root root   9600824 Mar  4 17:50 runc
-rwxr-xr-x 1 root root   3695403 Aug 27  2020 tuning

4.2 创建集群配置实例
root@ansible:/etc/kubeasz# ./ezctl --help
Usage: ezctl COMMAND [args]
-------------------------------------------------------------------------------------
Cluster setups:
    list                             to list all of the managed clusters
    checkout    <cluster>            to switch default kubeconfig of the cluster
    new         <cluster>            to start a new k8s deploy with name 'cluster'
    setup       <cluster>  <step>    to setup a cluster, also supporting a step-by-step way
    start       <cluster>            to start all of the k8s services stopped by 'ezctl stop'
    stop        <cluster>            to stop all of the k8s services temporarily
    upgrade     <cluster>            to upgrade the k8s cluster
    destroy     <cluster>            to destroy the k8s cluster
    backup      <cluster>            to backup the cluster state (etcd snapshot)
    restore     <cluster>            to restore the cluster state from backups
    start-aio                        to quickly setup an all-in-one cluster with 'default' settings

Cluster ops:
    add-etcd    <cluster>  <ip>      to add a etcd-node to the etcd cluster
    add-master  <cluster>  <ip>      to add a master node to the k8s cluster
    add-node    <cluster>  <ip>      to add a work node to the k8s cluster
    del-etcd    <cluster>  <ip>      to delete a etcd-node from the etcd cluster
    del-master  <cluster>  <ip>      to delete a master node from the k8s cluster
    del-node    <cluster>  <ip>      to delete a work node from the k8s cluster

Extra operation:
    kcfg-adm    <cluster>  <args>    to manage client kubeconfig of the k8s cluster

Use "ezctl help <command>" for more information about a given command.
-------------
root@ansible:/etc/kubeasz# ls example/
config.yml  hosts.allinone  hosts.multi-node
root@ansible:/etc/kubeasz# ./ezctl new k8s-01	--创建k8s集群名称，可以创建管理多个k8s集群
2022-03-04 18:39:08 DEBUG generate custom cluster files in /etc/kubeasz/clusters/k8s-01
2022-03-04 18:39:08 DEBUG set version of common plugins
2022-03-04 18:39:08 DEBUG cluster k8s-01: files successfully created.
2022-03-04 18:39:08 INFO next steps 1: to config '/etc/kubeasz/clusters/k8s-01/hosts'
2022-03-04 18:39:08 INFO next steps 2: to config '/etc/kubeasz/clusters/k8s-01/config.yml'
然后根据提示配置'/etc/kubeasz/clusters/k8s-01/hosts' 和 '/etc/kubeasz/clusters/k8s-01/config.yml'：根据前面节点规划修改hosts 文件和其他集群层面的主要配置选项；其他集群组件等配置项可以在config.yml 文件中修改。
root@ansible:/etc/kubeasz# cd /etc/kubeasz/clusters/k8s-01/
root@ansible:/etc/kubeasz/clusters/k8s-01# ls
config.yml  hosts

4.2.1 编辑配置hosts
root@ansible:/etc/kubeasz/clusters/k8s-01# grep -Ev '#|^$' hosts
-------------
[etcd]
172.168.2.21
172.168.2.22
172.168.2.23
[kube_master]
172.168.2.21
172.168.2.22
[kube_node]
172.168.2.24
172.168.2.25
[harbor]
[ex_lb]
[chrony]
[all:vars]
SECURE_PORT="6443"
CONTAINER_RUNTIME="docker"
CLUSTER_NETWORK="calico"		--使用的网络插件，公有云一般使用flannel或公有云特定网络组件。私有云使用calico，因为calico需要支持BGP协议，需要学习路由的，但是公有云一般没有。
PROXY_MODE="ipvs"
SERVICE_CIDR="10.68.0.0/16"
CLUSTER_CIDR="172.20.0.0/16"
NODE_PORT_RANGE="30000-65000"
CLUSTER_DNS_DOMAIN="homsom.local"	--集群后缀
bin_dir="/usr/local/bin"		--二进制存放路径
base_dir="/etc/kubeasz"
cluster_dir="{{ base_dir }}/clusters/k8s-01"
ca_dir="/etc/kubernetes/ssl"
-------------

4.2.2 编辑配置config.yml
root@ansible:/etc/kubeasz/clusters/k8s-01# vim config.yml
# default: ca will expire in 100 years
# default: certs issued by the ca will expire in 50 years
CA_EXPIRY: "876000h"
CERT_EXPIRY: "438000h"
# 设置不同的wal目录，可以避免磁盘io竞争，提高性能
ETCD_DATA_DIR: "/var/lib/etcd"
# [containerd]容器持久化存储目录
CONTAINERD_STORAGE_DIR: "/var/lib/containerd"
# [docker]信任的HTTP仓库
INSECURE_REG: '["127.0.0.1/8","192.168.13.235:8000","192.168.13.197:8000"]'
# node节点最大pod 数
MAX_PODS: 300
# role:network [flannel,calico,cilium,kube-ovn,kube-router]，我们选择的是calico，所以配置calico就可以了
# ----calico
# [calico]设置 CALICO_IPV4POOL_IPIP=“off”,可以提高网络性能，条件限制详见 docs/setup/calico.md，为Always开启跨子网，为了以后网络扩展可以打开
CALICO_IPV4POOL_IPIP: "Always"
# role:cluster-addon	所有插件不自动安装，后面手动安装
# coredns 自动安装
dns_install: "no"
ENABLE_LOCAL_DNS_CACHE: false	#测试关闭DNS缓存，生产开启。由于这里是测试，部署过一次k8s没关缓存，所以后面会关掉缓存再重新部署k8s集群
# metric server 自动安装
metricsserver_install: "no"
# dashboard 自动安装
dashboard_install: "no"
# ingress 自动安装
ingress_install: "no"
# prometheus 自动安装
prom_install: "no"
# nfs-provisioner 自动安装
nfs_provisioner_install: "no"
####注：其它默认即可
-------------

4.2.3 安装k8s环境，ansible会读取hosts和config.yml进行配置
root@ansible:/etc/kubeasz# ./ezctl setup k8s-01 01	--环境准备
PLAY RECAP *****************************************************************************************************************************************************************************
172.168.2.21               : ok=25   changed=20   unreachable=0    failed=0
172.168.2.22               : ok=25   changed=20   unreachable=0    failed=0
172.168.2.23               : ok=21   changed=16   unreachable=0    failed=0
172.168.2.24               : ok=24   changed=19   unreachable=0    failed=0
172.168.2.25               : ok=24   changed=19   unreachable=0    failed=0
localhost                  : ok=36   changed=34   unreachable=0    failed=0
注：当第一步成功了，意味着你的环境没有问题，--如果报错可更改vim playbooks/01.prepare.yml路过某些步骤

4.2.4 安装etcd
root@ansible:/etc/kubeasz# ./ezctl setup k8s-01 02	--安装etcd
PLAY RECAP *****************************************************************************************************************************************************************************
172.168.2.21               : ok=10   changed=9    unreachable=0    failed=0
172.168.2.22               : ok=10   changed=8    unreachable=0    failed=0
172.168.2.23               : ok=10   changed=8    unreachable=0    failed=0
--验证etcd是否正常
root@k8s-master01:~# export NODE_IPS="172.168.2.21 172.168.2.22 172.168.2.23"
root@k8s-master01:~# for ip in ${NODE_IPS};do ETCDCTL_API=3 /usr/local/bin/etcdctl --endpoints=https://${ip}:2379 --cacert=/etc/kubernetes/ssl/ca.pem --cert=/etc/kubernetes/ssl/etcd.pem --key=/etc/kubernetes/ssl/etcd-key.pem endpoint health;done
https://172.168.2.21:2379 is healthy: successfully committed proposal: took = 9.579469ms		--当显示successfully表示正常
https://172.168.2.22:2379 is healthy: successfully committed proposal: took = 10.896213ms
https://172.168.2.23:2379 is healthy: successfully committed proposal: took = 10.735953ms

4.2.5 部署docker
4.2.5.1 配置docker信任自签名证书步骤：	--如果未使用自签名证书，此步骤可省略
ssh ${node} 'mkdir -p /etc/docker/certs.d/harbor.magedu.net'
scp 192.168.13.197:~/certs/harbor-ca.crt ${node}:/etc/docker/certs.d/harbor.magedu.net/
scp 192.168.13.197:~/.docker ${node}:/root/

4.2.5.2 安装运行时docker
root@ansible:/etc/kubeasz# ./ezctl setup k8s-01 03	--安装运行时
PLAY RECAP ***************************************************************************************************************************************************
172.168.2.21               : ok=18   changed=14   unreachable=0    failed=0
172.168.2.22               : ok=15   changed=13   unreachable=0    failed=0
172.168.2.24               : ok=15   changed=13   unreachable=0    failed=0
172.168.2.25               : ok=15   changed=13   unreachable=0    failed=0

4.2.6 安装master
root@ansible:/etc/kubeasz# ./ezctl setup k8s-01 04	--安装master
PLAY RECAP *****************************************************************************************************************************************************************************
172.168.2.21               : ok=62   changed=56   unreachable=0    failed=0
172.168.2.22               : ok=58   changed=52   unreachable=0    failed=0
root@k8s-master01:~# kubectl get nodes	--能执行kubectl命令说明master部署成功了
NAME           STATUS                     ROLES    AGE   VERSION
172.168.2.21   Ready,SchedulingDisabled   master   36m   v1.21.0
172.168.2.22   Ready,SchedulingDisabled   master   36m   v1.21.0
注：
-----etcd、kube-apiserver、kubelet此3个服务都有自己的一套证书，并且信任同一个CA，其中etcd启动服务时使用自己的一套证书配置启动。其中kubelet启动服务时也使用自己的一套证书配置启动。kube-apiserver除了也使用自己的一套证书配置启动外，还在服务配置了访问etcd的证书、私钥，kubelet的证书、私钥，kube-apiserver配置访问etcd和kubelet的证书私钥是跟kube-apiserver一样的证书私钥文件。当kube-apiserver访问etcd或者kubelet时使用自己的私钥加密，并将自己的公钥发送给etcd或者kubelet，从而etcd或kubetlet可以使用kube-apiserver的公钥解密。反之亦然。
----kube-controller-manager、kube-scheduler、kube-proxy他们的证书和私钥都配置在kubeconfig文件中


4.2.7 安装node
--可以在安装node时调整相关配置，例如kube-proxy ipvs模式，ipvs调度算法等
root@ansible:/etc/kubeasz# vim roles/kube-node/templates/kube-proxy-config.yaml.j2
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
bindAddress: {{ inventory_hostname }}
clientConnection:
  kubeconfig: "/etc/kubernetes/kube-proxy.kubeconfig"
clusterCIDR: "{{ CLUSTER_CIDR }}"
conntrack:
  maxPerCore: 32768
  min: 131072
  tcpCloseWaitTimeout: 1h0m0s
  tcpEstablishedTimeout: 24h0m0s
healthzBindAddress: {{ inventory_hostname }}:10256
hostnameOverride: "{{ inventory_hostname }}"
metricsBindAddress: {{ inventory_hostname }}:10249
mode: "{{ PROXY_MODE }}"	#这个之前配置的模式就是ipvs，自己会传进来更改为ipvs
ipvs:		#增加ipvs调度算法
  scheduler: wrr
-------------
root@ansible:/etc/kubeasz# ./ezctl setup k8s-01 05	--安装node
PLAY RECAP *****************************************************************************************************************************************************************************
172.168.2.24               : ok=41   changed=38   unreachable=0    failed=0
172.168.2.25               : ok=39   changed=37   unreachable=0    failed=0

4.2.8 安装网络
4.2.8.1 这里是安装的calico网络
注：不管是calico还是flannel都要配置地址范围CLUSTER_CIDR，必须跟k8s中配置的地址范围一样，否则一定会跑不起来
root@ansible:/etc/kubeasz# vim roles/calico/templates/calico-v3.15.yaml.j2
            - name: CALICO_IPV4POOL_CIDR
              value: "{{ CLUSTER_CIDR }}"		--这里是传变量来的，所以确定是"172.20.0.0/16"地址范围
  calico_backend: "{{ CALICO_NETWORKING_BACKEND }}"
----------
root@ansible:/etc/kubeasz# grep CLUSTER_CIDR /etc/kubeasz/clusters/k8s-01/ -R
/etc/kubeasz/clusters/k8s-01/hosts:CLUSTER_CIDR="172.20.0.0/16"
root@ansible:/etc/kubeasz# grep CALICO_NETWORKING_BACKEND /etc/kubeasz/clusters/k8s-01/ -R
/etc/kubeasz/clusters/k8s-01/config.yml:CALICO_NETWORKING_BACKEND: "brid"
root@ansible:/etc/kubeasz# ./ezctl setup k8s-01 06	--安装网络
PLAY RECAP *****************************************************************************************************************************************************************************
172.168.2.21               : ok=17   changed=15   unreachable=0    failed=0
172.168.2.22               : ok=12   changed=10   unreachable=0    failed=0
172.168.2.24               : ok=12   changed=10   unreachable=0    failed=0
172.168.2.25               : ok=12   changed=11   unreachable=0    failed=0
root@k8s-master01:~# route -n	--calico会添加好多路由表
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         172.168.2.254   0.0.0.0         UG    0      0        0 eth0
172.17.0.0      0.0.0.0         255.255.0.0     U     0      0        0 docker0
172.20.32.128   0.0.0.0         255.255.255.192 U     0      0        0 *
172.20.58.192   172.168.2.25    255.255.255.192 UG    0      0        0 tunl0
172.20.85.192   172.168.2.24    255.255.255.192 UG    0      0        0 tunl0
172.20.122.128  172.168.2.22    255.255.255.192 UG    0      0        0 tunl0
172.168.2.0     0.0.0.0         255.255.255.0   U     0      0        0 eth0
root@k8s-master01:~# calicoctl node status	--查看节点网络状态,配置上需要去公网下载的镜像，可以先下载然后推送到本地仓库，然后更改配置里面的地址为本地仓库镜像地址
Calico process is running.

IPv4 BGP status
+--------------+-------------------+-------+----------+-------------+
| PEER ADDRESS |     PEER TYPE     | STATE |  SINCE   |    INFO     |
+--------------+-------------------+-------+----------+-------------+
| 172.168.2.22 | node-to-node mesh | up    | 13:11:29 | Established |
| 172.168.2.24 | node-to-node mesh | up    | 13:11:28 | Established |
| 172.168.2.25 | node-to-node mesh | up    | 13:11:27 | Established |
+--------------+-------------------+-------+----------+-------------+

IPv6 BGP status
No IPv6 peers found.
---------
root@k8s-master01:~# kubectl get nodes
NAME           STATUS                     ROLES    AGE   VERSION
172.168.2.21   Ready,SchedulingDisabled   master   62m   v1.21.0
172.168.2.22   Ready,SchedulingDisabled   master   62m   v1.21.0
172.168.2.24   Ready                      node     19m   v1.21.0
172.168.2.25   Ready                      node     19m   v1.21.0

4.2.8.2 测试网络
root@k8s-master01:~# kubectl get pods -A
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-647f956d86-5v6wb   1/1     Running   0          12m
kube-system   calico-node-gfkz6                          1/1     Running   0          12m
kube-system   calico-node-hsf4g                          1/1     Running   0          12m
kube-system   calico-node-xrdhm                          1/1     Running   0          12m
kube-system   calico-node-zjvmz                          1/1     Running   0          12m
root@k8s-master01:~# kubectl run net-test1 --image=192.168.13.197:8000/k8s/alpine sleep 36000
pod/net-test1 created
root@k8s-master01:~# kubectl run net-test2 --image=192.168.13.197:8000/k8s/alpine sleep 36000
pod/net-test2 created
root@k8s-master01:~# kubectl run net-test3 --image=192.168.13.197:8000/k8s/alpine sleep 36000
pod/net-test3 created
root@k8s-master01:~# kubectl get pods -A -o wide
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE   IP              NODE           NOMINATED NODE   READINESS GATES
default       net-test1                                  1/1     Running   0          12s   172.20.58.194   172.168.2.25   <none>           <none>
default       net-test2                                  1/1     Running   0          9s    172.20.58.195   172.168.2.25   <none>           <none>
default       net-test3                                  1/1     Running   0          6s    172.20.85.193   172.168.2.24   <none>           <none>
kube-system   calico-kube-controllers-647f956d86-5v6wb   1/1     Running   0          13m   172.168.2.24    172.168.2.24   <none>           <none>
kube-system   calico-node-gfkz6                          1/1     Running   0          13m   172.168.2.21    172.168.2.21   <none>           <none>
kube-system   calico-node-hsf4g                          1/1     Running   0          13m   172.168.2.25    172.168.2.25   <none>           <none>
kube-system   calico-node-xrdhm                          1/1     Running   0          13m   172.168.2.24    172.168.2.24   <none>           <none>
kube-system   calico-node-zjvmz                          1/1     Running   0          13m   172.168.2.22    172.168.2.22   <none>           <none>
root@k8s-master01:~# kubectl exec -it net-test1 sh
/ # ifconfig
eth0      Link encap:Ethernet  HWaddr 3E:FE:E6:F2:07:64
          inet addr:172.20.58.194  Bcast:0.0.0.0  Mask:255.255.255.255
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
/ # ping 172.20.85.193	--测试跨主机Pod是否通
PING 172.20.85.193 (172.20.85.193): 56 data bytes
64 bytes from 172.20.85.193: seq=0 ttl=62 time=2.431 ms
64 bytes from 172.20.85.193: seq=1 ttl=62 time=0.663 ms
/ # ping 223.6.6.6	--测试外网IP是否通
PING 223.6.6.6 (223.6.6.6): 56 data bytes
64 bytes from 223.6.6.6: seq=0 ttl=114 time=5.657 ms
64 bytes from 223.6.6.6: seq=1 ttl=114 time=6.902 ms
/ # cat /etc/resolv.conf
nameserver 169.254.20.10	--这个地址是开启了DNS缓存，这个我想关掉，只能删除集群再重新部署
search default.svc.homsom.local svc.homsom.local homsom.local hs.com
options ndots:5


###删除k8s集群，非常危险
root@ansible:/etc/kubeasz# ./ezctl destroy k8s-01
TASK [clean : 重启提示 WARNNING] ***********************************************************************************************************************************************************
ok: [172.168.2.21] => {
    "msg": "[重要]: 请重启节点以确保清除系统残留的虚拟网卡、路由信息、iptalbes|ipvs规则等 [IMPORTANT]: please reboot nodes, makesure to clean out net interfaces, routes and iptables/ipvs rules"
}
ok: [172.168.2.22] => {
    "msg": "[重要]: 请重启节点以确保清除系统残留的虚拟网卡、路由信息、iptalbes|ipvs规则等 [IMPORTANT]: please reboot nodes, makesure to clean out net interfaces, routes and iptables/ipvs rules"
}
ok: [172.168.2.24] => {
    "msg": "[重要]: 请重启节点以确保清除系统残留的虚拟网卡、路由信息、iptalbes|ipvs规则等 [IMPORTANT]: please reboot nodes, makesure to clean out net interfaces, routes and iptables/ipvs rules"
}
ok: [172.168.2.25] => {
    "msg": "[重要]: 请重启节点以确保清除系统残留的虚拟网卡、路由信息、iptalbes|ipvs规则等 [IMPORTANT]: please reboot nodes, makesure to clean out net interfaces, routes and iptables/ipvs rules"
}
ok: [172.168.2.23] => {
    "msg": "[重要]: 请重启节点以确保清除系统残留的虚拟网卡、路由信息、iptalbes|ipvs规则等 [IMPORTANT]: please reboot nodes, makesure to clean out net interfaces, routes and iptables/ipvs rules"
}

PLAY RECAP *****************************************************************************************************************************************************************************
172.168.2.21               : ok=19   changed=16   unreachable=0    failed=0
172.168.2.22               : ok=19   changed=16   unreachable=0    failed=0
172.168.2.23               : ok=5    changed=3    unreachable=0    failed=0
172.168.2.24               : ok=15   changed=12   unreachable=0    failed=0
172.168.2.25               : ok=15   changed=12   unreachable=0    failed=0
root@ansible:/etc/kubeasz# ansible k8s -m shell -a 'reboot'	--重启所有k8s节点以确保清除系统残留的虚拟网卡、路由信息、iptalbes|ipvs规则等
root@ansible:/etc/kubeasz# ansible k8s -m shell -a 'uptime'
172.168.2.22 | SUCCESS | rc=0 >>
 21:37:52 up 1 min,  0 users,  load average: 0.77, 0.53, 0.21

172.168.2.21 | SUCCESS | rc=0 >>
 21:37:52 up 1 min,  0 users,  load average: 0.76, 0.52, 0.20

172.168.2.23 | SUCCESS | rc=0 >>
 21:37:52 up 1 min,  0 users,  load average: 0.42, 0.27, 0.10

172.168.2.24 | SUCCESS | rc=0 >>
 21:37:53 up 0 min,  0 users,  load average: 0.27, 0.06, 0.02

172.168.2.25 | SUCCESS | rc=0 >>
 21:37:53 up 0 min,  0 users,  load average: 0.27, 0.06, 0.02

172.168.2.26 | SUCCESS | rc=0 >>
 21:37:53 up 1 min,  0 users,  load average: 0.49, 0.32, 0.12

 
###重新部署k8s集群
root@ansible:/etc/kubeasz# ./ezctl setup k8s-01 01
root@ansible:/etc/kubeasz# ./ezctl setup k8s-01 02
root@ansible:/etc/kubeasz# ./ezctl setup k8s-01 03
root@ansible:/etc/kubeasz# ./ezctl setup k8s-01 04
root@ansible:/etc/kubeasz# ./ezctl setup k8s-01 05
root@ansible:/etc/kubeasz# ./ezctl setup k8s-01 06
注：前面6个步骤是通过ansible来安装的，其它k8s组件通过自己安装 
    01  prepare            to prepare CA/certs & kubeconfig & other system settings
    02  etcd               to setup the etcd cluster
    03  container-runtime  to setup the container runtime(docker or containerd)
    04  kube-master        to setup the master nodes
    05  kube-node          to setup the worker nodes
    06  network      	   to setup the network plugin



/ # cat /etc/resolv.conf
nameserver 10.68.0.2	#此时是内部service地址了
search default.svc.homsom.local svc.homsom.local homsom.local hs.com
options ndots:5

4.3 安装coredns
4.3.1 进入kubernetes官方github上找changelog，
https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.21.md
https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.21.md#downloads-for-v12110
4.3.2 然后下载source code,client,server,node的二进制包
root@ansible:/etc/kubeasz# ansible k8s -m apt -a 'name=curl state=latest'
curl -sSfLO https://dl.k8s.io/v1.21.10/kubernetes.tar.gz
curl -sSfLO https://dl.k8s.io/v1.21.10/kubernetes-client-linux-amd64.tar.gz
curl -sSfLO https://dl.k8s.io/v1.21.10/kubernetes-server-linux-amd64.tar.gz
curl -sSfLO https://dl.k8s.io/v1.21.10/kubernetes-node-linux-amd64.tar.gz
4.3.3 配置coredns
注：coredns是通过apiserver从etcd拿到域名信息进行解析的，是无状态的，可以通过部署多个coredns来达到扩展DNS性能
root@k8s-master01:/usr/local/src# tar xf kubernetes.tar.gz
root@k8s-master01:/usr/local/src# ls
kubernetes  kubernetes.tar.gz
root@k8s-master01:/usr/local/src# cd kubernetes/
root@k8s-master01:/usr/local/src/kubernetes/cluster/addons/dns/coredns# ls
coredns.yaml.base  coredns.yaml.in  coredns.yaml.sed  Makefile  transforms2salt.sed  transforms2sed.sed
root@k8s-master01:/usr/local/src/kubernetes/cluster/addons/dns/coredns# mkdir -p /root/k8s
root@k8s-master01:/usr/local/src/kubernetes/cluster/addons/dns/coredns# cp coredns.yaml.base /root/k8s/coredns.yaml
root@k8s-master01:~/k8s# vim coredns.yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
  labels:
      addonmanager.kubernetes.io/mode: EnsureExists
data:
  Corefile: |
    .:53 {
        errors
        health {
            lameduck 5s
        }
		bind 0.0.0.0
        ready
        kubernetes homsom.local in-addr.arpa ip6.arpa {	#coredns后缀一定要跟cat /etc/kubeasz/clusters/k8s-01/hosts配置一样,CLUSTER_DNS_DOMAIN="homsom.local"	
            fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        forward . 192.168.10.250 {	#转发服务器地址
            max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
---
      containers:
      - name: coredns
        image: 192.168.13.197:8000/k8s/coredns-coredns:1.8.3	#把官网镜像通过代理下载下来，然后tag为本地镜像
        imagePullPolicy: IfNotPresent
        resources:
          limits:
            memory: 128Mi		#coredns内存限制，生产分配3G
          requests:
            cpu: 100m			#cpu生产3核
            memory: 70Mi
---
apiVersion: v1
kind: Service
metadata:
  name: kube-dns
  namespace: kube-system
  annotations:
    prometheus.io/port: "9153"
    prometheus.io/scrape: "true"
  labels:
    k8s-app: kube-dns
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
    kubernetes.io/name: "CoreDNS"
spec:
  type: NodePort		#指定service类型为NodePort
  selector:
    k8s-app: kube-dns
  clusterIP: 10.68.0.2		#此ip地址需要自己填写，一般为service IP(SERVICE_CIDR="10.68.0.0/16")的第二个地址，ansible部署的可以从roles/kube-node中看出+2，可从pod上/etc/resolv.conf文件查看
  ports:
  - name: dns
    port: 53
    protocol: UDP
  - name: dns-tcp
    port: 53
    protocol: TCP
  - name: metrics
    port: 9153
    protocol: TCP
    targetPort: 9153	
    nodePort: 30009		#映射nodePort端口
-----------------
root@k8s-master01:~# docker pull rancher/coredns-coredns:1.8.3
root@k8s-master01:~# docker tag rancher/coredns-coredns:1.8.3 192.168.13.197:8000/k8s/coredns-coredns:1.8.3
root@k8s-master01:~# docker push 192.168.13.197:8000/k8s/coredns-coredns:1.8.3
root@k8s-master01:~# kubectl exec -it net-test1 sh
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
/ # pin www.baidu.com
sh: pin: not found
/ # ping www.baidu.com
PING www.baidu.com (112.80.248.75): 56 data bytes
64 bytes from 112.80.248.75: seq=0 ttl=49 time=13.262 ms	#此时已经成功解析
64 bytes from 112.80.248.75: seq=1 ttl=49 time=12.156 ms
--访问coredns的metrics，可以给prometheus采集数据
http://172.168.2.25:30009/metrics	--任意节点IP加nodePort端口


4.4 安装dashboard
4.4.1 安装dashboard需要看支持k8s什么版本，然后安装对应版本，我们集群是1.21，所以安装V2.3.1
https://github.com/kubernetes/dashboard/releases

4.4.2 下载相应dashboard
root@k8s-master01:~/k8s# curl -sSfLO https://raw.githubusercontent.com/kubernetes/dashboard/v2.3.1/aio/deploy/recommended.yaml
root@k8s-master01:~/k8s# mv recommended.yaml dashboard.yaml
root@k8s-master01:~/k8s# vim dashboard.yaml	--更改为本地镜像仓库镜像
     containers:
        - name: kubernetes-dashboard
          image: 192.168.13.197:8000/k8s/dashboard:v2.3.1
     containers:
        - name: dashboard-metrics-scraper
          image: 192.168.13.197:8000/k8s/metrics-scraper:v1.0.6
kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  type: NodePort		--更改为NodePort类型
  ports:
    - port: 443
      targetPort: 8443
      nodePort: 30002	--节点端口为30002
-----

4.4.3 下载dashboard相关容器并更名推送到本地仓库
root@k8s-master02:~# docker pull kubernetesui/dashboard:v2.3.1
root@k8s-master02:~# docker tag kubernetesui/dashboard:v2.3.1 192.168.13.197:8000/k8s/dashboard:v2.3.1
root@k8s-master02:~# docker push 192.168.13.197:8000/k8s/dashboard:v2.3.1
root@k8s-master02:~# docker pull kubernetesui/metrics-scraper:v1.0.6
root@k8s-master02:~# docker tag kubernetesui/metrics-scraper:v1.0.6 192.168.13.197:8000/k8s/metrics-scraper:v1.0.6
root@k8s-master02:~# docker push 192.168.13.197:8000/k8s/metrics-scraper:v1.0.6

4.4.4 应用安装dashboard
root@k8s-master01:~/k8s# kubectl apply -f dashboard.yaml
root@k8s-master01:~/k8s# kubectl get pods -n kubernetes-dashboard
NAME                                         READY   STATUS    RESTARTS   AGE
dashboard-metrics-scraper-67d4cf4b45-8m2dl   1/1     Running   0          40s
kubernetes-dashboard-7c889c777-cfgw5         1/1     Running   0          40s
root@k8s-master01:~/k8s# kubectl get svc -n kubernetes-dashboard
NAME                        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)         AGE
dashboard-metrics-scraper   ClusterIP   10.68.20.27     <none>        8000/TCP        49s
kubernetes-dashboard        NodePort    10.68.127.217   <none>        443:30002/TCP   50s		--访问节点30002端口
https://172.168.2.21:30002/#/login	--访问web界面dashboard

4.4.5 创建dashboard管理用户
root@ansible:~/k8s# ansible 172.168.2.21 -m copy -a 'src=/root/k8s/admin-user.yml dest=/root/k8s/'
root@k8s-master01:~/k8s# cat admin-user.yml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
-----
root@k8s-master01:~/k8s# kubectl apply -f admin-user.yml
root@k8s-master01:~/k8s# kubectl get secret -A | grep admin
kubernetes-dashboard   admin-user-token-m4dph                           kubernetes.io/service-account-token   3      8s
root@k8s-master01:~/k8s# kubectl describe secret/admin-user-token-m4dph -n kubernetes-dashboard
Name:         admin-user-token-m4dph
Namespace:    kubernetes-dashboard
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: admin-user
              kubernetes.io/service-account.uid: 7e6796c1-8471-4dab-8572-a886bf85d2de

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1350 bytes
namespace:  20 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6ImQ3UV9STlJ4TEpQRS1XWmNHblFmaHJOUmdUaW5jMVJvSERqeE9VajR1LWcifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyLXRva2VuLW00ZHBoIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI3ZTY3OTZjMS04NDcxLTRkYWItODU3Mi1hODg2YmY4NWQyZGUiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZXJuZXRlcy1kYXNoYm9hcmQ6YWRtaW4tdXNlciJ9.vetemWR84jzBdD4akQPvk3gKFNuxMpF4e0THKY3vmQ77wLEOOyxI7KWolTU6qYQAh11t-cTa4H0gtlvvQwA_IBBuYrl6sSDpFrAQhrD9AaAW2mcMb2ocXs70T-okZwTgginIaB4Yhes7psqI1NG9aHDbKDkk1ECg62ou96QKNOKgtXc1lfcpPRJHbP0j8sg3JGvXIsg4F5TAUjPkEu4lNQr8bKrPvTheqqQF2JphoOQObZ9J1AbKpinBrZlSD7QxEVJwCa4Q-T-hLr93Y1epbesJ6blna7MfCyX9y-qqqJ6mtgWoLlNNUhsGIgJ1sWeTDZli5lwU1INATLGkmlYglA

4.4.6 然后用上面获取的token去访问dashboard，就可以通过dashboard进行访问了


4.5 k8s master添加
4.5.1 查看当前k8s集群状态
root@k8s-master01:~/k8s# kubectl get node	--看到只有两个master，现在需要添加一个master
NAME           STATUS                     ROLES    AGE   VERSION
172.168.2.21   Ready,SchedulingDisabled   master   38h   v1.21.0
172.168.2.22   Ready,SchedulingDisabled   master   38h   v1.21.0
172.168.2.24   Ready                      node     38h   v1.21.0
172.168.2.25   Ready                      node     38h   v1.21.0

4.5.2 root@ansible:/etc/kubeasz# ./ezctl add-master k8s-01 172.168.2.23		--添加master节点前提是节点配置了免密认证
PLAY RECAP *****************************************************************************************************************************************************************************
172.168.2.21               : ok=5    changed=3    unreachable=0    failed=0
172.168.2.22               : ok=5    changed=3    unreachable=0    failed=0
172.168.2.23               : ok=5    changed=2    unreachable=0    failed=0
172.168.2.24               : ok=5    changed=3    unreachable=0    failed=0
172.168.2.25               : ok=5    changed=3    unreachable=0    failed=0
localhost                  : ok=1    changed=0    unreachable=0    failed=0
root@k8s-master03:~# ps -ef | grep pyth		--在添加节点过程中，172.168.2.23节点实际在运行ansible的脚本，运行完成后将会消失
root        555      1  0 Mar04 ?        00:00:00 /usr/bin/python3 /usr/bin/networkd-dispatcher --run-startup-triggers
root       4094   3534  0 12:19 ?        00:00:00 /bin/sh -c /usr/bin/python && sleep 0
root       4095   4094  0 12:19 ?        00:00:00 /usr/bin/python
root       4096   4095  0 12:19 ?        00:00:00 /usr/bin/python /tmp/ansible_9pUKoh/ansible_module_stat.py
root       4097   4096  0 12:19 ?        00:00:00 /usr/bin/python /tmp/ansible_9pUKoh/ansible_module_stat.py

4.5.3 查看各节点访问kubernetes lb的配置，默认是访问本机的6443，然后本机通过nginx代理(早期是haproxy)到后端的master,这个在添加master或删除master时会动态更新。
root@k8s-master03:~# cat /etc/kube-lb/conf/kube-lb.conf
user root;
worker_processes 1;

error_log  /etc/kube-lb/logs/error.log warn;

events {
    worker_connections  3000;
}

stream {
    upstream backend {
        server 172.168.2.23:6443    max_fails=2 fail_timeout=3s;		#此行在执行add-master时，kubeasz会将新master节点增加到/etc/kubeasz/clusters/k8s-01/hosts中的master组里，从面新添加的master节点会增加此行，对行老的master需要手动添加此行
        server 172.168.2.21:6443    max_fails=2 fail_timeout=3s;
        server 172.168.2.22:6443    max_fails=2 fail_timeout=3s;
    }

    server {
        listen 127.0.0.1:6443;
        proxy_connect_timeout 1s;
        proxy_pass backend;
    }
}
--------
root@k8s-master01:~/k8s# kubectl get node
NAME           STATUS                     ROLES    AGE   VERSION
172.168.2.21   Ready,SchedulingDisabled   master   38h   v1.21.0
172.168.2.22   Ready,SchedulingDisabled   master   38h   v1.21.0
172.168.2.23   Ready,SchedulingDisabled   master   7m    v1.21.0
172.168.2.24   Ready                      node     38h   v1.21.0
172.168.2.25   Ready                      node     38h   v1.21.0

root@ansible:~# ansible 172.168.2.21,172.168.2.22,172.168.2.23 -m shell -a 'md5sum /etc/kubernetes/ssl/kubernetes*'
-------------------------------
172.168.2.23 | SUCCESS | rc=0 >>			------172.168.2.23新添加的master，他跟老的master不是同一批，所以md5值不一样，但不妨碍他们集群信息交换，因为共同信任一个CA
48123460ebea81b0e7c9f34505783327  /etc/kubernetes/ssl/kubernetes-key.pem
2888ca75106741e12be28405d6c3c88b  /etc/kubernetes/ssl/kubernetes.pem

172.168.2.22 | SUCCESS | rc=0 >>
fb6aeefdfb637da3b890b54c966e150b  /etc/kubernetes/ssl/kubernetes-key.pem
de7dfcd82015953231bde245660753c5  /etc/kubernetes/ssl/kubernetes.pem

172.168.2.21 | SUCCESS | rc=0 >>
fb6aeefdfb637da3b890b54c966e150b  /etc/kubernetes/ssl/kubernetes-key.pem
de7dfcd82015953231bde245660753c5  /etc/kubernetes/ssl/kubernetes.pem
-------------------------------

4.5 k8s node添加
root@ansible:/etc/kubeasz# ./ezctl add-node k8s-01 172.168.2.26
PLAY RECAP *****************************************************************************************************************************************************************************
172.168.2.26               : ok=94   changed=83   unreachable=0    failed=0
root@k8s-master01:~/k8s# kubectl get node
NAME           STATUS                     ROLES    AGE     VERSION
172.168.2.21   Ready,SchedulingDisabled   master   38h     v1.21.0
172.168.2.22   Ready,SchedulingDisabled   master   38h     v1.21.0
172.168.2.23   Ready,SchedulingDisabled   master   13m     v1.21.0
172.168.2.24   Ready                      node     38h     v1.21.0
172.168.2.25   Ready                      node     38h     v1.21.0
172.168.2.26   Ready                      node     2m51s   v1.21.0

4.6 k8s升级
小版本更新：1.21.0 --> 1.21.1 --> 1.21.2 	#一般是没有什么问题的
大版本更新：1.21  -->  1.22 --> 1.23		#需要经过严格测试更新，一般会有问题

4.6.1 蓝绿升级(再部署一个集群，将所有pod运行在最新的k8s集群上，然后切换SLB，缺点是耗硬件资源)
						client
							|
							|
							--------------------
												|	
---------------------				---------------------
|					|				|					|
|		1.20.0		|				|		1.20.4		|
|					|				|					|
---------------------				---------------------

4.6.2 滚动升级，不需要耗硬件资源
测试升级流程：
开发测试
测试通过
运维升级(收到测试通过邮件后进行升级)

4.6.2.1 升级过程：
1. 先升级master
	1.1 先将所有node上的/etc/kube-lb/conf/kube-lb.conf配置更改下，将需要升级的一个master节点下线，然后重载nginx配置
	1.2 然后将下线的master节点替换为新版本二进制进行升级，然后上线master节点
	1.3 再将所有node上的/etc/kube-lb/conf/kube-lb.conf配置更改下，将新master节点上线，其它所有master节点下线，然后重载nginx配置
	1.4 再一个一个master节点进行滚动升级，再上线运行即可
2. 再升级node	
	2.1 相比master节点容易升级，需要先停kubelet,kube-proxy服务，然后替换二进制进行升级，升级要快
	2.2 node升级前需要将pod进行驱逐，否则会影响服务

3. master组件选主解释
apiserver作为集群入口，本身是无状态的web服务器，多个apiserver服务之间直接负载请求并不需要做选主。
Controller-Manager和Scheduler作为任务类型的组件，比如controller-manager内置的k8s各种资源对象的控制器实时的watch  apiserver获取对象最新的变化事件做期望状态和实际状态调整，调度器watch未绑定节点的pod做节点选择，显然多个这些任务同时工作是完全没有必要的，所以controller-manager和scheduler也是需要选主的，但是选主逻辑和etcd不一样的，这里只需要保证从多个controller-manager和scheduler之间选出一个进入工作状态即可，而无需考虑它们之间的数据一致和同步。
	
	
4.6.3 采用滚动升级方式进行升级
4.6.3.1 下载需要更新的k8s版本二进制，我们是下载1.21.5
https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.21.md#downloads-for-v12110
root@ansible:~/download# ll
total 463460
drwxr-xr-x  2 root root       161 Mar  6 13:22 ./
drwx------ 13 root root      4096 Mar  6 13:19 ../
-rw-r--r--  1 root root  29275714 Mar  6 13:19 kubernetes-client-linux-amd64.tar.gz
-rw-r--r--  1 root root 118424850 Mar  6 13:22 kubernetes-node-linux-amd64.tar.gz
-rw-r--r--  1 root root 326345382 Mar  6 13:27 kubernetes-server-linux-amd64.tar.gz
-rw-r--r--  1 root root    517251 Mar  6 13:19 kubernetes.tar.gz

4.6.3.2 升级master,配置所有node节点kube-lb，下线第一个需要升级的master节点:172.168.2.21
root@ansible:~/k8s# ansible 172.168.2.24 -m fetch -a 'src=/etc/kube-lb/conf/kube-lb.conf dest=/root/ansible'	--复制node节点的kube-lb配置文件
root@ansible:~/k8s# vim /root/ansible/172.168.2.24/etc/kube-lb/conf/kube-lb.conf
root@ansible:~/k8s# cat /root/ansible/172.168.2.24/etc/kube-lb/conf/kube-lb.conf
user root;
worker_processes 1;

error_log  /etc/kube-lb/logs/error.log warn;

events {
    worker_connections  3000;
}

stream {
    upstream backend {
        server 172.168.2.23:6443    max_fails=2 fail_timeout=3s;
        #server 172.168.2.21:6443    max_fails=2 fail_timeout=3s;	#下线第一个需要升级的master节点:172.168.2.21
        server 172.168.2.22:6443    max_fails=2 fail_timeout=3s;
    }

    server {
        listen 127.0.0.1:6443;
        proxy_connect_timeout 1s;
        proxy_pass backend;
    }
}
---
root@ansible:~/k8s# ansible '~172.168.2.2[456]' -m copy -a 'src=/root/ansible/172.168.2.24/etc/kube-lb/conf/kube-lb.conf dest=/etc/kube-lb/conf/kube-lb.conf'	--分发更改后配置到node
root@ansible:~/k8s# ansible '~172.168.2.2[456]' -m shell -a 'grep "server 172.168.2.21:6443" /etc/kube-lb/conf/kube-lb.conf'	--验证配置是否如预期
172.168.2.24 | SUCCESS | rc=0 >>
        #server 172.168.2.21:6443    max_fails=2 fail_timeout=3s;

172.168.2.25 | SUCCESS | rc=0 >>
        #server 172.168.2.21:6443    max_fails=2 fail_timeout=3s;

172.168.2.26 | SUCCESS | rc=0 >>
        #server 172.168.2.21:6443    max_fails=2 fail_timeout=3s;

root@ansible:~/k8s# ansible '~172.168.2.2[456]' -m shell -a 'systemctl reload kube-lb.service'	--重载node服务
172.168.2.26 | SUCCESS | rc=0 >>


172.168.2.24 | SUCCESS | rc=0 >>


172.168.2.25 | SUCCESS | rc=0 >>

root@ansible:~/k8s# ansible '~172.168.2.2[456]' -m shell -a 'systemctl status kube-lb.service | grep Reload'	--查看是否重载生效
172.168.2.26 | SUCCESS | rc=0 >>
  Process: 47571 ExecReload=/etc/kube-lb/sbin/kube-lb -c /etc/kube-lb/conf/kube-lb.conf -p /etc/kube-lb -s reload (code=exited, status=0/SUCCESS)
Mar 06 13:02:07 k8s-node03 systemd[1]: Reloading l4 nginx proxy for kube-apiservers.
Mar 06 13:02:08 k8s-node03 systemd[1]: Reloaded l4 nginx proxy for kube-apiservers.
Mar 06 13:12:45 k8s-node03 systemd[1]: Reloading l4 nginx proxy for kube-apiservers.
Mar 06 13:12:45 k8s-node03 systemd[1]: Reloaded l4 nginx proxy for kube-apiservers.

172.168.2.25 | SUCCESS | rc=0 >>
  Process: 27252 ExecReload=/etc/kube-lb/sbin/kube-lb -c /etc/kube-lb/conf/kube-lb.conf -p /etc/kube-lb -s reload (code=exited, status=0/SUCCESS)
Mar 06 13:12:45 k8s-node02 systemd[1]: Reloading l4 nginx proxy for kube-apiservers.
Mar 06 13:12:45 k8s-node02 systemd[1]: Reloaded l4 nginx proxy for kube-apiservers.

172.168.2.24 | SUCCESS | rc=0 >>
  Process: 109649 ExecReload=/etc/kube-lb/sbin/kube-lb -c /etc/kube-lb/conf/kube-lb.conf -p /etc/kube-lb -s reload (code=exited, status=0/SUCCESS)
Mar 06 13:12:45 k8s-node01 systemd[1]: Reloading l4 nginx proxy for kube-apiservers.
Mar 06 13:12:45 k8s-node01 systemd[1]: Reloaded l4 nginx proxy for kube-apiservers.
注：无论是master还是node，它们访问的都是本机127.0.0.1:6443，然后通过本机nginx(/etc/kube-lb/sbin/kube-lb实际就是nginx)代理到后端master。由于主要是node节点运行pod，所以只更改node配置。kube-lb对后端master会做健康检测，所以不做以上步骤也是可以的，但是为了确保健康检测时间内无任何故障，需要如上操作确保。

4.6.3.3 升级第一个master
root@ansible:~/download# for i in `ls`;do tar -xf $i;done		--解析所有压缩包，会都解压到kubernetes文件夹中
root@ansible:~/download/kubernetes# ls server/bin/
apiextensions-apiserver  kube-apiserver.docker_tag           kube-controller-manager.tar  kube-proxy             kube-scheduler.docker_tag
kubeadm                  kube-apiserver.tar                  kubectl                      kube-proxy.docker_tag  kube-scheduler.tar
kube-aggregator          kube-controller-manager             kubectl-convert              kube-proxy.tar         mounter
kube-apiserver           kube-controller-manager.docker_tag  kubelet                      kube-scheduler
root@ansible:~/download/kubernetes# ./server/bin/kube-apiserver --version		--是新版本二进制，在测试环境测试确定没有问题再替换生产环境，如果yaml文件需要调整则进行调整测试
Kubernetes v1.21.5
root@ansible:~/download/kubernetes# ls /etc/kubeasz/bin/
bridge     cfssl-certinfo  containerd       ctr             dockerd       etcd     helm        kube-apiserver           kubelet         loopback  runc
calicoctl  cfssljson       containerd-bin   docker          docker-init   etcdctl  host-local  kube-controller-manager  kube-proxy      nginx     tuning
cfssl      chronyd         containerd-shim  docker-compose  docker-proxy  flannel  keepalived  kubectl                  kube-scheduler  portmap
root@ansible:~/download/kubernetes# /etc/kubeasz/bin/kube-apiserver --version		--这里面是老版本v1.21.0
Kubernetes v1.21.0
root@k8s-master01:~/k8s# kube		--除开kubectl(可以不用升级)，其它五个服务都需要停止升级
kube-apiserver           kube-controller-manager  kubectl                  kubelet                  kube-proxy               kube-scheduler
root@k8s-master01:~/k8s# systemctl stop kube
kube-apiserver.service           kube-lb.service                  kube-proxy.service
kube-controller-manager.service  kubelet.service                  kube-scheduler.service
root@k8s-master01:~/k8s# systemctl stop kube-apiserver.service kube-controller-manager.service kube-scheduler.service kubelet.service kube-proxy.service
root@k8s-master01:~/k8s# ls /usr/local/bin/kube*		--确定master二进制文件在哪个目录，确定在/usr/local/bin目录下
/usr/local/bin/kube-apiserver  /usr/local/bin/kube-controller-manager  /usr/local/bin/kubectl  /usr/local/bin/kubelet  /usr/local/bin/kube-proxy  /usr/local/bin/kube-scheduler
root@ansible:~/download/kubernetes# cd /root/download/kubernetes/server/bin/	
root@ansible:~/download/kubernetes/server/bin# scp kube-apiserver kube-controller-manager kube-scheduler kube-proxy kubelet root@172.168.2.21:/usr/local/bin/	--从ansible服务器复制新版本二进制到下线master上
kube-apiserver                                                                                                                                        100%  117MB  29.2MB/s   00:03
kube-controller-manager                                                                                                                               100%  111MB  33.2MB/s   00:03
kube-scheduler                                                                                                                                        100%   45MB  20.3MB/s   00:02
kube-proxy                                                                                                                                            100%   41MB  34.4MB/s   00:01
kubelet                                                                                                                                               100%  113MB  31.2MB/s   00:03
root@k8s-master01:~/k8s# /usr/local/bin/kube-apiserver --version		--测试确定是否是新版本
Kubernetes v1.21.5
root@k8s-master02:~# kubectl get nodes
NAME           STATUS                        ROLES    AGE   VERSION
172.168.2.21   NotReady,SchedulingDisabled   master   39h   v1.21.0		--master02看还是v1.21.0，NotReady
172.168.2.22   Ready,SchedulingDisabled      master   39h   v1.21.0
172.168.2.23   Ready,SchedulingDisabled      master   83m   v1.21.0
172.168.2.24   Ready                         node     39h   v1.21.0
172.168.2.25   Ready                         node     39h   v1.21.0
172.168.2.26   Ready                         node     73m   v1.21.0
root@k8s-master01:~/k8s# systemctl start kube-apiserver.service kube-controller-manager.service kube-scheduler.service kubelet.service kube-proxy.service	--确认无误后重新启动master的服务
root@k8s-master02:~# kubectl get nodes
NAME           STATUS                     ROLES    AGE   VERSION
172.168.2.21   Ready,SchedulingDisabled   master   39h   v1.21.5		--master02看现在是v1.21.5，版本变化说明升级成功，版本显示的其实是kubelet的版本
172.168.2.22   Ready,SchedulingDisabled   master   39h   v1.21.0
172.168.2.23   Ready,SchedulingDisabled   master   83m   v1.21.0
172.168.2.24   Ready                      node     39h   v1.21.0
172.168.2.25   Ready                      node     39h   v1.21.0
172.168.2.26   Ready                      node     73m   v1.21.0

4.6.3.4 升级第二个、第三个master(172.168.2.22,172.68.2.23)，
root@ansible:~/download/kubernetes/server/bin# vim /root/ansible/172.168.2.24/etc/kube-lb/conf/kube-lb.conf
root@ansible:~/download/kubernetes/server/bin# cat /root/ansible/172.168.2.24/etc/kube-lb/conf/kube-lb.conf
user root;
worker_processes 1;

error_log  /etc/kube-lb/logs/error.log warn;

events {
    worker_connections  3000;
}

stream {
    upstream backend {
        #server 172.168.2.23:6443    max_fails=2 fail_timeout=3s;
        server 172.168.2.21:6443    max_fails=2 fail_timeout=3s;
        #server 172.168.2.22:6443    max_fails=2 fail_timeout=3s;
    }

    server {
        listen 127.0.0.1:6443;
        proxy_connect_timeout 1s;
        proxy_pass backend;
    }
}
---------
root@ansible:~/download/kubernetes/server/bin# ansible '~172.168.2.2[456]' -m copy -a 'src=/root/ansible/172.168.2.24/etc/kube-lb/conf/kube-lb.conf dest=/etc/kube-lb/conf/kube-lb.conf'
root@ansible:~/download/kubernetes/server/bin# ansible '~172.168.2.2[456]' -m shell -a 'grep "server 172.168.2.21:6443" /etc/kube-lb/conf/kube-lb.conf'
172.168.2.25 | SUCCESS | rc=0 >>
        server 172.168.2.21:6443    max_fails=2 fail_timeout=3s;

172.168.2.24 | SUCCESS | rc=0 >>
        server 172.168.2.21:6443    max_fails=2 fail_timeout=3s;

172.168.2.26 | SUCCESS | rc=0 >>
        server 172.168.2.21:6443    max_fails=2 fail_timeout=3s;
root@ansible:~/download/kubernetes/server/bin# ansible '~172.168.2.2[456]' -m shell -a 'systemctl reload kube-lb.service'
root@ansible:~/download/kubernetes/server/bin# ansible '~172.168.2.2[456]' -m shell -a 'systemctl status kube-lb.service | grep Reload'
172.168.2.24 | SUCCESS | rc=0 >>
  Process: 27086 ExecReload=/etc/kube-lb/sbin/kube-lb -c /etc/kube-lb/conf/kube-lb.conf -p /etc/kube-lb -s reload (code=exited, status=0/SUCCESS)
Mar 06 13:12:45 k8s-node01 systemd[1]: Reloading l4 nginx proxy for kube-apiservers.
Mar 06 13:12:45 k8s-node01 systemd[1]: Reloaded l4 nginx proxy for kube-apiservers.
Mar 06 13:53:57 k8s-node01 systemd[1]: Reloading l4 nginx proxy for kube-apiservers.
Mar 06 13:53:57 k8s-node01 systemd[1]: Reloaded l4 nginx proxy for kube-apiservers.

172.168.2.25 | SUCCESS | rc=0 >>
  Process: 69353 ExecReload=/etc/kube-lb/sbin/kube-lb -c /etc/kube-lb/conf/kube-lb.conf -p /etc/kube-lb -s reload (code=exited, status=0/SUCCESS)
Mar 06 13:12:45 k8s-node02 systemd[1]: Reloading l4 nginx proxy for kube-apiservers.
Mar 06 13:12:45 k8s-node02 systemd[1]: Reloaded l4 nginx proxy for kube-apiservers.
Mar 06 13:53:57 k8s-node02 systemd[1]: Reloading l4 nginx proxy for kube-apiservers.
Mar 06 13:53:57 k8s-node02 systemd[1]: Reloaded l4 nginx proxy for kube-apiservers.

172.168.2.26 | SUCCESS | rc=0 >>
  Process: 87291 ExecReload=/etc/kube-lb/sbin/kube-lb -c /etc/kube-lb/conf/kube-lb.conf -p /etc/kube-lb -s reload (code=exited, status=0/SUCCESS)
Mar 06 13:02:07 k8s-node03 systemd[1]: Reloading l4 nginx proxy for kube-apiservers.
Mar 06 13:02:08 k8s-node03 systemd[1]: Reloaded l4 nginx proxy for kube-apiservers.
Mar 06 13:12:45 k8s-node03 systemd[1]: Reloading l4 nginx proxy for kube-apiservers.
Mar 06 13:12:45 k8s-node03 systemd[1]: Reloaded l4 nginx proxy for kube-apiservers.
Mar 06 13:53:57 k8s-node03 systemd[1]: Reloading l4 nginx proxy for kube-apiservers.
Mar 06 13:53:57 k8s-node03 systemd[1]: Reloaded l4 nginx proxy for kube-apiservers.
root@ansible:~/download/kubernetes/server/bin# ansible '~172.168.2.2[23]' -m shell -a 'systemctl stop kube-apiserver.service kube-controller-manager.service kube-scheduler.service kubelet.service kube-proxy.service'		--停止掉两个master的服务
root@ansible:~/download/kubernetes/server/bin# ansible '~172.168.2.2[23]' -m shell -a 'systemctl status kube-apiserver.service kube-controller-manager.service kube-scheduler.service kubelet.service kube-proxy.service | grep Active'		--确定是否成功关闭
172.168.2.22 | SUCCESS | rc=0 >>
   Active: inactive (dead) since Sun 2022-03-06 13:59:50 CST; 43s ago
   Active: inactive (dead) since Sun 2022-03-06 13:58:50 CST; 1min 43s ago
   Active: inactive (dead) since Sun 2022-03-06 13:58:50 CST; 1min 43s ago
   Active: inactive (dead) since Sun 2022-03-06 13:58:50 CST; 1min 43s ago
   Active: inactive (dead) since Sun 2022-03-06 13:58:50 CST; 1min 43s ago

172.168.2.23 | SUCCESS | rc=0 >>
   Active: inactive (dead) since Sun 2022-03-06 13:59:50 CST; 43s ago
   Active: inactive (dead) since Sun 2022-03-06 13:58:50 CST; 1min 43s ago
   Active: inactive (dead) since Sun 2022-03-06 13:58:50 CST; 1min 43s ago
   Active: inactive (dead) since Sun 2022-03-06 13:58:50 CST; 1min 43s ago
   Active: inactive (dead) since Sun 2022-03-06 13:58:50 CST; 1min 43s ago
	
root@ansible:~/download/kubernetes/server/bin# for i in 172.168.2.22 172.168.2.23;do scp kube-apiserver kube-controller-manager kube-scheduler kube-proxy kubelet root@${i}:/usr/local/bin/;done	--从ansible服务器复制新版本二进制到下线master上
kube-apiserver                                                                                                                                        100%  117MB  35.8MB/s   00:03
kube-controller-manager                                                                                                                               100%  111MB  31.7MB/s   00:03
kube-scheduler                                                                                                                                        100%   45MB  29.0MB/s   00:01
kube-proxy                                                                                                                                            100%   41MB  50.3MB/s   00:00
kubelet                                                                                                                                               100%  113MB  43.9MB/s   00:02
kube-apiserver                                                                                                                                        100%  117MB  49.2MB/s   00:02
kube-controller-manager                                                                                                                               100%  111MB  57.0MB/s   00:01
kube-scheduler                                                                                                                                        100%   45MB  50.3MB/s   00:00
kube-proxy                                                                                                                                            100%   41MB  57.1MB/s   00:00
kubelet                                                                                                                                               100%  113MB  51.4MB/s   00:02
root@ansible:~/download/kubernetes/server/bin# ansible '~172.168.2.2[23]' -m shell -a '/usr/local/bin/kube-apiserver --version'
172.168.2.22 | SUCCESS | rc=0 >>
Kubernetes v1.21.5

172.168.2.23 | SUCCESS | rc=0 >>
Kubernetes v1.21.5
root@k8s-master01:~/k8s# kubectl get nodes		--当前状态
NAME           STATUS                        ROLES    AGE    VERSION
172.168.2.21   Ready,SchedulingDisabled      master   40h    v1.21.5
172.168.2.22   NotReady,SchedulingDisabled   master   40h    v1.21.0
172.168.2.23   NotReady,SchedulingDisabled   master   108m   v1.21.0
172.168.2.24   Ready                         node     40h    v1.21.0
172.168.2.25   Ready                         node     40h    v1.21.0
172.168.2.26   Ready                         node     97m    v1.21.0
root@ansible:~/download/kubernetes/server/bin# ansible '~172.168.2.2[23]' -m shell -a 'systemctl start kube-apiserver.service kube-controller-manager.service kube-scheduler.service kubelet.service kube-proxy.service'
root@k8s-master01:~/k8s# kubectl get nodes
NAME           STATUS                     ROLES    AGE    VERSION
172.168.2.21   Ready,SchedulingDisabled   master   40h    v1.21.5
172.168.2.22   Ready,SchedulingDisabled   master   40h    v1.21.5
172.168.2.23   Ready,SchedulingDisabled   master   108m   v1.21.5
172.168.2.24   Ready                      node     40h    v1.21.0
172.168.2.25   Ready                      node     40h    v1.21.0
172.168.2.26   Ready                      node     98m    v1.21.0
root@ansible:~/download/kubernetes/server/bin# vim /root/ansible/172.168.2.24/etc/kube-lb/conf/kube-lb.conf
root@ansible:~/download/kubernetes/server/bin# cat /root/ansible/172.168.2.24/etc/kube-lb/conf/kube-lb.conf
user root;
worker_processes 1;

error_log  /etc/kube-lb/logs/error.log warn;

events {
    worker_connections  3000;
}

stream {
    upstream backend {
        server 172.168.2.23:6443    max_fails=2 fail_timeout=3s;
        server 172.168.2.21:6443    max_fails=2 fail_timeout=3s;
        server 172.168.2.22:6443    max_fails=2 fail_timeout=3s;
    }

    server {
        listen 127.0.0.1:6443;
        proxy_connect_timeout 1s;
        proxy_pass backend;
    }
}
root@ansible:~/download/kubernetes/server/bin# ansible '~172.168.2.2[456]' -m copy -a 'src=/root/ansible/172.168.2.24/etc/kube-lb/conf/kube-lb.conf dest=/etc/kube-lb/conf/kube-lb.conf'
root@ansible:~/download/kubernetes/server/bin# ansible '~172.168.2.2[456]' -m shell -a 'grep "server 172.168.2.2" /etc/kube-lb/conf/kube-lb.conf'
root@ansible:~/download/kubernetes/server/bin# ansible '~172.168.2.2[456]' -m shell -a 'systemctl reload kube-lb.service'

4.6.3.5 升级node
4.6.3.5.1 root@k8s-master01:~/k8s# kubectl cordon 172.168.2.24	--将172.168.2.24配置为不可调度
node/172.168.2.24 cordoned
root@k8s-master01:~/k8s# kubectl get nodes
NAME           STATUS                     ROLES    AGE    VERSION
172.168.2.21   Ready,SchedulingDisabled   master   40h    v1.21.5
172.168.2.22   Ready,SchedulingDisabled   master   40h    v1.21.5
172.168.2.23   Ready,SchedulingDisabled   master   117m   v1.21.5
172.168.2.24   Ready,SchedulingDisabled   node     40h    v1.21.0
172.168.2.25   Ready                      node     40h    v1.21.0
172.168.2.26   Ready                      node     107m   v1.21.0

4.6.3.5.2 root@k8s-master01:~/k8s# kubectl drain 172.168.2.24 --force --ignore-daemonsets --delete-emptydir-data	--驱逐172.168.2.24
node/172.168.2.24 already cordoned
WARNING: deleting Pods not managed by ReplicationController, ReplicaSet, Job, DaemonSet or StatefulSet: default/net-test3; ignoring DaemonSet-managed Pods: kube-system/calico-node-qnvt9
evicting pod kubernetes-dashboard/dashboard-metrics-scraper-67d4cf4b45-8m2dl
evicting pod default/net-test3
evicting pod kube-system/calico-kube-controllers-647f956d86-9bdm7
pod/calico-kube-controllers-647f956d86-9bdm7 evicted
pod/dashboard-metrics-scraper-67d4cf4b45-8m2dl evicted
pod/net-test3 evicted
node/172.168.2.24 evicted

4.6.3.5.3 替换新版本二进制升级node
root@ansible:~/download/kubernetes/server/bin# ansible 172.168.2.24 -m shell -a 'systemctl stop kubelet.service kube-proxy.service'
root@ansible:~/download/kubernetes/server/bin# scp kubelet kube-proxy root@172.168.2.24:/usr/local/bin/
root@ansible:~/download/kubernetes/server/bin# ansible 172.168.2.24 -m shell -a 'systemctl start kubelet.service kube-proxy.service'
root@ansible:~/download/kubernetes/server/bin# ansible 172.168.2.24 -m shell -a 'systemctl status kubelet.service kube-proxy.service | grep Active'
172.168.2.24 | SUCCESS | rc=0 >>
   Active: active (running) since Sun 2022-03-06 14:28:01 CST; 11s ago
   Active: active (running) since Sun 2022-03-06 14:28:01 CST; 11s ago
root@k8s-master01:~/k8s# kubectl get nodes
NAME           STATUS                     ROLES    AGE    VERSION
172.168.2.21   Ready,SchedulingDisabled   master   40h    v1.21.5
172.168.2.22   Ready,SchedulingDisabled   master   40h    v1.21.5
172.168.2.23   Ready,SchedulingDisabled   master   127m   v1.21.5
172.168.2.24   Ready,SchedulingDisabled   node     40h    v1.21.5		--此时升级完成为v1.21.5
172.168.2.25   Ready                      node     40h    v1.21.0
172.168.2.26   Ready                      node     116m   v1.21.0
root@k8s-master01:~/k8s# kubectl uncordon 172.168.2.24		--将172.168.2.24恢复为可调度
node/172.168.2.24 uncordoned
root@k8s-master01:~/k8s# kubectl get nodes
NAME           STATUS                     ROLES    AGE    VERSION
172.168.2.21   Ready,SchedulingDisabled   master   40h    v1.21.5
172.168.2.22   Ready,SchedulingDisabled   master   40h    v1.21.5
172.168.2.23   Ready,SchedulingDisabled   master   128m   v1.21.5
172.168.2.24   Ready                      node     40h    v1.21.5
172.168.2.25   Ready                      node     40h    v1.21.0
172.168.2.26   Ready                      node     117m   v1.21.0
root@k8s-master01:~/k8s# kubectl get pods -A -o wide		--因为net-test3不是控制器pod，所以驱逐后会丢失，生产环境是不允许创建这样的pod的
NAMESPACE              NAME                                         READY   STATUS    RESTARTS   AGE    IP               NODE           NOMINATED NODE   READINESS GATES
default                net-test1                                    1/1     Running   4          40h    172.20.58.193    172.168.2.25   <none>           <none>
default                net-test2                                    1/1     Running   4          40h    172.20.58.194    172.168.2.25   <none>           <none>
kube-system            calico-kube-controllers-647f956d86-q4f28     1/1     Running   0          6m6s   172.168.2.26     172.168.2.26   <none>           <none>
kube-system            calico-node-fl565                            1/1     Running   0          124m   172.168.2.25     172.168.2.25   <none>           <none>
kube-system            calico-node-ldrjs                            1/1     Running   0          127m   172.168.2.21     172.168.2.21   <none>           <none>
kube-system            calico-node-qnvt9                            1/1     Running   0          126m   172.168.2.24     172.168.2.24   <none>           <none>
kube-system            calico-node-t9rh6                            1/1     Running   0          127m   172.168.2.23     172.168.2.23   <none>           <none>
kube-system            calico-node-vbvts                            1/1     Running   0          118m   172.168.2.26     172.168.2.26   <none>           <none>
kube-system            calico-node-x9tjb                            1/1     Running   0          125m   172.168.2.22     172.168.2.22   <none>           <none>
kube-system            coredns-5fc7c5b494-gcb2w                     1/1     Running   0          39h    172.20.58.196    172.168.2.25   <none>           <none>
kubernetes-dashboard   dashboard-metrics-scraper-67d4cf4b45-w6vr9   1/1     Running   0          6m6s   172.20.135.129   172.168.2.26   <none>           <none>
kubernetes-dashboard   kubernetes-dashboard-7c889c777-cfgw5         1/1     Running   0          161m   172.20.58.197    172.168.2.25   <none>           <none>

4.6.3.5.4 升级其它node
root@ansible:~/download/kubernetes/server/bin# ansible '~172.168.2.2[56]' -m shell -a 'systemctl stop kubelet.service kube-proxy.service'
root@ansible:~/download/kubernetes/server/bin# for i in 172.168.2.25 172.168.2.26;do scp kubelet kube-proxy root@$i:/usr/local/bin/;done
root@ansible:~/download/kubernetes/server/bin# ansible '~172.168.2.2[56]' -m shell -a 'systemctl start kubelet.service kube-proxy.service'
root@k8s-master01:~/k8s# kubectl get nodes
NAME           STATUS                     ROLES    AGE    VERSION
172.168.2.21   Ready,SchedulingDisabled   master   40h    v1.21.5
172.168.2.22   Ready,SchedulingDisabled   master   40h    v1.21.5
172.168.2.23   Ready,SchedulingDisabled   master   131m   v1.21.5
172.168.2.24   Ready                      node     40h    v1.21.5
172.168.2.25   Ready                      node     40h    v1.21.5
172.168.2.26   Ready                      node     121m   v1.21.5



5 etcd客户端使用，数据备份与恢复
etcd服务器配置：SSD硬件，大内存，物理机最好
复制（镜像）集群: mysql,redis sentinal,etcd,zookeeper,rabbitmq 
分布式集群：elasticsearch,redis cluster,kafka

5.1 etcd常用操作
--查看etcd端点是否健康
root@k8s-master01:~/k8s# export NODE_IPS='172.168.2.21 172.168.2.22 172.168.2.23'
root@k8s-master01:~/k8s# for ip in ${NODE_IPS}; do ETCDCTL_API=3 /usr/local/bin/etcdctl --endpoints=https://${ip}:2379 --cacert=/etc/kubernetes/ssl/ca.pem --cert=/etc/kubernetes/ssl/etcd.pem --key=/etc/kubernetes/ssl/etcd-key.pem endpoint health; done
https://172.168.2.21:2379 is healthy: successfully committed proposal: took = 25.812243ms
https://172.168.2.22:2379 is healthy: successfully committed proposal: took = 15.815519ms
https://172.168.2.23:2379 is healthy: successfully committed proposal: took = 14.04151ms
--查看成员列表
root@k8s-master01:~/k8s# etcdctl member list	--v3版本可以不带证书，最好带证书
27f8ddc0f1ae8387, started, etcd-172.168.2.23, https://172.168.2.23:2380, https://172.168.2.23:2379, false
2cc5541313751d5d, started, etcd-172.168.2.21, https://172.168.2.21:2380, https://172.168.2.21:2379, false
b829b739e7a1b7aa, started, etcd-172.168.2.22, https://172.168.2.22:2380, https://172.168.2.22:2379, false
root@k8s-master01:~/k8s# ETCDCTL_API=3 etcdctl --endpoints=https://172.168.2.21:2379 --cacert=/etc/kubernetes/ssl/ca.pem --cert=/etc/kubernetes/ssl/etcd.pem --key=/etc/kubernetes/ssl/etcd-key.pem --write-out=table member list --write-out='table'	--使用证书
+------------------+---------+-------------------+---------------------------+---------------------------+------------+
|        ID        | STATUS  |       NAME        |        PEER ADDRS         |       CLIENT ADDRS        | IS LEARNER |
+------------------+---------+-------------------+---------------------------+---------------------------+------------+
| 27f8ddc0f1ae8387 | started | etcd-172.168.2.23 | https://172.168.2.23:2380 | https://172.168.2.23:2379 |      false |
| 2cc5541313751d5d | started | etcd-172.168.2.21 | https://172.168.2.21:2380 | https://172.168.2.21:2379 |      false |
| b829b739e7a1b7aa | started | etcd-172.168.2.22 | https://172.168.2.22:2380 | https://172.168.2.22:2379 |      false |
+------------------+---------+-------------------+---------------------------+---------------------------+------------+
--查看端点状态
root@k8s-master01:~/k8s# for ip in ${NODE_IPS}; do ETCDCTL_API=3 /usr/local/bin/etcdctl --endpoints=https://${ip}:2379 --cacert=/etc/kubernetes/ssl/ca.pem --cert=/etc/kubernetes/ssl/etcd.pem --key=/etc/kubernetes/ssl/etcd-key.pem --write-out=table endpoint status ; done
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|         ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://172.168.2.21:2379 | 2cc5541313751d5d |  3.4.13 |  3.4 MB |      true |      false |         3 |     354123 |             354123 |        |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|         ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://172.168.2.22:2379 | b829b739e7a1b7aa |  3.4.13 |  3.6 MB |     false |      false |         3 |     354123 |             354123 |        |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|         ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://172.168.2.23:2379 | 27f8ddc0f1ae8387 |  3.4.13 |  3.6 MB |     false |      false |         3 |     354123 |             354123 |        |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+

--
root@k8s-master01:~/k8s# ETCDCTL_API=3 etcdctl get / --prefix --keys-only		--只查看etcd的key
root@k8s-master01:~/k8s# ETCDCTL_API=3 etcdctl get / --prefix --keys-only | grep pods | wc -l
12
root@k8s-master01:~/k8s# ETCDCTL_API=3 etcdctl get / --prefix --keys-only | grep namespaces | wc -l
5
root@k8s-master01:~/k8s# ETCDCTL_API=3 etcdctl get /calico/ipam/v2/assignment/ipv4/block/172.20.122.128-26	--获取calico地址分配信息
/calico/ipam/v2/assignment/ipv4/block/172.20.122.128-26
{"cidr":"172.20.122.128/26","affinity":"host:k8s-master02","allocations":[0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"unallocated":[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63],"attributes":[{"handle_id":"ipip-tunnel-addr-k8s-master02","secondary":{"node":"k8s-master02","type":"ipipTunnelAddress"}}],"deleted":false}

5.2 etcd增删改查
--增：
root@k8s-master01:~/k8s# ETCDCTL_API=3 etcdctl put /magedu/n56 linux
OK
root@k8s-master01:~/k8s# ETCDCTL_API=3 etcdctl get /magedu/n56
/magedu/n56
linux
--改：
root@k8s-master01:~/k8s# ETCDCTL_API=3 etcdctl put /magedu/n56 linux56
OK
root@k8s-master01:~/k8s# ETCDCTL_API=3 etcdctl get /magedu/n56
/magedu/n56
linux56
--删：
root@k8s-master01:~/k8s# ETCDCTL_API=3 etcdctl del /magedu/n56
1
root@k8s-master01:~/k8s# ETCDCTL_API=3 etcdctl get /magedu/n56

5.3 etcd数据watch机制
基于不断监看数据，发生变化就主动触发通知客户端，Etcd v3 的watch机制支持watch某个固定的key，也支持watch一个范围。
相比Etcd v2, Etcd v3的一些主要变化：
	接口通过grpc提供rpc接口，放弃了v2的http接口，优势是长连接效率提升明显，缺点是使用不如以前方便，尤其对不方便维护长连接的场景。
	废弃了原来的目录结构，变成了纯粹的kv，用户可以通过前缀匹配模式模拟目录。
	内存中不再保存value，同样的内存可以支持存储更多的key。
	watch机制更稳定，基本上可以通过watch机制实现数据的完全同步。
	提供了批量操作以及事务机制，用户可以通过批量事务请求来实现Etcd v2的CAS机制（批量事务支持if条件判断）。
root@k8s-master02:~# ETCDCTL_API=3 etcdctl  watch /magedu/linux		--此客户端一直在watch /magedu/linux这个key,当其它客户端写入这个key时就会立即返回value给这个客户端
root@k8s-master01:~/k8s# ETCDCTL_API=3 etcdctl put /magedu/linux ubuntu		--其它客户端写入此key
OK
root@k8s-master02:~# etcdctl  watch /magedu/linux		--此客户端立即返回方法、key、value
PUT
/magedu/linux
ubuntu

5.4 etcd数据备份与恢复机制：
WAL是write ahead log的缩写，顾名思义，也就是在执行真正的写操作之前先写一个日志，预写日志。
wal: 存放预写式日志,最大的作用是记录了整个数据变化的全部历程。在etcd中，所有数据的修改在提交前，都要先写入到WAL中。

etcd v2版本数据备份与恢复：	----现在都是v3，此备份命令在v3版本已被废了
5.4.1 ----V2版本备份数据：
root@k8s-etcd2:~# ETCDCTL_API=2 etcdctl backup --data-dir /var/lib/etcd/ --backup-dir /opt/etcd_backup
2019-07-11 18:59:57.674432 I | wal: segmented wal file
/opt/etcd_backup/member/wal/0000000000000001-0000000000017183.wal is created
V2版本恢复数据：
root@k8s-etcd2:~# vim /etc/systemd/system/etcd.service
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target
Documentation=https://github.com/coreos
[Service]
Type=notify
WorkingDirectory=/var/lib/etcd/
ExecStart=/usr/bin/etcd
\
--name=etcd2 \
.................................
--data-dir=/opt/etcd_backup -force-new-cluster #强制设置为新集群
Restart=on-failure
RestartSec=5
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
----------

5.4.2 ----etcd 集群v3版本数据自动备份与恢复
手动备份：
root@k8s-master02:~# ETCDCTL_API=3 etcdctl snapshot save etcd-20220306.db
{"level":"info","ts":1646568636.104002,"caller":"snapshot/v3_snapshot.go:119","msg":"created temporary db file","path":"etcd-20220306.db.part"}
{"level":"info","ts":"2022-03-06T20:10:36.106+0800","caller":"clientv3/maintenance.go:200","msg":"opened snapshot stream; downloading"}
{"level":"info","ts":1646568636.1152713,"caller":"snapshot/v3_snapshot.go:127","msg":"fetching snapshot","endpoint":"127.0.0.1:2379"}
{"level":"info","ts":"2022-03-06T20:10:36.218+0800","caller":"clientv3/maintenance.go:208","msg":"completed snapshot read; closing"}
{"level":"info","ts":1646568636.2266297,"caller":"snapshot/v3_snapshot.go:142","msg":"fetched snapshot","endpoint":"127.0.0.1:2379","size":"3.6 MB","took":0.121813272}
{"level":"info","ts":1646568636.2267795,"caller":"snapshot/v3_snapshot.go:152","msg":"saved","path":"etcd-20220306.db"}
Snapshot saved at etcd-20220306.db

手动还原：
root@k8s-master02:~# ETCDCTL_API=3 etcdctl snapshot restore /root/etcd-20220306.db --data-dir=/tmp/etcd		#将数据恢复到一个新的不存在的目录中
{"level":"info","ts":1646568802.767991,"caller":"snapshot/v3_snapshot.go:296","msg":"restoring snapshot","path":"/root/etcd-20220306.db","wal-dir":"/tmp/etcd/member/wal","data-dir":"/tmp/etcd","snap-dir":"/tmp/etcd/member/snap"}
{"level":"info","ts":1646568802.8069868,"caller":"mvcc/kvstore.go:380","msg":"restored last compact revision","meta-bucket-name":"meta","meta-bucket-name-key":"finishedCompactRev","restored-compact-revision":285360}
{"level":"info","ts":1646568802.8211381,"caller":"membership/cluster.go:392","msg":"added member","cluster-id":"cdf818194e3a8c32","local-member-id":"0","added-peer-id":"8e9e05c52164694d","added-peer-peer-urls":["http://localhost:2380"]}
{"level":"info","ts":1646568802.8260946,"caller":"snapshot/v3_snapshot.go:309","msg":"restored snapshot","path":"/root/etcd-20220306.db","wal-dir":"/tmp/etcd/member/wal","data-dir":"/tmp/etcd","snap-dir":"/tmp/etcd/member/snap"}
root@k8s-master02:~# ETCDCTL_API=3 etcdctl snapshot restore /root/etcd-20220306.db --data-dir=/tmp/etcd		#再次执行恢复会报错
Error: data-dir "/tmp/etcd" exists

5.4.2 v3版本自动备份数据脚本
root@k8s-master02:~# mkdir /data/etcd-backup-dir/ -p
root@k8s-master02:~# cat script.sh
#!/bin/bash
source /etc/profile
DATE=`date +%Y-%m-%d_%H-%M-%S`
ETCDCTL_API=3 /usr/bin/etcdctl snapshot save /data/etcd-backup-dir/etcd-snapshot-${DATE}.db
---------------

5.4.3 etcd 集群v3版本数据自动备份与恢复：
root@ansible:/etc/kubeasz# ./ezctl backup k8s-01
root@ansible:/etc/kubeasz#  kubectl delete pod net-test4
pod "net-test4" deleted
root@ansible:/etc/kubeasz# ./ezctl restore k8s-01



###5.5 模拟单etcd节点故障
root@k8s-master02:~# for ip in ${NODE_IPS}; do ETCDCTL_API=3 /usr/local/bin/etcdctl --endpoints=https://${ip}:2379 --cacert=/etc/kubernetes/ssl/ca.pem --cert=/etc/kubernetes/ssl/etcd.pem --key=/etc/kubernetes/ssl/etcd-key.pem --write-out=table endpoint status ; done
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|         ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://172.168.2.21:2379 | 2cc5541313751d5d |  3.4.13 |  3.6 MB |     false |      false |        27 |       2212 |               2212 |        |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|         ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://172.168.2.22:2379 | b829b739e7a1b7aa |  3.4.13 |  3.6 MB |      true |      false |        27 |       2212 |               2212 |        |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|         ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://172.168.2.23:2379 | 27f8ddc0f1ae8387 |  3.4.13 |  3.6 MB |     false |      false |        27 |       2212 |               2212 |        |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+

root@k8s-master02:~# for ip in ${NODE_IPS}; do ETCDCTL_API=3 /usr/local/bin/etcdctl --endpoints=https://${ip}:2379 --cacert=/etc/kubernetes/ssl/ca.pem --cert=/etc/kubernetes/ssl/etcd.pem --key=/etc/kubernetes/ssl/etcd-key.pem --write-out=table endpoint status ; done	--此时172.168.2.22节点故障
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|         ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://172.168.2.21:2379 | 2cc5541313751d5d |  3.4.13 |  3.6 MB |      true |      false |        28 |       2288 |               2288 |        |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
{"level":"warn","ts":"2022-03-06T21:56:18.850+0800","caller":"clientv3/retry_interceptor.go:62","msg":"retrying of unary invoker failed","target":"passthrough:///https://172.168.2.22:2379","attempt":0,"error":"rpc error: code = DeadlineExceeded desc = latest balancer error: connection error: desc = \"transport: Error while dialing dial tcp 172.168.2.22:2379: connect: connection refused\""}
Failed to get the status of endpoint https://172.168.2.22:2379 (context deadline exceeded)
+----------+----+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| ENDPOINT | ID | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+----------+----+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
+----------+----+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|         ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://172.168.2.23:2379 | 27f8ddc0f1ae8387 |  3.4.13 |  3.6 MB |     false |      false |        28 |       2305 |               2305 |        |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+

root@k8s-master03:~# ETCDCTL_API=3 etcdctl member list		--获取成员ID，这里需要删除172.168.2.22节点，应此ID为b829b739e7a1b7aa
27f8ddc0f1ae8387, started, etcd-172.168.2.23, https://172.168.2.23:2380, https://172.168.2.23:2379, false
2cc5541313751d5d, started, etcd-172.168.2.21, https://172.168.2.21:2380, https://172.168.2.21:2379, false
b829b739e7a1b7aa, started, etcd-172.168.2.22, https://172.168.2.22:2380, https://172.168.2.22:2379, false

root@k8s-master03:~# ETCDCTL_API=3 etcdctl member remove b829b739e7a1b7aa	--删除故障etcd-172.168.2.22节点
Member b829b739e7a1b7aa removed from cluster c1c45dc3d77fe90d
root@k8s-master03:~# ETCDCTL_API=3 etcdctl member list
27f8ddc0f1ae8387, started, etcd-172.168.2.23, https://172.168.2.23:2380, https://172.168.2.23:2379, false
2cc5541313751d5d, started, etcd-172.168.2.21, https://172.168.2.21:2380, https://172.168.2.21:2379, false
root@k8s-master02:~# rm -rf /var/lib/etcd/*	--删除etcd-172.168.2.22的etcd数据目录
root@k8s-master03:~# ETCDCTL_API=3 etcdctl member add etcd-172.168.2.22 --peer-urls=https://172.168.2.22:2380	--在其它正常etcd节点添加故障节点
Member 416a25b135a72684 added to cluster c1c45dc3d77fe90d

ETCD_NAME="etcd-172.168.2.22"
ETCD_INITIAL_CLUSTER="etcd-172.168.2.23=https://172.168.2.23:2380,etcd-172.168.2.21=https://172.168.2.21:2380,etcd-172.168.2.22=https://172.168.2.22:2380"
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://172.168.2.22:2380"
ETCD_INITIAL_CLUSTER_STATE="existing"
--------------
root@k8s-master03:~# ETCDCTL_API=3 etcdctl member list
27f8ddc0f1ae8387, started, etcd-172.168.2.23, https://172.168.2.23:2380, https://172.168.2.23:2379, false
2cc5541313751d5d, started, etcd-172.168.2.21, https://172.168.2.21:2380, https://172.168.2.21:2379, false
416a25b135a72684, unstarted, , https://172.168.2.22:2380, , false

root@k8s-master02:~# vim /etc/systemd/system/etcd.service	--编辑故障etcd节点服务文件，配置name，initial-cluster，initial-advertise-peer-urls，initial-cluster-state四个参数跟添加故障节点步骤返回的值一样
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target
Documentation=https://github.com/coreos

[Service]
Type=notify
WorkingDirectory=/var/lib/etcd/
ExecStart=/usr/local/bin/etcd \
  --name=etcd-172.168.2.22 \
  --cert-file=/etc/kubernetes/ssl/etcd.pem \
  --key-file=/etc/kubernetes/ssl/etcd-key.pem \
  --peer-cert-file=/etc/kubernetes/ssl/etcd.pem \
  --peer-key-file=/etc/kubernetes/ssl/etcd-key.pem \
  --trusted-ca-file=/etc/kubernetes/ssl/ca.pem \
  --peer-trusted-ca-file=/etc/kubernetes/ssl/ca.pem \
  --initial-advertise-peer-urls=https://172.168.2.22:2380 \
  --listen-peer-urls=https://172.168.2.22:2380 \
  --listen-client-urls=https://172.168.2.22:2379,http://127.0.0.1:2379 \
  --advertise-client-urls=https://172.168.2.22:2379 \
  --initial-cluster-token=etcd-cluster-0 \
  --initial-cluster=etcd-172.168.2.21=https://172.168.2.21:2380,etcd-172.168.2.22=https://172.168.2.22:2380,etcd-172.168.2.23=https://172.168.2.23:2380 \
  --initial-cluster-state=existing \
  --data-dir=/var/lib/etcd \
  --wal-dir= \
  --snapshot-count=50000 \
  --auto-compaction-retention=1 \
  --auto-compaction-mode=periodic \
  --max-request-bytes=10485760 \
  --quota-backend-bytes=8589934592
Restart=always
RestartSec=15
LimitNOFILE=65536
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
-----------------
root@k8s-master02:~# systemctl daemon-reload
root@k8s-master02:~# systemctl start etcd		--启动etcd服务
root@k8s-master01:~# for ip in ${NODE_IPS}; do ETCDCTL_API=3 /usr/local/bin/etcdctl --endpoints=https://${ip}:2379 --cacert=/etc/kubernetes/ssl/ca.pem --cert=/etc/kubernetes/ssl/etcd.pem --key=/etc/kubernetes/ssl/etcd-key.pem --write-out=table endpoint status ; done		--此时成功同步加入
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|         ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://172.168.2.21:2379 | 2cc5541313751d5d |  3.4.13 |  3.6 MB |     false |      false |        40 |       9926 |               9926 |        |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|         ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://172.168.2.22:2379 | 416a25b135a72684 |  3.4.13 |  3.6 MB |     false |      false |        40 |       9926 |               9926 |        |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|         ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://172.168.2.23:2379 | 27f8ddc0f1ae8387 |  3.4.13 |  3.6 MB |      true |      false |        40 |       9926 |               9926 |        |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+





###5.6 模拟etcd灾难故障
root@k8s-master01:~/k8s# export NODE_IPS='172.168.2.21 172.168.2.22 172.168.2.23'
root@k8s-master01:~/k8s# for ip in ${NODE_IPS}; do ETCDCTL_API=3 /usr/local/bin/etcdctl --endpoints=https://${ip}:2379 --cacert=/etc/kubernetes/ssl/ca.pem --cert=/etc/kubernetes/ssl/etcd.pem --key=/etc/kubernetes/ssl/etcd-key.pem --write-out=table endpoint status ; done
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|         ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://172.168.2.21:2379 | 2cc5541313751d5d |  3.4.13 |  3.4 MB |      true |      false |         3 |     361566 |             361566 |        |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|         ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://172.168.2.22:2379 | b829b739e7a1b7aa |  3.4.13 |  3.6 MB |     false |      false |         3 |     361566 |             361566 |        |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|         ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://172.168.2.23:2379 | 27f8ddc0f1ae8387 |  3.4.13 |  3.6 MB |     false |      false |         3 |     361567 |             361567 |        |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
root@k8s-master01:~/k8s# ETCDCTL_API=3 /usr/local/bin/etcdctl get /magedu/linux
/magedu/linux
ubuntu
--停止etcd并删除目录模拟etcd故障
root@k8s-master01:~# systemctl stop etcd
root@k8s-master01:~# rm -rf /var/lib/etcd/member/
root@k8s-master02:~# systemctl stop etcd
root@k8s-master02:~# rm -rf /var/lib/etcd/
root@k8s-master03:~# kubectl get nodes		--此时两个etcd已经故障，就是整个etcd集群故障不可使用
Error from server: etcdserver: request timed out
root@k8s-master03:~# systemctl stop etcd
root@k8s-master03:~# rm -rf /var/lib/etcd/

--停止kube-apiserver/controller-manager/scheduler/kubelet/kube-proxy
root@k8s-master01:~# systemctl stop kube-apiserver.service kube-controller-manager.service kube-scheduler.service kube-proxy.service kubelet.service
root@k8s-master02:~# systemctl stop kube-apiserver.service kube-controller-manager.service kube-scheduler.service kube-proxy.service kubelet.service
root@k8s-master03:~# systemctl stop kube-apiserver.service kube-controller-manager.service kube-scheduler.service kube-proxy.service kubelet.service

--查看etcd快照信息
root@k8s-master01:~# etcdctl snapshot status etcd-20220306.db --write-out="table"
+----------+----------+------------+------------+
|   HASH   | REVISION | TOTAL KEYS | TOTAL SIZE |
+----------+----------+------------+------------+
| 83beedb0 |   286063 |       1156 |     3.6 MB |
+----------+----------+------------+------------+

--所有节点恢复同一份备份的数据到/var/lib/etcd中，参数可到/etc/systemd/system/etcd.service中查看
root@k8s-master01:~/k8s# ETCDCTL_API=3 etcdctl snapshot restore /root/etcd-20220306.db --data-dir=/var/lib/etcd --name=etcd-172.168.2.21 --initial-cluster=etcd-172.168.2.21=https://172.168.2.21:2380,etcd-172.168.2.22=https://172.168.2.22:2380,etcd-172.168.2.23=https://172.168.2.23:2380 --initial-cluster-token=etcd-cluster-0 --initial-advertise-peer-urls=https://172.168.2.21:2380

root@k8s-master02:~# ETCDCTL_API=3 etcdctl snapshot restore /root/etcd-20220306.db --data-dir=/var/lib/etcd --name=etcd-172.168.2.22 --initial-cluster=etcd-172.168.2.21=https://172.168.2.21:2380,etcd-172.168.2.22=https://172.168.2.22:2380,etcd-172.168.2.23=https://172.168.2.23:2380 --initial-cluster-token=etcd-cluster-0 --initial-advertise-peer-urls=https://172.168.2.22:2380 

root@k8s-master03:~# ETCDCTL_API=3 etcdctl snapshot restore /root/etcd-20220306.db --data-dir=/var/lib/etcd --name=etcd-172.168.2.23 --initial-cluster=etcd-172.168.2.21=https://172.168.2.21:2380,etcd-172.168.2.22=https://172.168.2.22:2380,etcd-172.168.2.23=https://172.168.2.23:2380 --initial-cluster-token=etcd-cluster-0 --initial-advertise-peer-urls=https://172.168.2.23:2380

--启用etcd服务
root@k8s-master01:~# systemctl start etcd
root@k8s-master02:~# systemctl start etcd
root@k8s-master03:~# systemctl start etcd

--检验状态，一主两从
root@k8s-master02:~# for ip in ${NODE_IPS}; do ETCDCTL_API=3 /usr/local/bin/etcdctl --endpoints=https://${ip}:2379 --cacert=/etc/kubernetes/ssl/ca.pem --cert=/etc/kubernetes/ssl/etcd.pem --key=/etc/kubernetes/ssl/etcd-key.pem endpoint health; done
https://172.168.2.21:2379 is healthy: successfully committed proposal: took = 11.746977ms
https://172.168.2.22:2379 is healthy: successfully committed proposal: took = 10.736969ms
https://172.168.2.23:2379 is healthy: successfully committed proposal: took = 11.008322ms

root@k8s-master02:~# for ip in ${NODE_IPS}; do ETCDCTL_API=3 /usr/local/bin/etcdctl --endpoints=https://${ip}:2379 --cacert=/etc/kubernetes/ssl/ca.pem --cert=/etc/kubernetes/ssl/etcd.pem --key=/etc/kubernetes/ssl/etcd-key.pem --write-out=table endpoint status ; done
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|         ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://172.168.2.21:2379 | 2cc5541313751d5d |  3.4.13 |  3.6 MB |     false |      false |        27 |         15 |                 15 |        |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|         ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://172.168.2.22:2379 | b829b739e7a1b7aa |  3.4.13 |  3.6 MB |      true |      false |        27 |         15 |                 15 |        |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|         ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://172.168.2.23:2379 | 27f8ddc0f1ae8387 |  3.4.13 |  3.6 MB |     false |      false |        27 |         15 |                 15 |        |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
root@k8s-master01:~/k8s# ETCDCTL_API=3 /usr/local/bin/etcdctl get /magedu/linux
/magedu/linux
ubuntu

--启动k8s服务
root@k8s-master01:~# systemctl start kube-apiserver.service kube-controller-manager.service kube-scheduler.service kube-proxy.service kubelet.service
root@k8s-master02:~# systemctl start kube-apiserver.service kube-controller-manager.service kube-scheduler.service kube-proxy.service kubelet.service
root@k8s-master03:~# systemctl start kube-apiserver.service kube-controller-manager.service kube-scheduler.service kube-proxy.service kubelet.service
注：启动后测试dashboard和coredns功能是否正常，经过测试是正常的



5.7 通过kubeasz来删除和添加etcd节点
--删除etcd节点
root@ansible:/etc/kubeasz# ./ezctl del-etcd k8s-01 172.168.2.21		--删除etcd节点
PLAY RECAP *****************************************************************************************************************************************************************************
172.168.2.21               : ok=8    changed=6    unreachable=0    failed=0
172.168.2.22               : ok=8    changed=6    unreachable=0    failed=0
172.168.2.23               : ok=8    changed=6    unreachable=0    failed=0
root@ansible:/etc/kubeasz# ./ezctl add-etcd k8s-01 172.168.2.21		--重新添加为etcd节点
PLAY RECAP *****************************************************************************************************************************************************************************
172.168.2.21               : ok=8    changed=6    unreachable=0    failed=0
172.168.2.22               : ok=8    changed=6    unreachable=0    failed=0
172.168.2.23               : ok=8    changed=6    unreachable=0    failed=0


5.8 KubernetesAPI简介
1. 命令式API
2. 声明式API
官方说API Server接收最多5000个node
资源对象：
LimitRange: 1. 限制容器  2. 限制pod  3. 限制名称空间
kubernetes现在版本支持ipvs和iptables，ipvs性能更好，当不支持ipvs的时候自动降级为iptables


5.9 dashboardtoken制作
root@k8s-master01:~/k8s# vim /root/.kube/config    #增加token到user中
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUR1RENDQXFDZ0F3SUJBZ0lVWTkvWDRUM3N6T0FsZktmbm1jV3I0MzdpdDUwd0RRWUpLb1pJaHZjTkFRRUwKQlFBd1lURUxNQWtHQTFVRUJoTUNRMDR4RVRBUEJnTlZCQWdUQ0VoaGJtZGFhRzkxTVFzd0NRWURWUVFIRXdKWQpVekVNTUFvR0ExVUVDaE1EYXpoek1ROHdEUVlEVlFRTEV3WlRlWE4wWlcweEV6QVJCZ05WQkFNVENtdDFZbVZ5CmJtVjBaWE13SUJjTk1qSXdNekEwTVRFeU1qQXdXaGdQTWpFeU1qQXlNRGd4TVRJeU1EQmFNR0V4Q3pBSkJnTlYKQkFZVEFrTk9NUkV3RHdZRFZRUUlFd2hJWVc1bldtaHZkVEVMTUFrR0ExVUVCeE1DV0ZNeEREQUtCZ05WQkFvVApBMnM0Y3pFUE1BMEdBMVVFQ3hNR1UzbHpkR1Z0TVJNd0VRWURWUVFERXdwcmRXSmxjbTVsZEdWek1JSUJJakFOCkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQTNtYm0zaHM3WlJ3WEdEUktkUW9rR25QVjVNbUQKYUEzNnpaZ0VXWUJNSkIvZDBOSEFkQkZDY1dLb3ArNUF2SFk3elBjeGdNelpRZ1B4TU9DcU9CS09NUVJYNG4ydApENmYxbUZrMzFNRDBEMXJGVTBXcGYwanRiampNMmNEOW5wU2trcmZ4dDliWlh2NHRHNFpDUlB4U1RJbkxDU0RkClVNYnN6OUFXVkZNamtnSndUa3FpU2NIZitod1FvOWZVdVduekZTWWdGUUppUWtWRVZqaGErYU5DK2oyUjNOQjUKN1hDS1RHMFBUNS9JVVFEL2t2V0doL0NoZEZUQmREV0plL0d4cnpkYlAxejRQbnBvSTBvaThDN1MwakErVlJKRApMcS9WcE5TY2d1WFB6ZXNPZSs3Tk9Ub0hwZURyVGJxTER5aVRMbEVWNmRWWG5ScE9tdG9XdjI2OU13SURBUUFCCm8yWXdaREFPQmdOVkhROEJBZjhFQkFNQ0FRWXdFZ1lEVlIwVEFRSC9CQWd3QmdFQi93SUJBakFkQmdOVkhRNEUKRmdRVXhxbndaUFpNTEZUeUhJVzNzcWNyaGJmZEl0QXdId1lEVlIwakJCZ3dGb0FVeHFud1pQWk1MRlR5SElXMwpzcWNyaGJmZEl0QXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBTFpndlVIOEh1SDRIYnJtUW80ejFOTWJKamZVCmlHaFYzdmpFRitIVHlhejByOU1HSlo5b1p3M2hpK0ZpUUJEaUFGSjNvTEVtWVEweDFLd2VlUnorQUlwOVV6QUEKaE5ETVB2YmlqTXl3b3JRNTdzN3BSWlMzejB5RHJ1MEh2R21WRkl6WjRzcm05TjZ2SnVORGUvbklBc0o5eitzbwpKN2doQ3k3Z0dqL2w5dXV2dmovNk8vNVJTVVc4WGE3NWZPR2ZESjFVdUdyemMzbE1mTkNwVUJwMFFXTXVtWHFRClJReHZuKzdRQWdQcitQRk9OLzZMSVkxYlZwNmkvUHhaZ2xjcHFnRjV4QUZ4VEFJYmRXdjVxTjVVQUNsWTFwOE8KVEwyeG9LQVdsQ1IydkdpVS8zbWJTZ2prd3JzRTRRZ3hweHdMdklUc2FNNWtINVF3YUMvalNIR0V3SlE9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0Kaaa
    server: https://172.168.2.21:6443
  name: cluster1
contexts:
- context:
    cluster: cluster1
    user: admin
  name: context-cluster1
current-context: context-cluster1
kind: Config
preferences: {}
users:
- name: admin
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUQxekNDQXIrZ0F3SUJBZ0lVYkRTc0dCeDZ1UEdLT2YxR1g5b1RKb1FmOEE0d0RRWUpLb1pJaHZjTkFRRUwKQlFBd1lURUxNQWtHQTFVRUJoTUNRMDR4RVRBUEJnTlZCQWdUQ0VoaGJtZGFhRzkxTVFzd0NRWURWUVFIRXdKWQpVekVNTUFvR0ExVUVDaE1EYXpoek1ROHdEUVlEVlFRTEV3WlRlWE4wWlcweEV6QVJCZ05WQkFNVENtdDFZbVZ5CmJtVjBaWE13SUJjTk1qSXdNekEwTVRNek5UQXdXaGdQTWpBM01qQXlNakF4TXpNMU1EQmFNR2N4Q3pBSkJnTlYKQkFZVEFrTk9NUkV3RHdZRFZRUUlFd2hJWVc1bldtaHZkVEVMTUFrR0ExVUVCeE1DV0ZNeEZ6QVZCZ05WQkFvVApEbk41YzNSbGJUcHRZWE4wWlhKek1ROHdEUVlEVlFRTEV3WlRlWE4wWlcweERqQU1CZ05WQkFNVEJXRmtiV2x1Ck1JSUJJakFOQmdrcWhraUc5dzBCQVFFRkFBT0NBUThBTUlJQkNnS0NBUUVBNDZNMkRia0VQLzNEM0dMYkppVUgKNUN3U2l6SkFCRHJxbE84ZWlMV3QweVZRczRzOEtDUHNBVmMwOTU0dVNJVkp3aUJrMkt6MlBhOHpIS1dNQ1BobAp0LzdaNzdwdytkUUVJeUVXT3p3aWdJKzZ6bW11YmpYWFRSZVFxb2ZHc3UrOEFvVU1Ya2NsczhualhrZjIvY3l2CnVWdmpyVUNDSkV0bjFvT0dhWmhTTUZoRi93TEJpaFVOTEZsb1lmbWNTSGZZSThkVEhZWklLaUk5SUNZY2JCWDEKbFBKMEE1bmpNdUk3dHhDSklpSHJiM3dvaEVsNVdkcmhkWDJFcTR0Rjc1ckJ0YjF6Q0RoczlITmswU0NqTmxpQgowNmI1K2ZnVXUwKzZKY1RtY3o1aGxmaTJJa3hFZkova3EzaGtTaGJCandhK09wZGJ6NEV6bmFPUURLaFNkbDV2Ckh3SURBUUFCbzM4d2ZUQU9CZ05WSFE4QkFmOEVCQU1DQmFBd0hRWURWUjBsQkJZd0ZBWUlLd1lCQlFVSEF3RUcKQ0NzR0FRVUZCd01DTUF3R0ExVWRFd0VCL3dRQ01BQXdIUVlEVlIwT0JCWUVGS0RKeGJXZy9VNlpUZ1pwZzIwVwpTbXFTZGVZek1COEdBMVVkSXdRWU1CYUFGTWFwOEdUMlRDeFU4aHlGdDdLbks0VzMzU0xRTUEwR0NTcUdTSWIzCkRRRUJDd1VBQTRJQkFRQW4ra2hYUGM3MGFmaWptWEYvSnJJanZWWk9DODRHZGhoVzlzK091K2hPOWtMT3BaaVUKRXlHMGw4UWxCa3g5UXRwT0gxQytTS2w5OFZWYkxEdk9rQlI5NmRONHNVTEZRaUJqZDRoN2ozS0FhRkhGQkh4ZQpEMmhrRk5YMTVIU1FWNzc1RXVkMTRxTndKYkluN2hNUlgzeERMblZzM3FPWmFuN3F3KzNtVzVFOWVIbEVTS0dnCnl6L3NPRm1vNWpCNDdyMUFFYTArS1QvUUhJNWpUS3B1aGpEcGM2Yjlqc3NyUUVoNGIvTXVqZG16d1hWbDVHSmEKMlJxWk4rRlJvV1M1MnNWd0xsVG0vY0M4UjlIN1pKNE8rNnNSVFRiTFlBZ2hQQjVmdUd3RkY2OXdrbWZEOCtBMApTWE1LNHkrdllCaEV2ZjVVV3lSZXN1SXdEQVZGVXRzVGhIbEMKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=ccc
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBNDZNMkRia0VQLzNEM0dMYkppVUg1Q3dTaXpKQUJEcnFsTzhlaUxXdDB5VlFzNHM4CktDUHNBVmMwOTU0dVNJVkp3aUJrMkt6MlBhOHpIS1dNQ1BobHQvN1o3N3B3K2RRRUl5RVdPendpZ0krNnptbXUKYmpYWFRSZVFxb2ZHc3UrOEFvVU1Ya2NsczhualhrZjIvY3l2dVZ2anJVQ0NKRXRuMW9PR2FaaFNNRmhGL3dMQgppaFVOTEZsb1lmbWNTSGZZSThkVEhZWklLaUk5SUNZY2JCWDFsUEowQTVuak11STd0eENKSWlIcmIzd29oRWw1CldkcmhkWDJFcTR0Rjc1ckJ0YjF6Q0RoczlITmswU0NqTmxpQjA2YjUrZmdVdTArNkpjVG1jejVobGZpMklreEUKZkova3EzaGtTaGJCandhK09wZGJ6NEV6bmFPUURLaFNkbDV2SHdJREFRQUJBb0lCQVFEZDBjNzhkRXYxNTF5UwpSeXB4OHlmTGFqN3ZzUm04aFlUTmVHMXlua2N5TjJ4NmFMVklFQ2tMN1dUSjNqUVBxd0tDem5vMndlUjVtMTNkCkRseDA2VWlGa1N2aGRQWmVIQUdrRWJ2T0lQMGw5ZWo4OXZKb3BzS1VkdUFickk4dEVudE1vVVc2SU81V1VlYmoKbXBET0pFVWdCTERKeE5DTWVZWkgvSVpnSTNRRGNrb1RCWXJHR2pzQ096UUNQS3dTRG5ZYlFTM2IzcUtBZnVMYwpUNjczdnZPUFZWV1ROc3l4cExId2xWcFpZUWFCS09DVXZxdk81V05Xdmp2Q3NFeW85TjJxZmlVaDJqUk1ETzEwCnp0WnEvRWJ4NGxSaDMvcGYzcEVHK0lmK21JN2VYOCtjV0ZRYUxCZk1xTjd1UG5OOWsrUll6Nk8zWnVMcm9zN08KWkNiVWh0cWhBb0dCQVArdXdDaUNyMndIMlNsbzFYK0Z1VEh2SDFHamtydDE5UkJiMzlqMHdyNnJrMUMvYU13Ngp5bHgwdmg3WXRKWmc4NXJHTzFxV0lraWdyc21yNndQL3d2UzBmcUwza09qdm9ZUnBEV1dpRCtVaStSZTZlbzZRClZ2WGFNNmNvRmNCUm9taHhWVkFTVXRiZDJRQ3pIS2Zrb0trRm0yUStONWhtdTV3eW15SisvTk1wQW9HQkFPUHIKakd2NUlWVnhCbTRzV0VGcnZTNXgwS1FVSzRBelNQVVU4ME54d055WWdYVEVsa3ppTTFNeElyMmJpTjAwb2xCegpwbE4rOTlJRW45WFlRTHYwZUlseUhRMnZtWWh2Y2VFclU3WHRiTkdEOGhnQzJKdUV2TTlXTzIwajB0ejN5eGx4CkpiV3p0dW9QSXg5cUR2NlBIay80aXI2c05RaGNGMkdNS09QbFJZRUhBb0dBRGRHT0JTSjdCS1d2OFBML2h2TGQKUFh1ay82Nk5nYUF3YkgvcXF6a2ZSVnJValdxcTZVN01IUThhTDJTYTdmMnpiTXdGN1RGc0RPelNSWWdMSFo0MwpGUzZrSVg2cjBFc1RPYXJMMUpCYnQ1Q2FVZFA4UjdRNVh2UTZFbkN5TEVDOVBGUFR2bzRlK0FucGJvWS9xRHROCkM1V0gvblQyWUVBOUo0WDhxSEtnaTNFQ2dZRUFvQ25ZcGMrT1V5SjM2RmdWTlBQbkg0b3ZtZjNxaTg1K1NHdU8KZnlpaTVPSHVwd1cyc1JTTUNMd1FzN2xtdGp2VWpFQ1k4emZZSXFmSlFsY1ROb0dYYXM3Y0I5QU1Ua295ZG84aAo1a2lRSGJOaEh1cHhHT2h3WGlzMDIzOC9JTFNvN3BvS2ErTjhlSUptcGg2N3Byc2dEQWFXU1dOdWFROStCcmlkCnkzaEVIV1VDZ1lCTnpRR2Q0ZTNEcmJuTmN0SXhBZVFydW9qTzhPYnl1UzRIOVNsd250eUxUTDU2eWRKMFk5NFoKMDlDZFZHZW5MYjFsWVZQcnVmakZMQ3ZWMFAxVSsrZE53R2FETWhkVFFOVWErUnFUNmpYUnR6dlRHTFlzMmM5bQpsZGU3WUt4WFdITDBkSkRCQ29kSWllMlk3N01QQVBzYmJmdnBXTnk5eW9GMnY4ZWZGb3dpMEE9PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=bbb
    token: eyJhbGciOiJSUzI1NiIsImtpZCI6ImQ3UV9STlJ4TEpQRS1XWmNHblFmaHJOUmdUaW5jMVJvSERqeE9VajR1LWcifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyLXRva2VuLW00ZHBoIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI3ZTY3OTZjMS04NDcxLTRkYWItODU3Mi1hODg2YmY4NWQyZGUiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZXJuZXRlcy1kYXNoYm9hcmQ6YWRtaW4tdXNlciJ9.vetemWR84jzBdD4akQPvk3gKFNuxMpF4e0THKY3vmQ77wLEOOyxI7KWolTU6qYQAh11t-cTa4H0gtlvvQwA_IBBuYrl6sSDpFrAQhrD9AaAW2mcMb2ocXs70T-okZwTgginIaB4Yhes7psqI1NG9aHDbKDkk1ECg62ou96QKNOKgtXc1lfcpPRJHbP0j8sg3JGvXIsg4F5TAUjPkEu4lNQr8bKrPvTheqqQF2JphoOQObZ9J1AbKpinBrZlSD7QxEVJwCa4Q-T-hLr93Y1epbesJ6blna7MfCyX9y-qqqJ6mtgWoLlNNUhsGIgJ1sWeTDZli5lwU1INATLGkmlYglA

	
	
6.0 基于PV和PVC运行 zookeeper集群
root@k8s-master01:~/k8s/dockerfile/zookeeper# docker pull elevy/slim_java:8
root@k8s-master01:~/k8s/dockerfile/zookeeper# docker tag elevy/slim_java:8 192.168.13.197:8000/baseimages/slim_java:8
root@k8s-master01:~/k8s/dockerfile/zookeeper# docker push 192.168.13.197:8000/baseimages/slim_java:8

server.1=zk1-service:2888:3888
server.2=zk2-service:2888:3888
server.3=zk3-service:2888:3888
注：2888端口谁为Leader谁监听，3888为每个zookeeper节点的集群端口
1.优先对比事务 id，谁大谁为leader，集群刚开始是没有事务ID的，所以得看第二步
2.对比server id，谁的server id谁就是leader

----------zookeeper Dockerfile---------------
root@k8s-master01:~/k8s/dockerfile/zookeeper# cat Dockerfile
#FROM harbor-linux38.local.com/linux38/slim_java:8
FROM 192.168.13.197:8000/baseimages/slim_java:8

ENV ZK_VERSION 3.4.14
ADD repositories /etc/apk/repositories
# Download Zookeeper
COPY zookeeper-3.4.14.tar.gz /tmp/zk.tgz
COPY zookeeper-3.4.14.tar.gz.asc /tmp/zk.tgz.asc
COPY KEYS /tmp/KEYS
RUN apk add --no-cache --virtual .build-deps \
      ca-certificates   \
      gnupg             \
      tar               \
      wget &&           \
    #
    # Install dependencies
    apk add --no-cache  \
      bash &&           \
    #
    #
    # Verify the signature
    export GNUPGHOME="$(mktemp -d)" && \
    gpg -q --batch --import /tmp/KEYS && \
    gpg -q --batch --no-auto-key-retrieve --verify /tmp/zk.tgz.asc /tmp/zk.tgz && \
    #
    # Set up directories
    #
    mkdir -p /zookeeper/data /zookeeper/wal /zookeeper/log && \
    #
    # Install
    tar -x -C /zookeeper --strip-components=1 --no-same-owner -f /tmp/zk.tgz && \
    #
    # Slim down
    cd /zookeeper && \
    cp dist-maven/zookeeper-${ZK_VERSION}.jar . && \
    rm -rf \
      *.txt \
      *.xml \
      bin/README.txt \
      bin/*.cmd \
      conf/* \
      contrib \
      dist-maven \
      docs \
      lib/*.txt \
      lib/cobertura \
      lib/jdiff \
      recipes \
      src \
      zookeeper-*.asc \
      zookeeper-*.md5 \
      zookeeper-*.sha1 && \
    #
    # Clean up
    apk del .build-deps && \
    rm -rf /tmp/* "$GNUPGHOME"

COPY conf /zookeeper/conf/
COPY bin/zkReady.sh /zookeeper/bin/
COPY entrypoint.sh /

ENV PATH=/zookeeper/bin:${PATH} \
    ZOO_LOG_DIR=/zookeeper/log \
    ZOO_LOG4J_PROP="INFO, CONSOLE, ROLLINGFILE" \
    JMXPORT=9010

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "zkServer.sh", "start-foreground" ]

EXPOSE 2181 2888 3888 9010
--------zookeeper endpoint.sh----------
root@k8s-master01:~/k8s/dockerfile/zookeeper# cat entrypoint.sh
#!/bin/bash

echo ${MYID:-1} > /zookeeper/data/myid

if [ -n "$SERVERS" ]; then
        IFS=\, read -a servers <<<"$SERVERS"
        for i in "${!servers[@]}"; do
                printf "\nserver.%i=%s:2888:3888" "$((1 + $i))" "${servers[$i]}" >> /zookeeper/conf/zoo.cfg
        done
fi

cd /zookeeper
exec "$@"
----------zookeeper yaml-----------
root@k8s-master01:~/k8s/yaml/zookeeper# cat zookeeper.yaml
apiVersion: v1
kind: Service
metadata:
  name: zookeeper
  namespace: magedu
spec:
  ports:
    - name: client
      port: 2181
  selector:
    app: zookeeper
---
apiVersion: v1
kind: Service
metadata:
  name: zookeeper1
  namespace: magedu
spec:
  type: NodePort
  ports:
    - name: client
      port: 2181
      nodePort: 42181
    - name: followers
      port: 2888
    - name: election
      port: 3888
  selector:
    app: zookeeper
    server-id: "1"
---
apiVersion: v1
kind: Service
metadata:
  name: zookeeper2
  namespace: magedu
spec:
  type: NodePort
  ports:
    - name: client
      port: 2181
      nodePort: 42182
    - name: followers
      port: 2888
    - name: election
      port: 3888
  selector:
    app: zookeeper
    server-id: "2"
---
apiVersion: v1
kind: Service
metadata:
  name: zookeeper3
  namespace: magedu
spec:
  type: NodePort
  ports:
    - name: client
      port: 2181
      nodePort: 42183
    - name: followers
      port: 2888
    - name: election
      port: 3888
  selector:
    app: zookeeper
    server-id: "3"
---
kind: Deployment
#apiVersion: extensions/v1beta1
apiVersion: apps/v1
metadata:
  name: zookeeper1
  namespace: magedu
spec:
  replicas: 1
  selector:
    matchLabels:
      app: zookeeper
  template:
    metadata:
      labels:
        app: zookeeper
        server-id: "1"
    spec:
      volumes:
        - name: data
          emptyDir: {}
        - name: wal
          emptyDir:
            medium: Memory
      containers:
        - name: server
          image: 192.168.13.197:8000/magedu/zookeeper:zk3414_202203231223
          #imagePullPolicy: Always
          imagePullPolicy: IfNotPresent
          env:
            - name: MYID
              value: "1"
            - name: SERVERS
              value: "zookeeper1,zookeeper2,zookeeper3"
            - name: JVMFLAGS
              value: "-Xmx2G"
          ports:
            - containerPort: 2181
            - containerPort: 2888
            - containerPort: 3888
          volumeMounts:
          - mountPath: "/zookeeper/data"
            name: zookeeper-datadir-pvc-1
      volumes:
        - name: zookeeper-datadir-pvc-1
          persistentVolumeClaim:
            claimName: zookeeper-datadir-pvc-1
---
kind: Deployment
#apiVersion: extensions/v1beta1
apiVersion: apps/v1
metadata:
  name: zookeeper2
  namespace: magedu
spec:
  replicas: 1
  selector:
    matchLabels:
      app: zookeeper
  template:
    metadata:
      labels:
        app: zookeeper
        server-id: "2"
    spec:
      volumes:
        - name: data
          emptyDir: {}
        - name: wal
          emptyDir:
            medium: Memory
      containers:
        - name: server
          image: 192.168.13.197:8000/magedu/zookeeper:zk3414_202203231223
          #imagePullPolicy: Always
          imagePullPolicy: IfNotPresent
          env:
            - name: MYID
              value: "2"
            - name: SERVERS
              value: "zookeeper1,zookeeper2,zookeeper3"
            - name: JVMFLAGS
              value: "-Xmx2G"
          ports:
            - containerPort: 2181
            - containerPort: 2888
            - containerPort: 3888
          volumeMounts:
          - mountPath: "/zookeeper/data"
            name: zookeeper-datadir-pvc-2
      volumes:
        - name: zookeeper-datadir-pvc-2
          persistentVolumeClaim:
            claimName: zookeeper-datadir-pvc-2
---
kind: Deployment
#apiVersion: extensions/v1beta1
apiVersion: apps/v1
metadata:
  name: zookeeper3
  namespace: magedu
spec:
  replicas: 1
  selector:
    matchLabels:
      app: zookeeper
  template:
    metadata:
      labels:
        app: zookeeper
        server-id: "3"
    spec:
      volumes:
        - name: data
          emptyDir: {}
        - name: wal
          emptyDir:
            medium: Memory
      containers:
        - name: server
          image: 192.168.13.197:8000/magedu/zookeeper:zk3414_202203231223
          #imagePullPolicy: Always
          imagePullPolicy: IfNotPresent
          env:
            - name: MYID
              value: "3"
            - name: SERVERS
              value: "zookeeper1,zookeeper2,zookeeper3"
            - name: JVMFLAGS
              value: "-Xmx2G"
          ports:
            - containerPort: 2181
            - containerPort: 2888
            - containerPort: 3888
          volumeMounts:
          - mountPath: "/zookeeper/data"
            name: zookeeper-datadir-pvc-3
      volumes:
        - name: zookeeper-datadir-pvc-3
          persistentVolumeClaim:
           claimName: zookeeper-datadir-pvc-3
-----------------------------------
windows zookeeper客户端：https://github.com/vran-dev/PrettyZoo/releases/download/v1.9.5/prettyZoo-win.msi
安装好zookeeper客户端后，可以连接zookeeper NodePort端口进行连接进行测试


6.1 构建基础镜像，业务镜像等，并推送到镜像仓库，实现nginx+tomcat动静分离
NodePort --> nginx Service --> nginx --> 代理至后端tomcat，静态资源代理至本地NFS挂载目录


6.2 结合ceph实现web数据持久化
k8s在使用ceph作为动态存储卷的时候，需要kube-controller-manager组件能够访问ceph，因此需要在包括k8s master及node节点在内的每一个node同步认证文件。
ceph认证两种方式：
一：通过ceph认证文件放到宿主机目录，keyring
二：通过K8S secret实现认证
6.2.1 创建初始化rbd
ceph@ansible:~$ ceph osd pool create shijie-rbd-pool1 16 16
pool 'shijie-rbd-pool1' created

ceph@ansible:~$ ceph osd pool application enable shijie-rbd-pool1 rbd
enabled application 'rbd' on pool 'shijie-rbd-pool1'

ceph@ansible:~$ rbd pool init -p shijie-rbd-pool1
6.2.2 创建image
ceph@ansible:~$ rbd create shijie-img-img1 --size 3G --pool shijie-rbd-pool1 --image-format 2 --image-feature layering
ceph@ansible:~$ rbd ls --pool shijie-rbd-pool1		#列出image
shijie-img-img1
ceph@ansible:~$ rbd --image shijie-img-img1 --pool shijie-rbd-pool1 info	#只要看特性，不要开太多，挂太多内核太低挂载不上
rbd image 'shijie-img-img1':
        size 3 GiB in 768 objects
        order 22 (4 MiB objects)
        snapshot_count: 0
        id: d3ff221f6940
        block_name_prefix: rbd_data.d3ff221f6940
        format: 2
        features: layering
        op_features:
        flags:
        create_timestamp: Wed Mar 23 20:29:22 2022
        access_timestamp: Wed Mar 23 20:29:22 2022
        modify_timestamp: Wed Mar 23 20:29:22 2022

6.2.3 客户端安装ceph-common:
--分别在k8s master和node节点安装ceph-common组件包
root@ansible:~# ansible '~172.168.2.2[123456]' -m shell -a ' apt install -y gnupg ca-certificates'
root@ansible:~# ansible '~172.168.2.2[123456]' -m shell -a "wget -q -O- 'https://mirrors.tuna.tsinghua.edu.cn/ceph/keys/release.asc' | sudo apt-key add -"
root@ansible:~# ansible '~172.168.2.2[123456]' -m shell -a 'sudo echo "deb https://mirrors.tuna.tsinghua.edu.cn/ceph/debian-pacific bionic main ">> /etc/apt/sources.list.d/ceph.list'
root@ansible:~# ansible '~172.168.2.2[123456]' -m shell -a 'sudo apt update'
--各节点安装和当前ceph集群相同版本的ceph-common
root@k8s-master01:~/k8s/dockerfile/web/magedu/tomcat-app1# apt-cache madison ceph-common
ceph-common | 16.2.7-1bionic | https://mirrors.tuna.tsinghua.edu.cn/ceph/debian-pacific bionic/main amd64 Packages
ceph-common | 12.2.13-0ubuntu0.18.04.10 | http://mirrors.aliyun.com/ubuntu bionic-security/main amd64 Packages
ceph-common | 12.2.13-0ubuntu0.18.04.10 | http://mirrors.aliyun.com/ubuntu bionic-updates/main amd64 Packages
ceph-common | 12.2.4-0ubuntu1 | http://mirrors.aliyun.com/ubuntu bionic/main amd64 Packages
      ceph | 12.2.4-0ubuntu1 | http://mirrors.aliyun.com/ubuntu bionic/main Sources
      ceph | 12.2.13-0ubuntu0.18.04.10 | http://mirrors.aliyun.com/ubuntu bionic-security/main Sources
      ceph | 12.2.13-0ubuntu0.18.04.10 | http://mirrors.aliyun.com/ubuntu bionic-updates/main Sources
root@ansible:~# ansible '~172.168.2.2[123456]' -m shell -a 'apt install -y ceph-common=16.2.7-1bionic'
root@ansible:~# ansible '~172.168.2.2[123456]' -m shell -a 'dpkg -l | grep ceph-common'
172.168.2.24 | SUCCESS | rc=0 >>
ii  ceph-common                            16.2.7-1bionic                                  amd64        common utilities to mount and interact with a ceph storage cluster
ii  python3-ceph-common                    16.2.7-1bionic                                  all          Python 3 utility libraries for Ceph

172.168.2.26 | SUCCESS | rc=0 >>
ii  ceph-common                            16.2.7-1bionic                                  amd64        common utilities to mount and interact with a ceph storage cluster
ii  python3-ceph-common                    16.2.7-1bionic                                  all          Python 3 utility libraries for Ceph

172.168.2.23 | SUCCESS | rc=0 >>
ii  ceph-common                            16.2.7-1bionic                                  amd64        common utilities to mount and interact with a ceph storage cluster
ii  python3-ceph-common                    16.2.7-1bionic                                  all          Python 3 utility libraries for Ceph

172.168.2.21 | SUCCESS | rc=0 >>
ii  ceph-common                            16.2.7-1bionic                                  amd64        common utilities to mount and interact with a ceph storage cluster
ii  python3-ceph-common                    16.2.7-1bionic                                  all          Python 3 utility libraries for Ceph

172.168.2.25 | SUCCESS | rc=0 >>
ii  ceph-common                            16.2.7-1bionic                                  amd64        common utilities to mount and interact with a ceph storage cluster
ii  python3-ceph-common                    16.2.7-1bionic                                  all          Python 3 utility libraries for Ceph

172.168.2.22 | SUCCESS | rc=0 >>
ii  ceph-common                            16.2.7-1bionic                                  amd64        common utilities to mount and interact with a ceph storage cluster
ii  python3-ceph-common                    16.2.7-1bionic                                  all          Python 3 utility libraries for Ceph
--centos7 node04安装ceph-common
[root@k8s-node04 yum.repos.d]# wget https://mirrors.aliyun.com/ceph/rpm-octopus/el7/noarch/ceph-release-1-1.el7.noarch.rpm -P /root/
[root@k8s-node04 ~]# rpm -qlp ceph-release-1-1.el7.noarch.rpm
/etc/yum.repos.d/ceph.repo
[root@k8s-node04 ~]# rpm -ivh ceph-release-1-1.el7.noarch.rpm
[root@k8s-node04 ~]# sed -i 's#download.ceph.com#mirrors.tuna.tsinghua.edu.cn/ceph#g' /etc/yum.repos.d/ceph.repo
[root@k8s-node04 ~]# cat /etc/yum.repos.d/ceph.repo
[Ceph]
name=Ceph packages for $basearch
baseurl=http://mirrors.tuna.tsinghua.edu.cn/ceph/rpm-octopus/el7/$basearch
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://mirrors.tuna.tsinghua.edu.cn/ceph/keys/release.asc

[Ceph-noarch]
name=Ceph noarch packages
baseurl=http://mirrors.tuna.tsinghua.edu.cn/ceph/rpm-octopus/el7/noarch
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://mirrors.tuna.tsinghua.edu.cn/ceph/keys/release.asc

[ceph-source]
name=Ceph source packages
baseurl=http://mirrors.tuna.tsinghua.edu.cn/ceph/rpm-octopus/el7/SRPMS
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://mirrors.tuna.tsinghua.edu.cn/ceph/keys/release.asc
---
[root@k8s-node04 ~]# yum install epel-release -y
[root@k8s-node04 ~]# yum install ceph-common -y

6.2.4 创建ceph用户与授权
ceph@ansible:~/ceph-cluster$ ceph auth get-or-create client.magedu-shijie mon 'allow r' osd 'allow * pool=shijie-rbd-pool1'
[client.magedu-shijie]
        key = AQDmHTtiJOaEEhAAvsD/ifbfUf2GFFf9F+XVHg==
ceph@ansible:~/ceph-cluster$ ceph auth get client.magedu-shijie
[client.magedu-shijie]
        key = AQDmHTtiJOaEEhAAvsD/ifbfUf2GFFf9F+XVHg==
        caps mon = "allow r"
        caps osd = "allow * pool=shijie-rbd-pool1"
exported keyring for client.magedu-shijie
ceph@ansible:~/ceph-cluster$ ceph auth get client.magedu-shijie -o ceph.client.magedu-shijie.keyring	#认证信息导致出文件
exported keyring for client.magedu-shijie
ceph@ansible:~/ceph-cluster$ cat ceph.client.magedu-shijie.keyring
[client.magedu-shijie]
        key = AQDmHTtiJOaEEhAAvsD/ifbfUf2GFFf9F+XVHg==
        caps mon = "allow r"
        caps osd = "allow * pool=shijie-rbd-pool1"

6.2.5 如果通过ceph认证文件进行认证，需要将相关文件复制到节点/etc/ceph/目录下
root@ansible:~# cd /var/lib/ceph/ceph-cluster/
root@ansible:/var/lib/ceph/ceph-cluster# ansible k8s -m copy -a 'src=ceph.conf dest=/etc/ceph/'
root@ansible:/var/lib/ceph/ceph-cluster# ansible k8s -m copy -a 'src=ceph.client.magedu-shijie.keyring dest=/etc/ceph/'
--节点测试ceph
root@k8s-master01:~# rbd --id magedu-shijie ls --pool=shijie-rbd-pool1
shijie-img-img1
[root@k8s-node04 ~]# rbd --id magedu-shijie ls --pool=shijie-rbd-pool1
shijie-img-img1

6.2.6 k8s节点配置主机名解析
root@ansible:~# cat /etc/hosts
127.0.0.1       localhost

172.168.2.11 ansible
172.168.2.21 master01
172.168.2.22 master02
172.168.2.23 master03
172.168.2.24 node01
172.168.2.25 node02
172.168.2.26 node03
192.168.13.63 node04

172.168.2.27 ceph01
172.168.2.28 ceph02
172.168.2.29 ceph03
172.168.2.11 ceph-deploy
-----
root@ansible:~# ansible k8s -m copy -a 'src=/etc/hosts dest=/etc/hosts'

6.2.7 通过keyring文件挂载rbd
root@k8s-master01:~/k8s/yaml/ceph-case# cat case1-busybox-keyring.yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox
  namespace: default
spec:
  #nodeName: '172.168.2.26'
  containers:
  - image: busybox
    command:
      - sleep
      - "3600"
    imagePullPolicy: Always
    name: busybox
    #restartPolicy: Always
    volumeMounts:
    - name: rbd-data1
      mountPath: /data
  volumes:
    - name: rbd-data1
      rbd:
        monitors:
        - '172.168.2.27:6789'
        - '172.168.2.28:6789'
        - '172.168.2.29:6789'
        pool: shijie-rbd-pool1
        image: shijie-img-img1
        fsType: ext4
        readOnly: false
        user: magedu-shijie
        keyring: /etc/ceph/ceph.client.magedu-shijie.keyring
注：node04主机是centos7系统，内核是3.10，挂载不上，经过内核升级为5.4后可以挂载上。但是机器太旧，后面又挂载不上。
root@k8s-master01:~/k8s/yaml/ceph-case# kubectl apply -f case1-busybox-keyring.yaml
root@k8s-master01:~/k8s/yaml/ceph-case# kubectl get pod -o wide
NAME      READY   STATUS    RESTARTS   AGE   IP              NODE            NOMINATED NODE   READINESS GATES
busybox   1/1     Running   0          66s   172.20.217.78   192.168.13.63   <none>           <none>
root@k8s-master01:~/k8s/yaml/ceph-case# kubectl exec -it busybox sh
/ # df -h | grep rbd
/dev/rbd0                 2.9G      9.0M      2.9G   0% /data
/ # echo 'magedu' >> /data/n56.txt	#可进行读写
/ # cat /data/n56.txt
magedu
[root@k8s-node04 ~]# df -TH | grep rbd		#其实是node04节点宿主机进行挂载，pod使用的是宿主机的内核
/dev/rbd0                                              ext4      3.2G  9.5M  3.1G   1% /var/lib/kubelet/plugins/kubernetes.io/rbd/mounts/shijie-rbd-pool1-image-shijie-img-img1
[root@k8s-node04 ~]# rbd showmapped
id  pool              namespace  image            snap  device
0   shijie-rbd-pool1             shijie-img-img1  -     /dev/rbd0
root@k8s-master01:~/k8s/yaml/ceph-case# kubectl delete -f case1-busybox-keyring.yaml	#先删除这个yaml，因为rbd只能挂载一个容器

--使用nginx挂载rbd
root@k8s-master01:~/k8s/yaml/ceph-case# cat case2-nginx-keyring.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
  selector:
    matchLabels: #rs or deployment
      app: ng-deploy-80
  template:
    metadata:
      labels:
        app: ng-deploy-80
    spec:
	  #nodeName: '172.168.2.26'
      containers:
      - name: ng-deploy-80
        image: nginx
        ports:
        - containerPort: 80
        volumeMounts:
        - name: rbd-data1
          mountPath: /data
      volumes:
        - name: rbd-data1
          rbd:
            monitors:
            - '172.168.2.27:6789'
            - '172.168.2.28:6789'
            - '172.168.2.29:6789'
            pool: shijie-rbd-pool1
            image: shijie-img-img1
            fsType: ext4
            readOnly: false
            user: magedu-shijie
            keyring: /etc/ceph/ceph.client.magedu-shijie.keyring
root@k8s-master01:~/k8s/yaml/ceph-case# kubectl apply -f case2-nginx-keyring.yaml

6.2.8 使用secret挂载k8s
6.2.8.1
--将ceph认证key用base64加密，然后写入到k8s secret中
root@k8s-master01:~# cat /etc/ceph/ceph.client.magedu-shijie.keyring
[client.magedu-shijie]
        key = AQDmHTtiJOaEEhAAvsD/ifbfUf2GFFf9F+XVHg==
        caps mon = "allow r"
        caps osd = "allow * pool=shijie-rbd-pool1"
root@k8s-master01:~# cat /etc/ceph/ceph.client.magedu-shijie.keyring | grep key | awk -F' ' '{print $3}' | tr -d ' ' | base64
QVFEbUhUdGlKT2FFRWhBQXZzRC9pZmJmVWYyR0ZGZjlGK1hWSGc9PQo=
root@k8s-master01:~/k8s/yaml/ceph-case# cat case3-secret-client-shijie.yaml
apiVersion: v1
kind: Secret
metadata:
  name: ceph-secret-magedu-shijie
type: "kubernetes.io/rbd"
data:
  key: QVFEbUhUdGlKT2FFRWhBQXZzRC9pZmJmVWYyR0ZGZjlGK1hWSGc9PQo=						#此key是经过base64加密的
root@k8s-master01:~/k8s/yaml/ceph-case# kubectl apply -f case3-secret-client-shijie.yaml
root@k8s-master01:~/k8s/yaml/ceph-case# kubectl get secret
NAME                        TYPE                                  DATA   AGE
ceph-secret-magedu-shijie   kubernetes.io/rbd                     1      5s
default-token-qghvn         kubernetes.io/service-account-token   3      19d
root@k8s-master01:~/k8s/yaml/ceph-case# kubectl get secret ceph-secret-magedu-shijie -o yaml | grep key:
  key: QVFEbUhUdGlKT2FFRWhBQXZzRC9pZmJmVWYyR0ZGZjlGK1hWSGc9PQo=
6.2.8.2 仓库pod使用secret进行挂载ceph
root@k8s-master01:~/k8s/yaml/ceph-case# cat case4-nginx-secret.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
  selector:
    matchLabels: #rs or deployment
      app: ng-deploy-80
  template:
    metadata:
      labels:
        app: ng-deploy-80
    spec:
	  #nodeName: '172.168.2.26'			#前面使用centos7旧机器测试挂载不上，所以使用ubuntu虚拟机挂载
      containers:
      - name: ng-deploy-80
        image: nginx
        ports:
        - containerPort: 80
        volumeMounts:
        - name: rbd-data1
          mountPath: /data
      volumes:
        - name: rbd-data1
          rbd:
            monitors:
            - '172.168.2.27:6789'
            - '172.168.2.28:6789'
            - '172.168.2.29:6789'
            pool: shijie-rbd-pool1
            image: shijie-img-img1
            fsType: ext4
            readOnly: false
            user: magedu-shijie
            secretRef:
              name: ceph-secret-magedu-shijie			#使用刚才创建的secret进行认证ceph
root@k8s-master01:~/k8s/yaml/ceph-case# kubectl apply -f case4-nginx-secret.yaml	  
			  
			  
6.2.9 动态创建存储卷			  
6.2.9.1 创建secret
--创建普通用户的secret，给pod挂载使用
root@k8s-master01:~/k8s/yaml/ceph-case# kubectl apply -f case3-secret-client-shijie.yaml
--创建admin的secret，我们要去ceph做操作，需要ceph管理员权限，通过k8s master进行连ceph进行管理，所以master也要装ceph-common
ceph@ansible:~/ceph-cluster$ cat ceph.client.admin.keyring
[client.admin]
        key = AQCCVTBi8iofJxAAuyX9tKr38EPErNhBnNeG6A==
        caps mds = "allow *"
        caps mgr = "allow *"
        caps mon = "allow *"
        caps osd = "allow *"
ceph@ansible:~/ceph-cluster$ cat ceph.client.admin.keyring | grep key | awk -F' ' '{print $3}' | tr -d ' ' | base64
QVFDQ1ZUQmk4aW9mSnhBQXV5WDl0S3IzOEVQRXJOaEJuTmVHNkE9PQo=
root@k8s-master01:~/k8s/yaml/ceph-case# cat case5-secret-admin.yaml
apiVersion: v1
kind: Secret
metadata:
  name: ceph-secret-admin
type: "kubernetes.io/rbd"
data:
  key: QVFDQ1ZUQmk4aW9mSnhBQXV5WDl0S3IzOEVQRXJOaEJuTmVHNkE9PQo=
root@k8s-master01:~/k8s/yaml/ceph-case# kubectl apply -f case5-secret-admin.yaml
root@k8s-master01:~/k8s/yaml/ceph-case# kubectl get secret		
NAME                        TYPE                                  DATA   AGE
ceph-secret-admin           kubernetes.io/rbd                     1      22h
ceph-secret-magedu-shijie   kubernetes.io/rbd                     1      22h
default-token-qghvn         kubernetes.io/service-account-token   3      20d

6.2.9.2 创建ceph存储类
root@k8s-master01:~/k8s/yaml/ceph-case# cat case6-ceph-storage-class.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass				#集群级别
metadata:
  name: ceph-storage-class-shijie
  annotations:
    storageclass.kubernetes.io/is-default-class: "true" #设置为默认存储类
provisioner: kubernetes.io/rbd
parameters:
  monitors: 172.168.2.27:6789,172.168.2.28:6789,172.168.2.29:6789	#mon服务器地址
  adminId: admin   							#ceph管理员名称
  adminSecretName: ceph-secret-admin		#ceph admin的secret名称
  adminSecretNamespace: default				#ceph admin的secret所在的名称空间
  pool: shijie-rbd-pool1					#自己预先创建好的存储池
  userId: magedu-shijie						#pod挂载使用的普通用户名称
  userSecretName: ceph-secret-magedu-shijie	#pod挂载使用的普通用户secret名称
root@k8s-master01:~/k8s/yaml/ceph-case# kubectl apply -f case6-ceph-storage-class.yaml
root@k8s-master01:~/k8s/yaml/ceph-case# kubectl get sc
NAME                                  PROVISIONER         RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
ceph-storage-class-shijie (default)   kubernetes.io/rbd   Delete          Immediate           false                  9s

6.2.9.3调用存储类创建pvc
root@k8s-master01:~/k8s/yaml/ceph-case# cat case7-mysql-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-data-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: ceph-storage-class-shijie
  resources:
    requests:
      storage: '2Gi'
root@k8s-master01:~/k8s/yaml/ceph-case# kubectl apply -f case7-mysql-pvc.yaml
root@k8s-master01:~/k8s/yaml/ceph-case# kubectl get pvc
NAME             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS                AGE
mysql-data-pvc   Bound    pvc-ac762756-7248-49e1-afad-29c60b9eeae6   2Gi        RWO            ceph-storage-class-shijie   2s
root@k8s-master01:~# kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                            STORAGECLASS                REASON   AGE
pvc-ac762756-7248-49e1-afad-29c60b9eeae6   2Gi        RWO            Delete           Bound    default/mysql-data-pvc           ceph-storage-class-shijie            2m8s
zookeeper-datadir-pv-1                     20Gi       RWO            Retain           Bound    magedu/zookeeper-datadir-pvc-1                                        2d
zookeeper-datadir-pv-2                     20Gi       RWO            Retain           Bound    magedu/zookeeper-datadir-pvc-2                                        2d
zookeeper-datadir-pv-3                     20Gi       RWO            Retain           Bound    magedu/zookeeper-datadir-pvc-3                                        2d
root@k8s-master01:~# kubectl describe pv pvc-ac762756-7248-49e1-afad-29c60b9eeae6 | grep RBDImage	#pv所挂载的image名称
    RBDImage:      kubernetes-dynamic-pvc-165149fa-ccf6-4abf-b279-706c735c56d1
ceph@ansible:~$ rbd ls --pool shijie-rbd-pool1			#此时在ceph管理服务器上查看已经创建了image
kubernetes-dynamic-pvc-165149fa-ccf6-4abf-b279-706c735c56d1
shijie-img-img1

6.2.9.4 使用mysql挂载pvc
root@k8s-master01:~/k8s/yaml/ceph-case# docker pull mysql:5.6.46
root@k8s-master01:~/k8s/yaml/ceph-case# docker tag mysql:5.6.46 192.168.13.197:8000/magedu/mysql:5.6.46
root@k8s-master01:~/k8s/yaml/ceph-case# docker push 192.168.13.197:8000/magedu/mysql:5.6.46
root@k8s-master01:~/k8s/yaml/ceph-case# docker run -it --rm -p 33306:3306 192.168.13.197:8000/magedu/mysql:5.6.46		#本机测试运行不起来，需要指定环境变量MYSQL_ROOT_PASSWORD值 
        You need to specify one of MYSQL_ROOT_PASSWORD, MYSQL_ALLOW_EMPTY_PASSWORD and MYSQL_RANDOM_ROOT_PASSWORD
root@k8s-master01:~/k8s/yaml/ceph-case# cat case8-mysql-single.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
spec:
  selector:
    matchLabels:
      app: mysql
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - image: 192.168.13.197:8000/magedu/mysql:5.6.46
        name: mysql
        env:
          # Use secret in real usage
        - name: MYSQL_ROOT_PASSWORD
          value: magedu123456
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: mysql-data-pvc
---
kind: Service
apiVersion: v1
metadata:
  labels:
    app: mysql-service-label
  name: mysql-service
spec:
  type: NodePort
  ports:
  - name: http
    port: 3306
    protocol: TCP
    targetPort: 3306
    nodePort: 43306
  selector:
    app: mysql
root@k8s-master01:~/k8s/yaml/ceph-case# kubectl apply -f case8-mysql-single.yaml
root@k8s-master01:~/k8s/yaml/ceph-case# kubectl get pods -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP              NODE            NOMINATED NODE   READINESS GATES
mysql-6c7ffcffdf-z8r9l   1/1     Running   0          68s   172.20.217.88   192.168.13.63   <none>           <none>
root@mysql-6c7ffcffdf-z8r9l:/# df -TH | grep /var/lib/mysql		#进入容器里面查看已经成功挂载，并且服务已经成功启动
/dev/rbd0               ext4     2.1G  128M  2.0G   7% /var/lib/mysql
ceph@ansible:~$ ceph df
--- RAW STORAGE ---
CLASS    SIZE   AVAIL     USED  RAW USED  %RAW USED
hdd    45 GiB  44 GiB  1.1 GiB   1.1 GiB       2.44
TOTAL  45 GiB  44 GiB  1.1 GiB   1.1 GiB       2.44

--- POOLS ---
POOL                   ID  PGS   STORED  OBJECTS     USED  %USED  MAX AVAIL
device_health_metrics   1    1      0 B        0      0 B      0     14 GiB
mypool                  2    4      0 B        0      0 B      0     14 GiB
myrbd1                  3    8   72 MiB       51  215 MiB   0.51     14 GiB
cephfs-metadata         4   16   24 KiB       22  160 KiB      0     14 GiB
cephfs-data             5   64      0 B        0      0 B      0     14 GiB
shijie-rbd-pool1        6   16  240 MiB       84  721 MiB   1.69     14 GiB		#mysql挂载的存储池使用了240M了

6.2.9.5 使用cephfs挂载
6.2.9.5.1 ceph@ansible:~$ ceph -s | grep mds    #首先确保ceph已经安装cephfs，如下表示已经安装,并且一主一备
    mds: 1/1 daemons up, 1 standby
	
6.2.9.5.2 创建mds专用用户
ceph@ansible:~$ ceph auth add client.kubernetes.mds.jack mon 'allow r' mds 'allow rw' osd 'allow rwx pool=cephfs-data'                                                                  added key for client.kubernetes.mds.jack
ceph@ansible:~$ ceph auth get client.kubernetes.mds.jack
[client.kubernetes.mds.jack]
        key = AQBwXT1iOtjWDxAAibWrQwV76onYdXoDZ1WfxQ==
        caps mds = "allow rw"
        caps mon = "allow r"
        caps osd = "allow rwx pool=cephfs-data"
exported keyring for client.kubernetes.mds.jack
ceph@ansible:~$ ceph auth get client.kubernetes.mds.jack -o ceph.client.kubernetes.mds.jack.keyring
ceph@ansible:~$ ceph auth print-key client.kubernetes.mds.jack > ceph.client.kubernetes.mds.jack.key
[root@k8s-node04 ~]# mount -t ceph 172.168.2.27:6789,172.168.2.28:6789,172.168.2.29:6789:/ /mnt -o name=kubernetes.mds.jack,secret=AQBwXT1iOtjWDxAAibWrQwV76onYdXoDZ1WfxQ==		#测试挂载
[root@k8s-node04 ~]# df -TH | grep mnt
172.168.2.27:6789,172.168.2.28:6789,172.168.2.29:6789:/ ceph       15G     0   15G   0% /mnt

6.2.9.5.3 创建mds专用secret
ceph@ansible:~$ echo 'AQBwXT1iOtjWDxAAibWrQwV76onYdXoDZ1WfxQ==' | base64
QVFCd1hUMWlPdGpXRHhBQWliV3JRd1Y3Nm9uWWRYb0RaMVdmeFE9PQo=
root@k8s-master01:~/k8s/yaml/ceph-case# cat case9-secret-mds-client-jack.yaml
apiVersion: v1
kind: Secret
metadata:
  name: ceph-secret-magedu-mds-jack
type: "kubernetes.io/rbd"
data:
  key: QVFCd1hUMWlPdGpXRHhBQWliV3JRd1Y3Nm9uWWRYb0RaMVdmeFE9PQo=
root@k8s-master01:~/k8s/yaml/ceph-case# kubectl apply -f case9-secret-mds-client-jack.yaml

6.2.9.5.4  应用pod挂载
root@k8s-master01:~/k8s/yaml/ceph-case# cat case9-nginx-cephfs.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels: #rs or deployment
      app: ng-deploy-80
  template:
    metadata:
      labels:
        app: ng-deploy-80
    spec:
      containers:
      - name: ng-deploy-80
        image: nginx
        ports:
        - containerPort: 80
        volumeMounts:
        - name: magedu-staticdata-cephfs
          mountPath: /usr/share/nginx/html/
      volumes:
        - name: magedu-staticdata-cephfs
          cephfs:
            monitors:
            - '172.168.2.27:6789'
            - '172.168.2.28:6789'
            - '172.168.2.29:6789'
            path: /
            user: kubernetes.mds.jack
            secretRef:
              name: ceph-secret-magedu-mds-jack
root@k8s-master01:~/k8s/yaml/ceph-case# kubectl apply -f case9-nginx-cephfs.yaml

6.2.9.5.5 上面deployment控制器运行的pod报错，报告未找到文件"unable to find a keyring on /etc/ceph/ceph.client.kubernetes.mds.jack.keyring,/etc/ceph/ceph.keyring,/etc/ceph/keyring,/etc/ceph/keyring.bin,: (2) No such file or directory" ，需要复制keyring到所有work节点
ceph@ansible:~$ sudo ansible k8s -m copy -a 'src=ceph.client.kubernetes.mds.jack.keyring dest=/etc/ceph/'
root@k8s-master01:~/k8s/yaml/ceph-case# kubectl apply -f case9-nginx-cephfs.yaml		#再次运行
root@k8s-master01:~/k8s/yaml/ceph-case# kubectl get pods -o wide
NAME                                READY   STATUS    RESTARTS   AGE   IP              NODE            NOMINATED NODE   READINESS GATES
mysql-6c7ffcffdf-z8r9l              1/1     Running   0          62m   172.20.217.88   192.168.13.63   <none>           <none>
nginx-deployment-7755dbc9d9-m2qml   1/1     Running   0          71s   172.20.217.87   192.168.13.63   <none>           <none>
nginx-deployment-7755dbc9d9-rjzlf   1/1     Running   0          71s   172.20.217.90   192.168.13.63   <none>           <none>
nginx-deployment-7755dbc9d9-zqfmb   1/1     Running   0          71s   172.20.217.91   192.168.13.63   <none>           <none>
--上面运行3个副本nginx。此时无论在哪一个pod更改挂载的目录，其它pod都会拥有同样的变更，实现数据共享
root@k8s-master01:~/k8s/yaml/ceph-case# kubectl exec -it nginx-deployment-7755dbc9d9-m2qml bash
root@nginx-deployment-7755dbc9d9-m2qml:/usr/share/nginx/html# echo 'v111' > index.html
root@nginx-deployment-7755dbc9d9-m2qml:/usr/share/nginx/html# curl localhost
v111
root@nginx-deployment-7755dbc9d9-m2qml:/usr/share/nginx/html# curl 172.20.217.90		#此时从nginx-deployment-7755dbc9d9-rjzlf pod获取数据也一样
v111
注：有状态应用使用RBD。共享存储使用cephFS。其它需要使用RadowsGW 
注：在挂载根目录下创建目录来区分项目ID，例如创建 mkdir /usr/share/nginx/html{n56,n57}，两个项目区分就是n56,n57

6.3.0 pod状态及探针
6.3.0.1 探针简介：
--探针是由 kubelet 对容器执行的定期诊断，以保证Pod的状态始终处于运行状态，要执行诊断，kubelet 调用由容器实现的Handler(处理程序)，有三种类型的处理程序：
ExecAction   #在容器内执行指定命令，如果命令退出时返回码为0则认为诊断成功。
TCPSocketAction    #对指定端口上的容器的IP地址进行TCP检查，如果端口打开，则诊断被认为是成功的。
HTTPGetAction    #对指定的端口和路径上的容器的IP地址执行HTTPGet请求，如果响应的状态码大于等于200且小于 400，则诊断被认为是成功的。
每次探测都将获得以下三种结果之一：
成功：容器通过了诊断。
失败：容器未通过诊断。
未知：诊断失败，因此不会采取任何行动。
--探针类型：
livenessProbe    #存活探针，检测容器容器是否正在运行，如果存活探测失败，则kubelet会杀死容器，并且容器将受到其重启策略的影响，如果容器不提供存活探针，则默认状态为 Success，livenessProbe⽤于控制是否重启pod。
readinessProbe    #就绪探针，如果就绪探测失败，端点控制器将从与Pod匹配的所有Service的端点中删除该Pod的IP地址，初始延迟之前的就绪状态默认为Failure(失败)，如果容器不提供就绪探针，则默认状态为Success，readinessProbe用于控制pod是否添加至service。

6.3.0.2 Pod重启策略：
k8s在Pod出现异常的时候会⾃动将Pod重启以恢复Pod中的服务。
restartPolicy：
Always：当容器异常时，k8s自动重启该容器，ReplicationController/Replicaset/Deployment。
OnFailure：当容器失败时(容器停止运行且退出码不为0)，k8s自动重启该容器。
Never：不论容器运⾏状态如何都不会重启该容器,Job或CronJob。

6.3.0.3 探针配置：
initialDelaySeconds: 120
#初始化延迟时间，告诉kubelet在执行第一次探测前应该等待多少秒，默认是0秒，最小值是0
periodSeconds: 60
#探测周期间隔时间，指定了kubelet应该每多少秒秒执行一次存活探测，默认是 10 秒。最小值是 1
timeoutSeconds: 5
#单次探测超时时间，探测的超时后等待多少秒，默认值是1秒，最小值是1。
successThreshold: 1
#从失败转为成功的重试次数，探测器在失败后，被视为成功的最小连续成功数，默认值是1，存活探测的这个值必须是1，最小值是 1。
failureThreshold： 3
#从成功转为失败的重试次数，当Pod启动了并且探测到失败，Kubernetes的重试次数，存活探测情况下的放弃就意味着重新启动容器，就绪探测情况下的放弃Pod 会被打上未就绪的标签，默认值是3，最小值是1。
----HTTP 探测器可以在 httpGet 上配置额外的字段：
host:
#连接使用的主机名，默认是Pod的 IP，也可以在HTTP头中设置 “Host” 来代替。
scheme: http
#用于设置连接主机的⽅式（HTTP 还是 HTTPS），默认是 HTTP。
path: /monitor/index.html
#访问 HTTP 服务的路径。
httpHeaders:
#请求中自定义的 HTTP 头,HTTP 头字段允许重复。
port: 80
#访问容器的端⼝号或者端口名，如果数字必须在 1 ～ 65535 之间。

6.3.0.4 livenessProbe和readinessProbe的对比：
配置参数一样
livenessProbe #连续探测失败会重启、重建pod，readinessProbe不会执⾏重启或者重建Pod操作
livenessProbe #连续检测指定次数失败后会将容器置于(Crash Loop BackOff)且不可用，readinessProbe不会
readinessProbe #连续探测失败会从service的endpointd中删除该Pod，livenessProbe不具备此功能，但是会将容器挂起livenessProbe
livenessProbe用户控制是否重启pod，readinessProbe⽤于控制pod是否添加⾄service
建议：
两个探针都配置

6.3.0.5 探针示例：
----HTTP探针示例：
root@k8s-master01:~/k8s/yaml/probe-case# cat nginx.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
  selector:
    matchLabels: #rs or deployment
      app: ng-deploy-80
    #matchExpressions:
    #  - {key: app, operator: In, values: [ng-deploy-80,ng-rs-81]}
  template:
    metadata:
      labels:
        app: ng-deploy-80
    spec:
      containers:
      - name: ng-deploy-80
        image: nginx:1.17.5
        ports:
        - containerPort: 80
        #readinessProbe:
        livenessProbe:
          httpGet:
            #path: /monitor/monitor.html
            path: /index1.html
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 3
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 3
---
apiVersion: v1
kind: Service
metadata:
  name: ng-deploy-80
spec:
  ports:
  - name: http
    port: 81
    targetPort: 80
    nodePort: 40012
    protocol: TCP
  type: NodePort
  selector:
    app: ng-deploy-80
----TCP探针示例：
root@k8s-master01:~/k8s/yaml/probe-case# cat tcp.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
  selector:
    matchLabels: #rs or deployment
      app: ng-deploy-80
    #matchExpressions:
    #  - {key: app, operator: In, values: [ng-deploy-80,ng-rs-81]}
  template:
    metadata:
      labels:
        app: ng-deploy-80
    spec:
      containers:
      - name: ng-deploy-80
        image: nginx:1.17.5
        ports:
        - containerPort: 80
        livenessProbe:
          tcpSocket:
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 3
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 3
        readinessProbe:
          tcpSocket:
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 3
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 3
---
apiVersion: v1
kind: Service
metadata:
  name: ng-deploy-80
spec:
  ports:
  - name: http
    port: 81
    targetPort: 80
    nodePort: 40012
    protocol: TCP
  type: NodePort
  selector:
    app: ng-deploy-80
----ExecAction探针示例：
root@k8s-master01:~/k8s/yaml/probe-case# cat redis.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-deployment
spec:
  replicas: 1
  selector:
    matchLabels: #rs or deployment
      app: redis-deploy-6379
    #matchExpressions:
    #  - {key: app, operator: In, values: [redis-deploy-6379,ng-rs-81]}
  template:
    metadata:
      labels:
        app: redis-deploy-6379
    spec:
      containers:
      - name: redis-deploy-6379
        image: redis
        ports:
        - containerPort: 6379
        readinessProbe:
          exec:
            command:
            - /usr/local/bin/redis-cli
            - quit
          initialDelaySeconds: 5
          periodSeconds: 3
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 3
        livenessProbe:
          exec:
            command:
            - /usr/local/bin/redis-cli
            - quit
          initialDelaySeconds: 5
          periodSeconds: 3
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 3
---
apiVersion: v1
kind: Service
metadata:
  name: redis-deploy-6379
spec:
  ports:
  - name: http
    port: 6379
    targetPort: 6379
    nodePort: 40016
    protocol: TCP
  type: NodePort
  selector:
    app: redis-deploy-6379

	
	
6.4 k8s运行redis
使用kompose将docker-compose文件转成K8s yaml文件，可以提升效率，但是有些内容未不致，需要进行相应调整。
redis.conf配置文件：
stop-writes-on-bgsave-error no		#表示bgsave快照保存错误时是否停止写入，这里改成no，保存快照时不停止写入

6.4.1 创建redis PV
root@k8s-master01:~/k8s/yaml/magedu/redis# cat pv/redis-persistentvolume.yaml
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: redis-datadir-pv-1
  namespace: magedu
spec:
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  nfs:
    path: /data/k8sdata/magedu/redis-datadir-1
    server: 192.168.13.67
root@k8s-master01:~/k8s/yaml/magedu/redis# kubectl apply -f pv/redis-persistentvolume.yaml
root@k8s-master01:~/k8s/yaml/magedu/redis# kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                            STORAGECLASS                REASON   AGE
pvc-ac762756-7248-49e1-afad-29c60b9eeae6   2Gi        RWO            Delete           Failed      default/mysql-data-pvc           ceph-storage-class-shijie            5h15m
redis-datadir-pv-1                         2Gi        RWO            Retain           Available                                                                         3s
zookeeper-datadir-pv-1                     20Gi       RWO            Retain           Bound       magedu/zookeeper-datadir-pvc-1                                        2d6h
zookeeper-datadir-pv-2                     20Gi       RWO            Retain           Bound       magedu/zookeeper-datadir-pvc-2                                        2d6h
zookeeper-datadir-pv-3                     20Gi       RWO            Retain           Bound       magedu/zookeeper-datadir-pvc-3                                        2d6h

6.4.2 创建PVC
root@k8s-master01:~/k8s/yaml/magedu/redis# cat pv/redis-persistentvolumeclaim.yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: redis-datadir-pvc-1
  namespace: magedu
spec:
  volumeName: redis-datadir-pv-1
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
root@k8s-master01:~/k8s/yaml/magedu/redis# kubectl apply -f pv/redis-persistentvolumeclaim.yaml
root@k8s-master01:~/k8s/yaml/magedu/redis# kubectl get pvc -n magedu
NAME                      STATUS   VOLUME                   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
redis-datadir-pvc-1       Bound    redis-datadir-pv-1       2Gi        RWO                           7s
zookeeper-datadir-pvc-1   Bound    zookeeper-datadir-pv-1   20Gi       RWO                           2d6h
zookeeper-datadir-pvc-2   Bound    zookeeper-datadir-pv-2   20Gi       RWO                           2d6h
zookeeper-datadir-pvc-3   Bound    zookeeper-datadir-pv-3   20Gi       RWO                           2d6h

6.4.3 运行redis
root@k8s-master01:~/k8s/yaml/magedu/redis# cat redis.yaml
kind: Deployment
#apiVersion: extensions/v1beta1
apiVersion: apps/v1
metadata:
  labels:
    app: devops-redis
  name: deploy-devops-redis
  namespace: magedu
spec:
  replicas: 1
  selector:
    matchLabels:
      app: devops-redis
  template:
    metadata:
      labels:
        app: devops-redis
    spec:
      containers:
        - name: redis-container
          image: 192.168.13.197:8000/magedu/redis:v4.0.14
          imagePullPolicy: Always
          volumeMounts:
          - mountPath: "/data/redis-data/"
            name: redis-datadir
      volumes:
        - name: redis-datadir
          persistentVolumeClaim:
            claimName: redis-datadir-pvc-1

---
kind: Service
apiVersion: v1
metadata:
  labels:
    app: devops-redis
  name: srv-devops-redis
  namespace: magedu
spec:
  type: NodePort
  ports:
  - name: http
    port: 6379
    targetPort: 6379
    nodePort: 36379
  selector:
    app: devops-redis
  sessionAffinity: ClientIP		#开启会话保持
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800
root@k8s-master01:~/k8s/yaml/magedu/redis# kubectl apply -f redis.yaml
root@k8s-master01:~/k8s/yaml/magedu/redis# kubectl get pods -n magedu
NAME                                             READY   STATUS    RESTARTS   AGE
deploy-devops-redis-749878f59d-gf856             1/1     Running   0          22s
magedu-nginx-deployment-769d4567ff-8sm6c         1/1     Running   2          2d
magedu-tomcat-app1-deployment-65747746b9-dfzfl   1/1     Running   1          2d
zookeeper1-749d87b7c5-stk5w                      1/1     Running   1          2d1h
zookeeper2-5f5fcb7f4d-s5pgp                      1/1     Running   1          2d1h
zookeeper3-c857bb585-txchq                       1/1     Running   1          2d1h
k8s集群外访问: 172.168.2.21:36379 auth:123456


6.4.4 运行mysql主从
statefulSet控制器绑定PV，因为pod名称是固定的，所以无论pod怎么删除怎么重建，pod和PV的绑定关系一直是固定的，不会变动，绑定关系持久保存在etcd当中。

6.4.4.1 做mysql5.7镜像，使用官方,可用于生产
root@k8s-master01:~# docker pull mysql:5.7
root@k8s-master01:~# docker run -it --rm mysql:5.7 bash 
root@bb4d3d7bbc9b:/# mysqld --version
mysqld  Ver 5.7.36 for Linux on x86_64 (MySQL Community Server (GPL))
root@k8s-master01:~# docker tag mysql:5.7 192.168.13.197:8000/magedu/mysql:5.7.36
root@k8s-master01:~# docker push 192.168.13.197:8000/magedu/mysql:5.7.36

6.4.4.2 做xtrabackup镜像，可用于生产
root@k8s-master01:~# docker pull registry.cn-hangzhou.aliyuncs.com/hxpdocker/xtrabackup:1.0
root@k8s-master01:~# docker tag registry.cn-hangzhou.aliyuncs.com/hxpdocker/xtrabackup:1.0 192.168.13.197:8000/magedu/xtrabackup:1.0
root@k8s-master01:~# docker push 192.168.13.197:8000/magedu/xtrabackup:1.0

6.4.4.3 创建mysql nfs存储目录、手动创建PV
[root@NFSServer ~]# mkdir -p /data/k8sdata/magedu/mysql-datadir-{1,2,3,4,5,6}
root@k8s-master01:~/k8s/yaml/magedu/mysql/pv# cat mysql-persistentvolume.yaml
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-datadir-1
spec:
  capacity:
    storage: 50Gi
  accessModes:
    - ReadWriteOnce
  nfs:
    path: /data/k8sdata/magedu/mysql-datadir-1
    server: 192.168.13.67
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-datadir-2
spec:
  capacity:
    storage: 50Gi
  accessModes:
    - ReadWriteOnce
  nfs:
    path: /data/k8sdata/magedu/mysql-datadir-2
    server: 192.168.13.67
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-datadir-3
spec:
  capacity:
    storage: 50Gi
  accessModes:
    - ReadWriteOnce
  nfs:
    path: /data/k8sdata/magedu/mysql-datadir-3
    server: 192.168.13.67
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-datadir-4
spec:
  capacity:
    storage: 50Gi
  accessModes:
    - ReadWriteOnce
  nfs:
    path: /data/k8sdata/magedu/mysql-datadir-4
    server: 192.168.13.67
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-datadir-5
spec:
  capacity:
    storage: 50Gi
  accessModes:
    - ReadWriteOnce
  nfs:
    path: /data/k8sdata/magedu/mysql-datadir-5
    server: 192.168.13.67

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-datadir-6
spec:
  capacity:
    storage: 50Gi
  accessModes:
    - ReadWriteOnce
  nfs:
    path: /data/k8sdata/magedu/mysql-datadir-6
    server: 192.168.13.67
root@k8s-master01:~/k8s/yaml/magedu/mysql/pv# kubectl apply -f mysql-persistentvolume.yaml
root@k8s-master01:~/k8s/yaml/magedu/mysql/pv# kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                            STORAGECLASS                REASON   AGE
mysql-datadir-1                            50Gi       RWO            Retain           Available                                                                         2s
mysql-datadir-2                            50Gi       RWO            Retain           Available                                                                         2s
mysql-datadir-3                            50Gi       RWO            Retain           Available                                                                         2s
mysql-datadir-4                            50Gi       RWO            Retain           Available                                                                         2s
mysql-datadir-5                            50Gi       RWO            Retain           Available                                                                         2s
mysql-datadir-6                            50Gi       RWO            Retain           Available                                                                         2s
pvc-ac762756-7248-49e1-afad-29c60b9eeae6   2Gi        RWO            Delete           Failed      default/mysql-data-pvc           ceph-storage-class-shijie            7h47m
redis-datadir-pv-1                         2Gi        RWO            Retain           Bound       magedu/redis-datadir-pvc-1                                            151m
zookeeper-datadir-pv-1                     20Gi       RWO            Retain           Bound       magedu/zookeeper-datadir-pvc-1                                        2d8h
zookeeper-datadir-pv-2                     20Gi       RWO            Retain           Bound       magedu/zookeeper-datadir-pvc-2                                        2d8h
zookeeper-datadir-pv-3                     20Gi       RWO            Retain           Bound       magedu/zookeeper-datadir-pvc-3                                        2d8h

注：应用mysql statefulset控制器部署时，因为遗留StorageClass相关的东西，经过删除没用的PVC和PV、清除mysql挂载的NFS数据目录后，重新创建mysql statefulset控制器部署成功
6.4.4.4 运行configMap
root@k8s-master01:~/k8s/yaml/magedu/mysql# cat mysql-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql
  namespace: magedu
  labels:
    app: mysql
data:
  master.cnf: |
    # Apply this config only on the master.
    [mysqld]
    log-bin
    log_bin_trust_function_creators=1
    lower_case_table_names=1
  slave.cnf: |
    # Apply this config only on slaves.
    [mysqld]
    super-read-only
    log_bin_trust_function_creators=1
root@k8s-master01:~/k8s/yaml/magedu/mysql# kubectl apply -f mysql-configmap.yaml

6.4.4.4 运行service，因为创建mysql statefulset控制器时，需要从mysql service中恢复数据，有依赖关系，否则不会创建成功。
root@k8s-master01:~/k8s/yaml/magedu/mysql# cat mysql-services.yaml
# Headless service for stable DNS entries of StatefulSet members.
apiVersion: v1
kind: Service
metadata:
  namespace: magedu
  name: mysql
  labels:
    app: mysql
spec:
  ports:
  - name: mysql
    port: 3306
  clusterIP: None
  selector:
    app: mysql
---
# Client service for connecting to any MySQL instance for reads.
# For writes, you must instead connect to the master: mysql-0.mysql.
apiVersion: v1
kind: Service
metadata:
  name: mysql-read
  namespace: magedu
  labels:
    app: mysql
spec:
  ports:
  - name: mysql
    port: 3306
  selector:
    app: mysql
root@k8s-master01:~/k8s/yaml/magedu/mysql# kubectl apply -f mysql-services.yaml

6.4.4.5 创建mysql statefulset 控制器，生产使用nodeSelector进行特定节点运行，性能强悍的机器上运行
root@k8s-master01:~/k8s/yaml/magedu/mysql# cat mysql-statefulset.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
  namespace: magedu
spec:
  selector:
    matchLabels:
      app: mysql
  serviceName: mysql
  replicas: 3
  template:
    metadata:
      labels:
        app: mysql
    spec:
      initContainers:
      - name: init-mysql
        image: 192.168.13.197:8000/magedu/mysql:5.7.36
        command:
        - bash
        - "-c"
        - |
          set -ex
          # Generate mysql server-id from pod ordinal index.
          [[ `hostname` =~ -([0-9]+)$ ]] || exit 1
          ordinal=${BASH_REMATCH[1]}
          echo [mysqld] > /mnt/conf.d/server-id.cnf
          # Add an offset to avoid reserved server-id=0 value.
          echo server-id=$((100 + $ordinal)) >> /mnt/conf.d/server-id.cnf
          # Copy appropriate conf.d files from config-map to emptyDir.
          if [[ $ordinal -eq 0 ]]; then
            cp /mnt/config-map/master.cnf /mnt/conf.d/
          else
            cp /mnt/config-map/slave.cnf /mnt/conf.d/
          fi
        volumeMounts:
        - name: conf
          mountPath: /mnt/conf.d
        - name: config-map
          mountPath: /mnt/config-map
      - name: clone-mysql
        image: 192.168.13.197:8000/magedu/xtrabackup:1.0
        command:
        - bash
        - "-c"
        - |
          set -ex
          # Skip the clone if data already exists.
          [[ -d /var/lib/mysql/mysql ]] && exit 0
          # Skip the clone on master (ordinal index 0).
          [[ `hostname` =~ -([0-9]+)$ ]] || exit 1
          ordinal=${BASH_REMATCH[1]}
          [[ $ordinal -eq 0 ]] && exit 0
          # Clone data from previous peer.
          ncat --recv-only mysql-$(($ordinal-1)).mysql 3307 | xbstream -x -C /var/lib/mysql			#在此步需要连接mysql-0.mysql进行克隆数据，所以service需要先创建
          # Prepare the backup.
          xtrabackup --prepare --target-dir=/var/lib/mysql
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
          subPath: mysql
        - name: conf
          mountPath: /etc/mysql/conf.d
      containers:
      - name: mysql
        image: 192.168.13.197:8000/magedu/mysql:5.7.36
        env:
        - name: MYSQL_ALLOW_EMPTY_PASSWORD
          value: "1"
        ports:
        - name: mysql
          containerPort: 3306
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
          subPath: mysql
        - name: conf
          mountPath: /etc/mysql/conf.d
        resources:
          requests:
            cpu: 500m
            memory: 1Gi
        livenessProbe:
          exec:
            command: ["mysqladmin", "ping"]
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
        readinessProbe:
          exec:
            # Check we can execute queries over TCP (skip-networking is off).
            command: ["mysql", "-h", "127.0.0.1", "-e", "SELECT 1"]
          initialDelaySeconds: 5
          periodSeconds: 2
          timeoutSeconds: 1
      - name: xtrabackup
        image: 192.168.13.197:8000/magedu/xtrabackup:1.0
        ports:
        - name: xtrabackup
          containerPort: 3307
        command:
        - bash
        - "-c"
        - |
          set -ex
          cd /var/lib/mysql
          # Determine binlog position of cloned data, if any.
          if [[ -f xtrabackup_slave_info ]]; then
            # XtraBackup already generated a partial "CHANGE MASTER TO" query
            # because we're cloning from an existing slave.
            mv xtrabackup_slave_info change_master_to.sql.in
            # Ignore xtrabackup_binlog_info in this case (it's useless).
            rm -f xtrabackup_binlog_info
          elif [[ -f xtrabackup_binlog_info ]]; then
            # We're cloning directly from master. Parse binlog position.
            [[ `cat xtrabackup_binlog_info` =~ ^(.*?)[[:space:]]+(.*?)$ ]] || exit 1
            rm xtrabackup_binlog_info
            echo "CHANGE MASTER TO MASTER_LOG_FILE='${BASH_REMATCH[1]}',\
                  MASTER_LOG_POS=${BASH_REMATCH[2]}" > change_master_to.sql.in
          fi
          # Check if we need to complete a clone by starting replication.
          if [[ -f change_master_to.sql.in ]]; then
            echo "Waiting for mysqld to be ready (accepting connections)"
            until mysql -h 127.0.0.1 -e "SELECT 1"; do sleep 1; done
            echo "Initializing replication from clone position"
            # In case of container restart, attempt this at-most-once.
            mv change_master_to.sql.in change_master_to.sql.orig
            mysql -h 127.0.0.1 <<EOF
          $(<change_master_to.sql.orig),
            MASTER_HOST='mysql-0.mysql',
            MASTER_USER='root',
            MASTER_PASSWORD='',
            MASTER_CONNECT_RETRY=10;
          START SLAVE;
          EOF
          fi
          # Start a server to send backups when requested by peers.
          exec ncat --listen --keep-open --send-only --max-conns=1 3307 -c \
            "xtrabackup --backup --slave-info --stream=xbstream --host=127.0.0.1 --user=root"
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
          subPath: mysql
        - name: conf
          mountPath: /etc/mysql/conf.d
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
      volumes:
      - name: conf
        emptyDir: {}
      - name: config-map
        configMap:
          name: mysql
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
root@k8s-master01:~/k8s/yaml/magedu/mysql# kubectl apply -f mysql-statefulset.yaml

6.4.4.6 测试
-- 在master-0库上写入数据，在其它从库上查看数据及slave状态是否正常
-- service: mysql 和 service: mysql-read 后端pod是一样的，所以无论读哪个service都是可以的。但是写的时候必须使用mysql-0.mysql才行，这样可以解析为pod IP，但是mysql-0.mysql-read则不行。
bash-4.3# nslookup mysql.magedu.svc.homsom.local	#因为mysql为无头service，所以service直接指向后端pod地址，并且有pod地址有对应的域名，例如172.20.217.104 mysql-0.mysql.magedu.svc.homsom.local，因为是statefulset 控制器，所以名称是固定的，，从而能使用mysql-0.mysql.magedu.svc.homsom.local进行解析
Name:      mysql.magedu.svc.homsom.local
Address 1: 172.20.217.108 172-20-217-108.mysql-read.magedu.svc.homsom.local
Address 2: 172.20.217.106 mysql-2.mysql.magedu.svc.homsom.local
Address 3: 172.20.217.107 172-20-217-107.mysql-read.magedu.svc.homsom.local
Address 4: 172.20.217.104 mysql-0.mysql.magedu.svc.homsom.local
bash-4.3# nslookup mysql-read.magedu.svc.homsom.local		#因为不是无头service，所以service有固定IP地址，从而不能使用mysql-0.mysql.magedu.svc.homsom.local进行解析
Name:      mysql-read.magedu.svc.homsom.local
Address 1: 10.68.32.249 mysql-read.magedu.svc.homsom.local


6.4.5 运行java类型服务--jenkins

6.4.5.1 构建镜像
------------------------
root@k8s-master01:~/k8s/dockerfile/web/magedu/jenkins# cat Dockerfile
#Jenkins Version 2.190.1
FROM 192.168.13.197:8000/pub-images/jdk-base:v8.212

MAINTAINER zhangshijie zhangshijie@magedu.net

ADD jenkins-2.190.1.war /apps/jenkins/
ADD run_jenkins.sh /usr/bin/

EXPOSE 8080

CMD ["/usr/bin/run_jenkins.sh"]
------------------------
root@k8s-master01:~/k8s/dockerfile/web/magedu/jenkins# cat run_jenkins.sh
#!/bin/bash
cd /apps/jenkins && java -server -Xms1024m -Xmx1024m -Xss512k -jar jenkins-2.190.1.war --webroot=/apps/jenkins/jenkins-data --httpPort=8080
------------------------
root@k8s-master01:~/k8s/dockerfile/web/magedu/jenkins# cat build-command.sh
#!/bin/bash
docker build -t  192.168.13.197:8000/magedu/jenkins:v2.190.1 .
echo "镜像制作完成，即将上传至Harbor服务器"
sleep 1
docker push 192.168.13.197:8000/magedu/jenkins:v2.190.1
echo "镜像上传完成"
------------------------

6.4.5.2 创建PV
root@k8s-master01:~/k8s/yaml/magedu/jenkins/pv# cat jenkins-persistentvolume.yaml
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: jenkins-datadir-pv
  namespace: magedu
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteOnce
  nfs:
    server: 192.168.13.67
    path: /data/k8sdata/magedu/jenkins-data

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: jenkins-root-datadir-pv
  namespace: magedu
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteOnce
  nfs:
    server: 192.168.13.67
    path: /data/k8sdata/magedu/jenkins-root-data
root@k8s-master01:~/k8s/yaml/magedu/jenkins/pv# kubectl apply -f jenkins-persistentvolume.yaml
root@k8s-master01:~/k8s/yaml/magedu/jenkins/pv# kubectl get pv | grep jenkins
jenkins-datadir-pv        100Gi      RWO            Retain           Available                                                            23s
jenkins-root-datadir-pv   100Gi      RWO            Retain           Available                                                            23s

6.4.5.3 创建PVC
root@k8s-master01:~/k8s/yaml/magedu/jenkins/pv# cat jenkins-persistentvolumeclaim.yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-datadir-pvc
  namespace: magedu
spec:
  volumeName: jenkins-datadir-pv
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 80Gi

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-root-data-pvc
  namespace: magedu
spec:
  volumeName: jenkins-root-datadir-pv
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 80Gi
root@k8s-master01:~/k8s/yaml/magedu/jenkins/pv# kubectl apply -f jenkins-persistentvolumeclaim.yaml
root@k8s-master01:~/k8s/yaml/magedu/jenkins/pv# kubectl get pvc -n magedu | grep jenkins
jenkins-datadir-pvc       Pending   jenkins-datadir-pv        0                                        8s
jenkins-root-data-pvc     Pending   jenkins-root-datadir-pv   0                                        8s

6.4.5.4 运行jenkins
root@k8s-master01:~/k8s/yaml/magedu/jenkins# cat jenkins.yaml
kind: Deployment
#apiVersion: extensions/v1beta1
apiVersion: apps/v1
metadata:
  labels:
    app: magedu-jenkins
  name: magedu-jenkins-deployment
  namespace: magedu
spec:
  replicas: 1
  selector:
    matchLabels:
      app: magedu-jenkins
  template:
    metadata:
      labels:
        app: magedu-jenkins
    spec:
      containers:
      - name: magedu-jenkins-container
        image: 192.168.13.197:8000/magedu/jenkins:v2.190.1
        #imagePullPolicy: IfNotPresent
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
          protocol: TCP
          name: http
        volumeMounts:
        - mountPath: "/apps/jenkins/jenkins-data/"
          name: jenkins-datadir-magedu
        - mountPath: "/root/.jenkins"
          name: jenkins-root-datadir
      volumes:
        - name: jenkins-datadir-magedu
          persistentVolumeClaim:
            claimName: jenkins-datadir-pvc
        - name: jenkins-root-datadir
          persistentVolumeClaim:
            claimName: jenkins-root-data-pvc

---
kind: Service
apiVersion: v1
metadata:
  labels:
    app: magedu-jenkins
  name: magedu-jenkins-service
  namespace: magedu
spec:
  type: NodePort
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 8080
    nodePort: 38080
  selector:
    app: magedu-jenkins
root@k8s-master01:~/k8s/yaml/magedu/jenkins# kubectl get pod -o wide -n magedu | grep jenkins
magedu-jenkins-deployment-5f94c58f86-226hb       1/1     Running   0          2m27s   172.20.58.205    172.168.2.25    <none>           <none>
root@k8s-master01:~/k8s/yaml/magedu/jenkins# kubectl get svc -n magedu | grep jenkins
magedu-jenkins-service       NodePort    10.68.92.47     <none>        80:38080/TCP                                   49s

6.4.5.5 web访问jenkins地址：http://172.168.2.25:38080
root@k8s-master01:~/k8s/yaml/magedu/jenkins# kubectl exec -it magedu-jenkins-deployment-5f94c58f86-226hb bash -n magedu
[root@magedu-jenkins-deployment-5f94c58f86-226hb /]# cat /root/.jenkins/secrets/initialAdminPassword
7179a6bf7caa41d0b98ba67a88b9d70d


6.4.6 k8s安装WordPress
6.4.6.1 构建workpres nginx镜像
---
root@k8s-master01:~/k8s/dockerfile/web/pub-images/nginx-base-wordpress# cat Dockerfile
#Nginx Base Image
FROM 192.168.13.197:8000/baseimages/magedu-centos-base:7.8.2003

MAINTAINER  zhangshijie@magedu.net

RUN yum install -y vim wget tree  lrzsz gcc gcc-c++ automake pcre pcre-devel zlib zlib-devel openssl openssl-devel iproute net-tools iotop
ADD nginx-1.14.2.tar.gz /usr/local/src/
RUN cd /usr/local/src/nginx-1.14.2 && ./configure --prefix=/apps/nginx  && make && make install && ln -sv  /apps/nginx/sbin/nginx /usr/sbin/nginx  &&rm -rf /usr/local/src/nginx-1.14.2.tar.gz
---
root@k8s-master01:~/k8s/dockerfile/web/pub-images/nginx-base-wordpress# cat build-command.sh
#!/bin/bash
docker build -t 192.168.13.197:8000/pub-images/nginx-base-wordpress:v1.14.2  .
sleep 1
docker push  192.168.13.197:8000/pub-images/nginx-base-wordpress:v1.14.2
---
root@k8s-master01:~/k8s/dockerfile/web/pub-images/nginx-base-wordpress# ./build-command.sh

6.4.6.2 基本workpres nginx镜像增加配置信息、数据目录再次构建nginx镜像
root@k8s-master01:~/k8s/dockerfile/web/magedu/wordpress/nginx# cat Dockerfile
FROM 192.168.13.197:8000/pub-images/nginx-base-wordpress:v1.14.2

ADD nginx.conf /apps/nginx/conf/nginx.conf
ADD run_nginx.sh /apps/nginx/sbin/run_nginx.sh
RUN mkdir -pv /home/nginx/wordpress
RUN chown nginx.nginx /home/nginx/wordpress/ -R

EXPOSE 80 443

CMD ["/apps/nginx/sbin/run_nginx.sh"]
---
root@k8s-master01:~/k8s/dockerfile/web/magedu/wordpress/nginx# cat nginx.conf | grep -Ev '#|^$'
user  nginx nginx;
worker_processes  auto;
events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    client_max_body_size 10M;
    client_body_buffer_size 16k;
    client_body_temp_path  /apps/nginx/tmp   1 2 2;
    gzip  on;
    server {
        listen       80;
        server_name  blogs.magedu.net;
        location / {
            root    /home/nginx/wordpress;
            index   index.php index.html index.htm;
        }
        location ~ \.php$ {
            root           /home/nginx/wordpress;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
             include        fastcgi_params;
        }
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
}
---
root@k8s-master01:~/k8s/dockerfile/web/magedu/wordpress/nginx# cat run_nginx.sh
#!/bin/bash
#echo "nameserver 10.20.254.254" > /etc/resolv.conf
#chown nginx.nginx /home/nginx/wordpress/ -R
/apps/nginx/sbin/nginx
tail -f /etc/hosts
root@k8s-master01:~/k8s/dockerfile/web/magedu/wordpress/nginx# cat build-command.sh
#!/bin/bash
TAG=$1
docker build -t 192.168.13.197:8000/magedu/wordpress-nginx:${TAG} .
echo "镜像制作完成，即将上传至Harbor服务器"
sleep 1
docker push  192.168.13.197:8000/magedu/wordpress-nginx:${TAG}
echo "镜像上传完成"
root@k8s-master01:~/k8s/dockerfile/web/magedu/wordpress/nginx# ./build-command.sh
root@k8s-master01:~/k8s/dockerfile/web/magedu/wordpress/nginx# ./build-command.sh v1

6.4.6.3 构建php镜像
---
root@k8s-master01:~/k8s/dockerfile/web/magedu/wordpress/php# cat Dockerfile
#PHP Base Image
FROM 192.168.13.197:8000/baseimages/magedu-centos-base:7.8.2003

MAINTAINER  zhangshijie@magedu.net

RUN yum install -y  https://mirrors.tuna.tsinghua.edu.cn/remi/enterprise/remi-release-7.rpm && yum install  php56-php-fpm php56-php-mysql -y
ADD www.conf /opt/remi/php56/root/etc/php-fpm.d/www.conf
#RUN useradd nginx -u 2019
ADD run_php.sh /usr/local/bin/run_php.sh
EXPOSE 9000

CMD ["/usr/local/bin/run_php.sh"]
---
root@k8s-master01:~/k8s/dockerfile/web/magedu/wordpress/php# cat run_php.sh
#!/bin/bash
#echo "nameserver 10.20.254.254" > /etc/resolv.conf

/opt/remi/php56/root/usr/sbin/php-fpm
#/opt/remi/php56/root/usr/sbin/php-fpm --nodaemonize
tail -f /etc/hosts
---
root@k8s-master01:~/k8s/dockerfile/web/magedu/wordpress/php# cat build-command.sh
#!/bin/bash
TAG=$1
docker build -t 192.168.13.197:8000/magedu/wordpress-php-5.6:${TAG} .
echo "镜像制作完成，即将上传至Harbor服务器"
sleep 1
docker push 192.168.13.197:8000/magedu/wordpress-php-5.6:${TAG}
echo "镜像上传完成"
---
root@k8s-master01:~/k8s/dockerfile/web/magedu/wordpress/php# cat www.conf | grep -Ev ';|^$|\ $'
[www]
user = nginx
group = nginx
listen = 0.0.0.0:9000
pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35
slowlog = /opt/remi/php56/root/var/log/php-fpm/www-slow.log
php_admin_value[error_log] = /opt/remi/php56/root/var/log/php-fpm/www-error.log
php_admin_flag[log_errors] = on
php_value[session.save_handler] = files
php_value[session.save_path]    = /opt/remi/php56/root/var/lib/php/session
php_value[soap.wsdl_cache_dir]  = /opt/remi/php56/root/var/lib/php/wsdlcache
---
root@k8s-master01:~/k8s/dockerfile/web/magedu/wordpress/php# ./build-command.sh v1

6.4.6.4 k8s运行nginx+php
root@k8s-master01:~/k8s/yaml/magedu/wordpress# cat wordpress.yaml
kind: Deployment
#apiVersion: extensions/v1beta1
apiVersion: apps/v1
metadata:
  labels:
    app: wordpress-app
  name: wordpress-app-deployment
  namespace: magedu
spec:
  replicas: 1
  selector:
    matchLabels:
      app: wordpress-app
  template:
    metadata:
      labels:
        app: wordpress-app
    spec:
      containers:
      - name: wordpress-app-nginx
        image: 192.168.13.197:8000/magedu/wordpress-nginx:v1
        imagePullPolicy: Always
        ports:
        - containerPort: 80
          protocol: TCP
          name: http
        - containerPort: 443
          protocol: TCP
          name: https
        volumeMounts:
        - name: wordpress
          mountPath: /home/nginx/wordpress
          readOnly: false
      - name: wordpress-app-php
        image: 192.168.13.197:8000/magedu/wordpress-php-5.6:v1
        imagePullPolicy: Always
        ports:
        - containerPort: 9000
          protocol: TCP
          name: http
        volumeMounts:
        - name: wordpress
          mountPath: /home/nginx/wordpress
          readOnly: false
      volumes:
      - name: wordpress
        nfs:
          server: 192.168.13.67
          path: /data/k8sdata/magedu/wordpress
---
kind: Service
apiVersion: v1
metadata:
  labels:
    app: wordpress-app
  name: wordpress-app-spec
  namespace: magedu
spec:
  type: NodePort
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 80
    nodePort: 30031
  - name: https
    port: 443
    protocol: TCP
    targetPort: 443
    nodePort: 30033
  selector:
    app: wordpress-app
root@k8s-master01:~/k8s/yaml/magedu/wordpress# kubectl apply -f wordpress.yaml
root@k8s-master01:~/k8s/yaml/magedu/wordpress# kubectl get pods -n magedu | grep word
wordpress-app-deployment-7d6d5c4c97-n26gw        2/2     Running   0          45m

6.4.6.5 测试nginx+php功能
注: 1. 数据持久化 2. 数据共享，php写，nginx读
[root@wordpress-app-deployment-7d6d5c4c97-n26gw /]# df -TH | grep word		#这个是进入pod中的nginx容器，查看是否正常
192.168.13.67:/data/k8sdata/magedu/wordpress nfs4     1.1T  2.9G  1.1T   1% /home/nginx/wordpress
[root@wordpress-app-deployment-7d6d5c4c97-n26gw /]# df -TH | grep word		#这个是进入pod中的php容器，查看是否正常
192.168.13.67:/data/k8sdata/magedu/wordpress nfs4     1.1T  2.9G  1.1T   1% /home/nginx/wordpress
[root@wordpress-app-deployment-7d6d5c4c97-n26gw /]# cat /home/nginx/wordpress/index.html	#测试写入首页文件index.html
magedu n56
[root@wordpress-app-deployment-7d6d5c4c97-n26gw wordpress]# cat index.php 	#写入测试php首页，通过http://172.168.2.21:30031/index.php进行查看是否正常
<?php
        phpinfo();
?>

6.4.6.6 上传wordpress站点代码到nginx+php的nfs目录下
6.4.6.6.1 更改wordpress站点文件属主属组为nginx
[root@wordpress-app-deployment-7d6d5c4c97-5tbrt nginx]# chown -R nginx.nginx /home/nginx/wordpress     

6.4.6.6.2 配置wordpress数据库配置
mysql> create database wordpress;
mysql> grant all on wordpress.* to wordpress@'%' identified by 'wordpress';

6.4.6.6.3 进入web页面配置wordpress
注：在web访问http://172.168.2.21:30031 地址后，需要将需要立即将172.168.2.21:30031  IP地址配置成域名，后面在进行配置数据库等信息。因为现在不配置成域名的话，后面再通过添加域名来反向代理wordpress的service接口时会不正常，这个问题非常麻烦，就是这个问题困扰了我很久，一度以为是nginx代理有问题
注：一定要在之前创建的主从数据库中主库进行创建写入，从库造成不能进行操作，即数据库:mysql-0.mysql
> mysql-0.mysql.magedu.svc.homsom.local		#此为无关service所以可以解析
Server:         10.68.0.2
Address:        10.68.0.2#53
Name:   mysql-0.mysql.magedu.svc.homsom.local
Address: 172.20.217.104
root@k8s-master01:~/k8s# kubectl get svc -n magedu | grep word
wordpress-app-spec           NodePort    10.68.65.16     <none>        80:30031/TCP,443:30033/TCP                     115m
--访问http://172.168.2.21:30031进行配置



6.4.6.7 dubbo微服务
6.4.6.7.1 构建dubbo provider镜像
root@k8s-master01:~/k8s/dockerfile/web/magedu/dubbo/provider# cat dubbo-demo-provider-2.1.5/conf/dubbo.properties | grep -Ev '#|^$'
dubbo.container=log4j,spring
dubbo.application.name=demo-provider
dubbo.application.owner=
dubbo.registry.address=zookeeper://zookeeper1.magedu.svc.homsom.local:2181 | zookeeper://zookeeper2.magedu.svc.homsom.local:2181 | zookeeper://zookeeper3.magedu.svc.homsom.local:2181
dubbo.monitor.protocol=registry
dubbo.protocol.name=dubbo
dubbo.protocol.port=20880
dubbo.log4j.file=logs/dubbo-demo-provider.log
dubbo.log4j.level=WARN
---
root@k8s-master01:~/k8s/dockerfile/web/magedu/dubbo/provider# cat Dockerfile
#Dubbo provider
FROM 192.168.13.197:8000/pub-images/jdk-base:v8.212

MAINTAINER zhangshijie "zhangshijie@magedu.net"

RUN yum install file nc -y
RUN mkdir -p /apps/dubbo/provider
ADD dubbo-demo-provider-2.1.5/  /apps/dubbo/provider
ADD run_java.sh /apps/dubbo/provider/bin
RUN chown nginx.nginx /apps -R
RUN chmod a+x /apps/dubbo/provider/bin/*.sh

CMD ["/apps/dubbo/provider/bin/run_java.sh"]
---
root@k8s-master01:~/k8s/dockerfile/web/magedu/dubbo/provider# cat run_java.sh
#!/bin/bash
#echo "nameserver 223.6.6.6" > /etc/resolv.conf
#/usr/share/filebeat/bin/filebeat -c /etc/filebeat/filebeat.yml -path.home /usr/share/filebeat -path.config /etc/filebeat -path.data /var/lib/filebeat -path.logs /var/log/filebeat  &
su - nginx -c "/apps/dubbo/provider/bin/start.sh"
tail -f /etc/hosts
---
root@k8s-master01:~/k8s/dockerfile/web/magedu/dubbo/provider# cat build-command.sh
#!/bin/bash
docker build -t 192.168.13.197:8000/magedu/dubbo-demo-provider:v1  .
sleep 3
docker push 192.168.13.197:8000/magedu/dubbo-demo-provider:v1
---
root@k8s-master01:~/k8s/dockerfile/web/magedu/dubbo/provider# ./build-command.sh

6.4.6.7.2 测试provider
root@k8s-master01:~/k8s/yaml/magedu/dubbo/provider# cat provider.yaml
kind: Deployment
#apiVersion: extensions/v1beta1
apiVersion: apps/v1
metadata:
  labels:
    app: magedu-provider
  name: magedu-provider-deployment
  namespace: magedu
spec:
  replicas: 1
  selector:
    matchLabels:
      app: magedu-provider
  template:
    metadata:
      labels:
        app: magedu-provider
    spec:
      containers:
      - name: magedu-provider-container
        image: 192.168.13.197:8000/magedu/dubbo-demo-provider:v1
        #command: ["/apps/tomcat/bin/run_tomcat.sh"]
        #imagePullPolicy: IfNotPresent
        imagePullPolicy: Always
        ports:
        - containerPort: 20880
          protocol: TCP
          name: http

---
kind: Service
apiVersion: v1
metadata:
  labels:
    app: magedu-provider
  name: magedu-provider-spec
  namespace: magedu
spec:
  type: NodePort
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 20880
    #nodePort: 30001
  selector:
    app: magedu-provider
root@k8s-master01:~/k8s/yaml/magedu/dubbo/provider# kubectl apply -f provider.yaml
root@k8s-master01:~/k8s/dockerfile/web/magedu/dubbo/provider# kubectl get pod -o wide -n magedu | grep provider
magedu-provider-deployment-7656dfd74f-vpjkl      1/1     Running       0          4m      172.20.217.110   192.168.13.63   <none>           <none>

6.4.6.7.3 连接到zookeeper集群查看是否有dubbo provider数据 
此时连接到zookeeper客户端可查看到provider注册的信息，ip地址为：172.20.217.110跟上面一样，端口为20880
/dubbo/com.alibaba.dubbo.demo.DemoService/providers/dubbo%3A%2F%2F172.20.217.110%3A20880%2Fcom.alibaba.dubbo.demo.DemoService%3Fanyhost%3Dtrue%26application%3Ddemo-provider%26dubbo%3D2.1.5%26interface%3Dcom.alibaba.dubbo.demo.DemoService%26loadbalance%3Droundrobin%26methods%3DsayHello%26pid%3D57%26revision%3D2.1.5%26timestamp%3D1648286134301


6.4.6.7.4 consumer镜像构建
root@k8s-master01:~/k8s/dockerfile/web/magedu/dubbo/consumer# cat dubbo-demo-consumer-2.1.5/conf/dubbo.properties | grep -Ev '#|^$'
dubbo.container=log4j,spring
dubbo.application.name=demo-consumer
dubbo.application.owner=
dubbo.registry.address=zookeeper://zookeeper1.magedu.svc.homsom.local:2181 | zookeeper://zookeeper2.magedu.svc.homsom.local:2181 | zookeeper://zookeeper3.magedu.svc.homsom.local:2181
dubbo.monitor.protocol=registry
dubbo.log4j.file=logs/dubbo-demo-consumer.log
dubbo.log4j.level=WARN
---
root@k8s-master01:~/k8s/dockerfile/web/magedu/dubbo/consumer# cat Dockerfile
#Dubbo consumer
FROM 192.168.13.197:8000/pub-images/jdk-base:v8.212

MAINTAINER zhangshijie "zhangshijie@magedu.net"

RUN yum install file -y
RUN mkdir -p /apps/dubbo/consumer
ADD dubbo-demo-consumer-2.1.5  /apps/dubbo/consumer
ADD run_java.sh /apps/dubbo/consumer/bin
RUN chown nginx.nginx /apps -R
RUN chmod a+x /apps/dubbo/consumer/bin/*.sh

CMD ["/apps/dubbo/consumer/bin/run_java.sh"]
---
root@k8s-master01:~/k8s/dockerfile/web/magedu/dubbo/consumer# cat run_java.sh
#!/bin/bash
#echo "nameserver 223.6.6.6" > /etc/resolv.conf
#/usr/share/filebeat/bin/filebeat -c /etc/filebeat/filebeat.yml -path.home /usr/share/filebeat -path.config /etc/filebeat -path.data /var/lib/filebeat -path.logs /var/log/filebeat  &
su - nginx -c "/apps/dubbo/consumer/bin/start.sh"
tail -f /etc/hosts
---
root@k8s-master01:~/k8s/dockerfile/web/magedu/dubbo/consumer# cat build-command.sh
#!/bin/bash
docker build -t 192.168.13.197:8000/magedu/dubbo-demo-consumer:v1  .
sleep 3
docker push 192.168.13.197:8000/magedu/dubbo-demo-consumer:v1
root@k8s-master01:~/k8s/dockerfile/web/magedu/dubbo/consumer
---
root@k8s-master01:~/k8s/dockerfile/web/magedu/dubbo/consumer# ./build-command.sh

6.4.6.7.5 测试consumer
root@k8s-master01:~/k8s/yaml/magedu/dubbo/consumer# cat consumer.yaml
kind: Deployment
#apiVersion: extensions/v1beta1
apiVersion: apps/v1
metadata:
  labels:
    app: magedu-consumer
  name: magedu-consumer-deployment
  namespace: magedu
spec:
  replicas: 1
  selector:
    matchLabels:
      app: magedu-consumer
  template:
    metadata:
      labels:
        app: magedu-consumer
    spec:
      containers:
      - name: magedu-consumer-container
        image: 192.168.13.197:8000/magedu/dubbo-demo-consumer:v1
        #command: ["/apps/tomcat/bin/run_tomcat.sh"]
        #imagePullPolicy: IfNotPresent
        imagePullPolicy: Always
        ports:
        - containerPort: 80
          protocol: TCP
          name: http

---
kind: Service
apiVersion: v1
metadata:
  labels:
    app: magedu-consumer
  name: magedu-consumer-server
  namespace: magedu
spec:
  type: NodePort
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 80
    #nodePort: 30001
  selector:
    app: magedu-consumer
root@k8s-master01:~/k8s/yaml/magedu/dubbo/consumer# kubectl apply -f consumer.yaml
root@k8s-master01:~/k8s/yaml/magedu/dubbo/consumer# kubectl get pods -n magedu -o wide | grep consum
magedu-consumer-deployment-84547497d4-999wr      1/1     Running       0          21s     172.20.217.111   192.168.13.63   <none>           <none>

6.4.6.7.6 连接到zookeeper集群查看是否有dubbo consumer数据 

6.4.6.7.7 注册中心管理端,非必需，是基于tomcat来做的
root@k8s-master01:~/k8s/dockerfile/web/magedu/dubbo/dubboadmin# cat dubboadmin/WEB-INF/dubbo.properties | grep -Ev '#|^$'
dubbo.registry.address=zookeeper://zookeeper1.magedu.svc.homsom.local:2181
dubbo.admin.root.password=root
dubbo.admin.guest.password=guest
---
root@k8s-master01:~/k8s/dockerfile/web/magedu/dubbo/dubboadmin# cat Dockerfile
#Dubbo dubboadmin
FROM 192.168.13.197:8000/pub-images/tomcat-base:v8.5.43

MAINTAINER zhangshijie "zhangshijie@magedu.net"

RUN yum install unzip -y
ADD server.xml /apps/tomcat/conf/server.xml
ADD logging.properties /apps/tomcat/conf/logging.properties
ADD catalina.sh /apps/tomcat/bin/catalina.sh
ADD run_tomcat.sh /apps/tomcat/bin/run_tomcat.sh
ADD dubboadmin.war  /data/tomcat/webapps/dubboadmin.war   #此war包就是个zip文件，里面的配置文件dubboadmin/WEB-INF/dubbo.properties一定要确定是否更改，否则会报错运行不起来
RUN cd /data/tomcat/webapps && unzip dubboadmin.war && rm -rf dubboadmin.war && chown -R nginx.nginx /data /apps

EXPOSE 8080 8443

CMD ["/apps/tomcat/bin/run_tomcat.sh"]
---
root@k8s-master01:~/k8s/dockerfile/web/magedu/dubbo/dubboadmin# grep '/data/tomcat/webapps' server.xml
      <Host appBase="/data/tomcat/webapps" autoDeploy="true" name="localhost" unpackWARs="true">
---
root@k8s-master01:~/k8s/dockerfile/web/magedu/dubbo/dubboadmin# ./build-command.sh v1

6.4.6.7.8 部署dubboadmin
groot@k8s-master01:~/k8s/yaml/magedu/dubbo/dubboadmin# cat dubboadmin.yaml
kind: Deployment
#apiVersion: extensions/v1beta1
apiVersion: apps/v1
metadata:
  labels:
    app: magedu-dubboadmin
  name: magedu-dubboadmin-deployment
  namespace: magedu
spec:
  replicas: 1
  selector:
    matchLabels:
      app: magedu-dubboadmin
  template:
    metadata:
      labels:
        app: magedu-dubboadmin
    spec:
      containers:
      - name: magedu-dubboadmin-container
        image: 192.168.13.197:8000/magedu/dubboadmin:v1
        #command: ["/apps/tomcat/bin/run_tomcat.sh"]
        #imagePullPolicy: IfNotPresent
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
          protocol: TCP
          name: http

---
kind: Service
apiVersion: v1
metadata:
  labels:
    app: magedu-dubboadmin
  name: magedu-dubboadmin-service
  namespace: magedu
spec:
  type: NodePort
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 8080
    nodePort: 30080
  selector:
    app: magedu-dubboadmin
root@k8s-master01:~/k8s/yaml/magedu/dubbo/dubboadmin# kubectl apply -f dubboadmin.yaml
root@k8s-master01:~/k8s/yaml/magedu/dubbo/dubboadmin# kubectl get pods -o wide -n magedu  | grep dubboadmin
magedu-dubboadmin-deployment-bbd4b4966-9fnzk     1/1     Running       0          52s     172.20.217.116   192.168.13.63   <none>           <none>

6.4.6.7.8 访问dubboadmin
root@k8s-master01:~/k8s/yaml/magedu/dubbo/dubboadmin# kubectl get svc -n magedu | grep dubboadmin
magedu-dubboadmin-service    NodePort    10.68.41.5      <none>        80:30080/TCP                                   81s
WEB访问：http://172.168.2.21:30080		用户和密码都是root


6.4.6.7.9 伸缩provider pod查看日志
[root@magedu-provider-deployment-7656dfd74f-vpjkl logs]# tail -f stdout.log 
[20:24:26] Hello world5336, request from consumer: /172.20.217.111:51638		#172.20.217.111是消费者地址
[20:24:28] Hello world5337, request from consumer: /172.20.217.111:51638
[20:24:30] Hello world5338, request from consumer: /172.20.217.111:51638
--查看consumer日志
[root@magedu-consumer-deployment-84547497d4-999wr logs]# pwd
/apps/dubbo/consumer/logs
[root@magedu-consumer-deployment-84547497d4-999wr logs]# tail -f stdout.log 
[20:22:41] Hello world5284, response form provider: 172.20.217.110:20880		#172.20.217.110是生产者地址
[20:22:43] Hello world5285, response form provider: 172.20.217.110:20880
[20:22:45] Hello world5286, response form provider: 172.20.217.110:20880
--伸缩provider为2个pod，再查看consumer日志
root@k8s-master01:~/k8s/yaml/magedu/dubbo/dubboadmin# kubectl get deployment magedu-provider-deployment -n magedu
NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
magedu-provider-deployment   1/1     1            1           3h14m
root@k8s-master01:~/k8s/yaml/magedu/dubbo/dubboadmin# kubectl scale --replicas=2 deployment/magedu-provider-deployment -n magedu	#伸缩
deployment.apps/magedu-provider-deployment scaled
root@k8s-master01:~/k8s/yaml/magedu/dubbo/dubboadmin# kubectl get deployment magedu-provider-deployment -n magedu
NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
magedu-provider-deployment   2/2     2            2           3h15m
[root@magedu-consumer-deployment-84547497d4-999wr logs]# tail -f stdout.log 	#此时多了172.20.217.112生产者
20:30:20] Hello world5513, response form provider: 172.20.217.110:20880
[20:30:22] Hello world5514, response form provider: 172.20.217.110:20880
[20:30:24] Hello world5515, response form provider: 172.20.217.110:20880
[20:30:27] Hello world5516, response form provider: 172.20.217.110:20880
[20:30:29] Hello world5517, response form provider: 172.20.217.110:20880
[20:30:31] Hello world5518, response form provider: 172.20.217.112:20880
[20:30:33] Hello world5519, response form provider: 172.20.217.110:20880
[20:30:35] Hello world5520, response form provider: 172.20.217.112:20880
[20:30:37] Hello world5521, response form provider: 172.20.217.110:20880
[20:30:39] Hello world5522, response form provider: 172.20.217.112:20880
[20:30:41] Hello world5523, response form provider: 172.20.217.110:20880
[20:30:43] Hello world5524, response form provider: 172.20.217.112:20880
[20:30:45] Hello world5525, response form provider: 172.20.217.110:20880


6.4.6.8 ingress-nginx部署及使用
root@k8s-master01:~/k8s/yaml/ingress# kubectl apply -f ingress-controller-deploy.yaml
root@k8s-master01:~/k8s/yaml/ingress# cat ingress-controller-deploy.yaml

apiVersion: v1
kind: Namespace
metadata:
  name: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx

---
# Source: ingress-nginx/templates/controller-serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    helm.sh/chart: ingress-nginx-2.4.0
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.33.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: controller
  name: ingress-nginx
  namespace: ingress-nginx
---
# Source: ingress-nginx/templates/controller-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    helm.sh/chart: ingress-nginx-2.4.0
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.33.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: controller
  name: ingress-nginx-controller
  namespace: ingress-nginx
data:
---
# Source: ingress-nginx/templates/clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    helm.sh/chart: ingress-nginx-2.4.0
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.33.0
    app.kubernetes.io/managed-by: Helm
  name: ingress-nginx
  namespace: ingress-nginx
rules:
  - apiGroups:
      - ''
    resources:
      - configmaps
      - endpoints
      - nodes
      - pods
      - secrets
    verbs:
      - list
      - watch
  - apiGroups:
      - ''
    resources:
      - nodes
    verbs:
      - get
  - apiGroups:
      - ''
    resources:
      - services
    verbs:
      - get
      - list
      - update
      - watch
  - apiGroups:
      - extensions
      - networking.k8s.io   # k8s 1.14+
    resources:
      - ingresses
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - ''
    resources:
      - events
    verbs:
      - create
      - patch
  - apiGroups:
      - extensions
      - networking.k8s.io   # k8s 1.14+
    resources:
      - ingresses/status
    verbs:
      - update
  - apiGroups:
      - networking.k8s.io   # k8s 1.14+
    resources:
      - ingressclasses
    verbs:
      - get
      - list
      - watch
---
# Source: ingress-nginx/templates/clusterrolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    helm.sh/chart: ingress-nginx-2.4.0
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.33.0
    app.kubernetes.io/managed-by: Helm
  name: ingress-nginx
  namespace: ingress-nginx
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ingress-nginx
subjects:
  - kind: ServiceAccount
    name: ingress-nginx
    namespace: ingress-nginx
---
# Source: ingress-nginx/templates/controller-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  labels:
    helm.sh/chart: ingress-nginx-2.4.0
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.33.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: controller
  name: ingress-nginx
  namespace: ingress-nginx
rules:
  - apiGroups:
      - ''
    resources:
      - namespaces
    verbs:
      - get
  - apiGroups:
      - ''
    resources:
      - configmaps
      - pods
      - secrets
      - endpoints
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - ''
    resources:
      - services
    verbs:
      - get
      - list
      - update
      - watch
  - apiGroups:
      - extensions
      - networking.k8s.io   # k8s 1.14+
    resources:
      - ingresses
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - extensions
      - networking.k8s.io   # k8s 1.14+
    resources:
      - ingresses/status
    verbs:
      - update
  - apiGroups:
      - networking.k8s.io   # k8s 1.14+
    resources:
      - ingressclasses
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - ''
    resources:
      - configmaps
    resourceNames:
      - ingress-controller-leader-nginx
    verbs:
      - get
      - update
  - apiGroups:
      - ''
    resources:
      - configmaps
    verbs:
      - create
  - apiGroups:
      - ''
    resources:
      - endpoints
    verbs:
      - create
      - get
      - update
  - apiGroups:
      - ''
    resources:
      - events
    verbs:
      - create
      - patch
---
# Source: ingress-nginx/templates/controller-rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    helm.sh/chart: ingress-nginx-2.4.0
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.33.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: controller
  name: ingress-nginx
  namespace: ingress-nginx
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ingress-nginx
subjects:
  - kind: ServiceAccount
    name: ingress-nginx
    namespace: ingress-nginx
---
# Source: ingress-nginx/templates/controller-service-webhook.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    helm.sh/chart: ingress-nginx-2.4.0
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.33.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: controller
  name: ingress-nginx-controller-admission
  namespace: ingress-nginx
spec:
  type: ClusterIP
  ports:
    - name: https-webhook
      port: 443
      targetPort: webhook
  selector:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/component: controller
---
# Source: ingress-nginx/templates/controller-service.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    helm.sh/chart: ingress-nginx-2.4.0
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.33.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: controller
  name: ingress-nginx-controller
  namespace: ingress-nginx
spec:
  type: NodePort
  ports:
    - name: http
      port: 80
      protocol: TCP
      targetPort: http
      nodePort: 40080
    - name: https
      port: 443
      protocol: TCP
      targetPort: https
      nodePort: 40444
  selector:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/component: controller
---
# Source: ingress-nginx/templates/controller-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    helm.sh/chart: ingress-nginx-2.4.0
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.33.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: controller
  name: ingress-nginx-controller
  namespace: ingress-nginx
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: ingress-nginx
      app.kubernetes.io/instance: ingress-nginx
      app.kubernetes.io/component: controller
  revisionHistoryLimit: 10
  minReadySeconds: 0
  template:
    metadata:
      labels:
        app.kubernetes.io/name: ingress-nginx
        app.kubernetes.io/instance: ingress-nginx
        app.kubernetes.io/component: controller
    spec:
      dnsPolicy: ClusterFirst
      hostNetwork: true
      containers:
        - name: controller
          image: 192.168.13.197:8000/magedu/nginx-ingress-controller:0.33.0
          imagePullPolicy: IfNotPresent
          lifecycle:
            preStop:
              exec:
                command:
                  - /wait-shutdown
          args:
            - /nginx-ingress-controller
            - --election-id=ingress-controller-leader
            - --ingress-class=nginx
            - --configmap=ingress-nginx/ingress-nginx-controller
            - --validating-webhook=:8443
            - --validating-webhook-certificate=/usr/local/certificates/cert
            - --validating-webhook-key=/usr/local/certificates/key
          securityContext:
            capabilities:
              drop:
                - ALL
              add:
                - NET_BIND_SERVICE
            runAsUser: 101
            allowPrivilegeEscalation: true
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
          livenessProbe:
            httpGet:
              path: /healthz
              port: 10254
              scheme: HTTP
            initialDelaySeconds: 10
            periodSeconds: 10
            timeoutSeconds: 1
            successThreshold: 1
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /healthz
              port: 10254
              scheme: HTTP
            initialDelaySeconds: 10
            periodSeconds: 10
            timeoutSeconds: 1
            successThreshold: 1
            failureThreshold: 3
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
            - name: https
              containerPort: 443
              protocol: TCP
            - name: webhook
              containerPort: 8443
              protocol: TCP
          volumeMounts:
            - name: webhook-cert
              mountPath: /usr/local/certificates/
              readOnly: true
          resources:
            requests:
              cpu: 100m
              memory: 90Mi
      serviceAccountName: ingress-nginx
      terminationGracePeriodSeconds: 300
      volumes:
        - name: webhook-cert
          secret:
            secretName: ingress-nginx-admission
---
# Source: ingress-nginx/templates/admission-webhooks/validating-webhook.yaml
apiVersion: admissionregistration.k8s.io/v1beta1
kind: ValidatingWebhookConfiguration
metadata:
  labels:
    helm.sh/chart: ingress-nginx-2.4.0
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.33.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: admission-webhook
  name: ingress-nginx-admission
  namespace: ingress-nginx
webhooks:
  - name: validate.nginx.ingress.kubernetes.io
    rules:
      - apiGroups:
          - extensions
          - networking.k8s.io
        apiVersions:
          - v1beta1
        operations:
          - CREATE
          - UPDATE
        resources:
          - ingresses
    failurePolicy: Fail
    clientConfig:
      service:
        namespace: ingress-nginx
        name: ingress-nginx-controller-admission
        path: /extensions/v1beta1/ingresses
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ingress-nginx-admission
  annotations:
    helm.sh/hook: pre-install,pre-upgrade,post-install,post-upgrade
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
  labels:
    helm.sh/chart: ingress-nginx-2.4.0
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.33.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: admission-webhook
  namespace: ingress-nginx
rules:
  - apiGroups:
      - admissionregistration.k8s.io
    resources:
      - validatingwebhookconfigurations
    verbs:
      - get
      - update
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/clusterrolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ingress-nginx-admission
  annotations:
    helm.sh/hook: pre-install,pre-upgrade,post-install,post-upgrade
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
  labels:
    helm.sh/chart: ingress-nginx-2.4.0
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.33.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: admission-webhook
  namespace: ingress-nginx
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ingress-nginx-admission
subjects:
  - kind: ServiceAccount
    name: ingress-nginx-admission
    namespace: ingress-nginx
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/job-createSecret.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: ingress-nginx-admission-create
  annotations:
    helm.sh/hook: pre-install,pre-upgrade
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
  labels:
    helm.sh/chart: ingress-nginx-2.4.0
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.33.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: admission-webhook
  namespace: ingress-nginx
spec:
  template:
    metadata:
      name: ingress-nginx-admission-create
      labels:
        helm.sh/chart: ingress-nginx-2.4.0
        app.kubernetes.io/name: ingress-nginx
        app.kubernetes.io/instance: ingress-nginx
        app.kubernetes.io/version: 0.33.0
        app.kubernetes.io/managed-by: Helm
        app.kubernetes.io/component: admission-webhook
    spec:
      containers:
        - name: create
          image: jettech/kube-webhook-certgen:v1.2.0
          imagePullPolicy: IfNotPresent
          args:
            - create
            - --host=ingress-nginx-controller-admission,ingress-nginx-controller-admission.ingress-nginx.svc
            - --namespace=ingress-nginx
            - --secret-name=ingress-nginx-admission
      restartPolicy: OnFailure
      serviceAccountName: ingress-nginx-admission
      securityContext:
        runAsNonRoot: true
        runAsUser: 2000
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/job-patchWebhook.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: ingress-nginx-admission-patch
  annotations:
    helm.sh/hook: post-install,post-upgrade
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
  labels:
    helm.sh/chart: ingress-nginx-2.4.0
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.33.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: admission-webhook
  namespace: ingress-nginx
spec:
  template:
    metadata:
      name: ingress-nginx-admission-patch
      labels:
        helm.sh/chart: ingress-nginx-2.4.0
        app.kubernetes.io/name: ingress-nginx
        app.kubernetes.io/instance: ingress-nginx
        app.kubernetes.io/version: 0.33.0
        app.kubernetes.io/managed-by: Helm
        app.kubernetes.io/component: admission-webhook
    spec:
      containers:
        - name: patch
          image: jettech/kube-webhook-certgen:v1.2.0
          imagePullPolicy: IfNotPresent
          args:
            - patch
            - --webhook-name=ingress-nginx-admission
            - --namespace=ingress-nginx
            - --patch-mutating=false
            - --secret-name=ingress-nginx-admission
            - --patch-failure-policy=Fail
      restartPolicy: OnFailure
      serviceAccountName: ingress-nginx-admission
      securityContext:
        runAsNonRoot: true
        runAsUser: 2000
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ingress-nginx-admission
  annotations:
    helm.sh/hook: pre-install,pre-upgrade,post-install,post-upgrade
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
  labels:
    helm.sh/chart: ingress-nginx-2.4.0
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.33.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: admission-webhook
  namespace: ingress-nginx
rules:
  - apiGroups:
      - ''
    resources:
      - secrets
    verbs:
      - get
      - create
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ingress-nginx-admission
  annotations:
    helm.sh/hook: pre-install,pre-upgrade,post-install,post-upgrade
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
  labels:
    helm.sh/chart: ingress-nginx-2.4.0
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.33.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: admission-webhook
  namespace: ingress-nginx
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ingress-nginx-admission
subjects:
  - kind: ServiceAccount
    name: ingress-nginx-admission
    namespace: ingress-nginx
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ingress-nginx-admission
  annotations:
    helm.sh/hook: pre-install,pre-upgrade,post-install,post-upgrade
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
  labels:
    helm.sh/chart: ingress-nginx-2.4.0
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.33.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: admission-webhook
  namespace: ingress-nginx

  
6.4.6.9 metrics server部署、hpa控制器
hpa控制器用metrics server收集到的指标数据当作条件来自动伸缩pod
hpa控制器伸缩pod需要deploy控制器使用资源限制(limit,request)才可进行自动伸缩
root@k8s-master01:~/k8s/yaml/ingress# kube-controller-manager --help | grep horizontal-pod-autoscaler-sync-period
--horizontal-pod-autoscaler-sync-period duration      #定义pod数量水平伸缩的间隔周期，默认15秒
--horizontal-pod-autoscaler-cpu-initialization-period	#用于设置 pod 的初始化时间， 在此时间内的 pod，CPU 资源指标将不会被采纳，默认为5分钟
--horizontal-pod-autoscaler-initial-readiness-delay duration The period after pod	#用于设置 pod 准备时间， 在此时间内的 pod 统统被认为未就绪及不采集数据,默认为30秒


6.4.6.9.1 部署metrics server 
root@k8s-master01:~/k8s/yaml/metrics-server# cat metrics-server-v0.4.4.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    k8s-app: metrics-server
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    rbac.authorization.k8s.io/aggregate-to-view: "true"
  name: system:aggregated-metrics-reader
rules:
- apiGroups:
  - metrics.k8s.io
  resources:
  - pods
  - nodes
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    k8s-app: metrics-server
  name: system:metrics-server
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - nodes
  - nodes/stats
  - namespaces
  - configmaps
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server-auth-reader
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: extension-apiserver-authentication-reader
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server:system:auth-delegator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: system:metrics-server
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:metrics-server
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: v1
kind: Service
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  ports:
  - name: https
    port: 443
    protocol: TCP
    targetPort: https
  selector:
    k8s-app: metrics-server
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: metrics-server
  strategy:
    rollingUpdate:
      maxUnavailable: 0
  template:
    metadata:
      labels:
        k8s-app: metrics-server
    spec:
      containers:
      - args:
        - --cert-dir=/tmp
        - --secure-port=4443
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-use-node-status-port
        image: 192.168.13.197:8000/baseimages/metrics-server:v0.4.4
        imagePullPolicy: IfNotPresent
        livenessProbe:
          failureThreshold: 3
          httpGet:
            path: /livez
            port: https
            scheme: HTTPS
          periodSeconds: 10
        name: metrics-server
        ports:
        - containerPort: 4443
          name: https
          protocol: TCP
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /readyz
            port: https
            scheme: HTTPS
          periodSeconds: 10
        securityContext:
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
        volumeMounts:
        - mountPath: /tmp
          name: tmp-dir
      nodeSelector:
        kubernetes.io/os: linux
      priorityClassName: system-cluster-critical
      serviceAccountName: metrics-server
      volumes:
      - emptyDir: {}
        name: tmp-dir
---
apiVersion: apiregistration.k8s.io/v1
kind: APIService
metadata:
  labels:
    k8s-app: metrics-server
  name: v1beta1.metrics.k8s.io
spec:
  group: metrics.k8s.io
  groupPriorityMinimum: 100
  insecureSkipTLSVerify: true
  service:
    name: metrics-server
    namespace: kube-system
  version: v1beta1
  versionPriority: 100
root@k8s-master01:~/k8s/yaml/metrics-server# kubectl apply -f metrics-server-v0.4.4.yaml
root@k8s-master01:~/k8s/yaml/metrics-server# kubectl top nodes	#部署完metrics server后就可以查看node和pod的资源使用情况了， 此时dashboard也有node和pod的资源图标显示了
W0326 23:18:07.870056    7197 top_node.go:119] Using json format to get metrics. Next release will switch to protocol-buffers, switch early by passing --use-protocol-buffers flag
NAME            CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
172.168.2.21    391m         19%    1276Mi          100%
172.168.2.22    297m         14%    1182Mi          93%
172.168.2.23    516m         25%    1180Mi          92%
172.168.2.24    250m         12%    846Mi           66%
172.168.2.25    176m         8%     1126Mi          88%
172.168.2.26    1069m        53%    576Mi           45%
192.168.13.63   572m         7%     4284Mi          37%
root@k8s-master01:~/k8s/yaml/metrics-server# kubectl top pods -A
W0326 23:19:04.471483    8139 top_pod.go:140] Using json format to get metrics. Next release will switch to protocol-buffers, switch early by passing --use-protocol-buffers flag
NAMESPACE              NAME                                             CPU(cores)   MEMORY(bytes)
ingress-nginx          ingress-nginx-controller-645b99897d-6rm9l        2m           64Mi
kube-system            calico-kube-controllers-647f956d86-m5ds9         10m          14Mi
kube-system            calico-node-fl565                                53m          41Mi
kube-system            calico-node-ldrjs                                59m          48Mi
kube-system            calico-node-qnvt9                                68m          35Mi
kube-system            calico-node-t9rh6                                103m         37Mi
kube-system            calico-node-vbvts                                35m          55Mi
kube-system            calico-node-x9tjb                                57m          43Mi
kube-system            calico-node-zknjn                                34m          123Mi
kube-system            coredns-5fc7c5b494-nj8zj                         7m           12Mi
kube-system            metrics-server-6557798c77-cl9x2                  4m           25Mi
kubernetes-dashboard   dashboard-metrics-scraper-67d4cf4b45-q9568       1m           6Mi
kubernetes-dashboard   kubernetes-dashboard-7df675bc5f-8phww            1m           30Mi
magedu                 deploy-devops-redis-749878f59d-gf856             1m           12Mi
magedu                 magedu-consumer-deployment-84547497d4-999wr      2m           307Mi
magedu                 magedu-dubboadmin-deployment-bbd4b4966-sts92     306m         685Mi
magedu                 magedu-jenkins-deployment-5f94c58f86-kc2hg       2m           539Mi
magedu                 magedu-nginx-deployment-769d4567ff-8sm6c         0m           9Mi
magedu                 magedu-provider-deployment-7656dfd74f-fq652      2m           334Mi
magedu                 magedu-provider-deployment-7656dfd74f-vpjkl      1m           346Mi
magedu                 magedu-tomcat-app1-deployment-65747746b9-dfzfl   1m           486Mi
magedu                 mysql-0                                          23m          221Mi
magedu                 wordpress-app-deployment-7d6d5c4c97-5tbrt        1m           433Mi
magedu                 zookeeper1-749d87b7c5-stk5w                      1m           135Mi
magedu                 zookeeper2-5f5fcb7f4d-s5pgp                      1m           139Mi
magedu                 zookeeper3-c857bb585-txchq                       1m           128Mi


6.4.6.9.2 yaml文件创建hpa控制器，一般每个项目下都会放一个hpa文件，可选用或者不用
root@k8s-master01:~/k8s/yaml/magedu/tomcat-app1# kubectl get pods -n magedu | grep tomcat
magedu-tomcat-app1-deployment-65747746b9-dfzfl   1/1     Running       1          3d5h
root@k8s-master01:~/k8s/yaml/magedu/tomcat-app1# kubectl apply -f hpa.yaml
root@k8s-master01:~/k8s/yaml/magedu/tomcat-app1# kubectl get hpa -n magedu
NAME                               REFERENCE                                  TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
magedu-tomcat-app1-podautoscaler   Deployment/magedu-tomcat-app1-deployment   <unknown>/60%   2         5         0          6s
root@k8s-master01:~/k8s/yaml/magedu/tomcat-app1# kubectl get hpa -n magedu		#此时有一个副本了，因为最小为2个pod
NAME                               REFERENCE                                  TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
magedu-tomcat-app1-podautoscaler   Deployment/magedu-tomcat-app1-deployment   <unknown>/60%   2         5         1          23s
root@k8s-master01:~/k8s/yaml/magedu/tomcat-app1# kubectl get pods -n magedu | grep tomcat
magedu-tomcat-app1-deployment-65747746b9-dfzfl   1/1     Running       1          3d5h
magedu-tomcat-app1-deployment-65747746b9-zdj9l   1/1     Running       0          18s






















</pre>