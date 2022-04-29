* https://dolphinscheduler.apache.org/zh-cn/docs/latest/user_doc/guide/installation/pseudo-cluster.html
* https://dolphinscheduler.apache.org/zh-cn/docs/latest/user_doc/guide/installation/cluster.html

# 准备工作
### 安装依赖
```
yum install java-1.8.0-openjdk
```
```
#which java 找到java路径
echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.312.b07-1.amzn2.0.2.x86_64/jre" >>/etc/profile
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
* 安装***
* 初始化mysql
```
mysql -uroot -p

mysql> CREATE DATABASE dolphinscheduler DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
mysql> GRANT ALL PRIVILEGES ON dolphinscheduler.* TO 'dolphinscheduler'@'%' IDENTIFIED BY 'dolphinscheduler';
mysql> GRANT ALL PRIVILEGES ON dolphinscheduler.* TO 'dolphinscheduler'@'localhost' IDENTIFIED BY 'dolphinscheduler';

mysql> flush privileges;
```

### 安装ZooKeeper (3.4.6+)集群,参考zookeeper文档
*


# 安装dolphinscheduler
### 准备 DolphinScheduler 启动环境
* 创建部署用户，并且一定要配置 sudo 免密
>因为任务执行服务是以 sudo -u {linux-user} 切换不同 linux 用户的方式来实现多租户运行作业，所以部署用户需要有 sudo 权限，而且是免密的。

>如果发现 /etc/sudoers 文件中有 "Defaults requirett" 这行，也请注释掉
```
useradd dolphinscheduler
echo "dolphinscheduler" | passwd --stdin dolphinscheduler
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
# 由于安装的时候需要向不同机器发送资源，所以要求各台机器间能实现SSH免密登陆。配置免密登陆的步骤如下
su dolphinscheduler

ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
ssh localhost
# 免密ssh到其它机器
ssh-copy-id dolphinscheduler0X
ssh dolphinscheduler0X
```
* 创建安装、数据目录
```
mkdir /opt/dolphinscheduler
mkdir /data/dolphinscheduler
chown -R dolphinscheduler.dolphinscheduler /opt/dolphinscheduler
chown -R dolphinscheduler.dolphinscheduler /data/dolphinscheduler
```


### [下载二进制安装包](https://www.apache.org/dyn/closer.lua/dolphinscheduler/2.0.5/apache-dolphinscheduler-2.0.5-bin.tar.gz)
* 只需要在其中一个节点上执行集群安装操作
```
wget https://dlcdn.apache.org/dolphinscheduler/2.0.5/apache-dolphinscheduler-2.0.5-bin.tar.gz
tar -xzf apache-dolphinscheduler-2.0.5-bin.tar.gz
chown -R dolphinscheduler:dolphinscheduler apache-dolphinscheduler-2.0.5-bin
```

### 修改相关配置(仅需要修改运行install.sh脚本的所在机器的配置即可)
* vim conf/config/install_config.conf
```
# ---------------------------------------------------------
# INSTALL MACHINE
# ---------------------------------------------------------
# 需要配置master、worker、API server，所在服务器的IP均为机器IP或者localhost
# 如果是配置hostname的话，需要保证机器间可以通过hostname相互链接
# 如下图所示，部署 DolphinScheduler 机器的 hostname 为 ds1,ds2,ds3,ds4,ds5，其中 ds1,ds2 安装 master 服务，ds3,ds4,ds5安装 worker 服务，alert server安装在ds4中，api server 安装在ds5中
ips="dolphinscheduler01,dolphinscheduler02,dolphinscheduler03"
masters="dolphinscheduler01,dolphinscheduler02,dolphinscheduler03"
workers="dolphinscheduler01:default,dolphinscheduler02:default,dolphinscheduler03:default"
alertServer="dolphinscheduler02"
apiServers="dolphinscheduler01"
pythonGatewayServers="dolphinscheduler01"

