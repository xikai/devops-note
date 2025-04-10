### docker-compose安装zabbix-server
* 下载zabbix-server docker配置文件
```
git clone https://github.com/zabbix/zabbix-docker.git
git checkout 4.0.10
```

* 修改docker-compose配置
>cp docker-compose_v3_alpine_mysql_latest.yaml docker-compose.yaml
```
version: '3.5'
services:
 zabbix-server:
  image: zabbix/zabbix-server-mysql:alpine-4.0-latest
  ports:
   - "10051:10051"
  volumes:
   - /etc/localtime:/etc/localtime:ro
   - /etc/timezone:/etc/timezone:ro
   - ./zbx_env/usr/lib/zabbix/alertscripts:/usr/lib/zabbix/alertscripts:ro
   - ./zbx_env/usr/lib/zabbix/externalscripts:/usr/lib/zabbix/externalscripts:ro
   - ./zbx_env/var/lib/zabbix/modules:/var/lib/zabbix/modules:ro
   - ./zbx_env/var/lib/zabbix/enc:/var/lib/zabbix/enc:ro
   - ./zbx_env/var/lib/zabbix/ssh_keys:/var/lib/zabbix/ssh_keys:ro
   - ./zbx_env/var/lib/zabbix/mibs:/var/lib/zabbix/mibs:ro
   - ./zbx_env/var/lib/zabbix/snmptraps:/var/lib/zabbix/snmptraps:ro
  links:
   - mysql-server:mysql-server
   - zabbix-java-gateway:zabbix-java-gateway
  ulimits:
   nproc: 65535
   nofile:
    soft: 20000
    hard: 40000
  deploy:
   resources:
    limits:
      cpus: '0.70'
      memory: 1G
    reservations:
      cpus: '0.5'
      memory: 512M
  env_file:
   - .env_db_mysql
   - .env_srv
  user: root
  depends_on:
   - mysql-server
   - zabbix-java-gateway
   - zabbix-snmptraps
  networks:
   zbx_net_backend:
     aliases:
      - zabbix-server
      - zabbix-server-mysql
      - zabbix-server-alpine-mysql
      - zabbix-server-mysql-alpine
   zbx_net_frontend:
#  devices:
#   - "/dev/ttyUSB0:/dev/ttyUSB0"
  stop_grace_period: 30s
  sysctls:
   - net.ipv4.ip_local_port_range=1024 65000
   - net.ipv4.conf.all.accept_redirects=0
   - net.ipv4.conf.all.secure_redirects=0
   - net.ipv4.conf.all.send_redirects=0
  labels:
   com.zabbix.description: "Zabbix server with MySQL database support"
   com.zabbix.company: "Zabbix SIA"
   com.zabbix.component: "zabbix-server"
   com.zabbix.dbtype: "mysql"
   com.zabbix.os: "alpine"


 zabbix-web-apache-mysql:
  image: zabbix/zabbix-web-apache-mysql:alpine-4.0-latest
  ports:
   - "80:80"
   - "443:443"
  links:
   - mysql-server:mysql-server
   - zabbix-server:zabbix-server
  volumes:
   - /etc/localtime:/etc/localtime:ro
   - /etc/timezone:/etc/timezone:ro
   - ./zbx_env/etc/ssl/apache2:/etc/ssl/apache2:ro
  deploy:
   resources:
    limits:
      cpus: '0.70'
      memory: 512M
    reservations:
      cpus: '0.5'
      memory: 256M
  env_file:
   - .env_db_mysql
   - .env_web
  user: root
  depends_on:
   - mysql-server
   - zabbix-server
  healthcheck:
   test: ["CMD", "curl", "-f", "http://localhost"]
   interval: 10s
   timeout: 5s
   retries: 3
   start_period: 30s
  networks:
   zbx_net_backend:
    aliases:
     - zabbix-web-apache-mysql
     - zabbix-web-apache-alpine-mysql
     - zabbix-web-apache-mysql-alpine
   zbx_net_frontend:
  stop_grace_period: 10s
  sysctls:
   - net.core.somaxconn=65535
  labels:
   com.zabbix.description: "Zabbix frontend on Apache web-server with MySQL database support"
   com.zabbix.company: "Zabbix SIA"
   com.zabbix.component: "zabbix-frontend"
   com.zabbix.webserver: "apache2"
   com.zabbix.dbtype: "mysql"
   com.zabbix.os: "alpine"


 zabbix-java-gateway:
  image: zabbix/zabbix-java-gateway:alpine-4.0-latest
  ports:
   - "10052:10052"
  deploy:
   resources:
    limits:
      cpus: '0.5'
      memory: 512M
    reservations:
      cpus: '0.25'
      memory: 256M
  env_file:
   - .env_java
  user: root
  networks:
   zbx_net_backend:
    aliases:
     - zabbix-java-gateway
     - zabbix-java-gateway-alpine
  stop_grace_period: 5s
  labels:
   com.zabbix.description: "Zabbix Java Gateway"
   com.zabbix.company: "Zabbix SIA"
   com.zabbix.component: "java-gateway"
   com.zabbix.os: "alpine"

 zabbix-snmptraps:
  image: zabbix/zabbix-snmptraps:alpine-4.0-latest
  ports:
   - "162:162/udp"
  volumes:
   - ./zbx_env/var/lib/zabbix/snmptraps:/var/lib/zabbix/snmptraps:rw
  deploy:
   resources:
    limits:
      cpus: '0.5'
      memory: 256M
    reservations:
      cpus: '0.25'
      memory: 128M
  user: root
  networks:
   zbx_net_frontend:
    aliases:
     - zabbix-snmptraps
   zbx_net_backend:
  stop_grace_period: 5s
  labels:
   com.zabbix.description: "Zabbix snmptraps"
   com.zabbix.company: "Zabbix SIA"
   com.zabbix.component: "snmptraps"
   com.zabbix.os: "ubuntu"

 mysql-server:
  image: mysql:8.0
  command: [mysqld, --character-set-server=utf8, --collation-server=utf8_bin, --default-authentication-plugin=mysql_native_password]
  volumes:
   - ./zbx_env/var/lib/mysql:/var/lib/mysql:rw
  env_file:
   - .env_db_mysql
  user: root
  stop_grace_period: 1m
  networks:
   zbx_net_backend:
    aliases:
     - mysql-server
     - zabbix-database
     - mysql-database


networks:
  zbx_net_frontend:
    driver: bridge
    driver_opts:
      com.docker.network.enable_ipv6: "false"
    ipam:
      driver: default
      config:
      - subnet: 172.16.238.0/24
  zbx_net_backend:
    driver: bridge
    driver_opts:
      com.docker.network.enable_ipv6: "false"
    internal: true
    ipam:
      driver: default
      config:
      - subnet: 172.16.239.0/24
```
```
#启动zabbix-server组件
docker-compose up -d
```

* alpine安装python3、requests
```
docker-compose exec -T zabbix-server apk add python3
docker-compose exec -T zabbix-server ln -s /usr/bin/python3 /usr/bin/python
docker-compose exec -T zabbix-server pip3 install requests
```

* zabbix时间显示(时区)
>vim .env_web
```
PHP_TZ=Asia/Shanghai
```
```
docker-compose restart zabbix-web-apache-mysql
```

### 宿主机二进制安装zabbix-agent
>zabbix-agent与zabbix-server同宿主机时，server需要配置zabbix-server的容器IP（172.16.238.3），其它主机zabbix-agent只需要写zabbix-server宿主机IP（172.19.39.18）
```
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
Server=172.19.39.18,172.16.238.3
ServerActive=172.19.39.18,172.16.238.3
Hostname=Zabbix server
Include=/etc/zabbix/zabbix_agentd.d/*.conf
```