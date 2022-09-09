cadvisor-install:
  file.managed:
    - name: /usr/local/bin/cadvisor
    - source: salt://prometheus/files/cadvisor
    - user: root
    - group: root
    - mode: 755

cadvisor-service:
  file.managed:
    - name: /usr/lib/systemd/system/cadvisor.service
    - source: salt://prometheus/files/cadvisor.service
    - mode: 644
    - user: root
    - group: root
  service.running:
    - name: cadvisor.service
    - enable: True
    - require:
      - file: cadvisor-service
