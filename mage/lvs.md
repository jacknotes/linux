# lvs

## ipvs
从Linux内核版本2.6起，ip_vs code已经被整合进了内核中，因此，只要在编译内核的时候选择了ipvs的功能，您的Linux即能支持LVS。Linux 2.4.23以后的内核版本也整合了ip_vs code，但如果是更旧的内核版本，您得自己手动将ip_vs code整合进内核原码中，并重新编译内核方可使用lvs。

### ipvs类型：

NAT:地址转换

```
1. 集群节点跟director必须在同一个IP网络中
2. RIP（RealServer IP）通常是私用地址，仅用于各集群节点间的通信
3. director位于client和realServer之间，并负责处理进出的所有通信
4. realServer必须将网关指向DIP(DirectorIP)
5. 支持端口映射
6. realServer可以使用任意os
7. 较大规模应用场景中，director易成为系统瓶颈（一般最多带10个RealServer）
```

DR：直接路由

```
1. 不支持端口映射
2. 集群节点跟director必须在同一个物理网络中
3. RIP可以使用公网地址，实现便捷的远程管理和监控
4. director仅负责处理入站请求，响应报文则由RealServer直接发往客户端
```

TUN：隧道

```
1. 不支持端口映射
2. 集群节点可以跨越Internet
3. RIP必须是公网地址
4. director仅负责处理入站请求，响应报文则由RealServer直接发往客户端
5. RealServer网关不能指向director
6. 只有支持隧道功能的os才能用于realserver
```



```
Type:
	NAT:
		类似DNAT
	DR:
		只接收入站请求，出站响应则由后端RealServer响应给Client,Director和RealServer通信是通过MAC地址，Director不解开ip层包
	TUN:
		只接收入站请求，出站响应则由后端RealServer响应给Client,Director和RealServer通信是通过TUNNING隧道模式进行通信，Director接收到Client包时，为了与后端的RealServer通信，Director对Client发过来的包加一个ip包，这样一来Director访问RealServer就成了外部是DIP和RIP，内部还是CIP和VIP,由于后端RealServer解开外部ip包，得到内部ip包，所以RealServer最后成功发向了Client
```



### 知识回顾：

```
	LB：Load Balance
​	HA：High Availability
​	HP：High Performance
LB：
​	Hardware:
​		F5 BIG-IP 
​		Citrix NetScaler
​		A10
​	Software
​		四层：
​			LVS
​		七层：
​			nginx
​			haproxy

LVS: Linux Virtual Server
```





### 关于ipvsadm:
```
## ipvs的命令行管理工具
ipvsadm是运行于用户空间、用来与ipvs交互的命令行工具，它的作用表现在：
1、定义在Director上进行dispatching的服务(service)，以及哪些服务器(server)用来提供此服务；
2、为每台同时提供某一种服务的服务器定义其权重（即概据服务器性能确定的其承担负载的能力）；
注：权重用整数来表示，有时候也可以将其设置为atomic_t；其有效表示值范围为24bit整数空间，即（2^24-1）；
因此，ipvsadm命令的主要作用表现在以下方面：
1、添加服务（通过设定其权重>0）；
2、关闭服务（通过设定其权重>0）；此应用场景中，已经连接的用户将可以继续使用此服务，直到其退出或超时；新的连接请求将被拒绝；
3、保存ipvs设置，通过使用“ipvsadm-sav > ipvsadm.sav”命令实现；
4、恢复ipvs设置，通过使用“ipvsadm-sav < ipvsadm.sav”命令实现;
5、显示ip_vs的版本号，下面的命令显示ipvs的hash表的大小为4k；
6、显示ipvsadm的版本号
ipvsadm --version
   ipvsadm v1.24 2003/06/07 (compiled with popt and IPVS v1.2.0)
ipvsadm下载地址： http://www.linuxvirtualserver.org/software/ipvs.html#kernel-2.6
7、ipvsadm使用中应注意的问题
默认情况下，ipvsadm在输出主机信息时使用其主机名而非IP地址，因此，Director需要使用名称解析服务。如果没有设置名称解析服务、服务不可用或设置错误，ipvsadm将会一直等到名称解析超时后才返回。当然，ipvsadm需要解析的名称仅限于RealServer，考虑到DNS提供名称解析服务效率不高的情况，建议将所有RealServer的名称解析通过/etc/hosts文件来实现；
8、iptables应该避免进行服务，主要是INPUT,FORWARD,OUTPUT Chain上不能启动。
```



### ipvs调度算法
```
固定调度
	rr: 轮叫，轮询
	wrr: Weight, 加权
	sh: source hash, 源地址hash
四种静态算法：
 	 1. rr:Round Robin
     2. wrr:Weight Round Robin
     3. dh:destination hash (常用来选择目标是Cache Server)
     4. sh:source hash (session affinity)
        六种动态算法：
        lc: 最少连接
        active*256+inactive
        谁的小，挑谁
        wlc: 加权最少连接
        (active*256+inactive)/weight
        sed: 最短期望延迟
        （active+1)*256/weight
        nq: never queue(永远不排除)
        LBLC: 基于本地的最少连接
        DH: 
        LBLCR: 基于本地的带复制功能的最少连接

默认方法：wlc

详解调度算法：
Director在接收到来自于Client的请求时，会基于"schedule"从RealServer中选择一个响应给Client。ipvs支持以下调度算法：
1、轮询（round robin, rr),加权轮询(Weighted round robin, wrr)——新的连接请求被轮流分配至各RealServer；算法的优点是其简洁性，它无需记录当前所有连接的状态，所以它是一种无状态调度。轮叫调度算法假设所有服务器处理性能均相同，不管服务器的当前连接数和响应速度。该算法相对简单，不适用于服务器组中处理性能不一的情况，而且当请求服务时间变化比较大时，轮叫调度算法容易导致服务器间的负载不平衡。
2、最少连接(least connected, lc)， 加权最少连接(weighted least connection, wlc)——新的连接请求将被分配至当前连接数最少的RealServer；最小连接调度是一种动态调度算法，它通过服务器当前所活跃的连接数来估计服务器的负载情况。调度器需要记录各个服务器已建立连接的数目，当一个请求被调度到某台服务器，其连接数加1；当连接中止或超时，其连接数减一。
3、基于局部性的最少链接调度（Locality-Based Least Connections Scheduling，lblc）——针对请求报文的目标IP地址的负载均衡调度，目前主要用于Cache集群系统，因为在Cache集群中客户请求报文的目标IP地址是变化的。这里假设任何后端服务器都可以处理任一请求，算法的设计目标是在服务器的负载基本平衡情况下，将相同目标IP地址的请求调度到同一台服务器，来提高各台服务器的访问局部性和主存Cache命中率，从而整个集群系统的处理能力。LBLC调度算法先根据请求的目标IP地址找出该目标IP地址最近使用的服务器，若该服务器是可用的且没有超载，将请求发送到该服务器；若服务器不存在，或者该服务器超载且有服务器处于其一半的工作负载，则用“最少链接”的原则选出一个可用的服务器，将请求发送到该服务器。
4、带复制的基于局部性最少链接调度（Locality-Based Least Connections with Replication Scheduling，lblcr）——也是针对目标IP地址的负载均衡，目前主要用于Cache集群系统。它与LBLC算法的不同之处是它要维护从一个目标IP地址到一组服务器的映射，而 LBLC算法维护从一个目标IP地址到一台服务器的映射。对于一个“热门”站点的服务请求，一台Cache 服务器可能会忙不过来处理这些请求。这时，LBLC调度算法会从所有的Cache服务器中按“最小连接”原则选出一台Cache服务器，映射该“热门”站点到这台Cache服务器，很快这台Cache服务器也会超载，就会重复上述过程选出新的Cache服务器。这样，可能会导致该“热门”站点的映像会出现在所有的Cache服务器上，降低了Cache服务器的使用效率。LBLCR调度算法将“热门”站点映射到一组Cache服务器（服务器集合），当该“热门”站点的请求负载增加时，会增加集合里的Cache服务器，来处理不断增长的负载；当该“热门”站点的请求负载降低时，会减少集合里的Cache服务器数目。这样，该“热门”站点的映像不太可能出现在所有的Cache服务器上，从而提供Cache集群系统的使用效率。LBLCR算法先根据请求的目标IP地址找出该目标IP地址对应的服务器组；按“最小连接”原则从该服务器组中选出一台服务器，若服务器没有超载，将请求发送到该服务器；若服务器超载；则按“最小连接”原则从整个集群中选出一台服务器，将该服务器加入到服务器组中，将请求发送到该服务器。同时，当该服务器组有一段时间没有被修改，将最忙的服务器从服务器组中删除，以降低复制的程度。
5、目标地址散列调度（Destination Hashing，dh）算法也是针对目标IP地址的负载均衡，但它是一种静态映射算法，通过一个散列（Hash）函数将一个目标IP地址映射到一台服务器。目标地址散列调度算法先根据请求的目标IP地址，作为散列键（Hash Key）从静态分配的散列表找出对应的服务器，若该服务器是可用的且未超载，将请求发送到该服务器，否则返回空。
6、源地址散列调度（Source Hashing，sh）算法正好与目标地址散列调度算法相反，它根据请求的源IP地址，作为散列键（Hash Key）从静态分配的散列表找出对应的服务器，若该服务器是可用的且未超载，将请求发送到该服务器，否则返回空。它采用的散列函数与目标地址散列调度算法的相同。除了将请求的目标IP地址换成请求的源IP地址外，它的算法流程与目标地址散列调度算法的基本相似。在实际应用中，源地址散列调度和目标地址散列调度可以结合使用在防火墙集群中，它们可以保证整个系统的唯一出入口。
7、关于LVS追踪标记fwmark：如果LVS放置于多防火墙的网络中，并且每个防火墙都用到了状态追踪的机制，那么在回应一个针对于LVS的连接请求时必须经过此请求连接进来时的防火墙，否则，这个响应的数据包将会被丢弃。
```



