# harpoxy

**对比**

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



**haproxy支持ACL规则**

用于定义四层到七层的规则来匹配一些特殊的请求，实现基于请求报文首部、相应报文内容或者是一些其他状态信息，从而根据需求进行不同的策略转发响应。
可以通过ACL规则完成以下两种主要功能：
1、通过设置ACL规则来检查客户端请求是否符合规则，将不符合规则要求的请求直接中断；
2、符合ACL规则的请求由backend指定的后端服务器池执行基于ACL规则的负载均衡，不符合的可以直接中断响应，也可以交由其它服务器池执行。
#Haproxy中的ACL规则总设置在frontend部分：
语法：
acl 名称 方法 -i [匹配的路径或文件]
说明：
acl：区分字符大小写，且其只能包含大小写字母、数字、-(连接线)、_(下划线)、.(点号)和:(冒号)；haproxy中，acl可以重名，这可以把多个测试条件定义为一个共同的acl。名称：设定ACL名称规则，后面可引用ACL规则。方法：用来设定实现ACL的方法。-i：忽略大小写  -f：从指定的文件中加载模式；
常用的方法：
1、hdr_beg(host)：用于测试请求报文的指定首部的开头部分是否符合指定的模式,host就是指定的首部{head request begin}
例子：
acl host_static hdr_beg(host) -i img. video. download. ftp.
注：测试请求头host首部是否是img. video. download. ftp.开头，开头则ACL规则通过
2、hdr_end(host)：用于测试请求报文的指定首部的结尾部分是否符合指定的模式
例子：
acl host_static hdr_end(host) -i .aa.com .bb.com
3、hdr_reg(host)：正则匹配
例子：
acl bbs hdr_reg(host) -i ^(bbs.test.com|shequ.test.com|forum)
4、url_sub：表示请求url中包含什么字符串
5、url_dir：表示请求url中存在哪些字符串作为部分地址路径
6、path_beg： 用于测试请求的URL是否以指定的模式开头
例子：
acl url_static path_beg -i /static /iilannis /javascript /stylesheets
7、path_end：用于测试请求的URL是否以指定的模式结尾
例子：
acl url_static path_end -i .jpg .gif .png .css .js
也可以根据访问的地址和端口进行规制设置：
dst：目标地址
dst_port：目标端口
src：源地址
src_port：源端口
实现的结果：
当客户端访问haproxy时，请求的是静态文件内容时，请求转交给static server，请求的是php内容时，请求转交给php server，请求的是jsp内容时，请求转交给tomcat server，以实现动静分离。
部署三台web服务器：
一台httpd支持php
一台部署nginx支持静态资源
一台tomcat支持jsp
例如：
frontend web
	listen www
	bind *:80
	maxconn 5000
	mode http
	log global
	option httplog
	option httpclose
	option forwardfor
	log global
	default_backend default   #设置默认访问页面，当没有匹配到ACL规则时则访问这个默认后端服务
    #定义当请求的内容是静态内容时，将请求转交给static server的acl规则       
    acl url_static path_beg  -i /static /images /img /javascript /stylesheets
    acl url_static path_end  -i .jpg .gif .png .css .js .html 
    acl host_static hdr_beg(host)  -i img. video. download. ftp. imags. videos.
    #定义当请求的内容是php内容时，将请求转交给php server的acl规则    
    acl url_php path_end     -i .php
    #定义当请求的内容是.jsp或.do内容时，将请求转交给tomcat server的acl规则    
    acl url_jsp path_end     -i .jsp .do
    #引用acl匹配规则
    use_backend static_pool if  url_static or host_static
    use_backend php_pool    if  url_php
    use_backend tomcat_pool if  url_jsp
#定义后端backend server
backend static_pool
	option httpchk GET /index.html
	server static1 192.168.80.101:80 cookie id1 check inter 2000 rise 2 fall 3
backend php_pool
	option httpchk GET /info.php
	server php1 192.168.80.102:80 cookie id1 check inter 2000 rise 2 fall 3
backend tomcat_pool
	option httpchk GET /index.jsp
	server tomcat1 192.168.80.103:8086 cookie id2 check inter 2000 rise 2 fall 3
backend default
	mode http
	option httpchk GET /index.html
	server default 192.168.80.104:80 cookie id1 check inter 2000 rise 2 fall 3 maxconn 5000



