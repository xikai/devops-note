# 安装jq
```
1.使用包管理器（例如 apt、yum、dnf 等）：
$ apt install jq   # 适用于 Ubuntu、Debian 和类似软件
$ yum install jq   # 适用于 CentOS、Fedora 等
$ dnf install jq   # 适用于 Fedora 22 及更高版本

2.使用二进制包安装程序：
$ curl --remote-name https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 
$ chmod +x jq-linux64 
$ mv jq-linux64 /usr/local/bin/jq
```

# jq过滤器
* 过滤jq器是一组说明jq如何处理输入的 JSON 数据的指令。过滤器是用 的领域特定语言 (DSL) 编写的，由一个或多个表达式jq组成。jq
jq支持多种过滤器类型，可用于选择、提取和修改 JSON 数据，常见的有：
  - 选择器：选择 JSON 数据的特定部分。
  - 函数：内置函数，可用于对输入的 JSON 数据执行各种操作。
  - 运算符：用于对输入的 JSON 数据执行数学、逻辑和比较运算。
  - 管道：用于将多个过滤器连接在一起，其中一个过滤器的输出作为输入传递给下一个过滤器。

* 最简单的过滤器是. 它接受输入并将其作为输出不加改变地生成。
```
$ echo '{"name": "knowclub", "age": 100}' | jq .
{
  "name": "knowclub",
  "age": 100
}
```
* 基于对象标识符索引的过滤器：
```
$ echo '{"foo": 42, "bar": "less interesting data"}'  | jq '.foo'
42
```
* 提取数组元素：
```
$ echo  '[1, 2, 3]' | jq '.[1]'
 2
```
* 获取数组的长度：
```
$ echo '[1, 2, 3]' | jq 'length'
3
```
* 提取一个对象的所有键：
```
$ echo '{"name": "knowclub", "age": 100}' | jq 'keys'
[
  "age",
  "name"
]
```
* 提取对象数组中键的值：
```
$ echo '[{"name": "knowclub", "age": 100}, {"name": "Jane", "age": 25}]' | jq '.[].name'
"knowclub"
"Jane"
```

# jq的数据类型
* jq支持多种类型的数据，包括：
  - 数字：整数和浮点值，例如 42、3.14 和 -2。
  - 字符串：用双引号括起来的文本，例如“hello world”。
  - 布尔值：真和假。
  - 数组：用方括号括起来的值列表，例如 [1, 2, 3]。
  - 对象：用花括号括起来的键值对，例如 {“name”: “Tony”, “age”: 100}。
  - Null：特殊值 null。

# jq的条件和比较
>jq支持多种类型的条件和比较运算符，可用于过滤器中以从 JSON 文件中提取或操作特定值：
* 等式 ( ==) 和不等式 ( !=)：
```
$ cat file.json | jq '.[] | select(.name == "knowclub")'
```
* 大于 ( >) 小于 ( <)：
```
$ cat file.json | jq '.[] | select(.age > 100)'
```
* 大于或等于 ( >=) 且小于或等于 ( <=)：
```
$ cat file.json | jq '.[] | select(.age >= 100)'
```
* and和or
```
$ cat file.json | jq '.[] | select(.age > 100 and .gender == "male")'
$ cat file.json | jq '.[] | select(.age > 100 or .gender == "female")'
```

# jq的正则表达式
### select 操作可以用于过滤输入中的元素，并根据给定的条件返回结果
```
jq -n '"a b" | test("a\\sb"; "x")'
```

* 

* 查询aws ip-ranges中region为us-west-2，service为S3的地址段
* [aws-ip-syntax](https://docs.aws.amazon.com/zh_cn/vpc/latest/userguide/aws-ip-ranges.html#aws-ip-syntax)
```
curl -s https://ip-ranges.amazonaws.com/ip-ranges.json |jq '.prefixes[] | select(.region=="us-west-2") | select(.service |test("^S3$"))'
```

# 参考文档
* https://jqlang.github.io/jq/manual/
