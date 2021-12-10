* https://dev.mysql.com/doc/refman/5.7/en/mysqlslap.html

> Mysqlslap是mysql自带的基准测试工具,该工具可以模拟多个客户端同时并发的向服务器发出查询更新,给出了性能测试数据而且提供了多种引擎的性能比较。mysqlslap为mysql性能优化前后提供了直观的验证依据,系统运维和DBA人员应该掌握一些常见的压力测试工具,才能准确的掌握线上数据库支撑的用户流量上限及其抗压性等问题。


# mysqlslap运行分为三个阶段
1. 使用单个客户端连接，创建用于测试架构的表、存储程序或数据
2. 运行负载测试（可以使用多个客户端）
3. 使用单个客户端连接，清理测试数据（关闭连接、删除测试表数据）


* 提供指定的create、query语句，使用50个客户端query，每个客户端执行200次select（;分号作为sql语句分隔符）
```
mysqlslap --delimiter=";"
  --create="CREATE TABLE a (b int);INSERT INTO a VALUES (23)"
  --query="SELECT * FROM a" --concurrency=50 --iterations=200
```

* 构建包含2个int列和3个varcher列的表，使用5个客户端query，每个客户端执行20次select (不创建和插入数据，使用上面的测试数据)
```
mysqlslap --concurrency=5 --iterations=20
  --number-int-cols=2 --number-char-cols=3
  --auto-generate-sql
```

* 对指定sql文件包含的语句，使用5个客户端query，每个客户端执行5次select（;分号作为sql语句分隔符）
```
mysqlslap --concurrency=5
  --iterations=5 --query=query.sql --create=create.sql
  --delimiter=";"
```

* 参数说明
```
--defaults-file：给定只读选项文件
--concurrency：发出SELECT语句时要模拟的客户机数
--iterations：每个client迭代执行query的次数
--number-int-cols：指定自动生成的测试表中包含多少个数字类型的列，默认1
--number-char-cols：指定自动生成的测试表中包含多少个字符类型的列，默认1
--auto-generate-sql：自动生成测试表和数据
--auto-generate-sql-add-autoincrement：将 AUTO_INCREMENT 列添加到自动生成的表
--auto-generate-sql-load-type：指定测试负载语句类型。允许的值为 read（扫描表）、write（插入到表中）、key（读取主键）、update（更新主键）或 mixed（半插入，半扫描选择）。默认值为mixed
--engine：代表要测试的引擎，可以有多个，用分隔符隔开
--number-of-queries：限制每个client大概的query查询总数
-u：指定连接mysql的用户
-p：指定连接mysql用户的密码
--verbose：显示测试详情
```

* 测试200,250,300个并发线程，测试次数30次，自动生成SQL测试脚本，读、写、更新混合测试，自增长字段，测试引擎为innodb，共运行5000次查询
```
mysqlslap -h10.10.24.34 -uadminroot -pnT1LgHRm7arJIX3y \
--concurrency=200,250,300 --iterations=30 --number-of-queries=5000 \
--number-int-cols=30 --number-char-cols=50 --auto-generate-sql --auto-generate-sql-add-autoincrement \
--engine=innodb
```
```
mysqlslap: [Warning] Using a password on the command line interface can be insecure.
Benchmark
	Running for engine innodb
	Average number of seconds to run all queries: 0.794 seconds    # 200个客户端（并发）同时运行这些SQL语句平均要花0.351秒
	Minimum number of seconds to run all queries: 0.736 seconds
	Maximum number of seconds to run all queries: 0.894 seconds
	Number of clients running queries: 200			# 总共100个客户端（并发）运行这些sql查询
	Average number of queries per client: 25        # 每个客户端（并发）平均运行25次查询（对应--concurrency=200，--number-of-queries=5000；5000/200=25）
```