#ceph
<pre>
版本区分，生产环境一定要使用小版本号为2的版本安装 
x.0.z：开发版
x.1.z：候选版
x.2.z：稳定版

3节点ceph集群：
一主两备，3副本
一块盘一个OSD进程，每个OSD ID都是唯一的
没有选举概念
系统盘做RAID1，每个系统数据盘做RAID0，可以节省磁盘空间，统一SSD硬盘（统一规格大小）。
客户端挂载使用的是Ceph协议，也可以通过NFS转Ceph协议进行挂载，但是有损耗

#一个ceph集群的组成部分：
若干的Ceph OSD(对象存储守护程序)
至少需要一个Ceph Monitors监视器（1，3，5，7...）
两个或以上的Ceph管理器managers,运行Ceph文件系统客户端时还需要高可用的Ceph Metadata Server（文件系统元数据服务器）
RADOS cluster: 由多台host存储服务器组成的ceph集群
OSD(Object Storage Daemon): 每台存储服务器的磁盘组成的存储空间
Mon（Monitor）：ceph的监视器，维护OSD和PG的集群状态，一个ceph集群至少要有一个mon,可以是一三五七等等这样的奇数个。
Mgr(Manager): 负责跟踪运行时指标和Ceph集群的当前状态，包括存储利用率，当前性能指标和系统负载等。
MDS(ceph 元数据服务器 ceph-mds):代表 ceph 文件系统(NFS/CIFS)存储元数据，(即 Ceph 块设备和 Ceph 对象存储不使用
MDS)
Ceph 的管理节点：
1.ceph 的常用管理接口是一组命令行工具程序，例如 rados、ceph、rbd 等命令，ceph 管
理员可以从某个特定的 ceph-mon 节点执行管理操作
2.推荐使用部署专用的管理节点对 ceph 进行配置管理、升级与后期维护，方便后期权限管
理，管理节点的权限只对管理人员开放，可以避免一些不必要的误操作的发生。

ceph 逻辑组织架构：
Pool：存储池、分区，存储池的大小取决于底层的存储空间。
PG(placement group)：一个 pool 内部可以有多个 PG 存在，pool 和 PG 都是抽象的逻辑概
念，一个 pool 中有多少个 PG 可以通过公式计算。
OSD(Object Storage Daemon,对象存储设备):每一块磁盘都是一个 osd，一个主机由一个或
多个 osd 组成.
ceph 集群部署好之后,要先创建存储池才能向 ceph 写入数据，文件在向 ceph 保存之前要
先进行一致性 hash 计算，计算后会把文件保存在某个对应的 PG 的，此文件一定属于某个
pool 的一个 PG，在通过 PG 保存在 OSD 上。
数据对象在写到主 OSD 之后再同步对从 OSD 以实现数据的高可用。


#一致性hash和CRUSH算法：
file_name --> object(oid) --> 一致性hash -->　哪个pool中的pg(得出pgid，例如2.11) --> CRUSH算法通过pgid算出其它副本PG(例如为PG1,PG2)
ceph将一个对象映射到RADOS集群的时候分为两步走：
	1. 首先使用一致性hash算法将对象名称映射到PG2.7(例如，pool为2，PG为7)
	2. 然后将PG ID 基于CRUSH算法映射到OSD即可查到对象
以上两个过程都是以“实时计算”的方式完成，而没有使用传统的查询数据与块设备的对应表的方式，这样有效避免了组件的“中心化”问题，也解决了查询 性能和冗余问题，使得ceph集群扩展不再受查询的性能限制。

这个实时计算操作使用的就是CRUSH算法：
	Controllers replication under scalable hashing #可控的、可复制的、可伸缩的一致性hash算法
	CRUSH是一种分布式算法，类似于一致性hash算法，用于为RADOS存储集群控制数据的分配。

bluestore比filestore新，在filestore时候元数据写在管理服务器某个磁盘路径上，会有双写问题。bluestore元数据写在每个OSD中的blueFS文件系统中，其它的数据叫RockDB,会在每个OSD中开辟一个blueFS空间，bluestore效率和性能都比filestore好，现在都使用bluestore


#部署ceph集群：
硬件规划：
元数据服务器对CPU敏感：大于4核CPU
元数据服务器和监视器必须可以尽快地提供它们的数据 ，所以他们应该有足够的内存，至少每进程1G
1. 硬件要求：
生产最低要求：
osd节点最低3个，16C32G，若干数据硬盘
mon节点3个，用于高可用，16c16g，200G硬盘
mgr节点两个，16c16g，200G硬盘
存储服务器osd：企业级SSD
网卡：万兆网卡，或者PCIE万兆网卡
2. 测试环境角色：
节点系统：Ubuntu 18.04.5 LTS 
ceph版本：16.2.5
ceph部署方式：ceph-deploy
部署用户可以是其它用户，ceph系统用户是ceph
192.168.13.31: ceph01.hs.com   ceph-mon01    ceph-mgr01     ceph-osd01
192.168.13.32: ceph02.hs.com   ceph-mon02	 ceph-mgr02		ceph-osd02
192.168.13.33: ceph03.hs.com   ceph-mon03   				ceph-osd03
192.168.13.34: ceph04.hs.com   ceph-deploy
network：
192.168.13.31: publicNetwork:eth0:192.168.13.31	privateNetwork:eth1:10.10.13.31
192.168.13.32: publicNetwork:eth0:192.168.13.32	privateNetwork:eth1:10.10.13.32
192.168.13.33: publicNetwork:eth0:192.168.13.33	privateNetwork:eth1:10.10.13.33
192.168.13.34: publicNetwork:eth0:192.168.13.34	privateNetwork:eth1:10.10.13.34
hard:
192.168.13.31: os 1块 + 数据盘10G 5块
192.168.13.32: os 1块 + 数据盘10G 5块
192.168.13.33: os 1块 + 数据盘10G 5块
192.168.13.34: os 1块 
3. 配置节点网络和主机名解析
网络：
[root@ubuntu /srv/salt/dev]# sudo salt 'ceph*' cmd.run 'cat /etc/netplan/50-cloud-init.yaml'
ceph03.hs.com:
    network:
      version: 2
      ethernets:
        eth0:
          dhcp4: false
          optional: true
          addresses:
           - 192.168.13.33/24
          gateway4: 192.168.13.254
          nameservers:
            search:
            - hs.com
            addresses:
            - 192.168.10.250
            - 192.168.10.110
        eth1:
          addresses:
           - 10.10.13.33/24
