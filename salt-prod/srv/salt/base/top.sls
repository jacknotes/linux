base:
  'node2':
    - init.init
  'node3':
    - init.init
prod:
  'node2':
    - lamp.web.install
  'node3':
    - lnmp.web.install
