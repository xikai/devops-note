* https://docs.mongodb.com/manual/tutorial/deploy-shard-cluster/

# 主机列表(2个shard，3个replica(一主两从))
shard1 | shard2 | config server | mongos
---|---|---|---
192.168.140.101:27001 | 192.168.140.101:27002 | 192.168.140.101:27000 | 192.168.140.101:27017
192.168.140.102:27001 | 192.168.140.102:27002 | 192.168.140.102:27000 | 192.168.140.102:27017
192.168.140.103:27001 | 192.168.140.103:27002 | 192.168.140.103:27000 | 192.168.140.103:27017

>部署mongodb,参考mongodb安装文档

* 创建数据日志目录
```
mkdir -p /data/mongodb/{configsvr,shard1,shard2}
mkdir -p /data/mongodb/logs
chown -R mongo.mongo /data/mongodb
chown -R mongo.mongo /usr/local/mongodb
```

# [部署config servers复制集](https://docs.mongodb.com/manual/reference/configuration-options/)
>vim /usr/local/mongodb/conf/configsvr.conf
```
processManagement:
  fork: true
net:
  port: 27000
  bindIp: 0.0.0.0
storage:
  dbPath: /data/mongodb/configsvr
systemLog:
  destination: file
  path: "/data/mongodb/logs/configsvr.log"
  logAppend: true
sharding:
  clusterRole: configsvr
replication:
  replSetName: "rs_configsvr"
security:
  keyFile: /usr/local/mongodb/conf/keyfile
```
* 启动config servers
```
/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/conf/configsvr.conf
```

* 初始化config servers复制集，在其中一个节点
```
/usr/local/mongodb/bin/mongo --port 27000
```
```
rs.initiate(
  {
    _id: "rs_configsvr",
    configsvr: true,
    members: [
      { _id : 0, host : "192.168.140.101:27000" },
      { _id : 1, host : "192.168.140.102:27000" },
      { _id : 2, host : "192.168.140.103:27000" }
    ]
  }
)
```
* 查看副本集状态
```
rs.status()
```

# 部署分片复制集(shard1、shard2)
* 部署shard1
>vim /usr/local/mongodb/conf/shard1.conf
```
processManagement:
  fork: true
net:
  bindIp: 192.168.140.101,127.0.0.1
  port: 27001
storage:
  dbPath: /data/mongodb/shard1
systemLog:
  destination: file
  path: "/data/mongodb/logs/shard1.log"
  logAppend: true
sharding:
  clusterRole: shardsvr
replication:
  replSetName: "rs_shard1"
security:
  keyFile: /usr/local/mongodb/conf/keyfile
```

* 启动shard1
```
/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/conf/shard1.conf
```

* 初始化shard1复制集，在其中一个节点
```
/usr/local/mongodb/bin/mongo --port 27001
```
```
rs.initiate(
  {
    _id: "rs_shard1",
    members: [
      { _id : 0, host : "192.168.140.101:27001" },
      { _id : 1, host : "192.168.140.102:27001" },
      { _id : 2, host : "192.168.140.103:27001" }
    ]
  }
)
```
* 查看副本集状态
```
rs.status()
```

### 部署shard2 -> 同上，修改对应配置和IP

# 部署mongos连接config servers复制集
>vim /usr/local/mongodb/conf/mongos.yaml
```
processManagement:
  fork: true
net:
  bindIp: 192.168.140.101,127.0.0.1
  port: 27017
storage:
  dbPath: /data/mongodb/mongos
systemLog:
  destination: file
  path: "/data/mongodb/logs/mongos.log"
  logAppend: true
sharding:
  configDB: rs_configsvr/192.168.140.101:27000,192.168.140.102:27000,192.168.140.103:27000"
security:
  keyFile: /usr/local/mongodb/conf/keyfile
```
* 启动mongos
```
/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/conf/mongos.yaml
```

* 增加分片到集群
```
/usr/local/mongodb/bin/mongo
```
```
use admin
sh.addShard("shard1/192.168.140.101:27001,192.168.140.102:27001")
sh.addShard("shard2/192.168.140.101:27002,192.168.140.102:27002")
```

* 创建用户名和密码
```
mongo --port 30000
> use admin
> db.createUser({user:"family",pwd:"WIN2net",roles:["root"]})
> db.auth('family','WIN2net')
```

* 对数据库开启分片
```
sh.enableSharding("testdb")
```

* 集合分片
```
# Hashed Sharding
sh.shardCollection("testdb.table1", {id : "hashed"})

# Ranged Sharding
sh.shardCollection("testdb.table1", {id : 1}) 
```


# 测试
* If the collection already contains data, you must create an index on the shard key using the db.collection.createIndex() method before using shardCollection().
```
mongo 127.0.0.1:27017
```
```
#使用testdb
use testdb;
#插入测试数据
for (var i = 1; i <= 10000; i++) {db.table1.save({id:i,"test1":"testval1"})};


#查看分片情况如下，部分无关信息省掉了
db.table1.stats();
{
   "sharded" : true,
    "ns" : "testdb.table1",
    "count" : 10000,
    "numExtents" : 13,
    "size" : 5600000,
    "storageSize" : 22372352,
    "totalIndexSize" : 6213760,
    "indexSizes" : {
       "_id_" : 3335808,
       "id_1" : 2877952
    },
    "avgObjSize" : 56,
    "nindexes" : 2,
    "nchunks" : 3,
    "shards" : {
       "shard1" : {
            "ns" : "testdb.table1",
            "count" : 42183,
            "size" : 0,
            ...
            "ok" : 1
         },
        "shard2" : {
            "ns" : "testdb.table1",
            "count" : 38937,
            "size" : 2180472,
            ...
            "ok" : 1
         }
     },
    "ok" : 1
}
# 可以看到数据分到2个分片，各自分片数量为： shard1 “count” : 42183，shard2 “count” : 38937已经成功了！
```


# 分片管理
```
sh.status()      查看集群摘要信息

use config
db.shards.findOne()    跟踪记录集群内所有分片信息
db.databases.find()    跟踪记录集群中所有数据库信息
db.collections.findOne()   跟踪记录有所有分片集合的信息

db.adminCommand({"connPoolStats" : 1})    查看mongos和mongodb之间的连接信息

增加分片
在mongos上运行addShard()，参数中指定副本集名称和主机名

删除分片(不建议删除分片)
db.adminCommand({"removeShard" : "test-rs3"})
```