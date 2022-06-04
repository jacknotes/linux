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
2. scheduler和controller-manager单实例运行: scheduler和controller-manager会修改集群状态，多实例运行会产生竞争状态。通过--leader-elect机制，只有领导者实例才能运行，其它实例处于standby状态；当领导者实例宕机时，剩余的实例选举产生新的领导者。领导者选举的方法：多个实例抢占创建endpoints资源，创建成功者为领导者。比如多个scheduler实例抢占创建endpoints资源：kube-scheduler
# kubectl get endpoints kube-scheduler -n kube-system -o yaml
apiVersion: v1
kind: Endpoints
metadata:
  annotations:
    control-plane.alpha.kubernetes.io/leader: '{"holderIdentity":"master1_293eaef2-fd7e-4ae9-aae7-e78615454881","leaseDurationSeconds":15,"acquireTime":"2021-10-06T20:46:43Z","renewTime":"2021-10-19T02:49:21Z","leaderTransitions":165}'
  creationTimestamp: "2021-02-01T03:10:48Z"
......
查询kube-scheduler endpoint资源，可以看到此时master1上的scheduler是active状态，其它实例则为standby。
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
只保留1个kube-controller-manager，而kube-scheduler3个节点全部关闭，在创建deployment和service时候，任务会被创建成功，但是pod会被一直pending，因为pod没有调度器调度，此时开启一个kube-scheduler后，pending状态的pod正常运行。
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
root@ansible:~/ansible# ssh-keygen -t rsa
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
----注-----
SERVICE_CIDR="10.68.0.0/16"		#service网络，每个IP地址都是32位掩码，没有子网划分，所以有2^16=65536个service地址
CLUSTER_CIDR="172.20.0.0/16"	#pod网络，如果是calico每个子网掩码是255.255.255.192，也就是可以运行2^10=1024个节点，每个节点只能运行62个pod。如果是flannel每个子网掩码是255.255.255.0，也就是可以运行2^8=256个节点，每个节点可以运行254个pod。
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
MASTER_CERT_HOSTS:
  - "10.1.1.1"
  - "k8s.test.io"
  - "k8s-api.hs.com"	#增加apiserver信任主机名，用于外部访问apiserver时的高可用域名或ip地址，可写多个备用，否则后续会报"Unable to connect to the server: x509: certificate is valid for 127.0.0.1, 172.168.2.23, 172.168.2.21, 172.168.2.22, 10.6, 10.1.1.1, not 192.168.13.50"
# node节点最大pod 数
MAX_PODS: 300
# role:network [flannel,calico,cilium,kube-ovn,kube-router]，我们选择的是calico，所以配置calico就可以了
# ----calico
# [calico]设置 CALICO_IPV4POOL_IPIP=“off”,可以提高网络性能，条件限制详见 docs/setup/calico.md，为Always开启跨子网，为了以后网络扩展可以打开
CALICO_IPV4POOL_IPIP: "Always"
# role:cluster-addon	所有插件不自动安装，后面手动安装
# coredns 自动安装
dns_install: "no"
ENABLE_LOCAL_DNS_CACHE: false	#测关闭DNS缓存
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




#####20220604----配置kube-controller-manager驱逐不健康节点的时间
###适用于kubernetes v1.13之前
root@k8s-master01:~# cat /etc/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \
  --bind-address=0.0.0.0 \
  --allocate-node-cidrs=true \
  --cluster-cidr=172.20.0.0/16 \
  --cluster-name=kubernetes \
  --cluster-signing-cert-file=/etc/kubernetes/ssl/ca.pem \
  --cluster-signing-key-file=/etc/kubernetes/ssl/ca-key.pem \
  --kubeconfig=/etc/kubernetes/kube-controller-manager.kubeconfig \
  --leader-elect=true \
  --node-cidr-mask-size=24 \
  --root-ca-file=/etc/kubernetes/ssl/ca.pem \
  --service-account-private-key-file=/etc/kubernetes/ssl/ca-key.pem \
  --service-cluster-ip-range=10.68.0.0/16 \
  --use-service-account-credentials=true \
  --v=2 \
  --node-monitor-period=5s \			#每隔5s和node联系一次，判定node是否失联。默认值为5s
  --node-monitor-grace-period=30s \		#当node失联30s后，判定node为NotReady状态。默认值为40s
  --node-startup-grace-period=1m0s \	#在NotReady基础上，当node失联1m0s后，判定node为UnHealthy状态。默认值为1m0s
  --pod-eviction-timeout=30s			#在UnHealthy基础上，当node失联30s后，开始删除原node上的pod进行重建。默认值为5m0s
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
-----

###v1.18以后的配置，当前集群版本为v1.23.7
root@k8s-master01:~/git/k8s-deploy/frontend-www-homsom-com-test/deploy# /usr/local/bin/kube-controller-manager --help 
--enable-taint-manager=true		#此参数是v1.18以后的参数，默认为true，意思为开启污点管理来驱逐pod，v1.13 >= v1.18参数为TaintBasedEvictions=true

root@k8s-master01:~# /usr/local/bin/kube-apiserver --help | grep -i -C 5 toleration-seconds
      --default-not-ready-toleration-seconds int       Indicates the tolerationSeconds of the toleration for notReady:NoExecute that is added by default to every pod that does not already have such a toleration. (default 300)
      --default-unreachable-toleration-seconds int     Indicates the tolerationSeconds of the toleration for unreachable:NoExecute that is added by default to every pod that does not already have such a toleration. (default 300)

root@ansible:~# kubectl describe pods client	#在基于污点的驱逐开启状态下node-startup-grace-period 和 pod-eviction-timeout 参数配置的时间不再生效，pod状态下可以看到pod什么情况下被驱逐及驱逐时间
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s

#配置kube-apiserver
root@k8s-master01:~/git/k8s-deploy/frontend-www-homsom-com-test/deploy# cat /etc/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-apiserver \
  --allow-privileged=true \
  --anonymous-auth=false \
  --api-audiences=api,istio-ca \
  --authorization-mode=Node,RBAC \
  --bind-address=172.168.2.21 \
  --client-ca-file=/etc/kubernetes/ssl/ca.pem \
  --endpoint-reconciler-type=lease \
  --etcd-cafile=/etc/kubernetes/ssl/ca.pem \
  --etcd-certfile=/etc/kubernetes/ssl/kubernetes.pem \
  --etcd-keyfile=/etc/kubernetes/ssl/kubernetes-key.pem \
  --etcd-servers=https://172.168.2.23:2379,https://172.168.2.22:2379,https://172.168.2.21:2379 \
  --kubelet-certificate-authority=/etc/kubernetes/ssl/ca.pem \
  --kubelet-client-certificate=/etc/kubernetes/ssl/kubernetes.pem \
  --kubelet-client-key=/etc/kubernetes/ssl/kubernetes-key.pem \
  --secure-port=6443 \
  --service-account-issuer=https://kubernetes.default.svc \
  --service-account-signing-key-file=/etc/kubernetes/ssl/ca-key.pem \
  --service-account-key-file=/etc/kubernetes/ssl/ca.pem \
  --service-cluster-ip-range=10.68.0.0/16 \
  --service-node-port-range=30000-62767 \
  --tls-cert-file=/etc/kubernetes/ssl/kubernetes.pem \
  --tls-private-key-file=/etc/kubernetes/ssl/kubernetes-key.pem \
  --requestheader-client-ca-file=/etc/kubernetes/ssl/ca.pem \
  --requestheader-allowed-names= \
  --requestheader-extra-headers-prefix=X-Remote-Extra- \
  --requestheader-group-headers=X-Remote-Group \
  --requestheader-username-headers=X-Remote-User \
  --proxy-client-cert-file=/etc/kubernetes/ssl/aggregator-proxy.pem \
  --proxy-client-key-file=/etc/kubernetes/ssl/aggregator-proxy-key.pem \
  --enable-aggregator-routing=true \
  --v=2 \
  --default-not-ready-toleration-seconds=60 \	#添加此两行，默认匹配到任何一个将进行驱逐
  --default-unreachable-toleration-seconds=30
Restart=always
RestartSec=5
Type=notify
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
---
注：配置kube-apiserver驱逐时间只针对新创建的pod生效，对于已经存在的pod默认还是300s

#配置kube-controller-manager
root@k8s-master01:~/git/k8s-deploy/frontend-www-homsom-com-test/deploy# cat /etc/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \
  --bind-address=0.0.0.0 \
  --allocate-node-cidrs=true \
  --cluster-cidr=172.20.0.0/16 \
  --cluster-name=kubernetes \
  --cluster-signing-cert-file=/etc/kubernetes/ssl/ca.pem \
  --cluster-signing-key-file=/etc/kubernetes/ssl/ca-key.pem \
  --kubeconfig=/etc/kubernetes/kube-controller-manager.kubeconfig \
  --leader-elect=true \
  --node-cidr-mask-size=24 \
  --root-ca-file=/etc/kubernetes/ssl/ca.pem \
  --service-account-private-key-file=/etc/kubernetes/ssl/ca-key.pem \
  --service-cluster-ip-range=10.68.0.0/16 \
  --use-service-account-credentials=true \
  --v=2 \
  --node-monitor-period=5s \	#v1.18以后默认只有此两个参数有效了
  --node-monitor-grace-period=30s
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
---
root@k8s-master01:~/git/k8s-deploy/frontend-www-homsom-com-test/deploy# scp /etc/systemd/system/kube-controller-manager.service 172.168.2.22:/etc/systemd/system/
root@k8s-master01:~/git/k8s-deploy/frontend-www-homsom-com-test/deploy# scp /etc/systemd/system/kube-controller-manager.service 172.168.2.23:/etc/systemd/system/
root@k8s-master01:~/git/k8s-deploy/frontend-www-homsom-com-test/deploy# ssh 172.168.2.22 'systemctl daemon-reload && systemctl restart kube-controller-manager.service && systemctl status kube-controller-manager.service | grep Active'
   Active: active (running) since Sat 2022-06-04 15:56:57 CST; 21ms ago
root@k8s-master01:~/git/k8s-deploy/frontend-www-homsom-com-test/deploy# ssh 172.168.2.23 'systemctl daemon-reload && systemctl restart kube-controller-manager.service && systemctl status kube-controller-manager.service | grep Active'
   Active: active (running) since Sat 2022-06-04 15:57:02 CST; 14ms ago
------------

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
#临时解决办法，把所有节点的kubelet /var/lib/kubelet/config.yaml DNS地址变更如下，并重启所有kubelet服务，以后的节点再增加时，需要把ansible config.yaml中DNS缓存关闭
clusterDNS:
- 10.68.0.2

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
        forward . 192.168.10.250 {	#转发服务器地址，可写多个
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
注：- --token-ttl=3600 参数表示dashboard会话超时时间为3600秒，默认为15分钟


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


5.9 dashboard token制作
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
livenessProbe    #存活探针，检测容器容器是否正在运行，如果存活探测失败，则kubelet会杀死容器，并且容器将受到其重启策略的影响，如果容器不提供存活探针，则默认状态为 Success，livenessProbe?于控制是否重启pod。
readinessProbe    #就绪探针，如果就绪探测失败，端点控制器将从与Pod匹配的所有Service的端点中删除该Pod的IP地址，初始延迟之前的就绪状态默认为Failure(失败)，如果容器不提供就绪探针，则默认状态为Success，readinessProbe用于控制pod是否添加至service。

6.3.0.2 Pod重启策略：
k8s在Pod出现异常的时候会自动将Pod重启以恢复Pod中的服务。
restartPolicy：
Always：当容器异常时，k8s自动重启该容器，ReplicationController/Replicaset/Deployment。
OnFailure：当容器失败时(容器停止运行且退出码不为0)，k8s自动重启该容器。
Never：不论容器运行状态如何都不会重启该容器,Job或CronJob。

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
#用于设置连接主机的?式（HTTP 还是 HTTPS），默认是 HTTP。
path: /monitor/index.html
#访问 HTTP 服务的路径。
httpHeaders:
#请求中自定义的 HTTP 头,HTTP 头字段允许重复。
port: 80
#访问容器的端?号或者端口名，如果数字必须在 1 ～ 65535 之间。

6.3.0.4 livenessProbe和readinessProbe的对比：
配置参数一样
livenessProbe #连续探测失败会重启、重建pod，readinessProbe不会执行重启或者重建Pod操作
livenessProbe #连续检测指定次数失败后会将容器置于(Crash Loop BackOff)且不可用，readinessProbe不会
readinessProbe #连续探测失败会从service的endpointd中删除该Pod，livenessProbe不具备此功能，但是会将容器挂起livenessProbe
livenessProbe用户控制是否重启pod，readinessProbe用于控制pod是否添加到service
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
注：如果后期添加域名那么访问会一直跳转到某个IP地址，可以尝试通过更改mysql数据库中的表wp_users,wp_options，看是否可以改变，此方法示尝试。
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



6.4.6.7 Kubernetes for CICD

6.4.6.7.1 运行nginx pod 
root@k8s-master01:~/k8s/yaml/magedu/nginx# cat nginx.yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  labels:
    app: magedu-nginx-deployment-label
  name: magedu-nginx-deployment
  namespace: magedu
spec:
  replicas: 1
  selector:
    matchLabels:
      app: magedu-nginx-selector
  template:
    metadata:
      labels:
        app: magedu-nginx-selector
    spec:
      containers:
      - name: magedu-nginx-container
        image: 192.168.13.197:8000/magedu/nginx-web1:v3
        #command: ["/apps/tomcat/bin/run_tomcat.sh"]
        #imagePullPolicy: IfNotPresent
        imagePullPolicy: Always
        ports:
        - containerPort: 80
          protocol: TCP
          name: http
        - containerPort: 443
          protocol: TCP
          name: https
        env:
        - name: "password"
          value: "123456"
        - name: "age"
          value: "20"
        resources:
          limits:
            cpu: 2
            memory: 2Gi
          requests:
            cpu: 500m
            memory: 1Gi

        volumeMounts:
        - name: magedu-images
          mountPath: /usr/local/nginx/html/webapp/images
          readOnly: false
        - name: magedu-static
          mountPath: /usr/local/nginx/html/webapp/static
          readOnly: false
      volumes:
      - name: magedu-images
        nfs:
          server: 192.168.13.67
          path: /data/k8sdata/magedu/images
      - name: magedu-static
        nfs:
          server: 192.168.13.67
          path: /data/k8sdata/magedu/static
      #nodeSelector:
      #  group: magedu
---
kind: Service
apiVersion: v1
metadata:
  labels:
    app: magedu-nginx-service-label
  name: magedu-nginx-service
  namespace: magedu
spec:
  type: NodePort
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 80
    nodePort: 40002
  - name: https
    port: 443
    protocol: TCP
    targetPort: 443
    nodePort: 40443
  selector:
    app: magedu-nginx-selector
---
root@k8s-master01:~/k8s/yaml/magedu/nginx# kubectl apply -f nginx.yaml
deployment.apps/magedu-nginx-deployment created
service/magedu-nginx-service created
root@k8s-master01:~/k8s/yaml/magedu/nginx# kubectl get pod -n magedu | grep nginx
magedu-nginx-deployment-769d4567ff-4mht9         1/1     Running   0          10s

6.4.6.7.2 金丝雀/灰度
业务镜像版本升级及回滚：
在指定的deployment中通过kubectl set image指定新版本的 镜像:tag 来实现更新代码的目的。构建三个不同版本的nginx镜像，第一次使用v1版本，后组逐渐升级到v2与v3，测试镜像版本升级与回滚操作

更新策略：
1. recreate(全部删除再全部安装新版本pod)   2. rollingUpdate(增加1个新pod，删除一个旧pod，直至全部更新，99%使用策略)

deployment控制器保持两种更新策略：默认为滚动更新
1.滚动更新(rolling update)：
滚动更新是默认的更新策略，滚动更新是基于新版本镜像创建新版本pod，然后删除⼀部分旧版本pod，然后再创建新版本pod，再删除⼀部分旧版本pod，直到就版本pod删除完成，滚动更新优势是在升级过程当中不会导致服务不可用，缺点是升级过程中会导致两个版本在短时间内会并存。具体升级过程是在执行更新操作后k8s会再创建一个新版本的ReplicaSet控制器，在删除旧版本的ReplicaSet控制器下的pod的同时会在新版本的ReplicaSet控制器下创建新的pod，直到旧版本的pod全部被删除完后再把旧版本的ReplicaSet控制器也回收掉。

在执行滚动更新的同时，为了保证服务的可用性，当前控制器内不可用的pod(pod需要拉取镜像执行创建和执行探针探测期间是不可用的)不能超出指定范围，因为需要多少保留指定数量的pod以保证服务可以被客户端正常访问，可以通过以下参数指定： 
#kubectl explain deployment.spec.strategy 
deployment.spec.strategy.rollingUpdate.maxSurge #指定在升级期间pod总数可以超出定义好的期望的pod数的个数或者百分比，默认为25%，如果设置为10%，假如当前是100个pod，那么升级时最多将创建110个pod即额外有10%的pod临时会超出当前(replicas)指定的副本数限制。
deployment.spec.strategy.rollingUpdate.maxUnavailable #指定在升级期间最大不可用的pod数，可以是整数或者当前pod的百分比，默认是25%，假如当前是100个pod，那么升级时最多可以有25个(25%)pod不可用即还要75个(75%)pod是可用的。
#注意：以上两个值不能同时为0，如果maxUnavailable最大不可用pod为0，maxSurge超出pod数也为0，那么将会导致pod无法进行滚动更新。

2.重建更新(recreate):
先删除现有的pod，然后基于新版本的镜像重建，优势是同时只有⼀个版本在线，不会产⽣多版本在线问题，缺点是pod删除后到pod重建成功中间的时间会导致服务无法访问，因此较少使用。

3. 暂停更新与恢复更新
root@k8s-master01:~# kubectl patch deployment magedu-nginx-deployment -p '{"spec": {"replicas": 3}}' -n magedu		#伸缩pod
root@k8s-master01:~# kubectl get pod -n magedu -o wide | grep nginx
magedu-nginx-deployment-769d4567ff-2vc2m         1/1     Running   0          32s     172.20.217.76    192.168.13.63   <none>           <none>
magedu-nginx-deployment-769d4567ff-4mht9         1/1     Running   0          11m     172.20.217.119   192.168.13.63   <none>           <none>
magedu-nginx-deployment-769d4567ff-q4zzg         1/1     Running   0          32s     172.20.217.75    192.168.13.63   <none>           <none>
root@k8s-master01:~# docker tag nginx:1.16.1 192.168.13.197:8000/magedu/nginx:1.16.1
root@k8s-master01:~# docker push 192.168.13.197:8000/magedu/nginx:1.16.1
root@k8s-master01:~# kubectl describe deployment magedu-nginx-deployment -n magedu | grep RollingUpdateStrategy
RollingUpdateStrategy:  25% max unavailable, 25% max surge
root@k8s-master01:~# kubectl set image deployment magedu-nginx-deployment magedu-nginx-container=192.168.13.197:8000/magedu/nginx:1.16.1 -n magedu && kubectl rollout pause deployment magedu-nginx-deployment -n magedu		#更新镜像并立即暂停，实现灰度发布
deployment.apps/magedu-nginx-deployment image updated
deployment.apps/magedu-nginx-deployment paused
root@k8s-master01:~/k8s/yaml/magedu/nginx# kubectl get pods -n magedu -w | grep magedu-nginx-deployment   	#pod的生成状态
magedu-nginx-deployment-769d4567ff-2vc2m         1/1     Running   0          116m
magedu-nginx-deployment-769d4567ff-4mht9         1/1     Running   0          127m
magedu-nginx-deployment-769d4567ff-q4zzg         1/1     Running   0          116m
magedu-nginx-deployment-866644b4bf-s5k8z         0/1     Pending   0          0s
magedu-nginx-deployment-866644b4bf-s5k8z         0/1     Pending   0          0s
magedu-nginx-deployment-866644b4bf-s5k8z         0/1     ContainerCreating   0          1s
magedu-nginx-deployment-866644b4bf-s5k8z         1/1     Running             0          17s
root@k8s-master01:~#  kubectl get pods -n magedu | grep magedu-nginx-deployment		#此时有4个pod
magedu-nginx-deployment-769d4567ff-2vc2m         1/1     Running   0          118m
magedu-nginx-deployment-769d4567ff-4mht9         1/1     Running   0          129m
magedu-nginx-deployment-769d4567ff-q4zzg         1/1     Running   0          118m
magedu-nginx-deployment-866644b4bf-s5k8z         1/1     Running   0          90s
root@k8s-master01:~# kubectl rollout resume deployment magedu-nginx-deployment -n magedu		#恢复更新
deployment.apps/magedu-nginx-deployment resumed
root@k8s-master01:~/k8s/yaml/magedu/nginx# kubectl get pods -n magedu -w | grep magedu-nginx-deployment
magedu-nginx-deployment-769d4567ff-2vc2m         1/1     Running   0          116m
magedu-nginx-deployment-769d4567ff-4mht9         1/1     Running   0          127m
magedu-nginx-deployment-769d4567ff-q4zzg         1/1     Running   0          116m
magedu-nginx-deployment-866644b4bf-s5k8z         0/1     Pending   0          0s
magedu-nginx-deployment-866644b4bf-s5k8z         0/1     Pending   0          0s
magedu-nginx-deployment-866644b4bf-s5k8z         0/1     ContainerCreating   0          1s
magedu-nginx-deployment-866644b4bf-s5k8z         1/1     Running             0          17s		#增加一个
magedu-nginx-deployment-769d4567ff-2vc2m         1/1     Terminating         0          119m	#从这里继续开始升级pod步骤，#删除一个
magedu-nginx-deployment-866644b4bf-r5fvs         0/1     Pending             0          1s
magedu-nginx-deployment-866644b4bf-r5fvs         0/1     Pending             0          1s
magedu-nginx-deployment-866644b4bf-r5fvs         0/1     ContainerCreating   0          1s
magedu-nginx-deployment-769d4567ff-2vc2m         0/1     Terminating         0          119m
magedu-nginx-deployment-866644b4bf-r5fvs         1/1     Running             0          5s		#增加一个
magedu-nginx-deployment-769d4567ff-q4zzg         1/1     Terminating         0          119m	#删除一个
magedu-nginx-deployment-866644b4bf-sv5vx         0/1     Pending             0          1s
magedu-nginx-deployment-866644b4bf-sv5vx         0/1     Pending             0          1s
magedu-nginx-deployment-866644b4bf-sv5vx         0/1     ContainerCreating   0          2s
magedu-nginx-deployment-769d4567ff-2vc2m         0/1     Terminating         0          119m
magedu-nginx-deployment-769d4567ff-2vc2m         0/1     Terminating         0          119m
magedu-nginx-deployment-769d4567ff-q4zzg         0/1     Terminating         0          119m
magedu-nginx-deployment-866644b4bf-sv5vx         1/1     Running             0          5s		#增加一个
magedu-nginx-deployment-769d4567ff-4mht9         1/1     Terminating         0          130m	#删除一个
magedu-nginx-deployment-769d4567ff-4mht9         0/1     Terminating         0          130m
magedu-nginx-deployment-769d4567ff-q4zzg         0/1     Terminating         0          119m
magedu-nginx-deployment-769d4567ff-q4zzg         0/1     Terminating         0          119m
magedu-nginx-deployment-769d4567ff-4mht9         0/1     Terminating         0          131m
magedu-nginx-deployment-769d4567ff-4mht9         0/1     Terminating         0          131m
root@k8s-master01:~# kubectl get pods -n magedu | grep magedu-nginx-deployment		#pod生成完成后最终为3个
magedu-nginx-deployment-866644b4bf-r5fvs         1/1     Running   0          41s
magedu-nginx-deployment-866644b4bf-s5k8z         1/1     Running   0          2m57s
magedu-nginx-deployment-866644b4bf-sv5vx         1/1     Running   0          35s


4. 另外一种滚动升级的方式就是写yaml文件
root@k8s-master01:~/k8s/yaml/deplooy-upgrade-case# cat tomcat-app1.yaml
kind: Deployment
#apiVersion: extensions/v1beta1
apiVersion: apps/v1
metadata:
  labels:
    app: magedu-tomcat-app1-deployment-label
  name: magedu-tomcat-app1-deployment
  namespace: magedu
spec:
  replicas: 3
  selector:
    matchLabels:
      app: magedu-tomcat-app1-selector
  template:
    metadata:
      labels:
        app: magedu-tomcat-app1-selector
    spec:
      containers:
      - name: magedu-tomcat-app1-container
        image: 192.168.13.197:8000/magedu/tomcat-app1:v2
        #command: ["/apps/tomcat/bin/run_tomcat.sh"]
        #imagePullPolicy: IfNotPresent
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
          protocol: TCP
          name: http
        env:
        - name: "password"
          value: "123456"
        - name: "age"
          value: "18"
        resources:
          limits:
            cpu: 1
            memory: "512Mi"
          requests:
            cpu: 500m
            memory: "512Mi"
        volumeMounts:
        - name: magedu-images
          mountPath: /usr/local/nginx/html/webapp/images
          readOnly: false
        - name: magedu-static
          mountPath: /usr/local/nginx/html/webapp/static
          readOnly: false
      volumes:
      - name: magedu-images
        nfs:
          server: 192.168.13.67
          path: /data/k8sdata/magedu/images
      - name: magedu-static
        nfs:
          server: 192.168.13.67
          path: /data/k8sdata/magedu/static
#      nodeSelector:
#        project: magedu
#        app: tomcat
---
root@k8s-master01:~/k8s/yaml/deplooy-upgrade-case# kubectl apply -f tomcat-app1.yaml --record
root@k8s-master01:~/k8s/yaml/deplooy-upgrade-case# kubectl get pods -n magedu -o wide  | grep tomcat
magedu-tomcat-app1-deployment-65747746b9-9wkt5   1/1     Running   0          29s     172.20.217.66    192.168.13.63   <none>           <none>
magedu-tomcat-app1-deployment-65747746b9-cmb6d   1/1     Running   0          34s     172.20.217.77    192.168.13.63   <none>           <none>
magedu-tomcat-app1-deployment-65747746b9-pgq5j   1/1     Running   0          39s     172.20.217.101   192.168.13.63   <none>           <none>
root@k8s-master01:~/k8s/yaml/deplooy-upgrade-case# cat tomcat-service.yaml
---
kind: Service
apiVersion: v1
metadata:
  labels:
    app: magedu-tomcat-app1-service-label
  name: magedu-tomcat-app1-service
  namespace: magedu
spec:
  type: NodePort
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 8080
    nodePort: 40003
  selector:
    app: magedu-tomcat-app1-selector
root@k8s-master01:~/k8s/yaml/deplooy-upgrade-case# kubectl apply -f tomcat-service.yaml
---
root@k8s-master01:~/k8s/yaml/deplooy-upgrade-case# kubectl get svc -n magedu | grep tomcat
magedu-tomcat-app1-service   NodePort    10.68.168.250   <none>        80:40003/TCP                                   5m54s
[root@NFSServer ~]# while true;do date; curl http://172.168.2.24:40003/myapp/index.html;sleep 0.2;done
--小插曲，经过一会儿，deployment自动由3个副本变成2个，找到原因是hpa导致
root@k8s-master01:~/k8s/yaml/deplooy-upgrade-case# kubectl get hpa -n magedu
NAME                               REFERENCE                                  TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
magedu-tomcat-app1-podautoscaler   Deployment/magedu-tomcat-app1-deployment   0%/60%    2         5         2          3d22h
root@k8s-master01:~/k8s/yaml/deplooy-upgrade-case# kubectl apply -f tomcat-app1.yaml


--新建一个deployment，增加version标签
root@k8s-master01:~/k8s/yaml/deplooy-upgrade-case# cat tomcat-app1-v2.yaml
kind: Deployment
#apiVersion: extensions/v1beta1
apiVersion: apps/v1
metadata:
  labels:
    app: magedu-tomcat-app1-deployment-label-v2
    version: v2
  name: magedu-tomcat-app1-deployment-v2
  namespace: magedu
spec:
  replicas: 1
  selector:
    matchLabels:
      app: magedu-tomcat-app1-selector
      version: v2
  template:
    metadata:
      labels:
        app: magedu-tomcat-app1-selector
        version: v2
    spec:
      containers:
      - name: magedu-tomcat-app1-container
        image: 192.168.13.197:8000/magedu/tomcat-app2:v1
        #command: ["/apps/tomcat/bin/run_tomcat.sh"]
        #imagePullPolicy: IfNotPresent
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
          protocol: TCP
          name: http
        env:
        - name: "password"
          value: "123456"
        - name: "age"
          value: "18"
        resources:
          limits:
            cpu: 1
            memory: "512Mi"
          requests:
            cpu: 500m
            memory: "512Mi"
        volumeMounts:
        - name: magedu-images
          mountPath: /usr/local/nginx/html/webapp/images
          readOnly: false
        - name: magedu-static
          mountPath: /usr/local/nginx/html/webapp/static
          readOnly: false
      volumes:
      - name: magedu-images
        nfs:
          server: 192.168.13.67
          path: /data/k8sdata/magedu/images
      - name: magedu-static
        nfs:
          server: 192.168.13.67
          path: /data/k8sdata/magedu/static
#      nodeSelector:
#        project: magedu
#        app: tomcat
---
root@k8s-master01:~/k8s/yaml/deplooy-upgrade-case# kubectl apply -f tomcat-app1-v2.yaml
root@k8s-master01:~/k8s/yaml/deplooy-upgrade-case# kubectl get pods -n magedu -o wide  | grep tomcat
magedu-tomcat-app1-deployment-65747746b9-9pbcq      1/1     Running   0          69s     172.20.217.93    192.168.13.63   <none>           <none>
magedu-tomcat-app1-deployment-65747746b9-rxlp7      1/1     Running   0          43m     172.20.217.92    192.168.13.63   <none>           <none>
magedu-tomcat-app1-deployment-65747746b9-vg44j      1/1     Running   0          43m     172.20.217.91    192.168.13.63   <none>           <none>
magedu-tomcat-app1-deployment-v2-797df58f6c-d225k   1/1     Running   0          25s     172.20.217.89    192.168.13.63   <none>           <none>
root@k8s-master01:~/k8s/yaml/deplooy-upgrade-case# cat tomcat-service-v2.yaml
---
kind: Service
apiVersion: v1
metadata:
  labels:
    app: magedu-tomcat-app1-service-label
  name: magedu-tomcat-app1-service
  namespace: magedu
spec:
  type: NodePort
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 8080
    nodePort: 40003
  selector:
    app: magedu-tomcat-app1-selector
    version: v2
[root@NFSServer ~]# while true;do date; curl http://172.168.2.24:40003/myapp/index.html;sleep 0.2;done	#此时service已经切换到v2了
Wed Mar 30 22:52:34 CST 2022
tomcat app2 for v2
Wed Mar 30 22:52:35 CST 2022
tomcat app2 for v2

root@k8s-master01:~/k8s/yaml/deplooy-upgrade-case# kubectl delete -f tomcat-app1.yaml	#此时无问题可以删除v1，若是有问题回滚v1，若是升级则更改此文件镜像版本为v3并且增加一个label version: v3，然后更改service yaml文件删除version: v2的标签，如果v3版本无问题，则增加version: v3 label，使service选择v3的deployment



6.4.6.8 jenkins,gitlab集成Kubernetes CICD
1. 下载jenkins和gitlab
wget https://mirrors.tuna.tsinghua.edu.cn/jenkins/debian-stable/jenkins_2.319.3_all.deb
wget https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/ubuntu/pool/bionic/main/g/gitlab-ce/gitlab-ce_14.8.4-ce.0_amd64.deb

2. 安装jdk
root@jenkins:~# apt install -y openjdk-11-jdk

3. 安装jenkins
root@jenkins:/etc/apt# apt update		#仓库源尽量用http协议，如果https有时会报证书错误
root@jenkins:~# dpkg -c jenkins_2.319.3_all.deb		#查看jenkins deb包中的文件
drwxr-xr-x root/root         0 2022-02-09 20:14 ./
drwxr-xr-x root/root         0 2022-02-09 20:14 ./etc/
drwxr-xr-x root/root         0 2022-02-09 20:14 ./etc/default/
-rw-r--r-- root/root      2775 2022-02-09 20:14 ./etc/default/jenkins
drwxr-xr-x root/root         0 2022-02-09 20:14 ./etc/init.d/
-rwxr-xr-x root/root      8184 2022-02-09 20:14 ./etc/init.d/jenkins
drwxr-xr-x root/root         0 2022-02-09 20:14 ./etc/logrotate.d/
-rw-r--r-- root/root       191 2022-02-09 20:14 ./etc/logrotate.d/jenkins
drwxr-xr-x root/root         0 2022-02-09 20:14 ./usr/
drwxr-xr-x root/root         0 2022-02-09 20:14 ./usr/share/
drwxr-xr-x root/root         0 2022-02-09 20:14 ./usr/share/doc/
drwxr-xr-x root/root         0 2022-02-09 20:14 ./usr/share/doc/jenkins/
-rw-r--r-- root/root       165 2022-02-09 20:14 ./usr/share/doc/jenkins/changelog.gz
-rw-r--r-- root/root      1498 2022-02-09 20:14 ./usr/share/doc/jenkins/copyright
drwxr-xr-x root/root         0 2022-02-09 20:14 ./usr/share/jenkins/
-rw-r--r-- root/root  72258627 2022-02-09 20:14 ./usr/share/jenkins/jenkins.war
drwxr-xr-x root/root         0 2022-02-09 20:14 ./var/
drwxr-xr-x root/root         0 2022-02-09 20:14 ./var/cache/
drwxr-xr-x root/root         0 2022-02-09 20:14 ./var/cache/jenkins/
drwxr-xr-x root/root         0 2022-02-09 20:14 ./var/lib/
drwxr-xr-x root/root         0 2022-02-09 20:14 ./var/lib/jenkins/
drwxr-xr-x root/root         0 2022-02-09 20:14 ./var/log/
drwxr-xr-x root/root         0 2022-02-09 20:14 ./var/log/jenkins/
root@jenkins:~# mv jenkins_2.319.3_all.deb /tmp/
root@jenkins:~# apt install -y /tmp/jenkins_2.319.3_all.deb
root@jenkins:~# systemctl stop jenkins.service
root@jenkins:~# grep -Ev '#|^$' /etc/default/jenkins
NAME=jenkins
JAVA_ARGS="-Djava.awt.headless=true -Dhudson.security.csrf.GlobalCrumbIssuerConfiguration.DISABLE_CSRF_PROTECTION=true"		#增加参数-Dhudson.security.csrf.GlobalCrumbIssuerConfiguration.DISABLE_CSRF_PROTECTION=true 使推送到gitlab后自动触发jenkins进行构建，新版本jenkins默认不支持，需要加此参数开启
PIDFILE=/var/run/$NAME/$NAME.pid
JENKINS_USER=root		#为了方便测试将用户和组改为root
JENKINS_GROUP=root
JENKINS_WAR=/usr/share/$NAME/$NAME.war
JENKINS_HOME=/var/lib/$NAME
RUN_STANDALONE=true
JENKINS_LOG=/var/log/$NAME/$NAME.log
JENKINS_ENABLE_ACCESS_LOG="no"
MAXOPENFILES=8192
HTTP_PORT=8080
PREFIX=/$NAME
JENKINS_ARGS="--webroot=/var/cache/$NAME/war --httpPort=$HTTP_PORT"
---
root@jenkins:~# systemctl start jenkins
root@jenkins:~# systemctl status jenkins | grep Active
   Active: active (exited) since Thu 2022-03-31 17:04:29 CST; 14s ago
root@jenkins:~# ss -tnl
State                Recv-Q                Send-Q                                Local Address:Port                               Peer Address:Port
LISTEN               0                     128                                   127.0.0.53%lo:53                                      0.0.0.0:*
LISTEN               0                     128                                         0.0.0.0:22                                      0.0.0.0:*
LISTEN               0                     50                                                *:8080                                          *:*
LISTEN               0                     128                                            [::]:22                                         [::]:*
-- WEB访问jenkins: http://172.168.2.13:8080/
复制其它jenkins安装好插件到新安装的jenkins目录/var/lib/jenkins/plubins/下，并重启jenkins即可


4. 安装gitlab
root@gitlab:~# dpkg -i gitlab-ce_14.8.4-ce.0_amd64.deb	#这个没有依赖关系
root@gitlab:~# grep -Ev '#|^$' /etc/gitlab/gitlab.rb
external_url 'http://172.168.2.14'		#配置外部URL 
root@gitlab:~# sudo gitlab-ctl reconfigure		#报如下错，原因是语言环境没有配置对
Running handlers:
There was an error running gitlab-ctl reconfigure:

execute[/opt/gitlab/embedded/bin/initdb -D /var/opt/gitlab/postgresql/data -E UTF8] (postgresql::enable line 49) had an error: Mixlib::ShellOut::ShellCommandFailed: Expected process to exit with [0], but received '1'
---- Begin output of /opt/gitlab/embedded/bin/initdb -D /var/opt/gitlab/postgresql/data -E UTF8 ----
STDOUT: The files belonging to this database system will be owned by user "gitlab-psql".
This user must also own the server process.

The database cluster will be initialized with locale "en_US".
STDERR: initdb: error: encoding mismatch
The encoding you selected (UTF8) and the encoding that the
selected locale uses (LATIN1) do not match.  This would lead to
misbehavior in various character string processing functions.
Rerun initdb and either do not specify an encoding explicitly,
or choose a matching combination.
---- End output of /opt/gitlab/embedded/bin/initdb -D /var/opt/gitlab/postgresql/data -E UTF8 ----
Ran /opt/gitlab/embedded/bin/initdb -D /var/opt/gitlab/postgresql/data -E UTF8 returned 1
--解决方法
export LC_CTYPE=en_US.UTF-8 export LC_ALL=en_US.UTF-8	
root@gitlab:~# cat /etc/default/locale
LANG=en_US.UTF-8
LANGUAGE="en_US:"
root@gitlab:~# sudo gitlab-ctl reconfigure		#再次执行
root@gitlab:~# cat /etc/gitlab/initial_root_password | grep '^Password'		#成功后生成初始密码在这
Password: sPvtRnjSqF/u6cFmSfvSMy9VeSb6Bv65IJlA//avX9I=
root@gitlab:~# systemctl restart gitlab-runsvdir.service	#再重启下gitlab
WEB访问http://172.168.2.14/更改密码    	#root | 12345678   # user1   |  12345678


5. 测试pull gitlab项目
root@jenkins:~# apt install -y git
root@jenkins:~/gitlabrepo# git clone http://172.168.2.14/magedu/app1.git	#经过测试是可以clone
Cloning into 'app1'...
Username for 'http://172.168.2.14': user1
Password for 'http://user1@172.168.2.14':
remote: Enumerating objects: 6, done.
remote: Counting objects: 100% (6/6), done.
remote: Compressing objects: 100% (3/3), done.
remote: Total 6 (delta 0), reused 0 (delta 0), pack-reused 0
Unpacking objects: 100% (6/6), done.

6. 配置gitlab部署key
root@jenkins:~/gitlabrepo# ssh-keygen  -t rsa
root@jenkins:~/gitlabrepo# cat /root/.ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCi9mOxMCBwYdDGjBBxspldclkN9l0PxQIZbUBGoNI3OIJnIkMC0maZdMcnbm0wwLVsmnx2lOfOfoRzRrMeZ5cf04IjZMj56qU3SMebVsMk0KSafhj9noxzyhLP2k1QqyK8rH7fEQTekd/aG7DfTPTHUVftfVgiW7RpgW4MESwmO3UaU51ZfstgcHdlx6Q1sP+T2LL7zwJxLho5U47rOTyGW3yz7hU6TKGxG8aMz1ibf4wzkmTFcNTwKnWeIbTuSC7z63s8J7DdeyrKid2pMd+TyVpXzD8hjAbOlsU8mIeVQ3TGzS0zd6hvXFXRwx2vuXEkr62dYDuzFTUCfZdydKEn root@jenkins
root@jenkins:~/gitlabrepo# git clone git@172.168.2.14:magedu/app1.git	#测试是否可以直接clone
Cloning into 'app1'...
remote: Enumerating objects: 9, done.
remote: Counting objects: 100% (9/9), done.
remote: Compressing objects: 100% (5/5), done.
remote: Total 9 (delta 0), reused 0 (delta 0), pack-reused 0
Receiving objects: 100% (9/9), done.
root@jenkins:~/gitlabrepo# mkdir -p /data/scripts
root@jenkins:~/gitlabrepo# cd /data/scripts
root@jenkins:/data/scripts# cat deploy.sh
#!/bin/sh
echo '123'

7. 部署脚本
root@jenkins:/data# mkdir -p /data/gitdata/magedu
root@k8s-master01:~# mkdir -p /opt/k8s-data/dockerfile/web/magedu/tomcat-app1
---部署脚本示例----
#!/bin/bash
#Author: ZhangShiJie
#Date: 2018-10-24
#Version: v1

#记录脚本开始执行时间
starttime=`date +'%Y-%m-%d %H:%M:%S'`

#变量
SHELL_DIR="/root/scripts"
SHELL_NAME="$0"
K8S_CONTROLLER1="172.31.7.101"
K8S_CONTROLLER2="172.31.7.102"
DATE=`date +%Y-%m-%d_%H_%M_%S`
METHOD=$1
Branch=$2


if test -z $Branch;then
  Branch=develop
fi


function Code_Clone(){
  Git_URL="git@172.31.5.101:magedu/app1.git"
  DIR_NAME=`echo ${Git_URL} |awk -F "/" '{print $2}' | awk -F "." '{print $1}'`
  DATA_DIR="/data/gitdata/magedu"
  Git_Dir="${DATA_DIR}/${DIR_NAME}"
  cd ${DATA_DIR} &&  echo "即将清空上一版本代码并获取当前分支最新代码" && sleep 1 && rm -rf ${DIR_NAME}
  echo "即将开始从分支${Branch} 获取代码" && sleep 1
  git clone -b ${Branch} ${Git_URL} 
  echo "分支${Branch} 克隆完成，即将进行代码编译!" && sleep 1
  #cd ${Git_Dir} && mvn clean package
  #echo "代码编译完成，即将开始将IP地址等信息替换为测试环境"
  #####################################################
  sleep 1
  cd ${Git_Dir}
  tar czf ${DIR_NAME}.tar.gz  ./*
}

#将打包好的压缩文件拷贝到k8s 控制端服务器
function Copy_File(){
  echo "压缩文件打包完成，即将拷贝到k8s 控制端服务器${K8S_CONTROLLER1}" && sleep 1
  scp ${Git_Dir}/${DIR_NAME}.tar.gz root@${K8S_CONTROLLER1}:/opt/k8s-data/dockerfile/web/magedu/tomcat-app1
  echo "压缩文件拷贝完成,服务器${K8S_CONTROLLER1}即将开始制作Docker 镜像!" && sleep 1
}

#到控制端执行脚本制作并上传镜像
function Make_Image(){
  echo "开始制作Docker镜像并上传到Harbor服务器" && sleep 1
  ssh root@${K8S_CONTROLLER1} "cd /opt/k8s-data/dockerfile/web/magedu/tomcat-app1 && bash build-command.sh ${DATE}"
  echo "Docker镜像制作完成并已经上传到harbor服务器" && sleep 1
}

#到控制端更新k8s yaml文件中的镜像版本号,从而保持yaml文件中的镜像版本号和k8s中版本号一致
function Update_k8s_yaml(){
  echo "即将更新k8s yaml文件中镜像版本" && sleep 1
  ssh root@${K8S_CONTROLLER1} "cd /opt/k8s-data/yaml/magedu/tomcat-app1 && sed -i 's/image: harbor.magedu.*/image: harbor.magedu.net\/magedu\/tomcat-app1:${DATE}/g' tomcat-app1.yaml"
  echo "k8s yaml文件镜像版本更新完成,即将开始更新容器中镜像版本" && sleep 1
}

#到控制端更新k8s中容器的版本号,有两种更新办法，一是指定镜像版本更新，二是apply执行修改过的yaml文件
function Update_k8s_container(){
  #第一种方法
  ssh root@${K8S_CONTROLLER1} "kubectl set image deployment/magedu-tomcat-app1-deployment  magedu-tomcat-app1-container=harbor.magedu.net/magedu/tomcat-app1:${DATE} -n magedu" 
  #第二种方法,推荐使用第一种
  #ssh root@${K8S_CONTROLLER1} "cd  /opt/k8s-data/yaml/magedu/tomcat-app1  && kubectl  apply -f tomcat-app1.yaml --record" 
  echo "k8s 镜像更新完成" && sleep 1
  echo "当前业务镜像版本: harbor.magedu.net/magedu/tomcat-app1:${DATE}"
  #计算脚本累计执行时间，如果不需要的话可以去掉下面四行
  endtime=`date +'%Y-%m-%d %H:%M:%S'`
  start_seconds=$(date --date="$starttime" +%s);
  end_seconds=$(date --date="$endtime" +%s);
  echo "本次业务镜像更新总计耗时："$((end_seconds-start_seconds))"s"
}

#基于k8s 内置版本管理回滚到上一个版本
function rollback_last_version(){
  echo "即将回滚之上一个版本"
  ssh root@${K8S_CONTROLLER1}  "kubectl rollout undo deployment/magedu-tomcat-app1-deployment  -n magedu"
  sleep 1
  echo "已执行回滚至上一个版本"
}

#使用帮助
usage(){
  echo "部署使用方法为 ${SHELL_DIR}/${SHELL_NAME} deploy "
  echo "回滚到上一版本使用方法为 ${SHELL_DIR}/${SHELL_NAME} rollback_last_version"
}

#主函数
main(){
  case ${METHOD}  in
  deploy)
    Code_Clone;
    Copy_File;
    Make_Image; 
    Update_k8s_yaml;
    Update_k8s_container;
  ;;
  rollback_last_version)
    rollback_last_version;
  ;;
  *)
    usage;
  esac;
}

