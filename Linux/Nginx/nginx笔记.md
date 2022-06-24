* http://nginx.org/en/docs/
* http://www.nginx.cn/doc/


# 日志格式
```
log_format  main  '$remote_addr [$time_local] "$host" "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for" '
                      '[$request_time] [$upstream_response_time]';

$request_time   指的就是从接受用户请求到发送完响应数据的时间，即包括接收请求数据时间、程序处理响应时间、输出响应数据时间。
$upstream_response_time  是指从Nginx向后端（php-cgi)建立连接开始到接受完数据然后关闭连接为止的时间。
```

# 配置
```
#一个nginx进程打开的最多文件描述符数目，理论值应该是最多打开文件数（系统的值ulimit -n）与nginx进程数相除，但是nginx分配请求并不均匀，所以建议与ulimit -n的值保持一致。
worker_rlimit_nofile 65535;

#单个进程最大连接数（最大连接数=连接数*进程数）
worker_connections 65535;

client_header_buffer_size 32k
默认客户请求头缓冲大小
 
large_client_header_buffers 4 32k
nginx默认会用client_header_buffer_size这个buffer来读取header值，如果
header过大，它会使用large_client_header_buffers来读取

proxy_connect_timeout
后端服务器连接的超时时间_发起握手等候响应超时时间
proxy_read_timeout
连接成功后_等候后端服务器响应时间_其实已经进入后端的排队之中等候处理（也可以说是后端服务器处理请求的时间）
proxy_send_timeout
后端服务器数据回传时间_就是在规定时间之内后端服务器必须传完所有的数据

proxy_buffer_size 4k 该指令设置缓冲区大小,代理从后端服务器取得的第一部分的响应内容,会放到这里
proxy_buffers 4 32k  当缓存区数据大于4K时 使用proxy_buffers来缓冲

server 192.168.221.57:8013 max_fails=2 fail_timeout=10s;
在fail_timeout设置的时间10s内，偿试2次连接失败后，10s内不在请求这台机器
注：请求量大 后端机器多 fail_timeout时间可以设短一点
如果请求到down掉的后端，默认会返回502,需要配合proxy_next_upstream http_502 来自动转发一下台后端处理（Default:	proxy_next_upstream error timeout;）

break 中断处理当前相同作用域中后续的指令
```

# location
```
http://blog.csdn.net/xy2204/article/details/47749405

location表达式类型
~ 表示执行一个正则匹配，区分大小写
~* 表示执行一个正则匹配，不区分大小写
^~ 表示普通字符匹配。使用前缀匹配。如果匹配成功，则不再匹配其他location。
= 进行普通字符精确匹配。也就是完全匹配。
@ 它定义一个命名的 location，使用在内部定向时，例如 error_page, try_files

location优先级说明
在nginx的location和配置中location的顺序没有太大关系。正location表达式的类型有关。相同类型的表达式，字符串长的会优先匹配。
以下是按优先级排列说明：
等号类型（=）的优先级最高。一旦匹配成功，则不再查找其他匹配项。
^~类型表达式。一旦匹配成功，则不再查找其他匹配项。
正则表达式类型（~ ~*）的优先级次之。如果有多个location的正则能匹配的话，则使用正则表达式最长的那个。
常规字符串匹配类型。按前缀匹配。
```


# rewrite
```
last   被rewrite重写过后的新的URI，不在本location块继续匹配，而是重新开始在server块中所有的location块中匹执行，循环次数不超过10次（否则报循环重定向过多）
break  被rewrite重写过后的新的URI，在本块中继续匹配执行。

permanent –   将重写过后的新的URI 返回301永久重定向, 地址栏显示重定向后的url，爬虫更新url
redirect –    将重写过后的新的URI 返回302临时重定向，地址栏显示重定向后的url，爬虫不会更新url（因为是临时）

# 将test.php?id=xxx&name=xxxx 重写为test-xxx-xxx.html
rewrite ^/test-(.*)-(.*).html$ /test.php?id=$1&name=$2 last;
```
```
# 301重定向
server {
    server_name test.fanhougame.net;
    rewrite ^/(.*)$ http://yh.fanhougame.net/$1 permanent;
}
```

```
#静态URL中带问号的地址转发
1.nginx在进行rewrite的正则表达式中只会将url中？前面的部分拿出来匹配
2.匹配完成后？后面的内容将自动追加到url中（包含？），如果不让后面的内容追加上去，请在最后加上？即可
3.如果想要？后面的内容则请使用$query_string
4.如果想要？后面指定的参数的值 使用"$arg_参数名"匹配

eg:
http://www.test.com/product?q=123   ---->    http://www.test.com/product?page=123
rewrite ^/product$ /product?page=$arg_q?

http://www.test.com/product?q=123&s=abc   ---->    http://www.test.com/product123?q=123&s=abc
rewrite ^/product$ /product123$query_string?
```
```
#rewrite参数超过9个使用名称捕获，用 $n0 代替 $10(nginx会将$10解释为"$1和0")
rewrite ^/page-(\w+)-(\w+)-(\w+)-(\w+)-(\w+)-(\w+)-(\w+)-(\w+)-(\w+)-(?<n0>\w+)\.html$      /page-$1-$2-$3-$4-$5-$6-$7-$8-$9-$n0.html$
```

# [map](http://nginx.org/en/docs/http/ngx_http_map_module.html#map)
* https://www.cnblogs.com/cangqinglang/p/12174407.html
### 场景： 匹配请求 url 的参数，如果参数是 debug 则设置 $foo = 1 ，默认设置 $foo = 0
* $args 是nginx内置变量，就是获取的请求 url 的参数。 如果 $args 匹配到 debug 那么 $foo 的值会被设为 1 ，如果 $args 一个都匹配不到 $foo 就是default 定义的值，在这里就是 0
```
map $args $foo {
    default 0;
    debug   1;
}
```

### map语法
```
map $var1 $var2 {...}
```
* map 的 $var1 为源变量，通常可以是 nginx 的内置变量，$var2 是自定义变量。 $var2 的值取决于 $var1 在对应表达式的匹配情况。 如果一个都匹配不到则 $var2 就是 default 对应的值。
  * 源变量可以为字符串或正则(~区分大小写，~*不区分大小写)
  * default ： 指定源变量匹配不到任何表达式时将使用的默认值。当没有设置 default，将会用一个空的字符串作为默认的结果。
  * hostnames ：指明source的值是主机名，主机名可包含前缀或后缀(*.example.com或 www.example.* )
  * include ： 包含一个或多个含有映射值的文件。
  * volatile 指明变量不可缓存