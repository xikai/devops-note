##################################################################
##   rman_incremental_backup.sh              
##   2015-11-18                        
##################################################################
#!/bin/sh

ORACLE_HOME="/u01/app/oracle/product/11.2.0"
ORACLE_SID="oradb1"
ORACLE_USER="oracle"
WEEK_DAILY=`date +%a`
TODAY=`date`
USER=`id|cut -d "(" -f2|cut -d ")" -f1`
RMAN_LOG_FILE="/tmp/rman_incremental_backup.out"
ROOT_MAIL="root@quxiu.me"

export LANG=en_US
export ORACLE_HOME
export ORACLE_SID

case $WEEK_DAILY in
    Mon|Tue|Wed|Fri|Sat)
        BAK_LEVEL=2
        ;;
    Thu)
        BAK_LEVEL=1
        ;;
    Sun)
        BAK_LEVEL=0
        ;;
    *)
        BAK_LEVEL=error
        ;;
esac

echo "-----------------$TODAY-------------------">$RMAN_LOG_FILE
echo "ORACLE_SID: $ORACLE_SID" >>$RMAN_LOG_FILE
echo "ORACLE_HOME: $ORACLE_HOME" >>$RMAN_LOG_FILE
echo "USER: $USER" >>$RMAN_LOG_FILE
echo "==========================================">>$RMAN_LOG_FILE
echo "BACKUP DATABASE BEGIN......">>$RMAN_LOG_FILE
echo "                   ">>$RMAN_LOG_FILE
chmod 666 $RMAN_LOG_FILE
echo "Today is : $WEEK_DAILY  incremental level=$BAK_LEVEL">>$RMAN_LOG_FILE

/u01/app/oracle/product/11.2.0/bin/rman target / >>$RMAN_LOG_FILE <<EOF
run {
allocate channel ch1 device type disk;
backup incremental level=$BAK_LEVEL skip inaccessible database format "/u01/app/backup/data_lv${BAK_LEVEL}_%d_%T_%I_%U"
 plus archivelog format "/u01/app/backup/arch_%d_%T_%I_%U"
 delete input;
backup current controlfile format "/u01/app/backup/ctl_%d_%T_%I_%U";
release channel ch1;
delete noprompt obsolete;
}
EOF


/bin/mail -s "RMAN Backup" $ROOT_MAIL < $RMAN_LOG_FILE
