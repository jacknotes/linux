#lvm
<pre>
centos7添加一块新硬盘，可使用命令让电脑无需重启即可读取硬盘：
[root@salt-server /sys/class/scsi_host]# echo "- - -" > /sys/class/scsi_host/host0/scan
[root@salt-server /sys/class/scsi_host]# echo "- - -" > /sys/class/scsi_host/host1/scan
[root@salt-server /sys/class/scsi_host]# echo "- - -" > /sys/class/scsi_host/host2/scan
扫描SCSI总线添加设备，有多少条SCSI总线就扫描多少次，脚本如下：
---------------
#!/usr/bin/bash

scsisum=`ll /sys/class/scsi_host/host*|wc -l`

for ((i=0;i<${scsisum};i++))
do
    echo "- - -" > /sys/class/scsi_host/host${i}/scan
done
-------------------

1.新建分区并更改分区类型为lvm
2.新建物理卷（physical volume）
[root@salt-server /sys/class/scsi_host]# pvcreate /dev/sdb{1,2}
  Physical volume "/dev/sdb1" successfully created.
  Physical volume "/dev/sdb2" successfully created.
3.详细查看新建的物理卷（pvs也可简要查看）
[root@salt-server /sys/class/scsi_host]# pvdisplay
  "/dev/sdb2" is a new physical volume of "30.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb2
  VG Name
  PV Size               30.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               4NprMw-yzO8-9UUc-rxrD-IhPi-toUj-qRA5qy

  "/dev/sdb1" is a new physical volume of "30.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb1
  VG Name
  PV Size               30.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               uQnOMJ-zjnx-5JiB-V7bB-WycM-wfZj-dmoEr7

4.新建卷组（volume group）:用于把物理卷组成一个组
[root@salt-server /sys/class/scsi_host]# vgcreate -s 16M myvg /dev/sdb{1,2}
  Volume group "myvg" successfully created
5.详细查看卷组：
[root@salt-server /sys/class/scsi_host]# vgdisplay
  --- Volume group ---
  VG Name               myvg
  System ID
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               <59.97 GiB
  PE Size               16.00 MiB
  Total PE              3838
  Alloc PE / Size       0 / 0
  Free  PE / Size       3838 / <59.97 GiB
  VG UUID               SuxdA7-l9lO-oO8n-QinG-ogil-fxzL-8dlJPP

6.新建逻辑卷（logical volume）:类似新加的硬盘一样
[root@salt-server /sys/class/scsi_host]# lvcreate -L 50G -n mylv myvg
  Logical volume "mylv" created.
7.详细查看逻辑卷：
[root@salt-server /sys/class/scsi_host]# lvdisplay
  --- Logical volume ---
  LV Path                /dev/myvg/mylv
  LV Name                mylv
  VG Name                myvg
  LV UUID                963Eh1-FWn9-8HfI-7Zou-NwOd-LyEF-pdkJHg
  LV Write Access        read/write
  LV Creation host, time salt-server, 2019-01-10 16:28:09 +0800
  LV Status              available
  # open                 0
  LV Size                50.00 GiB
  Current LE             3200
  Segments               2
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:0
8.查看新添加的逻辑卷
[root@salt-server /sys/class/scsi_host]# fdisk -l

Disk /dev/sda: 107.4 GB, 107374182400 bytes, 209715200 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000af649

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048     2099199     1048576   83  Linux
/dev/sda2         2099200   209715199   103808000   83  Linux

Disk /dev/sdb: 107.4 GB, 107374182400 bytes, 209715200 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0xa6d30b18

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1            2048    62916607    31457280   8e  Linux LVM
/dev/sdb2        62916608   125831167    31457280   8e  Linux LVM

Disk /dev/mapper/myvg-mylv: 53.7 GB, 53687091200 bytes, 104857600 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
注：/dev/mapper/myvg-mylv为新添加的逻辑卷

9.格式化逻辑卷：
[root@salt-server /sys/class/scsi_host]# mkfs.ext4 /dev/mapper/myvg-mylv
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
3276800 inodes, 13107200 blocks
655360 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=2162163712
400 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
        4096000, 7962624, 11239424

Allocating group tables: done
Writing inode tables: done
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done

10.挂载逻辑卷：
[root@salt-server /sys/class/scsi_host]# mount /dev/mapper/myvg-mylv /lvm

11.增加逻辑卷容量：(lvresize -l +179 /dev/myvg/mylv也行)
[root@salt-server ~]# lvextend -L +5G /dev/myvg/mylv
  Size of logical volume myvg/mylv changed from 50.00 GiB (3200 extents) to 55.00 GiB (3520 extents).
  Logical volume myvg/mylv successfully resized.

12.写入文件系统，使扩容生效
[root@salt-server ~]# resize2fs /dev/myvg/mylv
resize2fs 1.42.9 (28-Dec-2013)
Filesystem at /dev/myvg/mylv is mounted on /lvm; on-line resizing required
old_desc_blocks = 7, new_desc_blocks = 7
The filesystem on /dev/myvg/mylv is now 14417920 blocks long.

13.另外一种方式增加逻辑容量：(lvresize -l +179 /dev/myvg/mylv也行)
[root@salt-server ~]# lvextend -l +100%FREE /dev/myvg/mylv
  Size of logical volume myvg/mylv changed from 55.00 GiB (3520 extents) to <59.97 GiB (3838 extents).
  Logical volume myvg/mylv successfully resized.

[root@salt-server ~]# resize2fs /dev/myvg/mylv
resize2fs 1.42.9 (28-Dec-2013)
Filesystem at /dev/myvg/mylv is mounted on /lvm; on-line resizing required
old_desc_blocks = 7, new_desc_blocks = 8
The filesystem on /dev/myvg/mylv is now 15720448 blocks long.

[root@salt-server ~]# df -h
Filesystem             Size  Used Avail Use% Mounted on
/dev/sda2               99G  2.0G   97G   3% /
devtmpfs               1.9G     0  1.9G   0% /dev
tmpfs                  1.9G   28K  1.9G   1% /dev/shm
tmpfs                  1.9G  120M  1.8G   7% /run
tmpfs                  1.9G     0  1.9G   0% /sys/fs/cgroup
/dev/sda1             1014M  140M  875M  14% /boot
/dev/mapper/myvg-mylv   59G   52M   56G   1% /lvm
tmpfs                  380M     0  380M   0% /run/user/0

新增硬盘扩容：
14.对新增硬盘进行分一个区，并指定类型为8e
15.新建物理卷：
[root@salt-server /sys/class/scsi_host]# pvcreate /dev/sdc1
  Physical volume "/dev/sdc1" successfully created.
16.扩展卷组容量：
[root@salt-server /sys/class/scsi_host]# vgextend myvg /dev/sdc1
  Volume group "myvg" successfully extended
17.扩展逻辑卷容量：
[root@salt-server /sys/class/scsi_host]# lvextend -l +100%FREE /dev/myvg/mylv
  Size of logical volume myvg/mylv changed from <59.97 GiB (3838 extents) to 109.95 GiB (7037 extents).
  Logical volume myvg/mylv successfully resized.
18.写入文件系统：
[root@salt-server /sys/class/scsi_host]# resize2fs  /dev/myvg/mylv
19.对比查看：
[root@salt-server /sys/class/scsi_host]# df -h
Filesystem             Size  Used Avail Use% Mounted on
/dev/sda2               99G  2.0G   97G   3% /
devtmpfs               1.9G     0  1.9G   0% /dev
tmpfs                  1.9G   28K  1.9G   1% /dev/shm
tmpfs                  1.9G  120M  1.8G   7% /run
tmpfs                  1.9G     0  1.9G   0% /sys/fs/cgroup
/dev/sda1             1014M  140M  875M  14% /boot
/dev/mapper/myvg-mylv  148G   60M  141G   1% /lvm
tmpfs                  380M     0  380M   0% /run/user/0

[root@salt-server /sys/class/scsi_host]# fdisk -l

Disk /dev/sda: 107.4 GB, 107374182400 bytes, 209715200 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000af649

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048     2099199     1048576   83  Linux
/dev/sda2         2099200   209715199   103808000   83  Linux

Disk /dev/sdb: 107.4 GB, 107374182400 bytes, 209715200 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0xa6d30b18

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1            2048    62916607    31457280   8e  Linux LVM
/dev/sdb2        62916608   125831167    31457280   8e  Linux LVM
/dev/sdb3       125831168   209715199    41942016   8e  Linux LVM

