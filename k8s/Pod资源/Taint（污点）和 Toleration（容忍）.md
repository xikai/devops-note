https://k8smeetup.github.io/docs/concepts/configuration/taint-and-toleration/

### Taint（污点）和 Toleration（容忍）
* Taint（污点）和 Toleration（容忍）可以作用于 node 和 pod 上，其目的是优化 pod 在集群间的调度，这跟节点亲和性类似，只不过它们作用的方式相反，具有 taint 的 node 和 pod 是互斥关系，而具有节点亲和性关系的 node 和 pod 是相吸的
* Taint 和 toleration 相互配合，可以用来避免 pod 被分配到不合适的节点上。每个节点上都可以应用一个或多个 taint ，这表示对于那些不能容忍这些 taint 的 pod，是不会被该节点接受的。如果将 toleration 应用于 pod 上，则表示这些 pod 可以（但不要求）被调度到具有相应 taint 的节点上


```
# 给节点增加一个 taint
kubectl taint nodes node1 key1=value1:NoSchedule
# 从节点删除taint
kubectl taint nodes node1 key1:NoSchedule
```
* 只有拥有和这个 taint 相匹配的 toleration 的 pod 才能够被分配到 node1 这个节点
```
tolerations:
- key: "key1"
  operator: "Equal"
  value: "value1"
  effect: "NoSchedule"
```
```
tolerations:
- key: "key"
  operator: "Exists"
  effect: "NoSchedule"
```

>toleration 能容忍任意 taint
```
tolerations:
- operator: "Exists"
```
>toleration 能容忍任意effect的taint
```
tolerations:
- key: "key"
  operator: "Exists"
```

* 可以给一个节点添加多个 taint ，也可以给一个 pod 添加多个 toleration,Kubernetes 从一个节点的所有 taint 开始遍历，过滤掉那些 pod 中存在与之相匹配的 toleration 的 taint。余下未被过滤的 taint 的 effect 值决定了 pod 是否会被分配到该节点
  - 如果未被过滤的 taint 中存在一个以上 effect 值为 NoSchedule 的 taint，则 Kubernetes 不会将 pod 分配到该节点。
  - 如果未被过滤的 taint 中不存在 effect 值为 NoSchedule 的 taint，但是存在 effect 值为 PreferNoSchedule 的 taint，则 Kubernetes 会尝试将 pod 分配到该节点。
  - 如果未被过滤的 taint 中存在一个以上 effect 值为 NoExecute 的 taint，则 Kubernetes 不会将 pod 分配到该节点（如果 pod 还未在节点上运行），或者将 pod 从该节点驱逐（如果 pod 已经在节点上运行）



### 基于 taint 的驱逐pod
* taint 的 effect 值 NoExecute ，它会影响已经在节点上运行的 pod
  - 如果 pod 不能忍受effect 值为 NoExecute 的 taint，那么 pod 将马上被驱逐
  - 如果 pod 能够忍受effect 值为 NoExecute 的 taint，但是在 toleration 定义中没有指定 tolerationSeconds，则 pod 还会一直在这个节点上运行
  - 如果 pod 能够忍受effect 值为 NoExecute 的 taint，而且指定了 tolerationSeconds，则 pod 还能在这个节点上继续运行这个指定的时间长度
  
* 当某种条件为真时，node controller会自动给节点添加一个 taint。当前内置的 taint 包括：
```
node.kubernetes.io/not-ready：节点未准备好。这相当于节点状态 Ready 的值为 “False“。
node.alpha.kubernetes.io/unreachable：node controller 访问不到节点. 这相当于节点状态 Ready 的值为 “Unknown“。
node.kubernetes.io/out-of-disk：节点磁盘耗尽。
node.kubernetes.io/memory-pressure：节点存在内存压力。
node.kubernetes.io/disk-pressure：节点存在磁盘压力。
node.kubernetes.io/network-unavailable：节点网络不可用。
node.cloudprovider.kubernetes.io/uninitialized：如果 kubelet 启动时指定了一个 “外部” cloud provider，它将给当前节点添加一个 taint 将其标志为不可用。在 cloud-controller-manager 的一个 controller 初始化这个节点后，kubelet 将删除这个 taint。
```
>Kubernetes 会自动添加 toleration 机制保证了在not-ready、unreachable问题被检测到时 pod 默认能够继续停留在当前节点运行 5 分钟
* 避免 pod 被驱逐，当内置taint条件为真时
```
tolerations:
- key: "node.alpha.kubernetes.io/unreachable"
  operator: "Exists"
  effect: "NoExecute"
  tolerationSeconds: 6000
```