# DolphinScheduler安装路径，如果不存在会创建
installPath="/opt/dolphinscheduler"

# 部署用户，填写在 **配置用户免密及权限** 中创建的用户
deployUser="dolphinscheduler"

# 数据目录（确保dolphinscheduler用户可读写）
dataBasedirPath="/data/dolphinscheduler"

# ---------------------------------------------------------
# DolphinScheduler ENV
# ---------------------------------------------------------
# JAVA_HOME 的路径，是在 **前置准备工作** 安装的JDK中 JAVA_HOME 所在的位置.
javaHome="/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.312.b07-1.amzn2.0.2.x86_64/jre"

# ---------------------------------------------------------
# Database
# ---------------------------------------------------------
# 数据库的类型，用户名，密码，IP，端口，元数据库db。其中 DATABASE_TYPE 目前支持 mysql, postgresql, H2
# 请确保配置的值使用双引号引用，否则配置可能不生效
DATABASE_TYPE="mysql"
SPRING_DATASOURCE_URL="jdbc:mysql://ds1:3306/ds_201_doc?useUnicode=true&characterEncoding=UTF-8"
# 如果你不是以 dolphinscheduler/dolphinscheduler 作为用户名和密码的，需要进行修改
SPRING_DATASOURCE_USERNAME="dolphinscheduler"
SPRING_DATASOURCE_PASSWORD="dolphinscheduler"

#DATABASE_TYPE="postgresql"
#SPRING_DATASOURCE_URL="jdbc:postgresql://dolphinscheduler03:5432/dolphinscheduler"
#SPRING_DATASOURCE_USERNAME="dolphinscheduler"
#SPRING_DATASOURCE_PASSWORD="dolphinscheduler"

# ---------------------------------------------------------
# Registry Server
# ---------------------------------------------------------
# 注册中心地址，zookeeper服务的地址
registryServers="dolphinscheduler01:2181,dolphinscheduler02:2181,dolphinscheduler03:2181"
```

* 多租户配置
>租户对应的是 Linux 的用户，用于 worker 提交作业所使用的用户。如果 linux 没有这个用户，则会导致任务运行失败。你可以通过修改 worker.properties 配置文件中参数 worker.tenant.auto.create=true 实现当 linux 用户不存在时自动创建该用户。worker.tenant.auto.create=true 参数会要求 worker 可以免密运行 sudo 命令
```
# conf/worker.properties
worker.tenant.auto.create=true
```

### 部署 DolphinScheduler （在其中一个节点上执行）
```
su dolphinscheduler

# 初始化数据库
sh script/create-dolphinscheduler.sh

# 启动DolphinScheduler 
sh install.sh
```

* 启停服务
```
# 一键停止集群所有服务
sh ./bin/stop-all.sh

# 一键开启集群所有服务
sh ./bin/start-all.sh

# 启停 Master
sh ./bin/dolphinscheduler-daemon.sh stop master-server
sh ./bin/dolphinscheduler-daemon.sh start master-server

# 启停 Worker
sh ./bin/dolphinscheduler-daemon.sh start worker-server
sh ./bin/dolphinscheduler-daemon.sh stop worker-server

# 启停 Api
sh ./bin/dolphinscheduler-daemon.sh start api-server
sh ./bin/dolphinscheduler-daemon.sh stop api-server

# 启停 Alert
sh ./bin/dolphinscheduler-daemon.sh start alert-server
sh ./bin/dolphinscheduler-daemon.sh stop alert-server
```

# 登录 DolphinScheduler
```
浏览器访问地址 http://apiServers:12345/dolphinscheduler 即可登录系统UI。默认的用户名和密码是 admin/dolphinscheduler123
```

# DolphinScheduler正常运行提供如下的网络端口配置：
```
MasterServer 5678            # 非通信端口，只需本机端口不冲突即可
WorkerServer 1234            # 非通信端口，只需本机端口不冲突即可
ApiApplicationServer 12345   # 提供后端通信端口
```