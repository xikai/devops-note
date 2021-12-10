### 实现hpa的条件
1. 安装metrics-server (https://github.com/kubernetes-sigs/metrics-server)
   ```
   kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
   ```
2. 要实现autoscale，pod必须设置request
3. hpa不能autoscale daemonset类型control

### hpa工作机制
* horizontal-pod-autoscaler(控制器) -> RC/Depolyment(scale) -> pod1 ... pod N
* --horizontal-pod-autoscaler-sync-period 参数指定周期（默认值为 15 秒）对指定的指标查询资源利用率

* Pod 水平自动扩缩控制器根据当前指标和期望指标来计算扩缩比例,
  ```
  期望副本数 = ceil[当前副本数 * (当前指标 / 期望指标)] 
  ```
  * 如果计算出的扩缩比例接近1.0 将会放弃本次扩缩。--horizontal-pod-autoscaler-tolerance默认为 0.1
  * 正在关闭过程中的 Pod 和失败的 Pod 都会被忽略，不计入副本数。
  * 排除掉被搁置的 Pod,不计入副本数。
    * --horizontal-pod-autoscaler-initial-readiness-delay 参数（默认为 30s）用于设置 Pod 准备时间， 在此时间内的 Pod 统统被认为未就绪
    * --horizontal-pod-autoscaler-cpu-initialization-period 参数（默认为5分钟） 用于设置 Pod 的初始化时间， 在此时间内的 Pod，CPU 资源度量值将不会被采纳

* 在当前稳定版本（autoscaling/v1）中只支持基于 CPU 指标的扩缩。API 的 beta 版本（autoscaling/v2beta2）引入了基于内存和自定义指标的扩缩。
  https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#horizontalpodautoscaler-v1-autoscaling

* 如果指定了多个类型的度量指标，HPA 将会依次考量各个指标。 HPA 将会计算每一个指标所提议的副本数量，然后最终选择一个最高值

* 因为指标动态的变化会造成副本数量频繁的变化 抖动（Thrashing）。在 HPA 控制器执行扩缩操作之前，会记录扩缩建议信息，控制器会在操作时间窗口中考虑所有的建议信息，并从中选择得分最高的建议。
  * --horizontal-pod-autoscaler-downscale-stabilization 设置缩容冷却时间 默认值是 5 分钟（5m0s）并仅对此时间窗口内的最大规模执行操作。


### kubectl autoscale创建 HPA 对象
```
#为名 为 php-apache 的 deployment 创建一个 HPA 对象， 目标 CPU 使用率为 80%，副本数量配置为 2 到 5 之间
kubectl autoscale deployment php-apache --min=2 --max=5 --cpu-percent=80 
```

### 资源指标
* 定义一个资源指标
```yml
# HPA 控制器会维持扩缩目标中的 Pods 的平均资源利用率在 60%。 利用率是 Pod 的当前资源用量与其请求值之间的比值
type: Resource
resource:
  name: cpu
  target:
    type: Utilization
    averageUtilization: 60
```
* 定义一个容器指标
```yml
# HPA 控制器会对目标对象执行扩缩操作以确保所有 Pods 中 application 容器的平均 CPU 用量为 60%
type: ContainerResource
containerResource:
  name: cpu
  container: application
  target:
    type: Utilization
    averageUtilization: 60
```

### 自定义度量指标（custom metrics）
* Pod 度量指标，确保每秒能够服务 1000 个数据包请求
```yml
type: Pods
pods:
  metric:
    name: packets-per-second
  target:
    type: AverageValue  #平均值 将按pod数据拆分后 与API返回的度量指标比较
    averageValue: 1k
```
* 对象（Object）度量指标，确保所有在 Ingress 后的 Pod 每秒能够服务的请求总数达到 10000 个
```yml
type: Object
object:
  metric:
    name: requests-per-second
  describedObject:
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    name: main-route
  target:
    type: Value     #数据值 直接与API返回的度量指标比较
    value: 10k
```

### 外部度量指标（external metrics）
* 外部度量指标使得你可以使用你的监控系统的任何指标来自动扩缩你的集群
```yml
# 应用程序处理来自主机上消息队列的任务， 确保让每 30 个任务有 1 个工作者实例
- type: External
  external:
    metric:
      name: queue_messages_ready
      selector: "queue=worker_tasks"
    target:
      type: AverageValue
      averageValue: 30
```

### 扩缩策略
* 从 v1.18 开始，v2beta2 API 允许通过 HPA 的 behavior 字段配置扩缩行为
* scaleUp 和 scaleDown指定扩缩策略可以控制扩缩时副本数的变化率，以防止扩缩目标中副本数量的波动。
```yml
# periodSeconds 表示在过去的多长时间内要求策略值为真。 第一个策略（Pods）允许在一分钟内最多缩容 4 个副本。第二个策略（Percent） 允许在一分钟内最多缩容当前副本个数的百分之十。
# 由于默认情况下会选择容许更大程度作出变更的策略，只有 Pod 副本数大于 40 时， 第二个策略才会被采用, 在 autoscaler 控制器的每个循环中，将根据当前副本的数量重新计算要更改的 Pod 数量
behavior:
  scaleDown:
    policies:
    - type: Pods
      value: 4
      periodSeconds: 60
    - type: Percent
      value: 10
      periodSeconds: 60
```
```yml
behavior:
  scaleDown:
    stabilizationWindowSeconds: 300   #稳定窗口的时间为 300 秒，考虑5分钟内所有期望状态 并使用指定时间间隔内的最大值
    policies:                         #每15秒，允许 100% 删除当前运行的副本
    - type: Percent                  
      value: 100                     
      periodSeconds: 15
  scaleUp:             
    stabilizationWindowSeconds: 0   #稳定窗口的时间为 0 秒 ,立即扩容。
    policies:                       # 每 15 秒添加 4 个 Pod 或 100% 当前运行的副本数，直到 HPA 达到稳定状态
    - type: Percent
      value: 100
      periodSeconds: 15
    - type: Pods
      value: 4
      periodSeconds: 15
    selectPolicy: Max   #会选择扩容 Pod 数量最大的策略
```
* 禁用缩容
```yml
behavior:
  scaleDown:
    selectPolicy: Disabled
```

### 多个类型度量指标的hpa资源
```yml
apiVersion: autoscaling/v2beta1
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: AverageUtilization
        averageUtilization: 50
  - type: Pods
    pods:
      metric:
        name: packets-per-second
      target:
        type: AverageValue
        averageValue: 1k
  - type: Object
    object:
      metric:
        name: requests-per-second
      describedObject:
        apiVersion: networking.k8s.io/v1beta1
        kind: Ingress
        name: main-route
      target:
        kind: Value
        value: 10k
```