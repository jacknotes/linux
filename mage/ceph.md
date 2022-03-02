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
MDS(ceph 元数据服务器 ceph-mds):代表 ceph 文件系统(NFS/CIFS)存储元数据(Ceph 块设备和 Ceph对象存储不使用MDS)

ceph基础：
Ceph 是一个开源的分布式存储系统，同时支持对象存储、块设备、文件系统.
ceph 是一个对象(object)式存储系统，它把每一个待管理的数据流(文件等数据)切分为一到多个固定大小(默认 4 兆)的对象数据，并以其为原子单元(原子是构成元素的最小单元)完成数据的读写。
对象数据的底层存储服务是由多个存储主机(host)组成的存储集群，该集群也被称之为RADOS(reliable automatic distributed object store)存储集群，即可靠的、自动化的、分布式的对象存储系统。
librados 是 RADOS 存储集群的 API，支持 C/C++/JAVA/python/ruby/php/go等编程语言客户端。

Ceph的管理节点：
1.ceph 的常用管理接口是一组命令行工具程序，例如 rados、ceph、rbd 等命令，ceph 管理员可以从某个特定的 ceph-mon 节点执行管理操作
2.推荐使用部署专用的管理节点对 ceph 进行配置管理、升级与后期维护，方便后期权限管理，管理节点的权限只对管理人员开放，可以避免一些不必要的误操作的发生。

ceph 逻辑组织架构：
Pool：存储池、分区，存储池的大小取决于底层的存储空间。
PG(placement group)：一个 pool 内部可以有多个 PG 存在，pool 和 PG 都是抽象的逻辑概念，一个 pool 中有多少个 PG 可以通过公式计算。
OSD(Object Storage Daemon,对象存储设备):每一块磁盘都是一个osd，一个主机由一个或多个 osd 组成.
ceph 集群部署好之后,要先创建存储池才能向ceph 写入数据，文件在向 ceph 保存之前要先进行一致性 hash 计算，计算后会把文件保存在某个对应的PG上，此文件一定属于某个pool 的一个 PG，在通过 PG 保存在 OSD 上。
数据对象在写到主 OSD 之后再同步对从 OSD 以实现数据的高可用。

#一致性hash和CRUSH算法：
file_name --> 分块(默认每块4M) --> 一个或多个oid(object id) --> 一致性hash -->　哪个pool中的pg(得出pgid，例如2.11) --> CRUSH算法通过pgid算出到OSD的映射，PG -> OSD 映射：[CRUSH(pgid)->(osd1,osd2,osd3)]
注：存储文件过程：
第一步: 计算文件到对象的映射: 计算文件到对象的映射,假如 file 为客户端要读写的文件,得到 oid(object id) = ino + ono
ino:inode number (INO)，File 的元数据序列号，File 的唯一 id。 
ono:object number (ONO)，File 切分产生的某个 object 的序号，默认以 4M 切分一个块大小。
第二步：通过 hash 算法计算出文件对应的 pool 中的 PG:
通过一致性 HASH 计算 Object 到哪个pool中的PG， Object -> PG 映射 hash(oid) & mask-> pgid
第三步: 通过 CRUSH 把对象映射到 PG 中的 OSD 通过 CRUSH 算法计算 PG 到 OSD，PG -> OSD 映射：[CRUSH(pgid)->(osd1,osd2,osd3)]
第四步：PG 中的主 OSD 将对象写入到硬盘
第五步: 主 OSD 将数据同步给备份 OSD,并等待备份 OSD 返回确认
第六步: 主 OSD 将写入完成返回给客户端


ceph将一个对象映射到RADOS集群的时候分为两步走：
	1. 首先使用一致性hash算法将对象名称映射到PG2.7(例如，pool为2，PG为7)
	2. 然后将PG ID 基于CRUSH算法映射到OSD即可查到对象
以上两个过程都是以“实时计算”的方式完成，而没有使用传统的查询数据与块设备的对应表的方式，这样有效避免了组件的“中心化”问题，也解决了查询 性能和冗余问题，使得ceph集群扩展不再受查询的性能限制。

这个实时计算操作使用的就是CRUSH算法：
	Controllers replication under scalable hashing #可控的、可复制的、可伸缩的一致性hash算法
	CRUSH是一种分布式算法，类似于一致性hash算法，用于为RADOS存储集群控制数据的分配。

bluestore比filestore新，在filestore时候元数据写在管理服务器某个磁盘路径上，会有双写问题。bluestore元数据写在每个OSD中的blueFS文件系统中，其它的数据叫RockDB,会在每个OSD中开辟一个blueFS空间，bluestore效率和性能都比filestore好，现在都使用bluestore


#部署ceph集群：
注：以下在配置ceph集群时默认都是在ceph-deploy节点进行操作
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
集群时间必须同步一致
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
3. 配置节点时间同步、网络和主机名解析
时间同步
[root@ubuntu ~]# sudo salt 'ceph*' cmd.run 'apt install ntpdate -y'
[root@ubuntu ~]# sudo salt 'ceph*' cmd.run 'echo "*/5 * * * * root ntpdate time.hs.com" >> /etc/crontab'
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
推荐使用指定的普通用户部署和运行 ceph 集群，普通用户只要能以非交互方式执行sudo命令执行一些特权命令即可，新版的 ceph-deploy 可以指定包含 root 在内只要可以执行sudo 命令的用户，不过仍然推荐使用普通用户，比如ceph、cephuser、cephadmin 这样的用户去管理 ceph 集群。在包含 ceph-deploy 节点的存储节点、mon 节点和 mgr 节点等创建 ceph 用户。
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
9. 配置 mon 节点并生成和同步秘钥：
在所有mon节点安装ceph-mon包，安装后会自己安装ceph用户会覆盖之前创建的用户ceph，gid和uid不会变，但用户家目录已经改变了，所以之前的免密登录失效，需要重新执行免密登录步骤
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
--在所有(三个节点)mgr节点上安装包
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
Ceph 集群中的一个 OSD 是一个 node 节点的服务进程且对应于一个物理磁盘设备，是一个专用的守护进程。在某 OSD 设备出现故障，或管理员出于管理之需确实要移除特定的OSD设备时，需要先停止相关的守护进程，而后再进行移除操作。对于Luminous及其之后的版本来说，停止和移除命令的格式分别如下所示：
1. 停用设备：ceph osd out {osd-num}
2. 停止进程：sudo systemctl stop ceph-osd@{osd-num}
3. 移除设备：ceph osd purge {id} --yes-i-really-mean-it
若类似如下的 OSD 的配置信息存在于 ceph.conf 配置文件中，管理员在删除 OSD 之后手动将其删除。不过，对于 Luminous 之前的版本来说，管理员需要依次手动执行如下步骤删除 OSD 设备：
1. 于 CRUSH 运行图中移除设备：ceph osd crush remove {name}
2. 移除 OSD 的认证 key：ceph auth del osd.{osd-num}
3. 最后移除 OSD 设备：ceph osd rm {osd-num}

#--测试上传与下载数据：
存取数据时，客户端必须首先连接至 RADOS 集群上某存储池，然后根据对象名称由相关的CRUSH 规则完成数据对象寻址。于是，为了测试集群的数据存取功能，这里首先创建一个用于测试的存储池 mypool，并设定其 PG 数量为 32 个。
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
[ceph@ceph-deploy ceph-cluster]$ rados ls --pool=mypool
msg1
文件信息: ceph osd map 命令可以获取到存储池中数据对象的具体位置信息：
$ ceph osd map mypool msg1
osdmap e136 pool 'mypool' (2) object 'msg1' -> pg 2.c833d430 (2.30) -> up ([13,8,4], p13) acting ([13,8,4], p13)
表示文件放在了存储池 id 为 2 的 c833d430 的 PG 上,30 为当前 PG 的 id, 2.30 表示数据是在 id 为 2 的存储池当中 id 为 30 的 PG 中存储，在线的 OSD 编号 13,8,4，主 OSD 为 13，活动的 OSD 13,8,4，三个 OSD 表示数据放一共 3 个副本，PG 中的 OSD 是 ceph 的 crush
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



###ceph 集群应用基础：
#4.1：块设备 RBD：
RBD(RADOS Block Devices)即为块存储的一种，RBD 通过 librbd 库与 OSD 进行交互，RBD为 KVM 等虚拟化技术和云服务（如 OpenStack 和 CloudStack）提供高性能和无限可扩展性的存储后端，这些系统依赖于 libvirt 和 QEMU 实用程序与 RBD进行集成，客户端基于librbd 库即可将 RADOS 存储集群用作块设备，不过用于 rbd 的存储池需要事先启用 rbd功能并进行初始化。例如，下面的命令创建一个名为 myrbd1 的存储池，并在启用 rbd 功能后对其进行初始化：

4.1.1:创建 RBD：
创建存储池命令格式：
ceph osd pool create <poolname> pg_num pgp_num {replicated|erasure}
$ceph osd pool create myrbd1 64 64 #创建存储池,指定 pg 和 pgp 的数量，pgp 是对存在于 pg 的数据进行组合存储，pgp 通常等于 pg 的值
pool 'myrdb1' created
$ ceph osd pool --help
$ ceph osd pool application enable myrbd1 rbd   #对存储池启用 RBD 功能
enabled application 'rbd' on pool 'myrdb1'
$ rbd -h
$ rbd pool init -p myrbd1 #通过 RBD 命令对存储池初始化

4.1.2:创建并验证 img：
不过，rbd存储池并不能直接用于块设备，而是需要事先在其中按需创建映像（image），并把映像文件作为块设备使用，rbd命令可用于创建、查看及删除块设备相关的映像（image），以及克隆映像、创建快照、将映像回滚到快照和查看快照等管理操作，例如，下面的命令能够创建一个名为 myimg1 的映像：
$ rbd create myimg1 --size 5G --pool myrbd1 
$ rbd create myimg2 --size 3G --pool myrbd1 --image-format 2 --image-feature layering
注：后续步骤会使用 myimg2 ，由于 centos 系统内核较低无法挂载使用，因此只开启部分特性。除了 layering 其他特性需要高版本内核支持
$ rbd ls --pool myrbd1	#列出指定的pool中所有的img
myimg1
myimg2
$ rbd --image myimg1 --pool myrbd1 info	#查看指定 rdb 的信息
rbd image 'myimg1':
        size 5 GiB in 1280 objects
        order 22 (4 MiB objects)      #2^22次方等于4M
        snapshot_count: 0
        id: 5e7395799f4e
        block_name_prefix: rbd_data.5e7395799f4e
        format: 2
        features: layering, exclusive-lock, object-map, fast-diff, deep-flatten
        op_features:
        flags:
        create_timestamp: Sat Dec  4 13:45:40 2021
        access_timestamp: Sat Dec  4 13:45:40 2021
        modify_timestamp: Sat Dec  4 13:45:40 2021
$ rbd --image myimg2 --pool myrbd1 info
rbd image 'myimg2':
        size 3 GiB in 768 objects
        order 22 (4 MiB objects)
        snapshot_count: 0
        id: 5e769e3b33d6
        block_name_prefix: rbd_data.5e769e3b33d6
        format: 2
        features: layering
        op_features:
        flags:
        create_timestamp: Sat Dec  4 13:45:49 2021
        access_timestamp: Sat Dec  4 13:45:49 2021
        modify_timestamp: Sat Dec  4 13:45:49 2021

4.1.3:客户端使用块存储：
4.1.3.1:当前 ceph 状态：
$ ceph df
--- RAW STORAGE ---
CLASS     SIZE    AVAIL     USED  RAW USED  %RAW USED
ssd    150 GiB  149 GiB  539 MiB   539 MiB       0.35
TOTAL  150 GiB  149 GiB  539 MiB   539 MiB       0.35
--- POOLS ---
POOL                   ID  PGS  STORED  OBJECTS    USED  %USED  MAX AVAIL
device_health_metrics   1  394     0 B        0     0 B      0     47 GiB
mypool                  2  256     0 B        0     0 B      0     47 GiB
myrbd1                  3   64   405 B        7  48 KiB      0     47 GiB
4.1.3.2:在客户端安装 ceph-common:
客户端服务器配置 yum 源及 ceph 认证文件：
--配置 yum 源：
[root@node01 ~]# yum install epel-release -y
--下载p版本(16)包，但是redhat平台没有，所以下载o版本(15)的ceph-common包也可以用
[root@node01 ~]# curl -L -o /download/ceph-release-1-1.el7.noarch.rpm https://mirrors.aliyun.com/ceph/rpm-octopus/el7/noarch/ceph-release-1-1.el7.noarch.rpm
或[root@node01 ~]# wget https://mirrors.aliyun.com/ceph/rpm-octopus/el7/noarch/ceph-release-1-1.el7.noarch.rpm -O /download/ceph-release-1-1.el7.noarch.rpm
或 [root@node01 ~]# wget https://mirrors.aliyun.com/ceph/rpm-octopus/el7/noarch/ceph-release-1-1.el7.noarch.rpm -P /download/
--查看rpm包文件列表
[root@node01 ~]# rpm -qlp  /download/ceph-release-1-1.el7.noarch.rpm
/etc/yum.repos.d/ceph.repo
[root@node01 ~]# rpm -ivh /download/ceph-release-1-1.el7.noarch.rpm
或yum install https://mirrors.aliyun.com/ceph/rpm-octopus/el7/noarch/ceph-release-1-1.el7.noarch.rpm -y
[root@node01 ~]# cat /etc/yum.repos.d/ceph.repo
[Ceph]
name=Ceph packages for $basearch
baseurl=http://download.ceph.com/rpm-octopus/el7/$basearch
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc

[Ceph-noarch]
name=Ceph noarch packages
baseurl=http://download.ceph.com/rpm-octopus/el7/noarch
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc

[ceph-source]
name=Ceph source packages
baseurl=http://download.ceph.com/rpm-octopus/el7/SRPMS
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc 
[root@node01 ~]# sed -i 's#download.ceph.com#mirrors.aliyun.com/ceph#g' /etc/yum.repos.d/ceph.repo
[root@node01 ~]# yum install ceph-common -y
--从部署服务器同步认证文件：
$ cd ~/ceph-cluster
$ scp ceph.conf ceph.client.admin.keyring  root@192.168.13.56:/etc/ceph/
[root@node01 ~]# ls -l /etc/ceph/   #此时node01节点已经是ceph集群管理同权限了，因为复制的key是admin,非常不安全
total 12
-rw------- 1 root root 151 Dec  4 14:36 ceph.client.admin.keyring
-rw-r--r-- 1 root root 262 Dec  4 14:36 ceph.conf
-rw-r--r-- 1 root root  92 Oct 20 22:50 rbdmap


4.1.3.3:客户端映射 img：
[root@node01 ~]# rbd -p myrbd1 map myimg2
/dev/rbd0
[root@node01 ~]# lsblk
NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sr0      11:0    1 1024M  0 rom
rbd0    252:0    0    3G  0 disk
xvda    202:0    0  100G  0 disk
├─xvda1 202:1    0    1G  0 part /boot
└─xvda2 202:2    0   99G  0 part /
[root@node01 ~]# fdisk  -l
[root@node01 ~]# rbd -p myrbd1 map myimg1   #此时映射开启了众多特性的img2时出错，因为centos内核版本太低，所以挂载出错
rbd: sysfs write failed
RBD image feature set mismatch. You can disable features unsupported by the kernel with "rbd feature disable myrbd1/myimg1 object-map fast-diff deep-flatten".
In some cases useful info is found in syslog - try "dmesg | tail".
rbd: map failed: (6) No such device or address
[root@node01 ~]# rbd feature disable myrbd1/myimg1 object-map fast-diff deep-flatten  #关闭img1特性
[root@node01 ~]# rbd -p myrbd1 map myimg1
/dev/rbd1
[root@node01 ~]# lsblk
NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sr0      11:0    1 1024M  0 rom
rbd0    252:0    0    3G  0 disk
rbd1    252:16   0    5G  0 disk
xvda    202:0    0  100G  0 disk
├─xvda1 202:1    0    1G  0 part /boot
└─xvda2 202:2    0   99G  0 part /

4.1.3.5:客户端格式化磁盘并挂载使用：
[root@node01 ~]# mkfs.ext4 /dev/rbd0
[root@node01 ~]# mkfs.xfs /dev/rbd1
[root@node01 ~]# mkdir /test01 && mount /dev/rbd0 /test01
[root@node01 ~]# mkdir /test02 && mount /dev/rbd1 /test02
$ ceph df
--- RAW STORAGE ---
CLASS     SIZE    AVAIL     USED  RAW USED  %RAW USED
ssd    150 GiB  149 GiB  1.1 GiB   1.1 GiB       0.71
TOTAL  150 GiB  149 GiB  1.1 GiB   1.1 GiB       0.71
--- POOLS ---
POOL                   ID  PGS  STORED  OBJECTS     USED  %USED  MAX AVAIL
device_health_metrics   1  128     0 B        0      0 B      0     47 GiB
mypool                  2  256     0 B        0      0 B      0     47 GiB
myrbd1                  3   64  76 MiB       43  228 MiB   0.16     47 GiB
[root@node01 ~]# dd if=/dev/zero of=/test01/text.file bs=1M count=20
[root@node01 ~]# dd if=/dev/zero of=/test02/text.file bs=1M count=20
4.1.3.6:ceph 验证数据：
$ ceph df
--- RAW STORAGE ---
CLASS     SIZE    AVAIL     USED  RAW USED  %RAW USED
ssd    150 GiB  149 GiB  1.2 GiB   1.2 GiB       0.79
TOTAL  150 GiB  149 GiB  1.2 GiB   1.2 GiB       0.79
--- POOLS ---
POOL                   ID  PGS   STORED  OBJECTS     USED  %USED  MAX AVAIL
device_health_metrics   1  128      0 B        0      0 B      0     47 GiB
mypool                  2  256      0 B        0      0 B      0     47 GiB
myrbd1                  3   64  116 MiB       53  348 MiB   0.24     47 GiB
注：写了两个20M数据后，使用量增加了120M(从228到348)，初算应该是3副本的原因
注：当使用RBD块时，应该将块配置为LVM,这样在ceph扩容时，我们挂载的路径也可以实现动态扩容，否则不能实现动态扩容，只能把RBD块扩容的部分重新建立一个分区

#4.2：ceph radosgw(RGW)对象存储：
RGW 提供的是 REST 接口，客户端通过 http 与其进行交互，完成数据的增删改查等管理操作。radosgw 用在需要使用 RESTful API 接口访问 ceph 数据的场合，因此在使用 RBD 即块存储得场合或者使用 cephFS 的场合可以不用启用 radosgw 功能。
4.2.1:部署 radosgw 服务：
如果是在使用 radosgw 的场合，则以下命令将 ceph-mgr01 服务器部署为 RGW 主机：
[root@ceph01 ~]# cat /etc/hosts    #知道ceph01.hs.com和ceph02.hs.com是两台mgr服务器
127.0.0.1 localhost
#ceph resolv
192.168.13.31 ceph01.hs.com   ceph-mon01        ceph-mgr01      ceph-osd01
192.168.13.32 ceph02.hs.com   ceph-mon02        ceph-mgr02      ceph-osd02
192.168.13.33 ceph03.hs.com   ceph-mon03                        ceph-osd03
192.168.13.34 ceph04.hs.com   ceph-deploy
$ ceph -s
  cluster:
    id:     4d5745dd-5f75-485d-af3f-eeaad0c51648
    health: HEALTH_OK
  services:
    mon: 3 daemons, quorum ceph01,ceph02,ceph03 (age 90m)
    mgr: ceph-mgr01(active, since 5d), standbys: ceph-mgr02
    osd: 15 osds: 15 up (since 5d), 15 in (since 5d)
  data:
    pools:   3 pools, 448 pgs
    objects: 53 objects, 126 MiB
    usage:   1.2 GiB used, 149 GiB / 150 GiB avail
    pgs:     448 active+clean
