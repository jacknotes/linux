#monboDB

<pre>
#MongoDb的基本数据结构
SQL术语/概念	MongoDB术语/概念	解释/说明
database	database	数据库
table	collection	数据库表/集合
row	document	数据记录行/文档
column	field	数据字段/域
index	index	索引
table joins		表连接,MongoDb不支持
primary key	primary key	主键,MongoDb自动将_id字段设置为主键
注：可以看到 MongoDb 与 SQL 的数据库概念都是一致的，而 MongoDb 中数据库表（Table）则称之为集合（Collection），行（Row）则称为文档（Document），列（Column）则称为字段（Field）。


MongoDb创建数据库
MongoDb 创建和切换数据库的语法格式为：use database_name
如果数据库不存在，则创建数据库，否则切换到指定数据库。

MongoDb创建表
MongoDb 中并没有直接创建表的命令，表的数据结构在你往表插入数据时确定。因此在 MongoDb 中，你创建完数据库之后就可以直接往表中插入数据，表名在插入数据时指定。

MongoDb插入数据
MongoDB 使用 insert() 或 save() 方法向集合中插入文档，语法如下：
db.collection.insert(document)
> db.user.insert({
...     "name": "chenyurong",
...     "age": 25,
...     "addr": "ShenZhen"
... })
WriteResult({ "nInserted" : 1 })
db.user.find()
{ "_id" : ObjectId("59a2782f6eb4c099dbb718a1"), "name" : "chenyurong", "age" : 25, "addr" : "ShenZhen" }


查看所有数据库
> show dbs     
admin       0.000GB
chenyurong  0.000GB
local       0.000GB

> db.user.find().pretty()
{
	"_id" : ObjectId("59abb034dca9453471d67f13"),
	"name" : "chenyurong",
	"age" : 25,
	"addr" : "ShenZhen"
}

MongoDb查询数据
//清空当前数据库下user表的所有数据
> db.user.remove({})
WriteResult({ "nRemoved" : 2 })
//查看user表的所有数据
> db.user.find()
//批量插入数据
> db.user.insert([
... {
...     "name": "ChenYuRong",
...     "age": 25,
...     "addr": "ShenZhen"
... },
... {
...     "name": "LiQiLiang",
...     "age": 27,
...     "addr": "GuangZhou"
... }]
... )

MongoDB 查询数据的语法格式如下：
db.collection.find(query, projection)
query（可选）：使用查询操作符指定查询条件。该参数是一个JSON对象，key 一般为查询的列名，value 为查询匹配的值。
projection（可选）：使用投影操作符指定返回的键。如果省略该参数，那么查询时返回文档中所有键值。该参数是一个JSON对象，key 为需要显示的列名，value 为 1（显示） 或 0（不显示）。
下面的查询语句将user表中地址（addr）为ShenZhen，年龄（age）为25的数据筛选出来，并且在结果中不显示ID列：
db.user.find({"addr":"ShenZhen","age":25},{"_id":0}).pretty()
查询结果为：
{ "name" : "ChenYuRong", "age" : 25, "addr" : "ShenZhen" }

范围操作符
范围操作符指的是：大于、大于等于、等于、不等于、小于、小于等于操作符，在 MongoDb 中它们的表示以及使用如下面表格所示：
操作	格式	范例	RDBMS中的类似语句
等于	{:}	db.col.find({"by":"MongoDb入门教程"}).pretty()	where by = 'MongoDb入门教程'
小于	{:{$lt:}}	db.col.find({"likes":{$lt:50}}).pretty()	where likes < 50
小于或等于	{:{$lte:}}	db.col.find({"likes":{$lte:50}}).pretty()	where likes <= 50
大于	{:{$gt:}}	db.col.find({"likes":{$gt:50}}).pretty()	where likes > 50
大于或等于	{:{$gte:}}	db.col.find({"likes":{$gte:50}}).pretty()	where likes >= 50
不等于	{:{$ne:}}	db.col.find({"likes":{$ne:50}}).pretty()	where likes != 50
例如我要查询用户表中所有年龄大于等于25岁的用户，那么查询语句为：
db.user.find({"age": {$gte:25}},{"_id":0}).pretty()

