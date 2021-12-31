* [3.8.0以前的rabbitmq监控需要使用rabbitmq-exporter](https://github.com/kbudde/rabbitmq_exporter)
* [从 3.8.0 开始，RabbitMQ 附带内置 Prometheus 和 Grafana 支持](https://www.rabbitmq.com/prometheus.html)
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