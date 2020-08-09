#Oracle
<pre>
Environment:
[root@node1 ~]# cat /etc/redhat-release 
CentOS Linux release 7.6.1810 (Core) 
[root@node1 /git/linux]# uname -a
Linux node1 3.10.0-957.el7.x86_64 #1 SMP Thu Nov 8 23:39:32 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux

#install
step1:虚拟内存建议，oracle后面需要使用
[root@node1 ~]# dd if=/dev/zero of=/swap bs=1M count=1024
[root@node1 ~]# mkswap /swap 
[root@node1 ~]# chmod 0644 /swap 
[root@node1 ~]# echo /swap /swap swap defaults 0 0 >> /etc/fstab 
[root@node1 ~]# mount -a
[root@node1 ~]# swapon /swap

step2:安装依赖包
[root@node1 ~]# yum install -y binutils compat-libstdc++-33 elfutils-libelf elfutils-libelf-devel elfutils-libelf-devel-static kernel-headers glibc-headers gcc gcc-c++ glibc glibc-devel libaio libaio-devel libgcc libstdc++ libstdc++-devel libXext libXtst libX11 libXau libXi make sysstat unixODBC unixODBC-devel libXp libXp.so.6 libgomp compat-libcap1 ksh

step3:主机名解析
[root@node1 ~]# cat /etc/hosts| grep node1
192.168.220.79 node1

step4:创建相关用户和组
[root@node1 ~]# groupadd oinstall
[root@node1 ~]# groupadd dba
[root@node1 ~]# useradd -g oinstall -G dba -m oracle
[root@node1 ~]# echo 'oracle' | passwd --stdin oracle
Changing password for user oracle.
passwd: all authentication tokens updated successfully.

step5:修改linux内核配置
[root@node1 ~]# grep -v '#' /etc/sysctl.conf #添加配置
fs.file-max = 6815744
fs.aio-max-nr = 1048576
kernel.shmall = 2097152
kernel.shmmax = 2147483648
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 4194304
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
[root@node1 ~]# sysctl -p

step6:修改用户的限制文件
[root@node1 ~]# cat /etc/security/limits.conf | grep -v '#\|^$'
oracle           soft    nproc           2047
oracle           hard    nproc           16384
oracle           soft    nofile          1024
oracle           hard    nofile          65536
oracle           soft    stack           10240

step7:设置用户登录PAM模块相关认证
[root@node1 /download]# vim /etc/pam.d/login #添加两行
session required /lib64/security/pam_limits.so
session required pam_limits.so

step8:修改oracle用户在不同shell下相关限制参数
[root@node1 /download]# cat /etc/profile.d/oracle.sh
if [ $USER = "oracle" ]; then
if [ $SHELL = "/bin/ksh" ]; then
ulimit -p 16384
ulimit -n 65536
else
ulimit -u 16384 -n 65536
fi
fi
[root@node1 /download]# source /etc/profile
 
step9:上传解压oracle文件
[root@node1 /download]# unzip linux.x64_11gR2_database_1of2.zip
[root@node1 /download]# unzip linux.x64_11gR2_database_2of2.zip
[root@node1 /download]# ls database/
doc  install  response  rpm  runInstaller  sshsetup  stage  welcome.html

step10:创建oracle相关目录其权限
[root@node1 /download]# mkdir /usr/local/oracle/oracle -p #oracle是数据库系统安装目录
[root@node1 /download]# mkdir /usr/local/oracle/oradata -p #，oradata是数据库数据安装目录
[root@node1 /download]# mkdir /usr/local/oracle/oradata_back -p #oradata_back是数据备份目录
[root@node1 /download]# mkdir /usr/local/oracle/oraInventory -p #oraInventory是清单目录
[root@node1 /download]# chown -R oracle:oinstall /usr/local/oracle/oracle /usr/local/oracle/oraInventory /usr/local/oracle/oradata/
[root@node1 /download]# chmod -R 775 /usr/local/oracle/oracle /usr/local/oracle/oraInventory /usr/local/oracle/oradata/

step11:设置oracle登录后环境变量设置
[root@node1 /download]# su - oracle
[oracle@node1 ~]$ vim .bash_profile 
export ORACLE_BASE=/usr/local/oracle/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
export ORACLE_SID=orcl
export PATH=$PATH:$ORACLE_HOME/bin:$HOME/bin
[oracle@node1 ~]$ . .bash_profile

