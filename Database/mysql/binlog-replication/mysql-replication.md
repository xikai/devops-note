* https://dev.mysql.com/doc/refman/5.7/en/replication-howto.html

# 主服务器
1. 在主服务器上为从服务器创建一个用来同步的用户，指定只允许从192.168.1.17（mysql slave）登陆
```
mysql> grant replication slave on *.* to repl@192.168.1.17 identified by 'repl';
```

2. 修改主mysql主配置文件(需要重启服务生效)
```
cp /usr/local/mysql/my.cnf /usr/local/mysql/my.cnf.bak
```
* vim /usr/local/mysql/my.cnf
```
###在[mysqld]段中加上增加以下内容
server_id=1              ###服务器id号(一般为IP结尾段)
log-bin=mysql-bin        ###打开二进制日志
#binlog-do-db=abc        ###只为abc库记录binlog，其他库不记录
#binlog-ignore-db=mysql  ###忽略mysql库不记录binlog，其它库都记录(与binlog-do-db任选一个即可,两个参数都不写时默认记录所有库binlog)
```
3. 需要将主库加"读锁定",阻止写操作,确保主从数据一致
```
flush tables with read lock; 
```

4. 记录主库position, 让从库从这个position点开始进行数据同步
```
show master status;
```

5. mysqldump导出主库到从库,如果使用--master-data参数则不用执行第3)步锁表操作
```
mysqldump --all-databases --flush-logs --hex-blob --master-data=2 |gzip > d.sql.gz

#拷贝物理文件比dump更快
```

6.  解锁恢复写操作
```
unlock tables;
```


# 从服务器 
```
cp /usr/local/mysql/my.cnf /usr/local/mysql/my.cnf.bak
```
2. 修改从mysql配置文件
>vim /usr/local/mysql/my.cnf
```
[mysqld]
server-id               = 2
#replicate-do-db        = abc           ###指定复制的数据库，其它都不复制
replicate-ignore-db     = mysql       ###指定不复制的数据库其他都复制(与replicate-do-db任选一个即可,两个参数都不写时默认复制所有库)
```

3. 将主库数据拷贝过来解压，，如果有innodb表，需要删除ib_logfile*日志文件，否则同步时会提示Unknown table engine 'InnoDb'

4. 跳过slave IO线程启动从库 使之不要去同步主库
```
/usr/local/mysql/bin/mysqld_safe --defaults-file=/usr/local/mysql/my.cnf --skip-slave-start &
```
5. 连接从库控制台，手动指定要同步的主库
```
CHANGE MASTER TO
MASTER_HOST='192.168.0.224',
MASTER_PORT=3306,
MASTER_USER='repl',
MASTER_PASSWORD='repl',
MASTER_LOG_FILE='mysql-bin.000039',
MASTER_LOG_POS=102;
```

6. 启动slave线程
```
start slave;
```

7. 查看从服务器同步信息
```
mysql> show slave status;            #show slave status 参数详解：http://blog.chinaunix.net/uid-12115233-id-2853589.html
```


* 跳过错误：
```
stop slave;
set global sql_slave_skip_counter=错误id;
start slave;
show slave status\G;
```





 