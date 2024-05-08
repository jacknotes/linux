# Centos7配置软RAID 1
---
准备两块新硬盘，最好是同容量同转速的，新加硬盘必需重新启动系统才能读取：

1. 列出所有磁盘：
[root@linux-node1 ~]# fdisk -l
2. [root@linux-node1 ~]# fdisk /dev/sdb
3. 新建分区/dev/sdb1，并更改ID为fd，按w退出并保存 
4. [root@linux-node1 ~]# fdisk /dev/sdc
5. 新建分区/dev/sdc1，并更改ID为fd，按w退出并保存
6. 使用partprobe /dev/sdb,partprobe /dev/sdc命令让linux内核重新读取硬盘参数
7. 使用mdadm -C /dev/md0 -l 1 -a yes -n 2 /dev/sdb1 /dev/sdc1命令新建一个md0 软RAID
8. mkfs -t ext4 /dev/md0格式化RAID分区
9. mkdir /raid && mount /dev/md0 /raid 新建目录并挂载分区
10. vim /etc/fstab 增加开机启动设备
11. /dev/md0        /raid   ext4    defaults        0 0
12. mount -a 检查开机启动设备文件是否无误




# ubuntu 18.04.5
---

### 插曲：
1. 在制作软RAID之前，安装ubuntu18,04.5安装了两次，第一次安装在500G的 /dev/sda机械硬盘{安装一半中止安装}
2. 第二次安装在240G的 /dev/sdb固态硬盘，最终以固态硬盘为系统盘启动
3. 在系统中查看到/目录下挂载了LV，但是通过lvdisplay查看到有两块盘都挂载在/目录下，但有一个是活动，一个未活动，想删除未活动的，没有命令，最后重启后生效，以下是过程
```
root@ubuntu-18:/etc/apt# pvdisplay
  --- Physical volume ---
  PV Name               /dev/sdb5
  VG Name               ubuntu-18-vg
  PV Size               <222.62 GiB / not usable 2.00 MiB
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              56989
  Free PE               0
  Allocated PE          56989
  PV UUID               idWKzJ-wlWM-W1TV-4dqs-dbac-5K2v-C2kbSW

  --- Physical volume ---
  PV Name               /dev/sda5
  VG Name               ubuntu-18-vg
  PV Size               <464.81 GiB / not usable 0
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              118990
  Free PE               0
  Allocated PE          118990
  PV UUID               r0apGr-033N-9Eo2-r6he-rlIy-fepN-hmXdBF

root@ubuntu-18:/etc/apt# vgdisplay
  --- Volume group ---
  VG Name               ubuntu-18-vg
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  2
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               1
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               222.61 GiB
  PE Size               4.00 MiB
  Total PE              56989
  Alloc PE / Size       56989 / 222.61 GiB
  Free  PE / Size       0 / 0
  VG UUID               jC6Pgy-fjgQ-yP8m-ZSGI-XGrb-VN7W-JF1CHR

  --- Volume group ---
  VG Name               ubuntu-18-vg
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  2
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               464.80 GiB
  PE Size               4.00 MiB
  Total PE              118990
  Alloc PE / Size       118990 / 464.80 GiB
  Free  PE / Size       0 / 0
  VG UUID               A9eqdH-5erA-oSje-eg4I-PJu0-Y6XP-SJhfSj

root@ubuntu-18:/etc/apt# lvdisplay
  --- Logical volume ---
  LV Path                /dev/ubuntu-18-vg/root
  LV Name                root
  VG Name                ubuntu-18-vg
  LV UUID                hQdPeT-9evX-ncOs-xoId-w1Az-XMsA-JXAbWE
  LV Write Access        read/write
  LV Creation host, time ubuntu-18, 2022-11-24 21:58:25 +0800
  LV Status              available
  # open                 1
  LV Size                222.61 GiB
  Current LE             56989
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0

  --- Logical volume ---
  LV Path                /dev/ubuntu-18-vg/root
  LV Name                root
  VG Name                ubuntu-18-vg
  LV UUID                ifOmAN-zW2N-KrIp-zZDH-R5ST-7RIQ-HTn97u
  LV Write Access        read/write
  LV Creation host, time ubuntu-18, 2022-11-24 21:50:11 +0800
  LV Status              NOT available		#未活动，想删除掉
  LV Size                464.80 GiB
  Current LE             118990
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto

root@ubuntu-18:/etc/apt# df -TH
Filesystem                      Type      Size  Used Avail Use% Mounted on
udev                            devtmpfs  4.2G     0  4.2G   0% /dev
tmpfs                           tmpfs     827M  914k  826M   1% /run
/dev/mapper/ubuntu--18--vg-root xfs       239G  4.3G  235G   2% /		#实际只挂载了ssd硬盘
tmpfs                           tmpfs     4.2G     0  4.2G   0% /dev/shm
tmpfs                           tmpfs     5.3M     0  5.3M   0% /run/lock
tmpfs                           tmpfs     4.2G     0  4.2G   0% /sys/fs/cgroup
/dev/sdb1                       ext4      991M   64M  859M   7% /boot
tmpfs                           tmpfs     827M     0  827M   0% /run/user/0

root@ubuntu-18:/etc/apt# mkfs --type xfs -f /dev/sda	#格式化sda硬盘
root@ubuntu-18:/etc/apt# mkfs --type xfs -f /dev/sdc	#格式化sda硬盘
root@ubuntu-18:/etc/apt# lvdisplay
  --- Logical volume ---
  LV Path                /dev/ubuntu-18-vg/root
  LV Name                root
  VG Name                ubuntu-18-vg
  LV UUID                hQdPeT-9evX-ncOs-xoId-w1Az-XMsA-JXAbWE
  LV Write Access        read/write
  LV Creation host, time ubuntu-18, 2022-11-24 21:58:25 +0800
  LV Status              available
  # open                 1
  LV Size                222.61 GiB
  Current LE             56989
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0

  WARNING: Device for PV r0apGr-033N-9Eo2-r6he-rlIy-fepN-hmXdBF not found or rejected by a filter.	#提示/dev/sda这个PV是没有用的
  --- Logical volume ---
  LV Path                /dev/ubuntu-18-vg/root
  LV Name                root
  VG Name                ubuntu-18-vg
  LV UUID                ifOmAN-zW2N-KrIp-zZDH-R5ST-7RIQ-HTn97u
  LV Write Access        read/write
  LV Creation host, time ubuntu-18, 2022-11-24 21:50:11 +0800
  LV Status              NOT available
  LV Size                464.80 GiB
  Current LE             118990
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto

注：最后重启后生效，系统自动会清除没有用的lv,vg,pv
```


