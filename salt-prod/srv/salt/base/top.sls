base:
  '*':
    - init.init
prod:
  'salt':
    - redis_module.redis.install
  'LocalServer':
    - docker.docker_elk.install64
    - docker.docker_zabbix.install
