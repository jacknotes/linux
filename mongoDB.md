# MongoDB



## 1. MongoDB的基本数据结构 

| SQL术语/概念 | MongoDB术语/概念 | 解释/说明                           |
| ------------ | ---------------- | ----------------------------------- |
| database     | database         | 数据库                              |
| table        | collection       | 数据库表/集合                       |
| row          | document         | 数据记录行/文档                     |
| column       | field            | 数据字段/域                         |
| index        | index            | 索引                                |
| table joins  |                  | 表连接/MongoDB不支持                |
| primary key  | primary key      | 主键/MongoDB自动将_id字段设置为主键 |

> 可以看到 MongoDB 与 SQL 的数据库概念都是一致的，而 MongoDB 中数据库表（Table）则称之为集合（Collection），行（Row）则称为文档（Document），列（Column）则称为字段（Field）。



**MongoDB创建数据库**
创建和切换数据库的语法格式为：use database_name

> 如果数据库不存在，则创建数据库，否则切换到指定数据库。



**MongoDB创建表**
MongoDB中并没有直接创建表的命令，表的数据结构在你往表插入数据时确定。因此在 MongoDB 中，你创建完数据库之后就可以直接往表中插入数据，表名在插入数据时指定。



**MongoDB插入数据**
MongoDB 使用 insert() 或 save() 方法向集合中插入文档，语法如下：

```mongo
db.collection.insert(document)

> db.user.insert({
> ...     "name": "chenyurong",
> ...     "age": 25,
> ...     "addr": "ShenZhen"
> ... })
> WriteResult({ "nInserted" : 1 })
> db.user.find()
> { "_id" : ObjectId("59a2782f6eb4c099dbb718a1"), "name" : "chenyurong", "age" : 25, "addr" : "ShenZhen" }
```



**查看所有数据库**

```
> show dbs     
> admin       0.000GB
> chenyurong  0.000GB
> local       0.000GB

> db.user.find().pretty()
> {
> "_id" : ObjectId("59abb034dca9453471d67f13"),
> "name" : "chenyurong",
> "age" : 25,
> "addr" : "ShenZhen"
> }
```



**MongoDB查询数据**

```
# 清空当前数据库下user表的所有数据
db.user.remove({})
WriteResult({ "nRemoved" : 2 })
# 查看user表的所有数据
db.user.find()
# 批量插入数据
db.user.insert([
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
```





## 2. MongoDB 查询数据的语法格式

```
db.collection.find(query, projection)
```

query（可选）：使用查询操作符指定查询条件。该参数是一个JSON对象，key 一般为查询的列名，value 为查询匹配的值。

projection（可选）：使用投影操作符指定返回的键。如果省略该参数，那么查询时返回文档中所有键值。该参数是一个JSON对象，key 为需要显示的列名，alue 为 1（显示） 或 0（不显示）。

下面的查询语句将user表中地址（addr）为ShenZhen，年龄（age）为25的数据筛选出来，并且在结果中不显示ID列：

```
db.user.find({"addr":"ShenZhen","age":25},{"_id":0}).pretty()
查询结果为：
{ "name" : "ChenYuRong", "age" : 25, "addr" : "ShenZhen" }
```



**范围操作符**

范围操作符指的是：大于、大于等于、等于、不等于、小于、小于等于操作符，在 MongoDB 中它们的表示以及使用如下所示

