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
Enter New CA Key Passphrase:  #输入CA密码用做签发证书用
Re-Enter New CA Key Passphrase:
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
mkdir client
cp -a /etc/openvpn/easy-rsa/ client/
cd client/easy-rsa/easyrsa3/
客户端初始化：./easyrsa init-pki    #需输入yes 确定
创建客户端key及生成证书（记住生成是自己客户端登录输入的密码）：
 ./easyrsa gen-req along  #名字自己定义
----------------
Enter PEM pass phrase:666666  #输入客户端登录时的密码，输入两次
Verifying - Enter PEM pass phrase:
Common Name (eg: your user, host, or server name) [along]:  #输入通用名，默认为along，前面设置过
----------------
将客户端的along.req导入然后签约证书：
a. 进入到/etc/openvpn/easy-rsa/easyrsa3/：
cd /etc/openvpn/easy-rsa/easyrsa3/
b. 导入req：
./easyrsa import-req /root/client/easy-rsa/easyrsa3/pki/reqs/along.req along #ca导入客户端请求并命名为along
c. 签约证书:
 ./easyrsa sign client along  #签署客户端请求并指定的请求名为along//这里生成client所以必须为client，along要与之前导入名字一致
------------------
Confirm request details: yes
Enter pass phrase for /etc/openvpn/easy-rsa/easyrsa3/pki/private/ca.key:jackli  #输入ca的密码
------------------

5、把服务器端必要文件放到etc/openvpn/ 目录下
ca的证书、服务端的证书、秘钥，DH的公钥：
cp /etc/openvpn/easy-rsa/easyrsa3/pki/ca.crt /etc/openvpn/ #把ca的证书放到/etc/openvpn/目录下
cp /etc/openvpn/easy-rsa/easyrsa3/pki/private/server.key /etc/openvpn/ #把服务器的私钥放到/etc/openvpn/目录下
cp /etc/openvpn//easy-rsa/easyrsa3/pki/issued/server.crt /etc/openvpn/ #把服务器的证书放到/etc/openvpn/目录下
cp /etc/openvpn/easy-rsa/easyrsa3/pki/dh.pem /etc/openvpn/ #把dh算法的密钥交换协议文件放到/etc/openvpn目录下

6、把客户端必要文件放到root/openvpn/ 目录下
客户端的证书、秘钥：
cp /etc/openvpn/easy-rsa/easyrsa3/pki/ca.crt /root/client/ #把ca证书放到/root/client/ 目录下
cp /etc/openvpn/easy-rsa/easyrsa3/pki/issued/along.crt /root/client/ #把客户端证书放到/root/client/ 目录下
cp /root/client/easy-rsa/easyrsa3/pki/private/along.key /root/client #把客户端秘钥放到/root/client/ 目录下

7、为服务端编写配置文件
（1）当你安装好了openvpn时候，他会提供一个server配置的文件例子，在/usr/share/doc/openvpn-2.3.2/sample/sample-config-files 下会有一个server.conf文件，我们将这个文件复制到/etc/openvpn：
rpm -ql openvpn |grep server.conf
--------------
/usr/share/doc/openvpn-2.4.7/sample/sample-config-files/roadwarrior-server.conf
/usr/share/doc/openvpn-2.4.7/sample/sample-config-files/server.conf
/usr/share/doc/openvpn-2.4.7/sample/sample-config-files/xinetd-server-config
--------------
cp /usr/share/doc/openvpn-2.4.7/sample/sample-config-files/server.conf /etc/openvpn/ 
 （2）修改配置文件：
[root@localhost easyrsa3]# vim /etc/openvpn/server.conf
[root@localhost easyrsa3]# grep '^[^#|;]' /etc/openvpn/server.conf #编辑后的设置
local 0.0.0.0 #监听地址
port 1194  #监听端口
proto tcp  #监听协议
dev tun  #采用隧道模式
ca /etc/openvpn/ca.crt  #指定ca证书路径
cert /etc/openvpn/server.crt  #指定服务器端证书路径
key /etc/openvpn/server.key  #指定服务器端秘钥路径
dh /etc/openvpn/dh.pem #指定dh算法密钥交换协议文件
server 10.8.0.0 255.255.255.0 #设定客户端分配的地址池，不能与内网地址段一样
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
status /var/log/openvpn/openvpn-status.log #openvpn的状态日志路径
log         /var/log/openvpn/openvpn.log #openvpn的日志路径
verb 3
注：每个项目都会由一大堆介绍,上述修改，openvpn提供的server.conf已经全部提供，我们只需要去掉前面的注释#，然后修改我们自己的有关配置
（3）配置后的设置：
[root@localhost easyrsa3]# mkdir /var/log/openvpn
[root@localhost easyrsa3]# chown -R openvpn.openvpn /var/log/openvpn/
[root@localhost easyrsa3]# chown -R openvpn.openvpn /etc/openvpn/

8、iptables 设置nat 规则和打开路由转发
[root@localhost easyrsa3]# iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j MASQUERADE #设定防火墙，来自10.8.0.0/24的ip都转换为wan口上的ip
[root@along ~]# vim /etc/sysctl.conf //打开路由转发
net.ipv4.ip_forward = 1
[root@along ~]# sysctl -p

9、开启openvpn 服务
[root@localhost easyrsa3]# openvpn /etc/openvpn/server.conf  & #开启服务
[root@localhost easyrsa3]# ss -tnlu | grep 1194  #检查服务是否启动
tcp    LISTEN     0      1                      *:1194                  *:*


三、客户端连接openvpn
1、下载openvpn客户端安装
Windows客户端下载： https://swupdate.openvpn.org/community/releases/openvpn-install-2.4.7-I603.exe
在windows客户端上安装.exe安装包，在C:\Program Files\OpenVPN\sample-config目录下找到client.ovpn文件，这个是客户端配置文件，在linux下编辑更改
2、[root@smb-server ~]# grep '^[^#|;]' /Share/Info/linux/client.ovpn  #在linux下编辑更改配置如下
-------------
client
dev tun
proto tcp
remote 172.16.1.1 1194
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
cert client.crt
key client.key
comp-lzo
verb 3
-------------
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