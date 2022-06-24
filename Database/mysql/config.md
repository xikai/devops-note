# [innodb_buffer_pool_size](https://dev.mysql.com/doc/refman/5.7/en/innodb-buffer-pool-resize.html)
### 在线修改innodb_buffer_pool_size
1. innodb_buffer_pool_size的值必须是 innodb_buffer_pool_chunk_size * innodb_buffer_pool_instances的倍数或相等
2. 在调整buffer时 要等所有innodb api事务操作要等才调整结束才开始事务，调整期间可以对缓冲区并发访问（但是访问到回收的页面 就会出现短暂页面数据丢失 访问不到）
```
# 查看innodb_buffer_pool_size大小
mysql> select @@INNODB_BUFFER_POOL_SIZE /1024/1024/1024;

# 在线修改innodb_buffer_pool_size
mysql> SET GLOBAL innodb_buffer_pool_size=20*1024*1024*1024;

# 监控在线缓冲池大小调整进度 (缓冲池大小调整进度也记录在服务器错误日志中)
mysql> SHOW STATUS WHERE Variable_name='InnoDB_buffer_pool_resize_status';
```

# [innodb_flush_log_at_trx_commit](https://dev.mysql.com/doc/refman/5.7/en/innodb-parameters.html#sysvar_innodb_flush_log_at_trx_commit)
> 控制事务刷新到redo日志的频率，未刷新日志的事务可能在崩溃时丢失
* innodb_flush_log_at_trx_commit=1（默认值）：在每次事务提交时，将redo日志缓存区的数据写入日志文件中，并且刷新到磁盘中
* innodb_flush_log_at_trx_commit=0：每隔一秒将日志缓存区写到redo日志文件中，并且将redo日志文件的数据刷新到磁盘中
* innodb_flush_log_at_trx_commit=2：在每次事务提交时，将redo日志缓存区的数据写入日志文件中，但并不会同时刷新到磁盘中，而是由MySQL会每秒执行一次刷新磁盘操作


# [sync_binlog](https://dev.mysql.com/doc/refman/5.7/en/replication-options-binary-log.html#sysvar_sync_binlog)
> 控制MySQL服务器将binlog日志同步到磁盘的频率
* sync_binlog=1（默认值）：启用在事务提交之前将二进制日志同步到磁盘，在电源故障或操作系统崩溃的情况下，从二进制日志中丢失的事务只处于准备状态，事务将回滚确保数据不会丢失。这是最安全的设置，但是由于磁盘写操作的增加，可能会对性能产生负面影响。
* sync_binlog=0： 禁用MySQL服务器将binlog日志同步到磁盘,依赖操作系统不时地将二进制日志当作普通文件刷新到磁盘上。这个设置提供最佳性能，但是在断电或系统崩溃时，MySQL服务器可能提交了事务 而没有来得及同步binlog日志文件，导致丢失。
* sync_binlog=N： 收集N个二进制日志提交组后，将二进制日志同步到磁盘。在断电或操作系统崩溃的情况下，服务器可能已经提交了尚未刷新到磁盘的二进制日志的事务。值越高，性能越好，但数据丢失越多。