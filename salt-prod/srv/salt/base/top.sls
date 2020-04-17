base:
  '*':
    - init.init
prod:
  'type:docker_server':
    - match: pillar
    - docker.docker_install.install
    - docker.docker_elk.elk_optimize
