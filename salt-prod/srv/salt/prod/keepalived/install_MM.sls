{% set keepalived_tar= 'keepalived-2.0.19.tar.gz'  %}
{% set keepalived_source= 'salt://keepalived/files/'  %}
{% set keepalived_config= 'nginx-MM-keepalived.conf'  %}
{% set keepalived_shell= 'chk_nginx.sh'  %}

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
    - name: /etc/keepalived/chk_nginx.sh
    - source: {{ keepalived_source }}{{ keepalived_shell }}
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
    - VIP1: 192.168.15.50
    - VIP2: 192.168.15.51
    {% if grains['fqdn'] == 'node2' %}
    - ROUTEID: node2
    - STATEID1: MASTER
    - PRIORITYID1: 150
    - ROUTEID: node2
    - STATEID2: BACKUP
    - PRIORITYID2: 100
    {% elif grains['fqdn'] == 'node3' %}
    - ROUTEID: node3
    - STATEID1: BACKUP
    - PRIORITYID1: 100
    - ROUTEID: node3
    - STATEID2: MASTER
    - PRIORITYID2: 150
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


