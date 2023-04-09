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
bind-address=192.168.222.5
default-storage-engine=innodb
innodb_file_per_table
collation-server=utf8_general_ci
init-connect='SET NAMES utf8'
character-set-server=utf8

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
[root@controller ~]# yum install rabbitmq-server 
 
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
[root@controller ~]# yum install openstack-keystone python-keystoneclient

## 2.编辑/etc/keystone/keyston.conf文件并作下列修改：
[root@controller ~]# vim /etc/keystone/keystone.conf 
---
# a.修改[DEFAULT]小节，定义初始管理令牌
[DEFAULT]
admin_token=93641b30a0203a5bc0bb    #上面生成的随机值
verbose=true 						# d.（可选）开启详细日志，协助故障排除  
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





## 3. Glance服务



### 3.1 Glance 服务功能

* OpenStack镜像服务( glance )使用户能够发现、注册并检索虚拟机镜像( .img文件 ) 
* 它提供了一个 REST API 接口，使用户可以查询虚拟机镜像元数据和检索一个实际的镜像文件 
* 不论是简单的文件系统还是 OpenStack 对象存储，你都可以通过镜像服务在不同的位置存储虚 拟机镜像 
* 默认情况下，上传的虚拟机镜像存储路径为 /var/lib/glance/images/ Glance 服务功能 



### 3.2 组件说明

* glance-api：一个用来接收镜像发现、检索和存储的 API 接口 
* glance-registry：用来存储、处理和检索镜像的元数据。元数据包含对象的大小和类型。glanceregistry是一个OpenStack镜像服务使用的内部服务，不要透露给用户 
* Database：用于存储镜像的元数据的大小、类型，支持大多数数据库，一般选择 MySQL 或 SQLite Storage 
* repository for image files：镜像文件的存储仓库。支持包括普通文件系统在内的各种存储类 型。包括对象存储、块设备、HTTP、Amazon S3，但有些存储只支持只读访问



### 3.3 基本概念

* Image Identifiers：就是 Image URL ，格式 /images/ 全局唯一 

* Image Status 
  * Queued：镜像 ID 已被保留，镜像还没有上传
  * Saving：镜像正在被上传
  * Active：镜像可以使用了
  * Killed：镜像损坏或者不可用 
  * Deleted:镜像被删除
* Disk Format
  * Raw：This is unstructured disk image format （初始慢，占用空间为给定大小，不支持动态扩展）
  * Vhd：VMWare、XEN、Microsoft、VirtualBox 
  * Vmdk：common format 
  * Vdi：VirtualBox、QEMU emulator 
  * ISO：optical disc 
  * Qcow2：QEMU emulator 
  * Aki：Amazon Kernel Image 
  * Ari：Amazon ramdisk image 
  * Ami：Amazon machine image
* Container Format 
  * Bare ，不支持动态扩展，不支持导出导入
  * Ovf (Open VirtualMachine File)，支持动态扩展，支持导出导入
  * Aki 
  * Ami 
  * Ari



### 3.4 组件工作流

![组件工作流](.\image\openstack\openstack09.png)





### 3.5 构建实验

在controller节点安装并配置OpenStack镜像服务

* 安装先决条件
* 安装并配置镜像服务组件
* 完成安装



#### 3.5.1 安装先决条件

```shell
## 1.安装数据库
MariaDB [(none)]> CREATE DATABASE glance;
Query OK, 1 row affected (0.00 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 
    -> 'GLANCE_DBPASS';
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'GLANCE_DBPASS';
Query OK, 0 rows affected (0.00 sec)


## 2.启用admin环境脚本
[root@controller ~]# cat admin-openrc.sh 
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=ADMIN_PASS
export OS_AUTH_URL=http://controller.markli.cn:35357/v2.0
[root@controller ~]# source admin-openrc.sh 


## 3.创建认证服务凭证
# a.创建glance用户
[root@controller ~]# keystone user-create --name glance --pass GLANCE_PASS
+----------+----------------------------------+
| Property |              Value               |
+----------+----------------------------------+
|  email   |                                  |
| enabled  |               True               |
|    id    | 28fb373b34334a47a303f1ff79cf5043 |
|   name   |              glance              |
| username |              glance              |
+----------+----------------------------------+

# b.将glance用户链接到service租户和admin角色
[root@controller ~]# keystone user-role-add --user glance --tenant service --role admin

# c.创建glance服务
[root@controller ~]# keystone service-create --name glance --type image --description "OpenStack Image 
> Service"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |         OpenStack Image          |
|             |             Service              |
|   enabled   |               True               |
|      id     | 7737bf267bc447288b0ba9f670783b4d |
|     name    |              glance              |
|     type    |              image               |
+-------------+----------------------------------+


## 4.为OpenStack镜像服务创建认证服务端点
[root@controller ~]# keystone endpoint-create \
--service-id $(keystone service-list | awk '/ image / {print $2}') \
--publicurl http://controller.markli.cn:9292 \
--internalurl http://controller.markli.cn:9292 \
--adminurl http://controller.markli.cn:9292 \
--region regionOne
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
|   adminurl  | http://controller.markli.cn:9292 |
|      id     | 3149835277014694b8433ba5b3ecb2e9 |
| internalurl | http://controller.markli.cn:9292 |
|  publicurl  | http://controller.markli.cn:9292 |
|    region   |            regionOne             |
|  service_id | 7737bf267bc447288b0ba9f670783b4d |
+-------------+----------------------------------+
```

#### 3.5.2 安装并配置镜像服务组件

```shell
## 1、安装软件包
[root@controller ~]# yum install openstack-glance python-glanceclient


## 2、编辑/etc/glance/glance-api.conf文件
# a.修改[database]小节，配置数据库连接
[root@controller ~]# vim /etc/glance/glance-api.conf 
[database]
connection=mysql://glance:GLANCE_DBPASS@controller.markli.cn/glance

# b.修改[keystone_authtoken]和[paste_deploy]小节,配置认证服务访问，注意：末尾不要有"空格"
[keystone_authtoken]
auth_uri=http://controller.markli.cn:5000/v2.0
identity_uri=http://controller.markli.cn:35357
admin_tenant_name=service
admin_user=glance
admin_password=GLANCE_PASS

[paste_deploy]
flavor=keystone                                                                           ---

# c.（可选）在[DEFAULT]小节中配置详细日志输出，方便排错
[DEFAULT] 
verbose=True


## 3、编辑/etc/glance/glance-registry.con文件，并完成下列配置
# a.在[database]小节中配置数据库连接
[root@controller ~]# vim /etc/glance/glance-registry.conf 
[database]
connection=mysql://glance:GLANCE_DBPASS@controller.markli.cn/glance

# b.在[keystone_authtoken]和[paste_deploy]小节中配置认证服务访问
[keystone_authtoken]
auth_uri=http://controller.markli.cn:5000/v2.0
identity_uri=http://controller.markli.cn:35357
admin_tenant_name=service
admin_user=glance
admin_password=GLANCE_PASS

[paste_deploy]
flavor=keystone  
---

# c.在[glance_store]小节中配置本地文件系统存储和镜像文件的存放路径，可以配置对像存储等存储方式，此配置段需要手动增加
[glance_store]
default_store=file
filesystem_store_datadir=/var/lib/glance/images/	#此路径不需要手动创建，glance会自动创建

# d.（可选）在[DEFAULT]小节中配置详细日志输出，方便排错
[DEFAULT] 
verbose=True


## 4、初始化镜像服务的数据库
[root@controller ~]# su -s /bin/sh -c "glance-manage db_sync" glance
[root@controller ~]# mysql -uroot -p -e 'show tables from glance;'
Enter password: 
+----------------------------------+
| Tables_in_glance                 |
+----------------------------------+
| image_locations                  |
| image_members                    |
| image_properties                 |
| image_tags                       |
| images                           |
| metadef_namespace_resource_types |
| metadef_namespaces               |
| metadef_objects                  |
| metadef_properties               |
| metadef_resource_types           |
| migrate_version                  |
| task_info                        |
| tasks                            |
+----------------------------------+
```



#### 3.5.3 完成安装

启动镜像服务并设置开机自动启动：