### 制作软RAID 1
```
# 安装软raid工具 
root@office:~# apt install -y mdadm

# 列出所有块设备
root@office:~# lsblk
NAME                    MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda                       8:0    0 465.8G  0 disk
sdb                       8:16   0 223.6G  0 disk
|-sdb1                    8:17   0   976M  0 part /boot
|-sdb2                    8:18   0     1K  0 part
`-sdb5                    8:21   0 222.6G  0 part
  `-ubuntu--18--vg-root 253:0    0 222.6G  0 lvm  /
sdc                       8:32   0 465.8G  0 disk

# sudo mdadm --create --verbose /dev/md1 --level=1 --raid-devices=2 /dev/sda /dev/sdc		#software raid 1
# sudo mdadm --create --verbose /dev/md5 --level=5 --raid-devices=3 /dev/sda /dev/sdc /dev/sdd		#software raid 5
# sudo mdadm --create --verbose /dev/md6 --level=6 --raid-devices=4 /dev/sda /dev/sdc /dev/sdd /dev/sde	#software raid 6
# 创建软raid1
root@office:~# sudo mdadm --create --verbose /dev/md0 --level=1 --raid-devices=2 /dev/sda /dev/sdc	
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
mdadm: size set to 488254464K
mdadm: automatically enabling write-intent bitmap on large array
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.

# 查看软raid信息
root@office:~# cat /proc/mdstat
Personalities : [raid1]
md0 : active raid1 sdc[1] sda[0]
      488254464 blocks super 1.2 [2/2] [UU]
      [>....................]  resync =  0.1% (653120/488254464) finish=62.2min speed=130624K/sec	#同步0.1%
      bitmap: 4/4 pages [16KB], 65536KB chunk

unused devices: <none>
root@office:~# cat /proc/mdstat
Personalities : [raid1]
md0 : active raid1 sdc[1] sda[0]
      488254464 blocks super 1.2 [2/2] [UU]
      [>....................]  resync =  3.0% (15125888/488254464) finish=59.5min speed=132494K/sec	#同步3%
      bitmap: 4/4 pages [16KB], 65536KB chunk

unused devices: <none>

# 查看所有块设备信息
root@office:~# fdisk -l
Disk /dev/sda: 465.8 GiB, 500107862016 bytes, 976773168 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdb: 223.6 GiB, 240057409536 bytes, 468862128 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xcb1878ad

Device     Boot   Start       End   Sectors   Size Id Type
/dev/sdb1  *       2048   2000895   1998848   976M 83 Linux
/dev/sdb2       2002942 468860927 466857986 222.6G  5 Extended
/dev/sdb5       2002944 468860927 466857984 222.6G 8e Linux LVM


Disk /dev/sdc: 465.8 GiB, 500107862016 bytes, 976773168 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/ubuntu--18--vg-root: 222.6 GiB, 239029190656 bytes, 466853888 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/md0: 465.7 GiB, 499972571136 bytes, 976508928 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
---

# 格式化块设备为xfs文件系统 
root@office:~# mkfs --type xfs -f /dev/md0
meta-data=/dev/md0               isize=512    agcount=4, agsize=30515904 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=0, rmapbt=0, reflink=0
data     =                       bsize=4096   blocks=122063616, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=59601, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0

# 挂载存储目录
root@office:~# mkdir -p /data
root@office:~# mount /dev/md0 /data/
root@office:~# df -TH
Filesystem                      Type      Size  Used Avail Use% Mounted on
udev                            devtmpfs  4.2G     0  4.2G   0% /dev
tmpfs                           tmpfs     827M  898k  826M   1% /run
/dev/mapper/ubuntu--18--vg-root xfs       239G  4.3G  235G   2% /
tmpfs                           tmpfs     4.2G     0  4.2G   0% /dev/shm
tmpfs                           tmpfs     5.3M     0  5.3M   0% /run/lock
tmpfs                           tmpfs     4.2G     0  4.2G   0% /sys/fs/cgroup
/dev/sdb1                       ext4      991M   65M  859M   7% /boot
tmpfs                           tmpfs     827M     0  827M   0% /run/user/0
/dev/md0                        xfs       500G  532M  500G   1% /data


# 保存数组布局
为了确保在引导时自动重新组装阵列，我们将不得不调整/etc/mdadm/mdadm.conf文件。您可以通过键入以下内容自动扫描活动数组并附加文件：
root@office:~# sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
ARRAY /dev/md0 metadata=1.2 name=office.hs.com:0 UUID=8c669a34:60d603ea:2ac3604a:2b191b74
root@office:~# cat /etc/mdadm/mdadm.conf
HOMEHOST <system>
MAILADDR root
ARRAY /dev/md0 metadata=1.2 name=office.hs.com:0 UUID=8c669a34:60d603ea:2ac3604a:2b191b74

# 更新initramfs或初始RAM文件系统，以便在早期启动过程中阵列可用：
root@office:~# sudo update-initramfs -u
update-initramfs: Generating /boot/initrd.img-4.15.0-112-generic

----------
# 如果启动系统后，原来的名称/dev/md1变成/dev/md127了，可如下操作：
mdadm --assemble /dev/md1 --name=1 --update-name /dev/sda1 /dev/sdb1
# 如果原来的名称/dev/md2变成/dev/md127了，可如下操作：
mdadm --assemble /dev/md2 --name=2 --update-name /dev/sda1 /dev/sdb1
# 最后运行
sudo update-initramfs -u
----------

# 将新的文件系统挂载选项添加到/etc/fstab文件中以便在引导时自动挂载：
root@office:~# echo '/dev/md0 /data xfs defaults 0 0' | sudo tee -a /etc/fstab
/dev/md0 /data xfs defaults 0 0

# 测试是否自动开机挂载
root@office:~# umount  /data
root@office:~# mount -a
root@office:~# df -TH
Filesystem                      Type      Size  Used Avail Use% Mounted on
udev                            devtmpfs  4.2G     0  4.2G   0% /dev
tmpfs                           tmpfs     827M  898k  826M   1% /run
/dev/mapper/ubuntu--18--vg-root xfs       239G  4.3G  235G   2% /
tmpfs                           tmpfs     4.2G     0  4.2G   0% /dev/shm
tmpfs                           tmpfs     5.3M     0  5.3M   0% /run/lock
tmpfs                           tmpfs     4.2G     0  4.2G   0% /sys/fs/cgroup
/dev/sdb1                       ext4      991M   65M  859M   7% /boot
tmpfs                           tmpfs     827M     0  827M   0% /run/user/0
/dev/md0                        xfs       500G  532M  500G   1% /data

# 重启查看是否正常
root@office:~# cat /proc/mdstat
Personalities : [raid1]
md0 : active raid1 sdc[1] sda[0]
      488254464 blocks super 1.2 [2/2] [UU]
      [======>..............]  resync = 31.3% (152994432/488254464) finish=48.2min speed=115736K/sec
      bitmap: 3/4 pages [12KB], 65536KB chunk

unused devices: <none>
root@office:~# reboot	
# 重启后状态，如预期正常
root@office:~# df -TH
Filesystem                      Type      Size  Used Avail Use% Mounted on
udev                            devtmpfs  4.2G     0  4.2G   0% /dev
tmpfs                           tmpfs     827M  914k  826M   1% /run
/dev/mapper/ubuntu--18--vg-root xfs       239G  4.3G  235G   2% /
tmpfs                           tmpfs     4.2G     0  4.2G   0% /dev/shm
tmpfs                           tmpfs     5.3M     0  5.3M   0% /run/lock
tmpfs                           tmpfs     4.2G     0  4.2G   0% /sys/fs/cgroup
/dev/sdb1                       ext4      991M   65M  859M   7% /boot
/dev/md0                        xfs       500G  532M  500G   1% /data
tmpfs                           tmpfs     827M     0  827M   0% /run/user/0
root@office:~# cat /proc/mdstat		
Personalities : [raid1] [linear] [multipath] [raid0] [raid6] [raid5] [raid4] [raid10]
md0 : active raid1 sda[0] sdc[1]
      488254464 blocks super 1.2 [2/2] [UU]
      [======>..............]  resync = 32.0% (156609536/488254464) finish=47.3min speed=116771K/sec
      bitmap: 3/4 pages [12KB], 65536KB chunk

unused devices: <none>
---

# 同步完成状态
root@office:~# cat /proc/mdstat
Personalities : [raid1] [linear] [multipath] [raid0] [raid6] [raid5] [raid4] [raid10]
md0 : active raid1 sda[0] sdc[1]
      488254464 blocks super 1.2 [2/2] [UU]
      bitmap: 0/4 pages [0KB], 65536KB chunk

unused devices: <none>


```

