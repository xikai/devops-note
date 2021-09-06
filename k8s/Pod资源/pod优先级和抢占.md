# [pod-priority-preemption](https://kubernetes.io/zh/docs/concepts/scheduling-eviction/pod-priority-preemption/)
### priorityClass
```yml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000000        #值越大，优先级越高
globalDefault: false    #PriorityClass 的value用于没有 priorityClassName 的 Pod。
                        #系统中只能存在一个 globalDefault为 true 的 PriorityClass,默认所有新调度的容器都将应用此PriorityClass
                        #如果没有任何globalDefault为 true 的PriorityClass 存在, 则没有 priorityClassName 的 Pod 的优先级为0
description: "此优先级类应仅用于 XYZ 服务 Pod"
```
### Pod 优先级
```yml
apiVersion: v1
kind: Pod
metadata:
 name: nginx
spec:
 containers:
 - name: nginx
   image: nginx
   imagePullPolicy: IfNotPresent
 priorityClassName: high-priority   #优先级准入控制器使用 priorityClassName 字段并填充优先级的整数值。 如果未找到所指定的优先级类，则拒绝 Pod。
```

### Pod优先级 和现有集群
* 升级一个已经存在的但尚未使用此特性的集群，该集群中已经存在的 Pod 的优先级等效于零。
* 添加一个将 globalDefault 设置为 true 的 PriorityClass 不会改变现有 Pod 的优先级。 此类 PriorityClass 的值仅用于添加 PriorityClass 后创建的 Pod。
* 如果你删除了某个 PriorityClass 对象，则使用被删除的 PriorityClass 名称的现有 Pod 保持不变。


### 非抢占式PriorityClass
```yml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority-nonpreempting
value: 1000000
preemptionPolicy: Never   #等待调度的非抢占式 Pod 将留在调度队列中，直到有足够的可用资源，才可以被调度。非抢占式 Pod不能抢占其他 Pod，但仍可能被其他高优先级 Pod 抢占。
globalDefault: false
description: "This priority class will not cause other pods to be preempted."
```

### 抢占
* Pod 被创建后会进入队列等待调度(pending)。并尝试将它调度到某个节点上。如果没有找到满足 Pod 的所指定的所有要求的节点，则触发对抢占逻辑。
* 抢占逻辑试图找到一个节点， 在该节点中删除一个或多个优先级低于 被调度的 Pod，则可以将其调度到该节点上。
* 调度器按优先级对pending的pod排序，先调度优先级高的pod。如果无法调度此类 Pod，调度程序将继续尝试调度其他较低优先级的 Pod。
* 被抢占而牺牲的pod 会优雅终止。如果在此期间有另一个节点变得可用，则调度程序会使用另一个节点调度。
