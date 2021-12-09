include:
  - prometheus.user.prometheus

pushgateway-source-install:
  file.managed:
    - name: /usr/local/src/pushgateway-1.0.1.linux-amd64.tar.gz
    - source: salt://prometheus/files/pushgateway-1.0.1.linux-amd64.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && tar xf pushgateway-1.0.1.linux-amd64.tar.gz -C /usr/local/ && chown -R prometheus:prometheus /usr/local/pushgateway-1.0.1.linux-amd64 && ln -s /usr/local/pushgateway-1.0.1.linux-amd64 /usr/local/pushgateway
    - unless: test -x /usr/local/pushgateway/pushgateway
    - require:
      - file: pushgateway-source-install
      - user: prometheus-user-group

pushgateway-service:
  file.managed:
    - name: /usr/lib/systemd/system/pushgateway.service
    - source: salt://prometheus/files/pushgateway.service
    - mode: 644
    - user: root
    - group: root
  service.running:
    - name: pushgateway.service
    - enable: True
    - require:
      - file: pushgateway-service
      - cmd: pushgateway-source-install
