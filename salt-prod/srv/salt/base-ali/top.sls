base:
  'vpc2-docker01.ops.hs.com':
    - init.init
#  'redis-slave1,redis-slave2':
#    - match: list
#    - init.basePkg
prod:
  'vpc2-docker01.ops.hs.com':
    - docker.docker_install.install
  #'192.168.13.3[12]':
  #  - match: pcre
  #  - redis_module.redis_master_slave.deploy_slave

