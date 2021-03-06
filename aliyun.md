#Aliyun NoteBook
<pre>
#阿里云备案
需要备案服务号：ECS有效期必需>=3个月，必须有公网带宽，必须有EIP
备案服务号：如果没有，可以从另外渠道获取，只是一个备案能行证。
IP/公安备案：通过ICP备案后需要IP或者公安备案后才算真正的正常提供服务，ICP备案完成后，网站提供服务后30日内完成公安备案。



#添加公网网卡步骤： --20210317
1.创建弹性网卡 
2.弹性IP绑定辅助弹性网卡 
3.到新创建的弹性网卡上进行绑定ECS 
4.到绑定弹性IP的ECS上创建ifcfg-eth1配置文件并重启网络服务，实现添加公网地址网卡，此时会卡住，因为此时公网网卡已经生效，需要连接公网地址进入管理
[root@iptables network-scripts]# cp ifcfg-eth0 ifcfg-eth1
[root@iptables network-scripts]# cat ifcfg-eth1    --此网卡必须绑定第二个弹性网卡后才能使用
BOOTPROTO=dhcp
DEVICE=eth1
ONBOOT=yes
STARTMODE=auto
TYPE=Ethernet
USERCTL=no
[root@iptables network-scripts]#systemctl restart network
[root@iptables network-scripts]#ssh root@publicIP

实现SNAT代理上网：
1. 阿里云VPC网络IP地址不可以自己设定，网关不可以设定。
ip地址只能在控制台设定，网关在VPC网络的路由表中建立默认路由，指定下一跳到ECS(代理服务器)

2.网关到达绑定弹性IP的ECS，此时这个ECS需要做SNAT转换
2.1首先要开启ip转发
[root@iptables ~]# cat /etc/sysctl.d/snat.conf 
# ipforward
net.ipv4.ip_forward = 1
[root@iptables ~]# sysctl --system
[root@iptables ~]# sysctl -a | grep "net.ipv4.ip_forward"
net.ipv4.ip_forward = 1

3.创建iptables规则
[root@iptables yum.repos.d]# yum install -y iptables-services
#input
[root@iptables yum.repos.d]# iptables -I INPUT -s 222.66.21.210 -p tcp --dport 9572 -j ACCEPT
[root@iptables yum.repos.d]# iptables -I INPUT 2 -p tcp --dport 9572 -j DROP
[root@iptables yum.repos.d]#iptables -I INPUT -i lo -j ACCEPT
[root@iptables yum.repos.d]#iptables -I INPUT -p icmp -j ACCEPT
[root@iptables yum.repos.d]#iptables -I INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
#snat
[root@iptables yum.repos.d]# iptables -t nat -A POSTROUTING -s 10.0.0.0/8 -o eth1 -j SNAT --to-source 47.100.73.115
#dnat
[root@iptables yum.repos.d]# iptables -t nat -I PREROUTING -d 47.100.73.115 -p tcp --dport 80 --destication-to 10.10.10.240:80 
#start boot
[root@iptables yum.repos.d]# systemctl enable iptables
[root@iptables yum.repos.d]# service iptables save 




#openvpn for CentOS-7.9      --20210318
[root@iptables download]# yum install -y openvpn
[root@iptables download]# wget https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.8/EasyRSA-3.0.8.tgz
--配置服务端证书
[root@iptables /download]# tar xf EasyRSA-3.0.8.tgz
[root@iptables /download]# cp EasyRSA-3.0.8 /etc/openvpn/server
[root@iptables /download]# cd /etc/openvpn/server/EasyRSA-3.0.8/
[root@iptables /etc/openvpn/server/EasyRSA-3.0.8]# cp vars.example vars
[root@iptables /etc/openvpn/server/EasyRSA-3.0.8]# vim vars
set_var EASYRSA_REQ_COUNTRY     "CN"
set_var EASYRSA_REQ_PROVINCE    "Shanghai"
set_var EASYRSA_REQ_CITY        "Shanghai"
set_var EASYRSA_REQ_ORG         "ops"
set_var EASYRSA_REQ_EMAIL       "jack@qq.com"
set_var EASYRSA_REQ_OU          "OpenVPN"
set_var EASYRSA_CERT_EXPIRE     3650        --开启客户端证书有效期
[root@iptables /etc/openvpn/server/EasyRSA-3.0.8]# ./easyrsa init-pki   --输入yes初始化PKI
[root@iptables /etc/openvpn/server/EasyRSA-3.0.8]# ./easyrsa build-ca
Enter New CA Key Passphrase:             --输入自定义密码 
Re-Enter New CA Key Passphrase:         --输入自定义密码 
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:homsom.com       --通用名称
CA creation complete and you may now import and sign cert requests.
Your new CA certificate file for publishing is at:
/etc/openvpn/server/EasyRSA-3.0.8/pki/ca.crt

[root@iptables /etc/openvpn/server/EasyRSA-3.0.8]# ./easyrsa gen-req server nopass    --创建服务器证书名称叫server
Common Name (eg: your user, host, or server name) [server]:openvpn.homsom.com
Keypair and certificate request completed. Your files are:
req: /etc/openvpn/server/EasyRSA-3.0.8/pki/reqs/server.req
key: /etc/openvpn/server/EasyRSA-3.0.8/pki/private/server.key

[root@iptables /etc/openvpn/server/EasyRSA-3.0.8]# ./easyrsa sign server server     --签署服务器证书类型，这个服务器证书名称为server
Request subject, to be signed as a server certificate for 825 days:
subject=
    commonName                = openvpn.homsom.com
Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes
Enter pass phrase for /etc/openvpn/server/EasyRSA-3.0.8/pki/private/ca.key:      --输入ca的密码
Certificate created at: /etc/openvpn/server/EasyRSA-3.0.8/pki/issued/server.crt

[root@iptables /etc/openvpn/server/EasyRSA-3.0.8]# ./easyrsa gen-dh   --生成DH密钥交换算法文件
DH parameters of size 2048 created at /etc/openvpn/server/EasyRSA-3.0.8/pki/dh.pem


