* https://www.cnblogs.com/zhaojiedi1992/p/zhaojiedi_liunx_61_prometheus_relabel.html
* https://www.jianshu.com/p/c21d399c140a

### relabel_config
* Relabel用来重写target的标签
* 每个Target可以配置多个Relabel动作，按照配置文件顺序应用
* 目标重新标签之后，以__开头的标签将从标签集中删除的

### relabel的action类型
- replace 对标签和标签值进行替换
```
  - job_name: "node"
    file_sd_configs:
    - refresh_interval: 1m
      files:
      - "/usr/local/prometheus/prometheus/conf/node*.yml"
    relabel_configs:
    - source_labels:       #指定我们我们需要处理的源标签
      - "__hostname__"
      regex: "(.*)"        #regex去匹配源标签（__hostname__）的值，"(.*)"代表__hostname__这个标签是什么值都匹配的
      target_label: "nodename"  #指定了我们要replace后的标签名字
      action: replace      #指定relabel动作
      replacement: "$1"   #指定的替换后的标签（target_label）对应的数值
```
```
# 基础信息里面有__region_id__和__availability_zone__，但是我想融合2个字段在一起，可以通过replace来实现 //region_zone="cn-beijing-a"
  - job_name: "node"
    file_sd_configs:
    - refresh_interval: 1m
      files:
      - "/usr/local/prometheus/prometheus/conf/node*.yml"
    relabel_configs:
    - source_labels:
      - "__region_id__"
      - "__availability_zone__"
      separator: "-"
      regex: "(.*)"
      target_label: "region_zone"
      action: replace
      replacement: "$1"
```

- keep: 满足特定条件的实例进行采集，其他的不采集
>只要source_labels的值匹配regex（node00）的实例才能会被采集。 其他的实例不会被采集。
```
  - job_name: "node"
    file_sd_configs:
    - refresh_interval: 1m
      files: 
      - "/usr/local/prometheus/prometheus/conf/node*.yml"
    relabel_configs:
    - source_labels:
      - "__hostname__"
      regex: "node00"
      action: keep  
```
- drop： 满足特定条件的实例不采集，其他的采集
>与keep相反

- labeldrop： 对抓取的实例特定标签进行删除。
- labelkeep：  对抓取的实例特定标签进行保留，其他标签删除。