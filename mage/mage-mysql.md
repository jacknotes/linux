# Mysql



## 1. 关系型数据体系结构

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





## 2. mysql服务器的体系结构

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

**mysql请求流程：**
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
数据字典：data dictionary （oracle很常见）
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



## 3. 数据库基础及编译安装
mysql前途未卜，所以有了mariaDB,percona是为mysql提供优化方案的

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



### 3.1 编译安装mysql5.6
```bash
# 确保已经安装了cmake:
[root@localhost yum.repos.d]# yum install cmake -y
# cmake用法：
./configure    cmake .
./configure --help    
cmake . -LH   or   ccmake .
make && make install

# 安装开发环境
[root@localhost yum.repos.d]# yum groupinstall "Development Tools" "RPM Development Tools" -y  
# 编译参数：默认编译的存储引擎包括：csv、myisam、myisammrt和heap
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
[root@lnmp mysql-5.5.37]# echo $? #编译报错
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
```



### 3.2 mysql使用
```bash
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
```



## 4. 客户端工具的使用
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

**mysql命令分为两种**
	1. 客户端命令
	2. 服务器命令

### 4.1 mysql的客户端命令的使用
```bash
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
```



### 4.2 mysql的服务器命令使用
```
help KEYWORD ＃help关键字

# mysqladmin客户端工具的使用
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
```



## 5. mysql数据类型及sql模型
### 5.1 mysql数据类型

myISAM:
	.frm  #表结构文件
	.MYD  #表数据文件
	.MYI  #表索引文件
InnoDB
	.frm  #表结构文件
	.ibd  #表空间(数据和索引)
	
**大多数情况下使用的是myISAM和InnoDB存储引擎，其它存储引擎为辅助存储引擎**
客户端：mysql,mysqladmin,mysqldump,mysqlcheck,mysqlimport
服务器：mysqld,mysqld_safe(安全线程启动，mysql真正启动时是这个启动的),mysqld_multi(多实例)
mysqlbinlog #查看mysql二进制日志的

**my.cnf配置文件顺序**
	/etc/my.cnf,/etc/mysql/my.cnf,$MYSQL_HOME/my.cnf,--default-extra-file=/pth/to/somefile,~/.my.cnf  #后面的会覆盖前面的配置
[mysqld] #mysqld服务端配置
[mysql] #mysql客户端
[client]#所有客户端
> 所有命令行的命令都可以写到my.cnf配置文件中，也可以把my.cnf文件写在命令行中，在命令行中的_下划线和-横线在配置中一样

```bash
# mysql配置文件帮助信息
mysqld --help --verbose  # 查看配置文件可用的参数

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

**DBA**
开发DBA: 数据库设计、SQL语句、存储过程，存储函数，触发器
管理DBA: 安装、升级、备份、恢复、用户管理、权限管理、监控、性能分析、基准测试
	
	
**mysql开发**
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
```



### 5.2 SQL模型

```
违反了SQL规定时进行SQL模型设置
mysql的mysql模型：
	1. ANSI QUOTES
	2. IGNORE_SPACE
	3. STRICT_ALL_TABLES
	4. STRICT_TRANS_TABLES
	5. TRADITIONAL
		ANSI
            宽松模式，对插入数据进行校验，如果不符合定义类型或长度，对数据类型调整或截断保存，报warning警告。
        TRADITIONAL
            严格模式，当向mysql数据库插入数据时，进行数据的严格校验，保证错误数据不能插入，报error错误。用于事物时，会进行事物的回滚。
        STRICT_TRANS_TABLES
            严格模式，进行数据的严格校验，不允许向一个支持事物的表中插入非法数据，报error错误。
        STRICT_ALL_TABLES
            未设置的情况下，所有的非法数值都允许，返回警告信息。设置以后只要违反数据规则，都不允许填入，并返回错误。
        ANSI QUOTES
            双引号和反引号作用相同，只能用来引用字段名称/表名等，单引号只能引用在字符串。mysql中默认3者可以随意引用。
        IGNORE_SPACE
            在内建函数中忽略多余空格
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
```



## 6. MYSQL管理表和索引
```
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
```



## 7. 单表查询、多表查询和子查询
```
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
```



## 8. 多表查询、子查询及视图
```
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
```



## 9. MYSQL事务与隔离级别

```
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
```



## 10. 事务和隔离级别
```
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
```



## 11. MYSQL用户和权限管理
```
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
```



## 12. MYSQL日志管理一
```
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
```



## 13. MYSQL日志管理二
```
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
```



## 14. MYSQL备份和还原
```
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
--set-gtid-purged=OFF #禁用备份gtid信息

#备份所有数据库信息 mysqldump -uroot -p --all-databases --set-gtid-purged=OFF --triggers --routines --events > /root/all-databases.sql
# mysqldump -uroot -p --databases ApolloConfigDB --no-create-db --set-gtid-purged=OFF --single-transaction > /root/ApolloConfigDB.sql

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


---------------
# 差异备份
# 全量+差异

# 1. 全量备份：
mysqldump -h${HOSTNAME} -u${USER} -p${PASSWORD} --single-transaction --master-data=2 all-databases > /root/alldatabases.sql

# 2. 差异备份
# 这个是--master-data=2参数开启记录的文件及位置
[root@lnmp ~]# less alldatabases.sql 
CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000012', MASTER_LOG_POS=107; 

mysql> show binary logs;
+------------------+-----------+
| Log_name         | File_size |
+------------------+-----------+
| mysql-bin.000012 |       150 |
| mysql-bin.000013 |       352 |
| mysql-bin.000014 |       107 |
+------------------+-----------+

# 差异备份方式一 
[root@lnmp ~]# mysqlbinlog --no-defaults --start-position=107 /data/mysql/mysql-bin.000012 /data/mysql/mysql-bin.000013 /data/mysql/mysql-bin.000014 > /root/diff.sql
# 差异备份方式二 
[root@lnmp ~]# mysqlbinlog --no-defaults --start-position=107 /data/mysql/mysql-bin.* > /root/diff.sql
---------------
```



## 15. 使用LVM快照进行数据备份

``` 
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
	mysql> source a.sql  #还原增量文件
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
```



## 16. 使用xtrabackup进行数据备份

```
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
#xtrabackup只支持INNODB存储引擎完全+增量备份。只支持MYISAM完全备份、不支持MYISAM增量备份，当备份MYISAM存储引擎时使用增量备份则xtrabackup其实使用了完全备份
#完全+增量+二进制恢复
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
[root@lnmp download]# innobackupex --user=root --password=root123 /backup #完全备份
[root@lnmp 2019-06-23_21-25-52]# pwd
/backup/2019-06-23_21-25-52
[root@lnmp 2019-06-23_21-25-52]# ls
backup-my.cnf  lost+found  mysql               test       xtrabackup_binlog_info  xtrabackup_info
ibdata1        mydb        performance_schema  wordpress  xtrabackup_checkpoints  xtrabackup_logfile
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
[root@lnmp 2019-06-23_21-25-52]# innobackupex --apply-log /backup/2019-06-23_21-25-52/ #进行提交的事务日志写入数据文件，未提交的事务日志回滚，后面给一个路径，这个准备工作必须做，做完才可进行恢复，（不做的话mysql启动时会修复数据库，很危险）
mysql> insert into stu (Name) value ('abcd'); #模拟在mysql做插入动作
mysql> insert into stu (Name) value ('abcd12');
mysql> flush logs; #滚动二进制日志
[root@lnmp mydata]# cp mysql-bin.000001 /root #复制完全备份后更改的二进制日志文件信息
[root@lnmp mydata]# service mysql stop 
[root@lnmp mydata]# rm -rf ./* #模拟删除全部数据
[root@lnmp mydata]# ls /mydata/
[root@lnmp backup]# innobackupex --copy-back /backup/2019-06-23_21-25-52/ #恢复全量备份，恢复时mysqld服务可不启动。
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
[root@lnmp mydata]# service mysql start #启动mysql，必须保证/etc/init.d/mysqld和/etc/my.cnf文件都存在
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
[root@lnmp ~]# mysql < a.sql  #恢复备份的日志增量数据，
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
#让提交事务日志写入数据文件，未提交事务日志回滚
#注：1.需要在每个备份（包括完全和增量备份）上，将已经提交的事务进行“重放”。“重放”之后，所有的增量备份数据将合并到完全备份上。2.基于所有的备份将未提交的事务进行“回滚”。
[root@lnmp ~]# innobackupex --apply-log --redo-only /backup/2019-06-23_21-52-24/ #对完全备份操作，让事务日志写入数据文件，并且只做重读操作，不做撤销，因为如果撤销会影响后面的重读操作
[root@lnmp ~]# innobackupex --apply-log --redo-only /backup/2019-06-23_21-52-24/ --incremental-dir=/backup/2019-06-23_21-55-32/ #对增量备份1进行事务日志重放操作，/backup/2019-06-23_21-52-24/为完全备份路径，--incremental-dir=/backup/2019-06-23_21-55-32/是第1次增量备份路径
[root@lnmp ~]# innobackupex --apply-log --redo-only /backup/2019-06-23_21-52-24/ --incremental-dir=/backup/2019-06-23_22-00-13/ #对增量备份2进行事务日志重放操作，/backup/2019-06-23_21-52-24/为完全备份路径，--incremental-dir=/backup/2019-06-23_21-55-32/是第2次增量备份路径
[root@lnmp ~]# service mysql stop #停止mysql
Shutting down MySQL... SUCCESS!  
[root@lnmp mydata]# rm -rf /mydata/* #模拟崩溃
[root@lnmp mydata]# ls
[root@lnmp backup]# innobackupex --copy-back /backup/2019-06-23_21-52-24/ #完全加增量恢复，所有的增量备份数据已经合并到完全备份上，未提交的事务进行回滚
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

## xtrabackup的“流”及“备份压缩功能”
Xtrabackup对备份的数据文件支持“流”功能，即可以将备份的数据通过STDOUT传输给tar程序进行归档，而不是默认的直接保存至某备份目录中，要使用此功能，仅需要使用--stream选项即可。如：
#  innobackupex --stream=tar /backup | gzip > /backup/`date +%F_%H-%M-%S`.tar.gz
甚至也可以使用类似如下命令将数据备份至其它服务器：
#  innobackupex --stream=tar /backup | ssh user@www.magedu.com "cat - > /backup/`date +%F_%H-%M-%S`.tar.gz"
此外，在执行本地备份时，还可以使用--parallel选项对多个文件进行并行复制，此选项用于指定在复制时启动的线程数目。当然，在实际进行备份时要利用此功能的便利性，也需要启用innodb_file_per_table=1选项或共享的表空间通过innodb_data_file_path选项存储在多个ibdata文件中。对某一数据库的多个文件的复制无法利用到此功能。其简单使用方法如下：
#  innobackupex --parallel /path/to/backup
同时，innobackupex备份的数据文件也可以存储在远程主机，这可以使用--remote-host选项来实现。
#  innobackupex --remote-host=root@www.magedu.com /path/IN/REMOTE/HOST/to/backup

##xtrabckup导入及导出单张表
默认情况下，innodb表不能通过直接复制表文件的方式在mysql服务器之间进行移值，即便使用了innodb_file_per_table选项。而使用xtrabackup工具可以实现此种功能，不过此时需要“导出”表的mysql服务器启用了innodb_file_per_table=1选项(严格来说，是要“导出”的表在其创建之前，mysql服务器就启用了Innodb_file_per_table选项)。并且“导入”表的服务器同时启用了innodb_file_per_table=1和innodb_expand_import=1选项。
1.导出表
导出表是在备份的prepare(准备阶段，就是应用事务日志时)阶段进行的，因此，一旦完全备份完成，就可以在prepare过程中通过--export选项将某表导出了：
#  innobackupex --apply-log --export /path/to/backup
此命令会为每个innodb表的表空间创建一个以.exp结尾的文件，这些以.exp结尾的文件则可以用于导入至其它服务器。
2.导入表
要在mysql服务器上导入来自于其它服务器的某Innodb表，需要先在当前服务器上创建一个跟原来表表结构一致的表，而后才能实现将表导入：
#  create table mytable (...) enging=innodb;
然后将此表的表空间删除：
#  alter table mydatabase.mytable DISCARD TABLESPACE;
接下来，将来自“导出”表的服务器的mytable表的mytable.ibd和mytable.exp文件复制到当前服务器的数据目录，然后使用如下命令将其“导入”：
#  alter table mydatabase.mytable IMPORT TABLESPACE;
7、使用Xtrabackup对数据库进行部分备份
Xtrabackup也可以实现部分备份，即只备份某个或某些指定的数据库或某数据库中的某个或某些表。但要使用此功能，必须启用innodb_file_per_table选项，即每张表保存为一个独立的文件。同时，其也不支持--stream选项，即不支持将数据通过管道传输给其它程序进行处理。
此外，还原部分备份跟还原全部数据的备份也有所不同，即你不能通过简单地将prepared的部分备份使用--copy-back选项直接复制回数据目录，而是要通过导入表的方向来实现还原。当然，有些情况下，部分备份也可以直接通过--copy-back进行还原，但这种方式还原而来的数据多数会产生数据不一致的问题，因此，无论如何不推荐使用这种方式。
(1)创建部分备份
创建部分备份的方式有三种：正则表达式(--include), 枚举表文件(--tables-file)和列出要备份的数据库(--databases)。
(a)使用--include
使用--include时，要求为其指定要备份的表的完整名称，即形如databasename.tablename，如：
# innobackupex --include='^mageedu[.]tb1'  /path/to/backup
(b)使用--tables-file
此选项的参数需要是一个文件名，此文件中每行包含一个要备份的表的完整名称；如：
# echo -e 'mageedu.tb1\nmageedu.tb2' > /tmp/tables.txt
# innobackupex --tables-file=/tmp/tables.txt  /path/to/backup
(c)使用--databases
此选项接受的参数为数据名，如果要指定多个数据库，彼此间需要以空格隔开；同时，在指定某数据库时，也可以只指定其中的某张表。此外，此选项也可以接受一个文件为参数，文件中每一行为一个要备份的对象。如：
# innobackupex --databases="mageedu testdb"  /path/to/backup
(2)整理(preparing)部分备份
prepare部分备份的过程类似于导出表的过程，要使用--export选项进行：
# innobackupex --apply-log --export  /pat/to/partial/backup
此命令执行过程中，innobackupex会调用xtrabackup命令从数据字典中移除缺失的表，因此，会显示出许多关于“表不存在”类的警告信息。同时，也会显示出为备份文件中存在的表创建.exp文件的相关信息。
(3)还原部分备份
还原部分备份的过程跟导入表的过程相同。当然，也可以通过直接复制prepared状态的备份直接至数据目录中实现还原，不要此时要求数据目录处于一致状态。
```



## 17. MySQL读写分离

### 17.1 MYSQL读写分离概念
```
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
```



### 17.2 MYSQL异步、半同步配置及其注意事项

```
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
```

**半同步复制环境下主主集群下线一台主节点操作**

```
# 小记：20241202
# 半同步复制环境下主主集群下线一台主节点操作

## 禁用半同步复制：
SET GLOBAL rpl_semi_sync_master_enabled = 0;
SET GLOBAL rpl_semi_sync_slave_enabled = 0;

## 检查半同步复制是否已禁用：
SHOW VARIABLES LIKE 'rpl_semi_sync%';

## 检查复制状态
在停止主节点之前，确保数据库的复制状态是健康的，即所有的数据已经同步到从节点。
* 在主节点上查看复制状态：
SHOW MASTER STATUS;
* 确保没有任何待处理的事务。然后，检查从节点的状态，确认它已经接收到最新的事务。确保 Slave_IO_Running 和 Slave_SQL_Running 都是 Yes，且没有复制延迟。
SHOW SLAVE STATUS\G

## 准备主节点停止
在主节点切换为异步复制模式后，您可以安全地停止该节点进行维护，不会影响到其他节点的操作。
sudo systemctl stop mysql
或者：
mysqladmin -u root -p shutdown




# 恢复半同步复制

## 在维护完成并且主节点已经恢复后，可以重新启用半同步复制。
SET GLOBAL rpl_semi_sync_master_enabled = 1;
SET GLOBAL rpl_semi_sync_slave_enabled = 1;

## 检查半同步复制状态：
SHOW VARIABLES LIKE 'rpl_semi_sync%';

## 检查复制状态
当主节点恢复后，检查复制状态，并确保数据同步完成。
* 检查主节点状态：：
SHOW MASTER STATUS;
* 检查从节点状态，确认它已经接收到最新的事务。确保 Slave_IO_Running 和 Slave_SQL_Running 都是 Yes，且没有复制延迟。
SHOW SLAVE STATUS\G

## 切换回主主复制
当主节点恢复并且所有数据同步后，您可以恢复正常的主主复制模式，两个主节点将继续互相同步数据。



# 备选方案：使用 MySQL Group Replication 或其他高可用架构
除了主主复制和半同步复制外，还可以考虑使用 MySQL Group Replication，这是一个更为现代的解决方案，它提供了更高的自动化、数据一致性和故障恢复能力。
1. MySQL Group Replication：它支持自动故障转移，能够处理节点之间的复制冲突，并且能够在节点故障时自动恢复。

2. MHA（MySQL High Availability）：MHA 是一个 MySQL 高可用性工具，支持自动故障转移，避免了手动干预。
```









### 17.3 实战

```
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
```



### 17.4 什么是GTID

```
在 MySQL 主主集群中，GTID（Global Transaction Identifier） 是一种重要的机制，用于确保事务在多个主服务器之间的正确复制。GTID 使得复制系统更加稳健，特别是在主主复制中，它能够有效地避免数据冲突、重复执行事务、丢失事务等问题。下面是 GTID 在主主复制中的工作原理及其如何应用于防止数据冲突和重复插入的解释。

1. 什么是 GTID？
GTID（全局事务标识符）是 MySQL 为每个事务分配的唯一标识符。每个事务在提交时会被分配一个全局唯一的 ID。GTID 的格式通常是 server_id:transaction_id，其中：

server_id 是 MySQL 服务器的唯一标识符。
transaction_id 是该服务器上的事务 ID。
例如，1-1001 表示在服务器 1 上的事务 1001。

2. GTID 的工作原理
2.1 事务提交时生成 GTID
当事务在某个 MySQL 主服务器上提交时，系统会为该事务分配一个 GTID。这个 GTID 包含了该事务的唯一标识，保证了每个事务都有唯一的 ID，即使在多个 MySQL 实例之间复制，GTID 仍然能够保证事务的唯一性。

假设服务器 A 的 server_id 是 1，当它执行一个事务时，该事务就会被分配一个 GTID，例如 1-1001。
然后，这个事务会被记录到服务器 A 的 binlog 中，并且该事务的 GTID 会随 binlog 事件一起被复制到其他服务器。
2.2 复制过程中的 GTID 使用
在主主复制环境中，两个主服务器都同时执行读写操作，并且会将这些操作复制到对方。

假设服务器 A 执行了一个事务并分配了 GTID 1-1001，并将该事务写入其 binlog。
服务器 B 读取服务器 A 的 binlog，并根据 binlog 中的事件执行相同的操作（例如插入数据）。在执行完这个操作后，服务器 B 会记录已经处理过的 GTID（1-1001）到自己的 gtid_executed 列表中。
2.3 GTID 保证了不重复执行
通过 GTID，MySQL 可以保证即使同一个事务在多个主服务器之间进行复制和回放，也不会被重复执行。关键的点是：

唯一性：每个事务都有唯一的 GTID 标识。即使在多个服务器之间复制时，每个事务都有唯一的标识符，防止了事务被复制多次或重复执行。
有序性：在复制过程中，GTID 记录了事务的执行顺序。这样，当从服务器回放某个主服务器的 binlog 时，可以确保事务按正确的顺序执行。
3. GTID 在主主复制中的应用
在主主复制环境中，每个 MySQL 实例都作为主服务器同时处理数据修改，并将这些修改传播到另一个主服务器。GTID 的引入主要解决了以下问题：

3.1 避免数据丢失
在没有 GTID 的情况下，如果复制链路中断或者某个事务丢失，可能会导致数据丢失或不一致。而使用 GTID 后，MySQL 会确保每个事务都有唯一标识，并且确保所有的事务在复制过程中不会丢失。即使某个事务没有成功被复制到从服务器，它会在之后的复制过程中重新尝试执行。

3.2 避免重复执行
GTID 保证了同一个事务不会在主主复制环境中被重复执行。例如，服务器 A 执行了事务 1-1001，然后将该事务复制到服务器 B。服务器 B 执行完后会记下 GTID 1-1001。即使服务器 A 也将该事务再次发送给服务器 B，服务器 B 会检查 gtid_executed 列表，发现已经执行过该事务，因此不会重复执行该事务。

3.3 冲突检测
在主主复制的场景下，两个主服务器都可能同时执行相同的事务，导致冲突。GTID 可以帮助检测和解决这些冲突。每个事务都有一个唯一的 GTID，复制过程中，通过比对 GTID 来判断是否已经执行过某个事务，从而避免了冲突或重复执行。

3.4 事务隔离
在主主复制中，GTID 的一个关键优势是，它能帮助 MySQL 确保每个事务的执行顺序和唯一性。即使发生了服务器宕机或网络分区，GTID 仍然能够确保数据一致性。例如，如果服务器 A 执行了事务 1-1001，然后崩溃，重启后它可以根据 GTID 确定哪些事务已经执行，哪些没有，从而避免事务丢失或冲突。

4. GTID 与主主复制中的常见问题
4.1 循环复制
主主复制的一个常见问题是循环复制，即服务器 A 执行事务并将其复制到服务器 B，之后服务器 B 又将同样的事务复制回服务器 A。GTID 通过唯一标识事务来避免这一问题。服务器 A 在收到来自 B 的复制事件时，能够知道自己已经执行过该事务，从而避免了循环复制。

4.2 服务器 ID 冲突
在主主复制中，如果两个服务器的 server_id 配置相同，可能会导致复制异常。为避免这种情况，通常会为每个主服务器设置不同的 server_id，并确保它们唯一。

4.3 故障恢复
GTID 使得故障恢复变得更加容易。当主服务器发生故障时，GTID 可以帮助从服务器准确地恢复已执行的事务，确保不会丢失或重复执行事务。

5. GTID 与传统基于日志的复制的对比
传统的 MySQL 复制是基于 binlog 的，复制过程中依赖于日志的顺序执行。这个方法在某些情况下可能会出现 事务丢失、顺序错误或重复执行 的问题，而 GTID 在这方面做了改进：

GTID 使得复制更具容错性，因为它记录了事务的唯一 ID，不依赖于 binlog 顺序。
GTID 使得复制更加可靠和高效，避免了手动处理复制冲突、重放或丢失事务等问题。
总结
GTID 是 MySQL 主主复制中的关键技术，它通过为每个事务分配一个唯一标识符来确保事务的顺序和一致性。在主主复制架构中，GTID 主要用于：

确保事务不重复执行。
防止数据丢失和冲突。
简化故障恢复。
提高复制系统的容错能力。
通过正确使用 GTID，MySQL 能够提供更强的事务一致性和数据完整性，尤其是在主主复制的高并发写场景下
```







## 18. 设置主主架构
```
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
```



## 19. mysql使用ssl连接

### 19.1 SSL主从复制
```
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
```



### 19.2 SSL主主复制

```
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
```



## 20. MYSQL5.6基于GTID及多线程的复制
```
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
```



## 21. mysql-proxy

```
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
```




## 22. mysql优化
```
#MYISAM配置选项：
key_buffer_size:除开用户使用的内存空间外，尽量的全部分给它。内存存储索引的
concurrent_insert:是否允许并发插入操作，0禁止，2表示空隙时插入，默认是1，表示本身内部没有空隙时才插入
delay_key_write:延迟内存中索引失效时的重新写入的，on或off，
max_write_lock_count:
preload_buffer_size:
#INNODB配置选项：
innodb_buffer_pool_size:定义innodb缓冲池大小，缓存池包括索引和数据，16G分10G也不过分
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

#锁
事务锁(行锁、表锁)
(MYISAM)表级锁不会产生死锁.所以解决死锁主要还是针对于最常用的InnoDB,因为innodb默认是行锁,行锁是发生在事务当中的。mysql默认autocommit=1则不会发生行锁，当设成0时则会可能发生死锁。
#共享锁和排他锁
S锁(ShareLock,共享锁)	X锁(RWLock,排他锁)
SELECT * FROM table_name WHERE ... LOCK IN SHARE MODE  #共享锁
SELECT * FROM table_name WHERE ... FOR UPDATE  #排他锁
共享锁：允许一个事务去读一行，阻止其他事务获得相同数据集的排他锁；
排他锁：允许获得排他锁的事务更新数据，阻止其他事务取得相同数据集的共享读锁和排他写锁。
select * from table where ?; #快照读
select * from table where ? lock in share mode; #共享锁
select * from table where ? for update; #排他锁
insert into table values (…); #默认是排他锁
update table set ? where ?; #默认是排他锁
delete from table where ?; #默认是排他锁
#SQL语句1
select * from table where id = 1; #不加锁的，属于快照读
#SQL语句2
update set age = age + 1 where id = 1; #如果id是主键或者是索引的话，那么锁定的行只有符合条件的那几行。如果id非索引，那么会锁表。
#SQL语句3
update set age = age + 1 where id = 1 and nickname = 'hello'; #id或者nickname只要有一个是索引或者是主键的话，那么锁住的行都是符合条件的行。否则锁住的也是全表
#死锁原因：
所谓死锁<DeadLock>：是指两个或两个以上的进程在执行过程中,因争夺资源而造成的一种互相等待的现象,若无外力作用，它们都将无法推进下去.此时称系统处于死锁状态或系统产生了死锁，这些永远在互相等待的进程称为死锁进程。表级锁不会产生死锁.所以解决死锁主要还是针对于最常用的InnoDB。
死锁的关键在于：两个(或以上)的Session加锁的顺序不一致。
那么对应的解决死锁问题的关键就是：让不同的session加锁有次序

#kill掉等待死锁进程
–查看进程id，然后用kill id杀掉进程
show processlist;
SELECT * FROM information_schema.PROCESSLIST;
–查询正在执行的进程
SELECT * FROM information_schema.PROCESSLIST where length(info) >0 ;
//查询是打开了哪些表
show OPEN TABLES where In_use > 0;
//查看被锁住的表名、事务ID、锁ID等
SELECT * FROM INFORMATION_SCHEMA.INNODB_LOCKS;
//查看等待锁定关系
SELECT * FROM INFORMATION_SCHEMA.INNODB_LOCK_WAITS;
//杀掉锁表进程
kill 12041  | kill connection 12041  #杀掉ID为12041的连接
kill query 12041  #杀掉ID为12041的查询

#查询mysql语句执行运行时间
方法一： show profiles。
查看profile是否开启，数据库默认是不开启的。变量profiling是用户变量，每次都得重新启用。在MySQL 5.6.8过期，在后期版本中会被移除。
查看方法： show variables like "%pro%";
设置开启方法： set profiling = 1;
show profiles；即可查看所有sql的总的执行时间。
show profile cpu, block io, memory,swaps,context switches,source for query 6;可以查看出一条SQL语句执行的各种资源消耗情况，比如CPU，IO等
show profile all for query 6 查看第6条语句的所有的执行信息。
方法二： timestampdiff来查看执行时间。
这种方法有一点要注意，就是三条sql语句要尽量连一起执行，不然误差太大，根本不准
set @d=now();
select * from comment;
select timestampdiff(second,@d,now());
```



## 23. mysql5.7主主集群
```
# 192.168.13.160
[root@localhost mysqldata]# cat /etc/my.cnf 
[mysqld]
datadir = /home/mysqldata
basedir = /usr/local/mysql
socket=/usr/local/mysql/mysql.sock
gtid-mode=on
enforce-gtid-consistency=true
master-info-repository=TABLE 
relay-log-info-repository=TABLE
sync-master-info=1
slave-parallel-workers=2
binlog-checksum=CRC32 
master-verify-checksum=1
slave-sql-verify-checksum=1
binlog_format = ROW
log-bin=master-bin
log-bin-index=master-bin.index
character-set-server=utf8mb4
relay-log=relay-master
relay-log-index=relay-master.index
slow_query_log_file = /home/mysqldata/mysql-slow.log
slow_query_log = 1
general_log_file = /home/mysqldata/mysql.log
general_log = 1
log_error = /home/mysqldata/mysql.err
innodb_file_per_table=1
auto-increment-increment = 2
auto-increment-offset=2
server-id = 20
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES 
default-storage-engine = InnoDB
default-tmp-storage-engine = InnoDB
internal-tmp-disk-storage-engine = InnoDB

[client]
default-character-set = utf8mb4
socket=/usr/local/mysql/mysql.sock

# 192.168.13.116
[root@localhost mysqldata]# cat /etc/my.cnf 
[mysqld]
#skip-grant-tables = 1
#skip-slave-start = 1	#表示启动mysql服务后不启动slave线程
datadir = /home/mysqldata
basedir = /usr/local/mysql
socket=/usr/local/mysql/mysql.sock
gtid-mode=on
enforce-gtid-consistency=true
master-info-repository=TABLE 
relay-log-info-repository=TABLE
sync-master-info=1
slave-parallel-workers=2
binlog-checksum=CRC32 
master-verify-checksum=1
slave-sql-verify-checksum=1
binlog_format = ROW
log-bin=master-bin
log-bin-index=master-bin.index
character-set-server=utf8mb4
relay-log=relay-master
relay-log-index=relay-master.index
slow_query_log_file = /home/mysqldata/mysql-slow.log
slow_query_log = 1
general_log_file = /home/mysqldata/mysql.log
general_log = 1
log_error = /home/mysqldata/mysql.err
innodb_file_per_table=1
auto-increment-increment = 2
auto-increment-offset=1
server-id = 10
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES 
default-storage-engine = InnoDB
default-tmp-storage-engine = InnoDB
internal-tmp-disk-storage-engine = InnoDB

[client]
default-character-set = utf8mb4
socket=/usr/local/mysql/mysql.sock


# 主1：
grant replication slave on *.* to repluser@'192.168.13.%' identified by 'test';
flush privileges;
show grants for repluser@'192.168.13.%';
flush binary logs;
mysql> show master status;
+-------------------+----------+--------------+------------------+--------------------------------------------------------------------------------------+
| File              | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set                                                                    |
+-------------------+----------+--------------+------------------+--------------------------------------------------------------------------------------+
| master-bin.000012 |      194 |              |                  | 172a28db-ede3-11ea-894c-e619baff355e:1-30,
84ff5380-ee50-11ea-bbd9-4cd98f3bab94:9-10 |
+-------------------+----------+--------------+------------------+--------------------------------------------------------------------------------------+
change master to master_host='192.168.13.116',master_user='repluser',master_password='test',master_log_file='master-bin.000012',MASTER_LOG_POS=194;

# 主2：
grant replication slave on *.* to repluser@'192.168.13.%' identified by 'test';
flush privileges;
show grants for repluser@'192.168.13.%';
flush binary logs;
mysql> show master status;
+-------------------+----------+--------------+------------------+---------------------------------------------------------------------------------------+
| File              | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set                                                                     |
+-------------------+----------+--------------+------------------+---------------------------------------------------------------------------------------+
| master-bin.000008 |      194 |              |                  | 172a28db-ede3-11ea-894c-e619baff355e:16-26,
84ff5380-ee50-11ea-bbd9-4cd98f3bab94:1-12 |
+-------------------+----------+--------------+------------------+---------------------------------------------------------------------------------------+
change master to master_host='192.168.13.160',master_user='repluser',master_password='test',master_log_file='master-bin.000008',MASTER_LOG_POS=194;
或
# 主1：
CHANGE MASTER TO MASTER_HOST='192.168.13.160',MASTER_USER='repluser',MASTER_PASSWORD='test',MASTER_AUTO_POSITION=1;
# 主2：
CHANGE MASTER TO MASTER_HOST='192.168.13.116',MASTER_USER='repluser',MASTER_PASSWORD='test',MASTER_AUTO_POSITION=1;
# 注：无法使用MASTER_AUTO_POSITION=1进行主主集群时，需要使用reset master重置下mysql二进制文件，问题通常出在先手动删除了部分二进制文件，然后进行配置主主集群连接时报错
change master to master_auto_position=0       表示使用GTID不自动从binlog.000001去找，而是指定文件名及位置同步
change master to master_auto_position=1        表示使用GTID自动同步，从binlog.000001去找
stop slave;    停止slave线程
```



