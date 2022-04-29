https://www.cnblogs.com/itfat/p/12563818.html

# 加载gre内核模块
```
modprobe ip_gre
```
```
# lsmod|grep ip_gre
ip_gre                 32768  0
ip_tunnel              32768  1 ip_gre
gre                    16384  1 ip_gre
```

* 启动加载模块
```
echo "/sbin/modprobe ip_gre > /dev/null 2>&1" > /etc/sysconfig/modules/ip_gre.modules
chmod 755 /etc/sysconfig/modules/ip_gre.modules
```

# Host1
> public_ip:4.3.2.1 , private_subnet: 10.30.0.0/16
```
cat > /etc/sysconfig/network-scripts/ifcfg-grevpn <<EOF
DEVICE=grevpn
BOOTPROTO=none
ONBOOT=yes
DEVICETYPE=tunnel
TYPE=GRE

# 对端外部(联网的)IP
PEER_OUTER_IPADDR=1.2.3.4
# 对端隧道IP（两端必须同网段）
PEER_INNER_IPADDR=192.168.0.1

# 本地外部(联网的)IP
MY_OUTER_IPADDR=10.30.47.220
# 本地隧道IP（两端必须同网段）
MY_INNER_IPADDR=192.168.0.2
EOF
```

* 启用隧道
```
ifup grevpn
```

* 添加路由，指定到对端内网走隧道
```
# 重启网卡会恢复路由表
route add -net 172.16.0.0/24 dev grevpn
```

# Host2
> public_ip:1.2.3.4 , private_subnet: 172.16.0.0/24
```
cat > /etc/sysconfig/network-scripts/ifcfg-grevpn <<EOF
DEVICE=grevpn
BOOTPROTO=none
ONBOOT=yes
DEVICETYPE=tunnel
TYPE=GRE

# 对端外部(联网的)IP
PEER_OUTER_IPADDR=4.3.2.1
# 对端隧道IP
PEER_INNER_IPADDR=192.168.0.2

# 本地外部(联网的)IP
MY_OUTER_IPADDR=172.16.0.114
# 本地隧道IP
MY_INNER_IPADDR=192.168.0.1
EOF
```

* 启用隧道
```
ifup grevpn
```

* 添加路由，指定到对端内网走隧道
```
route add -net 10.30.0.0/16 dev grevpn
```

* 添加路由转发,让对端可以访问10.X/16网段
```
iptables -t nat -A POSTROUTING -s 172.16.0.0/23 -d 10.10.0.0/16 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.16.0.0/23 -d 10.20.0.0/16 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.16.0.0/23 -d 10.30.0.0/16 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.16.0.0/23 -d 10.40.0.0/16 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.16.0.0/23 -d 10.50.0.0/16 -o eth0 -j MASQUERADE
```

# [cisco router](https://image.ruijie.com.cn/Upload/Article/bc0fae82-6898-457d-ae7c-3a7113c1fc94/%E8%B7%AF%E7%94%B1%E4%BA%A7%E5%93%81/%E8%B7%AF%E7%94%B1%E4%BA%A7%E5%93%81/2018092015001400267.html)
```
19:14 $ telnet 172.16.0.1
Trying 172.16.0.1...
Connected to 172.16.0.1.
Escape character is '^]'.

User Access Verification

Username:admin
Password:*********


Ruijie#conf t
Enter configuration commands, one per line.  End with CNTL/Z.
Ruijie(config)#interface Tunnel 2
Ruijie(config-if-Tunnel 2)#ip address 192.168.0.1 255.255.255.0
Ruijie(config-if-Tunnel 2)#tunnel source 192.168.8.2
Ruijie(config-if-Tunnel 2)#tunnel destination 4.3.2.1
Ruijie(config-if-Tunnel 2)#exit
Ruijie(config)#ip route 10.30.0.0 255.255.0.0 Tunnel 2 192.168.0.2 
Ruijie(config-if-Tunnel 2)#no shutdown
```


# 其它网络配置
* 调整隧道MTU(两端都需要)
```
ifconfig grevpn mtu 1500
ifdown grevpn
ifup grevpn
```

* 启用ipv4转发以及关闭rp_filter
```
#立即关闭
echo 1 > /proc/sys/net/ipv4/ip_forward
echo 0 > /proc/sys/net/ipv4/conf/default/rp_filter

#修改配置
sed -i 's/^#\?net.ipv4.ip_forward =.*/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf
sed -i 's/^#\?net.ipv4.conf.default.rp_filter =.*/net.ipv4.conf.default.rp_filter = 0/g' /etc/sysctl.conf

#生效配置
sysctl -p
```