* https://flink.apache.org/zh/
* https://nightlies.apache.org/flink/flink-docs-release-1.15/zh
* https://nightlies.apache.org/flink/flink-docs-release-1.15/zh/docs/try-flink/flink-operations-playground/
* https://nightlies.apache.org/flink/flink-docs-release-1.15/zh/docs/deployment/overview/

# [架构](https://nightlies.apache.org/flink/flink-docs-release-1.15/zh/docs/deployment/overview/#overview-and-reference-architecture)
>Apache Flink 是一个分布式系统，它需要计算资源来执行应用程序。Flink 集成了所有常见的集群资源管理器，例如 Hadoop YARN、 Apache Mesos 和 Kubernetes，但同时也可以作为独立集群运行。
* FlinkClient -  Client 为提交 Job 的客户端，可以是运行在任何机器上（与 JobManager 环境连通即可）。提交 Job 后，Client 可以结束进程（Streaming的任务），也可以不结束并等待结果返回（MapReduce Client：yarn jar hadoop-mapreduce.jar WordCount input ouput）
* JobManager  - 主要负责调度 Job 并协调 Task 做 checkpoint，从 Client 处接收到 Job 和JAR 包等资源后，会生成优化后的执行计划，并以 Task 为单元调度到各个 TaskManager 去执行。（ResourceManager和ApplicationMaster或JobTracker）
* TaskManager - 运行 worker 进程（也称为 worker），在启动的时候就设置好了槽位数（Slot），每个 slot 能启动一个 Task，Task 为线程。从 JobManager 处接收需要部署的 Task，部署启动后，与自己的上游建立连接，接收数据（NodeManager或TaskTracker）


# [本地模式安装](https://nightlies.apache.org/flink/flink-docs-release-1.15/zh/docs/try-flink/local_installation/)
* 安装Java 11
```
java -version
```
* 安装flink
```
wget https://dlcdn.apache.org/flink/flink-1.15.2/flink-1.15.2-bin-scala_2.12.tgz
tar -xzf flink-1.15.2-bin-scala_2.12.tgz -C /usr/local
ln -s flink-1.15.2-bin-scala_2.12 flink
```

# 配置flink
* /etc/hosts
```
10.10.29.145  flinkmaster
10.10.68.204  flinkworker01
10.10.16.45   flinkworker02
```

* conf/flink-conf.yaml 
```
#配置项指向 master 节点
jobmanager.rpc.address: flinkmaster   

#定义 Flink 允许在每个节点上分配的最大内存值
jobmanager.memory.process.size: 4g
taskmanager.memory.process.size: 2g
```

* 配置worker节点, conf/workers
```
flinkworker01
flinkworker02
```

* conf/masters
```
flinkmaster:8081
```

# 启动集群
```
bin/jobmanager.sh start
bin/taskmanager.sh start

# 一键启动集群所有节点（ssh免密）
# ./bin/start-cluster.sh
```

# 提交作业（Job）
>Flink 的 Releases 附带了许多的示例作业。你可以任意选择一个，快速部署到已运行的集群上
```
$ ./bin/flink run examples/streaming/WordCount.jar
$ tail log/flink-*-taskexecutor-*.out
  (nymph,1)
  (in,3)
  (thy,1)
  (orisons,1)
  (be,4)
  (all,2)
  (my,1)
  (sins,1)
  (remember,1)
  (d,4)
```
* flink web ui: http://localhost:8081

# 停止集群
```
bin/jobmanager.sh stop
bin/taskmanager.sh stop

# 一键停止集群所有节点（ssh免密）
# ./bin/stop-cluster.sh
```