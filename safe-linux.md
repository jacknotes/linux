-------------------------------------------------------------------------------------
安装ClamAv
-------------------------------------------------------------------------------------
1. 安装
yum -y install epel-release
yum install –y clamav clamav-update

2. //更新
freshclam

mkdir /opt/infected

crontab -e
1 4 * * * /usr/bin/freshclam --quiet
1 5 * * * /usr/bin/clamscan -r -i /  --move=/opt/infected  -l /var/log/clamscan.log
//验证方法
/usr/bin/clamscan -r  /tmp  --move=/opt/infected  -l /var/log/clamscan.log




-------------------------------------------------------------------------------------
安装deny host软件
-------------------------------------------------------------------------------------
1下载
wget http://jaist.dl.sourceforge.net/project/denyhosts/denyhosts/2.6/DenyHosts-2.6.tar.gz
2解压
tar -zxvf DenyHosts-2.6.tar.gz -C /usr/local/
3进入解压文件夹
cd /usr/local/DenyHosts-2.6
4安装python环境
yum install -y python
5开始编译安装setup.py
python setup.py install
6编辑配置文件
cd /usr/share/denyhosts/
cp denyhosts.cfg-dist denyhosts.cfg
cp daemon-control-dist daemon-control
vim denyhosts.cfg
7启动denyhosts并且设置为开机自启动
cd /etc/rc.d/init.d/
ln -s /usr/share/denyhosts/daemon-control denyhosts
chkconfig --add denyhosts
chkconfig denyhosts on 
chkconfig --list denyhosts
8安装完成

后台启动：
/usr/share/denyhosts/daemon-control start &

添加ip白名单：vi /etc/hosts.allow
sshd:58.33.49.196:allow
sshd:58.33.49.195:allow
sshd:58.33.49.198:allow

tail -f /var/log/secure
tail -f /etc/hosts.deny 

----替换 /usr/share/denyhosts/denyhosts.cfg 

vim /usr/share/denyhosts/denyhosts.cfg 
————————————————
SECURE_LOG = /var/log/secure                  #ssh 日志文件 #redhat系列根据/var/log/secure文件来判断；
                                                           #Mandrake、FreeBSD根据 /var/log/auth.log来判断；
                                                           #SUSE则是用/var/log/messages来判断，这些在配置文件里面都有很详细的解释。
HOSTS_DENY = /etc/hosts.deny                  #控制用户登录的文件
PURGE_DENY = 30m                              #过多久后清除已经禁止的，设置为30分钟；
# ‘m’ = minutes
# ‘h’ = hours
# ‘d’ = days
# ‘w’ = weeks
# ‘y’ = years
BLOCK_SERVICE = sshd                         #禁止的服务名，当然DenyHost不仅仅用于SSH服务
DENY_THRESHOLD_INVALID = 1                   #允许无效用户失败的次数
DENY_THRESHOLD_VALID = 3                     #允许普通用户登陆失败的次数
DENY_THRESHOLD_ROOT = 3                      #允许root登陆失败的次数

DENY_THRESHOLD_RESTRICTED = 1                #设定 deny host 写入到该资料夹  
WORK_DIR = /usr/share/denyhosts/data     #将deny的host或ip记录到work_dir中  
SUSPICIOUS_LOGIN_REPORT_ALLOWED_HOSTS=YES  
HOSTNAME_LOOKUP=YES                         #是否做域名反解  
LOCK_FILE = /var/lock/subsys/denyhosts      #将DenyHost启动的pid记录到LOCK_FILE中，已确保服务正确启动，防止同时启动多个服务

       ############ THESE SETTINGS ARE OPTIONAL ############
ADMIN_EMAIL =                           #管理员邮箱
SMTP_HOST = 
SMTP_PORT = 
SMTP_FROM = 
SMTP_SUBJECT = DenyHosts Report         #邮件主题
AGE_RESET_VALID=5m                      #有效用户登录失败计数归零的时间
AGE_RESET_ROOT=10m                      #root用户登录失败计数归零的时间
AGE_RESET_RESTRICTED=10m                #用户的失败登录计数重置为0的时间(/usr/share/denyhosts/data/restricted-usernames)
AGE_RESET_INVALID=5m                    #无效用户登录失败计数归零的时间


   ######### THESE SETTINGS ARE SPECIFIC TO DAEMON MODE  ##########


DAEMON_LOG = /var/log/denyhosts              #DenyHosts日志文件存放的路径，默认
DAEMON_SLEEP = 30s                           #当以后台方式运行时，每读一次日志文件的时间间隔。
DAEMON_PURGE = 10m                           #当以后台方式运行时，清除机制在 HOSTS_DENY 中终止旧条目的时间间隔,这个会影响PURGE_DENY的间隔。
RESET_ON_SUCCESS = yes                      #如果一个ip登陆成功后，失败的登陆计数是否重置为0