Disk /dev/mapper/myvg-mylv: 161.0 GB, 160994164736 bytes, 314441728 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdc: 53.7 GB, 53687091200 bytes, 104857600 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0xb3b4092e

   Device Boot      Start         End      Blocks   Id  System
/dev/sdc1            2048   104857599    52427776   8e  Linux LVM

注意：sdb和sdc两个实际容量为100G和50G，我这里是虚拟机所以读取有误差，LVM只持在线扩展，不支持在线压缩

#压缩容量：
1.[root@salt-server /]# umount /lvm/
2.[root@salt-server /]# resize2fs /dev/myvg/mylv 30000M
resize2fs 1.42.9 (28-Dec-2013)
Please run 'e2fsck -f /dev/myvg/mylv' first.
3.[root@salt-server /]# e2fsck -f /dev/myvg/mylv
e2fsck 1.42.9 (28-Dec-2013)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
/dev/myvg/mylv: 13/6553600 files (0.0% non-contiguous), 459546/26198016 blocks
4.[root@salt-server /]#  resize2fs /dev/myvg/mylv 30000M
resize2fs 1.42.9 (28-Dec-2013)
Resizing the filesystem on /dev/myvg/mylv to 7680000 (4k) blocks.
The filesystem on /dev/myvg/mylv is now 7680000 blocks long.
5.[root@salt-server /]# mount /dev/myvg/mylv /lvm/
6.[root@salt-server /]# df -h
Filesystem             Size  Used Avail Use% Mounted on
/dev/sda2               99G  2.0G   97G   3% /
devtmpfs               1.9G     0  1.9G   0% /dev
tmpfs                  1.9G   28K  1.9G   1% /dev/shm
tmpfs                  1.9G  120M  1.8G   7% /run
tmpfs                  1.9G     0  1.9G   0% /sys/fs/cgroup
/dev/sda1             1014M  140M  875M  14% /boot
tmpfs                  380M     0  380M   0% /run/user/0
/dev/mapper/myvg-mylv   29G   45M   28G   1% /lvm
7.[root@salt-server /]# lvresize -L -70G /dev/myvg/mylv
  WARNING: Reducing active and open logical volume to <29.94 GiB.
  THIS MAY DESTROY YOUR DATA (filesystem etc.)
Do you really want to reduce myvg/mylv? [y/n]: y
  Size of logical volume myvg/mylv changed from <99.94 GiB (6396 extents) to <29.94 GiB (1916 extents).
  Logical volume myvg/mylv successfully resized.
8.[root@salt-server /lvm]# vgdisplay
  --- Volume group ---
  VG Name               myvg
  System ID
  Format                lvm2
  Metadata Areas        4
  Metadata Sequence No  11
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               1
  Max PV                0
  Cur PV                4
  Act PV                4
  VG Size               <149.94 GiB
  PE Size               16.00 MiB
  Total PE              9596
  Alloc PE / Size       5116 / <79.94 GiB
  Free  PE / Size       4480 / 70.00 GiB
  VG UUID               SuxdA7-l9lO-oO8n-QinG-ogil-fxzL-8dlJPP

</pre>


#iscsi
<pre>
#服务端（target）：
1. [root@salt-server ~]# yum install targetd targetcli -y
2. [root@salt-server ~]# systemctl start target
3. [root@salt-server ~]# systemctl enable target
4. 配置防火墙，放行3260端口
5. 执行targetcli工具：[root@salt-server ~]# targetcli
6. 输入help进行查看帮助：/> help
7. 基本思路：先把准备共享的块做出来，创建一个target，在target上创建lun，一个lun连接一个块
8. /> ls
o- / ............................................................................................................. [...]
  o- backstores .................................................................................................. [...]
  | o- block ...................................................................................... [Storage Objects: 0]
  | o- fileio ..................................................................................... [Storage Objects: 0]
  | o- pscsi ...................................................................................... [Storage Objects: 0]
  | o- ramdisk .................................................................................... [Storage Objects: 0]
  o- iscsi ................................................................................................ [Targets: 0]
  o- loopback .....
9. /> /backstores/block create salt.disk2 /dev/myvg/mylv2
Created block storage object salt.disk2 using /dev/myvg/mylv2.
/> /backstores/block/ create salt.disk3 /dev/myvg/mylv3
Created block storage object salt.disk3 using /dev/myvg/mylv3.
注：给/dev/myvg/mylv2逻辑卷起个名字叫salt.disk2;给/dev/myvg/mylv3逻辑卷起个名字叫salt.disk3
10. 创建 iqn 名字即创建ISCSI对象
11. /> /iscsi create iqn.2019-01.com.jack:disk2
Created target iqn.2019-01.com.jack:disk2.
Created TPG 1.
Global pref auto_add_default_portal=true
Created default portal listening on all IPs (0.0.0.0), port 3260.
12. /> /iscsi create iqn.2019-01.com.jack:disk3
Created target iqn.2019-01.com.jack:disk3.
Created TPG 1.
Global pref auto_add_default_portal=true
Created default portal listening on all IPs (0.0.0.0), port 3260.
13. 设置ACL即将ISCSI对象与客户端IP或主机名绑定
14. /> /iscsi/iqn.2019-01.com.jack:disk2/tpg1/acls create iqn.2019-01.com.jack:client2
Created Node ACL for iqn.2019-01.com.jack:client2
/> /iscsi/iqn.2019-01.com.jack:disk3/tpg1/acls create iqn.2019-01.com.jack:client3
Created Node ACL for iqn.2019-01.com.jack:client3
15. 注意：iqn.2019-01.com.jack:client2是 initiator 的名字，需要在客户端中设置的。
16. 创建LUN并绑定块
17. /> /iscsi/iqn.2019-01.com.jack:disk2/tpg1/luns create /backstores/block/salt.disk2
Created LUN 0.
Created LUN 0->0 mapping in node ACL iqn.2019-01.com.jack:client2
/> /iscsi/iqn.2019-01.com.jack:disk3/tpg1/luns create /backstores/block/salt.disk3
Created LUN 0.
Created LUN 0->0 mapping in node ACL iqn.2019-01.com.jack:client3
18. 一个ISCSI对象可以创建多个LUN（LUN0、LUN1……）。执行ls查看
19. /> ls
o- / ............................................................................................................. [...]
  o- backstores .................................................................................................. [...]
  | o- block ...................................................................................... [Storage Objects: 2]
  | | o- salt.disk2 ................................................... [/dev/myvg/mylv2 (50.0GiB) write-thru activated]
  | | | o- alua ....................................................................................... [ALUA Groups: 1]
  | | |   o- default_tg_pt_gp ........................................................... [ALUA state: Active/optimized]
  | | o- salt.disk3 ................................................... [/dev/myvg/mylv3 (70.0GiB) write-thru activated]
  | |   o- alua ....................................................................................... [ALUA Groups: 1]
  | |     o- default_tg_pt_gp ........................................................... [ALUA state: Active/optimized]
  | o- fileio ..................................................................................... [Storage Objects: 0]
  | o- pscsi ...................................................................................... [Storage Objects: 0]
  | o- ramdisk .................................................................................... [Storage Objects: 0]
  o- iscsi ................................................................................................ [Targets: 2]
  | o- iqn.2019-01.com.jack:disk2 ............................................................................ [TPGs: 1]
  | | o- tpg1 ................................................................................... [no-gen-acls, no-auth]
  | |   o- acls .............................................................................................. [ACLs: 1]
  | |   | o- iqn.2019-01.com.jack:client2 ............................................................. [Mapped LUNs: 1]
  | |   |   o- mapped_lun0 ................................................................ [lun0 block/salt.disk2 (rw)]
  | |   o- luns .............................................................................................. [LUNs: 1]
  | |   | o- lun0 .............................................. [block/salt.disk2 (/dev/myvg/mylv2) (default_tg_pt_gp)]
  | |   o- portals ........................................................................................ [Portals: 1]
  | |     o- 0.0.0.0:3260 ......................................................................................... [OK]
  | o- iqn.2019-01.com.jack:disk3 ............................................................................ [TPGs: 1]
  |   o- tpg1 ................................................................................... [no-gen-acls, no-auth]
  |     o- acls .............................................................................................. [ACLs: 1]
  |     | o- iqn.2019-01.com.jack:client3 ............................................................. [Mapped LUNs: 1]
  |     |   o- mapped_lun0 ................................................................ [lun0 block/salt.disk3 (rw)]
  |     o- luns .............................................................................................. [LUNs: 1]
  |     | o- lun0 .............................................. [block/salt.disk3 (/dev/myvg/mylv3) (default_tg_pt_gp)]
  |     o- portals ........................................................................................ [Portals: 1]
  |       o- 0.0.0.0:3260 ......................................................................................... [OK]
  o- loopback .........................................
