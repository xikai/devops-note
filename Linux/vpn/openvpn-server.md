* https://openvpn.net/community-resources/how-to/
* http://blog.joylau.cn/2020/05/28/OpenVPN-Config/
* https://community.openvpn.net/openvpn/wiki/RoutedLans#no1

# 环境准备
- 安装环境：centos7
- VPN源码地址：https://github.com/OpenVPN/openvpn.git
- easy-rsa源码：https://github.com/OpenVPN/easy-rsa.git

1、添加yum源（可选）
```perl
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
yum clean all
yum makecache
```

2、安装软件包和相关依赖包
```perl
# 更新yum源、安装epel
yum update -y
yum install -y epel-release

# 安装相关依赖包
yum install -y openssl openssl-devel lzo lzo-devel pam pam-devel pam_mysql automake pkgconfig gcc gcc-c++ zip ntp ntpdate bridge-utils pkcs11-helper

# 安装openvpn和证书生成工具easy-rsa
yum install -y openvpn easy-rsa openssl openssl-devel
```

3、关闭selinux
```perl
[root@localhost ~]# sed -i '/^SELINUX/s/enforcing/disabled/g' /etc/selinux/config
[root@localhost ~]# setenforce 0
```

4、系统时间与硬件时间同步
```perl
# 查看定时任务同步系统时间
[root@openvpn-server ~]# crontab -l
# 添加定时任务
[root@openvpn-server ~]# crontab -e
*/10 * * * * /usr/sbin/ntpdate ntp1.aliyun.com >/dev/null 2>&1
# 使用上海时间
[root@openvpn-server ~]# ll /etc/localtime
lrwxrwxrwx. 1 root root 33 Mar 9 03:59 /etc/localtime -> /usr/share/zoneinfo/Asia/Shanghai
# 查看硬件时间
[root@openvpn-server ~]# hwclock --show 
Thu 10 Mar 2022 01:32:59 PM CST  -0.943697 seconds
# 系统时间同步到硬件时间
[root@openvpn-server ~]# hwclock --systohc 
说明：如果时间不同步，那么VPN登录访问就可能存在问题。
```

# 生成证书  
**1、配置EASY-RSA 3.0**  
- 创建证书环境目录
```perl
# 复制easy-rsa脚本到 /etc/openvpn/目录，用来生成 CA 证书和各种 key
# 可以根据版本号来进行复制，使用yum info easy-rsa命令来查看版本号
[root@localhost ~]# cp -a /usr/share/easy-rsa /etc/openvpn/
[root@localhost ~]# cp -a /usr/share/doc/easy-rsa-3.0.8/vars.example /etc/openvpn/easy-rsa/3.0.8/vars
```

