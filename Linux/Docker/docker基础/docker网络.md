```
#映身本地5000端口到容器5000端口(-p映射指定端口)
docker run -d -P centos       #大P 随机映射一个 49000~49900 的端口到内部容器开放的网络端口
docker run -d -p 80 centos    #容器80端口映射到宿主机随机端口49153~65535
docker run -d -p 80:80 centos   #容器80端口映射到宿主机指定端口80
docker run -d -p 127.0.0.1:8080:80 centos  #容器80端口映射到宿主机127.0.0.1:80
docker run -d -p 127.0.0.1::80 centos       #容器80端口映射到宿主机127.0.0.1的随机端口

#通过宿主机映射IP端口访问容器端口
curl 127.0.0.1:8080

#查看容器端口映射
docker port 57a2e5ded61a

#安装docker的宿主机会创建一个新的网络接口docker0,地址范围172.16~172.30,是所有docker容器的网关，用于连接容器和本地宿主网络
```

```
#容器互联(不同的宿主机上运行的容器无法连接)
docker run -d --name redis centos

#--link container_name:alias
docker run -d --name web -p 80:80 -v /date/www:/data/www --link redis:redisserver centos   

[root@9e4ad953c1ee /]# ping redisserver
PING redis (172.17.0.2) 56(84) bytes of data.
64 bytes from redis (172.17.0.2): icmp_seq=1 ttl=64 time=1.42 ms
64 bytes from redis (172.17.0.2): icmp_seq=2 ttl=64 time=0.042 ms
64 bytes from redis (172.17.0.2): icmp_seq=3 ttl=64 time=0.042 ms
64 bytes from redis (172.17.0.2): icmp_seq=4 ttl=64 time=0.042 ms
```


* 容器网络相关参数
```
docker run -d --hostname=dch1 centos
docker run -d --dns=8.8.8.8 centos
docker run -d --net=bridge centos
docker run -d --bridge=docker0 centos            #指定容器挂载的网桥
docker run -d --ip_forward=true centos            #启动docker容器时自动打开宿主机转发服务
```

* 配置docker0网桥
```
# 启动服务时配置
--bip=192.168.1.5/24
--mtu=1500
```

* 配置docker
```
mkdir /etc/docker
cat << EOF > /etc/docker/daemon.json
{
  "registry-mirrors": ["https://vpc6s6jf.mirror.aliyuncs.com"],
  "data-root": "/data/docker",
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ],
  "mtu": 1450
}
EOF

#当Docker网络的MTU比docker host machine网卡MTU大的时候可能会发生：容器外出通信失败影响网络性能所以将Docker网络MTU设置成和host machine网卡保持一致就行了 "mtu": 1450

#容器通过宿主机访问外网，宿主要需要开启转发
net.ipv4.ip_forward=1
```


# 创建自定义网络
```
docker network create --driver bridge isolated_nw
```

* 查看自定义网络
>docker network ls
```
NETWORK ID          NAME                DRIVER
9f904ee27bf5        none                null
cf03ee007fb4        host                host
7fca4eb8c647        bridge              bridge
c5ee82f76de3        isolated_nw         bridge
```
>docker network inspect isolated_nw

* 启动容器使用自定义网络
```
docker run --network=isolated_nw -itd --name=container3 busybox
```

* 将容器从网络中断开
```
docker network disconnect isolated_nw container3 
```

* 将正在运行的容器加入指定网络
```
docker network connect my-bridge-network container3 
```