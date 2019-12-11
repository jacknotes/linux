#nginx 
<pre>
#nginx:
io复用
作业：
	keepalivd+nginx：实现高可用
	corosync+nginx：也可以实现高可用
nginx的应用：
	web服务器
	反向代理：web、mail
nginx优势：
File AIO
Asynchronous
Event-driven edge trigger
淘宝封装nginx:Tengines
支持FastCGI(php),uwsgi(python),SCGI
事件驱动模型：epoll(linux2.6+),kqueue(freeBSD4.1+),/dev/poll(solaris7 11/99+)
sendfile,sendfile64:支持将文件通过内核封装直接响应客户端。
#部署nginx:
groupadd -r -g 1000 nginx
useradd -r -g 1000 -u 1000 nginx 
[root@lamp nginx-1.16.0]# yum groupinstall -y "Development Tools" "Development and Creative Workstation "
[root@lamp nginx-1.16.0]# ./configure  --prefix=/usr/local/nginx  --sbin-path=/usr/local/nginx/sbin/nginx --conf-path=/usr/local/nginx/conf/nginx.conf --error-log-path=/var/log/nginx/error.log  --http-log-path=/var/log/nginx/access.log  --pid-path=/var/run/nginx/nginx.pid --lock-path=/var/lock/nginx.lock  --user=nginx --group=nginx --with-http_ssl_module --with-http_stub_status_module --with-http_gzip_static_module --http-client-body-temp-path=/var/tmp/nginx/client/ --http-proxy-temp-path=/var/tmp/nginx/proxy/ --http-fastcgi-temp-path=/var/tmp/nginx/fcgi/ --http-uwsgi-temp-path=/var/tmp/nginx/uwsgi --http-scgi-temp-path=/var/tmp/nginx/scgi --with-pcre
[root@lamp nginx-1.16.0]# make && make install
--------------nginx启动脚本----------------
[root@lamp init.d]# cat nginxd 
#!/bin/sh
#
# nginx - this script starts and stops the nginx daemon
#
# chkconfig:   - 85 15
# description:  NGINX is an HTTP(S) server, HTTP(S) reverse \
#               proxy and IMAP/POP3 proxy server
# processname: nginx
# config:      /usr/local/nginx/conf/nginx.conf
# pidfile:     /var/run/nginx/nginx.pid

# Source function library.
. /etc/rc.d/init.d/functions

# Source networking configuration.
. /etc/sysconfig/network

# Check that networking is up.
[ "$NETWORKING" = "no" ] && exit 0

nginx="/usr/local/nginx/sbin/nginx"
prog=$(basename $nginx)

NGINX_CONF_FILE="/usr/local/nginx/conf/nginx.conf"

[ -f /etc/sysconfig/nginx ] && . /etc/sysconfig/nginx

lockfile=/var/lock/nginx.lock

make_dirs() {
   # make required directories
   user=`$nginx -V 2>&1 | grep "configure arguments:.*--user=" | sed 's/[^*]*--user=\([^ ]*\).*/\1/g' -`
   if [ -n "$user" ]; then
      if [ -z "`grep $user /etc/passwd`" ]; then
         useradd -M -s /bin/nologin $user
      fi
      options=`$nginx -V 2>&1 | grep 'configure arguments:'`
      for opt in $options; do
          if [ `echo $opt | grep '.*-temp-path'` ]; then
              value=`echo $opt | cut -d "=" -f 2`
              if [ ! -d "$value" ]; then
                  # echo "creating" $value
                  mkdir -p $value && chown -R $user $value
              fi
          fi
       done
    fi
}

start() {
    [ -x $nginx ] || exit 5
    [ -f $NGINX_CONF_FILE ] || exit 6
    make_dirs
    echo -n $"Starting $prog: "
    daemon $nginx -c $NGINX_CONF_FILE
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $lockfile
    return $retval
}

stop() {
    echo -n $"Stopping $prog: "
    killproc $prog -QUIT
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $lockfile
    return $retval
}

restart() {
    configtest || return $?
    stop
    sleep 1
    start
}

