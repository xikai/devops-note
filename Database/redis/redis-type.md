# string最简单的数据类型，类似memcache
```
#set设置键值对
set key value
setnx key value                  //设置键值对,如果键值己存在，则不覆盖返回0。
setex key time value            //指定键值的有效时间(秒)
setrange key offset value         //替换指定下标(从0开始)开始字符串(个数=value长度)
mset key1 value1 key2 value2    //批量设置键值对
msetnx key3 value3 key2 value2    //批量设置键值对,如果有一个键值己存在，则批量设置失败返回0。
getset key value                //获取key的旧值，并设置key的新值

#get获取键的值
get key1
getrange key 0 5            //获取指定范围的键值
mget key1 key2 key3            //批量获取键值

#递增
incr key                //对键值做递增(+1)，健不存在，则设置为0
incrby key 3            //对键的值增加指定的数

#递减
decr key                //对键值做递减(-1)，健不存在，则设置为0
decrby key 3            //对键的值减去指定的数

#append附加
append key xxxkkk        //在key的值后附加xxxkkk

strlen key                //获取key值长度
```

# hash数据类型可以当做表
```
#hset table field value设置hash表字段的值
hset user:001 name xikai                    //设置user:001表的name等于xikai
hsetnx user:002 name xikai                    //设置字段值,如果己存在，则不覆盖返回0
hmset user:003 name xikai age 24 sex 1         //批量设置hash表字段

#hget获取hash表字段值
hget user:001 name
hmget user:003 name age sex                    //批量获取hash表字段


hincrby user:003 age 5                        //对hash表字段值增加5

hexists user:003 age                        //判断hash表字段是否存在

hlen user:001                                //获取user:001表的字段个数

hdel user:003 age                             //删除hash表字段的值

hkeys user:003                                //返回user:003所有字段名
hvals user:003                                //返回user:003所有字段值
hgetall user:003                             //返回user:003所有的字段和值
```

# list数据类型 栈 队列
```
#lpush在key对应的list头部添加value(先进后出)
lpush list1 "hello"
lpush list1 "world"

lrange list1 0 -1        //获取从头部第一个0到尾部最后一个-1的值
1)world
2)hello


#rpush在key对应的list尾部添加value(先进先出)
lpush list1 "hello"
lpush list1 "world"

lrange list1 0 -1
1)hello
2)world


#linsert在key对应的list指定位置插入value
rpush list2 "world"
linsert list2 before "world" "hello"

lrange list1 0 -1
1)hello
2)world


#lset设置list指定下标的值
lset list1 0 "hi"

#lrem删除list表中指定相同值的个数
lrem list1 3 "one"

#ltrim保留list表中指定范围的元素，删除其它元素
ltrim list1 1 -1

#lpop弹出头部第一个元素
lpop list1

#rpop弹出尾部第一个元素
rpop list1

#rpoplpush弹出第一个list的尾部元素从第二个list的头部添加
rpoplpush list1 list2

#lindex返回key在list中index位置的元素
lindex list1 1

#llen返回list中元素个数
llen list1
```

# zset数据类型(集合有顺序的存储)
```
#zadd往集合中添加元素
zadd set1 1 "one"


#zrange列出有序集合
zrange set1 0 -1 withscores     #0 -1索引，withscores列出顺序号

#zrevrange返向列出有序集合
zrevrange set1 0 -1 withscores

#zrangebyscores通过顺序号列出集合
zrangebysocres set1 2 3 withscores

#zremrangebyrank删除指定索引范围的元素
zremrangebyrank set1 0 -1


#zrem从集合中删除元素
zrem set1 one

#zincrby将集合中指定元素的顺序号增加
zincrby set1 2 one                #将set1集合中one的顺序号的值加2


zrank set1 one                    #zrank返回集合元素的索引号(从小到大)
zrevrank set1 one                #zrank返回集合元素的索引号(从大到小)

#zcount返回指定顺序号范围的元素个数
zcount set1 2 3

#zcard返回集合中元素的总个数
zcard set1
```

# set数据类型(集合无顺序的随机存储)
```
#sadd往集合中添加元素
sadd set1 one

#srem从集合中删除元素
srem set1 one

#smembers查看集合元素
smembers set1


#srandmember随机返回集合中的一个元素
srandmember set1

#spop随机弹出集合中一个元素，并删除元素
spop set1


sdiff set1 set2                            #sdiff取两个集合的差集,返回第一个集合中的不同元素
sdiffstore set1 set2 set3               #取set2 set3集合的差集,返回set2集合中的不同元素存入set1

sinter set1 set2                        #sinter取两个集合的交集
sinterstore set1 set2 set3               #取set2 set3集合的交集存入set1

sunion set1 set2                        #sunion取两个集合的并集
sunionstore set1 set2 set3               #取set2 set3集合的并集存入set1


smove set1 set2 one                        #将set1集合中的one元素移动到set2中

#scard查看集合元素的总个数
scard set1

#sismember判断元素是否在集合中
sismember set1 four
```