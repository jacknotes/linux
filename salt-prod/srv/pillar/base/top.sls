base:
  '*':
    - zabbix-agent
    - salt-minion
prod:
  '*':
    - prometheus.prometheus