--配置客户端证书
[root@iptables /download]# cd /etc/openvpn/client/
[root@iptables /etc/openvpn/client]# cp -ar /download/EasyRSA-3.0.8 .
[root@iptables /etc/openvpn/client]# ll
total 0
drwxrwx--- 4 root openvpn 214 Sep 10  2020 EasyRSA-3.0.8
[root@iptables /etc/openvpn/client]# cd /etc/openvpn/client/EasyRSA-3.0.8/
[root@iptables /etc/openvpn/client/EasyRSA-3.0.8]# ./easyrsa init-pki
[root@iptables /etc/openvpn/client/EasyRSA-3.0.8]# ./easyrsa gen-req client   --生成客户端证书及请求
writing new private key to '/etc/openvpn/client/EasyRSA-3.0.8/pki/easy-rsa-18233.0QLwEq/tmp.N7mIEz'
Enter PEM pass phrase:                     --输入自定义密码 
Verifying - Enter PEM pass phrase:    --输入自定义密码 
Common Name (eg: your user, host, or server name) [client]:     --输入通用名称，默认为证书名称
Keypair and certificate request completed. Your files are:
req: /etc/openvpn/client/EasyRSA-3.0.8/pki/reqs/client.req
key: /etc/openvpn/client/EasyRSA-3.0.8/pki/private/client.key

--服务端导入客户端的请求文件
[root@iptables /etc/openvpn/client/EasyRSA-3.0.8]# cd /etc/openvpn/server/EasyRSA-3.0.8/
[root@iptables /etc/openvpn/server/EasyRSA-3.0.8]# ./easyrsa import-req /etc/openvpn/client/EasyRSA-3.0.8/pki/reqs/client.req client   --导入客户端表示文件并命名为client
--签署客户端请求
[root@iptables /etc/openvpn/server/EasyRSA-3.0.8]# ./easyrsa sign client client   --签署类型为客户端类型，客户端请求名称为client
Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes
Enter pass phrase for /etc/openvpn/server/EasyRSA-3.0.8/pki/private/ca.key:     --输入ca密码
Certificate created at: /etc/openvpn/server/EasyRSA-3.0.8/pki/issued/client.crt


--把服务器端私钥、公钥、根证书、DH算法文件放到etc/openvpn/ 目录下   
[root@iptables /etc/openvpn/server/EasyRSA-3.0.8]# cp /etc/openvpn/server/EasyRSA-3.0.8/pki/ca.crt /etc/openvpn/
[root@iptables /etc/openvpn/server/EasyRSA-3.0.8]# cp /etc/openvpn/server/EasyRSA-3.0.8/pki/dh.pem /etc/openvpn/
[root@iptables /etc/openvpn/server/EasyRSA-3.0.8]# cp /etc/openvpn/server/EasyRSA-3.0.8/pki/private/server.key /etc/openvpn/
[root@iptables /etc/openvpn/server/EasyRSA-3.0.8]# cp /etc/openvpn/server/EasyRSA-3.0.8/pki/issued/server.crt /etc/openvpn/
[root@iptables /etc/openvpn/server/EasyRSA-3.0.8]# ll /etc/openvpn/
total 20
-rw------- 1 root root    1204 Mar 18 11:15 ca.crt
drwxr-x--- 3 root openvpn   27 Mar 18 10:57 client
-rw------- 1 root root     424 Mar 18 11:15 dh.pem
drwxr-x--- 2 root openvpn    6 Dec 10 00:57 server
-rw------- 1 root root    4644 Mar 18 11:15 server.crt
-rw------- 1 root root    1704 Mar 18 11:15 server.key
--把客户端私钥、公钥、根证书放到root/openvpn/client 目录下
[root@iptables /etc/openvpn/server/EasyRSA-3.0.8]# cp /etc/openvpn/client/EasyRSA-3.0.8/pki/private/client.key /etc/openvpn/client/
[root@iptables /etc/openvpn/server/EasyRSA-3.0.8]# cp /etc/openvpn/server/EasyRSA-3.0.8/pki/ca.crt /etc/openvpn/client/
[root@iptables /etc/openvpn/server/EasyRSA-3.0.8]# cp /etc/openvpn/server/EasyRSA-3.0.8/pki/issued/client.crt /etc/openvpn/client/
[root@iptables /etc/openvpn/server/EasyRSA-3.0.8]# ll /etc/openvpn/client/
total 16
-rw------- 1 root root    1204 Mar 18 11:17 ca.crt
-rw------- 1 root root    4472 Mar 18 11:17 client.crt
-rw------- 1 root root    1834 Mar 18 11:17 client.key
drwxrwx--- 5 root openvpn  225 Mar 18 10:59 EasyRSA-3.0.8

--在服务器端配置文件
[root@iptables /etc/openvpn]# rpm -ql openvpn | grep server.conf
/usr/share/doc/openvpn-2.4.10/sample/sample-config-files/roadwarrior-server.conf
/usr/share/doc/openvpn-2.4.10/sample/sample-config-files/server.conf
/usr/share/doc/openvpn-2.4.10/sample/sample-config-files/xinetd-server-config
[root@iptables /etc/openvpn]# cp /usr/share/doc/openvpn-2.4.10/sample/sample-config-files/server.conf /etc/openvpn/
[root@iptables /etc/openvpn]# mkdir -p /var/log/openvpn
[root@iptables /etc/openvpn]# chown -R root.openvpn /etc/openvpn/
[root@iptables /etc/openvpn]# chown -R root.openvpn /var/log/openvpn/
[root@iptables /etc/openvpn]# chmod -R 770 /etc/openvpn/
[root@iptables /etc/openvpn]# chmod -R 770 /var/log/openvpn/
[root@iptables /etc/openvpn]# vim /etc/openvpn/server.conf 
[root@iptables /etc/openvpn]# grep '^[^#|;]' /etc/openvpn/server.conf   
--------此配置是证书认证---------
local 0.0.0.0
port 1194
proto tcp
dev tun
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key  # This file should be kept secret
dh /etc/openvpn/dh.pem
server 192.168.177.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 223.6.6.6"
client-to-client
keepalive 10 120
comp-lzo
max-clients 100
user openvpn
group openvpn
persist-key
persist-tun
status /var/log/openvpn/openvpn-status.log
log         /var/log/openvpn/openvpn.log
verb 3
-----------------------------
-------此配置是密码认证-------
local 0.0.0.0
port 1194
proto tcp
dev tun
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key  # This file should be kept secret
dh /etc/openvpn/dh.pem
server 192.168.177.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 223.6.6.6"
client-to-client
keepalive 10 120
comp-lzo
max-clients 100
user openvpn
group openvpn
persist-key
persist-tun
status /var/log/openvpn/openvpn-status.log
log         /var/log/openvpn/openvpn.log
verb 3
auth-user-pass-verify /etc/openvpn/checkpsw.sh via-env
client-cert-not-required
script-security 3 
-----------------------------
----------or-证书和密码认证------------
local 0.0.0.0
port 1194
proto tcp
dev tun
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key  # This file should be kept secret
dh /etc/openvpn/dh.pem
server 192.168.177.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 223.6.6.6"
client-to-client
keepalive 10 120
comp-lzo
max-clients 100
user openvpn
group openvpn
persist-key
persist-tun
status /var/log/openvpn/openvpn-status.log
log         /var/log/openvpn/openvpn.log
verb 3
auth-user-pass-verify /etc/openvpn/checkpsw.sh via-env
username-as-common-name
script-security 3
-------------------------------
[root@iptables /etc/openvpn]# cat checkpsw.sh
#!/bin/bash 
########################################################### 
# checkpsw.sh (C) 2004 Mathias Sundman <mathias@openvpn.se> 
# 
# This script will authenticate OpenVpn users against 
# a plain text file. The passfile should simply contain 
# one row per user with the username first followed by 
# one or more space(s) or tab(s) and then the password.

