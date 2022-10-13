* https://docs.aws.amazon.com/zh_cn/opensearch-service/latest/developerguide/managedomains-snapshots.html

# 创建IAM角色对s3快照桶的策略
* opensearch-snapshot-logs
```
{
  "Version": "2012-10-17",
  "Statement": [{
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::opensearch-snapshot-logs"
      ]
    },
    {
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::opensearch-snapshot-logs/*"
      ]
    }
  ]
}
```
# 创建对opensearch ESHttpPut 操作的访问权限策略
* opensearch-http-put
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "arn:aws:iam::123456789012:role/opensearch-snapshot-logs"
    },
    {
      "Effect": "Allow",
      "Action": "es:ESHttpPut",
      "Resource": "arn:aws:es:us-west-2:123456789012:domain/product/*"
    }
  ]
}
```

# 创建角色
* IAM > 角色 > 创建角色 > AWS 账户
* 附加策略（opensearch-snapshot-logs、opensearch-http-put）
* 修改角色信任关系(IAM > 角色 >opensearch-snapshot-logs)
```
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "",
    "Effect": "Allow",
    "Principal": {
      "Service": "es.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }]

}
```

# 注册快照存储库
>因为curl不支持 AWS 请求签名。请改用示例 Python 客户端、Postman 或某种其他方式发送已签名请求以注册快照存储库
* vim register-repo.py
```python
import boto3
import requests
from requests_aws4auth import AWS4Auth

host = 'https://vpc-product-lpwn33dxg5ym2iv3vubselslve.us-west-2.es.amazonaws.com/' # include https:// and trailing /
region = 'us-west-2' # e.g. us-west-1
service = 'es'
credentials = boto3.Session().get_credentials()
awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)
# Register repository

path = '_snapshot/s3_backup' # the OpenSearch API endpoint
url = host + path

payload = {
  "type": "s3",
  "settings": {
    "bucket": "opensearch-snapshot-logs",
    "region": "us-west-2",
    "role_arn": "arn:aws:iam::123456789012:role/opensearch-snapshot-logs"
  }
}

headers = {"Content-Type": "application/json"}

r = requests.put(url, auth=awsauth, json=payload, headers=headers)

print(r.status_code)
print(r.text)

# # Take snapshot
#
# path = '_snapshot/my-snapshot-repo/my-snapshot'
# url = host + path
#
# r = requests.put(url, auth=awsauth)
#
# print(r.text)
#
# # Delete index
#
# path = 'my-index'
# url = host + path
#
# r = requests.delete(url, auth=awsauth)
#
# print(r.text)
#
# # Restore snapshot (all indices except Dashboards and fine-grained access control)
#
# path = '_snapshot/my-snapshot-repo/my-snapshot/_restore'
# url = host + path
#
# payload = {
#   "indices": "-.kibana*,-.opendistro_security",
#   "include_global_state": False
# }
#
# headers = {"Content-Type": "application/json"}
#
# r = requests.post(url, auth=awsauth, json=payload, headers=headers)
#
# print(r.text)
# 
# # Restore snapshot (one index)
#
# path = '_snapshot/my-snapshot-repo/my-snapshot/_restore'
# url = host + path
#
# payload = {"indices": "my-index"}
#
# headers = {"Content-Type": "application/json"}
#
# r = requests.post(url, auth=awsauth, json=payload, headers=headers)
#
# print(r.text)
```

* 注册快照仓库
```
$ python register-repo.py
200
{"acknowledged":true}
```

* 删除快照仓库
```
curl -XDELETE https://vpc-product-lpwn33dxg5ym2iv3vubselslve.us-west-2.es.amazonaws.com/_snapshot/s3_backup
```

* 查询快照仓库
```
# 查询所有快照仓库
curl -XGET https://vpc-product-lpwn33dxg5ym2iv3vubselslve.us-west-2.es.amazonaws.com/_snapshot?pretty
# 查询指定快照仓库
curl -XGET https://vpc-product-lpwn33dxg5ym2iv3vubselslve.us-west-2.es.amazonaws.com/_snapshot/s3_backup?pretty
```


# 创建快照
* vim create-snap.py
```py
import boto3
import requests
from requests_aws4auth import AWS4Auth

host = 'https://vpc-product-lpwn33dxg5ym2iv3vubselslve.us-west-2.es.amazonaws.com/' # include https:// and trailing /
region = 'us-west-2' # e.g. us-west-1
service = 'es'
credentials = boto3.Session().get_credentials()
awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)

# Take snapshot

path = '_snapshot/s3_backup/snapshot-test'
url = host + path
payload = {
  "indices": "index1,index2"
}

