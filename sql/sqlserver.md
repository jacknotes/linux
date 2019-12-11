#sql server
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

#交叉应用(CROSS APPLY())和外部应用(OUTER APPLY())
###CROSS APPLY()
SELECT T1.StudentNo, T1.Name, T2.ExamScore, T2.ExamDate FROM Student AS T1
CROSS APPLY(
    SELECT TOP 2 * FROM Score AS T
    WHERE T1.StudentNo = T.StudentNo
    ORDER BY T.ExamDate DESC
) AS T2
注：CROSS APPLY()工作原理是把左表当做目标表，把子集表当做源表，拿源表的每一行去跟目标表的行去比较(字段必须相对应连接),当源表和目标表匹配到时则保留，反则丢弃。子集表中ORDER BY比top优先级高。

###OUTER APPLY()
ELECT T1.StudentNo, T1.Name, T2.ExamScore, T2.ExamDate FROM Student AS T1
OUTER APPLY(
    SELECT TOP 2 * FROM Score AS T
    WHERE T1.StudentNo = T.StudentNo
    ORDER BY T.ExamDate DESC
) AS T2
注：OUTER APPLY()工作原理是把左表当做目标表，把子集表当做源表，拿源表的每一行去>跟目标表的行去比较(字段必须相对应连接),当源表和目标表匹配到时则保留，如果未匹配到，则目标表显示，源表显示为NULL。子集表中ORDER BY比top优先级高。(类似LEFT JOIN，与LEFT JOIN不同的是外部连接是拿子集表的多行跟左表的一行去比较)




</pre>