$ ceph --version
ceph version 16.2.6 (ee28fb57e47e9f88813e24bbf4c14496ca299d31) pacific (stable)
[root@ceph01 ~]# apt-cache madison radosgw
[root@ceph01 ~]# apt install radosgw=16.2.6-1bionic
--新建一个radosGW在ceph-mgr01上
$ cd ~/ceph-cluster/   #必须在有key的目录下执行命令才行
$ ceph-deploy --overwrite-conf rgw create ceph-mgr01
注：报此错误信息[ceph-mgr01][WARNIN] No data was received after 7 seconds, disconnecting...
,  第一次在执行此条命令时进程进来了，但是socket没有起来，后面重试了此条命令还是不行，最后是手动执行上面输出的3条跟服务启动及配置的命令才成功
4.2.2:验证 radosgw 服务：
[root@ceph01 ~]# ps -aux | grep radosgw
root       29982  6.7  0.9 3479152 39348 ?       Ssl  15:13   0:02 /usr/bin/radosgw -f --cluster ceph --name client.rgw.ceph-mgr01 --setuser ceph --setgroup ceph
[root@ceph01 ~]# ss -tnl| grep :7480
LISTEN   0         128                 0.0.0.0:7480             0.0.0.0:*
[root@ceph01 ~]#  curl http://ceph-mgr01:7480/
<?xml version="1.0" encoding="UTF-8"?><ListAllMyBucketsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Owner><ID>anonymous</ID><DisplayName></DisplayName></Owner><Buckets></Buckets></ListAllMyBucketsResult>[
注：像这样就把对象存储部署好了，这个要结合开发来使用，否则运维无法使用，主要是开发在bucket中对文件进行增删改查。
4.2.3:验证 ceph 状态：
$ ceph -s
  cluster:
    id:     4d5745dd-5f75-485d-af3f-eeaad0c51648
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum ceph01,ceph02,ceph03 (age 5m)
    mgr: ceph-mgr01(active, since 5d), standbys: ceph-mgr02
    osd: 15 osds: 15 up (since 5d), 15 in (since 5d)
    rgw: 1 daemon active (1 hosts, 1 zones)

  data:
    pools:   7 pools, 843 pgs
    objects: 242 objects, 126 MiB
    usage:   1.4 GiB used, 149 GiB / 150 GiB avail
    pgs:     843 active+clean

  progress:
    Global Recovery Event (9s)
      [===========================.]
4.2.4:验证 radosgw 存储池:
初始化完成 radosgw 之后，会初始化默认的存储池如下：
$ ceph osd pool ls
device_health_metrics
mypool
myrbd1
.rgw.root
default.rgw.log
default.rgw.control
default.rgw.meta




#整个ceph集群重启后状态
$ ceph -s
  cluster:
    id:     4d5745dd-5f75-485d-af3f-eeaad0c51648
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum ceph01,ceph02,ceph03 (age 2m)
    mgr: ceph-mgr02(active, since 91s), standbys: ceph-mgr01
    osd: 15 osds: 15 up (since 54s), 15 in (since 5d)
    rgw: 1 daemon active (1 hosts, 1 zones)

  data:
    pools:   7 pools, 811 pgs
    objects: 241 objects, 126 MiB
    usage:   1.1 GiB used, 149 GiB / 150 GiB avail
    pgs:     0.123% pgs not active
             810 active+clean
             1   peering

  io:
    client:   1.8 KiB/s rd, 0 B/s wr, 1 op/s rd, 1 op/s wr


#4.3：CephFS文件存储
CephFS即 ceph filesystem,可以实现文件系统共享功能，客户端通过ceph协议挂载并使用ceph集群作为数据存储服务器，在内核大于2.6.34及以后不用安装ceph挂载模块，可以在多个客户端挂载，并且一个客户端所作的更改会立即在其它客户端上体现
--CephFS需要两个存储池metadata pool和data pool：
CephFS需要运行Meta Data Services(MDS)服务，其守护进程为ceph-mds,ceph-mds进程管理与cephFS上存储的文件相关的元数据，并协调对ceph存储集群的访问,MDS需要单独的一个存储池,专门用来存储元数据信息的，存储池名称可以自定义指定
客户端写入的数据需要单独一个存储池，专门用来存放数据的，存储池名称可以自定义指定

4.3.1:部署MDS服务
在指定的ceph-mds服务器部署ceph-mds服务，可以和其它服务器混用(如ceph-mon,ceph-mgr),例如在ceph-mgr01上部署，至少有一个MDS服务器
--安装包
[root@ceph01 ~]# apt-cache madison ceph-mds
[root@ceph01 ~]# apt install -y ceph-mds=16.2.6-1bionic 
--部署节点上部署
$ cd ceph-cluster/
$ ceph-deploy mds create ceph-mgr01

4.3.2:验证MDS服务
$ ceph mds stat
 1 up:standby

4.3.3:创建CephFS metadata和data存储池
$ ceph osd pool create cephfs-metadata 32 32
$ ceph osd pool create cephfs-data 64 64
$ ceph fs new mycephfs cephfs-metadata cephfs-data   --创建一个cephfs名称为mycephfs，并指定元数据存储池、数据存储池

4.3.4:验证cephFS服务状态 
$ ceph -s		
  cluster:
    id:     4d5745dd-5f75-485d-af3f-eeaad0c51648
    health: HEALTH_WARN
            2 daemons have recently crashed

  services:
    mon: 3 daemons, quorum ceph01,ceph02,ceph03 (age 44m)
    mgr: ceph-mgr02(active, since 2h), standbys: ceph-mgr01
    mds: 1/1 daemons up
    osd: 15 osds: 15 up (since 2h), 15 in (since 5d)
    rgw: 1 daemon active (1 hosts, 1 zones)

  data:
    volumes: 1/1 healthy
    pools:   9 pools, 800 pgs
    objects: 264 objects, 126 MiB
    usage:   758 MiB used, 149 GiB / 150 GiB avail
    pgs:     800 active+clean

  io:
    client:   1.3 KiB/s wr, 0 op/s rd, 4 op/s wr

$ ceph mds stat			--一旦状态变成active就可以挂载cephfs了
mycephfs:1 {0=ceph-mgr01=up:active}
$ ceph fs status mycephfs		--查看指定cephfs的状态，cephfs对外提供的是6789端口，防火墙要放行
mycephfs - 0 clients
========
RANK  STATE      MDS         ACTIVITY     DNS    INOS   DIRS   CAPS
 0    active  ceph-mgr01  Reqs:    0 /s    10     13     12      0
      POOL         TYPE     USED  AVAIL
cephfs-metadata  metadata   100k  82.8G
  cephfs-data      data       0   47.1G
MDS version: ceph version 16.2.6 (ee28fb57e47e9f88813e24bbf4c14496ca299d31) pacific (stable)



4.3.5:挂载CephFS
$ cat ceph.client.admin.keyring   --复制key
mount -t ceph 192.168.13.31:6789/ /mnt -o name=admin,secret=4d5745dd-5f75-485d-af3f-eeaad0c516   --centos和ubuntu内核版本等于大于2.6.34则不用安装挂载模板
注：推荐装上ceph-common包，这样会比上面免安装的包新，传输速率会快些


#命令总结
$ ceph osd pool ls		--列出pool
device_health_metrics
mypool
myrbd1
.rgw.root
default.rgw.log
default.rgw.control
default.rgw.meta
cephfs-metadata
cephfs-data

$ ceph osd lspools
1 device_health_metrics
2 mypool
3 myrbd1
4 .rgw.root
5 default.rgw.log
6 default.rgw.control
7 default.rgw.meta
8 cephfs-metadata
9 cephfs-data

$ ceph pg stat		--查看PG状态，不太准，有Jemter进行压测
1024 pgs: 1024 active+clean; 126 MiB data, 809 MiB used, 149 GiB / 150 GiB avail; 10 KiB/s rd, 0 B/s wr, 17 op/s
$ ceph osd pool stats		--查看所有pool状态
$ ceph osd pool stats myrbd1
pool myrbd1 id 3
  nothing is going on

$ ceph df	--查看存储使用情况
--- RAW STORAGE ---
CLASS     SIZE    AVAIL     USED  RAW USED  %RAW USED
ssd    150 GiB  149 GiB  810 MiB   810 MiB       0.53
TOTAL  150 GiB  149 GiB  810 MiB   810 MiB       0.53
--- POOLS ---
POOL                   ID  PGS   STORED  OBJECTS     USED  %USED  MAX AVAIL
device_health_metrics   1  128      0 B        0      0 B      0     47 GiB
mypool                  2   64      0 B        0      0 B      0     47 GiB
myrbd1                  3   64  116 MiB       53  348 MiB   0.24     47 GiB
.rgw.root               4  128  1.3 KiB        4   48 KiB      0     47 GiB
default.rgw.log         5   32  3.6 KiB      177  408 KiB      0     47 GiB
default.rgw.control     6   32      0 B        8      0 B      0     47 GiB
default.rgw.meta        7  256      0 B        0      0 B      0     47 GiB
cephfs-metadata         8  256  2.3 KiB       22   96 KiB      0     47 GiB
cephfs-data             9   64      0 B        0      0 B      0     47 GiB

$ ceph osd stat		--查看osd状态
15 osds: 15 up (since 4h), 15 in (since 5d); epoch: e2417
$ ceph osd dump  	--查看ods详细信息
epoch 2417
fsid 4d5745dd-5f75-485d-af3f-eeaad0c51648
created 2021-11-27T22:36:31.505962+0800
modified 2021-12-04T18:18:24.592551+0800
flags sortbitwise,recovery_deletes,purged_snapdirs,pglog_hardlimit
crush_version 43
full_ratio 0.95
backfillfull_ratio 0.9
nearfull_ratio 0.85
require_min_compat_client luminous
min_compat_client luminous
require_osd_release pacific
stretch_mode_enabled false
pool 1 'device_health_metrics' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 128 pgp_num 128 autoscale_mode on last_change 1944 lfor 0/1620/1618 flags hashpspool stripe_width 0 pg_num_min 1 application mgr_devicehealth
pool 2 'mypool' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 64 pgp_num 64 autoscale_mode on last_change 2398 lfor 0/2398/2396 flags hashpspool stripe_width 0
pool 3 'myrbd1' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 64 pgp_num 64 autoscale_mode on last_change 333 flags hashpspool,selfmanaged_snaps stripe_width 0 application rbd

$ ceph osd tree    --可以查看哪个osd故障
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

$ ceph mon stat   --查看mon状态，最少3个保持高可用
e3: 3 mons at {ceph01=[v2:192.168.13.31:3300/0,v1:192.168.13.31:6789/0],ceph02=[v2:192.168.13.32:3300/0,v1:192.168.13.32:6789/0],ceph03=[v2:192.168.13.33:3300/0,v1:192.168.13.33:6789/0]}, election epoch 660, leader 0 ceph01, quorum 0,1,2 ceph01,ceph02,ceph03
$ ceph mon dump		--查看mon详细信息
epoch 3
fsid 4d5745dd-5f75-485d-af3f-eeaad0c51648
last_changed 2021-11-28T23:05:40.792550+0800
created 2021-11-27T22:36:04.013844+0800
min_mon_release 16 (pacific)
election_strategy: 1
0: [v2:192.168.13.31:3300/0,v1:192.168.13.31:6789/0] mon.ceph01
1: [v2:192.168.13.32:3300/0,v1:192.168.13.32:6789/0] mon.ceph02
2: [v2:192.168.13.33:3300/0,v1:192.168.13.33:6789/0] mon.ceph03
dumped monmap epoch 3



#ceph集群维护
http://docs.ceph.org.cn/rados/  	--ceph集群配置、部署与运维
4.4.1 通过套接字进行单机管理：
--可以在node节点或者mon节点通过ceph命令进行单机管理本机的mon或者osd服务
--先把admin认证文件同步到mon或者node节点
$ scp ceph.client.admin.keyring root@192.168.13.31:/etc/ceph
[root@ceph01 ~]# ceph --admin-socket /var/run/ceph/ceph-osd.0.asok --help
[root@ceph01 ~]# ls -l /var/run/ceph/
srwxr-xr-x 1 ceph ceph 0 Dec  4 15:48 ceph-client.rgw.ceph-mgr01.946.93902422886960.asok
srwxr-xr-x 1 ceph ceph 0 Dec  4 16:29 ceph-mds.ceph-mgr01.asok
srwxr-xr-x 1 ceph ceph 0 Dec  4 15:48 ceph-mgr.ceph-mgr01.asok
srwxr-xr-x 1 ceph ceph 0 Dec  4 15:48 ceph-mon.ceph01.asok
srwxr-xr-x 1 ceph ceph 0 Dec  4 15:50 ceph-osd.0.asok
srwxr-xr-x 1 ceph ceph 0 Dec  4 15:50 ceph-osd.1.asok
srwxr-xr-x 1 ceph ceph 0 Dec  4 15:50 ceph-osd.2.asok
srwxr-xr-x 1 ceph ceph 0 Dec  4 15:50 ceph-osd.3.asok
srwxr-xr-x 1 ceph ceph 0 Dec  4 15:50 ceph-osd.4.asok
[root@ceph01 ~]# ceph --admin-socket /var/run/ceph/ceph-osd.4.asok pg stat
2021-12-04T20:36:40.311+0800 7fc1d759e700 -1 asok(0x7fc1d8001510) AdminSocketConfigObs::init: failed: AdminSocket::bind_and_listen: failed to bind the UNIX domain socket to '/var/run/ceph/ceph-osd.4.asok': (17) File exists
1024 pgs: 1024 active+clean; 126 MiB data, 828 MiB used, 149 GiB / 150 GiB avail
--admin-daemon    #在mon节点获取daemon服务帮助：
[root@ceph01 ~]# ceph --admin-daemon /var/run/ceph/ceph-mon.ceph01.asok help
{
    "add_bootstrap_peer_hint": "add peer address as potential bootstrap peer for cluster bringup",
    "add_bootstrap_peer_hintv": "add peer address vector as potential bootstrap peer for cluster bringup",
    "compact": "cause compaction of monitor's leveldb/rocksdb storage",
    "config diff": "dump diff of current config and default config",
    "config diff get": "dump diff get <field>: dump diff of current and default config setting <field>",
    "config get": "config get <field>: get the config value",
    "config help": "get config setting schema and descriptions",
    "config set": "config set <field> <val> [<val> ...]: set a config variable",
    "config show": "dump current config settings",
    "config unset": "config unset <field>: unset a config variable",
    "connection scores dump": "show the scores used in connectivity-based elections",
    "connection scores reset": "reset the scores used in connectivity-based elections",
    "dump_historic_ops": "dump_historic_ops",
    "dump_mempools": "get mempool stats",
    "get_command_descriptions": "list available commands",
    "git_version": "get git sha1",
    "heap": "show heap usage info (available only if compiled with tcmalloc)",
    "help": "list available commands",
    "injectargs": "inject configuration arguments into running daemon",
    "log dump": "dump recent log entries to log file",
    "log flush": "flush log entries to log file",
    "log reopen": "reopen log file",
    "mon_status": "report status of monitors",
    "ops": "show the ops currently in flight",
    "perf dump": "dump perfcounters value",
    "perf histogram dump": "dump perf histogram values",
    "perf histogram schema": "dump perf histogram schema",
    "perf reset": "perf reset <name>: perf reset all or one perfcounter name",
    "perf schema": "dump perfcounters schema",
    "quorum enter": "force monitor back into quorum",
    "quorum exit": "force monitor out of the quorum",
    "sessions": "list existing sessions",
    "smart": "Query health metrics for underlying device",
    "sync_force": "force sync of and clear monitor store",
    "version": "get ceph version"
}
[root@ceph01 ~]# ceph --admin-daemon /var/run/ceph/ceph-mon.ceph01.asok config show

4.4.2 ceph集群的停止或重启
[root@ceph01 ~]# netstat -tanlp | grep :3300
tcp        0      0 192.168.13.31:3300      0.0.0.0:*               LISTEN      947/ceph-mon
tcp        0      0 192.168.13.31:3300      192.168.13.31:18406     ESTABLISHED 947/ceph-mon
tcp        0      0 192.168.13.31:3300      192.168.13.31:18782     ESTABLISHED 947/ceph-mon
tcp        0      0 192.168.13.31:11630     192.168.13.32:3300      ESTABLISHED 947/ceph-mon
tcp        0      0 192.168.13.31:15116     192.168.13.33:3300      ESTABLISHED 947/ceph-mon
tcp        0      0 192.168.13.31:18782     192.168.13.31:3300      ESTABLISHED 946/radosgw
tcp        0      0 192.168.13.31:3300      192.168.13.31:19066     ESTABLISHED 947/ceph-mon
tcp        0      0 192.168.13.31:12308     192.168.13.32:3300      ESTABLISHED 1818/ceph-osd
tcp        0      0 192.168.13.31:3300      192.168.13.31:19040     ESTABLISHED 947/ceph-mon
tcp        0      0 192.168.13.31:15258     192.168.13.33:3300      ESTABLISHED 1855/ceph-osd
tcp        0      0 192.168.13.31:15194     192.168.13.33:3300      ESTABLISHED 950/ceph-mgr
tcp        0      0 192.168.13.31:19040     192.168.13.31:3300      ESTABLISHED 1853/ceph-osd
tcp        0      0 192.168.13.31:18598     192.168.13.31:3300      ESTABLISHED 1860/ceph-osd
tcp        0      0 192.168.13.31:18406     192.168.13.31:3300      ESTABLISHED 946/radosgw
tcp        0      0 192.168.13.31:15346     192.168.13.33:3300      ESTABLISHED 1856/ceph-osd
tcp        0      0 192.168.13.31:3300      192.168.13.31:18598     ESTABLISHED 947/ceph-mon
tcp        0      0 192.168.13.31:19066     192.168.13.31:3300      ESTABLISHED 5233/ceph-mds
注：每隔6秒钟osd跟mon节点进行通信，如果20秒钟mon节点没有接收到osd的信息，那么这个osd就被认定为故障，那么这个osd将被踢出ceph集群从而进行osd的高可用
--重启之前，要提前设置ceph集群不要将OSD标记为out，从而不会采取通信机制，避免osd节点关闭服务后被踢出ceph集群外	
$ ceph osd set noout	--关闭服务将设置noout
noout is set
$ ceph -s
  cluster:
    id:     4d5745dd-5f75-485d-af3f-eeaad0c51648
    health: HEALTH_WARN
            noout flag(s) set

  services:
    mon: 3 daemons, quorum ceph01,ceph02,ceph03 (age 3h)
    mgr: ceph-mgr02(active, since 5h), standbys: ceph-mgr01
    mds: 1/1 daemons up
    osd: 15 osds: 15 up (since 5h), 15 in (since 5d)
         flags noout
    rgw: 1 daemon active (1 hosts, 1 zones)

  data:
    volumes: 1/1 healthy
    pools:   9 pools, 1024 pgs
    objects: 264 objects, 126 MiB
    usage:   854 MiB used, 149 GiB / 150 GiB avail
    pgs:     1024 active+clean

ceph osd unset noout		--启动服务后取消noout
4.4.2.1 关闭顺序
--关闭服务前设置noout
一、关闭存储客户端停止读写数据（java、php等客户端）
二、如果使用了RGW，关闭RGW
三、关闭cephfs元数据服务(MDS)
四、关闭ceph OSD
五、关闭ceph manager
六、关闭ceph monitor
4.4.2.2 启动顺序
一、启动ceph monitor
二、启动ceph manager
三、启动ceph OSD
四、启动cephfs元数据服务(MDS)
五、如果使用了RGW，启动RGW
六、启动存储客户端停止读写数据（java、php等客户端）

#去除警告1
--去除警告clock skew detected on mon.ceph03
URL: http://docs.ceph.org.cn/rados/configuration/mon-config-ref/
--监视器间允许的时钟漂移量，默认为0.050秒 即50毫秒
mon clock drift allowed = 1
--时钟偏移警告的退避指数 即连接多少次时间偏差后就触发警告
mon clock drift warn backoff = 10
--需要将这两项配置加入到配置文件中
cat >> ceph.conf << EOF			
mon clock drift allowed = 1
mon clock drift warn backoff = 10
EOF
--并且推送到所有mon节点
$ scp ceph.conf root@ceph-mon01:/etc/ceph
$ scp ceph.conf root@ceph-mon02:/etc/ceph
$ scp ceph.conf root@ceph-mon03:/etc/ceph
--最后重启ceph-mon@ceph-mon01.service才能生效
[root@ceph01 ~]# systemctl restart ceph-mon@ceph01.service
[root@ceph02 ~]# systemctl restart ceph-mon@ceph02.service
[root@ceph03 ~]# systemctl restart ceph-mon@ceph03.service
#去除警告2
--去除警告2 daemons have recently crashed	
$ ceph -s
  cluster:
    id:     4d5745dd-5f75-485d-af3f-eeaad0c51648
    health: HEALTH_WARN
            2 daemons have recently crashed			#2个守护进程最近崩溃了

  services:
    mon: 3 daemons, quorum ceph01,ceph02,ceph03 (age 3h)
    mgr: ceph-mgr02(active, since 5h), standbys: ceph-mgr01
    mds: 1/1 daemons up
    osd: 15 osds: 15 up (since 5h), 15 in (since 5d)
    rgw: 1 daemon active (1 hosts, 1 zones)

  data:
    volumes: 1/1 healthy
    pools:   9 pools, 1024 pgs
    objects: 264 objects, 126 MiB
    usage:   843 MiB used, 149 GiB / 150 GiB avail
    pgs:     1024 active+clean
$ ceph crash ls		--查看crash的信息列表
ID                                                                ENTITY      NEW
2021-12-04T07:44:38.164382Z_c9f4e389-f960-4465-bd9a-cf30bf58e8b6  mon.ceph02   *
2021-12-04T07:44:39.074114Z_8ecc649b-b249-4f30-8c06-aaad84ae6ff1  mon.ceph02   *
$ ceph crash info 2021-12-04T07:44:38.164382Z_c9f4e389-f960-4465-bd9a-cf30bf58e8b6	--查看crash详细信息
$ ceph crash archive 2021-12-04T07:44:38.164382Z_c9f4e389-f960-4465-bd9a-cf30bf58e8b6	--消息指定crash信息
$ ceph crash ls
ID                                                                ENTITY      NEW
2021-12-04T07:44:38.164382Z_c9f4e389-f960-4465-bd9a-cf30bf58e8b6  mon.ceph02
2021-12-04T07:44:39.074114Z_8ecc649b-b249-4f30-8c06-aaad84ae6ff1  mon.ceph02   *
$ ceph crash archive-all		--消息所有crash信息
$ ceph -s
  cluster:
    id:     4d5745dd-5f75-485d-af3f-eeaad0c51648
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum ceph01,ceph02,ceph03 (age 3h)
    mgr: ceph-mgr02(active, since 5h), standbys: ceph-mgr01
    mds: 1/1 daemons up
    osd: 15 osds: 15 up (since 5h), 15 in (since 5d)
    rgw: 1 daemon active (1 hosts, 1 zones)

  data:
    volumes: 1/1 healthy
    pools:   9 pools, 1024 pgs
    objects: 264 objects, 126 MiB
    usage:   852 MiB used, 149 GiB / 150 GiB avail
    pgs:     1024 active+clean

4.4.2.3 添加服务器
1. 先添加仓库源
2. ceph-deploy install --release pacific ceph-node4
3. 擦除磁盘
	ceph-deploy disk zap ceph-node04 /dev/sdb
4. 添加osd
	sudo ceph-deploy osd create ceph-node04 --data /dev/sdb

4.4.2.4 删除服务器
删除服务器之前要把服务器的OSD先停止然后从ceph集群删除
1. 把osd跳出集群     ---相反把OSD加入集群， ceph osd in 1
	ceph osd out 1
2. 等一段时间
3. 停止osd.x进程
	systemctl stop ceph-osd@1.service
4. 删除osd
	ceph osd rm 1
5. 当前主机的其它磁盘重复以上操作
6. OSD全部操作完成后下线主机
注：当备的osd插入到其它主机上，这个备的osd的数据将会被主的osd覆盖，以主的OSD为主


4.5 ceph配置文件
--Ceph的主配置文件是/etc/ceph/ceph.conf, ceph服务在启动时会检查ceph.conf，分号;和#在配置文件中都是注释，ceph.conf主要由以下配置段组成：
[global]	#全局配置
[osd]		#osd专用配置，可以使用osd.N，来表示某一个OSD专用配置，N为osd的编号，如0、2、1等
[mon]		#mon专用配置，也可以使用mon.A来为某一个monitor节点做专用配置，某中A为该节点的名称，ceph-monitor-2、ceph-monitor-1等，使用命令ceph mon dump可以获取节点的名称
[client]	#客户端专用配置

--ceph文件的加载顺序：
$CEPH_CONF环境变量
-c 指定的位置
/etc/ceph/ceph.conf
~/.ceph/ceph.conf
./ceph.conf

#4.6 存储池、PG与CRUSH
4.6.1 存储池
$ ceph osd pool create --help
osd pool create <pool> [<pg_num:int>] [<pgp_num:int>] [replicated|erasure]  
副本池：replicated，定义每个对象在集群中保存为多少个副本，默认为三个副本，一主两备，实现高可用，副本池是ceph默认的存储池类型。用得最多
纠删码池(erasure code):把各对象存储为N=K+M个块，其中K为数据块数量，M为编码块数量，因此存储池的尺寸为K+M。即数据保存在K个数据块，并提供M个冗余块提供数据高可用，那么最多能故障的块就是M个，实际的磁盘占用就是K+M块，因此相比副本池机制比较节省存储资源，一般采用8+4机制，即8个数据块+4个冗余 块，那么也就是12个数据块有8个数据块保存数据，有4个实现数据冗余，即1/3的磁盘空间用于数据冗余，比默认副本池的三倍冗余节省空间，但是不能出现大于一定数据块故障，但是不是所有的应用都支持纠删码池，RBD只支持副本池，radosgw则可以支持纠删码池。类似RAID，但用得不多。但是不是所有的应用都支持纠删码池，RBD只支持副本池而RADOSGW则可以支持纠删码池，ceph默认是副本池。

4.6.2--创建纠删删码池
$ ceph osd pool create erasure-testpool 32 32 erasure
$ ceph osd erasure-code-profile get default
k=2		--k为数据块的数量，即要将原始对象分割成的块数量，例如，如果k=2，则会将一个10kb对象分割成各为5kb的k个对象
m=2		--编码块(chunk)的数量，即编码函数计算的额外块的数量，如果有2个编码块，则表示有两个额外的备份，最多可以从当前pg中宕机2个OSD，而不会丢失数据
plugin=jerasure		--默认的纠删码池插件，是一种纠删码池算法
technique=reed_sol_van
--验证当前pg状态
$ ceph pg ls-by-pool erasure-testpool | awk '{print $1,$2,$15}'
PG OBJECTS ACTING
10.0 0 [6,12,2,NONE]p6
10.1 0 [14,8,3,NONE]p14
10.2 0 [1,8,NONE,10]p1
10.3 0 [10,8,1,NONE]p10
10.4 0 [12,3,8,NONE]p12
10.5 0 [2,NONE,11,6]p2
10.6 0 [8,NONE,4,10]p8
10.7 0 [6,3,NONE,13]p6
10.8 0 [0,10,7,NONE]p0
10.9 0 [5,3,NONE,10]p5
10.a 0 [6,13,NONE,3]p6
10.b 0 [6,0,13,NONE]p6
10.c 0 [7,NONE,10,0]p7
10.d 0 [9,13,NONE,2]p9
10.e 0 [8,14,NONE,3]p8
10.f 0 [13,NONE,8,2]p13
10.10 0 [12,6,NONE,4]p12
10.11 0 [12,1,6,NONE]p12
10.12 0 [10,3,7,NONE]p10
10.13 0 [1,13,NONE,9]p1
10.14 0 [1,14,NONE,5]p1
10.15 0 [4,5,14,NONE]p4
10.16 0 [6,NONE,4,13]p6
10.17 0 [6,12,2,NONE]p6
10.18 0 [4,5,NONE,10]p4
10.19 0 [1,7,NONE,13]p1
10.1a 0 [6,3,11,NONE]p6
10.1b 0 [3,7,13,NONE]p3
10.1c 0 [6,4,NONE,12]p6
10.1d 0 [7,3,12,NONE]p7
10.1e 0 [12,0,NONE,6]p12
10.1f 0 [7,2,13,NONE]p7
--在纠删码池pool中写入数据
$ sudo rados put -p erasure-testpool testfile1 /var/log/syslog
--验证写入的数据 
$ ceph osd map erasure-testpool testfile1
osdmap e2467 pool 'erasure-testpool' (10) object 'testfile1' -> pg 10.3a643fcb (10.b) -> up ([6,0,13,NONE], p6) acting ([6,0,13,NONE], p6)
$ ceph pg ls-by-pool erasure-testpool | awk '{print $1,$2,$15}'
PG OBJECTS ACTING
10.0 0 [6,12,2,NONE]p6			#为什么有NONE，因为我这里只有3个OSD节点，因为数据和纠删码是2+2，会分布在不同的节点，所以有一个纠删码会不可用，2个纠删码等于1个纠删码
10.1 0 [14,8,3,NONE]p14
10.2 0 [1,8,NONE,10]p1
10.3 0 [10,8,1,NONE]p10
10.4 0 [12,3,8,NONE]p12
10.5 0 [2,NONE,11,6]p2
10.6 0 [8,NONE,4,10]p8
10.7 0 [6,3,NONE,13]p6
10.8 0 [0,10,7,NONE]p0
10.9 0 [5,3,NONE,10]p5
10.a 0 [6,13,NONE,3]p6
10.b 1 [6,0,13,NONE]p6
10.c 0 [7,NONE,10,0]p7
10.d 0 [9,13,NONE,2]p9
10.e 0 [8,14,NONE,3]p8
10.f 0 [13,NONE,8,2]p13
10.10 0 [12,6,NONE,4]p12
10.11 0 [12,1,6,NONE]p12
10.12 0 [10,3,7,NONE]p10
10.13 0 [1,13,NONE,9]p1
10.14 0 [1,14,NONE,5]p1
10.15 0 [4,5,14,NONE]p4
10.16 0 [6,NONE,4,13]p6
10.17 0 [6,12,2,NONE]p6
10.18 0 [4,5,NONE,10]p4
10.19 0 [1,7,NONE,13]p1
10.1a 0 [6,3,11,NONE]p6
10.1b 0 [3,7,13,NONE]p3
10.1c 0 [6,4,NONE,12]p6
10.1d 0 [7,3,12,NONE]p7
10.1e 0 [12,0,NONE,6]p12
10.1f 0 [7,2,13,NONE]p7
--测试获取数据
$ sudo rados --pool erasure-testpool get testfile1 /opt/1.log
$ tail /opt/1.log

4.6.3 PG与PGP
PG=Placement Group	--归置组
PGP=Placement Group for Placement Purpose	--归置组的组合，PGP相当于是PG对应osd的一种排列组合关系。官方推荐PGP和PG数量一样。
归置组(Placement group)是用于跨越多OSD将数据存储在每个存储池中的内部数据结构，归置组在OSD守护进程和ceph客户端之间生成了一个中间层，hash算法负责将每个对象动态映射到一个归置组，然后CRUSH算法再将每个归置组动态映射到一个或多个OSD守护进程，从而能够支持在新的OSD设备上线时进行数据重新平衡。

相对于存储池来说，PG是一个虚拟组件，它是对象映射到存储池时使用的虚拟层。可以自定义存储池中的归置组数量。ceph出于规模伸缩及性能方面的考虑，ceph将存储池细分为多个归置组，把每个单独的对象映射到归置组，并为归置组分配一个主OSD。存储池由一系列的归置组组成，而CRUSH算法则根据集群运行图和集群状态，将各PG均匀、伪随机(基于hash映射，每次的计算结果都一样)的分布到集群中的OSD之止。如果某个OSD失败奥需要对集群进行重新平衡，ceph则移动或复制整个归置组而不需要单独对每个镜像进行寻址。

4.6.4 PG与OSD的关系
ceph基于crush算法将归置组PG分配至OSD，当一个客户端存储对象的时候，hash算法映射每一个对象至归置组(PG),然后CRUSH算法将归置组PG分配至OSD

4.6.5 PG分配计算
归置组(PG)的数量 是由管理员在创建存储池的时候指定的，然后由CRUSH负责创建和使用，PG的数量是2的N次方的倍数，每个OSD的PG不要超出250个PG，官方建议是每个OSD的PG是100个左右
--计算PG
1. 先计算磁盘数量是多少块，官方推荐每个OSD是100个PG
例如：10块磁盘需要创建20个存储池
总PG： 10*100=1000个PG
20个存储池中有些数据量大，有些数据量小，根据情况来分，
平均PG：1000/20=50，但是PG取2的N次方，否则在创建的时候Ceph会警告，所以这里向上取整为64或者向下取整32，一般是向上取整。
如果pool的大小只有几个G，则可以分配4个或8个PG就可以了

2. 通常，PG的数量应该是数据的合理力度的子集。
例如：一个包含256个PG的存储池，每个PG中包含大约1/256的存储池数据
3. 当需要将PG从一个OSD移动到另一个OSD的时候，PG的数量会对性能产生影响：
	1. PG的数量过少，一个OSD上保存的数据会相对增多，那么ceph同步数据的时候产生的网络负载将对集群的性能输出产生一定影响。
	2. PG过多的时候，ceph将会占用过多的CPU和内存资源用于记录PG的状态信息
4. PG的数量在集群分发数据和重新平衡时扮演者重要的角色作用
	1. 在所有OSD之间进行数据持久存储以及完成数据分布会需要较多的归置组，但是他们的数量应该减少到实现ceph最大性能所需的最小PG数量值，以节省CPU和内存资源。
	2. 一般来说，对于有着超过50个OSD的RADOS集群，建议每个OSD大约有50-100个PG以平衡资源使用及取得更好的数据持久性和数据分布，而在更大的集群中，每个OSD可以有100-200个PG
	3. 至于一个pool应该使用多少个PG，可以通过下面的公式计算后，将pool的PG值四舍五入到最近的2的N次幂，如下先计算出ceph集群的PG数：
		1. 磁盘总数 X 每个磁盘PG数 / 副本数 ==> ceph集群总PG数
		2. 例如：单个pool的PG计算：
			1. 有100个osd，3副本，5个pool
			2. Total PG=100*100/3=3333
			3. 每个pool的PG=3333/5=512，那么创建pool的时候就指定pg为512
		3. 需要结合数据数量，磁盘数量及磁盘空间计算出PG数量 ，8、16、32、64、128、256、512、1024等2的N次方
5. 测试创建 17个PG,17个PGP的情况
$ ceph osd pool create testpool01 17 17
$ ceph -s
  cluster:
    id:     4d5745dd-5f75-485d-af3f-eeaad0c51648
    health: HEALTH_WARN
            Degraded data redundancy: 1/892 objects degraded (0.112%), 1 pg degraded, 32 pgs undersized
            1 pool(s) do not have an application enabled
            1 pool(s) have non-power-of-two pg_num
6. 删除pool
$ ceph osd pool delete testpool01 testpool01 --yes-i-really-really-mean-it
Error EPERM: pool deletion is disabled; you must first set the mon_allow_pool_delete config option to true before you can destroy a pool
--设置ceph集群允许删除pool
$ ceph tell mon.* injectargs --mon-allow-pool-delete=true
mon.ceph01: {}
mon.ceph01: mon_allow_pool_delete = 'true'
mon.ceph02: {}
mon.ceph02: mon_allow_pool_delete = 'true'
mon.ceph03: {}
mon.ceph03: mon_allow_pool_delete = 'true'
--删除pool,需要输入两次pool名称
$ ceph osd pool delete testpool01 testpool01 --yes-i-really-really-mean-it
pool 'testpool01' removed	
--然后设置回来，不允许删除pool
$ ceph tell mon.* injectargs --mon-allow-pool-delete=false
mon.ceph01: {}
mon.ceph01: mon_allow_pool_delete = 'false'
mon.ceph02: {}
mon.ceph02: mon_allow_pool_delete = 'false'
mon.ceph03: {}
mon.ceph03: mon_allow_pool_delete = 'false'


4.7 PG的状态
URL：https://www.jianshu.com/p/36c2d5682d87
PG状态表
正常的PG状态是 100%的active + clean， 这表示所有的PG是可访问的，所有副本都对全部PG都可用。
如果Ceph也报告PG的其他的警告或者错误状态。PG状态表：
状态		描述
Activating	Peering已经完成，PG正在等待所有PG实例同步并固化Peering的结果(Info、Log等)
Active	活跃态。PG可以正常处理来自客户端的读写请求
Backfilling	正在后台填充态。 backfill是recovery的一种特殊场景，指peering完成后，如果基于当前权威日志无法对Up Set当中的某些PG实例实施增量同步(例如承载这些PG实例的OSD离线太久，或者是新的OSD加入集群导致的PG实例整体迁移) 则通过完全拷贝当前Primary所有对象的方式进行全量同步
Backfill-toofull	某个需要被Backfill的PG实例，其所在的OSD可用空间不足，Backfill流程当前被挂起
Backfill-wait	等待Backfill 资源预留
Clean	干净态。PG当前不存在待修复的对象， Acting Set和Up Set内容一致，并且大小等于存储池的副本数
Creating	PG正在被创建
Deep	PG正在或者即将进行对象一致性扫描清洗
Degraded	降级状态。Peering完成后，PG检测到任意一个PG实例存在不一致(需要被同步/修复)的对象，或者当前ActingSet 小于存储池副本数
Down	Peering过程中，PG检测到某个不能被跳过的Interval中(例如该Interval期间，PG完成了Peering，并且成功切换至Active状态，从而有可能正常处理了来自客户端的读写请求),当前剩余在线的OSD不足以完成数据修复
Incomplete	Peering过程中， 由于 a. 无非选出权威日志 b. 通过choose_acting选出的Acting Set后续不足以完成数据修复，导致Peering无非正常完成
Inconsistent	不一致态。集群清理和深度清理后检测到PG中的对象在副本存在不一致，例如对象的文件大小不一致或Recovery结束后一个对象的副本丢失
Peered	Peering已经完成，但是PG当前ActingSet规模小于存储池规定的最小副本数(min_size)
Peering	正在同步态。PG正在执行同步处理
Recovering	正在恢复态。集群正在执行迁移或同步对象和他们的副本
Recovering-wait	等待Recovery资源预留
Remapped	重新映射态。PG活动集任何的一个改变，数据发生从老活动集到新活动集的迁移。在迁移期间还是用老的活动集中的主OSD处理客户端请求，一旦迁移完成新活动集中的主OSD开始处理
Repair	PG在执行Scrub过程中，如果发现存在不一致的对象，并且能够修复，则自动进行修复状态
Scrubbing	PG正在或者即将进行对象一致性扫描
Unactive	非活跃态。PG不能处理读写请求
Unclean	非干净态。PG不能从上一个失败中恢复
Stale	未刷新态。PG状态没有被任何OSD更新，这说明所有存储这个PG的OSD可能挂掉, 或者Mon没有检测到Primary统计信息(网络抖动)
Undersized	PG当前Acting Set小于存储池副本数


4.9.1 常用命令
4.9.1.1 列出存储池
$ ceph osd pool ls
device_health_metrics
mypool
myrbd1
.rgw.root
default.rgw.log
default.rgw.control
default.rgw.meta
cephfs-metadata
cephfs-data

$ ceph osd pool ls detail
pool 1 'device_health_metrics' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 32 pgp_num 32 autoscale_mode on last_change 3048 lfor 0/3012/3010 flags hashpspool stripe_width 0 pg_num_min 1 application mgr_devicehealth
pool 2 'mypool' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 64 pgp_num 64 autoscale_mode on last_change 2398 lfor 0/2398/2396 flags hashpspool stripe_width 0
pool 3 'myrbd1' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 64 pgp_num 64 autoscale_mode on last_change 333 flags hashpspool,selfmanaged_snaps stripe_width 0 application rbd
pool 4 '.rgw.root' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 32 pgp_num 32 autoscale_mode on last_change 3042 lfor 0/3042/3040 flags hashpspool stripe_width 0 application rgw
pool 5 'default.rgw.log' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 32 pgp_num 32 autoscale_mode on last_change 1936 flags hashpspool stripe_width 0 application rgw
pool 6 'default.rgw.control' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 32 pgp_num 32 autoscale_mode on last_change 1639 flags hashpspool stripe_width 0 application rgw
pool 7 'default.rgw.meta' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 256 pgp_num 256 autoscale_mode on last_change 1682 lfor 0/0/1668 flags hashpspool stripe_width 0 pg_autoscale_bias 4 pg_num_min 8 application rgw
pool 8 'cephfs-metadata' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 256 pgp_num 256 autoscale_mode on last_change 2413 lfor 0/0/2411 flags hashpspool stripe_width 0 pg_autoscale_bias 4 pg_num_min 16 recovery_priority 5 application cephfs
pool 9 'cephfs-data' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 64 pgp_num 64 autoscale_mode on last_change 2409 flags hashpspool stripe_width 0 application cephfs

$ ceph osd lspools
1 device_health_metrics
2 mypool
3 myrbd1
4 .rgw.root
5 default.rgw.log
6 default.rgw.control
7 default.rgw.meta
8 cephfs-metadata
9 cephfs-data

4.9.1.2 获取存储池的事件信息
$ ceph osd pool stats mypool
pool mypool id 2
  nothing is going on

4.9.1.3 重合名存储池，正在使用的pool是无法重命名的
$ ceph osd pool rename mypool mypool1
pool 'mypool' renamed to 'mypool1'

4.9.1.4 显示存储池的用量信息
$ ceph df
--- RAW STORAGE ---
CLASS     SIZE    AVAIL     USED  RAW USED  %RAW USED
ssd    150 GiB  149 GiB  779 MiB   779 MiB       0.51
TOTAL  150 GiB  149 GiB  779 MiB   779 MiB       0.51

--- POOLS ---
POOL                   ID  PGS   STORED  OBJECTS     USED  %USED  MAX AVAIL
device_health_metrics   1   32      0 B        0      0 B      0     47 GiB
mypool                  2   64      0 B        0      0 B      0     47 GiB
myrbd1                  3   64  116 MiB       53  348 MiB   0.24     47 GiB
.rgw.root               4   32  1.3 KiB        4   48 KiB      0     47 GiB
default.rgw.log         5   32  3.6 KiB      209  408 KiB      0     47 GiB
default.rgw.control     6   32      0 B        8      0 B      0     47 GiB
default.rgw.meta        7  256      0 B        0      0 B      0     47 GiB
cephfs-metadata         8  256   26 KiB       22  160 KiB      0     47 GiB
cephfs-data             9   64      0 B        0      0 B      0     47 GiB
$ rados df
POOL_NAME                 USED  OBJECTS  CLONES  COPIES  MISSING_ON_PRIMARY  UNFOUND  DEGRADED  RD_OPS       RD  WR_OPS       WR  USED COMPR  UNDER COMPR
.rgw.root               48 KiB        4       0      12                   0        0         0      39   39 KiB       0      0 B         0 B          0 B
cephfs-data                0 B        0       0       0                   0        0         0       0      0 B       0      0 B         0 B          0 B
cephfs-metadata        160 KiB       22       0      66                   0        0         0      84   89 KiB      14   12 KiB         0 B          0 B
default.rgw.control        0 B        8       0      24                   0        0         0       0      0 B       0      0 B         0 B          0 B
default.rgw.log        408 KiB      209       0     627                   0        0         0  130149  127 MiB   86291   34 KiB         0 B          0 B
default.rgw.meta           0 B        0       0       0                   0        0         0       0      0 B       0      0 B         0 B          0 B
device_health_metrics      0 B        0       0       0                   0        0         0       0      0 B       0      0 B         0 B          0 B
mypool                     0 B        0       0       0                   0        0         0       1    2 KiB      12   36 MiB         0 B          0 B
myrbd1                 348 MiB       53       0     159                   0        0         0     455  3.7 MiB     201  118 MiB         0 B          0 B

total_objects    296
total_used       784 MiB
total_avail      149 GiB
total_space      150 GiB

4.9.2 存储池配置是否为可删除
ceph osd pool create mypool2 4 4 
ceph osd pool get mypool2 nodelete  --查看存储是否可以删除
ceph osd pool set mypool2 nodelete true	--设置存储池不可以被删除，此时存储池和mon设置都为不允许删除了
注：如果mon设置为可以删除，但是pool设置为不允许删除，那么你还是删除不了这个存储池了

4.9.3 存储池配额
存储池可以设置两个配对存储的对象进行限制，一个配额是最大空间
$ ceph osd pool get-quota mypool 	--查看存储池配额限制，默认是没有限制的 
quotas for pool 'mypool':
  max objects: N/A
  max bytes  : N/A
$ ceph osd pool set-qouta mypool max_objects 1000	--设置对象数量为1000，这个一般很少设置
$ ceph osd pool set-qouta mypool max_bytes 214748364800	--设置最大存储容量为200G，这个常用

4.9.4 存储池可用参数
size: 存储池中的对象副本数，默认一主两个备共3个副本
$ ceph osd pool get mypool size 	--查看存储池副本数
size: 3
$ ceph osd pool set mypool size 2		--设置存储池副本数
$ ceph osd pool get mypool min_size 	--提供服务所需要的最小副本数
min_size: 2
$ ceph osd pool get mypool pg_num		--查看当前PG的数量 
pg_num: 64
$ ceph osd pool get mypool crush_rule		--查看crush算法规则 
crush_rule: replicated_rule	--默认为副本池
$ ceph osd pool get mypool --查看可以获取的属性值 
$ ceph osd pool get mypool nopgchange 	--查看是否可以调整pg和pgp的数量
nopgchange: false
$ ceph osd pool set mypool pg_num 4 	--修改指定pool的pg数量，数据不会丢，但会重新平衡数据，会使ceph很繁忙
set pool 2 pg_num to 4
$ ceph osd pool set mypool pgp_num 4 	--修改指定pool的pgp数量，数据不会丢，但会重新平衡数据，会使ceph很繁忙
set pool 2 pgp_num to 4
$ ceph osd pool get mypool pg_num	--重新平衡pg是有一个慢性过程的
pg_num: 61


$ ceph config get mon	--查看ceph mon配置
$ ceph config set global osd_pool_default_pg_autoscale_mode off	--设置默认pg自动伸缩模式为关
$ ceph osd pool get mypool pg_autoscale_mode	--查看特定存储池pg自动伸缩状态是否开启，如果开启则无法调整pg和pgp数量
pg_autoscale_mode: on
$ ceph osd pool set mypool pg_autoscale_mode off	--关闭pg自动伸缩
set pool 2 pg_autoscale_mode to off

$ ceph osd pool get mypool nosizechange		--控制是否可以更改存储池的大小
 
noscrub和nodeep-scrub: 控制是否不进行轻量扫描(扫描OSD的元数据信息，默认每天一次)或是否深层扫描存储池(扫描数据本身，更耗IO，默认每周一次)，ceph这种扫描机制可以检测同一个PG中多个副本OSD是否有不一致情况，如果有则报告mon服务器有数据不一致而告警，扫描结果是json数据。在IO高的情况下，关闭扫描可临时解决高IO问题
$ ceph osd pool get mypool noscrub 	--控制是否开关轻量扫描
noscrub: false
$ ceph osd pool set mypool noscrub true	--关闭轻量扫描
set pool 2 noscrub to true
$ ceph osd pool get mypool nodeep-scrub 	--控制是否开关深层扫描
nodeep-scrub: false
$ ceph osd pool set mypool nodeep-scrub true	--关闭深层扫描
set pool 2 nodeep-scrub to true
$ ceph osd pool get mypool scrub_min_interval 	--查看扫描间隔时间，这个得到OSD上查看，
--osd上执行
sudo ceph daemon osd.3 config show | grep scrub	--查看扫描时间配置
"mon_scrub_interval": "86400",	--轻量扫描时间
"osd_deep_scrub_interval": "604800.000000",	--深层扫描时间
"osd_max_scrubs": "1",	--扫描时启用几个线程进行扫描
"osd_scrub_invalid_stats": "true",	--定义scrub是否有效
"osd_scrub_max_interval": "604800.000000",	--定义最大执行scrub间隔为7天
"osd_scrub_min_interval": "86400.000000",	--定义最小执行普通scrub间隔为1天

4.10 存储池快照
快照用于读取存储池中的数据进行备份与还原，创建快照需要占用的磁盘空间会比较大，取决于存储池中的数据大小，使用以下命令创建快照：
4.10.1 创建快照
$ ceph osd pool mksnap mypool mypool-snap1 	--创建快照方式1	
$ rados -p mypool mksnap mypool-snap2	--创建快照方式2
4.10.2 验证快照
$ rados lssnap -p mypool
1       mypool-snap1    2021.12.11 16:06:21
2       mypool-snap2    2021.12.11 16:06:57
2 snaps	--总共2个快照
4.10.3 回滚快照
$ rados -p mypool put testfil1 /etc/passwd
$ rados -p mypool ls
testfil1
$ ceph osd pool mksnap mypool mypool-snap-test001	--先创建快照
created pool mypool snap mypool-snap-test001
$ rados -p mypool rm testfil1	--模拟删除文件
$ rados rollback -p mypool testfil1  mypool-snap-test001	--回滚快照mypool-snap-test001的对象文件testfil1到存储池mypool中，注：只能还原某个对象文件
rolled back pool mypool to snapshot mypool-snap-test001
$ rados -p mypool ls	--此时文件又恢复了
testfil1
4.10.4 删除快照
$ rados lssnap -p mypool
1       mypool-snap1    2021.12.11 16:06:21
2       mypool-snap2    2021.12.11 16:06:57
3       mypool-snap-test001     2021.12.11 16:15:14
3 snaps
$ ceph osd pool rmsnap mypool mypool-snap-test001
removed pool mypool snap mypool-snap-test001
$ ceph osd pool rmsnap mypool mypool-snap2
removed pool mypool snap mypool-snap2
$ rados lssnap -p mypool
1       mypool-snap1    2021.12.11 16:06:21
1 snaps
$ ceph osd pool rmsnap mypool mypool-snap1
removed pool mypool snap mypool-snap1
$ rados lssnap -p mypool
0 snaps

4.11 数据压缩：	--生产环境上一般不使用
如果使用blustore存储引擎，ceph支持称为"实时数据压缩"即边压缩边保存数据的功能，该功能有助于节省磁盘空间，可以在Bluestore OSD上创建的每个Ceph池上启用或禁用压缩，以节约磁盘空间，默认没有开户压缩，需要后期配置并开启。
4.11.1 启用压缩并指定压缩算法
$ ceph osd pool set mypool compression_algorithm snappy 	--默认算法为snappy，也是ceph推荐的压缩算法
snappy: 该配置为指定压缩使用的算法默认为snpppy，还有none、zlib、lz4、zstd和snappy等算法，zstd压缩比好，但消耗CPU，lz4和snappy对CPU占用较低，不建议使用zlib
4.11.2 指定压缩模式
ceph osd pool set mypool compression_mode aggressive 
aggressive: 压缩的模式，有none,aggressive,passive和force，默认none
none: 从不压缩数据
passive: 除非写操作具有可压缩的提示集，否则不要压缩数据
aggressive: 压缩数据，除非写操作具有不可压缩的提示集
force: 无论如何都尝试压缩数据，即使客户端暗示数据不可压缩也会压缩，也就是在所有情况下都使用压缩

存储池压缩设置参数：
compression_algorithm	--压缩算法
compression_mode	--压缩模式
compression_required_ratio	--压缩后与压缩前的压缩比，默认为0.875
compression_max_blob_size	--大于此的块在被压缩之前被分解成更小的blob(块)，此设置将覆盖bluestore压缩max blob*的全局设置
compression_min_blob_size	--小于此的块不被压缩，此设置将覆盖bluestore压缩max blob*的全局设置
全局压缩选项，这些可以配置到ceph.conf配置文件，作用于所有存储池：
blustore_compression_algorithm	--压缩算法
blustore_compression_mode	--压缩模块
blustore_compression_required_ratio	--压缩后与压缩前的压缩比，默认为0.875
blustore_compression_min_blob_size	--小于它的块不会被压缩，默认0
blustore_compression_max_blob_size	--大于它的块在压缩前会被拆成更小的块，默认0
blustore_compression_min_blob_size_ssd	--默认8k
blustore_compression_max_blob_size_ssd	--默认64k
blustore_compression_min_blob_size_hdd	--默认128k
blustore_compression_min_blob_size_hdd	--默认512k

到node节点验证：
[root@ceph01 ~]# ceph daemon osd.1 config show | grep compression
    "bluestore_compression_algorithm": "snappy",
    "bluestore_compression_max_blob_size": "0",
    "bluestore_compression_max_blob_size_hdd": "65536",
    "bluestore_compression_max_blob_size_ssd": "65536",
    "bluestore_compression_min_blob_size": "0",
    "bluestore_compression_min_blob_size_hdd": "8192",
    "bluestore_compression_min_blob_size_ssd": "8192",
    "bluestore_compression_mode": "none",
    "bluestore_compression_required_ratio": "0.875000",
    "bluestore_rocksdb_options": "compression=kNoCompression,max_write_buffer_number=4,min_write_buffer_number_to_merge=1,recycle_log_file_num=4,write_buffer_size=268435456,writable_file_max_buffer_size=0,compaction_readahead_size=2097152,max_background_compactions=2,max_total_wal_size=1073741824",
    "filestore_rocksdb_options": "max_background_jobs=10,compaction_readahead_size=2097152,compression=kNoCompression",
    "kstore_rocksdb_options": "compression=kNoCompression",
    "leveldb_compression": "true",
    "mon_rocksdb_options": "write_buffer_size=33554432,compression=kNoCompression,level_compaction_dynamic_level_bytes=true",
    "rbd_compression_hint": "none",
#ceph-deploy上操作
ceph osd pool set mypool compression_algorithm snappy 	--修改压缩算法
ceph osd pool get mypool compression_algorithm			--查看压缩算法
ceph osd pool set mypool compression_mode passive	--修改压缩模式
ceph osd pool get mypool compression_mode 			--查看压缩模式


五：CephX认证机制：
Ceph使用cephx协议对客户端进行身份认证，cephx用于对ceph保存的数据进行谁访问和授权，用于对访问ceph的请求进行认证和授权检测，与mon通信的请求都要经过ceph认证通过，但是也可以在mon节点关闭cephx认证机制。但是关闭认证之后 任何访问都将被允许，因此无法保证数据的安全性。
5.1 授权流程
每个mon节点都可以对客户端进行身份认证并颁发秘钥，因此多个mon节点就不存在单点故障和认证性能瓶颈，mon节点会返回用于身份认证的数据结构，其中包含获取ceph服务时用到的session key,session key通过客户端秘钥进行加密，秘钥是在客户端提前配置好的(/etc/ceph/ceph.client.admin.keyring)，客户端使用session key向mon请求所需要的服务，mon向客户端提供一个tiket，用于向实际 处理数据的OSD等服务验证客户端身份，MON和OSD共享同一个secret，因此OSD会信任所有MON发放的tiket，tiket存在有效期
注意： CephX身份验证功能仅限制在Ceph各组件之间，不能扩展到其它非ceph组件。ceph只负责认证授权，不能解决数据传输的加密问题

5.2访问流程
1. 客户端请求认证，读取ceph.conf文件得知mon服务器地址、自己客户端key的文件在哪，并拿着客户端key去mon服务器认证。
2. mon服务器验证客户端key是否合法，合法则生成session key，并用客户端key加密后发送给客户端
3. 客户端上用客户端key解密后得到session key,并向MON服务器发送session key申请tiket 
4. MON服务器验证session key是否合法，合法则用session key加密tiket并发送给客户端
5. 客户端使用session key解密tiket并拿着tiket访问OSD（或者MDS）
6. OSD验证tiket并返回数据
注：OSD和MON服务器共享tiket

5.3 访问用户
用户是指个人(ceph管理者)或系统参与者（MON/OSD/MDS）
通过创建用户，可以控制用户或哪个参与者能够访问ceph存储集群、以及可访问的存储池及存储池中的数据。ceph支持多种类型的用户，但可管理的用户都属于client类型，区分用户类型的原因在于，MON/OSD/MDS等系统组件特使用cephx协议，但是它们为非客户端。通过点号来分割用户类型和用户名，格式为TYPE.ID，例如 client.admin
$ ceph auth list
mds.ceph-mgr01
        key: AQDnJqthYDIRBhAAawCn6G0GT+LPVBOIWI0bHA==
        caps: [mds] allow
        caps: [mon] allow profile mds
        caps: [osd] allow rwx
osd.0
        key: AQC2g6Nh0cEXARAACWH1tqYFA/PQEyjgVQG2PQ==
        caps: [mgr] allow profile osd
        caps: [mon] allow profile osd
        caps: [osd] allow *
osd.1
        key: AQCghKNhVmZ3HhAASD4z2wdLYnf89VaU9WRQBQ==
        caps: [mgr] allow profile osd
        caps: [mon] allow profile osd
        caps: [osd] allow *
osd.10
        key: AQDHhqNhT/lFCxAAUhH3aclNoN0lsKFb/wNFaw==
        caps: [mgr] allow profile osd
        caps: [mon] allow profile osd
        caps: [osd] allow *
osd.11
        key: AQD8hqNhXh8vJhAATdLlCbFbT2yz7933cxb3Rg==
        caps: [mgr] allow profile osd
        caps: [mon] allow profile osd
        caps: [osd] allow *
osd.12
        key: AQAwh6Nhh3HaJRAAb6tPXjUMoTM+HSGWLz+7xg==
        caps: [mgr] allow profile osd
        caps: [mon] allow profile osd
        caps: [osd] allow *
osd.13
        key: AQBvh6NhfJgjFhAAr1pHixxZtip3+bA1dIM/Pg==
        caps: [mgr] allow profile osd
        caps: [mon] allow profile osd
        caps: [osd] allow *
osd.14
        key: AQCqh6Nhpsj4MhAAfRoN/4o7dSTnwfYzeL2/lQ==
        caps: [mgr] allow profile osd
        caps: [mon] allow profile osd
        caps: [osd] allow *
osd.2
        key: AQDihKNhC3skARAAGkDenlnM/PeW9puZicKDog==
        caps: [mgr] allow profile osd
        caps: [mon] allow profile osd
        caps: [osd] allow *
osd.3
        key: AQArhaNhejBsExAAg3vhjspeSMhGm0l/MVQ6hQ==
        caps: [mgr] allow profile osd
        caps: [mon] allow profile osd
        caps: [osd] allow *
osd.4
        key: AQBxhaNh1EZsGBAABSy6cgj+MLxVlpTs8zLtzA==
        caps: [mgr] allow profile osd
        caps: [mon] allow profile osd
        caps: [osd] allow *
osd.5
        key: AQCwhaNh2FSTChAAOMp+3Ed6ZBx3cjlpRAlO/Q==
        caps: [mgr] allow profile osd
        caps: [mon] allow profile osd
        caps: [osd] allow *
osd.6
        key: AQDlhaNhbrjOIRAADxKKBHX3T468D9WhJ2hEnA==
        caps: [mgr] allow profile osd
        caps: [mon] allow profile osd
        caps: [osd] allow *
osd.7
        key: AQAehqNhL98vLRAA6vb7FERP3RKQjtOPhDGcEQ==
        caps: [mgr] allow profile osd
        caps: [mon] allow profile osd
        caps: [osd] allow *
osd.8
        key: AQBWhqNhLl7yNxAALIOQCQquMwAnpvZzJK9gcg==
        caps: [mgr] allow profile osd
        caps: [mon] allow profile osd
        caps: [osd] allow *
osd.9
        key: AQCNhqNh7b2ZDBAAGAeaLG2RxsGoe/1eEOMitQ==
        caps: [mgr] allow profile osd
        caps: [mon] allow profile osd
        caps: [osd] allow *
client.admin
        key: AQBvQqJhejFEHhAAsUidhVFym74h036oDshlyw==
        caps: [mds] allow *
        caps: [mgr] allow *
        caps: [mon] allow *
        caps: [osd] allow *
client.bootstrap-mds
        key: AQBvQqJhxghFHhAAk8B6kse7gtQ7LxWjK6VC5w==
        caps: [mon] allow profile bootstrap-mds
client.bootstrap-mgr
        key: AQBvQqJhWSNGHhAAXMMG355+lvKSwrMpvM8f1A==
        caps: [mon] allow profile bootstrap-mgr
client.bootstrap-osd
        key: AQBvQqJhQe5GHhAAS4+JAPQsU2bzi+1X/gb5Jg==
        caps: [mon] allow profile bootstrap-osd
client.bootstrap-rbd
        key: AQBvQqJh27dHHhAAX1hOKBcG3ueBzPHbDVVz9Q==
        caps: [mon] allow profile bootstrap-rbd
client.bootstrap-rbd-mirror
        key: AQBvQqJhu39IHhAAosOokUxW0RMvTMpRj4rgVg==
        caps: [mon] allow profile bootstrap-rbd-mirror
client.bootstrap-rgw
        key: AQBvQqJhlEdJHhAA/6Z396smwahTc7aX65Y23w==
        caps: [mon] allow profile bootstrap-rgw
client.rgw.ceph-mgr01
        key: AQAlFathEiKlCRAAs45P1GqD2yv9Ta5Plj1naA==
        caps: [mon] allow rw
        caps: [osd] allow rwx
mgr.ceph-mgr01
        key: AQBqcaNhId4cHBAA0zFKwKdqIPKi0TjzWk8adQ==
        caps: [mds] allow *
        caps: [mon] allow profile mgr
        caps: [osd] allow *
mgr.ceph-mgr02
        key: AQCVnKNhUT7PGRAAOevjcHw/gcPpeSS+g5kAFw==
        caps: [mds] allow *
        caps: [mon] allow profile mgr
        caps: [osd] allow *
installed auth entries:

$ ceph auth get client.admin   --获取单个用户权限
[client.admin]
        key = AQBvQqJhejFEHhAAsUidhVFym74h036oDshlyw==
        caps mds = "allow *"
        caps mgr = "allow *"
        caps mon = "allow *"
        caps osd = "allow *"
exported keyring for client.admin

5.4 ceph授权和使能
ceph基于使能/能力来描述用户可针对MON/MGR,OSD或MDS使用的授权范围或级别。
通用语法格式： daemon-type 'allow caps' [...]
r: 向用户授予读取权限，访问mon以检查 CRUSH运行图时需要具有此车能力。
w: 一般OSD，向用户授予针对对象的写入权限。
x: 授予用户调用类方法（包括读取和写入）的能力，以及在监视器中执行auth操作的能力。
*: 授予用户对特定守护进程/存储池的读取、写入和执行权限，以及执行管理命令的能力
class-read: 授予用户调用类读取方法的能力，属于是x能力的子集。
class-write: 授予用户调用类写入方法的能力，属于是x能力的子集。
profile osd: 授予用户以某个OSD身份连接到其他OSD或监视器的权限，授予OSD权限，使OSD能够处理复制检测信息流量和状态报告（获取OSD的状信息）。
profile mds: 授予用户以某个MDS身份连接到其他MDS或监视器的权限 
profile bootstrap-osd: 授予用户引导OSD的权限（初始化OSD并将OSD加入ceph集群），授权给部署工具，使其在引导OSD时有权添加密钥。
profile bootstrap-mds: 授予用户引导元数据服务器的权限，授权部署工具权限，使其在引导元数据服务时有权添加密钥。

MON能力：
包括r/w/x 和allow profile cap(ceph的运行图)
例如：
mon 'allow rwx'
mon 'allow profile osd'
OSD能力：
包括r,w,x,class-read,class-write和profile osd，另外OSD能力还允许进行存储池和名称空间设置
osd 'allow capability' [pool=poolname] [namespace-name]\
MDS能力：
只需要allow或空都表示允许 
mds 'allow'
针对用户采用YPTE.ID表示法，例如osd.0指定是osd类并且ID为0的用户(节点)，client.admin是client类型的用户，其ID为admin。另外注意，每个项包含一个key=xxx项，以及一个或多个caps项，可以结合使用-o 文件名选项和 ceph auth list 将输出保存到某个文件 

5.5 ceph用户管理
添加一个用户会创建用户名（YPTE.ID）
$ ceph auth add client.tom mon 'allow r' osd 'allow rwx pool=mypool'   --key在用户创建时自己生成
added key for client.tom
$ ceph auth get client.tom
[client.tom]
        key = AQAjudJhYm5gHRAAbLLo+3di1uc06BYPD7PdOA==
        caps mon = "allow r"
        caps osd = "allow rwx pool=mypool"
exported keyring for client.tom 
$ ceph auth get-or-create client.jack mon 'allow r' osd 'allow rwx pool=mypool'  --获取或创建并返回key
[client.jack]
        key = AQBQutJhOwl3GxAAkzkiyHIdJ3qbz2YvouJBLg==
$ ceph auth get-or-create-key client.jack mon 'allow r' osd 'allow rwx pool=mypool' --获取或创建并只返回key主体信息
AQBQutJhOwl3GxAAkzkiyHIdJ3qbz2YvouJBLg==
$ ceph auth print-key client.jack   --获取key主体信息
AQBQutJhOwl3GxAAkzkiyHIdJ3qbz2YvouJBLg==
$ ceph auth print_key client.jack
AQBQutJhOwl3GxAAkzkiyHIdJ3qbz2YvouJBLg==
$ ceph auth caps client.jack mon 'allow rw' osd 'allow rw pool=mypool' --修改权限，会立即生效
updated caps for client.jack
$ ceph auth get client.jack
[client.jack]
        key = AQBQutJhOwl3GxAAkzkiyHIdJ3qbz2YvouJBLg==
        caps mon = "allow rw"
        caps osd = "allow rw pool=mypool"
exported keyring for client.jack	--删除用户
$ ceph auth del client.jack
updated
$ ceph auth get client.jack
Error ENOENT: failed to find client.jack in keyring

5.6 秘钥环管理
ceph的秘钥环是一个保存了secrets、keys、certificates并且能够让客户端认证访问ceph的keyring file（集合文件），一个keyring file可以保存一个或多个认证信息，每一个key都有一个实际名称加权限，类型为：
{client, mon, mds, osd}.name
当客户端访问ceph信息时，ceph会使用以下四个密钥环文件预设置密钥环设置：
/etc/ceph<$cluster name>.<user $type>.<user $id>.keyring	--保存单个用户的keyring
/etc/ceph/cluster.keyring	--保存多个用户的keyring
/etc/ceph/keyring	--未定义集群名称的多个用户的keyring
/etc/ceph/keyring.bin	--编译后的二进制文件

5.6.1 通过秘钥环文件备份与恢复用户：
使用ceph auth add等命令添加的用户还需要额外使用ceph-authtool命令为其创建用户秘钥环文件，创建keyring文件命令格式：
ceph-authtool --create-keyring FILE
5.6.1.1 导出用户认证信息至keyring文件：
将用户信息导出至keyring文件，对用户信息进行备份：
$ ceph auth get-or-create client.user1 mon 'allow r' osd 'allow * pool=mypool'  --创建新用户
[client.user1]
        key = AQAVv9JhRJwaLhAAH806EF6bWSVEEIi3HFyAjw==
$ ceph auth get client.user1
[client.user1]
        key = AQAVv9JhRJwaLhAAH806EF6bWSVEEIi3HFyAjw==
        caps mon = "allow r"
        caps osd = "allow * pool=mypool"
exported keyring for client.user1
$ ceph-authtool --create-keyring ceph.client.user1.keyring	--创建keyring空密钥环文件
creating ceph.client.user1.keyring
$ file ceph.client.user1.keyring	--文件类型是empty，跟touch一个文件一样
ceph.client.user1.keyring: empty
$ ceph auth get client.user1 -o ceph.client.user1.keyring	--导出备份keyring
catexported keyring for client.user1
$ cat ceph.client.user1.keyring	
[client.user1]
        key = AQAVv9JhRJwaLhAAH806EF6bWSVEEIi3HFyAjw==
        caps mon = "allow r"
        caps osd = "allow * pool=mypool"
$ ceph auth del client.user1	--模拟误删除用户
updated
$
$ ceph auth get client.user1	--此时用户已查询不到
Error ENOENT: failed to find client.user1 in keyring
$ ceph auth import  -i ceph.client.user1.keyring	--恢复备份文件keyring，并且key会跟之前一样。{如果新建同名用户是没有用的，因为key已经变了}
imported keyring
$ ceph auth get client.user1	--对比跟之前是否一样
[client.user1]
        key = AQAVv9JhRJwaLhAAH806EF6bWSVEEIi3HFyAjw==
        caps mon = "allow r"
        caps osd = "allow * pool=mypool"
exported keyring for client.user1

--一个keyring文件保存多个用户信息
$ ceph-authtool --create-keyring ceph.client.user.keyring
creating ceph.client.user.keyring
$ ceph-authtool ./ceph.client.user.keyring --import-keyring ./ceph.client.admin.keyring
importing contents of ./ceph.client.admin.keyring into ./ceph.client.user.keyring
$ ceph-authtool ./ceph.client.user.keyring --import-keyring ./ceph.client.user1.keyring
importing contents of ./ceph.client.user1.keyring into ./ceph.client.user.keyring
$ cat ./ceph.client.user.keyring
[client.admin]
        key = AQBvQqJhejFEHhAAsUidhVFym74h036oDshlyw==
        caps mds = "allow *"
        caps mgr = "allow *"
        caps mon = "allow *"
        caps osd = "allow *"
[client.user1]
        key = AQAVv9JhRJwaLhAAH806EF6bWSVEEIi3HFyAjw==
        caps mon = "allow r"
        caps osd = "allow * pool=mypool"


##########6 RBD的使用
cephFS:6789
mon：3300
注：如果开启防火墙则打开以上端口

创建一个存储池
$ ceph osd pool create rbd-data1 4 4
$ ceph osd pool application enable rbd-data1 rbd  --开启rbd
$ rbd pool init -p rbd-data1	--初始化pool
$ rbd create data-img1 --size 1G --pool rbd-data1 --image-format 2 --image-feature layering		--创建镜像
$ rbd create data-img2 --size 1G --pool rbd-data1 --image-format 2 --image-feature layering
$ rbd ls --pool rbd-data1 -l
NAME       SIZE   PARENT  FMT  PROT  LOCK
data-img1  1 GiB            2
data-img2  1 GiB            2
$ rbd --image data-img1 --pool rbd-data1 info
rbd image 'data-img1':
        size 1 GiB in 256 objects
        order 22 (4 MiB objects)
        snapshot_count: 0
        id: 198ab4c4a8acc
        block_name_prefix: rbd_data.198ab4c4a8acc
        format: 2
        features: layering
        op_features:
        flags:
        create_timestamp: Mon Jan  3 17:48:54 2022
        access_timestamp: Mon Jan  3 17:48:54 2022
        modify_timestamp: Mon Jan  3 17:48:54 2022
$ rbd ls --pool rbd-data1 -l --format json --pretty-format
[
    {
        "image": "data-img1",
        "id": "198ab4c4a8acc",
        "size": 1073741824,
        "format": 2
    },
    {
        "image": "data-img2",
        "id": "198b4ede436",
        "size": 1073741824,
        "format": 2
    }
]
#块存储特性简介
layering: 支持镜像分层快照特性，用于快照及写时复制，可以对image创建快照并捉住，然后从快照克隆出新的image出来，父子image之间采用COW技术，共享对象数据。
striping: 支持条带化v2,类似raid 0，只不过在ceph环境中的数据被分散到不同的对象中，可改善顺序读写场景较多情况下的性能。
exclusive-lock: 支持独占锁，限制一个镜像只能被一个客户端使用。
object-map: 支持对象映射（依赖exclusive-lock），加速数据导入导出及已用空间统计等，此特性开启的时候，会记录image所有对象的一个位图，用以标记对象是否真的存在，在一些场景下可以加速Io.
fast-diff: 快速计算镜像与快照数据差异对比（依赖object-map).
deep-flatten: 支持快照扁平化操作，用于快照管理时解决快照依赖关系等。
journaling: 修改数据是否记录日志，该特性可以通过记录日志并通过日志恢复数据（依赖独占锁），开启此特性会增加系统磁盘IO使用。
jewel默认开启的特性包括：layerin/exclusive-lock/object-map/fast-diff/deep-flatten	--如果内核版本太低导致挂载不上RBD，原因就是特性开得太多了，应该要关闭相关特性功能

