#!/bin/bash

CURRENT_DIR=$(dirname $0)
mkdir -p /data/elasticsearch/{data,plugins}
chown -R 1000:1000 /data/elasticsearch

docker run -d \
  --name elasticsearch \
  --net=host \
  --ulimit nofile=65536:65536 \
  -e "discovery.type=single-node" \
  -e "bootstrap.memory_lock=true" \
  -e "ES_JAVA_OPTS=-Xms128m -Xmx128m" \
  -v /data/elasticsearch/data:/usr/share/elasticsearch/data \
  -v /data/elasticsearch/plugins:/usr/share/elasticsearch/plugins \
  docker.elastic.co/elasticsearch/elasticsearch:7.10.2

#docker run -d --name kibana --link YOUR_ELASTICSEARCH_CONTAINER_NAME_OR_ID:elasticsearch -p 5601:5601 docker.elastic.co/kibana/kibana:7.10.2