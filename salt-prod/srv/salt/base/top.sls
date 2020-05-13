base:
  'node3':
    - init.init
prod:
  'node3':
    - lnmp.web.web
    - docker.docker_zabbix.install
