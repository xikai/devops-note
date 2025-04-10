* https://blog.csdn.net/u012375924/article/details/78180722
* https://blog.csdn.net/wmdscjhdpy/article/details/123159308

# 安装libcgroup
```
apt install libcgroup*
```

# 配置规则组
* vim /etc/cgconfig.conf
>man cgconfig.conf
```
group users_mem_limit {
    memory {
        memory.limit_in_bytes = "30064771072";
        memory.swappiness = 0;
    }
}

group users_cpu_limit {
    cpu {
        cpu.cfs_quota_us = "10000";
        cpu.cfs_period_us = "50000";
    }
}
```

# 配置应用规则
* vim /etc/cgrules.conf
>man cgrules.conf
```
@admin        cpu         users_cpu_limit/
root          memory      users_mem_limit/
root:a.out    memory      users_mem_limit/          
```

* 启动服务
```
cgconfigparser -l /etc/cgconfig.conf
cgrulesengd
```