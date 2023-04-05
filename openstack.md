# Openstack





## 1. openstack 框架说明

1.1 组件说明

1.2 安装结构说明

1.3 基础环境构建



### 1.1 组件说明

![](.\image\openstack\openstack01.png)

![](.\image\openstack\openstack02.png)

### 1.2 安装结构说明

![](.\image\openstack\openstack03.png)

![](.\image\openstack\openstack04.png)

### 1.3 基础环境构建

* 创建3个主机网络，VMnet1、VMnet2、VMnet3分别代表管理网络、实例网络、外部网络

* 创建controller节点，2C CPU, 1.5G memory, 100G storage ，添加1个网卡位于VMnet1
  * keystone服务、部署trove服务、glance服务
* 创建nova节点，8C CPU, 6G memory, 100G storage (计算节点，资源尽量最高)，添加2个网卡分别位于VMnet1和VMnet2
  * 部署nova服务
* 创建neutron节点，2C CPU, 2.5G memory, 20G storage ，添加3个网卡分别位于VMnet1、VMnet2、VMnet3
  * 部署neutron服务
* 创建cinder节点，2C CPU, 1.5G memory, 20G storage ，添加1个网卡位于VMnet1
  * 部署cinder服务
* 创建nexus-proxy节点，openstack节点使用yum仓库是使用此代理
  * 部署nexus yum代理服务

注：所有节点系统初始化需要关闭SElinux、防火墙、NetworkManager功能，并配置主机名和时间同步

* 网络配置汇总

```
nexus-proxy: 192.168.222.4	192.168.239.128(NAT接口)
controller: 192.168.222.5
neutron: 192.168.222.6 172.16.0.6 100.100.100.10 
nova: 192.168.222.10 172.16.0.10
cinder: 192.168.222.20
```



#### VMware主机网络配置

![](.\image\openstack\openstack05.png)



#### controller节点信息

```shell
[root@controller ~]# ip a s 	#ens33网卡模式为VMnet1
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:1e:47:13 brd ff:ff:ff:ff:ff:ff
    inet 192.168.222.5/24 brd 192.168.222.255 scope global noprefixroute ens33
       valid_lft forever preferred_lft forever
    inet6 fe80::5ea0:8ef4:789c:280b/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
[root@controller ~]# cat /proc/cpuinfo | grep -i processor | wc -l
2
[root@controller ~]# cat /proc/meminfo | grep -i memtotal
MemTotal:        1511808 kB
[root@controller ~]# fdisk -l | grep '/dev/sda:'
Disk /dev/sda: 107.4 GB, 107374182400 bytes, 209715200 sectors
```

#### nova节点信息

```shell
[root@nova ~]# ip a s 	#ens33网卡模式为VMnet1,ens34网卡模式为VMnet2
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:5f:eb:c9 brd ff:ff:ff:ff:ff:ff
    inet 192.168.222.10/24 brd 192.168.222.255 scope global noprefixroute ens33
       valid_lft forever preferred_lft forever
    inet6 fe80::ca92:a15b:8ec5:ecaa/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
3: ens34: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:5f:eb:d3 brd ff:ff:ff:ff:ff:ff
    inet 172.16.0.10/24 brd 172.16.0.255 scope global noprefixroute ens34
       valid_lft forever preferred_lft forever
    inet6 fe80::e45:8c4a:baf1:c66c/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever

[root@nova ~]# cat /proc/cpuinfo | grep -i processor | wc -l
8
[root@nova ~]# cat /proc/meminfo | grep -i memtotal
MemTotal:        5925684 kB
[root@nova ~]# fdisk -l | grep '/dev/sda:'
Disk /dev/sda: 107.4 GB, 107374182400 bytes, 209715200 sectors
```

#### neutron节点信息

