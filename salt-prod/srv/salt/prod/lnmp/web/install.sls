include:
  - lnmp.nginx.service
  - lnmp.mysql.install
  - lnmp.php.install

php-ini:
  file.managed:
    - name: /usr/local/php-fastcgi/etc/php.ini
    - source: salt://lnmp/web/files/php.ini-production
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: pdo-plugin

php-fpm:
  file.managed:
    - name: /usr/local/php-fastcgi/etc/php-fpm.conf
    - source: salt://lnmp/web/files/php-fpm.conf.default
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: pdo-plugin

web-php:
  service.running:
    - name: php-fpm
    - enable: True
    - require:
      - cmd: php-fastcgi-service
    - watch:
      - file: php-ini
      - file: php-fpm

web-service:
  file.managed:
    - name: /usr/local/nginx/conf/vhost_online/web.conf
    - source: salt://lnmp/web/files/nginx-web.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - service: web-php
    - watch_in:
      - service: nginx-service
