include:
  - prometheus.user.prometheus

prometheus-source-install:
  file.managed:
    - name: /usr/local/src/prometheus-2.17.2.linux-amd64.tar.gz
    - source: salt://prometheus/files/prometheus-2.17.2.linux-amd64.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && tar xf prometheus-2.17.2.linux-amd64.tar.gz -C /usr/local/ && chown -R prometheus:prometheus /usr/local/prometheus-2.17.2.linux-amd64/ && ln -s /usr/local/prometheus-2.17.2.linux-amd64 /usr/local/prometheus  
    - unless: test -x /usr/local/prometheus/prometheus
    - require:
      - file: prometheus-source-install
      - user: prometheus-user-group

data-prometheus:
  file.directory:
    - name: /var/lib/prometheus
    - user: prometheus
    - group: prometheus
    - mode: 755
    - makedirs: True

prometheus-conf:
  file.managed:
    - name: /usr/local/prometheus/prometheus.yml
    - source: salt://prometheus/files/prometheus.yml
    - template: jinja
    - defaults:
      PROMETHEUS_SERVER: {{ pillar['PROMETHEUS_SERVER'] }}
      PROMETHEUS_PUSHGATEWAY: {{ pillar['PROMETHEUS_PUSHGATEWAY'] }}
      PROMETHEUS_NODE1: {{ pillar['PROMETHEUS_NODE1'] }}
      PROMETHEUS_NODE2: {{ pillar['PROMETHEUS_NODE2'] }}
    - require:
      - cmd: prometheus-source-install

prometheus-service:
  file.managed:
    - name: /usr/lib/systemd/system/prometheus.service
    - source: salt://prometheus/files/prometheus.service
    - mode: 644
    - user: root
    - group: root
    - require:
      - file: prometheus-conf
      - file: data-prometheus
  service.running:
    - name: prometheus.service
    - enable: True
    - require:
      - file: prometheus-service
    - watch:
      - file: prometheus-conf
