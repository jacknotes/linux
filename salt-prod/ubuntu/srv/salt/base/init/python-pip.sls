pip-dir:
  file.directory:
    - name: /root/.pip
    - user: root
    - group: root
    - mode: 755

/root/.pip/pip.conf:
  file.managed:
    - source: salt://init/files/pip.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: pip-dir