20. 启动监听程序
21. /> /iscsi/iqn.2019-01.com.jack:disk3/tpg1/portals/ create 192.168.1.235 ip_port=3260
Created network portal 192.168.1.235:3206.
/> /iscsi/iqn.2019-01.com.jack:disk2/tpg1/portals/ create 192.168.1.235 ip_port=3260
Created network portal 192.168.1.235:3206.
22. 注：192.168.1.235是ISCSI服务端网卡IP
23. 可以查看/etc/target/saveconfig.json配置文件，该配置文件保存着ISCSI的配置。/> exit
Global pref auto_save_on_exit=true
Configuration saved to /etc/target/saveconfig.json

#客户端(initiator端)
1. [root@salt-server ~]# yum install -y iscsi-initiator-utils
2. [root@salt-server ~]# cat /etc/iscsi/initiatorname.iscsi
InitiatorName=iqn.2019-01.com.jack:client2
3. [root@salt-server ~]# systemctl start iscsi
4. [root@salt-server ~]# systemctl enable iscsi
5. 发现存储：
[root@salt-server ~]# iscsiadm -m discovery -t st -p 192.168.1.235
192.168.1.235:3260,1 iqn.2019-01.com.jack:disk3
192.168.1.235:3206,1 iqn.2019-01.com.jack:disk3
192.168.1.235:3260,1 iqn.2019-01.com.jack:disk2
192.168.1.235:3206,1 iqn.2019-01.com.jack:disk2
7. 登录存储：
[root@salt-server ~]# iscsiadm -m node -T iqn.2019-01.com.jack:disk2 -p 192.168.1.235 -l
Logging in to [iface: default, target: iqn.2019-01.com.jack:disk2, portal: 192.168.1.235,3260] (multiple)
Login to [iface: default, target: iqn.2019-01.com.jack:disk2, portal: 192.168.1.235,3260] successful.
8. 查看scsi:
[root@salt-server ~]# lsscsi
[0:0:0:0]    disk    VMware   Virtual disk     1.0   /dev/sda
[0:0:1:0]    disk    VMware   Virtual disk     1.0   /dev/sdb
[0:0:2:0]    disk    VMware   Virtual disk     1.0   /dev/sdc
[2:0:0:0]    cd/dvd  NECVMWar VMware IDE CDR10 1.00  /dev/sr0
[3:0:0:0]    disk    LIO-ORG  salt.disk2       4.0   /dev/sdd
9. 跟本地磁盘一样，不需要格式化，直接挂载：[root@salt-server ~]# mount /dev/sdd /d
10. 查看挂载情况：
[root@salt-server /]# df -h
Filesystem             Size  Used Avail Use% Mounted on
/dev/sda2               99G  2.1G   97G   3% /
devtmpfs               1.9G     0  1.9G   0% /dev
tmpfs                  1.9G   28K  1.9G   1% /dev/shm
tmpfs                  1.9G  128M  1.8G   7% /run
tmpfs                  1.9G     0  1.9G   0% /sys/fs/cgroup
/dev/sda1             1014M  140M  875M  14% /boot
/dev/mapper/myvg-mylv   29G   45M   28G   1% /lvm
tmpfs                  380M     0  380M   0% /run/user/0
/dev/sdd                50G   53M   47G   1% /d
[root@salt-server /]# iscsiadm -m node -p 192.168.1.235 -u
--断开连接iscsi
注：-l表示连接ISCSI目标；-u表示断开和ISCSI目标的连接，isaci不支持多连接

#####parted工具
[root@lamp-zabbix ~]# parted  #进入parted模式
GNU Parted 3.1
Using /dev/sda
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted) select /dev/sdb  #选择磁盘                                               
Using /dev/sdb
(parted) mklabel  #创建磁盘标签                                                        
New disk label type?  #tab tab可查看帮助                                                    
aix    amiga  bsd    dvh    gpt    loop   mac    msdos  pc98   sun    
New disk label type? gpt #选择类型为gpt
(parted) p   #打印显示/dev/sdb                                                             
Model: VMware Virtual disk (scsi)
Disk /dev/sdb: 107GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 

Number  Start  End  Size  File system  Name  Flags
(parted) mkpart  #创建分区
Partition name?  []? gpt1 #设定分区名
File system type?  [ext2]?                                                
affs0            affs6            amufs3           btrfs            hfs              linux-swap(new)  reiserfs
affs1            affs7            amufs4           ext2             hfs+             linux-swap(old)  sun-ufs
affs2            amufs            amufs5           ext3             hfsx             linux-swap(v0)   swsusp
affs3            amufs0           apfs1            ext4             hp-ufs           linux-swap(v1)   xfs
affs4            amufs1           apfs2            fat16            jfs              nilfs2           
affs5            amufs2           asfs             fat32            linux-swap       ntfs             
File system type?  [ext2]? xfs #设定分区文件系统类型
Start? 1 #设定分区大小起始位置
End? 20GB  #设定分区大小结束位置                                                             
(parted) p                                                                
Model: VMware Virtual disk (scsi)
Disk /dev/sdb: 107GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size    File system  Name  Flags
 1      1049kB  20.0GB  20.0GB               gpt1
(parted) mkpart                                                           
Partition name?  []? gpt2
File system type?  [ext2]? xfs                                            
Start? 22G                                                                
End? 40G
(parted) p                                                                
Model: VMware Virtual disk (scsi)
Disk /dev/sdb: 107GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size    File system  Name  Flags
 1      1049kB  20.0GB  20.0GB               gpt1
 2      22.0GB  40.0GB  18.0GB               gpt2

(parted) rm 2  #删除分区                                                             
(parted) p                                                                
Model: VMware Virtual disk (scsi)
Disk /dev/sdb: 107GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size    File system  Name  Flags
 1      1049kB  20.0GB  20.0GB               gpt1
(parted) mkpart                                                           
Partition name?  []? part2                                                
File system type?  [ext2]?                                                
Start? 10G                                                                
End? 30G                                                                  
(parted) p                                                                
Model: VMware Virtual disk (scsi)
Disk /dev/sdb: 107GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size    File system  Name   Flags
 1      1049kB  10.0GB  9999MB               part1
 2      10.0GB  30.0GB  20.0GB               part2

(parted) mkpart 
Partition name?  []? part3         #创建了3个分区                                       
File system type?  [ext2]? ext4                                           
Start? 30G                                                                
End? 50G                                                                  
(parted) p                                                                
Model: VMware Virtual disk (scsi)
Disk /dev/sdb: 107GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size    File system  Name   Flags
 1      1049kB  10.0GB  9999MB               part1
 2      10.0GB  30.0GB  20.0GB               part2
 3      30.0GB  50.0GB  20.0GB               part3

(parted) quit                                                             
Information: You may need to update /etc/fstab.
[root@lamp-zabbix ~]# ls /dev/sdb
sdb   sdb1  sdb2  sdb3   #系统立马识别新建分区
[root@lamp-zabbix ~]# mkfs.ext4 /dev/sdb1 #格式化磁盘
[root@lamp-zabbix ~]# mkfs.ext4 /dev/sdb2
[root@lamp-zabbix ~]# mkfs.ext4 /dev/sdb3
(parted) p                                                                
Model: VMware Virtual disk (scsi)
Disk /dev/sdb: 107GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size    File system  Name   Flags
 1      1049kB  10.0GB  9999MB  ext4         part1
 2      10.0GB  30.0GB  20.0GB  ext4         part2
 3      30.0GB  50.0GB  20.0GB  ext4         part3
