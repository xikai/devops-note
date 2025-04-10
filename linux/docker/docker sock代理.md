
### 开启ssh代理
```
ssh -i ~/.ssh/aws-ec2.pem centos@52.39.117.244 -f -N -D 1080
```

### 设置docker代理配置
>mkdir /etc/systemd/system/docker.service.d \
>vim /etc/systemd/system/docker.service.d/http-proxy.conf
```
[Service]
Environment="ALL_PROXY=socks5://127.0.0.1:1080"
```
* 重启docker服务
```
systemctl daemon-reload
systemctl restart docker
```

### 国内公共docker镜像站
* https://github.com/DaoCloud/public-image-mirror
* quay.io 改成 quay.mirrors.ustc.edu.cn