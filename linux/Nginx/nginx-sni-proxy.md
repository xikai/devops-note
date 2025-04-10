* http://nginx.org/en/docs/http/configuring_https_servers.html#sni
* http://nginx.org/en/docs/stream/ngx_stream_ssl_preread_module.html#var_ssl_preread_server_name

* 在使用TLS的时候，http server希望根据HTTP请求中不同的host来决定使用不同的证书
  1. SSL位于HTTP协议和TCP协议之间,TLS的握手以及证书验证都是在HTTP开始之前,也就是说，一个请求到来， 在握手阶段，SSL并不知道这个请求到底是请求哪个Host
  2. 所以有了SNI：Server Name Indication，工作原理是在SSL握手的阶段，允许从 ClientHello 消息中提取信息，而不会终止 SSL/TLS，例如提取通过 SNI 请求的服务器名称。

# openssl 0.9.8f+
```
wget https://www.openssl.org/source/old/1.0.2/openssl-1.0.2k.tar.gz
tar -xzf openssl-1.0.2k.tar.gz
```

# nginx添加stream模块,开启SNI
```
./configure --with-stream --with-stream_ssl_preread_module --with-openssl=/root/openssl-1.0.2k --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module
make
make install
```
```
[root@localhost nginx-1.22.0]# /usr/local/nginx/sbin/nginx -V
...
TLS SNI support enabled
...
```

# 配置sni proxy (172.16.0.223)
* 如果使用Nginx反向代理HTTPS站点，且需要通过HTTPS访问的时候，则需要要在Nginx上配置SSL证书。而SNI Proxy则可以解决这个问题，我们无需在反代服务器上部署SSL证书，即可通过HTTPS访问
```
error_log logs/error.log;

events {
    worker_connections  65535;
}

stream {
    map_hash_max_size 512;
    map_hash_bucket_size 128;

    map $ssl_preread_server_name $name {
        www.google.com www.google.com:443;
        developers.google.com developers.google.com:443;
        maps.googleapis.com maps.googleapis.com:443;
    }

    server {
        listen      443;

        resolver 8.8.8.8;

        proxy_pass  $name;
        ssl_preread on;
    }
}
```

# client测试
* vim /etc/hosts
```
172.16.0.223 www.google.com
172.16.0.223 developers.google.com maps.googleapis.com
```
```
# 这里注意请求要使用https
curl https://google.com
```