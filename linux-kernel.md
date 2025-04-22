#linux内核调优
#常规优化
linux系统调优包括两个文件，一个是limits.conf文件，一个是sysctl.conf文件，这两个文件分别在/etc/secriuty/limits.conf和/etc/sysctl.conf下，具体修改内容如下：
vi /etc/security/limits.conf
        * soft nproc 11000 #软限制最多打开的软件数
        * hard nproc 11000 #硬限制最多打开的软件数
        * soft nofile 655350#软限制最多打开的文件数
        * hard nofile 655350#硬限制最多打开的文件数
#配置覆盖问题：
当我们在 /etc/security/limits.conf 配置了:
root soft nofile 65538
root hard nofile 65538
* soft nofile 65539
* hard nofile 65539

然后我们在 /etc/security/limits.d/20-nofile.conf 配置了：
root soft nofile 65536
root hard nofile 65536
* soft nofile 65540
* hard nofile 65540
最后的取值是会取 /etc/security/limits.d/20-nofile.conf 里面的值。
	配置，只能被特定覆盖。
	/etc/security/limits.d/ 下文件的相同配置可以覆盖 /etc/security/limits.conf
	soft和hard需要都进行设置,才能生效。
	nofile不能设置 unlimited
	nofile可以设置的最大值为 1048576(2**20)，设置的值大于该数，就会进行登录不了。
	soft 设置的值 一定要小于或等于 hard 的值。


#优化TCP
        vi /etc/sysctl.conf
        #禁用包过滤功能
        net.ipv4.ip_forward = 0  
        #启用源路由核查功能
        net.ipv4.conf.default.rp_filter = 1  
        #禁用所有IP源路由
        net.ipv4.conf.default.accept_source_route = 0  
        #使用sysrq组合键是了解系统目前运行情况，为安全起见设为0关闭
        kernel.sysrq = 0  
        #控制core文件的文件名是否添加pid作为扩展
        kernel.core_uses_pid = 1  
        #开启SYN Cookies，当出现SYN等待队列溢出时，启用cookies来处理
        net.ipv4.tcp_syncookies = 1  
        #每个消息队列的大小（单位：字节）限制 重要
        kernel.msgmnb = 65536  
        #整个系统最大消息队列数量限制 重要
        kernel.msgmax = 65536  
        #单个共享内存段的大小（单位：字节）限制，计算公式64G*1024*1024*1024(字节)
        kernel.shmmax = 68719476736  
        #所有内存大小（单位：页，1页 = 4Kb），计算公式16G*1024*1024*1024/4KB(页)
        kernel.shmall = 4294967296  
        #timewait的数量，默认是180000
        net.ipv4.tcp_max_tw_buckets = 6000  
        #开启有选择的应答
        net.ipv4.tcp_sack = 1  
        #支持更大的TCP窗口. 如果TCP窗口最大超过65535(64K), 必须设置该数值为1
        net.ipv4.tcp_window_scaling = 1  
        #TCP读buffer
        net.ipv4.tcp_rmem = 4096 131072 1048576
        #TCP写buffer
        net.ipv4.tcp_wmem = 4096 131072 1048576   
        #为TCP socket预留用于发送缓冲的内存默认值（单位：字节）
        net.core.wmem_default = 8388608
        #为TCP socket预留用于发送缓冲的内存最大值（单位：字节）
        net.core.wmem_max = 16777216  
        #为TCP socket预留用于接收缓冲的内存默认值（单位：字节）  
        net.core.rmem_default = 8388608
        #为TCP socket预留用于接收缓冲的内存最大值（单位：字节）
        net.core.rmem_max = 16777216
        #每个网络接口接收数据包的速率比内核处理这些包的速率快时，允许送到队列的数据包的最大数目 重要
        net.core.netdev_max_backlog = 262144  
        #web应用中listen函数的backlog默认会给我们内核参数的net.core.somaxconn限制到128，而nginx定义的                        
        NGX_LISTEN_BACKLOG默认为511，所以有必要调整这个值
        net.core.somaxconn = 262144  
        #系统中最多有多少个TCP套接字不被关联到任何一个用户文件句柄上。这个限制仅仅是为了防止简单的DoS攻        
        击，不能过分依靠它或者人为地减小这个值，更应该增加这个值(如果增加了内存之后)
         net.ipv4.tcp_max_orphans = 3276800  
        #记录的那些尚未收到客户端确认信息的连接请求的最大值。对于有128M内存的系统而言，缺省值是1024，小内存 
        的系统则是128
        net.ipv4.tcp_max_syn_backlog = 262144  
        #时间戳可以避免序列号的卷绕。一个1Gbps的链路肯定会遇到以前用过的序列号。时间戳能够让内核接受这种“异 
        常”的数据包。这里需要将其关掉
        net.ipv4.tcp_timestamps = 0  
        #为了打开对端的连接，内核需要发送一个SYN并附带一个回应前面一个SYN的ACK。也就是所谓三次握手中的第 
        二次握手。这个设置决定了内核放弃连接之前发送SYN+ACK包的数量
       net.ipv4.tcp_synack_retries = 1  
       #在内核放弃建立连接之前发送SYN包的数量
        net.ipv4.tcp_syn_retries = 1  
        #开启TCP连接中time_wait sockets的快速回收
        net.ipv4.tcp_tw_recycle = 1  
        #开启TCP连接复用功能，允许将time_wait sockets重新用于新的TCP连接（主要针对time_wait连接）重要
        net.ipv4.tcp_tw_reuse = 1  

        net.ipv4.tcp_fin_timeout = 15  
        #表示当keepalive起用的时候，TCP发送keepalive消息的频度（单位：秒） 重要
        net.ipv4.tcp_keepalive_time = 30  
        #对外连接端口范围
        net.ipv4.ip_local_port_range = 2048 65000
        #表示文件句柄的最大数量
        fs.file-max = 102400

