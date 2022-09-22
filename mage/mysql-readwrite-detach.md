# mysql双主双从集群



## 环境信息

| ip           | role    | hostname      | slave            | master   |
| ------------ | ------- | ------------- | ---------------- | -------- |
| 172.168.2.35 | master01| mysql-master01| master02,slave01 | master02 |
| 172.168.2.34 | master02| mysql-master02| master01,slave02 | master01 |
| 172.168.2.32 | slave01 | mysql-slave01 |                  | master01 |
| 172.168.2.31 | slave02 | mysql-slave02 |                  | master02 |

## 部署mysql集群

#### 配置hosts及时间同步
```
root@ansible:~# ansible mysql -m shell -a 'cat > /etc/hosts << EOF
> 127.0.0.1       localhost
> 172.168.2.35 mysql-master01
> 172.168.2.34 mysql-master02
> 172.168.2.32 mysql-slave01
> 172.168.2.31 mysql-slave02
> '

root@ansible:~# ansible mysql -m shell -a 'cat /etc/hosts'
172.168.2.34 | SUCCESS | rc=0 >>
 127.0.0.1 localhost
 172.168.2.35 mysql-master01
 172.168.2.34 mysql-master02
 172.168.2.32 mysql-slave01
 172.168.2.31 mysql-slave02

172.168.2.35 | SUCCESS | rc=0 >>
 127.0.0.1 localhost
 172.168.2.35 mysql-master01
 172.168.2.34 mysql-master02
 172.168.2.32 mysql-slave01
 172.168.2.31 mysql-slave02

172.168.2.31 | SUCCESS | rc=0 >>
 127.0.0.1 localhost
 172.168.2.35 mysql-master01
 172.168.2.34 mysql-master02
 172.168.2.32 mysql-slave01
 172.168.2.31 mysql-slave02

172.168.2.32 | SUCCESS | rc=0 >>
 127.0.0.1 localhost
 172.168.2.35 mysql-master01
 172.168.2.34 mysql-master02
 172.168.2.32 mysql-slave01
 172.168.2.31 mysql-slave02

root@ansible:~# ansible mysql -m shell -a 'date'
172.168.2.35 | SUCCESS | rc=0 >>
Wed Sep 14 16:44:10 CST 2022

172.168.2.34 | SUCCESS | rc=0 >>
Wed Sep 14 16:44:10 CST 2022

172.168.2.31 | SUCCESS | rc=0 >>
Wed Sep 14 16:44:10 CST 2022

172.168.2.32 | SUCCESS | rc=0 >>
Wed Sep 14 16:44:10 CST 2022
```

#### 安装mysql
```
root@ansible:/etc/ansible/roles/mysql# ansible mysql -m shell -a 'ss -tnl | grep :3306'
172.168.2.31 | SUCCESS | rc=0 >>
LISTEN   0         90                  0.0.0.0:3306             0.0.0.0:*

172.168.2.32 | SUCCESS | rc=0 >>
LISTEN   0         90                  0.0.0.0:3306             0.0.0.0:*

172.168.2.35 | SUCCESS | rc=0 >>
LISTEN   0         90                  0.0.0.0:3306             0.0.0.0:*

172.168.2.34 | SUCCESS | rc=0 >>
LISTEN   0         90                  0.0.0.0:3306             0.0.0.0:*
# 配置所有节点密码为 test1234
root@mysql-master01:~# cat /root/.mysql_secret
X#s?=w1XatZ6
root@mysql-master01:~# mysql -uroot -p
Enter password:
mysql> alter user root@'localhost' identified by 'test1234';	

```

#### 配置mysql双主双从集群