AND操作符
MongoDB 的 find() 方法可以传入多个键（key），每个键（key）以逗号隔开。每个键（key）之间是与的逻辑关系。
例如我要查询用户表（user）中地址为ShenZhen且年龄大于等于25岁的用户，那么查询语句为：
db.user.find({"addr": "ShenZhen","age": {$gte:25}},{"_id":0}).pretty()
查询结果为：
{ "name" : "ChenYuRong", "age" : 25, "addr" : "ShenZhen" }
{ "name" : "XiaoHei", "age" : 28, "addr" : "ShenZhen" }

OR操作符
例如我要查询用户表（user）中地址为ShenZhen或者年龄大于等于30岁的用户，那么查询语句为：
db.user.find({$or:[{"addr":"ShenZhen"},{"age":{$gte:30}}]}).pretty()
db.user.find({$or:[{"addr":"ShenZhen"},{"age":{$gte:30}}]}).pretty()

AND操作符和OR操作符可以混合使用，例如要实现以下SQL查询：
select * from user
where name = "ChenYuRong" or (age <= 25 and addr == "JieYang")
那么该 MongoDb 查询语句应该这样写：
db.user.find({$or:[{"name":"ChenYuRong"}, {"age": {$lte:25}, "addr": "JieYang"}]}).pretty()

排序
在 MongoDB 中使用使用 sort() 方法对数据进行排序，sort() 方法可以通过参数指定排序的字段，并使用 1 和 -1 来指定排序的方式，其中 1 为升序排列，而-1是用于降序排列。
sort()方法基本语法如下所示：
db.collection.find().sort({KEY:1})
其中KEY表示要进行排序的字段。
例如我们将所有年龄小于30岁的用户查询出来并将其按照年龄升序排列：
db.user.find({"age":{$lt:30}}).sort({age:1}).pretty()

聚合
MongoDB中聚合的方法使用aggregate()，其基本的语法格式如下：
db.collection.aggregate(AGGREGATE_OPERATION)
其中AGGREGATE_OPERATION的格式为：
[
    {
        $group: {
            _id: {
                addr: '$addr'
            },
            totalCount: {
                $sum: 1
            }
        }
    }
]
$group是固定的，表示这里一个分组聚合操作。
_id表示需要根据哪一些列进行聚合，其实一个JSON对象，其key/value对分别表示结果列的别名以及需要聚合的的数据库列。
totalCount表示聚合列的列名。
$sum表示要进行的聚合操作，后面的1表示每次加1。
例如要根据地区统计用户人数，那么查询语句为：
db.user.aggregate([{$group:{_id:{userAddr:'$addr'},totalCount:{$sum:1}}}])
查询结果为：
{ "_id" : { "userAddr" : "FuJian" }, "totalCount" : 1 }
{ "_id" : { "userAddr" : "JieYang" }, "totalCount" : 1 }
{ "_id" : { "userAddr" : "BeiJing" }, "totalCount" : 1 }
{ "_id" : { "userAddr" : "GuangZhou" }, "totalCount" : 1 }
{ "_id" : { "userAddr" : "ShenZhen" }, "totalCount" : 2 }

MongoDb更新数据
update() 方法用于更新已存在的文档。语法格式如下：
db.collection.update(
   <query>,
   <update>,
   {
     upsert: <boolean>,
     multi: <boolean>,
     writeConcern: <document>
   }
)
query：对哪些数据进行更新操作。
update：对这些数据做什么操作。
upsert（可选）：如果不存在update的记录，是否将其作为记录插入。true为插入，默认是false，不插入。
multi（可选）：是否更新多条记录。MongoDb 默认是false，只更新找到的第一条记录。如果这个参数为true,就把按条件查出来多条记录全部更新。
writeConcern（可选）：表示抛出异常的级别。
例如我们更新user表名为chenyurong的记录，将其年龄更改为25岁。
db.user.update({'name':'chenyurong'},{$set:{'age':25}})
其中$set表示进行赋值操作。