#time_wait连接过多（Linux内核优化）
net.ipv4.tcp_syncookies = 1 表示开启SYN Cookies。当出现SYN等待队列溢出时，启用cookies来处理，可防范少量SYN攻击，默认为0，表示关闭；

net.ipv4.tcp_tw_reuse = 1 表示开启重用。允许将TIME-WAIT sockets重新用于新的TCP连接，默认为0，表示关闭；

net.ipv4.tcp_tw_recycle = 1 表示开启TCP连接中TIME-WAIT sockets的快速回收，默认为0，表示关闭。这个甚用，在阿里云环境中开启至使端口被某些centos7访问拒绝。

net.ipv4.tcp_fin_timeout = 30 表示如果套接字由本端要求关闭，这个参数决定了它保持在FIN-WAIT-2状态的时间。

net.ipv4.tcp_keepalive_time = 1200 表示当keepalive起用的时候，TCP发送keepalive消息的频度。缺省是2小时，改为20分钟。

net.ipv4.ip_local_port_range = 1024 65000 表示用于向外连接的端口范围。缺省情况下很小：32768到61000，改为1024到65000。

net.ipv4.tcp_max_syn_backlog = 8192 表示SYN队列的长度，默认为1024，加大队列长度为8192，可以容纳更多等待连接的网络连接数。

net.ipv4.tcp_max_tw_buckets = 5000表示系统同时保持TIME_WAIT套接字的最大数量，如果超过这个数字，TIME_WAIT套接字将立刻被清除并打印警告信息。默认为180000，改为5000。对于Apache、Nginx等服务器，上几行的参数可以很好地减少TIME_WAIT套接字数量，但是对于Squid，效果却不大。此项参数可以控制TIME_WAIT套接字的最大数量，避免Squid服务器被大量的TIME_WAIT套接字拖死。
状态：描述
CLOSED：无连接是活动的或正在进行
LISTEN：服务器在等待进入呼叫
SYN_RECV：一个连接请求已经到达，等待确认
SYN_SENT：应用已经开始，打开一个连接
ESTABLISHED：正常数据传输状态
FIN_WAIT1：应用说它已经完成
FIN_WAIT2：另一边已同意释放
ITMED_WAIT：等待所有分组死掉
CLOSING：两边同时尝试关闭
TIME_WAIT：另一边已初始化一个释放
LAST_ACK：等待所有分组死掉

#/etc/sysctl.conf
---
#network
net.ipv4.tcp_syncookies = 1 
net.ipv4.tcp_tw_reuse = 1 
net.ipv4.tcp_tw_recycle = 1    这个慎用，在阿里云环境中开启至使端口被某些centos7访问拒绝。
net.ipv4.tcp_keepalive_time = 1200 
net.ipv4.ip_local_port_range = 10000 65000 
net.ipv4.tcp_max_syn_backlog = 8192 
net.ipv4.tcp_max_tw_buckets = 5000
---



