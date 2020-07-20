#ftp manual
<pre>
ftp有三种用户：
	1. 匿名用户
	2. 系统用户
	3. 虚拟用户(通过跟mysql进行结合，用mysql来建立用户，必须编译安装才行)
客户端软件：flashfxp

ftp常用选项：
anonymous_enable=NO  #是否禁用匿名用户登录,默认匿名用户名叫anonymous
ftp_username=ftp  #这是我们用于处理匿名FTP的用户的名称。该用户的主目录是匿名FTP区域的根目录。默认值：ftp
no_anon_password=NO  #启用后，这会阻止vsftpd请求匿名密码 - 匿名用户将直接登录。
anon_upload_enable=NO #是否开启匿名用户上传
anno_mkdir_write_enable=NO #是否开启匿名用户写入
anno_other_write_enable=NO #是否开启匿名用户其它权限，例如删除文件
chown_uploads=NO #如果启用，所有匿名上传的文件的所有者都将更改为设置chown_username中指定的用户
chown_username=whoever #指定匿名用户上传所有权的用户名
local_enable=YES  #是否开启本地用户登录
write_enable=YES  #是否开启写入权限
local_umask=022  #新建文件/目录默认权限
listen=YES  #开启21端口监听以独立服务运行，而不使用xinetd服务
connect_from_port_20=YES  #是否允许服务器主动模式（从20端口建立数据连接）
pasv_enable=YES     #是否允许服务器被动模式
pasv_max_port=24600 #设置被动模式服务器的最大端口号
pasv_min_port=24500 #设置被动模式服务器的最小端口号
pam_service_name=vsftpd #指定/etc/pam.d/vsftpd文件进行权限管理
userlist_enable=YES  #是否开启用户列表控制文件
userlist_deny=NO  #当开启了用户列表控制文件后，是否禁止用户列表的用户登录，为NO表示不禁止而允许列表用户登录
xferlog_enable=YES #是否开启ftp传输日志
xferlog_file=/var/log/vsftpd.log #指定日志文件路径
xferlog_std_format=YES #是事采取标准日志格式
tcp_wrappers=YES   #是否将传入连接通过tcp_wrappers访问控制提供
local_root=/ftp  #此选项表示vsftpd在本地（即非匿名）登录后尝试更改的目录。失败被默默地忽略了。
chroot_local_user=YES   #固定所有本地用户的根，后面就可以不用再定义固定用户列表文件了
chroot_list_enable=YES   #固定用户列表文件是否开启
chroot_list_file=/etc/vsftpd/chroot_list   #固定列表文件路径
local_max_rate=0    #限制最大传输速率（字节/秒）0为无限制
max_clients=0  #最大客户端连接数，默认是0不限制
max_per_ip=0  #对于同一个ip来说最多可以发起多少个请求的，默认是0不限制
dirmessage_enable=NO #如果启用该功能，那么FTP服务器的用户在第一次进入新目录时就可以看到消息。默认情况下，会扫描目录以查找.message文件
message_file=.message #这个选项是我们在进入新目录时要查找的文件的名称。内容将显示给远程用户。此选项仅在启用dirmessage_enable选项时才有用。

[root@smb ftp]# yum install vsftpd -y
[root@smb ftp]# cat /etc/vsftpd/ftpusers #这个目录中的用户将都会被拒绝登录，ftpusers不受任何配制项的影响，它总是有效，它是一个黑名单！
[root@smb ftp]# cat /etc/vsftpd/user_list  #如果userlist_deny=NO，则只允许列表用户登录，否则不允许列表用户登录。而user_list则是和vsftpd.conf中的userlist_enable和userlist_deny两个配置项紧密相关的，它可以有效，也可以无效，有效时它可以是一个黑名单，也可以是一个白名单！
[root@smb ftp]# vim /etc/pam.d/vsftpd  #这个文件是配置/etc/vsftpd/ftpusers这个目录的
Centos6 ftp配置：
-------------------------------
[root@smb ftp]# cat /etc/vsftpd/vsftpd.conf | grep -v '^#'
anonymous_enable=NO
local_enable=YES
local_root=/ftp
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd/chroot_list
listen=YES
pam_service_name=vsftpd
userlist_enable=YES
userlist_deny=NO
tcp_wrappers=YES
-------------------------------
[root@smb ftp]# cat /etc/vsftpd/ftpusers
# Users that are not allowed to login via ftp
root
bin
daemon
adm
lp
sync
shutdown
halt
mail
news
uucp
operator
games
nobody
------------------
[root@smb ftp]# cat /etc/vsftpd/user_list
# vsftpd userlist
# If userlist_deny=NO, only allow users in this file
# If userlist_deny=YES (default), never allow users in this file, and
# do not even prompt for a password.
# Note that the default vsftpd pam config also checks /etc/vsftpd/ftpusers
# for users that are denied.
jackli
test
------------------

