https://github.com/nginxinc/kubernetes-ingress/blob/master/docs/installation.md
### 安装nginx-ingress-controller
* 下载nginx-ingress-controller
```
git clone https://github.com/nginxinc/kubernetes-ingress.git
[root@k8s-master01 ~]# cd kubernetes-ingress/deployments/
[root@k8s-master01 ~]# ll
total 4
drwxr-xr-x 2 root root  87 Dec  9 04:03 common
drwxr-xr-x 2 root root 152 Dec  9 04:03 daemon-set
drwxr-xr-x 2 root root 152 Dec  9 04:03 deployment
drwxr-xr-x 3 root root 124 Dec  9 04:03 helm-chart
drwxr-xr-x 2 root root  23 Dec  9 04:03 rbac
-rw-r--r-- 1 root root 184 Dec  9 04:03 README.md
drwxr-xr-x 2 root root  85 Dec  9 04:03 service
```
* 创建namespace、SericeAccount、Secret 、ConfigMap
```
kubectl apply -f common/ns-and-sa.yaml
kubectl apply -f common/default-server-secret.yaml
kubectl apply -f common/nginx-config.yaml
```
* 配置RBAC绑定集群角色
```
kubectl apply -f rbac/rbac.yaml
```
* 修改nginx pods使用hostNetwork网络模式
>vim nginx-ingress.yaml
```
spec:
  hostNetwork: true      #hostNetwork网络模式
  restartPolicy: Always
```
* 安装nginx-ingress-controller
```
kubectl apply -f deployment/nginx-ingress.yaml
### kubectl apply -f daemon-set/nginx-ingress.yaml
```
```
[root@k8s-master01 deployments]# kubectl get pods --namespace=nginx-ingress
NAME                             READY   STATUS    RESTARTS   AGE
nginx-ingress-7745fdf7bb-dh69w   1/1     Running   0          4m52s
nginx-ingress-7745fdf7bb-kxvhb   1/1     Running   0          13h
```


### 发布ingress(nginx-test)
* 创建测试应用
>vim nginx-test.yaml
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment-test
  labels:
    app: nginx-test
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-test
  template:
    metadata:
      labels:
        app: nginx-test
    spec:
      containers:
      - name: nginx
        image: nginx:1.10.3
        ports:
        - containerPort: 80
---
kind: Service
apiVersion: v1
metadata:
  name: nginx-service-test
spec:
  ports:
    - name: nginx-test
      port: 80
      targetPort: 80
  selector:
    app: nginx-test
```
```
kubectl create -f nginx-test.yaml
```

* 创建ingress
>vim ingress-nginx-test
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-nginx-test
spec:
  rules:
  - host: nginxtest.k8s
    http:
      paths:
      - path: /
        backend:
          serviceName: nginx-service-test
          servicePort: nginx-test
```
```
kubectl create -f ingress-nginx-test.yaml
```
```
[root@k8s-master01 ~]# kubectl describe ing ingress-nginx-test
Name:             ingress-nginx-test
Namespace:        default
Address:          
Default backend:  default-http-backend:80 (<none>)
Rules:
  Host           Path  Backends
  ----           ----  --------
  nginxtest.k8s  
                 /   nginx-service-test:nginx-test (<none>)
Annotations:
Events:  <none>

```

* 配置hosts解析访问nginx-test
>C:\Windows\System32\drivers\etc\hosts
```
192.168.140.112 nginxtest.k8s
192.168.140.113 nginxtest.k8s
```
```
http://nginxtest.k8s
------
Welcome to nginx!
If you see this page, the nginx web server is successfully installed and working. Further configuration is required.

For online documentation and support please refer to nginx.org.
Commercial support is available at nginx.com.

Thank you for using nginx.
-------
```