#分区的删除和恢复
[root@lamp-zabbix ~]# mount /dev/sdb2 /mnt #挂载/dev/sdb2
[root@lamp-zabbix mnt]# touch 111
[root@lamp-zabbix mnt]# echo hello > 111
[root@lamp-zabbix mnt]# cat 111 
hello
[root@lamp-zabbix ~]# umount /mnt
[root@lamp-zabbix ~]# parted /dev/sdb
(parted) p  
Model: VMware Virtual disk (scsi)
Disk /dev/sdb: 107GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size    File system  Name   Flags
 1      1049kB  10.0GB  9999MB  ext4         part1
 2      10.0GB  30.0GB  20.0GB  ext4         part2
 3      30.0GB  50.0GB  20.0GB  ext4         part3
(parted) rm 2                                                             
(parted) p                                                                
Model: VMware Virtual disk (scsi)
Disk /dev/sdb: 107GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size    File system  Name   Flags
 1      1049kB  10.0GB  9999MB  ext4         part1
 3      30.0GB  50.0GB  20.0GB  ext4         part3   #已经把part2删除了，此时只要不把part2的分区进行格式化数据就还在
(parted) rescue     #恢复磁盘                                                       
Start? 10G  #起始大小必须跟part2起始大小一致                                                               
End? 30G   #结束大小必须跟part2结束大小一致
searching for file systems... 42%       (time left 00:01)Information: A ext4 primary partition was found at 10.0GB -> 30.0GB.  Do you want to add it to the partition table?  #搜索文件系统：已经找到一个ext4的主分区，你想添加到分区表吗？
Yes/No/Cancel? yes                                                        
(parted) p                                                                
Model: VMware Virtual disk (scsi)
Disk /dev/sdb: 107GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size    File system  Name   Flags
 1      1049kB  10.0GB  9999MB  ext4         part1
 2      10.0GB  30.0GB  20.0GB  ext4
 3      30.0GB  50.0GB  20.0GB  ext4         part3
[root@lamp-zabbix ~]# mount /dev/sdb2 /mnt
[root@lamp-zabbix ~]# ls /mnt/  #数据还在
111  lost+found


###Linux下multipath多路径配置
多路径的主要功能就是和存储设备一起配合实现如下功能：
1.故障的切换和恢复
2.IO流量的负载均衡
3.磁盘的虚拟化
注：由于多路径软件是需要和存储在一起配合使用的，不同的厂商基于不同的操作系统，都提供了不同的版本。并且有的厂商，软件和硬件也不是一起卖的，如果要使用 多路径软件的话，可能还需要向厂商购买license才行。比如EMC公司基于linux下的多路径软件，就需要单独的购买license。好在， RedHat和Suse的2.6的内核中都自带了免费的多路径软件包，并且可以免费使用，同时也是一个比较通用的包，可以支持大多数存储厂商的设备，即使 是一些不是出名的厂商，通过对配置文件进行稍作修改，也是可以支持并运行的很好的。

##查看是否安装了device-mapper包
[root@lamp-zabbix ~]# rpm -qa | grep device-mapper
device-mapper-event-libs-1.02.149-8.el7.x86_64
device-mapper-persistent-data-0.7.3-3.el7.x86_64
device-mapper-1.02.149-8.el7.x86_64
device-mapper-multipath-0.4.9-123.el7.x86_64
device-mapper-event-1.02.149-8.el7.x86_64
device-mapper-multipath-libs-0.4.9-123.el7.x86_64
device-mapper-libs-1.02.149-8.el7.x86_64
1. device-mapper-multipath：即multipath-tools。主要提供multipathd和multipath等工具和 multipath.conf等配置文件。这些工具通过device mapper的ioctr的接口创建和配置multipath设备（调用device-mapper的用户空间库。创建的多路径设备会在/dev/mapper中）。
2. device-mapper：主要包括两大部分：内核部分和用户部分。内核部分主要由device mapper核心（dm.ko）和一些target driver（md-multipath.ko）。核心完成设备的映射，而target根据映射关系和自身特点具体处理从mappered device 下来的i/o。同时，在核心部分，提供了一个接口，用户通过ioctr可和内核部分通信，以指导内核驱动的行为，比如如何创建mappered device，这些divece的属性等。linux device mapper的用户空间部分主要包括device-mapper这个包。其中包括dmsetup工具和一些帮助创建和配置mappered device的库。这些库主要抽象，封装了与ioctr通信的接口，以便方便创建和配置mappered device。multipath-tool的程序中就需要调用这些库。
3. dm-multipath.ko和dm.ko：dm.ko是device mapper驱动。它是实现multipath的基础。dm-multipath其实是dm的一个target驱动.
4. scsi_id：包含在udev程序包中，可以在multipath.conf中配置该程序来获取scsi设备的序号。通过序号，便可以判断多个路径 对应了同一设备。这个是多路径实现的关键。scsi_id是通过sg驱动，向设备发送EVPD page80或page83 的inquery命令来查询scsi设备的标识。但一些设备并不支持EVPD 的inquery命令，所以他们无法被用来生成multipath设备。但可以改写scsi_id，为不能提供scsi设备标识的设备虚拟一个标识符，并 输出到标准输出。multipath程序在创建multipath设备时，会调用scsi_id，从其标准输出中获得该设备的scsi id。在改写时，需要修改scsi_id程序的返回值为0。因为在multipath程序中，会检查该直来确定scsi id是否已经成功得到。

##multipath在Redhat中的基本配置过程：
1. 安装和加载多路径软件包
# rpm -ivh device-mapper-1.02.39-1.el5.rpm #安装映射包
# rpm -ivh device-mapper-multipath-0.4.7-34.el5.rpm #安装多路径包
# chkconfig –level 2345 multipathd on #设置成开机自启动multipathd
# lsmod |grep dm_multipath #来检查安装是否正常

#如果模块没有加载成功请使用下列命初始化DM，或重启系统:
[root@lamp-zabbix md]# pwd
#/lib/modules/3.10.0-957.el7.x86_64/kernel/drivers/md  #内核模块路径 
[root@lamp-zabbix multipath]# modprobe dm-multipath  ##最主要是这个模块
[root@lamp-zabbix multipath]# lsmod | grep multipath
dm_multipath           27792  0 
dm_mod                124407  3 dm_multipath,dm_log,dm_mirror
[root@lamp-zabbix multipath]# modprobe dm-round-robin
[root@lamp-zabbix multipath]# lsmod | grep robin
dm_round_robin         12819  0 
dm_multipath           27792  1 dm_round_robin

2. 配置multipath：
#multipath正常工作的最简配置如下：
vi /etc/multipath.conf
blacklist {
	devnode "^sda"   #表示不对sda这块盘进行检测使用
}
defaults {
	user_friendly_names yes
	path_grouping_policy multibus
	failback immediate
	no_path_retry fail
}

#Multipath的高级配置，配置文件是/etc/multipath.conf：
[root@mjdb class]# cat /etc/multipath.conf
blacklist {
    devnode "^sda"
}
defaults {
    user_friendly_names yes
    path_grouping_policy multibus
    failback immediate
    no_path_retry fail
}

multipaths {
        multipath {
                wwid 360060e8012651e005040651e00000000  #此wwid可使得multipath -v3查看到
                alias ssddata
        }
        multipath {
                wwid 360060e8012651e005040651e00000004
                alias hdddata
        }
}
3. multipath基本操作命令：
# /etc/init.d/multipathd start #开启mulitipath服务
# multipath -F #删除现有路径，两个新的路径就会被删除
# multipath -v2 #格式化路径，格式化后又出现
# multipath -ll #查看多路径状态
# multipath -v3 #查看wwid
[root@mjdb class]# multipath -ll
ssddata (360060e8012651e005040651e00000000) dm-2 HITACHI ,OPEN-V
size=2.6T features='0' hwhandler='0' wp=rw
`-+- policy='service-time 0' prio=1 status=active
  |- 16:0:0:0 sdd 8:48 active ready running  #多路径下已经整合了sdd和sdb两块盘
  `- 15:0:0:0 sdb 8:16 active ready running
hdddata (360060e8012651e005040651e00000004) dm-3 HITACHI ,OPEN-V
size=7.3T features='0' hwhandler='0' wp=rw
`-+- policy='service-time 0' prio=1 status=active
  |- 16:0:0:1 sde 8:64 active ready running
  `- 15:0:0:1 sdc 8:32 active ready running
