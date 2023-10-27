# 从nginx主备切换到LVS集群




## 1. 同步生产nginx(207)数据到nginx01(215)、nginx03(217)，/usr/local/nginx/sbin/nginx千万不能同步


```bash
# 1.0 查看当前服务器连接情况
netstat -ano | grep ESTABLISHED

# 1.1 同步数据到215
登录到215: 
systemctl stop nginx  && systemctl status nginx
\cp -ap /usr/local/nginx /root/nginx.bak-202310272300
cd /usr/local/nginx && rm -rf html/ conf/

登录到207: 
cd /usr/local/nginx && scp -r conf/ html/ root@192.168.13.215:/usr/local/nginx/

登录到215: 
cd /usr/local/nginx && chown -R nginx.nginx html/ conf/ && chmod -R 644 html/ conf/
systemctl start nginx  && systemctl status nginx


# 1.2 同步数据到217
登录到217: 
systemctl stop nginx  && systemctl status nginx
\cp -ap /usr/local/nginx /root/nginx.bak-202310272300
cd /usr/local/nginx && rm -rf html/ conf/

登录到207: 
cd /usr/local/nginx && scp -r conf/ html/ root@192.168.13.217:/usr/local/nginx/

登录到217: 
cd /usr/local/nginx && chown -R www.www html/ conf/ && chmod -R 644 html/ conf/
systemctl start nginx  && systemctl status nginx && systemctl reload nginx && systemctl status nginx

登录到215和217查看服务是否正常: 
ss -tnl
```



## 2. 配置nginx01(215)、nginx03(217)，使其具备 LVS后端服务器功能

2.1 内核参数配置
```bash
[/usr/local/nginx]# cat /etc/sysctl.conf 
net.ipv4.conf.eth0.arp_ignore=1
net.ipv4.conf.eth0.arp_announce=2
net.ipv4.conf.all.arp_ignore=1
net.ipv4.conf.all.arp_announce=2

[/usr/local/nginx]# sysctl --system
```

2.2 配置VIP地址永久生效
```bash
[/usr/local/nginx]# cat /etc/sysconfig/network-scripts/ifcfg-lo:*
DEVICE=lo:0
IPADDR=192.168.13.207
NETMASK=255.255.255.255
BROADCAST=192.168.13.207
ONBOOT=yes
DEVICE=lo:1
IPADDR=192.168.13.208
NETMASK=255.255.255.255
BROADCAST=192.168.13.208
ONBOOT=yes

[/usr/local/nginx]# systemctl restart network
```

2.3 测试SysV脚本，确保通过
```bash
[/usr/local/nginx]# ls /etc/init.d/lvs_nginx
/etc/init.d/lvs_nginx

chkconfig --add lvs_nginx && chkconfig --level 35 lvs_nginx on
service lvs_nginx status
service lvs_nginx restart && service lvs_nginx status
```



## 3. 配置2号环境prepro-nginx(209)


```bash
# 3.1 替换原有的ifcfg-eth0配置文件，使eth0网卡只有209IP地址
\cp -ap /etc/sysconfig/network-scripts/ifcfg-eth0.bak2 /etc/sysconfig/network-scripts/ifcfg-eth0

# 3.2 复制ifcfg-lo:0、ifcfg-lo:1文件
\cp -ap /shell/ifcfg/* /etc/sysconfig/network-scripts/

# 3.3 测试SysV脚本添加开机启动
[/usr/local/nginx]# ls /etc/init.d/lvs_nginx
/etc/init.d/lvs_nginx

chkconfig --add lvs_nginx && chkconfig --level 35 lvs_nginx on
```



## 4. 配置LVS服务器


```bash
# lvs01: 218、lvs02: 219两台服务器配置
cd /etc/keepalived && rm -rf /etc/keepalived/* && \cp -ap /shell/keepalived/* /etc/keepalived/
```



---------------------------------------------------------
#### 到此，以下操作将会影响线上服务，可能出现服务停止情况
---------------------------------------------------------



## 5. 重启209网络并测试lvs_nginx，确保通过


```bash
# 测试网络
[/usr/local/nginx]# systemctl restart network
[/usr/local/nginx]# service lvs_nginx status
[/usr/local/nginx]# service lvs_nginx restart && service lvs_nginx status

# 如果失败请回滚：
[/usr/local/nginx]# \cp -ap /etc/sysconfig/network-scripts/ifcfg-eth0.bak /etc/sysconfig/network-scripts/ifcfg-eth0 && systemctl restart network
```



## 6. 登录到生产nginx(207)停止keepalived服务


```bash
systemctl stop keepalived.service
```



## 7. 开启LVS集群服务


```bash
登录到215: 
systemctl restart keepalived.service && systemctl status keepalived.service

登录到217: 
systemctl restart keepalived.service && systemctl status keepalived.service
```



# 如果线上服务不正常，回滚操作


```bash
# 停止LVS服务
登录到215: 
systemctl stop keepalived.service && systemctl status keepalived.service

登录到217: 
systemctl stop keepalived.service && systemctl status keepalived.service

# 启动keepalived服务
登录到207: 
systemctl start keepalived.service 

# 配置208IP地址
登录到209: 
\cp -ap /etc/sysconfig/network-scripts/ifcfg-eth0.bak /etc/sysconfig/network-scripts/ifcfg-eth0 && systemctl restart network
```



## 测试命令


```bash
P='conf.d/real_server/'; for i in `ls $P`;do echo -e "\n$i\n";cat $P/$i;done
P='conf.d/virtual_server/'; for i in `ls $P`;do echo -e "\n$i\n";cat $P/$i;done
netstat -ano | grep ESTABLISHED
```