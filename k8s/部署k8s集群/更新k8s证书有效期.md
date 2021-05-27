### 检查证书是否过期
>kubeadm alpha certs check-expiration
```
CERTIFICATE                EXPIRES                  RESIDUAL TIME   EXTERNALLY MANAGED
admin.conf                 May 15, 2020 13:03 UTC   364d            false
apiserver                  May 15, 2020 13:00 UTC   364d            false
apiserver-etcd-client      May 15, 2020 13:00 UTC   364d            false
apiserver-kubelet-client   May 15, 2020 13:00 UTC   364d            false
controller-manager.conf    May 15, 2020 13:03 UTC   364d            false
etcd-healthcheck-client    May 15, 2020 13:00 UTC   364d            false
etcd-peer                  May 15, 2020 13:00 UTC   364d            false
etcd-server                May 15, 2020 13:00 UTC   364d            false
front-proxy-client         May 15, 2020 13:00 UTC   364d            false
scheduler.conf             May 15, 2020 13:03 UTC   364d            false
```

### 自动更新证书
>kubeadm 会在控制面板升级的时候更新所有证书

### 手动更新证书
* 备份k8s配置和etcd数据目录
```
cp -r /etc/kubernetes /etc/kubernetes.bak 
cp -r /var/lib/etcd /var/lib/etcd.bak 
```
* 更新证书
```
kubeadm alpha certs renew all     #如果您运行了一个 HA 集群，这个命令需要在所有控制面板节点上执行 
```
* 替换kubeconfig文件
```
mv $HOME/.kube/config $HOME/.kube/config.old
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
```

* 完成后重启 kube-apiserver、kube-controller、kube-scheduler、etcd 这4个容器即可，我们可以查看 apiserver 的证书的有效期来验证是否更新成功：
```
echo | openssl s_client -showcerts -connect 127.0.0.1:6443 -servername api 2>/dev/null | openssl x509 -noout -enddate
```