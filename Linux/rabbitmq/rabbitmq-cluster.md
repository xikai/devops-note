```
官方文档：
http://www.rabbitmq.com/clustering.html
http://www.rabbitmq.com/ha.html

参考文档：
http://blog.csdn.net/woogeyu/article/details/51119101
http://88250.b3log.org/rabbitmq-clustering-ha
```

# 功能和原理 
### RabbitMQ的Cluster集群模式一般分为两种，普通模式和镜像模式。
* 普通模式：默认的集群模式，以两个节点（rabbit01、rabbit02）为例来进行说明。对于Queue来说，消息实体只存在于其中一个节点rabbit01（或者rabbit02），rabbit01和rabbit02两个节点仅有相同的元数据，即队列的结构。当消息进入rabbit01节点的Queue后，consumer从rabbit02节点消费时，RabbitMQ会临时在rabbit01、rabbit02间进行消息传输，把A中的消息实体取出并经过B发送给consumer。所以consumer应尽量连接每一个节点，从中取消息。即对于同一个逻辑队列，要在多个节点建立物理Queue。否则无论consumer连rabbit01或rabbit02，出口总在rabbit01，会产生瓶颈。当rabbit01节点故障后，rabbit02节点无法取到rabbit01节点中还未消费的消息实体。如果做了消息持久化，那么得等rabbit01节点恢复，然后才可被消费；如果没有持久化的话，就会产生消息丢失的现象。
* 镜像模式：将需要消费的队列变为镜像队列，存在于多个节点，这样就可以实现RabbitMQ的HA高可用性。作用就是消息实体会主动在镜像节点之间实现同步，而不是像普通模式那样，在consumer消费数据时临时读取。缺点就是，集群内部的同步通讯会占用大量的网络带宽。集群中只要有一个节点可用，集群可用
* 内存节点/磁盘节点: 在RabbitMQ集群里，至少有一个磁盘节点，它用来持久保存元数据。新的节点加入集群后，会从磁盘节点上拷贝数据。节点系统只运行磁盘类型的节点; 如果2个节点，则建议都设为磁盘节点，如果3个节点，则可2个磁盘节点+1个内存节点。

# 多机单节点集群（rpm安装）
```bash
#设置节点主机名
vim /etc/sysconfig/network
HOSTNAME=rabbitX

#配置hosts解析各节点通过主机名通讯
vim /etc/hosts
192.168.221.111 rabbitmq01
192.168.221.112 rabbitmq02

#启动各节点
[root@rabbitmq01]# systemctl start rabbitmq-server

#设置erlang cookie用于各节点通讯认证
RabbitMQ 节点和 CLI 工具 (例如 rabbitmqctl) 使用 cookie 来确定是否允许它们相互通信。要使两个节点能够通信, 它们必须具有相同的共享机密, 称为 Erlang cookie。
RabbitMQ server starts up自动创建.erlang.cookie文件，位于$HOME/.erlang.cookie或/var/lib/rabbitmq/.erlang.cookie
[root@rabbitmq01]# scp /root/.erlang.cookie 192.168.221.112:/root
or:
[root@rabbitmq01]# scp /var/lib/rabbitmq/.erlang.cookie 192.168.221.112:/var/lib/rabbitmq/

#同步.erlang.cookie后启动节点2
[root@rabbitmq02]# systemctl start rabbitmq-server

#在每个节点上确认集群状态
rabbitmqctl cluster_status

#将节点rabbitmq02加入集群(join_cluster到同集群中的任一节点)
rabbitmq02# rabbitmqctl stop_app
rabbitmq02# rabbitmqctl join_cluster rabbit@rabbitmq01    #rabbitmq01为节点1的主机名,rabbit为前缀
rabbitmq02# rabbitmqctl start_app
```

# 单机多节点集群（rpm安装）
```bash
#启动各节点（RABBITMQ节点名由<前缀@主机名>组成,前缀通常是rabbit）
#当一个节点启动时，它检查是否为它分配了一个节点名。这是通过RABBITMQ_NODENAME环境变量完成的。如果没有显式地配置任何值，节点会解析它的主机名并将rabbit前缀给它以计算它的节点名。
RABBITMQ_NODE_PORT=5672 RABBITMQ_SERVER_START_ARGS="-rabbitmq_management listener [{port,15672}]" RABBITMQ_NODENAME=rabbit1 rabbitmq-server -detached
RABBITMQ_NODE_PORT=5673 RABBITMQ_SERVER_START_ARGS="-rabbitmq_management listener [{port,15673}]" RABBITMQ_NODENAME=rabbit2 rabbitmq-server -detached

#确认集群状态
rabbitmqctl -n rabbit1 cluster_status
rabbitmqctl -n rabbit2 cluster_status

#将节点rabbit2加入集群(join_cluster到同集群中的任一节点)
rabbitmqctl -n rabbit2 stop_app
rabbitmqctl -n rabbit2 join_cluster rabbit1@`hostname -s`
rabbitmqctl -n rabbit2 start_app
```

