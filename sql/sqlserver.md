# sql server

<pre>
数据存储结构：
#数据库文件和事务文件组成：
mdf：主数据库文件，提供系统数据库的信息，一个数据库只有一个主数据库文件
ndf：辅助数据库文件，用于存储主数据库未能存储的数据和一些对象
ldf: 事务日志文件，用户记录数据库被改变的操作指令，类似mysql的二进制日志，不属于任何一个文件组
#文件组：用户设置
#数据库和系统数据库：
#系统数据库：
master：主数据库，记录sqlserver的所有系统信息，登录及其他数据库存放位置
model：模板数据库，创建新数据库时结构都是相同的就是因为这个modl数据库
msdb：处理用户代理，作业，数据库备份还原信息
tempdb：存储所有临时表，临时的存储过程，是一个临时数据库，程序执行完成后会自动消失
resource:隐藏数据库，只读的，包含了sqlserver的所有对象信息
#用户数据库：用户新建的库

###数据库：
#从视图上创建数据库：
数据库属性：
限制访问：
multi_user
single_user
restricted_user #表示只允许数据库管理员登录
只读：只读数据库

新建多文件组的数据库：
先创建数据库--文件组--添加文件组FG--常规--设置数据库名称--添加--选择FG文件组

#sqlserver系统视图
sysdatabases,sysobjects,sysindexes,sys.objects
#sqlserver存储过程
sp_databases,sp_renamedb,sp_help,sp_columns
#查询存储过程或自定义函数的内容
exec sp_helptext sp_databases
#查询表:
select * from sys.objects where type='U'
#查询存储过程
select * from sys.objects where type='P'

#使用SQL语句创建数据库
#创建数据库时设置主文件组、日志文件
USE master
GO  --批处理的标志
CREATE DATABASE mydb
ON PRIMARY  --主文件组
(
	NAME='mydb_data',  --主文件逻辑文件名
	FILENAME='E:\DATA\mydb.mdf',  --主文件物理文件名
	SIZE=5MB,  --主文件初始大小
	MAXSIZE=100MB,  --主文件增长的最大值
	FILEGROWTH=15%  --主文件的增长率
)  --第一个文件组结束
LOG ON  --日志文件
(
	NAME='mydb_log',  --日志文件逻辑文件名
	FILENAME='E:\DATA\mydb.ldf',  --主文件物理文件名
	SIZE=5MB,  --主文件初始大小
	FILEGROWTH=0  --未启用自动增长
) --日志文件结束
GO --结束批处理的标志

#创建数据库时设置主文件组、辅助文件组、日志文件
USE master
GO  --批处理的标志
CREATE DATABASE test
ON PRIMARY  --主文件组
(
	NAME='test_data',  --主文件逻辑文件名
	FILENAME='E:\DATA\test.mdf',  --主文件物理文件名
	SIZE=5MB,  --主文件初始大小
	MAXSIZE=100MB,  --主文件增长的最大值
	FILEGROWTH=15%  --主文件的增长率
), --主文件组结束
FILEGROUP FG  --第二个文件组
(
	NAME='test_fg_data',  --辅助文件逻辑文件名
	FILENAME='E:\DATA\test_fg.ndf',  --辅助文件物理文件名
	SIZE=10MB,  --辅助文件初始大小
	FILEGROWTH=0  --辅助文件的增长率
)  --第二个文件组结束
LOG ON  --日志文件
(   --日志1的具体描述
	NAME='test_log',  --日志文件逻辑文件名
	FILENAME='E:\DATA\test.ldf',  --日志文件物理文件名
	SIZE=5MB,  --日志文件初始大小
	FILEGROWTH=0  --未启用自动增长
),
(   --日志2的具体描述
	NAME='test1_log',  --日志文件逻辑文件名
	FILENAME='E:\DATA\test1.ldf',  --日志文件物理文件名
	SIZE=5MB,  --日志文件初始大小
	FILEGROWTH=0  --未启用自动增长
)--日志文件结束
GO --结束批处理的标志

#使用sql语句创建文件组和添加文件文件
USE test   --切换要更改的数据库
ALTER DATABASE test ADD FILEGROUP FG1 --更改数据库添加文件组FG1
GO  --批处理开始
ALTER DATABASE test ADD FILE  --更改数据库添加辅助文件
(
	NAME='FG1_test-data',
	FILENAME='E:\DATA\FG1_test_data.ndf',
	SIZE=5MB,
	FILEGROWTH=10%
)TO FILEGROUP FG1  --到文件组FG1
GO 
ALTER DATABASE test  
MODIFY FILEGROUP FG1 DEFAULT  --设置文件组FG1为默认文件组

--删除数据库
if exists (select * from sysdatabases where name='mydb') drop database mydb
--登录名只能登录数据库，不能操作数据库

#使用sql进行用户新建和赋权
--创建登录名
USE master
GO
CREATE LOGIN pbmaster WITH PASSWORD='123456'
GO
--创建test数据库用户pbmaster
USE test
GO
CREATE USER pbuser FOR LOGIN pbmaster
GO
--为pbuser赋予testtab表查看，新增，修改的操作权限
USE test
GO
GRANT SELECT,INSERT,UPDATE ON table1 TO pbuser
GO
--回收testtab表updata权限
USE test
GO
REVOKE UPDATE ON table1 FROM pbuser
GO

#服务器角色
dbo是所有数据库的所有者
sysadmin角色：做的动作也都是属于dbo的
public:所以数据库用户都属于public
sa用户：为每个数据库映射了dbo到sa上
数据库级别的一个对象，只能包含用户名
角色分类：
	1. 固定数据库角色
	2. 自定义数据库角色

#数据库状态
#脱机与联机：
--使用sql语句来查看数据的状态
SELECT state_desc  FROM sys.databases WHERE name='test'
select * from sysdatabases
--使用函数来查看数据的状态
SELECT DATABASEPROPERTYEX('test','status')
--脱机：断开数据库与所有人的连接
--联机：开启断气库与所有人的连接
#分离与附加数据库
--使用存储过程来分离与附加数据库
--分离
EXEC sp_detach_db @dbname=test    --使用存储过程sp_detach_db来分离
--附加
EXEC sp_attach_db @dbname=test,    --使用存储过程sp_attach_db来分离
@filename1='E:\DATA\test.mdf',     --指定mdf,ndf,ldf文件路径
@filename2='E:\DATA\test_fg.ndf',
@filename3='E:\DATA\FG1_test_data.ndf',
@filename4='E:\DATA\test.ldf',
@filename5='E:\DATA\test1.ldf'
GO  --进行批处理
#注：无论是分离还是脱机，都可以复制数据库文件进行备份

#收缩数据库
收缩数据库作用：
	删除数据库的每个文件中已经分配但还没有使用的页，收缩后数据库空间自动减少
收缩方式：
	自动收缩
	手动收缩
自动收缩操作：
	右键数据库属性---常规---可以查看大小和可用空间---选项---自动收缩选择为true（以后每半个小时会检查）
手动收缩操作：
	右键数据库任务---收缩---文件---进行收缩

######数据库的备份与还原
sqlserver提供四种数据库备份方式：
	完整备份：备份整个数据库的所有内容包括事务日志
	差异备份：只备份上次完整备份后更改的数据部份
	事务日志备份：只备份事务日志里的内容
	文件或文件组备份：只备份文件或文件组中的某些文件
在数据库完整备份期间，sqlserver做以下工作：
	备份数据及数据库中所有表的结构和相关的文件结构
	备份在备份期间发生的所有活动
	备份在事务日志中未确认的事务

####T-SQL数据语言操作
DECLARE @color varchar(4)  #声明一个变量并设置名称及类型
SET @color='白色'  #设置一个变量
SELECT '我最喜欢的颜色'+@color  #测评+号连接符
GO  #开启批处理

#使用tsql创建表：
#创建表
USE test
GO
CREATE TABLE CommoditySort(
	SortId int IDENTITY(1,1) NOT NULL,
	SortName varchar(50) NOT NULL
)
GO
--商品信息表
USE test
GO
CREATE TABLE CommodityInfo(
	CommodityId int IDENTITY(1,1) NOT NULL,
	SortId int NOT NULL,
	CommodityName varchar(50) NOT NULL,
	Picture image,
	Inprice float NOT NULL,
	Outprice float NOT NULL,
	Amount int NOT NULL
)
GO

##使用sql为表添加约束
USE test
GO
ALTER TABLE CommoditySort
ADD CONSTRAINT PK_UserID PRIMARY KEY (UserID),  --主键约束
	CONSTRAINT CK_UserPWD CHECK(LEN(UserPwd)>=6),   --检查约束
	CONSTRAINT CK_Gender CHECK(Gender=0 OR Gender=1),  --检查gender是否是男或女并约束
	CONSTRAINT DF_Gender DEFAULT(0) FOR Gender,  --设置默认约束，gender为0
	CONSTRAINT CK_Email CHECK(Email like '%@%')   --检查email中是否有@并约束
GO
#使用T-SQL向已有数据表中添加约束
ALTER TABLE CommoditySort WITH NOCHECK  --WITH NOCHECK 为不进行约束检查
ADD CONSTRAINT CK_UserPWD CHECK(LEN(UserPwd)>=6), 
GO
#删除约束
ALTER TABLE CommoditySort
DROP CONSTRAINT CK_UserPWD   #删除约束
GO

#删除表USE test 
GO
IF EXISTS (select * from sysobjects  where name='renwu')
DROP TABLE renwu
GO

#插入数据到新表
select Amount,Inprice,IDENTITY(INT,1,1) AS id INTO tmptable from CommodityInfo --从表中查询数据并插入到新表中，
TRUNCATE TABLE --清空表，删除表数据并清空自增长值且从头开始，但不能用于约束的表

#sqlserver的导入和导出用于处理大量数据的导入和导出，形式是excel格式导入和导出

##批处理
所有的批处理指令以GO作为结束的标志，GO只能在独立一行，GO不是T-SQL语句
##什么情况下会使用批处理
在脚本中的事情必须发生在另外一件事情之前或者是分开发生的时候
#GO用在批处理的每一个步骤之后，不可以多个步骤使用一个GO。

