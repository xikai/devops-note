闪回数据库：在用户操作错误后，进行回退数据库到错误操作之前


配置闪回数据库
#查看数据库日志模式
select log_mode from v$database;

#设置为归档模式
1,alter system set log_archive_start=true scope=spfile;
2,shutdown immediate;
3,startup mount;
4,alter database archivelog;

#查看闪回恢复区目录及闪回恢复区大小限制
show parameter db_recovery_file_dest;

#设置闪回恢复区
alter system set db_recovery_file_dest='/u01/app/flash_recovery_area';
alter system set db_recovery_file_dest_size=20G;

#设置闪回保留目标时间(分钟)
alter system set db_flashback_retenion_target=240;

#启用闪回日志记录
shutdown immediate;
startup mount;
alter database flashback on;
alter database open;

#查看是否启用闪回
select flashback_on from v$database;




使用闪回数据库
shutdown abort;
startup mount;
flashback dadtabase to timestamp to_timestamp('20-12-15 10:00:00' 'hh24:mi:ss');
alter dadtabase open read only;

可以针对删除模式进行查询

shutdown abort;
startup mount;
flashback dadtabase to timestamp to_timestamp('20-12-15 10:01:00' 'hh24:mi:ss');
alter dadtabase open read only;

shutdown abort;
startup mount;
alter dadtabase open resetlogs;



#禁止指定对象生成闪回数据
alter tablespace tablespace_name flashback off;
select name,flashback_on from v$tablespace;



闪回删除的表
#查询用户回收站(查看删除的表是否还存在回收站)
select * from USER_RECYCLEBIN;
show recyclebin;

#闪回删除的表
flashback table table_name to before drop;


#删除表并不移到回收站
purge table table_name;