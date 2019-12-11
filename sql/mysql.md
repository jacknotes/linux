#mysql
<pre>
###存储过程
#### procedure in
mysql> \d $$;
mysql> create procedure up_test1<in v_int int>
    -> begin
    -> select v_int;
    -> set v_int = v_int +1;
    -> select v_int;
    -> end$$;
mysql> \d ;
mysql> set @a=10;
mysql> call up_test1(a)
    -> ;
+-------+
| v_int |
+-------+
|    10 |
+-------+
1 row in set (0.00 sec)

+-------+
| v_int |
+-------+
|    11 |
+-------+
1 row in set (0.00 sec)
mysql> select @a;
+------+
| @a   |
+------+
|   10 |
+------+
#注：in进去的变量不会改变同名变量本身值
#### procedure  out
mysql> delimiter //   #设定结束符
mysql> CREATE PROCEDURE simpleproc (OUT param1 INT)  #新建存储过程并传输出变量param1，变量类型为int
    -> BEGIN
    ->   SELECT COUNT(*) INTO param1 FROM t;  #将表中的行数赋值给变量param1
    -> END//
Query OK, 0 rows affected (0.00 sec)
mysql> delimiter ;   #设定回结束符
mysql> CALL simpleproc(@a);  #调用存储过程
mysql> SELECT @a;   #输出out出来的变量a的值。 注：@表示局部变量，@@表示全局变量
+------+
| @a   |
+------+
| 3    |
+------+
#注：out出来的变量会改变同名变量本身值
#注：inout表示作为输入参数的变量先把本身值赋给存储过程，然后存储过程再out给这个变量。最后从而改变这个同步变量值本身

####IF...ELSEIF语句
IF search_condition THEN statement_list
    [ELSEIF search_condition THEN statement_list] ...
    [ELSE statement_list]
END IF

####CASE WHEN语句
DELIMITER |

CREATE PROCEDURE p()
  BEGIN
    DECLARE v INT DEFAULT 1;

    CASE v
      WHEN 2 THEN SELECT v;
      WHEN 3 THEN SELECT 0;
      ELSE
        BEGIN
        END;
    END CASE;
  END;

select name,(case age when 10 then '未成年' when 20 then '少年' end) as '年龄' from users;
select name,ifnull(age) as '年龄' from users;   #ifnull()函数跟sqlserver的isnull()函数一样

####WHILE语句
CREATE PROCEDURE dowhile()
BEGIN
  DECLARE v1 INT DEFAULT 5;

  WHILE v1 > 0 DO
    ...
    SET v1 = v1 - 1;
  END WHILE;
END;

CAST('var' as int)  #转换函数

#例：
\d $$;
CREATE PROCEDURE dowhile()
BEGIN
  DECLARE a INT DEFAULT 0;
  DECLARE b INT DEFAULT 1;
  WHILE b <=100  DO
	 select max(id) into a from user;
     set a = a +1;
	 insert into user (id,name,age) values (a,'jack',25)
	 set b = b +1;
  END WHILE;
END;
$$;
\d ;
call dowhile;

####repeat和loop语句
###repeat 
Examples:
mysql> delimiter //

mysql> CREATE PROCEDURE dorepeat(p1 INT)
    -> BEGIN
    ->   SET @x = 0;
    ->   REPEAT
    ->     SET @x = @x + 1;
    ->   UNTIL @x > p1 END REPEAT;
    -> END
    -> //
Query OK, 0 rows affected (0.00 sec)

mysql> CALL dorepeat(1000)//
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT @x//
+------+
| @x   |
+------+
| 1001 |
+------+
1 row in set (0.00 sec)
#例：
mysql> delimiter //
mysql> CREATE PROCEDURE dorepeat(p1 INT)
    -> BEGIN
    ->     DECLARE imin INT DEFAULT 0;
  	-> 	   DECLARE imax INT DEFAULT 1;
	->	   select min(id) into imin from user;
	->     select max(id) into imax from user;
    ->   REPEAT   #进入循环
	->		if imin % 2 = 0 then
	->			update user set genter = 'F' WHERE id=imin;
	->		end if 
	->      set imin=imin+1;
    ->   UNTIL imin > imax   #满足条件则退出循环
	-> END REPEAT;  #循环结束语句
    -> END  
    -> //
mysql> delimiter ;
mysql> CALL dorepeat(1000);
###loop
Examples:
CREATE PROCEDURE doiterate(p1 INT)
BEGIN
  label1: LOOP
    SET p1 = p1 + 1;
    IF p1 < 10 THEN
      ITERATE label1;
    END IF;
    LEAVE label1;
  END LOOP label1;
  SET @x = p1;
