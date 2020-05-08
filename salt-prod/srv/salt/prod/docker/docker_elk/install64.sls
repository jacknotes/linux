include:
  - docker.docker_install.install
  - docker.docker_elk.elk_optimize

/data/docker/elk:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

/data/docker/elk/docker-compose.yml:
  file.managed:
    - source: salt://docker/docker_elk/files/docker-compose.yml.6.4
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: /data/docker/elk

elk_service:
  cmd.run:
    - name: cd /data/docker/elk && docker-compose up -d 
    - unless: docker ps | grep logstash
    - require:
      - service: docker-ce
      - sysctl: vm.max_map_count
      - file: /etc/security/limits.conf