reload() {
    configtest || return $?
    echo -n $"Reloading $prog: "
    killproc $nginx -HUP
    RETVAL=$?
    echo
}

force_reload() {
    restart
}

configtest() {
  $nginx -t -c $NGINX_CONF_FILE
}

rh_status() {
    status $prog
}

rh_status_q() {
    rh_status >/dev/null 2>&1
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
    restart|configtest)
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
            ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload|configtest}"
        exit 2
esac
--------------

nginx配置文件解析：
process 1 ;表示进程数，cpu密集型的为cpu个数相等，非密集型的为cpu个数的1.5-2倍
worker_connections 1024 ;每个工作进程最大请求数
tcp_nopush或tcp_nodelay off ;表示关闭http的nagle算法
对于nginx而言，每一个server称为一个虚拟主机;
location /URI/ { #对当前的URI及其子目录都生效
	root /web/www #表示/URI路径是本地文件系统路径/web/www/下的所有文件
	index index.html #默认页面
}
error_page 500 502 503 504 /50x.html; #返回500 502 503 504错误代码时读取/50x.html文件
location = URI {}： #只对当前的URI生效，不包括子目录 
location ~ URI {}： #精确匹配，区分大小写，URI可以为正则表达式
location ~* URI {}： #精确匹配，不区分大小写，URI可以为正则表达式
location ^~ URI {}： #不使用正则表达式
=,^~，~*|~,/ URI #4个优先级顺序
location / {
	allow 192.168.1.1;
	deny all; 
}
location / {        ##yum install -y httpd-tools  #需要借助httpd的工具对nginx进行做认证
	auth_basic	"htpasswd" ; #开户用户认证，借助httpd的htpasswd来创建用户密码，nginx无，htpasswd -c -m /etc/nginx/.users tom，第二次不能使用-c选项再创建文件
	auth_basic_user_file /etc/nginx/.users ;
}

[root@lamp down]# htpasswd -c -m /usr/local/nginx/.users jack
New password: 
Re-type new password: 
Adding password for user jack
[root@lamp down]# htpasswd -m /usr/local/nginx/.users tom
New password: 
Re-type new password: 
Adding password for user tom

location / {
	autoindex on ; 为打开目录索引
}
location /status｛
	stub_status on ; #开启nginx状态
｝

#ssl 跟httpd一样
##LEMP或LNMP:
NGINX支持FastCGI
#mysql使用通用二进制安装:
[root@lamp down]# tar -xf mysql-5.6.43-linux-glibc2.12-x86_64.tar.gz -C /usr/local/
[root@lamp local]# ln -sv mysql-5.6.43-linux-glibc2.12-x86_64/ mysql
‘mysql’ -> ‘mysql-5.6.43-linux-glibc2.12-x86_64/’
groupadd -r -g 1001 mysql
useradd -r -g 1001 -u 1001 mysql
[root@lamp mysql]# mkdir /etc/my.cnf.d
[root@lamp mysql]# ./scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/data
[root@lamp mysql]# vim my.cnf
basedir = /usr/local/mysql
datadir = /data
cp support-files/mysql.server /etc/init.d/mysqld
chkconfig --add mysqld 
chkconfig --list 
vim /etc/ld.so.conf.d/mysql.conf
ldconfig -p
ln -sv /usr/local/mysql/include/ /usr/include/mysql

#php安装：
	如果想让编译的php支持mcrypt、myhash扩展和libevent,需要安装下包几个包：
	libmcrypt.rpm、libmcrypt-devel.rpm、mhash.rpm、mhash-devel.rpm、mcrypt.rpm