[root@mjdb class]# multipath -v3 | grep uid  #查看wwid
Jul 06 15:29:35 | sdb: uid_attribute = ID_SERIAL (internal default)
Jul 06 15:29:35 | sdb: uid = 360060e8012651e005040651e00000000 (udev)
Jul 06 15:29:35 | sdc: uid_attribute = ID_SERIAL (internal default)
Jul 06 15:29:35 | sdc: uid = 360060e8012651e005040651e00000004 (udev)
Jul 06 15:29:35 | sdd: uid_attribute = ID_SERIAL (internal default)
Jul 06 15:29:35 | sdd: uid = 360060e8012651e005040651e00000000 (udev)
Jul 06 15:29:35 | sde: uid_attribute = ID_SERIAL (internal default)
Jul 06 15:29:35 | sde: uid = 360060e8012651e005040651e00000004 (udev)
uuid                              hcil     dev dev_t pri dm_st chk_st vend/pro

4. 在对多路径软件生成的磁盘进行分区之前最好运行一下pvcreate命令:
# pvcreate /dev/mapper/mpatha
# mkfs.ext4 /dev/mapper/mpatha
然后挂载即可使用

5. 使用iostat工具进行测试多路负载均衡测试
[root@mjdb class]# iostat
Linux 3.10.0-957.10.1.el7.x86_64 (mjdb)         07/06/2019      _x86_64_        (40 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           3.42    0.00    0.46    0.22    0.00   95.90

Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
sda               0.93         8.89        21.04   29883028   70696237
dm-0              0.93         8.72        20.71   29290709   69597817
dm-1              0.12         0.17         0.33     557636    1096352
sdb             238.97     11414.47      1500.67 38353282631 5042344724  #sdb和sdd负载均衡
sdc              18.90       415.94      7865.08 1397569729 26427111993  #sdc和sde负载均衡
sdd             243.28     11580.15      1522.88 38909963105 5116947563
sde              18.97       418.36      7890.97 1405719960 26514122646
dm-2            487.03     22994.62      3023.55 77263239080 10159292535
dm-3             37.80       834.30     15756.05 2803280833 52941234639

------------------------------------------------------------------------------------------
####用iscsi来模块IPSAN实战：
环境介绍：
node1:两个网卡：ip1:192.168.1.31,ip2:192.168.1.232,两块盘
node2:一个网卡：ip：192.168.1.37，一块盘
注：node1模拟服务端，node2模拟客户端 
##node1（target端配置）:
[root@mysql-master ~]# yum install epel-release -y 
[root@mysql-master ~]# ip add show
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:0c:29:ee:3e:65 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.31/24 brd 192.168.1.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:feee:3e65/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:0c:29:ee:3e:6f brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.232/24 brd 192.168.1.255 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:feee:3e6f/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
[root@mysql-master ~]# echo '- - -' > /sys/class/scsi_host/host0/scan  #不重启系统识别新增加硬盘
[root@mysql-master ~]# fdisk -l
Disk /dev/sda: 107.4 GB, 107374182400 bytes, 209715200 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000b0456
   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048     2099199     1048576   83  Linux
/dev/sda2         2099200   209715199   103808000   83  Linux

Disk /dev/sdb: 53.7 GB, 53687091200 bytes, 104857600 sectors #这块为新增加硬盘
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
[root@mysql-master ~]# yum install -y scsi-target-utils #安装服务端iscsi工具
[root@mysql-master ~]# vim /etc/tgt/targets.conf 
default-driver iscsi
<target iqn.2019-07.jack.com:target00>
        backing-store /dev/sdb
        initiator-address 192.168.1.37  #可选，指定客户端的ip
        incominguser jack jack  #可选，设置客户端的帐户和密码
</target>
[root@mysql-master ~]# systemctl enable tgtd.service 
Created symlink from /etc/systemd/system/multi-user.target.wants/tgtd.service to /usr/lib/systemd/system/tgtd.service.
[root@mysql-master ~]# systemctl start tgtd.service 
[root@mysql-master ~]# tgtadm --mode target --op show  #查看服务状态
Target 1: iqn.2019-07.jack.com:target00
    System information:
        Driver: iscsi
        State: ready
    I_T nexus information:
    LUN information:
        LUN: 0
            Type: controller
            SCSI ID: IET     00010000
            SCSI SN: beaf10
            Size: 0 MB, Block size: 1
            Online: Yes
            Removable media: No
            Prevent removal: No
            Readonly: No
            SWP: No
            Thin-provisioning: No
            Backing store type: null
            Backing store path: None
            Backing store flags: 
        LUN: 1
            Type: disk
            SCSI ID: IET     00010001
            SCSI SN: beaf11
            Size: 53687 MB, Block size: 512
            Online: Yes
            Removable media: No
            Prevent removal: No
            Readonly: No
            SWP: No
            Thin-provisioning: No
            Backing store type: rdwr
            Backing store path: /dev/sdb
            Backing store flags: 
    Account information:
        jack
    ACL information:
        192.168.1.37
##node2(initiator端配置)
[root@mysql-slave ~]# yum install -y iscsi-initiator-utils
[root@mysql-slave ~]# vim /etc/iscsi/initiatorname.iscsi
InitiatorName=iqn.2019-07.jack.com:target00  #与服务端设置一样
[root@mysql-slave ~]# vi /etc/iscsi/iscsid.conf  #如果服务端没有设置用户谁，这一步可以不用操作
node.session.auth.authmethod = CHAP
node.session.auth.username = jack
node.session.auth.password = jack
[root@mysql-slave ~]# iscsiadm -m discovery -t st -p 192.168.1.232 #在node2上扫描设备，这个ip是232
192.168.1.232:3260,1 iqn.2019-07.jack.com:target00
[root@mysql-slave ~]# iscsiadm -m discovery -t st -p 192.168.1.31  #在node2上扫描设备，这个ip是31
192.168.1.31:3260,1 iqn.2019-07.jack.com:target00
[root@mysql-slave ~]# iscsiadm -m node -o show  #展示结果
# BEGIN RECORD 6.2.0.874-10
node.name = iqn.2019-07.jack.com:target00
node.tpgt = 1
node.startup = automatic
node.leading_login = No
iface.hwaddress = <empty>
iface.ipaddress = <empty>
iface.iscsi_ifacename = default
iface.net_ifacename = <empty>
iface.gateway = <empty>
iface.subnet_mask = <empty>
iface.transport_name = tcp
iface.initiatorname = <empty>
iface.state = <empty>
iface.vlan_id = 0
iface.vlan_priority = 0
iface.vlan_state = <empty>
iface.iface_num = 0
iface.mtu = 0
iface.port = 0
iface.bootproto = <empty>
iface.dhcp_alt_client_id_state = <empty>
iface.dhcp_alt_client_id = <empty>
iface.dhcp_dns = <empty>
iface.dhcp_learn_iqn = <empty>
iface.dhcp_req_vendor_id_state = <empty>
iface.dhcp_vendor_id_state = <empty>
iface.dhcp_vendor_id = <empty>
iface.dhcp_slp_da = <empty>
iface.fragmentation = <empty>
iface.gratuitous_arp = <empty>
iface.incoming_forwarding = <empty>
iface.tos_state = <empty>
iface.tos = 0
iface.ttl = 0
iface.delayed_ack = <empty>
iface.tcp_nagle = <empty>
iface.tcp_wsf_state = <empty>
iface.tcp_wsf = 0
iface.tcp_timer_scale = 0
iface.tcp_timestamp = <empty>
iface.redirect = <empty>
iface.def_task_mgmt_timeout = 0
iface.header_digest = <empty>
iface.data_digest = <empty>
iface.immediate_data = <empty>
iface.initial_r2t = <empty>
iface.data_seq_inorder = <empty>
iface.data_pdu_inorder = <empty>
iface.erl = 0
iface.max_receive_data_len = 0
iface.first_burst_len = 0
iface.max_outstanding_r2t = 0
iface.max_burst_len = 0
iface.chap_auth = <empty>
iface.bidi_chap = <empty>
iface.strict_login_compliance = <empty>
iface.discovery_auth = <empty>
iface.discovery_logout = <empty>
node.discovery_address = 192.168.1.232
node.discovery_port = 3260
node.discovery_type = send_targets
node.session.initial_cmdsn = 0
node.session.initial_login_retry_max = 8
node.session.xmit_thread_priority = -20
node.session.cmds_max = 128
node.session.queue_depth = 32
node.session.nr_sessions = 1
node.session.auth.authmethod = CHAP
node.session.auth.username = jack
node.session.auth.password = ********
node.session.auth.username_in = <empty>
node.session.auth.password_in = <empty>
node.session.timeo.replacement_timeout = 120
node.session.err_timeo.abort_timeout = 15
node.session.err_timeo.lu_reset_timeout = 30
node.session.err_timeo.tgt_reset_timeout = 30
node.session.err_timeo.host_reset_timeout = 60
node.session.iscsi.FastAbort = Yes
node.session.iscsi.InitialR2T = No
node.session.iscsi.ImmediateData = Yes
node.session.iscsi.FirstBurstLength = 262144
node.session.iscsi.MaxBurstLength = 16776192
node.session.iscsi.DefaultTime2Retain = 0
node.session.iscsi.DefaultTime2Wait = 2
node.session.iscsi.MaxConnections = 1
node.session.iscsi.MaxOutstandingR2T = 1
node.session.iscsi.ERL = 0
node.session.scan = auto
node.conn[0].address = 192.168.1.232
node.conn[0].port = 3260
node.conn[0].startup = manual
node.conn[0].tcp.window_size = 524288
node.conn[0].tcp.type_of_service = 0
node.conn[0].timeo.logout_timeout = 15
node.conn[0].timeo.login_timeout = 15
node.conn[0].timeo.auth_timeout = 45
node.conn[0].timeo.noop_out_interval = 5
node.conn[0].timeo.noop_out_timeout = 5
node.conn[0].iscsi.MaxXmitDataSegmentLength = 0
node.conn[0].iscsi.MaxRecvDataSegmentLength = 262144
node.conn[0].iscsi.HeaderDigest = None
node.conn[0].iscsi.IFMarker = No
node.conn[0].iscsi.OFMarker = No
# END RECORD
# BEGIN RECORD 6.2.0.874-10
node.name = iqn.2019-07.jack.com:target00
node.tpgt = 1
node.startup = automatic
node.leading_login = No
iface.hwaddress = <empty>
iface.ipaddress = <empty>
iface.iscsi_ifacename = default
iface.net_ifacename = <empty>
iface.gateway = <empty>
iface.subnet_mask = <empty>
iface.transport_name = tcp
iface.initiatorname = <empty>
iface.state = <empty>
iface.vlan_id = 0
iface.vlan_priority = 0
iface.vlan_state = <empty>
iface.iface_num = 0
iface.mtu = 0
iface.port = 0
iface.bootproto = <empty>
iface.dhcp_alt_client_id_state = <empty>
iface.dhcp_alt_client_id = <empty>
iface.dhcp_dns = <empty>
iface.dhcp_learn_iqn = <empty>
iface.dhcp_req_vendor_id_state = <empty>
iface.dhcp_vendor_id_state = <empty>
iface.dhcp_vendor_id = <empty>
iface.dhcp_slp_da = <empty>
iface.fragmentation = <empty>
iface.gratuitous_arp = <empty>
iface.incoming_forwarding = <empty>
iface.tos_state = <empty>
iface.tos = 0
iface.ttl = 0
iface.delayed_ack = <empty>
iface.tcp_nagle = <empty>
iface.tcp_wsf_state = <empty>
iface.tcp_wsf = 0
iface.tcp_timer_scale = 0
iface.tcp_timestamp = <empty>
iface.redirect = <empty>
iface.def_task_mgmt_timeout = 0
iface.header_digest = <empty>
iface.data_digest = <empty>
iface.immediate_data = <empty>
iface.initial_r2t = <empty>
iface.data_seq_inorder = <empty>
iface.data_pdu_inorder = <empty>
iface.erl = 0
iface.max_receive_data_len = 0
iface.first_burst_len = 0
iface.max_outstanding_r2t = 0
iface.max_burst_len = 0
iface.chap_auth = <empty>
iface.bidi_chap = <empty>
iface.strict_login_compliance = <empty>
iface.discovery_auth = <empty>
iface.discovery_logout = <empty>
node.discovery_address = 192.168.1.31
node.discovery_port = 3260
node.discovery_type = send_targets
node.session.initial_cmdsn = 0
node.session.initial_login_retry_max = 8
node.session.xmit_thread_priority = -20
node.session.cmds_max = 128
node.session.queue_depth = 32
node.session.nr_sessions = 1
node.session.auth.authmethod = CHAP
node.session.auth.username = jack
node.session.auth.password = ********
node.session.auth.username_in = <empty>
node.session.auth.password_in = <empty>
node.session.timeo.replacement_timeout = 120
node.session.err_timeo.abort_timeout = 15
node.session.err_timeo.lu_reset_timeout = 30
node.session.err_timeo.tgt_reset_timeout = 30
node.session.err_timeo.host_reset_timeout = 60
node.session.iscsi.FastAbort = Yes
node.session.iscsi.InitialR2T = No
node.session.iscsi.ImmediateData = Yes
node.session.iscsi.FirstBurstLength = 262144
node.session.iscsi.MaxBurstLength = 16776192
node.session.iscsi.DefaultTime2Retain = 0
node.session.iscsi.DefaultTime2Wait = 2
node.session.iscsi.MaxConnections = 1
node.session.iscsi.MaxOutstandingR2T = 1
node.session.iscsi.ERL = 0
node.session.scan = auto
node.conn[0].address = 192.168.1.31
node.conn[0].port = 3260
node.conn[0].startup = manual
node.conn[0].tcp.window_size = 524288
node.conn[0].tcp.type_of_service = 0
node.conn[0].timeo.logout_timeout = 15
node.conn[0].timeo.login_timeout = 15
node.conn[0].timeo.auth_timeout = 45
node.conn[0].timeo.noop_out_interval = 5
node.conn[0].timeo.noop_out_timeout = 5
node.conn[0].iscsi.MaxXmitDataSegmentLength = 0
node.conn[0].iscsi.MaxRecvDataSegmentLength = 262144
node.conn[0].iscsi.HeaderDigest = None
node.conn[0].iscsi.IFMarker = No
node.conn[0].iscsi.OFMarker = No
# END RECORD
[root@mysql-slave ~]# iscsiadm -m node --login  #登录认证target，使用/etc/iscsi/iscsid.conf配置文件帐号密码进行认证的
Logging in to [iface: default, target: iqn.2019-07.jack.com:target00, portal: 192.168.1.232,3260] (multiple)
Logging in to [iface: default, target: iqn.2019-07.jack.com:target00, portal: 192.168.1.31,3260] (multiple)
Login to [iface: default, target: iqn.2019-07.jack.com:target00, portal: 192.168.1.232,3260] successful.
Login to [iface: default, target: iqn.2019-07.jack.com:target00, portal: 192.168.1.31,3260] successful.
[root@mysql-slave ~]# iscsiadm -m session -o show  #查看并确认信息
tcp: [1] 192.168.1.232:3260,1 iqn.2019-07.jack.com:target00 (non-flash)
tcp: [2] 192.168.1.31:3260,1 iqn.2019-07.jack.com:target00 (non-flash)
[root@mysql-slave ~]# cat /proc/partitions 
major minor  #blocks  name

   2        0          4 fd0
   8        0  104857600 sda
   8        1    1048576 sda1
   8        2  103808000 sda2
  11        0    1048575 sr0
   8       16   52428800 sdb  #sdb和sdc就是node1的一块共享磁盘，但是有两个网口，所以有两块逻辑磁盘
   8       32   52428800 sdc
[root@mysql-slave ~]# fdisk -l #查看sdb和sdc信息
Disk /dev/sda: 107.4 GB, 107374182400 bytes, 209715200 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000a9992
   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048     2099199     1048576   83  Linux
/dev/sda2         2099200   209715199   103808000   83  Linux

Disk /dev/sdb: 53.7 GB, 53687091200 bytes, 104857600 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

Disk /dev/sdc: 53.7 GB, 53687091200 bytes, 104857600 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

###安装多路径软件
[root@mysql-slave ~]# yum install -y device-mapper-multipath
[root@mysql-slave ~]# systemctl enable multipathd  #设置开机启动
[root@mysql-slave ~]# modprobe dm_multipath  #装载多路径模块
[root@mysql-slave ~]# vim /etc/multipath.conf  #多路径软件配置
blacklist {
    devnode "^sda"
}
defaults {
    user_friendly_names yes
    path_grouping_policy multibus
    failback immediate
    no_path_retry fail
}
[root@mysql-slave ~]# systemctl start multipathd.service  #启动服务，系统会加载内核模块
[root@mysql-slave ~]# lsmod | grep multipath
dm_multipath           27792  2 dm_service_time
dm_mod                124407  5 dm_multipath,dm_log,dm_mirror
[root@mysql-slave ~]# multipath -ll  #查看状态
mpatha (360000000000000000e00000000010001) dm-0 IET     ,VIRTUAL-DISK    
size=50G features='0' hwhandler='0' wp=rw
`-+- policy='service-time 0' prio=1 status=active
  |- 3:0:0:1 sdc 8:32 active ready running
  `- 4:0:0:1 sdb 8:16 active ready running
[root@mysql-slave ~]# lsblk   #可以查看多路径磁盘
NAME     MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
fd0        2:0    1    4K  0 disk  
sda        8:0    0  100G  0 disk  
├─sda1     8:1    0    1G  0 part  /boot
└─sda2     8:2    0   99G  0 part  /
sdb        8:16   0   50G  0 disk  
└─mpatha 253:0    0   50G  0 mpath 
sdc        8:32   0   50G  0 disk  
└─mpatha 253:0    0   50G  0 mpath 
sr0       11:0    1 1024M  0 rom   
[root@mysql-slave ~]# fdisk -l

Disk /dev/sda: 107.4 GB, 107374182400 bytes, 209715200 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000a9992
   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048     2099199     1048576   83  Linux
/dev/sda2         2099200   209715199   103808000   83  Linux

Disk /dev/sdb: 53.7 GB, 53687091200 bytes, 104857600 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

Disk /dev/sdc: 53.7 GB, 53687091200 bytes, 104857600 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

Disk /dev/mapper/mpatha: 53.7 GB, 53687091200 bytes, 104857600 sectors  #多了一个mpatha多路径磁盘
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
[root@mysql-slave ~]# mkfs.xfs /dev/mapper/mpatha #格式化
[root@mysql-slave ~]# mount /dev/mapper/mpatha /mnt/
[root@mysql-slave ~]# cd /mnt/
[root@mysql-slave mnt]# for ((i=1;i<=5;i++));do dd if=/dev/zero of=/mnt/1Gfile bs=8k count=131072 2>&1|grep MB;done;  #进行测试负载均衡效果
1073741824 bytes (1.1 GB) copied, 1.34263 s, 800 MB/s
1073741824 bytes (1.1 GB) copied, 1.29873 s, 827 MB/s
1073741824 bytes (1.1 GB) copied, 2.70738 s, 397 MB/s
1073741824 bytes (1.1 GB) copied, 9.33689 s, 115 MB/s
[root@mysql-slave ~]# iostat 1
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.26    0.00   21.65   24.48    0.00   53.61

Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
fd0               0.00         0.00         0.00          0          0
sda               0.00         0.00         0.00          0          0
sdb             364.00         0.00    186240.00          0     186240  #可以看到sdb和sdc写入速度是差不多的
sdc             386.00         0.00    196228.00          0     196228
dm-0            750.00         0.00    382468.00          0     382468
[root@mysql-master ~]# ip link set eth1 down #测试当node1的一个网口down掉时，node2是否不会断开连接，而达到高可用的作用
[root@mysql-slave mnt]# for ((i=1;i<=5;i++));do dd if=/dev/zero of=/mnt/1Gfile bs=8k count=131072 2>&1|grep MB;done; 
1073741824 bytes (1.1 GB) copied, 1.39296 s, 771 MB/s
[root@mysql-slave ~]# iostat 1
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.77    0.00   36.32   14.58    0.00   48.34

Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
fd0               0.00         0.00         0.00          0          0
sda               0.00         0.00         0.00          0          0
sdb            1122.00         0.00    572932.00          0     572932  #显示sdb还在工作，sdc已经断开了，达到了高可用的作用
sdc               0.00         0.00         0.00          0          0
dm-0           1122.00         0.00    572932.00          0     572932
[root@mysql-slave ~]# multipath -ll
mpatha (360000000000000000e00000000010001) dm-0 IET     ,VIRTUAL-DISK    
size=50G features='0' hwhandler='0' wp=rw
`-+- policy='service-time 0' prio=1 status=active
  |- 3:0:0:1 sdc 8:32 active undef running  #此时sdc状态是undef的
  `- 4:0:0:1 sdb 8:16 active ready running

[root@mysql-master ~]# ip link set eth1 up  #当node1接口up时，测试是否负载均衡
[root@mysql-slave mnt]# for ((i=1;i<=5;i++));do dd if=/dev/zero of=/mnt/1Gfile bs=8k count=131072 2>&1|grep MB;done; 
[root@mysql-slave ~]# iostat 1
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.51    0.00   10.43   35.88    0.00   53.18

Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
fd0               0.00         0.00         0.00          0          0
sda               0.00         0.00         0.00          0          0
sdb             251.00         0.00    128344.00          0     128344  结果显示负载均衡
sdc             242.00         0.00    123560.00          0     123560
dm-0            493.00         0.00    251904.00          0     251904
[root@mysql-slave ~]# multipath -ll
mpatha (360000000000000000e00000000010001) dm-0 IET     ,VIRTUAL-DISK    
size=50G features='0' hwhandler='0' wp=rw
`-+- policy='service-time 0' prio=1 status=active
  |- 3:0:0:1 sdc 8:32 failed faulty running
  `- 4:0:0:1 sdb 8:16 active ready running
[root@mysql-slave ~]# multipath -ll
mpatha (360000000000000000e00000000010001) dm-0 IET     ,VIRTUAL-DISK    
size=50G features='0' hwhandler='0' wp=rw
`-+- policy='service-time 0' prio=1 status=active
  |- 3:0:0:1 sdc 8:32 failed ready running
  `- 4:0:0:1 sdb 8:16 active ready running
[root@mysql-slave ~]# multipath -ll
mpatha (360000000000000000e00000000010001) dm-0 IET     ,VIRTUAL-DISK    
size=50G features='0' hwhandler='0' wp=rw
`-+- policy='service-time 0' prio=1 status=active
  |- 3:0:0:1 sdc 8:32 active ready running   #当接口回归时，sdc从失败状态逐渐走向装备状态
  `- 4:0:0:1 sdb 8:16 active ready running

注：此操作是服务端两个网卡，客户端一个网卡，达到去往服务端的流量有两条路径可走，客户端在总流量不大于本身网卡1000M时效果很好，如果大于本身网卡流量，则效果会差。
注：例如：服务端两个网卡，客户端两个网卡，这个跟上面例子一样，不同点在于客户端也可以达到高可用冗余功能，并且客户端发送的总流量由一个网卡的总容量变成两上个网卡的总容量，大大提升容量

[root@mysql-slave ~]# cat /etc/multipath.conf  #配置还可以加上wwid。从multipath -v3可以看出uid，udev值
blacklist {   #黑名单，会忽略黑名单的设备
    devnode "^sda"   #devnode后跟设备名称的正则表达式；
}
defaults {   #全局属性的默认配置
    user_friendly_names yes   #如为yes，则用/etc/multipath/bindings中的设置命名；如为no，则使用wwid命名（可被multipaths中的设置覆盖），默认值为no。
    path_grouping_policy multibus  #路径分组策略，“multibus”表示所有路径在一个组
    failback immediate  #恢复路径的方法，其中，“Immediate”表示立即恢复到包含活动路径的高优先级路径组
    no_path_retry fail  #禁用队列前系统重试的次数，“fail”表示直接返回错误
}
multipaths{  #multipaths单独配置单条路径，每条路径单独使用multipath子节
        multipath{
                wwid 360000000000000000e00000000010001  #路径WWID(必选)，可用命令/lib/udev/scsi_id -g -u /dev/sdX获取
                alias hdddata  #设备别名
        }
}

------------------------------------------------------------------------------------------
#####multipath的配置参数详解：
---------------------------
1.配置文件结构及位置
multipath配置文件/etc/multipath.conf由节（section），子节（sub-section），属性（atribute）和属性值（value）等组成，其结构具体如下所示：
<section> {
    <attribute> <value>
    ...
    <subsection> {
    <attribute> <value>
    ...
    }
}
配置文件的模板默认位于/usr/share/doc/device-mapper-multipath-X.Y.Z/multipath.conf（X,Y,Z为multipath的实际版本号），配置multipath配置文件时，可以将该文件复制于/etc/multipath.conf，
然后，在进行定制配置。

其中，可用的节关键字如下:
1)defaults:全局属性的默认设置。
2)blacklist:黑名单，multipath会忽略黑名单中的设备。
3)blacklist_exceptions:免除黑名单，加入黑名单内，但包含在这里的设备不会被忽略。
4)multipaths:多路径相关配置。
5)devices:存储设备相关配置。