PASSFILE="/etc/openvpn/test.key"
LOG_FILE="/var/log/openvpn/test.key.log"
TIME_STAMP=`date "+%Y-%m-%d %T"`

###########################################################

if [ ! -r "${PASSFILE}" ]; then
echo "${TIME_STAMP}: Could not open password file \"${PASSFILE}\" for reading." >> ${LOG_FILE}
exit 1
fi

CORRECT_PASSWORD=`awk '!/^;/&&!/^#/&&$1=="'${username}'"{print $2;exit}' ${PASSFILE}`

if [ "${CORRECT_PASSWORD}" = "" ]; then
echo "${TIME_STAMP}: User does not exist: username=\"${username}\", password=\"${password}\"." >> ${LOG_FILE}
exit 1
fi

if [ "${password}" = "${CORRECT_PASSWORD}" ]; then
echo "${TIME_STAMP}: Successful authentication: username=\"${username}\"." >> ${LOG_FILE}
exit 0
fi

echo "${TIME_STAMP}: Incorrect password: username=\"${username}\", password=\"${password}\"." >> ${LOG_FILE}
exit 1
####################################

[root@iptables /etc/openvpn]# chmod 444 test.key
[root@iptables /etc/openvpn]# cat test.key 
---
jack jackli
---
[root@iptables /etc/openvpn]# cat /usr/lib/systemd/system/openvpn-homsom.service 
-------
[Unit]
Description=OpenVPN service
After=network-online.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/usr/sbin/openvpn --config /etc/openvpn/server.conf
Restart=on-failure

[Install]
WantedBy=multi-user.target
------
[root@iptables /etc/openvpn]# systemctl daemon-reload
[root@iptables /etc/openvpn]# systemctl start openvpn-homsom
[root@iptables /etc/openvpn]# systemctl enable openvpn-homsom
[root@iptables /etc/openvpn]# iptables -t nat -A POSTROUTING -s 192.168.177.0/24 -j MASQUERADE
[root@iptables /etc/openvpn]# iptables -I INPUT 4 -p tcp --dport 1194 -j ACCEPT


#客户端配置
------客户端证书认证，如果证书未设密码则用户不用密码即可连接------
client
dev tun
proto tcp
remote 47.100.73.115 1194
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
cert client.crt
key client.key
cipher AES-256-CBC
comp-lzo
verb 3
----客户端密码认证，不需要客户端公私钥------
client
dev tun
proto tcp
remote 47.100.73.115 1194
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
auth-user-pass
cipher AES-256-CBC
comp-lzo
verb 3
----客户端证书和密码认证，如果证书也设置密码，则需要输入两次密码，一次是证书密码，一次是密码认证的密码---
client
dev tun
proto tcp
remote 47.100.73.115 1194
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
cert client.crt
key client.key
auth-user-pass
cipher AES-256-CBC
comp-lzo
verb 3
------------------------

客户端看情况增加路由才能访问内部网络：
route add 192.168.13.0 mask 255.255.255.0 172.168.2.254
route add 192.168.10.0 mask 255.255.255.0 172.168.2.254




#tengine部署---10.10.10.240
[root@nginx ~]# yum groupinstall -y "Development Tools" "Development and Creative Workstation"
[root@nginx ~]# cd /download/
[root@nginx download]# curl -OL http://tengine.taobao.org/download/tengine-2.3.2.tar.gz
[root@nginx download]# curl -OL http://ftp.pcre.org/pub/pcre/pcre-8.44.tar.gz
[root@nginx download]# curl -OL https://codeload.github.com/yaoweibin/ngx_http_substitutions_filter_module/zip/master
[root@nginx download]# ls
master  pcre-8.44.tar.gz  tengine-2.3.2.tar.gz
[root@nginx download]# groupadd -r -g 8080 tengine
[root@nginx download]# useradd -r -g 8080 -u 8080 -s /sbin/nologin -M tengine
[root@nginx download]# unzip master
[root@nginx download]# tar xf pcre-8.44.tar.gz -C /usr/local/
[root@nginx download]# tar xf tengine-2.3.2.tar.gz 
[root@nginx download]# ll
total 4944
-rw-r--r--  1 root root  120840 Mar 18 19:50 master
drwxr-xr-x  5 root root    4096 Aug  6  2019 ngx_http_substitutions_filter_module-master
-rw-r--r--  1 root root 2090750 Mar 18 19:50 pcre-8.44.tar.gz
drwxrwxr-x 13 root root    4096 Sep  5  2019 tengine-2.3.2
-rw-r--r--  1 root root 2835884 Mar 18 19:45 tengine-2.3.2.tar.gz
[root@nginx download]# cd tengine-2.3.2
[root@nginx tengine-2.3.2]# yum install -y openssl-devel
[root@nginx download]# ./configure --prefix=/usr/local/nginx --sbin-path=/usr/local/nginx/sbin/nginx --conf-path=/usr/local/nginx/conf/nginx.conf --error-log-path=/usr/local/nginx/logs/error.log --http-log-path=/usr/local/nginx/logs/access.log --pid-path=/usr/local/nginx/tengine.pid --user=tengine --group=tengine --with-pcre=/usr/local/pcre-8.44 --with-http_ssl_module --with-http_flv_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_sub_module --with-stream --add-module=modules/ngx_http_upstream_session_sticky_module --add-module=/download/ngx_http_substitutions_filter_module-master --with-stream_ssl_module --add-module=modules/ngx_http_upstream_check_module --with-http_auth_request_module --with-http_gzip_static_module --with-http_random_index_module --with-http_sub_module
[root@nginx tengine-2.3.2]# make -j 4 && make install ;echo $?
[root@nginx conf]# cat /etc/init.d/tengine 
#!/bin/bash
#
# nginx - this script starts and stops the nginx daemon
#
# chkconfig: - 85 15
# description: Nginx is an HTTP(S) server, HTTP(S) reverse
# proxy and IMAP/POP3 proxy server
# processname: nginx
# config: /usr/local/nginx/conf/nginx.conf
# config: /etc/sysconfig/nginx
# pidfile: /var/run/nginx.pid
  
