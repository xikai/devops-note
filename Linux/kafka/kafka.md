* https://kafka.apache.org/quickstart
* http://kafka.apache.org/documentation/#gettingStarted
* https://cloud.tencent.com/developer/article/1532226
* https://zhuanlan.zhihu.com/p/371886710


# 安装kafka
```
wget http://www-us.apache.org/dist/kafka/0.11.0.1/kafka_2.11-0.11.0.1.tgz
tar -xzf kafka_2.11-0.11.0.1.tgz -C /opt
mv  kafka_2.11-0.11.0.1 kafka
cd /opt/kafka
```
* 查看kafka版本号
```
# lib文件名包含版本信息
ls kafka/libs
```

### 配置zookeeper(所有节点)
* vim config/zookeeper.properties
```
dataDir=/data/zookeeper/data
dataLogDir=/data/zookeeper/logs
# the port at which the clients will connect
clientPort=2181
# disable the per-ip limit on the number of connections since this is a non-production config
maxClientCnxns=0
# Disable the adminserver by default to avoid port conflicts.
# Set the port to something non-conflicting if choosing to enable this
admin.enableServer=false
# admin.serverPort=8080
initLimit=5
syncLimit=2
server.1=kafka01:2888:3888
server.2=kafka02:2888:3888
server.3=kafka03:2888:3888
```
* 启动zookeeper
```
nohup bin/zookeeper-server-start.sh config/zookeeper.properties &
```
### 配置kafka broker(所有节点)
* vim config/server.properties
```
broker.id = 1  # 每个节点id必须唯一
listeners = PLAINTEXT://:9092
log.dirs = /data/kafka/logs
zookeeper.connect=kafka01:2181,kafka02:2181,kafka03:2181
```
* 启动kafka
```
nohup bin/kafka-server-start.sh config/server.properties &
```

# topic 
```
# 查看主题列表
bin/kafka-topics.sh --bootstrap-server localhost:9092 --list

# 创建主题
bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic my-topic \
  --partitions 1 --replication-factor 1
# 创建主题时修改配置
bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic my-topic \
--partitions 1 --replication-factor 1 --config max.message.bytes=5242940 --config flush.messages=1

# 查看主题配置
bin/kafka-topics.sh --bootstrap-server localhost:9092 --topic my-topic --describe

# 修改主题
bin/kafka-topics.sh --bootstrap-server localhost:9092 --alter --topic my_topic_name \
  --partitions 3

# 删除主题
bin/kafka-topics.sh --bootstrap-server localhost:9092 --delete --topic my_topic_name
```
```
# 增加主题配置项
bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type topics --entity-name my-topic \
  --alter --add-config max.message.bytes=5242940

# 删除覆盖配置项
bin/kafka-configs.sh --bootstrap-server localhost:9092  --entity-type topics --entity-name my-topic \
  --alter --delete-config max.message.bytes

# 检查主题配置项
bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type topics --entity-name my-topic --describe
```

# producer 
```
# 通过kafka命令行客户端生产消息
> bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test
This is a message
This is another message
```

# consumer 
```
# 通过kafka命令行客户端消费消息
> bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning
This is a message
This is another message
```



# UnlockExperimentalVMOptions报错：
```
Error: VM option 'UseG1GC' is experimental and must be enabled via -XX:+UnlockExperimentalVMOptions.
Error: Could not create the Java Virtual Machine.
Error: A fatal exception has occurred. Program will exit.
```
* vim bin/kafka-run-class.sh
```
if [ "x$KAFKA_HEAP_OPTS" = "x" ]; then
    KAFKA_HEAP_OPTS="-Xmx1G -Xms1G -XX:+UnlockExperimentalVMOptions"
fi
```