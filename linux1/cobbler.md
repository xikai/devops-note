
* https://cobbler.github.io/

### 安装Cobbler
* Disable SELinux
```
yum install -y epel-release
yum install -y cobbler cobbler-web httpd dhcp rsync tftp-server xinetd pykickstart fence-agents
```

* 生成加密密码
```
[root@localhost ~]# openssl passwd -1
Password: 
Verifying - Password: 
$1$StlPISB5$hZRscE7pPejDGK/CPgsRJ1
```
>vim /etc/cobbler/settings
```
#设置控制在启动过程中为新系统设置的root密码
default_password_crypted: "$1$StlPISB5$hZRscE7pPejDGK/CPgsRJ1"

#新构建系统连接Cobbler的IP
server: 192.168.140.101

#作为下载网络引导文件的TFTP服务器的IP
next_server: 192.168.140.101

# 关闭PXE重复安装
pxe_just_once：1

# Cobbler管理DHCP服务
manage_dhcp: 1
```

* DHCP管理和DHCP服务模板(如果需要开启dhcp服务)
  - 因为是用cobbler管理dhcp，所以要修改cobbler的dhcp模版，而不是直接修改dhcp本身的配置文件，因为cobbler会覆盖
>vim /etc/cobbler/dhcp.template
```
subnet 192.168.140.0 netmask 255.255.255.0 {
     option routers             192.168.140.2;
     option domain-name-servers 192.168.140.2;
     option subnet-mask         255.255.255.0;
     range dynamic-bootp        192.168.140.10 192.168.140.50;
     default-lease-time         21600;
     max-lease-time             43200;
     next-server                $next_server;
     ...
# 如果内网己有DHCP服务，注释掉 range dynamic-bootp 。不然你内网就会出现两个dhcp服务器
```



* 默认数据目录/var/www/cobbler/,/var/lib/cobbler/
* 启动Cobbler服务
```
systemctl start cobblerd
systemctl start httpd
systemctl start tftp
systemctl start rsyncd
systemctl enable cobblerd
systemctl enable httpd
systemctl enable tftp
systemctl enable rsyncd
```
* cobbler check 检查服务,解决并重启cobblerd
  - cobbler get-loaders
  - systemctl restart cobblerd
  - cobbler sync
  ```
  The following are potential configuration items that you may want to fix:

  1 : change 'disable' to 'no' in /etc/xinetd.d/tftp
  2 : debmirror package is not installed, it will be required to manage debian   deployments and repositories
  
  #这两个不用管，tftp直接systemd启动，debmirror用于debian系统（忽略）
  ```
  

### 下载ISO镜像并挂载 
```
mount -t iso9660 -o loop,ro /data/iso/CentOS-7.1-x86_64-DVD-1503-01.iso /mnt
```
* 导入镜像
```
cobbler import --name=centos7.1 --arch=x86_64 --path=/mnt
#输出信息略（Cobbler 将镜像拷贝一份放在 /var/www/cobbler/ks_mirror/centos7.1-x86_64 目录下）（同时会创建一个名为centos7.1-x86_64的发布版本及profile文件）
```

* 查看镜像详细信息
```
cobbler list
cobbler distro list
cobbler profile list
cobbler distro report --name=centos7.1-x86_64
 Name                           : centos7.1-x86_64
 Architecture                   : x86_64
 TFTP Boot Files                : {}
 Breed                          : redhat
 Comment                        : 
 Fetchable Files                : {}
 Initrd                         :  /var/www/cobbler/ks_mirror/centos7.1-x86_64/images/pxeboot/initrd.img
 Kernel                         :  /var/www/cobbler/ks_mirror/centos7.1-x86_64/images/pxeboot/vmlinuz
 Kernel Options                 : {}
 Kernel Options (Post Install)  : {}
 Kickstart Metadata             : {'tree':  'http://@@http_server@@/cblr/links/centos7.1-x86_64'}
 Management Classes             : []
 OS Version                     : rhel7
 Owners                         : ['admin']
 Red Hat Management Key         : <<inherit>>
 Red Hat Management Server      : <<inherit>>
 Template Files                 : {}
```

