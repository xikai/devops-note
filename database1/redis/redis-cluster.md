# Docs
```
官方文档：
http://redis.io/topics/cluster-tutorial
http://redis.io/topics/cluster-spec
参考文档：
http://www.redis.cn/topics/cluster-tutorial.html
http://blog.csdn.net/xu470438000/article/details/42972123
http://blog.csdn.net/reyleon/article/details/51454334
https://hub.docker.com/r/bitnami/redis-cluster
```

# 部署redis cluster
```bash
#创建目录，在相同主机上运行6个redis实例(生产环境至少6台机器运行单节点)
mkdir -p /usr/local/redis-cluster/{7000..7005}
```

* 安装redis-cluster依赖软件
```bash
yum install ruby gem -y
##gem sources -a http://ruby.taobao.org/
gem install redis

wget http://download.redis.io/releases/redis-3.2.3.tar.gz
tar xzf redis-3.2.3.tar.gz
cd redis-3.2.3
make
make install
cp src/redis-trib.rb /usr/local/bin/
```

* 拷贝redis配置文件到redis实例目录
```bash
cp redis.conf /usr/local/redis-cluster/7000/
cp redis.conf /usr/local/redis-cluster/7001/
cp redis.conf /usr/local/redis-cluster/7002/
cp redis.conf /usr/local/redis-cluster/7003/
cp redis.conf /usr/local/redis-cluster/7004/
cp redis.conf /usr/local/redis-cluster/7005/

mkdir -p /data/redis/logs
mkdir -p /data/redis/{7000..7005}
```

* 修改各redis实例配置文件为集群模式
>vim /usr/local/redis-cluster/700x/redis.conf
```
port 700x
daemonize yes
cluster-enabled yes
cluster-config-file nodes-700x.conf
cluster-node-timeout 5000
protected-mode no
loglevel notice
logfile /data/redis/logs/redis_700x.log
dir /data/redis/700x        #指定rdb、aof文件和cluster-config-file的保存位置

#appendonly yes
#appendfilename appendonly_700x.aof
#appendfsync everysec

#save 60 1
#save 100 10
#save 600 100
#dbfilename dump_7000.rdb

maxmemory 16g
maxmemory-policy volatile-lru
```


* 启动redis节点
```bash
cd /usr/local/redis-cluster/700x && redis-server ./redis.conf
```

* 创建redis cluster(己源码安装)
```bash
# --replicas 表示1个主节点对应几个从节点
redis-trib.rb create --replicas 1 192.168.221.53:7000 192.168.221.53:7001 \
192.168.221.53:7002 192.168.221.53:7003 192.168.221.53:7004 192.168.221.53:7005
```

* 查看节点信息
```bash
redis-cli -p 7000 cluster nodes
```


# 测试集群
* 连接任意节点获取集群信息
```bash
redis-cli -p 7001 cluster nodes
```

* 连接任一节点创建获取数据(-c参数可以指定查询时接收到MOVED指令自动跳转)
```bash
[root@localhost ~]# redis-cli -c -p 7001
127.0.0.1:7001> set a 1
(error) MOVED 15495 127.0.0.1:7002
127.0.0.1:7001> get a
(error) MOVED 15495 127.0.0.1:7002
127.0.0.1:7001> set b 2
(error) MOVED 3300 127.0.0.1:7000
127.0.0.1:7001> set c 3
OK
127.0.0.1:7001> get c
"3"
127.0.0.1:7001> get b
(error) MOVED 3300 127.0.0.1:7000
127.0.0.1:7001> 

注：同时挂掉两个master，或挂掉一对主从，集群失败
```

* redis集群逐个节点设置密码,修改节点配置文件redis.conf
```
requirepass "jg8ZxxT1#lmc"  
masterauth "jg8ZxxT1#lmc"
```
* 临时设置密码
```bash
config set masterauth jg8ZxxT1#lmc
config set requirepass jg8ZxxT1#lmc
config rewrite
```

* 为集群新加从节点
```bash
redis-trib.rb add-node --slave --master-id dfa9d0d059a7ea35867ab3cbe8232a8550ce933c new_node_ip:7000 old_masternode_ip:7000
```
* 移除一个节点(第一个参数是任意一个节点的地址,第二个节点是你想要移除的节点地址)
```bash
redis-trib.rb del-node 127.0.0.1:7000 `<node-id>`
```