| 操作       | 格式       | 范例                                           | RDBMS中的类似语句            |
| ---------- | ---------- | ---------------------------------------------- | ---------------------------- |
| 等于       | {:}        | db.col.find({"by":"MongoDB入门教程"}).pretty() | where by = 'MongoDB入门教程' |
| 小于       | {:{$lt:}}  | db.col.find({"likes":{$lt:50}}).pretty()       | where likes < 50             |
| 小于或等于 | {:{$lte:}} | db.col.find({"likes":{$lte:50}}).pretty(       | where likes <= 50            |
| 大于       | {:{$gt:}}  | db.col.find({"likes":{$gt:50}}).pretty()       | where likes > 50             |
| 大于或等于 | {:{$gte:}} | db.col.find({"likes":{$gte:50}}).pretty()      | where likes >= 50            |
| 不等于     | {:{$ne:}}  | db.col.find({"likes":{$ne:50}}).pretty()       | where likes != 50            |

例如我要查询用户表中所有年龄大于等于25岁的用户，那么查询语句为：

```
db.user.find({"age": {$gte:25}},{"_id":0}).pretty()
```



**AND操作符**

MongoDB 的 find() 方法可以传入多个键（key），每个键（key）以逗号隔开。每个键（key）之间是与的逻辑关系。

例如我要查询用户表（user）中地址为ShenZhen且年龄大于等于25岁的用户，那么查询语句为：

```
db.user.find({"addr": "ShenZhen","age": {$gte:25}},{"_id":0}).pretty()
# 查询结果为：
{ "name" : "ChenYuRong", "age" : 25, "addr" : "ShenZhen" }
{ "name" : "XiaoHei", "age" : 28, "addr" : "ShenZhen" }
```




**OR操作符**

例如我要查询用户表（user）中地址为ShenZhen或者年龄大于等于30岁的用户，那么查询语句为：

```
db.user.find({$or:[{"addr":"ShenZhen"},{"age":{$gte:30}}]}).pretty()
```



**AND和OR操作符混合使用**
例如要实现以下SQL查询：

```sql
select * from user
where name = "ChenYuRong" or (age <= 25 and addr == "JieYang")

```

那么该 MongoDB 查询语句应该这样写：
```
db.user.find({$or:[{"name":"ChenYuRong"}, {"age": {$lte:25}, "addr": "JieYang"}]}).pretty()
```



**排序**

在 MongoDB 中使用使用 sort() 方法对数据进行排序，sort() 方法可以通过参数指定排序的字段，并使用 1 和 -1 来指定排序的方式，其中 1 为升序排列，而-1是用于降序排列。

sort()方法基本语法如下所示：

```
db.collection.find().sort({KEY:1})
```

> 其中KEY表示要进行排序的字段，例如我们将所有年龄小于30岁的用户查询出来并将其按照年龄升序排列：
> db.user.find({"age":{$lt:30}}).sort({age:1}).pretty()



**聚合**

MongoDB中聚合的方法使用aggregate()，其基本的语法格式如下：

```
db.collection.aggregate(AGGREGATE_OPERATION)
# 其中AGGREGATE_OPERATION的格式为：
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
```

> $group是固定的，表示这里一个分组聚合操作。
> _id表示需要根据哪一些列进行聚合，其实一个JSON对象，其key/value分别对应结果列的别名、需要聚合的的数据库字段名。
> totalCount表示聚合列的字段名。
> $sum表示要进行的聚合操作，后面的1表示每次加1。
> 例如要根据地区统计用户人数，那么查询语句为：
>
> ```
> db.user.aggregate([{$group:{_id:{userAddr:'$addr'},totalCount:{$sum:1}}}])
> # 查询结果为：
> { "_id" : { "userAddr" : "FuJian" }, "totalCount" : 1 }
> { "_id" : { "userAddr" : "JieYang" }, "totalCount" : 1 }
> { "_id" : { "userAddr" : "BeiJing" }, "totalCount" : 1 }
> { "_id" : { "userAddr" : "GuangZhou" }, "totalCount" : 1 }
> { "_id" : { "userAddr" : "ShenZhen" }, "totalCount" : 2 }
> ```



**MongoDB更新数据**

update() 方法用于更新已存在的文档。语法格式如下：

```
db.collection.update(
   <query>,
   <update>,
   {
     upsert: <boolean>,
     multi: <boolean>,
     writeConcern: <document>
   }
)
```

> query：对哪些数据进行更新操作。
> update：对这些数据做什么操作。
> upsert（可选）：如果不存在update的记录，是否将其作为记录插入。true为插入，默认是false，不插入。
> multi（可选）：是否更新多条记录。MongoDB 默认是false，只更新找到的第一条记录。如果这个参数为true,就把按条件查出来多条记录全部更新。
> writeConcern（可选）：表示抛出异常的级别。
>
> 例如我们更新user表名为chenyurong的记录，将其年龄更改为25岁。
>
> ```
> db.user.update({'name':'chenyurong'},{$set:{'age':25}})
> ```
>
>
> 其中$set表示进行赋值操作。



**MongoDB删除数据**

MongoDB中聚合的方法使用remove()，其基本的语法格式如下：

```
db.collection.remove(
   <query>,
   {
     justOne: <boolean>,
     writeConcern: <document>
   }
)
```

> query（可选）：删除的文档的条件。
> justOne（可选）：如果设为 true 或 1，则只删除一个文档。
> writeConcern（可选）：抛出异常的级别。
> 例如我们想删除名字（name）为LiQiLiang的用户，那么该删除语句为：
>
> ```
> > db.user.remove({"name":"LiQiLiang"})
> WriteResult({ "nRemoved" : 1 })
> > db.user.find({"name":"LiQiLiang"}).pretty()
> ```
>
> 如果你想删除所有数据，可以使用以下方式（类似常规 SQL 的 truncate 命令）：
> ```
> db.col.remove({})
> db.col.find()
> ```



**常用的DDL命令**

* 查看当前数据库：db
* 查看所有数据库：show dbs
* 查看当前数据库所有集合（表格）：show collections



**MongoDB图形化工具**

* 如果是企业版用户，可以使用MongoDB Compass。
* 如果是个人用户，而且也一样使用 JetBrain 编辑器，那么你可以试试 JetBrain 的一款插件：JetBrain Plugin：mongo4idea。
* 其它：NoSQL for MongoDB（Windows使用）、Navicat





## 3. mangoDB单节点部署

```bash
[root@hw-blog data]# docker run -d \
 --restart=always \
 --name mongodb \
 -v /data/mongodb/db:/data/db \
 -v /data/mongodb/configdb:/data/configdb \
 -p 27017:27017 \
 -e MONGO_INITDB_ROOT_USERNAME=root \
 -e MONGO_INITDB_ROOT_PASSWORD=mongo@db \
 mongo:4.4
 
[root@hw-blog data]# tree mongodb/
mongodb/
├── configdb
└── db
    ├── collection-0-8434121944971773759.wt
    ├── collection-2-8434121944971773759.wt
    ├── collection-4-8434121944971773759.wt
    ├── collection-7-8434121944971773759.wt
    ├── diagnostic.data
    │   ├── metrics.2025-02-07T02-36-29Z-00000
    │   ├── metrics.2025-02-07T02-36-33Z-00000
    │   └── metrics.interim
    ├── index-1-8434121944971773759.wt
    ├── index-3-8434121944971773759.wt
    ├── index-5-8434121944971773759.wt
    ├── index-6-8434121944971773759.wt
    ├── index-8-8434121944971773759.wt
    ├── index-9-8434121944971773759.wt
    ├── journal
    │   ├── WiredTigerLog.0000000002
    │   ├── WiredTigerPreplog.0000000001
    │   └── WiredTigerPreplog.0000000002
    ├── _mdb_catalog.wt
    ├── mongod.lock
    ├── sizeStorer.wt
    ├── storage.bson
    ├── WiredTiger
    ├── WiredTigerHS.wt
    ├── WiredTiger.lock
    ├── WiredTiger.turtle
    └── WiredTiger.wt

4 directories, 25 files


```



## 4. 权限管理

> mongo在命令行模式下，不支持多用户同时登录，只允许一个用户登录，如果要登录另外新用户，首先需要退出旧用户登录才可登录新用户，使用db.logout()退出，使用db.auth(‘user’, 'password')登入

**MongoDB角色**

* 数据库用户角色：read、readWrite；
* 数据库管理角色：dbAdmin、dbOwner、userAdmin;
* 集群管理角色：clusterAdmin、clusterManager、4. clusterMonitor、hostManage；
* 备份恢复角色：backup、restore；
* 所有数据库角色：readAnyDatabase、readWriteAnyDatabase、userAdminAnyDatabase、dbAdminAnyDatabase
* 超级用户角色：root
* 内部角色：__system

**角色描述**

* Read：允许用户读取指定数据库

* readWrite：允许用户读写指定数据库
* dbAdmin：允许用户在指定数据库中执行管理函数，如索引创建、删除，查看统计或访问system.profile
* userAdmin：允许用户向system.users集合写入，可以在指定数据库里创建、删除和管理用户
* clusterAdmin：只在admin数据库中可用，赋予用户所有分片和复制集相关函数的管理权限。
* readAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的读权限
* readWriteAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的读写权限
* userAdminAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的userAdmin权限
* dbAdminAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的dbAdmin权限。
* root：只在admin数据库中可用。超级账号，超级权限



### 4.1 创建用户

```bash
[root@hw-blog data]# docker exec -it mongodb sh 
# mongo 127.0.0.1:27017/admin -u root -p mongo@db
MongoDB shell version v4.4.29
connecting to: mongodb://127.0.0.1:27017/admin?compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("a0c5f843-c2c4-4925-ae78-b7d291a91e1c") }
MongoDB server version: 4.4.29
Welcome to the MongoDB shell.
For interactive help, type "help".
For more comprehensive documentation, see
	https://docs.mongodb.com/
Questions? Try the MongoDB Developer Community Forums
	https://community.mongodb.com
---
The server generated these startup warnings when booting: 
        2025-02-07T02:36:31.223+00:00: Using the XFS filesystem is strongly recommended with the WiredTiger storage engine. See http://dochub.mongodb.org/core/prodnotes-filesystem
        2025-02-07T02:36:32.199+00:00: /sys/kernel/mm/transparent_hugepage/enabled is 'always'. We suggest setting it to 'never'
        2025-02-07T02:36:32.199+00:00: /sys/kernel/mm/transparent_hugepage/defrag is 'always'. We suggest setting it to 'never'
---
> use admin
switched to db admin
> db.auth('root','mongo@db')
1
> db.createUser({user:'admin',pwd:'p@ssw0rd',roles:[{role:'userAdminAnyDatabase', db:'admin'}]});
AnyDatabase', db:'jack'}]});Successfully added user: {
	"user" : "admin",
	"roles" : [
		{
			"role" : "userAdminAnyDatabase",
			"db" : "admin"
		}
	]
}
> db.createUser({user:'jack',pwd:'p@ssw0rd',roles:[{role:'userAdminAnyDatabase', db:'admin'}]});
Successfully added user: {
	"user" : "jack",
	"roles" : [
		{
			"role" : "userAdminAnyDatabase",
			"db" : "admin"
		}
	]
}

> use keyauth;
switched to db keyauth
> db.createUser({user:'keyauth',pwd:'123456',roles:[{role:'dbOwner', db:'keyauth'}]});
Successfully added user: {
	"user" : "keyauth",
	"roles" : [
		{
			"role" : "dbOwner",
			"db" : "keyauth"
		}
	]
}
> show users;
{
	"_id" : "keyauth.keyauth",
	"userId" : UUID("a102e410-134b-4047-a866-8c91b9091b53"),
	"user" : "keyauth",
	"db" : "keyauth",
	"roles" : [
		{
			"role" : "dbOwner",
			"db" : "keyauth"
		}
	],
	"mechanisms" : [
		"SCRAM-SHA-1",
		"SCRAM-SHA-256"
	]
}

```



### 4.2 CRUD

```bash
> db.logout()
{ "ok" : 1 }
> db.logout()
{
	"ok" : 0,
	"errmsg" : "command logout requires authentication",
	"code" : 13,
	"codeName" : "Unauthorized"
}
> db.auth('keyauth','123456')
1
> show collections;
> db.id.insert( { "id": 01, "name": "jack" } )
WriteResult({ "nInserted" : 1 })
> show collections;
id
> db.id.save( { "id": 02, "name": "candy" } )
WriteResult({ "nInserted" : 1 })
> db.id.find() 
{ "_id" : ObjectId("67a59a1eadd3e076064c2e54"), "id" : 1, "name" : "jack" }
{ "_id" : ObjectId("67a59a35add3e076064c2e55"), "id" : 2, "name" : "candy" }
# 批量插入
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
> db.id.find()
{ "_id" : ObjectId("67a59a1eadd3e076064c2e54"), "id" : 1, "name" : "jack" }
{ "_id" : ObjectId("67a59a35add3e076064c2e55"), "id" : 2, "name" : "candy" }
{ "_id" : ObjectId("67a59a4cadd3e076064c2e56"), "id" : 1, "name" : "jack" }
{ "_id" : ObjectId("67a59a4cadd3e076064c2e57"), "id" : 2, "name" : "candy" }
# 或 查询
> db.id.find({$or: [{"id":1},{"id":2}]}) 
{ "_id" : ObjectId("67a59a1eadd3e076064c2e54"), "id" : 1, "name" : "jack" }
{ "_id" : ObjectId("67a59a35add3e076064c2e55"), "id" : 2, "name" : "candy" }
{ "_id" : ObjectId("67a59a4cadd3e076064c2e56"), "id" : 1, "name" : "jack" }
{ "_id" : ObjectId("67a59a4cadd3e076064c2e57"), "id" : 2, "name" : "candy" }
# and 查询
> db.id.find({"id":2,"name":"candy"})
{ "_id" : ObjectId("67a59a35add3e076064c2e55"), "id" : 2, "name" : "candy" }
{ "_id" : ObjectId("67a59a4cadd3e076064c2e57"), "id" : 2, "name" : "candy" }
# sort排序，1为升序、-1为倒序
> db.id.find().sort({id:-1})
{ "_id" : ObjectId("67a59a9fadd3e076064c2e58"), "id" : 3, "name" : "bob" }
{ "_id" : ObjectId("67a59a35add3e076064c2e55"), "id" : 2, "name" : "candy" }
{ "_id" : ObjectId("67a59a4cadd3e076064c2e57"), "id" : 2, "name" : "candy" }
{ "_id" : ObjectId("67a59a1eadd3e076064c2e54"), "id" : 1, "name" : "jack" }
{ "_id" : ObjectId("67a59a4cadd3e076064c2e56"), "id" : 1, "name" : "jack" }
# aggregate聚合
> db.id.aggregate([{$group:{_id:{idnum:'$id'},totalCount:{$sum:1}}}])
{ "_id" : { "idnum" : 3 }, "totalCount" : 1 }
{ "_id" : { "idnum" : 2 }, "totalCount" : 2 }
{ "_id" : { "idnum" : 1 }, "totalCount" : 2 }
# 删除document
> db.id.remove({"id":1}) 
WriteResult({ "nRemoved" : 2 })
> db.id.find();
{ "_id" : ObjectId("67a59a35add3e076064c2e55"), "id" : 2, "name" : "candy" }
{ "_id" : ObjectId("67a59a4cadd3e076064c2e57"), "id" : 2, "name" : "candy" }
{ "_id" : ObjectId("67a59a9fadd3e076064c2e58"), "id" : 3, "name" : "bob" }
# 更新document
> db.id.update({"name":"tim"},{$set:{"id":4}})
WriteResult({ "nMatched" : 0, "nUpserted" : 0, "nModified" : 0 })
> db.id.find();
{ "_id" : ObjectId("67a59a35add3e076064c2e55"), "id" : 2, "name" : "candy" }
{ "_id" : ObjectId("67a59a4cadd3e076064c2e57"), "id" : 2, "name" : "candy" }
{ "_id" : ObjectId("67a59a9fadd3e076064c2e58"), "id" : 3, "name" : "bob" }
> db.id.update({"name":"bob"},{$set:{"id":4}})
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })
> db.id.find();
{ "_id" : ObjectId("67a59a35add3e076064c2e55"), "id" : 2, "name" : "candy" }
{ "_id" : ObjectId("67a59a4cadd3e076064c2e57"), "id" : 2, "name" : "candy" }
{ "_id" : ObjectId("67a59a9fadd3e076064c2e58"), "id" : 4, "name" : "bob" }
```



### 4.3 查看创建的用户

```sh
> use admin
switched to db admin
> db.logout()
{
	"ok" : 0,
	"errmsg" : "command logout requires authentication",
	"code" : 13,
	"codeName" : "Unauthorized"
}
> db.auth('root','mongo@db')
1
# 查看当前数据库中所有用户
> show users;
{
	"_id" : "admin.admin",
	"userId" : UUID("618e4320-9b4f-4f63-8ee9-c9c9785ca48a"),
	"user" : "admin",
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
	"_id" : "admin.jack",
	"userId" : UUID("affd1e0e-cede-481b-a6fa-a698f67aa625"),
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
	"userId" : UUID("aa772b89-cc30-42fd-972c-9878f5721dd2"),
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

# 查看mongo数据库中所有用户
> db.system.users.find().pretty() 
{
	"_id" : "admin.root",
	"userId" : UUID("aa772b89-cc30-42fd-972c-9878f5721dd2"),
	"user" : "root",
	"db" : "admin",
	"credentials" : {
		"SCRAM-SHA-1" : {
			"iterationCount" : 10000,
			"salt" : "7OaTHJ+QwteRjJNMWmuYMw==",
			"storedKey" : "BHRL37fWnNXNIpVuE7X8WvX01rk=",
			"serverKey" : "biyGQ+exqRd4It3kweK6t21hLTM="
		},
		"SCRAM-SHA-256" : {
			"iterationCount" : 15000,
			"salt" : "kSvxixOrppqG6AFzw5CUj9i8nOp3YtvHJy+keg==",
			"storedKey" : "O/+HXD3KLvRFMIohughpEyI0LPz/XHqGzoRjUZVsU6g=",
			"serverKey" : "FtTgZyy6hzEylh26/mKKLaYaWkydlOgbCSs5h2GURjU="
		}
	},
	"roles" : [
		{
			"role" : "root",
			"db" : "admin"
		}
	]
}
{
	"_id" : "admin.admin",
	"userId" : UUID("618e4320-9b4f-4f63-8ee9-c9c9785ca48a"),
	"user" : "admin",
	"db" : "admin",
	"credentials" : {
		"SCRAM-SHA-1" : {
			"iterationCount" : 10000,
			"salt" : "M2Cof1VOFgxLp1JnjK5iLw==",
			"storedKey" : "1ToweAwAav00qfETg6bjkQOiQOI=",
			"serverKey" : "ZWbZPaZwjaQi+a2zm7F8w2fkvlM="
		},
		"SCRAM-SHA-256" : {
			"iterationCount" : 15000,
			"salt" : "gNQg//V81TiadDf8waQMhjeSPu5YmK9iq3Gs1g==",
			"storedKey" : "7Ft96nXZnYaQkGZodBdZFs7bhj4kWwcobQeXJxOsMEE=",
			"serverKey" : "iRsN/x3PBasuzlxaxxDWRkH5JE+kctMlj2jUCGJiNfk="
		}
	},
	"roles" : [
		{
			"role" : "userAdminAnyDatabase",
			"db" : "admin"
		}
	]
}
{
	"_id" : "admin.jack",
	"userId" : UUID("affd1e0e-cede-481b-a6fa-a698f67aa625"),
	"user" : "jack",
	"db" : "admin",
	"credentials" : {
		"SCRAM-SHA-1" : {
			"iterationCount" : 10000,
			"salt" : "wFryUX/LTKo+TBp5QsKmnw==",
			"storedKey" : "CBQduzB4urQVGIjoR+e8518LS0U=",
			"serverKey" : "sEcxGn0JHPKrhnJdi9AfQctjQns="
		},
		"SCRAM-SHA-256" : {
			"iterationCount" : 15000,
			"salt" : "rDOHCQQWXp7Z67AHNEDHNciOgilgqinqY7fVKw==",
			"storedKey" : "aYUKFPsjMJglLM/KbXplL0Qbx2oNuLffZuItkzrWYkI=",
			"serverKey" : "VNdTf9Pus7WSgUUiJLH3ySteXOzsu8BZqEk8ob2aWWQ="
		}
	},
	"roles" : [
		{
			"role" : "userAdminAnyDatabase",
			"db" : "admin"
		}
	]
}
{
	"_id" : "jack.keyauth",
	"userId" : UUID("014978f3-987d-4ff8-be07-fb031debb6dc"),
	"user" : "keyauth",
	"db" : "jack",
	"credentials" : {
		"SCRAM-SHA-1" : {
			"iterationCount" : 10000,
			"salt" : "JyIdtI1eAsUNP5Z3CO2AtA==",
			"storedKey" : "9DgDYcVkZC1/qD8LHrI8HGfJ1aQ=",
			"serverKey" : "3Q3RBCUzQOiHSgsHwufp+X5vLaE="
		},
		"SCRAM-SHA-256" : {
			"iterationCount" : 15000,
			"salt" : "FuukCnhZMuUXfO7MsxVRJgjJWEOHk8UGS7M0Hw==",
			"storedKey" : "hiOOxIgL0RNfArM/JLj7jYCjtZxlP3TjTF3eIYCJlxo=",
			"serverKey" : "L6qD6akpMhtnaDRdHZ7o5T8CV8194oiDt6TjboLVy6Q="
		}
	},
	"roles" : [
		{
			"role" : "dbOwner",
			"db" : "keyauth"
		}
	]
}
{
	"_id" : "keyauth.keyauth",
	"userId" : UUID("a102e410-134b-4047-a866-8c91b9091b53"),
	"user" : "keyauth",
	"db" : "keyauth",
	"credentials" : {
		"SCRAM-SHA-1" : {
			"iterationCount" : 10000,
			"salt" : "XGhSn/GBsCbbZ81Yr1P9Nw==",
			"storedKey" : "OOSD81eXxWKai3j13OeGTEtQ7+c=",
			"serverKey" : "UJmwfsywt0SNfOOfOtdrZ90/dRY="
		},
		"SCRAM-SHA-256" : {
			"iterationCount" : 15000,
			"salt" : "OZ7umQYDL7V0IDEcOY2vmwcYMwfPpehNXOvTEA==",
			"storedKey" : "q0HXdPrIToJfJIygV4YppCELgN9MWdeROsihPrSHyow=",
			"serverKey" : "xczA1F0wLh3hbcPybeOilog6R3Jhg0Tw7HIf11AV6pU="
		}
	},
	"roles" : [
		{
			"role" : "dbOwner",
			"db" : "keyauth"
		}
	]
}

# 查看指定用户信息
> db.runCommand({usersInfo:"root"})
{
	"users" : [
		{
			"_id" : "admin.root",
			"userId" : UUID("aa772b89-cc30-42fd-972c-9878f5721dd2"),
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
	],
	"ok" : 1
}
```



### 4.4 修改密码

```sh
# 查看当前连接的用户信息
> db.runCommand({ connectionStatus: 1 })
{
	"authInfo" : {
		"authenticatedUsers" : [
			{
				"user" : "root",
				"db" : "admin"
			}
		],
		"authenticatedUserRoles" : [
			{
				"role" : "root",
				"db" : "admin"
			}
		]
	},
	"ok" : 1
}

> use keyauth
switched to db keyauth
> show users;
{
	"_id" : "keyauth.keyauth",
	"userId" : UUID("a102e410-134b-4047-a866-8c91b9091b53"),
	"user" : "keyauth",
	"db" : "keyauth",
	"roles" : [
		{
			"role" : "dbOwner",
			"db" : "keyauth"
		}
	],
	"mechanisms" : [
		"SCRAM-SHA-1",
		"SCRAM-SHA-256"
	]
}

# 更改账户密码
> db.changeUserPassword("keyauth","keyauth@123456")


# 退出当前用户连接，只能在登录的数据库退出，否则登出失败
> db.runCommand({ connectionStatus: 1 })
{
	"authInfo" : {
		"authenticatedUsers" : [
			{
				"user" : "root",
				"db" : "admin"
			}
		],
		"authenticatedUserRoles" : [
			{
				"role" : "root",
				"db" : "admin"
			}
		]
	},
	"ok" : 1
}
# 以下登出失败
> db.logout()
{ "ok" : 1 }
> db.logout()
{ "ok" : 1 }
> db.logout()
{ "ok" : 1 }
# 进入admin数据库，再次登出，则成功
> use admin
switched to db admin
> db.logout()
{ "ok" : 1 }
> db.logout()
{
	"ok" : 0,
	"errmsg" : "command logout requires authentication",
	"code" : 13,
	"codeName" : "Unauthorized"
}


# 验证新密码是否正常
> use keyauth
switched to db keyauth
> db.auth("keyauth","keyauth@123456")
1
> show collections;
id
> db.id.find({})
{ "_id" : ObjectId("67a59a35add3e076064c2e55"), "id" : 2, "name" : "candy" }
{ "_id" : ObjectId("67a59a4cadd3e076064c2e57"), "id" : 2, "name" : "candy" }
{ "_id" : ObjectId("67a59a9fadd3e076064c2e58"), "id" : 4, "name" : "bob" }

```



### 4.5 修改密码和信息

```sh
> db.runCommand({updateUser: 'keyauth', pwd: '123456', customData: {title: "test info"}})
{ "ok" : 1 }
> db.runCommand({ connectionStatus: 1 })
{
	"authInfo" : {
		"authenticatedUsers" : [
			{
				"user" : "keyauth",
				"db" : "keyauth"
			}
		],
		"authenticatedUserRoles" : [
			{
				"role" : "dbOwner",
				"db" : "keyauth"
			}
		]
	},
	"ok" : 1
}
> db
keyauth
> db.logout()
{ "ok" : 1 }
> db.logout()
{
	"ok" : 0,
	"errmsg" : "command logout requires authentication",
	"code" : 13,
	"codeName" : "Unauthorized"
}
> db.auth("keyauth","keyauth@123456")
Error: Authentication failed.
0
> db.auth("keyauth","123456")
1
> db.id.find({})
{ "_id" : ObjectId("67a59a35add3e076064c2e55"), "id" : 2, "name" : "candy" }
{ "_id" : ObjectId("67a59a4cadd3e076064c2e57"), "id" : 2, "name" : "candy" }
{ "_id" : ObjectId("67a59a9fadd3e076064c2e58"), "id" : 4, "name" : "bob" }
```



### 4.6 删除数据库用户

```sh
> use admin
switched to db admin
> db.auth('root','mongo@db')
1
> show users;
{
	"_id" : "admin.admin",
	"userId" : UUID("618e4320-9b4f-4f63-8ee9-c9c9785ca48a"),
	"user" : "admin",
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
	"_id" : "admin.jack",
	"userId" : UUID("affd1e0e-cede-481b-a6fa-a698f67aa625"),
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
	"userId" : UUID("aa772b89-cc30-42fd-972c-9878f5721dd2"),
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
> db.dropUser('admin')
true
> show users;
{
	"_id" : "admin.jack",
	"userId" : UUID("affd1e0e-cede-481b-a6fa-a698f67aa625"),
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
	"userId" : UUID("aa772b89-cc30-42fd-972c-9878f5721dd2"),
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
```



### 4.7 创建超级管理员

```sh
> db.createUser({user: "candy", pwd: "candy@123456", roles: ["root"]})
Successfully added user: { "user" : "candy", "roles" : [ "root" ] }
> show users;
{
	"_id" : "admin.candy",
	"userId" : UUID("1bf7b79b-261c-40d5-8cd5-a2c92c65dae7"),
	"user" : "candy",
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
	"_id" : "admin.jack",
	"userId" : UUID("affd1e0e-cede-481b-a6fa-a698f67aa625"),
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
	"userId" : UUID("aa772b89-cc30-42fd-972c-9878f5721dd2"),
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
```





### 4.8 创建业务数据库用户

> 只负责某一个或几个数据库的増查改删，以及所有数据库的只读权限

```bash
> db.createUser({user: "ops", pwd: "ops@123456", customData: {name: "jack", email: "12345@qq.com", age: 31}, roles: [{role: "readWrite", db: "ops01"}, {role: "readWrite", db: "ops02"},"read"]})
Successfully added user: {
	"user" : "ops",
	"customData" : {
		"name" : "jack",
		"email" : "12345@qq.com",
		"age" : 31
	},
	"roles" : [
		{
			"role" : "readWrite",
			"db" : "ops01"
		},
		{
			"role" : "readWrite",
			"db" : "ops02"
		},
		"read"
	]
}

> db.system.users.find({"user": "ops"}).pretty()
{
	"_id" : "admin.ops",
	"userId" : UUID("85454471-d05c-4d88-9a3b-180f9eda1b18"),
	"user" : "ops",
	"db" : "admin",
	"credentials" : {
		"SCRAM-SHA-1" : {
			"iterationCount" : 10000,
			"salt" : "EX1IuChEdX+5l6zZf1h6LQ==",
			"storedKey" : "KtlL+VH/7a4n7aL3pUb/ea/9xvY=",
			"serverKey" : "VHIzxwzQQ4VOxKyjUWAI5woEc8Y="
		},
		"SCRAM-SHA-256" : {
			"iterationCount" : 15000,
			"salt" : "x7XCfg2+rPSgu7SJxoT3SXr+ygxH59qOezoYQw==",
			"storedKey" : "DZ8MEpEijEAjX1l76rZm5ssA8A+IYjZMnXge46dfqdU=",
			"serverKey" : "h1gTb46ucSBpv3B5SJUBtuGUzAzCvXBeYeo7t7IFBu4="
		}
	},
	"customData" : {
		"name" : "jack",
		"email" : "12345@qq.com",
		"age" : 31
	},
	"roles" : [
		{
			"role" : "readWrite",
			"db" : "ops01"
		},
		{
			"role" : "readWrite",
			"db" : "ops02"
		},
		{
			"role" : "read",
			"db" : "admin"
		}
	]
}

# 权限追加
> db.grantRolesToUser('ops', [{role: "dbAdmin", db: "test"}])
> db.system.users.find({"user": "ops"}).pretty()
{
	"_id" : "admin.ops",
	"userId" : UUID("85454471-d05c-4d88-9a3b-180f9eda1b18"),
	"user" : "ops",
	"db" : "admin",
	"credentials" : {
		"SCRAM-SHA-1" : {
			"iterationCount" : 10000,
			"salt" : "EX1IuChEdX+5l6zZf1h6LQ==",
			"storedKey" : "KtlL+VH/7a4n7aL3pUb/ea/9xvY=",
			"serverKey" : "VHIzxwzQQ4VOxKyjUWAI5woEc8Y="
		},
		"SCRAM-SHA-256" : {
			"iterationCount" : 15000,
			"salt" : "x7XCfg2+rPSgu7SJxoT3SXr+ygxH59qOezoYQw==",
			"storedKey" : "DZ8MEpEijEAjX1l76rZm5ssA8A+IYjZMnXge46dfqdU=",
			"serverKey" : "h1gTb46ucSBpv3B5SJUBtuGUzAzCvXBeYeo7t7IFBu4="
		}
	},
	"customData" : {
		"name" : "jack",
		"email" : "12345@qq.com",
		"age" : 31
	},
	"roles" : [
		{
			"role" : "readWrite",
			"db" : "ops02"
		},
		{
			"role" : "readWrite",
			"db" : "ops01"
		},
		{
			"role" : "dbAdmin",
			"db" : "test"
		},
		{
			"role" : "read",
			"db" : "admin"
		}
	]
}

# 测试权限 
# 进入ops01测试权限正常
> use ops01
switched to db ops01
> show collections;
> db.id.insert( { "id": 01, "name": "jack" } )
WriteResult({ "nInserted" : 1 })
> show dbs
admin  0.000GB
ops01  0.000GB
> show collections;
id
> db.id.find({})
{ "_id" : ObjectId("67a5a79ab0855caa20c97f0e"), "id" : 1, "name" : "jack" }
# 进入ops03测试权限正常，因为是只读，所以无法插入
> use ops03
switched to db ops03
> db.id.insert( { "id": 01, "name": "jack" } )
WriteCommandError({
	"ok" : 0,
	"errmsg" : "not authorized on ops03 to execute command { insert: \"id\", ordered: true, lsid: { id: UUID(\"deadcfc5-3850-4288-9a09-4a3d8b00dc86\") }, $db: \"ops03\" }",
	"code" : 13,
	"codeName" : "Unauthorized"
})
```

> 无论是什么用户，无论授予了什么数据库权限，都必须进入admin数据库(use admin)，然后进行认证，db.auth('user','pass')





## 5. MongoDB集群部署

MongoDB 集群部署方式有三种：

**1. 副本集 (Replica Set)**：

- **定义**：副本集是一组 MongoDB 实例的集群，其中一个是主节点，其他的是从节点。数据在主节点上进行写操作，从节点会同步主节点的数据。副本集确保数据的高可用性与容错能力。
- **用途**：适用于需要高可用性和数据备份的场景。
- **特点**：一个副本集可以有多个节点（通常为奇数个节点），具有自动故障切换能力。

**2. 分片集群 (Sharded Cluster)**：

- **定义**：分片集群是一种水平扩展的方式，数据根据特定的分片键被分布到多个分片中。每个分片实际上是一个副本集。
- **用途**：适用于需要高吞吐量、处理大规模数据集的场景。
- 特点：包括三个主要组件：
  - **Shard**：存储数据的分片，可以是副本集。
  - **Mongos**：路由服务，客户端通过它访问分片。
  - **Config Servers**：存储分片集群的元数据。

**3. 混合模式 (Replica Set + Sharding)**：

- **定义**：分片集群中的每个分片本身是一个副本集，这样可以结合副本集的高可用性和分片集群的水平扩展性。
- **用途**：适用于需要高可用性和扩展性的生产环境。



