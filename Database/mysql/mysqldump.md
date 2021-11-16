# 备份库
```
# 数据和结构
mysqldump -uroot -p dbname > dbname.sql

#备份多个库
mysqldump -uroot -p --databases dbname1 dbname2 > dbname1-dbname2.sql

#备份所有库
mysqldump -uroot -p --all-databases > db.sql
```

# 备份表
```
mysqldump -uroot -p dbname table_name > dbname_table_name.sql
```

# 其它参数
```
#-d ,--no-data 仅备份数据库表结构
mysqldump -uroot -p -d dbname > dbname.sql
mysqldump -uroot -p -d dbname table_name > dbname_table_name.sql

--force 在导出过程中忽略出现的SQL错误

--set-gtid-purged=OFF 在导出过程中忽略gtid

--ignore-table 不导出指定表。指定忽略多个表时，需要重复多次，每次一个表。每个表必须同时指定数据库和表名。例如：--ignore-table=database.table1 --ignore-table=database.table2

--lock-all-tables 在mysqldump导出的整个过程中以read方式锁住整个实例所有库所有表（锁住方式类似 flush tables with read lock 的全局锁）数据库严格处于read only状态，这相当于脱机备份的感觉，所以导出的数据库在数据一致性上是被严格保证的，也就是数据是一致性的 (默认为off)。

--lock-tables 在mysqldump导出的整个过程中以read方式锁住当前正在导出库的所有表(默认开启)

--master-data 会自动关闭 --lock-tables，打开 --lock-all-tables；可用于设立另一台服务器作为master的slave,在把dump文件导入到slave之后，slave应当从该master坐标开始复制。
--master-data=1 在dump过程中记录主库的binlog和pos点，并在dump中不注释这一行，即恢复时执行；配置主从无需再指定主库binlog文件名和位置（默认值为1）
--master-data=2 在dump过程中记录主库的binlog和pos点，并在dump中注释这一行，配置主从需要指定主库binlog文件名和位置

--single-transaction 保证各个表具有数据一致性快照，mysqldump对该表的导出过程中对该表加只读锁，会自动关闭--lock-tables默认在导出库时对整个库的表加只读锁

--max_allowed_packet 服务器发送和接受的最大包长度(当导出的数据量大时需要设置)
```
```
mysqldump --help
```