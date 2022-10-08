```sh
#整个系统的文件限制
fs.file-max = 655350
#表示用于向外连接的端口范围，这里不要将最低值设的太低，否则可能会占用掉正常的端口
net.ipv4.ip_local_port_range = 10240 65000
#设置为5，内存在使用到100‐5=95%的时候，就开始出现有交换分区的使用,关闭交换分区设置为0
vm.swappiness = 0
#用来限制监听(LISTEN)队列的最大数量，超过这个数量就会导致链接超时或者触发重传机制。
net.core.somaxconn = 32768
#对于那些依然还未获得客户端确认的半连接请求﹐需要保存在队列中最大数目。
net.ipv4.tcp_max_syn_backlog = 32768
#启用SYNcookie将连接信息编码在ISN(initialsequencenumber)中返回给客户端，这时server不需要将半连接保存在队列中，而是利用客户端随后发来的ACK带回的ISN还原连接信息，以完成连接的建立，避免了半连接队列被攻击SYN包填满
net.ipv4.tcp_syncookies = 1   #默认为0不开启，SYN超时需要63秒，那么就给攻击者一个攻击服务器的机会，攻击者在短时间内发送大量的SYN包给Server(俗称 SYN flood 攻击)，用于耗尽Server的SYN队列

#server端重新发送SYN＋ACK数据包的次数。当网络繁忙、不稳定时，报文丢失就会变严重，此时应该调大重发次数。反之则可以调小重发次数
#net.ipv4.tcp_synack_retries = 2
#作为TCP客户端重新发送SYN请求包的次数
#net.ipv4.tcp_syn_retries = 2
###以上两个参数默认重试次数是 5 次，与客户端重传 SYN 类似，它的重传会经历 1、2、4、8、16 秒，最后一次重传后会继续等待 32 秒，如果服务端仍然没有收到 ACK，才会关闭连接，故共需要等待 63 秒

###TIME_WAIT###
#表示系统同时保持TIME_WAIT的最大数量，如果超过这个数字，TIME_WAIT将立刻被清除并打印警告信息
#net.ipv4.tcp_max_tw_buckets = 5000
#用于快速回收 TIME_WAIT 连接，通常在增加连接并发能力的场景会开启，比如发起大量短连接，快速回收可避免 tw_buckets 资源耗尽导致无法建立新连接 (time wait bucket table overflow)
#net.ipv4.tcp_tw_recycle = 1  #k8s环境不建议开启
#表示允许重新应用处于TIME‐WAIT状态的socket用于新的TCP连接。
#net.ipv4.tcp_tw_reuse = 1    #k8s环境不建议开启

#TCP可以缓存每个连接最新的时间戳，后续请求中如果时间戳小于缓存的时间戳，即视为无效，相应的数据包会被丢弃
#默认1开启，当 tcp_tw_recycle或tcp_tw_reuse开启后被激活；当多个客户端通过 NAT 方式联网并与服务端交互时，服务端看到的是同一个 IP，也就是说对服务端而言这些客户端实际上等同于一个，可惜由于这些客户端的时间戳可能存在差异，于是乎从服务端的视角看，便可能出现时间戳错乱的现象，进而直接导致时间戳小的数据包被丢弃。如果发生了此类问题，具体的表现通常是是客户端明明发送的 SYN，但服务端就是不响应 ACK。
#net.ipv4.tcp_timestamps = 0  #关闭

###TCP buffer###
#TCP读buffer
#net.ipv4.tcp_rmem = 4096 131072 6291456
#TCP写buffer
#net.ipv4.tcp_wmem = 4096 20480 4194304
#默认socket读buffer(以字节为单位)
#net.core.rmem_default = 67108864
#默认socket写buffer(以字节为单位)
#net.core.wmem_default = 67108864
#最大socket读buffer
#net.core.rmem_max = 67108864
#最大socket写buffer
#net.core.wmem_max = 67108864

#某个TCP连接在idle 2个小时(7200秒)后,内核才发起probe.如果probe 9次(每次75秒)不成功,内核才彻底放弃,认为该连接已失效.对服务器而言,显然上述值太大，可调整到:
#net.ipv4.tcp_keepalive_time = 1800
#net.ipv4.tcp_keepalive_probes = 3
#net.ipv4.tcp_keepalive_intvl = 30

#系统所能处理不属于任何进程的TCP sockets最大数量。
#net.ipv4.tcp_max_orphans = 3276800
```

# centos 7 
* vim /etc/security/limits.conf
```
work soft nofile 65535
work hard nofile 65535
```
* vim /etc/systemd/system.conf
```
DefaultLimitCORE=infinity
DefaultLimitNOFILE=102400
DefaultLimitNPROC=102400
```

# tcp半连接&全连接测试
* https://www.cxyxiaowu.com/10962.html
* https://www.cnblogs.com/silyvin/p/13596833.html