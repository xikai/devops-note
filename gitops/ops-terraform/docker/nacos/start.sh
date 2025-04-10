#!/bin/bash


# default db 127.0.0.1
# default username root
# default password 123456

# 需要先把mysql/sqls/nacos-mysql.sql 初始化，然后执行这个脚本

docker run -d \
    --name nacos \
    --restart=always \
    --net=host \
    -e MODE=standalone \
    -e SPRING_DATASOURCE_PLATFORM=mysql \
    -e MYSQL_SERVICE_HOST=127.0.0.1 \
    -e MYSQL_SERVICE_PORT=3306 \
    -e MYSQL_SERVICE_DB_NAME=nacos \
    -e MYSQL_SERVICE_USER=nacos \
    -e MYSQL_SERVICE_PASSWORD=d9DppmNFhdjM \
    $1/nacos-server:2.0.3