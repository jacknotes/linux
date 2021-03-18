#OpenVPN
<pre>
环境是centos6.9
参考链接：https://www.cnblogs.com/along21/p/8339955.html

1、安装openvpn 和easy-rsa（该包用来制作ca证书）
（1）安装epel 仓库源
wget https://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
（2）安装openvpn
yum install openvpn -y
（3）在github 上，下载最新的easy-rsa
mkdir /download && cd /download
wget https://github.com/OpenVPN/easy-rsa/archive/master.zip
或者git clone https://github.com/OpenVPN/easy-rsa

2、配置/etc/openvpn/ 目录
mkdir -p /etc/openvpn/
cp -a easy-rsa/ /etc/openvpn/
cd /etc/openvpn/easy-rsa/easyrsa3/
cp vars.example vars
vim vars
--------------------------------------------------
set_var EASYRSA_REQ_COUNTRY     "CN"
set_var EASYRSA_REQ_PROVINCE    "Shanghai"
set_var EASYRSA_REQ_CITY        "Shanghai"
set_var EASYRSA_REQ_ORG         "along"
set_var EASYRSA_REQ_EMAIL       "along@163.com"
set_var EASYRSA_REQ_OU          "My OpenVPN"
--------------------------------------------------

3、创建服务端证书及key
 初始化：./easyrsa init-pki   # 初始化
 创建根证书：./easyrsa build-ca  
---------------
Enter New CA Key Passphrase:password  #输入CA密码用做签发证书用
Re-Enter New CA Key Passphrase:password  #重新再输一次
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:myopenvpn.com  #设定通用名
---------------
 创建服务器端证书：./easyrsa gen-req server nopass
---------------
Common Name (eg: your user, host, or server name) [server]:myopenssl.com  #设定通用名，不要跟前面一样
---------------
 签约服务端证书：./easyrsa sign server server
---------------
 Confirm request details: yes  #确认
Enter pass phrase for /etc/openvpn/easy-rsa/easyrsa3/pki/private/ca.key:  #提供我们当时创建CA时候的密码。如果你忘记了密码，那你就重头开始再来一次吧
---------------
 创建Diffie-Hellman，确保key穿越不安全网络的命令: ./easyrsa gen-dh

4、创建客户端证书
进入root目录新建client文件夹，文件夹可随意命名，然后拷贝前面解压得到的easy-ras文件夹到client文件夹,进入下列目录：
mkdir /etc/openvpn/client -p
cp -a /etc/openvpn/easy-rsa/ /etc/openvpn/client/
cd /etc/openvpn/client/easy-rsa/easyrsa3/
客户端初始化：./easyrsa init-pki    #需输入yes 确定，重新初始化pki目录
创建客户端key及生成证书（记住生成是自己客户端登录输入的密码）：
 ./easyrsa gen-req along  #名字自己定义
----------------
Enter PEM pass phrase:666666  #输入客户端登录时的密码，输入两次
Verifying - Enter PEM pass phrase:666666  #再输入一次
Common Name (eg: your user, host, or server name) [along]:  #输入通用名，默认为along，前面设置过
----------------
将客户端的along.req导入然后签约证书：
a. 进入到/etc/openvpn/easy-rsa/easyrsa3/：
cd /etc/openvpn/easy-rsa/easyrsa3/
b. 导入req：
./easyrsa import-req /etc/openvpn/client/easy-rsa/easyrsa3/pki/reqs/along.req along #ca导入客户端请求并命名为along
c. 签约证书:
 ./easyrsa sign client along  #签署客户端请求并指定的请求名为along//这里生成client所以必须为client，along要与之前导入名字一致
------------------
Confirm request details: yes
Enter pass phrase for /etc/openvpn/easy-rsa/easyrsa3/pki/private/ca.key:  #输入ca的密码
------------------

5、把服务器端必要文件放到etc/openvpn/ 目录下
ca的证书、服务端的证书、秘钥，DH的公钥：
cp /etc/openvpn/easy-rsa/easyrsa3/pki/ca.crt /etc/openvpn/ #把ca的证书放到/etc/openvpn/目录下
cp /etc/openvpn/easy-rsa/easyrsa3/pki/private/server.key /etc/openvpn/ #把服务器的私钥放到/etc/openvpn/目录下
cp /etc/openvpn/easy-rsa/easyrsa3/pki/issued/server.crt /etc/openvpn/ #把服务器的证书放到/etc/openvpn/目录下
cp /etc/openvpn/easy-rsa/easyrsa3/pki/dh.pem /etc/openvpn/ #把dh算法的密钥交换协议文件放到/etc/openvpn目录下

