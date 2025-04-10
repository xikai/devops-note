* 创建1个分区 3个副本的主题
```
bin/kafka-topics.sh --bootstrap-server 10.10.9.18:9092 --create --partitions 1 --replication-factor 3 --topic test13
bin/kafka-topics.sh --bootstrap-server 10.10.9.18:9092 --list
```

* 生产者
```
--topic：测试topic名
--num-records NUM-RECORDS：产生的消息数量
--payload-delimiter PAYLOAD-DELIMITER： 当指定--payload-file参数时，可以提供分割符。注意：如果没有--payload-file参数，该参数不会生效(default: \n)
--throughput THROUGHPUT：每秒的吞吐量，即每秒多少条消息，设成-1，表示不限流，可测出生产者最大吞吐量。
--producer-props PROP-NAME=PROP-VALUE [PROP-NAME=PROP-VALUE ...]：kafka生产者相关的配置属性，比如bootstrap.servers，client.id 等等，该参数指定的配置参数比--producer.config指定的配置参数优先级高
--producer.config CONFIG-FILE：生产者的配置文件
--print-metrics：在最后输出测试的指标(default: false)
--transactional-id TRANSACTIONAL-ID：当 transaction-duration-ms > 0 时使用的 transactionalId。在测试并发事务的性能时很有用(default: performance-producer-default-transactional-id)
--transaction-duration-ms TRANSACTION-DURATION：
--record-size RECORD-SIZE：单条消息的字节大小，注意：只能提供 --record-size 和--payload-file其中的一个参数，不可以全部都指定
--payload-file PAYLOAD-FILE：读取消息的文件，必须是 UTF-8编码的文本文件
--help：查看帮助
注意： --record-size和--payload-file参数，是必须要指定的，但只能指定其中的一个参数，不可以全部指定。
```
```
bin/kafka-producer-perf-test.sh --producer-props bootstrap.servers=10.10.9.18:9092 --topic test13 --record-size 1000 --num-records 100000 --throughput -1 
42435 records sent, 8485.3 records/sec (8.09 MB/sec), 1539.8 ms avg latency, 3039.0 ms max latency.
46528 records sent, 9303.7 records/sec (8.87 MB/sec), 3502.4 ms avg latency, 3599.0 ms max latency.
100000 records sent, 8954.154728 records/sec (8.54 MB/sec), 2662.00 ms avg latency, 3599.00 ms max latency, 3405 ms 50th, 3585 ms 95th, 3593 ms 99th, 3595 ms 99.9th.
```

* 消费者
```
##注释：default<默认>、REQUIRED（必须参数）
--bootstrap-server <String: server specified>：<REQUIRED>:连接指定kafka server
--broker-list<String: host>：<REQUIRED>:kafka server
--consumer.config <String: config file>： 消费者配置文件
--date-format <String: date format>：日期格式，见 java.text. SimpleDateFormat.(default: yyyy-MM-dd HH:mm:ss:SSS)
--fetch-size <Integer: size>：单次请求提取的数据量 (default:1048576)
--from-latest：如果消费者还没有建立偏移量，则从最新的消息开始消费，而不是最早的消息
--group<String: gid>：消费者组ID (default: perf-consumer-69057)
--hide-header：如果设置，将不会打印状态头信息
--message-size<Integer:size>： 单条消息大小(default:100)
--messages<Long:count>：<REQUIRED>:消费或发送消息总数
--num-fetch-threads <Integer:count>：抓取的线程数量 (default:1)
--print-metrics：打印指标
--threads<Integer:count>：处理线程数量 (default:10) --timeout [Long: milliseconds]： 允许返回数据的最大超时时间(default: 10000)
--topic<String:topic>：<REQUIRED>:消费的主题
--help：查看帮助
```
```
bin/kafka-consumer-perf-test.sh --broker-list 10.10.9.18:9092 --topic test13 --fetch-size 1000 --messages 100000 --threads 0
WARNING: option [threads] and [num-fetch-threads] have been deprecated and will be ignored by the test
start.time, end.time, data.consumed.in.MB, MB.sec, data.consumed.in.nMsg, nMsg.sec, rebalance.time.ms, fetch.time.ms, fetch.MB.sec, fetch.nMsg.sec
2021-11-27 10:13:13:677, 2021-11-27 10:13:17:708, 95.3674, 23.6585, 100000, 24807.7400, 425, 3606, 26.4469, 27731.5585
```