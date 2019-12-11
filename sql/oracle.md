#Oracle
<pre>
使用图形化安装好oracle 11g.
打开cmd:sqlplus / as sysdba  #sys为超级管理员，dba为系统角色
alter user scott account unlock; #解释普通用户scott,oracle 12c普通用户为hr
alter user scott identified by scott; #修改scott用户密码为scott
show user;  #查看当前用户
password ;  #修改当前用户的密码
exit
sqlplus scott/scott  #用帐户和密码登录oracle
SQL> select * from tab;  #查看当前用户下的所有对象
SQL> desc emp;  #查看表结构
 名称                                      是否为空? 类型
 ----------------------------------------- -------- ----------------------------
 EMPNO                                     NOT NULL NUMBER(4)
 ENAME                                              VARCHAR2(10)
 JOB                                                VARCHAR2(9)
 MGR                                                NUMBER(4)
 HIREDATE                                           DATE
 SAL                                                NUMBER(7,2)
 COMM                                               NUMBER(7,2)
 DEPTNO                                             NUMBER(2)
SQL> host cls #执行主机的命令cls
SQL> /   #执行上一条命令
SQL> select NVL(NULL,'a') from dual;  #跟mysql的ifnull(),sqlserver的isnull()函数一样。
SQL> select 'hello' || 'jack' "column" from dual;  #||这字符连接符，oracle中别名必须使用双引号括起来，使用连接符时必需使用from关键字，dual是哑表或伪表，select关键字必须有表一起使用
column
------------------
hellojack
SQL> select sysdate from dual;  #查看系统时间
SYSDATE
--------------
09-9月 -19

#隐式数据类型转换
源数据类型							目标数据类型
VARCHAR2(变长) or CHAR(定长)			NUMBER
VARCHAR2 or CHAR					DATE
NUMBER								VARCHAR2	
DATE								VARCHAR2
#单行函数一
SQL> select lower('www.BAIdu.COm') from dual;  #lower()转小写函数，只能单引号，不能双引号

LOWER('WWW.BAIDU.COM')
--------------------------
www.baidu.com
SQL> select upper('www.BAIdu.COm') from dual; #upper()转大写函数

UPPER('WWW.BAIDU.COM')
--------------------------
WWW.BAIDU.COM
SQL> select initcap('www.mi.com') from dual; #initcap()函数以.为界限，每个首字母大写

