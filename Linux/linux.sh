网络连接
#统计当前tcp连接80端口的IP数
netstat -antp|grep ESTABLISHED |awk -F'[ :]+' '{if($5==80) print $6}'|sort|uniq -c|sort -nr|wc -l


日志分析
#查看nginx状态404的访问日志(json)
cat /data/logs/nginx/m.tomtop.com_access.log |awk -F\" '{if($24==404)print $0}'|wc -l


文件句柄
#查看可以创建的最大进程数（系统级）
cat /proc/sys/kernel/pid_max

#查看可以打开的最大文件句柄数（系统级）
cat /proc/sys/fs/file-max

#当前shell以及由它启动的进程的资源限制（进程级）
ulimit -n

#查看进程可使用的系统资源限制(文件句柄)
cat /proc/$pid/limits

#查看当前己打开的文件句柄数
cat /proc/sys/fs/file-nr   #己分配 未使用 最大
lsof |wc -l

#查看进程当前己打开的文件数
lsof -p pid |wc -l



ls |while read line; do mysql manage < $line; done

ls |grep -v proc |xargs du -sh|sort -hr

#find
-mtime/-mmin : 指定时间曾被改动过的文件，意思是文件內容被更改过
-ctime/-cmin : 指定时间曾被更改过的文件，意思是文件权限被更改过
-atime/-amin : 指定时间曾被存取过的文件，意思是文件被读取过

-mtime +10  10天以前修改过的
-mtime -10  10天以内修改过的
-mmin +10   10分钟以前修改过的

#查找指定时间范围的文件
find . -newermt '2015-03-02 00:00:00' ! -newermt '2015-03-03 14:00:00' -name "*@1c_1e_90Q*"

#批量查找替换字符串
grep -rl "rm-wz90448rzu9sd21h0.mysql.rds.aliyuncs.com" * |xargs perl -pi -e 's|rm-wz90448rzu9sd21h0.mysql.rds.aliyuncs.com|mydb01.dadi01.net|g'

#curl带头部参数的post请求
curl -H "token: 8dbcc3fd-22f2-452e-b205-a2b268746219" -H "Content-Type: application/json" -X POST -d '{"from":"chicuu@chicuu.com","toEmail":"2853635728@qq.com","title":"test111","content":"0000000000content test11"}' http://email.api.tomtop.com/email/send


#yum下载相关依赖rpm包文件
yum install --downloadonly --downloaddir=/test chrony libreswan aide