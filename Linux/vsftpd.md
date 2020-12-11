* https://security.appspot.com/vsftpd/vsftpd_conf.html

* 安装vsftpd
```bash
yum install -y vsftpd db4 db4-utils db4-devel
```

* 配置vsftpd
>cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak
>vim /etc/vsftpd/vsftpd.conf
```
listen=YES
anonymous_enable=NO
local_enable=YES
local_umask=022
xferlog_enable=YES
xferlog_file=/var/log/vsftpd.log
xferlog_std_format=YES
chroot_local_user=YES
ascii_upload_enable=YES
ascii_download_enable=YES

pasv_enable=YES
#pasv_address=<FTP服务器公网IP地址>  #本教程中为Linux实例公网IP
pasv_min_port=2000
pasv_max_port=2010

guest_enable=YES
guest_username=ftp
user_config_dir=/etc/vsftpd/vconf

pam_service_name=vsftpd
```


* 配置vsftpd PAM认证(添加以下)
>vim /etc/pam.d/vsftpd
```
auth        required        /lib64/security/pam_userdb.so     db=/etc/vsftpd/virtual_users.txt
account     required        /lib64/security/pam_userdb.so     db=/etc/vsftpd/virtual_users.txt
```

* 创建与虚拟用户对应的系统用户
```bash
mkdir /data/ftp
chmod -R 755 /data/ftp
chmod -R 777 /data/ftp/*
```

* 创建虚拟用户
```bash
touch /etc/vsftpd/virtual_users.txt
echo -e "test\na123456" > /etc/vsftpd/virtual_users.txt
db_load -T -t hash -f /etc/vsftpd/virtual_users.txt /etc/vsftpd/virtual_users.db
chmod 600 /etc/vsftpd/virtual_users.db
```

* 虚拟用户配置
>mkdir /etc/vsftpd/vconf
>vim /etc/vsftpd/vconf/test
```
local_root=/data/ftp/ftp01
write_enable=YES
anon_umask=022
anon_world_readable_only=NO
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
```

* 启动vsftpd
```
setenforce 0
service vsftpd restart
```

```
https://help.aliyun.com/document_detail/92048.html?spm=5176.11065259.1996646101.searchclickresult.61cf365167negz&aly_as=AFsqbdwz
## 云主机弹性公网IP 支持TCP/UDP/ICMP协议。默认不支持被动模式FTP等协议。需要配置#pasv_address=<FTP服务器公网IP地址>  #本教程中为Linux实例公网IP
主动模式：客户端向FTP服务器发送端口信息，由服务器主动连接该端口。
被动模式：FTP服务器开启并发送端口信息给客户端，由客户端连接该端口，服务器被动接受连接
```

### docker安装vsftpd
```
#!/usr/bin/env bash
# 云主机弹性IP 开启：PASV_ADDRESS_ENABLE=YES，PASV_ADDRESS=202.10.76.12

mkdir -p /data/www

docker run -d -v /data/www:/home/vsftpd \
    -p 20:20 -p 21:21 -p 21100-21110:21100-21110 \
    -e FTP_USER=myuser -e FTP_PASS=mypassdd01 \
    -e PASV_ADDRESS_ENABLE=YES -e PASV_ADDRESS=202.10.76.12 -e PASV_MIN_PORT=21100 -e PASV_MAX_PORT=21110 \
    --name vsftpd --restart=always fauria/vsftpd
```