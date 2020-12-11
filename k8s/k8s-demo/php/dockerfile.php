FROM php:7.2-fpm-alpine

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
  && apk add --update --no-cache --virtual .build-deps \
      g++ \
      gcc \
      make \
      autoconf \
      musl-dev \
      libtool \
      linux-headers \
      tzdata \
      freetype \
      freetype-dev \
      libpng \
      libpng-dev \
      libjpeg-turbo \
      libjpeg-turbo-dev \
      gettext-dev \
      openldap-dev \
      libxml2-dev \
      libxslt-dev \
      libzip-dev \
      bzip2-dev \
      libmcrypt-dev \
      libmemcached-dev \
      rabbitmq-c-dev \
      hiredis \
      hiredis-dev \
      sudo \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install -j$(nproc) \
      gd \
      bcmath \
      bz2 \
      gettext \
      pdo_mysql \
      mysqli \
      pcntl \
      soap \
      ldap \
      sockets \
      sysvsem \
      xsl \
      xmlrpc \
      zip \
      wddx \
      opcache \
  && wget https://github.com/tideways/php-xhprof-extension/archive/v4.1.3.tar.gz \
  && tar -xf v4.1.3.tar.gz \
  && rm -rf v4.1.3.tar.gz \
  && ( \
      cd php-xhprof-extension-4.1.3 \
      && phpize \
      && ./configure \
      && make \
      && make install \
      && cd .. \
  ) \
  && rm -rf php-xhprof-extension-4.1.3 \
  && pecl install mcrypt-1.0.1 \
  && pecl install swoole-4.2.10 \
  && pecl install memcached-3.0.4 \
  && pecl install xdebug-2.6.0 \
  && pecl install redis-4.0.2 \
  && pecl install mongodb-1.5.3 \
  && pecl install amqp-1.9.3 \
  && docker-php-ext-enable tideways mcrypt swoole memcached xdebug redis mongodb amqp \
  && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone