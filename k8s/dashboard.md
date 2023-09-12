* https://github.com/kubernetes/dashboard/tree/master/docs
* https://kubernetes.io/zh-cn/docs/tasks/access-application-cluster/web-ui-dashboard/
* https://github.com/kubernetes/dashboard/blob/v2.7.0/docs/common/dashboard-arguments.md

# 部署k8s dashboard
>当使用推荐的设置安装Kubernetes Dashboard时，身份验证和HTTPS都是启用的
```
# https://github.com/kubernetes/dashboard/releases/latest
wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
kubectl apply -f recommended.yaml
```

### [访问dashboard](https://github.com/kubernetes/dashboard/blob/master/docs/user/accessing-dashboard/README.md)
* 访问podIP
```
# 本地与k8s集群网络连通的前提下，直接访问
https://podIP:8443
```
* kubectl port-forward
```
kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8080:443
```
```
https://localhost:8080
```

* NodePort
>vim recommended.yaml 修改service
```yml
# ------------------- Dashboard Service ------------------- #

kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  ports:
    - port: 443
      targetPort: 8443
      nodePort: 30001    # 添加nodeport固定IP
  type: NodePort         # service类型为NodePort
  selector:
    k8s-app: kubernetes-dashboard
```

# 禁用https启用http安装方式
>当Kubernetes Dashboard在反向代理之后提供服和时，你希望取消HTTPS使用HTTP提供服务，因为Kubernetes Dashboard使用自动生成的HTTPS证书，这可能会导致HTTP客户端访问出现问题。
```yml
kind: Deployment
apiVersion: apps/v1
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  template:
    spec:
      containers:
        - name: kubernetes-dashboard
          image: kubernetesui/dashboard:v2.7.0
          imagePullPolicy: Always
          ports:
            - containerPort: 9090  #http默认端口9090
              protocol: TCP
          args:
            #取消自动生产ssl证书，增加--enable-insecure-login，--insecure-bind-address=0.0.0.0
            #- --auto-generate-certificates  
            - --enable-insecure-login
            - --insecure-bind-address=0.0.0.0
            - --namespace=kubernetes-dashboard
          livenessProbe:  #修改健康检测协议为HTTP，insecure-login默认端口9090
            httpGet:
              scheme: HTTP
              path: /
              port: 9090
```
```yml
kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  ports:
    - port: 80          #修改service端口
      targetPort: 9090  #http端口
  selector:
    k8s-app: kubernetes-dashboard
```

* ingress代理访问 (禁用https启用http安装方式)
```yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
  annotations:
    alb.ingress.kubernetes.io/load-balancer-name: newdev-front-internal
    alb.ingress.kubernetes.io/group.name: newdev-front-internal
    alb.ingress.kubernetes.io/scheme: internal
    alb.ingress.kubernetes.io/subnets: subnet-0ed62c7b145532283,subnet-049d2f560fb00bc1c
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
    alb.ingress.kubernetes.io/certificate-arn: arn:aws-cn:acm:cn-northwest-1:1234567890123:certificate/35284aff-9d42-4e69-a9c1-123456789
    alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
    alb.ingress.kubernetes.io/ssl-policy: ELBSecurityPolicy-TLS-1-2-2017-01
    alb.ingress.kubernetes.io/tags: cost=newdev
spec:
  ingressClassName: alb
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ssl-redirect
                port: 
                  name: use-annotation
    - host: dashboard.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: kubernetes-dashboard
                port:
                  number: 80
```
* 访问地址
```
https://dashboard.example.com
```

# [创建身份验证令牌用户 (RBAC)](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md)
* 创建集群管理员，admin-user.yaml
```yml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: v1
kind: Secret
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
  annotations:
    kubernetes.io/service-account.name: "admin-user"   
type: kubernetes.io/service-account-token  
```
```
# 获取admin-user的token
kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d
```

* [RBAC授权](https://kubernetes.io/zh-cn/docs/reference/access-authn-authz/rbac/)
```yml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dev-user
  namespace: test
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding   ###如果使用RoleBinding，只授权控制 RoleBinding 所在命名空间中的所有资源。
metadata:
  name: dev-user
  namespace: test
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole ###`kubectl get ClusterRole`查看ClusterRole；
  name: edit       ###admin不允许对资源配额或者命名空间本身进行写操作,edit不允许查看或者修改角色（Roles）或者角色绑定（RoleBindings）,view允许对命名空间的大多数对象有只读权限。它不允许查看角色（Roles）或角色绑定（RoleBindings），它不允许查看 Secrets; `kubectl get ClusterRole admin -oyaml` 查询指定ClusterRole的当前权限信息；
subjects:
- kind: ServiceAccount
  name: dev-user
  namespace: test
---
apiVersion: v1
kind: Secret
metadata:
  name: dev-user
  namespace: test
  annotations:
    kubernetes.io/service-account.name: "admin-user"   
type: kubernetes.io/service-account-token 
```
```
# 获取dev-user的token
kubectl get secret dev-user -n test -o jsonpath={".data.token"} | base64 -d
```