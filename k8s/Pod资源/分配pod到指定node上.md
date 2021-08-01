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

### 节点亲和性
```
apiVersion: v1
kind: Pod
metadata:
  name: with-node-affinity
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        ......
      preferredDuringSchedulingIgnoredDuringExecution:
```     
* requiredDuringSchedulingIgnoredDuringExecution （pod只能被调度到标签满足规则的node 上）
* preferredDuringSchedulingIgnoredDuringExecution （优先选择满足某条件的 node）
* 如果一个 node 的标签在运行时发生改变，从而导致 pod 的亲和性规则不再被满足时，pod 也仍然会继续运行在 node 上。requiredDuringSchedulingRequiredDuringExecution则相反它会将 Pod 从不再满足 Pod 的节点亲和性要求的节点上驱逐。



### pod亲和性和反亲和性
>基于已经在节点上运行的 Pod 的标签 来约束 Pod 可以调度到的节点，而不是基于节点上的标签。
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


