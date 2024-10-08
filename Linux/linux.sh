查询文件系统目录大小
ls |egrep -v 'data|proc' |xargs du -sh

重定向
2>&1 将 stderr 重定向到 stdout，错误消息被发送到与标准输出相同的地方

网络连接
#统计当前tcp连接80端口的IP数
netstat -antp|grep ESTABLISHED |awk -F'[ :]+' '{if($5==80) print $6}'|sort|uniq -c|sort -nr|wc -l

#设置网卡mtu值
ip link set dev eth0 mtu 1500
ifdown/ifup eth0  #重启网卡恢复设置
#永久配置： /etc/sysconfig/network-scripts/ifcfg-eth0 添加MTU=1500

日志分析
#查看nginx状态404的访问日志(json)
cat /data/logs/nginx/m.tomtop.com_access.log |awk -F\" '{if($24==404)print $0}'|wc -l

journalctl -u kubelet --since "2023-07-13 17:30:00" --until "2023-07-13 18:00:00"
journalctl --since yesterday
journalctl --since 09:00 --until "1 hour ago"
journalctl -k  //查看内核日志,等同于 demsg 命令
journalctl _PID=1


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
#查看被进程标记为删除的文件
lsos |grep deleted

# 将标准输入（通常是由前面的命令输出产生的）作为参数传递给另一个命令
xargs -n num：指定每次从输入中读取的参数数量。例如，xargs -n 1 会确保每次只传递一个参数给后续命令
xargs -t 或 --verbose：显示执行的命令，这对于调试很有帮助
xargs -p 或 --interactive：在执行每个命令之前询问用户是否要执行。可以防止意外执行危险命令
xargs -d delimiter：指定输入参数的分隔符，默认是空格。

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
#查找删除.开头的隐藏文件
find . -type f -name .\* -exec rm {} \;
#保留id最大的10个目录 并删除其它目录，目录名格式id-datatime：32-20231122043631697 
find /data/www -maxdepth 1 -mindepth 1 -type d |awk -F / '{print $NF}' |sort -t'-' -k1n |head -n -10 |while read dir; do rm -rf "/data/www/$dir"; done

#批量查找替换字符串
grep -rl "rm-wz90448rzu9sd21h0.mysql.rds.aliyuncs.com" * |xargs perl -pi -e 's|rm-wz90448rzu9sd21h0.mysql.rds.aliyuncs.com|mydb01.dadi01.net|g'

#curl带头部参数的post请求
curl -H "token: 8dbcc3fd-22f2-452e-b205-a2b268746219" -H "Content-Type: application/json" -X POST -d '{"from":"chicuu@chicuu.com","toEmail":"2853635728@qq.com","title":"test111","content":"0000000000content test11"}' http://email.api.tomtop.com/email/send
#认证访问
curl -u username:password https://www.google.com
#curl proxy访问
curl -U [username:password] --proxy 1.1.1.1:7070 https://www.google.com
# 通过指定网卡访问
curl cip.cc --interface 172.16.4.89


#yum下载相关依赖rpm包文件
yum install --downloadonly --downloaddir=./packages chrony libreswan aide


# 手动释放系统内存
# 在Linux系统下，我们一般不需要去释放内存，因为系统已经将内存管理的很好。但是凡事也有例外，有的时候内存会被缓存占用掉，导致系统使用SWAP空间影响性能，例如当你在linux下频繁存取文件后,物理内存会很快被用光,当程序结束后,内存不会被正常释放,而是一直作为caching。，此时就需要执行释放内存（清理缓存）的操作了。
# Linux系统的缓存机制是相当先进的，他会针对dentry（用于VFS，加速文件路径名到inode的转换）、Buffer Cache（针对磁盘块的读写）和Page Cache（针对文件inode的读写）进行缓存操作。但是在进行了大量文件操作之后，缓存会把内存资源基本用光。但实际上我们文件操作已经完成，这部分缓存已经用不到了。这个时候，我们难道只能眼睁睁的看着缓存把内存空间占据掉吗？所以，我们还是有必要来手动进行Linux下释放内存的操作，其实也就是释放缓存的操作了。/proc是一个虚拟文件系统,我们可以通过对它的读写操作做为与kernel实体间进行通信的一种手段.也就是说可以通过修改/proc中的文件,来对当前kernel的行为做出调整.那么我们可以通过调整/proc/sys/vm/drop_caches来释放内存。

cat /proc/sys/vm/drop_caches
0  #0是系统默认值，默认情况下表示不释放内存，由操作系统自动管理

1：释放页缓存
2：释放dentries和inodes
3：释放所有缓存

手动执行sync命令（描述：sync 命令运行 sync 子例程。如果必须停止系统，则运行sync 命令以确保文件系统的完整性。sync 命令将所有未写的系统缓冲区写到磁盘中，包含已修改的 i-node、已延迟的块 I/O 和读写映射文件）
sync
echo 3 > /proc/sys/vm/drop_caches  #重启系统恢复默认值0


ps auxwf
w:宽泛输出 ww无限宽度
f: 完整格式，输出额外的列


dmesg （全称是display message (or display driver)），dmesg命令是从内核环形缓冲区中获取数据的，当我们在Linux上排除故障时，dmesg命令会十分方便，它能很好地帮我们鉴别硬件相关的error和warning。除此之外，dmesg命令还能打印出守护进程相关的信息，已帮助我们debug