#镜像特性的启用：
--启用或关闭指定存储池中的指定镜像的特性
$ rbd feature enable exclusive-lock --pool rbd-data1 --image data-img1	--开启特性
$ rbd --image data-img1 --pool rbd-data1 info
rbd image 'data-img1':
        size 1 GiB in 256 objects
        order 22 (4 MiB objects)
        snapshot_count: 0
        id: 198ab4c4a8acc
        block_name_prefix: rbd_data.198ab4c4a8acc
        format: 2
        features: layering, exclusive-lock
        op_features:
        flags:
        create_timestamp: Mon Jan  3 17:48:54 2022
        access_timestamp: Mon Jan  3 17:48:54 2022
        modify_timestamp: Mon Jan  3 17:48:54 2022
$ rbd feature disable exclusive-lock --pool rbd-data1 --image data-img1	--关闭特性
$ rbd --image data-img1 --pool rbd-data1 info
rbd image 'data-img1':
        size 1 GiB in 256 objects
        order 22 (4 MiB objects)
        snapshot_count: 0
        id: 198ab4c4a8acc
        block_name_prefix: rbd_data.198ab4c4a8acc
        format: 2
        features: layering
        op_features:
        flags:
        create_timestamp: Mon Jan  3 17:48:54 2022
        access_timestamp: Mon Jan  3 17:48:54 2022
        modify_timestamp: Mon Jan  3 17:48:54 2022

