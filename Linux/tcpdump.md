* https://segmentfault.com/a/1190000019669218
* https://www.cnblogs.com/pyng/p/9698723.html
```
tcpdump [协议] [-i 网卡 -nn]  '表达式'
tcpdump tcp -i eth1 -t -s 0 -c 100 'dst port ! 22 and src net 192.168.1.0/24' -w ./target.cap
```
```
# 协议
tcp: ip icmp arp rarp 和 tcp、udp、icmp这些选项等都要放到第一个参数的位置，用来过滤数据报的类型

# 参数
-i eth0                   监控指定网卡
-t                        不显示时间戳
-s 0                      抓取数据包时默认抓取长度为68字节。加上-S 0 后可以抓到完整的数据包
-c 100                    只抓取100个数据包
-w ./target.cap           保存成cap文件，方便用ethereal(即wireshark)分析
-r                        从后面接的档案将封包数据读出来。那个『档案』是已经存在的档案，并且这个『档案』是由 -w 所制作出来的。
-nn                       直接以 IP 及 port number 显示，而非主机名与服务名称

# 表达式
host hostip               监控指定主机的接收和发送数据包
src host hostip           监控指定主机所有发送的数据包
dst host hostip           监控指定主机所有接收的数据包

src net 192.168.1.0/24    数据包的源网络地址为192.168.1.0/24

port 23                   监控指定协议及端口的数据包
dst port ! 22             不抓取目标端口是22的数据包
```
>三种逻辑运算，取非运算是‘not‘‘!‘,与运算是‘and‘,‘&&‘;或运算是‘or‘,‘||‘；这些关键字可以组合起来构成强大的组合


# 示例
```
如果想要获取主机210.27.48.1和除了主机210.27.48.2之外所有主机通信的ip包，使用命令：
tcpdump ip host 210.27.48.1 and ! 210.27.48.2

抓取指定IP的ICMP包
tcpdump icmp and host 172.31.42.89
```

# 包解析
```
15:39:07.427683 IP 10.25.137.230.20260 > 10.29.64.142.443: Flags [P.], seq 1026816011:1026816267, ack 1193238686, win 115, length 256
```
```sh
15:39:07.427683                               #网络包发生的时间
IP 10.25.137.230.20260 > 10.29.64.142.443:    #IP标识 源ip或者源主机名和端口20260 >流向符 数据包从左边发往右边 目的ip或者目的主机名和端口443
Flags [P.]                                    #Flags的标记，此处为[P.]，PSH,push推送，数据传输; 
seq 1026816011:1026816267, ack 1193238686, win 115, length 256 #seq为请求包序列号,ack为确认码,win为滑动窗口大小,length为承载的数据(payload)长度length，如果没有数据则为0
```
* tcpdump抓包的FLags标记
```
[S]：SYN会话建立请求
[.]：.或A表示ACK确认标识
[S.]：SYN会话建立请求，以及确认[S]的ACK
[P.]：PSH,push推送，数据传输
[R.]：RST,连接重置
[F.]：FIN结束连接
[DF]：Don't Fragment（不要碎裂），当DF=0时，表示允许分片，一般-v时才有这个标识
[FP.]：标记FIN、PUSH、ACK组合，这样做是为了提升网络效率，减少数据来回确认等
```