# Source function library.
. /etc/rc.d/init.d/functions
  
# Source networking configuration.
. /etc/sysconfig/network
  
# Check that networking is up.
[ "$NETWORKING" = "no" ] && exit 0
  
TENGINE_HOME="/usr/local/nginx/"
nginx=$TENGINE_HOME"sbin/nginx"
prog=$(basename $nginx)
  
NGINX_CONF_FILE=$TENGINE_HOME"conf/nginx.conf"
  
[ -f /etc/sysconfig/nginx ] && /etc/sysconfig/nginx
  
lockfile=/var/lock/subsys/nginx
  
start() {
    [ -x $nginx ] || exit 5
    [ -f $NGINX_CONF_FILE ] || exit 6
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
    killall -9 nginx
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
----------------------
[root@nginx tengine-2.3.2]# systemctl daemon-reload
[root@nginx tengine-2.3.2]# systemctl enable tengine


#bind DNS  --20210319
[root@nginx conf]# sed -i '/^DNS/ s/^\(.*\)$/#\1/' /etc/sysconfig/network-scripts/ifcfg-eth0
[root@nginx conf]# yum install -y bind bind-libs bind-utils
[root@nginx conf]#  grep -Ev '#|^$|^/' /etc/named.conf
-----------------------
options {
	listen-on port 53 { 127.0.0.1; 10.10.10.240; };
	listen-on-v6 port 53 { ::1; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
	statistics-file "/var/named/data/named_stats.txt";
	memstatistics-file "/var/named/data/named_mem_stats.txt";
	recursing-file  "/var/named/data/named.recursing";
	secroots-file   "/var/named/data/named.secroots";
	allow-query     { localhost; any; };
	allow-transfer  { 10.10.10.240; };
	forward first;                    
        	forwarders { 100.100.2.136; 100.100.2.138; };
	recursion yes;
	dnssec-enable yes;
	dnssec-validation yes;
	/* Path to ISC DLV key */
	bindkeys-file "/etc/named.root.key";
	managed-keys-directory "/var/named/dynamic";
	pid-file "/run/named/named.pid";
	session-keyfile "/run/named/session.key";
};
logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};
zone "." IN {
	type hint;
	file "named.ca";
};
include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
-----------------------
[root@nginx conf]# named-checkconf
[root@nginx conf]# systemctl enable named.service
[root@nginx conf]# systemctl start named.service
[root@nginx conf]# sed -i '/^#DNS/ s/^#\(.*\)$/\1/' /etc/sysconfig/network-scripts/ifcfg-eth0
[root@nginx etc]# vim /etc/named.rfc1912.zones 
zone "hs.com" IN {
        type master;
        file "hs.com.zone";
};
zone "10.10.10.in-addr.arpa" IN {
        type master;
        file "10.10.10.zone";
};
[root@nginx named]# cat /var/named/hs.com.zone 
$TTL 3600
$ORIGIN hs.com.
@       IN      SOA     ns1.hs.com.   admin.hs.com. (
        2021031901
        1H ; refresh
        10M ; retry
        3D ; expire
        1D ; negative answer ttl
)
        		IN      NS      ns1
	     		IN      A       10.10.10.240
ns1     		IN      A       10.10.10.240
iptables.ops     	IN      A       10.10.10.250
nginx.ops     		IN      A       10.10.10.240
jumpserver.ops     	IN      A       10.10.10.230
docker01.ops     	IN      A       10.10.10.101
docker02.ops     	IN      A       10.10.10.102
;docker03.ops     	IN      A       10.10.10.103
iptables     		IN     CNAME    iptables.ops

[root@nginx named]# cat /var/named/10.10.10.zone 
$ORIGIN 10.10.10.in-addr.arpa.
@       3600	IN      SOA     hs.com.    admin.hs.com. (
        2021031901
        1H ; refresh
        10M ; retry
        3D ; expire
        1D ; negative answer ttl 
)
        		IN      NS      ns1.hs.com.
250       		IN      PTR     iptables.ops.hs.com.
240       		IN      PTR     nginx.ops.hs.com.
230       		IN      PTR     jumpserver.ops.hs.com.
101       		IN      PTR     docker01.ops.hs.com.
102       		IN      PTR     docker02.ops.hs.com.
;103       		IN      PTR     docker03.ops.hs.com.

[root@nginx named]# named-checkzone hs.com hs.com.zone 
zone hs.com/IN: loaded serial 2021031901
OK
[root@nginx named]# named-checkzone 10.10.10.in-addr.arpa 10.10.10.zone 
10.10.10.zone:9: using RFC1035 TTL semantics
zone 10.10.10.in-addr.arpa/IN: loaded serial 2021031901
OK
[root@nginx named]# rndc reload
server reload successful


#ansible notebook
[root@jumpserver ansible]# ansible all -m copy -a 'src=/etc/sysconfig/network-scripts/ifcfg-eth0 dest=/etc/sysconfig/network-scripts/ifcfg-eth0 owner=root group=root mode=644 backup=yes'
[root@jumpserver ansible]# ansible all -m shell -a 'cat /etc/sysconfig/network-scripts/ifcfg-eth0'
[root@jumpserver ansible]# ansible all -m shell -a 'systemctl restart network'
[root@jumpserver ansible]# ansible all -m shell -a 'ping -qA -s 500 -w 1000 -c 10 hs.com'


#deploy jumpserver
require: mysql>=5.7,redis>=5.0
mysql: jumpserver
redis: kkD

mysql> create database jumpserver default charset 'utf8' collate 'utf8_bin';
mysql> grant all on jumpserver.* to jumpserver_admin@'127.0.0.1' identified by '123';
mysql> flush privileges;

[root@jumpserver /srv/salt/base/init]# cd /download/
[root@jumpserver /download]# axel -n 30 https://github.com/jumpserver/jumpserver/releases/download/v2.5.4/jumpserver-v2.5.4.tar.gz
[root@jumpserver /download]# tar xf jumpserver-v2.5.4.tar.gz -C /opt/
[root@jumpserver /download]# ln -sv /opt/jumpserver-v2.5.4/ /opt/jumpserver
[root@jumpserver /opt]# python3.6 -m venv /opt/py3
[root@jumpserver /opt]# source /opt/py3/bin/activate
(py3) [root@jumpserver /opt/jumpserver/requirements]#
(py3) [root@jumpserver /opt/jumpserver/requirements]# yum install -y `cat rpm_requirements.txt`
(py3) [root@jumpserver /opt/jumpserver/requirements]# yum install -y python3-devel
(py3) [root@jumpserver /opt/jumpserver/requirements]# pip install -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/
(py3) [root@jumpserver /opt/jumpserver/requirements]# cd /opt/jumpserver
(py3) [root@jumpserver /opt/jumpserver]# cp config_example.yml config.yml 
(py3) [root@jumpserver /opt/jumpserver]# cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 49;echo ''
mBsC2jwcfctRQ4VFTWeti
(py3) [root@jumpserver /opt/jumpserver]# cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 15;echo ''
UlxeRfB4PenMzXK
(py3) [root@jumpserver /opt/jumpserver]# grep -Ev '^$|#' /opt/jumpserver/config.yml    --key和token都必须一样
----
SECRET_KEY: mBsC2jwcfctRQ4VFTWetiE7F
BOOTSTRAP_TOKEN: UlxeRfB4P
DEBUG: true
LOG_LEVEL: DEBUG
LOG_DIR: /var/log/jumpserver.log
SESSION_COOKIE_AGE: 86400
SESSION_EXPIRE_AT_BROWSER_CLOSE: true
DB_ENGINE: mysql
DB_HOST: 127.0.0.1
DB_PORT: 3306
DB_USER: jumpserver_admin
DB_PASSWORD: jumpserver
DB_NAME: jumpserver
HTTP_BIND_HOST: 0.0.0.0
HTTP_LISTEN_PORT: 8080
WS_LISTEN_PORT: 8070
REDIS_HOST: 127.0.0.1
REDIS_PORT: 6379
REDIS_PASSWORD: kkD9g
WINDOWS_SKIP_ALL_MANUAL_PASSWORD: true
----
(py3) [root@jumpserver /opt/jumpserver]# /opt/jumpserver/jms start -d
(py3) [root@jumpserver /opt/jumpserver]# netstat -tnlp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:8070            0.0.0.0:*               LISTEN      18664/python3.6     
tcp        0      0 0.0.0.0:3306            0.0.0.0:*               LISTEN      13633/mysqld        
tcp        0      0 0.0.0.0:6379            0.0.0.0:*               LISTEN      15955/redis-server  
tcp        0      0 0.0.0.0:8080            0.0.0.0:*               LISTEN      18644/python3.6     
tcp        0      0 0.0.0.0:5555            0.0.0.0:*               LISTEN      18660/python3.6     
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      1008/sshd           
tcp        0      0 0.0.0.0:4505            0.0.0.0:*               LISTEN      6136/python3        
tcp        0      0 0.0.0.0:4506            0.0.0.0:*               LISTEN      6164/python3        
tcp6       0      0 :::9100                 :::*                    LISTEN      23273/node_exporter 
tcp6       0      0 :::5555                 :::*                    LISTEN      18660/python3.6     
--koko部署
(py3) [root@jumpserver /download]# axel -n 30 https://github.com/jumpserver/koko/releases/download/v2.5.4/koko-v2.5.4-linux-amd64.tar.gz
(py3) [root@jumpserver /download]# axel -n 30 https://download.jumpserver.org/public/kubectl.tar.gz
(py3) [root@jumpserver /download]# tar xf koko-v2.5.4-linux-amd64.tar.gz -C /opt/
(py3) [root@jumpserver /download]# tar xf kubectl.tar.gz 
(py3) [root@jumpserver /download]# cd /opt/
(py3) [root@jumpserver /opt]# ln -sv koko-v2.5.4-linux-amd64/ koko
(py3) [root@jumpserver /opt]# cd koko
(py3) [root@jumpserver /opt/koko]# mv kubectl /usr/local/bin/
(py3) [root@jumpserver /download]# chmod 755 /download/kubectl
(py3) [root@jumpserver /opt/koko]# mv /download/kubectl /usr/local/bin/rawkubectl
(py3) [root@jumpserver /opt/koko]# rm -rf /download/kubectl.tar.gz
(py3) [root@jumpserver /opt/koko]# cp config_example.yml config.yml 
(py3) [root@jumpserver /opt/koko]# vim config.yml
(py3) [root@jumpserver /opt/koko]# grep -Ev '#|^$' config.yml
CORE_HOST: http://127.0.0.1:8080
BOOTSTRAP_TOKEN: UlxeRfB4P K
REDIS_HOST: 127.0.0.1
REDIS_PORT: 6379
REDIS_PASSWORD: kkD9g 
REDIS_DB_ROOM: 6
(py3) [root@jumpserver /opt/koko]# /opt/koko/koko -s start -d 
(py3) [root@jumpserver /opt/koko]# netstat -tnlp | grep -E '2222|5000'
tcp6       0      0 :::5000                 :::*                    LISTEN      26822/koko          
tcp6       0      0 :::2222                 :::*                    LISTEN      26822/koko          
--Docker 部署 Guacamole 组件
docker run --name jms_guacamole -d \
  --restart=always \
  -p 127.0.0.1:8081:8080 \
  -e JUMPSERVER_KEY_DIR=/config/guacamole/key \
  -e JUMPSERVER_SERVER=http://10.10.10.230:8080 \
  -e BOOTSTRAP_TOKEN=Ulxe \
  -e GUACAMOLE_LOG_LEVEL=ERROR \
  jumpserver/guacamole:v2.5.4
--配置Lina和luna 组件
(py3) [root@jumpserver /download]# axel -n 30 https://github.com/jumpserver/lina/releases/download/v2.5.4/lina-v2.5.4.tar.gz
(py3) [root@jumpserver /download]# axel -n 30 https://github.com/jumpserver/luna/releases/download/v2.5.4/luna-v2.5.4.tar.gz
(py3) [root@jumpserver /download]# tar xf lina-v2.5.4.tar.gz -C /opt
(py3) [root@jumpserver /download]# tar xf luna-v2.5.4.tar.gz -C /opt
(py3) [root@jumpserver /download]# ln -sv /opt/lina-v2.5.4 /opt/lina && chown -R tengine:tengine /opt/lina-v2.5.4
(py3) [root@jumpserver /download]# ln -sv /opt/luna-v2.5.4 /opt/luna && chown -R tengine:tengine /opt/luna-v2.5.4
--警告迁移
(py3) [root@jumpserver /opt/koko]# cd /opt/jumpserver/apps/
(py3) [root@jumpserver /opt/jumpserver/apps]# ./manage.py makemigrations
Migrations for 'assets':
  assets/migrations/0063_auto_20210324_1925.py
    - Change Meta options on node
(py3) [root@jumpserver /opt/jumpserver/apps]# ./manage.py migrate
Operations to perform:
  Apply all migrations: admin, applications, assets, audits, auth, authentication, captcha, common, contenttypes, django_cas_ng, django_celery_beat, jms_oidc_rp, ops, orgs, perms, sessions, settings, terminal, tickets, users
Running migrations:
  Applying assets.0063_auto_20210324_1925... OK

注：koko组件相关连接mysql，当报mysql协议的客户端未安装时，因为jumpserver本机上未找到mysql，当是二进制安装时，
jumpserver不会识别，此时需要yum安装mariadb才行，yum install mariadb mariadb-libs mariadb-devel即可解决。
[root@jumpserver ~]# mv /etc/my.cnf.rpmsave /etc/my.cnf


--部署tengine
[root@jumpserver /opt]# salt 'jumpserver*' state.sls tengine.service saltenv=prod
[root@jumpserver /usr/local/nginx/conf]# grep -Ev '#|^$' nginx.conf
---
worker_processes  4;
events {
    worker_connections  10240;
}
http {
	include       mime.types;
	default_type  application/octet-stream;
	log_format  main  '$remote_addr - $remote_user [$time_local] "$request"'
                               '$status $body_bytes_sent "$http_referer"'
                               '"$http_user_agent" "$http_x_forwarded_for"';
	log_format log_json '{ "@timestamp": "$time_local", '
        '"remote_addr": "$remote_addr", '
        '"referer": "$http_referer", '
        '"host": "$host", '
        '"request": "$request", '
        '"status": $status, '
        '"bytes": $body_bytes_sent, '
        '"agent": "$http_user_agent", '
        '"x_forwarded": "$http_x_forwarded_for", '
        '"up_addr": "$upstream_addr",'
        '"up_host": "$upstream_http_host",'
        '"up_resp_time": "$upstream_response_time",'
        '"request_time": "$request_time"'
        ' }';
        access_log  logs/access.log  log_json;
	client_max_body_size 200m;
	underscores_in_headers on;
	server_tokens off;
	sendfile        on;
	keepalive_timeout  1024;
	gzip on;
	gzip_proxied any;
	gzip_http_version 1.1;
	gzip_min_length 1100;
	gzip_comp_level 5;
	gzip_buffers 8 16k;
	gzip_types application/json text/json text/plain text/xml text/css application/x-javascript application/xml application/xml+rss text/javascript application/atom+xml image/gif image/jpeg image/png;
	gzip_vary on;
    server {
    	listen 80;
	    location /ui/ {
	        try_files $uri / /index.html;
	        alias /opt/lina/;
	    }
	
	    location /luna/ {
	        try_files $uri / /index.html;
	    }
	
	    location /media/ {
	        add_header Content-Encoding gzip;
	    }
	
	    location /static/ {
	    }
	
	    location /koko/ {
	        proxy_pass       http://localhost:5000;
	        proxy_buffering off;
	        proxy_http_version 1.1;
	        proxy_set_header Upgrade $http_upgrade;
	        proxy_set_header Connection "upgrade";
	        proxy_set_header X-Real-IP $remote_addr;
	        proxy_set_header Host $host;
	        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	        access_log off;
	    }
	
	    location /guacamole/ {
	        proxy_pass       http://localhost:8081/;
	        proxy_buffering off;
	        proxy_http_version 1.1;
	        proxy_set_header Upgrade $http_upgrade;
	        proxy_set_header Connection $http_connection;
	        proxy_set_header X-Real-IP $remote_addr;
	        proxy_set_header Host $host;
	        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	        access_log off;
	    }
	
	    location /ws/ {
	        proxy_set_header X-Real-IP $remote_addr;
	        proxy_set_header Host $host;
	        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	        proxy_pass http://localhost:8070;
	        proxy_http_version 1.1;
	        proxy_buffering off;
	        proxy_set_header Upgrade $http_upgrade;
	        proxy_set_header Connection "upgrade";
	    }
	
	    location /api/ {
	        proxy_pass http://localhost:8080;
	        proxy_set_header X-Real-IP $remote_addr;
	        proxy_set_header Host $host;
	        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	    }
	
	    location /core/ {
	        proxy_pass http://localhost:8080;
	        proxy_set_header X-Real-IP $remote_addr;
	        proxy_set_header Host $host;
	        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	    }
	
	    location / {
	        rewrite ^/(.*)$ /ui/$1 last;
	    }
	}	
	server {
		listen       8088;
		location / {
                        add_header backendIP $upstream_addr;
                        proxy_redirect off;
                        proxy_set_header Host $host;
                        proxy_read_timeout 300s;
                        proxy_buffer_size  128k;
                        proxy_buffers   32 32k;
                        proxy_busy_buffers_size 128k; 
                        proxy_set_header X-Real-IP $remote_addr;
                        proxy_set_header X-Real-Port $remote_port;
                        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                }
		error_page   500 502 503 504  /50x.html;
		location = /50x.html {
			root   html;
		}
		location /NginxStatus {
			stub_status on;
		}
	}
}
---
[root@jumpserver /usr/local/nginx/conf]# cat /etc/init.d/tengine   --注：脚本出错在于注释过多，删除lock,pid等注释即可。
---
#!/bin/bash
#
# nginx - this script starts and stops the nginx daemon
#
# chkconfig: - 85 15
# description: Nginx is an HTTP(S) server, HTTP(S) reverse
# proxy and IMAP/POP3 proxy server
# processname: nginx
  
# Source function library.
. /etc/rc.d/init.d/functions
  
# Source networking configuration.
. /etc/sysconfig/network
  
# Check that networking is up.
[ "$NETWORKING" = "no" ] && exit 0
  
TENGINE_HOME="/usr/local/nginx/"
nginx=$TENGINE_HOME"sbin/nginx"
prog=$(basename $nginx)
  
NGINX_CONF_FILE=$TENGINE_HOME"conf/nginx.conf"
  
[ -f /etc/sysconfig/nginx ] && /etc/sysconfig/nginx
  
lockfile=/var/lock/subsys/nginx
  
start() {
    [ -x $nginx ] || exit 5
    [ -f $NGINX_CONF_FILE ] || exit 6
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
    killall -9 nginx
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
---jumpserver boot shell
[root@jumpserver ~]# cat /etc/init.d/jumpserver 
#!/bin/sh
# chkconfig: 35 90 10


# nodebook: manual kill beat
# ps aux | grep 'celery beat' | grep -v grep | awk '{print $2}' | xargs -I {} kill -9 {}

#start jumpserver
start(){
	source /opt/py3/bin/activate
	cd /opt/jumpserver && ./jms start -d
	cd /opt/koko && ./koko -s start -d 
	#RESULT=`docker ps | grep jms_guacamole >& /dev/null && echo 0 || echo 1`
	#if [ ${RESULT} == 1 ];then
	#	docker start jms_guacamole
	#fi
	docker restart jms_guacamole
	[ $? == 0 ] && echo "jumpserver start sucessful" || echo "jumpserver start failure"
}

stop(){
	source /opt/py3/bin/activate
        cd /opt/koko && ./koko -s stop
        cd /opt/jumpserver && ./jms stop
	RESULT=`docker ps | grep jms_guacamole >& /dev/null && echo 0 || echo 1`
	if [ ${RESULT} == 0 ];then
		docker stop jms_guacamole
	fi
	[ $? == 0 ] && echo "jumpserver stop sucessful" || echo "jumpserver stop failure"
	ps aux | grep 'celery beat' | grep -v grep | awk '{print $2}' | xargs -I {} kill -9 {}
}

status(){
	NET_RESULT=`netstat -tnlp | egrep "8080|8070|5000|2222|5555|8081" | wc -l`
	if [[ "${NET_RESULT}" < 6 ]];then
		echo "jumpserver is stop"
	else
        	echo "jumpserver is running"
        fi
}

case "$1" in 
	start)
		start
	;;
	stop)
		stop
	;;
	status)
		status
	;;
	*)
		echo "Usage: $0 [ start | stop | status ]"
	;;