### 查看内核是否支持IPVS

```
[root@lvs ~]# grep -i 'ipvs' /boot/config-2.6.32-696.el6.x86_64   #查看内核是否支持ipvs

# IPVS transport protocol load balancing support

# IPVS scheduler

# IPVS application helper

[root@lvs ~]# grep -i 'vs' /boot/config-2.6.32-696.el6.x86_64   
CONFIG_GENERIC_TIME_VSYSCALL=y

# CONFIG_X86_VSMP is not set

CONFIG_HIBERNATION_NVS=y
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

# IPVS application helper

CONFIG_IP_VS_FTP=m
CONFIG_IP_VS_PE_SIP=m
CONFIG_OPENVSWITCH=m
CONFIG_OPENVSWITCH_GRE=y
CONFIG_OPENVSWITCH_VXLAN=y
CONFIG_MTD_BLKDEVS=m
CONFIG_SCSI_MVSAS=m

# CONFIG_SCSI_MVSAS_DEBUG is not set

# CONFIG_SCSI_MVSAS_TASKLET is not set

CONFIG_VMWARE_PVSCSI=m
CONFIG_MOUSE_VSXXXAA=m
CONFIG_MAX_RAW_DEVS=8192
CONFIG_USB_SEVSEG=m
CONFIG_USB_VST=m
```



### IPVS安装

```
[root@lvs ~]# yum install ipvsadm -y
#命令详解
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

		# ipvsadm -a -t 172.16.100.1:80 -r 192.168.10.8 -m 

		# ipvsadm -a -t 172.16.100.1:80 -r 192.168.10.9 -m

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

注：各节点之间的时间偏差不应该超出1秒钟；

查看LVS上当前的所有连接

# ipvsadm -Lcn   

或者
#cat /proc/net/ip_vs_conn
查看虚拟服务和RealServer上当前的连接数、数据包数和字节数的统计值，则可以使用下面的命令实现：

# ipvsadm -l --stats

查看包传递速率的近似精确值，可以使用下面的命令：

# ipvsadm -l --rate 

# ipvsadm -l --timeout #查看tcp,tcpfin,udp包超时时间

# ipvsadm -S > /tmp/ipvs.save #保存ipvs规则

# ipvsadm -R < /tmp/ipvs.save #载入ipvs规则
```



#### NAT模型

```
LVS-NAT基于cisco的LocalDirector。VS/NAT不需要在RealServer上做任何设置，其只要能提供一个tcp/ip的协议栈即可，甚至其无论基于什么OS。基于LVS/NAT，所有的入站数据包均由Director进行目标地址转换后转发至内部的RealServer，RealServer响应的数据包再由Director转换源地址后发回客户端。 
VS/NAT模式不能与netfilter兼容，因此，不能将VS/NAT模式的Director运行在netfilter的保护范围之中。现在已经有补丁可以解决此问题，但尚未被整合进ip_vs code。

____________

​       |            |
​       |  client    |
​       |____________|                     
​     CIP=192.168.0.253 (eth0)             
​              |                           
​              |                           
​     VIP=192.168.0.220 (eth0)             

____________

​       |            |                     
​       |  director  |                     
​       |____________|                     
​     DIP=192.168.10.10 (eth1)         
​              |                           
​           (switch)------------------------
​              |                           |
​     RIP=192.168.10.2 (eth0)       RIP=192.168.10.3 (eth0)

_____________               _____________

​       |             |             |             |
​       | realserver1 |             | realserver2 |
​       |_____________|             |_____________|  
设置VS/NAT模式的LVS(这里以web服务为例)
Director:
建立服务

# ipvsadm -A -t VIP:PORT -s rr

如:

# ipvsadm -A -t 192.168.0.220:80 -s rr #-A添加director,-t表示tcp协议，VIP:PORT为director的服务地址，-s后面接调度算法，rr为round robin

设置转发：

# ipvsadm -a -t VIP:PORT -r RIP_N:PORT -m -w N #-a为添加RealServer,-t为Director服务器的tcp地址，VIP:PORT表示Director的地址，-r为RealServer，后面接RealServer地址，-m表示地址伪装（masquerade），用于地址转换，-w表示设置权重值，这里如要设置，首先Director必须为与加权相关的调度算法，否则无效

如：

# ipvsadm -a -t 192.168.0.220:80 -r 192.168.10.2 -m -w 1

# ipvsadm -a -t 192.168.0.220:80 -r 192.168.10.3 -m -w 1

打开路由转发功能

# echo "1" > /proc/sys/net/ipv4/ip_forward

#NAT模型脚本
服务控制脚本：
#!/bin/bash
#

# chkconfig: - 88 12

# description: LVS script for VS/NAT

#
. /etc/rc.d/init.d/functions
#
VIP=192.168.1.200
DIP=192.168.200.201
RIP1=192.168.200.202
RIP2=192.168.200.203

#
case "$1" in
start)           

  /sbin/ifconfig eth1:1 $VIP netmask 255.255.255.0 up

# Since this is the Director we must be able to forward packets

  echo 1 > /proc/sys/net/ipv4/ip_forward

# Clear all iptables rules.

  /sbin/iptables -F

# Reset iptables counters.

  /sbin/iptables -Z

# Clear all ipvsadm rules/services.

  /sbin/ipvsadm -C

# Add an IP virtual service for VIP 192.168.0.219 port 80

# In this recipe, we will use the round-robin scheduling method. 

# In production, however, you should use a weighted, dynamic scheduling method. 

  /sbin/ipvsadm -A -t $VIP:80 -s rr

# Now direct packets for this VIP to

# the real server IP (RIP) inside the cluster

  /sbin/ipvsadm -a -t $VIP:80 -r $RIP1 -m
  /sbin/ipvsadm -a -t $VIP:80 -r $RIP2 -m

  /bin/touch /var/lock/subsys/ipvsadm.lock
;;

stop)

# Stop forwarding packets

  echo 0 > /proc/sys/net/ipv4/ip_forward

# Reset ipvsadm

  /sbin/ipvsadm -C

# Bring down the VIP interface

  ifconfig eth1:1 down

  rm -rf /var/lock/subsys/ipvsadm.lock
;;

status)
  [ -e /var/lock/subsys/ipvsadm.lock ] && echo "ipvs is running..." || echo "ipvsadm is stopped..."
;;
*)
  echo "Usage: $0 {start|stop}"
;;
esac
```





