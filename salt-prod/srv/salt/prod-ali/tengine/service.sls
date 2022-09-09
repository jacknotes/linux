include:
  - tengine.install

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
    - source: salt://tengine/files/nginx.conf.default
    - user: tengine
    - group: tengine
    - mode: 644 
    - template: jinja
    - defaults:
      TengineWorkerCore: {{ grains['num_cpus'] }}

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
