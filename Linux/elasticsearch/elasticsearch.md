* https://www.elastic.co/guide/index.html#viewall
* https://www.elastic.co/guide/cn/elasticsearch/guide/current/distributed-cluster.html
* https://mp.weixin.qq.com/s/y8DNnj4fjiS3Gqz2DFik8w?spm=a2c6h.12873639.0.0.135365aeF1zJoB
* https://www.zhihu.com/question/327209680

# es集群
* 集群是由一个或者多个拥有相同 cluster.name 配置的节点组成， 它们共同承担数据和负载的压力。当有节点加入集群中或者从集群中移除节点时，集群将会重新平均分布所有的数据。Elasticsearch 默认被配置为使用单播发现，以防止节点无意中加入集群。
* [Zen Discovery](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/modules-discovery-zen.html) 是 Elasticsearch 的内置默认发现模块（发现模块的职责是发现集群中的节点以及选举 Master 节点）。Zen Discovery 与其他模块集成，例如，节点之间的所有通信都使用 Transport 模块完成。节点使用发现机制通过 Ping 的方式查找其他节点。Elasticsearch 默认被配置为使用单播发现，以防止节点无意中加入集群。
* 选举，先从各节点认为的 Master 中选，按照 ID 的字典序排序，取第一个。如果各节点都没有认为的 Master ，则从所有节点中选择，规则同上。discovery.zen.minimum_master_nodes ，如果节点数达不到最小值的限制，则循环上述过程，直到节点数足够可以开始选举
* 脑裂: 同时如果由于网络或其他原因导致集群中选举出多个 Master 节点，使得数据更新时出现不一致，这种现象称之为脑裂，即集群中不同的节点对于 Master 的选择出现了分歧，出现了多个 Master 竞争。

### ES集群角色
* master节点
```
node.master=true 表示此节点具有被选举为主节点的资格。默认true候选主节点
主节点负责创建索引、删除索引、跟踪哪些节点是群集的一部分，并决定哪些分片分配给哪些节点、更新集群状态等，稳定的主节点对集群的健康是非常重要的。
而主节点并不需要涉及到文档级别的变更和搜索等操作，所以当集群只拥有一个主节点的情况下，即使流量的增加它也不会成为瓶颈。
```
* data节点
```
node.data=true 表示此节点为数据节点，负责数据的存储和相关的操作，例如对数据进行增、删、改、查和聚合等操作，所以数据节点（Data 节点）对机器配置要求比较高，对 CPU、内存和 I/O 的消耗很大。
```
* ingest节点
  - 我们可以将请求发送到 集群中的任何节点，并由该节点负责分发请求、收集结果等操作，而不需要主节点转发。这种节点可称之为协调节点，协调节点是不需要指定和配置的，集群中的任何节点都可以充当协调节点的角色。
  - 当发送请求的时候， 为了扩展负载，更好的做法是轮询集群中所有的节点
```
# 如果某个节点既是数据节点又是主节点，那么可能会对主节点产生影响从而对整个集群的状态产生影响。我们应该对 Elasticsearch 集群中的节点做好角色上的划分和隔离。配置文件中给出了三种配置高性能集群拓扑结构的模式,如下： 
1. 如果你想让节点从不选举为主节点,只用来存储数据,可作为负载器 
node.master: false 
node.data: true 
2. 如果想让节点成为主节点,且不存储任何数据,并保有空闲资源,可作为协调器
node.master: true
node.data: false
3. 如果想让节点既不称为主节点,又不成为数据节点,那么可将他作为搜索器,从节点中获取数据,生成搜索结果等 
node.master: false 
node.data: false
```

### 集群结构
* 索引
  - 索引实际上是指向一个或者多个物理 分片 的 逻辑命名空间。但是应用程序是直接与索引而不是与分片进行交互。
* 分片 
  - 分片是数据的容器，文档保存在分片内，分片又被分配到集群内的各个节点里。集群中我们的文档被存储和索引到分片内，不过对于客户端来说分片是透明的，他们感知不到分片的存在。
  - 当你的集群规模扩大或者缩小时， Elasticsearch 会自动的在各节点中迁移分片，使得数据仍然均匀分布在集群里。
  - 一个分片可以是 主 分片或者 副本 分片。 索引内任意一个文档都归属于一个主分片，所以主分片的数目决定着索引能够保存的最大数据量。
  - ES中有两种类型的分片：主分片（primary shard）、副本分片（replicas）。一个副本分片只是一个主分片的拷贝，副本分片主要是用来实现高可用、高并发的。所有数据都要先写到主分片上，主分片等待所有副本完成数据更新后才返回客户端。
  - 在一个多分片的索引中写入数据时，通过路由公式来确定具体写入哪一个分片中，所以在创建索引的时候需要指定分片的数量，并且分片的数量一旦确定就不能修改
    ```
    shard = hash(routing) % number_of_primary_shards
    ```
    - routing 是一个可变值，默认是文档的 _id ，也可以设置成一个自定义的值。 routing 通过 hash 函数生成一个数字，然后这个数字再除以 number_of_primary_shards （主分片的数量）后得到 余数 。这个分布在 0 到   number_of_primary_shards-1 之间的余数，就是我们所寻求的文档所在分片的位置。
    - 我们要在创建索引的时候就确定好主分片的数量 并且永远不会改变这个数量：因为如果数量变化了，那么所有之前路由的值都会无效，文档也再也找不到了。所以在创建索引的时候合理的预分配分片数是很重要的。

