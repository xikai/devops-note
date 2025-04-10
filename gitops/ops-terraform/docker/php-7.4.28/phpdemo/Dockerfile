FROM registry.cn-shanghai.aliyuncs.com/vevor-terraform/php:7.4.28-fpm-alpine3.15-nginx

MAINTAINER xikai "kai.xi@vevor.net"

ADD . /var/www/html/
COPY ./vhost/demo.conf /etc/nginx/conf.d/demo.conf 