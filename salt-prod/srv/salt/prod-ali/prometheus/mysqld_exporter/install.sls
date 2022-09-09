include:
  - prometheus.user.prometheus

mysqld_exporter-source-install:
  file.managed:
    - name: /usr/local/src/mysqld_exporter-0.12.1.linux-amd64.tar.gz
    - source: salt://prometheus/mysqld_exporter/files/mysqld_exporter-0.12.1.linux-amd64.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && tar xf mysqld_exporter-0.12.1.linux-amd64.tar.gz -C /usr/local/ && chown -R prometheus:prometheus /usr/local/mysqld_exporter-0.12.1.linux-amd64 && ln -s /usr/local/mysqld_exporter-0.12.1.linux-amd64 /usr/local/mysqld_exporter
    - unless: test -x /usr/local/mysqld_exporter/mysqld_exporter
    - require:
      - file: mysqld_exporter-source-install
      - user: prometheus-user-group

mysqld_exporter-mysql_user_info:
  file.managed:
    - name: /usr/local/mysqld_exporter/.aliyun_rds_mysql.cnf
    - source: salt://prometheus/mysqld_exporter/files/aliyun_rds_mysql.cnf
    - mode: 644
    - user: root
    - group: root
    - require:
      - cmd: mysqld_exporter-source-install

mysqld_exporter-service:
  file.managed:
    - name: /usr/lib/systemd/system/mysqld_exporter.service
    - source: salt://prometheus/mysqld_exporter/files/mysqld_exporter.service
    - mode: 644
    - user: root
    - group: root
  service.running:
    - name: mysqld_exporter.service
    - enable: True
    - require:
      - file: mysqld_exporter-service