# 管理集群
```sh
#查看节点集群状态(单机多节点需要-n指定操作的节点)
rabbitmqctl -n rabbit1 cluster_status
rabbitmqctl -n rabbit2 cluster_status

##脱离集群
rabbitmqctl -n rabbit2 stop_app
rabbitmqctl -n rabbit2 reset
rabbitmqctl -n rabbit2 start_app

#从集群移除远程节点
rabbitmq02# rabbitmqctl forget_cluster_node rabbit@rabbitmq01

#创建集群用户(使用集群中任一节点)
#https://www.rabbitmq.com/access-control.html
rabbitmqctl -n rabbit1 list_users
rabbitmqctl -n rabbit1 add_user admin admin
rabbitmqctl -n rabbit1 set_user_tags admin administrator
rabbitmqctl -n rabbit1 set_permissions -p / admin ".*" ".*" ".*"
```

# [设置集群镜像队列策略(在集群中任一节点)](https://www.rabbitmq.com/ha.html#examples)
```sh
# 创建了一个策略，策略名称为ha-all,策略模式ha-mode为 all 即复制到所有节点，包含新增节点，策略正则表达式为 “^” 表示所有匹配所有队列名称。
rabbitmqctl -n rabbit1 set_policy ha-all "^" '{"ha-mode":"all","ha-sync-mode":"automatic"}'

# 队列被镜像到所有节点将给所有集群节点带来额外的压力，包括网络I/O、磁盘I/O和磁盘空间使用，建议镜像节点为集群节点数的的以半以上， (N/2 + 1) of cluster nodes
rabbitmqctl -n rabbit1 set_policy ha-two "^" '{"ha-mode":"exactly", "ha-params":2,"ha-sync-mode":"automatic"}'

# 队列被镜像到节点名称中列出的节点
# rabbitmqctl set_policy ha-nodes "^" '{"ha-mode":"nodes","ha-params":["rabbit@nodeA","rabbit@nodeB"]}'

# 应用策略到所有vhost
# for v in $(rabbitmqctl list_vhosts --silent); do rabbitmqctl set_policy -p $vhost ha-all "^" '{"ha-mode":"all","ha-sync-mode":"automatic"}'; done
```
* ha-sync-mode配置队列同步
```sh
ha-sync-mode默认为manual， 表示手动向master同步数据
ha-sync-mode: automatic,  当一个新的镜像加入时，队列将自动向master同步数据；当一个队列正在被同步时，所有其他队列操作将被阻塞。如果队列很小，或者RabbitMQ节点之间有一个快速的网络，并且ha-sync-batch-size被优化了，这是一个不错的选择。
```
* [检查队列是否镜像](https://www.rabbitmq.com/ha.html#how-to-check-i-a-queue-is-mirrored)


# 客户端连接集群(通过四层负载均衡)
* http://www.haproxy.org/
* http://cbonte.github.io/haproxy-dconv/1.6/intro.html

* 安装haproxy
```bash
yum install epel-release -y
yum install haproxy -y
```

* 配置haproxy
>cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak

>vim /etc/haproxy/haproxy.cfg
```
global
    log         127.0.0.1 local2
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon
    stats socket /var/lib/haproxy/stats

defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    #option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

listen rabbitmq_cluster
    bind 0.0.0.0:5670
    mode tcp
    option tcplog
    balance roundrobin
    server   rabbit1 192.168.221.111:5672 check inter 2000 rise 2 fall 3
    server   rabbit2 192.168.221.111:5673 check inter 2000 rise 2 fall 3

listen rabbitmq_web
    bind 0.0.0.0:15670
    mode tcp
    option tcplog
    balance roundrobin
    server   rabbit1 192.168.221.61:15673 check inter 2000 rise 2 fall 3
    server   rabbit2 192.168.221.61:15674 check inter 2000 rise 2 fall 3
```

* 启动haproxy
```bash
echo 'net.ipv4.ip_nonlocal_bind = 1'>>/etc/sysctl.conf
sysctl -p
systemctl start haproxy

setenforce 0
```