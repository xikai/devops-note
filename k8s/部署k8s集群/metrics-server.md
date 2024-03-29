* https://github.com/kubernetes-sigs/metrics-server
* https://docs.aws.amazon.com/zh_cn/eks/latest/userguide/metrics-server.html

### 部署 Metrics Server
* 下载资源清单文件
```
wget https://github.com/kubernetes-sigs/metrics-server/releases/download/latest/components.yaml -O metrics-server.yaml

# High Availability
wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/high-availability-1.21+.yaml -O metrics-server-ha-1.21+.yaml
```

* 修改清单
```yml
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      containers:
        - name: metrics-server
          #image: k8s.gcr.io/metrics-server/metrics-server:latest
          image: bitnami/metrics-server:latest
          imagePullPolicy: IfNotPresent
          args:
            - --cert-dir=/tmp
            - --secure-port=4443
            - --kubelet-preferred-address-types=InternalIP,Hostname,InternalDNS,ExternalDNS,ExternalIP  #InternalIP 直接使用节点IP地址获取数据
            - --kubelet-insecure-tls  #不验证客户端证书
```
```
kubectl apply -f metrics-server.yaml
```
* 验证
```
$ kubectl get pod -n kube-system |grep metrics-server
metrics-server-5fdc64df8b-kh4sp                   1/1     Running   0          4s
```
```
$ kubectl top nodes
NAME                      CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
k8s-qa-master.novalocal   279m         6%     3348Mi          43%
k8s-qa-node1.novalocal    767m         19%    7343Mi          46%
k8s-qa-node2.novalocal    1182m        29%    7037Mi          44%
k8s-qa-node3.novalocal    809m         20%    7640Mi          48%
```