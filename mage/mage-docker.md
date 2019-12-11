#马哥docker
<pre>
-----------
安装docker-compose:
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
-----------

1.容器隔离什么：
UTS:主机名和域名
IPC:共享内存，消息队列
Mount:挂载点
PID：进程
Network:网络
User:用户和组
注意：从内核3.8以后可以隔离上述6点。

名称空间：NameSpaces
切换根：chroot
控制组：controlgroups

LXC:LinuX Container (Linux容器)

容器编排工具：
docker的：machine+swarm+compose
mesos+marathon
kubernetes:k8s  #占据了80%以上的份额

google创建了一个容器：libcontainer-->runC
Docker社区版变名为Moby
google成立了容器组织：CNCF

docker+k8s

仓库名+标签等于镜像名，例：nginx:1.10
latest为最新标签，stable为最新稳定版

#docker的安装：
清华大学镜像站：https://mirrors.tuna.tsinghua.edu.cn/
wget https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/docker-ce.repo #下载docker-ce镜像
https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/7/x86_64/stable/Packages/  #这个是清华大学docker的包rpm路径
刚才下载的docker-ce是从dockerhub上下载的，太慢，所以把yum文件中的dockerhub的路径换成上面的rpm路径，如：
https://download.docker.com/全部换成https://mirrors.tuna.tsinghua.edu.cn/docker-ce/即可
[root@lamp yum.repos.d]# yum install docker-ce -y  #安装 
docker的主配置文件是json格式的配置文件，位于/etc/docker/daemon.json,默认不存在，可以新建，也可以运行docker的时候生成这个配置文件

docker镜像加速器：
1.docker cn  2.阿里云加速器  3. 中国科技大学
使用docker镜像加速器：
vim /etc/docker/daemon.json #添加下面的镜像即可
{
    "registry-mirrors": ["https://registry.docker-cn.com"] #json格式的数组，可以添加多个镜像加速器
}

[root@lamp yum.repos.d]# docker info
[root@lamp yum.repos.d]# docker version
alpine:构建最小镜像的版本，但没有调试工具
[root@lamp yum.repos.d]# docker image pull nginx:1.14-alpine
[root@lamp yum.repos.d]# docker image ls
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
nginx               1.14-alpine         66952fd0a8ef        8 weeks ago         16MB
#busybox可以当做很多很多的命令使用。所有命令都是busybox的别名
[root@lamp yum.repos.d]# docker pull busybox
[root@lamp yum.repos.d]# docker container ls
[root@lamp yum.repos.d]# docker network ls  #查看网络类型
NETWORK ID          NAME                DRIVER              SCOPE
b31695e0f952        bridge              bridge              local
27d08a79e849        host                host                local
8b51cdace047        none                null                local

[root@lamp yum.repos.d]# docker run --name b1 -it busybox:latest
[root@lamp yum.repos.d]# docker run  --name redis1 -d redis:4-alpine
[root@lamp yum.repos.d]# docker ps
[root@lamp yum.repos.d]# docker exec -it redis1 /bin/sh

#Docker镜像管理
分层构建机制：1.底层bootfs  2.上层rootfs
[root@lamp yum.repos.d]# docker info
Storage Driver: overlay2 #overlay2，这个是支持docker分层构建的文件系统
 Backing Filesystem: xfs
非常著名的开源软件做docker私有仓库：harbor
公有docker仓库：docker hub、quay.io