#### DR模型 
	ARP问题：
						  __________
	​                     |        |
	​                     | client |
	​                     |________|
	 	                       |
	​                         |
	​                      (router)
	​                         |
	​                         |
	​                         |       __________
	​                         |  DIP |          |
	​                         |------| director |
	​                         |  VIP |__________|
	​                         |
	​                         |
	
	                         |
	       ------------------------------------
	
	​       |                 |                |
	​       |                 |                |
	   RIP1, VIP         RIP2, VIP        RIP3, VIP
	
	______________    ______________    ______________
	|              |  |              |  |              |
	| realserver1  |  | realserver2  |  | realserver3  |
	|______________|  |______________|  |______________|
	在如上图的LVS/DR或LVS/TUN应用的一种模型中（所有机器都在同一个物理网络），所有机器（包括Director和RealServer）都使用了一个额外的IP地址，即VIP。当一个客户端向VIP发出一个连接请求时，此请求必须要连接至Director的VIP，而不能是RealServer的。因为，LVS的主要目标就是要Director负责调度这些连接请求至RealServer的。
	因此，在Client发出至VIP的连接请求后，只能由Director将其MAC地址响应给客户端（也可能是直接与Director连接的路由设备），而Director则会相应的更新其ipvsadm table以追踪此连接，而后将其转发至后端的RealServer之一。
	如果Client在请求建立至VIP的连接时由某RealServer响应了其请求，则Client会在其MAC table中建立起一个VIP至RealServer的对应关系，并进行后面的通信。此时，在Client看来只有一个RealServer而无法意识到其它服务器的存在。
	为了解决此问题，可以通过在路由器上设置其转发规则来实现(MAC-IP地址绑定)。当然，如果没有权限访问路由器并做出相应的设置，则只能通过传统的本地方式来解决此问题了。这些方法包括：
	1、禁止RealServer响应对VIP的ARP请求；
	2、在RealServer上隐藏VIP，以使得它们无法获知网络上的ARP请求；
	3、基于“透明代理（Transparent Proxy）”或者“fwmark （firewall mark）”；
	4、禁止ARP请求发往RealServers；
	传统认为，解决ARP问题可以基于网络接口，也可以基于主机来实现。Linux采用了基于主机的方式，因为其可以在大多场景中工作良好，但LVS却并不属于这些场景之一，因此，过去实现此功能相当麻烦。现在可以通过设置arp_ignore和arp_announce，这变得相对简单的多了。
	Linux 2.2和2.4（2.4.26之前的版本）的内核解决“ARP问题”的方法各不相同，且比较麻烦。幸运的是，2.4.26和2.6的内核中引入了两个新的调整ARP栈的标志（device flags）：arp_announce和arp_ignore。基于此，在DR/TUN的环境中，所有IPVS相关的设定均可使用arp_announce=2和arp_ignore=1/2/3来解决“ARP问题”了。
	arp_annouce：Define different restriction levels for announcing the local source IP address from IP packets in ARP requests sent on interface；
		0 - (default) Use any local address, configured on any interface.
		1 - Try to avoid local addresses that are not in the target's subnet for this interface. 
		2 - Always use the best local address for this target.
		
	arp_ignore: Define different modes for sending replies in response to received ARP requests that resolve local target IP address.
		0 - (default): reply for any local target IP address, configured on any interface.
		1 - reply only if the target IP address is local address configured on the incoming interface.
		2 - reply only if the target IP address is local address configured on the incoming interface and both with the sender's IP address are part from same subnet on this interface.
		3 - do not reply for local address configured with scope host, only resolutions for golbal and link addresses are replied.
		4-7 - reserved
		8 - do not reply for all local addresses
	
	VIP: MAC(DVIP)
	arp tables：
	kernel parameter:
		arp_ignore: 定义接收到ARP请求时的响应级别；
			0：只要本地配置的有相应地址，就给予响应；
			1：仅当目标 IP 地址是传入接口上配置的本地地址时才回复。
	
		arp_announce：定义将自己地址向外通告时的通告级别；
			0：将本地任何接口上的任何地址向外通告；
			1：试图仅向目标网络通告与其网络匹配的地址；
			2：仅向与本地接口上地址匹配的网络进行通告；



#### LVS/DR模型数据包流向

![lvs-dr](..\image\lvs\lvs-dr.png)

```
ClientIP: 172.168.2.11(38:22:d6:6c:07:5d)
DirectorIP: 172.168.2.18(00:1A:4D:8C:FA:D5)		VIP：172.168.2.20(00:1A:4D:8C:FA:D5)		172.168.2.19(00:1A:4D:8C:FA:D6)	
RealServerIP: 172.168.2.15(00:26:18:45:D7:88)	172.168.2.17(00:26:18:45:D7:89)
流程：

1. client请求VIP，找到Director
2. Director根据调度策略算法选取一台realserver,并把请求转发给后端realserver
3. realserver收到请求后，响应处理并把结果直接返回给client,而不走director
   数据包解封装流程：
4. director接收到client消息，即源mac地址为38:22:d6:6c:07:5d，目的地址为00:1A:4D:8C:FA:D5，源ip为172.168.2.11，目的ip为172.168.2.20
5. director根据调度策略算法选取一台realserver，假如调度给172.168.2.15，并把源mac地址改为00:1A:4D:8C:FA:D5(VIP mac地址)，目的mac地址改为00:26:18:45:D7:88(172.168.2.15的mac地址)，源ip和目的ip都不变（源ip为172.168.2.11，目的ip为172.168.2.20）
6. realserver接收到请求，先看到mac地址(00:26:18:45:D7:88)，再看IP地址(172.168.2.20)在自己lo接口上，都是自己并做出响应处理给客户端。即源mac为00:26:18:45:D7:88，源ip为172.168.2.20，目的mac地址为38:22:d6:6c:07:5d(第一次不知道会发ARP广播包，后续则会留在在mac table中)，目的ip为172.168.2.11。
注：TCP3次握手也是这样的顺序工作流程来工作，这次是一次请求工作流程，，数据帧都是有编号的，经过多次转发，都是在同一主机上进行处理，所以客户端和RS之间的数据包请求和响应处理是正常的。

疑点总结：
1. client请求VIP时，不光只有director有VIP，realserver也有VIP，如何解决正常解析到Director而不解析到realserver?
   答：通过配置net.ipv4.conf.eth0.arp_ignore = 1，net.ipv4.conf.all.arp_ignore = 1内核参数实现，此参数意思为"仅当目标 IP 地址是传入接口上配置的本地地址时才回复"，当realserver收到arp广播包时，必先是经过eth0物理接口的，而不会经过逻辑接口(lo接口)。因为VIP地址是配置在lo接口的，eth0接口并没有配置，所以当收到VIP地址的ARP广播包时，内核参数net.ipv4.conf.eth0.arp_ignore = 1就生效了，从而不会对client请求的VIP做出ARP响应，从而只有director会做出响应。
2. lvs/dr模型下director是如何进行转发的？
   答：diretor接收到client的请求后，只对二层以太网帧进行更改，不对对三层ip包进行更改，然后在进行转发
3. realserver收到director的数据包后如何进行响应的?
   答：直接响应客户端，响应的数据报文中把本地物理接口eth0的mac地址作为源mac地址(因为配置内核参数的原因{net.ipv4.conf.eth0.arp_announce = 2}，意思为只向该网卡回应与该网段匹配的ARP报文，又因为client IP 172.168.2.11跟eth0 ip 172.168.2.15是同网段，所以用eth0的mac地址回应172.168.2.11)，本地VIP做为源IP，目标IP为clientIP，目标mac地址先从ARP缓存查找，如无进行ARP广播，即源mac00:26:18:45:D7:88，源ip为172.168.2.20。目标mac地址为38:22:d6:6c:07:5d，目标ip为172.168.2.11。最后客户端收到数据帧得知mac地址和ip地址都是自己，并且源ip也是自己请求的VIP地址，就进行正常接收了，并不会再去看源mac地址了。当客户端再次请求172.168.2.20时会去找ARP缓存，或者进行ARP广播，重复以上的流程，去找DR，再由DR转发到RS，最后RS响应给client，流程：client -> DR -> RS -> client {重复此流程}

## 其它第三方说明
### 重点将请求报文的目标 MAC 地址设定为挑选出的 RS 的 MAC 地址,当RS接收到这个数据包之后,将源MAC替换成自己的MAC,目标MAC地址为客户端地址。
(1) 当用户请求到达 Director Server，此时请求的数据报文会先到内核空间的 PREROUTING 链。 此时报文的源 IP 为 CIP，目标 IP 为 VIP,MAC地址为各自的MAC地址。
(2) PREROUTING 检查发现数据包的目标 IP 是本机，将数据包送至 INPUT 链。
(3) IPVS 比对数据包请求的服务是否为集群服务，若是，将请求报文中的源 MAC 地址修改为 VIP 的 MAC 地址，将目标 MAC 地址修改 RIP 的 MAC 地址，然后将数据包发至 POSTROUTING 链。 此时的源 IP 和目的 IP 均未修改，仅修改了源 MAC 地址为 VIP 的 MAC 地址，目标 MAC 地址为 RIP 的 MAC 地址。
(4) 由于 DS 和 RS 在同一个网络中，所以是通过二层来传输。POSTROUTING 链检查目标 MAC 地址为 RIP 的 MAC 地址，那么此时数据包将会发至 Real Server。
(5) RS 发现请求报文的 MAC 地址是自己的 MAC 地址，就接收此报文。处理完成之后，将响应报文通过 lo 接口传送给 eth0 网卡然后向外发出。 此时的源 IP 地址为 VIP，目标 IP 为 CIP,并且将源MAC地址改为自己的MAC,目标MAC改为客户端MAC。
(6) 响应报文最终送达至客户端

LVS/DR 模型的特性
特点 1：保证前端路由将目标地址为 VIP 报文统统发给 Director Server，而不是 RS
RS 可以使用私有地址；也可以是公网地址，如果使用公网地址，此时可以通过互联网对 RIP 进行直接访问
RS 跟 Director Server 必须在同一个物理网络中
所有的请求报文经由 Director Server，但响应报文必须不能进过 Director Server
不支持地址转换，也不支持端口映射
RS 可以是大多数常见的操作系统
RS 的网关绝不允许指向 DIP(因为我们不允许他经过 director)
RS 上的 lo 接口配置 VIP 的 IP 地址
缺陷：RS 和 DS 必须在同一机房中
特点 1 的解决方案：

在前端路由器做静态地址路由绑定，将对于 VIP 的地址仅路由到 Director Server
存在问题：用户未必有路由操作权限，因为有可能是运营商提供的，所以这个方法未必实用
arptables：在 arp 的层次上实现在 ARP 解析时做防火墙规则，过滤 RS 响应 ARP 请求。这是由 iptables 提供的
修改 RS 上内核参数（arp_ignore 和 arp_announce）将 RS 上的 VIP 配置在 lo 接口的别名上，并限制其不能响应对 VIP 地址解析请求。
DR（Direct Routing 直接路由模式）此模式时 LVS 调度器只接收客户发来的请求并将请求转发给后端服务器，后端服务器处理请求后直接把内容直接响应给客户，而不用再次经过 LVS 调度器。LVS 只需要将网络帧的 MAC 地址修改为某一台后端服务器 RS 的 MAC，该包就会被转发到相应的 RS 处理，注意此时的源 IP 和目标 IP 都没变。RS 收到 LVS 转发来的包时，链路层发现 MAC 是自己的，到上面的网络层，发现 IP 也是自己的，于是这个包被合法地接受，RS 感知不到前面有 LVS 的存在。而当 RS 返回响应时，只要直接向源 IP（即用户的 IP）返回即可，不再经过 LVS。

注意
(1) 确保前端路由器将目标 IP 为 VIP 的请求报文发往 Director：
(a) 在前端网关做静态绑定；
(b) 在 RS 上使用 arptables；
(c) 在 RS 上修改内核参数以限制 arp 通告及应答级别；
arp_announce
arp_ignore
(2) RS 的 RIP 可以使用私网地址，也可以是公网地址；RIP 与 DIP 在同一 IP 网络；RIP 的网关不能指向 DIP，以确保响应报文不会经由 Director；
(3) RS 跟 Director 要在同一个物理网络；
(4) 请求报文要经由 Director，但响应不能经由 Director，而是由 RS 直接发往 Client；
(5) 此模式不支持端口映射；

DR模式缺点
唯一的缺陷在于它要求 LVS 调度器及所有应用服务器在同一个网段中，因此不能实现集群的跨网段应用。

DR模式优点
可见在处理过程中 LVS Route 只处理请求的直接路由转发，所有响应结果由各个应用服务器自行处理，并对用户进行回复，网络流量将集中在 LVS 调度器之上。
```