ceph02.hs.com:
    network:
      version: 2
      ethernets:
        eth0:
          dhcp4: false
          optional: true
          addresses:
           - 192.168.13.32/24
          gateway4: 192.168.13.254
          nameservers:
            search:
            - hs.com
            addresses:
            - 192.168.10.250
            - 192.168.10.110
        eth1:
          addresses:
           - 10.10.13.32/24
ceph04.hs.com:
    network:
      version: 2
      ethernets:
        eth0:
          dhcp4: false
          optional: true
          addresses:
           - 192.168.13.34/24
          gateway4: 192.168.13.254
          nameservers:
            search:
            - hs.com
            addresses:
            - 192.168.10.250
            - 192.168.10.110
        eth1:
          addresses:
           - 10.10.13.34/24
ceph01.hs.com:
    network:
      version: 2
      ethernets:
        eth0:
          dhcp4: false
          optional: true
          addresses:
           - 192.168.13.31/24
          gateway4: 192.168.13.254
          nameservers:
            search:
            - hs.com
            addresses:
            - 192.168.10.250
            - 192.168.10.110
        eth1:
          addresses:
           - 10.10.13.31/24
--主机名解析：
[root@ubuntu /srv/salt/dev]# sudo salt 'ceph*' cp.get_file salt://ceph/hosts /etc/hosts saltenv=dev
[root@ubuntu /srv/salt/dev]# sudo salt 'ceph*' cmd.run 'cat /etc/hosts'
ceph04.hs.com:
    127.0.0.1 localhost
    #ceph resolv
    192.168.13.31 ceph01.hs.com   ceph-mon01    ceph-mgr01      ceph-osd01
    192.168.13.32 ceph02.hs.com   ceph-mon02    ceph-mgr02      ceph-osd02
    192.168.13.33 ceph03.hs.com   ceph-mon03                    ceph-osd03
    192.168.13.34 ceph04.hs.com   ceph-deploy
ceph01.hs.com:
    127.0.0.1 localhost
    #ceph resolv
    192.168.13.31 ceph01.hs.com   ceph-mon01    ceph-mgr01      ceph-osd01
    192.168.13.32 ceph02.hs.com   ceph-mon02    ceph-mgr02      ceph-osd02
    192.168.13.33 ceph03.hs.com   ceph-mon03                    ceph-osd03
    192.168.13.34 ceph04.hs.com   ceph-deploy
ceph02.hs.com:
    127.0.0.1 localhost
    #ceph resolv
    192.168.13.31 ceph01.hs.com   ceph-mon01    ceph-mgr01      ceph-osd01
    192.168.13.32 ceph02.hs.com   ceph-mon02    ceph-mgr02      ceph-osd02
    192.168.13.33 ceph03.hs.com   ceph-mon03                    ceph-osd03
    192.168.13.34 ceph04.hs.com   ceph-deploy
ceph03.hs.com:
    127.0.0.1 localhost
    #ceph resolv
    192.168.13.31 ceph01.hs.com   ceph-mon01    ceph-mgr01      ceph-osd01
    192.168.13.32 ceph02.hs.com   ceph-mon02    ceph-mgr02      ceph-osd02
    192.168.13.33 ceph03.hs.com   ceph-mon03                    ceph-osd03
    192.168.13.34 ceph04.hs.com   ceph-deploy
