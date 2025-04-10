参考文档：http://www.5ienet.com/note/html/rman/index.shtml

RMAN启动数据库上的Oracle服务器进程来进行备份或还原; 备份、还原、恢复是由这些进程驱动的。


#连接本地目标数据库通过控制文件备份数据库
rman target / 

#显示RMAN默认配置
show all;

#设置RMAN备份冗余策略，保留可以恢复到n天以内的任何时间点的数据
configure retention policy to recovery window of n days;

#设置RMAN备份冗余策略，保留的冗余备份副本数量超过n，将废弃最旧的备份
configure retention policy to  redundancy n;

#不设置RMAN备份冗余策略
configure retention policy to none;

#开启自动备份控制文件及备份路径
configure controlfile autobackup on;
configure controlfile autobackup format for device type disk to "/u01/app/backup/ctl_%F";

#设置通道的默认备份路径
configure channel device type disk format '/oracle/orclarch/full_%d_%T_%I_%U';

#恢复RMAN默认设置
configure retention policy clear;
configure device type disk clear;
configure controlfile autobackup clear;
configure controlfile autobackup format for device type disk clear;


#列出相关配置
show channel;
show device type;
show default device type;

#列出所有文件备份信息
list backup of database;

#列出指定表空间的备份信息
list copy of tablespace "SYSTEM";

#列出指定数据文件的备份信息
list backup of datafile '/u01/app/oradata/oradb1/rman_ts.dbf';

#列出控制文件的备份信息
list backup of controlfile;

#查看已备份的归档日志片段
list backup of archivelog all;

#诊断问题
list failure;

#生成有关故障建议
advise failure;



删除备份
#RMAN根据备份冗余策略删除陈旧备份
report obsolete;
delete obsolete; 

#删除EXPIRED备份
delete expired backup;

#删除EXPIRED副本
delete expired copy;

#删除特定备份集
delete backupset 19;

#删除特定备份片
delete backuppiece "d:\backup\DEMO_19.bak";

#删除所有备份集
delete backup;


---------------------------------------------------------------------------------------------------
增量备份
增备是针对数据文件而言，控制文件和归档日志文件不能进行增量备份
#differential差异模式 默认(0=全量备份; 1=差异增量,上次LV0或LV1至今的增量0/1 ~ NOW; 2=累积增量,上次任意级别备份至今的增量0/1/2 ~ NOW)
#cumulative累积模式(0=全量备份; 1=上次全备至今的增量0 ~ NOW; 2=上次0或1级别备份至今的增量0/1~ NOW （differential下的LV1）)
backup incremental level=0 database;  
backup incremental level=2 cumulative database; 


