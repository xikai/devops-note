# 实现原理
* 主服务器在接受到每个事务请求时，将数据改动用预写日志(WAL)记录。具体而言，事务采用两段提交(Two Phase Commit)，即先将改动写入预写日志，然后再实际改动数据库。这样可以保证预写日志的时间戳永远不落后于数据库，即便是正在写入时服务器突然崩溃，重启以后也可以依据预写日志将数据恢复，因为预写日志保留了比数据库记录中更新的版本。PostgreSQL的异步复制解决方案正是利用了预写日志，将预写日志从主服务器(Master Sever)传输到备用服务器(Standby Server)，然后在备用服务器上回放(Replay)出预写日志中记录改动，从而实现主从复制。PostgreSQL使用了两种方式传输预写日志：存档式(archive)和流式(streaming)。
* 存档式复制的原理是主服务器将预写日志主动拷贝到一个安全的位置（可以直接到备用服务器，也可以是第三台服务器），同时备用服务器定期扫描这个位置，并将预写日志拷贝到备用服务器端然后再回放。这样即使主服务器崩溃了，备用服务器也可以从这个安全的位置获取到一份完整的记录，以确保任何数据不会丢失。而流式复制则简化了这一个步骤，由主服务器直接通过TCP协议向备用服务器传输日志，避免了两次复制的开销，有利于减小备用服务器和主服务器直接的数据延时。但当主服务器崩溃时，未被传输到备用服务器的日志则会丢失，造成数据损失。PostgreSQL支持存档式和流式两种模式的混合，当两种模式都开启时，备用服务器会定期检查是否有存档已经到达指定的位置，并回放日志。一旦检测到指定的位置没有新的日志，则会切换到流式模式试图直接从网络传输日志，接着再检查存档，不断重复这一循环。



# 主服务器:
* 创建复制用户
```
su - postgres
postgres# CREATE ROLE repl login replication encrypted password 'repl';
```
* vim /data/pgsql/data/pg_hba.conf
```
host    replication     repl             192.168.181.129/32         md5                                    
```

* vim /data/pgsql/data/postgresql.conf
```
listen_addresses = '192.168.181.128'
max_connections = 1000         #这个设置要注意下，从库的max_connections必须要大于主库的
wal_level = hot_standby      #这个是设置主为wal的主机
max_wal_senders = 5         #这个设置了可以最多有几个流复制连接，差不多有几个从，就设置几个
wal_keep_segments = 64         #设置流复制保留的最多的xlog数目
wal_sender_timeout = 60s     #设置流复制主机发送数据的超时时间
```
```
/usr/local/pgsql/bin/pg_ctl -D /data/pgsql/data restart
```


# 从服务器：
```
#基础备份同步主库
su - postgres
mv /data/pgsql/data /data/pgsql/data.bak
mkdir /data/pgsql/data
chown -R postgres.postgres /data/pgsql
/usr/local/pgsql/bin/pg_basebackup -Fp -Xs --progress -D /data/pgsql/data -h 192.168.181.128 -U repl
-D 将基础备份放到/data/pgsql/data 
-F备份输出格式，p无格式（默认），t在指定目录中输出tar文件
-X 参数，在备份完成之后，会到主库上收集 pg_basebackup 执行期间产生的 WAL 日志，
-Xf在备份结束时收集事务日志文件。 -Xs 即stream 形式，这种模式不需要收集主库的 WAL 文件，而能以 stream 复制方式直接追赶主库
```

* tcp连接主库流复制同步
>cp /usr/local/pgsql/share/recovery.conf.sample /data/pgsql/data/recovery.conf
```
# vim /data/pgsql/data/recovery.conf
standby_mode = on 
primary_conninfo = 'host=192.168.181.128 port=5432 user=repl password=repl'
#恢复到最新的归档数据（或恢复到指定时间点recovery_target_timeline = '2016-04-21 14:49:14'）
recovery_target_timeline = 'latest'   
archive_cleanup_command = 'pg_archivecleanup /data/pgsql/arch/* %r' #清理恢复过的wal日志文件
```

# 从库配置
```
cp /data/pgsql/data.bak/pg_hba.conf /data/pgsql/data/
cp /data/pgsql/data.bak/postgresql.conf /data/pgsql/data/
```
* vim /data/pgsql/data/postgresql.conf
```
max_connections = 1000                 # 一般查多于写的应用从库的最大连接数要比较大
hot_standby = on                       # 说明这台机器不仅仅是用于数据归档，也用于数据查询
```
```
/usr/local/pgsql/bin/pg_ctl -D /data/pgsql/data restart
```

# 查看复制状态：
```
#主库执行
ps aux |grep sender
postgres=# select * from pg_stat_replication;

#从库执行
ps aux |grep receiver
```