### 创建LVM on 软RAID
```
# 在软RAID之上创建LVM分区
root@office:~# fdisk -l /dev/md0
Disk /dev/md0: 465.7 GiB, 499972571136 bytes, 976508928 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x3637f591

Device     Boot Start       End   Sectors   Size Id Type
/dev/md0p1       2048 976508927 976506880 465.7G 8e Linux LVM

# 创建PV
root@office:~# pvcreate /dev/md0p1
  Physical volume "/dev/md0p1" successfully created.
root@office:~# pvdisplay
  --- Physical volume ---
  PV Name               /dev/md0p1
  VG Name               data
  PV Size               465.63 GiB / not usable 2.00 MiB
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              119202
  Free PE               119202
  Allocated PE          0
  PV UUID               bN1emA-z0g0-uwoR-gm4X-Hj3h-jIEY-siJeL4

  --- Physical volume ---
  PV Name               /dev/sdb5
  VG Name               ubuntu-18-vg
  PV Size               <222.62 GiB / not usable 2.00 MiB
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              56989
  Free PE               0
  Allocated PE          56989
  PV UUID               idWKzJ-wlWM-W1TV-4dqs-dbac-5K2v-C2kbSW

# 创建VG
root@office:~# vgcreate data /dev/md0p1
  Volume group "data" successfully created
root@office:~# vgdisplay
  --- Volume group ---
  VG Name               data
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               465.63 GiB
  PE Size               4.00 MiB
  Total PE              119202
  Alloc PE / Size       0 / 0
  Free  PE / Size       119202 / 465.63 GiB
  VG UUID               53eZFT-NBTs-n7ZE-YqPH-P9r5-vFZU-A0pX66

  --- Volume group ---
  VG Name               ubuntu-18-vg
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  2
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               1
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               222.61 GiB
  PE Size               4.00 MiB
  Total PE              56989
  Alloc PE / Size       56989 / 222.61 GiB
  Free  PE / Size       0 / 0
  VG UUID               jC6Pgy-fjgQ-yP8m-ZSGI-XGrb-VN7W-JF1CHR


# 创建LV
root@office:~# lvcreate -l 100%FREE -n data-lv data
  Logical volume "data-lv" created.
root@office:~# lvdisplay
  --- Logical volume ---
  LV Path                /dev/data/data-lv
  LV Name                data-lv
  VG Name                data
  LV UUID                8sWufC-pYOZ-URbg-pZyb-07O4-BBGc-GMgdB8
  LV Write Access        read/write
  LV Creation host, time office.hs.com, 2022-11-24 17:28:01 +0800
  LV Status              available
  # open                 0
  LV Size                465.63 GiB
  Current LE             119202
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:1

  --- Logical volume ---
  LV Path                /dev/ubuntu-18-vg/root
  LV Name                root
  VG Name                ubuntu-18-vg
  LV UUID                hQdPeT-9evX-ncOs-xoId-w1Az-XMsA-JXAbWE
  LV Write Access        read/write
  LV Creation host, time ubuntu-18, 2022-11-24 21:58:25 +0800
  LV Status              available
  # open                 1
  LV Size                222.61 GiB
  Current LE             56989
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0

注：如果扩展大小，需要执行：xfs_growfs /dev/vg1/lv1增加文件系统的容量


# 格式化LV为xfs文件系统 
root@office:~# mkfs -t xfs /dev/data/data-lv
meta-data=/dev/data/data-lv      isize=512    agcount=4, agsize=30515712 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=0, rmapbt=0, reflink=0
data     =                       bsize=4096   blocks=122062848, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=59601, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0

root@office:~# fdisk -l /dev/data/data-lv
Disk /dev/data/data-lv: 465.6 GiB, 499969425408 bytes, 976502784 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


# 挂载存储目录
root@office:~# mount /dev/data/data-lv /data/
root@office:~# cat /etc/fstab
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
/dev/mapper/ubuntu--18--vg-root /               xfs     defaults        0       0
# /boot was on /dev/sda1 during installation
UUID=d9974eb6-44d5-4ba2-a1d6-e0ae846aea5c /boot           ext4    defaults        0       2
/swapfile                                 none            swap    sw              0       0
/dev/data/data-lv /data xfs defaults 0 0
---
root@office:~# df -TH
Filesystem                      Type      Size  Used Avail Use% Mounted on
udev                            devtmpfs  4.2G     0  4.2G   0% /dev
tmpfs                           tmpfs     827M  926k  826M   1% /run
/dev/mapper/ubuntu--18--vg-root xfs       239G  4.3G  235G   2% /
tmpfs                           tmpfs     4.2G     0  4.2G   0% /dev/shm
tmpfs                           tmpfs     5.3M     0  5.3M   0% /run/lock
tmpfs                           tmpfs     4.2G     0  4.2G   0% /sys/fs/cgroup
/dev/sdb1                       ext4      991M   65M  859M   7% /boot
tmpfs                           tmpfs     827M     0  827M   0% /run/user/0
/dev/mapper/data-data--lv       xfs       500G  532M  500G   1% /data
root@office:~# umount  /data
root@office:~# mount -a
droot@office:~# df -TH
Filesystem                      Type      Size  Used Avail Use% Mounted on
udev                            devtmpfs  4.2G     0  4.2G   0% /dev
tmpfs                           tmpfs     827M  926k  826M   1% /run
/dev/mapper/ubuntu--18--vg-root xfs       239G  4.3G  235G   2% /
tmpfs                           tmpfs     4.2G     0  4.2G   0% /dev/shm
tmpfs                           tmpfs     5.3M     0  5.3M   0% /run/lock
tmpfs                           tmpfs     4.2G     0  4.2G   0% /sys/fs/cgroup
/dev/sdb1                       ext4      991M   65M  859M   7% /boot
tmpfs                           tmpfs     827M     0  827M   0% /run/user/0
/dev/mapper/data-data--lv       xfs       500G  532M  500G   1% /data



```