```shell
[root@neutron yum.repos.d]# ip a s 	#ens33网卡模式为VMnet1,ens34网卡模式为VMnet2,ens35网卡模式为VMnet3
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:a2:c7:5d brd ff:ff:ff:ff:ff:ff
    inet 192.168.222.6/24 brd 192.168.222.255 scope global noprefixroute ens33
       valid_lft forever preferred_lft forever
    inet6 fe80::9320:20db:ffd0:d284/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
3: ens34: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:a2:c7:67 brd ff:ff:ff:ff:ff:ff
    inet 172.16.0.6/24 brd 172.16.0.255 scope global noprefixroute ens34
       valid_lft forever preferred_lft forever
    inet6 fe80::4e41:63b1:6845:71a/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
4: ens35: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:a2:c7:71 brd ff:ff:ff:ff:ff:ff
    inet 100.100.100.10/24 brd 100.100.100.255 scope global ens35
       valid_lft forever preferred_lft forever

[root@neutron yum.repos.d]# cat /proc/cpuinfo | grep -i processor | wc -l
2
[root@neutron yum.repos.d]# cat /proc/meminfo | grep -i memtotal
MemTotal:        2379136 kB
[root@neutron yum.repos.d]# fdisk -l | grep '/dev/sda:'
Disk /dev/sda: 21.5 GB, 21474836480 bytes, 41943040 sectors
```

#### cinder节点信息

```shell
[root@cinder ~]# ip a s 	#ens33网卡模式为VMnet1
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:3f:46:46 brd ff:ff:ff:ff:ff:ff
    inet 192.168.222.20/24 brd 192.168.222.255 scope global noprefixroute ens33
       valid_lft forever preferred_lft forever
    inet6 fe80::b23b:d777:66f6:d81/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever

[root@cinder ~]# cat /proc/cpuinfo | grep -i processor | wc -l
2
[root@cinder ~]# cat /proc/meminfo | grep -i memtotal
MemTotal:        1511808 kB
[root@cinder ~]# fdisk -l | grep '/dev/sda:'
Disk /dev/sda: 21.5 GB, 21474836480 bytes, 41943040 sectors
```

#### nexus-proxy yum代理仓库部署

```shell
[root@nexus-proxy ~]# ip a s   # ens33网关为NAT模式，ens34网卡模式为VMnet1
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:8e:24:34 brd ff:ff:ff:ff:ff:ff
    inet 192.168.239.128/24 brd 192.168.239.255 scope global noprefixroute dynamic ens33
       valid_lft 1102sec preferred_lft 1102sec
    inet6 fe80::1e9f:9193:90e2:fa0/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
3: ens34: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:8e:24:3e brd ff:ff:ff:ff:ff:ff
    inet 192.168.222.4/24 brd 192.168.222.255 scope global noprefixroute ens34
       valid_lft forever preferred_lft forever
    inet6 fe80::e213:6fb4:5f04:7f45/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever

[root@nexus-proxy ~]# cat /proc/cpuinfo | grep -i processor | wc -l
2
[root@nexus-proxy ~]# cat /proc/meminfo | grep -i memtotal
MemTotal:        1863040 kB
[root@nexus-proxy ~]# fdisk -l | grep '/dev/sda:'
Disk /dev/sda: 107.4 GB, 107374182400 bytes, 209715200 sectors


[root@nexus-proxy ~]# mkdir -pv /data/nexus3 && chmod -R 777 /data/nexus3
[root@nexus-proxy ~]# docker run -d -p 80:8081 --name nexus -v /data/nexus3:/nexus-data -e INSTALL4J_ADD_VM_PARAMS="-Xms512m -Xmx512m -XX:MaxDirectMemorySize=512m -Djava.util.prefs.userRoot=/nexus-data/javaprefs" sonatype/nexus3:3.32.0
[root@nexus-proxy ~]# docker exec nexus cat /opt/sonatype/sonatype-work/nexus3/admin.password
85ff2858-98fd-43bd-8d75-2487d8b30af0

# 进入nexus，增加yum(proxy)，名称为yum-aliyun 配置阿里云repo仓库地址：http://mirrors.aliyun.com/centos/
# 进入nexus，增加yum(proxy)，名称为yum-aliyun-epel 配置阿里云repo仓库地址：http://mirrors.aliyun.com/epel/
# 进入nexus，增加yum(proxy)，名称为yum-openstack 配置repo仓库地址：http://repos.fedorapeople.org/repos/openstack/EOL/openstack-juno/epel-7/
# 获取nexus yum centos7 proxy地址：http://192.168.222.4/repository/yum-aliyun/
# 获取nexus yum epel proxy地址：http://192.168.222.4/repository/yum-aliyun-epel/
# 获取nexus yum openstack proxy地址：http://192.168.222.4/repository/yum-openstack/
```

