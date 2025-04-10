* https://manpages.debian.org/testing/logrotate/logrotate.8.en.html
* https://www.redhat.com/sysadmin/setting-logrotate
* https://linux.cn/article-4126-1.html
* https://blog.csdn.net/forthemyth/article/details/44062529

* nginx日志切割配置
>vim /etc/logrotate.d/nginx
```
/data/logs/nginx/*.log {
        daily
        missingok
        rotate 14
        compress
        delaycompress
        notifempty
        create 0640 www-data adm
        sharedscripts
        prerotate
                if [ -d /etc/logrotate.d/httpd-prerotate ]; then \
                        run-parts /etc/logrotate.d/httpd-prerotate; \
                fi \
        endscript
        postrotate
                invoke-rc.d nginx rotate >/dev/null 2>&1
        endscript
}
```

* 手动调用日志切割
```
logrotate /etc/logrotate.d/nginx
```
```
logrotate -d   #输出切割日志
logrotate -vf  #即使轮循条件没有满足，‘-f’强制logrotate轮循日志文件，‘-v’提供详细输出。
```

* logrotate自身日志
```
cat /var/lib/logrotate/status
```

* logrotate的cron定时任务
```
cat /etc/cron.daily/logrotate
```