step12:配置oracle静默安装响应文件
[root@node1 ~]# vim /download/database/response/db_install.rsp
oracle.install.option=INSTALL_DB_SWONLY #29行，#安装类型,只装数据库软件
ORACLE_HOSTNAME=node1 #37行,主机名称
UNIX_GROUP_NAME=oinstall #42行,安装组
INVENTORY_LOCATION=/usr/local/oracle/oraInventory #47行,NVENTORY目录（不填就是默认值,本例此处需修改,因个人创建安装目录而定）
SELECTED_LANGUAGES=en,zh_CN #78行，选择语言
ORACLE_HOME=/usr/local/oracle/oracle/product/11.2.0/db_1 #83行,安装路径
ORACLE_BASE=/usr/local/oracle/oracle #88行，oracle安装根路径
racle.install.db.InstallEdition=EE #99行，oracle安装版本
oracle.install.db.isCustomInstall=false #108行，是否手动指定企业安装组件
oracle.install.db.DBA_GROUP=dba #142行，设定用户组
oracle.install.db.OPER_GROUP=dba #147行，设定用户组
oracle.install.db.config.starterdb.type=GENERAL_PURPOSE #160行，数据库类型，选择数据库的用途，一般用途/事物处理，数据仓库
oracle.install.db.config.starterdb.globalDBName=orcl #165行，全局数据库名称
oracle.install.db.config.starterdb.SID=orcl #170行，SID（**此处注意与环境变量内配置SID一致）
oracle.install.db.config.starterdb.characterSet=AL32UTF8 #184，指定字符集
oracle.install.db.config.starterdb.memoryOption=true #192行，11g的新特性自动内存管理，也就是SGA_TARGET和PAG_AGGREGATE_TARGET，
oracle.install.db.config.starterdb.memoryLimit=1024 #200行，指定Oracle自动管理内存的大小，最少256M
oracle.install.db.config.starterdb.password.ALL=oracle #233行，设定所有数据库用户的密码
oracle.install.db.config.starterdb.password.SYS=password #238行,设定sys用户密码
oracle.install.db.config.starterdb.password.SYSTEM=password #243行，设定system用户密码
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false #376行，用户是否可以设置metalink密码
DECLINE_SECURITY_UPDATES=true #385行，注意此参数 设定一定要为true，是否设置安全更新

step13:根据响应文件安装oracle
[root@node1 ~]# su - oracle 
[oracle@node1 ~]$ /download/database/runInstaller -silent -ignorePrereq -ignoreSysPrereqs -responseFile /download/database/response/db_install.rsp 
/download/database/runInstaller 是主要安装脚本
-silent 静默模式 　　
-force 强制安装 　　
-ignorePrereq忽略warning直接安装。 　　
-responseFile读取安装应答文件
[oracle@node1 ~]$ The following configuration scripts need to be executed as the "root" user. #当你执行完上面命令后，不会立马返回这个成功的信息，你需要等待成功信息出现，视机器性能而定。
 #!/bin/sh 
 #Root scripts to run

/usr/local/oracle/oraInventory/orainstRoot.sh
/usr/local/oracle/oracle/product/11.2.0/db_1/root.sh
To execute the configuration scripts:
	 1. Open a terminal window 
	 2. Log in as "root" 
	 3. Run the scripts 
	 4. Return to this window and hit "Enter" key to continue 

Successfully Setup Software.
#成功提示你使用root进行执行两个脚本
[root@node1 /download/database/response]# /usr/local/oracle/oraInventory/orainstRoot.sh
Changing permissions of /usr/local/oracle/oraInventory.
Adding read,write permissions for group.
Removing read,write,execute permissions for world.

Changing groupname of /usr/local/oracle/oraInventory to oinstall.
The execution of the script is complete.
[root@node1 /download/database/response]# /usr/local/oracle/oracle/product/11.2.0/db_1/root.sh
Check /usr/local/oracle/oracle/product/11.2.0/db_1/install/root_node1_2020-06-18_17-53-11.log for the output of root script

step14:静默配置监听
[root@node1 /download/database/response]# su - oracle
[oracle@node1 ~]$ netca /silent /responsefile /download/database/response/netca.rsp 

Parsing command line arguments:
    Parameter "silent" = true
    Parameter "responsefile" = /download/database/response/netca.rsp
Done parsing command line arguments.
Oracle Net Services Configuration:
Profile configuration complete.
Oracle Net Listener Startup:
    Running Listener Control: 
      /usr/local/oracle/oracle/product/11.2.0/db_1/bin/lsnrctl start LISTENER
    Listener Control complete.
    Listener started successfully.
