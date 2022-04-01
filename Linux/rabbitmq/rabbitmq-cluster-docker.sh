# 环境准备
hostnamectl --static set-hostname rabbitmq01
mkdir -p /data/rabbitmq/{etc,log,mnesia}
chmod -R 777 /data/rabbitmq

vim /etc/hosts
10.10.3.177 rabbitmq01
10.10.38.11 rabbitmq02
10.10.30.57 rabbitmq03

# 启动rabbitmq
docker run -d --name rabbitmq \
  --restart=always \
  --net=host \
  #-v /data/rabbitmq/mnesia:/var/lib/rabbitmq/mnesia \
  #-v /data/rabbitmq/log:/var/log/rabbitmq/log \
  #-v /data/rabbitmq/etc:/etc/rabbitmq \
  -v /etc/hosts:/etc/hosts \
  -e RABBITMQ_DEFAULT_USER=admin \
  -e RABBITMQ_DEFAULT_PASS=fdtIdyymny8rRbh1 \
  -e RABBITMQ_ERLANG_COOKIE='rabbitcookie' \
  rabbitmq:3.8.28-management-alpine

[root@rabbitmq01 ~]# docker exec -it rabbitmq rabbitmq-plugins enable rabbitmq_management

# rabbitmq02加入集群
[root@rabbitmq02 ~]# docker exec -it rabbitmq rabbitmqctl stop_app
[root@rabbitmq02 ~]# docker exec -it rabbitmq rabbitmqctl join_cluster rabbit@rabbitmq01
[root@rabbitmq02 ~]# docker exec -it rabbitmq rabbitmqctl start_app

[root@rabbitmq02 ~]# docker exec -it rabbitmq rabbitmqctl cluster_status


# 设置管理员
[root@rabbitmq02 ~]# docker exec -it rabbitmq rabbitmqctl set_user_tags admin administrator
[root@rabbitmq02 ~]# docker exec -it rabbitmq rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"

# 设置镜像模式
[root@rabbitmq02 ~]# docker exec -it rabbitmq rabbitmqctl set_policy ha-all "^" '{"ha-mode":"all","ha-sync-mode":"automatic"}'