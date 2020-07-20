#ftp manual
<pre>
[root@smb ftp]# yum install vsftpd -y
ftp常用选项：
anonymous_enable=NO  #禁用匿名用户登录
local_enable=YES  #本地用户开启登录
write_enable=YES  #开启写入权限
local_umask=022  #新建文件目录默认权限
listen=YES  #开启21端口监听以独立服务运行，而不使用xinetd服务
pam_service_name=vsftpd #指定/etc/pam.d/vsftpd文件进行权限管理
userlist_enable=YES  #是否开启用户列表控制文件
userlist_deny=NO  #是否禁止用户列表的用户登录，为NO表示不禁止而允许列表用户登录
dirmessage_enable=YES 激活目录信息,当远程用户更改目录时,将出现提示信息
tcp_wrappers=YES   #使用tcp_wrqppers作为主机访问控制方式
no_anon_password=NO  #启用后，这会阻止vsftpd请求匿名密码 - 匿名用户将直接登录。
ftp_username=ftp  #这是我们用于处理匿名FTP的用户的名称。该用户的主目录是匿名FTP区域的根目录。默认值：ftp
local_root=/ftp  #此选项表示vsftpd在本地（即非匿名）登录后尝试更改的目录。失败被默默地忽略了。和chroot_local_user选项只能选其一
chroot_local_user=YES   #固定本地用户的根,和local_root选项只能选其一
chroot_list_enable=YES   #固定用户列表文件是否开启，如果希望用户登录后不能切换到自己目录以外的其它目录,需要设置该项,如果设置chroot_list_enable=YES,那么只允许/etc/vsftpd.chroot_list中列出的用户具有该功能.如果希望所有的本地用户都执行者chroot,可以增加一行:chroot_local_user=YES
chroot_list_file=/etc/vsftpd/chroot_list   #固定列表文件路径

from:http://vsftpd.beasts.org/vsftpd_conf.html

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
1.ftp服务全部部署完成后，iptables防火墙只开启21端口时，只能是局域网的用户才能正常访问，如果映射公网地址时，则iptables防火墙还必须放开4096:65535的端口才行，这样才能使公网正常访问，否则公网无法访问。
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
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES
listen=YES
listen_ipv6=NO
local_root=/ftp
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd/chroot_list
pam_service_name=vsftpd
userlist_enable=YES
userlist_deny=NO
tcp_wrappers=YES
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
# vsftpd userlist
# If userlist_deny=NO, only allow users in this file
# If userlist_deny=YES (default), never allow users in this file, and
# do not even prompt for a password.
# Note that the default vsftpd pam config also checks /etc/vsftpd/ftpusers
# for users that are denied.
ftpuser1
ftpuser2
#哪些用户固定到根目录并且不能去根以外的目录
[root@node1 /etc/vsftpd]# cat chroot_list 
ftpuser1

</pre>
