# immich

我叫 Alex。我学的是电气工程师，后来因为热爱解决问题而成为一名软件工程师。

我们和新生儿躺在床上，我的妻子说：“我们开始收集很多宝宝的照片和视频，我不想再为这个不能提名字的应用程序付费了。你总是想为我做点什么，那么你为什么不为我开发一个可以做到这一点的应用程序呢？”

这个想法就这样在我脑海中萌生了。之后，我开始在自托管领域寻找具有类似备份功能和性能水平的现有解决方案。我发现当前的解决方案主要集中在图库类型的应用程序上。但是，我想要一个易于使用的备份工具，带有一个可以高效查看照片和视频的原生移动应用程序。因此，我以一名渴望寻找的工程师的身份踏上了这段旅程。

促使我实现这个不得命名的应用程序替代或替换的另一个动机是为了回馈多年来让我受益匪浅的开源社区。

我很自豪能与您分享这一创作，它重视隐私、回忆以及通过易于使用和友好的界面回顾那些时刻的乐趣。



## 1. docker部署

```bash
## 1.安装docker
# step 1: 安装必要的一些系统工具
sudo yum install -y yum-utils

# Step 2: 添加软件源信息
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# Step 3: 安装Docker
sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Step 4: 开启Docker服务
sudo service docker start




## 2. 安装docker-compose
[root@RockLinux9 ~]# curl -oL /usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/v2.34.0/docker-compose-linux-x86_64




## 3.安装immich
[root@RockLinux9 ~]# mkdir ./immich-app
[root@RockLinux9 ~]# cd ./immich-app
[root@RockLinux9 ~/immich-app]# wget -O docker-compose.yml https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml
[root@RockLinux9 ~/immich-app]# wget -O .env https://github.com/immich-app/immich/releases/latest/download/example.env
[root@RockLinux9 ~/immich-app]# cat .env  | grep -Ev '#|^$'
UPLOAD_LOCATION=/data/immich
DB_DATA_LOCATION=/data/postgres
IMMICH_VERSION=release
DB_PASSWORD=gh1BcfTyPXSkKn3l
DB_USERNAME=postgres
DB_DATABASE_NAME=immich
[root@RockLinux9 ~/immich-app]# ls -a
.  ..  docker-compose.yml  .env


## 4.配置docker代理
[root@RockLinux9 ~/immich-app]# cat /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://172.168.2.219:10809"
Environment="HTTPS_PROXY=http://172.168.2.219:10809"
Environment="NO_PROXY=localhost,127.0.0.1"
[root@RockLinux9 ~/immich-app]# systemctl daemon-reload
[root@RockLinux9 ~/immich-app]# systemctl restart docker
[root@RockLinux9 ~/immich-app]# docker info  | grep Proxy
 HTTP Proxy: http://172.168.2.219:10809
 HTTPS Proxy: http://172.168.2.219:10809
 No Proxy: localhost,127.0.0.1
 
 
 ## 5. 运行immich
[root@RockLinux9 ~/immich-app]# docker-compose pull
[root@RockLinux9 ~/immich-app]# docker-compose up -d
[root@RockLinux9 ~/immich-app]# docker ps -a
CONTAINER ID   IMAGE                                                COMMAND                   CREATED       STATUS                 PORTS                    NAMES
b8607cd87d96   ghcr.io/immich-app/immich-server:release             "tini -- /bin/bash s…"   2 hours ago   Up 2 hours (healthy)   0.0.0.0:2283->2283/tcp   immich_server
96dfe7d45151   tensorchord/pgvecto-rs:pg14-v0.2.0                   "docker-entrypoint.s…"   2 hours ago   Up 2 hours (healthy)   5432/tcp                 immich_postgres
83beb3f75146   ghcr.io/immich-app/immich-machine-learning:release   "tini -- ./start.sh"      2 hours ago   Up 2 hours (healthy)                            immich_machine_learning
0e5c57e19694   redis:6.2-alpine                                     "docker-entrypoint.s…"   2 hours ago   Up 2 hours (healthy)   6379/tcp                 immich_redis
```