INITCAP('WWW.MI.COM'
--------------------
Www.Mi.Com
SQL> select concat('hello','world') from dual; #concat()函数，与||连接符号作用一样，而且concat()函数最多只能两个参数，一般使用||

CONCAT('HELLO','WORL
--------------------
helloworld	
SQL> select 'hello'||'world'||'for'||'jack' from dual; #推荐这种

'HELLO'||'WORLD'||'FOR'||'JACK'
----------------------------------
helloworldforjack
SQL> select substr('HelloWorld!',6,6) from dual; #substr()截取字符串函数

SUBSTR('HELL
------------
World!
SQL> select lengthb('hello中国') from dual; #查看字符串字节长度，utf8一个汉字三个字节，gbk一个汉字两个字节，oracle不用选字符编码，全部都识别

LENGTHB('HELLO中国')
--------------------
                  11

SQL> select length('hello中国') from dual; #查看字符串长度

LENGTH('HELLO中国')
-------------------
                  7
SQL> select instr('helloWorld','W') from dual; #查看字符在给定字符串的位置，未找到则返回0

INSTR('HELLOWORLD','W')
-----------------------
                      6
SQL> select LPAD('hello',10,'#') from dual;  #lpad函数取出给定字符串和给定的长度，不足用给定的符号从左边填充，足则截取不填充

LPAD('HELLO',10,'#')
--------------------
#####hello

SQL> select LPAD('hello',3,'#') from dual;

LPAD('
------
hel
SQL> select trim(' 'from '    hello  world  !     ') from dual; #trim函数用给定的符号截取删除字符的前后符号

TRIM(''FROM'HELLOWORLD!')
------------------------------
hello  world  !
SQL> select replace('hello','l','L') from dual; #raplace函数用目标字符替换指定源字符

REPLACE('H
----------
heLLo
SQL> select round(3.145,2) from dual; #四舍五入函数

ROUND(3.145,2)
--------------
          3.15

SQL> select trunc(3.145,2) from dual; #截取数值函数

TRUNC(3.145,2)
--------------
          3.14

SQL> select mod(10,3) from dual;  #取余函数

 MOD(10,3)
----------
         1
SQL> select sysdate from dual;  #当前时间

SYSDATE
--------------
14-9月 -19
SQL> select round(sysdate,'month') from dual; #四舍五入当前时间月份，得看日期，以15日为界线

ROUND(SYSDATE,
--------------
01-9月 -19

SQL> select round(sysdate,'year') from dual; #四舍五入取余当前时间年份，得看月份，以6月为界线

ROUND(SYSDATE,
--------------
01-1月 -20
#单行函数二
SQL> select sysdate from dual;

SYSDATE
--------------
14-9月 -19
SQL> select trunc(sysdate,'month') from dual; #取余月份，看日期，无论日期是多少都置为1
TRUNC(SYSDATE,
--------------
01-9月 -19
SQL> select trunc(sysdate,'year') from dual; #取余年份，看月份，无论月份是多少都置为1
TRUNC(SYSDATE,
--------------
01-1月 -19
注：round()和trunc()函数可以对sysdate日期进行操作
SQL> select months_between('31-12月-19',sysdate) from dual; #精确月之间的月数，此函数可自动计算平年闰月。
MONTHS_BETWEEN('31-12月-19',SYSDATE)
------------------------------------
                          3.52903338
SQL> select add_months(sysdate,2) from dual; #增加2个月

ADD_MONTHS(SYS
--------------
14-11月-19
SQL> select add_months(sysdate,-2) from dual; #减少两个月

ADD_MONTHS(SYS
--------------
14-7月 -19
SQL> select next_day(sysdate,'星期三') from dual; #下一个星期三是什么时候，next_day可以进行嵌套，因为此函数返回值是日期形

NEXT_DAY(SYSDA
--------------
18-9月 -19
SQL> select last_day(sysdate) from dual;  #查看本月最后一天是什么时候
LAST_DAY(SYSDA
--------------
30-9月 -19
#三大类型转换
隐式转换：
#隐式转换
源数据类型							目标数据类型
VARCHAR2(变长) or CHAR(定长)			NUMBER
VARCHAR2 or CHAR					DATE
NUMBER								VARCHAR2	
DATE								VARCHAR2
#显示转换：
###to_char()函数
SQL> select to_char(sysdate,'yyyy mm dd day') from dual; #to_char()函数类型转换，yyyy表示年，mm表示月，dd表示日，day表示星期

TO_CHAR(SYSDATE,'YYYYMMDDDAY')
----------------------------------------------
2019 09 14 星期六
SQL> select to_char(sysdate,'yyyy "年"mm"月" dd"日" day') from dual; #加的年月日是常量必须用双引号括起来
TO_CHAR(SYSDATE,'YYYY"年"MM"月"DD"日"DAY')
----------------------------------------------------------------
2019 年09月 14日 星期六
SQL> select to_char(sysdate,'yyyymmdd dayhh24:mi:ss') from dual; #yyyymmdd一定要和day有空格

TO_CHAR(SYSDATE,'YYYYMMDDDAYHH24:MI:SS')
----------------------------------------------------------
20190914 星期六14:51:07
SQL> select to_char(sysdate,'yyyymmdd dayhh12:mi:ss am') from dual; #12小时制，显示上午或下午，用am

TO_CHAR(SYSDATE,'YYYYMMDDDAYHH12:MI:SSAM')
------------------------------------------------------------------------
20190914 星期六02:53:04 下午
##数值转换为字符串
$表示美元符号，L表示为本地货币符号，9表示为数字，0表示为0，.表示小数点，，表示为千位符
SQL> select to_char(1234,'$9999') from dual; #$表示美元符号，9表示为数字，0表示为0，.表示小数点，，表示为千位符
SQL> select to_char(10000.57,'L90000.99') from dual;

TO_CHAR(10000.57,'L90000.99')
--------------------------------------
        ￥10000.57

SQL> select to_char(10000.57,'L99999.99') from dual; #和以上方法都可以

TO_CHAR(10000.57,'L99999.99')
--------------------------------------
        ￥10000.57
#to_date()函数转换
SQL> select to_date('2019-09-14','yyyy-mm-dd') from dual;
TO_DATE('2019-
--------------
14-9月 -19
SQL> select to_date('2019年09月14日','yyyy"年"mm"月"dd"日"') from dual;

TO_DATE('2019
--------------
14-9月 -19
SQL> select to_date('20190914 星期六02:53:04 下午','yyyymmdd dayhh12:mi:ss am') from dual;  #字符串转换为日期时分秒

TO_DATE('20190
--------------
14-9月 -19
#to_number()函数转换
SQL> select to_number('123') + 123 from dual; #+号在oracle中是算术运算符

TO_NUMBER('123')+123
--------------------
                 246

SQL> select '123'+123 from dual;  #隐式转换相加

 '123'+123
----------
       246

SQL> select '123'||123 from dual; #隐式转换连接，||为连接符

'123'||123
------------
123123
#日期转字符串再转为数字
SQL> select to_number(to_char(sysdate,'yyyymmdd')) from dual;

TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDD'))
--------------------------------------
                              20190914

#oracle第二天
注：order by既可以用字段排序也可以用列号来排序。
#通用函数和流程控制函数：
设置sqlplus命令行输出格式:
col empno for 9999;
col ename for a10;
col job for a10;
col mgr for 9999;   
col hiredate for a12;
col sal for 9999;
col comm for 9999;
col deptno for 99;
set pagesize 20;
col tname for a20;
set pagesize 80; 

nvl2(name,a,0)  #如果name不为null则返回a,如果为null则返回0
SQL> select nullif(10,100) from dual; #比较10和100是否相同，不相同返回10，相同返回null
NULLIF(10,100)
--------------
            10
SQL> select nullif(10,10)from dual; #null
NULLIF(10,10)
-------------

#case流程控制
case跟mysql、sqlserver一样。
例：select ename "姓名",job "职位",sal "涨前工资",
       case job
	    when 'ANALYST' then sal+1000
	    when 'MANAGER' then sal+800
            else sal+400
       end "涨后工资"
from emp; 
decode():此函数是oracle独有，是简化case流程控制的
select ename "姓名",job "职位",sal "涨前工资",
       decode(job,'ANALYST',sal+1000,'MANAGER',sal+800,sal+400) "涨后工资"
from emp; 
#多行函数
count()#计数,sum(),avg(),max(),min(),distinct#去重
#多表连接
内连接：相等内连接，不相等内连接
外连接：左外连接，右外连接
自连接
#相等内连接例子：
select emp.empno,emp.ename,dept.dname,dept.deptno
from emp,dept
where emp.deptno = dept.deptno;
#不相等内连接例子：
select e.empno,e.ename,e.sal,s.grade
from emp e,salgrade s
where e.sal between s.losal and s.hisal;
#左外连接例子：
select dept.deptno "部门号",dept.dname "部门名",count(emp.empno) "人数"
from dept,emp
where dept.deptno = emp.deptno(+) 
group by dept.deptno,dept.dname
order by 3 desc;
#注:(+)表示在多张表对应关系中没有数值的一方时用null填充，而(+)在左边表示右连接，在右边表示左连接，order by时可以用列号进行指定排序
#右外连接例子：
select dept.deptno "部门号",dept.dname "部门名",count(emp.empno) "人数"
from dept,emp
where emp.deptno(+) = dept.deptno
group by dept.deptno,dept.dname;
#注：dept.deptno = emp.deptno(+) 这种(+)的写法是oracle独有的，也可以用inner join,left join,right join等这种写法。

#子查询
单行子查询:=，<>,>=,<=
      select * 
      from emp 
      where sal = (
			select min(sal) 
			from emp
		  );
多行子查询：in,any,all
      select * 
      from emp 
      where sal <any (
			select sal 
			from emp 
			where deptno = 20
		      ); 
#集合查询
SQL> set time on  #开启sqlplus时间显示
17:48:06 SQL> set time off  #关闭sqlplus时间显示
SQL>
SQL> set timing on  #打开执行语句的执行时间
SQL> select sysdate from dual;
SYSDATE
--------------
14-9月 -19
已用时间:  00: 00: 00.00
#并集：union,union all
select * from emp where deptno = 20
union
select * from emp where deptno = 30;
#交集：intersect
select * from emp where sal between 1000 and 2000
intersect
select * from emp where sal between 1500 and 2500;
#差集：minus
select * from emp where sal between 1000 and 2000
minus
select * from emp where sal between 1500 and 2500;
#差集也可以用单表查询得出
select * 
from emp 
where (sal between 1000 and 2000) and (sal not between 1500 and 2500);

#oracle分页
回顾mysql分页，用limit关键字 
查询出users第2条到第4条记录
select * from users limit 1,3; 
#rownum
什么是rownum，有何特点
1）rownum是oracle专用的关健字
2）rownum与表在一起，表亡它亡,表在它在 
3）rownum在默认情况下，从表中是查不出来的
4）只有在select子句中，明确写出rownum才能显示出来
5）rownum是number类型，且唯一连续
6）rownum最小值是1，最大值与你的记录条数相同
7）rownum也能参与关系运算
   * rownum = 1    有值
   * rownum < 5    有值	
   * rownum <=5    有值 		
   * rownum > 2    无值    	
   * rownum >=2    无值
   * rownum <>2    有值	与  rownum < 2 相同
   * rownum = 2    无值
8）基于rownum的特性，我们通常rownum只用于<或<=关系运算   
##显示emp表中3-8条记录（方式一：使用集合减运算）
select rownum "伪列",emp.* from emp where rownum<=8
minus
select rownum,emp.* from emp where rownum<=2;
##显示emp表中3-8条记录（方式二：使用子查询，在from子句中使用，重点）
select xx.*
from (select rownum ids,emp.* from emp where rownum<=8) xx 
where ids>=2;
注意：方式二在子查询中的别名，不可加""引号，重点在于rownum是关键字不可用作子查询>,>=等符号比较，所以需要起别名，才可进行>=，>等符号的比较了。

#创建表
SQL> create table users(
  2    id number(5) primary key,
  3    name varchar2(8) not null unique,
  4    sal number(6,2) not null,
  5    birthday date default sysdate
  6  );
表已创建。
已用时间:  00: 00: 00.07
SQL> drop table users; #删除表，oracle删除表并没有永久删除，在其回收站recyclebin中
表已删除。
已用时间:  00: 00: 00.11
SQL> show recyclebin; #查看oracle回收站中的对象
ORIGINAL NAME    RECYCLEBIN NAME                OBJECT TYPE  DROP TIME
---------------- ------------------------------ ------------ -------------------
USERS            BIN$gIS8vqjtRhSRVjjth0mpTw==$0 TABLE        2019-09-14:18:32:16
SQL> flashback table users to before drop; #闪回表users到以前删除的地方
闪回完成。
已用时间:  00: 00: 00.03
#注：flashback table "BIN$gIS8vqjtRhSRVjjth0mpTw==$0" to before drop rename to  新表名;   #闪回可以用对象id,也可以重命名
SQL> drop table users purge;  #强制删除表使其不到回收站
表已删除。
已用时间:  00: 00: 00.01
SQL> show recyclebin;
SQL> purge recyclebin;  #清空回收站 
回收站已清空。
已用时间:  00: 00: 00.00

#修改表和约束
number(5)：表示最多存99999 
number(6,2)：其中2表示最多显示2位小数，采用四舍五入，不足位数补0，同时要设置col ... for ... 其中6表示小数+整数不多于6位，其中整数位数不得多于4位，可以等于4位
varchar2(8)：8表示字节，GBK 赵 2字节
date：默认格式为：'27-4月-15'
CLOB【Character Large OBject】：大文本对象，即超过65565字节的数据对象，最多存储4G
BLOB【Binary Large OBject】：大二进制对象，即图片，音频，视频，最多存储4G
#修改表
为emp表增加image列，alter table 表名 add 列名 类型(宽度) 
alter table emp
add image blob;
修改ename列的长度为20个字节，alter table 表名 modify 列名 类型(宽度) 
alter table emp
modify ename varchar2(20);
删除image列，alter table 表名 drop column 列名
alter table emp
drop column image;
重名列名ename为username，alter table 表名 rename column 原列名 to 新列名
alter table emp
rename column ename to username;
将emp表重命名emps，rename 原表名 to 新表名
rename emp to emps;
注意：修改表时，不会影响表中原有的数据
#注：修改表结构不可回滚

创建表customers(单)和orders(多)，使用primary key/not null/unique/default/foreign key约束
要体现【on delete cascade/on delete set null】
需求：删除客户，级联删除他所有的订单
      delete from customers where id = 1;
需求：删除客户，不级联删除他所有的订单，只是将外健设置为NULL
      delete from customers where id = 1;	

create table customers(
  id number(3) primary key,
  name varchar2(4) not null unique
);
insert into customers(id,name) values(1,'A');
insert into customers(id,name) values(2,'B');

create table orders(
  id number(3) primary key,
  isbn varchar2(6) not null unique,
  price number(3) not null,
  cid number(3),
  --constraint cid_FK foreign key(cid) references customers(id) on delete cascade 
  constraint cid_FK foreign key(cid) references customers(id) on delete set null    
);
注：on delete cascade 表示删除主键关联数据时也删除外键关联数据，on delete set null 表示删除主键关联数据时让外键关联数据为null，但外建字段不能设置为not null，否则不能设置为null
insert into orders(id,isbn,price,cid) values(1,'isbn10',10,1);
insert into orders(id,isbn,price,cid) values(2,'isbn20',20,1);
insert into orders(id,isbn,price,cid) values(3,'isbn30',30,2);
insert into orders(id,isbn,price,cid) values(4,'isbn40',40,2);
创建表students，包括id,name,gender,salary字段，使用check约束【性别只能是男或女，薪水介于6000到8000之间】
create table students(
  id number(3) primary key,
  name varchar2(4) not null unique,
  gender varchar2(2) not null check ( gender in ('男','女') ),
  salary number(6) not null check ( salary between 6000 and 8000 )
);
insert into students(id,name,gender,salary) values(1,'哈哈','中',6000);错
insert into students(id,name,gender,salary) values(2,'呵呵','男',5000);错
insert into students(id,name,gender,salary) values(3,'嘻嘻','女',7000);对

#第三天：oracle事务，视图，序列
#1.增删改数据
使用&占位符，动态输入值，&可以运用在任何一个DML语句中，在values子句中使用，例如：'&ename'和&sal
insert into emp values(&empno,'&ename','&job',&mgr,&hiredate,&sal,&comm,&xxxxxxxx);
注意：&是sqlplus工具提供的占位符，如果是字符串或日期型要加''符，数值型无需加''符

删除emp表中的所有记录
delete from emp;
将xxx_emp表中所有20号部门的员工，复制到emp表中，批量插入，insert into 表名 select ...语法
insert into emp
select * 
from xxx_emp
where deptno=20;

#2.批量插入数据
复制xxx_emp表结构，创建emp表的结构，但不会插入数据，因为where条件为false
create table emp
as
select * from xxx_emp where 1<>1;
创建emp表，复制xxx_emp表中的结构，同时复制xxx_emp表的所有数据
create table emp
as
select * from xxx_emp where 1=1;
注意：where不写的话，默认为true

#drop table 和 truncate table 和 delete from 区别：
drop table
1)属于DDL
2)不可回滚
3)不可带where
4)表内容和结构删除
5)删除速度快
truncate table
1)属于DDL
2)不可回滚
3)不可带where
4)表内容删除
5)删除速度快
delete from
1)属于DML
2)可回滚
3)可带where
4)表结构在，表内容要看where执行的情况
5)删除速度慢,需要逐行删除

向emp表，批量插入来自xxx_emp表中部门号为20的员工信息，只包括empno，ename，job，sal字段
insert into emp(empno,ename,job,sal)
select empno,ename,job,sal 
from xxx_emp 
where deptno=20;

依据xxx_emp表，只创建emp表，但不复制数据，且emp表只包括empno,ename字段
create table emp(empno,ename)
as
select empno,ename from xxx_emp where 1=2;

向emp表（只含有empno和ename字段），批量插入xxx_emp表中部门号为20的员工信息
insert into emp(empno,ename)
select empno,ename from xxx_emp where deptno=20;

#oracle事务
Oracle的事务只针对DML操作，即select/insert/update/delete
Oracle的事务开始：第一条DML操作做为事务开始
#Oracle的提交事务
（1）显示提交：commit	
（2）隐藏提交：DDL/DCL/exit(sqlplus工具)
注意：提交是从事务开始到事务提交中间的内容，提交到ORCL数据库中的DBF二进制文件
#Oracle的回滚事务
（1）显示回滚：rollback
（2）隐藏回滚：关闭窗口(sqlplus工具)，死机，掉电
注意：回滚到事务开始的地方
回顾为什么要设置回滚点？savepoint a;rollback to savepoint a;
如果没有设置回滚点的话，Oracle必须回滚到事务开始的地方，其间做的一个正确的操作也将撤销

使用savepoint 回滚点，设置回滚点a	
savepoint a;

使用rollback to savepoint，回滚到回滚点a处
rollback to savepoint a;

Oracle提交或回滚后，原来设置的回滚点还有效吗？
原回滚点无效了

Oracle之所以能回滚的原因是？
主要机制是实例池 

SQL> show user;
USER 为 "SCOTT"
SQL> conn / as sysdba
已连接。
SQL> show user
USER 为 "SYS"

#回顾事务隔离级别：
1. READ-UNCOMMITTED(读未提交);两个会话隔离性都为读未提交时，当一个会话启动事务进行增删改操作时，未使用COMMIT提交，另外一个会话也会看到同样的结果，这就是读未提交隔离的效果。但是会产生幻影问题
2. READ-COMMITTED(读提交);两个会话隔离性都为读提交时，当一个会话启动事务进行增删改操作时，使用COMMIT提交，另外一个会话也会看到同样的结果，这就是读提交隔离的效果。如果未提交则另外一个会话看不到改变的数据，但是提交后会产生幻影问题
3. REPEATABLE-READ(可重读);两个会话隔离性都为可重读时，当一个会话启动事务进行增删改操作时，使用COMMIT提交，另外一个会话不会看到同样的结果，此时另外一个会话看到的一直都是另外会话自己看到的结果，当另外一个会话也COMMIT时才会看到当前同样的结果，这就是可重读隔离的效果。但是会产生幻影问题
4. SEREALABLE(可串行);两个会话隔离性都为可串行时，当一个会话启动事务进行增删改操作时，未使用COMMIT提交，另外一个会话查询时不会有任何结果显示且会卡住查询会话，当当前会话COMMIT时，另外一个会话查询才会有结果显示。
#oracle事务隔离级别
Oracle支持的二种事务隔离级别及能够解决的问题
Oracle支持：read committed 和 serializable

Oracle中设置事务隔离级别为serializable
set transaction isolation level serializable;
注：演示二个用户同时操作emp表，删除KING这条记录，会有什么后果？
因为有隔离级别的存在，所以不会出现二个用户都删除了KING这条记录，
一定是一个用户删除KING成功,在该用户没有提交的情况下，另一个用户等待

#用户
声明：scott或hr叫用户名/方案名/空间名
      scott--tiger
      hr-----lion
      
查询当前用户是谁
show user;
查询scott自己表空间下的所有对象时，可加，或不加用户名select * from emp;
select * from emp;
或
select * from scott.emp;
以sysdba身份解锁hr普通帐户
alter user hr account unlock;
以sysdba身份设置hr普通帐户的密码
alter user hr identified by lion;
当scott查询hr表空间下的所有表时，必须得加用户名
select * from hr.jobs;
在默认情况下，每个用户只能查询自已空间下的对象的权限，不能查询其它用户空间下的对象
以sysdba身份角色，授予scott用户查询所有用户空间下的对象权限
grant select any table to scott;
以sysdba身份，撤销scott用户查询所有用户空间下的对象权限
revoke select any table from scott;
scott自已查看自己所拥有的权限
select * from user_sys_privs;
从scott用户空间导航到sysdba用户空间
conn / as sysdba;
从sysdba用户空间导航到scott用户空间
conn scott/tiger;
从scott用户空间导航到hr用户空间
conn hr/lion;
查询hr用户空间中的所有对象
select * from tab;
从hr用户空间导航到scott用户空间
conn scott/tiger;
在scott用户空间下，查询hr用户空间下的jobs表，必须加上hr用户空间名
select * from hr.jobs;

#作业
--笔试题1：找到员工表中工资最高的前三名
select    rownum,empno,ename,sal 
from      (select * from emp order by sal desc)
where     rownum<=3;
--笔试题2：找到员工表中员工薪水大于他所在本部门平均薪水的员工
select e.ename "姓名",xx.deptno "部门号",round(xx.avgsal,0) "部门平薪",e.sal "员工薪水",e.deptno "员工所在部门号"
from emp e,(select deptno,avg(sal) avgsal from emp group by deptno) xx
where (e.deptno=xx.deptno) and (e.sal>xx.avgsal);
--假如该表有大约1000万条记录，写一句最高效的SQL语句，计算以下4种人中每种员工的数量 
    select 
       sum(case when e.fsalary>9999 and e.fage>35 then 1 else 0 end) "第1种人",
       sum(case when e.fsalary>9999 and e.fage<35 then 1 else 0 end) "第2种人",
       sum(case when e.fsalary<9999 and e.fage>35 then 1 else 0 end) "第3种人",
       sum(case when e.fsalary<9999 and e.fage<35 then 1 else 0 end) "第4种人"
    from empinfo e;

#视图
什么是视图【View】 
（1）视图是一种虚表 
（2）视图建立在已有表的基础上, 视图赖以建立的这些表称为基表
（3）向视图提供数据内容的语句为 SELECT 语句,可以将视图理解为存储起来的 SELECT 语句
（4）视图向用户提供基表数据的另一种表现形式
（5）视图没有存储真正的数据，真正的数据还是存储在基表中
（6）程序员虽然操作的是视图，但最终视图还会转成操作基表
（7）一个基表可以有0个或多个视图 

什么情况下会用到视图
（1）如果你不想让用户看到所有数据（字段，记录），只想让用户看到某些的数据时，此时可以使用视图
（2）当你需要减化SQL查询语句的编写时，可以使用视图，但不提高查询效率

视图应用领域
（1）银行，电信，金属，证券军事等不便让用户知道所有数据的项目中

视图的作用
（1）限制数据访问
（2）简化复杂查询
（3）提供数据的相互独立
（4）同样的数据，可以有不同的显示方式

基于emp表所有列，创建视图emp_view_1，create view 视图名 as select对一张或多张基表的查询
create view emp_view_1
as
select * from emp;
默认情况下，普通用户无权创建视图，得让sysdba为你分配creare view的权限 
以sysdba身份，授权scott用户create view权限
grant create view to scott;
以sysdba身份，撤销scott用户create view权限
revoke create view from scott;
基于emp表指定列，创建视图emp_view_2，该视图包含编号/姓名/工资/年薪/年收入（查询中使用列别名）
create view emp_view_2
as
select empno "编号",ename "姓名",sal "工资",sal*12 "年薪",sal*12+NVL(comm,0) "年收入"
from emp;
基于emp表指定列，创建视图emp_view_3(a,b,c,d,e)，包含编号/姓名/工资/年薪/年收入（视图中使用列名）
create view emp_view_3(a,b,c,d,e)
as
select empno "编号",ename "姓名",sal "工资",sal*12 "年薪",sal*12+NVL(comm,0) "年收入"
from emp;
查询emp_view_3创建视图的结构
desc emp_view_3;
修改emp_view_3(id,name,salary,annual,income)视图，create or replace view 视图名 as 子查询
create or replace view emp_view_3(id,name,salary,annual,income)
as
select empno "编号",ename "姓名",sal "工资",sal*12 "年薪",sal*12+NVL(comm,0) "年收入"
from emp;
查询emp表，求出各部门的最低工资，最高工资，平均工资
select min(sal),max(sal),round(avg(sal),0),deptno
from emp
group by deptno;
创建视图emp_view_4，视图中包含各部门的最低工资，最高工资，平均工资
create or replace view emp_view_4
as
select deptno "部门号",min(sal) "最低工资",max(sal) "最高工资",round(avg(sal),0) "平均工资"
from emp
group by deptno;
创建视图emp_view_5，视图中包含员工编号，姓名，工资，部门名，工资等级
create or replace view emp_view_5
as
select e.empno "编号",e.ename "姓名",e.sal "工资",d.dname "部门名",s.grade "工资等级"
from emp e,dept d,salgrade s
where (e.deptno=d.deptno) and (e.sal between s.losal and s.hisal);
删除视图emp_view_1中的7788号员工的记录，使用delete操作，会影响基表吗
delete from emp_view_1 where empno=7788;写法正确，会影响基表
修改emp_view_1为只读视图【with read only】，再执行上述delete操作，还行吗？
create or replace view emp_view_1
as
select * from emp
with read only;
不能进行delete操作了
删除视图中的【某条】记录会影响基表吗？
会影响基表
将【整个】视图删除，会影响表吗？
不会影响基表
删除视图，会进入回收站吗？
不会进入回收站
删除基表会影响视图吗？
会影响视图
闪回基表后,视图有影响吗？
视图又可以正常工作了

#同义词
什么是同义词【Synonym】
（1）对一些比较长名字的对象(表，视图，索引，序列，。。。）做减化，用别名替代
同义词的作用
（1）缩短对象名字的长度
（2）方便访问其它用户的对象
创建与salgrade表对应的同义词，create synonym 同义词 for 表名/视图/其它对象
create synonym e for salgrade;
create synonym ev5 for emp_view_5;
以sys身份授予scott普通用户create synonym权限
grant create synonym to scott;
以sys身份从scott普通用户撤销create synonym权限
revoke create synonym from scott;
使用同义词操作salgrade表
select * from s;
删除同义词
drop synonym ev5;
删除同义词，会影响基表吗？
不会影响基表
删除基表，会影响同义词吗？
会影响同义词

#序列
什么是序列【Sequence】
（1）类似于MySQL中的auto_increment自动增长机制，但Oracle中无auto_increment机制
（2）是oracle提供的一个产生唯一数值型值的机制
（3）通常用于表的主健值
（4）序列只能保证唯一，不能保证连续
     声明：oracle中，只有rownum永远保持从1开始，且继续
（5）序列值，可放于内存，取之较快
 
题问：为什么oracle不直接用rownum做主健呢？
rownum=1这条记录不能永远唯一表示SMITH这个用户
但主键=1确可以永远唯一表示SMITH这个用户

为什么要用序列
（1）以前我们为主健设置值，需要人工设置值，容易出错
（2）以前每张表的主健值，是独立的，不能共享

为emp表的empno字段，创建序列emp_empno_seq，create sequence 序列名
create sequence emp_empno_seq;
删除序列emp_empno_seq，drop sequence 序列名
drop sequence emp_empno_seq;
查询emp_empno_seq序列的当前值currval和下一个值nextval，第一次使用序列时，必须选用：序列名.nextval
select emp_empno_seq.nextval from dual;
select emp_empno_seq.currval from dual;
使用序列，向emp表插入记录，empno字段使用序列值
insert into emp(empno) values(emp_empno_seq.nextval);
insert into emp(empno) values(emp_empno_seq.nextval);
insert into emp(empno) values(emp_empno_seq.nextval);
修改emp_empno_seq序列的increment by属性为20，默认start with是1，alter sequence 序列名
alter sequence emp_empno_seq
increment by 20;
修改修改emp_empno_seq序列的的increment by属性为5
alter sequence emp_empno_seq
increment by 5;
修改emp_empno_seq序列的start with属性，行吗
alter sequence emp_empno_seq
start with 100;
有了序列后，还能为主健手工设置值吗？
可以手工插入值：insert into emp(empno) values(9999);
删除表，会影响序列吗？
不会影响序列这个对象本身
删除序列，会影响表吗？
不会影响表，表中的序列已经转换为int类型了。

#索引
谈到分页会想起rownum
谈到索引会想起rowid
注：rowid,rownum两个字段是隐藏的，必须手动指定才能生效。rowid是全局唯一的，rownum是表里面唯一的
什么是索引【Index】
（1）是一种快速查询表中内容的机制，类似于新华字典的目录
（2）运用在表中某个/些字段上，但存储时，独立于表之外

为什么要用索引
（1）通过指针加速Oracle服务器的查询速度
（2）通过rowid快速定位数据的方法，减少磁盘I/O
     rowid是oracle中唯一确定每张表不同记录的唯一身份证

rowid的特点
（1）位于每个表中，但表面上看不见，例如：desc emp是看不见的
（2）只有在select中，显示写出rowid，方可看见
（3）它与每个表绑定在一起，表亡，该表的rowid亡，二张表rownum可以相同，但rowid必须是唯一的
（4）rowid是18位大小写加数字混杂体，唯一表代该条记录在DBF文件中的位置
（5）rowid可以参与=/like比较时，用''单引号将rowid的值包起来，且区分大小写
（6）rowid是联系表与DBF文件的桥梁

索引的特点
（1）索引一旦建立, Oracle管理系统会对其进行自动维护, 而且由Oracle管理系统决定何时使用索引
（2）用户不用在查询语句中指定使用哪个索引
（3）在定义primary key或unique约束后系统自动在相应的列上创建索引
（4）用户也能按自己的需求，对指定单个字段或多个字段，添加索引

什么时候【要】创建索引
（1）表经常进行 SELECT 操作
（2）表很大(记录超多)，记录内容分布范围很广
（3）列名经常在 WHERE 子句或连接条件中出现
 注意：符合上述某一条要求，都可创建索引，创建索引是一个优化问题，同样也是一个策略问题
       
什么时候【不要】创建索引
（1）表经常进行 INSERT/UPDATE/DELETE 操作
（2）表很小(记录超少)
（3）列名不经常作为连接条件或出现在 WHERE 子句中
同上注意

为emp表的empno单个字段，创建索引emp_empno_idx，叫单列索引，create index 索引名 on 表名(字段,...)
create index emp_empno_idx
on emp(empno);

为emp表的ename,job多个字段，创建索引emp_ename_job_idx，多列索引/联合索引
create index emp_ename_job_idx 
on emp(ename,job);
如果在where中只出现job不使用索引
如果在where中只出现ename使用索引
我们提倡同时出现ename和job

注意：索引创建后，只有查询表有关，和其它（insert/update/delete）无关,解决速度问题

删除emp_empno_idx和emp_ename_job_idx索引，drop index 索引名
drop index emp_empno_idx;
drop index emp_ename_job_idx;

#第四天：PLSQL程序设计
#SQL对比PLSQL
SQL99是什么
（1）是操作所有关系型数据库的规则
（2）是第四代语言
（3）是一种结构化查询语言
（4）只需发出合法合理的命令，就有对应的结果显示

SQL的特点
（1）交互性强，非过程化
（2）数据库操纵能力强，只需发送命令，无需关注如何实现
（3）多表操作时，自动导航简单，例如：
     select emp.empno,emp.sal,dept.dname
     from emp,dept
     where emp.deptno = dept.deptno
（4）容易调试，错误提示，直接了当
（5）SQL强调结果 

PLSQL是什么
     是专用于Oracle服务器，在SQL基础之上，添加了一些过程化控制语句，叫PLSQL
     过程化包括有：类型定义，判断，循环，游标，异常或例外处理。。。
     PLSQL强调过程

为什么要用PLSQL
     因为SQL是第四代命令式语言，无法显示处理过程化的业务，所以得用一个过程化程序设计语言来弥补SQL的不足之处，
     SQL和PLSQL不是替代关系，是弥补关系		
		
PLSQL程序的完整组成结构如下：
     [declare]
          变量声明;
  	  变量声明;
     begin
          DML/TCL操作;
	  DML/TCL操作;
     [exception]
          例外处理;
	  例外处理;
     end;
     /
注意：在PLSQL程序中，；号表示每条语句的结束，/表示整个PLSQL程序结束

书写PLSQL的工具有：
（1）SQLPLUS工具
（2）SQLDeveloper工具
（3）第三方工具（PLSQL & 其它）

PLSQL与SQL执行有什么不同：
（1）SQL是单条执行的
（2）PLSQL是整体执行的，不能单条执行，整个PLSQL结束用/，其中每条语句结束用；号

#PLSQL类型
mysum number(3);   #声明变量mysum为number类型，为3个整形
mysum2 number(3) := 0;  #声明变量mysum2为number类型，为3个整形，默认值为0
tip varchar2(10) := '结果是'; #声明变量tip为varchar2类型，最长为10个字节，默认值是'结果是'
pename emp.ename%type; #声明变量pename,类型和表emp中的字段ename一样
emp_record emp%rowtype; #声明变量emp_record,字段类型数量都和表emp的所有字段一样，就是复制emp表的表结构

写一个PLSQL程序，输出"hello world"字符串，语法：dbms_output.put_line('需要输出的字符串');
begin
    --向SQLPLUS客户端工具输出字符串
    dbms_output.put_line('hello 你好');
end;
/

注意：
dbms_output是oracle中的一个输出对象
put_line是上述对象的一个方法，用于输出一个字符串自动换行 

设置显示PLSQL程序的执行结果，默认情况下，不显示PLSQL程序的执行结果，语法：set serveroutput on/off;
set serveroutput on;


使用基本类型变量,常量和注释，求10+100的和
declare
    --定义变量
    mysum number(3) := 0;
    tip varchar2(10) := '结果是';
begin
    /*业务算法*/   
    mysum := 10 + 100;
    /*输出到控制器*/
    dbms_output.put_line(tip || mysum);
end;
/

输出7369号员工姓名和工资，格式如下：7369号员工的姓名是SMITH,薪水是800，语法：使用表名.字段%type
declare
    --定义二个变量，分别装姓名和工资
    pename emp.ename%type;
    psal   emp.sal%type;
begin  
    --SQL语句
    --select ename,sal from emp where empno = 7369;
    --PLSQL语句，将ename的值放入pename变量中，sal的值放入psal变量中    
    select ename,sal into pename,psal from emp where empno = 7369;
    --输出
    dbms_output.put_line('7369号员工的姓名是'||pename||',薪水是'||psal);    
end;
/

输出7788号员工姓名和工资，格式如下：7788号员工的姓名是SMITH,薪水是3000，语法：使用表名%rowtype
declare
    emp_record emp%rowtype;
begin
    select * into emp_record from emp where empno = 7788;
    dbms_output.put_line('7788号员工的姓名是'||emp_record.ename||',薪水是'||emp_record.sal);
end;
/

何时使用%type，何时使用%rowtype？
当定义变量时，该变量的类型与表中某字段的类型相同时，可以使用%type
当定义变量时，该变量与整个表结构完全相同时，可以使用%rowtype，此时通过变量名.字段名，可以取值变量中对应的值
项目中，常用%type

#plsql判读
#if..elsif..else..end if语句 
使用if-else-end if显示今天星期几，是"工作日"还是"休息日"
declare
    pday varchar2(10);
begin
    select to_char(sysdate,'day') into pday from dual;
    dbms_output.put_line('今天是'||pday);
    if pday in ('星期六','星期日') then
	dbms_output.put_line('休息日');
    else
	dbms_output.put_line('工作日');
    end if;
end;
/

从键盘接收值，使用if-elsif-else-end if显示"age<16"，"age<30"，"age<60"，"age<80"
declare
    age number(3) := &age;
begin
    if age < 16 then
       dbms_output.put_line('未成年');
    elsif age < 30 then
       dbms_output.put_line('青年人');
    elsif age < 60 then
       dbms_output.put_line('奋斗人');
    elsif age < 80 then 
       dbms_output.put_line('享受人');
    else
       dbms_output.put_line('未完再继');
    end if;
end;
/

#plsql循环
使用loop循环显示1-10
declare
    i number(2) := 1;
begin
    loop
        --当i>10时，退出循环
        exit when i>10;
        --输出i的值
        dbms_output.put_line(i);
        --变量自加
        i := i + 1;  
    end loop;
end;
/

使用while循环显示1-10
declare
    i number(2) := 1;
begin
    while i<11 
    loop
        dbms_output.put_line(i);
        i := i + 1;
    end loop;
end;
/

使用while循环，向emp表中插入999条记录
declare
    i number(4) := 1;
begin 
    while( i < 1000 )
    loop
        insert into emp(empno,ename) values(i,'哈哈');
        i := i + 1;
    end loop;   
end;
/

使用while循环，从emp表中删除999条记录
declare
    i number(4) := 1;
begin 
    while i<1000
    loop
        delete from emp where empno = i;
        i := i + 1;
    end loop;
end;
/

使用for循环显示20-30，for循环自动+1,写死了，例如不可以i+2步长等
declare
    i number(2) := 20;
begin
    for i in 20 .. 30
    loop
        dbms_output.put_line(i);
    end loop;
end;
/

#PLSQL游标
什么是光标/游标/cursor
类似于JDBC中的ResultSet对象的功能，从上向下依次获取每一记录的内容

使用无参光标cursor，查询所有员工的姓名和工资【如果需要遍历多条记录时，使用光标cursor，无记录找到使用cemp%notfound】
declare
    --定义游标
    cursor cemp is select ename,sal from emp;
    --定义变量
    vename emp.ename%type;
    vsal   emp.sal%type;
begin
    --打开游标，这时游标位于第一条记录之前
    open cemp;
    --循环
    loop
       --向下移动游标一次
       fetch cemp into vename,vsal; 
       --退出循环,当游标下移一次后，找不到记录时，则退出循环
       exit when cemp%notfound;
       --输出结果
       dbms_output.put_line(vename||'--------'||vsal);
    end loop;
    --关闭游标
    close cemp;
end;
/

使用带参光标cursor，查询10号部门的员工姓名和工资
declare
    cursor cemp(pdeptno emp.deptno%type) is select ename,sal from emp where deptno=pdeptno;
    pename emp.ename%type;
    psal emp.sal%type; 
begin 
    open cemp(&deptno);
    loop
        fetch cemp into pename,psal;	 
        exit when cemp%notfound;
        dbms_output.put_line(pename||'的薪水是'||psal);
    end loop;
    close cemp;
end;
/

使用无参光标cursor，真正给员工涨工资，ANALYST涨1000，MANAGER涨800，其它涨400，要求显示编号，姓名，职位，薪水
declare
    cursor cemp is select empno,ename,job,sal from emp;
    pempno emp.empno%type;
    pename emp.ename%type;
    pjob   emp.job%type;
    psal   emp.sal%type;
begin
    open cemp;
    loop
        fetch cemp into pempno,pename,pjob,psal;
        --循环退出条件一定要写
        exit when cemp%notfound;
        if pjob='ANALYST' then
            update emp set sal = sal + 1000 where empno = pempno;
        elsif pjob='MANAGER' then
            update emp set sal = sal + 800 where empno = pempno;
        else 
	    update emp set sal = sal + 400 where empno = pempno;
        end if;
    end loop;
    commit;
    close cemp;
end;
/

#PLSQL例外或异常
使用oracle系统内置例外，演示除0例外【zero_divide】
declare
    myresult number;
begin
    myresult := 1/0;
    dbms_output.put_line(myresult);
exception
    when zero_divide then 
	 dbms_output.put_line('除数不能为0');
	 delete from emp;  
end;
/

使用oracle系统内置例外，查询100号部门的员工姓名，演示没有找到数据【no_data_found】
declare
    pename varchar2(20);
begin
    select ename into pename from emp where deptno = 100;
    dbms_output.put_line(pename);
exception
    when NO_DATA_FOUND then 
	 dbms_output.put_line('查无该部门员工');
	 insert into emp(empno,ename) values(1111,'ERROR');
end;
/

使用用户自定义例外，使用光标cursor，查询10/20/30/100号部门的员工姓名，演示没有找到数据【nohave_emp_found】
declare
    cursor cemp(deptnovar number) is select ename from emp where deptno=deptnovar; 
    pename emp.ename%type;
    nohave_emp_found exception;
begin
    open cemp(&deptno);
    fetch cemp into pename;
    if cemp%notfound then
        raise nohave_emp_found;
    else 
        dbms_output.put_line(pename);
        loop
    	fetch cemp into pename;
	exit when cemp%notfound;
	dbms_output.put_line(pename);
        end loop;  
    end if;      
    close cemp;
exception
    when nohave_emp_found then
        dbms_output.put_line('无此部门');
end;
/

#ORACLE存储过程概念
为什么要用存储过程？
    （1）PLSQL每次执行都要整体运行一遍，才有结果
    （2）PLSQL不能将其封装起来，长期保存在oracle服务器中
    （3）PLSQL不能被其它应用程序调用，例如：Java
存储过程与PLSQL是什么关系？

#ORACLE存储过程

创建无参存储过程hello，无返回值，语法：create or replace procedure 过程名 as PLSQL程序
create or replace procedure hello
as
begin
    dbms_output.put_line('hello');
end;
/

删除存储过程hello，语法：drop procedure 过程名
drop procedure hello
调用存储过程方式一，exec 存储过程名
exec hello;
调用存储过程方式二，PLSQL程序
begin
    hello;
end;
/
调用存储过程方式三，Java程序

创建有参存储过程raiseSalary(编号)，为7369号员工涨10%的工资，演示in的用法，默认in，大小写不敏感
create or replace procedure raiseSalary(pempno in number)
as

begin
    update emp set sal=sal*1.1 where empno=pempno;
end;
/
exec raiseSalary(7369);

创建有参存储过程findEmpNameAndSalAndJob(编号)，查询7788号员工的的姓名，职位，月薪，返回多个值，演示out的用法
--创建存储过程
create or replace procedure findEmpNameAndSalAndJob(pempno in number,pename out varchar2,pjob out varchar2,psal out number)
as
begin
    select ename,job,sal into pename,pjob,psal from emp where empno=pempno;
end;
/
--PLSQL调用
declare
    pename emp.ename%type;
    pjob emp.job%type;
    psal emp.sal%type;
begin
    findEmpNameAndSalAndJob(7788,pename,pjob,psal);
    dbms_output.put_line('姓名'||pename||' 职位'||pjob||' 工资'||psal);
end;
/

什么情况下用exec调用，什么情况下用PLSQL调用存储过程？
没有返回值时用exec,当有返回值时用PLSQL

用存储过程，写一个计算个人所得税的功能
create or replace procedure tax(sal in number,sum out number)
as
    int number;
begin
    int := sal - 3500;
    if int<1500 then
        sum := int*0.3-0;
    elsif int<4500 then
        sum := int*0.1-105;
    elsif int<9000 then
        sum := int*0.2-555;
    elsif int<35000 then
        sum := int*0.25-1005;
    elsif int<55000 then 
        sum := int*0.3-2755;
    elsif int<80000 then
        sum := int*0.35-5505;
    else 
        sum := int*0.45-13505;
    end if;
end;
/

--PLSQL调用 
declare 
    stax number;
begin
    tax(5000,stax);
    dbms_output.put_line('交税'||stax);
end;
/

#存储函数
创建无参存储函数getName，有返回值，语法：create or replace function 函数名 return 返回类型 as PLSQL程序段
create or replace function get_name return varchar2
as
begin
    return 'hello world!';
end;
/

删除存储函数getName，语法：drop function 函数名
drop function get_name;

调用存储函数方式一，PLSQL程序
declare
    fanhui varchar2(20);
begin
    fanhui := get_name(); 
    dbms_output.put_line(fanhui);
end;
/

调用存储函数方式二，Java程序

创建有参存储函数findEmpIncome(编号)，查询7369号员工的年收入，演示in的用法，默认in
create or replace function findEmpIncome(fempno in number) return number
as
    income number;
begin
    select sal*12+NVL(comm,0) into income from emp where empno=fempno;
    return income;
end;
/

--PLSQL调用函数
declare
    income number;
begin
    income := findEmpIncome(7369);
    dbms_output.put_line('年收入'||income);
end;
/

创建有参存储函数findEmpNameAndJobAndSal(编号)，查询7788号员工的的姓名(return)，职位(out)，月薪(out)，返回多个值
--定义函数
create or replace function findEmpNameAndJobAndSal(fempno in number,fjob out varchar2,fsal out number) return varchar2
as
    fename emp.ename%type;
begin
    select ename,job,sal into fename,fjob,fsal from emp where empno=fempno;
    return fename;
end;
/
--调用函数
declare
    fjob emp.job%type;
    fsal emp.sal%type;
    fename emp.ename%type;
begin
    fename := findEmpNameAndJobAndSal(7788,fjob,fsal);
    dbms_output.put_line(fename||'--'||fjob||'--'||fsal);
end;
/

##过程函数和SQL适合什么场景
声明：适合不是强行要你使用，只是优先考虑
什么情况下【适合使用】存储过程？什么情况下【适合使用】存储函数？
【适合使用】存储过程：无返回值或有多个返回值时，适合用函数 
【适合使用】存储函数：有且只有一个返回值时，适合用函数

什么情况【适合使用】过程函数，什么情况【适合使用】SQL？
	【适合使用】过程函数：
	    》需要长期保存在数据库中
        》需要被多个用户重复调用
        》业务逻辑相同，只是参数不一样
	    》批操作大量数据，例如：批量插入很多数据
	【适合使用】SQL：
	    》凡是上述反面，都可使用SQL
	    》对表，视图，序列，索引，等这些还是要用SQL 

#触发器
创建语句级触发器insertEmpTrigger，当对表【emp】进行增加【insert】操作前【before】，显示"hello world"
create or replace trigger insertEmpTrigger
before insert 
on emp
begin
    dbms_output.put_line('Hello World!');
end;
/
删除触发器insertEmpTrigger，语法：drop trigger 触发器名
drop trigger insertEmpTrigger;
使用insert语句插入一条记录，引起insertEmpTrigger触发器工作
SQL> set serveroutput on
SQL> insert into emp(empno,ename) values (101,'jack');
Hello World!
使用insert语句插入N条记录，引起insertEmpTrigger触发器工作
begin
    for i in 200..299
       loop
            insert into emp(empno,ename) values (i,'jack');
       end loop ;
end;
/
创建语句级触发器deleteEmpTrigger，当对表【emp】进行删除【delete】操作后【after】，显示"world hello"
create or replace trigger deleteEmpTrigger
after delete
on emp
begin
    dbms_output.put_line('World! Hello');
end;
/
使用delete语句删除一条记录，引起deleteEmpTrigger触发器工作
SQL> delete from emp where empno=3;
World! Hello
使用delete语句删除N条记录，引起deleteEmpTrigger触发器工作
begin
    for i in 200..299
        loop
               delete from emp where empno=i;
        end loop;
end;
/

#星期一到星期五，且7-23点能向数据库emp表插入数据，否则使用函数抛出异常,
语法：raise_application_error('-20000','例外原因')
SQL> create or replace trigger securityTrigger
  2  before insert
  3  on emp
  4  declare
  5      week varchar2(10);
  6      hour number(2);
  7  begin
  8      select to_char(sysdate,'day') into week from dual;
  9      select to_char(sysdate,'hh24') into hour from dual;
 10      if week in ('星期六','星期日') or hour not between 7 and 23 then
 11          raise_application_error('-20000','非工作时间，不准插入数据！！！');
 12      end if;
 13  end;
 14  /

触发器已创建

SQL> insert into emp(empno,ename) values(100,'jack');
insert into emp(empno,ename) values(100,'jack')
            *
第 1 行出现错误:
ORA-20000: 非工作时间，不准插入数据！！！
ORA-06512: 在 "SCOTT.SECURITYTRIGGER", line 8
ORA-04088: 触发器 'SCOTT.SECURITYTRIGGER' 执行过程中出错

#创建行级触发器checkSalaryTrigger，涨后工资这一列，确保大于涨前工资，语法：for each row/:new.sal/:old.sal
create or replace trigger checkSalaryTrigger
after update of sal  --更新emp表sal列以后
on emp for each row  --针对每一行进行操作
begin
    if :new.sal <= :old.sal then
        raise_application_error('-20200','工资不能降低！！！');
    end if;
end;
/
--抛异常后就等于语句没执行成功
SQL> update emp set sal=800 where empno=7369;
update emp set sal=800 where empno=7369
       *
第 1 行出现错误:
ORA-20200: 工资不能降低！！！
ORA-06512: 在 "SCOTT.CHECKSALARYTRIGGER", line 3
ORA-04088: 触发器 'SCOTT.CHECKSALARYTRIGGER' 执行过程中出错

SQL> create table xxx_emp as select * from emp; #复制表数据及表结构
SQL> drop table emp purge;
表已删除。
SQL> show recyclebin;

#疑问：
删除触发器，表还在吗？
删除触发器后，表本身不会受影响。
将表丢到回收站，触发器还在吗？
触发器还在。
当闪回表后，触发器会在吗？
触发器还在。
彻底删除表，触发器会在吗？
触发器将也被彻底删除，就算新的同名表存在也是不会继承触发器的。

#Oracle优化
为什么要Oracle优化：
       随着实际项目的启动，Oracle经过一段时间的运行，最初的Oracle设置，会与实际Oracle运行性能会有一些差异，这时我们就需要做一个优化调整。

下面列出一些oracleSQL优化方案：
（01）选择最有效率的表名顺序（笔试常考） 
      ORACLE的解析器按照从右到左的顺序处理FROM子句中的表名， 
      FROM子句中写在最后的表将被最先处理，
      在FROM子句中包含多个表的情况下,你必须选择记录条数最少的表放在最后，
      如果有3个以上的表连接查询,那就需要选择那个被其他表所引用的表放在最后。
      例如：查询员工的编号，姓名，工资，工资等级，部门名
      select emp.empno,emp.ename,emp.sal,salgrade.grade,dept.dname
      from salgrade,dept,emp
      where (emp.deptno = dept.deptno) and (emp.sal between salgrade.losal and salgrade.hisal)  		
      1)如果三个表是完全无关系的话，将记录和列名最少的表，写在最后，然后依次类推
      2)如果三个表是有关系的话，将引用最多的表，放在最后，然后依次类推
