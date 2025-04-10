#!/bin/bash

CURRENT_DIR=$(dirname $0)
mkdir -p /data/mysql

docker run -d --name mysql \
  --restart=always \
  --net=host \
  -v /data/mysql:/var/lib/mysql:rw \
  -v ${CURRENT_DIR}/conf.d:/etc/mysql/conf.d:rw \
  -e "MYSQL_ROOT_PASSWORD=vevor@124" \
  mysql:5.7.34