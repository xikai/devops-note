* https://www.postgresql.org/download/linux/redhat/
* http://www.postgres.cn/v2/document

##源码安装
mkdir -p /data/pgsql/data
useradd -d /data/pgsql/data postgres
chown -R postgres.postgres /data/pgsql

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





