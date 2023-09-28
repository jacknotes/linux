# lvs部署




## 环境


```bash
test-lvs01			172.168.2.31
test-lvs02			172.168.2.32
test-lvs-VIP		172.168.2.33	172.168.2.36
test-nginx01		172.168.2.34
test-nginx02		172.168.2.35
```


## 更新系统

```bash
root@ansible:~# ansible lvs -m shell -a 'yum update -y'
root@ansible:~# ansible lvs -m shell -a 'reboot'
root@ansible:~# ansible lvs -m shell -a 'cat /etc/redhat-release'
172.168.2.31 | SUCCESS | rc=0 >>
CentOS Linux release 7.9.2009 (Core)

172.168.2.34 | SUCCESS | rc=0 >>
CentOS Linux release 7.9.2009 (Core)

172.168.2.32 | SUCCESS | rc=0 >>
CentOS Linux release 7.9.2009 (Core)

172.168.2.35 | SUCCESS | rc=0 >>
CentOS Linux release 7.9.2009 (Core)



root@ansible:~# ansible lvs -m shell -a 'uname -a'
172.168.2.31 | SUCCESS | rc=0 >>
Linux test-lvs01 3.10.0-1160.95.1.el7.x86_64 #1 SMP Mon Jul 24 13:59:37 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux

172.168.2.35 | SUCCESS | rc=0 >>
Linux test-nginx02 3.10.0-1160.95.1.el7.x86_64 #1 SMP Mon Jul 24 13:59:37 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux

172.168.2.32 | SUCCESS | rc=0 >>
Linux test-lvs02 3.10.0-1160.95.1.el7.x86_64 #1 SMP Mon Jul 24 13:59:37 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux

172.168.2.34 | SUCCESS | rc=0 >>
Linux test-nginx01 3.10.0-1160.95.1.el7.x86_64 #1 SMP Mon Jul 24 13:59:37 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux
```


## 查看内核是否支持IPVS

```bash
[root@test-lvs02 ~]# ansible lvs-node -m shell -a "grep -i 'vs' /boot/config-3.10.0-1160.95.1.el7.x86_64"
CONFIG_GENERIC_TIME_VSYSCALL=y
# CONFIG_X86_VSMP is not set
CONFIG_NETFILTER_XT_MATCH_IPVS=m
CONFIG_IP_VS=m
CONFIG_IP_VS_IPV6=y
# CONFIG_IP_VS_DEBUG is not set
CONFIG_IP_VS_TAB_BITS=12
# IPVS transport protocol load balancing support
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_PROTO_AH_ESP=y
CONFIG_IP_VS_PROTO_ESP=y
CONFIG_IP_VS_PROTO_AH=y
CONFIG_IP_VS_PROTO_SCTP=y
# IPVS scheduler
CONFIG_IP_VS_RR=m
CONFIG_IP_VS_WRR=m
CONFIG_IP_VS_LC=m
CONFIG_IP_VS_WLC=m
CONFIG_IP_VS_LBLC=m
CONFIG_IP_VS_LBLCR=m
CONFIG_IP_VS_DH=m
CONFIG_IP_VS_SH=m
CONFIG_IP_VS_SED=m
CONFIG_IP_VS_NQ=m
# IPVS SH scheduler
CONFIG_IP_VS_SH_TAB_BITS=8
# IPVS application helper
CONFIG_IP_VS_FTP=m
CONFIG_IP_VS_NFCT=y
CONFIG_IP_VS_PE_SIP=m
CONFIG_OPENVSWITCH=m
CONFIG_OPENVSWITCH_GRE=m
CONFIG_OPENVSWITCH_VXLAN=m
CONFIG_OPENVSWITCH_GENEVE=m
CONFIG_VSOCKETS=m
CONFIG_VSOCKETS_DIAG=m
CONFIG_VMWARE_VMCI_VSOCKETS=m
CONFIG_VIRTIO_VSOCKETS=m
CONFIG_VIRTIO_VSOCKETS_COMMON=m
CONFIG_HYPERV_VSOCKETS=m
CONFIG_MTD_BLKDEVS=m
CONFIG_SCSI_MVSAS=m
# CONFIG_SCSI_MVSAS_DEBUG is not set
CONFIG_SCSI_MVSAS_TASKLET=y
CONFIG_VMWARE_PVSCSI=m
CONFIG_VSOCKMON=m
CONFIG_VHOST_VSOCK=m
CONFIG_MOUSE_VSXXXAA=m
CONFIG_MAX_RAW_DEVS=8192
# CONFIG_POWER_AVS is not set
CONFIG_USB_SEVSEG=m
```


## 初始化各节点配置

```bash
root@ansible:/etc/ansible/roles# cat ../playbook/base.yml
---
- hosts:
  - 172.168.2.31
  - 172.168.2.32
  - 172.168.2.34
  - 172.168.2.35
  remote_user: root
  become: yes
  gather_facts: true
  roles:
  - base
root@ansible:/etc/ansible/roles# ansible-playbook /etc/ansible/playbook/base.yml


root@ansible:/etc/ansible/roles# cat ../playbook/nginx.yml
---
- hosts:
  - 172.168.2.34
  - 172.168.2.35
  remote_user: root
  become: yes
  gather_facts: true
  roles:
  - nginx
root@ansible:/etc/ansible/roles# ansible-playbook /etc/ansible/playbook/nginx.yml
```



## 集群时间配置

```bash
# 注：各节点之间的时间偏差不应该超出1秒钟
root@ansible:~# ansible lvs -m shell -a 'crontab -l'
172.168.2.32 | SUCCESS | rc=0 >>
#Ansible: timing sync ntp time
*/5 * * * * ntpdate time1.aliyun.com

172.168.2.31 | SUCCESS | rc=0 >>
#Ansible: timing sync ntp time
*/5 * * * * ntpdate time1.aliyun.com

172.168.2.34 | SUCCESS | rc=0 >>
#Ansible: timing sync ntp time
*/5 * * * * ntpdate time1.aliyun.com

172.168.2.35 | SUCCESS | rc=0 >>
#Ansible: timing sync ntp time
*/5 * * * * ntpdate time1.aliyun.com


## 查看当前时间
root@ansible:~# ansible lvs -m shell -a 'date'
172.168.2.31 | SUCCESS | rc=0 >>
Mon Sep 25 16:51:36 CST 2023

172.168.2.35 | SUCCESS | rc=0 >>
Mon Sep 25 16:51:36 CST 2023

172.168.2.34 | SUCCESS | rc=0 >>
Mon Sep 25 16:51:37 CST 2023

172.168.2.32 | SUCCESS | rc=0 >>
Mon Sep 25 16:51:37 CST 2023
```


