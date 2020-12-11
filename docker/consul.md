* https://www.consul.io/docs/index.html
* https://www.consul.io/intro/getting-started/install.html
* http://www.tuicool.com/articles/j2YVB3


### 安装consul
```
cd /usr/local/src
wget https://releases.hashicorp.com/consul/0.7.2/consul_0.7.2_linux_amd64.zip
unzip consul_0.7.2_linux_amd64.zip
cp consul /usr/local/bin/
mkdir /etc/consul.d

#定义一个web服务配置文件
echo '{"service": {"name": "web", "tags": ["rails"], "port": 80}}' \
    |tee /etc/consul.d/web.json

#启动agent
consul agent -server -bootstrap-expect 1 -data-dir /tmp/consul -config-dir /etc/consul.d

#查询服务
dns api:
dig @127.0.0.1 -p 8600 web.service.consul
dig @127.0.0.1 -p 8600 web.service.consul SRV

http api:
curl http://localhost:8500/v1/catalog/service/web
```

---
# consul cluster
* 官方建议每个Consul Cluster至少有3个或以上的运行在Server mode的Agent，Client节点不限
```
192.168.221.111  agent1  server (自荐leader)
192.168.221.112  agent2  server (health check)
192.168.221.113  agent3  server (web ui)
192.168.221.114  agent4  client
```

* 启动集群所需节点
```
#111(启动server节点,-bootstrap自选为leader)
consul agent -server -bootstrap -data-dir=/tmp/consul -node=agent1 -bind=192.168.221.111

#112(启动server节点,加入集群)
consul agent -server -data-dir=/tmp/consul -node=agent2 -bind=192.168.221.112 -join=192.168.221.111

#113(启动server节点,加入集群)
consul agent -server -data-dir=/tmp/consul -node=agent3 -bind=192.168.221.113 -join=192.168.221.111

#114(启动client节点,加入集群)
consul agent -data-dir=/tmp/consul -node=agent4 -bind=192.168.221.114 -join=192.168.221.111
```

* 查看集群节点
```
consul members
```

* 离开集群
```
正常退出（状态left）：ctrl+c ，通知集群中其它节点，该节点退出，不要再往该节点发现请求
强制退出（状态failed）: kill进程，在集群中的健康标记为critical，将尝试重连
注：建议agent server正常退出，避免服务崩溃 
```


---
### k/v 数据存储
* k/v http api
```
curl http://127.0.0.1:8500/v1/kv/?recurse |python -mjson.tool
curl -X PUT -d 'test' http://127.0.0.1:8500/v1/kv/web/key1
curl -X PUT -d 'test' http://127.0.0.1:8500/v1/kv/web/key2?flags=42
curl -X PUT -d 'test' http://127.0.0.1:8500/v1/kv/web/web/sub/key3
```

* k/v cli
```
consul kv get -recurse
consul kv put web/key4 testcli
consul kv get web/key1
consul kv delete web/key1
consul kv delete -recurse web
```


---
### health check
```
mkdir /etc/consul.d
#定义host检测配置文件
echo '{"check": {"name": "ping",
  "script": "ping -c1 google.com >/dev/null", "interval": "30s"}}' \
  >/etc/consul.d/ping.json

#定义service检测配置文件
echo '{"service": {"name": "web", "tags": ["rails"], "port": 80,
  "check": {"script": "curl 127.0.0.1>/dev/null 2>&1", "interval": "10s"}}}' \
  >/etc/consul.d/web.json

#(ctrl+c)正常退出agent2，重新启动
consul agent -server -data-dir=/tmp/consul -node=agent2 -bind=192.168.221.112 -join=192.168.221.111 -config-dir=/etc/consul.d

#检测节点健康状态
curl -s http://localhost:8500/v1/health/state/any | python -m json.tool
#失败检测
curl http://localhost:8500/v1/health/state/critical
```


---
### WEB UI
```
#下载consul_web_ui源文件
wget https://releases.hashicorp.com/consul/0.7.2/consul_0.7.2_web_ui.zip
mkdir /opt/consul_web
unzip consul_0.7.2_web_ui.zip -d /opt/consul_web/

#(ctrl+c)正常退出agent3,启动web_ui
consul agent -server -data-dir=/tmp/consul -node=agent3 -bind=192.168.221.113 -join=192.168.221.111 -ui-dir=/opt/consul_web -client=0.0.0.0

[root@localhost ~]# consul members
Node    Address               Status  Type    Build  Protocol  DC
agent1  192.168.221.111:8301  alive   server  0.7.2  2         dc1
agent2  192.168.221.112:8301  alive   client  0.7.2  2         dc1
agent3  192.168.221.113:8301  alive   client  0.7.2  2         dc1

#记问consul web
http://192.168.221.113:8500/
```