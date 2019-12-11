#Mysql数据库

<pre>
#第一节：关系型数据体系结构
学习要点：
	1. sql/mysql
	2. 事务，隔离，并发控制，锁
	3. 用户和权限
	4. 监控
		1. status
	5. 索引类型：查询
		1. variables
	6. 备份和恢复*
	7. 复制功能
	8. mysql集群

DBMS:
	1. 层次模型
	2. 网关模型
	3. 关系模型
RDBMS：
	1. 关系模型
	2. 实体-关系模型
	3. 对象关系模型：基于对象的数据模型
	4. 半结构化数据模型：使用XML(扩展标记语言)例：<name>Jerry</name>,<age>50</age>
关系：关系代数运算
	1. 交集：重合的部分
	2. 并集：属于A或属于B
	3. 差集：属于A不属于B
	4. 补集：全集减去集合等于补集
SQL:Structure Qurey Language
1970年IBM研发了System R数据库系统
Ingres：世界上第一款成熟的数据库系统。Oracle,sybase商业数据库系统。
美国标准委员会定义了sql标准：ansi-sql
DML:数据操作语言
	INSERT,DELETE,UPDATE,SELECT
DDL:数据定义语言
	CREATE,DROP,ALTER
DCL:数据控制语言(用于设置访问权限的)
	GRANT
	REVOKE

RDB对象：库、表、索引、视图、用户、存储过程、存储函数、触发器、事件调度器
RDB约束(constraint)：
	域约束：数据类型约束
	外键约束：引用完整性约束
	主键约束：某字段能唯一标识此字段所属的，并且不允许为空
		一张表中只能有一个主键
	唯一键约束：每一行的某字段都不允许出现相同值，可以为空
		一张表中可以有多个唯一键
	检查性约束：age: int

文件：
	表示层：文件
	逻辑层：文件系统（类似存储引擎）
	物理层：元数据，数据（存储为数据块）
关系型数据：
	表示层：表
	逻辑层：存储引擎
	物理层：数据文件（数据文件，索引文件，日志文件）

数据存储和查询：
	存储管理器：
		1. 权限及完整性管理器
		2. 事务管理器
		3. 文件管理器
		4. 缓冲管理器
	查询管理器：
		1. DML解释器
		2. DDL解释器
		3. 查询执行管理器
mysql交互工具及应用：
	1. 应用程序
	2. sql用户
	3. dba管理工具
	4. 程序员api
mysql是单进程多线程的，有守护线程和应用线程。应尽量少跟数据库交互，所以需要使用缓存和线程重用
32bit：mysql最大2.7G内存
64bit:不能确定。smp：对称多处理器。mysql不能使一个请求在多个处理器运行，只能一个请求在一个处理器运行

关系运算：
	1. 投影：只输出指定属性
	2. 选择：只输出符合条件行 WHERE
	3. 自然连接：具有相同名字的属性上所有取值相同的行
	4. 笛卡尔积： (a+b)*(c+d)=ac+ad+bc+bd
	5. 并：集合运算


#第二节：mysql服务器的体系结构
sql查询语句：
	sequel-->然后发展成SQL
	sql规范：
		sql-86
		sql-89
		sql-92
		sql-99
		sql-03
		sql-08
SQL语言的组成部分：
	DDL
	DML
	完整性定义语言：DDL的一部分功能
	视图定义
	事务控制
	嵌入式SQL和动态SQL：嵌入式SQL是把sql放在程序设计语言上执行

oracle:pl/sql（只有一个存储引擎）
postgresql:pl/sql
sqlserver:tsql（只有一个存储引擎）
mysql:sql（有多个存储引擎）
使用程序设计语言如何跟RDBMS交互：
	ODBC：嵌入式SQL:把sql放在程序设计语言上执行。与动态SQL类似，但其语言必须程序编译时完全确定下来。
	JDBC：动态SQL:程序设计语言使用函数（mysql_connect()）或者方法与RDBMS服务器建立连接，并进行交互;通过建立连接向SQL服务器发送查询语句，并将结果保存至变量中而后进行处理;
#mysql请求流程：
用户->连接管理器->解析器->缓存
用户->连接管理器->解析器->优化器->存储引擎
mysql支持插件式存储引擎
5.5.8-：默认MyISAM(不支持事务)，适用于查询多，修改少
5.5.8+:默认InnoDB(支持事务)，适用于在线事务处理

表管理器：负责创建、删除、重命名、移除、更新或插入之类的操作;
表维护模块：检查、修改、备份、恢复、优化(碎片管理)及解析;

行：定长，变长
文件中记录组织：
	堆文件组织：一条记录可以放在文件中的任何地方。
	顺序文件组织：根据“搜索码”值顺序存放。
	散列文件组织：根据hash算法进行存放
表结构定义文件，表数据文件
表空间：table space
数据字典：data dictionaty （oracle很常见）
	关系的元数据：
		关系的名字
		字段名字
		字段的类型和长度
		视图
		约束
		用户名字，授权，密码
注：初始化mysql后生成的mysql数据库说白了就是数据字典
缓冲区管理器：
	缓存转换策略
	被钉住的块不被置换出来

#第三节：数据库基础及编译安装
#mysql前途未卜，所以有了mariaDB,percona是为mysql提供优化方案的
安装方式：
	1. 基于软件包发行商格式的包。dep,rpm
	2. 通用二进制安装，是gcc,icc编译安装的，用得最多的是gcc
	3. 编译安装。5.1及以前是make安装的，后面的是cmake安装的，可以编译成32位或64位平台。
1. 基于软件包发行商格式的包安装的包：MySQL-client,MySQL-devel,MySQL-shared,MySQL-shared-compat。-----MySQL-test测试组件偶尔会装
2. 通用二进制安装之前做过
修改密码3种方式：
	1. mysqladmin -u root -h host -p youe_password 'new-password'
	2. set password for 'root'@'localhost'=password('new-password');
	3. update user set password=password('new-password') where user=root and host=localhost;
###3. 编译安装mysql5.6：
1. 确保已经安装了cmake:[root@localhost yum.repos.d]# yum install cmake -y
#cmake用法：
./configure    cmake .
./configure --help    cmake . -LH   or   ccmake .
make && make install     make && make install
[root@localhost yum.repos.d]# yum groupinstall "Development Tools" "RPM Development Tools" -y  #安装开发环境
编译参数：
默认编译的存储引擎包括：csv、myisam、myisammrt和heap
-DWITH_READLINE=1  #开启批量导入功能
-DWITH_SSL=system #开启ssl,对于复制功能至关重要
-DWITH_ZLIB=system #压缩库
-DSYSCONFDIR=/etc #配置文件路径
-DMYSQL_DATADIR=/mydata/data #数据库路径
-DCMAKE_INSTALL_PREFIX=/usr/local/mysql #安装路径
-DWITH_INNOBASE_STORAGE_ENGINE=1 #打开innoDB存储引擎
-DWITH_ARCHIVE_STORAGE_ENGINE=1 #打开archive存储引擎
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 #打开mysql黑洞存储引擎
-DMYSQL_UNIX_ADDR=/tmp/mysql.sock #指定mysql套接字路径
-DDEFAULT_CHARSET=utf-8 #默认字符集
-DDEFAULT_COLLATION=utf8_general_ci #字符集默认排序规则，例如拼音排序，笔画排序
-DWITH_LIBWRAP=0  #禁用tcp_wrap访问
[root@localhost download]# mkdir /mydata/data -pv #生产环境用在lvm上
[root@localhost data]# useradd -r -g 3306 -u 3306 -s /sbin/nologin mysql
[root@localhost data]# chown -R mysql.mysql /mydata/data/
[root@lnmp mysql-5.5.37]# cmake . -LH
[root@lnmp mysql-5.5.37]# cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/mydata/ -DSYSCONFDIR=/etc -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_ZLIB=system -DWITH_LIBWRAP=0 -DMYSQL_UNIX_ADDR=/tmp/mysql.sock -DDEFAULT_CHARSET=utf-8 -DDEFAULT_COLLATION=utf8_general_ci  #当后面mysql无法启动时，可以先不设置-DDEFAULT_CHARSET=utf-8 -DDEFAULT_COLLATION=utf8_general_ci参数
/down/mysql-5.5.37/sql/sql_yacc.yy:14770:23: note: in expansion of macro ‘Lex’
             LEX *lex= Lex;
                       ^
make[2]: *** [sql/CMakeFiles/sql.dir/sql_yacc.cc.o] Error 1
make[1]: *** [sql/CMakeFiles/sql.dir/all] Error 2
make: *** [all] Error 2
[root@lnmp mysql-5.5.37]# echo $? #编辑报错
2
[root@lnmp ~]# rpm -qa | grep bison
bison-3.0.4-2.el7.x86_64  #版本太高
[root@lnmp ~]# rpm -e bison
[root@lnmp ~]# rpm -qa | grep bison
[root@lnmp ~]# wget ftp://ftp.gnu.org/gnu/bison/bison-2.5.1.tar.xz #下载2.5.1低版本
tar xf bison-2.5.1.tar 
cd bison-2.5.1/
./configure && make && make install
[root@lnmp mysql-5.5.37]# make && make install
[root@lnmp mysql-5.5.37]# cd /usr/local/
[root@lnmp local]# chown -R :mysql mysql/
[root@lnmp mysql]# ./scripts/mysql_install_db --user=mysql --datadir=/mydata/data
Installing MySQL system tables...
OK
Filling help tables...
OK
[root@lnmp mysql]# cp support-files/my-large.cnf /etc/my.cnf
[root@lnmp mysql]# cp support-files/mysql.server /etc/init.d/mysqld
[root@lnmp mysql]# chkconfig --add mysqld
[root@lnmp mysql]# chkconfig --list mysqld
mysqld          0:off   1:off   2:on    3:on    4:on    5:on    6:off
[root@lnmp mysql]# vim /etc/profile.d/mysql.sh
export PATH=$PATH:/usr/local/mysql/bin
[root@lnmp mysql]# . /etc/profile
[root@lnmp etc]# service mysqld start
Starting MySQL.. SUCCESS! 
注：当上面所有设置过，启动不成功一般有4点原因：
	1. 此前服务未关闭端口占用，关闭之前的服务
	2. 数据初始化失败,查看数据目录/mydata下的$HOST.err错误文件
	3. 数据目录位置错误，数据目录/mydata下无$HOST.err错误文件，在my.cnf中明确定义datadir = /mydata
	4. 数据目录权限问题
#在同一台主机上，mysql和mysqld是如何进行通信的：
linux:
	mysql-->mysql.sock-->mysqld  #套接字
windows:
	mysql-->memory(pipe)-->mysqld   #共享内存或管道
mysql客户端工具：mysql、mysqldump、mysqladmin、mysqlcheck、mysqlimport   #my.cnf中client字段的配置都会对这些客户端工具生效
mysql非客户端工具：myisamchk、myisampark
mysql客户端使用参数：
	-u -h -p --protocal --port
	默认使用socket,其它protocol有tcp、memory、pipe

[root@lnmp etc]# mysql
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 1
Server version: 5.5.37-log Source distribution  #这里显示源码安装的

Copyright (c) 2000, 2014, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show engines;
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
| Engine             | Support | Comment                                                        | Transactions | XA   | Savepoints |
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
| CSV                | YES     | CSV storage engine                                             | NO           | NO   | NO         |
| InnoDB             | DEFAULT | Supports transactions, row-level locking, and foreign keys     | YES          | YES  | YES        |
| MyISAM             | YES     | MyISAM storage engine                                          | NO           | NO   | NO         |
| BLACKHOLE          | YES     | /dev/null storage engine (anything you write to it disappears) | NO           | NO   | NO         |
| MRG_MYISAM         | YES     | Collection of identical MyISAM tables                          | NO           | NO   | NO         |
| PERFORMANCE_SCHEMA | YES     | Performance Schema                                             | NO           | NO   | NO         |
| ARCHIVE            | YES     | Archive storage engine                                         | NO           | NO   | NO         |
| MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables      | NO           | NO   | NO         |
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
8 rows in set (0.00 sec) 
注：默认存储引擎为InnoDB

[root@lnmp etc]# vim /etc/my.cnf
thread_concurrency = 4 #4个并发线程
datadir = /mydata/data  #源码编译安装的mysql没有这个路径，但不报错，因为编译的时候已经指定了，为了保险起见，写上这行
[root@lnmp etc]# service mysqld restart
[root@lnmp etc]# mysql
mysql> select User,Host,Password from user;
+------+---------------+----------+
| User | Host          | Password |
+------+---------------+----------+
| root | localhost     |          |
| root | lnmp.jack.com |          |
| root | 127.0.0.1     |          |
| root | ::1           |          |
|      | localhost     |          |  #有两个匿名用户，需要删除
|      | lnmp.jack.com |          |
+------+---------------+----------+
mysql> drop user ''@localhost;
Query OK, 0 rows affected (0.00 sec)

mysql> drop user ''@lnmp.jack.com;
Query OK, 0 rows affected (0.00 sec)

mysql> drop user 'root'@'::1';
Query OK, 0 rows affected (0.00 sec)

mysql> select User,Host,Password from user;
+------+---------------+----------+
| User | Host          | Password |
+------+---------------+----------+
| root | localhost     |          |
| root | lnmp.jack.com |          |
| root | 127.0.0.1     |          |
+------+---------------+----------+
3 rows in set (0.00 sec)
mysql> update user set password=password('root123') where user='root';  #设置保留的三个用户密码
mysql> select User,Host,Password from user;
+------+---------------+-------------------------------------------+
| User | Host          | Password                                  |
+------+---------------+-------------------------------------------+
| root | localhost     | *FAAFFE644E901CFAFAEC7562415E5FAEC243B8B2 |
| root | lnmp.jack.com | *FAAFFE644E901CFAFAEC7562415E5FAEC243B8B2 |
| root | 127.0.0.1     | *FAAFFE644E901CFAFAEC7562415E5FAEC243B8B2 |
+------+---------------+-------------------------------------------+
[root@lnmp etc]# mysql -u root -h 192.168.1.233 -p  #登录报错，因为只允许本机访问，而且本机访问只能是通过socket访问的，现在指明ip地址，则mysql认为是使用tcp连接的，所以用root用户tcp连接跟设置的root用户socket连接不符，所以报错
Enter password: 
ERROR 1130 (HY000): Host 'linux-node1-salt.jack.com' is not allowed to connect to this MySQL server

如何在本机上不指定用户名主机密码登录mysql:
[root@lnmp ~]# cat .my.cnf 
[client]  #client为所有客户端生效，当为mysql时只针对mysql客户端
user = 'root'
password = 'root123'
host = 'localhost'
[root@lnmp ~]# chmod 600 .my.cnf 
[root@lnmp ~]# service mysqld restart #重启即可
Shutting down MySQL. SUCCESS! 
Starting MySQL.. SUCCESS! 
#认识数据库文件：
[root@lnmp mysql]# cd /mydata/data/mysql/ #进入系统数据库mysql
[root@lnmp mysql]# ls  #对于myISAM来说每个表有3个文件 
db.frm  #对于MyISAM存储引擎来说这个是表结构文件
db.MYD  #对于MyISAM存储引擎来说这个是表存储文件
db.MYI  #对于MyISAM存储引擎来说这个是表索引文件
InnoDB:
	所有表共享一个表空间文件，不好
	建议：每表一个独立的表空间文件
mysql> show variables like '%innodb%';
innodb_file_per_table           | OFF #把这个打开就可以支持每张表生成一个表空间文件
#为了永久生效，编辑 vim /etc/my.cnf文件
[mysqld]
innodb_file_per_table = 1
[root@lnmp bison-2.5.1]# service mysqld restart #重启服务
mysql> show global variables like '%innodb_file_per_table%';
+-----------------------+-------+
| Variable_name         | Value |
+-----------------------+-------+
| innodb_file_per_table | ON    |
+-----------------------+-------+

##例：创建一张表
mysql> create database mydb;
mysql> use mydb;
mysql> create table testdb(
    -> id int not null,
    -> name char(30));
[root@lnmp bison-2.5.1]# cd /mydata/data/mydb/
[root@lnmp mydb]# ll
total 208
-rw-rw---- 1 mysql mysql    65 Jun 13 17:27 db.opt #当前数据库默认的字符集和排序规则
-rw-rw---- 1 mysql mysql  8586 Jun 13 17:27 testdb.frm #innoDB的.frm为表结构
-rw-rw---- 1 mysql mysql 98304 Jun 13 17:27 testdb.ibd #innoDB的.ibd为表空间，存储了表的数据

##第四节：客户端工具的使用
mysql登入参数：
	1. -u or user
	2. -p or password
	3. -h or host
	4. --protocol
	5. --port
	6. --database or -D 

mysql两种交换模式
	1. 交互式模式
	2. 批处理模式  #mysql < init.sql  #sql文件为sql语句 

