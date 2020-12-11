* https://kafka.apache.org/quickstart
* https://my.oschina.net/gemron/blog/830297


# 安装kafka
```
wget http://www-us.apache.org/dist/kafka/0.11.0.1/kafka_2.11-0.11.0.1.tgz
tar -xzf kafka_2.11-0.11.0.1.tgz -C /opt
mv  kafka_2.11-0.11.0.1 kafka
cd /opt/kafka

#修改配置
vim config/zookeeper.properties
dataDir=/data/zookeeper/data

vim config/server.properties
log.dirs=/data/logs/kafka-logs

#启动zookeeper
nohup bin/zookeeper-server-start.sh config/zookeeper.properties &

#启动kafka
nohup bin/kafka-server-start.sh config/server.properties &

#创建主题
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test
#查看主题列表
bin/kafka-topics.sh --list --zookeeper localhost:2181

#通过kafka命令行客户端生产消息
> bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test
This is a message
This is another message

#通过kafka命令行客户端消费消息
> bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning
This is a message
This is another message
```


# 部署kafka集群
```
cp config/server.properties config/server-1.properties 
cp config/server.properties config/server-2.properties

#现在编辑这些新文件并设置以下属性：
config/server-1.properties：
    broker.id = 1
    listeners = PLAINTEXT://:9093
    log.dir = /tmp/kafka-logs-1

config/server-2.properties:
    broker.id = 2
    listeners = PLAINTEXT://:9094
    log.dir = /tmp/kafka-logs-2

#启动另外两个节点
nohup bin/kafka-server-start.sh config/server-1.properties &
nohup bin/kafka-server-start.sh config/server-2.properties &

#创建一个新的主题，复制因子为3
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 3 --partitions 1 --topic my-replicated-topic

#现在我们有一个集群，我们怎么知道哪个代理正在做什么？要看到运行“describe topics”命令：
> bin/kafka-topics.sh --describe --zookeeper localhost:2181 --topic my-replicated-topic
Topic:my-replicated-topic   PartitionCount:1    ReplicationFactor:3 Configs:
    Topic: my-replicated-topic  Partition: 0    Leader: 1   Replicas: 1,2,0 Isr: 1,2,0

“leader”是负责给定分区的所有读取和写入的节点。每个节点将是分区的随机选择部分的领导者。
“replicas”是复制此分区的日志的节点的列表，无论它们是否为引导者，或者即使它们当前处于活动状态。
“isr”是“同步中”副本的集合。这是副本列表的子集，其当前活动并赶上领导者。

#向我们的新主题发布几条消息
> bin/kafka-console-producer.sh --broker-list localhost:9092 --topic my-replicated-topic
...
my test message 1
my test message 2
^C

#消费新主题发布的消息
> bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --from-beginning --topic my-replicated-topic
...
my test message 1
my test message 2
^C

#现在让我们测试容错。broker1担任领导者，所以让我们kill了它：
> ps aux | grep server-1.properties 
7564 ttys002 0：15.91 /System/Library/Frameworks/JavaVM.framework/Versions/1.8/Home/bin/java ...
> kill -9 7564

在Windows上使用：
> wmic process get processid,caption,commandline | find "java.exe" | find "server-1.properties"
java.exe    java  -Xmx1G -Xms1G -server -XX:+UseG1GC ... build\libs\kafka_2.10-0.10.1.0.jar"  kafka.Kafka config\server-1.properties    644
> taskkill /pid 644 /f

#领导已切换到其中一个从属节点，节点1不再处于同步副本集中：
> bin/kafka-topics.sh --describe --zookeeper localhost:2181 --topic my-replicated-topic
Topic:my-replicated-topic    PartitionCount:1    ReplicationFactor:3    Configs:
    Topic: my-replicated-topic    Partition: 0    Leader: 2    Replicas: 1,2,0    Isr: 2,0
#但是消息仍然可用于消费，即使采取写入的领导最初是下来：
> bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --from-beginning --topic my-replicated-topic
...
my test message 1
my test message 2
^C
```


# 使用Kafka Connect导入/导出数据
```
#创建测试数据文件
> echo -e "foo\nbar" > test.txt

#启动Kafka Connect
Kafka包含的这些示例配置文件使用您之前启动的默认本地群集配置，并创建两个连接器：第一个是源连接器，从输入文件读取行并生成每个Kafka主题，第二个是宿连接器它从Kafka主题读取消息，并将其作为输出文件中的一行生成。
> bin/connect-standalone.sh config/connect-standalone.properties config/connect-file-source.properties config/connect-file-sink.properties

>cat test.sink.txt
foo
bar

> bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic connect-test --from-beginning
{"schema":{"type":"string","optional":false},"payload":"foo"}
{"schema":{"type":"string","optional":false},"payload":"bar"}
...

> echo "Another line" >> test.txt
```

