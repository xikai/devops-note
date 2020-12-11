* https://traefik.io/
* https://docs.traefik.io/user-guide/kubernetes/#deploy-traefik-using-a-deployment-or-daemonset

### 安装traefik-ingress-controller
* 下载traefik
```
git clone https://github.com/containous/traefik
[root@k8s-master01 traefik]# ll traefik/examples/k8s
total 36
-rw-r--r-- 1 root root  140 Dec  7 12:22 cheese-default-ingress.yaml
-rw-r--r-- 1 root root 1805 Dec  7 12:22 cheese-deployments.yaml
-rw-r--r-- 1 root root  519 Dec  7 12:22 cheese-ingress.yaml
-rw-r--r-- 1 root root  509 Dec  7 12:22 cheese-services.yaml
-rw-r--r-- 1 root root  504 Dec  7 12:22 cheeses-ingress.yaml
-rw-r--r-- 1 root root 1120 Dec  7 12:22 traefik-deployment.yaml
-rw-r--r-- 1 root root 1206 Dec  7 12:22 traefik-ds.yaml
-rw-r--r-- 1 root root  694 Dec  7 12:22 traefik-rbac.yaml
-rw-r--r-- 1 root root  471 Dec  7 12:22 ui.yaml
```
* 给node打标签，将traefik控制器安装到指定node
```
kubectl label nodes k8s-node-1 ingress=traefik
kubectl label nodes k8s-node-2 ingress=traefik
```

* 修改traefik pods使用hostNetwork网络模式(不需要service)
>vim traefik-deployment.yaml、traefik-ds.yaml
```
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: traefik-ingress-controller
  namespace: kube-system
---
kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: traefik-ingress-controller
  namespace: kube-system
  labels:
    k8s-app: traefik-ingress-lb
spec:
  replicas: 2                 #创建两个pod
  selector:
    matchLabels:
      k8s-app: traefik-ingress-lb
  template:
    metadata:
      labels:
        k8s-app: traefik-ingress-lb
        name: traefik-ingress-lb
    spec:
      serviceAccountName: traefik-ingress-controller
      terminationGracePeriodSeconds: 60
      hostNetwork: true        #启用hostNetwork网络模式
      restartPolicy: Always
      nodeSelector:
        ingress: traefik       #将pod创建到指定node节点上
      containers:
      - image: traefik
        name: traefik-ingress-lb
        ports:
        - name: http
          containerPort: 80
        - name: admin
          containerPort: 8080
        args:
        - --api
        - --kubernetes
        - --logLevel=INFO
```

* 启动traefik-ingress-controller(使用deployment或DaemonSet)
>80 对应服务端口，8080对应UI端口
```
# 绑定集群角色
kubectl create -f traefik/examples/k8s/traefik-rbac.yaml 

# 通过deployment部署
kubectl create -f traefik/examples/k8s/traefik-deployment.yaml
# 通过DaemonSet部署(在每个node启动一个traefik pod)
# kubectl create -f traefik/examples/k8s/traefik-ds.yaml
```
```
[root@k8s-master01 k8s]# kubectl get pod -n kube-system -o wide|grep traefik
traefik-ingress-controller-76c5b97f7b-4mclh   1/1     Running   0          20m    172.22.0.12   k8s-node-1     <none>           <none>
traefik-ingress-controller-76c5b97f7b-9gfxr   1/1     Running   0          20m    172.22.0.21   k8s-node-3     <none>           <none>       80/TCP,8080/TCP   4s

[root@k8s-node01 ~]# netstat -lntp|grep traefik
tcp6       0      0 :::80                   :::*                    LISTEN      39845/traefik       
tcp6       0      0 :::8080                 :::*                    LISTEN      39845/traefik 
```
* 访问traefix-ui
```
http://<node_ip>:8080
```

### 发布traefix-ui ingress
* 发布了一个host名为traefix-ui.k8s，后端service为traefix-web-ui的ingress
* traefix-ui己经通过hostNetwork监听节点端口，不需要再用ingress发布，此处只用于测试示例
>vim traefik/examples/k8s/ui.yaml
```
---
apiVersion: v1
kind: Service
metadata:
  name: traefik-web-ui
  namespace: kube-system
spec:
  selector:
    k8s-app: traefik-ingress-lb
  ports:
  - name: web
    port: 80
    targetPort: 8080
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: traefik-web-ui
  namespace: kube-system
spec:
  rules:
  - host: traefik-ui.k8s
    http:
      paths:
      - path: /
        backend:
          serviceName: traefik-web-ui
          servicePort: web
```
```
kubectl create -f traefik/examples/k8s/ui.yaml
```
```
[root@k8s-master01 k8s]# kubectl get ing -n kube-system
NAMESPACE     NAME             HOSTS            ADDRESS   PORTS   AGE
kube-system   traefik-web-ui   traefik-ui.k8s             80      80m


[root@k8s-master01 k8s]# kubectl describe ing traefik-web-ui -n kube-system
Name:             traefik-web-ui
Namespace:        kube-system
Address:          
Default backend:  default-http-backend:80 (<none>)
Rules:
  Host            Path  Backends
  ----            ----  --------
  traefik-ui.k8s  
                  /   traefik-web-ui:web (192.168.140.112:8080,192.168.140.113:8080)
Annotations:
Events:  <none>
```
* 配置hosts解析访问traefix-ui
>C:\Windows\System32\drivers\etc\hosts
```
192.168.140.112 traefik-ui.k8s
192.168.140.113 traefik-ui.k8s
```

* 访问traefik-ui
```
http://traefik-ui.k8s
```

