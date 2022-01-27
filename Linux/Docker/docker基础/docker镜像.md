* 查看docker镜像
```
docker images
```

* 搜寻镜像(默认搜索Docker Hub官方仓库中的镜像)
```
docker search mysql
```

* 下载centos:latest镜像
```
docker pull centos
```

* 为镜像标记新的TAG
```
docker tag centos centos:7.2
docker tag centos 192.168.221.111:5000/centos:7.2
```

* 获取镜像详细信息(JSON格式)
```
docker inspect fd44297e2ddb
```

* 删除镜像(需要先删除依赖该镜像的容器)
```
docker rmi a2669a9f1192
docker rmi $(docker images -q)     
docker rmi `docker images|egrep -v "library|jenkinsci" |awk '{print $3}'`
```
* docker清理指定日期之前的镜像
```
docker image prune -a --filter "until=$(date +'%Y-%m-%dT%H:%M:%S' --date='-7 days')"
```

* 删除镜像缓存
```
docker system prune --volumes
```

* 存储镜像文件为本地文件
```
docker save -o centos_apache2.tgz centos:apache2
```

* 载入镜像
```
docker load < centos_apache2.tgz 
```

### 手动创建镜像
* 修改容器并在本地创建新镜像(docker commit的只是镜像与容器当前状态的差异部分)
```
[root@localhost ~]# docker run -i -t centos /bin/bash
[root@42e3d44fb5f9 /]# echo "hello docker" >hello.txt
[root@42e3d44fb5f9 /]# exit
```

* 保存修改后的容器到新的镜像
```
[root@localhost ~]# docker commit -m "message" -a "Author" 42e3d44fb5f9 centos:hello
[root@localhost ~]# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
centos              hello               0da96d9f8357        7 seconds ago       299.5 MB
docker.io/centos    latest              0e0217391d41        13 days ago         196.6 MB
```

* 推送镜像到私有仓库
```
[root@localhost ~]# docker tag centos:hello 192.168.221.111:5000/centos:hello
[root@localhost ~]# docker push 192.168.221.111:5000/centos:hello

docker tag [ImageId] registry.cn-shenzhen.aliyuncs.com/dd01/alpine:[镜像版本号]
docker push registry.cn-shenzhen.aliyuncs.com/dd01/alpine:[镜像版本号]
```

* 批量更改docker tag
```
docker images | grep dadi01 |sed 's/dadi01/fncul/' |awk '{print "docker tag "$3" "$1":"$2}'| sh
```


### Dockerfile创建镜像
>创建空目录并将名为 Dockerfile 的此文件放入其中
* vim Dockerfile
```
# 第一条必须指定基于的基础镜像
FROM centos

# 维护者信息
MAINTAINER xikai "81757195@qq.com"

# dockerfile变量声明
ENV WEB nginx

# 镜像被构建时运行指令
RUN yum install -y $WEB

#开放容器端口
EXPOSE 80

# 容器被启动时运行指令
CMD ["/usr/sbin/nginx"]
```

* 构建镜像(-t设置仓库及镜像名)
```
docker build -t centos:nginx .
```

**注：如果构建失败，则通过docker run -it image_id /bin/bash进入最后一个成功的镜像ID调试，然后重新修改dockerfile文件**