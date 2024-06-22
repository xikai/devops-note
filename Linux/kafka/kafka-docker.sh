#!/bin/bash
mkdir -p /data/kafka-server
mkdir -p /data/kafka-zookeeper
mkdir -p /data/kafka-map/data
chown -R 1001:1001 /data/kafka-server
chown -R 1001:1001 /data/kafka-zookeeper

docker run -d --name kafka-zookeeper \
  --restart=always \
  --net=host \
  --ulimit nofile=65536:65536 \
  -v /data/kafka-zookeeper:/bitnami/zookeeper \
  -e ZOO_PORT_NUMBER=2180 \
  -e ZOO_ENABLE_ADMIN_SERVER=no \
  -e ALLOW_ANONYMOUS_LOGIN=yes \
  bitnami/zookeeper:3.6.3

docker run -d --name kafka-server \
  --restart=always \
  --net=host \
  --ulimit nofile=65536:65536 \
  -v /data/kafka-server:/bitnami/kafka \
  -e KAFKA_CFG_ZOOKEEPER_CONNECT=127.0.0.1:2180 \
  -e ALLOW_PLAINTEXT_LISTENER=yes \
  bitnami/kafka:2.8

docker run -d --name kafka-map \
  --restart=always \
  --net=host \
  -v /data/kafka-map/data:/usr/local/kafka-map/data \
  -e DEFAULT_USERNAME=admin \
  -e DEFAULT_PASSWORD=vevor@124 \
  dushixiang/kafka-map:latest