（02）WHERE子句中的连接顺序（笔试常考）  
      ORACLE采用自右而左的顺序解析WHERE子句,根据这个原理,表之间的连接必须写在其他WHERE条件之左,
      那些可以过滤掉最大数量记录的条件必须写在WHERE子句的之右。  
      例如：查询员工的编号，姓名，工资，部门名  
      select emp.empno,emp.ename,emp.sal,dept.dname
      from emp,dept
      where (emp.deptno = dept.deptno) and (emp.sal > 1500)   	
（03）SELECT子句中避免使用*号
      ORACLE在解析的过程中,会将*依次转换成所有的列名，这个工作是通过查询数据字典完成的，这意味着将耗费更多的时间
      select empno,ename from emp;
（04）使用DECODE函数来减少处理时间
      使用DECODE函数可以避免重复扫描相同记录或重复连接相同的表
（05）整合简单，无关联的数据库访问
（06）用TRUNCATE替代DELETE   
（07）尽量多使用COMMIT
      因为COMMIT会释放回滚点
（08）用WHERE子句替换HAVING子句
      WHERE先执行，HAVING后执行     
（09）多使用内部函数提高SQL效率     
（10）使用表的别名
      salgrade s    
（11）使用列的别名
      ename e
（12）用索引提高效率
      在查询中，善用索引     
