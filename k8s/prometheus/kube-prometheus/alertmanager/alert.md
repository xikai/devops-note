# 告警规则
* https://awesome-prometheus-alerts.grep.to/rules
* https://github.com/samber/awesome-prometheus-alerts/blob/master/_data/rules.yml
* https://help.aliyun.com/document_detail/176180.html
* zookeeper: https://github.com/apache/zookeeper/blob/master/zookeeper-docs/src/main/resources/markdown/zookeeperMonitor.md


# 告警说明
* https://access.redhat.com/documentation/zh-cn/openshift_container_platform/4.7/html-single/release_notes/index#ocp-4-7-monitoring
* 常用指标：https://cloud.tencent.com/developer/article/1667912

* CPUThrottlingHigh
```
# 关于 CPU 的 limit 合理性指标。查出最近5分钟，超过25%的CPU执行周期受到限制的容器
# 原因：容器cpu limit值设置太小，容器运行时cpu总是超过limit阈值
# 解决：调大容器 cpu limit值
sum by(container, pod, namespace) (increase(container_cpu_cfs_throttled_periods_total{container!=""}[5m])) / sum by(container, pod, namespace) (increase(container_cpu_cfs_periods_total[5m])) > (25 / 100)
```
```
container_cpu_cfs_periods_total：container生命周期中度过的cpu周期总数
container_cpu_cfs_throttled_periods_total：container生命周期中度过的受限的cpu周期总数
```

* KubeCPUOvercommit
>集群 CPU 过度使用。CPU 已经过度使用无法容忍节点故障，节点资源使用的总量超过节点的 CPU 总量，所以如果有节点故障将影响集群资源运行因为所需资源将无法被分配。
```
sum(namespace:kube_pod_container_resource_requests_cpu_cores:sum{}) /
sum(kube_node_status_allocatable_cpu_cores) >
(count(kube_node_status_allocatable_cpu_cores)-1) / count(kube_node_status_allocatable_cpu_cores)
```

* AlertmanagerFailedToSendAlerts
  - 最近5分钟，有 Alertmanager 实例都无法发送警报通知

* AlertmanagerClusterFailedToSendAlerts
  - 最近5分钟，如果集群中的所有 Alertmanager 实例都无法发送警报通知
```
# 原因：超过钉钉/微信单条消息最大长度限制等原因，导致发送失败
# 解决：静默或删除积堆告警，重启alertmanager
```