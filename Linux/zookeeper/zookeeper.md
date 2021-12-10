* https://zookeeper.apache.org/doc/current/zookeeperAdmin.html#ch_deployment
* https://segmentfault.com/a/1190000014642288
* https://segmentfault.com/a/1190000014642335

>zookeeper是一个开源的分布式协调服务，主要用于解决分布式场景下数据一致性问题

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
dataLogDir=/data/zookeeper/logs
clientPort=2181
```
* 启动zookeeper
```
mkdir -p /data/zookeeper/{data,logs}
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

### 配置集群(所有节点)
* vim /etc/hosts
```
172.22.0.29   zoo1
172.22.0.37   zoo2
172.22.0.9   zoo3
```
* vim conf/zoo.cfg
```
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/data/zookeeper/data
dataLogDir=/data/zookeeper/logs
clientPort=2181
server.1=zoo1:2888:3888     # 1表示myid为1的zookeeper，端口2888用来节点间通讯,端口3888用来选举leader
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

# 日志解析
```sh
# 查找参与选举的节点
2021-12-03 05:35:05,243 [myid:3] - INFO  [QuorumPeer[myid=3](plain=[0:0:0:0:0:0:0:0]:2181)(secure=disabled):QuorumPeer@1383] - LOOKING
2021-12-03 05:35:05,245 [myid:3] - INFO  [QuorumPeer[myid=3](plain=[0:0:0:0:0:0:0:0]:2181)(secure=disabled):FastLeaderElection@944] - New election. My id = 3, proposed zxid=0x10000000a
2021-12-03 05:35:05,246 [myid:3] - INFO  [ListenerHandler-zoo3/172.22.0.9:3888:QuorumCnxManager$Listener$ListenerHandler@1065] - 3 is accepting connections now, my election bind port: zoo3/172.22.0.9:38
88
# 当选leader
2021-12-03 04:50:50,341 [myid:2] - INFO  [QuorumPeer[myid=2](plain=[0:0:0:0:0:0:0:0]:2181)(secure=disabled):QuorumPeer@858] - Peer state changed: leading
2021-12-03 04:50:50,342 [myid:2] - INFO  [QuorumPeer[myid=2](plain=[0:0:0:0:0:0:0:0]:2181)(secure=disabled):QuorumPeer@1477] - LEADING
# 有足够的支持者
2021-12-03 05:35:05,667 [myid:1] - INFO  [QuorumPeer[myid=1](plain=[0:0:0:0:0:0:0:0]:2181)(secure=disabled):Leader@1504] - Have quorum of supporters, sids: [[1, 3]]; starting up and setting last processed zxid: 0x200000000
# 当选leader用时305ms
2021-12-03 04:50:50,410 [myid:2] - INFO  [QuorumPeer[myid=2](plain=[0:0:0:0:0:0:0:0]:2181)(secure=disabled):Leader@581] - LEADING - LEADER ELECTION TOOK - 305 MS
# 广播当前状态
2021-12-03 04:50:50,781 [myid:2] - INFO  [QuorumPeer[myid=2](plain=[0:0:0:0:0:0:0:0]:2181)(secure=disabled):QuorumPeer@864] - Peer state changed: leading - broadcast

# 接收到其它节点连接
2021-12-03 04:52:54,840 [myid:2] - INFO  [ListenerHandler-zoo2/172.22.0.37:3888:QuorumCnxManager$Listener$ListenerHandler@1070] - Received connection request from /172.22.0.9:42084

# 成功连接新leader
2021-12-03 05:35:05,510 [myid:3] - INFO  [LeaderConnector-zoo1/172.22.0.29:2888:Learner$LeaderConnector@370] - Successfully connected to leader, using address: zoo1/172.22.0.29:2888
2021-12-03 05:35:05,587 [myid:3] - INFO  [QuorumPeer[myid=3](plain=[0:0:0:0:0:0:0:0]:2181)(secure=disabled):Learner@717] - Learner received NEWLEADER message

# 建立一个会话连接
2021-12-03 05:20:34,142 [myid:1] - INFO  [CommitProcessor:1:LearnerSessionTracker@116] - Committing global session 0x20095b400190001

# 一个节点（id 3）连接中断
2021-12-03 05:27:09,633 [myid:2] - ERROR [LearnerHandler-/172.22.0.9:51772:LearnerHandler@714] - Unexpected exception causing shutdown while sock still open
2021-12-03 05:27:09,631 [myid:1] - WARN  [RecvWorker:3:QuorumCnxManager$RecvWorker@1396] - Connection broken for id 3, my id = 1
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

# 查看znode节点信息
[zk: 127.0.0.1:2181(CONNECTED) 4] stat /zk
cZxid = 0x0
ctime = Thu Jan 01 00:00:00 UTC 1970
mZxid = 0x0
mtime = Thu Jan 01 00:00:00 UTC 1970
pZxid = 0x0
cversion = -2
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 0
numChildren = 2

# 监听这个znode节点的变化,当另外一个客户端改变/zk时,它会打印下面的
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
```

### [adminserver](https://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_adminserver)
* vim conf/zoo.cfg
```
# Enable AdminServer
admin.portUnification
```
```
bin/zkServer.sh restart
```