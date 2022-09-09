/etc/yum.repos.d/salt.repo:
  file.managed:
    - source: salt://init/files/salt.repo
    - user: root
    - group: root
    - mode: 644

