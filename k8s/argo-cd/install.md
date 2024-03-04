* https://argo-cd.readthedocs.io/en/stable/


# Install argocd
* https://github.com/argoproj/argo-cd/blob/master/manifests/install.yaml
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

### [install ha argocd](https://argo-cd.readthedocs.io/en/stable/operator-manual/installation/#high-availability)
>与非高可用部署清单包含的组件相同，但增强了高可用能力和弹性能力，推荐在生产环境中使用。
* https://github.com/argoproj/argo-cd/blob/master/manifests/ha/install.yaml
```
# 与上文提到的 install.yaml 的内容相同，但配置了相关组件的多个副本。
curl -o ha-install.yaml https://raw.githubusercontent.com/argoproj/argo-cd/master/manifests/ha/install.yaml
kubectl apply -f ha-install.yaml -n argocd
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
  name: argocd
  namespace: argocd
  annotations:
    alb.ingress.kubernetes.io/load-balancer-name: argocd
    alb.ingress.kubernetes.io/group.name: argocd
    alb.ingress.kubernetes.io/scheme: internal
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/subnets: subnet-0ed62c7b145532283,subnet-049d2f560fb00bc1c
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
    alb.ingress.kubernetes.io/certificate-arn: arn:aws-cn:acm:cn-northwest-1:475810397983:certificate/35284aff-9d42-4e69-a9c1-xxxxxxxxxx
    #alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
spec:
  ingressClassName: alb
  rules:
  - host: argocd.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
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

# 注册外部集群
* 在部署到外部集群时才需要将集群的凭据注册到ArgoCD。在内部部署(到运行Argo CD的同一集群)时，应该使用https://kubernetes.default.svc作为应用程序的K8s API服务器地址。
```
# 将ServiceAccount (argocd-manager)安装到kubectl上下文的kube-system名称空间中，并将服务帐户绑定到一个管理员级的ClusterRole。Argo CD使用此服务帐户令牌执行其管理任务(即部署/监控)。
kubectl config get-contexts -o name
argocd cluster add docker-desktop
```
>可以修改argocd-manager-role角色的规则，使其仅具有对有限的名称空间、组和类型集的创建、更新、修补和删除权限。但是，要使Argo CD发挥作用，在集群作用域中需要get、list和watch权限


# 创建argocd应用
* [argocd app示例](https://github.com/argoproj/argocd-example-apps)
* 从Git仓库创建一个应用程序，在 GitHub 上创建一个项目，取名为 argocd-lab
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  selector:
    matchLabels:
      app: myapp
  replicas: 2
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: nginx:latest
        ports:
        - containerPort: 80
        
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
```

* 在仓库根目录中创建一个 Application 的配置清单
```yml
# application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp-argo-application
  namespace: argocd
spec:
  project: default

  source:
    repoURL: https://github.com/yangchuansheng/argocd-lab.git
    targetRevision: HEAD
    path: dev
  destination: 
    server: https://kubernetes.default.svc
    namespace: myapp

  syncPolicy:     #指定自动同步策略和频率，不配置时需要手动触发同步 
    syncOptions:  #定义同步方式
    - CreateNamespace=true  #如果不存在这个 namespace，就会自动创建它

    automated:  #检测到实际状态与期望状态不一致时，采取的同步措施
      selfHeal: true  #当集群实际状态不符合期望状态时，自动同步
      prune: true     #自动同步时，删除 Git 中不存在的资源

# Argo CD 默认情况下每 3 分钟会检测 Git 仓库一次，用于判断应用实际状态是否和 Git 中声明的期望状态一致，如果不一致，状态就转换为 OutOfSync。默认情况下并不会触发更新，除非通过 syncPolicy 配置了自动同步
```
```
kubectl apply -f application.yaml
```

# 命令行cli
* 创建应用
```
kubectl config set-context --current --namespace=argocd
argocd app create guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path guestbook --dest-server https://kubernetes.default.svc --dest-namespace default
```
* 同步(部署)应用
```
#查看应用状态
argocd app get guestbook
#同步(部署)应用
argocd app sync guestbook
```