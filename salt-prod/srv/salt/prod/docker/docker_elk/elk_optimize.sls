/etc/security/limits.conf:
  file.managed:
    - source: salt://docker/docker_elk/files/limits.conf
    - user: root
    - group: root
    - mode: 644

vm.max_map_count:
  sysctl.present:
    - value: 262144

