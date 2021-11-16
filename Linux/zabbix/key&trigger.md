* zabbix系统自带key
```
https://www.zabbix.com/documentation/2.2/manual/config/items/itemtypes/zabbix_agent
```

* 自定义agent key(zabbix_agentd.conf)
```
UnsafeUserParameters=1   #必须重启zabbix_agentd; 开启UserParameter中的命令可以包含特殊字符，如果字符串中出现$ 需要用$$。

UserParameter=get.os.type, head -1 /etc/issue
zabbix_get -s 127.0.0.1 -k get.os.type
```

* 传递参数给key,多个参数用逗号分隔
```
UserParameter=wc[*],grep -c "$2" $1  
zabbix_get -s 127.0.0.1 -k wc[/etc/passwd,root]  等于grep -c "root" /etc/passwd
```

* Trigger表达式
```
{<server>:<key>.<function>(parameter)}<operator><constant>

{Zabbix server:agent.ping.nodata(5m)}=1
{Zabbix server:system.cpu.load[all,avg1].last(0)}>5 | {Zabbix server:system.cpu.load[all,avg1].min(10m)}>2
{Zabbix server:vfs.file.cksum[/etc/passwd].diff(0)}>0
```