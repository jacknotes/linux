#harpoxy
nginx优势之一，代理至后端服务器是异步的，可以减少后端服务器的压力
haproxy:工作在四层和七层的反向代理服务器，可以对http和tcp进行反向代理
lvs：工作在内核空间的，而nginx和haproxy是工作在用户空间的
并发量最大的是lvs，比nginx和haproxy多。转发能力haproxy不如lvs，但比nginx好一点，但耗资源。
haproxy基于事件驱动的，是单进程的，支持非常大的并发连接数
haproxy可以基于url来调度至缓存服务器，提高缓存命中率，这是使用haproxy的一个重要原因
haproxy1.4版本是基于1.2而来的，haproxy1.3也是基于1.2而来的，现在企业用得最多的是haproxy1.4版本。
O(1)：是从运行任意挑出一个进程来检测运行时间是否和其他进程运行时间一样的。如果为一样说明可以达到O(1)标准。O(log(N))是仅次于O(1)标准
HAproxy优点：
	1. 单进程、事件驱动模型显示降低了上下文切换的开销及内存占用。
	2. O(1)事件检查器（event check）允许其在高并发连接中对任何连接的任何事件实现即时探测。
	3. 在任何可用的情况下，单缓冲机制能以不复制 任何数据的方式完成读写操作。这会节约大量的CPU时钟周期及内存带宽。
	4. 借用于Linux2.6
三个因素来评估负载均衡器的性能：
	1. 会话率
	2. 会话并发能力
	3. 数据率

#配置HAproxy
1. 配置文件格式：
	HAproxy的配置处理3类主要参数来源：
		1. 最优先处理的命令行参数
		2. "global"配置段，用于设定全局配置参数。[又包括进程设置段，进程调优段]
		3. proxy相关配置段，如"defaults"、"listen"、"frontend"、"backend"
2. 时间格式：
	1. us:微秒，即1/1000000秒
	2. ms:毫秒，即1/1000秒
	3. s:秒
	4. m:分钟
	5. h:小时
	6. d:天
3. 配置例子：
	global
		daemon  #后台运行
		maxconn 25600  #最大支持的连接数
	defaults
		mode http
		timeout connect 5000ms  #连接的超时时间
		timeout client 50000ms  #与客户端的超时时间
		timeout server 50000ms  #与服务器的超时时间
	frontend http-in
		bind *:80  #绑定本地的端口
		default_backend servers #默认后端服务器为哪台
	backend servers
		server server1 127.0.0.1:8080 maxconn 1000  #设定后端服务器server1的地址及最大连接数
#注：listen和frontend、backend只能选择其一。

blance:只能用于defaults,listen,backend段，不能用于frontend段，定义负载均衡
bind:只能用于frontend和listen当中，用于定义一个或几个监听的套接字上
mode:tcp,http,health(已经被弃用)，设定运行的模式或协议，前后端必须处于同一种协议
hash-type:有map-based和consistend（树状一致性hash,而memcached使用的是环形hash）,用得最多的是map-based
log:为每个实例启用事件和流量日志，可用于所有区段中使用。
maxconn:前端的最大并发连接数
default_backend:默认的后端
server:为后端声明一个server,此用用于listen和backend段
redir:启用重定向
stats enable#开启状态GUI接口的
stats hide-version#隐藏其版本号
stats uri#定义访问路径
stats auth#定义认证用户和密码
stats admin#用户在GUI断开后端服务器的，但必须满足某些条件，stats admin if LOCALHOST | stats admin if TRUE时才可以开启
option forwardfor #用户转发客户端远程地址到后端服务器的
error-file 400 /etc/haproxy/errorpages/400badreq.http#用于定义错误文件返回