[root@lamp php-5.4.24]# yum install epel-release 
[root@lamp php-5.4.24]# yum install -y libmcrypt* mhash* mcrypt
编辑安装php:
[root@lamp php-5.4.24]# ./configure --prefix=/usr/local/php-5.4.24 --with-mysql=/usr/local/mysql --with-openssl --with-mysqli=/usr/local/mysql/bin/mysql_config --enable-mbstring --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --enable-sockets --enable-fpm --with-mcrypt --with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d --with-bz2
[root@lamp php-5.4.24]# make &&make install
[root@lamp php-5.4.24]# cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
[root@lamp php-5.4.24]# chmod +x /etc/init.d/php-fpm
[root@lamp php-5.4.24]# chkconfig --add php-fpm
[root@lamp local]# ln -sv /usr/local/php-5.4.24/ /usr/local/php
‘/usr/local/php’ -> ‘/usr/local/php-5.4.24/’
[root@lamp php]# cp /down/php-5.4.24/php.ini-production /etc/php.ini
[root@lamp php]# mkdir /etc/php.d
[root@lamp php]# cp etc/php-fpm.conf.default etc/php-fpm.conf
#vim /usr/local/php/etc/php-fpm.conf
pm.max_children = 50 #最多几个子进程
pm.start_servers = 5
pm.min_spare_servers = 2
pm.max_spare_servers = 8
pid = run/php-fpm.pid 
listen = 127.0.0.1:9000 
[root@lamp php]# service php-fpm start
Starting php-fpm  done
[root@lamp php]# netstat -tunlp | grep php
tcp        0      0 127.0.0.1:9000          0.0.0.0:*               LISTEN      4634/php-fpm: maste 
[root@lamp php]# ps aux | grep php
root      4634  0.0  0.1  86732  4636 ?        Ss   14:55   0:00 php-fpm: master process (/usr/local/php-5.4.24/etc/php-fpm.conf)
nobody    4635  0.0  0.1  88816  4084 ?        S    14:55   0:00 php-fpm: pool www
nobody    4636  0.0  0.1  88816  4084 ?        S    14:55   0:00 php-fpm: pool www
nobody    4637  0.0  0.1  88816  4084 ?        S    14:55   0:00 php-fpm: pool www
nobody    4638  0.0  0.1  88816  4084 ?        S    14:55   0:00 php-fpm: pool www
nobody    4639  0.0  0.1  88816  4084 ?        S    14:55   0:00 php-fpm: pool www
nobody    4640  0.0  0.1  88816  4084 ?        S    14:55   0:00 php-fpm: pool www
nobody    4641  0.0  0.1  88816  4084 ?        S    14:55   0:00 php-fpm: pool www
nobody    4642  0.0  0.1  88816  4084 ?        S    14:55   0:00 php-fpm: pool www
root      4652  0.0  0.0 112708   976 pts/0    S+   14:55   0:00 grep --color=auto php

编辑nginx.conf配置文件：
location ~ \.php$ {
            root           html;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
            include        fastcgi_params;
        }
[root@lamp conf]# cat fastcgi_params
fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
fastcgi_param  SERVER_SOFTWARE    nginx;
fastcgi_param  REMOTE_ADDR        $remote_addr;
fastcgi_param  REMOTE_PORT        $remote_port;
fastcgi_param  SERVER_ADDR        $server_addr;
fastcgi_param  SERVER_PORT        $server_port;
fastcgi_param  SERVER_NAME        $server_name;
fastcgi_param  QUERY_STRING       $query_string;
fastcgi_param  REQUEST_METHOD     $request_method;
fastcgi_param  CONTENT_TYPE       $content_type;
fastcgi_param  CONTENT_LENGTH     $content_length;
fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;
fastcgi_param  REQUEST_URI        $request_uri;
fastcgi_param  DOCUMENT_URI       $document_uri;
fastcgi_param  DOCUMENT_ROOT      $document_root;
fastcgi_param  SERVER_PROTOCOL    $server_protocol;