4. 仓库准备：
各节点配置 ceph yum 仓库：
导入 key 文件: ~# wget -q -O- 'https://mirrors.tuna.tsinghua.edu.cn/ceph/keys/release.asc' | sudo apt-key add -
[root@ubuntu /srv/salt/dev]# sudo salt 'ceph*' cmd.run "wget -q -O- 'https://mirrors.tuna.tsinghua.edu.cn/ceph/keys/release.asc' | sudo apt-key add -"
[root@ubuntu /srv/salt/dev]# sudo salt 'ceph*' cmd.run 'sudo echo "deb https://mirrors.tuna.tsinghua.edu.cn/ceph/debian-pacific bionic main ">> /etc/apt/sources.list'
[root@ubuntu /srv/salt/dev]# sudo salt 'ceph*' cmd.run 'sudo apt update'
5. 创建 ceph 用户：
推荐使用指定的普通用户部署和运行 ceph 集群，普通用户只要能以非交互方式执行 sudo
命令执行一些特权命令即可，新版的 ceph-deploy 可以指定包含 root 的在内只要可以执行
sudo 命令的用户，不过仍然推荐使用普通用户，比如 ceph、cephuser、cephadmin 这样
的用户去管理 ceph 集群。
在包含 ceph-deploy 节点的存储节点、mon 节点和 mgr 节点等创建 ceph 用户。
[root@ubuntu /srv/salt/dev]# sudo salt 'ceph*' cmd.run 'groupadd -r -g 2022 ceph && useradd -r -m -u 2022 -g 2022 ceph && echo ceph:123456 | chpasswd'
--各服务器允许 ceph 用户以 sudo 执行特权命令：
[root@ubuntu /srv/salt/dev]# sudo salt 'ceph*' cmd.run 'echo "ceph ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && grep "ceph ALL" /etc/sudoers'
6. 配置免秘钥登录（此步骤建议在第9步操作）：
在 ceph-deploy 节点配置允许以非交互的方式登录到各 ceph node/mon/mgr 节点，即在ceph-deploy 节点(ceph04.hs.com)生成秘钥对，然后分发公钥到各被管理节点：
ceph@ceph04:~$ su - ceph
ceph@ceph04:~$ ssh-keygen
ceph@ceph04:~$ ssh-copy-id ceph@192.168.13.31
ceph@ceph04:~$ ssh-copy-id ceph@192.168.13.32
ceph@ceph04:~$ ssh-copy-id ceph@192.168.13.33
7. 在部署节点上安装 ceph 部署工具：
[root@ceph04 ~]# apt list --all-versions ceph-deploy
ceph-deploy/stable,stable 2.0.1 all
ceph-deploy/bionic,bionic 1.5.38-0ubuntu1 all
[root@ceph04 ~]# sudo apt -y install ceph-deploy=2.0.1
8. 初始化生成配置文件：
--Ubuntu 各服务器需要单独安装 Python2：
[root@ubuntu /srv/salt/dev]# sudo salt 'ceph*' cmd.run 'apt install python2.7 -y'
[root@ubuntu /srv/salt/dev]# sudo salt 'ceph*' cmd.run 'ln -sv /usr/bin/python2.7 /usr/bin/python2'
[root@ubuntu /srv/salt/dev]# sudo salt 'ceph*' cmd.run 'ls -l /usr/bin/python2'
ceph04.hs.com:
    lrwxrwxrwx 1 root root 18 Nov 27 22:11 /usr/bin/python2 -> /usr/bin/python2.7
ceph03.hs.com:
    lrwxrwxrwx 1 root root 18 Nov 27 22:09 /usr/bin/python2 -> /usr/bin/python2.7
ceph02.hs.com:
    lrwxrwxrwx 1 root root 18 Nov 27 22:09 /usr/bin/python2 -> /usr/bin/python2.7
ceph01.hs.com:
    lrwxrwxrwx 1 root root 18 Nov 27 22:09 /usr/bin/python2 -> /usr/bin/python2.7