* Segment：索引文档以段（Segment）的形式存储在磁盘上，索引文件被拆分为多个子文件，则每个子文件叫作段，每一个段上都存储的是倒排索引信息。
* Refresh：在 Elasticsearch 中，写入和打开一个新段的轻量的过程叫做 refresh 。 默认情况下每个分片会每秒自动刷新一次。注意新的段（Segment）目前处于操作系统的文件的缓存系统中(在Elasticsearch和磁盘之间是文件系统缓  存)，而不是磁盘上。但新的段（Segment）中的数据是可以被检索到的。并清空内存缓冲区。
* Segment合并：由于自动刷新流程每秒会创建一个新的段 ，这样会导致短时间内的段数量暴增。每一个段都会消耗文件句柄、内存和cpu运行周期。更重要的是，每个搜索请求都必须轮流检查每个段；所以段越多，搜索也就越慢。所以为了控制索引里段的数量，必须定期进行Segment合并操作。Elasticsearch通过在后台进行段合并来解决这个问题。小的段被合并到大的段，然后这些大的段再被合并到更大的段。
* Translog：通过延时写的策略可以减少数据往磁盘上写的次数，从而提升了整体的写入能力，但是文件缓存系统属于操作系统的内存，只要是内存都存在断电或异常情况下丢失数据的危险。为了避免丢失数据，Elasticsearch 添加了事务日志  （Translog），事务日志记录了所有还没有持久化到磁盘的数据。
* Flush： 当日志数据（Translog）的大小超过 512MB 或者时间超过 30 分钟时，需要触发一次Flush，将文件系统缓存系统中的数据新的段（Segment）刷新到硬盘中。生成提交点。删除旧的事务日志（Translog），创建一个空的事务日  志（Translog）,当断电或需要重启时，ES 不仅要根据提交点去加载已经持久化过的段，还需要工具 Translog 里的记录，把未持久化的数据重新持久化到磁盘上，避免了数据丢失的可能。

### 写操作
  1. 当有数据写入ES时，为了提升写入的速度，并没有将数据直接写在磁盘上，而是先写入到内存中，但是为了防止数据的丢失，会追加一份数据到事务日志(Translog)。
  2. 不断有新的文档被写入到内存，同时也都会记录到事务日志中。这时新数据还不能被检索和查询。
  3. 当达到默认的刷新时间1s或内存中的数据达到一定量(es的jvm内存)后，会触发一次 (Refresh)，将内存中的数据以一个新段（Segment）形式刷新到文件缓存系统中并清空内存。这时虽然新段未被提交到磁盘，但是可以提供文档的检索功能且不能被修改。
  4. 随着新文档索引不断被写入文件缓存系统，当数据大小超过 512M 或者时间超过 30 分钟时，会触发一次(Flush)。
  5. 文件系统缓存中数据通过 Fsync 刷新到磁盘中，生成提交点，事务日志文件被删除，创建一个空的新事务日志。

### 读操作
  - 节点收到读请求，会根据路由公式计算出数据存储在哪个分片上，以负载均衡的方式选择一个副本（在处理读取请求时，协调节点在每次请求的时候都会通过轮询所有的副本分片来达到负载均衡），然后将读请求转发到该分片节点上，处理完后再返回给收到请求的节点再返回给客户端。


# [安装elasticsearch](https://mp.weixin.qq.com/s/y8DNnj4fjiS3Gqz2DFik8w?spm=a2c6h.12873639.0.0.135365aeF1zJoB)
* 下载
```
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.6.16.tar.gz
tar -xzf elasticsearch-5.6.16.tar.gz
cd elasticsearch-5.6.16/ 
./bin/elasticsearch -d  #Running as a daemon
```

* 配置elasticsearch
```
groupadd es
useradd -g es es
mkdir -p /data/elasticsearch/{data,logs}
chown -R es.es /data/elasticsearch
chown -R es.es /usr/local/elasticsearch
```

