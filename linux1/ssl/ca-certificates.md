# [ubuntu系统上如何添加新的根证书](https://ubuntu.com/server/docs/security-trust-store)
>如果自己部署了一个CA系统，或者使用openssl生成了一个自签名的证书，如何让ubuntu系统信任这些证书呢
* 系统自带的证书通常是通过ca-certificates软件包安装的
>虽然不是所有的GNU/ Linux发行版都遵循这一点，但通常linux发行版都从/etc/ssl/certs目录中读取证书
```
sudo apt-get install -y ca-certificates
```

* 添加证书：
```sh
# 将pem格式的根证书扩展名改为.crt，并复制到/usr/share/ca-certificates目录
sudo cp local-ca.crt /usr/share/ca-certificates

# 扫描/usr/share/ca-certificates目录，选择你希望使用或忽略的证书，自动生成/etc/ca-certificates.conf配置文件
#sudo dpkg-reconfigure ca-certificates

# 将/etc/ca-certificates.conf配置文件中列出的根证书内容附加到/etc/ssl/certs/ca-certificates.crt ，而/etc/ssl/certs/ca-certificates.crt 包含了系统自带的各种可信根证书.
sudo update-ca-certificates
```

* 删除证书：
```sh
sudo rm -f /usr/share/ca-certificates/local-ca.crt
#sudo dpkg-reconfigure ca-certificates
sudo update-ca-certificates
```

* 查看证书信息
```
sudo openssl x509 -in local-ca.pem -noout -text
```
* 转换证书der格式为pem格式
```
sudo openssl x509 -inform der -outform pem -in local-ca.der -out local-ca.crt 
```