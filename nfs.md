#NFS
<pre>
nfs服务端： 
1，使用yum -y install nfs-utils     #因为centos7自带了rpcbind，所以不用安装rpc服务，rpc监听在111端口，可以使用ss -tnulp | grep 111查看rpc服务是否自动启动，如果没有启动，就systemctl start rpcbind 启动rpc服务。rpc在nfs服务器搭建过程中至关重要，因为rpc能够获得nfs服务器端的端口号等信息，nfs客户器端通过rpc获得这些信息后才能连接nfs服务器端。
2，使用 rpm -qa | grep nfs-utils 查看是否安装成功，
3，编辑/etc/exports ，添加以下内容           
/data    192.168.1.0/24(rw,async)
或   
/home/nfs/ 192.168.248.0/24(rw,sync,fsid=0)
同192.168.248.0/24一个网络号的主机可以挂载NFS服务器上的/home/nfs/目录到自己的文件系统中
rw表示可读写；sync表示同步写，fsid=0表示将/data找个目录包装成根目录
4,启动nfs服务，systemctl start nfs ,启动后 使用rpcinfo -p localhost查看
[root@salt-server ~]# rpcinfo -p localhost
   program vers proto   port  service
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    100000    3   udp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  44593  status
    100024    1   tcp   7058  status
    100005    1   udp  20048  mountd
    100005    1   tcp  20048  mountd
    100005    2   udp  20048  mountd
    100005    2   tcp  20048  mountd
    100005    3   udp  20048  mountd
    100005    3   tcp  20048  mountd
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100227    3   tcp   2049  nfs_acl
    100003    3   udp   2049  nfs
    100003    4   udp   2049  nfs
    100227    3   udp   2049  nfs_acl
    100021    1   udp  42533  nlockmgr
    100021    3   udp  42533  nlockmgr
    100021    4   udp  42533  nlockmgr
    100021    1   tcp  18681  nlockmgr
    100021    3   tcp  18681  nlockmgr
    100021    4   tcp  18681  nlockmgr
5，使用showmount -e localhost查看/etc/exports文件列表
6，[root@salt-server ~]# mkdir /data
     [root@salt-server ~]# echo hello,nfs > /data/1.txt
     [root@salt-server ~]# chown -R nfsnobody:nfsnobody /data

Linux客户端：
[root@Linux-node1-salt mnt]# yum install nfs-utils
rpc运行并开机启动，nfs客户端不用启动服务。
mount -t nfs 192.168.1.235:/data /mnt   挂载NFS
[root@Linux-node1-salt /]# cat /etc/rc.local
mount -t nfs 192.168.1.235:/nfs /mnt
我们需要把挂载命令放在rc.local里面，
我们不要把挂载命令放在fstab，因为fstab比网络先启动，会出现挂载不上网络NFS 

windows客户端：
1. 安装windows nfs客户端
2. C:\Users\Jackli>mount 192.168.1.235:/nfs/ z:
z: 现已成功连接到 192.168.1.235:/nfs/
命令已成功完成。
问题：挂载后无写入权限
解决办法：就是让Win7在挂载NFS的时候将UID和GID改成0即可：打开注册表找到：HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default，给其中增加两项：AnonymousUid，AnonymousGid



</pre>