## IPVS管理工具安装及常用命令

```bash
# IPVS管理工具安装
[root@test-lvs01 ~]# yum install ipvsadm -y
[root@test-lvs02 ~]# yum install ipvsadm -y


# 命令详解
ipvsadm:
	管理集群服务：
		添加：-A -t|u|f service-address [-s scheduler] [-p [timeout]] [-M netmask]	
			-t:tcp
			-u:udp
			-f:防火墙标记
		修改：-E -t|u|f service-address [-s scheduler] [-p [timeout]] [-M netmask]
		删除：-D -t|u|f service-address	
	管理集群服务中的RS:
		添加：-a|e -t|u|f service-address -r server-address [-g|i|m] [-w weight] 
			-t|u|f service-address：事先定义好的某集群服务
			-r server-address：某RS的地址，在NAT模型中，可使用IP:PORT实现端口映射
			[-g|i|m]：lvs类型，-g:DR,-i:TUN,-m:NAT
[-w weight]:定义服务器权重
​		修改：-e
​		删除：-d
​	查看：
​		-L|-l
​			-n: 数字格式显示主机地址和端口
​			--stats：统计数据
​			--rate: 速率
​			--timeout: 显示tcp、tcpfin和udp的会话超时时长
​			-c: 显示当前的ipvs连接状况
​	删除所有集群服务
​		-C：清空ipvs规则
​	保存规则
​		-S 
		# ipvsadm -S > /path/to/somefile
​	载入此前的规则：
​		-R
		# ipvsadm -R < /path/form/somefile


# 常用命令
ipvsadm -Lcn   						#查看LVS上当前的所有连接
cat /proc/net/ip_vs_conn			#查看虚拟服务和RealServer上当前的连接数
ipvsadm -l --stats					#数据包数和字节数的统计值
ipvsadm -l --rate 					#查看包传递速率的近似精确值
ipvsadm -l --timeout 				#查看tcp,tcpfin,udp包超时时间
ipvsadm -S > /tmp/ipvs.save 		#保存ipvs规则
ipvsadm -R < /tmp/ipvs.save 		#载入ipvs规则
ipvsadm -a -t 172.168.2.33:80 -r 172.168.2.34 -g -w 2
ipvsadm -a -t 172.168.2.33:80 -r 172.168.2.35 -g -w 1
```




## LVS+Keepalived高可用HA部署

```bash
arp缓存有效性2-20分钟不等

ifconfig lo:0 172.168.2.33 netmask 255.255.255.255 broadcast 172.168.2.33 up
route add -host 172.168.2.33 dev lo:0

net.ipv4.conf.eth0.arp_ignore = 1
net.ipv4.conf.eth0.arp_announce = 2
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 2

echo 1 > /proc/sys/net/ipv4/conf/eth0/arp_ignore
echo 2 > /proc/sys/net/ipv4/conf/eth0/arp_announce

```


```bash
root@ansible:/etc/ansible/roles# tree lvs-ha/
lvs-ha/
├── keepalived
│   ├── README.md
│   ├── files
│   │   ├── ip_vs.conf
│   │   └── keepalived-2.0.20.tar.gz
│   ├── handlers
│   │   ├── main.yml
│   │   └── reload.yml
│   ├── tasks
│   │   ├── install.yml
│   │   ├── installPackage-centos.yml
│   │   ├── installPackage-ubuntu.yml
│   │   ├── main.yml
│   │   ├── optimal.yml
│   │   └── service.yml
│   └── templates
│       └── keepalived.conf.j2
├── lvs
│   ├── README.md
│   ├── files
│   ├── handlers
│   │   ├── lvs.yml
│   │   └── main.yml
│   ├── tasks
│   │   ├── kernel.yml
│   │   ├── main.yml
│   │   ├── network.yml
│   │   └── optimal.yml
│   └── templates
│       └── ifcfg.j2
└── nginx
    ├── README.md
    ├── files
    │   ├── nginx
    │   │   ├── index.html
    │   │   ├── nginx-1.20.2.tar.gz
    │   │   ├── nginx-init
    │   │   ├── nginx-module-vts-0.1.17.tar.gz
    │   │   ├── nginx.service
    │   │   ├── ngx_http_substitutions_filter_module.tar.gz
    │   │   └── tengine-2.3.2.tar.gz
    │   └── pcre
    │       └── pcre-8.37.tar.gz
    ├── handlers
    │   ├── main.yml
    │   └── restart.yml
    ├── tasks
    │   ├── group.yml
    │   ├── install.yml
    │   ├── installPackage-centos.yml
    │   ├── installPackage-ubuntu.yml
    │   ├── main.yml
    │   ├── service.yml
    │   └── user.yml
    └── templates
        └── nginx.conf.j2


root@ansible:/etc/ansible/roles# tree /etc/ansible/group_vars/ /etc/ansible/host_vars/
/etc/ansible/group_vars/
├── lvs-node.yml
└── lvs.yml
/etc/ansible/host_vars/
├── 172.168.2.31.yml
└── 172.168.2.32.yml


##### group_vars和host_vars文件夹下的变量需要修改，按照需求修改
root@ansible:/etc/ansible/roles# cat /etc/ansible/hosts
[lvs:children]
lvs-node
nginx

[lvs-node]
172.168.2.31
172.168.2.32

[nginx]
172.168.2.34
172.168.2.35


root@ansible:/etc/ansible/roles# cat /etc/ansible/group_vars/lvs.yml
# nginx
groupname: www
groupname_id: 8080
username: www
username_id: 8080
nginx_address: 0.0.0.0
nginx_port: 80

## package info, suffix .tar.gz
pcre_package: pcre-8.37
#nginx_package: nginx-1.20.2
nginx_package: tengine-2.3.2
nginx_module_package01: ngx_http_substitutions_filter_module
nginx_module_package02: nginx-module-vts-0.1.17

# lvs
router_id: LVS01
vrrp_instance: LVS_HA1
auth_pass: tRhtrP2S2UBYy54L7uKkVM5AhodX4w4I
virtual_router_id: 200
virtual_ipaddress: 172.168.2.33
virtual_server_port: 80
real_server01: 172.168.2.34
real_server02: 172.168.2.35
sorry_server: 127.0.0.1

# lvs rs server
LOOPBACK_SUB_INTERFACE: "lo:0"
#####

root@ansible:/etc/ansible/roles# cat /etc/ansible/group_vars/lvs-node.yml
lvs_nginx: 'yes'

root@ansible:/etc/ansible/roles# cat /etc/ansible/host_vars/172.168.2.31.yml
state: MASTER
interface: eth0
priority: 100
root@ansible:/etc/ansible/roles# cat /etc/ansible/host_vars/172.168.2.32.yml
state: BACKUP
interface: eth0
priority: 80


# 应用playbook
root@ansible:/etc/ansible/roles# cat /etc/ansible/playbook/lvs-ha.yml
---
- hosts:
  - 172.168.2.31
  - 172.168.2.32
  remote_user: root
  become: yes
  gather_facts: true
  roles:
  - lvs-ha/keepalived
  - lvs-ha/nginx

- hosts:
  - 172.168.2.34
  - 172.168.2.35
  remote_user: root
  become: yes
  gather_facts: true
  roles:
  - lvs-ha/nginx
  - lvs-ha/lvs

root@ansible:/etc/ansible/roles# ansible-playbook /etc/ansible/playbook/lvs-ha.yml 

```


