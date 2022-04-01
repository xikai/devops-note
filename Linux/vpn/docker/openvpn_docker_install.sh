#!/bin/bash
# ref: https://hub.docker.com/r/kylemanna/openvpn
# 默认Enable default route,所有客户端数据包通过openvpn服务器的网关路由转发
# author: xikai

SERVER_IP=117.50.126.203
VPN_SUBNET=10.7.0.0/24

mkdir -p /opt/openvpn/client

# 开启系统IP转发
sysctl -w net.ipv4.ip_forward=1
sysctl -p

#生成openvpn配置文件（udp://openvpn_server_public_ip）
#    echo "usage: $0 [-d]"
#    echo "                  -u SERVER_PUBLIC_URL"
#    echo "                 [-e EXTRA_SERVER_CONFIG ]"
#    echo "                 [-E EXTRA_CLIENT_CONFIG ]"
#    echo "                 [-f FRAGMENT ]"
#    echo "                 [-n DNS_SERVER ...]"
#    echo "                 [-p PUSH ...]"  -p "route 172.22.48.0 255.255.240.0"
#    echo "                 [-r ROUTE ...]" -r 10.99.0.0/24
#    echo "                 [-s SERVER_SUBNET]"
#    echo
#    echo "optional arguments:"
#    echo " -2    Enable two factor authentication using Google Authenticator."
#    echo " -a    Authenticate  packets with HMAC using the given message digest algorithm (auth)."
#    echo " -b    Disable 'push block-outside-dns'"
#    echo " -c    Enable client-to-client option"
#    echo " -C    A list of allowable TLS ciphers delimited by a colon (cipher)."
#    echo " -d    Disable default route"
#    echo " -D    Do not push dns servers"
#    echo " -k    Set keepalive. Default: '10 60'"
#    echo " -m    Set client MTU"
#    echo " -N    Configure NAT to access external server network"
#    echo " -t    Use TAP device (instead of TUN device)"
#    echo " -T    Encrypt packets with the given cipher algorithm instead of the default one (tls-cipher)."
#    echo " -z    Enable comp-lzo compression."
docker run -v /opt/openvpn:/etc/openvpn --rm kylemanna/openvpn:2.4 ovpn_genconfig -D -d -b -z -u udp://$SERVER_IP -s $VPN_SUBNET

#初始化pki生成密钥文件（需要交互）
docker run -v /opt/openvpn:/etc/openvpn --rm -it kylemanna/openvpn:2.4 ovpn_initpki nopass

#启动openvpn server
docker run --name openvpn -v /opt/openvpn:/etc/openvpn -d -p 1194:1194/udp --cap-add=NET_ADMIN kylemanna/openvpn:2.4


# 创建VPN用户
cat > /opt/openvpn/add_vpn_user.sh << EOF
#!/bin/bash
read -p "please your username: " NAME
#生成客户端证书
docker run -v /opt/openvpn:/etc/openvpn --rm -it kylemanna/openvpn:2.4 easyrsa build-client-full \$NAME nopass
#导出客户端证书
docker run -v /opt/openvpn:/etc/openvpn --rm kylemanna/openvpn:2.4 ovpn_getclient \$NAME > /opt/openvpn/client/\$NAME.ovpn
docker restart openvpn
EOF

# 删除VPN用户
cat > /opt/openvpn/del_vpn_user.sh << EOF
#!/bin/bash
read -p "Delete username: " DNAME
docker run -v /opt/openvpn:/etc/openvpn --rm -it kylemanna/openvpn:2.4 easyrsa revoke \$DNAME
docker run -v /opt/openvpn:/etc/openvpn --rm -it kylemanna/openvpn:2.4 easyrsa gen-crl
docker run -v /opt/openvpn:/etc/openvpn --rm -it kylemanna/openvpn:2.4 rm -f /etc/openvpn/pki/reqs/\$DNAME.req
docker run -v /opt/openvpn:/etc/openvpn --rm -it kylemanna/openvpn:2.4 rm -f /etc/openvpn/pki/private/\$DNAME.key
docker run -v /opt/openvpn:/etc/openvpn --rm -it kylemanna/openvpn:2.4 rm -f /etc/openvpn/pki/issued/\$DNAME.crt
docker run -v /opt/openvpn:/etc/openvpn --rm -it kylemanna/openvpn:2.4 rm -f /etc/openvpn/client/\$DNAME.ovpn
docker restart openvpn
EOF

chmod +x /opt/openvpn/add_vpn_user.sh
chmod +x /opt/openvpn/del_vpn_user.sh


# 开启VPNSERVER后端子网路由
# 推送路由信息到客户端，允许客户端访问VPN服务器可访问的其他局域网
# vim openvpn.conf添加：
# push "route 172.22.0.0 255.255.240.0"
# push "route 172.22.16.0 255.255.240.0"
# push "route 172.22.32.0 255.255.240.0"
# docker restart openvpn

# 在vpnserver添加一条路由让10.7.0.0网段的流量 从服务器LAN网卡eth0路由转发出去
# iptables -t nat -A POSTROUTING -s 10.7.0.0/24 -o eth0 -j MASQUERADE