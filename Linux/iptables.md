* https://www.netfilter.org/documentation/index.html
* https://www.frozentux.net/iptables-tutorial/iptables-tutorial.html
* https://wiki.archlinux.org/index.php/Iptables_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)

### table表：
1. filter表——三个链：INPUT、FORWARD、OUTPUT作用：过滤数据包 内核模块：iptables_filter.
2. Nat表——三个链：PREROUTING、POSTROUTING、OUTPUT作用：用于网络地址转换（IP、端口） 内核模块：iptable_nat
3. Mangle表——五个链：PREROUTING、POSTROUTING、INPUT、OUTPUT、FORWARD作用：修改数据包的服务类型、TTL、并且可以配置路由实现QOS内核模块：iptable_mangle(别看这个表这么麻烦，咱们设置策略时几乎都不会用到它)
4. Raw表——两个链：OUTPUT、PREROUTING作用：决定数据包是否被状态跟踪机制处理 内核模块：iptable_raw

### chain链：
- INPUT - 进入本机localhost
- OUTPUT - 从本机localhost出去
- FORWARD - 路由的数据包,来源是请求转发的主机，目标是远端被访问的主机
- PREROUTING - 从外网到内网的NAT
- POSTROUTING - 从内网到外网的NAT

### target动作:
- DROP - 拒绝
- ACCEPT - 允许
- REJECT - 拒绝,丢弃包的同时给发送者发送没有接受的通知
- LOG - 日志记录

### 表链关系匹配顺序
```
   IN                                                       OUT
    |                                                        |
    |                                                        |
PREROUTING --> localhost(NO) ---> FORWORD ------------> POSTROUTING
(nat、mangle、raw)            (filter、mangle)     (mangle、raw、nat)
    |                                                        |
    |                                                        |
localhost(YES)                                               |
    |                                                        |
    |                                                        |
   INPUT ------------------> localhost ------------------> OUTPUT
(filter、mangle)                                  (filter、nat、mangle、raw)
```
```
进入内网其它主机的数据包:  ---> PREROUTING ---> FORWORD ---> 内网主机
内网其它主机外出的数据包:  ---> FORWORD ---> POSTROUTING ---> 外网主机
进入本机的数据包:  ---> INPUT ---> 本机
本机到内网其它主机的数据包:  ---> OUTPUT ---> 内网其它主机
```

### iptables命令
```bash
iptables -L 查看防火墙规则
iptables -F 清除所有规则
iptables -X 清除所有用户自定义规则

# 添加规则:
配置一条数据流时，进出都要添加规则
iptables [-t table] <-A|I|D|R> chain[规则编号] -p 协议 -s/-d 源/目标IP(不写则为any)--sport/--dport 源/目标端口 -j target


# 增删改查：
iptables -P INPUT/OUTPUT/FORWORD DROP        将防火墙默认规则设为默认拒绝所有
iptables -L -n --line-numbers                显示行号，便于插入规则
iptables -D chain 编号                       删除链中指定的规则
iptables -I chain [编号]                     将规则插入第n条,不写编号时默认插入第一条

保存制定的规则到/etc/sysconfig/iptables文件中，下次重启系统时默认添加被保存的规则：
services iptables save  或  iptables-save >/etc/sysconfig/iptables

iptables -N    mychain                 新建自定义链
iptables -X    mychain                 删除自定义链
iptables -A chain -j mychain     让指定链引用自定义链的规则

# 状态跟踪：
-m state --state NEW/ESTABLISHED/RELATED/INVALID:
NEW                    将要建立连接的第一个数据包,即3次握手的第一次，一次新的请求
ESTABLISHED            己经建立连接的数据包
RELATED                和己经建立连接相关的连接数数包
INVALID                与任何已知的流或连接都不相关联,它可能包含错误的数据或头.

eg:
iptables -A INPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
添加一条规则为只允许响应对方请求22号端口


# 日志记录
# INPUT链开头插入 匹配目标端口为9200的日志记录输出规则（--log-level日志级别4=waring,--log-prefix日志唯一标识字符串）
iptables -I INPUT  1 -p tcp --dport 9200  -j LOG --log-level 4 --log-prefix 'INPUT-2:'
```

### 常用配置示例:
```bash
iptables -N RH-Firewall-1-INPUT
iptables -A INPUT -j RH-Firewall-1-INPUT
iptables -A RH-Firewall-1-INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A RH-Firewall-1-INPUT -p icmp -j ACCEPT
iptables -A RH-Firewall-1-INPUT -i lo -j ACCEPT
iptables -A RH-Firewall-1-INPUT -p tcp -m state --state NEW --dport 22 -j ACCEPT
iptables -A RH-Firewall-1-INPUT -p tcp -m state --state NEW --dport 80 -j ACCEPT
iptables -A RH-Firewall-1-INPUT -p tcp -m state --state NEW --dport 20:21 -j ACCEPT
iptables -A RH-Firewall-1-INPUT -j DROP
```


### 地址转换NAT(Netfilter)
>必须先开启路由功能 echo 1 > /proc/sys/net/ipv4/ip_forward (当前生效)，永外生效需修改/etc/sysctl.conf
```bash
iptables -t nat -L     #查看NAT规则
```

* SNAT:POSTROUTING转换，只允许内网到外网
```bash
10.0.0.241------->eth0:10.0.0.254 -------->192.168.0.1
    内            eth1:192.168.0.254          外

iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -j SNAT --to-source 192.168.0.254  #外网接口_ip:跳转到源地址转换，转换为外网接口地址(静态IP)
iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -j MASQUERADE #转换为动态分配的IP地址
```

* DNAT:PREROUTING转换，允许从外网到内网
```bash
10.0.0.241 <-------eth0:10.0.0.254 <--------192.168.0.1
   内(webserver)   eth1:192.168.0.254            外

# 将外网关的地址转换为内网WEB服务器地址(在防火墙上发布WEB服务器，让外网用户访问)
iptables -t nat -A PREGOUTING -d 192.168.0.254 -p tcp --dport 80 -j DNAT --to-destination 10.0.0.241
```

```bash
FORWARD限制NAT访问指定的目标
eg:
iptables -A FORWARD -s 10.0.0.0/24 -j ACCEPT      允许源地址(10.0.0.0/24)NAT出外网
iptables -A FORWARD -d 10.0.0.0/24 -j ACCEPT      允许外网地址NAT转换为内网地址(10.0.0.0/24)
```


# 端口重定向
```sh
# 本机端口重定向
iptables -t nat -A PREROUTING -p tcp --dport 16379 -j REDIRECT --to-port 6379

# 跨主机端口重定向
iptables -t nat -A PREROUTING -p tcp --dport 6379 -j DNAT --to-destination 172.31.21.29:6379
iptables -t nat -A POSTROUTING -p tcp -d 172.31.21.29 --dport 6379 -j SNAT --to-source 172.31.36.121

# 通过ssh隧道跨主机端口转发
ssh -f -N -L :16379:172.31.21.29:6379 root@172.31.21.29
```