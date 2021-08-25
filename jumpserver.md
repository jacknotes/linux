#JumpServer

<pre>
REFERENCE: https://docs.jumpserver.org/zh/master/install/docker_install/

介绍：
JumpServer 是全球首款完全开源的堡垒机, 使用 GNU GPL v2.0 开源协议, 是符合 4A 的专业运维审计系统。
JumpServer 使用 Python / Django 进行开发, 遵循 Web 2.0 规范, 配备了业界领先的 Web Terminal 解决方案, 交互界面美观、用户体验好。
JumpServer 采纳分布式架构, 支持多机房跨区域部署, 中心节点提供 API, 各机房部署登录节点, 可横向扩展、无并发访问限制。
JumpServer 现已支持管理 SSH、 Telnet、 RDP、 VNC 协议资产。
改变世界, 从一点点开始。

特色优势：
开源: 零门槛，线上快速获取和安装；
分布式: 轻松支持大规模并发访问；
无插件: 仅需浏览器，极致的 Web Terminal 使用体验；
多云支持: 一套系统，同时管理不同云上面的资产；
云端存储: 审计录像云端存储，永不丢失；
多租户: 一套系统，多个子公司和部门同时使用。

环境要求：
硬件配置: 2个CPU核心, 4G 内存, 50G 硬盘（最低）
操作系统: Linux 发行版 x86_64
Python = 3.6.x
Mysql Server ≥ 5.6
Mariadb Server ≥ 5.5.56
Redis


#容器部署jumpserver
JumpServer 封装了一个 All in one Docker, 可以快速启动。该镜像集成了所需要的组件, "支持使用外置 Database 和 Redis"
注：环境迁移和更新升级请检查 SECRET_KEY 是否与之前设置一致, 不能随机生成, 否则数据库所有加密的字段均无法解密
----容器部署jumpserver_all容器
1. Linux 生成随机加密秘钥，使用 root 身份输入：
if [ ! "$SECRET_KEY" ]; then
  SECRET_KEY=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 50`;
  echo "SECRET_KEY=$SECRET_KEY" >> ~/.bashrc;
  echo $SECRET_KEY;
else
  echo $SECRET_KEY;
fi  
if [ ! "$BOOTSTRAP_TOKEN" ]; then
  BOOTSTRAP_TOKEN=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 16`;
  echo "BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN" >> ~/.bashrc;
  echo $BOOTSTRAP_TOKEN;
else
  echo $BOOTSTRAP_TOKEN;
fi
2. 部署jumpserver_all容器：
docker run --name jms_all -d \
  -p 80:80 -p 2222:2222 \
  -e SECRET_KEY=$SECRET_KEY \
  -e BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN \
  jumpserver/jms_all:latest
-----------额外变量说明------------
SECRET_KEY = ******
BOOTSTRAP_TOKEN = ******
DB_HOST = mysql_host
DB_PORT = 3306
DB_USER = jumpserver
DB_PASSWORD = weakPassword
DB_NAME = jumpserver
REDIS_HOST = redis_host
REDIS_PORT = 6379
REDIS_PASSWORD = weakPassword
VOLUME /opt/jumpserver/data/media
VOLUME /var/lib/mysql
----------------------------------
3. 访问：
浏览器访问: http://<容器所在服务器IP>
SSH 访问: ssh -p 2222 <容器所在服务器IP>
XShell 等工具请添加 connection 连接, 默认 ssh 端口 2222
默认管理员账户 admin 密码 admin

堡垒机操作流程：
1. 建立用户组
2. 建立用户，将用户加入用户组，并设定用户密码，以后是这里的用户连接jumpserver的ssh端口进行管理设备等操作的。
3. 进入资产管理中，增加管理用户，此用户是root或具有NOPASSWD权限的sudo用户。jumpserver将用此用户进行管理设备，一个设备对应一个管理用户。
4. 进入资产管理中，增加系统用户，设定用户名称，用户名，密码，登录模式为自动登录(连接时不用手动输入用户名 和密码)，协议为ssh，开启自动推送(如果机器中无此用户，则会自动增加用户和设定我们给定的密码)，也可以设定'命令过滤器'来允许或阻止用户命令(只要用户命令匹配到设定的正则命令则会允许或阻止)，设定sudo(开启普通用户可以使用的命令)，设定用户默认shell.
5. 进入资产列表添加资产，在左侧资产树中增加树节点(可以看做一个环境是一个节点，例如:pro)，然后选择树节点新建主机设备，设定：主机名，IP,指定系统平台，公网IP(无则跟IP字段一样即可),指定管理用户连接此主机设备的协议及端口(ssh:22)，选定之前建立的管理用户，选择节点属于哪个树节点。
6. 进入权限管理中，进行资产授权，创建一个授权：设定名称(例如：Ops-jack),并关联选定用户和用户组(此用户就是来登录堡垒机的)，选择资产(服务器等设备)，选择节点(树节点，例如pro)，选择系统用户(实际操作机器的帐记)，动作设定为全部，选择激活，最后确定即可。
7. 以上操作完成可即可连接堡垒机ssh端口进行管理设备，h是帮助，p是打印机器。可以在堡垒机web上进行实时监控的操作，查看用户执行的命令，用户的登录记录等信息。还可导出相关信息用于审计。


