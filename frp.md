#frp

## frp安装 
```
curl -OL https://github.com/fatedier/frp/releases/download/v0.44.0/frp_0.44.0_linux_amd64.tar.gz
tar xf frp_0.44.0_linux_amd64.tar.gz -C /usr/local/
cd /usr/local/
ln -sv frp_0.44.0_linux_amd64/ frp
cd frp
vim frps.ini 
```

## frp配置

### frp服务端配置
```
[root@prometheus frp]# cat frps.ini 
[common]
bind_port = 7123			#frp server port
vhost_http_port = 8088		#http port
vhost_https_port = 8099		#https port
token = idBANrqAS3hDK		#frp token

[root@prometheus frp]# systemctl cat frp.service 	#frp服务端启动脚本
# /usr/lib/systemd/system/frp.service
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=simple
ExecStart=/usr/local/frp/frps -c /usr/local/frp/frps.ini
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true
StandardOutput=syslog
StandardError=inherit

[Install]
WantedBy=multi-user.target
---
[root@prometheus frp]# systemctl daemon-reload 
[root@prometheus frp]# systemctl enable frp.service 
[root@prometheus frp]# systemctl start frp.service 
[root@prometheus frp]# ss -tnl | grep -E ':(7123|8088|8099)'
LISTEN     0      1024      [::]:8088                  [::]:*                  
LISTEN     0      1024      [::]:8099                  [::]:*                  
LISTEN     0      1024      [::]:7123                  [::]:*             
```


### frp客户端配置
```
root@gitlab:/usr/local/frp# cat frpc.ini	#客户端配置
[common]
server_addr = 114.114.114.114	#frp服务端Ip
server_port = 7123				#frp服务端Port
token = idBANrqAS3hDK			#frp服务端token，客户端跟服务端需要一致

[ssh]							#配置段描述
type = tcp						#类型为tcp
local_ip = 192.168.13.236		#本地ip和port，为frp穿透的对象
local_port = 22
remote_port = 8033				#指定服务端ssh端口，对应的是192.168.13.236:22

[web]							#配置段描述
type = http						#类型为http
local_ip = 192.168.13.236		#本地的http服务Ip及Port，此处为prometheus服务
local_port = 9090			
custom_domains = prometheus.markli.cn #对应的公网域名，需要映射到frp服务器，访问方式为http://prometheus.markli.cn:8088

[web2]
type = http
local_ip = 192.168.13.236
local_port = 3000
custom_domains = grafana.markli.cn

[rdp]							#配置段描述
type = tcp						#类型为tcp
local_ip = 172.168.2.122		#本地ip和port，为frp穿透的对象
local_port = 3389
remote_port = 7001				#指定服务端rdp端口，对应的是172.168.2.122:3389
---

root@gitlab:/usr/local/frp# systemctl cat frpc.service
# /usr/lib/systemd/system/frpc.service
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=simple
ExecStart=/usr/local/frp/frpc -c /usr/local/frp/frpc.ini
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true
StandardOutput=syslog
StandardError=inherit

[Install]
WantedBy=multi-user.target
---

root@gitlab:/usr/local/frp# systemctl daemon-reload
root@gitlab:/usr/local/frp# systemctl enable frpc.service
root@gitlab:/usr/local/frp# systemctl start frpc.service

```

#### frp客户端启动后服务端自动监听端口
例如上方8033、7001，另外frpc中配置的域名也会自动在frps中体现，只要token认证通过就可实现
```
[root@prometheus frp]# ss -tnl | grep -E ':(8033|7001)'
LISTEN     0      1024      [::]:7001                  [::]:*                  
LISTEN     0      1024      [::]:8033                  [::]:*    
[root@prometheus frp]# iptables -vnL	#如果公有云上ECS在本地开启了防火墙则需放行相应端口、另外安全组也需要放行
Chain INPUT (policy DROP 61 packets, 3164 bytes)
   98  5468 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            multiport ports 7123,8088,8099,8033
  182  9432 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            multiport dports 7001:7010

```