esac


#iptables
iptables -t nat -R PREROUTING 1 -d 47.100.73.115 -p tcp --dport 80 -j DNAT --to-destination 10.10.10.240:80 
iptables -t nat -R PREROUTING 2 -d 47.100.73.115 -p tcp --dport 443 -j DNAT --to-destination 10.10.10.240:443
#iptables -t nat -R PREROUTING 1 ! -s 10.0.0.0/8 -d 47.100.73.115 -p tcp --dport 80 -j DNAT --to-destination 10.10.10.240:80 
#iptables -t nat -R PREROUTING 2 ! -s 10.0.0.0/8 -d 47.100.73.115 -p tcp --dport 443 -j DNAT --to-destination 10.10.10.240:443
#iptables -t nat -I POSTROUTING 1 ! -s 10.0.0.0/8 -d 10.10.10.240 -p tcp --dport 80 -j SNAT --to-source 10.10.10.250
#iptables -t nat -I POSTROUTING 2 ! -s 10.0.0.0/8 -d 10.10.10.240 -p tcp --dport 443 -j SNAT --to-source 10.10.10.250
--------------
[root@iptables ~]# cat /etc/sysconfig/iptables
# Generated by iptables-save v1.4.21 on Thu Mar 25 08:59:19 2021
*nat
:PREROUTING ACCEPT [701:41429]
:INPUT ACCEPT [37:2340]
:OUTPUT ACCEPT [76:4963]
:POSTROUTING ACCEPT [118:7235]
-A PREROUTING -d 47.100.73.115/32 -p tcp -m tcp --dport 80 -j DNAT --to-destination 10.10.10.240:80
-A PREROUTING -d 47.100.73.115/32 -p tcp -m tcp --dport 443 -j DNAT --to-destination 10.10.10.240:443
-A POSTROUTING -s 10.0.0.0/8 -o eth1 -j SNAT --to-source 47.100.73.115
-A POSTROUTING -s 192.168.177.0/24 -j MASQUERADE
COMMIT
# Completed on Thu Mar 25 08:59:19 2021
# Generated by iptables-save v1.4.21 on Thu Mar 25 08:59:19 2021
*filter
:INPUT DROP [330:133270]
:FORWARD ACCEPT [9432993:6241960630]
:OUTPUT ACCEPT [6309905:4980444813]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp -m tcp --dport 1194 -j ACCEPT
-A INPUT -s 192.168.177.0/24 -p tcp -m tcp --dport 9100 -j ACCEPT
-A INPUT -s 192.168.177.0/24 -p tcp -m tcp --dport 9572 -j ACCEPT
-A INPUT -s 10.0.0.0/8 -p tcp -m tcp --dport 9572 -j ACCEPT
-A INPUT -s 222.66.21.210/32 -p tcp -m tcp --dport 9572 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 9572 -j DROP
COMMIT
# Completed on Thu Mar 25 08:59:19 2021
--------------