#### 配置内网不能上网机器的yum源

```shell
# 例如neutron服务器，替换baseurl地址为上面获取的nexus yum proxy地址：
[root@neutron yum.repos.d]# cat centos7.repo
[base]
name=CentOS-$releasever - Base
baseurl=http://192.168.222.4/repository/yum-aliyun/$releasever/os/$basearch/
enabled=1
gpgcheck=0

[updates]
name=CentOS-$releasever - Updates
baseurl=http://192.168.222.4/repository/yum-aliyun/$releasever/updates/$basearch/
enabled=1
gpgcheck=0

[extras]
name=CentOS-$releasever - Extras
baseurl=http://192.168.222.4/repository/yum-aliyun/$releasever/extras/$basearch/
enabled=1
gpgcheck=0

[centosplus]
name=CentOS-$releasever - Centosplus
baseurl=http://192.168.222.4/repository/yum-aliyun/$releasever/centosplus/$basearch/
enabled=1
gpgcheck=0
# 注：$releasever 表示7，$basearch表示x86_64
---
[root@nova yum.repos.d]# cat epel7.repo 
[epel]
name=CentOS-$releasever - epel
baseurl=http://192.168.222.4/repository/yum-aliyun-epel/7/$basearch
enabled=1
gpgcheck=0
---
[root@nova yum.repos.d]# cat openstack.repo 
[openstack]
name=CentOS-$releasever - Openstack
baseurl=http://192.168.222.4/repository/yum-openstack
enabled=1
gpgcheck=0
---
[root@neutron yum.repos.d]# yum clean all 
[root@neutron yum.repos.d]# yum makecache fast 
[root@neutron yum.repos.d]# yum repolist
repo id     		repo name      			status
base/7/x86_64       CentOS-7 - Base     	10,072
epel/x86_64         CentOS-7 - epel			13,770
openstack           CentOS-7 - Openstack    1,040
repolist: 24,882
[root@neutron yum.repos.d]# yum install -y vim bash-completion	#此时已经可以安装软件包
注：controler、nova、cinder节点都需要配置yum源
```



#### 所有节点配置hosts、时间同步以及其它

