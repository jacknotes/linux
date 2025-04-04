include:
  - lnmp.pkg.make
  - lnmp.user.www

pkg-php:
  pkg.installed:
    - names:
      - swig
      - libjpeg-turbo
      - libjpeg-turbo-devel
      - libpng
      - libpng-devel
      - freetype
      - freetype-devel
      - libxml2
      - libxml2-devel
      - zlib
      - zlib-devel
      - re2c
      - libcurl
      - libcurl-devel
      - libmcrypt
      - libmcrypt-devel
      - mhash
      - mhash-devel
      - mcrypt

php-source-install:
  file.managed:
    - name: /usr/local/src/php-5.6.9.tar.gz
    - source: salt://modules/php/files/php-5.6.9.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && tar zxf php-5.6.9.tar.gz && cd php-5.6.9&&  ./configure --prefix=/usr/local/php-fastcgi --with-mysql=/usr/local/mysql --with-openssl --with-mysqli=/usr/local/mysql/bin/mysql_config  --with-jpeg-dir --with-png-dir --with-zlib --enable-xml  --with-libxml-dir --with-curl --enable-bcmath --enable-shmop --enable-sysvsem  --enable-inline-optimization --enable-mbregex --enable-mbstring --with-gd --enable-gd-native-ttf --with-freetype-dir --with-gettext=/usr/lib64 --enable-sockets --with-xmlrpc --enable-zip --enable-soap --disable-debug --enable-opcache --enable-zip --with-config-file-path=/usr/local/php-fastcgi/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www && make && make install
    - require:
      - file: php-source-install
      - user: www-user-group
      - pkg: make-pkg
    - unless: test -d /usr/local/php-fastcgi

pdo-plugin:
  cmd.run:
    - name: cd /usr/local/src/php-5.6.9/ext/pdo_mysql/ && /usr/local/php-fastcgi/bin/phpize && ./configure --with-php-config=/usr/local/php-fastcgi/bin/php-config --with-pdo-mysql=/usr/local/mysql &&  make&& make install
    - unless: test -f /usr/local/php-fastcgi/lib/php/extensions/*/pdo_mysql.so
    - require:
      - cmd: php-source-install

php-fastcgi-service:
  file.managed:
    - name: /etc/init.d/php-fpm
    - source: salt://modules/php/files/init.d.php-fpm
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: chkconfig --add php-fpm
    - unless: chkconfig --list | grep php-fpm
    - require:
      - file: php-fastcgi-service