--------------------------------------------------------------------------------
#在线扩容
--确认分区表格式和文件系统
[root@jumpserver ~]# fdisk -lu /dev/vda 

Disk /dev/vda: 214.7 GB, 214748364800 bytes, 419430400 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000e0364

   Device Boot      Start         End      Blocks   Id  System
/dev/vda1   *        2048   419430366   209714159+  83  Linux
如果System为Linux，说明数据盘使用的是MBR分区表格式。
如果System为GPT，说明数据盘使用的是GPT分区表格式。
[root@jumpserver ~]# blkid /dev/vda1 
/dev/vda1: UUID="795c9f31-f638-4308-8fab-4a7d5c606beb" TYPE="ext4" 

运行以下命令确认文件系统的状态
ext*文件系统：
[root@jumpserver ~]# e2fsck -n /dev/vda1 
e2fsck 1.42.9 (28-Dec-2013)
Warning!  /dev/vda1 is mounted.
Warning: skipping journal recovery because doing a read-only filesystem check.
/dev/vda1: clean, 258247/13107200 files, 4033360/52428539 blocks
xfs文件系统：
xfs_repair -n /dev/vda1
注意 本示例中，文件系统状态为clean，表示文件系统状态正常。如果状态不是clean，请排查并修复。

--在线扩容后容量 
[root@jumpserver ~]# fdisk -lu /dev/vda 