END;
#例：
mysql> delimiter //
mysql> CREATE PROCEDURE doloop(p1 INT)
    -> BEGIN
    ->     DECLARE imin INT DEFAULT 0;
  	-> 	   DECLARE imax INT DEFAULT 1;
	->	   select min(id) into imin from user;
	->     select max(id) into imax from user;
    -> myloop:loop   #进入循环
	->		if imin % 2 = 0 then
	->			update user set genter = 'F' WHERE id=imin;
	->		end if 
	->      set imin=imin+1;
    ->   if imin > imax then  #满足条件则退出循环
	->		leave myloop;
	->	 end if;
	-> END loop myloop;  #循环结束语句
    -> END  
    -> //
mysql> delimiter ;
mysql> CALL doloop(1000);

####定义条件和处理
mysql> delimiter //
mysql>  create procedure up_test2()
    ->  begin
    ->  declare continue handler for sqlstate '42S02' set @a=1;
    ->  insert into user value (20,'jack');
    ->  select 5;
    -> end
    ->  $$;
mysql> delimiter ;
mysql> call up_test2 ;
+---+
| 5 |
+---+
| 5 |
+---+

####存储过程的管理
mysql> show procedure status where db='jack'\G;   #查看某个数据库的存储过程
*************************** 1. row ***************************
                  Db: jack
                Name: up_test1
                Type: PROCEDURE
             Definer: root@localhost
            Modified: 2019-08-31 15:21:51
             Created: 2019-08-31 15:21:51
       Security_type: DEFINER
             Comment:
character_set_client: utf8
collation_connection: utf8_general_ci
  Database Collation: utf8_general_ci
*************************** 2. row ***************************
                  Db: jack
                Name: up_test2
                Type: PROCEDURE
             Definer: root@localhost
            Modified: 2019-08-31 17:33:44
             Created: 2019-08-31 17:33:44
       Security_type: DEFINER
             Comment:
character_set_client: utf8
collation_connection: utf8_general_ci
  Database Collation: utf8_general_ci

mysql> select specific_name from mysql.proc;  #查看所有存储过程
+-------------------------------------+
| specific_name                       |
+-------------------------------------+
| extract_schema_from_file_name       |
| extract_table_from_file_name        |
| format_bytes                        |
| format_path                         |
| format_statement                    |
| format_time                         |
| list_add                            |
| list_drop                           |
| ps_is_account_enabled               |
| ps_is_consumer_enabled              |
| ps_is_instrument_default_enabled    |
| ps_is_instrument_default_timed      |
| ps_is_thread_instrumented           |
| ps_thread_id                        |
| ps_thread_account                   |
| ps_thread_stack                     |
| ps_thread_trx_info                  |
| quote_identifier                    |
| sys_get_config                      |
| version_major                       |
| version_minor                       |
| version_patch                       |
| create_synonym_db                   |
| execute_prepared_stmt               |
| diagnostics                         |
| ps_statement_avg_latency_histogram  |
| ps_trace_statement_digest           |
| ps_trace_thread                     |
| ps_setup_disable_background_threads |
| ps_setup_disable_consumer           |
| ps_setup_disable_instrument         |
| ps_setup_disable_thread             |
| ps_setup_enable_background_threads  |
| ps_setup_enable_consumer            |
| ps_setup_enable_instrument          |
| ps_setup_enable_thread              |
| ps_setup_reload_saved               |
| ps_setup_reset_to_default           |
| ps_setup_save                       |
| ps_setup_show_disabled              |
| ps_setup_show_disabled_consumers    |
| ps_setup_show_disabled_instruments  |
| ps_setup_show_enabled               |
| ps_setup_show_enabled_consumers     |
| ps_setup_show_enabled_instruments   |
| ps_truncate_all_tables              |
| statement_performance_analyzer      |
| table_exists                        |
| up_test1                            |
| up_test2                            |
+-------------------------------------+
50 rows in set (0.00 sec)
mysql> select * from mysql.proc where db = 'jack' limit 1 \G; #查看指定数据库的存储过程并限定行显示
*************************** 1. row ***************************
                  db: jack
                name: up_test1
                type: PROCEDURE
       specific_name: up_test1
            language: SQL
     sql_data_access: CONTAINS_SQL
    is_deterministic: NO
       security_type: DEFINER
          param_list: in v_int int
             returns:
                body: begin
select v_int;
set v_int = v_int +1;
select v_int;
end
             definer: root@localhost
             created: 2019-08-31 15:21:51
            modified: 2019-08-31 15:21:51
            sql_mode: ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
             comment:
