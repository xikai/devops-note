* https://github.com/hwdsl2/docker-ipsec-vpn-server/blob/master/README-zh.md
* https://github.com/hwdsl2/docker-ipsec-vpn-server/blob/master/docs/advanced-usage-zh.md

# 部署vpnserver
* vim /opt/ipsec-vpn-docker/vpn.env
```
VPN_IPSEC_PSK=h8YjhadR6NkaTtTk4rui
VPN_USER=vpnuser
VPN_PASSWORD=rXUCmTxqwiDXnnN5
```

* vim /opt/ipsec-vpn-docker/install.sh
```sh
docker run \
    --name ipsec-vpn-server \
    --restart=always \
    #--network=host \       #VPN客户端可以使用 Docker 主机的 VPN 内网 IP 192.168.42.1 访问主机上的端口或服务
    -v "$(pwd)/vpn.env:/opt/src/env/vpn.env:ro" \
    #-v ikev2-vpn-data:/etc/ipsec.d \   #不启用ikev2,只使用IPsec/L2TP和IPsec/XAuth (Cisco IPsec)方式连接VPN
    -v /lib/modules:/lib/modules:ro \
    -p 500:500/udp \
    -p 4500:4500/udp \
    -d --privileged \
    hwdsl2/ipsec-vpn-server
```


* 查看vpn服务端连接信息
```
[root@middleware2 ipsec-vpn-server]# docker logs ipsec-vpn-server

VPN credentials not set by user. Generating random PSK and password...

Trying to auto discover IP of this server...

Starting IPsec service...

================================================

IPsec VPN server is now ready for use!

Connect to your new VPN with these details:

Server IP: 34.121.103.159
IPsec PSK: xxxxxxxxxx
Username: vpnuser
Password: yyyyyyyyyyy
```

>防火墙|安全组需要开放UDP端口：1701、500、4500


# VPN配置
* vim ./vpn.env
```
# 新增vpn用户
VPN_ADDL_USERS=additional_username_1 additional_username_2
VPN_ADDL_PASSWORDS=additional_password_1 additional_password_2
# 为VPN客户端指定静态IP
VPN_ADDL_IP_ADDRS=* 192.168.43.2

# 配置其它DNS服务器
VPN_DNS_SRV1=1.1.1.1
VPN_DNS_SRV2=1.0.0.1

# 禁用 IPsec/L2TP 模式：
VPN_DISABLE_IPSEC_L2TP=yes
# 禁用 IPsec/XAuth ("Cisco IPsec") 模式：
VPN_DISABLE_IPSEC_XAUTH=yes
# 禁用 IPsec/L2TP 和 IPsec/XAuth 模式：
VPN_IKEV2_ONLY=yes

# 配置vpn地址池
VPN_L2TP_POOL=192.168.42.100-192.168.42.250
```
* 重启生效
```
docker restart ipsec-vpn-server
```

# 添加路由
* 客户端如果要访问vpnserver后面的子网，需要在客户端本地添加路由
```
# route add -net 目标网段/子网长度 下一跳IP（获取的vpn客户端IP）
sudo route add -net 10.128.0.0/20 192.168.42.1
```
* 删除路由
```
sudo route delete -net 10.128.0.0/20
```