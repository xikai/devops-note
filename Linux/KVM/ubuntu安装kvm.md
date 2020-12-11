* Linux KVM虚拟化
```
半虚拟化只支持类宿主主机操作系统（宿主主机是windows操作系统，只能安装windows虚拟机。宿主主机是linux操作系统，只能安装linux虚拟机）,
全虚拟化可以支持跨平台操作系统
KVM 需要有 CPU flags参数支持（Intel VT 或 AMD SVM）标签时，才支持虚拟化(BIOS先要开启虚拟化支持)

egrep 'vmx|svm' /proc/cpuinfo
```

# ubuntu安装kvm
```
apt update
apt install qemu qemu-kvm libvirt-bin  bridge-utils virt-viewer virt-manager 

systemctl start libvirtd
systemctl enable libvirtd
```

### ubuntu16.04网络配置
* vim /etc/network/interfaces增加以下内容
```
auto enp59s0f2
iface enp59s0f2 inet manual

auto br0
iface br0 inet static  

address 10.12.0.21
netmask 255.255.252.0
gateway 10.12.3.254
dns-nameserver 180.76.76.76
dns-nameserver 114.114.114.114
bridge_ports enp59s0f2
```
* 重启网络
```
systemctl restart networking

#使用ifconfig命令查看IP是否从enp59s0f2（网桥创建前的网卡）变到了br0上，如果没有变化则需要重启。如果宿主机ip已经成功变到网桥上，并且宿主机能正常上网而虚拟机获取不到ip，可能是ufw没有允许ip转发导致的，编辑/etc/default/ufw允许ip转发。

DEFAULT_FORWARD_POLICY="ACCEPT"
#重启ufw服务让设置生效

systemctl restart ufw.service
```


### ubuntu18.04网络配置
* vim /etc/netplan/01-netcfg.yaml
```
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
    version: 2
    ethernets:
        enp59s0f2:
            dhcp4: no
            dhcp6: no

    bridges:
        br0:
            interfaces: [enp59s0f2]
            dhcp4: no
            addresses: [10.12.0.21/22]
            gateway4: 10.12.3.254
            nameservers:
                    addresses: [180.76.76.76, 114.114.114.114]
```

* 重启网络
```
netplan apply
```

*  坑
```
执行完如上几步后发现虚拟机的网络和局域网的其他机器不通，只能ping通宿主机，

以为桥接模式用的不对,经过漫长的一天探索发现是宿主机上的iptables配置不合理，因为之前用的一直是centos的防火墙，对ubuntu防火墙不熟悉，感觉防火墙已经关闭，但事实是没生效，最后添加了一条防火墙规则，成功。

iptables -A FORWARD -j ACCEPT
```