##配置安装haproxy
[root@lamp-zabbix ~]# yum install haproxy -y
[root@lamp-zabbix ~]# rpm -ql haproxy
/etc/haproxy
/etc/haproxy/haproxy.cfg
/etc/logrotate.d/haproxy
/etc/sysconfig/haproxy
/usr/bin/halog
/usr/bin/iprange
/usr/lib/systemd/system/haproxy.service
/usr/sbin/haproxy
/usr/sbin/haproxy-systemd-wrapper
/usr/share/doc/haproxy-1.5.18
/usr/share/doc/haproxy-1.5.18/CHANGELOG
/usr/share/doc/haproxy-1.5.18/LICENSE
/usr/share/doc/haproxy-1.5.18/README
/usr/share/doc/haproxy-1.5.18/ROADMAP
/usr/share/doc/haproxy-1.5.18/VERSION
/usr/share/doc/haproxy-1.5.18/acl.fig
/usr/share/doc/haproxy-1.5.18/architecture.txt
/usr/share/doc/haproxy-1.5.18/close-options.txt
/usr/share/doc/haproxy-1.5.18/coding-style.txt
/usr/share/doc/haproxy-1.5.18/configuration.txt
/usr/share/doc/haproxy-1.5.18/cookie-options.txt
/usr/share/doc/haproxy-1.5.18/design-thoughts
/usr/share/doc/haproxy-1.5.18/design-thoughts/backends-v0.txt
/usr/share/doc/haproxy-1.5.18/design-thoughts/backends.txt
/usr/share/doc/haproxy-1.5.18/design-thoughts/be-fe-changes.txt
/usr/share/doc/haproxy-1.5.18/design-thoughts/binding-possibilities.txt
/usr/share/doc/haproxy-1.5.18/design-thoughts/buffer-redesign.txt
/usr/share/doc/haproxy-1.5.18/design-thoughts/buffers.fig
/usr/share/doc/haproxy-1.5.18/design-thoughts/config-language.txt
/usr/share/doc/haproxy-1.5.18/design-thoughts/connection-reuse.txt
/usr/share/doc/haproxy-1.5.18/design-thoughts/cttproxy-changes.txt
/usr/share/doc/haproxy-1.5.18/design-thoughts/entities-v2.txt
/usr/share/doc/haproxy-1.5.18/design-thoughts/how-it-works.txt
/usr/share/doc/haproxy-1.5.18/design-thoughts/http_load_time.url
/usr/share/doc/haproxy-1.5.18/design-thoughts/rate-shaping.txt
/usr/share/doc/haproxy-1.5.18/design-thoughts/sess_par_sec.txt
/usr/share/doc/haproxy-1.5.18/examples
/usr/share/doc/haproxy-1.5.18/examples/acl-content-sw.cfg
/usr/share/doc/haproxy-1.5.18/examples/auth.cfg
/usr/share/doc/haproxy-1.5.18/examples/build.cfg
/usr/share/doc/haproxy-1.5.18/examples/content-sw-sample.cfg
/usr/share/doc/haproxy-1.5.18/examples/cttproxy-src.cfg
/usr/share/doc/haproxy-1.5.18/examples/examples.cfg
/usr/share/doc/haproxy-1.5.18/examples/haproxy.cfg
/usr/share/doc/haproxy-1.5.18/examples/option-http_proxy.cfg
/usr/share/doc/haproxy-1.5.18/examples/ssl.cfg
/usr/share/doc/haproxy-1.5.18/examples/tarpit.cfg
/usr/share/doc/haproxy-1.5.18/examples/test-section-kw.cfg
/usr/share/doc/haproxy-1.5.18/examples/transparent_proxy.cfg
/usr/share/doc/haproxy-1.5.18/examples/url-switching.cfg
/usr/share/doc/haproxy-1.5.18/gpl.txt
/usr/share/doc/haproxy-1.5.18/haproxy-en.txt
/usr/share/doc/haproxy-1.5.18/haproxy-fr.txt
/usr/share/doc/haproxy-1.5.18/haproxy.1
/usr/share/doc/haproxy-1.5.18/internals
/usr/share/doc/haproxy-1.5.18/internals/acl.txt
/usr/share/doc/haproxy-1.5.18/internals/body-parsing.txt
/usr/share/doc/haproxy-1.5.18/internals/buffer-operations.txt
/usr/share/doc/haproxy-1.5.18/internals/buffer-ops.fig
/usr/share/doc/haproxy-1.5.18/internals/connect-status.txt
/usr/share/doc/haproxy-1.5.18/internals/connection-header.txt
/usr/share/doc/haproxy-1.5.18/internals/connection-scale.txt
/usr/share/doc/haproxy-1.5.18/internals/entities.fig
/usr/share/doc/haproxy-1.5.18/internals/entities.pdf
/usr/share/doc/haproxy-1.5.18/internals/entities.svg
/usr/share/doc/haproxy-1.5.18/internals/entities.txt
/usr/share/doc/haproxy-1.5.18/internals/hashing.txt
/usr/share/doc/haproxy-1.5.18/internals/header-parser-speed.txt
/usr/share/doc/haproxy-1.5.18/internals/header-tree.txt
/usr/share/doc/haproxy-1.5.18/internals/http-cookies.txt
/usr/share/doc/haproxy-1.5.18/internals/http-docs.txt
/usr/share/doc/haproxy-1.5.18/internals/http-parsing.txt
/usr/share/doc/haproxy-1.5.18/internals/naming.txt
/usr/share/doc/haproxy-1.5.18/internals/pattern.dia
/usr/share/doc/haproxy-1.5.18/internals/pattern.pdf
/usr/share/doc/haproxy-1.5.18/internals/polling-states.fig
/usr/share/doc/haproxy-1.5.18/internals/repartition-be-fe-fi.txt
/usr/share/doc/haproxy-1.5.18/internals/sequence.fig
/usr/share/doc/haproxy-1.5.18/internals/stats-v2.txt
/usr/share/doc/haproxy-1.5.18/internals/stream-sock-states.fig
/usr/share/doc/haproxy-1.5.18/internals/todo.cttproxy
/usr/share/doc/haproxy-1.5.18/lgpl.txt
/usr/share/doc/haproxy-1.5.18/proxy-protocol.txt
/usr/share/doc/haproxy-1.5.18/queuing.fig
/usr/share/haproxy
/usr/share/haproxy/400.http
/usr/share/haproxy/403.http
/usr/share/haproxy/408.http
/usr/share/haproxy/500.http
/usr/share/haproxy/502.http
/usr/share/haproxy/503.http
/usr/share/haproxy/504.http
/usr/share/haproxy/README
/usr/share/man/man1/halog.1.gz
/usr/share/man/man1/haproxy.1.gz
/var/lib/haproxy
[root@lamp-zabbix ~]# cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak
[root@lamp-zabbix ~]# vim /etc/haproxy/haproxy.cfg 
# to have these messages end up in /var/log/haproxy.log you will
    # need to:
    #
    # 1) configure syslog to accept network log events.  This is done
    #    by adding the '-r' option to the SYSLOGD_OPTIONS in
    #    /etc/sysconfig/syslog
    #
    # 2) configure local2 events to go to the /var/log/haproxy.log
    #   file. A line like the following can be added to
    #   /etc/sysconfig/syslog
    #
    #    local2.*                       /var/log/haproxy.log
    #
