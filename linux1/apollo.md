* https://www.apolloconfig.com/#/zh/

# [架构组件](https://www.apolloconfig.com/#/zh/design/apollo-design)
![image](https://cdn.jsdelivr.net/gh/apolloconfig/apollo@master/doc/images/overall-architecture.png)
* Config Service: 提供配置获取接口，配置的读取、推送等功能，服务对象是Apollo Client (客户端)
* Admin Service: 提供配置管理接口,配置修改、发布等功能，服务对象是Apollo Portal（管理界面）
* Meta Server: 
  - Portal通过域名访问Meta Server获取Admin Service服务列表（IP+Port）
  - Client 通过域名访问Meta Server获取Config Service服务列表（IP+Port）
  - Meta Server从Eureka获取Config Service和Admin Service的服务信息，相当于是一个Eureka Client
  - Meta Server只是一个逻辑角色，在部署时和Config Service是在一个JVM进程中的，所以IP、端口和Config Service一致
* Eureka: 
  - 基于Eureka和Spring Cloud Netflix提供服务注册和发现
  - Config Service和Admin Service会向Eureka注册服务，并保持心跳
  - 为了简单起见，目前Eureka在部署时和Config Service是在一个JVM进程中的,所以IP、端口和Config Service一致
* Portal: 提供Web界面供用户管理配置, 通过Meta Server获取Admin Service服务列表（IP+Port），通过IP+Port访问服务,在Portal侧做load balance、错误重试
* [Client](https://www.apolloconfig.com/#/zh/design/apollo-design?id=%e4%b8%89%e3%80%81%e5%ae%a2%e6%88%b7%e7%ab%af%e8%ae%be%e8%ae%a1): Apollo提供的客户端程序，为应用提供配置获取、实时更新等功能,通过Meta Server获取Config Service服务列表（IP+Port），通过IP+Port访问服务,在Client侧做load balance、错误重试

# 部署准备
* java 1.8+
```
yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
```
* MySQL 5.6.5+

* 部署案例
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
# 修改logs目录
LOG_DIR=/data/apollo-configserver/logs/

# 设置jvm内存堆栈大小(以下是默认设置)
# export JAVA_OPTS="-server -Xms6144m -Xmx6144m -Xss256k -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=384m -XX:NewSize=4096m -XX:MaxNewSize=4096m -XX:SurvivorRatio=18"
export JAVA_OPTS="-Xms1g -Xmx1g -Xss256k -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=384m -XX:NewSize=512m -XX:MaxNewSize=512m -XX:SurvivorRatio=8"
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
# 修改logs目录
LOG_DIR=/data/apollo-adminserver/logs/

# 设置jvm内存堆栈大小(以下是默认设置)
# export JAVA_OPTS="-Xms2560m -Xmx2560m -Xss256k -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=384m -XX:NewSize=1536m -XX:MaxNewSize=1536m -XX:SurvivorRatio=8"
export JAVA_OPTS="-Xms1g -Xmx1g -Xss256k -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=384m -XX:NewSize=512m -XX:MaxNewSize=512m -XX:SurvivorRatio=8"
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
#fat.meta=http://fill-in-fat-meta-server:8080
#uat.meta=http://fill-in-uat-meta-server:8080
#lpt.meta=${lpt_meta}
#pro.meta=http://fill-in-pro-meta-server:8080

pro.meta=http://10.10.19.133:8080,http://10.10.41.147:8080
uat.meta=http://10.50.139.15:8080
```

* vim adminservice/scripts/startup.sh
```
# 修改logs目录
LOG_DIR=/data/apollo-portal/logs/

# 设置jvm内存堆栈大小(以下是默认设置)
# export JAVA_OPTS="-Xms2560m -Xmx2560m -Xss256k -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=384m -XX:NewSize=1536m -XX:MaxNewSize=1536m -XX:SurvivorRatio=8"
export JAVA_OPTS="-Xms1g -Xmx1g -Xss256k -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=384m -XX:NewSize=512m -XX:MaxNewSize=512m -XX:SurvivorRatio=8"
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


# [指定要注册到eureka的IP](https://www.apolloconfig.com/#/zh/deployment/distributed-deployment-guide?id=_142-%e6%8c%87%e5%ae%9a%e8%a6%81%e6%b3%a8%e5%86%8c%e7%9a%84ip)
* {configservice,adminservice}/scripts/startup.sh
```
export JAVA_OPTS="$JAVA_OPTS -Deureka.instance.ipAddress="configservice_ip/adminservice_ip"
```

# 用户管理
* 新增部门
```
管理员工具 > 系统参数 > organizations > 查询(保存)
```
* 用户管理
```
管理员工具 > 用户管理 (输入的用户名如果不存在，则新建。若已存在，则更新)
```
```
# sql查询数据库，查询所有用户
select * from apolloportaldb.users;
```

# [权限管理](https://www.apolloconfig.com/#/zh/usage/apollo-user-guide?id=_12-%e9%a1%b9%e7%9b%ae%e6%9d%83%e9%99%90%e5%88%86%e9%85%8d)
* 项目创建者默认为项目负责人,且拥有该项目管理员权限

* Namespace的获取权限分为两种：
  - private （私有的）：private权限的Namespace，只能被所属的应用获取到。一个应用尝试获取其它应用private的Namespace，Apollo会报“404”异常。默认的“application” Namespace就是私有类型。
  - public （公共的）：public权限的Namespace，能被任何应用获取。
  - [关联类型（继承类型）](https://www.apolloconfig.com/#/zh/design/apollo-core-concept-namespace?id=_53-%e5%85%b3%e8%81%94%e7%b1%bb%e5%9e%8b)：关联类型具有private权限。关联类型的Namespace继承于公共类型的Namespace，用于覆盖公共Namespace的配置
    - https://www.apolloconfig.com/#/zh/usage/apollo-user-guide?id=%e5%9b%9b%e3%80%81%e5%a4%9a%e4%b8%aaappid%e4%bd%bf%e7%94%a8%e5%90%8c%e4%b8%80%e4%bb%bd%e9%85%8d%e7%bd%ae
    ```
    例如公共的Namespace有两个配置项k1 = v1,k2 = v2;然后应用A有一个关联类型的Namespace关联了此公共Namespace，且覆盖了配置项k1，新值为v3。那么在应用A实际运行时，获取到的公共Namespace的配置为k1 = v3,k2 =  v2
    ```

### [授权](https://www.apolloconfig.com/#/zh/usage/apollo-user-guide?id=_712-%e6%8e%88%e6%9d%83)
>Apollo 支持细粒度的权限控制，请务必根据实际情况做好权限控制：

  * 项目管理员权限
    * Apollo 默认允许所有登录用户创建项目，如果只允许部分用户创建项目，可以开启创建项目权限控制
  * 配置编辑、发布权限
    * 配置编辑、发布权限支持按环境配置，比如开发环境开发人员可以自行完成配置编辑和发布的过程，但是生产环境发布权限交由测试或运维人员
生产环境建议同时开启发布审核，从而控制一次配置发布只能由一个人修改，另一个人发布，确保配置修改得到充分检查
  * 配置查看权限
    * 可以指定某个环境只允许项目成员查看私有Namespace的配置，从而避免敏感配置泄露，如生产环境


# 安全访问
>除了用户权限，在系统访问上也需要加以考虑：
1. apollo-configservice和apollo-adminservice是基于内网可信网络设计的，所以出于安全考虑，禁止apollo-configservice和apollo-adminservice直接暴露在公网
2. 对敏感配置可以考虑开启[访问秘钥](https://www.apolloconfig.com/#/zh/usage/apollo-user-guide?id=_62-%e9%85%8d%e7%bd%ae%e8%ae%bf%e9%97%ae%e5%af%86%e9%92%a5)，从而只有经过身份验证的客户端才能访问敏感配置
3. 1.7.1及以上版本可以考虑为apollo-adminservice开启访问控制，从而只有受控的apollo-portal才能访问对应接口，增强安全性
4. 2.1.0及以上版本可以考虑为eureka开启访问控制，从而只有受控的apollo-configservice和apollo-adminservice可以注册到eureka，增强安全性