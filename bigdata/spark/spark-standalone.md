* https://zhuanlan.zhihu.com/p/583049605
* https://spark.apache.org/docs/latest/
* https://spark.apachecn.org/

>Spark 保持了 MapReduce 的可扩展、分布式、容错处理框架的优势，同时使其更高效、更易于使用；Spark作为Hadoop MapReduce的替代方案，大部分应用场景中，它还要依赖于 HDFS 和 HBase 来存储数据，依赖于 YARN 来管理集群和资源

# 部署spark standalone
* 下载：https://spark.apache.org/downloads.html
```
wget https://dlcdn.apache.org/spark/spark-3.2.1/spark-3.2.1-bin-hadoop3.2.tgz
tar -xzf spark-3.2.1-bin-hadoop3.2.tgz -C /opt
ln -s spark-3.2.1-bin-hadoop3.2 spark
cd spark
```
* 启动 
```
# 启动master server
./sbin/start-master.sh 

# 启动一个或多个 workers 
./sbin/start-slave.sh spark://spark:7077
```
* spark web ui
```
http://spark_master_ip:8080
```

# spark shell
* 在本地spark环境运行代码
```
# spark example
./bin/run-example SparkPi 10 

# spark shell指定master url 为 local 模式，使用 2 个线程在本地运行
./bin/spark-shell --master local[2]
./bin/pyspark --master local[2]
```

# spark submit
* 提交到远程spark集群
```
./bin/spark-submit \
  --class <main-class> \
  --master <master-url> \
  --deploy-mode <deploy-mode> \
  --conf <key>=<value> \
  ... # other options
  <application-jar> \
  [application-arguments]
```
* java应用示例
```
bin/spark-submit --class HelloWorld --master spark://spark:7077 --deploy-mode cluster http://spark.test.com/rs-scala-1.0.0.jar
```