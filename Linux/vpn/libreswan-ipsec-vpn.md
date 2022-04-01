* https://libreswan.org/
* https://cshihong.github.io/2019/04/03/IPSec-VPN%E4%B9%8BIKE%E5%8D%8F%E8%AE%AE%E8%AF%A6%E8%A7%A3/

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
    virtual_private=%v4:192.168.0.0/16,%v4:10.0.8.0/24,%v4:172.31.0.0/16
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
    ike=aes128-sha1     # 指定ike算法
    ikelifetime=28800s

    ### phase 2 ###
    phase2=esp
    phase2alg=aes128-sha1
    salifetime=3600s
    #pfs=yes            # 指定是否加密
    rekey=yes
    keyingtries=%forever
    dpddelay=10
    dpdtimeout=60
    dpdaction=restart_by_peer
    auto=start          # 指定连接添加类型。start 为开机自启，add为添加 不主动连接

    left=%defaultroute
    leftid=52.89.28.84
    leftsubnet=172.31.0.0/16
    leftnexthop=%defaultroute
    right=43.242.141.182
    rightsubnet=192.168.0.0/16
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
    virtual_private=%v4:192.168.0.0/16,%v4:10.0.8.0/24,%v4:172.31.0.0/16
    nat_traversal=yes
    protostack=netkey
include /etc/ipsec.d/*.conf
```

* vim /etc/ipsec.d/hk_aws.conf
```
conn vpn
    type=tunnel
    authby=secret
    keyexchange=ike
    ike=aes128-sha1
    ikelifetime=28800s

    phase2=esp
    phase2alg=aes128-sha1
    salifetime=3600s
    #pfs=yes
    rekey=yes
    keyingtries=%forever
    dpddelay=10
    dpdtimeout=60
    dpdaction=restart_by_peer
    auto=start

    left=%defaultroute
    leftid=43.242.141.182
    leftnexthop=%defaultroute
    leftsubnet=192.168.0.0/16
    right=52.89.28.84
    rightsubnet=172.31.0.0/16
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

### 防火墙策略开发udp500 和 udp4500端口
```
针对 Internet Key Exchange (IKE) 协议的 UDP 端口 500
针对 IKE NAT-Traversal的 UDP 端口 4500
```