#从配置文件看出，如果需要设置日志，需要做上面两步
[root@lamp-zabbix ~]# vim /etc/sysconfig/rsyslog 
SYSLOGD_OPTIONS="-c 2 -r -m 0" #增加-r选项
[root@lamp-zabbix ~]# vim /etc/rsyslog.conf #添加日志参数
local2.*                            /var/log/haproxy.log
$ModLoad imudp  
$UDPServerRun 514  #取消注释这两行，否则不会生效
[root@lamp-zabbix ~]# systemctl restart rsyslog.service 
[root@lamp-zabbix ~]# egrep -v '#|^$' /etc/haproxy/haproxy.cfg
global
    log         127.0.0.1 local2
    chroot      /var/lib/haproxy   #固定haproxy的根，以免被攻破危害整个系统
    pidfile     /var/run/haproxy.pid
    maxconn     4000   #最大的连接数
    user        haproxy   
    group       haproxy
    daemon   #以守护进程运行
    stats socket /var/lib/haproxy/stats   #状态套接字文件
defaults
    mode                    http   #七层http协议
    log                     global  #记录到使用全局配置设置的日志
    option                  httplog  #日志类别,采用httplog
    option                  dontlognull  #不记录健康检查日志信息
    option http-server-close  #每次请求完毕后主动关闭http通道
    option forwardfor       except 127.0.0.0/8  #从Http Header中获得客户端ip，除开本地的ip不转发到后端 
    option                  redispatch  #当serverId对应的服务器挂掉后，强制定向到其他健康的服务器
    retries                 3   #三次连接失败就认为是服务器不可用
    timeout http-request    10s #默认http请求超时时间
    timeout queue           1m  #默认队列超时时间
    timeout connect         10s #连接超时
    timeout client          1m  #客户端超时
    timeout server          1m  #服务端超时
    timeout http-keep-alive 10s #默认持久连接超时时间
    timeout check           10s #心跳检测超时
    maxconn                 3000   #最大连接数为3000