#部署xcache:
php5.4-xcache3.0
php5.5-xcache3.1
XCache资源网站：https://xcache.lighttpd.net/
下载XCache:wget https://xcache.lighttpd.net/pub/Releases/3.1.2/xcache-3.1.2.tar.gz
[root@lamp down]# tar xf xcache-3.1.2.tar.gz 
[root@lamp down]# cd xcache-3.1.2/
[root@lamp xcache-3.1.2]# /usr/local/php/bin/phpize 
Configuring for:
PHP Api Version:         20100412
Zend Module Api No:      20100525
Zend Extension Api No:   220100525
#编译xcache:
[root@lamp xcache-3.1.2]# ./configure --enable-xcache --with-php-config=/usr/local/php/bin/php-config
--prefix #这项是不写的，xcache默认会安装在php的扩展路径下的,因为通过phpize指令获取到了php的信息
--enable-xcache  #为开启xcache
--with-php-config=/usr/local/php/bin/php-config  #通过指定--with-php-config路径来获取php在编译时开启了哪些功能。因为php安装的配置信息等不在默认路径下，所以告诉xcache,不然xcache找不到的。
[root@lamp xcache-3.1.2]# make && make install
Installing shared extensions:     /usr/local/php-5.4.24/lib/php/extensions/no-debug-non-zts-20100525/   #安装扩展的路径
[root@lamp xcache-3.1.2]# ls xcache.ini
xcache.ini   #xcache提供的样例性配置文件
[root@lamp xcache-3.1.2]# mkdir /etc/php.d
[root@lamp xcache-3.1.2]# cp xcache.ini /etc/php.d/
[root@lamp xcache-3.1.2]# egrep -v '^;|^$' /etc/php.d/xcache.ini 
[xcache-common]
extension = /usr/local/php-5.4.24/lib/php/extensions/no-debug-non-zts-20100525/xcache.so
[xcache.admin]
xcache.admin.enable_auth = On
xcache.admin.user = "mOo"
xcache.admin.pass = "md5 encrypted password"
[xcache]
xcache.shm_scheme =        "mmap"
xcache.size  =               60M
xcache.count =                 1
xcache.slots =                8K
xcache.ttl   =                 0
xcache.gc_interval =           0
xcache.var_size  =            4M
xcache.var_count =             1
xcache.var_slots =            8K
xcache.var_ttl   =             0
xcache.var_maxttl   =          0
xcache.var_gc_interval =     300
xcache.var_namespace_mode =    0
xcache.var_namespace =        ""
xcache.readonly_protection = Off
xcache.mmap_path =    "/dev/zero"
xcache.coredump_directory =   ""
xcache.coredump_type =         0
xcache.disable_on_crash =    Off
xcache.experimental =        Off
xcache.cacher =               On
xcache.stat   =               On
xcache.optimizer =           Off
[xcache.coverager]
xcache.coverager =           Off
xcache.coverager_autostart =  On
xcache.coveragedump_directory = ""
[root@lamp xcache-3.1.2]# service php-fpm restart
Gracefully shutting down php-fpm . done
Starting php-fpm  done
[root@lamp html]# cat /usr/local/nginx/html/index.php  #测试
<?php
$conn=mysql_connect('192.168.1.233','jack','jack123');
        if ($conn)
                echo "Success...";
        else
                echo "Faild.....";
phpinfo()
?>
#编译zendopcache:
[root@lnmp down]# wget http://pecl.php.net/get/zendopcache-7.0.5.tgz
[root@lnmp down]# gzip -d zendopcache-7.0.5.tgz 
[root@lnmp down]# tar xf zendopcache-7.0.5.tar
[root@lnmp down]# cd zendopcache-7.0.5/
[root@lnmp zendopcache-7.0.5]# /usr/local/php/bin/phpize 
[root@lnmp zendopcache-7.0.5]# ./configure --with-php-config=/usr/local/php/bin/php-config
[root@lnmp zendopcache-7.0.5]# make && make install
--------
 vi  /etc/php.ini
zend_extension=/usr/local/php/lib/php/extensions/no-debug-non-zts-20121212/opcache.so
opcache.enable=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.enable_cli=1
--------
#php5.6开启opcache不用单独编译zendopcache,只需要编译php时开启 --enable-opcache即可
例：./configure --prefix=/usr/local/php-5.4.24 --with-mysql=/usr/local/mysql --with-openssl --with-mysqli=/usr/local/mysql/bin/mysql_config --enable-mbstring --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --enable-sockets --enable-fpm --with-mcrypt --with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d --with-bz2 --enable-opcache  #如果显示mysql lib报错时，可把--with-mysqli=/usr/local/mysql/bin/mysql_config的=/usr/local/mysql/bin/mysql_config去掉
[root@lnmp zendopcache-7.0.5]# make && make install
--------
 vi  /etc/php.ini
