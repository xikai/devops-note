#!/bin/bash

CURRENT_DIR=$(dirname $0)
mkdir -p /data/mysql

docker run -d --name mysql \
  --restart=always \
  --net=host \
  -v /data/mysql:/var/lib/mysql:rw \
  -v ${CURRENT_DIR}/conf.d:/etc/mysql/conf.d:rw \
  -v ${CURRENT_DIR}/sqls:/docker-entrypoint-initdb.d:rw \
  -e "MYSQL_ROOT_PASSWORD=kgSlQG1.GPb@u2mI" \
  $1/mysql:5.7.34