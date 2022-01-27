# 安装redis
```
tar -xzf redis-3.0.7.tar.gz
cd redis-3.0.7/
make
make install PREFIX=/usr/local/redis
mkdir -p /data/redis/{data,logs}
mkdir -p /usr/local/redis/conf
sysctl vm.overcommit_memory=1
cp redis.conf /usr/local/redis/conf
cd ..

#启动redis
/usr/local/redis/bin/redis-server /usr/local/redis/conf/redis.conf
#关闭redis
/usr/local/redis/bin/redis-cli -p 6379 shutdown
```



# 配置文件
```
daemonize yes
logfile "/data/redis/logs/redis_6379.log" 
dir /data/redis/data

# 持久化(两种方式)
1,快照，将内存中的数据以二进制形式写入文件中dump.rdb    
save 60 1                       #如果60秒内超过1个key被修改,则执行一次快照
save 100 10                     #如果100秒内超过10个key被修改,则执行一次快照
save 600 100                    #如果600秒内超过100个key被修改,则执行一次快照
dir /data/redis/                #指定快照文件保存位置
dbfilename dump_6379.rdb        #指定快照料文件名

2,aof，redis将每一个收到的写命令通过write函数追回到aof文件中，redis重启时会重新执行aof文件中的命令在内存中重建数据库内容
appendonly yes                                            #开启aof方式
appendfilename /data/redis/appendonly_6300.aof            #指定aof文件保存位置
appendfsync everysec                                      #aof同步方式，每秒

3,缓存策略，达到maxmemory时，触发maxmemory-policy
maxmemory 14G  #maxmemory默认值为0，表示不做限制

# volatile-lru -> remove the key with an expire set using an LRU algorithm
# allkeys-lru -> remove any key according to the LRU algorithm
# volatile-random -> remove a random key with an expire set
# allkeys-random -> remove a random key, any key
# volatile-ttl -> remove the key with the nearest expire time (minor TTL)
# noeviction -> don't expire at all, just return an error on write operations
maxmemory-policy noeviction
```

* 恢复
```
当redis服务重启时将按照以下优先级恢复数据到内存：
.如果只配置AOF,重启时加载AOF文件恢复数据；
.如果同时 配置了RBD和AOF,启动是只加载AOF文件恢复数据;
.如果只配置RBD,启动是将加载dump文件恢复数据。
```
```
redis虚拟内存，把不经常使用的数据交换到磁盘上
vm-enbaled yes                        #开启redis虚拟内存功能
vm-swap-file /tmp/redis.swap        #指定交换出来的value保存的文件路径
vm-max-memory 1000000                #redis使用的最大虚拟内存上限
vm-page-size 32                       #每个页面的大小32字节
vm-pages 134217728                    #最多使用多少页面
vm-max-threads 4                    #用于执行value对象换入的工作线程数量
```

* 安全性：
```
设置redis访问密码
vim redis.conf
requirepass xikai123      #redis速度太快一秒钟可以进行150000次密码尝试,建议设置复杂的密码(关闭外网访问)
重启redis服务


密码验证(两种方法)
1),登陆redis终端时验证密码
./redis-cli -a xikai123

2),进入终端后授权用户访问redis
./redis-cli
>auth xikai123
```


# 服务器命令
```
select 3                       #进入数据库3,redis数据库0-15,默认进入0
echo xxxx                      #输出内容
quit                           #退出redis终端
dbsize                         #获取当前数据库key的总个数
info                           #获取redis服务器相关信息
config get *                   #获取redis.conf配置信息(config get timeout 获取redis.conf中timout的值)
flushdb                        #删除当前数据库中所有key
flushall                       #删除所有数据库中所有key


健值命令:
move age 1                         #将age移动到数据库1

get key1                           #获取key
keys *                             #列出匹配模式的key名
randomkey                          #随机返回一个key
exists keyname                     #判断key是否存在
rename set1 set10                  #重命名key
del keyname                        #删除key
type keyname                       #查看key的数据类型

expire key 60                      #设置键的过期时间（秒）
ttl keyname                        #获取key的生命周期
persist keyname                    #取消key的过期时间
```


# [慢日志slowlog](http://redis.cn/commands/slowlog.html)
>Redis慢查询日志是一个记录超过指定执行时间的查询的系统。 这里的执行时间不包括IO操作，比如与客户端通信，发送回复等等，而只是实际执行命令所需的时间（这是唯一在命令执行过程中线程被阻塞且不能同时处理其他请求的阶段）。
* 在redis.conf中slowlog的设置：
```
slowlog-log-slower-than 10000       # 执行时间超过多少(微秒)将会被记录,使用负数将会关闭慢查询日志，而值为0将强制记录每一个命令
slowlog-max-len 128                 # 慢查询最大的条数，当一个新命令被记录，且慢查询日志已经达到其最大长度时，将从记录命令的队列中移除删除最旧的命令以腾出空间。
```
* 使用config方式动态设置slowlog
```
- 查看当前slowlog-log-slower-than设置
    127.0.0.1:6379> CONFIG GET slowlog-log-slower-than
    1) "slowlog-log-slower-than"
    2) "10000"
- 设置slowlog-log-slower-than为100ms
    127.0.0.1:6379> CONFIG SET slowlog-log-slower-than 100000
    OK
- 设置slowlog-max-len为1000
    127.0.0.1:6379> CONFIG SET slowlog-max-len 1000
    OK
```
* 读取slowlog
```
127.0.0.1:6379> slowlog get    # 返回慢查询日志中的每一个条目 
127.0.0.1:6379> slowlog get 2  # 返回慢查询日志中最近的2个条目
1) 1) (integer) 14
   2) (integer) 1309448221
   3) (integer) 15
   4) 1) "ping"
2) 1) (integer) 13              # 唯一的递增标识符
   2) (integer) 1309448128      # 处理记录命令的unix时间戳 
   3) (integer) 30              # 命令执行所需的总时间，以微秒为单位。
   4) 1) "slowlog"              # 组成该命令的参数的数组。
      2) "get"
      3) "100"
```
```
SLOWLOG LEN    # 获得慢查询日志的条数
SLOWLOG RESET  # 重置慢查询日志,删除后，信息将永远丢失
```


# [redis-benchmark](https://www.redis.com.cn/topics/benchmarks.html)
* 100个并发，10万请求数，每个key数据大小500字节,只测set/get
```
./redis-benchmark --help
./redis-benchmark -h 10.10.4.85 -p 6391 -a XeQ1htbZf2mpQyZn -c 100 -d 500 -n 100000 -t set,get
```





