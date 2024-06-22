# [安装AWS Load Balancer Controller](https://docs.aws.amazon.com/zh_cn/eks/latest/userguide/aws-load-balancer-controller.html)

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
    #alb.ingress.kubernetes.io/group.name: test            # 多个Ingress.yaml文件配置相同的group.name和load-balancer-name,则可以共用同一个ALB负载均衡器,控制器将自动合并相同group.name中所有ingress.yaml的ingress规则
    #alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}, {"HTTP": 8080}, {"HTTPS": 8443}]'
    #alb.ingress.kubernetes.io/certificate-arn: arn:aws-cn:acm:cn-northwest-1:475810397983:certificate/0d804345-35a8-48b5-89ba-ebfbc7341c63
    #alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
    #alb.ingress.kubernetes.io/actions.redirect-to-www: '{"Type": "redirect", "RedirectConfig": { "Host": "www.example.com", "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
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
            pathType: Prefix
            backend:
              service:
                name: "service-2048"
                port:
                  number: 80
    #- host: example.com 
    #  http:
    #    paths:
    #      - path: /
    #        pathType: Prefix
    #        backend:
    #          service:
    #            name: redirect-to-www
    #            port:
    #              name: use-annotation
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