Listener configuration complete.
Oracle Net Services configuration successful. The exit code is 0
[oracle@node1 ~]$ ll $ORACLE_HOME/network/admin
total 12
-rw-r--r-- 1 oracle oinstall 384 Jun 18 17:55 listener.ora
drwxr-xr-x 2 oracle oinstall  64 Jun 18 17:48 samples
-rw-r--r-- 1 oracle oinstall 187 May  7  2007 shrept.lst
-rw-r--r-- 1 oracle oinstall 237 Jun 18 17:55 sqlnet.ora
注：成功运行后会生成两个文件：sqlnet.ora和listener.ora
[root@node1 ~]# netstat -tnlp | grep 1521 #已经成功启动oracle
tcp6       0      0 :::1521                 :::*                    LISTEN      21773/tnslsnr   

step15:静默安装数据库（同时也建立一个对应的实例）
1)修改dbca.rsp文件
[root@node1 ~]# cp /download/database/response/dbca.rsp /download/database/response/dbca.rsp.bak
[root@node1 ~]# vim /download/database/response/dbca.rsp
GDBNAME = "orcl" #78行修改
SID = "orcl" #149行修改
SYSPASSWORD = "password" #190行修改
SYSTEMPASSWORD = "password" #200行修改
DATAFILEDESTINATION = /usr/local/oracle/oradata/ #357行修改,数据文件存放目录
ECOVERYAREADESTINATION=/usr/local/oracle/oradata_back #367行修改，恢复数据存放目录
CHARACTERSET = "AL32UTF8" #415行，设定字符集，重要
TOTALMEMORY = "1024" #540行，设定oracle使用的内存，建议为物理内存70%~85%
2)静默安装数据库
[oracle@node1 ~]$ dbca -silent -responseFile /download/database/response/dbca.rsp
[root@node1 ~]# ps -ef | grep ora_ | grep -v grep #root用户下查看oracle实例是否运行
oracle    23061      1  0 18:09 ?        00:00:00 ora_pmon_orcl
oracle    23063      1  0 18:09 ?        00:00:00 ora_vktm_orcl
oracle    23067      1  0 18:09 ?        00:00:00 ora_gen0_orcl
oracle    23069      1  0 18:09 ?        00:00:00 ora_diag_orcl
oracle    23071      1  0 18:09 ?        00:00:00 ora_dbrm_orcl
oracle    23073      1  0 18:09 ?        00:00:00 ora_psp0_orcl
oracle    23075      1  0 18:09 ?        00:00:00 ora_dia0_orcl
oracle    23077      1  0 18:09 ?        00:00:00 ora_mman_orcl
oracle    23079      1  0 18:09 ?        00:00:00 ora_dbw0_orcl
oracle    23081      1  0 18:09 ?        00:00:00 ora_lgwr_orcl
oracle    23083      1  0 18:09 ?        00:00:00 ora_ckpt_orcl
oracle    23085      1  0 18:09 ?        00:00:00 ora_smon_orcl
oracle    23087      1  0 18:09 ?        00:00:00 ora_reco_orcl
oracle    23089      1  2 18:09 ?        00:00:00 ora_mmon_orcl
oracle    23091      1  0 18:09 ?        00:00:00 ora_mmnl_orcl
oracle    23093      1  0 18:09 ?        00:00:00 ora_d000_orcl
oracle    23095      1  0 18:09 ?        00:00:00 ora_s000_orcl
oracle    23103      1  0 18:09 ?        00:00:00 ora_qmnc_orcl
oracle    23118      1  1 18:09 ?        00:00:00 ora_cjq0_orcl
[oracle@node1 ~]$ lsnrctl status #oracle用户下查看监听状态

LSNRCTL for Linux: Version 11.2.0.1.0 - Production on 18-JUN-2020 18:10:38

Copyright (c) 1991, 2009, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=EXTPROC1521)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 11.2.0.1.0 - Production
Start Date                18-JUN-2020 17:55:15
Uptime                    0 days 0 hr. 15 min. 23 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /usr/local/oracle/oracle/product/11.2.0/db_1/network/admin/listener.ora
Listener Log File         /usr/local/oracle/oracle/diag/tnslsnr/node1/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=node1)(PORT=1521)))
Services Summary...
Service "orcl" has 1 instance(s).
  Instance "orcl", status READY, has 1 handler(s) for this service...
Service "orclXDB" has 1 instance(s).
  Instance "orcl", status READY, has 1 handler(s) for this service...