main $1 $2
---------------
灰度发布：需要在脚本中增加判断、编写灰度发布函数、通过灰度发布变量调用灰度发布函数，
灰度发布方法：1. 通过kubectl rollout pause/resume来实现   2. 通过创建两个service来实现


6.4.7 日志收集 
k8s结合ELK实现日志收集-elasticsearch v7.6.2
系统日志
  /var/log/syslog
应用程序的日志
    error.log 
    accesslog.log-访问统计、分析

1.在k8s运行daemonset，收集每一个node节点/var/lib/docker/的日志
  优点：
    配置简单
    后期维护简单
  缺点：
    日志类型不好分类
2.每一个pod启动一个日志收集工具
  filebeat 
  两个实现方式：
    1.在一个pod的同一个容器里面，先启动filebeat进程。然后启动web服务
    2.在一个pod里面启动两个容器。一个容器是web服务，另外一个容器是filebeat。共同挂载emptyDir卷


--部署ES集群
 Elasticsearch for ubuntu: https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.6.2-amd64.deb
 Elasticsearch for centos: https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.6.2-x86_64.rpm
[root@elk ~]# rpm -ivh elasticsearch-7.6.2-x86_64.rpm	#此版本是包括jdk的，elasticsearch-no-jdk是没有jdk需要自己安装jdk的
[root@elk ~]# grep -Ev '#|^$' /etc/elasticsearch/elasticsearch.yml	#集群配置文件示例
cluster.name: magedu-elk-cluster1		#集群名称，所有节点必须一样
node.name: node1						#节点名称，每个节点不一样
path.data: /var/lib/elasticsearch		#数据存储目录，生产应该放在单独的固态硬盘上，内存最少8G以上
path.logs: /var/log/elasticsearch
#bootstrap.memory_lock: true				#是否在elasticsearch启动之后立即锁定内存，[root@elk ~]# cat /etc/elasticsearch/jvm.options文件配置内存大小，默认1G
network.host: 172.168.2.13				#本机绑定的IP地址
http.port: 9200							#本机对外的服务端口
discovery.seed_hosts: ["172.168.2.13", "172.168.2.14", "172.168.2.15"]				#集群中通告的节点ip地址，应是全部节点IP地址
cluster.initial_master_nodes: ["172.168.2.13", "172.168.2.14", "172.168.2.15"]		#哪些节点竞争master节点
gateway.recover_after_nodes: 2			#多少个节点启动后恢复elasticsearch数据，此节点数量最少是节点一半以上，3/2=1.5=2
action.destructive_requires_name: true	#是否启用在删除索引时需要索引名称，不能使用all或*代替索引名称
------由于机器少，这里部署单节点-----
[root@elk ~]# grep -Ev '#|^$' /etc/elasticsearch/elasticsearch.yml
node.name: k8s-elk
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
network.host: 172.168.2.13
http.port: 9200
cluster.initial_master_nodes: ["k8s-elk"]
action.destructive_requires_name: true
[root@elk ~]# systemctl restart elasticsearch.service		#启动elasticsearch服务
[root@elk ~]# tail -f /var/log/elasticsearch/magedu-elk-cluster1.log	#启动时输出日志在/var/log/elasticsearch/下，日志名称是集群名称，可以当做排错日志
[root@elk ~]# systemctl status elasticsearch.service | grep Active
   Active: active (running) since Fri 2022-04-01 18:04:45 CST; 57s ago
[root@elk ~]# curl http://172.168.2.13:9200/_cat/health
1648809937 10:45:37 elasticsearch green 1 1 0 0 0 0 0 0 - 100.0%

--安装zookeeper集群环境，kafka集群需要zookeeper集群
--先安装java环境
[root@centos7-node02 yum.repos.d]# yum install -y java-1.8.0-openjdk
--安装zookeeper
downloadURL: https://dlcdn.apache.org/zookeeper/zookeeper-3.5.9/apache-zookeeper-3.5.9-bin.tar.gz
[root@centos7-node02 apps]# tar xf apache-zookeeper-3.5.9-bin.tar.gz
[root@centos7-node02 apps]# cp -a apache-zookeeper-3.5.9-bin zookeeper01
[root@centos7-node02 apps]# cp -a apache-zookeeper-3.5.9-bin zookeeper02
[root@centos7-node02 apps]# mv apache-zookeeper-3.5.9-bin zookeeper03
[root@centos7-node02 apps]# ll
-rw-r--r-- 1 root root 9623007 Apr  1 19:35 apache-zookeeper-3.5.9-bin.tar.gz
drwxr-xr-x 6 root root     134 Apr  1 19:47 zookeeper01
drwxr-xr-x 6 root root     134 Apr  1 19:47 zookeeper02
drwxr-xr-x 6 root root     134 Apr  1 19:47 zookeeper03
--zookeeper01配置
[root@centos7-node02 conf]# cd /apps/zookeeper01/conf/
[root@centos7-node02 conf]# cp zoo_sample.cfg  zoo.cfg
[root@centos7-node02 conf]# grep -Ev '#|^$' zoo.cfg
tickTime=2000		#票据时间单位，默认2秒
initLimit=10		#初始化集群时需要在10个票据时间(10X2=20秒)内完成，否则初始化失败
syncLimit=5			#集群节点同步数据时间为5个票据时间(5X2=2=10秒)内完成
dataDir=/data/zookeeper01		#数据存放目录
dataLogDir=/data/zookeeper01/zookeeper	#zookeeper日志目录位置
clientPort=2181				#对外客户端访问端口
maxClientCnxns=200			#每个IP最大连接数为200
autopurge.snapRetainCount=3	#自动删除快照时保留的快照数，默认为3个
autopurge.purgeInterval=1	#自动删除快照的间隔，默认为1小时
server.1=172.168.2.14:2287:3387		#zookeeper节点的id、节点IP地址、当为leader时监听的端口、集群通告端口，用于选举，监听心跳
server.2=172.168.2.14:2288:3388
server.3=172.168.2.14:2289:3389
[root@centos7-node02 conf]# mkdir -p /data/zookeeper01/zookeeper
[root@centos7-node02 conf]# echo 1 > /data/zookeeper01/myid
[root@centos7-node02 conf]# cat /data/zookeeper01/myid
1
--zookeeper02配置
[root@centos7-node02 conf]# cd /apps/zookeeper02/conf/
[root@centos7-node02 conf]# cp zoo_sample.cfg  zoo.cfg
[root@centos7-node02 conf]# grep -Ev '#|^$' zoo.cfg
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/data/zookeeper02
dataLogDir=/data/zookeeper02/zookeeper
clientPort=2182
maxClientCnxns=200
autopurge.snapRetainCount=3
autopurge.purgeInterval=1
server.1=172.168.2.14:2287:3387
server.2=172.168.2.14:2288:3388
server.3=172.168.2.14:2289:3389
[root@centos7-node02 conf]# mkdir -p /data/zookeeper02/zookeeper
[root@centos7-node02 conf]# echo 2 > /data/zookeeper02/myid
[root@centos7-node02 conf]# cat /data/zookeeper02/myid
2
--zookeeper03配置
[root@centos7-node02 conf]# cd /apps/zookeeper03/conf/
[root@centos7-node02 conf]# cp zoo_sample.cfg  zoo.cfg
[root@centos7-node02 conf]# grep -Ev '#|^$' zoo.cfg
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/data/zookeeper03
dataLogDir=/data/zookeeper03/zookeeper
clientPort=2183
maxClientCnxns=200
autopurge.snapRetainCount=3
autopurge.purgeInterval=1
server.1=172.168.2.14:2287:3387
server.2=172.168.2.14:2288:3388
server.3=172.168.2.14:2289:3389
[root@centos7-node02 conf]# mkdir -p /data/zookeeper03/zookeeper
[root@centos7-node02 conf]# echo 3 > /data/zookeeper03/myid
[root@centos7-node02 conf]# cat /data/zookeeper03/myid
3
--启动zookeeper节点
[root@centos7-node02 conf]# /apps/zookeeper01/bin/zkServer.sh start
[root@centos7-node02 conf]# /apps/zookeeper02/bin/zkServer.sh start
[root@centos7-node02 conf]# /apps/zookeeper03/bin/zkServer.sh start
--错误可看日志
[root@centos7-node02 zookeeper01]# tail /apps/zookeeper01/logs/zookeeper-root-server-centos7-node02.out
--查看zookeeper状态
[root@centos7-node02 zookeeper01]# /apps/zookeeper01/bin/zkServer.sh status
/usr/bin/java
ZooKeeper JMX enabled by default
Using config: /apps/zookeeper01/bin/../conf/zoo.cfg
Client port found: 2181. Client address: localhost. Client SSL: false.
Mode: follower
[root@centos7-node02 zookeeper01]# /apps/zookeeper02/bin/zkServer.sh status
/usr/bin/java
ZooKeeper JMX enabled by default
Using config: /apps/zookeeper02/bin/../conf/zoo.cfg
Client port found: 2182. Client address: localhost. Client SSL: false.
Mode: leader
[root@centos7-node02 zookeeper01]# /apps/zookeeper03/bin/zkServer.sh status
/usr/bin/java
ZooKeeper JMX enabled by default
Using config: /apps/zookeeper03/bin/../conf/zoo.cfg
Client port found: 2183. Client address: localhost. Client SSL: false.
Mode: follower
[root@kafka apps]# ss -tnl
State       Recv-Q Send-Q                  Local Address:Port                                 Peer Address:Port
LISTEN      0      128                                 *:111                                             *:*
LISTEN      0      128                                 *:22                                              *:*
LISTEN      0      50                               [::]:2181                                         [::]:*
LISTEN      0      50                               [::]:2182                                         [::]:*
LISTEN      0      50                               [::]:2183                                         [::]:*
LISTEN      0      50                               [::]:40328                                        [::]:*
LISTEN      0      50                               [::]:33418                                        [::]:*
LISTEN      0      128                              [::]:111                                          [::]:*
LISTEN      0      50              [::ffff:172.168.2.14]:2288                                         [::]:*
LISTEN      0      50                               [::]:8080                                         [::]:*
LISTEN      0      50                               [::]:46641                                        [::]:*
LISTEN      0      128                              [::]:22                                           [::]:*
LISTEN      0      50              [::ffff:172.168.2.14]:3387                                         [::]:*
LISTEN      0      50              [::ffff:172.168.2.14]:3388                                         [::]:*
LISTEN      0      50              [::ffff:172.168.2.14]:3389                                         [::]:*

  
--部署kafka集群
--下载安装kafka集群
curl -LO https://mirrors.cnnic.cn/apache/kafka/2.2.2/kafka_2.12-2.2.2.tgz
[root@kafka apps]# tar xf kafka_2.13-2.4.1.tgz
[root@kafka apps]# \cp -a kafka_2.13-2.4.1 kafka01
[root@kafka apps]# \cp -a kafka_2.13-2.4.1 kafka02
[root@kafka apps]# mv kafka_2.13-2.4.1 kafka03
[root@kafka apps]# ll
-rw-r--r-- 1 root root  9623007 Apr  1 19:35 apache-zookeeper-3.5.9-bin.tar.gz
drwxr-xr-x 6 root root       89 Mar  3  2020 kafka01
drwxr-xr-x 6 root root       89 Mar  3  2020 kafka02
drwxr-xr-x 6 root root       89 Mar  3  2020 kafka03
-rw-r--r-- 1 root root 62127579 Apr  2 10:25 kafka_2.13-2.4.1.tgz
drwxr-xr-x 7 root root      146 Apr  1 20:00 zookeeper01
drwxr-xr-x 7 root root      146 Apr  1 20:00 zookeeper02
drwxr-xr-x 7 root root      146 Apr  1 20:00 zookeeper03
[root@kafka config]# grep -Ev '#|^$' /apps/kafka01/config/server.properties
broker.id=0											#kafka节点id，必须不一样，是int类型
listeners=PLAINTEXT://172.168.2.14:9092				#kafka监听的地址
num.network.threads=3								#kafka网络线程数，大并发下可以提高此值
num.io.threads=8									#kafkaio线程数，大并发下可以提高此值，前提是数据写在固态盘上
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=/data/kafka01-logs							#kafka的日志目录，也就是kafka的数据存储目录
num.partitions=1									#分区数
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect=172.168.2.14:2181,172.168.2.14:2182,172.168.2.14:2183			#zookeeper集群地址
zookeeper.connection.timeout.ms=6000
group.initial.rebalance.delay.ms=0
[root@kafka config]# mkdir -p /data/kafka01-logs
[root@kafka config]# grep -Ev '#|^$' /apps/kafka02/config/server.properties
broker.id=1
listeners=PLAINTEXT://172.168.2.14:9093
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=/data/kafka02-logs
num.partitions=1
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect=172.168.2.14:2181,172.168.2.14:2182,172.168.2.14:2183
zookeeper.connection.timeout.ms=6000
group.initial.rebalance.delay.ms=0
[root@kafka config]# mkdir -p /data/kafka02-logs
[root@kafka config]# grep -Ev '#|^$' /apps/kafka03/config/server.properties
broker.id=2
listeners=PLAINTEXT://172.168.2.14:9094
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=/data/kafka03-logs
num.partitions=1
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect=172.168.2.14:2181,172.168.2.14:2182,172.168.2.14:2183
zookeeper.connection.timeout.ms=6000
group.initial.rebalance.delay.ms=0
[root@kafka config]# mkdir -p /data/kafka03-logs
--调整kafka脚本内存参数，因为本机是测试机器，内存太小
[root@kafka ~]# vim /apps/kafka01/bin/kafka-server-start.sh
if [ "x$KAFKA_HEAP_OPTS" = "x" ]; then
    export KAFKA_HEAP_OPTS="-Xmx256M -Xms256M"			#最小256M