### 生成kickstart文件
* 安装软件包system-config-kickstart，运行X Window System生成kickstart文件。
* 参考kickstart文档 https://www.centos.org/docs/5/html/Installation_Guide-en-US/ch-kickstart2.html

>vim /var/lib/cobbler/kickstarts/centos7.1.ks
```
#platform=x86, AMD64, or Intel EM64T
# System authorization information
auth --enableshadow --passalgo=sha512
# System bootloader configuration
bootloader --location=mbr
# Clear the Master Boot Record
zerombr
# Install OS instead of upgrade
install
# Use network installation
url --url=$tree
# Use text mode install
text
# Run the Setup Agent on first boot
firstboot --disable
# Firewall configuration
firewall --disable
# SELinux configuration
selinux --disabled
# System keyboard
keyboard us
# System language
lang en_US
# System timezone
timezone  Asia/Shanghai
#Root password
rootpw --iscrypted $default_password_crypted
# Do not configure the X Window System
skipx
# If any cobbler repo definitions were referenced in the kickstart profile, include them here.
$yum_repo_stanza
# Network information
$SNIPPET('network_config')
# Reboot after installation
reboot

# Partition clearing information
clearpart --all --initlabel
# Allow anaconda to partition the system as needed
part /boot --fstype=ext4 --asprimary --size=200
part /boot/efi --fstype=efi --asprimary --size 400
part swap --size=2048
part / --fstype=ext4 --asprimary --size 1 --grow

#part pv.01 --grow --size=1
#part /boot --fstype=ext4  --size=200
#part /boot/efi --fstype=efi --size 400
#volgroup VolGroup --pesize=4096 pv.01
#logvol / --fstype=xfs --name=lv_root --vgname=VolGroup --grow --size=1024 --maxsize=20480
#logvol swap --name=lv_swap --vgname=VolGroup --grow --size=1984 --maxsize=8192


%pre
$SNIPPET('log_ks_pre')
$SNIPPET('kickstart_start')
$SNIPPET('pre_install_network_config')
# Enable installation monitoring
$SNIPPET('pre_anamon')
%end

%packages
@core
gcc
gcc-c++
make
autoconf
wget
openssh-clients
lrzsz
vim
net-tools
rsync
#$SNIPPET('func_install_if_enabled')
%end

%post --nochroot
$SNIPPET('log_ks_post_nochroot')
%end

%post
cat >> /etc/security/limits.conf <<EOF
*           soft    nproc           65535
*           hard    nproc           65535
*           soft    nofile          102400
*           hard    nofile          204800
EOF
#systemctl enable docker
$SNIPPET('log_ks_post')
# Start yum configuration
$yum_config_stanza
# End yum configuration
$SNIPPET('post_install_kernel_options')
$SNIPPET('post_install_network_config')
$SNIPPET('func_register_if_enabled')
$SNIPPET('download_config_files')
$SNIPPET('koan_environment')
$SNIPPET('redhat_register')
$SNIPPET('cobbler_register')
# Enable post-install boot notification
$SNIPPET('post_anamon')
# Start final steps
$SNIPPET('kickstart_done')
# End final steps
%end
```

* 修改系统启动镜像的ks文件
```
[root@localhost kickstarts]# cobbler profile report --name=centos7.1-x86_64 |grep "Kickstart"
 Kickstart                      : /var/lib/cobbler/kickstarts/sample_end.k
 Kickstart Metadata             : {}

[root@localhost kickstarts]# cobbler profile edit --name=centos7.1-x86_64 --distro=centos7.1-x86_64 --kickstart=/var/lib/cobbler/kickstarts/centos7.1.ks
[root@localhost kickstarts]# cobbler profile report --name=centos7.1-x86_64 |grep "Kickstart"
 Kickstart                      : /var/lib/cobbler/kickstarts/centos7.1.ks
 Kickstart Metadata             : {}

#同步配置
cobbler sync
```

* 删除系统启动镜像
```
cobbler profile remove --name=centos7.1
```

### 客户端启动PXE网络安装系统