The command completed successfully
3)启动数据库
[oracle@node1 ~]$ export ORACLE_SID=orcl
[oracle@node1 ~]$ sqlplus / as sysdba
SQL> shutdown immediate
[root@node1 ~]# ps -ef | grep ora_ | grep -v grep #此时ora_实例停止了
SQL> startup
[root@node1 ~]# ps -ef | grep ora_ | grep -v grep
oracle    23523      1  0 18:14 ?        00:00:00 ora_pmon_orcl
oracle    23525      1  0 18:14 ?        00:00:00 ora_vktm_orcl
oracle    23529      1  0 18:14 ?        00:00:00 ora_gen0_orcl
oracle    23531      1  0 18:14 ?        00:00:00 ora_diag_orcl
oracle    23533      1  0 18:14 ?        00:00:00 ora_dbrm_orcl
oracle    23535      1  0 18:14 ?        00:00:00 ora_psp0_orcl
oracle    23537      1  0 18:14 ?        00:00:00 ora_dia0_orcl
oracle    23539      1  0 18:14 ?        00:00:00 ora_mman_orcl
oracle    23541      1  0 18:14 ?        00:00:00 ora_dbw0_orcl
oracle    23543      1  0 18:14 ?        00:00:00 ora_lgwr_orcl
oracle    23545      1  0 18:14 ?        00:00:00 ora_ckpt_orcl
oracle    23547      1  0 18:14 ?        00:00:00 ora_smon_orcl
oracle    23549      1  0 18:14 ?        00:00:00 ora_reco_orcl
oracle    23551      1  0 18:14 ?        00:00:00 ora_mmon_orcl
oracle    23553      1  0 18:14 ?        00:00:00 ora_mmnl_orcl
oracle    23555      1  0 18:14 ?        00:00:00 ora_d000_orcl
oracle    23557      1  0 18:14 ?        00:00:00 ora_s000_orcl
oracle    23565      1  0 18:14 ?        00:00:00 ora_qmnc_orcl
oracle    23579      1  0 18:14 ?        00:00:00 ora_cjq0_orcl
oracle    23581      1  0 18:14 ?        00:00:00 ora_q000_orcl
oracle    23583      1  0 18:14 ?        00:00:00 ora_q001_orcl
#最后即可连接oracle数据库

#oracle的启动和关闭
Linux下启动Oracle分为两步：
　　1）启动监听；
　　2）启动数据库实例；
1.登录服务器，切换到oracle用户，或者以oracle用户登录
[oracle@node1 ~]$ lsnrctl start #启动监听
[oracle@node1 ~]$ lsnrctl status #查看启动状态
[oracle@node1 ~]$ netstat -tnlp | grep 1521
(Not all processes could be identified, non-owned process info
 will not be shown, you would have to be root to see it all.)
tcp6       0      0 :::1521                 :::*                    LISTEN      14878/tnslsnr    
2.以sys用户登录oracle,并启动数据库实例
[oracle@node1 ~]$ sqlplus / as sysdba
SQL> startup
ORACLE instance started.

Total System Global Area  801701888 bytes
Fixed Size		    2217632 bytes
Variable Size		  222300512 bytes
Database Buffers	  570425344 bytes
Redo Buffers		    6758400 bytes
Database mounted.
Database opened.
[oracle@node1 ~]$ ps aux | grep ora_ | grep -v grep #查看实例状态
oracle    15092  0.0  0.8 1004044 15920 ?       Ss   09:18   0:00 ora_pmon_orcl
oracle    15094  0.3  0.6 1001664 12372 ?       Ss   09:18   0:01 ora_vktm_orcl
oracle    15098  0.0  0.6 1001664 12368 ?       Ss   09:18   0:00 ora_gen0_orcl
oracle    15100  0.0  0.6 1001664 12384 ?       Ss   09:18   0:00 ora_diag_orcl
oracle    15102  0.0  1.0 1001664 20348 ?       Ss   09:18   0:00 ora_dbrm_orcl
oracle    15104  0.0  0.6 1001664 12644 ?       Ss   09:18   0:00 ora_psp0_orcl
oracle    15106  0.0  0.8 1002176 15908 ?       Ss   09:18   0:00 ora_dia0_orcl
oracle    15108  0.0  1.8 1001664 35332 ?       Ss   09:18   0:00 ora_mman_orcl
oracle    15110  0.0  1.1 1007932 21612 ?       Ss   09:18   0:00 ora_dbw0_orcl
oracle    15112  0.0  1.1 1017216 20884 ?       Ss   09:18   0:00 ora_lgwr_orcl
oracle    15114  0.1  0.8 1002176 15552 ?       Ss   09:18   0:00 ora_ckpt_orcl
oracle    15116  0.1  4.2 1008456 78864 ?       Ss   09:18   0:00 ora_smon_orcl
oracle    15118  0.0  1.1 1002176 21460 ?       Ss   09:18   0:00 ora_reco_orcl
oracle    15120  0.0  3.1 1007584 59404 ?       Ss   09:18   0:00 ora_mmon_orcl
oracle    15122  0.0  1.0 1001664 19152 ?       Ss   09:18   0:00 ora_mmnl_orcl
oracle    15124  0.0  0.6 1027292 12968 ?       Ss   09:18   0:00 ora_d000_orcl
oracle    15126  0.0  0.6 1002860 11580 ?       Ss   09:18   0:00 ora_s000_orcl
oracle    15168  0.0  0.7 1001664 14320 ?       Ss   09:18   0:00 ora_qmnc_orcl
oracle    15182  0.0  2.5 1006404 47428 ?       Ss   09:18   0:00 ora_cjq0_orcl
oracle    15260  0.0  1.3 1003332 24896 ?       Ss   09:18   0:00 ora_q000_orcl
oracle    15262  0.0  1.0 1002304 19320 ?       Ss   09:18   0:00 ora_q001_orcl
oracle    15813  0.0  0.6 1001664 12604 ?       Ss   09:23   0:00 ora_smco_orcl
oracle    15818  0.0  0.9 1002304 17156 ?       Ss   09:23   0:00 ora_w000_orcl
#关闭oracle
1. 关闭实例
2. 关闭监听器
[oracle@node1 ~]$ sqlplus / as sysdba
SQL> shutdown     
Database closed.
Database dismounted.
ORACLE instance shut down.
[oracle@node1 ~]$ ps aux | grep ora_ | grep -v grep
[oracle@node1 ~]$ lsnrctl stop