MongoDb删除数据
MongoDB中聚合的方法使用remove()，其基本的语法格式如下：
db.collection.remove(
   <query>,
   {
     justOne: <boolean>,
     writeConcern: <document>
   }
)
query（可选）：删除的文档的条件。
justOne（可选）：如果设为 true 或 1，则只删除一个文档。
writeConcern（可选）：抛出异常的级别。
例如我们想删除名字（name）为LiQiLiang的用户，那么该删除语句为：
> db.user.remove({"name":"LiQiLiang"})
WriteResult({ "nRemoved" : 1 })
> db.user.find({"name":"LiQiLiang"}).pretty()
> 
如果你想删除所有数据，可以使用以下方式（类似常规 SQL 的 truncate 命令）：
>db.col.remove({})
>db.col.find()
>


常用的DDL命令
查看当前数据库：db
查看所有数据库：show dbs
查看当前数据库所有集合（表格）：show collections

MongoDb图形化工具
如果你是企业版的用户，可以尝试使用：企业版用户：MongoDb Compass。
如果你跟我一样是个人用户，而且也一样使用 JetBrain 编辑器，那么你可以试试 JetBrain 的一款插件：JetBrain Plugin：mongo4idea。
另外的一款 GUI 图形化工具可以作为备用工具使用：NoSQL for MongoDb（Windows使用）。
Navicat12.1可进行连接


#mangodb部署
[root@TestHotelES /data/mangodb]# docker run -d \
 --restart=always \
 --name mongodb \
 -v /data/mongodb/db:/data/db \
 -p 27017:27017 \
 -e MONGO_INITDB_ROOT_USERNAME=root \
 -e MONGO_INITDB_ROOT_PASSWORD=mongo@DB \
 mongo:4.2
