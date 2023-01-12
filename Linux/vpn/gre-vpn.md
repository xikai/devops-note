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

* 启用ipv4转发以及关闭rp_filter
```
#重启失效
echo 1 > /proc/sys/net/ipv4/ip_forward
echo 0 > /proc/sys/net/ipv4/conf/default/rp_filter

#永久生效
vim /etc/sysctl.conf
net.ipv4.ip_forward = 1
net.ipv4.conf.default.rp_filter = 0

#生效配置
sysctl -p
```


# host_aws
> public_ip:18.166.180.137 , private_subnet: 10.30.0.0/16
```
cat > /etc/sysconfig/network-scripts/ifcfg-grevpn <<EOF
DEVICE=grevpn
BOOTPROTO=none
ONBOOT=yes
DEVICETYPE=tunnel
TYPE=GRE

# 本地外部(联网的)私有IP
MY_OUTER_IPADDR=10.30.47.220
# 本地隧道IP（两端必须同网段）
MY_INNER_IPADDR=192.168.0.2

# 对端外部(联网的)IP
PEER_OUTER_IPADDR=103.50.252.2
# 对端隧道IP（两端必须同网段）
PEER_INNER_IPADDR=192.168.0.1
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

----------------------------------------------------------------
# host_office（office）
> public_ip:103.50.252.2 , private_subnet: 172.16.0.0/24
```
cat > /etc/sysconfig/network-scripts/ifcfg-grevpn <<EOF
DEVICE=grevpn
BOOTPROTO=none
ONBOOT=yes
DEVICETYPE=tunnel
TYPE=GRE

# 本地外部(联网的)私有IP
MY_OUTER_IPADDR=172.16.0.114
# 本地隧道IP
MY_INNER_IPADDR=192.168.0.1

# 对端外部(联网的)IP
PEER_OUTER_IPADDR=18.166.180.137
# 对端隧道IP
PEER_INNER_IPADDR=192.168.0.2
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


# [cisco router（office）](https://image.ruijie.com.cn/Upload/Article/bc0fae82-6898-457d-ae7c-3a7113c1fc94/%E8%B7%AF%E7%94%B1%E4%BA%A7%E5%93%81/%E8%B7%AF%E7%94%B1%E4%BA%A7%E5%93%81/2018092015001400267.html)
* https://image.ruijie.com.cn/Upload/Article/bc0fae82-6898-457d-ae7c-3a7113c1fc94/%E8%B7%AF%E7%94%B1%E4%BA%A7%E5%93%81/%E8%B7%AF%E7%94%B1%E4%BA%A7%E5%93%81/
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
Ruijie(config)#interface Tunnel 1
Ruijie(config-if-Tunnel 1)#ip address 192.168.0.1 255.255.255.0
Ruijie(config-if-Tunnel 1)#tunnel source 103.50.252.2
Ruijie(config-if-Tunnel 1)#tunnel destination 18.166.180.137
Ruijie(config-if-Tunnel 1)#exit
Ruijie(config)#ip route 10.30.0.0 255.255.0.0 Tunnel 1 192.168.0.2 
Ruijie#write
```
```
# 查看路由表
Ruijie#show ip route
# 删除路由
Ruijie(config)#no ip route 10.30.0.0 255.255.0.0
# 关闭接口
Ruijie(config-if-Tunnel 1)# shutdown
Ruijie(config-if-Tunnel 1)#no shutdown   # 开启接口

# 查看所有接口
Ruijie#show ip interface brief
# 查看指定接口
Ruijie#show interface Tunnel 1
```


# 其它网络配置（非必须配置）
* 调整隧道MTU(两端都需要)
```
ifconfig grevpn mtu 1500
ifdown grevpn
ifup grevpn
```

* 配置转发
```
iptables -t nat -A POSTROUTING -s 172.16.0.0/23 -d 10.40.0.0/16 -o eth0 -j MASQUERADE
```

* gre隧道协议
```
自定义协议名：47
```