```shell
# hosts配置
[root@controller files]# ansible linux -m shell -a 'cat /etc/hosts'
192.168.222.20 | CHANGED | rc=0 >>
127.0.0.1 localhost
192.168.222.4 nexus-proxy.markli.cn 
192.168.222.5 controller.markli.cn 
192.168.222.6 neutron.markli.cn 
192.168.222.10 nova.markli.cn 
192.168.222.20 cinder.markli.cn 
192.168.222.6 | CHANGED | rc=0 >>
127.0.0.1 localhost
192.168.222.4 nexus-proxy.markli.cn 
192.168.222.5 controller.markli.cn 
192.168.222.6 neutron.markli.cn 
192.168.222.10 nova.markli.cn 
192.168.222.20 cinder.markli.cn 
192.168.222.10 | CHANGED | rc=0 >>
127.0.0.1 localhost
192.168.222.4 nexus-proxy.markli.cn 
192.168.222.5 controller.markli.cn 
192.168.222.6 neutron.markli.cn 
192.168.222.10 nova.markli.cn 
192.168.222.20 cinder.markli.cn 
192.168.222.5 | CHANGED | rc=0 >>
127.0.0.1 localhost
192.168.222.4 nexus-proxy.markli.cn 
192.168.222.5 controller.markli.cn 
192.168.222.6 neutron.markli.cn 
192.168.222.10 nova.markli.cn 
192.168.222.20 cinder.markli.cn 
192.168.222.4 | CHANGED | rc=0 >>
127.0.0.1 localhost
192.168.222.4 nexus-proxy.markli.cn 
192.168.222.5 controller.markli.cn 
192.168.222.6 neutron.markli.cn 
192.168.222.10 nova.markli.cn 
192.168.222.20 cinder.markli.cn 

# 时间同步，此处把nexus-proxy配置为ntp server
[root@controller tasks]# ansible all -m shell -a 'date'
192.168.222.5 | CHANGED | rc=0 >>
Wed Apr  5 19:18:13 CST 2023
192.168.222.10 | CHANGED | rc=0 >>
Wed Apr  5 19:18:13 CST 2023
192.168.222.4 | CHANGED | rc=0 >>
Wed Apr  5 19:18:13 CST 2023
192.168.222.20 | CHANGED | rc=0 >>
Wed Apr  5 19:18:13 CST 2023
192.168.222.6 | CHANGED | rc=0 >>
Wed Apr  5 19:18:13 CST 2023

# 安装 OpenStack 预备包 
## 安装 yum-plugin-priorities 包，防止高优先级软件被低优先级软件覆盖，这个插件允许存储库有不同的优先级
[root@controller tasks]# ansible openstack -m shell -a 'yum -y install yum-plugin-priorities'

# 更新操作系统 
[root@controller base]# ansible openstack -m shell -a 'yum upgrade -y'
[root@controller ~]# ansible openstack -m shell -a 'uname -a' #旧版本为3.10.0-1127
192.168.222.6 | CHANGED | rc=0 >>
Linux neutron.markli.cn 3.10.0-1160.el7.x86_64 #1 SMP Mon Oct 19 16:18:59 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
192.168.222.5 | CHANGED | rc=0 >>
Linux controller.markli.cn 3.10.0-1160.el7.x86_64 #1 SMP Mon Oct 19 16:18:59 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
192.168.222.10 | CHANGED | rc=0 >>
Linux nova.markli.cn 3.10.0-1160.el7.x86_64 #1 SMP Mon Oct 19 16:18:59 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
192.168.222.20 | CHANGED | rc=0 >>
Linux cinder.markli.cn 3.10.0-1160.el7.x86_64 #1 SMP Mon Oct 19 16:18:59 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
```



## 2. keystone 认证服务部署

* 2.1 组件说明
* 2.2 组件之间沟通方式
* 2.3 构建实验



### 2.1 组件说明

* 什么是 Keystone 
  * Keystone 是 OpenStack Identity Service 的项目名称，是一个负责身份 管理与授权的组件 主要功能：实现用户的身份认证，基于角色的权限管理，及openstack其他组件的访问地址和 安全策略管理

* 为什么需要 Keystone 
  * Keystone项目的主要目的是给整个openstack的各个组件（nova，cinder，glance...）提供一 个统一的验证方式

* 用户管理
  * Account 账户 
  * Authentication 身份认证 
  * Authorization 授权 

* 服务目录管理
  * 管理员手工配置的组件服务的访问端点对应关系，例如
    * nova http://restfullapi/uri
    * neutron http://restfullapi/uri