## 24. mysql主主集群GTID
```
1. 当两个节点数据不一致时，操作数据库后，数据库自动同步会出错，
此时是因为另外一个节点不能操作不存储的对象导致的。
解决办法 ：
停止当前节点的slave（包括IO和SQL线程），然后reset master，重置
本节点的master GTID信息，再设置GTID_PURGED为从show slave status\G;
中获取到的Retrieved_Gtid_Set值。最后重启slave线程即可解决。
例如 ：
mysql>  STOP SLAVE;
mysql> RESET MASTER;  （此步骤会清空二进制文件，有需要手动备份下）
mysql>   SET @@GLOBAL.GTID_PURGED ='8f9e146f-0a18-11e7-810a-0050568833c8:1-4'
mysql>  START SLAVE;
上面这些命令的用意是，忽略8f9e146f-0a18-11e7-810a-0050568833c8:1-4 这个GTID事务，下
一次事务接着从 5 这个GTID开始，即可跳过上述错误。
注:set @@GLOBAL.GTID_PURGED只能往后设，不能往前设，否则会报错。
如果非要往前设，那么只能重置本节点的slave信息，重新建立连接了。

最后解决办法：
1. 重置slave和master,重新建立集群连接
2. 重置slave设置，重新配置slave连接信息，指定binlog文件及位置

#mysql缓冲区大小设置详解：
当您增加或减少缓冲池大小时，该操作将按块执行。块大小由innodb_buffer_pool_chunk_size变量定义，该变量的默认值为 128 MB。
缓冲池大小必须始终等于innodb_buffer_pool_chunk_size * innodb_buffer_pool_instances或倍数。如果将缓冲池大小更改为不等于innodb_buffer_pool_chunk_size * innodb_buffer_pool_instances或倍数的值，则缓冲池大小将自动调整为等于innodb_buffer_pool_chunk_size * innodb_buffer_pool_instances或倍数的值。
innodb_buffer_pool_size可以动态设置，这使您无需重新启动服务器即可调整缓冲池的大小。
例：
innodb-buffer-pool-chunk-size = 134217728
innodb-buffer-pool-instances = 8
innodb-buffer-pool-size = 8589934592
#innodb-buffer-pool-size = 8G * innodb-buffer-pool-chunk-size * innodb-buffer-pool-instances
sync-binlog = 1  #1表示每有一次事务提交就从内存缓存同步到二进制日志文件中
log-slave-updates = 1  #multi level copy,多级复制，可以实现多主架构,表示在主1中插入一条数据时，此时主2会通过IO线程从主1上复制二进制日志到relay-log和binlog中，如果不开启这个，则只会同步到relay-log中，这样一台如果主2有一节点为从，则从节点无法同步主1上改变的二进制内容，如果用户请求正好被高度到主2的从节点时，则此请求不会被正确处理。
```

> mysql主从复制集群的状态转变信息：
> Slave_IO_State: System lock
> 到
> Slave_IO_State: Waiting for master to send event
> 	   
> Slave_SQL_Running_State: Waiting for Slave Worker to release partition
> 到
> Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates









## 25. Mysql备份恢复

```
数据库还原最好不要改数据库名称，因为mysql使用binlog还原时会找最原始的数据库，你改完数据库名称再用binlog还原会失败，
可以在binlog还原后再改回来，如果执行到一半提示数据库名称不正确，可使用下面脚本改回数据库原始名称：
-----------Change_DBname_Shell----------
#!/bin/bash
SDB="'jack123'"
DDB=jack
USER=root
PASSWORD=test
SQL="select table_name from information_schema.TABLES where TABLE_SCHEMA=${SDB}"
list_table=$(mysql -u${USER} -p${PASSWORD} -Nse "${SQL}")

mysql -u${USER} -p${PASSWORD} -e "create database if not exists ${DDB}"
for table in $list_table
do
    mysql -u${USER} -p${PASSWORD} -e "rename table `echo ${SDB} | sed s"/'//"g`.$table to ${DDB}.$table"
done
----------------------------------------
#binlog还原一定要在mysql命令行中执行，不要在shell中执行。mysql完全备份可以在shell和mysql命令行中执行
#从多个数据库的备份文件中提取一个数据库(例如数据库为test1)文件进行恢复
sed -n '/^-- Current Database: `test1`/,/^-- Current Database: `/p' Fat_Full-20201121-180137.sql > test1_db.sql
#提取出来后恢复时更改数据库名称进行恢复
sed -i 's/USE `test1`/USE `jack`/g' test1_db.sql

从binlog日志文件中只恢复jack增量部分
CHANGE MASTER TO MASTER_LOG_FILE='master-bin.000128', MASTER_LOG_POS=6643;
[root@test /data/backup]# mysqlbinlog --no-defaults --start-position=6643 master-bin.000128 > jack_increment.sql
[root@test /data/backup]# grep 'create database' jack_increment.sql
create database jack2
#将binlog日志中新建数据库注解掉，以免造成回滚binlog日志时多创建了数据库，恢复其它库数据，视情况而定
[root@test /data/backup]# sed -i 's/^create database/#create database/g' jack_increment.sql
[root@test /data/backup]# grep 'create database' jack_increment.sql
#create database jack2
mysql> source /data/backup/jack_increment.sql   #回放binlog只是覆盖已有数据创建新数据而已。
#############事务数据库测试
create database transaction;
use transaction;
CREATE TABLE `user` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
insert into user (name) values ('jack');
insert into transaction.user (name) values ('jack');
start transaction;
insert into transaction.user (name) values ('test');
select * from user;
+----+------+
| id | name |
+----+------+
|  1 | jack |
|  2 | jack |
+----+------+
commit;
select * from user;
+----+------+
| id | name |
+----+------+
|  1 | jack |
|  2 | jack |
|  3 | test |
+----+------+
delete from transaction.user where id=3;
select * from user;
+----+------+
| id | name |
+----+------+
|  1 | jack |
|  2 | jack |
+----+------+
insert into transaction.user (name) values ('test234');
select * from user;
+----+---------+
| id | name    |
+----+---------+
|  1 | jack    |
|  2 | jack    |
|  4 | test234 |
+----+---------+
start transaction;
insert into transaction.user (name) values ('test345');
mysql> select * from transaction.user;  #启动事务未提交事务的终端所查看的结果
+----+---------+
| id | name    |
+----+---------+
|  1 | jack    |
|  2 | jack    |
|  4 | test234 |
|  5 | test345 |
+----+---------+
select * from user;  #其它终端所查看的结果
+----+---------+
| id | name    |
+----+---------+
|  1 | jack    |
|  2 | jack    |
|  4 | test234 |
+----+---------+
#第一次完全备份
insert into transaction.user (name) values ('test456');
select * from user;
+----+---------+
| id | name    |
+----+---------+
|  1 | jack    |
|  2 | jack    |
|  4 | test234 |
|  6 | test456 |
+----+---------+
#第二次完全备份
mysql> insert into transaction.user (name) values ('test789');
select * from user;
+----+---------+
| id | name    |
+----+---------+
|  1 | jack    |
|  2 | jack    |
|  4 | test234 |
|  6 | test456 |
|  7 | test789 |
+----+---------+
show binary logs;
+-------------------+-----------+
| Log_name          | File_size |
+-------------------+-----------+
| master-bin.000134 |      2618 |
+-------------------+-----------+
flush logs;
show binary logs;
+-------------------+-----------+
| Log_name          | File_size |
+-------------------+-----------+
| master-bin.000134 |      2666 |
| master-bin.000135 |       154 |
+-------------------+-----------+
[root@test /data/backup]# cp /data/mysql/master-bin.000134 .
#第一次增量备份
insert into transaction.user (name) values ('test000');
select * from user;
+----+---------+
| id | name    |
+----+---------+
|  1 | jack    |
|  2 | jack    |
|  4 | test234 |
|  6 | test456 |
|  7 | test789 |
|  8 | test000 |
+----+---------+
commit； #前面未提交的事务进行提交
select * from transaction.user;  #提交事务终端和其它终端都可以看到此结果
+----+---------+
| id | name    |
+----+---------+
|  1 | jack    |
|  2 | jack    |
|  4 | test234 |
|  5 | test345 |
|  6 | test456 |
|  7 | test789 |
|  8 | test000 |
+----+---------+
mysql> show binary logs;
+-------------------+-----------+
| Log_name          | File_size |
+-------------------+-----------+
| master-bin.000134 |      2666 |
| master-bin.000135 |       714 |
+-------------------+-----------+
flush logs;
show binary logs;
+-------------------+-----------+
| Log_name          | File_size |
+-------------------+-----------+
| master-bin.000134 |      2666 |
| master-bin.000135 |       762 |
| master-bin.000136 |       154 |
+-------------------+-----------+
[root@test /data/backup]# cp /data/mysql/master-bin.000135 .
#第二次增量备份
####经过binlog还原测试得出结论：当事务未提交是不会写入到binlog文件中，所以当我们用第一次增量文件还原binlog数据时事务没有提交，所以没有写入到第一次的binlog文件。
####当第二次binlog还原时，之前的事务已经提交，并且事务改变了数据库，从而写入到第二次binlog文件中了，当我们使用第二次增量文件恢复时所以恢复了提交的事务结果。



-----FULL_BACKUP_ALLDB_AND_BINLOG_Shell-----
[root@test /data]# cat shell/mysql/v2/mysql_full_backup_allDB_and_binlog.sh 
#!/bin/bash  
#Describe: Shell Script For Backup MySQL Database Everyday Automatically By Crontab  
#Type: Multi_Or_ALL_Database_Full_Backup
#Duthor: JackLi
#Date: 2020-11-22
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:/usr/local/mysql/bin
export LANG=en_US.UTF-8

ENV=Pro
TYPE=Full
USER=root  
HOSTNAME="localhost"  
PASSWORD="test"  
#DATABASE="jack jackli test1 test2 test3 test4"  
DATABASE="all-databases"   #所有数据库备份
IPADDR=`ip add show | grep 192 | awk '{print $2}' | awk -F '/' '{print $1}'`
BACKUP_DIR=/data/jackbackup  #备份文件存储路径  
LOGFILE=${BACKUP_DIR}/mysql_backup.log #日记文件路径  
MYSQL_CONF=/etc/my.cnf   #mysql配置文件路径
MYSQL_BOOT_SHELL=/etc/init.d/mysqld  #mysql启动脚本
MYSQL_CONF_NAME=`basename ${MYSQL_CONF}`   #mysql配置文件名称
MYSQL_BOOT_SHELL_NAME=`basename ${MYSQL_BOOT_SHELL}`  #mysql启动脚本名称
DATE=`date '+%Y%m%d_%H%M%S'` #日期格式（作为文件名）  
DATE_YEAR=`date '+%Y'`
DATE_MONTH=`date '+%m'`
FORMAT=${ENV}_${TYPE}_${DATE}
BACKUP_DIR_CHILD="${DATE_YEAR}/${DATE_MONTH}/${FORMAT}"
DUMPFILE=${FORMAT}.sql #备份文件名  
DUMPFILE_INFO=${FORMAT}.sql.info #备份数据库信息名称  
ARCHIVE=${FORMAT}.tar.gz #压缩文件名  
MYSQL_DATADIR=`mysql -h${HOSTNAME} -u${USER} -p${PASSWORD} -e "show global variables like 'datadir';" | awk '{print $2}' | tail -n 1`
MYSQL_BINLOG_BASENAME="dirname `mysql -h${HOSTNAME} -u${USER} -p${PASSWORD} -e "show global variables like 'log_bin_basename';" | awk '{print $2}' | tail -n 1`"
MYSQL_BINLOG_INDEX=`mysql -h${HOSTNAME} -u${USER} -p${PASSWORD} -e "show global variables like 'log_bin_index';" | awk '{print $2}' | tail -n 1`
INNODB_VERSION=`mysql -h${HOSTNAME} -u${USER} -p${PASSWORD} -e "show global variables like 'innodb_version';" | awk '{print $2}' | tail -n 1`
BASE_DIR=`mysql -h${HOSTNAME} -u${USER} -p${PASSWORD} -e "show global variables like 'basedir';" | awk '{print $2}' | tail -n 1`
OPT='--single-transaction --flush-logs --master-data=2 --all-databases'
#OPT="--single-transaction --master-data=2 --flush-logs --databases ${DATABASE}"
OPTIONS="-h${HOSTNAME} -u${USER} -p${PASSWORD} ${OPT}"    

##判断备份文件存储目录和二进制存储目录是否存在，否则创建该目录  
if [ ! -d "${BACKUP_DIR}/${BACKUP_DIR_CHILD}" ]; then mkdir -p "${BACKUP_DIR}/${BACKUP_DIR_CHILD}"; fi

#开始备份之前，将备份信息头写入日记文件   
echo "———————————————–————————————————————————" >> $LOGFILE  
echo "BACKUP DATETIME: "${DATE} >> $LOGFILE  
echo "———————————————–————————————————————–———" >> $LOGFILE  

#使用mysqldump 命令备份制定数据库，并以格式化的时间戳命名备份文件  
cd ${BACKUP_DIR}/${BACKUP_DIR_CHILD} && echo "Full_Backup_Databases: ${DATABASE}.........." >> $LOGFILE

#开始备份
mysqldump ${OPTIONS} > ${DUMPFILE} 2> /dev/null 

#判断数据库备份是否成功  
if [[ $? == 0 ]]; then  
    echo "Full_Backup_Databases: Success" >> $LOGFILE

    #存放binlog文件名变量数组
    VAR_BINLOG_NAME_LONG=(`cat ${MYSQL_BINLOG_INDEX} | sed "s#^.#$(${MYSQL_BINLOG_BASENAME})#g" | sort | head -n -1`)
    VAR_BINLOG_NAME_SHORT=(`cat ${MYSQL_BINLOG_INDEX} | sed "s#^./##g" | sort | head -n -1`)
    
    #对binlog进行存档
    echo "Copy_Mysql_Binlog_To_Bakcup_Binlogs_Dir.........." >> ${LOGFILE}  
    for i in `seq 0 ${#VAR_BINLOG_NAME_LONG[*]}`;do
    if [ "${i}" != "${#VAR_BINLOG_NAME_LONG[*]}" ];then
    		\cp -ar ${VAR_BINLOG_NAME_LONG[$[i]]} ${VAR_BINLOG_NAME_SHORT[${i}]}_${FORMAT}
    fi
    done
    
    #删除之前旧binlog
    if [[ $? == 0 ]]; then  
    	echo "Copy_Mysql_Binlog_To_Bakcup_Binlogs_Dir: Success" >> ${LOGFILE}  
        PURGE_BINARY_LOGS="purge binary logs to `mysql -h${HOSTNAME} -u${USER} -p${PASSWORD} -e 'show binary logs;' | tail -n 1 | awk '{print $1}'`"
        PURGE_BINARY_LOGS_RESULT=`echo ${PURGE_BINARY_LOGS} | sed -e 's/to /to \"/g' | sed -e 's/$/\"/g'`
    echo "Delete_Old_Binlog.........." >> ${LOGFILE}
        mysql -h${HOSTNAME} -u${USER} -p${PASSWORD} -e "${PURGE_BINARY_LOGS_RESULT}"
    [ $? == 0 ] && echo "Delete_Old_Binlog: Success" >> ${LOGFILE} || echo "Delete_Old_Binlog: Failure" >> ${LOGFILE} 
    else
    	echo "Copy_Mysql_Binlog_To_Bakcup_Binlogs_Dir: Failure" >> ${LOGFILE}  
    fi
    
    #对配置文件和启动脚本进行存档
    echo "Copy_Mysql_Config_File_and_Boot_Shell_To_Bakcup_Dir.........." >> ${LOGFILE}  
    \cp -ar ${MYSQL_CONF} ${BACKUP_DIR}/${BACKUP_DIR_CHILD}/${FORMAT}_${MYSQL_CONF_NAME}  && \cp -ar ${MYSQL_BOOT_SHELL} ${BACKUP_DIR}/${BACKUP_DIR_CHILD}/${FORMAT}_${MYSQL_BOOT_SHELL_NAME}
    [ $? == 0 ] && echo "Copy_Mysql_Config_File_and_Boot_Shell_To_Bakcup_Dir: Success" >> ${LOGFILE} || echo "Copy_Mysql_Config_File_and_Boot_Shell_To_Bakcup_Dir: Failure" >> ${LOGFILE} 
    
    #写入信息到文件
    echo "———————————————–————————————————————————" >> ${DUMPFILE_INFO}
    echo "MYSQL_INFO" >> ${DUMPFILE_INFO}
    echo "———————————————–————————————————————–———" >> ${DUMPFILE_INFO}
    echo "BACKUP_HOST: ${IPADDR}" >> ${DUMPFILE_INFO}
    echo "BACKUP_ENV: ${ENV}" >> ${DUMPFILE_INFO}
    echo "BACKUP_TYPE: ${TYPE}" >> ${DUMPFILE_INFO}
    echo "BACKUP_DATABASE: ${DATABASE[@]}" >> ${DUMPFILE_INFO}
    echo "BACKUP_DATABASE_VERSION: ${INNODB_VERSION}" >> ${DUMPFILE_INFO}
    echo "BACKUP_DATABASE_BASE_DIR: ${BASE_DIR}" >> ${DUMPFILE_INFO}
    echo "BACKUP_DATABASE_DATA_DIR: ${MYSQL_DATADIR}" >> ${DUMPFILE_INFO}
    echo "BACKUP_DATABASE_CONF: ${MYSQL_CONF}" >> ${DUMPFILE_INFO}
    echo "BACKUP_DATABASE_START_SHELL: ${MYSQL_BOOT_SHELL}" >> ${DUMPFILE_INFO}
    echo "  " >> ${DUMPFILE_INFO}
    echo "———————————————–————————————————————————" >> ${DUMPFILE_INFO}
    echo "MYSQL_BACKUP_LOG" >> ${DUMPFILE_INFO}
    sed -n "/${DATE}/,/Bakcup_Dir:/p" ${LOGFILE} >> ${DUMPFILE_INFO}
    
    #创建备份文件的压缩包  
    echo "Create_Compression_File.........." >> ${LOGFILE}  
    cd .. && tar czf ${ARCHIVE} ${FORMAT} >& /dev/null 
    #判断压缩是否成功
    if [ $? == 0 ];then
    echo "Create_Compression_File: Success" >> ${LOGFILE}
    	#删除原始备份文件，只需保留数据库备份文件的压缩包即可  
    echo "Delete_Source_Backup_files.........." >> ${LOGFILE}
    	rm -rf ${FORMAT}
    [ $? == 0 ] && echo "Delete_Source_Backup_files: Success" >> ${LOGFILE} || echo "Delete_Source_Backup_files: Failure" >> ${LOGFILE}
    	echo "[${ARCHIVE}] Backup_Succeed!" >> ${LOGFILE} 
    else
    echo "Create_Compression_File: Failure" >> ${LOGFILE}
    echo "[${ARCHIVE}] Backup_Failure!" >> ${LOGFILE} 
    fi
else  
    echo "[${DUMPFILE}] Database_Backup_Failure!" >> ${LOGFILE}  
fi  

#输出备份过程结束的提醒消息  
echo "Backup_Process_Done" >> ${LOGFILE}
echo "  " >> ${LOGFILE}  

-----------FULL_BACKUP_ALLDB_Shell----------
[root@test /data]# cat mysql_full_backup_allDB.sh
#!/bin/bash  
#Describe: Shell Script For Backup MySQL Database Everyday Automatically By Crontab  
#Type: Multi_Or_ALL_Database_Full_Backup
#Duthor: JackLi
#Date: 2020-11-22
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:/usr/local/mysql/bin
export LANG=en_US.UTF-8

ENV=Pro
TYPE=Full
USER=root  
HOSTNAME="localhost"  
PASSWORD="test"  
#DATABASE="jack jackli test1 test2 test3 test4"  
DATABASE="all-databases"   #所有数据库备份
IPADDR=`ip add show | grep 192 | awk '{print $2}' | awk -F '/' '{print $1}'`
BACKUP_DIR=/data/jackbackup  #备份文件存储路径  
LOGFILE=${BACKUP_DIR}/mysql_backup.log #日记文件路径  
MYSQL_CONF=/etc/my.cnf   #mysql配置文件路径
MYSQL_BOOT_SHELL=/etc/init.d/mysqld  #mysql启动脚本
MYSQL_CONF_NAME=`basename ${MYSQL_CONF}`   #mysql配置文件名称
MYSQL_BOOT_SHELL_NAME=`basename ${MYSQL_BOOT_SHELL}`  #mysql启动脚本名称
DATE=`date '+%Y%m%d_%H%M%S'` #日期格式（作为文件名）  
DATE_YEAR=`date '+%Y'`
DATE_MONTH=`date '+%m'`
FORMAT=${ENV}_${TYPE}_${DATE}
BACKUP_DIR_CHILD="${DATE_YEAR}/${DATE_MONTH}/${FORMAT}"
DUMPFILE=${FORMAT}.sql #备份文件名  
DUMPFILE_INFO=${FORMAT}.sql.info #备份数据库信息名称  
ARCHIVE=${FORMAT}.tar.gz #压缩文件名  
MYSQL_DATADIR=`mysql -h${HOSTNAME} -u${USER} -p${PASSWORD} -e "show global variables like 'datadir';" | awk '{print $2}' | tail -n 1`
INNODB_VERSION=`mysql -h${HOSTNAME} -u${USER} -p${PASSWORD} -e "show global variables like 'innodb_version';" | awk '{print $2}' | tail -n 1`
BASE_DIR=`mysql -h${HOSTNAME} -u${USER} -p${PASSWORD} -e "show global variables like 'basedir';" | awk '{print $2}' | tail -n 1`
OPT='--single-transaction --master-data=2 --all-databases'
#OPT="--single-transaction --master-data=2 --flush-logs --databases ${DATABASE}"
OPTIONS="-h${HOSTNAME} -u${USER} -p${PASSWORD} ${OPT}"    

##判断备份文件存储目录和二进制存储目录是否存在，否则创建该目录  
if [ ! -d "${BACKUP_DIR}/${BACKUP_DIR_CHILD}" ]; then mkdir -p "${BACKUP_DIR}/${BACKUP_DIR_CHILD}"; fi

#开始备份之前，将备份信息头写入日记文件   
echo "———————————————–————————————————————————" >> $LOGFILE  
echo "BACKUP DATETIME: "${DATE} >> $LOGFILE  
echo "———————————————–————————————————————–———" >> $LOGFILE  

#使用mysqldump 命令备份制定数据库，并以格式化的时间戳命名备份文件  
cd ${BACKUP_DIR}/${BACKUP_DIR_CHILD} && echo "Full_Backup_Databases: ${DATABASE}.........." >> $LOGFILE

#开始备份
mysqldump ${OPTIONS} > ${DUMPFILE} 2> /dev/null 

#判断数据库备份是否成功  
if [[ $? == 0 ]]; then  
    echo "Full_Backup_Databases: Success" >> $LOGFILE

    #对配置文件和启动脚本进行存档
    echo "Copy_Mysql_Config_File_and_Boot_Shell_To_Bakcup_Dir.........." >> ${LOGFILE}  
    \cp -ar ${MYSQL_CONF} ${BACKUP_DIR}/${BACKUP_DIR_CHILD}/${FORMAT}_${MYSQL_CONF_NAME}  && \cp -ar ${MYSQL_BOOT_SHELL} ${BACKUP_DIR}/${BACKUP_DIR_CHILD}/${FORMAT}_${MYSQL_BOOT_SHELL_NAME}
    [ $? == 0 ] && echo "Copy_Mysql_Config_File_and_Boot_Shell_To_Bakcup_Dir: Success" >> ${LOGFILE} || echo "Copy_Mysql_Config_File_and_Boot_Shell_To_Bakcup_Dir: Failure" >> ${LOGFILE} 
    
    #写入信息到文件
    echo "———————————————–————————————————————————" >> ${DUMPFILE_INFO}
    echo "MYSQL_INFO" >> ${DUMPFILE_INFO}
    echo "———————————————–————————————————————–———" >> ${DUMPFILE_INFO}
    echo "BACKUP_HOST: ${IPADDR}" >> ${DUMPFILE_INFO}
    echo "BACKUP_ENV: ${ENV}" >> ${DUMPFILE_INFO}
    echo "BACKUP_TYPE: ${TYPE}" >> ${DUMPFILE_INFO}
    echo "BACKUP_DATABASE: ${DATABASE[@]}" >> ${DUMPFILE_INFO}
    echo "BACKUP_DATABASE_VERSION: ${INNODB_VERSION}" >> ${DUMPFILE_INFO}
    echo "BACKUP_DATABASE_BASE_DIR: ${BASE_DIR}" >> ${DUMPFILE_INFO}
    echo "BACKUP_DATABASE_DATA_DIR: ${MYSQL_DATADIR}" >> ${DUMPFILE_INFO}
    echo "BACKUP_DATABASE_CONF: ${MYSQL_CONF}" >> ${DUMPFILE_INFO}
    echo "BACKUP_DATABASE_START_SHELL: ${MYSQL_BOOT_SHELL}" >> ${DUMPFILE_INFO}
    echo "  " >> ${DUMPFILE_INFO}
    echo "———————————————–————————————————————————" >> ${DUMPFILE_INFO}
    echo "MYSQL_BACKUP_LOG" >> ${DUMPFILE_INFO}
    sed -n "/${DATE}/,/Bakcup_Dir:/p" ${LOGFILE} >> ${DUMPFILE_INFO}
    
    #创建备份文件的压缩包  
    echo "Create_Compression_File.........." >> ${LOGFILE}  
    cd .. && tar czf ${ARCHIVE} ${FORMAT} >& /dev/null 
    #判断压缩是否成功
    if [ $? == 0 ];then
    echo "Create_Compression_File: Success" >> ${LOGFILE}
    	#删除原始备份文件，只需保留数据库备份文件的压缩包即可  
    echo "Delete_Source_Backup_files.........." >> ${LOGFILE}
    	rm -rf ${FORMAT}
    [ $? == 0 ] && echo "Delete_Source_Backup_files: Success" >> ${LOGFILE} || echo "Delete_Source_Backup_files: Failure" >> ${LOGFILE}
    	echo "[${ARCHIVE}] Backup_Succeed!" >> ${LOGFILE} 
    else
    echo "Create_Compression_File: Failure" >> ${LOGFILE}
    echo "[${ARCHIVE}] Backup_Failure!" >> ${LOGFILE} 
    fi
else  
    echo "[${DUMPFILE}] Database_Backup_Failure!" >> ${LOGFILE}  
fi  

#输出备份过程结束的提醒消息  
echo "Backup_Process_Done" >> ${LOGFILE}
echo "  " >> ${LOGFILE} 

-----------FULL_BACKUP_SingleDB_Shell----------
#!/bin/bash  
#Describe: Shell Script For Backup MySQL Database Everyday Automatically By Crontab  
#Type: Single_Database_Full_Backup
#mysql_info: mysql5.7
#Author: JackLi
#Date: 2020-12-04
#set -e

#----user authrization
#grant select,lock tables,replication client,show view,trigger,reload,execute,super on *.* to dbbackup@'localhost';
#[root@salt ~]# openssl rand -base64 5
#hZH3oCw=
#alter user dbbackup@'localhost' identified by "hZH3oCw=";
#flush privileges;

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:/usr/local/mysql/bin
export LANG=en_US.UTF-8

ENV=Dev
TYPE=Full
USER=dbbackup 
HOSTNAME="localhost"  
PASSWORD="hZH3oCw="  
DATABASE=(car_platform flight_manager hotelresource payorder travelproduct)
IPADDR=`ip add show | grep 192 | awk '{print $2}' | awk -F '/' '{print $1}'`
BACKUP_DIR=/home/backup  #备份文件存储路径  
LOGFILE=${BACKUP_DIR}/mysql_backup.log #日记文件路径  
MYSQL_CONF=/etc/my.cnf   #mysql配置文件路径
MYSQL_BOOT_SHELL=/etc/init.d/mysqld  #mysql启动脚本路径
MYSQL_CONF_NAME=`basename ${MYSQL_CONF}`   #mysql配置文件名称
MYSQL_BOOT_SHELL_NAME=`basename ${MYSQL_BOOT_SHELL}`  #mysql启动脚本名称
DATE=`date +%Y%m%d_%H%M%S` #日期格式（作为目录名）  
DATE_FILE="date +%Y%m%d_%H%M%S" #日期格式（作为文件名） 
DATE_YEAR=`date '+%Y'`
DATE_MONTH=`date '+%m'`
FORMAT=${ENV}_${TYPE}_${DATE}
BACKUP_DIR_CHILD="${DATE_YEAR}/${DATE_MONTH}/${FORMAT}"
DUMPFILE_INFO=${FORMAT}.sql.info #备份数据库信息名称  
MYSQL_DATADIR=`mysql -h${HOSTNAME} -u${USER} -p${PASSWORD} -e "show global variables like 'datadir';" | awk '{print $2}' | tail -n 1`
INNODB_VERSION=`mysql -h${HOSTNAME} -u${USER} -p${PASSWORD} -e "show global variables like 'innodb_version';" | awk '{print $2}' | tail -n 1`
BASE_DIR=`mysql -h${HOSTNAME} -u${USER} -p${PASSWORD} -e "show global variables like 'basedir';" | awk '{print $2}' | tail -n 1`
OPT="--single-transaction --master-data=2 --databases "
OPTIONS="-h${HOSTNAME} -u${USER} -p${PASSWORD} ${OPT}"    

##判断备份文件存储目录和二进制存储目录是否存在，否则创建该目录  
if [ ! -d "${BACKUP_DIR}/${BACKUP_DIR_CHILD}" ]; then mkdir -p "${BACKUP_DIR}/${BACKUP_DIR_CHILD}"; fi
cd ${BACKUP_DIR}/${BACKUP_DIR_CHILD}

#开始备份之前，将备份信息头写入日记文件   
echo " " >> $LOGFILE
echo "———————————————–————————————————————————" >> $LOGFILE  
echo "BACKUP DATETIME:" ${DATE} >> $LOGFILE  
echo "———————————————–————————————————————–———" >> $LOGFILE  