6、把客户端必要文件放到root/openvpn/client/ 目录下
客户端的证书、秘钥：
cp /etc/openvpn/easy-rsa/easyrsa3/pki/ca.crt /etc/openvpn/client/ #把ca证书放到/root/client/ 目录下
cp /etc/openvpn/easy-rsa/easyrsa3/pki/issued/along.crt /etc/openvpn/client/ #把客户端证书放到/root/client/ 目录下
cp /etc/openvpn/client/easy-rsa/easyrsa3/pki/private/along.key /etc/openvpn/client/#把客户端秘钥放到/root/client/ 目录下

7、为服务端编写配置文件
（1）当你安装好了openvpn时候，他会提供一个server配置的文件例子，在/usr/share/doc/openvpn-2.4.8/sample/sample-config-files/下会有一个server.conf文件，我们将这个文件复制到/etc/openvpn：
rpm -ql openvpn |grep server.conf
--------------
/usr/share/doc/openvpn-2.4.8/sample/sample-config-files/roadwarrior-server.conf
/usr/share/doc/openvpn-2.4.8/sample/sample-config-files/server.conf
/usr/share/doc/openvpn-2.4.8/sample/sample-config-files/xinetd-server-config
--------------
cp /usr/share/doc/openvpn-2.4.8/sample/sample-config-files/server.conf /etc/openvpn/
 （2）修改配置文件：
[root@localhost easyrsa3]# vim /etc/openvpn/server.conf
[root@localhost easyrsa3]# grep '^[^#|;]' /etc/openvpn/server.conf #编辑后的设置
##############证书认证###############
#server:
local 0.0.0.0 #监听地址
port 1194  #监听端口
proto tcp  #监听协议
dev tun  #采用隧道模式
ca /etc/openvpn/ca.crt  #指定ca证书路径
cert /etc/openvpn/server.crt  #指定服务器端证书路径
key /etc/openvpn/server.key  #指定服务器端秘钥路径
dh /etc/openvpn/dh.pem #指定dh算法密钥交换协议文件
server 172.31.254.0 255.255.255.0 #设定客户端分配的地址池，不能与内网地址段一样
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp" #设定给网关
push "dhcp-option DNS 8.8.8.8"  #设定dhcp分配dns
client-to-client #客户端之间互相通信
keepalive 10 120 #存活时间，10秒ping一次，120秒如果未收到响应则视为断线
comp-lzo #传输数据压缩
max-clients 100 #最大客户端连接数
user openvpn #用户
group openvpn  #用户组
persist-key
persist-tun
status 	/var/log/openvpn/openvpn-status.log #openvpn的状态日志路径
log     /var/log/openvpn/openvpn.log #openvpn的日志路径
verb 3
##############密码认证###############
local 0.0.0.0 #监听地址
port 1194  #监听端口
proto tcp  #监听协议
dev tun  #采用隧道模式
ca /etc/openvpn/ca.crt  #指定ca证书路径
cert /etc/openvpn/server.crt  #指定服务器端证书路径
key /etc/openvpn/server.key  #指定服务器端秘钥路径
dh /etc/openvpn/dh.pem #指定dh算法密钥交换协议文件
server 172.31.254.0 255.255.255.0 #设定客户端分配的地址池，不能与内网地址段一样
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp" #设定给网关
push "dhcp-option DNS 8.8.8.8"  #设定dhcp分配dns
client-to-client #客户端之间互相通信
keepalive 10 120 #存活时间，10秒ping一次，120秒如果未收到响应则视为断线
comp-lzo #传输数据压缩
max-clients 100 #最大客户端连接数
user openvpn #用户
group openvpn  #用户组
persist-key
persist-tun
status 	/var/log/openvpn/openvpn-status.log #openvpn的状态日志路径
log     /var/log/openvpn/openvpn.log #openvpn的日志路径
verb 3
auth-user-pass-verify /etc/openvpn/checkpsw.sh via-env  #开启密码认证文件路径 
client-cert-not-required  #不需要客户端使用证书
script-security 3  #脚本运行级别为3，这三个密码相关一定要开启，缺一不可
###########checkpsw.sh脚本############
#!/bin/sh
PASSFILE="/etc/openvpn/test.key"  #用户认证帐号密码文件一行一个帐号和密码，如：test test
LOG_FILE="/var/log/openvpn/test.key.log"
TIME_STAMP=`date "+%Y-%m-%d %T"`
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
注：每个项目都会由一大堆介绍,上述修改，openvpn提供的server.conf已经全部提供，我们只需要去掉前面的注释#，然后修改我们自己的有关配置
（3）配置后的设置：
[root@localhost easyrsa3]# mkdir /var/log/openvpn -p
[root@localhost easyrsa3]# chown -R openvpn.openvpn /var/log/openvpn/  #用户openvpn在安装openvpn软件时就已经自动创建
[root@localhost easyrsa3]# chown -R openvpn.openvpn /etc/openvpn/

