#memcached缓存服务器
<pre>
将url的请求文件名为键，文件内容为值
支持text和binary
一半依赖于客户端，一半依赖于服务器
影响业务本身但不影响数据本身，memcached只是一个缓存服务器
lazy模型的，懒惰的，只在不存满缓存空间就不会清除缓存。LRU：最近最少使用
使用内存来缓存数据，memcached又叫内存缓存服务器，数据大小：最小为48bytes
避免内存碎片两种办法：
	1. buddy system(伙伴系统)：用来避免内存外碎片的，也叫内存间碎片的，对内存页再次分片
	2. slab alllocator：slab分配器，slab class:类别，slab chunk:类别的容量大小，用来避免内存内碎片的，memchached使用这种方法
memcached:不通信的分布式缓存服务器
memcached:
	1.缓存在内存当中，
	2.找到适当的trunk存储，难以避免内存浪费，但是尽量浪费最小空间
	3.hash存储（一致性hash算法），达到O(1)效果，当memcached故障时或增加memcached时，不会影响全局memcached群，只是导致这一个memcached[而如果是取余的算法那么会导致全局memcached群受到影响]
#memcached能不能使用取决于客户端程序是否支持，使用取余的算法还是一致性hash算法取决于程序本身的设计
#安装libevent:支持event-driven,memcached需要它,可以安装新的，也可以使用系统自带的老片libevent
[root@lnmp down]# wget https://github.com/libevent/libevent/releases/download/release-2.1.10-stable/libevent-2.1.10-stable.tar.gz
[root@lnmp down]# tar xf libevent-2.1.10-stable.tar.gz 
[root@lnmp down]# cd libevent-2.1.10-stable/
[root@lnmp libevent-2.1.10-stable]# ./configure --prefix=/usr/local/libevent 
[root@lnmp libevent-2.1.10-stable]# make && make install
#安装memcached
[root@lnmp down]# wget http://www.memcached.org/files/memcached-1.5.16.tar.gz
[root@lnmp down]# tar xf memcached-1.5.16.tar.gz 
[root@lnmp down]# cd memcached-1.5.16/
[root@lnmp down]# yum install -y cyrus-sasl-devel #安装sasl,memcached认证时需要
[root@lnmp memcached-1.5.16]# ./configure --prefix=/usr/local/memcached --enable-sasl --enable-sasl-pwdb --with-libevent=/usr/local/libevent #告诉系统使用新的libevent
[root@lnmp memcached-1.5.16]# make && make install 
[root@lnmp memcached-1.5.16]# /usr/local/memcached/bin/memcached -m 128m -n 20 -f 1.1 -vv  -d -u nobody  #使用内存大小为128m，最小slab chunk为20，但是这memcache最小为72，增长因子系统为1.1，-d为后台运行，用户为nobody，-c为最大的并发数,-t为设定最大线程数，-S为启用sasl功能进行认证，-l为设定监听ip地址
[root@lnmp memcached-1.5.16]# netstat -tunlp | grep ':11211\>'
tcp        0      0 0.0.0.0:11211           0.0.0.0:*               LISTEN      4614/memcached      
tcp6       0      0 :::11211                :::*                    LISTEN      4614/memcached      
[root@lnmp memcached-1.5.16]# yum install telnet -y
[root@lnmp memcached-1.5.16]# telnet localhost 11211
Trying ::1...
Connected to localhost.
Escape character is '^]'.
<28 new auto-negotiating client connection
<28 stats  #查看当前状态的
STAT pid 4614
STAT uptime 245
STAT time 1560064889
STAT version 1.5.16
STAT libevent 2.1.10-stable
STAT pointer_size 64
STAT rusage_user 0.027374
STAT rusage_system 0.015398
STAT max_connections 1024
STAT curr_connections 2
STAT total_connections 3
STAT rejected_connections 0
STAT connection_structures 3
STAT reserved_fds 20
STAT cmd_get 0
STAT cmd_set 0
STAT cmd_flush 0
STAT cmd_touch 0
STAT get_hits 0   #get的命中率
STAT get_misses 0  #get的未命中率
STAT get_expired 0
STAT get_flushed 0
STAT delete_misses 0
STAT delete_hits 0
STAT incr_misses 0
STAT incr_hits 0
STAT decr_misses 0
STAT decr_hits 0
STAT cas_misses 0
STAT cas_hits 0
STAT cas_badval 0
STAT touch_hits 0
STAT touch_misses 0
STAT auth_cmds 0
STAT auth_errors 0
STAT bytes_read 7
STAT bytes_written 0
STAT limit_maxbytes 134217728
STAT accepting_conns 1
STAT listen_disabled_num 0
STAT time_in_listen_disabled_us 0
STAT threads 4
STAT conn_yields 0
STAT hash_power_level 16
STAT hash_bytes 524288
STAT hash_is_expanding 0
STAT slab_reassign_rescues 0
STAT slab_reassign_chunk_rescues 0
STAT slab_reassign_evictions_nomem 0
STAT slab_reassign_inline_reclaim 0
STAT slab_reassign_busy_items 0
STAT slab_reassign_busy_deletes 0
STAT slab_reassign_running 0
STAT slabs_moved 0
STAT lru_crawler_running 0
STAT lru_crawler_starts 765
STAT lru_maintainer_juggles 295
STAT malloc_fails 0
STAT log_worker_dropped 0
STAT log_worker_written 0
STAT log_watcher_skipped 0
STAT log_watcher_sent 0
STAT bytes 0
STAT curr_items 0
STAT total_items 0
STAT slab_global_page_pool 0
STAT expired_unfetched 0
STAT evicted_unfetched 0
STAT evicted_active 0
STAT evictions 0
STAT reclaimed 0
STAT crawler_reclaimed 0
STAT crawler_items_checked 0
STAT lrutail_reflocked 0
STAT moves_to_cold 0
STAT moves_to_warm 0
STAT moves_within_lru 0
STAT direct_reclaims 0
STAT lru_bumps_dropped 0
END
add mykey 0 30 5  #增加一个键，mykey为键名，0为类别标志，10为超时时间，5为数据大小
<28 add mykey 0 30 5
hello #设置hello为mykey的值
>28 STORED
STORED
get mykey
<28 get mykey  #获取键的值
>28 sending key mykey
>28 END
VALUE mykey 0 5
hello   #显示值为hello
END
<28 get mykey #过了30秒，所以没有缓存了
>28 END
END

