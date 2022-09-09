include:
  - prometheus.user.prometheus

node_exporter-source-install:
  file.managed:
    - name: /usr/local/src/node_exporter-1.0.1.linux-amd64.tar.gz
    - source: salt://prometheus/files/node_exporter-1.0.1.linux-amd64.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && tar xf node_exporter-1.0.1.linux-amd64.tar.gz -C /usr/local/ && chown -R prometheus:prometheus /usr/local/node_exporter-1.0.1.linux-amd64/ && ln -s /usr/local/node_exporter-1.0.1.linux-amd64/ /usr/local/node_exporter
    - unless: test -x /usr/local/node_exporter/node_exporter
    - require:
      - file: node_exporter-source-install
      - user: prometheus-user-group

node_exporter-service:
  file.managed:
    - name: /usr/lib/systemd/system/node_exporter.service
    - source: salt://prometheus/files/node_exporter.service
    - mode: 644
    - user: root
    - group: root
  service.running:
    - name: node_exporter.service
    - enable: True
    - require:
      - file: node_exporter-service
