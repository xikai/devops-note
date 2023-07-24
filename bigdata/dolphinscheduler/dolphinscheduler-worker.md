* https://dolphinscheduler.apache.org/zh-cn/docs/latest/user_doc/guide/installation/standalone.html

### 安装依赖
```
yum install java-1.8.0-openjdk java-1.8.0-openjdk-devel 
```
```
#which java 找到java路径
echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk" >>/etc/profile
source /etc/profile
```

# 配置dolphinscheduler worker
* vim conf/env/dolphinscheduler_env.sh
```
export HADOOP_CONF_DIR=/opt/soft/hadoop/etc/hadoop
export SPARK_HOME2=/usr/lib/spark
export JAVA_HOME=${JAVA_HOME:-/usr/lib/jvm/java-1.8.0-openjdk}
```

* vim conf/config/install_config.conf
> DS集群的自动安装、启动&关闭 会加载install_config.conf
```
# ---------------------------------------------------------
# INSTALL MACHINE
# ---------------------------------------------------------
ips="localhost"
sshPort="22"
masters="172.31.40.12"
workers="localhost:default"
alertServer="172.31.40.12"
apiServers="172.31.40.12"
pythonGatewayServers="172.31.40.12"

# ---------------------------------------------------------
# DolphinScheduler ENV
# ---------------------------------------------------------
# JAVA_HOME 的路径，是在 **前置准备工作** 安装的JDK中 JAVA_HOME 所在的位置
javaHome="/usr/lib/jvm/temurin-8-jdk-amd64"

# ---------------------------------------------------------
# Database
# ---------------------------------------------------------
DATABASE_TYPE="postgresql"
SPRING_DATASOURCE_URL="jdbc:postgresql://172.31.40.12:5432/dolphinscheduler"
SPRING_DATASOURCE_USERNAME="root"
SPRING_DATASOURCE_PASSWORD="root"

# ---------------------------------------------------------
# Registry Server
# ---------------------------------------------------------
registryServers="172.31.40.12:2181"
```

* vim conf/registry.properties
```
registry.plugin.name=zookeeper
registry.servers=52.83.20.115:2181
registry.namespace=dolphinscheduler
```

# 启动worker
```
bash ./bin/dolphinscheduler-daemon.sh start worker-server
bash ./bin/dolphinscheduler-daemon.sh stop worker-server
```

