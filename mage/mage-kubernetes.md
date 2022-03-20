#mage-kubernetes 1.21

<pre>
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







</pre>