--初始化mon节点
ceph@ceph04:~$ mkdir ceph-cluster
ceph@ceph04:~/ceph-cluster$ ceph-deploy new --cluster-network 10.10.13.0/24 --public-network 192.168.13.0/24 ceph01.hs.com
[ceph01.hs.com][DEBUG ] IP addresses found: [u'192.168.13.31', u'172.17.0.1', u'172.19.0.1', u'10.10.13.31']
ceph@ceph04:~/ceph-cluster$ ls
ceph.conf  ceph-deploy-ceph.log  ceph.mon.keyring
ceph@ceph04:~/ceph-cluster$ cat ceph.conf
[global]
fsid = 4d5745dd-5f75-485d-af3f-eeaad0c51648
public_network = 192.168.13.0/24
cluster_network = 10.10.13.0/24
mon_initial_members = ceph01
mon_host = 192.168.13.31
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx
9. 配置 mon 节点并生成及同步秘钥：
在所有节点安装ceph-mon包，安装后会自己安装ceph用户会覆盖之前创建的用户ceph，gid和uid不会变，但用户家目录已经改变了，所以之前的免密登录失效，需要重新执行免密登录步骤
apt install -y ceph-mon
----初始化mon节点key，自己会读取ceph.conf配置文件进行初始化:
root@ceph04:~$ su - ceph
$ cd /home/ceph/ceph-cluster/
$ ceph-deploy mon create-initial
$ ls
ceph.bootstrap-mds.keyring  ceph.bootstrap-osd.keyring  ceph.client.admin.keyring  ceph-deploy-ceph.log
ceph.bootstrap-mgr.keyring  ceph.bootstrap-rgw.keyring  ceph.conf                  ceph.mon.keyring
--（在ceph01.hs.com节点上）验证第一台mon服务器是否装好：
[root@ceph01 ~]# ps aux | grep ceph-mon
ceph      5405  0.8  1.0 480412 40688 ?        Ssl  22:36   0:02 /usr/bin/ceph-mon -f --cluster ceph --id ceph01 --setuser ceph --setgroup ceph
root      5831 19.0  0.0  15508  2004 pts/0    S+   22:42   0:00 grep --color=auto ceph-mon
10. 分发admin秘钥：
在 ceph-deploy 节点把配置文件和 admin 密钥拷贝至 Ceph 集群需要执行 ceph 管理命令的节点，从而不需要后期通过 ceph 命令对 ceph 集群进行管理配置的时候每次都需要指定ceph-mon 节点地址和 ceph.client.admin.keyring 文件,另外各 ceph-mon 节点也需要同步ceph 的集群配置文件与认证文件：
--在所有节点上安装ceph-common
apt install -y ceph-common #先安装 ceph 的公共组件,安装的节点就有了管理ceph集群的管理命令了
root@ceph04:~/ceph-cluster$ su - ceph
$ mv /home/ceph/ceph-cluster/ /var/lib/ceph/
$ cd ~/ceph-cluster/
$ ls
ceph.bootstrap-mds.keyring  ceph.bootstrap-osd.keyring  ceph.client.admin.keyring  ceph-deploy-ceph.log
ceph.bootstrap-mgr.keyring  ceph.bootstrap-rgw.keyring  ceph.conf                  ceph.mon.keyring
$ ceph -s
2021-11-28T19:27:15.874+0800 7f65f1d37700 -1 auth: unable to find a keyring on /etc/ceph/ceph.client.admin.keyring,/etc/ceph/ceph.keyring,/etc/ceph/keyring,/etc/ceph/keyring.bin,: (2) No such file or directory
2021-11-28T19:27:15.874+0800 7f65f1d37700 -1 AuthRegistry(0x7f65ec05b4f8) no keyring found at /etc/ceph/ceph.client.admin.keyring,/etc/ceph/ceph.keyring,/etc/ceph/keyring,/etc/ceph/keyring.bin,, disabling cephx
2021-11-28T19:27:15.882+0800 7f65f0ad5700 -1 auth: unable to find a keyring on /etc/ceph/ceph.client.admin.keyring,/etc/ceph/ceph.keyring,/etc/ceph/keyring,/etc/ceph/keyring.bin,: (2) No such file or directory
2021-11-28T19:27:15.882+0800 7f65f0ad5700 -1 AuthRegistry(0x7f65ec05f3e0) no keyring found at /etc/ceph/ceph.client.admin.keyring,/etc/ceph/ceph.keyring,/etc/ceph/keyring,/etc/ceph/keyring.bin,, disabling cephx
2021-11-28T19:27:15.914+0800 7f65f0ad5700 -1 auth: unable to find a keyring on /etc/ceph/ceph.client.admin.keyring,/etc/ceph/ceph.keyring,/etc/ceph/keyring,/etc/ceph/keyring.bin,: (2) No such file or directory
2021-11-28T19:27:15.914+0800 7f65f0ad5700 -1 AuthRegistry(0x7f65f0ad4000) no keyring found at /etc/ceph/ceph.client.admin.keyring,/etc/ceph/ceph.keyring,/etc/ceph/keyring,/etc/ceph/keyring.bin,, disabling cephx
[errno 2] RADOS object not found (error connecting to the cluster)
--此时有集群管理命令，但是没有权限进行管理，此时需要同步ceph.client.admin.keyring 文件和ceph.conf文件到能管理集群的节点上,例如同步到本节点（ceph-deploy）上：
$ ceph-deploy admin ceph-deploy
--ceph 节点验证秘钥：
$ ls -l /etc/ceph/
total 12
-rw------- 1 root root 151 Nov 28 19:40 ceph.client.admin.keyring
-rw-r--r-- 1 root root 262 Nov 28 19:40 ceph.conf
-rw-r--r-- 1 root root  92 Sep 16 22:38 rbdmap
-rw------- 1 root root   0 Nov 28 19:40 tmp3yHcUr
--认证文件的属主和属组为了安全考虑，默认设置为了 root 用户和 root 组，如果需要ceph用户也能执行 ceph 命令，那么就需要对 ceph 用户进行授权:
--安装setfacl命令进行授权
$ sudo apt install -y apt-file
$ sudo apt-file update
$ sudo apt-file search setfacl
$ sudo apt install -y acl
$ sudo setfacl -m u:ceph:rw /etc/ceph/ceph.client.admin.keyring
--此时可以查看ceph集群状态了，此时ceph-mon节点就已经初始化完成了
$ ceph -s
  cluster:
    id:     4d5745dd-5f75-485d-af3f-eeaad0c51648
    health: HEALTH_WARN
            mon is allowing insecure global_id reclaim

  services:
    mon: 1 daemons, quorum ceph01 (age 21h)
    mgr: no daemons active
    osd: 0 osds: 0 up, 0 in

  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   0 B used, 0 B / 0 B avail
    pgs:
11. 部署 ceph-mgr 节点：
--在所有(三个节点)mgr节点不安装包
apt install ceph-mgr
--配置ceph-deploy免密登录 
$ ssh-keygen
$ ssh-copy-id ceph@ceph01.hs.com
$ ssh-copy-id ceph@ceph02.hs.com
$ ssh-copy-id ceph@ceph03.hs.com
--添加mgr节点，在mgr节点上运行的是一个mgr服务，自己会设置开机自启动
$ ceph-deploy mgr create ceph-mgr01
[ceph-mgr01][INFO  ] Running command: sudo systemctl start ceph-mgr@ceph-mgr01
[ceph-mgr01][INFO  ] Running command: sudo systemctl enable ceph.target
--查看mgr服务是否启动
[root@ceph01 ~]# systemctl status ceph-mgr@ceph-mgr01 | grep Active
   Active: active (running) since Sun 2021-11-28 20:09:28 CST; 3min 12s ago
