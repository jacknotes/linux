include:
  - redis_module.redis_master_slave.pkg
redis-require-package:
  pkg.installed:
    - names:
      - tcl
  file.managed:
    - name: /usr/local/src/redis-5.0.5.tar.gz
    - source: salt://redis_module/redis_master_slave/files/redis-5.0.5.tar.gz
    - user: root
    - group: root
    - mode: 755

redis-install:
  file.directory:
    - name: /usr/local/redis
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && tar xf redis-5.0.5.tar.gz && cd redis-5.0.5 && make && make PREFIX=/usr/local/redis install && echo 'export PATH=$PATH:/usr/local/redis/bin' >> /etc/profile.d/redis.sh
    - unless: 
      - test -f /etc/profile.d/redis.sh
      - test -x /usr/local/redis/bin
    - require: 
      - file: redis-install
      - file: redis-require-package
      - pkg: redis-require-package

redis-init:
  file.managed:
    - name: /etc/init.d/redis-master
    - source: salt://redis_module/redis_master_slave/files/redis-master-init
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: chkconfig --add redis-master
    - unless: chkconfig --list | grep redis-master
    - require:
      - file: redis-init  

redis-service:
  file.managed:
    - name: /usr/local/redis/redis-master.conf
    - source: salt://redis_module/redis_master_slave/files/redis-master.conf
    - user: root
    - group: root
    - mode: 644
    - require: 
      - file: redis-install
  service.running:
    - name: redis-master
    - enable: True
    - require:
      - cmd: redis-init

redis-sentinel-init:
  file.managed:
    - name: /etc/init.d/redis-sentinel
    - source: salt://redis_module/redis_master_slave/files/redis-sentinel-init
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: chkconfig --add redis-sentinel
    - unless: chkconfig --list | grep redis-sentinel

sentinel-service:
  file.managed:
    - name: /usr/local/redis/sentinel.conf
    - source: salt://redis_module/redis_master_slave/files/sentinel.conf
    - template: jinja
    - defaults:
      masterIP: {{ pillar['redis-masterIP'] }}
      masterPort: {{ pillar['redis-masterPort'] }}
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: redis-install
  service.running:
    - name: redis-sentinel
    - enable: True
    - require:
      - cmd: redis-sentinel-init
      - service: redis-service

