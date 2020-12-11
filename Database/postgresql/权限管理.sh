https://www.cnblogs.com/zhoujinyi/p/10939715.html

客户端连接访问控制(pg_hba.conf)
----------------------------------------------------------------------------------------------
# "local" is for Unix domain socket connections only
local   all             postgres                                peer  #依赖操作系统用户认证  
local   all             all                                     md5   #密码认证

# IPv4 local connections:
host    all             all             0.0.0.0/0               md5   #postgresql访问控制允许其它主机远程连接

# IPv6 local connections:
host    all             all             ::1/128                 ident

# Allow replication connections from localhost, by a user with the
# replication privilege.
#local   replication     postgres                                peer
#host    replication     postgres        127.0.0.1/32            ident
----------------------------------------------------------------------------------------------

su - postgres -c "/usr/local/pgsql/bin/pg_ctl -D /data/pgsql/data reload"



--------------------------------------------------------------------------------

角色：
#创建删除角色
CREATE ROLE name;
DROP ROLE name;

#查询角色
\du

1. 登录权限：
只有具有LOGIN属性的角色才可以用于数据库连接，因此我们可以将具有该属性的角色视为登录用户
CREATE ROLE name LOGIN PASSWORD '123456';

2. 超级用户：
数据库的超级用户拥有该数据库的所有权限，为了安全起见，我们最好使用非超级用户完成我们的正常工作。和创建普通用户不同，创建超级用户必须是以超级用户的身份执行以下命令：
CREATE ROLE name SUPERUSER;

3. 创建数据库：
角色要想创建数据库，必须明确赋予创建数据库的属性，见如下命令：
CREATE ROLE name CREATEDB;

4. 创建角色：
一个角色要想创建更多角色，必须明确给予创建角色的属性，见如下命令：
CREATE ROLE name CREATEROLE;

5.启动复制：
角色要想启动流复制，必须明确给出权限。 用于流复制的角色必须总是拥有LOGIN权限。要创建这样的角色
CREATE ROLE name REPLICATION LOGIN

6.权限继承
用户是否继续该角色的权限，默认INHERIT继承
CREATE ROLE name NOINHERIT

####
CREATE USER/ROLE name [ [ WITH ] option [ ... ] ]  : 关键词 USER,ROLE； name 用户或角色名； 

where option can be:

      SUPERUSER | NOSUPERUSER      :超级权限，拥有所有权限，默认nosuperuser。
    | CREATEDB | NOCREATEDB        :建库权限，默认nocreatedb。
    | CREATEROLE | NOCREATEROLE    :建角色权限，拥有创建、修改、删除角色，默认nocreaterole。
    | INHERIT | NOINHERIT          :继承权限，可以把除superuser权限继承给其他用户/角色，默认inherit。
    | LOGIN | NOLOGIN              :登录权限，作为连接的用户，默认nologin，除非是create user（默认登录）。
    | REPLICATION | NOREPLICATION  :复制权限，用于物理或则逻辑复制（复制和删除slots），默认是noreplication。
    | BYPASSRLS | NOBYPASSRLS      :安全策略RLS权限，默认nobypassrls。
    | CONNECTION LIMIT connlimit   :限制用户并发数，默认-1，不限制。正常连接会受限制，后台连接和prepared事务不受限制。
    | [ ENCRYPTED ] PASSWORD 'password' | PASSWORD NULL :设置密码，密码仅用于有login属性的用户，不使用密码身份验证，则可以省略此选项。可以选择将空密码显式写为PASSWORD NULL。
                                                         加密方法由配置参数password_encryption确定，密码始终以加密方式存储在系统目录中。
    | VALID UNTIL 'timestamp'      :密码有效期时间，不设置则用不失效。
    | IN ROLE role_name [, ...]    :新角色将立即添加为新成员。
    | IN GROUP role_name [, ...]   :同上
    | ROLE role_name [, ...]       :ROLE子句列出一个或多个现有角色，这些角色自动添加为新角色的成员。 （这实际上使新角色成为“组”）。
    | ADMIN role_name [, ...]      :与ROLE类似，但命名角色将添加到新角色WITH ADMIN OPTION，使他们有权将此角色的成员资格授予其他人。
    | USER role_name [, ...]       :同上
    | SYSID uid                    :被忽略，但是为向后兼容性而存在。



#修改角色属性
ALTER ROLE name RENAME TO new_name
ALTER ROLE name PASSWORD '111111';

ALTER ROLE name
SUPERUSER | NOSUPERUSER
| CREATEDB | NOCREATEDB
| CREATEROLE | NOCREATEROLE
| CREATEUSER | NOCREATEUSER
| INHERIT | NOINHERIT
| LOGIN | NOLOGIN
| REPLICATION | NOREPLICATION
| CONNECTION LIMIT connlimit
| [ ENCRYPTED | UNENCRYPTED ] PASSWORD 'password'
| VALID UNTIL 'timestamp' 



--------------------------------------------------------------------------------
权限管理：
PostgreSQL中预定义了许多不同类型的内置权限，如：SELECT、INSERT、UPDATE、DELETE、RULE、REFERENCES、TRIGGER、CREATE、TEMPORARY、EXECUTE和USAGE。

查看角色权限
select * from pg_roles;


###授权http://www.postgres.cn/docs/10/sql-grant.html
GRANT SELECT ON database TO role;
GRANT ALL ON database TO PUBLIC;
GRANT rolename TO user;
GRANT rolename1 TO rolename2;

REVOKE ALL ON database FROM PUBLIC;


#为用户角色授予指定库表只读权限
1,创建角色web
CREATE ROLE web LOGIN PASSWORD '123456';

2,为角色web授权privetest库所有表只读权限
\c privtest;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO web;

3,为角色web授权base库所有表table1只读权限
\c base;
GRANT SELECT ON table1 TO web;

#设置用户只读属性
create user tomtopro superuser password 'ttro@tomtop.com';
alter user tomtopro set default_transaction_read_only = on;





