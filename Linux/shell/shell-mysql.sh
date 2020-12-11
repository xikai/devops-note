#!/bin/sh
##########################
#time: 20130823
#by:   xikai
#########################
user="root"
passwd="307@fanhoucom"
ip="10.154.1.59"
port="3305"
dbname=(jy_cuser_log3 jy_cuser_log4)
#echo ${dbname[*]}

for i in ${dbname[*]}
do

#字段不能加引号
/usr/local/mysql/bin/mysql -h"$ip" -P"$port" -u"$user" -p"$passwd" $i <<EOF
insert into xikai values('100','sssss');
insert into xikai(id) values('100');
update xikai set name='xxxx' where id=1;
CREATE TABLE logxikai (
  user_id int(10) unsigned NOT NULL DEFAULT '0',
  log_type tinyint(3) unsigned NOT NULL DEFAULT '0',
  info varchar(128) NOT NULL DEFAULT '[]',
  create_time int(10) unsigned NOT NULL DEFAULT '0',
  KEY user_id_time (user_id,create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
EOF
done



------------------------------------------------------------------------------------
#!/bin/sh
##########################
#time: 20130823
#by:   xikai
#########################
user="root"
passwd="307@fanhoucom"
ip="10.154.1.59"
port="3305"
dbname=(jy_cuser_log3 jy_cuser_log4)
sql="CREATE TABLE logxikaii4444 (
  user_id int(10) unsigned NOT NULL DEFAULT '0',
  log_type tinyint(3) unsigned NOT NULL DEFAULT '0',
  info varchar(128) NOT NULL DEFAULT '[]',
  create_time int(10) unsigned NOT NULL DEFAULT '0',
  KEY user_id_time (user_id,create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;"
#echo ${dbname[*]}

for i in ${dbname[*]}
do
/usr/local/mysql/bin/mysql -h"$ip" -P"$port" -u"$user" -p"$passwd" $i -e "$sql"
done