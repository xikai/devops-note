* https://www.elastic.co/guide/en/elasticsearch/reference/6.3/ingest.html

>在实际的文档索引到es之前，使用摄取节点对文档进行预处理,ingest node拦截bulk和index请求，应用转换，然后将文档传递回索引或批量api。默认情况下，所有节点都启用ingest node,因此任何节点都可以处理ingest任务。

* 添加pipelines和更新集群中的现有pipelines
```json
curl -X PUT "localhost:9200/_ingest/pipeline/my-pipeline-id?pretty" -H 'Content-Type: application/json' -d'
{
  "description" : "describe pipeline",
  "processors" : [
    {
      "set" : {
        "field": "foo",
        "value": "bar"
      }
    }
  ]
}
'
```
* 查询pipelines
```
curl -X GET "localhost:9200/_ingest/pipeline                            #列出所有pipelines
curl -X GET "localhost:9200/_ingest/pipeline/my-pipeline-id?pretty"     #列出指定pipelines
```

* 删除pipelines
```
curl -X DELETE "localhost:9200/_ingest/pipeline/my-pipeline-id?pretty"
```

* 模拟pipelines
```json
POST _ingest/pipeline/_simulate
{
  "pipeline" : {
    // pipeline definition here
  },
  "docs" : [
    { "_source": {/** first document **/} },
    { "_source": {/** second document **/} },
    // ...
  ]
}
```
* 模拟己存在的pipelines
```json
POST _ingest/pipeline/my-pipeline-id/_simulate
{
  "docs" : [
    { "_source": {/** first document **/} },
    { "_source": {/** second document **/} },
    // ...
  ]
}
```
