#/bin/bash
mkdir -p /data/elasticsearch/data
chown -R 1000:1000 /data/elasticsearch/data

docker run -d --name es -p 9200:9200 -p 9300:9300 \
        --ulimit nofile=65536:65536 \
        -e "discovery.type=single-node" \
        -v /data/elasticsearch/data:/usr/share/elasticsearch/data \
        docker.elastic.co/elasticsearch/elasticsearch:7.10.2

#docker run -d --name kibana --link YOUR_ELASTICSEARCH_CONTAINER_NAME_OR_ID:elasticsearch -p 5601:5601 docker.elastic.co/kibana/kibana:7.10.2