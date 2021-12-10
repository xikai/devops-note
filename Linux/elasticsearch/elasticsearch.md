* https://www.elastic.co/guide/en/elasticsearch/reference/5.6/index.html
* 集群原理: https://www.elastic.co/guide/cn/elasticsearch/guide/current/distributed-cluster.html


* 下载安装
```
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.6.16.tar.gz
tar -xzf elasticsearch-5.6.16.tar.gz
cd elasticsearch-5.6.16/ 
./bin/elasticsearch -d  #Running as a daemon
```

* 配置elasticsearch
```
groupadd es
useradd -g es es
mkdir -p /data/elasticsearch/{data,logs}
chown -R es.es /data/elasticsearch
chown -R es.es /usr/local/elasticsearch
```

* vim config/elasticsearch.yml
```
cluster.name: es-test
node.name: es01
path.data: /data/elasticsearch/data
path.logs: /data/elasticsearch/logs
bootstrap.memory_lock: false
network.host: 0.0.0.0
http.port: 9400
transport.tcp.port: 9500
# 单播发现，加入集群
discovery.zen.ping.unicast.hosts: ["es01:9500", "es02:9500", "es03:9500"]
discovery.zen.minimum_master_nodes: 2
```

* vim /usr/lib/systemd/system/es.service
```
[Unit]
Description=elasticsearch

[Service]
#User=elasticsearch
#Group=elasticsearch
ExecStart=/usr/bin/su - es -c '/usr/local/elasticsearch/bin/elasticsearch'
LimitMEMLOCK=infinity

Restart=on-failure

[Install]
WantedBy=multi-user.target
```
```
systemctl daemon-reload
systemctl start elasticsearch
```