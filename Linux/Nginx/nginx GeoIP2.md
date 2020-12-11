* https://github.com/leev/ngx_http_geoip2_module

# 安装GeoIP2模块(基于ip cookie灰度分流)
* 安装依赖包
```bash
yum install -y git m4 autoconf automake gettext libtool
```
* 下载所需的数据文件和nginx_geoip2 源码包
```bash
cd /usr/local/src
wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.mmdb.gz
wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz
wget https://github.com/maxmind/libmaxminddb/releases/download/1.3.2/libmaxminddb-1.3.2.tar.gz
git clone https://github.com/leev/ngx_http_geoip2_module
```
* 解压数据文件
```bash        
gunzip GeoLite2-Country.mmdb.gz 
gunzip GeoLite2-City.mmdb.gz
cp GeoLite2-Country.mmdb GeoLite2-City.mmdb /usr/local/nginx/conf
```

* 安装libmaxminddb
```bash
tar -xzf libmaxminddb-1.3.2.tar.gz
cd libmaxminddb-1.3.2
./configure
make && make install
ldconfig
```

* 测试maxminddb
```bash
mmdblookup --file /usr/local/nginx/conf/GeoLite2-Country.mmdb --ip 112.225.35.70 country iso_code
```

* 进入nginx 源码目录（nginx -V 查看之前的编译参数）
```bash
cd /usr/local/src/nginx-1.12.0
./configure --user=www --group=www --prefix=/usr/local/nginx --with-pcre --with-http_stub_status_module --with-http_ssl_module --with-http_geoip_module --with-http_realip_module --with-http_v2_module --with-openssl=/usr/local/src/openssl-1.0.2l --add-module=/usr/local/src/ngx_cache_purge-2.3 --add-module=/usr/local/src/nginx-http-concat --add-dynamic-module=/usr/local/src/ngx_http_geoip2_module

make
make install
```

* vim /usr/local/nginx/conf/nginx.conf
```
load_module modules/ngx_http_geoip2_module.so;
http {
    geoip2 /usr/local/nginx/conf/GeoLite2-Country.mmdb {
        $geoip2_data_country_code default=US country iso_code;
        $geoip2_data_country_name country names en;
    }

    geoip2 /usr/local/nginx/conf/GeoLite2-City.mmdb {
        $geoip2_data_city_name default=London city names en;
    }
}
```

* vim /usr/local/nginx/conf/fastcgi_params
```
fastcgi_param  COUNTRY_CODE       $geoip2_data_country_code;
fastcgi_param  COUNTRY_NAME       $geoip2_data_country_name;
fastcgi_param  CITY_NAME          $geoip2_data_city_name;
```

* 加载libmaxminddb 
```bash
echo /usr/local/lib >> /etc/ld.so.conf
ldconfig
```
* 检测nginx 配置
```bash
nginx -t
```

* nginx配置
```
if ($geoip2_data_country_code = CN) {
}
```



# 示例配置：
```
upstream camferewww {
    server 172.31.40.14:80 max_fails=2 fail_timeout=5s;
    server 172.31.34.217:80 max_fails=2 fail_timeout=5s;
}

upstream camferegray {
    server 172.31.40.14:83 max_fails=2 fail_timeout=5s;
    server 172.31.34.217:83 max_fails=2 fail_timeout=5s;
}

server {
    listen 80;
    server_name www.camfere.com camfere.com;

    set $backend camferewww;
    set $gray false;
    if ($geoip2_data_country_code = "CN") {
        set $backend camferegray;
        set $gray true;
    }
    add_header set-cookie "gray=$gray; max-age=86400";
    
    
    if ($http_cookie ~* "gray=true") {
        set $backend camferegray;
    }
    
    location / {
        proxy_pass http://$backend;
    
        proxy_ignore_headers X-Accel-Expires Expires Cache-Control Set-Cookie;
        proxy_hide_header X-Powered-By;
        expires    3m;
    
        proxy_cache cache_one;
        proxy_cache_valid 200 301 302 304 3m;
        proxy_cache_key $host$ruri$cookie_TT_CURR$cookie_gray;
        add_header X-Cache '$upstream_cache_status from $server_addr';
    }

    location ~ /purge(/.*)
    {
        allow all;
        proxy_cache_purge cache_one $host$1$is_args$args$cookie_TT_CURR$cookie_gray;
    }
}
```