LSNRCTL for Linux: Version 11.2.0.1.0 - Production on 19-JUN-2020 09:31:04

Copyright (c) 1991, 2009, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=EXTPROC1521)))
The command completed successfully
[oracle@node1 ~]$ netstat -tnlp | grep 1521 #已经关闭
(No info could be read for "-p": geteuid()=9091 but you should be root.)

#Oracle for Linux开机自启动
1. [root@node2 ~]# vi /usr/local/oracle/oracle/product/11.2.0/db_1/bin/dbstart 
	 79 # First argument is used to bring up Oracle Net Listener
     80 ORACLE_HOME_LISTNER=$ORACLE_HOME   #将$1改成oracle安装的目录
     81 if [ ! $ORACLE_HOME_LISTNER ] ; then
     82   echo "ORACLE_HOME_LISTNER is not SET, unable to auto-start Oracle Net Liste        ner"
     83   echo "Usage: $0 ORACLE_HOME"
     84 else
2. [root@node2 ~]# vi /etc/oratab
orcl:/usr/local/oracle/oracle/product/11.2.0/db_1:Y  #将N设成Y，这个参数dbstart会来调取
3. [root@node2 ~]# vi /etc/rc.d/rc.local
#oracle auto start
su - oracle -lc "/usr/local/oracle/oracle/product/11.2.0/db_1/bin/lsnrctl start"
su - oracle -lc "/usr/local/oracle/oracle/product/11.2.0/db_1/bin/dbstart"
4. [root@node2 ~]# chmod +x /etc/rc.d/rc.local


#plsql客户端连接及配置(基于windows)
plsql客户端连接oracle有两种方式，一种是Basic,一种是TNS
1.Basic方式
1)先安装oracleclient(安装时自己会添加变量到系统中)
2)再安装plsql客户端、激活、绿化为中文版
3)在plsql客户端中设置：工具--首选项--连接  中，填入oracle主目录名路径和oci库路径，例如：D:\app\jack\product\11.2.0\client_1 和 D:\app\jack\product\11.2.0\client_1\oci.dll
4)重启plsql生效
5)打开plsql进行连接，输入用户名、密码、IP:PORT/INSTANCE、MODE
2.TNS方式
1)先安装oracleclient(安装时自己会添加变量到系统中),主要作用是在plsql中出现‘数据库’和‘连接为’这两个小窗口，否则无法连接oracle Server.
2)再安装plsql客户端、激活、绿化为中文版
3)在plsql客户端中设置：工具--首选项--连接  中，填入oracle主目录名路径和oci库路径，例>如：D:\OperationTools\oracle\instantclient_11_2 和 D:\OperationTools\oracle\instantclient_11_2\oci.dll
4)重启plsql生效
5)解压下好的instantclient_11_2.tgz，并在instantclient_11_2中建立目录NETWORK\ADMIN两个目录.然后把instantclient_11_2目录中的tnsnames.ora复制到NETWORK\ADMIN目录下，并编辑更改tnsnames.ora文件设立别名、连接协议、主机名或IP、PORT、连接的数据库名称
6)在系统中建立变量，使plsql能找到这个tnsnames.ora文件信息，例如：D:\OperationTools\oracle\instantclient_11_2\NETWORK\ADMIN
7)打开plsql进行连接，输入用户名、密码、别名(tnsnames.ora文件定义的)、MODE

</pre>

