# [测试工具](https://esrally.readthedocs.io/en/latest/index.html)
* [rally](https://github.com/elastic/rally) 是 elastic 官方开源的一款基于 python3 实现的针对 es 的压测工具。rally主要功能如下：
* 通过Elasticsearch官方提供的geonames（大小为3.3G, 总计11396505 个doc），以及benchmark rally脚本，我们对Elasticsearch（V6.7.0）进行了压测

# 测试环境
```
客户端：
云主机规格：2C 4GB
云主机镜像：Amazon Linux 2 AMI x86_64

Elasticsearch集群：es_search（分片:5 副本:1）
集群云主机规格：4C 16GB  *  3节点
单节点JVM堆栈：8GB
```

# 安装rally
* [前提条件](https://esrally.readthedocs.io/en/latest/install.html)
  - 安装Python3.8+ & pip3
  - git1.9+
  - JDK 1.8+
  
* 安装Python
```
yum -y install openssl-devel zlib-devel bzip2-devel sqlite-devel readline-devel libffi-devel systemtap-sdt-devel
wget https://www.python.org/ftp/python/3.8.9/Python-3.8.9.tgz
tar -zxvf Python-3.8.9.tgz
cd Python-3.8.9
./configure --prefix=/usr/local/python3
make && make install

ln -s /usr/local/python3/bin/python3 /usr/bin/python3
ln -s /usr/local/python3/bin/pip3 /usr/bin/pip3
```

* 安装git2.34
```
yum install gcc perl-ExtUtils-MakeMaker curl-devel expat-devel gettext-devel openssl-devel zlib-devel asciidoc
wget https://www.kernel.org/pub/software/scm/git/git-2.34.1.tar.gz
tar -xzf git-2.34.1.tar.gz
cd git-2.34.1
./configure
make && make install
```

* 安装JDK1.8
```
yum install java-1.8.0-openjdk -y
```

* 安装esrally工具
```
# 安装完成后 执行文件在/usr/local/python3/bin/esrally
pip3 install esrally
#pip3 install esrally==1.4.1
```

# 在线测试
* https://esrally.readthedocs.io/en/latest/command_line_reference.html#command-line-flags
```
--distribution-version：指定基准测试的ES版本  
--pipeline：
    benchmark-only：自定义集群时需要使用的pipeline，只进行压测而不去管理ES实例，也是最常用的。  
    from-distribution：默认的，是指esrally在官方打好的包下载下来，解压运行  
    from-sources-complete：支持从源码本地编译、打包再运行，对于ES开发人员有用  
    from-sources-skip-build：与from-sources-complete相互呼应，利用源码方式但是跳过编译、打包
```
* 由于elasticsearch的运行必须非root账户,esrally建议用非root账户执行
```
su - elasticsearch
```
* [Tracks - 指定不同压测场景](https://esrally.readthedocs.io/en/latest/race.html#list-tracks)
```
# 列出官方支持的压测场景(对全文基准感兴趣，因此我们将选择运行pmc. 如果您有自己的数据要用于基准测试，请创建自己的轨道)
esrally list tracks
Name        Description                                          Documents  Compressed Size    Uncompressed Size    Default Challenge        All Challenges
----------  -------------------------------------------------  -----------  -----------------  -------------------  -----------------------  ---------------------------
geonames    POIs from Geonames                                    11396505  252.4 MB           3.3 GB               append-no-conflicts      append-no-conflicts,appe...
geopoint    Point coordinates from PlanetOSM                      60844404  481.9 MB           2.3 GB               append-no-conflicts      append-no-conflicts,appe...
http_logs   HTTP server log data                                 247249096  1.2 GB             31.1 GB              append-no-conflicts      append-no-conflicts,appe...
nested      StackOverflow Q&A stored as nested docs               11203029  663.1 MB           3.4 GB               nested-search-challenge  nested-search-challenge,...
noaa        Global daily weather measurements from NOAA           33659481  947.3 MB           9.0 GB               append-no-conflicts      append-no-conflicts,appe...
nyc_taxis   Taxi rides in New York in 2015                       165346692  4.5 GB             74.3 GB              append-no-conflicts      append-no-conflicts,appe...
percolator  Percolator benchmark based on AOL queries              2000000  102.7 kB           104.9 MB             append-no-conflicts      append-no-conflicts,appe...
pmc         Full text benchmark with academic papers from PMC       574199  5.5 GB             21.7 GB              append-no-conflicts      append-no-conflicts,appe...
```
* 压测命令
```
# 将track geonames下载到指定elasticsearch实例压测
esrally --pipeline=benchmark-only --track=geonames --target-hosts=es01.test.com:9200  
```
* [配置 Rally](https://esrally.readthedocs.io/en/latest/configuration.html)
* $ cat ~/.rally/rally.ini
```
[meta]
config.version = 17

[system]
env.name = local

[node]
root.dir = /home/elasticsearch/.rally/benchmarks
src.root.dir = /home/elasticsearch/.rally/benchmarks/src

[source]
# 远程仓库地址
remote.repo.url = https://github.com/elastic/elasticsearch.git   
elasticsearch.src.subdir = elasticsearch

[benchmarks]
local.dataset.cache = /home/elasticsearch/.rally/benchmarks/data

#关于报告输出到es的配置
[reporting]
datastore.type = in-memory
datastore.host = 
datastore.port = 
datastore.secure = False
datastore.user = 
datastore.password =   

#赛道配置
[tracks]
default.url = https://github.com/elastic/rally-tracks

[teams]
default.url = https://github.com/elastic/rally-teams

[defaults]
preserve_benchmark_candidate = False

[distributions]
release.cache = true
```

# [离线测试](https://esrally.readthedocs.io/en/latest/offline.html#)
* 基准测试在首次是需要下载数据集，下载特别慢，那么我们就先手动下载测试数据，然后将测试数据上传到DATA目录，然后改一下esrally配置文件路径。
* 使用esrally压测工具需要注意以下注意事项：
  1. 启动esrally 需要使用普通用户，不能使用ROOT，来启动服务
  2. 默认的测试数据在AWS上，所以在线测试下载特别慢，我们可以通过这个链接去下载数据，提前准备好
  3. 国内下载track数据文件 https://pan.baidu.com/s/123zgferlhWflOj7qJxFD1w
    ```
    # 以geonames为例，将下载的数据放在
    /home/elasticsearch/.rally/benchmarks/data/geonames
    ```
* 启动压测
```
esrally --offline --pipeline=benchmark-only --track=geonames --target-hosts=es01.test.com:9200 
```

* [对现有集群压测](https://esrally.readthedocs.io/en/latest/recipes.html#benchmarking-an-existing-cluster)
```
su - elasticsearch
esrally race --offline \
--pipeline=benchmark-only \
--target-hosts=10.10.9.231:9200,10.10.23.165:9200,10.10.45.176:9200 \
--track=geonames \
--report-format=csv \
--report-file=/home/elasticsearch/.rally/result.csv
```

# 多个压测客户端(分发请求负载)
>
* 在每个客户端上启动esrallyd
```
esrallyd start --node-ip=10.5.5.5 --coordinator-ip=10.5.5.5
esrallyd start --node-ip=10.5.5.6 --coordinator-ip=10.5.5.5
esrallyd start --node-ip=10.5.5.7 --coordinator-ip=10.5.5.5
# --node-ip esrally客户端启动的IP
# --coordinator-ip 统筹者的IP
```
* 在coordinator(统筹者节点)启动压测
```
esrally race --track=pmc --pipeline=benchmark-only --load-driver-hosts=10.5.5.6,10.5.5.7 --target-hosts=10.5.5.11:9200,10.5.5.12:9200,10.5.5.13:9200
```