hosts:
  file.managed:
    - name: /etc/hosts
    - source: salt://modules/rabbitmq/files/hosts
    - user: root
    - group: root
    - mode: 644
  
rabbitmq-erlang.repo:
  file.managed:
    - name: /etc/yum.repos.d/rabbitmq-erlang.repo
    - source: salt://modules/rabbitmq/files/rabbitmq-erlang.repo
    - user: root
    - group: root
    - mode: 644

rabbitmq.repo:
  file.managed:
    - name: /etc/yum.repos.d/rabbitmq.repo
    - source: salt://modules/rabbitmq/files/rabbitmq.repo
    - user: root
    - group: root
    - mode: 644

erlang-install:
#  cmd.run:
#    - name: yum clean all && yum makecache &> /dev/null
  pkg.installed:
    - names: 
      - erlang
    - require: 
      - file: rabbitmq-erlang.repo

/tmp/rabbitmq-release-signing-key.asc:
  file.managed:
    - source: salt://modules/rabbitmq/files/rabbitmq-release-signing-key.asc
    - user: root
    - group: root
    - mode: 644      

rabbitmq-install:
  cmd.run:
    - name: rpm --import /tmp/rabbitmq-release-signing-key.asc
  pkg.installed:
    - names: 
      - rabbitmq-server
    - require: 
      - file: rabbitmq.repo

/etc/rabbitmq/rabbitmq.conf:
  file.managed:
    - source: salt://modules/rabbitmq/files/rabbitmq.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: rabbitmq-install
    - watch_in:
      - service: rabbitmq-service

/etc/rabbitmq/enabled_plugins:
 file.managed:
    - source: salt://modules/rabbitmq/files/enabled_plugins
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: rabbitmq-install
    - watch_in:
      - service: rabbitmq-service

erlang-cookie:
  file.managed:
    - name: /var/lib/rabbitmq/.erlang.cookie
    - source: salt://modules/rabbitmq/files/.erlang.cookie 
    - user: rabbitmq
    - root: rabbitmq
    - mode: 400
    - watch_in:
      - service: rabbitmq-service

rabbitmq-service:
  service.running:
    - name: rabbitmq-server 
    - enable: True
    - require:
      - pkg: rabbitmq-install
    
add-useradd.sh:
  file.managed:
    - name: /etc/rabbitmq/useradd.sh
    - source: salt://modules/rabbitmq/files/useradd.sh
    - user: root
    - group: root
    - mode: 755

add-useradd:
  cmd.run: 
    - name: /bin/bash /etc/rabbitmq/useradd.sh
    - unless: rabbitmqctl list_users | grep ^admin
    - require:
      - service: rabbitmq-service
      - file: add-useradd.sh

