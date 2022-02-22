# 内核升级
* 查看当前内核版本
```sh
# uname -r
3.10.0-862.el7.x86_64
```

* 下载内核源
```
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
```
* 查看可用的内核版本
```sh
# yum --disablerepo="*" --enablerepo="elrepo-kernel" list available
Loading mirror speeds from cached hostfile
 * elrepo-kernel: ftp.ne.jp
Available Packages
elrepo-release.noarch                                     7.0-5.el7.elrepo                     elrepo-kernel
kernel-lt.x86_64                                          5.4.178-1.el7.elrepo                 elrepo-kernel
kernel-lt-devel.x86_64                                    5.4.178-1.el7.elrepo                 elrepo-kernel
kernel-lt-doc.noarch                                      5.4.178-1.el7.elrepo                 elrepo-kernel
kernel-lt-headers.x86_64                                  5.4.178-1.el7.elrepo                 elrepo-kernel
kernel-lt-tools.x86_64                                    5.4.178-1.el7.elrepo                 elrepo-kernel
kernel-lt-tools-libs.x86_64                               5.4.178-1.el7.elrepo                 elrepo-kernel
kernel-lt-tools-libs-devel.x86_64                         5.4.178-1.el7.elrepo                 elrepo-kernel
kernel-ml.x86_64                                          5.16.8-1.el7.elrepo                  elrepo-kernel
kernel-ml-devel.x86_64                                    5.16.8-1.el7.elrepo                  elrepo-kernel
kernel-ml-doc.noarch                                      5.16.8-1.el7.elrepo                  elrepo-kernel
kernel-ml-headers.x86_64                                  5.16.8-1.el7.elrepo                  elrepo-kernel
kernel-ml-tools.x86_64                                    5.16.8-1.el7.elrepo                  elrepo-kernel
kernel-ml-tools-libs.x86_64                               5.16.8-1.el7.elrepo                  elrepo-kernel
kernel-ml-tools-libs-devel.x86_64                         5.16.8-1.el7.elrepo                  elrepo-kernel
perf.x86_64                                               5.16.8-1.el7.elrepo                  elrepo-kernel
python-perf.x86_64
```
* 安装最新内核
```sh
yum --enablerepo=elrepo-kernel install kernel-ml
# --enablerepo 选项开启 CentOS 系统上的指定仓库。默认开启的是 elrepo，这里用 elrepo-kernel 替换。
```

* 查看系统可用内核
```sh
# awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
0 : CentOS Linux 7 Rescue acd60cfc85b7986eb8ec2dc7ac0a8c7b (5.16.8-1.el7.elrepo.x86_64)
1 : CentOS Linux (5.16.8-1.el7.elrepo.x86_64) 7 (Core)
2 : CentOS Linux (3.10.0-862.el7.x86_64) 7 (Core)
3 : CentOS Linux (0-rescue-78521e51141d4d0bafae14998efaf5eb) 7 (Core)
```
* 设置默认启动的内核
```sh
grub2-set-default 1  #设置为以上内核的ID
#或 vim /etc/default/grub  添加 GRUB_DEFAULT=1
```
* 生成 grub 配置文件并重启
```
grub2-mkconfig -o /boot/grub2/grub.cfg
```
```
reboot
```
