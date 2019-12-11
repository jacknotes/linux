#linux下的软RAID配置：Centos7为例
准备两块新硬盘，最好是同容量同转速的，新加硬盘必需重新启动系统才能读取，这里以raid1为例：
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