#客户端配置yum源：
客户端要想挂载使用ceph RBD,需要安装ceph客户端组件ceph-common,但是ceph-common不在centos的yum仓库中，因此需要单独配置yum源：
[root@centos7-node04 ~]# yum install epel-release
[root@centos7-node04 ~]# yum install -y https://mirrors.aliyun.com/ceph/rpm-octopus/el7/noarch/ceph-release-1-1.el7.noarch.rpm	
注：由于P版还没有centos7yum源，所以用O版centos7yum源。ubuntu18系统源上有ceph-common包，不用单独配置源
[root@centos7-node02 ~]# yum install -y ceph-common

#ceph-deploy上创建普通用户key
$ ceph auth add client.jack mon 'allow r' osd 'allow rwx pool=rbd-data1'
added key for client.jack
$ ceph auth get client.jack
[client.jack]
        key = AQDIluJhU6ZZChAA5bv43g5tMHQUk3O6FwK8dA==
        caps mon = "allow r"
        caps osd = "allow rwx pool=rbd-data1"
exported keyring for client.jack
$ ceph-authtool --create-keyring ceph.client.jack.keyring
creating ceph.client.jack.keyring
$ ceph auth get client.jack -o ceph.client.jack.keyring
exported keyring for client.jack
$ cat ceph.client.jack.keyring
[client.jack]
        key = AQDIluJhU6ZZChAA5bv43g5tMHQUk3O6FwK8dA==
        caps mon = "allow r"
        caps osd = "allow rwx pool=rbd-data1"
