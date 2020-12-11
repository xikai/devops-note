### 安装rabbitmq-erlang（Bintray Yum repositories）
>https://github.com/rabbitmq/erlang-rpm
```
cat >/etc/yum.repos.d/rabbitmq-erlang.repo<<EOF
[rabbitmq-erlang]
name=rabbitmq-erlang
baseurl=https://dl.bintray.com/rabbitmq-erlang/rpm/erlang/21/el/7
gpgcheck=1
gpgkey=https://dl.bintray.com/rabbitmq/Keys/rabbitmq-release-signing-key.asc
repo_gpgcheck=0
enabled=1
EOF
```
```
yum install erlang
```

### 安装rabbitmq-server(Bintray Yum Repository)
>https://www.rabbitmq.com/install-rpm.html#bintray
```
cat >/etc/yum.repos.d/rabbitmq.repo<<EOF
[bintray-rabbitmq-server]
name=bintray-rabbitmq-rpm
baseurl=https://dl.bintray.com/rabbitmq/rpm/rabbitmq-server/v3.7.x/el/7/
gpgcheck=0
repo_gpgcheck=0
enabled=1
EOF
```
```
yum install rabbitmq-server
```

* 启动rabbitmq-server
```
systemctl start rabbitmq-server
systemctl enable rabbitmq-server
```

* 安装管理插件
```
rabbitmq-plugins list                      
rabbitmq-plugins enable rabbitmq_management
```

* 命令行管理
```
#用户管理
rabbitmqctl list_users 
rabbitmqctl add_user rabbit rabbitpassword
rabbitmqctl delete_user rabbit 
rabbitmqctl change_password rabbit newpassword 
rabbitmqctl set_user_tags rabbit management

#虚拟主机管理
rabbitmqctl list_vhosts
rabbitmqctl add_vhost /
rabbitmqctl delete_vhost /

#队列管理
rabbitmqctl list_queues
rabbitmqctl 

#权限管理
rabbitmqctl list_permissions
rabbitmqctl set_permissions -p / rabbit ".*" ".*" ".*"
```

* web管理
```
http://server-ip:15672
```