##########sqlserver函数
函数帮助和其他帮助都可以通过F1的索引
###字符串函数
函数：charindex(),len(),left(),right(),replace(),stuff()
select CHARINDEX('mi','www.mi.com') --从www.mi.com中截取mi的索引开始位置
select CHARINDEX('mi','www.mi.com'，10) --并给定起始位置
--将函数放在查询语句中进行使用
select charindex('@',Email) FROM UserInfo where username='jack' --查询jack用户的emial列中@的索引值
select len(Email) FROM UserInfo where username='jack' --查询jack用户的emial列中的值的长度
select left(Email,charindex('@','Email') FROM UserInfo where username='jack' --截取jack用户的emial列中以'@'符号左边的数，right()函数也一样
select REPLACE('我是中国人','中国人','湖北人') from UserInfo where username='jack' --替换我是中国人为我是湖北人，这个是字符串替换作用
select STUFF('ABCDEF',2,3,'ZZZ') --结果是'AZZZEF'，使用是从索引2开始删除3位，并用ZZZ替换
###日期函数
函数：getdate(),dateadd(),datediff()
select getdate() --获取当前系统时间
SELECT DATEADD(MM,1,GETDATE())  --在当前时间的月份加1，可以为正负数、如果是小数则会取整省略分数后的数
select datediff(YY,'2008-8-8',GETDATE()) --日期比较，这里以YY年来比较
###数学函数和系统函数
函数：rand(),ceiling(),floor(),abs(),convert()
SELECT RAND(100)   --指定了种子数(100)，则每次返回值都相同
SELECT RAND()  --未指定种子数()，则每次返回值都不相同
select CONVERT(int,'10')+CONVERT(int,'15')  --类型转换

#############查询
#模糊查询
_,%,[],[^]
#查询中使用聚合函数
sum(),avg(),min(),max(),count()
#分组查询
group by,having,order by ----排序永远是在最后的
例：select..from..where...group by...having...order by...
#内连接查询
内连接：根据表中共同的列来进行匹配,可以使用where和inner join来使用，但where最多只能两张表
SELECT 
    productCode, 
    productName, 
    textDescription
FROM
    products t1
        INNER JOIN
    productlines t2 ON t1.productline = t2.productline
		INNER JOIN 
	money t3 ON t2.moneyid=t3.moneyid
#联合查询
UNION ALL --联合查询方法和mysql一样，UNION ALL表示不去重显示，默认UNION是去重显示的
select userid,username into newtable from userinfo  --联合查询插入到临时表时必须在第一个from前插入into
union
select userid,payway,userage from orderinfo
注：联合查询的多表类型必须保持一致，否则不会成功
#联合查询与连接查询的区别

#EXISTS子查询
只注重子查询是否有返回行，如果查有返回行返回结果为值，否则为假
IF EXISTS (SELECT commodityid FROM order where amount >3)
	BEGEIN
		UPDATE order SET money=money*0.8 
		WHERE commodityid IN (SELECT commodityid FROM order where amount >3)
	END
--通常会使用NOT EXISTS对子查询的结果进行取反

#ALL,ANY和SOME子查询
ALL:所有
ANY:部分
SOME:与ANY等同，使用ANY的地址都可以使用SOME替换
--ALL
SELECT * FROM table2 WHERE n>ALL(SELECT n FROM table1)
--返回结果为4，--table2 n为（1，2，3，4），table1 n为（2，3）
--ANY
SELECT * FROM table2 WHERE n>ANY(SELECT n FROM table1)
--返回结果为3,4，--table2 n为（1，2，3，4），table1 n为（2，3）
--SOME
SELECT * FROM table2 WHERE n>SOME(SELECT n FROM table1)
--返回结果为3,4，--table2 n为（1，2，3，4），table1 n为（2，3）
注：ANY跟SOME一样
SELECT * FROM table2 WHERE n=ANY(SELECT n FROM table1)  --加上下面这条结果都一样
SELECT * FROM table2 WHERE n IN (SELECT n FROM table1)
SELECT * FROM table2 WHERE n <> ANY(SELECT n FROM table1) --加上下面这条结果不一样
SELECT * FROM table2 WHERE n NOT IN (SELECT n FROM table1)
注：n=ANY与n IN相同的， n <> ANY和n NOT IN是不相同的

##查询示例集：
--[1]查询全部的行和列,*代表所有的行和列
SELECT * FROM UserInfo
--[2]查询部分行和列，部分行使用WEHRE来限制，部分列使用列名来限制
SELECT UserId ,PayWay,PayMoney FROM OrderInfo 
WHERE PayWay='网上银行'  --“=”的作用是比较运算符，将左右两边的值进行相比
--同理，查询一下付款的方式不是“网上银行”的订单信息
SELECT UserId,PayWay,PayMoney FROM OrderInfo 
WHERE PayWay<>'网上银行'  --不等于也可以使用"!="非SQL92标准
--[3]在查询的结查集中使得别名
 --（1）使用AS关键字来改变结果集中的别名
 SELECT UserId AS 用户名 ,PayWay AS 付款方式,PayMoney AS 付款金额
  FROM OrderInfo 
WHERE PayWay='网上银行' 
--（2）使用“=”赋值运算符来改变结果集中的别名，赋值的顺序是从右向左赋值
SELECT 用户名=UserId ,付款方式=PayWay,付款金额=PayMoney FROM OrderInfo 
WHERE PayWay='网上银行' 
--（3）使用“空格”来改变结果集中列的别名
SELECT UserId 用户名 ,PayWay 付款方式,PayMoney 付款金额
 FROM OrderInfo 
WHERE PayWay='网上银行' 
--[4]查询NULL值
SELECT * FROM UserInfo WHERE Email IS NULL
--如果原来有数据，而后又被删除，那么使用IS NULL能否查询到？查不到
SELECT * FROM UserInfo WHERE Email IS NULL OR Email=''
--IS NULL与''的区别
--IS NULL:从未录入过数据，没有地址
--''：录入过数据，而后被删除，是有地址

--[1]在查询中使用常量列
SELECT UserId 用户号,PayWay 付款方式,PayMoney 付款金额,
'天猫' AS 购物网站 FROM OrderInfo
--[2]查询返回限制的行数，使用TOP关键字
  --(1)返回限定的个数
  SELECT TOP 5 UserName AS 用户名,UserAddress AS 地址
   FROM UserInfo WHERE Gender=1
  --(2)返回限定百份比 20% PERCENT
    SELECT TOP 20 PERCENT UserName AS 用户名,UserAddress AS 地址
   FROM UserInfo WHERE Gender=1
   -- 数据库中用户表中女生的用户有几条？X*20%=2   X=？X*0.2=2  X*2=20  X=10
   SELECT * FROM UserInfo WHERE Gender=1   --6*0.2  =1.2条
   --使用百份比的形式能够得到大概的数据而非精确的数据
   --[3]在查询的结查集中进行排序，关键字是ORDER BY 升序为ASC,降序为DESC
   --将订单表中付款金额由高到低的顺序显示
   SELECT UserId,PayWay,PayMoney FROM OrderInfo
   ORDER BY PayMoney DESC
   --如何按照多列进行排序
   --按购买数量降序，按付款金额升序，
   SELECT UserId,PayWay,Amount,PayMoney FROM OrderInfo
   ORDER BY Amount DESC,PayMoney ASC

SELECT UserName,UserAddress,Phone FROM UserInfo WHERE UserName LIKE '李%'
SELECT * FROM OrderInfo WHERE Amount BETWEEN 2 AND 10
SELECT * FROM OrderInfo WHERE Amount BETWEEN 10 AND 2
 --相当于
SELECT * FROM OrderInfo WHERE Amount>=10 AND Amount<=2
SELECT * FROM OrderInfo WHERE PayWay IN
 ('网上银行','邮局汇款')
SELECT * FROM OrderInfo WHERE PayWay ='网上银行'  OR 
 PayWay='邮局汇款'

SELECT COUNT(*) FROM UserInfo WHERE Gender=0--男性用户
SELECT COUNT(*) FROM UserInfo WHERE Gender=1--女性用户
--（2）使用分组来完成
SELECT COUNT(*) AS 总人数,Gender AS 性别 FROM UserInfo
GROUP BY Gender
SELECT CommodityId AS 商品编号,SUM(Amount) AS 销售总量
   FROM OrderInfo
  GROUP BY CommodityId
  ORDER BY SUM(Amount) DESC
SELECT SUM(Amount) AS 销售总量,CommodityId AS 商品编号
  FROM OrderInfo
  WHERE OrderTime BETWEEN '2013-1-1' AND '2014-11-30'
  GROUP BY CommodityId
  HAVING SUM(Amount)>10
  ORDER BY SUM(Amount) DESC

--1、先将两表中的数据相乘
--2、通过WHERE条件选 出重叠的部分
--改进版，三表连接查询
SELECT O.OrderId,U.UserName,O.Amount,C.CommodityName
 FROM OrderInfo AS O,UserInfo AS U,
CommodityInfo AS C
WHERE O.UserId=U.UserId AND C.CommodityId=O.CommodityId

--[2]使用INNER JOIN..ON
SELECT OrderId,UserName,O.Amount,CommodityName
 FROM UserInfo AS U
INNER JOIN OrderInfo AS O ON U.UserId=O.UserId
INNER JOIN CommodityInfo AS C ON O.CommodityId=C.CommodityId
WHERE U.UserName='赵可以'

--如何来分左表还是右表
--LEFT JOIN左外连接以  LEFT 左边的表为主表
--RIGHT JOIN右外连接以RIGHT 右边的表为主表
左外连与右外连接相互转换
--左外连接
SELECT S.SortName AS 类别名称,Amount AS 库存量
 FROM CommoditySort AS S 
LEFT JOIN CommodityInfo AS C
ON S.SortId=C.SortId
--相当于
--右外连接
SELECT S.SortName AS 类别名称,Amount AS 库存量
 FROM CommodityInfo AS C
RIGHT JOIN CommoditySort AS S
ON C.SortId=S.SortId

SELECT UserName AS 用户名,UserAddress AS 地址 FROM UserInfo WHERE UserId=
(
	SELECT UserId FROM OrderInfo WHERE CommodityId=
	(
		SELECT CommodityId FROM CommodityInfo 
		WHERE CommodityName='苹果Iphone6'
	)
)

SELECT UserId,UserName,UserAddress FROM UserInfo
UNION
SELECT UserId,PayWay, CONVERT(varchar(10),OrderTime) FROM OrderInfo
SELECT * FROM UserInfo WHERE UserId NOT IN
(
	SELECT DISTINCT UserId FROM OrderInfo 
)
--购买超过3个的用户的付款金额打8折
IF EXISTS(SELECT * FROM OrderInfo WHERE CommodityId IN
(
	SELECT CommodityId FROM CommodityInfo WHERE SortId=
	(
		SELECT SortId FROM CommoditySort WHERE SortName='手机数码'
	)
)AND Amount>3)
	BEGIN
		--对付款金额打8折
		UPDATE OrderInfo SET PayMoney=PayMoney*0.8
		WHERE CommodityId IN
		(
			SELECT CommodityId FROM OrderInfo WHERE CommodityId IN
			(
				SELECT CommodityId FROM CommodityInfo WHERE SortId=
				(
					SELECT SortId FROM CommoditySort WHERE SortName='手机数码'
				)
			)AND Amount>3
		)
	END
	--通常会使用NOT EXISTS对子查询的结果进行取反
	--EXISTS:子查询查到记录，结果为真，否则结果为假
	--NOT EXISTS:子查询查不到结果，返回为真，子查询查到结查，返回为假 

SELECT S.SortName AS  类别名称,cnt AS 库存量 FROM CommoditySort AS S
INNER JOIN (SELECT SortId,SUM(Amount) AS cnt FROM CommodityInfo
GROUP BY SortId
HAVING SUM(Amount)>10000) AS T
ON S.SortId=T.SortId)


#######T-SQL程序
###变量
#局部变量
@VAR
----------
DECLARE @UserID varchar(10),@pwd varchar(20)
--变量赋值
--SET
SET @UserID='zhangzhang'
--SELECT
SELECT @pwd=UserPwd FROM Userinfo where UserID=@UserID
PRINT @UserID
PRINT @pwd
GO
----------
SELECT @UserID='zhangzhang',@pwd=UserPwd
SELECT @province=useraddress FROM Userinfo --useraddress为返回多个值
SELECT @province --显示值
----注：GO之前的变量局部变量，在GO之后是不能使用的。另外SET是不允许同时为多个变量赋值，而SELECT却可以。SELECT可以接收多个值，而且SET不可以接收多个值。SET可以接收NULL值，SELECT无法接收NULL值，所以将会输出之前的旧值，不会输出NULL值。
#全局变量
@@VAR
@@IDENTITY --返回最后插入语句的标识值的系统函数，必须有标识列(唯一id)，否则不会返回标识值的。
@@ERROR --返回执行的上一个Transact-SQL语句的错误号。如果前一个 Transact-SQL 语句执行没有错误，则返回 0。
SELECT @@ERROR  --SELECT输出的时候以表格结果输出的
PRINT @@ERROR  --PRINT输出的时候以文本结果输出的
SELECT @@ERROR AS 错误号  --对结果命名别名

###数据类型转换
隐式转换：类型相兼容自动转换
显示转换：可以使用CONVERT函数或CAST函数
#CONVERT与CAST函数转换：
PRINT '错误号' + convert(varchar(10),@@ERROR)
PRINT '错误号' + CAST(@@ERROR AS varchar(5))
相同点：都能够将某数据类型转换为另一种数据类型
异同点：CONVERT有三个参数，但CONVERT函数转换有优势，转换类型很多,SELECT CONVERT(VARCHAR(10),GETDATE(),111),111为style，可以设置date或time类型的数据，其他类型为0

######流程控制语句
顺序结构：BEGIN......END
分支结构：IF.....ELSE或CASE....END
循环结构：WHILE
#顺序结构：
BEGIN
	......
END
#分支结构IF...ELSE
IF
	BEGIN
		......
	END
[ELSE
	BEGIN
		......
	END]
GO
例：
DECLARE @x int,@y int
SELECT @x=5,@y=10
IF(@x>=@y)
	BEGIN
		PRINT '@x大于等于@y'  --如果超过一条语句则需要使用BEGIN...END
		PRINT ' ' 
	END
ELSE
	PRINT '@x小于@y' 
	PRINT '程序结束了'   --这条语句不属于IF..ELSE结构语句后的代码，所以不加BEGIN...END也会执行，建议加上BEGIN..END
GO
#分支结构CASE....END
CASE
	WHEN....THEN....
	WHEN....THEN....
	[ELSE]
END
GO
例：
DECLARE @score int
SET @socre=90
SELECT 成绩=CASE
	WHEN @score>=90 THEN 'A'
	WHEN @score >=80 AND @score <90 THEN 'B'
	WHEN @score BETWEEN 70 AND 79 THEN 'C'
	ELSE 'D'
END
GO
#SQL语句中使用CASE..END
SELECT 用户编号=UserID,会员等级=
CASE
	WHEN COUNT(*)=1 THEN '普通会员'  --因为GROUP BY分类UserID汇总并只显示UserID,所以COUNT(*)表示的是UserID的下标值[表示同一个UserID分类汇总的次数]这个字段，否则多个字段显示则这里是不能使用*的
	WHEN COUNT(*) BETWEEN 2 AND 5 THEN '白金会员'
	WHEN COUNT(*) BETWEEN 6 AND 10 THEN 'VIP会员'
	ELSE 'VIP白金会员'
END
FROM OrderInfo
GROUP BY UserID
GO
#循环结构WHILE
DECLARE @i int,@sum int  --求1到10之间数累加之和
SELECT @i=1,@sum=0
WHERE(@i<=10)
	BEGEIN
		SET @sum=@sum+@i
		SET @i=@i+1
	END
PRINT '1到10之间的累加和是：'+CONVERT(varchar(3),@sum)
GO
#CONTINUE,BREAK,RETURN
CONTINUE:继续回到上一个条件处开始执行，CONTINUE后面语句将不在执行
BREAK:退出当前所在的整个父条件结构体而去执行父结构体外的语句
RETURN:退出当前批处理程序，去执行当前批处理程序后的语句
#CONTINUE:  --求1到10之间偶数之和
DECLARE @sum int,@i int
SELECT @sum=0,@i=1
WHILE(@i<=10)
	BEGIN
		IF(@i%2=0)
			BEGIN
				SET @sum=@sum+@i
				SET @i=@i+1
			END
		ELSE
			BEGIN
				SET @i=@i+1
				CONTINUE	
			END
	END
