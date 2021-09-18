/etc/yum.repos.d/salt_3002.repo:
  file.managed:
    - source: salt://init/files/salt_3002.repo
    - user: root
    - group: root
    - mode: 644