$ scp ceph.conf ceph.client.jack.keyring root@172.168.2.14:/etc/ceph/		--将配置文件和key文件复制到客户端/etc/ceph/目录下

#centos7客户端上测试是否有权限访问ceph存储
[root@centos7-node02 ~]# ceph --user jack -s	--当显示如下状态表示这个普通用户有权限访问ceph存储了
  cluster:
    id:     4d5745dd-5f75-485d-af3f-eeaad0c51648
    health: HEALTH_WARN
            1 pool(s) do not have an application enabled
            2 daemons have recently crashed

  services:
    mon: 3 daemons, quorum ceph01,ceph02,ceph03 (age 6h)
    mgr: ceph-mgr01(active, since 12d), standbys: ceph-mgr02
    mds: 1/1 daemons up
    osd: 15 osds: 15 up (since 3d), 15 in (since 3d)
    rgw: 1 daemon active (1 hosts, 1 zones)

  data:
    volumes: 1/1 healthy
    pools:   10 pools, 896 pgs
    objects: 304 objects, 126 MiB
    usage:   2.3 GiB used, 148 GiB / 150 GiB avail
    pgs:     896 active+clean

[root@centos7-node02 ~]# rbd --user jack -p rbd-data1 map data-img1	--映射存储块设备
/dev/rbd0
[root@centos7-node02 ~]# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   20G  0 disk
├─sda1            8:1    0    2G  0 part /boot
└─sda2            8:2    0   18G  0 part
  └─centos-root 253:0    0   18G  0 lvm  /
sr0              11:0    1 1024M  0 rom
rbd0            252:0    0    1G  0 disk
[root@centos7-node02 ~]# cat /etc/ceph/ceph.conf	--通过mon服务器携带认证信息去访问ceph存储
[global]
fsid = 4d5745dd-5f75-485d-af3f-eeaad0c51648
public_network = 192.168.13.0/24
cluster_network = 10.10.13.0/24
mon_initial_members = ceph01
mon_host = 192.168.13.31
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx

mon clock drift allowed = 1
mon clock drift warn backoff = 10
[root@centos7-node02 ~]# cat /etc/ceph/ceph.client.jack.keyring
[client.jack]
        key = AQDIluJhU6ZZChAA5bv43g5tMHQUk3O6FwK8dA==
        caps mon = "allow r"
        caps osd = "allow rwx pool=rbd-data1"
		
--测试挂载mysql存储
[root@centos7-node02 ~]# mkdir /data/mysql -p
--创建LVM，将/dev/rbd0全部创建一个分区，并更改分区类型为LVM，或者不更改直接使用pvcreate创建
[root@centos7-node02 ~]# pvcreate /dev/rbd0	--创建pv失败，因为centos7上lvm并不能识别rbd，需要更改lvm.conf配置文件
  Device /dev/rbd0 excluded by a filter.
[root@centos7-node02 ~]# grep types /etc/lvm/lvm.conf
        types =  [ "rbd", 1024 ]	--添加rbd类型，最大分区数为1024
		[root@centos7-node02 ~]# pvcreate /dev/rbd0
WARNING: dos signature detected on /dev/rbd0 at offset 510. Wipe it? [y/n]: y
  Wiping dos signature on /dev/rbd0.
  Physical volume "/dev/rbd0" successfully created.	--此时pv创建成功了
[root@centos7-node02 ~]# vgcreate myvg /dev/rbd0
[root@centos7-node02 ~]# lvcreate -l 100%FREE -n mylv myvg
[root@centos7-node02 ~]# mkfs.xfs /dev/myvg/mylv
[root@centos7-node02 ~]# mount /dev/myvg/mylv /data/mysql/	--挂载mysql存储目录
[root@centos7-node02 ~]# df -h
Filesystem               Size  Used Avail Use% Mounted on
devtmpfs                 898M     0  898M   0% /dev
tmpfs                    910M  100K  910M   1% /dev/shm
tmpfs                    910M   26M  885M   3% /run
tmpfs                    910M     0  910M   0% /sys/fs/cgroup
/dev/mapper/centos-root   18G  2.4G   16G  13% /
/dev/sda1                2.0G  153M  1.9G   8% /boot
tmpfs                    182M     0  182M   0% /run/user/0
/dev/mapper/myvg-mylv   1018M   33M  986M   4% /data/mysql
[root@centos7-node02 ~]# yum install -y mariadb-server mariadb	--安装mysql
[root@centos7-node02 ~]# vim /etc/my.cnf
[mysqld]
datadir=/data/mysql		--更改存储路径是
[root@centos7-node02 ~]# chown -R mysql.mysql /data/mysql/
[root@centos7-node02 ~]# systemctl start mariadb	--启动mysql
[root@centos7-node02 ~]# systemctl enable mariadb
Created symlink from /etc/systemd/system/multi-user.target.wants/mariadb.service to /usr/lib/systemd/system/mariadb.service.
[root@centos7-node02 ~]# netstat -tnlp | grep :3306
tcp        0      0 0.0.0.0:3306            0.0.0.0:*               LISTEN      117085/mysqld

#ceph-deploy上查看存储池rbd-data1使用空间为32M，其实已经写进来了
$ ceph df
--- RAW STORAGE ---
CLASS     SIZE    AVAIL     USED  RAW USED  %RAW USED
ssd    150 GiB  148 GiB  2.4 GiB   2.4 GiB       1.60
TOTAL  150 GiB  148 GiB  2.4 GiB   2.4 GiB       1.60

--- POOLS ---
POOL                   ID  PGS   STORED  OBJECTS     USED  %USED  MAX AVAIL
device_health_metrics   1   32      0 B        0      0 B      0     46 GiB
mypool                  2   64  2.7 KiB        2   12 KiB      0     46 GiB
myrbd1                  3   64  116 MiB       53  348 MiB   0.25     46 GiB
.rgw.root               4   32  1.3 KiB        4   48 KiB      0     46 GiB
default.rgw.log         5   32  3.6 KiB      209  408 KiB      0     46 GiB
default.rgw.control     6   32      0 B        8      0 B      0     46 GiB
default.rgw.meta        7  256      0 B        0      0 B      0     46 GiB
cephfs-metadata         8  256   31 KiB       22  172 KiB      0     46 GiB
cephfs-data             9   64      0 B        0      0 B      0     46 GiB
rbd-data1              12   64   32 MiB       29   97 MiB   0.07     46 GiB
[root@centos7-node02 ~]# lsmod | grep ceph	--客户端挂载ceph存储实际是挂载ceph模块
libceph               306750  1 rbd
dns_resolver           13140  1 libceph
libcrc32c              12644  4 xfs,ip_vs,libceph,nf_conntrack
[root@centos7-node02 ~]# modinfo libceph
filename:       /lib/modules/3.10.0-1127.el7.x86_64/kernel/net/ceph/libceph.ko.xz
license:        GPL
description:    Ceph core library
author:         Patience Warnick <patience@newdream.net>
author:         Yehuda Sadeh <yehuda@hq.newdream.net>
author:         Sage Weil <sage@newdream.net>
retpoline:      Y
rhelversion:    7.8
srcversion:     D4ABB648AE8130ECF90AA3F
depends:        libcrc32c,dns_resolver
intree:         Y
vermagic:       3.10.0-1127.el7.x86_64 SMP mod_unload modversions
signer:         CentOS Linux kernel signing key
sig_key:        69:0E:8A:48:2F:E7:6B:FB:F2:31:D8:60:F0:C6:62:D8:F1:17:3D:57
sig_hashalgo:   sha256

