base:
  'node*':
    - init.init
prod:
  'node1':
    - prometheus.prometheus
    - prometheus.node_exporter
    - prometheus.grafana
    - prometheus.pushgateway
  'node2':
    - prometheus.node_exporter