```shell
[root@controller ~]# systemctl enable openstack-glance-api.service openstack-glance-registry.service
Created symlink from /etc/systemd/system/multi-user.target.wants/openstack-glance-api.service to /usr/lib/systemd/system/openstack-glance-api.servi
ce.
Created symlink from /etc/systemd/system/multi-user.target.wants/openstack-glance-registry.service to /usr/lib/systemd/system/openstack-glance-regi
stry.service.
[root@controller ~]# systemctl start openstack-glance-api.service openstack-glance-registry.service
```



#### 3.5.4 验证安装

如何使用CirrOS验证镜像服务是否安装成功。CirrOS是一个小Linux镜像，可 以帮你验证镜像服务。

```
## 1、创建一个临时目录
[root@controller ~]# mkdir /tmp/images
[root@controller ~]# cd /tmp/images

## 2、下载镜像
[root@nexus-proxy /download]# curl -OL http://download.cirros-cloud.net/0.3.3/cirros-0.3.3-x86_64-disk.img
[root@nexus-proxy /download]# scp cirros-0.3.3-x86_64-disk.img root@controller.markli.cn:/tmp/images/

## 3、运行admin环境脚本，以便执行管理命令
[root@controller /tmp/images]# source /root/admin-openrc.sh 

## 4、上传镜像文件到镜像服务器
glance image-create --name "cirros-0.3.3-x86_64" --file cirros-0.3.3-x86_64-disk.img \
--disk-format qcow2 --container-format bare --is-public True --progress
[=============================>] 100%
+------------------+--------------------------------------+
| Property         | Value                                |
+------------------+--------------------------------------+
| checksum         | 133eae9fb1c98f45894a4e60d8736619     |
| container_format | bare                                 |
| created_at       | 2023-04-08T13:27:28                  |
| deleted          | False                                |
| deleted_at       | None                                 |
| disk_format      | qcow2                                |
| id               | 07e17807-8720-468c-a9d8-bf51bcc3314b |
| is_public        | True                                 |
| min_disk         | 0                                    |
| min_ram          | 0                                    |
| name             | cirros-0.3.3-x86_64                  |
| owner            | e530df3ff8e14bcfada8f49fe4413e68     |
| protected        | False                                |
| size             | 13200896                             |
| status           | active                               |
| updated_at       | 2023-04-08T13:27:29                  |
| virtual_size     | None                                 |
+------------------+--------------------------------------+

## 5、确认镜像文件上传并验证属性，状态为active时表示正常可用
[root@controller /tmp/images]# glance image-list
+--------------------------------------+---------------------+-------------+------------------+----------+--------+
| ID                                   | Name                | Disk Format | Container Format | Size     | Status |
+--------------------------------------+---------------------+-------------+------------------+----------+--------+
| 07e17807-8720-468c-a9d8-bf51bcc3314b | cirros-0.3.3-x86_64 | qcow2       | bare             | 13200896 | active |
+--------------------------------------+---------------------+-------------+------------------+----------+--------+
[root@controller /tmp/images]# cd 
[root@controller ~]# rm -rf /tmp/images
```

```
glance image-create相关选项含义：
--name <NAME>
镜像名称。
--file <FILE>
要上传文件及路径。
--disk-format <DISK_FORMAT>
镜像的磁盘格式。可以支持：ami, ari, aki, vhd, vmdk, raw, qcow2, vdi,iso格式。
--container-format <CONTAINER_FORMAT>
镜像容器格式。可以支持：ami, ari, aki, bare, ovf格式。
--is-public {True,False}
镜像是否可以被公共访问。
--progress
显示上传进度。
```





## 4. Nova服务



### 4.1 Nova 是什么

* Openstack 是由 Rackspace 和 NASA 共同开发的云计算平台
* 类似于 Amazon EC2 和 S3 的云基础架构服务
* Nova 在 Openstack 中提供云计算服务
* 超过 140 家企业及 18470 为开发者参与开发，参与开发的厂商如下

![参与开发的厂商](.\image\openstack\openstack10.png)

### 4.2 组件说明 

* nova-api service 接收并响应终端用户计算 API 调用。该服务支持 OpenStack 计算 API， Amazon EC2  和特殊的管理特权 API
* nova-api-metadata service 接受从实例元数据发来的请求。该服务通常与 nova-network 服务在安装多 主机模式下运行
* nova-compute service 一个守护进程，通过虚拟化层API接口创建和终止虚拟机实例。例如： XenAPI  for XenServer/XCP， libvirt for KVM or QEMU，VMwareAPI for Vmware 
* nova-scheduler service 从队列中获取虚拟机实例请求，并确认由哪台计算服务运行该虚拟机 
* nova-conductor module 协调 nova-compute 服务和 database 之间的交互数据。避免 nova-compute 服 务直接访问云数据库。不要将该模块部署在 nova-compute 运行的节点上
* nova-network worker daemon 类似于nova-compute服务，接受来自队列的网络任务和操控网络。比如这 只网卡桥接或改变iptables规则 
* nova-consoleauth daemon 在控制台代理提供用户授权令牌 
* nova-novncproxy daemon 提供了一个通过VNC连接来访问运行的虚拟机实例的代理。支持基于浏览器的 novnc客户端
* nova-spicehtml5proxy daemon 提供了一个通过 spice 连接来访问运行的虚拟机实例的代理。支持基于 浏览器的 HTML5 客户端 
* nova-xvpnvncproxy daemon 提供了一个通过VNC连接来访问运行的虚拟机实例的代理。支持 OpenStackspecific Java 客户端 
* nova-cert daemon x509 证书
* nova-objectstore daemon 一个 Amazon S3 的接口，用于将 Amazon S3 的镜像注册到 OpenStack euca2ools client 用于兼容于 Amazon E2 接口的命令行工具 
* nova client nova命令行工具 
* The queue 在进程之间传递消息的中心。通常使用 RabbitMQ 
* SQL database 保存云基础设置建立和运行时的状态信息



![位置顺序](.\image\openstack\openstack11.png)

![内部沟通](.\image\openstack\openstack12.png)



![同其它组件沟通](.\image\openstack\openstack13.png)



![虚拟机启动流程](.\image\openstack\openstack14.png)





### 4.3 构建实验之controller节点

安装和配置controller节点

* 配置先决条件
* 安装和配置计算控制组件
* 完成安装



#### 4.3.1 配置先决条件

```bash
## 1、创建数据库，完成下列步骤：
# a.使用数据库管理员root登录数据库
[root@controller ~]# mysql -u root -p             
Enter password: 	# homsom

# b.创建nova数据库
MariaDB [(none)]> CREATE DATABASE nova;

# c.创建数据库用户nova，并授予nova用户对nova数据库的完全控制权限。
MariaDB [(none)]> GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'NOVA_DBPASS';
MariaDB [(none)]> GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'NOVA_DBPASS'; 


## 2、执行admin环境脚本
[root@controller ~]# source admin-openrc.sh


## 3、在认证服务中创建计算服务的认证信息
# a.创建nova用户
[root@controller ~]# keystone user-create --name nova --pass NOVA_PASS
+----------+----------------------------------+
| Property |              Value               |
+----------+----------------------------------+
|  email   |                                  |
| enabled  |               True               |
|    id    | 23098de2ccb245fbae33d0610faf13b8 |
|   name   |               nova               |
| username |               nova               |
+----------+----------------------------------+

# b.链接nova用户到service租户和admin角色
[root@controller ~]# keystone user-role-add --user nova --tenant service --role admin

# c.创建nova服务
[root@controller ~]# keystone service-create --name nova --type compute --description "OpenStack Compute"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |        OpenStack Compute         |
|   enabled   |               True               |
|      id     | 32d7f428ba144840a1c8062368d9cd87 |
|     name    |               nova               |
|     type    |             compute              |
+-------------+----------------------------------+


## 4、创建计算服务端点
# keystone endpoint-create \
--service-id $(keystone service-list | awk '/ compute / {print $2}') \
--publicurl http://controller.markli.cn:8774/v2/%\(tenant_id\)s \
--internalurl http://controller.markli.cn:8774/v2/%\(tenant_id\)s \
--adminurl http://controller.markli.cn:8774/v2/%\(tenant_id\)s \
--region regionOne
+-------------+---------------------------------------------------+
|   Property  |                       Value                       |
+-------------+---------------------------------------------------+
|   adminurl  | http://controller.markli.cn:8774/v2/%(tenant_id)s |
|      id     |          c98e124f5b8246ecbd2eea14805bac3c         |
| internalurl | http://controller.markli.cn:8774/v2/%(tenant_id)s |
|  publicurl  | http://controller.markli.cn:8774/v2/%(tenant_id)s |
|    region   |                     regionOne                     |
|  service_id |          32d7f428ba144840a1c8062368d9cd87         |
+-------------+---------------------------------------------------+
```