#ceph RBD容量拉伸
$ rbd ls -p rbd-data1 -l
NAME       SIZE   PARENT  FMT  PROT  LOCK
data-img1  1 GiB            2
data-img2  1 GiB            2
$ rbd resize --pool rbd-data1 --image data-img1 --size 2G	--ceph上拉伸存储
Resizing image: 100% complete...done.
$ rbd ls -p rbd-data1 -l
NAME       SIZE   PARENT  FMT  PROT  LOCK
data-img1  2 GiB            2
data-img2  1 GiB            2
---------------------------慎用---------------------------
----注：小插曲，如果客户端为非lVM卷，可以使用resize2fs和xfs_growfs命令分别对ext4和xfs文件系统进行容量拉伸，这个未进行严格测试，在生产上慎用
root@ubuntu18-node01:~# df -Th | grep /dev/rbd0
/dev/rbd0                            xfs      1014M  168M  847M  17% /data/mysql
root@ubuntu18-node01:~# xfs_growfs /dev/rbd0
meta-data=/dev/rbd0              isize=512    agcount=9, agsize=31744 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1 spinodes=0 rmapbt=0
         =                       reflink=0
data     =                       bsize=4096   blocks=262144, imaxpct=25
         =                       sunit=1024   swidth=1024 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=8 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 262144 to 384000
root@ubuntu18-node01:~# df -Th | grep /dev/rbd0
/dev/rbd0                            xfs       1.5G  168M  1.3G  12% /data/mysql
---------------------------慎用---------------------------

[root@centos7-node02 ~]# lsblk	--在ceph客户端上查看/dev/rbd0现在为2G了，但是/dev/myvg/mylv现在还是1G大小，需要进行lvm拉伸操作
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   20G  0 disk
├─sda1            8:1    0    2G  0 part /boot
└─sda2            8:2    0   18G  0 part
  └─centos-root 253:0    0   18G  0 lvm  /
sr0              11:0    1 1024M  0 rom
rbd0            252:0    0    2G  0 disk
└─myvg-mylv     253:1    0 1020M  0 lvm  /data/mysql
--centos7客户端上进行lvm拉伸
[root@centos7-node02 ~]# pvdisplay	
  --- Physical volume ---
  PV Name               /dev/rbd0
  VG Name               myvg
  PV Size               1.00 GiB / not usable 0
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              255
  Free PE               0
  Allocated PE          255
  PV UUID               KZMM7l-IPdw-smwp-WJ0Y-fEiM-xHH0-grWbZL
[root@centos7-node02 ~]# pvresize /dev/rbd0	--扩展/dev/rbd0大小
  Physical volume "/dev/rbd0" changed
  1 physical volume(s) resized or updated / 0 physical volume(s) not resized
[root@centos7-node02 ~]# pvdisplay
  --- Physical volume ---
  PV Name               /dev/rbd0
  VG Name               myvg
  PV Size               2.00 GiB / not usable 4.00 MiB
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              511
  Free PE               256
  Allocated PE          255
  PV UUID               KZMM7l-IPdw-smwp-WJ0Y-fEiM-xHH0-grWbZL
[root@centos7-node02 ~]# vgdisplay	--在pvextend后，vg大小就为为2G了，此时Free  PE有空间了
  --- Volume group ---
  VG Name               myvg
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               1
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <2.00 GiB
  PE Size               4.00 MiB
  Total PE              511
  Alloc PE / Size       255 / 1020.00 MiB
  Free  PE / Size       256 / 1.00 GiB
  VG UUID               PCuPF0-s3L7-OqIV-4q7n-b62b-j9yc-t8ffA8
[root@centos7-node02 ~]# lvextend -l +255 /dev/myvg/mylv	--扩展lv大小
  Size of logical volume myvg/mylv changed from 1.00 GiB (256 extents) to <2.00 GiB (511 extents).
  Logical volume myvg/mylv successfully resized.
[root@centos7-node02 ~]# lvdisplay	--lv扩展大小成功
  --- Logical volume ---
  LV Path                /dev/myvg/mylv
  LV Name                mylv
  VG Name                myvg
  LV UUID                fDIdMX-Pak3-zT32-EpnY-hdnG-OzhR-Izc1xM
  LV Write Access        read/write
  LV Creation host, time centos7-node02, 2022-01-16 15:04:22 +0800
  LV Status              available
  # open                 1
  LV Size                <2.00 GiB
  Current LE             511
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:1
[root@centos7-node02 ~]# df -h	--大小还是为1G 	
Filesystem               Size  Used Avail Use% Mounted on
devtmpfs                 898M     0  898M   0% /dev
tmpfs                    910M  100K  910M   1% /dev/shm
tmpfs                    910M   26M  885M   3% /run
tmpfs                    910M     0  910M   0% /sys/fs/cgroup
/dev/mapper/centos-root   18G  2.4G   16G  14% /
/dev/sda1                2.0G  153M  1.9G   8% /boot
tmpfs                    182M     0  182M   0% /run/user/0
/dev/mapper/myvg-mylv   1018M   62M  956M   7% /data/mysql
[root@centos7-node02 ~]# mount | grep /data/mysql	--查看是xfs文件系统还是ext4文件系统
/dev/mapper/myvg-mylv on /data/mysql type xfs (rw,relatime,attr2,inode64,sunit=8192,swidth=8192,noquota)
[root@centos7-node02 ~]# xfs_growfs /dev/myvg/mylv	--如果是ext4则使用resize2fs /dev/myvg/mylv
meta-data=/dev/mapper/myvg-mylv  isize=512    agcount=8, agsize=32768 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0 spinodes=0
data     =                       bsize=4096   blocks=261120, imaxpct=25
         =                       sunit=1024   swidth=1024 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=624, version=2
         =                       sectsz=512   sunit=8 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 261120 to 523264
[root@centos7-node02 ~]# df -h	--此时大小为2G了
Filesystem               Size  Used Avail Use% Mounted on
devtmpfs                 898M     0  898M   0% /dev
tmpfs                    910M  100K  910M   1% /dev/shm
tmpfs                    910M   26M  885M   3% /run
tmpfs                    910M     0  910M   0% /sys/fs/cgroup
/dev/mapper/centos-root   18G  2.4G   16G  14% /
/dev/sda1                2.0G  153M  1.9G   8% /boot
tmpfs                    182M     0  182M   0% /run/user/0
/dev/mapper/myvg-mylv    2.0G   63M  2.0G   4% /data/mysql

#设置centos7开机自动挂载ceph存储
[root@centos7-node02 ~]# vim /etc/rc.d/rc.local
#ceph
rbd --user jack -p rbd-data1 map data-img1
mount /dev/myvg/mylv /data/mysql/
[root@centos7-node02 ~]# chmod +x /etc/rc.d/rc.local
[root@centos7-node02 ~]# vim /usr/lib/systemd/system/stopSrv.service	--配置关机前的操作
[Unit]
Description=close services before reboot and shutdown
DefaultDependencies=no
Before=shutdown.target reboot.target halt.target
# This works because it is installed in the target and will be
#   executed before the target state is entered
# Also consider kexec.target

[Service]
Type=oneshot
ExecStart=/shell/halt_after_shell.sh

[Install]
WantedBy=halt.target reboot.target shutdown.target
[root@centos7-node02 ~]# systemctl is-enabled stopSrv.service
enabled
[root@centos7-node02 ~]# cat /shell/halt_after_shell.sh
#!/bin/sh

umount /data/mysql
[root@centos7-node02 ~]# ls -l /shell/halt_after_shell.sh
-rwxr-xr-x 1 root root 30 Jan 16 16:21 /shell/halt_after_shell.sh
[root@centos7-node02 ~]# reboot	--重启测试
注：经过重启测试得出如下问题：1. 在关机停止运行服务时一直卡在类似"A job running at /data/mysql"这里，无法正常关机。2. 强制关机并开机后，在/etc/rc.d/rc.local里面第一步成功，但是在第二步挂载"mount /dev/mapper/myvg-mylv /data/mysql"时不成功，始终没有挂载个，这两个问题需要解决。


#####设置ubuntu18开机挂载ceph存储
root@ubuntu18-node01:~# cat /lib/systemd/system/rc.local.service
------------
[Unit]
Description=/etc/rc.local Compatibility
Documentation=man:systemd-rc-local-generator(8)
ConditionFileIsExecutable=/etc/rc.local
After=network.target