[root@TestHotelES /data/mongodb]# docker exec -it mongodb /bin/sh
# mongo 127.0.0.1:27017/admin -u root -p mongo@DB   --登录
# mongo   或者
> use admin
switched to db admin
> db.auth('root','mongo@DB');
1
> db.createUser({user:'admin',pwd:'p@ssw0rd',roles:[{role:'userAdminAnyDatabase', db:'admin'}]});
> db.createUser({user:'jack',pwd:'p@ssw0rd',roles:[{role:'userAdminAnyDatabase', db:'admin'}]});
db.createUser({user:'jack',pwd:'p@ssw0rd',roles:[{role:'userAdminAnyDatabase', db:'jack'}]});
> db.auth('admin','p@ssw0rd');
1
--Example
> use homsom_db01
switched to db homsom_db01
> db.id.insert( { "id": 01, "name": "jack" } )
WriteResult({ "nInserted" : 1 })
> db.id.save( { "id": 02, "name": "candy" } )
WriteResult({ "nInserted" : 1 })
> db.id.find()
{ "_id" : ObjectId("60816ef820a7f48fbefe4bc7"), "id" : 1, "name" : "jack" }
{ "_id" : ObjectId("60816f0b20a7f48fbefe4bc8"), "id" : 2, "name" : "candy" }
> db.id.insert( [{ "id": 01, "name": "jack" },{"id": 02,"name": "candy"} ] ) 
BulkWriteResult({
	"writeErrors" : [ ],
	"writeConcernErrors" : [ ],
	"nInserted" : 2,
	"nUpserted" : 0,
	"nMatched" : 0,
	"nModified" : 0,
	"nRemoved" : 0,
	"upserted" : [ ]
})
> show collections;
id
> db.id.find()
{ "_id" : ObjectId("60816fc820a7f48fbefe4bc9"), "id" : 1, "name" : "jack" }
{ "_id" : ObjectId("60816fc820a7f48fbefe4bca"), "id" : 2, "name" : "candy" }
> db.id.find({'id': 1})
{ "_id" : ObjectId("60816fc820a7f48fbefe4bc9"), "id" : 1, "name" : "jack" }
> db.id.find({"id": {$lt:2}})
{ "_id" : ObjectId("60816fc820a7f48fbefe4bc9"), "id" : 1, "name" : "jack" }
> db.id.insert( { "id": 03, "name": "bob" } )
WriteResult({ "nInserted" : 1 })
> db.id.find();
{ "_id" : ObjectId("60816fc820a7f48fbefe4bc9"), "id" : 1, "name" : "jack" }
{ "_id" : ObjectId("60816fc820a7f48fbefe4bca"), "id" : 2, "name" : "candy" }
{ "_id" : ObjectId("6081710f20a7f48fbefe4bcb"), "id" : 3, "name" : "bob" }
--or
> db.id.find({$or: [{"id":1},{"id":2}]})
{ "_id" : ObjectId("60816fc820a7f48fbefe4bc9"), "id" : 1, "name" : "jack" }
{ "_id" : ObjectId("60816fc820a7f48fbefe4bca"), "id" : 2, "name" : "candy" }
--and
> db.id.find({"id":2,"name":"candy"})
{ "_id" : ObjectId("60816fc820a7f48fbefe4bca"), "id" : 2, "name" : "candy" }
--and、or
> db.id.insert( { "id": 03, "name": "tim" } )
WriteResult({ "nInserted" : 1 })
> db.id.find()
{ "_id" : ObjectId("60816fc820a7f48fbefe4bc9"), "id" : 1, "name" : "jack" }
{ "_id" : ObjectId("60816fc820a7f48fbefe4bca"), "id" : 2, "name" : "candy" }
{ "_id" : ObjectId("6081710f20a7f48fbefe4bcb"), "id" : 3, "name" : "bob" }
{ "_id" : ObjectId("6081720320a7f48fbefe4bcc"), "id" : 3, "name" : "tim" }
> db.id.find({$or: [{"id":1},{"id":3,"name":"bob"}]})
{ "_id" : ObjectId("60816fc820a7f48fbefe4bc9"), "id" : 1, "name" : "jack" }
{ "_id" : ObjectId("6081710f20a7f48fbefe4bcb"), "id" : 3, "name" : "bob" }
--sort排序
> db.id.find().sort({id:1})
{ "_id" : ObjectId("60816fc820a7f48fbefe4bc9"), "id" : 1, "name" : "jack" }
{ "_id" : ObjectId("60816fc820a7f48fbefe4bca"), "id" : 2, "name" : "candy" }
{ "_id" : ObjectId("6081710f20a7f48fbefe4bcb"), "id" : 3, "name" : "bob" }
{ "_id" : ObjectId("6081720320a7f48fbefe4bcc"), "id" : 3, "name" : "tim" }
> db.id.find().sort({id:-1})
{ "_id" : ObjectId("6081710f20a7f48fbefe4bcb"), "id" : 3, "name" : "bob" }
{ "_id" : ObjectId("6081720320a7f48fbefe4bcc"), "id" : 3, "name" : "tim" }
{ "_id" : ObjectId("60816fc820a7f48fbefe4bca"), "id" : 2, "name" : "candy" }
{ "_id" : ObjectId("60816fc820a7f48fbefe4bc9"), "id" : 1, "name" : "jack" }
--aggregate聚合操作
> db.id.aggregate([{$group:{_id:{idnum:'$id'},totalCount:{$sum:1}}}])
{ "_id" : { "idnum" : 1 }, "totalCount" : 1 }
{ "_id" : { "idnum" : 2 }, "totalCount" : 1 }
{ "_id" : { "idnum" : 3 }, "totalCount" : 2 }
--document删除
> db.id.find();
{ "_id" : ObjectId("60816fc820a7f48fbefe4bc9"), "id" : 1, "name" : "jack" }
{ "_id" : ObjectId("60816fc820a7f48fbefe4bca"), "id" : 2, "name" : "candy" }
{ "_id" : ObjectId("6081710f20a7f48fbefe4bcb"), "id" : 3, "name" : "bob" }
{ "_id" : ObjectId("6081720320a7f48fbefe4bcc"), "id" : 3, "name" : "tim" }
> db.id.remove({"id":1})
WriteResult({ "nRemoved" : 1 })
> db.id.find();
{ "_id" : ObjectId("60816fc820a7f48fbefe4bca"), "id" : 2, "name" : "candy" }
{ "_id" : ObjectId("6081710f20a7f48fbefe4bcb"), "id" : 3, "name" : "bob" }
{ "_id" : ObjectId("6081720320a7f48fbefe4bcc"), "id" : 3, "name" : "tim" }
--update
> db.id.update({"name":"tim"},{$set:{"id":4}})
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })
> db.id.find();
{ "_id" : ObjectId("60816fc820a7f48fbefe4bca"), "id" : 2, "name" : "candy" }
{ "_id" : ObjectId("6081710f20a7f48fbefe4bcb"), "id" : 3, "name" : "bob" }
{ "_id" : ObjectId("6081720320a7f48fbefe4bcc"), "id" : 4, "name" : "tim" }

