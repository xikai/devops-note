* https://dolphinscheduler.apache.org/zh-cn/docs/latest/user_doc/guide/installation/pseudo-cluster.html
* https://dolphinscheduler.apache.org/zh-cn/docs/latest/user_doc/guide/installation/cluster.html
* https://developer.aliyun.com/article/1060716

# 准备工作
### 安装依赖
```
yum install java-1.8.0-openjdk java-1.8.0-openjdk-devel
```
```
#which java 找到java路径
echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk" >>/etc/profile
source /etc/profile
```

### 安装PostgreSQL (8.2.15+)或者 MySQL (5.7+)
* 安装postgresql-server
```
yum install postgresql-server
```
* 修改data目录
```
mkdir /data/pgsql/data -p
chown -R postgres.postgres /data/pgsql
usermod -d /data/pgsql postgres

#修改/usr/lib/systemd/system/postgresql.service
Environment=PGDATA=/data/pgsql/data
```
* 启动
```
su - postgres -c "pg_ctl -D /data/pgsql/data initdb"
systemctl enable postgresql.service
systemctl start postgresql.service
```
* 登陆,初始化数据库
```
sudo -u postgres psql postgres

postgres=# CREATE DATABASE dolphinscheduler;

#创建用户
postgres=# CREATE USER dolphinscheduler WITH PASSWORD 'dolphinscheduler';

# 授权
postgres=# \c dolphinscheduler;
postgres=# dolphinscheduler=# GRANT ALL ON ALL TABLES IN SCHEMA public TO dolphinscheduler;
```

### 安装MySQL (5.7+)，推荐
* 安装初始化mysql
```
mysql -uroot -p

mysql> CREATE DATABASE dolphinscheduler DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
mysql> GRANT ALL PRIVILEGES ON dolphinscheduler.* TO 'dolphinscheduler'@'10.%.%.%' IDENTIFIED BY 'dolphinscheduler';
mysql> GRANT ALL PRIVILEGES ON dolphinscheduler.* TO 'dolphinscheduler'@'localhost' IDENTIFIED BY 'dolphinscheduler';

mysql> flush privileges;
```

### 安装ZooKeeper (3.4.6+)集群,参考zookeeper文档
*

### 准备 DolphinScheduler 启动环境
* 创建部署用户，并且一定要配置 sudo 免密
>因为任务执行服务是以 sudo -u {linux-user} 切换不同 linux 用户的方式来实现多租户运行作业，所以部署用户需要有 sudo 权限，而且是免密的。

>如果发现 /etc/sudoers 文件中有 "Defaults requirett" 这行，也请注释掉
```
# 创建用户需使用 root 登录
useradd dolphinscheduler

# 添加密码
echo "dolphinscheduler" | passwd --stdin dolphinscheduler

# 配置 sudo 免密
sed -i '$adolphinscheduler  ALL=(ALL)  NOPASSWD: NOPASSWD: ALL' /etc/sudoers
sed -i 's/Defaults    requirett/#Defaults    requirett/g' /etc/sudoers
```
* 配置hosts和SSH机器免密登陆
```
# /etc/hosts
10.10.62.120  dolphinscheduler01
10.10.90.244  dolphinscheduler02
10.10.126.148 dolphinscheduler03
```
```
hostnamectl --static set-hostname dolphinscheduler01
hostnamectl --static set-hostname dolphinscheduler02
hostnamectl --static set-hostname dolphinscheduler03
```

* 由于安装的时候需要向不同机器发送资源，所以要求各台机器间能实现SSH免密登陆。配置免密登陆的步骤如下
```
su - dolphinscheduler

ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
ssh localhost
# 免密ssh到其它机器
ssh-copy-id dolphinscheduler0X
ssh dolphinscheduler0X
```

# 安装dolphinscheduler
### [下载二进制安装包](https://dolphinscheduler.apache.org/zh-cn/download)
```
cd ~
wget https://www.apache.org/dyn/closer.lua/dolphinscheduler/*/apache-dolphinscheduler-*-bin.tar.gz
tar -xzf apache-dolphinscheduler-*-bin.tar.gz

# 修改目录权限，使得部署用户对二进制包解压后的 apache-dolphinscheduler-*-bin 目录有操作权限
chown -R dolphinscheduler:dolphinscheduler apache-dolphinscheduler-*-bin
```

