* https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/

# [安装AWS Load Balancer Controller](https://docs.aws.amazon.com/zh_cn/eks/latest/userguide/aws-load-balancer-controller.html)
### 创建一个 IAM 策略 (该策略允许负载均衡器代表您调用 AWS API)
```
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.0/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json
```

### 创建角色
* 查看集群的 OIDC 提供商 URL
```
aws eks describe-cluster --name my-cluster --query "cluster.identity.oidc.issuer" --output text
输出示例：
https://oidc.eks.region-code.amazonaws.com/id/EXAMPLED539D4633E53DE1B716D3041E
```
* 创建信任策略, load-balancer-role-trust-policy.json 替换为上面输出的id
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::111122223333:oidc-provider/oidc.eks.region-code.amazonaws.com/id/EXAMPLED539D4633E53DE1B716D3041E"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.region-code.amazonaws.com/id/EXAMPLED539D4633E53DE1B716D3041E:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
                }
            }
        }
    ]
}
```
* 创建角色并附加信任策略
```
aws iam create-role \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --assume-role-policy-document file://"load-balancer-role-trust-policy.json"
```
* 附加IAM策略到角色
```
aws iam attach-role-policy \
  --policy-arn arn:aws:iam::111122223333:policy/AWSLoadBalancerControllerIAMPolicy \
  --role-name AmazonEKSLoadBalancerControllerRole
```

* 创建ServiceAccount帐户, aws-load-balancer-controller-service-account.yaml
```yml
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: aws-load-balancer-controller
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::111122223333:role/AmazonEKSLoadBalancerControllerRole
```
```
kubectl apply -f aws-load-balancer-controller-service-account.yaml
```

### 安装AWS Load Balancer Controller
* 安装 cert-manager 以将证书配置注入 Webhook
```
kubectl apply \
    --validate=false \
    -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml
```
* 安装aws-load-balancer-controller
```yml
curl -Lo v2_4_0_full.yaml https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.4.0/v2_4_0_full.yaml

# 删除此部分可防止在部署控制器时覆盖在上一步中添加的 IAM 角色注释
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: aws-load-balancer-controller
  name: aws-load-balancer-controller
  namespace: kube-system

# Deployment spec 部分中的 your-cluster-name 替换为您的集群名称，并在 --ingress-class=alb 下添加 following parameters
...
spec:
      containers:
        - args:
            - --cluster-name=your-cluster-name
            - --ingress-class=alb
              --enable-shield=false
              --enable-waf=false
              --enable-wafv2=false
...
```
```
kubectl apply -f v2_4_0_full.yaml
```
```
kubectl get deployment -n kube-system aws-load-balancer-controller
```


# [Kubernetes Ingress - Application Load Balancer  ALB](https://docs.aws.amazon.com/zh_cn/eks/latest/userguide/alb-ingress.html)
* annotations: https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/guide/ingress/annotations/
```yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: "2048-ingress"
  namespace: "2048-game"
  labels:
    app: 2048-nginx-ingress
  annotations:
    kubernetes.io/ingress.class: alb
    #alb.ingress.kubernetes.io/load-balancer-name: k8s-game2048
    alb.ingress.kubernetes.io/scheme: internet-facing
    #alb.ingress.kubernetes.io/scheme: (internet-facing|internal)            # internal表示内网alb，internet-facing表示公网alb
    alb.ingress.kubernetes.io/target-type: ip
    #alb.ingress.kubernetes.io/target-type: (ip|instance)       # 目标为Instance，这种类型需配置service为nodePort方式；
    alb.ingress.kubernetes.io/subnets: subnet-87717ccd,subnet-3f129e56,subnet-a7b716dc
    #alb.ingress.kubernetes.io/group.name: test            # 多个Ingress resource配置相同的Ingress name和Ingress Groups，则可以共用同一个ALB负载均衡器
    #alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}, {"HTTP": 8080}, {"HTTPS": 8443}]'
    #alb.ingress.kubernetes.io/certificate-arn: arn:aws-cn:acm:cn-northwest-1:475810397983:certificate/0d804345-35a8-48b5-89ba-ebfbc7341c63
    #alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
    #alb.ingress.kubernetes.io/backend-protocol: (HTTP|HTTPS)     #路由流量到后端应用所用的协议
    #alb.ingress.kubernetes.io/backend-protocol-version: HTTP2      #路由流量到后端应用所用的协议版本，HTTP2/GRPC,默认为HTTP1
    #alb.ingress.kubernetes.io/healthcheck-protocol: (HTTP|HTTPS)
    #alb.ingress.kubernetes.io/healthcheck-port: (integer|traffic-port)
    #alb.ingress.kubernetes.io/healthcheck-path: /ping
spec:
  rules:
    - host: 2048.example.com
      http:
        paths:
          - path: /
            backend:
              service:
                name: "service-2048"
                port:
                  number: 80
```


# [Kubernetes service - LoadBalancer NLB](https://docs.aws.amazon.com/zh_cn/eks/latest/userguide/network-load-balancing.html)
* https://kubernetes.io/zh/docs/concepts/services-networking/service/#loadbalancer
* https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/guide/service/nlb/
```yml
apiVersion: v1
kind: Service
metadata:
  name: nlb-sample-service
  namespace: nlb-sample-app
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: external         #创建NLB负载均衡器(AWS Load Balancer Controller)，而不是AWS cloud provider load balancer controller
    service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip    #创建NLB ip模式，直接将数据包发到pod的ip地址，如要使用此模式，Kubernetes 集群的联网插件（也就是 适用于 Kubernetes 的 AWS CNI 插件）必须将 ENI 上的第二个 IP 地址作为 Pod IP
    #service.beta.kubernetes.io/aws-load-balancer-type: "nlb"           #nlb创建NLB instance模式, nlb-ip创建NLB ip模式。向后兼容 上面注释将被忽略。本质上NLB instance模式和CLB没有本质区别，网络流量完全相同，均需要将流量先转发到Node port。但是使用NLB ip模式则可以跨过ClusterIP流量直达pod,因此可以通过此模式获取client真实ip地址
    #service.beta.kubernetes.io/aws-load-balancer-internal: "true"          #内部负载均衡器
    service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
    #service.beta.kubernetes.io/aws-load-balancer-backend-protocol: https   #指定 Pod 使用哪种协议(https|http|ssl|tcp)
    #service.beta.kubernetes.io/aws-load-balancer-ssl-cert: arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012
spec:
  ports:
    - port: 80
      targetPort: 80
      protocol: TCP
  type: LoadBalancer
  selector:
    app: nginx
```

* kubectl get svc nlb-sample-service -n nlb-sample-app
```
NAME            TYPE           CLUSTER-IP         EXTERNAL-IP                                                                    PORT(S)        AGE
sample-service  LoadBalancer   10.100.240.137   k8s-nlbsampl-nlbsampl-xxxxxxxxxx-xxxxxxxxxxxxxxxx.elb.us-west-2.amazonaws.com   80:32400/TCP   16h
```