# 软RAID

**datetime: 20240508**
**OS: CentOS7**



## 1. 创建软RAID1

```bash
# 创建分区/dev/sda1, /dev/sdb1
[root@testhoteles ~]# lsblk
NAME            MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda               8:0    0 465.8G  0 disk
└─sda1            8:1    0 465.8G  0 part
sdb               8:16   0 465.8G  0 disk
└─sdb1            8:17   0 465.8G  0 part
sdc               8:32   0 223.6G  0 disk
├─sdc1            8:33   0   500M  0 part /boot
└─sdc2            8:34   0 223.1G  0 part
  ├─centos-root 253:0    0    50G  0 lvm  /
  ├─centos-swap 253:1    0   7.8G  0 lvm  [SWAP]
  └─centos-home 253:2    0 165.2G  0 lvm  /home


# 创建软RAID1
[root@testhoteles ~]# mdadm --create --verbose /dev/md1 --level=1 --raid-devices=2 /dev/sda1 /dev/sdb1
mdadm: partition table exists on /dev/sda1
mdadm: partition table exists on /dev/sda1 but will be lost or
       meaningless after creating array
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
mdadm: partition table exists on /dev/sdb1
mdadm: partition table exists on /dev/sdb1 but will be lost or
       meaningless after creating array
mdadm: size set to 488253440K
mdadm: automatically enabling write-intent bitmap on large array
Continue creating array? y			# 确认
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md1 started.


# 查看软RAID详细信息
[root@testhoteles ~]# mdadm -D /dev/md1
/dev/md1:
           Version : 1.2
     Creation Time : Wed May  8 06:11:58 2024
        Raid Level : raid1
        Array Size : 488253440 (465.63 GiB 499.97 GB)
     Used Dev Size : 488253440 (465.63 GiB 499.97 GB)
      Raid Devices : 2
     Total Devices : 2
       Persistence : Superblock is persistent

     Intent Bitmap : Internal

       Update Time : Wed May  8 06:12:43 2024
             State : clean, resyncing
    Active Devices : 2
   Working Devices : 2
    Failed Devices : 0
     Spare Devices : 0

Consistency Policy : bitmap

     Resync Status : 1% complete

              Name : testhoteles.hs.com:1  (local to host testhoteles.hs.com)
              UUID : 611ac412:b50551be:6cf89141:7d2d4580
            Events : 9

    Number   Major   Minor   RaidDevice State
       0       8        1        0      active sync   /dev/sda1
       1       8       17        1      active sync   /dev/sdb1
	   
# 查看已经组装（激活）的阵列状态
[root@testhoteles ~]# cat /proc/mdstat
Personalities : [raid1]
md1 : active raid1 sdb1[1] sda1[0]
      488253440 blocks super 1.2 [2/2] [UU]
      [>....................]  resync =  1.8% (9164160/488253440) finish=66.3min speed=120344K/sec
      bitmap: 4/4 pages [16KB], 65536KB chunk

unused devices: <none>

# 查看陈列配置
[root@testhoteles ~]# mdadm -Q /dev/md1
/dev/md1: 465.63GiB raid1 2 devices, 0 spares. Use mdadm --detail for more detail.

[root@testhoteles ~]# lsblk
NAME            MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
sda               8:0    0 465.8G  0 disk
└─sda1            8:1    0 465.8G  0 part
  └─md1           9:1    0 465.7G  0 raid1
sdb               8:16   0 465.8G  0 disk
└─sdb1            8:17   0 465.8G  0 part
  └─md1           9:1    0 465.7G  0 raid1
sdc               8:32   0 223.6G  0 disk
├─sdc1            8:33   0   500M  0 part  /boot
└─sdc2            8:34   0 223.1G  0 part
  ├─centos-root 253:0    0    50G  0 lvm   /
  ├─centos-swap 253:1    0   7.8G  0 lvm   [SWAP]
  └─centos-home 253:2    0 165.2G  0 lvm   /home

# 查看阵列构成配置(转储超级块内容)
[root@testhoteles ~]# mdadm --query --examine /dev/sda1
/dev/sda1:
          Magic : a92b4efc
        Version : 1.2
    Feature Map : 0x1
     Array UUID : 611ac412:b50551be:6cf89141:7d2d4580
           Name : testhoteles.hs.com:1  (local to host testhoteles.hs.com)
  Creation Time : Wed May  8 06:11:58 2024
     Raid Level : raid1
   Raid Devices : 2

 Avail Dev Size : 976506928 sectors (465.63 GiB 499.97 GB)
     Array Size : 488253440 KiB (465.63 GiB 499.97 GB)
  Used Dev Size : 976506880 sectors (465.63 GiB 499.97 GB)
    Data Offset : 264192 sectors
   Super Offset : 8 sectors
   Unused Space : before=264112 sectors, after=48 sectors
          State : active
    Device UUID : 88720bbd:f63659bd:f432717e:8440d35c

Internal Bitmap : 8 sectors from superblock
    Update Time : Wed May  8 06:33:01 2024
  Bad Block Log : 512 entries available at offset 16 sectors
       Checksum : 7c6f3018 - correct
         Events : 225


   Device Role : Active device 0
   Array State : AA ('A' == active, '.' == missing, 'R' == replacing)
   
# 同步完成状态
[root@testhoteles ~]# mdadm -D /dev/md1
/dev/md1:
           Version : 1.2
     Creation Time : Wed May  8 06:11:58 2024
        Raid Level : raid1
        Array Size : 488253440 (465.63 GiB 499.97 GB)
     Used Dev Size : 488253440 (465.63 GiB 499.97 GB)
      Raid Devices : 2
     Total Devices : 2
       Persistence : Superblock is persistent

     Intent Bitmap : Internal

       Update Time : Wed May  8 15:35:00 2024
             State : clean			# 这里没有resyncing状态了，表示干净状态
    Active Devices : 2
   Working Devices : 2
    Failed Devices : 0
     Spare Devices : 0

Consistency Policy : bitmap

              Name : testhoteles.hs.com:1  (local to host testhoteles.hs.com)
              UUID : 611ac412:b50551be:6cf89141:7d2d4580
            Events : 1127

    Number   Major   Minor   RaidDevice State
       0       8        1        0      active sync   /dev/sda1
       1       8       17        1      active sync   /dev/sdb1

```



