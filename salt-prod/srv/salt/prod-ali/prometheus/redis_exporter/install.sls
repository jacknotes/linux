include:
  - prometheus.user.prometheus

redis_exporter-source-install:
  file.managed:
    - name: /usr/local/src/redis_exporter-v1.11.1.linux-amd64.tar.gz
    - source: salt://prometheus/redis_exporter/files/redis_exporter-v1.11.1.linux-amd64.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && tar xf redis_exporter-v1.11.1.linux-amd64.tar.gz -C /usr/local/ && chown -R prometheus:prometheus /usr/local/redis_exporter-v1.11.1.linux-amd64 && ln -s /usr/local/redis_exporter-v1.11.1.linux-amd64 /usr/local/redis_exporter
    - unless: test -x /usr/local/redis_exporter/redis_exporter
    - require:
      - file: redis_exporter-source-install
      - user: prometheus-user-group

redis_exporter-service:
  file.managed:
    - name: /usr/lib/systemd/system/redis_exporter.service
    - source: salt://prometheus/redis_exporter/files/redis_exporter.service
    - mode: 644
    - user: root
    - group: root
  service.running:
    - name: redis_exporter.service
    - enable: True
    - require:
      - file: redis_exporter-service
