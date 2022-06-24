* https://www.elastic.co/guide/en/elasticsearch/reference/7.15/snapshot-restore.html
# snapshot原理
* 对运行中的es集群索引进行增量备份

# es snapshot
* 在es中注册快照存储仓库
```
curl -XPUT 'http://localhost:9200/_snapshot/my_backup' -H 'Content-Type: application/json' -d '{
  "type": "fs",
  "settings": {
        ... repository specific settings ...
  }
}
```

* 获取快照存储仓库信息
```
curl -XGET localhost:9200/_snapshot/my_backup

# 获取多个快照存储仓库信息（用逗号隔开 可以用通配符匹配）
curl -XGET localhost:9200/_snapshot/repo*,*backup*

# 返回当前注册的所有存储仓库
curl -XGET localhost:9200/_snapshot
curl -XGET localhost:9200/_snapshot/_all
```

# 挂载共享文件系统作为快照仓库
```
vim elasticsearch.yml
path.repo: ["/mount/backups", "/mount/longterm_backups"]
```
```
systemctl restart elasticsearch
```

* 创建共享文件系统仓库
```
curl -XPUT 'http://localhost:9200/_snapshot/my_backup' -H 'Content-Type: application/json' -d '{
    "type": "fs",
    "settings": {
        "location": "/mount/backups/my_backup",
        "compress": true
    }
}'
```