查看当前数据库：db
查看所有数据库：show dbs
查看当前数据库所有集合（表格）：show collections




--mongoDB角色
数据库用户角色：read、readWrite；
数据库管理角色：dbAdmin、dbOwner、userAdmin;
集群管理角色：clusterAdmin、clusterManager、4. clusterMonitor、hostManage；
备份恢复角色：backup、restore；
所有数据库角色：readAnyDatabase、readWriteAnyDatabase、userAdminAnyDatabase、dbAdminAnyDatabase
超级用户角色：root
内部角色：__system
Read：允许用户读取指定数据库
readWrite：允许用户读写指定数据库
dbAdmin：允许用户在指定数据库中执行管理函数，如索引创建、删除，查看统计或访问system.profile
userAdmin：允许用户向system.users集合写入，可以在指定数据库里创建、删除和管理用户
clusterAdmin：只在admin数据库中可用，赋予用户所有分片和复制集相关函数的管理权限。
readAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的读权限
readWriteAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的读写权限
userAdminAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的userAdmin权限
dbAdminAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的dbAdmin权限。
root：只在admin数据库中可用。超级账号，超级权限

查看创建的用户
show users 或 db.system.users.find().pretty() 或 db.runCommand({usersInfo:"userName"})
修改密码
use admin
db.changeUserPassword("username", "xxx")
修改密码和用户信息
db.runCommand(
    {
        updateUser:"username",
        pwd:"xxx",
        customData:{title:"xxx"}
    }
)
删除数据库用户
use admin
db.dropUser('user001')


#创建admin超级管理员用户
指定用户的角色和数据库：
(注意此时添加的用户都只用于admin数据库，而非你存储业务数据的数据库)
(在cmd中敲多行代码时，直接敲回车换行，最后以分号首尾)
db.createUser(  
  { user: "admin",  
    customData：{description:"superuser"},
    pwd: "admin",  
    roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]  
  }  
)  
user字段，为新用户的名字；
pwd字段，用户的密码；
cusomData字段，为任意内容，例如可以为用户全名介绍；
roles字段，指定用户的角色，可以用一个空数组给新用户设定空角色。在roles字段,可以指定内置角色和用户定义的角色。
超级用户的role有两种，userAdmin或者userAdminAnyDatabase(比前一种多加了对所有数据库的访问,仅仅是访问而已)。
db是指定数据库的名字，admin是管理数据库。
不能用admin数据库中的用户登录其他数据库。注：只能查看当前数据库中的用户，哪怕当前数据库admin数据库，也只能查看admin数据库中创建的用户。

#创建一个不受访问限制的超级用户
(跳出三界之外，不在五行之中)
db.createUser(
    {
        user:"root",
        pwd:"pwd",
        roles:["root"]
    }
)

