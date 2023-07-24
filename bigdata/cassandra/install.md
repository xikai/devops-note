* https://cassandra.apache.org/doc/latest/index.html
* https://blog.51cto.com/michaelkang/5501456
* https://www.pianshen.com/article/2543784114/

# 简介
* Cassandra是一款分布式的结构化数据存储方案(NoSql数据库)，存储结构比Key-Value数据库（像Redis）更丰富，但是比Document数据库（如Mongodb）支持度有限；适合做数据分析或数据仓库这类需要迅速查找且数据量大的应用.
* Cassandra通过gossip协议 维护集群的状态，每个节点可能知道所有其他节点，也可能仅知道几个邻居节点，只要这些节点可以通过网络连通，最终他们的状态都是一致的。由于去中心化无主的策略，所以没有单点故障
* Gossip是一个最终一致性算法 虽然无法保证在某个时刻所有节点状态一致，但可以保证在“最终”所有节点一致，“最终”是一个现实中存在，但理论上无法证明的时间点。因此Gossip适合没有很高一致性要求的场景。

# 存储引擎
* [commitlog](https://cassandra.apache.org/doc/3.11/cassandra/architecture/storage_engine.html#commit-log) 
  - 任何写入Cassandra的数据在写入memtable之前都会先写入提交日志
* [Mem-table](https://cassandra.apache.org/doc/3.11/cassandra/architecture/storage_engine.html#memtables)
  - Memtables是Cassandra缓冲区写操作的内存结构。提交日志后，数据将被写入Memtables。最终，memtable被刷新到磁盘上并成为不可变的sstable
* [SSTable](https://cassandra.apache.org/doc/3.11/cassandra/architecture/storage_engine.html#sstables) 
  - sstable是Cassandra用来将数据持久化到磁盘上的不可变数据文件
  - 当sstable从memtable刷新到磁盘或从其他节点进行流处理时，Cassandra会触发压缩，将多个sstable合并成一个
  - 一旦新的SSTable被写入，旧的SSTable就可以被删除

# 数据模型
* keyspace (类似关系型数据库的 库名)
  * table 
    * Partition
      * row 
        * column

# [数据分布](https://cassandra.apache.org/doc/3.11/cassandra/architecture/dynamo.html)
* Cassandra通过使用hash函数对存储在系统中的所有数据进行分区来实现水平可伸缩性。每个分区被复制到多个物理节点，通常跨故障域(如机架甚至数据中心)
* [一致性哈希](http://t.zoukankan.com/dyf6372-p-3529511.html): 数据是通过表组织起来的，表中每行数据由primary key标识，集群中每个节点拥有一个或多个hash值区间 这样便可根据primary key对应的hash值将该条数据放在包含该hash值的hash值区间对应的节点中,就是说主键决定了数据存储在哪个节点。
  * vnodes虚拟节点：把数据分配到物理机器节点,指定数据与物理节点的所属关系
  * Partitioner分区器：在整个集群中对数据进行分区
  * Replicationstrategy副本策略：决定每行数据的副本 保存子不同的节点上。所有的节点都同样重要，没有主次之分。一行有几个副本由副本因子参数决定。
    * SimpleStrategy  适用于只有一个数据中心的状况。第一个副本的存储位置由分片器（partitioner）决定，其他副本按照顺时针方向依次放在其它节点。
    * NetworkTopologyStrategy 可以扩展到多数据中心。
  * Snitch: 决定副本策略的拓扑信息

# 安装
* 安装依赖
```
yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
```
```
#which java 找到java路径
echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk" >>/etc/profile
source /etc/profile
```

* 安装cassandra
```
wget https://dlcdn.apache.org/cassandra/3.11.13/apache-cassandra-3.11.13-bin.tar.gz
tar -xzf apache-cassandra-3.11.13-bin.tar.gz -C /usr/local
cd /usr/local
ln -s apache-cassandra-3.11.13 cassandra
```
```
groupadd cassandra
useradd -g cassandra cassandra
mkdir -p /data/cassandra/{data,logs,commitlog,saved_caches,hints}
chown -R cassandra:cassandra /usr/local/cassandra/
chown -R cassandra:cassandra /data/cassandra/
```

# [配置](https://cassandra.apache.org/doc/3.11/cassandra/configuration/index.html)
* vim conf/cassandra.yaml
```yml
cluster_name: 'Test Cluster'

# 集群节点配置
seed_provider:
    - class_name: org.apache.cassandra.locator.SimpleSeedProvider
      parameters:
          - seeds: "172.16.0.212,172.16.0.213,172.16.0.214"

storage_port: 7000
listen_address: 172.16.0.212      #监听地址为节点IP，不能为0.0.0.0； 集群中服务器与服务器之间相互通信的地址
rpc_address: 172.16.0.212         #cqlsh 监听地址
native_transport_port: 9042  #cqlsh通讯端口

data_file_directories:
    - /data/cassandra/data      #数据目录
commitlog_directory: /data/cassandra/commitlog      #commitlog目录
saved_caches_directory: /data/cassandra/saved_caches    #缓存目录
hints_directory: /data/cassandra/hints

#authenticator: PasswordAuthenticator  #设置为用密码认证，默认允许所有人登录
```

* 修改日志目录 ,conf/cassandra-env.sh
```
if [ "x$CASSANDRA_LOG_DIR" = "x" ] ; then
    CASSANDRA_LOG_DIR="/data/cassandra/logs"
fi
```

* 设置jvm堆大小，,conf/cassandra-env.sh
```
MAX_HEAP_SIZE 表示最大申请内存大小
HEAP_NEW_SIZE 表示初始申请内存大小
```

# 启动
```
su - cassandra -c '/usr/local/cassandra/bin/cassandra'
tail -f logs/system.log
```
* 关闭
```
bin/nodetool stopdaemon
or:
kill pid
```

* 检查状态
```
bin/nodetool status
```


# cqlsh
```
bin/cqlsh 172.16.0.212
cqlsh> describe keyspaces;
cqlsh> describe tables;
```
* 创建用户
```
bin/cqlsh 172.16.0.212 -ucassandra -pcassandra
cqlsh> CREATE USER myusername WITH PASSWORD 'mypassword' SUPERUSER;
```

* 创建keyspace,并选择
```
cqlsh> create keyspace castest with replication = {'class':'SimpleStrategy','replication_factor':3} and durable_writes = true;
cqlsh> use castest;
```
* 创建表，写入数据
```
CREATE TABLE user_info (id int, user_name varchar, PRIMARY KEY (id) );
INSERT INTO user_info (id,user_name) VALUES (1,'user01');
```
* 查询数据
```
select * from user_info;
```

