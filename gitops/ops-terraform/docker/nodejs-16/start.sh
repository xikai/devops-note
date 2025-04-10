#!/bin/bash

mkdir -p /data/nodejs-16

docker run -d \
  --name nodejs-16 \
  --net=host \
  $1/node:16 \
  sleep 1000