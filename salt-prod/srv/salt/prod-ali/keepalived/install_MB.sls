{% set keepalived_tar= 'keepalived-2.0.19.tar.gz'  %}
{% set keepalived_source= 'salt://keepalived/files/'  %}
{% set keepalived_config= 'mysql-MB-keepalived.conf'  %}

keepalived-install:
  file.managed:
    - name: /usr/local/src/{{ keepalived_tar }}
    - source: {{ keepalived_source }}{{ keepalived_tar }}
    - mode: 755
    - user: root
    - group: root
  cmd.run:
    - name: cd /usr/local/src && tar zxf {{  keepalived_tar }} && cd keepalived-2.0.19 && ./configure --prefix=/usr/local/keepalived && make && make install
    - unless: test -d /usr/local/keepalived
    - require:
      - file: keepalived-install

/etc/keepalived:
  file.directory:
    - user: root
    - group: root

keepalived-shell:
  file.managed:
    - name: /etc/keepalived/chk_mysql.sh
    - source: {{ keepalived_source }}chk_mysql.sh
    - mode: 755
    - user: root
    - group: root
    - require:
      - file: /etc/keepalived

keepalived-conf:
  file.managed:
    - name: /etc/keepalived/keepalived.conf
    - source: {{ keepalived_source }}{{ keepalived_config }}
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - VIP: 192.168.13.117
    {% if grains['id'] == 'redis-master' %}
    - ROUTEID: mysql_ha
    - STATEID: MASTER
    - PRIORITYID: 150
    {% elif grains['id'] == '192.168.13.116' %}
    - ROUTEID: mysql_ha
    - STATEID: BACKUP
    - PRIORITYID: 100
    {% endif %}
    - require:
      - file: /etc/keepalived

keepalived-service:
  service.running:
    - name: keepalived
    - enable: True
    - reload: True
    - watch:
      - file: keepalived-conf


