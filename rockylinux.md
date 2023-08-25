# RockyLinux



## 系统安装

跟安装CentOS7一样，步骤略

```bash
[root@prometheus02 yum.repos.d]# cat /etc/rocky-release
Rocky Linux release 9.2 (Blue Onyx)
[root@prometheus02 ~]# hostnamectl set-hostname prometheus02
[root@prometheus02 ~]# timedatectl set-timezone Asia/Shanghai
```



## 网卡名称更改

```bash
[root@prometheus02 ~]# cat /etc/default/grub 
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M rd.lvm.lv=rl/root net.ifnames=0 biosdevname=0"
GRUB_DISABLE_RECOVERY="true"
GRUB_ENABLE_BLSCFG=true

[root@prometheus02 ~]# grub2-mkconfig -o /boot/grub2/grub.cfg
[root@prometheus02 ~]# reboot
```



## 网络配置

```bash
[root@prometheus02 system-connections]# systemctl enable NetworkManager
[root@prometheus02 system-connections]# pwd
/etc/NetworkManager/system-connections
[root@prometheus02 system-connections]# cat eth0.nmconnection 
[connection]				# connection配置
id=eth0						# connection id
uuid=31bbdaf8-a3d4-456c-b93e-3b608abaa28b
type=ethernet				# device type为ethernet
autoconnect-priority=-999
interface-name=eth0			# device名称

[ethernet]

[ipv4]
method=manual				# ip获取方式为manual，还可为auto
address1=192.168.13.237/24,192.168.13.254	# ip地址
address2=192.168.0.31/24
dns=192.168.10.250;192.168.10.110;			# dns配置，以`;`结尾

[ipv6]
addr-gen-mode=eui64
method=auto

[proxy]
---
# 装载配置
[root@prometheus02 system-connections]# nmcli c load /etc/NetworkManager/system-connections/eth0.nmconnection 
# 激活连接
[root@prometheus02 system-connections]# nmcli c up /etc/NetworkManager/system-connections/eth0.nmconnection

# 查看状态信息
[root@prometheus02 system-connections]# nmcli d status
DEVICE  TYPE      STATE                   CONNECTION 
eth0    ethernet  connected               eth0       
lo      loopback  connected (externally)  lo         
[root@prometheus02 system-connections]# nmcli c show
NAME  UUID                                  TYPE      DEVICE 
eth0  31bbdaf8-a3d4-456c-b93e-3b608abaa28b  ethernet  eth0   
lo    30af657b-b6f3-4460-a9e3-497eb0900fe9  loopback  lo     
[root@prometheus02 system-connections]# ip a s eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:50:56:84:a7:84 brd ff:ff:ff:ff:ff:ff
    altname enp11s0
    altname ens192
    inet 192.168.13.237/24 brd 192.168.13.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::250:56ff:fe84:a784/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
```



## yum源配置

```bash
# 配置rocky源使用阿里云
[root@prometheus02 yum.repos.d]# sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.aliyun.com/rockylinux|g' \
    -i.bak \
    /etc/yum.repos.d/rocky*.repo

[root@prometheus02 yum.repos.d]# ll
total 44
-rw-r--r--. 1 root root 2081 Aug 22 11:22 docker-ce.repo
-rw-r--r--. 1 root root 6604 Aug 22 11:09 rocky-addons.repo
-rw-r--r--. 1 root root 6586 Apr 27 13:35 rocky-addons.repo.bak
-rw-r--r--. 1 root root 1164 Aug 22 11:09 rocky-devel.repo
-rw-r--r--. 1 root root 1161 Apr 27 13:35 rocky-devel.repo.bak
-rw-r--r--. 1 root root 2385 Aug 22 11:09 rocky-extras.repo
-rw-r--r--. 1 root root 2379 Apr 27 13:35 rocky-extras.repo.bak
-rw-r--r--. 1 root root 3414 Aug 22 11:09 rocky.repo
-rw-r--r--. 1 root root 3405 Apr 27 13:35 rocky.repo.bak


# 安装epel源
[root@prometheus02 yum.repos.d]# dnf install -y https://mirrors.aliyun.com/epel/epel-release-latest-9.noarch.rpm
[root@prometheus02 yum.repos.d]# sed -i 's|^#baseurl=https://download.example/pub|baseurl=https://mirrors.aliyun.com|' /etc/yum.repos.d/epel*
[root@prometheus02 yum.repos.d]# sed -i 's|^metalink|#metalink|' /etc/yum.repos.d/epel*

[root@prometheus02 yum.repos.d]# dnf makecache
```



