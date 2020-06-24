include:
  - lamp.apr.install-apr
  - lnmp.user.www

httpd-source-install:
  file.managed:
    - name: /usr/local/src/httpd-2.4.43.tar.bz2
    - source: salt://lamp/httpd/files/httpd-2.4.43.tar.bz2
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && tar xf httpd-2.4.43.tar.bz2 && cd httpd-2.4.43 && ./configure --prefix=/usr/local/httpd --sysconfdir=/etc/httpd --enable-so --enable-rewrite --enable-ssl --enable-cgi --enable-cgid --enable-modules=most --enable-mods-shared=most --enable-mpms-shared=all --with-mpm=event --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util && make && make install && chown -R www:www /usr/local/httpd
    - unless: test -d /usr/local/httpd
    - require:
      - user: www-user-group
      - file: httpd-source-install
      - cmd: apr-source-install 
      - cmd: apr-util-source-install 

httpd-start-shell:
  file.managed:
    - name: /etc/init.d/httpd
    - source: salt://lamp/httpd/files/httpd
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: chkconfig --add httpd
    - unless: chkconfig --list httpd
    - require: 
      - file: httpd-start-shell
      - cmd: httpd-source-install

httpd-webroot:
  file.directory:
    - name: /webroot
    - user: www
    - group: www
    - mode: 775
  cmd.run:
    - name: mkdir /webroot/logs
    - unless: test -d /webroot/logs
    - user: www
    - group: www
    - mode: 775
    - require:
      - file: httpd-webroot

httpd-index:
  file.managed:
    - name: /webroot/index.php
    - source: salt://lamp/httpd/files/index.php
    - user: www
    - group: www
    - mode: 775
    - require:
      - file: httpd-webroot

httpd-conf:
  file.managed:
    - name: /etc/httpd/httpd.conf
    - source: salt://lamp/httpd/files/httpd.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: httpd-source-install

httpd-online:
  file.directory:
    - name: /etc/httpd/httpd_online
    - user: root
    - group: root
    - mode: 644

httpd-offline:
  file.directory:
    - name: /etc/httpd/httpd_offline
    - user: root
    - group: root
    - mode: 644

httpd-service:
  service.running:
    - name: httpd
    - enable: True
    - require:
      - cmd: httpd-start-shell
    - watch:
      - file: httpd-conf
      - file: httpd-online