* vim config/elasticsearch.yml
```
cluster.name: es-test
node.name: es01
path.data: /data/elasticsearch/data
path.logs: /data/elasticsearch/logs
bootstrap.memory_lock: false
network.host: 0.0.0.0
http.port: 9400
transport.tcp.port: 9500
# 单播发现，加入集群
discovery.zen.ping.unicast.hosts: ["es01:9500", "es02:9500", "es03:9500"]
# 参与选举的候选主节点数，不小于这个数才能触发选举（官方建议取值：候选主节点个数/2)+1，以防止脑裂）
# 避免集群中只有2个候选主节点（如果一个节点出现问题，另一个节点的同意人数最多只能为1，永远也不能选举出新的主节点，这时就发生了脑裂现象）
discovery.zen.minimum_master_nodes: 2 
```

* vim /usr/lib/systemd/system/es.service
```
[Unit]
Description=elasticsearch

[Service]
#User=elasticsearch
#Group=elasticsearch
ExecStart=/usr/bin/su - es -c '/usr/local/elasticsearch/bin/elasticsearch'
LimitMEMLOCK=infinity

Restart=on-failure

[Install]
WantedBy=multi-user.target
```
```
systemctl daemon-reload
systemctl start elasticsearch
```

# 集群管理
### 检查集群健康状态
```
curl localhost:9200/_cluster/health?pretty
curl localhost:9200/_cat/health?v
```
* 查看集群挂起的任务(e.g. create index, update mapping, allocate or fail shard)
```
curl -XGET 'http://localhost:9200/_cluster/pending_tasks'
```
* 查看线程池
```
curl -XGET 'localhost:9200/_cat/thread_pool?v'
```

### 查询集群节点信息、状态
```
#列出node节点
curl -XGET "http://localhost:9200/_cat/nodes"

#查询节点信息
curl -XGET 'http://localhost:9200/_nodes?pretty'
curl -XGET 'http://localhost:9200/_nodes/nodeId1,nodeId2?pretty'
#查询节点状态
curl -XGET 'http://localhost:9200/_nodes/stats?pretty'
curl -XGET 'http://localhost:9200/_nodes/nodeId1,nodeId2/stats?pretty'

# 获取集群节点的热线程
curl -XGET 'localhost:9200/_nodes/hot_threads'
curl -XGET 'localhost:9200/_nodes/nodeId1,nodeId2/hot_threads'
```

### 列出集群索引
```
curl -XGET "localhost:9200/_cat/indices?v"
```

#查看集群指定索引健康状态
```
curl localhost:9200/_cluster/health/test1,test2?pretty
```

* 手动迁移/分配单个分片到指定节点
>在处理任何重路由命令后，Elasticsearch将像正常一样执行再平衡
```
# 使用参数?dry_run测试命令运行结果，命令并不会实际被执行
curl -X POST "localhost:9200/_cluster/reroute?pretty" -H 'Content-Type: application/json' -d'
{
    "commands" : [
        {
          "move" : { #将已启动的分片从一个节点移动到另一个节点
            "index" : "test", "shard" : 0,
            "from_node" : "node1", "to_node" : "node2"
          }
        },
        {
          "allocate_replica" : {  #将未分配的分片分配给节点
            "index" : "test", 
            "shard" : 1,
            "node" : "node3"
          }
        }
    ]
}'
```

* 查询索引分片信息
```
curl http://localhost:9200/_cat/shards?v
curl http://localhost:9200/_cat/shards/my_index?v
```

* 查询索引中分片的segments
```
#查看所有索引分片的段
curl -XGET 'localhost:9200/_cat/segments'
#查看指定索引分片的段
curl -XGET 'localhost:9200/_cat/segments/my_index1,myindex2'
```

# 集群设置
```
# 查看集群设置
curl http://localhost:9200/_cluster/settings?pretty
```
* 分片自动重平衡
```
# 关闭分片平衡迁移
curl -XPUT http://localhost:9200/_cluster/settings -d '{
    "transient" : {
        "cluster.routing.allocation.enable" : "none"
    }
}'

# 开启分片平衡迁移
curl -XPUT http://localhost:9200/_cluster/settings -d '{
    "transient" : {
        "cluster.routing.allocation.enable" : "all"
    }
}'
```

* 分片不分配到指定节点
```
# 设置不分配分片到指定IP的节点
curl -XPUT "http://localhost:9200/_cluster/settings" -d '{
  "transient" : {
    "cluster.routing.allocation.exclude._ip" : "172.31.27.38,172.31.19.50,172.31.19.67"
  }
}'

curl -XPUT "http://localhost:9200/_cluster/settings" -d '{
  "transient" : {
    "cluster.routing.allocation.exclude._ip" : null
  }
}'
```

