* https://weread.qq.com/web/reader/829328f071a74c6182975cck16732dc0161679091c5aeb1

# network namespace
* 在Linux的世界里，文件系统挂载点、主机名、POSIX进程间通信消息队列、进程PID数字空间、IP地址、user ID数字空间等全局系统资源被namespace分割，装到一个个抽象的独立空间里。而隔离上述系统资源的namespace分别是Mount namespace、UTS namespace、IPC namespace、PID namespace、networknamespace和user namespace。
* Linux的namespace给里面的进程造成了两个错觉：（1）它是系统里唯一的进程。（2）它独享系统的所有资源。
* network namespace，它在Linux内核2.6版本引入，作用是隔离Linux系统的设备，以及IP地址、端口、路由表、防火墙规则等网络资源。


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
* VTEP：可以是网络设备 也可以是一台机器（例如虚拟化集群中的宿主机）,即有IP也有MAC地址。
* VNI： 每个vxlan的标识,24位的整数；VNI相同的机器逻辑上处于同一个二层网络
* vxlan在三层网络基础上搭建虚拟的二层网络
  ```
    | ethernet header | IP header | udp header | vxlan header | original L2 frame | FCS |
  ```


# flannel（vxlan模式）
* 在VXLAN模式下，数据是由内核转发的，flannel不转发数据
1. (container1:eth0 --veth--> host1:vethxxxx) --container1 route--> cni0网桥 --host1 route--> host1 VETP:flannel.1() --> host1 eth0
  - container1直接将数据包通过veth发送给另一端host1上的vethxxxxx,同主机的容器通讯封装目标容器mac地址走cni0网桥
  - 跨主机容器通讯：cni0网桥收到数据包 通过host1 路由表转发给 flannel.1 (与其它主机的VTEP组成虚拟二层网络，在原始报文上封装vxlan头[目标主机VTEP MAC+目标主机IP])
  - host1 flannel.1通过内核转发给host1 eth0
  - host1 eth0通过host1 路由表转发给host2 eth0
2. host2 eth0 -> host2 VETP:flannel.1 -> cni0网桥 -route-> (host2:vethxxxxx -veth-> container2:eth0)