2.defaults节可用属性
1)polling_interval:路径检查的时间间隔，单位秒(s)。
2)max_polling_interval:路径检查的最大时间间隔，默认为polling_interval的4倍，单位秒(s)。
3)multipath_dir:多路径共享库的路径，具体与系统相关，默认为/lib/multipath或/lib64/multipath。
4)find_multipaths:默认值no，这将为黑名单外的所有设备创建多路径设备。如置为yes，则将为3种场景创建多路径设备：不在黑名单的两个路径的wwid相同；用户手动强制创建；一个路径的wwid与之前已经创建的多路径设备相同。
5)verbosity:信息输出等级，最低为0，最高为6，默认为2。
6)path_selector:路径选择算法，其中，“round-robin 0”表示在多个路径间不断循环；“queue-length 0”表示选择当前处理IO数最少的路径；“service-time 0”表示选择IO服务时间最短的路径。
7)path_grouping_policy:路径分组策略，其中，“failover” 表示一条路径一个组（默认值）；“multibus”表示所有路径在一个组；“group_by_serial”表示根据序列号分组；“group_by_prio”表示根据优先级分组；
  “group_by_node_name”表示根据名字分组。
8)uid_attribute:用udev的哪个属性唯一标识一个设备，默认值为ID_SERIAL。
9)prio:路径优先级获取方法,其中，“const”返回1（默认值）；“emc”为emc盘阵生成优先级；“alua”基于SCSI-3 ALUA配置生成优先级；“ontap”为NetAPP盘阵生成优先级；
  “rdac”为LSI/Engenio/NetApp E-Series RDAC控制器生成优先级；“hp_sw”根据Compaq/HP控制器active/standby模式生成优先级；“hds”为日立HDS模块化阵列生成优先级；
  “random”随机生成优先级，其值在1到10间；“weightedpath”根据正则表达式及prio_args参数值生成优先级。
