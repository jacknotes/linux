base:
  '*':
    - zabbix.agent
prod:
  'node*':
    - docker.docker
    - rabbitmq.rabbitmq 
    - redis-cluster.redis
