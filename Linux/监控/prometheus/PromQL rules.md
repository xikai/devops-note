### prometheus之记录规则(recording rules)与告警规则(alerting rule)
 - Prometheus 可以配置rules，然后定时查询数据。rules规则是我们预先定义的一组来完成复杂工作的表达式的合集。规则以 YAML 格式书写。通过PromQL可以实时对Prometheus中采集到的样本数据进行查询，聚合以及其它各种运算操作。
   - **Recording rules:** 对采集的metric做计算或聚合，生成新的metric。记录规则允许我们预先计算经常使用或计算成本高的表达式，并将其结果保存为一组新的时间序列。因此，查询预先计算的结果通常比每次需要时执行原始表达式快得多
   - **Alerting rules：** 通过表达式定义报警规则

* 在Prometheus配置文件中，通过rule_files定义recoding rule规则文件的访问路径。
```
rule_files:
  [ - <filepath_glob> ... ]
```

* 安装promtool检测规则文件语法
```bash
go get github.com/prometheus/prometheus/cmd/promtool
promtool check rules /path/to/example.rules.yml
```

* 聚合scrape数据到新的时间序列
>假设我们有兴趣记录所有实例（但保留作业和服务维度）在 5 分钟窗口内测量的实例 RPC （rpc_durations_seconds_count） 的每秒速率
```
avg(rate(rpc_durations_seconds_count[5m])) by (job, service)
```

* 记录规则示例：
>vim prometheus.rules.yml
```yml
groups:
- name: example
  rules:
  - record: job_service:rpc_durations_seconds_count:avg_rate5m
    expr: avg(rate(rpc_durations_seconds_count[5m])) by (job, service)
```

* 告警规则示例
>vim alerting.rules.yml
```yml
groups:
- name: example
  rules:
  - alert: HighRequestLatency
    expr: job:request_latency_seconds:mean5m{job="myjob"} > 0.5
    for: 10m
    labels:
      severity: page
    annotations:
      summary: High request latency
```