#### 4.3.2 安装和配置计算控制组件

```bash
## 1、安装软件包，确保安装的软件包一致且不漏安装
[root@controller ~]# yum install openstack-nova-api openstack-nova-cert openstack-nova-conductor openstack-nova-console openstack-nova-novncproxy openstack-nova-scheduler python-novaclient	


## 2、编辑/etc/nova/nova.conf文件，完成如下操作：
# a.编辑[database]小节(没有则新增)，配置数据库访问：
[database]
connection=mysql://nova:NOVA_DBPASS@controller.markli.cn/nova

# b.编辑[DEFAULT]小节，配置RabbitMQ消息队列访问：
[DEFAULT]
rpc_backend=rabbit
rabbit_host=controller.markli.cn
rabbit_userid=guest
rabbit_password=homsom	#密码在keystone服务部署时，安装Messaing Server时已经更改为homsom

# c.编辑[DEFAULT]和[keystone_authtoken]小节，配置认证服务
[DEFAULT]
auth_strategy=keystone

[keystone_authtoken]
auth_uri=http://controller.markli.cn:5000/v2.0
identity_uri=http://controller.markli.cn:35357
admin_tenant_name=service
admin_user=nova
admin_password=NOVA_PASS
---

# d.编辑[DEFAULT]小节,配置my_ip选项为controller节点的管理接口ip:
[DEFAULT]
my_ip=192.168.222.5

# e.编辑[DEFAULT]小节，配置VNCdialing服务的使用controller节点的管理接口ip：
[DEFAULT]
vncserver_listen=192.168.222.5
vncserver_proxyclient_address=192.168.222.5

# f.编辑[glance]小节,配置镜像服务器的位置：
[glance]
host=controller.markli.cn

# g.（可选）在[DEFAULT]小节中配置详细日志输出。方便排错。
[DEFAULT]
verbose=True


## 3、初始化计算数据库
[root@controller ~]# su -s /bin/sh -c "nova-manage db sync" nova
[root@controller ~]# mysql -uroot -p -e 'show tables from nova;'
Enter password: 
+--------------------------------------------+
| Tables_in_nova                             |
+--------------------------------------------+
| agent_builds                               |
| aggregate_hosts                            |
.....
```

```bash
[root@controller ~]# grep -Ev '#|^$' /etc/nova/nova.conf
[DEFAULT]
rabbit_host=controller.markli.cn
rabbit_userid=guest
rabbit_password=homsom
rpc_backend=rabbit
my_ip=192.168.222.5
auth_strategy=keystone
verbose=True
vncserver_listen=192.168.222.5
vncserver_proxyclient_address=192.168.222.5
[baremetal]
[cells]
[cinder]
[conductor]
[ephemeral_storage_encryption]
[glance]
host=controller.markli.cn
[hyperv]
[image_file_url]
[ironic]
[keymgr]
[keystone_authtoken]
auth_uri=http://controller.markli.cn:5000/v2.0
identity_uri=http://controller.markli.cn:35357
admin_user=nova
admin_password=NOVA_PASS
admin_tenant_name=service
[libvirt]
[matchmaker_redis]
[matchmaker_ring]
[metrics]
[neutron]
[osapi_v3]
[rdp]
[serial_console]
[spice]
[ssl]
[trusted_computing]
[upgrade_levels]
[vmware]
[xenserver]
[zookeeper]
[database]
connection=mysql://nova:NOVA_DBPASS@controller.markli.cn/nova
```





#### 4.3.3 完成安装

启动计算服务并配置开机自动启动：

```bash
[root@controller ~]# systemctl enable openstack-nova-api.service openstack-nova-cert.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service

[root@controller ~]# systemctl start openstack-nova-api.service openstack-nova-cert.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service

## 验证安装
[root@controller ~]# nova service-list
+----+------------------+----------------------+----------+---------+-------+----------------------------+-----------------+
| Id | Binary           | Host                 | Zone     | Status  | State | Updated_at                 | Disabled Reason |
+----+------------------+----------------------+----------+---------+-------+----------------------------+-----------------+
| 1  | nova-scheduler   | controller.markli.cn | internal | enabled | up    | 2023-04-09T06:14:51.000000 | -               |
| 2  | nova-consoleauth | controller.markli.cn | internal | enabled | up    | 2023-04-09T06:14:51.000000 | -               |
| 3  | nova-cert        | controller.markli.cn | internal | enabled | up    | 2023-04-09T06:14:51.000000 | -               |
| 4  | nova-conductor   | controller.markli.cn | internal | enabled | up    | 2023-04-09T06:14:51.000000 | -               |
+----+------------------+----------------------+----------+---------+-------+----------------------------+-----------------+

```





### 4.4 构建实验之compute节点

* 安装并配置计算虚拟化组件
* 完成安装



#### 4.4.1 安装并配置计算虚拟化组件

```bash
## 1、安装软件包
[root@nova ~]# yum install openstack-nova-compute sysfsutils


## 2、编辑/etc/nova/nova.conf文件，完成下列步骤：
# a.编辑[DEFAULT]小节，配置RabbitMQ消息队列访问：
[DEFAULT]
rpc_backend=rabbit
rabbit_host=controller.markli.cn
rabbit_userid=guest
rabbit_password=homsom

# b.编辑[DEFAULT]和[keystone_authtoken]小节，配置认证服务访问：
[DEFAULT]
auth_strategy=keystone

[keystone_authtoken]
auth_uri=http://controller.markli.cn:5000/v2.0
identity_uri=http://controller.markli.cn:35357
admin_tenant_name=service
admin_user=nova
admin_password=NOVA_PASS

# c.编辑[DEFAULT]小节，配置my_ip配置项：
[DEFAULT]
my_ip=192.168.222.10

# d.编辑[DEFAULT]小节，开启并配置远程控制台访问
[DEFAULT]
vnc_enabled=True
vncserver_listen=0.0.0.0
vncserver_proxyclient_address=192.168.222.10
novncproxy_base_url=http://controller.markli.cn:6080/vnc_auto.html

# e.编辑[glance]小节，配置镜像服务器位置
[glance]
host=controller.markli.cn

# f.（可选）在[DEFAULT]小节中配置详细日志输出。方便排错。
[DEFAULT]
verbose=True
```

```bash
[root@nova ~]# grep -Ev '#|^$' /etc/nova/nova.conf
[DEFAULT]
rabbit_host=controller.markli.cn
rabbit_userid=guest
rabbit_password=homsom
rpc_backend=rabbit
my_ip=192.168.222.10
auth_strategy=keystone
verbose=True
novncproxy_base_url=http://controller.markli.cn:6080/vnc_auto.html
vncserver_listen=0.0.0.0
vncserver_proxyclient_address=192.168.222.10
vnc_enabled=True
[baremetal]
[cells]
[cinder]
[conductor]
[ephemeral_storage_encryption]
[glance]
host=controller.markli.cn
[hyperv]
[image_file_url]
[ironic]
[keymgr]
[keystone_authtoken]
auth_uri=http://controller.markli.cn:5000/v2.0
identity_uri=http://controller.markli.cn:35357
admin_user=nova
admin_password=NOVA_PASS
admin_tenant_name=service
[libvirt]
[matchmaker_redis]
[matchmaker_ring]
[metrics]
[neutron]
[osapi_v3]
[rdp]
[serial_console]
[spice]
[ssl]
[trusted_computing]
[upgrade_levels]
[vmware]
[xenserver]
[zookeeper]
```



#### 4.4.2 完成安装