[root@ceph01 ~]# ps aux | grep mgr
ceph      8264 20.3  6.1 1119736 248624 ?      Ssl  20:09   0:27 /usr/bin/ceph-mgr -f --cluster ceph --id ceph-mgr01 --setuser ceph --setgroup ceph
--查看集群状态，此时已经添加了一个mrg节点ceph-mgr01了
$ ceph -s
  cluster:
    id:     4d5745dd-5f75-485d-af3f-eeaad0c51648
    health: HEALTH_WARN
            mon is allowing insecure global_id reclaim
            OSD count 0 < osd_pool_default_size 3

  services:
    mon: 1 daemons, quorum ceph01 (age 21h)
    mgr: ceph-mgr01(active, since 13m)
    osd: 0 osds: 0 up, 0 in

  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   0 B used, 0 B / 0 B avail
    pgs:
12. 初始化node(osd)节点
--指定node节点初始化，初始化时不替换节点的repo源、不作gpgcheck检查。此过程必须执行，否则node节点加入不了ceph集群，主要是节点磁盘报错导致加入不了， 安装后会在node节点安装ceph-volume等命令，此命令用于擦除磁盘
$ ceph-deploy install --no-adjust-repos --nogpgcheck ceph-osd01
$ ceph-deploy install --no-adjust-repos --nogpgcheck ceph-osd02
$ ceph-deploy install --no-adjust-repos --nogpgcheck ceph-osd03
13. 初始化ceph命令
$ ceph -s     
  cluster:
    id:     4d5745dd-5f75-485d-af3f-eeaad0c51648
    health: HEALTH_WARN
            mon is allowing insecure global_id reclaim     --有两个警告
            OSD count 0 < osd_pool_default_size 3

  services:
    mon: 1 daemons, quorum ceph01 (age 22h)
    mgr: ceph-mgr01(active, since 30m)
    osd: 0 osds: 0 up, 0 in

  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   0 B used, 0 B / 0 B avail
    pgs:
$ ceph config set mon auth_allow_insecure_global_id_reclaim false  --配置后没有警告了
$ ceph -s
  cluster:
    id:     4d5745dd-5f75-485d-af3f-eeaad0c51648
    health: HEALTH_WARN
            OSD count 0 < osd_pool_default_size 3

  services:
    mon: 1 daemons, quorum ceph01 (age 22h)
    mgr: ceph-mgr01(active, since 32m)
    osd: 0 osds: 0 up, 0 in

  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   0 B used, 0 B / 0 B avail
    pgs:
