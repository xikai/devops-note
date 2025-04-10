* https://www.jianshu.com/p/6018bf6d84e8/


# [修改主题Topic能从Producer接收的最大消息大小](https://kafka.apache.org/documentation/#topicconfigs_max.message.bytes)
```
bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type topics --entity-name testTopic \
  --alter --add-config max.message.bytes=5242940
```
* 检查主题配置项
```
bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type topics --entity-name testTopic --describe
```

# [修改broker消息大小](https://kafka.apache.org/documentation/#brokerconfigs_message.max.bytes)
* vim config/server.properties
```
message.max.bytes=5242940
# 每个分区试图获取的消息字节数。要大于等于message.max.bytes
replica.fetch.max.bytes=6291456 
```
* 更改完配置要重启kafka server才能生效
```
bin/kafka-server-stop.sh
nohup bin/kafka-server-start.sh config/server.properties &
```

# [修改命令行生产者客户端的消息最大请求大小](https://kafka.apache.org/documentation/#producerconfigs_max.request.size)
* vim config/producer.properties 
```
max.request.size=5242940
```
```
# 注：在Linux控制台发送消息时，控制台有输入字数限制，不利于测试，所以将大的消息放在文本文件里test.txt，通过< /usr/local/test.txt追加到控制台
bin/kafka-console-producer.sh --broker-list localhost:9092 --topic testTopic < /usr/local/test.txt --producer.config config/producer.properties
```


# 测试
* 生产一条5M的消息,默认会拦截请求大于1048576字节的消息
```
>bin/kafka-producer-perf-test.sh --producer-props bootstrap.servers=localhost:9092 --topic testTopic --record-size 5242940  --num-records 1 --throughput -1
org.apache.kafka.common.errors.RecordTooLargeException: The message is 5024088 bytes when serialized which is larger than 1048576, which is the value of the max.request.size configuration.

# 增加--producer-props max.request.size=5242940，修改生产者最大消息请求大小
>bin/kafka-producer-perf-test.sh --producer-props bootstrap.servers=localhost:9092 max.request.size=5242940 --topic testTopic --record-size 5242000 --num-records 1 --throughput -1
1 records sent, 3.030303 records/sec (14.52 MB/sec), 323.00 ms avg latency, 323.00 ms max latency, 323 ms 50th, 323 ms 95th, 323 ms 99th, 323 ms 99.9th.
```

* 消费消息（另一个终端同时开启）
```
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic testTopic
```