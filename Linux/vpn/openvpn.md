* https://openvpn.net/community-resources/how-to/
* http://blog.joylau.cn/2020/05/28/OpenVPN-Config/
* https://community.openvpn.net/openvpn/wiki/RoutedLans#no1

# 安装openvpn
```
yum install openvpn easy-rsa openssl openssl-devel
```

# [使用easy-rsa生成主证书颁发机构 (CA) 证书和密钥](https://github.com/OpenVPN/easy-rsa/blob/master/README.quickstart.md)
```
cp -r /usr/share/easy-rsa /etc/openvpn/
cp /usr/share/doc/easy-rsa-3.0.8/vars.example /etc/openvpn/easy-rsa/3.0.8/vars
cd /etc/openvpn/easy-rsa/3.0.8
```
```
# egrep 'set_var' vars    #将下面几行注释去掉，并修改为：
set_var EASYRSA_REQ_COUNTRY	"CN"
set_var EASYRSA_REQ_PROVINCE	"GD"
set_var EASYRSA_REQ_CITY	"SZ"
set_var EASYRSA_REQ_ORG	"vevor"
set_var EASYRSA_REQ_EMAIL	"vevor@123.com"
set_var EASYRSA_REQ_OU		"IT"
```

* 初始化pki目录
```
[root@xinnet-baoleiji 3.0.8]# ./easyrsa init-pki
Note: using Easy-RSA configuration from: /etc/openvpn/easy-rsa/3.0.8/vars

init-pki complete; you may now create a CA or requests.
Your newly created PKI dir is: /etc/openvpn/easy-rsa/3.0.8/pki
```

* 以无密码方式，创建服务器ca文件
```
[root@xinnet-baoleiji 3.0.8]# ./easyrsa build-ca nopass
Note: using Easy-RSA configuration from: /etc/openvpn/easy-rsa/3.0.8/vars
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating RSA private key, 2048 bit long modulus
......................................................+++
.............+++
e is 65537 (0x10001)
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:

CA creation complete and you may now import and sign cert requests.
Your new CA certificate file for publishing is at:
/etc/openvpn/easy-rsa/3.0.8/pki/ca.crt
```

* 创建服务器端证书
```
[root@xinnet-baoleiji 3.0.8]# ./easyrsa gen-req server nopass

Note: using Easy-RSA configuration from: /etc/openvpn/easy-rsa/3.0.8/vars
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating a 2048 bit RSA private key
.....................................................................................+++
.............................................................................................................................+++
writing new private key to '/etc/openvpn/easy-rsa/3.0.8/pki/easy-rsa-29702.69FO7a/tmp.0vwwmK'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [server]:

Keypair and certificate request completed. Your files are:
req: /etc/openvpn/easy-rsa/3.0.8/pki/reqs/server.req
key: /etc/openvpn/easy-rsa/3.0.8/pki/private/server.key
```

* 使用CA对服务器端的证书进行签名
```
[root@xinnet-baoleiji 3.0.8]# ./easyrsa sign server server

Note: using Easy-RSA configuration from: /etc/openvpn/easy-rsa/3.0.8/vars
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017


You are about to sign the following certificate.
Please check over the details shown below for accuracy. Note that this request
has not been cryptographically verified. Please be sure it came from a trusted
source or that you have verified the request checksum with the sender.

Request subject, to be signed as a server certificate for 825 days:

subject=
    commonName                = server


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes
Using configuration from /etc/openvpn/easy-rsa/3.0.8/pki/easy-rsa-29952.NkJu0P/tmp.C53V2E
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'server'
Certificate is to be certified until Feb  8 04:08:17 2024 GMT (825 days)

Write out database with 1 new entries
Data Base Updated

Certificate created at: /etc/openvpn/easy-rsa/3.0.8/pki/issued/server.crt
```

