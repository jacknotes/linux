#Ubuntu
<pre>
#网络和DNS配置
jack@ubuntu:/etc/apt$ uname -a 
Linux ubuntu 5.4.0-80-generic #90-Ubuntu SMP Fri Jul 9 22:49:44 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux
jack@ubuntu:/etc/apt$ cat /etc/issue
Ubuntu 20.04.2 LTS \n \l

#ubuntu网络
从ubuntu17.10开始，网络默认由netplan进行管理，yaml格式，文档见/usr/share/doc/netplan/netplan.html
配置好/etc/netplan/00-installer-config.yaml后执行sudo netplan apply 进行应用，实际操作的是由systemd-networkd.service和systemd-resolved.service进行管理，此两个服务也必须开机自启才行，也可以由NetworkManager.service这一个服务统一管理。
默认不自带NetworkManager，需要先安装sudo apt install -y network-manager
#--网络更换方式
[jack@ubuntu:~]$ sudo systemctl stop systemd-networkd
[jack@ubuntu:~]$ sudo systemctl disable systemd-networkd
[jack@ubuntu:~]$ vim /etc/netplan/00-installer-config.yaml
  renderer: NetworkManager   --更换纳管方式为NetworkManager 
[jack@ubuntu:~]$ /etc/apt$ sudo netplan apply 
#--DNS更换方式
[jack@ubuntu:~]$ sudo systemctl stop systemd-resolved
[jack@ubuntu:~]$ sudo systemctl disable systemd-resolved
[jack@ubuntu:~]$ sudo cat /etc/NetworkManager/NetworkManager.conf 
[main]
dns=default   --在main下面增加此行
[jack@ubuntu:~]$ sudo mv /etc/resolv.conf /tmp/
[jack@ubuntu:~]$ sudo systemctl restart NetworkManager
[jack@ubuntu:~]$ sudo cat /etc/resolv.conf 
# Generated by NetworkManager
search hs.com
nameserver 192.168.10.250
nameserver 192.168.10.110
[jack@ubuntu:~]$ sudo systemctl enable NetworkManager
注：以上实行更换网络和DNS配置，从而实现了使用NetworkManager一个服务进行管理ubuntu网络

#netplan配置例子：
jack@ubuntu:/etc/apt$ sudo cat /etc/netplan/00-installer-config.yaml 
---
# This is the network config written by 'subiquity'
network:
  version: 2
  renderer: NetworkManager   #或者renderer: networkd，默认为networkd，需要事先安装NetworkManager
  ethernets:
    ens33:
      dhcp4: false
      optional: true    #如果一个设备被标记为可选，networkd 将不会等待它。这个只有networkd支持，默认是false
      addresses:
      - 172.168.2.224/24
      gateway4: 172.168.2.254
      nameservers:
        search: 
        - hs.com
        addresses:
        - 192.168.10.250
        - 192.168.10.110
      routes:   #--设置路由
      - to: 0.0.0.0/0
        via: 10.0.0.1
        metric: 100
      - to: 0.0.0.0/0
        via: 11.0.0.1
        metric: 100
-----生产配置--------
[jack@ubuntu:~]$ cat /etc/netplan/00-installer-config.yaml 
# This is the network config written by 'subiquity'
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: false
      addresses:
      - 172.168.2.224/24
      gateway4: 172.168.2.254
      nameservers:
        search: 
        - hs.com
        addresses:
        - 192.168.10.250
        - 192.168.10.110
---
jack@ubuntu:/etc/apt$ sudo netplan apply 
[jack@ubuntu:~]$ sudo resolvectl status ens33   --此命令依赖systemd-resolved.service服务
Link 2 (ens33)
      Current Scopes: DNS           
DefaultRoute setting: yes           
       LLMNR setting: yes           
MulticastDNS setting: no            
  DNSOverTLS setting: no            
      DNSSEC setting: no            
    DNSSEC supported: no            
  Current DNS Server: 192.168.10.250
         DNS Servers: 192.168.10.250
                      192.168.10.110
          DNS Domain: hs.com        



