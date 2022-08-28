* https://www.apolloconfig.com/#/zh/

# 部署准备
* java 1.8+
* MySQL 5.6.5+

* Apollo目前支持以下环境：
```
DEV 开发环境
FAT 测试环境，相当于alpha环境(功能测试)
UAT 集成环境，相当于beta环境（回归测试）
PRO 生产环境
```

* apollo服务端口：
```
JVM8080：对外暴露的网络端口是8080，里面有Meta Server，Eureka，Config Service，其中Config Service又使用了ConfigDB
JVM8090：对外暴露的网络端口是8090，里面有Admin Service，并且Admin Service使用了ConfigDB
JVM8070：对外暴露的网络端口是8070，里面有Portal，并且Portal使用了PortalDB
```

* 部署方式
```
1台部署Portal和mysql
每个环境部署一套Config Service和Admin Service
```

# 创建数据库
* [导入数据库](https://github.com/apolloconfig/apollo/blob/v1.9.2/scripts/sql) -> raw
```
wget https://raw.githubusercontent.com/apolloconfig/apollo/v1.9.2/scripts/sql/apolloconfigdb.sql
wget https://raw.githubusercontent.com/apolloconfig/apollo/v1.9.2/scripts/sql/apolloportaldb.sql
```
```
mysql -uroot -p
source /opt/apollo/apolloconfigdb.sql;
source /opt/apollo/apolloportaldb.sql;
```
```
create user 'apollo'@'%' identified by 'abc123';
grant all on Apollo*.* to 'apollo'@'%';
grant all on ApolloPortalDB.* to 'apollo'@'%';
flush privileges;
```


# 部署apollo
* 下载安装包
```
# 下载最新版本的apollo-configservice-x.x.x-github.zip、apollo-adminservice-x.x.x-github.zip和apollo-portal-x.x.x-github.zip
https://github.com/apolloconfig/apollo/releases/tag/v1.9.2
```
```
mkdir -p /opt/apollo/{configservice,adminservice,portal}
unzip apollo-configservice-x.x.x-github.zip -d configservice
unzip apollo-adminservice-x.x.x-github.zip -d adminservice
unzip apollo-portal-x.x.x-github.zip -d portal
```

### 配置configservice
* vim configservice/config/application-github.properties
```
spring.datasource.url = jdbc:mysql://localhost:3306/ApolloConfigDB?characterEncoding=utf8
spring.datasource.username = apollo
spring.datasource.password = abc123
```
* vim configservice/scripts/startup.sh
```
# 设置jvm内存堆栈大小(以下是默认设置)
# export JAVA_OPTS="-server -Xms6144m -Xmx6144m -Xss256k -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=384m -XX:NewSize=4096m -XX:MaxNewSize=4096m -XX:SurvivorRatio=18"
export JAVA_OPTS="-Xms1024m -Xmx1024m -Xss256k -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=384m -XX:NewSize=512m -XX:MaxNewSize=512m -XX:SurvivorRatio=8"
```
* 启动configservice
```
./configservice/scripts/startup.sh
```

### 配置adminservice
* vim adminservice/config/application-github.properties
```
# mysql5.7 需要加useSSL=false
spring.datasource.url = jdbc:mysql://localhost:3306/ApolloConfigDB?characterEncoding=utf8&useSSL=false
spring.datasource.username = apollo
spring.datasource.password = abc123
```
* vim adminservice/scripts/startup.sh
```
# 设置jvm内存堆栈大小(以下是默认设置)
# export JAVA_OPTS="-Xms2560m -Xmx2560m -Xss256k -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=384m -XX:NewSize=1536m -XX:MaxNewSize=1536m -XX:SurvivorRatio=8"
export JAVA_OPTS="-Xms512m -Xmx512m -Xss256k -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=384m -XX:NewSize=256m -XX:MaxNewSize=256m -XX:SurvivorRatio=8"
```
* 启动adminservice
```
./adminservice/scripts/startup.sh
```


### 配置portal
* vim portal/config/application-github.properties
```
spring.datasource.url = jdbc:mysql://localhost:3306/ApolloPortalDB?characterEncoding=utf8&useSSL=false
spring.datasource.username = apollo
spring.datasource.password = abc123
```
* vim portal/config/apollo-env.properties
>apollo-configservice同时承担meta server职责，如果要修改端口，注意要同时ApolloConfigDB.ServerConfig表中的eureka.service.url配置项以及apollo-portal和apollo-client中的使用到的meta server信息
```yaml
# Apollo Portal需要在不同的环境访问不同的meta service(apollo-configservice)地址，所以我们需要在配置中提供这些信息。默认情况下，meta service和config service是部署在同一个JVM进程，所以meta service的地址就是config service的地址。对于1.6.0及以上版本，可以通过Mysql中ApolloPortalDB.ServerConfig表的配置项来配置Meta Service地址，详见apollo.portal.meta.servers - 各环境Meta Service列表
# 如果某个环境不需要，也可以直接删除对应的配置项
#local.meta=http://localhost:8080
dev.meta=http://localhost:8080
#fat.meta=http://fill-in-fat-meta-server:8080
#uat.meta=http://fill-in-uat-meta-server:8080
#lpt.meta=${lpt_meta}
#pro.meta=http://fill-in-pro-meta-server:8080
```

* vim adminservice/scripts/startup.sh
```
# 设置jvm内存堆栈大小(以下是默认设置)
# export JAVA_OPTS="-Xms2560m -Xmx2560m -Xss256k -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=384m -XX:NewSize=1536m -XX:MaxNewSize=1536m -XX:SurvivorRatio=8"
export JAVA_OPTS="-Xms512m -Xmx512m -Xss256k -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=384m -XX:NewSize=256m -XX:MaxNewSize=256m -XX:SurvivorRatio=8"
```
* 启动portal
```
./portal/scripts/startup.sh
```

# 访问apollo portal
```
http://117.50.126.249:8070/
apollo
admin
```


# [注册到指定的eureka](https://www.apolloconfig.com/#/zh/deployment/distributed-deployment-guide?id=_142-%e6%8c%87%e5%ae%9a%e8%a6%81%e6%b3%a8%e5%86%8c%e7%9a%84ip)
* {configservice,adminservice}/scripts/startup.sh
```
export JAVA_OPTS="$JAVA_OPTS -Deureka.instance.ipAddress="172.31.87.191"
```