character_set_client: utf8
collation_connection: utf8_general_ci
        db_collation: utf8_general_ci
           body_utf8: begin
select v_int;
set v_int = v_int +1;
select v_int;
end
1 row in set (0.00 sec)

mysql> show create procedure jack.up_test2\G;  #查看存储过程的内容
*************************** 1. row ***************************
           Procedure: up_test2
            sql_mode: ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
    Create Procedure: CREATE DEFINER=`root`@`localhost` PROCEDURE `up_test2`()
begin
 declare continue handler for sqlstate '42S02' set @a=1;
 insert into user value (20,'jack');
 select 5;
end
character_set_client: utf8
collation_connection: utf8_general_ci
  Database Collation: utf8_general_ci
1 row in set (0.00 sec)
#修改存储过程
alter procedure up_test1 no sql;
alter procedure up_test1 comment "添加注释";
注：mysql添加注释有三种方法，1.#号开头 2./**/包括 3.--  开头，双横线后一定有一个空格才行

####函数的创建
函数分类：
	内置函数、自定义函数
#自定义函数
mysql> show global variables like '%fun%';
+---------------------------------+-------+
| Variable_name                   | Value |
+---------------------------------+-------+
| log_bin_trust_function_creators | OFF   |   #先要设为ON才可以开启自定义函数 
+---------------------------------+-------+
mysql> set global log_bin_trust_function_creators=1$$;
mysql> create function fun_sum(a int,b int)  #新建函数
    -> returns int  #指定要返回值的类型
    -> BEGIN
    -> return a+b;  #返回值
    -> end
    -> $$;
Query OK, 0 rows affected (0.00 sec)
mysql> select fun_sum(1,3);  #调用函数
+--------------+
| fun_sum(1,3) |
+--------------+
|            4 |
+--------------+
mysql> show create function fun_sum\G;   #查看
*************************** 1. row ***************************
            Function: fun_sum
            sql_mode: ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
     Create Function: CREATE DEFINER=`root`@`localhost` FUNCTION `fun_sum`(a int,b int) RETURNS int(11)
BEGIN
return a+b;
end
character_set_client: utf8
collation_connection: utf8_general_ci
  Database Collation: utf8_general_ci
