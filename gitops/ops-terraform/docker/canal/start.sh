#!/bin/bash
CURRENT_DIR=$(dirname $0)

mkdir -p /data/canal/logs

docker run -d --name canal \
  --restart=always \
  --net=host \
  -v ${CURRENT_DIR}/example:/home/admin/canal-server/conf/example:rw \
  -v /data/canal/logs:/home/admin/canal-server/logs:rw \
  -e canal.instance.tsdb.enable=false \
  -e canal.serverMode=rocketMQ \
  -e rocketmq.namesrv.addr=127.0.0.1:9876 \
  -e canal.aliyun.accessKey= \
  -e canal.aliyun.secretKey= \
  $1/canal-server:v1.1.5