## 安装docker

rocky linux 安装docker建议最新版，老版本会有问题
```bash
[root@prometheus02 yum.repos.d]# curl -L -o docker-ce.repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
[root@prometheus02 yum.repos.d]# sudo dnf install -y yum-utils
[root@prometheus02 yum.repos.d]# dnf install --showduplicates docker-ce-3:20.10.24-3.el9.x86_64
[root@prometheus02 yum.repos.d]# cat /etc/docker/daemon.json
{
	"registry-mirrors": ["http://hub-mirror.c.163.com","https://docker.mirrors.ustc.edu.cn","https://registry.docker-cn.com"],
	"insecure-registries": ["http://192.168.13.235:8000","http://192.168.13.197:8000","harbor.hs.com","harborrepo.hs.com"],
	"log-driver":"json-file",
	"log-opts": {"max-size":"500m", "max-file":"3"}
}
[root@prometheus02 yum.repos.d]# systemctl start docker-ce
[root@prometheus02 yum.repos.d]# systemctl enable docker-ce
[root@prometheus02 yum.repos.d]# docker info 
Client: Docker Engine - Community
 Version:    24.0.5
 Context:    default
 Debug Mode: false
 Plugins:
  buildx: Docker Buildx (Docker Inc.)
    Version:  v0.11.2
    Path:     /usr/libexec/docker/cli-plugins/docker-buildx
  compose: Docker Compose (Docker Inc.)
    Version:  v2.20.2
    Path:     /usr/libexec/docker/cli-plugins/docker-compose

Server:
 Containers: 0
  Running: 0
  Paused: 0
  Stopped: 0
 Images: 0
 Server Version: 20.10.24
 Storage Driver: overlay2
  Backing Filesystem: xfs
  Supports d_type: true
  Native Overlay Diff: true
  userxattr: false
 Logging Driver: json-file
 Cgroup Driver: systemd
 Cgroup Version: 2
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local logentries splunk syslog
 Swarm: inactive
 Runtimes: io.containerd.runtime.v1.linux runc io.containerd.runc.v2
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: 8165feabfdfe38c65b599c4993d227328c231fca
 runc version: v1.1.8-0-g82f18fe
 init version: de40ad0
 Security Options:
  seccomp
   Profile: default
  cgroupns
 Kernel Version: 5.14.0-284.25.1.el9_2.x86_64
 Operating System: Rocky Linux 9.2 (Blue Onyx)
 OSType: linux
 Architecture: x86_64
 CPUs: 8
 Total Memory: 15.37GiB
 Name: prometheus02
 ID: ZRRR:DOCG:OYWM:BBGC:EQRL:RQAL:VVMM:6G57:3WMM:5YLM:U56S:RSQU
 Docker Root Dir: /var/lib/docker
 Debug Mode: false
 Experimental: false
 Insecure Registries:
  192.168.13.197:8000
  192.168.13.235:8000
  harbor.hs.com
  harborrepo.hs.com
  127.0.0.0/8
 Registry Mirrors:
  http://hub-mirror.c.163.com/
  https://docker.mirrors.ustc.edu.cn/
  https://registry.docker-cn.com/
 Live Restore Enabled: false
```



## 安装配置openvpn 

```bash
[root@prometheus02 ~]# dnf install -y openvpn 

# 连接vpn
/usr/bin/expect << EOF
set timeout 10
spawn /usr/sbin/openvpn --config /etc/openvpn/client/client.conf
expect {
"*Username*" { send "$USER\n"; exp_continue }
"*Password*" { send "$PASSWORD\n"; exp_continue }
}
expect eof
EOF

```



## 迁移prometheus

```bash
groupadd -r prometheus && useradd -r -s /sbin/nologin -g prometheus prometheus

[root@prometheus02 shell]# systemctl cat prometheus.service 
# /usr/lib/systemd/system/prometheus.service
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/prometheus/prometheus \
--config.file /usr/local/prometheus/prometheus.yml \
--storage.tsdb.path /data/prometheus/ \
--storage.tsdb.retention.time=180d \
--storage.tsdb.retention.size=200GB \
--storage.tsdb.wal-compression \
--web.external-url=http://192.168.13.237:9090 \
--web.enable-admin-api \
--web.enable-lifecycle \
--web.page-title=homsom
Restart=on-failure

[Install]
WantedBy=multi-user.target
###


# 配置权限 
chown -R prometheus.prometheus /data/prometheus /usr/local/prometheus-2.33.5.linux-amd64

# 启动grafana-server
systemctl start prometheus
systemctl enable prometheus

```