14. 准备 OSD 节点：
$ ceph-deploy install --release pacifi ceph-osd01  #擦除磁盘之前通过 deploy 节点对 node 节点执行安装 ceph 基本运行环境，之前通过ceph-deploy install --no-adjust-repos --nogpgcheck ceph-osd01进行安装过了,此步骤省略
--列出node磁盘
$ cd ceph-cluster/
$ ceph-deploy disk list ceph-osd01 ceph-osd02 ceph-osd03
[ceph_deploy.conf][DEBUG ] found configuration file at: /var/lib/ceph/.cephdeploy.conf
[ceph_deploy.cli][INFO  ] Invoked (2.0.1): /usr/bin/ceph-deploy disk list ceph-osd01 ceph-osd02 ceph-osd03
[ceph_deploy.cli][INFO  ] ceph-deploy options:
[ceph_deploy.cli][INFO  ]  username                      : None
[ceph_deploy.cli][INFO  ]  verbose                       : False
[ceph_deploy.cli][INFO  ]  debug                         : False
[ceph_deploy.cli][INFO  ]  overwrite_conf                : False
[ceph_deploy.cli][INFO  ]  subcommand                    : list
[ceph_deploy.cli][INFO  ]  quiet                         : False
[ceph_deploy.cli][INFO  ]  cd_conf                       : <ceph_deploy.conf.cephdeploy.Conf instance at 0x7f18f5511500>
[ceph_deploy.cli][INFO  ]  cluster                       : ceph
[ceph_deploy.cli][INFO  ]  host                          : ['ceph-osd01', 'ceph-osd02', 'ceph-osd03']
[ceph_deploy.cli][INFO  ]  func                          : <function disk at 0x7f18f54e76d0>
[ceph_deploy.cli][INFO  ]  ceph_conf                     : None
[ceph_deploy.cli][INFO  ]  default_release               : False
[ceph-osd01][DEBUG ] connection detected need for sudo
[ceph-osd01][DEBUG ] connected to host: ceph-osd01
[ceph-osd01][DEBUG ] detect platform information from remote host
[ceph-osd01][DEBUG ] detect machine type
[ceph-osd01][DEBUG ] find the location of an executable
[ceph-osd01][INFO  ] Running command: sudo fdisk -l
[ceph-osd01][INFO  ] Disk /dev/xvdg: 10 GiB, 10737418240 bytes, 20971520 sectors
[ceph-osd01][INFO  ] Disk /dev/xvde: 10 GiB, 10737418240 bytes, 20971520 sectors
[ceph-osd01][INFO  ] Disk /dev/xvdb: 10 GiB, 10737418240 bytes, 20971520 sectors
[ceph-osd01][INFO  ] Disk /dev/xvdc: 10 GiB, 10737418240 bytes, 20971520 sectors
[ceph-osd01][INFO  ] Disk /dev/xvdf: 10 GiB, 10737418240 bytes, 20971520 sectors
[ceph-osd01][INFO  ] Disk /dev/xvda: 20 GiB, 21474836480 bytes, 41943040 sectors
[ceph-osd01][INFO  ] Disk /dev/mapper/ceph01--vg-root: 19 GiB, 20447232000 bytes, 39936000 sectors
[ceph-osd02][DEBUG ] connection detected need for sudo
[ceph-osd02][DEBUG ] connected to host: ceph-osd02
[ceph-osd02][DEBUG ] detect platform information from remote host
[ceph-osd02][DEBUG ] detect machine type
[ceph-osd02][DEBUG ] find the location of an executable
[ceph-osd02][INFO  ] Running command: sudo fdisk -l
[ceph-osd02][INFO  ] Disk /dev/xvde: 10 GiB, 10737418240 bytes, 20971520 sectors
[ceph-osd02][INFO  ] Disk /dev/xvdc: 10 GiB, 10737418240 bytes, 20971520 sectors
[ceph-osd02][INFO  ] Disk /dev/xvdb: 10 GiB, 10737418240 bytes, 20971520 sectors
[ceph-osd02][INFO  ] Disk /dev/xvdf: 10 GiB, 10737418240 bytes, 20971520 sectors
[ceph-osd02][INFO  ] Disk /dev/xvdg: 10 GiB, 10737418240 bytes, 20971520 sectors
[ceph-osd02][INFO  ] Disk /dev/xvda: 20 GiB, 21474836480 bytes, 41943040 sectors
[ceph-osd02][INFO  ] Disk /dev/mapper/ceph02--vg-root: 19 GiB, 20447232000 bytes, 39936000 sectors
[ceph-osd03][DEBUG ] connection detected need for sudo
[ceph-osd03][DEBUG ] connected to host: ceph-osd03
[ceph-osd03][DEBUG ] detect platform information from remote host
[ceph-osd03][DEBUG ] detect machine type
[ceph-osd03][DEBUG ] find the location of an executable
[ceph-osd03][INFO  ] Running command: sudo fdisk -l
[ceph-osd03][INFO  ] Disk /dev/xvdg: 10 GiB, 10737418240 bytes, 20971520 sectors
[ceph-osd03][INFO  ] Disk /dev/xvda: 20 GiB, 21474836480 bytes, 41943040 sectors
[ceph-osd03][INFO  ] Disk /dev/xvde: 10 GiB, 10737418240 bytes, 20971520 sectors
[ceph-osd03][INFO  ] Disk /dev/xvdc: 10 GiB, 10737418240 bytes, 20971520 sectors
[ceph-osd03][INFO  ] Disk /dev/xvdf: 10 GiB, 10737418240 bytes, 20971520 sectors
[ceph-osd03][INFO  ] Disk /dev/xvdb: 10 GiB, 10737418240 bytes, 20971520 sectors
[ceph-osd03][INFO  ] Disk /dev/mapper/ceph03--vg-root: 19 GiB, 20447232000 bytes, 39936000 sectors
--在ceph-deploy上对node节点上的磁盘进行擦除，不用建立磁盘分区，ceph自己会建立分区的
ceph-deploy disk zap ceph-osd01 /dev/xvdb
ceph-deploy disk zap ceph-osd01 /dev/xvdc
ceph-deploy disk zap ceph-osd01 /dev/xvde
ceph-deploy disk zap ceph-osd01 /dev/xvdf
ceph-deploy disk zap ceph-osd01 /dev/xvdg

ceph-deploy disk zap ceph-osd02 /dev/xvdb
ceph-deploy disk zap ceph-osd02 /dev/xvdc
ceph-deploy disk zap ceph-osd02 /dev/xvde
ceph-deploy disk zap ceph-osd02 /dev/xvdf
ceph-deploy disk zap ceph-osd02 /dev/xvdg

ceph-deploy disk zap ceph-osd03 /dev/xvdb
ceph-deploy disk zap ceph-osd03 /dev/xvdc
ceph-deploy disk zap ceph-osd03 /dev/xvde
ceph-deploy disk zap ceph-osd03 /dev/xvdf
ceph-deploy disk zap ceph-osd03 /dev/xvdg
15. 添加 OSD：
数据分类保存方式：
Data：即 ceph 保存的对象数据
Block: rocks DB 数据即元数据
block-wal：数据库的 wal 日志
$ ceph-deploy osd --help
For bluestore, optional devices can be used::
    ceph-deploy osd create {node} --data /path/to/data --block-db /path/to/db-device
    ceph-deploy osd create {node} --data /path/to/data --block-wal /path/to/wal-device
    ceph-deploy osd create {node} --data /path/to/data --block-db /path/to/db-device --block-wal /path/to/wal-device
For filestore, the journal must be specified, as well as the objectstore::
    ceph-deploy osd create {node} --filestore --data /path/to/data --journal /path/to/journal
注：现在都使用bluestore
--查看状态
$ ceph -s
  cluster:
    id:     4d5745dd-5f75-485d-af3f-eeaad0c51648
    health: HEALTH_WARN
            OSD count 0 < osd_pool_default_size 3

  services:
    mon: 1 daemons, quorum ceph01 (age 22h)
    mgr: ceph-mgr01(active, since 75m)
    osd: 0 osds: 0 up, 0 in

  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   0 B used, 0 B / 0 B avail
    pgs:
