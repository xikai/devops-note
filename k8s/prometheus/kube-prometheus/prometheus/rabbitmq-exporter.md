* 3.8.0以前的rabbitmq监控需要使用rabbitmq-exporter
* https://github.com/kbudde/rabbitmq_exporter

# 配置rabbitmq-exporter
* vim rabbitmq-exporter-configmap.yaml
```yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: rabbitmq-exporter-config
  namespace: monitoring
data:
  rabbitmq.conf: |
    {
        "rabbit_url": "http://rabbitmq-cluster-vip:15672",
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
```
kubectl apply -f rabbitmq-exporter-configmap.yaml
```

# k8s 部署rabbitmq-exporter
* vim rabbitmq-exporter.yaml
```yml
apiVersion: v1
kind: Service
metadata:
  name: rabbitmq-exporter-svc
  namespace: monitoring
spec:
  selector:
    k8s-app: rabbitmq-exporter
  ports:
  - name: svc-9419
    protocol: TCP
    port: 9419
    targetPort: 9419
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rabbitmq-exporter
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      k8s-app: rabbitmq-exporter
  template:
    metadata:
      labels:
        k8s-app: rabbitmq-exporter
    spec:
      containers:
      - name: rabbitmq-exporter
        image: kbudde/rabbitmq-exporter
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 9419
          name: metric-port
        volumeMounts:
          - name: rabbitmq-exporter-config
            mountPath: /conf/rabbitmq.conf
            subPath: rabbitmq.conf
        securityContext:
          privileged: false
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      volumes:
        - name: rabbitmq-exporter-config
          configMap:
            name: rabbitmq-exporter-config
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
```
```
kubectl apply -f rabbitmq-exporter.yaml
```

# prometheus 抓取rabbitmq metrics
```yml
- job_name: 'rabbitmq_cluster_targets'
  static_configs:
    - targets:
      - rabbitmq-exporter-svc:9419
```

# grafana dashboards
* https://grafana.com/grafana/dashboards/4371