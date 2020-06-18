include:
  - docker.docker_install.install

/data/docker/zabbix:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

zabbix-docker-compose-file:
  file.managed:
    - name: /data/docker/zabbix/docker-compose.yml
    - source: salt://docker/docker_zabbix/files/docker-compose.yml
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: /data/docker/zabbix

zabbix-daemon.json:
  file.managed:
    - name: /etc/docker/daemon.json
    - source: salt://docker/docker_zabbix/files/daemon.json
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: /data/docker/zabbix

zabbix-nginx-file:
  file.managed:
    - name: /data/docker/zabbix/graphfont.ttf
    - source: salt://docker/docker_zabbix/files/graphfont.ttf
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: /data/docker/zabbix

zabbix-service:
  cmd.run:
    - name: cd /data/docker/zabbix && docker-compose --compatibility up -d
    - unless: docker ps | grep nginx
    - require: 
      - file: zabbix-docker-compose-file
      - file: /usr/local/bin/docker-compose
