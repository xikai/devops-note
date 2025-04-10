# 安装salt-ssh
```
yum install salt-ssh -y
```

# 配置要连接的节点服务器
* vim /etc/salt/roster
```
squid1:
  host: 192.168.194.102
  user: root
  port: 22
  passwd: 111111
  priv: 

  timeout: 3
```

# 测式master和节点的连通
* salt-ssh 'squid1' test.ping
```
squid1:
    True
```
```
salt-ssh 'squid1' -r 'df -h'
```