#!/bin/bash

docker run -d \
  --name nginx-php \
  --net=host \
  $1/php:7.4.28-fpm-alpine3.15-nginx
