#kubeadm方式(官网推荐) 搭建K8s高可用集群
<pre>
#规划：
master1: node1 192.168.15.201 install:keepalived,haproxy k8s:kube-apiserver,kube-controller-manager,kube-scheduler,etcd,kubelet,kube-proxy,flannel,docker
master2: node2 192.168.15.202 install:keepalived,haproxy k8s:kube-apiserver,kube-controller-manager,kube-scheduler,etcd,kubelet,kube-proxy,flannel,docker
master3: node3 192.168.15.203 install:keepalived,haproxy k8s:kube-apiserver,kube-controller-manager,kube-scheduler,etcd,kubelet,kube-proxy,flannel,docker
node1: salt 192.168.15.199  k8s:kubelet,kube-proxy,flannel,docker
VIP: 192.168.15.50
#软件版本信息：
Linux操作系统：CentOS Linux release 7.6.1810 (Core)
内核：3.10.0-957.el7.x86_64 
Kubernetes：1.15.11
Docker：19.03.9
#1.1环境准备（下面要更改的都在下面salt清单文件中）
[root@master /srv/salt/base]# cat top.sls
base:
  'master':
    - init.init
  'node*':
    - init.init
prod:
  'master':
    - docker.docker_install.install
  'node*':
    - docker.docker_install.install
[root@master /srv/salt/base]# cat init/init.sls 
include:
  - init.dns
  - init.hosts
  - init.history
  - init.audit
  - init.sysctl
  - init.firewall
  - init.ssh
  - init.postfix
  - init.tty-timeout
  - init.ntp-client
  - init.selinux
  - init.tty-style
  - init.user-www
  - init.repo-clear
  - init.repo
  - init.basePkg
  - init.python-pip
  - init.axel
  - init.k8s
#使集群内节点各主机名互相能解析
[root@master /srv/salt/base/init]# salt -L master,node1,node2,node3 cmd.run 'cat /etc/hosts | egrep "salt|node" | grep -v "#"'
#使集群内节点时间一致
[root@master ~]# salt -L master,node1,node2,node3 cmd.run 'date'
#关闭SElinux
[root@master ~]# salt -L master,node1,node2,node3 cmd.run 'getenforce'
#关闭防火墙
[root@master ~]# salt -L master,node1,node2,node3 cmd.run 'systemctl status firewalld | grep -i "active"'
#生产环境关闭虚拟内存，并要在/etc/fstab中禁用swap挂载:  
[root@master ~]# salt -L master,node1,node2,node3 cmd.run 'swapoff -a'
[root@master ~]# salt -L master,node1,node2,node3 cmd.run "sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab"
#注：另外要确保双机互信
[root@master /srv/salt/base/init]# salt -L master,node1,node2,node3 cmd.run 'mkdir -p /root/.ssh/'
[root@master /srv/salt/base/init]# salt-cp '*' /root/.ssh/authorized_keys /root/.ssh/
#salt清单文件：
--------互相能解析---------
[root@master /srv/salt/base]# cat init/hosts.sls 
/etc/hosts:
  file.managed:
    - source: salt://init/files/hosts
    - user: root
    - group: root
    - mode: 644
[root@master /srv/salt/base]# cat init/files/hosts 
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
140.82.113.3    github.com
199.232.69.194	github.global.ssl.fastly.net
192.168.15.199 master
192.168.15.200 harbor
192.168.15.201 node1
192.168.15.202 node2
192.168.15.203 node3
--------时间同步-----------
[root@master /srv/salt/base]# cat init/ntp-client.sls 
ntpdate-install:
  pkg.installed:
    - name: ntpdate

TimeZone:
  timezone.system:
    - name: Asia/Shanghai

cron-ntpdate:
  cron.present:
    - name: ntpdate time1.aliyun.com
    - user: root
    - minute: '*/5'
-------关闭selinux--------
[root@master /srv/salt/base]# cat init/selinux.sls 
close_selinux:
  file.managed:
    - name: /etc/selinux/config
    - source: salt://init/files/selinux-config.template
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - name: setenforce 0 || echo ok
    - onlyif: getsebool
[root@master /srv/salt/base]# cat init/files/selinux-config.template 
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=disabled
# SELINUXTYPE= can take one of three two values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected. 
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted 
-------关闭防火墙--------
[root@master /srv/salt/base]# cat init/firewall.sls 
firewalld-stop:
  service.dead:
    - name: firewalld.service
    - enable: False
------------------------

#系统调优、ipvs配置，docker安装
[root@master /srv/salt/base/init]# salt -L master,node1,node2,node3 state.highstate
------------------------
[root@master /srv/salt/base/init]# cat k8s.sls 
#require sysctl.sls
enable-ipvs-modules:
  file.managed:
    - name: //etc/sysconfig/modules/ipvs.modules
    - source: salt://init/files/ipvs.modules
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: bash /etc/sysconfig/modules/ipvs.modules
    - unless: lsmod | grep -e ip_vs
  pkg.installed:
    - pkgs:
      - ipset
      - ipvsadm
[root@master /srv/salt/base/init]# cat files/ipvs.modules 
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
[root@master /srv/salt/base/init]# cat sysctl.sls #里面有k8s需要调优的参数
net.ipv4.ip_local_port_range:    
  sysctl.present:
    - value: 10000 65000
net.bridge.bridge-nf-call-iptables:
  sysctl.present:
    - value: 1
net.bridge.bridge-nf-call-ip6tables:
  sysctl.present:
    - value: 1
net.ipv4.ip_forward: 
  sysctl.present:
    - value: 1
net.ipv4.tcp_tw_recycle:
  sysctl.present:
    - value: 0
vm.swappiness:
  sysctl.present:
    - value: 0
vm.overcommit_memory:
  sysctl.present:
    - value: 1
vm.panic_on_oom:
  sysctl.present:
    - value: 0
fs.inotify.max_user_instances:
  sysctl.present:
    - value: 8192
fs.inotify.max_user_watches:
  sysctl.present:
    - value: 1048576
fs.file-max:
  sysctl.present:
    - value: 52706963
fs.nr_open:
  sysctl.present:
    - value: 52706963
net.ipv6.conf.all.disable_ipv6:
  sysctl.present:
    - value: 1
net.netfilter.nf_conntrack_max:
  sysctl.present:
    - value: 2310720
------------------------

