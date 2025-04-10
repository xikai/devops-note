#!/bin/bash

IMAGE_URL=$1 
CURRENT_DIR=$(dirname $0)
mkdir -p /data/rocketmq/{nameserver,broker}
# export CURRENT_DIR=${CURRENT_DIR} 
# envsubst < ${CURRENT_DIR}/docker-compose.yaml
export image_url=${IMAGE_URL} && envsubst < ${CURRENT_DIR}/docker-compose.yaml.j2 > ${CURRENT_DIR}/docker-compose.yaml
docker-compose -f ${CURRENT_DIR}/docker-compose.yaml up -d 