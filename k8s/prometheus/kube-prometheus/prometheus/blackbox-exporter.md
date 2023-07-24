* https://github.com/prometheus/blackbox_exporter
* https://blog.51cto.com/shoufu/2469397

# [配置blackbox-exporter](https://github.com/prometheus/blackbox_exporter/blob/master/CONFIGURATION.md)
* https://github.com/prometheus/blackbox_exporter/blob/master/example.yml
* vim config/blackbox2-exporter-configmap.yaml
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: blackbox2-exporter-config
  namespace: monitoring
data:
  config.yml: |-
    "modules":
      "http_2xx":
        "http":
          "preferred_ip_protocol": "ip4"
        "prober": "http"
      "http_post_2xx":
        "http":
          "method": "POST"
          "preferred_ip_protocol": "ip4"
        "prober": "http"
      "irc_banner":
        "prober": "tcp"
        "tcp":
          "preferred_ip_protocol": "ip4"
          "query_response":
          - "send": "NICK prober"
          - "send": "USER prober prober prober :prober"
          - "expect": "PING :([^ ]+)"
            "send": "PONG ${1}"
          - "expect": "^:[^ ]+ 001"
      "pop3s_banner":
        "prober": "tcp"
        "tcp":
          "preferred_ip_protocol": "ip4"
          "query_response":
          - "expect": "^+OK"
          "tls": true
          "tls_config":
            "insecure_skip_verify": false
      "ssh_banner":
        "prober": "tcp"
        "tcp":
          "preferred_ip_protocol": "ip4"
          "query_response":
          - "expect": "^SSH-2.0-"
      "tcp_connect":
        "prober": "tcp"
        "tcp":
          "preferred_ip_protocol": "ip4"
```
```
kubectl apply -f manifests/config/blackbox2-exporter-configmap.yaml
```

# 部署blackbox-exporter
* vim config/blackbox2-exporter.yaml
```yml
apiVersion: v1
kind: Service
metadata:
  name: blackbox2-exporter-svc
  namespace: monitoring
spec:
  selector:
    k8s-app: blackbox2-exporter
  ports:
  - name: probe
    protocol: TCP
    port: 9115
    targetPort: 19115
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: blackbox2-exporter
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      k8s-app: blackbox2-exporter
  template:
    metadata:
      labels:
        k8s-app: blackbox2-exporter
    spec:
      containers:
      - name: blackbox-exporter
        image: quay.io/prometheus/blackbox-exporter:v0.19.0
        args:
        - --config.file=/etc/blackbox_exporter/config.yml
        - --web.listen-address=:19115
        ports:
        - containerPort: 19115
          name: http
        resources:
          limits:
            cpu: 20m
            memory: 40Mi
          requests:
            cpu: 10m
            memory: 20Mi
        securityContext:
          runAsNonRoot: true
          runAsUser: 65534
        volumeMounts:
        - mountPath: /etc/blackbox_exporter/
          name: config
          readOnly: true
      - name: module-configmap-reloader
        image: jimmidyson/configmap-reload:v0.5.0
        args:
        - --webhook-url=http://localhost:19115/-/reload
        - --volume-dir=/etc/blackbox_exporter/
        resources:
          limits:
            cpu: 20m
            memory: 40Mi
          requests:
            cpu: 10m
            memory: 20Mi
        securityContext:
          runAsNonRoot: true
          runAsUser: 65534
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: FallbackToLogsOnError
        volumeMounts:
        - mountPath: /etc/blackbox_exporter/
          name: config
          readOnly: true
      volumes:
      - configMap:
          name: blackbox2-exporter-config
        name: config
```
```
kubectl apply -f config/blackbox2-exporter.yaml
```

# [配置prometheus](https://github.com/prometheus/blackbox_exporter#prometheus-configuration)
* https://prometheus.io/docs/guides/multi-target-exporter/
* vim config/prometheus-additional.yaml
```
scrape_configs:
  - job_name: 'blackbox2_http_2xx'
    metrics_path: /probe
    params:
      module: [http_2xx]  # Look for a HTTP 200 response.
    static_configs:
      - targets:
        - http://prometheus.io    # Target to probe with http.
        - https://prometheus.io   # Target to probe with https.
        - http://example.com:8080 # Target to probe with http on port 8080.
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: blackbox2-exporter-svc:9115  # The blackbox exporter's real hostname:port.
```

# 测试
```
curl "http://blackbox2-exporter-svc:9115/probe?module=http_2xx&target=https://prometheus.io"
```

# [grafana](https://grafana.com/grafana/dashboards/7587)