#docker配置
------------------------------------
[root@master /srv/salt/prod/keepalived]# cat /etc/docker/daemon.json 
{
	"exec-opts": ["native.cgroupdriver=systemd"],
	"registry-mirrors": ["https://fz5yth0r.mirror.aliyuncs.com","http://hub-mirror.c.163.com","https://docker.mirrors.ustc.edu.cn","https://registry.docker-cn.com"],
	"insecure-registries": ["http://192.168.15.200:8888"], 
	"log-driver": "json-file",
	"log-opts": {"max-size": "100m"}
}  
注解：
1. "exec-opts": ["native.cgroupdriver=systemd"]：表示将docker的cgroup driver设为systemd，或在/var/lib/systemd/system/docker.service中ExecStart加参数设定：--exec-opt native.cgroupdriver=systemd 。k8s需要
2. "registry-mirrors" ：镜像仓库地址
3. "insecure-registries"：不安全的仓库，这里设置的是自己的私有仓库，因为是http，所以需要放在这里指明，docker默认是信任https。
4. "log-driver": 设定docker的日志为json格式，以后方便ELK进行管理。
5. "log-opts"：用来设定一个容器日志文件最大多少，还可以指定"max-file":"3"来设定一个容器最大有几个日志文件，不指则使用默认策略。这个选项只针对新创建容器才生效，已经运行容器不生效。可通过命令查看是否生效：docker inspect -f '{{.HostConfig.LogConfig}}' haproxy-k8s 
{json-file map[max-size:100m]}
------------------------------------

---------------------------------------------
#使用镜像部署haproxy和keepalived实现k8s的高可用
---------------------------------------------
[root@node1 /download/ha]# cat haproxy.cfg 
global
log 127.0.0.1 local0
log 127.0.0.1 local1 notice
maxconn 4096
#chroot /usr/share/haproxy
#user haproxy
#group haproxy
daemon

defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    retries 3
    option redispatch
    timeout connect  5000
    timeout client  50000
    timeout server  50000

frontend stats-front
  bind *:8081
  mode http
  default_backend stats-back

frontend fe_k8s_6444
  bind *:6444
  mode tcp
  timeout client 1h
  log global
  option tcplog
  default_backend be_k8s_6443
  acl is_websocket hdr(Upgrade) -i WebSocket
  acl is_websocket hdr_beg(Host) -i ws

backend stats-back
  mode http
  balance roundrobin
  stats uri /haproxy/stats
  stats auth jack:jacklil

backend be_k8s_6443
  mode tcp
  timeout queue 1h
  timeout server 1h
  timeout connect 1h
  log global
  balance roundrobin
  server rancher01 192.168.15.201:6443
  #server rancher02 192.168.15.202:6443 
  #server rancher03 192.168.15.203:6443
---------------------------------------------
haproxy.cfg注：
server先只开启一台，如果开启多台，K8S安装时则可能
调度到不存在的端口，从而MASTER安装失败。这里先不开启
端口检查来实现服务动态高可用。等多台master节点都已经
安装加入集群完成后再加上，如：
 server rancher01 192.168.15.201:6443 check inter 2000 rise 2 fall 3
 server rancher02 192.168.15.202:6443 check inter 2000 rise 2 fall 3
 server rancher03 192.168.15.203:6443 check inter 2000 rise 2 fall 3
---------------------------------------------
[root@node1 /download/ha]# cat haproxy-start.sh 
#!/bin/bash
#
MasterIP1=192.168.15.201
MasterIP2=192.168.15.202
MasterIP3=192.168.15.203

docker run -d --restart=always --name haproxy-k8s -p 6444:6444 \
	-e MasterIP1=$MasterIP1 \
	-e MasterIP2=$MasterIP2 \
	-e MasterIP3=$MasterIP3 \
	-v /download/ha/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg \
	192.168.15.200:8888/k8s/haproxy-k8s:latest
---------------------------------------------
haproxy-start.sh注：
haproxy镜像的启动脚本。填写多个MASTER的ip地址，并且挂载
事先准备好的配置文件，用以挂载。
---------------------------------------------
[root@node1 /download/ha]# cat keepalived-start.sh 
#!/bin/sh
#
VIRTUAL_IP=192.168.15.50
INTERFACE=eth0
NETMASK_BIT=24
CHECK_PORT=6444
RID=60
VRID=120
MCAST_GROUP=244.0.0.18

docker run -d --restart=always --name=keepalived-k8s \
	--net=host --cap-add=NET_ADMIN \
	-e VIRTUAL_IP=$VIRTUAL_IP \
	-e INTERFACE=$INTERFACE \
	-e NETMASK_BIT=$NETMASK_BIT \
	-e CHECK_PORT=$CHECK_PORT \
	-e RID=$RID \
	-e VRID=$VRID \
	-e MCAST_GROUP=$MCAST_GROUP \
	192.168.15.200:8888/k8s/keepalived-k8s:latest
---------------------------------------------
keepalived-start.sh注：
keepalived镜像的启动脚本。填写VIP地址、指明宿主机的网口、
宿主机网络掩码、keepalived要检查的端口、
router_id(RID)：运行keepalived的一个表示，多个集群设置不同、
virtual_router_id(VRID):用以区分是否属于同一个VIP实例组，
属于同一个VIP组则这里的虚拟路由ID一定一样、
(MCAST_GROUP):多播地址，keepalived集群用以联络地址。
---------------------------------------------
--------haproxy容器中生成的配置---------
[root@node1 /download/ha]# docker exec haproxy-k8s cat /usr/local/etc/haproxy/haproxy.cfg
global
log 127.0.0.1 local0
log 127.0.0.1 local1 notice
maxconn 4096
#chroot /usr/share/haproxy
#user haproxy
#group haproxy
daemon

defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    retries 3
    option redispatch
    timeout connect  5000
    timeout client  50000
    timeout server  50000

frontend stats-front
  bind *:8081
  mode http
  default_backend stats-back

frontend fe_k8s_6444
  bind *:6444
  mode tcp
  timeout client 1h
  log global
  option tcplog
  default_backend be_k8s_6443
  acl is_websocket hdr(Upgrade) -i WebSocket
  acl is_websocket hdr_beg(Host) -i ws

backend stats-back
  mode http
  balance roundrobin
  stats uri /haproxy/stats
  stats auth jack:jacklil

backend be_k8s_6443
  mode tcp
  timeout queue 1h
  timeout server 1h
  timeout connect 1h
  log global
  balance roundrobin
  server rancher01 192.168.15.201:6443 
  #server rancher02 192.168.15.202:6443 
  #server rancher03 192.168.15.203:6443
--------keepalived容器中生成的配置---------
[root@node1 /download/ha]# docker exec keepalived-k8s cat /etc/keepalived/keepalived.conf 
    global_defs {
        router_id 60
        vrrp_version 2
        vrrp_garp_master_delay 1
    }   

    vrrp_script chk_haproxy {
        script       "/bin/busybox nc -v -w 2 -z 127.0.0.1 6444 2>&1 | grep open | grep 6444"
        timeout 1
        interval 1   # check every 1 second
        fall 2       # require 2 failures for KO
        rise 2       # require 2 successes for OK
    }   

    vrrp_instance lb-vips {
        state BACKUP
        interface eth0
        virtual_router_id 120
        priority 100
        advert_int 1
        nopreempt
        track_script {
            chk_haproxy
        }
        authentication {
            auth_type PASS
            auth_pass blahblah
        }
        virtual_ipaddress {
            192.168.15.50/24 dev eth0
        }
    }
