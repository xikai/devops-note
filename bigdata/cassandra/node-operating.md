* https://cassandra.apache.org/doc/3.11/cassandra/operating/topo_changes.html
* https://developer.aliyun.com/article/714637
* https://m.elecfans.com/article/609753.html

# [nodetool](https://cassandra.apache.org/doc/3.11/cassandra/tools/nodetool/nodetool.html)
* https://cassandra.apache.org/doc/3.11/cassandra/troubleshooting/use_nodetool.html
```
#查看集群状态
bin/nodetool status
bin/nodetool describecluster

#查看当前节点信息
bin/nodetool info

# 获取节点的网络连接信息
bin/nodetool netstats

#当前节点下线，并把数据复制到环中紧邻的下一个节点
bin/nodetool decommission 


#强制移除节点，无任何数据拷贝
bin/nodetool assassinate
  
# 删除一个节点，从其他副本节点拷贝数据到数据重分布后的目标节点，有数据不一致风险，用于当前节点不能重新拉起，提供数据读取服务
bin/nodetool removenode HostID    # 如果死亡节点是种子节点，请在每个节点上更改群集的种子节点配置，如有需要添加新的种子节点IP

# 新增节点
bin/nodetool bootstrap resume

# 清理节点磁盘空间
bin/nodetool cleanup  
```

# 加减机器，扩容，缩容
* 新增节点
```
部署新节点，配置和其它节点一样，bin/cassandra启动
在新节点成功加入之后，对每个先前存在的节点运行nodetool cleanup 如果你不这样做，旧的数据仍然会在老节点上，占用磁盘空间。
```

* 下线一个正常的集群节点
```
#在要下线的节点上执行：
nodetool decommission 或者 nodetool removenode

#如果重新上线该节点
bin/cassandra -Dcassandra.override_decommission=true 
或删除现在节点上所有数据后重启服务： rm -rf /data/cassandra/*/* && bin/cassandra
```

* 替换DOWN掉的节点
```
部署新节点,配置和其它节点一样
bin/cassandra -Dcassandra.replace_address=192.168.1.101 ，第一次启动加上替换节点参数

查看数据迁移的进度 nodetool netstats
等待数据迁移，看到新节点的状态变成UN状态的时候，就表示迁移完成了

在其它老节点执行磁盘清理
nodetool cleanup
```

# 验证集群数据
* https://blog.51cto.com/michaelkang/2419518
```
[root@kubm-01 ~]# cqlsh 172.20.101.157  -u cassandra -p cassandra  

cassandra@cqlsh> SELECT * from kevin_test.t_users; 

 user_id | emails                          | first_name | last_name
---------+---------------------------------+------------+-----------
       6 | {'k6-6@gmail.com', 'k6@pt.com'} |     kevin6 |      kang
       7 | {'k7-7@gmail.com', 'k7@pt.com'} |     kevin7 |      kang
       9 | {'k9-9@gmail.com', 'k9@pt.com'} |     kevin9 |      kang
       4 | {'k4-4@gmail.com', 'k4@pt.com'} |     kevin4 |      kang
       3 | {'k3-3@gmail.com', 'k3@pt.com'} |     kevin3 |      kang
       5 | {'k5-5@gmail.com', 'k5@pt.com'} |     kevin5 |      kang
       0 | {'k0-0@gmail.com', 'k0@pt.com'} |     kevin0 |      kang
       8 | {'k8-8@gmail.com', 'k8@pt.com'} |     kevin8 |      kang
       2 | {'k2-2@gmail.com', 'k2@pt.com'} |     kevin2 |      kang
       1 | {'k1-1@gmail.com', 'k1@pt.com'} |     kevin1 |      kang
```