fi
[root@kafka ~]# \cp -a /apps/kafka01/bin/kafka-server-start.sh /apps/kafka02/bin/kafka-server-start.sh
[root@kafka ~]# \cp -a /apps/kafka01/bin/kafka-server-start.sh /apps/kafka03/bin/kafka-server-start.sh

--启动kafka集群
/apps/kafka01/bin/kafka-server-start.sh -daemon /apps/kafka01/config/server.properties
/apps/kafka02/bin/kafka-server-start.sh -daemon /apps/kafka02/config/server.properties
/apps/kafka03/bin/kafka-server-start.sh -daemon /apps/kafka03/config/server.properties
[root@kafka ~]# for i in 01 02 03;do /apps/kafka$i/bin/kafka-server-start.sh -daemon /apps/kafka$i/config/server.properties;done
[root@kafka ~]# ss -tnl | grep 90
LISTEN     0      50       [::ffff:172.168.2.14]:9092                  [::]:*
LISTEN     0      50       [::ffff:172.168.2.14]:9093                  [::]:*
LISTEN     0      50       [::ffff:172.168.2.14]:9094                  [::]:*
--排错日志
[root@kafka logs]# tail -f /apps/kafka01/logs/kafkaServer.out


--filebeat在Pod中预先安装好，采用一个pod一个容器两个进程(filebeat和业务镜像)
--将filebeat安装在基础镜像中，之前安装过
---之前基础dockerfile----
root@k8s-master01:~/k8s/dockerfile/system/centos# ls
build-command.sh  Dockerfile  filebeat-7.6.2-x86_64.rpm
root@k8s-master01:~/k8s/dockerfile/system/centos# cat ~/k8s/dockerfile/system/centos/Dockerfile
FROM centos:7.8.2003
MAINTAINER Jack.Zhang  2973707860@qq.com

ADD filebeat-7.6.2-x86_64.rpm /tmp
RUN yum install -y /tmp/filebeat-7.6.2-x86_64.rpm vim wget tree  lrzsz gcc gcc-c++ automake pcre pcre-devel zlib zlib-devel openssl openssl-devel iproute net-tools iotop &&  rm -rf /etc/localtime /tmp/filebeat-7.6.2-x86_64.rpm && ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && useradd  www -u 2020 && useradd nginx -u 2021
----------
[root@magedu-tomcat-app1-deployment-v2-797df58f6c-d225k /]# filebeat version		#所有基于此镜像的容器就有filebeat,logstash、filebeat、elasticsearch版本最好都一样，这里都是7.6.2
filebeat version 7.6.2 (amd64), libbeat 7.6.2 [d57bcf8684602e15000d65b75afcd110e2b12b59 built 2020-03-26 05:23:38 +0000 UTC]
--在dockerfile构建时添加filebeat.yml配置文件
root@k8s-master01:~/k8s/dockerfile/web/magedu/tomcat-app2# cat filebeat.yml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /apps/tomcat/logs/catalina.out
  fields:
    type: tomcat-catalina
- type: log
  enabled: true
  paths:
    - /apps/tomcat/logs/localhost_access_log.*.txt
  fields:
    type: tomcat-accesslog
filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false
setup.template.settings:
  index.number_of_shards: 1
setup.kibana:
output.kafka:
   hosts: ["172.168.2.14:9092","172.168.2.14:9093","172.168.2.14:9094"]
   topic: "magedu-n56-app1"			#kafka topic名称
   required_acks: 1
   compression: gzip
   max_message_bytes: 1000000
#output.redis:
#  hosts: ["172.31.2.105:6379"]
#  key: "k8s-magedu-app1"
#  db: 1
#  timeout: 5
#  password: "123456"
-------
root@k8s-master01:~/k8s/dockerfile/web/magedu/tomcat-app2# cat run_tomcat.sh
#!/bin/bash
#echo "nameserver 223.6.6.6" > /etc/resolv.conf
#echo "192.168.7.248 k8s-vip.example.com" >> /etc/hosts

/usr/share/filebeat/bin/filebeat -e -c /etc/filebeat/filebeat.yml -path.home /usr/share/filebeat -path.config /etc/filebeat -path.data /var/lib/filebeat -path.logs /var/log/filebeat &				#先运行filebeat，后运行tomcat
su - nginx -c "/apps/tomcat/bin/catalina.sh start"
tail -f /etc/hosts
------Dockerfile-------
root@k8s-master01:~/k8s/dockerfile/web/magedu/tomcat-app2# cat Dockerfile
#tomcat web1
FROM 192.168.13.197:8000/pub-images/tomcat-base:v8.5.43

