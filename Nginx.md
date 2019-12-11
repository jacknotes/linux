#Nginx
Nginx:反向代理、负载均衡、动静分离、网页、图片缓存
1. 反向代理：既然有反向，那肯定有正向，现有客户端x，代理服务器y，最终服务器z，现在x直接访问z：x->z，通过代理服务器y：x->y->z，无论正反代理服务器y都是位于x、z之间，正反是根据代理服务器代理的是谁来判断的
正向：代理服务器y代理的是客户端，站在客户端的角度上是正向的，所以是正向代理
反向：代理服务器y代理的是最终服务器z，站在客户端的角度上是反向的，所以是反向代理

2. 负载均衡：现在客户端所有请求都经过nginx了，那么nginx就可以决定将这些请求转发给谁，如果服务器A的资源更充分（CPU更多、内存更大等等），服务器B没有服务器A处理能力强，那么nginx就会吧更多的请求转发到A，转发较少的请求到服务器B，这样就做到了负载均衡，而且就算其中一台服务器宕机了，对于用户而言也能正常访问网站。

3. 动静分离：借助于nginx强大的转发功能，可以通过配置实现网站的动态请求和静态文件进行分离，将动态请求发送到服务器A，将静态文件转发到服务器B，这样便于nginx做静态文件的缓存和后期对网站使用CDN。


<pre>
#一.安装nginx
#安装所需的pcre库。注：安装这个pcre库是为了让nginx支持HTTP Rewrite模块
1. 下载pcre软件
ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.43.tar.gz
2. 编译安装
tar zxf pcre-8.43.tar.gz
cd pcre-8.43
yum install -y gcc gcc-c++
./configure
make && make install

#安装Nginx
下载nginx源码包:http://nginx.org/download/
[root@master-nginx pcre-8.43]# useradd -M -s /sbin/nologin  nginx
[root@master-nginx nginx-1.0.1]# ./configure \
> --user=nginx \
> --group=nginx \
> --prefix=/application/nginx-1.10.1 \
> --with-http_stub_status_module \
> --with-http_ssl_module \
> --with-pcre=/download/src/pcre-8.43
#pcre注意这里不是安装后的目录，而是源码目录
[root@master-nginx nginx-1.0.1]#make && make install

#启动服务
[root@master-nginx src]# ln -s /application/nginx-1.10.1/ /application/nginx
[root@master-nginx nginx-1.10.1]# cd conf/
[root@master-nginx conf]# cp ../sbin/nginx /etc/init.d/
[root@master-nginx conf]# /etc/init.d/nginx  #启动
[root@master-nginx conf]# ps -ef | grep nginx  #查看是否启动
root       636     1  0 17:33 ?        00:00:00 nginx: master process /etc/init.d/nginx
nginx      637   636  0 17:33 ?        00:00:00 nginx: worker process
root       639 10547  0 17:33 pts/0    00:00:00 grep --color=auto nginx

[root@master-nginx conf]# /application/nginx/sbin/nginx -t  #检查语法
nginx: the configuration file /application/nginx-1.10.1/conf/nginx.conf syntax is ok
nginx: configuration file /application/nginx-1.10.1/conf/nginx.conf test is successful

有的时候也会提示有错误

[root@localhost nginx-1.10.1]# /application/nginx/sbin/nginx -t /application/nginx/sbin/nginx: error while loading shared libraries: libpcre.so.1: cannot open shared object file: No such file or directory

出现错误提示 提示说明无法打开libpcre.so.1这个文件，没有这个文件或目录，出现这个提示的原因是因为在系统的/etc/ld.so.conf这个文件里没有libpcre.so.1的路径配置

解决方法如下：
[root@localhost nginx-1.10.1]# find / -name libpcre.so.1
/download/tools/pcre-8.38/.libs/libpcre.so.1
/usr/local/lib/libpcre.so.1
[root@localhost nginx-1.10.1]# vi /etc/ld.so.conf
include ld.so.conf.d/*.conf
/usr/local/lib   #添加此路径即可
[root@localhost nginx-1.10.1]# ldconfig  #生效配置

#测试nginx
http://192.168.1.31/
如果出现无法访问的现象可以从以下几个方面排错:
1、防火墙是否关闭
2、与WEB服务器的联通性
3、selinux是否为disable
4、telnet下80端口
5、查看错误日志记录进行分析问题所在
              

#二.Nginx服务配置文件介绍
1、Nginx服务目录结构介绍
[root@master-nginx nginx]# tree
.
├── client_body_temp
├── conf     #nginx服务配置文件目录
│   ├── fastcgi.conf   #fastcgi配置文件
│   ├── fastcgi.conf.default
│   ├── fastcgi_params   #fastcgi参数配置文件
│   ├── fastcgi_params.default
│   ├── koi-utf
│   ├── koi-win
│   ├── mime.types
│   ├── mime.types.default
│   ├── nginx.conf   #nginx服务的主配置文件
│   ├── nginx.conf.default   #nginx服务的默认配置文件
│   ├── scgi_params
│   ├── scgi_params.default
│   ├── uwsgi_params
│   ├── uwsgi_params.default
│   └── win-utf
├── fastcgi_temp
├── html    #编译安装nginx默认的首页配置文件目录
│   ├── 50x.html   #错误页面配置文件
│   ├── index.html   #默认的首页配置文件
│   └── index.html.bak
├── logs    #日志配置文件目录
│   ├── access.log   #访问日志文件
│   ├── error.log    #错误日志文件
│   └── nginx.pid
├── proxy_temp
├── sbin    #命令目录
│   └── nginx    #Nginx服务启动命令
├── scgi_temp   #临时目录      
└── uwsgi_temp

2、Nginx服务主配置文件介绍
[root@master-nginx nginx]# egrep -v "#|^$" conf/nginx.conf  #过滤配置文件
worker_processes  1;  #工作进程数
events {    #事件
    worker_connections  1024;   #并发数，单位时间内最大连接数
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    server {     #虚拟主机标签
        listen       80;    #监听的端口号
        server_name  localhost;   #服务器主机名
        location / {
            root   html;    #默认站点目录
            index  index.html index.htm;      #默认首页文件
        }
        error_page   500 502 503 504  /50x.html;    #错误页面文件
        location = /50x.html { 
            root   html;
        }
    }
}

3、Nginx服务帮助信息
[root@master-nginx nginx]# /application/nginx/sbin/nginx -h
nginx version: nginx/1.10.1
Usage: nginx [-?hvVtTq] [-s signal] [-c filename] [-p prefix] [-g directives]

Options:
  -?,-h         : this help
  -v            : show version and exit  #显示版本并退出
  -V            : show version and configure options then exit  #显示版本信息与配置后退出
  -t            : test configuration and exit  #检查配置（检查语法）
  -T            : test configuration, dump it and exit
  -q            : suppress non-error messages during configuration testing
  -s signal     : send signal to a master process: stop, quit, reopen, reload
  -p prefix     : set prefix path (default: /application/nginx-1.10.1/)
  -c filename   : set configuration file (default: conf/nginx.conf)  #指定配置文件，而非使用nginx.conf
  -g directives : set global directives out of configuration file

4、nginx编译参数查看
[root@master-nginx nginx]# /application/nginx/sbin/nginx -v
nginx version: nginx/1.10.1
[root@master-nginx nginx]# /application/nginx/sbin/nginx -V
nginx version: nginx/1.10.1
built by gcc 4.8.5 20150623 (Red Hat 4.8.5-36) (GCC)
built with OpenSSL 1.0.2k-fips  26 Jan 2017
TLS SNI support enabled
configure arguments: --user=nginx --group=nginx --prefix=/application/nginx-1.10.1 --with-http_stub_status_module --with-http_ssl_module --with-pcre=/download/src/pcre-8.43
实际生产环境比较实用的查看参数，比如服务非你自己所安装，但又没有相关文档参考，此参数可以提供一些相关的信息

#Nginx配置虚拟主机
[root@master-nginx ~]# mkdir /www/{www,bbs,blog} -p
[root@master-nginx ~]# tree /www/
/www/
├── bbs
├── b
[root@master-nginx ~]# ll /www/
total 0
drwxr-xr-x 2 nginx nginx 6 Mar  7 14:20 bbs
drwxr-xr-x 2 nginx nginx 6 Mar  7 14:20 blog
drwxr-xr-x 2 nginx nginx 6 Mar  7 14:20 www
[root@master-nginx ~]# echo "welcont to mingongge's web site" > /www/www/index.html
[root@master-nginx ~]# echo "welcont to mingongge's bbs site" > /www/bbs/index.html
[root@master-nginx ~]# echo "welcont to mingongge's blog site" > /www/blog/index.html
[root@master-nginx conf]# pwd
/application/nginx/conf
[root@master-nginx conf]# cd extra/vhosts/
[root@master-nginx vhosts]# cp ../../nginx.conf www/www.conf
[root@master-nginx vhosts]# cp ../../nginx.conf bbs/bbs.conf
[root@master-nginx vhosts]# cp ../../nginx.conf blog/blog.conf
[root@master-nginx vhosts]# pwd
/application/nginx/conf/extra/vhosts
[root@master-nginx vhosts]# cat www/www.conf 
    server {
        listen       80;
        server_name  master-nginx.jack.com

        location / {
            root   /www/www;
            index  index.html index.htm;
        }
    }
[root@master-nginx vhosts]# cat bbs/bbs.conf 
    server {
        listen       80;
        server_name  nginx2.jack.com

        location / {
            root   /www/bbs;
            index  index.html index.htm;
        }
    }
[root@master-nginx vhosts]# cat blog/blog.conf 
    server {
        listen       80;
        server_name  nginx3.jack.com

        location / {
            root   /www/blog;
            index  index.html index.htm;
        }
    }
include  extra/vhosts/*.conf; #在主配置文件nginx.conf最后一行加下配置，在http{}内
附配置：
-------------------------------------
[root@master-nginx conf]# grep -Ev '#|^$' nginx.conf
worker_processes  1;
events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
include extra/vhosts/*/*.conf;
}
-------------------------------------
[root@master-nginx conf]# /etc/init.d/nginx -t
nginx: the configuration file /application/nginx-1.10.1/conf/nginx.conf syntax is ok
nginx: configuration file /application/nginx-1.10.1/conf/nginx.conf test is successful
[root@master-nginx conf]# /etc/init.d/nginx -s reload
[root@master-nginx conf]# lsof -i :80
COMMAND  PID  USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
nginx    636  root    6u  IPv4  77178      0t0  TCP *:http (LISTEN)
nginx   5349 nginx    6u  IPv4  77178      0t0  TCP *:http (LISTEN)