Disk /dev/vda: 225.5 GB, 225485783040 bytes, 440401920 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000e0364

   Device Boot      Start         End      Blocks   Id  System
/dev/vda1   *        2048   419430366   209714159+  83  Linux

--在线扩容云盘后，使用growpart和resize2fs等工具完成Linux系统盘扩展分区和文件系统
[root@jumpserver ~]# yum install cloud-utils-growpart xfsprogs -y
[root@jumpserver ~]# df -Th
Filesystem     Type      Size  Used Avail Use% Mounted on
devtmpfs       devtmpfs  3.7G     0  3.7G   0% /dev
tmpfs          tmpfs     3.7G  220K  3.7G   1% /dev/shm
tmpfs          tmpfs     3.7G  640K  3.7G   1% /run
tmpfs          tmpfs     3.7G     0  3.7G   0% /sys/fs/cgroup
/dev/vda1      ext4      197G   13G  177G   7% /
overlay        overlay   197G   13G  177G   7% /var/lib/docker/overlay2/3ac74b0f19183813328a7ad7f9177b55504a296168b6451ffe60462108fd45e8/merged
tmpfs          tmpfs     756M     0  756M   0% /run/user/0
返回分区（/dev/vda1）容量是197GiB，文件系统类型为ext4
--运行以下命令扩容分区
[root@jumpserver ~]# growpart /dev/vda 1 
CHANGED: partition=1 start=2048 old: size=419428319 end=419430367 new: size=440399839 end=440401887
[root@jumpserver ~]# fdisk -lu /dev/vda 