#手动构建镜像
[root@lamp yum.repos.d]# docker run --name busy -it busybox:latest /bin/sh
[root@lamp ~]# docker commit -p busy  #-p为暂停制作镜像，制作镜像时容器必须是运行的状态
sha256:57bfc146aedd034161e6576848148cba3152868228c199c999c98c34f6e62932
[root@lamp ~]# docker image ls
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
<none>              <none>              57bfc146aedd        8 seconds ago       1.2MB
redis               4-alpine            83944736833a        5 weeks ago         35.5MB
busybox             latest              d8233ab899d4        6 weeks ago         1.2MB
nginx               1.14-alpine         66952fd0a8ef        8 weeks ago         16MB
[root@lamp ~]# docker tag 57bfc146aedd jack/nginx:v1
[root@lamp ~]# docker image ls
REPOSITORY          TAG                 IMAGE ID            CREATED              SIZE
jack/nginx          v1                  57bfc146aedd        About a minute ago   1.2MB
redis               4-alpine            83944736833a        5 weeks ago          35.5MB
busybox             latest              d8233ab899d4        6 weeks ago          1.2MB
nginx               1.14-alpine         66952fd0a8ef        8 weeks ago          16MB
[root@lamp ~]# docker image rm jack/nginx:v1
Untagged: jack/nginx:v1
Deleted: sha256:57bfc146aedd034161e6576848148cba3152868228c199c999c98c34f6e62932
Deleted: sha256:cf73b3daaf935c97f27501df298c95cfefb14456dc5d0e203b0ff8bedef353a4
[root@lamp ~]# docker image ls
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
redis               4-alpine            83944736833a        5 weeks ago         35.5MB
busybox             latest              d8233ab899d4        6 weeks ago         1.2MB
nginx               1.14-alpine         66952fd0a8ef        8 weeks ago         16MB
[root@lamp ~]# docker inspect nginx:1.14-alpine  #查看镜像或容器底层信息

docker commit -p -c CMD ["/bin/httpd","-f","-h","/data/html"] busybox jack/httpd:v2 #基于容器构建镜像并指定默认指令，仓库名为jack/httpd:v2，要跟自己的docker hub帐户一模一样
docker login -u jack  #先登录用户才能推送镜像。
docker push httpd:v2  #推送镜像到docker hub或者第三方公司docker仓库
也可以推送到阿里云的：容器镜像服务
[root@lamp ~]# cat /etc/docker/daemon.json #添加阿里云加速器
{
    "registry-mirrors": ["https://vpnp9nso.mirror.aliyuncs.com","https://registry.docker-cn.com"]
}
[root@lamp ~]# docker tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]
docker logout #登出
docker login --username=username registry.cn-shanghai.aliyuncs.com
[root@lamp ~]# docker tag busybox:latest registry.cn-shanghai.aliyuncs.com/jackli-nginx/httpd:v1  #为镜像打标签成其他名称
[root@lamp ~]# docker push registry.cn-shanghai.aliyuncs.com/jackli-nginx/httpd:v1   #推送镜像到阿里云
docker save #导出镜像
docker load #导入镜像

brige-utils:brctl
yum install brige-utils
brctl show
OVS:OpenVSwitch(linux第三方开源软件),SDN(软件驱动网络)
Overlay Network(叠加网络)
User,Mount,Pid容器间隔离，UTS,Net,IPC容器间共享

docker image
docker container
docker network

#docker的网络管理
[root@lamp ~]# rpm -qa | grep iproute
iproute-4.11.0-14.el7.x86_64

[root@lamp ~]# ip netns add r1
[root@lamp ~]# ip netns add r2
[root@lamp ~]# ip netns list
[root@lamp ~]# ip link add name veth1.1 type veth peer name veth1.2
[root@lamp ~]# ip netns  exec r1 ifconfig -a
lo: flags=8<LOOPBACK>  mtu 65536
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
[root@lamp ~]# docker network list
NETWORK ID          NAME                DRIVER              SCOPE
b31695e0f952        bridge              bridge              local
27d08a79e849        host                host                local
8b51cdace047        none                null                local
[root@lamp ~]# docker run --name b1 -it --network bridge -h t1.magedu.com busybox
/ # hostname
t1.magedu.com
[root@lamp ~]# docker run --name busy2 --rm -it --network container:busy busybox:latest #网络共享（net,uts,ipc共享），用户空间，挂载，和pid不共享
#如何更改docker0桥服务地址：
vim /etc/docker/daemon.json
[root@lamp ~]# cat /etc/docker/daemon.json
{
    "registry-mirrors": ["https://vpnp9nso.mirror.aliyuncs.com","https://registry.docker-cn.com"],
    "bip": "10.0.0.1/24",  #添加ip地址段
}
用docker客户端管理其他docker server:
vim /etc/docker/daemon.json
 "hosts": ["tcp://0.0.0.0:2375","unix:///var/run/docker.sock"] #开启守护进程，Server Version: 18.09.4 设置有问题


