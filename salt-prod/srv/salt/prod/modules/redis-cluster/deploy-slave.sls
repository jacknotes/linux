redis-require-package:
  pkg.installed:
    - names:
      - tcl
  file.managed:
    - name: /usr/local/src/redis-5.0.5.tar.gz
    - source: salt://modules/redis-cluster/files/redis-5.0.5.tar.gz
    - user: root
    - group: root
    - mode: 755

redis-install:
  file.managed:
    - name: /usr/local/redis/redis.conf
    - source: salt://modules/redis-cluster/files/redis-slave.conf
    - template: jinja
    - defaults: 
      masterIP: {{ pillar['redis-masterIP'] }}
      masterPort: {{ pillar['redis-masterPort'] }}
    - user: root
    - group: root
    - mode: 644
    - require: 
      - cmd: redis-install
  cmd.run:
    - name: cd /usr/local/src && tar xf redis-5.0.5.tar.gz && cd redis-5.0.5 && make && make PREFIX=/usr/local/redis install && echo 'export PATH=$PATH:/usr/local/redis/bin' >> /etc/profile.d/redis.sh && source /etc/profile
    - unless: 
      - test -f /etc/profile.d/redis.sh
      - test -x /usr/local/redis/bin
    - require: 
      - file: redis-require-package
      - pkg: redis-require-package

redis-service:
  cmd.run: 
    - name: /usr/local/redis/bin/redis-server /usr/local/redis/redis.conf 
    - unless: netstat -tunlp | grep 6379
    - require: 
      - file: redis-install

sentinel-service:
  file.managed:
    - name: /usr/local/redis/sentinel.conf
    - source: salt://modules/redis-cluster/files/sentinel.conf
    - template: jinja
    - defaults: 
      masterIP: {{ pillar['redis-masterIP'] }}
      masterPort: {{ pillar['redis-masterPort'] }}
    - user: root
    - group: root
    - mode: 644
    - require: 
      - cmd: redis-install
  cmd.run:
    - name: /usr/local/redis/bin/redis-sentinel /usr/local/redis/sentinel.conf
    - unless: netstat -tunlp | grep 26379
    - require: 
      - cmd: redis-service
