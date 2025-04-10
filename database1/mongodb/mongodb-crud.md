* 集合(collections)等同于关系型数据库的表
* 文档等同于关系型数据库的记录行

```bash
db               #查看当前数据库
use dbname       #切换数据库
show collections #列出集合（表）
```


# 创建文档 db.collection.insert()
* 创建集合(blog)并插入文档
```bash
db.collection.insertOne() #插入一个文档
db.users.insert(
   {
      name: "sue",
      age: 19,
      status: "P"
   }
)

db.collection.insertMany()  #插入多个文档
db.users.insert(
   [
     { name: "bob", age: 42, status: "A", },
     { name: "ahn", age: 22, status: "A", },
     { name: "xi", age: 34, status: "D", }
   ]
)
```
* _id 字段
>在MongoDB中，存储于集合中的每一个文档都需要一个唯一的 _id 字段作为 primary_key。如果一个插入文档操作遗漏了``_id`` 字段，MongoDB驱动会自动为``_id``字段生成一个 ObjectId。



# 查询文档 db.collection.find()
```bash
db.users.insert({'name':'xikai','age':24,'email':'quxiu@email.com'})
db.users.find({'name':'xikai'})               #查询指定条件
db.users.find({},{'name':1,'email':1})        #只查询文档的name和email字段
db.users.find({},{'name':0})        	      #查询文档除尘name以外的所有字段
db.users.count() 			      #统计文档数

#条件查询
$gt $gte $lt $lte $ne $in $and $or (大于，大于等于，小于，小于等于，不等于)
db.users.find({'age':{$gte:24,$lt:26}})        #查询age大于等于24小于26的
db.users.find({status:{$in:['A','D']}})        #in查询与键值匹配的值
db.users.find({'email':'quxiu@email.com','age':24})  #and
db.users.find({$or:[{'email':'quxiu@email.com'},{'age':25}]})  

#内嵌查询
db.inventory.insertMany( [
   { item: "journal", qty: 25, size: { h: 14, w: 21, uom: "cm" }, status: "A" },
   { item: "notebook", qty: 50, size: { h: 8.5, w: 11, uom: "in" }, status: "A" },
   { item: "paper", qty: 100, size: { h: 8.5, w: 11, uom: "in" }, status: "D" },
   { item: "planner", qty: 75, size: { h: 22.85, w: 30, uom: "cm" }, status: "D" },
   { item: "postcard", qty: 45, size: { h: 10, w: 15.25, uom: "cm" }, status: "A" }
]);

db.inventory.find( { size: { h: 14, w: 21, uom: "cm" } } )
db.inventory.find( { "size.h":14 })
db.inventory.find( { "size.h": { $lt: 15 } } )
db.inventory.find( { "size.h": { $lt: 15 }, "size.uom": "cm", status: "A" } )

#数组查询
db.inventory.insertMany([
   { item: "journal", qty: 25, tags: ["blank", "red"], dim_cm: [ 14, 21 ] },
   { item: "notebook", qty: 50, tags: ["red", "blank"], dim_cm: [ 14, 21 ] },
   { item: "paper", qty: 100, tags: ["red", "blank", "plain"], dim_cm: [ 14, 21 ] },
   { item: "planner", qty: 75, tags: ["blank", "red"], dim_cm: [ 22.85, 30 ] },
   { item: "postcard", qty: 45, tags: ["blue"], dim_cm: [ 10, 15.25 ] }
]);

#包含匹配
db.inventory.find( { tags: "red" } )
db.inventory.find( { tags: { $all: ["red", "blank"] } } )

db.inventory.find( { tags: ["red", "blank"] } )   #精确匹配 tags: ["red", "blank"]

#一个元素可以满足大于15的条件，另一个元素可以满足小于20的条件，或者一个元素可以同时满足两个条件
db.inventory.find( { dim_cm: { $gt: 15, $lt: 20 } } )

#数组中至少包含一个大于($gt) 22和小于($lt) 30的元素
db.inventory.find( { dim_cm: { $elemMatch: { $gt: 22, $lt: 30 } } } )

#查询tag包含3个元素的文档
db.inventory.find( { "tags": { $size: 3 } } )

#查询文档，返回前10条或后10条
db.posts.find( {}, { comments: { $slice: 10 } } )    #前10条
db.posts.find( {}, { comments: { $slice: -10 } } )    #后10条

#查询文档，从第20条开始往后10条
db.posts.find( {}, { comments: { $slice: [ 20, 10 ] } } ) 

#空查询
db.inventory.insertMany([
   { _id: 1, item: null },
   { _id: 2 }
])

#查询为空（null,不存在）的字段
> db.inventory.find( { item: null } )
{ "_id" : 1, "item" : null }
{ "_id" : 2 }

# 查询匹配不包含项目字段的文档
> db.inventory.find( { item : { $exists: false } } )
{ "_id" : 2 }

#正则表达式查询
db.users.find({'name':/xikai/i})
db.users.find({'name':/xikaiy?/})

#游标遍历
find()默认只打印20条
> for(var i=0;i<10000;i++){
	db.items.insert({"title":i,"content":i});
}

使用 var 关键字把 find() 方法返回的游标赋值给一个变量时，它将不会自动迭代。
> var myCursor = db.items.find()

 #myCursor.next()迭代下一条
> printjson(myCursor.next())
{ "_id" : ObjectId("5becead4f18e99d865436ed7"), "title" : 0, "content" : 0 }

#myCursor.hasNext() 判断游标是否已经取到尽头
> while (myCursor.hasNext()) {    
       printjson(myCursor.next());
    }

#forEach遍历整个集合
> var myCursor = db.items.find()
> myCursor.forEach(printjson)

db.users.find().limit(3)                     #查询前3个文档
db.users.find().skip(3)                      #查询忽略前3个文档
db.users.find().sort({'name':1,'age':-1})    #按name升序 age降序排列
```