PRINT '1到10之间的偶数和为：'+CONVERT(varchar(3),@sum)
GO
###双重循环
------九九乘法表-------------
--诀窍在于行数和个数相乘
DECLARE @x int,@y int,@str varchar(100)
SELECT @x=1,@y=1,@str=''
WHILE(@x<=9)
	BEGIN
		WHILE(@y<=@x)
			BEGIN
				SET @str=@str+CONVERT(varchar(2),@x)+'*'+CONVERT(varchar(2),@y)+'='+CONVERT(varchar(2),@x*@y)+'  '
				SET @y=@y+1
			END
		PRINT @str
		PRINT ''
		SET @str=''
		SET @x=@x+1
		SET @y=1
	END
GO


######SQLServer事务
开始事务：BEGIN TRANSACTION
提交事务：COMMIT TRANSACTION
回滚或撤销事务：ROLLBACK TRANSACTION
SET NOCOUNT ON --不开启计行数功能，表示不显示受影响的行数
#事务例子：
USE bank
GO
BEGIN TRANSACTION --开始事务
DECLARE @error
SET @error=0
UPDATE banktab SET money=money-300 WHERE name='bob'
SET @error=@error+@@ERROR  --用自身的变量error+加上上条语句的错误返回代码值，如果无错，全局变量ERROR的值也为0
UPDATE banktab SET money=money+300 WHERE name='jack'
SET @error=@error+@@ERROR
IF(@error>0)
	BEGIN
		PRINT '交易失败，回滚事务！'
		ROLLBACK TRAN   --TRANSACTION可以简写成TRAN
	END
ELSE
	BEGIN
		PRINT '交易成功，提交事务！'
		COMMIT TRANSACTION   --提交事务
	ENG
GO
##嵌套事务及事务分类
全局变量@@TRANSCOUNT:
	返回当前连接的活动事务数
显式事务：
	用BEGIN TRANSACTION明确指定事务的开始，是最常用的事务类型
隐性事务：
	通过设置SET IMPLICIT_TRANSACTIONS ON语句，将隐性事务模式设置为打开，
	其后的T-SQL语句自动启动一个新事务
	提交或回滚一个事务后，下一个T-SQL语句又将启动一个新事务
自动提交事务：
	SQLServer的默认模式
	每条单独的T-SQL语句视为一个事务
例：
BEGIN TRAN ----@@TRANSCOUNT+1
	BEGIN TRAN ----@@TRANSCOUNT又+1
	COMMIT TRAN ----@@TRANSCOUNT-1
COMMIT TRAN  ----@@TRANSCOUNT又-1
#注：当在嵌套事务中使用ROLLBACK TRAN时，则TRANSCOUNT变量直接变成0，也就是说这样会直接取消父事务，使嵌套事务和父事务都会取消
如何开启显式事务：
	SET IMPLICIT_TRANSACTIONS OFF --关闭隐式事务
如何开启隐式事务：(默认是隐式事务)
	SET IMPLICIT_TRANSACTIONS ON  --开启隐式事务，开启隐式事务后必须手动执行COMMIT TRAN提交事务，如果不手动执行COMMIT TRAN则在下一个语句中(语句为改变数据库的语句)开启新的一个事务
如何开启自动提交事务：
	当设置IMPLICIT_TRANSACTIONS OFF时，就恢复成了自动提交事务模式，自动提交事务不需要使用BEGIN TRAN和COMMIT TRAN，当语句没有问题时自动会开启和提交事务

###事务的相关问题
SQLServer跟MYSQL事务原理一样。

#####视图
视图的注意事项：
	1. 新建视图时不能使用ORDER BY语句，除非用TOP限定行数。否则新建视图将不成功
	2. 新建视图时不能使用INTO插入到别的新表中，不能使用临时表的
	3. 新建视图时是不允许使用表变量的。
#临时表：
	1. 存储在tempdb数据库
	2. 本地临时表为‘#’开头，全局临时表以‘##’开关
	3. 断开连接时临时表就被删除
#表变量
	1. 表变量实际是变量一种形式
	2. 以@开头
	3. 存在内存中
DECLARE @table TABLE
(
	ID int,
	name varchar(20)
)

####索引
索引分类：
	1. 聚集索引：目录和内容是一起的，每个表只能有一个聚集索引。
	2. 非聚集索引：从目录找位置，从位置找内容，目录和内容是分开的，每个表可以有249个非聚集索引

SELECT * FROM sysindexs WHERE name='index_name' --搜索索引
#T-SQL语句创建索引：
IF EXISTS(SELECT * FROM sysindexes WHERE name='IX_UserInfo_UseAddress' )
DROP INDEX UserInfo.IX_UserInfo_UseAddress
GO
CREATE NONCLUSTERED INDEX IX_UserInfo_UseAddress--nonclustered index为表示非聚集索引
ON UserInfo(UserAddress)  --ON表名（列名）
WITH FILLFACTOR=30  --表示填充因子为30%
GO
#使用索引
SELECT * FROM UserInfo
WITH(INDEX=IX_UserInfo_UseAddress)  --使用指定索引进行查询，默认可以不指，sqlserver会默认去使用
WHERE UserAddress LIKE '%河北%'  
#查看索引
	1. 使用SSMS查看索引
	2. EXEC sp_helpindex table_name
	3. 使用视图查看索引：
		1. USE current_db
		2. SELECT * FROM sysindexes WHERE name='index_name'

########SQLSERVER存储过程
#存储过程的分类：
1. 系统存储过程：用来管理SQL SERVER和显示有关数据库和用户信息的存储过程，以sp_开头，存放在master数据库中。
2. 扩展存储过程：使用其他编程语言创建外部存储过程，并将这个存储过程在SL SERVER中作为存储过程来使用。以xp_开关的。
3. 自定义存储过程：用户在SQL SERVER中通过采用SQL语句创建存储过程，通常以usp_开头。
#存储过程的调用：
1. EXECUTE procedure_name [arg1] [arg2] ...
2. EXEC procedure_name [arg1] [arg2] ...
#系统存储过程 
USE master 
GO
EXEC sp_databases   --执行系统存储过程进行查看数据库
EXEC sp_renamedb 'test', 'mytest'  --执行系统存储过程进行重命名系统数据库
exec sp_help bumen  --执行系统存储过程进行查看帮助
exec sp_columns bumen  --执行系统存储过程进行查看表列信息
#扩展存储过程  --扩展存储过程2008以后可能会被废除，尽量不要使用扩展存储过程
USE master 
GO
EXEC sp_configure 'show advanced option',1  --启用xp_cmdshell功能
GO
RECONFIGURE --重新配置
GO
EXEC sp_configure 'xp_cmdshell',1 --打开xp_cmdshell
GO
RECONFIGURE
GO
--使用xp_cmdshell在D盘创建myfile文件夹
EXEC xp_cmdshell 'mkdir e:\myfile',no_output  --no_output表示不输出返回信息
GO  
#自定义存储过程
#创建存储过程

SET ANSI_NULLS ON  --SET ANSI_NULLS ON:表示对空值(null)对等于(=)或不等于(<>)进行判断时，遵从 SQL-92 规则，表示用=,<>进行比较时都为false,就是不允许进行比较
GO
SET QUOTED_IDENTIFIER ON  --SET QUOTED_IDENTIFIER ON:表示使用引用标识符，标识符可以用双引号分隔或者不加双引号分隔，但是，文字必须用单引号分隔。当为OFF时则表示用双引号分隔的都为值，跟ON正好相反
GO

select * from openrowset('SQLOLEDB','server_address'; 'sa';'password',database.dbo.table) --可以查询其它服务器表数据到当前结果集中

ROW_NUMBER() OVER(ORDER BY SalesYTD DESC) --返回结果集分区内行的序列号，每个分区的第一行从 1 开始。ORDER BY 子句可确定在特定分区中为行分配唯一 ROW_NUMBER 的顺序。

例：
SELECT FirstName, LastName, ROW_NUMBER() OVER(ORDER BY SalesYTD DESC) AS 'Row Number', SalesYTD, PostalCode 
FROM Sales.vSalesPerson
WHERE TerritoryName IS NOT NULL AND SalesYTD <> 0;



CREATE PROC[EDURE] procedure_name
AS 
	SQL statement
GO
#调用存储过程
EXEC procedure_name
GO

####创建带参数的存储过程
CREATE PROC[EDURE] procedure_name
	@startDate datetime,   --第一个参数没有默认值必须填入参数
	@endDate datetime=null,  --第二个参数有默认值可以不填入参数
	@userId varchar(20)=null --第三个参数有默认值可以不填入参数
AS 
	SQL statement
GO
#调用带参数的存储过程
EXEC procedure_name '2019-06-01'
或者
EXEC procedure_name '2019-06-01','2019-07-01',1 --隐式调用对参数顺序有要求
或者 
EXEC procedure_name @startDate='2019-06-01',@userId=default,@endDate='2019-07-01' --显式调用对参数顺序无要求，但变量名称(名称必须是存储过程的变量名)和值必须写，默认值可以使用default
或者
DECLARE @arg1 datetime,@arg2 datetime,@arg3 varchar(20)
SELECT @arg1='2019-06-01',@arg2='2019-07-01',@arg3=1
EXEC procedure_name @arg1,@arg2,@arg3 --用声明变量来调用


###创建带输入输出参数的存储过程
CREATE PROC[EDURE] procedure_name
	@startDate datetime,   
	@endDate datetime=null,  
	@userId varchar(20)=null 
AS 
	DECLARE @test int
	SQL statement
	SET @test=@@IDENTITY  --在存储过程在设置变量@test，用于在调用存储过程时输出
GO
#调用带输入输出参数的存储过程
EXEC procedure_name '2019-06-01','2019-07-01',1 output --output为输出参数信息
PRINT '测试值为：'+CONVERT(VARCHAR(5),@test)

###创建带返回值的存储过程
CREATE PROC[EDURE] procedure_name
	@startDate datetime,   
	@endDate datetime=null,  
	@userId varchar(20)=null 
AS 
	SELECT @startDate='2019-06-01',@endDate='2019-07-01',@userId=1
	INSERT INTO table1 VAULES (@startDate,@endDate,@userId)
	IF @@ERROR>0
		RETURN -1
	ELSE
		RETURN @@IDENTITY
GO
#调用带返回值的存储过程
DECLARE @result int
EXEC @result=procedure_name '2019-06-01','2019-07-01',1 
IF @result=-1
	PRINT '插入失败!'
ELSE 
	PRINT '插入成功!'
GO

########创建和使用存储过程的注意事项
创建存储过程：
	1. 在有默认值的参数变量写在声明变量最后
	2. 在结束存储过程创建时必须写GO结束
调用存储过程：
	1. 调用参数使用隐式存储调用时参数必须与定义存储过程参数位置相同
	2. 如果使用显示存储调用，则可以不按顺序写，但变量名必须和参数变量名一样
	3. 如果调用存储过程是批处理中的第一个语句，则可以省略EXEC不写

### 交叉应用CROSS APPLY()
```sql
SELECT T1.StudentNo, T1.Name, T2.ExamScore, T2.ExamDate 
FROM Student AS T1
CROSS APPLY(
    SELECT TOP 2 * 
	FROM Score AS T
    WHERE T1.StudentNo = T.StudentNo
    ORDER BY T.ExamDate DESC
) AS T2
```
> CROSS APPLY()工作原理是把左表当做目标表，把子集表当做源表，拿源表的每一行去跟目标表的行去比较(字段必须相对应连接)，当源表和目标表匹配到时则保留，反则丢弃。子集表中ORDER BY比top优先级高。

### 外部应用OUTER APPLY()
```sql
SELECT T1.StudentNo, T1.Name, T2.ExamScore, T2.ExamDate 
FROM Student AS T1
OUTER APPLY(
    SELECT TOP 2 * 
	FROM Score AS T
    WHERE T1.StudentNo = T.StudentNo
    ORDER BY T.ExamDate DESC
) AS T2
```
> OUTER APPLY()工作原理是把左表当做目标表，把子集表当做源表，拿源表的每一行去跟目标表的行去比较(字段必须相对应连接)，当源表和目标表匹配到时则保留，如果未匹配到，则目标表显示，源表显示为NULL。子集表中ORDER BY比top优先级高。(类似LEFT JOIN，与LEFT JOIN不同的是OUTER APPLY()是拿子集表的多行跟左表的一行去比较)




# 常用操作SQL

