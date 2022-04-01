# 配置ipsec
```
yum install ppp xl2tpd iptables -y
```

* vim /etc/ipsec.d/l2tp_psk.conf
```
conn L2TP-PSK-NAT
    rightsubnet=vhost:%priv
    also=L2TP-PSK-noNAT
conn L2TP-PSK-noNAT
    authby=secret
    pfs=no
    auto=start
    keyingtries=3
    dpddelay=30
    dpdtimeout=120
    dpdaction=clear
    rekey=no
    ikelifetime=8h
    keylife=1h
    type=transport
    left=43.242.141.182
    leftprotoport=17/1701
    right=%any
    rightprotoport=17/%any
```

* vim /etc/ipsec.d/l2tp_psk.secrets
```
43.242.141.182 %any : PSK "123456789"
```

# 配置l2tp
* vim /etc/xl2tpd/xl2tpd.conf
```
[global]
 listen-addr = 0.0.0.0
 port = 1701

[lns default]
ip range = 192.168.221.200-192.168.221.250
local ip = 192.168.221.253
require chap = yes
refuse pap = yes
require authentication = yes
name = "L2TP VPNserver"
ppp debug = yes
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
```

* vim /etc/ppp/options.xl2tpd
```
idle 259200             #72个小时空闲断开 
mtu 1500                #查看ifconfig与本地网卡MTU值匹配
mru 1500
ms-dns 8.8.8.8
```
```
systemctl start ipsec
systemctl enable ipsec
systemctl start xl2tpd
systemctl enable xl2tpd
```

# 其它配置
```
# 设置VPN账号密码
#vim /etc/ppp/chap-secrets  
xikai	pptpd	tomtop@tt	*
xikai	l2tpd	tomtop@tt	*
xik	*	tomtop@tt	*

# 添加iptables转发规则。
我们的VPN已经可以拨号了，但是还不能访问任何网页。最后一步就是添加iptables转发规则了，输入下面的指令：
iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -o eth0 -j MASQUERADE
###iptables -t nat -A POSTROUTING -s 192.168.221.0/24 ! -d 172.31.0.0/16 -o enp3s0 -j SNAT --to-source 43.242.141.182
```

### 成功连接后发现有些网站无法打开，然后搜索了一下大概是因为MTU设置不合理造成的
>在ppp安装目录下面建立一个ip-up.local脚本，当有用户拨号上来的时候，自动修改MTU的值
* vim /etc/ppp/ip-up.local
```
#!/bin/bash
PATH=/sbin:/usr/sbin:/bin:/usr/bin
export PATH
ifconfig $1 mtu 1500  #查看ifconfig与本地网卡MTU值匹配
```
```
chmod +x /etc/ppp/ip-up.local
```