[root@lamp docker]# systemctl reset-failed docker
[root@lamp docker]# systemctl start docker
Network: bridge host macvlan null overlay #常用的 bridge host null 3种网络模式
[root@lamp docker]# docker network create --subnet "10.10.10.1/24" -d bridge mybg #创建一个bridge桥
[root@lamp docker]# docker network rm mybr #删除一个网络桥
[root@lamp docker]# docker run --name t3 -it --net mybr busybox:latest
[root@lamp docker]# docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
87d81d6b8ba8        bridge              bridge              local
27d08a79e849        host                host                local
3a7a26dc5f1c        mybr                bridge              local
8b51cdace047        none                null                local
[root@lamp yum.repos.d]# docker inspect -f {{.Mounts}} b2 #查看卷的挂载，最开始是.开头，为json格式 
[{volume 495f80a775edf91f24e661aa592a3245b2914d32ca441d593cf3ee16cb63d357 /var/lib/docker/volumes/495f80a775edf91f24e661aa592a3245b2914d32ca441d593cf3ee16cb63d357/_data /data local  true }] 
 

共享网络，共享存储卷，
nginx和tomcat联合工作

Dockerfile:
[root@lamp ~]# cat Dockerfile
#from Images
FROM busybox:latest
MAINTAINER "jackli5689@gmail.com" #维护信息
#LABEL maintainer="jackli5689@gmail.com" #维护信息
ENV DOC_ROOT=/data/web/html \  #定义变量
    WEB_SERVER_PACKAGE='nginx-1.14.2.tar.gz'
COPY index.html ${DOC_ROOT:-/data/web/html/}
COPY yum.repos.d /etc/yum.repos.d/
ADD http://nginx.org/download/nginx-1.14.2.tar.gz /usr/local/src/ #只会下载tar.gz文件到目录中
ADD ${WEB_SERVER_PACKAGE} /usr/local/src/ #把文件添加到目录中并解压
WORKDIR /usr/local/src  #指定当前的目录
ADD nginx-1.14.2.tar.gz ./ #添加并解压到当前目录
VOLUME /data/mysql/  #挂载容器卷到宿主机随机目录下
EXPOSE 11211/udp 223/tcp  #指定要暴露对外的端口，默认是tcp端口，当指定-大P指令时才真暴露
RUN yum -y install epel-release && yum makecache && yum install nginx && yum clean all     #在build中执行的命令
CMD  /bin/sh    #指定在run时执行的默认命令
ENTRYPOINT   #这个命令跟CMD一样，只是这个命令不会被用户手动指定的命令覆盖，如果非要被用户覆盖可以在docker run时指定--entrypoint
注意：如果CMD和ENTRYPOINT一起使用时，CMD会被参数给ENTRYPOINT使用，在使用命令时一定要用双引号括起来使用，不能使用单引号来使用
HEALTHCHECK     #健康检查，--start-period=3s表示运行3秒后开始检查，--timeout=30s超时30s为不正常，interval=30s每间隔30s检查一次，--retries=3重试3次后确定是否成功
HEALTHCHECK --start-period=3s --timeout=30s interval=30s --retries=3 CMD wget -O - -q http://${IP:-0.0.0.0}:${PORT:-80}/ || exit 1
ARG     #在build时可以使用build-arg传变量，在运行容器时可以使用env来传变量
ONBUILD wget https://www.baidu.com   #当Dockerfile使用ONBUILD时，别人以你这个Dockerfile生成的镜像为基础镜像时，都会执行ONBUILD后面的指令    

docker build -t tinyhttpd:v0.1 . #在Dockerfile目录下运行此命令构建镜像

[root@lamp ~]# docker run --name tiny1 --rm tinyhttpd:v0.1 printenv #打印变量 
Dockerfile中的环境变量在build时已经执行了，在run时可以改变环境变量，只会改变变量值不会影响Dockerfile的变量，加-e时可指定变量

RUN和CMD中使用中括号时，不会产生子shell，直接使用RUN和CMD加命令时会产生子shell,要想使用中括号时产生子shell可以加"/bin/sh","-c".例如：CMD ["/bin/sh","-c","/bin/httpd -f -h /data/web/html/"]

[root@lamp ~]# echo $@ ls # $@为后面的参数
ls
exec $@ /usr/sbin/httpd -g "daemon off" #将/usr/sbin/httpd -g "daemon off"以子shell的第一个进程执行，


