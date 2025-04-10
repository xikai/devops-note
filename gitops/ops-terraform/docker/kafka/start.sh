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
  -e ZOO_ENABLE_ADMIN_SERVER=no \
  -e ALLOW_ANONYMOUS_LOGIN=yes \
  $1/zookeeper:3.6.3

docker run -d --name kafka-server \
 --restart=always \
 --net=host \
 --ulimit nofile=65536:65536 \
 -v /data/kafka-server:/bitnami/kafka \
 -e KAFKA_ZOOKEEPER_CONNECT="127.0.0.1:2181" \
 -e KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092 \
 -e KAFKA_ADVERTISED_LISTENERS="PLAINTEXT://$(hostname -i):9092" \
 -e ALLOW_PLAINTEXT_LISTENER=yes \
 -e KAFKA_MESSAGE_MAX_BYTES=400000000 \
 -e KAFKA_REPLICA_FETCH_MAX_BYTES=400000000 \
 -e KAFKA_FETCH_MESSAGE_MAX_BYTES=400000000 \
 -e KAFKA_MAX_REQUEST_SIZE=400000000 \
 -e KAFKA_SOCKET_REQUEST_MAX_BYTES=400000000 \
 $1/kafka:2.8

docker run -d --name kafka-map \
  --restart=always \
  --net=host \
  -v /data/kafka-map/data:/usr/local/kafka-map/data \
  -e SERVER_PORT=8881 \
  -e DEFAULT_USERNAME=admin \
  -e DEFAULT_PASSWORD=vevor@124 \
  $1/kafka-map:v1.3.3