------------------------------------
注：当所有三个节点都成为MASTER节点后，所有节点都应该把haproxy中的后面三个服务都开启，并且三个节点都运行keepalived实现负载均衡高可用

#配置kubernetes阿里云的yum源，用来安装kubeadm等组件(可选，如果有特定版本需要可去开源镜像站下载下来本地安装，我们后面是自己下载下来安装的)
[root@node1 k8s]# cat /etc/yum.repos.d/k8s.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
[root@salt /srv/salt/prod/keepalived]# salt-cp  -L node1,node2 /etc/yum.repos.d/k8s.repo /etc/yum.repos.d/
#手动下载并安装kube组件，这里不使用在线安装，因为有版本需求(去清华软件镜像源或阿里源下载下来，这里版本为1.15.11)
#----也可这样下载：yum install -y  --showduplicates kubectl-1.15.11-0 kubelet-1.15.11-0 kubeadm-1.15.11-0 kubernetes-cni-0.8.6-0 cri-tools-1.13.0-0
[root@node1 k8s]# ls
cri-tools-1.13.0-0.x86_64.rpm  kubectl-1.15.11-0.x86_64.rpm  	kubernetes-cni-0.8.6-0.x86_64.rpm
kubeadm-1.15.11-0.x86_64.rpm   kubelet-1.15.11-0.x86_64.rpm
[root@node1 k8s]# yum localinstall -y *.rpm
#设定docker和kubelet开启启动，所有节点都一样
[root@node1 /download/k8s]# systemctl enable kubelet  
[root@node1 /download/k8s]# systemctl enable docker
#先从第三方镜像站下载google镜像：
#直接下载需要的版本的镜像
[root@node1 /download/k8s]# kubeadm config images pull --image-repository=registry.aliyuncs.com/google_containers --kubernetes-version=v1.15.11 
#然后给下载好的第三方k8s镜像从打标签，例如：
[root@node1 ~]# docker tag registry.aliyuncs.com/google_containers/kube-apiserver:v1.15.11 k8s.gcr.io/kube-apiserver:v1.15.11
[root@node1 ~]# docker tag registry.aliyuncs.com/google_containers/kube-proxy:v1.15.11 k8s.gcr.io/kube-proxy:v1.15.11
[root@node1 ~]# docker tag registry.aliyuncs.com/google_containers/kube-scheduler:v1.15.11 k8s.gcr.io/kube-scheduler:v1.15.11
[root@node1 ~]# docker tag registry.aliyuncs.com/google_containers/kube-controller-manager:v1.15.11 k8s.gcr.io/kube-controller-manager:v1.15.11
[root@node1 ~]# docker tag registry.aliyuncs.com/google_containers/coredns:1.3.1 k8s.gcr.io/coredns:1.3.1
[root@node1 ~]# docker tag registry.aliyuncs.com/google_containers/etcd:3.3.10 k8s.gcr.io/etcd:3.3.10
[root@node1 ~]# docker tag registry.aliyuncs.com/google_containers/pause:3.1 k8s.gcr.io/pause:3.1
#最后docker save保存镜像，传送至需要安装master的机器上，进行docker load导入
[root@node2 /download/k8s/k8s/k8star]# for i in `ls .`;do docker load -i $i;done  #注：在所有镜像目录下进行导入
--------pull k8s镜像和重打标签脚本----------
#!/bin/sh
#
Repository="192.168.15.200:8888"
Project="k8s"
Kubernetes_domain="k8s.gcr.io"

#batch docker pull
function pull_k8s_FromAliyun(){
	kubeadm config images pull --image-repository=registry.aliyuncs.com/google_containers --kubernetes-version=v1.15.11 	
}

function untag_k8s_FromAliyun(){
	aliyun=(`docker image ls | grep aliyuncs | awk '{ sub(/\ +/,":"); print $1}' | sort`) #error point
	google=(`docker image ls | grep aliyuncs | awk '{ sub(/\ +/,":"); print $1}' | awk -F '/' '{print "k8s.gcr.io/"$3}' | sort`)
	let k8s_sum=${#aliyun[@]}-1
	for i in `seq 0 ${k8s_sum}`;do
		docker tag ${aliyun[$i]} ${google[$i]}
	done
	[ $? == 0 ] && echo "tag aliyun name to google name successful" || echo "tag aliyun to google failure"
}

#batch docker tag 
function tag_ToPriRegistry(){
	for i in `docker image ls  | grep registry | grep -v REPOSITORY | awk '{ sub(/\ +/,":"); print $1}' `;do docker tag $i ${Repository}/${Project}/${Kubernetes_domain}/`echo ${i} | awk -F '/' '{print $3}'`;done
}

#batch docker push
function push_ToPriRegistry(){
	for i in `docker image ls  | grep 192 | grep -v REPOSITORY | awk '{ sub(/\ +/,":"); print $1}'`;do docker push $i;done
}

function pull_FromPriRegistry(){
	docker pull 192.168.15.200:8888/k8s/k8s.gcr.io/coredns:1.3.1
	docker pull 192.168.15.200:8888/k8s/k8s.gcr.io/pause:3.1
	docker pull 192.168.15.200:8888/k8s/k8s.gcr.io/kube-scheduler:v1.15.11
	docker pull 192.168.15.200:8888/k8s/k8s.gcr.io/kube-proxy:v1.15.11
	docker pull 192.168.15.200:8888/k8s/k8s.gcr.io/kube-controller-manager:v1.15.11
	docker pull 192.168.15.200:8888/k8s/k8s.gcr.io/kube-apiserver:v1.15.11
	docker pull 192.168.15.200:8888/k8s/k8s.gcr.io/etcd:3.3.10
}

#batch docker untag
function untag_FromPriRegisty(){
	list1=(`docker image ls  | grep 192 | grep -v REPOSITORY | awk '{ sub(/\ +/,":"); print $1}' | sort`)
	list2=(`docker image ls  | grep 192 | grep -v REPOSITORY | awk '{ sub(/\ +/,":"); print $1}' | sort | sed 's#192.168.15.200\:8888\/k8s\/##g'`)
	let sum=${#list1[@]}-1
	for i in `seq 0 ${sum}`;do
		docker tag ${list1[$i]} ${list2[$i]}
	done
}

case $1 in
	pull_k8s_FromAliyun)
		pull_k8s_FromAliyun;;
	untag_k8s_FromAliyun)
		untag_k8s_FromAliyun;;
	tag_ToPriRegistry)
		tag_ToPriRegistry;;
	push_ToPriRegistry)
		push_ToPriRegistry;;
	pull_FromPriRegistry)
		pull_FromPriRegistry;;
	untag_fromPriRegisty)
		untag_FromPriRegisty;;
	*)
		echo "Usage: $0 (pull_k8s_FromAliyun | untag_k8s_FromAliyun | tag_ToPriRegistry | push_ToPriRegistry | pull_FromPriRegistry | untag_FromPriRegisty)"