ADD catalina.sh /apps/tomcat/bin/catalina.sh
ADD server.xml /apps/tomcat/conf/server.xml
ADD myapp/* /data/tomcat/webapps/myapp/
#ADD app1.tar.gz /data/tomcat/webapps/myapp/
ADD run_tomcat.sh /apps/tomcat/bin/run_tomcat.sh
ADD filebeat.yml /etc/filebeat/filebeat.yml
RUN chown  -R nginx.nginx /data/ /apps/
#ADD filebeat-7.5.1-x86_64.rpm /tmp/
#RUN cd /tmp && yum localinstall -y filebeat-7.5.1-amd64.deb

EXPOSE 8080 8443

CMD ["/apps/tomcat/bin/run_tomcat.sh"]
-----------------------
root@k8s-master01:~/k8s/dockerfile/web/magedu/tomcat-app2# ./build-command.sh 20211024_16-57-30		#添加filebeat配置文件，并配置filebeat启动
root@k8s-master01:~/k8s/yaml/magedu/tomcat-app1# cat tomcat-app1.yaml
kind: Deployment
#apiVersion: extensions/v1beta1
apiVersion: apps/v1
metadata:
  labels:
    app: magedu-tomcat-app1-deployment-label
  name: magedu-tomcat-app1-deployment
  namespace: magedu
spec:
  replicas: 1
  selector:
    matchLabels:
      app: magedu-tomcat-app1-selector
  template:
    metadata:
      labels:
        app: magedu-tomcat-app1-selector
    spec:
      containers:
      - name: magedu-tomcat-app1-container
        image: 192.168.13.197:8000/magedu/tomcat-app2:20211024_16-57-30		#将此镜像更改为启动filebeat的镜像
        #command: ["/apps/tomcat/bin/run_tomcat.sh"]
        #imagePullPolicy: IfNotPresent
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
          protocol: TCP
          name: http
        env:
        - name: "password"
          value: "123456"
        - name: "age"
          value: "18"
        resources:
          limits:
            cpu: 1
            memory: "512Mi"
          requests:
            cpu: 500m
            memory: "512Mi"
        volumeMounts:
        - name: magedu-images
          mountPath: /usr/local/nginx/html/webapp/images
          readOnly: false
        - name: magedu-static
          mountPath: /usr/local/nginx/html/webapp/static
          readOnly: false
      volumes:
      - name: magedu-images
        nfs:
          server: 192.168.13.67
          path: /data/k8sdata/magedu/images
      - name: magedu-static
        nfs:
          server: 192.168.13.67
          path: /data/k8sdata/magedu/static
#      nodeSelector:
#        project: magedu
#        app: tomcat
---
kind: Service
apiVersion: v1
metadata:
  labels:
    app: magedu-tomcat-app1-service-label
  name: magedu-tomcat-app1-service
  namespace: magedu
spec:
  type: NodePort
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 8080
    nodePort: 40003
  selector:
    app: magedu-tomcat-app1-selector
--------------------
root@k8s-master01:~/k8s/yaml/magedu/tomcat-app1# kubectl apply -f tomcat-app1.yaml
root@k8s-master01:~/k8s/yaml/magedu/tomcat-app1# kubectl get pods -n magedu | grep magedu-tomcat-app1-deployment
magedu-tomcat-app1-deployment-7d89cf4c79-g7fs7      1/1     Running   0          2m3s
--进容器查看filtbeat是否起来
[root@magedu-tomcat-app1-deployment-7d89cf4c79-g7fs7 /]# ps -ef | grep filebeat		#有进程表示启动了
root         6     1  0 13:56 ?        00:00:00 /usr/share/filebeat/bin/filebeat -e -c /etc/filebeat/filebeat.yml -path.home /usr/share/filebeat -path.config /etc/filebeat -path.data /var/lib/filebeat -path.logs /var/log/filebeat
--下载kafkatool可视化工具测试kafka是否有预期的日志写入
DownloadURL: https://www.kafkatool.com/download.html


----安装配置logstash
--安装jdk
[root@elk ~]# yum install java-11-openjdk
--安装logstash7.6.2
DownloadURL: https://artifacts.elastic.co/downloads/logstash/logstash-7.6.2.rpm
[root@elk ~]# yum install -y ./logstash-7.6.2.rpm
[root@elk ~]# cd /etc/logstash
[root@elk /etc/logstash]# ls
conf.d  jvm.options  log4j2.properties  logstash-sample.conf  logstash.yml  pipelines.yml  startup.options
[root@elk /etc/logstash]# cd conf.d/
[root@elk ~]# cat /etc/logstash/conf.d/kafka-to-es.conf
input {
  kafka {
    bootstrap_servers => "172.168.2.14:9092,172.168.2.14:9093,172.168.2.14:9094"
    topics => ["magedu-n56-app1","magedu-n56-app2"]
    codec => "json"
  }
}


output {
  stdout {
    codec => rubydebug
  }
}
-----------
[root@elk ~]# /usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/kafka-to-es.conf -t		#测试配置文件语法是否有问题
Configuration OK
[root@elk ~]# /usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/kafka-to-es.conf		#就可以运行输出到控制台了
#[root@elk ~]# systemctl restart logstash.service
[root@elk ~]# cat /etc/logstash/conf.d/kafka-to-es.conf
input {
  kafka {
    bootstrap_servers => "172.168.2.14:9092,172.168.2.14:9093,172.168.2.14:9094"
    topics => ["magedu-n56-app1","magedu-n56-app2"]
    codec => "json"
  }
}


output {
  if [fields][type] == "tomcat-accesslog" {
    elasticsearch {
      hosts => ["172.168.2.13:9200"]
      index => "magedu-n56-app1-accesslog-%{+YYYY.MM.dd}"
    }
  }

  if [fields][type] == "tomcat-catalina" {
    elasticsearch {
      hosts => ["172.168.2.13:9200"]
      index => "magedu-n56-app1-catalinalog-%{+YYYY.MM.dd}"
    }
  }
#  stdout {
#    codec => rubydebug
#  }
}
-----

----安装kibana7.6.2，版本必须跟elasticsearch版本一致，否则后续使用会有问题
[root@elk ~]# rpm -ivh kibana-7.6.2-x86_64.rpm
[root@elk ~]# grep -Ev '#|^$' /etc/kibana/kibana.yml		#更改配置文件
server.port: 5601
server.host: "172.168.2.13"
elasticsearch.hosts: ["http://172.168.2.13:9200"]
i18n.locale: "zh-CN"
[root@elk ~]# systemctl restart kibana.service		#重启kibana服务
[root@elk ~]# ss -tnl | grep 5601
LISTEN     0      128    172.168.2.13:5601                     *:*

---------k8s和ceph工作经验简历优化-------------
1.kubernetes 高可用集群规划和部署
  master节点
  etcd 
    SSD
2.harbor 的镜像分发
  P2P
  蜻蜓
3.制定镜像构建方式和标准，基于Dockerfile结合shell脚本实现镜像自动构建
  分层构建
4.编写yaml文件，运行无状态服务
  nginx tomcat 微服务 java
5.制定探针探测机制，基于存活和就绪探针对容器中的服务探测
6.对k8s中的容器进行业务数据持久化
  NFS：cephfs  nginx 
  rbd mysql elasticsearch 
7.编写脚本，结合Jenkins与gitlab实现代码部署和回滚
8.部署ELK环境，实现日志收集
  统一收集
  统一存储
  统一展示
9.对部分pod配置HPA控制器，实现pod的弹性伸缩
10.通过nodeport及ingress对k8s中的访问进行暴露
11.对container、pod和namespace进行资源限制
  nginx 1c 2g
  java 1c 3g 
  微服务 0.5c 1g 
12.通过prometheus对容器进行监控
13.编写yaml文件，运行有状态服务
  mysql 
  数据持久化
14.编写k8s 运维手册
15.对kubernetes配置多账户并进行权限控制，避免由于权限误操作导致的问题

ceph：
  1.负责ceph集群的规划、服务器选型SSD/PCI-E/万兆网卡、部署和后期维护
  2.编写ceph使用手册以及内部培训
  3.启用rbd块存储，用于kubernetes中有状态的服务数据持久化
    pv pvc 
  4.启用cephfs文件存储，用于对kubernetes中多个无状态服务的数据持久化和共享
  5.启用radosgw对象存储，用于kubernetes对象存储数据的访问
  6.基于prometheus对ceph进行监控
  7.ceph集群的后期维护
    增加node节点
    处理OSD故障
      临时2副本
      关闭数据整理
    对ceph数据的PG进行后期的调整
-------------------------------------------


6.4.8 资源限制 
容器限制、pod限制、namespace限制
常用业务资源分配：
  nginx: 2c 2g 
  微服务： 2c 2g/2c 3g 
  mysql/ES  4c/6G  4c/8G
  
6.4.8.1 容器限制 
root@k8s-master01:~/k8s/yaml/limit-rbac/limit-case# cat case1-pod-memory-limit.yml
#apiVersion: extensions/v1beta1
apiVersion: apps/v1
kind: Deployment
metadata:
  name: limit-test-deployment
  namespace: magedu
spec:
  replicas: 1
  selector:
    matchLabels: #rs or deployment
      app: limit-test-pod
#    matchExpressions:
#      - {key: app, operator: In, values: [ng-deploy-80,ng-rs-81]}
  template:
    metadata:
      labels:
        app: limit-test-pod
    spec:
      containers:
      - name: limit-test-container
        image: lorel/docker-stress-ng
        resources:
          limits:
            memory: "200Mi"
            cpu: 200m
          requests:
            memory: "100Mi"
        #command: ["stress"]
        args: ["--vm", "2", "--vm-bytes", "256M"]		#压测程序在没有资源限制时会占用2000毫核CPU，512M内存
      #nodeSelector:
      #  env: group1

6.4.8.2 pod限制 
root@k8s-master01:~/k8s/yaml/limit-rbac/limit-case# cat case3-LimitRange.yaml		#仅针对limitrangs对象应用后，后续的pod创建会受此限制，已创建的不会受此限制
apiVersion: v1
kind: LimitRange
metadata:
  name: limitrange-magedu
  namespace: magedu
spec:
  limits:
  - type: Container       #限制的资源类型
    max:
      cpu: "2"            #限制单个容器的最大CPU
      memory: "2Gi"       #限制单个容器的最大内存
    min:
      cpu: "100m"         #限制单个容器的最小CPU
      memory: "100Mi"     #限制单个容器的最小内存
    default:
      cpu: "500m"         #默认单个容器的CPU限制
      memory: "512Mi"     #默认单个容器的内存限制
    defaultRequest:
      cpu: "500m"         #默认单个容器的CPU创建请求
      memory: "512Mi"     #默认单个容器的内存创建请求
    maxLimitRequestRatio:
      cpu: 2              #限制CPU limit/request比值最大为2
      memory: 2         #限制内存limit/request比值最大为1.5
  - type: Pod
    max:
      cpu: "4"            #限制单个Pod的最大CPU
      memory: "4Gi"       #限制单个Pod最大内存
  - type: PersistentVolumeClaim
    max:
      storage: 50Gi        #限制PVC最大的requests.storage
    min:
      storage: 5Gi        #限制PVC最小的requests.storage
---
root@k8s-master01:~/k8s/yaml/limit-rbac/limit-case# kubectl apply -f case3-LimitRange.yaml
limitrange/limitrange-magedu created
root@k8s-master01:~/k8s/yaml/limit-rbac/limit-case# kubectl get limitranges -n magedu
NAME                CREATED AT
limitrange-magedu   2022-04-02T12:38:23Z
root@k8s-master01:~/k8s/yaml/limit-rbac/limit-case# kubectl describe limitranges -n magedu
Name:                  limitrange-magedu
Namespace:             magedu
Type                   Resource  Min    Max   Default Request  Default Limit  Max Limit/Request Ratio
----                   --------  ---    ---   ---------------  -------------  -----------------------
Container              cpu       100m   2     500m             500m           2
Container              memory    100Mi  2Gi   512Mi            512Mi          2
Pod                    cpu       -      4     -                -              -
Pod                    memory    -      4Gi   -                -              -
PersistentVolumeClaim  storage   5Gi    50Gi  -                -              -
---------pod示例--------
root@k8s-master01:~/k8s/yaml/magedu/nginx# cat nginx-limit.yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  labels:
    app: magedu-nginx-deployment-label
  name: magedu-nginx-deployment
  namespace: magedu
spec:
  replicas: 1
  selector:
    matchLabels:
      app: magedu-nginx-selector
  template:
    metadata:
      labels:
        app: magedu-nginx-selector
    spec:
      containers:
      - name: magedu-nginx-container
        image: 192.168.13.197:8000/magedu/nginx-web1:v3
        imagePullPolicy: Always
        ports:
        - containerPort: 80
          protocol: TCP
          name: http
        - containerPort: 443
          protocol: TCP
          name: https
        env:
        - name: "password"
          value: "123456"
        - name: "age"
          value: "20"
        resources:
          limits:
            cpu: 2					#cpu比值为1:4，会受上面limitranges影响，不会创建成功，直接在调度前被拒绝
            memory: 2Gi
          requests:
            cpu: 500m
            memory: 1Gi
        volumeMounts:
        - name: magedu-images
          mountPath: /usr/local/nginx/html/webapp/images
          readOnly: false
        - name: magedu-static
          mountPath: /usr/local/nginx/html/webapp/static
          readOnly: false
      volumes:
      - name: magedu-images
        nfs:
          server: 192.168.13.67
          path: /data/k8sdata/magedu/images
      - name: magedu-static
        nfs:
          server: 192.168.13.67
          path: /data/k8sdata/magedu/static
---
kind: Service
apiVersion: v1
metadata:
  labels:
    app: magedu-nginx-service-label
  name: magedu-nginx-service
  namespace: magedu
spec:
  type: NodePort
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 80
    nodePort: 40002
  - name: https
    port: 443
    protocol: TCP
    targetPort: 443
    nodePort: 40443
  selector:
    app: magedu-nginx-selector
--------------------------
root@k8s-master01:~/k8s/yaml/magedu/nginx# kubectl apply -f nginx-limit.yaml	#应用比值为1:4的cpu pod，此时应用成功
deployment.apps/magedu-nginx-deployment configured
service/magedu-nginx-service unchanged
root@k8s-master01:~/k8s/yaml/magedu/nginx# kubectl get pods -n magedu			#但是通过查看pod却始终看不到
NAME                                                READY   STATUS    RESTARTS   AGE
deploy-devops-redis-749878f59d-gf856                1/1     Running   0          8d
magedu-consumer-deployment-84547497d4-999wr         1/1     Running   0          7d3h
magedu-dubboadmin-deployment-bbd4b4966-sts92        1/1     Running   0          7d
magedu-jenkins-deployment-5f94c58f86-kc2hg          1/1     Running   0          7d8h
magedu-provider-deployment-7656dfd74f-fq652         1/1     Running   0          7d
magedu-provider-deployment-7656dfd74f-vpjkl         1/1     Running   0          7d3h
magedu-tomcat-app1-deployment-7d89cf4c79-5m6sn      1/1     Running   0          5h24m
magedu-tomcat-app1-deployment-7d89cf4c79-g7fs7      1/1     Running   0          6h46m
magedu-tomcat-app1-deployment-v2-797df58f6c-rdhk8   1/1     Running   0          3h37m
mysql-0                                             2/2     Running   0          7d22h
wordpress-app-deployment-7d6d5c4c97-jx4kf           2/2     Running   0          4d4h
zookeeper1-749d87b7c5-stk5w                         1/1     Running   1          10d
zookeeper2-5f5fcb7f4d-s5pgp                         1/1     Running   1          10d
zookeeper3-c857bb585-txchq                          1/1     Running   1          10d
root@k8s-master01:~/k8s/yaml/magedu/nginx# kubectl get deployment -n magedu
NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
deploy-devops-redis                1/1     1            1           8d
magedu-consumer-deployment         1/1     1            1           7d3h
magedu-dubboadmin-deployment       1/1     1            1           7d
magedu-jenkins-deployment          1/1     1            1           7d8h
magedu-nginx-deployment            0/1     0            0           87s		#此时需要查看deployment，此deployoment就是上面pod的控制器，这样还看不出报错
magedu-provider-deployment         2/2     2            2           7d3h
magedu-tomcat-app1-deployment      2/2     2            2           6h47m
magedu-tomcat-app1-deployment-v2   1/1     1            1           2d22h
wordpress-app-deployment           1/1     1            1           4d4h
zookeeper1                         1/1     1            1           10d
zookeeper2                         1/1     1            1           10d
zookeeper3                         1/1     1            1           10d
root@k8s-master01:~/k8s/yaml/magedu/nginx# kubectl get deployment/magedu-nginx-deployment -n magedu -o json		#此时能过输出json或yaml来查看报错
            {
                "lastTransitionTime": "2022-04-02T12:42:37Z",
                "lastUpdateTime": "2022-04-02T12:42:37Z",
                "message": "pods \"magedu-nginx-deployment-769d4567ff-mhz7j\" is forbidden: cpu max limit to request ratio per Container is 2, but provided ratio is 4.000000",
                "reason": "FailedCreate",
                "status": "True",
                "type": "ReplicaFailure"
            }
----此时将nginx-limit.yaml资源限制改成这个就正常起来了
        resources:
          limits:
            cpu: 1000m
            memory: 1Gi
          requests:
            cpu: 500m
            memory: 512Mi
root@k8s-master01:~/k8s/yaml/magedu/nginx# kubectl get pods -n magedu | grep magedu-nginx-deployment-849cbbbb9c-bjjln
magedu-nginx-deployment-849cbbbb9c-bjjln            1/1     Running   0          61s


6.4.8.3 namespace限制
root@k8s-master01:~/k8s/yaml/limit-rbac/limit-case# cat case6-ResourceQuota-magedu.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: quota-magedu
  namespace: magedu
spec:
  hard:
    requests.cpu: "8			#namespace下请求资源最多使用8核cpu
    limits.cpu: "8"				#namespace下限制资源最多使用8核cpu
    requests.memory: 4Gi		#namespace下请求资源最多使用4核内存
    limits.memory: 4Gi			#namespace下限制资源最多使用4核内存
    requests.nvidia.com/gpu: 4	#namespace下限制GPU最多使用4核GPU
    pods: "2"					#namespace下最多创建2个pod
    services: "6"				#namespace下最多创建6个service
root@k8s-master01:~/k8s/yaml/limit-rbac/limit-case# kubectl apply -f case6-ResourceQuota-magedu.yaml	#只在应用后生效
root@k8s-master01:~/k8s/yaml/limit-rbac/limit-case# kubectl get resourcequotas -n magedu
NAME           AGE   REQUEST                                                                                                        LIMIT
quota-magedu   7s    pods: 15/2, requests.cpu: 2600m/8, requests.memory: 3172Mi/4Gi, requests.nvidia.com/gpu: 0/4, services: 15/6   limits.cpu: 4/8, limits.memory: 2560Mi/4Gi
root@k8s-master01:~/k8s/yaml/limit-rbac/limit-case# kubectl describe resourcequotas quota-magedu -n magedu
Name:                    quota-magedu
Namespace:               magedu
Resource                 Used    Hard
--------                 ----    ----
limits.cpu               4       8
limits.memory            2560Mi  4Gi
pods                     15      2
requests.cpu             2600m   8
requests.memory          3172Mi  4Gi
requests.nvidia.com/gpu  0       4
services                 15      6
root@k8s-master01:~/k8s/yaml/limit-rbac/limit-case# cat case6-ResourceQuota-magedu.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: quota-magedu
  namespace: magedu
spec:
  hard:
    requests.cpu: "16"
    limits.cpu: "16"
    requests.memory: 16Gi
    limits.memory: 16Gi
    requests.nvidia.com/gpu: 4
    pods: "100"
    services: "50"
root@k8s-master01:~/k8s/yaml/limit-rbac/limit-case# kubectl describe resourcequotas quota-magedu -n magedu
Name:                    quota-magedu
Namespace:               magedu
Resource                 Used    Hard
--------                 ----    ----
limits.cpu               4       16
limits.memory            2560Mi  16Gi
pods                     15      100
requests.cpu             2600m   16
requests.memory          3172Mi  16Gi
requests.nvidia.com/gpu  0       4
services                 15      50

示例：
kind: resourcequota
namespace: magedu
resourcequota: 48C96G
例如: 有2个节点，每个节点为24C64G，并且每个pod为2C4G，共创建了24个pod，此时资源已经全部分配出去，当再创建第25个pod时将会失败。即使24个pod实际使用资源不足48C96G，此时第25个pod也会创建失败，因为namespace资源额度已经使用使用完，此时需要调整resourcequota或者调整yaml文件中的requset和limit值。




6.5 访问控制，RBAC
root@k8s-master01:~/k8s/yaml/limit-rbac/role# kubectl create serviceaccount magedu -n  magedu
serviceaccount/magedu created
root@k8s-master01:~/k8s/yaml/limit-rbac/role# cat magedu-role.yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: magedu
  name: magedu-role
rules:
- apiGroups: ["*"]			#表示apiversion和版本号，例如v1beta1,v1等
  resources: ["pods/exec"]		#资源类型
  #verbs: ["*"]
  ##RO-Role
  verbs: ["get", "list", "watch", "create"]		#只读权限，一般给开发就给这样的权限即可，对象有pods,pods/exec,deployments,replicasets等

- apiGroups: ["*"]
  resources: ["pods"]
  #verbs: ["*"]
  ##RO-Role
  verbs: ["get", "list", "watch"]

- apiGroups: ["*"]
  resources: ["deployments", "replicasets", "deployments/scale"]
  #verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  ##RO-Role
  verbs: ["get", "watch", "list"]

- apiGroups: ["*"]
  resources: ["events"]
  ##RO-Role
  verbs: ["get", "watch", "list"]
---
root@k8s-master01:~/k8s/yaml/limit-rbac/role# kubectl apply -f magedu-role.yaml
role.rbac.authorization.k8s.io/magedu-role created
root@k8s-master01:~/k8s/yaml/limit-rbac/role# cat magedu-role-bind.yaml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: role-bind-magedu
  namespace: magedu
subjects:
- kind: ServiceAccount
  name: magedu
  namespace: magedu
roleRef:
  kind: Role
  name: magedu-role
  apiGroup: rbac.authorization.k8s.io
---
root@k8s-master01:~/k8s/yaml/limit-rbac/role# kubectl apply -f magedu-role-bind.yaml
rolebinding.rbac.authorization.k8s.io/role-bind-magedu created

root@k8s-master01:~/k8s/yaml/limit-rbac/role# kubectl get secret -n magedu
NAME                  TYPE                                  DATA   AGE
default-token-b4vg9   kubernetes.io/service-account-token   3      11d
magedu-token-qvnbb    kubernetes.io/service-account-token   3      2m44s
root@k8s-master01:~/k8s/yaml/limit-rbac/role# kubectl describe secret magedu-token-qvnbb -n magedu
Name:         magedu-token-qvnbb
Namespace:    magedu
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: magedu
              kubernetes.io/service-account.uid: 2fafcf0e-4dc5-45f8-b9f8-191b197b75c8
Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1350 bytes
namespace:  6 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6ImQ3UV9STlJ4TEpQRS1XWmNHblFmaHJOUmdUaW5jMVJvSERqeE9VajR1LWcifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYWdlZHUiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoibWFnZWR1LXRva2VuLXF2bmJiIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6Im1hZ2VkdSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjJmYWZjZjBlLTRkYzUtNDVmOC1iOWY4LTE5MWIxOTdiNzVjOCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYWdlZHU6bWFnZWR1In0.woEJpQGXMqDsp_RjcQrga-UoZ1NFAMcwgVhFaVInobrWIClEykQvrfFChFSwNWYvlgIWB5EqfnviQWUSATiqp5r1hH2sIY50HSQBFKuZKmXQuLf_NB2Y-4rF-paVuX6VxtnlmYz6wMWMCAsid7gBA_G7qF73oFJF5d8n2JHsIlUyrPh9BK0HJ3_vC7YxNBfC5OAH3knWcysVS1iEoN_y9RVHFytYgQqL2659S4XSBc76A7cneyQJ6ZsZEbZRyDJ6FxJs4cTJNPuaIcyMcIB1goX5bLIrj3LrHcd5A3rawXM4WEjdk4YbZVuMCCEeGXSHh1h6rPKnEkAjusoVQJIlzw
---
--当访问没有权限时会报错
pods "magedu-tomcat-app1-deployment-v2-797df58f6c-rdhk8" is forbidden: User "system:serviceaccount:magedu:magedu" cannot create resource "pods/exec" in API group "" in the namespace "magedu"


--用kubernetes.pem或者ca.pem生成k8s超级管理员权限kubeconfig
kubectl config set-cluster cluster1 --certificate-authority=/etc/kubernetes/ssl/ca.pem --embed-certs=true --server=https://192.168.13.50:6443 --kubeconfig=user1.kubeconfig
kubectl config set-credentials user1 \
--client-certificate=/etc/kubernetes/ssl/kubernetes.pem \
--client-key=/etc/kubernetes/ssl/kubernetes-key.pem \
--embed-certs=true \
--kubeconfig=user1.kubeconfig
kubectl config set-context cluster1 --cluster=cluster1 --user=user1 --kubeconfig=user1.kubeconfig
kubectl config use-context cluster1 --kubeconfig=user1.kubeconfig


root@k8s-master01:~/k8s/yaml/limit-rbac/limit-case# kubectl get clusterrolebinding cluster-admin -o yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  creationTimestamp: "2022-03-04T13:45:03Z"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: cluster-admin
  resourceVersion: "148"
  uid: ba619883-3399-48b8-b325-6101f5a07494
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group			#O,        Subject: C = CN, ST = HangZhou, L = XS, O = k8s, OU = System, CN = kubernetes
  name: system:masters		
root@k8s-master01:~/k8s/yaml/limit-rbac/limit-case# kubectl get clusterrolebinding kubernetes-crb -o yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  creationTimestamp: "2022-03-04T13:45:04Z"
  name: kubernetes-crb
  resourceVersion: "214"
  uid: 6b6bfccb-c554-4e0f-a517-a878a65329d0
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User			#CN,        Subject: C = CN, ST = HangZhou, L = XS, O = k8s, OU = System, CN = kubernetes  #kubernetes.pem和ca.pem CN都是kubernetes
  name: kubernetes
root@k8s-master01:~/k8s/yaml/limit-rbac/limit-case# kubectl get clusterrolebinding admin-user -o yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"rbac.authorization.k8s.io/v1","kind":"ClusterRoleBinding","metadata":{"annotations":{},"name":"admin-user"},"roleRef":{"apiGroup":"rbac.authorization.k8s.io","kind":"ClusterRole","name":"cluster-admin"},"subjects":[{"kind":"ServiceAccount","name":"admin-user","namespace":"kubernetes-dashboard"}]}
  creationTimestamp: "2022-03-06T03:54:44Z"
  name: admin-user
  resourceVersion: "227520"
  uid: d031510b-3e5c-4745-9033-236fa0e00f0f
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard

----创建kubeconfig文件，普通用户jack，只有magedu名称空间下只读权限
RoleBinding 或者 ClusterRoleBinding 可绑定角色到某 *主体（Subject）*上。 主体可以是组(O)，用户(CN)或者 服务账户(servuceaccount)。groups, users or ServiceAccounts

root@k8s-master01:~/k8s/yaml/limit-rbac/role# cat jack-csr.json	#创建用户为Jack，组为k8s的证书签署请求文件
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
      "O": "k8s",
      "OU": "System"
    }
  ]
}
root@k8s-master01:~/k8s/yaml/limit-rbac/role# scp jack-csr.json root@172.168.2.11:~			#复制到目标机器
root@ansible:/etc/kubeasz/clusters/k8s-01/ssl# cp /etc/kubeasz/bin/cfssl* /usr/local/bin/			#准备证书生成工具，kubeasz自带
root@ansible:/etc/kubeasz/clusters/k8s-01/ssl# cat ca-config.json
{
  "signing": {
    "default": {
      "expiry": "438000h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "438000h"
      }
    },
    "profiles": {
      "kcfg": {
        "usages": [
            "signing",
            "key encipherment",
            "client auth"
        ],
        "expiry": "438000h"
      }
    }
  }
}
-----
#cfssl gencert -ca=/etc/kubeasz/clusters/k8s-01/ssl/ca.pem  -ca-key=/etc/kubeasz/clusters/k8s-01/ssl/ca-key.pem -config=/etc/kubeasz/clusters/k8s-01/ssl/ca-config.json -profile=kubernetes /root/Jack-csr.json | cfssljson -bare Jack
root@ansible:/etc/kubeasz/clusters/k8s-01/ssl/custom-ssl# cfssl gencert -ca=/etc/kubeasz/clusters/k8s-01/ssl/ca.pem  -ca-key=/etc/kubeasz/clusters/k8s-01/ssl/ca-key.pem -config=/etc/kubeasz/clusters/k8s-01/ssl/ca-config.json -profile=kubernetes /root/Jack-csr.json | cfssljson -bare Jack
2022/04/03 15:03:21 [INFO] generate received request
2022/04/03 15:03:21 [INFO] received CSR
2022/04/03 15:03:21 [INFO] generating key: rsa-2048
2022/04/03 15:03:22 [INFO] encoded CSR
2022/04/03 15:03:22 [INFO] signed certificate with serial number 423342455757237043378896963793677996952171777953
2022/04/03 15:03:22 [WARNING] This certificate lacks a "hosts" field. This makes it unsuitable for
websites. For more information see the Baseline Requirements for the Issuance and Management
of Publicly-Trusted Certificates, v.1.1.6, from the CA/Browser Forum (https://cabforum.org);
specifically, section 10.2.3 ("Information Requirements").
root@ansible:/etc/kubeasz/clusters/k8s-01/ssl/custom-ssl# ll
total 16
drwxr-xr-x 2 root root   58 4月   3 15:03 ./
drwxr-xr-x 3 root root 4096 4月   3 15:03 ../
-rw-r--r-- 1 root root  997 4月   3 15:03 Jack.csr
-rw------- 1 root root 1675 4月   3 15:03 Jack-key.pem
-rw-r--r-- 1 root root 1383 4月   3 15:03 Jack.pem
root@ansible:/etc/kubeasz/clusters/k8s-01/ssl/custom-ssl# scp Jack.pem Jack-key.pem root@172.168.2.21:~/k8s/yaml/limit-rbac/role/
root@k8s-master01:~/k8s/yaml/limit-rbac/role# kubectl config set-cluster cluster1 --certificate-authority=/etc/kubernetes/ssl/ca.pem --embed-certs=true --server=https://192.168.13.50:6443 --kubeconfig=Jack.kubeconfig
Cluster "cluster1" set.
root@k8s-master01:~/k8s/yaml/limit-rbac/role# kubectl config set-credentials Jack --client-certificate=/root/k8s/yaml/limit-rbac/role/Jack.pem --client-key=/root/k8s/yaml/limit-rbac/role/Jack-key.pem --embed-certs=true --kubeconfig=Jack.kubeconfig
User "Jack" set.
root@k8s-master01:~/k8s/yaml/limit-rbac/role# kubectl config set-context cluster1 --cluster=cluster1 --user=Jack --namespace=magedu --kubeconfig=Jack.kubeconfig
Context "cluster1" created.
root@k8s-master01:~/k8s/yaml/limit-rbac/role# kubectl config use-context cluster1 --kubeconfig=Jack.kubeconfig
Switched to context "cluster1".
root@k8s-master01:~/k8s/yaml/limit-rbac/role# cat Jack.kubeconfig
root@k8s-master01:~/k8s/yaml/limit-rbac/role# cat Jack.kubeconfig
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUR1RENDQXFDZ0F3SUJBZ0lVWTkvWDRUM3N6T0FsZktmbm1jV3I0MzdpdDUwd0RRWUpLb1pJaHZjTkFRRUwKQlFBd1lURUxNQWtHQTFVRUJoTUNRMDR4RVRBUEJnTlZCQWdUQ0VoaGJtZGFhRzkxTVFzd0NRWURWUVFIRXdKWQpVekVNTUFvR0ExVUVDaE1EYXpoek1ROHdEUVlEVlFRTEV3WlRlWE4wWlcweEV6QVJCZ05WQkFNVENtdDFZbVZ5CmJtVjBaWE13SUJjTk1qSXdNekEwTVRFeU1qQXdXaGdQTWpFeU1qQXlNRGd4TVRJeU1EQmFNR0V4Q3pBSkJnTlYKQkFZVEFrTk9NUkV3RHdZRFZRUUlFd2hJWVc1bldtaHZkVEVMTUFrR0ExVUVCeE1DV0ZNeEREQUtCZ05WQkFvVApBMnM0Y3pFUE1BMEdBMVVFQ3hNR1UzbHpkR1Z0TVJNd0VRWURWUVFERXdwcmRXSmxjbTVsZEdWek1JSUJJakFOCkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQTNtYm0zaHM3WlJ3WEdEUktkUW9rR25QVjVNbUQKYUEzNnpaZ0VXWUJNSkIvZDBOSEFkQkZDY1dLb3ArNUF2SFk3elBjeGdNelpRZ1B4TU9DcU9CS09NUVJYNG4ydApENmYxbUZrMzFNRDBEMXJGVTBXcGYwanRiampNMmNEOW5wU2trcmZ4dDliWlh2NHRHNFpDUlB4U1RJbkxDU0RkClVNYnN6OUFXVkZNamtnSndUa3FpU2NIZitod1FvOWZVdVduekZTWWdGUUppUWtWRVZqaGErYU5DK2oyUjNOQjUKN1hDS1RHMFBUNS9JVVFEL2t2V0doL0NoZEZUQmREV0plL0d4cnpkYlAxejRQbnBvSTBvaThDN1MwakErVlJKRApMcS9WcE5TY2d1WFB6ZXNPZSs3Tk9Ub0hwZURyVGJxTER5aVRMbEVWNmRWWG5ScE9tdG9XdjI2OU13SURBUUFCCm8yWXdaREFPQmdOVkhROEJBZjhFQkFNQ0FRWXdFZ1lEVlIwVEFRSC9CQWd3QmdFQi93SUJBakFkQmdOVkhRNEUKRmdRVXhxbndaUFpNTEZUeUhJVzNzcWNyaGJmZEl0QXdId1lEVlIwakJCZ3dGb0FVeHFud1pQWk1MRlR5SElXMwpzcWNyaGJmZEl0QXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBTFpndlVIOEh1SDRIYnJtUW80ejFOTWJKamZVCmlHaFYzdmpFRitIVHlhejByOU1HSlo5b1p3M2hpK0ZpUUJEaUFGSjNvTEVtWVEweDFLd2VlUnorQUlwOVV6QUEKaE5ETVB2YmlqTXl3b3JRNTdzN3BSWlMzejB5RHJ1MEh2R21WRkl6WjRzcm05TjZ2SnVORGUvbklBc0o5eitzbwpKN2doQ3k3Z0dqL2w5dXV2dmovNk8vNVJTVVc4WGE3NWZPR2ZESjFVdUdyemMzbE1mTkNwVUJwMFFXTXVtWHFRClJReHZuKzdRQWdQcitQRk9OLzZMSVkxYlZwNmkvUHhaZ2xjcHFnRjV4QUZ4VEFJYmRXdjVxTjVVQUNsWTFwOE8KVEwyeG9LQVdsQ1IydkdpVS8zbWJTZ2prd3JzRTRRZ3hweHdMdklUc2FNNWtINVF3YUMvalNIR0V3SlE9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://192.168.13.50:6443
  name: cluster1
contexts:
- context:
    cluster: cluster1
    namespace: magedu
    user: Jack
  name: cluster1
current-context: cluster1
kind: Config
preferences: {}
users:
- name: Jack
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUQwVENDQXJtZ0F3SUJBZ0lVU2lkVkR3UEJJNnl6SzR0NkVYNUVoWTJqRDZFd0RRWUpLb1pJaHZjTkFRRUwKQlFBd1lURUxNQWtHQTFVRUJoTUNRMDR4RVRBUEJnTlZCQWdUQ0VoaGJtZGFhRzkxTVFzd0NRWURWUVFIRXdKWQpVekVNTUFvR0ExVUVDaE1EYXpoek1ROHdEUVlEVlFRTEV3WlRlWE4wWlcweEV6QVJCZ05WQkFNVENtdDFZbVZ5CmJtVjBaWE13SUJjTk1qSXdOREF6TURZMU9EQXdXaGdQTWpBM01qQXpNakV3TmpVNE1EQmFNR0V4Q3pBSkJnTlYKQkFZVEFrTk9NUkV3RHdZRFZRUUlFd2hUYUdGdVoyaGhhVEVSTUE4R0ExVUVCeE1JVTJoaGJtZG9ZV2t4RERBSwpCZ05WQkFvVEEyczRjekVQTUEwR0ExVUVDeE1HVTNsemRHVnRNUTB3Q3dZRFZRUURFd1JLWVdOck1JSUJJakFOCkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQXQwRS9lcVUyL3pZYm5xSU9hOGNWb0ppbjJVVlkKb2NBSGlBTlZzMEtBUm5RcENiM0Vsc1NzL3JKbDd3REUxaHFyNDJDQTBVK3V4UG54cWp2UHBzTlZIRnBoeW4rbwpQNEJvWENPMjNkaVcrM20rbVFIMmNac2JJL2JnNWlNcWUxWlYzNEFhZm9jZFhlNlYrNWxpci9CVGlNSDJGaWNkClF5aWJKRzFPOExlb3ltUHJKakxCMHRSWXNGQnR5QWtMQkgvTCtVU0ozbEtJSGRSc2l0NFpvVkVRdUV4WW4vb2IKN3RwdjFpaHRBR29UUUNvKzI2ZEQvYmYyWWdQWjBXeXppNXJLNWM1ZlpZQW51T2NKcDNCenpQdnZvMXNKOGN4MApOOXlYQVh6aWVaSVlxTDJIVStiK2xOR3dDZUJ2dStsWlRrQXNRSmVMcU1nK01KRFNmZERkdVl4T2pRSURBUUFCCm8zOHdmVEFPQmdOVkhROEJBZjhFQkFNQ0JhQXdIUVlEVlIwbEJCWXdGQVlJS3dZQkJRVUhBd0VHQ0NzR0FRVUYKQndNQ01Bd0dBMVVkRXdFQi93UUNNQUF3SFFZRFZSME9CQllFRlB0QXAxR2VTc3VzSGlwOVZMd1pDdnZFQUwwdQpNQjhHQTFVZEl3UVlNQmFBRk1hcDhHVDJUQ3hVOGh5RnQ3S25LNFczM1NMUU1BMEdDU3FHU0liM0RRRUJDd1VBCkE0SUJBUUJZWXdkNzJJSjFST1RwS3NaeHJxN2pZb0h3Wkk5VDNHaGZQaktpRVVpNlBNT2hoamd2NUE3cG8yZGgKMG91aUhINmNBc0dLdGNkcnpTYXhuRUh1aFVtMXlYYTZjRXZYMWxzMms1eHB4azNwczBzVkZPSi80cFZxWnR1cgpVdllIVXdvaXpmZkwvN3h4ektUOGFqMUh0VTVJL3pxclI2MWR1U2kzQ0VoK2NhVVF4MnNiZlJnUWp5RjNMWDJKCkhZWkc0bEhZM2l1R2VjR25hdmFqcllIUFJGUDFLRnF1akhJeWhpL3l4UGpMUzgvRStxQSt2aXhNbzRyQUpRdkEKc280enREVm9oU05WeXVCK2J3aVpBaUl6a0E5cG1CQUl0dEhrcXdEclk2OXI4UnovbEk1dkhkclNxZ0VnV1M4awpMT1FhVkVJTFltQ2cweUJ1bC9aTVBFbXFvUDl4Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb3dJQkFBS0NBUUVBdDBFL2VxVTIvellibnFJT2E4Y1ZvSmluMlVWWW9jQUhpQU5WczBLQVJuUXBDYjNFCmxzU3MvckpsN3dERTFocXI0MkNBMFUrdXhQbnhxanZQcHNOVkhGcGh5bitvUDRCb1hDTzIzZGlXKzNtK21RSDIKY1pzYkkvYmc1aU1xZTFaVjM0QWFmb2NkWGU2Vis1bGlyL0JUaU1IMkZpY2RReWliSkcxTzhMZW95bVBySmpMQgowdFJZc0ZCdHlBa0xCSC9MK1VTSjNsS0lIZFJzaXQ0Wm9WRVF1RXhZbi9vYjd0cHYxaWh0QUdvVFFDbysyNmRECi9iZjJZZ1BaMFd5emk1cks1YzVmWllBbnVPY0pwM0J6elB2dm8xc0o4Y3gwTjl5WEFYemllWklZcUwySFUrYisKbE5Hd0NlQnZ1K2xaVGtBc1FKZUxxTWcrTUpEU2ZkRGR1WXhPalFJREFRQUJBb0lCQVFDTTcrYUZTYmxSY0dpdgppUTAwUU1uV1dIR0d2VG1jTk5iVitWS1k2a1ZEYWlVQnMrd1UxREFFTm1vRTlYOXM5dGhKcURlS1F4RXp0dEx3CnpNMDRBVFJjK1BvS3hrRThqV0kxc3RYNktwQjcyYmNIY0NYOFc0RDFHUE1BcS8wSkhHNHcxUklMUzVqL1cvWUgKcVlEbnRScFpyR3E1d04xVmdFNUpKclEybDlsOXhTc2ROazE3eEt3K2srNHhxcWdFRTJUTmsxRDlJeVpsYkhnYQpOQUgvcEVObmxuL1VTa0dyVjZtWTMzT0V1OFFWV2RTclo1bGw5Y05pY3gxUEtZMHRLMEw2QmZoRnNYU0RKUUkyCitpSFRvZWoraWR2dng1YUJQWDJaS3QyQTNmMVV3R1huRXM1SmE3QzUvcm5vME9FWmhsOVJydS93VG1CTG55Z2kKdGdJQmt1K0JBb0dCQU13VDZuWTVFWVZSTWx0elVJNDNYUkJVTUJLU201NnVqdzJvM0U3aUZqam4zSGRlMDBMQQpCQWRlSk1OWWg2UElFWDhzUURLNzhqTGRnN3kzMmd1UmNIRDQxUi96dGxvSDlHMlpHNnZHbkp1YU5SLzE5MzJqCi9Fa3ZDK3pXZU5GbWdLY2MzcUJHMTFqUUU5OHdYVFRrSjl3YTVYTkV3NE5BMWJBVk1xeU1ZREF0QW9HQkFPWGgKRmFETk1pZFJLTWpWZUhld0pHNFZKMmgxSDVhd1VHdUZiaXhPc21JMFJZWUNuT0dEd0xDNGlJeWd4YnJBR2wwaQppZHdvVmZPVnNoUGYraDF0UjdrR1RGQjhpQ3ByODNpaExONytYVEVldHV5Rkh4SUNzajkwZ2JlT25NVHFnM3ROClAvOWRtSnZRcG1mM09ZR2VSbDJnZGQxVno0eWtDNnRVcVZ6RnJUUGhBb0dBVEtDdHlQWmt2Y3BmUGpkdVovZ2gKMlovQzdUWmZlSlhTNFM0bWl2Z1pvQVJ2bytMWE1Ka282aHRQY29vclpEUWJYY1VmMWV6OFpGMEl1alBPaThsdwpqdnJnQzc5WEdUY2pjSU90QURMeld2bnNPTFFDMmdwWkVLRzV1SlJQaVZFVHZhdjVhL1V0cHd0NmFyT2VTOTNmCm1hWC93ZWh3QVRpM0JBYnhvQmlWaFlFQ2dZQi9FVFlsVm9kOG1DNFZKWHFibmkvazhhaUE0d3o4L0tUWGFrQUcKR2RJYzJvdjdrWUlxWGV1clE3V25GazkxOVM0ZGdUUDNFQXpDd21KVy9oMkJHcURrczRpSGpPNnZsRkJXdzdETAo2b3FVMWtlQzRlclV4OHpEcXFEeFY5RnNQNzFCOE9lSlByRlduN1Q4RHZvb25kYURkbWp3V2JpS0l6dVlEd28zCkQ4VzN3UUtCZ0Jyc1dKcFoxMGw3dVUrMnhTUkQ5QzhlNjNVRU5tcG93bjBQODNraStxOGhGVmZLdW5KTU9Od1cKRTJYdWovVWJrUnNQZmVxcGN2UFZkR1g0TUNJNVc1M094dW5PbExxQkZvS1hUd1gzTzR2MTRrMVdhWFdzdm15aQpxbS8zcmRSTkk1OStaM09aZm5WR3lWZkcyMm55amJzMkJTeTZ1cVNMQVZvcS9pczNzY0doCi0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==

----此时这个kubeconfig文件创建完成，但是没有任何权限绑定，所以此文件是没有权限的
[root@k8s-node04 .kube]# kubectl get pods -A
Error from server (Forbidden): pods is forbidden: User "Jack" cannot list resource "pods" in API group "" at the cluster scope

root@k8s-master01:~/k8s/yaml/limit-rbac/role# cat magedu-role.yaml		#创建role
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: magedu
  name: magedu-role
rules:
- apiGroups: ["*"]
  resources: ["pods/exec"]
  #verbs: ["*"]
  ##RO-Role
  verbs: ["get", "list", "watch", "create"]

- apiGroups: ["*"]
  resources: ["pods"]
  #verbs: ["*"]
  ##RO-Role
  verbs: ["get", "list", "watch"]

- apiGroups: ["*"]
  resources: ["deployments", "replicasets", "deployments/scale"]
  #verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  ##RO-Role
  verbs: ["get", "watch", "list"]

- apiGroups: ["*"]
  resources: ["events"]
  ##RO-Role
  verbs: ["get", "watch", "list"]
root@k8s-master01:~/k8s/yaml/limit-rbac/role# kubectl apply -f magedu-role.yaml
role.rbac.authorization.k8s.io/magedu-role configured
root@k8s-master01:~/k8s/yaml/limit-rbac/role# cat magedu-role-user-bind.yaml	#创建rolebinding
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: role-bind-user-magedu
  namespace: magedu
subjects:
- kind: User		#这里是用户绑定，还可以是Group，ServiceAccount
  name: Jack
  namespace: magedu
roleRef:
  kind: Role
  name: magedu-role
  apiGroup: rbac.authorization.k8s.io
root@k8s-master01:~/k8s/yaml/limit-rbac/role# kubectl apply -f magedu-role-user-bind.yaml
rolebinding.rbac.authorization.k8s.io/role-bind-user-magedu created
root@k8s-master01:~/k8s/yaml/limit-rbac/role# kubectl describe rolebinding role-bind-user-magedu -n magedu
Name:         role-bind-user-magedu
Labels:       <none>
Annotations:  <none>
Role:
  Kind:  Role
  Name:  magedu-role
Subjects:
  Kind  Name  Namespace
  ----  ----  ---------
  User  Jack  magedu
root@k8s-master01:~/k8s/yaml/limit-rbac/role# kubectl describe role magedu-role -n magedu
Name:         magedu-role
Labels:       <none>
Annotations:  <none>
PolicyRule:
  Resources            Non-Resource URLs  Resource Names  Verbs
  ---------            -----------------  --------------  -----
  pods.*/exec          []                 []              [get list watch create]
  pods.*               []                 []              [get list watch]
  deployments.*/scale  []                 []              [get watch list]
  deployments.*        []                 []              [get watch list]
  events.*             []                 []              [get watch list]
  replicasets.*        []                 []              [get watch list]

[root@k8s-node04 .kube]# kubectl get pods -n magedu			#查看magedu名称空间下pod
NAME                                                READY   STATUS    RESTARTS   AGE
deploy-devops-redis-749878f59d-gf856                1/1     Running   0          8d
magedu-consumer-deployment-84547497d4-999wr         1/1     Running   0          7d22h
magedu-dubboadmin-deployment-bbd4b4966-sts92        1/1     Running   0          7d20h
magedu-jenkins-deployment-5f94c58f86-kc2hg          1/1     Running   0          8d
magedu-nginx-deployment-849cbbbb9c-kfw45            1/1     Running   0          3h25m
magedu-nginx-deployment-849cbbbb9c-kp59d            1/1     Running   0          61m
magedu-provider-deployment-7656dfd74f-fq652         1/1     Running   0          7d19h
magedu-provider-deployment-7656dfd74f-vpjkl         1/1     Running   0          7d23h
magedu-tomcat-app1-deployment-7d89cf4c79-g7fs7      1/1     Running   0          26h
magedu-tomcat-app1-deployment-v2-797df58f6c-rdhk8   1/1     Running   0          23h
mysql-0                                             2/2     Running   0          8d
wordpress-app-deployment-7d6d5c4c97-jx4kf           2/2     Running   0          4d23h
zookeeper1-749d87b7c5-stk5w                         1/1     Running   1          10d
zookeeper2-5f5fcb7f4d-s5pgp                         1/1     Running   1          10d
zookeeper3-c857bb585-txchq                          1/1     Running   1          10d
[root@k8s-node04 .kube]# kubectl get all -n magedu			#查看magedu名称空间下所有资源
NAME                                                    READY   STATUS    RESTARTS   AGE
pod/deploy-devops-redis-749878f59d-gf856                1/1     Running   0          8d
pod/magedu-consumer-deployment-84547497d4-999wr         1/1     Running   0          7d22h
pod/magedu-dubboadmin-deployment-bbd4b4966-sts92        1/1     Running   0          7d20h
pod/magedu-jenkins-deployment-5f94c58f86-kc2hg          1/1     Running   0          8d
pod/magedu-nginx-deployment-849cbbbb9c-kfw45            1/1     Running   0          3h25m
pod/magedu-nginx-deployment-849cbbbb9c-kp59d            1/1     Running   0          61m
pod/magedu-provider-deployment-7656dfd74f-fq652         1/1     Running   0          7d19h
pod/magedu-provider-deployment-7656dfd74f-vpjkl         1/1     Running   0          7d23h
pod/magedu-tomcat-app1-deployment-7d89cf4c79-g7fs7      1/1     Running   0          26h
pod/magedu-tomcat-app1-deployment-v2-797df58f6c-rdhk8   1/1     Running   0          23h
pod/mysql-0                                             2/2     Running   0          8d
pod/wordpress-app-deployment-7d6d5c4c97-jx4kf           2/2     Running   0          4d23h
pod/zookeeper1-749d87b7c5-stk5w                         1/1     Running   1          10d
pod/zookeeper2-5f5fcb7f4d-s5pgp                         1/1     Running   1          10d
pod/zookeeper3-c857bb585-txchq                          1/1     Running   1          10d

NAME                                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/deploy-devops-redis                1/1     1            1           8d
deployment.apps/magedu-consumer-deployment         1/1     1            1           7d22h
deployment.apps/magedu-dubboadmin-deployment       1/1     1            1           7d20h
deployment.apps/magedu-jenkins-deployment          1/1     1            1           8d
deployment.apps/magedu-nginx-deployment            2/2     2            2           19h
deployment.apps/magedu-provider-deployment         2/2     2            2           7d23h
deployment.apps/magedu-tomcat-app1-deployment      1/1     1            1           26h
deployment.apps/magedu-tomcat-app1-deployment-v2   1/1     1            1           3d17h
deployment.apps/wordpress-app-deployment           1/1     1            1           4d23h
deployment.apps/zookeeper1                         1/1     1            1           10d
deployment.apps/zookeeper2                         1/1     1            1           10d
deployment.apps/zookeeper3                         1/1     1            1           10d

