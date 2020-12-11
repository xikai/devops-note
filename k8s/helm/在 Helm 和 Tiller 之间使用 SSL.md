### 生成CA和证书
>mkdir /opt/ssl/helm_ssl \
cd /opt/ssl/helm_ssl

* 生成CA
```
openssl genrsa -out ./ca.key.pem 4096
openssl req -key ca.key.pem -new -x509 -days 7300 -sha256 -out ca.cert.pem -extensions v3_ca
```
* 生成tiller私钥和客户端证书
```
openssl genrsa -out ./tiller.key.pem 4096
openssl req -key tiller.key.pem -new -sha256 -out tiller.csr.pem
```
* 生成Helm私钥和客户端证书
```
openssl genrsa -out ./helm.key.pem 4096
openssl req -key helm.key.pem -new -sha256 -out helm.csr.pem
```
* 使用创建的 CA 证书对每个 CSR 进行签名（调整 days 参数以满足你的要求）
```
openssl x509 -req -CA ca.cert.pem -CAkey ca.key.pem -CAcreateserial -in tiller.csr.pem -out tiller.cert.pem -days 365
openssl x509 -req -CA ca.cert.pem -CAkey ca.key.pem -CAcreateserial -in helm.csr.pem -out helm.cert.pem -days 365
```

### 安装基于ssl认证的tiller服务端
```
helm init --tiller-tls --tiller-tls-cert ./tiller.cert.pem --tiller-tls-key ./tiller.key.pem --tiller-tls-verify --tls-ca-cert ca.cert.pem
```

### 配置基于ssl认证的helm客户端
>Tiller 服务现在运行通过 TLS 保护。现在需要配置 Helm 客户端来执行 TLS 操作。
```
helm ls --tls --tls-ca-cert ca.cert.pem --tls-cert helm.cert.pem --tls-key helm.key.pem
```
>键入长命令很麻烦。快捷方法是将密钥，证书和 CA 移入 $HELM_HOME
```
cp ca.cert.pem $(helm home)/ca.pem
cp helm.cert.pem $(helm home)/cert.pem
cp helm.key.pem $(helm home)/key.pem

helm ls
```