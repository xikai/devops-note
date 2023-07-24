# 镜像
```
# 查看镜像
ctr i ls

# 镜像下载
ctr i pull docker.io/library/nginx:alpine

# 将镜像挂载到主机目录
ctr i mount docker.io/library/nginx:alpine /mnt
# 将镜像从主机目录上卸载
ctr i unmount /mnt

# 将镜像导出为压缩包
ctr i export nginx.tar.gz docker.io/library/nginx:alpine
# 从压缩包导入镜像
ctr i import nginx.tar.gz

# 帮助
ctr i --help
```

# 容器
```
# 查看容器
ctr c ls

# 创建容器
ctr c create docker.io/library/nginx:alpine nginx

# 查看容器的详细配置
ctr c info nginx

# 帮助
ctr c --help
```

# 任务
>上面 create 的命令创建了容器后，并没有处于运行状态，只是一个静态的容器。一个 container 对象只是包含了运行一个容器所需的资源及配置的数据结构，这意味着 namespaces、rootfs 和容器的配置都已经初始化成功了，只是用户进程(这里是 nginx)还没有启动. 然而一个容器真正的运行起来是由 Task 对象实现的，task 代表任务的意思，可以为容器设置网卡，还可以配置工具来对容器进行监控等
```
# 查看正在运行的容器
ctr task ls

# 通过 Task 启动容器
ctr task start -d nginx

# 直接创建并运行容器
ctr run -d docker.io/library/nginx:alpine nginx

# 进入容器
ctr task exec --exec-id 0 -t nginx sh

# 暂停/恢复容器（类似docker pause）
ctr task pause nginx
ctr task resume nginx

# 杀掉容器, ctr 没有 stop 容器的功能，只能暂停或者杀死容器
ctr task kill nginx

# 获取容器的内存、CPU 和 PID 的限额与使用量
ctr task metrics nginx

# 查看容器中所有进程的 PID（这里的 PID 是宿主机看到的 PID，不是容器中看到的 PID）
ctr task ps nginx
```

# 命名空间
>除了 k8s 有命名空间以外，Containerd 也支持命名空间,如果不指定，ctr 默认是 default 空间
```
ctr ns ls
ctr -n k8s.io task ls
```