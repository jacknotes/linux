include:
  - docker.docker_install.install

zabbix-docker-compose-file:
  file.managed:
    - name: /usr/local/src/docker-compose.yml
    - source: salt://docker/docker_zabbix/docker-compose.yml
    - user: root
    - group: root
    - mode: 644

zabbix-service:
  cmd.run:
    - name: cd /usr/local/src && docker-compose up -d
    - unless: docker ps | grep nginx
    - require: 
      - file: zabbix-docker-compose-file
      - file: /usr/local/bin/docker-compose
