#postgreSQL
<pre>
#数据库热度排行榜地址：
https://db-engines.com/en/ranking
https://hellogithub.com/report/db-engines/?url=/periodical/volume/66/
#postgresql中文文档
http://www.postgres.cn/docs/10/functions.html

#postgresql安装
sudo apt-get install -y postgresql
#更改监听地址
[postgres@ceph02 ~]$ vim /etc/postgresql/10/main/postgresql.conf 
listen_addresses = '0.0.0.0' 
#配置pg_hba.conf使用户可以远程登录
[postgres@ceph02 ~]$ vim /etc/postgresql/10/main/pg_hba.conf 
host    all             all             all                     md5
[postgres@ceph02 ~]$ systemctl restart postgresql
#刚安装好postgresql时postgres用户默认使用空密码登录。
[root@ceph02 ~]# sudo -i -u postgres
[postgres@ceph02 ~]$ psql -U postgres   --使用用户postgres进行登录 
postgres=# alter user postgres password 'ubuntu';

#查看数据库版本
[root@ceph02 ~]# psql --version
psql (PostgreSQL) 10.18 (Ubuntu 10.18-0ubuntu0.18.04.1)

#列出数据库
[root@ceph02 ~]# psql -l
psql: FATAL:  role "root" does not exist
#安装postgresql时默认会创建postgre用户，这个用户是postgresql的超级管理员用户
[root@ceph02 ~]# sudo su - postgres 
[postgres@ceph02 ~]$ psql -l
                             List of databases
   Name    |  Owner   | Encoding | Collate | Ctype |   Access privileges   
-----------+----------+----------+---------+-------+-----------------------
 postgres  | postgres | LATIN1   | en_US   | en_US | 
 template0 | postgres | LATIN1   | en_US   | en_US | =c/postgres          +
           |          |          |         |       | postgres=CTc/postgres
 template1 | postgres | LATIN1   | en_US   | en_US | =c/postgres          +
           |          |          |         |       | postgres=CTc/postgres

#新建jackDB数据库
[postgres@ceph02 ~]$ createdb jackDB
或者
CREATE DATABASE "jackDB"
    WITH 
    OWNER = postgres
    ENCODING = 'LATIN1'
    LC_COLLATE = 'en_US'
    LC_CTYPE = 'en_US'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;


[postgres@ceph02 ~]$ psql -l
                             List of databases
   Name    |  Owner   | Encoding | Collate | Ctype |   Access privileges   
-----------+----------+----------+---------+-------+-----------------------
 jackDB    | postgres | LATIN1   | en_US   | en_US | 
 postgres  | postgres | LATIN1   | en_US   | en_US | 
 template0 | postgres | LATIN1   | en_US   | en_US | =c/postgres          +
           |          |          |         |       | postgres=CTc/postgres
 template1 | postgres | LATIN1   | en_US   | en_US | =c/postgres          +
           |          |          |         |       | postgres=CTc/postgres

#进入命令行并打开jackDB数据库
[postgres@ceph02 ~]$ psql jackdb    #区分大小写
psql: FATAL:  database "jackdb" does not exist
[postgres@ceph02 ~]$ psql jackDB
psql (10.18 (Ubuntu 10.18-0ubuntu0.18.04.1))
Type "help" for help.
jackDB=# 

#获取帮助
jackDB=# help
You are using psql, the command-line interface to PostgreSQL.
Type:  \copyright for distribution terms
       \h for help with SQL commands
       \? for help with psql commands
       \g or terminate with semicolon to execute query   #执行上一次命令
       \q to quit

#使用函数
jackDB=# select now();
            now             
----------------------------
 2021-10-14 20:22:20.336+08

jackDB=# select version();
                                                               version                                                                
