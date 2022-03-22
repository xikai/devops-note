#表示系统同时保持TIME_WAIT套接字的最大数量，如果超过这个数字，TIME_WAIT套接字将立刻被清除并打印警告信息。默认为180000 
net.ipv4.tcp_max_tw_buckets = 10000
#它可以用来查找特定的遗失的数据报‐‐‐ 因此有助于快速恢复状态。
net.ipv4.tcp_sack = 1
#设置tcp/ip会话的滑动窗口大小是否可变。
net.ipv4.tcp_window_scaling = 1
#接收缓存设置同tcp_wmem
net.ipv4.tcp_rmem = 4096 87380 4194304
#socket预留用于发送缓冲的内存最小值。
net.ipv4.tcp_wmem = 4096 16384 4194304
#默认的发送窗口大小(以字节为单位)
net.core.wmem_default = 67108864
#默认的接收窗口大小(以字节为单位)
net.core.rmem_default = 67108864
#最大的TCP数据接收缓冲 
net.core.rmem_max = 67108864
#最大的TCP数据发送缓冲
net.core.wmem_max = 67108864
#每个网络接口接收数据包的速率比内核处理这些包的速率快时，允许送到队列的数据包的最大数目。
net.core.netdev_max_backlog = 262144
#用来限制监听(LISTEN)队列最大数据包的数量，超过这个数量就会导致链接超时或者触发重传机制。
net.core.somaxconn = 65535
#系统所能处理不属于任何进程的TCP sockets最大数量。
net.ipv4.tcp_max_orphans = 3276800
#时间戳，Timestamp会让它知道这是个 '旧封包',tcp_tw_recycle打开时这个要关闭。
net.ipv4.tcp_timestamps = 0
#对于远端的连接请求SYN，内核会发送SYN ＋ACK数据报，以确认收到上一个 SYN连接请求包。
net.ipv4.tcp_synack_retries = 2
#对于一个新建连接，内核要发送多少个SYN连接请求才决定放弃。
net.ipv4.tcp_syn_retries = 2
#打开快速 TIME‐WAIT sockets 回收。
net.ipv4.tcp_tw_recycle = 1
#表示是否允许重新应用处于TIME‐WAIT状态的socket用于新的TCP连接。
net.ipv4.tcp_tw_reuse = 1
#对于本端断开的socket连接，TCP保持在FIN‐WAIT‐2状态的时间。
net.ipv4.tcp_fin_timeout = 2
#TCP发送keepalive探测消息的间隔时间（秒），用于确认TCP连接是否有效。
net.ipv4.tcp_keepalive_time = 600
#表示用于向外连接的端口范围，默认比较小，这个范围同样会间接用于NAT表规模。
net.ipv4.ip_local_port_range = 10240 65000
#内存在使用到100‐5=95%的时候，就开始出现有交换分区的使用
vm.swappiness = 5
#值为0时表示可以从下一个zone找可用内存，非0表示在本地回收。
vm.zone_reclaim_mode = 0
#对于那些依然还未获得客户端确认的连接请求﹐需要保存在队列中最大数目。
net.ipv4.tcp_max_syn_backlog = 262144
#同步刷脏页，会阻塞应用程序 
vm.dirty_ratio = 60
#异步刷脏页，不会阻塞应用程序
vm.dirty_background_ratio = 5
# 禁用IPV6
net.ipv6.conf.all.disable_ipv6 = 1


#centos 7 
vim /etc/systemd/system.conf
DefaultLimitCORE=infinity
DefaultLimitNOFILE=102400
DefaultLimitNPROC=102400


