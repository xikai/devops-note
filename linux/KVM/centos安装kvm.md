* http://koumm.blog.51cto.com/703525/1289627
* Linux KVM虚拟化
```
半虚拟化只支持类宿主主机操作系统（宿主主机是windows操作系统，只能安装windows虚拟机。宿主主机是linux操作系统，只能安装linux虚拟机）,
全虚拟化可以支持跨平台操作系统
KVM 需要有 CPU flags参数支持（Intel VT 或 AMD SVM）标签时，才支持虚拟化(BIOS先要开启虚拟化支持)

egrep 'vmx|svm' /proc/cpuinfo
```

* 安装KVM虚拟化平台
```
yum install qemu-kvm qemu-kvm-tools libvirt libvirt-python virt-viewer virt-manager virt-install
```
```
安装完后重启系统，然后确认一下是否安装成功：
#reboot
lsmod | grep kvm
kvm_amd                69416  0
kvm                   226208  1 kvm_amd

ls -l /dev/kvm
crw-rw---- 1 root kvm 10, 232 Jun 25 15:56 /dev/kvm
```

* 修改网卡文件
>cd /etc/sysconfig/network-scripts/

>cp ifcfg-eth0 ifcfg-br0

>vim ifcfg-br0
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

>vim ifcfg-eth0
```
DEVICE=eth0
NM_CONTROLLED=yes
ONBOOT=yes
BRIDGE=br0
TYPE=Ethernet
```
```
systemctl restart network 
systemctl start libvirtd
systemctl enable libvirtd
```