<pre>
oracle管理学习路线：
1. 数据库软件安装及创建数据库
	1. 环境变量
	2. 内核参数
	3. 软件目录
	4. 数据文件格式：文件系统，raw，asm
	5. 字符集设置
	6. 实例服务和实例名称设置
2. 启动关闭数据库
	1. 启动数据库
		1. nomount:启动参数文件
		2. mount:启动控制文件
		3. open:启动数据文件和日志文件的全挂载，进入数据库正常服务状态。如果数据库数据文件的检测点一致，那么直接打开，如果不一致，那么就做实例级回滚。
	2. 关闭数据库：
		1. immediate: 正常关闭
		2. abort: 强行关闭
3. 管理内存
	1. 缓冲区高速缓存
	2. 使用多个缓冲区池
	3. 共享池
	4. 大型池
	5. java池
	6. 重做日志缓冲区
	7. 自动管理共享内存
	8. 自动优化sga参数
	9. 手动优化sga参数
	v$parameter
	--缓冲区高速缓存:
	通过指定DB_CACHE_SIZE 参数的值，可以配置缓冲区高速缓存。缓冲区高速缓存可存放数据文件中块大小为DB_BLOCK_SIZE 的数据块的副本。缓冲区高速缓存是SGA 的一部分，因此所有用户都可以共享这些块。服务器进程将数据文件中的数据读入缓冲区高速缓存。为了提高性能，服务器进程有时在一个读操作中会读取多个块。然后由DBW n 进程将数据从缓冲区高速缓存写入数据文件。为提高性能，DBW n 在一个写操作中会写入多个块。
	在任何给定时间，缓冲区高速缓存都可能会存放一个数据库块的多个副本。虽然该块只存在一个当前副本，但为了满足查询需要，服务器进程可能需要根据过去的映像信息构造读一致性副本。这称为读一致性(CR) 块。 
	最近最少使用(LRU)  列表可反映缓冲区的使用情况。缓冲区将依据其被引用时间的远近和引用频率进行排序。因此，最经常使用且最常用的缓冲区将列在最近最常使用一端。传入的块先被复制到最近最少使用一端的缓冲区中，然后该缓冲区将被指定到列表中央，作为起点。从这个起点开始，缓冲区根据使用情况在列表中上下移动。 
	缓冲区高速缓存中的缓冲区可以处于以下四种状态之一：
	• 已连接：当前正将该块读入高速缓存或正在写入该块。其它会话正等待访问该块。
	• 干净的：该缓冲区目前未连接，如果其当前内容（数据块）将不再被引用，则可以立即执行过期处理。这些内容与磁盘保持同步，或者缓冲区包含块的读一致性快照。
	• 空闲/未使用：缓冲区因实例刚启动而处于空白状态。此状态与“干净”状态非常相似，不同之处在于缓冲区未曾使用过。
	• 脏：缓冲区不再处于连接状态，但内容（数据块）已更改，因此必须先通过 DBW n 将内容刷新到磁盘，然后才能执行过期处理。 
	服务器进程使用缓冲区高速缓存中的缓冲区；而DBW n 进程通过将更改的缓冲区写回数据文件，使高速缓存中的缓冲区变为可用状态。
	检查点队列中列出将要写出到磁盘的缓冲区。 
	Oracle DB 支持同一数据库中有多种块大小。标准块大小用于SYSTEM 表空间。标准块大小可以通过设置初始化参数DB_BLOCK_SIZE 来指定。其有效值介于2 KB 到32 KB  之间，默认值为8 KB。非标准块大小的缓冲区的高速缓存大小通过以下参数指定：
	• DB_2K_CACHE_SIZE
	• DB_4K_CACHE_SIZE
	• DB_8K_CACHE_SIZE
	• DB_16K_CACHE_SIZE
	• DB_32K_CACHE_SIZE
	DB_ n K_CACHE_SIZE参数不能用于调整标准块大小的高速缓存的大小。如果DB_BLOCK_SIZE 的值为n K，则设置DB_ n K_CACHE_SIZE是非法的。标准块大小的高
	速缓存的大小始终由DB_CACHE_SIZE 的值确定。
	由于每个缓冲区高速缓存的大小都有限制，因此，通常并非磁盘上的所有数据都能放在高速缓存中。当高速缓存写满时，后续高速缓存未命中会导致Oracle DB 将高速缓存中已有的灰数据写入磁盘，以便为新数据腾出空间。（如果缓冲区中没有灰数据，则不需要写入磁盘即可将新块读入该缓冲区。）以后若对已写入磁盘的任何数据进行访问，则会导致再次出现高速缓存未命中现象。 
	数据请求导致高速缓存命中的几率会受到高速缓存大小的影响。高速缓存越大，包含所请求数据的几率也就越大。因此，增加高速缓存大小会提高引起高速缓存命中的数据请求的百分比。
	--使用多个缓冲区池：	
	数据库管理员(DBA) 可以创建多个缓冲池来提高数据库缓冲区高速缓存的性能。你可以根据对象的访问情况将其分配给某个缓冲池。
	缓冲池有三种：
	• 保留：此池用于保留内存中可能要重用的对象。将这些对象保留在内存中可减少 I/O操作。通过使池的大小大于分配给该池的各个段的总大小，可以将缓冲区保留在此池中。这意味着缓冲区不必执行过期处理。保留池可通过指定DB_KEEP_CACHE_SIZE参数的值来配置。
	• 回收：此池用于内存中重用几率很小的块。回收池的大小要小于分配给该池的各个段的总大小。这意味着读入该池的块经常需要在缓冲区内执行过期处理。回收池可通过指定DB_RECYCLE_CACHE_SIZE 参数的值来配置。
	• 默认：此池始终存在。它相当于没有保留池和回收池的实例的缓冲区高速缓存，可通过DB_CACHE_SIZE 参数进行配置。
	注：保留池或回收池中的内存不是默认缓冲池的子集。
	CREATE INDEX cust_idx …
	STORAGE (BUFFER _POOL KEEP);
	ALTER TABLE oe.customers
	STORAGE (BUFFER_POOL RECYCLE);
	ALTER INDEX oe.cust_lname_ix
	STORAGE (BUFFER _POOL KEEP);
	BUFFER_POOL 子句用于定义对象的默认缓冲池。它是STORAGE子句的一部分，对CREATE 和ALTER表、集群和索引语句有效。未明确设置缓冲池的对象中的块将进入默认缓冲池。
	语法为：BUFFER_POOL [KEEP | RECYCLE | DEFAULT] 。
	使用ALTER语句更改对象的默认缓冲池时，已缓存的块会一直保留在其当前缓冲区中，直到正常缓冲区管理活动将它们清除为止。从磁盘读取的块将被放置在为该段新指定的缓冲池中。
	由于多个缓冲池被分配给某一个段，所以有多个段的对象可以将块放置在多个缓冲池中。
	例如，按索引组织的表在索引段和溢出段上可以有多个不同的池。
	--共享池：
	内容：
	• 库高速缓存（共享sql区域）：命令文本、已进行语法分析的代码和执行计划
	• 数据字典高速缓存：数据字典表中各表、列和权限的定义
	• 结果高速缓存：SQL 查询和PL/SQL  函数的结果
	• 用户全局区(UGA) ：Oracle 共享服务器的会话信息
	可以使用SHARED_POOL_SIZE 初始化参数指定共享池的大小。共享池是用于存储多个会话共享的信息的内存区。它包含不同类型的数据，
	库高速缓存：库高速缓存包含共享 SQL 区和PL/SQL  区－经过完全语法分析或编译的PL/SQL  块和SQL 语句的表示法。PL/SQL  块包括：
	• 过程和函数
	• 程序包
	• 触发器
	• 匿名PL/SQL  块
	数据字典高速缓存：数据字典高速缓存将字典对象的定义存放在内存中。
	结果高速缓存：结果高速缓存包括 SQL 查询结果高速缓存和PL/SQL  函数结果高速缓存。此高速缓存用于存储SQL 查询或PL/SQL  函数的结果，以加快它们将来的执行速度。
	用户全局区：UGA 包含 Oracle  共享服务器的会话信息。使用共享服务器会话时，如果尚未配置大型池，则UGA 位于共享池中。
	--重做日志缓冲区：
	SGA 中的循环缓冲区
	• 存放对数据库所做更改的信息
	• 包含重做条目，重做条目中具有重做由诸如DML 和DDL 操作所做更改的信息
	日志写进程(LGWR)  传送的内容：
	– 用户进程提交事务处理时
	– 重做日志缓冲区满三分之一时
	– DBW n 进程将修改的缓冲区写入磁盘之前
	Oracle Server  进程将重做条目从用户的内存空间复制到每个DML 或DDL 语句的重做日志缓冲区。重做条目包含重建或重做DML 和DDL 操作对数据库的更改所必需的信息。它们用于数据库恢复，需要占用缓冲区中的连续空间。 
	重做日志缓冲区是一个回收缓冲区；服务器进程可以用新条目覆盖重做日志缓冲区中已写入磁盘的条目。LGWR 进程的写速度通常都很快，足以确保缓冲区中始终有存储新条目的空间。LGWR 进程将重做日志缓冲区写入磁盘上的活动联机重做日志文件（或活动组成员）中。LGWR 进程将LGWR 上次写入磁盘以来进入缓冲区的所有重做条目复制到磁盘。 
	什么导致LGWR 执行写操作？
	在以下情况下，LGWR 会从重做日志缓冲区中写出重做数据：
	• 用户进程提交事务处理时
	• 每隔三秒钟，或者重做日志缓冲区满三分之一时
	• DBW n 进程将修改的缓冲区写入磁盘时（如果相应的重做日志数据尚未写入磁盘）
	--自动内存管理：
	通过自动内存管理，数据库可以根据工作量自动调整SGA 和PGA 的大小。
	ALTER SYSTEM SET MEMORY_TARGET=300M;
	通过自动内存管理(AMM)，Oracle DB 可以自动管理SGA 内存以及实例PGA 内存的大小。为此，在大多数平台上，只需要设置一个目标内存大小初始化参数( MEMORY_TARGET )  和一个最大内存大小初始化参数( MEMORY_MAX_TARGET)，数据库就会根据处理需求在SGA 与实例 PGA 之间动态交换内存。
	通过导航到“Server > Memory Advisors （服务器> 内存指导）”（在“Database Configuration（数据库配置）”区域中），并单击“Enable（启用）”按钮，可启用Oracle Enterprise Manager 中的AMM。
	启用自动内存管理后, 数据库将会自动设置内存的最佳分配方式。将不时更改内存分配以适应工作量的变化。 “最大内存大小”指定数据库可以分配的, 并且为了使用自动内存管理而必须设置的内存量。
	通过这种内存管理方法，数据库还可以动态调整单个SGA 组件的大小以及单个PGA 的大小。 
	因为目标内存初始化参数是动态的，因此可以随时更改目标内存大小而不必重新启动数据库。最大内存大小相当于一个上限，以防你无意中将目标内存大小设置得太高。因为某些SGA 组件的大小不容易收缩，或者其大小必须不低于某个下限值，所以数据库还要防止你将目标内存大小设置得太低。 
	这种间接的内存转移依赖于操作系统(OS) 的共享内存释放机制。将内存释放给 OS 后，其它组件可以通过向OS 请求内存来分配内存。目前，Linux、Solaris 、HPUX、AIX 和Windows 平台上已实施了自动内存管理。
