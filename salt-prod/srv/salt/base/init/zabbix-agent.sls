zabbix-agent-source-install:
  file.managed:
    - name: /usr/local/src/zabbix-agent-3.4.15-1.el7.x86_64.rpm
    - source: salt://init/files/zabbix-agent-3.4.15-1.el7.x86_64.rpm
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: yum localinstall -y /usr/local/src/zabbix-agent-3.4.15-1.el7.x86_64.rpm
    - unless: rpm -qa | grep zabbix-agent
    - require:
      - file: zabbix-agent-source-install

zabbix-agent:
  file.managed:
    - name: /etc/zabbix/zabbix_agentd.conf
    - source: salt://init/files/zabbix_agentd.conf
    - template: jinja
    - defaults:
      Zabbix_Server: {{ pillar['Zabbix_Server'] }}
      Hostname: {{ grains['host'] }}
    - require:
      - cmd: zabbix-agent-source-install
  service.running:
    - enable: True
    - watch:
      - file: zabbix-agent

zabbix_agentd.d:
  file.directory:
    - name: /etc/zabbix/zabbix_agentd.d
    - watch_in: 
      - service: zabbix-agent
    - require:
      - cmd: zabbix-agent-source-install