zend_extension=/usr/local/php/lib/php/extensions/no-debug-non-zts-20121212/opcache.so
opcache.enable=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.enable_cli=1
--------
http://localhost/index.php   #显示Zend Memory Manager	enabled则为已经开启

#下载phpMyAdmin：
参考链接：https://www.phpmyadmin.net/files
[root@lamp down]# wget https://files.phpmyadmin.net/phpMyAdmin/3.4.3.2/phpMyAdmin-3.4.3.2-all-languages.tar.gz
[root@lamp down]# mv pma/ /usr/local/nginx/html/
[root@lamp down]# cd /usr/local/nginx/html/pma/
[root@lamp pma]# cp config.sample.inc.php config.inc.php
[root@lamp pma]# openssl rand -base64 10
oKH3SiJGsm9l1g==
[root@lamp pma]# vim config.inc.php  #可不使用帐号登录
$cfg['blowfish_secret'] = 'oKH3SiJGsm9l1g==';
$cfg['Servers'][$i]['host'] = '192.168.1.233';
$cfg['Servers'][$i]['connect_type'] = 'tcp';
$cfg['Servers'][$i]['compress'] = false;
$cfg['Servers'][$i]['AllowNoPassword'] = false;
[root@lamp pma]# vim libraries/config.default.php  #设置使用帐号登录
$cfg['PmaAbsoluteUri'] = '/usr/local/nginx/html/pma';
$cfg['Servers'][$i]['host'] = '192.168.1.233';
$cfg['Servers'][$i]['user'] = 'jack';
$cfg['Servers'][$i]['password'] = 'jack123';
#部署wordpress：
[root@lamp down]# wget https://wordpress.org/wordpress-4.0.8.tar.gz
[root@lamp down]# tar xf wordpress-4.0.8.tar.gz -C /usr/local/nginx/html/
[root@lamp down]# cd /usr/local/nginx/html/


IO模型：
        阻塞、非阻塞、同步、异步、
同步阻塞、同步非阻塞（io复用）、异步阻塞（event-driven）、异步非阻塞(aio)
nginx模型：
        mmap、event-driveen、aio

memcache:万金油(可以缓存大部分数据)，可序列化数据，string,object,键值数据，C/S架构，C就是应用程序服务器，S就是memcache
redis可以存储更复杂的数据结构，可持久存储，当memcache不能满足时使用redis,是一个NoSQL数据库
NoSQL是一类数据库，不是一种数据库，有文档数据库，图片数据库，键值数据库等。


Nginx反向代理：
        lvs：四层，工作在内核内，性能好，调用ldirect检查后端状态
        nginx：七层，工作在用户空间，性能稍差，转发能力不如haproxy,但差别不是很大，但是nginx占用资源小
        haproxy:七层，工作在用户空间，性能稍差，转发能力虽比nginx好，但是占用资源稍大

反向代理学习：
反向代理某个路径：
location /forum/ {
        proxy_pass http://192.168.1.201:8080/bbs/;  #此http://192.168.1.201:8080后端主机必需设置日志格式接收nginx发送过去的X-Real-IP,以httpd为例，接收格式为%{X-Real-IP}i替换%h
		proxy_set_header X-Real-IP $remote_addr;   #设置发送给后面的头部信息，将自己代理至后端的本机ip变成访问代理服务器的远端ip,变量可查看nginx.org官网core核心模块下变量
}
location ~* ^/forum {
        proxy_pass http://192.168.1.201:8080;  #因为使用模式匹配了，所以这里不能像上面使用具体路径了，只能写到ip加端口位置，否则会报语法错误
}
反向代理整个网站：
location / {
		proxy_pass http://192.168.1.201:8080/;
}
负载均衡：
upstream webserver {  #设定upstream名称，必须为唯一，可以为多个，必须设置在server外
		server httpd.jack.com:8080 weight=5; #weight权重比重
		server tomcat.jack.com weight=5; #权限比重
		server my.jack.com ;  #如果不设置权重则表示分配到此主机的请求用户跟这台主机绑定
}
location / {
		proxy_pass http://webserver/; #反向代理至负载均衡组webserver
}
upstream上游群组：
weight:权重调用
max_fails:最多错误次数
fail_timeout：错误检查超时时间
backup:做最后一个工作的服务器
upstream webserver { 
	server httpd.jack.com:8080 weight=5 max_fails=2 fail_timeout=2;  #设定健康检查
	server tomcat.jack.com:8080 weight=5 max_fails=2 fail_timeout=2;
}
location / {
		proxy_pass http://webserver/; #反向代理至负载均衡组webserver
}
当所有负载均衡挂掉怎么办，设定error_page页：
server {
	listen 8080;
	server_name localhost;
	location / {
		root /web/errorpages;
		index index.html;
	}
}
upstream webserver { 
	server httpd.jack.com:8080 weight=5 max_fail=2 fail_timeout=2;  #当httpd和tomcat挂掉后会使用127.0.0.1:8080这个端口
	server tomcat.jack.com:8080 weight=5 max_fail=2 fail_timeout=2;
	server 127.0.0.1:8080 backup;
}
location / {
		proxy_pass http://webserver/; #反向代理至负载均衡组webserver
}