NAME                                                          DESIRED   CURRENT   READY   AGE
replicaset.apps/deploy-devops-redis-749878f59d                1         1         1       8d
replicaset.apps/magedu-consumer-deployment-84547497d4         1         1         1       7d22h
replicaset.apps/magedu-dubboadmin-deployment-bbd4b4966        1         1         1       7d20h
replicaset.apps/magedu-jenkins-deployment-5f94c58f86          1         1         1       8d
replicaset.apps/magedu-nginx-deployment-849cbbbb9c            2         2         2       19h
replicaset.apps/magedu-provider-deployment-7656dfd74f         2         2         2       7d23h
replicaset.apps/magedu-tomcat-app1-deployment-7d89cf4c79      1         1         1       26h
replicaset.apps/magedu-tomcat-app1-deployment-v2-797df58f6c   1         1         1       3d17h
replicaset.apps/wordpress-app-deployment-7d6d5c4c97           1         1         1       4d23h
replicaset.apps/zookeeper1-749d87b7c5                         1         1         1       10d
replicaset.apps/zookeeper2-5f5fcb7f4d                         1         1         1       10d
replicaset.apps/zookeeper3-c857bb585                          1         1         1       10d
Error from server (Forbidden): replicationcontrollers is forbidden: User "Jack" cannot list resource "replicationcontrollers" in API group "" in the namespace "magedu"
Error from server (Forbidden): services is forbidden: User "Jack" cannot list resource "services" in API group "" in the namespace "magedu"
Error from server (Forbidden): daemonsets.apps is forbidden: User "Jack" cannot list resource "daemonsets" in API group "apps" in the namespace "magedu"
Error from server (Forbidden): statefulsets.apps is forbidden: User "Jack" cannot list resource "statefulsets" in API group "apps" in the namespace "magedu"
Error from server (Forbidden): horizontalpodautoscalers.autoscaling is forbidden: User "Jack" cannot list resource "horizontalpodautoscalers" in API group "autoscaling" in the namespace "magedu"
Error from server (Forbidden): cronjobs.batch is forbidden: User "Jack" cannot list resource "cronjobs" in API group "batch" in the namespace "magedu"
Error from server (Forbidden): jobs.batch is forbidden: User "Jack" cannot list resource "jobs" in API group "batch" in the namespace "magedu"
-----
--此时访问dashboard，需要创建添加secret中的token到kubeconfig中才行，否则单单使用上面的kubeconfig是登录不了dashboard的
root@k8s-master01:~/k8s/yaml/limit-rbac/role# kubectl describe secrets magedu-token-qvnbb -n magedu | grep '^token'
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6ImQ3UV9STlJ4TEpQRS1XWmNHblFmaHJOUmdUaW5jMVJvSERqeE9VajR1LWcifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYWdlZHUiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoibWFnZWR1LXRva2VuLXF2bmJiIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6Im1hZ2VkdSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjJmYWZjZjBlLTRkYzUtNDVmOC1iOWY4LTE5MWIxOTdiNzVjOCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYWdlZHU6bWFnZWR1In0.woEJpQGXMqDsp_RjcQrga-UoZ1NFAMcwgVhFaVInobrWIClEykQvrfFChFSwNWYvlgIWB5EqfnviQWUSATiqp5r1hH2sIY50HSQBFKuZKmXQuLf_NB2Y-4rF-paVuX6VxtnlmYz6wMWMCAsid7gBA_G7qF73oFJF5d8n2JHsIlUyrPh9BK0HJ3_vC7YxNBfC5OAH3knWcysVS1iEoN_y9RVHFytYgQqL2659S4XSBc76A7cneyQJ6ZsZEbZRyDJ6FxJs4cTJNPuaIcyMcIB1goX5bLIrj3LrHcd5A3rawXM4WEjdk4YbZVuMCCEeGXSHh1h6rPKnEkAjusoVQJIlzw
root@k8s-master01:~/k8s/yaml/limit-rbac/role# kubectl describe secrets magedu-token-qvnbb -n magedu | grep '^token'
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6ImQ3UV9STlJ4TEpQRS1XWmNHblFmaHJOUmdUaW5jMVJvSERqeE9VajR1LWcifQ.eyJpc3MiOiJrdWJlcmzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYWdlZHUiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhW50L3NlY3JldC5uYW1lIjoibWFnZWR1LXRva2VuLXF2bmJiIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImkdSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjJmYWZjZjBlLTRkYzUtNDVmOC1iOWY4LTE5MWIxOTdiNzVjnN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYWdlZHU6bWFnZWR1In0.woEJpQGXMqDsp_RjcQrga-UoZ1NFAMcwgVhFaVInobrWIClEykQvrfFChFSwNWWB5EqfnviQWUSATiqp5r1hH2sIY50HSQBFKuZKmXQuLf_NB2Y-4rF-paVuX6VxtnlmYz6wMWMCAsid7gBA_G7qF73oFJF5d8n2JHsIlUyrPh9BK0HJ3_vC7YxOAH3knWcysVS1iEoN_y9RVHFytYgQqL2659S4XSBc76A7cneyQJ6ZsZEbZRyDJ6FxJs4cTJNPuaIcyMcIB1goX5bLIrj3LrHcd5A3rawXM4WEjdk4YbZVuMCCHh1h6rPKnEkAjusoVQJIlzw
root@k8s-master01:~/k8s/yaml/limit-rbac/role# cat Jack.kubeconfig
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUR1RENDQXFDZ0F3SUJBZ0lVWTkvWDRUM3N6T0FsZktmbm1jV3I0MzdpdDUwd0RRWUpLb1pJaHZjTkFRRUwKQlFBd1lURUxNQWtHQTFVRUJoTUNRMDR4RVRBUEJnTlZCQWdUQ0VoaGJtZGFhRzkxTVFzd0NRWURWUVFIRXdKWQpVekVNTUFvR0ExVUVDaE1EYXpoek1ROHdEUVlEVlFRTEV3WlRlWE4wWlcweEV6QVJCZ05WQkFNVENtdDFZbVZ5CmJtVjBaWE13SUJjTk1qSXdNekEwTVRFeU1qQXdXaGdQTWpFeU1qQXlNRGd4TVRJeU1EQmFNR0V4Q3pBSkJnTlYKQkFZVEFrTk9NUkV3RHdZRFZRUUlFd2hJWVc1bldtaHZkVEVMTUFrR0ExVUVCeE1DV0ZNeEREQUtCZ05WQkFvVApBMnM0Y3pFUE1BMEdBMVVFQ3hNR1UzbHpkR1Z0TVJNd0VRWURWUVFERXdwcmRXSmxjbTVsZEdWek1JSUJJakFOCkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQTNtYm0zaHM3WlJ3WEdEUktkUW9rR25QVjVNbUQKYUEzNnpaZ0VXWUJNSkIvZDBOSEFkQkZDY1dLb3ArNUF2SFk3elBjeGdNelpRZ1B4TU9DcU9CS09NUVJYNG4ydApENmYxbUZrMzFNRDBEMXJGVTBXcGYwanRiampNMmNEOW5wU2trcmZ4dDliWlh2NHRHNFpDUlB4U1RJbkxDU0RkClVNYnN6OUFXVkZNamtnSndUa3FpU2NIZitod1FvOWZVdVduekZTWWdGUUppUWtWRVZqaGErYU5DK2oyUjNOQjUKN1hDS1RHMFBUNS9JVVFEL2t2V0doL0NoZEZUQmREV0plL0d4cnpkYlAxejRQbnBvSTBvaThDN1MwakErVlJKRApMcS9WcE5TY2d1WFB6ZXNPZSs3Tk9Ub0hwZURyVGJxTER5aVRMbEVWNmRWWG5ScE9tdG9XdjI2OU13SURBUUFCCm8yWXdaREFPQmdOVkhROEJBZjhFQkFNQ0FRWXdFZ1lEVlIwVEFRSC9CQWd3QmdFQi93SUJBakFkQmdOVkhRNEUKRmdRVXhxbndaUFpNTEZUeUhJVzNzcWNyaGJmZEl0QXdId1lEVlIwakJCZ3dGb0FVeHFud1pQWk1MRlR5SElXMwpzcWNyaGJmZEl0QXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBTFpndlVIOEh1SDRIYnJtUW80ejFOTWJKamZVCmlHaFYzdmpFRitIVHlhejByOU1HSlo5b1p3M2hpK0ZpUUJEaUFGSjNvTEVtWVEweDFLd2VlUnorQUlwOVV6QUEKaE5ETVB2YmlqTXl3b3JRNTdzN3BSWlMzejB5RHJ1MEh2R21WRkl6WjRzcm05TjZ2SnVORGUvbklBc0o5eitzbwpKN2doQ3k3Z0dqL2w5dXV2dmovNk8vNVJTVVc4WGE3NWZPR2ZESjFVdUdyemMzbE1mTkNwVUJwMFFXTXVtWHFRClJReHZuKzdRQWdQcitQRk9OLzZMSVkxYlZwNmkvUHhaZ2xjcHFnRjV4QUZ4VEFJYmRXdjVxTjVVQUNsWTFwOE8KVEwyeG9LQVdsQ1IydkdpVS8zbWJTZ2prd3JzRTRRZ3hweHdMdklUc2FNNWtINVF3YUMvalNIR0V3SlE9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://172.168.2.21:6443
  name: cluster1
contexts:
- context:
    cluster: cluster1
    namespace: magedu
    user: Jack
  name: cluster1
current-context: cluster1
kind: Config
preferences: {}
users:
- name: Jack
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUQwVENDQXJtZ0F3SUJBZ0lVU2lkVkR3UEJJNnl6SzR0NkVYNUVoWTJqRDZFd0RRWUpLb1pJaHZjTkFRRUwKQlFBd1lURUxNQWtHQTFVRUJoTUNRMDR4RVRBUEJnTlZCQWdUQ0VoaGJtZGFhRzkxTVFzd0NRWURWUVFIRXdKWQpVekVNTUFvR0ExVUVDaE1EYXpoek1ROHdEUVlEVlFRTEV3WlRlWE4wWlcweEV6QVJCZ05WQkFNVENtdDFZbVZ5CmJtVjBaWE13SUJjTk1qSXdOREF6TURZMU9EQXdXaGdQTWpBM01qQXpNakV3TmpVNE1EQmFNR0V4Q3pBSkJnTlYKQkFZVEFrTk9NUkV3RHdZRFZRUUlFd2hUYUdGdVoyaGhhVEVSTUE4R0ExVUVCeE1JVTJoaGJtZG9ZV2t4RERBSwpCZ05WQkFvVEEyczRjekVQTUEwR0ExVUVDeE1HVTNsemRHVnRNUTB3Q3dZRFZRUURFd1JLWVdOck1JSUJJakFOCkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQXQwRS9lcVUyL3pZYm5xSU9hOGNWb0ppbjJVVlkKb2NBSGlBTlZzMEtBUm5RcENiM0Vsc1NzL3JKbDd3REUxaHFyNDJDQTBVK3V4UG54cWp2UHBzTlZIRnBoeW4rbwpQNEJvWENPMjNkaVcrM20rbVFIMmNac2JJL2JnNWlNcWUxWlYzNEFhZm9jZFhlNlYrNWxpci9CVGlNSDJGaWNkClF5aWJKRzFPOExlb3ltUHJKakxCMHRSWXNGQnR5QWtMQkgvTCtVU0ozbEtJSGRSc2l0NFpvVkVRdUV4WW4vb2IKN3RwdjFpaHRBR29UUUNvKzI2ZEQvYmYyWWdQWjBXeXppNXJLNWM1ZlpZQW51T2NKcDNCenpQdnZvMXNKOGN4MApOOXlYQVh6aWVaSVlxTDJIVStiK2xOR3dDZUJ2dStsWlRrQXNRSmVMcU1nK01KRFNmZERkdVl4T2pRSURBUUFCCm8zOHdmVEFPQmdOVkhROEJBZjhFQkFNQ0JhQXdIUVlEVlIwbEJCWXdGQVlJS3dZQkJRVUhBd0VHQ0NzR0FRVUYKQndNQ01Bd0dBMVVkRXdFQi93UUNNQUF3SFFZRFZSME9CQllFRlB0QXAxR2VTc3VzSGlwOVZMd1pDdnZFQUwwdQpNQjhHQTFVZEl3UVlNQmFBRk1hcDhHVDJUQ3hVOGh5RnQ3S25LNFczM1NMUU1BMEdDU3FHU0liM0RRRUJDd1VBCkE0SUJBUUJZWXdkNzJJSjFST1RwS3NaeHJxN2pZb0h3Wkk5VDNHaGZQaktpRVVpNlBNT2hoamd2NUE3cG8yZGgKMG91aUhINmNBc0dLdGNkcnpTYXhuRUh1aFVtMXlYYTZjRXZYMWxzMms1eHB4azNwczBzVkZPSi80cFZxWnR1cgpVdllIVXdvaXpmZkwvN3h4ektUOGFqMUh0VTVJL3pxclI2MWR1U2kzQ0VoK2NhVVF4MnNiZlJnUWp5RjNMWDJKCkhZWkc0bEhZM2l1R2VjR25hdmFqcllIUFJGUDFLRnF1akhJeWhpL3l4UGpMUzgvRStxQSt2aXhNbzRyQUpRdkEKc280enREVm9oU05WeXVCK2J3aVpBaUl6a0E5cG1CQUl0dEhrcXdEclk2OXI4UnovbEk1dkhkclNxZ0VnV1M4awpMT1FhVkVJTFltQ2cweUJ1bC9aTVBFbXFvUDl4Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb3dJQkFBS0NBUUVBdDBFL2VxVTIvellibnFJT2E4Y1ZvSmluMlVWWW9jQUhpQU5WczBLQVJuUXBDYjNFCmxzU3MvckpsN3dERTFocXI0MkNBMFUrdXhQbnhxanZQcHNOVkhGcGh5bitvUDRCb1hDTzIzZGlXKzNtK21RSDIKY1pzYkkvYmc1aU1xZTFaVjM0QWFmb2NkWGU2Vis1bGlyL0JUaU1IMkZpY2RReWliSkcxTzhMZW95bVBySmpMQgowdFJZc0ZCdHlBa0xCSC9MK1VTSjNsS0lIZFJzaXQ0Wm9WRVF1RXhZbi9vYjd0cHYxaWh0QUdvVFFDbysyNmRECi9iZjJZZ1BaMFd5emk1cks1YzVmWllBbnVPY0pwM0J6elB2dm8xc0o4Y3gwTjl5WEFYemllWklZcUwySFUrYisKbE5Hd0NlQnZ1K2xaVGtBc1FKZUxxTWcrTUpEU2ZkRGR1WXhPalFJREFRQUJBb0lCQVFDTTcrYUZTYmxSY0dpdgppUTAwUU1uV1dIR0d2VG1jTk5iVitWS1k2a1ZEYWlVQnMrd1UxREFFTm1vRTlYOXM5dGhKcURlS1F4RXp0dEx3CnpNMDRBVFJjK1BvS3hrRThqV0kxc3RYNktwQjcyYmNIY0NYOFc0RDFHUE1BcS8wSkhHNHcxUklMUzVqL1cvWUgKcVlEbnRScFpyR3E1d04xVmdFNUpKclEybDlsOXhTc2ROazE3eEt3K2srNHhxcWdFRTJUTmsxRDlJeVpsYkhnYQpOQUgvcEVObmxuL1VTa0dyVjZtWTMzT0V1OFFWV2RTclo1bGw5Y05pY3gxUEtZMHRLMEw2QmZoRnNYU0RKUUkyCitpSFRvZWoraWR2dng1YUJQWDJaS3QyQTNmMVV3R1huRXM1SmE3QzUvcm5vME9FWmhsOVJydS93VG1CTG55Z2kKdGdJQmt1K0JBb0dCQU13VDZuWTVFWVZSTWx0elVJNDNYUkJVTUJLU201NnVqdzJvM0U3aUZqam4zSGRlMDBMQQpCQWRlSk1OWWg2UElFWDhzUURLNzhqTGRnN3kzMmd1UmNIRDQxUi96dGxvSDlHMlpHNnZHbkp1YU5SLzE5MzJqCi9Fa3ZDK3pXZU5GbWdLY2MzcUJHMTFqUUU5OHdYVFRrSjl3YTVYTkV3NE5BMWJBVk1xeU1ZREF0QW9HQkFPWGgKRmFETk1pZFJLTWpWZUhld0pHNFZKMmgxSDVhd1VHdUZiaXhPc21JMFJZWUNuT0dEd0xDNGlJeWd4YnJBR2wwaQppZHdvVmZPVnNoUGYraDF0UjdrR1RGQjhpQ3ByODNpaExONytYVEVldHV5Rkh4SUNzajkwZ2JlT25NVHFnM3ROClAvOWRtSnZRcG1mM09ZR2VSbDJnZGQxVno0eWtDNnRVcVZ6RnJUUGhBb0dBVEtDdHlQWmt2Y3BmUGpkdVovZ2gKMlovQzdUWmZlSlhTNFM0bWl2Z1pvQVJ2bytMWE1Ka282aHRQY29vclpEUWJYY1VmMWV6OFpGMEl1alBPaThsdwpqdnJnQzc5WEdUY2pjSU90QURMeld2bnNPTFFDMmdwWkVLRzV1SlJQaVZFVHZhdjVhL1V0cHd0NmFyT2VTOTNmCm1hWC93ZWh3QVRpM0JBYnhvQmlWaFlFQ2dZQi9FVFlsVm9kOG1DNFZKWHFibmkvazhhaUE0d3o4L0tUWGFrQUcKR2RJYzJvdjdrWUlxWGV1clE3V25GazkxOVM0ZGdUUDNFQXpDd21KVy9oMkJHcURrczRpSGpPNnZsRkJXdzdETAo2b3FVMWtlQzRlclV4OHpEcXFEeFY5RnNQNzFCOE9lSlByRlduN1Q4RHZvb25kYURkbWp3V2JpS0l6dVlEd28zCkQ4VzN3UUtCZ0Jyc1dKcFoxMGw3dVUrMnhTUkQ5QzhlNjNVRU5tcG93bjBQODNraStxOGhGVmZLdW5KTU9Od1cKRTJYdWovVWJrUnNQZmVxcGN2UFZkR1g0TUNJNVc1M094dW5PbExxQkZvS1hUd1gzTzR2MTRrMVdhWFdzdm15aQpxbS8zcmRSTkk1OStaM09aZm5WR3lWZkcyMm55amJzMkJTeTZ1cVNMQVZvcS9pczNzY0doCi0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==
    token: eyJhbGciOiJSUzI1NiIsImtpZCI6ImQ3UV9STlJ4TEpQRS1XWmNHblFmaHJOUmdUaW5jMVJvSERqeE9VajR1LWcifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYWdlZHUiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoibWFnZWR1LXRva2VuLXF2bmJiIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6Im1hZ2VkdSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjJmYWZjZjBlLTRkYzUtNDVmOC1iOWY4LTE5MWIxOTdiNzVjOCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYWdlZHU6bWFnZWR1In0.woEJpQGXMqDsp_RjcQrga-UoZ1NFAMcwgVhFaVInobrWIClEykQvrfFChFSwNWYvlgIWB5EqfnviQWUSATiqp5r1hH2sIY50HSQBFKuZKmXQuLf_NB2Y-4rF-paVuX6VxtnlmYz6wMWMCAsid7gBA_G7qF73oFJF5d8n2JHsIlUyrPh9BK0HJ3_vC7YxNBfC5OAH3knWcysVS1iEoN_y9RVHFytYgQqL2659S4XSBc76A7cneyQJ6ZsZEbZRyDJ6FxJs4cTJNPuaIcyMcIB1goX5bLIrj3LrHcd5A3rawXM4WEjdk4YbZVuMCCEeGXSHh1h6rPKnEkAjusoVQJIlzw
#token前面有四个空格



6.6 k8s网络，容器网络
1. overlay网络模型--性能最差，扩展性最好
2. 路由网络模型--性能其次，扩展性其次
3. underlay网络模型--性能最好，扩展性最差，依赖物理网络。

--underlay网络
每个pod都使用的是物理网络的IP地址，维护起来非常困难。较为觉的解决方案有MAC VLAN,IP VLAN,和直接路由等。
	MAC VLAN: 每个容器都有一个独立的MAC和IP地址，主机跟交换机之间连接需要使用trunk模式
	IP VLAN: 
		IP VLAN L2: 类似MAC VLAN,在内核4.2以后才支持。
		IP VLAN L3: 每个容器都有一个独立的IP地址，共享宿主机网络接口上的MAC地址，在内核4.2以后才支持。

--overlay网络/路由网络
flannel插件：
	1. vxlan: 
		1.1 vxlan，可以跨三层网络，overlay网络模型（4层），vxlan会监听upd 8472端口(linux)/4789端口(windows)，可抓包分析 tcpdump -i eth0 udp port 8472 -nnnn -vvvv
		1.2.vxlan Directrouting，类似host-gw，不能跨三层网络，只能二层，属于路由模型
	2. host-gw: HOST Gateway（性能比VxLAN好，但是不能跨三层网络），属于路由模型
	3. UDP: 基于普通UDP转发，性能最差，在以上两种不能使用时才使用这种。
calico插件：
calico封装类型：VXLAN（非BGP非议）和IP-in-IP（BGP协议）
	1. BGP模式：将节点做为虚拟路由器通过 BGP 路由协议来实现集群内容器之间的网络访问。只能在同一个子网，属于路由网络，性能较好，但扩展性差
	2. IPIP模式：在原有IP报文中封装一个新的IP报文，新的IP报文中将源地址IP和目的地址IP都修改为对端宿主机IP。使用遂道技术，属于overlay网络模型（三层）
	3. cross-subnet模式：Calico-ipip模式和calico-bgp模式都有对应的局限性，对于一些主机跨子网而又无法使网络设备使用BGP的场景可以使用cross-subnet 模式，实现同子网机器使用calico-BGP模式，跨子网机器使用calico-ipip模式。



默认情况下calico在集群层面分配一个10.42.0.0/16的CIDR网段，在这基础上在单独为每个主机划分一个单独子网采用26位子网掩码对应的集群支持的节点数为 2^10=1024 节点，单个子网最大支持 64 个 POD，当单个子网对应 IP 消耗后，calico 会重新在本机上划分一个新的子网
注意：块大小将影响节点POD的IP地址分配和路由条目数量，如果主机在一个CIDR中分配所有地址，则将为其分配一个附加CIDR。如果没有更多可用的块，则主机可以从分配给其他主机的 CIDR 中获取地址。为借用的地址添加了特定的路由，这会影响路由表的大小。

SERVICE_CIDR="10.68.0.0/16"		#service网络，每个IP地址都是32位掩码，没有子网划分，所以有2^16=65536个service地址
CLUSTER_CIDR="172.20.0.0/16"	#pod网络，如果是calico每个子网掩码是255.255.255.192，也就是可以运行2^10=1024个节点，每个节点只能运行62个pod。如果是flannel每个子网掩码是255.255.255.0，也就是可以运行2^8=256个节点，每个节点可以运行254个pod。

--calico网络配置
calico 允许用户修改对应的 IP 池和集群 CIDR，创建和替换步骤注意：删除Pod时，应用程序会出现暂时不可用，pod就使用控制器进行管理，并运行多个副本
	1. 添加一个新的 IP 池。
	2. 注意：新 IP 池必须在同一群集 CIDR 中。
	3. 禁用旧的 IP 池（注意：禁用 IP 池只会阻止分配新的 IP 地址。它不会影响现有 POD 的联网）
	4. 从旧的 IP 池中删除 Pod。
	5. 验证新的 Pod 是否从新的 IP 池中获取地址。
	6. 删除旧的 IP 池。
--查看calico ip池配置
root@k8s-master01:~# calicoctl get ipPool -o yaml
apiVersion: projectcalico.org/v3
items:
- apiVersion: projectcalico.org/v3
  kind: IPPool
  metadata:
    creationTimestamp: "2022-03-04T13:51:46Z"
    name: default-ipv4-ippool
    resourceVersion: "1194"
    uid: bc2c260c-18b3-4d48-9f01-fe47b08943ef
  spec:
    blockSize: 26
    cidr: 172.20.0.0/16
    ipipMode: Always
    natOutgoing: true
    nodeSelector: all()
    vxlanMode: Never
kind: IPPoolList
metadata:
  resourceVersion: "5014664"

--定义 ippool 资源
apiVersion: projectcalico.org/v3
items:
- apiVersion: projectcalico.org/v3
  kind: IPPool
  metadata:
    name: my-ippool
  spec:
    blockSize: 24
    cidr: 192.0.0.0/16
    ipipMode: Always
    natOutgoing: true
    nodeSelector: all()
    vxlanMode: Never
calicoctl apply -f pool.yaml		#创建新的
calicoctl patch ippool default-ipv4-ippool -p '{"spec": {"disabled": "true"}}'		#将旧的 ippool 禁用，最后创建 workload 测试



6.7 k8s监控，prometheus
开源监控解决方案：cacti,nagios,zabbix,smokeping,open-falcon,Nightingale(滴滴基于open-falcon开发开源),prometheus
商业监控解决方案：监控宝，听云