```bash
## 1、确认你的计算节点是否支持硬件虚拟化
[root@nova ~]# egrep -c '(vmx|svm)' /proc/cpuinfo
0
#---------
#如果返回值>=1,则说明你的计算节点硬件支持虚拟化，无需额外配置。
#如果返回值=0，则说明你的计算节点硬件不支持虚拟化，你必须配置libvirt由使用KVM改为QEMU。
#---------


## 2、由以上得知，此硬件不支持虚拟化，需要在/etc/nova/nova.conf中把虚拟化类型配置为qemu
[libvirt]
virt_type=qemu


## 3、启动计算服务及依赖服务，并设置他们开机自动启动
[root@nova ~]# systemctl enable libvirtd.service openstack-nova-compute.service
[root@nova ~]# systemctl start libvirtd.service
[root@nova ~]# systemctl start openstack-nova-compute.service


#### 如果有多个compute节点，也是如上配置
```



#### 4.4.3 验证安装

在controller节点上验证安装

```bash
## 1、启用admin环境脚本
[root@controller ~]# source admin-openrc.sh 


## 2、列出服务组件确认每一个进程启动成功
[root@controller ~]# nova service-list
+----+------------------+----------------------+----------+---------+-------+----------------------------+-----------------+
| Id | Binary           | Host                 | Zone     | Status  | State | Updated_at                 | Disabled Reason |
+----+------------------+----------------------+----------+---------+-------+----------------------------+-----------------+
| 1  | nova-scheduler   | controller.markli.cn | internal | enabled | up    | 2023-04-09T06:48:12.000000 | -               |
| 2  | nova-consoleauth | controller.markli.cn | internal | enabled | up    | 2023-04-09T06:48:12.000000 | -               |
| 3  | nova-cert        | controller.markli.cn | internal | enabled | up    | 2023-04-09T06:48:13.000000 | -               |
| 4  | nova-conductor   | controller.markli.cn | internal | enabled | up    | 2023-04-09T06:48:13.000000 | -               |
| 5  | nova-compute     | nova.markli.cn       | nova     | enabled | up    | 2023-04-09T06:48:18.000000 | -               |
+----+------------------+----------------------+----------+---------+-------+----------------------------+-----------------+


## 3、列出镜像服务中的镜像列表，确认连接认证服务器和镜像服务器成功
[root@controller ~]# nova image-list
+--------------------------------------+---------------------+--------+--------+
| ID                                   | Name                | Status | Server |
+--------------------------------------+---------------------+--------+--------+
| 07e17807-8720-468c-a9d8-bf51bcc3314b | cirros-0.3.3-x86_64 | ACTIVE |        |
+--------------------------------------+---------------------+--------+--------+
```







## 5. Neutron服务



### 5.1 网络相关知识

![L2/L3](.\image\openstack\openstack15.png)

![集成网络](.\image\openstack\openstack16.png)

![存在区别](.\image\openstack\openstack17.png)

![路由表](.\image\openstack\openstack18.png)

![防火墙](.\image\openstack\openstack19.png)

![混杂模式](.\image\openstack\openstack20.png)

![网络名字命名空间](.\image\openstack\openstack21.png)

![叠加网络](.\image\openstack\openstack22.png)

![GRE SDN 网络优缺点](.\image\openstack\openstack23.png)

![解决问题](.\image\openstack\openstack24.png)

![接口类型](.\image\openstack\openstack25.png)

![Open vswitch](.\image\openstack\openstack26.png)







### 5.2 Neutron网络

![](.\image\openstack\openstack27.png)

**Neutron 基本概念**

* 网络连接服务 
* 面向租户 API 接口，用于创建虚拟网络、路由器、负载均衡、关联 网络接口至指定网络和路由 
* 通过 API 接口管理虚拟或物理交换机 
* 提供 Plugin 架构来支持不同的技术平台 
* Neutron Private Network – 提供固定私网地址 
* Neutron Public Network – 提供浮动 IP 地址



**Neutron 相关概念**

* Network
  * 一个 L2 网络单元 
  * 租户可通过 Neutron API 创建自己的网络

* Subnet 
  * 一段 IPV4/IPV6 地址段
  * 为 Instance 提供私网或公网地址
* Router
  * 三层路由器 
  * 为租户的 Instance 提供路由功能 
* Port 
  * 虚拟交换机上的端口
  * 管理 Instance 的网卡

![](.\image\openstack\openstack28.png)

![Neutron 组件架构](.\image\openstack\openstack29.png)



![](.\image\openstack\openstack30.png)

![](.\image\openstack\openstack31.png)

![](.\image\openstack\openstack32.png)

![](.\image\openstack\openstack33.png)

![](.\image\openstack\openstack34.png)

![](.\image\openstack\openstack35.png)

![](.\image\openstack\openstack36.png)

![](.\image\openstack\openstack37.png)





### 5.3 构建实验之controller节点

* 配置先决条件
* 安装网络服务组件
* 配置网络服务组件
* 配置Modular Layer2(ML2)插件
* 配置计算服务使用Neutron
* 完成安装
* 验证



#### 5.3.1 配置先决条件

```bash
## 1、创建数据库，完成下列步骤：
# a.使用root用户连接mysql数据库
[root@controller ~]# mysql -u root -p

# b.创建neutron数据库
MariaDB [(none)]> CREATE DATABASE neutron;                                    

# c.创建数据库用户neutron，并授予neutron用户对neutron数据库完全控制权限
MariaDB [(none)]> GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'NEUTRON_DBPASS';
MariaDB [(none)]> GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'NEUTRON_DBPASS';


## 2、执行admin环境变量脚本
[root@controller ~]# source admin-openrc.sh


## 3、在认证服务中创建网络服务的认证信息，完成下列步骤：
# a.创建neutron用户
[root@controller ~]# keystone user-create --name neutron --pass NEUTRON_PASS
+----------+----------------------------------+
| Property |              Value               |
+----------+----------------------------------+
|  email   |                                  |
| enabled  |               True               |
|    id    | e8bafdcc40b447259f7b1740c2b1bdaf |
|   name   |             neutron              |
| username |             neutron              |
+----------+----------------------------------+

# b.连接neutron用户到serivce租户和admin角色
[root@controller ~]# keystone user-role-add --user neutron --tenant service --role admin

# c.创建neutron服务
[root@controller ~]# keystone service-create --name neutron --type network --description "OpenStack Networking"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |       OpenStack Networking       |
|   enabled   |               True               |
|      id     | 90ed666cc33d46e9b202dc1d4b1511a7 |
|     name    |             neutron              |
|     type    |             network              |
+-------------+----------------------------------+

# d.创建neutron服务端点
[root@controller ~]# keystone endpoint-create \
--service-id $(keystone service-list | awk '/ network / {print $2}') \
--publicurl http://controller.markli.cn:9696 \
--adminurl http://controller.markli.cn:9696 \
--internalurl http://controller.markli.cn:9696 \
--region regionOne
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
|   adminurl  | http://controller.markli.cn:9696 |
|      id     | 44cf1e222b6c42f7a06898e0e665a819 |
| internalurl | http://controller.markli.cn:9696 |
|  publicurl  | http://controller.markli.cn:9696 |
|    region   |            regionOne             |
|  service_id | 90ed666cc33d46e9b202dc1d4b1511a7 |
+-------------+----------------------------------+
```



#### 5.3.2 安装网络服务组件