## 查看LVS集群状态

```bash
root@ansible:/etc/ansible/roles/lvs-ha/nginx# ansible lvs-node -m shell -a 'ip a s '
172.168.2.32 | SUCCESS | rc=0 >>
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:d5:e6:09 brd ff:ff:ff:ff:ff:ff
    inet 172.168.2.32/24 brd 172.168.2.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fed5:e609/64 scope link noprefixroute
       valid_lft forever preferred_lft forever

172.168.2.31 | SUCCESS | rc=0 >>
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:89:e1:6b brd ff:ff:ff:ff:ff:ff
    inet 172.168.2.31/24 brd 172.168.2.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet 172.168.2.33/32 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fe89:e16b/64 scope link noprefixroute
       valid_lft forever preferred_lft forever


root@ansible:/etc/ansible/roles/lvs-ha/nginx# ansible lvs-node -m shell -a 'ipvsadm -ln'
172.168.2.31 | SUCCESS | rc=0 >>
IP Virtual Server version 1.2.1 (size=4096)	# 需要重启ip_vs.conf才生效
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  172.168.2.33:80 rr persistent 5
  -> 172.168.2.34:80              Route   1      0          0
  -> 172.168.2.35:80              Route   1      0          0

172.168.2.32 | SUCCESS | rc=0 >>
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  172.168.2.33:80 rr persistent 5
  -> 172.168.2.34:80              Route   1      0          0
  -> 172.168.2.35:80              Route   1      0          0
  
 
## 重启LVS2台主机后生效
root@ansible:~# ansible lvs-node -m shell -a 'ipvsadm -ln'
172.168.2.32 | SUCCESS | rc=0 >>
IP Virtual Server version 1.2.1 (size=1048576)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  172.168.2.33:80 rr persistent 5
  -> 172.168.2.34:80              Route   1      0          0
  -> 172.168.2.35:80              Route   1      0          0

172.168.2.31 | SUCCESS | rc=0 >>
IP Virtual Server version 1.2.1 (size=1048576)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  172.168.2.33:80 rr persistent 5
  -> 172.168.2.34:80              Route   1      0          0
TCP  172.168.2.33:443 rr persistent 5
  -> 172.168.2.34:443             Route   1      0          0
  -> 172.168.2.35:443             Route   1      1          1


  
## keepalived配置
root@ansible:/etc/ansible/roles/lvs-ha/nginx# ansible lvs-node -m shell -a 'cat /etc/keepalived/keepalived.conf'
172.168.2.31 | SUCCESS | rc=0 >>
! Configuration File for keepalived

global_defs {
   router_id LVS01
}

vrrp_instance LVS_HA1 {
    state MASTER
    interface eth0
    virtual_router_id 200
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass tRhtrP2S2UBYy54L7uKkVM5AhodX4w4I
    }
    virtual_ipaddress {
        172.168.2.33
    }
}

virtual_server 172.168.2.33 80 {
    delay_loop 5
    lb_algo rr
    lb_kind DR
    persistence_timeout 5
    protocol TCP

    sorry_server 127.0.0.1 80

    real_server 172.168.2.34 80 {
        weight 1
        TCP_CHECK {
            connect_port 80
            connect_timeout 2
            retry 3
            delay_before_retry 1
        }
    }

    real_server 172.168.2.35 80 {
        weight 1
        TCP_CHECK {
            connect_port 80
            connect_timeout 2
            retry 3
            delay_before_retry 1
        }
    }
}

172.168.2.32 | SUCCESS | rc=0 >>
! Configuration File for keepalived

global_defs {
   router_id LVS01
}

vrrp_instance LVS_HA1 {
    state BACKUP
    interface eth0
    virtual_router_id 200
    priority 80
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass tRhtrP2S2UBYy54L7uKkVM5AhodX4w4I
    }
    virtual_ipaddress {
        172.168.2.33
    }
}

virtual_server 172.168.2.33 80 {
    delay_loop 5
    lb_algo rr
    lb_kind DR
    persistence_timeout 5
    protocol TCP

    sorry_server 127.0.0.1 80

    real_server 172.168.2.34 80 {
        weight 1
        TCP_CHECK {
            connect_port 80
            connect_timeout 2
            retry 3
            delay_before_retry 1
        }
    }

    real_server 172.168.2.35 80 {
        weight 1
        TCP_CHECK {
            connect_port 80
            connect_timeout 2
            retry 3
            delay_before_retry 1
        }
    }
}



## sorry服务，监听在本地80端口，IPVS的80端口比本地套接字80端口优先级高，因为IPVS工作在内核层，请求到达DR时就被IPVS所纳管
root@ansible:/etc/ansible/roles/lvs-ha/nginx# ansible lvs-node -m shell -a "grep -Ev '#|^$' /usr/local/nginx/conf/nginx.conf"
172.168.2.32 | SUCCESS | rc=0 >>
worker_processes  2;
worker_rlimit_nofile 65535;
events {
        use epoll;
        worker_connections  65535;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    server {
        listen       80;
        server_name  localhost;
        location / {
            root   html;
            index  index.html index.htm;
        }
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
}

172.168.2.31 | SUCCESS | rc=0 >>
worker_processes  2;
worker_rlimit_nofile 65535;
events {
        use epoll;
        worker_connections  65535;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    server {
        listen       80;
        server_name  localhost;
        location / {
            root   html;
            index  index.html index.htm;
        }
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }

[root@test-lvs01 ~]# curl 127.0.0.1
sorry service.

```


## 查看nginx集群状态

