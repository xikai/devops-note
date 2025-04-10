#!/bin/bash
docker build -t registry.cn-shanghai.aliyuncs.com/vevor-terraform/php:7.4.28-fpm-alpine3.15-nginx .
docker push registry.cn-shanghai.aliyuncs.com/vevor-terraform/php:7.4.28-fpm-alpine3.15-nginx 