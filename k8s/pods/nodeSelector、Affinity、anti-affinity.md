* https://kubernetes.io/zh-cn/docs/concepts/scheduling-eviction/assign-pod-node
* https://kubernetes.io/zh-cn/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/

# 通过nodeSelector指定node label调度pod
```
# 为node附加lable标签
kubectl label nodes k8s-node1 disk=ssd
# 查看node标签
kubectl get nodes --show-labels
# 删除node标签
kubectl label nodes k8s-node1 disk-
```

* 在pod配置中加nodeSelector
```yml
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


# Node亲和性/反亲和性
* 节点亲和性概念上类似于 nodeSelector， 它使你可以根据节点上的标签来约束 Pod 可以调度到哪些节点上。 节点亲和性有两种:
  - requiredDuringSchedulingIgnoredDuringExecution： 调度器只有在规则被满足的时候才能执行调度。此功能类似于 nodeSelector， 但其语法表达能力更强。
  - preferredDuringSchedulingIgnoredDuringExecution： 调度器会尝试寻找满足对应规则的节点。如果找不到匹配的节点，调度器仍然会调度该 Pod。
  - IgnoredDuringExecution 意味着如果节点标签在 Kubernetes 调度 Pod 后发生了变更，Pod 仍将继续运行
* 如果你同时指定了 nodeSelector 和 nodeAffinity，两者 必须都要满足，才能将 Pod 调度到候选节点上。

```yml
apiVersion: v1
kind: Pod
metadata:
  name: with-node-affinity
spec:
  affinity:
    nodeAffinity:
      #节点必须包含一个键名为 topology.kubernetes.io/zone 的标签， 并且该标签的取值必须为 antarctica-east1 或 antarctica-west1
      requiredDuringSchedulingIgnoredDuringExecution:   
        nodeSelectorTerms:    #如果你在与 nodeAffinity 类型关联的 nodeSelectorTerms 中指定多个条件， 只要其中一个 nodeSelectorTerms 满足（各个条件按逻辑或or操作组合）的话，Pod 就可以被调度到节点上
        - matchExpressions:   #如果你在与 nodeSelectorTerms 中的条件相关联的单个 matchExpressions 字段中指定多个表达式， 则只有当所有表达式都满足（各表达式按逻辑与操作组合）时，Pod 才能被调度到节点上
          - key: topology.kubernetes.io/zone   
            operator: In  #可用操作符：In、NotIn、Exists、DoesNotExist、Gt 和 Lt，(NotIn 和 DoesNotExist 可用来实现节点反亲和性行为)
            values:
            - antarctica-east1
            - antarctica-west1
      #节点最好具有一个键名为 another-node-label-key 且取值为 another-node-label-value 的标签
      preferredDuringSchedulingIgnoredDuringExecution:   
      - weight: 1
        preference:     
          matchExpressions:     
          - key: another-node-label-key
            operator: In   
            values:
            - another-node-label-value
  containers:
  - name: with-node-affinity
    image: registry.k8s.io/pause:2.0
```

# 亲和性权重
>可以为 preferredDuringSchedulingIgnoredDuringExecution 亲和性类型的每个实例设置 weight 字段，其取值范围是 1 到 100，用于指定规则的优先级。
```yml
apiVersion: v1
kind: Pod
metadata:
  name: with-affinity-anti-affinity
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/os
            operator: In
            values:
            - linux
      preferredDuringSchedulingIgnoredDuringExecution:
      # 如果存在两个候选节点，都满足 preferredDuringSchedulingIgnoredDuringExecution 规则,其中一个节点具有标签 label-1:key-1，另一个节点具有标签 label-2:key-2。调度器会考察各个节点的 weight 取值之和，并添加到节点的其他得分值之上,总分最高的节点的优先被调度使用。
      - weight: 1   
        preference:
          matchExpressions:
          - key: label-1
            operator: In
            values:
            - key-1
      - weight: 50
        preference:
          matchExpressions:
          - key: label-2
            operator: In
            values:
            - key-2
  containers:
  - name: with-node-affinity
    image: registry.k8s.io/pause:2.0