### 部署DR环境

```
Director:
	eth0,DIP:192.168.1.199 
	eth0:0,VIP:192.168.1.200
RealServer1:
	eth3,Rip:192.168.1.198
	lo,VIP:192.168.1.200
RealServer2:
	eth2,Rip:192.168.1.197
	lo,VIP:192.168.1.200

部署：
##Director:
[root@lvs ~]# ifconfig eth0:0 192.168.1.200/32 broadcast 192.168.1.200 up
[root@lvs ~]# route add -host 192.168.1.200 dev eth0:0
[root@lvs ~]# ifconfig 
eth0      Link encap:Ethernet  HWaddr 00:0C:29:5F:97:D7  
          inet addr:192.168.1.199  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::20c:29ff:fe5f:97d7/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:17767 errors:0 dropped:0 overruns:0 frame:0
          TX packets:12874 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:2000374 (1.9 MiB)  TX bytes:1516017 (1.4 MiB)

eth0:0    Link encap:Ethernet  HWaddr 00:0C:29:5F:97:D7  
          inet addr:192.168.1.200  Bcast:192.168.1.200  Mask:0.0.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:240 errors:0 dropped:0 overruns:0 frame:0
          TX packets:240 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:15076 (14.7 KiB)  TX bytes:15076 (14.7 KiB)
##RealServer1:
部署RealServer的VIP不要在没有设置arp_ignore和arp_announce前设置，可以先设置RIP。在RealServers上，VIP配置在本地回环接口lo上。
注：arp响应一定是由内向外响应的，lo如果向外响应会到达eth0，然后最终到达目标ip。所以我们把vip配置在lo接口上，只要关掉eth0或者lo接口的响应级别和通行级别即可。
#vim /etc/sysctl.conf
net.ipv4.conf.eth0.arp_ignore = 1
net.ipv4.conf.eth0.arp_announce = 2
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 2
以上选项需要在启用VIP之前进行，否则，则需要在Drector上清空arp表才能正常使用LVS。
#到达Director的数据包首先会经过PREROUTING，而后经过路由发现其目标地址为本地某接口的地址，因此，接着就会将数据包发往INPUT(LOCAL_IN HOOK)。此时，正在运行内核中的ipvs（始终监控着LOCAL_IN HOOK）进程会发现此数据包请求的是一个集群服务，因为其目标地址是VIP。于是，此数据包本来到达本机(Director)目标行程被Director改变为经由POSTROUTING HOOK发往RealServer。这种改变数据包正常行程的过程是根据IPVS表(由管理员通过ipvsadm定义)来实现的。
[root@www ~]# sysctl -p
[root@www ~]# cat /proc/sys/net/ipv4/conf/eth0/arp_ignore 
1
[root@www ~]# cat /proc/sys/net/ipv4/conf/eth0/arp_announce 
2
[root@www ~]# cat /proc/sys/net/ipv4/conf/all/arp_ignore         
1
[root@www ~]# cat /proc/sys/net/ipv4/conf/all/arp_announce 
2
[root@httpd1 ~]# ifconfig lo:0 192.168.1.200 netmask 255.255.255.255 broadcast 192.168.1.200 up
[root@httpd1 ~]# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
192.168.1.0     0.0.0.0         255.255.255.0   U     0      0        0 eth3
169.254.0.0     0.0.0.0         255.255.0.0     U     1002   0        0 eth3
0.0.0.0         192.168.1.1     0.0.0.0         UG    0      0        0 eth3
[root@httpd1 ~]# route add -host 192.168.1.200 dev lo:0
[root@httpd1 ~]# ifconfig 
eth3      Link encap:Ethernet  HWaddr 00:0C:29:06:03:54  
          inet addr:192.168.1.198  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::20c:29ff:fe06:354/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:9846 errors:0 dropped:0 overruns:0 frame:0
          TX packets:5138 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:933215 (911.3 KiB)  TX bytes:898759 (877.6 KiB)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:188 errors:0 dropped:0 overruns:0 frame:0
          TX packets:188 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:10582 (10.3 KiB)  TX bytes:10582 (10.3 KiB)

lo:0      Link encap:Local Loopback  
          inet addr:192.168.1.200  Mask:255.255.255.255
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
[root@httpd1 ~]# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
192.168.1.200   0.0.0.0         255.255.255.255 UH    0      0        0 lo
192.168.1.0     0.0.0.0         255.255.255.0   U     0      0        0 eth3
169.254.0.0     0.0.0.0         255.255.0.0     U     1002   0        0 eth3
0.0.0.0         192.168.1.1     0.0.0.0         UG    0      0        0 eth3
##RealServer2:
#vim /etc/sysctl.conf
net.ipv4.conf.eth0.arp_ignore = 1
net.ipv4.conf.eth0.arp_announce = 2
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 2
[root@www ~]# sysctl -p
[root@httpd2 ~]# ifconfig lo:0 192.168.1.200/32 broadcast 192.168.1.200 up
[root@httpd2 ~]# ifconfig 
eth2      Link encap:Ethernet  HWaddr 00:0C:29:D2:A3:F8  
          inet addr:192.168.1.197  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::20c:29ff:fed2:a3f8/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:5698 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3751 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:504132 (492.3 KiB)  TX bytes:402358 (392.9 KiB)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:477 errors:0 dropped:0 overruns:0 frame:0
          TX packets:477 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:26148 (25.5 KiB)  TX bytes:26148 (25.5 KiB)

lo:0      Link encap:Local Loopback  
          inet addr:192.168.1.200  Mask:0.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
[root@httpd2 ~]# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
192.168.1.0     0.0.0.0         255.255.255.0   U     0      0        0 eth2
169.254.0.0     0.0.0.0         255.255.0.0     U     1002   0        0 eth2
0.0.0.0         192.168.1.1     0.0.0.0         UG    0      0        0 eth2
[root@httpd2 ~]# route add -host 192.168.1.200 dev lo:0
[root@httpd2 ~]# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
192.168.1.200   0.0.0.0         255.255.255.255 UH    0      0        0 lo
192.168.1.0     0.0.0.0         255.255.255.0   U     0      0        0 eth2
169.254.0.0     0.0.0.0         255.255.0.0     U     1002   0        0 eth2
0.0.0.0         192.168.1.1     0.0.0.0         UG    0      0        0 eth2
##Director上进行ipvsadm操作
[root@lvs ~]# ipvsadm -C
[root@lvs ~]# ipvsadm -A -t 192.168.1.200:80 -s wlc
[root@lvs ~]# ipvsadm -a -t 192.168.1.200:80 -r 192.168.1.198 -g -w 3
[root@lvs ~]# ipvsadm -a -t 192.168.1.200:80 -r 192.168.1.197 -g -w 1
[root@lvs ~]# ipvsadm -ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  192.168.1.200:80 wlc
  -> 192.168.1.197:80             Route   1      0          0         
  -> 192.168.1.198:80             Route   3      0          0   
如果有多台Realserver，在某些应用场景中，Director还需要基于“连接追踪”实现将由同一个客户机的请求始终发往其第一次被分配至的Realserver，以保证其请求的完整性等。其连接追踪的功能由Hash table实现。Hash table的大小等属性可通过下面的命令查看：

# ipvsadm -lcn
为了保证其时效性，Hash table中“连接追踪”信息被定义了“生存时间”。LVS为记录“连接超时”定义了三个计时器：
	1、空闲TCP会话；
	2、客户端正常断开连接后的TCP会话；
	3、无连接的UDP数据包（记录其两次发送数据包的时间间隔）；
上面三个计时器的默认值可以由类似下面的命令修改，其后面的值依次对应于上述的三个计时器：

# ipvsadm --set 28800 30 600
数据包在由Direcotr发往Realserver时，只有目标MAC地址发生了改变(变成了Realserver的MAC地址)。Realserver在接收到数据包后会根据本地路由表将数据包路由至本地回环设备，接着，监听于本地回环设备VIP上的服务则对进来的数据库进行相应的处理，而后将处理结果回应至RIP，但数据包的原地址依然是VIP。
```