listen stats
        mode http  #开启http
        bind *:1080  #绑定在本地1080端口
        stats enable  #开启haproxy状态
        stats hide-version  #隐藏版本信息
        stats uri       /haproxyadmin?stats  #haproxy状态管理的uri路径
        stats realm     Haproxy\ Statistics   #统计页面密码框上提示文本
        stats auth      admin:admin  #帐户和密码
        stats admin if TRUE  #如果认证了则开启管理员功能，可进行开关后端服务器
frontend web
        bind *:8080  #前端的端口
        log global  #记录到global
        option httpclose #每次请求完毕后主动关闭http通道,haproxy不支持keep-alive,只能模拟这种模式的实现 
        option logasap #大传输大文件时可以提前记录日志
        option dontlognull  #不记录健康检查日志信息
        capture request header Host len 20  #捕获请求报文头部用于记录日志
        capture request header Referer len 60 #捕获请求报文头部用于记录日志
        default_backend servers  #默认使用后端servers服务器群

backend servers
        balance roundrobin  #负载均衡算法，这种用得最多
        server web1 192.168.1.233:80 check maxconn 4000  #定义后端服务器组，最大4000并发连接
        server web2 192.168.1.239:80 check maxconn 3000  
[root@lamp-zabbix ~]# systemctl start haproxy.service
[root@lamp-zabbix ~]# netstat -tnlp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:3306            0.0.0.0:*               LISTEN      8997/mysqld         
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      1/systemd           
tcp        0      0 0.0.0.0:8080            0.0.0.0:*               LISTEN      31272/haproxy       
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      4810/sshd           
tcp        0      0 0.0.0.0:1080            0.0.0.0:*               LISTEN      31272/haproxy       
tcp        0      0 0.0.0.0:10050           0.0.0.0:*               LISTEN      15655/zabbix_agentd 
tcp        0      0 0.0.0.0:10051           0.0.0.0:*               LISTEN      15557/zabbix_server 
tcp6       0      0 :::111                  :::*                    LISTEN      1/systemd           
tcp6       0      0 :::80                   :::*                    LISTEN      14729/httpd         
tcp6       0      0 :::22                   :::*                    LISTEN      4810/sshd           
tcp6       0      0 :::443                  :::*                    LISTEN      14729/httpd         
tcp6       0      0 :::10050                :::*                    LISTEN      15655/zabbix_agentd 
tcp6       0      0 :::10051                :::*                    LISTEN      15557/zabbix_server 
#http://192.168.1.239:1080/haproxyadmin?stats #访问GUI查看haproxy的状态

#使用haproxy负载均衡mysql
[root@lamp-zabbix ~]# egrep -v '#|^$' /etc/haproxy/haproxy.cfg
global
    log         127.0.0.1 local2
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon
    stats socket /var/lib/haproxy/stats
defaults
    mode                    tcp
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 300
listen stats
        mode http
        bind *:1080
        stats enable
        stats hide-version
        stats uri       /haproxyadmin?stats
        stats realm     Haproxy\ Statistics
        stats auth      admin:admin
        stats admin if TRUE
frontend web
        bind *:3307
        log global
        mode tcp
        default_backend mysqlservers

backend mysqlservers
        balance leastconn
        server dbsrv1 192.168.1.31:3306 check port 3306 maxconn 300
        server dbsrv2 192.168.1.37:3306 check port 3306 maxconn 300
