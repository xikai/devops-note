* 修改calico MTU
>kubectl edit configmaps -n kube-system canal-config
```
# Currently, RKE does not support configuring MTU，which can be configured manually：
# Add "mtu": "1450" under "type": "calico"

  cni_network_config: |-
    {
      "name": "k8s-pod-network",
      "cniVersion": "0.3.1",
      "plugins": [
        {
          "type": "calico",
          "mtu": 1450,
          "log_level": "info",
          "datastore_type": "kubernetes",
          "nodename": "__KUBERNETES_NODE_NAME__",
          "ipam": {
              "type": "host-local",
              "subnet": "usePodCidr"
          },
          "policy": {
              "type": "k8s"
          },
```
```
# Delete the canal pod and let it be recreated
kubectl get pod -n kube-system |grep canal |awk '{print $1}' | xargs kubectl delete -n kube-system pod
```

* 最简单的 nginx 测试服务
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 3
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

* 在指定节点运行pod
```
kubectl run -it alpine --image=alpine --overrides='{"apiVersion":"apps/v1","spec":{"template":{"spec":{"nodeSelector":{"kubernetes.io/hostname":"k8s-test-node2"}}}}}'
```

* 测试容器网络连通性
```
ping www.baidu.com
curl www.baidu.com
```

* 测试POD跨节点连通性

* 测试service连通性