10)prio_args:计算优先级函数的参数。
11)features:指定使用Device Mapper的特性，其中，“queue_if_no_path”表示没有可用路径时，将请求加入队列；“no_partitions”表示禁止使用kpartx生成分区。
12)path_checker:路径检查方法，其中，“readsector0”表示通过读取设备的第一扇区来决定路径状态，已废弃，用directio替代；“tur”表示运行“TEST UNIT READY”命令来决定路径状态；
   “emc_clariion”表示执行“EMC Clariion specific EVPD page 0xC0”来决定路径的状态；“hp_sw”表示检查惠普Active/Standby盘阵；“rdac”表示检查“LSI/Engenio/NetApp E-Series RDAC”存储控制器的状态；
   “direction”表示用DirectIO读取设备的第一个扇区。
13)failback:恢复路径的方法，其中，“Immediate”表示立即恢复到包含活动路径的高优先级路径组；“manual”表示手动恢复（默认值）；“followover”表示只有路径组的第一条路径可用时才恢复；
   “values>0”表示延迟恢复。
14)rr_min_io:切换到当前路径组中下一条路径前进行的IO数，仅用于2.6.31的核心版本号，默认值为1000。
15)rr_min_io_rq:切换到当前路径组中下一条路径前进行IO数，仅用于2.6.31及以后的核心版本号，默认值为1。
16)no_path_retry:禁用队列前系统重试的次数，“fail”表示直接返回错误，“queue”表示全部加入队列，默认值为0。
17)user_friendly_names:如为yes，则用/etc/multipath/bindings中的设置命名；如为no，则使用wwid命名（可被multipaths中的设置覆盖），默认值为no。
18)max_fds:multipathd和multipath可打开的最大文件描述符数。
19)checker_timeout:路径检查的超时时间，单位秒(s)，默认值为/sys/block/sd<x>/device/timeout值。
20)fast_io_fail_tmo:SCSI IO错误超时，应比dev_loss_tmo小，为off则禁用超时。
21)dev_loss_tmo:SCSI设备移除超时，Linux下的默认为为300，单位秒(s)。
22)queue_without_daemon:如置为no，如multipathd没启动，则禁止所有设备的IO加入队列。
23)bindings_file:设置了user_friendly_names时，名称绑定文件的路径，默认值为/etc/multipath/bindings。
24)wwids_file:wwids跟踪文件路径，默认为/etc/multipath/wwids。
25)log_checker_err:路径检查出错时的日志记录方式，默认为always。
26)reservation_key:为mpathpersist命令指定的key。
27)retain_attached_hw_handler:是否继续使用hardware_handler，默认为no。
28)detect_prio:如置为yes，则首先尝试使用alua检测，默认为no。
29)hw_str_match:如置为yes，则优先使用字符串匹配名称、厂商等信息，默认为no。
30)force_sync:如置为yes，则强制使用同步模式检查路径，默认为no。
31)deferred_remove:如置为yes，则延迟删除没有路径的设备，默认为no。
32)config_dir:指定配置文件的目录，如不为“”，则按照字母排序搜索目录中的*.conf文件，像使用/etc/multipath.conf一样对其进行读取，默认为/etc/multipath/conf.d。
33)delay_watch_checks:如大于0，则只有连续delay_watch_checks检查路径有效时,才认为有效，默认为no。
34)delay_wait_checks: 如大于0，经过delay_watch_check检查有效后，延迟delay_wait_checks次检查后,才正式重新启用，默认为no。
35)missing_uev_msg_delay:   当一个新的设备被创建后，在延迟missing_uev_msg_delay秒后开始接受udev信息，默认值是30。

