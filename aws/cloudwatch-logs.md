# [日志事件和 Live Tail 的筛选条件模式语法](https://docs.aws.amazon.com/zh_cn/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html)
* 日志事件： CloudWatch > 日志组 > 日志流(aws-waf-logs-cloudfront)
* 使用正则表达式搜索和筛选日志数据时，必须用 % 将表达式括起来
```
%[abc]% 匹配“a”、“b”或“c”；%[a-z]% 匹配从“a”到“z”的任何小写字母
%gra|ey% 可以匹配“gray”或“grey”

%AUTHORIZED% 返回包含 AUTHORIZED 关键字的所有日志事件
```
* 匹配 JSON 日志事件中的字词
```
{ $.eventType = "UpdateTrail" }                               
{ ($.user.email = "John.Stiles@example.com" || $.coordinates[0][1] = "nonmatch") && $.actions[2] = "nonmatch" }                            
```


# [Logs Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html)
>CloudWatch Logs Insights 可自动发现来自 AWS 服务（如 Amazon Route 53、AWS Lambda、AWS CloudTrail 和 Amazon VPC）的日志中的字段，以及以 JSON 格式发出日志事件的任何应用程序或自定义日志
* 自动发现己选日志组的字段
```
在CloudWatch > Logs Insights 页面选择日志组后，页面右上角查看（己发现的字段）
```

* 对于发送到 Amazon Logs 的每条 CloudWatch 日 CloudWatch 志，Logs Insights 都会自动生成五个系统字段
>CloudWatch Logs Insights 会自动发现不同日志类型的字段，并生成以 @ 字符开头的字段。
```
@message 包含原始未解析的日志事件。这等同于中的message字段InputLogevent。
@timestamp 包含日志事件的 timestamp 字段中事件时间戳。这等同于中的timestamp字段InputLogevent。
@ingestionTime包含 CloudWatch Logs 收到日志事件的时间。
@logStream 包含已将日志事件添加到的日志流的名称。日志流使用与生成日志的相同进程对日志进行分组。
@log 是 account-id:log-group-name 形式的日志组标识符。在查询多个日志组时，这可能对于确定特定事件属于哪个日志组非常有用。
```

* [查询语法](https://docs.aws.amazon.com/zh_cn/AmazonCloudWatch/latest/logs/CWL_QuerySyntax.html)
  - 查询语法支持不同的函数和运算，包括但不限于常规函数、算术和比较运算以及正则表达式。
  - 要创建包含多个命令的查询，请使用竖线字符（|）分隔命令
  - 要创建包含注释的查询，请使用哈希字符（#）对注释进行分隔。
  
  * 常用函数
    ```
    display 在查询结果中显示一个或多个特定字段。
    fields 在查询结果中显示多个特定字段，并支持函数和操作，可用于修改字段值和创建用于查询的新字段。
    filter 筛选查询，以仅返回与一个或多个条件匹配的日志事件。（通过运算符过滤）
    pattern 自动将您的日志数据划分为不同模式。模式是在日志字段中重复出现的共有的文本结构。
    parse 从日志字段中提取数据，以创建可以在查询中处理的提取字段。parse 同时支持使用通配符和正则表达式的 glob 模式。
    sort 按升序 (asc) 或降序 (desc) 顺序显示返回的日志事件。
    stats 使用日志字段值计算聚合统计数据。
    limit 指定您希望查询返回的最大日志事件数。对于 sort 返回“前 20 个”或“最近 20 个”结果很有用。
    dedup 根据您指定的字段中的特定值删除重复的结果。
    unmask 显示由于数据保护策略而屏蔽部分内容的日志事件的所有内容。有关日志组中数据保护的更多信息，请参阅 通过屏蔽帮助保护敏感的日志数据。
    ```
* 查询示例
```
# 查找 25 个最近添加的日志事件
fields @timestamp, @message | sort @timestamp desc | limit 25

# 获取每小时异常数量的列表
filter @message like /Exception/ 
    | stats count(*) as exceptionCount by bin(1h)
    | sort exceptionCount desc

# 获取非异常的日志事件的列表
fields @message | filter @message not like /Exception/

# 获取 server 字段每个唯一值的最新日志事件(对server字段去复)
fields @timestamp, server, severity, message 
| sort @timestamp asc 
| dedup server

# 针对每个 severity 类型获取 server 字段每个唯一值的最新日志事件
fields @timestamp, server, severity, message 
| sort @timestamp desc 
| dedup server, severity
```

* 使用聚合函数运行查询
```
stats count(*) by fieldName
```

### JSON 日志中的字段
>使用点符号表示 JSON 字段
```json
{
    "eventVersion": "1.0",
    "userIdentity": {
        "type": "IAMUser",
        "principalId": "EX_PRINCIPAL_ID",
        "arn": "arn: aws: iam: : 123456789012: user/Alice",
        "accessKeyId": "EXAMPLE_KEY_ID",
        "accountId": "123456789012",
        "userName": "Alice"
    },
    "eventTime": "2014-03-06T21: 22: 54Z",
    "eventSource": "ec2.amazonaws.com",
    "eventName": "StartInstances",
    "awsRegion": "us-east-2",
    "sourceIPAddress": "192.0.2.255",
    "userAgent": "ec2-api-tools1.6.12.2",
    "requestParameters": {
        "instancesSet": {
            "items": [
                {
                    "instanceId": "i-abcde123"
                }
            ]
        }
    },
    "responseElements": {
        "instancesSet": {
            "items": [
                {
                    "instanceId": "i-abcde123",
                    "currentState": {
                        "code": 0,
                        "name": "pending"
                    },
                    "previousState": {
                        "code": 80,
                        "name": "stopped"
                    }
                }
            ]
        }
    }
}
```
```
该示例 JSON 事件包含一个名为 userIdentity 的对象。userIdentity 包含一个名为 type 的字段。要使用点表示法表示 type 的值，请使用: userIdentity.type
该示例 JSON 事件包含多个数组，它们展平到嵌套字段名称和值的列表。要表示 requestParameters.instancesSet 中第一个项目的 instanceId 值，请使用 requestParameters.instancesSet.items.0.instanceId
```
* 查询筛选 instanceId 的值等于 "i-abcde123" 的消息，并返回包含指定值的所有录入事件
```
fields @timestamp, @message
| filter requestParameters.instancesSet.items.0.instanceId="i-abcde123"
| sort @timestamp desc
```


### [waf示例](https://repost.aws/zh-Hans/knowledge-center/waf-analyze-logs-stored-cloudwatch-s3)
* 筛选跨站点脚本或 SQL 注入的waf日志
```sh
fields @timestamp, terminatingRuleId, action, httpRequest.clientIp as ClientIP, httpRequest.country as Country, terminatingRuleMatchDetails.0.conditionType as ConditionType, terminatingRuleMatchDetails.0.location as Location, terminatingRuleMatchDetails.0.matchedData.0 as MatchedData
| filter ConditionType in["XSS","SQL_INJECTION"]
```

* 过滤请求/api/encipher/upload，被AWSManagedRulesSQLiRuleSet拒绝的waf日志
```sh
fields @timestamp, @message
| filter (httpRequest.uri="/api/encipher/upload" and terminatingRuleId="AWS-AWSManagedRulesSQLiRuleSet" and action="BLOCK")
```