--在k8s中部署prometheus
--prometheus operator部署
DownnloadURL: https://github.com/prometheus-operator/kube-prometheus
-------对k8s版本依赖------
kube-prometheus stack	Kubernetes 1.19	Kubernetes 1.20	Kubernetes 1.21	Kubernetes 1.22	Kubernetes 1.23
release-0.7	✔	✔	✗	✗	✗
release-0.8	✗	✔	✔	✗	✗
release-0.9	✗	✗	✔	✔	✗
release-0.10	✗	✗	✗	✔	✔
main	✗	✗	✗	✔	✔
-------------------------
kubroot@k8s-master01:~# kubectl get nodes		#k8s版本为v1.21.5
NAME            STATUS                     ROLES    AGE   VERSION
172.168.2.21    Ready,SchedulingDisabled   master   30d   v1.21.5
172.168.2.22    Ready,SchedulingDisabled   master   30d   v1.21.5
172.168.2.23    Ready,SchedulingDisabled   master   29d   v1.21.5
172.168.2.24    Ready                      node     30d   v1.21.5
172.168.2.25    Ready                      node     30d   v1.21.5
172.168.2.26    Ready                      node     29d   v1.21.5
192.168.13.63   Ready                      node     14d   v1.21.5
--clone kube-prometheus源代码，主要是manifests目录的yaml文件
root@k8s-master01:~/k8s/yaml# git clone -b release-0.9 https://github.com/prometheus-operator/kube-prometheus.git
root@k8s-master01:~/k8s/yaml# cd kube-prometheus/manifests/
root@k8s-master01:~/k8s/yaml/kube-prometheus/manifests# cd setup/
root@k8s-master01:~/k8s/yaml/kube-prometheus/manifests/setup# ll
total 1080
drwxr-xr-x 2 root root   4096 Apr  4 14:47 ./
drwxr-xr-x 3 root root   4096 Apr  4 14:47 ../
-rw-r--r-- 1 root root     60 Apr  4 14:47 0namespace-namespace.yaml
-rw-r--r-- 1 root root 122054 Apr  4 14:47 prometheus-operator-0alertmanagerConfigCustomResourceDefinition.yaml
-rw-r--r-- 1 root root 247084 Apr  4 14:47 prometheus-operator-0alertmanagerCustomResourceDefinition.yaml
-rw-r--r-- 1 root root  26989 Apr  4 14:47 prometheus-operator-0podmonitorCustomResourceDefinition.yaml
-rw-r--r-- 1 root root  26119 Apr  4 14:47 prometheus-operator-0probeCustomResourceDefinition.yaml
-rw-r--r-- 1 root root 350889 Apr  4 14:47 prometheus-operator-0prometheusCustomResourceDefinition.yaml
-rw-r--r-- 1 root root   3899 Apr  4 14:47 prometheus-operator-0prometheusruleCustomResourceDefinition.yaml
-rw-r--r-- 1 root root  28287 Apr  4 14:47 prometheus-operator-0servicemonitorCustomResourceDefinition.yaml
-rw-r--r-- 1 root root 253551 Apr  4 14:47 prometheus-operator-0thanosrulerCustomResourceDefinition.yaml
-rw-r--r-- 1 root root    471 Apr  4 14:47 prometheus-operator-clusterRoleBinding.yaml
-rw-r--r-- 1 root root   1377 Apr  4 14:47 prometheus-operator-clusterRole.yaml
-rw-r--r-- 1 root root   2350 Apr  4 14:47 prometheus-operator-deployment.yaml
-rw-r--r-- 1 root root    285 Apr  4 14:47 prometheus-operator-serviceAccount.yaml
-rw-r--r-- 1 root root    515 Apr  4 14:47 prometheus-operator-service.yaml
root@k8s-master01:~/k8s/yaml/kube-prometheus/manifests/setup# grep -ri image: ./*
./prometheus-operator-0alertmanagerCustomResourceDefinition.yaml:              baseImage:
./prometheus-operator-0alertmanagerCustomResourceDefinition.yaml:                    image:
./prometheus-operator-0alertmanagerCustomResourceDefinition.yaml:              image:
./prometheus-operator-0alertmanagerCustomResourceDefinition.yaml:                    image:
./prometheus-operator-0alertmanagerCustomResourceDefinition.yaml:                        image:
./prometheus-operator-0prometheusCustomResourceDefinition.yaml:              baseImage:
./prometheus-operator-0prometheusCustomResourceDefinition.yaml:                    image:
./prometheus-operator-0prometheusCustomResourceDefinition.yaml:              image:
./prometheus-operator-0prometheusCustomResourceDefinition.yaml:                    image:
./prometheus-operator-0prometheusCustomResourceDefinition.yaml:                  baseImage:
./prometheus-operator-0prometheusCustomResourceDefinition.yaml:                  image:
./prometheus-operator-0prometheusCustomResourceDefinition.yaml:                        image:
./prometheus-operator-0thanosrulerCustomResourceDefinition.yaml:                    image:
./prometheus-operator-0thanosrulerCustomResourceDefinition.yaml:              image:
./prometheus-operator-0thanosrulerCustomResourceDefinition.yaml:                    image:
./prometheus-operator-0thanosrulerCustomResourceDefinition.yaml:                        image:
./prometheus-operator-deployment.yaml:        image: quay.io/prometheus-operator/prometheus-operator:v0.49.0		#提前下载好放到自己的harbor
./prometheus-operator-deployment.yaml:        image: quay.io/brancz/kube-rbac-proxy:v0.11.0							#提前下载好放到自己的harbor
root@k8s-master01:~/k8s/yaml/kube-prometheus/manifests/setup# docker pull quay.io/prometheus-operator/prometheus-operator:v0.49.0
root@k8s-master01:~/k8s/yaml/kube-prometheus/manifests/setup# docker tag quay.io/prometheus-operator/prometheus-operator:v0.49.0 192.168.13.197:8000/baseimages/prometheus-operator:v0.49.0
root@k8s-master01:~/k8s/yaml/kube-prometheus/manifests/setup# docker push 192.168.13.197:8000/baseimages/prometheus-operator:v0.49.0
root@k8s-master01:~/k8s/yaml/kube-prometheus/manifests/setup# docker pull  quay.io/brancz/kube-rbac-proxy:v0.11.0
root@k8s-master01:~/k8s/yaml/kube-prometheus/manifests/setup# docker tag quay.io/brancz/kube-rbac-proxy:v0.11.0 192.168.13.197:8000/baseimages/kube-rbac-proxy:v0.11.0
root@k8s-master01:~/k8s/yaml/kube-prometheus/manifests/setup# docker push 192.168.13.197:8000/baseimages/kube-rbac-proxy:v0.11.0
root@k8s-master01:~/k8s/yaml/kube-prometheus/manifests/setup# vim ./prometheus-operator-deployment.yaml		#更改配置文件更换镜像地址为本地镜像地址
root@k8s-master01:~/k8s/yaml/kube-prometheus/manifests/setup# kubectl apply -f .	#应用setup中的yaml基本文件，其实是运行prometheus-operator
root@k8s-master01:~/k8s/yaml/kube-prometheus/manifests/setup# cd ..
root@k8s-master01:~/k8s/yaml/kube-prometheus/manifests# ll
total 1812
drwxr-xr-x  3 root root    4096 Apr  4 15:44 ./
drwxr-xr-x 12 root root    4096 Apr  4 14:47 ../
-rw-r--r--  1 root root     875 Apr  4 14:47 alertmanager-alertmanager.yaml
-rw-r--r--  1 root root     515 Apr  4 14:47 alertmanager-podDisruptionBudget.yaml
-rw-r--r--  1 root root    6855 Apr  4 14:47 alertmanager-prometheusRule.yaml
-rw-r--r--  1 root root    1169 Apr  4 14:47 alertmanager-secret.yaml
-rw-r--r--  1 root root     301 Apr  4 14:47 alertmanager-serviceAccount.yaml
-rw-r--r--  1 root root     540 Apr  4 14:47 alertmanager-serviceMonitor.yaml
-rw-r--r--  1 root root     577 Apr  4 14:47 alertmanager-service.yaml
-rw-r--r--  1 root root     278 Apr  4 14:47 blackbox-exporter-clusterRoleBinding.yaml
-rw-r--r--  1 root root     287 Apr  4 14:47 blackbox-exporter-clusterRole.yaml
-rw-r--r--  1 root root    1392 Apr  4 14:47 blackbox-exporter-configuration.yaml
-rw-r--r--  1 root root    3081 Apr  4 14:47 blackbox-exporter-deployment.yaml
-rw-r--r--  1 root root      96 Apr  4 14:47 blackbox-exporter-serviceAccount.yaml
-rw-r--r--  1 root root     680 Apr  4 14:47 blackbox-exporter-serviceMonitor.yaml
-rw-r--r--  1 root root     540 Apr  4 14:47 blackbox-exporter-service.yaml
-rw-r--r--  1 root root     721 Apr  4 14:47 grafana-dashboardDatasources.yaml
-rw-r--r--  1 root root 1448205 Apr  4 14:47 grafana-dashboardDefinitions.yaml
-rw-r--r--  1 root root     625 Apr  4 14:47 grafana-dashboardSources.yaml
-rw-r--r--  1 root root    8098 Apr  4 14:47 grafana-deployment.yaml
-rw-r--r--  1 root root      86 Apr  4 14:47 grafana-serviceAccount.yaml
-rw-r--r--  1 root root     398 Apr  4 14:47 grafana-serviceMonitor.yaml
-rw-r--r--  1 root root     452 Apr  4 14:47 grafana-service.yaml
-rw-r--r--  1 root root    3380 Apr  4 14:47 kube-prometheus-prometheusRule.yaml
-rw-r--r--  1 root root   64451 Apr  4 14:47 kubernetes-prometheusRule.yaml
-rw-r--r--  1 root root    6912 Apr  4 14:47 kubernetes-serviceMonitorApiserver.yaml
-rw-r--r--  1 root root     425 Apr  4 14:47 kubernetes-serviceMonitorCoreDNS.yaml
-rw-r--r--  1 root root    6431 Apr  4 14:47 kubernetes-serviceMonitorKubeControllerManager.yaml
-rw-r--r--  1 root root    7629 Apr  4 14:47 kubernetes-serviceMonitorKubelet.yaml
-rw-r--r--  1 root root     530 Apr  4 14:47 kubernetes-serviceMonitorKubeScheduler.yaml
-rw-r--r--  1 root root     464 Apr  4 14:47 kube-state-metrics-clusterRoleBinding.yaml
-rw-r--r--  1 root root    1712 Apr  4 14:47 kube-state-metrics-clusterRole.yaml
-rw-r--r--  1 root root    2959 Apr  4 15:43 kube-state-metrics-deployment.yaml
-rw-r--r--  1 root root    3082 Apr  4 14:47 kube-state-metrics-prometheusRule.yaml
-rw-r--r--  1 root root     280 Apr  4 14:47 kube-state-metrics-serviceAccount.yaml
-rw-r--r--  1 root root    1011 Apr  4 14:47 kube-state-metrics-serviceMonitor.yaml
-rw-r--r--  1 root root     580 Apr  4 14:47 kube-state-metrics-service.yaml
-rw-r--r--  1 root root     444 Apr  4 14:47 node-exporter-clusterRoleBinding.yaml
-rw-r--r--  1 root root     461 Apr  4 14:47 node-exporter-clusterRole.yaml
-rw-r--r--  1 root root    3047 Apr  4 14:47 node-exporter-daemonset.yaml
-rw-r--r--  1 root root   13986 Apr  4 14:47 node-exporter-prometheusRule.yaml
-rw-r--r--  1 root root     270 Apr  4 14:47 node-exporter-serviceAccount.yaml
-rw-r--r--  1 root root     850 Apr  4 14:47 node-exporter-serviceMonitor.yaml
-rw-r--r--  1 root root     492 Apr  4 14:47 node-exporter-service.yaml
-rw-r--r--  1 root root     482 Apr  4 14:47 prometheus-adapter-apiService.yaml
-rw-r--r--  1 root root     576 Apr  4 14:47 prometheus-adapter-clusterRoleAggregatedMetricsReader.yaml
-rw-r--r--  1 root root     494 Apr  4 14:47 prometheus-adapter-clusterRoleBindingDelegator.yaml
-rw-r--r--  1 root root     471 Apr  4 14:47 prometheus-adapter-clusterRoleBinding.yaml
-rw-r--r--  1 root root     378 Apr  4 14:47 prometheus-adapter-clusterRoleServerResources.yaml
-rw-r--r--  1 root root     409 Apr  4 14:47 prometheus-adapter-clusterRole.yaml
-rw-r--r--  1 root root    2204 Apr  4 14:47 prometheus-adapter-configMap.yaml
-rw-r--r--  1 root root    2525 Apr  4 15:44 prometheus-adapter-deployment.yaml
-rw-r--r--  1 root root     506 Apr  4 14:47 prometheus-adapter-podDisruptionBudget.yaml
-rw-r--r--  1 root root     515 Apr  4 14:47 prometheus-adapter-roleBindingAuthReader.yaml
-rw-r--r--  1 root root     287 Apr  4 14:47 prometheus-adapter-serviceAccount.yaml
-rw-r--r--  1 root root     677 Apr  4 14:47 prometheus-adapter-serviceMonitor.yaml
-rw-r--r--  1 root root     501 Apr  4 14:47 prometheus-adapter-service.yaml
-rw-r--r--  1 root root     447 Apr  4 14:47 prometheus-clusterRoleBinding.yaml
-rw-r--r--  1 root root     394 Apr  4 14:47 prometheus-clusterRole.yaml
-rw-r--r--  1 root root    5000 Apr  4 14:47 prometheus-operator-prometheusRule.yaml
-rw-r--r--  1 root root     715 Apr  4 14:47 prometheus-operator-serviceMonitor.yaml
-rw-r--r--  1 root root     499 Apr  4 14:47 prometheus-podDisruptionBudget.yaml
-rw-r--r--  1 root root   14021 Apr  4 14:47 prometheus-prometheusRule.yaml
-rw-r--r--  1 root root    1184 Apr  4 14:47 prometheus-prometheus.yaml
-rw-r--r--  1 root root     471 Apr  4 14:47 prometheus-roleBindingConfig.yaml
-rw-r--r--  1 root root    1547 Apr  4 14:47 prometheus-roleBindingSpecificNamespaces.yaml
-rw-r--r--  1 root root     366 Apr  4 14:47 prometheus-roleConfig.yaml
-rw-r--r--  1 root root    2047 Apr  4 14:47 prometheus-roleSpecificNamespaces.yaml
-rw-r--r--  1 root root     271 Apr  4 14:47 prometheus-serviceAccount.yaml
-rw-r--r--  1 root root     531 Apr  4 14:47 prometheus-serviceMonitor.yaml
-rw-r--r--  1 root root     558 Apr  4 14:47 prometheus-service.yaml
drwxr-xr-x  2 root root    4096 Apr  4 15:28 setup/
root@k8s-master01:~/k8s/yaml/kube-prometheus/manifests# grep -ri image: . | grep gcr
./kube-state-metrics-deployment.yaml:        image: k8s.gcr.io/kube-state-metrics/kube-state-metrics:v2.1.1
./prometheus-adapter-deployment.yaml:        image: k8s.gcr.io/prometheus-adapter/prometheus-adapter:v0.9.0
root@k8s-master01:~/k8s/yaml/kube-prometheus/manifests# docker pull bitnami/kube-state-metrics:2.1.1
root@k8s-master01:~/k8s/yaml/kube-prometheus/manifests# docker tag bitnami/kube-state-metrics:2.1.1 192.168.13.197:8000/baseimages/kube-state-metrics:2.1.1
root@k8s-master01:~/k8s/yaml/kube-prometheus/manifests# docker push 192.168.13.197:8000/baseimages/kube-state-metrics:2.1.1
root@k8s-master01:~/k8s/yaml/kube-prometheus/manifests# docker pull willdockerhub/prometheus-adapter:v0.9.0
root@k8s-master01:~/k8s/yaml/kube-prometheus/manifests# docker tag willdockerhub/prometheus-adapter:v0.9.0 192.168.13.197:8000/baseimages/prometheus-adapter:v0.9.0
root@k8s-master01:~/k8s/yaml/kube-prometheus/manifests# docker push 192.168.13.197:8000/baseimages/prometheus-adapter:v0.9.0
root@k8s-master01:~/k8s/yaml/kube-prometheus/manifests# vim ./kube-state-metrics-deployment.yaml		#更改配置文件更换镜像地址为本地镜像地址
root@k8s-master01:~/k8s/yaml/kube-prometheus/manifests# vim ./prometheus-adapter-deployment.yaml		#更改配置文件更换镜像地址为本地镜像地址
root@k8s-master01:~/k8s/yaml/kube-prometheus/manifests# kubectl apply -f .		#应用
#kube-operator跟metrics-server有configmap冲突，删除kube-prometheus后需要重新应用metrics-server


###black_exporter模板——9719
###alertmanager抑制
inhibit_rules: #抑制的规则
  - source_match: #源匹配级别，当匹配成功发出通知，但是其他的通知将被抑制
      everity: 'critical' #严重级别
	target_match:
	  severity: 'warning' #警告级别
	equal: ['alertname', 'dev', 'instance']
###prometheus远程写入VictoriaMetrics，甚至可以替代prometheus


#k8s手动部署prometheus
---------------k8s以daemonset方式部署node-exporter,cadvisor
root@k8s-master01:~/k8s/yaml/prometheus-case# kubectl taint node 172.168.2.21 172.168.2.22 172.168.2.23 node-role.kubernetes.io/master:NoSchedule
root@k8s-master01:~/k8s/yaml/prometheus-case# kubectl describe node 172.168.2.21 172.168.2.22 172.168.2.23 | grep -A 5 Taints
Taints:             node-role.kubernetes.io/master:NoSchedule
                    node.kubernetes.io/unschedulable:NoSchedule
Unschedulable:      true
Lease:
  HolderIdentity:  172.168.2.21
  AcquireTime:     <unset>
--
Taints:             node-role.kubernetes.io/master:NoSchedule
                    node.kubernetes.io/unschedulable:NoSchedule
Unschedulable:      true
Lease:
  HolderIdentity:  172.168.2.22
  AcquireTime:     <unset>
--
Taints:             node-role.kubernetes.io/master:NoSchedule
                    node.kubernetes.io/unschedulable:NoSchedule
Unschedulable:      true
Lease:
  HolderIdentity:  172.168.2.23
  AcquireTime:     <unset>
---
root@k8s-master01:~/k8s/yaml/prometheus-case# cat case1-daemonset-deploy-cadvisor.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: cadvisor
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: cAdvisor
  template:
    metadata:
      labels:
        app: cAdvisor
    spec:
      tolerations:    #污点容忍,忽略master的NoSchedule
      - effect: ""
        key: node-role.kubernetes.io/master
        operator: "Exists"
      hostNetwork: true
      restartPolicy: Always   # 重启策略
      containers:
      - name: cadvisor
        image: 192.168.13.197:8000/baseimages/prometheus/cadvisor:v0.39.2
        imagePullPolicy: IfNotPresent  # 镜像策略
        ports:
        - containerPort: 8080
        volumeMounts:
          - name: root
            mountPath: /rootfs
          - name: run
            mountPath: /var/run
          - name: sys
            mountPath: /sys
          - name: docker
            mountPath: /var/lib/docker
      volumes:
      - name: root
        hostPath:
          path: /
      - name: run
        hostPath:
          path: /var/run
      - name: sys
        hostPath:
          path: /sys
      - name: docker
        hostPath:
          path: /var/lib/docker
root@k8s-master01:~/k8s/yaml/prometheus-case# kubectl apply -f case1-daemonset-deploy-cadvisor.yaml
root@k8s-master01:~/k8s/yaml/prometheus-case# cat case2-daemonset-deploy-node-exporter-new.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: monitoring
  labels:
    k8s-app: node-exporter
spec:
  selector:
    matchLabels:
        k8s-app: node-exporter
  template:
    metadata:
      labels:
        k8s-app: node-exporter
    spec:
      tolerations:
        - effect: NoSchedule
          key: node-role.kubernetes.io/master
      containers:
      - image: prom/node-exporter:v1.3.1
        imagePullPolicy: IfNotPresent
        name: prometheus-node-exporter
        ports:
        - containerPort: 9100
          hostPort: 9100
          protocol: TCP
          name: metrics
        volumeMounts:
        - mountPath: /host/proc
          name: proc
        - mountPath: /host/sys
          name: sys
        - mountPath: /host
          name: rootfs
        args:
        - --path.procfs=/host/proc
        - --path.sysfs=/host/sys
        - --path.rootfs=/host
      volumes:
        - name: proc
          hostPath:
            path: /proc
        - name: sys
          hostPath:
            path: /sys
        - name: rootfs
          hostPath:
            path: /
      hostNetwork: true
      hostPID: true
root@k8s-master01:~/k8s/yaml/prometheus-case# kubectl apply -f case2-daemonset-deploy-node-exporter-new.yaml
root@k8s-master01:~/k8s/yaml/prometheus-case# kubectl get pods -A
NAMESPACE              NAME                                         READY   STATUS      RESTARTS   AGE
ingress-nginx          ingress-nginx-admission-create-krlqb         0/1     Completed   0          9d
ingress-nginx          ingress-nginx-admission-patch-xpxp8          0/1     Completed   0          9d
ingress-nginx          ingress-nginx-controller-645b99897d-6rm9l    1/1     Running     12         9d
kube-system            calico-kube-controllers-647f956d86-m5ds9     1/1     Running     4          24d
kube-system            calico-node-fl565                            1/1     Running     41         29d
kube-system            calico-node-ldrjs                            1/1     Running     49         29d
kube-system            calico-node-qnvt9                            1/1     Running     56         29d
kube-system            calico-node-t9rh6                            1/1     Running     39         29d
kube-system            calico-node-vbvts                            1/1     Running     37         29d
kube-system            calico-node-x9tjb                            1/1     Running     46         29d
kube-system            calico-node-zknjn                            1/1     Running     1          14d
kube-system            coredns-5fc7c5b494-nj8zj                     1/1     Running     4          24d
kube-system            metrics-server-6557798c77-qv29m              1/1     Running     3          5h24m
kubernetes-dashboard   dashboard-metrics-scraper-67d4cf4b45-q9568   1/1     Running     2          24d
kubernetes-dashboard   kubernetes-dashboard-7df675bc5f-8phww        1/1     Running     20         12d
monitoring             cadvisor-8qkft                               1/1     Running     0          7m22s
monitoring             cadvisor-ct6px                               1/1     Running     0          6m51s
monitoring             cadvisor-jd7xc                               1/1     Running     0          7m27s
monitoring             cadvisor-m5st9                               1/1     Running     0          7m5s
monitoring             cadvisor-npdj6                               1/1     Running     0          7m10s
monitoring             cadvisor-q4555                               1/1     Running     0          6m41s
monitoring             cadvisor-zplt5                               1/1     Running     0          7m13s
monitoring             node-exporter-4pkrr                          1/1     Running     0          72s
monitoring             node-exporter-5xvvv                          1/1     Running     0          72s
monitoring             node-exporter-f77fj                          1/1     Running     0          72s
monitoring             node-exporter-pl2lt                          1/1     Running     0          72s
monitoring             node-exporter-r7f9z                          1/1     Running     0          72s
monitoring             node-exporter-t64p8                          1/1     Running     0          72s
monitoring             node-exporter-zq6wk                          1/1     Running     0          72s

--------------在k8s中部署prometheus-server
----新建prometheus configmap
root@k8s-master01:~/k8s/yaml/prometheus-case# cat case3-1-prometheus-cfg.yaml
---
kind: ConfigMap
apiVersion: v1
metadata:
  labels:
    app: prometheus
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      scrape_timeout: 10s
      evaluation_interval: 1m
    scrape_configs:
    - job_name: 'kubernetes-node'
      kubernetes_sd_configs:
      - role: node
      relabel_configs:
      - source_labels: [__address__]
        regex: '(.*):10250'
        replacement: '${1}:9100'
        target_label: __address__
        action: replace
      - action: labelmap
        regex: __meta_kubernetes_node_label_(.+)
    - job_name: 'kubernetes-node-cadvisor'
      kubernetes_sd_configs:
      - role:  node
      scheme: https
      tls_config:
        ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
      relabel_configs:
      - action: labelmap
        regex: __meta_kubernetes_node_label_(.+)
      - target_label: __address__
        replacement: kubernetes.default.svc:443
      - source_labels: [__meta_kubernetes_node_name]
        regex: (.+)
        target_label: __metrics_path__
        replacement: /api/v1/nodes/${1}/proxy/metrics/cadvisor
    - job_name: 'kubernetes-apiserver'
      kubernetes_sd_configs:
      - role: endpoints
      scheme: https
      tls_config:
        ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
      relabel_configs:
      - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
        action: keep
        regex: default;kubernetes;https
    - job_name: 'kubernetes-service-endpoints'
      kubernetes_sd_configs:
      - role: endpoints
      relabel_configs:
      - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scheme]
        action: replace
        target_label: __scheme__
        regex: (https?)
      - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
      - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
        action: replace
        target_label: __address__
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
      - action: labelmap
        regex: __meta_kubernetes_service_label_(.+)
      - source_labels: [__meta_kubernetes_namespace]
        action: replace
        target_label: kubernetes_namespace
      - source_labels: [__meta_kubernetes_service_name]
        action: replace
        target_label: kubernetes_name
root@k8s-master01:~/k8s/yaml/prometheus-case# kubectl apply -f case3-1-prometheus-cfg.yaml

----配置serviceaccount
root@k8s-master01:~/k8s/yaml/prometheus-case# cat case3-1-prometheus-serviceaccount.yml
apiVersion: v1
kind: ServiceAccount
metadata:
  namespace: monitoring
  name: monitor
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: monitor-clusterrolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- namespace: monitoring
  kind: ServiceAccount
  name: monitor
root@k8s-master01:~/k8s/yaml/prometheus-case# kubectl apply -f case3-1-prometheus-serviceaccount.yml

----配置prometheus-server
root@k8s-master01:~/k8s/yaml/prometheus-case# cat case3-2-prometheus-deployment.yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus-server
  namespace: monitoring
  labels:
    app: prometheus
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
      component: server
    #matchExpressions:
    #- {key: app, operator: In, values: [prometheus]}
    #- {key: component, operator: In, values: [server]}
  template:
    metadata:
      labels:
        app: prometheus
        component: server
      annotations:
        prometheus.io/scrape: 'false'
    spec:
      nodeName: 192.168.13.63
      serviceAccountName: monitor
      containers:
      - name: prometheus
        image: 192.168.13.197:8000/baseimages/prometheus/prometheus:v2.31.2
        imagePullPolicy: IfNotPresent
        command:
          - prometheus
          - --config.file=/etc/prometheus/prometheus.yml
          - --storage.tsdb.path=/prometheus
          - --storage.tsdb.retention=720h
        ports:
        - containerPort: 9090
          protocol: TCP
        volumeMounts:
        - mountPath: /etc/prometheus/prometheus.yml
          name: prometheus-config
          subPath: prometheus.yml
        - mountPath: /prometheus/
          name: prometheus-storage-volume
      volumes:
        - name: prometheus-config
          configMap:
            name: prometheus-config
            items:
              - key: prometheus.yml
                path: prometheus.yml
                mode: 0644
        - name: prometheus-storage-volume
          hostPath:
           path: /data/prometheusdata
           type: Directory
---
[root@k8s-node04 ~]# mkdir -p /data/prometheusdata
[root@k8s-node04 ~]# chmod -R 777 /data/prometheusdata
root@k8s-master01:~/k8s/yaml/prometheus-case# kubectl apply -f case3-2-prometheus-deployment.yaml
root@k8s-master01:~/k8s/yaml/prometheus-case# kubectl get pods -n monitoring
NAME                                 READY   STATUS    RESTARTS   AGE
cadvisor-8qkft                       1/1     Running   0          43m
cadvisor-ct6px                       1/1     Running   0          42m
cadvisor-jd7xc                       1/1     Running   0          43m
cadvisor-m5st9                       1/1     Running   0          42m
cadvisor-npdj6                       1/1     Running   0          42m
cadvisor-q4555                       1/1     Running   0          42m
cadvisor-zplt5                       1/1     Running   0          42m
node-exporter-4pkrr                  1/1     Running   0          36m
node-exporter-5xvvv                  1/1     Running   0          36m
node-exporter-f77fj                  1/1     Running   0          36m
node-exporter-pl2lt                  1/1     Running   0          36m
node-exporter-r7f9z                  1/1     Running   0          36m
node-exporter-t64p8                  1/1     Running   0          36m
node-exporter-zq6wk                  1/1     Running   0          36m
prometheus-server-7989d5f6c4-nlbln   1/1     Running   0          36s

-----创建service
root@k8s-master01:~/k8s/yaml/prometheus-case# cat case3-3-prometheus-svc.yaml
---
apiVersion: v1
kind: Service
metadata:
  name: prometheus
  namespace: monitoring
  labels:
    app: prometheus
spec:
  type: NodePort
  ports:
    - port: 9090
      targetPort: 9090
      nodePort: 30090
      protocol: TCP
  selector:
    app: prometheus
    component: server
---
root@k8s-master01:~/k8s/yaml/prometheus-case# kubectl apply -f case3-3-prometheus-svc.yaml
root@k8s-master01:~/k8s/yaml/prometheus-case# kubectl get svc -n monitoring
NAME         TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
prometheus   NodePort   10.68.252.108   <none>        9090:30090/TCP   19s

----web访问prometheus-server: http://192.168.13.63:30090/targets

----k8s默认情况下会在每个名称空间下生成ca公钥证书(可通过configmap查看)、默认token(可通过secret查看)，ca公钥证书默认会挂载到所有pod里面(/ /var/run/secrets/kubernetes.io/serviceaccount/ca.crt)，默认token会根据用户创建pod时是否指定serviceaccount，如若无指定则使用默认的secret进行挂载，如若指定则使用用户指定的serviceaccount挂载
root@k8s-master01:~# kubectl get configmap -A | grep kube-root
default                kube-root-ca.crt                     1      31d
ingress-nginx          kube-root-ca.crt                     1      9d
kube-node-lease        kube-root-ca.crt                     1      31d
kube-public            kube-root-ca.crt                     1      31d
kube-system            kube-root-ca.crt                     1      31d
kubernetes-dashboard   kube-root-ca.crt                     1      30d
monitoring             kube-root-ca.crt                     1      18h
root@k8s-master01:~# kubectl get secret -A | grep default
default                default-token-qghvn                              kubernetes.io/service-account-token   3      31d
ingress-nginx          default-token-jxvtb                              kubernetes.io/service-account-token   3      9d
kube-node-lease        default-token-h8pdm                              kubernetes.io/service-account-token   3      31d
kube-public            default-token-9v2gl                              kubernetes.io/service-account-token   3      31d
kube-system            default-token-fxm9x                              kubernetes.io/service-account-token   3      31d
kubernetes-dashboard   default-token-sc55p                              kubernetes.io/service-account-token   3      30d
monitoring             default-token-mqj24                              kubernetes.io/service-account-token   3      18h

root@k8s-master01:~# kubectl get configmap prometheus-config -n monitoring
NAME                DATA   AGE
prometheus-config   1      18h
root@k8s-master01:~# kubectl describe configmap prometheus-config -n monitoring
Name:         prometheus-config
Namespace:    monitoring
Labels:       app=prometheus
Annotations:  <none>

Data
====
prometheus.yml:
----
global:
  scrape_interval: 15s
  scrape_timeout: 10s
  evaluation_interval: 1m
scrape_configs:
- job_name: 'kubernetes-node'
  kubernetes_sd_configs:
  - role: node								
  relabel_configs:
  - source_labels: [__address__]
    regex: '(.*):10250'
    replacement: '${1}:9100'
    target_label: __address__
    action: replace
  - action: labelmap
    regex: __meta_kubernetes_node_label_(.+)
- job_name: 'kubernetes-node-cadvisor'
  kubernetes_sd_configs:
  - role:  node					#kubernetes服务发现
  scheme: https		#如果是https，则需要指定证书
  tls_config:
    ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt		#访问https时验证证书的CA文件地址，因为是kubernetes_sd发现，所以需要kubernetes的CA证书
  bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token	#访问kubernetes的token，会有相应的权限，如若token权限受限，将不会成功发现kuberentes的资源
  relabel_configs:
  - action: labelmap
    regex: __meta_kubernetes_node_label_(.+)
  - target_label: __address__
    replacement: kubernetes.default.svc:443
  - source_labels: [__meta_kubernetes_node_name]
    regex: (.+)
    target_label: __metrics_path__
    replacement: /api/v1/nodes/${1}/proxy/metrics/cadvisor
- job_name: 'kubernetes-apiserver'
  kubernetes_sd_configs:
  - role: endpoints
  scheme: https
  tls_config:
    ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
  bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
  relabel_configs:
  - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
    action: keep
    regex: default;kubernetes;https
- job_name: 'kubernetes-service-endpoints'
  kubernetes_sd_configs:
  - role: endpoints
  relabel_configs:
  - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
    action: keep
    regex: true
  - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scheme]
    action: replace
    target_label: __scheme__
    regex: (https?)
  - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
    action: replace
    target_label: __metrics_path__
    regex: (.+)
  - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
    action: replace
    target_label: __address__
    regex: ([^:]+)(?::\d+)?;(\d+)
    replacement: $1:$2
  - action: labelmap
    regex: __meta_kubernetes_service_label_(.+)
  - source_labels: [__meta_kubernetes_namespace]
    action: replace
    target_label: kubernetes_namespace
  - source_labels: [__meta_kubernetes_service_name]
    action: replace
    target_label: kubernetes_name


#-----安装consul集群 
-----------------------------------------------
----自动加入集群方式部署consul集群
--配置consul agent server
--创建目录
root@ansible:~# ansible prometheus -m shell -a 'mkdir -p /etc/consul.d /data/consul'
--配置consul agent server配置文件
cat <<EOF > /etc/consul.d/consul.json
{
  "datacenter": "prometheus",
  "bind_addr": "172.168.2.27",
  "client_addr": "0.0.0.0",
  "data_dir": "/data/consul",
  "log_level": "INFO",
  "server": true,
  "ui": true,
  "bootstrap_expect": 3,
  "retry_join": ["172.168.2.27","172.168.2.28","172.168.2.29"],
  "rejoin_after_leave": true,
  "advertise_addr_wan": "172.168.2.27"
}
EOF

