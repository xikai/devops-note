# network namespace


# veth pair
* veth是虚拟以太网卡（Virtual Ethernet）的缩写。veth设备总是成对的，因此我们称之为veth pair。
* veth pair常被用于跨network namespace之间的通信，即分别将veth pair的两端放在不同的namespace里。
  ```
  # container:eth0 <---> host:vethxxxxx
  # 查看host vethxxx和哪个container:eth0对应
  container: ip link show eth0  (116: eth0@if117: 可以看到116是eth0的接口index，117则是另一端vethxxx的接口index)
  host: ip link show |grep 117  (117: veth123456@if116)


# linux bridge
* 两个network namespace可以通过veth pair连接，但两个以上的network namespace相连就需要网桥。
* 网桥是二层设备通过mac地址通讯，linux bridge不能跨主机

# linux隧道
### ipip

### vxlan(虚拟可扩展局域网)
```
# 多个设备的vetp组成虚拟二层网络vxlan:
vetp(host1) - vetp(host2) - vetp(host3)
```
* VTEP：可以是网络设备，也可以是一台机器（例如虚拟化集群中的宿主机）,用于VXLAN报文的封装和解封装
* VNI： 每个vxlan的标识,24位的整数；VIN相同的机器逻辑上处于同一个二层网络
* vxlan的报文是mac in udp 即在三层网络基础上搭建虚拟的二层网络


# flannel（vxlan模式）
1. (container1:eth0 --veth--> host1:vethxxxx1) --container1 route--> cni0网桥 --host1 route--> host1 VETP:flannel.1 --> host1 eth0
  - container1直接将数据包通过veth发送给另一端host1上的vethxxxxx,同主机的容器通讯封装目标容器mac地址走cni0网桥
  - cni0网桥收到数据包 通过host1 路由表转发给 flannel.1 (封装vxlan头，通过etcd得到节点2的IP。然后，通过节点1中的转发表得到节点2对应的VTEP的MAC)
  - host1 flannel.1通过host1 路由表转发给host1 eth0
  - host1 eth0通过host1 路由表转发给host2 eth0
2. host2 eth0 -> host2 VETP:flannel.1 -> cni0网桥 -route-> (host2:vethxxxxx -veth-> container2:eth0)