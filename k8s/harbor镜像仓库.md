* https://github.com/goharbor/harbor/blob/master/docs/installation_guide.md
* https://github.com/goharbor/harbor-helm

### 安装docker-compose
>https://docs.docker.com/compose/install/
```
curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

### 下载Harbor
```
#下载https://github.com/goharbor/harbor/releases
wget https://storage.googleapis.com/harbor-releases/harbor-offline-installer-v1.x.x
tar -xzf harbor-offline-installer-v1.x.x.tgz
mv harbor /opt
```

### 使用HTTP访问harbor
* 配置harbor
>vim harbor.yml
```
hostname: reg.dadi01.cn

# http related config
http:
  # port for http, default is 80. If https enabled, this port will redirect to https port
  port: 80
  
harbor_admin_password: Harbor12345
```

* 安装启动harbor
```
./prepare  #准备配置
./install.sh
```

* 访问harbor
```
http://192.168.140.111
admin
Harbor12345

# docker访问harbor
docker login 192.168.140.111
```

* 配置Docker使用不安全的registry
>vim /usr/lib/systemd/system/docker.service
```
ExecStart=/usr/bin/dockerd --insecure-registry=192.168.140.111
```
```
systemctl daemon-reload
systemctl restart docker
```


### 使用HTTPS访问harbor(生产环境建议使用https)
* 自建CA生成证书
```
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -sha512 -days 3650 \
    -subj "/C=CN/ST=GuangDong/L=ShenZhen/O=example/OU=IT/CN=reg.yourdomain.com" \
    -key ca.key \
    -out ca.crt
```
* 生成服务器证书
```
# 创建私钥
openssl genrsa -out reg.yourdomain.com.key 4096

# 生成私钥签名请求
openssl req -sha512 -new \
    -subj "/C=CN/ST=GuangDong/L=ShenZhen/O=example/OU=IT/CN=reg.yourdomain.com" \
    -key reg.yourdomain.com.key \
    -out reg.yourdomain.com.csr 
```
* 生成证书
```
cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth 
subjectAltName = @alt_names

[alt_names]
DNS.1=reg.yourdomain.com
DNS.2=yourdomain.com
DNS.3=hostname
EOF
```
```
openssl x509 -req -sha512 -days 3650 \
  -extfile v3.ext \
  -CA ca.crt -CAkey ca.key -CAcreateserial \
  -in reg.yourdomain.com.csr \
  -out reg.yourdomain.com.crt
```

* 配置安装证书
>如果有申请付费证书，可以不使用上面创建的自建证书
```
mkdir -p /data/cert/
cp reg.yourdomain.com.crt /data/cert/
cp reg.yourdomain.com.key /data/cert/
```

* 配置harbor
>vim harbor.yml
```
hostname: reg.dadi01.cn

# http related config
http:
  # port for http, default is 80. If https enabled, this port will redirect to https port
  port: 80

# https related config
https:
#   # https port for harbor, default is 443
  port: 443
#   # The path of cert and key files for nginx
  certificate: /data/cert/dadi01.cn.pem
  private_key: /data/cert/dadi01.cn.key
  
harbor_admin_password: Harbor12345
```

* 生成配置文件,启动harbor
```
./prepare
docker-compose down -v   #停止harbor,如果己经启动
docker-compose up -d
```

* 访问harbor
```
https://reg.yourdomain.com
admin
Harbor12345

# docker访问harbor,确保没有设置"-insecure-registry"
docker login reg.yourdomain.com
```

* 为docker配置证书
>docker用.crt作为CA证书，.cert文件作为客户端证书
```
openssl x509 -inform PEM -in reg.yourdomain.com.crt -out reg.yourdomain.com.cert
mkdir -p /etc/docker/certs.d/reg.yourdomain.com/
cp reg.yourdomain.com.cert /etc/docker/certs.d/reg.yourdomain.com/
cp reg.yourdomain.com.key /etc/docker/certs.d/reg.yourdomain.com/
cp ca.crt /etc/docker/certs.d/reg.yourdomain.com/
# macOS将证书拷贝到~/.docker/certs.d/reg.yourdomain.com/  重启docker
```

### 插件
* clair 是coreos 开源的容器漏洞扫描工具
* Notary 是一套docker镜像的签名工具， 用来保证镜像在pull，push和传输工程中的一致性和完整性。避免中间人攻击，避免非法的镜像更新和运行
```
./install.sh --with-notary --with-clair --with-chartmuseum
```