##### 配置双主集群
```
# 172.168.2.35 和 172.168.2.34为双主，可以读写

# 172.168.2.35配置并重启服务
root@mysql-master01:~# cat /etc/my.cnf
[mysqld]
#skip-grant-tables = 1
#skip-slave-start = 1
skip-name-resolve=1
datadir = /data/mysql
basedir = /usr/local/mysql
socket=/usr/local/mysql/mysql.sock
pid-file=/data/mysql/mysql.pid
gtid-mode=on
enforce-gtid-consistency=true
master-info-repository=TABLE
relay-log-info-repository=TABLE
sync-master-info=1
slave-parallel-workers=4
binlog-checksum=CRC32
master-verify-checksum=1
slave-sql-verify-checksum=1
binlog_format = ROW
log-bin=master-bin	# **
log-bin-index=master-bin.index # **
character-set-server=utf8mb4
relay-log=relay-master
relay-log-index=relay-master.index
slow_query_log_file = /data/mysql/mysql-slow.log
slow_query_log = 1
log_error = /data/mysql/mysql.err
innodb_file_per_table=1
auto-increment-increment = 2 # ID increment number **
auto-increment-offset=1 # init ID number **
server-id = 10
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
default-storage-engine = InnoDB
default-tmp-storage-engine = InnoDB
internal-tmp-disk-storage-engine = InnoDB
innodb-buffer-pool-chunk-size = 134217728
innodb-buffer-pool-instances = 1
#innodb-buffer-pool-size = 3221225472
#innodb-buffer-pool-size = 5G * innodb-buffer-pool-chunk-size * innodb-buffer-pool-instances
sync-binlog = 1	# **
log-slave-updates = 1  #multi level copy **
lower-case-table-names = 1
innodb-flush-method=O_DIRECT
max-connections=500
wait-timeout=3600
innodb-thread-concurrency=16
innodb-log-buffer-size=32M
innodb-log-file-size=100M
innodb-log-files-in-group=3
bind-address=0.0.0.0
port=3306
transaction-isolation=READ-COMMITTED

[client]
default-character-set = utf8mb4
socket=/usr/local/mysql/mysql.sock
---
root@mysql-master01:~# service mysqld restart
root@mysql-master01:~# ss -tnl | grep :3306
LISTEN   0         128                 0.0.0.0:3306             0.0.0.0:*


# 172.168.2.34配置并重启服务
root@mysql-master02:~# cat /etc/my.cnf
[mysqld]
skip-name-resolve=1
datadir = /data/mysql
basedir = /usr/local/mysql
socket=/usr/local/mysql/mysql.sock
pid-file=/data/mysql/mysql.pid
gtid-mode=on
enforce-gtid-consistency=true
master-info-repository=TABLE
relay-log-info-repository=TABLE
sync-master-info=1
slave-parallel-workers=4
binlog-checksum=CRC32
master-verify-checksum=1
slave-sql-verify-checksum=1
binlog_format = ROW
log-bin=master-bin	# **
log-bin-index=master-bin.index	#**
character-set-server=utf8mb4
relay-log=relay-master
relay-log-index=relay-master.index
slow_query_log_file = /data/mysql/mysql-slow.log
slow_query_log = 1
log_error = /data/mysql/mysql.err
innodb_file_per_table=1
auto-increment-increment = 2 # ID increment number **
auto-increment-offset=2 # init ID number **
server-id = 20
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
default-storage-engine = InnoDB
default-tmp-storage-engine = InnoDB
internal-tmp-disk-storage-engine = InnoDB
innodb-buffer-pool-chunk-size = 134217728
innodb-buffer-pool-instances = 1
#innodb-buffer-pool-size = 3221225472
#innodb-buffer-pool-size = 5G * innodb-buffer-pool-chunk-size * innodb-buffer-pool-instances
sync-binlog = 1	#**
log-slave-updates = 1  #multi level copy **
lower-case-table-names = 1
innodb-flush-method=O_DIRECT
max-connections=500
wait-timeout=3600
innodb-thread-concurrency=16
innodb-log-buffer-size=32M
innodb-log-file-size=100M
innodb-log-files-in-group=3
bind-address=0.0.0.0
port=3306
transaction-isolation=READ-COMMITTED

[client]
default-character-set = utf8mb4
socket=/usr/local/mysql/mysql.sock
---
root@mysql-master02:~# service mysqld restart
root@mysql-master02:~# ss -tnl | grep :3306
LISTEN   0         128                 0.0.0.0:3306             0.0.0.0:*




### 配置mysql-master01和mysql-master02双主集群配置

# mysql-master01配置用户权限及滚动二进制日志
mysql> grant replication slave on *.* to repluser@'172.168.2.%' identified by 'ER02BFDuGofk9XX5';
mysql> flush privileges;
mysql> show grants for repluser@'172.168.2.%';
+------------------------------------------------------------+
| Grants for repluser@172.168.2.%                            |
+------------------------------------------------------------+
| GRANT REPLICATION SLAVE ON *.* TO 'repluser'@'172.168.2.%' |
+------------------------------------------------------------+
mysql> flush binary logs;
mysql> show master status;
+-------------------+----------+--------------+------------------+--------------------------------------------+
| File              | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set                          |
+-------------------+----------+--------------+------------------+--------------------------------------------+
| master-bin.000013 |      194 |              |                  | 6f827b18-3026-11ed-b3fb-000c296de557:1-129 |
+-------------------+----------+--------------+------------------+--------------------------------------------+

# mysql-master02配置用户权限及滚动二进制日志
mysql> grant replication slave on *.* to repluser@'172.168.2.%' identified by 'ER02BFDuGofk9XX5';
mysql> flush privileges;
mysql> show grants for repluser@'172.168.2.%';
+------------------------------------------------------------+
| Grants for repluser@172.168.2.%                            |
+------------------------------------------------------------+
| GRANT REPLICATION SLAVE ON *.* TO 'repluser'@'172.168.2.%' |
+------------------------------------------------------------+
mysql> flush binary logs;
mysql> show master status;
+-------------------+----------+--------------+------------------+--------------------------------------------+
| File              | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set                          |
+-------------------+----------+--------------+------------------+--------------------------------------------+
| master-bin.000019 |      194 |              |                  | 6f8269d5-3026-11ed-b17a-000c29e6b41f:1-126 |
+-------------------+----------+--------------+------------------+--------------------------------------------+

## 配置mysql-master01和mysql-master02集群配置
# mysql-master01
mysql> change master to master_host='172.168.2.34',master_user='repluser',master_password='ER02BFDuGofk9XX5',master_log_file='master-bin.000019',MASTER_LOG_POS=194;
# mysql-master02
mysql> change master to master_host='172.168.2.35',master_user='repluser',master_password='ER02BFDuGofk9XX5',master_log_file='master-bin.000013',MASTER_LOG_POS=194;

# 查看集群状态(mysql-master01)
mysql> show master status\G
*************************** 1. row ***************************
             File: master-bin.000013
         Position: 194
     Binlog_Do_DB:
 Binlog_Ignore_DB:
Executed_Gtid_Set: 6f827b18-3026-11ed-b3fb-000c296de557:1-129

mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State:
                  Master_Host: 172.168.2.34
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000019
          Read_Master_Log_Pos: 194
               Relay_Log_File: relay-master.000001
                Relay_Log_Pos: 4
        Relay_Master_Log_File: master-bin.000019
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
            Executed_Gtid_Set: 6f827b18-3026-11ed-b3fb-000c296de557:1-129
                Auto_Position: 0
         Replicate_Rewrite_DB:
                 Channel_Name:
           Master_TLS_Version:

# 查看集群状态(mysql-master02)
mysql> show master status\G
*************************** 1. row ***************************
             File: master-bin.000019
         Position: 194
     Binlog_Do_DB:
 Binlog_Ignore_DB:
Executed_Gtid_Set: 6f8269d5-3026-11ed-b17a-000c29e6b41f:1-126

mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State:
                  Master_Host: 172.168.2.35
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000013
          Read_Master_Log_Pos: 194
               Relay_Log_File: relay-master.000001
                Relay_Log_Pos: 4
        Relay_Master_Log_File: master-bin.000013
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
            Executed_Gtid_Set: 6f8269d5-3026-11ed-b17a-000c29e6b41f:1-126
                Auto_Position: 0
         Replicate_Rewrite_DB:
                 Channel_Name:
           Master_TLS_Version:

# 启动slave线程(mysql-master01)
mysql> start slave;
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 172.168.2.34
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000019
          Read_Master_Log_Pos: 194
               Relay_Log_File: relay-master.000002
                Relay_Log_Pos: 321
        Relay_Master_Log_File: master-bin.000019
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
             Master_Server_Id: 20
                  Master_UUID: 6f8269d5-3026-11ed-b17a-000c29e6b41f
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
            Executed_Gtid_Set: 6f827b18-3026-11ed-b3fb-000c296de557:1-129
                Auto_Position: 0
         Replicate_Rewrite_DB:
                 Channel_Name:
           Master_TLS_Version:

# 启动slave线程(mysql-master02)
mysql> start slave;
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 172.168.2.35
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000013
          Read_Master_Log_Pos: 194
               Relay_Log_File: relay-master.000002
                Relay_Log_Pos: 321
        Relay_Master_Log_File: master-bin.000013
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
             Master_Server_Id: 10
                  Master_UUID: 6f827b18-3026-11ed-b3fb-000c296de557
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
            Executed_Gtid_Set: 6f8269d5-3026-11ed-b17a-000c29e6b41f:1-126
                Auto_Position: 0
         Replicate_Rewrite_DB:
                 Channel_Name:
           Master_TLS_Version:

# 创建数据库、表并进行插入测试
mysql> show databases;	#master01
+--------------------+
| Database           |
+--------------------+
| information_schema |
| ms                 |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
mysql> show databases;	#master02
+--------------------+
| Database           |
+--------------------+
| information_schema |
| ms                 |
| mysql              |
| performance_schema |
| sys                |
+--------------------+

# 创建表(master01)
CREATE TABLE `ms`.`province`  (
  `Id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '名称',
  `NameEn` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `Status` smallint(4) NOT NULL COMMENT '状态，1=启用 0=禁用',
  `CreateUser` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '创建人',
  `CreateTime` datetime(6) NOT NULL COMMENT '创建时间',
  `UpdateUser` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '最后修改人',
  `UpdateTime` datetime(6) NULL DEFAULT NULL COMMENT '修改时间',
  `IsDelete` tinyint(1) NOT NULL COMMENT '0 未删除 1 已删除',
  PRIMARY KEY (`Id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 54 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

# 查看表(master02)
mysql> show tables from ms;
+--------------+
| Tables_in_ms |
+--------------+
| province     |
+--------------+

# master01插入数据
mysql> use ms;
mysql> INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (1, '', 'Beijing', 1, '', '2021-01-26 17:49:11.000000', NULL, NULL, 0);
mysql> select * from province;
+----+------+---------+--------+------------+----------------------------+------------+------------+----------+
| Id | Name | NameEn  | Status | CreateUser | CreateTime                 | UpdateUser | UpdateTime | IsDelete |
+----+------+---------+--------+------------+----------------------------+------------+------------+----------+
|  1 |      | Beijing |      1 |            | 2021-01-26 17:49:11.000000 | NULL       | NULL       |        0 |
+----+------+---------+--------+------------+----------------------------+------------+------------+----------+

# master02插入数据
mysql> INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (2, '', 'Shanghai', 1, '', '2021-01-26 17:49:11.000000', NULL, NULL, 0);
mysql> INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (3, '', 'Tianjin', 1, '', '2021-01-26 17:49:11.000000', NULL, NULL, 0);
mysql> INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (4, '', 'Chongqing', 1, '', '2021-01-26 17:49:11.000000', NULL, NULL, 0);
mysql> select * from province;
+----+------+-----------+--------+------------+----------------------------+------------+------------+----------+
| Id | Name | NameEn    | Status | CreateUser | CreateTime                 | UpdateUser | UpdateTime | IsDelete |
+----+------+-----------+--------+------------+----------------------------+------------+------------+----------+
|  1 |      | Beijing   |      1 |            | 2021-01-26 17:49:11.000000 | NULL       | NULL       |        0 |
|  2 |      | Shanghai  |      1 |            | 2021-01-26 17:49:11.000000 | NULL       | NULL       |        0 |
|  3 |      | Tianjin   |      1 |            | 2021-01-26 17:49:11.000000 | NULL       | NULL       |        0 |
|  4 |      | Chongqing |      1 |            | 2021-01-26 17:49:11.000000 | NULL       | NULL       |        0 |
+----+------+-----------+--------+------------+----------------------------+------------+------------+----------+
# master01查看数据
mysql> select * from province;
+----+------+-----------+--------+------------+----------------------------+------------+------------+----------+
| Id | Name | NameEn    | Status | CreateUser | CreateTime                 | UpdateUser | UpdateTime | IsDelete |
+----+------+-----------+--------+------------+----------------------------+------------+------------+----------+
|  1 |      | Beijing   |      1 |            | 2021-01-26 17:49:11.000000 | NULL       | NULL       |        0 |
|  2 |      | Shanghai  |      1 |            | 2021-01-26 17:49:11.000000 | NULL       | NULL       |        0 |
|  3 |      | Tianjin   |      1 |            | 2021-01-26 17:49:11.000000 | NULL       | NULL       |        0 |
|  4 |      | Chongqing |      1 |            | 2021-01-26 17:49:11.000000 | NULL       | NULL       |        0 |
+----+------+-----------+--------+------------+----------------------------+------------+------------+----------+

# master01删除"天津"数据
mysql> delete from province where nameEn = 'Tianjin';
mysql> select * from province;
+----+------+-----------+--------+------------+----------------------------+------------+------------+----------+
| Id | Name | NameEn    | Status | CreateUser | CreateTime                 | UpdateUser | UpdateTime | IsDelete |
+----+------+-----------+--------+------------+----------------------------+------------+------------+----------+
|  1 |      | Beijing   |      1 |            | 2021-01-26 17:49:11.000000 | NULL       | NULL       |        0 |
|  2 |      | Shanghai  |      1 |            | 2021-01-26 17:49:11.000000 | NULL       | NULL       |        0 |
|  4 |      | Chongqing |      1 |            | 2021-01-26 17:49:11.000000 | NULL       | NULL       |        0 |
+----+------+-----------+--------+------------+----------------------------+------------+------------+----------+
# master02查看
mysql> select * from province;
+----+------+-----------+--------+------------+----------------------------+------------+------------+----------+
| Id | Name | NameEn    | Status | CreateUser | CreateTime                 | UpdateUser | UpdateTime | IsDelete |
+----+------+-----------+--------+------------+----------------------------+------------+------------+----------+
|  1 |      | Beijing   |      1 |            | 2021-01-26 17:49:11.000000 | NULL       | NULL       |        0 |
|  2 |      | Shanghai  |      1 |            | 2021-01-26 17:49:11.000000 | NULL       | NULL       |        0 |
|  4 |      | Chongqing |      1 |            | 2021-01-26 17:49:11.000000 | NULL       | NULL       |        0 |
+----+------+-----------+--------+------------+----------------------------+------------+------------+----------+

# 至此，mysql双主集群已经完毕，接下来配置双从节点。

```

#### 配置mysql-slave01和mysql-slave02双从节点
```
# mysql-slave01
root@mysql-slave01:/data/mysql# cat /etc/my.cnf
[mysqld]
super_read_only=1 # slave require, admin user not change slave node, enable super_read_only == enable read_only
read_only=1 # slave require, general user not change slave node
skip-name-resolve=1
datadir = /data/mysql
basedir = /usr/local/mysql
socket=/usr/local/mysql/mysql.sock
pid-file=/data/mysql/mysql.pid
gtid-mode=on
enforce-gtid-consistency=true
master-info-repository=TABLE
relay-log-info-repository=TABLE
sync-master-info=1
slave-parallel-workers=4
binlog-checksum=CRC32
master-verify-checksum=1
slave-sql-verify-checksum=1
binlog_format = ROW
#log-bin=master-bin # close binlog, slave not require
#log-bin-index=master-bin.index
character-set-server=utf8mb4
relay-log=relay-master
relay-log-index=relay-master.index
slow_query_log_file = /data/mysql/mysql-slow.log
slow_query_log = 1
log_error = /data/mysql/mysql.err
innodb_file_per_table=1
#auto-increment-increment = 2 # ID increment number
#auto-increment-offset=1 # init ID number
server-id = 110
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
default-storage-engine = InnoDB
default-tmp-storage-engine = InnoDB
internal-tmp-disk-storage-engine = InnoDB
innodb-buffer-pool-chunk-size = 134217728
innodb-buffer-pool-instances = 1
#innodb-buffer-pool-size = 3221225472
#innodb-buffer-pool-size = 5G * innodb-buffer-pool-chunk-size * innodb-buffer-pool-instances
sync-binlog = 1
log-slave-updates = 0  # multi level copy, slave not require
lower-case-table-names = 1
innodb-flush-method=O_DIRECT
max-connections=500
wait-timeout=3600
innodb-thread-concurrency=16
innodb-log-buffer-size=32M
innodb-log-file-size=100M
innodb-log-files-in-group=3
bind-address=0.0.0.0
port=3306
transaction-isolation=READ-COMMITTED

[client]
default-character-set = utf8mb4
socket=/usr/local/mysql/mysql.sock
---
root@mysql-slave01:~# service mysqld restart
root@mysql-slave01:/data/mysql# ss -tnl | grep :3306
LISTEN   0         128                 0.0.0.0:3306             0.0.0.0:*

mysql> show global variables like '%log%';
+--------------------------------------------+--------------------------------+
| Variable_name                              | Value                          |
+--------------------------------------------+--------------------------------+
| back_log                                   | 150                            |
| binlog_cache_size                          | 32768                          |
| binlog_checksum                            | CRC32                          |
| binlog_direct_non_transactional_updates    | OFF                            |
| binlog_error_action                        | ABORT_SERVER                   |
| binlog_format                              | ROW                            |
| binlog_group_commit_sync_delay             | 0                              |
| binlog_group_commit_sync_no_delay_count    | 0                              |
| binlog_gtid_simple_recovery                | ON                             |
| binlog_max_flush_queue_time                | 0                              |
| binlog_order_commits                       | ON                             |
| binlog_row_image                           | FULL                           |
| binlog_rows_query_log_events               | OFF                            |
| binlog_stmt_cache_size                     | 32768                          |
| binlog_transaction_dependency_history_size | 25000                          |
| binlog_transaction_dependency_tracking     | COMMIT_ORDER                   |
| expire_logs_days                           | 0                              |
| general_log                                | OFF                            |
| general_log_file                           | /data/mysql/mysql-slave01.log  |
| innodb_api_enable_binlog                   | OFF                            |
| innodb_flush_log_at_timeout                | 1                              |
| innodb_flush_log_at_trx_commit             | 1                              |
| innodb_locks_unsafe_for_binlog             | OFF                            |
| innodb_log_buffer_size                     | 33554432                       |
| innodb_log_checksums                       | ON                             |
| innodb_log_compressed_pages                | ON                             |
| innodb_log_file_size                       | 104857600                      |
| innodb_log_files_in_group                  | 3                              |
| innodb_log_group_home_dir                  | ./                             |
| innodb_log_write_ahead_size                | 8192                           |
| innodb_max_undo_log_size                   | 1073741824                     |
| innodb_online_alter_log_max_size           | 134217728                      |
| innodb_undo_log_truncate                   | OFF                            |
| innodb_undo_logs                           | 128                            |
| log_bin                                    | OFF                            |
| log_bin_basename                           |                                |
| log_bin_index                              |                                |
| log_bin_trust_function_creators            | OFF                            |
| log_bin_use_v1_row_events                  | OFF                            |
| log_builtin_as_identified_by_password      | OFF                            |
| log_error                                  | /data/mysql/mysql.err          |
| log_error_verbosity                        | 3                              |
| log_output                                 | FILE                           |
| log_queries_not_using_indexes              | OFF                            |
| log_slave_updates                          | OFF                            |
| log_slow_admin_statements                  | OFF                            |
| log_slow_slave_statements                  | OFF                            |
| log_statements_unsafe_for_binlog           | ON                             |
| log_syslog                                 | OFF                            |
| log_syslog_facility                        | daemon                         |
| log_syslog_include_pid                     | ON                             |
| log_syslog_tag                             |                                |
| log_throttle_queries_not_using_indexes     | 0                              |
| log_timestamps                             | UTC                            |
| log_warnings                               | 2                              |
| max_binlog_cache_size                      | 18446744073709547520           |
| max_binlog_size                            | 1073741824                     |
| max_binlog_stmt_cache_size                 | 18446744073709547520           |
| max_relay_log_size                         | 0                              |
| relay_log                                  | relay-master                   |
| relay_log_basename                         | /data/mysql/relay-master       |
| relay_log_index                            | /data/mysql/relay-master.index |
| relay_log_info_file                        | relay-log.info                 |
| relay_log_info_repository                  | TABLE                          |
| relay_log_purge                            | ON                             |
| relay_log_recovery                         | OFF                            |
| relay_log_space_limit                      | 0                              |
| slow_query_log                             | ON                             |
| slow_query_log_file                        | /data/mysql/mysql-slow.log     |
| sql_log_off                                | OFF                            |
| sync_binlog                                | 1                              |
| sync_relay_log                             | 10000                          |
| sync_relay_log_info                        | 10000                          |
+--------------------------------------------+--------------------------------+

# mysql-slave02
root@mysql-slave02:~# cat /etc/my.cnf
[mysqld]
super_read_only=1 # slave require, admin user not change slave node, enable super_read_only == enable read_only
read_only=1 # slave require, general user not change slave node
skip-name-resolve=1
datadir = /data/mysql
basedir = /usr/local/mysql
socket=/usr/local/mysql/mysql.sock
pid-file=/data/mysql/mysql.pid
gtid-mode=on
enforce-gtid-consistency=true
master-info-repository=TABLE
relay-log-info-repository=TABLE
sync-master-info=1
slave-parallel-workers=4
binlog-checksum=CRC32
master-verify-checksum=1
slave-sql-verify-checksum=1
binlog_format = ROW
#log-bin=master-bin # close binlog, slave not require
#log-bin-index=master-bin.index
character-set-server=utf8mb4
relay-log=relay-master
relay-log-index=relay-master.index
slow_query_log_file = /data/mysql/mysql-slow.log
slow_query_log = 1
log_error = /data/mysql/mysql.err
innodb_file_per_table=1
#auto-increment-increment = 2 # ID increment number
#auto-increment-offset=1 # init ID number
server-id = 120
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
default-storage-engine = InnoDB
default-tmp-storage-engine = InnoDB
internal-tmp-disk-storage-engine = InnoDB
innodb-buffer-pool-chunk-size = 134217728
innodb-buffer-pool-instances = 1
#innodb-buffer-pool-size = 3221225472
#innodb-buffer-pool-size = 5G * innodb-buffer-pool-chunk-size * innodb-buffer-pool-instances
sync-binlog = 1
log-slave-updates = 0  # multi level copy, slave not require
lower-case-table-names = 1
innodb-flush-method=O_DIRECT
max-connections=500
wait-timeout=3600
innodb-thread-concurrency=16
innodb-log-buffer-size=32M
innodb-log-file-size=100M
innodb-log-files-in-group=3
bind-address=0.0.0.0
port=3306
transaction-isolation=READ-COMMITTED

[client]
default-character-set = utf8mb4
socket=/usr/local/mysql/mysql.sock
---
root@mysql-slave02:~# service mysqld restart
root@mysql-slave02:~# ss -tnl | grep :3306
LISTEN   0         128                 0.0.0.0:3306             0.0.0.0:*


## 配置slave01和slave02两节点的从配置

mysql> show master status;	# master01的主信息
+-------------------+----------+--------------+------------------+------------------------------------------------------------------------------------------+
| File              | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set                                                                        |
+-------------------+----------+--------------+------------------+------------------------------------------------------------------------------------------+
| master-bin.000013 |     2822 |              |                  | 6f8269d5-3026-11ed-b17a-000c29e6b41f:127-129,
6f827b18-3026-11ed-b3fb-000c296de557:1-133 |
+-------------------+----------+--------------+------------------+------------------------------------------------------------------------------------------+


# 配置slave01的主为mysql-master01
mysql> change master to master_host='172.168.2.35',master_user='repluser',master_password='ER02BFDuGofk9XX5',master_log_file='master-bin.000013',MASTER_LOG_POS=194;	#虽然master01的binlog文件位置现在是2822，但是一直在变，我们可以将位置设置为某个文件的初始文件进行同步
mysql> start slave;
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 172.168.2.35
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000013
          Read_Master_Log_Pos: 2822		#已经同步完成
               Relay_Log_File: relay-master.000002
                Relay_Log_Pos: 2949
        Relay_Master_Log_File: master-bin.000013
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
          Exec_Master_Log_Pos: 2822
              Relay_Log_Space: 3153
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
                  Master_UUID: 6f827b18-3026-11ed-b3fb-000c296de557
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
           Retrieved_Gtid_Set: 6f8269d5-3026-11ed-b17a-000c29e6b41f:127-129,
6f827b18-3026-11ed-b3fb-000c296de557:130-133
            Executed_Gtid_Set: 6f8269d5-3026-11ed-b17a-000c29e6b41f:127-129,
6f827b18-3026-11ed-b3fb-000c296de557:130-133,
ae74efaa-3408-11ed-9c87-000c295b580f:1-124
                Auto_Position: 0
         Replicate_Rewrite_DB:
                 Channel_Name:
           Master_TLS_Version:


# 配置slave02的主为mysql-master02
mysql> change master to master_host='172.168.2.34',master_user='repluser',master_password='ER02BFDuGofk9XX5',master_log_file='master-bin.000019',MASTER_LOG_POS=194;
mysql> start slave;
mysql> show slave status \G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 172.168.2.34
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000019
          Read_Master_Log_Pos: 2831		#已经同步完成
               Relay_Log_File: relay-master.000002
                Relay_Log_Pos: 2958
        Relay_Master_Log_File: master-bin.000019
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
          Exec_Master_Log_Pos: 2831
              Relay_Log_Space: 3162
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
                  Master_UUID: 6f8269d5-3026-11ed-b17a-000c29e6b41f
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
           Retrieved_Gtid_Set: 6f8269d5-3026-11ed-b17a-000c29e6b41f:127-129,
6f827b18-3026-11ed-b3fb-000c296de557:130-133
            Executed_Gtid_Set: 544f9c9b-3024-11ed-878b-000c2953a213:1-126,
6f8269d5-3026-11ed-b17a-000c29e6b41f:127-129,
6f827b18-3026-11ed-b3fb-000c296de557:130-133
                Auto_Position: 0
         Replicate_Rewrite_DB:
                 Channel_Name:
           Master_TLS_Version:

# 查看两个slave节点是否同步数据信息
mysql> show databases;	# slave01
+--------------------+
| Database           |
+--------------------+
| information_schema |
| ms                 |	#已经同步数据库及表信息
| mysql              |
| performance_schema |
| sys                |
+--------------------+
mysql> select * from ms.province;
+----+------+-----------+--------+------------+----------------------------+------------+------------+----------+
| Id | Name | NameEn    | Status | CreateUser | CreateTime                 | UpdateUser | UpdateTime | IsDelete |
+----+------+-----------+--------+------------+----------------------------+------------+------------+----------+
|  1 |      | Beijing   |      1 |            | 2021-01-26 17:49:11.000000 | NULL       | NULL       |        0 |
|  2 |      | Shanghai  |      1 |            | 2021-01-26 17:49:11.000000 | NULL       | NULL       |        0 |
|  4 |      | Chongqing |      1 |            | 2021-01-26 17:49:11.000000 | NULL       | NULL       |        0 |
+----+------+-----------+--------+------------+----------------------------+------------+------------+----------+

mysql> show databases;	# slave02
+--------------------+
| Database           |
+--------------------+
| information_schema |
| ms                 |	#已经同步数据库及表信息
| mysql              |
| performance_schema |
| sys                |
+--------------------+
mysql> select * from ms.province;
+----+------+-----------+--------+------------+----------------------------+------------+------------+----------+
| Id | Name | NameEn    | Status | CreateUser | CreateTime                 | UpdateUser | UpdateTime | IsDelete |
+----+------+-----------+--------+------------+----------------------------+------------+------------+----------+
|  1 |      | Beijing   |      1 |            | 2021-01-26 17:49:11.000000 | NULL       | NULL       |        0 |
|  2 |      | Shanghai  |      1 |            | 2021-01-26 17:49:11.000000 | NULL       | NULL       |        0 |
|  4 |      | Chongqing |      1 |            | 2021-01-26 17:49:11.000000 | NULL       | NULL       |        0 |
+----+------+-----------+--------+------------+----------------------------+------------+------------+----------+

# 查看双主集群各自的slave节点信息
# master01--172.168.2.35
mysql> show slave hosts;
+-----------+------+------+-----------+--------------------------------------+
| Server_id | Host | Port | Master_id | Slave_UUID                           |
+-----------+------+------+-----------+--------------------------------------+
|        20 |      | 3306 |        10 | 6f8269d5-3026-11ed-b17a-000c29e6b41f |	#172.168.2.34
|       110 |      | 3306 |        10 | ae74efaa-3408-11ed-9c87-000c295b580f |	#172.168.2.32
+-----------+------+------+-----------+--------------------------------------+
# master02--172.168.2.34
mysql> show slave hosts;
+-----------+------+------+-----------+--------------------------------------+
| Server_id | Host | Port | Master_id | Slave_UUID                           |
+-----------+------+------+-----------+--------------------------------------+
|        10 |      | 3306 |        20 | 6f827b18-3026-11ed-b3fb-000c296de557 |	#172.168.2.35
|       120 |      | 3306 |        20 | 544f9c9b-3024-11ed-878b-000c2953a213 |	#172.168.2.31
+-----------+------+------+-----------+--------------------------------------+

mysql> show global variables like '%server_uuid%';	# master01 uuid
+---------------+--------------------------------------+
| Variable_name | Value                                |
+---------------+--------------------------------------+
| server_uuid   | 6f827b18-3026-11ed-b3fb-000c296de557 |
+---------------+--------------------------------------+

# 查看两个slave是否为只读，不允许写入
mysql> show global variables like '%read_only%';	# slave01
+-----------------------+-------+
| Variable_name         | Value |
+-----------------------+-------+
| innodb_read_only      | OFF   |
| read_only             | ON    |	#已经生效为只读，普通用户级别用户只读
| super_read_only       | ON    |	#已经生效为只读，服务器级别用户只读
| transaction_read_only | OFF   |
| tx_read_only          | OFF   |
+-----------------------+-------+

mysql> show global variables like '%read_only%';	# slave02
+-----------------------+-------+
| Variable_name         | Value |
+-----------------------+-------+
| innodb_read_only      | OFF   |
| read_only             | ON    |	#已经生效为只读，普通用户级别用户只读
| super_read_only       | ON    |	#已经生效为只读，服务器级别用户只读
| transaction_read_only | OFF   |
| tx_read_only          | OFF   |
+-----------------------+-------+


```

#### 测试双主双从集群读写是否同步
```
# 创建远程访问权限的root用户进行测试，在master01或者master02上创建，集群会自动同步
mysql> GRANT SELECT, INSERT, UPDATE, DELETE ON `ms`.* TO 'jack'@'%';		# *.*为服务器级别，ms.*为用户级别
mysql> flush privileges;	# 在navicat中用jack连接master01、master02、slave01、slave02

# 测试slave是否可以写入，在navicat中连接slave01和slave02插入数据皆报read_only错误，如预期所想
INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (5, '黑龙江', 'Heilongjiang', 1, '系统导入', '2021-01-26 17:49:11.000000', NULL, NULL, 0)
> 1290 - The MySQL server is running with the --read-only option so it cannot execute this statement
> 时间: 0.001s

# 测试master是否可以读写，如预期所想可读写
INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (6, '吉林', 'Jilin', 1, '系统导入', '2021-01-26 17:49:11.000000', NULL, NULL, 0)
> Affected rows: 1
> 时间: 0.004s

# 查看数据是否都同步
root@ansible:~# ansible mysql -m shell -a "/usr/local/mysql/bin/mysql -uroot -ptest1234 -e 'select * from ms.province;'"
172.168.2.31 | SUCCESS | rc=0 >>
Id      Name    NameEn  Status  CreateUser      CreateTime      UpdateUser      UpdateTime      IsDelete
1               Beijing 1               2021-01-26 17:49:11.000000      NULL    NULL    0
2               Shanghai        1               2021-01-26 17:49:11.000000      NULL    NULL    0
4               Chongqing       1               2021-01-26 17:49:11.000000      NULL    NULL    0
6       吉林    Jilin   1       系统导入        2021-01-26 17:49:11.000000      NULL    NULL    0mysql: [Warning] Using a password on the command line interface can be insecure.

172.168.2.32 | SUCCESS | rc=0 >>
Id      Name    NameEn  Status  CreateUser      CreateTime      UpdateUser      UpdateTime      IsDelete
1               Beijing 1               2021-01-26 17:49:11.000000      NULL    NULL    0
2               Shanghai        1               2021-01-26 17:49:11.000000      NULL    NULL    0
4               Chongqing       1               2021-01-26 17:49:11.000000      NULL    NULL    0
6       吉林    Jilin   1       系统导入        2021-01-26 17:49:11.000000      NULL    NULL    0mysql: [Warning] Using a password on the command line interface can be insecure.

172.168.2.34 | SUCCESS | rc=0 >>
Id      Name    NameEn  Status  CreateUser      CreateTime      UpdateUser      UpdateTime      IsDelete
1               Beijing 1               2021-01-26 17:49:11.000000      NULL    NULL    0
2               Shanghai        1               2021-01-26 17:49:11.000000      NULL    NULL    0
4               Chongqing       1               2021-01-26 17:49:11.000000      NULL    NULL    0
6       吉林    Jilin   1       系统导入        2021-01-26 17:49:11.000000      NULL    NULL    0mysql: [Warning] Using a password on the command line interface can be insecure.

172.168.2.35 | SUCCESS | rc=0 >>
Id      Name    NameEn  Status  CreateUser      CreateTime      UpdateUser      UpdateTime      IsDelete
1               Beijing 1               2021-01-26 17:49:11.000000      NULL    NULL    0
2               Shanghai        1               2021-01-26 17:49:11.000000      NULL    NULL    0
4               Chongqing       1               2021-01-26 17:49:11.000000      NULL    NULL    0
6       吉林    Jilin   1       系统导入        2021-01-26 17:49:11.000000      NULL    NULL    0mysql: [Warning] Using a password on the command line interface can be insecure.

注：至此，双主双从mysql集群部署完成，接下来需要部署读写分离中间件Mycat-server-1.6.7.5
```


#### mysql双主双从集群错误汇总
```
# 从同步报错，原因是主的binlog执行时出错，有冲突，常常是管理员在slave进行操作了，又在master上操作，而后master同步到slave出错，下面是出错信息
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 172.168.2.34
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000019
          Read_Master_Log_Pos: 3651
               Relay_Log_File: relay-master.000004
                Relay_Log_Pos: 401
        Relay_Master_Log_File: master-bin.000019
             Slave_IO_Running: Yes
            Slave_SQL_Running: No
              Replicate_Do_DB:
          Replicate_Ignore_DB:
           Replicate_Do_Table:
       Replicate_Ignore_Table:
      Replicate_Wild_Do_Table:
  Replicate_Wild_Ignore_Table:
                   Last_Errno: 1396
                   Last_Error: Coordinator stopped because there were error(s) in the worker(s). The most recent failure being: Worker 4 failed executing transaction '6f8269d5-3026-11ed-b17a-000c29e6b41f:130' at master log master-bin.000019, end_log_pos 3011. See error log and/or performance_schema.replication_applier_status_by_worker table for more details about this failure or others, if any.
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 2831
              Relay_Log_Space: 4486
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
               Last_SQL_Errno: 1396
               Last_SQL_Error: Coordinator stopped because there were error(s) in the worker(s). The most recent failure being: Worker 4 failed executing transaction '6f8269d5-3026-11ed-b17a-000c29e6b41f:130' at master log master-bin.000019, end_log_pos 3011. See error log and/or performance_schema.replication_applier_status_by_worker table for more details about this failure or others, if any.
  Replicate_Ignore_Server_Ids:
             Master_Server_Id: 20
                  Master_UUID: 6f8269d5-3026-11ed-b17a-000c29e6b41f
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State:
           Master_Retry_Count: 86400
                  Master_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp: 220915 15:31:20
               Master_SSL_Crl:
           Master_SSL_Crlpath:
           Retrieved_Gtid_Set: 6f8269d5-3026-11ed-b17a-000c29e6b41f:127-133,
6f827b18-3026-11ed-b3fb-000c296de557:130-133
            Executed_Gtid_Set: 544f9c9b-3024-11ed-878b-000c2953a213:1-126,
6f8269d5-3026-11ed-b17a-000c29e6b41f:127-129,
6f827b18-3026-11ed-b3fb-000c296de557:130-133
                Auto_Position: 0
         Replicate_Rewrite_DB:
                 Channel_Name:
           Master_TLS_Version:
# 查看mysql错误日志可以看出来是执行
root@mysql-slave02:/data/mysql# tail mysql.err
2022-09-15T07:31:20.202852Z 6 [ERROR] Slave SQL for channel '': Worker 4 failed executing transaction '6f8269d5-3026-11ed-b17a-000c29e6b41f:130' at master log master-bin.000019, end_log_pos 3011; Error 'Operation DROP USER failed for 'mysql.session'@'localhost'' on query. Default database: 'ms'. Query: 'drop user 'mysql.session'@'localhost'', Error_code: 1396
2022-09-15T07:31:20.202996Z 2 [Warning] Slave SQL for channel '': ... The slave coordinator and worker threads are stopped, possibly leaving data in inconsistent state. A restart should restore consistency automatically, although using non-transactional storage for data or info tables or DDL queries could lead to problems. In such cases you have to examine your data (see documentation for details). Error_code: 1756
2022-09-15T07:31:20.203022Z 2 [Note] Error reading relay log event for channel '': slave SQL thread was killed
2022-09-15T07:31:20.203576Z 2 [Note] Slave SQL thread for channel '' exiting, replication stopped in log 'master-bin.000019' at position 2831

# 解决办法：跳过事务
mysql> stop slave;	#停止IO和SQL线程
mysql> set @@session.gtid_next='6f8269d5-3026-11ed-b17a-000c29e6b41f:131';	#配置当前环境变量gtid_next值，下一个执行的gtid事务，为上方Last_SQL_Error中报错的transaction
mysql> begin;commit;	#提交事务
mysql> set @@session.gtid_next=automatic;	#配置下一个gtid事务为自动，恢复默认值
mysql> start slave;	#启动IO和SQL线程
mysql> show slave status\G	#再次查看信息，还是有错误
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 172.168.2.34
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000019
          Read_Master_Log_Pos: 3651
               Relay_Log_File: relay-master.000004
                Relay_Log_Pos: 401
        Relay_Master_Log_File: master-bin.000019
             Slave_IO_Running: Yes
            Slave_SQL_Running: No
              Replicate_Do_DB:
          Replicate_Ignore_DB:
           Replicate_Do_Table:
       Replicate_Ignore_Table:
      Replicate_Wild_Do_Table:
  Replicate_Wild_Ignore_Table:
                   Last_Errno: 1396
                   Last_Error: Coordinator stopped because there were error(s) in the worker(s). The most recent failure being: Worker 4 failed executing transaction '6f8269d5-3026-11ed-b17a-000c29e6b41f:131' at master log master-bin.000019, end_log_pos 3187. See error log and/or performance_schema.replication_applier_status_by_worker table for more details about this failure or others, if any.
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 2831
              Relay_Log_Space: 4937
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
               Last_SQL_Errno: 1396
               Last_SQL_Error: Coordinator stopped because there were error(s) in the worker(s). The most recent failure being: Worker 4 failed executing transaction '6f8269d5-3026-11ed-b17a-000c29e6b41f:131' at master log master-bin.000019, end_log_pos 3187. See error log and/or performance_schema.replication_applier_status_by_worker table for more details about this failure or others, if any.
  Replicate_Ignore_Server_Ids:
             Master_Server_Id: 20
                  Master_UUID: 6f8269d5-3026-11ed-b17a-000c29e6b41f
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State:
           Master_Retry_Count: 86400
                  Master_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp: 220915 15:48:54
               Master_SSL_Crl:
           Master_SSL_Crlpath:
           Retrieved_Gtid_Set: 6f8269d5-3026-11ed-b17a-000c29e6b41f:127-133,
6f827b18-3026-11ed-b3fb-000c296de557:130-133
            Executed_Gtid_Set: 544f9c9b-3024-11ed-878b-000c2953a213:1-126,
6f8269d5-3026-11ed-b17a-000c29e6b41f:127-130,
6f827b18-3026-11ed-b3fb-000c296de557:130-133
                Auto_Position: 0
         Replicate_Rewrite_DB:
                 Channel_Name:
           Master_TLS_Version:

#继续查看错误日志
root@mysql-slave02:/data/mysql# tail mysql.err
2022-09-15T07:48:54.284339Z 18 [ERROR] Slave SQL for channel '': Worker 4 failed executing transaction '6f8269d5-3026-11ed-b17a-000c29e6b41f:131' at master log master-bin.000019, end_log_pos 3187; Error 'Operation DROP USER failed for 'mysql.sys'@'localhost'' on query. Default database: 'ms'. Query: 'drop user 'mysql.sys'@'localhost'', Error_code: 1396

#继续解决，跳过事务，但是这次错误不是报上次的drop user 'mysql.session'@'localhost'，而是报drop user 'mysql.sys'@'localhost'
mysql> stop slave;	#停止IO和SQL线程
mysql> set @@session.gtid_next='6f8269d5-3026-11ed-b17a-000c29e6b41f:131';	#配置当前环境变量gtid_next值，下一个执行的gtid事务，为上方Last_SQL_Error中报错的transaction
mysql> begin;commit;	#提交事务
mysql> set @@session.gtid_next=automatic;	#配置下一个gtid事务为自动，恢复默认值
mysql> start slave;	#启动IO和SQL线程
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 172.168.2.34
                  Master_User: repluser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master-bin.000019
          Read_Master_Log_Pos: 3651
               Relay_Log_File: relay-master.000006
                Relay_Log_Pos: 401
        Relay_Master_Log_File: master-bin.000019
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
          Exec_Master_Log_Pos: 3651
              Relay_Log_Space: 852
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
                  Master_UUID: 6f8269d5-3026-11ed-b17a-000c29e6b41f
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
           Retrieved_Gtid_Set: 6f8269d5-3026-11ed-b17a-000c29e6b41f:127-133,
6f827b18-3026-11ed-b3fb-000c296de557:130-133
            Executed_Gtid_Set: 544f9c9b-3024-11ed-878b-000c2953a213:1-126,
6f8269d5-3026-11ed-b17a-000c29e6b41f:127-133,
6f827b18-3026-11ed-b3fb-000c296de557:130-133
                Auto_Position: 0
         Replicate_Rewrite_DB:
                 Channel_Name:
           Master_TLS_Version:

注：这次成功了，恢复正常了，原因是在有问题的slave上删除了两个没用的帐户导致slave报错，通过上方跳过这两次事务而正常

另外一种未经过测试的办法：
stop slave;
set global sql_slave_skip_counter = 1;
start slave;
show slave status\G
```






## mycat部署

### 依赖及环境

* 依赖jdk，必须是JDK7或更高版本
* mycat 1.6.7.5下载：axel -n 30 https://github.com/MyCATApache/Mycat-Server/releases/download/Mycat-server-1675-release/Mycat-server-1.6.7.5-release-20200422133810-linux.tar.gz

| ip           | role    |
| ------------ | ------- |
| 172.168.2.35 | mycat01 |
| 172.168.2.34 | mycat02 |

* 参数URL: https://www.cnblogs.com/kevingrace/p/9365840.html


### 安装openJDK
root@ansible:/etc/ansible/roles/mysql/tasks# ansible '~172.168.2.3[54]' -m shell -a 'apt install -y openjdk-8-jdk'
root@ansible:/etc/ansible/roles/mysql/tasks# ansible '~172.168.2.3[54]' -m shell -a 'dpkg -l | grep openjdk-8-jdk'
172.168.2.35 | SUCCESS | rc=0 >>
ii  openjdk-8-jdk:amd64                    8u342-b07-0ubuntu1~18.04                        amd64        OpenJDK Development Kit (JDK)
ii  openjdk-8-jdk-headless:amd64           8u342-b07-0ubuntu1~18.04                        amd64        OpenJDK Development Kit (JDK) (headless)

172.168.2.34 | SUCCESS | rc=0 >>
ii  openjdk-8-jdk:amd64                    8u342-b07-0ubuntu1~18.04                        amd64        OpenJDK Development Kit (JDK)
ii  openjdk-8-jdk-headless:amd64           8u342-b07-0ubuntu1~18.04                        amd64        OpenJDK Development Kit (JDK) (headless)


### 实现mysql多主多从读写分离

### 安装配置mycat
```
root@mysql-master01:/download# tar xf Mycat-server-1.6.7.5-release-20200422133810-linux.tar.gz -C /usr/local/
root@mysql-master01:/download# ls /usr/local/mycat/
bin  catlet  conf  lib  version.txt
root@mysql-master01:/download# useradd mycat	#创建用户
root@mysql-master01:/download# echo 'mycat:mycat123' | chpasswd
root@mysql-master01:/usr/local/mycat# mkdir /usr/local/mycat/logs
root@mysql-master01:/download# chown -R mycat.mycat /usr/local/mycat/
root@mysql-master01:/download# ll -d /usr/local/mycat/
drwxr-xr-x 6 mycat mycat 73 Sep 15 17:26 /usr/local/mycat//
root@mysql-master01:/usr/local/mycat# ll conf/
total 112
drwxrwxrwx 4 mycat mycat 4096 Sep 15 17:40  ./
drwxr-xr-x 6 mycat mycat   73 Sep 15 17:26  ../
-rwxrwxrwx 1 mycat mycat   92 Apr 15  2020  autopartition-long.txt*
-rwxrwxrwx 1 mycat mycat   51 Apr 15  2020  auto-sharding-long.txt*
-rwxrwxrwx 1 mycat mycat   67 Apr 15  2020  auto-sharding-rang-mod.txt*
-rwxrwxrwx 1 mycat mycat  340 Apr 15  2020  cacheservice.properties*
-rwxrwxrwx 1 mycat mycat 3338 Apr 15  2020  dbseq.sql*
-rwxrwxrwx 1 mycat mycat 3532 Apr 15  2020 'dbseq - utf8mb4.sql'*
-rwxrwxrwx 1 mycat mycat  446 Apr 15  2020  ehcache.xml*
-rwxrwxrwx 1 mycat mycat 2454 Apr 15  2020  index_to_charset.properties*
-rwxrwxrwx 1 mycat mycat 1285 Apr 15  2020  log4j2.xml*
-rwxrwxrwx 1 mycat mycat  183 Apr 15  2020  migrateTables.properties*
-rwxrwxrwx 1 mycat mycat  271 Apr 15  2020  myid.properties*
-rwxrwxrwx 1 mycat mycat   16 Apr 15  2020  partition-hash-int.txt*
-rwxrwxrwx 1 mycat mycat  108 Apr 15  2020  partition-range-mod.txt*
-rwxrwxrwx 1 mycat mycat 5423 Apr 15  2020  rule.xml*		#是分片规则的配置文件，分片规则的具体一些参数信息单独存放为文件，也在这个目录下
-rwxrwxrwx 1 mycat mycat 3302 Apr 15  2020  schema.xml*		#是逻辑库定义和表以及分片定义的配置文件
-rwxrwxrwx 1 mycat mycat  440 Apr 15  2020  sequence_conf.properties*
-rwxrwxrwx 1 mycat mycat   79 Apr 15  2020  sequence_db_conf.properties*
-rwxrwxrwx 1 mycat mycat   29 Apr 15  2020  sequence_distributed_conf.properties*
-rwxrwxrwx 1 mycat mycat   28 Apr 15  2020  sequence_http_conf.properties*
-rwxrwxrwx 1 mycat mycat   53 Apr 15  2020  sequence_time_conf.properties*
-rwxrwxrwx 1 mycat mycat 6336 Apr 15  2020  server.xml*		#是Mycat服务器参数调整和用户授权的配置文件
-rwxrwxrwx 1 mycat mycat   18 Apr 15  2020  sharding-by-enum.txt*
-rwxrwxrwx 1 mycat mycat 4251 Apr 22  2020  wrapper.conf*
drwxrwxrwx 2 mycat mycat 4096 Sep 15 17:26  zkconf/
drwxrwxrwx 2 mycat mycat   36 Sep 15 17:26  zkdownload/
注：配置文件修改，需要重启Mycat或者通过9066端口reload。日志存放在logs/mycat.log中，每天一个文件，日志的配置是在conf/log4j2.xml中，根据自己的需要，可以调整输出级别为info，debug级别下，会输出更多的信息，方便排查问题

root@ansible:/etc/ansible/roles/mysql/tasks# ansible '~172.168.2.3[54]' -m shell -a "echo 'export PATH=$PATH:/usr/local/mycat/bin' > /etc/profile.d/mycat.sh"
root@ansible:/etc/ansible/roles/mysql/tasks# ansible '~172.168.2.3[54]' -m shell -a "cat /etc/profile.d/mycat.sh"
172.168.2.35 | SUCCESS | rc=0 >>
export PATH=/etc/kubeasz/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/local/mycat/bin

172.168.2.34 | SUCCESS | rc=0 >>
export PATH=/etc/kubeasz/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/local/mycat/bin


## 配置mycat的配置
# 配置server.xml
-------------只更改如下用户配置，其余默认即可
        <user name="root" defaultAccount="true">
                <property name="password">123456</property>
                <property name="schemas">mycat</property>
                <property name="defaultSchema">mycat</property>
        </user>

        <user name="user">
                <property name="password">user</property>
                <property name="schemas">mycat</property>
                <property name="readOnly">true</property>
                <property name="defaultSchema">mycat</property>
        </user>
-------------
重点关注上面这段配置，其他默认即可。
=======================================
参数           说明
user          用户配置节点
name          登录的用户名，也就是连接Mycat的用户名。
password      登录的密码，也就是连接Mycat的密码
schemas       数据库名，这里会和schema.xml中的配置关联，多个用逗号分开，例如需要这个用户需要管理两个数据库db1,db2，则配置db1,db2
privileges    配置用户针对表的增删改查的权限
readOnly      mycat逻辑库所具有的权限。true为只读，false为读写都有，默认为false。
=======================================
注意：
- server.xml文件里登录mycat的用户名和密码可以任意定义，这个账号和密码是为客户机登录mycat时使用的账号信息。
- 逻辑库名(如上面的mycat，也就是登录mycat后显示的库名，切换这个库之后，显示的就是代理的真实mysql数据库的表)要在schema.xml里面也定义，否则会导致mycat服务启动失败！
- 如果定义多个标签，即设置多个连接mycat的用户名和密码，那么就需要在schema.xml文件中定义多个对应的库！
-------------


# 配置schema.xml
-------------
root@mysql-master01:/usr/local/mycat# cat conf/schema.xml
<?xml version="1.0"?>
<!DOCTYPE mycat:schema SYSTEM "schema.dtd">
<mycat:schema xmlns:mycat="http://io.mycat/">
        <schema name="mycat" checkSQLschema="false" sqlMaxLimit="100" dataNode="ms">
        </schema>

        <dataNode name="ms" dataHost="ops-mysql" database="ms" />

        <!-- <dataHost name="ops-mysql" maxCon="1000" minCon="10" balance="1"
                          writeType="0" dbType="mysql" dbDriver="jdbc" switchType="2"  slaveThreshold="100">
                <heartbeat>show slave status</heartbeat>
                <writeHost host="mysql-master01" url="jdbc:mysql://172.168.2.35:3306" user="root"
                                   password="test666">
                        <readHost host="mysql-slave01" url="jdbc:mysql://172.168.2.32:3306" user="root"
                                   password="test666">
                        </readHost>
                </writeHost>
                <writeHost host="mysql-master02" url="jdbc:mysql://172.168.2.34:3306" user="root"
                                   password="test666">
                        <readHost host="mysql-slave02" url="jdbc:mysql://172.168.2.31:3306" user="root"
                                   password="test666">
                        </readHost>
                </writeHost>
        </dataHost> -->

        <dataHost name="ops-mysql" maxCon="1000" minCon="10" balance="1"
                          writeType="0" dbType="mysql" dbDriver="native" switchType="2"  slaveThreshold="100">
                <heartbeat>show slave status</heartbeat>
                <writeHost host="mysql-master01" url="172.168.2.35:3306" user="root"
                                   password="test666">
                        <readHost host="mysql-slave01" url="172.168.2.32:3306" user="root"
                                   password="test666">
                        </readHost>
                </writeHost>
                <writeHost host="mysql-master02" url="172.168.2.34:3306" user="root"
                                   password="test666">
                        <readHost host="mysql-slave02" url="172.168.2.31:3306" user="root"
                                   password="test666">
                        </readHost>
                </writeHost>
        </dataHost>
</mycat:schema>
-------------
schema.xml是最主要的配置项，此文件关联mysql读写分离策略！读写分离、分库分表策略、分片节点都是在此文件中配置的！
MyCat作为中间件，它只是一个代理，本身并不进行数据存储，需要连接后端的MySQL物理服务器，此文件就是用来连接MySQL服务器的！
一定要授权mycat机器能使用root/test666权限成功登录这4台机器的mysql数据库,这很重要!!!
=======================================
## schemaxml文件中配置的参数解释：
参数           说明
schema         数据库设置，此数据库为逻辑数据库，name与server.xml中schema对应
dataNode       分片信息，也就是分库相关配置
dataHost       物理数据库，真正存储数据的数据库

## 配置说明：
name属性唯一标识dataHost标签，供上层的标签使用。
maxCon属性指定每个读写实例连接池的最大连接。也就是说，标签内嵌套的
writeHost、readHost标签都会使用这个属性的值来实例化出连接池的最大连接数。
minCon属性指定每个读写实例连接池的最小连接，初始化连接池的大小。

## 每个节点的属性逐一说明：
schema:
属性             说明
name               逻辑数据库名，与server.xml中的schema对应
checkSQLschema     数据库前缀相关设置，建议看文档，这里暂时设为folse
sqlMaxLimit    select 时默认的limit，避免查询全表

table：
属性             说明
name               表名，物理数据库中表名
dataNode       表存储到哪些节点，多个节点用逗号分隔。节点为下文dataNode设置的name
primaryKey     主键字段名，自动生成主键时需要设置
autoIncrement      是否自增
rule               分片规则名，具体规则下文rule详细介绍

dataNode：
属性             说明
name               节点名，与table中dataNode对应
datahost       物理数据库名，与datahost中name对应
database       物理数据库中数据库名

dataHost：
属性             说明
name               物理数据库名，与dataNode中dataHost对应
balance            均衡负载的方式
writeType      写入方式
dbType             数据库类型
heartbeat      心跳检测语句，注意语句结尾的分号要加

## schema.xml文件中有三点需要注意：balance="1"，writeType="0" ,switchType="1"
balance="0"：      不开启读写分离机制，所有读操作都发送到当前可用的writeHost 上,即读请求仅发送到writeHost上。
 
balance="1"：      读请求随机分发到当前writeHost对应的readHost、standby的writeHost和readHost上。即全部的readHost与stand by writeHost 参与
                   select 语句的负载均衡，简单的说，当双主双从模式(M1 ->S1 ， M2->S2，并且 M1 与 M2 互为主备)，正常情况下， M2,S1,
                   S2 都参与 select 语句的负载均衡
 
balance="2"：      读请求随机分发到当前dataHost内所有的writeHost和readHost上。即所有读操作都随机的在writeHost、 readhost 上分发。
 
balance="3"：      读请求随机分发到当前writeHost对应的readHost上。即所有读请求随机的分发到 wiriterHost 对应的 readhost 执行,
                   writerHost 不负担读压力，注意 balance=3 只在 1.4 及其以后版本有，1.3 没有。

## writeType 属性，负载均衡类型，目前的取值有 3 种
writeType="0"   所有写操作发送到配置的第一个 writeHost，第一个挂了切到还生存的第二个writeHost，重新启动后已切换后的为准，切换记录在配置文件中:dnindex.properties .
writeType="1"   所有写操作都随机的发送到配置的 writeHost。
writeType="2"   没实现。

## 对于事务内的SQL默认走写节点
以 /*balance*/ 开头，可以指定SQL使用特定负载均衡方案。例如在大环境开启读写分离的情况下，特定强一致性的SQL查询需求；
slaveThreshold：近似的主从延迟时间（秒）Seconds_Behind_Master < slaveThreshold ，读请求才会分发到该Slave，确保读到的数据相对较新。
schema.xml中的writeType的取值决定了负载均衡对写操作的处理：
writeType="0"：所有的写操作都发送到配置文件中的第一个write host。（第一个write host故障切换到第二个后，即使之后修复了仍然维持第二个为写库）。推荐取0值，不建议修改.

## 主从切换（双主failover）：switchType 属性
如果细心观察schem.xml文件的话，会发现有一个参数：switchType，如下配置：
 <dataHost name="ops-mysql" maxCon="1000" minCon="10" balance="1" writeType="0" dbType="mysql" dbDriver="native" switchType="1"  slaveThreshold="100">
 
参数解读
switchType="-1"：  不自动切换
switchType="1"：   默认值，自动切换
switchType="2"：   基于MySQL主从同步的状态来决定是否切换。需修改heartbeat语句（即心跳语句）：show slave status
switchType="3"：   基于Mysql Galera Cluster（集群多节点复制）的切换机制。需修改heartbeat语句（即心跳语句）：show status like 'wsrep%'

## dbType属性
指定后端连接的数据库类型，目前支持二进制的mysql协议，还有其他使用JDBC连接的数据库。例如：mongodb、oracle、spark等。

##dbDriver属性指定连接后端数据库使用的
Driver，目前可选的值有native和JDBC。
使用native的话，因为这个值执行的是二进制的mysql协议，所以可以使用mysql和maridb。
其他类型的数据库则需要使用JDBC驱动来支持。从1.6版本开始支持postgresql的native原始协议。
如果使用JDBC的话需要将符合JDBC 4标准的驱动JAR包放到MYCAT\lib目录下，并检查驱动JAR包中包括如下目录结构的文件：
META-INF\services\java.sql.Driver。在这个文件内写上具体的Driver类名，例如：com.mysql.jdbc.Driver。

## heartbeat标签
这个标签内指明用于和后端数据库进行心跳检查的语句。例如,MYSQL可以使用select user()，Oracle可以使用select 1 from dual等。
这个标签还有一个connectionInitSql属性，主要是当使用Oracla数据库时，需要执行的初始化SQL
语句就这个放到这里面来。例如：altersession set nls_date_format='yyyy-mm-dd hh24:mi:ss'
mysql主从切换的语句必须是：show slave status

## writeHost标签、readHost标签
这两个标签都指定后端数据库的相关配置给mycat，用于实例化后端连接池。
唯一不同的是：writeHost指定写实例、readHost指定读实例，组着这些读写实例来满足系统的要求。
在一个dataHost内可以定义多个writeHost和readHost。但是，如果writeHost指定的后端数据库宕机，那么这个writeHost绑定的所有readHost都将不可用。
另一方面，由于这个writeHost宕机系统会自动的检测到，并切换到备用的writeHost上去。
=======================================
-------------


# 启动服务
root@mysql-master01:/usr/local/mycat/conf# /usr/local/mycat/bin/mycat start
Starting Mycat-server...
root@mysql-master01:/usr/local/mycat/conf# /usr/local/mycat/bin/mycat status
Mycat-server is running (29531).
root@mysql-master01:/usr/local/mycat/conf# ss -tnlp
State                 Recv-Q                 Send-Q                                  Local Address:Port                                    Peer Address:Port
LISTEN                0                      128                                           0.0.0.0:3306                                         0.0.0.0:*                     users:(("mysqld",pid=23052,fd=18))
LISTEN                0                      128                                     127.0.0.53%lo:53                                           0.0.0.0:*                     users:(("systemd-resolve",pid=478,fd=13))
LISTEN                0                      128                                           0.0.0.0:22                                           0.0.0.0:*                     users:(("sshd",pid=634,fd=3))
LISTEN                0                      1                                           127.0.0.1:32000                                        0.0.0.0:*                     users:(("java",pid=29533,fd=4))
LISTEN                0                      50                                                  *:25449                                              *:*                     users:(("java",pid=29533,fd=82))
LISTEN                0                      100                                                 *:9066                                               *:*                     users:(("java",pid=29533,fd=106))
LISTEN                0                      50                                                  *:30517                                              *:*                     users:(("java",pid=29533,fd=80))
LISTEN                0                      128                                              [::]:22                                              [::]:*                     users:(("sshd",pid=634,fd=4))
LISTEN                0                      50                                                  *:1984                                               *:*                     users:(("java",pid=29533,fd=81))
LISTEN                0                      100                                                 *:8066                                               *:*                     users:(("java",pid=29533,fd=110))
注：Mycat服务端口默认是8066、管理端口默认是9066
```


### MyCat主从切换概述
```
# 1. 自动切换
自动切换是MyCat主从复制的默认配置 , 当主机或从机宕机后, MyCat自动切换到可用的服务器上。假设写服务器为M， 读服务器为S， 则：
正常时， 写M读S；
当M宕机后， 读写S ；恢复M后， 写S， 读M ；
当S宕机后， 读写M ；恢复S后， 写M， 读S ；

# 2. 基于MySQL主从同步状态的切换
这种切换方式与自动切换不同， MyCat检测到主从数据同步延迟时， 会自动切换到拥有最新数据的MySQL服务器上， 防止读到很久以前的数据。
原理就是通过检查MySQL的主从同步状态（show slave status）中的Seconds_Behind_Master、Slave_IO_Running、Slave_SQL_Running三个字段,来确定当前主从同步的状态以及主从之间的数据延迟。Seconds_Behind_Master为0表示没有延迟，数值越大，则说明延迟越高。

注：mycat配置
balance为1：让全部的readHost及备用的writeHost参与select的负载均衡。
switchType为2：基于MySQL主从同步的状态决定是否切换。
heartbeat：主从切换的心跳语句必须为show slave status。
```

### 通过连接mycat实现读写分离来使用mysql集群
```
root@mysql-master01:/usr/local/mycat# mysql -uroot -h127.0.0.1 -P8066 -p
Enter password:		#123456
mysql> show databases;
+----------+
| DATABASE |
+----------+
| mycat    |
+----------+
mysql> use mycat;
mysql> show tables;
+--------------+
| Tables_in_ms |
+--------------+
| province     |
+--------------+
mysql> select * from mycat.province;
mysql> select * from ms.province;
+----+--------+-----------+--------+--------------+----------------------------+------------+------------+----------+
| Id | Name   | NameEn    | Status | CreateUser   | CreateTime                 | UpdateUser | UpdateTime | IsDelete |
+----+--------+-----------+--------+--------------+----------------------------+------------+------------+----------+
|  1 |        | Beijing   |      1 |              | 2021-01-26 17:49:11.000000 | NULL       | NULL       |        0 |
|  2 |        | Shanghai  |      1 |              | 2021-01-26 17:49:11.000000 | NULL       | NULL       |        0 |
|  4 |        | Chongqing |      1 |              | 2021-01-26 17:49:11.000000 | NULL       | NULL       |        0 |
|  6 | 吉林   | Jilin     |      1 | 系统导入     | 2021-01-26 17:49:11.000000 | NULL       | NULL       |        0 |
+----+--------+-----------+--------+--------------+----------------------------+------------+------------+----------+
注：此时master01负责写，slave01、master02、slave02只负责读，可以从如下日志中看出
root@mysql-master01:/usr/local/mycat# tail -n 500  -f logs/mycat.log | grep 'MySQLConnection@'

-- 写语句路由到的后端mysql节点：可以看出是172.168.2.35
2022-09-19 11:54:43.290 DEBUG [$_NIOREACTOR-1-RW] (io.mycat.backend.mysql.nio.MySQLConnectionHandler.handleLogNodeInfo(MySQLConnectionHandler.java:166)) - handleOkPacket MySQLConnection@261540976 [id=116] for node=ms, sql=INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (15, '??', 'Jiangsu', 1, '????', '2021-01-15 11:30:59.000000', NULL, NULL, 0)
2022-09-19 11:54:43.294 DEBUG [$_NIOREACTOR-1-RW] (io.mycat.backend.datasource.PhysicalDatasource.releaseChannel(PhysicalDatasource.java:633)) - release channel MySQLConnection@261540976 [id=116, lastTime=1663559683286, user=root, schema=ms, old shema=ms, borrowed=true, fromSlaveDB=false, threadId=138, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.35, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]

-- 读语句路由到的后端mysql节点：可以看出是172.168.2.32，
2022-09-19 11:53:07.555 DEBUG [$_NIOREACTOR-2-RW] (io.mycat.backend.mysql.nio.MySQLConnectionHandler.handleLogNodeInfo(MySQLConnectionHandler.java:166)) - handleFieldEofPacket MySQLConnection@2042176058 [id=141] for node=ms, sql=SHOW COLUMNS FROM `ms`.`province`
2022-09-19 11:53:07.555 DEBUG [$_NIOREACTOR-2-RW] (io.mycat.backend.mysql.nio.MySQLConnectionHandler.handleLogNodeInfo(MySQLConnectionHandler.java:166)) - handleRowEofPacket MySQLConnection@2042176058 [id=141] for node=ms, sql=SHOW COLUMNS FROM `ms`.`province`
2022-09-19 11:53:07.555 DEBUG [$_NIOREACTOR-2-RW] (io.mycat.backend.datasource.PhysicalDatasource.releaseChannel(PhysicalDatasource.java:633)) - release channel MySQLConnection@2042176058 [id=141, lastTime=1663559587546, user=root, schema=ms, old shema=ms, borrowed=true, fromSlaveDB=true, threadId=87, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.32, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]

-- 查看插入的数据 
1		Beijing	1		2021-01-26 17:49:11.000000			0
2		Shanghai	1		2021-01-26 17:49:11.000000			0
4		Chongqing	1		2021-01-26 17:49:11.000000			0
6	吉林	Jilin	1	系统导入	2021-01-26 17:49:11.000000			0
11	山西	Shanxi	1	系统导入	2021-01-15 11:30:59.000000			0
12	陕西		1	系统导入	2021-01-15 11:30:59.000000			0
13	甘肃	Gansu	1	系统导入	2021-01-15 11:30:59.000000			0
14	宁夏	Ningxia	1	系统导入	2021-01-15 11:30:59.000000			0
15	江苏	Jiangsu	1	系统导入	2021-01-15 11:30:59.000000			0	#这条记录为插入的数据
```





### 模拟故障

#### 模拟172.168.2.32:3306(salve01)故障
```
root@mysql-slave01:~# hostname
mysql-slave01
root@mysql-slave01:~# service mysqld stop
root@mysql-slave01:~# systemctl is-active mysqld
inactive

-- 去mycat服务器(172.168.2.35)查看mycat日志，显示172.168.3.32连接已经关闭了
2022-09-19 14:32:36.995  INFO [$_NIOREACTOR-1-RW] (io.mycat.net.AbstractConnection.close(AbstractConnection.java:520)) - close connection,reason:stream closed ,MySQLConnection@1729582706 [id=143, lastTime=1663569156986, user=root, schema=ms, old shema=ms, borrowed=false, fromSlaveDB=true, threadId=10, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.32, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]
2022-09-19 14:32:38.459  INFO [$_NIOREACTOR-0-RW] (io.mycat.net.AbstractConnection.close(AbstractConnection.java:520)) - close connection,reason:stream closed ,MySQLConnection@2020709367 [id=146, lastTime=1663569096988, user=root, schema=ms, old shema=ms, borrowed=false, fromSlaveDB=true, threadId=12, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.32, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]
2022-09-19 14:32:38.460  INFO [$_NIOREACTOR-2-RW] (io.mycat.net.AbstractConnection.close(AbstractConnection.java:520)) - close connection,reason:stream closed ,MySQLConnection@1582606878 [id=148, lastTime=1663569106986, user=root, schema=ms, old shema=ms, borrowed=false, fromSlaveDB=true, threadId=14, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.32, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]

2022-09-19 14:32:56.992 ERROR [$_NIOConnector] (io.mycat.backend.heartbeat.MySQLHeartbeat.nextDector(MySQLHeartbeat.java:215)) - set Error 2  DBHostConfig [hostName=mysql-slave01, url=172.168.2.32:3306]	#显示schema.xml文件配置172.168.2.32:3306错误，原因是无法建立连接，所以错误


-- 去mycat服务器(172.168.2.35)查看mycat日志，当客户端执行查询时，"读请求"被路由到172.168.2.31上了
2022-09-19 14:50:01.028 DEBUG [$_NIOREACTOR-0-RW] (io.mycat.backend.datasource.PhysicalDBPool.getRWBanlanceCon(PhysicalDBPool.java:556)) - select read source mysql-slave02 for dataHost:ops-mysql
2022-09-19 14:50:01.029 DEBUG [$_NIOREACTOR-0-RW] (io.mycat.server.NonBlockingSession.bindConnection(NonBlockingSession.java:450)) - bindConnection Connection@1050121832 [id=140] for node=ms, sql=SHOW COLUMNS FROM `ms`.`province`
2022-09-19 14:50:01.030 DEBUG [$_NIOREACTOR-1-RW] (io.mycat.backend.mysql.nio.MySQLConnectionHandler.handleLogNodeInfo(MySQLConnectionHandler.java:166)) - handleFieldEofPacket MySQLConnection@1050121832 [id=140] for node=ms, sql=SHOW COLUMNS FROM `ms`.`province`
2022-09-19 14:50:01.031 DEBUG [$_NIOREACTOR-1-RW] (io.mycat.backend.mysql.nio.MySQLConnectionHandler.handleLogNodeInfo(MySQLConnectionHandler.java:166)) - handleRowEofPacket MySQLConnection@1050121832 [id=140] for node=ms, sql=SHOW COLUMNS FROM `ms`.`province`
2022-09-19 14:50:01.031 DEBUG [$_NIOREACTOR-1-RW] (io.mycat.server.NonBlockingSession.releaseConnection(NonBlockingSession.java:391)) - releaseConnection Connection@1050121832 [id=140] for node=ms, sql=SHOW COLUMNS FROM `ms`.`province`
2022-09-19 14:50:01.031 DEBUG [$_NIOREACTOR-1-RW] (io.mycat.backend.datasource.PhysicalDatasource.releaseChannel(PhysicalDatasource.java:633)) - release channel MySQLConnection@1050121832 [id=140, lastTime=1663570201026, user=root, schema=ms, old shema=ms, borrowed=true, fromSlaveDB=true, threadId=87, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.31, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]
```

#### 模拟172.168.2.32:3306(salve01)服务恢复
```
root@mysql-slave01:~# service mysqld start

-- 去mycat服务器(172.168.2.35)查看mycat日志，此时可以看到172.168.2.32:3306(salve01)已经恢复
2022-09-19 14:52:46.993  INFO [$_NIOREACTOR-1-RW] (io.mycat.backend.datasource.PhysicalDatasource$1$1.connectionAcquired(PhysicalDatasource.java:514)) - connection id is 150
2022-09-19 14:52:46.993 DEBUG [$_NIOREACTOR-1-RW] (io.mycat.sqlengine.SQLJob.connectionAcquired(SQLJob.java:89)) - con query sql:show slave status to con:MySQLConnection@935276298 [id=150, lastTime=1663570366993, user=root, schema=ms, old shema=ms, borrowed=true, fromSlaveDB=true, threadId=8, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.32, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]
2022-09-19 14:52:46.994 DEBUG [$_NIOREACTOR-1-RW] (io.mycat.backend.datasource.PhysicalDatasource.releaseChannel(PhysicalDatasource.java:633)) - release channel MySQLConnection@935276298 [id=150, lastTime=1663570366988, user=root, schema=ms, old shema=ms, borrowed=true, fromSlaveDB=true, threadId=8, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.32, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]

2022-09-19 14:53:06.990 DEBUG [Timer0] (io.mycat.sqlengine.SQLJob.connectionAcquired(SQLJob.java:89)) - con query sql:show slave status to con:MySQLConnection@1552174925 [id=124, lastTime=1663570386990, user=root, schema=ms, old shema=ms, borrowed=true, fromSlaveDB=false, threadId=139, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.35, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]
2022-09-19 14:53:06.991 DEBUG [Timer0] (io.mycat.sqlengine.SQLJob.connectionAcquired(SQLJob.java:89)) - con query sql:show slave status to con:MySQLConnection@1704921047 [id=126, lastTime=1663570386990, user=root, schema=ms, old shema=ms, borrowed=true, fromSlaveDB=false, threadId=94, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.34, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]
2022-09-19 14:53:06.991 DEBUG [Timer0] (io.mycat.sqlengine.SQLJob.connectionAcquired(SQLJob.java:89)) - con query sql:show slave status to con:MySQLConnection@935276298 [id=150, lastTime=1663570386991, user=root, schema=ms, old shema=ms, borrowed=true, fromSlaveDB=true, threadId=8, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.32, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]
2022-09-19 14:53:06.991 DEBUG [$_NIOREACTOR-1-RW] (io.mycat.backend.datasource.PhysicalDatasource.releaseChannel(PhysicalDatasource.java:633)) - release channel MySQLConnection@1552174925 [id=124, lastTime=1663570386986, user=root, schema=ms, old shema=ms, borrowed=true, fromSlaveDB=false, threadId=139, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.35, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]
```


#### 模拟172.168.2.35:3306(master01)故障
```
root@mysql-master01:/usr/local/mycat# service mysqld stop
root@mysql-master01:/usr/local/mycat# systemctl is-active mysqld
inactive

-- 去mycat服务器(172.168.2.35)查看mycat日志，显示172.168.3.35连接已经关闭了
2022-09-19 14:57:16.991 ERROR [$_NIOConnector] (io.mycat.net.NIOConnector.finishConnect(NIOConnector.java:158)) - error:
java.net.ConnectException: Connection refused
        at sun.nio.ch.SocketChannelImpl.checkConnect(Native Method) ~[?:1.8.0_342]
        at sun.nio.ch.SocketChannelImpl.finishConnect(SocketChannelImpl.java:716) ~[?:1.8.0_342]
        at io.mycat.net.NIOConnector.finishConnect(NIOConnector.java:167) ~[Mycat-server-1.6.7.5-release.jar:?]
        at io.mycat.net.NIOConnector.finishConnect(NIOConnector.java:146) [Mycat-server-1.6.7.5-release.jar:?]
        at io.mycat.net.NIOConnector.run(NIOConnector.java:99) [Mycat-server-1.6.7.5-release.jar:?]
2022-09-19 14:57:16.992  INFO [$_NIOConnector] (io.mycat.net.AbstractConnection.close(AbstractConnection.java:520)) - close connection,reason:java.net.ConnectException: Connection refused ,MySQLConnection@843290958 [id=0, lastTime=1663570636987, user=root, schema=ms, old shema=ms, borrowed=false, fromSlaveDB=false, threadId=0, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.35, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]
2022-09-19 14:57:16.993  INFO [$_NIOConnector] (io.mycat.sqlengine.SQLJob.connectionError(SQLJob.java:125)) - can't get connection for sql :show slave status
2022-09-19 14:57:16.994  WARN [$_NIOConnector] (io.mycat.backend.heartbeat.MySQLDetector.onResult(MySQLDetector.java:208)) - heart beat error: mysql-master01/ops-mysql retry=10 tmo=30000
2022-09-19 14:57:16.994 ERROR [$_NIOConnector] (io.mycat.backend.heartbeat.MySQLHeartbeat.nextDector(MySQLHeartbeat.java:215)) - set Error 2  DBHostConfig [hostName=mysql-master01, url=172.168.2.35:3306]	#显示schema.xml配置172.168.2.35:3306错误，表示主机DOWN


-- 客户端进行查询插入报错
INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (17, '安徽', 'Anhui', 1, '系统导入', '2021-01-15 11:30:59.000000', NULL, NULL, 0)
> 1184 - java.net.ConnectException: Connection refused
> 时间: 0.004s

-- 等待一会，大概30秒左右，客户端可以写入了，在172.168.2.34上进行插入了，此时master01宕机了，而且master01的slave01也不会对外服务了，所以此时真正对外服务的节点是Write: master02(172.168.2.34)、Read: slave02(172.168.2.31)
2022-09-19 15:01:42.613 DEBUG [$_NIOREACTOR-2-RW] (io.mycat.server.NonBlockingSession.bindConnection(NonBlockingSession.java:450)) - bindConnection Connection@2055689303 [id=155] for node=ms, sql=INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (17, '??', 'Anhui', 1, '????', '2021-01-15 11:30:59.000000', NULL, NULL, 0)
2022-09-19 15:01:42.617 DEBUG [$_NIOREACTOR-2-RW] (io.mycat.backend.mysql.nio.MySQLConnectionHandler.handleLogNodeInfo(MySQLConnectionHandler.java:166)) - handleOkPacket MySQLConnection@2055689303 [id=155] for node=ms, sql=INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (17, '??', 'Anhui', 1, '????', '2021-01-15 11:30:59.000000', NULL, NULL, 0)
2022-09-19 15:01:42.617 DEBUG [$_NIOREACTOR-2-RW] (io.mycat.server.NonBlockingSession.releaseConnection(NonBlockingSession.java:391)) - releaseConnection Connection@2055689303 [id=155] for node=ms, sql=INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (17, '??', 'Anhui', 1, '????', '2021-01-15 11:30:59.000000', NULL, NULL, 0)
2022-09-19 15:01:42.617 DEBUG [$_NIOREACTOR-2-RW] (io.mycat.backend.datasource.PhysicalDatasource.releaseChannel(PhysicalDatasource.java:633)) - release channel MySQLConnection@2055689303 [id=155, lastTime=1663570902607, user=root, schema=ms, old shema=ms, borrowed=true, fromSlaveDB=false, threadId=95, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.34, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]		#172.168.2.34进行处理写请求
.....
2022-09-19 14:59:17.011 DEBUG [$_NIOREACTOR-2-RW] (io.mycat.backend.datasource.PhysicalDatasource.releaseChannel(PhysicalDatasource.java:633)) - release channel MySQLConnection@111133128 [id=125, lastTime=1663570757005, user=root, schema=ms, old shema=ms, borrowed=true, fromSlaveDB=true, threadId=80, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.31, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]		#172.168.2.31进行处理读请求
```

#### 模拟172.168.2.35:3306(master01)服务恢复
```
root@mysql-master01:~# service mysqld start
root@mysql-master01:~# systemctl is-active mysqld
active

-- 去mycat服务器(172.168.2.35)查看mycat日志，此时可以看到172.168.2.35:3306(salve01)已经恢复
2022-09-19 15:52:16.992  INFO [$_NIOREACTOR-0-RW] (io.mycat.backend.datasource.PhysicalDatasource$1$1.connectionAcquired(PhysicalDatasource.java:514)) - connection id is 165
2022-09-19 15:52:16.992 DEBUG [$_NIOREACTOR-0-RW] (io.mycat.sqlengine.SQLJob.connectionAcquired(SQLJob.java:89)) - con query sql:show slave status to con:MySQLConnection@1094913372 [id=165, lastTime=1663573936992, user=root, schema=ms, old shema=ms, borrowed=true, fromSlaveDB=false, threadId=8, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.35, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]
2022-09-19 15:52:16.993 DEBUG [$_NIOREACTOR-0-RW] (io.mycat.backend.datasource.PhysicalDatasource.releaseChannel(PhysicalDatasource.java:633)) - release channel MySQLConnection@1094913372 [id=165, lastTime=1663573936987, user=root, schema=ms, old shema=ms, borrowed=true, fromSlaveDB=false, threadId=8, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.35, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]	#172.168.2.35已经恢复

-- mycat管理端口中查看健康检查状态
mysql> show @@heartbeat;			#恢复前状态
+----------------+-------+--------------+------+---------+-------+--------+---------+--------------+---------------------+-------+
| NAME           | TYPE  | HOST         | PORT | RS_CODE | RETRY | STATUS | TIMEOUT | EXECUTE_TIME | LAST_ACTIVE_TIME    | STOP  |
+----------------+-------+--------------+------+---------+-------+--------+---------+--------------+---------------------+-------+
| mysql-master01 | mysql | 172.168.2.35 | 3306 |      -1 |     0 | idle   |   30000 | 1,1,1        | 2022-09-19 15:51:26 | false |
| mysql-master02 | mysql | 172.168.2.34 | 3306 |       1 |     0 | idle   |   30000 | 1,1,1        | 2022-09-19 15:51:26 | false |
| mysql-slave01  | mysql | 172.168.2.32 | 3306 |       1 |     0 | idle   |   30000 | 1,1,1        | 2022-09-19 15:51:26 | false |
| mysql-slave02  | mysql | 172.168.2.31 | 3306 |       1 |     0 | idle   |   30000 | 2,2,2        | 2022-09-19 15:51:26 | false |
+----------------+-------+--------------+------+---------+-------+--------+---------+--------------+---------------------+-------+
4 rows in set (0.00 sec)

mysql> mysql> show @@heartbeat;		#恢复后状态
+----------------+-------+--------------+------+---------+-------+--------+---------+--------------+---------------------+-------+
| NAME           | TYPE  | HOST         | PORT | RS_CODE | RETRY | STATUS | TIMEOUT | EXECUTE_TIME | LAST_ACTIVE_TIME    | STOP  |
+----------------+-------+--------------+------+---------+-------+--------+---------+--------------+---------------------+-------+
| mysql-master01 | mysql | 172.168.2.35 | 3306 |       1 |     0 | idle   |   30000 | 0,1,1        | 2022-09-19 15:55:36 | false |
| mysql-master02 | mysql | 172.168.2.34 | 3306 |       1 |     0 | idle   |   30000 | 1,1,1        | 2022-09-19 15:55:36 | false |
| mysql-slave01  | mysql | 172.168.2.32 | 3306 |       1 |     0 | idle   |   30000 | 1,1,1        | 2022-09-19 15:55:36 | false |
| mysql-slave02  | mysql | 172.168.2.31 | 3306 |       1 |     0 | idle   |   30000 | 1,1,1        | 2022-09-19 15:55:36 | false |
+----------------+-------+--------------+------+---------+-------+--------+---------+--------------+---------------------+-------+

-- 查看写请求路由到哪里
-- 第一次写请求
2022-09-20 09:38:09.891 DEBUG [$_NIOREACTOR-1-RW] (io.mycat.server.NonBlockingSession.bindConnection(NonBlockingSession.java:450)) - bindConnection Connection@399050934 [id=158] for node=ms, sql=INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (18, '??', 'Jiangxi', 1, '????', '2021-01-15 11:30:59.000000', NULL, NULL, 0)
2022-09-20 09:38:09.894 DEBUG [$_NIOREACTOR-2-RW] (io.mycat.backend.mysql.nio.MySQLConnectionHandler.handleLogNodeInfo(MySQLConnectionHandler.java:166)) - handleOkPacket MySQLConnection@399050934 [id=158] for node=ms, sql=INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (18, '??', 'Jiangxi', 1, '????', '2021-01-15 11:30:59.000000', NULL, NULL, 0)
2022-09-20 09:38:09.894 DEBUG [$_NIOREACTOR-2-RW] (io.mycat.server.NonBlockingSession.releaseConnection(NonBlockingSession.java:391)) - releaseConnection Connection@399050934 [id=158] for node=ms, sql=INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (18, '??', 'Jiangxi', 1, '????', '2021-01-15 11:30:59.000000', NULL, NULL, 0)
2022-09-20 09:38:09.894 DEBUG [$_NIOREACTOR-2-RW] (io.mycat.backend.datasource.PhysicalDatasource.releaseChannel(PhysicalDatasource.java:633)) - release channel MySQLConnection@399050934 [id=158, lastTime=1663637889886, user=root, schema=ms, old shema=ms, borrowed=true, fromSlaveDB=false, threadId=98, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.34, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]		#第一次写路由到172.168.2.34
-- 第二次写请求
2022-09-20 09:38:33.954 DEBUG [$_NIOREACTOR-1-RW] (io.mycat.server.NonBlockingSession.bindConnection(NonBlockingSession.java:450)) - bindConnection Connection@1704921047 [id=126] for node=ms, sql=INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (19, '??', 'Fujian', 1, '????', '2021-01-15 11:30:59.000000', NULL, NULL, 0)
2022-09-20 09:38:33.958 DEBUG [$_NIOREACTOR-3-RW] (io.mycat.backend.mysql.nio.MySQLConnectionHandler.handleLogNodeInfo(MySQLConnectionHandler.java:166)) - handleOkPacket MySQLConnection@1704921047 [id=126] for node=ms, sql=INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (19, '??', 'Fujian', 1, '????', '2021-01-15 11:30:59.000000', NULL, NULL, 0)
2022-09-20 09:38:33.959 DEBUG [$_NIOREACTOR-3-RW] (io.mycat.server.NonBlockingSession.releaseConnection(NonBlockingSession.java:391)) - releaseConnection Connection@1704921047 [id=126] for node=ms, sql=INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (19, '??', 'Fujian', 1, '????', '2021-01-15 11:30:59.000000', NULL, NULL, 0)
2022-09-20 09:38:33.959 DEBUG [$_NIOREACTOR-3-RW] (io.mycat.backend.datasource.PhysicalDatasource.releaseChannel(PhysicalDatasource.java:633)) - release channel MySQLConnection@1704921047 [id=126, lastTime=1663637913946, user=root, schema=ms, old shema=ms, borrowed=true, fromSlaveDB=false, threadId=94, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.34, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]		#第二次写路由到172.168.2.34
-- 第三次写请求
2022-09-20 09:39:19.372 DEBUG [$_NIOREACTOR-1-RW] (io.mycat.server.NonBlockingSession.bindConnection(NonBlockingSession.java:450)) - bindConnection Connection@399050934 [id=158] for node=ms, sql=INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (20, '??', 'Hubei', 1, '????', '2021-01-15 11:30:59.000000', NULL, NULL, 0)
2022-09-20 09:39:19.376 DEBUG [$_NIOREACTOR-2-RW] (io.mycat.backend.mysql.nio.MySQLConnectionHandler.handleLogNodeInfo(MySQLConnectionHandler.java:166)) - handleOkPacket MySQLConnection@399050934 [id=158] for node=ms, sql=INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (20, '??', 'Hubei', 1, '????', '2021-01-15 11:30:59.000000', NULL, NULL, 0)
2022-09-20 09:39:19.376 DEBUG [$_NIOREACTOR-2-RW] (io.mycat.server.NonBlockingSession.releaseConnection(NonBlockingSession.java:391)) - releaseConnection Connection@399050934 [id=158] for node=ms, sql=INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (20, '??', 'Hubei', 1, '????', '2021-01-15 11:30:59.000000', NULL, NULL, 0)
2022-09-20 09:39:19.376 DEBUG [$_NIOREACTOR-2-RW] (io.mycat.backend.datasource.PhysicalDatasource.releaseChannel(PhysicalDatasource.java:633)) - release channel MySQLConnection@399050934 [id=158, lastTime=1663637959365, user=root, schema=ms, old shema=ms, borrowed=true, fromSlaveDB=false, threadId=98, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.34, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]		#第三次写路由到172.168.2.34
注：3次写都到master02，说明master01恢复后是不提供写的，


-- 查看读请求路由到哪里
-- 第一次读请求
2022-09-20 09:33:52.401 DEBUG [$_NIOREACTOR-2-RW] (io.mycat.server.NonBlockingSession.bindConnection(NonBlockingSession.java:450)) - bindConnection Connection@1094913372 [id=165] for node=ms, sql=SHOW COLUMNS FROM `ms`.`province`
2022-09-20 09:33:52.403 DEBUG [$_NIOREACTOR-0-RW] (io.mycat.backend.mysql.nio.MySQLConnectionHandler.handleLogNodeInfo(MySQLConnectionHandler.java:166)) - handleFieldEofPacket MySQLConnection@1094913372 [id=165] for node=ms, sql=SHOW COLUMNS FROM `ms`.`province`
2022-09-20 09:33:52.403 DEBUG [$_NIOREACTOR-0-RW] (io.mycat.backend.mysql.nio.MySQLConnectionHandler.handleLogNodeInfo(MySQLConnectionHandler.java:166)) - handleRowEofPacket MySQLConnection@1094913372 [id=165] for node=ms, sql=SHOW COLUMNS FROM `ms`.`province`
2022-09-20 09:33:52.404 DEBUG [$_NIOREACTOR-0-RW] (io.mycat.server.NonBlockingSession.releaseConnection(NonBlockingSession.java:391)) - releaseConnection Connection@1094913372 [id=165] for node=ms, sql=SHOW COLUMNS FROM `ms`.`province`
2022-09-20 09:33:52.404 DEBUG [$_NIOREACTOR-0-RW] (io.mycat.backend.datasource.PhysicalDatasource.releaseChannel(PhysicalDatasource.java:633)) - release channel MySQLConnection@1094913372 [id=165, lastTime=1663637632386, user=root, schema=ms, old shema=ms, borrowed=true, fromSlaveDB=false, threadId=8, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.35, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]	#第一次路由到172.168.2.35
-- 第二次读请求
2022-09-20 09:35:36.841 DEBUG [$_NIOREACTOR-1-RW] (io.mycat.server.NonBlockingSession.bindConnection(NonBlockingSession.java:450)) - bindConnection Connection@1780052473 [id=160] for node=ms, sql=SHOW STATUS
2022-09-20 09:35:36.844 DEBUG [$_NIOREACTOR-0-RW] (io.mycat.backend.mysql.nio.MySQLConnectionHandler.handleLogNodeInfo(MySQLConnectionHandler.java:166)) - handleFieldEofPacket MySQLConnection@1780052473 [id=160] for node=ms, sql=SHOW STATUS
2022-09-20 09:35:36.844 DEBUG [$_NIOREACTOR-0-RW] (io.mycat.backend.mysql.nio.MySQLConnectionHandler.handleLogNodeInfo(MySQLConnectionHandler.java:166)) - handleRowEofPacket MySQLConnection@1780052473 [id=160] for node=ms, sql=SHOW STATUS
2022-09-20 09:35:36.844 DEBUG [$_NIOREACTOR-0-RW] (io.mycat.server.NonBlockingSession.releaseConnection(NonBlockingSession.java:391)) - releaseConnection Connection@1780052473 [id=160] for node=ms, sql=SHOW STATUS
2022-09-20 09:35:36.844 DEBUG [$_NIOREACTOR-0-RW] (io.mycat.backend.datasource.PhysicalDatasource.releaseChannel(PhysicalDatasource.java:633)) - release channel MySQLConnection@1780052473 [id=160, lastTime=1663637736826, user=root, schema=ms, old shema=ms, borrowed=true, fromSlaveDB=true, threadId=13, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.32, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]	#第二次路由到172.168.2.32
-- 第三次读请求
2022-09-20 09:37:16.640 DEBUG [$_NIOREACTOR-2-RW] (io.mycat.server.NonBlockingSession.bindConnection(NonBlockingSession.java:450)) - bindConnection Connection@1823216045 [id=130] for node=ms, sql=SHOW COLUMNS FROM `ms`.`province`
2022-09-20 09:37:16.642 DEBUG [$_NIOREACTOR-3-RW] (io.mycat.backend.mysql.nio.MySQLConnectionHandler.handleLogNodeInfo(MySQLConnectionHandler.java:166)) - handleFieldEofPacket MySQLConnection@1823216045 [id=130] for node=ms, sql=SHOW COLUMNS FROM `ms`.`province`
2022-09-20 09:37:16.642 DEBUG [$_NIOREACTOR-3-RW] (io.mycat.backend.mysql.nio.MySQLConnectionHandler.handleLogNodeInfo(MySQLConnectionHandler.java:166)) - handleRowEofPacket MySQLConnection@1823216045 [id=130] for node=ms, sql=SHOW COLUMNS FROM `ms`.`province`
2022-09-20 09:37:16.642 DEBUG [$_NIOREACTOR-3-RW] (io.mycat.server.NonBlockingSession.releaseConnection(NonBlockingSession.java:391)) - releaseConnection Connection@1823216045 [id=130] for node=ms, sql=SHOW COLUMNS FROM `ms`.`province`
2022-09-20 09:37:16.642 DEBUG [$_NIOREACTOR-3-RW] (io.mycat.backend.datasource.PhysicalDatasource.releaseChannel(PhysicalDatasource.java:633)) - release channel MySQLConnection@1823216045 [id=130, lastTime=1663637836628, user=root, schema=ms, old shema=ms, borrowed=true, fromSlaveDB=true, threadId=81, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.31, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]	#第二次路由到172.168.2.31
注：这三次读请求是随机的，可能有连续两次出现在同一个节点之上，这三个节点都有接收读请求，说明master01恢复后是提供读的
总结：master01主机服务恢复后，不提供写，只提供读。
```

##### master01恢复后为读节点，master02为写节点，这时宕掉master02，看读写请求如何 
```
root@mysql-master02:/usr/local/mycat# service mysqld stop

-- 写请求测试
-- 第一次写请求
2022-09-20 09:46:12.974 DEBUG [$_NIOREACTOR-1-RW] (io.mycat.server.NonBlockingSession.bindConnection(NonBlockingSession.java:450)) - bindConnection Connection@1094913372 [id=165] for node=ms, sql=INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (21, '??', 'Hunan', 1, '????', '2021-01-15 11:30:59.000000', NULL, NULL, 0)
2022-09-20 09:46:12.977 DEBUG [$_NIOREACTOR-0-RW] (io.mycat.backend.mysql.nio.MySQLConnectionHandler.handleLogNodeInfo(MySQLConnectionHandler.java:166)) - handleOkPacket MySQLConnection@1094913372 [id=165] for node=ms, sql=INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (21, '??', 'Hunan', 1, '????', '2021-01-15 11:30:59.000000', NULL, NULL, 0)
2022-09-20 09:46:12.977 DEBUG [$_NIOREACTOR-0-RW] (io.mycat.server.NonBlockingSession.releaseConnection(NonBlockingSession.java:391)) - releaseConnection Connection@1094913372 [id=165] for node=ms, sql=INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (21, '??', 'Hunan', 1, '????', '2021-01-15 11:30:59.000000', NULL, NULL, 0)
2022-09-20 09:46:12.977 DEBUG [$_NIOREACTOR-0-RW] (io.mycat.backend.datasource.PhysicalDatasource.releaseChannel(PhysicalDatasource.java:633)) - release channel MySQLConnection@1094913372 [id=165, lastTime=1663638372966, user=root, schema=ms, old shema=ms, borrowed=true, fromSlaveDB=false, threadId=8, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.35, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]	#写请求到master01(172.168.2.35)
-- 第二次写请求
2022-09-20 09:46:12.974 DEBUG [$_NIOREACTOR-1-RW] (io.mycat.server.NonBlockingSession.bindConnection(NonBlockingSession.java:450)) - bindConnection Connection@1094913372 [id=165] for node=ms, sql=INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (21, '??', 'Hunan', 1, '????', '2021-01-15 11:30:59.000000', NULL, NULL, 0)
2022-09-20 09:46:12.977 DEBUG [$_NIOREACTOR-0-RW] (io.mycat.backend.mysql.nio.MySQLConnectionHandler.handleLogNodeInfo(MySQLConnectionHandler.java:166)) - handleOkPacket MySQLConnection@1094913372 [id=165] for node=ms, sql=INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (21, '??', 'Hunan', 1, '????', '2021-01-15 11:30:59.000000', NULL, NULL, 0)
2022-09-20 09:46:12.977 DEBUG [$_NIOREACTOR-0-RW] (io.mycat.server.NonBlockingSession.releaseConnection(NonBlockingSession.java:391)) - releaseConnection Connection@1094913372 [id=165] for node=ms, sql=INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (21, '??', 'Hunan', 1, '????', '2021-01-15 11:30:59.000000', NULL, NULL, 0)
2022-09-20 09:46:12.977 DEBUG [$_NIOREACTOR-0-RW] (io.mycat.backend.datasource.PhysicalDatasource.releaseChannel(PhysicalDatasource.java:633)) - release channel MySQLConnection@1094913372 [id=165, lastTime=1663638372966, user=root, schema=ms, old shema=ms, borrowed=true, fromSlaveDB=false, threadId=8, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.35, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]	#写请求到master01(172.168.2.35)
-- 第三次写请求
2022-09-20 09:48:43.998 DEBUG [$_NIOREACTOR-1-RW] (io.mycat.server.NonBlockingSession.bindConnection(NonBlockingSession.java:450)) - bindConnection Connection@1094913372 [id=165] for node=ms, sql=INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (22, '??', 'Sichuan', 1, '????', '2021-01-15 11:30:59.000000', NULL, NULL, 0)
2022-09-20 09:48:43.998 DEBUG [$_NIOREACTOR-0-RW] (io.mycat.backend.mysql.nio.MySQLConnectionHandler.handleLogNodeInfo(MySQLConnectionHandler.java:166)) - handleErrorPacket MySQLConnection@1094913372 [id=165] for node=ms, sql=INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (22, '??', 'Sichuan', 1, '????', '2021-01-15 11:30:59.000000', NULL, NULL, 0)
2022-09-20 09:48:43.999  WARN [$_NIOREACTOR-0-RW] (io.mycat.backend.mysql.nio.handler.SingleNodeHandler.backConnectionErr(SingleNodeHandler.java:284)) - execute  sql err : errno:1062 Duplicate entry '22' for key 'PRIMARY' con:MySQLConnection@1094913372 [id=165, lastTime=1663638523986, user=root, schema=ms, old shema=ms, borrowed=true, fromSlaveDB=false, threadId=8, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=ms{INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (22, '??', 'Sichuan', 1, '????', '2021-01-15 11:30:59.000000', NULL, NULL, 0)}, respHandler=SingleNodeHandler [node=ms{INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (22, '??', 'Sichuan', 1, '????', '2021-01-15 11:30:59.000000', NULL, NULL, 0)}, packetId=1], host=172.168.2.35, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=true] frontend host:172.168.2.219/62846/root
2022-09-20 09:48:43.999 DEBUG [$_NIOREACTOR-0-RW] (io.mycat.server.NonBlockingSession.releaseConnection(NonBlockingSession.java:391)) - releaseConnection Connection@1094913372 [id=165] for node=ms, sql=INSERT INTO `ms`.`province`(`Id`, `Name`, `NameEn`, `Status`, `CreateUser`, `CreateTime`, `UpdateUser`, `UpdateTime`, `IsDelete`) VALUES (22, '??', 'Sichuan', 1, '????', '2021-01-15 11:30:59.000000', NULL, NULL, 0)
2022-09-20 09:48:43.999 DEBUG [$_NIOREACTOR-0-RW] (io.mycat.backend.datasource.PhysicalDatasource.releaseChannel(PhysicalDatasource.java:633)) - release channel MySQLConnection@1094913372 [id=165, lastTime=1663638523986, user=root, schema=ms, old shema=ms, borrowed=true, fromSlaveDB=false, threadId=8, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.35, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]	#写请求到master01(172.168.2.35)，但这次写入人错误，因为主键ID重复了

-- 读请求测试
-- 第一次读请求
2022-09-20 09:50:46.652 DEBUG [$_NIOREACTOR-2-RW] (io.mycat.server.NonBlockingSession.bindConnection(NonBlockingSession.java:450)) - bindConnection Connection@730444724 [id=159] for node=ms, sql=SHOW COLUMNS FROM `ms`.`province`
2022-09-20 09:50:46.653 DEBUG [$_NIOREACTOR-3-RW] (io.mycat.backend.mysql.nio.MySQLConnectionHandler.handleLogNodeInfo(MySQLConnectionHandler.java:166)) - handleFieldEofPacket MySQLConnection@730444724 [id=159] for node=ms, sql=SHOW COLUMNS FROM `ms`.`province`
2022-09-20 09:50:46.653 DEBUG [$_NIOREACTOR-3-RW] (io.mycat.backend.mysql.nio.MySQLConnectionHandler.handleLogNodeInfo(MySQLConnectionHandler.java:166)) - handleRowEofPacket MySQLConnection@730444724 [id=159] for node=ms, sql=SHOW COLUMNS FROM `ms`.`province`
2022-09-20 09:50:46.653 DEBUG [$_NIOREACTOR-3-RW] (io.mycat.server.NonBlockingSession.releaseConnection(NonBlockingSession.java:391)) - releaseConnection Connection@730444724 [id=159] for node=ms, sql=SHOW COLUMNS FROM `ms`.`province`
2022-09-20 09:50:46.653 DEBUG [$_NIOREACTOR-3-RW] (io.mycat.backend.datasource.PhysicalDatasource.releaseChannel(PhysicalDatasource.java:633)) - release channel MySQLConnection@730444724 [id=159, lastTime=1663638646646, user=root, schema=ms, old shema=ms, borrowed=true, fromSlaveDB=true, threadId=12, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.32, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]	#读请求到slave01(172.168.2.32)
-- 第二次读请求
2022-09-20 09:51:23.985 DEBUG [$_NIOREACTOR-2-RW] (io.mycat.server.NonBlockingSession.bindConnection(NonBlockingSession.java:450)) - bindConnection Connection@1780052473 [id=160] for node=ms, sql=SHOW COLUMNS FROM `ms`.`province`
2022-09-20 09:51:23.986 DEBUG [$_NIOREACTOR-0-RW] (io.mycat.backend.mysql.nio.MySQLConnectionHandler.handleLogNodeInfo(MySQLConnectionHandler.java:166)) - handleFieldEofPacket MySQLConnection@1780052473 [id=160] for node=ms, sql=SHOW COLUMNS FROM `ms`.`province`
2022-09-20 09:51:23.987 DEBUG [$_NIOREACTOR-0-RW] (io.mycat.backend.mysql.nio.MySQLConnectionHandler.handleLogNodeInfo(MySQLConnectionHandler.java:166)) - handleRowEofPacket MySQLConnection@1780052473 [id=160] for node=ms, sql=SHOW COLUMNS FROM `ms`.`province`
2022-09-20 09:51:23.987 DEBUG [$_NIOREACTOR-0-RW] (io.mycat.server.NonBlockingSession.releaseConnection(NonBlockingSession.java:391)) - releaseConnection Connection@1780052473 [id=160] for node=ms, sql=SHOW COLUMNS FROM `ms`.`province`
2022-09-20 09:51:23.987 DEBUG [$_NIOREACTOR-0-RW] (io.mycat.backend.datasource.PhysicalDatasource.releaseChannel(PhysicalDatasource.java:633)) - release channel MySQLConnection@1780052473 [id=160, lastTime=1663638683969, user=root, schema=ms, old shema=ms, borrowed=true, fromSlaveDB=true, threadId=13, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.32, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]	#读请求到slave01(172.168.2.32)
-- 第三次读请求
2022-09-20 09:51:40.474 DEBUG [$_NIOREACTOR-2-RW] (io.mycat.server.NonBlockingSession.bindConnection(NonBlockingSession.java:450)) - bindConnection Connection@730444724 [id=159] for node=ms, sql=SHOW COLUMNS FROM `ms`.`province`
2022-09-20 09:51:40.475 DEBUG [$_NIOREACTOR-3-RW] (io.mycat.backend.mysql.nio.MySQLConnectionHandler.handleLogNodeInfo(MySQLConnectionHandler.java:166)) - handleFieldEofPacket MySQLConnection@730444724 [id=159] for node=ms, sql=SHOW COLUMNS FROM `ms`.`province`
2022-09-20 09:51:40.475 DEBUG [$_NIOREACTOR-3-RW] (io.mycat.backend.mysql.nio.MySQLConnectionHandler.handleLogNodeInfo(MySQLConnectionHandler.java:166)) - handleRowEofPacket MySQLConnection@730444724 [id=159] for node=ms, sql=SHOW COLUMNS FROM `ms`.`province`
2022-09-20 09:51:40.475 DEBUG [$_NIOREACTOR-3-RW] (io.mycat.server.NonBlockingSession.releaseConnection(NonBlockingSession.java:391)) - releaseConnection Connection@730444724 [id=159] for node=ms, sql=SHOW COLUMNS FROM `ms`.`province`
2022-09-20 09:51:40.475 DEBUG [$_NIOREACTOR-3-RW] (io.mycat.backend.datasource.PhysicalDatasource.releaseChannel(PhysicalDatasource.java:633)) - release channel MySQLConnection@730444724 [id=159, lastTime=1663638700467, user=root, schema=ms, old shema=ms, borrowed=true, fromSlaveDB=true, threadId=12, charset=utf8, txIsolation=3, autocommit=true, txReadonly=false, attachment=null, respHandler=null, host=172.168.2.32, port=3306, statusSync=null, writeQueue=0, modifiedSQLExecuted=false]	#读请求到slave01(172.168.2.32)
注：master02故障后，master02的slave也不对外提供服务
总结：当master02故障时，若master01之前在线，则会将写请求转移到master01
```






# 动态更改mycat配置
root@mysql-master01:/usr/local/mycat# mysql -uroot -h 172.168.2.35 -P 9066 -p
Enter password:		#123456
mysql> show @@server;
+--------------+-------------+--------------+------------+---------------+---------------+---------+--------+
| UPTIME       | USED_MEMORY | TOTAL_MEMORY | MAX_MEMORY | RELOAD_TIME   | ROLLBACK_TIME | CHARSET | STATUS |
+--------------+-------------+--------------+------------+---------------+---------------+---------+--------+
| 2m 58s 140ms |    40024552 |    257425408 |  954728448 | 1663555046467 |            -1 | utf8    | ON     |
+--------------+-------------+--------------+------------+---------------+---------------+---------+--------+
mysql> reload @@config_all;		#重载所有配置


# mycat管理端口
```
# 登录9066进行管理监控mycat
root@mysql-master01:/usr/local/mycat# mysql -uroot -h172.168.2.35 -P9066 -p
Enter password:

# 查看帮助
mysql> show @@help;
+--------------------------------------------------------------+--------------------------------------------+
| STATEMENT                                                    | DESCRIPTION                                |
+--------------------------------------------------------------+--------------------------------------------+
| show @@time.current                                          | Report current timestamp                   |
| show @@time.startup                                          | Report startup timestamp                   |
| show @@version                                               | Report Mycat Server version                |
| show @@server                                                | Report server status                       |
| show @@threadpool                                            | Report threadPool status                   |
| show @@database                                              | Report databases                           |
| show @@datanode                                              | Report dataNodes                           |
| show @@datanode where schema = ?                             | Report dataNodes                           |
| show @@datasource                                            | Report dataSources                         |
| show @@datasource where dataNode = ?                         | Report dataSources                         |
| show @@datasource.synstatus                                  | Report datasource data synchronous         |
| show @@datasource.syndetail where name=?                     | Report datasource data synchronous detail  |
| show @@datasource.cluster                                    | Report datasource galary cluster variables |
| show @@processor                                             | Report processor status                    |
| show @@command                                               | Report commands status                     |
| show @@connection                                            | Report connection status                   |
| show @@cache                                                 | Report system cache usage                  |
| show @@backend                                               | Report backend connection status           |
| show @@session                                               | Report front session details               |
| show @@connection.sql                                        | Report connection sql                      |
| show @@sql.execute                                           | Report execute status                      |
| show @@sql.detail where id = ?                               | Report execute detail status               |
| show @@sql                                                   | Report SQL list                            |
| show @@sql.high                                              | Report Hight Frequency SQL                 |
| show @@sql.slow                                              | Report slow SQL                            |
| show @@sql.resultset                                         | Report BIG RESULTSET SQL                   |
| show @@sql.sum                                               | Report  User RW Stat                       |
| show @@sql.sum.user                                          | Report  User RW Stat                       |
| show @@sql.sum.table                                         | Report  Table RW Stat                      |
| show @@parser                                                | Report parser status                       |
| show @@router                                                | Report router status                       |
| show @@heartbeat                                             | Report heartbeat status                    |
| show @@heartbeat.detail where name=?                         | Report heartbeat current detail            |
| show @@slow where schema = ?                                 | Report schema slow sql                     |
| show @@slow where datanode = ?                               | Report datanode slow sql                   |
| show @@sysparam                                              | Report system param                        |
| show @@syslog limit=?                                        | Report system mycat.log                    |
| show @@white                                                 | show mycat white host                      |
| show @@white.set=?,?                                         | set mycat white host,[ip,user]             |
| show @@directmemory=1 or 2                                   | show mycat direct memory usage             |
| show @@check_global -SCHEMA= ? -TABLE=? -retry=? -interval=? | check mycat global table consistency       |
| switch @@datasource name:index                               | Switch dataSource                          |
| kill @@connection id1,id2,...                                | Kill the specified connections             |
| stop @@heartbeat name:time                                   | Pause dataNode heartbeat                   |
| reload @@config                                              | Reload basic config from file              |
| reload @@config_all                                          | Reload all config from file                |
| reload @@route                                               | Reload route config from file              |
| reload @@user                                                | Reload user config from file               |
| reload @@sqlslow=                                            | Set Slow SQL Time(ms)                      |
| reload @@user_stat                                           | Reset show @@sql  @@sql.sum @@sql.slow     |
| rollback @@config                                            | Rollback all config from memory            |
| rollback @@route                                             | Rollback route config from memory          |
| rollback @@user                                              | Rollback user config from memory           |
| reload @@sqlstat=open                                        | Open real-time sql stat analyzer           |
| reload @@sqlstat=close                                       | Close real-time sql stat analyzer          |
| offline                                                      | Change MyCat status to OFF                 |
| online                                                       | Change MyCat status to ON                  |
| clear @@slow where schema = ?                                | Clear slow sql by schema                   |
| clear @@slow where datanode = ?                              | Clear slow sql by datanode                 |
+--------------------------------------------------------------+--------------------------------------------+



# 显示后端物理库连接信息，包括当前连接数，端口等信息
mysql> show @@backend;
+------------+------+---------+--------------+------+--------+---------+---------+-------+--------+----------+------------+--------+---------+---------+------------+-------------+
| processor  | id   | mysqlId | host         | port | l_port | net_in  | net_out | life  | closed | borrowed | SEND_QUEUE | schema | charset | txlevel | autocommit | tx_readonly |
+------------+------+---------+--------------+------+--------+---------+---------+-------+--------+----------+------------+--------+---------+---------+------------+-------------+
| Processor0 |  160 |      13 | 172.168.2.32 | 3306 |  24086 |   15690 |     175 |   358 | false  | false    |          0 | ms     | utf8:45 | 3       | true       | false       |
| Processor0 |  136 |      84 | 172.168.2.31 | 3306 |  34264 |  744250 |    4744 | 15658 | false  | false    |          0 | ms     | utf8:45 | 3       | true       | false       |
| Processor0 |  153 |      10 | 172.168.2.32 | 3306 |  24018 |   43762 |     373 |   658 | false  | false    |          0 | ms     | utf8:45 | 3       | true       | false       |
| Processor1 |  161 |     100 | 172.168.2.34 | 3306 |  59322 |      93 |      65 |    58 | false  | false    |          0 | ms     | utf8:45 | 3       | true       | false       |
| Processor1 |  132 |      82 | 172.168.2.31 | 3306 |  34252 |  693110 |    5151 | 15958 | false  | false    |          0 | ms     | utf8:45 | 3       | true       | false       |
| Processor1 |  150 |       8 | 172.168.2.32 | 3306 |  23994 |  131384 |    1011 |   938 | false  | false    |          0 | ms     | utf8:45 | 3       | true       | false       |
| Processor1 |  137 |      85 | 172.168.2.31 | 3306 |  34268 |  701864 |    4823 | 15658 | false  | false    |          0 | ms     | utf8:45 | 3       | true       | false       |
| Processor1 |  154 |      97 | 172.168.2.34 | 3306 |  59188 |   39505 |     581 |   658 | false  | false    |          0 | ms     | utf8:45 | 3       | true       | false       |
| Processor1 |  140 |      87 | 172.168.2.31 | 3306 |  34276 |  639380 |    4599 | 15058 | false  | false    |          0 | ms     | utf8:45 | 3       | true       | false       |
| Processor1 |  157 |      99 | 172.168.2.34 | 3306 |  59256 |   18264 |     197 |   358 | false  | false    |          0 | ms     | utf8:45 | 3       | true       | false       |
| Processor2 |  162 |      14 | 172.168.2.32 | 3306 |  24154 |      93 |      65 |    58 | false  | false    |          0 | ms     | utf8:45 | 3       | true       | false       |
| Processor2 |  133 |      83 | 172.168.2.31 | 3306 |  34254 |  705317 |    4999 | 15958 | false  | false    |          0 | ms     | utf8:45 | 3       | true       | false       |
| Processor2 |  151 |      96 | 172.168.2.34 | 3306 |  59180 |   42487 |     373 |   658 | false  | false    |          0 | ms     | utf8:45 | 3       | true       | false       |
| Processor2 |  138 |      86 | 172.168.2.31 | 3306 |  34272 |  653326 |    4866 | 15358 | false  | false    |          0 | ms     | utf8:45 | 3       | true       | false       |
| Processor2 |  155 |      95 | 172.168.2.34 | 3306 |  59186 |   39471 |     580 |   658 | false  | false    |          0 | ms     | utf8:45 | 3       | true       | false       |
| Processor2 |  125 |      80 | 172.168.2.31 | 3306 |  34242 |  740730 |    5210 | 16008 | false  | false    |          0 | ms     | utf8:45 | 3       | true       | false       |
| Processor2 |  158 |      98 | 172.168.2.34 | 3306 |  59254 |   15287 |     404 |   358 | false  | false    |          0 | ms     | utf8:45 | 3       | true       | false       |
| Processor3 |  130 |      81 | 172.168.2.31 | 3306 |  34246 |  718629 |    5078 | 15958 | false  | false    |          0 | ms     | utf8:45 | 3       | true       | false       |
| Processor3 |  152 |      11 | 172.168.2.32 | 3306 |  24012 |   40643 |     351 |   658 | false  | false    |          0 | ms     | utf8:45 | 3       | true       | false       |
| Processor3 |  156 |       9 | 172.168.2.32 | 3306 |  24010 |   40643 |     351 |   658 | false  | false    |          0 | ms     | utf8:45 | 3       | true       | false       |
| Processor3 |  126 |      94 | 172.168.2.34 | 3306 |  57690 | 5043611 |   36524 | 16008 | false  | false    |          0 | ms     | utf8:45 | 3       | true       | false       |
| Processor3 |  159 |      12 | 172.168.2.32 | 3306 |  24088 |   18810 |     197 |   358 | false  | false    |          0 | ms     | utf8:45 | 3       | true       | false       |
+------------+------+---------+--------------+------+--------+---------+---------+-------+--------+----------+------------+--------+---------+---------+------------+-------------+


# 显示当前前端客户端连接情况
mysql> show @@connection;
+------------+------+---------------+------+------------+------+--------+---------+--------+---------+---------------+-------------+------------+---------+------------+
| PROCESSOR  | ID   | HOST          | PORT | LOCAL_PORT | USER | SCHEMA | CHARSET | NET_IN | NET_OUT | ALIVE_TIME(S) | RECV_BUFFER | SEND_QUEUE | txlevel | autocommit |
+------------+------+---------------+------+------------+------+--------+---------+--------+---------+---------------+-------------+------------+---------+------------+
| Processor0 |   18 | 172.168.2.35  | 9066 |      12646 | root | NULL   | utf8:45 |    162 |    2983 |            57 |        4096 |          0 |         |            |
| Processor0 |   15 | 172.168.2.219 | 8066 |      64333 | root | NULL   | utf8:45 |   1546 |   23627 |          1871 |        4096 |          0 | 3       | true       |
| Processor2 |   13 | 172.168.2.219 | 8066 |      58524 | root | NULL   | utf8:45 |   6511 |  866182 |          5972 |        4096 |          0 | 3       | true       |
+------------+------+---------------+------+------------+------+--------+---------+--------+---------+---------------+-------------+------------+---------+------------+
-- 客户端tcp监听信息
PS C:\Users\0799> netstat -antop tcp | findstr :64333
  TCP    172.168.2.219:64333    172.168.2.35:8066      ESTABLISHED     19832    InHost
PS C:\Users\0799> netstat -antop tcp | findstr :58524
  TCP    172.168.2.219:58524    172.168.2.35:8066      ESTABLISHED     19832    InHost


# 当前线程池的执行情况，是否有积压(active_count)以及task_queue_size，后者为积压的待处理的SQL，若积压数目一直保值，则说明后端物理连接可能不够或者SQL执行比较缓慢
mysql> show @@threadpool;
+------------------+-----------+--------------+-----------------+----------------+------------+
| NAME             | POOL_SIZE | ACTIVE_COUNT | TASK_QUEUE_SIZE | COMPLETED_TASK | TOTAL_TASK |
+------------------+-----------+--------------+-----------------+----------------+------------+
| Timer            |         2 |            0 |               0 |          55121 |      55121 |
| BusinessExecutor |         8 |            0 |               0 |            991 |        991 |
+------------------+-----------+--------------+-----------------+----------------+------------+


# 当前后端物理库的心跳检测情况,RS_CODE为1表示心跳正常。注：172.168.2.35为我手动宕掉的，RS_CODE=-1为失败
mysql> show @@heartbeat;
+----------------+-------+--------------+------+---------+-------+--------+---------+--------------+---------------------+-------+
| NAME           | TYPE  | HOST         | PORT | RS_CODE | RETRY | STATUS | TIMEOUT | EXECUTE_TIME | LAST_ACTIVE_TIME    | STOP  |
+----------------+-------+--------------+------+---------+-------+--------+---------+--------------+---------------------+-------+
| mysql-master01 | mysql | 172.168.2.35 | 3306 |      -1 |     1 | idle   |   30000 | 1,2,1        | 2022-09-19 15:18:06 | false |
| mysql-master02 | mysql | 172.168.2.34 | 3306 |       1 |     0 | idle   |   30000 | 1,2,1        | 2022-09-19 15:18:06 | false |
| mysql-slave01  | mysql | 172.168.2.32 | 3306 |       1 |     0 | idle   |   30000 | 1,2,2        | 2022-09-19 15:18:06 | false |
| mysql-slave02  | mysql | 172.168.2.31 | 3306 |       1 |     0 | idle   |   30000 | 1,1,2        | 2022-09-19 15:18:06 | false |
+----------------+-------+--------------+------+---------+-------+--------+---------+--------------+---------------------+-------+
注：RS_CODE=1为连接正常，RS_CODE=-1为失败，172.168.2.35为我手动宕掉的


# 显示数据节点的访问情况，包括每个数据节点当前活动连接数(active),空闲连接数（idle）以及最大连接数(maxCon) size，EXECUTE参数表示从该节点获取连接的次数，次数越多，说明访问该节点越多
mysql> show @@datanode;
+------+--------------+-------+-------+--------+------+------+---------+------------+----------+---------+---------------+
| NAME | DATHOST      | INDEX | TYPE  | ACTIVE | IDLE | SIZE | EXECUTE | TOTAL_TIME | MAX_TIME | MAX_SQL | RECOVERY_TIME |
+------+--------------+-------+-------+--------+------+------+---------+------------+----------+---------+---------------+
| ms   | ops-mysql/ms |     1 | mysql |      0 |    8 | 1000 |    1789 |          0 |        0 |       0 |            -1 |
+------+--------------+-------+-------+--------+------+------+---------+------------+----------+---------+---------------+


# 显示当前processors的处理情况，包括每个processor的IO吞吐量(NET_IN/NET_OUT)、IO队列的积压情况(R_QUEY/W_QUEUE)，Socket Buffer Pool的使用情况 BU_PERCENT为已使用的百分比、BU_WARNS为Socket Buffer Pool不够时，临时创建的新的BUFFER的次数，若百分比经常超过90%并且BU_WARNS>0，则表明BUFFER不够，需要增大，参见性能调优手册。
mysql> show @@processor;
+------------+---------+---------+-------------+---------+---------+--------------+--------------+------------+----------+----------+----------+
| NAME       | NET_IN  | NET_OUT | REACT_COUNT | R_QUEUE | W_QUEUE | FREE_BUFFER  | TOTAL_BUFFER | BU_PERCENT | BU_WARNS | FC_COUNT | BC_COUNT |
+------------+---------+---------+-------------+---------+---------+--------------+--------------+------------+----------+----------+----------+
| Processor0 | 3000248 |  732147 |           0 |       0 |       0 | 687194767350 | 687194767360 |          0 |        0 |        2 |        3 |
| Processor1 | 4354755 |   47843 |           0 |       0 |       0 | 687194767350 | 687194767360 |          0 |        0 |        0 |        8 |
| Processor2 | 4220711 |  932680 |           0 |       0 |       0 | 687194767350 | 687194767360 |          0 |        0 |        1 |        8 |
| Processor3 | 7577861 |   67598 |           0 |       0 |       0 | 687194767350 | 687194767360 |          0 |        0 |        1 |        5 |
+------------+---------+---------+-------------+---------+---------+--------------+--------------+------------+----------+----------+----------+


# 显示缓存的使用情况，对于性能监控和调优很有价值，MAX为缓存的最大值（记录个数），CUR为当前已经在缓存中的数量，ACESS为缓存读次数，HIT为缓存命中次数，PUT 为写缓存次数，LAST_XX为最后操作时间戳，比较重要的几个参数：CUR：若CUR接近MAX，而PUT大于MAX很多，则表明MAX需要增大，HIT/ACCESS为缓存命中率，这个值越高越好。
mysql> show @@cache;
+-------------------------------------+-------+------+--------+------+------+---------------+----------+
| CACHE                               | MAX   | CUR  | ACCESS | HIT  | PUT  | LAST_ACCESS   | LAST_PUT |
+-------------------------------------+-------+------+--------+------+------+---------------+----------+
| ER_SQL2PARENTID                     |  1000 |    0 |      0 |    0 |    0 |             0 |        0 |
| SQLRouteCache                       | 10000 |    0 |     79 |    0 |    0 | 1663572122365 |        0 |
| TableID2DataNodeCache.TESTDB_ORDERS | 50000 |    0 |      0 |    0 |    0 |             0 |        0 |
+-------------------------------------+-------+------+--------+------+------+---------------+----------+



# 杀掉客户端的连接，参数为连接的ID值，通过show @@connection，可以展示当前连接到MyCAT的所有客户端进程，若某个进程异常，则可以通过该命令杀掉连接
mysql> show @@connection;
+------------+------+---------------+------+------------+------+--------+---------+--------+---------+---------------+-------------+------------+---------+------------+
| PROCESSOR  | ID   | HOST          | PORT | LOCAL_PORT | USER | SCHEMA | CHARSET | NET_IN | NET_OUT | ALIVE_TIME(S) | RECV_BUFFER | SEND_QUEUE | txlevel | autocommit |
+------------+------+---------------+------+------------+------+--------+---------+--------+---------+---------------+-------------+------------+---------+------------+
| Processor0 |   18 | 172.168.2.35  | 9066 |      12646 | root | NULL   | utf8:45 |    369 |   10743 |          1187 |        4096 |          0 |         |            |
| Processor0 |   15 | 172.168.2.219 | 8066 |      64333 | root | NULL   | utf8:45 |   1626 |   24932 |          3001 |        4096 |          0 | 3       | true       |
| Processor2 |   13 | 172.168.2.219 | 8066 |      58524 | root | NULL   | utf8:45 |   6714 |  898919 |          7102 |        4096 |          0 | 3       | true       |
| Processor3 |   19 | 172.168.2.32  | 8066 |      58592 | root | mycat  | utf8:45 |    237 |    1255 |           344 |        4096 |          0 | 3       | true       |
+------------+------+---------------+------+------------+------+--------+---------+--------+---------+---------------+-------------+------------+---------+------------+
mysql> kill @@connection 19;	#杀掉链接
mysql> show @@connection;
+------------+------+---------------+------+------------+------+--------+---------+--------+---------+---------------+-------------+------------+---------+------------+
| PROCESSOR  | ID   | HOST          | PORT | LOCAL_PORT | USER | SCHEMA | CHARSET | NET_IN | NET_OUT | ALIVE_TIME(S) | RECV_BUFFER | SEND_QUEUE | txlevel | autocommit |
+------------+------+---------------+------+------------+------+--------+---------+--------+---------+---------------+-------------+------------+---------+------------+
| Processor0 |   18 | 172.168.2.35  | 9066 |      12646 | root | NULL   | utf8:45 |    416 |   11620 |          1207 |        4096 |          0 |         |            |
| Processor0 |   15 | 172.168.2.219 | 8066 |      64333 | root | NULL   | utf8:45 |   1626 |   24932 |          3021 |        4096 |          0 | 3       | true       |
| Processor2 |   13 | 172.168.2.219 | 8066 |      58524 | root | NULL   | utf8:45 |   6714 |  898919 |          7122 |        4096 |          0 | 3       | true       |
+------------+------+---------------+------+------------+------+--------+---------+--------+---------+---------------+-------------+------------+---------+------------+
mysql> show tables;		#此时客户端连接报错
ERROR 2013 (HY000): Lost connection to MySQL server during query

```

### 实现mysql多主多从读写分离之配置多个数据库

```
# server.xml配置
root@mysql-master01:/usr/local/mycat/conf# cat server.xml
        <user name="root" defaultAccount="true">
				<!--用户密码 -->
                <property name="password">123456</property>		
				<!--用户数据库，表示给此用户开启多个数据库 -->
                <property name="schemas">ms,db01,db02,db03</property>
				<!--是否只读，默认为false，则为读写权限。此开关优先级大于privileges check="true" -->
                <property name="readOnly">true</property>
				<!--benchmark 基准，当前端的整体connection数达到基准值时, 对来自该账户的请求开始拒绝连接，0或不设表示不限制 -->
                <property name="benchmark">11111</property>
				<!--用户默认数据库 -->
				<!--No MyCAT Database selected 错误前会尝试使用该schema作为schema，不设置则为null,报错 -->
                <property name="defaultSchema">ms</property>
                
                <!-- 表级 DML 权限设置 -->
				<!--check为true表示开启DML控制 -->
                <privileges check="true">
                        <!--0000 表示对 "insert,update,select,delete" 权限进行关闭，1为开启-->
						<!--数据库级别DML权限 -->
                        <schema name="ms" dml="1110" >
								<!--表级别DML权限，优先数据库级别权限 -->
                                <table name="province" dml="0010"></table>
                        </schema>
                        <schema name="db01" dml="1110" >
                                <table name="province01" dml="1000"></table>
                        </schema>
                        <schema name="db02" dml="1110" >
                                <table name="province02" dml="0100"></table>
                        </schema>
                        <schema name="db03" dml="1110" >
                                <table name="province03" dml="0000"></table>
                        </schema>
                </privileges>
        </user>

# schema.xml配置
root@mysql-master01:/usr/local/mycat/conf# cat schema.xml
<?xml version="1.0"?>
<!DOCTYPE mycat:schema SYSTEM "schema.dtd">
<mycat:schema xmlns:mycat="http://io.mycat/">
		<!--数schema name必须跟server.xml中的name保持一致，否则会报错 -->
		<!--当该值设置为 true 时，如果我们执行语句**select * from TESTDB.travelrecord;**则MyCat会把语句修改为**select * from travelrecord;**。即把表示schema的字符去掉，避免发送到后端数据库执行时报**（ERROR 1146 (42S02): Table ‘testdb.travelrecord’ doesn’t exist）。**不过，即使设置该值为 true ，如果语句所带的是并非是schema指定的名字，例如：**select * from db1.travelrecord;** 那么MyCat并不会删除db1这个字段，如果没有定义该库的话则会报错，所以在提供SQL语句的最好是不带这个字段 -->
		<!-- 当该值设置为某个数值时。每条执行的SQL语句，如果没有加上limit语句，MyCat也会自动的加上所对应的值。例如设置值为100，执行**select * from TESTDB.travelrecord;**的效果为和执行**select * from TESTDB.travelrecord limit 100;**相同。 -->
		<!--dataNode名称为对应数据节点名称 -->
        <schema name="ms" checkSQLschema="false" sqlMaxLimit="100" dataNode="ms">
        </schema>
        <schema name="db01" checkSQLschema="false" sqlMaxLimit="100" dataNode="db01">
        </schema>
        <schema name="db02" checkSQLschema="false" sqlMaxLimit="100" dataNode="db02">
        </schema>
        <schema name="db03" checkSQLschema="false" sqlMaxLimit="100" dataNode="db03">
        </schema>

		<!--dataNode名称(数据节点名称)、数据主机名称、数据主机中的真实数据库名称-->
        <dataNode name="ms" dataHost="ops-mysql" database="ms" />
        <dataNode name="db01" dataHost="ops-mysql" database="db01" />
        <dataNode name="db02" dataHost="ops-mysql" database="db02" />
        <dataNode name="db03" dataHost="ops-mysql" database="db03" />

		<!--数据主机名称、maxCon表示每个读写实例连接池的最大连接、minCon表示每个读写实例连接池的初始化连接-->
		<!--balance="1" 全部的readHost与stand by writeHost参与select语句的负载均衡，简单的说，当双主双从模式(M1->S1，M2->S2，并且M1与 M2互为主备)，正常情况下，M2,S1,S2都参与select语句的负载均衡。 -->
		<!--writeType="0" 所有写操作发送到配置的第一个writeHost，第一个挂了切到还生存的第二个writeHost，重新启动后已切换后的为准，切换记录在配置文件中:dnindex.properties -->
		<!--switchType="2" 基于MySQL主从同步的状态决定是否切换。-->
        <dataHost name="ops-mysql" maxCon="1000" minCon="10" balance="1"
                          writeType="0" dbType="mysql" dbDriver="native" switchType="2"  slaveThreshold="100">
				<!--switchType="2" 时心跳检查语句必须为：show slave status-->
                <heartbeat>show slave status</heartbeat>
                <writeHost host="mysql-master01" url="172.168.2.35:3306" user="root"
                                   password="test666">
                        <readHost host="mysql-slave01" url="172.168.2.32:3306" user="root"
                                   password="test666">
                        </readHost>
                </writeHost>
                <writeHost host="mysql-master02" url="172.168.2.34:3306" user="root"
                                   password="test666">
                        <readHost host="mysql-slave02" url="172.168.2.31:3306" user="root"
                                   password="test666">
                        </readHost>
                </writeHost>
        </dataHost>

================纯配置文件server.xml=================
       <user name="root" defaultAccount="true">
                <property name="password">123456</property>
                <property name="schemas">ms,db01,db02,db03</property>
                <property name="readOnly">true</property>
                <property name="benchmark">11111</property>
                <property name="defaultSchema">ms</property>
                <!--No MyCAT Database selected 错误前会尝试使用该schema作为schema，不设置则为null,报错 -->

                <!-- 表级 DML 权限设置 -->
                <privileges check="true">
                        <!--0000 as insert,update,select,delete close-->
                        <schema name="ms" dml="1110" >
                                <table name="province" dml="0010"></table>
                        </schema>
                        <schema name="db01" dml="1110" >
                                <table name="province01" dml="1000"></table>
                        </schema>
                        <schema name="db02" dml="1110" >
                                <table name="province02" dml="0100"></table>
                        </schema>
                        <schema name="db03" dml="1110" >
                                <table name="province03" dml="0000"></table>
                        </schema>
                </privileges>
        </user>
		<!--只读用户也可以使用set命令，很危险-->
        <user name="user">
                <property name="password">user</property>
                <property name="schemas">ms</property>
                <property name="readOnly">true</property>
                <property name="defaultSchema">ms</property>
        </user>

================纯配置文件schema.xml=================
<?xml version="1.0"?>
<!DOCTYPE mycat:schema SYSTEM "schema.dtd">
<mycat:schema xmlns:mycat="http://io.mycat/">
        <schema name="ms" checkSQLschema="false" sqlMaxLimit="100" dataNode="ms">
        </schema>
        <schema name="db01" checkSQLschema="false" sqlMaxLimit="100" dataNode="db01">
        </schema>
        <schema name="db02" checkSQLschema="false" sqlMaxLimit="100" dataNode="db02">
        </schema>
        <schema name="db03" checkSQLschema="false" sqlMaxLimit="100" dataNode="db03">
        </schema>


        <dataNode name="ms" dataHost="ops-mysql" database="ms" />
        <dataNode name="db01" dataHost="ops-mysql" database="db01" />
        <dataNode name="db02" dataHost="ops-mysql" database="db02" />
        <dataNode name="db03" dataHost="ops-mysql" database="db03" />

        <dataHost name="ops-mysql" maxCon="1000" minCon="10" balance="1"
                          writeType="0" dbType="mysql" dbDriver="native" switchType="2"  slaveThreshold="100">
                <heartbeat>show slave status</heartbeat>
                <writeHost host="mysql-master01" url="172.168.2.35:3306" user="root"
                                   password="test666">
                        <readHost host="mysql-slave01" url="172.168.2.32:3306" user="root"
                                   password="test666">
                        </readHost>
                </writeHost>
                <writeHost host="mysql-master02" url="172.168.2.34:3306" user="root"
                                   password="test666">
                        <readHost host="mysql-slave02" url="172.168.2.31:3306" user="root"
                                   password="test666">
                        </readHost>
                </writeHost>
        </dataHost>
</mycat:schema>
=====================================================
```


### 实现mysql多主多从读写分离之配置IP白名单和SQL黑名单

| item           	| default | description      			  | 
| ----------------- | ------- | ----------------------------- |
| selelctAllow		| true	  | 是否允许执行SELECT语句		  |
| deleteAllow		| true	  | 是否允许执行DELETE语句        |
| updateAllow		| true	  | 是否允许执行UPDATE语句        |
| insertAllow		| true	  | 是否允许执行INSERT语句        |
| createTableAllow	| true	  | 是否允许创建表                |
| setAllow			| true	  | 是否允许使用SET语法           |
| alterTableAllow	| true	  | 是否允许执行Alter Table语句   |
| dropTableAllow	| true	  | 是否允许修改表                |
| commitAllow		| true	  | 是否允许执行commit操作        |
| rollbackAllow		| true	  | 是否允许执行roll back操作     |

```
======================server.xml======================
        <!-- IP白名单 -->^M
        <firewall>^M
           <whitehost>^M
              <host host="127.*" user="root"/>^M
              <!-- 以下用户所在的IP都可以登录mycat-->^M
              <host host="172.168.2.*" user="root"/>^M
           </whitehost>^M
        <!-- SQL黑名单 -->^M
		<!-- SQL黑名单一开启表示对应的sql将受管控，而且此功能影响mycat管理端口进行管理，无法进行重置配置文件-->^M
       <blacklist check="true">^M
              <property name="setAllow">false</property>
              <property name="commentAllow">true</property>
              <property name="noneBaseStatementAllow">true</property>
              <property name="multiStatementAllow">true</property>
              <property name="commentAllow">true</property>

              <!--
              <property name="dropTableAllow">true</property>
              <property name="alterTableAllow">true</property>
              <property name="createTableAllow"></property>
              <property name="insertAllow">true</property>
              <property name="updateAllow">true</property>
              <property name="deleteAllow">true</property>
              <property name="selelctAllow">true</property>
              <property name="selectAllColumnAllow">true</property>
              <property name="selectIntoAllow">true</property>
              <property name="replaceAllow">true</property>
              <property name="callAllow">true</property>
              <property name="mergeAllow">true</property>
              <property name="truncateAllow">false</property>
              <property name="commentAllow">true</property>
              <property name="useAllow">true</property>
              <property name="describeAllow">true</property>
              <property name="commitAllow">true</property>
              <property name="rollbackAllow">true</property>
              -->
       </blacklist>^M
        </firewall>^M
=====================================================
```

#### 应用强制指定走读走写节点
```
# 强制走从：
/*!mycat:db_type=slave*/ select * from travelrecord
或
/*#mycat:db_type=slave*/ select * from travelrecord

# 强制走写：
/*!mycat:db_type=master*/ select * from travelrecord
或
/*#mycat:db_type=master*/ select * from travelrecord
```

#### 遗留问题
```
1. 普通用户可以对mycat执行set语句
2. 普通用户可以使用除增删改查之外的语句，如果可以把用户的权限限定在增删改查之内就好了


```