--配置consul agent server配置文件
cat <<EOF > /etc/consul.d/consul.json
{
  "datacenter": "prometheus",
  "bind_addr": "172.168.2.28",
  "client_addr": "0.0.0.0",
  "data_dir": "/data/consul",
  "log_level": "INFO",
  "server": true,
  "ui": true,
  "bootstrap_expect": 3,
  "retry_join": ["172.168.2.27","172.168.2.28","172.168.2.29"],
  "rejoin_after_leave": true,
  "advertise_addr_wan": "172.168.2.28"
}
EOF

--配置consul agent server配置文件
cat <<EOF > /etc/consul.d/consul.json
{
  "datacenter": "prometheus",
  "bind_addr": "172.168.2.29",
  "client_addr": "0.0.0.0",
  "data_dir": "/data/consul",
  "log_level": "INFO",
  "server": true,
  "ui": true,
  "bootstrap_expect": 3,
  "retry_join": ["172.168.2.27","172.168.2.28","172.168.2.29"],
  "rejoin_after_leave": true,
  "advertise_addr_wan": "172.168.2.29"
}
EOF

--测试服务是否可以启动
consul agent -config-dir=/etc/consul.d

--添加consul agent server服务启动文件，3台consul agent server都是一样
cat <<EOF > /etc/systemd/system/consul.service
[Unit]
Description=consul agent
Requires=network-online.target
After=network-online.target

[Service]
User=root
ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d/
ExecReload=/usr/local/bin/consul reload
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

--配置开机自动动并启动服务
root@prometheus01:/apps# systemctl daemon-reload
root@prometheus01:/apps# systemctl start consul.service
root@prometheus01:/apps# systemctl status consul.service


--consul agent client
--添加consul agent client启动配置文件
mkdir -p /etc/consul.d /data/consul
cat <<EOF > /etc/consul.d/consul.json
{
  "datacenter": "prometheus",
  "bind_addr": "172.168.2.11",
  "client_addr": "172.168.2.11",
  "data_dir": "/data/consul",
  "log_level": "INFO",
  "server": false,
  "retry_join": ["172.168.2.27","172.168.2.28","172.168.2.29"]
}
EOF

--添加consul agent client服务启动文件
cat <<EOF > /etc/systemd/system/consul.service
[Unit]
Description=consul agent
Requires=network-online.target
After=network-online.target

[Service]
User=root
ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d/
ExecReload=/usr/local/bin/consul reload
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

--启动consul agent client
systemctl daemon-reload && systemctl start consul.service && systemctl status consul.service

--命令
--查看consul agent成员，包括server和client
root@prometheus01:/apps# consul members
Node          Address            Status  Type    Build   Protocol  DC          Partition  Segment
prometheus01  172.168.2.27:8301  alive   server  1.11.4  2         prometheus  default    <all>
prometheus02  172.168.2.28:8301  alive   server  1.11.4  2         prometheus  default    <all>
prometheus03  172.168.2.29:8301  alive   server  1.11.4  2         prometheus  default    <all>
ansible       172.168.2.11:8301  alive   client  1.11.4  2         prometheus  default    <default>
--列出raft协议的成功以及角色，就是查看server的角色 
root@prometheus01:/apps#  consul operator raft list-peers
Node          ID                                    Address            State     Voter  RaftProtocol
prometheus03  6ea130e8-f32e-fcb9-7f44-f6a2dff08a86  172.168.2.29:8300  follower  true   3
prometheus02  92376e65-258d-fff8-24b0-a7a7d6f6e66d  172.168.2.28:8300  leader    true   3
prometheus01  f72ec6ca-69a7-03ae-52f3-3880dbb1edc7  172.168.2.27:8300  follower  true   3
--测试停止consul agent server
root@prometheus02:/apps# systemctl stop consul
root@prometheus01:/apps# consul members
Node          Address            Status  Type    Build   Protocol  DC          Partition  Segment
prometheus01  172.168.2.27:8301  alive   server  1.11.4  2         prometheus  default    <all>
prometheus02  172.168.2.28:8301  left    server  1.11.4  2         prometheus  default    <all>
prometheus03  172.168.2.29:8301  alive   server  1.11.4  2         prometheus  default    <all>
ansible       172.168.2.11:8301  alive   client  1.11.4  2         prometheus  default    <default>
root@prometheus01:/apps# consul operator raft list-peers
Node          ID                                    Address            State     Voter  RaftProtocol
prometheus03  6ea130e8-f32e-fcb9-7f44-f6a2dff08a86  172.168.2.29:8300  follower  true   3
prometheus01  f72ec6ca-69a7-03ae-52f3-3880dbb1edc7  172.168.2.27:8300  leader    true   3

--端口监听状态
root@prometheus01:/usr/local/prometheus# ss -tunl  | grep :8
udp    UNCONN   0        0            172.168.2.27:8301          0.0.0.0:*
udp    UNCONN   0        0            172.168.2.27:8302          0.0.0.0:*
udp    UNCONN   0        0                       *:8600                *:*
tcp    LISTEN   0        128          172.168.2.27:8300          0.0.0.0:*
tcp    LISTEN   0        128          172.168.2.27:8301          0.0.0.0:*
tcp    LISTEN   0        128          172.168.2.27:8302          0.0.0.0:*
tcp    LISTEN   0        128                     *:8500                *:*
tcp    LISTEN   0        128                     *:8600                *:*
root@prometheus02:/apps# ss -tunl  | grep :8
udp    UNCONN   0        0            172.168.2.28:8301          0.0.0.0:*
udp    UNCONN   0        0            172.168.2.28:8302          0.0.0.0:*
udp    UNCONN   0        0                       *:8600                *:*
tcp    LISTEN   0        128          172.168.2.28:8300          0.0.0.0:*
tcp    LISTEN   0        128          172.168.2.28:8301          0.0.0.0:*
tcp    LISTEN   0        128          172.168.2.28:8302          0.0.0.0:*
tcp    LISTEN   0        128                     *:8500                *:*
tcp    LISTEN   0        128                     *:8600                *:*
root@prometheus03:/apps# ss -tunl  | grep :8
udp    UNCONN   0        0            172.168.2.29:8301          0.0.0.0:*
udp    UNCONN   0        0            172.168.2.29:8302          0.0.0.0:*
udp    UNCONN   0        0                       *:8600                *:*
tcp    LISTEN   0        128          172.168.2.29:8300          0.0.0.0:*
tcp    LISTEN   0        128          172.168.2.29:8301          0.0.0.0:*
tcp    LISTEN   0        128          172.168.2.29:8302          0.0.0.0:*
tcp    LISTEN   0        128                     *:8500                *:*
tcp    LISTEN   0        128                     *:8600                *:*
-----------------------------------------------


--prometheus配置consul自动发现
root@prometheus01:/usr/local/prometheus# cat prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets:
rule_files:
scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: 'consul-node_exporter'
    metrics_path: /metrics
    scrape_interval: 15s
    consul_sd_configs:				#consul服务发现
    - server: '172.168.2.27:8500'
      services: []
    - server: '172.168.2.28:8500'
      services: []
    - server: '172.168.2.29:8500'
      services: []
    relabel_configs:
      - source_labels: [__meta_consul_service]
        regex: node.*
        action: keep
      - regex: __meta_consul_service_metadata_(.+)
        action: labelmap
----------

---#文件服务发现

---#DNS服务发现
172.168.2.21	master01.k8s.hs.com
172.168.2.22	master02.k8s.hs.com
172.168.2.23	master03.k8s.hs.com
172.168.2.24	node01.k8s.hs.com
172.168.2.25	node02.k8s.hs.com

> set type=srv
> _k8s._tcp.k8s.hs.com
服务器:  homsom-dc01.hs.com
Address:  192.168.10.250
_k8s._tcp.k8s.hs.com    SRV service location:
          priority       = 10
          weight         = 10
          port           = 9100
          svr hostname   = 192.168.13.63
root@prometheus01:/usr/local/prometheus# cat prometheus.yml
  - job_name: 'dns-node_exporter'
    metrics_path: /metrics
    dns_sd_configs:
    - names: ["master01.k8s.hs.com","master02.k8s.hs.com","master03.k8s.hs.com","node01.k8s.hs.com","node02.k8s.hs.com"]
      type: A
      port: 9100
      refresh_interval: 10s
    - names: ["_k8s._tcp.k8s.hs.com"]
      type: SRV
      refresh_interval: 10s
root@prometheus01:/usr/local/prometheus# systemcel restart prometheus
--ubuntu下使用systemd-resolve需要刷新缓存
root@prometheus01:/usr/local/prometheus# systemd-resolve --flush-caches
--去prometheusUI验证是否成功

#-------kube-state-metrics组件
URL: https://github.com/kubernetes/kube-state-metrics
Kube-state-metrics:通过监听 API Server 生成有关资源对象的状态指标，比如 Deployment、Node、Pod，需要注意的是 kube-state-metrics 只是简单的提供一个 metrics 数据，并不会存储这些指标数据，所以我们 可 以 使 用 Prometheus 来 抓 取 这 些 数 据 然 后 存 储 ， 主 要 关 注 的 是 业 务 相 关 的 一 些 元 数 据 ， 比 如Deployment 、 Pod 、 副 本 状 态 等 ； 调 度 了 多 少 个 replicas ？ 现 在 可 用 的 有 几 个 ？ ； 多 少 个 Pod 是running/stopped/terminated 状态？；Pod 重启了多少次？；我有多少 job 在运行中。

1. 使用rolebinding去绑定role和user,此时user有了名称空间级别的role权限
2. 使用clusterrolebinding去绑定clusterrole和user，此时user有了集群级别的clusterrole权限
3. 使用rolebinding绑定clusterrole和user，此时user有了名称空间的clusterrole权限，也就是user有了自己所在名称空间的所有关于clusterrole角色当中的权限
--部署kube-state-metrics 2.2.4，跟kubernetes版本有要求
root@k8s-master01:~/k8s/yaml/prometheus-case# cat case5-kube-state-metrics-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kube-state-metrics
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kube-state-metrics
  template:
    metadata:
      labels:
        app: kube-state-metrics
    spec:
      serviceAccountName: kube-state-metrics
      containers:
      - name: kube-state-metrics
        image: bitnami/kube-state-metrics:2.2.4
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kube-state-metrics
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kube-state-metrics
rules:
- apiGroups: [""]
  resources: ["nodes", "pods", "services", "resourcequotas", "replicationcontrollers", "limitranges", "persistentvolumeclaims", "persistentvolumes", "namespaces", "endpoints"]
  verbs: ["list", "watch"]
- apiGroups: ["extensions"]
  resources: ["daemonsets", "deployments", "replicasets"]
  verbs: ["list", "watch"]
- apiGroups: ["apps"]
  resources: ["statefulsets"]
  verbs: ["list", "watch"]
- apiGroups: ["batch"]
  resources: ["cronjobs", "jobs"]
  verbs: ["list", "watch"]
