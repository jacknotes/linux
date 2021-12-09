include:
  - prometheus.user.prometheus

elasticsearch_exporter-source-install:
  file.managed:
    - name: /usr/local/src/elasticsearch_exporter-1.1.0.linux-amd64.tar.gz
    - source: salt://prometheus/files/elasticsearch_exporter-1.1.0.linux-amd64.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && tar xf elasticsearch_exporter-1.1.0.linux-amd64.tar.gz -C /usr/local/ && chown -R prometheus:prometheus /usr/local/elasticsearch_exporter-1.1.0.linux-amd64 && ln -s /usr/local/elasticsearch_exporter-1.1.0.linux-amd64 /usr/local/elasticsearch_exporter
    - unless: test -x /usr/local/elasticsearch_exporter/elasticsearch_exporter
    - require:
      - file: elasticsearch_exporter-source-install
      - user: prometheus-user-group

elasticsearch_exporter-service:
  file.managed:
    - name: /usr/lib/systemd/system/elasticsearch_exporter.service
    - source: salt://prometheus/files/elasticsearch_exporter.service
    - mode: 755
    - user: root
    - group: root
  service.running:
    - name: elasticsearch_exporter.service
    - enable: True
    - require:
      - file: elasticsearch_exporter-service