* 推迟分片分配
>当一个节点需要重启时，可以避免自动重平衡导致分片迁移，造成不必要的网络、磁盘IO开销
```
# 查看推迟分片分配的设置，delayed_unassigned_shards延时待分配到具体节点上的分片数
curl http://localhost:9200/_cluster/health?pretty

# 推迟分片分配,此设置可以在活动索引(或所有索引)上更新.等待5分钟后再开始分配分片
curl -X PUT "localhost:9200/_all/_settings?pretty" -H 'Content-Type: application/json' -d'{
  "settings": {
    "index.unassigned.node_left.delayed_timeout": "5m"
  }
}'

# 取消推迟分片分配，设置为立即分配
curl -X PUT "localhost:9200/_all/_settings?pretty" -H 'Content-Type: application/json' -d'{
  "settings": {
    "index.unassigned.node_left.delayed_timeout": "0"
  }
}'
```

# [索引管理](https://www.elastic.co/guide/cn/elasticsearch/guide/current/index-management.html)
* 获取索引信息
```
curl -XGET 'localhost:9200/my_index?pretty'
```

* 创建索引
```
curl -XPUT 'localhost:9200/my_index?pretty'  -H 'Content-Type: application/json' -d'
{
   "settings" : {
      "number_of_shards" : 3,
      "number_of_replicas" : 1
   }
}'
```

* 删除索引
```
curl -X DELETE "localhost:9200/my_index?pretty"
curl -X DELETE "localhost:9200//index_one,index_two"
curl -X DELETE "localhost:9200/index_*"
```

* 查询索引
```
curl -XGET 'localhost:9200/my_index/_search?pretty'
```

* 更新索引设置
```
#调整索引分片副本数
curl -XPUT 'localhost:9200/my_index/_settings?pretty'  -H 'Content-Type: application/json' -d'
{
   "number_of_replicas" : 2
}'
```



# [慢日志](https://www.elastic.co/guide/en/elasticsearch/reference/current/index-modules-slowlog.html)
>为每个索引动态设置
* 设置搜索(查询阶段和获取阶段)慢日志阀值
```
curl -XPUT http:/localhost:9200/my-index-000001/_settings -d '{
  "index.search.slowlog.threshold.query.warn": "10s",
  "index.search.slowlog.threshold.query.info": "5s",
  "index.search.slowlog.threshold.query.debug": "2s",
  "index.search.slowlog.threshold.query.trace": "500ms",
  "index.search.slowlog.threshold.fetch.warn": "1s",
  "index.search.slowlog.threshold.fetch.info": "800ms",
  "index.search.slowlog.threshold.fetch.debug": "500ms",
  "index.search.slowlog.threshold.fetch.trace": "200ms",
  "index.search.slowlog.level": "info"
}'
```
* 设置索引阶段慢日志阀值
```
curl -XPUT http:/localhost:9200/my-index-000001/_settings -d '{
  "index.indexing.slowlog.threshold.index.warn": "10s",
  "index.indexing.slowlog.threshold.index.info": "5s",
  "index.indexing.slowlog.threshold.index.debug": "2s",
  "index.indexing.slowlog.threshold.index.trace": "500ms",
  "index.indexing.slowlog.level": "info",
  "index.indexing.slowlog.source": "1000"
}'
```

* 示例
```
curl -XPUT http:/localhost:9200/my-index-000001/_settings -d '{
  "index.search.slowlog.threshold.query.warn": "250ms",
  "index.search.slowlog.threshold.fetch.warn": "250ms",
  "index.indexing.slowlog.threshold.index.warn": "250ms",
  "index.indexing.slowlog.level": "warn",
  "index.indexing.slowlog.source": "1000"
}'
```

* 查看索引慢日志设置
```
curl -XGET  http:/localhost:9200/my-index-000001/_settings?pretty
```


# GC log
* vim jvm.options
```
## GC logging

-XX:+PrintGCDetails
-XX:+PrintGCTimeStamps
-XX:+PrintGCDateStamps

-Xloggc:/data/elasticsearch/logs/gc.log
```

# [elasticsearch-head](https://github.com/mobz/elasticsearch-head) 

```
docker run -d --name elasticsearch-head -p 9100:9100 mobz/elasticsearch-head:5
```

* 修改es配置(elasticsearch.yml)，允许跨域访问
```
http.cors.enabled: true
http.cors.allow-origin: "*"
http.cors.allow-headers: Authorization
```

# 性能优化
* https://www.elastic.co/guide/cn/elasticsearch/guide/current/_Improving_Performance.html
* https://cloud.tencent.com/developer/article/1436787
* https://blog.csdn.net/wlei0618/article/details/124104738
* https://developer.aliyun.com/article/706990
* https://learn.lianglianglee.com/%E4%B8%93%E6%A0%8F/ElasticSearch%E7%9F%A5%E8%AF%86%E4%BD%93%E7%B3%BB%E8%AF%A6%E8%A7%A3/17%20%E4%BC%98%E5%8C%96%EF%BC%9AElasticSearch%E6%80%A7%E8%83%BD%E4%BC%98%E5%8C%96%E8%AF%A6%E8%A7%A3.md