--添加osd,data、block、block-wal都安装在--data中
ceph-deploy osd create ceph-osd01 --data /dev/xvdb
ceph-deploy osd create ceph-osd01 --data /dev/xvdc
ceph-deploy osd create ceph-osd01 --data /dev/xvde
ceph-deploy osd create ceph-osd01 --data /dev/xvdf
ceph-deploy osd create ceph-osd01 --data /dev/xvdg

ceph-deploy osd create ceph-osd02 --data /dev/xvdb
ceph-deploy osd create ceph-osd02 --data /dev/xvdc
ceph-deploy osd create ceph-osd02 --data /dev/xvde
ceph-deploy osd create ceph-osd02 --data /dev/xvdf
ceph-deploy osd create ceph-osd02 --data /dev/xvdg

ceph-deploy osd create ceph-osd03 --data /dev/xvdb
ceph-deploy osd create ceph-osd03 --data /dev/xvdc
ceph-deploy osd create ceph-osd03 --data /dev/xvde
ceph-deploy osd create ceph-osd03 --data /dev/xvdf
ceph-deploy osd create ceph-osd03 --data /dev/xvdg
$ ceph -s
  cluster:
    id:     4d5745dd-5f75-485d-af3f-eeaad0c51648
    health: HEALTH_OK

  services:
    mon: 1 daemons, quorum ceph01 (age 23h)
    mgr: ceph-mgr01(active, since 95m)
    osd: 15 osds: 15 up (since 55s), 15 in (since 88s)

  data:
    pools:   1 pools, 512 pgs
    objects: 0 objects, 0 B
    usage:   161 MiB used, 150 GiB / 150 GiB avail
    pgs:     512 active+clean
--添加osd后再查看ceph状态，只要整个集群中osd大于等于3就不会再报警告了，其实在添加第三个osd时集群就不会报警告了
注：至此，ceph集群就部署好了，以后就是添加服务器、节点和osd
--设置 OSD 服务自启动:
默认就已经为自启动, node节点添加完成后,可以测试node服务器重启后，OSD 是否会自动启动

#管理ceph集群：
#--从RADOS集群删除OSD
Ceph 集群中的一个 OSD 是一个 node 节点的服务进程且对应于一个物理磁盘设备，是一个
专用的守护进程。在某 OSD 设备出现故障，或管理员出于管理之需确实要移除特定的 OSD
设备时，需要先停止相关的守护进程，而后再进行移除操作。对于 Luminous 及其之后的版
本来说，停止和移除命令的格式分别如下所示：
1. 停用设备：ceph osd out {osd-num}
2. 停止进程：sudo systemctl stop ceph-osd@{osd-num}
3. 移除设备：ceph osd purge {id} --yes-i-really-mean-it
若类似如下的 OSD 的配置信息存在于 ceph.conf 配置文件中，管理员在删除 OSD 之后手
动将其删除。
不过，对于 Luminous 之前的版本来说，管理员需要依次手动执行如下步骤删除 OSD 设备：
1. 于 CRUSH 运行图中移除设备：ceph osd crush remove {name}
2. 移除 OSD 的认证 key：ceph auth del osd.{osd-num}
3. 最后移除 OSD 设备：ceph osd rm {osd-num}

#--测试上传与下载数据：
存取数据时，客户端必须首先连接至 RADOS 集群上某存储池，然后根据对象名称由相关的
CRUSH 规则完成数据对象寻址。于是，为了测试集群的数据存取功能，这里首先创建一个
用于测试的存储池 mypool，并设定其 PG 数量为 32 个。
$ ceph osd pool create mypool 32 32
pool 'mypool' created
$ ceph pg ls-by-pool mypool | awk '{print $1,$2,$15}'
PG OBJECTS ACTING
2.0 0 [8,10,3]p8
2.1 0 [2,13,9]p2
2.2 0 [5,1,10]p5
2.3 0 [5,4,14]p5
2.4 0 [1,12,6]p1
2.5 0 [12,4,8]p12
2.6 0 [1,13,9]p1
2.7 0 [6,13,2]p6
2.8 0 [8,13,0]p8
2.9 0 [4,9,12]p4
2.a 0 [11,4,8]p11
2.b 0 [13,7,4]p13
2.c 0 [12,0,5]p12
2.d 0 [12,8,3]p12
2.e 0 [2,13,8]p2
2.f 0 [11,8,0]p11
2.10 0 [10,1,8]p10
2.11 0 [6,1,12]p6
2.12 0 [10,3,9]p10
2.13 0 [13,6,3]p13
2.14 0 [8,13,0]p8
2.15 0 [10,1,5]p10
2.16 0 [8,12,1]p8
2.17 0 [6,14,2]p6
2.18 0 [13,9,2]p13
2.19 0 [3,6,13]p3
2.1a 0 [6,14,2]p6
2.1b 0 [11,7,3]p11
2.1c 0 [10,7,1]p10
2.1d 0 [10,7,0]p10
2.1e 0 [3,13,5]p3
2.1f 0 [4,7,14]p4
2.20 0 [8,10,3]p8
$ ceph osd tree
ID  CLASS  WEIGHT   TYPE NAME        STATUS  REWEIGHT  PRI-AFF
-1         0.14694  root default
-3         0.04898      host ceph01
 0    ssd  0.00980          osd.0        up   1.00000  1.00000
 1    ssd  0.00980          osd.1        up   1.00000  1.00000
 2    ssd  0.00980          osd.2        up   1.00000  1.00000
 3    ssd  0.00980          osd.3        up   1.00000  1.00000
 4    ssd  0.00980          osd.4        up   1.00000  1.00000