## 2. raid停止和重组装 

```bash
[root@testhoteles ~]# lsblk
NAME            MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
sda               8:0    0 465.8G  0 disk
└─sda1            8:1    0 465.8G  0 part
  └─md1           9:1    0 465.7G  0 raid1
sdb               8:16   0 465.8G  0 disk
└─sdb1            8:17   0 465.8G  0 part
  └─md1           9:1    0 465.7G  0 raid1
sdc               8:32   0 223.6G  0 disk
├─sdc1            8:33   0   500M  0 part  /boot
└─sdc2            8:34   0 223.1G  0 part
  ├─centos-root 253:0    0    50G  0 lvm   /
  ├─centos-swap 253:1    0   7.8G  0 lvm   [SWAP]
  └─centos-home 253:2    0 165.2G  0 lvm   /home

# 停止软RAID
[root@testhoteles ~]# mdadm --stop /dev/md1
mdadm: stopped /dev/md1

# 查看块
[root@testhoteles ~]# lsblk
NAME            MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda               8:0    0 465.8G  0 disk
└─sda1            8:1    0 465.8G  0 part
sdb               8:16   0 465.8G  0 disk
└─sdb1            8:17   0 465.8G  0 part
sdc               8:32   0 223.6G  0 disk
├─sdc1            8:33   0   500M  0 part /boot
└─sdc2            8:34   0 223.1G  0 part
  ├─centos-root 253:0    0    50G  0 lvm  /
  ├─centos-swap 253:1    0   7.8G  0 lvm  [SWAP]
  └─centos-home 253:2    0 165.2G  0 lvm  /home


# 重新装载陈列
# mdadm --assemble --scan  # 自动组装所有阵列
[root@testhoteles ~]# mdadm --assemble /dev/md1 /dev/sda1 /dev/sdb1 --force
mdadm: /dev/md1 has been started with 2 drives.

[root@testhoteles ~]# 
mdadm: /dev/md/1 has been started with 2 drives.

[root@testhoteles ~]# mdadm -D /dev/md1
/dev/md1:
           Version : 1.2
     Creation Time : Wed May  8 06:11:58 2024
        Raid Level : raid1
        Array Size : 488253440 (465.63 GiB 499.97 GB)
     Used Dev Size : 488253440 (465.63 GiB 499.97 GB)
      Raid Devices : 2
     Total Devices : 2
       Persistence : Superblock is persistent

     Intent Bitmap : Internal

       Update Time : Wed May  8 06:28:39 2024
             State : clean, resyncing
    Active Devices : 2
   Working Devices : 2
    Failed Devices : 0
     Spare Devices : 0

Consistency Policy : bitmap

     Resync Status : 20% complete

              Name : testhoteles.hs.com:1  (local to host testhoteles.hs.com)
              UUID : 611ac412:b50551be:6cf89141:7d2d4580
            Events : 172

    Number   Major   Minor   RaidDevice State
       0       8        1        0      active sync   /dev/sda1
       1       8       17        1      active sync   /dev/sdb1
```