##实例：
#nginx配置信息：
------------------
[root@lnmp html]# egrep -v '^$|#' ../conf/nginx.conf
worker_processes  1;
events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    upstream webserver {
        server 192.168.1.239 weight=5;  #上游服务器1，轮询
        server 127.0.0.1:8080 backup;  #备份web，当所有web down掉后替换使用，当web恢复时则停用
        server 192.168.1.239:8080 weight=5; #上游服务器2，轮询
    }
    server {
        listen 8080;
        server_name localhost;
        root html/errorpages;
        index index.html;
    }
    server {
        listen       80;
        server_name  localhost;
        location / {
                proxy_pass http://webserver/;  #设定代理到上游服务器组webserver
                proxy_set_header X-Real-IP $remote_addr:$remote_port;  #设定代理到上游服务器时设置头文件信息为用户端的真实ip和port
        }
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
}
------------------
#httpd配置信息：
------------------
[root@lamp httpd]# cat conf/httpd.conf 
ServerRoot "/etc/httpd"
Listen 80
Listen 8080
Include conf.modules.d/*.conf
User apache
Group apache
ServerAdmin root@localhost
<Directory />
    AllowOverride none
    Require all denied
</Directory>
<Directory "/var/www">
    AllowOverride None
    Require all granted
</Directory>
<Directory "/var/www/html">
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
<IfModule dir_module>
    DirectoryIndex index.html
</IfModule>
<Files ".ht*">
    Require all denied
</Files>
ErrorLog "logs/error_log"
LogLevel warn
<IfModule log_config_module>
    LogFormat "%{X-Real-IP}i %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined  #这里要设置被虚拟主机引用的日志格式信息，设置接收代理服务器传送过来的参数，这里把%h更改为%{X-Real-IP}i，i为引用这个变量的值
    LogFormat "%h %l %u %t \"%r\" %>s %b" common
    <IfModule logio_module>
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
    </IfModule>
    CustomLog "logs/access_log" combined
</IfModule>
<IfModule alias_module>
    ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"
</IfModule>
<Directory "/var/www/cgi-bin">
    AllowOverride None
    Options None
    Require all granted
</Directory>
<IfModule mime_module>
    TypesConfig /etc/mime.types
    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz
    AddType text/html .shtml
    AddOutputFilter INCLUDES .shtml
</IfModule>
AddDefaultCharset UTF-8
<IfModule mime_magic_module>
    MIMEMagicFile conf/magic
</IfModule>
EnableSendfile on
IncludeOptional conf.d/*.conf
------------------
[root@lamp httpd]# cat conf.d/vhost.conf 
<VirtualHost 192.168.1.239:80>
        ServerName lamp.jack.com
        DocumentRoot /var/www/html/a
        CustomLog "logs/a.access_log" combined
        ErrorLog "logs/a.error_log"
</VirtualHost>
<VirtualHost 192.168.1.239:8080>
        ServerName my.jack.com:8080
        DocumentRoot /var/www/html/b
        CustomLog "logs/b.access_log" combined
        ErrorLog "logs/b.error_log"
</VirtualHost>
------------------
[root@lamp conf.d]# tail /etc/httpd/logs/b.access_log  -f
192.168.1.233 - - [04/Jun/2019:10:37:51 +0800] "GET / HTTP/1.0" 200 20 "-" "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"
192.168.1.233 - - [04/Jun/2019:10:37:51 +0800] "GET / HTTP/1.0" 200 20 "-" "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"   #这两条是之前的代理服务器地址
192.168.2.153:50424 - - [04/Jun/2019:10:46:31 +0800] "GET / HTTP/1.0" 200 20 "-" "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"  #这个是客户端真实地址
[root@lamp logs]# cat a.access_log 
192.168.2.153:50424 - - [04/Jun/2019:10:46:29 +0800] "GET / HTTP/1.0" 304 - "-" "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"  #这个是客户端真实地址
------------------
nginx:
	round-robin;
	ip_hash;
	least_conn;

开启会话保持：
    upstream webserver {
		ip_hash;  #开启会话保持
        server 192.168.1.239 weight=5;  #上游服务器1，轮询
        server 127.0.0.1:8080 backup;  #开启会话保持后不能使用backup
        server 192.168.1.239:8080 weight=5; #上游服务器2，轮询
    }

[root@smb-server ~]# netstat -ant | awk '/:80\>/{S[$NF]++} END{for(A in S) {print A,S[A]}}' #查看连接某个端口的状态数量，:80\>为:80结尾的，\>为词尾，S[$NF]++为把最后一个字段的值放入数据S上并进行汇总，for(A in S)表示A读取S中的每一个第一列值，{print A,S[A]}表示遍厉打印S的第一列值，S[A]表示取出数组中对应键的值
TIME_WAIT 3
LISTEN 1

nginx缓存：
	cache:共享内存：存储键和缓存对象元数据
		  磁盘空间：存储数据
	proxy_cache_path:不能定义在server{}上下文中;
缓存对象命名：
proxy_cache_path /nginx/cache/first levels=1:2:1 keys_zone=first:20m max_size=1G  #磁盘空间缓存等级最多为3级，这里第一级为1个字符名称，第二级为2个字符名称，第三级为1个字符名称，字符等级越高查找缓存越快，max_size=1G为缓存的硬盘空间大小，缓存空间并不是越大越好，需要自己去测试才能确定最佳空间，当缓存空间满了时，需要cache_manager:LRU来管理缓存，把缓存用得少的给清理掉用以新的缓存存储。keys_zone为定义共享内存的，first为共享内存内的一个名称，大小为20m

#测试缓存，缓存web对象
 proxy_cache_path /nginx/cache/first levels=1:2 keys_zone=first:2m max_size=1G; #设置缓存，共享内存名叫first
 server {
        listen       80;
        server_name  localhost;
        add_header X-Cache "$upstream_cache_status from $server_addr"; #增加客户端的头部信息为缓存状态从哪个服务器地址,用以区别是否命中缓存

        location / {
                proxy_pass http://webserver/;
                proxy_set_header X-Real-IP $remote_addr:$remote_port;  #设置代理到后端的头为客户端ip，后端httpd服务器引用即可
                proxy_cache first;  #开启缓存，指向first共享内存
                proxy_cache_valid 200 10m; #并开启有效的缓存代理，当响应代码为200时缓存10分钟
        }
 }
这个是测试返回的结果：X-Cache:HIT from 192.168.1.233  #HIT为命令了，MISS为未命中
X-Cache:MISS from 192.168.1.233 #为未命中

为日志开启缓存，为fatCGI开启缓存
三种常用的缓存： 
	1. open_log_cache  #日志缓存，降低磁盘io
	2. open_file_cache  #web对象缓存
	3. fastcgi_cache  #fastcgi缓存
nginx的limit限制也基于共享内存实现
gzip  on #为开启压缩，节约带宽，响应速度提快。
gzip_proxied 为定义哪些压缩哪些不压缩。

#多个upstream组，进行多个不同服务类型进行反向代理
upstream imgsrvs {
	server server1;
	server server2;
}
upstream phpsrvs {
	server server1;
	server server2;
}
upstream staticsrvs {
	server server1;
	server server2;
}
location ~* \.php$ {
	fastcgi_pass http://phpsrvs;
}
location ~* "\.(jpg|jpeg|gif|png)$" {
	proxy_pass http://imgsrvs;
}
location / {
	proxy_pass http://staticsrvs;
}

#rewrite:URL重写模块
	if (condition) {

}
例：
location /images {
	rewrite http://192.168.1.239/images/;
}
支持正则表达式：
location / {
	root html;
	index index.php index.html;
	rewrite "^/bbs/(.*)/images/(.*)\.jpg$" http://www.magedu.com/bbs/$2/images/$1.jpg last;  #$1表示第一个括号的值，$2表示第二个括号里的值
}
上面的重写结果会引用死循环：http://www.magedu.com/bbs/a/images/b.jpg --> http://www.magedu.com/bbs/b/images/a.jpg --> http://www.magedu.com/bbs/a/images/b.jpg,这种情况所以要用break，不应该用last。
last:本次重写完成之后，重启下一轮检查；
break:本次重写完成之后，直接执行后续操作，不再对本次操作再做检查；


location /photos/ {  #设置图片盗链不允许访问的操作
  	valid_referers none blocked www.modomain.com mydomain.com; #当客户端输入网址时或访问地址为www.modomain.com、mydomain.com时为有效引用，否则其他为无效引用
	if ($invalid_referer) {  #当无效引用时返回403
		return 403;
	}
}
#注：none代表没有referer，blocked代表有referer但是被防火墙或者是代理给去除了


WebDAV:一种基于http1.1协议的通信协议，它扩展了http1.1，在GET,POST,HEAD等几个http标准方法以外添加了一些新的方法，使应用程序可直接对web server直接读写，并支持写文件锁定(locking)及解锁(unlock)，还可以支持文件的版本控制。
PUT:上传
#web服务器实现读写分离的：
定义多台服务器为读，某台为写，然后使读服务器同步写服务器的文件到读服务器
#httpd服务开启dav
[root@lamp conf.modules.d]# cat 00-dav.conf 
LoadModule dav_module modules/mod_dav.so
LoadModule dav_fs_module modules/mod_dav_fs.so
LoadModule dav_lock_module modules/mod_dav_lock.so
<Directory "/var/www/html">
    Dav on  #开启dav
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
[root@lamp conf.d]# setfacl -m u:apache:rwx /var/www/html/* #设置网站根目录权限
[root@lamp conf.d]# getfacl /var/www/html/a/
getfacl: Removing leading '/' from absolute path names
# file: var/www/html/a/
# owner: root
# group: root
user::rwx
user:apache:rwx
group::r-x
mask::rwx
other::r-x
[root@lnmp 61]# curl -T /etc/issue http://lamp.jack.com/
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>403 Forbidden</title>
</head><body>
<h1>Forbidden</h1>
<p>You don't have permission to access /issue
on this server.</p>
</body></html>
[root@lnmp 61]# curl -T /etc/issue http://lamp.jack.com/
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>201 Created</title>
</head><body>
<h1>Created</h1>
<p>Resource /issue has been created.</p>  #已经上传成功
</body></html>
http://192.168.1.239/issue #客户端可以访问上传后的文件
#使用nginx实行web读写分离
server {
        listen 8080;
        server_name localhost;
        root html/errorpages;
        index index.html;
    }
location / {
                proxy_pass http://192.168.1.233:8080/;
                if ($request_method = "PUT") {
                        proxy_pass http://192.168.1.239;
                }
}

[root@lnmp conf]# curl http://lnmp.jack.com  #读，lnmp.jack.com解析为192.168.1.233
<h1>sorry,web server is down,please later visit!<h1>
[root@lnmp conf]# curl -T /etc/e2fsck.conf http://lnmp.jack.com/ #写
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>201 Created</title>
</head><body>
<h1>Created</h1>
<p>Resource /e2fsck.conf has been created.</p>
</body></html>
注意：自己需要在主服务器上使用rsync+inotify或者sersync来同步给从服务器。从服务器可以是一个upstream
</pre>




