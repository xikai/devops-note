RMAN恢复目录数据库备份(恢复目录一般在另一台oracle服务器上创建)

#连接到恢复目录数据库,创建恢复目录的用户和权限
sqlplus SYSTEM/oracle@oracle_cata
SQL> create tablespace rman_ts datafile '/u01/app/oradata/oradb1/rman_ts.dbf' size 200m autoextend on next 5000m;
SQL> create user rmanuser identified by "rmanpwd" default tablespace rman_ts;
SQL> grant connect,resource,recovery_catalog_owner to rmanuser;

#连接恢复目录数据库
rman catalog rmanuser/rmanpwd@oracle_cata   #连接本机恢复目录不加@oracle_rman
RMAN> create catalog
RMAN> connect target sys/oracle@oradb1      #connect target sys/oracle@oradb1 catalog rmanuser/rmanpwd@oracle_cata
RMAN> register database;
RMAN> report schema;                        #验证是否成功注册数据库
