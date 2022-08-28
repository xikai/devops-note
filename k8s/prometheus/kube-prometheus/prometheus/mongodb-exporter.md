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
wget https://github.com/percona/mongodb_exporter/releases/download/v0.33.0/mongodb_exporter-0.33.0.linux-amd64.tar.gz
tar xzf mongodb_exporter-0.33.0.linux-amd64.tar.gz
mv mongodb_exporter-0.33.0.linux-amd64 /usr/local/mongodb_exporter
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

## grafana
```
# 随机演示数据
https://github.com/percona/grafana-dashboards/blob/main/dashboards/MongoDB/MongoDB_Instances_Overview.json

# 安装plugins/breadcrumb
grafana-cli plugins install digiapulssi-breadcrumb-panel

# 安装Plugins/Polystat

```