```bash
root@ansible:/etc/ansible/roles/lvs-ha/nginx# ansible nginx -m shell -a "ip a s "
172.168.2.35 | SUCCESS | rc=0 >>
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet 172.168.2.33/32 brd 172.168.2.33 scope global lo:0
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:27:16:38 brd ff:ff:ff:ff:ff:ff
    inet 172.168.2.35/24 brd 172.168.2.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fe27:1638/64 scope link noprefixroute
       valid_lft forever preferred_lft forever

172.168.2.34 | SUCCESS | rc=0 >>
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet 172.168.2.33/32 brd 172.168.2.33 scope global lo:0
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:8e:49:1d brd ff:ff:ff:ff:ff:ff
    inet 172.168.2.34/24 brd 172.168.2.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fe8e:491d/64 scope link noprefixroute
       valid_lft forever preferred_lft forever

root@ansible:/etc/ansible/roles/lvs-ha/nginx# ansible nginx -m shell -a "ss -tnl"
172.168.2.34 | SUCCESS | rc=0 >>
State      Recv-Q Send-Q Local Address:Port               Peer Address:Port
LISTEN     0      128          *:80                       *:*
LISTEN     0      128          *:22                       *:*
LISTEN     0      128       [::]:22                    [::]:*

172.168.2.35 | SUCCESS | rc=0 >>
State      Recv-Q Send-Q Local Address:Port               Peer Address:Port
LISTEN     0      128          *:80                       *:*
LISTEN     0      128          *:22                       *:*
LISTEN     0      128       [::]:22                    [::]:*

root@ansible:/etc/ansible/roles/lvs-ha/nginx# ansible nginx -m shell -a "cat /etc/rc.d/rc.local | grep route"
172.168.2.34 | SUCCESS | rc=0 >>
route add -host 172.168.2.33 dev lo:0

172.168.2.35 | SUCCESS | rc=0 >>
route add -host 172.168.2.33 dev lo:0


root@ansible:/etc/ansible/roles/lvs-ha/nginx# ansible nginx -m shell -a "cat /etc/sysctl.conf"
172.168.2.34 | SUCCESS | rc=0 >>
# sysctl settings are defined through files in
# /usr/lib/sysctl.d/, /run/sysctl.d/, and /etc/sysctl.d/.
#
# Vendors settings live in /usr/lib/sysctl.d/.
# To override a whole file, create a new file with the same in
# /etc/sysctl.d/ and put new settings there. To override
# only specific settings, add a file with a lexically later
# name in /etc/sysctl.d/ and put new settings there.
#
# For more information, see sysctl.conf(5) and sysctl.d(5).
net.ipv4.conf.eth0.arp_ignore=1
net.ipv4.conf.eth0.arp_announce=2
net.ipv4.conf.all.arp_ignore=1
net.ipv4.conf.all.arp_announce=2

172.168.2.35 | SUCCESS | rc=0 >>
# sysctl settings are defined through files in
# /usr/lib/sysctl.d/, /run/sysctl.d/, and /etc/sysctl.d/.
#
# Vendors settings live in /usr/lib/sysctl.d/.
# To override a whole file, create a new file with the same in
# /etc/sysctl.d/ and put new settings there. To override
# only specific settings, add a file with a lexically later
# name in /etc/sysctl.d/ and put new settings there.
#
# For more information, see sysctl.conf(5) and sysctl.d(5).
net.ipv4.conf.eth0.arp_ignore=1
net.ipv4.conf.eth0.arp_announce=2
net.ipv4.conf.all.arp_ignore=1
net.ipv4.conf.all.arp_announce=2


root@ansible:/etc/ansible/roles/lvs-ha/nginx# ansible nginx -m shell -a "sysctl -n net.ipv4.conf.eth0.arp_ignore"
172.168.2.35 | SUCCESS | rc=0 >>
1

172.168.2.34 | SUCCESS | rc=0 >>
1
```


## lvs上下线操作


```bash
# 下线某个real_server时需要注释整个real_server配置
[root@test-lvs01 ~]# cat /etc/keepalived/keepalived.conf
! Configuration File for keepalived

global_defs {
   router_id LVS01
}

vrrp_instance LVS_HA1 {
    state MASTER
    interface eth0
    virtual_router_id 200
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass tRhtrP2S2UBYy54L7uKkVM5AhodX4w4I
    }
    virtual_ipaddress {
        172.168.2.33
    }
}

virtual_server 172.168.2.33 80 {
    delay_loop 5
    lb_algo rr
    lb_kind DR
    persistence_timeout 5
    protocol TCP

    sorry_server 127.0.0.1 80

    real_server 172.168.2.34 80 {		# 经过测试，这是第一个real_server，如果注释第一个real_server则本virtual_server下的所有real_server都将不生效
        weight 1
        TCP_CHECK {
            connect_port 80
            connect_timeout 2
            retry 3
            delay_before_retry 1
        }
    }

#    real_server 172.168.2.35 80 {	# 这是第二个real_server，注释第二个real_server将仅影响此real_server，此时第一个real_server是生效的，在最前面使用#或者!也是注释
        weight 1
        TCP_CHECK {
            connect_port 80
            connect_timeout 2
            retry 3
            delay_before_retry 1
        }
    }

}

virtual_server 172.168.2.33 443 {
    delay_loop 5
    lb_algo rr
    lb_kind DR
    persistence_timeout 5
    protocol TCP

    sorry_server 127.0.0.1 80

    real_server 172.168.2.34 443 {
        weight 1
        TCP_CHECK {
            connect_port 80
            connect_timeout 2
            retry 3
            delay_before_retry 1
        }
    }

    real_server 172.168.2.35 443 {
        weight 1
        TCP_CHECK {
            connect_port 80
            connect_timeout 2
            retry 3
            delay_before_retry 1
        }
    }
}

注：为了解决如上注释使用异常问题，可以使用下面的方法：对配置文件进行分段处理
```



## lvs上tcpdump过程解析

