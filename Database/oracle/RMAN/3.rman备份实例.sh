RMAN备份实例(归档模式)
#设置RMAN策略
rman target /
configure controlfile autobackup on;
configure controlfile autobackup format for device type disk to "/u01/app/backup/ctl_%F";
configure channel device type disk format '/u01/app/backup/full_%d_%T_%I_%U';
configure retention policy to recovery window of 7 days;



----------------------------------------------------------------------------------------------
#全量备份
cat >>/u01/app/oracle/product/11.2.0/backup_oradb1_full.rman <<EOF
run {
allocate channel ch1 device type disk;
backup database format '/u01/app/backup/data_full_%d_%T_%I_%U'
 plus archivelog format '/u01/app/backup/arch_%d_%T_%I_%U'
 delete input;
backup current controlfile format '/u01/app/backup/ctl_%d_%T_%I_%U';
release channel ch1;
delete noprompt obsolete;
}
EOF

#命令行执行备份
rman target / cmdfile=/u01/app/oracle/product/11.2.0/backup_oradb1.rman log /tmp/rman_full.log



----------------------------------------------------------------------------------------------
#增量备份
cat >>/u01/app/oracle/product/11.2.0/backup_oradb1_inc0.rman <<EOF
run {
allocate channel ch1 device type disk;
backup incremental level=0 skip inaccessible database format '/u01/app/backup/data_lv0_%d_%T_%I_%U'
 plus archivelog format '/u01/app/backup/arch_%d_%T_%I_%U'
 delete input;
backup current controlfile format '/u01/app/backup/ctl_%d_%T_%I_%U';
release channel ch1;
delete noprompt obsolete;
}
EOF

cat >>/u01/app/oracle/product/11.2.0/backup_oradb1_inc2.rman <<EOF
run {
allocate channel ch1 device type disk;
backup incremental level=2 skip inaccessible database format '/u01/app/backup/data_lv2_%d_%T_%I_%U'
 plus archivelog format '/u01/app/backup/arch_%d_%T_%I_%U'
 delete input;
backup current controlfile format '/u01/app/backup/ctl_%d_%T_%I_%U';
release channel ch1;
delete noprompt obsolete;
}
EOF

cat >>/u01/app/oracle/product/11.2.0/backup_oradb1_inc1.rman <<EOF
run {
allocate channel ch1 device type disk;
backup incremental level=1 skip inaccessible database format '/u01/app/backup/data_lv1_%d_%T_%I_%U'
 plus archivelog format '/u01/app/backup/arch_%d_%T_%I_%U'
 delete input;
backup current controlfile format '/u01/app/backup/ctl_%d_%T_%I_%U';
release channel ch1;
delete noprompt obsolete;
}
EOF


#crontab
0 0 * * 0  rman target / cmdfile=/u01/app/oracle/product/11.2.0/backup_oradb1_inc0.rman log /tmp/rman_inc0.log
0 0 * * 1,2,3,5,6  rman target / cmdfile=/u01/app/oracle/product/11.2.0/backup_oradb1_inc2.rman log /tmp/rman_inc2.log
0 0 * * 4  rman target / cmdfile=/u01/app/oracle/product/11.2.0/backup_oradb1_inc0.rman log /tmp/rman_inc1.log