## 3. 保存已有的陈列配置

```bash
[root@testhoteles ~]# mdadm --detail --scan > /etc/mdadm.conf
[root@testhoteles ~]# cat /etc/mdadm.conf
ARRAY /dev/md1 metadata=1.2 name=testhoteles.hs.com:1 UUID=611ac412:b50551be:6cf89141:7d2d4580
```



## 4. 挂载并开机启动

```bash
[root@testhoteles ~]# mkfs -t xfs /dev/md1
[root@testhoteles ~]# mkdir /data
[root@testhoteles ~]# cat /etc/fstab | grep /data
/dev/md1        /data   xfs     defaults        0 0
[root@testhoteles ~]# mount -a
[root@testhoteles ~]# df -TH | grep /data
/dev/md1                xfs       500G   34M  500G    1% /data

# CentOS7更新initramfs，避免raid名称变成md127，在对raid有更新的情况下，都需要更新一下initramfs的，以保证在启动时能正确的找到raid信息
[root@testhoteles ~]# dracut --mdadmconf --fstab --add="mdraid" --filesystems "xfs ext4 ext3" --add-drivers="raid1" --force /boot/initramfs-$(uname -r).img $(uname -r) -M
```



## 5. 模拟软RAID故障和修复

```bash
# 手动停掉一个设备(当设备显示磨损迹象时，例如通过SMART)
[root@testhoteles ~]# mdadm --manage /dev/md1 --fail /dev/sda1
mdadm: set /dev/sda1 faulty in /dev/md1
[root@testhoteles ~]# mdadm -D /dev/md1
/dev/md1:
           Version : 1.2
     Creation Time : Wed May  8 06:11:58 2024
        Raid Level : raid1
        Array Size : 488253440 (465.63 GiB 499.97 GB)
     Used Dev Size : 488253440 (465.63 GiB 499.97 GB)
      Raid Devices : 2
     Total Devices : 2
       Persistence : Superblock is persistent

     Intent Bitmap : Internal

       Update Time : Wed May  8 15:39:18 2024
             State : clean, degraded
    Active Devices : 1
   Working Devices : 1
    Failed Devices : 1
     Spare Devices : 0

Consistency Policy : bitmap

              Name : testhoteles.hs.com:1  (local to host testhoteles.hs.com)
              UUID : 611ac412:b50551be:6cf89141:7d2d4580
            Events : 1129

    Number   Major   Minor   RaidDevice State
       -       0        0        0      removed
       1       8       17        1      active sync   /dev/sdb1

       0       8        1        -      faulty   /dev/sda1# 此时/dev/sda1是故障的，不影响使用
[root@testhoteles ~]# df -TH | grep /data
/dev/md1                xfs       500G   35M  500G    1% /data

# 移除一个错误的组员设备(在设备故障后，应提前更换设备)
[root@testhoteles ~]# mdadm --manage /dev/md1 --remove /dev/sda1
mdadm: hot removed /dev/sda1 from /dev/md1
[root@testhoteles ~]# mdadm -D /dev/md1
/dev/md1:
           Version : 1.2
     Creation Time : Wed May  8 06:11:58 2024
        Raid Level : raid1
        Array Size : 488253440 (465.63 GiB 499.97 GB)
     Used Dev Size : 488253440 (465.63 GiB 499.97 GB)
      Raid Devices : 2
     Total Devices : 1
       Persistence : Superblock is persistent

     Intent Bitmap : Internal

       Update Time : Wed May  8 15:41:10 2024
             State : clean, degraded
    Active Devices : 1
   Working Devices : 1
    Failed Devices : 0
     Spare Devices : 0

Consistency Policy : bitmap

              Name : testhoteles.hs.com:1  (local to host testhoteles.hs.com)
              UUID : 611ac412:b50551be:6cf89141:7d2d4580
            Events : 1134

    Number   Major   Minor   RaidDevice State
       -       0        0        0      removed		# 已经移除
       1       8       17        1      active sync   /dev/sdb1

# 添加一个成员到现有阵列，这将开始重建修复，因为硬盘超级块信息未清除，而且是/dev/md1原来的成员磁盘，所以加入进来后不需要同步 或者 及少数同步就可使用
[root@testhoteles ~]# mdadm /dev/md1 --add /dev/sda1
mdadm: re-added /dev/sda1
[root@testhoteles ~]# mdadm -D /dev/md1
/dev/md1:
           Version : 1.2
     Creation Time : Wed May  8 06:11:58 2024
        Raid Level : raid1
        Array Size : 488253440 (465.63 GiB 499.97 GB)
     Used Dev Size : 488253440 (465.63 GiB 499.97 GB)
      Raid Devices : 2
     Total Devices : 2
       Persistence : Superblock is persistent

     Intent Bitmap : Internal

       Update Time : Wed May  8 15:42:06 2024
             State : clean	# 状态是健康的
    Active Devices : 2
   Working Devices : 2
    Failed Devices : 0
     Spare Devices : 0

Consistency Policy : bitmap

              Name : testhoteles.hs.com:1  (local to host testhoteles.hs.com)
              UUID : 611ac412:b50551be:6cf89141:7d2d4580
            Events : 1158

    Number   Major   Minor   RaidDevice State
       0       8        1        0      active sync   /dev/sda1
       1       8       17        1      active sync   /dev/sdb1

# 当有数据写入时，状态为active 
[root@testhoteles ~]# mdadm -D /dev/md1 
/dev/md1:
           Version : 1.2
     Creation Time : Wed May  8 06:11:58 2024
        Raid Level : raid1
        Array Size : 488253440 (465.63 GiB 499.97 GB)
     Used Dev Size : 488253440 (465.63 GiB 499.97 GB)
      Raid Devices : 2
     Total Devices : 2
       Persistence : Superblock is persistent

     Intent Bitmap : Internal

       Update Time : Wed May  8 12:25:06 2024
             State : active 
    Active Devices : 2
   Working Devices : 2
    Failed Devices : 0
     Spare Devices : 0

Consistency Policy : bitmap

              Name : testhoteles.hs.com:1  (local to host testhoteles.hs.com)
              UUID : 611ac412:b50551be:6cf89141:7d2d4580
            Events : 2291

    Number   Major   Minor   RaidDevice State
       2       8        1        0      active sync   /dev/sda1
       1       8       17        1      active sync   /dev/sdb1
```



