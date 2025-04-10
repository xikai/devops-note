#!/bin/bash
CURRENT_DIR=$(dirname $0)
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
  $1/rabbitmq:3.8.1-management

docker cp ${CURRENT_DIR}/rabbitmq_delayed_message_exchange-3.8.0.ez rabbitmq:/opt/rabbitmq/plugins
docker exec -it rabbitmq rabbitmq-plugins enable rabbitmq_delayed_message_exchange
