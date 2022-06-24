* 查看集群健康状态
```
curl "http://log.vevor-inner.com/_cluster/health"
```
* 列出索引
```
curl 'http://log.vevor-inner.com/_cat/indices'
```

* 删除索引
```
curl -XDELETE "http://log.vevor-inner.com/.opendistro-alerting-alert-history-2022.06.11-000038"
curl -XDELETE "http://log.vevor-inner.com/openresty-other-*"
```

* 设置集群每个node最大分片数
```
curl -XPUT "http://log.vevor-inner.com/_cluster/settings" -H 'Content-Type: application/json' -d
{
   "persistent":{
      "cluster.max_shards_per_node": 10000
   }
}
```
```
curl "http://log.vevor-inner.com/_cluster/settings?pretty" |jq .persistent.cluster.max_shards_per_node
```