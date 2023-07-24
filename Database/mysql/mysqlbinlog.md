* https://dev.mysql.com/doc/refman/5.7/en/mysqlbinlog.html

# 通过起始和结束位置恢复binlog数据
```
mysqlbinlog --start-position=219 --stop-position=982 mysql-bin.000001 |mysql -uroot -p123456
```
# 通过时间范围恢复binlog数据
```
mysqlbinlog --start-datetime="2005-12-25 11:25:56" --stop-datetime="2005-12-25 12:25:56" mysql-bin.000001 |mysql -uroot -p123456
```