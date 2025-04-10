

### promtheus配置示例
* https://prometheus.io/docs/prometheus/latest/configuration/configuration/
```
# Global configuration
global:
  scrape_interval:     15s
  evaluation_interval: 15s

# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      - 192.168.140.101:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  - 'prometheus.rules.yml'
  - 'alerting.rules.yml'

# A scrape configuration containing exactly one endpoint to scrape:
scrape_configs:
  # Prometheus itself.
  - job_name: 'prometheus'
    static_configs:
    - targets: ['localhost:9090']

  # node_exporter
  - job_name: 'prometheus_node'
    static_configs:
    - targets: ['192.168.140.101:9100']
    
  # 添加示例targets监控metrics
  - job_name: 'example-random'
    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.140.101:8080', '192.168.140.101:8081']
        labels:
          group: 'production'
      - targets: ['192.168.140.101:8082']
        labels:
          group: 'canary'
```