#Nginx反向代理负载均衡配置（负载均衡有硬件设备（F5）、软件等）
-------------------
#192.168.1.31:
[root@master-nginx conf]# grep -Ev '#|^$' nginx.conf
worker_processes  1;
events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
include extra/vhosts/*.conf;
include /application/nginx/conf/extra/upstream01.conf;
}
-------------------
[root@master-nginx conf]# cat extra/vhosts/www.conf 
    server {
        listen       81;
        server_name  master-nginx.jack.com;

        location / {
            root   /www/www;
            index  index.html index.htm;
        }
    }
-------------------
[root@master-nginx conf]# cat extra/upstream01.conf 
upstream test_servers {     #定义主机池
        server 192.168.1.31:81 weight=5; 
        server 192.168.1.37:80 weight=15;    #权重越大出现次数越高
}

server { 
        listen 80; 
        server_name nginx1.jack.com;
        location / { 
                proxy_pass http://test_servers;  #将监听到请求转发到这个虚拟主机池
        }  
}
-------------------
#192.168.1.37:
-------------------
[root@slave-nginx conf]# grep -Ev '#|^$' nginx.conf
worker_processes  1;
events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
include extra/vhosts/slave-nginx.jack.com;
}
-------------------
[root@slave-nginx conf]# cat extra/vhosts/slave-nginx.jack.com 
server{
        listen  80;
        server_name     slave-nginx.jack.com;
        location /{
                root /www/www;
                index index.html index.htm;
        }
}
-------------------
注：要达到systemctl管理nginx，编译软件nginx需要在系统服务目录/lib/systemd/system里创建nginx.service文件

#Nginx+Tomcat多实例及负载均衡配置
采用nginx的反向代理负载均衡功能，配合后端的tomcat多实例来实现tomcat WEB服务的负载均衡
安装nginx服务：1.安装所需的pcre库  2.编译安装Nginx服务（见前面）
#安装JDK环境：
因为Tomcat需要JDK的环境，因此在安装之前需要先安装JDK环境，首先下载好相应的JDK软件包。
[root@master-nginx src]# tar -zxf jdk-8u201-linux-x64.tar.gz -C /application/
[root@master-nginx application]# ln -s jdk1.8.0_201/ jdk #软链接
[root@master-nginx application]# sed -i '$a export JAVA_HOME=/application/jdk\nexport PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH\nexport CLASSPATH=.$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/jre/lib:$JAVA_HOME/lib/tools.jar' /etc/profile  #设置变量到/etc/profile
[root@master-nginx application]# tail /etc/profile #查看是否生效
export JAVA_HOME=/application/jdk
export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH
export CLASSPATH=.$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/jre/lib:$JAVA_HOME/lib/tools.jar
[root@master-nginx application]# java -version   #查看是否安装成功
java version "1.8.0_201"
Java(TM) SE Runtime Environment (build 1.8.0_201-b09)
Java HotSpot(TM) 64-Bit Server VM (build 25.201-b09, mixed mode)
#安装配置Tomcat多实例
wget http://mirror.bit.edu.cn/apache/tomcat/tomcat-8/v8.5.38/bin/apache-tomcat-8.5.38.tar.gz #下载地址 
[root@slave-nginx src]# tar -zxf apache-tomcat-8.5.38.tar.gz  -C /application/
[root@slave-nginx src]# cd /application/
[root@slave-nginx application]# ln -s apache-tomcat-8.5.38/ tomcat
[root@master-nginx application]# echo 'export TOMCAT_HOME=/application/tomcat'>>/etc/profile #设置变量
[root@master-nginx conf]# vim /application/tomcat/conf/server.xml #设置tomcat配置文件 
<Server port="8005" shutdown="SHUTDOWN">
<Connector port="8080" protocol="HTTP/1.1"
<Host name="localhost"  appBase="/www/tomcat"
创建站点目录
[root@slave-nginx ROOT]# pwd #mkdir -p /www/tomcat/ROOT
/www/tomcat/ROOT
[root@slave-nginx conf]# echo "hello" > /www/tomcat/ROOT/index.html  
[root@master-nginx conf]# echo "world" > /www/tomcat/ROOT/index.jsp
启动多实例并检查服务是否启动
[root@master-nginx conf]# /application/tomcat/bin/startup.sh 
[root@slave-nginx conf]# /application/tomcat/bin/startup.sh
[root@master-nginx conf]# netstat -tnlp 
tcp6       0      0 127.0.0.1:8005          :::*                    LISTEN      17346/java  
tcp6       0      0 :::8080                 :::*                    LISTEN      17346/java 

配置nginx:
vim /application/nginx/conf/nginx.conf
worker_processes  1;
events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
	upstream web_pools {
        server 127.0.0.1:8081;
        server 127.0.0.1:8082;
	}
    server {
        listen       80;
        server_name  localhost;
        location / {
            root   html;
            index  index.jsp index.html index.htm;
            proxy_pass http://web_pools;
        }
     }
}

#HTTP服务器Nginx服务
Nginx的优势简介：
经常在运维面试中，面试官会问到，你们用什么HTTP服务器啊？为什么用它？？
1、作为WEB服务器而言，Nginx处理静态文件的效率比较高
2、作为代理服务器而言，Nginx可以实现无缓存的反向代理加速来提高WEB站点的运行速度，提高用户访问的体验
3、作为负载均衡服务器而言，支持的应用较多，同时也支持容错功能，自带算法进行负载均衡调度
4、性能方面而言，采用内核poll模型，支持更多的并发连接，官方显示最大可支持50000个并发连接的请求响应，但占用资源很少且非常稳定

Nginx日常配置优化
1、日志切割
由于Nginx没有Apache服务的cronolog日志切割功能，所以需要进行相关优化处理，可以编写脚本来自动切割日志文件
-------------
[root@master-nginx www]# cat nginx-cronlog.sh 
#!/bin/sh
logpath="/logs/nginx"
nginxlogs="/application/nginx/logs/"
mkdir -p  $logpath/$(date +%Y)
mv $nginxlogs/access.log $logpath/$(date +%Y)/access_$(date +%F-%T).log
mv $nginxlogs/error.log $logpath/$(date +%Y)/error_$(date +%F-%T).log
kill -USR1 `cat /application/nginx/logs/nginx.pid`
-------------
最后将脚本执行命令加入到定时任务来实现自动切割日志
##通过USR1信号来控制进程，从而重新生成一个新的日志文件
nginx对进程的控制功能非常强，可以通过信号指令来控制进程，常用信号如下
QUIT 处理完当前请求后关闭进程
HUP 重新加载配置，不会中断用户的访问请求
USR1 用于切割日志
USR2 用于平滑升级可执行程序

2、nginx中FastCGI参数优化
提高nginx环境下PHP的运行效率，可以将下面的配置加入到主配置文件中
-----------------
fastcgi_cache_path /application/nginx/fastcgi_cache_levels=1:2 keys_zone=TEST:10m inactive=5m;
fastcgi_connect_timeout 300;
fastcgi_send_timeout 300;
fastcgi_read_timeout 300;
fastcgi_buffer_size 64k;
fastcgi_buffers 4 64k;
fastcgi_busy_buffers_size 128k;
fastcgi_cache TEST;
fastcgi_cache_valid 200 302 1h;
fastcgi_cache_valid 3011d;
fastcgi_cache_valid any 1m;
##应答缓存时间
-----------------
3、nginx的HTTPgzip模块配置
root@centos7 ~]# /usr/local/nginx/sbin/nginx -V
nginx version: nginx/1.12.0
built by gcc 4.8.5 20150623 (Red Hat 4.8.5-11) (GCC) 
built with OpenSSL 1.0.1e-fips 11 Feb 2013
TLS SNI support enabled
configure arguments: --with-http_stub_status_module --with-http_gzip_static_module --with-http_ssl_module --prefix=/usr/local/nginx
可以看出在编译时已加上此模块，因此只需要在配置文件里进行配置即可
-----------------
	gzip  on;
    gzip_min_length 1k;
    gzip_buffers 4 16k;
    gzip_http_version 1.1;
    gzip_comp_level 2;
    gzip_types text/plain application/x-javascript text/css application/xml;
    gzip_vary on;
-----------------
#Nginx的优化配置详解
基本参数优化
----------------
server_tokens off;
#关闭在错误页面中的nginx版本号，安全性是有好处的
sendfile on;
#传输文件时发挥作用
tcp_nopush on;
#一个数据包里发送所有头文件
tcp_nodelay on;
#不缓存数据
keepalive_timeout 10; 
#在这个超时时间过后关闭客户端链接
client_header_timeout 10; 
#设置请求头的超时时间
client_body_timeout 10;
#设置请求体的超时时间
reset_timeout_connection on;
#开启关闭不响应的客户端连接功能，释放客户端所占的内存空间
send_timeout 10;
#客户端的响应超时时间。如果在这段时间内，客户端没有读取任何数据，nginx就会关闭连接。
limit_conn_zone 
#设置用于保存各种key（比如当前连接数）的共享内存的参数。5m就是5兆字节，这个值应该被设置的足够大以存储（32K5）32byte状态或者（16K5）64byte状态。
limit_conn
#为给定的key设置最大连接数。这里key是addr，我们设置的值是100，也就是说我们允许每一个IP地址最多同时打开有100个连接。
default_type
#设置文件使用的默认的MIME-type。
charset
#设置我们的头文件中的默认的字符集
----------------
Gzip压缩优化
----------------
gzip_types  

#压缩的文件类型
 text/plain text/css 
 application/json 
 application/x-javascript 
 text/xml application/xml 
 application/xml+rss 
 text/javascript
gzip on;
#采用gzip压缩的形式发送数据
gzip_disable "msie6"
#为指定的客户端禁用gzip功能
gzip_static;
#压缩前查找是否有预先gzip处理过的资源
gzip_proxied any;
#允许或者禁止压缩基于请求和响应的响应流
gzip_min_length  1000;
#设置对数据启用压缩的最少字节数
gzip_comp_level 6;
#设置数据的压缩等级
----------------
FastCGI参数优化
----------------
fastcgi_cache_path 
/data/ngx_fcgi_cache 
#缓存路径
levels=2:2
 #目录结构等级
keys_zone=ngx_fcgi_cache:512m 
#关键字区域存储时间
inactive=1d #非活动删除时间	 
fastcgi_connect_timeout 240; 
#连接到后端fastcgi的超时时间
fastcgi_send_timeout 240;
#建立连接后多久不传送数据就断开
fastcgi_read_timeout 240; 
#接收fastcgi应答的超时时间
fastcgi_buffer_size 64k; 
#指定读取fastcgi应答缓冲区大小
fastcgi_buffers 4 64k;
#指定本地缓冲区大小（缓冲FaseCGI应答请求）
fastcgi_busy_buffers_size 128k; 
#繁忙时的buffer，可以是fastcgi_buffer的两倍
fastcgi_temp_file_write_size  128k; 
#在写入缓存文件时用多大的数据块，默认是fastcgi_buffer的两倍
fastcgi_cache mingongge;
#开启缓存时指定一个名称
fastcgi_cache_valid 200 302 1h;
#指定应答码200 302 缓存一小时
fastcgi_cache_valid 301 1d; 
#指定应答码301缓存一天
fastcgi_cache_valid any 1m;
#指定其它应答码缓存一月
----------------
其它参数优化
----------------
open_file_cache
#指定缓存最大数目以及缓存的时间
open_file_cache_valid
#在open_file_cache中指定检测正确信息的间隔时间
open_file_cache_min_uses   
#定义了open_file_cache中指令参数不活动时间期间里最小的文件数
open_file_cache_errors     
#指定了当搜索一个文件时是否缓存错误信息
location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
#指定缓存文件的类型
        {
        expires 3650d;    
           #指定缓存时间
        }
        location ~ .*\.(js|css)?$
        {
        expires 3d;                     
        }
expires有个缺点就是如果更新WEB数据后，用户没有清理缓存，会看到旧的数据，因此建议将时间设置短一点
----------------
优化后完整的配置文件
----------------
user www; 
pid /var/run/nginx.pid; 
worker_processes auto; 
worker_rlimit_nofile 100000; 
events { 
worker_connections 2048; 
multi_accept on; 
use epoll; 
} 
http { 
server_tokens off; 
sendfile on; 
tcp_nopush on; 
tcp_nodelay on; 
access_log off; 
error_log /var/log/nginx/error.log crit; 
keepalive_timeout 10; 
client_header_timeout 10; 
client_body_timeout 10; 
reset_timedout_connection on; 
send_timeout 10; 
limit_conn_zone $binary_remote_addr zone=addr:5m; 
limit_conn addr 100; 
include /etc/nginx/mime.types; 
default_type text/html; 
charset UTF-8; 
gzip on; 
gzip_disable "msie6"; 
gzip_proxied any; 
gzip_min_length 1000; 
gzip_comp_level 6; 
gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript; 
open_file_cache max=100000 inactive=20s; 
open_file_cache_valid 30s; 
open_file_cache_min_uses 2; 
open_file_cache_errors on; 
include /etc/nginx/conf.d/*.conf; 
include /etc/nginx/sites-enabled/*; 
}
----------------

##Nginx+keepalived高可用配置实战
1.环境准备：
下载keepalived软件
wget http://www.keepalived.org/software/keepalived-1.1.17.tar.gz
安装keepalived之前，安装几个依赖包
[root@master-nginx src]# yum install openssl-devel popt* -y
[root@master-nginx src]# tar -zxf keepalived-1.1.17.tar.gz 
[root@master-nginx keepalived-1.1.17]# ./configure 
[root@master-nginx keepalived-1.1.17]# make && make install
规范配置、启动文件路径：
[root@master-nginx keepalived-1.1.17]# cp /usr/local/etc/rc.d/init.d/keepalived /etc/init.d/
[root@master-nginx keepalived-1.1.17]# /bin/cp /usr/local/etc/sysconfig/keepalived /etc/sysconfig/
[root@master-nginx keepalived-1.1.17]# mkdir /etc/keepalived -p
[root@master-nginx keepalived-1.1.17]# /bin/cp /usr/local/etc/keepalived/keepalived.conf /etc/keepalived/
[root@master-nginx keepalived-1.1.17]# /bin/cp /usr/local/sbin/keepalived /usr/sbin/
[root@master-nginx keepalived-1.1.17]# /etc/init.d/keepalived start
LNMP架构应用实战—Nginx反向代理负载均衡配置
2.配置keepalived
---------------
[root@master-nginx keepalived]# cat /etc/keepalived/keepalived.conf
! Configuration File for keepalived

global_defs {
   notification_email {
     abc@qq.com
   }
   notification_email_from test@qq.com
   smtp_server 1.1.1.1
   smtp_connect_timeout 30
   router_id LVS_3
}

vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 19
    priority 150
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 11112
    }
    virtual_ipaddress {
        192.168.1.35
    }
}
---------------
[root@slave-nginx keepalived-1.1.17]# cat /etc/keepalived/keepalived.conf
[root@master-nginx keepalived]# cat keepalived.conf
! Configuration File for keepalived

global_defs {
   notification_email {
     abc@qq.com
   }
   notification_email_from Alexandre.Cassen@firewall.loc
   smtp_server 1.1.1.1
   smtp_connect_timeout 30
   router_id LVS_6
}

vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 19
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 11112
    }
    virtual_ipaddress {
        192.168.1.35
    }
}
---------------
[root@master-nginx keepalived]# /etc/init.d/keepalived restart
Restarting keepalived (via systemctl):  [  OK  ]
[root@slave-nginx keepalived]# /etc/init.d/keepalived restart
Restarting keepalived (via systemctl):  [  OK  ]
[root@master-nginx keepalived]# ip add 
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:50:56:ad:2c:3b brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.31/24 brd 192.168.1.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet 192.168.1.35/32 scope global eth0  #VIP
       valid_lft forever preferred_lft forever
    inet6 fe80::250:56ff:fead:2c3b/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
3.反向代理服务故障自动切换
如果实际生产环境中当主keeplived的服务器nginx服务宕机，但是主又有VIP，这时就出现无法访问的现象，因此可以做如下的配置，使得这种情况可自已切换
-------------------
[root@master-nginx keepalived]# cat check_nginx.sh 
#!/bin/sh
while true
do
        PNUM=`ps -ef|grep nginx|wc -l`
        if [ $PNUM -lt 4 ];then
                /etc/init.d/keepalived stop >/dev/null 2>&1
                kill -9 `cat /run/keepalived.pid ` >/dev/null 2>&1
        fi
        if [ ! -f /run/keepalived.pid ];then
                break 
        fi
        sleep 5
done
-------------------

#Apache和Nginx概述：
#Apache
Apache最常使用的MPM有 prefork和worker两种。至于您的服务器正以哪种方式运行，取决于安装Apache过程中指定的MPM编译参数,在X系统上默认的编译参数为 prefork。
由于大多数的Unix都不支持真正的线程，所以采用了预派生子进程(prefork)方式，像Windows或者Solaris这些支持 线程的平台，基于多进程多线程混合的worker模式是一种不错的选择。Apache中还有一个重要的组件就是APR（Apache portable Runtime Library），即Apache可移植运行库，它是一个对操作系统调用的抽象库，用来实现Apache内部组件对操作系统的使用，提高系统的可移植性。 Apache对于php的解析，就是通过众多Module中的php Module来完成的。
Apache的perfork工作模式生命周期：
 +--------------------------------------------------------------+
   |                 +---------------------+       启动阶段        |
   |                 |    系统启动, 配置     |                      |
   |                 +----------+----------+                      |
   |                            |                                 |
   |                 +----------v----------+                      |
   |                 |      模块的初始化     |                      |
   |                 +-+--------+--------+-+                      |
   |                   |        |        |                        |
   |   +-------------+ | +------v-------+| +--------------+       |
   |   | 子进程初始化  |<+ | 子进程初始化   |+>|  子进程初始化  |       |
   |   +------+------+   +-------+------+  +-------+------+       |
   +--------------------------------------------------------------+
   |          |                  |                 |     运行阶段  |
   |     +----v----+        +----v----+       +----v----+         |
   |     | 请求循环 |        |  请求循环 |       | 请求循环 |         |
   |     +----+----+        +----+----+       +----+----+         |
   |          |                  |                 |              |
   |   +------v------+    +------v------+   +------v------+       |
   |   |  子进程结束   |    |  子进程结束  |   |   子进程结束  |       |
   |   +-------------+    +-------------+   +-------------+       |
   +--------------------------------------------------------------+
prefork的工作原理：
一个单独的控制进程(父进程)负责产生子进程，这些子进程用于监听请求并作出应答。Apache总是试图保持一些备用的 (spare)或是空闲的子进程用于迎接即将到来的请求。这样客户端就无需在得到服务前等候子进程的产生。在Unix系统中，父进程通常以root身份运行以便邦定80端口，而 Apache产生的子进程通常以一个低特权的用户运行。User和Group指令用于配置子进程的低特权用户。运行子进程的用户必须要对他所服务的内容有读取的权限，但是对服务内容之外的其他资源必须拥有尽可能少的权限。
worker的工作原理：
每个进程能够拥有的线程数量是固定的。服务器会根据负载情况增加或减少进程数量。一个单独的控制进程(父进程)负责子进程的建立。每个子进程能够建立ThreadsPerChild数量的服务线程和一个监听线程，该监听线程监听接入请求并将其传递给服务线程处理和应答。Apache总是试图维持一个备用(spare)或是空闲的服务线程池。这样，客户端无须等待新线程或新进程的建立即可得到处理。在Unix中，为了能够绑定80端口，父进程一般都是以root身份启动，随后，Apache以较低权限的用户建立子进程和线程。User和Group指令用于配置Apache子进程的权限。虽然子进程必须对其提供的内容拥有读权限，但应该尽可能给予他较少的特权。另外，除非使用了suexec ，否则，这些指令配置的权限将被CGI脚本所继承。
Event MPM：
这是Apache最新的工作模式，它和worker模式很像，不同的是在于它解决了keep-alive长连接的时候占用线程资源被浪费的问题，在event工作模式中，会有一些专门的线程用来管理这些keep-alive类型的线程，当有真实请求过来的时候，将请求传递给服务器的线程，执行完毕后，又允许它释放。这增强了在高并发场景下的请求处理。在*unix系统中的apache2.4版本使用的就是这个模式。

Apache的运行
启动阶段：
在启动阶段，Apache主要进行配置文件解析(例如http.conf以及Include指令设定的配置文件等)、模块加载(例如mod_php.so,mod_perl.so等)和系统资源初始化（例如日志文件、共享内存段等）工作。在这个阶段，Apache为了获得系统资源最大的使用权限，将以特权用户root（X系统）或超级管理员administrator(Windows系统)完成启动。
 +--------+
       |  开始   |
       +----+---+
            |
 +----------v------------+   解析主配置文件http.conf中配置信息，
 |     解析配置文件        |   像LoadModule, AddType
 +----------+------------+   等指令被加载至内存
            |
 +----------v------------+   依据AddModule, LoadModule等指令
 |   加载静态/动态模块      |   加载Apache模块，像mod_php5.so被
 +----------+------------+   加载至内存，映射到Apache地址空间。
            |
 +----------v------------+   日志文件、共享内存段，数据库链接
 |     系统资源初始化      |    等初始化
 +----------+------------+
            |
        +---v----+
        |  结束   |
        +--------+
运行阶段
在运行阶段，Apache主要工作是处理用户的服务请求。在这个阶段，Apache放弃特权用户级别，使用普通权限，这主要是基于安全性的考虑，防止由于代码的缺陷引起的安全漏洞。

由于Apache的Hook机制，Apache 允许模块(包括内部模块和外部模块，例如mod_php5.so,mod_perl.so等)将自定义的函数注入到请求处理循环中。mod_php5.so/php5apache2.dll就是将所包含的自定义函数，通过Hook机制注入到Apache中，在Apache处理流程的各个阶段负责处理php请求。

Apache将请求处理循环分为11个阶段，依次是：Post-Read-Request，URI Translation，Header Parsing，Access Control，Authentication，Authorization，MIME Type Checking，FixUp，Response，Logging，CleanUp。
Apache处理http请求的生命周期
Post-Read-Request阶段:在正常请求处理流程中，这是模块可以插入钩子的第一个阶段。对于那些想很早进入处理请求的模块来说，这个阶段可以被利用。
URI Translation阶段 : Apache在本阶段的主要工作：将请求的URL映射到本地文件系统。模块可以在这阶段插入钩子，执行自己的映射逻辑。mod_alias就是利用这个阶段工作的。
Header Parsing阶段 : Apache在本阶段的主要工作：检查请求的头部。由于模块可以在请求处理流程的任何一个点上执行检查请求头部的任务，因此这个钩子很少被使用。mod_setenvif就是利用这个阶段工作的。
Access Control阶段 : Apache在本阶段的主要工作：根据配置文件检查是否允许访问请求的资源。Apache的标准逻辑实现了允许和拒绝指令。mod_authz_host就是利用这个阶段工作的。
Authentication阶段 : Apache在本阶段的主要工作：按照配置文件设定的策略对用户进行认证，并设定用户名区域。模块可以在这阶段插入钩子，实现一个认证方法。
Authorization阶段 : Apache在本阶段的主要工作：根据配置文件检查是否允许认证过的用户执行请求的操作。模块可以在这阶段插入钩子，实现一个用户权限管理的方法。
MIME Type Checking阶段 : Apache在本阶段的主要工作：根据请求资源的MIME类型的相关规则，判定将要使用的内容处理函数。标准模块mod_negotiation和mod_mime实现了这个钩子。
FixUp阶段 : 这是一个通用的阶段，允许模块在内容生成器之前，运行任何必要的处理流程。和Post_Read_Request类似，这是一个能够捕获任何信息的钩子，也是最常使用的钩子。
Response阶段 : Apache在本阶段的主要工作：生成返回客户端的内容，负责给客户端发送一个恰当的回复。这个阶段是整个处理流程的核心部分。
Logging阶段 : Apache在本阶段的主要工作：在回复已经发送给客户端之后记录事务。模块可能修改或者替换Apache的标准日志记录。
CleanUp阶段 : Apache在本阶段的主要工作：清理本次请求事务处理完成之后遗留的环境，比如文件、目录的处理或者Socket的关闭等等，这是Apache一次请求处理的最后一个阶段。

#Nginx
Nginx的模块与工作原理
Nginx由内核和模块组成，其中，内核的设计非常微小和简洁，完成的工作也非常简单，仅仅通过查找配置文件将客户端请求映射到一个location block（location是Nginx配置中的一个指令，用于URL匹配），而在这个location中所配置的每个指令将会启动不同的模块去完成相应的工作。

Nginx的模块从结构上分为核心模块、基础模块和第三方模块：
核心模块：HTTP模块、EVENT模块和MAIL模块
基础模块：HTTP Access模块、HTTP FastCGI模块、HTTP Proxy模块和HTTP Rewrite模块，
第三方模块：HTTP Upstream Request Hash模块、Notice模块和HTTP Access Key模块。
Nginx的模块从功能上分为如下三类:
Handlers（处理器模块）。此类模块直接处理请求，并进行输出内容和修改headers信息等操作。Handlers处理器模块一般只能有一个。
Filters （过滤器模块）。此类模块主要对其他处理器模块输出的内容进行修改操作，最后由Nginx输出。
Proxies （代理类模块）。此类模块是Nginx的HTTP Upstream之类的模块，这些模块主要与后端一些服务比如FastCGI等进行交互，实现服务代理和负载均衡等功能。
                 +                    ^
        Http Request |                    |  Http Response
                     |                    |
    +---------+------v-----+         +----+----+
    |  Conf   | Nginx Core |         | FilterN |
    +---------+------+-----+         +----^----+
                     |                    |
                     |               +----+----+
                     |               | Filter2 |
choose a handler     |               +----^----+
based conf           |                    |
                     |               +----+----+
                     |               | Filter1 |
                     |               +----^----+
                     |                    | Generate content
               +-----v--------------------+----+
               |           Handler             |
               +-------------------------------+

Nginx本身做的工作实际很少，当它接到一个HTTP请求时，它仅仅是通过查找配置文件将此次请求映射到一个location block，而此location中所配置的各个指令则会启动不同的模块去完成工作，因此模块可以看做Nginx真正的劳动工作者。通常一个location中的指令会涉及一个handler模块和多个filter模块（当然，多个location可以复用同一个模块）。handler模块负责处理请求，完成响应内容的生成，而filter模块对响应内容进行处理。

Nginx工作流程:
所有实际上的业务处理逻辑都在worker进程。worker进程中有一个函数，执行无限循环，不断处理收到的来自客户端的请求，并进行处理，直到整个nginx服务被停止。Worker中这个函数执行内容如下：
操作系统提供的机制（例如epoll, kqueue等）产生相关的事件。
接收和处理这些事件，如是接受到数据，则产生更高层的request对象。
处理request的header和body。
产生响应，并发送回客户端。
完成request的处理。
重新初始化定时器及其他事件。

FastCGI(负责动态文件)
FastCGI是一个可伸缩地、高速地在HTTP server和动态脚本语言间通信的接口。多数流行的HTTP server都支持FastCGI，包括Apache、Nginx和lighttpd等。同时，FastCGI也被许多脚本语言支持，其中就有PHP。

FastCGI是从CGI发展改进而来的。传统CGI接口方式的主要缺点是性能很差，因为每次HTTP服务器遇到动态程序时都需要重新启动脚本解析器来执行解析，然后将结果返回给HTTP服务器。这在处理高并发访问时几乎是不可用的。另外传统的CGI接口方式安全性也很差，现在已经很少使用了。

FastCGI接口方式采用C/S结构，可以将HTTP服务器和脚本解析服务器分开，同时在脚本解析服务器上启动一个或者多个脚本解析守护进程。当HTTP服务器每次遇到动态程序时，可以将其直接交付给FastCGI进程来执行，然后将得到的结果返回给浏览器。这种方式可以让HTTP服务器专一地处理静态请求或者将动态脚本服务器的结果返回给客户端，这在很大程度上提高了整个应用系统的性能。

Nging和FastCGI合作：
Nginx不支持对外部程序的直接调用或者解析，所有的外部程序（包括PHP）必须通过FastCGI接口来调用。FastCGI接口在Linux下是socket（这个socket可以是文件socket，也可以是ip socket）。

接下来以Nginx下PHP的运行过程来说明。PHP-FPM是管理FastCGI的一个管理器，它作为PHP的插件存在。
FastCGI进程管理器php-fpm自身初始化，启动主进程php-fpm和启动start_servers个CGI 子进程。主进程php-fpm主要是管理fastcgi子进程，监听9000端口。fastcgi子进程等待来自Web Server的连接。
当客户端请求到达Web Server Nginx是时，Nginx通过location指令，将所有以php为后缀的文件都交给127.0.0.1:9000来处理，即Nginx通过location指令，将所有以php为后缀的文件都交给127.0.0.1:9000来处理。
FastCGI进程管理器PHP-FPM选择并连接到一个子进程CGI解释器。Web server将CGI环境变量和标准输入发送到FastCGI子进程。
FastCGI子进程完成处理后将标准输出和错误信息从同一连接返回Web Server。当FastCGI子进程关闭连接时，请求便告处理完成。
FastCGI子进程接着等待并处理来自FastCGI进程管理器（运行在 WebServer中）的下一个连接。

#Apache和Nginx比较
功能对比：
Nginx和Apache一样，都是HTTP服务器软件，在功能实现上都采用模块化结构设计，都支持通用的语言接口，如PHP、Perl、Python等，同时还支持正向和反向代理、虚拟主机、URL重写、压缩传输、SSL加密传输等。
在功能实现上，Apache的所有模块都支持动、静态编译，而Nginx模块都是静态编译的，
对FastCGI的支持，Apache对Fcgi的支持不好，而Nginx对Fcgi的支持非常好；
在处理连接方式上，Nginx支持epoll，而Apache却不支持；
在空间使用上，Nginx安装包仅仅只有几百K，和Nginx比起来Apache绝对是庞然大物。

#Nginx相对apache的优点
轻量级，同样起web 服务，比apache 占用更少的内存及资源
静态处理，Nginx 静态处理性能比 Apache 高 3倍以上
抗并发，nginx 处理请求是异步非阻塞的，而apache则是阻塞型的，在高并发下nginx 能保持低资源低消耗高性能。在- - Apache+PHP（prefork）模式下，如果PHP处理慢或者前端压力很大的情况下，很容易出现Apache进程数飙升，从而拒绝服务的现象。
高度模块化的设计，编写模块相对简单
社区活跃，各种高性能模块出品迅速啊
#apache相对nginx的优点
rewrite，比nginx 的rewrite 强大
模块超多，基本想到的都可以找到
少bug，nginx的bug相对较多
超稳定
Apache对PHP支持比较简单，Nginx需要配合其他后端用
#选择Nginx的优势所在
作为Web服务器: Nginx处理静态文件、索引文件，自动索引的效率非常高。
作为代理服务器，Nginx可以实现无缓存的反向代理加速，提高网站运行速度。
作为负载均衡服务器，Nginx既可以在内部直接支持Rails和PHP，也可以支持HTTP代理服务器对外进行服务，同时还支持简单的容错和利用算法进行负载均衡。
在性能方面，Nginx是专门为性能优化而开发的，在实现上非常注重效率。它采用内核Poll模型(epoll and kqueue )，可以支持更多的并发连接，最大可以支持对50 000个并发连接数的响应，而且只占用很低的内存资源。
在稳定性方面，Nginx采取了分阶段资源分配技术，使得CPU与内存的占用率非常低。Nginx官方表示，Nginx保持10 000个没有活动的连接，而这些连接只占用2.5MB内存，因此，类似DOS这样的攻击对Nginx来说基本上是没有任何作用的。
在高可用性方面，Nginx支持热部署，启动速度特别迅速，因此可以在不间断服务的情况下，对软件版本或者配置进行升级，即使运行数月也无需重新启动，几乎可以做到7×24小时不间断地运行。
#同时使用Nginx和Apache
由于Nginx和Apache各自的优势，现在很多人选择了让两者在服务器中共存。在服务器端让Nginx在前，Apache在后。由Nginx做负载均衡和反向代理，并且处理静态文件，将动态请求（如PHP应用）交给Apache去处理。


###基于 Nginx 的 HTTPS 性能优化实践
#HTTP/2
相比廉颇老矣的 HTTP/1.x，HTTP/2 在底层传输做了很大的改动和优化包括有：
每个服务器只用一个连接，节省多次建立连接的时间，在TLS上效果尤为明显
加速 TLS 交付，HTTP/2 只耗时一次 TLS 握手，通过一个连接上的多路利用实现最佳性能
更安全，通过减少 TLS 的性能损失，让更多应用使用 TLS，从而让用户信息更安全
例子：在 Akamai 的 HTTP/2 DEMO中，加载300张图片，HTTP/2 的优越性极大的显现了出来，在 HTTP/1.X 需要 14.8s 的操作中，HTTP/2 仅需不到1s。
HTTP/2 现在已经获得了绝大多数的现代浏览器的支持。只要我们保证 Nginx 版本大于 1.9.5 即可。当然建议保持最新的 Nginx 稳定版本以便更新相关补丁。同时 HTTP/2 在现代浏览器的支持上还需要 OpenSSL 版本大于 1.0.2。
#TLS 1.3
和 HTTP/1.x 一样，目前受到主流支持的 TLS 协议版本是 1.1 和 1.2，分别发布于 2006年和2008年，也都已经落后于时代的需求了。在2018年8月份，IETF终于宣布TLS 1.3规范正式发布了，标准规范（Standards Track）定义在 rfc8446。
#TLS 1.3 相较之前版本的优化内容有：
握手时间：同等情况下，TLSv1.3 比 TLSv1.2 少一个 RTT
应用数据：在会话复用场景下，支持 0-RTT 发送应用数据
握手消息：从 ServerHello 之后都是密文。
会话复用机制：弃用了 Session ID 方式的会话复用，采用 PSK 机制的会话复用。
密钥算法：TLSv1.3 只支持 PFS （即完全前向安全）的密钥交换算法，禁用 RSA 这种密钥交换算法。对称密钥算法只采用 AEAD 类型的加密算法，禁用CBC 模式的 AES、RC4 算法。
密钥导出算法：TLSv1.3 使用新设计的叫做 HKDF 的算法，而 TLSv1.2 是使用PRF算法，稍后我们再来看看这两种算法的差别。
#总结一下就是在更安全的基础上还做到了更快，目前 TLS 1.3 的重要实现是 OpenSSL 1.1.1 开始支持了，并且 1.1.1 还是一个 LTS 版本，未来的 RHEL8、Debian10  都将其作为主要支持版本。在 Nginx 上的实现需要 Nginx  1.13+。
#Brotli
Brotli 是由 Google 于 2015 年 9 月推出的无损压缩算法，它通过用变种的 LZ77 算法，Huffman 编码和二阶文本建模进行数据压缩，是一种压缩比很高的压缩方法。
Brotli特点：
针对常见的 Web 资源内容，Brotli 的性能要比 Gzip 好 17-25%；
Brotli 压缩级别为 1 时，压缩速度是最快的，而且此时压缩率比 gzip 压缩等级为 9（最高）时还要高；
在处理不同 HTML 文档时，brotli 依然提供了非常高的压缩率；
相较 GZIP：
JavaScript 上缩小 14%
HTML上缩小 21%
CSS上缩小 17%
#Brotli 的支持必须依赖 HTTPS，不过换句话说就是只有在 HTTPS 下才能实现 Brotli。
#ECC 证书
椭圆曲线密码学（Elliptic curve cryptography，缩写为ECC），一种建立公开金钥加密的算法，基于椭圆曲线数学。椭圆曲线在密码学中的使用是在1985年由Neal Koblitz和Victor Miller分别独立提出的。
内置 ECDSA 公钥的证书一般被称之为 ECC 证书，内置 RSA 公钥的证书就是 RSA 证书。由于 256 位 ECC Key 在安全性上等同于 3072 位 RSA Key，加上 ECC 运算速度更快，ECDHE 密钥交换 + ECDSA 数字签名无疑是最好的选择。由于同等安全条件下，ECC 算法所需的 Key 更短，所以 ECC 证书文件体积比 RSA 证书要小一些。
ECC 证书不仅仅可以用于 HTTPS 场景当中，理论上可以代替所有 RSA 证书的应用场景，如 SSH 密钥登陆、SMTP 的 TLS 发件等。
#使用 ECC 证书有两个点需要注意：
一、 并不是每一个证书类型都支持的，一般商业证书中带增强型字眼的才支持ECC证书的签发。
二、 ECC证书在一些场景中可能还不被支持，因为一些产品或者软件可能还不支持 ECC。 这时候就要虚线解决问题了，例如针对部分旧操作系统和浏览器不支持ECC，可以通过ECC+RSA双证书模式来解决问题。

#安装
下载源码
综合上述我们要用到的新特性，我们整合一下需求：
HTTP/2  要求 Nginx 1.9.5+，，OpenSSL 1.0.2+
TLS 1.3  要求 Nginx 1.13+，OpenSSL 1.1.1+
Brotli 要求 HTTPS，并在 Nginx 中添加扩展支持
ECC 双证书 要求 Nginx 1.11+
这里 Nginx，我个人推荐 1.15+，因为 1.14 虽然已经能支持TLS1.3了，但是一些 TLS1.3 的进阶特性还只在 1.15+ 中提供。
#我们定义一下版本号：
[root@master-nginx src]# OpenSSLVersion='openssl-1.1.1a'
[root@master-nginx src]# nginxVersion='nginx-1.14.1'
#Nginx
[root@master-nginx src]# wget http://nginx.org/download/$nginxVersion.tar.gz
[root@master-nginx src]# tar -zxf $nginxVersion.tar.gz
#OpenSSL：
[root@master-nginx src]# wget https://www.openssl.org/source/$OpenSSLVersion.tar.gz
[root@master-nginx src]# tar -zxf $OpenSSLVersion.tar.gz
#Brotli
[root@master-nginx src]# git clone https://github.com/eustas/ngx_brotli.git
[root@master-nginx src]# cd ngx_brotli/
[root@master-nginx ngx_brotli]# git submodule update --init --recursive #初始化本地配置文件并检出父仓库列出的commit
#编译
[root@master-nginx src]# cd $nginxVersion
[root@master-nginx nginx-1.14.1]# ./configure \
> --prefix=/usr/local/nginx \  #编辑后安装的目录位置
> --with-openssl=/download/src/$OpenSSLVersion \  #指定单独编译入OpenSSL的源码位置
> --with-openssl-opt=enable-tls1_3 \  #开启TLS 1.3支持
> --with-http_v2_module \  #开启HTTP/2
> --with-http_ssl_module \  #开启HTTPS支持
> --with-http_gzip_static_module \  #开启GZip压缩
> --add-module=/download/src/ngx_brotli/ #编译入ngx_broti扩展
[root@master-nginx nginx-1.14.1]# make && make install 
[root@master-nginx nginx-1.14.1]# [ -z "`grep ^'export PATH=' /etc/profile`" ] && echo "export PATH=/usr/local/nginx/sbin:\$PATH" >> /etc/profile  #设置Nginx变量
[root@master-nginx nginx-1.14.1]# [ -n "`grep ^'export PATH=' /etc/profile`" -a -z "`grep /usr/local/nginx/ /etc/profile`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=/usr/local/nginx/sbin:\1@" /etc/profile
[root@master-nginx nginx-1.14.1]# . /etc/profile
[root@master-nginx nginx-1.14.1]# nginx -t
nginx: the configuration file /usr/local/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /usr/local/nginx/conf/nginx.conf test is successful
[root@master-nginx nginx-1.14.1]# nginx #启动nginx
[root@master-nginx nginx-1.14.1]# mkdir /data/wwwlogs/ -p  #创建相关目录
[root@master-nginx nginx-1.14.1]# mkdir /data/wwwroot/default/ -p
[root@master-nginx nginx-1.14.1]# cp /usr/local/nginx/html/index.html /data/wwwroot/default/
#配置
HTTP2：
[root@master-nginx nginx]# vim conf/nginx.conf
       listen       443 ssl http2; #开启http2
只要在 server{}  下的lisen 443 ssl 后添加  http2 即可。而且从 1.15 开始，只要写了这一句话就不需要再写 ssl on 了，很多小伙伴可能用了 1.15+ 以后衍用原配置文件会报错，就是因为这一点。
开启TLS 1.3:
[root@master-nginx nginx]# vim conf/nginx.conf
 ssl_protocols   TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
------------
[root@master-nginx conf]# grep -E -v '#|^$' nginx.conf  #完全nginx.conf配置
events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    server {
        listen       443 ssl http2;
        server_name master-nginx.jack.com jack.com;
        ssl_session_cache shared:SSL:1m;
        ssl_session_timeout 5m;
        keepalive_timeout 75s;
        keepalive_requests 100;
        ssl_protocols   TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
        ssl_ciphers     'TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:TLS13-AES-128-CCM-8-SHA256:TLS13-AES-128-CCM-SHA256:EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5';
        gzip on;
        gzip_comp_level 6;
        gzip_min_length 1k;
        gzip_types text/plain text/css text/xml text/javascript text/x-component application/json application/javascript application/x-javascript application/xml application/xhtml+xml application/rss+xml application/atom+xml application/x-font-ttf application/vnd.ms-fontobject image/svg+xml image/x-icon font/opentype;
        brotli on;
        brotli_comp_level 6;
        brotli_min_length 1k;
        brotli_types text/plain text/css text/xml text/javascript text/x-component application/json application/javascript application/x-javascript application/xml application/xhtml+xml application/rss+xml application/atom+xml application/x-font-ttf application/vnd.ms-fontobject image/svg+xml image/x-icon font/opentype; 
        location / {
            root   html;
            index  index.html index.htm;
        }
    }
}
------------

ECC：
生成 key
openssl ecparam -genkey -name prime256v1 -out master-nginx.jack.com-ecc.key
-name 参数 prime256v1 或者secp384r1。 256bit 其实安全性和速度都足够了
生成 CSR
openssl req -new -sha256 -key master-nginx.jack.com-ecc.key -out master-nginx.jack.com-ecc.csr 

#反向代理
server 
{
listen  80;                                                         
server_name  localhost;                                               
client_max_body_size 1024M;
location / {
proxy_pass http://localhost:8080;
proxy_set_header Host $host:$server_port;
	}
}
保存配置文件后启动Nginx，这样当我们访问localhost的时候，就相当于访问localhost:8080了
#负载均衡
#1.RR（默认）
每个请求按时间顺序逐一分配到不同的后端服务器，如果后端服务器down掉，能自动剔除。
简单配置
upstream test {
server localhost:8080;
server localhost:8081;
}
#2.权重
指定轮询几率，weight和访问比率成正比，用于后端服务器性能不均的情况。例如
upstream test {
server localhost:8080 weight=9;
server localhost:8081 weight=1;
}
那么10次一般只会有1次会访问到8081，而有9次会访问到8080
#3.ip_hash
上面的2种方式都有一个问题，那就是下一个请求来的时候请求可能分发到另外一个服务器，当我们的程序不是无状态的时候（采用了session保存数据），这时候就有一个很大的很问题了，比如把登录信息保存到了session中，那么跳转到另外一台服务器的时候就需要重新登录了，所以很多时候我们需要一个客户只访问一个服务器，那么就需要用iphash了，iphash的每个请求按访问ip的hash结果分配，这样每个访客固定访问一个后端服务器，可以解决session的问题。
ip_hash设置：
upstream test {
ip_hash;  #加入ip_hash即可
server localhost:8080;
server localhost:8081;
}
#4、fair（第三方）
按后端服务器的响应时间来分配请求，响应时间短的优先分配。
upstream test {
fair; 
server localhost:8080;
server localhost:8081;
}
#5、url_hash（第三方）
按访问url的hash结果来分配请求，使每个url定向到同一个后端服务器，后端服务器为缓存时比较有效。 在upstream中加入hash语句，server语句中不能写入weight等其他的参数，hash_method是使用的hash算法
upstream test {
hash $request_uri; 
hash_method crc32; 
server localhost:8080;
server localhost:8081;
}
以上5种负载均衡各自适用不同情况下使用，所以可以根据实际情况选择使用哪种策略模式,不过fair和url_hash需要安装第三方模块才能使用，由于本文主要介绍Nginx能做的事情，所以Nginx安装第三方模块不会再本文介绍

##HTTP服务器
Nginx本身也是一个静态资源的服务器，当只有静态资源的时候，就可以使用Nginx来做服务器，同时现在也很流行动静分离，就可以通过Nginx来实现，首先看看Nginx做静态资源服务器：
---------------
server {
    listen       
80
;                                                         
    server_name  localhost;                                               
    client_max_body_size 
1024M
;
    location / {
           root   e:wwwroot;
           index  index.html;
       }
}
这样如果访问http://localhost 就会默认访问到E盘wwwroot目录下面的index.html，如果一个网站只是静态页面的话，那么就可以通过这种方式来实现部署
---------------
动静分离是让动态网站里的动态网页根据一定规则把不变的资源和经常变的资源区分开来，动静资源做好了拆分以后，我们就可以根据静态资源的特点将其做缓存操作，这就是网站静态化处理的核心思路：
upstream test{  
   server localhost:8080;  
   server localhost:8081;  
}   
server {  
    listen       80;  
    server_name  localhost;  
    location / {  
        root   e:wwwroot;  
        index  index.html;  
    }      
# 所有静态请求都由nginx处理，存放目录为html  
    location ~ .(gif|jpg|jpeg|png|bmp|swf|css|js)$ {  
        root    e:wwwroot;  
    }      
# 所有动态请求都转发给tomcat处理  
    location ~ .(jsp|do)$ {  
            proxy_pass  http://test;  
    }  
    error_page   500 502 503 504 /50x.html;  
    location = /50x.html {  
        root   e:wwwroot;  
    }  
}  

这样我们就可以吧HTML以及图片和css以及js放到wwwroot目录下，而tomcat只负责处理jsp和请求，例如当我们后缀为gif的时候，Nginx默认会从wwwroot获取到当前请求的动态图文件返回，当然这里的静态文件跟Nginx是同一台服务器，我们也可以在另外一台服务器，然后通过反向代理和负载均衡配置过去就好了，只要搞清楚了最基本的流程，很多配置就很简单了，另外localtion后面其实是一个正则表达式，所以非常灵活
---------------

##深度总结
#Nginx的Master-Worker模式
nginx进程:启动Nginx后，其实就是在80端口启动了Socket服务进行监听,此时就有master和work两个进程。
Master进程的作用是？
读取并验证配置文件nginx.conf；管理worker进程；
Worker进程的作用是？
每一个Worker进程都维护一个线程（避免线程切换），处理连接和请求；注意Worker进程的个数由配置文件决定，一般和CPU个数相关（有利于进程切换），配置几个就有几个Worker进程。
#Nginx如何做到热部署？
所谓热部署，就是配置文件nginx.conf修改后，不需要stop Nginx，不需要中断请求，就能让配置文件生效！（nginx -s reload 重新加载/nginx -t检查配置/nginx -s stop）
方案一：
修改配置文件nginx.conf后，主进程master负责推送给woker进程更新配置信息，woker进程收到信息后，更新进程内部的线程信息。（有点valatile的味道）
方案二：
修改配置文件nginx.conf后，重新生成新的worker进程，当然会以新的配置进行处理请求，而且新的请求必须都交给新的worker进程，至于老的worker进程，等把那些以前的请求处理完毕后，kill掉即可。
Nginx采用的就是方案二来达到热部署的！
#Nginx如何做到高并发下的高效处理？
上文已经提及Nginx的worker进程个数与CPU绑定、worker进程内部包含一个线程高效回环处理请求，这的确有助于效率，但这是不够的。
作为专业的程序员，我们可以开一下脑洞：BIO/NIO/AIO、异步/同步、阻塞/非阻塞...
要同时处理那么多的请求，要知道，有的请求需要发生IO，可能需要很长时间，如果等着它，就会拖慢worker的处理速度。
Nginx采用了Linux的epoll模型，epoll模型基于事件驱动机制，它可以监控多个事件是否准备完毕，如果OK，那么放入epoll队列中，这个过程是异步的。worker只需要从epoll队列循环处理即可。
#Nginx挂了怎么办？
Nginx既然作为入口网关，很重要，如果出现单点问题，显然是不可接受的。
答案是：Keepalived+Nginx实现高可用。
Keepalived是一个高可用解决方案，主要是用来防止服务器单点发生故障，可以通过和Nginx配合来实现Web服务的高可用。（其实，Keepalived不仅仅可以和Nginx配合，还可以和很多其他服务配合）
Keepalived+Nginx实现高可用的思路：
第一：请求不要直接打到Nginx上，应该先通过Keepalived（这就是所谓虚拟IP，VIP）
第二：Keepalived应该能监控Nginx的生命状态（提供一个用户自定义的脚本，定期检查Nginx进程状态，进行权重变化,，从而实现Nginx故障切换）
##主战场：nginx.conf
#把Nginx作为web server来处理静态资源。
第一：location可以进行正则匹配，应该注意正则的几种形式以及优先级。（这里不展开）
第二：Nginx能够提高速度的其中一个特性就是：动静分离，就是把静态资源放到Nginx上，由Nginx管理，动态请求转发给后端。
第三：我们可以在Nginx下把静态资源、日志文件归属到不同域名下（也即是目录），这样方便管理维护。
第四：Nginx可以进行IP访问控制，有些电商平台，就可以在Nginx这一层，做一下处理，内置一个黑名单模块，那么就不必等请求通过Nginx达到后端在进行拦截，而是直接在Nginx这一层就处理掉。
#反向代理【proxy_pass】
所谓反向代理，很简单，其实就是在location这一段配置中的root替换成proxy_pass即可。root说明是静态资源，可以由Nginx进行返回；而proxy_pass说明是动态请求，需要进行转发，比如代理到Tomcat上。
反向代理，上面已经说了，过程是透明的，比如说request -> Nginx -> Tomcat，那么对于Tomcat而言，请求的IP地址就是Nginx的地址，而非真实的request地址，这一点需要注意。不过好在Nginx不仅仅可以反向代理请求，还可以由用户自定义设置HTTP HEADER。
#负载均衡【upstream】
上面的反向代理中，我们通过proxy_pass来指定Tomcat的地址，很显然我们只能指定一台Tomcat地址，那么我们如果想指定多台来达到负载均衡呢？
第一，通过upstream来定义一组Tomcat，并指定负载策略（IPHASH、加权论调、最少连接），健康检查策略（Nginx可以监控这一组Tomcat的状态）等。
第二，将proxy_pass替换成upstream指定的值即可。
负载均衡可能带来的问题？
负载均衡所带来的明显的问题是，一个请求，可以到A server，也可以到B server，这完全不受我们的控制，当然这也不是什么问题，只是我们得注意的是：用户状态的保存问题，如Session会话信息，不能在保存到服务器上。
#缓存
缓存，是Nginx提供的，可以加快访问速度的机制，说白了，在配置上就是一个开启，同时指定目录，让缓存可以存储到磁盘上。具体配置，大家可以参考Nginx官方文档，这里就不在展开了。

##提高Nginx服务器硬度的12个技巧
#1: 保持Nginx的及时升级
目前Nginx的稳定版本为1.14.0，最好升级到最新版本，看官方的release note你会发现他们修复了很多bug，任何一款产品的生产环境都不想在这样的bug风险下运行的。
另外，虽然安装包安装比通过源代码编译安装更容易，但后一个选项有两个优点：
1）它允许您将额外的模块添加到Nginx中（如more_header，mod_security），
2）它总是提供比安装包更新的版本，在Nginx网站上可看release note。
#2: 去掉不用的Nginx模块
在编译安装时，执行./configure方法时加上以下配置指令，可以显式的删除不用的模块：
./configure --without-module1 --without-module2 --without-module3
例如：
./configure --without-http_dav_module --withouthttp_spdy_module
#注意事项：配置指令是由模块提供的。确保你禁用的模块不包含你需要使用的指令！在决定禁用模块之前，应该检查Nginx文档中每个模块可用的指令列表。
#3: 在Nginx配置中禁用server_tokens项
server_tokens在打开的情况下会使404页面显示Nginx的当前版本号。这样做显然不安全，因为黑客会利用此信息尝试相应Nginx版本的漏洞。
只需要在nginx.conf中http模块设置server_tokens off即可。重启Nginx后生效。
#4: 禁止非法的HTTP User Agents
User Agent是HTTP协议中对浏览器的一种标识，禁止非法的User Agent可以阻止爬虫和扫描器的一些请求，防止这些请求大量消耗Nginx服务器资源。
为了更好的维护，最好创建一个文件，包含不期望的user agent列表例如/etc/nginx/blockuseragents.rules包含如下内容：
map $http_user_agent $blockedagent {
    default 0;
    ~*malicious 1;
    ~*bot 1;
    ~*backdoor 1;
    ~*crawler 1;
    ~*bandit 1;
}
然后将如下语句放入配置文件的server模块内：
include /etc/nginx/blockuseragents.rules;
并加入if语句设置阻止后进入的页面：
if($blockedagent){
	return 403;
}
#5: 禁掉不需要的 HTTP 方法
例如一些web站点和应用，可以只支持GET、POST和HEAD方法。
在配置文件中的server模块加入如下方法可以阻止一些欺骗攻击
if ($request_method !~ ^(GET|HEAD|POST)$) {
return 444;
}
#6: 设置缓冲区容量上限
这样的设置可以阻止缓冲区溢出攻击（同样是Server模块）
client_body_buffer_size 1k;
client_header_buffer_size 1k;
client_max_body_size 1k;
large_client_header_buffers 2 1k;
#设置后，不管多少HTTP请求都不会使服务器系统的缓冲区溢出了。
#7: 限制最大连接数
在http模块内，server模块外设置limit_conn_zone，可以设置连接的IP
在http，server或location模块设置limit_conn，可以设置IP的最大连接数
例如：
limit_conn_zone $binary_remote_addr zone=addr:5m; #server模块外设置
limit_conn addr 1;  #server模块内设置
#8: 设置日志监控
error_log /var/www/logs/tecmintlovesnginx.error.log #server加入错误日志地址
access_log /var/www/logs/tecmintlovesnginx.access.log #server加入访问日志地址
#9: 阻止图片外链自你的服务器
图片外链自你的服务器这样做显然会增加你服务器的带宽压力。
假设你有一个img目录用来存储图片，你自己的IP是192.168.0.25，加入如下配置可以防止外链
location /img/ {
      valid_referers none blocked 192.168.0.25;
        if ($invalid_referer) {
          return 403;
      }
}
#10: 禁止 SSL 并且只打开 TLS
只要可以的话，尽量避免使用SSL，要用TLS替代，以下设置可以放在Server模块内：
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
11: 做证书加密（HTTPS）
server {
      listen 192.168.0.25:443 ssl;
      server_tokens off;
      server_name tecmintlovesnginx.com www.tecmintlovesnginx.com;
      root /var/www/tecmintlovesnginx.com/public_html;
      ssl_certificate /etc/nginx/sites-enabled/certs/tecmintlovesnginx.crt;
      ssl_certificate_key /etc/nginx/sites-enabled/certs/tecmintlovesnginx.key;
      ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
}
#12: 重定向HTTP请求到HTTPS
在第11点基础上增加
server {
      listen 192.168.0.25:443 ssl;
      server_tokens off;
      server_name tecmintlovesnginx.com www.tecmintlovesnginx.com;
	  return 301 https://$server_name$request_uri;
      root /var/www/tecmintlovesnginx.com/public_html;
      ssl_certificate /etc/nginx/sites-enabled/certs/tecmintlovesnginx.crt;
      ssl_certificate_key /etc/nginx/sites-enabled/certs/tecmintlovesnginx.key;
      ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
}


###1分钟搞定 Nginx 版本的平滑升级与回滚
#升级Nginx到新的版本和如何回滚至旧版本。
安装1.10.1版本：
[root@master-nginx nginx-1.10.1]# ./configure \
> --user=nginx \
> --group=nginx \
> --prefix=/application/nginx-1.10.1 \
> --with-http_stub_status_module \
> --with-http_ssl_module \
> --with-pcre=/download/src/pcre-8.43
#pcre注意这里不是安装后的目录，而是源码目录
安装1.14.1版本：
[root@master-nginx nginx-1.14.1]# ./configure \
> --user=nginx \
> --group=nginx \
> --prefix=/application/nginx-1.14.1 \
> --with-http_stub_status_module \
> --with-http_ssl_module \
> --with-pcre=/download/src/pcre-8.43
#pcre注意这里不是安装后的目录，而是源码目录
平滑升级：
[root@master-nginx application]# nginx/sbin/nginx 
[root@master-nginx application]# netstat -tnlp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      21437/nginx: master 
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      8289/sshd           
tcp6       0      0 :::22                   :::*                    LISTEN      8289/sshd           
[root@master-nginx application]# nginx/sbin/nginx -v
nginx version: nginx/1.10.1
[root@master-nginx application]# cd nginx/sbin/
[root@master-nginx sbin]# ls
nginx
[root@master-nginx sbin]# mv nginx nginx-1.10.1
[root@master-nginx sbin]# ls
nginx-1.10.1
[root@master-nginx sbin]# cp /application/nginx-1.14.1/sbin/nginx .
[root@master-nginx sbin]# ls
nginx  nginx-1.10.1
[root@master-nginx sbin]# ps -ef | grep nginx
root     14010     1  0 17:46 ?        00:00:00 nginx: master process ./nginx
nginx    14011 14010  0 17:46 ?        00:00:00 nginx: worker process
root     14106 12408  0 17:47 pts/0    00:00:00 grep nginx
[root@master-nginx sbin]# ps -ef | grep nginx
root     21437     1  0 18:07 ?        00:00:00 nginx: master process nginx/sbin/nginx
nginx    21438 21437  0 18:07 ?        00:00:00 nginx: worker process
root     21506 12408  0 18:08 pts/0    00:00:00 grep nginx
[root@master-nginx sbin]# kill -USR2 21437
[root@master-nginx sbin]# ps -ef | grep nginx
root     21437     1  0 18:07 ?        00:00:00 nginx: master process nginx/sbin/nginx
nginx    21438 21437  0 18:07 ?        00:00:00 nginx: worker process
root     21532 21437  0 18:09 ?        00:00:00 nginx: master process nginx/sbin/nginx
nginx    21533 21532  0 18:09 ?        00:00:00 nginx: worker process
root     21537 12408  0 18:09 pts/0    00:00:00 grep nginx
[root@master-nginx sbin]# kill -WINCH 21437
[root@master-nginx sbin]# ps -ef | grep nginx
root     21437     1  0 18:07 ?        00:00:00 nginx: master process nginx/sbin/nginx
root     21532 21437  0 18:09 ?        00:00:00 nginx: master process nginx/sbin/nginx
nginx    21533 21532  0 18:09 ?        00:00:00 nginx: worker process
root     21554 12408  0 18:09 pts/0    00:00:00 grep nginx
[root@master-nginx sbin]# ls
注：如果在版本升级完成后，没有任何问题，需要关闭老的master进程的话，可以使用下面的命令：
kill -QUIT 14010

</pre>