注意事项：
1.ftp服务全部部署完成后，iptables防火墙只开启21端口时，只能是局域网的用户才能正常访问，如果映射公网地址时，则iptables防火墙还必须放开4096:65535的端口才行，这样才能使公网正常访问，否则公网无法访问(ftp此时是被动模式，客户端会从ftp控制接口中得知ftp的数据端口是多少,被动模式下ftp的data接口是4096:65535。当ftp是主动模式时，则ftp的data接口是20，此时ftp会主动去连接客户端)。
2.ftp服务在局域网访问时只需要输入ftp://ip:port即可，在公网访问时必须加上访问的用户名，例：ftp://username@ip:port ，如果是匿名用户访问时则可不加用户名。
</pre>

#Centos7
<pre>
#vsftp总配置文件
[root@node1 ~]# grep -Ev '#|^$' /etc/vsftpd/vsftpd.conf 
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
message_file=.message
connect_from_port_20=YES
listen=YES
local_root=/ftp
chroot_local_user=YES
#chroot_list_enable=YES
#chroot_list_file=/etc/vsftpd/chroot_list
pam_service_name=vsftpd
userlist_enable=YES
userlist_deny=NO
tcp_wrappers=YES
xferlog_enable=YES
xferlog_file=/var/log/vsftpd.log
xferlog_std_format=YES
local_max_rate=0
max_clients=0  
max_per_ip=0  
#pam模块管理ftp用户权限文件
[root@node1 /etc/vsftpd]# cat /etc/pam.d/vsftpd 
#%PAM-1.0
session    optional     pam_keyinit.so    force revoke
auth       required	pam_listfile.so item=user sense=deny file=/etc/vsftpd/ftpusers onerr=succeed
auth       required	pam_shells.so
auth       include	password-auth
account    include	password-auth
session    required     pam_loginuid.so
session    include	password-auth
#pam模板拒绝的文件用户
[root@node1 /etc/vsftpd]# cat ftpusers 
# Users that are not allowed to login via ftp
root
bin
daemon
adm
lp
sync
shutdown
halt
mail
news
uucp
operator
games
nobody
#vsftp配置文件中指定哪些用户列表可以登录ftp
[root@node1 /etc/vsftpd]# cat user_list 
ftpuser1
ftpuser2
#哪些用户固定到根目录并且不能去根以外的目录

----加密的ftp-----vsftp要求必须使用rsa格式的证书(用私有CA进行签署证书)
ssl_enable=YES
ssl_tlsv1=YES
ssl_sslv3=YES
allow_anon_ssl=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES
rsa_cert_file=/etc/vsftpd/ssl/vsftpd_cert.pem
rsa_private_key_file=/etc/vsftpd/ssl/vsftpd_key.pem

----配置用户
--使用系统用户建立用户时，用户家目录不能不要，登录shell必须是/bin/bash
[root@node1 /ftp/dev]# setfacl -m g:devgroup:rwx /ftp/ops #设置facl时不使用-d -R则表示设置目标目录权限，使用-d -R表示设置目标目录下面的所有权限
[root@node1 /ftp/dev]# getfacl /ftp/ops
getfacl: Removing leading '/' from absolute path names
# file: ftp/ops
# owner: root
# group: ftpgroup
# flags: -s-
user::rwx
group::rwx
group:devgroup:rwx          #setfacl -m g:devgroup:rwx /ftp/ops
mask::rwx
other::r-x
default:user::rwx
default:group::rwx
default:group:devgroup:rwx  setfacl -d -R -m g:devgroup:rwx /ftp/ops
default:mask::rwx
default:other::r-x