mysql提示符：
	1. ->
	2. '>
	3. ">
	4. /*>
	5. `>

#mysql命令分为两种
	1. 客户端命令
	2. 服务器命令
	
#mysql的客户端命令的使用：
mysql> \?  #获取客户端命令帮助

For information about MySQL products and services, visit:
   http://www.mysql.com/
For developer information, including the MySQL Reference Manual, visit:
   http://dev.mysql.com/
To buy MySQL Enterprise support, training, or other products, visit:
   https://shop.mysql.com/

List of all MySQL commands:
Note that all text commands must be first on line and end with ';'
?         (\?) Synonym for `help'.
clear     (\c) Clear the current input statement.
connect   (\r) Reconnect to the server. Optional arguments are db and host.
delimiter (\d) Set statement delimiter.  #设置服务器结束符
edit      (\e) Edit command with $EDITOR.
ego       (\G) Send command to mysql server, display result vertically. #以列方式显示表
exit      (\q) Exit mysql. Same as quit. #退出客户端
go        (\g) Send command to mysql server. #默认以行显示
help      (\h) Display this help.
nopager   (\n) Disable pager, print to stdout.
notee     (\t) Don't write into outfile.
pager     (\P) Set PAGER [to_pager]. Print the query results via PAGER.
print     (\p) Print current command.
prompt    (\R) Change your mysql prompt.
quit      (\q) Quit mysql.
rehash    (\#) Rebuild completion hash. #打开名称补全
source    (\.) Execute an SQL script file. Takes a file name as an argument.  #读取服务器上sql文件
status    (\s) Get status information from the server. #查看状态信息
system    (\!) Execute a system shell command. #执行系统命令
tee       (\T) Set outfile [to_outfile]. Append everything into given outfile.
use       (\u) Use another database. Takes database name as argument.  #切换数据库
charset   (\C) Switch to another charset. Might be needed for processing binlog with multi-byte charsets. #切换字符集
warnings  (\W) Show warnings after every statement. #开启警告信息
nowarning (\w) Don't show warnings after every statement. #关闭警告信息
#mysql的服务器命令使用：
help KEYWORD ＃help关键字
##mysqladmin客户端工具的使用
[root@lnmp ~]# mysqladmin --help
Usage: mysqladmin [OPTIONS] command command....
mysqladmin -u root -p your_password "NEW_PASSWORD" #更改root密码
mysqladmin参数：
	--compress #发送接收数据时都进行压缩
	--ssl-ca=name   #指定ca路径及名称
	--ssl-capath=name  #指定多个ca路径
	--ssl-cert=name  #指定证书路径及名称
	--ssl-cipher=name  #指定加密算法列表
	--ssl-key=name  #指定key路径及名称
	--ssl-verify-server-cert #是否验证服务器证书
	create DATABASE
	drop DATABASE
	processlist   #查看mysql服务器当前执行的命令进程
	status  #查看服务器状态
		--sleep 2 #每隔2秒显示一次
		--count 2 #总共显示两次
	extended-status  #显示服务器状态变量信息
	variables  #显示服务器变量
	flush-privileges #重读mysql授权表，
	flush-status  #重置服务器的大多数变量
	flush-logs  #二进制和中继日志滚动
	flush-hosts #重置计数器可以让失误次数过多而被禁止登录的用户登录
	kill #杀死一个线程
	reload  #等同于flush-privileges 
	refresh #相同于同时执行flush-hosts和flush-logs
	shutdown #关闭mysql服务
	version #显示服务器版本及当前状态信息
	start-slave:启动从服务器复制线程
		IO thread
		SQL thread
	stop-slave:关闭从服务器复制线程
另外mysql客户端工具：mysqldump,mysqlimport,mysqlcheck

#第五节：mysql数据类型及sql模型
myISAM:
	.frm  #表结构文件
	.MYD  #表数据文件
	.MYI  #表索引文件
InnoDB
	.frm  #表结构文件
	.ibd  #表空间(数据和索引)
#大多数情况下使用的是myISAM和InnoDB存储引擎，其它存储引擎为抚助存储引擎
客户端：mysql,mysqladmin,mysqldump,mysqlcheck,mysqlimport
服务器：mysqld,mysqld_safe(安全线程启动，mysql真正启动时是这个启动的),mysqld_multi(多实例)
mysqlbinlog #查看mysql二进制日志的
#my.cnf配置文件顺序：
	/etc/my.cnf,/etc/mysql/my.cnf,$MYSQL_HOME/my.cnf,--default-extra-file=/pth/to/somefile,~/.my.cnf  #后面的会覆盖前面的配置
[mysqld] #mysqld服务端配置
[mysql] #mysql客户端
[client】#所有客户端
注：所有命令行的命令都可以写到my.cnf配置文件中，也可以把my.cnf文件写在命令行中，在命令行中的_下划线和-横线在配置中一样，
#mysql配置文件帮助信息：
#mysqld --help --verbose  #查看配置文件可用的参数
mysql> help show table status; #查看表的状态信息
Name: 'SHOW TABLE STATUS'
Description:
Syntax:
SHOW TABLE STATUS [{FROM | IN} db_name]
    [LIKE 'pattern' | WHERE expr]
mysql> show table status from mysql like 'user' \G ;
*************************** 1. row ***************************
           Name: user
         Engine: MyISAM  #表类型为MyISAM
        Version: 10
     Row_format: Dynamic
           Rows: 3
 Avg_row_length: 126
    Data_length: 380
Max_data_length: 281474976710655
   Index_length: 2048
      Data_free: 0
 Auto_increment: NULL
    Create_time: 2019-06-18 21:57:30
    Update_time: 2019-06-18 22:34:55
     Check_time: NULL
      Collation: utf8_bin
       Checksum: NULL
 Create_options: 
        Comment: Users and global privileges
1 row in set (0.00 sec)

DBA:
	开发DBA:数据库设计、SQL语句、存储过程，存储函数，触发器
	管理DBA：安装、升级、备份、恢复、用户管理、权限管理、监控、性能分析、基准测试
###mysql开发
1. mysql数据类型
2. mysql SQL语句

1.mysql数据类型：
	数值型：
		精确数值：
			1. int 
			2. decimal #十进制
		近似数值：
			1. float  
			2. double
			3. real #实数
	字符型：
		定长：CHAR(N) #不区分大小写，BINARY  #BINARY区分大小写
		变长：VARCHAR(N) #不区分大小写，VARBINARY #VARBINARY可变长的区分大小写
		大字符：text #不区分大小写   blob #区分大小写
		内置类型：ENUM  #枚举型,SET #集合型
	日期时间型：
		date,time,datatime,timestamp(时间戳)，year(N)#可为2位或4位
域属性，修改符：（进行域限制的）	
数据类型：
1. 存储的值类型：
2. 占据的存储空间：
3. 定长还是变长：
4. 如何比较及排序：
5. 是否能够索引：
#不区分大小写：
char #最大255个字符，能索引整个字段
varchar #最大65535个字符，每一个varchar将至少多占一个字符空间，超过255后需要占用两个结束符，低于255时只占用1个结束符
tinytext #255个字符，不能索引整个字段
text #65535
mediumtext #16777215
longtext  #4294967295
#区分大小写：
binary #255个字节
varbinary #65535个字节
tinyblob #255个字节，blob中为文本大对象
blob #64k
mediumblob  #16Mb空间
longblog #4G空间

tinyint(1) #括号里面的数字并不会改变数据类型的大小，只是显示数值位数，例如值为123，则这里显示个位3
date #3个字节
time #3个字节
datetime #8个字节
year #1个字节
ENUM  #枚举型，字符型，65535个字符
SET #集合型，存储的是位图，64个字符

#字段后面的限定：
1. NOTNULL
2. NULL
3. DEFAULT
4. CHARACTER SET #字符集
5. COLLATION  #排序规则
6. AUTO_INCREMENT #自增长，必须为正整形（UNSIGNED），这个字段定义为这个类型后不能为空，一定要创建索引(PRIMARY KEY或UNIQUE index)
7. ZEROFILL #多一位用0填充
mysql> select last_insert_id();
+------------------+
| last_insert_id() |
+------------------+
|                0 |
+------------------+
#所有存储函数使用select执行，存储过程使用call来调用 
#字符集和排序规则：字段从表继承，表从数据库继承，数据库从服务器继承
mysql> SHOW CHARACTER SET;  #查看当前服务器的所有字符集
+----------+-----------------------------+---------------------+--------+
| Charset  | Description                 | Default collation   | Maxlen |
+----------+-----------------------------+---------------------+--------+
| big5     | Big5 Traditional Chinese    | big5_chinese_ci     |      2 |
| dec8     | DEC West European           | dec8_swedish_ci     |      1 |
| cp850    | DOS West European           | cp850_general_ci    |      1 |
| hp8      | HP West European            | hp8_english_ci      |      1 |
| koi8r    | KOI8-R Relcom Russian       | koi8r_general_ci    |      1 |
| latin1   | cp1252 West European        | latin1_swedish_ci   |      1 |
| latin2   | ISO 8859-2 Central European | latin2_general_ci   |      1 |
| swe7     | 7bit Swedish                | swe7_swedish_ci     |      1 |
| ascii    | US ASCII                    | ascii_general_ci    |      1 |
| ujis     | EUC-JP Japanese             | ujis_japanese_ci    |      3 |
| sjis     | Shift-JIS Japanese          | sjis_japanese_ci    |      2 |
| hebrew   | ISO 8859-8 Hebrew           | hebrew_general_ci   |      1 |
| tis620   | TIS620 Thai                 | tis620_thai_ci      |      1 |
| euckr    | EUC-KR Korean               | euckr_korean_ci     |      2 |
| koi8u    | KOI8-U Ukrainian            | koi8u_general_ci    |      1 |
| gb2312   | GB2312 Simplified Chinese   | gb2312_chinese_ci   |      2 |
| greek    | ISO 8859-7 Greek            | greek_general_ci    |      1 |
| cp1250   | Windows Central European    | cp1250_general_ci   |      1 |
| gbk      | GBK Simplified Chinese      | gbk_chinese_ci      |      2 |
| latin5   | ISO 8859-9 Turkish          | latin5_turkish_ci   |      1 |
| armscii8 | ARMSCII-8 Armenian          | armscii8_general_ci |      1 |
| utf8     | UTF-8 Unicode               | utf8_general_ci     |      3 |
| ucs2     | UCS-2 Unicode               | ucs2_general_ci     |      2 |
| cp866    | DOS Russian                 | cp866_general_ci    |      1 |
| keybcs2  | DOS Kamenicky Czech-Slovak  | keybcs2_general_ci  |      1 |
| macce    | Mac Central European        | macce_general_ci    |      1 |
| macroman | Mac West European           | macroman_general_ci |      1 |
| cp852    | DOS Central European        | cp852_general_ci    |      1 |
| latin7   | ISO 8859-13 Baltic          | latin7_general_ci   |      1 |
| utf8mb4  | UTF-8 Unicode               | utf8mb4_general_ci  |      4 |
| cp1251   | Windows Cyrillic            | cp1251_general_ci   |      1 |
| utf16    | UTF-16 Unicode              | utf16_general_ci    |      4 |
| cp1256   | Windows Arabic              | cp1256_general_ci   |      1 |
| cp1257   | Windows Baltic              | cp1257_general_ci   |      1 |
| utf32    | UTF-32 Unicode              | utf32_general_ci    |      4 |
| binary   | Binary pseudo charset       | binary              |      1 |
| geostd8  | GEOSTD8 Georgian            | geostd8_general_ci  |      1 |
| cp932    | SJIS for Windows Japanese   | cp932_japanese_ci   |      2 |
| eucjpms  | UJIS for Windows Japanese   | eucjpms_japanese_ci |      3 |
+----------+-----------------------------+---------------------+--------+
39 rows in set (0.00 sec)

mysql> show collation;  #查看各个字符集下的排序规则 
+--------------------------+----------+-----+---------+----------+---------+
| Collation                | Charset  | Id  | Default | Compiled | Sortlen |
+--------------------------+----------+-----+---------+----------+---------+
| big5_chinese_ci          | big5     |   1 | Yes     | Yes      |       1 |
| big5_bin                 | big5     |  84 |         | Yes      |       1 |
| dec8_swedish_ci          | dec8     |   3 | Yes     | Yes      |       1 |
| dec8_bin                 | dec8     |  69 |         | Yes      |       1 |
| cp850_general_ci         | cp850    |   4 | Yes     | Yes      |       1 |
| cp850_bin                | cp850    |  80 |         | Yes      |       1 |
| hp8_english_ci           | hp8      |   6 | Yes     | Yes      |       1 |
| hp8_bin                  | hp8      |  72 |         | Yes      |       1 |
| koi8r_general_ci         | koi8r    |   7 | Yes     | Yes      |       1 |
| koi8r_bin                | koi8r    |  74 |         | Yes      |       1 |
| latin1_german1_ci        | latin1   |   5 |         | Yes      |       1 |
| latin1_swedish_ci        | latin1   |   8 | Yes     | Yes      |       1 |
| latin1_danish_ci         | latin1   |  15 |         | Yes      |       1 |
| latin1_german2_ci        | latin1   |  31 |         | Yes      |       2 |
| latin1_bin               | latin1   |  47 |         | Yes      |       1 |
| latin1_general_ci        | latin1   |  48 |         | Yes      |       1 |
| latin1_general_cs        | latin1   |  49 |         | Yes      |       1 |
| latin1_spanish_ci        | latin1   |  94 |         | Yes      |       1 |
| latin2_czech_cs          | latin2   |   2 |         | Yes      |       4 |
| latin2_general_ci        | latin2   |   9 | Yes     | Yes      |       1 |
| latin2_hungarian_ci      | latin2   |  21 |         | Yes      |       1 |
| latin2_croatian_ci       | latin2   |  27 |         | Yes      |       1 |
| latin2_bin               | latin2   |  77 |         | Yes      |       1 |
| swe7_swedish_ci          | swe7     |  10 | Yes     | Yes      |       1 |
| swe7_bin                 | swe7     |  82 |         | Yes      |       1 |
| ascii_general_ci         | ascii    |  11 | Yes     | Yes      |       1 |
| ascii_bin                | ascii    |  65 |         | Yes      |       1 |
| ujis_japanese_ci         | ujis     |  12 | Yes     | Yes      |       1 |
| ujis_bin                 | ujis     |  91 |         | Yes      |       1 |
| sjis_japanese_ci         | sjis     |  13 | Yes     | Yes      |       1 |
| sjis_bin                 | sjis     |  88 |         | Yes      |       1 |
| hebrew_general_ci        | hebrew   |  16 | Yes     | Yes      |       1 |
| hebrew_bin               | hebrew   |  71 |         | Yes      |       1 |
| tis620_thai_ci           | tis620   |  18 | Yes     | Yes      |       4 |
| tis620_bin               | tis620   |  89 |         | Yes      |       1 |
| euckr_korean_ci          | euckr    |  19 | Yes     | Yes      |       1 |
| euckr_bin                | euckr    |  85 |         | Yes      |       1 |
| koi8u_general_ci         | koi8u    |  22 | Yes     | Yes      |       1 |
| koi8u_bin                | koi8u    |  75 |         | Yes      |       1 |
| gb2312_chinese_ci        | gb2312   |  24 | Yes     | Yes      |       1 |
| gb2312_bin               | gb2312   |  86 |         | Yes      |       1 |
| greek_general_ci         | greek    |  25 | Yes     | Yes      |       1 |
| greek_bin                | greek    |  70 |         | Yes      |       1 |
| cp1250_general_ci        | cp1250   |  26 | Yes     | Yes      |       1 |
| cp1250_czech_cs          | cp1250   |  34 |         | Yes      |       2 |
| cp1250_croatian_ci       | cp1250   |  44 |         | Yes      |       1 |
| cp1250_bin               | cp1250   |  66 |         | Yes      |       1 |
| cp1250_polish_ci         | cp1250   |  99 |         | Yes      |       1 |
| gbk_chinese_ci           | gbk      |  28 | Yes     | Yes      |       1 |
| gbk_bin                  | gbk      |  87 |         | Yes      |       1 |
| latin5_turkish_ci        | latin5   |  30 | Yes     | Yes      |       1 |
| latin5_bin               | latin5   |  78 |         | Yes      |       1 |
| armscii8_general_ci      | armscii8 |  32 | Yes     | Yes      |       1 |
| armscii8_bin             | armscii8 |  64 |         | Yes      |       1 |
| utf8_general_ci          | utf8     |  33 | Yes     | Yes      |       1 |
| utf8_bin                 | utf8     |  83 |         | Yes      |       1 |
| utf8_unicode_ci          | utf8     | 192 |         | Yes      |       8 |
| utf8_icelandic_ci        | utf8     | 193 |         | Yes      |       8 |
| utf8_latvian_ci          | utf8     | 194 |         | Yes      |       8 |
| utf8_romanian_ci         | utf8     | 195 |         | Yes      |       8 |
| utf8_slovenian_ci        | utf8     | 196 |         | Yes      |       8 |
| utf8_polish_ci           | utf8     | 197 |         | Yes      |       8 |
| utf8_estonian_ci         | utf8     | 198 |         | Yes      |       8 |
| utf8_spanish_ci          | utf8     | 199 |         | Yes      |       8 |
| utf8_swedish_ci          | utf8     | 200 |         | Yes      |       8 |
| utf8_turkish_ci          | utf8     | 201 |         | Yes      |       8 |
| utf8_czech_ci            | utf8     | 202 |         | Yes      |       8 |
| utf8_danish_ci           | utf8     | 203 |         | Yes      |       8 |
| utf8_lithuanian_ci       | utf8     | 204 |         | Yes      |       8 |
| utf8_slovak_ci           | utf8     | 205 |         | Yes      |       8 |
| utf8_spanish2_ci         | utf8     | 206 |         | Yes      |       8 |
| utf8_roman_ci            | utf8     | 207 |         | Yes      |       8 |
| utf8_persian_ci          | utf8     | 208 |         | Yes      |       8 |
| utf8_esperanto_ci        | utf8     | 209 |         | Yes      |       8 |
| utf8_hungarian_ci        | utf8     | 210 |         | Yes      |       8 |
| utf8_sinhala_ci          | utf8     | 211 |         | Yes      |       8 |
| utf8_general_mysql500_ci | utf8     | 223 |         | Yes      |       1 |
| ucs2_general_ci          | ucs2     |  35 | Yes     | Yes      |       1 |
| ucs2_bin                 | ucs2     |  90 |         | Yes      |       1 |
| ucs2_unicode_ci          | ucs2     | 128 |         | Yes      |       8 |
| ucs2_icelandic_ci        | ucs2     | 129 |         | Yes      |       8 |
| ucs2_latvian_ci          | ucs2     | 130 |         | Yes      |       8 |
| ucs2_romanian_ci         | ucs2     | 131 |         | Yes      |       8 |
| ucs2_slovenian_ci        | ucs2     | 132 |         | Yes      |       8 |
| ucs2_polish_ci           | ucs2     | 133 |         | Yes      |       8 |
| ucs2_estonian_ci         | ucs2     | 134 |         | Yes      |       8 |
| ucs2_spanish_ci          | ucs2     | 135 |         | Yes      |       8 |
| ucs2_swedish_ci          | ucs2     | 136 |         | Yes      |       8 |
| ucs2_turkish_ci          | ucs2     | 137 |         | Yes      |       8 |
| ucs2_czech_ci            | ucs2     | 138 |         | Yes      |       8 |
| ucs2_danish_ci           | ucs2     | 139 |         | Yes      |       8 |
| ucs2_lithuanian_ci       | ucs2     | 140 |         | Yes      |       8 |
| ucs2_slovak_ci           | ucs2     | 141 |         | Yes      |       8 |
| ucs2_spanish2_ci         | ucs2     | 142 |         | Yes      |       8 |
| ucs2_roman_ci            | ucs2     | 143 |         | Yes      |       8 |
| ucs2_persian_ci          | ucs2     | 144 |         | Yes      |       8 |
| ucs2_esperanto_ci        | ucs2     | 145 |         | Yes      |       8 |
| ucs2_hungarian_ci        | ucs2     | 146 |         | Yes      |       8 |
| ucs2_sinhala_ci          | ucs2     | 147 |         | Yes      |       8 |
| ucs2_general_mysql500_ci | ucs2     | 159 |         | Yes      |       1 |
| cp866_general_ci         | cp866    |  36 | Yes     | Yes      |       1 |
| cp866_bin                | cp866    |  68 |         | Yes      |       1 |
| keybcs2_general_ci       | keybcs2  |  37 | Yes     | Yes      |       1 |
| keybcs2_bin              | keybcs2  |  73 |         | Yes      |       1 |
| macce_general_ci         | macce    |  38 | Yes     | Yes      |       1 |
| macce_bin                | macce    |  43 |         | Yes      |       1 |
| macroman_general_ci      | macroman |  39 | Yes     | Yes      |       1 |
| macroman_bin             | macroman |  53 |         | Yes      |       1 |
| cp852_general_ci         | cp852    |  40 | Yes     | Yes      |       1 |
| cp852_bin                | cp852    |  81 |         | Yes      |       1 |
| latin7_estonian_cs       | latin7   |  20 |         | Yes      |       1 |
| latin7_general_ci        | latin7   |  41 | Yes     | Yes      |       1 |
| latin7_general_cs        | latin7   |  42 |         | Yes      |       1 |
| latin7_bin               | latin7   |  79 |         | Yes      |       1 |
| utf8mb4_general_ci       | utf8mb4  |  45 | Yes     | Yes      |       1 |
| utf8mb4_bin              | utf8mb4  |  46 |         | Yes      |       1 |
| utf8mb4_unicode_ci       | utf8mb4  | 224 |         | Yes      |       8 |
| utf8mb4_icelandic_ci     | utf8mb4  | 225 |         | Yes      |       8 |
| utf8mb4_latvian_ci       | utf8mb4  | 226 |         | Yes      |       8 |
| utf8mb4_romanian_ci      | utf8mb4  | 227 |         | Yes      |       8 |
| utf8mb4_slovenian_ci     | utf8mb4  | 228 |         | Yes      |       8 |
| utf8mb4_polish_ci        | utf8mb4  | 229 |         | Yes      |       8 |
| utf8mb4_estonian_ci      | utf8mb4  | 230 |         | Yes      |       8 |
| utf8mb4_spanish_ci       | utf8mb4  | 231 |         | Yes      |       8 |
| utf8mb4_swedish_ci       | utf8mb4  | 232 |         | Yes      |       8 |
| utf8mb4_turkish_ci       | utf8mb4  | 233 |         | Yes      |       8 |
| utf8mb4_czech_ci         | utf8mb4  | 234 |         | Yes      |       8 |
| utf8mb4_danish_ci        | utf8mb4  | 235 |         | Yes      |       8 |
| utf8mb4_lithuanian_ci    | utf8mb4  | 236 |         | Yes      |       8 |
| utf8mb4_slovak_ci        | utf8mb4  | 237 |         | Yes      |       8 |
| utf8mb4_spanish2_ci      | utf8mb4  | 238 |         | Yes      |       8 |
| utf8mb4_roman_ci         | utf8mb4  | 239 |         | Yes      |       8 |
| utf8mb4_persian_ci       | utf8mb4  | 240 |         | Yes      |       8 |
| utf8mb4_esperanto_ci     | utf8mb4  | 241 |         | Yes      |       8 |
| utf8mb4_hungarian_ci     | utf8mb4  | 242 |         | Yes      |       8 |
| utf8mb4_sinhala_ci       | utf8mb4  | 243 |         | Yes      |       8 |
| cp1251_bulgarian_ci      | cp1251   |  14 |         | Yes      |       1 |
| cp1251_ukrainian_ci      | cp1251   |  23 |         | Yes      |       1 |
| cp1251_bin               | cp1251   |  50 |         | Yes      |       1 |
| cp1251_general_ci        | cp1251   |  51 | Yes     | Yes      |       1 |
| cp1251_general_cs        | cp1251   |  52 |         | Yes      |       1 |
| utf16_general_ci         | utf16    |  54 | Yes     | Yes      |       1 |
| utf16_bin                | utf16    |  55 |         | Yes      |       1 |
| utf16_unicode_ci         | utf16    | 101 |         | Yes      |       8 |
| utf16_icelandic_ci       | utf16    | 102 |         | Yes      |       8 |
| utf16_latvian_ci         | utf16    | 103 |         | Yes      |       8 |
| utf16_romanian_ci        | utf16    | 104 |         | Yes      |       8 |
| utf16_slovenian_ci       | utf16    | 105 |         | Yes      |       8 |
| utf16_polish_ci          | utf16    | 106 |         | Yes      |       8 |
| utf16_estonian_ci        | utf16    | 107 |         | Yes      |       8 |
| utf16_spanish_ci         | utf16    | 108 |         | Yes      |       8 |
| utf16_swedish_ci         | utf16    | 109 |         | Yes      |       8 |
| utf16_turkish_ci         | utf16    | 110 |         | Yes      |       8 |
| utf16_czech_ci           | utf16    | 111 |         | Yes      |       8 |
| utf16_danish_ci          | utf16    | 112 |         | Yes      |       8 |
| utf16_lithuanian_ci      | utf16    | 113 |         | Yes      |       8 |
| utf16_slovak_ci          | utf16    | 114 |         | Yes      |       8 |
| utf16_spanish2_ci        | utf16    | 115 |         | Yes      |       8 |
| utf16_roman_ci           | utf16    | 116 |         | Yes      |       8 |
| utf16_persian_ci         | utf16    | 117 |         | Yes      |       8 |
| utf16_esperanto_ci       | utf16    | 118 |         | Yes      |       8 |
| utf16_hungarian_ci       | utf16    | 119 |         | Yes      |       8 |
| utf16_sinhala_ci         | utf16    | 120 |         | Yes      |       8 |
| cp1256_general_ci        | cp1256   |  57 | Yes     | Yes      |       1 |
| cp1256_bin               | cp1256   |  67 |         | Yes      |       1 |
| cp1257_lithuanian_ci     | cp1257   |  29 |         | Yes      |       1 |
| cp1257_bin               | cp1257   |  58 |         | Yes      |       1 |
| cp1257_general_ci        | cp1257   |  59 | Yes     | Yes      |       1 |
| utf32_general_ci         | utf32    |  60 | Yes     | Yes      |       1 |
| utf32_bin                | utf32    |  61 |         | Yes      |       1 |
| utf32_unicode_ci         | utf32    | 160 |         | Yes      |       8 |
| utf32_icelandic_ci       | utf32    | 161 |         | Yes      |       8 |
| utf32_latvian_ci         | utf32    | 162 |         | Yes      |       8 |
| utf32_romanian_ci        | utf32    | 163 |         | Yes      |       8 |
| utf32_slovenian_ci       | utf32    | 164 |         | Yes      |       8 |
| utf32_polish_ci          | utf32    | 165 |         | Yes      |       8 |
| utf32_estonian_ci        | utf32    | 166 |         | Yes      |       8 |
| utf32_spanish_ci         | utf32    | 167 |         | Yes      |       8 |
| utf32_swedish_ci         | utf32    | 168 |         | Yes      |       8 |
| utf32_turkish_ci         | utf32    | 169 |         | Yes      |       8 |
| utf32_czech_ci           | utf32    | 170 |         | Yes      |       8 |
| utf32_danish_ci          | utf32    | 171 |         | Yes      |       8 |
| utf32_lithuanian_ci      | utf32    | 172 |         | Yes      |       8 |
| utf32_slovak_ci          | utf32    | 173 |         | Yes      |       8 |
| utf32_spanish2_ci        | utf32    | 174 |         | Yes      |       8 |
| utf32_roman_ci           | utf32    | 175 |         | Yes      |       8 |
| utf32_persian_ci         | utf32    | 176 |         | Yes      |       8 |
| utf32_esperanto_ci       | utf32    | 177 |         | Yes      |       8 |
| utf32_hungarian_ci       | utf32    | 178 |         | Yes      |       8 |
| utf32_sinhala_ci         | utf32    | 179 |         | Yes      |       8 |
| binary                   | binary   |  63 | Yes     | Yes      |       1 |
| geostd8_general_ci       | geostd8  |  92 | Yes     | Yes      |       1 |
| geostd8_bin              | geostd8  |  93 |         | Yes      |       1 |
| cp932_japanese_ci        | cp932    |  95 | Yes     | Yes      |       1 |
| cp932_bin                | cp932    |  96 |         | Yes      |       1 |
| eucjpms_japanese_ci      | eucjpms  |  97 | Yes     | Yes      |       1 |
| eucjpms_bin              | eucjpms  |  98 |         | Yes      |       1 |
+--------------------------+----------+-----+---------+----------+---------+
197 rows in set (0.00 sec)

##mysql的SQL模型：
违反了SQL规定时进行SQL模型设置
mysql的mysql模型：
	1. ANSI QUOTES
	2. IGNORE_SPACE
	3. STRICT_ALL_TABLES
	4. STRICT_TRANS_TABLES
	5. TRADITIONAL
mysql> show global variables like 'sql_mode'; #查看服务器模型
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| sql_mode      |       |
+---------------+-------+

MYSQL服务器变量：
	作用域：
	1. 全局变量 #服务一启动时启动，show global variables; 
	2. 会话变量  #用户连入mysql时设置的变量，当连接断掉时会话变量也会断掉, show [session] variables;
#注意：全局变量和会话变量类似/etc/my.cnf和~/.my.cnf，后者可覆盖前者
生效时间分为两类：
	动态：可即时修改，即时生效。
	静态：写在配置文件中，有的不能写在配置文件时通过参数传递给mysqld或mysql_safe
动态调整参数的生效方式：
	全局变量：对当前会话无效，只对新建立会话生效，类似/etc/profile一样，重新建立shell才生效
	会话变量：即时生效，但只对当前会话有效。会话断掉即失效。
#注：默认会话变量从全局变量继承的

服务器变量：@@变量名或@@global变量名
	显示：select
	设定：set global|session 变量名='value'


mysql> select  @@global.sql_mode; #查看全局变量mysql的mode
+-------------------+
| @@global.sql_mode |
+-------------------+
|                   |
+-------------------+
mysql> set global sql_mode='strict_all_tables'; #设置全局变量sql mode
mysql> select @@global.sql_mode; 查看全局变量mode
+-------------------+
| @@global.sql_mode |
+-------------------+
| STRICT_ALL_TABLES |
+-------------------+
mysql> select @@sql_mode;
+------------+
| @@sql_mode |
+------------+
|            |
+------------+
#注：全局变量只对下次登入时生效，对当前会话不生效。局部变量对当前会话生效，会话断掉时失效。

#第六节：MYSQL管理表和索引
#新建数据库：
help create database #获取帮助信息
mysql> create schema students character set 'utf8' collate utf8_general_ci;
alter database  #修改数据库
drop database  #删除数据库
#新建表：
1. 直接定义一张空表
2. 从其它表中查询出数据，并以之创建新表内容
3. 以其它表为模板创建一个空表
help create table  #获取帮助信息
create table courses(CID TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,Course VARCHAR(50) NOT NULL，Age TINYINT,PRIMARY KEY(CID),UNIQUE KEY(Course),INDEX(Age)); #另外一种设立主键方法
#键也称为约束，可用作索引，属于特殊索引（有特殊限定）：是BTree结构，另外一种结构为HASH结构
#第一种创建表的方法
mysql> create table courses(CID TINYINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,Couse VARCHAR(50) NOT NULL); #新建表
mysql> show table status from students like 'courses'\G; #查看表状态
*************************** 1. row ***************************
           Name: courses
         Engine: InnoDB #不指定存储引擎默认从数据库继承
        Version: 10
     Row_format: Compact
           Rows: 0
 Avg_row_length: 0
    Data_length: 16384
Max_data_length: 0
   Index_length: 0
      Data_free: 0
 Auto_increment: 1
    Create_time: 2019-06-19 22:31:48
    Update_time: NULL
     Check_time: NULL
      Collation: utf8_general_ci
       Checksum: NULL
 Create_options: 
        Comment: 
1 row in set (0.00 sec)
mysql> drop table courses; #删除表
mysql> create table courses(CID TINYINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,Couse VARCHAR(50) NOT NULL)ENGINE MyISAM; #新建表并设立存储引擎MyISAM
mysql> show table status like 'courses'\G';
*************************** 1. row ***************************
           Name: courses
         Engine: MyISAM #MyISAM存储引擎
        Version: 10
     Row_format: Dynamic
           Rows: 0
 Avg_row_length: 0
    Data_length: 0
Max_data_length: 281474976710655
   Index_length: 1024
      Data_free: 0
 Auto_increment: 1
    Create_time: 2019-06-19 22:34:32
    Update_time: 2019-06-19 22:34:32
     Check_time: NULL
      Collation: utf8_general_ci
       Checksum: NULL
 Create_options: 
        Comment: 
mysql> insert into courses (Couse) value ('hamagong'),('pixiejianfa'),('kuihuabaodian');
mysql> select * from courses;
+-----+---------------+
| CID | Couse         |
+-----+---------------+
|   1 | hamagong      |
|   2 | pixiejianfa   |
|   3 | kuihuabaodian |
+-----+---------------+
mysql> show index from courses; #显示表的索引
+---------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table   | Non_unique | Key_name | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+---------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| courses |          0 | PRIMARY  |            1 | CID         | A         |           3 |     NULL | NULL   |      | BTREE      |         |               |
+---------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
                                                  #CID为索引
#第二种创建表的方法
mysql> create table testcourses select * from courses where CID <= 3;
mysql> desc testcourses; #通过查询新建的表表结构也会发生改变
+-------+---------------------+------+-----+---------+-------+
| Field | Type                | Null | Key | Default | Extra |
+-------+---------------------+------+-----+---------+-------+
| CID   | tinyint(3) unsigned | NO   |     | 0       |       |
| Couse | varchar(50)         | NO   |     | NULL    |       |
+-------+---------------------+------+-----+---------+-------+
mysql> desc courses;
+-------+---------------------+------+-----+---------+----------------+
| Field | Type                | Null | Key | Default | Extra          |
+-------+---------------------+------+-----+---------+----------------+
| CID   | tinyint(3) unsigned | NO   | PRI | NULL    | auto_increment |
| Couse | varchar(50)         | NO   |     | NULL    |                |
+-------+---------------------+------+-----+---------+----------------+
#第三种创建表的方法
mysql> create table test like courses; #复制表的结构为空表
mysql> desc courses;
+-------+---------------------+------+-----+---------+----------------+
| Field | Type                | Null | Key | Default | Extra          |
+-------+---------------------+------+-----+---------+----------------+
| CID   | tinyint(3) unsigned | NO   | PRI | NULL    | auto_increment |
| Couse | varchar(50)         | NO   |     | NULL    |                |
+-------+---------------------+------+-----+---------+----------------+
mysql> desc test;
+-------+---------------------+------+-----+---------+----------------+
| Field | Type                | Null | Key | Default | Extra          |
+-------+---------------------+------+-----+---------+----------------+
| CID   | tinyint(3) unsigned | NO   | PRI | NULL    | auto_increment |
| Couse | varchar(50)         | NO   |     | NULL    |                |
+-------+---------------------+------+-----+---------+----------------+
mysql> insert into test select * from courses; #复制表数据
mysql> select * from courses;
+-----+---------------+
| CID | Couse         |
+-----+---------------+
|   1 | hamagong      |
|   2 | pixiejianfa   |
|   3 | kuihuabaodian |
+-----+---------------+
mysql> select * from test;
+-----+---------------+
| CID | Couse         |
+-----+---------------+
|   1 | hamagong      |
|   2 | pixiejianfa   |
|   3 | kuihuabaodian |
+-----+---------------+
#ALTER修改表
help alter table #查看修改帮助
BTREE索引和HASH索引对表查询优化有很大影响
mysql> create table student(SID INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY ,Name varchar(30) NOT NULL,CID TINYINT UNSIGNED NOT NULL);
mysql> desc courses;
+-------+---------------------+------+-----+---------+----------------+
| Field | Type                | Null | Key | Default | Extra          |
+-------+---------------------+------+-----+---------+----------------+
| CID   | tinyint(3) unsigned | NO   | PRI | NULL    | auto_increment |
| Couse | varchar(50)         | NO   |     | NULL    |                |
+-------+---------------------+------+-----+---------+----------------+
mysql> desc student;
+-------+---------------------+------+-----+---------+----------------+
| Field | Type                | Null | Key | Default | Extra          |
+-------+---------------------+------+-----+---------+----------------+
| SID   | int(10) unsigned    | NO   | PRI | NULL    | auto_increment |
| CID   | tinyint(3) unsigned | NO   | MUL | NULL    |                |
| name  | varchar(30)         | NO   |     | NULL    |                |
+-------+---------------------+------+-----+---------+----------------+
mysql> insert into student (Name,CID) values ('zwj',2),('lhc',3);
mysql> select * from student;
+-----+-----+------+
| SID | CID | name |
+-----+-----+------+
|   1 |   2 | zwj  |
|   2 |   3 | lhc  |
+-----+-----+------+
mysql> select Name,Couse from courses,student where courses.CID=student.CID;  #多表查询
+------+---------------+
| Name | Couse         |
+------+---------------+
| zwj  | pixiejianfa   |
| lhc  | kuihuabaodian |
+------+---------------+
mysql> insert into student (Name,CID) values ('zhangwuji',5); #现在这个student表没有外键约束所以可以插入主表中没有的CID
#建立外键：
mysql> alter table student add FOREIGN KEY(CID) REFERENCES courses(CID) ;  #插入外键时报错，原因在于外键不允许在除InnoDB外的所有存储引擎上使用
ERROR 1005 (HY000): Can't create table 'students.#sql-63d8_9' (errno: 150)
mysql> show table status like 'student'\G;
*************************** 1. row ***************************
           Name: student
         Engine: InnoDB
        Version: 10
     Row_format: Compact
           Rows: 3
 Avg_row_length: 5461
    Data_length: 16384
Max_data_length: 0
   Index_length: 0
      Data_free: 0
 Auto_increment: NULL
    Create_time: 2019-06-20 08:56:54
    Update_time: NULL
     Check_time: NULL
      Collation: utf8_general_ci
       Checksum: NULL
 Create_options: 
        Comment: 
mysql> show table status like 'courses'\G;
*************************** 1. row ***************************
           Name: courses
         Engine: MyISAM   #因为主键表是MyISAM存储引擎的
        Version: 10
     Row_format: Dynamic
           Rows: 3
 Avg_row_length: 20
    Data_length: 60
Max_data_length: 281474976710655
   Index_length: 2048
      Data_free: 0
 Auto_increment: 4
    Create_time: 2019-06-19 22:34:32
    Update_time: 2019-06-19 22:45:38
     Check_time: NULL
      Collation: utf8_general_ci
       Checksum: NULL
 Create_options: 
        Comment: 
mysql> alter table courses ENGINE=InnoDB; #更改表存储引擎
mysql> alter table student add FOREIGN KEY foreign_id (CID) REFERENCES courses (CID) ; 
mysql> insert into student (Name,CID) values ('zhangwuji',6); #此时报错，因为有外键限制
ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails (`students`.`student`, CONSTRAINT `student_ibfk_1` FOREIGN KEY (`CID`) REFERENCES `courses` (`CID`))
mysql> insert into student (Name,CID) values ('zhangwuji',1); #这个主键有，所以成功
#索引：
索引只能增加、查询、删除，不能修改索引。
mysql> show indexes from student;
+---------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table   | Non_unique | Key_name   | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+---------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| student |          0 | PRIMARY    |            1 | SID         | A         |           2 |     NULL | NULL   |      | BTREE      |         |               |
| student |          1 | foreign_id |            1 | CID         | A         |           2 |     NULL | NULL   |      | BTREE      |         |               |
+---------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
mysql> create index name_on_student on student (name) using btree; #新建索引并使用btree索引，默认是btree索引，可以省略不写
mysql> show indexes from student;
+---------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table   | Non_unique | Key_name        | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+---------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| student |          0 | PRIMARY         |            1 | SID         | A         |           2 |     NULL | NULL   |      | BTREE      |         |               |
| student |          1 | foreign_id      |            1 | CID         | A         |           2 |     NULL | NULL   |      | BTREE      |         |               |
| student |          1 | name_on_student |            1 | name        | A         |           2 |     NULL | NULL   |      | BTREE      |         |               |
+---------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
mysql> drop index name_on_student on student; #删除索引
mysql> create index name_on_student on student (name(5) desc) using btree; #新建索引并且只引用从左到右五位，后面的不参加索引，可能节约资源有很大帮助，desc是降序，asc是升序。

#第七节：单表查询、多表查询和子查询
查询语句类型：
	1. 简单查询
	2. 多表查询
	3. 子查询
select语句：投影、选择、别名
SELECT DISTINCT Gender FROM students;  #Gender中有好多M和F行，这条语句查出来结果只显示两行，一行为M一行为F，只显示不同行的,去重

#简单查询
FROM子句：要查询的关系，可以是表、多个表、其它SELECT语句
WHERE子句：布尔关系表达式，判断是否的，=、>、>=、<、<=、<>|!=、<=>  #<=>是对空值时运行比较的，而<>|!=是对所有数据进行比较的
逻辑关系：AND,OR,NOT，BETWEEN，LIKE(_单个字符，%任意字符),REGEXP|RLIKE(正则表达式)，IN，IS NULL|NOT NULL,AS，LIMIT
排序：ORDER BY field_name {ASC|DESC} #默认是ASC升序
聚合：AVG(age),MAX(age),MIN(age),SUM(age),COUNT(age),
分组：GROUP BY，HAVING(对使用分组的语句最后再进行一次筛选)

##SELECT语句样例：
SELECT Name,Age FROM students WHERE Age<=25 AND Age>=20; #查询20到25的用户
SELECT Name,Age FROM students WHERE Age BETWEEN 20 AND 25; #查询20到25之间
SELECT Name FROM students WHERE Name LIKE '%ing%' #模糊搜索
SELECT Name FROM students WHERE Name RLIKE '^[XP].*$'; #以正则表达式模糊搜索
SELECT Name FROM students WHERE Age IN (18,20,25); #查找年龄为18，20，25的用户
SELECT Name FROM students WHERE CID2 IS NULL; #查询课程2为家的用户
SELECT Name FROM students WHERE CID2 IS NULL ORDER BY Name DESC; #降序排序
SELECT Name AS Student_Name FROM students; #将显示的字段Name重合名为Student_Name
SELECT Name FROM students LIMIT 2; #显示前两行
SELECT Name FROM students LIMIT 2，3;  #从最前面偏移两个，第三个开始显示3行
SELECT Avg(Age) FROM students GROUP BY Gender; #先对Gender进行分组，然后对每个分组进行求平均值
SELECT COUNT(CID1) AS Persons,CID1 FROM students GROUP BY CID1 HAVING Persons>=2; #查找分组CID1课程的每门人数，并最后使用HAVING进行筛选大于等于2个人的，也可以在关联查询中使用别名进行查询

mysql> SELECT 2+1;
+-----+
| 2+1 |
+-----+
|   3 |
+-----+
mysql> SELECT 2+1 AS sum;
+-----+
| sum |
+-----+
|   3 |
+-----+

#复合查询或多表查询：
多表查询：
	连接：
		1. 交叉连接：笛卡尔乘积（不会这样使用）
		2. 自然连接：建立主外键关系进行查询，有的才显示，没有的不显示
		3. 外连接：有的显示值，没有的显示NULL，建立在自然连接基础之上
			1. 左外连接：... LEFT JOIN ... ON ... #省略号依次为左表，右表，条件，以左表为基准
			2. 右外连接：... RIGHT JOIN ... ON ...#省略号依次为左表，右表，条件，在名表为基准
		4. 自连接：对同一张表当作两张表进行查询

SELECT s.Name,c.Cname FROM students AS s,courses AS c WHERE s.CID1=c.CID; #自然连接并给表取别名
SELEECT s.Name,c.Cname FROM students AS s LEFT JOIN courses AS c ON s.CID1=c.CID;  #左外连接，以左表为基准，右表有值的显示，无值的也显示，显示为NULL
SELEECT s.Name,c.Cname FROM students AS s RIGHT JOIN courses AS c ON s.CID1=c.CID;  #右外连接，以右表为基准，左表有值的显示，无值的也显示，显示为NULL
SELECT c.Name AS student,s.Name AS tearcher FROM students AS c,student AS s WHERE c.TID=s.SID; #自连接

#子查询：
子查询：比较操作中使用时只能返回单个值
IN():在IN中使用子查询
在FROM中使用子查询
例：
SELECT Name FROM students WHERE Age > (SELECT AVG(Age) FROM students); #子查询，查询年龄大于平均年龄的用户
SELECT Name FROM students WHERE Age IN (SELECT Age FROM students);
SELECT Name,Age FROM (SELECT Name,Age FROM students) AS t WHERE t.Age >= 20; #将子查询看作一张临时表

#联合查询：UNION关键字
（SELECT Name,Age FROM students) UNION (SELECT Tname,Age FROM tutors); #联合查询
#第八节：多表查询、子查询及视图
SELECT Tname FROM tutors WHERE TID NOT IN (SELECT DISTINCT TID FROM courses); #从tutors表找出TID不在courses表上的老师名
SELECT CID1 FROM students GROUP BY CID1 HAVING COUNT(CID1) >=2; #找出学习的课程大于等于2的CID1
SELECT Cname FROM courses WHERE CID IN (SELECT CID1 FROM students GROUP BY CID1 HAVING COUNT(CID1) >=2); #对找出大于等于2的CID1进行显示课程名称
SELECT Name,Cname,Tname FROM students,courses,tutors WHERE students.CID1=courses.CID AND courses.TID=tutors.TID; #从学生表，老师表，课程表中查询每个学生所学的课以及对应的老师

#视图：存储下来的SELECT语句
help create view #获取新建视图帮助
CREATE VIEW sct AS SELECT Name,Cname,Tname FROM students,courses,tutors WHERE students.CID1=courses.CID AND courses.TID=tutors.TID; #新建视图为sct,视图结果为AS后面的查询结果
SHOW TABLES;  #这时可以查看新建下来的视图sct,会变成一张表存储
物化视图：将视图保存在文件中，但是在基表上插入数据时物化视图不会更新，所以在不常变的视图上才物化视图。
注：一般不允许在视图上插入数据，可以在基表上插入数据，此时视图会跟着改变，但只做为临时表用。所以会比较慢，在mysql上一般不用，只在安全需要时会筛选特定字段展示给用户。mysql视图上不能许使用索引，mysql不支持物化视图。
SHOW CREATE VIEW sct;  #查看视图sct创建时使用了什么语句
SHOW CREATE TABLE courses; #查看表创建时使用了什么样的语句

mysql -e 'CREATE DATABASE edb;'  #在bash上新建数据库，-e选项
mysql -e 'SHOW DATABASES;'  #在bash上查看数据库

#第九节：MYSQL事务与隔离级别
广义查询：SELECT,INSERT,UPDATE,DELETE
insert批量插入会提高性能的
字符串：单引号
数据型：不需要引号
日期和时间：不需要引号
空值：NULL
auto_increment自增长，在表中删除某些行，计数器不会填补删除的空行数据，而是继续使用之前的顺序新增，除非你更改LAST_INSERT_ID()值。

#insert:
insert into students (col1,col2) value (val1,val2),...;#批量插入
insert into students set Tname='tom',Age=16; #特定插入
insert into students (col1,col2,...) select  #查询插入
#replace:跟insert语句一样，表示未有数据和有数据时都使用，而insert插入数据有约束时不会插入

#delete
例：DELETE FROM tb_name WHERE condition;
mysql有内部参数可以限制delete from tb_name 和 update tb_name set cou=val 误操作的。
delete from tb_name #会删除表所有数据但不清空AUTOINCREMENT计数器
TRUNCATE tb_name:清空表并重置AUTOINCREMENT计数器;

#update
update tb_name set cou=val where id=1 ;

##mysql连接执行流程：
1. 连接管理器
2. 缓存管理器（只对查询有用，返回结果给用户），分析管理器(分析语句，如有查询则去缓存管理器取，无则去优化器优化语句)
3. 优化器
4. 执行引擎（执行语句）
5. 存储引擎（将语句解析为块语言）
注：mysql是明文的，密文需要借助ssl

并发控制：两个以上访问会出现并发控制
多版本并发控制:MVCC,数据库必备的功能

锁：
	读锁：共享锁
	写锁：独占锁
		LOCK TABLES tb_name READ|WRITE
		UNLOCK TABLES
锁粒度：从大到小，MYSQL服务器仅支持表级锁，行锁需要存储引擎完成
	表锁：锁定一个表
	页锁：mysql存储是分页的
	行锁：锁定一行
注：mysql自己内部会处理锁，我们不用人为去加锁，只是使用温备份时才加锁。
mysql> lock tables student read; #会话1为表student加共享锁
mysql> select * from student; #会话2可读
+-----+------+------+
| SID | CID  | name |
+-----+------+------+
|   1 |    2 | zwj  |
|   2 |    3 | lhc  |
|   8 |    1 | tom  |
|   9 |   10 | jack |
+-----+------+------+
mysql> insert student (CID,name) values (11,'candy'); #此会会话2插入数据时会卡住，等待锁释放后才可插入

mysql> unlock tables; #会话1解除锁
Query OK, 0 rows affected (0.00 sec)
mysql> insert student (CID,name) values (11,'candy'); #此时才插入成功，耗时44秒
Query OK, 1 row affected (44.01 sec)

#####事务
RDBMS: ACID(原子性，一致性，隔离性，持久性) #支持事务必须支持这4个特性
		Automicity,Consistency,Isolation,Durability
事务日志：
	1. 重做日志  #叫redo log
	2. 撤销日志  #叫undo log
事务流程：
 1. 提交事务
 2. 写入事务日志 #当提交事务全部操作未完全写入事务日志时，mysql服务重新启动时会读取撤销日志进行撤销，否则会写入数据库。
 3. 写入数据库 #当写入数据库操作时服务崩溃，mysql服务重新启用后会读取重做日志进行重新写入数据库
注：事务日志不是越大越好，越大表示同步到磁盘越慢
隔离性：
	隔离级别：
		READ-UNCOMMITTED   #读未提交，最低隔离级别
		READ-COMMITTED    #读提交
		REPEATABLE-READ   #可重读（默认隔离级别）
		SERIALIZABLE    #可串行
mysql> show global variables like '%iso%'; #查看mysql隔离级别
+---------------+-----------------+
| Variable_name | Value           |
+---------------+-----------------+
| tx_isolation  | REPEATABLE-READ |
+---------------+-----------------+

服务器变量：
	全局变量(global)：
		对全局生效，新建会话时才生效
	会话变量（session）：
		对当前会话生效，立即生效
	注：但重启服务后失败，要想永久生效必须写入文件
mysql> show global variables like '%iso%'; #全局变量默认级别
+---------------+-----------------+
| Variable_name | Value           |
+---------------+-----------------+
| tx_isolation  | REPEATABLE-READ |
+---------------+-----------------+
mysql> show variables like '%iso%'; #会话变量默认级别
+---------------+-----------------+
| Variable_name | Value           |
+---------------+-----------------+
| tx_isolation  | REPEATABLE-READ |
+---------------+-----------------+
mysql> set tx_isolation='READ-UNCOMMITTED'; #设置隔离级别
mysql> show variables like '%iso%'; #不知道全名时可使用show进行展示
+---------------+------------------+
| Variable_name | Value            |
+---------------+------------------+
| tx_isolation  | READ-UNCOMMITTED |
+---------------+------------------+
mysql> select @@tx_isolation; #知道全名时可用select展示
+------------------+
| @@tx_isolation   |
+------------------+
| READ-UNCOMMITTED |
+------------------+

#第十节：事务和隔离级别
RDBMS: ACID(原子性，一致性，隔离性，持久性)
	Automicity 原子性：事务所引起的数据库操作，要么都完成，要么都不执行
	Consistency 一致性：两都事务前后状态一致
	Isolation 隔离性：
					事务调度：事务之间影响最小
					MVCC:多版本并发控制
	Durability 持久性：一旦事务成功完成，系统必须保证任何故障都不会引起事务表示出不一致性
		1. 事务提交之前就已经写出数据至持久性存储
		2. 结合事务日志完成
			1. 事务日志：写入时是顺序IO
			2. 数据文件：写入时是随机IO
事务的状态：
	1. 活动的：active
	2. 部分提交的：最后一条语句执行后部分已经提交成功的
	3. 失败的
	4. 中止的
	5. 提交的
事务允许并发执行：
	1. 提高吞吐量和资源利用率
	2. 减少等待时间
事务调度：	
	1. 可恢复调度
	2. 无级联调度
调度级别：
	1. READ-UNCOMMITTED #读未提交
	2. READ-COMMITTED #读提交
	3. REPEATABLE-READ #可重读  MYSQL默认这个，大多数RDBMS是第2个读提交
	4. SERIALIZABLE #可串行
并发控制依赖的技术手段：
	1. 锁
	2. 时间戳
	3. 多版本和快照隔离

SQL语句或者ODBC的命令 
START TRANSACTION  #启动事务
	SQL 1
	SQL 2 
	......
COMMIT  #提交事务，使用事务日志的重做日志进行写入持久存储设备
ROLLBACK  #未提交事务前可使用此命令进行回滚撤销，使用事务日志的撤销日志进行回滚
mysql> select @@autocommit; #如果没有明确启动事务，自动提交是开启的
+--------------+
| @@autocommit |
+--------------+
|            1 |
+--------------+
建议：在事务性数据库上，手动明确使用事务，并且关闭自动提交，这样可以减少数据库io的
mysql> set autocommit=0； #此时关闭自动提交功能，在使用select语句后需要使用commit提交才可写入持久性存储
mysql> set global autocommit=0; #这个是设置全局变量的自动提交 
mysql> select @@autocommit;
+--------------+
| @@autocommit |
+--------------+
|            0 |
+--------------+
保存点：SAVEPOINT  #在事务中使用
SAVEPOINT a; #建立一个保存点
ROLLBACK TO a;  #回滚到保存点a
例：
mysql> select * from student;
+-----+------+-------+
| SID | CID  | name  |
+-----+------+-------+
|   1 |    2 | zwj   |
|   2 |    3 | lhc   |
|   8 |    1 | tom   |
|   9 |   10 | jack  |
|  10 |   11 | candy |
+-----+------+-------+
mysql> select @@autocommit;
+--------------+
| @@autocommit |
+--------------+
|            0 |
+--------------+
mysql> delete from student where SID=10;
mysql> savepoint a;
mysql> delete from student where SID=9;
mysql> savepoint b;
mysql> select * from student;
+-----+------+------+
| SID | CID  | name |
+-----+------+------+
|   1 |    2 | zwj  |
|   2 |    3 | lhc  |
|   8 |    1 | tom  |
+-----+------+------+
mysql> rollback to a;  #回滚到某个保存点
mysql> select * from student;
+-----+------+------+
| SID | CID  | name |
+-----+------+------+
|   1 |    2 | zwj  |
|   2 |    3 | lhc  |
|   8 |    1 | tom  |
|   9 |   10 | jack |
+-----+------+------+
####验证隔离级别：
先启动两个mysql会话：
1. SET tx_isolation=READ-UNCOMMITTED(读未提交);两个会话隔离性都为读未提交时，当一个会话启动事务进行增删改操作时，未使用COMMIT提交，另外一个会话也会看到同样的结果，这就是读未提交隔离的效果。但是会产生幻影问题
2. SET tx_isolation=READ-COMMITTED(读提交);两个会话隔离性都为读提交时，当一个会话启动事务进行增删改操作时，使用COMMIT提交，另外一个会话也会看到同样的结果，这就是读提交隔离的效果。如果未提交则另外一个会话看不到改变的数据，但是提交后会产生幻影问题
3. SET tx_isolation=REPEATABLE-READ(可重读);两个会话隔离性都为可重读时，当一个会话启动事务进行增删改操作时，使用COMMIT提交，另外一个会话不会看到同样的结果，此时另外一个会话看到的一直都是另外会话自己看到的结果，当另外一个会话也COMMIT时才会看到当前同样的结果，这就是可重读隔离的效果。但是会产生幻影问题
4. SET tx_isolation=SEREALABLE(可串行);两个会话隔离性都为可串行时，当一个会话启动事务进行增删改操作时，未使用COMMIT提交，另外一个会话查询时不会有任何结果显示且会卡住查询会话，当当前会话COMMIT时，另外一个会话查询才会有结果显示。
#注：如果不是银行证券行业，可以适当降低隔离级别，提升性能是相当明显的

#第十一节：MYSQL用户和权限管理
用户：只是认证
权限：是用来授权用户访问数据库的权限
#mysqld服务启动时会加载mysql数据库中user,db,tables_priv,columns_priv,procs_priv,proxies_priv 6张表并生成一张授权表到内存当中。
user表：用户帐号、全局权限 
db表：库级别权限
tables_priv表：表级别权限
columns_priv表：列级别权限 
procs_priv：存储过程和存储函数相关的权限 
proxies+_priv:代理用户权限

#用户帐号：用户名@主机	
权限级别：
	1. 全局级别：super(可查看设置全局变量的权限)
	2. 库：
	3. 表：delete,alter
	4. 列：select,insert,update
	5. 存储过程和存储函数

临时表：存储在内存中，执行快，heap:16M大小 
触发器：主动数据库，在mysql上执行某些操作时触发另外一个动作的
--skip-grant-tables --skip-networking#跳过授权表,并且关闭网络连接
--skip-name-resolve #跳过名称解析

create user jack@'%' identified by '123';这个命令新建用户mysql自动触发刷新特权表
mysql> show grants for jack@"%"; #查看某个用户权限，这个用户默认只有usage权限
+-----------------------------------------------------------------------------------------------------+
| Grants for jack@%                                                                                   |
+-----------------------------------------------------------------------------------------------------+
| GRANT USAGE ON *.* TO 'jack'@'%' IDENTIFIED BY PASSWORD '*23AE809DDACAF96AF0FD78ED04B6A265E05AA257' |
+-----------------------------------------------------------------------------------------------------+

GRANT ALL PRIVILEGES ON [object_type] db.* TO username@'%'; #[object_type]：TABLE,FUNCTION,PROCEDURE
GRANT EXECUTE ON FUNCTION db.abc TO username@'%'; #授权db.abc存储函数执行权限给某个用户。
with_option:
    GRANT OPTION  #可以把权限授权给其他用户的权限 
  | MAX_QUERIES_PER_HOUR count  #每小时最大查询数，为0则为不限制，其大正数为限定值，下面也一样
  | MAX_UPDATES_PER_HOUR count  #每小时最大更新数
  | MAX_CONNECTIONS_PER_HOUR count #每小时用户最大连接数
  | MAX_USER_CONNECTIONS count #用户最大连接数

GRANT UPDATE(Age) ON db.abc TO username@'%'; #授权更新某个表某个字段权限给用户
#REVOKE
REVOKE SELECT ON cactidb.* FROM cactiuser@'%';
##找回root密码：在mysql脚本中编辑启动脚本段，设置启动mysql_safe时传递两个参数 --skip-grant-tables --skip-networking ，也可在/etc/my.cnf中[mysqld]字段写入，然后启动mysqld服务，update user表更改密码，关闭mysqld服务，删除刚刚设置的 --skip-grant-tables --skip-networking两个参数，并重启服务即可。

#第十二节：MYSQL日志管理一
mysql> show global variables like '%log%';
#错误日志：log_warnings，log_error #默认开启的
	1. mysql服务器启动和关闭过程中的信息
	2. mysql服务器运行过程中的错误信息
	3. 事件调度器运行一个事件时产生的信息
	4. 在从服务器上启动从服务器进行时产生的信息
	
#一般查询日志：general_log，general_log_file，log,log_output[TABLE|FILE|NONE]可以设定在mysql表中，sql_log_off（用于控制是否禁止将一般查询日志类信息记录进查询日志文件）   #不建议开启                        
#慢查询日志：long_query_time，log_slow_queries|slow_query_log，slow_query_log_file，log_output[TABLE|FILE|NONE] #建议开启，日志输出可以同时输出TABLE,FILE中
mysql> show global variables like '%long_quer%';
+-----------------+-----------+
| Variable_name   | Value     |
+-----------------+-----------+
| long_query_time | 10.000000 |
+-----------------+-----------+
#二进制日志：任何引起或可能引起数据库变化的操作     #必须开启
	binlog_format=MIXED 
	log_bin（设置日志开关并且设置二进制文件路径）
	sql_log_bin（二进制日志文件开关，当以后恢复备份时需要临时把二进制日志文件关闭，完成后恢复）
	binlog_cache_size(大小取决于binlog_stmt_cache_size)
	binlog_stmt_cache_size（二进制文件语句缓存大小）
	sync_binlog（设置对二进制每多少次写操作后同步一次，0表示不同步）
	expire_logs_days：设置二进制日志过期天数
	滚动记录日志，mysqld启动时也会滚动记录日志
	复制、即时点恢复：
		mysqlbinlog,查看二进制日志命令
	二进制日志的格式：
		基于语句：statement
		基于行：row
		混合方式：mixed
	二进制日志事件：
		产生的时间，datetime
		位置,position
	二进制日志文件：
		索引文件
		二进制日志文件
	查看当前正在使用的二进制日志文件：
	mysql> SHOW MASTER STATUS ;
+------------------+----------+--------------+------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+------------------+----------+--------------+------------------+
| mysql-bin.000009 |  1132572 |              |                  |
+------------------+----------+--------------+------------------+
mysql> show binlog events in 'mysql-bin.000003';
+------------------+-----+-------------+-----------+-------------+---------------------------------------+
| Log_name         | Pos | Event_type  | Server_id | End_log_pos | Info                                  |
+------------------+-----+-------------+-----------+-------------+---------------------------------------+
| mysql-bin.000003 |   4 | Format_desc |         1 |         107 | Server ver: 5.5.37-log, Binlog ver: 4 |
| mysql-bin.000003 | 107 | Stop        |         1 |         126 |                                       |
+------------------+-----+-------------+-----------+-------------+---------------------------------------+
	SHOW BINLOG EVENTS IN 'mysql-bin.000009' [FROM pos]; #详细查看二进制日志文件事件的信息
	mysqlbinlog命令：
		--start-datetime 'yyyy-mm-dd hh:mm:ss'
		--stop-datetime 'yyyy-mm-dd hh:mm:ss'
		--start-position
		--stop-position
	[root@lnmp mydata]# mysqlbinlog --start-position=220554 --stop-position=223392 mysql-bin.000009 > /root/a.sql #查看起始位置到结束位置的日志并导出到sql脚本上，另外mysql数据库导入即可恢复
	mysql> flush logs; #滚动二进制日志和从服务器中继日志的命令
mysql> show master status ;
+------------------+----------+--------------+------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+------------------+----------+--------------+------------------+
| mysql-bin.000010 |      107 |              |                  |
+------------------+----------+--------------+------------------+
	mysql> show binary logs; #查看当前保存下来的二进制文件
+------------------+-----------+
| Log_name         | File_size |
+------------------+-----------+
| mysql-bin.000001 |     26636 |
| mysql-bin.000002 |   1069399 |
| mysql-bin.000003 |       126 |
| mysql-bin.000004 |       126 |
| mysql-bin.000005 |       737 |
| mysql-bin.000006 |       126 |
| mysql-bin.000007 |       126 |
| mysql-bin.000008 |       126 |
| mysql-bin.000009 |   1132615 |
| mysql-bin.000010 |       107 |
+------------------+-----------+
mysql> purge binary logs to 'mysql-bin.000003'; #删除指定日志文件以前所有的二进制日志文件
mysql> show binary logs;
+------------------+-----------+
| Log_name         | File_size |
+------------------+-----------+
| mysql-bin.000003 |       126 |
| mysql-bin.000004 |       126 |
| mysql-bin.000005 |       737 |
| mysql-bin.000006 |       126 |
| mysql-bin.000007 |       126 |
| mysql-bin.000008 |       126 |
| mysql-bin.000009 |   1132615 |
| mysql-bin.000010 |       107 |
+------------------+-----------+
#中继日志：
#事务日志：ACIO，InnoD有事务日志
#任何变量涉及文件的操作必须重启服务器才能生效
mysql> show global variables like '%log%'; #查看全局所有log相关日志
+-----------------------------------------+---------------------------+
| Variable_name                           | Value                     |
+-----------------------------------------+---------------------------+
| back_log                                | 50                        |
| binlog_cache_size                       | 32768                     |
| binlog_direct_non_transactional_updates | OFF                       |
| binlog_format                           | MIXED                     |
| binlog_stmt_cache_size                  | 32768                     |
| expire_logs_days                        | 0                         |
| general_log                             | OFF                       |
| general_log_file                        | /mydata/lnmp.log          |
| innodb_flush_log_at_trx_commit          | 1                         |
| innodb_locks_unsafe_for_binlog          | OFF                       |
| innodb_log_buffer_size                  | 8388608                   |
| innodb_log_file_size                    | 5242880                   |
| innodb_log_files_in_group               | 2                         |
| innodb_log_group_home_dir               | ./                        |
| innodb_mirrored_log_groups              | 1                         |
| log                                     | OFF                       |
| log_bin                                 | ON                        |
| log_bin_trust_function_creators         | OFF                       |
| log_error                               | /mydata/lnmp.jack.com.err | #错误日志
| log_output                              | FILE                      |
| log_queries_not_using_indexes           | OFF                       |
| log_slave_updates                       | OFF                       |
| log_slow_queries                        | OFF                       |
| log_warnings                            | 1                         | #记录警告日志
| max_binlog_cache_size                   | 18446744073709547520      |
| max_binlog_size                         | 1073741824                |
| max_binlog_stmt_cache_size              | 18446744073709547520      |
| max_relay_log_size                      | 0                         |
| relay_log                               |                           |
| relay_log_index                         |                           |
| relay_log_info_file                     | relay-log.info            |
| relay_log_purge                         | ON                        |
| relay_log_recovery                      | OFF                       |
| relay_log_space_limit                   | 0                         |
| slow_query_log                          | OFF                       | #慢查询日志开关
| slow_query_log_file                     | /mydata/lnmp-slow.log     |
| sql_log_bin                             | ON                        | #用户sql shell中临时开启和关闭二进制日志记录的开关
| sql_log_off                             | OFF                       |
| sync_binlog                             | 0                         |
| sync_relay_log                          | 0                         |
| sync_relay_log_info                     | 0                         |
+-----------------------------------------+---------------------------+
41 rows in set (0.00 sec)

#第十三节：MYSQL日志管理二
#中继日志：从主服务器的二进制日志文件中复制而来的事件，并保存的日志文件，用于从服务器复制回放的
#事务日志：ACIO，InnoD有事务日志
	innodb_flush_log_at_trx_commit：内存中缓存的日志同步到事务日志中来，值为1时表示每当有事务提交时同步事务日志，并执行磁盘flush操作，值为2时表示每有事务提交才同步，但不执行磁盘flush操作，值为0时每秒钟同步一次并告次内核不要在内核缓存直接保存到事务日志当中（执行磁盘flush操作）
	innodb_log_buffer_size：内存缓存大小，默认8M
	innodb_log_file_size：事务日志大小，默认5M
	innodb_log_files_in_group：事务日志组，默认为2个
	innodb_log_group_home_dir：事务日志存储位置
	innodb_mirrored_log_groups：事务日志镜像组

mysql> show engines;
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
| Engine             | Support | Comment                                                        | Transactions | XA   | Savepoints |
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
| CSV                | YES     | CSV storage engine                                             | NO           | NO   | NO         |
| InnoDB             | DEFAULT | Supports transactions, row-level locking, and foreign keys     | YES          | YES  | YES        |
| MyISAM             | YES     | MyISAM storage engine                                          | NO           | NO   | NO         |
| BLACKHOLE          | YES     | /dev/null storage engine (anything you write to it disappears) | NO           | NO   | NO         |
| MRG_MYISAM         | YES     | Collection of identical MyISAM tables                          | NO           | NO   | NO         |
| PERFORMANCE_SCHEMA | YES     | Performance Schema                                             | NO           | NO   | NO         |
| ARCHIVE            | YES     | Archive storage engine                                         | NO           | NO   | NO         |
| MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables      | NO           | NO   | NO         |
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
8 rows in set (0.00 sec)
MYISAM存储引擎：
	1. 不支持事务
	2. 只支持表锁
	3. 不支持外键
	4. 支持BTree索引，FULLTEXT索引，空间索引，
	5. 支持表压缩
	.frm 表结构
	.MYI 表索引
	.MYD 表数据
InnoDB:
	1. 支持事务
	2. 行级锁
	3. 支持BTree索引，聚簇索引，自适应hash索引
	4. 表空间
	5. 支持raw磁盘设备(裸设备)
	.frm 表结构
	.ibd 表空间
	innodb_file_per_table ON #开启每一个表一个表空间
MRG_MYISAM：合并MYISAM表
CSV：在两个数据库之间进行移植时使用
ARCHIVE：用来实现归档的，
MEMORY：内存存储引擎
BLACKHOLE：级联复制，多级复制时再说
#不建议使用混合存储引擎，比如以后对事务进行rollback时MYISAM就不支持，会出问题。

#第十四节：MYSQL备份和还原
RAID1,RAID10：保证硬件损坏而业务不会中止
备份是为了数据不丢失，跟硬件RAID是两个不同的概念
#备份类型：
	热备份、温备份、冷备份：
		1. 热备份：读写不受影响 
		2. 温备份：可读不可写
		3. 冷备份：离线备份，读写操作均中止
	物理备份和逻辑备份：
		1. 物理备份：复制数据文件
		2. 逻辑备份：将数据导出至文本文件中
	完全备份、增量备份、差异备份：
		1. 完全备份：备份完全数据
		2. 增量备份：仅备份上次完全备份或增量备份以后变化的数据
		3. 差异备份：仅备份上次完全备份以后变化的数据

#还原：
	要进行还原预演。不然到还原的时候还原会出问题

备份什么：
	数据、配置文件、二进制日志、事务日志

热备份：
	MYISAM:在线热备份几乎不可能，除非借助LVM快照进行热备份，否则最好的是温备份，用读锁锁定备份的所有表
	InnoDB:xtrabackup,mysqldump来进行热备份
MYSQL可以借助从服务器来进行温备份。从服务器停掉从服务器IO线程，此时从服务器只能读，就可进行温备份

物理备份：速度快
逻辑备份：速度慢、丢失浮点数精度，方便使用文本处理工具直接对其处理、可移植能力强;

备份策略：完全+增量;完全+差异

MySQ备份工具：
	1. mysqldump:逻辑备份工具，MyISAM(温备份)，InnoDB(热备份)
	2. mysqlhotcopy：物理备份工具、温备份
文件系统备份工具：
	1. cp:只能实现冷备，基于lvm可以实现热备
	2. lvm:逻辑卷的快照功能，几乎热备;
		mysql>FLUSH TABLES;
		mysql>LOCK TABLES;
		创建快照，释放锁，而后复制数据
		注：基于lvM快照来说，对于MyISAM存储引擎来说几乎可以实现热备，但是InnoDB就不行了，因为可能还有部分数据正从事务日志写入数据文件中，所以得监控InnoDB的缓冲区是否全部复制完成。
第三组备份工具：
	ibbackup:针对InnoDB存储引擎的商业工具
	xtrabackup:开源工具,建议使用这个备份工具

mysqldump备份：
	1. 先打开一个mysql终端进行锁所有表并刷新所有表：FLUSH TABLES WITH READ LOCK;
	2. 并对二进制日志进行滚动：FLUSH LOGS;SHOW BINARY LOGS;查看当前的二进制日志是哪个文件，记录稍后备份是截止到哪个二进制日志文件，但这个方式太麻烦，可在备份数据是使用[mysqldump --master-data=2 students > /root/stu-`date +%Y-%m-%d-%H:%M:%S`.sql]命令进行备份，--master-data=2表示记录你备份到二进制日志文件的哪个地方了,从备份的sql文本文件中可查看，下次从提示地方进行备份即可[CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000010', MASTER_LOG_POS=348;
]。#--master-data=0表示不记录位置，--master-data=1表示记录位置，恢复后直接启动从服务器。
	2. 再进行备份：mysqldump -uroot -p students > /root/students.sql
	3. 在另外一个mysql终端进行解锁表：UNLOCK TABLES;

--lock-all-tables #锁定所有表
--master-data={0|1|2} #记录二进制日志位置 
--flush-logs #执行二进制日志滚动
--single-transaction #如果库中的表类型为InnoDB,可使用这个参数备份，会自动锁InnoDB的表，不可与--lock-all-tables一起使用
--all-databases #备份所有库，命令会自动创建数据库，在还原的时候就不用创建库了
--databases DB_NAME,DB_NAME #备份指定库，命令会自动创建数据库，在还原的时候就不用创建库了
--events #备份事件
--routines #备份存储过程和存储函数
--triggers #备份触发器

mysqldump --lock-all-tables --master-data=2 --flush-logs students > /root/stu-`date +%Y-%m-%d-%H:%M:%S`.sql

备份策略：周完全+每日增量
	完全备份：mysqldump --lock-all-tables --master-data=2 --flush-logs students > /root/stu-`date +%Y-%m-%d-%H:%M:%S`.sql
	增量备份：备份二进制日志文件(flush logs)
例：
1. [root@lnmp ~]# mysqldump -uroot -p --flush-logs --master-data=2 --lock-all-tables --all-databases > /root/alldatabases.sql
2. [root@lnmp ~]# less alldatabases.sql 
CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000014', MASTER_LOG_POS=107; #这个是--master-data=2参数开启记录的文件及位置
3.mysql> show binary logs;
+------------------+-----------+
| Log_name         | File_size |
+------------------+-----------+
| mysql-bin.000012 |       150 |
| mysql-bin.000013 |       352 |
| mysql-bin.000014 |       107 |
+------------------+-----------+
4. mysql> purge binary logs to 'mysql-bin.000014'; #腾出二进制空间，以后会越来越大，建议先备份老的二进制然后再清理
5. mysql> show binary logs;
+------------------+-----------+
| Log_name         | File_size |
+------------------+-----------+
| mysql-bin.000014 |       107 |
+------------------+-----------+
6. mysql> select * from student;
+-----+------+-------+
| SID | CID  | name  |
+-----+------+-------+
|   2 |    3 | lhc   |
|   8 |    1 | tom   |
|   9 |   10 | jack  |
|  10 |   11 | candy |
|  11 |   12 | bob   |
+-----+------+-------+
7. mysql> delete from student where CID=3 OR CID=1; #删除两行 
8. mysql> select * from student;
+-----+------+-------+
| SID | CID  | name  |
+-----+------+-------+
|   9 |   10 | jack  |
|  10 |   11 | candy |
|  11 |   12 | bob   |
+-----+------+-------+
mysql> \q  #假如一天过去了，做了删除两行的操作
9. mysql> flush logs; #进行日志滚动
10. mysql> show master status; #当时滚动后的二进制日志
+------------------+----------+--------------+------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+------------------+----------+--------------+------------------+
| mysql-bin.000015 |      107 |              |                  |
+------------------+----------+--------------+------------------+
11. mysql> show binary logs;
+------------------+-----------+
| Log_name         | File_size |
+------------------+-----------+
| mysql-bin.000014 |       717 | #这个二进制日志就是上一次完全备份后到当前期间的二进制日志
| mysql-bin.000015 |       107 |
+------------------+-----------+
12. [root@lnmp mydata]# cp mysql-bin.000014 /root/ #备份增量到/root目录下
13. [root@lnmp mydata]# mysqlbinlog mysql-bin.000014 > /root/mon-incrementa1.sql #或者这样先读出二进制文件后重定向到新建文件进行增量备份也行，12步和13步选其一即可
14. mysql> insert into student (CID,name) value (88,'ll'); #到第二天操作增加了一行
15. mysql> select * from student;
+-----+------+-------+
| SID | CID  | name  |
+-----+------+-------+
|   9 |   10 | jack  |
|  10 |   11 | candy |
|  11 |   12 | bob   |
|  12 |   88 | ll    |
+-----+------+-------+
16. 假如服务器崩溃了或者整个数据库删除了，但是日志文件在
17. [root@lnmp mydata]# cp mysql-bin.000015 /root #假如日志文件在别的目录
18. [root@lnmp mydata]# rm -rf ./* #整个数据库删了
19. [root@lnmp mydata]# killall mysqld #终止mysqld
20. [root@lnmp mysql]# scripts/mysql_install_db --user=mysql --datadir=/mydata #重新初始化mysql库
21. [root@lnmp mysql]# service mysql start #启动mysqld服务
Starting MySQL.. SUCCESS! 
22. [root@lnmp ~]# mysql -uroot -p < alldatabases.sql  #还原完全备份
Enter password: 
23. mysql> select * from student; #先查看表
+-----+------+-------+
| SID | CID  | name  |
+-----+------+-------+
|   2 |    3 | lhc   |
|   8 |    1 | tom   |
|   9 |   10 | jack  |
|  10 |   11 | candy |
|  11 |   12 | bob   |
+-----+------+-------+
24. [root@lnmp ~]# mysql -uroot -p < mon-incrementa1.sql  #还原我们的第一次增量数据
Enter password: 
25. mysql> select * from  student; #此时还原了我们删除两行的状态，但是我们插入的那行还未还原，我们刚才备份mysql-bin.000015的文件就有插入那行的数据
+-----+------+-------+
| SID | CID  | name  |
+-----+------+-------+
|   9 |   10 | jack  |
|  10 |   11 | candy |
|  11 |   12 | bob   |
+-----+------+-------+
26. [root@lnmp ~]# mysqlbinlog mysql-bin.000015 > temp.sql #生成临时文件
27. [root@lnmp ~]# mysql -uroot -p < temp.sql  #导入数据库，也可使用mysqlbinlog mysql-bin.000015 | mysql -uroot -p
Enter password: 
28. mysql> select * from  student;
+-----+------+-------+
| SID | CID  | name  |
+-----+------+-------+
|   9 |   10 | jack  |
|  10 |   11 | candy |
|  11 |   12 | bob   |
|  12 |   88 | ll    |  #已经即时点还原成功
+-----+------+-------+

---------------mysql备份脚本-------------
#!/bin/bash  
#Shell Command For Backup MySQL Database Everyday Automatically By Crontab  
   
USER=root  
PASSWORD="123.com"  
DATABASE="yzm"  
HOSTNAME="localhost"  
   
WEBMASTER=test@qq.com  
   
BACKUP_DIR=/backup/mysql/$DATABASE #备份文件存储路径  
LOGFILE=/backup/mysql/$DATABASE/data_backup.log #日记文件路径  
DATE=`date '+%Y%m%d-%H%M'` #日期格式（作为文件名）  
DUMPFILE=$DATE.sql #备份文件名  
ARCHIVE=$DATE.sql.tar.gz #压缩文件名  
OPT='--lock-all-tables --flush-logs --master-data=2 --databases'
OPTIONS="-h$HOSTNAME -u$USER -p$PASSWORD $OPT $DATABASE"    
#判断备份文件存储目录是否存在，否则创建该目录  
if [ ! -d $BACKUP_DIR ] ;  
then  
        mkdir -p "$BACKUP_DIR"  
fi  
#开始备份之前，将备份信息头写入日记文件   
echo " " >> $LOGFILE  
echo "———————————————–" >> $LOGFILE  
echo "BACKUP DATE:" $(date +"%y-%m-%d %H:%M:%S") >> $LOGFILE  
echo "———————————————– " >> $LOGFILE  
   
#切换至备份目录  
cd $BACKUP_DIR  
#使用mysqldump 命令备份制定数据库，并以格式化的时间戳命名备份文件  
mysqldump $OPTIONS > $DUMPFILE  
#判断数据库备份是否成功  
if [[ $? == 0 ]]; then  
    #创建备份文件的压缩包  
    tar czvf $ARCHIVE $DUMPFILE >> $LOGFILE 2>&1  
    #输入备份成功的消息到日记文件  
    echo “[$ARCHIVE] Backup Successful!” >> $LOGFILE  
    #删除原始备份文件，只需保 留数据库备份文件的压缩包即可  
    rm -f $DUMPFILE  
else  
    echo “Database Backup Fail!” >> $LOGFILE  
fi  
#输出备份过程结束的提醒消息  
echo “Backup Process Done >> $LOGFILE 
---------------

#第十五节：使用LVM快照进行数据备份 
SET sql_log_bin=0;
#在数据库导入恢复的时候不应该记录二进制日志文件，会产生大量IO，所以在恢复期间应该关闭记录二进制日志，恢复后开启二进制日志
mysql -u root -p  #进入mysql终端 
set sql_log_bin=0; #临时关闭记录二进制日志开关
source /root/data.sql;  #导入数据库
set sql_log_bin=1; #临时开启记录二进制日志开关
逻辑备份：
	1. 浮点数据丢失精度;
	2. 备份出的数据更占用存储空间，压缩后可大大节省空间。
	3. 不适合对大数据库做完全备份。
#innodb跟myisam同样逻辑备份时的不一样操作
mysql> flush tables with read lock; #对innodb存储引擎进行加锁
mysql> show engine innodb status; #这个地方是不一样操作。。。查看innodb存储引擎缓冲区是否还有数据写入，等缓冲区无数据时才可对数据库进行备份

MVCC：REPEATABLE-READ(可重读)时，使用--single-transaction对innoDB可做热备份原因。
#select INTO OUTFILE跟mysqldump也是裸备份
#使用SELECT * INTO OUTFILE /tmp/test.txt FROM tb_name [WHERE clause];备份某些表
#create table tb1 like tutors; #先访造tutors生成一样的表结构
#使用LOAD DATA INFILE '/tmp/test.txt INTO TABLE tb_name;#然后恢复备份的某些表
mysqlbinlog --start-position=605 /mydata/mysql-bin.000001 > /tmp/my.sql #对二进制日志文件进行位置选定导出为sql文件
truncate table tutor; #清空表数据

#几乎热备：LVM
	快照：snapshot
	前提：
		1. 数据文件要在逻辑卷上
		2. 此逻辑卷所在卷组必须有足够空间使用快照卷
		3. 数据文件和事务日志要在同一个逻辑卷上

如果二进制日志文件跨文件了需要基于开始时间保存
LVM卷进行步骤：
	1. 打开会话，施加读锁，锁定所有表：
		mysql> FLUSH TABLES WITH READ LOCK;
		mysql> FLUSH LOGS;
	2. 在shell终端上，保存二进制日志文件信息
		# mysql -u root -p -e 'SHOW MASTER STATUS \G' >/backup/binlog-info-`date +%Y-%m-%d-%H:%M:%S`.txt
	3. 创建lvm快照
		# lvcreate -L 50M -s -p r -n data-snap /dev/myvg/mylv
	4. 释放锁
		mysql> UNLOCK TABLES;
	5. 挂载快照卷，备份
		# mount /dev/myvg/data-snap /mnt -o ro 
		# cp /mnt/* /backup/all-database-`date +%Y-%m-%d-%H:%M:%S`/
	6. 删除LVM快照卷
		lvremove
	7. 查看保存的二进制日志文件信息，增量备份数据库目录下二进制日志文件
		mysqlbinlog --start-datetime='2019-06-23 17:00:00' mysql-bin.000004 mysql-bin.000005 > /backup/binlog01-`date +%Y-%m-%d-%H:%M:%S`.sql
		注：如果innodb打开了innodb_file_per_table=1，则只需要按需复制数据库文件夹即可，不需要全部复制。
	8. 如果数据库全部坏了，停掉mysql服务，复制/backup/all-database-`date +%Y-%m-%d-%H:%M:%S`/下的数据库文件[除开旧的二进制文件]到数据库目录下/mydata,并重启服务
	9. 进入mysql终端，临时关闭二进制日志写入功能SET sql_log_bin=0;，然后导入增量备份数据source /backup/binlog01-`date +%Y-%m-%d-%H:%M:%S`.sql
	10. 打开二进制日志写入功能SET sql_log_bin=1

例：
1. mysql> flush tables with read lock;
2. mysql> flush logs;
3. [root@lnmp ~]# mysql -e 'show master status '> binlog.txt 
4. [root@lnmp ~]# lvcreate -L 50M -s -p r -n mydata-snap /dev/myvg/mylv
  Rounding up size to full physical extent 52.00 MiB
  Logical volume "mydata-snap" created.
5. mysql> unlock tables; 
6. [root@lnmp mnt]#  mount /dev/myvg/mydata-snap /mnt && mkdir /backup/alldata -pv && cp -a ./* /backup/alldata/
7. [root@lnmp ~]# umount /mnt/
8. [root@lnmp ~]# lvremove /dev/myvg/mydata-snap 
Do you really want to remove active logical volume myvg/mydata-snap? [y/n]: y
  Logical volume "mydata-snap" successfully removed
9. [root@lnmp alldata]# rm -rf mysql-bin.* #整理完全备份文件，删除快照无效二进制日志文件
[root@lnmp alldata]# ls
ibdata1      ib_logfile1        lnmp.jack.com.pid  mydb   performance_schema  wordpress
ib_logfile0  lnmp.jack.com.err  lost+found         mysql  test
10. [root@lnmp mydata]# mysqlbinlog --start-datetime='2019-06-23 18:59:54' mysql-bin.000006 mysql-bin.000007 > /root/a.sql #整理增量文件，时间从之前导出的binlog.txt文件看出，假如mysql服务已经是断开状态
11. [root@lnmp alldata]# service mysql stop
Shutting down MySQL.... SUCCESS!
12. [root@lnmp mydata]# ls
ibdata1      lnmp.jack.com.err  mysql             mysql-bin.000006  performance_schema
ib_logfile0  lost+found         mysql-bin.000004  mysql-bin.000007  test
ib_logfile1  mydb               mysql-bin.000005  mysql-bin.index   wordpress
13. [root@lnmp mydata]# rm -rf ./* #模拟整个数据库崩溃
14. [root@lnmp mydata]# cp -a /backup/alldata/* /mydata #复制完全备份文件到数据库目录，因为是快照，所以可以全部复制回来
15. [root@lnmp mydata]# service mysql start #可正常启动了,先要在mysql脚本上start()段 加入--skip-networking参数断网启动mysql,防止恢复时别人连入数据库
Starting MySQL SUCCESS! 
16. mysql> show databases;
+---------------------+
| Database            |
+---------------------+
| information_schema  |
| #mysql50#lost+found |
| mydb                |
| mysql               |
| performance_schema  |
| test                |
| wordpress           |
+---------------------+
17. mysql> select * from stu; #完全备份后进行新添加的数据没有，需要增量还原后才可见
+----+-------+------+
| ID | Name  | Age  |
+----+-------+------+
|  1 | bob   |   21 |
|  2 | jack  |   25 |
|  3 | candy |   24 |
|  4 | aa    | NULL |
+----+-------+------+
18. mysql> set sql_log_bin=0; #临时关闭二进制写入功能
19. [root@lnmp ~]# mysql < a.sql  #还原增量文件
19. mysql> select * from stu;
+----+-------+------+
| ID | Name  | Age  |
+----+-------+------+
|  1 | bob   |   21 |
|  2 | jack  |   25 |
|  3 | candy |   24 |
|  4 | aa    | NULL |
|  5 | bb    | NULL |  #这4行添加的数据正常了
|  6 | cc    | NULL |
|  7 | dd    | NULL |
|  8 | ee    | NULL |
+----+-------+------+
20. mysql> set sql_log_bin=1; #开启二进制写入功能
21. [root@lnmp mydata]# service mysql stop #停止
22. [root@lnmp mydata]# service mysql start #先要在mysql脚本上start()段去掉--skip-networking参数,再启动mysql正常提供服务
##注：LVM-->有一个mylvmbackup(perl scripts)，有单独的配置，提供LVM快照的。

#第十六节：使用xtrabackup进行数据备份
innodb_support_xa               | ON  #开启innodb分布式事务的，建议开启
sync_binlog            | 0  #建议设置为1，每1次写操作将同步二进制日志到磁盘

#percona提供的xtrabackup备份工具
	xtrabackup:
		xtradb:innodb的增强版
		innodb
注：如果是源码编译mysql时，建议把mysql中innodb存储引擎源码删了，去percona官方下xtradb源码放到innodb存储引擎的位置，并更名xtradb为innodb即可编译。

参考链接：https://www.percona.com/downloads/
参考链接：https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.9/binary/redhat/6/x86_64/Percona-XtraBackup-2.4.9-ra467167cdd4-el6-x86_64-bundle.tar
#使用Xtrabackup进行mysql备份
##安装xtrabackup
[root@lnmp download]# wget https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.9/binary/redhat/6/x86_64/Percona-XtraBackup-2.4.9-ra467167cdd4-el6-x86_64-bundle.tar
[root@lnmp download]# tar xf Percona-XtraBackup-2.4.9-ra467167cdd4-el6-x86_64-bundle.tar
[root@lnmp download]# rpm -ivh  rpm -ivh percona-xtrabackup-24-2.4.9-1.el6.x86_64.rpm 
[root@lnmp download]# yum install -y libev libev-devel perl perl-devel perl-DBD-MySQL #如果依赖需要安装
[root@lnmp download]# rpm -ql percona-xtrabackup-24-2.4.9-1.el6.x86_64
/usr/bin/innobackupex #备份工具
/usr/bin/xbcloud
/usr/bin/xbcloud_osenv
/usr/bin/xbcrypt
/usr/bin/xbstream
/usr/bin/xtrabackup
/usr/share/doc/percona-xtrabackup-24-2.4.9
/usr/share/doc/percona-xtrabackup-24-2.4.9/COPYING
/usr/share/man/man1/innobackupex.1.gz
/usr/share/man/man1/xbcrypt.1.gz
/usr/share/man/man1/xbstream.1.gz
/usr/share/man/man1/xtrabackup.1.gz
#第一阶段：备份
[root@lnmp download]# innobackupex --user=root --password=root123 /backup #备份
[root@lnmp 2019-06-23_21-25-52]# ls
backup-my.cnf  lost+found  mysql               test       xtrabackup_binlog_info  xtrabackup_info
ibdata1        mydb        performance_schema  wordpress  xtrabackup_checkpoints  xtrabackup_logfile
[root@lnmp 2019-06-23_21-25-52]# pwd
/backup/2019-06-23_21-25-52
[root@lnmp 2019-06-23_21-25-52]# cat xtrabackup_checkpoints #用记增量备份的检查点文件
backup_type = full-backuped
from_lsn = 0
to_lsn = 2245016
last_lsn = 2245016
compact = 0
recover_binlog_info = 0
[root@lnmp 2019-06-23_21-25-52]# cat xtrabackup_info #xtrabackup备份的信息
uuid = 6d2b0eba-95ba-11e9-8344-005056ad0d3c
name = 
tool_name = innobackupex
tool_command = --user=root --password=... /backup
tool_version = 2.4.9
ibbackup_version = 2.4.9
server_version = 5.5.37-log
start_time = 2019-06-23 21:25:52
end_time = 2019-06-23 21:25:53
lock_time = 0
binlog_pos = filename 'mysql-bin.000001', position '801'
innodb_from_lsn = 0
innodb_to_lsn = 2245016
partial = N
incremental = N
format = file
compact = N
compressed = N
encrypted = N
[root@lnmp 2019-06-23_21-25-52]# cat xtrabackup_binlog_info  #xtrabckup备份的二进制文件状态
mysql-bin.000001        801
#第二阶段：准备工作，将事务日志进行重读和撤销到数据文件
[root@lnmp 2019-06-23_21-25-52]# innobackupex --apply-log /backup/2019-06-23_21-25-52/ #进行事务日志写入数据文件，后面给一个路径，这个准备工作必须做，做完才可进行恢复
mysql> insert into stu (Name) value ('abcd'); #模拟在mysql做插入动作
mysql> insert into stu (Name) value ('abcd12');
mysql> flush logs; #滚动二进制日志
[root@lnmp mydata]# cp mysql-bin.000001 /root #复制完全备份后更改的二进制日志文件信息
[root@lnmp mydata]# service mysql stop 
[root@lnmp mydata]# rm -rf ./* #模拟删除全部数据
[root@lnmp mydata]# ls /mydata/
[root@lnmp backup]# innobackupex --copy-back /backup/2019-06-23_21-25-52/ #恢复全量备份
[root@lnmp mydata]# ll #恢复成功，但是属主属组不是mysql.mysql，必须改正
total 41056
-rw-r----- 1 root root 18874368 Jun 23 21:43 ibdata1
-rw-r----- 1 root root  5242880 Jun 23 21:43 ib_logfile0
-rw-r----- 1 root root  5242880 Jun 23 21:43 ib_logfile1
-rw-r----- 1 root root 12582912 Jun 23 21:43 ibtmp1
drwxr-x--- 2 root root     4096 Jun 23 21:43 lost+found
drwxr-x--- 2 root root     4096 Jun 23 21:43 mydb
drwxr-x--- 2 root root     4096 Jun 23 21:43 mysql
drwxr-x--- 2 root root     4096 Jun 23 21:43 performance_schema
drwxr-x--- 2 root root     4096 Jun 23 21:43 test
drwxr-x--- 2 root root     4096 Jun 23 21:43 wordpress
-rw-r----- 1 root root       23 Jun 23 21:43 xtrabackup_binlog_pos_innodb
-rw-r----- 1 root root      463 Jun 23 21:43 xtrabackup_info
[root@lnmp mydata]# chown -R mysql.mysql /mydata/
[root@lnmp mydata]# service mysql start #启动mysql
Starting MySQL.. SUCCESS! 
[root@lnmp 2019-06-23_21-25-52]# cat xtrabackup_binlog_info 
mysql-bin.000001        801
[root@lnmp ~]# mysqlbinlog --start-position=801 mysql-bin.000001 > a.sql
mysql> select * from stu;
+----+-------+------+
| ID | Name  | Age  |
+----+-------+------+
|  1 | bob   |   21 |
|  2 | jack  |   25 |
|  3 | candy |   24 |
|  4 | aa    | NULL |
|  5 | bb    | NULL |
|  6 | cc    | NULL |
|  7 | dd    | NULL |
|  8 | ee    | NULL |
+----+-------+------+
mysql> set sql_log_bin=0;
[root@lnmp ~]# mysql < a.sql  #恢复增量备份数据
mysql> set sql_log_bin=1;
mysql> select * from stu;
+----+--------+------+
| ID | Name   | Age  |
+----+--------+------+
|  1 | bob    |   21 |
|  2 | jack   |   25 |
|  3 | candy  |   24 |
|  4 | aa     | NULL |
|  5 | bb     | NULL |
|  6 | cc     | NULL |
|  7 | dd     | NULL |
|  8 | ee     | NULL |
|  9 | abcd   | NULL | #已经恢复
| 10 | abcd12 | NULL |
+----+--------+------+
#已经增量恢复了，所以现在重新做完全备份
[root@lnmp ~]# innobackupex --user=root --password=root123 /backup #重做完全备份
mysql> insert stu (Name) value ('aa1'),('aa2'); #新插入两条数据
[root@lnmp ~]# innobackupex --incremental /backup --incremental-basedir=/backup/2019-06-23_21-52-24 #做第一次增量备份，--incremental表示增量，/backup表示备份的目录，--incremental-basedir=/backup/2019-06-23_21-52-24表示在这个基础上做增量备份
[root@lnmp backup]# ll
total 0 
drwxr-x--- 8 root root 249 Jun 23 21:52 2019-06-23_21-52-24 #这个是完全
drwxr-x--- 8 root root 275 Jun 23 21:55 2019-06-23_21-55-32 #这个是增量
mysql> insert stu (Name) value ('aa1'),('cc1');
mysql> insert stu (Name) value ('aa1'),('cc2');
[root@lnmp ~]# innobackupex --incremental /backup --incremental-basedir=/backup/2019-06-23_21-55-32 #这个是第二次增量备份
[root@lnmp backup]# ll
total 0
drwxr-x--- 8 root root 249 Jun 23 21:52 2019-06-23_21-52-24
drwxr-x--- 8 root root 275 Jun 23 21:55 2019-06-23_21-55-32
drwxr-x--- 8 root root 275 Jun 23 22:00 2019-06-23_22-00-13
[root@lnmp 2019-06-23_21-52-24]# cat xtrabackup_checkpoints 
backup_type = full-backuped
from_lsn = 0
to_lsn = 2246096
last_lsn = 2246096 #完全备份的最后lsn
compact = 0
recover_binlog_info = 0
[root@lnmp 2019-06-23_21-55-32]# cat xtrabackup_checkpoints 
backup_type = incremental
from_lsn = 2246096
to_lsn = 2246774
last_lsn = 2246774 #增量备份的最后lsn
compact = 0
recover_binlog_info = 0
[root@lnmp 2019-06-23_22-00-13]# cat xtrabackup_checkpoints 
backup_type = incremental
from_lsn = 2246774
to_lsn = 2247436
last_lsn = 2247436 #增量备份的最后lsn
compact = 0
recover_binlog_info = 0
#让事务日志写入数据文件
[root@lnmp ~]# innobackupex --apply-log --redo-only /backup/2019-06-23_21-52-24/ #对完全备份操作，让事务日志写入数据文件，并且只做重读操作，不做撤销，因为如果撤销会影响后面的重读操作
[root@lnmp ~]# innobackupex --apply-log --redo-only /backup/2019-06-23_21-52-24/ --incremental-dir=/backup/2019-06-23_21-55-32/ #对增量备份1进行事务日志操作，/backup/2019-06-23_21-52-24/为写入数据文件路径，--incremental-dir=/backup/2019-06-23_21-55-32/是第1次增量备份事务日志和二进制日志路径
[root@lnmp ~]# innobackupex --apply-log --redo-only /backup/2019-06-23_21-52-24/ --incremental-dir=/backup/2019-06-23_22-00-13/ #对增量备份2进行事务日志操作，/backup/2019-06-23_21-52-24/为写入数据文件路径，--incremental-dir=/backup/2019-06-23_21-55-32/是第2次增量备份事务日志和二进制日志路径
[root@lnmp ~]# service mysql stop #停止mysql
Shutting down MySQL... SUCCESS!  
[root@lnmp mydata]# rm -rf /mydata/* #模拟崩溃
[root@lnmp mydata]# ls
[root@lnmp backup]# innobackupex --copy-back /backup/2019-06-23_21-52-24/ #完全加增量恢复
[root@lnmp mydata]# ll /mydata/
total 18488
-rw-r----- 1 root root 18874368 Jun 23 22:41 ibdata1
drwxr-x--- 2 root root     4096 Jun 23 22:41 lost+found
drwxr-x--- 2 root root     4096 Jun 23 22:41 mydb
drwxr-x--- 2 root root     4096 Jun 23 22:41 mysql
drwxr-x--- 2 root root     4096 Jun 23 22:41 performance_schema
drwxr-x--- 2 root root     4096 Jun 23 22:41 test
drwxr-x--- 2 root root     4096 Jun 23 22:41 wordpress
-rw-r----- 1 root root       24 Jun 23 22:41 xtrabackup_binlog_pos_innodb
-rw-r----- 1 root root      507 Jun 23 22:41 xtrabackup_info
[root@lnmp mydata]# chown -R mysql.mysql /mydata/
[root@lnmp mydata]# service mysql start #启动mysql
Starting MySQL.. SUCCESS! 
mysql> select * from stu;
+----+--------+------+
| ID | Name   | Age  |
+----+--------+------+
|  1 | bob    |   21 |
|  2 | jack   |   25 |
|  3 | candy  |   24 |
|  4 | aa     | NULL |
|  5 | bb     | NULL |
|  6 | cc     | NULL |
|  7 | dd     | NULL |
|  8 | ee     | NULL |
|  9 | abcd   | NULL |
| 10 | abcd12 | NULL |
| 11 | aa1    | NULL |
| 12 | aa2    | NULL |
| 13 | aa1    | NULL |
| 14 | bb1    | NULL |
| 15 | aa1    | NULL |
| 16 | bb2    | NULL |
| 17 | aa1    | NULL |
| 18 | cc1    | NULL |
| 19 | aa1    | NULL |
| 20 | cc2    | NULL |  #cc2为第二次增量备份前插入的，事实证明成功
+----+--------+------+
20 rows in set (0.00 sec)
#注：innodb_file_per_table=1必须启用每表一个表空间，innodb_expand_import=1启用导入功能


###MySQL读写分离
#第一节：MYSQL读写分离概念
复制的作用：
	1. 辅助实现备份
	2. 高可用
	3. 异地容灾
	4. scale out:分担负载
主从架构中不使用MYSQL代理，通过php程序指定主从服务器来实现读写分离。
双主复制：无法减轻写操作。

#读写分离工具
读写分离：
	MySQL-Proxy
	amoeba:阿里巴巴前员工写的，已经离职
数据拆分：
	cobar：现在阿里巴巴用

#第二节：MYSQL异步、半同步配置及其注意事项
一个从只能属于一个主服务器，
mysql5.5-：配置很简单
mysql5.6+：配置较复杂，引入gtid（全局事务号）机制，multi-thread repliction

一：mysql master:
1. 启用二进制日志：
	1. log-bin = master-bin
	2. log-bin-index = master-bin.index
2. 选择一个惟一server-id
	server-id = {0-2^32}-1 #0到2的32次方减1
3. 创建具有复制权限的用户
	1. REPLICATION SLAVE #复制从用户
	2. REPLICATION CLIENT #复制客户端用户

二：mysql slave
1. 启用中继日志
	1. relay-log = relay-log
	2. relay-log-index = relay-log.index
2. 选择一个惟一的server-id
	server-id = {0-2^32}-1 #0到2的32次方减1,千千万万不能和主服务器相同
3. 连接至主服务器，并开始复制数据：
	1. mysql> CHANGE MASTER TO MASTER_HOST='',MASTER_PORT='',MASTER_LOG_FILE='',MASTER_LOG_POS='',MASTER_USER='',MASTER_PASSWORD='';
	2. mysql> START SLAVE; #启动IO_Thread和SQL_Thread两个线程，如果需要启用单个线程，例：START SLAVE IO_Thread;
复制线程：
	master: 当从服务器复制主服务器二进制事件时，主服务器启动一个dump线程跟从服务器IO_Thread进行连接
	slave: 当从服务器从主服务器复制二进制事件时，会启动IO_Thread和SQL_Thread两个线程，IO_Thread是跟主服务器dump线程进行连接，作用是复制主服务器二进制事件到从服务器中继日志中的。SQL_Thread线程是回放本地的中继日志生成数据文件并记录二进制日志文件到从服务器的。

工作模式：
半同步：只需要从服务器其中一台响应主服务器复制成功或超时，这就是半同步模式。并且要设超时时间间隔。
异步：当超时时间间隔到达后主服务器与从服务器断开，并且降级为异步模式

####实操：
##主服务器：
[root@mysql-master download]wget https://dev.mysql.com/get/Downloads/MySQL-5.5/mysql-5.5.62-linux-glibc2.12-x86_64.tar.gz
[root@mysql-master download]# tar xf mysql-5.5.62-linux-glibc2.12-x86_64.tar.gz  -C /usr/local
[root@mysql-master download]# groupadd -g 3306 -r mysql
[root@mysql-master download]# useradd -g 3306 -u 3306 -r mysql
[root@mysql-master download]# mkdir -pv /mydata/data
[root@mysql-master download]# chown -R mysql.mysql /mydata/data/
[root@mysql-master download]# chown -R root.mysql /usr/local/mysql-5.5.62-linux-glibc2.12-x86_64/
[root@mysql-master download]# ln -sv /usr/local/mysql-5.5.62-linux-glibc2.12-x86_64 /usr/local/mysql
‘/usr/local/mysql’ -> ‘/usr/local/mysql-5.5.62-linux-glibc2.12-x86_64’
[root@mysql-master mysql]# ./scripts/mysql_install_db --user=mysql --datadir=/mydata/data
[root@mysql-master mysql]# cp support-files/mysql.server /etc/init.d/mysqld
[root@mysql-master mysql]# chkconfig --add mysqld
[root@mysql-master mysql]# chkconfig --list mysqld
mysqld          0:off   1:off   2:on    3:on    4:on    5:on    6:off
[root@mysql-master mysql]# cat /etc/profile.d/mysqld.sh 
export PATH=$PATH:/usr/local/mysql/bin
[root@mysql-slave mysql]# . /etc/profile.d/mysqld.sh 
[root@mysql-master mysql]# cat /etc/ld.so.conf.d/mysql
/usr/local/mysql/lib
[root@mysql-master lib]# ldconfig -v
[root@mysql-master mysql]# ln -sv /usr/local/mysql/include/ /usr/include/mysql
‘/usr/include/mysql’ -> ‘/usr/local/mysql/include/’
[root@mysql-master mysql]# cp support-files/my-large.cnf /etc/my.cnf
[root@mysql-master mysql]# vim  /etc/my.cnf
innodb_file_per_table=1
datadir = /mydata/data
log-bin=mysql-bin
log-bin-index=log-bin.inde
server-id       = 1
-------------------------
[root@mysql-master mysql]# egrep -v '#|^$' /etc/my.cnf
[client]
port            = 3306
socket          = /tmp/mysql.sock
[mysqld]
port            = 3306
socket          = /tmp/mysql.sock
skip-external-locking
key_buffer_size = 256M
max_allowed_packet = 1M
table_open_cache = 256
sort_buffer_size = 1M
read_buffer_size = 1M
read_rnd_buffer_size = 4M
myisam_sort_buffer_size = 64M
thread_cache_size = 8
query_cache_size= 16M
thread_concurrency = 8
innodb_file_per_table=1
datadir = /mydata/data
log-bin=mysql-bin
log-bin-index=log-bin.index
binlog_format=mixed
server-id       = 1
[mysqldump]
quick
max_allowed_packet = 16M
[mysql]
no-auto-rehash
[myisamchk]
key_buffer_size = 128M
sort_buffer_size = 128M
read_buffer = 2M
write_buffer = 2M
[mysqlhotcopy]
interactive-timeout
-------------------------
[root@mysql-master mysql]# service mysqld start
Starting MySQL.. SUCCESS!
mysql> grant replication slave on *.* to repluser@'192.168.1.%' identified by 'replpass';  #建立复制从服务器的用户
mysql> flush privileges;
[root@mysql-master mysql]# scp /etc/my.cnf 192.168.1.37:/etc #复制主服务器配置文件到从服务器

##从服务器
[root@mysql-slave download]# tar xf mysql-5.5.62-linux-glibc2.12-x86_64.tar.gz -C /usr/local
[root@mysql-slave download]# mkdir -pv /mydata/data
mkdir: created directory ‘/mydata’
mkdir: created directory ‘/mydata/data’
[root@mysql-slave download]# groupadd -r -g 3306 mysql
[root@mysql-slave download]# useradd -r -g 3306 -u 3306 mysql
[root@mysql-slave download]# chown -R mysql.mysql /mydata/data/
[root@mysql-slave download]# ln -sv /usr/local/mysql-5.5.62-linux-glibc2.12-x86_64/ /usr/local/mysql
‘/usr/local/mysql’ -> ‘/usr/local/mysql-5.5.62-linux-glibc2.12-x86_64/’
[root@mysql-slave download]# cd /usr/local/mysql
[root@mysql-slave mysql]# ./scripts/mysql_install_db --user=mysql --datadir=/mydata/data
[root@mysql-slave mysql]# vim /etc/profile.d/mysqld.sh
export PATH=$PATH:/usr/local/mysql/bin
[root@mysql-slave mysql]# . /etc/profile.d/mysqld.sh 
[root@mysql-slave mysql]# vim /etc/ld.so.conf.d/mysql
/usr/local/mysql/lib
[root@mysql-slave mysql]# ldconfig
[root@mysql-slave mysql]# ln -sv /usr/local/mysql/include/ /usr/include/mysql
‘/usr/include/mysql’ -> ‘/usr/local/mysql/include/’
[root@mysql-slave mysql]# vim /etc/my.cnf
server-id       = 11
relay-log = relay-log
relay-log-index = relay-log.index
innodb_file_per_table=1
datadir = /mydata/data
[root@mysql-slave mysql]# service mysqld start
Starting MySQL.Logging to '/mydata/data/mysql-slave.jack.com.err'.
. SUCCESS! 
------------------
[root@mysql-slave mysql]# egrep -v '#|^$' /etc/my.cnf
[client]
port            = 3306
socket          = /tmp/mysql.sock
[mysqld]
port            = 3306
socket          = /tmp/mysql.sock
skip-external-locking
key_buffer_size = 256M
max_allowed_packet = 1M
table_open_cache = 256
sort_buffer_size = 1M
read_buffer_size = 1M
read_rnd_buffer_size = 4M
myisam_sort_buffer_size = 64M
thread_cache_size = 8
query_cache_size= 16M
thread_concurrency = 8
innodb_file_per_table=1
datadir = /mydata/data
relay-log = relay-log
relay-log-index = relay-log.index
binlog_format=mixed
server-id       = 11
[mysqldump]
quick
max_allowed_packet = 16M
[mysql]
no-auto-rehash
[myisamchk]
key_buffer_size = 128M
sort_buffer_size = 128M
read_buffer = 2M
write_buffer = 2M
[mysqlhotcopy]
interactive-timeout
------------------
mysql> show slave status; #查看slave状态，现在未启动所以未有结果
mysql> show master status;
+------------------+----------+--------------+------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+------------------+----------+--------------+------------------+
| mysql-bin.000001 |      338 |              |                  |
+------------------+----------+--------------+------------------+
mysql> show binlog events in 'mysql-bin.000001'; #从结果看出，由于主服务器创建用户导致position发生改变，而从服务器不需要这个用户，则从服务器从主服务器文件：mysql-bin.000001开始，位置为338开始
+------------------+-----+-------------+-----------+-------------+-----------------------------------------------------------------------------------+
| Log_name         | Pos | Event_type  | Server_id | End_log_pos | Info                                                                              |
+------------------+-----+-------------+-----------+-------------+-----------------------------------------------------------------------------------+
| mysql-bin.000001 |   4 | Format_desc |         1 |         107 | Server ver: 5.5.62-log, Binlog ver: 4                                             |
| mysql-bin.000001 | 107 | Query       |         1 |         263 | grant replication slave on *.* to repluser@'192.168.1.%' identified by 'replpass' |
| mysql-bin.000001 | 263 | Query       |         1 |         338 | flush privileges                                                                  |
+------------------+-----+-------------+-----------+-------------+-----------------------------------------------------------------------------------+
mysql> CHANGE MASTER TO MASTER_HOST='192.168.1.31',MASTER_USER='repluser',MASTER_PASSWORD='replpass',MASTER_LOG_FILE='mysql-bin.000001',MASTER_LOG_POS=338;  #连接主服务器，因为主服务器端口默认是3306，所以未指定
mysql> show slave status\G; #查看从服务器的壮态
*************************** 1. row ***************************
               Slave_IO_State: 
                  Master_Host: 192.168.1.31 #主服务器地址
                  Master_User: repluser  #同步主服务器的用户
                  Master_Port: 3306  #主服务器端口 
                Connect_Retry: 60  #连接重试间隔时间为60秒
              Master_Log_File: mysql-bin.000001  #主服务器二进制文件名称
          Read_Master_Log_Pos: 338  #读到主服务器二进制文件的位置
               Relay_Log_File: relay-log.000001  #从服务器中继日志文件名称
                Relay_Log_Pos: 4 #从服务器中继日志文件位置
        Relay_Master_Log_File: mysql-bin.000001  #中继工作此时到主服务器的日志文件名称
             Slave_IO_Running: No   #IO线程运行状态，日后排错重点
            Slave_SQL_Running: No   #SQL线程运行状态，日后排错重点
              Replicate_Do_DB:   #复制过滤器
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0  
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 338  #写到主服务器二进制文件的位置
              Relay_Log_Space: 107 #中继日志空间位置
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No  #主服务器是否允许ssl
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: NULL #从服务器比主服务器慢多少
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0  #本地线程的错误信息
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 0
mysql> START SLAVE;  #启动从服务器
mysql> SHOW SLAVE STATUS\G;
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.1.31
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000001
          Read_Master_Log_Pos: 338
               Relay_Log_File: relay-log.000002
                Relay_Log_Pos: 253
        Relay_Master_Log_File: mysql-bin.000001
             Slave_IO_Running: Yes  #IO线程已经运行
            Slave_SQL_Running: Yes  #SQL线程已经运行
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 338
              Relay_Log_Space: 403
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 1
mysql> show global variables like 'read%';
+----------------------+---------+
| Variable_name        | Value   |
+----------------------+---------+
| read_buffer_size     | 1048576 |
| read_only            | OFF     |  #设置从服务器是否为可读
| read_rnd_buffer_size | 4194304 |
+----------------------+---------+
[root@mysql-slave mysql]# vim /etc/my.cnf
read_only = 1  #设置从服务器以后永久只能只读
[root@mysql-slave mysql]# service mysqld restart
mysql> show global variables like 'read%';
+----------------------+---------+
| Variable_name        | Value   |
+----------------------+---------+
| read_buffer_size     | 1048576 |
| read_only            | ON      |  #已经开启，但对于super用户来说不生效
| read_rnd_buffer_size | 4194304 |
+----------------------+---------+
mysql> show slave status \G;
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.1.31
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000001
          Read_Master_Log_Pos: 338
               Relay_Log_File: relay-log.000008
                Relay_Log_Pos: 253
        Relay_Master_Log_File: mysql-bin.000001
             Slave_IO_Running: Yes  #设置从服务器为只读也不影响IO和SQL线程写入
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 338
              Relay_Log_Space: 403
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 1
##重启slave服务器时未指定用户密码等信息，从服务器是怎么运行的呢？
[root@mysql-slave data]# cat master.info  #slave数据库目录下存储了用户密码等信息
18
mysql-bin.000001
421
192.168.1.31
repluser
replpass
3306
60
0





0
1800.000

0
[root@mysql-slave data]# cat relay-log.info #这个文件记录的是当前中继日志的文件名和位置，以及主服务器的文件及位置，结合master.info文件来确定IO和SQL线程从哪里开始启动
./relay-log.000008
336
mysql-bin.000001
421

mysql> create database mydb;  #主服务器上新建数据库
mysql> show databases; #从服务器上查看新建的数据库
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mydb               |
| mysql              |
| performance_schema |
| test               |
+--------------------+
#主服务器配置
sync_binlog = 1 #设定主服务器同步二进制日志，确定二进制安全

#注：当从服务器不想一启动时，可把数据库路径下的master.info和relay-log.info移出数据库路径，当重启从服务器服务时，不会自动启动，再手动添加主服务器连接即可。
#注：从服务器的IO和SQL线程信息日志都在从服务器数据库路径下的错误日志里面。
STOP SLAVE;停止从服务器IO和SQL线程

####设置半同步复制
[root@mysql-slave data]# cd /usr/local/mysql/lib/plugin/ #主服务器上跟这一样
[root@mysql-slave plugin]# ls
semisync_master.so    #主服务器安装的半同步模块
semisync_slave.so     #从服务器安装的半同步模块
#在主服务器中安装半同步模块
mysql> INSTALL PLUGIN rpl_semi_sync_master SONAME 'semisync_master.so'; #安装主服务器的模块
mysql> SHOW GLOBAL VARIABLES LIKE '%rpl%';
+------------------------------------+-------+
| Variable_name                      | Value |
+------------------------------------+-------+
| rpl_recovery_rank                  | 0     |
| rpl_semi_sync_master_enabled       | OFF   |  #默认是未开启的
| rpl_semi_sync_master_timeout       | 10000 |  #半同步超时时间
| rpl_semi_sync_master_trace_level   | 32    |  #追踪级别
| rpl_semi_sync_master_wait_no_slave | ON    |  #没有slave连接时是否等待slave连接
+------------------------------------+-------+
mysql> SET GLOBAL rpl_semi_sync_master_enabled=1; #主服务器开启半同步模式
mysql> SHOW GLOBAL VARIABLES LIKE '%rpl%';
+------------------------------------+-------+
| Variable_name                      | Value |
+------------------------------------+-------+
| rpl_recovery_rank                  | 0     |
| rpl_semi_sync_master_enabled       | ON    |  #已经开启
| rpl_semi_sync_master_timeout       | 10000 |
| rpl_semi_sync_master_trace_level   | 32    |
| rpl_semi_sync_master_wait_no_slave | ON    |
+------------------------------------+-------+
##从服务器安装半同步模块
mysql> INSTALL PLUGIN rpl_semi_sync_slave SONAME 'semisync_slave.so';
mysql> SHOW GLOBAL VARIABLES LIKE '%rpl%';
+---------------------------------+-------+
| Variable_name                   | Value |
+---------------------------------+-------+
| rpl_recovery_rank               | 0     |
| rpl_semi_sync_slave_enabled     | OFF   |
| rpl_semi_sync_slave_trace_level | 32    |
+---------------------------------+-------+
mysql> SET GLOBAL rpl_semi_sync_slave_enabled=1; #开启从线程半同步模式
mysql> show global variables like '%rpl%';
+---------------------------------+-------+
| Variable_name                   | Value |
+---------------------------------+-------+
| rpl_recovery_rank               | 0     |
| rpl_semi_sync_slave_enabled     | ON    |
| rpl_semi_sync_slave_trace_level | 32    |
+---------------------------------+-------+
mysql> SHOW GLOBAL STATUS LIKE '%rpl%';
+--------------------------------------------+-------------+
| Variable_name                              | Value       |
+--------------------------------------------+-------------+
| Rpl_semi_sync_master_clients               | 0           | #半同步客户端还未有，因为需要从服务器IO_Thread重新连接dump线程才行
| Rpl_semi_sync_master_net_avg_wait_time     | 0           |
| Rpl_semi_sync_master_net_wait_time         | 0           |
| Rpl_semi_sync_master_net_waits             | 0           |
| Rpl_semi_sync_master_no_times              | 0           |
| Rpl_semi_sync_master_no_tx                 | 0           |
| Rpl_semi_sync_master_status                | ON          |
| Rpl_semi_sync_master_timefunc_failures     | 0           |
| Rpl_semi_sync_master_tx_avg_wait_time      | 0           |
| Rpl_semi_sync_master_tx_wait_time          | 0           |
| Rpl_semi_sync_master_tx_waits              | 0           |
| Rpl_semi_sync_master_wait_pos_backtraverse | 0           |
| Rpl_semi_sync_master_wait_sessions         | 0           |
| Rpl_semi_sync_master_yes_tx                | 0           |
| Rpl_status                                 | AUTH_MASTER |
+--------------------------------------------+-------------+
mysql> STOP SLAVE IO_Thread;
mysql> START SLAVE IO_Thread;  #重新启动IO_Thread，从新连接主服务器dump线程
mysql> SHOW GLOBAL STATUS LIKE '%rpl%';
+--------------------------------------------+-------------+
| Variable_name                              | Value       |
+--------------------------------------------+-------------+
| Rpl_semi_sync_master_clients               | 1           |
| Rpl_semi_sync_master_net_avg_wait_time     | 0           |
| Rpl_semi_sync_master_net_wait_time         | 0           |
| Rpl_semi_sync_master_net_waits             | 0           |
| Rpl_semi_sync_master_no_times              | 0           |
| Rpl_semi_sync_master_no_tx                 | 0           |
| Rpl_semi_sync_master_status                | ON          |
| Rpl_semi_sync_master_timefunc_failures     | 0           |
| Rpl_semi_sync_master_tx_avg_wait_time      | 0           |
| Rpl_semi_sync_master_tx_wait_time          | 0           |
| Rpl_semi_sync_master_tx_waits              | 0           |
| Rpl_semi_sync_master_wait_pos_backtraverse | 0           |
| Rpl_semi_sync_master_wait_sessions         | 0           |
| Rpl_semi_sync_master_yes_tx                | 0           |
| Rpl_status                                 | AUTH_MASTER |
+--------------------------------------------+-------------+
##注：至此，半同步服务器已经结束

----------------------------
##半同步到异步的转变例子：
mysql> use mydb;
mysql> create table tb1 (id int);
mysql> stop slave IO_THREAD; #从服务器停止IO线程
mysql> create table tb2 (id int); #主服务器半同步时间为10秒，会等待超时时间走完，而后会降级为异步
Query OK, 0 rows affected (10.01 sec)
mysql> create table t32 (id int); #现在为异步，不会再等待slave的IO线程了
Query OK, 0 rows affected (0.01 sec)
mysql> SHOW GLOBAL STATUS LIKE '%rpl%';
+--------------------------------------------+-------------+
| Variable_name                              | Value       |
+--------------------------------------------+-------------+
| Rpl_semi_sync_master_clients               | 0           | #没有客户端连接显示为异步
| Rpl_semi_sync_master_net_avg_wait_time     | 230         |
| Rpl_semi_sync_master_net_wait_time         | 460         |
| Rpl_semi_sync_master_net_waits             | 2           | #等待了2次
| Rpl_semi_sync_master_no_times              | 1           |
| Rpl_semi_sync_master_no_tx                 | 2           |
| Rpl_semi_sync_master_status                | OFF         |
| Rpl_semi_sync_master_timefunc_failures     | 0           |
| Rpl_semi_sync_master_tx_avg_wait_time      | 467         |
| Rpl_semi_sync_master_tx_wait_time          | 467         |
| Rpl_semi_sync_master_tx_waits              | 1           |
| Rpl_semi_sync_master_wait_pos_backtraverse | 0           |
| Rpl_semi_sync_master_wait_sessions         | 0           |
| Rpl_semi_sync_master_yes_tx                | 1           |
| Rpl_status                                 | AUTH_MASTER |
+--------------------------------------------+-------------+
mysql> start slave IO_THREAD; #当从服务器IO线程启动，从服务器立即从异步模式到半同步模式
mysql> SHOW GLOBAL STATUS LIKE '%rpl%';
+--------------------------------------------+-------------+
| Variable_name                              | Value       |
+--------------------------------------------+-------------+
| Rpl_semi_sync_master_clients               | 1           |
| Rpl_semi_sync_master_net_avg_wait_time     | 1108        |
| Rpl_semi_sync_master_net_wait_time         | 3324        |
| Rpl_semi_sync_master_net_waits             | 3           |
| Rpl_semi_sync_master_no_times              | 1           |
| Rpl_semi_sync_master_no_tx                 | 2           |
| Rpl_semi_sync_master_status                | ON          |
| Rpl_semi_sync_master_timefunc_failures     | 0           |
| Rpl_semi_sync_master_tx_avg_wait_time      | 467         |
| Rpl_semi_sync_master_tx_wait_time          | 467         |
| Rpl_semi_sync_master_tx_waits              | 1           |
| Rpl_semi_sync_master_wait_pos_backtraverse | 0           |
| Rpl_semi_sync_master_wait_sessions         | 0           |
| Rpl_semi_sync_master_yes_tx                | 1           |
| Rpl_status                                 | AUTH_MASTER |
+--------------------------------------------+-------------+

###percona-tools工具，mysql管理工具
参考链接：https://www.percona.com/
[root@mysql-slave download]# wget https://www.percona.com/downloads/percona-toolkit/2.2.2/RPM/percona-toolkit-2.2.2-1.noarch.rpm
[root@mysql-slave download]# rpm -ivh percona-toolkit-2.2.2-1.noarch.rpm  #rpm安装需要依赖
warning: percona-toolkit-2.2.2-1.noarch.rpm: Header V4 DSA/SHA1 Signature, key ID cd2efd2a: NOKEY
error: Failed dependencies:
        perl(DBI) >= 1.13 is needed by percona-toolkit-2.2.2-1.noarch
        perl(DBD::mysql) >= 1.0 is needed by percona-toolkit-2.2.2-1.noarch
        perl(IO::Socket::SSL) is needed by percona-toolkit-2.2.2-1.noarch
[root@mysql-slave download]# yum -y localinstall percona-toolkit-2.2.2-1.noarch.rpm --nogpgcheck #用yum localinstall安装解决依赖关系
[root@mysql-slave download]# vim /etc/my.cnf #确定my.cnf配置文件未被更改
[root@mysql-slave download]# pt #安装好后pt开头的命令
pt-align                  pt-index-usage            pt-slave-restart
pt-archiver               pt-ioprofile              pt-stalk
ptaskset                  pt-kill                   pt-summary
pt-config-diff            pt-mext                   pt-table-checksum
pt-deadlock-logger        pt-mysql-summary          pt-table-sync
pt-diskstats              pt-online-schema-change   pt-table-usage
pt-duplicate-key-checker  pt-pmp                    pt-upgrade
pt-fifo-split             pt-query-digest           pt-variable-advisor
pt-find                   pt-show-grants            pt-visual-explain
pt-fingerprint            pt-sift                   ptx
pt-fk-error-logger        pt-slave-delay            
pt-heartbeat              pt-slave-find        
#pt-ioprofile  #评估io的能力

#####设置主-主复制
##主服务器1：
[root@mysql-master download]# vim /etc/my.cnf
log-bin=master-bin
log-bin-index=master-bin.index
relay-log=relay-master
relay-log-index=relay-master.index
auto-increment-increment = 2
auto-increment-offset=1
server-id = 10
mysql> GRANT REPLICATION SLAVE ON *.* TO repluser@'192.168.1.%' IDENTIFIED BY 'replpass';
mysql> flush privileges;

##主服务器2：
[root@mysql-slave download]# vim /etc/my.cnf
log-bin=mysql-bin
log-bin-index=mysql-bin.index
relay-log = relay-master
relay-log-index = relay-master.index
auto-increment-increment=2
auto-increment-offset=2
server-id = 20
mysql> GRANT REPLICATION SLAVE ON *.* TO repluser@'192.168.1.%' IDENTIFIED BY 'replpass';
mysql> flush privileges;

#mysql终端操作
mysql> show master status;  #主服务器2
+-------------------+----------+--------------+------------------+
| File              | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+-------------------+----------+--------------+------------------+
| master-bin.000002 |      107 |              |                  |
+-------------------+----------+--------------+------------------+
mysql> show master status;  #主服务器1
+-------------------+----------+--------------+------------------+
| File              | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+-------------------+----------+--------------+------------------+
| master-bin.000001 |      107 |              |                  |
+-------------------+----------+--------------+------------------+
mysql> CHANGE MASTER TO MASTER_HOST='192.168.1.31',MASTER_USER='repluser',MASTER_PASSWORD='replpass',MASTER_LOG_FILE='master-bin.000001',MASTER_LOG_POS=107;  #主服务器2设置
mysql> START SLAVE; #主服务器2
mysql> SHOW SLAVE STATUS\G;  #主服务器2
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.1.31
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000001
          Read_Master_Log_Pos: 107
               Relay_Log_File: relay-master.000002
                Relay_Log_Pos: 254
        Relay_Master_Log_File: master-bin.000001
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 107
              Relay_Log_Space: 407
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 10
mysql> CHANGE MASTER TO MASTER_HOST='192.168.1.37',MASTER_USER='repluser',MASTER_PASSWORD='replpass',MASTER_LOG_FILE='master-bin.000002',MASTER_LOG_POS=107;  #主服务器1设置
mysql> START SLAVE; #主服务器1
mysql> SHOW SLAVE STATUS \G;  #主服务器1
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.1.37
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000002
          Read_Master_Log_Pos: 107
               Relay_Log_File: relay-master.000002
                Relay_Log_Pos: 254
        Relay_Master_Log_File: master-bin.000002
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 107
              Relay_Log_Space: 407
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 20

##mysql使用ssl连接：
mysql> show global variables like '%ssl%';
+---------------+----------+
| Variable_name | Value    |
+---------------+----------+
| have_openssl  | DISABLED |
| have_ssl      | DISABLED | #是否开启ssl功能, 不可写变量,需要指定证书和key即可开启
| ssl_ca        |          |
| ssl_capath    |          |
| ssl_cert      |          |
| ssl_cipher    |          |
| ssl_key       |          |
+---------------+----------+
mysql> grant all on *.* to jack@'%' identified by 'jackli' REQUIRE SSL; #设置需要ssl认证的用户登录
#cakey.pem建立：
[root@mysql-slave CA]# （umask 077;openssl genrsa -out private/cakey.pem 2048)
[root@mysql-slave CA]# openssl req -new -x509 -key private/cakey.pem -out cacert.pem -days 3650
#建立CA需要的文件
[root@mysql-slave CA]# touch index.txt
[root@mysql-slave CA]# touch serial
[root@mysql-slave CA]# echo 01 > serial
#客户端生成key:
[root@mysql-slave data]# openssl genrsa -out ./mysql.key 1024
#客户端生成csr证书请求文件:
[root@mysql-slave data]# openssl req -new -key mysql.key -out mysql.csr
#CA签署证书请求文件生成证书：
[root@mysql-slave data]# openssl ca -in mysql.csr -out mysql.crt -days 3650
#复制ca证书及mysql证书和私钥到/mydata/data/ssl目录下
[root@mysql-slave data]# mv mysql.crt mysql.key ssl/
[root@mysql-slave data]# cp /etc/pki/CA/cacert.pem ./ssl/
[root@mysql-slave data]# ls ssl/
cacert.pem  mysql.crt  mysql.key
#生成客户端证书及密钥
[root@mysql-slave ssl]# openssl genrsa -out ./client.key 1024
[root@mysql-slave ssl]# openssl req -new -key client.key -out client.csr 
[root@mysql-slave ssl]# openssl ca -in client.csr -out client.crt -days 3650
[root@mysql-slave data]# chown -R mysql.mysql /mydata
[root@mysql-slave ssl]# mysql -ujack -h 192.168.1.37 -p --ssl-cert=/mydata/data/ssl/client.crt --ssl-key=/mydata/data/ssl/client.key
Enter password:    #/my.cnf文件上要写明ca证书路径，mysql的私钥和公钥路径，
mysql> show global variables like '%ssl%';
+---------------+-----------------------------+
| Variable_name | Value                       |
+---------------+-----------------------------+
| have_openssl  | YES                         |
| have_ssl      | YES                         |
| ssl_ca        | /mydata/data/ssl/cacert.pem |
| ssl_capath    |                             |
| ssl_cert      | /mydata/data/ssl/mysql.crt  |
| ssl_cipher    |                             |
| ssl_key       | /mydata/data/ssl/mysql.key  |
+---------------+-----------------------------+

#SSL主主复制
#主服务器1:
mysql> grant replication slave on *.* to 'repluser'@'192.168.1.%' require ssl; #设定此用户复制到从服务器时必须使用ssl认证
mysql> change master to master_host='192.168.1.37',master_user='repluser',master_password='replpass',master_log_file='master-bin.000001',master_log_pos=367; #主服务器2连接时未使用ssl连接
mysql> show slave status\G;
               Slave_IO_State: Connecting to master
                  Master_Host: 192.168.1.37
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000001
          Read_Master_Log_Pos: 367
               Relay_Log_File: relay-master.000001
                Relay_Log_Pos: 4
        Relay_Master_Log_File: master-bin.000001
             Slave_IO_Running: Connecting  #因为主服务器配置必须使用证书才可登录,这里未使用所以一直显示连接中状态
            Slave_SQL_Running: Yes

mysql> change master to master_host='192.168.1.37',master_user='repluser',master_password='replpass',master_log_file='master-bin.000001',master_log_pos=367,master_ssl=1,master_ssl_cert='/mydata/data/ssl/mysql.crt',master_ssl_key='/mydata/data/ssl/mysql.key',master_ssl_ca='/mydata/data/ssl/cacert.pem';  #使用主服务器的证书、密钥和ca证书
mysql> start slave;
mysql> show slave status\G;
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.1.37
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000003
          Read_Master_Log_Pos: 349
               Relay_Log_File: relay-master.000004
                Relay_Log_Pos: 496
        Relay_Master_Log_File: master-bin.000003
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 349
              Relay_Log_Space: 50283
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: Yes
           Master_SSL_CA_File: /mydata/data/ssl/cacert.pem #192.168.1.37上的ca证书
           Master_SSL_CA_Path: 
              Master_SSL_Cert: /mydata/data/ssl/mysql.crt #192.168.1.37mysql配置文件上的证书
            Master_SSL_Cipher: 
               Master_SSL_Key: /mydata/data/ssl/mysql.key #192.168.1.37mysql配置文件上的私钥
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 20
#注:从服务器上的ca证书,客户端证书和私钥必须和主服务器的证书和密钥,也就是说主服务器需要同从服务器帐户进行ssl认证时,主服务器必须先设定好ca证书,客户端证书和私钥文件发送给从，让从进行使用.这边只做了单主ssl加密,另外单主跟这一样操作,这里不再列出.

#第三节：MYSQL5.6基于GTID及多线程的复制
#数据库(MYSQL)复制过滤:
主服务器上使用:
	binlog-do-db:将指定数据库的相关修改操作记入二进制日志
	binlog-ignore-db:将指定数据库的相关修改操作忽略不记入二进制日志	
	注:不建议在主服务器修改,会导致二进制文件丢失,无法即时点还原
从服务器上使用:
	replicate-do-db:只应用哪些数据库
	replicate-ignore-db:只忽略哪些数据库
	replicate-do-table:只应用哪些表
	replicate-ignore-table:只忽略哪些表
	replicate-wild-do-table:以通配符只应用哪些表
	replicate-wild-ignore-table:以通配符只忽略哪些表
	注:这上面的每个参数可以多次使用
[root@mysql-slave ~]# vim /etc/my.cnf
replicate-do-db = gtid
mysql> show slave status\G;
Replicate_Do_DB: gtid #会显示只复制这个数据库这行
mysql> create database mydb; #主服务器新建数据库mydb
mysql> show databases; #从未同步
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| ssl                |
| test               |
+--------------------+
mysql> create database gtid; #主服务器新建gtid数据库
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| gtid               |  #从服务器过滤成功复制了
| mysql              |
| performance_schema |
| ssl                |
| test               |
+--------------------+

###MySQL-5.6:GTID(global transaction identifiles)
slave-parallel-workers:表示启用几个SQL_Thread线程,0为禁用.每个SQL_Thread线程只能复制一个数据库
#GTID只支持Python2.7+,
https://launchpad.net/mysql-utilities
流程:replicate-->check-->show-->HA
1. mysqlreplicate(复制相关工具):实现快速启动mysql从服务器的,通过追踪gtid知道哪些事务完成,跳过已经执行的事务,从未执行的事务开始复制
2. mysqlrpcheck:用户实现简单验证我们的部署,并实现快速故障修复等功能.
3. mysqlrplshow:发现并显示主从复制拓扑图,并显示主机名和端口号
4. mysqlfailover:故障转移工具,能够快速让你自动或手动提升一个slave为master的,提升master之前slave会从其他slave复制本身不具备的事务并重放后提升自己为master
5. mysqlrpladmin:调度管理工具,手动让某一个节点启动或下线

####基于MYSQL5.6的GTID实现复制功能
#1. 配置master节点
[mysqld]
binlog-format=ROW  #二进制日志格式
log-bin=master-bin  #启用二进制日志
log-slave-update=true  #获取其他从服务器的日志记录到自己的二进制日志中，为了以后提升自己为主服务器做准备，必须启用二进制日志
gtid-mode=on  #开启gtid，否则跟5.5的复制功能一样
enforce-gtid-consistency=true  #强制开启gtid的一致性检查，可防止二进制日志文件数据不一致的
master-info-repository=TABLE  #master.info文件记录到表中，默认是FILE
relay-log-info-repository=TABLE #relay-log.info文件记录到表中，默认是FILE
sync-master-info=1  #同步从节点执行二进制日志事件所在的文件及位置到master.info中，确保下次从节点再次读取的准确性和完整性
slave-parallel-workers=2  #设定从服务器的SQL线程数，0表示关闭多线程复制功能，只能等于小于数据库个数
binlog-checksum=CRC32  #指定二进制日志文件校验算法，启用复制有关的所有检验功能
master-verify-checksum=1 #启用验证主服务器binlog的校验码，启用复制有关的所有检验功能
slave-sql-verify-checksum=1  #启用验证从服务器binlog的校验码，启用复制有关的所有检验功能
binlog-rows-query-log_events=1 #启用可以在二进制日志记录事件相关的信息，可降低故障排除的复杂度，但会降低服务器的io性能
server-id=11 #服务器id
report-port=3306  #报告主机的端口
port=3306 #mysqld服务端口
datadir=/tmp/mysql.sock  #套接字文件 
report-host=192.168.1.31 #报告主机的地址
#2. 配置slave节点
[mysqld]
binlog-format=ROW  #二进制日志格式
relay-log=relay-log  #启用中继日志
log-slave-update=true  #获取其他服务器的日志记录到自己的二进制日志中
gtid-mode=on  #开启gtid，否则跟5.5的复制功能一样
enforce-gtid-consistency=true  #强制开始gtid的一致性，可防止数据不一至的
master-info-repository=TABLE  #master.info文件记录到表中，默认是FILE
relay-log-info-repository=TABLE #relay-log.info文件记录到表中，默认是FILE
sync-master-info=1  #同步信息到master.info中，确保无信息丢失的
slave-parallel-workers=2  #设定从服务器的SQL线程数，0表示关闭多线程复制功能
binlog-checksum=CRC32  #指定二进制日志文件校验算法，启用复制有关的所有检验功能
master-verify-checksum=1 #启用验证主服务器binlog的校验码，启用复制有关的所有检验功能
slave-sql-verify-checksum=1  #启用验证从服务器binlog的校验码，启用复制有关的所有检验功能
binlog-rows-query-log_events=1 #启用可以在二进制日志记录事件相关的信息，可降低故障排除的复杂度
server-id=11 #服务器id
report-port=3306  #报告主机的端口
port=3306 #mysqld服务端口
datadir=/tmp/mysql.sock  #套接字文件 
report-host=192.168.1.37  #报告主机的地址
read_only=1 #设置从节点为只读
#注：如果使用了HA功能，需要把从提升为主，那么需要在从服务器上设置开启二进制日志文件log-bin=master-bin
注：在gtid模式下，每个server将会随机生成一个uuid，uuid补上一个事务号就成了gtid
#3. 创建复制用户
mysql> GRANT REPLICATION SLAVE ON *.* TO repluser@'192.168.1.%' IDENTIFIED BY 'replpass';
#4. 为备节点提供初始数据库
锁定主表，备份主节点上的数据，将其还原至从节点：如果没有启用GTID,在备份时需要在master上使用show master status 命令查看二进制日志文件名称及事件位置，以便后面启动slave节点时使用
#5. 启动从节点的复制线程
mysql> CHANGE MASTER TO MASTER_HOST='192.168.1.31',MASTER_USER='repluser',MASTER_PASSWORD='replpass',MASTER_AUTO_POSITION=1;
没启用GTID功能,需要使用如下命令：
mysql> CHANGE MASTER TO MASTER_HOST='192.168.1.31',MASTER_USER='repluser',MASTER_PASSWORD='replpass',MASTER_LOG_FILE='master-bin.000001',MASTER_LOG_POS=1174;

###实例：
#注：将来无论在任何集群或高可用上都要做到时间的同步
mysql> show global variables like '%gtid%'; #查看是否启用了gtid,5.5下未启用gtid功能，所以未有值
mysql> show global variables like '%uuid%';
show warnings; #查看警告消息
show slave hosts; #查看从节点主机的信息
#mysql5.6半同步和mysql5.5一样。mysql5.5和mysql5.6主从复制没什么太大差别，就是多了个GTID功能 

#主节点配置：
[root@mysql-slave mysql]# id mysql
uid=3306(mysql) gid=3306(mysql) groups=3306(mysql)
[root@mysql-master mysql]# chown -R mysql.mysql /mydata/
1. [root@mysql-master mysql]# tar xf mysql-5.6.43-linux-glibc2.12-x86_64.tar.gz -C /usr/local/
2. [root@mysql-master mysql]# ln -sv /usr/local/mysql-5.6.43-linux-glibc2.12-x86_64/ /usr/local/mysql
3. [root@mysql-master mysql]# yum install -y autoconf #解决报错问题
4. [root@mysql-master mysql]# scripts/mysql_install_db --user=mysql --datadir=/mydata/data
5. [root@mysql-master mysql]# cp support-files/mysql.server /etc/init.d/mysqld
6. [root@mysql-master mysql]# chkconfig --add mysqld
7. [root@mysql-master mysql]# cat /etc/profile.d/mysqld.sh 
export PATH=$PATH:/usr/local/mysql/bin
8. [root@mysql-master mysql]# . /etc/profile.d/mysqld.sh
9. [root@mysql-master mysql]# egrep -v '#|^$' /usr/local/mysql/my.cnf 
[mysqld]
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES 
datadir=/mydata/data
socket=/tmp/mysql.sock
server_id=1
log-bin=master-bin
log-slave-update=true
gtid-mode=on
enforce-gtid-consistency=true
master-info-repository=TABLE
relay-log-info-repository=TABLE
sync-master-info=1
slave-parallel-workers=2
binlog-checksum=CRC32
master-verify-checksum=1
slave-sql-verify-checksum=1
binlog-rows-query-log_events=1
report-port=3306
report-host=192.168.1.31
port=3306
[root@mysql-master mysql]# chown -R root.mysql /usr/local/mysql
10. [root@mysql-master mysql]# service mysqld start
11. mysql> show global variables like '%gtid%';
+---------------------------------+-------+
| Variable_name                   | Value |
+---------------------------------+-------+
| binlog_gtid_simple_recovery     | OFF   |
| enforce_gtid_consistency        | ON    |
| gtid_executed                   |       |
| gtid_mode                       | ON    |  #已经开启gtid
| gtid_owned                      |       |
| gtid_purged                     |       |
| simplified_binlog_gtid_recovery | OFF   |
+---------------------------------+-------+
12. mysql> show global variables like '%uuid%';
+---------------+--------------------------------------+
| Variable_name | Value                                |
+---------------+--------------------------------------+
| server_uuid   | cc9c8cb8-9c66-11e9-9eb9-000c29ee3e65 |  #因为开启了gtid所以会生成uuid
+---------------+--------------------------------------+
13. mysql> mysql> show master status; #查看主节点状态
+-------------------+----------+--------------+------------------+-------------------+
| File              | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+-------------------+----------+--------------+------------------+-------------------+
| master-bin.000001 |      151 |              |                  |                   |
+-------------------+----------+--------------+------------------+-------------------+
14. mysql> show slave hosts; 
Empty set (0.00 sec) #因为还未有从节点加入，所以为空

#从节点配置
[root@mysql-slave mysql]# id mysql
uid=3306(mysql) gid=3306(mysql) groups=3306(mysql)
[root@mysql-master mysql]# chown -R mysql.mysql /mydata/
1. [root@mysql-slave download]# tar xf mysql-5.6.43-linux-glibc2.12-x86_64.tar.gz -C /usr/local/
2. [root@mysql-slave download]# ln -sv /usr/local/mysql-5.6.43-linux-glibc2.12-x86_64/ /usr/local/mysql
‘/usr/local/mysql’ -> ‘/usr/local/mysql-5.6.43-linux-glibc2.12-x86_64/’
3. [root@mysql-slave mysql]# chown -R root.mysql /usr/local/mysql
4. [root@mysql-slave mysql]# yum install -y autoconf #解决报错问题
5. [root@mysql-slave mysql]# scripts/my
6. sql_install_db --user=mysql --datadir=/mydata/data
6. [root@mysql-slave mysql]# cp support-files/mysql.server /etc/init.d/mysqld
7. [root@mysql-slave mysql]# chkconfig --add mysqld
8. [root@mysql-slave mysql]# egrep -v '#|^$' /usr/local/mysql/my.cnf 
[mysqld]
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES 
datadir=/mydata/data
socket=/tmp/mysql.sock
server_id=11
log-bin=master-bin
log-slave-update=true
relay-log=relay-log
gtid-mode=on
enforce-gtid-consistency=true
master-info-repository=TABLE
relay-log-info-repository=TABLE
sync-master-info=1
slave-parallel-workers=2
binlog-checksum=CRC32
master-verify-checksum=1
slave-sql-verify-checksum=1
binlog-rows-query-log_events=1
report-port=3306
report-host=192.168.1.37
port=3306
read-only=1
9. [root@mysql-slave mysql]# service mysqld start
10. mysql> show global variables like '%gtid%';
+---------------------------------+-------+
| Variable_name                   | Value |
+---------------------------------+-------+
| binlog_gtid_simple_recovery     | OFF   |
| enforce_gtid_consistency        | ON    |
| gtid_executed                   |       |
| gtid_mode                       | ON    |
| gtid_owned                      |       |
| gtid_purged                     |       |
| simplified_binlog_gtid_recovery | OFF   |
+---------------------------------+-------+
11. mysql> show global variables like '%uuid%';
+---------------+--------------------------------------+
| Variable_name | Value                                |
+---------------+--------------------------------------+
| server_uuid   | c38be2e6-9c68-11e9-9ec6-000c29303e31 |
+---------------+--------------------------------------+
12. mysql> show master status;
+-------------------+----------+--------------+------------------+-------------------+
| File              | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+-------------------+----------+--------------+------------------+-------------------+
| master-bin.000001 |      151 |              |                  |                   |
+-------------------+----------+--------------+------------------+-------------------+
13. mysql> show slave status;
Empty set (0.00 sec)  #因为这个做从节点，而别的节点未把此从节点当做主节点，所以为空
#从节点加入主节点
1. mysql> grant replication slave on *.* to repluser@'192.168.1.%' identified by 'replpass'; #主节点设置帐户
2. mysql> change master to master_host='192.168.1.31',master_user='repluser',master_password='replpass',master_auto_position=1; #从节点加入主节点
3. mysql> show slave status\G;
*************************** 1. row ***************************
               Slave_IO_State: 
                  Master_Host: 192.168.1.31
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: 
          Read_Master_Log_Pos: 4
               Relay_Log_File: mysql-slave-relay-bin.000001
                Relay_Log_Pos: 4
        Relay_Master_Log_File: 
             Slave_IO_Running: No #还未开启IO_THREAD和SQL_THREAD
            Slave_SQL_Running: No
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 0
              Relay_Log_Space: 151
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: NULL
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 0
                  Master_UUID: 
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: 
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: 
            Executed_Gtid_Set: 
                Auto_Position: 1
4. mysql> start slave;
5. mysql> show slave status\G;
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.1.31
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000001
          Read_Master_Log_Pos: 411
               Relay_Log_File: mysql-slave-relay-bin.000002
                Relay_Log_Pos: 623
        Relay_Master_Log_File: master-bin.000001
             Slave_IO_Running: Yes  #已经开启
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 411
              Relay_Log_Space: 833
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 1
                  Master_UUID: cc9c8cb8-9c66-11e9-9eb9-000c29ee3e65
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for the slave I/O thread to update it
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: cc9c8cb8-9c66-11e9-9eb9-000c29ee3e65:1
            Executed_Gtid_Set: cc9c8cb8-9c66-11e9-9eb9-000c29ee3e65:1
                Auto_Position: 1
6. mysql> show slave hosts;  #查看从节点信息
+-----------+--------------+------+-----------+--------------------------------------+
| Server_id | Host         | Port | Master_id | Slave_UUID                           |
+-----------+--------------+------+-----------+--------------------------------------+
|        11 | 192.168.1.37 | 3306 |         1 | c38be2e6-9c68-11e9-9ec6-000c29303e31 |
+-----------+--------------+------+-----------+--------------------------------------+
7. [root@mysql-master download]# mysql -u root -p wordpress < wordpress.sql  #主节点导入数据库
8. [root@mysql-slave mysql]# mysql -u root -p -e 'show databases'
Enter password: 
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| test               |
| wordpress          |  #从节点同步了
+--------------------+

###MYSQL-PROXY
memcached是旁路服务器，只是一个API
mysql proxy(需要lua插件)，amoeba(阿里巴巴开源的mysql读写分时软件)
mysql-mmm另外一个项目，是对mysql多主复制的管理工具，可以使mysql多主功能更好

mysql-proxy依赖包：
	libevent,lua,glib2,pkg-config,libtool,mysql-devel
rpm -q lua #确保已经安装lua，才可安装mysql-proxy
#源代码安装：
	./configure
	make && make install 

#使用通用二进制安装：
[root@lnmp mysql-proxy]# rpm -qa | grep lua #确保lua已经安装
lua-5.1.4-15.el7.x86_64
[root@lnmp download]# wget https://downloads.mysql.com/archives/get/file/mysql-proxy-0.8.3-linux-glibc2.3-x86-64bit.tar.gz
[root@lnmp download]# useradd -r mysql-proxy
[root@lnmp download]# tar xf mysql-proxy-0.8.3-linux-glibc2.3-x86-64bit.tar.gz -C /usr/local/
[root@lnmp download]# ln -sv /usr/local/mysql-proxy-0.8.3-linux-glibc2.3-x86-64bit/ /usr/local/mysql-proxy
‘/usr/local/mysql-proxy’ -> ‘/usr/local/mysql-proxy-0.8.3-linux-glibc2.3-x86-64bit/’
[root@lnmp mysql-proxy]# echo 'export PATH=$PATH:/usr/local/mysql-proxy/bin' > /etc/profile.d/mysql-proxy.sh
[root@lnmp mysql-proxy]# . /etc/profile.d/mysql-proxy.sh 
[root@lnmp mysql-proxy]# mysql-proxy --help-all
Usage:
  mysql-proxy [OPTION...] - MySQL Proxy

Help Options:
  -?, --help                                              Show help options
  --help-all                                              Show all help options
  --help-proxy                                            Show options for the proxy-module

proxy-module
  -P, --proxy-address=<host:port>                         #mysql-proxy地址
  -r, --proxy-read-only-backend-addresses=<host:port>     #只读后端服务器
  -b, --proxy-backend-addresses=<host:port>               #读写后端服务器
  --proxy-skip-profiling                                  disables profiling of queries (default: enabled)
  --proxy-fix-bug-25371                                   fix bug #25371 (mysqld > 5.1.12) for older libmysql versions
  -s, --proxy-lua-script=<file>                           #lua脚本路径
  --no-proxy                                              don't start the proxy-module (default: enabled)
  --proxy-pool-no-change-user                             don't use CHANGE_USER to reset the connection coming from the pool (default: enabled)
  --proxy-connect-timeout                                 #写超时时长
  --proxy-read-timeout                                    #读超时时长
  --proxy-write-timeout                                   #写超时时长

Application Options:
  -V, --version                                           Show version
  --defaults-file=<file>                                  #默认读取的配置文件路径
  --verbose-shutdown                                      Always log the exit code when shutting down
  --daemon                                                Start in daemon-mode
  --user=<user>                                           Run mysql-proxy as user
  --basedir=<absolute path>                               Base directory to prepend to relative paths in the config
  --pid-file=<file>                                       PID file in case we are started as daemon
  --plugin-dir=<path>                                     path to the plugins
  --plugins=<name>                                        plugins to load
  --log-level=(error|warning|info|message|debug)          log all messages of level ... or higher
  --log-file=<file>                                       log all messages in a file
  --log-use-syslog                                        log all messages to syslog
  --log-backtrace-on-crash                                try to invoke debugger on crash
  --keepalive                                             #在mysql-proxy崩溃时重启mysql-proxy
  --max-open-files                                        maximum number of open files (ulimit -n)
  --event-threads                                         number of event-handling threads (default: 1)
  --lua-path=<...>                                        set the LUA_PATH
  --lua-cpath=<...>                                       set the LUA_CPATH

[root@lnmp mysql-proxy]# mysql-proxy --daemon --log-level=debug --log-file=/var/log/mysql-proxy.log --plugins="proxy" --proxy-backend-addresses="192.168.1.31:3306" --proxy-read-only-backend-addresses="192.168.1.37:3306" #开启mysql-proxy，运行在4040端口，--plugins="proxy"必须开启proxy插件，否则无法启动
[root@lnmp mysql-proxy]# tail /var/log/mysql-proxy.log 
2019-07-02 22:44:50: (critical) plugin proxy 0.8.3 started
2019-07-02 22:44:50: (debug) max open file-descriptors = 1024
2019-07-02 22:44:50: (message) proxy listening on port :4040
2019-07-02 22:44:50: (message) added read/write backend: 192.168.1.31:3306
2019-07-02 22:44:50: (message) added read-only backend: 192.168.1.37:3306
#注：此时可以连接192.168.1.233:4040进行连接主从服务器，但mysql-proxy不会给我们进行读写分离，要想读写分离必须借助lua脚本才可实现

[root@lnmp mysql-proxy]# ls /usr/local/mysql-proxy/share/doc/mysql-proxy
active-queries.lua       ro-balance.lua           tutorial-resultset.lua
active-transactions.lua  ro-pooling.lua           tutorial-rewrite.lua
admin-sql.lua            rw-splitting.lua         tutorial-routing.lua
analyze-query.lua        tutorial-basic.lua       tutorial-scramble.lua
auditing.lua             tutorial-constants.lua   tutorial-states.lua
commit-obfuscator.lua    tutorial-inject.lua      tutorial-tokenize.lua
commit-obfuscator.msc    tutorial-keepalive.lua   tutorial-union.lua
COPYING                  tutorial-monitor.lua     tutorial-warnings.lua
histogram.lua            tutorial-packets.lua     xtab.lua
load-multi.lua           tutorial-prep-stmts.lua
README                   tutorial-query-time.lua
#注： rw-splitting.lua这个脚本是实现读写分离的
[root@lnmp mysql-proxy]# killall mysql-proxy #先停掉服务
[root@lnmp mysql-proxy]# mysql-proxy --daemon --log-level=debug --log-file=/var/log/mysql-proxy.log --plugins="proxy" --proxy-backend-addresses="192.168.1.31:3306" --proxy-read-only-backend-addresses="192.168.1.37:3306" --proxy-lua-script="/usr/local/mysql-proxy/share/doc/mysql-proxy/rw-splitting.lua" #加入读写分离功能
[root@lnmp mysql-proxy]# cat /usr/local/mysql-proxy/share/doc/mysql-proxy/admin.lua 
---------------------mysql-proxy admin插件lua脚本--------------------------
function set_error(errmsg) 
        proxy.response = {
                type = proxy.MYSQLD_PACKET_ERR,
                errmsg = errmsg or "error"
        }
end

function read_query(packet)
        if packet:byte() ~= proxy.COM_QUERY then
                set_error("[admin] we only handle text-based queries (COM_QUERY)")
                return proxy.PROXY_SEND_RESULT
        end

        local query = packet:sub(2)

        local rows = { }
        local fields = { }

        if query:lower() == "select * from backends" then
                fields = { 
                        { name = "backend_ndx", 
                          type = proxy.MYSQL_TYPE_LONG },

                        { name = "address",
                          type = proxy.MYSQL_TYPE_STRING },
                        { name = "state",
                          type = proxy.MYSQL_TYPE_STRING },
                        { name = "type",
                          type = proxy.MYSQL_TYPE_STRING },
                        { name = "uuid",
                          type = proxy.MYSQL_TYPE_STRING },
                        { name = "connected_clients", 
                          type = proxy.MYSQL_TYPE_LONG },
                }

                for i = 1, #proxy.global.backends do
                        local states = {
                                "unknown",
                                "up",
                                "down"
                        }
                        local types = {
                                "unknown",
                                "rw",
                                "ro"
                        }
                        local b = proxy.global.backends[i]

                        rows[#rows + 1] = {
                                i,
                                b.dst.name,          -- configured backend address
                                states[b.state + 1], -- the C-id is pushed down starting at 0
                                types[b.type + 1],   -- the C-id is pushed down starting at 0
                                b.uuid,              -- the MySQL Server's UUID if it is managed
                                b.connected_clients  -- currently connected clients
                        }
                end
        elseif query:lower() == "select * from help" then
                fields = { 
                        { name = "command", 
                          type = proxy.MYSQL_TYPE_STRING },
                        { name = "description", 
                          type = proxy.MYSQL_TYPE_STRING },
                }
                rows[#rows + 1] = { "SELECT * FROM help", "shows this help" }
                rows[#rows + 1] = { "SELECT * FROM backends", "lists the backends and their state" }
        else
                set_error("use 'SELECT * FROM help' to see the supported commands")
                return proxy.PROXY_SEND_RESULT
        end

        proxy.response = {
                type = proxy.MYSQLD_PACKET_OK,
                resultset = {
                        fields = fields,
                        rows = rows
                }
        }
        return proxy.PROXY_SEND_RESULT
end
---------------------
[root@lnmp mysql-proxy]# killall mysql-proxy #先停掉服务
[root@lnmp mysql-proxy]# mysql-proxy --daemon --log-level=debug --log-file=/var/log/mysql-proxy.log --plugins="proxy" --proxy-backend-addresses="192.168.1.31:3306" --proxy-read-only-backend-addresses="192.168.1.37:3306" --proxy-lua-script="/usr/local/mysql-proxy/share/doc/mysql-proxy/rw-splitting.lua" --plugins=admin --admin-username="admin" --admin-password="admin" --admin-lua-script="/usr/local/mysql-proxy/share/doc/mysql-proxy/admin.lua" #重新启动，并再加新功能开启admin
[root@lnmp mysql-proxy]# tail /var/log/mysql-proxy.log 
2019-07-02 23:01:46: (message) shutting down normally, exit code is: 0
2019-07-02 23:04:38: (critical) mysql-proxy-cli.c:503: Unknown option --admin-lua-scripts=/usr/local/mysql-proxy/share/doc/mysql-proxy/admin.lua (use --help to show all options)
2019-07-02 23:04:38: (message) Initiating shutdown, requested from mysql-proxy-cli.c:513
2019-07-02 23:04:38: (message) shutting down normally, exit code is: 1
2019-07-02 23:05:24: (critical) plugin proxy 0.8.3 started
2019-07-02 23:05:24: (critical) plugin admin 0.8.3 started
2019-07-02 23:05:24: (debug) max open file-descriptors = 1024
2019-07-02 23:05:24: (message) proxy listening on port :4040  #已经启动
2019-07-02 23:05:24: (message) added read/write backend: 192.168.1.31:3306
2019-07-02 23:05:24: (message) added read-only backend: 192.168.1.37:3306
[root@lnmp mysql-proxy]# netstat -tnlp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:4040            0.0.0.0:*               LISTEN      2643/mysql-proxy    #这个是mysql-proxy代理端口
tcp        0      0 127.0.0.1:9000          0.0.0.0:*               LISTEN      19324/php-fpm: pool 
tcp        0      0 0.0.0.0:4041            0.0.0.0:*               LISTEN      2643/mysql-proxy    #这个是管理接口
tcp        0      0 0.0.0.0:3306            0.0.0.0:*               LISTEN      6663/mysqld         
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      1/systemd           
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      29371/nginx: master 
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      4902/sshd           
tcp        0      0 0.0.0.0:10050           0.0.0.0:*               LISTEN      29685/zabbix_agentd 
tcp6       0      0 :::8009                 :::*                    LISTEN      24764/java          
tcp6       0      0 :::42445                :::*                    LISTEN      24764/java          
tcp6       0      0 :::111                  :::*                    LISTEN      1/systemd           
tcp6       0      0 :::8080                 :::*                    LISTEN      24764/java          
tcp6       0      0 :::22                   :::*                    LISTEN      4902/sshd           
tcp6       0      0 :::8888                 :::*                    LISTEN      24764/java          
tcp6       0      0 :::35192                :::*                    LISTEN      24764/java          
tcp6       0      0 :::10050                :::*                    LISTEN      29685/zabbix_agentd 
tcp6       0      0 :::10052                :::*                    LISTEN      28163/java          
tcp6       0      0 127.0.0.1:8005          :::*                    LISTEN      24764/java          
#测试：
mysql> grant all on *.* to root@'192.%' identified by 'redhat'; #连接到主建立可访问用户
mysql> flush privileges;
[root@mysql-slave ~]# mysql -u admin -p -h 192.168.1.233 --port 4041 #连接mysql-proxy admin管理接口，用户密码为设置的admin
Enter password: 
mysql> select * from backends; #连进来后只能使用这个命令查看主从节点信息和状态
+-------------+-------------------+---------+------+------+-------------------+
| backend_ndx | address           | state   | type | uuid | connected_clients |
+-------------+-------------------+---------+------+------+-------------------+
|           1 | 192.168.1.31:3306 | unknown | rw   | NULL |                 0 |
|           2 | 192.168.1.37:3306 | unknown | ro   | NULL |                 0 |
+-------------+-------------------+---------+------+------+-------------------+
[root@mysql-slave ~]# mysql -uroot -p -h 192.168.1.233 -P 4040 #连接mysql代理服务器进行路由
Enter password: 
mysql> create database hellodb; #进行写操作
mysql> select * from backends;
+-------------+-------------------+---------+------+------+-------------------+
| backend_ndx | address           | state   | type | uuid | connected_clients |
+-------------+-------------------+---------+------+------+-------------------+
|           1 | 192.168.1.31:3306 | up      | rw   | NULL |                 0 | #此时这个状态为up，说明写操作路由到主节点上了
|           2 | 192.168.1.37:3306 | unknown | ro   | NULL |                 0 |
+-------------+-------------------+---------+------+------+-------------------+
mysql> select * from backends;
+-------------+-------------------+-------+------+------+-------------------+
| backend_ndx | address           | state | type | uuid | connected_clients |
+-------------+-------------------+-------+------+------+-------------------+
|           1 | 192.168.1.31:3306 | up    | rw   | NULL |                 0 |
|           2 | 192.168.1.37:3306 | up    | ro   | NULL |                 0 | 
+-------------+-------------------+-------+------+------+-------------------+
#经过多个连接查询，此时到从服务器了，因为读写分离lua脚本设置最小4个连接，最大8个连接，所以未达到这个不会到另外一个服务器，读写分离lua脚本那里把它改小了

#####mysql-proxy启动脚本
#注：分为mysql-proxy脚本和/etc/sysconfig/mysql-proxy配置文件
----------------
[root@lnmp mysql-proxy]# cat /etc/init.d/mysql-proxy 
#!/bin/bash
#
# mysql-proxy This script starts and stops the mysql-proxy daemon
#
# chkconfig: - 78 30
# processname: mysql-proxy
# description: mysql-proxy is a proxy daemon for mysql
 
# Source function library.
. /etc/rc.d/init.d/functions
 
prog="/usr/local/mysql-proxy/bin/mysql-proxy"
 
# Source networking configuration.
if [ -f /etc/sysconfig/network ]; then
    . /etc/sysconfig/network
fi
 
# Check that networking is up.
[ ${NETWORKING} = "no" ] && exit 0
 
# Set default mysql-proxy configuration.
ADMIN_USER="admin"
ADMIN_PASSWD="admin"
ADMIN_LUA_SCRIPT="/usr/local/mysql-proxy/share/doc/mysql-proxy/admin.lua"
PROXY_OPTIONS="--daemon"
PROXY_PID=/var/run/mysql-proxy.pid
PROXY_USER="mysql-proxy"
PROXY_ADDRESS="0.0.0.0:4040"
 
# Source mysql-proxy configuration.
if [ -f /etc/sysconfig/mysql-proxy ]; then
    . /etc/sysconfig/mysql-proxy
fi
 
RETVAL=0
 
start() {
    echo -n $"Starting $prog: "
    daemon $prog $PROXY_OPTIONS --pid-file=$PROXY_PID --proxy-address="$PROXY_ADDRESS" --user=$PROXY_USER --admin-username="$ADMIN_USER" --admin-lua-script="$ADMIN_LUA_SCRIPT" --admin-password="$ADMIN_PASSWORD"
    RETVAL=$?
    echo
    if [ $RETVAL -eq 0 ]; then
        touch /var/lock/subsys/mysql-proxy
    fi
}
 
stop() {
    echo -n $"Stopping $prog: "
    killproc -p $PROXY_PID -d 3 $prog
    RETVAL=$?
    echo
    if [ $RETVAL -eq 0 ]; then
        rm -f /var/lock/subsys/mysql-proxy
        rm -f $PROXY_PID
    fi
}
# See how we were called.
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start
        ;;
    condrestart|try-restart)
        if status -p $PROXY_PIDFILE $prog >&/dev/null; then
            stop
            start
        fi
        ;;
    status)
        status -p $PROXY_PID $prog
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|reload|status|condrestart|try-restart}"
        RETVAL=1
        ;;
esac
 
exit $RETVAL
----------------
[root@lnmp mysql-proxy]# cat /etc/sysconfig/mysql-proxy  #mysql-proxy脚本配置文件
# Options for mysql-proxy 
ADMIN_USER="admin"
ADMIN_PASSWORD="admin"
ADMIN_LUA_SCRIPT="/usr/local/mysql-proxy/share/doc/mysql-proxy/admin.lua"
PROXY_LUA_SCRIPT="/usr/local/mysql-proxy/share/doc/mysql-proxy/rw-splitting.lua"
PROXY_ADDRESS="0.0.0.0:3306"
PROXY_USER="mysql-proxy"
PROXY_OPTIONS="--daemon --keepalive=true --log-level=info --log-file=/var/log/mysql-proxy.log --plugins="proxy" --proxy-backend-addresses="192.168.1.31:3306" --proxy-read-only-backend-addresses="192.168.1.37:3306" --proxy-lua-script="$PROXY_LUA_SCRIPT" --plugins="admin" "
----------------


#####mysql优化
#MYISAM配置选项：
key_buffer_size:除开用户使用的内存空间外，尽量的全部分给它。内存存储索引的
concurrent_insert:是否允许并发插入操作，0禁止，2表示空隙时插入，默认是1，表示本身内部没有空隙时才插入
delay_key_write:延迟内存中索引失效时的重新写入的，on或off，
max_write_lock_count:
preload_buffer_size:
#INNODB配置选项：
innodb_flush_log_size:定义innodb缓冲池大小，缓存池包括索引和数据，16G分10G也不过分
innodb_flush_log_at_trx_commit:1表示事务一提交就flush,2表示提交时才flush,前提是关闭了自动提交功能
innodb_file_per_table:每表一个表空间文件
#是否启用查询缓存：
query_cache_size:查询缓存大小，默认是0禁用，只要大于0就启用
query_cache_min_res_unit:设置查询缓存最小单位
query_cache_type:定义查询缓存的类型，ON,OFF,DEMAND(按需缓冲，在查询语句中使用SQL CACHE时才缓存)

#MySQL优化框架
1. SQL语句优化
2. 索引优化
3. 数据库结构优化
4. InnoDB表优化
5. MyISAM表优化
6. Memory表优化
7. 理解查询执行计划
8. 缓冲和缓存
9. 锁优化
10. MySQL服务器优化
11. 性能评估
12. MySQL优化内幕

MySQL优化需要在三个不同层次上协调进行：MySQL级别、OS级别和硬件级别。MySQL级别的优化包括表优化、查询优化和MySQL服务器配置优化等，而MySQL的各种数据结构又最终作用于OS直至硬件设备，因此还需要了解每种结构对OS级别的资源的需要并最终导致的CPU和I/O操作等，并在此基础上将CPU及I/O操作需要尽量降低以提升其效率。

数据库层面的优化着眼点：
1、是否正确设定了表结构的相关属性，尤其是每个字段的字段类型是否为最佳。同时，是否为特定类型的工作组织使用了合适的表及表字段也将影响系统性能，比如，数据频繁更新的场景应该使用较多的表而每张表有着较少字段的结构，而复杂数据查询或分析的场景应该使用较少的表而每张表较多字段的结构等。
2、是否为高效进行查询创建了合适的索引。
3、是否为每张表选用了合适的存储引擎，并有效利用了选用的存储引擎本身的优势和特性。
4、是否基于存储引擎为表选用了合适的行格式(row format)。例如，压缩表在读写操作中会降低I/O操作需求并占用较少的磁盘空间，InnoDB支持读写应用场景中使用压缩表，但MyISAM仅能在读环境中使用压缩表。
5、是否使用了合适的锁策略，如在并发操作场景中使用共享锁，而对较高优先级的需求使用独占锁等。同时，还应该考虑存储引擎所支持的锁类型。
6、是否为InnoDB的缓冲池、MyISAM的键缓存以及MySQL查询缓存设定了合适大小的内存空间，以便能够存储频繁访问的数据且又不会引起页面换出。

操作系统和硬件级别的优化着眼点：
1、是否为实际的工作负载选定了合适的CPU，如对于CPU密集型的应用场景要使用更快速度的CPU甚至更多数量的CPU，为有着更多查询的场景使用更多的CPU等。基于多核以及超线程(hyperthreading)技术，现代的CPU架构越来越复杂、性能也越来越强了，但MySQL对多CPU架构的并行计算能力的利用仍然是有着不太尽如人意之处，尤其是较老的版本如MySQL 5.1之前的版本甚至无法发挥多CPU的优势。不过，通常需要实现的CPU性能提升目标有两类：低迟延和高吞吐量。低延迟需要更快速度的CPU，因为单个查询只能使用一颗；而需要同时运行许多查询的场景，多CPU更能提供更好的吞吐能力，然而其能否奏效还依赖于实际工作场景，因为MySQL尚不能高效的运行于多CPU，并且其对CPU数量的支持也有着限制。一般来说，较新的版本可以支持16至24颗CPU甚至更多。
2、是否有着合适大小的物理内存，并通过合理的配置平衡内存和磁盘资源，降低甚至避免磁盘I/O。现代的程序设计为提高性能通常都会基于局部性原理使用到缓存技术，这对于频繁操作数据的数据库系统来说尤其如此——有着良好设计的数据库缓存通常比针对通用任务的操作系统的缓存效率更高。缓存可以有效地延迟写入、优化写入，但并能消除写入，并综合考虑存储空间的可扩展性等，为业务选择合理的外部存储设备也是非常重要的工作。
3、是否选择了合适的网络设备并正确地配置了网络对整体系统系统也有着重大影响。延迟和带宽是网络连接的限制性因素，而常见的网络问题如丢包等，即是很小的丢包率也会赞成性能的显著下降。而更重要的还有按需调整系统中关网络方面的设置，以高效处理大量的连接和小查询。
4、是否基于操作系统选择了适用的文件系统。实际测试表明大部分文件系统的性能都非常接近，因此，为了性能而苦选文件系统并不划算。但考虑到文件系统的修复能力，应该使用日志文件系统如ext3、ext4、XFS等。同时，关闭文件系统的某些特性如访问时间和预读行为，并选择合理的磁盘调度器通常都会给性能提升带来帮助。
5、MySQL为响应每个用户连接使用一个单独的线程，再加内部使用的线程、特殊目的线程以及其它任何由存储引擎创建的线程等，MySQL需要对这些大量线程进行有效管理。Linux系统上的NPTL线程库更为轻量级也更有效率。MySQL 5.5引入了线程池插件，但其效用尚不明朗。

使用InnoDB存储引擎最佳实践：
1、基于MySQL查询语句中最常用的字段或字段组合创建主键，如果没有合适的主键也最好使用AUTO_INCRMENT类型的某字段为主键。
2、根据需要考虑使用多表查询，将这些表通过外键建立约束关系。
3、关闭autocommit。
4、使用事务(START TRANSACTION和COMMIT语句)组合相关的修改操作或一个整体的工作单元，当然也不应该创建过大的执行单元。
5、停止使用LOCK TABLES语句，InnoDB可以高效地处理来自多个会话的并发读写请求。如果需要在一系列的行上获取独占访问权限，可以使用SELECT ... FOR UPDATE锁定仅需要更新的行。
6、启用innodb_file_per_table选项，将各表的数据和索引分别进行存放。
7、评估数据和访问模式是否能从InnoDB的表压缩功能中受益(在创建表时使用ROW_FORMAT=COMPRESSED选项)，如果可以，则应该启用压缩功能。

EXPLAIN语句解析：
id:SELECT语句的标识符，一般为数字，表示对应的SELECT语句在原始语句中的位置。没有子查询或联合的整个查询只有一个SELECT语句，因此其id通常为1。在联合或子查询语句中，内层的SELECT语句通常按它们在原始语句中的次序进行编号。但UNION操作通常最后会有一个id为NULL的行，因为UNION的结果通常保存至临时表中，而MySQL需要到此临时表中取得结果。
EXPLAN select name from students where age=30; #显示语句执行计划的
select_type:
即SELECT类型，有如下值列表：
SIMPLE：简单查询，即没有使用联合或子查询；
PRIMARY：UNION的最外围的查询或者最先进行的查询；
UNION：相对于PRIMARY，为联合查询的第二个及以后的查询；
DEPENDENT UNION：与UNION相同，但其位于联合子查询中(即UNION查询本身是子查询)；
UNION RESULT：UNION的执行结果；
SUBQUERY：非从属子查询，优化器通常认为其只需要运行一次；
DEPENDENT SUBQUERY：从属子查询，优化器认为需要为外围的查询的每一行运行一次，如用于IN操作符中的子查询；
DERIVED：用于FROM子句的子查询，即派生表查询；

table:
输出信息所关系到的表的表名，也有可能会显示为如下格式：
<unionM,N>：id为M和N的查询执行联合查询后的结果；
<derivedN>：id为N的查询执行的结果集；

type:
MySQL官方手册中解释type的作用为“type of join(联结的类型)”，但其更确切的意思应该是“记录(record)访问类型”，因为其主要目的在于展示MySQL在表中找到所需行的方式。通常有如下所示的记录访问类型：
system: 表中仅有一行，是const类型的一种特殊情况；
const：表中至多有一个匹配的行，该行仅在查询开始时读取一次，因此，该行此字段中的值可以被优化器看作是个常量(constant)；当基于PRIMARY KEY或UNIQUE NOT NULL字段查询，且与某常量进行等值比较时其类型就为const，其执行速度非常快；
eq_ref：类似于const，表中至多有一个匹配的行，但比较的数值不是某常量，而是来自于其它表；ed_ref出现在PRIMARY KEY或UNIQUE NOT NULL类型的索引完全用于联结操作中进行等值(=)比较时；这是除了system和const之外最好的访问类型；
ref：查询时的索引类型不是PRIMARY KEY或UNIQUE NOT NULL导致匹配到的行可能不惟一，或者仅能用到索引的左前缀而非全部时的访问类型；ref可被用于基于索引的字段进行=或<=>操作；
fulltext：用于FULLTEXT索引中用纯文本匹配的方法来检索记录。
ref_or_null：类似于ref，但可以额外搜索NULL值；
index_merge：使用“索引合并优化”的记录访问类型，相应地，其key字段(EXPLAIN的输出结果)中会出现用到的多个索引，key_len字段中会出现被使用索引的最长长度列表；将多个“范围扫描(range scan)”获取到的行进行合并成一个结果集的操作即索引合并(index merge)。
unique_subquery：用于IN比较操作符中的子查询中进行的“键值惟一”的访问类型场景中，如 value IN (SELECT primary_key FROM single_table WHERE some_expr)；
index_subquery：类似于unique_subquery，但子查询中键值不惟一；
range：带有范围限制的索引扫描，而非全索引扫描，它开始于索引里的某一点，返回匹配那个值的范围的行；相应地，其key字段(EXPLAIN的输出结果)中会输出所用到的索引，key_len字段中会包含用到的索引的最长部分的长度；range通常用于将索引与常量进行=、<>、>、>=、<、<=、IS NULL、<=>、BETWEEN或IN()类的比较操作中；
index：同全表扫描(ALL)，只不过是按照索引的次序进行而不行的次序；其优点是避免了排序，但是要承担按索引次序读取整个表的开销，这意味着若是按随机次序访问行，代价将非常大；
ALL：“全表扫描”的方式查找所需要的行，如果第一张表的查询类型(EXPLAIN的输出结果)为const，其性能可能不算太坏，而第一张表的查询类型为其它结果时，其性能通常会非常差；

Extra:
Using where：MySQL服务器将在存储引擎收到数据后进行“后过滤(post-filter)”以限定发送给下张表或客户端的行；如果WHERE条件中使用了索引列，其读取索引时就由存储引擎检查，因此，并非所有带有WHERE子句的查询都会显示“Using where”；
Using index：表示所需要的数据从索引就能够全部获取到，从而不再需要从表中查询获取所需要数据，这意味着MySQL将使用覆盖索引；但如果同时还出现了Using where，则表示索引将被用于查找特定的键值；
Using index for group-by：类似于Using index，它表示MySQL可仅通过索引中的数据完成GROUP BY或DISTINCT类的查询；
Using filesort：表示MySQL会对结果使用一个外部索引排序，而不是从表里按索引次序来读取行；

</pre>