1 row in set (0.00 sec)
mysql> select specific_name,db,name,type from mysql.proc;   #查看数据库服务器的所有存储过程和函数
+-------------------------------------+------+-------------------------------------+-----------+
| specific_name                       | db   | name                                | type      |
+-------------------------------------+------+-------------------------------------+-----------+
| extract_schema_from_file_name       | sys  | extract_schema_from_file_name       | FUNCTION  |
| extract_table_from_file_name        | sys  | extract_table_from_file_name        | FUNCTION  |
| format_bytes                        | sys  | format_bytes                        | FUNCTION  |
| format_path                         | sys  | format_path                         | FUNCTION  |
| format_statement                    | sys  | format_statement                    | FUNCTION  |
| format_time                         | sys  | format_time                         | FUNCTION  |
| list_add                            | sys  | list_add                            | FUNCTION  |
| list_drop                           | sys  | list_drop                           | FUNCTION  |
| ps_is_account_enabled               | sys  | ps_is_account_enabled               | FUNCTION  |
| ps_is_consumer_enabled              | sys  | ps_is_consumer_enabled              | FUNCTION  |
| ps_is_instrument_default_enabled    | sys  | ps_is_instrument_default_enabled    | FUNCTION  |
| ps_is_instrument_default_timed      | sys  | ps_is_instrument_default_timed      | FUNCTION  |
| ps_is_thread_instrumented           | sys  | ps_is_thread_instrumented           | FUNCTION  |
| ps_thread_id                        | sys  | ps_thread_id                        | FUNCTION  |
| ps_thread_account                   | sys  | ps_thread_account                   | FUNCTION  |
| ps_thread_stack                     | sys  | ps_thread_stack                     | FUNCTION  |
| ps_thread_trx_info                  | sys  | ps_thread_trx_info                  | FUNCTION  |
| quote_identifier                    | sys  | quote_identifier                    | FUNCTION  |
| sys_get_config                      | sys  | sys_get_config                      | FUNCTION  |
| version_major                       | sys  | version_major                       | FUNCTION  |
| version_minor                       | sys  | version_minor                       | FUNCTION  |
| version_patch                       | sys  | version_patch                       | FUNCTION  |
| create_synonym_db                   | sys  | create_synonym_db                   | PROCEDURE |
| execute_prepared_stmt               | sys  | execute_prepared_stmt               | PROCEDURE |
| diagnostics                         | sys  | diagnostics                         | PROCEDURE |
| ps_statement_avg_latency_histogram  | sys  | ps_statement_avg_latency_histogram  | PROCEDURE |
| ps_trace_statement_digest           | sys  | ps_trace_statement_digest           | PROCEDURE |
| ps_trace_thread                     | sys  | ps_trace_thread                     | PROCEDURE |
| ps_setup_disable_background_threads | sys  | ps_setup_disable_background_threads | PROCEDURE |
| ps_setup_disable_consumer           | sys  | ps_setup_disable_consumer           | PROCEDURE |
| ps_setup_disable_instrument         | sys  | ps_setup_disable_instrument         | PROCEDURE |
| ps_setup_disable_thread             | sys  | ps_setup_disable_thread             | PROCEDURE |
| ps_setup_enable_background_threads  | sys  | ps_setup_enable_background_threads  | PROCEDURE |
| ps_setup_enable_consumer            | sys  | ps_setup_enable_consumer            | PROCEDURE |
| ps_setup_enable_instrument          | sys  | ps_setup_enable_instrument          | PROCEDURE |
| ps_setup_enable_thread              | sys  | ps_setup_enable_thread              | PROCEDURE |
| ps_setup_reload_saved               | sys  | ps_setup_reload_saved               | PROCEDURE |
| ps_setup_reset_to_default           | sys  | ps_setup_reset_to_default           | PROCEDURE |
| ps_setup_save                       | sys  | ps_setup_save                       | PROCEDURE |
| ps_setup_show_disabled              | sys  | ps_setup_show_disabled              | PROCEDURE |
| ps_setup_show_disabled_consumers    | sys  | ps_setup_show_disabled_consumers    | PROCEDURE |
| ps_setup_show_disabled_instruments  | sys  | ps_setup_show_disabled_instruments  | PROCEDURE |
| ps_setup_show_enabled               | sys  | ps_setup_show_enabled               | PROCEDURE |
| ps_setup_show_enabled_consumers     | sys  | ps_setup_show_enabled_consumers     | PROCEDURE |
| ps_setup_show_enabled_instruments   | sys  | ps_setup_show_enabled_instruments   | PROCEDURE |
| ps_truncate_all_tables              | sys  | ps_truncate_all_tables              | PROCEDURE |
| statement_performance_analyzer      | sys  | statement_performance_analyzer      | PROCEDURE |
| table_exists                        | sys  | table_exists                        | PROCEDURE |
| up_test1                            | jack | up_test1                            | PROCEDURE |
| up_test2                            | jack | up_test2                            | PROCEDURE |
| fun_sum                             | jack | fun_sum                             | FUNCTION  |
+-------------------------------------+------+-------------------------------------+-----------+

####视图的创建
CREATE
    [OR REPLACE]
    [ALGORITHM = {UNDEFINED | MERGE | TEMPTABLE}]
    [DEFINER = { user | CURRENT_USER }]
    [SQL SECURITY { DEFINER | INVOKER }]
    VIEW view_name [(column_list)]
    AS select_statement
    [WITH [CASCADED | LOCAL] CHECK OPTION]

mysql> create or replace view v_test as  #新建或替换存在的视图
    -> select id,name from info;
视图作用：
	1. 对权限的把控，只允许员工查看某几列数据
	2. 例如只允许员工查看领工资的次数
	3. 表常常用得到时可以创建视图

mysql> use jack
Database changed
mysql> create table info(
    -> id int auto_increment not null primary key,
    -> name varchar(30) not null,
    -> age int,
    -> gender varchar(2))
    -> character set utf8;
Query OK, 0 rows affected (0.04 sec)
mysql> create procedure up_insert(in a int)
    -> begin
    -> declare icount int;
    -> select count(id) into icount from info;
    -> set icount = icount +1;
    -> while icount <= a do
    -> insert into info (id,name) values (icount,'jack');
    -> set icount =icount +1;
    -> end while;
    -> end$$;
Query OK, 0 rows affected (0.00 sec)
mysql> create or replace view info_money as
    -> select name,money from info order by money desc limit 10;
Query OK, 0 rows affected (0.01 sec)
mysql> select * from info_money;
+------+-------+
| name | money |
+------+-------+
| jack | 10000 |
| jack |  8500 |
| jack |  5000 |
| jack |  NULL |
| jack |  NULL |
| jack |  NULL |
| jack |  NULL |
| jack |  NULL |
| jack |  NULL |
| jack |  NULL |
+------+-------+
10 rows in set (0.00 sec)
mysql> insert into info (name,age,gender,money,mon_count) value ('bob',43,'M',15000,1);
Query OK, 1 row affected (0.01 sec)
mysql> select * from info_money;
+------+-------+
| name | money |
+------+-------+
| bob  | 15000 |    #新插入的15000自动排序在里面了
| jack | 10000 |
| jack |  8500 |
| jack |  5000 |
| jack |  NULL |
| jack |  NULL |
| jack |  NULL |
| jack |  NULL |
| jack |  NULL |
| jack |  NULL |
+------+-------+