# 修改文档 db.collection.update()
```bash
db.inventory.insertMany( [
   { item: "canvas", qty: 100, size: { h: 28, w: 35.5, uom: "cm" }, status: "A" },
   { item: "journal", qty: 25, size: { h: 14, w: 21, uom: "cm" }, status: "A" },
   { item: "mat", qty: 85, size: { h: 27.9, w: 35.5, uom: "cm" }, status: "A" },
   { item: "mousepad", qty: 25, size: { h: 19, w: 22.85, uom: "cm" }, status: "P" },
   { item: "notebook", qty: 50, size: { h: 8.5, w: 11, uom: "in" }, status: "P" },
   { item: "paper", qty: 100, size: { h: 8.5, w: 11, uom: "in" }, status: "D" },
   { item: "planner", qty: 75, size: { h: 22.85, w: 30, uom: "cm" }, status: "D" },
   { item: "postcard", qty: 45, size: { h: 10, w: 15.25, uom: "cm" }, status: "A" },
   { item: "sketchbook", qty: 80, size: { h: 14, w: 21, uom: "cm" }, status: "A" },
   { item: "sketch pad", qty: 95, size: { h: 22.85, w: 30.5, uom: "cm" }, status: "A" }
] );

{
  <update operator>: { <field1>: <value1>, ... },
  <update operator>: { <field2>: <value2>, ... },
  ...
}

#更新第一条
> db.inventory.find({item: "paper"})
{ "_id" : ObjectId("5becace359a0aba12c9c320e"), "item" : "paper", "qty" : 100, "size" : { "h" : 8.5, "w" : 11, "uom" : "in" }, "status" : "D" }
{ "_id" : ObjectId("5becaea2ed34096eb0cbd989"), "item" : "paper", "qty" : 100, "tags" : [ "red", "blank", "plain" ], "dim_cm" : [ 14, 21 ] }
{ "_id" : ObjectId("5beceefd1f95e45bd804aa0c"), "item" : "paper", "qty" : 100, "size" : { "h" : 8.5, "w" : 11, "uom" : "in" }, "status" : "D" }

> db.inventory.update(
...    { item: "paper" },
...    {
...      $set: { "size.uom": "cm", status: "P" },
...      $currentDate: { lastModified: true }
...    }
... )
{ "acknowledged" : true, "matchedCount" : 1, "modifiedCount" : 1 }

> db.inventory.find({item: "paper"})
{ "_id" : ObjectId("5becace359a0aba12c9c320e"), "item" : "paper", "qty" : 100, "size" : { "h" : 8.5, "w" : 11, "uom" : "cm" }, "status" : "P", "lastModified" : ISODate("2018-11-15T04:02:31.385Z") }
{ "_id" : ObjectId("5becaea2ed34096eb0cbd989"), "item" : "paper", "qty" : 100, "tags" : [ "red", "blank", "plain" ], "dim_cm" : [ 14, 21 ] }
{ "_id" : ObjectId("5beceefd1f95e45bd804aa0c"), "item" : "paper", "qty" : 100, "size" : { "h" : 8.5, "w" : 11, "uom" : "in" }, "status" : "D" }
>

#更新多条
> db.inventory.find({"qty": { $lt: 50 }})
{ "_id" : ObjectId("5becace359a0aba12c9c320c"), "item" : "journal", "qty" : 25, "size" : { "h" : 14, "w" : 21, "uom" : "cm" }, "status" : "A" }
{ "_id" : ObjectId("5becace359a0aba12c9c3210"), "item" : "postcard", "qty" : 45, "size" : { "h" : 10, "w" : 15.25, "uom" : "cm" }, "status" : "A" }
{ "_id" : ObjectId("5becaea2ed34096eb0cbd987"), "item" : "journal", "qty" : 25, "tags" : [ "blank", "red" ], "dim_cm" : [ 14, 21 ] }
{ "_id" : ObjectId("5becaea2ed34096eb0cbd98b"), "item" : "postcard", "qty" : 45, "tags" : [ "blue" ], "dim_cm" : [ 10, 15.25 ] }
{ "_id" : ObjectId("5beceefd1f95e45bd804aa08"), "item" : "journal", "qty" : 25, "size" : { "h" : 14, "w" : 21, "uom" : "cm" }, "status" : "A" }
{ "_id" : ObjectId("5beceefd1f95e45bd804aa0a"), "item" : "mousepad", "qty" : 25, "size" : { "h" : 19, "w" : 22.85, "uom" : "cm" }, "status" : "P" }
{ "_id" : ObjectId("5beceefd1f95e45bd804aa0e"), "item" : "postcard", "qty" : 45, "size" : { "h" : 10, "w" : 15.25, "uom" : "cm" }, "status" : "A" }
> 
> db.inventory.update(
...    { "qty": { $lt: 50 } },
...    {
...      $set: { "size.uom": "in", status: "P" },
...      $currentDate: { lastModified: true }
...    },
...    { multi: true }
... )

#updateMany也可以更新多条
> db.inventory.updateMany(
...    { "qty": { $lt: 50 } },
...    {
...      $set: { "size.uom": "in", status: "P" },
...      $currentDate: { lastModified: true }
...    }
... )
{ "acknowledged" : true, "matchedCount" : 7, "modifiedCount" : 7 }
> 
> db.inventory.find({"qty": { $lt: 50 }})
{ "_id" : ObjectId("5becace359a0aba12c9c320c"), "item" : "journal", "qty" : 25, "size" : { "h" : 14, "w" : 21, "uom" : "in" }, "status" : "P", "lastModified" : ISODate("2018-11-15T04:06:56.192Z") }
{ "_id" : ObjectId("5becace359a0aba12c9c3210"), "item" : "postcard", "qty" : 45, "size" : { "h" : 10, "w" : 15.25, "uom" : "in" }, "status" : "P", "lastModified" : ISODate("2018-11-15T04:06:56.192Z") }
{ "_id" : ObjectId("5becaea2ed34096eb0cbd987"), "item" : "journal", "qty" : 25, "tags" : [ "blank", "red" ], "dim_cm" : [ 14, 21 ], "lastModified" : ISODate("2018-11-15T04:06:56.193Z"), "size" : { "uom" : "in" }, "status" : "P" }
{ "_id" : ObjectId("5becaea2ed34096eb0cbd98b"), "item" : "postcard", "qty" : 45, "tags" : [ "blue" ], "dim_cm" : [ 10, 15.25 ], "lastModified" : ISODate("2018-11-15T04:06:56.193Z"), "size" : { "uom" : "in" }, "status" : "P" }
{ "_id" : ObjectId("5beceefd1f95e45bd804aa08"), "item" : "journal", "qty" : 25, "size" : { "h" : 14, "w" : 21, "uom" : "in" }, "status" : "P", "lastModified" : ISODate("2018-11-15T04:06:56.193Z") }
{ "_id" : ObjectId("5beceefd1f95e45bd804aa0a"), "item" : "mousepad", "qty" : 25, "size" : { "h" : 19, "w" : 22.85, "uom" : "in" }, "status" : "P", "lastModified" : ISODate("2018-11-15T04:06:56.193Z") }
{ "_id" : ObjectId("5beceefd1f95e45bd804aa0e"), "item" : "postcard", "qty" : 45, "size" : { "h" : 10, "w" : 15.25, "uom" : "in" }, "status" : "P", "lastModified" : ISODate("2018-11-15T04:06:56.193Z") }

#替换第一个结果的整个文档
> db.users.find({ name: "xyz" })
{ "_id" : 5, "name" : "xyz", "age" : 23, "type" : 2, "status" : "D", "favorites" : { "artist" : "Noguchi", "food" : "nougat" }, "finished" : [ 14, 6 ], "badges" : [ "orange" ], "points" : [ { "points" : 71, "bonus" : 20 } ] }
> db.users.update(
...    { name: "xyz" },
...    { name: "mee", age: 25, type: 1, status: "A", favorites: { "artist": "Matisse", food: "mango" } }
... )
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })
> db.users.find({ name: "mee" })
{ "_id" : 5, "name" : "mee", "age" : 25, "type" : 1, "status" : "A", "favorites" : { "artist" : "Matisse", "food" : "mango" } }
> 

> db.inventory.find({item: "paper"})
{ "_id" : ObjectId("5becace359a0aba12c9c320e"), "item" : "paper", "qty" : 100, "size" : { "h" : 8.5, "w" : 11, "uom" : "cm" }, "status" : "P", "lastModified" : ISODate("2018-11-15T04:02:31.385Z") }
{ "_id" : ObjectId("5becaea2ed34096eb0cbd989"), "item" : "paper", "qty" : 100, "tags" : [ "red", "blank", "plain" ], "dim_cm" : [ 14, 21 ] }
{ "_id" : ObjectId("5beceefd1f95e45bd804aa0c"), "item" : "paper", "qty" : 100, "size" : { "h" : 8.5, "w" : 11, "uom" : "in" }, "status" : "D" }
> 
> 
> db.inventory.replaceOne(
...    { item: "paper" },
...    { item: "paper", instock: [ { warehouse: "A", qty: 60 }, { warehouse: "B", qty: 40 } ] }
... )
{ "acknowledged" : true, "matchedCount" : 1, "modifiedCount" : 1 }
> db.inventory.find({item: "paper"})
{ "_id" : ObjectId("5becace359a0aba12c9c320e"), "item" : "paper", "instock" : [ { "warehouse" : "A", "qty" : 60 }, { "warehouse" : "B", "qty" : 40 } ] }
{ "_id" : ObjectId("5becaea2ed34096eb0cbd989"), "item" : "paper", "qty" : 100, "tags" : [ "red", "blank", "plain" ], "dim_cm" : [ 14, 21 ] }
{ "_id" : ObjectId("5beceefd1f95e45bd804aa0c"), "item" : "paper", "qty" : 100, "size" : { "h" : 8.5, "w" : 11, "uom" : "in" }, "status" : "D" }
```