#CentOS6 | 7 TCP系统调优
#通过以上修改，TIME_WAIT明显减少！
# Decrease the time default value for tcp_fin_timeout connection
net.ipv4.tcp_fin_timeout = 30
# Decrease the time default value for tcp_keepalive_time connection
net.ipv4.tcp_keepalive_time = 1800
# Turn off tcp_window_scaling
net.ipv4.tcp_window_scaling = 0
# Turn off the tcp_sack
net.ipv4.tcp_sack = 0
#Turn off tcp_timestamps
net.ipv4.tcp_timestamps = 0


#centos7内核升级
--安装elrepo源
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh  https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
yum --disablerepo="*" --enablerepo="elrepo-kernel" repolist
--查看可用的内核版本:
kernel-lt 和 kernel-ml 二者的区别：在 ELRepo中有两个内核选项，一个是kernel-lt（长期支持版），一个是 kernel-ml（主线最新版本），采用长期支持版本（kernel-lt），更加稳定一些。
yum --disablerepo="*" --enablerepo="elrepo-kernel" list available
yum --enablerepo="elrepo-kernel" install kernel-lt -y
--查看安装的内核版本
[root@k8s-node04 ~]# awk -F \' '$1=="menuentry " {print $2}' /boot/grub2/grub.cfg
CentOS Linux (5.4.187-1.el7.elrepo.x86_64) 7 (Core)
CentOS Linux (3.10.0-1160.59.1.el7.x86_64) 7 (Core)
CentOS Linux (3.10.0-957.el7.x86_64) 7 (Core)
CentOS Linux (0-rescue-cb390effac4d4aeab81a3217e9a295d9) 7 (Core)
--设置开机启动哪个版本
方法1：
[root@k8s-node04 ~]# grub2-set-default 0
方法2：
编辑配置文件 vim /etc/default/grub
将GRUB_DEFAULT=saved改为GRUB_0=saved，保存退出vim
--运行grub2-mkconfig命令来重新创建内核配置
[root@k8s-node04 ~]# grub2-mkconfig -o /boot/grub2/grub.cfg
[root@k8s-node04 ~]# reboot
[root@k8s-node04 ~]# uname  -a
Linux k8s-node04 5.4.187-1.el7.elrepo.x86_64 #1 SMP Mon Mar 21 17:34:42 EDT 2022 x86_64 x86_64 x86_64 GNU/Linux



## 使用示例
释放缓存，使用`/proc/sys/vm/drop_caches`参数，此参数只能写不能查看
```bash
root@ansible:/download# ls -l /proc/sys/vm/drop_caches
--w------- 1 root root 0 Apr 22 17:45 /proc/sys/vm/drop_caches

# 释放页缓存
root@ansible:/download# free
              total        used        free      shared  buff/cache   available
Mem:        1948932      422776       81924        9700     1444232     1335560
Swap:        995236         524      994712
root@ansible:/download# echo 1 > /proc/sys/vm/drop_caches
root@ansible:/download# free
              total        used        free      shared  buff/cache   available
Mem:        1948932      422828     1209448        9692      316656     1343428
Swap:        995236         524      994712


# 释放目录项和inode缓存
root@ansible:/download# free
              total        used        free      shared  buff/cache   available
Mem:        1948932      423160     1206908        9692      318864     1343076
Swap:        995236         524      994712
root@ansible:/download# echo 2 > /proc/sys/vm/drop_caches
root@ansible:/download# free
              total        used        free      shared  buff/cache   available
Mem:        1948932      292136     1385328        9672      271468     1497172
Swap:        995236         524      994712


# 释放所有缓存
root@ansible:/download# free
              total        used        free      shared  buff/cache   available
Mem:        1948932      282872     1394380        9672      271680     1506412
Swap:        995236         524      994712
root@ansible:/download# echo 3 > /proc/sys/vm/drop_caches
root@ansible:/download# free
              total        used        free      shared  buff/cache   available
Mem:        1948932      282168     1396496        9672      270268     1507064
Swap:        995236         524      994712

```




