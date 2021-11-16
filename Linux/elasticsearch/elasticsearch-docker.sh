#/bin/bash
mkdir -p /data/elasticsearch/data
chown -R 1000:1000 /data/elasticsearch/data

docker run -d --name es -p 9200:9200 -p 9300:9300 \
        --ulimit nofile=65536:65536 \
        -e "cluster.name=dd01-test" \
        -v /data/elasticsearch/data:/usr/share/elasticsearch/data \
        elasticsearch:5.6.4