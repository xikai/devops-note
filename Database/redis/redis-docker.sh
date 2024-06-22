#!/bin/bash

CURRENT_DIR=$(dirname $0)
mkdir -p /data/redis
chown -R 1001:1001 /data/redis

docker run -d --name redis \
  --restart=always \
  --net=host \
  -v /data/redis:/bitnami/redis/data \
  -e "REDIS_PASSWORD=vevor@124" \
  bitnami/redis:5.0.14