```bash
[root@controller ~]# yum install openstack-neutron openstack-neutron-ml2 python-neutronclient which
--> Processing Conflict: python-neutron-2014.2.3-1.el7.noarch conflicts python-eventlet >= 0.16.0
--> Finished Dependency Resolution
Error: python-neutron conflicts with python2-eventlet-0.18.4-1.el7.noarch
 You could try using --skip-broken to work around the problem
 You could try running: rpm -Va --nofiles --nodigest

## 报错：因为之前安装了python2-eventlet-0.18.4-1.el7.noarch，而现在想安装python-eventlet却安装不上，提示python-eventlet版本是大于0.16.0的

## 原因：因为epel源没有低版本的python-eventlet-0.15.2，而http://repos.fedorapeople.org/repos/openstack/EOL/openstack-juno/epel-7/epel有此安装包，需要单独下载进行安装

# 下载python-eventlet-0.15.2-1.el7.noarch.rpm
[root@nexus-proxy /download]# curl -OL http://repos.fedorapeople.org/repos/openstack/EOL/openstack-juno/epel-7/epel/python-eventlet-0.15.2-1.el7.noarch.rpm
[root@nexus-proxy /download]# scp python-eventlet-0.15.2-1.el7.noarch.rpm root@controller.markli.cn:/download/

# 先卸载高版本软件，一定要加上--nodeps参数，表示 不移除此软件相关的依赖包，只移除此软件
[root@controller ~]# rpm -e --nodeps python2-eventlet-0.18.4-1.el7.noarch 
[root@controller ~]# ls /download/
python-eventlet-0.15.2-1.el7.noarch.rpm
[root@controller ~]# rpm -ivh /download/python-eventlet-0.15.2-1.el7.noarch.rpm 

# 再次安装成功
[root@controller ~]# yum install openstack-neutron openstack-neutron-ml2 python-neutronclient which
Is this ok [y/d/N]: y
[root@controller ~]# yum install openstack-neutron openstack-neutron-ml2 python-neutronclient which
Loaded plugins: fastestmirror, priorities
Loading mirror speeds from cached hostfile
Package openstack-neutron-2014.2.3-1.el7.noarch already installed and latest version
Package openstack-neutron-ml2-2014.2.3-1.el7.noarch already installed and latest version
Package python-neutronclient-2.3.9-1.el7.centos.noarch already installed and latest version
```



#### 5.3.3 配置网络服务组件

````bash
## 编辑/etc/neutron/neutron.conf文件，并完成下列操作
[root@controller ~]# vim /etc/neutron/neutron.conf
# a.编辑[database]小节，配置数据库访问
[database]
connection=mysql://neutron:NEUTRON_DBPASS@controller.markli.cn/neutron

# b.编辑[DEFAULT]小节，配置RabbitMQ消息队列访问：
[DEFAULT]
rpc_backend=rabbit
rabbit_host=controller.markli.cn
rabbit_userid=guest
rabbit_password=homsom

# c.编辑[DEFAULT]和[keystone_authtoken]小节，配置认证服务访问：
[DEFAULT]
auth_strategy=keystone

[keystone_authtoken]
auth_uri=http://controller.markli.cn:5000/v2.0
identity_uri=http://controller.markli.cn:35357
admin_tenant_name=service
admin_user=neutron
admin_password=NEUTRON_PASS

# d.编辑[DEFAULT]小节，启用Modular Layer2(ML2)插件,路由服务和重叠IP地址功能：
[DEFAULT]
core_plugin=ml2
service_plugins=router
allow_overlapping_ips=True

# e.编辑[DEFAULT]小节，配置当网络拓扑结构发生变化时通知计算服务：
[DEFAULT]
notify_nova_on_port_status_changes=True
notify_nova_on_port_data_changes=True
nova_url=http://controller.markli.cn:8774/v2
nova_admin_auth_url=http://controller.markli.cn:35357/v2.0
nova_region_name=regionOne
nova_admin_username=nova
nova_admin_tenant_id=f1e21cb223d94e82b695e1c2d277a77f
nova_admin_password=NOVA_PASS
# 注：可通过keystone tenant-get service，获取service租户ID。
```
[root@controller ~]# source admin-openrc.sh 
[root@controller ~]# keystone tenant-get service         
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |          Service Tenant          |
|   enabled   |               True               |
|      id     | f1e21cb223d94e82b695e1c2d277a77f |
|     name    |             service              |
+-------------+----------------------------------+
```

# f.（可选）在[DEFAULT]小节中配置详细日志输出。方便排错。
[DEFAULT]
verbose=True
````



#### 5.3.4 配置Modular Layer2(ML2)插件

```bash
## 编辑/etc/neutron/plugins/ml2/ml2_conf.ini文件，并完成下列操作
# a.编辑[ml2]小节，启用flat和generic routing encapsulation (GRE)网络类型驱动，配置GRE租户网络和OVS驱动机制。
[ml2]
type_drivers=flat,gre
tenant_network_types=gre
mechanism_drivers=openvswitch

# b.编辑[ml2_type_gre]小节，配置隧道标识范围：
[ml2_type_gre]
tunnel_id_ranges=1:1000

# c.编辑[securitygroup]小节，启用安全组，启用ipset并配置OVS防火墙驱动：
[securitygroup]
enable_security_group=True
enable_ipset=True
firewall_driver=neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
```



#### 5.3.5 配置计算服务使用Neutron

```bash
## 默认情况下，计算服务使用传统网络，为了使用Newtron我们需要重新配置。编辑/etc/nova/nova.conf文件，并完成下列操作
# a.编辑[DEFAULT]小节，配置API接口和驱动程序：
[DEFAULT]
network_api_class=nova.network.neutronv2.api.API
security_group_api=neutron
linuxnet_interface_driver=nova.network.linux_net.LinuxOVSInterfaceDriver
firewall_driver=nova.virt.firewall.NoopFirewallDriver

# b.编辑[neutron]小节，配置访问参数：
[neutron]
url=http://controller.markli.cn:9696
auth_strategy=keystone
admin_auth_url=http://controller.markli.cn:35357/v2.0
admin_tenant_name=service
admin_username=neutron
admin_password=NEUTRON_PASS
```



#### 5.3.6 完成配置

```bash
## 1、为ML2插件配置文件创建链接文件。
[root@controller ~]# ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini


## 2、初始化数据库
[root@controller ~]# su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade juno" neutron


## 3、重新启动计算服务
[root@controller ~]# systemctl restart openstack-nova-api.service openstack-nova-scheduler.service openstack-nova-conductor.service


## 4、启动网络服务并配置开机自动启动
[root@controller ~]# systemctl enable neutron-server.service
[root@controller ~]# systemctl start neutron-server.service
```



#### 5.3.7 验证

```bash
## 1、执行admin环境变量脚本
[root@controller ~]# source admin-openrc.sh


## 2、列出加载的扩展模块，确认成功启动neutron-server进程。
[root@controller ~]# neutron ext-list
+-----------------------+-----------------------------------------------+
| alias                 | name                                          |
+-----------------------+-----------------------------------------------+
| security-group        | security-group                                |
| l3_agent_scheduler    | L3 Agent Scheduler                            |
| ext-gw-mode           | Neutron L3 Configurable external gateway mode |
| binding               | Port Binding                                  |
| provider              | Provider Network                              |
| agent                 | agent                                         |
| quotas                | Quota management support                      |
| dhcp_agent_scheduler  | DHCP Agent Scheduler                          |
| l3-ha                 | HA Router extension                           |
| multi-provider        | Multi Provider Network                        |
| external-net          | Neutron external network                      |
| router                | Neutron L3 Router                             |
| allowed-address-pairs | Allowed Address Pairs                         |
| extraroute            | Neutron Extra Route                           |
| extra_dhcp_opt        | Neutron Extra DHCP opts                       |
| dvr                   | Distributed Virtual Router                    |
+-----------------------+-----------------------------------------------+
```





### 5.4 构建实验之Neutron节点

* 配置先决条件
* 安装网络组件
* 配置网络通用组件
* 配置Modular Layer 2 (ML2) plug-in
* 配置Layer-3 (L3) agent 
* 配置DHCP agent
* 配置metadata agent
* 配置Open vSwitch (OVS)服务
* 完成安装
* 验证



#### 5.4.1 配置先决条件

[root@controller ~]# ssh neutron.markli.cn

``` bash
## 编辑/etc/sysctl.conf文件，包含下列参数：
[root@neutron ~]# vim /etc/sysctl.conf 
net.ipv4.ip_forward=1
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0
[root@neutron ~]# sysctl --system
```



#### 5.4.2 安装网络组件

```bash
# 搜索依赖包
[root@neutron ~]# yum search python-eventlet --enablerepo=openstack
Loaded plugins: fastestmirror, priorities
Loading mirror speeds from cached hostfile
========================================================== N/S matched: python-eventlet ===========================================================
python-eventlet.noarch : Highly concurrent networking library
python2-eventlet-doc.noarch : Documentation for python-eventlet

# 安装低版本包，启用和禁用相关仓库，其实上面也可以使用此方法进行安装
[root@neutron ~]# yum install python-eventlet.noarch --enablerepo=openstack --disablerepo=epel

# 安装网络组件
[root@neutron ~]# yum install openstack-neutron openstack-neutron-ml2 openstack-neutron-openvswitch
```



