include:
  - lnmp.nginx.install

nginx-webroot:
  file.directory:
    - name: /webroot
    - user: www
    - group: www
    - mode: 775

nginx-index:
  file.managed:
    - name: /webroot/index.php
    - source: salt://lnmp/nginx/files/index.php
    - user: www
    - group: www
    - mode: 775
    - require:
      - file: nginx-webroot

nginx-init:
  file.managed:
    - name: /etc/init.d/nginx
    - source: salt://lnmp/nginx/files/nginx-init
    - mode: 755
    - user: root
    - group: root
  cmd.run:
    - name: chkconfig --add nginx
    - unless: chkconfig --list | grep nginx
    - require:
      - file: nginx-init

/usr/local/nginx/conf/nginx.conf:
  file.managed:
    - source: salt://lnmp/nginx/files/nginx.conf
    - user: www
    - group: www
    - mode: 644 

nginx-service:
  service.running:
    - name: nginx
    - enable: True
    - reload: True
    - require:
      - cmd: nginx-init
    - watch:
      - file: /usr/local/nginx/conf/nginx.conf
      - file: nginx-online

nginx-online:
  file.directory:
    - name: /usr/local/nginx/conf/vhost_online

nginx-offline:
  file.directory:
    - name: /usr/local/nginx/conf/vhost_offline
