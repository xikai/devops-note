* https://www.kancloud.cn/pshizhsysu/prometheus/1869390
* https://blog.csdn.net/liangkiller/article/details/105758857
* https://www.modb.pro/db/50726

# Target的初始Label
* 示例配置
```
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
```
* prometheus -> status -> targets
```
Endpoint: 
 http://localhost:9090/metrics
Labels: 
 instance="localhost:9090"
 job="prometheus"
```
* Prometheus 加载 Targets 后，这些 Targets 会自动包含一些默认的标签，Target 以 __ 作为前置的标签是在系统内部使用的，这些标签不会被写入到样本数据中。
* 默认每次增加 Target 时会自动增加一个 instance 标签，而 instance 标签的内容刚好对应 Target 实例的 __address__ 值，这是因为实际上 Prometheus 内部做了一次标签重写处理
* 对于静态配置的Target，最开始的时候，Target固定会有这几个标签：
  ```
  job：对应配置里面job_name
  __address__：当前Target实例的访问地址<host>:<port>
  __scheme__：采集目标服务访问地址的HTTP Scheme，HTTP或者HTTPS
  __metrics_path__：采集目标服务访问地址的访问路径
  __param_<name>：采集任务目标服务的中包含的请求参数
  ```


# 服务发现的Target
>可以从promtheus -> Status -> Service Discovery页面看到初始标签（Discoverd Labels）及最后的标签（Target Labels）
* https://prometheus.io/docs/prometheus/latest/configuration/configuration/#kubernetes_sd_config
```
公共配置中的job、__address__、__scheme__、__metrics_path__ 这些标签依然存在
__meta_：在重新标记阶段可以使用以 _meta_ 为前缀的附加标签。它们由提供目标的服务发现机制设置的
```

# [relabel_configs](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#relabel_config)
* relabel_configs，在拉取(scraping)前,修改target和它的labels
* 每个Target可以配置多个Relabel动作，按照配置文件顺序应用
* 目标重新标签之后，以__开头的标签将从标签集中删除的
```
 [ source_labels: '[' <labelname> [, ...] ']' ]
 [ separator: <string> | default = ; ]
 [ target_label: <labelname> ]
 [ regex: <regex> | default = (.*) ]
 [ modulus: <uint64> ]
 [ replacement: <string> | default = $1 ]
 [ action: <relabel_action> | default = replace ]
```
```
• replace：根据 regex 的配置匹配 source_labels 标签的值（注意：多个 source_label 的值会按照 separator 进行拼接），并且将匹配到的值写入到 target_label 中，并在prometheus的Target Labels中展示。
           如果有多个匹配组，则可以使用 ${1}, ${2} 确定写入的内容。如果没匹配到任何内容则不对 target_label 进行替换， 默认为 replace。
• keep：丢弃 source_labels 的值中没有匹配到 regex 正则表达式内容的 Target 实例
• drop：丢弃 source_labels 的值中匹配到 regex 正则表达式内容的 Target 实例
• hashmod：将 target_label 设置为关联的 source_label 的哈希模块
• labelmap：根据 regex 去匹配 Target 实例所有标签的名称（注意是名称），并且将捕获到的内容作为为新的标签名称，regex 匹配到标签的的值作为新标签的值。
• labeldrop：对 Target 标签进行过滤，会移除匹配过滤条件的所有标签
• labelkeep：对 Target 标签进行过滤，会移除不匹配过滤条件的所有标签
```


