* [swarm多宿主机的容器之间通过overlay网络通迅](https://docs.docker.com/engine/swarm/swarm-tutorial/)

# 初始化创建一个新的 swarm集群
```
docker swarm init \
--advertise-addr <MANAGER-IP> \     # MANAGER-IP 地址必须分配给主机操作系统可用的网络接口。swarm 中的所有节点都需要连接到该 IP 地址的管理器。
--default-addr-pool 10.20.0.0/16    # 配置自定义默认地址池
```
```
$ docker swarm init --advertise-addr 172.31.40.12
Swarm initialized: current node (qpzc4d5r134xbd4q7g5mpuwrd) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-0swco2y5tfj98n4cawcvnr5qea0vswp95bjlk3vjc0aezygtv1-71xeeq6kxfkfken10b2dk0nag 172.31.40.12:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```

* 查看 swarm 的当前状态
```
$ docker info
……
 Swarm: active
  NodeID: qpzc4d5r134xbd4q7g5mpuwrd
  Is Manager: true
  ClusterID: 0yi260i2v1lpgucdz3ru6pa8k
  Managers: 1
  Nodes: 1
  Default Address Pool: 10.0.0.0/8
  SubnetSize: 24
  Data Path Port: 4789
  Orchestration:
   Task History Retention Limit: 5
  Raft:
   Snapshot Interval: 10000
   Number of Old Snapshots to Retain: 0
   Heartbeat Tick: 1
   Election Tick: 10
  Dispatcher:
   Heartbeat Period: 5 seconds
  CA Configuration:
   Expiry Duration: 3 months
   Force Rotate: 0
  Autolock Managers: false
  Root Rotation In Progress: false
  Node Address: 172.31.40.12
  Manager Addresses:
   172.31.40.12:2377
```

# 将节点添加到 swarm
* 运行manager节点生成的命令加入swarm集群
```
docker swarm join --token SWMTKN-1-0swco2y5tfj98n4cawcvnr5qea0vswp95bjlk3vjc0aezygtv1-71xeeq6kxfkfken10b2dk0nag 172.31.40.12:2377
```
* 在管理节点上运行以下命令来检索工作人员的加入命令
```
$ docker swarm join-token worker
To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-0swco2y5tfj98n4cawcvnr5qea0vswp95bjlk3vjc0aezygtv1-71xeeq6kxfkfken10b2dk0nag 172.31.40.12:2377
```

# 脱离swarm集群（在manager节点）
```
docker swarm leave --force
```

* 查看swarm节点信息（在manager节点）
>节点 ID 旁边的*表示您当前已连接到此节点。
```
$ docker node ls
ID                            HOSTNAME   STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
70ji4szg4sxffklx3ymtrt646     es07       Ready     Active                          20.10.7
qpzc4d5r134xbd4q7g5mpuwrd *   es09       Ready     Active         Leader           20.10.7
```

# 将服务部署到 swarm集群（在manager节点）
```
docker service create --replicas 1 --name helloworld alpine ping docker.com
```
```
# 列出service
# docker service ls
ID             NAME         MODE         REPLICAS   IMAGE           PORTS
kqh6v2jhb1xd   helloworld   replicated   1/1        alpine:latest

# 查看helloworld服务的详细信息
docker service inspect --pretty helloworld

# 查看哪些节点正在运行该服务
docker service ps helloworld
```
* 扩展服务副本
```
docker service scale helloworld=2
```
* 更新服务
```
docker service update --publish-add 80 my_web
```
* 删除swarm服务
```
docker service rm helloworld
```

# swarm路由，发布服务端口（nodeport）
* 当您访问任何节点上的端口 8080 时，Docker 会将您的请求路由到后端活动容器，您可以配置HAProxy以平衡对发布到端口 8080 的 nginx 服务的请求
```
# --publish创建服务时使用该标志发布端口。target 用于指定容器内部的端口，published用于指定在路由网格上绑定的端口。
 docker service create \
  --name my-web \
  --publish published=8080,target=80 \
  --replicas 2 \
  nginx
```

# overlay覆盖网络
> overlay网络在多个 Docker主机之间创建一个分布式网络
1. 在创建覆盖网络之前，您需要将 Docker主机初始化为 swarm 管理器或加入swarm集群，即使您从不打算使用 swarm 服务。之后，您可以创建其他用户定义的覆盖网络。
```
[manage1]$ docker swarm init --advertise-addr 172.31.40.12
[work1]$ docker swarm join --token SWMTKN-1-0swco2y5tfj98n4cawcvnr5qea0vswp95bjlk3vjc0aezygtv1-71xeeq6kxfkfken10b2dk0nag 172.31.40.12:2377

```
2. 当您初始化 swarm 或将 Docker 主机加入现有 swarm 时，会在该 Docker 主机上创建两个新网络：
  * ingress覆盖网络
  * docker_gwbridge桥接网络
  ```
  # docker network ls
  NETWORK ID     NAME              DRIVER    SCOPE
  93e675732113   bridge            bridge    local
  3c0bfcdebdb5   docker_gwbridge   bridge    local
  eec085361c0a   host              host      local
  hcivkfsbpebp   ingress           overlay   swarm
  9c657ab05bc5   none              null      local
  ```

* 先决条件：
```
每个加入overlay网络的docker主机开放端口:
用于集群管理通信的 TCP 2377
用于节点之间的通信的 TCP 和 UDP 7946
overlay网络流量 UDP 4789
```

* 创建用户自定义overlay网络
```
# --attachable 创建用于swarm服务 或 跨主机单独容器通讯的覆盖网络
docker network create --driver overlay --subnet 172.20.0.0/24 --attachable my-attachable-multi-host-network
```
```
# 只能用于swarm服务通讯的覆盖网络
docker network create --driver overlay my-multi-host-network
```

* 将独立容器附加到覆盖网络
>ingress网络是在没有--attachable标志的情况下创建的，这意味着只有 swarm 服务可以使用它, 你可以连接独立的容器到带--attachable标志创建的，用户定义的overlay覆盖网络。这使运行在不同 Docker主机上的独立容器能够进行通信，且不需要在各个docker主机上配置route表
```
# swarm manage1
docker run -d --name box1 --network my-attachable-multi-host-network busybox sleep 3600
docker exec -it box1 sh
ping box2
ping 172.20.0.6

# swarm work1
docker run -d --name box2 --network my-attachable-multi-host-network busybox sleep 3600
docker exec -it box2 sh
ping box1
ping 172.20.0.4
```

* 删除网络
```
docker network rm my-attachable-multi-host-network
```