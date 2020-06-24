include:
  - docker.docker_install.install
  - docker.docker_elk.elk_optimize

/data/docker/elk:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

/data/docker/elk/elasticsearch.yml:
  file.managed:
    - source: salt://docker/docker_elk/files/elasticsearch.yml
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: /data/docker/elk

/data/docker/elk/kibana.yml:
  file.managed:
    - source: salt://docker/docker_elk/files/kibana.yml
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: /data/docker/elk

/data/docker/elk/logstash_port.conf:
  file.managed:
    - source: salt://docker/docker_elk/files/logstash_port.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: /data/docker/elk

/data/docker/elk/docker-compose.yml:
  file.managed:
    - source: salt://docker/docker_elk/files/docker-compose.yml
    - template: jinja
    - defaults:
      ELK_NODENAME: {{ pillar['ELK_NODENAME'] }}
      ELK_NODEIP: {{ pillar['ELK_NODEIP'] }}
      ELK_CLUSTER_IPLIST: {{ pillar['ELK_CLUSTER_IPLIST'] }}
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: /data/docker/elk
      - file: /data/docker/elk/elasticsearch.yml
      - file: /data/docker/elk/kibana.yml
      - file: /data/docker/elk/logstash_port.conf

elk_service:
  cmd.run:
    - name: cd /data/docker/elk && docker-compose up -d 
    - unless: docker ps | grep logstash
    - require:
      - service: docker-ce
      - sysctl: vm.max_map_count
      - file: /etc/security/limits.conf
