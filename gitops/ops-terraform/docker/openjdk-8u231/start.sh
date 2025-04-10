#!/bin/bash

mkdir -p /data/openjdk-8u231

docker run -d \
  --name openjdk-8u231 \
  --net=host \
  $1/openjdk:8u231 \
  sleep 1000