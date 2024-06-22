* https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/recognize-expanded-volume-linux.html

1. 控制台修改EBS卷大小
* 确认卷修改成功并且其处于 optimizing 或 completed 状态

2. 扩展 EBS 卷的文件系统
* Xen 实例和 Nitro 实例的设备和分区命名有所不同。要确定实例是基于 Xen 还是基于 Nitro
```
aws ec2 describe-instance-types --instance-type m6g.xlarge --query "InstanceTypes[].Hypervisor"
[
    "nitro"
]
```
* 检查卷是否有分区
```
# 在以下示例输出中，根卷 (nvme0n1) 有两个分区（nvme0n1p1 和 nvme0n1p128），而额外的卷 (nvme1n1) 没有分区。
[ec2-user ~]$ sudo lsblk
NAME          MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
nvme1n1       259:0    0  30G  0 disk /data
nvme0n1       259:1    0  16G  0 disk
└─nvme0n1p1   259:2    0   8G  0 part /
└─nvme0n1p128 259:3    0   1M  0 part

# 如果该卷具有分区，则继续执行以下步骤（2b）。如果该卷没有分区，请跳过。例如，若要扩展名为 nvme0n1p1 的分区
[ec2-user ~]$ sudo growpart /dev/nvme0n1 1

# 以下示例输出显示卷 (nvme0n1) 和分区 (nvme0n1p1) 的大小相同 (16 GB)。
[ec2-user ~]$ sudo lsblk
NAME          MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
nvme1n1       259:0    0  30G  0 disk /data
nvme0n1       259:1    0  16G  0 disk
└─nvme0n1p1   259:2    0  16G  0 part /
└─nvme0n1p128 259:3    0   1M  0 part
```

3. 扩展文件系统
* 获取需要扩展的文件系统的名称、大小、类型和挂载点
```
[ec2-user ~]$ df -hT
Filesystem      Type  Size  Used Avail Use% Mounted on
/dev/nvme0n1p1  xfs   8.0G  1.6G  6.5G  20% /
/dev/nvme1n1    xfs   8.0G   33M  8.0G   1% /data
```
* [XFS 文件系统] 使用 xfs_growfs 命令
```
sudo xfs_growfs -d /
```
* [Ext4 文件系统] 使用 resize2fs 命令
```
sudo resize2fs /dev/nvme0n1p1
```

# 核心步骤
```
lsblk
df -hT
xfs_growfs -d /data
```