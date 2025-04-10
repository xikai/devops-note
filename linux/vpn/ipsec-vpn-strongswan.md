* https://docs.strongswan.org
* https://www.alibabacloud.com/help/zh/vpn/user-guide/configure-strongswan

# 环境准备
* subnet to subnet vpn
```
strongwan server (ec2):
外网：52.82.96.246
内网：172.28.37.86

beijing-office (router):
外网：103.85.179.136
内网：192.168.102.0/24,192.168.106.0/24

hangzhou-office (router):
外网：39.170.98.96
内网：192.168.115.0/24,192.168.116.0/24,192.168.120.0/22,192.168.118.0/24
```

# [安装strongwan](https://rhel.pkgs.org/7/epel-x86_64/strongswan-5.7.2-1.el7.x86_64.rpm.html)
```
yum install amazon-linux-extras
amazon-linux-extras enable epel
yum install strongswan
```

# 配置strongwan server
* 防火墙策略开放ipsec端口（udp500 和 udp4500）
```
针对 Internet Key Exchange (IKE) 协议的 UDP 端口 500
针对 IKE NAT-Traversal的 UDP 端口 4500
```

* 开启系统路由转发，vim /etc/sysctl.conf
```
将“net.ipv4.ip_forward”改为1，变成下面的形式：
net.ipv4.ip_forward=1
保存退出，并执行下面的命令来生效它：
sysctl -p
```

### ipsec配置
* vim /etc/ipsec.conf
```
conn beijing-office
     keyexchange=ikev2
     left=172.28.37.86
     leftsubnet=172.28.0.0/16
     leftid=52.82.96.246
     right=103.85.179.136
     rightsubnet=192.168.102.0/24,192.168.106.0/24
     rightid=103.85.179.136
     auto=start
     ike=aes256-sha256-modp1024
     ikelifetime=86400s
     esp=aes256-sha256-modp1024
     lifetime=86400s
     type=tunnel
     authby=psk

conn hangzhou-office
     keyexchange=ikev2
     left=172.28.37.86
     leftsubnet=172.28.0.0/16
     leftid=52.82.96.246
     right=39.170.98.96
     rightsubnet=192.168.115.0/24,192.168.116.0/24,192.168.120.0/22,192.168.118.0/24
     rightid=39.170.98.96
     auto=start
     ike=aes256-sha256-modp1024
     ikelifetime=86400s
     esp=aes256-sha256-modp1024
     lifetime=86400s
     type=tunnel
     authby=psk
```

### 配置PSK预共享密钥
* vim /etc/strongswan/ipsec.secrets
```
103.85.179.136 : PSK "k9ujf77gDezqwdJi"
39.170.98.96 : PSK "7QgN2GnUg9aDjDqn"
```

# 启动StrongSwan
```
systemctl start strongswan
systemctl enable strongswan
```

### 添加iptables SNAT转发，允许对端子网访问VPNserver子网的其他主机
```
iptables -t nat -A POSTROUTING -s 192.168.0.0/16 -o eth0 -j MASQUERADE
```