####视图的管理
mysql> select * from information_schema.views\G;   #查看mysql所有视图
视图两种算法：
	1. merge：视图数据可更新
	2. temptable: 临时表，视图数据不可更新
	3. undefiend: 
注：create view v_test1 algorithm=temptable as 
mysql> show table status from jack like 'info_%' \G;  #从jack数据库中查看表info_开头表的状态
*************************** 1. row ***************************
           Name: info_money
         Engine: NULL
        Version: NULL
     Row_format: NULL
           Rows: NULL
 Avg_row_length: NULL
    Data_length: NULL
Max_data_length: NULL
   Index_length: NULL
      Data_free: NULL
 Auto_increment: NULL
    Create_time: NULL
    Update_time: NULL
     Check_time: NULL
      Collation: NULL
       Checksum: NULL
 Create_options: NULL
        Comment: VIEW
1 row in set (0.00 sec)
mysql> select drop_priv from mysql.user where user='root';  #查看用户是否有删除视图权限，当drop_priv为Y则有权限
+-----------+
| drop_priv |
+-----------+
| Y         |
+-----------+
1 row in set (0.00 sec)
mysql> drop view if exists info_money; #删除视图
Query OK, 0 rows affected (0.01 sec)

####触发器的应用
什么是触发器？
	触发器实际也是一种存储过程，它在插入，删除或修改特定表中的数据时触发执行，它比数据库本身标准的功能有更精细和更复杂的数据控制能力。
触发器特性：
	监视地点：一般是表名
	监视事件：update/delete/insert
	触发时间: after/before
	触发事件：update/delete/insert
注：不能被用户调用，只能由数据库主动执行
例：
mysql> create trigger tr_insertInfo after insert  #新建插入触发器
    ->  on info for each row  #在info表上执行insert以后为每一行执行后面的语句 
    -> begin
    ->  insert into user values(new.id,'bob');  #new.id为info表中的新插入id，
    -> end$$;
mysql> insert into   info (id,name)value(1000,'tim'); 
mysql> select * from info where id=1000;
+------+------+------+--------+-------+-----------+
| id   | name | age  | gender | money | mon_count |
+------+------+------+--------+-------+-----------+
| 1000 | tim  | NULL | NULL   |  NULL |      NULL |
+------+------+------+--------+-------+-----------+
mysql> select * from user;   #表中1000结果由触发器生成,id就是new,id变量代入的
+------+------+
| id   | name |
+------+------+
|    1 | jack |
| 1000 | bob  |
+------+------+
2 rows in set (0.00 sec)
mysql>  create trigger tr_deleteInfo before delete #新建删除触发器
    ->  on info for each row
    -> begin
    -> delete from user where id=old.id; #old.id为info表中的指定旧id，
    -> end $$;
Query OK, 0 rows affected (0.01 sec)
mysql> delete from info where id=1000;
Query OK, 1 row affected (0.01 sec)
mysql> select * from info where id=1000;
Empty set (0.00 sec)
mysql> select * from user;  #触发器自动删除了
+----+------+  
| id | name |
+----+------+
|  1 | jack |
+----+------+
1 row in set (0.00 sec)
#触发器的管理
mysql> show triggers\G;  #查看当前数据库的触发器
mysql> select trigger_name from information_schema.triggers; #查看整个数据库服务器的触发器
+----------------------------+
| trigger_name               |
+----------------------------+
| tr_insertInfo              |
| tr_deleteInfo              |
| sys_config_insert_set_user |
| sys_config_update_set_user |
+----------------------------+
mysql> drop trigger if exists tr_deleteInfo; #删除触发器
mysql> show create trigger jack.tr_insertInfo\G;  #查看新建时触发器的语句
*************************** 1. row ***************************
               Trigger: tr_insertInfo
              sql_mode: ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
SQL Original Statement: CREATE DEFINER=`root`@`localhost` trigger tr_insertInfo after insert
 on info for each row
begin
 insert into user values(new.id,'bob');
end
  character_set_client: utf8
  collation_connection: utf8_general_ci
    Database Collation: utf8_general_ci
               Created: 2019-09-01 11:56:56.93
1 row in set (0.00 sec)

</pre>