#外置数据库要求：
mysql 版本需要大于等于 5.6
mariadb 版本需要大于等于 5.5.6
数据库编码要求 uft8

1. 创建数据库
create database jumpserver default charset 'utf8' collate 'utf8_bin';
grant all on jumpserver.* to 'jumpserver'@'%' identified by 'weakPassword';
2. 安装redis数据库，并设定访问redis库密码
3. 运行jumpserver容器
[root@hohong-node2 ~]# docker run --name jms_all -d -v /opt/jumpserver:/opt/jumpserver/data/media  -p 80:80 -p 2222:2222 -e SECRET_KEY=$SECRET_KEY -e BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN -e DB_HOST=192.168.230.80 -e DB_PORT=3306 -e DB_USER=jumpserver -e DB_PASSWORD=weakPassword -e DB_NAME=jumpserver -e REDIS_HOST=192.168.230.80 -e REDIS_PORT=6379 -e REDIS_PASSWORD=weakPassword jumpserver/jms_all:latest


</pre>

<pre>
#Jumpserver部署
#URL: https://jumpserver.readthedocs.io/zh/master/install/step_by_step/
JumpServer 环境要求:
硬件配置: 2个CPU核心, 4G 内存, 50G 硬盘（最低）
操作系统: Linux 发行版 x86_64
Python = 3.6.x
Mysql Server ≥ 5.7
Redis

安装 Python3.6 MySQL Redis--mysql和python3.6可通过yum安装
--安装mysql后一定要记得配置环境变量，并且卸载mariadb，否则./jms start连接数据库启动不起来
echo 'export PATH=${PATH}:/usr/local/mysql/bin' > /etc/profile.d/mysql.sh
. /etc/profile.d/mysql.sh
[root@opsnginx jumpserver]# cat /etc/ld.so.conf.d/mysql.conf 
/usr/local/mysql/lib
[root@opsnginx jumpserver]#  ldconfig -v
[root@opsnginx jumpserver]# ln -sv /usr/local/mysql/include/ /usr/include/mysql
#1. 安装redis:
[root@test /data/redis]# mkdir -p /data/redis
[root@test /data/redis]# vim /data/redis/redis.conf
[root@test /data/redis]# cat /data/redis/redis.conf 
bind 0.0.0.0
port 6379
requirepass "123456"
masterauth "123456"
daemonize no
pidfile "/data/redis_6369.pid"
loglevel notice
logfile "redis_6369.log"
databases 16
always-show-logo yes
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename "dump_6369.rdb"
appendonly yes
appendfilename "appendonly_6369.aof"
appendfsync everysec
no-appendfsync-on-rewrite yes
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble yes
slowlog-log-slower-than 10000
slowlog-max-len 128
aof-rewrite-incremental-fsync yes
rdb-save-incremental-fsync yes
replica-priority 30
maxmemory 1gb

#docker运行redis
docker run -d \
-p 6379:6379 \
-v /data/redis/redis.conf:/usr/local/etc/redis/redis.conf \
-v /data/redis/data:/data \
--restart=always \
--name redis \
--privileged \
redis:5.0.10 \
redis-server /usr/local/etc/redis/redis.conf

#2. 配置mysql
[root@test ~]# mysql -uroot -p
MySQL [(none)]> create database jumpserver default charset 'utf8' collate 'utf8_bin';
MySQL [(none)]> set global validate_password_policy=LOW;
MySQL [(none)]> grant all on jumpserver.* to jumpserver_admin@'localhost' identified by 'jumpserver@123.com';
MySQL [(none)]> flush privileges;

--创建 Python 虚拟环境
[root@test ~]# python3.6 -m venv /opt/py3
--载入 Python 虚拟环境
[root@test ~]# source /opt/py3/bin/activate
(py3) [root@test ~]#
注：后面每次操作 JumpServer 都需要先载入 py3 虚拟环境

#3. 获取 JumpServer 代码
(py3) [root@test ~]# cd /opt && \
> wget https://github.com/jumpserver/jumpserver/releases/download/v2.5.3/jumpserver-v2.5.3.tar.gz
(py3) [root@test /opt]# tar xf jumpserver-v2.5.3.tar.gz
(py3) [root@test /opt]# mv jumpserver-v2.5.3 jumpserver

#4. 安装编译环境依赖
(py3) [root@test /opt]# cd /opt/jumpserver/requirements
[root@test /opt/jumpserver/requirements]# yum install -y $(cat rpm_requirements.txt)
[root@test /opt/jumpserver/requirements]# pip install -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/
或者
---
[root@test /data/redis]# cat /root/.pip/pip.conf 
[global]
timeout = 6000
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
---
安装中途报错：Python.h: No such file or directory，安装python3-devel
(py3) [root@test /opt/jumpserver/requirements]# yum install -y python3-devel
重新安装
(py3) [root@test /opt/jumpserver/requirements]# pip install -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/