```

# pod间亲和性/反亲和性
>Pod 间亲和性/反亲和性 使你可以基于已经在节点上运行的 Pod 的标签来约束 新来的Pod 可以调度到的节点，而不是基于节点上的标签。
* Pod 间亲和性/反亲和性都需要相当的计算量，因此会在大规模集群中显著降低调度速度。 我们不建议在包含数百个节点的集群中使用这类设置
* Pod 反亲和性需要节点上存在一致性的标签。换言之， 集群中每个节点都必须拥有与 topologyKey 匹配的标签。 如果某些或者所有节点上不存在所指定的 topologyKey 标签，调度行为可能与预期的不同。
* Pod 的亲和性与反亲和性也有两种类型：
  - requiredDuringSchedulingIgnoredDuringExecution
  - preferredDuringSchedulingIgnoredDuringExecution
```yml
apiVersion: v1
kind: Pod
metadata:
  name: with-pod-affinity
spec:
  affinity:
    podAffinity:  #pod亲和性
      #仅当节点和至少一个已运行且有 security=S1 的标签的 Pod 处于同一区域时，才可以将该 Pod 调度到节点上。更确切的说，调度器必须将 Pod 调度到具有 topology.kubernetes.io/zone 标签的节点上，并且集群中至少有一个位于该可用区的节点上运行着带有 security=S1 标签的 Pod。
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: security
            operator: In
            values:
            - S1
        topologyKey: topology.kubernetes.io/zone  #对于 Pod 亲和性而言，在 requiredDuringSchedulingIgnoredDuringExecution 和 preferredDuringSchedulingIgnoredDuringExecution 中，topologyKey 不允许为空
    podAntiAffinity:   #pod反亲和性
      #如果节点处于 Pod 所在的同一可用区且至少一个 Pod 具有 security=S2 标签，则该 Pod 不应被调度到该节点上
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:       
            - key: security
              operator: In
              values:
              - S2
          topologyKey: topology.kubernetes.io/zone
  containers:
  - name: with-pod-affinity
    image: registry.k8s.io/pause:2.0
```

# 实用案例
> 以一个三节点的集群为例。你使用该集群运行一个带有Redis的 Web 应用程序。 在此例中，还假设 Web 应用程序和Redis之间的延迟应尽可能低。 你可以使用 Pod 间的亲和性和反亲和性来尽可能地将该 Web 服务器与redis并置
* Redis 缓存 Deployment 示例, 设置了标签 app=store:
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-cache
spec:
  selector:
    matchLabels:
      app: store
  replicas: 3
  template:
    metadata:
      labels:
        app: store
    spec:
      affinity:
        podAntiAffinity:  #podAntiAffinity 规则告诉调度器避免将多个带有 app=store 标签的副本部署到同一节点上。 因此，每个独立节点上会创建一个缓存实例。
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - store
            topologyKey: "kubernetes.io/hostname"   #对于 requiredDuringSchedulingIgnoredDuringExecution 要求的 Pod 反亲和性， 准入控制器 LimitPodHardAntiAffinityTopology 要求 topologyKey 只能是 kubernetes.io/hostname。如果你希望使用其他定制拓扑逻辑， 你可以更改准入控制器或者禁用之。
      containers:
      - name: redis-server
        image: redis:3.2-alpine
```
* Web 服务器Deployment示例,设置了标签 app=web-store
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-server
spec:
  selector:
    matchLabels:
      app: web-store
  replicas: 3
  template:
    metadata:
      labels:
        app: web-store
    spec:
      affinity:
        podAntiAffinity:  #Pod 反亲和性规则告诉调度器决不要在单个节点上放置多个 app=web-store 服务器
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - web-store
            topologyKey: "kubernetes.io/hostname"
        podAffinity:    #Pod 亲和性规则告诉调度器将每个副本放到存在标签为 app=store 的 Pod 的节点上
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - store
            topologyKey: "kubernetes.io/hostname"
      containers:
      - name: web-app
        image: nginx:1.16-alpine
```
