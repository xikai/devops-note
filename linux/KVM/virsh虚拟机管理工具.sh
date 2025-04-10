virsh list --all                           #列出所有虚拟机
virsh console [guest]                     #从KVM控制台连接到虚拟机
virsh start [guest]                        #启动虚拟机
virsh reboot [guest]                      #重启某一个虚拟机
virsh shutdown [guest]                    #正常关闭虚拟机
virsh destroy [guest]                      #强制关闭虚拟机
virsh undefine [guest]                     #删除虚拟机及文件
virsh autostart [guest]                   #设置虚拟机为自启动
virsh suspend [guest]                     #暂停虚拟机虚拟机
virsh resume [guest]                      #从暂停状态还原VM虚拟机
virsh setmem [guest]                    #重新设置虚拟机内存大小
virsh setmaxmem [guest]                    #设置内存最大值
virsh setvcpus [guest]                    #修改虚拟机CPU数量
virsh dominfo [guest]                    #查看指定虚拟机的信息
virsh edit [guest]                        #编辑虚拟机配置文件



qemu-img info yourdisk.img                                                #查看img信息
qemu-img convert -f raw -O qcow2 yourdisk.img newdisk.qcow2                #转换镜像文件格式

virsh snapshot-create-as --domain CentOS1 --name snp2 --description "tms"         #创建快照
virsh snapshot-list CentOS1                                                        #列出所有快照
virsh snapshot-current CentOS1                                                    #查看当前所在快照
virsh snapshot-revert CentOS1 snap2                                                #恢复快照
virsh snapshot-delete CentOS1 snap2                                                #删除快照


#virsh使用qemu+ssh访问远程libvirtd
yum install qemu-kvm-tools -y
virsh -c qemu+ssh://192.168.221.70/system list --all


#virsh使用qemu+tcp访问远程libvirtd
vim /etc/sysconfig/libvirtd
LIBVIRTD_CONFIG=/etc/libvirt/libvirtd.conf
LIBVIRTD_ARGS="--listen"

vim  /etc/libvirt/libvirtd.conf
listen_tls = 0
listen_tcp = 1
tcp_port = "16509" 
listen_addr = "0.0.0.0"
auth_tcp = "none"

service libvirtd restart

virsh -c qemu+tcp://192.168.221.70/system list --all



#guest迁移
方法一：
1，拷贝guest.img、guest.xml到目标主机
2，virsh define /etc/libvirt/qemu/guest.xml
3，virsh start guest

方法二(动态迁移)：
 virsh migrate vm0 qemu+tcp://192.168.1.200/system tcp://192.168.1.200


#清理qcow2磁盘碎片,压缩虚拟机镜像文件
使用dd命令将客户机未使用的磁盘空间用0填满
$dd if=/dev/zero of=~/junk
dd: writing to `/home/***/junk’: No space left on device
然后
$rm junk
关闭客户机,备份镜像
转换磁盘镜像文件
$qemu-img convert -O qcow2 debian.qcow2 debian_new.qcow2
转换完成后可以看到debian_new.qcow2占用的KVM主机存储空间与客户机使用的磁盘空间基本是一致的。然后用新的磁盘镜像文件debian_new.qcow2启动客户机即可。
windows客户机
删除不需要的文件,清理系统垃圾,然后整理磁盘碎片
下载SDelete,借助sdelete用0来填充未使用硬盘空间
查看sdelete帮助
C:\>sdelete
SDelete – Secure Delete v1.6
Copyright (C) 1999-2010 Mark Russinovich
Sysinternals – www.sysinternals.com
usage: sdelete.exe [-p passes] [-s] [-q] …
sdelete.exe [-p passes] [-z|-c] [drive letter] …
-a Remove Read-Only attribute
-c Clean free space
-p passes Specifies number of overwrite passes (default is 1)
-q Don’t print errors (Quiet)
-s or -r Recurse subdirectories
-z Zero free space (good for virtual disk optimization)
用0填充C分区空闲区域
C:\>sdelete -z c
关闭客户机
最后在KVM主机上转换qcow2磁盘镜像文件
$qemu-img convert -O qcow2 windows.qcow2 windows_new.qcow2
转换完成后可以看到windows_new.qcow2占用的KVM主机存储空间与客户机使用的磁盘空间基本是一致的。然后用新的磁盘镜像文件windows_new.qcow2启动客户机即可。