## 配置HAproxy

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

## 安装haproxy

```bash
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
```



## 使用haproxy负载均衡mysql
```bash
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
```





# haproxy+keepalived实现高可用集群

```bash
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
#注：可添加额外参数，注意参数解释：inter 2000 心跳检测时间；rise 2 两次连接成功，表示服务器正常；fall 3 三次连接失败，表示服务器异常； weight 1 权重设置
[root@lnmp ~]# vim /etc/sysconfig/rsyslog 
SYSLOGD_OPTIONS="-r -c 2 -m 0"
[root@lnmp ~]# vim /etc/rsyslog.conf 
local2.*                   /var/log/haproxy.log
$ModLoad imudp  
$UDPServerRun 514  #取消注释这两行，否则不会生效
[root@lnmp ~]# systemctl restart rsyslog
[root@lnmp ~]# systemctl start haproxy #注意haproxy配置必须一样，端口也一样。

---------haproxy config--------------
global
	maxconn 50000
	chroot /usr/local/haproxy  #haproxy install root directory
	uid 99   #99 is nobody
	gid 99
	daemon
	nbproc 1  #start boot process number
	pidfile /usr/local/haproxy/logs/haproxy.pid
	log 127.0.0.1 local3 info

#默认参数设置
defaults
	option http-keep-alive
	mode http  #set run mode,have tcp,http,health choose
	maxconn 50000
	retires 3
	timeout connect 5000ms
	timeout client  20000ms
	timeout server 25000ms
	timeout check 5000ms

#开启Haproxy Status状态监控，增加验证
listen status
	mode http  #
	bind 0.0.0.0:8888
	stats enable
	stats refresh 30s #设置HAProxy监控统计页面自动刷新的时间
	stats realm Welcome login #设置登录监控页面时，密码框上的提示信息
	stats uri     /haproxy-status
	stats auth    haproxy:password
	stats hide-version #设置在监控页面上隐藏HAProxy的版本号
	status admin if TRUE #设置此选项，可在监控页面上启用、禁用后端服务器，仅在1.4.9版本以后生效

#前端设置
frontend rabbitmq_webui
	bind *:15672
	mode http
	option httplog  #record http request logs
	option redispatch #而如果后端服务器出现故障，客户端的cookie是不会刷新的，这就会造成无法访问。此时，如果设置了此参数，就会将客户的请求强制定向到另外一台健康的后端服务器上，以保证服务正常
	option abortonclose #此参数可以在服务器负载很高的情况下，自动结束当前队列中处理时间比较长的连接
	option forwardfor header X-REAL-IP  #option forwardfor [ except <network> ] [ header <name> ] [ if-none ],<network>：可选参数，当指定时，源地址为匹配至此网络中的请求都禁用此功能。<name>：可选参数，可使用一个自定义的首部，如“X-Client”来替代“X-Forwarded-For”。有些独特的web服务器的确需要用于一个独特的首部.if-none：仅在此首部不存在时才将其添加至请求报文问道中。HAProxy可以向每个发往服务器的请求上添加此首部，并以客户端IP为其value。
	#option httpclose  #此选项表示客户端和服务端完成一次连接请求后，HAProxy将主动关闭此TCP连接。这是对性能非常有帮助的一个参数
	log global
	default_backend rabbitmq_webui

#后端设置
backend rabbitmq_webui
	balance source #指定负载均衡算法,roundrobin基于权重进行轮叫调度的算法,static-rr基于权重进行轮叫调度的算法，不过此算法为静态算法，在运行时调整其服务器权重不会生效,source基于请求源IP的算法,leastconn此算法会将新的连接请求转发到具有最少连接数目的后端服务器。uri此算法会对部分或整个URI进行HASH运算，再经过与服务器的总权重相除，最后转发到某台匹配的后端服务器上,uri_param此算法会根据URL路径中的参数进行转发，这样可保证在后端真实服务器数据不变时，同一个用户的请求始终分发到同一台机器上,hdr此算法根据HTTP头进行转发，如果指定的HTTP头名称不存在，则使用roundrobin算法 进行策略转发,cookie SERVERID表示允许向cookie插入SERVERID，每台服务器的SERVERID可在下面的server关键字中使用cookie关键字定义
	server rabbitmq-node1 192.168.15.201:15672 check port 15672 inter 2000 rise 2 fall 3
	server rabbitmq-node2 192.168.15.202:15672 check port 15672 inter 2000 rise 2 fall 3

	#server <name> <address>:[port] [param*],param*参数:check 表示启用对此后端服务器执行健康状态检查,inter 设置健康状态检查的时间间隔，单位是毫秒,rise 检查多少次认为服务器可用,fall 检查多少次认为服务器不可用,weight 设置服务器的权重，默认为1，最大为256。设置为0表示不参与负载均衡,backup 设置备份服务器，用于所有后端服务器全部不可用时,kie 为指定的后端服务器设置cookie值，此处指定的值将在请求入站时被检查，第一次为此值挑选的后端服务器将在后续的请求中一直被选中，其目的在于实现持久连接的功能
-------------------------------------
```



