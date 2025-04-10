#!/bin/bash

CURRENT_DIR=$(dirname $0)
MYSQL_IP="127.0.0.1"
USERNAME="root"
PASSWORD="sfs9KYq4FsOhfn5Jw8di"
mkdir -p /data/xxl-job/applogs

docker run -d \
  --name=xxl-job \
  --net=host \
  --privileged=true \
  -e PARAMS="--spring.datasource.url=jdbc:mysql://$MYSQL_IP:3306/xxl_job?useUnicode=true&characterEncoding=utf-8&zeroDateTimeBehavior=convertToNull&useSSL=false&serverTimezone=GMT%2B8&allowMultiQueries=true \
  --spring.datasource.username=$USERNAME \
  --spring.datasource.password=$PASSWORD" \
  -v /data/xxl-job/applogs:/data/applogs \
  $1/xxl-job:2.1.1