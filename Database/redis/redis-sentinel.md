* http://www.redis.com.cn/topics/sentinel.html
* https://redis.io/docs/management/sentinel/
* https://bbs.huaweicloud.com/blogs/303870
* https://www.cnblogs.com/kevingrace/p/9004460.html

> Redis Sentinel 是一个分布式系统， 你可以在一个架构中运行奇数个 Sentinel 进程（progress）， 这些进程使用流言协议（gossip protocols)来接收关于主服务器是否下线的信息， 并使用投票协议（agreement protocols）来决定是否执行自动故障迁移， 以及选择哪个从服务器作为新的主服务器。


# [部署主从redis-server](database/redis/redis.md)

# redis-server主从配置
* master
```
daemonize no
bind 0.0.0.0
protected-mode yes    #当保护模式默认被开启yes时，必须配置bind监听IP或requirepass二者之一，否则将只允许来自本地lo网卡的访问
logfile "/data/redis/logs/redis_6379.log"
dir /data/redis/data

save 60 1
save 100 10
save 600 100
dbfilename dump_6379.rdb

requirepass "123456"
masterauth 123456    #由于使用sentinel，master也可能变成slave
```
* slave
```
daemonize no
bind 0.0.0.0
protected-mode yes
logfile "/data/redis/logs/redis_6379.log" 
dir /data/redis/data

save 60 1
save 100 10
save 600 100
dbfilename dump_6379.rdb

requirepass "123456"
masterauth 123456

slaveof 172.22.0.29 6379   #指定主节点master_ip，（发生主从切换后，哨兵会删掉主节点上的slaveof配置，并在从节点启动后增加slaveof配置指向新的主）
```

* 启动redis
```
systemctl start redis
```

* 验证从节点的redis服务
```
[root@test-host-1 ~]# /usr/local/redis/bin/redis-cli -p 6379 -a 123456 info replication
# Replication
role:master
connected_slaves:2
slave0:ip=172.22.0.37,port=6379,state=online,offset=813,lag=1
slave1:ip=172.22.0.9,port=6379,state=online,offset=813,lag=1
master_repl_offset:813
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:2
repl_backlog_histlen:812
```
>此时可以在master上写入数据，在slave上查看数据，此时主从复制配置完成


