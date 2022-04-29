* https://dolphinscheduler.apache.org/zh-cn/docs/latest/user_doc/guide/installation/docker.html

# docker-compose安装
```sh
# 172.31.40.12
wget https://dlcdn.apache.org/dolphinscheduler/2.0.5/apache-dolphinscheduler-2.0.5-src.tar.gz
tar -xzf apache-dolphinscheduler-2.0.5-src.tar.gz
cd apache-dolphinscheduler-2.0.5-src/docker/docker-swarm
docker-compose up -d
```

* 登陆
```
http://172.31.40.12:12345/dolphinscheduler
admin
dolphinscheduler123
```

# 如何通过 docker-compose 扩缩容 master 和 worker？
```
扩缩容 master 至 2 个实例:
docker-compose up -d --scale dolphinscheduler-master=2 dolphinscheduler-master
扩缩容 worker 至 3 个实例:
docker-compose up -d --scale dolphinscheduler-worker=3 dolphinscheduler-worker
```

# 在其它主机启动worker容器
```
docker run -d --name dolphinscheduler-worker \
--net=host \
-e DATABASE_HOST="172.31.40.12" -e DATABASE_PORT="5432" -e DATABASE_DATABASE="dolphinscheduler" \
-e DATABASE_USERNAME="root" -e DATABASE_PASSWORD="root" \
-e REGISTRY_PLUGIN_NAME=zookeeper \
-e REGISTRY_SERVERS=172.31.40.12:2181 \
apache/dolphinscheduler:latest worker-server
```

# worker环境部署
* vim Dockerfile
```
FROM apache/dolphinscheduler:2.0.5

RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/' /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends python-pip \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade setuptools
RUN pip install --upgrade google-cloud-bigquery pyarrow -i https://pypi.tuna.tsinghua.edu.cn/simple

ADD spark-3.2.1-bin-hadoop3.2.tgz /opt/soft
```