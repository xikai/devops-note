### LVM是 Logical Volume Manager(逻辑卷管理)的简写，它是Linux环境下对磁盘分区进行管理的一种机制
* 物理卷pv（physicalvolume）   -物理卷就是指硬盘分区或从逻辑上与磁盘分区具有同样功能的设备(如RAID)，是LVM的基本存储逻辑块，但和基本的物理存储介质（如分区、磁盘等）比较，却包含有与LVM相关的管理参数。 
* 卷组vg（VolumeGroup）- LVM卷组类似于非LVM系统中的物理硬盘，其由物理卷组成。可以在卷组上创建一个或多个“LVM分区”（逻辑卷），LVM卷组由一个或多个物理卷组成。
* 逻辑卷lv（logicalvolume）- LVM的逻辑卷类似于非LVM系统中的硬盘分区，在逻辑卷之上可以建立文件系统(比如/home或者/usr等)。 

```
加入PV的磁盘分区才可以用来组建VG，然后从VG中分区使用(LVM分区):
磁盘分区1    磁盘分区2     磁盘分区3 
    |            |            |
   PV          PV          PV
    |            |            |
---------------------------------
|                VG              |
---------------------------------
    |        |        |        |
   LV       LV       LV       LV
```

### 在系统中添加一块新的8G的scsi硬盘/dev/sdb,将硬盘分区，ID改为8e,配置LVM
* LVM 初始化
>vgscan
```
#使用刚划分的新分区/dev/sdb1 /dev/sdb2 /dev/sdb3 /dev/sdb5 /dev/sdb6生成pv
pvcreate /dev/sdb1 /dev/sdb2 /dev/sdb3 /dev/sdb5 /dev/sdb6
  Physical volume "/dev/sdb1" successfully created
  Physical volume "/dev/sdb2" successfully created
  Physical volume "/dev/sdb3" successfully created
  Physical volume "/dev/sdb5" successfully created
  Physical volume "/dev/sdb6" successfully created

#使用刚生成的pv：/dev/sdb1 /dev/sdb2 /dev/sdb3创建vg：hongtu
vgcreate VolGroup /dev/sdb1 /dev/sdb2 /dev/sdb3
  Volume group "VolGroup" successfully created

#为了立即使用卷组而不是重新启动系统，可以使用vgchange来激活卷组
vgchange -ay VolGroup
  1 logical volume(s) in volume group "VolGroup" now active  

#在刚生成的vg：hongtu中创建一个大小为3G的lv：gaowang
lvcreate -L 2.8g -n lv_data VolGroup
  Rounding up size to full physical extent 2.80 GB
  Logical volume "lv_data" created
#如果希望创建一个使用全部卷组的逻辑卷，则需 要首先察看该卷组的PE数，然后在创建逻辑卷时指定：
#vgdisplay VolGroup | grep "Total PE"
```


* 将刚创建的lv格式化成ext3 的文件系统，并挂载使用。在其中创建文件和目录，看能否成功。
>mkfs.ext3 /dev/VolGroup/lv_data
```
mke2fs 1.39 (29-May-2006)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
367264 inodes, 734208 blocks
36710 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=754974720
23 block groups
32768 blocks per group, 32768 fragments per group
15968 inodes per group
Superblock backups stored on blocks: 
        32768, 98304, 163840, 229376, 294912

Writing inode tables: done                            
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

This filesystem will be automatically checked every 33 mounts or
180 days, whichever comes first.  Use tune2fs -c or -i to override.
```

* 挂载LV分区
```
mkdir lvm
mount /dev/VolGroup/lv_data /data
如果希望系统启动时自动加载文件系统，则还需要在/etc/fstab中添加内容：
/dev/VolGroup/lv_data        /data    	defaults    1    2 

#删除逻辑卷以前首先需要将其卸载，然后删除：
#umount /dev/VolGroup/lv_data
#lvremove /dev/VolGroup/lv_data 
```



### 管理LVM
* 使用命令将pv：/dev/sdb5 /dev/sdb6也加入到vg：hongtu中
```
vgextend VolGroup /dev/sdb5 /dev/sdb6
  Volume group "VolGroup" successfully extended
```

* 使用命令增加lv:lv_data的大小为4G
```
lvextend -L +0.1g /dev/VolGroup/lv_data
  Rounding up size to full physical extent 1.20 GB
  Extending logical volume lv_data to 4.00 GB
  Logical volume lv_data successfully resized
```

```
#resize2fs 加载逻辑卷才能生效
resize2fs /dev/VolGroup/lv_data

#xfs文件系统使用xfs_growfs生效
xfs_growfs /dev/VolGroup/lv_app
```