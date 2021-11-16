* Blackbox Exporter是Prometheus社区提供的官方黑盒监控解决方案，其允许用户通过：HTTP、HTTPS、DNS、TCP以及ICMP的方式对网络进行探测。
* https://github.com/prometheus/blackbox_exporter

### blackbox modules
* 配置blackbox modules
>vim /srv/prometheus/blackbox/blackbox.yml
```
modules:
  http_2xx:
    prober: http
    http:
      method: GET
```

* 安装blackbox_exporter
```
docker run -d \
    -p 9115:9115 \
    --name blackbox_exporter \
    -v /srv/prometheus/blackbox:/config \
    prom/blackbox-exporter:master \
    --config.file=/config/blackbox.yml
```

* 访问测试
```
http://202.10.76.12/:9115/probe?module=http_2xx&target=baidu.com
```
```
# HELP probe_dns_lookup_time_seconds Returns the time taken for probe dns lookup in seconds
# TYPE probe_dns_lookup_time_seconds gauge
probe_dns_lookup_time_seconds 5.017272758
# HELP probe_duration_seconds Returns how long the probe took to complete in seconds
# TYPE probe_duration_seconds gauge
probe_duration_seconds 5.10082118
# HELP probe_failed_due_to_regex Indicates if probe failed due to regex
# TYPE probe_failed_due_to_regex gauge
probe_failed_due_to_regex 0
# HELP probe_http_content_length Length of http content response
# TYPE probe_http_content_length gauge
probe_http_content_length 81
# HELP probe_http_duration_seconds Duration of http request by phase, summed over all redirects
# TYPE probe_http_duration_seconds gauge
probe_http_duration_seconds{phase="connect"} 0.040959283
probe_http_duration_seconds{phase="processing"} 0.041543292
probe_http_duration_seconds{phase="resolve"} 5.017272758
probe_http_duration_seconds{phase="tls"} 0
probe_http_duration_seconds{phase="transfer"} 0.000334977
# HELP probe_http_last_modified_timestamp_seconds Returns the Last-Modified HTTP response header in unixtime
# TYPE probe_http_last_modified_timestamp_seconds gauge
probe_http_last_modified_timestamp_seconds 1.26330408e+09
# HELP probe_http_redirects The number of redirects
# TYPE probe_http_redirects gauge
probe_http_redirects 0
# HELP probe_http_ssl Indicates if SSL was used for the final redirect
# TYPE probe_http_ssl gauge
probe_http_ssl 0
# HELP probe_http_status_code Response HTTP status code
# TYPE probe_http_status_code gauge
probe_http_status_code 200
# HELP probe_http_uncompressed_body_length Length of uncompressed response body
# TYPE probe_http_uncompressed_body_length gauge
probe_http_uncompressed_body_length 81
# HELP probe_http_version Returns the version of HTTP of the probe response
# TYPE probe_http_version gauge
probe_http_version 1.1
# HELP probe_ip_protocol Specifies whether probe ip protocol is IP4 or IP6
# TYPE probe_ip_protocol gauge
probe_ip_protocol 4
# HELP probe_success Displays whether or not the probe was a success
# TYPE probe_success gauge
probe_success 1
```

* 与Prometheus集成,配置prometheus server拉取blackbox metrics
>vim /srv/prometheus/prometheus.yml 添加
```
scrape_configs:
- job_name: baidu_http2xx_probe
  params:
    module:
    - http_2xx
    target:
    - baidu.com
  metrics_path: /probe
  static_configs:
  - targets:
    - 172.22.0.45:9115
- job_name: prometheus_http2xx_probe
  params:
    module:
    - http_2xx
    target:
    - prometheus.io
  metrics_path: /probe
  static_configs:
  - targets:
    - 172.22.0.45:9115
```

### 查看blackbox probe metrics
```
http://202.10.76.12:9090/graph -> probe_duration_seconds
```