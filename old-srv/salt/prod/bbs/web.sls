include:
  - modules.php.install
  - modules.php.php-memcache
  - modules.php.php-redis
  - modules.nginx.service

php-ini:
  file.managed:
    - name: /usr/local/php-fastcgi/etc/php.ini
    - source: salt://bbs/files/php.ini-production
    - user: root
    - group: root
    - mode: 644

php-fpm:
  file.managed:
    - name: /usr/local/php-fastcgi/etc/php-fpm.conf
    - source: salt://bbs/files/php-fpm.conf.default
    - user: root
    - group: root
    - mode: 644

bbs-php:
  service.running:
    - name: php-fpm
    - enable: True
    - require:
      - cmd: php-fastcgi-service
    - watch:
      - file: php-ini
      - file: php-fpm

web-bbs:
  file.managed:
    - name: /usr/local/nginx/conf/vhost_online/bbs.conf
    - source: salt://bbs/files/nginx-bbs.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - service: bbs-php 
    - watch_in:
      - service: nginx-service