#### DR环境下Director脚本

```
#!/bin/bash
#

# LVS script for VS/DR

#
. /etc/rc.d/init.d/functions
#
VIP=192.168.1.200
RIP1=192.168.1.198
RIP2=192.168.1.197
PORT=80

#
case "$1" in
start)           

  /sbin/ifconfig eth0:0 $VIP broadcast $VIP netmask 255.255.255.255 up
  /sbin/route add -host $VIP dev eth0:0

# Since this is the Director we must be able to forward packets

  echo 1 > /proc/sys/net/ipv4/ip_forward

# Clear all iptables rules.

  /sbin/iptables -F

# Reset iptables counters.

  /sbin/iptables -Z

# Clear all ipvsadm rules/services.

  /sbin/ipvsadm -C

# Add an IP virtual service for VIP 192.168.0.219 port 80

# In this recipe, we will use the round-robin scheduling method. 

# In production, however, you should use a weighted, dynamic scheduling method. 

  /sbin/ipvsadm -A -t $VIP:80 -s wlc

# Now direct packets for this VIP to

# the real server IP (RIP) inside the cluster

  /sbin/ipvsadm -a -t $VIP:80 -r $RIP1 -g -w 1
  /sbin/ipvsadm -a -t $VIP:80 -r $RIP2 -g -w 2

  /bin/touch /var/lock/subsys/ipvsadm.lock &> /dev/null
;; 

stop)

# Stop forwarding packets

  echo 0 > /proc/sys/net/ipv4/ip_forward

# Reset ipvsadm

  /sbin/ipvsadm -C

# Bring down the VIP interface

  /sbin/ifconfig eth0:0 down
  /sbin/route del $VIP >& /dev/null
  /bin/rm -rf /var/lock/subsys/ipvsadm.lock >& /dev/null
  echo "ipvs is stopped..."
;;

status)
  if [ ! -e /var/lock/subsys/ipvsadm.lock ]; then
    echo "ipvsadm is stopped ..."
  else
    echo "ipvs is running ..."
  fi
;;
*)
  echo "Usage: $0 {start|stop|status}"
;;
esac
```



#### DR环境下RealServer脚本

```
#!/bin/bash
#

# Script to start LVS DR real server.

# description: LVS DR real server

#
.  /etc/rc.d/init.d/functions

VIP=192.168.1.200
host=`/bin/hostname`

case "$1" in
start)
       # Start LVS-DR real server on this machine.
        /sbin/ifconfig lo down
        /sbin/ifconfig lo up
        echo 1 > /proc/sys/net/ipv4/conf/lo/arp_ignore
        echo 2 > /proc/sys/net/ipv4/conf/lo/arp_announce
        echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
        echo 2 > /proc/sys/net/ipv4/conf/all/arp_announce

        /sbin/ifconfig lo:0 $VIP broadcast $VIP netmask 255.255.255.255 up
        /sbin/route add -host $VIP dev lo:0

;;
stop)

        # Stop LVS-DR real server loopback device(s).
        /sbin/ifconfig lo:0 down
        echo 0 > /proc/sys/net/ipv4/conf/lo/arp_ignore
        echo 0 > /proc/sys/net/ipv4/conf/lo/arp_announce
        echo 0 > /proc/sys/net/ipv4/conf/all/arp_ignore
        echo 0 > /proc/sys/net/ipv4/conf/all/arp_announce

;;
status)

        # Status of LVS-DR real server.
        islothere=`/sbin/ifconfig lo:0 | grep $VIP`
        isrothere=`netstat -rn | grep "lo" | grep $VIP`
        if [ ! "$islothere" -o ! "isrothere" ];then
            # Either the route or the lo:0 device
            # not found.
            echo "LVS-DR real server Stopped."
        else
            echo "LVS-DR real server Running."
        fi

;;
*)
            # Invalid entry.
            echo "$0: Usage: $0 {start|status|stop}"
            exit 1
;;
esac
```



#### RS健康状态检查脚本

```
#!/bin/bash
#
VIP=192.168.1.200
CPORT=80
FAIL_BACK=127.0.0.1
RS=("192.168.1.198" "192.168.1.197")
declare -a RSSTATUS
RW=("2" "1")
RPORT=80
TYPE=g
CHKLOOP=3
LOG=/var/log/ipvsmonitor.log

addrs() {
  ipvsadm -a -t $VIP:$CPORT -r $1:$RPORT -$TYPE -w $2
  [ $? -eq 0 ] && return 0 || return 1
}

delrs() {
  ipvsadm -d -t $VIP:$CPORT -r $1:$RPORT 
  [ $? -eq 0 ] && return 0 || return 1
}

checkrs() {
  local I=1
  while [ $I -le $CHKLOOP ]; do 
    if curl --connect-timeout 1 http://$1 &> /dev/null; then
      return 0
    fi
    let I++
  done
  return 1
}

initstatus() {
  local I
  local COUNT=0;
  for I in ${RS[*]}; do
    if ipvsadm -L -n | grep "$I:$RPORT" &> /dev/null ; then
      RSSTATUS[$COUNT]=1
    else 
      RSSTATUS[$COUNT]=0
    fi
  let COUNT++
  done
}

checklvslist() {
  /sbin/ipvsadm -ln | grep $1 &> /dev/null && return 0 || return 1
}

failback(){
  local SUM=0
  for n in ${RSSTATUS[*]} ; do
    let SUM=$SUM+$n
  done
  if [[ $SUM -eq 0 ]] && `checklvslist $FAIL_BACK;[ $? -eq 1 ]` ;then
    addrs $FAIL_BACK 1
    [ $? -eq 0 ] &&  echo "`date +'%F %H:%M:%S'`, RealServer is Down, $FAIL_BACK is back." >> $LOG
  elif [[ $SUM -ne 0 ]] && `checklvslist $FAIL_BACK;[ $? -eq 0 ]`; then
    delrs $FAIL_BACK
    [ $? -eq 0 ] &&  echo "`date +'%F %H:%M:%S'`, RealServer is Up, $FAIL_BACK is gone." >> $LOG
  fi
}

initstatus
while :; do
  let COUNT=0
  for I in ${RS[*]}; do
    if checkrs $I; then
      if [[ ${RSSTATUS[$COUNT]} -eq 0 ]] || [[ ${RSSTATUS[$COUNT]} -eq 1 ]] &&  `checklvslist $I;[ $? -eq 1 ]` ;then
         addrs $I ${RW[$COUNT]}
         [ $? -eq 0 ] && RSSTATUS[$COUNT]=1 && echo "`date +'%F %H:%M:%S'`, $I is back." >> $LOG
      fi
    else
      if [[ ${RSSTATUS[$COUNT]} -eq 1 ]] || [[ ${RSSTATUS[$COUNT]} -eq 0 ]] &&  `checklvslist $I;[ $? -eq 0 ]`; then
         delrs $I
         [ $? -eq 0 ] && RSSTATUS[$COUNT]=0 && echo "`date +'%F %H:%M:%S'`, $I is gone." >> $LOG
      fi
    fi
    let COUNT++
  done 
  failback
  sleep 5
done
```