* 认证服务中的关键字
  * User（用户) 一个人、系统或服务在OpenStack中的数字表示。已经登录的用户分配令牌环以 访问资源。用户可以直接分配给特定的租户，就像隶属于每个组。
  *  Credentials（凭证） 用于确认用户身份的数据。例如：用户名和密码，用户名和API key，或 由认证服务提供的身份验证令牌 
  * Authentication（验证） 确认用户身份的过程。 
  * Token（令牌） 一个用于访问OpenStack API和资源的字母数字字符串。一个临牌可以随时撤销， 并且持续一段时间有效 认证服务中的关键字 -1 
  * Tenant（租户） 一个组织或孤立资源的容器。租户可以组织或隔离认证对象。根据服务运营 的要求，一个租户可以映射到客户、账户、组织或项目。
  *  Service（服务） OpenStack服务，例如计算服务（nova），对象存储服务（swift） ,或镜像服 务（glance）。它提供了一个或多个端点，供用户访问资源和执行操作。 
  * Endpoint（端点） 一个用于访问某个服务的可以通过网络进行访问的地址，通常是一个URL地 址。
  * Role（角色） 定制化的包含特定用户权限和特权的权限集合 
  * Keystone Client（keystone命令行工具） Keystone的命令行工具。通过该工具可以创建用户， 角色，服务和端点等。。。
* 名词解释
  * 用户：张三 
  * 凭证：身份证 
  * 验证：验证身份证 
  * 令牌：房卡 
  * 租户：宾馆 (是服务的集合)
  * 服务：住宿、餐饮 
  * 端点：路径 
  * 角色：VIP等级



### 2.2 组件之间沟通方式

用户认证过程

![用户认证过程](.\image\openstack\openstack06.png)



组件之间的交互过程

![组件之间的交互过程](.\image\openstack\openstack07.png)

![用户-角色-服务](.\image\openstack\openstack08.png)



### 2.3 构建实验

在生产环境安装mysql和rabbitMQ时，需要使用高可用集群

#### 2.3.1 为 controller 节点安装数据库

```
# 安装 mariadb 软件包 
yum -y install mariadb mariadb-server MySQL-python

# 配置mariadb
[root@controller ~]# cat /etc/my.cnf
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
symbolic-links=0
bind-address = 192.168.222.5
default-storage-engine = innodb
innodb_file_per_table
collation-server = utf8_general_ci
init-connect = 'SET NAMES utf8'
character-set-server = utf8

[mysqld_safe]
log-error=/var/log/mariadb/mariadb.log
pid-file=/var/run/mariadb/mariadb.pid

!includedir /etc/my.cnf.d
---

# 启动mariadb
[root@controller ~]# systemctl start mariadb.service 
[root@controller ~]# systemctl enable mariadb.service
# 初始化mariadb
[root@controller ~]# mysql_secure_installation 
# 测试登录
[root@controller ~]# mysql -uroot -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 12
Server version: 5.5.68-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> 
```

#### 2.3.2 安装 Messaing Server 服务

* 功能：协调操作和状态信息服务
* 常用的消息代理软件  RabbitMQ  Qpid  ZeroMQ 

在 controller 节点安装 RabbitMQ

```shell
# a、安装 RabbitMQ 软件包 
[root@controller ~]# yum -y install rabbitmq-server 
 
# b、启动服务并设置开机自启动 
[root@controller ~]# systemctl enable rabbitmq-server 
[root@controller ~]# systemctl start rabbitmq-server 
 
# c、rabbitmq 默认用户名和密码是 guest，可以通过下列命令修改 
[root@controller ~]# rabbitmqctl change_password guest homsom	#测试环境密码都是homsom
Changing password for user "guest" ...
...done.
```

#### 2.3.3 创建认证服务数据库

```shell
# a.登录mysql数据库
[root@controller ~]# mysql -u root -p
Enter password: homsom

# b.创建keystone数据库
MariaDB [(none)]> CREATE DATABASE keystone;

# c.创建keystone数据库用户，使其可以对keystone数据库有完全控制权限
MariaDB [(none)]> GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 
'homsom';
MariaDB [(none)]> GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 
'homsom';

# 生成一个随机值作为管理令牌在初始配置
[root@controller ~]# openssl rand -hex 10:
93641b30a0203a5bc0bb
```

#### 2.3.4 安装和配置认证组件

