* https://libreswan.org/

# subnet to subnet vpn
```
AWS:
外网：52.89.28.84
内网：172.31.0.0/16
HK:
外网：43.242.141.182
内网：192.168.0.0/16
```
* vim /etc/sysctl.conf
```
将“net.ipv4.ip_forward”改为1，变成下面的形式：
net.ipv4.ip_forward=1
保存退出，并执行下面的命令来生效它：
sysctl -p
```

* 安装libreswan（libreswan3.23 、unbound-libs>=1.6）
```
yum install -y libreswan unbound-libs
```

* openssl生成64位PSK预共享密钥
```
openssl rand -base64 16
 6RHsYmuqCG8YUpaX6u14Gg==
```

## AWS(52.89.28.84):
* vim /etc/ipsec.conf
```
config setup
    logfile=/var/log/pluto.log
    virtual_private=%v4:192.168.0.0/16,%v4:10.0.8.0/24,%v4:172.31.0.0/16,%v4:172.30.0.0/24,%v4:172.30.10.0/24,%v4:172.30.20.0/23,%v4:172.30.30.0/24
    nat_traversal=yes
    protostack=netkey
include /etc/ipsec.d/*.conf
```

* vim /etc/ipsec.d/aws_hk.conf
```
conn vpn
    ### phase 1 ###
    type=tunnel         # 指定模式类型为隧道模式|传输模式
    authby=secret       # 指定认证类型预共享秘钥
    keyexchange=ike
    ike=aes128-sha1;modp1536     # 指定ike算法
    ikelifetime=86400s
    ikev2=never

    ### phase 2 ###
    phase2=esp
    phase2alg=aes128-sha1;modp1536
    salifetime=3600s
    #pfs=yes            # 指定是否加密
    dpddelay=10
    dpdtimeout=60
    dpdaction=restart_by_peer
    auto=start          # 指定连接添加类型 start 为开机自启，add为添加 不主动连接

    left=%defaultroute
    leftid=52.89.28.84
    leftsubnet=172.31.0.0/16
    leftnexthop=%defaultroute
    right=43.242.141.182
    #rightsubnet=192.168.0.0/16
    rightsubnets={ 172.30.0.0/24 172.30.10.0/24 172.30.20.0/23 172.30.30.0/24 }
    rightnexthop=%defaultroute
```

* vim /etc/ipsec.d/ipsec.secrets
```
52.89.28.84  43.242.141.182 : PSK "6RHsYmuqCG8YUpaX6u14Gg=="
```

```
ipsec verify
systemctl enable ipsec
systemctl start ipsec
```

## HK(43.242.141.182):
* vim /etc/ipsec.conf
```
config setup
    logfile=/var/log/pluto.log
    dumpdir=/var/run/pluto/
    virtual_private=%v4:192.168.0.0/16,%v4:10.0.8.0/24,%v4:172.31.0.0/16,%v4:172.30.0.0/24,%v4:172.30.10.0/24,%v4:172.30.20.0/23,%v4:172.30.30.0/24
    nat_traversal=yes
    protostack=netkey
include /etc/ipsec.d/*.conf
```

* vim /etc/ipsec.d/hk_aws.conf
```
conn vpn
    ### phase 1 ###
    type=tunnel         # 指定模式类型为隧道模式|传输模式
    authby=secret       # 指定认证类型预共享秘钥
    keyexchange=ike
    ike=aes128-sha1;modp1536     # 指定ike算法
    ikelifetime=86400s
    ikev2=never

    ### phase 2 ###
    phase2=esp
    phase2alg=aes128-sha1;modp1536
    salifetime=3600s
    #pfs=yes            # 指定是否加密
    dpddelay=10
    dpdtimeout=60
    dpdaction=restart_by_peer
    auto=start          # 指定连接添加类型 start 为开机自启，add为添加 不主动连接

    left=43.242.141.182
    leftsubnet=192.168.0.0/16
    leftnexthop=%defaultroute
    right=52.89.28.84
    rightsubnet=172.31.0.0/16
    rightnexthop=%defaultroute
```

* vim /etc/ipsec.d/ipsec.secrets
```
43.242.141.182 52.89.28.84 : PSK "6RHsYmuqCG8YUpaX6u14Gg=="
```
```
ipsec verify
systemctl enable ipsec
systemctl start ipsec
```
```
tailf /var/log/pluto.log
    ……
    IPsec SA established tunnel mode  #看到日志为建立隧道成功
```
* 查看ipsec建立情况
```
ipsec auto --status
```

### 防火墙策略开放ipsec端口（udp500 和 udp4500）
```
针对 Internet Key Exchange (IKE) 协议的 UDP 端口 500
针对 IKE NAT-Traversal的 UDP 端口 4500
```

# 添加iptables转发规则
```
我们的VPN已经可以拨号了，但是还不能访问vpnserver后面的子网。最后一步就是添加iptables转发规则了，输入下面的指令：
iptables -t nat -A POSTROUTING -s 172.30.0.0/16 -o eth0 -j MASQUERADE
###iptables -t nat -A POSTROUTING -s 192.168.221.0/24 ! -d 172.31.0.0/16 -o enp3s0 -j SNAT --to-source 43.242.141.182
```