esac
----------------------
注：主要使用pull_k8s和tag_k8s两个方法
注：以上两个方法执行完后，一定要检查下tag和源镜像是否打错，本人就是吃了这个亏，scheduler打成了controller manater，最终导致master节点无法运行scheduler和controller manater两个容器，一直是create状态，虽然集群初始化成功，但是未正常工作，使用kubectl get cs scheduler和controller manater两个状态是不正常的。从而导致其他节点无法加入集群。
----------------------


#生成默认配置文件
[root@node1 /download/k8s/k8s]# kubeadm config print init-defaults > kubeadm-config.yaml
#配置默认配置文件，一定要保留好，以后证书时间设置需要用到此文件
------------------
[root@node1 /download/k8s/k8s]# cat kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta2
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.0123456789abcdef
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 192.168.15.201
  bindPort: 6443
nodeRegistration:
  criSocket: /var/run/dockershim.sock
  name: node1
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
---
apiServer:
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta2
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controlPlaneEndpoint: "192.168.15.50:6444"
controllerManager: {}
dns:
  type: CoreDNS
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: k8s.gcr.io
kind: ClusterConfiguration
kubernetesVersion: v1.15.11
networking:
  dnsDomain: cluster.local
  podSubnet: "10.244.0.0/16"
  serviceSubnet: 10.96.0.0/12
scheduler: {}
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
featureGates:
  SupportIPVSProxyMode: true
mode: ipvs
------------------
需要改的注解：
advertiseAddress: 192.168.15.201 #本节点的ip
bindPort: 6443 #本节点apiserver的端口
controlPlaneEndpoint: "192.168.15.50:6444" #增加此行，设定keepalived+haproxy的vip及负载均衡端口地址，用于调度后端的APIserver。第一台k8s MASTER开始安装时，haproxy调度只能调度本机一台机器，因为调度多台可能会导致调度到不存在的端口，从而失败。
imageRepository: k8s.gcr.io #之前我们下载镜像、重打标签并装载进docker了，所以这里千万不要更改，使用默认google的gcr地址。
kubernetesVersion: v1.15.11 #版本号一定要更改为跟自己匹配的镜像版本号
podSubnet: "10.244.0.0/16" #增加此行设置flannel网络子网
注：如果上面是开启ipvs的配置，如果不需要删除即可，则是默认iptables
注：也可以编辑kube-system名称空间下的kube-proxy configmap，将mode设为ipvs，然后让kube-system名称空间下的kube-proxy pod都重载下配置，重载就是将pod都删除，daemonSet控制器都会重启pod
注：下面是查看是否使用了ipvs而不是iptables
[root@node1 /download/k8s]# kubectl logs kube-proxy-g65tj -n kube-system | grep ipvs
I0625 13:25:52.361403       1 server_others.go:170] Using ipvs Proxier.
------------------
#第一台k8s MASTER进行安装
[root@salt /download/k8s]# kubeadm init --config=kubeadm-config.yaml --experimental-upload-certs | tee kubeadm-init.log
注：新版本为--upload-certs-----kubeadm init --config=kubeadm-config.yaml --upload-certs | tee kubeadm-init.log
----安装成功后如下
To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of the control-plane node running the following command on each as root:

  kubeadm join 192.168.15.50:6444 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:9549817d04057b1e29f03d1a51a6106bfcb828b438c53f90b7c35f20e5c929fa \
    --control-plane --certificate-key 964d6ebbd7b271d61ab2c68449423d4bfcdfd2b17866b8b53a983e671047aadb

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use 
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.15.50:6444 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:9549817d04057b1e29f03d1a51a6106bfcb828b438c53f90b7c35f20e5c929fa 

