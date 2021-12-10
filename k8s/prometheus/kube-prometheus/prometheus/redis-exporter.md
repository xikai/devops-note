* https://github.com/oliver006/redis_exporter

# 部署redis-exporter
* 配置redis密码
* vim manifests/additional/redis-pwd-file-configmap.yaml
```yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-pwd-file
  namespace: monitoring
data:
  redis-pwd-file.json: |
    {
      "redis://10.10.13.228:6391": "g3kBySjY8G5XWLs9",
      "redis://10.10.21.174:6391": "g3kBySjY8G5XWLs9",
      "redis://10.10.13.228:6392": "id8Ka2x4WizGwrOO",
      "redis://10.10.21.174:6392": "id8Ka2x4WizGwrOO",
      "redis://10.10.32.132:6391": "4O9CeN5H7xHajiCe",
      "redis://10.10.66.105:6391": "4O9CeN5H7xHajiCe",
    }
```
```
kubectl apply -f redis-pwd-file-configmap.yaml
```

* 部署redis-exporter
* vim manifests/additional/redis-exporter.yaml
```yml
apiVersion: v1
kind: Service
metadata:
  name: redis-exporter-svc
  namespace: monitoring
spec:
  selector:
    k8s-app: redis-exporter
  ports:
  - name: svc-9121
    protocol: TCP
    port: 9121
    targetPort: 9121
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-exporter
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      k8s-app: redis-exporter
  template:
    metadata:
      labels:
        k8s-app: redis-exporter
    spec:
      containers:
      - name: redis-exporter
        image: oliver006/redis_exporter:v1.27.1-arm
        imagePullPolicy: IfNotPresent
        command: ["/redis_exporter"]
        args:
        - --redis.password-file=/tmp/redis-pwd-file.json
        - --include-system-metrics=true
        ports:
        - containerPort: 9121
          name: metric-port
        env:
          - name: REDIS_FILE
            value: /tmp/redis-pwd-file.json
        volumeMounts:
          - name: redis-pwd-file
            mountPath: /tmp/redis-pwd-file.json
            subPath: redis-pwd-file.json
        securityContext:
          privileged: false
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      volumes:
        - name: redis-pwd-file
          configMap:
            name: redis-pwd-file
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
```
```
kubectl apply -f manifests/additional/redis-exporter.yaml
```



# 配置prometheus
* 通过此文件，prometheus自动发现redis监控目标
* vim manifests/additional/redis-targets-configmap.yaml
```yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-targets
  namespace: monitoring
data:
  redis-targets.json: |
    [
      {
        "targets": [ "redis://10.10.9.231:6379", "redis://10.10.23.165:6379","redis://10.10.45.176:6379"],
        "labels": { "cluster_name": "redis_search" }
      },
      {
        "targets": [ "redis://10.10.13.35:6379", "redis://10.10.17.10:6379","redis://10.10.42.121:6379"],
        "labels": { "cluster_name": "redis_website" }
      }
    ]
```
```
kubectl apply -f redis-targets-configmap.yaml
```

* 配置prometheus挂载redis-targets
* vim manifests/prometheus-prometheus.yaml ,添加：
```yml
spec:
  ……
  volumeMounts:
    - name: redis-targets
      mountPath: /tmp/redis-targets.json
      subPath: redis-targets.json
  volumes:
    - name: redis-targets
      configMap:
        name: redis-targets
```
```
kubectl apply -f manifests/prometheus-prometheus.yaml
```

* 增加redis-exporter metrics scrape配置
* vim manifests/additional/prometheus-additional.yaml
```yml
- job_name: "redis_exporter_targets"
  file_sd_configs:
    - files:
      - /tmp/redis-targets.json
  metrics_path: /scrape
  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - target_label: __address__
      replacement: redis-exporter-svc:9121

## config for scraping the exporter itself
- job_name: 'redis_exporter_itself'
  static_configs:
    - targets:
      - redis-exporter-svc:9121
```

* 更新promtheus附加配置
```
# 修改prometheus-additional.yaml需要更新secret
kubectl create secret generic additional-scrape-configs --from-file=prometheus-additional.yaml --dry-run -oyaml |kubectl apply -n monitoring -f -

#查看secret for additional-scrape-configs
kubectl get secret additional-scrape-configs -n monitoring -oyaml |yq e '.data ."prometheus-additional.yaml"' - |base64 -d
```