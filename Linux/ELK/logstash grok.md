* https://www.jianshu.com/p/d46b911fb83e
* https://www.elastic.co/guide/en/logstash/6.7/plugins-filters-grok.html


### 自定义pattern
* 查找logstash patterns目录
```
rpm -ql logstash|grep patterns
```

>vim grok-patterns 添加nginx patterns类型
```
# Nginx logs
NGUSERNAME [a-zA-Z\.\@\-\+_%]+
NGUSER %{NGUSERNAME}
NGINXACCESS %{IPORHOST:clientip} %{NGUSER:ident} %{NGUSER:auth} \[%{HTTPDATE:timestamp}\] "%{WORD:verb} %{URIPATHPARAM:request} HTTP/%{NUMBER:httpversion}" %{NUMBER:response} (?:%{NUMBER:bytes}|-) (?:"(?:%{URI:referrer}|-)"|%{QS:referrer}) %{QS:agent}
```
```
systemctl restart logstash
```