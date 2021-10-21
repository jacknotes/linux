include:
  - init.salt-repo  

salt-minion:
  cmd.run:
    - name: sudo wget -qO /usr/share/keyrings/salt-archive-keyring.gpg https://repo.saltproject.io/py3/ubuntu/18.04/amd64/3003/salt-archive-keyring.gpg && sudo apt update
    - unless: test -f /usr/share/keyrings/salt-archive-keyring.gpg
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

