* 在指定节点运行pod
```
kubectl run -it alpine2 --image=alpine --overrides='{"apiVersion":"apps/v1","spec":{"template":{"spec":{"nodeSelector":{"kubernetes.io/hostname":"k8s-test-node2"}}}}}'
```

* 最简单的 nginx 测试服务
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx

---

apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  type: ClusterIP
  ports:
  - port: 80
    protocol: TCP
    name: http
  selector:
    app: nginx
```