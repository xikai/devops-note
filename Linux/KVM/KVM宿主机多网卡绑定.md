* 设置开机加载bonding模块
```
  vi /etc/modprobe.d/bonding.conf 加入以下两行：
  alias bond0 bonding
  options bond0 miimon=100 mode=0

  mode=0 表示负载均衡方式，两块网卡都工作，需要交换机作支持
  mode=1 表示冗余方式，网卡只有一个工作，一个出问题启用另外的
```


* 修改网卡配置文件
>vim ifcfg-br0 
```
DEVICE=br0
TYPE=Bridge
ONBOOT=yes
BOOTPROTO=none
NM_CONTROLLED=yes
USERCTL=no
IPV6INIT=no
IPADDR=192.168.60.90
NETMASK=255.255.255.0
GATEWAY=192.168.60.1
DNS1=114.114.114.114
```


>cd /etc/sysconfig/network-scripts/ ，新建ifcfg-bond0文件 ，内容如下：
```
DEVICE=bond0
NM_CONTROLLED=yes
ONBOOT=yes
BRIDGE=br0
TYPE=Ethernet
```


* 修改想要做成bond的网卡的配置文件，如ifcfg-eth0、ifcfg-eth1，内容分别如下：
```
DEVICE=em1
TYPE=Ethernet
ONBOOT=yes
BRIDGE=br0                #如果bond0桥接br0，这里要也桥接br0
BOOTPROTO=none
USERCTL=no
MASTER=bond0            #绑定bond0
SLAVE=yes

DEVICE=em2
TYPE=Ethernet
ONBOOT=yes
BRIDGE=br0                #如果bond0桥接br0，这里要也桥接br0
BOOTPROTO=none
USERCTL=no
MASTER=bond0            #绑定bond0
SLAVE=yes
```
```
service NetworkManager stop
chkconfig NetworkManager off
```
*  重启系统，使配置生效