## 2. 访问immich
1. 浏览器访问http://172.168.2.40:2283
![](./image/immich/01.jpg)

2. 创建用户并配置硬盘限额
![](./image/immich/02.jpg)

3. 下载immich移动应用
3.1 用新用户登录并更改密码
3.2 配置地址连接immich服务，地址为：`http://172.168.2.40:2283/api`




## 3. 配置frp代理

### 3.1 配置frp服务端
```bash
root@hw2:~/download# curl -OL https://github.com/fatedier/frp/releases/download/v0.61.2/frp_0.61.2_linux_amd64.tar.gz
root@hw2:~/download# tar xf frp_0.61.2_linux_amd64.tar.gz -C /usr/local
root@hw2:~/download# cd /usr/local
root@hw2:~/download# ln -sv frp_0.61.2_linux_amd64 frp
root@hw2:~/download# cd /usr/local/frp
# 配置frps参数
root@hw2:/usr/local/frp# cat frps.toml 
[common]
bind_port = 8023
vhost_http_port = 8024
token = randomkey
# frp 管理后台端口 
dashboard_port = 8123
# frp 管理后台用户名和密码 
dashboard_user = user
dashboard_pwd = pass
# frp 日志配置 
log_file = /var/log/frps.log  
log_level = info 
log_max_days = 3 


## 配置service文件
root@hw2:/usr/local/frp# systemctl cat frps
# /lib/systemd/system/frps.service
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=simple
ExecStart=/usr/local/frp/frps -c /usr/local/frp/frps.toml
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true
StandardOutput=syslog
StandardError=inherit

[Install]
WantedBy=multi-user.target
root@hw2:/usr/local/frp# systemctl daemon-reload 
sroot@hw2:/usr/local/frp# systemctl start frps 
root@hw2:/usr/local/frp# ss -tnlp | grep frps 
LISTEN 0      4096               *:8024             *:*    users:(("frps",pid=3352567,fd=8))                                                       
LISTEN 0      4096               *:8023             *:*    users:(("frps",pid=3352567,fd=7))                                                       
LISTEN 0      4096               *:8123             *:*    users:(("frps",pid=3352567,fd=6))        
```



### 3.2 配置frp客户端
```bash
[root@RockLinux9 ~]# tar xf /usr/local/src/frp_0.61.2_linux_amd64.tar.gz -C /usr/local/
[root@RockLinux9 ~]# cd /usr/local/
[root@RockLinux9 /usr/local]# ln -sv frp_0.61.2_linux_amd64/ frp
[root@RockLinux9 /usr/local]# cd frp
[root@RockLinux9 /usr/local/frp]# cat /usr/local/frp/frpc.toml
[common]
server_addr = hw2.test.com
server_port = 8023
token = randomkey

[http-immich]
type = http
local_ip = 127.0.0.1
local_port = 2283
custom_domains = immich.test.com

#[ssh]
#type = tcp
#local_ip = 127.0.0.1
#local_port = 22
#remote_port = 10033

#[rdp]
#type = tcp
#local_ip = 172.168.2.122
#local_port = 3389
#remote_port = 10034



## 配置frpc服务
[root@RockLinux9 /usr/local/frp]# systemctl cat frpc
# /usr/lib/systemd/system/frpc.service
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=simple
ExecStart=/usr/local/frp/frpc -c /usr/local/frp/frpc.toml
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true
StandardOutput=syslog
StandardError=inherit

[Install]
WantedBy=multi-user.target


## 启动frpc服务
[root@RockLinux9 /usr/local/frp]# systemctl daemon-reload
[root@RockLinux9 /usr/local/frp]# systemctl start frpc
[root@RockLinux9 /usr/local/frp]# systemctl enable frpc
[root@RockLinux9 /usr/local/frp]# systemctl status frpc
● frpc.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/frpc.service; disabled; preset: disabled)
     Active: active (running) since Thu 2025-03-27 14:20:30 CST; 2s ago
   Main PID: 59969 (frpc)
      Tasks: 6 (limit: 22799)
     Memory: 4.7M
        CPU: 38ms
     CGroup: /system.slice/frpc.service
             └─59969 /usr/local/frp/frpc -c /usr/local/frp/frpc.toml
```