#apt源设置
jack@ubuntu:/etc/apt$ sudo cat /etc/apt/sources.list
---
deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
---
#更新apt源
jack@ubuntu:/etc/apt$ sudo apt update
#更新apt已安装的包
jack@ubuntu:/etc/apt$ sudo apt upgrade

#dpkg命令
sudo dpkg -i    等于     sudo rpm -i 
sudo dpkg -r    等于     sudo rpm -e		卸载
sudo dpkg -P    等于     sudo rpm -e		卸载并删除配置文件
sudo dpkg -s openssh-server    等于     rpm -q --info openssh-server
sudo dpkg -L openssh-server    等于     sudo rpm -ql openssh-server
sudo dpkg -l    等于     sudo rpm -qa 
sudo dpkg -S /usr/sbin/sshd 或者 dpkg -S netstat   等于     sudo rpm -qf /usr/sbin/sshd 

#apt命令
sudo apt search net-tools	等于		sudo yum search net-tools
sudo apt list | grep openssh	等于		sudo yum list net-tools, sudo yum list | grep net-tools
sudo apt show net-tools		等于		sudo yum info net-tools
sudo apt install net-tools 	等于		sudo yum install net-tools -y
sudo apt remove --purge net-tools 	等于		sudo yum remove net-tools -y  卸载并删除配置文件
sudo apt update		等于		sudo yum mamkecache fast    更新包信息
sudo apt upgrade net-tools	等于	sudo yum update net-tools
sudo apt-get dist-upgrade  等于	sudo yum update   升级系统
sudo apt-get clean && sudo apt-get autoclean 清理无用的包  |   sudo yum clean all   清理缓存 
sudo apt-get source net-tools   下载原代码包
sudo apt-get check 检查是否有损坏的依赖
#安装apt相关命令apt-file
sudo apt install apt-file -y
sudo apt-file update   --更新apt-file命令所需的信息
sudo apt-file search /bin/netstat   --查看此文件属于哪个软件包
#apt-cache 
sudo apt-cache madison kubectl   --查看包历史版本
sudo apt install kubectl=1.19.10-00  --安装指定版本包

#--apt update报证书问题解决办法
问题：
jack@ubuntu:/tmp/test$ sudo apt update 
  The following signatures couldn't be verified because the public key is not available: NO_PUBKEY FEEA9169307EA071 NO_PUBKEY 8B57C5C2836F4BEB
解决：
jack@ubuntu:/tmp/test$ sudo gpg --keyserver keyserver.ubuntu.com --recv 8B57C5C2836F4BEB
jack@ubuntu:/tmp/test$ sudo gpg --export --armor 8B57C5C2836F4BEB | sudo apt-key add -
其余相关命令：
--查看gpg key
sudo gpg -k 
--删除gpg key，指定gpg key ID
sudo gpg --delete-keys 59FE0256827269DC81578F928B57C5C2836F4BEB
--列出apt-key列表
sudo apt-key list
--删除apt-key 
sudo apt-key del 59FE0256827269DC81578F928B57C5C2836F4BEB

#关闭ubuntu防火墙
[jack@ubuntu ~]$sudo systemctl stop ufw
[jack@ubuntu ~]$sudo systemctl disable ufw


#常用命令工具安装
--安装 apt 依赖包，用于通过HTTPS来获取仓库，也是必要程序包:
[jack@ubuntu ~]$sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
[jack@ubuntu ~]$which -a vim 
/usr/bin/vim
/bin/vim
[jack@ubuntu ~]$sudo apt-file search /bin/vim                 
vim: /usr/bin/vim.basic
--工具名称
vim: vim
net-tools: netstat,route
iproute2: ip,ss
netcat-openbsd: nc
nmap: nmap
glances: glances
axel: axel
lsof: lsof
ifstat: ifstat
tree: tree 
unzip: unzip
--安装常用命令
sudo apt install -y vim net-tools iproute2 netcat-openbsd nmap glances axel tree unzip 
--chrony是时间服务程序，有Daemon
sudo apt install -y chrony   

