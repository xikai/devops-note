\l                          列出库(加 "+" 获取更多信息)
\c                          切换库
\d[t|i|s]                   列出表/索引/序列
\d                          列出表结构
\du                         列出用户 
\x  在行或列扩展输出之间切换 (类似mysql  \G)
\a 在非对齐和对齐的输出模式之间切换

#当前活动连接数
select count(1) from pg_stat_activity;
#当前活动明细连接数
select datname,pid,usename,application_name,waiting,state,query from pg_stat_activity;
#最大连接数
show max_connections;


查看Postgresql的连接状况：
ps aux |grep postgres
select * from pg_stat_activity;



查看主从复制状态：SELECT * from pg_stat_replication; 
查看主从状态：SELECT * from pg_is_in_recovery();
暂停/恢复主从复制：
pg_xlog_replay_pause()；
pg_xlog_replay_resume()；


查看数据库系统参数
1、设置执行超过指定秒数的sql语句输出到日志 ：log_min_duration_statement = 3
2、查看客户端编码：show client_encoding;


查询当前SQL线程（类似show processlist）
--------------------------------------------------------------------------------
 SELECT 
    procpid, 
    start, 
    now() - start AS lap, 
    current_query 
FROM 
    (SELECT 
        backendid, 
        pg_stat_get_backend_pid(S.backendid) AS procpid, 
        pg_stat_get_backend_activity_start(S.backendid) AS start, 
       pg_stat_get_backend_activity(S.backendid) AS current_query 
    FROM 
        (SELECT pg_stat_get_backend_idset() AS backendid) AS S 
    ) AS S 
WHERE 
   current_query <> '<IDLE>' 
ORDER BY 
   lap DESC;


procpid：进程ID
start：进程开始时间
lap：经过时间
current_query：执行中的sql

#杀死进程的方法
SELECT pg_cancel_backend(进程ID);# 只能kill查询的语句
select  pg_terminate_backend(进程ID)#可以kill各种DML
kill -9 进程ID;


