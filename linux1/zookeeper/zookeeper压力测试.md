# 参考链接：
```
https://github.com/phunt/zk-smoketest
https://blog.csdn.net/aduocd/article/details/118929845
```

# 下载
```
yum install -y gcc ant
# 安装python-devel（Ubuntu中为python-dev）
yum install -y python-devel
# 安装libzookeeper-mt-devel，（Ubuntu系统需要安装）
# yum install -y libzookeeper-mt-devel

wget https://codeload.github.com/phunt/zk-smoketest/zip/refs/heads/master
unzip zk-smoketest-master.zip
```

* zk-latencies.py 该工具使用 ZooKeeper python 绑定来测试各种操作延迟。脚本执行以下操作：
```
为测试创建一个根 znode，即 /zk-latencies
将 zk 会话附加到集成中的每个服务器（-servers 列表）
对每个服务器运行各种（创建/获取/设置/删除）操作，注意操作的延迟
客户端然后清理，删除 /zk-latencies znode
默认情况下运行异步操作，如果要使用同步操作，请指定“--synchronous”参数。通常，测试两者之间的差异将使您深入了解网络延迟。
```

* 用法
```
用法：zk-latencies.py [options]

选项：
  -h, --help   显示此帮助信息并退出
  --servers=SERVERS   逗号分隔主机列表：端口（默认localhost:2181）
  --cluster=CLUSTER   逗号分隔主机列表：端口，作为集群测试，替代 --servers 
  --config=CONFIGFILE    指定选择自己的zk配置文件
  --timeout=TIMEOUT    会话超时以毫秒为单位查找服务器（默认 5000）
  --root_znode=ROOT_ZNODE   用于测试的根目录，将作为测试的一部分创建（默认 zk-latencies） 
  -- znode_size=ZNODE_SIZE   创建/设置 znode 时的数据大小（默认 25）
  --znode_count=ZNODE_COUNT   每个性能部分要操作的 znode 数量（默认 10000）
  --watch_multiple=WATCH_MULTIPLE   每个 znode 上放置的手表数量（默认 1）
  -- force   强制测试运行，即使 root_znode 存在 -警告！不要在真正的 znode上运行它，否则你会丢失它
  --synchronous   默认使用异步 ZK api，这会强制同步调用
  -v, --verbose   详细输出，包括更多细节
  -q, --quiet   安静的输出，基本上只是成功/失败
--servers 选项将依次测试每个服务器，而 --cluster 选项将测试随机选择的集群中的服务器。
```
```
# 设置 znode 的数量和数据大小，调用同步
PYTHONPATH=lib.linux-x86_64-2.6/ LD_LIBRARY_PATH=lib.linux-x86_64-2.6/ ./zk-latencies.py --cluster "10.10.15.133:2181,10.10.21.126:2181,10.10.37.241:2181" --znode_count=1000 --znode_size=1000 --synchronous
```