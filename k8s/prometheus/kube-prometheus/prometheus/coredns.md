```
- job_name: kube-dns
  honor_labels: true
  kubernetes_sd_configs:
    - role: pod
  relabel_configs:
    - action: keep
      source_labels:
      - __meta_kubernetes_namespace
      - __meta_kubernetes_pod_name
      separator: '/'
      regex: 'kube-system/coredns.+'
    - source_labels:
      - __meta_kubernetes_pod_container_port_name
      action: keep
      regex: metrics
    - source_labels:
      - __meta_kubernetes_pod_name
      action: replace
      target_label: instance
    - action: labelmap
      regex: __meta_kubernetes_pod_label_(.+)
```

* [grafana dashboard](https://grafana.com/grafana/dashboards/14981-coredns/)


* [metrics](https://coredns.io/plugins/metrics/)
* https://sysdig.com/blog/how-to-monitor-coredns/
```
coredns_dns_responses_total{rcode=~"SERVFAIL|REFUSED"}
```

```
alert: CoreDNSDown
annotations:
  message: CoreDNS has disappeared from Prometheus target discovery.
  runbook_url: https://github.com/povilasv/coredns-mixin/tree/master/runbook.md#alert-name-corednsdown
expr: |
  sum(up{job="kube-dns"})  == 1
for: 15m
labels:
  severity: critical
```