#5. 修改配置文件
(py3) [root@test /opt/jumpserver/requirements]# cd /opt/jumpserver && \
> cp config_example.yml config.yml && \
> vi config.yml
[root@test /data/redis]# cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 49;echo
EkLA6TbB3Jn4aMmFY70VhfFMrYtfnfyORlVPMMIIiDewHLE4X
[root@test /data/redis]# cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 15;echo
NVae5xLfiOObJC7
-----------
# SECURITY WARNING: keep the secret key used in production secret!
# 加密秘钥 生产环境中请修改为随机字符串，请勿外泄, 可使用命令生成 
# $ cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 49;echo
SECRET_KEY: EkLA6TbB3Jn4aMmFY70VhfFMrYtfnfyORlVPMMIIiDewHLE4X

# SECURITY WARNING: keep the bootstrap token used in production secret!
# 预共享Token coco和guacamole用来注册服务账号，不在使用原来的注册接受机制
BOOTSTRAP_TOKEN: NVae5xLfiOObJC7

# Development env open this, when error occur display the full process track, Production disable it
# DEBUG 模式 开启DEBUG后遇到错误时可以看到更多日志
DEBUG: true

# DEBUG, INFO, WARNING, ERROR, CRITICAL can set. See https://docs.djangoproject.com/en/1.10/topics/logging/
# 日志级别
LOG_LEVEL: DEBUG
# LOG_DIR: 

# Session expiration setting, Default 24 hour, Also set expired on on browser close
# 浏览器Session过期时间，默认24小时, 也可以设置浏览器关闭则过期
# SESSION_COOKIE_AGE: 86400
SESSION_EXPIRE_AT_BROWSER_CLOSE: true

# Database setting, Support sqlite3, mysql, postgres ....
# 数据库设置
# See https://docs.djangoproject.com/en/1.10/ref/settings/#databases

# SQLite setting:
# 使用单文件sqlite数据库
# DB_ENGINE: sqlite3
# DB_NAME: 
# MySQL or postgres setting like:
# 使用Mysql作为数据库
DB_ENGINE: mysql
DB_HOST: 127.0.0.1
DB_PORT: 3306
DB_USER: jumpserver_admin
DB_PASSWORD: jumpserver@123.com 
DB_NAME: jumpserver

# When Django start it will bind this host and port
# ./manage.py runserver 127.0.0.1:8080
# 运行时绑定端口
HTTP_BIND_HOST: 0.0.0.0
HTTP_LISTEN_PORT: 8080
WS_LISTEN_PORT: 8070

# Use Redis as broker for celery and web socket
# Redis配置
REDIS_HOST: 127.0.0.1
REDIS_PORT: 6379
REDIS_PASSWORD: 123456
# REDIS_DB_CELERY: 3
# REDIS_DB_CACHE: 4

# Use OpenID Authorization
# 使用 OpenID 进行认证设置
# AUTH_OPENID: False # True or False
# BASE_SITE_URL: None
# AUTH_OPENID_CLIENT_ID: client-id
# AUTH_OPENID_CLIENT_SECRET: client-secret
# AUTH_OPENID_PROVIDER_ENDPOINT: https://op-example.com/
# AUTH_OPENID_PROVIDER_AUTHORIZATION_ENDPOINT: https://op-example.com/authorize
# AUTH_OPENID_PROVIDER_TOKEN_ENDPOINT: https://op-example.com/token
# AUTH_OPENID_PROVIDER_JWKS_ENDPOINT: https://op-example.com/jwks
# AUTH_OPENID_PROVIDER_USERINFO_ENDPOINT: https://op-example.com/userinfo
# AUTH_OPENID_PROVIDER_END_SESSION_ENDPOINT: https://op-example.com/logout
# AUTH_OPENID_PROVIDER_SIGNATURE_ALG: HS256
# AUTH_OPENID_PROVIDER_SIGNATURE_KEY: None
# AUTH_OPENID_SCOPES: "openid profile email"
# AUTH_OPENID_ID_TOKEN_MAX_AGE: 60
# AUTH_OPENID_ID_TOKEN_INCLUDE_CLAIMS: True
# AUTH_OPENID_USE_STATE: True
# AUTH_OPENID_USE_NONCE: True
# AUTH_OPENID_SHARE_SESSION: True
# AUTH_OPENID_IGNORE_SSL_VERIFICATION: True
# AUTH_OPENID_ALWAYS_UPDATE_USER: True

# Use Radius authorization
# 使用Radius来认证
# AUTH_RADIUS: false
# RADIUS_SERVER: localhost
# RADIUS_PORT: 1812
# RADIUS_SECRET: 

# CAS 配置
# AUTH_CAS': False,
# CAS_SERVER_URL': "http://host/cas/",
# CAS_ROOT_PROXIED_AS': 'http://jumpserver-host:port',  
# CAS_LOGOUT_COMPLETELY': True,
# CAS_VERSION': 3,