# redis-Sentinel配置
>至少需要三个 Sentinel 实例才能进行可靠的部署。Sentinel必须部署奇数个，偶数个Sentinel会出现选举脑裂，导致无法执行故障切换(https://zhuanlan.zhihu.com/p/353156564),sentinel只要监控同一个redis master，启动的话自动连接成集群
```
cp sentinel.conf /usr/local/redis/conf
mkdir -p /data/redis/sentinel

```
* vim sentinel.conf
```
daemonize no
port 26379
bind 0.0.0.0    #必须配置bind或protected-mode no,否则sentinel之间不能通讯
dir "/data/redis/sentinel"
pidfile "/var/run/redis_26379.pid"
logfile "/data/redis/logs/sentine.log"

sentinel monitor mymaster 172.22.0.29 6379 2
sentinel down-after-milliseconds mymaster 5000
sentinel parallel-syncs mymaster 1
sentinel failover-timeout mymaster 60000
sentinel auth-pass mymaster 123456

# sentinel monitor resque 192.168.1.3 6380 4
# sentinel down-after-milliseconds resque 10000
# sentinel parallel-syncs resque 2
# sentinel failover-timeout resque 180000

```

# sentinel工作原理
```
sentinel monitor mymaster 172.22.0.29 6379 2
# redis Sentinel监控别名为mymaster的主机，地址是172.22.0.29:6379，并且有2个quorum法定人数(需要同意主节点不可用的Sentinels的数量)。然而quorum 仅仅只是用来检测失败。为了实际的执行故障转移，还需要sentinel中的大多数sentinel投票选出leader并且被授权后才可以进行failover。例如，集群中有5个sentinel，票数被设置为2，当2个sentinel认为一个master已经不可用了以后，将会触发failover。但是，进行failover的那个sentinel必须先获得至少3个sentinel的授权才可以实行failover。
# 创建连接主服务器的网络连接
  Sentinel和Master之间会创建一个命令连接和一个订阅连接：
  1）命令连接用于获取主从信息
  2）订阅连接用于Sentinel之间进行信息广播，每个Sentinel和自己监视的主从服务器之间会订阅_sentinel_:hello频道（注意Sentinel之间不会创建订阅连接，它们通过订阅_sentinel_:hello频道来获取其他Sentinel的初始信息）
# 创建连接从服务器的网络连接
  根据主服务获取从服务器信息，Sentinel可以创建到Slave的网络连接，Sentinel和Slave之间也会创建命令连接和订阅连接
# 创建Sentinel之间的网络连接
  此时是不是还有疑问，Sentinel之间是怎么互相发现对方并且相互通信的，这个就和上面Sentinel与自己监视的主从之间订阅_sentinel_:hello频道有关了。
  Sentinel会与自己监视的所有Master和Slave之间订阅_sentinel_:hello频道，并且Sentinel每隔2秒钟向_sentinel_:hello频道发送一条消息，消息内容如下：
  PUBLISH _sentinel_:hello "<s_ip>,<s_port>,<s_runid>,<s_epoch>,<m_ip>,<m_port>,<m_runid>,<m_epoch>" 其中s代码Sentinel，m代表Master；ip表示IP地址，port表示端口、runid表示运行id、epoch表示配置纪元。
  Sentinel之间不会创建订阅连接，它们只会创建命令连接


sentinel down-after-milliseconds mymaster 30000
# 主观下线（Subjectively Down， 简称sdown）指的是单个 Sentinel 实例对服务器做出的下线判断
   每个Sentinel节点都要定期PING命令来判断Redis数据节点和其余Sentinel节点是否可达，如果超过30000毫秒30s且没有回复，则当前Sentinel认为其主观下线。
# 客观下线（Objectively Down， 简称odown）指多个 Sentinel 实例在对同一个服务器做出sdown判断：要想判断当前Master是否客观下线，还需要询问其他Sentinel，并且所有认为Master主观下线或者客观下线的总和需要达到quorum配置的值，当前Sentinel才会将Master标志为客观下线。
  * 当前Sentinel向sentinelRedisInstance实例中的其他Sentinel发送如下命令：SENTINEL is-master-down-by-addr <ip> <port> <current_epoch> <runid>。
     ip：被判断为主观下线的Master的IP地址
     port：被判断为主观下线的Master的端口
     current_epoch：当前sentinel的配置纪元
     runid：当前sentinel的运行id，runid
     <SENTINEL is-master-down-by-addr 192.168.211.104 6379 0 *> ,当Sentinel检测到Master处于主观下线时，询问其他Sentinel时会发送current_epoch和runid，此时current_epoch=0，runid=*
  * 接收到命令的Sentinel，会根据命令中的参数检查主服务器是否下线，检查完成后会返回如下三个参数：
     down_state：检查结果1代表已下线、0代表未下线
     leader_epoch：当leader_runid返回runid时，配置纪元会有值，否则一直返回0
     leader_runid：返回*代表判断是否下线，返回runid代表选举领头Sentinel

# 选举leader Sentinel
  * down_state返回1，证明接收is-master-down-by-addr命令的Sentinel认为该Master也主观下线了，如果down_state返回1的数量（包括本身）大于等于quorum（配置文件中配置的值），那么Master正式被当前Sentinel标记为客观下线。此时，Sentinel会再次发送如下指令：SENTINEL is-master-down-by-addr <ip> <port> <current_epoch> <runid>。
  * 此时的runid将不再是0，而是Sentinel自己的运行id（runid）的值，表示当前Sentinel希望接收到is-master-down-by-addr命令的其他Sentinel将其设置为leader Sentinel。这个设置是先到先得的，Sentinel先接收到谁的设置请求，就将谁设置为leader Sentinel。
  * 发送命令的Sentinel会根据其他Sentinel回复的结果来判断自己是否被该Sentinel设置为领头Sentinel，如果Sentinel被其他Sentinel设置为领头Sentinel的数量超过半数Sentinel（这个数量在sentinelRedisInstance的sentinel字典中可以获取），那么Sentinel会认为自己已经成为领头Sentinel，并开始后续故障转移工作。由于需要半数，且每个Sentinel只会设置一个领头Sentinel，那么只会出现一个领头Sentinel，如果没有一个达到领头Sentinel的要求，Sentinel将会重新选举直到领头Sentinel产生为止）

# 故障转移
* 故障转移将会交给领头sentinel全权负责，领头sentinel需要做如下事情：
  1. 从原先master的slave中，选择最佳的slave作为新的master
  2. 让其他slave成为新的master的slave
  3. 继续监听旧master，如果其上线，则将其设置为新的master的slave
* 选择最佳的新Master，领头Sentinel会做如下清洗和排序工作：
  1. 判断slave是否有下线的，如果有从slave列表中移除。删除5秒内未响应sentinel的INFO命令的slave。删除与下线主服务器断线时间超过down_after_milliseconds * 10 的所有从服务器
  2. 根据slave优先级slave_priority，选择优先级最高的slave作为新master。如果优先级相同，根据slave复制偏移量slave_repl_offset，选择偏移量最大的slave作为新master。如果偏移量相同，根据slave服务器运行id run id排序，选择run id最小的slave作为新master
* 新的Master产生后，leader sentinel会向已下线主服务器的其他从服务器（不包括新Master）发送SLAVEOF ip port命令，使其成为新master的slave。
```
```
sentinel parallel-syncs mymaster 1
# 当Sentinel节点集合对主节点故障判定达成一致时，Sentinel领导者节点会做故障转移操作，选出新的主节点，原来的从节点会向新的主节点发起复制操作，限制每次向新的主节点发起复制操作的从节点个数为1

sentinel failover-timeout mymaster 60000
# 指定故障切换允许的毫秒数，超过这个时间，就认为故障切换失败

sentinel auth-pass mymaster 123456
# sentinel author-pass定义服务的密码，mymaster是服务名称，123456是Redis服务器密码

# sentinel notification-script mymaster /usr/local/redis/scripts/warn.sh
# 指定sentinel检测到该监控的redis实例指向的实例异常时，调用的报警脚本。该配置项可选，比较常用 
```

# 启动redis-sentinel
```
cat > /usr/lib/systemd/system/redis-sentinel.service <<EOF
[Unit]
Description=Redis Sentinel Server
After=network.target

[Service]
Type=simple
User=redis
Group=redis
PIDFile=/var/run/redis_26379.pid
ExecStart=/usr/local/redis/bin/redis-sentinel /usr/local/redis/conf/sentinel.conf
ExecStop=/usr/local/redis/bin/redis-cli -p 26379 shutdown

[Install]
WantedBy=multi-user.target
EOF
```
```
systemctl start redis-sentinel
systemctl enable redis-sentinel
```

* 查看哨兵是否成功通信
```
[root@test-host-1 ~]# /usr/local/redis/bin/redis-cli -p 26379  info sentinel
# Sentinel
sentinel_masters:1
sentinel_tilt:0
sentinel_running_scripts:0
sentinel_scripts_queue_length:0
sentinel_simulate_failure_flags:0
master0:name=mymaster,status=ok,address=172.22.0.29:6379,slaves=2,sentinels=3
```

* 哨兵命令
```sh
/usr/local/redis/bin/redis-cli -p 26379 
> SENTINEL failover mymaster                            #手动触发主从切换
> SENTINEL set master6379 down-after-milliseconds 3000  #设置当前哨兵节点检测服务器下线的时间(如果您有多个哨兵，则应将更改应用于所有实例)
> SENTINEL reset *                                      #对于符合pattern通配符风格的主节点配置进行重置，包含清除主节点的相关状态，重新发现从节点和sentinel节点等
> SENTINEL masters                                      #返回被sentinel监视的所有master的状态信息
> SENTINEL master mymaster                              #返回被sentinel监视的指定master的状态信息
> SENTINEL slaves mymaster                              #返回所有slave状态信息
> SENTINEL sentinels mymaster                           #返回所有sentinel状态信息
```

# redis高可用故障实验
* 检查三个节点的复制身份状态
```
[root@test-host-1 ~]# /usr/local/redis/bin/redis-cli -p 6379 -a 123456 info replication
# Replication
role:master
connected_slaves:2
slave0:ip=172.22.0.37,port=6379,state=online,offset=415214,lag=1
slave1:ip=172.22.0.9,port=6379,state=online,offset=415214,lag=1
master_repl_offset:415214
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:2
repl_backlog_histlen:415213

[root@test-host-2 ~]# /usr/local/redis/bin/redis-cli -p 6379 -a 123456 info replication
# Replication
role:slave
master_host:172.22.0.29
master_port:6379
master_link_status:up
master_last_io_seconds_ago:1
master_sync_in_progress:0
slave_repl_offset:425124
slave_priority:100
slave_read_only:1
connected_slaves:0
master_repl_offset:0
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0
```

* 杀掉master redis进程
```
pkill redis-server

# 此时再次查看两个slave的状态
[root@test-host-2 ~]# /usr/local/redis/bin/redis-cli -p 6379 -a 123456 info replication
master_link_status:down
master_link_down_since_seconds:13
```

* 稍等片刻之后，发现slave节点成为master节点
```
[root@test-host-2 ~]# /usr/local/redis/bin/redis-cli -p 6379 -a 123456 info replication
# Replication
role:master
connected_slaves:1
slave0:ip=172.22.0.9,port=6379,state=online,offset=4015,lag=0
master_repl_offset:4015
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:2
repl_backlog_histlen:4014
```

* 客户端连接sentinel（ip+端口,sentinel_name）