# 示例
### 默认初始标签
```yml
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
```
* curl 'http://localhost:9090/api/v1/targets?state=active'
```
{
	"status": "success",
	"data": {
		"activeTargets": [{
			"discoveredLabels": { // 这块只能作为源标签
				"__address__": "localhost:9090",
				"__metrics_path__": "/metrics",
				"__scheme__": "http",
				"job": "prometheus"
			},
			"labels": { // relabel后的初始标签
				"instance": "localhost:9090",
				"job": "prometheus"
			},
			"scrapePool": "prometheus",
			"scrapeUrl": "http://localhost:9090/metrics",
			"lastError": "",
			"lastScrape": "2020-04-25T08:42:19.254191755-04:00",
			"lastScrapeDuration": 0.012091634,
			"health": "up"
		}],
		"droppedTargets": []
	}
}
```
### 添加自定义标签
```
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
        labels: 
          userLabel1: value1
          userLabel2: value2
```
* curl 'http://localhost:9090/api/v1/targets?state=active'
```
{
	"status": "success",
	"data": {
		"activeTargets": [{
			"discoveredLabels": {
				"__address__": "localhost:9090",
				"__metrics_path__": "/metrics",
				"__scheme__": "http",
				"job": "prometheus",
				"userLabel1": "value1", //新增
				"userLabel2": "value2"  //新增
			},
			"labels": {
				"instance": "localhost:9090",
				"job": "prometheus",
				"userLabel1": "value1",  //新增
				"userLabel2": "value2"  //新增
			},
            ...
		}],
		"droppedTargets": []
	}
}
```
### replace 替换标签的值
```
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
        labels: 
          userLabel1: value1
          userLabel2: value2
    relabel_configs:
    # 用source_labels: [userLabel1] 的值，替换 target_label: userLabel2的值
    - source_labels: [userLabel1] 
      target_label:  userLabel2  
      #默认action 是 'replace'
```
* curl 'http://localhost:9090/api/v1/targets?state=active'
```
			"discoveredLabels": {
				"__address__": "localhost:9090",
				"__metrics_path__": "/metrics",
				"__scheme__": "http",
				"job": "prometheus",
				"userLabel1": "value1", //不变
				"userLabel2": "value2"  //不变
			},
			"labels": {
				"instance": "localhost:9090",
				"job": "prometheus",
				"userLabel1": "value1",
				"userLabel2": "value1"  //用userLabel1的值替换了userLabel2
			},
```
* replacement ,用userLabel1的部分值替换userLabel2
```
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
        labels: 
          userLabel1: value1
          userLabel2: value2
    relabel_configs:
    - source_labels: [userLabel1]
      regex: 'value([0-9]+)'
      target_label:  userLabel2
      replacement: '$1'
      action: replace
```
* curl 'http://localhost:9090/api/v1/targets?state=active'
```
			"labels": {
				"instance": "localhost:9090",
				"job": "prometheus",
				"userLabel1": "value1",
				"userLabel2": "1"
			},
```

### labelmap 取匹配的标签名的一部分生成新标签
```
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
        labels: 
          userLabel1: value1
          userLabel2: value2
    relabel_configs:
    - action: labelmap
	  regex: user(.*)1
      
```
* curl 'http://localhost:9090/api/v1/targets?state=active'
```
			"labels": {
				"instance": "localhost:9090",
				"job": "prometheus",
				"userLabel1": "value1",
				"userLabel2": "value2",
				"Label": "value1" //新生成的标签
			},
```

### labeldrop/labelkeep 删除匹配/不匹配regex条件的标签
```
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
        labels: 
          userLabel1: value1
          userLabel2: value2
    relabel_configs:
    - raction: labeldrop
	  regex: userLabel1
      
```
* curl 'http://localhost:9090/api/v1/targets?state=active'
```
{
	"status": "success",
	"data": {
		"activeTargets": [{
			"discoveredLabels": { //这部分只能做为源标签
				"__address__": "localhost:9090",
				"__metrics_path__": "/metrics",
				"__scheme__": "http",
				"job": "prometheus",
				"userLabel1": "value1",
				"userLabel2": "value2"
			},
			"labels": {
				"instance": "localhost:9090",
				"job": "prometheus",
				"userLabel2": "value2" //删除了userLabel1
			},
            ...
	}
}
```

### drop/keep 删除匹配/不匹配regex条件的target
```
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
        abels: 
           userLabel1: value1
    relabel_configs:
    - source_labels: [userLabel1]
	  regex: userLabel1 
      action: drop
```
* curl 'http://localhost:9090/api/v1/targets?state=active'
```
{
	"status": "success",
	"data": {
		"activeTargets": [],
		"droppedTargets": []
	}
}
```