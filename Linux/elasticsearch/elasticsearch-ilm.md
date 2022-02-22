# 索引生命周期管理
* https://www.elastic.co/guide/en/elasticsearch/reference/7.16/index-lifecycle-management.html
* https://juejin.cn/post/6844904131262431246


# [创建索引策略](https://www.elastic.co/guide/en/elasticsearch/reference/7.10/set-up-lifecycle-policy.html)
* 当索引进入一个阶段（phase），这个阶段的配置将被缓存在索引元数据中，避免策略更新后被影响
* 如果一个索引有未分配的shards，并且集群健康状态为黄色，那么该索引仍然可以根据其索引生命周期管理策略过渡到下一个阶段。但是Elasticsearch只能在集群green状态时执行某些清理任务。
>可以通过Kibana管理页面设置(Stack Management -> Index Lifecycle Policies)，也可以通过API设置。
```json
curl -X PUT "localhost:9200/_ilm/policy/del-index-7d" -H 'Content-Type: application/json' -d'
{
  "policy": {
    "phases": {
      "hot": {
        "min_age": "0ms",
        "actions": {}
      },
      "delete": {
        "min_age": "7d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}'
```

# [创建索引模板](https://www.elastic.co/guide/en/elasticsearch/reference/7.10/index-templates.html)
* 索引模板是一种告诉Elasticsearch在创建索引时如何配置索引的方法。
>可以通过Kibana管理页面设置(Stack Management -> Index Management -> Index Templates)，也可以通过API设置。
```
curl -X PUT "localhost:9200/_index_template/test-log_template?pretty" -H 'Content-Type: application/json' -d'
{
  "index_patterns": ["test-log-*"], #模板用于所有test-log-开头的索引
  "template": {
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 0,
      "index.lifecycle.name": "del-index-7d" #应用ILM策略到这个模板创建的索引上
    }
  }
}
'
```
