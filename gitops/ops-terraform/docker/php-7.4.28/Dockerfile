FROM php:7.4.28-fpm-alpine3.15

MAINTAINER vevor "devops@vevor.com"

RUN apk add --update --no-cache --virtual .build-deps \
        gcc \
        g++ \
        make \
        autoconf \
        musl-dev \
        libtool \
        linux-headers \
        tzdata \
        busybox-extras \
        gettext-dev \
        libzip-dev \
        bzip2-dev \
        libmcrypt-dev \
        libxml2-dev \
        libxslt-dev \
        libffi-dev \
        openssl-dev \
        freetype \
        freetype-dev \
        libpng \
        libpng-dev \
        jpeg-dev \
        libjpeg \
        libjpeg-turbo \
        libjpeg-turbo-dev \
        nginx \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        bcmath \
        bz2 \
        gettext \
        pdo_mysql \
        mysqli \
        xsl \
        xmlrpc \
        zip \
    && docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-install opcache \
	&& pecl channel-update pecl.php.net \
	&& no | pecl install -o -f redis \
    && pecl install mongodb \
	&& docker-php-ext-enable redis mongodb \
    && mkdir -p /etc/nginx/conf.d \
    && mkdir -p /run/php

COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./php-fpm.d/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
COPY ./phpdemo/vhost/demo.conf /etc/nginx/conf.d/demo.conf
COPY ./phpdemo/index.php /var/www/html/index.php

CMD nginx && php-fpm