```bash
[root@test-lvs02 keepalived]# tcpdump  -i eth0 -nnnn port 80 and host 172.168.2.36
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
15:15:01.800530 IP 172.168.2.219.5686 > 172.168.2.36.80: Flags [S], seq 3520950535, win 64240, options [mss 1460,nop,wscale 8,nop,nop,sackOK], length 0		# 客户端建立连接请求第一次握手到达lvs
15:15:01.800577 IP 172.168.2.219.5686 > 172.168.2.36.80: Flags [S], seq 3520950535, win 64240, options [mss 1460,nop,wscale 8,nop,nop,sackOK], length 0		# lvs将客户端建立连接请求第一次握手的源MAC和目的MAC改成V-MAC和R-MAC
15:15:01.800810 IP 172.168.2.36.80 > 172.168.2.219.5686: Flags [S.], seq 3908883242, ack 3520950536, win 29200, options [mss 1460,nop,nop,sackOK,nop,wscale 7], length 0	# RS接收到客户端第一次建立连接请求，确认第一次握手并发起第二次握手，实际是RS直接跟客户端进行沟通，而没有经过LVS，为什么LVS上抓到了RS的响应包呢？因为RS响应的IP地址是172.168.2.36，我们抓的包是eth0网卡上，所有虚拟机的网络都属于eth0，所以可以看到此包
15:15:01.802449 IP 172.168.2.219.5686 > 172.168.2.36.80: Flags [.], ack 1, win 8212, length 0 #客户端确认连接请求，第三次握手完成
15:15:01.802463 IP 172.168.2.219.5686 > 172.168.2.36.80: Flags [.], ack 1, win 8212, length 0 #lvs转发第三次握手连接请求
15:15:01.805557 IP 172.168.2.219.5686 > 172.168.2.36.80: Flags [P.], seq 1:1125, ack 1, win 8212, length 1124: HTTP: GET /TktCp/main.aspx HTTP/1.1	# 客户端开始发起HTTP请求
15:15:01.805580 IP 172.168.2.219.5686 > 172.168.2.36.80: Flags [P.], seq 1:1125, ack 1, win 8212, length 1124: HTTP: GET /TktCp/main.aspx HTTP/1.1  # lvs转发客户端的HTTP请求
15:15:01.805827 IP 172.168.2.36.80 > 172.168.2.219.5686: Flags [.], ack 1125, win 251, length 0		# RS确认HTTP请求
15:15:01.836772 IP 172.168.2.36.80 > 172.168.2.219.5686: Flags [P.], seq 1:7257, ack 1125, win 251, length 7256: HTTP: HTTP/1.1 200 OK		# RS响应HTTP请求
15:15:01.836782 IP 172.168.2.36.80 > 172.168.2.219.5686: Flags [F.], seq 7257, ack 1125, win 251, length 0	# RS发起连接关闭请求
15:15:01.837666 IP 172.168.2.219.5686 > 172.168.2.36.80: Flags [.], ack 5841, win 8212, length 0	# 客户端确认关闭连接请求
15:15:01.837685 IP 172.168.2.219.5686 > 172.168.2.36.80: Flags [.], ack 5841, win 8212, length 0
15:15:01.847762 IP 172.168.2.36.80 > 172.168.2.219.5686: Flags [F.], seq 7257, ack 1125, win 251, length 0
15:15:01.847995 IP 172.168.2.219.5686 > 172.168.2.36.80: Flags [.], ack 7257, win 8206, length 0
15:15:01.848015 IP 172.168.2.219.5686 > 172.168.2.36.80: Flags [.], ack 7257, win 8206, length 0
15:15:01.869934 IP 172.168.2.219.5686 > 172.168.2.36.80: Flags [.], ack 7258, win 8206, length 0
15:15:01.869980 IP 172.168.2.219.5686 > 172.168.2.36.80: Flags [.], ack 7258, win 8206, length 0

```