# 删除文档 db.collection.remove()
```bash
#删除集合
db.inventory.drop() 
#清空集合内所有文档      
db.inventory.remove({})

#删除除所有{status: "D"}的文档
> db.users.find({status: "D"})
{ "_id" : ObjectId("5beca73c59a0aba12c9c3209"), "name" : "xi", "age" : 34, "status" : "D" }
{ "_id" : 4, "name" : "xi", "age" : 34, "type" : 2, "status" : "D", "favorites" : { "artist" : "Chagall", "food" : "chocolate" }, "finished" : [ 5, 11 ], "badges" : [ "Picasso", "black" ], "points" : [ { "points" : 53, "bonus" : 15 }, { "points" : 51, "bonus" : 15 } ] }

> db.users.remove({status: "D"})
WriteResult({ "nRemoved" : 2 })  

#删除第一条
> db.users.find({status: "A"})
{ "_id" : ObjectId("5beca73c59a0aba12c9c3207"), "name" : "bob", "age" : 42, "status" : "A" }
{ "_id" : ObjectId("5beca73c59a0aba12c9c3208"), "name" : "ahn", "age" : 22, "status" : "A" }
{ "_id" : 2, "name" : "bob", "age" : 42, "type" : 1, "status" : "A", "favorites" : { "artist" : "Miro", "food" : "meringue" }, "finished" : [ 11, 25 ], "badges" : [ "green" ], "points" : [ { "points" : 85, "bonus" : 20 }, { "points" : 64, "bonus" : 12 } ] }
{ "_id" : 3, "name" : "ahn", "age" : 22, "type" : 2, "status" : "A", "favorites" : { "artist" : "Cassatt", "food" : "cake" }, "finished" : [ 6 ], "badges" : [ "blue", "Picasso" ], "points" : [ { "points" : 81, "bonus" : 8 }, { "points" : 55, "bonus" : 20 } ] }
{ "_id" : 5, "name" : "mee", "age" : 25, "type" : 1, "status" : "A", "favorites" : { "artist" : "Matisse", "food" : "mango" } }

> db.users.remove({status: "A"},1)     #等同db.users.deleteOne({status: "A"})
WriteResult({ "nRemoved" : 1 })

> db.users.find({status: "A"})
{ "_id" : ObjectId("5beca73c59a0aba12c9c3208"), "name" : "ahn", "age" : 22, "status" : "A" }
{ "_id" : 2, "name" : "bob", "age" : 42, "type" : 1, "status" : "A", "favorites" : { "artist" : "Miro", "food" : "meringue" }, "finished" : [ 11, 25 ], "badges" : [ "green" ], "points" : [ { "points" : 85, "bonus" : 20 }, { "points" : 64, "bonus" : 12 } ] }
{ "_id" : 3, "name" : "ahn", "age" : 22, "type" : 2, "status" : "A", "favorites" : { "artist" : "Cassatt", "food" : "cake" }, "finished" : [ 6 ], "badges" : [ "blue", "Picasso" ], "points" : [ { "points" : 81, "bonus" : 8 }, { "points" : 55, "bonus" : 20 } ] }
{ "_id" : 5, "name" : "mee", "age" : 25, "type" : 1, "status" : "A", "favorites" : { "artist" : "Matisse", "food" : "mango" } }
```













