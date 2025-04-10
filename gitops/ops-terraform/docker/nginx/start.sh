#!/bin/bash
CURRENT_DIR=$(dirname $0)

mkdir -p /data/nginx/logs

docker run -d --name nginx \
  --restart=always \
  --net=host \
  -v /data/nginx/logs:/var/log/nginx \
  -v ${CURRENT_DIR}/conf.d:/etc/nginx/conf.d \
  -v ${CURRENT_DIR}/nginx.conf:/etc/nginx/nginx.conf \
  $1/nginx:1.21