### LVS持久连接
```
无论基于什么样的算法，只要期望源于同一个客户端的请求都由同一台Realserver响应时，就需要用到持久连接。比如，某一用户连续打开了三个telnet连接请求时，根据RR算法，其请求很可能会被分配至不同的Realserver，这通常不符合使用要求。
##DR模式脚本
无论使用算法，LVS持久都能实现在一定时间内，将来自同一个客户端请求派发至此前选定的RS。
	持久连接模板(内存缓冲区)：
		每一个客户端  及分配给它的RS的映射关系；
	ipvsadm -A|E ... -p timeout:
		timeout: 持久连接时长，默认300秒；单位是秒；
	在基于SSL，需要用到持久连接；
	PPC：将来自于同一个客户端对同一个集群服务的请求，始终定向至此前选定的RS；     持久端口连接
	PCC：将来自于同一个客户端对所有端口的请求，始终定向至此前选定的RS；           持久客户端连接
		把所有端口统统定义为集群服务，一律向RS转发；
	PNMPP：持久防火墙标记连接
#PPC
[root@lvs lvs]# ipvsadm -E -t 192.168.1.200:80 -s wlc -p 600  #设置持久连接时间为600秒，这个是PPC持久端口连接
[root@lvs lvs]# ipvsadm -L -n
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  192.168.1.200:80 wlc persistent 600
  -> 192.168.1.197:80             Route   2      0          0         
  -> 192.168.1.198:80             Route   1      0          0     
#PCC
[root@lvs lvs]# ipvsadm -A -t 192.168.1.200:0 -s rr -p 600
[root@lvs lvs]# ipvsadm -a -t 192.168.1.200:0 -r 192.168.1.198 -g -w 2
[root@lvs lvs]# ipvsadm -a -t 192.168.1.200:0 -r 192.168.1.197 -g -w 1
[root@lvs lvs]# ipvsadm -L -n 
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  192.168.1.200:0 rr persistent 600
  -> 192.168.1.197:0              Route   1      0          0         
  -> 192.168.1.198:0              Route   2      0          0    
#httpd2
[root@httpd2 lvs_RS]# yum install telnet-server -y
[root@httpd2 lvs_RS]# vim /etc/xinetd.d/telnet
disable		= no
[root@httpd2 lvs_RS]# /etc/init.d/xinetd start 
正在启动 xinetd：                                          [确定]
[root@httpd2 lvs_RS]# netstat -tunlp | grep 23
tcp        0      0 :::23                       :::*                        LISTEN      6410/xinetd
[root@httpd2 ~]# useradd hadoop
[root@httpd2 ~]# passwd hadoop
#httpd1
[root@httpd1 ~]# vim /etc/xinetd.d/telnet 
disable		= no
[root@httpd1 ~]# service xinetd start 
正在启动 xinetd：                                          [确定]
[root@httpd1 ~]# netstat -tunlp | grep 23
tcp        0      0 :::23                       :::*                        LISTEN      5636/xinetd         
[root@httpd1 ~]# useradd hadoop
[root@httpd1 ~]# passwd hadoop
[root@lvs lvs]# ipvsadm -l -n -c
IPVS connection entries
pro expire state       source             virtual            destination
TCP 08:34  NONE        192.168.1.101:0    192.168.1.200:0    192.168.1.197:0
#经过实践证明，同一个客户端访问80和23端口都会被定向到同一台服务器，这个就是PCC持久客户端连接
##防火墙标记
[root@lvs lvs]# iptables -t mangle -A PREROUTING -d 192.168.1.200 -i eth0 -p tcp --dport 80 -j MARK --set-mark 8
[root@lvs lvs]# iptables -t mangle -A PREROUTING -d 192.168.1.200 -i eth0 -p tcp --dport 23 -j MARK --set-mark 8
#给80和23端口打上同一个防火墙标记8
[root@lvs lvs]# ipvsadm -A -f 8 -s rr
[root@lvs lvs]# ipvsadm -a -f 8 -r 192.168.1.198 -w 2 -g
[root@lvs lvs]# ipvsadm -a -f 8 -r 192.168.1.197 -w 2 -g
[root@lvs lvs]# ipvsadm -ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
FWM  8 rr
  -> 192.168.1.197:0              Route   2      0          0         
  -> 192.168.1.198:0              Route   2      0          0         
#经过实践证明，同一个客户端访问80和23端口都会被定向到同一台服务器，这个就是防火墙标记将两个不相关的服务绑定在一起。
```



## lvs旧操作步骤

```
--环境
OS： Centos7
172.168.2.18 lvs01	keepalived01	role:DirectorServer01	sorryServer:127.0.0.1:80	VIP: 172.168.2.20(Master)
172.168.2.19 lvs02	keepalived02	role:DirectorServer02	sorryServer:127.0.0.1:80	VIP: 172.168.2.20(Backup)
172.168.2.15 nginx01 role:RealServer01
172.168.2.17 nginx02 role:RealServer02

##DR模型
##部署Director:
[root@lvs01 ~]# yum install -y ipvsadm
[root@lvs01 ~]# ifconfig eth0:0 172.168.2.20/32 broadcast 172.168.2.20 up
[root@lvs01 ~]# route add -host 172.168.2.20 dev eth0:0
[root@lvs01 ~]# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         172.168.2.254   0.0.0.0         UG    100    0        0 eth0
172.168.0.0     0.0.0.0         255.255.0.0     U     100    0        0 eth0
172.168.2.20    0.0.0.0         255.255.255.255 UH    0      0        0 eth0
[root@lvs01 ~]# ifconfig
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 172.168.2.18  netmask 255.255.0.0  broadcast 172.168.255.255
        ether 00:0c:29:dc:4c:18  txqueuelen 1000  (Ethernet)
        RX packets 279107  bytes 200895653 (191.5 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 79624  bytes 5340452 (5.0 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

eth0:0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 172.168.2.20  netmask 0.0.0.0  broadcast 172.168.2.20
        ether 00:0c:29:dc:4c:18  txqueuelen 1000  (Ethernet)

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 632  bytes 55604 (54.3 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 632  bytes 55604 (54.3 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0


##部署Realserver01:
[root@nginx01 ~]# vim /etc/sysctld/lvs.conf
net.ipv4.conf.eth0.arp_ignore = 1
net.ipv4.conf.eth0.arp_announce = 2
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 2
[root@nginx01 ~]# sysctl --system 
[root@nginx01 ~]# sysctl -a | grep -E 'arp_ignore|arp_announce'
net.ipv4.conf.all.arp_announce = 2
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.default.arp_announce = 0
net.ipv4.conf.default.arp_ignore = 0
net.ipv4.conf.eth0.arp_announce = 2
net.ipv4.conf.eth0.arp_ignore = 1
net.ipv4.conf.lo.arp_announce = 0
net.ipv4.conf.lo.arp_ignore = 0
[root@nginx01 ~]# ifconfig lo:0 172.168.2.20 netmask 255.255.255.255 broadcast 172.168.2.20 up
[root@nginx01 ~]# route add -host 172.168.2.20 dev lo:0
[root@nginx01 ~]# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         172.168.2.254   0.0.0.0         UG    100    0        0 eth0
172.168.2.0     0.0.0.0         255.255.255.0   U     100    0        0 eth0
172.168.2.20    0.0.0.0         255.255.255.255 UH    0      0        0 lo


##部署Realserver02:
[root@nginx02 ~]# vim /etc/sysctld/lvs.conf
net.ipv4.conf.eth0.arp_ignore = 1
net.ipv4.conf.eth0.arp_announce = 2
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 2
[root@nginx02 ~]# sysctl --system 
[root@nginx02 ~]# sysctl -a | grep -E 'arp_ignore|arp_announce'
net.ipv4.conf.all.arp_announce = 2
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.default.arp_announce = 0
net.ipv4.conf.default.arp_ignore = 0
net.ipv4.conf.eth0.arp_announce = 2
net.ipv4.conf.eth0.arp_ignore = 1
net.ipv4.conf.lo.arp_announce = 0
net.ipv4.conf.lo.arp_ignore = 0
[root@nginx02 ~]# ifconfig lo:0 172.168.2.20 netmask 255.255.255.255 broadcast 172.168.2.20 up
[root@nginx02 ~]# route add -host 172.168.2.20 dev lo:0
[root@nginx02 ~]# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         172.168.2.254   0.0.0.0         UG    100    0        0 eth0
172.168.2.0     0.0.0.0         255.255.255.0   U     100    0        0 eth0
172.168.2.20    0.0.0.0         255.255.255.255 UH    0      0        0 lo

##Director上进行ipvsadm操作
[root@lvs01 ~]# ipvsadm -C
[root@lvs01 ~]# ipvsadm -A -t 172.168.2.20:80 -s wlc
[root@lvs01 ~]# ipvsadm -a -t 172.168.2.20:80 -r 172.168.2.15 -g -w 3
[root@lvs01 ~]# ipvsadm -a -t 172.168.2.20:80 -r 172.168.2.17 -g -w 1
[root@lvs01 ~]# ipvsadm -ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  172.168.2.20:80 wlc
  -> 172.168.2.15:80              Route   3      1          0
  -> 172.168.2.17:80              Route   1      1          0
[root@lvs01 ~]# ipvsadm -lcn
IPVS connection entries
pro expire state       source             virtual            destination
TCP 14:37  ESTABLISHED 172.168.2.219:50658 172.168.2.20:80    172.168.2.17:80
TCP 14:47  ESTABLISHED 172.168.2.219:50659 172.168.2.20:80    172.168.2.15:80
--为了保证其时效性，Hash table中“连接追踪”信息被定义了“生存时间”。LVS为记录“连接超时”定义了三个计时器：
	1、空闲TCP会话；
	2、客户端正常断开连接后的TCP会话；
	3、无连接的UDP数据包（记录其两次发送数据包的时间间隔）；
上面三个计时器的默认值可以由类似下面的命令修改，其后面的值依次对应于上述的三个计时器：
# ipvsadm --set 28800 30 600
```





## LVS+keepalived+nginx高可用-主备

