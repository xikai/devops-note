* https://github.com/danielqsj/kafka_exporter

# [部署kafka-exporter](https://github.com/danielqsj/kafka_exporter/tree/master/deploy/base)
* vim config/kafka-exporter.yaml
* 监控多套kafka集群 拷贝多份文件部署
```yml
apiVersion: v1
kind: Service
metadata:
  name: kafka-exporter-svc
  namespace: monitoring
spec:
  selector:
    k8s-app: kafka-exporter
  ports:
  - name: http-metrics
    protocol: TCP
    port: 9308
    targetPort: 9308
---  
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kafka-exporter
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      k8s-app: kafka-exporter
  template:
    metadata:
      labels:
        k8s-app: kafka-exporter
    spec:
      containers:
      - name: kafka-exporter
        imagePullPolicy: IfNotPresent
        image: danielqsj/kafka-exporter:latest
        args:
          - --kafka.server=10.10.3.248:9092
          - --kafka.server=10.10.35.23:9092
          - --kafka.server=10.10.78.51:9092
        ports:
        - name: http-metrics
          containerPort: 9308
          protocol: TCP
        securityContext:
          privileged: false
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
```
```
kubectl apply -f config/kafka-exporter.yaml
```

# 配置prometheus
* 增加kafka-exporter metrics scrape配置
* vim config/prometheus-additional.yaml
```yml
- job_name: 'kafka_exporter_targets'
  static_configs:
    - targets:
      - kafka-exporter-svc:9308
```

* 更新promtheus附加配置
```
# 修改prometheus-additional.yaml需要更新secret
kubectl create secret generic additional-scrape-configs --from-file=prometheus-additional.yaml --dry-run -oyaml |kubectl apply -n monitoring -f -

#查看secret for additional-scrape-configs
kubectl get secret additional-scrape-configs -n monitoring -oyaml |yq e '.data ."prometheus-additional.yaml"' - |base64 -d
```

* [grafana dashboards](https://grafana.com/grafana/dashboards/7589)