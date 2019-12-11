#ftp manual
<pre>
[root@smb ftp]# yum install vsftpd -y
ftp常用选项：
anonymous_enable=NO  #禁用匿名用户登录
local_enable=YES  #本在用户开启登录
write_enable=YES  #开启写入权限
local_umask=022  #新建文件目录默认权限
listen=YES  #开启21端口监听以独立服务运行，而不使用xinetd服务
pam_service_name=vsftpd
userlist_enable=YES  #用户列表文件开启
userlist_deny=NO  #是否禁止用户列表的用户登录，为NO不禁止只允许列表用户登录
tcp_wrappers=YES   #
no_anon_password=NO  #启用后，这会阻止vsftpd请求匿名密码 - 匿名用户将直接登录。
ftp_username=ftp  #这是我们用于处理匿名FTP的用户的名称。该用户的主目录是匿名FTP区域的根目录。默认值：ftp
local_root=/ftp  #此选项表示vsftpd在本地（即非匿名）登录后尝试更改的目录。失败被默默地忽略了。和chroot_local_user选项只能选其一
chroot_local_user=YES   #固定本地用户的根,和local_root选项只能选其一
chroot_list_enable=YES   #固定用户列表文件开启
chroot_list_file=/etc/vsftpd/chroot_list   #固定列表文件路径

from:http://vsftpd.beasts.org/vsftpd_conf.html

[root@smb ftp]# cat /etc/vsftpd/ftpusers #这个目录中的用户将都会被拒绝登录
[root@smb ftp]# cat /etc/vsftpd/user_list  #如果userlist_deny=NO，则只允许列表用户登录，否则不允许列表用户登录
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
