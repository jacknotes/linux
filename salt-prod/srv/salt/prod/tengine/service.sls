include:
  - tengine.install

tengine-index:
  file.managed:
    - name: /usr/local/nginx/html/index.html
    - source: salt://tengine/files/index.html
    - user: www
    - group: www
    - mode: 775

tengine-init:
  file.managed:
    - name: /etc/init.d/tengine
    - source: salt://tengine/files/tengine-init
    - mode: 755
    - user: root
    - group: root
  cmd.run:
    - name: chkconfig --add tengine
    - unless: chkconfig --list | grep tengine
    - require:
      - file: tengine-init

/usr/local/nginx/conf/nginx.conf:
  file.managed:
    - source: salt://tengine/files/nginx.conf
    - user: www
    - group: www
    - mode: 644 

tengine-service:
  service.running:
    - name: tengine
    - enable: True
    - reload: True
    - require:
      - cmd: tengine-init
    - watch:
      - file: /usr/local/nginx/conf/nginx.conf
      - file: tengine-online

tengine-online:
  file.directory:
    - name: /usr/local/nginx/conf/vhost_online

tengine-offline:
  file.directory:
    - name: /usr/local/nginx/conf/vhost_offline