* 创建 dh 秘钥（耗时稍微长一些）
```
[root@xinnet-baoleiji 3.0.8]# ./easyrsa gen-dh

Note: using Easy-RSA configuration from: /etc/openvpn/easy-rsa/3.0.8/vars
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating DH parameters, 2048 bit long safe prime, generator 2
This is going to take a long time
...................................................+.............+......................................++*++*

DH parameters of size 2048 created at /etc/openvpn/easy-rsa/3.0.8/pki/dh.pem
```

* 拷贝证书
```
cp /etc/openvpn/easy-rsa/3.0.8/pki/ca.crt /etc/openvpn/server
cp /etc/openvpn/easy-rsa/3.0.8/pki/private/server.key /etc/openvpn/server
cp /etc/openvpn/easy-rsa/3.0.8/pki/issued/server.crt /etc/openvpn/server
cp /etc/openvpn/easy-rsa/3.0.8/pki/dh.pem /etc/openvpn/server
```

# 配置openvpn server
```
cp /usr/share/doc/openvpn-2.4.11/sample/sample-config-files/server.conf /etc/openvpn/server.conf.bak
```
* vim /etc/openvpn/server.conf
```
local 0.0.0.0
port 1194
proto udp
dev tun
ca /etc/openvpn/server/ca.crt
cert /etc/openvpn/server/server.crt
key /etc/openvpn/server/server.key
dh /etc/openvpn/server/dh.pem
#tls-auth /etc/openvpn/server/ta.key 0
server 10.7.0.0 255.255.255.0
# 推送路由信息到客户端，以允许客户端能够连接到服务器后的其他私有子网，即允许客户端访问VPN服务器可访问的其他局域网(需要在vpnserver添加一条路由让10.7.0.0网段的流量 从服务器LAN网卡eth0路由转发出去： iptables -t nat -A POSTROUTING -s 10.7.0.0/24 -o eth0 -j MASQUERADE)
push "route 172.22.0.0 255.255.240.0"
push "route 172.22.16.0 255.255.240.0"
push "route 172.22.32.0 255.255.240.0"
#push "redirect-gateway def1 bypass-dhcp"   #推送网关及DHCP配置到客户端，让客户端所有流量都通过VPN代理转发
#向windows客户端推送DNS服务器地址
#push "dhcp-option DNS 208.67.222.222"
#push "dhcp-option DNS 208.67.220.220"
compress lzo       
duplicate-cn       #允许同一个客户端证书多次登录
keepalive 10 120   #每10秒ping一次，连接超时时间设为120秒
comp-lzo           #使用lzo压缩的通讯,服务端和客户端都必须配置
#重启时仍保留一些状态
persist-key       
persist-tun
user openvpn
group openvpn
log         /var/log/openvpn/openvpn.log
log-append  /var/log/openvpn/openvpn.log
status /var/log/openvpn/openvpn-status.log
verb 3          #指定日志文件的记录详细级别，可选0-9，等级越高日志内容越详细 
explicit-exit-notify 1
```

* 开启系统IP转发
```
# vim /etc/sysctl.conf
net.ipv4.ip_forward = 1
```
```
sysctl -p
```

* 启动openvpn server
```
mkdir /var/log/openvpn
chown openvpn.openvpn /var/log/openvpn
openvpn --daemon --config server.conf
```
```
[Unit]
Description=OpenVPN Robust And Highly Flexible Tunneling Application On %I
After=network.target

[Service]
Type=simple
PrivateTmp=true
ExecStart=/usr/sbin/openvpn --cd /etc/openvpn/ --config %i.conf

[Install]
WantedBy=multi-user.target
```

# 配置openvpn client
* 生成客户端证书
```
# cd /etc/openvpn/easy-rsa/3.0.8
# ./easyrsa gen-req xikai nopass
Note: using Easy-RSA configuration from: /etc/openvpn/easy-rsa/3.0.8/vars
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating a 2048 bit RSA private key
..................+++
.................................+++
writing new private key to '/etc/openvpn/easy-rsa/3.0.8/pki/easy-rsa-3961.ME9A2u/tmp.Tr75qU'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [xikai]:

Keypair and certificate request completed. Your files are:
req: /etc/openvpn/easy-rsa/3.0.8/pki/reqs/xikai.req
key: /etc/openvpn/easy-rsa/3.0.8/pki/private/xikai.key
```