注：当安装不成功时，则只能重装系统，因为安装时有好多文件生成，你删除/etc/kubernetes/*和/var/lib/etcd/*下的所有东西后、systemctl stop kubelet、删除运行的容器后重新安装还是不行。所以我重装安装后才能成功。
------------------
#node2和node3加入集群为MASTER(基础配置跟node1一样)
注1：此时keepalived和haproxy可以先不运行，使用node1的keepalived和haproxy，当多个node成功加入集群为Master后再运行起来也可以。如果非要运行则haproxy.cfg需要跟node1配置一样，不能开启未运行的节点和端口反向代理。
注2：node2和node3两个节点加入集群成为MASTER角色时，不是用kubeadm init方式，而是Kubeadm join方式加入，切记方式忽弄错，否则一旦加错，则此节点只能重装机器重新配置才能安装，否则会加入集群失败。
#node2:
[root@node2 /download/k8s]# kubeadm join 192.168.15.50:6444 --token abcdef.0123456789abcdef     --discovery-token-ca-cert-hash sha256:9549817d04057b1e29f03d1a51a6106bfcb828b438c53f90b7c35f20e5c929fa     --control-plane --certificate-key 964d6ebbd7b271d61ab2c68449423d4bfcdfd2b17866b8b53a983e671047aadb
#node3:
[root@node3 /download/k8s]# kubeadm join 192.168.15.50:6444 --token abcdef.0123456789abcdef     --discovery-token-ca-cert-hash sha256:9549817d04057b1e29f03d1a51a6106bfcb828b438c53f90b7c35f20e5c929fa     --control-plane --certificate-key 964d6ebbd7b271d61ab2c68449423d4bfcdfd2b17866b8b53a983e671047aadb
------------------
#安装网络组件flannel(work节点加入集群后会自动安装flannel)
[root@node2 /download/k8s]# wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
[root@node2 /download/k8s]# kubectl apply -f kube-flannel.yml 
[root@node3 /download/ha]# kubectl get nodes
NAME    STATUS   ROLES    AGE   VERSION
node1   Ready    master   82m   v1.15.11
node2   Ready    master   29m   v1.15.11
node3   Ready    master   23m   v1.15.11
#查看controller-manager的状态信息
[root@node3 /download/ha]# kubectl get endpoints kube-controller-manager --namespace=kube-system -o yaml
apiVersion: v1
kind: Endpoints
metadata:
  annotations:
    control-plane.alpha.kubernetes.io/leader: '{"holderIdentity":"node2_43c667f7-d1eb-49be-baa5-f88d71a7c8e6","leaseDurationSeconds":15,"acquireTime":"2020-06-24T11:45:04Z","renewTime":"2020-06-24T12:15:39Z","leaderTransitions":1}'
  creationTimestamp: "2020-06-24T10:51:16Z"
  name: kube-controller-manager
  namespace: kube-system
  resourceVersion: "7570"
  selfLink: /api/v1/namespaces/kube-system/endpoints/kube-controller-manager
  uid: 0e28b751-9867-48ef-ab10-e1cbc8cc105c
注：现在工作在node2节点上
#查看scheduler的状态信息
[root@node3 /download/ha]# kubectl get endpoints kube-scheduler --namespace=kube-system -o yaml
apiVersion: v1
kind: Endpoints
metadata:
  annotations:
    control-plane.alpha.kubernetes.io/leader: '{"holderIdentity":"node2_54b65e54-e505-4c12-8985-1fa7ef2236bc","leaseDurationSeconds":15,"acquireTime":"2020-06-24T11:45:03Z","renewTime":"2020-06-24T12:16:49Z","leaderTransitions":1}'
  creationTimestamp: "2020-06-24T10:51:16Z"
  name: kube-scheduler
  namespace: kube-system
  resourceVersion: "7685"
  selfLink: /api/v1/namespaces/kube-system/endpoints/kube-scheduler
  uid: 727eb8b7-cdc6-46f0-8090-5e79dcdc2f3e
注：现在工作在node2节点上
#查看etcd的状态信息
[root@node3 /download/ha]# kubectl -n kube-system exec etcd-node1 -- etcdctl --endpoints=https://192.168.15.201:2379 --ca-file=/etc/kubernetes/pki/etcd/ca.crt --cert-file=/etc/kubernetes/pki/etcd/server.crt --key-file=/etc/kubernetes/pki/etcd/server.key cluster-health
member 50b740923d05ad3a is healthy: got healthy result from https://192.168.15.203:2379
member 6862af6d9efd7585 is healthy: got healthy result from https://192.168.15.201:2379
member ce4e0edfb72b5c96 is healthy: got healthy result from https://192.168.15.202:2379
cluster is healthy
注：集群是健康的。其中etcd-node1和https://192.168.15.201:2379这两个节点必须在线，否则会执行出错。例如node3不在线，则你可以使用组合：etcd-node1他https://192.168.15.202:2379 或 etcd-node2他https://192.168.15.201:2379,就是不能有etcd-node3或https://192.168.15.203:2379其中一个。


#k8s工作节点离线加入k8s集群
#安装kube组件工具(离线安装，因为不需要最新的版本，要求安装1.15.11版本)
[root@master /download]# yum localinstall kubeadm-1.15.11-0.x86_64.rpm kubelet-1.15.11-0.x86_64.rpm kubernetes-cni-0.8.6-0.x86_64.rpm cri-tools-1.13.0-0.x86_64.rpm kubectl-1.15.11-0.x86_64.rpm -y
#确保docker Cgroup Driver是systemd
[root@master /download]# docker info | grep group
 Cgroup Driver: systemd  
#kubelet加入开机启动
[root@master /download]# systemctl enable kubelet 
#本地导入kube-proxy和pause镜像(因为无法访问gcr)
[root@master /download]# docker load -i kube-proxy.tgz
[root@master /download]# docker load -i pause.tgz
#节点加入集群，角色为node
[root@master /download]# kubeadm join 192.168.15.50:6444 --token abcdef.0123456789abcdef --discovery-token-ca-cert-hash sha256:9549817d04057b1e29f03d1a51a6106bfcb828b438c53f90b7c35f20e5c929fa  
#此时node节点还不是Ready状态，因为flanel配置清单中是DaemonSet控制器，所以过一会自动在node上把pause(flanel需要)镜像pull下来然后运行flanel pod
[root@node2 /download/k8s]# kubectl get nodes 
NAME     STATUS     ROLES    AGE    VERSION
master   NotReady   <none>   107s   v1.15.11
node1    Ready      master   102m   v1.15.11
node2    Ready      master   49m    v1.15.11
node3    Ready      master   43m    v1.15.11
#过一会节点已经是Ready状态
[root@node3 /download/k8s]# kubectl get nodes
NAME     STATUS   ROLES    AGE    VERSION
master   Ready    <none>   30m    v1.15.11
node1    Ready    master   130m   v1.15.11
node2    Ready    master   77m    v1.15.11
node3    Ready    master   71m    v1.15.11

#k8s节点删除及加入
[root@node2 /download/ha]# kubectl get nodes
NAME    STATUS   ROLES    AGE   VERSION
node1   Ready    master   16h   v1.15.11
node2   Ready    master   17m   v1.15.11
node3   Ready    master   15h   v1.15.11
[root@node2 ~]# kubectl drain node3 --delete-local-data --ignore-daemonsets #删除node2之前先驱赶上面支持的pod
[root@node2 ~]# kubectl get nodes
NAME    STATUS                     ROLES    AGE   VERSION
node1   Ready                      master   16h   v1.15.11
node2   Ready                      master   18m   v1.15.11
node3   Ready,SchedulingDisabled   master   15h   v1.15.11
[root@node2 ~]# kubectl delete node node3
node "node3" deleted
[root@node3 /download/ha]# kubeadm reset #重置状态
[root@node3 /download/ha]# iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
[root@node3 /download/ha]# ipvsadm --clear
[root@node3 /download/ha]# rm -rf /root/.kube
[root@node3 /download/ha]# rm -rf /etc/kubernetes/*
#重新生成work节点加入命令
[root@node2 ~]# kubeadm token create --print-join-command 
kubeadm join 192.168.15.55:6444 --token k9v7p7.samwp1kekt8p25ff     --discovery-token-ca-cert-hash sha256:7ceff99c998bcd4806f16367c52748ebfcc78724d5f698f169996eb6d221320e 
#生成master节点加入集群需要的证书key
[root@node2 ~]# kubeadm init phase upload-certs --experimental-upload-certs
Flag --experimental-upload-certs has been deprecated, use --upload-certs instead
[upload-certs] Using certificate key:
431cc4152d1368bf954e948662d8a31a0bf6162901e68d3b99ab3e9fb76e593e
#结合前面两条输出结果组成master节点加入的命令
[root@node3 /download/ha]# kubeadm join 192.168.15.55:6444 --token k9v7p7.samwp1kekt8p25ff     --discovery-token-ca-cert-hash sha256:7ceff99c998bcd4806f16367c52748ebfcc78724d5f698f169996eb6d221320e --experimental-control-plane --certificate-key 431cc4152d1368bf954e948662d8a31a0bf6162901e68d3b99ab3e9fb76e593e
-----报错
[check-etcd] Checking that the etcd cluster is healthy
error execution phase check-etcd: etcd cluster is not healthy: context deadline exceeded
  
#上面加入集群遇到etcd还保留着node3的信息问题解决步骤：
1. docker exec -it $(docker ps -f name=etcd_etcd -q) /bin/sh #在其它正常master进入容器
2. etcdctl --endpoints "https://127.0.0.1:2379"  --ca-file /etc/kubernetes/pki/etcd/ca.crt --cert-file /etc/kubernetes/pki/etcd/server.crt --key-f
ile /etc/kubernetes/pki/etcd/server.key member list #查看etcd列表
1b56951a47da77b8: name=node2 peerURLs=https://192.168.15.202:2380 clientURLs=https://192.168.15.202:2379 isLeader=false
6862af6d9efd7585: name=node1 peerURLs=https://192.168.15.201:2380 clientURLs=https://192.168.15.201:2379 isLeader=false
c239ad0101f8f817: name=node3 peerURLs=https://192.168.15.203:2380 clientURLs=https://192.168.15.203:2379 isLeader=true
------------------------
注：上面第一步和第二步可用这一条命令使用
[root@node2 ~]# kubectl -n kube-system exec etcd-node1 -- etcdctl --endpoints=https://192.168.15.201:2379 --ca-file=/etc/kubernetes/pki/etcd/ca.crt --cert-file=/etc/kubernetes/pki/etcd/server.crt --key-file=/etc/kubernetes/pki/etcd/server.key member list
6862af6d9efd7585: name=node1 peerURLs=https://192.168.15.201:2380 clientURLs=https://192.168.15.201:2379 isLeader=true
7b57aaeb162ecae9: name=node2 peerURLs=https://192.168.15.202:2380 clientURLs=https://192.168.15.202:2379 isLeader=false
c239ad0101f8f817: name=node3 peerURLs=https://192.168.15.203:2380 clientURLs=https://192.168.15.203:2379 isLeader=false
------------------------
3.[root@node2 ~]# kubectl -n kube-system exec etcd-node1 -- etcdctl --endpoints=https://192.168.15.201:2379 --ca-file=/etc/kubernetes/pki/etcd/ca.crt --cert-file=/etc/kubernetes/pki/etcd/server.crt --key-file=/etc/kubernetes/pki/etcd/server.key member remove c239ad0101f8f817 #删除node3
Removed member c239ad0101f8f817 from cluster
4. [root@node2 ~]# kubectl -n kube-system exec etcd-node1 -- etcdctl --endpoints=https://192.168.15.201:2379 --ca-file=/etc/kubernetes/pki/etcd/ca.crt --cert-file=/etc/kubernetes/pki/etcd/server.crt --key-file=/etc/kubernetes/pki/etcd/server.key member list
6862af6d9efd7585: name=node1 peerURLs=https://192.168.15.201:2380 clientURLs=https://192.168.15.201:2379 isLeader=true
7b57aaeb162ecae9: name=node2 peerURLs=https://192.168.15.202:2380 clientURLs=https://192.168.15.202:2379 isLeader=false
5. [root@node3 /download/ha]# kubeadm join 192.168.15.55:6444 --token k9v7p7.samwp1kekt8p25ff     --discovery-token-ca-cert-hash sha256:7ceff99c998bcd4806f16367c52748ebfcc78724d5f698f169996eb6d221320e --experimental-control-plane --certificate-key 431cc4152d1368bf954e948662d8a31a0bf6162901e68d3b99ab3e9fb76e593e --ignore-preflight-errors=all #重新加入集群为master，如果遇到卡住，请查看本机是否能下正常访问join的ip地址和端口
6. [root@node3 /download/k8s]# mkdir -p $HOME/.kube
7. [root@node3 /download/k8s]# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
8. [root@node3 /download/k8s]# sudo chown $(id -u):$(id -g) $HOME/.kube/config
9. [root@node3 /download/ha]# kubectl get nodes #node3已经正常
NAME    STATUS   ROLES    AGE   VERSION
node1   Ready    master   17h   v1.15.11
node2   Ready    master   29m   v1.15.11
node3   Ready    master   48s   v1.15.11
#注：其中偶然遇到node3节点NotReady状态，是因为node3无法访问192.168.15.55:6444导致，重启下haproxy和keepalived以及网络就好了
[root@node3 /download/ha]# kubectl -n kube-system exec etcd-node1 -- etcdctl --endpoints=https://192.168.15.201:2379 --ca-file=/etc/kubernetes/pki/etcd/ca.crt --cert-file=/etc/kubernetes/pki/etcd/server.crt --key-file=/etc/kubernetes/pki/etcd/server.key cluster-health
member 1ce832bb521e7a92 is healthy: got healthy result from https://192.168.15.203:2379
member 6862af6d9efd7585 is healthy: got healthy result from https://192.168.15.201:2379
member 7b57aaeb162ecae9 is healthy: got healthy result from https://192.168.15.202:2379
cluster is healthy
#注:当你有3个master节点，要删除node1时，该删除的操作已经删除了，此时假如你误操作了，把node3进行：kubectl delete node node3了。这时你:kubectl get nodes则只会看到一个节点:node2，此是etcd中还存在着node2和node3的信息，只是前端看不到node3了，所以集群没有故障。你此时应将node1尽快设为master，然后就可以看到node1和node2为master节点了。至于node3让其像node1一样重新加入集群为master节点即可(集群中至少于需要两个etcd信息存活)。集群也没有问题

#注：当三个MASTER中有一个Master关机时，则检查etcd时显示集群已经被降级，而且调度有时会调度到挂的机器上，则需要更改~/.kube/config配置文件中的Server地址或者开启Haproxy的端口检查，当第二个Master关机时，则仅存活的一个Master无法提供服务，说明你的集群挂了(要是机器关机，则重启即可，要是破坏性故障，则整个集群挂了)。k8s高可用集群最少3台，可容一台故障，如果三台其中两台都故障，则表明你的k8s集群已经挂了，记住，只能容错一个MASTER故障。


###k8s证书过期处理
reference:http://www.mamicode.com/info-detail-2575653.html
--说明
  一般正常安装k8s集群，集群证书的有效期是一年，包括以下证书：
    - apiserver
    - apiserver-kubelet-client
    - apiserver-etcd-client
    - front-proxy-client
    - etcd/server
    - etcd/peer
    - etcd/healthcheck-client
--证书过期问题解决办法：
对于手动生成的证书
    手动安装过程中，只需指定证书的过期时间为N天即可
对于kubeadm
    方式一：升级K8S集群，自动更新证书
    方式二：修改kubeadm并重新编译
    方式三：重新生成证书
证书报错信息：
    [root@k8s-master03 ~]# kubectl get po
    Unable to connect to the server: x509: certificate has expired or is not yet valid
#查看证书有效期
[root@node1 /etc/kubernetes/pki]# openssl x509 -in apiserver.crt -text -noout
 Not Before: Jun 25 13:24:57 2020 GMT
 Not After : Jun 25 13:24:58 2021 GMT
[root@node1 /etc/kubernetes/pki]# openssl x509 -in ca.crt -text -noout
Not Before: Jun 25 13:24:57 2020 GMT
Not After : Jun 23 13:24:57 2030 GMT
#步骤：
我们使用方式二，把kubeadm源码下下来修改后重新编译即可。
去go语言中文社区下载安装包：https://studygolang.com/
[root@master /download]# axel -n 30 https://studygolang.com/dl/golang/go1.14.4.linux-amd64.tar.gz
[root@master /download]# tar xf go1.14.4.linux-amd64.tar.gz -C /usr/local/
[root@master /usr/local]# echo 'PATH=$PATH:/usr/local/go/bin' > /etc/profile.d/go.sh
[root@master /usr/local]# . /etc/profile
[root@master /usr/local]# go version
go version go1.14.4 linux/amd64
#克隆k8s的项目
#github太慢，用下面码云上镜像的。官方：git clone https://github.com/kubernetes/kubernetes.git
[root@master /download]# git clone https://gitee.com/mirrors/Kubernetes.git
[root@master /download]# cd Kubernetes/
[root@master /download/Kubernetes]# kubeadm version #查看当前版本
kubeadm version: &version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.11", GitCommit:"d94a81c724ea8e1ccc9002d89b7fe81d58f89ede", GitTreeState:"clean", BuildDate:"2020-03-12T21:06:11Z", GoVersion:"go1.12.17", Compiler:"gc", Platform:"linux/amd64"}
#我们这里使用的k8s是v1.15.11的，所以我们切换这个分支
[root@master /download/Kubernetes]# git checkout -b remotes/origin/release-1.15.11 v1.15.11
Checking out files: 100% (18052/18052), done.
Switched to a new branch 'remotes/origin/release-1.15.11'
#修改kubenets源码包更新证书策略
#第一个地方
[root@master /download/Kubernetes]# vim staging/src/k8s.io/client-go/util/cert/cert.go
func NewSelfSignedCACert(cfg Config, key crypto.Signer) (*x509.Certificate, error) {
        now := time.Now()
        tmpl := x509.Certificate{
                SerialNumber: new(big.Int).SetInt64(0),
                Subject: pkix.Name{
                        CommonName:   cfg.CommonName,
                        Organization: cfg.Organization,
                },
                NotBefore:             now.UTC(),
                NotAfter:              now.Add(duration365d * 10).UTC(), #这里把10年调大为100年，即为duration365d * 100
                KeyUsage:              x509.KeyUsageKeyEncipherment | x509.KeyUsageDigitalSignature | x509.KeyUsageCertSign,
                BasicConstraintsValid: true,
                IsCA:                  true,
        }

#第二地方（以后版本如果不一样，需要查看开发者手册）
[root@master /download/Kubernetes]# vim cmd/kubeadm/app/constants/constants.go
      // TempDirForKubeadm defines temporary directory for kubeadm
        // should be joined with KubernetesDir.
        TempDirForKubeadm = "tmp"

        // CertificateValidity defines the validity for all the signed certificates generated by kubeadm
        CertificateValidity = time.Hour * 24 * 365 #调整为 time.Hour * 24 * 365 * 100
#然后编译，这里只编译kubeadm，由于编译太慢和网络原因我没有弄了。
[root@master /download/Kubernetes]# make WHAT=cmd/kubeadm GOFLAGS=-v 
#如果本地没有环境，则可以用这个镜像进行编译
[root@master /download/Kubernetes]# docker pull gcrcontainer/kube-cross:v1.13.5-1
[root@master /download/Kubernetes]# docker run --rm -it -v /download/Kubernetes
:/go/src/k8s.io/kubernetes gcrcontainer/kube-cross:v1.13.5-1
--进入容器执行编译
cd /go/src/k8s.io/kubernetes
make all WHAT=cmd/kubeadm GOFLAGS=-v
#编译成功后kubeadm执行文件在_output/bin/kubeadm，替换掉正在使用的kubeadm
--先备份之前的kubeadm
mv -ar /usr/bin/kubeadm{,.bak}
--复制新的kubeadm执行文件
cp -ar _output/bin/kubeadm /usr/bin/kubeadm
chmod +x /usr/bin/kubeadm
--备份现在的pki目录证书文件
cp -ar /etc/kubernetes/pki{,.bak}
--生成新证书
kubeadm alpha certs renew all --config=/download/k8s/kubeadm-config.yaml #指定集群安装时的配置文件，这个配置文件一定要保存好，否则生成证书不了
注：当生成好后自己会生成证书在/etc/kubernetes/pki目录中，直接去检查时效就好
#检查证书到期时间
kubeadm alpha certs check-expiration

##kubeadm alpha phase kubeconfig all --config kubeadm-config.yaml 这个是重新生成配置文件，可不执行。

#--------使用脚本将kubeadm的证书延长至10年
REFERENCE:https://github.com/luckylucky421/kubernetes1.17.3
将这个项目clone下来或者将update-kubeadm-cert.sh脚本下下来，在所有master上执行./update-kubeadm-cert.sh all即可。

#方式一：升级K8S集群，自动更新证书
kubeadm config view >> kube-config.yaml  #保存原配置
yum list all --showduplicates | grep kubeadm #查看所有kubeadm版本
yum install -y --showduplicates kubeadm-1.15.12  #安装升级目标版本
kubeadm upgrade plan  #查看升级计划
kubeadm config images pull --image-repository=registry.aliyuncs.com/google_containers --kubernetes-version=v1.15.12 #下载升级目标版本k8s套件
docker tag registry.aliyuncs.com/google_containers/kube-apiserver:v1.15.12 k8s.gcr.io/kube-apiserver:v1.15.12 #将从阿里云下载的版本打标记成k8s可以认的镜像，具体哪些版本打标记需看kubeadm upgrade plan升级计划中的详细版本
docker tag registry.aliyuncs.com/google_containers/kube-proxy:v1.15.12 k8s.gcr.io/kube-proxy:v1.15.12
docker tag registry.aliyuncs.com/google_containers/kube-scheduler:v1.15.12 k8s.gcr.io/kube-scheduler:v1.15.12
docker tag registry.aliyuncs.com/google_containers/kube-controller-manager:v1.15.12 k8s.gcr.io/kube-controller-manager:v1.15.12
kubeadm upgrade apply v1.15.12 #应用升级版本
kubeadm upgrade node #升级k8s，升级完成后，kubectl version可以看到server端的版本从v1.15.11变成v1.15.12了
yum install -y kubectl-1.15.12 kubelet-1.15.12  --showduplicates #master安装
systemctl daemon-reload
systemctl restart kubelet
[root@master ~]# kubectl get nodes  #此时可以看到升级版本了，其余master节点跟这个master节点一样升级，node节点只需要安装kubelet新版本并重新启动即可，完成后证书截止日期就变成明年的今天了
NAME     STATUS     ROLES    AGE   VERSION
master   Ready      master   79d   v1.15.12
node1    Ready      <none>   79d   v1.15.12
node2    NotReady   <none>   79d   v1.15.11


</pre>




#单master k8s集群
<pre>
#node1:master
[root@node1 /download/k8s]# kubeadm config print init-defaults > kubeadm-config.yaml
-------------------
[root@node1 /download/k8s]# cat kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta2
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.0123456789abcdef
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 192.168.15.201
  bindPort: 6443
nodeRegistration:
  criSocket: /var/run/dockershim.sock
  name: node1
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
---
apiServer:
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta2
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns:
  type: CoreDNS
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: k8s.gcr.io
kind: ClusterConfiguration
kubernetesVersion: v1.15.11
networking:
  dnsDomain: cluster.local
  podSubnet: "10.244.0.0/16"
  serviceSubnet: 10.96.0.0/12
scheduler: {}
---------------------
[root@node1 /download/k8s]# cat tag.sh  --------pull k8s镜像和重打标签脚本-----见上方-----
[root@node1 /download/k8s]# chmod +x tag.sh 
[root@node1 /download/k8s]# ./tag.sh 
Usage: ./tag.sh (tag | push | untag | pull_k8s | tag_k8s)
[root@node1 /download/k8s]#./tag.sh pull_k8s
[config/images] Pulled registry.aliyuncs.com/google_containers/kube-apiserver:v1.15.11
[config/images] Pulled registry.aliyuncs.com/google_containers/kube-controller-manager:v1.15.11
[config/images] Pulled registry.aliyuncs.com/google_containers/kube-scheduler:v1.15.11
[config/images] Pulled registry.aliyuncs.com/google_containers/kube-proxy:v1.15.11
[config/images] Pulled registry.aliyuncs.com/google_containers/pause:3.1
[config/images] Pulled registry.aliyuncs.com/google_containers/etcd:3.3.10
[config/images] Pulled registry.aliyuncs.com/google_containers/coredns:1.3.1
[root@node1 /download/k8s]# ./tag.sh tag_k8s
tag aliyun name to google name successful
[root@node1 /download/k8s]# docker image ls
REPOSITORY                                                        TAG                 IMAGE ID            CREATED             SIZE
registry.aliyuncs.com/google_containers/kube-proxy                v1.15.11            7cd3972af624        3 months ago        82.5MB
k8s.gcr.io/kube-proxy                                             v1.15.11            7cd3972af624        3 months ago        82.5MB
k8s.gcr.io/kube-apiserver                                         v1.15.11            0eaa5e1d871a        3 months ago        207MB
registry.aliyuncs.com/google_containers/kube-apiserver            v1.15.11            0eaa5e1d871a        3 months ago        207MB
k8s.gcr.io/kube-controller-manager                                v1.15.11            4d53b9ec5d96        3 months ago        159MB
registry.aliyuncs.com/google_containers/kube-controller-manager   v1.15.11            4d53b9ec5d96        3 months ago        159MB
k8s.gcr.io/kube-scheduler                                         v1.15.11            e671c2a84bb9        3 months ago        81.2MB
registry.aliyuncs.com/google_containers/kube-scheduler            v1.15.11            e671c2a84bb9        3 months ago        81.2MB
k8s.gcr.io/coredns                                                1.3.1               eb516548c180        17 months ago       40.3MB
registry.aliyuncs.com/google_containers/coredns                   1.3.1               eb516548c180        17 months ago       40.3MB
k8s.gcr.io/etcd                                                   3.3.10              2c4adeb21b4f        19 months ago       258MB
registry.aliyuncs.com/google_containers/etcd                      3.3.10              2c4adeb21b4f        19 months ago       258MB
k8s.gcr.io/pause                                                  3.1                 da86e6ba6ca1        2 years ago         742kB
registry.aliyuncs.com/google_containers/pause                     3.1                 da86e6ba6ca1        2 years ago         742kB
#注：1. 如果本机开启了swap,则需要设置kubelet忽略swap，不然kubelet不能启动，则kubeadm无法调用kubelet则无法正常进行。忽略swap:
	[root@node1 /download/kubernetes]# cat /etc/sysconfig/kubelet 
	KUBELET_EXTRA_ARGS="--fail-swap-on=false"
	2. 在kubeadm安装时需要添加忽略swap选项：
	[root@node1 /download/kubernetes]# kubeadm init --config=kubeadm-config.yaml --upload-certs --ignore-preflight-errors=swap | tee kubeadm-init.log

[root@node1 /download/k8s]# kubeadm init --config=kubeadm-config.yaml --upload-certs | tee kubeadm-init.log
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.15.201:6443 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:1dfc3e7d6d450204f7a7580c27d75dcd809ca64ae417141334f126061a9c62a7 
[root@node1 /download/k8s]# mkdir -p $HOME/.kube
[root@node1 /download/k8s]# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
[root@node1 /download/k8s]# sudo chown $(id -u):$(id -g) 
$HOME/.kube/config
[root@node1 /download/k8s]# kubectl apply -f kube-flannel.yml 
podsecuritypolicy.policy/psp.flannel.unprivileged created
clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
serviceaccount/flannel created
configmap/kube-flannel-cfg created
daemonset.apps/kube-flannel-ds-amd64 created
daemonset.apps/kube-flannel-ds-arm64 created
daemonset.apps/kube-flannel-ds-arm created
daemonset.apps/kube-flannel-ds-ppc64le created
daemonset.apps/kube-flannel-ds-s390x created

#node2:node
[root@node2 /download/k8s]# yum localinstall -y *.rpm
[root@node2 /download/k8s]# systemctl enable kubelet.service
[root@node2 /download/k8s]# docker pull 192.168.15.200:8888/k8s/k8s.gcr.io/kube-proxy:v1.15.11
[root@node2 /download/k8s]# docker pull 192.168.15.200:8888/k8s/k8s.gcr.io/pause:3.1
[root@node2 /download/k8s]# docker tag 192.168.15.200:8888/k8s/k8s.gcr.io/kube-proxy:v1.15.11 k8s.gcr.io/kube-proxy:v1.15.11
[root@node2 /download/k8s]# docker tag 192.168.15.200:8888/k8s/k8s.gcr.io/pause:3.1 k8s.gcr.io/pause:3.1
[root@node2 /download/k8s]# kubeadm join 192.168.15.201:6443 --token abcdef.0123456789abcdef \
>     --discovery-token-ca-cert-hash sha256:1dfc3e7d6d450204f7a7580c27d75dcd809ca64ae417141334f126061a9c62a7


</pre>