8、iptables 设置nat 规则和打开路由转发
[root@localhost easyrsa3]# iptables -t nat -A POSTROUTING -s 172.31.254.0/24 -j MASQUERADE #设定防火墙，来自172.31.254.0/24的ip都转换为wan口上的ip，172.31.254.0/24是vpn拨进来的虚拟Ip
[root@along ~]# vim /etc/sysctl.conf //打开路由转发
net.ipv4.ip_forward = 1
[root@along ~]# sysctl -p
###高级路由，需要设置###
[root@openssl openvpn]# cat /etc/iproute2/rt_tables 
#
# reserved values
#
255	local
254	main
253	default
0	unspec
#
# local
#
#1	inr.ruhep
10 eth0table  #增加一张路由表，优先级为10，值越小越优先
--增加策略路由
[root@openssl openvpn]#/sbin/ip rule add to 192.168.0.0/16 table eth0table  #添加策略路由，指向eth0table路由表
[root@openssl openvpn]# ip rule show 
0:	from all lookup local 
32765:	from all to 192.168.0.0/16 lookup eth0table   #添加一条策略路由后优先级为32765，值越小越优先
32766:	from all lookup main 
32767:	from all lookup default
--设置路由表
[root@openssl openvpn]#/sbin/ip route add default via 192.168.1.254 table eth0table  #设置et0table路由表，所有进来的路由都指向网关
[root@openssl openvpn]# ip route show table eth0table
default via 192.168.1.254 dev eth0 
##################

9、开启openvpn 服务
[root@localhost easyrsa3]# openvpn /etc/openvpn/server.conf  & #开启服务
[root@localhost easyrsa3]# ss -tnlu | grep 1194  #检查服务是否启动
tcp    LISTEN     0      1                      *:1194                  *:*

##设置服务端开机自启动
[root@openssl openvpn]# grep '^[^#]' /etc/rc.local 
touch /var/lock/subsys/local
/sbin/ip rule add to 192.168.0.0/16 table eth0table
/sbin/ip route add default via 192.168.1.254 table eth0table
/usr/sbin/openvpn /etc/openvpn/.server.conf &


三、客户端连接openvpn
1、下载openvpn客户端安装
Windows客户端下载： https://swupdate.openvpn.org/community/releases/openvpn-install-2.4.7-I603.exe
在windows客户端上安装.exe安装包，在C:\Program Files\OpenVPN\sample-config目录下找到client.ovpn文件，这个是客户端配置文件，在linux下编辑更改
2、[root@smb-server ~]# grep '^[^#|;]' /Share/Info/linux/client.ovpn  #在linux下编辑更改配置如下
-------------证书认证------------
#client:
client
dev tun
proto tcp
remote 180.168.251.182 1194
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
cert client.crt
key client.key
;auth-user-pass
cipher AES-256-CBC
comp-lzo
verb 3
-------------密码认证------------
client
dev tun
proto tcp
remote 180.168.251.182 1194
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
auth-user-pass  #开启密码认证
cipher AES-256-CBC
comp-lzo
verb 3
--------------------------------
3、把服务器端的证书文件复制到C:\Program Files\OpenVPN\config目录下
ca.crt along.crt along.key #这三个文件，在/root/client/目录下有这三个文件，并把along.crt和along.key改名为client.crt和client.key，因为你的openvpn客户端配置文件已经注明公私钥名称
4、启动客户端
（1）启动，注意启动需以管理员权限启动
（2）输入自己设置的密码，这个密码是在服务器端设置客户端证书时设置的密码，这里为666666
5、测试是否成功
（1）在client 查询ip，确实是openvpn 给定的ip
（2）网页查询ip，确认是否是公司的ip

吊销客户端证书：
cd /etc/openvpn/easy-rsa/easyrsa3/ 
 ./easyrsa revoke tt
 ./easyrsa gen-crl #生成吊销列表，使服务端验证
 ln -s /etc/openvpn/easy-rsa/easyrsa3/pki/crl.pem crl.pem #在/etc/openvpn目录下建立吊销列表
vim /etc/openvpn/crl.pem
crl-verify crl.pem   #添加这行即可
openvpn --config /etc/openvpn/server.conf  #重启openvpn

</pre>


<pre>
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
set_var EASYRSA_REQ_EMAIL       "jacknotes@163.com"
set_var EASYRSA_REQ_OU          "homsom OpenVPN"
set_var EASYRSA_CERT_EXPIRE     3650        --开启客户端证书有效期
[root@iptables /etc/openvpn/server/EasyRSA-3.0.8]# ./easyrsa init-pki   --输入yes初始化PKI
[root@iptables /etc/openvpn/server/EasyRSA-3.0.8]# ./easyrsa build-ca
Enter New CA Key Passphrase:             --输入自定义密码homsom
Re-Enter New CA Key Passphrase:         --输入自定义密码homsom
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
Enter PEM pass phrase:                     --输入自定义密码jackli
Verifying - Enter PEM pass phrase:    --输入自定义密码jackli
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


</pre>