#### 5.4.3 配置网络通用组件

```bash
## 网络通用组件配置包含认证机制，消息队列及插件。编辑/etc/neutron/neutron.conf文件并完成下列操作
[root@neutron ~]# vim /etc/neutron/neutron.conf
# a.编辑[database]小节，注释任何connection选项。因为network节点不能直接连接数据库。

# b.编辑[DEFAULT]小节，配置RabbitMQ消息队列访问
[DEFAULT]
rpc_backend=rabbit
rabbit_host=controller.markli.cn
rabbit_userid=guest
rabbit_password=homsom

# c.编辑[DEFAULT]和[keystone_authtoken]小节，配置认证服务访问：
[DEFAULT]
auth_strategy=keystone

[keystone_authtoken]
auth_uri=http://controller.markli.cn:5000/v2.0
identity_uri=http://controller.markli.cn:35357
admin_tenant_name=service
admin_user=neutron
admin_password=NEUTRON_PASS

# d.编辑[DEFAULT]小节，启用Modular Layer2(ML2)插件,路由服务和重叠IP地址功能：
[DEFAULT]
core_plugin=ml2
service_plugins=router
allow_overlapping_ips=True

# e.（可选）在[DEFAULT]小节中配置详细日志输出。方便排错。
[DEFAULT]
verbose=True
```



#### 5.4.4 配置Modular Layer 2 (ML2) plug-in

```bash
## ML2插件使用Open vSwitch (OVS)机制为虚拟机实例提供网络框架。编辑/etc/neutron/plugins/ml2/ml2_conf.ini文件并完成下列操作
[root@neutron ~]# vim /etc/neutron/plugins/ml2/ml2_conf.ini
# a.编辑[ml2]小节，启用flat和generic routing encapsulation (GRE)网络类型驱动，配置GRE租户网络和OVS驱动机制。
[ml2]
type_drivers=flat,gre
tenant_network_types=gre
mechanism_drivers=openvswitch

# b.编辑[ml2_type_flat]小节，配置外部网络：
[ml2_type_flat]
flat_networks=external

# c.编辑[ml2_type_gre]小节，配置隧道标识范围：
[ml2_type_gre]
tunnel_id_ranges=1:1000

# d.编辑[securitygroup]小节，启用安全组，启用ipset并配置OVS防火墙驱动：
[securitygroup]
enable_security_group=True
enable_ipset=True
firewall_driver=neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver

# e.编辑[ovs]小节,配置Open vSwitch (OVS) 代理
[ovs]
local_ip=172.16.0.6	#实例网络接口IP地址
tunnel_type=gre
enable_tunneling=True
bridge_mappings=external:br-ex
```

```bash
[root@controller ~]# ansible 192.168.222.6 -m shell -a 'hostname;ip a s'
192.168.222.6 | CHANGED | rc=0 >>
neutron.markli.cn
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:a2:c7:5d brd ff:ff:ff:ff:ff:ff
    inet 192.168.222.6/24 brd 192.168.222.255 scope global ens33
       valid_lft forever preferred_lft forever
3: ens34: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:a2:c7:67 brd ff:ff:ff:ff:ff:ff
    inet 172.16.0.6/24 brd 172.16.0.255 scope global ens34
       valid_lft forever preferred_lft forever
4: ens35: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:a2:c7:71 brd ff:ff:ff:ff:ff:ff
    inet 100.100.100.10/24 brd 100.100.100.255 scope global ens35
       valid_lft forever preferred_lft forever
```



#### 5.4.5 配置Layer-3 (L3) agent

```bash
## 编辑/etc/neutron/l3_agent.ini文件并完成下列配置
[root@neutron ~]# vim /etc/neutron/l3_agent.ini
# a.编辑[DEFAULT]小节，配置驱动，启用网络命名空间，配置外部网络桥接
[DEFAULT]
interface_driver=neutron.agent.linux.interface.OVSInterfaceDriver
use_namespaces=True
external_network_bridge=br-ex

# b.（可选）在[DEFAULT]小节中配置详细日志输出。方便排错。
[DEFAULT]
debug=True 
```



#### 5.4.6 配置DHCP agent

```bash
## 1、编辑/etc/neutron/dhcp_agent.ini文件并完成下列步骤：
[root@neutron ~]# vim /etc/neutron/dhcp_agent.ini
# a.编辑[DEFAULT]小节，配置驱动和启用命名空间
[DEFAULT]
interface_driver=neutron.agent.linux.interface.OVSInterfaceDriver
dhcp_driver=neutron.agent.linux.dhcp.Dnsmasq
use_namespaces=True

# b.（可选）在[DEFAULT]小节中配置详细日志输出。方便排错。
[DEFAULT]
debug=True


## 2、(可选,在VMware虚拟机中可能是必要的!)配置DHCP选项，将MUT改为1454bytes，以改善网络性能。
# a.编辑/etc/neutron/dhcp_agent.ini文件并完成下列步骤：编辑[DEFAULT]小节，启用dnsmasq配置：
[DEFAULT]
dnsmasq_config_file=/etc/neutron/dnsmasq-neutron.conf

# b.创建并编辑/etc/neutron/dnsmasq-neutron.conf文件并完成下列配置：启用DHCP MTU选项(26)并配置值为1454bytes
[root@neutron ~]# vim /etc/neutron/dnsmasq-neutron.conf
dhcp-option-force=26,1454
user=neutron
group=neutron

# c.终止任何已经存在的dnsmasq进行
pkill dnsmasq
```



#### 5.4.7 配置metadata agent

```bash
## 1、编辑/etc/neutron/metadata_agent.ini文件并完成下列配置：
[root@neutron ~]# vim /etc/neutron/metadata_agent.ini
# a.编辑[DEFAULT]小节，配置访问参数：
[DEFAULT]
auth_url=http://controller.markli.cn:5000/v2.0
auth_region=regionOne
admin_tenant_name=service
admin_user=neutron
admin_password=NEUTRON_PASS

# b.编辑[DEFAULT]小节,配置元数据主机：
[DEFAULT]
nova_metadata_ip=controller.markli.cn

# c.编辑[DEFAULT]小节，配置元数据代理共享机密暗号：
[DEFAULT]
metadata_proxy_shared_secret=METADATA_SECRET

# d.（可选）在[DEFAULT]小节中配置详细日志输出。方便排错。
[DEFAULT]
debug=True


## 2、在*****controller*****节点，编辑/etc/nova/nova.conf文件并完成下列配置
# 编辑[neutron]小节，启用元数据代理并配置机密暗号：
[root@controller ~]# vim /etc/nova/nova.conf
[neutron]
service_metadata_proxy=True
metadata_proxy_shared_secret=METADATA_SECRET


## 3、在*****controller*****节点，重新启动compute API服务
[root@controller ~]# systemctl restart openstack-nova-api.service                       
```



#### 5.4.8 配置Open vSwitch (OVS)服务

**回到neutron节点进行配置**

```bash
## 1、启动VOS服务并配置开机自动启动：
[root@neutron ~]# systemctl enable openvswitch.service && systemctl start openvswitch.service


## 2、添加外部网桥(external birdge)
[root@neutron ~]# ovs-vsctl add-br br-ex


## 3、添加一个端口到外部网桥，用于连接外部物理网络，ens35为连接外部网卡(VMnet3)接口名
[root@neutron ~]# ovs-vsctl add-port br-ex ens35 
```

```
[root@neutron ~]# ip a s 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:a2:c7:5d brd ff:ff:ff:ff:ff:ff
    inet 192.168.222.6/24 brd 192.168.222.255 scope global ens33
       valid_lft forever preferred_lft forever
3: ens34: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:a2:c7:67 brd ff:ff:ff:ff:ff:ff
    inet 172.16.0.6/24 brd 172.16.0.255 scope global ens34
       valid_lft forever preferred_lft forever
4: ens35: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:a2:c7:71 brd ff:ff:ff:ff:ff:ff
    inet 100.100.100.10/24 brd 100.100.100.255 scope global ens35
       valid_lft forever preferred_lft forever
5: ovs-system: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 1a:2e:dd:00:92:59 brd ff:ff:ff:ff:ff:ff
6: br-ex: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether e6:a1:ea:ad:1e:45 brd ff:ff:ff:ff:ff:ff
```