### 修改相关配置(仅需要修改运行install.sh脚本的所在机器的配置即可)
>只需要在第一个节点上执行集群安装操作（可免密ssh登陆其它节点）
* vim bin/env/install_env.sh
```sh
# ---------------------------------------------------------
# INSTALL MACHINE
# ---------------------------------------------------------
# A comma separated list of machine hostname or IP would be installed DolphinScheduler,
# including master, worker, api, alert. If you want to deploy in pseudo-distributed
# mode, just write a pseudo-distributed hostname
# Example for hostnames: ips="ds1,ds2,ds3,ds4,ds5", Example for IPs: ips="192.168.8.1,192.168.8.2,192.168.8.3,192.168.8.4,192.168.8.5"
ips="dolphinscheduler01,dolphinscheduler02,dolphinscheduler03"

# Port of SSH protocol, default value is 22. For now we only support same port in all `ips` machine
# modify it if you use different ssh port
sshPort=${sshPort:-"22"}

# A comma separated list of machine hostname or IP would be installed Master server, it
# must be a subset of configuration `ips`.
# Example for hostnames: masters="ds1,ds2", Example for IPs: masters="192.168.8.1,192.168.8.2"
masters="dolphinscheduler01,dolphinscheduler02,dolphinscheduler03"

# A comma separated list of machine <hostname>:<workerGroup> or <IP>:<workerGroup>.All hostname or IP must be a
# subset of configuration `ips`, And workerGroup have default value as `default`, but we recommend you declare behind the hosts
# Example for hostnames: workers="ds1:default,ds2:default,ds3:default", Example for IPs: workers="192.168.8.1:default,192.168.8.2:default,192.168.8.3:default"
workers="dolphinscheduler01:default,dolphinscheduler02:default,dolphinscheduler03:default"

# A comma separated list of machine hostname or IP would be installed Alert server, it
# must be a subset of configuration `ips`.
# Example for hostname: alertServer="ds3", Example for IP: alertServer="192.168.8.3"
alertServer="dolphinscheduler02"

# A comma separated list of machine hostname or IP would be installed API server, it
# must be a subset of configuration `ips`.
# Example for hostname: apiServers="ds1", Example for IP: apiServers="192.168.8.1"
apiServers="dolphinscheduler01"

# The directory to install DolphinScheduler for all machine we config above. It will automatically be created by `install.sh` script if not exists.
# Do not set this configuration same as the current path (pwd). Do not add quotes to it if you using related path.
installPath="/usr/local/dolphinscheduler"

# The user to deploy DolphinScheduler for all machine we config above. For now user must create by yourself before running `install.sh`
# script. The user needs to have sudo privileges and permissions to operate hdfs. If hdfs is enabled than the root directory needs
# to be created by this user
deployUser="dolphinscheduler"

# The root of zookeeper, for now DolphinScheduler default registry server is zookeeper.
zkRoot=${zkRoot:-"/dolphinscheduler"}
```
* vim bin/env/dolphinscheduler_env.sh
```sh
# JAVA_HOME, will use it to start DolphinScheduler server
export JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk"

# Database related configuration, set database type, username and password
export DATABASE=${DATABASE:-mysql}
export SPRING_PROFILES_ACTIVE=${DATABASE}
export SPRING_DATASOURCE_URL="jdbc:mysql://mysql-master.test.local:3306/dolphinscheduler?useUnicode=true&characterEncoding=UTF-8"
export SPRING_DATASOURCE_USERNAME="dolphinscheduler"
export SPRING_DATASOURCE_PASSWORD="dolphinscheduler"

# DolphinScheduler server related configuration
export SPRING_CACHE_TYPE=${SPRING_CACHE_TYPE:-none}
export SPRING_JACKSON_TIME_ZONE=${SPRING_JACKSON_TIME_ZONE:-UTC}
export MASTER_FETCH_COMMAND_NUM=${MASTER_FETCH_COMMAND_NUM:-10}

# Registry center configuration, determines the type and link of the registry center
export REGISTRY_TYPE=${REGISTRY_TYPE:-zookeeper}
export REGISTRY_ZOOKEEPER_CONNECT_STRING="dolphinscheduler01:2181,dolphinscheduler02:2181,dolphinscheduler03:2181"

# Tasks related configurations, need to change the configuration if you use the related tasks.
export HADOOP_HOME="/usr/local/hadoop"
export HADOOP_CONF_DIR="/usr/local/hadoop/etc/hadoop"
export SPARK_HOME1=${SPARK_HOME1:-/opt/soft/spark1}
export SPARK_HOME2=${SPARK_HOME2:-/opt/soft/spark2}
export PYTHON_HOME=${PYTHON_HOME:-/opt/soft/python}
export HIVE_HOME=${HIVE_HOME:-/opt/soft/hive}
export FLINK_HOME=${FLINK_HOME:-/opt/soft/flink}
export DATAX_HOME=${DATAX_HOME:-/opt/soft/datax}
export SEATUNNEL_HOME=${SEATUNNEL_HOME:-/opt/soft/seatunnel}
export CHUNJUN_HOME=${CHUNJUN_HOME:-/opt/soft/chunjun}

export PATH=$HADOOP_HOME/bin:$SPARK_HOME1/bin:$SPARK_HOME2/bin:$PYTHON_HOME/bin:$JAVA_HOME/bin:$HIVE_HOME/bin:$FLINK_HOME/bin:$DATAX_HOME/bin:$SEATUNNEL_HOME/bin:$CHUNJUN_HOME/bin:$PATH
```

