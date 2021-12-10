
* https://github.com/rabbitmq/rabbitmq-perf-test
* https://www.dazhuanlan.com/noding/topics/1370419

* PerfTest 是 RabbitMQ 吞吐量测试工具，它可以测试 RabbitMQ 节点或 RabbitMQ 集群的基本性能。它基于 Java 客户端，可以配置为模拟基本工作负载和更高级的工作负载。通常在计算机和 RabbitMQ 节点上有足够的 CPU 核心时可以产生更高的吞吐量。同时运行的多个 PerfTest 实例可模拟更实际的工作负载。PerfTest 还有一些额外的工具，比如输出 HTML 图表。


# 下载安装
* 安装rabbit-perftest之前需要配置好java环境
```
[root@rabbitmq01 www]# java -version
java version "1.8.0_301"
Java(TM) SE Runtime Environment (build 1.8.0_301-b09)
Java HotSpot(TM) 64-Bit Server VM (build 25.301-b09, mixed mode)  

wget https://github.com/rabbitmq/rabbitmq-perf-test/releases/download/v2.15.0/rabbitmq-perf-test-2.15.0-bin.tar.gz
tar -zxvf rabbitmq-perf-test-2.15.0-bin.tar.gz -C /usr/local
cd /usr/local/rabbitmq-perf-test-2.15.0/bin

# 测试是否安装成功，在$HOME/bin目录下运行
./runjava com.rabbitmq.perf.PerfTest --help
```

* 出现命令选项参数说明安装成功
```
runjava命令参数详解介绍：https://rabbitmq.github.io/rabbitmq-perf-test/milestone/htmlsingle/#simulating-high-loads

* runjava命令选项参数说明：
-a,--autoack：客户端在处理完messages之后会给服务端返回一个ack确认信息，服务端在收到该ack信息之后才会把messages删除
-ad,--auto-delete <arg>：队列是否自动删除，该参数默认为 true
-d,--id <arg>：本次测试的编号，身份标识
-D,--cmessages <arg>：消费者要消费的消息数量，也就是指定这次测试中消费者一共要消费多少条消息，一旦消费者消费了这么多条消息，消费者就会被停止
-f,--flag <arg>：消息标志，多个可以用逗号隔开，支持的值：persistent(持久性)和mandatory(强制性)
-h,--uri <arg>：连接到RabbitMQ的URI地址（格式:amqp://用户名:密码@节点IP:port）
-hst,--heartbeat-sender-threads <arg>：生产者和消费者的心跳发送者的线程数量
-L,--consumer-latency <arg>：设置以微秒为单位的固定消费者延迟（例:--consumer-latency 1000 ：设置了1毫秒的延迟）
-ms,--use-millis：是否收集延迟时间，单位毫秒。默认是关闭的。如果生产者和消费者在不同的主机上运行，那么就将其设置成为true
-mp,--message-properties <arg>：消息属性以逗号隔开的键值对方式，比如priority=5
-p,--predeclared：允许使用预先声明的对象
-qp,--queue-pattern <arg>：按顺序依次创建的队列名称模式，该--queue-pattern值是 Java printf 样式的格式字符串。（例如:--queue-pattern 'perf-test-%d' --queue-pattern-from 1 --queue-pattern-to 500，将创建从perf-test-001到 perf-test-500的队列）
-qpf,--queue-pattern-from <arg>：队列名称模式范围开头（含）
-qpt,--queue-pattern-to <arg>：队列名称模式范围结尾（含）
-r,--rate <arg>：生产者速度限制
-R,--consumer-rate <arg>：消费者速度限制
-s,--size <arg>：设置消息大小，单位是字节（默认12字节）
-u,--queue <arg>：队列名称
-vl,--variable-latency <arg>：设置可变消费者的等待时间（例:--variable-latency 1000:60 --variable-latency 1000000:30 置为 1 ms 持续 60 秒，然后设置为 1 秒持续 30 秒）
-x,--producers <arg>：生产者数量
-y,--consumers <arg>：消费者数量
-z,--time <arg>：运行时间，单位是秒（默认没有限制）
```
```
./runjava com.rabbitmq.perf.PerfTest -h "amqp://admin:123456@10.10.3.177:5672" \
--queue-pattern 'perf-test-%d' --queue-pattern-from 1 --queue-pattern-to 50 \
-s 1000 -a -d "test1" \
--producers 1 --consumers 10
```