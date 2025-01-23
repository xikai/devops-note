* https://juejin.cn/post/7361639833863438390
* [nerdctl为docker的替代工具](https://github.com/containerd/nerdctl/blob/main/docs/command-reference.md)

# [存储目录](https://blog.51cto.com/u_11791718/6091847)
* vim /etc/containerd/config.toml
```sh
# root用来保存持久化数据，包括 Snapshots, Content, Metadata 以及各种插件的数据
root = "/var/lib/containerd"
  /var/lib/containerd/io.containerd.content.v1.content   # image镜像存储目录,存放镜像对应的 config、index、layer、manifest。layer 是 gzip 文件，其他的是 json 文件。可以用 ctr content ls 查看。
  /var/lib/containerd/io.containerd.snapshotter.v1.overlayfs   # 容器启动运行和image镜像解压后的存放目录，可以用 ctr snapshot ls 查看。

# state 用来保存临时数据，包括 sockets、pid、挂载点、运行时状态以及不需要持久化保存的插件数据
state = "/run/containerd"
  /run/containerd/io.containerd.runtime.v2.task/k8s.io   # 容器运行时映射到宿主机的目录
```


# 镜像
```
# 查看镜像
ctr -n k8s.io i ls
ctr -n k8s.io i ls -q  #只输出镜像ID

# 镜像下载
ctr -n k8s.io i pull docker.io/library/nginx:alpine

# 删除镜像
ctr -n k8s.io i rm docker.io/library/nginx:alpine
# 删除指定镜像
ctr -n k8s.io i ls -q |grep '123456789012'|xargs ctr -n k8s.io i rm
# 删除所有未被使用的镜像
ctr -n k8s.io i prune --all

# tag镜像
ctr -n k8s.io i tag nginx:alpine docker.io/library/nginx:alpine

# 推送镜像
ctr -n k8s.io i push docker.io/library/nginx:alpine

# 将镜像挂载到主机目录
ctr -n k8s.io i mount docker.io/library/nginx:alpine /mnt
# 将镜像从主机目录上卸载
ctr -n k8s.io i unmount /mnt

# 将镜像导出为压缩包
ctr -n k8s.io i export nginx.tar.gz docker.io/library/nginx:alpine
# 从压缩包导入镜像
ctr -n k8s.io i import nginx.tar.gz

# 帮助
ctr i --help
```

# 容器
```
# 查看容器
ctr -n k8s.io c ls

# 创建容器
ctr -n k8s.io c create docker.io/library/nginx:alpine nginx

# 查看容器的详细配置
ctr -n k8s.io c info nginx

# 帮助
ctr c --help
```

# 任务
>上面 create 的命令创建了容器后，并没有处于运行状态，只是一个静态的容器。一个 container 对象只是包含了运行一个容器所需的资源及配置的数据结构，这意味着 namespaces、rootfs 和容器的配置都已经初始化成功了，只是用户进程(这里是 nginx)还没有启动. 然而一个容器真正的运行起来是由 Task 对象实现的，task 代表任务的意思，可以为容器设置网卡，还可以配置工具来对容器进行监控等
```
# 查看正在运行的容器
ctr -n k8s.io task ls

# 通过 Task 启动容器
ctr -n k8s.io task start -d nginx

# 直接创建并运行容器
ctr -n k8s.io run -d docker.io/library/nginx:alpine nginx

# 进入容器
ctr -n k8s.io task exec --exec-id 0 -t nginx sh

# 暂停/恢复容器（类似docker pause）
ctr -n k8s.io task pause nginx
ctr -n k8s.io task resume nginx

# 杀掉容器, ctr 没有 stop 容器的功能，只能暂停或者杀死容器
ctr -n k8s.io task kill nginx

# 获取容器的内存、CPU 和 PID 的限额与使用量
ctr -n k8s.io task metrics nginx

# 查看容器中所有进程的 PID（这里的 PID 是宿主机看到的 PID，不是容器中看到的 PID）
ctr -n k8s.io task ps nginx
```

# 命名空间
>除了 k8s 有命名空间以外，Containerd 也支持命名空间,如果不指定，ctr 默认是 default 空间
```
ctr ns ls
ctr -n k8s.io task ls
```

# 容器运行时数据目录大小排序
```
[root@ip-10-21-47-48 ~]# cd /run/containerd/io.containerd.runtime.v2.task/k8s.io/
[root@ip-10-21-47-48 k8s.io]# du -sh * |sort -hr
59G	12abf295be7007d459fef677321b0102aeb26d82b9965142fc88508a29425e52
3.3G	bd083f29f21140aa03c44cef0ee89d1ee0cf290ec22ca1d90473ac3b1e424e52
3.1G	3199f002a07087e1eaa93d82508dac481a1d9fe7ea8a4d64ae4387a6dbc9d8f8
1.1G	7827a812a1c5b669d4cf35b569432a3567bd6ff19afab4d56f4a2b2281143a8f
549M	fb8f4b9d54f45d7f4d50a2d5d88bcb2caae8ebbf2a18d7faa82eb5e8c9fd073c
549M	f3f2b05a6f363b5611212477592391f2643e505a2117b1aaa2ee21f29c0eb5d4
549M	54f12ff17cc24cec91468c70a9ca0c18d495e76f12171ad7e355ab0c6602ca38
549M	4eeb2721db5e7dc0546da82dac7ff6169bf7506abe64fb8df419af390f894f09
362M	29756be75cadf188e663c6c063792f3ecf481e722ba8815e69244275a1570968
316M	d16d06f3be5178c7d03ff857e4339e03726fef3ceff8d082a1e2bec5eeaf492b
```
* 通过目录名(containerd ID)查找image名
```
[root@ip-10-21-47-48 k8s.io]# ctr -n k8s.io  c ls |grep 12abf295be7007d459fef677321b0102aeb26d82b9965142fc88508a29425e52
12abf295be7007d459fef677321b0102aeb26d82b9965142fc88508a29425e52    499890050841.dkr.ecr.us-west-2.amazonaws.com/vevor-support:21-20241212145257230                   io.containerd.runc.v2
```