* 用CA证书对客户端证书进行签名(只有签名证书客户端才能使用证书登录 vpn)
```
# ./easyrsa sign client xikai
Note: using Easy-RSA configuration from: /etc/openvpn/easy-rsa/3.0.8/vars
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017


You are about to sign the following certificate.
Please check over the details shown below for accuracy. Note that this request
has not been cryptographically verified. Please be sure it came from a trusted
source or that you have verified the request checksum with the sender.

Request subject, to be signed as a client certificate for 825 days:

subject=
    commonName                = xikai


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes
Using configuration from /etc/openvpn/easy-rsa/3.0.8/pki/easy-rsa-4060.ccr0I5/tmp.fTTGDo
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'xikai'
Certificate is to be certified until Feb  8 05:58:50 2024 GMT (825 days)

Write out database with 1 new entries
Data Base Updated

Certificate created at: /etc/openvpn/easy-rsa/3.0.8/pki/issued/xikai.crt
```

* client配置文件
```
cp /usr/share/doc/openvpn-2.4.11/sample/sample-config-files/client.conf /etc/openvpn/client.conf.bak
```
* vim xikai.ovpn
```
client
proto udp
dev tun
remote 117.50.126.193 1194
ca ca.crt
cert xikai.crt
key xikai.key
#tls-auth ta.key 1
resolv-retry infinite
remote-cert-tls server
cipher AES-256-CBC
persist-tun
persist-key
comp-lzo
verb 3
mute-replay-warnings

#所有流量通过openvpn网卡走
#redirect-gateway def1
#部分网段通过openvpn网卡走
#route-nopull
#route 192.168.4.0 255.255.255.0 vpn_gateway
#vpn客户端指定DNS服务器
#dhcp-option DNS 103.24.176.20
```
* 拷贝客户端证书
```
cp /etc/openvpn/easy-rsa/3.0.8/pki/ca.crt /etc/openvpn/client
cp /etc/openvpn/easy-rsa/3.0.8/pki/issued/xikai.crt /etc/openvpn/client
cp /etc/openvpn/easy-rsa/3.0.8/pki/private/xikai.key /etc/openvpn/client
```

* 查看用户证书
```
./easyrsa show-req EntityName
./easyrsa show-cert EntityName
```

* 撤销用户证书
```
./easyrsa revoke EntityName
./easyrsa gen-crl
```

# [openvpn-connect](https://openvpn.net/vpn-client/)
* 安装：https://openvpn.net/downloads/openvpn-connect-v3-macos.dmg
* 下发ca.crt、xikai.crt、xikai.key证书文件到客户端
```
tar czf xikai.tar.gz ca.crt  xikai.crt  xikai.key xikai.ovpn
scp root@117.50.126.193:/etc/openvpn/client/xikai.tar.gz ~/Desktop
```

* 网络测试（vpnserver虚拟地址池网关）
```
14:58 $ ping 10.7.0.1
PING 10.7.0.1 (10.7.0.1): 56 data bytes
64 bytes from 10.7.0.1: icmp_seq=0 ttl=64 time=44.553 ms
64 bytes from 10.7.0.1: icmp_seq=1 ttl=64 time=46.091 ms
64 bytes from 10.7.0.1: icmp_seq=2 ttl=64 time=45.310 ms
```
```
# vpnserver后面的其它子网
15:05 $ ping 172.22.0.9
PING 172.22.0.9 (172.22.0.9): 56 data bytes
64 bytes from 172.22.0.9: icmp_seq=0 ttl=63 time=49.064 ms
64 bytes from 172.22.0.9: icmp_seq=1 ttl=63 time=76.990 ms
64 bytes from 172.22.0.9: icmp_seq=2 ttl=63 time=49.890 ms
64 bytes from 172.22.0.9: icmp_seq=3 ttl=63 time=53.051 ms
```