## 1. 查询数据库会话
```sql
select spid as ProcessID,db_name(dbid) as DBNAME,loginame as UserName,count(dbid) as Connection 
from master.sys.sysprocesses 
where dbid > 4
group by spid,dbid,loginame

kill 55

select session_id,login_time,login_name,host_name,
host_process_id,status,memory_usage,reads,writes
from sys.dm_exec_sessions 
where group_id = 2
order by reads desc


select * 
from [master].dbo.sysprocesses 
where dbid in 
(
Select dbid from master.dbo.sysdatabases where name in ('homsomdb')
)
order by physical_io desc

kill 122


select 
	t1.session_id,
	t1.client_net_address,
	t1.client_tcp_port,
	t1.local_net_address,
	t1.local_tcp_port,
	t1.connect_time,
	t1.num_reads,
	t1.num_writes,
	t1.last_read,
	t1.last_write,
	t1.net_packet_size,
	t2.login_time,
	t2.login_name,
	t2.host_name,
	t2.program_name,
	t2.host_process_id,
	t2.status,
	t2.cpu_time,
	t2.memory_usage,
	t2.total_scheduled_time,
	t2.last_request_start_time,
	t2.last_request_end_time,
	t2.reads,
	t2.writes,
	t2.logical_reads
from sys.dm_exec_sessions t2
left join sys.dm_exec_connections t1 on t1.session_id=t2.session_id
order by t2.logical_reads desc

--kill 63 
```



## 2. 数据库镜像操作

```sql
-- 删除镜像，并将原先正在还原的数据库设为可操作
alter database test set partner off;
restore database test with recovery;

-- 主机备份
USE master
GO
BACKUP DATABASE [test] TO DISK = N'D:\test.bak'
WITH FORMAT, INIT, NAME = N'DBtestSync-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10;
GO
BACKUP LOG [test] TO DISK = N'D:\test.bak'
WITH NOFORMAT, NOINIT, NAME = N'DBtestSync-Transaction Log Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10;
GO 

-- 镜像还原并置为正在还原的状态
USE master
GO
RESTORE DATABASE [test] FROM DISK = N'D:\test.bak'
WITH FILE = 1,
NORECOVERY, NOUNLOAD, REPLACE, STATS = 10
GO
RESTORE LOG [test] FROM DISK = N'D:\test.bak'
WITH FILE = 2,
NORECOVERY, NOUNLOAD, STATS = 10
GO

-- 注意
主机和镜像服务器的数据库服务都需要使用域控的hs\administrator账户启用，在配置镜像时都使用hs\administrator
```



## 3. 主备切换
```
【1】.在高安全模式下：
在主机执行:
use master;
alter database Demo1 set partner failover;
即完成主备切换
【2】.在高性能模式下，需要先切换到高安全模式下再执行切换
在主机执行:
use master;
alter database Demo1 set partner safety full;
alter database Demo1 set partner failover;
【3】.在主机（SQLSVR1）宕机的情况下在备机（SQLSVR2）进行强制切换：
use master;
alter database Demo1 set partner FORCE_SERVICE_ALLOW_DATA_LOSS;
当主机(SQLSVR1)重新开机后，在SQLSVR2机器上执行
use master;
alter database Demo1 set partner resume;
此时SQLSVR1成为了备机，而SQLSVR2成为了主机。
再到SQLSVR2机器上执行
alter database Demo1 set partner failover;
就成了SQLSVR1成为主机，SQLSVR2成为备机
【4】切换镜像在高性能模式下(慎用，可能会丢失数据)
use master;
alter database Demo1 set partner safety off;
【5】.关闭数据库镜像
ALTER DATABASE Demo1 SET PARTNER OFF
【6】.暂停与恢复数据库镜像
　　在主体镜像服务器上，若是不小心日志过大，可以进行暂停来设置日志上限
　　（1）暂停：ALTER DATABASE AdventureWorks2012 SET PARTNER SUSPEND;
　　（2）恢复：ALTER DATABASE AdventureWorks2012 SET PARTNER RESUME;
【7】移除见证服务器
USE [master]
GO
ALTER DATABASE Demo1 SET WITNESS OFF
GO
-- 参考链接：https://www.cnblogs.com/gered/p/10601202.html
```



## 4. 备份还原脚本
```sql
-- Full Backup
BACKUP DATABASE [test] TO  DISK =test_202102020200_diff.bak  WITH NOFORMAT  
, NOINIT,  NAME = N'test-完整 数据库 备份', SKIP, NOREWIND, NOUNLOAD,  STATS = 10  

-- Different Backup
BACKUP DATABASE [test] TO  DISK =test_202102020300_diff.bak  WITH  DIFFERENTIAL, NOFORMAT
, NOINIT,  NAME = N'test-差异 数据库 备份', SKIP, NOREWIND, NOUNLOAD,  STATS = 10

-- Transaction Log Backup
BACKUP LOG test TO  DISK =test_202102022300_log.trn WITH NAME=N'ehomsom 日志'

----数据库备份
--#Full Backup
BACKUP DATABASE [FinanceDB20210304] TO  DISK ='I:\tmpBackupDB\FinanceDB_full.bak'  WITH NOFORMAT  
, NOINIT,  NAME = N'[FinanceDB20210304]-完整 数据库 备份', SKIP, NOREWIND, NOUNLOAD,  STATS = 10  

--#Different Backup
BACKUP DATABASE [FinanceDB20210304] TO  DISK ='I:\tmpBackupDB\FinanceDB_diff.bak'  WITH  DIFFERENTIAL, NOFORMAT
, NOINIT,  NAME = N'[FinanceDB20210304]-差异 数据库 备份', SKIP, NOREWIND, NOUNLOAD,  STATS = 10

--#Transaction Log Backup
BACKUP LOG [FinanceDB20210304] TO  DISK ='I:\tmpBackupDB\FinanceDB_log.trn' WITH NAME=N'[FinanceDB20210304] 日志'
```

**数据库还原脚本**

```sql
-- 还原数据库FinanceDB
use master
go

create database FinanceDB20210304
GO

-- 还原全量备份
RESTORE DATABASE FinanceDB20210304
FROM
DISK='K:\2020\11\FinanceDB_20201101020001_full.bak'
WITH MOVE 'FinanceDB' TO 'F:\TmpDb\FinanceDB20210304.mdf',
MOVE 'FinanceDB_log' TO 'F:\TmpDb\FinanceDB20210304_log.ldf',
STATS = 10, REPLACE,NORECOVERY
GO

-- 还原差异备份
RESTORE DATABASE FinanceDB20210304
FROM
DISK='K:\2020\11\FinanceDB_20201107030000_diff.bak'
WITH STATS = 10,
REPLACE,RECOVERY
GO

-- 还原事务日志备份
RESTORE LOG sms2018
FROM
DISK = N'L:\2018\10\SMS20181022230000_log.trn'
WITH STATS = 10, RECOVERY ,STOPAT='2018-10-22 14:30:00'
GO


-- 还原数据库topway
USE master
GO

CREATE DATABASE [topway20210303]
--RESTORE FILELISTONLY FROM DISK = N'L:\2020\2021\02\topway_20210228020000_full.bak'
--RESTORE VERIFYONLY FROM DISK = N'L:\2020\2021\02\topway_20210228020000_full.bak' WITH STATS=10 -- ,CHECKSUM;
RESTORE DATABASE [topway20210303] FROM DISK = N'L:\2020\2021\02\topway_20210228020000_full.bak'
WITH MOVE 'topway_data' TO 'F:\TmpDb\topway20210303.mdf',
MOVE 'ftrow_custphone' TO 'F:\TmpDb\topway20210303.ndf',
MOVE 'topway_log' TO 'F:\TmpDb\topway20210303_log.ldf',
FILE = 1,
NORECOVERY, REPLACE, STATS = 10
GO

RESTORE DATABASE [topway20210303] FROM DISK = N'L:\2020\2021\03\topway_20210302030000_diff.bak'
WITH REPLACE, STATS = 10,
FILE = 1,
--RECOVERY
NORECOVERY
GO

RESTORE LOG [topway20210303] FROM DISK = N'L:\2020\2021\03\Topway20210302230000_log.trn'
WITH FILE=1,NORECOVERY,REPLACE,STATS=10
GO

RESTORE LOG [topway20210303] FROM DISK = N'L:\2020\2021\03\Topway20210303230000_log.trn'
WITH FILE=2,RECOVERY,REPLACE,STATS=10 --,STOPAT='2021-03-04 20:25:00' --时间不能大于事务日志时间，否则还原会处于还原状态
GO


--参数说明：
--WITH MOVE TO：重新指定文件的路径，WITH MOVE
--TO数量取决于数据库文件数量
--STATS = 10：没完成10%显示一条记录
--REPLACE：覆盖现有数据库
--NORECOVERY：不对数据库进行任何操作，不回滚未
--提交的事务
```



## 5. 查询死锁
```sql
select    
    request_session_id spid,   
    OBJECT_NAME(resource_associated_entity_id) tableName    
from    
    sys.dm_tran_locks   
where    
    resource_type='OBJECT' 
	
	
-- 杀死死锁进程
kill 354 

-- 显示死锁相关信息
exec sp_who2 354

-- SQLServer查看用户连接数
SELECT login_name,  
       Count(0) user_count  
FROM   Sys.dm_exec_requests dr WITH(nolock)  
       RIGHT OUTER JOIN Sys.dm_exec_sessions ds WITH(nolock)  
                     ON dr.session_id = ds.session_id  
       RIGHT OUTER JOIN Sys.dm_exec_connections dc WITH(nolock)  
                     ON ds.session_id = dc.session_id  
WHERE  ds.session_id > 50  
GROUP  BY login_name  
ORDER  BY user_count DESC 


-- 查询死锁的存储过程
USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_who_lock_TMP]    Script Date: 2025/4/14 15:06:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER PROCEDURE [dbo].[sp_who_lock_TMP]
AS
    BEGIN
        DECLARE @spid INT ,
            @bl INT ,
            @intTransactionCountOnEntry INT ,
            @intRowcount INT ,
            @intCountProperties INT ,
            @intCounter INT
 
        CREATE TABLE #tmp_lock_who
            (
              id INT IDENTITY(1, 1) ,
              spid SMALLINT ,
              bl SMALLINT
            )
 
        IF @@ERROR <> 0
            RETURN @@ERROR
 
        INSERT INTO #tmp_lock_who ( spid, bl )
                SELECT 0, blocked
                    FROM ( SELECT *
                            FROM sys.sysprocesses
                            WHERE blocked > 0
                         ) a
                    WHERE NOT EXISTS ( SELECT *
                                        FROM ( SELECT *
                                                FROM sys.sysprocesses
                                                WHERE blocked > 0
                                             ) b
                                        WHERE a.blocked = spid )
                UNION
                SELECT spid, blocked
                    FROM sys.sysprocesses
                    WHERE blocked > 0
 
        IF @@ERROR <> 0
            RETURN @@ERROR
 
       -- 找到临时表的记录数
        SELECT @intCountProperties = COUNT(*), @intCounter = 1
            FROM #tmp_lock_who
 
        IF @@ERROR <> 0
            RETURN @@ERROR
 
        IF @intCountProperties = 0
            SELECT N'现在没有阻塞和死锁信息' AS message
       -- 循环开始
        WHILE @intCounter <= @intCountProperties
            BEGIN
              -- 取第一条记录
                SELECT @spid = spid, @bl = bl
                    FROM #tmp_lock_who
                    WHERE Id = @intCounter
                BEGIN
                    IF @spid = 0
                        SELECT N'引起数据库死锁的是: ' + CAST(@bl AS VARCHAR(10))
                                + N'进程号,其执行的SQL语法如下'
                    ELSE
                        SELECT N'进程号SPID：' + CAST(@spid AS VARCHAR(10))
                                + N'被进程号SPID：' + CAST(@bl AS VARCHAR(10)) N'阻塞,其当前进程执行的SQL语法如下'
                    DBCC INPUTBUFFER (@bl )
                END
 
              -- 循环指针下移
                SET @intCounter = @intCounter + 1
            END
 
 
        DROP TABLE #tmp_lock_who
 
        RETURN 0
    END
--
```



## 6. 用户管理