#### 5.4.8 完成安装

```bash
## 1、创建网络服务初始化脚本的符号连接
[root@neutron ~]# ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
[root@neutron ~]# cp /usr/lib/systemd/system/neutron-openvswitch-agent.service /usr/lib/systemd/system/neutron-openvswitch-agent.service.orig
[root@neutron ~]# sed -i 's,plugins/openvswitch/ovs_neutron_plugin.ini,plugin.ini,g' /usr/lib/systemd/system/neutron-openvswitch-agent.service 


## 2、启动网络服务并设置开机自动启动
[root@neutron ~]# systemctl enable neutron-openvswitch-agent.service neutron-l3-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service neutron-ovs-cleanup.service
[root@neutron ~]# systemctl start neutron-openvswitch-agent.service neutron-l3-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service neutron-ovs-cleanup.service
```



#### 5.4.9 验证(在controller节点执行下列命令)

```bash
## 1、执行admin环境变量脚本
[root@controller ~]# source admin-openrc.sh

## 2、列出neutron代理，确认启动neutron agents成功。              
[root@controller ~]# neutron agent-list
+--------------------------------------+--------------------+-------------------+-------+----------------+---------------------------+
| id                                   | agent_type         | host              | alive | admin_state_up | binary                    |
+--------------------------------------+--------------------+-------------------+-------+----------------+---------------------------+
| 382bb3e0-043d-48ea-8bc5-7eccaae78f91 | L3 agent           | neutron.markli.cn | :-)   | True           | neutron-l3-agent          |
| 6fe95f69-e5a2-4858-ab26-3380692bfea2 | DHCP agent         | neutron.markli.cn | :-)   | True           | neutron-dhcp-agent        |
| 72b72f8b-6232-4139-a913-41121996330b | Open vSwitch agent | neutron.markli.cn | :-)   | True           | neutron-openvswitch-agent |
| 868ecf4f-2ef5-47e4-9ebc-7615bd45f690 | Metadata agent     | neutron.markli.cn | :-)   | True           | neutron-metadata-agent    |
+--------------------------------------+--------------------+-------------------+-------+----------------+---------------------------+
```





### 5.5 安装并配置compute1节点

* 配置先决条件
* 安装网络组件
* 配置网络通用组件
* 配置Modular Layer 2 (ML2) plug-in
* 配置Open vSwitch (OVS) service
* 配置计算服务使用网络
* 完成安装
* 验证



#### 5.5.1 配置先决条件

```bash
## 1、编辑/etc/sysctl.conf文件，使其包含下列参数：
[root@nova ~]# vim /etc/sysctl.conf
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0

## 2、使/etc/sysctl.conf文件中的更改生效：
[root@nova ~]# sysctl -p
```



#### 5.5.2 安装网络组件

```bash
# 安装低版本包，启用和禁用相关仓库，其实上面也可以使用此方法进行安装
[root@nova ~]# rpm -e --nodeps python2-eventlet-0.18.4-1.el7.noarch 
[root@nova ~]# yum install python-eventlet.noarch --enablerepo=openstack --disablerepo=epel

# 安装网络组件
[root@nova ~]# yum install openstack-neutron-ml2 openstack-neutron-openvswitch
```



#### 5.5.3 配置网络通用组件

```bash
## 编辑/etc/neutron/neutron.conf文件并完成下列操作：
[root@nova ~]# vim /etc/neutron/neutron.conf
# a.编辑[database]小节，注释左右connection配置项。因为计算节点不能直接连接数据库。

# b.编辑[DEFAULT]小节，配置RabbitMQ消息代理访问：
[DEFAULT]
rpc_backend=rabbit
rabbit_host=controller.markli.cn
rabbit_userid=guest
rabbit_password=homsom

# c.编辑[DEFAULT]和[keystone_authtoken]小节，配置认证服务访问：
[DEFAULT]
auth_strategy=keystone

[keystone_authtoken]
auth_uri=http://controller.markli.cn:5000/v2.0
identity_uri=http://controller.markli.cn:35357
admin_tenant_name=service
admin_user=neutron
admin_password=NEUTRON_PASS

# d.编辑[DEFAULT]小节，启用Modular Layer2(ML2)插件，路由服务和重叠ip地址功能：
[DEFAULT]
core_plugin=ml2
service_plugins=router
allow_overlapping_ips=True

# d.（可选）在[DEFAULT]小节中配置详细日志输出。方便排错。
[DEFAULT]
verbose=True
```



#### 5.5.4 配置Modular Layer 2 (ML2) plug-in

```bash
## 编辑/etc/neutron/plugins/ml2/ml2_conf.ini文件并完成下列操作
[root@nova ~]# vim /etc/neutron/plugins/ml2/ml2_conf.ini
# a.编辑[ml2]小节，启用flat和generic routing encapsulation (GRE)网络类型驱动，GRE租户网络和OVS机制驱动：
[ml2]
type_drivers=flat,gre
tenant_network_types=gre
mechanism_drivers=openvswitch

# b.编辑[ml2_type_gre]小节，配置隧道标识符(id)范围：
[ml2_type_gre]
tunnel_id_ranges=1:1000

# c.编辑[securitygroup]小节，启用安全组，ipset并配置OVS iptables防火墙驱动：
[securitygroup]
enable_security_group=True
enable_ipset=True
firewall_driver=neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver

# d.编辑[ovs]小节，配置Open vSwitch (OVS) agent：
[ovs]
local_ip=172.16.0.10	#本地实例网络接口ip地址
tunnel_type=gre
enable_tunneling=True
```



#### 5.5.5 配置Open vSwitch (OVS) service

```bash
# 启动OVS服务并设置开机自动启动：
[root@nova ~]# systemctl enable openvswitch.service && systemctl start openvswitch.service
```



#### 5.5.6 配置计算服务使用网络

```bash
## 编辑/etc/nova/nova.conf文件并完成下列操作：
[root@nova ~]# vim /etc/nova/nova.conf
# a.编辑[DEFAULT]小节,配置API接口和驱动：
[DEFAULT]
network_api_class=nova.network.neutronv2.api.API
security_group_api=neutron
linuxnet_interface_driver=nova.network.linux_net.LinuxOVSInterfaceDriver
firewall_driver=nova.virt.firewall.NoopFirewallDriver

# b.编辑[neutron]小节，配置访问参数：
[neutron]
url=http://controller.markli.cn:9696
auth_strategy=keystone
admin_auth_url=http://controller.markli.cn:35357/v2.0
admin_tenant_name=service
admin_username=neutron
admin_password=NEUTRON_PASS
```



#### 5.5.7 完成安装

```bash
## 1、创建网络服务初始化脚本的符号连接
[root@nova ~]# ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
[root@nova ~]# cp /usr/lib/systemd/system/neutron-openvswitch-agent.service /usr/lib/systemd/system/neutron-openvswitch-agent.service.orig
[root@nova ~]# sed -i 's,plugins/openvswitch/ovs_neutron_plugin.ini,plugin.ini,g' /usr/lib/systemd/system/neutron-openvswitch-agent.service


## 2、重启计算服务：
[root@nova ~]# systemctl restart openstack-nova-compute.service


## 3、启动OVS代理服务并设置开机自动启动：
[root@nova ~]# systemctl enable neutron-openvswitch-agent.service && systemctl start neutron-openvswitch-agent.service
```



#### 5.5.8 验证(在controller节点执行下列命令)

