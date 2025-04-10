* https://www.cnblogs.com/panwenbin-logs/p/18396013
* https://www.kancloud.cn/pshizhsysu/prometheus/1869390
* https://blog.csdn.net/liangkiller/article/details/105758857
* https://www.modb.pro/db/50726


# 服务发现的Target
>可以从promtheus -> Status -> Service Discovery页面看到初始标签（Discoverd Labels）及最后的标签（Target Labels）
* https://prometheus.io/docs/prometheus/latest/configuration/configuration/#kubernetes_sd_config
```
prometheus 动态发现目标(targer)之后， 在被发现的 target 实例中， 都包含一些原始的Metadata 标签信息， 默认的标签有：
__address__： 以<host>:<port> 格式显示目标 targets 的地址
__scheme__： 采集的目标服务地址的 Scheme 形式， HTTP 或者 HTTPS
__metrics_path__： 采集的目标服务的访问路径
```


# [relabel_configs](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#relabel_config)
>能够在抓取到目标实例之前把目标实例的元数据标签动态重新修改， 动态添加或者覆盖标签
```
为了更好的识别监控指标,便于后期调用数据绘图、 告警等需求， prometheus 支持对发现的目标进行 label 修改， 在两个阶段可以重新标记：
relabel_configs ： 在对 target 进行数据采集之前（比如在采集数据之前重新定义标签信息， 如目的 IP、目的端口等信息） ， 可以使用 relabel_configs 添加、 修改或删除一些标签、 也可以只采集特定目标或过滤目标。
metric_relabel_configs： 在对 target 进行数据采集之后， 即如果是已经抓取到指标数据时， 可以使用metric_relabel_configs 做最后的重新标记和过滤。流程如下
```
```
配置 - relabel_configs - 抓取 - metric_relabel_configs - TSDB
```

* relabel_configs，在拉取(scraping)前,修改target和它的labels
* 每个Target可以配置多个Relabel动作，按照配置文件顺序应用
* 目标重新标签之后，以__开头的标签将从标签集中删除的
```sh
 [ source_labels: '[' <labelname> [, ...] ']' ]  	#源标签， 没有经过 relabel 处理之前的标签名字
 [ separator: <string> | default = ; ]
 [ target_label: <labelname> ]   					#通过 action 处理之后的新的标签名字
 [ regex: <regex> | default = (.*) ]   				#给定的值或正则表达式匹配， 匹配源标签
 [ modulus: <uint64> ]
 [ replacement: <string> | default = $1 ]           #通过分组替换后标签（target_label） 对应的值
 [ action: <relabel_action> | default = replace ]   #操作类型， 默认为 replace. 用source_labels的值，替换 target_label的值
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