#!/bin/bash
mkdir -p /data/rabbitmq/{mnesia,log}

docker run -d --name rabbitmq \
  --restart=always \
  --hostname rabbitmq \
  --net=host \
  --ulimit nofile=65536:65536 \
  -v /data/rabbitmq/mnesia:/var/lib/rabbitmq/mnesia \
  -v /data/rabbitmq/log:/var/log/rabbitmq/log \
  -e RABBITMQ_DEFAULT_USER=admin \
  -e RABBITMQ_DEFAULT_PASS=vevor@124 \
  rabbitmq:3.8.1-management