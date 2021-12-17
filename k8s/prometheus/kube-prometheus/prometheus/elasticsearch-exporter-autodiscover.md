* https://github.com/prometheus-community/elasticsearch_exporter

# [部署elasticsearch_exporter](https://github.com/prometheus-community/elasticsearch_exporter/blob/master/examples/kubernetes/deployment.yml)
* vim  manifests/additional/es-exporter.yaml
```yml
apiVersion: v1
kind: Service
metadata:
  name: es-exporter-svc
  namespace: monitoring
spec:
  selector:
    k8s-app: es-exporter
  ports:
  - name: svc-9114
    protocol: TCP
    port: 9114
    targetPort: 9114
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: es-exporter
  namespace: monitoring
spec:
  replicas: 1
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
    type: RollingUpdate
  selector:
    matchLabels:
      k8s-app: es-exporter
  template:
    metadata:
      labels:
        k8s-app: es-exporter
    spec:
      containers:
        - name: es-exporter
          image: quay.io/prometheuscommunity/elasticsearch-exporter:latest
          command:
            - /bin/elasticsearch_exporter
            - --es.uri=http://elasticsearch:9200  #被采集es集群的一个节点
            #- --es.all  #采集集群所有节点，不仅是本节点（自动发现模式不要开启）
            - --es.cluster_settings
            - --es.indices
            - --es.indices_settings
            - --es.indices_mappings	
            - --es.shards
            - --es.snapshots
          ports:
            - containerPort: 9114
              name: http
          securityContext:
            capabilities:
              drop:
                - SETPCAP
                - MKNOD
                - AUDIT_WRITE
                - CHOWN
                - NET_RAW
                - DAC_OVERRIDE
                - FOWNER
                - FSETID
                - KILL
                - SETGID
                - SETUID
                - NET_BIND_SERVICE
                - SYS_CHROOT
                - SETFCAP
            readOnlyRootFilesystem: true
          livenessProbe:
            httpGet:
              path: /healthz
              port: 9114
            initialDelaySeconds: 30
            timeoutSeconds: 10
          readinessProbe:
            httpGet:
              path: /healthz
              port: 9114
            initialDelaySeconds: 10
            timeoutSeconds: 10
          resources:
            limits:
              cpu: 100m
              memory: 128Mi
            requests:
              cpu: 25m
              memory: 64Mi
      restartPolicy: Always
      securityContext:
        runAsNonRoot: true
        runAsGroup: 10000
        runAsUser: 10000
        fsGroup: 10000
```
```
kubectl apply -f manifests/additional/es-exporter.yaml
```

# 配置prometheus
* 通过此文件，prometheus自动发现elasticsearch监控目标
* vim manifests/additional/es-targets-configmap.yaml
```yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: es-targets
  namespace: monitoring
data:
  es-targets.json: |
    [
      {
        "targets": ["http://10.10.9.231:9200", "http://10.10.23.165:9200","http://10.10.45.176:9200"],
        "labels": { "cluster_name": "es_search" }
      },
      {
        "targets": ["http://10.10.13.35:9200", "http://10.10.17.10:9200","http://10.10.42.121:9200"],
        "labels": { "cluster_name": "es_website" }
      }
    ]
```
```
kubectl apply -f es-targets-configmap.yaml
```

* 配置prometheus挂载es-targets
* vim manifests/prometheus-prometheus.yaml ,添加：
```yml
spec:
  ……
  volumeMounts:
    - name: es-targets
      mountPath: /tmp/es-targets.json
      subPath: es-targets.json
  volumes:
    - name: es-targets
      configMap:
        name: es-targets
```
```
kubectl apply -f manifests/prometheus-prometheus.yaml
```

* 增加es-exporter metrics scrape配置
* vim manifests/additional/prometheus-additional.yaml
```yml
- job_name: "es_exporter_targets"
  file_sd_configs:
    - files:
      - /tmp/es-targets.json
  metrics_path: /metrics
  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - target_label: __address__
      replacement: es-exporter-svc:9114

## config for scraping the exporter itself
- job_name: 'es_exporter_itself'
  static_configs:
    - targets:
      - es-exporter-svc:9114
```

* 更新promtheus附加配置
```
# 修改prometheus-additional.yaml需要更新secret
kubectl create secret generic additional-scrape-configs --from-file=prometheus-additional.yaml --dry-run -oyaml |kubectl apply -n monitoring -f -

#查看secret for additional-scrape-configs
kubectl get secret additional-scrape-configs -n monitoring -oyaml |yq e '.data ."prometheus-additional.yaml"' - |base64 -d
```

# elasticsearch dashboard
* https://github.com/prometheus-community/elasticsearch_exporter/blob/master/examples/grafana/dashboard.json
* https://grafana.com/grafana/dashboards/6483