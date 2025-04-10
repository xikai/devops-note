* https://moosefs.com/support/#documentation
* https://moosefs.com/blog/how-install-moosefs/

### 简介
MooseFs是一个容错的分布式文件系统。它把数据存储在多个物理设备中。在任何Unix-like系统中支持如下标准的文件操作：
层级机构（目录树）
存储POSIX文件属性（权限、最后访问和最后修改时间）
支持特殊文件（块和字符设备，管道、scokets）
软连接、硬链接
基于IP或者密码的访问控制

MooseFs其他与众不同的特性：
高可用，每份数据可以设置多个副本，并存储在不同的物理机器上
高可扩展性，通过扩容主机硬盘或者增加服务器进行在线动态扩容。
可以设置被删除的文件保留时间（文件系统级别的“垃圾回收站”）
	一致的文件快照，即使文件正在被修改/访问,依然可以完成文件一致性快照。



### MooseFS架构
![image](https://moosefs.com/wp-content/themes/Moose/img/moosefs-architecture.png)
* MooseFS包含4个组件：
1.	Managing servers（Master server）：MooseFS（开源版）中仅支持一台Master server，MooseFS Pro（收费版）中支持任意台Master server。Master server维护整个文件系统，存储每个文件元数据（文件大小，属性和文件位置，包括所有非正常文件，如目录、sockets、管道和设备）。

2.	Data servers（Chunk servers）：任意数量台服务器，用来存储文件的data并同步文件到各个chunk servers（如果某个文件存在多个副本）。

3.	Metadata backup server（Metalogger server）: 任意数量台服务器，存储元数据（metadata ）变更记录并周期性从Master server下载元数据文件。
当Master server故障时Metalogger Server 服务器可以设置为Master server。

4.	客户端通过挂载来使用MooseFS : 客户端使用mfsmount程序与MooseFS进行交互。

mfsmount 基于FUSE机制（Filesystem in Userspace）。在任何支持FUSE的操作系统(Linux、FreeBSD、MacOS X)上都可以使用MooseFS。
FUSE 指完全在用户态实现的文件系统。Linux用于支持用户空间文件系统的内核模块名叫FUSE。

### 工作原理
![image](http://img0.tuicool.com/nuuqQzj.png!web)
![image](http://img1.tuicool.com/yMbIvmv.png!web)

### 服务器列表

Master Servers | Metalogger | Chunkservers
---|---|---
192.168.140.101 | 192.168.140.102 | 192.168.140.103、192.168.140.104



### 软件包资源
```
curl "https://ppa.moosefs.com/RPM-GPG-KEY-MooseFS" > /etc/pki/rpm-gpg/RPM-GPG-KEY-MooseFS
curl "http://ppa.moosefs.com/MooseFS-3-el7.repo" > /etc/yum.repos.d/MooseFS.repo
```
>vim /etc/hosts
```
192.168.140.101 mfsmaster
```
```
mkdir -p /data/mfs
chown -R mfs:mfs /data/mfs
```

### 安装Master Servers、MooseFS CGI and CGI Server
```
yum install -y moosefs-master moosefs-cgi moosefs-cgiserv
cd /etc/mfs 
cp mfsmaster.cfg.sample mfsmaster.cfg    # 配置master服务
cp mfsexports.cfg.sample mfsexports.cfg  # 配置挂载权限
```
>vim mfsmaster.cfg
```
DATA_PATH = /data/mfs
```
>vim mfsexports.cfg
```
192.168.140.0/24 / rw,alldirs,maproot=0
```
>启动mfsmaster、mfscgiserv
```
cp /var/lib/mfs/metadata.mfs /data/mfs/
mfsmaster start
mfscgiserv start
or:
systemctl start moosefs-master
systemctl start moosefs-cgiserv
```
>访问MooseFS CGI
```
http://192.168.140.101:9425
```

### 安装Metaloggers Server
>MooseFS (non-Pro)建议至少部署一台Metalogger.与Master server一样的硬件配置，负责备份master服务器的变化日志文件，文件类型为changelog_ml.*.mfs，以便于在master server出问题的时候接替其进行工作。
```
yum install -y moosefs-metalogger
cd /etc/mfs 
cp mfsmetalogger.cfg.sample mfsmetalogger.cfg
```
>vim mfsmetalogger.cfg
```
DATA_PATH = /data/mfs
```
>启动Metaloggers Server
```
cp /var/lib/mfs/metadata.mfs /data/mfs/
mfsmetalogger start
or:
systemctl start moosefs-metalogger
```

### 安装Chunkservers
```
yum install -y moosefs-chunkserver
cd /etc/mfs 
cp mfschunkserver.cfg.sample mfschunkserver.cfg 
cp mfshdd.cfg.sample mfshdd.cfg
```
>vim mfschunkserver.cfg
```
DATA_PATH = /data/mfs
```
>Chunkservers指定数据存储目录 \
vim mfshdd.cfg
```
/data/mfs/data
```
>启动mfschunkserver
```
mfschunkserver start
```

### 安装MooseFS Clients
```
yum install -y fuse fuse-devel moosefs-client
```
```
mkdir /mnt/mfs
mfsmount /mnt/mfs -H mfsmaster
```
```
[root@localhost ~]# df -h
文件系统                 容量  已用  可用 已用% 挂载点
/dev/mapper/centos-root   18G  1.2G   17G    7% /
devtmpfs                 232M     0  232M    0% /dev
tmpfs                    242M     0  242M    0% /dev/shm
tmpfs                    242M  4.5M  237M    2% /run
tmpfs                    242M     0  242M    0% /sys/fs/cgroup
/dev/sda1                497M  120M  378M   25% /boot
mfsmaster:9421            35G  2.8G   33G    8% /mnt/mfs
```
---
### 设置挂载目录下数据副本数(默认数据的副本为2)
>/mnt/mfs/goal1、/mnt/mfs/goal2分别副本数为1和2 \
```
mkdir /mnt/mfs/{goal1,goal2}
mfssetgoal -r 1 /mnt/mfs/goal1
mfssetgoal -r 2 /mnt/mfs/goal2
```

### 测试文件副本数
```
cp anaconda-ks.cfg /mnt/mfs/goal1/a1.cfg
cp anaconda-ks.cfg /mnt/mfs/goal2/a2.cfg

[root@localhost mfs]# mfsfileinfo /mnt/mfs/goal1/a1.cfg 
/mnt/mfs/goal1/a1.cfg:
	chunk 0: 0000000000000005_00000001 / (id:5 ver:1)
		copy 1: 192.168.140.104:9422 (status:VALID)
[root@localhost mfs]# mfsfileinfo /mnt/mfs/goal2/a2.cfg 
/mnt/mfs/goal2/a2.cfg:
	chunk 0: 0000000000000002_00000001 / (id:2 ver:1)
		copy 1: 192.168.140.103:9422 (status:VALID)
		copy 2: 192.168.140.104:9422 (status:VALID)
```
>当chunkserver:104下线时a1.cfg本地缓存失效后，不能访问
```
[root@localhost mfs]# mfsfileinfo /mnt/mfs/goal1/a1.cfg 
/mnt/mfs/goal1/a1.cfg:
	chunk 0: 0000000000000005_00000001 / (id:5 ver:1)
		no valid copies !!!
[root@localhost mfs]# mfsfileinfo /mnt/mfs/goal2/a2.cfg 
/mnt/mfs/goal2/a2.cfg:
	chunk 0: 0000000000000002_00000001 / (id:2 ver:1)
		copy 1: 192.168.140.103:9422 (status:VALID)
```
### Master Server故障恢复测试
开源版MooseFS的Master Server存在单点故障。

Master Server故障（意外断电或服务崩溃），可以通过两种方式恢复：
	一、在Master Server上使用mfsmaster -a 命令修复启动。
	二、当Master Server上的元数据和变更日志丢失，通过Metalogger server上的元数据和变更日志进行恢复。

另外查阅官方文档，在Master Server 服务器故障时，可能会丢失最近一小时的数据。因为Master Server每隔一小时保存元数据到硬盘，可配置最小间隔也是1小时。目前没有解决方案。

>使用Metalogger Server的元数据log进行恢复
```
# mfsclient在/mnt/mfs/goal2目录下执行，创建100个txt文件。
[root@localhost goal2]# for i in {201..300};do echo $i > $i.txt;done

# 登录mfsmaster，强制杀死mfsmaster 进程，备份并清空元数据存放目录
[root@mfsmaster ~]# ps aux|grep mfsmaster
mfs      19871  1.7 70.3 604976 347748 ?       S<   22:50   0:04 mfsmaster -a
root     19874  0.0  0.1 112716   980 pts/0    R+   22:55   0:00 grep --color=auto mfsmaster
[root@mfsmaster ~]# kill -9 19871
[root@mfsmaster ~]# cd /data
[root@mfsmaster data]# cp -pr mfs/ mfs_master_bak
[root@mfsmaster data]# rm -rf mfs/*

# 登录Metalogger Server，停止Metalogger Server，备份元数据日志并拷贝到Master Server
[root@localhost ~]# mfsmetalogger stop
[root@localhost ~]# cd /data/mfs/
[root@localhost data]# cp -pr mfs mfs_metalog_bak
[root@localhost data]# cd mfs
[root@localhost mfs]# scp * root@mfsmaster:/data/mfs

# 修复启动mfsmaster
[root@mfsmaster ~]# mfsmaster -a
```

### 回收站测试
>创建测试文件
```
[root@localhost goal2]# echo 'This is a testfile for moosfe trash' > testfile_trash.txt
[root@localhost goal2]# echo 'testfile' > testfile_trash_im.txt
[root@localhost goal2]# 
[root@localhost goal2]# 
[root@localhost goal2]# mfssettrashtime 0 testfile_trash_im.txt  #设置此文件的保留时间为0，则会被立即删除
testfile_trash_im.txt: 0
[root@localhost goal2]# mfsgettrashtime  testfile_trash.txt  testfile_trash_im.txt
testfile_trash.txt: 86400
testfile_trash_im.txt: 0
[root@localhost goal2]# rm -fr testfile_trash.txt testfile_trash_im.txt #删除测试文件
```
>恢复测试文件,挂载MFSMETA目录
```
[root@localhost mnt]# mkdir /mnt/mfstrash
[root@localhost mnt]# mfsmount -m /mnt/mfstrash -H mfsmaster
[root@localhost mfstrash]# ls
sustained  trash
```
挂载 MFSMETA 文件系统,它包含目录 trash (包含仍然可以被还原的删除文件的信息)和trash/undel (用于获取文件并恢复)。把删除的文件移到/ trash/undel 下,就可以恢复此文件。

>查找出被错误删除的文件，并恢复
```
[root@localhost mfstrash]# cd trash/
[root@localhost trash]#  ll -R | grep -C 2 testfile
./0D3:
总用量 1
-rw-r--r--    1 root root 36 11月 14 23:20 000000D3|goal2|testfile_trash.txt
d-w------- 4098 root root  0 11月 15 10:16 undel
[root@localhost trash]# mv 000000D3\|goal2\|testfile_trash.txt /mnt/mfstrash/trash/undel/

# 恢复成功 
[root@localhost goal2]# ls
a2.cfg  testfile_trash.txt
```