# 使用s3作为快照仓库
* 创建s3存储桶
* [配置可以访问s3存储桶所需最小权限的IAM用户/角色策略](https://www.elastic.co/guide/en/elasticsearch/reference/master/repository-s3.html#repository-s3-permissions)
* [创建VPC终端节点到s3服务（同区域）](https://docs.amazonaws.cn/vpc/latest/privatelink/vpce-gateway.html)
* [安装es s3插件(所有节点)](https://www.elastic.co/guide/en/elasticsearch/plugins/current/repository-s3.html)
```
#The plugin must be installed on every node in the cluster, and each node must be restarted after installation.
sudo bin/elasticsearch-plugin install repository-s3

#创建aws s3.access_key
bin/elasticsearch-keystore create
bin/elasticsearch-keystore add s3.client.default.access_key
 AKIAW5SEXXXXXXXXX
bin/elasticsearch-keystore add s3.client.default.secret_key
 WUP5YB6O03GRXXXXXXXXXXXXXXXXXXXXXXX

#重启所有节点
systemctl restart elasticsearch  
```
* 创建s3快照存储仓库
* https://github.com/elastic/elasticsearch/blob/master/docs/plugins/repository-s3.asciidoc
* https://www.elastic.co/guide/en/elasticsearch/plugins/current/repository-s3-repository.html#repository-s3-permissions
```
$ curl -XPUT 'http://localhost:9200/_snapshot/s3_backup' -H 'Content-Type: application/json' -d '{
    "type": "s3",
    "settings": {
        #"endpoint": "https://s3.cn-northwest-1.amazonaws.com.cn", #AWS中国需要指定s3终端节点地址
        "bucket": "es-snapshot-backup",
        "region": "us-west-2",
        "compress": true
    }
}'
```
```
# 确认备份仓库是否创建成功
curl -XPOST http://localhost:9200/_snapshot/s3_backup/_verify?pretty

#查看创建的存储仓库
curl -XGET localhost:9200/_snapshot/s3_backup?pretty
```

# 创建快照
```
#备份所有索引
curl -XPUT http:///localhost:9200/_snapshot/s3_backup/snapshot_all

#备份指定索引
curl -XPUT 'http://localhost:9200/_snapshot/s3_backup/index-201807' -H 'Content-Type: application/json' -d '{ "indices": "index-201807" }'

#备份多个索引：
curl -XPUT 'http://localhost:9200/_snapshot/s3_backup/index-201807' -H 'Content-Type: application/json' -d '{
   "indices": "products,index_1,index_2",
   "ignore_unavailable": true,
   "include_global_state": false
}'
```

# 查看快照
```
# 查询指定快照
curl -XGET localhost:9200/_snapshot/s3_backup/snapshot_1?pretty
curl -XGET localhost:9200/_snapshot/s3_backup/snapshot_1?wait_for_completion=true  #等待完成
# 查询多个快照
curl -XGET localhost:9200/_snapshot/s3_backup/snapshot_*,some_other_snapshot?pretty
# 查询所有快照
curl -XGET localhost:9200/_snapshot/s3_backup/_all?pretty

# 查询条件过滤(snap开头，2个快照，name排序)
curl -XGET localhost:9200/_snapshot/s3_backup/snap*?size=2&sort=name
```
* 从多个仓库检索快照
```
GET -XGET localhost:9200/_snapshot/my_backup,my_fs_backup
GET -XGET localhost:9200/_snapshot/my*
```

# 恢复快照
* 默认情况下，快照中的所有索引都会被恢复，集群状态 不会被恢复
```
curl -XPOST 'http://localhost:9200/_snapshot/s3_backup/snapshot_1/_restore
```
* 恢复指定索引的快照
```
curl -XPOST 'http://localhost:9200/_snapshot/s3_backup/snapshot_1/_restore -d '{
  "indices": "index_1,index_2",
  "ignore_unavailable": true,
  "include_global_state": true,
  "rename_pattern": "index_(.+)",
  "rename_replacement": "restored_index_$1"
}'
```

# 监视快照创建和恢复过程
```
# 监视所有快照的创建恢复过程
curl -XGET localhost:9200/_snapshot/s3_backup/_current?pretty
# 监视快照snapshot_1的创建恢复过程
curl -XGET localhost:9200/_snapshot/s3_backup/snapshot_1/_current?pretty
# 监视多个快照的创建恢复过程
curl -XGET localhost:9200/_snapshot/my_backup/snapshot_*,some_other_snapshot?pretty
```
```
curl -XGET localhost:9200/_cat/snapshots/s3_backup?pretty
```

# 获取快照详细信息
```
curl -XGET localhost:9200/_snapshot/s3_backup/snapshot_1/_status?pretty
curl -XGET localhost:9200/_snapshot/s3_backup/snapshot_1,snapshot_2/_status?pretty
```

# 从存储仓库删除快照(停止快照创建和恢复操作)
```
curl -XDELETE localhost:9200/_snapshot/s3_backup/snapshot_1
curl -XDELETE localhost:9200/_snapshot/s3_backup/snapshot_2,snapshot_3
curl -XDELETE localhost:9200/_snapshot/s3_backup/snap*
```
* 删除快照仓库
```
curl -XDELETE localhost:9200/_snapshot/s3_backup
```

# [SLM(快照生命周期管理策略)](https://www.elastic.co/guide/en/elasticsearch/reference/7.15/getting-started-snapshot-lifecycle-management.html#slm-gs-create-policy)
```
curl -XPUT localhost:9200/_slm/policy/nightly-snapshots
{
  "schedule": "0 30 1 * * ?", 
  "name": "<nightly-snap-{now/d}>", 
  "repository": "s3_backup", 
  "config": { 
    "indices": ["*"] 
  },
  "retention": { 
    "expire_after": "30d", 
    "min_count": 5, 
    "max_count": 50 
  }
}
```

* 立即执行SLM快照策略
```
curl -XPOST localhost:9200/_slm/policy/nightly-snapshots/_execute
```
* 查看slm是否运行成功
>如果快照在复制文件时丢失了与远程存储库的连接，则初始快照可能会失败。
```
curl -XGET localhost:9200/_slm/policy/nightly-snapshots?human
```

* 查看所有slm policy
```
curl -XGET localhost:9200/_slm/policy
```
* 删除slm
```
curl -XDELETE localhost:9200/_slm/policy/nightly-snapshots
```