#设置ubuntu默认编辑器
1. 查看所有对象，每个对象对应一个快捷方式
[jack@ubuntu:~]$ ls /etc/alternatives/
aclocal            ebtables-restore  fakeroot.fr.1.gz                 lzcmp         nawk.1.gz      rlogin.1.gz       view.da.1.gz
aclocal.1.gz       ebtables-save     fakeroot.sv.1.gz                 lzcmp.1.gz    nc             rmt               view.de.1.gz
arptables          editor            from                             lzdiff        nc.1.gz        rmt.8.gz          view.fr.1.gz
arptables-restore  editor.1.gz       from.1.gz                        lzdiff.1.gz   netcat         rsh               view.it.1.gz
arptables-save     ex                ftp                              lzegrep       netcat.1.gz    rsh.1.gz          view.ja.1.gz
automake           ex.1.gz           ftp.1.gz                         lzegrep.1.gz  netrc.5.gz     rview             view.pl.1.gz
automake.1.gz      ex.da.1.gz        futurize                         lzfgrep       newt-palette   rvim              view.ru.1.gz
awk                ex.de.1.gz        infobrowser                      lzfgrep.1.gz  pager          telnet            vi.fr.1.gz
awk.1.gz           ex.fr.1.gz        infobrowser.1.gz                 lzgrep        pager.1.gz     telnet.1.gz       vi.it.1.gz
builtins.7.gz      ex.it.1.gz        ip6tables                        lzgrep.1.gz   pasteurize     text.plymouth     vi.ja.1.gz
c++                ex.ja.1.gz        ip6tables-restore                lzless        pftp           traceroute6       vim
c++.1.gz           ex.pl.1.gz        ip6tables-save                   lzless.1.gz   pftp.1.gz      traceroute6.8.gz  vimdiff
c89                ex.ru.1.gz        iptables                         lzma          pico           unlzma            vi.pl.1.gz
c89.1.gz           faked.1.gz        iptables-restore                 lzma.1.gz     pico.1.gz      unlzma.1.gz       vi.ru.1.gz
c99                faked.es.1.gz     iptables-save                    lzmore        pinentry       vi                vtrgb
c99.1.gz           faked.fr.1.gz     jsondiff                         lzmore.1.gz   pinentry.1.gz  vi.1.gz           w
cc                 faked.sv.1.gz     libblas.so.3-x86_64-linux-gnu    mt            rcp            vi.da.1.gz        w.1.gz
cc.1.gz            fakeroot          liblapack.so.3-x86_64-linux-gnu  mt.1.gz       rcp.1.gz       vi.de.1.gz        write
cpp                fakeroot.1.gz     lzcat                            my.cnf        README         view              write.1.gz
ebtables           fakeroot.es.1.gz  lzcat.1.gz                       nawk          rlogin         view.1.gz         wsdump
2. 例如editor的默认方式是nano
[jack@ubuntu:~]$ ls -ld /etc/alternatives/editor
lrwxrwxrwx 1 root root 9 Feb  1 17:26 /etc/alternatives/editor -> /bin/nano
3. 列出editor有哪些打开方式
[jack@ubuntu:~]$ sudo update-alternatives --list editor
/bin/ed
/bin/nano
/usr/bin/vim.basic
/usr/bin/vim.tiny
4. 更改默认方式
[jack@ubuntu:~]$ sudo update-alternatives --config editor 
There are 4 choices for the alternative editor (providing /usr/bin/editor).

  Selection    Path                Priority   Status
------------------------------------------------------------
* 0            /bin/nano            40        auto mode
  1            /bin/ed             -100       manual mode
  2            /bin/nano            40        manual mode
  3            /usr/bin/vim.basic   30        manual mode
  4            /usr/bin/vim.tiny    15        manual mode

Press <enter> to keep the current choice[*], or type selection number: 3
update-alternatives: using /usr/bin/vim.basic to provide /usr/bin/editor (editor) in manual mode
5. 安装快捷方式
sudo update-alternatives --install /etc/alternatives/editor editor /usr/bin/vim-4.6 20
sudo update-alternatives --install /etc/alternatives/editor editor /usr/bin/vim-4.8 50

