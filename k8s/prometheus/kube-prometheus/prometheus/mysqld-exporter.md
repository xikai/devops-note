* https://github.com/prometheus/mysqld_exporter

# docker部署mysqld-exporter
```
# 授权容器IP
CREATE USER 'exporter'@'172.17.%.%' IDENTIFIED BY 'xxxxxxxxx' WITH MAX_USER_CONNECTIONS 3;
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'172.17.%.%';
flush privileges;
```
```
docker run -d \
  --name mysqld-exporter  \
  -p 9104:9104 \
  --restart=always \
  -e DATA_SOURCE_NAME="exporter:123123@(10.10.24.34:3306)/" \
  prom/mysqld-exporter
```

# 二进制部署mysqld-exporter
```
CREATE USER 'exporter'@'localhost' IDENTIFIED BY 'xxxxxxxxx' WITH MAX_USER_CONNECTIONS 3;
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'localhost';
flush privileges;
```

* 下载mysqld-exporter
```
wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.13.0/mysqld_exporter-0.13.0.linux-amd64.tar.gz
tar xvf mysqld_exporter-0.13.0.linux-amd64.tar.gz
mv mysqld_exporter-0.13.0.linux-amd64 /usr/local/mysqld_exporter
```
* 编写systemd service 文件
```
cat <<EOF > /usr/lib/systemd/system/mysqld_exporter.service 
[Unit]
Description=mysqld_exporter
After=network.target
[Service]
Type=simple
Environment=DATA_SOURCE_NAME=exporter:exporterpwd@(localhost:3306)/
ExecStart=/usr/local/mysqld_exporter/mysqld_exporter \
  --web.listen-address=:9104 \
  --collect.info_schema.processlist
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
```
# 启动mysqld_exporter
```
systemctl daemon-reload
systemctl start mysqld_exporter
systemctl enable mysqld_exporter
```

# 配置prometheus
```yml
# vim prometheus.yaml
scrapy_confings:
···
- job_name: 'mysql_base_targets'
  static_configs: 
  - targets: ['10.10.13.79:9104','10.10.13.79:9100'] # mysql_exporter和node_exporter的metrics一起采集，加相同label便于匹配
    labels:
      instance: mysql_base_master
  - targets: ['10.10.26.114:9104','10.10.26.114:9100']
    labels:
      instance: mysql_base_slave
```
```
systemctl restart prometheus
```

* [grafana dashboards](https://grafana.com/grafana/dashboards/7362)