* install mysql
```
groupadd mysql
useradd -r -g mysql -s /bin/false mysql
mkdir -p /data/mysql/{data,logs}
chown -R mysql.mysql /data/mysql
```
```
wget https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.35-linux-glibc2.12-x86_64.tar.gz
tar -xzf mysql-5.7.35-linux-glibc2.12-x86_64.tar.gz -C /usr/local
cd /usr/local
ln -s ./mysql-5.7.35-linux-glibc2.12-x86_64 mysql

mkdir -p /usr/local/mysql/etc
chown -R mysql.mysql /usr/local/mysql

echo "export PATH=$PATH:/usr/local/mysql/bin" >>/etc/profile
source /etc/profile
```

* vim /usr/local/mysql/etc/my.cnf
```
[client]
port = 3306
socket = /tmp/mysql.sock
default-character-set = utf8

[mysqld]
port = 3306
bind-address = 0.0.0.0
socket = /tmp/mysql.sock
basedir = /usr/local/mysql
datadir = /data/mysql/data
log-error = /data/mysql/logs/mysql-err.log
pid-file = /usr/local/mysql/mysql.pid
character_set_server = utf8

server-id = 1
log-bin = /data/mysql/data/mysql-bin
binlog_format = row
gtid_mode = ON
enforce-gtid-consistency = ON
replicate-ignore-db=information_schema
replicate-ignore-db=performance_schema
replicate-ignore-db=sys


[mysqldump]
quick
max_allowed_packet = 1024M
net_buffer_length = 512k

[myisamchk]
key_buffer_size = 128M
sort_buffer_size = 20M
#read_buffer = 20M
#write_buffer = 20M

[mysqlhotcopy]
interactive-timeout
```

* init mysql
```
/usr/local/mysql/bin/mysqld  --defaults-file=/usr/local/mysql/etc/my.cnf --user=mysql --initialize --basedir=/usr/local/mysql --datadir=/data/mysql/data/
```
```
# grep password /data/mysql/logs/mysql-err.log
2021-11-22T11:37:22.006929Z 1 [Note] A temporary password is generated for root@localhost: nHqeq4+93O7r
```

* mysql.service
```
cat > /usr/lib/systemd/system/mysql.service << EOF
[Unit]
Description=MySQL Server
After=network.target
After=syslog.target

[Service]
Type=forking
TimeoutSec=0
PermissionsStartOnly=true
ExecStart=/usr/local/mysql/bin/mysqld --defaults-file=/usr/local/mysql/etc/my.cnf --user=mysql --daemonize

Restart=on-failure
RestartPreventExitStatus=1
PrivateTmp=false

[Install]
WantedBy=multi-user.target
EOF
```
```
systemctl start mysql
```


* 修改密码
```
# reset password
alter user 'root'@'localhost' identified by '123456';
```


# show processlist
* Command
```
Sleep 就是做完动作，还没有 timeout 的连接

```