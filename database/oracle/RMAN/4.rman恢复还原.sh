#spfile丢失:
startup nomount;
set dbid 3988862108;
restore spfile from autobackup;
#restore controlfile from "/u01/app/backup/c-2238399066-20151107-03";
shutdown immediate;
set dbid 3988862108;
startup;


#恢复控制文件controlfile
set dbid 3391142503
restore controlfile from "/u01/app/backup/c-2238399066-20151107-03";
sql "alter database mount";
recover database;
sql "alter database open resetlogs";


#恢复表空间
sql "alter tablespace jweb offline";//如果文件不存在，则用 sql "alter tablespace users offline immeidate";
restore tablespace jweb;
recover tablespace jweb;
sql "alter tablespace jweb online";


#恢复数据文件
sql "alter database datafile 10 offline";
restore datafile 10;
recover datafile 10;
sql "alter database datafile 10 online";


#数据库出现问题，非catalog方式完全恢复(恢复日期最近的备份，恢复优先级：镜像备份大于备份集)
startup nomount;
restore controlfile from autobackup;
alter database mount;
restore database;
recover database;
alter database open resetlogs;


#基于时间点的恢复
run{
set until time "to_date(07/01/02 15:00:00','mm/dd/yy hh24:mi:ss')";
restore database;
recover database;
alter database open resetlogs;
}
ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS';
startup mount;
restore database until time "to_date('2009-7-19 13:19:00','YYYY-MM-DD HH24:MI:SS')";
recover database until time "to_date('2009-7-19 13:19:00','YYYY-MM-DD HH24:MI:SS')";
alter database open resetlogs;