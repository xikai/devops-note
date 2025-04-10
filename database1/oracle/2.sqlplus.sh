#修改SQL*PLUS提示符
SQL> set sqlprompt "_user'@'_connect_identifier>";
注：将上面命令放在ORACLE_HOME/sqlplus/admim/glogin.sql中自动设置sqlprompt


#执行sql语句
SQL> select username,user_id from dba_users;

#执行缓存区语句
SQL> /

#列出sqlplus缓存区
SQL> list
  1* select username,user_id from dba_users


#在缓存区最后一条语句附加语句文本(append后面两个空格)  
SQL> append  order by username;
  1* select username,user_id from dba_users order by username  


#替换缓存区文本
SQL> change /user_id/password/;
  1* select username,password from dba_users


#在缓存区添加一行
SQL> input order by username;  


#删除缓存区指定行  
SQL> del 2


#清空缓存区
SQL> clear buffer;


#将缓存区内容保存到文件
SQL> save sqlbuff.txt;


#通过sqlplus运行指定指定文件中的sql语句
SQL> start sqlbuff.txt;


#替换字段名，显示字符别名
SQL> column username heading 用户名;
SQL> select username,user_id from dba_users;

用户      USER_ID
------------------------------ ----------
MGMT_VIEW                              74
SYS                                     0
SYSTEM                                  5
DBSNMP                                 30
SYSMAN                                 72
OUTLN                                   9
FLOWS_FILES                            75
MDSYS                                  57
ORDSYS                                 53
EXFSYS                                 42
WMSYS                                  32



#显示，设置每页显示多少行
SQL> show pagesize;
SQL> set pagesize 10;

#显示，设置每行显示多少字符
SQL> show linesize;
SQL> set linesize 80;


#是否显示查询所用时间
SQL> set timing on