```
## 1.安装软件包
[root@controller ~]# yum install -y openstack-keystone python-keystoneclient

## 2.编辑/etc/keystone/keyston.conf文件并作下列修改：
[root@controller ~]# vim /etc/keystone/keystone.conf 
---
# a.修改[DEFAULT]小节，定义初始管理令牌
[DEFAULT]
admin_token=93641b30a0203a5bc0bb    #上面生成的随机值
verbose = true 						# d.（可选）开启详细日志，协助故障排除  
# b.修改[database]小节，配置数据库访问
[database]
connection=mysql://keystone:homsom@controller.markli.cn/keystone                         # c.修改[token]小节，配置UUID提供者和SQL驱动                                      
[token]
provider=keystone.token.providers.uuid.Provider                                            driver=keystone.token.persistence.backends.sql.Token
                                        
## 3.常见通用证书的密钥，并限制相关文件的访问权限
keystone-manage pki_setup --keystone-user keystone --keystone-group keystone
chown -R keystone:keystone /var/log/keystone
chown -R keystone:keystone /etc/keystone/ssl
chmod -R o-rwx /etc/keystone/ssl

## 4.初始化keystone数据库
[root@controller ~]# su -s /bin/sh -c "keystone-manage db_sync" keystone
# 查看数据库是否恢复数据
MariaDB [keystone]> show tables;
+-----------------------+
| Tables_in_keystone    |
+-----------------------+
| assignment            |
| credential            |
| domain                |
| endpoint              |
| group                 |
| id_mapping            |
| migrate_version       |
| policy                |
| project               |
| region                |
| revocation_event      |
| role                  |
| service               |
| token                 |
| trust                 |
| trust_role            |
| user                  |
| user_group_membership |
+-----------------------+
```

#### 2.3.5 完成安装

```shell
## 1.启动identity服务并设置开机启动
systemctl enable openstack-keystone.service
systemctl start openstack-keystone.service

## 2.默认情况下，服务器会无限存储到期的令牌，在资源有限的情况下会严重影响
服务器性能。建议用计划任务，每小时删除过期的令牌
(crontab -l -u keystone 2>&1 | grep -q token_flush) || \
echo '@hourly /usr/bin/keystone-manage token_flush >/var/log/keystone/keystone-tokenflush.log 2>&1' >> /var/spool/cron/keystone

[root@controller ~]# cat /var/spool/cron/keystone
@hourly /usr/bin/keystone-manage token_flush >/var/log/keystone/keystone-tokenflush.log 2>&1
```

#### 2.3.6 创建tenants(租户),(users)用户和(roles)角色

配置先决条件

```
# 1.配置管理员令牌
export OS_SERVICE_TOKEN=93641b30a0203a5bc0bb		#刚才生成的字符串
# 2.配置端点
export OS_SERVICE_ENDPOINT=http://controller.markli.cn:35357/v2.0
```

创建租户，用户和角色