r = requests.put(url, auth=awsauth)
print(r.text)
```
```
$ python create-snap.py
200
{"acknowledged":true}
```

* 删除快照
```
curl -XDELETE https://vpc-product-lpwn33dxg5ym2iv3vubselslve.us-west-2.es.amazonaws.com/_snapshot/s3_backup/snapshot-test
```

* 查询快照
```
# 查询所有快照
curl -XGET https://vpc-product-lpwn33dxg5ym2iv3vubselslve.us-west-2.es.amazonaws.com/_snapshot/s3_backup/_all?pretty
# 查询指定快照
curl -XGET https://vpc-product-lpwn33dxg5ym2iv3vubselslve.us-west-2.es.amazonaws.com/_snapshot/s3_backup/snapshot-test?pretty
curl -XGET https://vpc-product-lpwn33dxg5ym2iv3vubselslve.us-west-2.es.amazonaws.com/_snapshot/s3_backup/snapshot-*?pretty

# 查询快照状态
curl -XGET https://vpc-product-lpwn33dxg5ym2iv3vubselslve.us-west-2.es.amazonaws.com/_snapshot/s3_backup/snapshot-test/_status?pretty
```


# [使用索引状态管理自动执行快照](https://docs.aws.amazon.com/zh_cn/opensearch-service/latest/developerguide/ism.html#ism-example)
* https://opensearch.org/docs/latest/im-plugin/ism/policies/#snapshot
* https://opensearch.org/docs/latest/im-plugin/ism/policies/#example-policy
```json
curl -XPOST -H 'Content-Type: application/json' http://localhost:9200/_plugins/_ism/add/del-index-7d-snapshot
{
  "policy": {
    "description": "Snapshot index that are age than 1 days and Delete index that are age than 7 days",
    "schema_version": 1,
    "default_state": "hot",
    "states": [
      {
        "name": "hot",
        "actions": [],
        "transitions": [
          {
            "state_name": "snapshot",
            "conditions": {
              "min_index_age": "1d"
            }
          }
        ]
      },
      {
        "name": "snapshot",
        "actions": [
          {
            "snapshot": {
              "repository": "s3_backup",
              "snapshot": "pci-pay-logs"     //快照名称被作为前缀，创建日期自动被添加到它应该具有的名称之后
            }
          }
        ],
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
    "ism_template": {
      "index_patterns": [
        "pay-*",
        "ads-*"
      ],
      "priority": 100     //值越高，优先级越高
    }
  }
}
```

# 恢复快照
* 查询2022.07.27快照的数据
```
curl -XGET https://xxxxxxxxxxx.us-west-2.es.amazonaws.com/_snapshot/s3_backup/pci-pay-logs-2022.07.28-*?pretty
```
* 不能将索引的快照还原到已包含同名索引的 OpenSearch 群集
```
#删除opensearch中同名索引
curl -XDELETE 'https://xxxxxxxxxxx.us-west-2.es.amazonaws.com/index-name'
```
* 恢复快照
```
curl -XPOST 'https://xxxxxxxxxxx.us-west-2.es.amazonaws.com/_snapshot/s3_backup/pci-pay-logs-2022.07.28-05:32:16.953/_restore'

#恢复快照中指定的索引
curl -XPOST 'domain-endpoint/_snapshot/cs-automated/2020-snapshot/_restore' -d '{"indices": "my-index"}' -H 'Content-Type: application/json'
#恢复快照中除指定索引以外的所有索引
curl -XPOST 'domain-endpoint/_snapshot/cs-automated/2020-snapshot/_restore' -d '{"indices": "-.kibana*,-.opendistro*"}' -H 'Content-Type: application/json'

```



# aws opensearch默认自动快照仓库
* 列出快照仓库
```
curl -XGET https://xxxxxxxxxxx.us-west-2.es.amazonaws.com/_snapshot?pretty
{
  "cs-automated-enc" : {
    "type" : "s3"
  }
}
```
* 查询cs-automated-enc仓库，快照名包含2022-06-10的快照
```
curl -XGET https://xxxxxxxxxxx.us-west-2.es.amazonaws.com/_snapshot/cs-automated-enc/2022-06-10*?pretty
```
* [恢复快照](https://opensearch.org/docs/latest/opensearch/snapshots/snapshot-restore/#restore-snapshots)
```
curl -XPOST 'https://xxxxxxxxxxx.us-west-2.es.amazonaws.com/_snapshot/cs-automated-enc/2022-06-10t23-41-15.707514a0-3bfd-4d82-b177-d23615f9e4c2/_restore' -H 'Content-Type: application/json' -d '
{
  "indices": ".kibana_1",
  "rename_pattern": ".kibana_1",        #匹配需要重命名的索引组
  "rename_replacement": ".kibana_1_old" #替换匹配的索引名
}'
```