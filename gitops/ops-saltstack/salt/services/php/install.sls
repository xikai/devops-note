php_pkg:
  pkg.installed:
    - pkgs:
      - libjpeg-turbo
      - libjpeg-turbo-devel
      - libpng
      - libpng-devel
      - libmcrypt-devel
      - mhash-devel
      - php-mbstring
      - freetype
      - freetype-devel
      - libxml2
      - libxml2-devel
      - zlib
      - zlib-devel
      - glibc
      - glibc-devel
      - glib2 
      - glib2-devel
      - bzip2
      - bzip2-devel
      - ncurses
      - ncurses-devel
      - curl
      - libcurl-devel
      - e2fsprogs
      - e2fsprogs-devel
      - krb5-devel
      - libidn
      - libidn-devel
      - cyrus-sasl
      - cyrus-sasl-devel

php_source:
  file.managed:
    - name: /usr/local/src/php-5.6.16.tar.gz
    - source: salt://services/php/files/php-5.6.16.tar.gz
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - cwd: /usr/local/src
    - name: tar -xzf php-5.6.16.tar.gz
    - unless: test -d /usr/local/src/php-5.6.16
    - require:
      - file: php_source

php_compile:
  cmd.run:
    - cwd: /usr/local/src/php-5.6.16
    - name: ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --enable-fpm --with-mysql --with-mysqli --with-pdo-mysql --with-mcrypt --enable-mbstring --with-mhash --with-openssl --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir --enable-xml --disable-rpath --with-gd --enable-gd-native-ttf --with-gettext --with-curl --enable-sockets --enable-bcmath --with-bz2 --with-gettext --with-xmlrpc --enable-zip --enable-soap --with-iconv-dir --enable-opcache && make && make install
    - requires:
      - pkg: php_pkg
      - cmd: php_source
    - unless: test -d /usr/local/php

php_memcache_source:
  file.managed:
    - name: /usr/local/src/memcache-3.0.5.tgz
    - source: salt://services/php/files/memcache-3.0.5.tgz
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - cwd: /usr/local/src
    - name: tar -xzf memcache-3.0.5.tgz
    - unless: test -d /usr/local/src/memcache-3.0.5
    - require:
      - file: php_memcache_source

php_memcache_compile:
  cmd.run:
    - cwd: /usr/local/src/memcache-3.0.5
    - name: /usr/local/php/bin/phpize && ./configure --with-php-config=/usr/local/php/bin/php-config && make && make install
    - requires:
      - cmd: php_memcache_source
    - unless: test -f /usr/local/php/lib/php/extensions/no-debug-non-zts-20131226/memcache.so

php_redis_source:
  file.managed:
    - name: /usr/local/src/phpredis-3.1.1.tar.gz
    - source: salt://services/php/files/phpredis-3.1.1.tar.gz
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - cwd: /usr/local/src
    - name: tar -xzf phpredis-3.1.1.tar.gz
    - unless: test -d /usr/local/src/phpredis-3.1.1
    - require:
      - file: php_redis_source

php_redis_compile:
  cmd.run:
    - cwd: /usr/local/src/phpredis-3.1.1
    - name: /usr/local/php/bin/phpize && ./configure --with-php-config=/usr/local/php/bin/php-config && make && make install
    - requires:
      - cmd: php_redis_source
    - unless: test -f /usr/local/php/lib/php/extensions/no-debug-non-zts-20131226/redis.so

php_igbinary_source:
  file.managed:
    - name: /usr/local/src/igbinary-1.2.1.tgz
    - source: salt://services/php/files/igbinary-1.2.1.tgz
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - cwd: /usr/local/src
    - name: tar -xzf igbinary-1.2.1.tgz
    - unless: test -d /usr/local/src/igbinary-1.2.1
    - require:
      - file: php_igbinary_source

php_igbinary_compile:
  cmd.run:
    - cwd: /usr/local/src/igbinary-1.2.1
    - name: /usr/local/php/bin/phpize && ./configure --enable-igbinary --with-php-config=/usr/local/php/bin/php-config && make && make install
    - requires:
      - cmd: php_igbinary_source
    - unless: test -f /usr/local/php/lib/php/extensions/no-debug-non-zts-20131226/igbinary.so

/usr/local/php/etc/php.ini:
  file.managed:
    - source: salt://services/php/files/php.ini
    - user: root
    - group: root
    - mode: 644
    - requires:
      - cmd: php_compile
    - template: jinja

/usr/local/php/etc/php-fpm.conf:
  file.managed:
    - source: salt://services/php/files/php-fpm.conf
    - user: root
    - group: root
    - mode: 644
    - requires:
      - cmd: php_compile

/etc/sysconfig/php-fpm:
  file.managed:
    - source: salt://services/php/files/php-fpm
    - user: root
    - group: root
    - mode: 644

php-fpm_service:
  file.managed:
    - name: /usr/lib/systemd/system/php-fpm.service
    - source: salt://services/php/files/php-fpm.service
    - user: root
    - mode: 755
  service.running:
    - name: php-fpm
    - enable: True
    - reload: True
    - watch:
      - file: /usr/local/php/etc/php.ini
      - file: /usr/local/php/etc/php-fpm.conf

php_logs_directory:
  file.directory:
    - name: /data/logs/php
    - user: www
    - group: root
    - mode: 775
    - makedirs: True

php_log_cut:
  file.managed:
    - name: /etc/logrotate.d/php
    - source: salt://services/php/files/php
    - user: root
    - group: root
    - mode: 644