#append在值后面增加值，prepentd在值前面增加值，超过30秒超时后值还在内存缓存着，但是memcached不给你返回数据了
memcached常用命令：
replace：替换
get：获取
set：设置
add：增加
incr:i++
decr:i--
delete：删除
flush_all:清除所有缓存
stats：状态
version：版本
verbosity:显示日志级别

#memcached脚本制作
--------------
[root@lnmp init.d]# cat memcached 
#!/bin/bash
#
#init file for memcached
#chkconfig: - 86 14
#description: Distributed memory caching daemon
#
#processname: memcached
#config: /etc/sysconfig/memcached

. /etc/rc.d/init.d/functions

##Default variables
PORT='11211'
USER='nobody'
MAXCONN='1024'
CACHESIZE='64'
OPTIONS=''

[ -f /etc/sysconfig/memcached ] && . /etc/sysconfig/memcached

RETVAL=0
prog="/usr/local/memcached/bin/memcached"
desc="Distributed memory caching"
lockfile="/var/lock/subsys/memcached"

start(){
        echo -n $"Starting $desc (memcached):"
        daemon $prog -d -p $PORT -u $USER -c $MAXCONN -m $CACHESIZE $OPTIONS
        RETVAL=$?
        echo 
        [ $RETVAL -eq 0 ] && touch $lockfile
        return $RETVAL
}

stop(){
        echo -n $"Shutting down $desc (memcached) "
        killproc $prog
        RETVAL=$?
        echo
        [ $RETVAL -eq 0 ] && rm -f $lockfile
        return $RETVAL
}

restart (){
        stop
        start
}

reload(){
        echo -n $"Reloading $desc ($prog):"
        killproc $prog -HUP
        RETVAL=$?
        echo
        return $RETVAL
}

case "$1" in 
        start)
                start;;
        stop)
                stop;;
        restart)
                restart;;
        reload)
                reload;;
        status)
                status $prog;;
        condrestart)
                [ -e $lockfile ] && restart 
                RETVAL=$?;;
        *)
                echo $"Usage: $0 {start|stop|reload|restart|condrestart|status}"
                RETVAL=1;;
esac
exit #RETVAL

[root@lnmp init.d]# cat /etc/sysconfig/memcached 
PORT='11211'
USER='nobody'
MAXCONN='1024'
CACHESIZE='128'
OPTIONS=''
--------------


#memcached客户端
perl：调用module使用memcached
	cache::memcached
php:
	memcache
	memcached  #比memcache功能更强大,更好用，一般用这个
