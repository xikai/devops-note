### 主机列表
shard1 | shard2 | shard3 | config server | mongos
---|---|---|---|---
192.168.140.101:27001 | 192.168.140.101:27002 | 192.168.140.101:27003 | 192.168.140.101:27019 | 192.168.140.104:27017
192.168.140.102:27001 | 192.168.140.102:27002 | 192.168.140.102:27003 | 192.168.140.102:27019 |
192.168.140.103:27001 | 192.168.140.103:27002 | 192.168.140.103:27003 | 192.168.140.103:27019 |

>部署mongodb,参考mongodb安装文档

* 创建数据日志目录
```
mkdir -p /data/mongodb/{configsvr,shard1,shard2,shard3}
mkdir -p /data/mongodb/logs
chown -R mongo.mongo /data/mongodb
chown -R mongo.mongo /usr/local/mongodb
```

### 部署config servers复制集
>vim mongodb_configsvr.conf
```
processManagement:
   fork: true
net:
   bindIp: 192.168.140.101,127.0.0.1
   port: 27019
storage:
   dbPath: /data/mongodb/configsvr
systemLog:
   destination: file
   path: "/data/mongodb/logs/mongodb_configsvr.log"
   logAppend: true
sharding:
   clusterRole: configsvr
replication:
   replSetName: "rs_cfg"
```
* 启动config servers
```
/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/mongodb_configsvr.conf
```

* 初始化config servers，在其中一个节点
>/usr/local/mongodb/bin/mongo --port 27019
```
rs.initiate(
  {
    _id: "rs_cfg",
    configsvr: true,
    members: [
      { _id : 0, host : "192.168.140.101:27019" },
      { _id : 1, host : "192.168.140.102:27019" },
      { _id : 2, host : "192.168.140.103:27019" }
    ]
  }
)
```

### 部署分片复制集(shard1、shard2、shard3)
>vim mongodb_shardX.conf
```
processManagement:
   fork: true
net:
   bindIp: 192.168.140.101,127.0.0.1
   port: 2700X
storage:
   dbPath: /data/mongodb/shardX
systemLog:
   destination: file
   path: "/data/mongodb/logs/mongodb_shardX.log"
   logAppend: true
sharding:
   clusterRole: shardsvr
replication:
   replSetName: "rs_shardX"
```

* 启动shard servers
```
/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/mongodb_shardX.conf
```
* **部署其它机器同上，修改对应配置IP**

* 初始化shardX servers，在其中一个节点
>/usr/local/mongodb/bin/mongo --port 2700X
```
rs.initiate(
  {
    _id: "rs_shard1",
    configsvr: true,
    members: [
      { _id : 0, host : "192.168.140.101:2700X" },
      { _id : 1, host : "192.168.140.102:2700X" },
      { _id : 2, host : "192.168.140.103:2700X" }
    ]
  }
)
```

### 部署mongos连接config servers复制集
>vim mongodb_mongos.conf
```
processManagement:
   fork: true
net:
   bindIp: 192.168.140.104,127.0.0.1
   port: 27017
storage:
   dbPath: /data/mongodb/data
systemLog:
   destination: file
   path: "/data/mongodb/logs/mongodb.log"
   logAppend: true
sharding:
   configDB: rs_cfg/192.168.140.101:27019,192.168.140.102:27019,192.168.140.103:27019"
```
* 启动mongos
```
/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/mongodb_mongos.conf
```

* 增加分片到集群
>/usr/local/mongodb/bin/mongo
```
use admin
sh.addShard("shard1/192.168.140.101:27001,192.168.140.102:27001,192.168.140.103:27001")
sh.addShard("shard2/192.168.140.101:27002,192.168.140.102:27002,192.168.140.103:27002")
sh.addShard("shard3/192.168.140.101:27003,192.168.140.102:27003,192.168.140.103:27003")
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


### 测试
* If the collection already contains data, you must create an index on the shard key using the db.collection.createIndex() method before using shardCollection().

>mongo 127.0.0.1:27017
```
#使用testdb
use testdb;
#插入测试数据
for (var i = 1; i <= 10000; i++) {db.table1.save({id:i,"test1":"testval1"})};


#查看分片情况如下，部分无关信息省掉了
db.table1.stats();
{"sharded" : true,
        "ns" : "testdb.table1",
        "count" : 10000,
        "numExtents" : 13,
        "size" : 5600000,
        "storageSize" : 22372352,
        "totalIndexSize" : 6213760,
        "indexSizes" : {"_id_" : 3335808,
                "id_1" : 2877952
        },
        "avgObjSize" : 56,
        "nindexes" : 2,
        "nchunks" : 3,
        "shards" : {"shard1" : {"ns" : "testdb.table1",
                        "count" : 42183,
                        "size" : 0,
                        ...
                        "ok" : 1
                },
                "shard2" : {"ns" : "testdb.table1",
                        "count" : 38937,
                        "size" : 2180472,
                        ...
                        "ok" : 1
                },
                "shard3" : {"ns" : "testdb.table1",
                        "count" :18880,
                        "size" : 3419528,
                        ...
                        "ok" : 1
                }},
        "ok" : 1
}
# 可以看到数据分到3个分片，各自分片数量为： shard1 “count” : 42183，shard2 “count” : 38937，shard3 “count” : 18880。已经成功了！
```


### 分片管理
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