-5         0.04898      host ceph02
 5    ssd  0.00980          osd.5        up   1.00000  1.00000
 6    ssd  0.00980          osd.6        up   1.00000  1.00000
 7    ssd  0.00980          osd.7        up   1.00000  1.00000
 8    ssd  0.00980          osd.8        up   1.00000  1.00000
 9    ssd  0.00980          osd.9        up   1.00000  1.00000
-7         0.04898      host ceph03
10    ssd  0.00980          osd.10       up   1.00000  1.00000
11    ssd  0.00980          osd.11       up   1.00000  1.00000
12    ssd  0.00980          osd.12       up   1.00000  1.00000
13    ssd  0.00980          osd.13       up   1.00000  1.00000
14    ssd  0.00980          osd.14       up   1.00000  1.00000
$ ceph osd pool ls
device_health_metrics
mypool
$ rados lspools
device_health_metrics
mypool
----当前的 ceph 环境还没还没有部署使用块存储和文件系统使用 ceph，也没有使用对象存储的客户端，但是 ceph 的 rados 命令可以实现访问ceph 对象存储的功能：
$ ls -lh /usr/local/src/
-rw-r--r-- 1 root root 37M Oct 27 11:58 consul_1.10.3_linux_amd64.zip 
上传文件： 
$ sudo rados put msg1 /usr/local/src/consul_1.10.3_linux_amd64.zip --pool=mypool  #把 messages 文件上传到 mypool 并指定对象 id 为 msg1 
列出文件:
[ceph@ceph-deploy ceph-cluster]$ $ rados ls --pool=mypool
msg1
文件信息: ceph osd map 命令可以获取到存储池中数据对象的具体位置信息：
$ ceph osd map mypool msg1
osdmap e136 pool 'mypool' (2) object 'msg1' -> pg 2.c833d430 (2.30) -> up ([13,8,4], p13) acting ([13,8,4], p13)
表示文件放在了存储池 id 为 2 的 c833d430 的 PG 上,30 为当前 PG 的 id, 2.30 表示数据是
在 id 为 2 的存储池当中 id 为 30 的 PG 中存储，在线的 OSD 编号 13,8,4，主 OSD 为 13，
活动的 OSD 13,8,4，三个 OSD 表示数据放一共 3 个副本，PG 中的 OSD 是 ceph 的 crush
算法计算出三份数据保存在哪些 OSD。
修改文件：
$ sudo rados put msg1 /etc/passwd --pool=mypool
下载文件：
$ sudo rados get msg1 --pool=mypool /opt/my.txt
比较文件：
$ md5sum /etc/passwd
d8bb7df8470675207d1a728b27999baa  /etc/passwd
$ md5sum /opt/my.txt
d8bb7df8470675207d1a728b27999baa  /opt/my.txt
删除文件：
$ sudo rados rm msg1 --pool=mypool
$ rados ls --pool=mypool

#--扩展 ceph 集群实现高可用：
主要是扩展 ceph 集群的 mon 节点以及 mgr 节点，以实现集群高可用。
#----扩展 ceph-mon 节点:
Ceph-mon 是原生具备自选举以实现高可用机制的 ceph 服务，节点数量通常是奇数。
--在其它mon服务器上安装ceph-mon包：
[root@ceph02 ~]# apt install -y ceph-mon
[root@ceph03 ~]# apt install -y ceph-mon
--在ceph-deploy上添加mon,添加mon后自动会进行高可用
$ ceph-deploy mon add ceph-mon02
$ ceph-deploy mon add ceph-mon03
$ ceph -s
  cluster:
    id:     4d5745dd-5f75-485d-af3f-eeaad0c51648
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum ceph01,ceph02,ceph03 (age 2s)
    mgr: ceph-mgr01(active, since 2h)
    osd: 15 osds: 15 up (since 81m), 15 in (since 81m)

  data:
    pools:   2 pools, 768 pgs
    objects: 0 objects, 0 B
    usage:   309 MiB used, 150 GiB / 150 GiB avail
    pgs:     768 active+clean
--验证 ceph-mon 状态：
$ ceph quorum_status --format json-pretty
#----扩展 mgr 节点：
ceph-mgr两个节点可实现高可用，没有自主选举，用hello包进行探测，分active和standby模式，当active故障时standby会接管
[root@ceph02 ~]# apt install -y ceph-mgr
$ ceph-deploy mgr create ceph-mgr02
$ ceph -s
  cluster:
    id:     4d5745dd-5f75-485d-af3f-eeaad0c51648
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum ceph01,ceph02,ceph03 (age 8m)
    mgr: ceph-mgr01(active, since 3h), standbys: ceph-mgr02
    osd: 15 osds: 15 up (since 89m), 15 in (since 90m)

  data:
    pools:   2 pools, 768 pgs
    objects: 0 objects, 0 B
    usage:   309 MiB used, 150 GiB / 150 GiB avail
    pgs:     768 active+clean


#ceph 集群应用基础：










</pre>