* https://docs.gethue.com/quickstart/
* https://www.freesion.com/article/8216110109/

# Dependencies
* Python 2.7
* MySQL / MariaDB
```
mysql> CREATE DATABASE hue;
mysql> GRANT ALL PRIVILEGES ON hue.* TO 'hue'@'10.10.%.%' IDENTIFIED BY 'huepasswd';
mysql> flush privileges;
```


# Install
```
wget https://github.com/cloudera/hue/archive/refs/tags/release-4.10.0.tar.gz
tar -xzf release-4.10.0.tar.gz
PREFIX=/usr/local make install
cd /usr/local/hue
```

# [Configuration](https://docs.gethue.com/administrator/configuration/connectors)
```
cp desktop/conf/pseudo-distributed.ini.tmpl desktop/conf/pseudo-distributed.ini
vim desktop/conf/pseudo-distributed.ini
```
```
[desktop]
secret_key=L2bchcwcogfizlwrgc0tvlkingbtmC
http_host=0.0.0.0
http_port=8000

[[database]]
host=10.10.80.65
port=3306
engine=mysql
user=hue
password=huevevor
name=hue

[notebook]
[[interpreters]]

[[[mysql]]]
name=MySQL
interface=sqlalchemy
options='{"url": "mysql://user:password@localhost:3306/hue"}'

[[[presto]]]
name = Presto
interface=sqlalchemy
options='{"url": "presto://localhost:8080/hive/default"}'
```
```
./build/env/bin/pip install mysqlclient
./build/env/bin/pip install pyhive
echo "export LD_LIBRARY_PATH=/usr/local/mysql/lib" >>/etc/profile
```
```
./build/env/bin/hue migrate
```

# Run
```
useradd hue
chown -R hue.hue /usr/local/hue
nohup build/env/bin/supervisor &

/usr/local/hue/build/env/bin/hue runcherrypyserver
```
```
#开发环境（本地localhost启动）
./build/env/bin/hue runserver
```