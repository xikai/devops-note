# 安装rabbitmq-erlang（Bintray Yum repositories）
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

# 安装rabbitmq-server(Bintray Yum Repository)
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

* [访问授权](https://www.rabbitmq.com/access-control.html)
* https://www.rabbitmq.com/management.html#permissions
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
#rabbitmqctl set_permissions -p VHostPath User ConfP(有配置权限的资源) WriteP(有写权限的资源) ReadP(有读权限的资源)
rabbitmqctl set_permissions -p / rabbit ".*" ".*" ".*"
#禁止配置和写入权限，^$表示资源为空
rabbitmqctl set_permissions -p / rabbit "^$" "^$" ".*"
```
```
# 新建monitoring用户
rabbitmqctl add_user backend-admin rabbitpassword 
rabbitmqctl set_user_tags backend-admin monitoring
for v in $(rabbitmqctl list_vhosts --silent); do rabbitmqctl set_permissions -p $v "backend-admin" ".*" ".*" ".*"; done
rabbitmqctl list_users
```

* web管理
```
http://server-ip:15672
```

# 状态分析
* 查看节点状态信息
```
rabbitmqctl status
```
* top进程状态
```
# 开启rabbitmq-top插件,通过Management UI -> Admin -> Top Processes查看进程
rabbitmq-plugins enable rabbitmq_top
# rabbitmq-cli top进程查看
rabbitmq-diagnostics observer
```

# 内存使用
>当RabbitMQ服务器使用超过内存水位线（默认为40%的可用内存）时，它会发出内存警报并阻塞所有正在发布消息的连接。
* [memory_high_watermark](https://www.rabbitmq.com/memory.html#configuring-threshold)
```
# 设置内存水位线，基于百分比
rabbitmqctl set_vm_memory_high_watermark 0.6
# 设置内存水位线，基于绝对值
rabbitmqctl set_vm_memory_high_watermark absolute "4G"

# 节点重启后失效，写入配置文件rabbitmq.conf永久生效
vm_memory_high_watermark 0.6
vm_memory_high_watermark absolute "4G"
```

* 内存诊断
```
# 内存细分报告 ,https://www.rabbitmq.com/memory-use.html#breakdown-cli
rabbitmq-diagnostics memory_breakdown

# Management UI:
点击node -> Memory details -> update

# 内存状态
rabbitmq-diagnostics status
rabbitmq status
```

# 磁盘使用
>当磁盘可用空间低于配置限制（默认为50MB）时，警报将被触发，所有生产者将被阻塞;在未识别的平台上磁盘空间监控无效。
* [disk_free_limit](https://www.rabbitmq.com/disk-alarms.html#configure)
  * 如果磁盘告警设置过低，并且消息快速分页，则可能会在磁盘空间检查之间(间隔至少10秒)耗尽磁盘空间并导致RabbitMQ崩溃。更保守的方法是将限制设置为与系统上安装的内存量相同
```
# 设置内存水位线，基于绝对值
rabbitmqctl set_disk_free_limit "16GB"

# 设置相对于机器中的RAM的空闲空间限制。此配置文件将磁盘可用空间限制设置为与机器上的RAM数量相同
rabbitmqctl set_disk_free_limit 1.0

# 节点重启后失效，写入配置文件rabbitmq.conf永久生效
disk_free_limit.absolute = 16GB
disk_free_limit.relative = 1.0
```
