* https://github.com/prometheus/node_exporter
* https://blog.csdn.net/u012599988/article/details/102929269

# 安装node_exporter
>监控主机系统不推荐使用docker启动node_exporter
```
wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz
tar xvfz node_exporter-0.18.1.linux-amd64.tar.gz
cd node_exporter-0.18.1.linux-amd64
./node_exporter
```

* Node Exporter metrics
```
curl http://localhost:9100/metrics
```

* 配置prometheus server拉取Node Exporter metrics
>vim /srv/prometheus/prometheus.yml 添加     
```
scrape_configs:
- job_name: 'node'
  static_configs:
  - targets: ['172.22.0.45:9100']
```
```
docker restart prometheus
```

# 查看node metrics
```
http://202.10.76.12:9090/graph -> node_cpu_seconds_total
```

# grafana dashboards
* https://grafana.com/grafana/dashboards/1860
* https://grafana.com/grafana/dashboards/8919

# node_exporter监控systemd
```
./node_exporter --collector.systemd --collector.systemd.unit-whitelist=(docker|sshd).service
```
* promql
```
node_systemd_unit_state
```

# node_exporter自定义监控
```
./node_exporter --collector.textfile.directory='/path/'
```
* 自定义metric输出格式
```
#HELP example_metric read from /path/example.prom  
#TYPE example_metric untyped  
example_metric 1
```
* 定时任务更新metric数据
```
*/2 * * * * sh test.sh && mv /path/example.promm /path/example.prom
```