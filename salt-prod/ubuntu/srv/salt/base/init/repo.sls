/etc/apt/sources.list:
  file.managed:
    - source: salt://init/files/sources18.list
    - user: root
    - group: root
    - mode: 644

