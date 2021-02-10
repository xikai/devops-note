mkdir -p ./es/{data,logs}/es{01..03}
chown -R 1000:1000 es/*

mkdir ./kafka-logs
mkdir -p logstash/{config,pipeline}
mkdir -p nginx/conf.d