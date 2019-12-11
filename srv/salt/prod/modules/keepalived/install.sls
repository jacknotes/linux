{% set keepalived_tar= 'keepalived-1.2.17.tar.gz'  %}
{% set keepalived_source= 'salt://modules/keepalived/files/'  %}

keepalived-install:
  file.managed:
    - name: /usr/local/src/{{ keepalived_tar }}
    - source: {{ keepalived_source }}{{ keepalived_tar }}
    - mode: 755
    - user: root
    - group: root
  cmd.run:
    - name: cd /usr/local/src && tar zxf {{  keepalived_tar }} && cd keepalived-1.2.17 && ./configure --prefix=/usr/local/keepalived --disable-fwmark && make && make install
    - unless: test -d /usr/local/keepalived
    - require:
      - file: keepalived-install

/etc/sysconfig/keepalived:
  file.managed:
    - source: {{ keepalived_source }}keepalived.sysconfig
    - mode: 644
    - user: root
    - group: root

/etc/init.d/keepalived:
  file.managed:
    - source: {{ keepalived_source }}keepalived.init
    - mode: 755
    - user: root
    - group: root

keepalived-init:
  cmd.run:
    - name: chkconfig --add keepalived
    - unless: chkconfig --list | grep keepalived
    - require:
      - file: /etc/init.d/keepalived

/etc/keepalived:
  file.directory:
    - user: root
    - group: root