#docker的私有仓库，Harbor
registry默认是支持https的
如果要让docker客户端支持http协议，可以告诉docker这个私有仓库为不安全的，设置daemon.json文件：
vim /etc/docker/daemon.json
"insecure-registries": ["node02.magedu.com:5000"]  #加入这行指定不安全的私有仓库

docker-registrise #docker私有仓库
docker-compose  #docker编排工具，读取compose的文件的

#harbor安装和启动
wget https://storage.googleapis.com/harbor-releases/release-1.7.0/harbor-offline-installer-v1.7.4.tgz #在github上下载offline的harbor
[root@lamp download]# tar xf harbor-offline-installer-v1.7.4.tgz -C /usr/local/
[root@lamp download]# cd /usr/local/
[root@lamp harbor]# ls
common                          docker-compose.yml    LICENSE
docker-compose.chartmuseum.yml  harbor.cfg            open_source_license
docker-compose.clair.yml        harbor.v1.7.4.tar.gz  prepare
docker-compose.notary.yml       install.sh
#harbor.v1.7.4.tar.gz是docker-compose.yml中所需要的镜像
[root@lamp harbor]# vim harbor.cfg
hostname = lamp.jack.com
ui_url_protocol = http
max_job_workers = 2   #并发工作进程数，为cpu个数
ssl_cert = /data/cert/server.crt #公钥放哪
ssl_cert_key = /data/cert/server.key  
secretkey_path = /data #公钥放哪
admiral_url = NA  #定义管理url
log_rotate_size = 200M  #大于200M就要日志滚动
harbor_admin_password = Harbor12345  #管理默认密码
db_host = postgresql
db_password = root123

[root@lamp harbor]# ./install.sh

[Step 0]: checking installation environment ...

Note: docker version: 18.09.4
âœ– Need to install docker-compose(1.7.1+) by yourself first and run this script again.   #需要安装docker-compose(1.7.1+)
[root@lamp harbor]# yum install docker-compose.noarch   -y
[root@lamp harbor]# ./install.sh  #再次执行安装
[root@lamp harbor]# ss -tnl
State      Recv-Q Send-Q Local Address:Port               Peer Address:Port     
LISTEN     0      128    127.0.0.1:9000                     *:*                 
LISTEN     0      128    127.0.0.1:1514                     *:*                 
LISTEN     0      128          *:111                      *:*
LISTEN     0      128          *:22                       *:*
LISTEN     0      128         :::111                     :::*
LISTEN     0      128         :::80                      :::*
LISTEN     0      128         :::22                      :::*
LISTEN     0      128         :::443                     :::*
LISTEN     0      128         :::4443                    :::*
vim /etc/docker/daemon.json
"insecure-registries": ["lamp.jack.com"]  #加入这行指定不安全的私有仓库
harbor脚本执行是执行docker-compose create和docker-compose start的
如果要停止harbor，需要在docker-compose.yml的目录下执行docker-compose stop，这个指令是去找docker-compose.yml这个文件去停止相关的容器的
启动则是 docker-compose start 
暂停是docker-compose pause  #unpause为恢复

#docker的资源限制及验证
在docker run时可以调OOM优先级

限制内存：-m参数为限制ram物理内存，--memory-swap来设置虚拟内存，必须先设置ram后才能设置swap
ram值为数值加b,k,m,G单位组成数值。
当swap值为-1时，则容器swap值为物理机所有swap大小。当swap值为unset时，则容器的swap大小为容器ram内存的2倍。当swap值为0时等同于unset。当swap值为正值时，则可用的swap内存为swap内存减去ram所剩的内存大小

限制CPU:--cpus=2为限制cpu核数
lorel/docker-stress-ng这个镜像用来做资源测试
--cpus=2
--cpu-shares 1024 的 --cpu-shares 512 共用物理cpu大小，为2:1
--oom-kill-disable 为关闭oom的kill功能，代表这个容器再怎么吃资源都不会被kill掉
--oom-score-adj -1000 #值为-1000到1000,数值越低代表越不容易被kill掉


注意：运行容器时使用普通用户，不要使用root用户运行。容器运行时尽量指定使用资源，以免代码导致的问题使系统资源被无尽占用。
</pre>