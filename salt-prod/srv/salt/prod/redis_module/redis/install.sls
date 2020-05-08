redis-require-package:
  pkg.installed:
    - names:
      - tcl
#      - jemalloc-devel
  file.managed:
    - name: /usr/local/src/redis-5.0.5.tar.gz
    - source: salt://redis_module/redis/files/redis-5.0.5.tar.gz
    - user: root
    - group: root
    - mode: 755

redis-install:
  file.managed:
    - name: /usr/local/redis/redis.conf
    - source: salt://redis_module/redis/files/redis.conf
    - user: root
    - group: root
    - mode: 644
    - require: 
      - cmd: redis-install
  cmd.run:
    - name: cd /usr/local/src && tar xf redis-5.0.5.tar.gz && cd redis-5.0.5 && make && make PREFIX=/usr/local/redis install && echo 'export PATH=$PATH:/usr/local/redis/bin' >> /etc/profile.d/redis.sh && source /etc/profile
    - unless: test -f /etc/profile.d/redis.sh
    - require: 
      - file: redis-require-package
      - pkg: redis-require-package

redis-init:
  file.managed:
    - name: /etc/init.d/redis
    - source: salt://redis_module/redis/files/redis-init
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: chkconfig --add redis
    - unless: chkconfig --list | grep redis
    - require:
      - file: redis-init  

redis-service:
  service.running:
    - name: redis
    - enable: True
    - require:
      - cmd: redis-init

