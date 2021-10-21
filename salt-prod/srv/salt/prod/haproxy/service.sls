include:
  - haproxy.install

rsyslog-service:
  file.managed:
    - name: /etc/rsyslog.conf
    - source: salt://haproxy/files/rsyslog.conf
    - user: root
    - group: root
    - mode: 644
  service.running:
    - name: rsyslog
    - enable: True
    - require:
      - file: rsyslog-service
    - watch:
      - file: rsyslog-service

haproxy-service:
  file.managed:
    - name: /etc/haproxy/haproxy.cfg
    - source: salt://haproxy/files/haproxy.cfg.template
    - user: root
    - group: root
    - mode: 644
  service.running:
    - name: haproxy
    - enable: True
    - reload: True
    - require:
      - cmd: haproxy-install
    - watch:
      - file: haproxy-service
