* https://github.com/prometheus/mysqld_exporter

# docker部署mysqld-exporter
```
# 授权容器IP
CREATE USER 'exporter'@'172.17.%.%' IDENTIFIED BY 'xxxxxxxxx' WITH MAX_USER_CONNECTIONS 3;
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'172.17.%.%';
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
```

* 下载mysqld-exporter
```
wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.13.0/mysqld_exporter-0.13.0.linux-amd64.tar.gz
tar xvf mysqld_exporter-0.13.0.linux-amd64.tar.gz -C /usr/local
mv mysqld_exporter-0.13.0.linux-amd64 mysqld_exporter
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
ExecStart=/usr/local/mysqld_exporter/mysqld_exporter --web.listen-address=:9104
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
  - job_name: MySQL
    static_configs:
    - targets:
      - ip:9104
      labels:
        instance: ip:3306
```
```
systemctl restart prometheus
```