* https://prometheus.io/docs/prometheus/latest/querying/basics/
* https://www.bookstack.cn/read/prometheus-manual/prometheus-querying-basics.md

# 查询表达式数据类型
* Instant vector（即时向量）：在同一时刻，抓取的所有度量指标数据。这些度量指标数据的key都是相同的，也即相同的时间戳。
* Range vector（范围向量）：在任何一个时间范围内，抓取的所有度量指标数据
* Scalar（标量）：一个简单的浮点值
* String（字符串）：一个当前没有被使用的简单字符串


# metric 指标，Instant vector（即时向量）
* 指标名称不能是关键字bool、on、ignoring、group_left、group_right
```
http_requests_total
```

# label 标签
* label 指标标签(用于过滤样本数据)
```
http_requests_total{job="prometheus",group="canary"}
```
* 标签匹配操作符 ,[regular expressions in Prometheus](https://github.com/google/re2/wiki/Syntax)
```
= 精确地匹配标签给定的值
!= 不等于给定的标签值
=~ 正则表达匹配给定的标签值
!~ 给定的标签值不符合正则表达式
```

* __name__可用于匹配指标名
```
http_requests_total{job="prometheus",group="canary"}
等同于
{__name__=~"http_requests_total",job="prometheus",group="canary"}
```

# Range vector（范围向量）
* 获取<最近5分钟 指标为http_requests_total 标签job的值为prometheus> 的所有样本数据
```
http_requests_total{job="prometheus"}[5m]
```
* 时间单位
```
ms - milliseconds
s - seconds
m - minutes
h - hours
d - days - assuming a day has always 24h
w - weeks - assuming a week has always 7d
y - years - assuming a year has always 365d
```
```
5h
1h30m
5m
10s
```
* offset 时间偏移,允许在查询中改变单个瞬时向量和范围向量中的时间偏移
>offset偏移修饰符必须直接跟在选择器后面
```
# 返回相对于当前时间的前5分钟 http_requests_total的时间序列数据
http_requests_total offset 5m

# 返回相对于当前时间的前一周时，http_requests_total的5分钟内的速率
rate(http_requests_total[5m] offset 1w)
```
* @ 获取指标在指定时间戳的样本数据
```
# 返回http_requests_total 在时间戳为 2021-01-04T07:40:00+00:00的样本数据
http_requests_total @ 1609746000
```

# 操作符
* 运算符
```
+ 加法
- 减法
* 乘法
/ 除法
% 模
^ 幂等
```
* 比较操作符
```
== 等于
!= 不等于
> 大于
< 小于
>= 大于等于
<= 小于等于
```
* 逻辑操作符
```
and 交集
or 并集
unless 补集
```

# 聚合操作符
* 聚合操作符被用于聚合单个即时向量的所有时间序列列表，把聚合的结果值存入到新的向量中
```
sum (求和)
min (最小值)
max (最大值)
avg (平均值)
stddev (标准差)
stdvar (标准方差)
count (计数)
count_values (对value进行计数)
bottomk (后n条时序)
topk (前n条时序)
quantile (分位数)
```
* 通过without或者by子句来保留不同的维度，例如：如果度量指标名称http_requests_total包含由group, application, instance的标签组成的时间序列数据
```
# 我们可以通过以下方式计算去除instance标签的http请求总数
sum without (instance) (http_requests_total)

# 或只保留instance标签的http请求总数
sum by (instance) (http_requests_total)
```
```
instance_cpu_time_ns{app="lion", proc="web", rev="34d0f99", env="prod", job="cluster-manager"}
instance_cpu_time_ns{app="elephant", proc="worker", rev="34d0f99", env="prod", job="cluster-manager"}
instance_cpu_time_ns{app="turtle", proc="api", rev="4d3a513", env="prod", job="cluster-manager"}
instance_cpu_time_ns{app="fox", proc="widget", rev="4d3a513", env="prod", job="cluster-manager"}
...

count by (app) (instance_cpu_time_ns)
topk(3, sum by (app, proc) (rate(instance_cpu_time_ns[5m])))
```

* \<aggregation\>_over_time() 时序范围内的取值
>kube_pod_container_status_waiting_reason{reason="CrashLoopBackOff", job="kube-state-metrics"}[5m]
```
kube_pod_container_status_waiting_reason{container="filebeat", instance="10.20.22.154:8443", job="kube-state-metrics", namespace="logs", pod="filebeat-p9bxc", reason="CrashLoopBackOff", uid="04b1fffe-ecac-435a-8025-58556f6b02d2"}
1 @1672717347.934
1 @1672717377.934
1 @1672717407.934
1 @1672717437.934
1 @1672717467.934
1 @1672717497.934
1 @1672717527.934
1 @1672717557.934
1 @1672717587.934
1 @1672717617.934
```
```
# 取5分钟内所有时序点的最大值
max_over_time(kube_pod_container_status_waiting_reason{reason="CrashLoopBackOff", job="kube-state-metrics"}[5m])   # 返回1

min_over_time(kube_pod_container_status_waiting_reason{reason="CrashLoopBackOff", job="kube-state-metrics"}[5m])   # 返回1
avg_over_time(kube_pod_container_status_waiting_reason{reason="CrashLoopBackOff", job="kube-state-metrics"}[5m])   # 返回1
sum_over_time(kube_pod_container_status_waiting_reason{reason="CrashLoopBackOff", job="kube-state-metrics"}[5m])   # 返回10
```

# [内置函数](https://prometheus.io/docs/prometheus/latest/querying/functions/)
* https://www.bookstack.cn/read/prometheus-manual/prometheus-querying-functions.md
### [rate / irate](https://segmentfault.com/a/1190000040783147)
* rate 计算指定时间范围内数据缓慢变化率
```
取时间范围内的firstValue和lastValue；
变化率 = (lastValue - firstValue) / Range；
```

* irate 计算指定时间范围内数据快速变化率
```
取时间范围内的lastValue和lastBeforeValue = (lastValue - 1)；
变化率 = (lastValue - lastBeforeValue) / Range；
```

* increase() 计算counter类型过去时间的增量
* round()函数进行取整

### [label_replace](https://prometheus.io/docs/prometheus/latest/querying/functions/#label_replace)
>将src_label按照正则表达式切分，然后取其中的一段，作为新的标签加入到指标中
```
label_replace(v instant-vector, dst_label string, replacement string, src_label string, regex string)
```
* 新增host标签内容为instance的ipaddr
```
原始series:  up{instance="localhost:8080",job="cadvisor"} 1
```
```
label_replace(up, "host", "$1", "instance", "(.*):.*")
#对src_label instance正则表达式匹配，如果匹配不到，则无变化，如果匹配到了，那么就将host=$1(正则匹配的第一个串，这里是localhost)加入到label中,在本例中，也就是会增加host=localhost这个标签
```
```
改造后series:  up{host="localhost",instance="localhost:8080",job="cadvisor"} 1
```