* https://code.google.com/p/fastdfs/
* https://github.com/happyfish100/fastdfs/blob/master/INSTALL


# 安装fastDFS tracker
```bash
unzip libfastcommon-master.zip 
cd libfastcommon-master
./make.sh
./make.sh install

tar -xzf FastDFS_v5.07.tar.gz
cd FastDFS
./make.sh
./make.sh install

mkdir /data/fastdfs/tracker -p
```

* 配置fastDFS tracker
>cp /etc/fdfs/tracker.conf.sample /etc/fdfs/tracker.conf
>vim /etc/fdfs/tracker.conf
```
base_path=/data/fastdfs/tracker
max_connections=2560
```

* 启动tracker
```
/sbin/service fdfs_trackerd start
```


# 安装fastDFS storage
```bash
unzip libfastcommon-master.zip 
cd libfastcommon-master
./make.sh
./make.sh install

tar -xzf FastDFS_v5.07.tar.gz
cd FastDFS
./make.sh
./make.sh install

mkdir /data/fastdfs/storage -p
```

* 配置fastDFS storage
>cp /etc/fdfs/storage.conf.sample /etc/fdfs/storage.conf
>vim /etc/fdfs/storage.conf
```
group_name=group1
port=23000                                    #FastDFS服务端口必须一致 一台服务器可以装多个组(group)但不能装同组的多个Storage
base_path=/data/fastdfs/storage
max_connections=2560
store_path0=/data/fastdfs/storage
tracker_server=192.168.181.128:22122        #tracker_server可以配置不止一个
```

* 启动storage
```bash
/sbin/service fdfs_storaged start 
```

* 在storage上安装nginx及fastdfs_nginx_module模块为storage提供http的访问服务(first install the FastDFS storage server and client library)
```bash
/usr/sbin/groupadd www
/usr/sbin/useradd -g www www

yum install -y openssl openssl-devel
```
```bash
tar -xzf fastdfs-nginx-module_v1.16.tar.gz
vim fastdfs-nginx-module/src/config 修改为：
  CORE_INCS="$CORE_INCS /usr/include/fastdfs /usr/include/fastcommon/"
```

```bash
tar -xzf nginx-1.6.2.tar.gz
cd nginx-1.6.2/
./configure --prefix=/usr/local/nginx \
--user=www --group=www \
--with-pcre \
--with-http_stub_status_module \
--with-http_ssl_module \
--add-module=/usr/local/src/fastdfs-nginx-module/src
make && make install
cd ..

cp /usr/local/src/fastdfs-nginx-module/src/mod_fastdfs.conf /etc/fdfs/
cp /usr/local/src/FastDFS/conf/http.conf /usr/local/src/FastDFS/conf/mime.types /etc/fdfs/
```

>vim /etc/fdfs/mod_fastdfs.conf
```
base_path=/tmp
tracker_server=192.168.181.128:22122
group_name=group1
url_have_group_name = true                #文件url中是否有group名
store_path0=/data/fastdfs/storage
```

>vim /usr/local/nginx/conf/nginx.conf
```
server {
        listen       8080;
        server_name 192.168.181.128;

        location / {
            root   html;
            index  index.html index.htm;
        }
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
        location /group1/M00 {
            root /data/fastdfs/storage/data/web;
            ngx_fastdfs_module;
        }

        access_log /data/logs/nginx/access.log;
        error_log /data/logs/nginx/error.log;
}
```
```bash
##ln -s /data/fastdfs/storage/data /data/fastdfs/storage/data/M00
/usr/local/nginx/sbin/nginx
```



# 通过fdfs客户端测试上传文件
vim /etc/fdfs/client.conf
```
base_path=/tmp
tracker_server=192.168.181.128:22122
```


* 上传
```
/usr/bin/fdfs_upload_file /etc/fdfs/client.conf 2015-12-29.log    
#能返回类似"group1/M00/00/00/wKi1gFZ_g0qADS5XAAllWoHXw_8229.log"这样的路径即为成功！
```

* 下载
```
/usr/bin/fdfs_download_file /etc/fdfs/client.conf group1/M00/00/00/wKi1gFZ_g0qADS5XAAllWoHXw_8229.log
```

* 查看storage状态：
```
/usr/bin/fdfs_monitor /etc/fdfs/client.conf
```



# 安装nginx反向代理fastdfs group实现同组读取负载均衡
```
upstream fdfs_group1 {
  server 192.168.181.129:8080 weight=1 max_fails=2 fail_timeout=30s;
  server 192.168.181.130:8080 weight=1 max_fails=2 fail_timeout=30s;
}

server{
   listen       80;
   server_name fdfs.test.com;

   location /group1/M00 {
            proxy_pass http://fdfs_group1;
        }
}
```