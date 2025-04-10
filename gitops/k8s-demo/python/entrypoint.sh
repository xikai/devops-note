#!/bin/bash
echo -e "0 02,06,10,14,18,22 * * * python3 /var/www/html/master_vevor/testsuites/job.py" >/var/spool/cron/crontabs/root
service cron start
python3 /var/www/html/master_vevor/testsuites/run.py

