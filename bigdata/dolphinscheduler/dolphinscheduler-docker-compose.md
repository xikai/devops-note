* https://dolphinscheduler.apache.org/zh-cn/docs/latest/user_doc/guide/installation/docker.html

# docker-compose安装
```sh
# 172.31.40.12
wget https://dlcdn.apache.org/dolphinscheduler/2.0.5/apache-dolphinscheduler-2.0.5-src.tar.gz
tar -xzf apache-dolphinscheduler-2.0.5-src.tar.gz
cd apache-dolphinscheduler-2.0.5-src/docker/docker-swarm
docker-compose up -d
```

* 登陆
```
http://172.31.40.12:12345/dolphinscheduler
admin
dolphinscheduler123
```

# 如何通过 docker-compose 扩缩容 master 和 worker？
```
扩缩容 master 至 2 个实例:
docker-compose up -d --scale dolphinscheduler-master=2 dolphinscheduler-master
扩缩容 worker 至 3 个实例:
docker-compose up -d --scale dolphinscheduler-worker=3 dolphinscheduler-worker
```

# 在其它主机启动worker容器
* postgresql
```
docker run -d --name dolphinscheduler-worker \
--net=host \
-e DATABASE_HOST="172.31.40.12" -e DATABASE_PORT="5432" -e DATABASE_DATABASE="dolphinscheduler" \
-e DATABASE_USERNAME="root" -e DATABASE_PASSWORD="root" \
-e REGISTRY_PLUGIN_NAME=zookeeper \
-e REGISTRY_SERVERS=172.31.40.12:2181 \
apache/dolphinscheduler:latest worker-server
```
* mysql
```
docker run -d --name dolphinscheduler-worker \
--net=host \
-e DATABASE_TYPE=mysql \
-e DATABASE_DRIVER="com.mysql.jdbc.Driver" \
-e DATABASE_HOST="172.31.40.12" -e DATABASE_PORT="3306" -e DATABASE_DATABASE="dolphinscheduler" -e DATABASE_PARAMS="useUnicode=true&characterEncoding=UTF-8" \
-e DATABASE_USERNAME="dolphinscheduler" -e DATABASE_PASSWORD="123456" \
-e REGISTRY_PLUGIN_NAME=zookeeper \
-e REGISTRY_SERVERS="zk_mid01:2181,zk_mid02:2181,zk_mid03:2181" \
-e WORKER_SERVER_OPTS="-Dworker.listen.port=1235" \
-e WORKER_GROUPS="default,rsearch-training" \
apache/dolphinscheduler:2.0.5-bab-lr worker-server
```

# worker环境部署
* vim Dockerfile
```
FROM apache/dolphinscheduler:2.0.5

RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/' /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends python-pip \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade setuptools
RUN pip install --upgrade google-cloud-bigquery pyarrow -i https://pypi.tuna.tsinghua.edu.cn/simple

ADD google-cloud-sdk-377.0.0-linux-x86_64.tar.gz /opt
```
* 在worker中部署spark（因为存储卷 dolphinscheduler-shared-local 被挂载到 /opt/soft, 因此 /opt/soft 中的所有文件都不会丢失）
```
docker cp spark-3.2.1-bin-hadoop3.2.tgz docker-swarm_dolphinscheduler-worker_1:/opt/soft
```
```
docker exec -it docker-swarm_dolphinscheduler-worker_1 bash
cd /opt/soft
tar zxf spark-2.4.7-bin-hadoop2.7.tgz
rm -f spark-2.4.7-bin-hadoop2.7.tgz
ln -s spark-2.4.7-bin-hadoop2.7 spark2 # 或者 mv
$SPARK_HOME2/bin/spark-submit --version
```
* vim config.env.sh
```
SPARK_HOME2=/opt/soft/spark-3.2.1-bin-hadoop3.2
```

# 配置连接外部hadoop
### 外部hadoop配置
* etc/hadoop/core-site.xml
```
<configuration>
    <!-- NameNode监听地址 -->
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://172.31.14.200:9000</value>
    </property>
</configuration>
```
* etc/hadoop/hdfs-site.xml
```
<configuration>
    <!-- 关闭用户权限检查：因为容器里面使用root用户执行 -->
    <property>
        <name>dfs.permissions</name>
        <value>false</value>
    </property>
</configuration>
```

### 拷贝hadoop配置文件
```
mkdir etc
cp -r /opt/hadoop/etc/hadoop ./etc/hadoop
```
* 挂载hadoop配置目录, docker-compose.yml
```
  dolphinscheduler-worker:
    ……
    volumes:
    ……
    - ./etc/hadoop:/opt/etc/hadoop   # 挂载hadoop配置
```
* vim config.env.sh
```
HADOOP_CONF_DIR=/opt/etc/hadoop
```

### ds容器中的spark-yarn配置
* vim ./etc/hadoop/yarn-site.xml
```
<configuration>
  <!-- 配置连接外部yarn RM -->
  <property>
    <name>yarn.resourcemanager.address</name>
    <value>172.31.14.200:8032</value>
  </property>
</configuration>
```