（13）字符串型，能用=号，不用like
      因为=号表示精确比较，like表示模糊比较 
（14）SQL语句用大写的
      因为Oracle服务器总是先将小写字母转成大写后，才执行
      在eclipse中，先写小写字母，再通过ctrl+shift+X转大写;ctrl+shift+Y转小写	
（15）避免在索引列上使用NOT
      因为Oracle服务器遇到NOT后，他就会停止目前的工作，转而执行全表扫描
（16）避免在索引列上使用计算
      WHERE子句中，如果索引列是函数的一部分，优化器将不使用索引而使用全表扫描，这样会变得变慢 
      例如，SAL列上有索引，
      低效：
      SELECT EMPNO,ENAME
      FROM EMP 
      WHERE SAL*12 > 24000;
      高效：
      SELECT EMPNO,ENAME
      FROM EMP
      WHERE SAL > 24000/12;
（17）用 >= 替代 >
      低效：
      SELECT * FROM EMP WHERE DEPTNO > 3   
      首先定位到DEPTNO=3的记录并且扫描到第一个DEPT大于3的记录
      高效：
      SELECT * FROM EMP WHERE DEPTNO >= 4  
      直接跳到第一个DEPT等于4的记录
（18）用IN替代OR
      select * from emp where sal = 1500 or sal = 3000 or sal = 800;
      select * from emp where sal in (1500,3000,800);
（19）总是使用索引的第一个列
      如果索引是建立在多个列上，只有在它的第一个列被WHERE子句引用时，优化器才会选择使用该索引
      当只引用索引的第二个列时，不引用索引的第一个列时，优化器使用了全表扫描而忽略了索引
      create index emp_sal_job_idex
      on emp(sal,job);
      ----------------------------------
      select *
      from emp  
      where job != 'SALES';	      
（20）避免改变索引列的类型，显示比隐式更安全 
      当字符和数值比较时，ORACLE会优先转换数值类型到字符类型 
      select 123 || '123' from dual;

</pre>