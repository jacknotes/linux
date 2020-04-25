base:
  '*':
    - init.init
prod:
  'Linux-node3*':
    - cluster.haproxy-outside
    - cluster.haproxy-outside-keepalived
    - bbs.memcached
    - bbs.web

  'Linux-node4*':
    - cluster.haproxy-outside
    - cluster.haproxy-outside-keepalived
    - bbs.memcached
    - bbs.web
