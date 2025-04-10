* 查看集群健康状态
```
curl "http://log.example.com/_cluster/health"
```
* 列出索引
```
curl 'http://log.example.com/_cat/indices'
```

* 删除索引
```
curl -XDELETE "http://log.example.com/.opendistro-alerting-alert-history-2022.06.11-000038"
curl -XDELETE "http://log.example.com/openresty-other-*"
```

* 设置集群每个node最大分片数
```
curl -XPUT "http://log.example.com/_cluster/settings" -H 'Content-Type: application/json' -d
{
   "persistent":{
      "cluster.max_shards_per_node": 10000
   }
}
```
```
curl "http://log.example.com/_cluster/settings?pretty" |jq .persistent.cluster.max_shards_per_node
```


# nginx auth_basic代理aws opensearch
```
yum install httpd -y
htpasswd -c /usr/local/openresty/nginx/conf/htpasswd_log username
New password:

# 生成用户到密码文件（非交互式）
htpasswd -bc /usr/local/openresty/nginx/conf/htpasswd_log username password
# 新增用户
htpasswd -b /usr/local/openresty/nginx/conf/htpasswd_log username2 password2
```
```
server {
  listen 80;
  server_name log.example.com;

  location / {
     auth_basic  "HTTP Basic Authentication";
     auth_basic_user_file /usr/local/openresty/nginx/conf/htpasswd_log;
     proxy_set_header Authorization "";
     proxy_hide_header Authorization;

     proxy_pass https://vpc-product-xxxxxxxxxxxxxxxxxxx.us-west-2.es.amazonaws.com;
     proxy_redirect https://vpc-product-xxxxxxxxxxxxxxxxxxx.us-west-2.es.amazonaws.com/ http://log.example.com/;
     proxy_set_header Host $host;
     proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
  }

}
```