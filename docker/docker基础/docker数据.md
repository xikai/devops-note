* 挂载宿主机文件目录到容器
```
docker run -d -p 80:80 -v /root/htdocs:/usr/local/apache2/htdocs httpd
```

* 数据卷容器
```
#创建容器dbapp 并将数据卷/dbdata映射到宿主机 /var/lib/docker/volumes 中生成一个随机目录(通过docker inspect dbapp查看volumes相关字段)
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