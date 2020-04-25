base:
  '*':
    - init.init
prod:
  'type:docker_server':
    - match: pillar
    - docker.docker_install.install
    - docker.docker_elk.elk_optimize
  'node3':
    - modules.rabbitmq.rabbitmq
    - modules.redis-cluster.deploy-master
  'node2':
    - modules.rabbitmq.rabbitmq-slave
    - modules.redis-cluster.deploy-slave
