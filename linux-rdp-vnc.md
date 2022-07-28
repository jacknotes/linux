#Linux远程桌面（RDP和VNC协议）
###Windows：rdp（Remote Desktop Protocal）
###Linux: vnc（virtual network console）

常用国内源：
163镜像源（桌面安装推荐选择163，服务安装推荐选择阿里云）
http://mirrors.163.com/
中国技术科学大学
http://mirrors.ustc.edu.cn/
Centos官方站点
http://vault.centos.org

国内的几个比较大的镜像： 
清华大学镜像：https://mirror.tuna.tsinghua.edu.cn/ 
阿里云镜像：http://mirrors.aliyun.com/ 
网易镜像：http://mirrors.163.com/ 
搜狐镜像：http://mirrors.sohu.com/ 
华中科技大学镜像：http://mirror.hust.edu.cn/ 
兰州大学镜像：http://mirror.lzu.edu.cn/ 
北京交大镜像：http://mirror.bjtu.edu.cn/cn/ 
厦大镜像：http://mirrors.xmu.edu.cn/ 
上海交大镜像：http://ftp.sjtu.edu.cn/ 
中国科技大学镜像：http://mirrors.ustc.edu.cn/ 
ruby淘宝镜像：https://ruby.taobao.org/ 
gem国内镜像：https://ruby.taobao.org/ 
bundle源：https://ruby.taobao.org 

<pre>
#linux rdp客户端
软件：
rdesktop(rdp协议客户端)
grdesktop（rdp协议客户端）,
krdc(支持rcp和vnc两种协议客户端)
安装：krdc:yum install  kdenetwork-krdc -y
linux桌面搜索krdc运行即可

#linux rdp服务端
xrdp:此软件使用的是rdp协议，方便windows访问linux（已经测试）
yum install epel-release
yum install xrdp -y
配置xrdp.ini文件:vim /etc/xrdp/xrdp.ini,把max_bpp=32，改为max_bpp=24
服务启动：systemctl start xrdp&& systemctl enable xrdp
windows远程桌面连接选择Xorg进行连接即可

#linux vnc客户端
vinagre:支持ssh,rdp,vnc三种协议，linux系统自带
remmina:vnc协议客户端,需手动安装
krdc:vnc协议客户端,系统自带
安装：krdc:yum install  kdenetwork-krdc -y
linux桌面搜索krdc运行即可

#linux vnc服务端
tigervnc:vnc协议服务端，需手动安装（已经测试）
1. 安装：yum install tigervnc-server
2. 复制配置文件：cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service
3. 编辑配置文件：vim /etc/systemd/system/vncserver@:1.service
把<USER>替换成你要远程的用户名，这里是root
ExecStart=/usr/sbin/runuser -l root -c "/usr/bin/vncserver %i -geometry 1280x720"
PIDFile=/root/.vnc/%H%i.pid
4. vncpasswd  #设置vnc远程密码
5. 重载配置文件：[root@Linux-node6-slave-mysql ~]# systemctl daemon-reload
6. [root@Linux-node6-slave-mysql system]# systemctl start vncserver@:1
7. [root@Linux-node6-slave-mysql system]# systemctl enable vncserver@:1
8. xvnc服务端口默认为5900，如果使用vncserver@:1则默认端口加1为5091

#x11vnc:vnc协议服务端，需手动安装
启动vnc服务端：x11vnc -password PASSWORD -dikplay :d forever (开启端口默认为5900，forever为始终开启)


#windows vnc软件
ultravnc(免费),tightvnc(免费,推荐),realvnc(收费)
tightvnc（已经测试）:安装好后输入ipaddr:1即可登录，ctrl+alt+shift+f退出全屏，tight也可当做windows端的vnc server


</pre>


# RustDesk中继服务器部署
<pre>

URL: https://rustdesk.com/docs/zh-cn/self-host/install/
URL: https://github.com/rustdesk/rustdesk

### 服务端
[root@BuildImage /data/rustdesk]# cat docker-compose.yml 
version: '3'

networks:
  rustdesk-net:
    external: false

services:
  hbbs:
    container_name: hbbs
    ports:
      - 21115:21115
      - 21116:21116
      - 21116:21116/udp
      - 21118:21118
    image: rustdesk/rustdesk-server:1.1.6
    command: hbbs -r 192.168.13.214:21117
    volumes:
      - ./hbbs:/root
    networks:
      - rustdesk-net
    depends_on:
      - hbbr
    restart: unless-stopped

  hbbr:
    container_name: hbbr
    ports:
      - 21117:21117
      - 21119:21119
    image: rustdesk/rustdesk-server:1.1.6
    command: hbbr
    volumes:
      - ./hbbr:/root
    networks:
      - rustdesk-net
    restart: unless-stopped
	
docker-compose up -d

### 客户端
客户端下载rustdesk-1.1.9-x64.exe，并更名为rustdesk-host=192.168.13.214,key=OzhoV2yYK.exe    
注：
1. host=中继服务器地址，key为中继服务器公钥，这样可免除手动配置。
2.亦或在客户端中配置'ID/中继服务器'，ID服务器：192.168.13.214 中继服务器：192.168.13.214:21116

</pre>