#!/bin/bash

mkdir -p /data/openjdk-8u332-slim

docker run -d \
  --name openjdk-8u332-slim \
  --net=host \
  $1/openjdk:8u332-slim \
  sleep 1000