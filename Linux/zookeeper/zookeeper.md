* https://zookeeper.apache.org/doc/current/zookeeperAdmin.html#ch_deployment
* https://segmentfault.com/a/1190000014642288
* https://segmentfault.com/a/1190000014642335

# 部署zookeeper
```
yum install java-1.8.0-openjdk -y
systemctl stop iptables
```
```
wget https://dlcdn.apache.org/zookeeper/zookeeper-3.6.3/apache-zookeeper-3.6.3-bin.tar.gz
tar -xzf apache-zookeeper-3.6.3-bin.tar.gz
mv apache-zookeeper-3.6.3-bin zookeeper
cd zookeeper
cp conf/zoo_sample.cfg conf/zoo.cfg
```
* 配置文件
```
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/data/zookeeper/data
clientPort=2181
```
* 启动zookeeper
```
mkdir -p /data/zookeeper/data
bin/zkServer.sh start
```
* 连接到 ZooKeeper
```
bin/zkCli.sh -server 127.0.0.1:2181
[zk: 127.0.0.1:2181(CONNECTED) 0] help
[zk: 127.0.0.1:2181(CONNECTED) 1] ls /
[zookeeper]
```

# 部署zookeeper集群
* Zookeeper组成一个集群至少需要三台节点(2n+1个服务允许n个失效)
* zookeeper分为三种角色，每一个节点同时只能扮演一种角色
  - Leader：事务请求(写操作)的唯一调度和处理者
  - Follower：处理客户端的非事务请求(读操作)，转发事务请求(写操作)给leader，参与leader选举投票
  - Observer：接收客户端连接，将写请求转发给Leader节点，Observer不参与选举投票过程

* 配置集群(所有节点)
```
# vim /etc/hosts
172.22.0.29   zoo1
172.22.0.37   zoo2
172.22.0.9   zoo3
```
```
# vim conf/zoo.cfg
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/data/zookeeper/data
clientPort=2181
server.1=zoo1:2888:3888     # 1表示myid为1的zookeeper，端口2888用来连接leader,端口3888用来选举leader
server.2=zoo2:2888:3888
server.3=zoo3:2888:3888
```
* 配置myid
```
# zoo1
echo 1 > /data/zookeeper/data/myid
# zoo2
echo 2 > /data/zookeeper/data/myid
# zoo3
echo 3 > /data/zookeeper/data/myid
```
* 启动zookeeper
```
mkdir -p /data/zookeeper/data
bin/zkServer.sh start
```
* 要看server status
```
[root@zk_soa01 zookeeper]# bin/zkServer.sh status
/usr/bin/java
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper/bin/../conf/zoo.cfg
Client port found: 2181. Client address: localhost.
Mode: follower
```

# 命令行操作 ZooKeeper cluster
* 连接到ZooKeeper cluster
```
# 任一节点
bin/zkCli.sh -server 127.0.0.1:2181
```
```
[zk: 127.0.0.1:2181(CONNECTED) 0] help
[zk: 127.0.0.1:2181(CONNECTED) 1] ls /
[zookeeper]
[zk: 127.0.0.1:2181(CONNECTED) 2] create /zk "myData"
Created /zk
[zk: 127.0.0.1:2181(CONNECTED) 3] get /zk
myData

# 监听这个节点的变化,当另外一个客户端改变/zk时,它会打印下面的
[zk: 127.0.0.1:2181(CONNECTED) 5] get -w /zk
myData

# 设置/zk关联的字符串
[zk: 127.0.0.1:2181(CONNECTED) 6] set /zk "zsl"

WATCHER::

WatchedEvent state:SyncConnected type:NodeDataChanged path:/zk

# 删除znode节点 /zk
[zk: 127.0.0.1:2181(CONNECTED) 7] delete /zk
# 如果znode下面有子节点，用delete是删除不了的，要用递归删除：rmr
[zk: 127.0.0.1:2181(CONNECTED) 7] rmr /zk