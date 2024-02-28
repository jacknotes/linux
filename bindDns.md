# bind DNS



![Linux](https://github.com/jacknotes/linux/raw/master/image/linux.jpg)

[Linux bind doc](https://bind9.readthedocs.io/en/v9_18_6/)



## 节点环境信息
```
root@dns-master:~# cat /etc/issue
Ubuntu 18.04.5 LTS \n \l
root@dns-master:~# ip a s eth0 | grep 172
    inet 172.168.2.34/24 brd 172.168.2.255 scope global eth0
	
root@dns-slave01:~# cat /etc/issue
Ubuntu 18.04.5 LTS \n \l
root@dns-slave01:~# ip a s eth0 | grep 172
    inet 172.168.2.35/24 brd 172.168.2.255 scope global eth0
```



## 一、bind安装 

```
root@dns-master:~# sudo apt update
root@dns-slave01:~# sudo apt update
root@dns-master:~# sudo apt-get install -y bind9 bind9utils bind9-doc
root@dns-slave01:~# sudo apt-get install -y bind9 bind9utils bind9-doc
```



## 二、bind配置



### 2.1 设置绑定到IPv4模式

```
root@dns-master:~# sudo cat/etc/default/bind9
RESOLVCONF=no
OPTIONS="-u bind -4"
root@dns-master:~# sudo systemctl restart bind9
root@dns-master:~# sudo systemctl is-active bind9
active

root@dns-slave01:~# sudo cat /etc/default/bind9
RESOLVCONF=no
OPTIONS="-u bind -4"
root@dns-slave01:~# systemctl restart bind9
root@dns-slave01:~# systemctl is-active bind9
active
```



### 2.2 配置主DNS服务器

BIND的配置由多个文件组成，这些文件包含在主配置文件named.conf。这些文件名以named开头，因为这是BIND运行的进程的名称（“域名守护程序”的缩写），我们将从配置选项文件开始。



#### 2.2.1 配置选项文件

1. 在dns-master上打开/etc/bind/named.conf.options文件进行编辑。
2. 在现有options块上方，创建一个名为“trusted”的新 ACL（访问控制列表）块。这是我们将定义客户列表的地方，我们将允许哪些客户端地址递归DNS查询（即与dns-master位于同一数据中心的服务器）
3. 现在我们有了可信DNS客户端列表，我们将要编辑options块，配置如下

```
root@dns-master:~# grep -Ev '\/\/|^$' /etc/bind/named.conf
include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local";
include "/etc/bind/named.conf.default-zones";

root@dns-master:~# grep -Ev '\/\/|^$' /etc/bind/named.conf.options
acl "trusted" {
        172.168.2.34;    # dns-master
        172.168.2.35;    # dns-slave01
        172.168.2.0/24;  # server ip range
        192.168.13.0/24;  # server ip range
        192.168.10.0/24;  # client ip range
};
options {
        directory "/var/cache/bind";   # bind默认数据目录
        recursion yes;                 # 是否开启递归查询功能
        allow-recursion { trusted; };  # 允许递归查询的主机列表
        listen-on { 172.168.2.34; };   # 监听的地址
        allow-transfer { 172.168.2.35; };	# 允许传输的dns-slave地址，这里写了是全局性的，可在zone中不写亦生效
        forwarders {						# 不能解析时转发的服务器地址
                8.8.8.8;
                8.8.4.4;
        };
```



#### 2.2.2 配置本地文件

配置正向区域和反向区域解析，这里配置的域名为jack.com

```
root@dns-master:~# cat /etc/bind/named.conf.local
zone "jack.com" IN {
        type master;
        file "jack.com.zone"; // 文件路径，默认在/var/cache/bind目录下
		//allow-update { 172.168.2.35; }; //如果allow-update的值不是none，那么这个zone就是一个动态zone，反之是静态zone，如果开启会导致rndc reload不同步zone信息到dns-slave中，强烈建议不开启
        //allow-transfer{ 172.168.2.35; }; // dns-slave01传输的地址，全局写了这里可不写，这里优先级高
		also-notify { 172.168.2.35; }; // 当dns-master更新后通知dns-slave01进行更新并重载服务
};

zone "2.168.172.in-addr.arpa" IN {
        type master;
        file "2.168.172.in-addr-arpa";
        //allow-transfer{ 172.168.2.35; }; // dns-slave01传输的地址，全局写了这里可不写
		also-notify { 172.168.2.35; }; // 当dns-master更新后通知dns-slave01进行更新并重载服务
};
```



#### 2.2.3 创建转发区文件

```
root@dns-master:~# cp /etc/bind/db.local /var/cache/bind/jack.com.zone
root@dns-master:~# sudo vim /var/cache/bind/jack.com.zone
root@dns-master:~# cat /var/cache/bind/jack.com.zone
$TTL    604800
@       IN      SOA     dns-master.jack.com. admin.jack.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
        IN      NS      dns-master.jack.com.

dns-master      IN      A       172.168.2.34
dns-slave01     IN      A       172.168.2.35

root@dns-master:~# cp /etc/bind/db.127 /var/cache/bind/2.168.172.in-addr-arpa
root@dns-master:~# vim /var/cache/bind/2.168.172.in-addr-arpa
root@dns-master:~# cat /var/cache/bind/2.168.172.in-addr-arpa
$TTL    604800
@       IN      SOA     dns-master.jack.com. admin.jack.com. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
        IN      NS      dns-master.jack.com.
34      IN      PTR     dns-master.jack.com.
35      IN      PTR     dns-slave01.jack.com.

```



#### 2.2.4 检查bind配置语法并重启bind服务

1. 如果您的命名配置文件没有语法错误，您将返回到shell提示符并且看不到任何错误消息。如果配置文件有问题，请查看错误消息和“配置主DNS服务器”部分，然后再次尝试named-checkconf
2. named-checkzone命令可用于检查区域文件的正确性。其第一个参数指定区域名称，第二个参数指定相应的区域文件，这两个文件都在named.conf.local定义

```
root@dns-master:~# sudo named-checkconf
root@dns-master:~# sudo named-checkzone jack.com /var/cache/bind/jack.com.zone
zone jack.com/IN: loaded serial 2
OK
root@dns-master:~# sudo named-checkzone 2.168.172.in-addr-arpa /var/cache/bind/2.168.172.in-addr-arpa
zone 2.168.172.in-addr-arpa/IN: loaded serial 1
OK
root@dns-master:~# systemctl restart bind9
root@dns-master:~# systemctl is-active bind9
active
```
```
# windows 测试解析

> server 172.168.2.34
默认服务器:  [172.168.2.34]
Address:  172.168.2.34

> dns-slave01.jack.com
服务器:  [172.168.2.34]
Address:  172.168.2.34

名称:    dns-slave01.jack.com
Address:  172.168.2.35
```



### 2.3 配置备用DNS服务器

```
root@dns-slave01:~# grep -Ev '\/\/|^$' /etc/bind/named.conf
include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local";
include "/etc/bind/named.conf.default-zones";

root@dns-slave01:~# sudo vim /etc/bind/named.conf.options
root@dns-slave01:~# cat /etc/bind/named.conf.options
acl "trusted" {
        172.168.2.34;    # dns-master
        172.168.2.35;    # dns-slave01
        172.168.2.0/24;  # server ip range
        192.168.13.0/24;  # server ip range
        192.168.10.0/24;  # client ip range
};
options {
        directory "/var/cache/bind";
        recursion yes;                 # enables resursive queries
        allow-recursion { trusted; };  # allows recursive queries from "trusted" clients, or "any" not limits.
        listen-on { 172.168.2.35; };   # dns-master private IP address - listen on private network only
        allow-transfer { none; };
        forwarders {
                8.8.8.8;
                8.8.4.4;
        };
};
```



#### 2.3.1 定义与主DNS服务器上的主区域对应的从属区域

```
root@dns-slave01:~# cat /etc/bind/named.conf.local
zone "jack.com" IN {
        type slave;
        file "jack.com.zone"; // can not write abs path
		masterfile-format text;	// slave data format is text, can change
        masters { 172.168.2.34; }; // dns-master address
        
};

zone "2.168.172.in-addr.arpa" IN {
        type slave;
        file "2.168.172.in-addr-arpa"; 	// can not write abs path
		masterfile-format text;	// slave data format is text, can change
        masters { 172.168.2.34; }; // dns-master address
};
```



#### 2.3.2 检查bind配置语法并重启bind服务

```
root@dns-slave01:~# sudo named-checkconf
root@dns-slave01:~# sudo systemctl restart bind9
root@dns-slave01:~# sudo systemctl is-active bind9
active

# 因为前面配置区域文件时指定格式为text，所以这里不是乱码
root@dns-slave01:~# cat /var/cache/bind/jack.com.zone
$ORIGIN .
$TTL 604800     ; 1 week
jack.com                IN SOA  dns-master.jack.com. admin.jack.com. (
                                2          ; serial
                                604800     ; refresh (1 week)
                                86400      ; retry (1 day)
                                2419200    ; expire (4 weeks)
                                604800     ; minimum (1 week)
                                )
                        NS      dns-master.jack.com.
$ORIGIN jack.com.
dns-master              A       172.168.2.34
dns-slave01             A       172.168.2.35

root@dns-slave01:~# cat /var/cache/bind/2.168.172.in-addr-arpa
$ORIGIN .
$TTL 604800     ; 1 week
2.168.172.in-addr.arpa  IN SOA  dns-master.jack.com. admin.jack.com. (
                                1          ; serial
                                604800     ; refresh (1 week)
                                86400      ; retry (1 day)
                                2419200    ; expire (4 weeks)
                                604800     ; minimum (1 week)
                                )
                        NS      dns-master.jack.com.
$ORIGIN 2.168.172.in-addr.arpa.
34                      PTR     dns-master.jack.com.
35                      PTR     dns-slave01.jack.com.
```



### 2.4 dns-master增加1条a记录并重载dns服务，检验dns-slave01是否同步

```
root@dns-master:/var/cache/bind# cat jack.com.zone
$TTL    604800
@       IN      SOA     dns-master.jack.com. admin.jack.com. (
                        2022000021      ; Serial	#增加修订版本号
                        86400         ; Refresh	#服务器刷新时间
                        3600         ; Retry		#重新刷新时间
                        604800         ; Expire	#宣告失效的时间
                        10800 )       ; Negative Cache TTL	#缓存保留时间，可以换算为7D
;
        IN      NS      dns-master.jack.com.

dns-master      IN      A       172.168.2.34
dns-slave01     IN      A       172.168.2.35
test            IN      A       172.168.2.219		#增加一条A记录
root@dns-master:/var/cache/bind# sudo rndc reload
server reload successful

# dns-master 日志
Sep  8 12:00:30 dns-master named[13545]: reloading configuration succeeded
Sep  8 12:00:30 dns-master named[13545]: reloading zones succeeded
Sep  8 12:00:30 dns-master named[13545]: zone jack.com/IN: loaded serial 2022000021
Sep  8 12:00:30 dns-master named[13545]: zone jack.com/IN: sending notifies (serial 2022000021)
Sep  8 12:00:30 dns-master named[13545]: all zones loaded
Sep  8 12:00:30 dns-master named[13545]: running
Sep  8 12:00:30 dns-master named[13545]: client @0x7f346c001460 172.168.2.35#8281 (jack.com): transfer of 'jack.com/IN': AXFR-style IXFR started (serial 2022000021)
Sep  8 12:00:30 dns-master named[13545]: client @0x7f346c001460 172.168.2.35#8281 (jack.com): transfer of 'jack.com/IN': AXFR-style IXFR ended

# dns-slave01日志
Sep  8 12:00:30 dns-slave01 named[12774]: client @0x7f5bb8041e30 172.168.2.34#10295: received notify for zone 'jack.com'
Sep  8 12:00:30 dns-slave01 named[12774]: zone jack.com/IN: notify from 172.168.2.34#10295: serial 2022000021
Sep  8 12:00:30 dns-slave01 named[12774]: zone jack.com/IN: Transfer started.
Sep  8 12:00:30 dns-slave01 named[12774]: transfer of 'jack.com/IN' from 172.168.2.34#53: connected using 172.168.2.35#8281
Sep  8 12:00:30 dns-slave01 named[12774]: zone jack.com/IN: transferred serial 2022000021
Sep  8 12:00:30 dns-slave01 named[12774]: transfer of 'jack.com/IN' from 172.168.2.34#53: Transfer status: success
Sep  8 12:00:30 dns-slave01 named[12774]: transfer of 'jack.com/IN' from 172.168.2.34#53: Transfer completed: 1 messages, 6 records, 194 bytes, 0.001 secs (194000 bytes/sec)

# dns-slave01 zone信息
root@dns-slave01:/var/cache/bind# cat jack.com.zone
$ORIGIN .
$TTL 600        ; 10 minutes
jack.com                IN SOA  dns-master.jack.com. admin.jack.com. (
                                2022000021 ; serial
                                86400      ; refresh (1 day)
                                3600       ; retry (1 hour)
                                604800     ; expire (1 week)
                                10800      ; minimum (3 hours)
                                )
                        NS      dns-master.jack.com.
$ORIGIN jack.com.
dns-master              A       172.168.2.34
dns-slave01             A       172.168.2.35
test                    A       172.168.2.219	//已经更新
```



### 2.5 客户端测试解析

```
> server 172.168.2.34		//dns-master
默认服务器:  [172.168.2.34]
Address:  172.168.2.34

> test.jack.com
服务器:  [172.168.2.34]
Address:  172.168.2.34

名称:    test.jack.com
Address:  172.168.2.219

> server 172.168.2.35		//dns-slave01
默认服务器:  dns-slave01.jack.com
Address:  172.168.2.35

> test.jack.com
服务器:  dns-slave01.jack.com
Address:  172.168.2.35

名称:    test.jack.com
Address:  172.168.2.219
```



## 三、slave升级为master

**当dns-master故障时，把dns-slave01切换为dns-master**

```
# 模拟dns-master故障
root@dns-master:/var/cache/bind# systemctl stop bind9
root@dns-master:/var/cache/bind# systemctl is-active bind9
inactive

# 配置dns-slave01并重载服务
root@dns-slave01:/var/cache/bind# cat /etc/bind/named.conf.local
zone "jack.com" IN {
        //type slave;
        type master;
        file "jack.com.zone"; // can write abs path
        //masterfile-format text;
        //masters { 172.168.2.34; }; // dns-master address
};

zone "2.168.172.in-addr.arpa" IN {
        //type slave;
        type master;
        file "2.168.172.in-addr-arpa";
        //masterfile-format text;
        //masters { 172.168.2.34; }; // dns-master address
};
root@dns-slave01:/var/cache/bind# rndc reload
server reload successful
root@dns-slave01:/var/cache/bind# systemctl is-active bind9
active

# 客户端测试解析
> test.jack.com
服务器:  [172.168.2.35]
Address:  172.168.2.35

名称:    test.jack.com
Address:  172.168.2.219

# 增加一条A记录
root@dns-slave01:/var/cache/bind# cat jack.com.zone
$ORIGIN .
$TTL 600        ; 10 minutes
jack.com                IN SOA  dns-master.jack.com. admin.jack.com. (
                                2022000022 ; serial
                                86400      ; refresh (1 day)
                                3600       ; retry (1 hour)
                                604800     ; expire (1 week)
                                10800      ; minimum (3 hours)
                                )
                        NS      dns-master.jack.com.
$ORIGIN jack.com.
dns-master              A       172.168.2.34
dns-slave01             A       172.168.2.35
test                    A       172.168.2.219
test2                   A       172.168.2.219
root@dns-slave01:/var/cache/bind# rndc reload
server reload successful
# 客户端测试解析
> test2.jack.com
服务器:  [172.168.2.35]
Address:  172.168.2.35

名称:    test2.jack.com
Address:  172.168.2.219
```

1. 此时可以将dns-slave01当做dns-master来使用了，在新的dns-master上进行配置dns解析都可以了。另外也可以为此dns-master添加dns-slave。
2. 由于无论是bind的配置文件还是bind的zone文件都可以通过rndc reload来生效，所以此方法可以实现dns的高可用，就算挂了一台dns-master，也可以无缝将dns-slave提升为master，实现dns的角色无缝切换。



## 四、master与slave角色互换

**把dns-slave01切换为dns-master、把dns-master切换为dns-slave*

```
# dns-master切换为dns-slave
root@dns-master:/etc/bind# cat /etc/bind/named.conf.options
acl "trusted" {
        172.168.2.34;    # dns-slave01
        172.168.2.35;    # dns-master
        172.168.2.0/24;  # server ip range
        192.168.13.0/24;  # server ip range
        192.168.10.0/24;  # client ip range
};


options {
        directory "/var/cache/bind";
        listen-on { 172.168.2.34; };   # dns-master private IP address - listen on private network only
        recursion yes;                 # enables resursive queries
        allow-recursion { trusted; };  # allows recursive queries from "trusted" clients
        allow-transfer { none; };
        forwarders {
                8.8.8.8;
                8.8.4.4;
        };
};
root@dns-master:/etc/bind# cat /etc/bind/named.conf.local
zone "jack.com" IN {
        //type master;
        //file "jack.com.zone"; // can write abs path
        //also-notify { 172.168.2.35; }; // dns-slave01 address
        type slave;
        file "jack.com.zone"; // can write abs path
        masterfile-format text;
        masters { 172.168.2.35; };

};

zone "2.168.172.in-addr.arpa" IN {
        //type master;
        //also-notify { 172.168.2.35; }; // dns-slave01 address
        type slave;
        file "2.168.172.in-addr-arpa";
        masterfile-format text;
        masters { 172.168.2.35; };
};
root@dns-master:/etc/bind# named-checkconf
root@dns-master:/etc/bind# systemctl start bind9


# dns-slave切换为dns-master
root@dns-slave01:/etc/bind# cat named.conf.options
acl "trusted" {
        172.168.2.34;    # dns-slave01
        172.168.2.35;    # dns-master
        172.168.2.0/24;  # server ip range
        192.168.13.0/24;  # server ip range
        192.168.10.0/24;  # client ip range
};
options {
        directory "/var/cache/bind";
        listen-on { 172.168.2.35; };   # dns-master private IP address - listen on private network only
        recursion yes;                 # enables resursive queries
        allow-recursion { trusted; };  # allows recursive queries from "trusted" clients, or "any" not limits.
        allow-transfer { 172.168.2.34; };
        forwarders {
                8.8.8.8;
                8.8.4.4;
        };
};
root@dns-slave01:/etc/bind# cat named.conf.local
zone "jack.com" IN {
        type master;
        file "jack.com.zone"; // can write abs path
        also-notify { 172.168.2.34; };
        //type slave;
        //masterfile-format text;
        //masters { 172.168.2.34; }; // dns-master address
};

zone "2.168.172.in-addr.arpa" IN {
        type master;
        file "2.168.172.in-addr-arpa";
        also-notify { 172.168.2.34; };
        //type slave;
        //masterfile-format text;
        //masters { 172.168.2.34; }; // dns-master address
};
root@dns-slave01:/etc/bind# rndc reload
server reload successful

# 增加新的dns-master serial版本号，使新的dns-slave能同步新的dns-master
root@dns-slave01:/etc/bind# vim /var/cache/bind/jack.com.zone
$ORIGIN .
$TTL 600        ; 10 minutes
jack.com                IN SOA  dns-master.jack.com. admin.jack.com. (
                                2022000026 ; serial
                                86400      ; refresh (1 day)
                                3600       ; retry (1 hour)
                                604800     ; expire (1 week)
                                10800      ; minimum (3 hours)
                                )
                        NS      dns-master.jack.com.
$ORIGIN jack.com.
dns-slave01              A       172.168.2.34
dns-master             A       172.168.2.35
test                    A       172.168.2.219
test2                   A       172.168.2.219
test3                   A       172.168.2.219
test4                   A       172.168.2.219
test5                   A       172.168.2.219
test6                   A       172.168.2.219
root@dns-slave01:/etc/bind# rndc reload
server reload successful

# 查看新的dns-slave
root@dns-master:/etc/bind# cat /var/cache/bind/jack.com.zone
$ORIGIN .
$TTL 600        ; 10 minutes
jack.com                IN SOA  dns-master.jack.com. admin.jack.com. (
                                2022000026 ; serial
                                86400      ; refresh (1 day)
                                3600       ; retry (1 hour)
                                604800     ; expire (1 week)
                                10800      ; minimum (3 hours)
                                )
                        NS      dns-master.jack.com.
$ORIGIN jack.com.
dns-slave01              A       172.168.2.34
dns-master             A       172.168.2.35
test                    A       172.168.2.219
test2                   A       172.168.2.219
test3                   A       172.168.2.219
test4                   A       172.168.2.219
test5                   A       172.168.2.219
test6                   A       172.168.2.219


# 客户端测试解析
> server 172.168.2.34
默认服务器:  dns-slave01.jack.com
Address:  172.168.2.34

> test6.jack.com
服务器:  dns-slave01.jack.com
Address:  172.168.2.34

名称:    test6.jack.com		#解析成功
Address:  172.168.2.219



> server 172.168.2.35
默认服务器:  dns-master.jack.com
Address:  172.168.2.35

> test6.jack.com
服务器:  dns-master.jack.com
Address:  172.168.2.35

名称:    test6.jack.com
Address:  172.168.2.219
```











