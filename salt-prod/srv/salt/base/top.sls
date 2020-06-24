base:
  'node*':
    - init.init
prod:
  'node*':
    - docker.docker_install.install