[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
RemainAfterExit=yes
GuessMainPID=no
------------
root@ubuntu18-node01:~# cat /etc/rc.local
#!/bin/sh
rbd --user jack -p rbd-data1 map data-img2
/bin/mount /dev/rbd0 /data/mysql
------------
root@ubuntu18-node01:~# ls -l /etc/rc.local
-rwxr-xr-x 1 root root 99 Jan 21 16:28 /etc/rc.local
------------
root@ubuntu18-node01:~# cat /lib/systemd/system/mysql.service
# MySQL systemd service file
[Unit]
Description=MySQL Community Server
After=network.target
After=rc-local.service		#关键在这，在rc-local.service运行之后再运行

[Install]
WantedBy=multi-user.target

[Service]
Type=forking
User=mysql
Group=mysql
PIDFile=/run/mysqld/mysqld.pid
PermissionsStartOnly=true
ExecStartPre=/usr/share/mysql/mysql-systemd-start pre
ExecStart=/usr/sbin/mysqld --daemonize --pid-file=/run/mysqld/mysqld.pid
TimeoutSec=infinity
Restart=on-failure
RuntimeDirectory=mysqld
RuntimeDirectoryMode=755
LimitNOFILE=5000
------------
root@ubuntu18-node01:~# systemctl daemon-reload
root@ubuntu18-node01:~# systemctl reboot		--重启服务器
root@ubuntu18-node01:~# systemctl status mysql	--重启后挂载正常，mysql服务正常
* mysql.service - MySQL Community Server
   Loaded: loaded (/lib/systemd/system/mysql.service; enabled; vendor preset: enabled)
   Active: active (running) since Fri 2022-01-21 17:34:11 CST; 4s ago
  Process: 760 ExecStart=/usr/sbin/mysqld --daemonize --pid-file=/run/mysqld/mysqld.pid (code=exited, status=0/SUCCESS)
  Process: 747 ExecStartPre=/usr/share/mysql/mysql-systemd-start pre (code=exited, status=0/SUCCESS)
 Main PID: 762 (mysqld)
    Tasks: 27 (limit: 2232)
   CGroup: /system.slice/mysql.service
           `-762 /usr/sbin/mysqld --daemonize --pid-file=/run/mysqld/mysqld.pid

Jan 21 17:34:05 ubuntu18-node01 systemd[1]: Starting MySQL Community Server...
Jan 21 17:34:11 ubuntu18-node01 systemd[1]: Started MySQL Community Server.

#卸载并删除存储池rbd-data1中的镜像data-img2
root@ubuntu18-node01:~# systemctl stop mysql
root@ubuntu18-node01:~# umount /data/mysql
root@ubuntu18-node01:~# rbd --user jack -p rbd-data1 unmap data-img2	--客户端操作
然后取消开机自启动
rbd rm --pool rbd-data1 --image data-img2 	--服务端操作，永久删除镜像

#rbd镜像回收站机制
删除的镜像数据无法恢复，但是还有另外一种方法可以先把镜像移动到回收站，后期确认删除的时候再从回收站删除即可
rbd help trash	--回收站帮助命令
$ rbd ls -p rbd-data1 -l
NAME       SIZE     PARENT  FMT  PROT  LOCK
data-img1    2 GiB            2
data-img2  1.5 GiB            2
$ rbd status --pool rbd-data1 --image data-img1		--查看客户端挂载详情
Watchers:
        watcher=172.168.2.14:0/1168538719 client.105668 cookie=18446462598732840964
$ rbd status --pool rbd-data1 --image data-img2
Watchers:
        watcher=172.168.2.12:0/1558883488 client.108501 cookie=18446462598732840965
--客户端卸载ceph存储
root@ubuntu18-node01:~# systemctl stop mysql
root@ubuntu18-node01:~# umount /data/mysql
root@ubuntu18-node01:~# rbd --user jack -p rbd-data1 unmap data-img2
$ rbd status --pool rbd-data1 --image data-img2	--此时已无客户端挂载
Watchers: none
$ rbd trash move --pool rbd-data1 --image data-img2	--把data-img2移到回收站中
$ rbd ls -p rbd-data1  -l		--此时无法看到data-img2，因为在回收站中
NAME       SIZE   PARENT  FMT  PROT  LOCK
data-img1  2 GiB            2
root@ubuntu18-node01:~# rbd --user jack -p rbd-data1 map data-img2	--此时客户端挂载data-img2会报错，因为已经在回收站中了
rbd: sysfs write failed
In some cases useful info is found in syslog - try "dmesg | tail".
rbd: map failed: (2) No such file or directory
$ rbd trash move --pool rbd-data1 --image data-img1	--这个移除镜像动作是在客户端还在挂载的情况下操作的，非常危险，因为用户还在读写数据，会造成数据丢失，此操作只能在测试情况下操作，但是结果表明在线移除到回收站客户端上挂载还是正常使用的，当你挂载释放后将无法再次挂载
$ rbd ls --pool rbd-data1 -l	--此时无镜像
[root@centos7-node02 ~]# df -Th | grep /data/mysql	--此时客户端还在挂载中
/dev/mapper/myvg-mylv   xfs       2.0G   63M  2.0G   4% /data/mysql
$ rbd trash ls --pool rbd-data1	--在rbd回收站中查看镜像信息
198ab4c4a8acc data-img1
198b4ede436 data-img2
$ rbd trash restore --pool rbd-data1 --image data-img2 --image-id 198b4ede436	--恢复data-img2到存储池rbd-data1中
$ rbd trash ls --pool rbd-data1
198ab4c4a8acc data-img1
$ rbd ls --pool rbd-data1 -l 	--此时data-img2已正常对外提供服务
NAME       SIZE     PARENT  FMT  PROT  LOCK
data-img2  1.5 GiB            2
root@ubuntu18-node01:~#  rbd --user jack -p rbd-data1 map data-img2		--客户端直接挂载使用即可，服务端不用格式化，否则会造成全部数据丢失
root@ubuntu18-node01:~# mount /dev/rbd0 /data/mysql/
root@ubuntu18-node01:~# df -Th | grep mysql
/dev/rbd0                            xfs       1.5G  156M  1.4G  11% /data/mysql
--从回收站删除镜像可使用rbd trash remove --pool rbd-data1 --image-id 198b4ede436命令，此后这个回收站镜像将永久删除了

#rbd镜像快照
rbd help snap 
snap create (snap add)	--创建快照
snap limit clear	--清除一个镜像的快照上限
snap limit set	--设置一个镜像的快照上限
snap list (snap ls)	--列出快照
snap protect	--保护快照不允许被删除
snap unprotect	--允许一个快照被删除，取消快照保护
snap purge	--删除所有未被保护的镜像
snap remove (snap rm)	--删除删除
snap rename	--重命名快照
snap rollback (snap revert)	--还原快照

--创建快照
$ rbd snap create --pool rbd-data1 --image data-img2 --snap img2-snap-202201281718	--快照是全量的
Creating snap: 100% complete...done.
$ rbd snap list --pool rbd-data1 --image data-img2
SNAPID  NAME                    SIZE     PROTECTED  TIMESTAMP
     4  img2-snap-202201281718  1.5 GiB             Fri Jan 28 17:18:32 2022
--删除并还原快照
root@ubuntu18-node01:/data/mysql# ls
auto.cnf    ca.pem           client-key.pem  ibdata1      ib_logfile1  jackli  performance_schema  public_key.pem   server-key.pem
ca-key.pem  client-cert.pem  ib_buffer_pool  ib_logfile0  ibtmp1       mysql   private_key.pem     server-cert.pem  sys
root@ubuntu18-node01:/data/mysql# systemctl stop mysql
root@ubuntu18-node01:~# umount /data/mysql
root@ubuntu18-node01:~# rbd --user jack -p rbd-data1 unmap data-img2	--客户端上进行卸载
$ rbd snap rollback --pool rbd-data1 --image data-img2 --snap img2-snap-202201281718	--客户端上进行快照还原
Rolling back to snapshot: 100% complete...done.
root@ubuntu18-node01:~# rbd --user jack -p rbd-data1 map data-img2	--重新映射
/dev/rbd0
root@ubuntu18-node01:~# mount /dev/rbd0 /data/mysql/	--重新挂载
root@ubuntu18-node01:~# systemctl start mysql	--此时创建的jackli数据库已经没有了
root@ubuntu18-node01:~# ls /data/mysql/
auto.cnf    ca.pem           client-key.pem  ibdata1      ib_logfile1  mysql               private_key.pem  server-cert.pem  sys
ca-key.pem  client-cert.pem  ib_buffer_pool  ib_logfile0  ibtmp1       performance_schema  public_key.pem   server-key.pem
$ rbd snap limit set --pool rbd-data1 --image data-img2 --limit 3	--设置快照数据限制
$ rbd snap limit clear --pool rbd-data1 --image data-img2



####CephFS使用
可以实现文件系统共享功能，客户端通过ceph协议挂载并使用ceph集群作为数据存储服务器
cephFS需要运行Meta Data Services(MDS)服务，其守护进程为ceph-mds,ceph-mds进程管理与cephFS上存储的文件相关的元数据，并协调对ceph存储集群的访问。
cephFS的元数据使用的动态子树分区，把元数据划分名称空间对应到不同的mds，写入元数据的时候将元数据按照名称保存到不同主mds上，有点类似于nginx的缓存目录分层一样。

#挂载cephFS	
$ ceph auth add client.bob mon 'allow r' mds 'allow rw' osd 'allow rwx pool=cephfs-data'	--创建挂载cephFS用户
added key for client.bob
$ ceph auth get client.bob
[client.bob]
        key = AQCT4/NhiWQ1AhAAYDHqJsnRse43dHZ5b/lIYQ==
        caps mds = "allow rw"
        caps mon = "allow r"
        caps osd = "allow rwx pool=cephfs-data"
exported keyring for client.bob
$ ceph auth get client.bob -o ceph.client.bob.keyring	--nf
exported keyring for client.bob
$ ceph auth print-key client.bob
AQCT4/NhiWQ1AhAAYDHqJsnRse43dHZ5b/lIYQ==
$ ceph auth print-key client.bob > bob.key
$ ls -lt	--此时有这三个文件是我们需要的
-rw-rw-r-- 1 ceph ceph     40 Jan 28 20:39 bob.key
-rw-rw-r-- 1 ceph ceph    147 Jan 28 20:38 ceph.client.bob.keyring
-rw-rw-r-- 1 ceph ceph    324 Dec  4 21:52 ceph.conf
$ scp bob.key ceph.client.bob.keyring ceph.conf root@172.168.2.12:/etc/ceph/	--复制配置和key到cephFS客户端

--ubuntu18客户端上挂载cephFS
root@ubuntu18-node01:~# dpkg -l | grep ceph	
ii  ceph-common                            12.2.13-0ubuntu0.18.04.10                       amd64        common utilities to mount and interact with a ceph storage cluster
--内核空间搭载cephFS，内核需大于2.6.34支持（另外一种为用户空间，性能很差）
root@ubuntu18-node01:/etc/ceph# mkdir -p /data/cephfs
root@ubuntu18-node01:/etc/ceph# mount -t ceph 192.168.13.31:6789,192.168.13.32:6789,192.168.13.33:6789:/ /data/cephfs -o name=bob,secretfile=/etc/ceph/bob.key
或root@ubuntu18-node01:/etc/ceph# mount -t ceph 192.168.13.31:6789,192.168.13.32:6789,192.168.13.33:6789:/ /data/cephfs -o name=bob,secret=AQCT4/NhiWQ1AhAAYDHqJsnRse43dHZ5b/lIYQ==
root@ubuntu18-node01:/etc/ceph# df -TH
Filesystem                                                 Type      Size  Used Avail Use% Mounted on
udev                                                       devtmpfs  976M     0  976M   0% /dev
tmpfs                                                      tmpfs     200M  7.2M  193M   4% /run
/dev/mapper/ubuntu18--x8664--vg-root                       xfs        21G  5.2G   16G  26% /
tmpfs                                                      tmpfs     1.0G   17k  1.0G   1% /dev/shm
tmpfs                                                      tmpfs     5.3M     0  5.3M   0% /run/lock
tmpfs                                                      tmpfs     1.0G     0  1.0G   0% /sys/fs/cgroup
/dev/sda1                                                  ext4      991M   64M  859M   7% /boot
/dev/rbd0                                                  xfs       1.6G  177M  1.4G  12% /data/mysql
tmpfs                                                      tmpfs     200M     0  200M   0% /run/user/0
192.168.13.31:6789,192.168.13.32:6789,192.168.13.33:6789:/ ceph       50G     0   50G   0% /data/cephfs
root@ubuntu18-node01:/etc/ceph# cp /var/log/syslog /data/cephfs/
root@ubuntu18-node01:/etc/ceph# ls -l /data/cephfs/
-rw-r----- 1 root root 150324 Jan 28 20:55 syslog

--centos7客户端上挂载cephFS
[root@centos7-node02 ~]# rpm -qa | grep ceph-common
python3-ceph-common-15.2.15-0.el7.x86_64
ceph-common-15.2.15-0.el7.x86_64
[root@centos7-node02 ~]# ceph --user bob -s
  cluster:
    id:     4d5745dd-5f75-485d-af3f-eeaad0c51648
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum ceph01,ceph02,ceph03 (age 5h)
    mgr: ceph-mgr01(active, since 5h), standbys: ceph-mgr02
    mds: 1/1 daemons up
    osd: 15 osds: 15 up (since 5h), 15 in (since 3d)
    rgw: 1 daemon active (1 hosts, 1 zones)

  data:
    volumes: 1/1 healthy
    pools:   10 pools, 68 pgs
    objects: 449 objects, 352 MiB
    usage:   1.5 GiB used, 148 GiB / 150 GiB avail
    pgs:     68 active+clean
[root@centos7-node02 ~]# mkdir -p /data/cephfs
[root@centos7-node02 ~]# mount -t ceph 192.168.13.31:6789,192.168.13.32:6789,192.168.13.33:6789:/ /data/cephfs -o name=bob,secret=AQCT4/NhiWQ1AhAAYDHqJsnRse43dHZ5b/lIYQ==
--cephFS共享使用
[root@centos7-node02 /data/cephfs]# echo 123 >> /data/cephfs/hehe.txt
root@ubuntu18-node01:/etc/ceph# cat /data/cephfs/hehe.txt
123
234
注：cephFS是有先后顺序的，有文件锁是文件系统原因，跟cephFS没有关系

--设置开机自启动
root@ubuntu18-node01:/etc/ceph# cat /etc/fstab	
192.168.13.31:6789,192.168.13.32:6789,192.168.13.33:6789:/      /data/cephfs    ceph    defaults,name=bob,secret=AQCT4/NhiWQ1AhAAYDHqJsnRse43dHZ5b/lIYQ==,_netdev       0 0
root@ubuntu18-node01:/etc/ceph# mount -a
root@ubuntu18-node01:~# lsmod | grep ceph
ceph                  376832  1
libceph               315392  2 ceph,rbd
fscache                65536  1 ceph
libcrc32c              16384  2 xfs,libceph
root@ubuntu18-node01:~# modinfo ceph
filename:       /lib/modules/4.15.0-112-generic/kernel/fs/ceph/ceph.ko
license:        GPL
description:    Ceph filesystem for Linux
author:         Patience Warnick <patience@newdream.net>
author:         Yehuda Sadeh <yehuda@hq.newdream.net>
author:         Sage Weil <sage@newdream.net>
alias:          fs-ceph
srcversion:     B2806F4EAACAC1E19EE7AFA
depends:        libceph,fscache
retpoline:      Y
intree:         Y
name:           ceph
vermagic:       4.15.0-112-generic SMP mod_unload
signat:         PKCS#7
signer:
sig_key:
sig_hashalgo:   md4

--centos7用户空间挂载ceph-fs，当内核小于2.6.34时只能这样，性能很差，不用安装ceph-common
[root@centos7-node02 /data/cephfs]# cat /etc/yum.repos.d/ceph.repo
--------------
[Ceph]
name=Ceph packages for $basearch
baseurl=http://download.ceph.com/rpm-octopus/el7/$basearch
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc

[Ceph-noarch]
name=Ceph noarch packages
baseurl=http://download.ceph.com/rpm-octopus/el7/noarch
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc

[ceph-source]
name=Ceph source packages
baseurl=http://download.ceph.com/rpm-octopus/el7/SRPMS
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc
--------------
[root@centos7-node01 ~]# yum install -y ceph-fuse	--客户端安装
$ scp bob.key ceph.client.bob.keyring ceph.conf root@172.168.2.13:/etc/ceph/	--服务端操作
bob.key                                                                                                                                               100%   40     6.8KB/s   00:00
ceph.client.bob.keyring                                                                                                                               100%  147    15.9KB/s   00:00
ceph.conf                                                                                                                                             100%  324   162.0KB/s   00:00
[root@centos7-node01 ~]# ceph-fuse --name client.bob -m 192.168.13.31:6789,192.168.13.32:6789,192.168.13.33:6789 /data/cephfuse	--客户端挂载
ceph-fuse[2022-01-28T21:48:21.978+0800 7f6dc79c0f40 -1 init, newargv = 0x5581883c0df0 newargc=9
74775]: starting ceph client
ceph-fuse[74775]: starting fuse
[root@centos7-node01 ~]# cd /data/cephfuse/
[root@centos7-node01 /data/cephfuse]# dd if=/dev/zero of=1file bs=1M count=100
100+0 records in
100+0 records out
104857600 bytes (105 MB) copied, 2.2857 s, 45.9 MB/s
[root@centos7-node01 /data/cephfuse]# vim /etc/fstab	--设置开机挂载
none    /data/cephfuse  fuse.ceph       ceph.id=bob,ceph.conf=/etc/ceph/ceph.conf,_netdev,defaults      0 0


#cephFS高可用
1个active + 1个standby模式	--推荐这种模式
2个active + 1个standby模式
3个active
当MDS是动态子树分区时，mds集群是没有standby的MDS(都是active的MDS)，那么当挂掉某一个MDS，那么其它mon服务器将进行动态分配到其它MDS上，那么在分配的过程会有大量的IO消耗、cpu消耗。所以建议使用active + standby模式的MDS集群。因为MDS元数据不太，例如10几T数据，最大也就4个G元数据，同步很快，因为有部分人设置8个主

#部署MDS高可用:
$ ceph mds stat
mycephfs:1 {0=ceph-mgr01=up:active}
$ ceph fs status	--查看当前集群MDS状态，MDS节点是ceph-mgr01---192.168.13.31
mycephfs - 0 clients
========
RANK  STATE      MDS         ACTIVITY     DNS    INOS   DIRS   CAPS
 0    active  ceph-mgr01  Reqs:    0 /s    10     13     12      0
      POOL         TYPE     USED  AVAIL
cephfs-metadata  metadata   236k  46.5G
  cephfs-data      data       0   46.5G
MDS version: ceph version 16.2.6 (ee28fb57e47e9f88813e24bbf4c14496ca299d31) pacific (stable)

MDS集群规划：
active MDS: ceph-mon01---192.168.13.31,ceph-mon02---192.168.13.32
standby MDS: ceph-mon03---192.168.13.33，ceph-deploy---192.168.13.34
$ cat /etc/hosts
127.0.0.1 localhost
192.168.13.31 ceph01.hs.com   ceph-mon01        ceph-mgr01      ceph-osd01
192.168.13.32 ceph02.hs.com   ceph-mon02        ceph-mgr02      ceph-osd02
192.168.13.33 ceph03.hs.com   ceph-mon03                        ceph-osd03
192.168.13.34 ceph04.hs.com   ceph-deploy
$ ceph-deploy mds create ceph-mon02	--添加mds服务器
[ceph_deploy.conf][DEBUG ] found configuration file at: /var/lib/ceph/.cephdeploy.conf
[ceph_deploy.cli][INFO  ] Invoked (2.0.1): /usr/bin/ceph-deploy mds create ceph-mon02
[ceph_deploy.cli][INFO  ] ceph-deploy options:
[ceph_deploy.cli][INFO  ]  username                      : None
[ceph_deploy.cli][INFO  ]  verbose                       : False
[ceph_deploy.cli][INFO  ]  overwrite_conf                : False
[ceph_deploy.cli][INFO  ]  subcommand                    : create
[ceph_deploy.cli][INFO  ]  quiet                         : False
[ceph_deploy.cli][INFO  ]  cd_conf                       : <ceph_deploy.conf.cephdeploy.Conf instance at 0x7f6e491780f0>
[ceph_deploy.cli][INFO  ]  cluster                       : ceph
[ceph_deploy.cli][INFO  ]  func                          : <function mds at 0x7f6e491507d0>
[ceph_deploy.cli][INFO  ]  ceph_conf                     : None
[ceph_deploy.cli][INFO  ]  mds                           : [('ceph-mon02', 'ceph-mon02')]
[ceph_deploy.cli][INFO  ]  default_release               : False
[ceph_deploy.mds][DEBUG ] Deploying mds, cluster ceph hosts ceph-mon02:ceph-mon02
[ceph-mon02][DEBUG ] connection detected need for sudo
[ceph-mon02][DEBUG ] connected to host: ceph-mon02
[ceph-mon02][DEBUG ] detect platform information from remote host
[ceph-mon02][DEBUG ] detect machine type
[ceph_deploy.mds][INFO  ] Distro info: Ubuntu 18.04 bionic
[ceph_deploy.mds][DEBUG ] remote host will use systemd
[ceph_deploy.mds][DEBUG ] deploying mds bootstrap to ceph-mon02
[ceph-mon02][DEBUG ] write cluster configuration to /etc/ceph/{cluster}.conf
[ceph-mon02][WARNIN] mds keyring does not exist yet, creating one
[ceph-mon02][DEBUG ] create a keyring file
[ceph-mon02][DEBUG ] create path if it doesn't exist
[ceph-mon02][INFO  ] Running command: sudo ceph --cluster ceph --name client.bootstrap-mds --keyring /var/lib/ceph/bootstrap-mds/ceph.keyring auth get-or-create mds.ceph-mon02 osd allow rwx mds allow mon allow profile mds -o /var/lib/ceph/mds/ceph-ceph-mon02/keyring
[ceph-mon02][INFO  ] Running command: sudo systemctl enable ceph-mds@ceph-mon02
[ceph-mon02][WARNIN] Created symlink /etc/systemd/system/ceph-mds.target.wants/ceph-mds@ceph-mon02.service -> /lib/systemd/system/ceph-mds@.service.
[ceph-mon02][INFO  ] Running command: sudo systemctl start ceph-mds@ceph-mon02
[ceph-mon02][INFO  ] Running command: sudo systemctl enable ceph.target
[ceph-mon02][WARNIN] No data was received after 7 seconds, disconnecting...
$ ceph mds stat
mycephfs:1 {0=ceph-mgr01=up:active} 1 up:standby	--加进来的MDS自动为standby角色
$ ceph mds stat
mycephfs:1 {0=ceph-mgr01=up:active} 1 up:standby
$ ceph -s
  cluster:
    id:     4d5745dd-5f75-485d-af3f-eeaad0c51648
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum ceph01,ceph02,ceph03 (age 11h)
    mgr: ceph-mgr01(active, since 9d), standbys: ceph-mgr02
    mds: 1/1 daemons up, 1 standby
    osd: 15 osds: 15 up (since 9d), 15 in (since 12d)
    rgw: 1 daemon active (1 hosts, 1 zones)

  data:
    volumes: 1/1 healthy
    pools:   10 pools, 68 pgs
    objects: 472 objects, 453 MiB
    usage:   3.0 GiB used, 147 GiB / 150 GiB avail
    pgs:     68 active+clean
$ ceph fs get mycephfs
Filesystem 'mycephfs' (1)
fs_name mycephfs
epoch   137
flags   12
created 2021-12-04T18:16:31.743004+0800
modified        2022-01-28T15:44:43.850680+0800
tableserver     0
root    0
session_timeout 60
session_autoclose       300
max_file_size   1099511627776
required_client_features        {}
last_failure    0
last_failure_osd_epoch  7238
compat  compat={},rocompat={},incompat={1=base v0.20,2=client writeable ranges,3=default file layouts on dirs,4=dir inode in separate object,5=mds uses versioned encoding,6=dirfrag is stored in omap,7=mds uses inline data,8=no anchor table,9=file layout v2,10=snaprealm v2}
max_mds 1	--此参数表示MDS最大有多少个active MDS，所以加进来只有一个active MDS
in      0
up      {0=114114}
failed
damaged
stopped
data_pools      [9]
metadata_pool   8
inline_data     disabled
balancer
standby_count_wanted    1
[mds.ceph-mgr01{0:114114} state up:active seq 41 addr [v2:192.168.13.31:6800/3437480283,v1:192.168.13.31:6801/3437480283] compat {c=[1],r=[1],i=[7ff]}]
#设置为2个active
$ ceph fs set mycephfs max_mds 2
$ ceph mds stat
mycephfs:2 {0=ceph-mgr01=up:active,1=ceph-mon02=up:active}
$ ceph -s
  cluster:
    id:     4d5745dd-5f75-485d-af3f-eeaad0c51648
    health: HEALTH_WARN
            insufficient standby MDS daemons available

  services:
    mon: 3 daemons, quorum ceph01,ceph02,ceph03 (age 11h)
    mgr: ceph-mgr01(active, since 9d), standbys: ceph-mgr02
    mds: 2/2 daemons up
    osd: 15 osds: 15 up (since 9d), 15 in (since 12d)
    rgw: 1 daemon active (1 hosts, 1 zones)

  data:
    volumes: 1/1 healthy
    pools:   10 pools, 68 pgs
    objects: 490 objects, 453 MiB
    usage:   3.0 GiB used, 147 GiB / 150 GiB avail
    pgs:     68 active+clean

  io:
    client:   938 B/s wr, 0 op/s rd, 3 op/s wr

$ ceph fs get mycephfs
Filesystem 'mycephfs' (1)
fs_name mycephfs
epoch   143
flags   12
created 2021-12-04T18:16:31.743004+0800
modified        2022-02-06T19:24:47.670589+0800
tableserver     0
root    0
session_timeout 60
session_autoclose       300
max_file_size   1099511627776
required_client_features        {}
last_failure    0
last_failure_osd_epoch  7238
compat  compat={},rocompat={},incompat={1=base v0.20,2=client writeable ranges,3=default file layouts on dirs,4=dir inode in separate object,5=mds uses versioned encoding,6=dirfrag is stored in omap,7=mds uses inline data,8=no anchor table,9=file layout v2,10=snaprealm v2}
max_mds 2
in      0,1
up      {0=114114,1=114403}
failed
damaged
stopped
data_pools      [9]
metadata_pool   8
inline_data     disabled
balancer
standby_count_wanted    1
[mds.ceph-mgr01{0:114114} state up:active seq 41 addr [v2:192.168.13.31:6800/3437480283,v1:192.168.13.31:6801/3437480283] compat {c=[1],r=[1],i=[7ff]}]
[mds.ceph-mon02{1:1bee3} state up:active seq 5f addr [v2:192.168.13.32:1aa4/f33e6272,v1:192.168.13.32:1aa5/f33e6272] compat {c=[1],r=[1],i=[7ff]}]
#添加2两个standby MDS
#--ceph-mon03
$ ceph-deploy mds create ceph-mon03
[ceph_deploy.conf][DEBUG ] found configuration file at: /var/lib/ceph/.cephdeploy.conf
[ceph_deploy.cli][INFO  ] Invoked (2.0.1): /usr/bin/ceph-deploy mds create ceph-mon03
[ceph_deploy.cli][INFO  ] ceph-deploy options:
[ceph_deploy.cli][INFO  ]  username                      : None
[ceph_deploy.cli][INFO  ]  verbose                       : False
[ceph_deploy.cli][INFO  ]  overwrite_conf                : False
[ceph_deploy.cli][INFO  ]  subcommand                    : create
[ceph_deploy.cli][INFO  ]  quiet                         : False
[ceph_deploy.cli][INFO  ]  cd_conf                       : <ceph_deploy.conf.cephdeploy.Conf instance at 0x7f313e4b60f0>
[ceph_deploy.cli][INFO  ]  cluster                       : ceph
[ceph_deploy.cli][INFO  ]  func                          : <function mds at 0x7f313e48e7d0>
[ceph_deploy.cli][INFO  ]  ceph_conf                     : None
[ceph_deploy.cli][INFO  ]  mds                           : [('ceph-mon03', 'ceph-mon03')]
[ceph_deploy.cli][INFO  ]  default_release               : False
[ceph_deploy.mds][DEBUG ] Deploying mds, cluster ceph hosts ceph-mon03:ceph-mon03
[ceph-mon03][DEBUG ] connection detected need for sudo
[ceph-mon03][DEBUG ] connected to host: ceph-mon03
[ceph-mon03][DEBUG ] detect platform information from remote host
[ceph-mon03][DEBUG ] detect machine type
[ceph_deploy.mds][INFO  ] Distro info: Ubuntu 18.04 bionic
[ceph_deploy.mds][DEBUG ] remote host will use systemd
[ceph_deploy.mds][DEBUG ] deploying mds bootstrap to ceph-mon03
[ceph-mon03][DEBUG ] write cluster configuration to /etc/ceph/{cluster}.conf
[ceph-mon03][WARNIN] mds keyring does not exist yet, creating one
[ceph-mon03][DEBUG ] create a keyring file
[ceph-mon03][DEBUG ] create path if it doesn't exist
[ceph-mon03][INFO  ] Running command: sudo ceph --cluster ceph --name client.bootstrap-mds --keyring /var/lib/ceph/bootstrap-mds/ceph.keyring auth get-or-create mds.ceph-mon03 osd allow rwx mds allow mon allow profile mds -o /var/lib/ceph/mds/ceph-ceph-mon03/keyring
[ceph-mon03][INFO  ] Running command: sudo systemctl enable ceph-mds@ceph-mon03
[ceph-mon03][WARNIN] Created symlink /etc/systemd/system/ceph-mds.target.wants/ceph-mds@ceph-mon03.service -> /lib/systemd/system/ceph-mds@.service.
[ceph-mon03][INFO  ] Running command: sudo systemctl start ceph-mds@ceph-mon03
[ceph-mon03][INFO  ] Running command: sudo systemctl enable ceph.target
[ceph-mon03][WARNIN] No data was received after 7 seconds, disconnecting...
#--ceph-deploy
$ sudo apt update
$ sudo apt install -y ceph-mds
$ ceph-deploy mds create  ceph-deploy
#查看ceph fs状态
$ ceph fs status
mycephfs - 3 clients
========
RANK  STATE      MDS         ACTIVITY     DNS    INOS   DIRS   CAPS
 0    active  ceph-mgr01  Reqs:    0 /s    13     16     12      8
 1    active  ceph-mon02  Reqs:    0 /s    10     13     11      0
      POOL         TYPE     USED  AVAIL
cephfs-metadata  metadata   404k  45.3G
  cephfs-data      data     300M  45.3G
STANDBY MDS
 ceph-mon03
ceph-deploy
                                    VERSION                                                   DAEMONS
ceph version 16.2.6 (ee28fb57e47e9f88813e24bbf4c14496ca299d31) pacific (stable)  ceph-mgr01, ceph-mon02, ceph-mon03
ceph version 16.2.7 (dd0603118f56ab514f133c8d2e3adfc983942503) pacific (stable)             ceph-deploy

#配置MDS standby和active的对应关系
$ cd ceph-cluster/
$ vim ceph.conf
---------
[global]
fsid = 4d5745dd-5f75-485d-af3f-eeaad0c51648
public_network = 192.168.13.0/24
cluster_network = 10.10.13.0/24
mon_initial_members = ceph01
mon_host = 192.168.13.31
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx

mon clock drift allowed = 1
mon clock drift warn backoff = 10


[mds.ceph-mon03]
#mds_standby_for_fscid = mycephfs
mds_standby_for_name = ceph-mon02	--配置active MDS为ceph-mon02
mds_standby_replay = true			--配置是否中继同步active元数据

[mds.ceph-deploy]
#mds_standby_for_fscid = mycephfs
mds_standby_for_name = ceph-mgr01
mds_standby_replay = true
---------

$ ceph-deploy --overwrite-conf config push ceph-mgr01
$ ceph-deploy --overwrite-conf config push ceph-deploy
$ ceph-deploy --overwrite-conf config push ceph-mon02
$ ceph-deploy --overwrite-conf config push ceph-mon03
root@ansible:~# ansible ceph -m shell -a 'cat /etc/ceph/ceph.conf'
192.168.13.34 | SUCCESS | rc=0 >>
[global]
fsid = 4d5745dd-5f75-485d-af3f-eeaad0c51648
public_network = 192.168.13.0/24
cluster_network = 10.10.13.0/24
mon_initial_members = ceph01
mon_host = 192.168.13.31
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx

mon clock drift allowed = 1
mon clock drift warn backoff = 10

[mds.ceph-mon03]
#mds_standby_for_fscid = mycephfs
mds_standby_for_name = ceph-mon02
mds_standby_replay = true

[mds.ceph-deploy]
#mds_standby_for_fscid = mycephfs
mds_standby_for_name = ceph-mgr01
mds_standby_replay = true

192.168.13.33 | SUCCESS | rc=0 >>
[global]
fsid = 4d5745dd-5f75-485d-af3f-eeaad0c51648
public_network = 192.168.13.0/24
cluster_network = 10.10.13.0/24
mon_initial_members = ceph01
mon_host = 192.168.13.31
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx

mon clock drift allowed = 1
mon clock drift warn backoff = 10

[mds.ceph-mon03]
#mds_standby_for_fscid = mycephfs
mds_standby_for_name = ceph-mon02
mds_standby_replay = true

[mds.ceph-deploy]
#mds_standby_for_fscid = mycephfs
mds_standby_for_name = ceph-mgr01
mds_standby_replay = true

192.168.13.32 | SUCCESS | rc=0 >>
[global]
fsid = 4d5745dd-5f75-485d-af3f-eeaad0c51648
public_network = 192.168.13.0/24
cluster_network = 10.10.13.0/24
mon_initial_members = ceph01
mon_host = 192.168.13.31
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx

mon clock drift allowed = 1
mon clock drift warn backoff = 10

[mds.ceph-mon03]
#mds_standby_for_fscid = mycephfs
mds_standby_for_name = ceph-mon02
mds_standby_replay = true

[mds.ceph-deploy]
#mds_standby_for_fscid = mycephfs
mds_standby_for_name = ceph-mgr01
mds_standby_replay = true

192.168.13.31 | SUCCESS | rc=0 >>
[global]
fsid = 4d5745dd-5f75-485d-af3f-eeaad0c51648
public_network = 192.168.13.0/24
cluster_network = 10.10.13.0/24
mon_initial_members = ceph01
mon_host = 192.168.13.31
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx

mon clock drift allowed = 1
mon clock drift warn backoff = 10

[mds.ceph-mon03]
#mds_standby_for_fscid = mycephfs
mds_standby_for_name = ceph-mon02
mds_standby_replay = true

[mds.ceph-deploy]
#mds_standby_for_fscid = mycephfs
mds_standby_for_name = ceph-mgr01
mds_standby_replay = true

root@ansible:~# ansible ceph -m shell -a 'ls /etc/systemd/system//*mds*'
192.168.13.34 | SUCCESS | rc=0 >>
ceph-mds@ceph-deploy.service
192.168.13.32 | SUCCESS | rc=0 >>
ceph-mds@ceph-mon02.service
192.168.13.33 | SUCCESS | rc=0 >>
ceph-mds@ceph-mon03.service
192.168.13.31 | SUCCESS | rc=0 >>
ceph-mds@ceph-mgr01.service

root@ansible:~# ansible 192.168.13.34  -m shell -a 'systemctl restart ceph-mds@ceph-deploy.service'
192.168.13.34 | SUCCESS | rc=0 >>
root@ansible:~# ansible 192.168.13.33  -m shell -a 'systemctl restart ceph-mds@ceph-mon03.service'
192.168.13.33 | SUCCESS | rc=0 >>
root@ansible:~# ansible 192.168.13.32  -m shell -a 'systemctl restart ceph-mds@ceph-mon02.service'	--此时重启active MDS后，将会由指定的standby MDS接管
192.168.13.32 | SUCCESS | rc=0 >>
$ ceph fs status
mycephfs - 3 clients
========
RANK  STATE      MDS         ACTIVITY     DNS    INOS   DIRS   CAPS
 0    active  ceph-mgr01  Reqs:    0 /s    13     16     12      8
 1    failed														--为失败状态
      POOL         TYPE     USED  AVAIL
cephfs-metadata  metadata   404k  45.3G
  cephfs-data      data     300M  45.3G
STANDBY MDS
ceph-deploy
 ceph-mon03
                                    VERSION                                             DAEMONS
ceph version 16.2.6 (ee28fb57e47e9f88813e24bbf4c14496ca299d31) pacific (stable)  ceph-mgr01, ceph-mon03
ceph version 16.2.7 (dd0603118f56ab514f133c8d2e3adfc983942503) pacific (stable)       ceph-deploy
$ ceph fs status
mycephfs - 3 clients
========
RANK  STATE      MDS         ACTIVITY     DNS    INOS   DIRS   CAPS
 0    active  ceph-mgr01  Reqs:    0 /s    13     16     12      8
 1    rejoin  ceph-mon03                    0      3      1      0	--rejoin状态
      POOL         TYPE     USED  AVAIL
cephfs-metadata  metadata   404k  45.3G
  cephfs-data      data     300M  45.3G
STANDBY MDS
ceph-deploy
                                    VERSION                                             DAEMONS
ceph version 16.2.6 (ee28fb57e47e9f88813e24bbf4c14496ca299d31) pacific (stable)  ceph-mgr01, ceph-mon03
ceph version 16.2.7 (dd0603118f56ab514f133c8d2e3adfc983942503) pacific (stable)       ceph-deploy
$ ceph fs status
mycephfs - 3 clients
========
RANK  STATE      MDS         ACTIVITY     DNS    INOS   DIRS   CAPS
 0    active  ceph-mgr01  Reqs:    0 /s    13     16     12      8
 1    active  ceph-mon03  Reqs:    0 /s    10     13     11      0	--此时ceph-mon03成功加入为active
      POOL         TYPE     USED  AVAIL
cephfs-metadata  metadata   404k  45.3G
  cephfs-data      data     300M  45.3G
STANDBY MDS
ceph-deploy
 ceph-mon02
                                    VERSION                                                   DAEMONS
ceph version 16.2.6 (ee28fb57e47e9f88813e24bbf4c14496ca299d31) pacific (stable)  ceph-mgr01, ceph-mon03, ceph-mon02
ceph version 16.2.7 (dd0603118f56ab514f133c8d2e3adfc983942503) pacific (stable)             ceph-deploy
root@ansible:~# ansible 192.168.13.31  -m shell -a 'systemctl restart ceph-mds@ceph-mgr01.service'	--重启ceph-mds@ceph-mgr01.service服务


#通过ganesha将cephfs导出为NFS:
通过ganesha将cephfs通过NFS共享使用：
https://www.server-world.info/en/note?os=Ubuntu_20.04&p=ceph15&f=8
[root@ceph02 ~]# apt install nfs-ganesha-ceph -y
[root@ceph02 ~]# mv /etc/ganesha/ganesha.conf /etc/ganesha/ganesha.conf.bak
[root@ceph02 ~]# vim /etc/ganesha/ganesha.conf
NFS_CORE_PARAM {
    # disable NLM
    Enable_NLM = false;
    # disable RQUOTA (not suported on CephFS)
    Enable_RQUOTA = false;
    # NFS protocol
    Protocols = 4;
}
EXPORT_DEFAULTS {
    # default access mode
    Access_Type = RW;
}
EXPORT {
    # uniq ID
    Export_Id = 1;
    # mount path of CephFS
    Path = "/";
    FSAL {
        name = CEPH;
        # hostname or IP address of this Node
        hostname="192.168.13.31";
    }
    # setting for root Squash
    Squash="No_root_squash";
    # NFSv4 Pseudo path
    Pseudo="/nfspath";
    # allowed security options
    SecType = "sys";
}
LOG {
    # default log level
    Default_Log_Level = WARN;
}
systemctl restart nfs-ganesha		--ganesha服务启动失败，需要再找原因
mount -t nfs 192.168.13.31:/nfspath /mnt	



#radosgw高可用
radosgw本身无状态，安装多个副本，并且使用负载均衡器代理到后端即可。ceph01之前已经安装radosgw,现在添加一个节点ceph04安装radosgw:
ceph04安装命令：
--使用root用户进行安装
apt install -y radosgw
--切换为ceph用户进行部署
ceph-deploy rgw create ceph-deploy

--查看ceph radosgw进程
root@ansible:~/ansible# ansible ceph -m shell -a 'ps -ef | grep radosgw'
192.168.13.34 | SUCCESS | rc=0 >>
root      4380  4379 97 14:21 pts/1    00:00:07 /bin/sh -c ps -ef | grep radosgw
root      4382  4380  0 14:21 pts/1    00:00:00 grep radosgw
ceph     31659     1  0 Feb07 ?        04:50:42 /usr/bin/radosgw -f --cluster ceph --name client.rgw.ceph-deploy --setuser ceph --setgroup ceph

192.168.13.31 | SUCCESS | rc=0 >>
ceph       93816       1  1 Feb07 ?        05:53:09 /usr/bin/radosgw -f --cluster ceph --name client.rgw.ceph-mgr01 --setuser ceph --setgroup ceph
root      292515  292513 82 14:21 pts/1    00:00:05 /bin/sh -c ps -ef | grep radosgw
root      292517  292515 67 14:21 pts/1    00:00:00 grep radosgw

--查看ceph集群状态
$ ceph -s
  cluster:
    id:     4d5745dd-5f75-485d-af3f-eeaad0c51648
    health: HEALTH_WARN
            There are daemons running an older version of ceph

  services:
    mon: 3 daemons, quorum ceph01,ceph02,ceph03 (age 6h)
    mgr: ceph-mgr01(active, since 4w), standbys: ceph-mgr02
    mds: 2/2 daemons up, 2 standby
    osd: 15 osds: 15 up (since 2d), 15 in (since 7d)
    rgw: 2 daemons active (2 hosts, 1 zones)	--目前radosgw有两进程，我们分别 安装在ceph01,ceph04上

  data:
    volumes: 1/1 healthy
    pools:   10 pools, 68 pgs
    objects: 491 objects, 453 MiB
    usage:   3.5 GiB used, 146 GiB / 150 GiB avail
    pgs:     68 active+clean

$ ceph osd pool ls	--查看存储池
device_health_metrics
mypool
myrbd1
.rgw.root
default.rgw.log
default.rgw.control
default.rgw.meta
cephfs-metadata
cephfs-data
rbd-data1
注：后序有数据写入后，会生产存储池'default.rgw.buckets.data'和'default.rgw.buckets.index'
ceph osd pool get default.rgw.buckets.data crush_rule	--查看是否是副本池规则
ceph osd pool get default.rgw.buckets.data size		--查看副本数
--web访问radosgw
http://192.168.13.34:7480/
http://192.168.13.34:7480/

--radosgw存储池功能

--获取radosgw中zone为'default'的信息,radosgw-admin是管理radosgw管理命令
$ radosgw-admin zone get --rgw-zone="default"	
{
    "id": "46daa4c7-cddc-429f-8f05-a501a521e6b6",
    "name": "default",
    "domain_root": "default.rgw.meta:root",
    "control_pool": "default.rgw.control",
    "gc_pool": "default.rgw.log:gc",
    "lc_pool": "default.rgw.log:lc",
    "log_pool": "default.rgw.log",
    "intent_log_pool": "default.rgw.log:intent",
    "usage_log_pool": "default.rgw.log:usage",
    "roles_pool": "default.rgw.meta:roles",
    "reshard_pool": "default.rgw.log:reshard",
    "user_keys_pool": "default.rgw.meta:users.keys",
    "user_email_pool": "default.rgw.meta:users.email",
    "user_swift_pool": "default.rgw.meta:users.swift",
    "user_uid_pool": "default.rgw.meta:users.uid",
    "otp_pool": "default.rgw.otp",
    "system_key": {
        "access_key": "",
        "secret_key": ""
    },
    "placement_pools": [
        {
            "key": "default-placement",
            "val": {
                "index_pool": "default.rgw.buckets.index",
                "storage_classes": {
                    "STANDARD": {
                        "data_pool": "default.rgw.buckets.data"
                    }
                },
                "data_extra_pool": "default.rgw.buckets.non-ec",
                "index_type": 0
            }
        }
    ],
    "realm_id": "",
    "notif_pool": "default.rgw.log:notif"
}

--更改ceph radosgw端口为9900，并重启radosgw服务使其生效
--ceph-deploy操作
$ cat /etc/ceph/ceph.conf
-------
[client.rgw.ceph-mgr01]
rgw_host = ceph-mgr01
rgw_frontends = civetweb port=9900

[client.rgw.ceph-deploy]
rgw_host = ceph-deploy
rgw_frontends = civetweb port=9900
-------
$ ceph-deploy --overwrite-conf config push ceph-deploy
$ ceph-deploy --overwrite-conf config push ceph-deploy
--节点上操作
[root@ceph01 ~]# systemctl restart ceph-radosgw@rgw.ceph-mgr01.service
[root@ceph04 ~]# systemctl restart ceph-radosgw@rgw.ceph-deploy.service
--web访问radosgw
http://192.168.13.34:9900/
http://192.168.13.34:9900/

--radosgw签名证书，有两种方式
1. 推荐把泛域名证书放到nginx上
2. rgw内置https功能，需要radosgw自签，这个不被信息。


#日志及其它优化配置
1. 创建日志目录
[root@ceph01 ~]# mkdir /var/log/radosgw
[root@ceph01 ~]# chown ceph.ceph /var/log/radosgw
--当前配置
$ cat /etc/ceph/ceph.conf
-------
[client.rgw.ceph-mgr01]
rgw_host = ceph-mgr01
rgw_frontends = "civetweb port=9900+8443s ssl_certificate=/etc/ceph/certs/civetweb.pem error_log_file=/var/log/radosgw/civetweb.error.log access_log_file=/var/log/radosgw/civetweb.access.log request_timeout_ms=30000 num_threads=200"
-------
#URL: https://docs.ceph.com/en/mimic/radosgw/config-ref/
num_threads默认值等于 rgw_thread_pool_size=100
[root@ceph01 ~]# systemctl restart ceph-radosgw@rgw.ceph-mgr01.service


##RGW Server配置
1. 创建RGW帐户
$ radosgw-admin user create --uid='jack' --display-name='jack'
{
    "user_id": "jack",
    "display_name": "jack",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "subusers": [],
    "keys": [
        {
            "user": "jack",
            "access_key": "U5XEBIOGLYHXY4N544GB",
            "secret_key": "nWPoq8gAtpsxhEeKcxOGBK1uFv9rqm4Si7vT9ey9"
        }
    ],
    "swift_keys": [],
    "caps": [],
    "op_mask": "read, write, delete",
    "default_placement": "",
    "default_storage_class": "",
    "placement_tags": [],
    "bucket_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "user_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "temp_url_keys": [],
    "type": "rgw",
    "mfa_ids": []
}
$ radosgw-admin user list
[
    "jack"
]

2. 安装s3cmd客户端（s3cmd是一个通过命令行访问ceph RGW实现创建存储桶、上传、下载以及管理数据到对象存储的命令行客户端工具。）
root@ansible:~/ansible# apt-cache madison s3cmd
     s3cmd |    2.0.1-2 | http://mirrors.aliyun.com/ubuntu bionic/universe amd64 Packages
     s3cmd |    2.0.1-2 | http://mirrors.aliyun.com/ubuntu bionic/universe i386 Packages
     s3cmd |    2.0.1-2 | http://mirrors.aliyun.com/ubuntu bionic/universe Sources
root@ansible:~/ansible# apt install -y s3cmd
root@ansible:~/ansible# s3cmd --help
  --configure           Invoke interactive (re)configuration tool. Optionally
                        use as '--configure s3://some-bucket' to test access
                        to a specific bucket instead of attempting to list
                        them all.
--安装/usr/bin/gpg软件
root@ansible:/etc/ansible/roles# apt install -y gnupg2

root@ansible:~/ansible# s3cmd --configure	--以交互式方式生成s3cmd配置文件

Enter new values or accept defaults in brackets with Enter.
Refer to user manual for detailed description of all options.

Access key and Secret key are your identifiers for Amazon S3. Leave them empty for using the env variables.
Access Key: U5XEBIOGLYHXY4N544GB		--1. 输入key
Secret Key: nWPoq8gAtpsxhEeKcxOGBK1uFv9rqm4Si7vT9ey9	--2. 输入secret
Default Region [US]:		--3. 设定默认地区，就选US即可

Use "s3.amazonaws.com" for S3 Endpoint and not modify it to the target Amazon S3.
S3 Endpoint [s3.amazonaws.com]: 192.168.13.31:9900		--4. 设置radosgw的访问地址或域名

Use "%(bucket)s.s3.amazonaws.com" to the target Amazon S3. "%(bucket)s" and "%(location)s" vars can be used
if the target S3 system supports dns based buckets.
DNS-style bucket+hostname:port template for accessing a bucket [%(bucket)s.s3.amazonaws.com]: 192.168.13.31:9900/%(bucket)		--5. 输入backet的完整格式名称，也可以是%(bucket)s.192.168.13.31:9900

Encryption password is used to protect your files from reading
by unauthorized persons while in transfer to S3
Encryption password:
Path to GPG program: /usr/bin/gpg	--6. 输入gpg路径

When using secure HTTPS protocol all communication with Amazon S3
servers is protected from 3rd party eavesdropping. This method is
slower than plain HTTP, and can only be proxied with Python 2.7 or newer
Use HTTPS protocol [Yes]: No	--7. 是否使用https

On some networks all internet access must go through a HTTP proxy.
Try setting it here if you can't connect to S3 directly
HTTP Proxy server name:		--8. 是否有http proxy服务名称

New settings:
  Access Key: U5XEBIOGLYHXY4N544GB
  Secret Key: nWPoq8gAtpsxhEeKcxOGBK1uFv9rqm4Si7vT9ey9
  Default Region: US
  S3 Endpoint: 192.168.13.31:9900
  DNS-style bucket+hostname:port template for accessing a bucket: 192.168.13.31:9900/%(bucket)
  Encryption password:
  Path to GPG program: /usr/bin/gpg
  Use HTTPS protocol: False
  HTTP Proxy server name:
  HTTP Proxy server port: 0

Test access with supplied credentials? [Y/n] Y	--9. 是否进行测试
Please wait, attempting to list all buckets...
Success. Your access key and secret key worked fine :-)

Now verifying that encryption works...
Not configured. Never mind.

Save settings? [y/N] y	--10. 是否保存，在上一步测试失败，则不会跳出这一步
Configuration saved to '/root/.s3cfg'
注：结果是创建了/root/.s3cfg文件，如果你很熟悉，可以直接改这个配置文件

--创建bucket
root@ansible:~/ansible# s3cmd mb s3://mybucket









</pre>














<pre>
#常用命令
ceph osd pool ls
ceph osd pool rm mypool --yes-i-really-really-mean-it --yes-i-really-really-mean-it
ceph pg ls-by-pool mypool | awk '{print $1,$2,$15}'
ceph osd tree
sudo rados put testfil1 /usr/local/src/consul_1.10.3_linux_amd64.zip --pool=mypool 
rados ls --pool=mypool
ceph osd map mypool testfil1

#RBD
ceph osd pool create myrbd1 64 64 #创建存储池
ceph osd pool application enable myrbd1 rbd   #对存储池启用 RBD 功能
rbd pool init -p myrbd1 #通过 RBD 命令对存储池初始化
rbd create myimg1 --size 5G --pool myrbd1 
rbd create myimg2 --size 3G --pool myrbd1 --image-format 2 --image-feature layering
rbd ls --pool myrbd1	#列出指定的pool中所有的img
rbd --image myimg1 --pool myrbd1 info	#查看指定 rdb 的信息

ceph df
rados df
rbd --user jack -p rbd-data1 map data-img1 
rbd feature disable myrbd1/myimg1 object-map fast-diff deep-flatten  #关闭img1特性
rbd -p myrbd1 map myimg1

#cephfs
ceph osd pool create cephfs-metadata 32 32
ceph osd pool create cephfs-data 64 64
ceph fs new mycephfs cephfs-metadata cephfs-data 
$ ceph mds stat
mycephfs:1 {0=ceph-mgr01=up:active}
$ ceph fs status mycephfs


ceph osd lspools
ceph pg stat		--查看PG状态，不太准，有Jemter进行压测
ceph osd stat		--查看osd状态
ceph osd tree    --可以查看哪个osd故障
ceph mon stat   --查看mon状态，最少3个保持高可用

#更改存储池pg和pgp大小
ceph config set global osd_pool_default_pg_autoscale_mode off	--设置默认pg自动伸缩模式
ceph osd pool autoscale-status
ceph osd pool get mypool pg_autoscale_mode
ceph osd pool set mypool pg_autoscale_mode off
ceph osd pool set mypool pg_num 4
ceph osd pool set mypool pgp_num 4

#查看ceph配置
$ ceph config get mon
WHO     MASK  LEVEL     OPTION                                 VALUE  RO
mon           advanced  auth_allow_insecure_global_id_reclaim  false
global        advanced  osd_pool_default_pg_autoscale_mode     off




	

</pre>





	




