## 6. 扩容软RAID，RAID0和RAID5可以

```bash
mdadm /dev/md5 -a /dev/sde1
mdadm --grow /dev/md5 --raid-devices=4
xfs_growfs -d /mnt
```



## 7. 清除阵列超级块信息(在将分区用于其他目的之前必须这样做)

```bash
# 清除硬盘超级块信息
[root@testhoteles ~]# mdadm --zero-superblock /dev/sda1
[root@testhoteles ~]# mdadm -D /dev/md1
/dev/md1:
           Version : 1.2
     Creation Time : Wed May  8 06:11:58 2024
        Raid Level : raid1
        Array Size : 488253440 (465.63 GiB 499.97 GB)
     Used Dev Size : 488253440 (465.63 GiB 499.97 GB)
      Raid Devices : 2
     Total Devices : 1
       Persistence : Superblock is persistent

     Intent Bitmap : Internal

       Update Time : Wed May  8 15:43:16 2024
             State : clean, degraded
    Active Devices : 1
   Working Devices : 1
    Failed Devices : 0
     Spare Devices : 0

Consistency Policy : bitmap

              Name : testhoteles.hs.com:1  (local to host testhoteles.hs.com)
              UUID : 611ac412:b50551be:6cf89141:7d2d4580
            Events : 1163

    Number   Major   Minor   RaidDevice State
       -       0        0        0      removed
       1       8       17        1      active sync   /dev/sdb1

# 加入清除硬盘超级块信息后的磁盘，将会使此块磁盘从新同步另一块磁盘，从0开始
[root@testhoteles ~]# mdadm /dev/md1 --add /dev/sda1
mdadm: added /dev/sda1
[root@testhoteles ~]# mdadm -D /dev/md1
/dev/md1:
           Version : 1.2
     Creation Time : Wed May  8 06:11:58 2024
        Raid Level : raid1
        Array Size : 488253440 (465.63 GiB 499.97 GB)
     Used Dev Size : 488253440 (465.63 GiB 499.97 GB)
      Raid Devices : 2
     Total Devices : 2
       Persistence : Superblock is persistent

     Intent Bitmap : Internal

       Update Time : Wed May  8 15:43:47 2024
             State : clean, degraded, recovering
    Active Devices : 1
   Working Devices : 2
    Failed Devices : 0
     Spare Devices : 1

Consistency Policy : bitmap

    Rebuild Status : 0% complete

              Name : testhoteles.hs.com:1  (local to host testhoteles.hs.com)
              UUID : 611ac412:b50551be:6cf89141:7d2d4580
            Events : 1167

    Number   Major   Minor   RaidDevice State
       2       8        1        0      spare rebuilding   /dev/sda1
       1       8       17        1      active sync   /dev/sdb1
```