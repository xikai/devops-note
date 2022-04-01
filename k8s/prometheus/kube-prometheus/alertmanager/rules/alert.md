# 告警规则
* https://awesome-prometheus-alerts.grep.to/rules
* zookeeper: https://github.com/apache/zookeeper/blob/master/zookeeper-docs/src/main/resources/markdown/zookeeperMonitor.md


# 告警说明
* https://access.redhat.com/documentation/zh-cn/openshift_container_platform/4.7/html-single/release_notes/index#ocp-4-7-monitoring

* CPUThrottlingHigh
```
# 查出最近5分钟，超过25%的CPU执行周期受到限制的container
# 原因：容器cpu limit值设置太小，容器运行时cpu总是超过limit阈值
# 解决：调大容器 cpu limit值
sum by(container, pod, namespace) (increase(container_cpu_cfs_throttled_periods_total{container!=""}[5m])) / sum by(container, pod, namespace) (increase(container_cpu_cfs_periods_total[5m])) > (25 / 100)
```
```
container_cpu_cfs_periods_total：container生命周期中度过的cpu周期总数
container_cpu_cfs_throttled_periods_total：container生命周期中度过的受限的cpu周期总数
```

* AlertmanagerFailedToSendAlerts
  - 最近5分钟，有 Alertmanager 实例都无法发送警报通知

* AlertmanagerClusterFailedToSendAlerts
  - 最近5分钟，如果集群中的所有 Alertmanager 实例都无法发送警报通知
```
# 原因：超过钉钉/微信单条消息最大长度限制等原因，导致发送失败
# 解决：静默或删除积堆告警，重启alertmanager
```