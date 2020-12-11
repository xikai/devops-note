# 安装准备
```
# KVM虚拟机上网
1.开启宿主机的路由转发功能
vim /etc/sysctl.conf 中修改net.ipv4.ip_forward = 1
2.配置宿主机NAT
#iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -j MASQUERADE  #MASQUERADE用于动态外网IP
#iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o eth1 -j SNAT --to-source 117.79.238.187   #ech1 外网网卡设备

#创建KVM数据文件目录
mkdir -p /data/kvm/{iso,img}

#软链xml虚拟机配置文件到/data数据盘
mv /etc/libvirt/qemu /data/kvm/
ln -s /data/kvm/qemu /etc/libvirt/

#安装 osinfo-query列出所有操作系统类型
#REHL/CentOS
yum -y install libosinfo

#Debian/Ubuntu
apt -y install libosinfo-bin


root@server:~# osinfo-query os
 Short ID             | Name                                               | Version  | ID                                      
----------------------+----------------------------------------------------+----------+-----------------------------------------
 altlinux1.0          | Mandrake RE Spring 2001                            | 1.0      | http://altlinux.org/altlinux/1.0        
 altlinux2.0          | ALT Linux 2.0                                      | 2.0      | http://altlinux.org/altlinux/2.0        
 altlinux2.2          | ALT Linux 2.2                                      | 2.2      | http://altlinux.org/altlinux/2.2        
 altlinux2.4          | ALT Linux 2.4                                      | 2.4      | http://altlinux.org/altlinux/2.4        

```

# 安装Centos虚拟机
```
qemu-img create -f qcow2 /data/kvm/img/centos48200.qcow2 200G      #创建虚拟机硬盘

virt-install \
--name centos48200 \
--vcpus=4 \
--ram 8192 \
--disk path=/data/kvm/img/centos48200.qcow2,size=200,format=qcow2,bus=virtio,cache=writeback \
--network bridge=br0,model=virtio \
--os-variant=generic26 \
--accelerate \
--vnc \
--vncport=5910 \
--vnclisten=0.0.0.0 \
--location=/data/kvm/iso/CentOS-6.5-x86_64-bin-DVD1.iso
```

# 安装Ubuntu虚拟机
```
qemu-img create -f qcow2 /data/kvm/img/ubuntu1804-200.qcow2 200G

virt-install \
--name ubuntu1804-200 \
--vcpus=4 \
--ram 8192 \
--disk path=/data/kvm/img/ubuntu1804-200.qcow2,size=200,format=qcow2,bus=virtio,cache=writeback \
--network bridge=br0,model=virtio \
--os-variant=ubuntu18.04 \
--accelerate \
--vnc \
--vncport=5911 \
--vnclisten=0.0.0.0 \
--cdrom=/data/kvm/iso/ubuntu-18.04.5-live-server-amd64.iso
```

# 安装Windows虚拟机
```
cd /data/kvm/iso

#下载virtio windows驱动
win2008:  wget https://launchpad.net/kvm-guest-drivers-windows/20120712/20120712/+download/virtio-win-drivers-20120712-1.iso       
win7:     wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.102/virtio-win-0.1.102.iso

qemu-img create -f qcow2 /data/kvm/img/win2k8_48200.qcow2 200G

virt-install \
--name win2k8_48200 \
--vcpus=4 \
--ram 8192 \
--disk path=/data/kvm/iso/virtio-win-drivers-20120712-1.iso,device=cdrom \
--disk path=/data/kvm/img/win2k8_48200.qcow2,size=200,format=qcow2,bus=virtio,cache=writeback \
--network bridge=br0,model=virtio \
--os-variant=win2k8 \
--accelerate \
--vnc \
--vncport=5911 \
--vnclisten=0.0.0.0 \
--cdrom=/data/kvm/iso/cn_windows_server_2008_r2_standard_enterprise_datacenter_and_web_with_sp1_vl_build_x64_dvd_617396.iso
```

```
#VNC-Veiwer
#vnc option里面Advanced-->expert-->ColourLevel的值为“rgb222” or “full”即可。


##选项解析
--name       #指定虚拟机名称，virsh操作指定虚拟机时所需要的参数，不可以重复。
--ram       #分配内存大小，安装完成后可以用 virsh 调整。
--vcpus     #分配CPU核心数，最大与实体机CPU核心数相同，安装完成后也可以用 virsh 调整。
--disk       #指定虚拟机镜像， size 指定分配大小单位为G，format=qcow2指定镜像文件格式（qcow2支持snapshot快照 ）
         bus虚拟机磁盘使用的总线类型，为了使虚拟机达到好的性能，这里使用virtio。cache虚拟机磁盘的cache类型，device=cdrom将文件以光驱的形式挂载到系统中
--network     #网络类型，此处用的是默认，一般用的应该是 bridge 桥接。model网卡模式，这里也是使用性能更好的virtio
--os-variant   #指定操作系统类型，此处使用的是标准Linux 2.6，其他的可以通过 man virt-install 详细查看。
--accelerate   #加速
--cdrom     #指定安装镜像所在。
--vnc       #启用VNC远程管理，一般安装系统都要启用。
--vncport     #指定 VNC 监控端口，默认端口为 5900。
--vnclisten   #指定 VNC 绑定IP，默认绑定127.0.0.1，这里将其改为 0.0.0.0 以便可以通过外部连接。
--paravirt     #以半虚拟化方式建立虚拟机
--cdrom /root/fedora7live.iso                #指定安装源
--location nft:192.168.1.254:/var/ftp/pub/rhel5        #指定安装源
--extra-args='console=tty0 console=ttyS0,115200n8 serial'  #设置virsh console连接虚拟机(开启这个可能会导致无法使用VNC安装系统)
```

```
#克隆VM
virt-clone -o vm1 -n vm2 -f /data/kvm/img/vm2.qcow2

#如果克隆了一个启用VNC的虚拟机后，则需要修改vnc port，否则无法启动
virsh edit guest
<graphics type='vnc' port='5912' autoport='no' listen='0.0.0.0' keymap='en-us' passwd='123456'/>


#克隆linux系统后需要修改网卡配置才能正常连网
1,vim /etc/udev/rules.d/70-persistent-net.rules
删除NAME=eth0那一行，将NAME=eth1修改为NAME=eth0

2,vim ifcfg-eth0
修改HWADDR为/etc/udev/rules.d/70-persistent-net.rules文件中的MAC地址，删除UUID

3,然后重启系统生效


如果你修改了一个客户机的xml文件（位于/etc/libvirt/qemu/ 目录），你必须重启libvirtd：
/etc/init.d/libvirtd restart




#设置己安装的虚拟机可以通过vrish console连接(在虚拟机设置)
1、添加ttyS0的安全许可，允许root登录:
echo "ttyS0" >> /etc/securetty

2、在/etc/grub.conf文件中为内核添加参数:console=ttyS0 一定要放在kernel这行中(大约在第16行)，不能单独一行，即console=ttyS0是kernel的一个参数
kernel /vmlinuz-2.6.32-431.el6.x86_64 ro root=UUID=bde49855-1a2a-48c8-af4e-e516f7b46ba9 rd_NO_LUKS KEYBOARDTYPE=pc KEYTABLE=us rd_NO_MD crashkernel=auto LANG=zh_CN.UTF-8 rd_NO_LVM rd_NO_DM rhgb quiet
 console=ttyS0

3、在/etc/inittab中添加agetty:
S0:12345:respawn:/sbin/agetty ttyS0 115200

4、重启
reboot

```