## keepalived配置文件分段处理目录及内容
```bash
[root@test-lvs01 keepalived]# tree .
.
├── conf.d
│   ├── real_server
│   │   ├── rs_172.168.2.34_443.conf
│   │   ├── rs_172.168.2.34_80.conf
│   │   ├── rs_172.168.2.35_443.conf
│   │   └── rs_172.168.2.35_80.conf
│   └── virtual_server
│       ├── vs_172.168.2.33_443.conf
│       ├── vs_172.168.2.33_80.conf
│       ├── vs_172.168.2.36_443.conf
│       └── vs_172.168.2.36_80.conf
├── keepalived.conf
└── notify.sh


[root@test-lvs01 keepalived]# cat notify.sh
#!/bin/bash
#
contact='jack.li@homsom.com'
INTERFACE_NAME=`grep interface /etc/keepalived/keepalived.conf | awk '{print $2}' | head -n 1`
#INTERFACE_NAME_IPADDR=`ip a s ${INTERFACE_NAME} | grep 192.168.13.255 | awk -F '/' '{print $1}' | awk '{print $2}'`
INTERFACE_NAME_IPADDR=`ip a s ${INTERFACE_NAME} | grep 172.168.2.255 | awk -F '/' '{print $1}' | awk '{print $2}'`
notify() {
local mailsubject="$(hostname) to be $1, vip floating"
local mailbody="$(date +'%F %T'): vrrp transition, $(hostname)-${INTERFACE_NAME_IPADDR} changed to be $1 for VIP $2"
echo "$mailbody" | mail -s "$mailsubject" $contact
}

case $1 in
master)
        notify master $2
        ;;
backup)
        notify backup $2
        ;;
fault)
        notify fault $2
        ;;
*)
        echo "Usage: $(basename $0) {master|backup|fault} ARG2"
        exit 1
        ;;
esac
---

[root@test-lvs01 keepalived]# cat keepalived.conf
! Configuration File for keepalived

global_defs {
   router_id LVS01
}

vrrp_instance LVS_HA1 {
    state MASTER
    interface eth0
    virtual_router_id 200
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass tRhtrP2S2UBYy54L7uKkVM5AhodX4w4I
    }
    virtual_ipaddress {
        172.168.2.33
    }

    notify_master "/etc/keepalived/notify.sh master 172.168.2.33"
    notify_backup "/etc/keepalived/notify.sh backup 172.168.2.33"
    notify_fault "/etc/keepalived/notify.sh fault 172.168.2.33"
    smtp alter
}

vrrp_instance LVS_HA2 {
    state BACKUP
    interface eth0
    virtual_router_id 201
    priority 80
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass WJ6zRoIcslkgyojnUOUxLdcE9BiZ4Yan
    }
    virtual_ipaddress {
        172.168.2.36
    }

    notify_master "/etc/keepalived/notify.sh master 172.168.2.36"
    notify_backup "/etc/keepalived/notify.sh backup 172.168.2.36"
    notify_fault "/etc/keepalived/notify.sh fault 172.168.2.36"
    smtp alter
}

include conf.d/virtual_server/vs_*.conf
---

[root@test-lvs01 keepalived]# cat conf.d/virtual_server/vs_172.168.2.33_80.conf
virtual_server 172.168.2.33 80 {
    delay_loop 5
    lb_algo rr
    lb_kind DR
    persistence_timeout 600
    protocol TCP

    include ../real_server/rs_172.168.2.34_80.conf
    include ../real_server/rs_172.168.2.35_80.conf
}
[root@test-lvs01 keepalived]# cat conf.d/virtual_server/vs_172.168.2.33_443.conf
virtual_server 172.168.2.33 443 {
    delay_loop 5
    lb_algo rr
    lb_kind DR
    persistence_timeout 600
    protocol TCP

    include ../real_server/rs_172.168.2.34_443.conf
    include ../real_server/rs_172.168.2.35_443.conf
}
[root@test-lvs01 keepalived]# cat conf.d/virtual_server/vs_172.168.2.36_80.conf
virtual_server 172.168.2.36 80 {
    delay_loop 5
    lb_algo rr
    lb_kind DR
    persistence_timeout 600
    protocol TCP

    include ../real_server/rs_172.168.2.34_80.conf
    include ../real_server/rs_172.168.2.35_80.conf
}
[root@test-lvs01 keepalived]# cat conf.d/virtual_server/vs_172.168.2.36_443.conf
virtual_server 172.168.2.36 443 {
    delay_loop 5
    lb_algo rr
    lb_kind DR
    persistence_timeout 600
    protocol TCP

    include ../real_server/rs_172.168.2.34_443.conf
    include ../real_server/rs_172.168.2.35_443.conf
}
---

[root@test-lvs01 keepalived]# cat conf.d/real_server/rs_172.168.2.34_80.conf
real_server 172.168.2.34 80 {
    weight 1
    TCP_CHECK {
        connect_port 80
        connect_timeout 2
        retry 3
        delay_before_retry 1
    }
}
[root@test-lvs01 keepalived]# cat conf.d/real_server/rs_172.168.2.34_443.conf
real_server 172.168.2.34 443 {
    weight 1
    TCP_CHECK {
        connect_port 443
        connect_timeout 2
        retry 3
        delay_before_retry 1
    }
}
[root@test-lvs01 keepalived]# cat conf.d/real_server/rs_172.168.2.35_80.conf
real_server 172.168.2.35 80 {
    weight 1
    TCP_CHECK {
        connect_port 80
        connect_timeout 2
        retry 3
        delay_before_retry 1
    }
}
[root@test-lvs01 keepalived]# cat conf.d/real_server/rs_172.168.2.35_443.conf
real_server 172.168.2.35 443 {
    weight 1
    TCP_CHECK {
        connect_port 443
        connect_timeout 2
        retry 3
        delay_before_retry 1
    }
}
---



root@ansible:~# ansible lvs-node -m shell -a 'ipvsadm -ln'
172.168.2.32 | SUCCESS | rc=0 >>
IP Virtual Server version 1.2.1 (size=1048576)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  172.168.2.33:80 rr persistent 600
  -> 172.168.2.34:80              Route   1      0          0
  -> 172.168.2.35:80              Route   1      0          0
TCP  172.168.2.33:443 rr persistent 600
  -> 172.168.2.34:443             Route   1      0          0
  -> 172.168.2.35:443             Route   1      0          0
TCP  172.168.2.36:80 rr persistent 600
  -> 172.168.2.34:80              Route   1      0          0
  -> 172.168.2.35:80              Route   1      0          0
TCP  172.168.2.36:443 rr persistent 600
  -> 172.168.2.34:443             Route   1      0          0
  -> 172.168.2.35:443             Route   1      0          0

172.168.2.31 | SUCCESS | rc=0 >>
IP Virtual Server version 1.2.1 (size=1048576)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  172.168.2.33:80 rr persistent 600
  -> 172.168.2.34:80              Route   1      0          0
  -> 172.168.2.35:80              Route   1      0          0
TCP  172.168.2.33:443 rr persistent 600
  -> 172.168.2.34:443             Route   1      0          0
  -> 172.168.2.35:443             Route   1      0          0
TCP  172.168.2.36:80 rr persistent 600
  -> 172.168.2.34:80              Route   1      0          0
  -> 172.168.2.35:80              Route   1      0          0
TCP  172.168.2.36:443 rr persistent 600
  -> 172.168.2.34:443             Route   1      0          0
  -> 172.168.2.35:443             Route   1      0          0


root@ansible:~# ansible lvs-node -m shell -a 'ipvsadm -ln --stats'
172.168.2.31 | SUCCESS | rc=0 >>
IP Virtual Server version 1.2.1 (size=1048576)
Prot LocalAddress:Port               Conns   InPkts  OutPkts  InBytes OutBytes
  -> RemoteAddress:Port
TCP  172.168.2.33:80                   353     2387        0   425447        0
  -> 172.168.2.34:80                   169     1211        0   199557        0
  -> 172.168.2.35:80                   184     1176        0   225890        0
TCP  172.168.2.33:443                   14      872        0   293980        0
  -> 172.168.2.34:443                    2       48        0    10137        0
  -> 172.168.2.35:443                   12      824        0   283843        0
TCP  172.168.2.36:80                     0        0        0        0        0
  -> 172.168.2.34:80                     0        0        0        0        0
  -> 172.168.2.35:80                     0        0        0        0        0
TCP  172.168.2.36:443                    0        0        0        0        0
  -> 172.168.2.34:443                    0        0        0        0        0
  -> 172.168.2.35:443                    0        0        0        0        0

172.168.2.32 | SUCCESS | rc=0 >>
IP Virtual Server version 1.2.1 (size=1048576)
Prot LocalAddress:Port               Conns   InPkts  OutPkts  InBytes OutBytes
  -> RemoteAddress:Port
TCP  172.168.2.33:80                     0        0        0        0        0
  -> 172.168.2.34:80                     0        0        0        0        0
  -> 172.168.2.35:80                     0        0        0        0        0
TCP  172.168.2.33:443                    0        0        0        0        0
  -> 172.168.2.34:443                    0        0        0        0        0
  -> 172.168.2.35:443                    0        0        0        0        0
TCP  172.168.2.36:80                   179     1820        0   412976        0
  -> 172.168.2.34:80                    17      115        0    22084        0
  -> 172.168.2.35:80                   162     1705        0   390892        0
TCP  172.168.2.36:443                    8      404        0   154710        0
  -> 172.168.2.34:443                    2       14        0     1632        0
  -> 172.168.2.35:443                    6      390        0   153078        0


[root@test-lvs02 keepalived]# ipvsadm -lnc
IPVS connection entries
pro expire state       source             virtual            destination
TCP 00:08  CLOSE       172.168.2.219:8814 172.168.2.36:80    172.168.2.34:80
TCP 00:08  CLOSE       172.168.2.219:8826 172.168.2.36:80    172.168.2.34:80
TCP 00:09  CLOSE       172.168.2.219:8834 172.168.2.36:80    172.168.2.34:80
TCP 00:08  CLOSE       172.168.2.219:8830 172.168.2.36:80    172.168.2.34:80
TCP 00:08  CLOSE       172.168.2.219:8817 172.168.2.36:80    172.168.2.34:80
TCP 00:08  CLOSE       172.168.2.219:8819 172.168.2.36:80    172.168.2.34:80
TCP 00:09  CLOSE       172.168.2.219:8835 172.168.2.36:80    172.168.2.34:80
TCP 00:08  CLOSE       172.168.2.219:8832 172.168.2.36:80    172.168.2.34:80
TCP 10:00  NONE        172.168.2.219:0    172.168.2.36:80    172.168.2.34:80	#10分钟有效期
TCP 00:08  CLOSE       172.168.2.219:8828 172.168.2.36:80    172.168.2.34:80


[root@test-lvs02 keepalived]# ipvsadm -S > /tmp/ipvs.rule
[root@test-lvs02 keepalived]# cat /tmp/ipvs.rule
-A -t 172.168.2.33:http -s rr -p 600
-a -t 172.168.2.33:http -r 172.168.2.34:http -g -w 1
-a -t 172.168.2.33:http -r 172.168.2.35:http -g -w 1
-A -t 172.168.2.33:https -s rr -p 600
-a -t 172.168.2.33:https -r 172.168.2.34:https -g -w 1
-a -t 172.168.2.33:https -r 172.168.2.35:https -g -w 1
-A -t test-lvs02:http -s rr -p 600
-a -t test-lvs02:http -r 172.168.2.34:http -g -w 1
-a -t test-lvs02:http -r 172.168.2.35:http -g -w 1
-A -t test-lvs02:https -s rr -p 600
-a -t test-lvs02:https -r 172.168.2.34:https -g -w 1
-a -t test-lvs02:https -r 172.168.2.35:https -g -w 1
#[root@test-lvs02 keepalived]# ipvsadm -R < /tmp/ipvs.rule

```



