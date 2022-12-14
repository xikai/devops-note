#一般备份恢复(pg_dump)
pg_dump product > product_20151229.sql
psql product < product_20151229.sql >/dev/null

#gzip压缩备份大数据
pg_dump product |gzip > product.sql.gz
gunzip -c product.sql.gz |psql product >/dev/null

#备份恢复所有数据库
pg_dumpall |gzip > all_20160524.sql.gz
gunzip -c all_20160524.sql.gz |psql >/dev/null

#恢复指定库
pg_dump -h 202.10.76.7 -U kong kong |psql -h 172.22.0.20 -U kong kong

#pg_dump指定存储格式
pg_dump -F t product product.tgz        #tar归档格式转储的不是脚本，不能用于psql，而是需要使用pg_restore恢复
pg_restore -d product product.tgz

#备份表
pg_dump -U tomtop image -t t_file_route > t_file_route.sql
pg_dump -U tomtop image -t t1 -t t2 > ts.sql

#执行SQL文件
psql -d order -f aa.sql


#冷备份恢复(关闭postgres数据库服务，拷贝系统数据文件)
tar -cf backup.tar /usr/local/pgsql/data



# 启用wal归档日志备份
vim postgresql.conf
wal_level = hot_standby
archive_mode = on
# 将WAL日志存在本地 （%p表示wal日志文件的路径，%f表示wal日志文件名称）
# archive_command = 'cp %p /data/pgsql/arch/%f'

#以天为目录存放wal归档日志
# archive_command = 'DATE=`date +%Y%m%d`; DIR="/data/pgsql/arch/$DATE"; (test -d $DIR || mkdir -p $DIR) && cp %p $DIR/%f'  
 
# 将WAL日志存在主从以外的日志服务器(需先建立sshkey认证)
archive_command = 'scp %p postgres@192.168.181.100:/data/pgsql/arch/%f'
archive_command = '/bin/aws s3 cp %p s3://ttbkup/pgsql/archlog/%f' 




# 恢复wal归档日志
vim recovery.conf
# 恢复本地WAL日志
# restore_command = 'cp /data/pgsql/arch/%f %p'
# archive_cleanup_command = 'pg_archivecleanup /data/pgsql/arch %r'      # 清理恢复使用过的wal日志文件(%r由包含最新可用重启点的文件名代替)

#恢复以天为目录存放的wal归档日志
# restore_command = 'scp postgres@192.168.181.100:/data/pgsql/arch/*/%f %p'

# 恢复远程主机wal日志(需先建立sshkey认证)
restore_command = 'scp postgres@192.168.181.100:/data/pgsql/arch/%f %p'
restore_command = '/bin/aws s3 cp s3://ttbkup/pgsql/arch/%f %p'






