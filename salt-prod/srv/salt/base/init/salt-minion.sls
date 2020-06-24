include:
  - init.repo  

salt-minion:
  pkg.installed:
    - name: salt-minion
  file.managed:
    - name: /etc/salt/minion
    - source: salt://init/files/minion
    - template: jinja
    - defaults:
      Salt_Master: {{ pillar['Salt_Master'] }}
    - require:
      - pkg: salt-minion
  service.running:
    - name: salt-minion
    - enable: True
    - watch:
      - file: salt-minion