## lvs 1号和2号环境混用场景

```bash
root@ansible:~# ansible lvs-node -m shell -a 'ip a s ;ipvsadm -ln'
172.168.2.31 | SUCCESS | rc=0 >>
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:89:e1:6b brd ff:ff:ff:ff:ff:ff
    inet 172.168.2.31/24 brd 172.168.2.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet 172.168.2.33/32 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fe89:e16b/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
IP Virtual Server version 1.2.1 (size=1048576)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  172.168.2.33:80 rr persistent 600
  -> 172.168.2.35:80              Route   1      2          0
TCP  172.168.2.33:443 rr persistent 600
  -> 172.168.2.35:443             Route   1      0          0
TCP  172.168.2.36:80 rr persistent 600
  -> 172.168.2.35:80              Route   1      0          0
TCP  172.168.2.36:443 rr persistent 600
  -> 172.168.2.35:443             Route   1      0          0

172.168.2.32 | SUCCESS | rc=0 >>
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:d5:e6:09 brd ff:ff:ff:ff:ff:ff
    inet 172.168.2.32/24 brd 172.168.2.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet 172.168.2.36/32 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fed5:e609/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
IP Virtual Server version 1.2.1 (size=1048576)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  172.168.2.33:80 rr persistent 600
  -> 172.168.2.35:80              Route   1      0          0
TCP  172.168.2.33:443 rr persistent 600
  -> 172.168.2.35:443             Route   1      0          0
TCP  172.168.2.36:80 rr persistent 600
  -> 172.168.2.35:80              Route   1      0          0
TCP  172.168.2.36:443 rr persistent 600
  -> 172.168.2.35:443             Route   1      0          0




# /etc/hosts配置
172.168.2.31 配置所有主机头域名指向172.168.2.33
172.168.2.32 配置所有主机头域名指向172.168.2.36
172.168.2.34 配置所有主机头域名指向172.168.2.33
172.168.2.35 配置所有主机头域名指向172.168.2.36

root@ansible:~# ansible lvs -m shell -a 'tail -n 5 /etc/hosts'
172.168.2.32 | SUCCESS | rc=0 >>
172.168.2.36 Insurancerclient.service.hs.com
172.168.2.36 waptest.homsom.com
172.168.2.36 nginx-status.hs.com

172.168.2.31 | SUCCESS | rc=0 >>
172.168.2.33 Insurancerclient.service.hs.com
172.168.2.33 waptest.homsom.com
172.168.2.33 nginx-status.hs.com
172.168.2.33 kuboard.k8s.hs.com

172.168.2.35 | SUCCESS | rc=0 >>
172.168.2.36 Insurancerclient.service.hs.com
172.168.2.36 waptest.homsom.com
172.168.2.36 nginx-status.hs.com

172.168.2.34 | SUCCESS | rc=0 >>
172.168.2.33 Insurancerclient.service.hs.com
172.168.2.33 waptest.homsom.com
172.168.2.33 nginx-status.hs.com
172.168.2.33 kuboard.k8s.hs.com



# 默认VirtualServer指向RealServer服务地址
172.168.2.33 -> 172.168.2.34	# 模拟1号环境
172.168.2.36 -> 172.168.2.35	# 模拟2号环境


# nginx服务器配置的VIP地址
172.168.2.34 -> 配置了172.168.2.33
172.168.2.35 -> 配置了172.168.2.36、172.168.2.33	# 模拟1号和2号环境混用时使用


# 模拟VS 172.168.2.33和172.168.2.36 都指向RS 172.168.2.35，模拟1号和2号环境混用，访问流程如下：
客户端 -> 请求erp.hs.com -> 解析到172.168.2.33:80并请求LVS -> LVS转发请求到RS 172.168.2.35:80(VIP 172.168.2.33:80) -> RS本机通过80端口http协议接收到请求，得知请求头在nginx配置中，则不会去DNS解析（否则将DNS解析主机头并使用本机eth0端口去连接），然后连接后端服务192.168.13.204:80，此时本地连接的地址是eth0网卡的RS地址(172.168.2.35:80) -> 到达192.168.13.204后，查看主机头是本机，结果本机处理请求，并响应信息给172.168.2.35 -> 然后RS封装数据，源IP地址为172.168.2.33，目标地址为172.168.2.219，最终响应给客户端了

```



## lvs nginx配置lvs环境脚本


