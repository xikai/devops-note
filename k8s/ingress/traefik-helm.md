### NodePord traefik
* 编写覆盖values配置文件
>vi traefik/traefik.yaml
```
serviceType: NodePort
replicas: 2
resources:
  limits:
    cpu: 1
    memory: 1Gi
  requests:
    cpu: 1
    memory: 1Gi
ssl:
  enabled: true
dashboard:
  enabled: true
  domain: traefik.dadi01.net
service:
  nodePorts:
    http: 30080
    https: 30443
rbac:
  enabled: true
metrics:
  prometheus:
    enabled: true
```

* 安装traefik ingress-controller
```
helm install stable/traefik --name traefik-ingress-controller --namespace kube-system -f traefik/traefik.yaml

helm upgrade -f traefik/traefik.yaml traefik-ingress-controller stable/traefik --namespace kube-system
```

* 配置负载均衡
```
将节点的30080加到负载均衡（如阿里云的ELB、Haproxy、F5等）后面，负载均衡对外提供80、443端口的访问。
通过将traefik.dadi01.net解析到负载均衡的VIP上就能够访问Traefik的dashboard了
```


### hostNetwork traefik
* 下载traefik helm chart
```
git clone https://github.com/helm/charts.git
cd stable/traefik
```

* 修改为hostNetwork网络模式
>vim templates/deployment.yaml
```
spec:
  template:
    spec:
      hostNetwork: true    #修改为hostNetwork网络模式
      {{- if .Values.nodeSelector }}
      nodeSelector:
{{ toYaml .Values.nodeSelector | indent 8 }}
      {{- end }}
```
>vim templates/service.yaml (或删除service.yaml)
```
spec:
  #type: {{ .Values.serviceType }}  #注释service type 改为默认ClusterIP
```


* 编写覆盖values配置文件
>vi traefik-host.yaml
```
replicas: 2
resources:
  limits:
    cpu: 1
    memory: 1Gi
  requests:
    cpu: 1
    memory: 1Gi
ssl:
  enabled: true
dashboard:
  enabled: true
  domain: traefik.dadi01.cn
rbac:
  enabled: true
metrics:
  prometheus:
    enabled: true
nodeSelector:
  ingress: traefik
externalTrafficPolicy: ""
```

* 为node节点打标签
```
kubectl label nodes k8s-node01 ingress=traefik
kubectl label nodes k8s-node02 ingress=traefik
kubectl get nodes --show-labels
```

* 安装traefik ingress-controller
```
helm install --name traefik-ingress-controller -f ./traefik-host.yaml . --namespace kube-system

helm upgrade -f ./traefik-host.yaml traefik-ingress-controller . --namespace kube-system
```