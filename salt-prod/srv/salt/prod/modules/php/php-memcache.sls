che-plugin:
  file.managed:
    - name: /usr/local/src/memcache-2.2.7.tgz  #memecache插件，并不是memcache软件
    - source: salt://modules/php/files/memcache-2.2.7.tgz
    - user: root
    - group: root
    - mode: 755

  cmd.run:
    - name: cd /usr/local/src && tar zxf memcache-2.2.7.tgz && cd memcache-2.2.7&& /usr/local/php-fastcgi/bin/phpize && ./configure --enable-memcache --with-php-config=/usr/local/php-fastcgi/bin/php-config &&  make&& make install
    - unless: test -f /usr/local/php-fastcgi/lib/php/extensions/*/memcache.so
  require:
    - file: memcache-plugin