```
环境：
OS： Centos7
172.168.2.18 lvs01	keepalived01	role:DirectorServer01	sorryServer:127.0.0.1:80	VIP: 172.168.2.20(Master)
172.168.2.19 lvs02	keepalived02	role:DirectorServer02	sorryServer:127.0.0.1:80	VIP: 172.168.2.20(Backup)
172.168.2.15 nginx01 role:RealServer01
172.168.2.17 nginx02 role:RealServer02

#安装keepalived01
[root@lvs01 ~]# curl -sSfL -O https://www.keepalived.org/software/keepalived-2.0.20.tar.gz
[root@lvs01 ~]# tar xf keepalived-2.0.20.tar.gz
[root@lvs01 ~]# cd keepalived-2.0.20/
[root@lvs01 ~/keepalived-2.0.20]# ls
aclocal.m4  AUTHOR       build_setup  compile    configure.ac  COPYING  doc      INSTALL     keepalived          lib          Makefile.in  README.md  TODO
ar-lib      bin_install  ChangeLog    configure  CONTRIBUTORS  depcomp  genhash  install-sh  keepalived.spec.in  Makefile.am  missing      snap
[root@lvs01 ~/keepalived-2.0.20]# ./configure --prefix=/usr/local/keepalived --sysconf=/etc

Keepalived configuration
------------------------

Keepalived version       : 2.0.20
Compiler                 : gcc
Preprocessor flags       : -D_GNU_SOURCE
Compiler flags           : -g -g -O2 -Wall -Wextra -Wunused -Wstrict-prototypes -Wbad-function-cast -Wcast-align -Wcast-qual -Wdisabled-optimization -Wdouble-promotion -Wfloat-equal -Wformat-security -Wframe-larger-than=5120 -Winit-self -Winline -Wjump-misses-init -Wlogical-op -Wmissing-declarations -Wmissing-field-initializers -Wmissing-prototypes -Wnested-externs -Wold-style-definition -Woverlength-strings -Wpointer-arith -Wredundant-decls -Wshadow -Wstack-protector -Wstrict-overflow=4 -Wstrict-prototypes -Wsuggest-attribute=const -Wsuggest-attribute=format -Wsuggest-attribute=noreturn -Wsuggest-attribute=pure -Wsync-nand -Wtrampolines -Wundef -Wuninitialized -Wunknown-pragmas -Wunsuffixed-float-constants -Wunused-macros -Wvariadic-macros -Wwrite-strings -fPIE -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -O2
Linker flags             : -pie -Wl,-z,relro -Wl,-z,now
Extra Lib                : -lm -lcrypto -lssl
Use IPVS Framework       : Yes
IPVS use libnl           : No
IPVS syncd attributes    : No
IPVS 64 bit stats        : No
HTTP_GET regex support   : No
fwmark socket support    : Yes
Use VRRP Framework       : Yes
Use VRRP VMAC            : Yes
Use VRRP authentication  : Yes
With ip rules/routes     : Yes
With track_process       : Yes
With linkbeat            : Yes
Use BFD Framework        : No
SNMP vrrp support        : No
SNMP checker support     : No
SNMP RFCv2 support       : No
SNMP RFCv3 support       : No
DBUS support             : No
SHA1 support             : No
Use JSON output          : No
libnl version            : None
Use IPv4 devconf         : No
Use iptables             : Yes
Use libiptc              : No
Use libipset             : No
Use nftables             : No
init type                : systemd
Strict config checks     : No
Build genhash            : Yes
Build documentation      : No
[root@lvs01 ~/keepalived-2.0.20]# make && make install
[root@lvs01 ~/keepalived-2.0.20]# cp keepalived/etc/init.d/keepalived /etc/init.d/
[root@lvs01 ~/keepalived-2.0.20]# \cp keepalived/etc/sysconfig/keepalived /etc/sysconfig/
[root@lvs01 ~/keepalived-2.0.20]# systemctl daemon-reload
[root@lvs01 ~/keepalived-2.0.20]# systemctl start keepalived.service
[root@lvs01 ~/keepalived-2.0.20]# systemctl enable keepalived.service
#安装lvs01
[root@lvs01 ~]# yum install -y ipvsadm
#配置keepalived01，使其调用ipvs模块，实现keepalived+lvs功能

[root@lvs01 ~]# cat /etc/keepalived/keepalived.conf
-------------------------

global_defs {
   router_id LVS01
}

vrrp_instance LVS_HA {
    state MASTER
    interface eth0
    virtual_router_id 100
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass uGLGQp5gVyYzCuKI
    }
    virtual_ipaddress {
        172.168.2.20
    }
}

virtual_server 172.168.2.20 80 {
    delay_loop 5
    lb_algo rr
    lb_kind DR
    persistence_timeout 5
    protocol TCP

    sorry_server 127.0.0.1 80
    
    real_server 172.168.2.15 80 {
        weight 1
        TCP_CHECK {
            connect_port 80
            connect_timeout 2		!超时时间为connect_timeout + retry * delay_before_retry = 5秒
            retry 3
            delay_before_retry 1
        }
    }
    
    real_server 172.168.2.17 80 {
        weight 1
        TCP_CHECK {
            connect_port 80
            connect_timeout 1
            retry 3
            delay_before_retry 1
        }
    }

}
-------------------------

#安装keepalived02
[root@lvs02 ~]# curl -sSfL -O https://www.keepalived.org/software/keepalived-2.0.20.tar.gz
[root@lvs02 ~]# tar xf keepalived-2.0.20.tar.gz
[root@lvs02 ~]# cd keepalived-2.0.20/
[root@lvs02 ~/keepalived-2.0.20]# ls
aclocal.m4  AUTHOR       build_setup  compile    configure.ac  COPYING  doc      INSTALL     keepalived          lib          Makefile.in  README.md  TODO
ar-lib      bin_install  ChangeLog    configure  CONTRIBUTORS  depcomp  genhash  install-sh  keepalived.spec.in  Makefile.am  missing      snap
[root@lvs02 ~/keepalived-2.0.20]# ./configure --prefix=/usr/local/keepalived --sysconf=/etc
[root@lvs02 ~/keepalived-2.0.20]# make && make install
[root@lvs02 ~/keepalived-2.0.20]# cp keepalived/etc/init.d/keepalived /etc/init.d/
[root@lvs02 ~/keepalived-2.0.20]# \cp keepalived/etc/sysconfig/keepalived /etc/sysconfig/
[root@lvs02 ~/keepalived-2.0.20]# systemctl daemon-reload
[root@lvs02 ~/keepalived-2.0.20]# systemctl start keepalived.service
[root@lvs02 ~/keepalived-2.0.20]# systemctl enable keepalived.service
#安装lvs02
[root@lvs02 ~]# yum install -y ipvsadm

#配置keepalived02，使其调用ipvs模块，实现keepalived+lvs功能
------------------------

[root@lvs02 ~]# cat /etc/keepalived/keepalived.conf
global_defs {
   router_id LVS02
}

vrrp_instance LVS_HA {
    state BACKUP
    interface eth0
    virtual_router_id 100
    priority 90
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass uGLGQp5gVyYzCuKI
    }
    virtual_ipaddress {
        172.168.2.20
    }
}

virtual_server 172.168.2.20 80 {
    delay_loop 5
    lb_algo rr
    lb_kind DR
    persistence_timeout 5
    protocol TCP

    sorry_server 127.0.0.1 80
    
    real_server 172.168.2.15 80 {
        weight 1
        TCP_CHECK {
            connect_port 80
            connect_timeout 2
            retry 3
            delay_before_retry 1
        }
    }
    
    real_server 172.168.2.17 80 {
        weight 1
        TCP_CHECK {
            connect_port 80
            connect_timeout 1
            retry 3
            delay_before_retry 1
        }
    }

}
------------------------

注：172.168.2.15、172.168.2.17上已编译安装nginx，这里省略安装
#用ipvsadm上下线realserver
[root@lvs01 ~]# ipvsadm -ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  172.168.2.20:80 rr persistent 5
  -> 172.168.2.15:80              Route   1      0          0
  -> 172.168.2.17:80              Route   1      0          10

[root@lvs01 ~]# ipvsadm -d -t 172.168.2.20:80 -r 172.168.2.17:80	--手动删除一个RealServer
[root@lvs01 ~]# ipvsadm -ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  172.168.2.20:80 rr persistent 5
  -> 172.168.2.15:80              Route   1      0          4

[root@lvs01 ~]# ipvsadm -a -t 172.168.2.20:80 -r 172.168.2.17:80 -w 10 && ipvsadm -d -t 172.168.2.20:80 -r 172.168.2.15:80
[root@lvs01 ~]# ipvsadm -ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  172.168.2.20:80 rr persistent 5
  -> 172.168.2.17:80              Route   10     0          25

[root@lvs01 ~]# ipvsadm -a -t 172.168.2.20:80 -r 172.168.2.15:80 && ipvsadm -d -t 172.168.2.20:80 -r 172.168.2.17:80
[root@lvs01 ~]# ipvsadm -ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  172.168.2.20:80 rr persistent 5
  -> 172.168.2.15:80              Route   1      0          103

[root@lvs01 ~]# ipvsadm -a -t 172.168.2.20:80 -r 172.168.2.17:80	--手动添加一个RealServer
[root@lvs02 ~]# ipvsadm -ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  172.168.2.20:80 rr persistent 5
  -> 172.168.2.15:80              Route   1      0          0
  -> 172.168.2.17:80              Route   1      0          0
# 更改keepalived配置文件上下线realserver
[root@lvs02 ~]# vim /etc/keepalived/keepalived.conf
:.,+8s/^/#/g	--注释特定realserver配置段
[root@lvs02 ~]# systemctl reload keepalived.service
[root@lvs02 ~]# vim /etc/keepalived/keepalived.conf
:.,+8s/^#//g	--取消特定注释realserver配置段
[root@lvs02 ~]# systemctl reload keepalived.service
```



