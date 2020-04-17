/etc/security/limits.conf:
  file.managed:
    - source: salt://docker/docker_elk/files/limits.conf
    - user: root
    - group: root
    - mode: 644

reload_sysctl.conf:
  cmd.run:
    - name: echo "vm.max_map_count=262144" >> /etc/sysctl.conf && sysctl -p
    - unless: grep "vm.max_map_count=262144" /etc/sysctl.conf
