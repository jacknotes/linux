base:
  '192.168.13.3*':
    - init.basePkg
prod:
  '192.168.13.33':
    - redis_module.redis_master_slave.deploy_master
  '192.168.13.3[12]':
    - match: pcre
    - redis_module.redis_master_slave.deploy_slave
