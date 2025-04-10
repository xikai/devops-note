* https://opensearch.org/docs/latest/monitoring-plugins/alerting/index/

# 创建告警目标
>Alerting -> Destinations -> Add destination.

# 创建监视器
>Alerting -> Monitors -> Create monitor.
* [Define monitor（Define using extraction query）](https://opensearch.org/docs/latest/opensearch/query-dsl/bool/)
```json
{
  "query": {
    "bool": {
      "must": [   //结果必须与此子句中的查询匹配。如果您有多个查询，则每一个都必须匹配。充当and操作员。
        {}
      ],
      "must_not": [ //这与must相反。所有匹配都从结果中排除。充当not操作员。
        {}
      ],
      "should": [  //结果应该但不必与查询匹配,每个匹配should子句都会增加相关性分数。作为一种选择，您可以要求一个或多个查询来匹配minimum_number_should_match参数的值（默认值为 1）
        {}
      ],
      "filter": {} //使用过滤器查询根据完全匹配、范围、日期、数字等过滤结果
    }
  }
}
```
```json
{
  "bool": {
    "must": [
      {
        "match_phrase": {
          "message": "errors php"
        }
      }
    ],
    "should": [],
    "must_not": [],
    "filter": [
      {
        "range": {
          "@timestamp": {
            "from": "now-1m",
            "to": "now",
            "include_lower": true,
            "include_upper": true,
            "format": "strict_date_optional_time"
          }
        }
      }
    ]
  }
}
```

* [查询DSL](https://opensearch.org/docs/latest/opensearch/query-dsl/full-text/)
```json
{
  "bool": {
    "should": [
      {
        "match": {
          "status": "504"
        }
      },
      {
        "match": {
          "status": "502"
        }
      }
    ],
    "minimum_should_match": 1,
    "filter": [
      {
        "range": {
          "@timestamp": {
            "from": "now-1m",
            "to": "now",
            "include_lower": true,
            "include_upper": true,
            "format": "strict_date_optional_time"
          }
        }
      }
    ]
  }
}
```

* 浏览器打开kibana，通过KQL过滤 生成查询语句 -> F12 -> Networking -> XHR -> es -> payload: params...query 

# 创建触发器
```
ctx.results[0].hits.total.value > 0
```

# 配置告警
```json
{"msgtype": "markdown","markdown": {"title":"【{{#ctx.results}} {{#hits.hits}} {{_index}} {{/hits.hits}} {{/ctx.results}}】前台-PC-网站异常监控点告警",
"text":"
# 【{{#ctx.results}} {{#hits.hits}} {{_index}} {{/hits.hits}} {{/ctx.results}}】前台-PC-网站异常监控点告警
{{#ctx.results}}
{{#hits.hits}}
## {{_source.@timestamp}}
> {{_source.message}}

{{/hits.hits}}
{{/ctx.results}}
\n
[查看全部](dingtalk://dingtalkclient/page/link?pc_slide=false&url=http%3A%2F%2Flog.vevor-inner.com%2F_plugin%2Fkibana%2Fapp%2Fdiscover%23%2F%3F_g%3D%28filters%3A%21%28%29%2CrefreshInterval%3A%28pause%3A%21t%2Cvalue%3A0%29%2Ctime%3A%28from%3A%27{{ctx.periodStart}}%27%2Cto%3A%27{{ctx.periodEnd}}%27%29%29%26_a%3D%28columns%3A%21%28_source%29%2Cfilters%3A%21%28%29%2Cindex%3A%27859f8410-58c8-11ec-8cf5-ed1e5e25408f%27%2Cinterval%3Aauto%2Cquery%3A%28language%3Akuery%2Cquery%3A%27message%3A%2520%28%28%2522errors%2520exception%2522%29%2520and%2520not%2520%28%2522SoaException%2870017%29%2522%29%2520and%2520not%2520%28%2522SoaException%2820009%29%2522%29%2520and%2520not%2520%28%2522SoaException%2820021%29%2522%29%2520and%2520not%2520%28%2522ShopcartException%2522%29%2520and%2520not%2520%28%2522SoaException%2870009%29%2522%29%2520and%2520not%2520%28%2522NotFoundHttpException%2522%29%29%27%29%2Csort%3A%21%28%29%29)
"}}
```