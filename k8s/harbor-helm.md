### 下载harbor-helm源码
```
git clone https://github.com/goharbor/harbor-helm.git
cd harbor-helm
git checkout v1.1.1
```
* 新建配置文件，覆盖源values.yaml配置(使用阿里云nas作为持久化存储,==alicloud-nas==存储类之前己创建)
>vim dd01-values.yaml
```
expose:
  type: ingress
  tls:
    enabled: true
    secretName: "harbor-tls-secret"
  ingress:
    hosts:
      core: reg.dadi01.net
      notary: notary.dadi01.net
    annotations:
      kubernetes.io/ingress.class: "traefik"
      ingress.kubernetes.io/ssl-redirect: "true"
      ingress.kubernetes.io/proxy-body-size: "0"

externalURL: https://reg.dadi01.net

persistence:
  enabled: true
  resourcePolicy: "keep"
  persistentVolumeClaim:
    registry:
      storageClass: "alicloud-nas"
    chartmuseum:
      storageClass: "alicloud-nas"
    jobservice:
      storageClass: "alicloud-nas"
    database:
      storageClass: "alicloud-nas"
    redis:
      storageClass: "alicloud-nas"
```


* 下载阿里云ssl证书到cert目录（pem文件中第一个cert是服务器证书，第二个cert是ca）,并通过base64加密
```
cat cert/dadi01.net.ca | base64
LS0tLS1CRUdJTiF...(skip)...UFJVVkFURSBLRVktLS1tLQo
cat cert/dadi01.net.crt | base64
LS0taadfeeeefef...(skip)...UFJVVkFURSBLRVktLS1tLQo
cat cert/dadi01.net.key | base64
LS0tLS1DEDefeef...(skip)...UFJVVkFURSBLRVktLS1tLQo
```
* 创建harbor tls secret
>vim ingress-tls-secret.yaml
```
apiVersion: v1
kind: Secret
metadata:
  labels:
    chart: harbor
    release: harbor
  name: harbor-tls-secret
  namespace: kube-ops
type: kubernetes.io/tls
data:
  ca.crt: LS0tLS1CRUdJTiF...(skip)...UFJVVkFURSBLRVktLS1tLQo
  tls.crt: LS0taadfeeeefef...(skip)...UFJVVkFURSBLRVktLS1tLQo
  tls.key: LS0tLS1DEDefeef...(skip)...UFJVVkFURSBLRVktLS1tLQo
```
```
kubectl apply -f ingress-tls-secret.yaml
```

* 安装harbor
```
helm install --name harbor -f dd01-values.yaml . --namespace kube-ops
```
```
 17:23 $ kubectl get ingress -n kube-ops
NAME                    HOSTS                              ADDRESS   PORTS     AGE
harbor-harbor-ingress   reg.dadi01.net,notary.dadi01.net             80, 443   2m47s
```

* 为docker配置证书
>docker login/push  到harbor时默认使用https协议
```
1,登陆harbor->系统管理->配置管理->系统设置->下载镜像库根证书.
2,将根证书拷贝到/etc/docker/certs.d/reg.dadi01.net/ ,macos拷贝到~/.docker/certs.d/reg.dadi01.net/
3,重启docker
```