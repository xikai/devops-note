* 分片是指将数据拆分存放在不同的机器上。不需要功能强大的大型计算机就可以存储更多数据，处理更大的负载。生产环境至少应该创建3个及以上的分片服务器

### 组件介绍
* **shard**
  - 每个分片是完整数据的一个子集，可以为每个分片部署一个复制集
  - mongodb在集合级别将数据分片,使用shard key
* **mongos**
  - mongos充当查询路由器，为客户端提供连接shard的接口
* **config servers**
  - 配置服务器存储集群的元数据和配置设置。配置服务器必须被部署为一个复制集

### 架构图
![image](https://docs.mongodb.com/v3.6/_images/sharded-cluster-production-architecture.bakedsvg.svg)

### 连接一个混合分片集群（包含分片的集合和未分片的集合）
* 客户端不应该直接连接一个单独分片服务器读写
![image](https://docs.mongodb.com/v3.6/_images/sharded-cluster-mixed.bakedsvg.svg)

### Shard Keys
https://blog.csdn.net/wenniuwuren/article/details/52945137
* Shard keys 是collection中的一个字段 Mongo DB用这个keys来对数据进行分片存放到集群中的各个shard节点的chunk上
  - 分片键确定集合文档在集群分片中的分布
  - 分片键可以是集合文档中的单索引或者是混合索引
  - MongoDB 使用分片键值的范围在集合中分区数据
  - 每个范围定义一个分片键值不重叠并且关联一个块
![image](https://docs.mongodb.com/v3.6/_images/sharding-range-based.bakedsvg.svg)

* 一旦对一个集合分片，分片键和分片值就不可改变。   
  - 不能给集合选择不同的分片键
  - 不能更新分片键的值。

* 分片键规范
```
sh.shardCollection( namespace, key )
#namespace 由<database>.<collection>组成，指定目标集合完整的命名空间
#key 包含一个字段的文档或索引遍历方向的文档
```

### 分片策略
* Hashed Sharding（推荐）
  - Hashed分片使用单个字段的Hashed索引作为分片键，在您的分片集群中对数据进行分片
  - Hashed Sharding提供更均匀的数据分布

* Ranged Sharding
  - MongoDB使用片键的范围把数据分布在分片中,每个范围,又称为数据块


### Zone
- 我们可以按照 shard key 对数据进行分组，每一组称为一个Zone,之后把 Zone 在分配给不同的 Shard 服务器
- 一个 Shard 可以存储一个或多个非冲突的Zone

* 分片集群数据结构
    * cluster:
    	- shard1:
    	    - zone:
                - chunk
                - chunk
        - shard2
        - shard3

* Zone分片架构
![image](https://www.mongoing.com/docs/_images/sharded-cluster-zones.png)

* balancer 
  - 均衡器试图在集群的每个一分片上，均匀的分布集合的chunk
  - 在均衡过程中，如果均衡器检测到任何违背已配置区域上给定的分片，均衡器将会把这些数据块迁移到不存在冲突的分片上

* 增加分片到Zone
```
sh.addShardTag("shard0000", "NYC")
sh.addShardTag("shard0001", "NYC")
sh.addShardTag("shard0002", "SFO")
sh.addShardTag("shard0002", "NRT")
```

* 删除Zone从分片
```
sh.removeShardTag("shard0002", "NRT")
```

* 创建Zone范围
  - 例如：给records.users集合分片，通过zipcode字段
  ```
  sh.addTagRange("records.users", { zipcode: "10001" }, { zipcode: "10281" }, "NYC")
  sh.addTagRange("records.users", { zipcode: "11201" }, { zipcode: "11240" }, "NYC")
  sh.addTagRange("records.users", { zipcode: "94102" }, { zipcode: "94135" }, "SFO")
  ```
* 删除Zone范围
```
use config
db.tags.remove({ _id: { ns: "records.users", min: { zipcode: "10001" }}, tag: "NYC" })
```

* 查看存在的Zone
```
use config
db.shards.find({ tags: "NYC" })

#返回所有范围在"NYC"的Zone
db.tags.find({ tags: "NYC" })
```