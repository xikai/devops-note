* 3.8.0以前的rabbitmq监控需要使用rabbitmq-exporter
* https://github.com/kbudde/rabbitmq_exporter

# 配置rabbitmq-exporter
* vim /data/rabbitmq/etc/rabbitmq-exporter.conf
* https://github.com/kbudde/rabbitmq_exporter/blob/main/config.example.json
```
{
    "rabbit_url": "http://127.0.0.1:15672",
    "rabbit_user": "admin",
    "rabbit_pass": "l3jmSq7eWY4df4fb",
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

# 启动rabbitmq-exporter
```
docker run -d --name rabbitmq-exporter --restart=always -v /data/rabbitmq/etc/rabbitmq-exporter.conf:/conf/rabbitmq.conf --net=container:rabbitmq kbudde/rabbitmq-exporter
```

# grafana dashboards
* https://grafana.com/grafana/dashboards/4371