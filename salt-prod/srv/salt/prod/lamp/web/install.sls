include:
  - lamp.httpd.install
  - lnmp.mysql.install
  - lnmp.php.install

php-ini:
  file.managed:
    - name: /usr/local/php-fastcgi/etc/php.ini
    - source: salt://lnmp/web/files/php.ini-production
    - user: root
    - group: root
    - mode: 644

php-fpm:
  file.managed:
    - name: /usr/local/php-fastcgi/etc/php-fpm.conf
    - source: salt://lnmp/web/files/php-fpm-port.conf.default
    - user: root
    - group: root
    - mode: 644

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
    - name: /etc/httpd/httpd_online/web.conf
    - source: salt://lamp/web/files/web.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - service: web-php
    - watch_in:
      - service: httpd-service