----其它配置文件参考----
#常用的匿名FTP配置项
anonymous_enable=YES                         是否允许匿名用户访问

anon_umask=022                                     匿名用户所上传文件的权限掩码

anon_root=/var/ftp                                    设置匿名用户的FTP根目录

anon_upload_enable=YES                      是否允许匿名用户上传文件

anon_mkdir_write_enable=YES               是否允许匿名用户允许创建目录

anon_other_write_enable=YES               是否允许匿名用户有其他写入权（改名，删除，覆盖）

anon_max_rate=0                                     限制最大传输速率（字节/秒）0为无限制

 

#常用的本地用户FTP配置项
local_enable=YES                                      是否允许本地系统用户访问

local_umask=022                                       本地用户所上传文件的权限掩码

local_root=/var/ftp                                      设置本地用户的FTP根目录

chroot_list_enable=YES                            表示是否开启chroot的环境，默认没有开启

chroot_list_file=/etc/vsftpd/chroot_list        表示写在/etc/vsftpd/chroot_list文件里面的用户是不可以出chroot环境的。默认是可以的。

Chroot_local_user=YES                             表示所有写在/etc/vsftpd/chroot_list文件里面的用户是可以出chroot环境的，和上面的相反。

local_max_rate=0                                       限制最大传输速率（字节/秒）0为无限制

 

#常用的全局配置项
listen=YES                                                  是否以独立运行的方式监听服务

listen_address=192.168.4.1                       设置监听FTP服务的IP地址

listen_port=21                                             设置监听FTP服务的端口号

write_enable=YES                                      是否启用写入权限（上传，删除文件）

download_enable＝YES                             是否允许下载文件

dirmessage_enable=YES                           用户切换进入目录时显示.message文件

xferlog_enable=YES                                   启用日志文件，记录到/var/log/xferlog

xferlog_std_format=YES                             启用标准的xferlog日志格式，禁用此项将使用vsftpd自己的格式

connect_from_port_20=YES                       允许服务器主动模式（从20端口建立数据连接）

pasv_enable=YES                                       允许服务器被动模式

pasv_max_port=24600                                设置被动模式服务器的最大端口号

pasv_min_port=24500                                 设置被动模式服务器的最小端口号

pam_service_name=vsftpd                          用户认证的PAM文件位置

（/etc/pam.d/vsftpd.vu）

userlist_enable=YES                                     是否启用user_list列表文件

userlist_deny=YES                                        是否禁用user_list中的用户

max_clients=0                                                限制并发客户端连接数

max_per_ip=0                                                 限制同一IP地址的并发连接数

tcp_wrappers=YES                                         是否启用tcp_wrappers主机访问控制

chown_username=root                                   表示匿名用户上传的文件的拥有人是root，默认关闭

ascii_upload_enable=YES                              表示是否允许用户可以上传一个二进制文件，默认是不允许的

ascii_download_enable=YES                         这个是代表是否允许用户可以下载一个二进制文件，默认是不允许的

nopriv_user=vsftpd                                          设置支撑Vsftpd服务的宿主用户为手动建立的Vsftpd用户

async_abor_enable=YES                                设定支持异步传输功能

ftpd_banner=Welcome to Awei FTP servers   设定Vsftpd的登陆标语

guest_enable=YES　　　　　　　　　　　  设置启用虚拟用户功能

guest_username=ftpuser　　　　　　　　　指定虚拟用户的宿主用户

virtual_use_local_privs=YES　　　　　　　 设定虚拟用户的权限符合他们的宿主用户

user_config_dir=/etc/vsftpd/vconf　　　　　 设定虚拟用户个人Vsftp的配置文件存放路径




</pre>
