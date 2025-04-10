### 安装所需软件包
```
bind                主程序所需软件
bind-utils          客户端搜寻主机名的相关指令
bind-dyndb-ldap
bind-chroot         将bind 主程序关在家里面
bind-libs           bind与相关指定使用的函数库

yum install bind*
```

### 配置
* 主配置文件/etc/named.conf
>vim /etc/named.conf
```
options {
        listen-on port 53 { any; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        allow-query     { any; };
        recursion yes;

        //forwarders { 114.114.114.114; };

        dnssec-enable yes;
        dnssec-validation yes;
        dnssec-lookaside auto;

        /* Path to ISC DLV key */
        bindkeys-file "/etc/named.iscdlv.key";

        managed-keys-directory "/var/named/dynamic";
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

zone "." IN {
        type hint;
        file "named.ca";
};

zone "ve.cn" IN {
        type master;
        file "ve.cn.zone";
};

zone "60.168.192.in-addr.arpa" IN {
        type master;
        file "192.168.60.zone";
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
```


* 正向解析配置文件
>cp /var/named/named.localhost /var/named/ve.cn.zone
>vim /var/named/ve.cn.zone
```
$TTL    86400
@               IN      SOA     ve.cn.  root.ve.cn (
                                0       ; serial
                                1D      ; refresh
                                1H      ; retry
                                1W      ; expire
                                3H )    ; minimum
                IN      NS      ns.ve.cn.
                IN      MX  10  mail.ve.cn.
ns              IN      A       192.168.60.60
mail            IN      A       192.168.60.60
ve.cn.          IN      A       192.168.60.60    ;解析ve.cn短域名
```

* 反向解析配置文件
>vim /var/named/192.168.60.zone
```
$TTL    86400
@       IN      SOA     60.168.192.in-addr.arpa.        root.ve.cn. (
                        0       ; serial
                        1D      ; refresh
                        1H      ; retry
                        1W      ; expire
                        3H )    ; minimum
        IN      NS      ns.ve.cn.
        IN      MX  10  mail.ve.cn.
60      IN      PTR     ns.ve.cn.
60      IN      PTR     mail.ve.cn.
60      IN      PTR     www.ve.cn.
```

* 检测配置文件
```
named-checkconf /etc/named.conf
named-checkzone ve.cn /var/named/ve.cn.zone
```

###启动named服务
```
service named start
```

#### bind日志
```
tail -f /var/named/data/named.run
tail -f /var/log/message
```