```sql
-- 进入系统数据库
use master 
go 

-- 创建登录用户
create login ops with password='123456',check_policy=off,check_expiration=off,DEFAULT_DATABASE=master;

-- 创建数据库用户并绑定登录用户
use test
create user ops for login ops with default_schema = dbo 
go
use topway20250408
create user ops for login ops with default_schema = dbo 
go


-- 新建角色并授予角色权限
use test
go
EXEC sp_addrole 'hs_ops_role'
GRANT UPDATE TO hs_ops_role
go

use topway20250408
EXEC sp_addrole 'hs_ops_role'
GRANT UPDATE TO hs_ops_role
go



-- 赋予数据库用户特定角色权限
use test
exec sp_addrolemember 'db_datareader','ops'		-- 通过加入数据库角色，赋予数据库用户db_datareader权限
exec sp_addrolemember 'hs_ops_role','ops'			-- 再授予更新权限
go 

use topway20250408
exec sp_addrolemember 'db_datareader','ops'		-- 通过加入数据库角色，赋予数据库用户db_datareader权限
exec sp_addrolemember 'hs_ops_role','ops'			-- 再授予更新权限
go 


-- 进入test数据库测试
use test
go 
-- 测试权限，模拟登录用户ops
EXECUTE AS USER = 'ops';
-- 查看当前登录名
select USER_NAME();
-- 测试SELECT权限（应成功）
SELECT * FROM Orders
-- 测试UPDATE权限（应成功）
UPDATE Orders SET Amount = '888' WHERE OrderID = 101;
-- 测试DELETE权限（应失败）
DELETE FROM Orders WHERE OrderID = 101;
-- 退出模拟登录用户
REVERT;



-- 数据库级别，查看指定角色db_datareader中有哪些用户
SELECT 
    dp.name AS UserName,
    r.name AS RoleName
FROM 
    sys.database_role_members drm
JOIN 
    sys.database_principals r ON drm.role_principal_id = r.principal_id
JOIN 
    sys.database_principals dp ON drm.member_principal_id = dp.principal_id
WHERE 
    r.name = 'db_datareader';
	


-- 查看所有用户对应的所有角色权限
use test;
EXEC sp_helpuser;
-- 查看指定用户对应的角色权限
use test;
EXEC sp_helpuser ops;
-- UserName	RoleName	LoginName	DefDBName	DefSchemaName	UserID	SID
-- ops	hs_ops_role	ops	master	dbo	46        	0x05C2B6064623A94DA5A6E89716C61791
-- ops	db_datareader	ops	master	dbo	46        	0x05C2B6064623A94DA5A6E89716C61791

-- 为用户删除角色
use test;
EXEC sp_droprolemember 'hs_ops_role', 'ops';

-- 再次查看指定用户对应的角色权限
use test;
EXEC sp_helpuser ops;
-- UserName	RoleName	LoginName	DefDBName	DefSchemaName	UserID	SID
-- ops	db_datareader	ops	master	dbo	6         	0x05C2B6064623A94DA5A6E89716C61791



-- 服务器级别，查看登录用户是否启用或禁用
SELECT name AS 登录名, 
       type_desc AS 类型, 
       create_date AS 创建时间, 
       case when is_disabled=0 then N'启用'
		when is_disabled=1 then N'禁用' 
		else '' END AS 是否禁用
FROM sys.server_principals
WHERE type IN ('U', 'S', 'G')  -- U: Windows用户, S: SQL登录, G: Windows组
and name = 'ops'



-- 服务器级别，启用、禁用登录账户
alter login ops disable
alter login ops enable



-- 服务器级别，修改登录用户名称
alter login ops with name = operator
-- 服务器级别，修改登录用户密码
alter login operator with password = '666666'
-- 数据库级别，修改登录用户默认架构
use test;
alter user ops with default_schema = sys




-- 再次查看指定用户对应的角色权限
use test;
EXEC sp_helpuser ops;
-- UserName	RoleName	LoginName	DefDBName	DefSchemaName	UserID	SID
-- ops	db_datareader	operator	master	sys	6         	0x05C2B6064623A94DA5A6E89716C61791

use topway20250408;
EXEC sp_helpuser ops;
-- UserName	RoleName	LoginName	DefDBName	DefSchemaName	UserID	SID
-- ops	hs_ops_role	operator	master	sys	46        	0x05C2B6064623A94DA5A6E89716C61791
-- ops	db_datareader	operator	master	sys	46        	0x05C2B6064623A94DA5A6E89716C61791


-- 为数据库用户删除角色，记住是数据库用户而不是登录用户
use test;
EXEC sp_droprolemember 'db_datareader', 'ops';

use topway20250408;
EXEC sp_droprolemember 'hs_ops_role', 'ops';
EXEC sp_droprolemember 'db_datareader', 'ops';


-- 再次查看指定用户对应的角色权限
use test;
EXEC sp_helpuser ops;
-- UserName	RoleName	LoginName	DefDBName	DefSchemaName	UserID	SID
-- ops	public	operator	master	sys	6         	0x05C2B6064623A94DA5A6E89716C61791

use topway20250408;
EXEC sp_helpuser ops;
-- UserName	RoleName	LoginName	DefDBName	DefSchemaName	UserID	SID
-- ops	public	operator	master	sys	46        	0x05C2B6064623A94DA5A6E89716C61791


-- 删除数据库用户
use test
drop user ops 

use topway20250408
drop user ops 


-- 删除登录用户
drop login operator
-- 无法删除登录名 'operator'，因为该用户当前正处于登录状态。

-- 查看客户端连接
SELECT 
    conn.session_id,
    conn.client_net_address,
    sess.host_name,
    sess.program_name,
    sess.login_name,
    sess.last_request_start_time,
    sess.last_request_end_time,
    sess.status
FROM 
    sys.dm_exec_connections AS conn
    INNER JOIN sys.dm_exec_sessions AS sess
        ON conn.session_id = sess.session_id
where login_name = 'operator'

-- session_id	client_net_address	host_name	program_name	login_name	last_request_start_time	last_request_end_time	status
-- 61	172.168.2.219	HS-UA-TSJ-0132	Microsoft SQL Server Management Studio	operator	2025-04-14 17:41:03.390	2025-04-14 17:41:03.390	sleeping
-- 65	172.168.2.219	HS-UA-TSJ-0132	Microsoft SQL Server Management Studio	operator	2025-04-14 17:41:03.383	2025-04-14 17:41:03.383	sleeping

-- 结束客户端连接
kill 61
kill 65

-- 删除登录用户
drop login operator
```



## 7. 授予权限

授予存储过程、执行计划、视图等权限

- **对象级权限**：

  ```sql
  -- 授予用户对存储过程的执行权限,OBJECT::dbo表示对特定数据库对象（如表、视图、存储过程）的权限控制。例如，dbo.sp_CalculateSalary表示属于dbo架构的表。
  GRANT EXECUTE ON OBJECT::dbo.sp_CalculateSalary TO UserC;
  
  -- TYPE指用户定义数据类型（UDT），TYPE::dbo表示对属于dbo架构的自定义数据类型的权限。
  GRANT EXECUTE ON TYPE::dbo.PhoneNumber TO UserB;
  ```

  

- **架构级权限**：

  ```sql
  -- 禁止角色修改dbo架构下的所有对象
  DENY ALTER ON SCHEMA::dbo TO Role_Developers;
  ```

  

- **数据库级权限**：

  ```sql
  -- 允许用户创建新表
  GRANT CREATE TABLE TO UserD;
  ```

  

- **除了上述类型，SQL Server还支持以下安全对象（Securable）的权限管理：**

  | **对象类型**         | **描述**               | **适用权限示例**                                      |
  | -------------------- | ---------------------- | ----------------------------------------------------- |
  | **DATABASE**         | 数据库级别的权限       | `CREATE TABLE`, `BACKUP DATABASE`, `ALTER ANY USER`   |
  | **SERVER**           | 服务器级别的权限       | `CREATE DATABASE`, `ALTER SERVER ROLE`, `CONNECT SQL` |
  | **ENDPOINT**         | 通信端点（如HTTP端点） | `ALTER`, `CONNECT`, `TAKE OWNERSHIP`                  |
  | **LOGIN**            | 服务器登录账户         | `IMPERSONATE`, `CONTROL`, `ALTER ANY LOGIN`           |
  | **ROLE**             | 数据库角色或服务器角色 | `ALTER`, `CONTROL`, `ADD MEMBER`                      |
  | **ASSEMBLY**         | 程序集（CLR集成）      | `EXECUTE`, `REFERENCES`, `ALTER`                      |
  | **FULLTEXT CATALOG** | 全文目录               | `CONTROL`, `REFERENCES`                               |
  | **SYMMETRIC KEY**    | 对称密钥               | `VIEW DEFINITION`, `ALTER`, `REFERENCES`              |
  | **CERTIFICATE**      | 证书                   | `CONTROL`, `TAKE OWNERSHIP`                           |
  | **SEQUENCE**         | 序列对象               | `UPDATE`, `CONTROL`                                   |



```sql
---- 授予存储过程权限
use homsomdb
SELECT 'GRANT EXECUTE,VIEW DEFINITION ON[dbo].[' + name + ']TO [WN010]' AS t_sql FROM sys.procedures
-- SELECT 'GRANT EXECUTE,VIEW DEFINITION,ALTER ON[dbo].[' + name + ']TO [hs\testuser]' AS t_sql FROM sys.procedures
GRANT EXECUTE,VIEW DEFINITION  ON [dbo].[AutomaticTicketing_GetRecord]TO [WN010]
-- revoke EXECUTE,VIEW DEFINITION on [dbo].[AutomaticTicketing_GetRecord] from [WN010]


---- 授予执行计划权限
-- 数据库级别权限
USE topway
GRANT SHOWPLAN TO [HS\testuser]
-- 服务器级别权限
GRANT SHOWPLAN TO [HS\testuser] AS SERVER

-- 批量脚本生成
SELECT 'USE ' + name + '; GRANT SHOWPLAN TO [test];' 
FROM sys.databases;



---- 授予其它权限
USE topway;
GO
 
DECLARE @loginname VARCHAR(32);
SET @loginname='[hs\testuser]'

-- 给用户授予查看存储过程定义的权限
SELECT  'GRANT EXECUTE,VIEW DEFINITION,ALTER ON ' + SCHEMA_NAME(schema_id) + '.'
        + QUOTENAME(name) + ' TO ' + @loginname + ';'
FROM    sys.procedures where is_ms_shipped=0
ORDER BY 1 ;
 
 
-- 给用户授予查看自定义函数定义的权限, 'SQL_TABLE_VALUED_FUNCTION'此表值函数无执行权限
SELECT  'GRANT EXECUTE,VIEW DEFINITION ON ' + SCHEMA_NAME(schema_id) + '.'
        + QUOTENAME(name) + ' TO ' + @loginname + ';'
FROM    sys.objects
WHERE   type_desc IN ( 'SQL_SCALAR_FUNCTION','AGGREGATE_FUNCTION' );
ORDER BY 1 ;

 
-- 给用户授予查看视图定义的权限
SELECT  'GRANT VIEW DEFINITION ON ' + SCHEMA_NAME(schema_id) + '.'
        + QUOTENAME(name) + ' TO ' + @loginname + ';'
FROM    sys.views;
ORDER BY 1 ;
 
 
-- 给用户授予查看表定义的权限
SELECT 'GRANT VIEW DEFINITION ON ' + SCHEMA_NAME(schema_id) 
      + QUOTENAME(name) + ' TO ' + @loginname + ';' 
FROM sys.tables
ORDER BY 1 ;



```



## 8. sql_exporter账户

sql_exporter登录账户创建、数据库账户创建、赋权

```sql
--
DECLARE @sql VARCHAR(max)

SET @sql=CAST('use master;CREATE LOGIN [sql_exporter] WITH PASSWORD=N''qICJEasdqwDiOSrdT96'', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF; GRANT VIEW SERVER STATE TO [sql_exporter];
GRANT VIEW ANY DEFINITION TO [sql_exporter];' AS VARCHAR(max))

select @sql=@sql+CAST('use '+name+';CREATE USER [sql_exporter] FOR LOGIN [sql_exporter];EXEC sp_addrolemember N''db_datareader'', N''sql_exporter'';'+CHAR(10) AS VARCHAR(max)) 
from master.sys.databases  where state=0

select @sql
exec(@sql)
--


---- sql_exporter权限授予
-- 设置变量
DECLARE @sql VARCHAR(max)
-- 新建登录用户并授权查看服务器状态、查看任何定义权限给用户语句
SET @sql=CAST('use master;CREATE LOGIN [sql_exporter] WITH PASSWORD=N''qICJEasdqwDiOSrdT96'', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF; GRANT VIEW SERVER STATE TO [sql_exporter];
GRANT VIEW ANY DEFINITION TO [sql_exporter];' AS VARCHAR(max))
-- 在上一步基础上，在每一个数据库中新建用户并映射到上面新建的登录用户，赋予角色权限"db_datareader"给"sql_exporter"
select @sql=@sql+CAST('use '+name+';CREATE USER [sql_exporter] FOR LOGIN [sql_exporter];EXEC sp_addrolemember N''db_datareader'', N''sql_exporter'';'+CHAR(10) AS VARCHAR(max)) 
from master.sys.databases  where state=0
-- 执行整个拼接语句
EXEC(@sql)
-- 上面拆解语句
use master;
CREATE LOGIN [sql_exporter] WITH PASSWORD=N'qICJEasdqwDiOSrdT96',DEFAULT_DATABASE=[master],CHECK_EXPIRATION=OFF,CHECK_POLICY=OFF;
GRANT VIEW SERVER STATE TO [sql_exporter];
GRANT VIEW ANY DEFINITION TO [sql_exporter];
use ActivityDB; CREATE USER [sql_exporter] FOR LOGIN [sql_exporter]; exec sp_addrolemember N'db_datareader', N'sql_exporter';
```

**sql_exporter用户删除**
```sql
DECLARE @sql VARCHAR(max)

SET @sql=CAST('' AS VARCHAR(max))

select @sql=@sql+CAST('use '+name+';DROP USER [sql_exporter];'+CHAR(10) AS VARCHAR(max)) 
from master.sys.databases  where state=0

select @sql=@sql+CAST('use master;DROP LOGIN [sql_exporter];' +CHAR(10) AS VARCHAR(max)) 

select @sql
exec(@sql)
```




