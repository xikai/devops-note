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
openssl rand -base64 48
 63I3J3wzjjke5QVTcQGBMeNAliiktDX836gK8dFW+kdUn7ynXTMzQDTz5w3qZvDZ
```

### AWS(52.89.28.84):
* vim /etc/ipsec.conf
```
config setup
    protostack=netkey
    logfile=/var/log/pluto.log
    dumpdir=/var/run/pluto/
    virtual_private=%v4:192.168.0.0/16,%v4:10.0.8.0/24,%v4:172.31.0.0/16
include /etc/ipsec.d/*.conf
```

* vim /etc/ipsec.d/aws_hk.conf
```
conn vpn
    type=tunnel
    authby=secret
    left=%defaultroute
    leftid=52.89.28.84
    leftnexthop=%defaultroute
    leftsubnet=172.31.0.0/16
    right=43.242.141.182
    rightsubnet=192.168.0.0/16
    phase2=esp
    phase2alg=aes128-sha1
    ike=aes128-sha1
    ikelifetime=28800s
    salifetime=3600s
    pfs=yes
    auto=start
    rekey=yes
    keyingtries=%forever
    dpddelay=10
    dpdtimeout=60
    dpdaction=restart_by_peer
```

* vim /etc/ipsec.d/ipsec.secrets
```
52.89.28.84  43.242.141.182 : PSK "63I3J3wzjjke5QVTcQGBMeNAliiktDX836gK8dFW+kdUn7ynXTMzQDTz5w3qZvDZ"
```

### HK(43.242.141.182):
* vim /etc/ipsec.conf
```
config setup
    protostack=netkey
    nat_traversal=yes   #l2tp vpn中需要配置
    logfile=/var/log/pluto.log
    dumpdir=/var/run/pluto/
    virtual_private=%v4:192.168.0.0/16,%v4:10.0.8.0/24,%v4:172.31.0.0/16
include /etc/ipsec.d/*.conf
```

* vim /etc/ipsec.d/hk_aws.conf
```
conn vpn
    type=tunnel
    authby=secret
    left=%defaultroute
    leftid=43.242.141.182
    leftnexthop=%defaultroute
    leftsubnet=192.168.0.0/16
    right=52.89.28.84
    rightsubnet=172.31.0.0/16
    phase2=esp
    phase2alg=aes128-sha1
    ike=aes128-sha1
    ikelifetime=28800s
    salifetime=3600s
    pfs=yes
    auto=start
    rekey=yes
    keyingtries=%forever
    dpddelay=10
    dpdtimeout=60
    dpdaction=restart_by_peer
```

* vim /etc/ipsec.d/ipsec.secrets
```
43.242.141.182 52.89.28.84 : PSK "63I3J3wzjjke5QVTcQGBMeNAliiktDX836gK8dFW+kdUn7ynXTMzQDTz5w3qZvDZ"
```
```
systemctl start ipsec
systemctl enable ipsec
```


### L2TP VPN
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

* vim /etc/xl2tpd/xl2tpd.conf
```
[global]
 listen-addr = 0.0.0.0
 ipsec saref = yes
[lns default]
ip range = 192.168.221.200-192.168.221.250
local ip = 192.168.221.253
require chap = yes
refuse pap = yes
require authentication = yes
name = L2TPVPNserver
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

systemctl start xl2tpd
systemctl enable xl2tpd
systemctl restart ipsec
```

### pptpd vpn
> 检查服务器是否有必要的支持
```
modprobe ppp-compress-18 && echo ok
 ok
# cat /dev/net/tun
cat: /dev/net/tun: File descriptor in bad state
```

* 安装pptpd
```
yum install -y ppp pptpd iptables

#安装pptp.这个软件在yum源里是没有的,我们需要手动下载,去官网下载https://pkgs.org/download/pptpd
wget http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/p/pptpd-1.4.0-2.el7.x86_64.rpm
rpm -ivh pptpd-1.4.0-2.el7.x86_64.rpm
```

* vim /etc/pptpd.conf
```
option /etc/ppp/options.pptpd
connections 100
localip 192.168.221.252       #给vpn服务器设置一个隧道ip
remoteip 192.168.221.150-199  #分配给vpn client的ip范围
```

* vim /etc/ppp/options.pptpd 配置DNS
```
idle 259200             #72个小时空闲断开 
ms-dns 8.8.8.8  
```

### 其它配置
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

systemctl start pptpd
systemctl enable pptpd  
```

### pptpd成功连接后发现有些网站无法打开，然后搜索了一下大概是因为MTU设置不合理造成的
>在pptpd的安装目录下面建立一个ip-up.local脚本，当有用户拨号上来的时候，自动修改MTU的值
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





