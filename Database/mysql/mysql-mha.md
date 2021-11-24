* https://github.com/yoshinorim/mha4mysql-manager/wiki

* [Download](https://code.google.com/archive/p/mysql-master-ha/downloads)

# [Installing MHA Node](https://github.com/yoshinorim/mha4mysql-manager/wiki/Installation#installing-mha-node)
* install MHA Node to all MySQL servers (both master and slave).
* install MHA Node to also management server(MHA Manager modules internally depend on MHA Node modules)

```
yum install perl-DBD-MySQL
wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/mysql-master-ha/mha4mysql-node-0.53.tar.gz
tar -zxf mha4mysql-node-0.53.tar.gz
perl Makefile.PL
make --prefix=/usr/local/mha-node
make install
```

# [Installing MHA Manager](https://github.com/yoshinorim/mha4mysql-manager/wiki/Installation#installing-mha-manager)
* install MHA Manager to management server
```
yum install perl-DBD-MySQL perl-Config-Tiny perl-Log-Dispatch perl-Parallel-ForkManager
wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/mysql-master-ha/mha4mysql-manager-0.53.tar.gz
tar -zxf mha4mysql-manager-0.53.tar.gz
perl Makefile.PL
make --prefix=/usr/local/mha-manager
make install
```

* [配置mha-manager](https://github.com/yoshinorim/mha4mysql-manager/wiki/Configuration)
>每个 MySQL 服务器的主机名、MySQL 用户名和密码、MySQL 复制用户名和密码、工作目录名称等
```
cat << EOF > /usr/local/mha-manager/app1.conf
[server default]
# mysql user and password
user=root
password=mysqlpass
ssh_user=root
# working directory on the manager
manager_workdir=/var/log/masterha/app1
# working directory on MySQL servers
remote_workdir=/var/log/masterha/app1

[server1]
hostname=host1

[server2]
hostname=host2

[server3]
hostname=host3
EOF
```

* 验证非交互式 SSH 连接是否可以相互建立
```
manager_host$ masterha_check_ssh --conf=/usr/local/mha-manager/app1.conf
```
* 检查复制健康
```
manager_host$ masterha_check_repl --conf=/usr/local/mha-manager/app1.conf
```
* 启动mha-manager
```
nohup manager_host$ masterha_manager --conf=/usr/local/mha-manager/app1.conf &
manager_host$ masterha_stop --conf==/usr/local/mha-manager/app1.conf
```
* 检查mha-manager状态
```
manager_host$ masterha_check_status --conf==/usr/local/mha-manager/app1.conf
```

# 测试主故障转移
* 现在 mha-manager监控 MySQL 主服务器的可用性,测试主故障转移是否正常工作,在主服务器上杀死 mysqld
```
master-host1$  killall -9 mysqld mysqld_safe
```