# [pod调度](https://kubernetes.io/zh/docs/concepts/scheduling-eviction/kube-scheduler/)
> 调度器（kube-scheduler ）通过 （Watch）机制 kubernetes apiserver来发现集群中新创建且尚未被调度到 Node 上的 Pod
1. 过滤(根据Pod的资源请求，对满足Pod 调度请求的所有 Node 称之为 可调度节点)
```
# 以下断言实现了过滤接口：
PodFitsHostPorts：检查 Pod 请求的端口（网络协议类型）在节点上是否可用。
PodFitsHost：检查 Pod 是否通过主机名指定了 Node。
PodFitsResources：检查节点的空闲资源（例如，CPU和内存）是否满足 Pod 的要求。
MatchNodeSelector：检查 Pod 的节点选择算符 和节点的 标签 是否匹配。
NoVolumeZoneConflict：给定该存储的故障区域限制， 评估 Pod 请求的卷在节点上是否可用。
NoDiskConflict：根据 Pod 请求的卷是否在节点上已经挂载，评估 Pod 和节点是否匹配。
MaxCSIVolumeCount：决定附加 CSI 卷的数量，判断是否超过配置的限制。
CheckNodeMemoryPressure：如果节点正上报内存压力，并且没有异常配置，则不会把 Pod 调度到此节点上。
CheckNodePIDPressure：如果节点正上报进程 ID 稀缺，并且没有异常配置，则不会把 Pod 调度到此节点上。
CheckNodeDiskPressure：如果节点正上报存储压力（文件系统已满或几乎已满），并且没有异常配置，则不会把 Pod 调度到此节点上。
CheckNodeCondition：节点可用上报自己的文件系统已满，网络不可用或者 kubelet 尚未准备好运行 Pod。 如果节点上设置了这样的状况，并且没有异常配置，则不会把 Pod 调度到此节点上。
PodToleratesNodeTaints：检查 Pod 的容忍 是否能容忍节点的污点。
CheckVolumeBinding：基于 Pod 的卷请求，评估 Pod 是否适合节点，这里的卷包括绑定的和未绑定的 PVCs 都适用。
```
2. 打分(根据一系列函数对这些可调度节点打分， 选出其中得分最高的 Node 来运行 Pod。如果存在多个得分最高的 Node，kube-scheduler 会从中随机选取一个)
```
# 以下优先级实现了打分接口
SelectorSpreadPriority：属于同一 Service、 StatefulSet 或 ReplicaSet 的 Pod，跨主机部署。
InterPodAffinityPriority：实现了 Pod 间亲和性与反亲和性的优先级。
LeastRequestedPriority：偏向最少请求资源的节点。 换句话说，节点上的 Pod 越多，使用的资源就越多，此策略给出的排名就越低。
MostRequestedPriority：支持最多请求资源的节点。 该策略将 Pod 调度到整体工作负载所需的最少的一组节点上。
RequestedToCapacityRatioPriority：使用默认的打分方法模型，创建基于 ResourceAllocationPriority 的 requestedToCapacity。
BalancedResourceAllocation：偏向平衡资源使用的节点。
NodePreferAvoidPodsPriority：根据节点的注解 scheduler.alpha.kubernetes.io/preferAvoidPods 对节点进行优先级排序。 你可以使用它来暗示两个不同的 Pod 不应在同一节点上运行。
NodeAffinityPriority：根据节点亲和中 PreferredDuringSchedulingIgnoredDuringExecution 字段对节点进行优先级排序。 你可以在将 Pod 分配给节点中了解更多。
TaintTolerationPriority：根据节点上无法忍受的污点数量，给所有节点进行优先级排序。 此策略会根据排序结果调整节点的等级。
ImageLocalityPriority：偏向已在本地缓存 Pod 所需容器镜像的节点。
ServiceSpreadingPriority：对于给定的 Service，此策略旨在确保该 Service 关联的 Pod 在不同的节点上运行。 它偏向把 Pod 调度到没有该服务的节点。 整体来看，Service 对于单个节点故障变得更具弹性。
EqualPriority：给予所有节点相等的权重。
EvenPodsSpreadPriority：实现了 Pod 拓扑扩展约束的优先级排序。
```




# [节点压力驱逐](https://kubernetes.io/zh/docs/concepts/scheduling-eviction/node-pressure-eviction/)
* 由于节点的 CPU、内存、磁盘空间和文件系统的 inode 等资源达到特定的消耗水平， kubelet 主动终止 Pod 以回收节点上资源的过程。

### 软驱逐
* 将驱逐条件与管理员所必须指定的宽限期配对。 在超过宽限期之前，kubelet 不会驱逐 Pod。 如果没有指定的宽限期，kubelet 会在启动时返回错误。
* 驱逐条件(如果驱逐条件持续时长超过指定的宽限期，可以触发 Pod 驱逐)：eviction-soft: memory.available<1.5Gi
* 驱逐宽限期(定义软驱逐条件在触发 Pod 驱逐之前必须保持多长时间)：eviction-soft-grace-period: memory.available=1m30s

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