# LDAP/AD settings
# LDAP 搜索分页数量
# AUTH_LDAP_SEARCH_PAGED_SIZE: 1000
#
# 定时同步用户
# 启用 / 禁用
# AUTH_LDAP_SYNC_IS_PERIODIC: True
# 同步间隔 (单位: 时) (优先）
# AUTH_LDAP_SYNC_INTERVAL: 12
# Crontab 表达式
# AUTH_LDAP_SYNC_CRONTAB: * 6 * * *
#
# LDAP 用户登录时仅允许在用户列表中的用户执行 LDAP Server 认证
# AUTH_LDAP_USER_LOGIN_ONLY_IN_USERS: False
#
# LDAP 认证时如果日志中出现以下信息将参数设置为 0 (详情参见：https://www.python-ldap.org/en/latest/faq.html)
# In order to perform this operation a successful bind must be completed on the connection
# AUTH_LDAP_OPTIONS_OPT_REFERRALS: -1

# OTP settings
# OTP/MFA 配置
# OTP_VALID_WINDOW: 0
# OTP_ISSUER_NAME: Jumpserver

# Perm show single asset to ungrouped node
# 是否把未授权节点资产放入到 未分组 节点中
# PERM_SINGLE_ASSET_TO_UNGROUP_NODE: False
#
# 同一账号仅允许在一台设备登录
# USER_LOGIN_SINGLE_MACHINE_ENABLED: False
#
# 启用定时任务
# PERIOD_TASK_ENABLE: True
#
# 启用二次复合认证配置
# LOGIN_CONFIRM_ENABLE: False
#
# Windows 登录跳过手动输入密码
WINDOWS_SKIP_ALL_MANUAL_PASSWORD: true
-----------

#6. 启动 JumpServer
--第一次启动会很慢
cd /opt/jumpserver && ./jms start
--可以 -d 参数在后台运行
./jms start -d
[root@test /download]# netstat -tnlp | grep 80[78]0
tcp        0      0 0.0.0.0:8070            0.0.0.0:*               LISTEN      18185/python3.6     
tcp        0      0 0.0.0.0:8080            0.0.0.0:*               LISTEN      18136/python3.6 


#7. 正常部署 KoKo 组件----2019年9月30日，Jumpserver堡垒机发布V1.5.3版本。自 V1.5.3 版本起，Koko（即基于Go语言开发的SSH客户端）将担任Coco（即基于Python语言开发的SSH客户端）在Jumpserver项目中的角色，后续版本不会再对Coco进行维护。
[root@test /opt]# source /opt/py3/bin/activate
(py3) [root@test /opt]# 
#7.1 获取koko安装包
(py3) [root@test /opt]# cd /opt && \
> wget https://github.com/jumpserver/koko/releases/download/v2.5.3/koko-v2.5.3-linux-amd64.tar.gz
---
(可选)注：下载慢可用axel进行下载再放到此目录下：
[root@test /download]# axel  -n 30 https://github.com/jumpserver/koko/releases/download/v2.5.3/koko-v2.5.3-linux-amd64.tar.gz
[root@test /download]# cp koko-v2.5.3-linux-amd64.tar.gz /opt/
---
(py3) [root@test /opt]# tar -xf koko-v2.5.3-linux-amd64.tar.gz && \
mv koko-v2.5.3-linux-amd64 koko && \
chown -R root:root koko && \
cd koko \
mv kubectl /usr/local/bin/ && \
wget https://download.jumpserver.org/public/kubectl.tar.gz && \
tar -xf kubectl.tar.gz && \
chmod 755 kubectl && \
mv kubectl /usr/local/bin/rawkubectl && \
rm -rf kubectl.tar.gz

#7.2 编辑KOKO配置文件
(py3) [root@test /opt/koko]# cp config_example.yml config.yml && \
> vi config.yml
#----注：BOOTSTRAP_TOKEN 需要从 jumpserver/config.yml 里面获取, 保证一致
---
# 项目名称, 会用来向Jumpserver注册, 识别而已, 不能重复
# NAME: {{ Hostname }}

# Jumpserver项目的url, api请求注册会使用
CORE_HOST: http://127.0.0.1:8080

# Bootstrap Token, 预共享秘钥, 用来注册coco使用的service account和terminal
# 请和jumpserver 配置文件中保持一致，注册完成后可以删除
BOOTSTRAP_TOKEN: NVae5xLfiOObJC7

# 启动时绑定的ip, 默认 0.0.0.0
# BIND_HOST: 0.0.0.0

# 监听的SSH端口号, 默认2222
# SSHD_PORT: 2222

# 监听的HTTP/WS端口号，默认5000
# HTTPD_PORT: 5000

# 项目使用的ACCESS KEY, 默认会注册,并保存到 ACCESS_KEY_STORE中,
# 如果有需求, 可以写到配置文件中, 格式 access_key_id:access_key_secret
# ACCESS_KEY: null

# ACCESS KEY 保存的地址, 默认注册后会保存到该文件中
# ACCESS_KEY_FILE: data/keys/.access_key

# 设置日志级别 [DEBUG, INFO, WARN, ERROR, FATAL, CRITICAL]
# LOG_LEVEL: INFO

# SSH连接超时时间 (default 15 seconds)
# SSH_TIMEOUT: 15

# 语言 [en,zh]
# LANGUAGE_CODE: zh

# SFTP的根目录, 可选 /tmp, Home其他自定义目录
# SFTP_ROOT: /tmp

