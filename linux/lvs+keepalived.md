### 环境
```
LVS-Master        192.168.1.10
LVS-BACKUP        192.168.1.11
LVS-VIP           192.168.1.8     
Realserver        192.168.1.16
Realserver        192.168.1.17
GateWay           192.168.1.1
```

### LVS-Master和LVS-BACKUP操作
* 下载LVS和Keepalvied软件包
```
cd /srv
wget http://www.linuxvirtualserver.org/software/kernel-2.6/ipvsadm-1.24.tar.gz
wget http://www.keepalived.org/software/keepalived-1.1.15.tar.gz
```

* 在安装前还需要执行以下命令：
```
uname -r
 2.6.18-194.el5

ln -s /usr/src/kernels/2.6.18-194.el5-i686/ /usr/src/linux
如果/usr/src/kernels/为空, 请执行yum -y install kernel-devel
不是太旧的内核已经包涵了lvs的模块的, 使用以下命令检查：
lsmod |grep ip_vs
如果检查结果为空, 请自行安装ipvsadm
```

* 在主从lvs服务器上安装ipvsadm和Keepalvied
```
tar -zxf ipvsadm-1.24.tar.gz
cd ipvsadm-1.24
make && make install
cd .. 
find / -name ipvsadm  # 查看ipvsadm的位置

tar -zxf keepalived-1.1.15.tar.gz
cd keepalived-1.1.15
./configure        ###Use IPVS Framework、IPVS sync daemon support、Use VRRP Framework(这三个必须为yes)
make && make install
find / -name keepalived  # 查看keepalived位置

#创建(复制)配置/可执行文件(这样启动就不用带太多路径参数)
cp /usr/local/etc/rc.d/init.d/keepalived /etc/rc.d/init.d/
cp /usr/local/etc/sysconfig/keepalived /etc/sysconfig/
mkdir /etc/keepalived
cp /usr/local/etc/keepalived/keepalived.conf /etc/keepalived/
cp /usr/local/sbin/keepalived /usr/sbin/
```

* 利用Keepalvied实现负载均衡和高可用性
>在主从负载均衡服务器上配置keepalived.conf
>vim /etc/keepalived/keepalived.conf #内容如下 
```
! Configuration File for keepalived

global_defs {
   notification_email {
     xk81757195@163.com             #接收邮件的email地址
    #failover@firewall.loc
    #sysadmin@firewall.loc
   }
   notification_email_from lvsserver@163.com     #邮件来自..
   smtp_server 127.0.0.1
   smtp_connect_timeout 30
   router_id LVS_DEVEL
}

vrrp_instance VI_1 {
    state MASTER                     #指定Keepalived的角色, backup里修改为BACKUP
    interface eth0
    virtual_router_id 51
    priority 100                     #定义优先级, backup里修改为小于100的数字, 如99
    advert_int 1                      #设定MASTER与BACKUP负载均衡器之间同步检查的时间间隔, 单位是秒.
    authentication {
        auth_type PASS                 #设置验证类型, 主要有PASS和AH两种. 
        auth_pass 1111                 #设置验证密码, MASTER与BACKUP必须使用相同的密码才能正常通信.
    }
    virtual_ipaddress {
        192.168.1.8                 #虚拟ip, 如果有多个, 每个一行
    }
}

virtual_server 192.168.1.8 80 {
    delay_loop 5                     #设置realserver健康检查时间, 单位是秒. 
    lb_algo wrr                     #设置负载调度算法, 这里设置为wrr, 即加权轮询算法.
    lb_kind DR                         #设置LVS实现负载均衡的机制
    nat_mask 255.255.255.0
    persistence_timeout 60            #同一IP的连接60秒内被分配到同一台realserve
    protocol TCP                    #用TCP协议检查realserver状态

    real_server 192.168.1.16 80 {
        weight 5                    #权重
        TCP_CHECK {
                connect_timeout 10    #10秒无响应超时
                nb_get_retry 3
                delay_before_retry 3
                connect_port 80
        }
    }

    real_server 192.168.1.17 80 {
        weight 5
        TCP_CHECK {
                connect_timeout 10
                nb_get_retry 3
                delay_before_retry 3
                connect_port 80
        }
    }
}
```

* 在realserver创建realserver.sh脚本, 脚本的作用是绑定vip并忽略arp请求
>vim /usr/local/sbin/realserver.sh #内容如下
```
#!/bin/bash
# description: Config realserver lo and apply noarp

VIP=192.168.1.8
. /etc/rc.d/init.d/functions
case "$1" in
start)
    /sbin/ifconfig lo:0 $VIP netmask 255.255.255.255 broadcast $VIP
    /sbin/route add -host $VIP dev lo:0
    echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
    echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
    echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
    echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce
    sysctl -p >/dev/null 2>&1
    echo "RealServer Start OK"
    ;;
stop)
    /sbin/ifconfig lo:0 down
    /sbin/route del $VIP >/dev/null 2>&1
    echo "0" >/proc/sys/net/ipv4/conf/lo/arp_ignore
    echo "0" >/proc/sys/net/ipv4/conf/lo/arp_announce
    echo "0" >/proc/sys/net/ipv4/conf/all/arp_ignore
    echo "0" >/proc/sys/net/ipv4/conf/all/arp_announce
    echo "RealServer Stoped"
    ;;
*)
    echo "Usage: $0 {start|stop}"
    exit 1
esac
exit 0
```
>添加权限：chmod 755 /usr/local/sbin/realserver.sh


* 启动服务
```
#master和backup分别执行：
service keepalived start
chkconfig keepalived on 

#realserver全部执行：
/usr/local/sbin/realserver.sh start
#记得写入rc.local, 因为这个不支持chkconfig
echo "/usr/local/sbin/realserver.sh start" >>/etc/rc.local
```

* 在master上执行ipvsadm检测lvs是否正常：
```
[root@localhost ~]# ipvsadm
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress：Port Scheduler Flags
  -> RemoteAddress：Port           Forward Weight ActiveConn InActConn
TCP  192.168.1.8：http wrr persistent 50
  -> 192.168.1.17：http           Route   5      0          11         
  -> 192.168.1.16：http           Route   5      0          0         
```


```
这个时候如果尝试停掉某一台realserver在收到宕机邮件的同时服务也不会中断(会丢失一部分用户会话状态, 这个就需要session同步了, 这里不多说), 而如果停掉master那么backup就会接替master继续服务(由配置文件里设置的同步时间决定服务中断的时间, 不过不会丢失用户会话状态).

windows如何充当realserver, 可参考本文： http://www.cnblogs.com/daizhj/archive/2010/06/13/1693673.html
详细配置参数和高级配置其它参考文档： http://dl.windphp.com/LoadBalance/  

参考文档： http://bbs.linuxtone.org/forum.php?mod=viewthread&tid=1077
           http://windphp.com/unix/55.html
```