### 初始化数据库
* 使用mysql数据库需要下载mysql-connector-java 驱动 (8.0.16) 并移入 api-server/libs 以及 worker-server/libs 文件夹中，最后重启 api-server 和 worker-server 服务，即可使用 MySQL 数据源
```
wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.28/mysql-connector-java-8.0.28.jar
cp mysql-connector-java-8.0.28.jar apache-dolphinscheduler-*-bin/api-server/libs/
cp mysql-connector-java-8.0.28.jar apache-dolphinscheduler-*-bin/master-server/libs/
cp mysql-connector-java-8.0.28.jar apache-dolphinscheduler-*-bin/worker-server/libs/
cp mysql-connector-java-8.0.28.jar apache-dolphinscheduler-*-bin/alert-server/libs/
cp mysql-connector-java-8.0.28.jar apache-dolphinscheduler-*-bin/tools/libs/
```
* 通过Shell 脚本来初始化数据库
```
bash tools/bin/upgrade-schema.sh
```

### 部署 DolphinScheduler （在其中一个节点上执行）
>通过操作此安装目录分发配置、管理dolphinscheduler节点
```
su - dolphinscheduler
cd ~/apache-dolphinscheduler-*-bin

bash ./bin/install.sh
注意: 第一次部署的话，可能出现 5 次sh: bin/dolphinscheduler-daemon.sh: No such file or directory相关信息，此为非重要信息直接忽略即可
```

# 登录 DolphinScheduler
```
浏览器访问地址 http://apiServers:12345/dolphinscheduler 即可登录系统UI。
默认的用户名和密码是 admin/dolphinscheduler123
```

# 启停服务
* 启停服务
```
# 启停 Master
bash ./bin/dolphinscheduler-daemon.sh start master-server
bash ./bin/dolphinscheduler-daemon.sh stop master-server

# 启停 Worker
bash ./bin/dolphinscheduler-daemon.sh start worker-server
bash ./bin/dolphinscheduler-daemon.sh stop worker-server

# 启停 Api
bash ./bin/dolphinscheduler-daemon.sh start api-server
bash ./bin/dolphinscheduler-daemon.sh stop api-server

# 启停 Alert
bash ./bin/dolphinscheduler-daemon.sh start alert-server
bash ./bin/dolphinscheduler-daemon.sh stop alert-server
```
```
# 一键停止集群所有节点所有服务 (只需要在任一节点执行)
bash ./bin/stop-all.sh

# 一键开启集群所有节点所有服务 (只需要在任一节点执行)
bash ./bin/start-all.sh
```

# DolphinScheduler正常运行提供如下的网络端口配置：
```
MasterServer 5678            # 非通信端口，只需本机端口不冲突即可
WorkerServer 1234            # 非通信端口，只需本机端口不冲突即可
ApiApplicationServer 12345   # 提供后端通信端口
```

# 上传资源文件到s3
* conf/common.properties
```
resource.storage.type=S3
fs.defaultFS=s3a://dolphinscheduler-resource
fs.s3a.endpoint=https://s3.us-west-2.amazonaws.com
fs.s3a.access.key=xxxxxxxxxx
fs.s3a.secret.key=xxxxxxxxxx
```