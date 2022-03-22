* https://docs.aws.amazon.com/zh_cn/opensearch-service/latest/developerguide/managedomains-snapshots.html

# 创建对s3快照桶的策略
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

path = '_snapshot/audit-logs' # the OpenSearch API endpoint
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
```
$ curl https://vpc-product-lpwn33dxg5ym2iv3vubselslve.us-west-2.es.amazonaws.com/_snapshot/audit-logs?pretty
{
  "audit-logs" : {
    "type" : "s3",
    "settings" : {
      "bucket" : "opensearch-snapshot-logs",
      "region" : "us-west-2",
      "role_arn" : "arn:aws:iam::123456789012:role/opensearch-snapshot-logs"
    }
  }
}
```

* 创建快照
```
curl -XPUT 'https://vpc-product-lpwn33dxg5ym2iv3vubselslve.us-west-2.es.amazonaws.com/_snapshot/audit-logs/snapshot-test' -H 'Content-Type: application/json' -d '{
   "indices": "movies,opendistro-sample-http-responses",
   "ignore_unavailable": true,
   "include_global_state": false
}'
```
* 查询快照
```
curl -XGET https://vpc-product-lpwn33dxg5ym2iv3vubselslve.us-west-2.es.amazonaws.com/_snapshot/audit-logs/snapshot-test?pretty
```
* 查询快照状态
```
curl -XGET https://vpc-product-lpwn33dxg5ym2iv3vubselslve.us-west-2.es.amazonaws.com/_snapshot/audit-logs/snapshot-test/_status?pretty
```