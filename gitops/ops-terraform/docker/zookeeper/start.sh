#!/bin/bash
mkdir -p /data/zookeeper/{data,datalog,logs}

docker run -d --name zookeeper \
  --restart always \
  -v /data/zookeeper/data:/data \
  -v /data/zookeeper/datalog:/datalog \
  -v /data/zookeeper/logs:/logs \
  -e ZOO_MAX_CLIENT_CNXNS=200 \
  -e ZOO_CFG_EXTRA="metricsProvider.className=org.apache.zookeeper.metrics.prometheus.PrometheusMetricsProvider metricsProvider.httpPort=7070" \
  -e JVMFLAGS="-Xmx128m" \
  $1/zookeeper:3.6.3