```shell
## 1、创建用于管理的租户，用户和角色
# a.创建admin租户
[root@controller ~]# keystone tenant-create --name admin --description "Admin Tenant"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |           Admin Tenant           |
|   enabled   |               True               |
|      id     | e530df3ff8e14bcfada8f49fe4413e68 |
|     name    |              admin               |
+-------------+----------------------------------+

# b.创建admin用户
[root@controller ~]# keystone user-create --name admin --pass ADMIN_PASS --email EMAIL_ADDRESS
+----------+----------------------------------+
| Property |              Value               |
+----------+----------------------------------+
|  email   |          EMAIL_ADDRESS           |
| enabled  |               True               |
|    id    | 67e028b136674295900a5031b11a1140 |
|   name   |              admin               |
| username |              admin               |
+----------+----------------------------------+

# c.创建admin角色
[root@controller ~]# keystone role-create --name admin
+----------+----------------------------------+
| Property |              Value               |
+----------+----------------------------------+
|    id    | 72f5096b1692401f86e02c6987c011a9 |
|   name   |              admin               |
+----------+----------------------------------+

# d.添加admin租户和用户到admin角色
[root@controller ~]# keystone user-role-add --tenant admin --user admin --role admin

# e.创建用于dashboard访问的“_member_”角色
[root@controller ~]# keystone role-create --name _member_
+----------+----------------------------------+
| Property |              Value               |
+----------+----------------------------------+
|    id    | ed068c77bb4041b5a92af46cd14b50d1 |
|   name   |             _member_             |
+----------+----------------------------------+

# f.添加admin租户和用户到_member_角色
[root@controller ~]# keystone user-role-add --tenant admin --user admin --role _member_


## 2、创建一个用于演示的demo租户和用户
# a.创建demo租户
[root@controller ~]# keystone tenant-create --name demo --description "Demo Tenant"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |           Demo Tenant            |
|   enabled   |               True               |
|      id     | 29dd9bfe34324be8b979ad93be76fce5 |
|     name    |               demo               |
+-------------+----------------------------------+

# b.创建的demo用户
[root@controller ~]# keystone user-create --name demo --pass DEMO_PASS --email EMAIL_ADDRESS
+----------+----------------------------------+
| Property |              Value               |
+----------+----------------------------------+
|  email   |          EMAIL_ADDRESS           |
| enabled  |               True               |
|    id    | c198723d56e84fdd9d6f3c2ecb65b639 |
|   name   |               demo               |
| username |               demo               |
+----------+----------------------------------+

# c.添加demo租户和用户到_member_角色
[root@controller ~]# keystone user-role-add --tenant demo --user demo --role _member_


## 3、OpenStack服务业需要一个租户，用户和角色和其他服务进行交互。因此我们创建一个service的租户。任何一个OpenStack服务都要和它关联
[root@controller ~]# keystone tenant-create --name service --description "Service Tenant"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |          Service Tenant          |
|   enabled   |               True               |
|      id     | f1e21cb223d94e82b695e1c2d277a77f |
|     name    |             service              |
+-------------+----------------------------------+

```

#### 2.3.7 创建服务实体和API端点

* 实体：keystone提供服务的名称
* API端点：keystone提供服务的路径

```shell
## 1.在OpenStack环境中，identity服务管理一个服务目录，并使用这个目录在OpenStack环境中定位其他服务。
# 为identity服务创建一个服务实体，只要type为identity的就是一个认证服务，name为实体名称
[root@controller ~]# keystone service-create --name keystone --type identity --description "OpenStack Identity"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |        OpenStack Identity        |
|   enabled   |               True               |
|      id     | c60ac1135ab84189a7ff7baf5806963b |
|     name    |             keystone             |
|     type    |             identity             |
+-------------+----------------------------------+

## 2.OpenStack环境中，identity服务管理目录以及与服务相关API端点。服务使用这个目录来沟通其他服务。
# OpenStack为每个服务提供了三个API端点：admin(管理),internal(内部),public(公共)
# 为identity服务创建API端点
[root@controller ~]# keystone endpoint-create \
> --service-id $(keystone service-list | awk '/ identity / {print $2}') \
> --publicurl http://controller.markli.cn:5000/v2.0 \
> --internalurl http://controller.markli.cn:5000/v2.0 \
> --adminurl http://controller.markli.cn:35357/v2.0 \
> --region regionOne
+-------------+----------------------------------------+
|   Property  |                 Value                  |
+-------------+----------------------------------------+
|   adminurl  | http://controller.markli.cn:35357/v2.0 |
|      id     |    bf2f7e71da084e4dadbb368163bd6b2b    |
| internalurl | http://controller.markli.cn:5000/v2.0  |
|  publicurl  | http://controller.markli.cn:5000/v2.0  |
|    region   |               regionOne                |
|  service_id |    c60ac1135ab84189a7ff7baf5806963b    |
+-------------+----------------------------------------+

```

#### 2.3.8 确认操作

