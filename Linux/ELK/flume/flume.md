* https://flume.apache.org/releases/content/1.11.0/FlumeUserGuide.html

---
* 文件源
https://flume.apache.org/releases/content/1.11.0/FlumeUserGuide.html#taildir-source
* flume接收器
https://flume.apache.org/releases/content/1.11.0/FlumeUserGuide.html#avro-sink

```yml
# in this case called 'agent'
#agent1 name
agent.channels = c1
agent.sources = fileSource
agent.sinks = k1 k2
#set gruop
agent.sinkgroups = g1

agent.sources.fileSource.type=taildir
agent.sources.fileSource.filegroups=f1 f2
agent.sources.fileSource.filegroups.f1=/fdata/logs/pc/running/trace-[0-9]*.log
agent.sources.fileSource.filegroups.f2=/fdata/logs/m/running/trace-[0-9]*.log
agent.sources.fileSource.positionFile=/fdata/logs/taildir_position.json
#agent.sources.fileSource.skipToEnd=true

agent.sources.fileSource.deserializer.maxLineLength=100000
agent.sources.fileSource.decodeErrorPolicy = IGNORE
agent.sources.fileSource.pollDelay = 1000
agent.sources.fileSource.channels = c1

agent.channels.c1.type=file
agent.channels.c1.dataDirs=/fdata/filechannel
#agent.channels.c1.capacity = 5000
#agent.channels.c1.transactionCapacity = 2000
#agent.channels.c1.keep-alive = 10

# sink1
agent.sinks.k1.channel = c1
agent.sinks.k1.type = avro
agent.sinks.k1.hostname = 10.10.68.204
agent.sinks.k1.port = 6333

# sink2
agent.sinks.k2.channel = c1
agent.sinks.k2.type = avro
agent.sinks.k2.hostname = 10.10.78.106
agent.sinks.k2.port = 6333

#set sink group
agent.sinkgroups.g1.sinks = k1 k2

#set failover
agent.sinkgroups.g1.processor.type = failover
agent.sinkgroups.g1.processor.priority.k1 = 10
agent.sinkgroups.g1.processor.priority.k2 = 1
agent.sinkgroups.g1.processor.maxpenalty = 10000
```

* flume源
https://flume.apache.org/releases/content/1.11.0/FlumeUserGuide.html#avro-source
* kafka接收器
https://flume.apache.org/releases/content/1.11.0/FlumeUserGuide.html#kafka-sink

```yml
agent.sources = s1Flume
agent.channels = c1
agent.sinks =sinkKafka

agent.sources.s1Flume.channels = c1
agent.sources.s1Flume.type = avro
agent.sources.s1Flume.bind = 10.10.68.204
agent.sources.s1Flume.port = 6333

agent.sinks.sinkKafka.type = org.apache.flume.sink.kafka.KafkaSink
agent.sinks.sinkKafka.topic = gb-trace-php
agent.sinks.sinkKafka.brokerList = kafka-log01.test.local:9092,kafka-log02.test.local:9092,kafka-log03.test.local:9092
agent.sinks.sinkKafka.requiredAcks = 1
agent.sinks.sinkKafka.batchSize = 1000
agent.sinks.sinkKafka.channel = c1

agent.channels.c1.type=file
agent.channels.c1.dataDirs=/data/flume/data/filechannel
#agent.channels.c1.capacity = 1000
#agent.channels.c1.transactionCapacity = 600
```