[root@lamp-zabbix haproxy]# mysql -u root -p --port 3307 --protocol tcp -h 192.168.1.239  #输入密码直接连接即可
#注：常常用haproxy来调度mysql的读负载均衡
#HAProxy 负载均衡策略非常多， HAProxy 的负载均衡算法现在具体有如下8种：
1> roundrobin，表示简单的轮询，这个不多说，这个是负载均衡基本都具备的；
2> static-rr，表示根据权重，建议关注；
3> leastconn，表示最少连接者先处理，建议关注；
4> source，表示根据请求源 IP，这个跟 Nginx 的 IP_hash 机制类似，我们用其作为解决 session 问题的一种方法，建议关注；
5> ri，表示根据请求的 URI；
6> rl_param，表示根据请求的 URl 参数’balance url_param’ requires an URLparameter name；
7> hdr(name)，表示根据 HTTP 请求头来锁定每一次 HTTP 请求；
8> rdp-cookie(name)，表示根据据 cookie(name)来锁定并哈希每一次 TCP 请求。





#作业：使用keepalive跟haproxy进行整合使用

##CentOS7 haproxy+keepalived实现高可用集群搭建
CentOS7 64位
Keepalived1.3.5和Haproxy1.5.18：192.168.1.239、192.168.1.233两台主机上安装
后端负载主机：192.168.1.31、192.168.1.37两台节点上安装mysql服务
##Keepalived介绍，HA故障转移
keepalived是一个免费开源的，用C编写的类似于layer3, 4 & 7交换机制软件，具备我们平时说的第3层、第4层和第7层交换机的功能。主要提供loadbalancing（负载均衡）和 high-availability（高可用）功能，负载均衡实现需要依赖Linux的虚拟服务内核模块（ipvs），而高可用是通过VRRP协议实现多台机器之间的故障转移服务。
keepalived是一个基于VRRP协议来实现的WEB 服务高可用方案，可以利用其来避免单点故障。一个WEB服务至少会有2台服务器运行Keepalived，一台为主服务器（MASTER），一台为备份服务器（BACKUP），但是对外表现为一个虚拟IP，主服务器会发送特定的消息给备份服务器，当备份服务器收不到这个消息的时候，即主服务器宕机的时候，备份服务器就会接管虚拟IP，继续提供服务，从而保证了高可用性。keepalived是VRRP的完美实现！
#注haproxy192.168.1.239(lamp-zabbix.jack.com)已经安装好，只需要在192.168.1.233(lnmp.jack.com)上再安装haproxy即可
[root@lnmp ~]# cat /etc/haproxy/haproxy.cfg #跟192.168.1.239配置一样
global
    log         127.0.0.1 local2 
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon
    stats socket /var/lib/haproxy/stats
defaults
    mode                    tcp
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 300
listen stats
        mode http
        bind *:1080
        stats enable
        stats hide-version
        stats uri       /haproxyadmin?stats
        stats realm     Haproxy\ Statistics
        stats auth      admin:admin
        stats admin if TRUE
frontend web
        bind *:3307
        log global
        mode tcp
        default_backend mysqlservers

backend mysqlservers
        balance leastconn
        server dbsrv1 192.168.1.31:3306 check port 3306 maxconn 300
        server dbsrv2 192.168.1.37:3306 check port 3306 maxconn 300
#注：可添加额外参数，注意参数解释：inter 2000 心跳检测时间；rise 2 三次连接成功，表示服务器正常；fall 5 三次连接失败，表示服务器异常； weight 1 权重设置
[root@lnmp ~]# vim /etc/sysconfig/rsyslog 
SYSLOGD_OPTIONS="-r -c 2 -m 0"
[root@lnmp ~]# vim /etc/rsyslog.conf 
local2.*                   /var/log/haproxy.log
$ModLoad imudp  
$UDPServerRun 514  #取消注释这两行，否则不会生效
[root@lnmp ~]# systemctl restart rsyslog
[root@lnmp ~]# systemctl start haproxy #注意haproxy配置必须一样，端口也一样。

#192.168.1.233和192.168.1.239这两台haproxy上都要安装keepalived
[root@lamp-zabbix haproxy]# yum install -y keepalived 
[root@lnmp ~]# yum install -y keepalived
[root@lamp-zabbix haproxy]# cp /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak
[root@lnmp ~]# cp /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak
[root@lamp-zabbix haproxy]# vim /etc/keepalived/keepalived.conf #主keepalived
! Configuration File for keepalived
global_defs {
  notification_email {
    root@localhost
    }
  
  notification_email_from keepalived@localhost
  smtp_server 127.0.0.1
  smtp_connect_timeout 30
  router_id HAproxy237
}
  
