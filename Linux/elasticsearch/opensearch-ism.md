# opensearch索引状态管理
* https://opensearch.org/docs/latest/im-plugin/ism/index/
>策略(policy)定义了索引可以处于的状态(state)、处于状态时要执行的操作(action)，以及在状态之间转换(transition)必须满足的条件。

# Amazon OpenSearch Service (ISM)
* https://docs.aws.amazon.com/zh_cn/opensearch-service/latest/developerguide/ism.html

# [使用 Index State Management (ISM) 来管理 Amazon OpenSearch Service 存储空间不足问题](https://aws.amazon.com/cn/premiumsupport/knowledge-center/opensearch-low-storage-ism/)
* [创建ISM策略 (删除age大于7天的索引)](https://opensearch.org/docs/latest/im-plugin/ism/policies/)
>在 OpenSearch 控制面板中，选择 Index Management（索引管理）选项卡，然后为 rollover 操作创建一个 ISM 策略. (Index Management -> Policy managed indices)
```json
curl -XPOST -H 'Content-Type: application/json' http://$IP:9200/_plugins/_ism/add/del-index-7d -d '
{
  "policy": {
    "description": "Delete index that are age than 7 days",
    "schema_version": 1,
    "default_state": "hot",
    "states": [
      {
        "name": "hot",
        "actions": [],
        "transitions": [
          {
            "state_name": "delete",
            "conditions": {
              "min_index_age": "7d"
            }
          }
        ]
      },
      {
        "name": "delete",
        "actions": [
          {
            "delete": {}
          }
        ],
        "transitions": []
      }
    ],
    "ism_template": { //在策略中设置 ism_template 字段，当您创建与模板模式匹配的索引时，策略会自动附加到该索引。在此示例中，以 "log" 开头的名称创建的任何索引都会自动匹配 ISM 策略 
      "index_patterns": ["log*"],
      "priority": 100   //值越高，优先级越高
    }
  }
}'
```

* 将策略附加到索引
要将 ISM 策略附加到索引，请执行以下步骤：
1. 从 OpenSearch Service 控制台打开 OpenSearch 控制面板。
2. 选择 Index Management（索引管理）选项卡。
3. 选择要将 ISM 策略附加到的索引（例如："test-index-000001"）。
4. 选择 Apply policy（应用策略）。
5. （可选）如果您的策略指定了需要别名的任何操作，请提供别名，然后选择 Apply（应用）。您的索引在 Managed Indices（管理索引）列表下显示。

# [创索引索模板](https://opensearch.org/docs/1.2/opensearch/index-templates/)
>_index_template用于设置索引属性
```json
curl -XPOST -H 'Content-Type: application/json' http://$IP:9200/_index_template/shards-2 -d '
{
  "index_patterns": [
    "log*"
  ],
  "priority": 100, //值越高，优先级越高
  "template": {
    "aliases": { //为匹配的index设置alias
      "my_logs": {}
    },
    "settings": {
      "number_of_shards": 2,
      "number_of_replicas": 1
    }
  }
}'
```

* 查看索引模板
```
curl "http://log.vevor-inner.com/_index_template/index-shards-2?pretty"
```

* 删除索引模板
```
curl -XDELETE http://$IP:9200/_index_template/shards-2
```

* 列出所有索引模板
```
curl "http://log.vevor-inner.com/_cat/templates"
```