## 9. 其它常用查询
```sql
-- sqlserver主键重置为0
dbcc checkident('BspDateInfo',reseed,0)	# 参数1：表名，参数2：固定参数，表示重新设置，参数3：重置ID为0，插入下一条数据则为1

-- 查看当前的实际活跃连接数
SELECT COUNT(*) AS active_connections
FROM sys.dm_exec_sessions
WHERE session_id > 50; -- 排除系统会话

-- 查看sqlserver连接情况
SELECT 
    conn.session_id,
    conn.client_net_address,
    sess.host_name,
    sess.program_name,
    sess.login_name,
    sess.last_request_start_time,
    sess.last_request_end_time,
    sess.status
FROM 
    sys.dm_exec_connections AS conn
    INNER JOIN sys.dm_exec_sessions AS sess
        ON conn.session_id = sess.session_id;

-- 查看死锁
exec [dbo].[sp_who_lock]

-- 查看sqlserver系统配置
SELECT * FROM sys.configurations

-- 查看当前的最大工作线程数和affinity mask设置
SELECT
    configuration_id,
    name,
    value,
    value_in_use
FROM
    sys.configurations
WHERE
    name = 'max worker threads' OR
    name = 'affinity mask';

-- 修改 max worker threads 和 affinity mask 设置
EXEC sp_configure 'max worker threads', <desired_number>;
RECONFIGURE;
EXEC sp_configure 'affinity mask', <hexadecimal_value>;
RECONFIGURE;


-- 检查权限： 检查当前用户或者'hs\testuser'用户是否有执行存储过程的权限
USE topway20231218
GO
SELECT * 
FROM sys.database_permissions
WHERE major_id = OBJECT_ID('[dbo].[AirTicketAnalysis]')
  AND grantee_principal_id = USER_ID('hs\testuser');

-- 配置存储过程权限
USE topway20231218
GO
GRANT EXECUTE ON [dbo].[AirTicketAnalysis] TO [hs\testuser];
-- GRANT EXECUTE ON OBJECT::dbo.AirTicketAnalysis TO [hs\testuser];


-- 取消存储过程权限
REVOKE EXECUTE ON [dbo].[AirTicketAnalysis] TO [hs\testuser]


-- 查看当前数据库用户有哪些权限
use test;
EXEC sp_helpuser ops;
-- UserName	RoleName	LoginName	DefDBName	DefSchemaName	UserID	SID
-- ops	hs_ops_role	ops	master	dbo	46        	0x05C2B6064623A94DA5A6E89716C61791
-- ops	db_datareader	ops	master	dbo	46        	0x05C2B6064623A94DA5A6E89716C61791


-- 查看角色有哪些用户，显示用户名称
SELECT 
    dp.name AS UserName,
    r.name AS RoleName
FROM 
    sys.database_role_members drm
JOIN 
    sys.database_principals r ON drm.role_principal_id = r.principal_id
JOIN 
    sys.database_principals dp ON drm.member_principal_id = dp.principal_id
WHERE 
    r.name = 'db_datareader';
	



-- 配置表类型权限 
-- 切换数据库
use your_db;
-- 授予用户表类型dbo.IntlProtocolBandingData权限EXECUTE,REFERENCES,VIEW DEFINITION
GRANT EXECUTE,REFERENCES,VIEW DEFINITION ON TYPE::dbo.IntlProtocolBandingData TO [hs\prod-dbuser];
-- 查看当前用户表类型权限 
SELECT * FROM fn_my_permissions('dbo.IntlProtocolBandingData', 'TYPE');
-- 以下是输出结果
entity_name	subentity_name	permission_name
dbo.IntlProtocolBandingData		REFERENCES
dbo.IntlProtocolBandingData		EXECUTE
dbo.IntlProtocolBandingData		VIEW DEFINITION
dbo.IntlProtocolBandingData		TAKE OWNERSHIP
dbo.IntlProtocolBandingData		CONTROL






-- 查看死锁
exec [dbo].[sp_who_lock]
--kill 1012


-- 查看当前的实际活跃连接数
SELECT COUNT(*) AS active_connections
FROM sys.dm_exec_sessions
WHERE session_id > 50; 

-- 查看客户端连接
SELECT 
    conn.session_id,
    conn.client_net_address,
    sess.host_name,
    sess.program_name,
    sess.login_name,
    sess.last_request_start_time,
    sess.last_request_end_time,
    sess.status
FROM 
    sys.dm_exec_connections AS conn
    INNER JOIN sys.dm_exec_sessions AS sess
        ON conn.session_id = sess.session_id;

-- 查看当前活动的会话:
SELECT
    sess.session_id,
    sess.login_name,
    req.status,
    req.command,
    sess.cpu_time,
		sess.memory_usage,
		sess.total_scheduled_time,
    req.total_elapsed_time,
    sqltext.text
FROM
    sys.dm_exec_sessions AS sess
JOIN
    sys.dm_exec_requests AS req
    ON sess.session_id = req.session_id
CROSS APPLY
    sys.dm_exec_sql_text(req.sql_handle) AS sqltext
ORDER BY
    req.total_elapsed_time,sess.cpu_time,sess.memory_usage DESC;






-- DBCC LOGINFO(EtermSrv_SysDB);

--------------- ldf文件收缩 -----------
------ 0. 进入数据库
----use [ITConfigDB]

------ 1. 查看当前打开的事务
----DBCC OPENTRAN;

------ 2. 备份事务日志
----BACKUP LOG [ITConfigDB] TO DISK = 'E:\test\ITConfigDB_20250408103501.trn';

------ 3. 执行检查点
----CHECKPOINT;

------ 4. 查看日志文件状态
----DBCC LOGINFO([ITConfigDB]);

------ 5. 收缩日志文件
----DBCC SHRINKFILE ([ITConfigDB_log], 1);

------ 6. 重复备份和收缩（如果需要）
----BACKUP LOG [ITConfigDB] TO DISK = 'E:\test\ITConfigDB_20250408103502.trn';
----DBCC SHRINKFILE ([ITConfigDB_log], 1);


--------------------------------
---- 批量写入事务日志，是head-log移到最前面
-- 查看日志head-log
-- DBCC LOGINFO([TravelReportDB]);

-- 查看测试表TestInsertLog
-- select count(1) from TestInsertLog;

---- 创建测试表TestInsertLog
--CREATE TABLE TestInsertLog (
--    ID INT IDENTITY(1,1) PRIMARY KEY,
--    DataValue NVARCHAR(100)
--);

-- 批量插入数据到测试表TestInsertLog
--INSERT INTO TestInsertLog (DataValue)
--SELECT TOP 100000 -- 调整为你需要的行数
--    NEWID()
--FROM sys.objects a
--CROSS JOIN sys.objects b;

-- 删除测试表TestInsertLog
-- drop table TestInsertLog;
------------------------------
-------------------------------------

-- DBCC LOGINFO([OperationLogsDB]);


---- 获取所有数据库名称
-- 方法1：使用sys.databases视图（推荐）
SELECT name AS DatabaseName 
FROM sys.databases 
WHERE database_id > 4  -- 排除系统数据库
ORDER BY name;

-- 方法2：使用sp_databases存储过程
EXEC sp_databases;

```



## 10. ldf日志文件收缩

