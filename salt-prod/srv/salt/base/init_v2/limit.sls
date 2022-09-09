limitInit:
  file.managed:
    - name: /etc/security/limits.d/98-homsom.conf
    - source: salt://init/files/limit-99-homsom.conf
    - user: root
    - group: root
    - mode: 644