```bash
## 1、执行admin环境变量脚本
[root@controller ~]# source admin-openrc.sh 


## 2、列出neutron代理，确认启动neutron agents成功。
[root@controller ~]# neutron agent-list
+--------------------------------------+--------------------+-------------------+-------+----------------+---------------------------+
| id                                   | agent_type         | host              | alive | admin_state_up | binary                    |
+--------------------------------------+--------------------+-------------------+-------+----------------+---------------------------+
| 382bb3e0-043d-48ea-8bc5-7eccaae78f91 | L3 agent           | neutron.markli.cn | :-)   | True           | neutron-l3-agent          |
| 6fe95f69-e5a2-4858-ab26-3380692bfea2 | DHCP agent         | neutron.markli.cn | :-)   | True           | neutron-dhcp-agent        |
| 72b72f8b-6232-4139-a913-41121996330b | Open vSwitch agent | neutron.markli.cn | :-)   | True           | neutron-openvswitch-agent |
| 868ecf4f-2ef5-47e4-9ebc-7615bd45f690 | Metadata agent     | neutron.markli.cn | :-)   | True           | neutron-metadata-agent    |
| ac348813-d8c2-48cc-921b-88cde4dfd7be | Open vSwitch agent | nova.markli.cn    | :-)   | True           | neutron-openvswitch-agent |
+--------------------------------------+--------------------+-------------------+-------+----------------+---------------------------+
```





### 5.6 创建第一个网络

![](.\image\openstack\openstack38.png)



**配置外部网络(在controller节点执行后面的命令)**

* 创建一个外部网络
* 创建一个外部网络的子网



#### 5.6.1 创建一个外部网络

```bash
## 1、执行admin环境变量脚本
[root@controller ~]# source admin-openrc.sh


## 2、创建网络，物理网络为external，上面绑定了VMnet3的接口ens35，IP：100.100.100.10
[root@controller ~]# neutron net-create ext-net --shared --router:external True --provider:physical_network external --provider:network_type flat 
Created a new network:
+---------------------------+--------------------------------------+
| Field                     | Value                                |
+---------------------------+--------------------------------------+
| admin_state_up            | True                                 |
| id                        | 220a0286-174f-49c4-b0c5-9eb98cff99a6 |
| name                      | ext-net                              |
| provider:network_type     | flat                                 |
| provider:physical_network | external                             |
| provider:segmentation_id  |                                      |
| router:external           | True                                 |
| shared                    | True                                 |
| status                    | ACTIVE                               |
| subnets                   |                                      |
| tenant_id                 | e530df3ff8e14bcfada8f49fe4413e68     |
+---------------------------+--------------------------------------+
```



#### 5.6.2 创建一个外部网络的子网

```bash
## 创建子网：
# neutron subnet-create ext-net --name ext-subnet \
--allocation-pool start=FLOATING_IP_START,end=FLOATING_IP_END \
--disable-dhcp --gateway EXTERNAL_NETWORK_GATEWAY EXTERNAL_NETWORK_CIDR
FLOATING_IP_STAR=起始IP
FLOATING_IP_END=结束IP
EXTERNAL_NETWORK_GATEWAY=外部网络网关
EXTERNAL_NETWORK_CIDR=外部网络网段


## 例如，外网网段为：100.100.100.0/24，浮动地址范围为：100.100.100.100~100.100.100.200，网关为：100.100.100.10
[root@controller ~]# neutron subnet-create ext-net --name ext-subnet --allocation-pool start=100.100.100.100,end=100.100.100.200 --disable-dhcp --gateway 100.100.100.10 100.100.100.0/24
Created a new subnet:
+-------------------+--------------------------------------------------------+
| Field             | Value                                                  |
+-------------------+--------------------------------------------------------+
| allocation_pools  | {"start": "100.100.100.100", "end": "100.100.100.200"} |
| cidr              | 100.100.100.0/24                                       |
| dns_nameservers   |                                                        |
| enable_dhcp       | False                                                  |
| gateway_ip        | 100.100.100.10                                         |
| host_routes       |                                                        |
| id                | bd8a5f03-828a-4e92-a9e5-b2b7e98b959c                   |
| ip_version        | 4                                                      |
| ipv6_address_mode |                                                        |
| ipv6_ra_mode      |                                                        |
| name              | ext-subnet                                             |
| network_id        | 220a0286-174f-49c4-b0c5-9eb98cff99a6                   |
| tenant_id         | e530df3ff8e14bcfada8f49fe4413e68                       |
+-------------------+--------------------------------------------------------+
```





### 5.7 配置租户网络(在controller节点执行后面的命令)

* 创建租户网络 
* 创建租户网络的子网 
* 在租户网络创建一个路由器，用来连接外部网和租户网



#### 5.7.1 创建一个租户网络

```bash
## 1、执行demo环境变量脚本
[root@controller ~]# source demo-openrc.sh


## 2、创建租户网络
[root@controller ~]# neutron net-create demo-net
Created a new network:
+-----------------+--------------------------------------+
| Field           | Value                                |
+-----------------+--------------------------------------+
| admin_state_up  | True                                 |
| id              | e3f030ee-50f9-491b-a5a0-e4d4f5f5bbf3 |
| name            | demo-net                             |
| router:external | False                                |
| shared          | False                                |
| status          | ACTIVE                               |
| subnets         |                                      |
| tenant_id       | 29dd9bfe34324be8b979ad93be76fce5     |
+-----------------+--------------------------------------+
```



#### 5.7.2 创建一个租户网络的子网

```bash
## 创建子网：
#neutron subnet-create demo-net --name demo-subnet \
--gateway TENANT_NETWORK_GATEWAY TENANT_NETWORK_CIDR
TENANT_NETWORK_GATEWAY=租户网的网关
TENANT_NETWORK_CIDR=租户网的网段


## 例如，租户网的网段为192.168.2.0/24，网关为192.168.2.1(网关通常默认为.1)
[root@controller ~]# neutron subnet-create demo-net --name demo-subnet --gateway 192.168.2.1 192.168.2.0/24
Created a new subnet:
+-------------------+--------------------------------------------------+
| Field             | Value                                            |
+-------------------+--------------------------------------------------+
| allocation_pools  | {"start": "192.168.2.2", "end": "192.168.2.254"} |
| cidr              | 192.168.2.0/24                                   |
| dns_nameservers   |                                                  |
| enable_dhcp       | True                                             |
| gateway_ip        | 192.168.2.1                                      |
| host_routes       |                                                  |
| id                | ead23a92-96ef-4ed4-b665-2d4d8d789d29             |
| ip_version        | 4                                                |
| ipv6_address_mode |                                                  |
| ipv6_ra_mode      |                                                  |
| name              | demo-subnet                                      |
| network_id        | e3f030ee-50f9-491b-a5a0-e4d4f5f5bbf3             |
| tenant_id         | 29dd9bfe34324be8b979ad93be76fce5                 |
+-------------------+--------------------------------------------------+
```



#### 5.7.3 在租户网络创建一个路由器，用来连接外部网和租户网

```bash
## 1、创建路由器
[root@controller ~]# neutron router-create demo-router
Created a new router:
+-----------------------+--------------------------------------+
| Field                 | Value                                |
+-----------------------+--------------------------------------+
| admin_state_up        | True                                 |
| external_gateway_info |                                      |
| id                    | d55547f5-e034-49a8-a5c9-0560ba7e00af |
| name                  | demo-router                          |
| routes                |                                      |
| status                | ACTIVE                               |
| tenant_id             | 29dd9bfe34324be8b979ad93be76fce5     |
+-----------------------+--------------------------------------+


## 2、附加路由器到demo租户的子网
[root@controller ~]# neutron router-interface-add demo-router demo-subnet
Added interface acb779fc-60c0-4bb2-b3d6-dacc94f3989a to router demo-router.


## 3、通过设置网关，使路由器附加到外部网络
[root@controller ~]# neutron router-gateway-set demo-router ext-net
Set gateway for router demo-router
```



#### 5.7.4 确认连接

```bash
## 1、查看路由器获取到的IP
[root@controller ~]# neutron router-list
+--------------------------------------+-------------+---------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------+
| id                                   | name        | external_gateway_info
                                                                                                |
+--------------------------------------+-------------+---------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------+
| d55547f5-e034-49a8-a5c9-0560ba7e00af | demo-router | {"network_id": "220a0286-174f-49c4-b0c5-9eb98cff99a6", "enable_snat": true, "external_fixed_
ips": [{"subnet_id": "bd8a5f03-828a-4e92-a9e5-b2b7e98b959c", "ip_address": "100.100.100.100"}]} |
+--------------------------------------+-------------+---------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------+

## 2、在任何一台外部主机上ping路由器获取到的外部地址
***** 经过测试有问题，100.100.100.10和100.100.100.100无法ping通，需要调试
```



