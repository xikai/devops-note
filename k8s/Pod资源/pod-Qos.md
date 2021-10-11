# pod Qos
* Qos优先级：Guaranteed > Burstable > BestEffort
* Guaranteed（最严格，Pod 中的每个容器，包含初始化容器，必须指定内存和CPU的请求和限制，并且两者要相等）
* Burstable（Pod 不符合 Guaranteed QoS 类的情况下，至少一个容器具有内存或 CPU 请求）
* BestEffort（Pod 中的容器必须没有设置内存和 CPU 限制或请求）

# CPU资源（可压缩资源）
* 如果pod中服务使用CPU超过设置的 limits，pod不会被kill掉但会被限制。如果没有设置limits，pod可以使用全部空闲的cpu资源。

# 内存和磁盘（不可压缩资源）
* 当一个pod使用内存超过了设置的 limits，pod中 container 的进程会被 kernel 因OOM kill掉。
* 当资源紧俏时，例如OOM，kubelet会根据QoS进行驱逐：
```
Best-Effort，最低优先级，第一个被kill
Burstable，第二个被kill
Guaranteed，最高优先级，最后kill。除非超过limit或者没有其他低优先级的Pod
```

# 使用建议
* 如果资源充足，可以将 pod QoS 设置为 Guaranteed
* 不是很关键的服务 pod QoS 设置为 Burstable 或者 BestEffort。比如 filebeat、logstash、fluentd等