## 迁移grafana-server



安装二进制版本grafana-enterprise-7.1.4

```bash
wget https://dl.grafana.com/enterprise/release/grafana-enterprise-7.1.4.linux-amd64.tar.gz
tar -zxvf grafana-enterprise-7.1.4.linux-amd64.tar.gz -C /usr/local

[root@prometheus02 local]# ls grafana-7.1.4/
bin  conf  data  LICENSE  NOTICE.md  plugins-bundled  public  README.md  scripts  VERSION


# 查看老版本环境变量，并复制到新服务器中
[root@prometheus02 local]# cat /etc/sysconfig/grafana-server 
GRAFANA_USER=grafana

GRAFANA_GROUP=grafana

GRAFANA_HOME=/usr/local/grafana

LOG_DIR=/var/log/grafana

DATA_DIR=/var/lib/grafana

MAX_OPEN_FILES=10000

CONF_DIR=/etc/grafana

CONF_FILE=/etc/grafana/grafana.ini

RESTART_ON_UPGRADE=true

PLUGINS_DIR=/var/lib/grafana/plugins

PROVISIONING_CFG_DIR=/etc/grafana/provisioning

# Only used on systemd systems
PID_FILE_DIR=/var/run/grafana
###


# 复制老版本启动服务文件到新服务器
[root@prometheus02 local]# systemctl cat grafana-server.service 
# /usr/lib/systemd/system/grafana-server.service
[Unit]
Description=Grafana instance
Documentation=http://docs.grafana.org
Wants=network-online.target
After=network-online.target
After=postgresql.service mariadb.service mysqld.service

[Service]
EnvironmentFile=/etc/sysconfig/grafana-server
User=grafana
Group=grafana
Type=notify
Restart=on-failure
WorkingDirectory=/usr/local/grafana
RuntimeDirectory=grafana
RuntimeDirectoryMode=0750
ExecStart=/usr/local/grafana/bin/grafana-server                                                  \
                            --config=${CONF_FILE}                                   \
                            --pidfile=${PID_FILE_DIR}/grafana-server.pid            \
                            --packaging=rpm                                         \
                            cfg:default.paths.logs=${LOG_DIR}                       \
                            cfg:default.paths.data=${DATA_DIR}                      \
                            cfg:default.paths.plugins=${PLUGINS_DIR}                \
                            cfg:default.paths.provisioning=${PROVISIONING_CFG_DIR}  

LimitNOFILE=10000
TimeoutStopSec=20

[Install]
WantedBy=multi-user.target
###


# 配置依赖目录及权限 
groupadd -r grafana && useradd -r -s /sbin/nologin -g grafana grafana
mkdir -p /var/log/grafana /var/lib/grafana 
scp -r /var/lib/grafana prometheus02:/var/lib/grafana
scp -r /etc/grafana prometheus02:/etc/grafana
chown -R grafana.grafana /var/log/grafana /var/lib/grafana /etc/grafana /usr/local/grafana-7.1.4


# 启动grafana-server
systemctl start grafana-server
systemctl enable grafana-server 
```





## 配置alertmanager集群



```bash
[root@prometheus02 kubeasz]# systemctl cat alertmanager.service 
# /usr/lib/systemd/system/alertmanager.service
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/alertmanager/alertmanager --config.file=/usr/local/alertmanager/alertmanager.yml \
--storage.path=/usr/local/alertmanager/data/ --web.external-url=http://192.168.13.237:9093 \
--cluster.listen-address=0.0.0.0:8001 --cluster.peer=192.168.13.236:8001 --log.level=warn --log.format=json
Restart=on-failure

[Install]
WantedBy=multi-user.target


[root@prometheus02 kubeasz]# head -n 50 /usr/local/prometheus/prometheus.yml 
global:
  scrape_interval: 30s
  evaluation_interval: 30s
  scrape_timeout: 30s

alerting:
  alertmanagers:
  - static_configs:
    - targets:
      - '192.168.13.236:9093'
      - '192.168.13.237:9093'
      - '192.168.13.235:9093'
......
```

