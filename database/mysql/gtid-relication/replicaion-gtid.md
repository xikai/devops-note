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
mysqldump > db.sql
```


### 从库
* 配置开启gtid
```sh
[mysqld]
server_id = 2
log-bin = mysql-bin
binlog_format =row

replicate-ignore-db=information_schema
replicate-ignore-db=mysql  #忽略同步mysql，也会同步主库DDL sql创建的用户
replicate-ignore-db=performance_schema
replicate-ignore-db=sys

gtid_mode=ON
enforce-gtid-consistency = ON
```

* 跳过开启同步，启动从库
```
/usr/local/mysql/bin/mysqld --defaults-file=/usr/local/mysql/my.cnf --user=mysql --skip-slave-start --daemonize
```

* 导入主库备份文件（带GTID）
```
# gunzip -f < 10.10.26.114_220331030001.sql.gz |mysql -uroot -p
ERROR 1840 (HY000) at line 24: @@GLOBAL.GTID_PURGED can only be set when @@GLOBAL.GTID_EXECUTED is empty.
```
* 清除master信息
```
mysql -uroot -p
>reset master;
```
```
gunzip -f < 10.10.26.114_220331030001.sql.gz |mysql -uroot -p
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

* 启动从库同步
```
start slave;
```


# 查看主从同步延时
* master
```sh
mysql> show master status\G;
*************************** 1. row ***************************
File: ******-bin.001291    #主库当前binlog文件
Position: 896711460        #主库当前Position
Binlog_Do_DB: 
Binlog_Ignore_DB: 
1 row in set (0.00 sec)
```
* slave
```sh
mysql> show slave status\G;
*************************** 1. row ***************************
Slave_IO_State: Waiting for master to send event
Master_Host: 10.69.6.163
Master_User: replica
Master_Port: 3801
Connect_Retry: 60
Master_Log_File: *****-bin.001211         #从库IO线程，当前读取的binlog文件
Read_Master_Log_Pos: 278633662            #从库IO线程，当前读取的binlog位置
Relay_Log_File: *****-relay-bin.002323    #从库SQL线程，当前执行的binlog文件
Relay_Log_Pos: 161735853                  #从库SQL线程，当前执行的binlog位置
Relay_Master_Log_File: *******-bin.001211 #从库SQL线程，最近执行的binlog文件
Slave_IO_Running: Yes
Slave_SQL_Running: Yes
Replicate_Do_DB: 
Replicate_Ignore_DB: 
Replicate_Do_Table: 
Replicate_Ignore_Table: 
Replicate_Wild_Do_Table: 
Replicate_Wild_Ignore_Table: 
Last_Errno: 0
Last_Error: 
Skip_Counter: 0
Exec_Master_Log_Pos: 278633662
Relay_Log_Space: 161735853
Until_Condition: None
Until_Log_File: 
Until_Log_Pos: 0
Master_SSL_Allowed: No
Master_SSL_CA_File: 
Master_SSL_CA_Path: 
Master_SSL_Cert: 
Master_SSL_Cipher: 
Master_SSL_Key: 
Seconds_Behind_Master: 0    #网络正常情况下，从库与主库binlog位置的时间差（单位：秒）。本质上 是从库SQL线程和IO线程之间的时间差，当网络环境特别糟糕的情况下，这个值确会让我们产生幻觉，I/O thread同步很慢，每次同步过来，SQL thread就能立即执行，这样，我们看到的Seconds_Behind_Master是0，而真正的，slave已经落后master很多很多，需要查看主库上的binlog和Position来判断真实延时情况     
1 row in set (0.00 sec)
```