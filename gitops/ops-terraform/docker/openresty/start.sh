#!/bin/bash
CURRENT_DIR=$(dirname $0)

mkdir -p /data/openresty/logs
chmod 777 -R  /data/openresty

docker run -d --name openresty \
  --restart=always \
  --net=host \
  -v ${CURRENT_DIR}/nginx.conf:/usr/local/openresty/nginx/conf/nginx.conf \
  -v ${CURRENT_DIR}/conf.d:/etc/nginx/conf.d \
  -v /data/openresty/logs:/data/logs \
  -v ${CURRENT_DIR}/my_lua:/usr/local/openresty/lualib/my_lua \
  $1/openresty