3.blacklist配置
blacklist内的设备将会被多路径忽略，有三种格式：
1)wwid后跟设备的WWID；
2)devnode后跟设备名称的正则表达式；
3)device设备描述，为一个子节（Subsection），其需包含vendor、product，详细可参考devices节的描述。
blacklist_exceptions语法与blacklist相同，表示取消对blacklist中设备的忽略。

4.multipaths配置
multipaths单独配置单条路径，每条路径单独使用multipath子节，其可包含如下属性：
1)wwid:路径WWID(必选)，可用命令/lib/udev/scsi_id -g -u /dev/sdX获取。
2)alias:设备别名。
3)path_grouping_policy
4)path_selector    
5)prio    
6)prio_args    
7)failback    
8)rr_weight    
9)flush_on_last_del    
10)no_path_retry    
11)rr_min_io    
12)rr_min_io_q    
13)features    
14)reservation_key    
15)deferred_remove    
16)delay_watch_checks    
17)delay_wait_checks    

5.devices配置
devices节中每个device子节用于描述一个设备，其主要属性如下：
1)vendor:生产商(必选)。
2)product:产品型号。
3)revision:版本号。
4)product_blacklist:产品型号黑名单。
5)alias_prefix:设备名称前缀，默认为mapth。
6)hardware_handler:硬件相关操作的型号，主要有：
  "emc":Hardware handler for EMC storage arrays.
  "rdac":Hardware handler for LSI/Engenio/NetApp E-Series RDAC storage controller.
  "hp_sw":Hardware handler for Compaq/HP storage arrays in active/standby mode.
  "alua":Hardware handler for SCSI-3 ALUA compatible arrays.
7)path_grouping_policy    下面的与defaults节说明相同。
8)uid_attribute    
9)path_selector    
10)path_checker    
11)prio    
12)prio_args    
13)features    
14)failback    
15)rr_weight    
16)no_path_retry    
17)rr_min_io    
18)rr_min_io_rq    
19)fast_io_fail_tmo    
20)dev_loss_tmo    
21)flush_on_last_del    
22)retain_attached_hw_handler    
23)detect_prio    
24)deferred_remove    
25)delay_watch_checks    
16)delay_wait_checks    
---------------------------



</pre>
