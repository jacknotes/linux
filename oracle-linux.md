﻿#Oracle
<pre>
Environment:
[root@node1 ~]# cat /etc/redhat-release 
CentOS Linux release 7.6.1810 (Core) 
#install
step1:虚拟内存建议，oracle后面需要使用
[root@node1 ~]# dd if=/dev/zero of=/swap bs=1M count=1024
[root@node1 ~]# mkswap /swap 
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
if [$SHELL = "/bin/ksh" ]; then
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
oracle.install.option=INSTALL_DB_SWONL #29行，#安装类型,只装数据库软件
ORACLE_HOSTNAME=node1 #37行,主机名称
UNIX_GROUP_NAME=oinstall #42行,安装组
INVENTORY_LOCATION=/usr/local/oracle/oraInventory #47行,NVENTORY目录（不填就是默认值,本例此处需修改,因个人创建安装目录而定）
SELECTED_LANGUAGES=en,zh_CN #78行，选择语言
ORACLE_HOME=/usr/local/oracle/oracle/product/11.2.0/db_1 #83行,安装路径
ORACLE_BASE=/usr/local/oracle/oracle #88行，oracle安装根路径
racle.install.db.InstallEdition=EE #99行，oracle安装版本
oracle.install.db.isCustomInstall=false #108行，是否自定义安装，默认使用默认组件
oracle.install.db.DBA_GROUP=dba #142行，设定用户组
oracle.install.db.OPER_GROUP=dba #147行，设定用户组
oracle.install.db.config.starterdb.type=GENERAL_PURPOSE #160行，数据库类型
oracle.install.db.config.starterdb.globalDBName=orcl #165行，全局数据库名称
oracle.install.db.config.starterdb.SID=orcl #170行，SID（**此处注意与环境变量内配置SID一致）
oracle.install.db.config.starterdb.memoryLimit=1024 #200行，指定总内存分配，最少256M
oracle.install.db.config.starterdb.password.ALL=oracle #233行，设定所有数据库用户使
用同一个密码
oracle.install.db.config.starterdb.password.SYS=password #238行
oracle.install.db.config.starterdb.password.SYSTEM=passwor #243行
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false #376行
DECLINE_SECURITY_UPDATES=true #385行，注意此参数 设定一定要为true

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

</pre>