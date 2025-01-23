* 挂载宿主机文件目录到容器
```
docker run -d -p 80:80 -v /root/htdocs:/usr/local/apache2/htdocs httpd
```

* 数据卷容器
```
#创建容器dbapp 并将数据卷/var/lib/docker/volumes 中生成一个随机目录(通过docker inspect dbapp查看volumes相关字段) ，映射到容器/dbdata目录 
docker run -d --name dbapp -v /dbdata centos
```

* 其它容器使用--volumes-from来挂载dbdata容器中的数据卷
```
docker run -d --name db1 --volumes-from dbapp centos
```

* 备份数据卷的数据
```
#创建一个backup容器，将本地/backup目录挂载到backup容器的/backup目录，并挂载dbdata容器的数据卷
docker run -d --name backup --volumes-from dbapp -v /backup:/backup centos tar -cf /backup/backup.tar /dbdata 
```

* 恢复数据卷的数据
```
docker run -d --name dbdata2 -v /dbdata2 centos
docker run -it --name backup --volumes-from dbdata2 -v /backup:/backup centos tar -xf /backup/backup.tar
```

# [docker存储驱动overlay2](https://blog.51cto.com/u_14301180/5354261)
* 查看存储驱动
```
docker info | grep "Storage Driver"
```

* overlay2 和 AUFS 类似，它将所有目录称之为层（layer），overlay2 的目录是镜像和容器分层的基础，而把这些层统一展现到同一的目录下的过程称为联合挂载（union mount）。overlay2 把目录的下一层叫作lowerdir，上一层叫作upperdir，联合挂载后的结果叫作merged。
* 总体来说，overlay2 是这样储存文件的：overlay2将镜像层和容器层都放在单独的目录，并且有唯一 ID，每一层仅存储发生变化的文件，最终使用联合挂载技术将容器层和镜像层的所有文件统一挂载到容器中，使得容器中看到完整的系统文件。
* overlay2 文件系统最多支持 128 个层数叠加，也就是说你的 Dockerfile 最多只能写 128 个指令，不过这在日常使用中足够了。
```
# 查看镜像分层
docker image inspect centos
```
* 按目录大小排序
```
[root@ip-10-20-56-6 overlay2]# cd /var/lib/docker/overlay2
[root@ip-10-20-56-6 overlay2]# du -sh * |sort -hr
242G	70ee315c080fce436f3983d4a0d6d7e13f3bd00dcf38bfcd5f43b1451b0c2bd0
1010M	d1db562b091a853116f49af376dc4c768db1334352f13c933d0a3f0c0f9a7d20
805M	07ee09431d458e5ff11de770dbdac7ba882aa43d48c3d85bb8901101f69f0075
444M	e999640f05922e543a66cf29d232ab9a7e318b373f70c31201512418e605782b
364M	0a35c2b0d253c4da411258006d2ec18db0487793e0d939e514bacce25f282e44
362M	5502cbf1c089f82c6ef3171f893dbe4fe1ba738c29531c3aab9e6ebcbbcafdb7
314M	f88e09fbd1e56958d8b72e2554241fd25faf3c20bd36cbdfdc3fe63ea1c0f7fd
310M	cd1ee129d1b16a21d0cf02c99af0d2369df51aa299bd763169f05bbe6ceeb2f0
309M	816998f92173742c8500d93703c35f1a2d2b0204380436decbdb6778f88ce6b9
304M	cd6bcd6bed35271f7940f91fcbe3e6cae2fc289b0007ffaa9423de6cf215dbe2
```
* 通过DOCKER OVERLAY2 目录名查找容器名和容器ID
>有时候经常会有个别容器占用磁盘空间特别大，这个时候就需要通过docker overlay2 目录名查找对应容器名
```
docker ps -q | xargs docker inspect --format '{{.State.Pid}}, {{.Name}}, {{.GraphDriver.Data.WorkDir}}' |grep 70ee315c080fce436f3983d4a0d6d7e13f3bd00dcf38bfcd5f43b1451b0c2bd0
```