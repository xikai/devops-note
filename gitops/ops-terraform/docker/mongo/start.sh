#!/bin/bash

CURRENT_DIR=$(dirname $0)
mkdir -p /data/mongo

docker run -d --name mongo \
  --restart=always \
  --net=host \
  -p 27017:27017 \
  -v ${CURRENT_DIR}/conf.d/mongod.conf:/etc/mongod.conf \
  -v /data/mongo:/data/db \
  -e MONGO_INITDB_ROOT_USERNAME=root \
  -e MONGO_INITDB_ROOT_PASSWORD=kgSlQG1.GPb@u2mI \
  -d $1/mongo:5.0.14 --oplogSize 512
  