4. 表空间
	1. 创建各种表空间，数据表空间，回滚段表空间，临时表空间
	2. 删除表空间
	3. 创建非标准块大小的表空间
	4. 查询表空间
	v$tablespace,dba_tablespaces
5. 数据文件
	1. 添加数据文件
	2. 删除数据文件（10g以后才有）
	3. 重命名数据文件
	4. 更改数据文件大小 
	5. 数据文件online,offline
	6. 查看数据文件大小
	v$datafile dba_data_files dba_temp_files
6. 参数管理
	1. pfile和spfile的转换
	2. 更改spfile
	3. 更改pfile
	4. 查看参数
	5. 查看sprile位置
7. redo管理
	1. 添加redo组
	2. 删除redo组
	3. 添加redo成员
	4. 删除redo成员
	5. 更改redo大小
	6. drop老的redo
	7. add新的redo
	8. 查看redo状态
	9. 查看redo成员状态
	v$log v$logfile
8. undo管理
	1. undo表空间创建
	2. undo表空间更改
	3. undo表空间用途
	4. undo保留时间的设置
	5. ora-01555错误产生的原因
9. 回收站
	1. 手动回收空间
	2. 查询回收站
	3. 查询已删除的表中的数据 
	4. 闪回删除的数据
	5. dba_recyclebin
	6. recyclebin
10. 管理锁
	1. 锁定机制
	2. 数据并发处理
	3. DML锁定
	4. 锁定冲突的可能原因
	5. 检测锁定冲突
	6. 解决锁定冲突
	7. 使用SQL解决锁定冲突
	8. 死锁
11. oracle用户
	1. 创建用户
	2. 赋予用户权限 
	3. 管理用户
	4. 在用户中创建对象
	5. 管理用户对象
	6. 删除用户
	dba_users
12. oracle网络
	1. 网络包括服务端和客户端
	2. 主要是配置tnsnames.ora listener.ora sqlnet.ora
	3. 把服务动态注册到监听，静态注册到监听
	4. 包括客户端连接单机库，rac库配置文件
13. 审计，安全
14. 数据字典
	1. v$开头是动态视图，在nomount,mount,open状态皆可使用
	2. dba_、all_、user_开头是静态视图，只有open状态可使用

进阶学习路线：
1. oracle体系结构
2. oracle管理精通
3. sql
4. 备份恢复
5. oracle rac
6. 调优
	1. 主机调优
	2. 存储调优
	3. 网络调优
	4. db调优
	5. 应用调优
7. 灾备goldengate dataguard sharepelx

</pre>