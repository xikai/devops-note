# [节点压力驱逐](https://kubernetes.io/zh/docs/concepts/scheduling-eviction/node-pressure-eviction/)
* 由于节点的 CPU、内存、磁盘空间和文件系统的 inode 等资源达到特定的消耗水平， kubelet 主动终止 Pod 以回收节点上资源的过程。

### 软驱逐
* 将驱逐条件与管理员所必须指定的宽限期配对。 在超过宽限期之前，kubelet 不会驱逐 Pod。 如果没有指定的宽限期，kubelet 会在启动时返回错误。
驱逐条件(如果驱逐条件持续时长超过指定的宽限期，可以触发 Pod 驱逐)：
eviction-soft: memory.available<1.5Gi
驱逐宽限期(定义软驱逐条件在触发 Pod 驱逐之前必须保持多长时间)：
eviction-soft-grace-period: memory.available=1m30s

### 硬驱逐
* 硬驱逐条件没有宽限期。当达到硬驱逐条件时， kubelet 会立即杀死 pod，而不会正常终止以回收紧缺的资源。
* kubelet 具有以下默认硬驱逐条件：
```
memory.available<100Mi
nodefs.available<10%
imagefs.available<15%
nodefs.inodesFree<5%（Linux 节点）
```

### kubelet 驱逐时 Pod 的选择 
* kubelet 在驱逐最终用户 Pod 之前会先尝试回收节点级资源（例如，它会在磁盘资源不足时删除未使用的容器镜像。）
1. Pod 的资源使用是否超过其请求
2. Pod 优先级
3. Pod 相对于请求的资源使用情况


### 最小驱逐回收
* 在某些情况下，驱逐 Pod 只会回收少量的紧俏资源。 这可能导致 kubelet 反复达到配置的驱逐条件并触发多次驱逐。
```yml
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
evictionHard:
  memory.available: "500Mi"
  nodefs.available: "1Gi"       # 如果 nodefs.available 信号满足驱逐条件， kubelet 会回收资源，直到信号达到 1Gi 的条件
  imagefs.available: "100Gi"
evictionMinimumReclaim:
  memory.available: "0Mi"
  nodefs.available: "500Mi"     # 然后继续回收至少 500Mi 直到信号达到 1.5Gi
  imagefs.available: "2Gi"
```
