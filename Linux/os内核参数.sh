net.core.rmem_max = 4194304 #最大的TCP数据接收缓冲
net.core.wmem_max = 2097152 #最大的TCP数据发送缓冲
net.core.wmem_default = 262144 #表示接收套接字缓冲区大小的缺省值(以字节为单位）
net.core.rmem_default = 262144 #表示发送套接字缓冲区大小的缺省值(以字节为单位)
kernel.shmmni = 4096 #这个内核参数用于设置系统范围内共享内存段的最大数量。该参数的默认值是 4096 。通常不需要更改
kernel.sem = 250 32000 100 142
kernel.shmall = 2097152 #该参数表示系统一次可以使用的共享内存总量(以页为单位)。缺省值就是2097152，通常不需要修改
kernel.shmmax = 2147483648 #该参数定义了共享内存段的最大尺寸(以字节为单位)，此值默认为物理内存的一半 
kernel.sysrq = 0 #如无需调试系统排查问题，这个必须为0
fs.file-max = 6815744 #该参数表示文件句柄的最大数量。文件句柄设置表示在linux系统中可以打开的文件数量


#Network
net.ipv4.tcp_syncookies = 1 #当出现SYN等待队列溢出时，启用cookies来处理，可防范少量SYN攻击，默认为0，表示关闭。
net.ipv4.tcp_tw_reuse = 1 #允许将TIME-WAIT sockets重新用于新的TCP连接，默认为0，表示关闭
net.ipv4.tcp_tw_recycle = 1 #TCP连接中TIME-WAIT sockets的快速回收，默认为0，表示关闭，注意如果是nat-nat网络，并与net.ipv4.tcp_timestamps = 1组合使用，则会出现时断时续的情况
net.ipv4.tcp_fin_timeout = 30 #修改系統默认的 TIMEOUT 时间

#避免服务器被大量的TIME_WAIT拖死
net.ipv4.tcp_keepalive_time = 1200 #当keepalive起用的时候，TCP发送keepalive消息的频度。缺省是2小时，改为20分钟
net.ipv4.ip_local_port_range = 9000 65000 #如果连接数本身就很多，可以再优化一下TCP的可使用端口范围，进一步提升服务器的并发能力，默认值是32768到61000
net.ipv4.tcp_max_syn_backlog = 8192 #SYN队列的长度，默认为1024，加大队列长度为8192，可以容纳更多等待连接的网络连接数
net.ipv4.tcp_max_tw_buckets = 5000 #系统同时保持TIME_WAIT的最大数量，如果超过这个数字，TIME_WAIT将立刻被清除并打印警告信息，默认为180000

net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.all.arp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.default.arp_filter = 0
net.ipv4.conf.lo.rp_filter = 0
net.ipv4.conf.lo.arp_filter = 0
net.ipv4.conf.em1.rp_filter = 0
net.ipv4.conf.em1.arp_filter = 0
net.ipv4.conf.em2.rp_filter = 0
net.ipv4.conf.em2.arp_filter = 0


#最大限度使用物理内存，然后才是swap空间(默认值60，表示物量内存剩余60%开始使用swap,建议改成10)
vm.swappiness=0   


#/etc/security/limits.conf
apps soft nofile 131072        #如果文件多，MySQL打开的文件句柄很多的话，可适当调大
apps hard memlock 128849018880 #可选，如需设置大内存页，根据系统内存而定
apps soft memlock 128849018880
apps soft core unlimited
apps hard core unlimited
apps hard nproc unlimited
apps soft nproc unlimited
apps hard nofile 131072         #如果文件多，MySQL打开的文件句柄很多的话，可适当调大
apps hard stack unlimited
apps soft stack unlimited
