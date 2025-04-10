* https://docs.mongoing.com/
* https://docs.mongodb.com/manual/tutorial/getting-started/
* https://www.cnblogs.com/clsn/p/8214345.html#auto_id_22

* [docker-compose 复制集](https://blog.csdn.net/biao0309/article/details/87641272)


* 数据库备份，-d指定数据库(不指定表示备份所有数据库) -o指定存储备份的目录
```
/usr/local/mongodb/bin/mongodump -d test -o /backup
```
* 数据库恢复，--drop恢复前删除集合(若存在)，否则会与现有的集合数据合并
```
/usr/local/mongodb/bin/mongorestore -d test --drop /backup/test
```

* 修复数据库
```
db.repairDatabase()
```

* 查询解释explain
```
db.inventory.find(
   { quantity: { $gte: 100, $lte: 200 } }
).explain("executionStats")
```
* 增加索引
```
db.inventory.createIndex( { quantity: 1 } )
```