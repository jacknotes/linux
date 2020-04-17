zabbix-agent:
  pkg.installed:
    - name: zabbix-agent
  file.managed:
    - name: /etc/zabbix/zabbix_agentd.conf
    - source: salt://init/files/zabbix_agentd.conf
    - template: jinja
    - defaults:
      Zabbix_Server: {{ pillar['Zabbix_Server'] }}
      Hostname: {{ grains['host'] }}
    - require:
      - pkg: zabbix-agent
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
      - pkg: zabbix-agent
