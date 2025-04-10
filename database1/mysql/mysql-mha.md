* https://github.com/yoshinorim/mha4mysql-manager/wiki
* https://dwj999.github.io/AWS-EC2%E6%90%AD%E5%BB%BAMHA-VIP-MySQL5-7.html

# [Installing MHA Node](https://github.com/yoshinorim/mha4mysql-manager/wiki/Installation#installing-mha-node)
* [Download](https://code.google.com/archive/p/mysql-master-ha/downloads)
* install MHA Node to all MySQL servers (both master and slave).
* install MHA Node to also management server(MHA Manager modules internally depend on MHA Node modules)
>一主一从时，建议两边都部署mha-node和mha-manager
```
yum install -y epel-release
yum install -y perl-ExtUtils-CBuilder perl-ExtUtils-MakeMaker perl-CPAN perl-DBD-MySQL perl-Config-Tiny perl-Log-Dispatch perl-Parallel-ForkManager perl-Time-HiRes
wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/mysql-master-ha/mha4mysql-node-0.58.tar.gz
tar -zxf mha4mysql-node-0.58.tar.gz
mv mha4mysql-node-0.58 /usr/local/mha-node
perl Makefile.PL
make
make install
```

# [Installing MHA Manager](https://github.com/yoshinorim/mha4mysql-manager/wiki/Installation#installing-mha-manager)
* install MHA Manager to management server
```
yum install -y perl-DBD-MySQL perl-Config-Tiny perl-Log-Dispatch perl-Parallel-ForkManager
wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/mysql-master-ha/mha4mysql-manager-0.58.tar.gz
tar -zxf mha4mysql-manager-0.58.tar.gz
mv mha4mysql-manager-0.58 /usr/local/mha-manager
perl Makefile.PL
make
make install
```

* [配置mha-manager](https://github.com/yoshinorim/mha4mysql-manager/wiki/Configuration)
>每个 MySQL 服务器的主机名、MySQL 用户名和密码、MySQL 复制用户名和密码、工作目录名称等
vim /usr/local/mha-manager/app1.conf
```sh
[server default]  #如果用一个manager管理多对mysql主从，把default配置放在一个全局配置文件(/etc/masterha_default.cnf)管理更容易，如果在全局配置文件和应用程序配置文件上设置相同的参数，则使用后者(应用程序配置)
user=root
password=mysqlpass
ssh_user=root
ssh_port=1022

master_binlog_dir=/data/mysql/data
remote_workdir=/data/log/masterha

ping_interval=3
secondary_check_script= masterha_secondary_check -s remote_host1 -s remote_host2

# https://github.com/yoshinorim/mha4mysql-manager/blob/master/samples/scripts/master_ip_failover
master_ip_failover_script=/usr/local/mha-manager/script/masterha/master_ip_failover
# shutdown_script= /script/masterha/power_manager
# report_script= /script/masterha/send_report
# master_ip_online_change_script= /script/masterha/master_ip_online_change

manager_workdir=/var/log/masterha/app1
manager_log=/var/log/masterha/app1/manager.log


[server1]   # 在MHA决定新主服务器时，排序顺序很重要
hostname=host1

[server2]
hostname=host2
candidate_master=1  #服务器将被优先级设置为新的主服务器, 多个server被设置优先推荐时按server在配置中的排序优先

#[server3]
#hostname=host3
#no_master=1      #服务器永远不会成为新的主服务器

#从MHA版本0.56开始，MHA支持新的节[binlogN]。在binlog部分，您可以定义mysqlbinlog流媒体服务器。当MHA进行基于GTID的故障转移时，MHA检查binlog服务器，如果binlog服务器领先于其他从服务器，MHA在恢复之前将差异binlog事件应用到新主服务器。当MHA执行基于非gtid(传统)的故障转移时，MHA会忽略binlog服务器
# [binlog1]  
# hostname=binlog_host1

```

* 配置非交互式 SSH 连接是否可以相互建立
```
# ssh-copy-id -i /root/.ssh/id_rsa.pub root@ip
[manager_host]$ masterha_check_ssh --conf=/usr/local/mha-manager/app1.conf
```
* 检查复制健康
```
[manager_host]$ masterha_check_repl --conf=/usr/local/mha-manager/app1.conf
```
* 启动mha-manager
```
[manager_host]$ nohup masterha_manager --conf=/usr/local/mha-manager/app1.conf &
[manager_host]$ masterha_stop --conf==/usr/local/mha-manager/app1.conf
```
* 检查mha-manager状态
```
[manager_host]$ masterha_check_status --conf==/usr/local/mha-manager/app1.conf
```

# 测试主故障转移
* 现在 mha-manager监控 MySQL 主服务器的可用性,测试主故障转移是否正常工作,在主服务器上杀死 mysqld
```
[master-host1]$ killall -9 mysqld mysqld_safe
```
```
[master-host1]$ tail -f  /var/log/masterha/app1/manager.log
……
Started automated(non-interactive) failover.
Invalidated master IP address on mysql-slave(172.31.36.197:3306)
Selected mysql-master(172.31.43.188:3306) as a new master.
mysql-master(172.31.43.188:3306): OK: Applying all logs succeeded.
mysql-master(172.31.43.188:3306): OK: Activated master IP address.
mysql-master(172.31.43.188:3306): Resetting slave info succeeded.
Master failover to mysql-master(172.31.43.188:3306) completed successfully.
```

# 切换主库后，重新配置从库（原主库）同步新主库
```
CHANGE MASTER TO MASTER_HOST='master_ip',MASTER_USER='repl',MASTER_PASSWORD='WIN2net',MASTER_PORT=3306,MASTER_AUTO_POSITION = 1;
start slave;
show slave status\G;
```