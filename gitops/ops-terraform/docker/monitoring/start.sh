#!/bin/bash

CURRENT_DIR=$(dirname $0)
mkdir -p /data/grafana/data
chown -R 472:472 /data/grafana

docker run --name prometheus -d \
  -p 9090:9090 \
  -v ${CURRENT_DIR}/config/prometheus.yml:/etc/prometheus/prometheus.yml \
  $1/prometheus:v2.53.2

docker run --name alertmanager -d \
  -p 9093:9093 \
  -v ${CURRENT_DIR}/config/alertmanager.yml:/etc/alertmanager/alertmanager.yml \
  $1/alertmanager:v0.27.0

docker run -d --name grafana \
  -p 3000:3000 \
  -v /data/grafana/data:/var/lib/grafana \
  $1/grafana-enterprise:11.1.3-ubuntu