lvs多VIP脚本

```bash
[root@test-nginx02 shell]# cat lvs_nginx.sh
#!/bin/bash
# lvs for nginx network operation shell.
# author: jackli
# date: 20230927


INTERFACE='lo:'
VIP01='172.168.2.33'
VIP01_INTERFACE="${INTERFACE}0"
VIP02='172.168.2.36'
VIP02_INTERFACE="${INTERFACE}1"
VIP_COUNT='2'
DATETIME='date +"%Y-%m-%d-%H:%M:%S"'


start(){
        sysctl -w net.ipv4.conf.eth0.arp_ignore=1 && \
        sysctl -w net.ipv4.conf.eth0.arp_announce=2 && \
        sysctl -w net.ipv4.conf.all.arp_ignore=1 && \
        sysctl -w net.ipv4.conf.all.arp_announce=2 && \
        ip address add ${VIP01}/32 broadcast ${VIP01} scope global dev ${VIP01_INTERFACE}
        ip address add ${VIP02}/32 broadcast ${VIP02} scope global dev ${VIP02_INTERFACE}
        ip route add ${VIP01}/32 dev ${VIP01_INTERFACE}
        ip route add ${VIP02}/32 dev ${VIP02_INTERFACE}

        if [ $? == 0 ];then
                echo "`${DATETIME}`: [INFO] lvs nginx node newtork start successful."
        else
                echo "`${DATETIME}`: [ERROR] lvs nginx node newtork start failure."
        fi
}


stop(){
        ip route del ${VIP01}/32 dev ${VIP01_INTERFACE}
        ip route del ${VIP02}/32 dev ${VIP02_INTERFACE}
        ip address del ${VIP01}/32 dev ${VIP01_INTERFACE}
        ip address del ${VIP02}/32 dev ${VIP02_INTERFACE}
        sysctl -w net.ipv4.conf.eth0.arp_ignore=0 && \
        sysctl -w net.ipv4.conf.eth0.arp_announce=0 && \
        sysctl -w net.ipv4.conf.all.arp_ignore=0 && \
        sysctl -w net.ipv4.conf.all.arp_announce=0

        if [ $? == 0 ];then
                echo "`${DATETIME}`: [INFO] lvs nginx node newtork stop successful."
        else
                echo "`${DATETIME}`: [ERROR] lvs nginx node newtork stop failure."
        fi
}


restart(){
        stop
        sleep 1
        start
}

status(){
        [ `route -n | grep -E "${VIP01}|${VIP02}" | wc -l` == "${VIP_COUNT}" ] && \
        [ `ip address show ${INTERFACE} | grep -E "${VIP01}|${VIP02}" | wc -l` == "${VIP_COUNT}" ]  && \
        [ `sysctl -n net.ipv4.conf.eth0.arp_ignore` == 1 ] && \
        [ `sysctl -n net.ipv4.conf.eth0.arp_announce` == 2 ] && \
        [ `sysctl -n net.ipv4.conf.all.arp_ignore` == 1 ] && \
        [ `sysctl -n net.ipv4.conf.all.arp_announce` == 2 ]

        if [ $? == 0 ];then
                echo "`${DATETIME}`: [INFO] lvs nginx node newtork is running."
        else
                echo "`${DATETIME}`: [INFO] lvs nginx node newtork is stop."
        fi

}

case "$1" in
        start)
                start;;
        stop)
                stop;;
        restart)
                restart;;
        status)
                status;;
        *)
                echo "Usage: $0 { start | stop | restart | status}"
        ;;

esac
```


lvs单VIP脚本

```bash
[root@test-nginx01 shell]# cat lvs_nginx_33.sh
#!/bin/bash
# lvs for nginx network operation shell.
# author: jackli
# date: 20230927


INTERFACE='lo:'
VIP01='172.168.2.33'
VIP01_INTERFACE="${INTERFACE}0"
VIP_COUNT='1'
DATETIME='date +"%Y-%m-%d-%H:%M:%S"'


start(){
        sysctl -w net.ipv4.conf.eth0.arp_ignore=1 && \
        sysctl -w net.ipv4.conf.eth0.arp_announce=2 && \
        sysctl -w net.ipv4.conf.all.arp_ignore=1 && \
        sysctl -w net.ipv4.conf.all.arp_announce=2 && \
        ip address add ${VIP01}/32 broadcast ${VIP01} scope global dev ${VIP01_INTERFACE}
        ip route add ${VIP01}/32 dev ${VIP01_INTERFACE}

        if [ $? == 0 ];then
                echo "`${DATETIME}`: [INFO] lvs nginx node newtork start successful."
        else
                echo "`${DATETIME}`: [ERROR] lvs nginx node newtork start failure."
        fi
}


stop(){
        ip route del ${VIP01}/32 dev ${VIP01_INTERFACE}
        ip address del ${VIP01}/32 dev ${VIP01_INTERFACE}
        sysctl -w net.ipv4.conf.eth0.arp_ignore=0 && \
        sysctl -w net.ipv4.conf.eth0.arp_announce=0 && \
        sysctl -w net.ipv4.conf.all.arp_ignore=0 && \
        sysctl -w net.ipv4.conf.all.arp_announce=0

        if [ $? == 0 ];then
                echo "`${DATETIME}`: [INFO] lvs nginx node newtork stop successful."
        else
                echo "`${DATETIME}`: [ERROR] lvs nginx node newtork stop failure."
        fi
}


restart(){
        stop
        sleep 1
        start
}

status(){
        [ `route -n | grep -E "${VIP01}" | wc -l` == "${VIP_COUNT}" ] && \
        [ `ip address show ${INTERFACE} | grep -E "${VIP01}" | wc -l` == "${VIP_COUNT}" ]  && \
        [ `sysctl -n net.ipv4.conf.eth0.arp_ignore` == 1 ] && \
        [ `sysctl -n net.ipv4.conf.eth0.arp_announce` == 2 ] && \
        [ `sysctl -n net.ipv4.conf.all.arp_ignore` == 1 ] && \
        [ `sysctl -n net.ipv4.conf.all.arp_announce` == 2 ]

        if [ $? == 0 ];then
                echo "`${DATETIME}`: [INFO] lvs nginx node newtork is running."
        else
                echo "`${DATETIME}`: [INFO] lvs nginx node newtork is stop."
        fi

}

case "$1" in
        start)
                start;;
        stop)
                stop;;
        restart)
                restart;;
        status)
                status;;
        *)
                echo "Usage: $0 { start | stop | restart | status}"
        ;;

esac
```