c/c++
	libmemcached
	以上都是命令行工具
memadmin：基于php的GUI工具
#安装php的memcache客户端：
wget http://pecl.php.net/get/memcache-2.2.6.tgz
[root@lnmp download]# tar xf memcache-2.2.6.tgz
[root@lnmp download]# cd memcache-2.2.6/
[root@lnmp memcache-2.2.6]# /usr/local/php/bin/phpize  #跟xcache一样是php模块
Configuring for:
PHP Api Version:         20100412
Zend Module Api No:      20100525
Zend Extension Api No:   220100525
[root@lnmp memcache-2.2.6]# ./configure --with-php-config=/usr/local/php/bin/php-config --enable-memcache
[root@lnmp memcache-2.2.6]# make && make install 
[root@lnmp memcache-2.2.6]# cat /etc/php.d/memcache.ini
extension=/usr/local/php-5.4.24/lib/php/extensions/no-debug-non-zts-20100525/memcache.so
[root@lnmp memcache-2.2.6]# service php-fpm restart
Gracefully shutting down php-fpm . done
Starting php-fpm  done
然后可用phpinfo()函数查看memcache是否安装成功
phpinfo()脚本 
---------
[root@lnmp pma]# cat index.php 
<?php
$conn=mysql_connect('192.168.1.233','jack','jack123');
        if ($conn)
                echo "Success...";
        else
                echo "Faild.....";

phpinfo()
?>
---------
测试是否可以连接memcache脚本
---------
[root@lnmp pma]# cat test.php 
<?php
$mem = new Memcache;
$mem->connect("127.0.0.1",11211) or die("Could not connect");

$version = $mem->getVersion();
echo "Server's version: ".$version."<br/>\n";

$mem->set('testkey','Hello World',0,600) or die("Faild to save data at the memcached server");
echo "Store data in the cache (data will expire in 600 seconds)<br/>\n";

$get_result = $mem->get('testkey');
echo "$get_result is from memcached server.";
?>
---------
访问http://192.168.1.233/test.php
Server's version: 1.5.16
Store data in the cache (data will expire in 600 seconds)
Hello World is from memcached server. #提示已经存储在memcached中

[root@lnmp pma]# telnet localhost 11211
Trying ::1...
Connected to localhost.
Escape character is '^]'.
get testkey #查看确定存在
VALUE testkey 0 11
Hello World
END

###nginx整合memcached，缓存nginx到memcached上
server{
	listen 80;
	server_name www.magedu.com;
	location / {
		set $memcached_key $uri;  #设置memcached的键为uri路径
		memcached_pass	127.0.0.1:11211; #指定memcached服务器地址
		default_type	text/html;  #指定memcached默认查找的类型为text/html
		error_page		404 @fallback; #当memcached中没有找到缓存时调用@fallback
	}
	
	location @fallback {
		proxy_pass http://192.168.1.233;#当调用fallback函数时去找后端web server,然后将数据缓存在memcached当中
	}
}

##让php session会话存储在memcached当中
[root@lnmp php-5.4.24]# vim /etc/php.ini  
session.save_handler = memcache
session.save_path = "tcp://192.168.1.233:11211?persistent=1&weight=1&timeout=1&retry_interval=15" #更改上面两行，persistent持久连接，weight为权重，timeout为超时时间，retry_interval为重试间隔时间
session.name = PHPSESSID #这个以后要用到的，php的会话id
service php-fpm restart 
测试session:
#新建setsess.php进行设置session id:
[root@lnmp html]# cat setsess.php 
<?php
session_start();
if (!isset($_SESSION['lnmp.jack.com'])) {   
 $_SESSION['lnmp.jack.com'] = time();
}
print $_SESSION['lnmp.jack.com'];
print "<br><br>";
print "Session_ID: ". session_id();
?>
#新建getsess.php进行显示session id:
[root@lnmp html]# cat getsess.php 
<?php
session_start();
$memcache_obj = new Memcache;
$memcache_obj->connect('192.168.1.233',11211);
$mysess=session_id();
var_dump($memcache_obj->get($mysess));
$memcache_obj->close();
?>
#注：使用lvs对多个memcached进行负载均衡


#memadmin管理,GUI管理工具，用来管理memcached的
[root@lnmp down]# wget http://www.junopen.com/memadmin/memadmin-1.0.12.tar.gz 
tar xf memadmin-1.0.12.tar.gz  /var/www/html
#帐户和密码默认都是admin


</pre>