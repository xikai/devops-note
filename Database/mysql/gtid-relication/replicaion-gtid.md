* https://dev.mysql.com/doc/refman/5.7/en/replication-gtids.htm
* https://www.cxyzjd.com/article/Q274948451/109593530

* 全局事务标识符 (GTID), 是对于一个已提交事务的编号，并且是一个全局唯一的编号,GTID 实际上 是由 UUID+TID 组成的.
   ```
   # UUID 是一个 MySQL 实例的唯一标识。TID 代表了该实例上已经提交的事务数量，并且随着事务提交单调递增
   3E11FA47-71CA-11E1-9E33-C80AA9429562:23
   ```
* GTID 存储在mysql数据库中名为gtid_executed的表中（不要尝试自己创建或修改此表）

# Gtid的工作原理:
1. 当一个事务在主库端执行并提交时，产生GTID，一同记录到binlog日志中。
2. binlog_传输到slave,并存储到slave的relaylog,后，读取这个GTID的这个值设置gtid_next变量，即告诉 Slave，下一个要执行的 GTID值。
3. sql线程从relay log中获取 GTID，然后对比 slave端的binlog是否有该GTID。
4. 如果有记录，说明该GTID的事务已经执行，slave会忽略。
5. 如果没有记录，slave就会执行该GTID事务，并记录该GTID到自身的b在读取执行事务前会先检查其他session持有该GTID，确保不被重复执行。
6. 在解析过程中会判断是否有主键，如果没有就用二级索引，如果没有就用全部扫描。

# 配置gtid主从
### 主库
* 配置开启gtid
```
[mysqld]
server_id = 1
log-bin = mysql-bin
binlog_format =row

gtid_mode=ON
enforce-gtid-consistency = ON
```

* 启动主库
```
/usr/local/mysql/bin/mysqld  --defaults-file=/usr/local/mysql/my.cnf --user=mysql --initialize --basedir=/usr/local/mysql --datadir=/data/mysql/data/
```
* mysql.service
```
cat << EOF > /usr/lib/systemd/system/mysql.service
[Unit]
Description=MySQL Server
After=network.target
After=syslog.target

[Service]
Type=forking
TimeoutSec=0
PermissionsStartOnly=true
ExecStart=/usr/local/mysql/bin/mysqld --defaults-file=/usr/local/mysql/my.cnf --user=mysql --daemonize

Restart=on-failure
RestartPreventExitStatus=1
PrivateTmp=false

[Install]
WantedBy=multi-user.target
/usr/local/mysql/bin/mysql_safe --defaults-file=/usr/local/mysql/my.cnf &
EOF
```
```
systemctl start mysql
```


* 创建复制用户
```
mysql> CREATE USER 'repl'@'172.22.%.%' IDENTIFIED BY 'abc123';
mysql> GRANT REPLICATION SLAVE ON *.* TO 'repl'@'172.22.%.%';
mysql> flush privileges;
```

* 在主库创建新的备份导入从库
>启用gtid之前的备份无法在开启了gtid的实例上恢复
```
# 需要将主库加"读锁定",阻止写操作,确保主从数据一致
mysql> flush tables with read lock; 
```
```
mysqldump >db.sql
```


### 从库
* 配置开启gtid
```sh
[mysqld]
server_id = 2
log-bin = mysql-bin
binlog_format =row

replicate-ignore-db=information_schema
replicate-ignore-db=mysql  #忽略同步mysql，也会同步主库sql创建的用户
replicate-ignore-db=performance_schema
replicate-ignore-db=sys

gtid_mode=ON
enforce-gtid-consistency = ON
```

* 跳过开启同步，启动从库
```
/usr/local/mysql/bin/mysqld --defaults-file=/usr/local/mysql/my.cnf --user=mysql --skip-slave-start --daemonize
```
* 从库设置为使用基于 GTID 的自动定位,同步主库
```
CHANGE MASTER TO
MASTER_HOST='172.22.0.29',
MASTER_PORT=3306,
MASTER_USER='repl',
MASTER_PASSWORD='abc123',
MASTER_AUTO_POSITION=1;
```

* 导入主库备份
```
mysql < db.sql
```

* 启动从库同步
```
start slave;
```