- apiGroups: ["autoscaling"]
  resources: ["horizontalpodautoscalers"]
  verbs: ["list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kube-state-metrics
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kube-state-metrics
subjects:
- kind: ServiceAccount
  name: kube-state-metrics
  namespace: kube-system
---
apiVersion: v1
kind: Service
metadata:
  annotations:
    prometheus.io/scrape: 'true'
  name: kube-state-metrics
  namespace: kube-system
  labels:
    app: kube-state-metrics
spec:
  type: NodePort
  ports:
  - name: kube-state-metrics
    port: 8080
    targetPort: 8080
    nodePort: 31666
    protocol: TCP
  selector:
    app: kube-state-metrics
---
root@k8s-master01:~/k8s/yaml/prometheus-case# kubectl apply -f case5-kube-state-metrics-deploy.yaml
root@k8s-master01:~/k8s/yaml/prometheus-case# kubectl get svc/kube-state-metrics -n kube-system
NAME                 TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
kube-state-metrics   NodePort   10.68.16.146   <none>        8080:31666/TCP   87s
root@k8s-master01:~/k8s/yaml/prometheus-case# kubectl get pod -n kube-system | grep kube-state-metrics
kube-state-metrics-6f7b48c7bc-lf7mv        1/1     Running   0          110s
curl http://172.168.2.21:31666/healthz	#这个url是监控apiservre的健康状态的
curl http://172.168.2.21:31666/metrics	#所有deploy,pod,node的状态

--配置prometheus-server
  - job_name: 'kube-state-metrics'
    static_configs:
    - targets: ["172.168.2.21:31666"]
root@prometheus01:/usr/local/prometheus# systemctl restart prometheus.service

--安装grafana
sudo apt-get install -y adduser libfontconfig1
wget https://dl.grafana.com/enterprise/release/grafana-enterprise_8.4.5_amd64.deb
sudo dpkg -i grafana-enterprise_8.4.5_amd64.deb
root@prometheus01:/usr/local/src# systemctl start grafana-server.service
root@prometheus01:/usr/local/src# systemctl enable grafana-server.service
WEB访问：http://172.168.2.27:3000
--grafana模板
13332/13824-kube-state-metrics 



#--监控扩展
#----监控tomcat
root@k8s-master01:~/k8s/yaml/prometheus-case/app-monitor-case/tomcat/tomcat-image# cat Dockerfile
#FROM tomcat:8.5.73-jdk11-corretto
FROM tomcat:8.5.73

ADD server.xml /usr/local/tomcat/conf/server.xml	#tomcat配置文件，指定了站点目录/data/tomcat/webapps
RUN mkdir /data/tomcat/webapps -p
ADD myapp /data/tomcat/webapps/myapp
ADD metrics.war /data/tomcat/webapps		#metrics.war包放到站点目录，会暴露/metrics URL，主要看内存异常，session信息
ADD simpleclient-0.8.0.jar  /usr/local/tomcat/lib/		#下面的所有jar包放到tomcat lib目录或者java的lib目录，metrics.war运行的时候需要加载，这些jar可以去gitlab上查找
ADD simpleclient_common-0.8.0.jar /usr/local/tomcat/lib/
ADD simpleclient_hotspot-0.8.0.jar /usr/local/tomcat/lib/
ADD simpleclient_servlet-0.8.0.jar /usr/local/tomcat/lib/
ADD tomcat_exporter_client-0.0.12.jar /usr/local/tomcat/lib/
EXPOSE 8080 8443 8009
---
root@k8s-master01:~/k8s/yaml/prometheus-case/app-monitor-case/tomcat/tomcat-image# cat run_tomcat.sh
#!/bin/bash
echo "1.1.1.1 www.a.com" >> /etc/hosts
su - magedu -c "/apps/tomcat/bin/catalina.sh start"
tail -f /etc/hosts
---
root@k8s-master01:~/k8s/yaml/prometheus-case/app-monitor-case/tomcat/tomcat-image# cat build-command.sh
#!/bin/bash
docker build -t 192.168.13.197:8000/magedu/tomcat-app1:v1 .
docker push 192.168.13.197:8000/magedu/tomcat-app1:v1
---
root@k8s-master01:~/k8s/yaml/prometheus-case/app-monitor-case/tomcat/tomcat-image# ./build-command.sh		#构建镜像

--在k8s运行tomcat
root@k8s-master01:~/k8s/yaml/prometheus-case/app-monitor-case/tomcat/yaml# cat tomcat-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tomcat-deployment
  namespace: default
spec:
  selector:
    matchLabels:
     app: tomcat
  replicas: 1 # tells deployment to run 2 pods matching the template
  template: # create pods using pod definition in this template
    metadata:
      labels:
        app: tomcat
      annotations:
        prometheus.io/scrape: 'true'
    spec:
      containers:
      - name: tomcat
        image: 192.168.13.197:8000/magedu/tomcat-app1:v1
        ports:
        - containerPort: 8080
        securityContext:
          privileged: true
root@k8s-master01:~/k8s/yaml/prometheus-case/app-monitor-case/tomcat/yaml# cat tomcat-svc.yaml
kind: Service  #service 类型
apiVersion: v1
metadata:
#  annotations:
#    prometheus.io/scrape: 'true'
  name: tomcat-service
spec:
  selector:
    app: tomcat
  ports:
  - nodePort: 31080
    port: 80
    protocol: TCP
    targetPort: 8080
  type: NodePort
---
root@k8s-master01:~/k8s/yaml/prometheus-case/app-monitor-case/tomcat/yaml# kubectl apply -f .

--配置prometheus增加tomcat的监控
root@prometheus01:/usr/local/prometheus# cat prometheus.yml
  - job_name: 'kubernetes-tomcat-metrics'
    static_configs:
    - targets: ["172.168.2.21:31080"]
root@prometheus01:/usr/local/prometheus# systemctl restart prometheus
导入tomcat-模板



----k8s部署redis和reddis_exporter
root@k8s-master01:~/k8s/yaml/prometheus-case/app-monitor-case/redis/yaml# cat redis-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  namespace: studylinux-net
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:4.0.14
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
        ports:
        - containerPort: 6379
      - name: redis-exporter
        image: oliver006/redis_exporter:latest
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
        ports:
        - containerPort: 9121
root@k8s-master01:~/k8s/yaml/prometheus-case/app-monitor-case/redis/yaml# cat redis-redis-svc.yaml
kind: Service  #service 类型
apiVersion: v1
metadata:
#  annotations:
#    prometheus.io/scrape: 'false'
  name: redis-redis-service
  namespace: studylinux-net
spec:
  selector:
    app: redis
  ports:
  - nodePort: 31081
    name: redis
    port: 6379
    protocol: TCP
    targetPort: 6379
  type: NodePort
root@k8s-master01:~/k8s/yaml/prometheus-case/app-monitor-case/redis/yaml# cat redis-exporter-svc.yaml
kind: Service  #service 类型
apiVersion: v1
metadata:
  annotations:
    prometheus.io/scrape: 'true'
    prometheus.io/port: "9121"
  name: redis-exporter-service
  namespace: studylinux-net
spec:
  selector:
    app: redis
  ports:
  - nodePort: 31082
    name: prom
    port: 9121
    protocol: TCP
    targetPort: 9121
  type: NodePort
---
--配置prometheus增加redis的监控
root@prometheus01:/usr/local/prometheus# cat prometheus.yml
  - job_name: 'kubernetes-redis-metrics'
    static_configs:
    - targets: ["172.168.2.21:31082"]
root@prometheus01:/usr/local/prometheus# systemctl restart prometheus
--redis模板14615



----#监控haproxy
--下载配置haproxy_exporter
https://github.com/prometheus/haproxy_exporter/releases/download/v0.13.0/haproxy_exporter-0.13.0.linux-amd64.tar.gz
--有两种方式配置haproxy_exporter监控haproxy
1. 通过socket	2. 通过haproxy状态页，haproxy_exporter再转换为prometheus能识别的格式

--安装配置haproxy，通过socket方式监控haproxy
root@ha:~# cat /etc/haproxy/haproxy.cfg
global
        log /dev/log    local0
        log /dev/log    local1 notice
        chroot /var/lib/haproxy
        #stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
        stats socket /run/lib/haproxy/haproxy.sock mode 660 level admin		#此行就是socket
        stats timeout 30s
        user haproxy
        group haproxy
        daemon
        ca-base /etc/ssl/certs
        crt-base /etc/ssl/private
        ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS
        ssl-default-bind-options no-sslv3
defaults
        log     global
        mode    http
        option  httplog
        #mode tcp
        option  dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
        errorfile 400 /etc/haproxy/errors/400.http
        errorfile 403 /etc/haproxy/errors/403.http
        errorfile 408 /etc/haproxy/errors/408.http
        errorfile 500 /etc/haproxy/errors/500.http
        errorfile 502 /etc/haproxy/errors/502.http
        errorfile 503 /etc/haproxy/errors/503.http
        errorfile 504 /etc/haproxy/errors/504.http

listen k8s-apiserver-6443
  bind 172.168.2.12:6443
  mode tcp
  server k8s-master01 172.168.2.21:6443 check inter 3s fall 3 rise 5
  server k8s-master02 172.168.2.22:6443 check inter 3s fall 3 rise 5
  server k8s-master03 172.168.2.23:6443 check inter 3s fall 3 rise 5

listen prometheus-server-80
  bind 172.168.2.12:80
  mode http
  server 172.168.2.27 172.168.2.27:9090 check inter 3s fall 3 rise 5
---
root@ha:~# systemctl restart haproxy


--方式1：启动haproxy_exporter
root@ha:/apps/haproxy_exporter-0.13.0.linux-amd64# ./haproxy_exporter --haproxy.scrape-uri=unix:/run/lib/haproxy/haproxy.sock

--方式2：启动haproxy_exporter
root@ha:/apps/haproxy_exporter-0.13.0.linux-amd64# cat /etc/haproxy/haproxy.cfg
listen stats
  bind :9009
  stats enable
  #stats hide-version
  stats uri /haproxy-status
  stats realm HAPorxy\ Stats\ Page
  stats auth haadmin:123456
  stats auth admin:123456
root@ha:/apps/haproxy_exporter-0.13.0.linux-amd64# systemctl restart haproxy
root@ha:/apps/haproxy_exporter-0.13.0.linux-amd64# ./haproxy_exporter --haproxy.scrape-uri="http://haadmin:123456@127.0.0.1:9009/haproxy-status;csv" &
root@ha:/apps/haproxy_exporter-0.13.0.linux-amd64# ss -tnl | grep 9009
LISTEN   0         128                 0.0.0.0:9009             0.0.0.0:*

--配置prometheus-server
root@prometheus01:/usr/local/prometheus# cat prometheus.yml
  - job_name: 'kubernetes-haproxy-server-metrics'
    static_configs:
    - targets: ["172.168.2.12:9101"]
root@prometheus01:/usr/local/prometheus# systemctl restart prometheus

--haproxy模板367/2428




----#监控nginx
要在编译安装 nginx 的时候添加 nginx-module-vts 模块，github 地址：https://github.com/vozlt/nginx-module-vts
[root@tengine /usr/local/nginx/sbin]# 
./configure --prefix=/usr/local/nginx --user=nginx --group=nginx --with-pcre=/download/pcre-8.44 --with-http_ssl_module --with-http_flv_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_sub_module --with-stream --add-module=modules/ngx_http_upstream_session_sticky_module --with-stream_ssl_module --add-module=modules/ngx_http_upstream_check_module --with-http_auth_request_module --with-http_gzip_static_module --with-http_random_index_module --add-module=/download/nginx-module-vts-0.1.17

[root@tengine /usr/local/nginx/sbin]# cat ../conf/nginx.conf
http {
    vhost_traffic_status_zone;
    vhost_traffic_status_filter_by_host on;

	server{
        listen 8089;
        #server_name 192.168.13.50;
		server_name 127.0.0.1
        location /status {
                vhost_traffic_status_display;
                vhost_traffic_status_display_format html;		#还可以是json和prometheus格式
        }
	}
}
--下载nginx-vts-exporter进行监控
[root@tengine /usr/local/nginx/sbin]# /usr/local/nginx-vts-exporter-0.10.3.linux-amd64/nginx-vts-exporter -nginx.scrape_timeout 10 -nginx.scrape_uri http://127.0.0.1:8089/status/format/json -telemetry.address 192.168.13.50:9913 -telemetry.endpoint /metrics



----#prometheus联绑集群
环境：
172.168.2.27	prometheus-server
172.168.2.28	prometheus-federate01
172.168.2.29	prometheus-federate02
172.168.2.21 172.168.2.22 172.168.2.23	node-exporter for prometheus-federate01
172.168.2.24 172.168.2.25 172.168.2.26	192.168.13.63	node-exporter for prometheus-federate02

--------安装
----prometheus-server
root@prometheus01:/usr/local/src# tar xf prometheus-2.33.4.linux-amd64.tar.gz -C /usr/local/
root@prometheus01:/usr/local/src# ln -sv /usr/local/prometheus-2.33.4.linux-amd64/ /usr/local/prometheus
root@prometheus01:/usr/local/src# groupadd -r prometheus
root@prometheus01:/usr/local/src# useradd  -r -g prometheus -s /sbin/nologin -M prometheus
root@prometheus01:/usr/local/src# mkdir -p /var/lib/prometheus
root@prometheus01:/usr/local/src# chown -R prometheus.prometheus /usr/local/prometheus-2.33.4.linux-amd64/ /var/lib/prometheus
root@prometheus01:/usr/local/src# cat >> /lib/systemd/system/prometheus.service << EOF
[Unit]
Description=https://prometheus.io
After=network-online.target
[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/prometheus/prometheus \
--config.file /usr/local/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--storage.tsdb.retention.time=90d \
--storage.tsdb.retention.size=100GB \
--storage.tsdb.wal-compression \
--web.external-url=http://172.169.2.27:9090 \
--web.enable-admin-api \
--web.enable-lifecycle \
--web.page-title=HomsomMonitor
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
------
root@prometheus01:/usr/local/src# systemctl daemon-reload
sroot@prometheus01:/usr/local/src# systemctl restart prometheus.service
root@prometheus01:/usr/local/src# systemctl status prometheus.service | grep Active
   Active: active (running) since Wed 2022-04-06 22:10:55 CST; 19s ago

----prometheus-federate01
root@prometheus02:/usr/local/src# tar xf prometheus-2.33.4.linux-amd64.tar.gz -C /usr/local/
root@prometheus02:/usr/local/src# ln -sv /usr/local/prometheus-2.33.4.linux-amd64/ /usr/local/prometheus
root@prometheus02:/usr/local/src# groupadd -r prometheus
root@prometheus02:/usr/local/src# useradd  -r -g prometheus -s /sbin/nologin -M prometheus
root@prometheus02:/usr/local/src# mkdir -p /var/lib/prometheus
root@prometheus02:/usr/local/src# chown -R prometheus.prometheus /usr/local/prometheus-2.33.4.linux-amd64/ /var/lib/prometheus
root@prometheus02:/usr/local/src# cat >> /lib/systemd/system/prometheus.service << EOF
[Unit]
Description=https://prometheus.io
After=network-online.target
[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/prometheus/prometheus \
--config.file /usr/local/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--storage.tsdb.retention.time=90d \
--storage.tsdb.retention.size=100GB \
--storage.tsdb.wal-compression \
--web.external-url=http://172.169.2.28:9090 \
--web.enable-admin-api \
--web.enable-lifecycle \
--web.page-title=HomsomMonitor
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
------
root@prometheus02:/usr/local/src# systemctl daemon-reload
sroot@prometheus02:/usr/local/src# systemctl restart prometheus.service
root@prometheus02:/usr/local/src# systemctl status prometheus.service | grep Active
   Active: active (running) since Wed 2022-04-06 22:16:55 CST; 19s ago


----prometheus-federate02
root@prometheus03:/usr/local/src# tar xf prometheus-2.33.4.linux-amd64.tar.gz -C /usr/local/
root@prometheus03:/usr/local/src# ln -sv /usr/local/prometheus-2.33.4.linux-amd64/ /usr/local/prometheus
root@prometheus03:/usr/local/src# groupadd -r prometheus
root@prometheus03:/usr/local/src# useradd  -r -g prometheus -s /sbin/nologin -M prometheus
root@prometheus03:/usr/local/src# mkdir -p /var/lib/prometheus
root@prometheus03:/usr/local/src# chown -R prometheus.prometheus /usr/local/prometheus-2.33.4.linux-amd64/ /var/lib/prometheus
root@prometheus03:/usr/local/src# cat >> /lib/systemd/system/prometheus.service << EOF
[Unit]
Description=https://prometheus.io
After=network-online.target
[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/prometheus/prometheus \
--config.file /usr/local/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--storage.tsdb.retention.time=90d \
--storage.tsdb.retention.size=100GB \
--storage.tsdb.wal-compression \
--web.external-url=http://172.169.2.29:9090 \
--web.enable-admin-api \
--web.enable-lifecycle \
--web.page-title=HomsomMonitor
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
root@prometheus03:/usr/local/src# systemctl daemon-reload
root@prometheus03:/usr/local/src# systemctl restart prometheus.service
root@prometheus03:/usr/local/src# systemctl status prometheus.service | grep Active
   Active: active (running) since Wed 2022-04-06 22:21:32 CST; 4s ago


-------配置
----prometheus-federate01
root@prometheus02:/usr/local/prometheus# cat prometheus.yml
global:
  scrape_interval: 15s 
  evaluation_interval: 15s 

alerting:
  alertmanagers:
    - static_configs:
        - targets:
rule_files:

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "kubernetes-master-metrics"
    file_sd_configs:
    - files:
      - /usr/local/prometheus/file_sd_configs/*.json
      refresh_interval: 10s
---
root@prometheus02:/usr/local/prometheus# mkdir -p /usr/local/prometheus/file_sd_configs
root@prometheus02:/usr/local/prometheus# cat /usr/local/prometheus/file_sd_configs/kubernetes-master.json
[
  {
    "targets": ["172.168.2.21:9100","172.168.2.22:9100"]
  }
]
root@prometheus02:/usr/local/prometheus# curl -X POST http://localhost:9090/-/reload

----prometheus-federate02
root@prometheus03:/usr/local/prometheus# cat prometheus.yml
global:
  scrape_interval: 15s 
  evaluation_interval: 15s 

alerting:
  alertmanagers:
    - static_configs:
        - targets:
rule_files:

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "kubernetes-node-metrics"
    file_sd_configs:
    - files:
      - /usr/local/prometheus/file_sd_configs/*.json
      refresh_interval: 10s
---
root@prometheus03:/usr/local/prometheus# mkdir -p /usr/local/prometheus/file_sd_configs
root@prometheus03:/usr/local/prometheus# cat /usr/local/prometheus/file_sd_configs/kubernetes-node.json
[
  {
    "targets": ["172.168.2.24:9100","172.168.2.25:9100"]
  }
]
root@prometheus03:/usr/local/prometheus# curl -X POST http://localhost:9090/-/reload

----prometheus-server
root@prometheus01:/usr/local/prometheus# cat prometheus.yml | head -n 40
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets:
rule_files:

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "prometheus-federate01-172.168.2.28"
    scrape_interval: 15s
    honor_labels: true
    metrics_path: '/federate'
    params:
      'match[]':
      - '{job="prometheus"}'			#这个是匹配job="prometheus"的，本机有所以不会覆盖本机，没有才会抓取
      - '{__name__=~"job:.*"}'			这个是匹配指标是job:开头的
      - '{__name__=~"node.*"}'			#这个是匹配指标是node开头的
    static_configs:
    - targets: ["172.168.2.28:9090"]

  - job_name: "prometheus-federate02-172.168.2.29"
    scrape_interval: 15s
    honor_labels: true
    metrics_path: '/federate'
    params:
      'match[]':
      - '{job="prometheus"}'
      - '{__name__=~"job:.*"}'
      - '{__name__=~"node.*"}'
    static_configs:
    - targets: ["172.168.2.29:9090"]
---
root@prometheus01:/usr/local/prometheus# curl -X POST http://localhost:9090/-/reload

----grafana导入模板11074(node-exporter for EN)/8919(node-exporter for CN)

----prometheus-federate01和prometheus-federate02增加主机，prometheus-server不用配置自动发现主机
root@prometheus02:/usr/local/prometheus/file_sd_configs# cat kubernetes-master.json
[
  {
    "targets": ["172.168.2.21:9100","172.168.2.22:9100","172.168.2.23:9100"]			#再增加一个master
  }
]
root@prometheus03:/usr/local/prometheus/file_sd_configs# cat kubernetes-node.json
[
  {
    "targets": ["172.168.2.24:9100","172.168.2.25:9100","172.168.2.26:9100","192.168.13.63:9100"]
  }
]
root@prometheus02:/usr/local/prometheus/file_sd_configs# curl -XPOST http://localhost:9090/-/reload  		 #此时联绑server(prometheus-server)最大等待10s+15s=25s时间就可以查看到增加的master节点



----#alertmanager
----#dingtalk告警
DownloadURL: https://github.com/timonwong/prometheus-webhook-dingtalk/releases/download/v1.4.0/prometheus-webhook-dingtalk-1.4.0.linux-amd64.tar.gz
１. 安装 
root@prometheus01:/usr/local/src# tar xf prometheus-webhook-dingtalk-1.4.0.linux-amd64.tar.gz -C /usr/local/
root@prometheus01:/usr/local# ln -sv prometheus-webhook-dingtalk-1.4.0.linux-amd64/ prometheus-webhook-dingtalk
root@prometheus01:/usr/local/prometheus-webhook-dingtalk# cat config.yml

2. 服务配置文件
--配置prometheus-webhook-dingtalk服务
./prometheus-webhook-dingtalk --web.listen-address="0.0.0.0:8060" --ding.profile="dingding=https://oapi.dingtalk.com/robot/send?access_token=8e182e1791d67431a8ff1a421b4e2de2dfcb34eb07d5ab3b522cfa10"
#注：profile=dingding，所以alertmanager调用的时候也需要写profile名称dingding，例如'http://172.168.2.27:8060/dingtalk/dingding/send'

----或者
targets:
  dingding:
    url: https://oapi.dingtalk.com/robot/send?access_token=8e182e1791d67431a8ff1a421b4e2de2dfcb34eb07d5ab3b521e0
---
# /lib/systemd/system/prometheus-webhook-dingtalk.service
[Unit]
Description=https://github.com/timonwong/prometheus-webhook-dingtalk
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/prometheus-webhook-dingtalk/prometheus-webhook-dingtalk \
--config.file /usr/local/prometheus-webhook-dingtalk/config.yml \
--web.enable-lifecycle \
--web.listen-address "0.0.0.0:8060"
Restart=on-failure

[Install]
WantedBy=multi-user.target
---

3. 启动服务
root@prometheus01:/usr/local/prometheus-webhook-dingtalk# systemctl daemon-reload
root@prometheus01:/usr/local/prometheus-webhook-dingtalk# systemctl restart prometheus-webhook-dingtalk.service
root@prometheus01:/usr/local/prometheus-webhook-dingtalk# systemctl enable prometheus-webhook-dingtalk.service
root@prometheus01:/usr/local/prometheus-webhook-dingtalk# systemctl status prometheus-webhook-dingtalk.service | grep Active
   Active: active (running) since Fri 2022-04-08 14:36:33 CST; 7s ago
#root@prometheus01:/usr/local/prometheus-webhook-dingtalk# curl -XPOST http://localhost:8060/-/reload	#后面可使用此方法重载，因为服务配置加入web.enable-lifecycle

----配置alertmanager
root@prometheus01:/usr/local/alertmanager# cat alertmanager.yml
global:
  resolve_timeout: 5m
  smtp_require_tls: false
  smtp_smarthost: 'smtp.qiye.163.com:465'
  smtp_hello: '@163.com'
  smtp_from: 'prometheus@domaim.com'
  smtp_auth_username: 'prometheus@domain.com'
  smtp_auth_password: 'password'
templates:
  - '/usr/local/alertmanager/email.tmpl'
route:
  receiver: 'dingding'		#配置告警通知时，最好将告警方式配置在这里，这里表示没有匹配到的告警将由此方式发出
  group_by: ['alertname']
  group_wait: 5s
  group_interval: 1s
  repeat_interval: 4h
  routes:
  - receiver: 'dingding'
    group_wait: 5s
    continue: true
    match_re:
      alertname: .*[a-z].*
  - receiver: 'email'
    group_wait: 5s
    continue: true
    match_re:
      alertname: .*[a-z].*
receivers:
- name: 'email'
  email_configs:
  - to: '{{ template "email.to" . }}'
    html: '{{ template "email.html" . }}'
    send_resolved: true
- name: 'dingding'
  webhook_configs:
  - url: 'http://172.168.2.27:8060/dingtalk/dingding/send'
    send_resolved: true
inhibit_rules:
  - source_match:
      alertname: linuxNodeDown
    target_match:
      job: blackboxProbeFailure
    equal:
      - ops
---
--配置prometheus告警规则
root@prometheus01:/usr/local/prometheus/rules# cat /usr/local/prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - '172.168.2.27:9093'
rule_files:
  - rules/*.rule

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "prometheus-federate01-172.168.2.28"
    scrape_interval: 15s
    honor_labels: true
    metrics_path: '/federate'
    params:
      'match[]':
      - '{job="prometheus"}'
      - '{__name__=~"job:.*"}'
      - '{__name__=~"node.*"}'
    static_configs:
    - targets: ["172.168.2.28:9090"]

  - job_name: "prometheus-federate02-172.168.2.29"
    scrape_interval: 15s
    honor_labels: true
    metrics_path: '/federate'
    params:
      'match[]':
      - '{job="prometheus"}'
      - '{__name__=~"job:.*"}'
      - '{__name__=~"node.*"}'
    static_configs:
    - targets: ["172.168.2.29:9090"]
---
root@prometheus01:/usr/local/prometheus/rules# cat test.rule
groups:
- name: linuxHostStatusAlert
  rules:
  - alert: linuxHostCPUUsageAlert
    expr: avg(rate(node_cpu_seconds_total{mode="system"}[5m])) by (instance) *100 >7
    for: 30s
    labels:
      severity: warnning
    annotations:
      summary: "Host CPU[5m] usage High"
      description: "instance: {{ $labels.instance }} CPU Usage above 85%/5m (current value: {{ $value }})"
---
root@prometheus01:/usr/local/prometheus/rules# curl -X POST http://localhost:9090/-/reload

4. 测试钉钉是否成功收取到消息


----#企业微信告警
----注册企业微信，可以取一个企业名称，主要是手机号绑定，不用实名也可以的，但不能违法，然后在应用管理——应用——创建一个机器人，获取AgentId和Secret，企业ID——在我的企业中获取，信息如下：
企业ID: ww51a66e1695615e
AgentId: 100002
Secret: G-mb4SP5Xn-Id75f99NrFGMjHrfbYzIkDLcbi

root@prometheus01:/usr/local/alertmanager# cat wechat-new.tmpl		#微信模板
{{ define "wechat.default.message" }}
{{ range $i, $alert :=.Alerts }}
===alertmanager 监控报警===
告警状态：{{ .Status }}
告警主题: {{ $alert.Annotations.summary }}
告警级别：{{ $alert.Labels.severity }}
告警类型：{{ $alert.Labels.alertname }}
故障主机: {{ $alert.Labels.instance }}
告警详情: {{ $alert.Annotations.description }}
触发时间: {{ $alert.StartsAt.Format "2006-01-02 15:04:05" }}
===========end============
{{ end }}
{{ end }}
-----
root@prometheus01:/usr/local/alertmanager# cat email.tmpl			#邮件模板
{{ define "email.to" }}jack@domain.com{{ end }}
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
---

--alertmanagre增加配置即可
root@prometheus01:/usr/local/alertmanager# cat alertmanager.yml
global:
  resolve_timeout: 5m
  smtp_require_tls: false
  smtp_smarthost: 'smtp.qiye.163.com:465'
  smtp_hello: '@163.com'
  smtp_from: 'prometheus@domaim.com'
  smtp_auth_username: 'prometheus@domain.com'
  smtp_auth_password: 'password'
templates:
  - '/usr/local/alertmanager/email.tmpl'
  - '/usr/local/alertmanager/wechat-new.tmpl'
route:
  receiver: 'webhook'
  group_by: ['alertname']
  group_wait: 5s
  group_interval: 1s
  repeat_interval: 4h
  routes:
  - receiver: 'dingding'
    group_wait: 5s
    continue: true
    match_re:
      alertname: .*[a-z].*
  - receiver: 'wechat'
    group_wait: 5s
    continue: true
    match_re:
      alertname: .*[a-z].*
receivers:
- name: 'email'
  email_configs:
  - to: '{{ template "email.to" . }}'
    html: '{{ template "email.html" . }}'
    send_resolved: true
- name: 'dingding'
  webhook_configs:
  - url: 'http://172.168.2.27:8060/dingtalk/dingding/send'
    send_resolved: true
- name: 'wechat'
  wechat_configs:
  - corp_id: ww51a66e1695615e
    to_user: '@all'
    agent_id: 100002
    api_secret: G-mb4SP5Xn-Id75MjHrfbYzIkDLcbiLkunX0
    send_resolved: true
inhibit_rules:
  - source_match:
      alertname: linuxNodeDown
    target_match:
      job: blackboxProbeFailure
    equal:
      - ops
-----

--最后测试企业微信是否收到测试消息即可


#alertmanager高可用
第一种：prometheus-server01	------------|		   | alertmanager01	---------|	
										lvs--------							dingding,wechat,email
		prometheus-server02	------------|		   | alertmanager02 ---------|
注：后面装两个alertmanager，因为基于Alertmanager的告警分组机制即使不同的Prometheus Sever分别发送相同的告警给Alertmanager，Alertmanager也可以自动将这些告警合并为一个通知向receiver发送。会自动去重，所以为会发送重复的告警到后端告警媒介，lvs需要有健康检查功能。需要使用源地址哈希功能，sh算法

第二种：prometheus-server01	------------|		   | alertmanager01	---------|	
										|----------| alertmanager02	---------|dingding,wechat,email
		prometheus-server02	------------|		   | alertmanager03 ---------|
注：alertmanagr集群运行gossip协议，会自动去重


----#部署alertmanager集群
为了能够让Alertmanager节点之间进行通讯，需要在Alertmanager启动时设置相应的参数。其中主要的参数包括：
--cluster.listen-address string: 当前实例集群服务监听地址
--cluster.peer value: 初始化时关联的其它实例的集群服务地址

--3个节点部署alertmanager
root@prometheus:/usr/local/src# tar xf alertmanager-0.23.0.linux-amd64.tar.gz -C /usr/local/
root@prometheus:/usr/local/src# chown -R prometheus.prometheus /usr/local/alertmanager-0.23.0.linux-amd64/
root@prometheus:/usr/local/src# ln -sv /usr/local/alertmanager-0.23.0.linux-amd64/ /usr/local/alertmanager

--alertmanager01
/usr/local/alertmanager/alertmanager  --web.listen-address=":9093" --cluster.listen-address="172.168.2.27:8001" --config.file=/usr/local/alertmanager/alertmanager.yml  --storage.path=/usr/local/alertmanager/data/

--alertmanager02
/usr/local/alertmanager/alertmanager  --web.listen-address=":9093" --cluster.listen-address="172.168.2.28:8001" --cluster.peer=172.168.2.27:8001 --config.file=/usr/local/alertmanager/alertmanager.yml  --storage.path=/usr/local/alertmanager/data/

--alertmanager03
/usr/local/alertmanager/alertmanager  --web.listen-address=":9093" --cluster.listen-address="172.168.2.29:8001"  --cluster.peer=172.168.2.27:8001 --config.file=/usr/local/alertmanager/alertmanager.yml  --storage.path=/usr/local/alertmanager/data/
#去其中一台alertmanager查看集群状态


---服务方式启动
root@prometheus01:/usr/local/alertmanager# cat /lib/systemd/system/alertmanager.service
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/alertmanager/alertmanager --config.file=/usr/local/alertmanager/alertmanager.yml \
--storage.path=/usr/local/alertmanager/data/ --web.external-url=http://172.168.2.27:9093 \
--web.listen-address="0.0.0.0:9093" --cluster.listen-address="172.168.2.27:8001"
Restart=on-failure

[Install]
WantedBy=multi-user.target
---
root@prometheus02:/usr/local/alertmanager# cat /lib/systemd/system/alertmanager.service
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/alertmanager/alertmanager --config.file=/usr/local/alertmanager/alertmanager.yml \
--storage.path=/usr/local/alertmanager/data/ --web.external-url=http://172.168.2.28:9093 \
--web.listen-address="0.0.0.0:9093" --cluster.listen-address="172.168.2.28:8001" --cluster.peer=172.168.2.27:8001
Restart=on-failure

[Install]
WantedBy=multi-user.target
---
root@prometheus03:/usr/local/alertmanager# cat /lib/systemd/system/alertmanager.service
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/alertmanager/alertmanager --config.file=/usr/local/alertmanager/alertmanager.yml \
--storage.path=/usr/local/alertmanager/data/ --web.external-url=http://172.168.2.29:9093 \
--web.listen-address="0.0.0.0:9093" --cluster.listen-address="172.168.2.29:8001" --cluster.peer=172.168.2.28:8001
Restart=on-failure

[Install]
WantedBy=multi-user.target
---
root@prometheus:/usr/local/alertmanager# systemctl daemon-reload
root@prometheus:/usr/local/alertmanager# systemctl restart alertmanager.service



--配置prometheus增加alertmanager地址
root@prometheus01:/usr/local/alertmanager# cat /usr/local/prometheus/prometheus.yml
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - '172.168.2.27:9093'
          - '172.168.2.28:9093'
          - '172.168.2.29:9093'
	
	
	

####promtheus远端存储----victoriametrics
DownloadURL: https://github.com/VictoriaMetrics/VictoriaMetrics
单机版下载：https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v1.76.0/victoria-metrics-amd64-v1.76.0.tar.gz
集群版下载：https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v1.76.0/victoria-metrics-amd64-v1.76.0-cluster.tar.gz

####单机部署
参数：
-httpListenAddr=0.0.0.0:8428 #监听地址及端口
-storageDataPath #VictoriaMetrics 将所有数据存储在此目录中，默认为执行启动 victoria 的当前目录下
的 victoria-metrics-data 目录中。
-retentionPeriod #存储数据的保留，较旧的数据会自动删除，默认保留期为 1 个月，默认单位为 m(月)，
支持的单位有 h (hour), d (day), w (week), y (year)。

1. 安装运行
root@prometheus01:/usr/local/src# tar xf victoria-metrics-amd64-v1.76.0.tar.gz
root@prometheus01:/usr/local/src# chown -R prometheus.prometheus /usr/local/src/victoria-data/
root@prometheus01:/usr/local/src# chmod -R 775 /usr/local/src/victoria-data/	
root@prometheus01:/usr/local/src# ./victoria-metrics-prod -httpListenAddr=0.0.0.0:8428 -storageDataPath=/usr/local/src/victoria-data -retentionPeriod=3

2. 配置prometheus
root@prometheus01:~# cd /usr/local/prometheus
root@prometheus01:/usr/local/prometheus# vim prometheus.yml
remote_write:
- url: http://172.168.2.27:8428/api/v1/write
root@prometheus01:/usr/local/prometheus# systemctl restart prometheus
注：prometheus虽然往远端存储上写入数据，但是tsdb配置不能删除，否则会在/data/目录下生成tsdb目录

3. 测试数据是否在维多利亚存储成功
访问维多利亚：http://172.168.2.27:8428/
在UI查看数据是否存储成功：http://172.168.2.27:8428/vmui






####集群部署
组件介绍：
vminsert	#写入组件(写)，vminsert 负责接收数据写入并根据对度量名称及其所有标签的一致 hash 结果将数据分散写入不同的后端 vmstorage 节点之间 vmstorage，vminsert 默认端口 8480
vmstorage 	#存储原始数据并返回给定时间范围内给定标签过滤器的查询数据，默认端口 8482
vmselect 	#查询组件(读)，连接 vmstorage ，默认端口 8481
注：远端存储只部署以上3个组件即可

其它可选组件：
vmagent	#是一个很小但功能强大的代理，它可以从 node_exporter 各种来源收集度量数据，并将它们存 储 在 VictoriaMetrics 或 任 何 其 他 支 持 远 程 写 入 协 议 的 与 prometheus 兼 容 的 存 储 系 统 中 ， 有 替 代prometheus server 的意向。
vmalert： 替换 prometheus server，以 VictoriaMetrics 为数据源，基于兼容 prometheus 的告警规则，判断数据是否异常，并将产生的通知发送给 alertermanager
Vmgateway： 读写 VictoriaMetrics 数据的代理网关，可实现限速和访问控制等功能，目前为企业版组件
vmctl： VictoriaMetrics 的命令行工具，目前主要用于将 prometheus、opentsdb 等数据源的数据迁移到VictoriaMetrics。

vmstorage-prod主要参数：
-httpListenAddr string
Address to listen for http connections (default ":8482")
-vminsertAddr string
TCP address to accept connections from vminsert services (default ":8400")
-vmselectAddr string
TCP address to accept connections from vmselect services (default ":8401")



1. 安装部署vmstorage-prod:
----node01:
root@prometheus01:/usr/local/src# tar -tvf victoria-metrics-amd64-v1.76.0-cluster.tar.gz
-rwxr-xr-x valyala/valyala 11454200 2022-04-07 20:51 vminsert-prod
-rwxr-xr-x valyala/valyala 12511560 2022-04-07 20:52 vmselect-prod
-rwxr-xr-x valyala/valyala 11784736 2022-04-07 20:52 vmstorage-prod
root@prometheus01:/usr/local/src# tar xf victoria-metrics-amd64-v1.76.0-cluster.tar.gz -C /usr/local/bin/
root@prometheus01:/usr/local/src# cat /lib/systemd/system/vmstorage.service
[Unit]
Description=Vmstorage Server
After=network.target

[Service]
Restart=on-failure
WorkingDirectory=/tmp
ExecStart=/usr/local/bin/vmstorage-prod -loggerTimezone Asia/Shanghai -storageDataPath /data/vmstorage-data -httpListenAddr :8482 -vminsertAddr :8400 -vmselectAddr :8401

[Install]
WantedBy=multi-user.target
---
root@prometheus01:/usr/local/src# systemctl daemon-reload && systemctl enable vmstorage.service && systemctl start vmstorage.service
root@prometheus01:/usr/local/src# ss -tnl | grep :84
LISTEN   0         128                 0.0.0.0:8482             0.0.0.0:*		#vmstorage端口
LISTEN   0         128                 0.0.0.0:8400             0.0.0.0:*		#提供vminsert写入端口
LISTEN   0         128                 0.0.0.0:8401             0.0.0.0:*		#提供vmselect读取端口

----node02:
root@prometheus02:/usr/local/src# tar xf victoria-metrics-amd64-v1.76.0-cluster.tar.gz -C /usr/local/bin/
root@prometheus02:/usr/local/src# cat /lib/systemd/system/vmstorage.service
[Unit]
Description=Vmstorage Server
After=network.target

[Service]
Restart=on-failure
WorkingDirectory=/tmp
ExecStart=/usr/local/bin/vmstorage-prod -loggerTimezone Asia/Shanghai -storageDataPath /data/vmstorage-data -httpListenAddr :8482 -vminsertAddr :8400 -vmselectAddr :8401

[Install]
WantedBy=multi-user.target
---
root@prometheus02:/usr/local/src# systemctl daemon-reload && systemctl enable vmstorage.service && systemctl start vmstorage.service
root@prometheus02:/usr/local/src# ss -tnl | grep :84
LISTEN   0         128                 0.0.0.0:8482             0.0.0.0:*
LISTEN   0         128                 0.0.0.0:8400             0.0.0.0:*
LISTEN   0         128                 0.0.0.0:8401             0.0.0.0:*

----node03:
root@prometheus03:/usr/local/src# tar xf victoria-metrics-amd64-v1.76.0-cluster.tar.gz -C /usr/local/bin/
root@prometheus03:/usr/local/src# cat /lib/systemd/system/vmstorage.service
[Unit]
Description=Vmstorage Server
After=network.target

[Service]
Restart=on-failure
WorkingDirectory=/tmp
ExecStart=/usr/local/bin/vmstorage-prod -loggerTimezone Asia/Shanghai -storageDataPath /data/vmstorage-data -httpListenAddr :8482 -vminsertAddr :8400 -vmselectAddr :8401

[Install]
WantedBy=multi-user.target
---
root@prometheus03:/usr/local/src# systemctl daemon-reload && systemctl enable vmstorage.service && systemctl start vmstorage.service
root@prometheus03:/usr/local/src# ss -tnl | grep :84
LISTEN   0         128                 0.0.0.0:8400             0.0.0.0:*
LISTEN   0         128                 0.0.0.0:8401             0.0.0.0:*
LISTEN   0         128                 0.0.0.0:8482             0.0.0.0:*


2. 安装部署vminsert-prod:
----node01
root@prometheus01:/usr/local/src# cat /lib/systemd/system/vminsert.service
[Unit]
Description=Vminsert Server
After=network.target

[Service]
Restart=on-failure
WorkingDirectory=/tmp
ExecStart=/usr/local/bin/vminsert-prod -httpListenAddr :8480 -storageNode=172.168.2.27:8400,172.168.2.28:8400,172.168.2.29:8400

[Install]
WantedBy=multi-user.target
---
root@prometheus01:/usr/local/src# systemctl daemon-reload && systemctl enable vminsert.service && systemctl start vminsert.service
root@prometheus01:/usr/local/src# ss -tnl | grep :8480
LISTEN   0         128                 0.0.0.0:8480             0.0.0.0:*

----node02
root@prometheus02:/usr/local/src# cat /lib/systemd/system/vminsert.service
[Unit]
Description=Vminsert Server
After=network.target

[Service]
Restart=on-failure
WorkingDirectory=/tmp
ExecStart=/usr/local/bin/vminsert-prod -httpListenAddr :8480 -storageNode=172.168.2.27:8400,172.168.2.28:8400,172.168.2.29:8400

[Install]
WantedBy=multi-user.target
root@prometheus02:/usr/local/src# systemctl daemon-reload && systemctl enable vminsert.service && systemctl start vminsert.service
root@prometheus02:/usr/local/src# ss -tnl | grep :8480
LISTEN   0         128                 0.0.0.0:8480             0.0.0.0:*

----node03
root@prometheus03:/usr/local/src# cat /lib/systemd/system/vminsert.service
[Unit]
Description=Vminsert Server
After=network.target

[Service]
Restart=on-failure
WorkingDirectory=/tmp
ExecStart=/usr/local/bin/vminsert-prod -httpListenAddr :8480 -storageNode=172.168.2.27:8400,172.168.2.28:8400,172.168.2.29:8400

[Install]
WantedBy=multi-user.target
root@prometheus03:/usr/local/src# systemctl daemon-reload && systemctl enable vminsert.service && systemctl start vminsert.service
root@prometheus03:/usr/local/src# ss -tnl | grep :8480
LISTEN   0         128                 0.0.0.0:8480             0.0.0.0:*


3. 安装部署vmselect-prod:
----node01
root@prometheus01:/usr/local/src# cat /lib/systemd/system/vmselect.service
[Unit]
Description=Vminsert Server
After=network.target

[Service]
Restart=on-failure
WorkingDirectory=/tmp
ExecStart=/usr/local/bin/vmselect-prod -httpListenAddr :8481 -storageNode=172.168.2.27:8401,172.168.2.28:8401,172.168.2.29:8401

[Install]
WantedBy=multi-user.target
---
root@prometheus01:/usr/local/src# systemctl daemon-reload && systemctl enable vmselect.service && systemctl start vmselect.service
root@prometheus01:/usr/local/src# ss -tnl | grep :8481
LISTEN   0         128                 0.0.0.0:8481             0.0.0.0:*

----node02
root@prometheus02:/usr/local/src# cat /lib/systemd/system/vmselect.service
[Unit]
Description=Vminsert Server
After=network.target

[Service]
Restart=on-failure
WorkingDirectory=/tmp
ExecStart=/usr/local/bin/vmselect-prod -httpListenAddr :8481 -storageNode=172.168.2.27:8401,172.168.2.28:8401,172.168.2.29:8401

[Install]
WantedBy=multi-user.target
---
root@prometheus02:/usr/local/src# systemctl daemon-reload && systemctl enable vmselect.service && systemctl start vmselect.service
root@prometheus02:/usr/local/src# ss -tnl | grep :8481
LISTEN   0         128                 0.0.0.0:8481             0.0.0.0:*

----node03
root@prometheus03:/usr/local/src# cat /lib/systemd/system/vmselect.service
[Unit]
Description=Vminsert Server
After=network.target

[Service]
Restart=on-failure
WorkingDirectory=/tmp
ExecStart=/usr/local/bin/vmselect-prod -httpListenAddr :8481 -storageNode=172.168.2.27:8401,172.168.2.28:8401,172.168.2.29:8401

[Install]
WantedBy=multi-user.target
---
root@prometheus03:/usr/local/src# systemctl daemon-reload && systemctl enable vmselect.service && systemctl start vmselect.service
root@prometheus03:/usr/local/src# ss -tnl | grep :8481
LISTEN   0         128                 0.0.0.0:8481             0.0.0.0:*

4. 验证服务端口
root@prometheus01:/usr/local/src# curl http://172.168.2.27:8480/metrics
root@prometheus01:/usr/local/src# curl http://172.168.2.27:8481/metrics
root@prometheus01:/usr/local/src# curl http://172.168.2.27:8482/metrics


5. 配置prometheus写入到vmstorage
root@prometheus01:/usr/local/prometheus# cat prometheus.yml
remote_write:
- url: http://172.168.2.27:8480/insert/1/prometheus				
- url: http://172.168.2.28:8480/insert/1/prometheus
- url: http://172.168.2.29:8480/insert/1/prometheus
注：#http://172.168.2.27:8480/insert此为固定地址，1/prometheus此为自定义地址，查询时应对此自定义地址，查询地址路径应为：http://172.168.2.27:8481/select/1/prometheus，是无状态的，在前面可加LB，默认情况下，数据被 vminsert 的组件基于 hash 算法分别将数据持久化到不同的vmstorage节点，一个数据会被拆分成N分在vmstorage节点，提高读写性能
root@prometheus01:/usr/local/prometheus# systemctl stop prometheus
root@prometheus01:/usr/local/prometheus# systemctl start prometheus

6. 在grafana配置prometheus数据源为vmselect，从vmselect读取数据，无状态，前面应有LB
添加一个新的prometheus源，名称为：Prometheus-victoriametrics-cluster，地址为：http://172.168.2.27:8481/select/1/prometheus
新添加模板选定数据源为新添加的Prometheus-victoriametrics-cluster，再看是否有数据


7. 开启数据复制（可选）
默认情况下，数据被 vminsert 的组件基于 hash 算法分别将数据持久化到不同的vmstorage 节点，一个数据被拆分成多份。可以启用 vminsert 组件支持的-replicationFactor=N 复制功能，将数据分别在各节点保存一份完整的副本以实现数据的高可用。


</pre>