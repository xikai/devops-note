* https://www.elastic.co/guide/en/elasticsearch/reference/6.3/ingest.html
# [grok-processor](https://www.elastic.co/guide/en/elasticsearch/reference/6.3/grok-processor.html)
* [Grok处理器预装了一组基本模式](https://github.com/elastic/elasticsearch/blob/6.3/libs/grok/src/main/resources/patterns/grok-patterns)
* [Oniguruma正则表达式](https://github.com/kkos/oniguruma/blob/master/doc/RE)

* 自定义Patterns(将您自己的模式添加到pattern_definitions选项下的processors定义中)
```json
{
  "description" : "...",
  "processors": [
    {
      "grok": {
        "field": "message",
        "patterns": ["my %{FAVORITE_DOG:dog} is colored %{RGB:color}"],
        "pattern_definitions" : {
          "FAVORITE_DOG" : "beagle",
          "RGB" : "RED|GREEN|BLUE"
        }
      }
    }
  ]
}
```

* 构建patterns的实用工具
  * Grok Debugger: kibana -> Dev Tools -> Grok Debugger


# 在Elasticsearch中创建一个摄取节点管道
>在实际的文档索引到es之前，使用摄取节点对文档进行预处理,ingest node拦截bulk和index请求，应用转换，然后将文档传递回索引或批量api。默认情况下，所有节点都启用ingest node,因此任何节点都可以处理ingest任务。
```json
curl -H 'Content-Type: application/json' -XPUT 'http://localhost:9200/_ingest/pipeline/nginx-grok' -d'
{
  "description": "nginx-grok",
  "processors": [
    {
      "grok": {
        "field": "message",
        "patterns": [
          "%{IP:remote_addr} - %{DATA:remote_user} \\[%{HTTPDATE:time}\\] \"%{WORD:method} %{DATA:uri}\" %{NUMBER:status:int} %{NUMBER:body_bytes_sent:int} \"%{DATA:http_referer}\" \"%{DATA:http_user_agent}\" \"%{DATA:http_x_forwarded_for}\"",
          "%{GREEDYDATA:time} \\[%{WORD:level}\\] %{GREEDYDATA:msg}"
        ]
      }
    }
  ]
}'
```

* 在filebeat output中使用pipeline
```
output.elasticsearch:
  hosts: ["localhost:9200"]
  pipeline: "nginx-grok"
```


# 示例：自定义Patterns匹配aws cdn日志
```json
curl -H 'Content-Type: application/json' -XPUT 'http://localhost:9200/_ingest/pipeline/cloudfront-grok' -d'
{
  "description": "cloudfront-grok",
  "processors": [
    {
      "grok": {
        "field": "message",
        "patterns": [
          "%{DATE_YMD:date}\\s+%{TIME:time}\\s+%{GREEDYDATA:x_edge_location}\\s+(?:%{NUMBER:sc_bytes:int}|-)\\s+%{IPORHOST:c-ip}\\s+%{WORD:cs_method}\\s+%{HOSTNAME:cs_host}\\s+%{NOTSPACE:cs_uri_stem}\\s+%{NUMBER:sc_status:int}\\s+%{NOTSPACE:referrer}\\s+%{NOTSPACE:User-Agent}\\s+(%{NOTSPACE:cs_uri_query}|-)\\s+(%{NOTSPACE:cookies}|-)\\s+%{WORD:x_edge_result_type}\\s+%{NOTSPACE:x_edge_request_id}\\s+%{NOTSPACE:x_host_header}\\s+%{URIPROTO:cs_protocol}\\s+%{INT:cs_bytes:int}\\s+%{GREEDYDATA:time_taken:float}\\s+(%{NOTSPACE:x_forwarded_for}|-)\\s+%{NOTSPACE:ssl_protocol}\\s+%{NOTSPACE:ssl_cipher}\\s+%{NOTSPACE:x_edge_response_result_type}\\s+%{NOTSPACE:cs-protocol-version}\\s+(%{NOTSPACE:fle-status}|-)\\s+(%{NOTSPACE:fle-encrypted-fields}|-)\\s+%{NUMBER:c-port:int}\\s+%{NUMBER:time-to-first-byte}\\s+%{NOTSPACE:x-edge-detailed-result-type}\\s+%{NOTSPACE:sc-content-type}\\s+(%{NOTSPACE:sc-content-len}|-)\\s+(%{NOTSPACE:sc-range-start}|-)\\s+(%{NOTSPACE:sc-range-end}|-)"
        ],
        "pattern_definitions" : {
          "DATE_YMD" : "%{YEAR}-%{MONTHNUM}-%{MONTHDAY}"
        }
      }
    }
  ]
}'
```