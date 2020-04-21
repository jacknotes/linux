base:
  '*':
    - zabbix.agent
prod:
  'node*':
    - docker.docker
    - redis-cluster.redis