# SFTP是否显示隐藏文件
# SFTP_SHOW_HIDDEN_FILE: false

# 是否复用和用户后端资产已建立的连接(用户不会复用其他用户的连接)
# REUSE_CONNECTION: true

# 资产加载策略, 可根据资产规模自行调整. 默认异步加载资产, 异步搜索分页; 如果为all, 则资产全部加载, 本地搜索分页.
# ASSET_LOAD_POLICY:

# zip压缩的最大额度 (单位: M)
# ZIP_MAX_SIZE: 1024M

# zip压缩存放的临时目录 /tmp
# ZIP_TMP_PATH: /tmp

# 向 SSH Client 连接发送心跳的时间间隔 (单位: 秒)，默认为30, 0则表示不发送
# CLIENT_ALIVE_INTERVAL: 30

# 向资产发送心跳包的重试次数，默认为3
# RETRY_ALIVE_COUNT_MAX: 3

# 会话共享使用的类型 [local, redis], 默认local
# SHARE_ROOM_TYPE: local

# Redis配置
REDIS_HOST: 127.0.0.1
REDIS_PORT: 6379
REDIS_PASSWORD: 123456
# REDIS_CLUSTERS:
REDIS_DB_ROOM: 6
---

#7.3 启动koko
[root@test /opt/koko]# source /opt/py3/bin/activate
(py3) [root@test /opt/koko]# ./koko 
[root@test /download]# netstat -tnlp | egrep '2222|5000'
tcp6       0      0 :::5000                 :::*                    LISTEN      28945/./koko        
tcp6       0      0 :::2222                 :::*                    LISTEN      28945/./koko

#(可选)或者使用docker部署koko
docker run --name jms_koko -d \
  -p 2222:2222 \
  -p 127.0.0.1:5000:5000 \
  -e CORE_HOST=http://192.168.13.50:8080 \
  -e BOOTSTRAP_TOKEN=NVae5xLfiOObJC7 \
  -e LOG_LEVEL=ERROR \
  --privileged=true \
  --restart=always \
  jumpserver/jms_koko:v2.5.3


#8. Docker 部署 Guacamole 组件
----JUMPSERVER_SERVER地址不能使用127.0.0.1
docker run --name jms_guacamole -d \
  --restart=always \
  -p 8081:8080 \
  -e JUMPSERVER_KEY_DIR=/config/guacamole/key \
  -e JUMPSERVER_SERVER=http://192.168.13.50:8080 \
  -e BOOTSTRAP_TOKEN=NVae5xLfiOObJC7 \
  -e GUACAMOLE_LOG_LEVEL=ERROR \
  jumpserver/jms_guacamole:v2.5.3

#9. 下载 Lina 组件
[root@test /download]# axel -n 30 https://github.com/jumpserver/lina/releases/download/v2.5.3/lina-v2.5.3.tar.gz
[root@test /download]# cp lina-v2.5.3.tar.gz /opt/
[root@test /download]# cd /opt/
[root@test /opt]# tar -xf lina-v2.5.3.tar.gz
[root@test /opt]# mv lina-v2.5.3 lina
[root@test /opt]# useradd -M -s /sbin/nologin nginx
[root@test /opt]# chown -R nginx:nginx lina

#10. 下载 Luna 组件
[root@test /download]# axel -n 30 https://github.com/jumpserver/luna/releases/download/v2.5.3/luna-v2.5.3.tar.gz
[root@test /download]# cp luna-v2.5.3.tar.gz /opt/
[root@test /download]# cd /opt/
[root@test /opt]# tar -xf luna-v2.5.3.tar.gz
[root@test /opt]# mv luna-v2.5.3 luna
[root@test /opt]# chown -R nginx:nginx luna

#11. 配置 Nginx 整合各组件
[root@test /download]# tar xf pcre-8.44.tar.gz 
[root@test /download]# tar xf tengine-2.3.2.tar.gz 
[root@test /download]# cd tengine-2.3.2/
[root@test /download/tengine-2.3.2]# ./configure --prefix=/usr/local/tengine --sbin-path=/usr/local/tengine/sbin/nginx --conf-path=/usr/local/tengine/conf/nginx.conf --error-log-path=/usr/local/tengine/log/error.log --http-log-path=/usr/local/tengine/log/access.log --pid-path=/usr/local/tengine/tengine.pid --lock-path=/usr/local/tengine/lock/tengine.lock --user=nginx --group=nginx --with-pcre=/download/pcre-8.44 --with-http_ssl_module --with-http_flv_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_sub_module
[root@test /download/tengine-2.3.2]# make -j 4 && make install && echo $?
---
[root@test /usr/local/tengine]# cat /etc/init.d/nginx 
#!/bin/bash
#
# nginx - this script starts and stops the nginx daemon
#
# chkconfig: - 85 15
# description: Nginx is an HTTP(S) server, HTTP(S) reverse
# proxy and IMAP/POP3 proxy server
# processname: nginx
# config: /usr/local/tengine/conf/nginx.conf
# config: /etc/sysconfig/nginx
# pidfile: /usr/local/tengine/tengine.pid
  
# Source function library.
. /etc/rc.d/init.d/functions
  
