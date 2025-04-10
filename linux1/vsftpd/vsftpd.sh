#!/usr/bin/env bash
# 云主机弹性IP 开启：PASV_ADDRESS_ENABLE=YES，PASV_ADDRESS=202.10.76.12

mkdir -p /data/www

docker run -d -v /data/www:/home/vsftpd \
    -p 20:20 -p 21:21 -p 21100-21110:21100-21110 \
    -e FTP_USER=myuser -e FTP_PASS=mypassdd01 \
    -e PASV_ADDRESS_ENABLE=YES -e PASV_ADDRESS=202.10.76.12 -e PASV_MIN_PORT=21100 -e PASV_MAX_PORT=21110 \
    --name vsftpd --restart=always fauria/vsftpd