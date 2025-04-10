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
> 控制MySQL服务器将事务日志ib_logfile:(记录的是redo log和undo log的信息)刷新到磁盘的频率
* innodb_flush_log_at_trx_commit=1（默认值：为了完全符合ACID[原子性、一致性、隔离性和持久性的缩写]）：每次事务提交的时候，都把log buffer刷到文件系统中(os buffer)去，并且调用文件系统的“flush”操作将缓存刷新到磁盘上去
* innodb_flush_log_at_trx_commit=0：表示每隔一秒把log buffer刷到文件系统中(os buffer)去，并且调用文件系统的“flush”操作将缓存刷新到磁盘上去。也就是说一秒之前的日志都保存在日志缓冲区，也就是内存上，如果机器宕掉，可能丢失1秒的事务数据
* innodb_flush_log_at_trx_commit=2：每次事务提交的时候会把log buffer刷到文件系统中去，但并不会立即刷写到磁盘，如果只是MySQL数据库挂掉了，由于文件系统没有问题，那么对应的事务数据并没有丢失。只有在数据库所在的主机操作系统损坏或者突然掉电的情况下，数据库的事务数据可能丢失1秒之类的事务数据


# [sync_binlog](https://dev.mysql.com/doc/refman/5.7/en/replication-options-binary-log.html#sysvar_sync_binlog)
> 控制MySQL服务器将binlog日志同步到磁盘的频率
* sync_binlog=1（默认值）：启用在事务提交之前将二进制日志同步到磁盘，在电源故障或操作系统崩溃的情况下，从二进制日志中丢失的事务只处于准备状态，事务将回滚确保数据不会丢失。这是最安全的设置，但是由于磁盘写操作的增加，可能会对性能产生负面影响。
* sync_binlog=0： 禁用MySQL服务器将binlog日志同步到磁盘,依赖操作系统不时地将二进制日志当作普通文件刷新到磁盘上。这个设置提供最佳性能，但是在断电或系统崩溃时，MySQL服务器可能提交了事务 而没有来得及同步binlog日志文件，导致丢失。
* sync_binlog=N： 收集N个二进制日志提交组后，将二进制日志同步到磁盘。在断电或操作系统崩溃的情况下，服务器可能已经提交了尚未刷新到磁盘的二进制日志的事务。值越高，性能越好，但数据丢失越多。