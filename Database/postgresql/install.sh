yum install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
yum install postgresql10
yum install postgresql10-server

/usr/pgsql-10/bin/postgresql-10-setup initdb
systemctl enable postgresql-10
systemctl start postgresql-10

#或自定义数据目录
mkdir /data/pgsql/data
chown -R postgres.postgres /data/pgsql
su - postgres
/usr/pgsql-10/bin/initdb -D /data/pgsql/data
pg_ctl -D /data/pgsql/data start

#第一次登陆(空密码，postgres用户登陆）
sudo su - postgres -c "psql"


-------------------------------------------------------------------------
##源码安装
mkdir -p /data/pgsql/data
useradd postgres -d /data/pgsql/data
chown -R postgres.postgres /data/pgsql

wget https://ftp.postgresql.org/pub/source/v9.4.5/postgresql-9.4.5.tar.gz
tar -xzf postgresql-9.4.5.tar.gz
cd postgresql-9.4.5
./configure --prefix=/usr/local/pgsql
gmake
gmake install

su - postgres
/usr/local/pgsql/bin/pg_ctl -D /data/pgsql/data initdb
/usr/local/pgsql/bin/pg_ctl -D /data/pgsql/data start

/usr/local/pgsql/bin/createdb test
/usr/local/pgsql/bin/psql test



-------------------------------------------------------------
#源码安装额外扩展（例如：dblink）
cd /usr/local/src/postgresql-9.2.10/contrib/dblink
make
make install

postgres=# CREATE EXTENSION dblink;


#查看当前库安装的额外扩展
select extname,extversion from pg_extension;