[参考网址](https://www.cnblogs.com/gallen-n/p/6555283.html)

环境：sqlserver2016 alwayson集群


```sql
-- 0. 进入数据库
use [TravelReportDB]

-- 1. 查看当前打开的事务
DBCC OPENTRAN;

-- 2. 备份事务日志
BACKUP LOG [TravelReportDB] TO DISK = 'E:\test\TravelReportDB_2024111902.trn';

-- 3. 执行检查点
CHECKPOINT;

-- 4. 查看日志文件状态
DBCC LOGINFO([TravelReportDB]);

-- 5. 收缩日志文件
DBCC SHRINKFILE ([TravelReportDB_log], 1);
#DBCC SHRINKFILE ([TravelReportDB], 1);			# 此命令为收缩mdf文件，
# 数据完整性：DBCC SHRINKFILE 不会删除或破坏已有数据，但可能因页移动导致索引碎片化，从而间接影响查询性能
# 空间释放限制：LDF/MDF文件无法收缩到小于存储当前数据所需的最小空间。例如，若 MDF 文件有 10GB 数据，即使指定更小的 target_size，实际收缩后仍会保留 10GB 空间


-- 6. 重复备份和收缩（如果需要）
BACKUP LOG [TravelReportDB] TO DISK = 'E:\test\TravelReportDB_2024111902.trn';
DBCC SHRINKFILE ([TravelReportDB_log], 1);


-- 查看日志head-log
-- DBCC LOGINFO([TravelReportDB]);

-- 查看测试表TestInsertLog
-- select count(1) from TestInsertLog;

---- 创建测试表TestInsertLog
--CREATE TABLE TestInsertLog (
--    ID INT IDENTITY(1,1) PRIMARY KEY,
--    DataValue NVARCHAR(100)
--);

-- 批量插入数据到测试表TestInsertLog
--INSERT INTO TestInsertLog (DataValue)
--SELECT TOP 100000 -- 调整为你需要的行数
--    NEWID()
--FROM sys.objects a
--CROSS JOIN sys.objects b;

-- 删除测试表TestInsertLog
-- drop table TestInsertLog;
```
```
# 日志文件状态，status状态为2表示正在使用是活动的VLF，status状态为0表示未使用是不活动的VLF
RecoveryUnitId	FileId	FileSize	StartOffset	FSeqNo	Status	Parity	CreateLSN
0	2	253952	8192	20411	2	64	0
0	2	253952	262144	20412	2	64	0
0	2	5242880	516096	20413	2	64	19186000000042700020
0	2	5242880	5758976	20414	2	64	19186000000042700020
0	2	5242880	11001856	20415	2	64	19186000000042700020
0	2	5251072	16244736	20416	2	128	19186000000042700020
0	2	5242880	21495808	20409	0	64	19195000000973400005
0	2	5242880	26738688	20410	2	64	19195000000973400005
0	2	5242880	31981568	20417	2	64	20416000000183200001
0	2	5242880	37224448	20418	2	64	20416000000183200001
0	2	5242880	42467328	20419	2	64	20416000000183200001
0	2	5242880	47710208	20420	2	64	20416000000183200001
0	2	5242880	52953088	20421	2	64	20418000000781600349
0	2	5242880	58195968	20422	2	64	20418000000781600349
0	2	5242880	63438848	20423	2	64	20418000000781600349
0	2	5242880	68681728	20424	2	64	20418000000781600349
0	2	5242880	73924608	20425	2	64	20421000000378400142
0	2	5242880	79167488	20426	2	64	20421000000378400142
0	2	5242880	84410368	20427	2	64	20421000000378400142
0	2	5242880	89653248	20428	2	64	20421000000378400142
0	2	5242880	94896128	20429	2	64	20423000000985600235
0	2	5242880	100139008	20430	2	64	20423000000985600235
0	2	5242880	105381888	20431	2	64	20423000000985600235
0	2	5242880	110624768	20432	2	64	20423000000985600235
0	2	5242880	115867648	20433	2	64	20426000000577600163
0	2	5242880	121110528	20434	2	64	20426000000577600163
0	2	5242880	126353408	20435	2	64	20426000000577600163
0	2	5242880	131596288	20436	2	64	20426000000577600163
0	2	5242880	136839168	20437	2	64	20429000000162400454
0	2	5242880	142082048	20438	2	64	20429000000162400454
0	2	5242880	147324928	20439	2	64	20429000000162400454
0	2	5242880	152567808	20440	2	64	20429000000162400454
0	2	5242880	157810688	20441	2	64	20431000000757600338
0	2	5242880	163053568	20442	2	64	20431000000757600338
0	2	5242880	168296448	20443	2	64	20431000000757600338
0	2	5242880	173539328	20444	2	64	20431000000757600338
0	2	20971520	178782208	20445	2	64	20441000000492000349
0	2	20971520	199753728	20446	2	64	20444000000097600205
0	2	20971520	220725248	20447	2	64	20445000001740800134
0	2	20971520	241696768	20448	2	64	20446000000301600346
0	2	20971520	262668288	20449	2	64	20446000002959200346
0	2	20971520	283639808	20450	2	64	20449000000625600207
0	2	20971520	304611328	20451	2	64	20449000003275200349
0	2	20971520	325582848	20452	2	64	20450000001853600001
0	2	20971520	346554368	0	0	0	20451000000409600346
0	2	20971520	367525888	0	0	0	20451000003071200346
```





## 11. 服务器角色

**`sysadmin`权限的核心定义与作用**

1. 权限范围
   - `sysadmin`是SQL Server的固定服务器角色，其成员拥有**所有权限**，包括但不限于：

- 创建/删除数据库、用户、角色
- 修改服务器配置（如内存分配、网络设置）、重启或关闭实例
- 管理审计日志、安全策略、操作系统文件（通过`xp_cmdshell`执行命令）
- 覆盖其他用户的权限，甚至移除其他`sysadmin`成员
  - 与`sa`账户的关系：`sa`默认属于`sysadmin`且不可移除。

2. 与其他角色的对比

- **Serveradmin**：仅管理服务器级配置（如内存、关闭实例），无法控制数据库或用户。
- **Securityadmin**：管理登录名和密码，但权限范围远小于`sysadmin`。
- **Public角色**：所有登录默认加入，但初始无权限。



```sql
---- 对登录用户进行添加和移除服务器角色
-- 此方法兼容SQL Server 2012及以上版本 
ALTER SERVER ROLE sysadmin ADD MEMBER test;
ALTER SERVER ROLE sysadmin drop MEMBER test;

-- 适用于所有版本，但未来可能被弃用
EXEC sp_addsrvrolemember 'test', 'sysadmin';
EXEC sp_dropsrvrolemember 'test', 'sysadmin';

-- 查看是否属于sysadm角色 
SELECT IS_SRVROLEMEMBER('sysadmin', 'test') AS IsSysadmin;


-- 查看所有登录用户及对应的类型
USE master;
GO
SELECT name, type_desc
FROM sys.server_principals
WHERE type_desc IN ('SQL_LOGIN', 'WINDOWS_LOGIN', 'WINDOWS_GROUP', 'CERTIFICATE', 'ASYMMETRIC_KEY', 'EXTERNAL_LOGIN');

-- 查看服务器所有角色
SELECT name, type_desc FROM sys.server_principals WHERE type = 'R';

-- 查看所有登录用户对应的服务器角色
USE master;
SELECT SrvRole = g.name, MemberName = u.name, MemberSID = u.sid 
FROM sys.server_principals u, sys.server_principals g, sys.server_role_members m 
WHERE g.principal_id = m.role_principal_id AND u.principal_id = m.member_principal_id 
ORDER BY 1, 2;


-- 查看服务器角色成员
USE master;
GO
SELECT SRM.role_principal_id, SP.name AS Role_Name,
       SRM.member_principal_id, SP2.name AS Member_Name
FROM sys.server_role_members AS SRM
JOIN sys.server_principals AS SP
ON SRM.role_principal_id = SP.principal_id
JOIN sys.server_principals AS SP2
ON SRM.member_principal_id = SP2.principal_id
ORDER BY SP.name, SP2.name;


-- 查看服务器角色的所有权限
SELECT *
FROM sys.fn_builtin_permissions('SERVER')
ORDER BY permission_name;

-- 查看所有服务器角色
SELECT name, type_desc 
FROM sys.server_principals 
WHERE type_desc = 'SERVER_ROLE' 
AND is_fixed_role = 1;  -- 仅显示固定角色

-- 查看服务器角色成员
SELECT 
    r.name AS RoleName, 
    m.name AS MemberName 
FROM sys.server_role_members rm
JOIN sys.server_principals r ON rm.role_principal_id = r.principal_id
JOIN sys.server_principals m ON rm.member_principal_id = m.principal_id;


-- 使用系统存储过程查看服务器角色成员
EXEC sp_helpsrvrolemember;

-- 查看数据库系统自带角色
use db;
exec sp_helprole;

-- 使用系统存储过程查看服务器角色权限
EXEC sp_srvrolepermission;

-- 查看服务器角色成员
EXEC sp_helpsrvrolemember 'sysadmin';

-- 查看数据库角色成员
EXEC sp_helprolemember 'hs_ops';  -- 指定角色名
SELECT 
    roles.name AS RoleName,
    members.name AS MemberName,
    members.type_desc AS MemberType
FROM sys.database_role_members rm
JOIN sys.database_principals roles ON rm.role_principal_id = roles.principal_id
JOIN sys.database_principals members ON rm.member_principal_id = members.principal_id
WHERE roles.name = 'db_owner';


-- 查看所有数据库角色及其权限描述
use topway20250408;
SELECT 
    r.name AS RoleName, 
    p.permission_name AS Permission,
    o.name AS ObjectName,
    p.state_desc AS PermissionState
FROM sys.database_principals r
JOIN sys.database_permissions p ON r.principal_id = p.grantee_principal_id
LEFT JOIN sys.objects o ON p.major_id = o.object_id
WHERE r.type = 'R' and r.name='hs_ops' and p.permission_name = 'EXECUTE'
order by o.name
```





## 12. 批量添加用户角色权限

### 1. 添加登录用户并对所有数据库赋予指定角色权限

```sql
-- 创建登录用户，并赋予所有数据库指定角色权限，除开系统数据库
-- 虽然执行多次报错，但是添加角色是生效的
DECLARE @DatabaseName NVARCHAR(128);
DECLARE @USER NVARCHAR(100);
DECLARE @ROLE NVARCHAR(100);
DECLARE @ROLE02 NVARCHAR(100);
DECLARE @ROLE03 NVARCHAR(100);
DECLARE @CREATE_USER_SQL NVARCHAR(MAX);

SET @USER='markli'
-- SET @USER='CHINAMI-1PLNOIJ\administrator'
SET @ROLE='db_datareader'
SET @ROLE02='db_datawriter'
SET @ROLE03='db_owner'
-- windows用户
--SET @CREATE_USER_SQL = N'use master; create login [' + @USER + '] FROM WINDOWS;'
SET @CREATE_USER_SQL = N'use master; create login ' + @USER + ' with password=''123456'',check_policy=off,check_expiration=off,DEFAULT_DATABASE=master;'
EXEC sp_executesql @CREATE_USER_SQL;
SET @CREATE_USER_SQL = N''

DECLARE db_cursor CURSOR FOR 
SELECT name FROM sys.databases WHERE database_id > 4;

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DatabaseName;

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @CREATE_USER_SQL = N'
    USE ' + QUOTENAME(@DatabaseName) + ';
    create user ['+ @USER +'] for login ['+ @USER +'] with default_schema = dbo;
	exec sp_addrolemember ' + @ROLE + ',['+ @USER +'];
	';

	SET @CREATE_USER_SQL = @CREATE_USER_SQL + N'
	exec sp_addrolemember ' + @ROLE02 + ',['+ @USER +'];
	exec sp_addrolemember ' + @ROLE03 + ',['+ @USER +'];
	';

	-- select @CREATE_USER_SQL
	EXEC sp_executesql @CREATE_USER_SQL;

    FETCH NEXT FROM db_cursor INTO @DatabaseName;
END;

CLOSE db_cursor;
DEALLOCATE db_cursor;
```

**优化版**

```sql
-- 创建登录用户，并赋予所有数据库指定角色权限，除开系统数据库
-- 虽然执行多次报错，但是添加角色是生效的
DECLARE @DatabaseName NVARCHAR(128);
DECLARE @USER NVARCHAR(100);
DECLARE @ROLE NVARCHAR(100);
DECLARE @ROLE02 NVARCHAR(100);
DECLARE @ROLE03 NVARCHAR(100);
DECLARE @CREATE_USER_SQL NVARCHAR(MAX);

SET @USER='prod-dbuser-ddl'
-- SET @USER='CHINAMI-1PLNOIJ\administrator'
SET @ROLE='db_ddladmin'
--SET @ROLE02='db_datawriter'
--SET @ROLE03='db_owner'
-- windows用户
--SET @CREATE_USER_SQL = N'use master; create login [' + @USER + '] FROM WINDOWS;'
SET @CREATE_USER_SQL = N'use master; create login [' + @USER + '] with password=''123456'',check_policy=off,check_expiration=off,DEFAULT_DATABASE=master;'


DECLARE db_cursor CURSOR FOR 
SELECT name FROM sys.databases WHERE database_id > 4;

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DatabaseName;

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @CREATE_USER_SQL += N'
    USE ' + QUOTENAME(@DatabaseName) + ';
    create user ['+ @USER +'] for login ['+ @USER +'];
	exec sp_addrolemember ' + @ROLE + ',['+ @USER +'];
	';

	--SET @CREATE_USER_SQL = @CREATE_USER_SQL + N'
	--exec sp_addrolemember ' + @ROLE02 + ',['+ @USER +'];
	--exec sp_addrolemember ' + @ROLE03 + ',['+ @USER +'];
	--';

    FETCH NEXT FROM db_cursor INTO @DatabaseName;
END;

CLOSE db_cursor;
DEALLOCATE db_cursor;

select @CREATE_USER_SQL
-- EXEC sp_executesql @CREATE_USER_SQL;
```





### 2. 查看指定用户所有数据库的权限

```sql
-- 查看所有数据库指定用户的角色权限，除开系统数据库
DECLARE @DatabaseName NVARCHAR(128);
DECLARE @SQL NVARCHAR(MAX);
DECLARE @USER NVARCHAR(100);

SET @USER='markli'
-- SET @USER='CHINAMI-1PLNOIJ\administrator'
DECLARE db_cursor CURSOR FOR 
SELECT name FROM sys.databases WHERE database_id > 4;

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DatabaseName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = N'
    USE ' + QUOTENAME(@DatabaseName) + ';
    SELECT 
        DB_NAME() COLLATE Chinese_PRC_CI_AS AS DatabaseName,
        USER_NAME(p.grantee_principal_id) COLLATE Chinese_PRC_CI_AS AS UserName,
        p.permission_name COLLATE Chinese_PRC_CI_AS AS Permission,
        p.state_desc COLLATE Chinese_PRC_CI_AS AS PermissionState,
        CASE 
            WHEN p.class = 0 THEN ''Database''
            WHEN p.class = 3 THEN ''Schema''
            WHEN p.class = 4 THEN ''Database Principal''
            ELSE ''Other''
        END AS SecurableType
    FROM sys.database_permissions p
    WHERE USER_NAME(p.grantee_principal_id) = '''+ @USER + '''
    UNION ALL
    SELECT 
        DB_NAME() COLLATE Chinese_PRC_CI_AS AS DatabaseName,
        '''+ @USER + ''' COLLATE Chinese_PRC_CI_AS AS UserName,
        role.name COLLATE Chinese_PRC_CI_AS AS Permission,
        ''GRANT'' COLLATE Chinese_PRC_CI_AS AS PermissionState,
        ''Role Membership'' COLLATE Chinese_PRC_CI_AS AS SecurableType
    FROM sys.database_role_members rm
    JOIN sys.database_principals role ON rm.role_principal_id = role.principal_id
    JOIN sys.database_principals userp ON rm.member_principal_id = userp.principal_id
    WHERE userp.name = '''+ @USER + ''';';

	--select @SQL
    EXEC sp_executesql @SQL;
    FETCH NEXT FROM db_cursor INTO @DatabaseName;
END;

CLOSE db_cursor;
DEALLOCATE db_cursor;
```

**response**

```
DatabaseName	UserName	Permission	PermissionState	SecurableType
test	markli	CONNECT	GRANT	Database
test	markli	db_owner	GRANT	Role Membership
test	markli	db_datareader	GRANT	Role Membership
test	markli	db_datawriter	GRANT	Role Membership

topway20250408	markli	CONNECT	GRANT	Database
topway20250408	markli	db_owner	GRANT	Role Membership
topway20250408	markli	db_datareader	GRANT	Role Membership
topway20250408	markli	db_datawriter	GRANT	Role Membership
```

**优化版**

```sql
-- 查看所有数据库指定用户的角色权限，除开系统数据库
DECLARE @DatabaseName NVARCHAR(128);
DECLARE @SQL NVARCHAR(MAX)=N'';
DECLARE @USER NVARCHAR(100);

SET @USER='HS\prod-dbuser-ddl'
-- SET @USER='CHINAMI-1PLNOIJ\administrator'
DECLARE db_cursor CURSOR FOR 
SELECT name FROM sys.databases WHERE database_id > 4;

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DatabaseName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL += N'
    USE ' + QUOTENAME(@DatabaseName) + ';
    SELECT 
        DB_NAME() COLLATE Chinese_PRC_CI_AS AS DatabaseName,
        USER_NAME(p.grantee_principal_id) COLLATE Chinese_PRC_CI_AS AS UserName,
        p.permission_name COLLATE Chinese_PRC_CI_AS AS Permission,
        p.state_desc COLLATE Chinese_PRC_CI_AS AS PermissionState,
        CASE 
            WHEN p.class = 0 THEN ''Database''
            WHEN p.class = 3 THEN ''Schema''
            WHEN p.class = 4 THEN ''Database Principal''
            ELSE ''Other''
        END AS SecurableType
    FROM sys.database_permissions p
    WHERE USER_NAME(p.grantee_principal_id) = '''+ @USER + '''
    UNION ALL
    SELECT 
        DB_NAME() COLLATE Chinese_PRC_CI_AS AS DatabaseName,
        '''+ @USER + ''' COLLATE Chinese_PRC_CI_AS AS UserName,
        role.name COLLATE Chinese_PRC_CI_AS AS Permission,
        ''GRANT'' COLLATE Chinese_PRC_CI_AS AS PermissionState,
        ''Role Membership'' COLLATE Chinese_PRC_CI_AS AS SecurableType
    FROM sys.database_role_members rm
    JOIN sys.database_principals role ON rm.role_principal_id = role.principal_id
    JOIN sys.database_principals userp ON rm.member_principal_id = userp.principal_id
    WHERE userp.name = '''+ @USER + ''';
	';


    FETCH NEXT FROM db_cursor INTO @DatabaseName;
END;

CLOSE db_cursor;
DEALLOCATE db_cursor;

select @SQL
--EXEC sp_executesql @SQL;
```







### 3. 删除登录用户和所有数据库的用户

```sql
-- 删除指定登录用户及数据库用户，并解除数据库用户授权，除开系统数据库
DECLARE @DatabaseName NVARCHAR(128);
DECLARE @USER NVARCHAR(100);
DECLARE @DROP_USER_SQL NVARCHAR(MAX);

SET @USER='prod-dbuser-ddl'
-- SET @USER='CHINAMI-1PLNOIJ\administrator'
SET @DROP_USER_SQL = N'use master; drop login [' + @USER + '];' 

DECLARE db_cursor CURSOR FOR 
SELECT name FROM sys.databases WHERE database_id > 4;

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DatabaseName;

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @DROP_USER_SQL += N'
    USE ' + QUOTENAME(@DatabaseName) + ';
    drop user ['+ @USER +'];
	';

    FETCH NEXT FROM db_cursor INTO @DatabaseName;
END;

CLOSE db_cursor;
DEALLOCATE db_cursor;

select @DROP_USER_SQL;
--EXEC sp_executesql @DROP_USER_SQL;
```

**再次查看指定用户所有数据库的权限**

```
DatabaseName	UserName	Permission	PermissionState	SecurableType

```

> 已经为空，权限无



**优化版**

```sql
-- 删除指定登录用户及数据库用户，并解除数据库用户授权，除开系统数据库
DECLARE @DatabaseName NVARCHAR(128);
DECLARE @USER NVARCHAR(100);
DECLARE @DROP_USER_SQL NVARCHAR(MAX);

SET @USER='prod-dbuser-ddl'
-- SET @USER='CHINAMI-1PLNOIJ\administrator'
SET @DROP_USER_SQL = N'use master; drop login [' + @USER + '];' 

DECLARE db_cursor CURSOR FOR 
SELECT name FROM sys.databases WHERE database_id > 4;

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DatabaseName;

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @DROP_USER_SQL += N'
    USE ' + QUOTENAME(@DatabaseName) + ';
    drop user ['+ @USER +'];
	';

    FETCH NEXT FROM db_cursor INTO @DatabaseName;
END;

CLOSE db_cursor;
DEALLOCATE db_cursor;

select @DROP_USER_SQL;
--EXEC sp_executesql @DROP_USER_SQL;
```







### 4. 添加角色并授予角色权限-当前对象

```sql
-- 创建角色并授予角色权限
DECLARE @ROLE NVARCHAR(MAX)
DECLARE @ROLE_sql NVARCHAR(MAX)
DECLARE @sql NVARCHAR(MAX) = '';
DECLARE @DatabaseName NVARCHAR(128);

set @ROLE='role_ops'

DECLARE db_cursor CURSOR FOR 
SELECT name FROM sys.databases WHERE database_id > 4;

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DatabaseName;

WHILE @@FETCH_STATUS = 0
BEGIN
	---- 创建角色
	set @ROLE_sql=N'
    USE ' + QUOTENAME(@DatabaseName) + ';
	CREATE ROLE ' + @ROLE + ';'

	select @ROLE_sql;
	EXEC sp_executesql @ROLE_sql;

	
	----- 授予表
	-- 赋予当前数据库所有表的SELECT, INSERT, UPDATE, DELETE权限给角色@ROLE
	SELECT @sql += 'GRANT SELECT, INSERT, UPDATE, DELETE ON ' 
		+ QUOTENAME(SCHEMA_NAME(schema_id)) + '.' 
		+ QUOTENAME(name) + ' TO ' + @ROLE + ';'
	FROM sys.tables;

	select @sql;
	EXEC sp_executesql @sql;

	---- 授予执行计划
	set @sql=N''
	SELECT @sql = N'GRANT SHOWPLAN TO ' + @ROLE + ';'

	select @sql;
	EXEC sp_executesql @sql;

	
	---- 授予存储过程
	set @sql=N''
	-- 授予执行权限
	SELECT @sql = N'GRANT EXECUTE ON DATABASE::' + @DatabaseName + ' TO ' + @ROLE + ';'

	select @sql;
	EXEC sp_executesql @sql;

	-- 授予ALTER和VIEW DEFINITION权限
	DECLARE @sql_proc NVARCHAR(MAX) = '';
	SELECT @sql_proc += 'GRANT VIEW DEFINITION,ALTER ON ' 
	    + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' 
	    + QUOTENAME(name) + ' TO ' + @ROLE + ';'
	FROM sys.procedures;
	
	select @sql_proc;
	EXEC sp_executesql @sql_proc;


	---- 授予函数
	-- 表值函数
	DECLARE @sql_func NVARCHAR(MAX) = '';
	SELECT @sql_func += 'GRANT ALTER,VIEW DEFINITION ON ' 
	    + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' 
	    + QUOTENAME(name) + ' TO ' + @ROLE + ';'
	FROM sys.objects 
	WHERE type IN ('FN', 'IF', 'TF');
	
	select @sql_func;
	EXEC sp_executesql @sql_func;


	---- 授予视图
	DECLARE @sql_view NVARCHAR(MAX) = '';
	SELECT @sql_view += 'GRANT SELECT, ALTER, VIEW DEFINITION ON ' 
	    + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' 
	    + QUOTENAME(name) + ' TO ' + @ROLE + ';'
	FROM sys.views;

	select @sql_view;
	EXEC sp_executesql @sql_view;


    FETCH NEXT FROM db_cursor INTO @DatabaseName;
END;

CLOSE db_cursor;
DEALLOCATE db_cursor;
```



### 5. 添加角色并授予角色权限-所有对象

```sql
-- 创建角色并授予角色权限
DECLARE @ROLE NVARCHAR(MAX)='role_ops_all';
DECLARE @sql NVARCHAR(MAX) = '';
DECLARE @DatabaseName NVARCHAR(128);

DECLARE db_cursor CURSOR FOR 
SELECT name FROM sys.databases WHERE database_id > 4;

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DatabaseName;

WHILE @@FETCH_STATUS = 0
BEGIN
	---- 创建角色
	SET @sql=N'
    USE ' + QUOTENAME(@DatabaseName) + ';
	CREATE ROLE ' + @ROLE + ';'
	SELECT @sql;
	EXEC sp_executesql @sql;
	
	----- 授予数据库下所有表和视图
	-- 赋予当前数据库所有表的SELECT, INSERT, UPDATE, DELETE权限给角色@ROLE
	SELECT @sql = 'GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO ' + @ROLE + ';'
	SELECT @sql;
	EXEC sp_executesql @sql;

	---- 授予数据库下所有执行计划
	SELECT @sql = N'GRANT SHOWPLAN TO ' + @ROLE + ';'
	SELECT @sql;
	EXEC sp_executesql @sql;

	---- 授予数据库下所有存储过程和函数
	SELECT @sql = 'GRANT EXECUTE,VIEW DEFINITION,ALTER ON SCHEMA::dbo TO ' + @ROLE + ';'
	SELECT @sql;
	EXEC sp_executesql @sql;

    FETCH NEXT FROM db_cursor INTO @DatabaseName;
END;

CLOSE db_cursor;
DEALLOCATE db_cursor;
```



### 6. 查看所有数据库角色及其权限描述

`仅限自定义角色`，因为固定角色（例如db_owner）的权限是预定义的，由系统隐式授予，而非通过显式的`GRANT`语句分配。

```sql
-- 查看所有数据库角色及其权限描述，可添加特定条件进行筛选
use topway20250408;
SELECT 
    r.name AS RoleName, 
    p.permission_name AS Permission,
    o.name AS ObjectName,
    p.state_desc AS PermissionState
FROM sys.database_principals r
JOIN sys.database_permissions p ON r.principal_id = p.grantee_principal_id
LEFT JOIN sys.objects o ON p.major_id = o.object_id
WHERE r.type = 'R' and r.name='role_ops' --and p.permission_name = 'EXECUTE'
order by o.name
```



### 7. 查看所有数据库指定角色中的成员，除开系统数据库

```sql
-- 查看所有数据库指定角色中的成员，除开系统数据库
DECLARE @DatabaseName NVARCHAR(128);
DECLARE @ROLE_SQL NVARCHAR(MAX);
DECLARE @ROLE NVARCHAR(100) = 'role_ops';

DECLARE db_cursor CURSOR FOR 
SELECT name FROM sys.databases WHERE database_id > 4;

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DatabaseName;

WHILE @@FETCH_STATUS = 0
BEGIN
	-- 创建临时表存储角色成员信息
	DROP TABLE IF EXISTS #RoleMembers;
	CREATE TABLE #RoleMembers (
	    RoleName NVARCHAR(128),
	    MemberName NVARCHAR(128),
	    MemberSID VARBINARY(85),
	    DatabaseName NVARCHAR(128)
	);

	SET @ROLE_SQL = N'
	USE ' + QUOTENAME(@DatabaseName) + ';
	INSERT INTO #RoleMembers (RoleName, MemberName, MemberSID) EXEC sp_helprolemember ' + @ROLE + ';
	UPDATE #RoleMembers SET DatabaseName = ''' + @DatabaseName + ''' where DatabaseName is null;
	SELECT DatabaseName, RoleName, MemberName, MemberSID FROM #RoleMembers;
	';

	--select @ROLE_SQL

	EXEC sp_executesql @ROLE_SQL;
    FETCH NEXT FROM db_cursor INTO @DatabaseName;
END;

CLOSE db_cursor;
DEALLOCATE db_cursor;
```



### 8. 查看所有数据库指定角色中的成员，除开系统数据库

```sql
-- 删除所有数据库指定角色，除开系统数据库
DECLARE @DatabaseName NVARCHAR(128);
DECLARE @ROLE NVARCHAR(100);
DECLARE @DROP_ROLE_SQL NVARCHAR(MAX);

SET @ROLE='role_ops'

DECLARE db_cursor CURSOR FOR 
SELECT name FROM sys.databases WHERE database_id > 4;

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DatabaseName;

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @DROP_ROLE_SQL = N'
    USE ' + QUOTENAME(@DatabaseName) + ';
    drop role ['+ @ROLE +'];
	';
	EXEC sp_executesql @DROP_ROLE_SQL;

    FETCH NEXT FROM db_cursor INTO @DatabaseName;
END;

CLOSE db_cursor;
DEALLOCATE db_cursor;
```







## 13. 孤立用户处理

孤立用户是指数据库中存在用户名，但其对应的 SQL Server 登录名（在 `master` 数据库的 `syslogins` 表中）已丢失或 SID（安全标识符）不匹配的情况

**典型场景**：

1. 跨服务器还原数据库时，目标服务器未创建与原服务器相同的登录名。
2. 重装 SQL Server 或仅还原用户数据库后，登录名未同步重建。

```sql
-- 查看当前数据库孤立的用户
---- 是 SQL Server 中修复孤立用户的关键工具，适用于需手动关联用户与登录名的场景。
-- sp_change_users_login ACTION有3个操作模式：REPORT、AUTO_FIX、UPDATE_ONE
-- REPORT：列出当前数据库所有孤立用户及其 SID(不支持windows登录用户)，适用场景：诊断问题，权限要求：db_owner
-- AUTO_FIX：自动创建同名登录名并关联用户（可选密码），适用场景：快速修复，权限要求：sysadmin
-- UPDATE_ONE：手动关联用户到现有登录名，适用场景：精确控制映射关系，权限要求：db_owner
use [topway20250408];
go
sp_change_users_login 'REPORT'
GO
-- superpm	0x9C2C1E89F2D4A5418EEC2839C3CD9A63
-- YWB	0xF29D2611188B1945B80628BB83D65B81
-- dbbackup	0xE9E835A237473C4CB0F77021942E0FF9



-- 创建新登录用户
-- 创建非windows登录用户时不会自动关联数据库用户，所以需要关联孤立数据库用户
-- 创建windows登录用户则可以自动关联数据库用户，无需再关联
use master; 
create login test with password='pass@123',check_policy=off,check_expiration=off;


-- 方式1：
use [topway20250408];
go
-- 关联用户
sp_change_users_login 'update_one', 'YWB', 'cachedproject'
GO

use [topway20250408];
go
sp_change_users_login 'REPORT'
GO
-- superpm	0x9C2C1E89F2D4A5418EEC2839C3CD9A63
-- dbbackup	0xE9E835A237473C4CB0F77021942E0FF9




---- 方式2：对孤立用户进行绑定
-- 在新版本中使用 ALTER USER 替代，支持windows登录用户
use [topway20250408];
go
-- 执行第1次成功
ALTER USER superpm WITH LOGIN = test;
-- 执行第2次报错，无法将用户重新映射到登录名 'test'，因为该登录名已映射到数据库中的用户，违反了单数据库内一对一映射规则
-- 需要先解绑test登录用户，或创建新的登录用户绑定到此数据库用户
ALTER USER dbbackup WITH LOGIN = test;

-- 查看当前数据库用户映射关系
SELECT dp.name AS [User], sp.name AS [Login]
FROM sys.database_principals dp
LEFT JOIN sys.server_principals sp ON dp.sid = sp.sid
WHERE dp.name = 'superpm';
-- superpm	test


---- 解绑superpm数据库用户，释放test登录用户
-- 备份用户权限（可选）
EXEC sp_helpuser 'superpm';
-- 删除用户（需先转移对象所有权）
DROP USER superpm;
-- 创建不关联登录名的用户（仅限包含数据库）
CREATE USER superpm WITHOUT LOGIN;
-- 禁用登录名（阻止服务器级连接）
ALTER LOGIN test DISABLE;
-- 或撤销数据库访问权限，DENY CONNECT仅阻止用户访问当前数据库，不影响其他数据库
USE [topway20250408];
DENY CONNECT TO [superpm];

-- 执行第3次成功
ALTER USER dbbackup WITH LOGIN = test;

-- 再次查看当前数据库用户映射关系
SELECT dp.name AS [User], sp.name AS [Login]
FROM sys.database_principals dp
LEFT JOIN sys.server_principals sp ON dp.sid = sp.sid
WHERE dp.name = 'dbbackup';
-- dbbackup	test
```

