### 通过nodeSelector指定node label调度pod
```
# 为node附加lable标签
kubectl label nodes k8s-node1 disk=ssd
# 查看node标签
kubectl get nodes --show-labels
# 删除node标签
kubectl label nodes k8s-node1 disk-
```

* 在pod配置中加nodeSelector
```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  nodeSelector:
    disk: ssd
```

### node亲和性
```
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        ......
      preferredDuringSchedulingIgnoredDuringExecution:
```     
* requiredDuringSchedulingIgnoredDuringExecution （pod 只能被调度到标签满足规则的node 上）
* preferredDuringSchedulingIgnoredDuringExecution （优先选择满足某条件的 node）
* 如果一个 node 的标签在运行时发生改变，从而导致 pod 的亲和性规则不再被满足时，pod 也仍然会继续运行在 node 上

### pod亲和性和反亲和性
>根据已经在 node 上运行的 pod 的标签 来限制 pod 调度在哪个 node 上，而不是基于 node 上的标签
```
spec:
  affinity:
    podAffinity:  #亲和性
      requiredDuringSchedulingIgnoredDuringExecution:
        ......
    podAntiAffinity: #反亲和性
      preferredDuringSchedulingIgnoredDuringExecution:
```
* requiredDuringSchedulingIgnoredDuringExecution（必须至少拥有一个满足条件的pod在node上运行，才会被调度到这个node）
* preferredDuringSchedulingIgnoredDuringExecution（如果有一个满足条件的pod在node上运行，则不把pod调度到这个node上）


