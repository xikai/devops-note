#!/bin/bash

backupDir=/data/pgbackup #备份目录设置
pguser=postgres
backup_caps=3 #备份上限天数
TODAY=`date +%Y%m%d`

export PGPASSWORD=repltomtop

if [ ! -d "$backupDir/$TODAY" ]; then
    mkdir -p "$backupDir/$TODAY"
    chown -R ${pguser}.${pguser} "$backupDir/$TODAY"
fi

echo "$(date +%F/%T)开始基础备份"
pg_basebackup -Fp -x --progress -D ${backupDir}/${TODAY}/base-backup -h 172.31.5.166 -U repl
[[ $? = 0 ]] && echo "$(date +%F/%T)备份成功！"
mv /data/pgdata/imgdata ${backupDir}/${TODAY}/base-backup/

echo "删除以下过期的备份文件："
find $backupDir -mindepth 1 -maxdepth 1 -type d -mtime +3 -exec rm -rf {} \;