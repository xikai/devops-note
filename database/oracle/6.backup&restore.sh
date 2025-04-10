物理备份（复制文件）
冷备份（非归档模式）
shutdown数据库，复制数据文件和控制文件



热备份（归档模式）
在数据库归档模式下进行备份，联机备份
#查看数据库日志状态
SQL> select log_mode from v$database;
SQL> archive log list;
Database log mode              No Archive Mode
Automatic archival             Disabled
Archive destination            USE_DB_RECOVERY_FILE_DEST
Oldest online log sequence     37
Current log sequence           39

#设置为归档模式
shutdown immediate;
startup mount;
alter database archivelog;
alter system set log_archive_start=true scope=spfile;  #oracle 9i需要设置
select log_mode from v$database;
alter database open;

#备份TEST表空间数据
alter tablespace TEST begin backup;
找开oradata文件夹复制文件
alter tablespace TEST end backup;

#恢复数据文件
alter database datafile 10 offline drop;
alter database open;
recover datafile 10;
alter database datafile 10 online;




#逻辑备份与恢复
exp system/oracle inctype=complete file=040731.dmp tables=productinfo
exp system/oracle inctype=complete file=040731.dmp tablespace='tablespace_name'

imp system/oracle file=040731.dmp tables=productinfo