---
# [配置客户端规则访问策略](https://openvpn.net/community-resources/how-to/#configuring-client-specific-rules-and-access-policies)

* 为不同client角色分配不同网段虚拟IP
```
# vpn client roles
Employee    10.8.0.0/24
Sysadmin    10.8.1.0/24
Contractor  10.8.2.0/24
```
* 配置server
```
dev tun0
# 为Employee分配虚拟IP，Sysadmin和Contractor通过ccd配置固定IP
server 10.8.0.0 255.255.255.0
# 为Sysadmin和Contractor添加路由
route 10.8.1.0 255.255.255.0
route 10.8.2.0 255.255.255.0
client-config-dir ccd  #开启客户端配置目录
```
* 新建ccd目录及客户端文件：在/etc/openvpn/下新建ccd目录，在ccd目录下新建以用户名命名的文件，并且通过ifconfig-push分配地址，注意这里需要分配两个地址，一个是客户端本地地址，另一个是服务器的ip端点
```
# 在配置固定IP时，掩码必须为/30
#ccd/sysadmin1
ifconfig-push 10.8.1.1 10.8.1.2
#ccd/contractor1
ifconfig-push 10.8.2.1 10.8.2.2
#ccd/contractor2
ifconfig-push 10.8.2.5 10.8.2.6
```
* 配置iptables规则
```
# Employee rule
iptables -A FORWARD -i tun0 -s 10.8.0.0/24 -d 10.66.4.4 -j ACCEPT

# Sysadmin rule
iptables -A FORWARD -i tun0 -s 10.8.1.0/24 -d 10.66.4.0/24 -j ACCEPT

# Contractor rule
iptables -A FORWARD -i tun0 -s 10.8.2.0/24 -d 10.66.4.12 -j ACCEPT
```

# 客户端通过用户名密码连接VPN
* 配置服务端使用脚本认证插件
```
# vim server.conf
#客户端不进行证书认证，如果不加将实现证书和用户密码双重认证
client-cert-not-required

#用户和密码验证脚本
auth-user-pass-verify /etc/openvpn/checkpsw.sh via-env

#使用用户名密码登录认证
username-as-common-name

#脚本安全级别
script-security 3
```

* 验证脚本
```
# vim /etc/openvpn/checkpsw.sh
#!/bin/sh
###########################################################
# checkpsw.sh (C) 2004 Mathias Sundman <mathias@openvpn.se>
PASSFILE="/etc/openvpn/pwd-file"
LOG_FILE="/var/log/openvpn/openvpn-password.log"
TIME_STAMP=`date "+%Y-%m-%d %T"`
###########################################################
if [ ! -r "${PASSFILE}" ]; then
  echo "${TIME_STAMP}: Could not open password file \"${PASSFILE}\" for reading." >> ${LOG_FILE}
  exit 1
fi
CORRECT_PASSWORD=`awk '!/^;/&&!/^#/&&$1=="'${username}'"{print $2;exit}' ${PASSFILE}`
if [ "${CORRECT_PASSWORD}" = "" ]; then 
  echo "${TIME_STAMP}: User does not exist: username=\"${username}\", password=\"${password}\"." >> ${LOG_FILE}
  exit 1
fi
if [ "${password}" = "${CORRECT_PASSWORD}" ]; then 
  echo "${TIME_STAMP}: Successful authentication: username=\"${username}\"." >> ${LOG_FILE}
  exit 0
fi
echo "${TIME_STAMP}: Incorrect password: username=\"${username}\", password=\"${password}\"." >> ${LOG_FILE}
exit 1
```

* 创建脚本和用户密码文件
```
yum install expect
mkpasswd -l 15
```
```
# vim pwd-file 
xikai ukhvlhv30bCti2Y
```
```
chmod 755 checkpsw.sh
chmod 400 pwd-file
chown openvpn.openvpn pwd-file
chown openvpn.openvpn checkpsw.sh
```
* 重启openvpn server
```
pkill openvpn
openvpn --daemon --config server.conf
```

* vpn client开启密码认证
```
# vim client.ovpn
auth-user-pass 
```