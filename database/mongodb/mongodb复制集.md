### 组件介绍
* **主节点 Primary**
  - 复制集中只能有一个主节点，用来接收客户端写请求，并记录操作日志到oplog
  - 复制集中任何成员都可以接收读请求。但是默认情况下，应用程序会直接连接到在主节点上进行读操作
* **从节点  Secondary**
  - 接收复制（异步）主节点的oplog应用到自己数据集，从节点可以有多个
  - 优先级设为0的从节点，不能成为主节点
  - 隐藏节点，优先级为0，不会收到客户端读请求，对客户端不可见
  - 延时节点，也是隐藏节点，且同步主节点数据集延时
* **投票节点 Arbiter**
  - 投票节点，没有数据集，也不能选举为主节点，不要同时在主节点或从节点上运行Arbiter，当参与选举的节点为偶数时，可以让Arbiter参与选举

### 架构
* 一主两从：
![image](https://mongoing.com/docs/_images/replica-set-primary-with-two-secondaries.png)

* 一主一从一仲裁：
![image](https://www.mongoing.com/docs/_images/replica-set-primary-with-secondary-and-arbiter.png)

### 部署复制集
1. 部署mongodb,参考mongodb安装文档
2. 设置节点复制集名称(同一复制集下的节点复制集名相同)
>vim mongodb.conf
```
replication:
   replSetName: "rs0"
```
3. 启动mongodb实例
```
/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/mongodb.conf
```
4. 初始化复制集(在其中一个节点上)
>/usr/local/mongon/bin/mongo
```
rs.initiate( {
   _id : "rs0",
   members: [
      { _id: 0, host: "192.168.240.128:27017" },
      { _id: 1, host: "192.168.240.129:27017" },
      { _id: 2, host: "192.168.240.130:27017" }
   ]
})
```

* rs.conf()查看复制集配置
* rs.status()查看复制集状态

### 为复制集增加投票节点
* 当复制集拥有偶数个节点，新增一个投票节点参与 elections 来打破投票僵局。
>vim mongodb.conf 关闭journal占用更少的空间
```
storage:
   journal:
      enabled: false
```
```
rs0:PRIMARY> rs.addArb("m1.example.net:30000")
```

### 为复制集新增节点
* 可以用复制集的备份快照来快速新增节点，新节点会成为从节点并赶上复制集的最新的数据集状态
* 使用 rs.printReplicationInfo() 来确认复制集的oplog状态
* rs.reconfig() 更新配置
```
# priority: 0, votes: 0设置优先级和是否参与投票，如果需要
rs.add( { host: "mongodb3.example.net:27017", priority: 0, votes: 0 } )
```

### 从复制集移除节点
1. 关闭我们想要移除的 mongod 实例
2. 连接到复制集现在的 primary
3. 
- rs.remove() 来移除节点
```
rs.remove("mongod3.example.net:27017")
```
- rs.reconfig() 来移除节点
```
cfg = rs.conf()
cfg.members.splice(2,1)  #members._id
rs.reconfig(cfg)
```

### 修改复制集节点
```
cfg = rs.conf()
cfg.members[0].host = "mongo2.example.net"
cfg.members[1].priority = 0    #修复优先级
cfg.members[2].hidden = true   #设置隐藏节点
cfg.members[0].slaveDelay = 3600  #设置延时复制节点
cfg.members[4].votes = 0          #设置不参与投票
rs.reconfig(cfg)
```