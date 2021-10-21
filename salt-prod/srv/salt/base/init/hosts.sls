/etc/hosts:
  file.managed:
    - source: salt://init/files/hosts
    - user: root
    - group: root
    - mode: 644
