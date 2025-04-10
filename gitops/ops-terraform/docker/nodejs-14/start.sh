#!/bin/bash

mkdir -p /data/nodejs-14


docker run -d \
  --name nodejs-14 \
  --net=host \
  $1/node:14 \
  sleep 1000