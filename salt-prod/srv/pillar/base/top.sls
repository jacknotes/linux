base:
  '*':
    - zabbix-agent
    - salt-minion
prod:
  '*':
    - redis-cluster.redis
    - rabbitmq.rabbitmq
