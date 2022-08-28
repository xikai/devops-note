* https://argo-cd.readthedocs.io/en/stable/


# Install argocd
```
kubectl create namespace argocd
curl -o install.yaml https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f install.yaml -n argocd
```
```
Argo CD 会运行一个 gRPC 服务（由 CLI 使用）和 HTTP/HTTPS 服务（由 UI 使用），这两种协议都由 argocd-server 服务在以下端口进行暴露：
443 - gRPC/HTTPS
80 - HTTP（重定向到 HTTPS）
```

# Install argocd cli
* Download latest version
```
curl -L -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd
```
* Download concrete version
```
VERSION=<TAG> # Select desired TAG from https://github.com/argoproj/argo-cd/releases
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64
chmod +x /usr/local/bin/argocd
```


# Access The Argo CD API Server
### Port Forwarding argocd service
```
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
```
https://localhost:8080
```

### Service Type Load Balancer
```
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

### [ingress] (https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/)
* 修改argocd-server Deployment 不启用 tls
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/component: server
    app.kubernetes.io/name: argocd-server
    app.kubernetes.io/part-of: argocd
  name: argocd-server
spec:
  template:
    spec:
      containers:
      - command:
        - argocd-server
        - --insecure  #不启用 tls
```
* argocd-ingress.yaml
```yml
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    annotations:
      kubernetes.io/ingress.class: alb
      alb.ingress.kubernetes.io/scheme: internal
      alb.ingress.kubernetes.io/target-type: ip
      alb.ingress.kubernetes.io/subnets: subnet-011c4c7230dbd2dc8,subnet-0e3de58be862175c0
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}]'
      alb.ingress.kubernetes.io/group.name: argocd
    name: argocd
    namespace: argocd
  spec:
    rules:
    - host: argocd.yourdomain.com
      http:
        paths:
        - path: /*
          backend:
            service:
              name: argocd-server
              port:
                number: 80
```

### 访问argocd UI
* 初始密码
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```
```
http://argocd.yourdomain.com
admin
xxxxxxxx
```