```shell
## 1、删除OS_SERVICE_TOKEN 和OS_SERVICE_ENDPOINT 临时变量
[root@controller ~]# unset OS_SERVICE_TOKEN OS_SERVICE_ENDPOINT

## 2、使用admin租户和用户请求认证令牌
[root@controller ~]# keystone --os-tenant-name admin --os-username admin --os-password ADMIN_PASS --os-auth-url http://controller.markli.cn:35357/v2.0 token-get
+-----------+----------------------------------+
|  Property |              Value               |
+-----------+----------------------------------+
|  expires  |       2023-04-05T16:20:10Z       |
|     id    | 49274c7479634126af3a87212029c715 |
| tenant_id | e530df3ff8e14bcfada8f49fe4413e68 |
|  user_id  | 67e028b136674295900a5031b11a1140 |
+-----------+----------------------------------+

## 3、以admin租户和用户的身份查看租户列表
[root@controller ~]# keystone --os-tenant-name admin --os-username admin --os-password ADMIN_PASS --os-auth-url http://controller.markli.cn:35357/v2.0 tenant-list
+----------------------------------+---------+---------+
|                id                |   name  | enabled |
+----------------------------------+---------+---------+
| e530df3ff8e14bcfada8f49fe4413e68 |  admin  |   True  |
| 29dd9bfe34324be8b979ad93be76fce5 |   demo  |   True  |
| f1e21cb223d94e82b695e1c2d277a77f | service |   True  |
+----------------------------------+---------+---------+

## 4、以admin租户和用户的身份查看用户列表
[root@controller ~]# keystone --os-tenant-name admin --os-username admin --os-password ADMIN_PASS --os-auth-url http://controller.markli.cn:35357/v2.0 user-list
+----------------------------------+-------+---------+---------------+
|                id                |  name | enabled |     email     |
+----------------------------------+-------+---------+---------------+
| 67e028b136674295900a5031b11a1140 | admin |   True  | EMAIL_ADDRESS |
| c198723d56e84fdd9d6f3c2ecb65b639 |  demo |   True  | EMAIL_ADDRESS |
+----------------------------------+-------+---------+---------------+

## 5、以admin租户和用户的身份查看角色列表
[root@controller ~]# keystone --os-tenant-name admin --os-username admin --os-password ADMIN_PASS --os-auth-url http://controller.markli.cn:35357/v2.0 role-list
+----------------------------------+----------+
|                id                |   name   |
+----------------------------------+----------+
| ed068c77bb4041b5a92af46cd14b50d1 | _member_ |
| 72f5096b1692401f86e02c6987c011a9 |  admin   |
+----------------------------------+----------+

## 6、以demo租户和用户的身份请求认证令牌
[root@controller ~]# keystone --os-tenant-name demo --os-username demo --os-password DEMO_PASS --os-auth-url http://controller.markli.cn:35357/v2.0 token-get
+-----------+----------------------------------+
|  Property |              Value               |
+-----------+----------------------------------+
|  expires  |       2023-04-05T16:27:23Z       |
|     id    | b3b5211f904b488fa697eff8d288fd3a |
| tenant_id | 29dd9bfe34324be8b979ad93be76fce5 |
|  user_id  | c198723d56e84fdd9d6f3c2ecb65b639 |
+-----------+----------------------------------+

## 7、以demo租户和用户的身份查看用户列表
[root@controller ~]# keystone --os-tenant-name demo --os-username demo --os-password DEMO_PASS --os-auth-url http://controller.markli.cn:35357/v2.0 user-list
You are not authorized to perform the requested action: admin_required (HTTP 403)

```

#### 2.3.9 创建OpenStack客户端环境脚本

为了方便使用上面的环境变量和命令选项，我们为admin和demo租户和用户 创建环境脚本。

```shell
## 1、编辑admin-openrc.sh
[root@controller ~]# cat admin-openrc.sh 
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=ADMIN_PASS
export OS_AUTH_URL=http://controller.markli.cn:35357/v2.0

## 2、编辑demo-openrc.sh
[root@controller ~]# cat demo-openrc.sh 
export OS_TENANT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=DEMO_PASS
export OS_AUTH_URL=http://controller.markli.cn:5000/v2.0

## 加载客户端环境脚本
source admin-openrc.sh
```