Disk /dev/vda: 225.5 GB, 225485783040 bytes, 440401920 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000e0364

   Device Boot      Start         End      Blocks   Id  System
/dev/vda1   *        2048   440401886   220199919+  83  Linux    --end扇区已经扩展了

--扩展文件系统
ext*文件系统（例如ext3和ext4）：运行以下命令扩展文件系统。
[root@jumpserver ~]# resize2fs /dev/vda1   --扩展文件系统
resize2fs 1.42.9 (28-Dec-2013)
Filesystem at /dev/vda1 is mounted on /; on-line resizing required
old_desc_blocks = 13, new_desc_blocks = 14
The filesystem on /dev/vda1 is now 55049979 blocks long.
--成功后大小
[root@jumpserver ~]# df -Th
Filesystem     Type      Size  Used Avail Use% Mounted on
devtmpfs       devtmpfs  3.7G     0  3.7G   0% /dev
tmpfs          tmpfs     3.7G  240K  3.7G   1% /dev/shm
tmpfs          tmpfs     3.7G  644K  3.7G   1% /run
tmpfs          tmpfs     3.7G     0  3.7G   0% /sys/fs/cgroup
/dev/vda1      ext4      207G   13G  186G   7% /
overlay        overlay   207G   13G  186G   7% /var/lib/docker/overlay2/3ac74b0f19183813328a7ad7f9177b55504a296168b6451ffe60462108fd45e8/merged
tmpfs          tmpfs     756M     0  756M   0% /run/user/0

xfs文件系统：运行以下命令扩展文件系统。
xfs_growfs <mountpoint>
example: xfs_growfs /
--------------------------------------------------------------------------------


#mysqld_exporter
mysql> grant select,process,replication client on *.* to 'mysqld_exporter'@'10.10.10.%' identified by 'lVPl5nwV8GriDhcP';
#mysql最大可用内存
select (@@key_buffer_size +@@innodb_buffer_pool_size + @@tmp_table_size + @@max_connections*(@@read_buffer_size + @@read_rnd_buffer_size + @@sort_buffer_size + @@join_buffer_size + @@binlog_cache_size + @@thread_stack) )/1024/1024 as "Total_AllMem result";

注：日常记录
redis、mysql数据库都需要设置白名单才可连接使用，其中redis连接密码为阿里云控制台设置的<user>:<password>，方可能redis-cli等客户端连接

#阿里云elasticsearch备份恢复整个快照
POST _snapshot/aliyun_auto_snapshot/<snapshot>/_restore?wait_for_completion=true
#elasticsearch备份恢复快照中的指定索引
POST _snapshot/aliyun_auto_snapshot/<snapshot>/_restore
{
"indices": "index_1",
"rename_pattern": "index_(.+)",
"rename_replacement": "restored_index_$1"
}


#SaaS
#Redis
程序读写除DB0以外的数据库时不成功，问题在哪？
答：如果您的Redis实例为集群架构或读写分离架构，且需要执行切换或选择数据库的操作（即使用多数据库功能），您必须先将cluster_compat_enable参数设置为0（即关闭原生Redis Cluster语法兼容），然后重启客户端应用。







#20210713
--OSS帮助命令
E:\Software\ossutil64>.\ossutil64.exe help cp
--OSS配置
E:\Software\ossutil64>.\ossutil64.exe config
--OSS测试网络
E:\Software\ossutil64>.\ossutil64.exe  probe --upload --bucketname dbs-backup-20159124-cn-shanghai --add aliyun.com
--OSS新建目录
E:\Software\ossutil64>.\ossutil64.exe mkdir oss://dbs-backup-20159124-cn-shanghai/test01
--OSS上传文件不重命名
E:\Software\ossutil64>.\ossutil64.exe cp e:\idrac_dashboard.json oss://dbs-backup-20159124-cn-shanghai/test01/
--OSS上传文件不重命名
E:\Software\ossutil64>.\ossutil64.exe cp e:\idrac_dashboard.json oss://dbs-backup-20159124-cn-shanghai/idrac.json 
--OSS列出Bucket文件
E:\Software\ossutil64>.\ossutil64.exe ls oss://dbs-backup-20159124-cn-shanghai
LastModifiedTime                   Size(B)  StorageClass   ETAG                                  ObjectName
2021-07-13 11:50:24 +0800 CST       444549      Standard   9540352DBC57D44FB6CC715153A599C0      oss://dbs-backup-20159124-cn-shanghai/test01
2021-07-13 11:49:02 +0800 CST            0      Standard   D41D8CD98F00B204E9800998ECF8427E      oss://dbs-backup-20159124-cn-shanghai/test01/
2021-07-13 11:51:10 +0800 CST       444549      Standard   9540352DBC57D44FB6CC715153A599C0      oss://dbs-backup-20159124-cn-shanghai/test01/idrac_dashboard.json
Object Number is: 3
--OSS删除一个对象
E:\Software\ossutil64>.\ossutil64.exe rm  oss://dbs-backup-20159124-cn-shanghai/test01
--OSS下载一个文件夹所有内容
E:\Software\ossutil64>.\ossutil64.exe cp oss://dbs-backup-20159124-cn-shanghai/snapshot/ --recursive .\


</pre>
