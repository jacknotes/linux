zabbix-agent:
  pkg.installed:
    - name: zabbix-agent
  file.managed:
    - name: /etc/zabbix/zabbix_agentd.conf
    - source: salt://init/files/zabbix_agentd.conf
    - template: jinja
    - defaults:
        Zabbix_Server: {{ pillar['Zabbix_Server'] }}
        fqdn: {{ grains['fqdn'] }}
    - require:
      - pkg: zabbix-agent
    - backup: minion
  service.running:
    - enable: True
    - watch:
      - pkg: zabbix-agent
      - file: zabbix-agent
zabbix_agentd.conf.d:
  file.directory:
    - name: /etc/zabbix/zabbix_agentd.d
    - watch_in: 
      - service: zabbix-agent
    - require:
      - pkg: zabbix-agent


 



