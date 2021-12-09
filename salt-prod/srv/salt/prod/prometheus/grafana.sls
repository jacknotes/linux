grafana-source-install:
  file.managed:
    - name: /usr/local/src/grafana-7.0.3-1.x86_64.rpm
    - source: salt://prometheus/files/grafana-7.0.3-1.x86_64.rpm
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && yum localinstall -y /usr/local/src/grafana-7.0.3-1.x86_64.rpm  
    - unless: test -f /usr/lib/systemd/system/grafana-server.service
    - require:
      - file: grafana-source-install

grafana-service:
  service.running:
    - name: grafana-server.service
    - enable: True
    - require:
      - cmd: grafana-source-install
