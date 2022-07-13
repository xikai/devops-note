* http://www.redis.com.cn/topics/sentinel.html
* https://www.cnblogs.com/kevingrace/p/9004460.html
* Redis Sentinel 是一个分布式系统， 你可以在一个架构中运行多个 Sentinel 进程（progress）， 这些进程使用流言协议（gossip protocols)来接收关于主服务器是否下线的信息， 并使用投票协议（agreement protocols）来决定是否执行自动故障迁移， 以及选择哪个从服务器作为新的主服务器。

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
>Sentinel必须部署奇数个，偶数个Sentinel会出现选举脑裂，导致无法执行故障切换（https://zhuanlan.zhihu.com/p/353156564）,sentinel只要监控同一个redis master，启动的话自动连接成集群
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
sentinel down-after-milliseconds mymaster 3000
sentinel parallel-syncs mymaster 1
sentinel failover-timeout mymaster 60000
sentinel auth-pass mymaster 123456

# sentinel monitor resque 192.168.1.3 6380 4
# sentinel down-after-milliseconds resque 10000
# sentinel parallel-syncs resque 2
# sentinel failover-timeout resque 180000

```
```
# 当前Sentinel节点监控 172.22.0.29:6379 这个主节点
# 2代表判断主节点失败至少需要2个Sentinel节点同意(不过要注意，无论你设置要多少个 Sentinel 同意才能判断一个服务器失效， 都需要一个Sentinel获得系统中多数（majority） Sentinel 的支持选举为leader， 才能发起一次自动故障迁移)
# mymaster是主节点的别名
sentinel monitor mymaster 172.22.0.29 6379 2

# 每个Sentinel节点都要定期PING命令来判断Redis数据节点和其余Sentinel节点是否可达，如果超过30000毫秒30s且没有回复，则判定不可达
sentinel down-after-milliseconds mymaster 30000

# 当Sentinel节点集合对主节点故障判定达成一致时，Sentinel领导者节点会做故障转移操作，选出新的主节点，
原来的从节点会向新的主节点发起复制操作，限制每次向新的主节点发起复制操作的从节点个数为1
sentinel parallel-syncs mymaster 1

# 指定故障切换允许的毫秒数，超过这个时间，就认为故障切换失败，默认为3分钟
sentinel failover-timeout mymaster 180000

# sentinel author-pass定义服务的密码，mymaster是服务名称，123456是Redis服务器密码
sentinel auth-pass mymaster 123456

# 指定sentinel检测到该监控的redis实例指向的实例异常时，调用的报警脚本。该配置项可选，比较常用 
# sentinel notification-script mymaster /usr/local/redis/scripts/warn.sh
```
>sentinel down-after-milliseconds配置项只是一个哨兵在超过规定时间依旧没有得到响应后，会自己认为主机不可用。对于其他哨兵而言，并不是这样认为。哨兵会记录这个消息，当拥有认为主观下线的哨兵达到sentinel monitor所配置的数量时，就会发起一次投票，进行failover，此时哨兵会重写Redis的哨兵配置文件，以适应新场景的需要。
```
* 主观下线（Subjectively Down， 简称 SDOWN）指的是单个 Sentinel 实例对服务器做出的下线判断。
* 客观下线（Objectively Down， 简称 ODOWN）指的是多个 Sentinel 实例在对同一个服务器做出 SDOWN 判断， 并且通过 SENTINEL is-master-down-by-addr 命令互相交流之后， 得出的服务器下线判断。 （一个 Sentinel 可以通过向另一个 Sentinel 发送 SENTINEL is-master-down-by-addr 命令来询问对方是否认为给定的服务器已下线。）
* 从主观下线状态切换到客观下线状态并没有使用严格的法定人数算法（strong quorum algorithm）， 而是使用了流言协议： 如果 Sentinel 在给定的时间范围内， 从其他 Sentinel 那里接收到了足够数量的主服务器下线报告， 那么 Sentinel 就会将主服务器的状态从主观下线改变为客观下线。 如果之后其他 Sentinel 不再报告主服务器已下线， 那么客观下线状态就会被移除。
```

* 启动redis-sentinel
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
> SENTINEL set master6379 down-after-milliseconds 3000  #设置所有哨兵节点检测服务器下线的时间
> SENTINEL reset *                                      #刷新从master\slave\sentinel获取的信息
> SENTINEL masters                                      #返回被sentinel监视的所有master的状态信息
> SENTINEL master <master_name>                         #返回被sentinel监视的指定master的状态信息
> SENTINEL slaves                                       #返回所有slave状态信息
> SENTINEL sentinels                                    #返回所有sentinel状态信息
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