- 创建 vars 文件,添加内容，详情参考[openvpn配置文件详解](http://note.youdao.com/noteshare?id=f89b4abaf6b98fb4095c68d22e918a4c&sub=96E434572DB04B2B9CF7CC587B48918F)
```perl
#  vars 文件中定义的变量是用于生成证书的基本信息，没这个文件可新建，填写或修改如下内容（我这里是清空文件添加）
[root@localhost ~]# vim /etc/openvpn/easy-rsa/3.0.8/vars
...
set_var EASYRSA_REQ_COUNTRY     "CN"   //你所在国家码，2个字符
set_var EASYRSA_REQ_PROVINCE    "GUANGDONG"   //你所在省份
set_var EASYRSA_REQ_CITY    "SHENZHEN"   //你所在城市
set_var EASYRSA_REQ_ORG     "vevor.com"   //你所在组织
set_var EASYRSA_REQ_EMAIL   "admin@vevor.com"   //你的邮箱地址
set_var EASYRSA_REQ_OU      "vevor"   //拥有者
set_var EASYRSA_KEY_SIZE    2048   //生成密钥的位数
```
**2、初始化并建立CA证书**  

> 我们将创建CA密钥，server端、client端密钥，DH和CRL PEM, TLS认证钥匙ta.key。  
创建服务端和客户端密钥之前，需要初始化PKI目录

- 创建生成ca根证书
```perl
# 初始化 pki 相关目录,用于存储证书
[root@localhost ~]# cd /etc/openvpn/easy-rsa/3.0.8
[root@localhost 3.0.8]# ./easyrsa init-pki
```
输出信息如下：
```
Note: using Easy-RSA configuration from: /etc/openvpn/easy-rsa/3.0.8/vars

init-pki complete; you may now create a CA or requests.
Your newly created PKI dir is: /etc/openvpn/easy-rsa/3.0.8/pki
```

```perl
# 创建根证书,首先会提示设置密码,用于ca对之后生成的server和client证书签名时使用
# 我这添加nopass参数表示不对证书签名设置密码
[root@localhost 3.0.8]# ./easyrsa build-ca nopass

Note: using Easy-RSA configuration from: /etc/openvpn/easy-rsa/3.0.8/vars
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating RSA private key, 2048 bit long modulus
........................................+++
.........................................+++
e is 65537 (0x10001)
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [Easy-RSA CA]: //直接回车

CA creation complete and you may now import and sign cert requests.
Your new CA certificate file for publishing is at:
/etc/openvpn/easy-rsa/3.0.8/pki/ca.crt

# 生成证书如下
[root@localhost 3.0.8]# find ./ -name ca*
./x509-types/ca
./pki/private/ca.key
./pki/ca.crt
```

**3、创建服务端证书和密钥**  
> 创建服务端密钥文件名称为server，nopass表示不加密私钥文件，生成过程中直接回车默认

```perl
# 创建openvpn服务端证书和密钥
[root@localhost 3.0.8]# ./easyrsa build-server-full server nopass

Note: using Easy-RSA configuration from: /etc/openvpn/easy-rsa/3.0.8/vars
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating a 2048 bit RSA private key
.............................................................................+++
......................+++
writing new private key to '/etc/openvpn/easy-rsa/3.0.8/pki/easy-rsa-25354.b6RZsK/tmp.u1Dw5v'
-----
Using configuration from /etc/openvpn/easy-rsa/3.0.8/pki/easy-rsa-25354.b6RZsK/tmp.qADbIx
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'server'
Certificate is to be certified until Jun 11 10:25:47 2024 GMT (825 days)

Write out database with 1 new entries
Data Base Updated
```
```
# 生成文件
[root@localhost 3.0.8]# find ./ -name server*
./x509-types/server
./x509-types/serverClient
./pki/private/server.key
./pki/reqs/server.req
./pki/issued/server.crt
```

**4、创建DH密钥**  

> 根据在顶部创建的vars配置文件生成2048位的密钥

```perl
# 创建Diffie-Hellman文件
[root@localhost 3.0.8]# ./easyrsa gen-dh

Note: using Easy-RSA configuration from: /etc/openvpn/easy-rsa/3.0.8/vars
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating DH parameters, 2048 bit long safe prime, generator 2
This is going to take a long time
...................................+.............................+...............................................................................+.............................................++*++*

DH parameters of size 2048 created at /etc/openvpn/easy-rsa/3.0.8/pki/dh.pem
```

**5、创建TLS认证密钥 (可选)**
> 这个 key 主要用于防止 DoS 和 TLS 攻击，这一步其实是可选的，但为了安全还是生成一下，该文件在后面配置 open VPN 时会用到。

```
[root@localhost 3.0.8]# openvpn --genkey --secret /etc/openvpn/easy-rsa/3.0.8/pki/ta.key
```

**6、创建证书撤销列表(CRL)密钥**
> CRL(证书撤销列表)密钥用于撤销客户端密钥。如果服务器上有多个客户端证书，希望删除某个密钥，那么只需使用./easyrsa revoke NAME这个命令撤销即可。

```perl
# 生成CRL密钥
[root@localhost 3.0.8]# ./easyrsa gen-crl

Note: using Easy-RSA configuration from: /etc/openvpn/easy-rsa/3.0.8/vars
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Using configuration from /etc/openvpn/easy-rsa/3.0.8/pki/easy-rsa-2625.Kll0r8/tmp.V2N1Uw

An updated CRL has been created.
CRL file: /etc/openvpn/easy-rsa/3.0.8/pki/crl.pem
```
注：crl.pem证书的不能移动，否则在后期删除用户认证的时候不生效，保持该目录即可

**7、复制证书文件**  
- 复制ca证书，ta.key和server端证书及dh.pem , crl.pem密钥文件到/etc/openvpn/server文件夹里
```perl
[root@localhost 3.0.8]# cp -a /etc/openvpn/easy-rsa/3.0.8/pki/ca.crt /etc/openvpn/server/
[root@localhost 3.0.8]# cp -a /etc/openvpn/easy-rsa/3.0.8/pki/ta.key /etc/openvpn/server/
[root@localhost 3.0.8]# cp -a /etc/openvpn/easy-rsa/3.0.8/pki/dh.pem /etc/openvpn/server/
[root@localhost 3.0.8]# cp -a /etc/openvpn/easy-rsa/3.0.8/pki/crl.pem /etc/openvpn/server/
[root@localhost 3.0.8]# cp -a /etc/openvpn/easy-rsa/3.0.8/pki/issued/server.crt /etc/openvpn/server/
[root@localhost 3.0.8]# cp -a /etc/openvpn/easy-rsa/3.0.8/pki/private/server.key /etc/openvpn/server/
[root@localhost 3.0.8]# ll /etc/openvpn/server/
total 28
-rw------- 1 root root 1172 Mar  9 10:26 ca.crt
-rw------- 1 root root  633 Mar  9 10:33 crl.pem
-rw------- 1 root root  424 Mar  9 10:28 dh.pem
-rw------- 1 root root  636 Mar  9 10:32 ta.key
-rw------- 1 root root 4568 Mar  9 10:27 server.crt
-rw------- 1 root root 1704 Mar  9 10:27 server.key
```

# 配置OpenVPN服务端
1、修改OpenVPN配置文件，详情参考[openvpn配置文件详解](http://note.youdao.com/noteshare?id=f89b4abaf6b98fb4095c68d22e918a4c&sub=96E434572DB04B2B9CF7CC587B48918F)
> 复制模板文件到服务端主配置文件夹里面（也可自行在/etc/openvpn/server/目录下创建server.conf文件）

```perl
# 复制模板文件到服务端目录（可选）
#[root@localhost 3.0.8]# cp -a /usr/share/doc/openvpn-2.4.11/sample/sample-config-files/server.conf /etc/openvpn/

# 在文件中修改或添加一下内容
[root@localhost 3.0.8]# vim /etc/openvpn/server.conf

port 1194
proto udp
dev tun
ca /etc/openvpn/server/ca.crt
cert /etc/openvpn/server/server.crt
key /etc/openvpn/server/server.key
dh /etc/openvpn/server/dh.pem
# 该文件不可移动，要使用原文件生成目录
crl-verify /etc/openvpn/easy-rsa/3.0.8/pki/crl.pem
tls-auth /etc/openvpn/server/ta.key 0
# 该网段为 open VPN 虚拟网卡网段，不要和内网网段冲突即可。open VPN 默认为 10.8.0.0/24
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
# 推送路由到客户端，允许客户端访问内网172.16.1.0网段
push "route 172.16.1.0 255.255.255.0"
push "route 10.10.0.0 255.255.0.0"
# DNS 服务器配置，可以根据需要指定其他dns
#push "redirect-gateway def1 bypass-dhcp"  #推送网关及DHCP配置到客户端，让客户端所有流量都通过VPN代理转发
#push "dhcp-option DNS 114.114.114.114"   #推送DNS服务器地址到客户端
duplicate-cn       #允许同一个客户端证书多次登录
keepalive 10 120   #每10秒ping一次，连接超时时间设为120秒
cipher AES-256-CBC
compress lz4-v2     #使用lz4-v2压缩的通讯,服务端和客户端都必须配置
push "compress lz4-v2"
max-clients 100
user openvpn
group openvpn
persist-key
persist-tun
status status.log
log server.log
log-append server.log
verb 3             #指定日志文件的记录详细级别，可选0-9，等级越高日志内容越详细 
mute 20
explicit-exit-notify 1   
```
- push “redirect-gateway def1”: 参数，如果添加该参数，所有客户端的默认网关都将重定向到VPN，这将导致诸如web浏览器、DNS查询等所有客户端流量都经过这里。但是在实际的应用中，我们期望的是只有需要进过vpn流量的时候才走vpn，其他的就正常走我们自己的网络就可以啦。所以在server.conf文件里面这行就需要注释掉。

2、修改内核模块开启系统IPv4转发
```perl
# 不存在该配置则添加
# grep 'net.ipv4.ip_forward = 1' /etc/sysctl.conf || echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf

# 执行生效
sysctl -p
```

3、添加iptables防火墙规则
```perl
# 启用iptables
systemctl start firewalld
systemctl enable firewalld

# 清理所有防火墙规则，使用前查看规则
# iptables -F
# iptables -X

# 将 openvpn 的网络流量转发到公网：snat 规则
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

# iptables 规则持久化保存
iptables-save > /etc/sysconfig/iptables
# 或者
sudo /usr/libexec/iptables/iptables.init save

# 查看防火墙规则
iptables -nvL -t nat --line-number
# 删除上面的iptables配置信息命令如下。作用：对比正常的访问和异常的访问
iptables -t nat -D POSTROUTING 1
```

4、启动openVPN并设置开机自启动
```perl
systemctl start openvpn@server
systemctl enable openvpn@server
systemctl status openvpn@server

# 验证
[root@local-vpn ~]# netstat -antpu | grep openvpn
udp        0      0 0.0.0.0:1194            0.0.0.0:*                           6601/openvpn

# 服务端启动后将获取虚拟IP：10.8.0.1
[root@local-vpn ~]# ifconfig
tun0: flags=4305<UP,POINTOPOINT,RUNNING,NOARP,MULTICAST>  mtu 1500
        inet 10.8.0.1  netmask 255.255.255.255  destination 10.8.0.2
```
说明：如果时间不同步，那么VPN登录访问就可能存在问题。

# 配置OpenVPN 客户端
详情参考[openvpn配置文件详解](http://note.youdao.com/noteshare?id=f89b4abaf6b98fb4095c68d22e918a4c&sub=96E434572DB04B2B9CF7CC587B48918F)
> 在openvpn服务器端操作，复制一个client.conf模板到/etc/openvpn/client文件夹下面。然后编辑该文件/etc/openvpn/client/client.conf

```perl
# 复制模板文件到服务端目录并重命名为ovpn后缀文件
[root@localhost 3.0.8]# cp -a /usr/share/doc/openvpn-2.4.11/sample/sample-config-files/client.conf /etc/openvpn/client/client.ovpn

# 在文件中修改或添加一下内容
[root@localhost 3.0.8]# vim /etc/openvpn/client/client.ovpn

client
dev tun
proto udp
# 设置Server服务端的IP地址和端口，这个地方需要严格和Server端保持一致。(可以写多个做到高可用,需外网访问写外网ip)
remote 172.16.0.214 1194
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
cert admin.crt
key admin.key
# 用户名密码登陆认证方式
# auth-user-pass
remote-cert-tls server
tls-auth ta.key 1
cipher AES-256-CBC
compress lz4-v2
verb 3
mute-replay-warnings
```
注释：auth-user-pass: 该参数是注释掉的，如果开启该参数，任意的账户和密码都可以链接vpn，非常的不安全，如果客户端开启这个参数，服务器端一定要启用用户认证

1、创建windows下的client.ovpn配置文件  
> windows 客户端在官方下载对应的系统的客户端进行安装，安装完成后会在当前的用户目录下面有一个C:\Users\username\OpenVPN\config\的路径，把在服务器上生成的username.zip解压到该目录下面即可

- 创建openVPN用户脚本
```sh
cat > add_vpn_user.sh << "EOF"
set -e

CLIENT_DIR=/etc/openvpn/client
EASY_RSA_VERSION=3.0.8
EASY_RSA_DIR=/etc/openvpn/easy-rsa/
OVPN_USER_KEYS_DIR=$CLIENT_DIR/keys
PKI_DIR=$EASY_RSA_DIR/$EASY_RSA_VERSION/pki

for user in "$@"
do
  if [ -d "$OVPN_USER_KEYS_DIR/$user" ]; then
    rm -rf $OVPN_USER_KEYS_DIR/$user
    rm -rf  $PKI_DIR/reqs/$user.req
    sed -i '/'"$user"'/d' $PKI_DIR/index.txt
  fi
  cd $EASY_RSA_DIR/$EASY_RSA_VERSION
  # 生成客户端 ssl 证书文件
  ./easyrsa build-client-full $user nopass
  # 整理下生成的文件
  mkdir -p  $OVPN_USER_KEYS_DIR/$user
  cp -a $PKI_DIR/ca.crt $OVPN_USER_KEYS_DIR/$user/   # CA 根证书
  cp -a $PKI_DIR/issued/$user.crt $OVPN_USER_KEYS_DIR/$user/   # 客户端证书
  cp -a $PKI_DIR/private/$user.key $OVPN_USER_KEYS_DIR/$user/  # 客户端证书密钥
  cp -a /etc/openvpn/client/client.ovpn $OVPN_USER_KEYS_DIR/$user/$user.ovpn # 客户端配置文件
  sed -i 's/admin/'"$user"'/g' $OVPN_USER_KEYS_DIR/$user/$user.ovpn
  cp -a $PKI_DIR/ta.key $OVPN_USER_KEYS_DIR/$user/  # auth-tls 文件
  cd $OVPN_USER_KEYS_DIR
  zip -r $user.zip $user
done
exit 0
EOF
```
```
./add_vpn_user.sh VE-Xikai
```

- 吊销用户证书 

> 只要吊销对应用户的 SSL 证书即可。因为OpenVPN 的客户端和服务端的认证主要通过 SSL 证书进行双向认证。

```sh
# 编辑 OpenVPN 服务端配置 server.conf 添加如下配置:
crl-verify /etc/openvpn/easy-rsa/3.0.8/pki/crl.pem

cd /etc/openvpn/easy-rsa/3.0.8/
# 查看用户证书
./easyrsa show-req EntityName
./easyrsa show-cert EntityName

# 吊销用户证书（需重启openvpn服务才生效）
./easyrsa revoke username
./easyrsa gen-crl
```

- 一键删除用户(需重启openvpn)
```sh
cat > del_vpn_user.sh << "EOF"
# ! /bin/bash

set -e
OVPN_USER_KEYS_DIR=/etc/openvpn/client/keys
EASY_RSA_VERSION=3.0.8
EASY_RSA_DIR=/etc/openvpn/easy-rsa/
for user in "$@"
do
  cd $EASY_RSA_DIR/$EASY_RSA_VERSION
  echo -e 'yes\n' | ./easyrsa revoke $user
  ./easyrsa gen-crl
  # 吊销掉证书后清理客户端相关文件
  if [ -d "$OVPN_USER_KEYS_DIR/$user" ]; then
    rm -rf $OVPN_USER_KEYS_DIR/${user}*
  fi
  systemctl restart openvpn@server
done
exit 0
EOF
```

### vpn网络连接测试
* 客户端ping服务端vpn虚拟IP
```
14:58 $ ping 10.8.0.1
PING 10.8.0.1 (10.8.0.1) 56(84) bytes of data.
64 bytes from 10.8.0.1: icmp_seq=1 ttl=64 time=0.024 ms
64 bytes from 10.8.0.1: icmp_seq=2 ttl=64 time=0.028 ms
```
* 客户端ping服务端后面的其它主机IP
```
13:34 $ ping 172.16.14.139
PING 172.16.14.139 (172.16.14.139): 56 data bytes
64 bytes from 172.16.14.139: icmp_seq=0 ttl=64 time=46.525 ms
64 bytes from 172.16.14.139: icmp_seq=1 ttl=64 time=23.368 ms
```


# [配置CCD客户端规则访问策略](https://openvpn.net/community-resources/how-to/#configuring-client-specific-rules-and-access-policies)
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
#ccd/sysadmin1
ifconfig-push 10.8.1.1 10.8.1.2
#ccd/contractor1
ifconfig-push 10.8.2.1 10.8.2.2
#ccd/contractor2
ifconfig-push 10.8.2.5 10.8.2.6
```
>在配置固定IP时，每一对ifconfig-push地址代表虚拟客户端和服务器IP端点。它们必须从连续的/30子网中获取，以便与Windows客户端和TAP-Windows驱动程序兼容,具体来说，每个端点对的IP地址的最后八位必须取自这个集合:
```
[  1,  2] [  5,  6] [  9, 10] [ 13, 14] [ 17, 18]
[ 21, 22] [ 25, 26] [ 29, 30] [ 33, 34] [ 37, 38]
[ 41, 42] [ 45, 46] [ 49, 50] [ 53, 54] [ 57, 58]
[ 61, 62] [ 65, 66] [ 69, 70] [ 73, 74] [ 77, 78]
[ 81, 82] [ 85, 86] [ 89, 90] [ 93, 94] [ 97, 98]
[101,102] [105,106] [109,110] [113,114] [117,118]
[121,122] [125,126] [129,130] [133,134] [137,138]
[141,142] [145,146] [149,150] [153,154] [157,158]
[161,162] [165,166] [169,170] [173,174] [177,178]
[181,182] [185,186] [189,190] [193,194] [197,198]
[201,202] [205,206] [209,210] [213,214] [217,218]
[221,222] [225,226] [229,230] [233,234] [237,238]
[241,242] [245,246] [249,250] [253,254]
```

* 配置iptables规则以完成访问策略控制
```
# Employee rule
iptables -A FORWARD -i tun0 -s 10.8.0.0/24 -d 10.66.4.4 -j ACCEPT

# Sysadmin rule
iptables -A FORWARD -i tun0 -s 10.8.1.0/24 -d 10.66.4.0/24 -j ACCEPT

# Contractor rule
iptables -A FORWARD -i tun0 -s 10.8.2.0/24 -d 10.66.4.12 -j ACCEPT
```

# 设置账号密码登录
1、配置用户认证的脚本(脚本是由openvpn官网提供的)
```sh
[root@openvpn ~]# vim /etc/openvpn/checkpsw.sh
#!/bin/sh
###########################################################
# checkpsw.sh (C) 2004 Mathias Sundman 
#
# This script will authenticate OpenVPN users against
# a plain text file. The passfile should simply contain
# one row per user with the username first followed by
# one or more space(s) or tab(s) and then the password.
 
PASSFILE="/etc/openvpn/psw-file"
LOG_FILE="/etc/openvpn/openvpn-password.log"
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

2、创建psw-file文件，用于存放用户名和密码
```sh
# 前面为用户名，后面为密码，中间使用空格分开
[root@openvpn ~]# vim /etc/openvpn/psw-file
test 123456
wwq 123456
```
```
chmod 755 checkpsw.sh
chmod 400 pwd-file
chown openvpn.openvpn pwd-file
chown openvpn.openvpn checkpsw.sh
```

3、配置server.conf
```sh
# 在配置的最后增加以下内容
cat >> /etc/openvpn/server.conf << EOF
#脚本安全级别
script-security 3

# 用户和密码验证脚本
auth-user-pass-verify /etc/openvpn/checkpsw.sh via-env

#使用用户名密码登录认证
username-as-common-name

# 客户端不进行证书认证，如果不加将实现证书和用户密码双重认证
verify-client-cert none
EOF
```
注意：如果加上client-cert-not-required则代表只使用用户名密码方式验证登录，如果不加，则代表需要证书和用户名密码双重验证登录！

4、配置客户端open文件
```perl
vim /etc/openvpn/client/client.ovpn
# 注释掉密钥
#cert client.crt
#key client.key

# 在文件最后添加,使用用户名密码登录openvpn服务器
auth-user-pass
```

5、重启openvpn服务
```
systemctl restart openvpn@server
```


# 通过openvpn服务器代理转发流量到客户端
```
openvpn服务器公有IP：120.79.20.71
openvpn服务器私有IP：172.16.14.139
openvpn隧道虚拟网段：10.8.0.0/24
```

1. 通过ccd为客户端分配固定虚拟IP 10.8.0.9
2. 在openvpn服务器上通过iptables跨主机端口重定向流量到客户端固定虚拟IP 10.8.0.9
```
iptables -t nat -A PREROUTING -d 120.79.20.71/32 -p tcp -m tcp --dport 80 -j DNAT --to-destination 10.8.0.9:80
iptables -t nat -A PREROUTING -d 172.16.14.139/32 -p tcp -m tcp --dport 80 -j DNAT --to-destination 10.8.0.9:80
iptables -t nat -A PREROUTING -d 10.8.0.1/32 -p tcp -m tcp --dport 80 -j DNAT --to-destination 10.8.0.9:80
iptables -t nat -A POSTROUTING -d 10.8.0.9/32 -p tcp -m tcp --dport 80 -j SNAT --to-source 10.8.0.1
iptables -t nat -A POSTROUTING -d 10.8.0.9/32 -p tcp -m tcp --dport 80 -j SNAT --to-source 120.79.20.71
iptables -t nat -A POSTROUTING -d 10.8.0.9/32 -p tcp -m tcp --dport 80 -j SNAT --to-source 172.16.14.139
```