#开始备份
for i in `seq 0 ${#DATABASE[*]}`;do
	if [ ${i} != ${#DATABASE[*]} ];then
		DUMPFILE=${ENV}_${TYPE}_`${DATE_FILE}`_${DATABASE[${i}]}.sql #备份文件名
		echo "Full_Backup_Databases: ${DATABASE[${i}]}.........." >> $LOGFILE
		mysqldump ${OPTIONS} ${DATABASE[${i}]} > ${DUMPFILE} 2> /dev/null 
		#判断数据库备份是否成功  
		if [[ $? == 0 ]]; then  
    		echo "Full_Backup_Databases ${DATABASE[${i}]}: Success" >> $LOGFILE
		else  
    		echo "Full_Backup_Databases ${DATABASE[${i}]}: Falure" >> ${LOGFILE}  
		fi  
	fi
done

#对配置文件和启动脚本进行存档
echo "Copy_Mysql_Config_File_and_Boot_Shell_To_Bakcup_Dir.........." >> ${LOGFILE}  
\cp -ar ${MYSQL_CONF} ${BACKUP_DIR}/${BACKUP_DIR_CHILD}/${FORMAT}_${MYSQL_CONF_NAME}  && \cp -ar ${MYSQL_BOOT_SHELL} ${BACKUP_DIR}/${BACKUP_DIR_CHILD}/${FORMAT}_${MYSQL_BOOT_SHELL_NAME}
[ $? == 0 ] && echo "Copy_Mysql_Config_File_and_Boot_Shell_To_Bakcup_Dir: Success" >> ${LOGFILE} || echo "Copy_Mysql_Config_File_and_Boot_Shell_To_Bakcup_Dir: Failure" >> ${LOGFILE} 

#写入信息到文件
echo "———————————————–————————————————————————" >> ${DUMPFILE_INFO}
echo "MYSQL_INFO" >> ${DUMPFILE_INFO}
echo "———————————————–————————————————————–———" >> ${DUMPFILE_INFO}
echo "BACKUP_HOST: ${IPADDR}" >> ${DUMPFILE_INFO}
echo "BACKUP_ENV: ${ENV}" >> ${DUMPFILE_INFO}
echo "BACKUP_TYPE: ${TYPE}" >> ${DUMPFILE_INFO}
echo "BACKUP_DATABASE: ${DATABASE[@]}" >> ${DUMPFILE_INFO}
echo "BACKUP_DATABASE_VERSION: ${INNODB_VERSION}" >> ${DUMPFILE_INFO}
echo "BACKUP_DATABASE_BASE_DIR: ${BASE_DIR}" >> ${DUMPFILE_INFO}
echo "BACKUP_DATABASE_DATA_DIR: ${MYSQL_DATADIR}" >> ${DUMPFILE_INFO}
echo "BACKUP_DATABASE_CONF: ${MYSQL_CONF}" >> ${DUMPFILE_INFO}
echo "BACKUP_DATABASE_START_SHELL: ${MYSQL_BOOT_SHELL}" >> ${DUMPFILE_INFO}
echo "  " >> ${DUMPFILE_INFO}
echo "———————————————–————————————————————————" >> ${DUMPFILE_INFO}
echo "MYSQL_BACKUP_LOG" >> ${DUMPFILE_INFO}
sed -n "/${DATE}/,/Bakcup_Dir:/p" ${LOGFILE} >> ${DUMPFILE_INFO}

#创建备份文件的压缩包  
echo "Create_Compression_File.........." >> ${LOGFILE}  
ARCHIVE=${FORMAT}.tar.gz #压缩文件名  
cd .. && tar czf ${ARCHIVE} ${FORMAT} >& /dev/null 
#判断压缩是否成功  
if [ $? == 0 ];then
	echo "Create_Compression_File: Success" >> ${LOGFILE}
    	#删除原始备份文件，只需保留数据库备份文件的压缩包即可  
	echo "Delete_Source_Backup_files.........." >> ${LOGFILE}
	rm -rf ${FORMAT}
	[ $? == 0 ] && echo "Delete_Source_Backup_files: Success" >> ${LOGFILE} || echo "Delete_Source_Backup_files: Failure" >> ${LOGFILE}
	echo "[${ARCHIVE}] Backup_Succeed!" >> ${LOGFILE} 
else
	echo "Create_Compression_File: Failure" >> ${LOGFILE}
	echo "[${ARCHIVE}] Backup_Failure!" >> ${LOGFILE} 
fi

#输出备份过程结束的提醒消息  
echo "Backup_Process_Done" >> ${LOGFILE}
echo "  " >> ${LOGFILE}  

-----------INCREMENT_BACKUP_ALLDB_Shell----------
[root@test /data]# cat mysql_increment_backup.sh 
#!/bin/bash
#Describe: Shell Command For Backup MySQL Database Everyday Automatically By Crontab  
#Type: Increment Backup
#mysql_info: mysql5.7
#Author: JackLi
#Date: 2020-11-22

#----user authrization
#grant select,lock tables,replication client,show view,trigger,reload,execute,super on *.* to dbbackup@'localhost';
#[root@salt ~]# openssl rand -base64 5
#hZH3oCw=
#alter user dbbackup@'localhost' identified by "hZH3oCw=";
#flush privileges;

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:/usr/local/mysql/bin
export LANG=en_US.UTF-8

ENV=Dev
TYPE=Increment
USER=dbbackup
HOSTNAME="localhost"
PASSWORD="hZH3oCw="
BACKUP_DIR=/home/backup  #备份文件存储路径  
LOGFILE=${BACKUP_DIR}/mysql_backup.log #日记文件路径  
DATE=`date '+%Y%m%d_%H%M%S'` #日期格式（作为文件名）  
DATE_FILE="date +%Y%m%d_%H%M%S" #日期格式（作为文件名） 
DATE_YEAR=`date '+%Y'`
DATE_MONTH=`date '+%m'`
FORMAT=${ENV}_${TYPE}_${DATE}
BACKUP_DIR_CHILD="${DATE_YEAR}/${DATE_MONTH}/${FORMAT}"
DUMPFILE_INFO=${FORMAT}.sql.info #备份数据库信息名称  
ARCHIVE=${FORMAT}.tar.gz #压缩文件名  
MYSQL_BINLOG_INDEX=`mysql -h${HOSTNAME} -u${USER} -p${PASSWORD} -e "show global variables like 'log_bin_index';" | awk '{print $2}' | tail -n 1`
MYSQL_BINLOG_BASENAME="dirname `mysql -h${HOSTNAME} -u${USER} -p${PASSWORD} -e "show global variables like 'log_bin_basename';" | awk '{print $2}' | tail -n 1`"

##判断备份文件存储目录和二进制存储目录是否存在，否则创建该目录  
if [ ! -d "${BACKUP_DIR}/${BACKUP_DIR_CHILD}" ]; then mkdir -p "${BACKUP_DIR}/${BACKUP_DIR_CHILD}"; fi

#开始备份之前，将备份信息头写入日记文件   
echo "———————————————–————————————————————————" >> $LOGFILE
echo "BACKUP DATETIME: "${DATE} >> $LOGFILE
echo "———————————————–————————————————————–———" >> $LOGFILE

#对binlog进行存档
cd ${BACKUP_DIR}/${BACKUP_DIR_CHILD} && echo "Increment_Backup_Databases.........." >> $LOGFILE

#mysql日志切割
mysqladmin -h${HOSTNAME} -u${USER} -p${PASSWORD} flush-logs 2> /dev/null
if [[ $? == 0 ]]; then
    #存放binlog文件名变量数组
    VAR_BINLOG_NAME_LONG=(`cat ${MYSQL_BINLOG_INDEX} | sed "s#^.#$(${MYSQL_BINLOG_BASENAME})#g" | sort | head -n -1`)
    VAR_BINLOG_NAME_SHORT=(`cat ${MYSQL_BINLOG_INDEX} | sed "s#^./##g" | sort | head -n -1`)

    #循环复制binlog日志到备份目录
    echo "Copy_Binlog_To_BackupDir.........." >> $LOGFILE
    for i in `seq 0 ${#VAR_BINLOG_NAME_LONG[*]}`;do
        if [ "${i}" != "${#VAR_BINLOG_NAME_LONG[*]}" ];then
    	\cp -ar ${VAR_BINLOG_NAME_LONG[$[i]]} ${VAR_BINLOG_NAME_SHORT[${i}]}_${ENV}_${TYPE}_`${DATE_FILE}`
        fi
    done
    
    #删除之前旧binlog
    if [[ $? == 0 ]]; then
        echo "Copy_Binlog_To_BackupDir: Success" >> $LOGFILE
        PURGE_BINARY_LOGS="purge binary logs to `mysql -h${HOSTNAME} -u${USER} -p${PASSWORD} -e 'show binary logs;' | tail -n 1 | awk '{print $1}'`"
        PURGE_BINARY_LOGS_RESULT=`echo ${PURGE_BINARY_LOGS} | sed -e 's/to /to \"/g' | sed -e 's/$/\"/g'`
        echo "Delete_Old_Binlog.........." >> ${LOGFILE}
        mysql -h${HOSTNAME} -u${USER} -p${PASSWORD} -e "${PURGE_BINARY_LOGS_RESULT}"
        if [[ $? == 0 ]];then
        echo "Delete_Old_Binlog: Success" >> ${LOGFILE} 
    else
        echo "Delete_Old_Binlog: Failure" >> ${LOGFILE}
        fi
    else
        echo "Copy_Binlog_To_BackupDir: Failure" >> $LOGFILE
    fi
    
    #创建备份文件的压缩包  
    echo "Create_Compression_File.........." >> ${LOGFILE}
    cd .. && tar czf ${ARCHIVE} ${FORMAT} >& /dev/null
    
    #判断压缩是否成功
    if [ $? == 0 ];then
        echo "Create_Compression_File: Success" >> ${LOGFILE}
    
        #删除原始备份文件，只需保留数据库备份文件的压缩包即可  
        echo "Delete_Source_Backup_files.........." >> ${LOGFILE}
        rm -rf ${FORMAT}
        if [ $? == 0 ];then
        echo "Delete_Source_Backup_files: Success" >> ${LOGFILE} 
            echo "[${ARCHIVE}] Backup_Succeed!" >> ${LOGFILE}
            echo "Increment_Backup_Databases: Success" >> $LOGFILE
    else 
        echo "Delete_Source_Backup_files: Failure" >> ${LOGFILE}
        fi
    else
        echo "Create_Compression_File: Failure" >> ${LOGFILE}
        echo "[${ARCHIVE}] Backup_Failure!" >> ${LOGFILE}
    fi
else
    echo "Increment_Backup_Databases: Failure" >> $LOGFILE
fi
----------------------------------------
mysql配置调整
#使mysql表名允许小写
lower-case-table-names = 1  
#跳过名称解析，可以解决navicat远程连接mysql慢问题
skip-name-resolve
#跳过授权表，通过此方式重置mysql root密码
skip-grant-tables = 1
----------------------------------------
```



## 26. mysqlbinlog日志解析

### 26.1 使用mysqlbinlog分析

**mysqlbinlog转换为sql，对其base64解码并详细输出，从而进行binlog分析**

```bash
mysqlbinlog --no-defaults master-bin.000079 > /tmp/binlog.sql
```

**mysqlbinlog转换为sql，对其base64解码并详细输出，从而进行binlog分析**

```bash
mysqlbinlog --no-defaults -vv --base64-output=decode-rows master-bin.000079 > /tmp/binlog-new.sql
```

```bash
[root@mysql01 /tmp]# ll -h
total 7.5G
-rw-r--r-- 1 root root 5.5G Dec  1 09:09 binlog-new.sql	# 解码binlog
-rw-r--r-- 1 root root 2.0G Nov 30 20:56 binlog.sql	# 未解码binlog
```

**未解码binlog内容片段**

```bash
#231129 16:21:55 server id 30  end_log_pos 1554 CRC32 0x2251eb00 	Write_rows: table id 144 flags: STMT_END_F

BINLOG '
o/RmZRMeAAAAOAAAAIsFAAAAAJAAAAAAAAEABnphYmJpeAAHaGlzdG9yeQAECAMFAwEIAHpSNkw=
o/RmZR4eAAAAhwAAABIGAAAAAJAAAAAAAAEAAgAE//DZiQAAAAAAAL/zZmUAAAAAAAA2QOiAvS/w
24kAAAAAAAC/82ZlAAAAAAAARUDogL0v8NqJAAAAAAAAv/NmZQAAAAAAAD5A6IC9L/AxigAAAAAA
AL/zZmUAAAAAAABFQOiAvS8A61Ei
'/*!*/;
# at 1554
```

**解码binlog内容片段**

```bash
#231129 16:31:49 server id 30  end_log_pos 8734516 CRC32 0xed0660ca     Update_rows: table id 109 flags: STMT_END_F
### UPDATE `currency_rate`.`qrtz_scheduler_state`
### WHERE
###   @1='CurrencyRateSyncSchedule' /* VARSTRING(480) meta=480 nullable=0 is_null=0 */
###   @2='pro-java-currencyrate-service-hs-com-rollout-7574648f49-lsghf1696846181249' /* VARSTRING(760) meta=760 nullable=0 is_null=0 */
###   @3=1701246701683 /* LONGINT meta=0 nullable=0 is_null=0 */
###   @4=7500 /* LONGINT meta=0 nullable=0 is_null=0 */
### SET
###   @1='CurrencyRateSyncSchedule' /* VARSTRING(480) meta=480 nullable=0 is_null=0 */
###   @2='pro-java-currencyrate-service-hs-com-rollout-7574648f49-lsghf1696846181249' /* VARSTRING(760) meta=760 nullable=0 is_null=0 */
###   @3=1701246709185 /* LONGINT meta=0 nullable=0 is_null=0 */
###   @4=7500 /* LONGINT meta=0 nullable=0 is_null=0 */
# at 8734516
```



### 26.2 使用binlog2sql工具分析

```bash
[root@prometheus ~]# git clone https://github.com/danfengcao/binlog2sql.git && cd binlog2sql
[root@prometheus binlog2sql]# pip-3 install -r requirements.txt 
```

**mysql server 必须配置如下**

```bash
[mysqld]
server_id = 1							# 配置server_id
log_bin = /var/log/mysql/mysql-bin.log	# 开启binlog
max_binlog_size = 1G					# binlog文件最大大小
binlog_format = row						# 行格式
binlog_row_image = full		# full记录每一行的变更(不管sql语句是否涉及字段)，minimal只记录影响的行

#  binlog_row_image = full 解释#
### UPDATE `test`.`t2`
### WHERE
###   @1=1 /* INT meta=0 nullable=0 is_null=0 */
###   @2='gz' /* STRING(20) meta=65044 nullable=1 is_null=0 */
###   @3='yayundeng' /* STRING(20) meta=65044 nullable=1 is_null=0 */
###   @4=1 /* INT meta=0 nullable=1 is_null=0 */
### SET
###   @1=1 /* INT meta=0 nullable=0 is_null=0 */
###   @2='gz' /* STRING(20) meta=65044 nullable=1 is_null=0 */
###   @3='yayundeng' /* STRING(20) meta=65044 nullable=1 is_null=0 */
###   @4=99 /* INT meta=0 nullable=1 is_null=0 */

# binlog_row_image = minimal 解释#
### UPDATE `test`.`t2`
### WHERE
###   @1=1 /* INT meta=0 nullable=0 is_null=0 */
### SET
###   @4=100 /* INT meta=0 nullable=1 is_null=0 */
# at 2309

# 建议授权
GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 
```


**恢复数据步骤**

```bash
# 登录mysql，查看目前的binlog文件
mysql> show master status;
+------------------+-----------+
| Log_name         | File_size |
+------------------+-----------+
| mysql-bin.000051 |       967 |
| mysql-bin.000052 |       965 |
+------------------+-----------+

# 最新的binlog文件是mysql-bin.000052，我们再定位误操作SQL的binlog位置。误操作人只能知道大致的误操作时间，我们根据大致时间过滤数据。
shell> python binlog2sql/binlog2sql.py -h127.0.0.1 -P3306 -uadmin -p'admin' -dtest -ttbl --start-file='mysql-bin.000052' --start-datetime='2016-12-13 20:25:00' --stop-datetime='2016-12-13 20:30:00'
输出：
INSERT INTO `test`.`tbl`(`addtime`, `id`, `name`) VALUES ('2016-12-13 20:26:00', 4, '小李'); #start 317 end 487 time 2016-12-13 20:26:26
UPDATE `test`.`tbl` SET `addtime`='2016-12-12 00:00:00', `id`=4, `name`='小李' WHERE `addtime`='2016-12-13 20:26:00' AND `id`=4 AND `name`='小李' LIMIT 1; #start 514 end 701 time 2016-12-13 20:27:07
DELETE FROM `test`.`tbl` WHERE `addtime`='2016-12-10 00:04:33' AND `id`=1 AND `name`='小赵' LIMIT 1; #start 728 end 938 time 2016-12-13 20:28:05
DELETE FROM `test`.`tbl` WHERE `addtime`='2016-12-10 00:04:48' AND `id`=2 AND `name`='小钱' LIMIT 1; #start 728 end 938 time 2016-12-13 20:28:05
DELETE FROM `test`.`tbl` WHERE `addtime`='2016-12-13 20:25:00' AND `id`=3 AND `name`='小孙' LIMIT 1; #start 728 end 938 time 2016-12-13 20:28:05
DELETE FROM `test`.`tbl` WHERE `addtime`='2016-12-12 00:00:00' AND `id`=4 AND `name`='小李' LIMIT 1; #start 728 end 938 time 2016-12-13 20:28:05

# 我们得到了误操作sql的准确位置在728-938之间，再根据位置进一步过滤，使用flashback模式生成回滚sql，检查回滚sql是否正确(注：真实环境下，此步经常会进一步筛选出需要的sql。结合grep、编辑器等)
shell> python binlog2sql/binlog2sql.py -h127.0.0.1 -P3306 -uadmin -p'admin' -dtest -ttbl --start-file='mysql-bin.000052' --start-position=3346 --stop-position=3556 -B > rollback.sql | cat
输出：
INSERT INTO `test`.`tbl`(`addtime`, `id`, `name`) VALUES ('2016-12-12 00:00:00', 4, '小李'); #start 728 end 938 time 2016-12-13 20:28:05
INSERT INTO `test`.`tbl`(`addtime`, `id`, `name`) VALUES ('2016-12-13 20:25:00', 3, '小孙'); #start 728 end 938 time 2016-12-13 20:28:05
INSERT INTO `test`.`tbl`(`addtime`, `id`, `name`) VALUES ('2016-12-10 00:04:48', 2, '小钱'); #start 728 end 938 time 2016-12-13 20:28:05
INSERT INTO `test`.`tbl`(`addtime`, `id`, `name`) VALUES ('2016-12-10 00:04:33', 1, '小赵'); #start 728 end 938 time 2016-12-13 20:28:05

# 确认回滚sql正确，执行回滚语句。登录mysql确认，数据回滚成功。
shell> mysql -h127.0.0.1 -P3306 -uadmin -p'admin' < rollback.sql
mysql> select * from tbl;
+----+--------+---------------------+
| id | name   | addtime             |
+----+--------+---------------------+
|  1 | 小赵   | 2016-12-10 00:04:33 |
|  2 | 小钱   | 2016-12-10 00:04:48 |
|  3 | 小孙   | 2016-12-13 20:25:00 |
|  4 | 小李   | 2016-12-12 00:00:00 |
+----+--------+---------------------+


# 限制(对比mysqlbinlog)
- mysql server必须开启，离线模式下不能解析
- 参数 *binlog_row_image* 必须为FULL，暂不支持MINIMAL
- 解析速度不如mysqlbinlog

### 优点（对比mysqlbinlog）

- 纯Python开发，安装与使用都很简单
- 自带flashback、no-primary-key解析模式，无需再装补丁
- flashback模式下，更适合[闪回实战](https://github.com/danfengcao/binlog2sql/blob/master/example/mysql-flashback-priciple-and-practice.md)
- 解析为标准SQL，方便理解、筛选
- 代码容易改造，可以支持更多个性化解析



****解析出标准SQL****

```bash
[root@prometheus binlog2sql]# python3 binlog2sql/binlog2sql.py -h192.168.13.163 -P3306 -ubinlog_ops -ppass -d dingtalk_selfbuilt -t user_info --start-file='master-bin.000079' --start-datetime='2023-11-30 11:00:00' --stop-datetime='2023-11-30 12:00:00' | tee result_sql/dingtalk_selfbuilt.user_info.sql

[root@prometheus binlog2sql]# grep -i 'delete' result_sql/dingtalk_selfbuilt.user_info.sql 

INSERT INTO `dingtalk_selfbuilt`.`user_info`(`id`, `corp_id`, `union_id`, `user_id`, `depart_id`, `job_number`, `name`, `state_code`, `mobile`, `email`, `hs_user_id`, `hs_user_name`, `status`, `create_time`, `update_time`, `is_deleted`) VALUES (1730063375908392961, 'ding9a5df197688bc5cc35c2f4657eb6378f', 'MTQjRKeQKcU1MfruiPlz2oQiEiE', '40276017718062865', 1, NULL, '田立群（青锋）', '86', '#Encrypt#_EBF06746966F939B811271E32D3D1A52', NULL, NULL, NULL, '0', '2023-11-30 11:17:06', '2023-11-30 11:17:06', '0'); #start 530817402 end 530817798 time 2023-11-30 11:17:06
UPDATE `dingtalk_selfbuilt`.`user_info` SET `id`=1730063375908392961, `corp_id`='ding9a5df197688bc5cc35c2f4657eb6378f', `union_id`='MTQjRKeQKcU1MfruiPlz2oQiEiE', `user_id`='40276017718062865', `depart_id`=1, `job_number`=NULL, `name`='田立群（青锋）', `state_code`='86', `mobile`='#Encrypt#_EBF06746966F939B811271E32D3D1A52', `email`=NULL, `hs_user_id`='9F05302E-06E5-4157-BB6F-8A47EFA562E6', `hs_user_name`='田立群（青锋）', `status`='1', `create_time`='2023-11-30 11:17:06', `update_time`='2023-11-30 11:17:07', `is_deleted`='0' WHERE `id`=1730063375908392961 AND `corp_id`='ding9a5df197688bc5cc35c2f4657eb6378f' AND `union_id`='MTQjRKeQKcU1MfruiPlz2oQiEiE' AND `user_id`='40276017718062865' AND `depart_id`=1 AND `job_number` IS NULL AND `name`='田立群（青锋）' AND `state_code`='86' AND `mobile`='#Encrypt#_EBF06746966F939B811271E32D3D1A52' AND `email` IS NULL AND `hs_user_id` IS NULL AND `hs_user_name` IS NULL AND `status`='0' AND `create_time`='2023-11-30 11:17:06' AND `update_time`='2023-11-30 11:17:06' AND `is_deleted`='0' LIMIT 1; #start 530821116 end 530821757 time 2023-11-30 11:17:07
UPDATE `dingtalk_selfbuilt`.`user_info` SET `id`=1730043639749791746, `corp_id`='dingf239b82e87a474d7', `union_id`='iic0vniSPE1OW6GFnv3xRF0wiEiE', `user_id`='615281495', `depart_id`=878888446, `job_number`='015211', `name`='刘俊卿', `state_code`='86', `mobile`='#Encrypt#_570E33F4131CE4DC0DB2FFEC87A623B1', `email`='#Encrypt#_0A216ADB082B983A01413C0338D2C5D3', `hs_user_id`='74185DD9-0117-4C02-B48C-7D55761C429E', `hs_user_name`='刘俊卿', `status`='1', `create_time`='2023-11-30 09:58:41', `update_time`='2023-11-30 11:27:25', `is_deleted`='0' WHERE `id`=1730043639749791746 AND `corp_id`='dingf239b82e87a474d7' AND `union_id`='iic0vniSPE1OW6GFnv3xRF0wiEiE' AND `user_id`='615281495' AND `depart_id`=878888446 AND `job_number`='015211' AND `name`='刘俊卿' AND `state_code`='86' AND `mobile`='#Encrypt#_570E33F4131CE4DC0DB2FFEC87A623B1' AND `email`='#Encrypt#_0A216ADB082B983A01413C0338D2C5D3' AND `hs_user_id`='74185DD9-0117-4C02-B48C-7D55761C429E' AND `hs_user_name`='刘俊卿' AND `status`='1' AND `create_time`='2023-11-30 09:58:41' AND `update_time`='2023-11-30 09:58:41' AND `is_deleted`='0' LIMIT 1; #start 536838482 end 536839190 time 2023-11-30 11:27:25
```



****解析出回滚SQL****

-B: 生成回滚sql

从上面生成的标准sql中可以看到position是从530817402到536839190

```bash
[root@prometheus binlog2sql]# python3 binlog2sql/binlog2sql.py -B -h192.168.13.163 -P3306 -ubinlog_ops -ppass -d dingtalk_selfbuilt -t user_info --start-file='master-bin.000079' --start-position=530817402 --stop-position=536839190 | tee result_sql/dingtalk_selfbuilt.user_info_rollback.sql
UPDATE `dingtalk_selfbuilt`.`user_info` SET `id`=1730043639749791746, `corp_id`='dingf239b82e87a474d7', `union_id`='iic0vniSPE1OW6GFnv3xRF0wiEiE', `user_id`='615281495', `depart_id`=878888446, `job_number`='015211', `name`='刘俊卿', `state_code`='86', `mobile`='#Encrypt#_570E33F4131CE4DC0DB2FFEC87A623B1', `email`='#Encrypt#_0A216ADB082B983A01413C0338D2C5D3', `hs_user_id`='74185DD9-0117-4C02-B48C-7D55761C429E', `hs_user_name`='刘俊卿', `status`='1', `create_time`='2023-11-30 09:58:41', `update_time`='2023-11-30 09:58:41', `is_deleted`='0' WHERE `id`=1730043639749791746 AND `corp_id`='dingf239b82e87a474d7' AND `union_id`='iic0vniSPE1OW6GFnv3xRF0wiEiE' AND `user_id`='615281495' AND `depart_id`=878888446 AND `job_number`='015211' AND `name`='刘俊卿' AND `state_code`='86' AND `mobile`='#Encrypt#_570E33F4131CE4DC0DB2FFEC87A623B1' AND `email`='#Encrypt#_0A216ADB082B983A01413C0338D2C5D3' AND `hs_user_id`='74185DD9-0117-4C02-B48C-7D55761C429E' AND `hs_user_name`='刘俊卿' AND `status`='1' AND `create_time`='2023-11-30 09:58:41' AND `update_time`='2023-11-30 11:27:25' AND `is_deleted`='0' LIMIT 1; #start 536838482 end 536839190 time 2023-11-30 11:27:25
UPDATE `dingtalk_selfbuilt`.`user_info` SET `id`=1730063375908392961, `corp_id`='ding9a5df197688bc5cc35c2f4657eb6378f', `union_id`='MTQjRKeQKcU1MfruiPlz2oQiEiE', `user_id`='40276017718062865', `depart_id`=1, `job_number`=NULL, `name`='田立群（青锋）', `state_code`='86', `mobile`='#Encrypt#_EBF06746966F939B811271E32D3D1A52', `email`=NULL, `hs_user_id`=NULL, `hs_user_name`=NULL, `status`='0', `create_time`='2023-11-30 11:17:06', `update_time`='2023-11-30 11:17:06', `is_deleted`='0' WHERE `id`=1730063375908392961 AND `corp_id`='ding9a5df197688bc5cc35c2f4657eb6378f' AND `union_id`='MTQjRKeQKcU1MfruiPlz2oQiEiE' AND `user_id`='40276017718062865' AND `depart_id`=1 AND `job_number` IS NULL AND `name`='田立群（青锋）' AND `state_code`='86' AND `mobile`='#Encrypt#_EBF06746966F939B811271E32D3D1A52' AND `email` IS NULL AND `hs_user_id`='9F05302E-06E5-4157-BB6F-8A47EFA562E6' AND `hs_user_name`='田立群（青锋）' AND `status`='1' AND `create_time`='2023-11-30 11:17:06' AND `update_time`='2023-11-30 11:17:07' AND `is_deleted`='0' LIMIT 1; #start 530821116 end 530821757 time 2023-11-30 11:17:07
DELETE FROM `dingtalk_selfbuilt`.`user_info` WHERE `id`=1730063375908392961 AND `corp_id`='ding9a5df197688bc5cc35c2f4657eb6378f' AND `union_id`='MTQjRKeQKcU1MfruiPlz2oQiEiE' AND `user_id`='40276017718062865' AND `depart_id`=1 AND `job_number` IS NULL AND `name`='田立群（青锋）' AND `state_code`='86' AND `mobile`='#Encrypt#_EBF06746966F939B811271E32D3D1A52' AND `email` IS NULL AND `hs_user_id` IS NULL AND `hs_user_name` IS NULL AND `status`='0' AND `create_time`='2023-11-30 11:17:06' AND `update_time`='2023-11-30 11:17:06' AND `is_deleted`='0' LIMIT 1; #start 530817402 end 530817798 time 2023-11-30 11:17:06
```


****报错****

```
    binlog2sql.process_binlog()
  File "binlog2sql/binlog2sql.py", line 121, in process_binlog
    self.print_rollback_sql(filename=tmp_file)
  File "binlog2sql/binlog2sql.py", line 129, in print_rollback_sql
    for line in reversed_lines(f_tmp):
  File "/root/binlog2sql/binlog2sql/binlog2sql_util.py", line 249, in reversed_lines
    block = block.decode("utf-8")
```

****解决****

```
修改 binlog2sql_util.py 第249行：block = block.decode("utf-8", 'ignore')；
```





## 27. mysql5.7半同步主主集群

* 一个mysql集群共2个节点都为主节点时，这2个主节点之间不能启用`半同步slave`的功能，否则会出错，只能为异步。

* 一个mysql集群共3个节点分别为2个主节点1个从节点时，这1个从节点跟其中1个主节点可以启用`半同步slave`的功能。

---

在 MySQL 集群中，当存在 **双主架构（两个主节点）** 时，确实无法启用半同步复制功能（Semisynchronous Replication），否则可能导致数据冲突或复制链路异常。以下是具体原因和解决方案：

**原因分析**

---

1. 半同步复制的机制限制
   - 半同步复制要求主节点在提交事务前，必须等待至少一个从节点确认已接收数据
   - 在双主架构中，每个节点既是主节点又是从节点。如果双方同时启用半同步模式，会形成**相互等待**的环路，导致事务提交阻塞或超时
2. 角色冲突与数据一致性风险
   - 双主模式下，两个节点独立处理写请求，若同时开启半同步复制，可能因网络延迟或节点负载不均导致事务顺序错乱，破坏数据一致性
3. 官方限制与兼容性问题
   - MySQL 官方未对双主架构的半同步复制提供原生支持，其设计初衷是面向**一主多从**场景。强行配置可能导致复制线程崩溃或数据丢失

------

**解决方案**

1. 使用异步复制（默认模式）
   - **优点**：无阻塞问题，性能较高，适合对数据实时性要求不严格的场景
   - **缺点**：存在数据延迟或丢失风险，需通过其他机制（如心跳检测、手动切换）保障高可用性。
2. 切换为全同步复制（组复制）
   - 使用 **MySQL Group Replication**（MGR），基于 Paxos 协议实现多主数据同步，所有节点需达成一致后才提交事务
   - **适用场景**：高一致性要求的金融类业务，但牺牲部分写入性能。
3. 调整架构为一主多从
   - 若业务允许，改为单主节点 + 多个从节点，可正常启用半同步复制，平衡性能与数据安全性





### 27.1 配置半同步复制

#### 27.1.1 查看mysql插件文件

```bash
[root@g2-pro-mysql01 ~]# ls /usr/local/mysql/lib/plugin/semisync_{master,slave}.so 
/usr/local/mysql/lib/plugin/semisync_master.so  /usr/local/mysql/lib/plugin/semisync_slave.so
[root@g2-pro-mysql02 ~]# ls /usr/local/mysql/lib/plugin/semisync_{master,slave}.so 
/usr/local/mysql/lib/plugin/semisync_master.so  /usr/local/mysql/lib/plugin/semisync_slave.so
```



#### 27.1.2 查看动态加载是否为true
```sql
mysql> show variables like "have_dynamic_loading";
+----------------------+-------+
| Variable_name        | Value |
+----------------------+-------+
| have_dynamic_loading | YES   |
+----------------------+-------+
```







### 27.2 安装半同步插件

```sql
# g2-pro-mysql01安装master半同步插件
mysql> INSTALL PLUGIN rpl_semi_sync_master SONAME 'semisync_master.so'; 
# g2-pro-mysql01安装slave半同步插件
mysql> INSTALL PLUGIN rpl_semi_sync_slave SONAME 'semisync_slave.so';
# 查看插件状态
mysql> SELECT PLUGIN_NAME, PLUGIN_STATUS FROM INFORMATION_SCHEMA.PLUGINS WHERE PLUGIN_NAME LIKE '%semi%';
+----------------------+---------------+
| PLUGIN_NAME          | PLUGIN_STATUS |
+----------------------+---------------+
| rpl_semi_sync_master | ACTIVE        |
| rpl_semi_sync_slave  | ACTIVE        |
+----------------------+---------------+


# g2-pro-mysql02安装master半同步插件
mysql> INSTALL PLUGIN rpl_semi_sync_master SONAME 'semisync_master.so';
# g2-pro-mysql02安装slave半同步插件
mysql> INSTALL PLUGIN rpl_semi_sync_slave SONAME 'semisync_slave.so';
# 查看插件状态
mysql> SELECT PLUGIN_NAME, PLUGIN_STATUS FROM INFORMATION_SCHEMA.PLUGINS WHERE PLUGIN_NAME LIKE '%semi%';
+----------------------+---------------+
| PLUGIN_NAME          | PLUGIN_STATUS |
+----------------------+---------------+
| rpl_semi_sync_master | ACTIVE        |
| rpl_semi_sync_slave  | ACTIVE        |
+----------------------+---------------+
```
> 如需卸载半同步插件：
>
> ```
> UNINSTALL PLUGIN rpl_semi_sync_master;
> UNINSTALL PLUGIN rpl_semi_sync_slave;
> ```




### 27.3 开启半同步

MySQL主从集群默认是异步方式同步数据的
```sql
# g2-pro-mysql01
mysql> show status like 'Rpl_semi_sync_%_status'; 
+-----------------------------+-------+
| Variable_name               | Value |
+-----------------------------+-------+
| Rpl_semi_sync_master_status | OFF   |
| Rpl_semi_sync_slave_status  | OFF   |
+-----------------------------+-------+

# g2-pro-mysql02
mysql> show status like 'Rpl_semi_sync_%_status'; 
+-----------------------------+-------+
| Variable_name               | Value |
+-----------------------------+-------+
| Rpl_semi_sync_master_status | OFF   |
| Rpl_semi_sync_slave_status  | OFF   |
+-----------------------------+-------+


# g2-pro-mysql01和g2-pro-mysql02开启主从的半同步功能
SET GLOBAL rpl_semi_sync_master_enabled = 1;
SET GLOBAL rpl_semi_sync_slave_enabled = 1;

# 查看半同步功能是否开启，Rpl_semi_sync_slave_status未成功开启
mysql> show status like 'Rpl_semi_sync_%_status'; 
+-----------------------------+-------+
| Variable_name               | Value |
+-----------------------------+-------+
| Rpl_semi_sync_master_status | ON   |
| Rpl_semi_sync_slave_status  | OFF   |
+-----------------------------+-------+
# 原因是需要重启下slave进程
mysql> stop slave; 
mysql> start slave;
# 再次查看半同步复制功能是否开启，此时成功开启
mysql> show status like 'Rpl_semi_sync_%_status';
+-----------------------------+-------+
| Variable_name               | Value |
+-----------------------------+-------+
| Rpl_semi_sync_master_status | ON    |
| Rpl_semi_sync_slave_status  | ON    |
+-----------------------------+-------+
```



### 27.4 半同步配置优化

```sql
# 查看半同步复制状态
mysql> show status like 'Rpl_semi_sync%';
+--------------------------------------------+-------+
| Variable_name                              | Value |
+--------------------------------------------+-------+
| Rpl_semi_sync_master_clients               | 1     |
| Rpl_semi_sync_master_net_avg_wait_time     | 0     |
| Rpl_semi_sync_master_net_wait_time         | 0     |
| Rpl_semi_sync_master_net_waits             | 0     |
| Rpl_semi_sync_master_no_times              | 0     |
| Rpl_semi_sync_master_no_tx                 | 0     |
| Rpl_semi_sync_master_status                | ON    |
| Rpl_semi_sync_master_timefunc_failures     | 0     |
| Rpl_semi_sync_master_tx_avg_wait_time      | 0     |
| Rpl_semi_sync_master_tx_wait_time          | 0     |
| Rpl_semi_sync_master_tx_waits              | 0     |
| Rpl_semi_sync_master_wait_pos_backtraverse | 0     |
| Rpl_semi_sync_master_wait_sessions         | 0     |
| Rpl_semi_sync_master_yes_tx                | 0     |
| Rpl_semi_sync_slave_status                 | ON    |
+--------------------------------------------+-------+

# 查看半同步复制配置
mysql> SHOW GLOBAL VARIABLES LIKE 'rpl_semi_sync%';
+-------------------------------------------+------------+
| Variable_name                             | Value      |
+-------------------------------------------+------------+
| rpl_semi_sync_master_enabled              | ON         |
| rpl_semi_sync_master_timeout              | 10000      |
| rpl_semi_sync_master_trace_level          | 32         |
| rpl_semi_sync_master_wait_for_slave_count | 1          |
| rpl_semi_sync_master_wait_no_slave        | ON         |
| rpl_semi_sync_master_wait_point           | AFTER_SYNC |
| rpl_semi_sync_slave_enabled               | ON         |
| rpl_semi_sync_slave_trace_level           | 32         |
+-------------------------------------------+------------+
# rpl_semi_sync_master_enabled：master半同步功能是否开启
# rpl_semi_sync_slave_enabled：slave半同步功能是否开启
# rpl_semi_sync_master_timeout：master配置的半同步超时时间为10s，slave连接此master超过此值时将降级为默认的异步复制
# rpl_semi_sync_master_wait_for_slave_count：slave数量配置，用于控制主服务器在执行写操作时等待多少个slave服务器确认接收到数据。
# rpl_semi_sync_master_wait_no_slave：默认为 0，表示当没有从服务器连接时，主服务器不会等待确认，操作会立即返回。如果为1时会增加主服务器的等待时间，因为主服务器会在没有从服务器时保持等待状态。此选项在主服务器没有从服务器或在一个从服务器离线时将其关闭，值为0
# rpl_semi_sync_master_wait_point：控制主服务器在等待从服务器确认数据已接收到的时机，是在事务提交后（AFTER_SYNC，默认值）等待确认还是在事务提交前（BEFORE_SYNC）就开始等待确认。

# 可调整半同步超时时间为5s（建议）
mysql> SET GLOBAL rpl_semi_sync_master_timeout=5000;
mysql> SHOW GLOBAL VARIABLES LIKE 'rpl_semi_sync%';
+-------------------------------------------+------------+
| Variable_name                             | Value      |
+-------------------------------------------+------------+
| rpl_semi_sync_master_enabled              | ON         |
| rpl_semi_sync_master_timeout              | 5000       |
| rpl_semi_sync_master_trace_level          | 32         |
| rpl_semi_sync_master_wait_for_slave_count | 1          |
| rpl_semi_sync_master_wait_no_slave        | ON         |
| rpl_semi_sync_master_wait_point           | AFTER_SYNC |
| rpl_semi_sync_slave_enabled               | ON         |
| rpl_semi_sync_slave_trace_level           | 32         |
+-------------------------------------------+------------+
```



### 27.5 半同步测试

#### 27.5.1 测试客户端连接

```sql
# g2-pro-mysql02停止IO_THREAD
mysql> stop slave IO_THREAD for channel 'g2-mysql01-sync-to-mysql02';

# g2-pro-mysql01查看同步状态
mysql> show status like 'Rpl_semi%';
+--------------------------------------------+-------+
| Variable_name                              | Value |
+--------------------------------------------+-------+
| Rpl_semi_sync_master_clients               | 0     |
| Rpl_semi_sync_master_net_avg_wait_time     | 0     |
| Rpl_semi_sync_master_net_wait_time         | 0     |
| Rpl_semi_sync_master_net_waits             | 0     |
| Rpl_semi_sync_master_no_times              | 0     |
| Rpl_semi_sync_master_no_tx                 | 0     |
| Rpl_semi_sync_master_status                | ON    |
| Rpl_semi_sync_master_timefunc_failures     | 0     |
| Rpl_semi_sync_master_tx_avg_wait_time      | 0     |
| Rpl_semi_sync_master_tx_wait_time          | 0     |
| Rpl_semi_sync_master_tx_waits              | 0     |
| Rpl_semi_sync_master_wait_pos_backtraverse | 0     |
| Rpl_semi_sync_master_wait_sessions         | 0     |
| Rpl_semi_sync_master_yes_tx                | 0     |
| Rpl_semi_sync_slave_status                 | ON    |
+--------------------------------------------+-------+

# g2-pro-mysql02启动IO_THREAD
mysql> start slave IO_THREAD for channel 'g2-mysql01-sync-to-mysql02';

# g2-pro-mysql01查看同步状态
mysql> show status like 'Rpl_semi%';
+--------------------------------------------+-------+
| Variable_name                              | Value |
+--------------------------------------------+-------+
| Rpl_semi_sync_master_clients               | 1     |
| Rpl_semi_sync_master_net_avg_wait_time     | 0     |
| Rpl_semi_sync_master_net_wait_time         | 0     |
| Rpl_semi_sync_master_net_waits             | 0     |
| Rpl_semi_sync_master_no_times              | 0     |
| Rpl_semi_sync_master_no_tx                 | 0     |
| Rpl_semi_sync_master_status                | ON    |
| Rpl_semi_sync_master_timefunc_failures     | 0     |
| Rpl_semi_sync_master_tx_avg_wait_time      | 0     |
| Rpl_semi_sync_master_tx_wait_time          | 0     |
| Rpl_semi_sync_master_tx_waits              | 0     |
| Rpl_semi_sync_master_wait_pos_backtraverse | 0     |
| Rpl_semi_sync_master_wait_sessions         | 0     |
| Rpl_semi_sync_master_yes_tx                | 0     |
| Rpl_semi_sync_slave_status                 | ON    |
+--------------------------------------------+-------+
```



#### 27.5.2 半同步测试操作
```sql
# g2-pro-mysql01操作
mysql> create database mydb;
mysql> use mydb;
mysql> create table tb1 (id int);
# g2-pro-mysql02操作
mysql> stop slave IO_THREAD for channel 'g2-mysql01-sync-to-mysql02'; # 从服务器停止IO线程
# g2-pro-mysql01操作
mysql> create table tb2 (id int); # 主服务器半同步时间为10秒，会等待超时时间走完，而后会降级为异步
Query OK, 0 rows affected (10.01 sec)
mysql> create table tb3 (id int); # 现在为异步，不会再等待slave的IO线程了
Query OK, 0 rows affected (0.01 sec)

# g2-pro-mysql01查看半同步状态，重启mysql服务后值将归零
mysql> show status like 'Rpl_semi_sync%';
+--------------------------------------------+-------+
| Variable_name                              | Value |
+--------------------------------------------+-------+
| Rpl_semi_sync_master_clients               | 0     |
| Rpl_semi_sync_master_net_avg_wait_time     | 0     |
| Rpl_semi_sync_master_net_wait_time         | 0     |
| Rpl_semi_sync_master_net_waits             | 3     |
| Rpl_semi_sync_master_no_times              | 1     |
| Rpl_semi_sync_master_no_tx                 | 2     |
| Rpl_semi_sync_master_status                | OFF   |
| Rpl_semi_sync_master_timefunc_failures     | 0     |
| Rpl_semi_sync_master_tx_avg_wait_time      | 2427  |
| Rpl_semi_sync_master_tx_wait_time          | 4855  |
| Rpl_semi_sync_master_tx_waits              | 2     |
| Rpl_semi_sync_master_wait_pos_backtraverse | 0     |
| Rpl_semi_sync_master_wait_sessions         | 0     |
| Rpl_semi_sync_master_yes_tx                | 2     |
| Rpl_semi_sync_slave_status                 | ON    |
+--------------------------------------------+-------+
# Rpl_semi_sync_master_clients：当前连接到主服务器并参与半同步复制的客户端（从服务器）数量。
# Rpl_semi_sync_master_net_avg_wait_time：主服务器在网络中等待从服务器确认的平均时间（单位：微秒）。
# Rpl_semi_sync_master_net_wait_time：主服务器在当前状态下的总网络等待时间（单位：微秒）。
# Rpl_semi_sync_master_net_waits：主服务器等待从服务器确认的总次数。
# Rpl_semi_sync_master_no_times: 主服务器没有从服务器时的次数。
# Rpl_semi_sync_master_no_tx：主服务器在没有提交事务时发生的次数。
# Rpl_semi_sync_master_status：半同步复制在主服务器上的当前状态。
# Rpl_semi_sync_master_timefunc_failures：主服务器等待确认时遇到的时间函数错误次数（例如，超时）。
# Rpl_semi_sync_master_tx_avg_wait_time：主服务器等待从服务器确认的事务的平均时间（单位：微秒）。
# Rpl_semi_sync_master_tx_wait_time：主服务器等待从服务器确认事务的总时间（单位：微秒）。
# Rpl_semi_sync_master_tx_waits：主服务器等待从服务器确认事务的总次数。
# Rpl_semi_sync_master_wait_pos_backtraverse：主服务器回溯等待位置的次数。当主服务器在等待从服务器确认时，如果等待位置发生回退，则记录此事件。
# Rpl_semi_sync_master_wait_sessions：当前主服务器正在等待的会话数。每个等待的会话都对应着至少一个从服务器。
# Rpl_semi_sync_master_yes_tx：主服务器确认的事务次数。在这些事务中，主服务器成功接收到从服务器的确认。
# Rpl_semi_sync_slave_status：从服务器的半同步复制状态。



# g2-pro-mysql02操作
mysql> start slave IO_THREAD for channel 'g2-mysql01-sync-to-mysql02';
# g2-pro-mysql01查看半同步状态
mysql> show status like 'Rpl_semi_sync%';
+--------------------------------------------+-------+
| Variable_name                              | Value |
+--------------------------------------------+-------+
| Rpl_semi_sync_master_clients               | 1     |
| Rpl_semi_sync_master_net_avg_wait_time     | 0     |
| Rpl_semi_sync_master_net_wait_time         | 0     |
| Rpl_semi_sync_master_net_waits             | 4     |
| Rpl_semi_sync_master_no_times              | 1     |
| Rpl_semi_sync_master_no_tx                 | 2     |
| Rpl_semi_sync_master_status                | ON    |
| Rpl_semi_sync_master_timefunc_failures     | 0     |
| Rpl_semi_sync_master_tx_avg_wait_time      | 2427  |
| Rpl_semi_sync_master_tx_wait_time          | 4855  |
| Rpl_semi_sync_master_tx_waits              | 2     |
| Rpl_semi_sync_master_wait_pos_backtraverse | 0     |
| Rpl_semi_sync_master_wait_sessions         | 0     |
| Rpl_semi_sync_master_yes_tx                | 2     |
| Rpl_semi_sync_slave_status                 | ON    |
+--------------------------------------------+-------+
# g2-pro-mysql01操作
mysql> create table tb4 (id int); # 主服务器半同步时间为10秒，会等待超时时间走完，而后会降级为异步
mysql> show status like 'Rpl_semi_sync%';
+--------------------------------------------+-------+
| Variable_name                              | Value |
+--------------------------------------------+-------+
| Rpl_semi_sync_master_clients               | 1     |
| Rpl_semi_sync_master_net_avg_wait_time     | 0     |
| Rpl_semi_sync_master_net_wait_time         | 0     |
| Rpl_semi_sync_master_net_waits             | 5     |
| Rpl_semi_sync_master_no_times              | 1     |
| Rpl_semi_sync_master_no_tx                 | 2     |
| Rpl_semi_sync_master_status                | ON    |
| Rpl_semi_sync_master_timefunc_failures     | 0     |
| Rpl_semi_sync_master_tx_avg_wait_time      | 2702  |
| Rpl_semi_sync_master_tx_wait_time          | 8106  |
| Rpl_semi_sync_master_tx_waits              | 3     |
| Rpl_semi_sync_master_wait_pos_backtraverse | 0     |
| Rpl_semi_sync_master_wait_sessions         | 0     |
| Rpl_semi_sync_master_yes_tx                | 3     |
| Rpl_semi_sync_slave_status                 | ON    |
+--------------------------------------------+-------+
```





### 27.6 半同步主主集群下线主节点

半同步复制环境下主主集群下线一台主节点操作，例如下线主节点`g2-pro-mysql02`



#### 27.6.1 禁用半同步复制

```sql
# g2-pro-mysql01
mysql> SET GLOBAL rpl_semi_sync_master_enabled = 0;
mysql> SET GLOBAL rpl_semi_sync_slave_enabled = 0;
mysql> SHOW GLOBAL VARIABLES LIKE 'rpl_semi_sync%';
+-------------------------------------------+------------+
| Variable_name                             | Value      |
+-------------------------------------------+------------+
| rpl_semi_sync_master_enabled              | OFF        |
| rpl_semi_sync_master_timeout              | 10000      |
| rpl_semi_sync_master_trace_level          | 32         |
| rpl_semi_sync_master_wait_for_slave_count | 1          |
| rpl_semi_sync_master_wait_no_slave        | ON         |
| rpl_semi_sync_master_wait_point           | AFTER_SYNC |
| rpl_semi_sync_slave_enabled               | OFF        |
| rpl_semi_sync_slave_trace_level           | 32         |
+-------------------------------------------+------------+

# g2-pro-mysql02
mysql> SET GLOBAL rpl_semi_sync_master_enabled = 0;
mysql> SET GLOBAL rpl_semi_sync_slave_enabled = 0;
mysql> SHOW GLOBAL VARIABLES LIKE 'rpl_semi_sync%';
+-------------------------------------------+------------+
| Variable_name                             | Value      |
+-------------------------------------------+------------+
| rpl_semi_sync_master_enabled              | OFF        |
| rpl_semi_sync_master_timeout              | 10000      |
| rpl_semi_sync_master_trace_level          | 32         |
| rpl_semi_sync_master_wait_for_slave_count | 1          |
| rpl_semi_sync_master_wait_no_slave        | OFF        |
| rpl_semi_sync_master_wait_point           | AFTER_SYNC |
| rpl_semi_sync_slave_enabled               | OFF        |
| rpl_semi_sync_slave_trace_level           | 32         |
+-------------------------------------------+------------+
```



#### 27.6.2 检查半同步复制状态

```sql
# g2-pro-mysql01
mysql> show status like 'Rpl_semi_sync%';
+--------------------------------------------+-------+
| Variable_name                              | Value |
+--------------------------------------------+-------+
| Rpl_semi_sync_master_clients               | 0     |
| Rpl_semi_sync_master_net_avg_wait_time     | 0     |
| Rpl_semi_sync_master_net_wait_time         | 0     |
| Rpl_semi_sync_master_net_waits             | 0     |
| Rpl_semi_sync_master_no_times              | 1     |
| Rpl_semi_sync_master_no_tx                 | 0     |
| Rpl_semi_sync_master_status                | OFF   |
| Rpl_semi_sync_master_timefunc_failures     | 0     |
| Rpl_semi_sync_master_tx_avg_wait_time      | 0     |
| Rpl_semi_sync_master_tx_wait_time          | 0     |
| Rpl_semi_sync_master_tx_waits              | 0     |
| Rpl_semi_sync_master_wait_pos_backtraverse | 0     |
| Rpl_semi_sync_master_wait_sessions         | 0     |
| Rpl_semi_sync_master_yes_tx                | 0     |
| Rpl_semi_sync_slave_status                 | ON    |
+--------------------------------------------+-------+

# g2-pro-mysql02
mysql> show status like 'Rpl_semi_sync%';
+--------------------------------------------+-------+
| Variable_name                              | Value |
+--------------------------------------------+-------+
| Rpl_semi_sync_master_clients               | 1     |
| Rpl_semi_sync_master_net_avg_wait_time     | 0     |
| Rpl_semi_sync_master_net_wait_time         | 0     |
| Rpl_semi_sync_master_net_waits             | 0     |
| Rpl_semi_sync_master_no_times              | 1     |
| Rpl_semi_sync_master_no_tx                 | 0     |
| Rpl_semi_sync_master_status                | OFF   |
| Rpl_semi_sync_master_timefunc_failures     | 0     |
| Rpl_semi_sync_master_tx_avg_wait_time      | 0     |
| Rpl_semi_sync_master_tx_wait_time          | 0     |
| Rpl_semi_sync_master_tx_waits              | 0     |
| Rpl_semi_sync_master_wait_pos_backtraverse | 0     |
| Rpl_semi_sync_master_wait_sessions         | 0     |
| Rpl_semi_sync_master_yes_tx                | 0     |
| Rpl_semi_sync_slave_status                 | ON    |
+--------------------------------------------+-------+
```



#### 27.6.3 检查复制状态

在停止主节点之前，确保数据库的复制状态是健康的，即所有的数据已经同步到从节点。

##### 27.6.3 .1 在g2-pro-mysql01主节点上查看复制状态

```sql
# g2-pro-mysql01
mysql> SHOW MASTER STATUS\G
*************************** 1. row ***************************
             File: master-bin.000015
         Position: 234
     Binlog_Do_DB: 
 Binlog_Ignore_DB: 
Executed_Gtid_Set: 608bbf72-a0d4-11ef-9140-0050569c6862:1-22,
60a3d850-a0d4-11ef-b3d1-0050569c92f9:3-16

# 检查从节点的状态，确认它已经接收到最新的事务，确保 Slave_IO_Running 和 Slave_SQL_Running 都是 Yes，且没有复制延迟。
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.13.166
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000015
          Read_Master_Log_Pos: 234
               Relay_Log_File: relay-master-g2@002dmysql02@002dsync@002dto@002dmysql01.000033
                Relay_Log_Pos: 409
        Relay_Master_Log_File: master-bin.000015
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
          Exec_Master_Log_Pos: 234
              Relay_Log_Space: 863
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
             Master_Server_Id: 2
                  Master_UUID: 60a3d850-a0d4-11ef-b3d1-0050569c92f9
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: 60a3d850-a0d4-11ef-b3d1-0050569c92f9:3-16
            Executed_Gtid_Set: 608bbf72-a0d4-11ef-9140-0050569c6862:1-22,
60a3d850-a0d4-11ef-b3d1-0050569c92f9:3-16
                Auto_Position: 0
         Replicate_Rewrite_DB: 
                 Channel_Name: g2-mysql02-sync-to-mysql01
           Master_TLS_Version: 

```



##### 27.6.3 .2 在g2-pro-mysql02主节点上查看复制状态

```sql
mysql> SHOW MASTER STATUS\G
*************************** 1. row ***************************
             File: master-bin.000015
         Position: 234
     Binlog_Do_DB: 
 Binlog_Ignore_DB: 
Executed_Gtid_Set: 608bbf72-a0d4-11ef-9140-0050569c6862:3-22,
60a3d850-a0d4-11ef-b3d1-0050569c92f9:1-16
1 row in set (0.00 sec)

# 检查从节点的状态，确认它已经接收到最新的事务，确保 Slave_IO_Running 和 Slave_SQL_Running 都是 Yes，且没有复制延迟。
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.13.165
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000015
          Read_Master_Log_Pos: 234
               Relay_Log_File: relay-master-g2@002dmysql01@002dsync@002dto@002dmysql02.000034
                Relay_Log_Pos: 409
        Relay_Master_Log_File: master-bin.000015
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
          Exec_Master_Log_Pos: 234
              Relay_Log_Space: 863
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
                  Master_UUID: 608bbf72-a0d4-11ef-9140-0050569c6862
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: 608bbf72-a0d4-11ef-9140-0050569c6862:3-22
            Executed_Gtid_Set: 608bbf72-a0d4-11ef-9140-0050569c6862:3-22,
60a3d850-a0d4-11ef-b3d1-0050569c92f9:1-16
                Auto_Position: 0
         Replicate_Rewrite_DB: 
                 Channel_Name: g2-mysql01-sync-to-mysql02
           Master_TLS_Version: 
```





#### 27.6.4 主节点下线操作

##### 27.6.4.1 停止主节点

在主节点切换为异步复制模式后，您可以安全地停止该节点进行维护，不会影响到其他节点的操作。

```bash
# g2-pro-mysql02
mysql> stop slave IO_THREAD for channel 'g2-mysql01-sync-to-mysql02';
# 经过停止IO_THREAD后Rpl_semi_sync_slave_status状态变为OFF了
mysql> show status like 'Rpl_semi_sync%';
+--------------------------------------------+-------+
| Variable_name                              | Value |
+--------------------------------------------+-------+
| Rpl_semi_sync_master_clients               | 1     |
| Rpl_semi_sync_master_net_avg_wait_time     | 0     |
| Rpl_semi_sync_master_net_wait_time         | 0     |
| Rpl_semi_sync_master_net_waits             | 0     |
| Rpl_semi_sync_master_no_times              | 1     |
| Rpl_semi_sync_master_no_tx                 | 0     |
| Rpl_semi_sync_master_status                | OFF   |
| Rpl_semi_sync_master_timefunc_failures     | 0     |
| Rpl_semi_sync_master_tx_avg_wait_time      | 0     |
| Rpl_semi_sync_master_tx_wait_time          | 0     |
| Rpl_semi_sync_master_tx_waits              | 0     |
| Rpl_semi_sync_master_wait_pos_backtraverse | 0     |
| Rpl_semi_sync_master_wait_sessions         | 0     |
| Rpl_semi_sync_master_yes_tx                | 0     |
| Rpl_semi_sync_slave_status                 | OFF   |
+--------------------------------------------+-------+
mysql> SHOW GLOBAL VARIABLES LIKE 'rpl_semi_sync%';
+-------------------------------------------+------------+
| Variable_name                             | Value      |
+-------------------------------------------+------------+
| rpl_semi_sync_master_enabled              | OFF        |
| rpl_semi_sync_master_timeout              | 10000      |
| rpl_semi_sync_master_trace_level          | 32         |
| rpl_semi_sync_master_wait_for_slave_count | 1          |
| rpl_semi_sync_master_wait_no_slave        | ON         |
| rpl_semi_sync_master_wait_point           | AFTER_SYNC |
| rpl_semi_sync_slave_enabled               | OFF        |
| rpl_semi_sync_slave_trace_level           | 32         |
+-------------------------------------------+------------+
[root@g2-pro-mysql02 ~]# service mysqld stop 
Shutting down MySQL............. SUCCESS! 


# g2-pro-mysql01
mysql> create table tb5 (id int);
mysql> create table tb6 (id int);
mysql> show status like 'Rpl_semi_sync%';
+--------------------------------------------+-------+
| Variable_name                              | Value |
+--------------------------------------------+-------+
| Rpl_semi_sync_master_clients               | 0     |
| Rpl_semi_sync_master_net_avg_wait_time     | 0     |
| Rpl_semi_sync_master_net_wait_time         | 0     |
| Rpl_semi_sync_master_net_waits             | 0     |
| Rpl_semi_sync_master_no_times              | 1     |
| Rpl_semi_sync_master_no_tx                 | 0     |
| Rpl_semi_sync_master_status                | OFF   |
| Rpl_semi_sync_master_timefunc_failures     | 0     |
| Rpl_semi_sync_master_tx_avg_wait_time      | 0     |
| Rpl_semi_sync_master_tx_wait_time          | 0     |
| Rpl_semi_sync_master_tx_waits              | 0     |
| Rpl_semi_sync_master_wait_pos_backtraverse | 0     |
| Rpl_semi_sync_master_wait_sessions         | 0     |
| Rpl_semi_sync_master_yes_tx                | 0     |
| Rpl_semi_sync_slave_status                 | ON    |
+--------------------------------------------+-------+
```



##### 27.6.4.2 恢复半同步复制

###### 27.6.4.2.1 g2-pro-mysql02节点操作

`g2-pro-mysql02`维护完成后启动mysqld服务

```bash
[root@g2-pro-mysql02 ~]# service mysqld start 
```

重新启用半同步复制

```sql
mysql> SET GLOBAL rpl_semi_sync_master_enabled = 1;
mysql> SET GLOBAL rpl_semi_sync_slave_enabled = 1;
mysql> show status like 'Rpl_semi_sync%';
+--------------------------------------------+-------+
| Variable_name                              | Value |
+--------------------------------------------+-------+
| Rpl_semi_sync_master_clients               | 0     |
| Rpl_semi_sync_master_net_avg_wait_time     | 0     |
| Rpl_semi_sync_master_net_wait_time         | 0     |
| Rpl_semi_sync_master_net_waits             | 0     |
| Rpl_semi_sync_master_no_times              | 0     |
| Rpl_semi_sync_master_no_tx                 | 0     |
| Rpl_semi_sync_master_status                | ON    |
| Rpl_semi_sync_master_timefunc_failures     | 0     |
| Rpl_semi_sync_master_tx_avg_wait_time      | 0     |
| Rpl_semi_sync_master_tx_wait_time          | 0     |
| Rpl_semi_sync_master_tx_waits              | 0     |
| Rpl_semi_sync_master_wait_pos_backtraverse | 0     |
| Rpl_semi_sync_master_wait_sessions         | 0     |
| Rpl_semi_sync_master_yes_tx                | 0     |
| Rpl_semi_sync_slave_status                 | OFF   |
+--------------------------------------------+-------+
```

> `SET GLOBAL rpl_semi_sync_slave_enabled = 1;` 无法在sql命令行生效，原因是`IO_THREAD`已经停止，需要先开启`IO_THREAD`才能配置此参数。
>
> 方法一：开启`IO_THREAD`线程
>
> ```sql
> mysql> show slave status\G
> *************************** 1. row ***************************
>                Slave_IO_State: 
>                   Master_Host: 192.168.13.165
>                   Master_User: repluser
>                   Master_Port: 3306
>                 Connect_Retry: 60
>               Master_Log_File: master-bin.000016
>           Read_Master_Log_Pos: 1081
>                Relay_Log_File: relay-master-g2@002dmysql01@002dsync@002dto@002dmysql02.000046
>                 Relay_Log_Pos: 701
>         Relay_Master_Log_File: master-bin.000016
>              Slave_IO_Running: No
>             Slave_SQL_Running: Yes
>               Replicate_Do_DB: 
>           Replicate_Ignore_DB: 
>            Replicate_Do_Table: 
>        Replicate_Ignore_Table: 
>       Replicate_Wild_Do_Table: 
>   Replicate_Wild_Ignore_Table: 
>                    Last_Errno: 0
>                    Last_Error: 
>                  Skip_Counter: 0
>           Exec_Master_Log_Pos: 1081
>               Relay_Log_Space: 1879
>               Until_Condition: None
>                Until_Log_File: 
>                 Until_Log_Pos: 0
>            Master_SSL_Allowed: No
>            Master_SSL_CA_File: 
>            Master_SSL_CA_Path: 
>               Master_SSL_Cert: 
>             Master_SSL_Cipher: 
>                Master_SSL_Key: 
>         Seconds_Behind_Master: NULL
> Master_SSL_Verify_Server_Cert: No
>                 Last_IO_Errno: 0
>                 Last_IO_Error: 
>                Last_SQL_Errno: 0
>                Last_SQL_Error: 
>   Replicate_Ignore_Server_Ids: 
>              Master_Server_Id: 1
>                   Master_UUID: 608bbf72-a0d4-11ef-9140-0050569c6862
>              Master_Info_File: mysql.slave_master_info
>                     SQL_Delay: 0
>           SQL_Remaining_Delay: NULL
>       Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
>            Master_Retry_Count: 86400
>                   Master_Bind: 
>       Last_IO_Error_Timestamp: 
>      Last_SQL_Error_Timestamp: 
>                Master_SSL_Crl: 
>            Master_SSL_Crlpath: 
>            Retrieved_Gtid_Set: 608bbf72-a0d4-11ef-9140-0050569c6862:3-29
>             Executed_Gtid_Set: 608bbf72-a0d4-11ef-9140-0050569c6862:3-29,
> 60a3d850-a0d4-11ef-b3d1-0050569c92f9:1-16
>                 Auto_Position: 0
>          Replicate_Rewrite_DB: 
>                  Channel_Name: g2-mysql01-sync-to-mysql02
>            Master_TLS_Version: 
> 
> mysql> start slave IO_THREAD for channel 'g2-mysql01-sync-to-mysql02';
> mysql> show slave status\G
> *************************** 1. row ***************************
>                Slave_IO_State: Waiting for master to send event
>                   Master_Host: 192.168.13.165
>                   Master_User: repluser
>                   Master_Port: 3306
>                 Connect_Retry: 60
>               Master_Log_File: master-bin.000016
>           Read_Master_Log_Pos: 1421
>                Relay_Log_File: relay-master-g2@002dmysql01@002dsync@002dto@002dmysql02.000047
>                 Relay_Log_Pos: 701
>         Relay_Master_Log_File: master-bin.000016
>              Slave_IO_Running: Yes
>             Slave_SQL_Running: Yes
>               Replicate_Do_DB: 
>           Replicate_Ignore_DB: 
>            Replicate_Do_Table: 
>        Replicate_Ignore_Table: 
>       Replicate_Wild_Do_Table: 
>   Replicate_Wild_Ignore_Table: 
>                    Last_Errno: 0
>                    Last_Error: 
>                  Skip_Counter: 0
>           Exec_Master_Log_Pos: 1421
>               Relay_Log_Space: 1495
>               Until_Condition: None
>                Until_Log_File: 
>                 Until_Log_Pos: 0
>            Master_SSL_Allowed: No
>            Master_SSL_CA_File: 
>            Master_SSL_CA_Path: 
>               Master_SSL_Cert: 
>             Master_SSL_Cipher: 
>                Master_SSL_Key: 
>         Seconds_Behind_Master: 0
> Master_SSL_Verify_Server_Cert: No
>                 Last_IO_Errno: 0
>                 Last_IO_Error: 
>                Last_SQL_Errno: 0
>                Last_SQL_Error: 
>   Replicate_Ignore_Server_Ids: 
>              Master_Server_Id: 1
>                   Master_UUID: 608bbf72-a0d4-11ef-9140-0050569c6862
>              Master_Info_File: mysql.slave_master_info
>                     SQL_Delay: 0
>           SQL_Remaining_Delay: NULL
>       Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
>            Master_Retry_Count: 86400
>                   Master_Bind: 
>       Last_IO_Error_Timestamp: 
>      Last_SQL_Error_Timestamp: 
>                Master_SSL_Crl: 
>            Master_SSL_Crlpath: 
>            Retrieved_Gtid_Set: 608bbf72-a0d4-11ef-9140-0050569c6862:3-31
>             Executed_Gtid_Set: 608bbf72-a0d4-11ef-9140-0050569c6862:3-31,
> 60a3d850-a0d4-11ef-b3d1-0050569c92f9:1-16
>                 Auto_Position: 0
>          Replicate_Rewrite_DB: 
>                  Channel_Name: g2-mysql01-sync-to-mysql02
>            Master_TLS_Version: 
> 
> # Rpl_semi_sync_slave_status状态自动变为ON
> mysql> show status like 'Rpl_semi_sync%'; 
> +--------------------------------------------+-------+
> | Variable_name                              | Value |
> +--------------------------------------------+-------+
> | Rpl_semi_sync_master_clients               | 1     |
> | Rpl_semi_sync_master_net_avg_wait_time     | 0     |
> | Rpl_semi_sync_master_net_wait_time         | 0     |
> | Rpl_semi_sync_master_net_waits             | 3     |
> | Rpl_semi_sync_master_no_times              | 1     |
> | Rpl_semi_sync_master_no_tx                 | 2     |
> | Rpl_semi_sync_master_status                | ON    |
> | Rpl_semi_sync_master_timefunc_failures     | 0     |
> | Rpl_semi_sync_master_tx_avg_wait_time      | 1676  |
> | Rpl_semi_sync_master_tx_wait_time          | 3352  |
> | Rpl_semi_sync_master_tx_waits              | 2     |
> | Rpl_semi_sync_master_wait_pos_backtraverse | 0     |
> | Rpl_semi_sync_master_wait_sessions         | 0     |
> | Rpl_semi_sync_master_yes_tx                | 2     |
> | Rpl_semi_sync_slave_status                 | ON    |
> +--------------------------------------------+-------+
> 
> mysql> SHOW GLOBAL VARIABLES LIKE 'rpl_semi_sync%'; 
> +-------------------------------------------+------------+
> | Variable_name                             | Value      |
> +-------------------------------------------+------------+
> | rpl_semi_sync_master_enabled              | ON         |
> | rpl_semi_sync_master_timeout              | 10000      |
> | rpl_semi_sync_master_trace_level          | 32         |
> | rpl_semi_sync_master_wait_for_slave_count | 1          |
> | rpl_semi_sync_master_wait_no_slave        | ON         |
> | rpl_semi_sync_master_wait_point           | AFTER_SYNC |
> | rpl_semi_sync_slave_enabled               | ON         |
> | rpl_semi_sync_slave_trace_level           | 32         |
> +-------------------------------------------+------------+
> ```
>
> 
>
> 方法二：在/etc/my.cnf配置，并重启mysqld服务后生效
>
> ```bash
> [root@g2-pro-mysql02 ~]# cat /etc/my.cnf 
> [mysqld]
> ....
> # Rpl_semi_sync
> rpl_semi_sync_master_enabled=1
> rpl_semi_sync_slave_enabled=1
> 
> [root@g2-pro-mysql02 ~]# service mysqld restart 
> Shutting down MySQL..... SUCCESS! 
> Starting MySQL..... SUCCESS! 
> ```
>
> 以下是启用的正常状态，启动mysqld服务后需要等待1分钟左右时间才可看到Rpl_semi_sync_master_status状态变为ON
>
> ```sql
> mysql> show status like 'Rpl_semi_sync%';
> +--------------------------------------------+-------+
> | Variable_name                              | Value |
> +--------------------------------------------+-------+
> | Rpl_semi_sync_master_clients               | 0     |
> | Rpl_semi_sync_master_net_avg_wait_time     | 0     |
> | Rpl_semi_sync_master_net_wait_time         | 0     |
> | Rpl_semi_sync_master_net_waits             | 0     |
> | Rpl_semi_sync_master_no_times              | 0     |
> | Rpl_semi_sync_master_no_tx                 | 0     |
> | Rpl_semi_sync_master_status                | ON    |
> | Rpl_semi_sync_master_timefunc_failures     | 0     |
> | Rpl_semi_sync_master_tx_avg_wait_time      | 0     |
> | Rpl_semi_sync_master_tx_wait_time          | 0     |
> | Rpl_semi_sync_master_tx_waits              | 0     |
> | Rpl_semi_sync_master_wait_pos_backtraverse | 0     |
> | Rpl_semi_sync_master_wait_sessions         | 0     |
> | Rpl_semi_sync_master_yes_tx                | 0     |
> | Rpl_semi_sync_slave_status                 | ON    |
> +--------------------------------------------+-------+
> ```



###### **27.6.4.2.2 g2-pro-mysql01节点操作**

```sql
mysql> SET GLOBAL rpl_semi_sync_master_enabled = 1;
mysql> SET GLOBAL rpl_semi_sync_slave_enabled = 1;
mysql> SHOW GLOBAL VARIABLES LIKE 'rpl_semi_sync%';
+-------------------------------------------+------------+
| Variable_name                             | Value      |
+-------------------------------------------+------------+
| rpl_semi_sync_master_enabled              | ON         |
| rpl_semi_sync_master_timeout              | 10000      |
| rpl_semi_sync_master_trace_level          | 32         |
| rpl_semi_sync_master_wait_for_slave_count | 1          |
| rpl_semi_sync_master_wait_no_slave        | ON         |
| rpl_semi_sync_master_wait_point           | AFTER_SYNC |
| rpl_semi_sync_slave_enabled               | ON         |
| rpl_semi_sync_slave_trace_level           | 32         |
+-------------------------------------------+------------+

mysql> show status like 'Rpl_semi_sync%';
+--------------------------------------------+-------+
| Variable_name                              | Value |
+--------------------------------------------+-------+
| Rpl_semi_sync_master_clients               | 1     |
| Rpl_semi_sync_master_net_avg_wait_time     | 0     |
| Rpl_semi_sync_master_net_wait_time         | 0     |
| Rpl_semi_sync_master_net_waits             | 0     |
| Rpl_semi_sync_master_no_times              | 1     |
| Rpl_semi_sync_master_no_tx                 | 0     |
| Rpl_semi_sync_master_status                | ON    |
| Rpl_semi_sync_master_timefunc_failures     | 0     |
| Rpl_semi_sync_master_tx_avg_wait_time      | 0     |
| Rpl_semi_sync_master_tx_wait_time          | 0     |
| Rpl_semi_sync_master_tx_waits              | 0     |
| Rpl_semi_sync_master_wait_pos_backtraverse | 0     |
| Rpl_semi_sync_master_wait_sessions         | 0     |
| Rpl_semi_sync_master_yes_tx                | 0     |
| Rpl_semi_sync_slave_status                 | ON    |
+--------------------------------------------+-------+
```





#### 27.7 检查半同步复制状态
```sql
mysql> show master status\G
*************************** 1. row ***************************
             File: master-bin.000018
         Position: 234
     Binlog_Do_DB: 
 Binlog_Ignore_DB: 
Executed_Gtid_Set: 608bbf72-a0d4-11ef-9140-0050569c6862:3-24,
60a3d850-a0d4-11ef-b3d1-0050569c92f9:1-16

mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.13.165
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000015
          Read_Master_Log_Pos: 572
               Relay_Log_File: relay-master-g2@002dmysql01@002dsync@002dto@002dmysql02.000040
                Relay_Log_Pos: 361
        Relay_Master_Log_File: master-bin.000015
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
          Exec_Master_Log_Pos: 572
              Relay_Log_Space: 1032
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
                  Master_UUID: 608bbf72-a0d4-11ef-9140-0050569c6862
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: 608bbf72-a0d4-11ef-9140-0050569c6862:3-24
            Executed_Gtid_Set: 608bbf72-a0d4-11ef-9140-0050569c6862:3-24,
60a3d850-a0d4-11ef-b3d1-0050569c92f9:1-16
                Auto_Position: 0
         Replicate_Rewrite_DB: 
                 Channel_Name: g2-mysql01-sync-to-mysql02
           Master_TLS_Version: 
```



#### 27.8 切回主主复制
当主节点`g2-pro-mysql02`恢复并且所有数据同步后，您可以恢复正常的主主复制模式（例如调整mysql的流量到2台主节点之上，实现slb，可通过mycat读写分离中间件、四层负载均衡等方式），两个主节点将继续互相同步数据。



#### 27.9 备选方案

除了主主复制和半同步复制外，还可以考虑使用 MySQL Group Replication，这是一个更为现代的解决方案，它提供了更高的自动化、数据一致性和故障恢复能力。
1. MySQL Group Replication：它支持自动故障转移，能够处理节点之间的复制冲突，并且能够在节点故障时自动恢复。

2. MHA（MySQL High Availability）：MHA 是一个 MySQL 高可用性工具，支持自动故障转移，避免了手动干预。







## 28. mysql集群迁移至新集群

**目的：**
从source_mysql_master节点迁移数据库到`新mysql集群`



### 28.1 环境

ip: 172.168.2.17  	role: source_mysql_master	config: enable gtid		domain_name: mysql.hs.com
ip: 172.168.2.18	role: new_mysql_master01	config: enable gtid
ip: 172.168.2.19	role: new_mysql_master02	config: enable gtid

> 1. 确保所有节点server_id不同、gtid开启、多级复制开启。
> 2. 除开第1点和个性化配置外，确保所有节点配置一样。



### 28.2 备份172.168.2.17数据库
```bash
# 172.168.2.17上备份数据库
[root@source ~]# mysqldump -uroot -p --all-databases --triggers --routines --events --set-gtid-purged=OFF --flush-logs --master-data=2 --single-transaction > alldatabases-`date +'%Y%m%d%H%M%S'`.sql
Enter password:
# 复制备份数据到172.168.2.18
[root@source ~]# scp alldatabases-20241212145939.sql root@172.168.2.18:/root/alldatabases-20241212145939-172.168.2.17.sql
```



### 28.3 在172.168.2.18上恢复数据库
```bash
mysql> set session sql_log_bin=0;
mysql> source /root/alldatabases-20241212145939-172.168.2.17.sql;
mysql> set session sql_log_bin=1;
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test               |
+--------------------+
mysql> show master status;
+-------------------+----------+--------------+------------------+-------------------+
| File              | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+-------------------+----------+--------------+------------------+-------------------+
| master-bin.000001 |      154 |              |                  |                   |
+-------------------+----------+--------------+------------------+-------------------+

[root@master ~]# service mysqld restart
Shutting down MySQL.... SUCCESS!
Starting MySQL. SUCCESS!
```



### 28.4 备份172.168.2.18数据库
此步骤假设172.168.2.18数据库太大，例如达到10G以上，则需要使用此备份步骤，否则在172.168.2.19上可直接使用`chang master`命令

```bash
[root@master ~]# mysqldump -uroot -p --all-databases --triggers --routines --events --set-gtid-purged=OFF --flush-logs --master-data=2 --single-transaction > alldatabases-`date +'%Y%m%d%H%M%S'`.sql
Enter password:
[root@master ~]# scp alldatabases-20241212150856.sql root@172.168.2.19:/root/alldatabases-20241212150856-172.168.2.18.sql
```



### 28.5 在172.168.2.19上恢复数据库
```bash
mysql> set session sql_log_bin=0;
mysql> source /root/alldatabases-20241212150856-172.168.2.18.sql;
mysql> set session sql_log_bin=1;
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test               |
+--------------------+
mysql> show master status;
+-------------------+----------+--------------+------------------+-------------------+
| File              | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+-------------------+----------+--------------+------------------+-------------------+
| master-bin.000001 |      154 |              |                  |                   |
+-------------------+----------+--------------+------------------+-------------------+

[root@slave1 ~]# service mysqld restart
Shutting down MySQL.... SUCCESS!
Starting MySQL. SUCCESS!
```



### 28.6 配置172.168.2.18的主为172.168.2.17

在172.168.2.17上配置mysql集群用户
```sql
mysql> grant replication slave on *.* to repluser@'172.168.2.%' identified by 'test';
```

配置172.168.2.18
```bash
[root@master ~]# head -n 100 /root/alldatabases-20241212145939-172.168.2.17.sql | grep -i 'change master'
-- CHANGE MASTER TO MASTER_LOG_FILE='master-bin.000002', MASTER_LOG_POS=154;
```
```sql
mysql> change master to master_host='172.168.2.17',master_port=3306,master_user='repluser',master_password='test',master_log_file='master-bin.000002',MASTER_LOG_POS=154 for channel 'channel_17';
mysql> show binary logs;
+-------------------+-----------+
| Log_name          | File_size |
+-------------------+-----------+
| master-bin.000001 |       177 |
| master-bin.000002 |       202 |
| master-bin.000003 |       154 |
+-------------------+-----------+
mysql> start slave for channel 'channel_17';
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 172.168.2.17
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000002
          Read_Master_Log_Pos: 456
               Relay_Log_File: relay-master-channel_17.000002
                Relay_Log_Pos: 623
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
          Exec_Master_Log_Pos: 456
              Relay_Log_Space: 838
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
             Master_Server_Id: 17
                  Master_UUID: d2639a01-b7b7-11ef-be27-000c298c385b
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp:
               Master_SSL_Crl:
           Master_SSL_Crlpath:
           Retrieved_Gtid_Set: d2639a01-b7b7-11ef-be27-000c298c385b:1
            Executed_Gtid_Set: d2639a01-b7b7-11ef-be27-000c298c385b:1
                Auto_Position: 0
         Replicate_Rewrite_DB:
                 Channel_Name: channel_17
           Master_TLS_Version:
mysql> show binary logs;
+-------------------+-----------+
| Log_name          | File_size |
+-------------------+-----------+
| master-bin.000001 |       177 |
| master-bin.000002 |       202 |
| master-bin.000003 |       456 |
+-------------------+-----------+
```



**查看172.168.2.17和172.168.2.18的同步方式**

```sql
# 172.168.2.17
mysql> show status like 'Rpl_semi_sync_%_status';
Empty set (0.01 sec)

# 172.168.2.18
mysql> show status like 'Rpl_semi_sync_%_status';
Empty set (0.00 sec)
```
> 从上面结果中可以看出来，并没有半同步设置，所以默认是异步复制的。





### 28.7 配置172.168.2.18和172.168.2.19互为主主

#### 28.7.1 配置172.168.2.19的主为172.168.2.18

**配置172.168.2.19**

```bash
[root@slave1 ~]# head -n 100 /root/alldatabases-20241212150856-172.168.2.18.sql | grep -i 'change master'
-- CHANGE MASTER TO MASTER_LOG_FILE='master-bin.000003', MASTER_LOG_POS=154;
```
```sql
mysql> change master to master_host='172.168.2.18',master_port=3306,master_user='repluser',master_password='test',master_log_file='master-bin.000003',MASTER_LOG_POS=154 for channel 'channel_18';
mysql> start slave;
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 172.168.2.18
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000003
          Read_Master_Log_Pos: 456
               Relay_Log_File: relay-master-channel_18.000002
                Relay_Log_Pos: 623
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
          Exec_Master_Log_Pos: 456
              Relay_Log_Space: 838
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
             Master_Server_Id: 18
                  Master_UUID: 6a46703e-0798-11ee-af59-000c29c7acb7
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp:
               Master_SSL_Crl:
           Master_SSL_Crlpath:
           Retrieved_Gtid_Set: d2639a01-b7b7-11ef-be27-000c298c385b:1
            Executed_Gtid_Set: d2639a01-b7b7-11ef-be27-000c298c385b:1
                Auto_Position: 0
         Replicate_Rewrite_DB:
                 Channel_Name: channel_18
           Master_TLS_Version:
mysql> show binary logs;
+-------------------+-----------+
| Log_name          | File_size |
+-------------------+-----------+
| master-bin.000001 |       177 |
| master-bin.000002 |       456 |
+-------------------+-----------+
mysql> select * from t3;
+------+
| id   |
+------+
|    1 |
|    2 |
|    1 |
|    2 |
|    1 |
|    2 |
|    3 |
|    4 |
|    3 |
|    4 |
|    5 |
|    6 |
|    7 |
|    8 |
|    9 |
|    9 |
|   10 |
|   13 |
+------+
mysql> show master status;
+-------------------+----------+--------------+------------------+----------------------------------------+
| File              | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set                      |
+-------------------+----------+--------------+------------------+----------------------------------------+
| master-bin.000002 |      456 |              |                  | d2639a01-b7b7-11ef-be27-000c298c385b:1 |
+-------------------+----------+--------------+------------------+----------------------------------------+
```



#### 28.7.2 测试172.168.2.17插入数据
```sql
# 操作172.168.2.17
mysql> show create table test.t3\G
*************************** 1. row ***************************
       Table: t3
Create Table: CREATE TABLE `t3` (
  `id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4

mysql> delete from t3 where id not in (13);
mysql> insert into t3 values (14);
mysql> select * from t3;
+------+
| id   |
+------+
|   13 |
|   14 |
+------+
mysql> show master status\G
*************************** 1. row ***************************
             File: master-bin.000002
         Position: 1052
     Binlog_Do_DB:
 Binlog_Ignore_DB:
Executed_Gtid_Set: d2639a01-b7b7-11ef-be27-000c298c385b:1-3

# 操作172.168.2.18
mysql> select * from t3;
+------+
| id   |
+------+
|   13 |
|   14 |
+------+
mysql> show master status\G
*************************** 1. row ***************************
             File: master-bin.000003
         Position: 1034
     Binlog_Do_DB:
 Binlog_Ignore_DB:
Executed_Gtid_Set: d2639a01-b7b7-11ef-be27-000c298c385b:1-3


# 操作172.168.2.19
mysql> select * from t3;
+------+
| id   |
+------+
|   13 |
|   14 |
+------+
mysql> show master status\G
*************************** 1. row ***************************
             File: master-bin.000002
         Position: 1034
     Binlog_Do_DB:
 Binlog_Ignore_DB:
Executed_Gtid_Set: d2639a01-b7b7-11ef-be27-000c298c385b:1-3
```



#### 28.7.3 将生产域名解析指向172.168.2.18

配置域名mysql.hs.com -> 172.168.2.18
> 1. 需要观察172.168.2.18同步172.168.17的情况，等待2个节点同步position到最新状态(不能存在大量sql未同步)时才能切换域名指向
> 2. 此时应用连接的是新的主机172.168.2.18
> 3. 观察应用是否连接正常，如若不正常则需要回滚（回滚则是将172.168.2.17的主指向172.168.2.18），回滚sql如下：
> ```sql
> mysql> change master to master_host='172.168.2.18',master_port=3306,master_user='repluser',master_password='test',master_log_file='master-bin.000002',MASTER_LOG_POS=1034 for channel 'channel_18';
> ```
> 等待2个节点同步position到最新状态(不能存在大量sql未同步)时才能切换域名指向回`172.168.2.17`
> 4. 如若正常则继续以下步骤



#### 28.7.4 配置172.168.2.18的主为172.168.2.19
这里选择172.168.2.19的master文件和position为master_log_file='master-bin.000002',MASTER_LOG_POS=456
> 为什么不是master_log_file='master-bin.000002',MASTER_LOG_POS=1034?
> 因为真实环境中，binlog是在不断的增长的，所以你无法确定最新的position，可以选取最近的postion即可，slave线程会重新应用binlog，你可能会担心数据会重复执行两遍，经过多次测试，不会存在重复执行，因为有GTID 来标记已经执行的操作，以便在执行时进行冲突检测和处理，可参考`17.4 什么是GTID`
```sql
mysql> change master to master_host='172.168.2.19',master_port=3306,master_user='repluser',master_password='test',master_log_file='master-bin.000002',MASTER_LOG_POS=154 for channel 'channel_19';
mysql> start slave;
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 172.168.2.17
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000002
          Read_Master_Log_Pos: 1052
               Relay_Log_File: relay-master-channel_17.000002
                Relay_Log_Pos: 1219
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
          Exec_Master_Log_Pos: 1052
              Relay_Log_Space: 1434
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
             Master_Server_Id: 17
                  Master_UUID: d2639a01-b7b7-11ef-be27-000c298c385b
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp:
               Master_SSL_Crl:
           Master_SSL_Crlpath:
           Retrieved_Gtid_Set: d2639a01-b7b7-11ef-be27-000c298c385b:1-3
            Executed_Gtid_Set: d2639a01-b7b7-11ef-be27-000c298c385b:1-3
                Auto_Position: 0
         Replicate_Rewrite_DB:
                 Channel_Name: channel_17
           Master_TLS_Version:
*************************** 2. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 172.168.2.19
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000002
          Read_Master_Log_Pos: 1034
               Relay_Log_File: relay-master-channel_19.000002
                Relay_Log_Pos: 1201
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
          Exec_Master_Log_Pos: 1034
              Relay_Log_Space: 1416
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
             Master_Server_Id: 19
                  Master_UUID: 6a3dda9b-0798-11ee-89f5-000c29089177
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp:
               Master_SSL_Crl:
           Master_SSL_Crlpath:
           Retrieved_Gtid_Set: d2639a01-b7b7-11ef-be27-000c298c385b:1-3
            Executed_Gtid_Set: d2639a01-b7b7-11ef-be27-000c298c385b:1-3
                Auto_Position: 0
         Replicate_Rewrite_DB:
                 Channel_Name: channel_19
           Master_TLS_Version:
```



**测试**
172.168.2.17(主) -> 172.168.2.18(从)
172.168.2.18(主) -> 172.168.2.19(主)

```sql
## 第一次
# 172.168.2.19 
mysql> insert into t3 values(15);
mysql> select * from t3;
+------+
| id   |
+------+
|   13 |
|   14 |
|   15 |
+------+

# 172.168.2.18
mysql> select * from t3;
+------+
| id   |
+------+
|   13 |
|   14 |
|   15 |
+------+

# 172.168.2.17
mysql> select * from t3;
+------+
| id   |
+------+
|   13 |
|   14 |
+------+


## 第二次
# 172.168.2.18
mysql> insert into t3 values (16);
mysql> select * from t3;
+------+
| id   |
+------+
|   13 |
|   14 |
|   15 |
|   16 |
+------+

# 172.168.2.19
mysql> select * from t3;
+------+
| id   |
+------+
|   13 |
|   14 |
|   15 |
|   16 |
+------+

# 172.168.2.17
mysql> select * from t3;
+------+
| id   |
+------+
|   13 |
|   14 |
+------+


## 第三次
# 172.168.2.17
mysql> insert into t3 values (16);
mysql> select * from t3;
+------+
| id   |
+------+
|   13 |
|   14 |
|   16 |
+------+

# 172.168.2.18
mysql> select * from t3;
+------+
| id   |
+------+
|   13 |
|   14 |
|   15 |
|   16 |
|   16 |
+------+

# 172.168.2.19
mysql> select * from t3;
+------+
| id   |
+------+
|   13 |
|   14 |
|   15 |
|   16 |
|   16 |
+------+
```



#### 28.7.5 在172.168.2.18上去除172.168.2.17主的配置
```sql
mysql> stop slave for channel 'channel_17';
mysql> reset slave all for channel 'channel_17';
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 172.168.2.19
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000002
          Read_Master_Log_Pos: 1780
               Relay_Log_File: relay-master-channel_19.000002
                Relay_Log_Pos: 1703
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
          Exec_Master_Log_Pos: 1780
              Relay_Log_Space: 1918
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
             Master_Server_Id: 19
                  Master_UUID: 6a3dda9b-0798-11ee-89f5-000c29089177
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp:
               Master_SSL_Crl:
           Master_SSL_Crlpath:
           Retrieved_Gtid_Set: 6a3dda9b-0798-11ee-89f5-000c29089177:1,
d2639a01-b7b7-11ef-be27-000c298c385b:1-4
            Executed_Gtid_Set: 6a3dda9b-0798-11ee-89f5-000c29089177:1,
6a46703e-0798-11ee-af59-000c29c7acb7:1,
d2639a01-b7b7-11ef-be27-000c298c385b:1-4
                Auto_Position: 0
         Replicate_Rewrite_DB:
                 Channel_Name: channel_19
           Master_TLS_Version:
```



#### 28.7.6 在172.168.2.18和172.168.2.19开启半同步复制
##### 28.7.6.1 安装半同步插件
```sql
# 172.168.2.18
mysql> show variables like "have_dynamic_loading";
+----------------------+-------+
| Variable_name        | Value |
+----------------------+-------+
| have_dynamic_loading | YES   |
+----------------------+-------+
mysql> INSTALL PLUGIN rpl_semi_sync_master SONAME 'semisync_master.so'; 
mysql> INSTALL PLUGIN rpl_semi_sync_slave SONAME 'semisync_slave.so';
mysql> SELECT PLUGIN_NAME, PLUGIN_STATUS FROM INFORMATION_SCHEMA.PLUGINS WHERE PLUGIN_NAME LIKE '%semi%';
+----------------------+---------------+
| PLUGIN_NAME          | PLUGIN_STATUS |
+----------------------+---------------+
| rpl_semi_sync_master | ACTIVE        |
| rpl_semi_sync_slave  | ACTIVE        |
+----------------------+---------------+

# 172.168.2.19
mysql> show variables like "have_dynamic_loading";
+----------------------+-------+
| Variable_name        | Value |
+----------------------+-------+
| have_dynamic_loading | YES   |
+----------------------+-------+
mysql> INSTALL PLUGIN rpl_semi_sync_master SONAME 'semisync_master.so'; 
mysql> INSTALL PLUGIN rpl_semi_sync_slave SONAME 'semisync_slave.so';
mysql> SELECT PLUGIN_NAME, PLUGIN_STATUS FROM INFORMATION_SCHEMA.PLUGINS WHERE PLUGIN_NAME LIKE '%semi%';
+----------------------+---------------+
| PLUGIN_NAME          | PLUGIN_STATUS |
+----------------------+---------------+
| rpl_semi_sync_master | ACTIVE        |
| rpl_semi_sync_slave  | ACTIVE        |
+----------------------+---------------+
```



##### 28.7.6.2 开启半同步功能
```sql
# 172.168.2.18
mysql> show status like 'Rpl_semi_sync%';
+--------------------------------------------+-------+
| Variable_name                              | Value |
+--------------------------------------------+-------+
| Rpl_semi_sync_master_clients               | 0     |
| Rpl_semi_sync_master_net_avg_wait_time     | 0     |
| Rpl_semi_sync_master_net_wait_time         | 0     |
| Rpl_semi_sync_master_net_waits             | 0     |
| Rpl_semi_sync_master_no_times              | 0     |
| Rpl_semi_sync_master_no_tx                 | 0     |
| Rpl_semi_sync_master_status                | OFF   |
| Rpl_semi_sync_master_timefunc_failures     | 0     |
| Rpl_semi_sync_master_tx_avg_wait_time      | 0     |
| Rpl_semi_sync_master_tx_wait_time          | 0     |
| Rpl_semi_sync_master_tx_waits              | 0     |
| Rpl_semi_sync_master_wait_pos_backtraverse | 0     |
| Rpl_semi_sync_master_wait_sessions         | 0     |
| Rpl_semi_sync_master_yes_tx                | 0     |
| Rpl_semi_sync_slave_status                 | OFF   |
+--------------------------------------------+-------+
mysql> SET GLOBAL rpl_semi_sync_master_enabled = 1;
mysql> SET GLOBAL rpl_semi_sync_slave_enabled = 1;
mysql> SHOW GLOBAL VARIABLES LIKE 'rpl_semi_sync_%_enabled';
+------------------------------+-------+
| Variable_name                | Value |
+------------------------------+-------+
| rpl_semi_sync_master_enabled | ON    |
| rpl_semi_sync_slave_enabled  | ON    |
+------------------------------+-------+
mysql> show status like 'Rpl_semi_sync%';
+--------------------------------------------+-------+
| Variable_name                              | Value |
+--------------------------------------------+-------+
| Rpl_semi_sync_master_clients               | 0     |
| Rpl_semi_sync_master_net_avg_wait_time     | 0     |
| Rpl_semi_sync_master_net_wait_time         | 0     |
| Rpl_semi_sync_master_net_waits             | 0     |
| Rpl_semi_sync_master_no_times              | 0     |
| Rpl_semi_sync_master_no_tx                 | 0     |
| Rpl_semi_sync_master_status                | ON    |
| Rpl_semi_sync_master_timefunc_failures     | 0     |
| Rpl_semi_sync_master_tx_avg_wait_time      | 0     |
| Rpl_semi_sync_master_tx_wait_time          | 0     |
| Rpl_semi_sync_master_tx_waits              | 0     |
| Rpl_semi_sync_master_wait_pos_backtraverse | 0     |
| Rpl_semi_sync_master_wait_sessions         | 0     |
| Rpl_semi_sync_master_yes_tx                | 0     |
| Rpl_semi_sync_slave_status                 | OFF   |
+--------------------------------------------+-------+

# 172.168.2.19
mysql> SET GLOBAL rpl_semi_sync_master_enabled = 1;
mysql> SET GLOBAL rpl_semi_sync_slave_enabled = 1;
mysql> SHOW GLOBAL VARIABLES LIKE 'rpl_semi_sync_%_enabled';
+------------------------------+-------+
| Variable_name                | Value |
+------------------------------+-------+
| rpl_semi_sync_master_enabled | ON    |
| rpl_semi_sync_slave_enabled  | ON    |
+------------------------------+-------+
mysql> show status like 'Rpl_semi_sync%';
+--------------------------------------------+-------+
| Variable_name                              | Value |
+--------------------------------------------+-------+
| Rpl_semi_sync_master_clients               | 0     |
| Rpl_semi_sync_master_net_avg_wait_time     | 0     |
| Rpl_semi_sync_master_net_wait_time         | 0     |
| Rpl_semi_sync_master_net_waits             | 0     |
| Rpl_semi_sync_master_no_times              | 0     |
| Rpl_semi_sync_master_no_tx                 | 0     |
| Rpl_semi_sync_master_status                | ON    |
| Rpl_semi_sync_master_timefunc_failures     | 0     |
| Rpl_semi_sync_master_tx_avg_wait_time      | 0     |
| Rpl_semi_sync_master_tx_wait_time          | 0     |
| Rpl_semi_sync_master_tx_waits              | 0     |
| Rpl_semi_sync_master_wait_pos_backtraverse | 0     |
| Rpl_semi_sync_master_wait_sessions         | 0     |
| Rpl_semi_sync_master_yes_tx                | 0     |
| Rpl_semi_sync_slave_status                 | OFF   |
+--------------------------------------------+-------+
```



##### 28.7.6.3 配置半同步超时时间
```sql
# 172.168.2.18
mysql> SET GLOBAL rpl_semi_sync_master_timeout=5000;
mysql> SHOW GLOBAL VARIABLES LIKE 'rpl_semi_sync_master_timeout';
+------------------------------+-------+
| Variable_name                | Value |
+------------------------------+-------+
| rpl_semi_sync_master_timeout | 5000  |
+------------------------------+-------+

# 172.168.2.19
mysql> SET GLOBAL rpl_semi_sync_master_timeout=5000;
mysql> SHOW GLOBAL VARIABLES LIKE 'rpl_semi_sync_master_timeout';
+------------------------------+-------+
| Variable_name                | Value |
+------------------------------+-------+
| rpl_semi_sync_master_timeout | 5000  |
+------------------------------+-------+
```



##### 7.6.4 应用半同步复制
**先应用172.168.2.18的slave功能**，成功后172.168.2.18将和172.168.2.19进行半同步复制。

如果异常，也只导致172.168.2.19的写有延迟，不会影响已经投入生产使用的域名mysql.hs.com的使用

```sql
# 172.168.2.18
mysql> stop slave for channel 'channel_19';
mysql> start slave for channel 'channel_19';
# 此时172.168.2.18的Rpl_semi_sync_slave_status状态为ON，表示跟172.168.2.19的半同步复制已经正常工作
mysql> show status like 'Rpl_semi_sync%';
+--------------------------------------------+-------+
| Variable_name                              | Value |
+--------------------------------------------+-------+
| Rpl_semi_sync_master_clients               | 0     |
| Rpl_semi_sync_master_net_avg_wait_time     | 0     |
| Rpl_semi_sync_master_net_wait_time         | 0     |
| Rpl_semi_sync_master_net_waits             | 0     |
| Rpl_semi_sync_master_no_times              | 0     |
| Rpl_semi_sync_master_no_tx                 | 0     |
| Rpl_semi_sync_master_status                | ON    |
| Rpl_semi_sync_master_timefunc_failures     | 0     |
| Rpl_semi_sync_master_tx_avg_wait_time      | 0     |
| Rpl_semi_sync_master_tx_wait_time          | 0     |
| Rpl_semi_sync_master_tx_waits              | 0     |
| Rpl_semi_sync_master_wait_pos_backtraverse | 0     |
| Rpl_semi_sync_master_wait_sessions         | 0     |
| Rpl_semi_sync_master_yes_tx                | 0     |
| Rpl_semi_sync_slave_status                 | ON    |
+--------------------------------------------+-------+


# 在172.168.2.19进行数据插入测试，在半同步复制模式下，插入时间为0.01秒
mysql> insert into t3 values (17);
Query OK, 1 row affected (0.01 sec)

mysql> select * from t3;
+------+
| id   |
+------+
|   13 |
|   14 |
|   15 |
|   16 |
|   16 |
|   17 |
+------+


# 在172.168.2.18上查询
mysql> select * from t3;
+------+
| id   |
+------+
|   13 |
|   14 |
|   15 |
|   16 |
|   16 |
|   17 |
+------+
```



**应用172.168.2.19的slave功能**

```sql
# 172.168.2.19
mysql> stop slave for channel 'channel_18';
mysql> start slave for channel 'channel_18';
# 此时172.168.2.19的Rpl_semi_sync_slave_status状态为ON，表示跟172.168.2.18的半同步复制已经正常工作
mysql> show status like 'Rpl_semi_sync%';
+--------------------------------------------+-------+
| Variable_name                              | Value |
+--------------------------------------------+-------+
| Rpl_semi_sync_master_clients               | 1     |
| Rpl_semi_sync_master_net_avg_wait_time     | 0     |
| Rpl_semi_sync_master_net_wait_time         | 0     |
| Rpl_semi_sync_master_net_waits             | 1     |
| Rpl_semi_sync_master_no_times              | 0     |
| Rpl_semi_sync_master_no_tx                 | 0     |
| Rpl_semi_sync_master_status                | ON    |
| Rpl_semi_sync_master_timefunc_failures     | 0     |
| Rpl_semi_sync_master_tx_avg_wait_time      | 5456  |
| Rpl_semi_sync_master_tx_wait_time          | 5456  |
| Rpl_semi_sync_master_tx_waits              | 1     |
| Rpl_semi_sync_master_wait_pos_backtraverse | 0     |
| Rpl_semi_sync_master_wait_sessions         | 0     |
| Rpl_semi_sync_master_yes_tx                | 1     |
| Rpl_semi_sync_slave_status                 | ON    |
+--------------------------------------------+-------+


# 在172.168.2.18进行数据插入测试，在半同步复制模式下，插入时间为0.01秒
mysql> insert into t3 values(18);
Query OK, 1 row affected (0.01 sec)

mysql> select * from t3;
+------+
| id   |
+------+
|   13 |
|   14 |
|   15 |
|   16 |
|   16 |
|   17 |
|   18 |
+------+

# 在172.168.2.19上查询
mysql> select * from t3;
+------+
| id   |
+------+
|   13 |
|   14 |
|   15 |
|   16 |
|   16 |
|   17 |
|   18 |
+------+
```













## 笔记

### 1. mysql性能优化
```
MySQL内存消耗过高分析与处理
   MySQL的内存消耗分为：
       1.会话级别的内存消耗：如sort_buffer_size等，每个会话都会开辟一个sort_buffer_size来进行排序操作
       2.全局的内存消耗：例如：innodb_buffer_pool_size等，全局共享的内存段
   其中170的数据库的全局内存消耗很稳定，没有出现增加的现象，那么会话级的内存消耗可能是一个主因。

关于会话级的内存消耗解释如下：
read_buffer_size, sort_buffer_size, read_rnd_buffer_size, tmp_table_size这些参数在需要的时候才分配，操作后释放。
这些会话级的内存，不管使用多少都分配该size的值，即使实际需要远远小于这些size。
每个线程可能会不止一次需要分配buffer，例如子查询，每层都需要有自己的read_buffer,sort_buffer, tmp_table_size 等
找到每次内存消耗峰值是不切实际的，因此我的这些建议可以用来衡量一下你实际修改一些变量值产生的反应,例如把 sort_buffer_size 从1MB增加到4MB并且在 max_connections 为 1000 的情况下，内存消耗增长峰值并不是你所计算的3000MB而是30MB。
mysql内存计算器：
http://www.mysqlcalculator.com/

参数调优：
1.max_connections=2000   ----最大并发连接数，自己一般最大3000，需要设置
mysql> show global variables like "%max_connection%";
+-----------------+-------+
| Variable_name   | Value |
+-----------------+-------+
| max_connections | 2000  |
+-----------------+-------+
mysql> show global status like "%max_used_conn%";   ----已经连接最大并发数量，可用于看是否要调整最大并发连接数
+---------------------------+---------------------+
| Variable_name             | Value               |
+---------------------------+---------------------+
| Max_used_connections      | 46                  |

2.back_log=80  ----一般不设置
mysql> show global variables like "%back_log%"; ----查看最大并发连接数连接满时，还可以有多少外连接放在堆栈中等待连接释放
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| back_log      | 80    |

3.wait_timeout=3600  ----连接进来客户端空闲1小时后自动断开这个连接 

4.interactive_timeout=28800   ----连接客户端不管是在活动还是在非活动，到达这个值后就会断开这个连接

5.key_buffer_size=8388608
mysql> show global variables like "%key_buffer_size%";  ----myisam表的索引缓冲区和临时表的缓冲区大小
+-----------------+---------+
| Variable_name   | Value   |
+-----------------+---------+
| key_buffer_size | 8388608 |
+-----------------+---------+
mysql> show global status like "%created_tmp%";
+-------------------------+-----------+
| Variable_name           | Value     |
+-------------------------+-----------+
| Created_tmp_disk_tables | 20695306  |    ----Created_tmp_tables/(Created_tmp_tables+Created_tmp_disk_tables)=90%以上越好，代表90%以上在内存中
| Created_tmp_tables      | 202292618 |       ----Created_tmp_disk_tables/(Created_tmp_tables+Created_tmp_disk_tables)=5%到10%以内越好，代表5%到10%以内在内存中

6.max_allowed_packet=4194304  ---默认4M     
mysql> show global variables like "%max_allow%";   ----server接收的数据包大小
+--------------------------+------------+
| Variable_name            | Value      |
+--------------------------+------------+
| max_allowed_packet       | 4194304    |

7.thread_cache_size=9  ----服务器线程缓存大小，用内存空间换cpu的性能
mysql> show global variables like "%thread_cache_size%";
+-------------------+-------+
| Variable_name     | Value |
+-------------------+-------+
| thread_cache_size | 9     |

8.innodb_buffer_pool_size=2G  ----很重要
mysql> show global variables like "%innodb_buffer_pool_size%";
+-------------------------+------------+
| Variable_name           | Value      |
+-------------------------+------------+
| innodb_buffer_pool_size | 2147483648 |
+-------------------------+------------+
mysql> show engine innodb status\G
----------------------
BUFFER POOL AND MEMORY
----------------------
Total large memory allocated 2198863872
Dictionary memory allocated 788831
Buffer pool size   131056
Free buffers       112340
Database pages     18700   --pool size=18700*16k=292M

9.innodb_flush_log_at_trx_commit=1  ----提交事务写入磁盘方式，每次提交事务就写入磁盘
mysql> show global variables like "%commit%";
| innodb_flush_log_at_trx_commit          | 1     |

10.innodb-thread-concurrency=16  ----当用户连接大时，设定线程并发数，先设置cpu核心数，然后观察cpu使用情况平不平均，平均即可，如若不平均把此值增加一倍，如此规则调到最后使用情况平均即可。此值不是很重要
mysql> show global variables like "%concurrency%";
| innodb_thread_concurrency  | 16    |

11.innodb_log_buffer_size=32M  ----redo log大小，从内存脏页写入到硬盘，事务量大的话则可以增大此区域内存大小，减小IO次数，此设置重要
mysql> show global variables like "%innodb%log%size%";
| innodb_log_buffer_size           | 16777216   |
mysql> show global status like "%commit%"; ----如果事务量大，则可以增加
+----------------+-------+
| Variable_name  | Value |
+----------------+-------+
| Com_commit     | 1624  |

12.innodb-log-file-size=100M  --设置事务日志文件大小，增加文件大小，减小IO次数

13.innodb-log-files-in-group=3  --设置事务日志组数，增加文件大小，减小IO次数

14.transaction-isolation=READ-COMMITTED   --不是要求很高的地方，可以调度事务策略，可以提升性能

15.innodb-flush-method=O_DIRECT   --O_DIRECT则表示我们的write操作是从MySQL innodb buffer里直接向磁盘上写。

16.innodb-buffer-pool-size = 2147483648   --用于缓存索引和数据的内存大小
innodb-buffer-pool-chunk-size = 134217728
innodb-buffer-pool-instances = 8
#innodb-buffer-pool-size = 2G * innodb-buffer-pool-chunk-size * innodb-buffer-pool-instances


innoDB缓冲池预取（预读）
线性预读： innodb_read_ahead_threshold  范围值：0-64，默认56
随机预读：要启用此功能，将innodb_random_read_ahead设为 ON

配置缓冲池刷新
mysql> show global variables like "%innodb_max_dirty_pages_pct%";
+--------------------------------+-----------+
| Variable_name                  | Value     |
+--------------------------------+-----------+
| innodb_max_dirty_pages_pct     | 75.000000 |
| innodb_max_dirty_pages_pct_lwm | 0.000000  |
+--------------------------------+-----------+
innodb_flush_neighbors  范围值：0-2    (SSD)0:禁用innodb_flush_neighbors     (HDD)1:会以相同程度刷新连续的脏页    2:会以相同程度刷新脏页


BLOG:
报错：ERROR 3167 (HY000): The 'INFORMATION_SCHEMA.SESSION_VARIABLES' feature is disabled; see the documentation for 'show_compatibility_56'
解决：set global show_compatibility_56=1;

共享内存：
mysql> select VARIABLE_NAME, VARIABLE_VALUE, concat(VARIABLE_VALUE/1024/1024,' MB') AS VARIABLE_VALUE_MB from information_schema.SESSION_VARIABLES where variable_name in ('innodb_buffer_pool_size','innodb_log_buffer_size','innodb_additional_mem_pool_size','key_buffer_size','query_cache_size');
+-------------------------+----------------+-------------------+
| VARIABLE_NAME           | VARIABLE_VALUE | VARIABLE_VALUE_MB |
+-------------------------+----------------+-------------------+
| KEY_BUFFER_SIZE         | 8388608        | 8 MB              |
| QUERY_CACHE_SIZE        | 1048576        | 1 MB              |
| INNODB_LOG_BUFFER_SIZE  | 33554432       | 32 MB             |
| INNODB_BUFFER_POOL_SIZE | 1073741824     | 1024 MB           |
+-------------------------+----------------+-------------------+

Session 私有内存
mysql> select VARIABLE_NAME, VARIABLE_VALUE, concat(VARIABLE_VALUE/1024/1024,' MB') AS VARIABLE_VALUE_MB from information_schema.SESSION_VARIABLES where variable_name in ('read_buffer_size','read_rnd_buffer_size','sort_buffer_size','join_buffer_size','binlog_cache_size','tmp_table_size');
+----------------------+----------------+-------------------+
| VARIABLE_NAME        | VARIABLE_VALUE | VARIABLE_VALUE_MB |
+----------------------+----------------+-------------------+
| READ_RND_BUFFER_SIZE | 262144         | 0.25 MB           |
| JOIN_BUFFER_SIZE     | 262144         | 0.25 MB           |
| READ_BUFFER_SIZE     | 131072         | 0.125 MB          |
| BINLOG_CACHE_SIZE    | 32768          | 0.03125 MB        |
| TMP_TABLE_SIZE       | 16777216       | 16 MB             |
| SORT_BUFFER_SIZE     | 262144         | 0.25 MB           |
+----------------------+----------------+-------------------+


开启内存监控:
mysql> update performance_schema.setup_instruments set enabled = 'yes' where name like 'memory%';
Query OK, 307 rows affected (0.00 sec)
Rows matched: 377  Changed: 307  Warnings: 0
mysql>  select * from performance_schema.setup_instruments where name like 'memory%innodb%' limit 20;
+-------------------------------------------+---------+-------+
| NAME                                      | ENABLED | TIMED |
+-------------------------------------------+---------+-------+
| memory/innodb/adaptive hash index         | YES     | NO    |
| memory/innodb/buf_buf_pool                | YES     | NO    |
| memory/innodb/dict_stats_bg_recalc_pool_t | YES     | NO    |
| memory/innodb/dict_stats_index_map_t      | YES     | NO    |
| memory/innodb/dict_stats_n_diff_on_level  | YES     | NO    |
| memory/innodb/other                       | YES     | NO    |
| memory/innodb/row_log_buf                 | YES     | NO    |
| memory/innodb/row_merge_sort              | YES     | NO    |
| memory/innodb/std                         | YES     | NO    |
| memory/innodb/trx_sys_t::rw_trx_ids       | YES     | NO    |
| memory/innodb/partitioning                | YES     | NO    |
| memory/innodb/api0api                     | YES     | NO    |
| memory/innodb/btr0btr                     | YES     | NO    |
| memory/innodb/btr0bulk                    | YES     | NO    |
| memory/innodb/btr0cur                     | YES     | NO    |
| memory/innodb/btr0pcur                    | YES     | NO    |
| memory/innodb/btr0sea                     | YES     | NO    |
| memory/innodb/buf0buf                     | YES     | NO    |
| memory/innodb/buf0dblwr                   | YES     | NO    |
| memory/innodb/buf0dump                    | YES     | NO    |
+-------------------------------------------+---------+-------+
内存相关表：
mysql> show tables like "%memory%";
+-----------------------------------------+
| Tables_in_performance_schema (%memory%) |
+-----------------------------------------+
| memory_summary_by_account_by_event_name |
| memory_summary_by_host_by_event_name    |
| memory_summary_by_thread_by_event_name  |
| memory_summary_by_user_by_event_name    |
| memory_summary_global_by_event_name     |
+-----------------------------------------+

一、统计事件消耗内存：
mysql>  select event_name, SUM_NUMBER_OF_BYTES_ALLOC  from performance_schema.memory_summary_global_by_event_name order by SUM_NUMBER_OF_BYTES_ALLOC desc LIMIT 10;
+----------------------------------------------------------------------+---------------------------+
| event_name                                                           | SUM_NUMBER_OF_BYTES_ALLOC |
+----------------------------------------------------------------------+---------------------------+
| memory/innodb/mem0mem                                                |                1995778712 |
| memory/sql/get_all_tables                                            |                 412322432 |
| memory/sql/TABLE                                                     |                 281189581 |
| memory/memory/HP_PTRS                                                |                 192947480 |
| memory/mysys/MY_DIR                                                  |                  33424056 |
| memory/sql/sp_head::main_mem_root                                    |                  28100736 |
| memory/performance_schema/events_statements_history_long             |                  14320000 |
| memory/performance_schema/events_statements_history_long.tokens      |                  10240000 |
| memory/performance_schema/events_statements_summary_by_digest.tokens |                  10240000 |
| memory/performance_schema/events_statements_history_long.sqltext     |                  10240000 |
+----------------------------------------------------------------------+---------------------------+
二、统计线程消耗内存
mysql> select thread_id, event_name, SUM_NUMBER_OF_BYTES_ALLOC from performance_schema.memory_summary_by_thread_by_event_name order by SUM_NUMBER_OF_BYTES_ALLOC desc limit 10; 
+-----------+-----------------------+---------------------------+
| thread_id | event_name            | SUM_NUMBER_OF_BYTES_ALLOC |
+-----------+-----------------------+---------------------------+
|    371930 | memory/innodb/mem0mem |                1591929352 |
|    373719 | memory/innodb/mem0mem |                1260471512 |
|    369907 | memory/innodb/mem0mem |                 251307576 |
|    369906 | memory/innodb/mem0mem |                 251061296 |
|    371020 | memory/innodb/mem0mem |                 238006616 |
|    370993 | memory/innodb/mem0mem |                 237003072 |
|    374396 | memory/innodb/mem0mem |                 215111224 |
|    374395 | memory/innodb/mem0mem |                 215105752 |
|    372569 | memory/innodb/mem0mem |                 169878016 |
|    374402 | memory/innodb/mem0mem |                  89511112 |
+-----------+-----------------------+---------------------------+
三、统计账户消耗内存
mysql> select USER, HOST, EVENT_NAME, SUM_NUMBER_OF_BYTES_ALLOC from performance_schema.memory_summary_by_account_by_event_name order by SUM_NUMBER_OF_BYTES_ALLOC desc limit 10; 
+------------+----------------+-----------------------------------+---------------------------+
| USER       | HOST           | EVENT_NAME                        | SUM_NUMBER_OF_BYTES_ALLOC |
+------------+----------------+-----------------------------------+---------------------------+
| exporter   | 192.168.13.116 | memory/innodb/mem0mem             |               65844650316 |
| exporter   | 192.168.13.116 | memory/sql/get_all_tables         |               15545820992 |
| exporter   | 192.168.13.116 | memory/memory/HP_PTRS             |                7245936688 |
| commonuser | 192.168.13.223 | memory/innodb/mem0mem             |                4799390568 |
| exporter   | 192.168.13.116 | memory/mysys/MY_DIR               |                1255560480 |
| exporter   | 192.168.13.116 | memory/sql/sp_head::main_mem_root |                1059501824 |
| commonuser | 172.168.2.215  | memory/innodb/mem0mem             |                 835759808 |
| commonuser | 172.168.2.203  | memory/innodb/mem0mem             |                 293736656 |
| exporter   | 192.168.13.116 | memory/sql/JOIN_CACHE             |                 266862592 |
| exporter   | 192.168.13.116 | memory/sql/thd::main_mem_root     |                 132942912 |
+------------+----------------+-----------------------------------+---------------------------+
四、统计主机消耗内存：
mysql> select  HOST, EVENT_NAME, SUM_NUMBER_OF_BYTES_ALLOC from performance_schema.memory_summary_by_host_by_event_name order by SUM_NUMBER_OF_BYTES_ALLOC desc limit 10; 
+----------------+-----------------------------------+---------------------------+
| HOST           | EVENT_NAME                        | SUM_NUMBER_OF_BYTES_ALLOC |
+----------------+-----------------------------------+---------------------------+
| 192.168.13.116 | memory/innodb/mem0mem             |               66686415452 |
| 192.168.13.116 | memory/sql/get_all_tables         |               15744343264 |
| 192.168.13.116 | memory/memory/HP_PTRS             |                7338468296 |
| 192.168.13.223 | memory/innodb/mem0mem             |                4873961080 |
| 192.168.13.116 | memory/mysys/MY_DIR               |                1271594160 |
| 192.168.13.116 | memory/sql/sp_head::main_mem_root |                1073031808 |
| 172.168.2.215  | memory/innodb/mem0mem             |                 851695800 |
| 172.168.2.203  | memory/innodb/mem0mem             |                 293736656 |
| 192.168.13.116 | memory/sql/JOIN_CACHE             |                 270270464 |
| 192.168.13.116 | memory/sql/thd::main_mem_root     |                 134640192 |
+----------------+-----------------------------------+---------------------------+
五、统计用户消耗内存：
mysql> select  USER, EVENT_NAME, SUM_NUMBER_OF_BYTES_ALLOC from performance_schema.memory_summary_by_user_by_event_name order by SUM_NUMBER_OF_BYTES_ALLOC desc limit 10; 
+------------+-----------------------------------+---------------------------+
| USER       | EVENT_NAME                        | SUM_NUMBER_OF_BYTES_ALLOC |
+------------+-----------------------------------+---------------------------+
| exporter   | memory/innodb/mem0mem             |               67139097900 |
| exporter   | memory/sql/get_all_tables         |               15851239872 |
| exporter   | memory/memory/HP_PTRS             |                7388293008 |
| commonuser | memory/innodb/mem0mem             |                6035689696 |
| exporter   | memory/mysys/MY_DIR               |                1280227680 |
| exporter   | memory/sql/sp_head::main_mem_root |                1080317184 |
| exporter   | memory/sql/JOIN_CACHE             |                 272105472 |
| exporter   | memory/sql/thd::main_mem_root     |                 135554112 |
| exporter   | memory/memory/HP_INFO             |                 120848112 |
| exporter   | memory/memory/HP_SHARE            |                  88782226 |
+------------+-----------------------------------+---------------------------+

mysql> select event_name,current_alloc from sys.memory_global_by_current_bytes where event_name like '%innodb%';
+-------------------------+---------------+
| event_name              | current_alloc |
+-------------------------+---------------+
| memory/innodb/mem0mem   | 1.56 MiB      |
| memory/innodb/row0sel   | 71.01 KiB     |
| memory/innodb/ha_innodb | 38.78 KiB     |
| memory/innodb/trx0undo  | 11.34 KiB     |
| memory/innodb/rem0rec   | 1.22 KiB      |
| memory/innodb/btr0pcur  | 971 bytes     |
+-------------------------+---------------+

mysql> SELECT SUBSTRING_INDEX(event_name,'/',2) AS   code_area, sys.format_bytes(SUM(current_alloc))   AS current_alloc   FROM sys.x$memory_global_by_current_bytes   GROUP BY SUBSTRING_INDEX(event_name,'/',2)   ORDER BY SUM(current_alloc) DESC;
+---------------------------+---------------+
| code_area                 | current_alloc |
+---------------------------+---------------+
| memory/performance_schema | 143.61 MiB    |
| memory/sql                | 19.43 MiB     |
| memory/innodb             | 1.55 MiB      |
| memory/myisam             | 251.80 KiB    |
| memory/mysys              | 194.53 KiB    |
| memory/memory             | 174.01 KiB    |
+---------------------------+---------------+

最大可用内存(M)
mysql> SELECT  (  @@key_buffer_size + @@innodb_buffer_pool_size + @@query_cache_size + @@tmp_table_size + @@max_connections * (  @@read_buffer_size + @@read_rnd_buffer_size + @@sort_buffer_size + @@join_buffer_size + @@binlog_cache_size + @@thread_stack  )  ) / 1024 / 1024 AS result;
+---------------+
| result        |
+---------------+
| 1164.62500000 |
+---------------+
单个连接最大可用内存(M)
mysql> SELECT  (  @@read_buffer_size + @@read_rnd_buffer_size + @@sort_buffer_size + @@join_buffer_size + @@binlog_cache_size + @@thread_stack  ) / 1024 / 1024 AS result;
+------------+
| result     |
+------------+
| 1.15625000 |
+------------+
最大可使用内存
mysql> SELECT  (  @@key_buffer_size + @@innodb_buffer_pool_size + @@query_cache_size + @@tmp_table_size  ) / 1024 / 1024 AS result;
+---------------+
| result        |
+---------------+
| 1049.00000000 |
+---------------+

mysql> show global variables like '%table%cache%';
+----------------------------+-------+
| Variable_name              | Value |
+----------------------------+-------+
| table_definition_cache     | 1400  |
| table_open_cache           | 2000  |
| table_open_cache_instances | 16    |
+----------------------------+-------+

关闭SWAP（只支持cmake编译的mysql）：
innodb_numa_interleave = 0;

#参数对比
local:
@@key_buffer_size		8388608 
@@query_cache_size	1048576 
@@tmp_table_size		16777216 
@@innodb_buffer_pool_size	2147483648 
@@innodb_log_buffer_size	16777216 
@@max_connections	500 
@@sort_buffer_size		262144 
@@read_buffer_size		131072 
@@read_rnd_buffer_size	262144 	
@@join_buffer_size		262144 
@@thread_stack		262144 
@@binlog_cache_size	32768 
total: 2651.5 MB

aliyun
@@key_buffer_size		16777216 
@@query_cache_size	0
@@tmp_table_size		2097152 
@@innodb_buffer_pool_size	12884901888 
@@innodb_log_buffer_size	8388608 
@@max_connections	4532 
@@sort_buffer_size		868352 
@@read_buffer_size		868352 
@@read_rnd_buffer_size	442368 	
@@join_buffer_size		442368 
@@thread_stack		262144 
@@binlog_cache_size	2097152 
```


### 2. 整个mysql数据实例迁移
```
# 旧192.168.13.116：
[root@devmysql ~]# mysqldump -uroot -p --all-databases --triggers --routines --events --set-gtid-purged=OFF --flush-logs --master-data=2 --single-transaction > alldatabases.sql
[root@devmysql ~]# scp alldatabases.sql root@192.168.13.202:/root/
#新192.168.13.202：
[root@devmysql ~]# mysql -uroot -p < alldatabases.sql 
#将新节点做为旧节点的从进行同步
#旧192.168.13.116：
grant replication slave on *.* to 'dev-repluser'@'192.168.13.%' identified by 'test';
show grants for 'dev-repluser'@'192.168.13.%';
#新192.168.13.202：
change master to master_host='192.168.13.116',master_user='dev-repluser',master_password='test',master_log_file='master-bin.000057',MASTER_LOG_POS=194;
(
start slave io_thread;
start slave sql_thread;
或者
start slave;
)
#同步状态：
1. 开始slave线程后，同步状态显示如下
Slave_IO_State: System lock
表示从线程正在大量的复制会话binlog.
2. 等待一段时间后，如下：
Slave_IO_State: Waiting for master to send event
3. 如果同步慢可增加同步线程
set global slave_parallel_workers=2
#最后停止服务并更换IP地址
1. 将旧192.168.13.116实例设置为只读
set global read_only=1;
2. 查看binlog是否还在增长，并记录position，稍后在从节点上看是否都已经同步完成。
show binary logs;
3. 在新节点上查看同步旧节点的文件及位置，确定是否都已经同步完成。
show slave status\G
4. 关闭旧节点的mysql服务，并将ip地址更换为其它空闲ip
service mysqld stop
systemctl stop network
5. 如果确定同步完成，此时在新节点上重置slave和master状态
stop slave ;
reset slave all;
reset master;
mysql> show master logs;
+-------------------+-----------+
| Log_name          | File_size |
+-------------------+-----------+
| master-bin.000001 |       154 |
+-------------------+-----------+
6. 在新节点上先停止mysql服务，将更换ip地址为旧节点的IP地址：192.168.13.116，并启动服务检查数据库是否正常
service mysqld stop
-- change ip to : 192.168.13.116
systemctl restart network
service mysqld start
7. 检查mysql服务
```




### 3. mysql.5.7跟5.6初始密码方式
```
bin/mysqld --initialize --user=mysql --datadir=/usr/local/mysql/data --basedir=/usr/local/mysql
/******* 
注意：这步执行完成后会显示初始化的root用户密码
2020-05-14T05:38:52.063819Z 1 [Note] A temporary password is generated for root@localhost: O(TsKbE/I9hw
密码是：O(TsKbE/I9hw
********/

## method1 
./bin/mysql_install_db --user=mysql --datadir=/data/mysql
root@mysql-slave02:~# cat /root/.mysql_secret
# Password set for user 'root@localhost' at 2022-09-09 17:27:52
>v%sZ0ie%3+0
root@mysql-slave02:~# mysql -uroot -p
Enter password:
alter user root@'localhost' identified by 'your_password'

## method2 
./bin/mysqld  --initialize --user=mysql --datadir=/data/mysql --basedir=/usr/local/mysql
grep password /data/mysql/mysql.err
```


### 4. 问题

#### 4.1 问题1
```
1. mysqlbinlog提取日志出错
[root@tengine /tmp/mysqltmp/Pro_Increment_20211107_030001]# mysqlbinlog --no-defaults --start-po176406467 master-bin.000403_Pro_Increment_20211107_030002 > user-approve
ERROR: Error in Log_event::read_log_event(): 'Found invalid event in binary log', data_len: 65, ype: 33
ERROR: Could not read entry at offset 176406467: Error in log format or read error.
原因：当前的mysqlbinlog版本跟导出binlog日志的mysqlbinlog版本不一致
[root@tengine /tmp/mysqltmp/Pro_Increment_20211107_030001]# /usr/local/mysql/bin/mysqlbinlog --no-defaults --start-position=176406467 master-bin.000403_Pro_Increment_20211107_030002 > user-approve.sql

2. mysql二进制文件恢复时更改数据库名称进行恢复，先要对二进制进行解码以显示数据库名称和表名，再进行对提取后的sql文件进行替换数据库名称。
[root@tengine /tmp/mysqltmp/Pro_Increment_20211107_030001]# /usr/local/mysql/bin/mysqlbinlog --no-defaults --base64-output=decode-rows -v --start-position=176406467 master-bin.000403_Pro_Increment_20211107_030002 > user.sql
[root@tengine /tmp/mysqltmp/Pro_Increment_20211107_030001]# sed -i 's/`zabbix`/`zabbix2021`/g' user.sql 
注：但此方便会增加提取后的文件大小，以及替换数据库名称时花费大量时间，此方法不推荐在大量数据还原时使用，建议不进行解码sql文件不替换数据库名称，在使用全备+增量恢复后将数据库名称进行变更即可。

3. 从开启GTID的库中导出数据到未开启GTID的库中，需要注意，在导出的文件中去掉相应的gtid内容--set-gtid-purged=OFF，否则导入时会报错如下：
ERROR 1839 (HY000) at line 24 in file: '/root/db_hdf_bqjfl_xxxx_xx_xx.sql': @@GLOBAL.GTID_PURGED can only be set when @@GLOBAL.GTID_MODE = ON.
如果恢复数据库二进制文件时报错，设置gtid_mode为OFF_PERMISSIVEL：
MySQL [(none)]> set @@GLOBAL.GTID_MODE = OFF_PERMISSIVE;
| gtid_mode     | OFF_PERMISSIVE |
```



#### 4.2 问题2

```
#ubuntu18下apt安装mysql-server更改数据目录失败问题
root@ubuntu18-node01:/etc/mysql# mysqld --initialize
mysqld: Can't create directory '/data/mysql/' (Errcode: 17 - File exists)
2022-01-21T07:42:39.962304Z 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
2022-01-21T07:42:39.965643Z 0 [ERROR] Aborting
原因：因为Ubuntu有个AppArmor，是一个Linux系统安全应用程序，类似于Selinux,AppArmor默认安全策略定义个别应用程序可以访问系统资源和各自的特权，如果不设置服务的执行程序，即使你改了属主属组并0777权限，也是对服务起不到作用。apt安装下MySQL默认数据目录是/var/lib/mysql，其它的目录权限都不可。开始修改：
vim /etc/apparmor.d/usr.sbin.mysqld
找到：
# Allow data dir access
  /var/lib/mysql/ r,
  /var/lib/mysql/** rwk,
修改为：
# Allow data dir access
  /data/mysql/ r,
  /data/mysql/** rwk,

--再次初始化mysql
root@ubuntu18-node01:/etc/mysql# mysqld --initialize

--启动mysql
root@ubuntu18-node01:/etc/mysql# systemctl start mysql
root@ubuntu18-node01:/etc/mysql# systemctl status mysql

--查看root密码
root@ubuntu18-node01:/etc/mysql# cat /var/log/mysql/error.log | grep -i password | grep 'root@localhost'
2022-01-21T07:12:08.048732Z 1 [Warning] root@localhost is created with an empty password ! Please consider switching off the --initialize-insecure option.
2022-01-21T07:44:40.064990Z 1 [Note] A temporary password is generated for root@localhost: Qal4*LYjoJ#0
```





#### 4.3 问题3

**mysql从旧集群迁移到新集群一定要考虑自增ID，否则数据同步会出错，记一次前一事故于20241219晚8点**



**环境现状：**

旧集群：主主集群，A1自增ID初始为1，步长为2，A2自增ID初始为2，步长为2，主主模式下无问题。

新集群：主主集群，B1自增ID初始为1，步长为2，B2自增ID初始为2，步长为2，主主模式下无问题。



**此时需求：**

将A1数据同步到B1，当同步完成后，此时数据还会实时同步，有一部分服务使用新域名promysql.hs.com写入到A1，绝大部分使用旧域名mysql.hs.com写入到B1，要涉及域名的映射变更



**应对办法：**

将A1和B1做成主主集群



**此后故障现象：**

A1和B1同步过程出错，报库表中主键重复错误

故障原因： 同一个服务，一号环境的服务写入数据到promysql.hs.com、二号环境的服务写入数据到mysql.hs.com，在DNS缓存失效时间不一致情况下或高并发情况下就可能出现如上情况，所以致使promysql.hs.com和mysql.hs.com`同一个库表同一个主键`都已经存在，最后A1和B1数据在同步时就会冲突，导致数据不能正常回放同步而故障。

```
2024-12-19T14:22:11.056614+08:00 22246920 [Warning] Storing MySQL user name or password information in the master info repository is not secure and is therefore not recommended. Please consider using the USER and PASSWORD connection options for START SLAVE; see the 'START SLAVE Syntax' in the MySQL Manual for more information.
2024-12-19T20:33:12.520523+08:00 22246923 [ERROR] Slave SQL for channel 'channel_165': Worker 2 failed executing transaction '608bbf72-a0d4-11ef-9140-0050569c6862:958' at master log master-bin.000024, end_log_pos 810686885; Could not execute Write_rows event on table trip_management.trip_event_msg; Duplicate entry '2828933' for key 'PRIMARY', Error_code: 1062; handler error HA_ERR_FOUND_DUPP_KEY; the event's master log master-bin.000024, end_log_pos 810686885, Error_code: 1062
2024-12-19T20:33:12.551226+08:00 22246921 [Warning] Slave SQL for channel 'channel_165': ... The slave coordinator and worker threads are stopped, possibly leaving data in inconsistent state. A restart should restore consistency automatically, although using non-transactional storage for data or info tables or DDL queries could lead to problems. In such cases you have to examine your data (see documentation for details). Error_code: 1756
2024-12-19T20:37:29.994475+08:00 22317066 [ERROR] Slave SQL for channel 'channel_165': Worker 2 failed executing transaction '608bbf72-a0d4-11ef-9140-0050569c6862:958' at master log master-bin.000024, end_log_pos 810686885; Could not execute Write_rows event on table trip_management.trip_event_msg; Duplicate entry '2828933' for key 'PRIMARY', Error_code: 1062; handler error HA_ERR_FOUND_DUPP_KEY; the event's master log FIRST, end_log_pos 810686885, Error_code: 1062
2024-12-19T20:37:29.994503+08:00 22317064 [Warning] Slave SQL for channel 'channel_165': ... The slave coordinator and worker threads are stopped, possibly leaving data in inconsistent state. A restart should restore consistency automatically, although using non-transactional storage for data or info tables or DDL queries could lead to problems. In such cases you have to examine your data (see documentation for details). Error_code: 1756
2024-12-19T20:37:30.025503+08:00 22317065 [ERROR] Slave SQL for channel 'channel_165': Worker 1 failed executing transaction '608bbf72-a0d4-11ef-9140-0050569c6862:981' at master log master-bin.000024, end_log_pos 811262540; Could not execute Update_rows event on table email_sms_tmpl.qrtz_scheduler_state; Can't find record in 'qrtz_scheduler_state', Error_code: 1032; handler error HA_ERR_KEY_NOT_FOUND; the event's master log master-bin.000024, end_log_pos 811262540, Error_code: 1032
[root@pro-mysql02 /data/mysql]# tail mysql.err
2024-12-19T14:22:11.056614+08:00 22246920 [Warning] Storing MySQL user name or password information in the master info repository is not secure and is therefore not recommended. Please consider using the USER and PASSWORD connection options for START SLAVE; see the 'START SLAVE Syntax' in the MySQL Manual for more information.
2024-12-19T20:33:12.520523+08:00 22246923 [ERROR] Slave SQL for channel 'channel_165': Worker 2 failed executing transaction '608bbf72-a0d4-11ef-9140-0050569c6862:958' at master log master-bin.000024, end_log_pos 810686885; Could not execute Write_rows event on table trip_management.trip_event_msg; Duplicate entry '2828933' for key 'PRIMARY', Error_code: 1062; handler error HA_ERR_FOUND_DUPP_KEY; the event's master log master-bin.000024, end_log_pos 810686885, Error_code: 1062
2024-12-19T20:33:12.551226+08:00 22246921 [Warning] Slave SQL for channel 'channel_165': ... The slave coordinator and worker threads are stopped, possibly leaving data in inconsistent state. A restart should restore consistency automatically, although using non-transactional storage for data or info tables or DDL queries could lead to problems. In such cases you have to examine your data (see documentation for details). Error_code: 1756
2024-12-19T20:37:29.994475+08:00 22317066 [ERROR] Slave SQL for channel 'channel_165': Worker 2 failed executing transaction '608bbf72-a0d4-11ef-9140-0050569c6862:958' at master log master-bin.000024, end_log_pos 810686885; Could not execute Write_rows event on table trip_management.trip_event_msg; Duplicate entry '2828933' for key 'PRIMARY', Error_code: 1062; handler error HA_ERR_FOUND_DUPP_KEY; the event's master log FIRST, end_log_pos 810686885, Error_code: 1062
2024-12-19T20:37:29.994503+08:00 22317064 [Warning] Slave SQL for channel 'channel_165': ... The slave coordinator and worker threads are stopped, possibly leaving data in inconsistent state. A restart should restore consistency automatically, although using non-transactional storage for data or info tables or DDL queries could lead to problems. In such cases you have to examine your data (see documentation for details). Error_code: 1756
2024-12-19T20:37:30.025503+08:00 22317065 [ERROR] Slave SQL for channel 'channel_165': Worker 1 failed executing transaction '608bbf72-a0d4-11ef-9140-0050569c6862:981' at master log master-bin.000024, end_log_pos 811262540; Could not execute Update_rows event on table email_sms_tmpl.qrtz_scheduler_state; Can't find record in 'qrtz_scheduler_state', Error_code: 1032; handler error HA_ERR_KEY_NOT_FOUND; the event's master log master-bin.000024, end_log_pos 811262540, Error_code: 1032
```



**临时跳过**

```sql
# show slave status\G 错误：
Coordinator stopped because there were error(s) in the worker(s). The most recent failure being: Worker 1 failed executing transaction '608bbf72-a0d4-11ef-9140-0050569c6862:981' at master log master-bin.000024, end_log_pos 811262540. See error log and/or performance_schema.replication_applier_status_by_worker table for more details about this failure or others, if any.


# 1. 跳过此次事务ID
set @@session.gtid_next='608bbf72-a0d4-11ef-9140-0050569c6862:981';
begin;commit;
set @@session.gtid_next=automatic;
start slave SQL_THREAD for channel 'channel_165';

# 2. 或者更改position位置
stop slave for channel 'channel_165';
reset slave all for channel 'channel_165';
change master to master_host='192.168.13.165',master_port=3306,master_user='repluser',master_password='test',master_log_file='master-bin.000024',MASTER_LOG_POS=811262540 for channel 'channel_165';
start slave for channel 'channel_165';
show slave status\G
```



**最终解决办法：**

因为A1和B1表中都存在同一个主键ID，而且有好多行，一个一个跳过不太现实。而绝大部分服务写入的是B1(mysql.hs.com)，所以**将B1视为主要的数据库**，步骤如下：

1. 观察A1(promysql.hs.com)的连接状态，通过用户连接的数据库找到对应的服务，将服务重启，使其连接到B1(mysql.hs.com)，直至服务都连接至B1(mysql.hs.com)。
2. 查看B1的slave线程同步情况，通过`show slave status\G`看出同步到`file master-bin.001633, end_log_pos 100743590`这个位置时错误，并且查看A1的master状态，通过`show master status\G`看出当前的position为`master-bin.001633，370715282`，得到开始和结束的file、position。
3. 通过`binlog2sql`工具将binlog备份成sql，然后分析sql语句来被数据。

```
python3 binlog2sql/binlog2sql.py -h192.168.13.164 -P3306 -uadmin -p'test'  --start-file='master-bin.001633' --start-position=100743590 --stop-file='master-bin.001633' --stop-position=370715282 > ./mysql_164.sql
```



**什么是主主集群：就是2个节点现在和将来要进行写入数据的节点，上面A1现在写入数据，B1现在不写入数据，但是B1将来要写入数据，所以A1和B1也是主主集群。**



**结论：**

**主主集群自增ID一定不能冲突，如果是两个集群组成主从，这里共4节点，要考虑到所有节点的自增ID，这里应为：**

1. A1自增ID初始为1，步长为4，
2. A2自增ID初始为2，步长为4，
3. B1自增ID初始为3，步长为4，
4. B2自增ID初始为4，步长为4。









### 5. 生产mysql主主集群节点迁移
```
master01: 192.168.13.160
master02: 192.168.13.163 
new master02: 192.168.13.164
需求：将192.168.13.163迁移至192.168.13.164，192.168.13.160跟192.168.13.164成为主主集群

1. 192.168.13.164安装mysql，并复制192.168.13.163服务器配置文件到192.168.13.164，重启192.168.13.164服务
2. 停止192.168.13.163 slave线程，并确保无任何客户端写入数据到192.168.13.163。
3. 全库备份192.168.13.163并复制到192.168.13.164，记录192.168.13.163slave同步192.168.13.160master01执行到什么文件、什么位置，例如master_log_file='master-bin.000157',master_log_pos=111047299{其实可以直接从192.168.13.160进行全库备份，然后复制到192.168.13.164进行恢复，直接把192.168.13.160作为主}
 mysqldump -uroot -p --all-databases --triggers --routines --events --set-gtid-purged=OFF --flush-logs --master-data=2 --single-transaction > alldatabases.sql
4. 192.168.13.164恢复数据库，并配置192.168.13.160为master，此时主从复制集群配置完成

head -n 1000 alldatabases.sql | grep -i 'change master'
-- CHANGE MASTER TO MASTER_LOG_FILE='master-bin.000157', MASTER_LOG_POS=111047299;

set session sql_log_bin=0;
source /root/alldatabases.sql;
set session sql_log_bin=1;
change master to master_host='192.168.13.160',master_port=3306,master_user='repluser',master_password='test',master_log_file='master-bin.000157',MASTER_LOG_POS=111047299 for channel 'channel1';
show slave status\G
5. 需要实现主主集群，还需要在192.168.13.160上把192.168.13.164设置为主
    5.1 将192.168.13.164的配置文件/etc/my.cnf关闭多级复制，log-slave-updates = 0，并重启服务。观察192.168.13.164 binlog文件确定是否未变化(本机未执行DML语句时)
    5.2 在192.168.13.160上将192.168.13.164设置为主
    change master to master_host='192.168.13.164',master_port=3306,master_user='repluser',master_password='test',master_log_file='master-bin.000005',MASTER_LOG_POS=194 for channel 'channel1';
    5.3 然后配置文件/etc/my.cnf开启多级复制，log-slave-updates = 1，并重启服务
------------------------------------------------------------------------------------
注：5.1和5.3其实可以省略log-slave-updates的配置，直接配置change master,只需要查看本地binlog文件执行哪个位置，可以从早期位置同步，mysql不会重复插入，得益于gtid的作用，但是上面步骤更稳妥。例如
mysql> show master status\G
*************************** 1. row ***************************
             File: master-bin.000004
         Position: 115946474			------可以使用早期Position进行master同步
mysql> show master status\G
*************************** 1. row ***************************
             File: master-bin.000004
         Position: 115947139
change master to master_host='192.168.13.164',master_port=3306,master_user='repluser',master_password='test',master_log_file='master-bin.000004',MASTER_LOG_POS=115946474 for channel 'channel1';
------------------------------------------------------------------------------------
6. 测试master01和new master02是否可以互写同步即可

7. 安装keepalived高可用，注意keepalived的配置，优先级、单播注意IP地址一定要匹配对，否则会出现脑残情况。
```


### 6. 记一次生产数据库恢复过程

> datetime: 2023-03-21 17:00
```
需求：恢复mysql生产库feishu_selfbuilt到2023-03-17 11点

#### 安装mysql5.7 for docker
docker run -d -p 3306:3306 --restart -v /usr/share/zoneinfo/Asia/Shanghai:/etc/localtime --name restore-mysql -v /data/mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=password mysql:5.7.31 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci

#### 恢复步骤
## 截取全量备份 标志位
grep "CHANGE MASTER TO MASTER_LOG_FILE='" Pro_Full_20230316_010451_feishu_selfbuilt.sql
-- CHANGE MASTER TO MASTER_LOG_FILE='master-bin.000400', MASTER_LOG_POS=418765598;

## binlog格式转换为sql，从标志位处开始
mysqlbinlog --no-defaults --start-position=418765598 master-bin.000400_Pro_Increment_20230316_030001 > feishu_selfbuilt-000400.sql

## binlog格式转换为sql
mysqlbinlog --no-defaults master-bin.000401_Pro_Increment_20230317_030001 > feishu_selfbuilt-000401.sql

## binlog格式转换为sql，到达指定时间停止
mysqlbinlog --no-defaults --stop-datetime='2023-03-17 11:00:00'  master-bin.000402_Pro_Increment_20230318_030001 > feishu_selfbuilt-000402.sql

## 全量恢复
mysql -uroot -p < Pro_Full_20230316_010451_feishu_selfbuilt.sql

## 增量恢复
source /restore-mysql/feishu_selfbuilt-000400.sql
source /restore-mysql/feishu_selfbuilt-000401.sql
source /restore-mysql/feishu_selfbuilt-000402.sql



# 差异备份方式一 
[root@lnmp ~]# mysqlbinlog --no-defaults --start-position=107 /data/mysql/mysql-bin.000012 /data/mysql/mysql-bin.000013 /data/mysql/mysql-bin.000014 > /root/diff.sql
# 差异备份方式二 
[root@lnmp ~]# mysqlbinlog --no-defaults --start-position=107 /data/mysql/mysql-bin.* > /root/diff.sql
```



### 7.停止和删除channel为空的channel

```bash
# 停止和删除channel为空的channel
mysql> stop slave FOR CHANNEL '';
# 此步骤不会重置io_thread和sql_thread是运行状态的channel，只会重置状态是停止的channel
mysql> reset slave all;

# 当有多个channel时,重置特定的channel
mysql> stop slave for channel 'channel_19';
mysql> reset slave all for channel 'channel_19';
```



### 8. 配置主主同步

#### 8.1 测试环境

```bash
# master01
mysql> grant replication slave on *.* to repluser@'172.168.2.%' identified by 'jcemcilmbpVCm2JO';

mysql> show grants for repluser@'172.168.2.%';
+------------------------------------------------------------+
| Grants for repluser@172.168.2.%                            |
+------------------------------------------------------------+
| GRANT REPLICATION SLAVE ON *.* TO 'repluser'@'172.168.2.%' |
+------------------------------------------------------------+

mysql> flush binary logs;

mysql> show binary logs;
+-------------------+-----------+
| Log_name          | File_size |
+-------------------+-----------+
| master-bin.000005 |      1430 |
| master-bin.000006 |       194 |
+-------------------+-----------+

mysql> purge binary logs to 'master-bin.000006';

mysql> show master status;
+-------------------+----------+--------------+------------------+------------------------------------------+
| File              | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set                        |
+-------------------+----------+--------------+------------------+------------------------------------------+
| master-bin.000006 |      194 |              |                  | cced45a5-a028-11ef-bf55-000c298e491d:1-5 |
+-------------------+----------+--------------+------------------+------------------------------------------+


# master02
mysql> grant replication slave on *.* to repluser@'172.168.2.%' identified by 'jcemcilmbpVCm2JO';

mysql> show grants for repluser@'172.168.2.%';
+------------------------------------------------------------+
| Grants for repluser@172.168.2.%                            |
+------------------------------------------------------------+
| GRANT REPLICATION SLAVE ON *.* TO 'repluser'@'172.168.2.%' |
+------------------------------------------------------------+

mysql> flush binary logs;

mysql> show binary logs;
+-------------------+-----------+
| Log_name          | File_size |
+-------------------+-----------+
| master-bin.000005 |      1430 |
| master-bin.000006 |       194 |
+-------------------+-----------+

mysql> purge binary logs to 'master-bin.000006';

mysql> show master status;
+-------------------+----------+--------------+------------------+------------------------------------------+
| File              | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set                        |
+-------------------+----------+--------------+------------------+------------------------------------------+
| master-bin.000006 |      194 |              |                  | cd0bd321-a028-11ef-bf6b-000c29271638:1-2 |
+-------------------+----------+--------------+------------------+------------------------------------------+



# master01 config
mysql> change master to master_host='172.168.2.44',master_user='repluser',master_password='jcemcilmbpVCm2JO',master_log_file='master-bin.000006',MASTER_LOG_POS=194 for CHANNEL 'g2-mysql02-to-mysql01';

mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State:
                  Master_Host: 172.168.2.44
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000006
          Read_Master_Log_Pos: 194
               Relay_Log_File: relay-master.000001
                Relay_Log_Pos: 4
        Relay_Master_Log_File: master-bin.000006
             Slave_IO_Running: No
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
          Exec_Master_Log_Pos: 194
              Relay_Log_Space: 154
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
            Executed_Gtid_Set: cced45a5-a028-11ef-bf55-000c298e491d:1-5
                Auto_Position: 0
         Replicate_Rewrite_DB:
                 Channel_Name: g2-mysql02-to-mysql01
           Master_TLS_Version:

mysql> start slave;
Query OK, 0 rows affected (0.01 sec)

mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 172.168.2.44
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000006
          Read_Master_Log_Pos: 194
               Relay_Log_File: relay-master.000002
                Relay_Log_Pos: 321
        Relay_Master_Log_File: master-bin.000006
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
          Exec_Master_Log_Pos: 194
              Relay_Log_Space: 525
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
             Master_Server_Id: 2
                  Master_UUID: cd0bd321-a028-11ef-bf6b-000c29271638
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp:
               Master_SSL_Crl:
           Master_SSL_Crlpath:
           Retrieved_Gtid_Set:
            Executed_Gtid_Set: cced45a5-a028-11ef-bf55-000c298e491d:1-5
                Auto_Position: 0
         Replicate_Rewrite_DB:
                 Channel_Name: g2-mysql02-to-mysql01
           Master_TLS_Version:



# master02 config
mysql> change master to master_host='172.168.2.43',master_user='repluser',master_password='jcemcilmbpVCm2JO',master_log_file='master-bin.000006',MASTER_LOG_POS=194 for CHANNEL 'g2-mysql01-to-mysql02';

mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State:
                  Master_Host: 172.168.2.43
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000006
          Read_Master_Log_Pos: 194
               Relay_Log_File: relay-master-g2@002dmysql01@002dto@002dmysql02.000001
                Relay_Log_Pos: 4
        Relay_Master_Log_File: master-bin.000006
             Slave_IO_Running: No
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
          Exec_Master_Log_Pos: 194
              Relay_Log_Space: 154
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
            Executed_Gtid_Set: cd0bd321-a028-11ef-bf6b-000c29271638:1-2
                Auto_Position: 0
         Replicate_Rewrite_DB:
                 Channel_Name: g2-mysql01-to-mysql02
           Master_TLS_Version:

mysql> start slave;

mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 172.168.2.43
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000006
          Read_Master_Log_Pos: 194
               Relay_Log_File: relay-master-g2@002dmysql01@002dto@002dmysql02.000002
                Relay_Log_Pos: 321
        Relay_Master_Log_File: master-bin.000006
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
          Exec_Master_Log_Pos: 194
              Relay_Log_Space: 559
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
                  Master_UUID: cced45a5-a028-11ef-bf55-000c298e491d
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp:
               Master_SSL_Crl:
           Master_SSL_Crlpath:
           Retrieved_Gtid_Set:
            Executed_Gtid_Set: cd0bd321-a028-11ef-bf6b-000c29271638:1-2
                Auto_Position: 0
         Replicate_Rewrite_DB:
                 Channel_Name: g2-mysql01-to-mysql02
           Master_TLS_Version:


# 测试主主
# master01 
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.00 sec)

mysql> create database test;

# master02
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test               |
+--------------------+

mysql> drop database test;

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+

# master01
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
```



#### 8.2 生产环境

```bash
# master01
mysql> grant replication slave on *.* to repluser@'192.168.13.%' identified by 'ALbx93RAYDZQd5pa';

mysql> show grants for repluser@'192.168.13.%';
+------------------------------------------------------------+
| Grants for repluser@192.168.13.%                            |
+------------------------------------------------------------+
| GRANT REPLICATION SLAVE ON *.* TO 'repluser'@'192.168.13.%' |
+------------------------------------------------------------+

mysql> flush binary logs;

mysql> show binary logs;
+-------------------+-----------+
| Log_name          | File_size |
+-------------------+-----------+
| master-bin.000005 |      1430 |
| master-bin.000006 |       194 |
+-------------------+-----------+

mysql> purge binary logs to 'master-bin.000006';

mysql> show master status;
+-------------------+----------+--------------+------------------+------------------------------------------+
| File              | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set                        |
+-------------------+----------+--------------+------------------+------------------------------------------+
| master-bin.000006 |      194 |              |                  | 608bbf72-a0d4-11ef-9140-0050569c6862:1-2 |
+-------------------+----------+--------------+------------------+------------------------------------------+



# master02
mysql> grant replication slave on *.* to repluser@'192.168.13.%' identified by 'ALbx93RAYDZQd5pa';

mysql> show grants for repluser@'192.168.13.%';
+------------------------------------------------------------+
| Grants for repluser@192.168.13.%                            |
+------------------------------------------------------------+
| GRANT REPLICATION SLAVE ON *.* TO 'repluser'@'192.168.13.%' |
+------------------------------------------------------------+

mysql> flush binary logs;

mysql> show binary logs;
+-------------------+-----------+
| Log_name          | File_size |
+-------------------+-----------+
| master-bin.000005 |      1430 |
| master-bin.000006 |       194 |
+-------------------+-----------+

mysql> purge binary logs to 'master-bin.000006';

mysql> show master status;
+-------------------+----------+--------------+------------------+------------------------------------------+
| File              | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set                        |
+-------------------+----------+--------------+------------------+------------------------------------------+
| master-bin.000006 |      194 |              |                  | 60a3d850-a0d4-11ef-b3d1-0050569c92f9:1-2 |
+-------------------+----------+--------------+------------------+------------------------------------------+




# master01 config
mysql> change master to master_host='192.168.13.166',master_user='repluser',master_password='ALbx93RAYDZQd5pa',master_log_file='master-bin.000006',MASTER_LOG_POS=194 for CHANNEL 'g2-mysql02-sync-to-mysql01';

mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: 
                  Master_Host: 192.168.13.166
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000006
          Read_Master_Log_Pos: 194
               Relay_Log_File: relay-master-g2@002dmysql02@002dsync@002dto@002dmysql01.000001
                Relay_Log_Pos: 4
        Relay_Master_Log_File: master-bin.000006
             Slave_IO_Running: No
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
          Exec_Master_Log_Pos: 194
              Relay_Log_Space: 154
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
            Executed_Gtid_Set: 608bbf72-a0d4-11ef-9140-0050569c6862:1-2
                Auto_Position: 0
         Replicate_Rewrite_DB: 
                 Channel_Name: g2-mysql02-sync-to-mysql01
           Master_TLS_Version: 


mysql> start slave;

mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.13.166
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000006
          Read_Master_Log_Pos: 194
               Relay_Log_File: relay-master-g2@002dmysql02@002dsync@002dto@002dmysql01.000002
                Relay_Log_Pos: 321
        Relay_Master_Log_File: master-bin.000006
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
          Exec_Master_Log_Pos: 194
              Relay_Log_Space: 568
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
             Master_Server_Id: 2
                  Master_UUID: 60a3d850-a0d4-11ef-b3d1-0050569c92f9
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: 
            Executed_Gtid_Set: 608bbf72-a0d4-11ef-9140-0050569c6862:1-2
                Auto_Position: 0
         Replicate_Rewrite_DB: 
                 Channel_Name: g2-mysql02-sync-to-mysql01
           Master_TLS_Version: 




# master02 config
mysql> change master to master_host='192.168.13.165',master_user='repluser',master_password='ALbx93RAYDZQd5pa',master_log_file='master-bin.000006',MASTER_LOG_POS=194 for CHANNEL 'g2-mysql01-sync-to-mysql02';

mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: 
                  Master_Host: 192.168.13.165
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000006
          Read_Master_Log_Pos: 194
               Relay_Log_File: relay-master-g2@002dmysql01@002dsync@002dto@002dmysql02.000001
                Relay_Log_Pos: 4
        Relay_Master_Log_File: master-bin.000006
             Slave_IO_Running: No
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
          Exec_Master_Log_Pos: 194
              Relay_Log_Space: 154
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
            Executed_Gtid_Set: 60a3d850-a0d4-11ef-b3d1-0050569c92f9:1-2
                Auto_Position: 0
         Replicate_Rewrite_DB: 
                 Channel_Name: g2-mysql01-sync-to-mysql02
           Master_TLS_Version: 


mysql> start slave;

mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.13.165
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000006
          Read_Master_Log_Pos: 194
               Relay_Log_File: relay-master-g2@002dmysql01@002dsync@002dto@002dmysql02.000002
                Relay_Log_Pos: 321
        Relay_Master_Log_File: master-bin.000006
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
          Exec_Master_Log_Pos: 194
              Relay_Log_Space: 568
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
                  Master_UUID: 608bbf72-a0d4-11ef-9140-0050569c6862
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: 
            Executed_Gtid_Set: 60a3d850-a0d4-11ef-b3d1-0050569c92f9:1-2
                Auto_Position: 0
         Replicate_Rewrite_DB: 
                 Channel_Name: g2-mysql01-sync-to-mysql02
           Master_TLS_Version: 


# 测试主主
# master01 
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+

mysql> create database test;
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+

# master02
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test               |
+--------------------+

mysql> drop database test;
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+

# master01
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+

```



## 常用语句

```sql
-- 查看进程列表
show processlist;

-- 查看进程列表，通过条件筛选
SELECT id as 线程ID,db as 当前进入数据库,user as 用户, host as 客户端,time as 等待时间,state as 执行状态,info as SQL语句 
FROM INFORMATION_SCHEMA.PROCESSLIST 
where info !='' -- and db='czndc'
order by info desc

-- 查看进程列表，通过条件筛选
SELECT id as 线程ID,db as 当前进入数据库,user as 用户, host as 客户端,time as 等待时间,state as 执行状态,info as SQL语句 
FROM INFORMATION_SCHEMA.PROCESSLIST 
where info !='' 
-- and info like '%interhotelresource_expedia%'
order by info desc



-- 查看当前使用的表，缩小死锁相关的数据库范围
show OPEN TABLES where In_use > 0;

-- kill进程
-- kill 3980177


-- 查看innode锁、等待锁，判断数据库是否有锁
SELECT * FROM INFORMATION_SCHEMA.INNODB_LOCKS; 
SELECT * FROM INFORMATION_SCHEMA.INNODB_LOCK_WAITS; 


-- 查看表锁等待状态、行锁等待状态
show status like 'table%';
show status like 'InnoDB_row_lock%';


-- 查看innodb当前状态，查找status中TRANSACTION的locked，判断哪个事务有死锁，再查找`MySQL thread id`，结束线程id
show engine innodb status;


-- 查看innodb事务的线程信息
select * from INFORMATION_SCHEMA.INNODB_TRX

-- 查看innodb事务特定信息
select trx_id as 事务ID, trx_mysql_thread_id as mysql线程ID, trx_started as 线程开始时间, trx_tables_in_use as 使用的表数量,
trx_tables_locked as 锁定的表数量,trx_rows_locked as 锁定的行数量, trx_query as 查询语句
from INFORMATION_SCHEMA.INNODB_TRX


-- 查看告警信息
show WARNINGS;


-- 查看死锁是否写入错误日志文件
show global variables like 'innodb_print_all_deadlocks';
SHOW VARIABLES LIKE 'log_error';
-- 通过错误日志文件中的事务ID查看线程ID
SELECT id, user, host, db, command, time, state, info, trx_id
FROM information_schema.processlist
JOIN information_schema.innodb_trx ON information_schema.processlist.id = information_schema.innodb_trx.trx_mysql_thread_id;


-- 在master上查看从节点信息
# Server_id为13的slave节点mysql服务已经停止
mysql> show slave hosts;
+-----------+------+------+-----------+--------------------------------------+
| Server_id | Host | Port | Master_id | Slave_UUID                           |
+-----------+------+------+-----------+--------------------------------------+
|        11 |      | 3306 |        12 | 608bbf72-a0d4-11ef-9140-0050569c6862 |
+-----------+------+------+-----------+--------------------------------------+
# Server_id为13的slave节点mysql服务已经正常
mysql> show slave hosts;
+-----------+------+------+-----------+--------------------------------------+
| Server_id | Host | Port | Master_id | Slave_UUID                           |
+-----------+------+------+-----------+--------------------------------------+
|        13 |      | 3306 |        12 | be245fa2-0955-11f0-bd79-906f1807c457 |
|        11 |      | 3306 |        12 | 608bbf72-a0d4-11ef-9140-0050569c6862 |
+-----------+------+------+-----------+--------------------------------------+
```







## mysql调优

在 `SHOW ENGINE INNODB STATUS` 的输出中，查看缓冲池使用情况是评估数据库性能的关键步骤之一。下面是如何根据缓冲池的使用情况做出调整：

**innodb status**

```
=====================================
2024-12-02 15:43:10 0x7f60c3ef7700 INNODB MONITOR OUTPUT
=====================================
Per second averages calculated from the last 28 seconds
-----------------
BACKGROUND THREAD
-----------------
srv_master_thread loops: 13396724 srv_active, 0 srv_shutdown, 21909 srv_idle
srv_master_thread log flush and writes: 13418633
----------
SEMAPHORES
----------
OS WAIT ARRAY INFO: reservation count 193593675573
--Thread 140053527312128 has waited at buf0buf.cc line 4040 for 0  seconds the semaphore:
S-lock on RW-latch at 0x7f621d35cbe8 created in file buf0buf.cc line 1468
a writer (thread id 140053536773888) has reserved it in mode  exclusive
number of readers 0, waiters flag 1, lock_word: 0
Last time read locked in file row0sel.cc line 3766
Last time write locked in file /export/home/pb2/build/sb_0-39489236-1591101761.33/mysql-5.7.31/storage/innobase/buf/buf0buf.cc line 5210
OS WAIT ARRAY INFO: signal count 66482489263
RW-shared spins 0, rounds 413022330814, OS waits 192340138320
RW-excl spins 0, rounds 220272496510, OS waits 884730441
RW-sx spins 86157096, rounds 1742951978, OS waits 25614492
Spin rounds per wait: 413022330814.00 RW-shared, 220272496510.00 RW-excl, 20.23 RW-sx
------------
TRANSACTIONS
------------
Trx id counter 20422525725
Purge done for trx's n:o < 20422510918 undo n:o < 0 state: running but idle
History list length 4705
LIST OF TRANSACTIONS FOR EACH SESSION:
---TRANSACTION 421537104098000, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104015920, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104173696, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104120800, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104092528, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104108944, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537103994944, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104133568, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104129008, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104115328, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104000416, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104128096, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104073376, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104065168, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104051488, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104263984, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104263072, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104262160, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104258512, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104260336, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104259424, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104257600, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104049664, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104251216, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104209264, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104188288, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104130832, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104003152, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104050576, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537103993120, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104162752, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104089792, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104047840, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104068816, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104201968, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104181904, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104087968, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104007712, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537103999504, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537103996768, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104215648, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104250304, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104249392, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104247568, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104246656, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104245744, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104240272, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104239360, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104236624, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104078848, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104234800, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104230240, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104014096, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104123536, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104225680, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104222944, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104222032, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104220208, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104216560, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104199232, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104191024, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104170048, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104150896, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104149072, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104066080, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104010448, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104009536, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104112592, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104023216, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104001328, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104190112, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104187376, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104180080, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104147248, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104046016, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104099824, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104100736, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104093440, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104171872, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104118064, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104219296, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104218384, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104214736, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104170960, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104141776, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104139040, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104057872, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104136304, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104132656, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104111680, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104105296, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104098912, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104082496, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104069728, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104061520, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537103995856, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104032336, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104164576, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104152720, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104079760, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104067904, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104064256, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104035072, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537103994032, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104122624, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104241184, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104233888, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104232976, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104229328, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104228416, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104226592, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104213824, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104224768, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104223856, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104221120, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104198320, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104197408, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104195584, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104194672, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104137216, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104124448, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104090704, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104087056, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104084320, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104063344, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104037808, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104036896, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104008624, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104186464, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104178256, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104172784, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104166400, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104126272, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104109856, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104060608, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104029600, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104004064, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104025952, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104149984, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104125360, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104018656, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104095264, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537103998592, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104016832, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104156368, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104131744, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104169136, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104167312, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104165488, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104158192, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104153632, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104146336, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104080672, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104106208, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104097088, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104077936, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104138128, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104121712, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104119888, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104039632, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104024128, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104107120, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104056960, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104021392, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104256688, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104255776, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104085232, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104038720, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104006800, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104252128, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104243920, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104242096, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104180992, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104135392, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104110768, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104077024, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104154544, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104053312, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104238448, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104237536, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104235712, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104231152, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104012272, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104227504, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104040544, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104055136, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104168224, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104081584, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104022304, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104142688, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104127184, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104070640, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104011360, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104004976, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104056048, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104217472, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104177344, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104139952, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104113504, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104076112, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104145424, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104072464, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104212912, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104211088, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104071552, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104208352, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104206528, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104205616, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104204704, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104202880, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104200144, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104185552, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104148160, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104086144, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104088880, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104052400, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537103997680, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104160928, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104034160, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104192848, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104028688, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104140864, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104114416, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104144512, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104129920, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104013184, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104134480, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104019568, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104182816, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104043280, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104203792, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104031424, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104054224, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104044192, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104161840, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104232064, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104059696, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104157280, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104183728, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104174608, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104075200, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104045104, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104048752, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104096176, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104058784, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104248480, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104102560, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104163664, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104035984, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104243008, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104155456, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104025040, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104160016, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104315056, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104325088, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104033248, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104017744, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104365216, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104002240, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537103992208, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104015008, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104254864, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104294080, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104541232, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104151808, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104509312, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104442736, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104436352, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104494720, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104493808, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104490160, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104042368, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104415376, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104261248, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104482864, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104332384, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104425408, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104175520, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104005888, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104046928, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104438176, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104265808, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104176432, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104210176, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104117152, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104030512, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104091616, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104026864, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104159104, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104104384, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104083408, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104103472, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104094352, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104020480, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104191936, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104074288, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104184640, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104108032, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104041456, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104189200, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104143600, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104193760, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104118976, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104062432, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104116240, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104027776, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104101648, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537104264896, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537103991296, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537103990384, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537103989472, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421537103988560, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
--------
FILE I/O
--------
I/O thread 0 state: waiting for completed aio requests (insert buffer thread)
I/O thread 1 state: waiting for completed aio requests (log thread)
I/O thread 2 state: waiting for completed aio requests (read thread)
I/O thread 3 state: waiting for completed aio requests (read thread)
I/O thread 4 state: waiting for completed aio requests (read thread)
I/O thread 5 state: waiting for completed aio requests (read thread)
I/O thread 6 state: waiting for completed aio requests (write thread)
I/O thread 7 state: waiting for completed aio requests (write thread)
I/O thread 8 state: waiting for completed aio requests (write thread)
I/O thread 9 state: waiting for completed aio requests (write thread)
Pending normal aio reads: [0, 0, 0, 0] , aio writes: [0, 0, 0, 0] ,
 ibuf aio reads:, log i/o's:, sync i/o's:
Pending flushes (fsync) log: 0; buffer pool: 0
55966884361 OS file reads, 2648295107 OS file writes, 2057089994 OS fsyncs
1 pending preads, 0 pending pwrites
4321.52 reads/s, 16384 avg bytes/read, 190.96 writes/s, 142.82 fsyncs/s
-------------------------------------
INSERT BUFFER AND ADAPTIVE HASH INDEX
-------------------------------------
Ibuf: size 1, free list len 62231, seg size 62233, 151864864 merges
merged operations:
 insert 325494220, delete mark 303361986, delete 4340936
discarded operations:
 insert 136, delete mark 0, delete 0
Hash table size 796871, node heap has 1268 buffer(s)
Hash table size 796871, node heap has 15 buffer(s)
Hash table size 796871, node heap has 2 buffer(s)
Hash table size 796871, node heap has 2 buffer(s)
Hash table size 796871, node heap has 3 buffer(s)
Hash table size 796871, node heap has 4 buffer(s)
Hash table size 796871, node heap has 18 buffer(s)
Hash table size 796871, node heap has 208 buffer(s)
3741.65 hash searches/s, 3111.39 non-hash searches/s
---
LOG
---
Log sequence number 3507184143569
Log flushed up to   3507184143569
Pages flushed up to 3507109533747
Last checkpoint at  3507099075084
0 pending log flushes, 0 pending chkp writes
1899316448 log i/o's done, 130.59 log i/o's/second
----------------------
BUFFER POOL AND MEMORY
----------------------
Total large memory allocated 3298295808
Dictionary memory allocated 5762760
Buffer pool size   196584
Free buffers       4659
Database pages     190405
Old database pages 70442
Modified db pages  2239
Pending reads      1
Pending writes: LRU 0, flush list 0, single page 0
Pages made young 28317847741, not young 1906159094595
0.00 youngs/s, 0.00 non-youngs/s
Pages read 55967639681, created 411344665, written 689380059
0.00 reads/s, 0.00 creates/s, 0.00 writes/s
Buffer pool hit rate 940 / 1000, young-making rate 7 / 1000 not 343 / 1000
Pages read ahead 0.00/s, evicted without access 0.00/s, Random read ahead 0.00/s
LRU len: 190405, unzip_LRU len: 0
I/O sum[2099200]:cur[16008], unzip sum[0]:cur[0]
----------------------
INDIVIDUAL BUFFER POOL INFO
----------------------
---BUFFER POOL 0
Buffer pool size   24573
Free buffers       585
Database pages     23804
Old database pages 8807
Modified db pages  333
Pending reads      1
Pending writes: LRU 0, flush list 0, single page 0
Pages made young 3502764571, not young 230809434771
0.00 youngs/s, 0.00 non-youngs/s
Pages read 7089307381, created 57728632, written 91750312
0.00 reads/s, 0.00 creates/s, 0.00 writes/s
Buffer pool hit rate 933 / 1000, young-making rate 8 / 1000 not 349 / 1000
Pages read ahead 0.00/s, evicted without access 0.00/s, Random read ahead 0.00/s
LRU len: 23804, unzip_LRU len: 0
I/O sum[262400]:cur[2001], unzip sum[0]:cur[0]
---BUFFER POOL 1
Buffer pool size   24573
Free buffers       536
Database pages     23843
Old database pages 8821
Modified db pages  242
Pending reads      0
Pending writes: LRU 0, flush list 0, single page 0
Pages made young 3533709865, not young 204798884083
0.00 youngs/s, 0.00 non-youngs/s
Pages read 7129829083, created 52354408, written 87390895
0.00 reads/s, 0.00 creates/s, 0.00 writes/s
Buffer pool hit rate 917 / 1000, young-making rate 9 / 1000 not 392 / 1000
Pages read ahead 0.00/s, evicted without access 0.00/s, Random read ahead 0.00/s
LRU len: 23843, unzip_LRU len: 0
I/O sum[262400]:cur[2001], unzip sum[0]:cur[0]
---BUFFER POOL 2
Buffer pool size   24573
Free buffers       393
Database pages     23996
Old database pages 8877
Modified db pages  162
Pending reads      0
Pending writes: LRU 0, flush list 0, single page 0
Pages made young 3525340339, not young 254711421490
0.00 youngs/s, 0.00 non-youngs/s
Pages read 7075240756, created 48760256, written 81890892
0.00 reads/s, 0.00 creates/s, 0.00 writes/s
Buffer pool hit rate 920 / 1000, young-making rate 8 / 1000 not 405 / 1000
Pages read ahead 0.00/s, evicted without access 0.00/s, Random read ahead 0.00/s
LRU len: 23996, unzip_LRU len: 0
I/O sum[262400]:cur[2001], unzip sum[0]:cur[0]
---BUFFER POOL 3
Buffer pool size   24573
Free buffers       384
Database pages     23995
Old database pages 8877
Modified db pages  331
Pending reads      0
Pending writes: LRU 0, flush list 0, single page 0
Pages made young 3530033608, not young 273231823280
0.00 youngs/s, 0.00 non-youngs/s
Pages read 6981359911, created 49273054, written 85043694
0.00 reads/s, 0.00 creates/s, 0.00 writes/s
Buffer pool hit rate 940 / 1000, young-making rate 6 / 1000 not 331 / 1000
Pages read ahead 0.00/s, evicted without access 0.00/s, Random read ahead 0.00/s
LRU len: 23995, unzip_LRU len: 0
I/O sum[262400]:cur[2001], unzip sum[0]:cur[0]
---BUFFER POOL 4
Buffer pool size   24573
Free buffers       641
Database pages     23740
Old database pages 8783
Modified db pages  129
Pending reads      0
Pending writes: LRU 0, flush list 0, single page 0
Pages made young 3622087338, not young 218918745733
0.00 youngs/s, 0.00 non-youngs/s
Pages read 6545549615, created 49882197, written 87187000
0.00 reads/s, 0.00 creates/s, 0.00 writes/s
Buffer pool hit rate 964 / 1000, young-making rate 4 / 1000 not 200 / 1000
Pages read ahead 0.00/s, evicted without access 0.00/s, Random read ahead 0.00/s
LRU len: 23740, unzip_LRU len: 0
I/O sum[262400]:cur[2001], unzip sum[0]:cur[0]
---BUFFER POOL 5
Buffer pool size   24573
Free buffers       800
Database pages     23575
Old database pages 8722
Modified db pages  292
Pending reads      0
Pending writes: LRU 0, flush list 0, single page 0
Pages made young 3572500313, not young 212843803272
0.00 youngs/s, 0.00 non-youngs/s
Pages read 6886746235, created 51032030, written 86116329
0.00 reads/s, 0.00 creates/s, 0.00 writes/s
Buffer pool hit rate 921 / 1000, young-making rate 11 / 1000 not 400 / 1000
Pages read ahead 0.00/s, evicted without access 0.00/s, Random read ahead 0.00/s
LRU len: 23575, unzip_LRU len: 0
I/O sum[262400]:cur[2001], unzip sum[0]:cur[0]
---BUFFER POOL 6
Buffer pool size   24573
Free buffers       617
Database pages     23763
Old database pages 8791
Modified db pages  329
Pending reads      0
Pending writes: LRU 0, flush list 0, single page 0
Pages made young 3535652675, not young 253150304747
0.00 youngs/s, 0.00 non-youngs/s
Pages read 7038859994, created 52461566, written 87559680
0.00 reads/s, 0.00 creates/s, 0.00 writes/s
Buffer pool hit rate 952 / 1000, young-making rate 6 / 1000 not 405 / 1000
Pages read ahead 0.00/s, evicted without access 0.00/s, Random read ahead 0.00/s
LRU len: 23763, unzip_LRU len: 0
I/O sum[262400]:cur[2001], unzip sum[0]:cur[0]
---BUFFER POOL 7
Buffer pool size   24573
Free buffers       703
Database pages     23689
Old database pages 8764
Modified db pages  421
Pending reads      0
Pending writes: LRU 0, flush list 0, single page 0
Pages made young 3495759032, not young 257694677219
0.00 youngs/s, 0.00 non-youngs/s
Pages read 7220746706, created 49852522, written 82441257
0.00 reads/s, 0.00 creates/s, 0.00 writes/s
Buffer pool hit rate 933 / 1000, young-making rate 10 / 1000 not 384 / 1000
Pages read ahead 0.00/s, evicted without access 0.00/s, Random read ahead 0.00/s
LRU len: 23689, unzip_LRU len: 0
I/O sum[262400]:cur[2001], unzip sum[0]:cur[0]
--------------
ROW OPERATIONS
--------------
2 queries inside InnoDB, 0 queries in queue
2 read views open inside InnoDB
Process ID=2108, Main thread ID=140058535225088, state: sleeping
Number of rows inserted 53669677428, updated 2060125221, deleted 408123861, read 5520108629530
3582.59 inserts/s, 133.50 updates/s, 0.11 deletes/s, 211021.14 reads/s
----------------------------
END OF INNODB MONITOR OUTPUT
============================
```





### 1. **Free buffers 数量较少**

在 `SHOW ENGINE INNODB STATUS` 输出中的 `Buffer Pool and Memory` 部分，您会看到如下信息：

```
----------------------
BUFFER POOL AND MEMORY
----------------------
Total large memory allocated 3298295808
Dictionary memory allocated 5762760
Buffer pool size   196584
Free buffers       4659
Database pages     190405
Old database pages 70442
Modified db pages  2239
Pending reads      1
Pending writes: LRU 0, flush list 0, single page 0
Pages made young 28317847741, not young 1906159094595
0.00 youngs/s, 0.00 non-youngs/s
Pages read 55967639681, created 411344665, written 689380059
0.00 reads/s, 0.00 creates/s, 0.00 writes/s
Buffer pool hit rate 940 / 1000, young-making rate 7 / 1000 not 343 / 1000
Pages read ahead 0.00/s, evicted without access 0.00/s, Random read ahead 0.00/s
LRU len: 190405, unzip_LRU len: 0
I/O sum[2099200]:cur[16008], unzip sum[0]:cur[0]
```

- **`Buffer pool size`**：缓冲池的总大小（单位通常为页），通常建议设置为服务器总内存的 60%-70%。
- **`Free buffers`**：当前缓冲池中空闲的缓冲页数量。
- **`Database pages`**：缓冲池中已经加载的数据库页的数量。
- **`Modified db pages`**：被修改但尚未写回磁盘的脏页数量。

**如果 `Free buffers` 数量较少，意味着缓冲池正在使用大部分内存。可能的原因包括：**

```powershell
# `Free buffers` 数量为2%，比例少，建议增加innodb_buffer_pool_size
PS C:\Users\user> 4659/196584 * 100
2.36997924551337
```

- **`innodb_buffer_pool_size` 配置过小**：如果缓冲池过小，MySQL就需要频繁从磁盘加载数据，导致I/O瓶颈，影响性能。
- **工作集较大**：如果您的数据库非常大，或者有大量活跃数据集，可能需要更大的缓冲池。

**解决方案：**

- **增加 `innodb_buffer_pool_size`**：您可以通过增大 `innodb_buffer_pool_size` 来提供更多内存用于缓冲池。例如，如果服务器有 64GB 内存，可以考虑将缓冲池大小设置为 40GB 到 45GB。

  ```
  innodb_buffer_pool_size = 45G
  ```

  增加缓冲池大小后，`Free buffers` 数量应当增加，表示有更多的空间可以用来缓存数据。

  

### 2. **Database pages 和 Modified db pages 的比例**

- **`Database pages`**：表示缓冲池中加载的页数。
- **`Modified db pages`**：表示已经被修改但尚未刷写回磁盘的脏页。

如果 `Modified db pages` 的比例过高，可能会影响数据库的性能，尤其是：

- **增加磁盘I/O**：脏页需要定期刷写回磁盘，过多的脏页可能会导致I/O延迟。
- **崩溃恢复时间长**：在崩溃恢复时，未写回磁盘的脏页需要重新写入，这会增加恢复时间。

```powershell
# Modified db pages的比例为1%，比例不高
PS C:\Users\user> 2239/190405 * 100
1.17591449804364
```

**解决方案：**

- **调整 `innodb_flush_log_at_trx_commit`**：此参数控制 InnoDB 如何将日志刷写到磁盘。默认值为 `1`，意味着每次事务提交时都会将日志写入磁盘。如果系统中 `Modified db pages` 比较多，且 `innodb_flush_log_at_trx_commit` 设置为 `1`，可以考虑将其设置为 `2` 或 `0` 来减少磁盘I/O的频率：

  - **`innodb_flush_log_at_trx_commit = 1`**：每次事务提交时，日志都会写入磁盘，提供最强的数据持久性保证（适用于高事务一致性要求的场景）。
  - **`innodb_flush_log_at_trx_commit = 2`**：日志缓冲区每秒刷新一次，而不是每次事务提交时刷新。这会减少磁盘I/O的次数，但在崩溃时可能会丢失最近的事务。
  - **`innodb_flush_log_at_trx_commit = 0`**：日志缓冲区仅在事务提交时刷新，但只有当日志刷新到磁盘时，才会保证数据一致性。这是最快的选项，但风险较高。

  示例：

  ```
  innodb_flush_log_at_trx_commit = 2
  ```

- **调整 `innodb_flush_method`**：使用 `O_DIRECT` 刷写日志可以减少操作系统缓存的干扰，改善性能。默认情况下，InnoDB使用操作系统的缓存来写入日志。如果I/O瓶颈明显，可以考虑设置：

  ```
  innodb_flush_method = O_DIRECT
  ```

- **调整 `innodb_log_file_size` 和 `innodb_log_files_in_group`**：增大日志文件大小和日志文件数量有助于减少频繁的日志刷新操作，从而降低磁盘I/O负载。您可以考虑增大这些值：

  ```
  innodb_log_file_size = 512M
  innodb_log_files_in_group = 3
  ```



### 3. **调优缓冲池的其他参数**

除了 `innodb_buffer_pool_size`，还有一些其他参数可以帮助调优缓冲池的表现：

- **`innodb_buffer_pool_instances`**：当 `innodb_buffer_pool_size` 较大时，启用多个缓冲池实例可以提高并发性能。通常，每个实例的大小不应超过 1GB。

  ```
  innodb_buffer_pool_instances = 8
  ```

- **`innodb_buffer_pool_chunk_size`**：决定每个缓冲池实例分配的内存块大小。大内存块可以减少内存碎片，但可能会影响内存的管理效率。

  ```
  innodb_buffer_pool_chunk_size = 128M
  ```



###  **4. 监控和优化**

- **监控缓冲池命中率**：使用 `SHOW STATUS LIKE 'Innodb_buffer_pool_read%'` 可以查看缓冲池的命中率：

  ```sql
  SHOW STATUS LIKE 'Innodb_buffer_pool_read%';
  ```

  - `Innodb_buffer_pool_reads`：从磁盘读取的数据页数量。
  - `Innodb_buffer_pool_read_requests`：缓冲池的读取请求数量。

  通过比较这两个指标，您可以估算出缓冲池的命中率。如果命中率较低，表示缓冲池的大小不足，可能需要增大 `innodb_buffer_pool_size`。

  ```sql
  Variable_name	Value
  Innodb_buffer_pool_read_ahead_rnd	0
  Innodb_buffer_pool_read_ahead	1503497106
  Innodb_buffer_pool_read_ahead_evicted	1963700
  Innodb_buffer_pool_read_requests	4349996785073
  Innodb_buffer_pool_reads	54330211073
  ```

  ```powershell
  # 读请求命中率为1.24%，应该增加innodb_buffer_pool_size大小
  PS C:\Users\user> 54328830364/4349900219578 * 100
  1.24896727790392
  ```

- **`SHOW STATUS LIKE 'Innodb_buffer_pool_wait%'`**：可以查看缓冲池的等待情况。如果等待过多，可能意味着缓冲池的内存过小。**此参数有用**

  ```sql
  Variable_name	Value
  Innodb_buffer_pool_wait_free	299524
  ```

  

### 总结

- 如果 `Free buffers` 数量较少，可能需要增加 `innodb_buffer_pool_size`，以提供更多的缓冲池内存，减少磁盘I/O。
- 如果 `Modified db pages` 比例过高，可以调整 `innodb_flush_log_at_trx_commit` 等参数来减少磁盘I/O压力，平衡性能和数据一致性。
- 适当增加 `innodb_log_file_size`、`innodb_log_files_in_group` 和调整缓冲池实例数，能进一步优化缓冲池的性能。





## mysql死锁

### 1. innodb status

```sql
> SHOW ENGINE INNODB STATUS\G
------------------------
LATEST DETECTED DEADLOCK
------------------------
2024-12-31 12:34:56 0x7f8f8400c700
*** (1) TRANSACTION:
TRANSACTION 12345, ACTIVE 5 sec starting index read
mysql tables in use 1, locked 1
LOCK WAIT 4 lock struct(s), heap size 1136, 2 row lock(s)
MySQL thread id 101, OS thread handle 123456789, query id 456 localhost root updating
UPDATE your_table SET column = value WHERE id = 'A'
*** (1) WAITING FOR THIS LOCK TO BE GRANTED:
RECORD LOCKS space id 789 page no 3 n bits 72 index `PRIMARY` of table `your_schema`.`your_table` trx id 12345 lock_mode X locks rec but not gap waiting
*** (2) TRANSACTION:
TRANSACTION 67890, ACTIVE 5 sec starting index read
mysql tables in use 1, locked 1
4 lock struct(s), heap size 1136, 2 row lock(s)
MySQL thread id 102, OS thread handle 987654321, query id 789 localhost root updating
UPDATE your_table SET column = value WHERE id = 'B'
*** (2) HOLDS THE LOCK(S):
RECORD LOCKS space id 789 page no 3 n bits 72 index `PRIMARY` of table `your_schema`.`your_table` trx id 67890 lock_mode X locks rec but not gap
*** (2) WAITING FOR THIS LOCK TO BE GRANTED:
RECORD LOCKS space id 789 page no 3 n bits 72 index `PRIMARY` of table `your_schema`.`your_table` trx id 67890 lock_mode X locks rec but not gap waiting
*** WE ROLL BACK TRANSACTION (1)
```

从上面的输出中，我们可以看到两个事务（TRANSACTION 12345 和 TRANSACTION 67890）互相等待对方持有的锁，从而导致了死锁。

关键部分解释如下：

1. **事务信息**:

   - ```
     TRANSACTION 12345, ACTIVE 5 sec starting index read
     ```

     - `TRANSACTION 12345` 是第一个事务的ID。
     - `TRANSACTION 67890` 是第二个事务的ID。

   - `MySQL thread id 101` 和 `MySQL thread id 102` 分别是与这些事务关联的MySQL线程ID。

   - `OS thread handle` 是操作系统级别的线程句柄，但通常不需要用来手动结束事务。

2. **等待的锁**:

   - 第一个事务在等待锁：`WAITING FOR THIS LOCK TO BE GRANTED`
   - 第二个事务也在等待锁：`WAITING FOR THIS LOCK TO BE GRANTED`
   - 描述了两个事务各自持有的锁和等待的锁。

3. **解决方案**:

   - InnoDB 选择回滚第一个事务：`WE ROLL BACK TRANSACTION (1)`



### 2. 手动结束死锁事务

如果需要手动结束一个死锁事务，可以按照以下步骤进行操作：

1. **获取事务ID**：从 `SHOW ENGINE INNODB STATUS` 的输出中找到死锁的事务ID（如 12345 和 67890）。

2. **查找 MySQL 线程ID**：使用以下查询找到与事务ID对应的 MySQL 线程ID：

   ```sql
   SELECT trx_id, trx_mysql_thread_id 
   FROM information_schema.innodb_trx 
   WHERE trx_id IN (12345, 67890);
   ```

3. **终止事务**：使用 `KILL` 命令终止相应的 MySQL 线程：

   ```sql
   KILL 101;  -- 终止事务ID为12345的线程
   KILL 102;  -- 终止事务ID为67890的线程
   ```

这样可以手动结束死锁事务。



















# MariaDB

## 1.用户创建和授权

```mysql
MariaDB [(none)]> create user 'admin'@'localhost' identified via unix_socket or mysql_native_password using password('pass');
MariaDB [(none)]> grant all on *.* to 'admin'@'localhost' with grant option;
MariaDB [(none)]> show grants for 'admin'@'localhost'\G
*************************** 1. row ***************************
Grants for admin@localhost: GRANT ALL PRIVILEGES ON *.* TO `admin`@`localhost` IDENTIFIED VIA unix_socket OR mysql_native_password USING '*32A74631B3D01D69B36739B9FB9AB85FDFC9BF3A' WITH GRANT OPTION
```



### 1.1 默认认证机制：`unix_socket`插件

1. **认证插件的作用**
   MariaDB从10.4版本开始，默认将`root@localhost`账户的认证方式设置为`unix_socket`。此插件通过操作系统的用户身份验证机制（如Unix域套接字）自动授权用户，无需密码：
   - **本地连接时**：当用户以系统`root`身份运行`mysql -u root`命令时，`unix_socket`插件会检查当前操作系统的用户ID（UID）是否与数据库账户关联的用户名匹配。若匹配，则直接授权访问。
   - **远程TCP/IP连接时**：需使用密码或其他认证方式（如`mysql_native_password`），因为`unix_socket`仅适用于本地套接字连接。
2. **Debian/Ubuntu系统的特殊配置**
   在Debian系发行版中，MariaDB默认将`root@localhost`绑定到`unix_socket`认证。这种设计旨在简化系统维护任务（如日志轮换、服务启停），并增强安全性，因为只有系统`root`用户才能以数据库`root`身份登录，避免了密码泄露风险。
3. **IDENTIFIED VIA与USE的语法冲突**
   - `IDENTIFIED VIA` 是MariaDB特有的语法，用于指定认证插件（如`unix_socket`或`mysql_native_password`），而MySQL中使用`IDENTIFIED WITH`。
   - `use password('pass')`存在拼写错误，正确语法应为`USING PASSWORD('pass')`。
4. **多认证插件的兼容性**
   - 在**MariaDB 10.4+**中支持通过`OR`逻辑指定多个认证插件（如同时允许Unix套接字和密码登录），但MySQL仅支持单一认证插件。
5. **WITH GRANT OPTION的位置错误**
   - `WITH GRANT OPTION`应作为`GRANT`语句的独立子句，而非附加在认证配置后。
6. **PASSWORD()函数的弃用问题**
   - `PASSWORD()`函数在MySQL 5.7+已弃用，直接使用明文密码即可。



## 1.2 使用指定认证插件登录

```sh
$ mysql -u admin -p --protocol=tcp --default-auth=mysql_native_password
```



### 1.3 重新初始化mariadb

```sh
# 重新初始化
mariadb-install-db \
  --user=mysql \
  --datadir=/var/lib/mysql \
  --auth-root-authentication-method=normal  

# 是否除匿名用户、是否开启unix_socket、配置'root'@'localhost'密码
/usr/bin/mariadb-secure-installation
```

