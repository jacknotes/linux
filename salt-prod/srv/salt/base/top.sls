base:
  '*':
    - init.init
prod:
  'type:docker_server':
    - match: pillar
    - docker.docker_install.install
  'node2':
    - redis_module.redis_cluster.deploy_master
  'node3':
    - redis_module.redis_cluster.deploy_slave
  'node1':
    - redis_module.redis_cluster.deploy_slave
