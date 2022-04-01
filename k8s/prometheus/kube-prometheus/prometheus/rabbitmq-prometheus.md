
# [从 3.8.0 开始，RabbitMQ 附带内置 Prometheus 和 Grafana 支持](https://www.rabbitmq.com/prometheus.html)
```
# 对任一集群节点执行
rabbitmq-plugins enable rabbitmq_prometheus
```
```
curl -s localhost:15692/metrics | head -n 3
# TYPE erlang_mnesia_held_locks gauge
# HELP erlang_mnesia_held_locks Number of held locks.
erlang_mnesia_held_locks{node="rabbit@65f1a10aaffa",cluster="rabbit@65f1a10aaffa"} 0
```

# [3.8.0以前的rabbitmq监控需要使用rabbitmq-exporter](https://github.com/kbudde/rabbitmq_exporter)
* vim /data/rabbitmq/etc/rabbitmq-exporter.conf
```
{
    "rabbit_url": "http://127.0.0.1:15672",
    "rabbit_user": "admin",
    "rabbit_pass": "123456",
    "publish_port": "9419",
    "publish_addr": "",
    "output_format": "TTY",
    "ca_file": "ca.pem",
    "cert_file": "client-cert.pem",
    "key_file": "client-key.pem",
    "insecure_skip_verify": false,
    "exlude_metrics": [],
    "include_queues": ".*",
    "skip_queues": "^$",
    "skip_vhost": "^$",
    "include_vhost": ".*",
    "rabbit_capabilities": "no_sort,bert",
    "enabled_exporters": [
            "exchange",
            "node",
            "overview",
            "queue"
    ],
    "timeout": 30,
    "max_queues": 0
}
```
* 启动rabbitmq-exporter
```
docker run -d --name rabbitmq-exporter --restart=always -v /data/rabbitmq/etc/rabbitmq-exporter.conf:/conf/rabbitmq.conf --net=container:rabbitmq kbudde/rabbitmq-exporter
```