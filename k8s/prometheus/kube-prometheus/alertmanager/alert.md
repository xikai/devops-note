* CPUThrottlingHigh
```
# 查出最近5分钟，超过25%的CPU执行周期受到限制的container
sum by(container, pod, namespace) (increase(container_cpu_cfs_throttled_periods_total{container!=""}[5m])) / sum by(container, pod, namespace) (increase(container_cpu_cfs_periods_total[5m])) > (25 / 100)
```
```
container_cpu_cfs_periods_total：container生命周期中度过的cpu周期总数
container_cpu_cfs_throttled_periods_total：container生命周期中度过的受限的cpu周期总数
```

# 告警规则
* https://awesome-prometheus-alerts.grep.to/rules