# Source networking configuration.
. /etc/sysconfig/network
  
# Check that networking is up.
[ "$NETWORKING" = "no" ] && exit 0
  
TENGINE_HOME="/usr/local/tengine/"
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
---
[root@test /usr/local/tengine]# chmod +x /etc/init.d/nginx
[root@test /usr/local/tengine]# service nginx start
---
[root@test /usr/local/tengine/conf]# cat nginx.conf
worker_processes  4;

events {
    use epoll;
    worker_connections  1024;
}


http {
	include       mime.types;
	default_type  application/octet-stream;
	log_format  dm  '"$request_body"';
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
        access_log  log/access.log  log_json;
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

    client_max_body_size 100m;  # 录像及文件上传大小限制

    location /ui/ {
        try_files $uri / /index.html;
        alias /opt/lina/;
    }

    location /luna/ {
        try_files $uri / /index.html;
        alias /opt/luna/;  # luna 路径, 如果修改安装目录, 此处需要修改
    }

    location /media/ {
        add_header Content-Encoding gzip;
        root /opt/jumpserver/data/;  # 录像位置, 如果修改安装目录, 此处需要修改
    }

    location /static/ {
        root /opt/jumpserver/data/;  # 静态资源, 如果修改安装目录, 此处需要修改
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
[root@test /usr/local/tengine/conf]# service nginx reload
注：等待运行完成后，可访问http://{server_ip}:8080进行访问，默认密码:admin/admin






#Jumpserver迁移
#URL: https://jumpserver.readthedocs.io/zh/master/admin-guide/migration/
source: 192.168.13.50
destination: 192.168.13.66
#50
[root@test ~]# service nginx reload
[root@test /download]# mysqldump -uroot -p --master-data=2 --single-transaction --databases jumpserver > jumpserver.sql
#66迁移数据
[root@opsnginx opt]# scp -r root@192.168.13.50:/opt/jumpserver /opt
[root@opsnginx opt]# scp -r root@192.168.13.50:/opt/koko /opt
[root@opsnginx opt]# scp -r root@192.168.13.50:/download/jumpserver.sql /opt
[root@opsnginx opt]# ls
jumpserver  jumpserver.sql  rh
--安装mysql(版本必须和原数据库一致且大于等于5.7)、python(3.6.x)、docker,此步骤省略
Python = 3.6.x
Mysql Server ≥ 5.7
--安装mysql后一定要记得配置环境变量，并且卸载mariadb，否则./jms start连接数据库启动不起来
echo 'export PATH=${PATH}:/usr/local/mysql/bin' > /etc/profile.d/mysql.sh
. /etc/profile.d/mysql.sh
[root@opsnginx jumpserver]# cat /etc/ld.so.conf.d/mysql.conf 
/usr/local/mysql/lib
[root@opsnginx jumpserver]#  ldconfig -v
[root@opsnginx jumpserver]# ln -sv /usr/local/mysql/include/ /usr/include/mysql

--安装redis
[root@test /data/redis]# mkdir -p /data/redis
[root@test /data/redis]# vim /data/redis/redis.conf
[root@test /data/redis]# cat /data/redis/redis.conf 
bind 0.0.0.0
port 6379
requirepass "123456"
masterauth "123456"
#alert,must is no
daemonize no
pidfile "/data/redis_6369.pid"
loglevel notice
logfile "redis_6369.log"
databases 16
always-show-logo yes
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename "dump_6369.rdb"
#open aof
appendonly yes
appendfilename "appendonly_6369.aof"
#aof log everysec sync persistent device
appendfsync everysec
no-appendfsync-on-rewrite yes
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble yes
slowlog-log-slower-than 10000
slowlog-max-len 128
aof-rewrite-incremental-fsync yes
rdb-save-incremental-fsync yes
replica-priority 30
maxmemory 1gb

#docker运行redis
docker run -d \
-p 6379:6379 \
-v /data/redis/redis.conf:/usr/local/etc/redis/redis.conf \
-v /data/redis/data:/data \
--restart=always \
--name redis \
--privileged \
redis:5.0.10 \
redis-server /usr/local/etc/redis/redis.conf

#配置mysql
--这里创建数据库应用的账户密码建议与 jumpserver/config.yml 里面的数据库信息一致
mysql> create database jumpserver default charset 'utf8' collate 'utf8_bin';
mysql> set global validate_password_policy=LOW;
mysql> grant all on jumpserver.* to jumpserver_admin@'localhost' identified by 'jumpserver@123.com';
mysql> use jumpserver;
mysql> source /opt/jumpserver.sql

#
[root@opsnginx opt]# cd /opt
[root@opsnginx opt]# python3.6 -m venv py3
[root@opsnginx opt]# source /opt/py3/bin/activate
(py3) [root@opsnginx opt]# cd /opt/jumpserver/requirements
(py3) [root@opsnginx requirements]# yum -y install $(cat rpm_requirements.txt)
(py3) [root@opsnginx requirements]# yum install -y python3-devel
(py3) [root@opsnginx requirements]# pip install -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/
----启动jumpserver
(py3) [root@opsnginx requirements]# cd /opt/jumpserver/ && ./jms start -d 
注：新的机器安装数据库未授权jumpserver_admin@'127.0.0.1' dentified by 'jumpserver@123.com';，启动时始终起不来，谨记配置文件是怎么写，用户权限就怎么分配。
----启动koko
(py3) [root@opsnginx requirements]# cd /opt/koko/ && ./koko -d
注：也可以重新安装koko，但是报错： POST http://127.0.0.1:8080/api/v2/terminal/terminal-registrations/ failed, get code: 400, {"error":"service account registration disabled"}
后面知道了原因，原因是：web上设置“关闭了终端注册功能”，应该把此功能打开后再重新运行koko就可以成功了。


#复制lina、luna安装包并进行安装配置
[root@opsnginx jumpserver]# scp -r root@192.168.13.50:/opt/[kl]*.tar.gz /opt
root@192.168.13.50's password:  
lina-v2.5.3.tar.gz                                                                                                100% 1950KB   6.6MB/s   00:00    
luna-v2.5.3.tar.gz                                                                                                100% 1512KB   7.3MB/s   00:00    
#部署lina
(py3) [root@opsnginx opt]# cd /opt/
(py3) [root@opsnginx opt]# tar xf lina-v2.5.3.tar.gz 
(py3) [root@opsnginx opt]# mv lina-v2.5.3 lina
(py3) [root@opsnginx opt]# useradd -M -s /sbin/nologin nginx
(py3) [root@opsnginx opt]# chown -R nginx:nginx lina
#部署luna
(py3) [root@opsnginx opt]# cd /opt/
(py3) [root@opsnginx opt]# tar -xf luna-v2.5.3.tar.gz
(py3) [root@opsnginx opt]# mv luna-v2.5.3 luna
(py3) [root@opsnginx opt]# chown -R nginx:nginx luna

#Docker 部署 Guacamole 组件
----JUMPSERVER_SERVER地址不能使用127.0.0.1
docker run --name jms_guacamole -d \
  --restart=always \
  -p 127.0.0.1:8081:8080 \
  -e JUMPSERVER_SERVER=http://192.168.13.66:8080 \
  -e BOOTSTRAP_TOKEN=NVae5xLfiOObJC7 \
  -e GUACAMOLE_LOG_LEVEL=ERROR \
  jumpserver/jms_guacamole:v2.5.3
#开始tengine
[root@opsnginx jumpserver]# scp -r root@192.168.13.50:/usr/local/tengine/conf/nginx.conf /usr/local/tengine/conf
(py3) [root@opsnginx opt]# service nginx reload

#注：启动后来到会话管理--终端管理中查看到Guacamole是不在线的。去docker中看到报错信息：注册失败，可能已经注册过，请检查终端名称: [Gua]268b7a49f5b3
，此时只能删除注册信息，重新注册Guacamole。
(py3) [root@opsnginx opt]# docker rm -f 268b7a49f5b374915a3aa7951fa2b80671169726178e42646af1c7c410e3d3a9
268b7a49f5b374915a3aa7951fa2b80671169726178e42646af1c7c410e3d3a9
(py3) [root@opsnginx opt]# docker run --name jms_guacamole -d \
>   --restart=always \
>   -p 127.0.0.1:8081:8080 \
>   -e JUMPSERVER_SERVER=http://192.168.13.66:8080 \
>   -e BOOTSTRAP_TOKEN=NVae5xLfiOObJC7 \
>   -e GUACAMOLE_LOG_LEVEL=ERROR \
>   jumpserver/jms_guacamole:v2.5.3
注：如果上面还是注册不上，那就是web上设置“关闭了终端注册功能”，应该把此功能打开后再重新运行注册即可


#jumpserver分布式部署
#URL: https://jumpserver.readthedocs.io/zh/master/install/setup_by_prod/
1. mysql要主主模式
2. redis要是主从集群 
3. 集中存储，这里是NFS，高级应该换与ceph
4. jms需要两份，配置一样，两个节点都要部署，/opt/jumpserver/data/下的数据要放成集中存储进行共享存储
5. koko需要两份，两个节点进行配置，部署一样
6. guacamole需要两份，两个节点进行配置，部署一样
7. tengine安装 lina和luna前面静态资源，也要挂载/opt/jumpserver/data/下的数据，反向代理时需要用到。要把koko的22端口映射到tengine机器上，因为需要通过ssh到jumpserver所在
的2222端口上。
#下面附上核心配置：
(py3) [root@test /usr/local/tengine/sbin]# /usr/local/tengine/sbin/nginx -V 
Tengine version: Tengine/2.3.2
nginx version: nginx/1.17.3
built by gcc 4.8.5 20150623 (Red Hat 4.8.5-44) (GCC) 
built with OpenSSL 1.0.2k-fips  26 Jan 2017
TLS SNI support enabled
configure arguments: --prefix=/usr/local/tengine --sbin-path=/usr/local/tengine/sbin/nginx --conf-path=/usr/local/tengine/conf/nginx.conf --error-log-path=/usr/local/tengine/log/error.log --http-log-path=/usr/local/tengine/log/access.log --pid-path=/usr/local/tengine/tengine.pid --lock-path=/usr/local/tengine/lock/tengine.lock --user=nginx --group=nginx --with-pcre=/download/pcre-8.44 --with-http_ssl_module --with-http_flv_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_sub_module --with-stream --add-module=modules/ngx_http_upstream_session_sticky_module

--------------------------
(py3) [root@test /usr/local/tengine/sbin]# cat ../conf/nginx.conf
user  nginx;
worker_processes  auto;

error_log  /usr/local/tengine/log/error.log warn;
pid	/usr/local/tengine/tengine.pid;


events {
    worker_connections  1024;
}

stream {
    log_format  proxy  '$remote_addr [$time_local] '
                        '$protocol $status $bytes_sent $bytes_received '
                        '$session_time "$upstream_addr" '
                        '"$upstream_bytes_sent" "$upstream_bytes_received" "$upstream_connect_time"';

    access_log /usr/local/tengine/log/tcp-access.log  proxy;
    open_log_file_cache off;

    upstream kokossh {
        server 192.168.13.50:2221;
        server 192.168.13.65:2222;  # 多节点
        # 这里是 koko ssh 的后端ip
        least_conn;
    }

    server {
        listen 2222;
        proxy_pass kokossh;
        proxy_protocol on;
        proxy_connect_timeout 1s;
    }
}

http {
    include       /usr/local/tengine/conf/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /usr/local/tengine/log/access.log  main;

    sendfile        on;
    # tcp_nopush     on;

    keepalive_timeout  65;

    # 关闭版本显示
    server_tokens off;

    include /usr/local/tengine/conf/conf.d/*.conf;
}
--------------------------
(py3) [root@test /usr/local/tengine/sbin]# cat ../conf/conf.d/jumpserver.conf 
upstream core {
    server 192.168.13.50:8080;
    server 192.168.13.65:8080;
    session_sticky;
}

upstream ws {
    server 192.168.13.50:8070;
    server 192.168.13.65:8070;
    # 这里是 core 的后端ip
    session_sticky;
}

upstream koko {
    server 192.168.13.50:5000;
    server 192.168.13.65:5000;  # 多节点
    # 这里是 koko 的后端ip
    session_sticky;
}

upstream guacamole {
    server 192.168.13.50:8081;
    server 192.168.13.65:8081;  # 多节点
    # 这里是 guacamole 的后端ip
    session_sticky;
}

server {
    listen 80;
    # server_name demo.jumpserver.org;  # 自行修改成你的域名
    # return 301 https://$server_name$request_uri;
# }

# server {
    # 推荐使用 https 访问, 请自行修改下面的选项
    # listen 443 ssl;
    # server_name demo.jumpserver.org;  # 自行修改成你的域名
    # ssl_certificate   /etc/nginx/sslkey/1_jumpserver.org_bundle.crt;  # 自行设置证书
    # ssl_certificate_key  /etc/nginx/sslkey/2_jumpserver.org.key;  # 自行设置证书
    # ssl_session_timeout 5m;
    # ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
    # ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    # ssl_prefer_server_ciphers on;

    client_max_body_size 100m;  # 录像上传大小限制

    location /ui/ {
        try_files $uri / /index.html;
        alias /opt/lina/;
    }

    location /luna/ {
        try_files $uri / /index.html;
        alias /opt/luna/;  # luna 路径
    }

    location /media/ {
        add_header Content-Encoding gzip;
        root /opt/jumpserver/data/;  # 录像位置, 如果修改安装目录, 此处需要修改
    }

    location /static/ {
        root /opt/jumpserver/data/;  # 静态资源, 如果修改安装目录, 此处需要修改
    }

    location /koko/ {
        proxy_pass       http://koko;  # koko
        proxy_buffering  off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        access_log off;
    }

    location /guacamole/ {
        proxy_pass       http://guacamole/;  #  guacamole
        proxy_buffering  off;
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
        proxy_pass http://ws;
        proxy_http_version 1.1;
        proxy_buffering off;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    location /api/ {
        proxy_pass http://core;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location /core/ {
        proxy_pass http://core;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;  
    }

    location / {
        rewrite ^/(.*)$ /ui/$1 last;
    }
}
--------------------------
#经过测试在一个节点是停止了jms、koko、guacamole后，服务正常。

--重置密码
cd /opt/jumpserver/apps
python manage.py shell

from users.models import User
u = User.objects.get(username='admin')
u.reset_password('password')
u.save()

--MFA密码忘记重置
cd /opt/jumpserver/apps
python manage.py shell

from users.models import User
u = User.objects.get(username='admin')
u.mfa_level='0'
u.otp_secret_key=''
u.save()


#20210825--添加windows资产时注意情况
1.Ansible 要求在 Windows 主机上安装 PowerShell 3.0 或更高版本以及至少 .NET 4.0
2.如果在 Server 2008 上运行，则必须安装 SP2。如果在 Server 2008 R2 或 Windows 7 上运行，则必须安装 SP1
3.Windows Server 2008 只能安装 PowerShell 3.0；指定较新的版本将导致脚本失败
powershell2.0升级到powershell3.0需要安装升级补丁Windows6.1-KB2506143-x64

</pre>