# 部署keepalived

```bash
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
VIP=$1
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
VIP=$1
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
```







# 基于nginx做主备或主主模式

```bash
#keepalived配置详解：
-------------

! Configuration File for keepalived  

global_defs {  
   notification_email {  
         linuxedu@foxmail.com
         mageedu@126.com  
   }  
   notification_email_from kanotify@magedu.com 
   smtp_connect_timeout 3  
   smtp_server 127.0.0.1  
   router_id LVS_DEVEL  
}  

vrrp_script chk_haproxy {  
    script "killall -0 haproxy"  
    interval 1  
    weight 2  
}  

vrrp_script chk_mantaince_down {
   script "[[ -f /etc/keepalived/down ]] && exit 1 || exit 0"
   interval 1
   weight 2
}

vrrp_instance VI_1 {  
    interface eth0  
    state MASTER  # BACKUP for slave routers
    priority 101  # 100 for BACKUP
    virtual_router_id 51 
    garp_master_delay 1 
    advert_int 1   

    authentication {  
        auth_type PASS  
        auth_pass password  
    }  
    track_interface {  
       eth0    
    }  
    virtual_ipaddress {  
        172.16.100.1/16 dev eth0 label eth0:0 
    }  
    track_script {  
        chk_haproxy  
        chk_mantaince_down
    }  

 

    notify_master "/etc/keepalived/notify.sh master"  
    notify_backup "/etc/keepalived/notify.sh backup"  
    notify_fault "/etc/keepalived/notify.sh fault"  
    smtp alter

} 
-------------

全局配置解析
global_defs全局配置标识，表面这个区域{}是全局配置
notification_email {  
         linuxedu@foxmail.com
         mageedu@126.com  
}
表示keepalived在发生诸如切换操作时需要发送email通知，以及email发送给哪些邮件地址，邮件地址可以多个，每行一个，这里的只能发送到本机用户
notification_email_from kanotify@magedu.com 
表示发送通知邮件时邮件源地址是谁
smtp_server 127.0.0.1
表示发送email时使用的smtp服务器地址，这里可以用本地的sendmail来实现
smtp_connect_timeout 3
连接smtp连接超时时间
router_id node1
机器标识
vrrp_script chk_haproxy {  
    script "killall -0 haproxy"  
    interval 1  
    weight 2  
}  
vrrp_script chk_mantaince_down {
   script "[[ -f /etc/keepalived/down ]] && exit 1 || exit 0"
   interval 1
   weight 2
}
vrrp_script区域定义脚本名字和脚本执行的间隔和脚本执行的优先级变更
state：state指定instance(Initial)的初始状态，就是说在配置好后，这台服务器的初始状态就是这里指定的，但这里指定的不算，还是得要通过竞选通过优先级来确定，里如果这里设置为master，但如若他的优先级不及另外一台，那么这台在发送通告时，会发送自己的优先级，另外一台发现优先级不如自己的高，那么他会就回抢占为master
interface：实例绑定的网卡，因为在配置虚拟IP的时候必须是在已有的网卡上添加的
priority 100：设置本节点的优先级，优先级高的为master
virtual router id：这里设置VRID，这里非常重要，相同的VRID为一个组，他将决定多播的MAC地址
garp master delay：在切换到master状态后，延迟进行免费的ARP(gratuitous ARP)请求
advert_int 1: 检查间隔
nopreempt：state必须配置为BACKUP时，nopreempt不抢占功能才能生效
authentication {  
        auth_type PASS  
        auth_pass password  
    }
authentication：这里设置认证
auth type：认证方式，可以是PASS或AH两种认证方式
auth pass：认证密码
 track_interface {  
       eth0    
    }
track interface：跟踪接口，设置额外的监控，里面任意一块网卡出现问题，都会进入故障(FAULT)状态，例如，用nginx做均衡器的时候，内网必须正常工作，如果内网出问题了，这个均衡器也就无法运作了，所以必须对内外网同时做健康检查
 virtual_ipaddress {  
        172.16.100.1/16 dev eth0 label eth0:0 
    } 
virtual ipaddress：这里设置的就是VIP，也就是虚拟IP地址，他随着state的变化而增加删除，当state为master的时候就添加，当state为backup的时候删除，这里主要是有优先级来决定的，和state设置的值没有多大关系，这里可以设置多个IP地址
track_script {  
        chk_haproxy  
        chk_mantaince_down
    }  
在实例(vrrp_instance)里面引用脚本
注意：VRRP脚本(vrrp_script)和VRRP实例(vrrp_instance)属于同一个级别
notify_master "/etc/keepalived/notify.sh master"  表示当切换到master状态时，要执行的脚本
notify_backup "/etc/keepalived/notify.sh backup"  表示当切换到backup状态时，要执行的脚本
notify_fault "/etc/keepalived/notify.sh fault" 表示当故障时，要执行的脚本

smtp alter	表示切换时给global defs中定义的邮件地址发送右键通知
-------------

#源码keepalived安装---CentOS-7
[root@node2 download]# wget https://www.keepalived.org/software/keepalived-2.0.19.tar.gz
[root@node2 download]# tar xf keepalived-2.0.19.tar.gz 
[root@node2 keepalived-2.0.19]# ./configure --prefix=/usr/local/keepalived
[root@node2 keepalived-2.0.19]# make && make install
[root@node2 keepalived]# mkdir /etc/keepalived
[root@node2 keepalived]# cp /usr/local/keepalived/etc/keepalived/keepalived.conf /etc/keepalived/
[root@node2 keepalived]# cp /download/keepalived-2.0.19/keepalived/keepalived.service /usr/lib/systemd/system/ #默认复制过去，没有则自己复制下
[root@node2 download]# echo 'PATH=$PATH:/usr/local/keepalived/sbin' > /etc/profile.d/keepalived.sh
[root@node2 download]# . /etc/profile.d/keepalived.sh
#keepalived主备模式
------MASTER-------
[root@node2 html]# cat /etc/keepalived/keepalived.conf 
! Configuration File for keepalived
global_defs {
	notification_email {
     		saltstack@example.com
   	}
   	notification_email_from keepalived@example.com
   	smtp_server 127.0.0.1
   	smtp_connect_timeout 30
   	router_id nginx_ha
}

vrrp_instance nginx_ha {
	state MASTER
	interface eth0
	virtual_router_id 80
	priority 150
	advert_int 1

	authentication {
		auth_type PASS
	   		auth_pass 8486c8cdb3 
	}
	
	virtual_ipaddress {
		192.168.15.50
	}

}
-----BACKUP-------
! Configuration File for keepalived
global_defs {
	notification_email {
     		saltstack@example.com
   	}
   	notification_email_from keepalived@example.com
   	smtp_server 127.0.0.1
   	smtp_connect_timeout 30
   	router_id nginx_ha
}

vrrp_instance nginx_ha {
	state BACKUP
	interface eth0
	virtual_router_id 80
	priority 100
	advert_int 1

	authentication {
		auth_type PASS
	   		auth_pass 8486c8cdb3 
	}
	
	virtual_ipaddress {
		192.168.15.50
	}

}
------------------

[root@node2 keepalived]# cat chk_nginx.sh 
#!/bin/bash
d=`date --date today +%Y%m%d_%H:%M:%S`
#n1=`ps -C nginx --no-heading|wc -l`
curl -Is http://127.0.0.1 | grep '200 OK'
n1=$?
if [ $n1 -ne "0" ]; then
        #systemctl restart nginx
        #n2=`ps -C nginx --no-heading|wc -l`
	curl -Is http://127.0.0.1 | grep '200 OK'
	n2=$?
        if [ $n2 -ne "0"  ]; then
                echo "$d nginx down,keepalived will stop" >> /var/log/chk_nginx.log
                systemctl stop keepalived
        fi

fi
------------------

[root@node2 /usr/local/nginx/html]# systemctl start keepalived.service 
[root@node3 /usr/local/nginx/html]# systemctl start keepalived.service 
#keepalived主主模式
说明：其基本实现思想为创建两个虚拟路由器，并以两个节点互为主从。
-----------node2-----------
! Configuration File for keepalived
global_defs {
	notification_email {
     		saltstack@example.com
   	}
   	notification_email_from keepalived@example.com
   	smtp_server 127.0.0.1
   	smtp_connect_timeout 30
   	router_id node2
}

vrrp_script chk_nginx {              
    	script "/etc/keepalived/chk_nginx.sh"
    	interval 1
    	weight 10 
}

vrrp_instance nginx_ha1 {
	state MASTER
	interface eth0
	virtual_router_id 80
	priority 150
	advert_int 1

	authentication {
		auth_type PASS
	   		auth_pass 8486c8cdb3 
	}
	
	virtual_ipaddress {
		192.168.15.50
	}
	
	track_script {
	    	chk_nginx
		}

}

vrrp_instance nginx_ha2 {
	state BACKUP
	interface eth0
	virtual_router_id 81
	priority 100
	advert_int 1

	authentication {
		auth_type PASS
	   		auth_pass ecc539f348
	}
	
	virtual_ipaddress {
		192.168.15.51
	}
	
	track_script {
	    	chk_nginx
		}

}

-----------node3-----------
! Configuration File for keepalived
global_defs {
	notification_email {
     		saltstack@example.com
   	}
   	notification_email_from keepalived@example.com
   	smtp_server 127.0.0.1
   	smtp_connect_timeout 30
   	router_id nginx_ha
}

vrrp_script chk_nginx {              
    	script "/etc/keepalived/chk_nginx.sh"
    	interval 3
    	weight 10 
}

vrrp_instance nginx_ha1 {
	state BACKUP
	interface eth0
	virtual_router_id 80
	priority 100
	advert_int 1

	authentication {
		auth_type PASS
	   		auth_pass 8486c8cdb3 
	}
	
	virtual_ipaddress {
		192.168.15.50
	}
	
	track_script {
	    	chk_nginx
		}

}

vrrp_instance nginx_ha2 {
	state MASTER
	interface eth0
	virtual_router_id 81
	priority 150
	advert_int 1

	authentication {
		auth_type PASS
	   		auth_pass ecc539f348
	}
	
	virtual_ipaddress {
		192.168.15.51
	}
	
	track_script {
	    	chk_nginx
		}

}
-----------node2--------------
[root@node2 keepalived]# cat /etc/keepalived/chk_nginx.sh 
#!/bin/bash
d=`date --date today +%Y%m%d_%H:%M:%S`
[ `ps -C nginx --no-heading|wc -l` -gt 0 ] && curl -Is http://127.0.0.1 | grep '200 OK'
if [ $? -ne '0' ];then
        systemctl restart nginx
	[ `ps -C nginx --no-heading|wc -l` -gt 0 ] && curl -Is http://127.0.0.1 | grep '200 OK'
        if [ $? -ne "0"  ]; then
                echo "$d nginx down,keepalived will stop" >> /var/log/chk_nginx.log
                systemctl stop keepalived
        fi
fi
-----------node3--------------
[root@node3 /etc/keepalived]# cat chk_nginx.sh 
#!/bin/bash
d=`date --date today +%Y%m%d_%H:%M:%S`
[ `ps -C nginx --no-heading|wc -l` -gt 0 ] && curl -Is http://127.0.0.1 | grep '200 OK'
if [ $? -ne '0' ];then
        systemctl restart nginx
	[ `ps -C nginx --no-heading|wc -l` -gt 0 ] && curl -Is http://127.0.0.1 | grep '200 OK'
        if [ $? -ne "0"  ]; then
                echo "$d nginx down,keepalived will stop" >> /var/log/chk_nginx.log
                systemctl stop keepalived
        fi

fi
------------------------------

-----------此k8skeepalived配置可实现自动故障和恢复----------------
[root@node3 /download/ha]# docker exec keepalived-k8s cat /etc/keepalived/keepalived.conf
    global_defs {
        router_id 60
        vrrp_version 2
        vrrp_garp_master_delay 1
    }   

    vrrp_script chk_haproxy {
        script       "/bin/busybox nc -v -w 2 -z 127.0.0.1 6444 2>&1 | grep open | grep 6444"
        timeout 1
        interval 1   # check every 1 second
        fall 2       # require 2 failures for KO
        rise 2       # require 2 successes for OK
    }   
    
    vrrp_instance lb-vips {
        state BACKUP
        interface eth0
        virtual_router_id 120
        priority 100
        advert_int 1
        nopreempt
        track_script {
            chk_haproxy
        }
        authentication {
            auth_type PASS
            auth_pass blahblah
        }
        virtual_ipaddress {
            192.168.15.50/24 dev eth0
        }
    }

-----------------------------------------------------------

注：
版本：Keepalived v1.3.9 (11/11,2017)
使用了vrrp_version 2版本，制定了脚本，当fall 2（失败两次停掉相关联的实例）
当 rise 2（成功两次则再次启动相关联的实例），interval 1（每一秒执行一次检查）
timeout 1（当达到1秒时为失败一次），此配置开启了多播，多播在多个Keepalived节点上，

有时随机有两个虚拟IP在线
-----------------------------------------------------------


#keepalived配置邮件告警

1. 邮件脚本
   [root@reverse02 /etc/keepalived]# cat notify.sh
   #!/bin/bash
   #
   contact='test@baidu.com'
   notify() {
   local mailsubject="$(hostname) to be $1, vip floating"
   local mailbody="$(date +'%F %T'): vrrp transition, $(hostname) changed to be $1"
   echo "$mailbody" | mail -s "$mailsubject" $contact
   }

case $1 in
master)
        notify master
        ;;
backup)
        notify backup
        ;;
fault)
        notify fault
        ;;
*)
        echo "Usage: $(basename $0) {master|backup|fault}"
        exit 1
        ;;
esac

2. 服务器上配置邮件通知帐户及邮件服务器配置
   2.1 yum install mailx	--安装包
   2.2 vim /etc/mail.rc	--配置互联网邮件信息

--------------

set from=email@domaim.com
set smtp=smtp.qiye.163.com
set smtp-auth=login
set smtp-auth-user=user@domain.com
set smtp-auth-password=password

set ssl-verify=ignore
--------------

3. 配置keepalived
   [root@reverse02 /etc/keepalived]# cat keepalived.conf

----------------------

! Configuration File for keepalived
! 这里面的邮箱配置只对本机用户有效
global_defs {
	notification_email {
     		root@localhost
   	}
   	notification_email_from root@localhost
   	smtp_server 127.0.0.1
   	smtp_connect_timeout 30
   	router_id reverse02
}

vrrp_instance nginx_ha {
	state BACKUP
	interface eth0
	virtual_router_id 51
	priority 100
	advert_int 1

	authentication {
		auth_type PASS
	   		auth_pass 1111
	}
	
	virtual_ipaddress {
		192.168.13.207
	}
	
	notify_master "/etc/keepalived/notify.sh master"  
	notify_backup "/etc/keepalived/notify.sh backup"  
	notify_fault "/etc/keepalived/notify.sh fault"  
	smtp alter

}
----------------------

附keepalived启动脚本

[root@reverse02 /etc/keepalived]# cat /etc/init.d/keepalived 
-------------------------

#!/bin/sh
#

# keepalived   High Availability monitor built upon LVS and VRRP

#

# chkconfig:   - 86 14

# description: Robust keepalive facility to the Linux Virtual Server project \

#              with multilayer TCP/IP stack checks.

### BEGIN INIT INFO

# Provides: keepalived

# Required-Start: $local_fs $network $named $syslog

# Required-Stop: $local_fs $network $named $syslog

# Should-Start: smtpdaemon httpd

# Should-Stop: smtpdaemon httpd

# Default-Start: 

# Default-Stop: 0 1 2 3 4 5 6

# Short-Description: High Availability monitor built upon LVS and VRRP

# Description:       Robust keepalive facility to the Linux Virtual Server

#                    project with multilayer TCP/IP stack checks.

### END INIT INFO

# Source function library.

. /etc/rc.d/init.d/functions

exec="/usr/local/keepalived/sbin/keepalived"
prog="keepalived"
config="/etc/keepalived/keepalived.conf"

[ -e /etc/sysconfig/$prog ] && . /etc/sysconfig/$prog

lockfile=/var/lock/subsys/keepalived

start() {
    [ -x $exec ] || exit 5
    [ -e $config ] || exit 6
    echo -n $"Starting $prog: "
    daemon $exec $KEEPALIVED_OPTIONS
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $lockfile
    return $retval
}

stop() {
    echo -n $"Stopping $prog: "
    killproc $prog
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $lockfile
    return $retval
}

restart() {
    stop
    start
}

reload() {
    echo -n $"Reloading $prog: "
    killproc $prog -1
    retval=$?
    echo
    return $retval
}

force_reload() {
    restart
}

rh_status() {
    status $prog
}

rh_status_q() {
    rh_status &>/dev/null
}


case "$1" in
    start)
        rh_status_q && exit 0
        $1
        ;;
    stop)
        rh_status_q || exit 0
        $1
        ;;
    restart)
        $1
        ;;
    reload)
        rh_status_q || exit 7
        $1
        ;;
    force-reload)
        force_reload
        ;;
    status)
        rh_status
        ;;
    condrestart|try-restart)
        rh_status_q || exit 0
        restart
        ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload}"
        exit 2
esac

exit $?
-------------------------



#问题：两台机器上面都有VIP的情况
排查：
1.检查防火墙，发现已经是关闭状态。

2. keepalived.conf配置问题。
   3.可能是上联交换机禁用了arp的广播限制，造成keepalive无法通过广播通信，两台服务器抢占vip，出现同时都有vip的情况。
     tcpdump -i eth0 vrrp -n   检查发现160和163都在对224.0.0.18发送消息。但是在正常情况下，备节点如果收到主节点的心跳消息时，优先级高于自己，就不会主动对外发送消息。

#keepalived两台机器同时出现vip问题，使用单播进行解决
-----------------------------

[root@linux04 keepalived]# cat /etc/keepalived/keepalived.conf   --node163
! Configuration File for keepalived
global_defs {
	notification_email {
     		root@localhost
   	}
   	notification_email_from root@localhost
   	smtp_server 127.0.0.1
   	smtp_connect_timeout 30
   	router_id mysql_ha02
}

vrrp_script chk_mysql {              
    	script "/etc/keepalived/chk_mysql.sh"
    	interval 1
    	weight 10 
}

vrrp_instance mysql_ha {
	state BACKUP
	interface eth0
	virtual_router_id 80
	priority 100
	advert_int 1
! 使用单播解决多台机器同时出现VIP问题
   	unicast_src_ip  192.168.13.163
	unicast_peer {              
        	192.168.13.160
    	}

	authentication {
		auth_type PASS
	   		auth_pass 8486c8cdb3 
	}
	
	virtual_ipaddress {
		192.168.13.117
	}
	
	track_script {
	    	chk_mysql
		}
	
	notify_master "/etc/keepalived/notify.sh master"  
	notify_backup "/etc/keepalived/notify.sh backup"  
	notify_fault "/etc/keepalived/notify.sh fault"  
	smtp alter

}
-----------------------------

[root@linux01 keepalived]# cat /etc/keepalived/keepalived.conf   --node160
! Configuration File for keepalived
global_defs {
	notification_email {
     		root@localhost
   	}
   	notification_email_from root@localhost
   	smtp_server 127.0.0.1
   	smtp_connect_timeout 30
   	router_id mysql_ha01
}

vrrp_script chk_mysql {              
    	script "/etc/keepalived/chk_mysql.sh"
    	interval 1
    	weight 10 
}

vrrp_instance mysql_ha {
	state MASTER
	interface em1
	virtual_router_id 80
	priority 150
	advert_int 1

   	unicast_src_ip  192.168.13.160
   	unicast_peer {              
   	    	192.168.13.163
   		}
   	
   	authentication {
   		auth_type PASS
   	   		auth_pass 8486c8cdb3 
   	}
   	
   	virtual_ipaddress {
   		192.168.13.117
   	}
   	
   	track_script {
   	    	chk_mysql
   		}
   	
   	notify_master "/etc/keepalived/notify.sh master"  
   	notify_backup "/etc/keepalived/notify.sh backup"  
   	notify_fault "/etc/keepalived/notify.sh fault"  
   	smtp alter

}
-----------------------------
```