--------------------------------------------------------------------------------------------------------------------------------------
 PostgreSQL 10.18 (Ubuntu 10.18-0ubuntu0.18.04.1) on x86_64-pc-linux-gnu, compiled by gcc (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0, 64-bit

#删除数据库
[postgres@ceph02 ~]$ dropdb jackDB
[postgres@ceph02 ~]$ psql -l
                             List of databases
   Name    |  Owner   | Encoding | Collate | Ctype |   Access privileges   
-----------+----------+----------+---------+-------+-----------------------
 postgres  | postgres | LATIN1   | en_US   | en_US | 
 template0 | postgres | LATIN1   | en_US   | en_US | =c/postgres          +
           |          |          |         |       | postgres=CTc/postgres
 template1 | postgres | LATIN1   | en_US   | en_US | =c/postgres          +
           |          |          |         |       | postgres=CTc/postgres


#操作数据表
[root@ceph02 ~]# su - postgres 
[postgres@ceph02 ~]$ createdb jackDB
[postgres@ceph02 ~]$ psql jackDB
#获取sql命令帮助
jackDB=# \h create
#进一步缩小命令帮助范围在表
jackDB=# \h create table    
#新建表
jackDB=# create table posts(title varchar(255), content text);
#显示当前数据库所有表
jackDB=# \dt
         List of relations
 Schema | Name  | Type  |  Owner   
--------+-------+-------+----------
 public | posts | table | postgres
#查看指定表结构
jackDB=# \d posts
                       Table "public.posts"
 Column  |          Type          | Collation | Nullable | Default 
---------+------------------------+-----------+----------+---------
 title   | character varying(255) |           |          | 
 content | text                   |           |          | 
#更改表名称
jackDB=# alter table posts rename to jackposts;
#查看重命名表名称
jackDB=# \dt
           List of relations
 Schema |   Name    | Type  |  Owner   
--------+-----------+-------+----------
 public | jackposts | table | postgres
#删除表
jackDB=# drop table jackposts;
#查看所有表，已无表
jackDB=# \dt
Did not find any relations.
#配置sql文件，使用命令批量导入
[postgres@ceph02 ~]$ cat jackDB_posts.sql
create table posts(title varchar(25), content text);
#切换数据库
postgres-# \connect jackDB
You are now connected to database "jackDB" as user "postgres".
#列出所有表
jackDB-# \dt
Did not find any relations.
#从sql文件中导入sql语句
jackDB-# \i jackDB_posts.sql;
#文件中sql语句是创建表，执行成功后查看表已经存在
jackDB-# \dt
         List of relations
 Schema | Name  | Type  |  Owner   
--------+-------+-------+----------
 public | posts | table | postgres
#查看当前的连接信息
jackDB-# \conninfo 
You are connected to database "jackDB" as user "postgres" via socket in "/var/run/postgresql" at port "5432".


#字段类型
1. sql标准类型
2. 特色类型
  2.1 Array
  2.2 网络地址类型(inet)
  2.3 Json类型
  2.4 xml类型

#表约束
#新建表
create table posts(
  id serial primary key,
  title varchar(255) not null,
  content text check(length(content) > 3),
  is_draft boolean default TRUE,
  is_del boolean default FALSE,
  created_date timestamp default 'now'
);
#查看表结构
jackDB=# \d posts;
                                                     Table "public.posts"
    Column    |            Type             | Collation | Nullable |                          Default                          
--------------+-----------------------------+-----------+----------+-----------------------------------------------------------
 id           | integer                     |           | not null | nextval('posts_id_seq'::regclass)
 title        | character varying(255)      |           | not null | 
 content      | text                        |           |          | 
 is_draft     | boolean                     |           |          | true
 is_del       | boolean                     |           |          | false
 created_date | timestamp without time zone |           |          | '2021-10-14 21:04:48.040029'::timestamp without time zone
Indexes:
    "posts_pkey" PRIMARY KEY, btree (id)
Check constraints:
    "posts_content_check" CHECK (length(content) > 3)

#插入数据
jackDB=# insert into posts values (1,'jack','helloWorld!'),(2,'candy','helloJack!');
#切换输出显示是列或者行显示
#jackDB=# \x
Expanded display is off.
#查询数据
jackDB=# select * from posts;
 id | title |   content   | is_draft | is_del |        created_date        
----+-------+-------------+----------+--------+----------------------------
  1 | jack  | helloWorld! | t        | f      | 2021-10-14 21:04:48.040029
  2 | candy | helloJack!  | t        | f      | 2021-10-14 21:04:48.040029

#变更表结构
jackDB=# \d posts
                                                     Table "public.posts"
    Column    |            Type             | Collation | Nullable |                          Default                          
--------------+-----------------------------+-----------+----------+-----------------------------------------------------------
 id           | integer                     |           | not null | nextval('posts_id_seq'::regclass)
 title        | character varying(255)      |           | not null | 
 content      | text                        |           |          | 
 is_draft     | boolean                     |           |          | true
 is_del       | boolean                     |           |          | false
 created_date | timestamp without time zone |           |          | '2021-10-14 21:04:48.040029'::timestamp without time zone
Indexes:
    "posts_pkey" PRIMARY KEY, btree (id)
Check constraints:
    "posts_content_check" CHECK (length(content) > 3)
jackDB=# alter table posts alter content type varchar(1000);
ALTER TABLE
jackDB=# \d posts
                                                     Table "public.posts"
    Column    |            Type             | Collation | Nullable |                          Default                          
--------------+-----------------------------+-----------+----------+-----------------------------------------------------------
 id           | integer                     |           | not null | nextval('posts_id_seq'::regclass)
 title        | character varying(255)      |           | not null | 
 content      | character varying(1000)     |           |          | 
 is_draft     | boolean                     |           |          | true
 is_del       | boolean                     |           |          | false
 created_date | timestamp without time zone |           |          | '2021-10-14 21:04:48.040029'::timestamp without time zone
Indexes:
    "posts_pkey" PRIMARY KEY, btree (id)
Check constraints:
    "posts_content_check" CHECK (length(content::text) > 3)
jackDB=# alter table posts rename content to info;
ALTER TABLE
jackDB=# alter table posts add age int;
jackDB=# alter table posts drop age;
jackDB=# create index info_index on posts(info);
jackDB=# \d posts
                                                     Table "public.posts"
    Column    |            Type             | Collation | Nullable |                          Default                          
--------------+-----------------------------+-----------+----------+-----------------------------------------------------------
 id           | integer                     |           | not null | nextval('posts_id_seq'::regclass)
 title        | character varying(255)      |           | not null | 
 info         | character varying(1000)     |           |          | 
 is_draft     | boolean                     |           |          | true
 is_del       | boolean                     |           |          | false
 created_date | timestamp without time zone |           |          | '2021-10-14 21:04:48.040029'::timestamp without time zone
Indexes:
    "posts_pkey" PRIMARY KEY, btree (id)
    "info_index" btree (info)
Check constraints:
    "posts_content_check" CHECK (length(info::text) > 3)
jackDB=# drop index info_index;

#使用视图
jackDB=# select * from posts;
 id | title |    info     | is_draft | is_del |        created_date        
----+-------+-------------+----------+--------+----------------------------
  1 | jack  | helloWorld! | t        | f      | 2021-10-14 21:04:48.040029
  2 | candy | helloJack!  | t        | f      | 2021-10-14 21:04:48.040029
#新建视图
jackDB=# create view test_view as select * from posts where title='jack';
CREATE VIEW
jackDB=# select * from test_view;
 id | title |    info     | is_draft | is_del |        created_date        
----+-------+-------------+----------+--------+----------------------------
  1 | jack  | helloWorld! | t        | f      | 2021-10-14 21:04:48.040029
#更新表数据
jackDB=# update posts set info='hehe' where title='jack';
UPDATE 1
#数据也会更新
jackDB=# select * from test_view;
 id | title | info | is_draft | is_del |        created_date        
----+-------+------+----------+--------+----------------------------
  1 | jack  | hehe | t        | f      | 2021-10-14 21:04:48.040029
#因为视图创建的条件是title='jack'，所以这个条件一变就没有数据了
jackDB=# update posts set title='Bob' where info='hehe';
UPDATE 1
jackDB=# select * from test_view;
 id | title | info | is_draft | is_del | created_date 
----+-------+------+----------+--------+--------------
(0 rows)
jackDB=# select * from test_view;
 id | title | info | is_draft | is_del |        created_date        
----+-------+------+----------+--------+----------------------------
  1 | jack  | hehe | t        | f      | 2021-10-14 21:04:48.040029

#使用事务
begin    或者   start transaction
commit 
savepoint name_1
rollback   或者   rollback to savepoint 
#应用事务
jackDB=# select * from posts;
 id | title |    info    | is_draft | is_del |        created_date        
----+-------+------------+----------+--------+----------------------------
  2 | candy | helloJack! | t        | f      | 2021-10-14 21:04:48.040029
  1 | jack  | hehe       | t        | f      | 2021-10-14 21:04:48.040029
(2 rows)
jackDB=# begin;
BEGIN
jackDB=# update posts set info='www.mi.com' where title='candy'; update posts set info='mi.com' where title='jack';
UPDATE 1
UPDATE 1
jackDB=# commit;
COMMIT
jackDB=# select * from posts;
 id | title |    info    | is_draft | is_del |        created_date        
----+-------+------------+----------+--------+----------------------------
  2 | candy | www.mi.com | t        | f      | 2021-10-14 21:04:48.040029
  1 | jack  | mi.com     | t        | f      | 2021-10-14 21:04:48.040029
#回滚事务
jackDB=# begin;
BEGIN
jackDB=# update posts set info='Hello World!' where title='candy';                                                   
UPDATE 1
jackDB=# select * from posts;
 id | title |     info     | is_draft | is_del |        created_date        
----+-------+--------------+----------+--------+----------------------------
  1 | jack  | mi.com       | t        | f      | 2021-10-14 21:04:48.040029
  2 | candy | Hello World! | t        | f      | 2021-10-14 21:04:48.040029
(2 rows)

jackDB=# rollback;
ROLLBACK
jackDB=# select * from posts;
 id | title |    info    | is_draft | is_del |        created_date        
----+-------+------------+----------+--------+----------------------------
  2 | candy | www.mi.com | t        | f      | 2021-10-14 21:04:48.040029
  1 | jack  | mi.com     | t        | f      | 2021-10-14 21:04:48.040029
#回滚事务
jackDB=# select * from posts;
 id | title |   info    | is_draft | is_del |        created_date        
----+-------+-----------+----------+--------+----------------------------
  1 | jack  | mi.com    | t        | f      | 2021-10-14 21:04:48.040029
  2 | candy | baidu.com | t        | f      | 2021-10-14 21:04:48.040029
(2 rows)

jackDB=# update posts set info='google.com' where title='candy';
UPDATE 1
jackDB=# select * from posts;
 id | title |    info    | is_draft | is_del |        created_date        
----+-------+------------+----------+--------+----------------------------
  1 | jack  | mi.com     | t        | f      | 2021-10-14 21:04:48.040029
  2 | candy | google.com | t        | f      | 2021-10-14 21:04:48.040029
(2 rows)

jackDB=# savepoint google;
SAVEPOINT
jackDB=# update posts set info='www.google.com' where title='jack';
UPDATE 1
jackDB=# savepoint google_2;
SAVEPOINT
jackDB=# select * from posts;    
 id | title |      info      | is_draft | is_del |        created_date        
----+-------+----------------+----------+--------+----------------------------
  2 | candy | google.com     | t        | f      | 2021-10-14 21:04:48.040029
  1 | jack  | www.google.com | t        | f      | 2021-10-14 21:04:48.040029
jackDB=# rollback to savepoint google;
ROLLBACK
jackDB=# select * from posts;
 id | title |    info    | is_draft | is_del |        created_date        
----+-------+------------+----------+--------+----------------------------
  1 | jack  | mi.com     | t        | f      | 2021-10-14 21:04:48.040029
  2 | candy | google.com | t        | f      | 2021-10-14 21:04:48.040029
#回滚到最初
jackDB=# rollback; 
ROLLBACK
jackDB=# select * from posts;
 id | title |   info    | is_draft | is_del |        created_date        
----+-------+-----------+----------+--------+----------------------------
  1 | jack  | mi.com    | t        | f      | 2021-10-14 21:04:48.040029
  2 | candy | baidu.com | t        | f      | 2021-10-14 21:04:48.040029



#权限管理
注：postgresql中用户跟角色是绑定的，当你创建角色或者用户时会一起创建，是如果是纯角色可以不授予登录，如果是普通用户需要授予登录 
--创建角色 
CREATE ROLE "jack" LOGIN PASSWORD 'jack';
--更改角色密码
ALTER ROLE "jack" PASSWORD 'jackli';
--可以创建数据库
ALTER ROLE "jack" CREATEDB;
--可以创建角色
ALTER ROLE "jack" CREATEROLE;
--设置为超级用户
ALTER ROLE "jack" SUPERUSER;
--可以复制
ALTER ROLE "jack" REPLICATION;
--可以继承权限 
ALTER ROLE "jack" INHERIT;
--不能继承权限
ALTER ROLE "jack" NOINHERIT;
--可以绕过RLS
ALTER ROLE "jack" BYPASSRLS;
--更改用户连接数为100（不限制为-1），密码改为jackli并且加密(加密方式有ENCRYPTED,UNENCRYPTED和空)，角色有效期到'2021-10-16 11:32:19'
ALTER ROLE "jack" CONNECTION LIMIT 100 ENCRYPTED PASSWORD 'jackli' VALID UNTIL '2021-10-16 11:32:19';
--超级用户
CREATE ROLE "test" SUPERUSER CREATEDB CREATEROLE LOGIN REPLICATION BYPASSRLS CONNECTION LIMIT 100 ENCRYPTED PASSWORD 'test' VALID UNTIL '2021-10-22 11:38:11';
--将角色jack赋予给test用户
GRANT "jack" TO "test";
--从test01用户移除角色jack
REVOKE "jack" FROM "test01";
#命令注解
#\h create user; 和 \h create role;      -- CREATE USER和CREATE ROLE的区别在于，CREATE USER指令创建的用户默认是有登录权限的，而CREATE ROLE没有。
IN ROLE role_name 和IN GROUP role_name效果一样，表示将当前角色加入到role_name中
ROLE role_name 和 USER role_name效果一样，表示将角色role_name加入当前角色中
ADMIN role_name表示将角色role_name加入当前角色中并赋予管理权限 

--新建用户test
jackDB=# create user test createdb createrole inherit replication bypassrls connection limit 10 encrypted password 'test' valid until '2030-01-01 00:00';
--新建用户test01并且加入角色jack中
jackDB=# create user test01 createdb createrole inherit replication bypassrls connection limit 10 encrypted password 'test' valid until '2030-01-01 00:00' in role jack;
--新建用户test02并且加入角色jack中，并且设置nologin，role和group相同
jackDB=# create user test02 createdb createrole nologin inherit replication bypassrls connection limit 10 encrypted password 'test' valid until '2030-01-01 00:00' in group jack;
--为test02开启登录，密码为上面创建test02时的密码
jackDB=# alter user test02 login;
--新建用户test03并且将jack角色加入test03角色中
postgres=# create user test03 createdb createrole inherit replication bypassrls connection limit 10 encrypted password 'test' valid until '2030-01-01 00:00' role jack;
--授予角色权限 
GRANT UPDATE ON demo TO demo_role; --赋予demo_role demo表的update权限
GRANT SELECT ON ALL TABLES IN SCHEMA PUBLIC to demo_role; --赋予demo_role所有表的SELECT权限
特殊符号:ALL代表所访问权限，PUBLIC代表所有用户
GRANT ALL ON demo TO demo_role; --将demo表的所有权限赋给特定用户
GRANT SELECT ON demo TO PUBLIC; --将demo表的SELECT权限赋给所有用户
\z或\dp指令显示用户访问权限。

#切换用户
jackDB=# set role test03;   --切换到用户test03
SET
jackDB=> select user;   --查看当前用户
  user  
--------
 test03
jackDB=> select * from posts;     --test03无权限查看
ERROR:  permission denied for relation posts
jackDB=> reset role;    --回到最原始（第一个）的用户
RESET
jackDB=# select * from current_user;
 current_user 
--------------
 postgres

#新建zabbix库为例 
jackDB=# create user zabbix;
jackDB=# create database zabbix owner zabbix;
jackDB=# alter user zabbix with password 'zabbix';
jackDB=# grant all on database zabbix to zabbix;    --授予zabbix有create,connect,temporary权限
-- zabbix=# revoke all on database zabbix from zabbix;
[postgres@ceph02 ~]$ psql -U zabbix -W -h 192.168.13.32 -d zabbix
zabbix=> \dp
                             Access privileges
 Schema |  Name  | Type  | Access privileges | Column privileges | Policies 
--------+--------+-------+-------------------+-------------------+----------
 public | test01 | table |                   |                   | 
zabbix=> select * from test01;
ERROR:  permission denied for relation test01
-- 因为test01表不是zabbix创建，所以需要使用超级管理员进行授予权限，
jackDB=# \c zabbix;
zabbix=# grant all on all tables in schema public to zabbix;    --进入zabbix数据库，授予zabbix数据库中架构schema中的所有表所有权限给zabbix用户
zabbix=# revoke delete,insert,references,select,trigger,truncate,update on test01 from "zabbix";   --从zabbix库中针对test01表从用户zabbix移除特定权限
jackDB=> revoke all on all tables in schema public from zabbix;    --从jackDB库中针对所有表从用户zabbix移除特定权限
注：只要是超级管理员，就可以取消postgres超级管理员权限 

#查看用户系统权限
1、查看某用户的系统权限
SELECT * FROM pg_roles WHERE rolname='postgres';
2、查看某用户的表权限
select * from information_schema.table_privileges where grantee='postgres';
3、查看某用户的usage权限
select * from information_schema.usage_privileges where grantee='postgres';
4、查看某用户在存储过程函数的执行权限
select * from information_schema.routine_privileges where grantee='postgres';
5、查看某用户在某表的列上的权限
select * from information_schema.column_privileges where grantee='postgres';
6、查看当前用户能够访问的数据类型
select * from information_schema.data_type_privileges ;
7、查看用户自定义类型上授予的USAGE权限
select * from information_schema.udt_privileges where grantee='postgres';
#都在两张表中
select * from information_schema
select * from pg_catalog.pg_roles;

--查询所有表
select * from pg_tables where SCHEMAname='public'
--查看指定表结构
select * from information_schema.columns where table_schema='public' and TABLE_NAME='posts' limit 10;






#编译安装postgresql
https://ftp.postgresql.org/pub/source/v10.18/postgresql-10.18.tar.bz2
[root@ceph03 /download]#axel -n 30 postgresql-10.18.tar.bz2 https://ftp.postgresql.org/pub/source/v10.18/postgresql-10.18.tar.bz2
#新增一个操作pg的用户postgres
[root@ceph03 ~]# groupadd db
[root@ceph03 ~]# useradd -m -d /home/postgres -g db -s /bin/bash postgres
[root@ceph03 ~]# echo 'postgres:postgres' | chpasswd 
安装依赖包：
[root@ceph03 /download]# sudo apt-get install -y libreadline-dev zlib1g-dev gcc make 
[root@ceph03 /download]# tar xf postgresql-10.18.tar.bz2 
[root@ceph03 /download]# cd postgresql-10.18/
[root@ceph03 /download/postgresql-10.18]# ./configure --prefix=/opt/postgresql/10.18
[root@ceph03 /download/postgresql-10.18]# make && make install
[root@ceph03 ~]# chown -R postgres /opt/postgresql/
#初始化数据库
[root@ceph03 /download/postgresql-10.18]# su - postgres
postgres@ceph03:~$ vim .bash_profile
------
#表示pg安装的目录，和--prefix的目录一致
PGHOME=/opt/postgresql/10.18
export PGHOME
#pg数据目录，在初始化数据库时如果没有指定目录，则选择环境变量中的目录
PGDATA=/opt/postgresql/10.18/data
export PGDATA
PATH=$PATH:$HOME/bin:$PGHOME/bin
export PATH
------
postgres@ceph03:~$ source .bash_profile
postgres@ceph03:~$ initdb -D /opt/postgresql/10.18/data 
#启动和连接
postgres@ceph03:/opt/postgresql/10.18$ vim /opt/postgresql/10.18/data/postgresql.conf
listen_addresses = '0.0.0.0'
postgres@ceph03:/opt/postgresql/10.18$ vim /opt/postgresql/10.18/data/pg_hba.conf
host    all             all             all                     trust
注：执行pg_ctl reload 或者 SELECT pg_reload_conf()
postgres@ceph03:/opt/postgresql/10.18$ mkdir -p /opt/postgresql/10.18/logs
postgres@ceph03:/opt/postgresql/10.18$ pg_ctl -D /opt/postgresql/10.18/data -l /opt/postgresql/10.18/logs/logfile start
postgres@ceph03:/opt/postgresql/10.18$ netstat -tnlp | grep :5432
tcp        0      0 0.0.0.0:5432            0.0.0.0:*               LISTEN      23489/postgres     
--使用linux用户postgres进行登录postgresql，此linux用户有访问posgresql根目录权限，所以进行时不用密码，而-U postgres用户是postgresql默认的超级管理员，密码为空，以下登录并设置密码
postgres@ceph03:/opt/postgresql/10.18$ psql -U postgres  
psql (10.18)
Type "help" for help.
postgres=# alter user postgres with password 'postgres';
#postgresql数据库运行管理
[postgres@ceph03 ~]$ pg_ctl start
[postgres@ceph03 ~]$ pg_ctl stop
[postgres@ceph03 ~]$ pg_ctl status
[postgres@ceph03 ~]$ pg_ctl reload   











</pre>