### 3.3 在frp服务器检查frp服务端配置的服务
```bash
# 查看frps的端口
# 8023: frp连接端口		8024：http端口		8123：frp管理界面
root@hw2:~# ss -tnlp | grep frp
LISTEN 0      4096               *:8024             *:*    users:(("frps",pid=3352567,fd=8))                                                       
LISTEN 0      4096               *:8023             *:*    users:(("frps",pid=3352567,fd=7))                                                       
LISTEN 0      4096               *:8123             *:*    users:(("frps",pid=3352567,fd=6))     

# 测试访问客户端注册上来的服务
root@hw2:~# curl -s -H 'Host: immich.test.com' http://127.0.0.1:8024 | grep immich
      .bg-immich-bg {
      .dark .dark\:bg-immich-dark-bg {
    class="absolute z-[1000] flex h-screen w-screen place-content-center place-items-center bg-immich-bg dark:bg-immich-dark-bg dark:text-immich-dark-fg"
  <body class="bg-immich-bg dark:bg-immich-dark-bg">
```



## 4. 配置nginx代理frp的http服务
通过nginx代理，可以实现http/https协议代理frp服务

**nginx配置**
```nginx
root@hw2:~# grep -Ev '#|^$' /etc/nginx/nginx.conf 
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;
events {
	worker_connections 768;
}
http {
    server {
        listen       8443 ssl;
        server_name  frp.test.com;
        ssl_certificate /etc/letsencrypt/live/test.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/test.com/privkey.pem;
        ssl_session_timeout 1d;
        ssl_session_tickets off;
        ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-CHACHA20-POLY1305;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers off;
        location / {
                add_header Strict-Transport-Security "max-age=31536000";
                proxy_pass http://127.0.0.1:8123;
                proxy_set_header    Host            $proxy_host;
                proxy_set_header    X-Real-IP       $remote_addr;
                proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_hide_header   X-Powered-By;
        }
    }
    server {
        listen       8443 ssl;
        server_name  immich.test.com;
        ssl_certificate /etc/letsencrypt/live/test.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/test.com/privkey.pem;
        ssl_session_timeout 1d;
        ssl_session_tickets off;
        ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-CHACHA20-POLY1305;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers off;
        location / {
                add_header Strict-Transport-Security "max-age=31536000";
                proxy_pass http://127.0.0.1:8024;
                proxy_set_header    Host            $host;
                proxy_set_header    X-Real-IP       $remote_addr;
                proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_hide_header   X-Powered-By;
        }
    }
}
```

**nginx启动和测试**
```bash
root@hw2:~# systemctl enable nginx 
Synchronizing state of nginx.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install enable nginx
syst	croot@hw2:~# systemctl start nginx 
root@hw2:~# systemctl status nginx 
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Thu 2025-03-27 14:49:49 CST; 40min ago
       Docs: man:nginx(8)
   Main PID: 3352438 (nginx)
      Tasks: 3 (limit: 1011)
     Memory: 11.5M
        CPU: 13.001s
     CGroup: /system.slice/nginx.service
             ├─3352438 "nginx: master process /usr/sbin/nginx -g daemon on; master_process on;"

# 测试nginx代理的服务是正常的
root@hw2:/etc/nginx# curl -s https://immich.test.com:8443 | grep immich 
      .bg-immich-bg {
      .dark .dark\:bg-immich-dark-bg {
    class="absolute z-[1000] flex h-screen w-screen place-content-center place-items-center bg-immich-bg dark:bg-immich-dark-bg dark:text-immich-dark-fg"
  <body class="bg-immich-bg dark:bg-immich-dark-bg">
```