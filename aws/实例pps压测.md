* https://repost.aws/knowledge-center/ec2-instance-network-pps-limit

* 安装iperf2
```
cd /usr/local/
git clone https://git.code.sf.net/p/iperf2/code iperf2-code

cd /usr/local/iperf2-codesudo 
./configure
make && make install
```

* 服务端开启udp协议，接收请求
```
/usr/local/bin/iperf -s -u
```

* 客户端发送请求
```
/usr/local/bin/iperf -c <private_ip_of_server_instance> -u -i 1 -l 16 -b 20kpps -e -P64 -o /tmp/bw_test.txt && grep -i sum-64 /tmp/bw_test.txt
```

* 显示每秒运行测试的摘要，以及PPS
```
[SUM-64] 0.00-1.00 sec 9.42 MBytes 79.1 Mbits/sec 617416/2 617416 pps
[SUM-64] 1.00-2.00 sec 10.1 MBytes 84.3 Mbits/sec 658689/0 658692 pps
[SUM-64] 2.00-3.00 sec 10.1 MBytes 84.7 Mbits/sec 661837/0 661838 pps
[SUM-64] 3.00-4.00 sec 10.1 MBytes 84.6 Mbits/sec 661226/0 661226 pps
[SUM-64] 6.00-7.00 sec 9.73 MBytes 81.7 Mbits/sec 637975/0 637975 pps
[SUM-64] 7.00-8.00 sec 9.46 MBytes 79.4 Mbits/sec 620172/0 620172 pps
[SUM-64] 8.00-9.00 sec 9.46 MBytes 79.4 Mbits/sec 620150/0 620151 pps
```