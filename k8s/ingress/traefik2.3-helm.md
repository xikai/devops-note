* https://www.qikqiak.com/traefik-book/
* https://www.qikqiak.com/post/traefik-2.1-101/

```
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
```


* 自定义values
>vim traefik.yaml
```
deployment:
  replicas: 1
resources:
  limits:
    cpu: 1
    memory: 1Gi
  requests:
    cpu: 1
    memory: 1Gi
service:
  enabled: true
  type: ClusterIP
hostNetwork: true
nodeSelector:
  ingress: traefik
```

```
kubectl create namespace traefik

helm install traefik traefik/traefik --namespace=traefik -f traefik.yaml

helm upgrade -f traefik.yaml traefik traefik/traefik --namespace=traefik
```