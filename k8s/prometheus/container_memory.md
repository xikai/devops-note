* [Pod命令如何计算内存使用量](https://help.aliyun.com/document_detail/413870.html)
* https://www.orchome.com/6745#item-1-1
```
执行kubectl top pod命令得到的结果，并不是容器服务中container_memory_usage_bytes指标的内存使用量，而是指标container_memory_working_set_bytes的内存使用量，计算方式如下：
container_memory_usage_bytes = container_memory_rss + container_memory_cache + kernel memory
container_memory_working_set_bytes = container_memory_usage_bytes - total_inactive_file（未激活的匿名缓存页）
container_memory_working_set_bytes是容器真实使用的内存量，也是资源限制limit时的重启判断依据