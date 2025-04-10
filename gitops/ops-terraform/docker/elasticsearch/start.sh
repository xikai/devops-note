#!/bin/bash

CURRENT_DIR=$(dirname $0)
mkdir -p /data/elasticsearch/{data,plugins}
chown -R 1000:1000 /data/elasticsearch

docker run -d \
  --name elasticsearch \
  --net=host \
  --restart=always \
  --ulimit nofile=65536:65536 \
  -e "discovery.type=single-node" \
  -e "bootstrap.memory_lock=true" \
  -e "ES_JAVA_OPTS=-Xms128m -Xmx128m" \
  -v /data/elasticsearch/data:/usr/share/elasticsearch/data \
  -v /data/elasticsearch/plugins:/usr/share/elasticsearch/plugins \
  $1/elasticsearch:7.10.2

mkdir -p /data/kibana/data
chown -R 1000:1000 /data/kibana

docker run -d \
  --name kibana \
  --net=host \
  --restart=always \
  -v /data/kibana/data:/usr/share/kibnan/data \
  -e "ELASTICSEARCH_HOSTS=http://127.0.0.1:9200" \
  $1/kibana:7.10.2