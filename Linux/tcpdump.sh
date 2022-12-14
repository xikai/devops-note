tcpdump：
https://www.cnblogs.com/pyng/p/9698723.html

tcpdump [-i 网卡] -nn '表达式'
tcpdump tcp -i eth1 -t -s 0 -c 100 'dst port ! 22 and src net 192.168.1.0/24' -w ./target.cap
tcp: ip icmp arp rarp 和 tcp、udp、icmp这些选项等都要放到第一个参数的位置，用来过滤数据报的类型
-i eth0                   监控指定网卡
-t                        不显示时间戳
-s 0                      抓取数据包时默认抓取长度为68字节。加上-S 0 后可以抓到完整的数据包
-c 100                    只抓取100个数据包
-w ./target.cap           保存成cap文件，方便用ethereal(即wireshark)分析
-r                        从后面接的档案将封包数据读出来。那个『档案』是已经存在的档案，并且这个『档案』是由 -w 所制作出来的。
-nn                       直接以 IP 及 port number 显示，而非主机名与服务名称

tcp/udp                   监控指定协议

host hostip               监控指定主机的接收和发送数据包
src host hostip           监控指定主机所有发送的数据包
dst host hostip           监控指定主机所有接收的数据包

src net 192.168.1.0/24    数据包的源网络地址为192.168.1.0/24

port 23                   监控指定协议及端口的数据包
dst port ! 22             不抓取目标端口是22的数据包

-----------------------------------------------------------


三种逻辑运算，取非运算是‘not‘‘!‘,与运算是‘and‘,‘&&‘;或运算是‘or‘,‘||‘；这些关键字可以组合起来构成强大的组合

如果想要获取主机210.27.48.1和除了主机210.27.48.2之外所有主机通信的ip包，使用命令：
tcpdump ip host 210.27.48.1 and ! 210.27.48.2