vrrp_script chk_haproxy {                           
  script "/etc/keepalived/check_haproxy.sh"
  interval 2
  weight 2
}
  
vrrp_instance VI_1 {
  state MASTER
  interface eth0
  virtual_router_id 51
  priority 100
  advert_int 1
  authentication {
    auth_type PASS
    auth_pass 1111
}
  track_script {
    chk_haproxy
}
virtual_ipaddress {
    192.168.1.238
}
  notify_master "/etc/keepalived/clean_arp.sh 192.168.1.238"
}
[root@lamp-zabbix keepalived]# vim check_haproxy.sh 
#!/bin/bash
A=`ps -C haproxy --no-header | wc -l`
if [ $A -eq 0 ];then
systemctl start haproxy
sleep 3
if [ `ps -C haproxy --no-header | wc -l ` -eq 0 ];then
systemctl stop haproxy
fi
fi
[root@lamp-zabbix keepalived]# chmod +x check_haproxy.sh 
[root@lamp-zabbix keepalived]# vim clean_arp.sh 
P=$1
GATEWAY=192.168.1.254   
/sbin/arping -I eth0 -c 5 -s $VIP $GATEWAY &>/dev/null
[root@lamp-zabbix keepalived]# chmod +x clean_arp.sh 
[root@lnmp keepalived]# vim keepalived.conf #备keepalived
! Configuration File for keepalived
global_defs {
  notification_email {
    root@localhost
    }
  
  notification_email_from keepalived@localhost
  smtp_server 127.0.0.1
  smtp_connect_timeout 30
  router_id HAproxy236
}
  
vrrp_script chk_haproxy {                           
  script "/etc/keepalived/check_haproxy.sh"
  interval 2
  weight 2
}
  
vrrp_instance VI_1 {
  state BACKUP
  interface eth0
  virtual_router_id 51
  priority 99
  advert_int 1
  authentication {
    auth_type PASS
    auth_pass 1111
}
  track_script {
    chk_haproxy
}
virtual_ipaddress {
    192.168.1.238
}
  notify_master "/etc/keepalived/clean_arp.sh 192.168.1.238"
}
[root@lnmp keepalived]# vim check_haproxy.sh
#!/bin/bash
A=`ps -C haproxy --no-header | wc -l`
if [ $A -eq 0 ];then
systemctl start haproxy
sleep 3
if [ `ps -C haproxy --no-header | wc -l ` -eq 0 ];then
systemctl stop haproxy
fi
fi
[root@lnmp keepalived]# vim clean_arp.sh
P=$1
GATEWAY=192.168.1.254   
/sbin/arping -I eth0 -c 5 -s $VIP $GATEWAY &>/dev/null
[root@lnmp keepalived]# chmod +x clean_arp.sh check_haproxy.sh 
[root@lnmp keepalived]# systemctl start keepalived.service
[root@lamp-zabbix keepalived]# systemctl start keepalived.service 
[root@lamp-zabbix keepalived]# ip add show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:0c:29:55:04:d0 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.239/24 brd 192.168.1.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet 192.168.1.238/32 scope global eth0   #VIP在主上
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fe55:4d0/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
[root@lnmp keepalived]# ip add show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:50:56:ad:0d:3c brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.233/24 brd 192.168.1.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::250:56ff:fead:d3c/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
[root@lamp-zabbix keepalived]# systemctl stop keepalived.service 
[root@lamp-zabbix keepalived]# ip add show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:0c:29:55:04:d0 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.239/24 brd 192.168.1.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fe55:4d0/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
[root@lnmp keepalived]# ip add show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:50:56:ad:0d:3c brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.233/24 brd 192.168.1.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet 192.168.1.238/32 scope global eth0  #到从上了
       valid_lft forever preferred_lft forever
    inet6 fe80::250:56ff:fead:d3c/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
#注：此时可以访问192.168.1.238即可进行对mysql读操作进行负载均衡了，无论是哪台机器故障，keepalived随之会转移到另外一台机器上使用haproxy进行代理。
[root@mysql-master ~]# mysql -u root -p --port 3308 --protocol tcp -h 192.168.1.238
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 6
Server version: 5.6.43-log MySQL Community Server (GPL)

Copyright (c) 2000, 2019, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