## keepalived从主备变成主主模式

```
环境：
OS： Centos7
172.168.2.18 lvs01	keepalived01	role:DirectorServer01	sorryServer:127.0.0.1:80	VIP1: 172.168.2.20(Master)	VIP2: 172.168.2.21(Backup)
172.168.2.19 lvs02	keepalived02	role:DirectorServer02	sorryServer:127.0.0.1:80	VIP1: 172.168.2.20(Backup)	VIP2: 172.168.2.21(Master)
172.168.2.15 nginx01 role:RealServer01
172.168.2.17 nginx02 role:RealServer02
#keepalived01配置变更如下：

[root@lvs01 ~]# cat /etc/keepalived/keepalived.conf
---------------------

global_defs {
   router_id LVS01
}

vrrp_instance LVS_HA1 {
    state MASTER
    interface eth0
    virtual_router_id 100
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass uGLGQp5gVyYzCuKI
    }
    virtual_ipaddress {
        172.168.2.20
    }
}

virtual_server 172.168.2.20 80 {
    delay_loop 5
    lb_algo rr
    lb_kind DR
    persistence_timeout 5
    protocol TCP

    sorry_server 127.0.0.1 80
    
    real_server 172.168.2.15 80 {
        weight 1
        TCP_CHECK {
            connect_port 80
            connect_timeout 2
            retry 3
            delay_before_retry 1
        }
    }
    
    real_server 172.168.2.17 80 {
        weight 1
        TCP_CHECK {
            connect_port 80
            connect_timeout 1
            retry 3
            delay_before_retry 1
        }
    }

}

vrrp_instance LVS_HA2 {
    state BACKUP
    interface eth0
    virtual_router_id 101
    priority 90
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 56smW6IWMHSJNwb3
    }
    virtual_ipaddress {
        172.168.2.21
    }
}

virtual_server 172.168.2.21 80 {
    delay_loop 5
    lb_algo rr
    lb_kind DR
    persistence_timeout 5
    protocol TCP

    sorry_server 127.0.0.1 80
    
    real_server 172.168.2.15 80 {
        weight 1
        TCP_CHECK {
            connect_port 80
            connect_timeout 2
            retry 3
            delay_before_retry 1
        }
    }
    
    real_server 172.168.2.17 80 {
        weight 1
        TCP_CHECK {
            connect_port 80
            connect_timeout 1
            retry 3
            delay_before_retry 1
        }
    }

}
---------------------

#keepalived02配置变更如下：
---------------------

[root@lvs02 ~]# cat /etc/keepalived/keepalived.conf
global_defs {
   router_id LVS02
}

vrrp_instance LVS_HA {
    state BACKUP
    interface eth0
    virtual_router_id 100
    priority 90
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass uGLGQp5gVyYzCuKI
    }
    virtual_ipaddress {
        172.168.2.20
    }
}

virtual_server 172.168.2.20 80 {
    delay_loop 5
    lb_algo rr
    lb_kind DR
    persistence_timeout 5
    protocol TCP

    sorry_server 127.0.0.1 80
    
    real_server 172.168.2.15 80 {
        weight 1
        TCP_CHECK {
            connect_port 80
            connect_timeout 2
            retry 3
            delay_before_retry 1
        }
    }
    
    real_server 172.168.2.17 80 {
        weight 1
        TCP_CHECK {
            connect_port 80
            connect_timeout 1
            retry 3
            delay_before_retry 1
        }
    }

}

vrrp_instance LVS_HA2 {
    state MASTER
    interface eth0
    virtual_router_id 101
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 56smW6IWMHSJNwb3
    }
    virtual_ipaddress {
        172.168.2.21
    }
}

virtual_server 172.168.2.21 80 {
    delay_loop 5
    lb_algo rr
    lb_kind DR
    persistence_timeout 5
    protocol TCP

    sorry_server 127.0.0.1 80
    
    real_server 172.168.2.15 80 {
        weight 1
        TCP_CHECK {
            connect_port 80
            connect_timeout 2
            retry 3
            delay_before_retry 1
        }
    }
    
    real_server 172.168.2.17 80 {
        weight 1
        TCP_CHECK {
            connect_port 80
            connect_timeout 1
            retry 3
            delay_before_retry 1
        }
    }

}
---------------------

#所有realserver服务器需要增加配置VIP地址在新接口上
[root@nginx01 ~]# ifconfig lo:1 172.168.2.21 netmask 255.255.255.255 broadcast 172.168.2.21 up
[root@nginx01 ~]# route add -host 172.168.2.21 dev lo:1
[root@nginx02 ~]# ifconfig lo:1 172.168.2.21 netmask 255.255.255.255 broadcast 172.168.2.21 up
[root@nginx02 ~]# route add -host 172.168.2.21 dev lo:1
或
[root@nginx01 ~]# cat /etc/sysconfig/network-scripts/ifcfg-lo:0
DEVICE=lo:0
IPADDR=172.168.2.20
NETMASK=255.255.255.255
BROADCAST=172.168.2.20
ONBOOT=yes
[root@nginx01 ~]# cat /etc/rc.d/rc.local
#!/bin/bash
touch /var/lock/subsys/local
route add -host 172.168.2.20 dev lo:0

[root@nginx02 ~]# cat /etc/sysconfig/network-scripts/ifcfg-lo:0
DEVICE=lo:0
IPADDR=172.168.2.20
NETMASK=255.255.255.255
BROADCAST=172.168.2.20
ONBOOT=yes
[root@nginx02 ~]# cat /etc/rc.d/rc.local
#!/bin/bash
touch /var/lock/subsys/local
route add -host 172.168.2.20 dev lo:0


###lvs调优
1.1调整ipvs connection hash表的大小
IPVS connection hash table size，取值范围:[12,20]。该表用于记录每个进来的连接及路由去向的信息。连接的Hash表要容纳几百万个并发连接，任何一个报文到达都需要查找连接Hash表。Hash表的查找复杂度为O(n/m)，其中n为Hash表中对象的个数，m为Hash表的桶个数。当对象在Hash表中均匀分布和Hash表的桶个数与对象个数一样多时，Hash表的查找复杂度可以接近O(1)。
LVS的调优建议将hash table的值设置为不低于并发连接数。例如，并发连接数为200，Persistent时间为200S，那么hash桶的个数应设置为尽可能接近200x200=40000，2的15次方为32768就可以了。当ip_vs_conn_tab_bits=20 时，哈希表的的大小（条目）为 pow(2,20)，即 1048576，对于64位系统，IPVS占用大概16M内存，可以通过demsg看到：IPVS: Connection hash table configured (size=1048576, memory=16384Kbytes)。对于现在的服务器来说，这样的内存占用不是问题。所以直接设置为20即可。
关于最大“连接数限制”：这里的hash桶的个数，并不是LVS最大连接数限制。LVS使用哈希链表解决“哈希冲突”，当连接数大于这个值时，必然会出现哈稀冲突，会（稍微）降低性能，但是并不对在功能上对LVS造成影响。
[root@lvs01 ~]# dmesg | grep IPVS
[   16.052228] IPVS: Connection hash table configured (size=4096, memory=64Kbytes)

1.2调整 ip_vs_conn_tab_bits的方法：
新的IPVS代码，允许调整 ip_vs_conn_bits 的值。而老的IPVS代码则需要通过重新编译来调整。在发行版里，IPVS通常是以模块的形式编译的。确认能否调整使用命令 modinfo -p ip_vs（查看 ip_vs 模块的参数），看有没有 conn_tab_bits 参数可用。
[root@lvs01 ~]# modinfo -p ip_vs
conn_tab_bits:Set connections' hash size (int)
假如可以用，那么说是可以调整，调整方法是加载时通过设置 conn_tab_bits参数。在/etc/modprobe.d/目录下添加文件ip_vs.conf，内容为：
options ip_vs conn_tab_bits=20
ipvsadm -l	--查看，如果显示IP Virtual Server version 1.2.1 (size=4096)，则前面加的参数没有生效
reboot	--重新启动服务器进行加载
[root@lvs01 ~]# ipvsadm -ln
IP Virtual Server version 1.2.1 (size=1048576)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  172.168.2.20:80 rr persistent 5
  -> 172.168.2.15:80              Route   1      0          0
  -> 172.168.2.17:80              Route   1      0          0

1.3尽量避免sh算法
一些业务为了支持会话保持，选择SH调度算法，以实现 同一源ip的请求调度到同一台RS上；但SH算法根本没有实现一致性hash，一旦一台RS down，当前所有连接都会断掉；如果配置了inhibit_on_failure，那就更悲剧了，调度到该RS上的流量会一直损失；
实际线上使用时，如需 会话保持，建议配置 persistence_timeout参数，保证一段时间同一源ip的请求到同一RS上
```

