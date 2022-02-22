* https://github.com/percona/mongodb_exporter

# 创建mongodb监控用户
```
db.getSiblingDB("admin").createUser({
    user: "exporter",
    pwd: "123456",
    roles: [
        { role: "clusterMonitor", db: "admin" },
        { role: "read", db: "local" }
    ]
})
```

# 二进制安装
```
wget https://github.com/percona/mongodb_exporter/releases/download/v0.30.0/mongodb_exporter-0.30.0.linux-arm64.tar.gz
tar xzf mongodb_exporter-0.30.0.linux-arm64.tar.gz
mv mongodb_exporter-0.30.0.linux-arm64  /usr/local/mongodb_exporter
```

* 启动mongodb exporter
```
cat >/usr/lib/systemd/system/mongodb_exporter.service <<EOF
[Unit]
Description=mongodb_exporter
Documentation=https://github.com/percona/mongodb_exporter
After=network.target

[Service]
Type=simple
Environment="MONGODB_URI=mongodb://exporter:123456@localhost:30000/admin"
ExecStart=/usr/local/mongodb_exporter/mongodb_exporter \
  --compatible-mode \
  --discovering-mode \
  --collector.dbstats \
  --collector.topmetrics
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
```
```
systemctl daemon-reload
systemctl start mongodb_exporter
systemctl enable mongodb_exporter
```

* prometheus配置
```
  - job_name: mongodb_exporter
    static_configs:
    - targets: ['10.0.0.72:9216']
```

# kubernetes安装
* vim mongodb-exporter.yaml
```yml
apiVersion: v1
kind: Service
metadata:
  name: mongodb-exporter-svc
  namespace: monitoring
spec:
  selector:
    k8s-app: mongodb-exporter
  ports:
  - name: svc-9216
    protocol: TCP
    port: 9216
    targetPort: 9216
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongodb-exporter
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      k8s-app: mongodb-exporter
  template:
    metadata:
      labels:
        k8s-app: mongodb-exporter
    spec:
      containers:
      - name: mongodb-exporter
        image: xikai/mongodb_exporter:v0.30.0-arm64
        imagePullPolicy: IfNotPresent
        args:
          - --mongodb.uri=mongodb://exporter:123456@10.10.17.238:30000/admin
          - --compatible-mode
          - --discovering-mode
          - --collector.dbstats
          - --collector.topmetrics
        - containerPort: 9216
          name: metric-port
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
kubectl apply -f mongodb-exporter.yaml
```

### 配置prometheus
* 增加kafka-exporter metrics scrape配置
* vim manifests/additional/prometheus-additional.yaml
```yml
- job_name: 'mongodb_exporter_targets'
  static_configs:
    - targets:
      - mongodb-exporter-svc:9216
```

* 更新promtheus附加配置
```
# 修改prometheus-additional.yaml需要更新secret
kubectl create secret generic additional-scrape-configs --from-file=prometheus-additional.yaml --dry-run -oyaml |kubectl apply -n monitoring -f -

#查看secret for additional-scrape-configs
kubectl get secret additional-scrape-configs -n monitoring -oyaml |yq e '.data ."prometheus-additional.yaml"' - |base64 -d
```

## grafana
```
# 随机演示数据
https://github.com/percona/grafana-dashboards/blob/main/dashboards/MongoDB/MongoDB_Instances_Overview.json

# 安装plugins/breadcrumb
grafana-cli plugins install digiapulssi-breadcrumb-panel

# 安装Plugins/Polystat

```
