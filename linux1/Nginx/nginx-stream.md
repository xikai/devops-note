* http://nginx.org/en/docs/stream/ngx_stream_core_module.html

* nginx tcp/udp代理

# 添加stream模块
```
./configure --with-stream
```

# 配置nginx
>vim nginx.conf
```
error_log /var/log/nginx/error.log info;

events {
    worker_connections  65535;
}

http {
    ……
}

stream {
    upstream openvpn {
        server 183.11.233.147:11113;
    }

    server {
        listen 11113 udp reuseport;
        proxy_timeout 20s;
        proxy_pass openvpn;
    }
}
```