#ubuntu20.04.2没有/var/log/messages文件
[jack@ubuntu:/usr/local/nginx/html]$ sudo vim /etc/rsyslog.d/50-default.conf
*.info;mail.none;authpriv.none;cron.none        /var/log/messages
[jack@ubuntu:/usr/local/nginx/html]$ sudo systemctl restart rsyslog
[jack@ubuntu:/usr/local/nginx/html]$ sudo ls /var/log/messages
/var/log/messages
注：/etc/rsyslog.d管理的自己会自动日志切割



#ubuntu20.04.2开机启动脚本
1. 查看
[jack@ubuntu ~]$sudo cat /usr/lib/systemd/system/rc-local.service
---
[Unit]
Description=/etc/rc.local Compatibility
Documentation=man:systemd-rc-local-generator(8)
ConditionFileIsExecutable=/etc/rc.local
After=network.target

[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
RemainAfterExit=yes
GuessMainPID=no
---
一般正常的启动文件主要分成三部分
[Unit] 段: 启动顺序与依赖关系
[Service] 段: 启动行为,如何启动，启动类型
[Install] 段: 定义如何安装这个配置文件，即怎样做到开机启动
可以看出，/etc/rc.local 的启动顺序是在网络后面，但是显然它少了 Install 段，也就没有定义如何做到开机启动，所以显然这样配置是无效的。 因此我们就需要在后面帮他加上 [Install] 段:
[Install]  
WantedBy=multi-user.target  
Alias=rc-local.service
[jack@ubuntu ~]$sudo systemctl daemon-reload 
自ubuntu-18.04以后 默认是没有 /etc/rc.local 这个文件的，需要自己创建
[jack@ubuntu ~]$sudo touch /etc/rc.local 
[jack@ubuntu ~]$sudo chmod +x /etc/rc.local
[jack@ubuntu ~]$cat /etc/rc.local
---
#!/bin/sh
echo "看到这行字，说明添加自启动脚本成功。" > /usr/local/test.log
exit 0
---
[jack@ubuntu ~]$sudo systemctl start rc-local
[jack@ubuntu ~]$sudo systemctl status rc-local
sudo init 6
[jack@ubuntu:~]$ cat /usr/local/test.log 
看到这行字，说明添加自启动脚本成功。


#编译安装nginx
1. 安装编译需要用到的库和工具
[jack@ubuntu:/download]$ sudo apt-get install -y build-essential libtool gcc automake autoconf make gcc g++
2. 下载tengine和pcre,和第三方的替换模块：ngx_http_substitutions_filter_module
[jack@ubuntu:~]$ sudo mkdir -p /download
[jack@ubuntu:~]$ cd /download/
[jack@ubuntu:/download]$ sudo curl -OL http://tengine.taobao.org/download/tengine-2.3.2.tar.gz
[jack@ubuntu:/download]$ sudo curl -OL http://ftp.pcre.org/pub/pcre/pcre-8.44.tar.gz
[jack@ubuntu:/download]$ sudo curl -OL https://codeload.github.com/yaoweibin/ngx_http_substitutions_filter_module/zip/master
[jack@ubuntu:/download]$ sudo unzip master
[jack@ubuntu:/download]$ ls
master  ngx_http_substitutions_filter_module-master  pcre-8.44.tar.gz  tengine-2.3.2.tar.gz
3. 配置pcre和安装tengine
[jack@ubuntu:/download]$ sudo tar xfv pcre-8.44.tar.gz -C /usr/local/
[jack@ubuntu:/download]$ ls -ld /usr/local/pcre*
drwxr-xr-x 7 1169 1169 4096 Feb 12  2020 /usr/local/pcre-8.44
--安装依赖软件
[jack@ubuntu:/download]$ sudo apt install -y openssl libssl-dev libpcre3 libpcre3-dev zlib1g-dev
--编译安装tengine 
[jack@ubuntu:/download]$ sudo tar xvf tengine-2.3.2.tar.gz 
[jack@ubuntu:/download]$ cd tengine-2.3.2/
[jack@ubuntu:/download/tengine-2.3.2]$ sudo groupadd -r tengine
[jack@ubuntu:/download/tengine-2.3.2]$ sudo useradd -r -s /sbin/nologin -M -g tengine tengine
[jack@ubuntu:/download/tengine-2.3.2]$ sudo ./configure --prefix=/usr/local/nginx --sbin-path=/usr/local/nginx/sbin/nginx --conf-path=/usr/local/nginx/conf/nginx.conf --error-log-path=/usr/local/nginx/logs/error.log --http-log-path=/usr/local/nginx/logs/access.log --user=tengine --group=tengine --with-pcre=/usr/local/pcre-8.44 --with-http_ssl_module --with-http_flv_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_sub_module --with-stream --add-module=modules/ngx_http_upstream_session_sticky_module --add-module=/download/ngx_http_substitutions_filter_module-master --with-stream_ssl_module --add-module=modules/ngx_http_upstream_check_module --with-http_auth_request_module --with-http_gzip_static_module --with-http_random_index_module --with-http_sub_module
[jack@ubuntu:/download/tengine-2.3.2]$ sudo make -j 4 && sudo make install && echo $?
[jack@ubuntu:/download/tengine-2.3.2]$ /usr/local/nginx/sbin/nginx -V
Tengine version: Tengine/2.3.2
nginx version: nginx/1.17.3
built by gcc 9.3.0 (Ubuntu 9.3.0-17ubuntu1~20.04) 
built with OpenSSL 1.1.1f  31 Mar 2020
TLS SNI support enabled
configure arguments: --prefix=/usr/local/nginx --sbin-path=/usr/local/nginx/sbin/nginx --conf-path=/usr/local/nginx/conf/nginx.conf --error-log-path=/usr/local/nginx/logs/error.log --http-log-path=/usr/local/nginx/logs/access.log --user=tengine --group=tengine --with-pcre=/usr/local/pcre-8.44 --with-http_ssl_module --with-http_flv_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_sub_module --with-stream --add-module=modules/ngx_http_upstream_session_sticky_module --add-module=/download/ngx_http_substitutions_filter_module-master --with-stream_ssl_module --add-module=modules/ngx_http_upstream_check_module --with-http_auth_request_module --with-http_gzip_static_module --with-http_random_index_module --with-http_sub_module
--配置tengine启动脚本
[jack@ubuntu:/download/tengine-2.3.2]$ sudo vim /usr/lib/systemd/system/tengine.service
---
[Unit]
Description=nginx - high performance web server
After=network.target remote-fs.target nss-lookup.target
[Service]
Type=forking
ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s stop
[Install]
WantedBy=multi-user.target
---
[jack@ubuntu:/download/tengine-2.3.2]$ sudo systemctl daemon-reload 
[jack@ubuntu:/download/tengine-2.3.2]$ sudo systemctl start tengine
[jack@ubuntu:/download/tengine-2.3.2]$ sudo systemctl status tengine


#docker部署
# step 1: 安装必要的一些系统工具
sudo apt-get update
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
# step 2: 安装GPG证书
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
# Step 3: 写入软件源信息
sudo add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
# Step 4: 更新并安装Docker-CE
sudo apt-get -y update
sudo apt-get -y install docker-ce

# 安装指定版本的Docker-CE:
# Step 1: 查找Docker-CE的版本:
# apt-cache madison docker-ce
#   docker-ce | 17.03.1~ce-0~ubuntu-xenial | https://mirrors.aliyun.com/docker-ce/linux/ubuntu xenial/stable amd64 Packages
#   docker-ce | 17.03.0~ce-0~ubuntu-xenial | https://mirrors.aliyun.com/docker-ce/linux/ubuntu xenial/stable amd64 Packages
# Step 2: 安装指定版本的Docker-CE: (VERSION例如上面的17.03.1~ce-0~ubuntu-xenial)
# sudo apt-get -y install docker-ce=[VERSION]


</pre>