#创建一个业务数据库管理员用户
(只负责某一个或几个数据库的増查改删)
> db.createUser({
    user:"user001",
    pwd:"123456",
    customData:{
        name:'jim',
        email:'jim@qq.com',
        age:18,
    },
    roles:[
        {role:"readWrite",db:"db001"},
        {role:"readWrite",db:"db002"},
        'read'// 对其他数据库有只读权限，对db001、db002是读写权限
    ]
})
--查看用户
> show users;
{
	"_id" : "admin.jack",
	"userId" : UUID("d5892afb-86d6-4aee-aeb4-ed25674fda9b"),
	"user" : "jack",
	"db" : "admin",
	"roles" : [
		{
			"role" : "userAdminAnyDatabase",
			"db" : "admin"
		}
	],
	"mechanisms" : [
		"SCRAM-SHA-1",
		"SCRAM-SHA-256"
	]
}
{
	"_id" : "admin.root",
	"userId" : UUID("3f57644e-ad5f-40b4-a08a-1eb18e87af87"),
	"user" : "root",
	"db" : "admin",
	"roles" : [
		{
			"role" : "root",
			"db" : "admin"
		}
	],
	"mechanisms" : [
		"SCRAM-SHA-1",
		"SCRAM-SHA-256"
	]
}
{
	"_id" : "admin.user001",
	"userId" : UUID("ed93e470-189a-48e5-a069-cbef455e65f0"),
	"user" : "user001",
	"db" : "admin",
	"customData" : {
		"name" : "jim",
		"email" : "jim@qq.com",
		"age" : 18
	},
	"roles" : [
		{
			"role" : "readWrite",
			"db" : "db001"
		},
		{
			"role" : "readWrite",
			"db" : "db002"
		},
		{
			"role" : "read",
			"db" : "admin"
		}
	],
	"mechanisms" : [
		"SCRAM-SHA-1",
		"SCRAM-SHA-256"
	]
}
--删除指定用户
> db.dropUser('user001')
true
> show users;
{
	"_id" : "admin.jack",
	"userId" : UUID("d5892afb-86d6-4aee-aeb4-ed25674fda9b"),
	"user" : "jack",
	"db" : "admin",
	"roles" : [
		{
			"role" : "userAdminAnyDatabase",
			"db" : "admin"
		}
	],
	"mechanisms" : [
		"SCRAM-SHA-1",
		"SCRAM-SHA-256"
	]
}
{
	"_id" : "admin.root",
	"userId" : UUID("3f57644e-ad5f-40b4-a08a-1eb18e87af87"),
	"user" : "root",
	"db" : "admin",
	"roles" : [
		{
			"role" : "root",
			"db" : "admin"
		}
	],
	"mechanisms" : [
		"SCRAM-SHA-1",
		"SCRAM-SHA-256"
	]
}
--change password
> db.changeUserPassword('jack','jackli')
--change password and modify info,键区分大小写
> db.runCommand({updateUser: "jack",pwd: "jackli",customData: {"fullname": "JackLi","email": "Jack.Li@test.com","phone": "13500000000"}})
{ "ok" : 1 }
> show users;
{
	"_id" : "admin.jack",
	"userId" : UUID("d5892afb-86d6-4aee-aeb4-ed25674fda9b"),
	"user" : "jack",
	"db" : "admin",
	"roles" : [
		{
			"role" : "userAdminAnyDatabase",
			"db" : "admin"
		}
	],
	"customData" : {
		"fullname" : "JackLi",
		"email" : "Jack.Li@test.com",
		"phone" : "13500000000"
	},
	"mechanisms" : [
		"SCRAM-SHA-1",
		"SCRAM-SHA-256"
	]
}
{
	"_id" : "admin.root",
	"userId" : UUID("3f57644e-ad5f-40b4-a08a-1eb18e87af87"),
	"user" : "root",
	"db" : "admin",
	"roles" : [
		{
			"role" : "root",
			"db" : "admin"
		}
	],
	"mechanisms" : [
		"SCRAM-SHA-1",
		"SCRAM-SHA-256"
	]
}
--权限追加
> db.grantRolesToUser('admin',[{role:"dbAdmin",db:"jack"}])
> show users
{
	"_id" : "admin.admin",
	"userId" : UUID("d41ccf2b-5324-426b-bd38-5a2a1c19f7f1"),
	"user" : "admin",
	"db" : "admin",
	"roles" : [
		{
			"role" : "dbAdmin",
			"db" : "jack"
		},
		{
			"role" : "userAdminAnyDatabase",
			"db" : "admin"
		}
	],
	"mechanisms" : [
		"SCRAM-SHA-1",
		"SCRAM-SHA-256"
	]
}
{
	"_id" : "admin.root",
	"userId" : UUID("a1cd23d6-79ec-4bff-8380-a462343c80dd"),
	"user" : "root",
	"db" : "admin",
	"roles" : [
		{
			"role" : "root",
			"db" : "admin"
		}
	],
	"mechanisms" : [
		"SCRAM-SHA-1",
		"SCRAM-SHA-256"
	]
}

注：无论是什么用户，无论授予了什么数据库权限，都必须进入admin数据库(use admin)，然后进行认证，db.auth('user','pass')



#Mongodb集群搭建
mongodb 集群搭建的方式有三种：
主从备份（Master - Slave）模式，或者叫主从复制模式。
副本集（Replica Set）模式。
分片（Sharding）模式。
其中，第一种方式基本没什么意义，官方也不推荐这种方式搭建。另外两种分别就是副本集和分片的方式。



</pre>
