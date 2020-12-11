#!/bin/bash
###mysql_db_backup
export PATH=$PATH:/usr/local/webserver/mysql/bin:/usr/local/mysql/bin
source /etc/profile

if [ ! -d /db_bak ] ;then mkdir /db_bak ;fi
rm -rf /db_bak/*

system_ip=`/sbin/ifconfig | sed -n '2p' | awk -F: '{print $2}' | awk '{print $1}' | sed 's/\./-/g'`
all_db=`mysql -ucm2011 -pcm2011 -Bse 'show databases'|egrep  -v 'mysql|test|information_schema|performance_schema'`

cd /db_bak
for db in ${all_db}
do
    mysqldump -ucm2011 -pcm2011 $db > $db.sql
    tar czf db_${system_ip}_$db.tar.gz $db.sql
done
rm -rf *.sql

if [ `ls /db_bak|wc -l` -ne 0 ]
then
        rsync -avz -e "ssh -i /root/.ssh/id_rsa" /db_bak root@66.90.104.207:/backup
fi


#rm +7 data
files=`ls /backup | grep -v backup.sh`
for i in $files
do
   fileDate=`echo $i |awk -F. '{print $2}'`
   fileTime=`date +%s -d $fileDate`
   nowTime=`date +%s`
   interval=$((($nowTime-$fileTime)/86400))
   if [ $interval -gt 7 ] ;then
      echo "remove the $i ..."
      rm -rf $i
   fi
done