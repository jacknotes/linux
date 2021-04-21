include:
  - docker.docker_install.install
  - docker.docker_elk761.elk_optimize

/data/elk:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

/data/elk/elasticsearch.yml:
  file.managed:
    - source: salt://docker/docker_elk761/files/elasticsearch.yml
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: /data/elk

/data/elk/kibana.yml:
  file.managed:
    - source: salt://docker/docker_elk761/files/kibana.yml
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: /data/elk

/data/elk/elk.sh:
  file.managed:
    - source: salt://docker/docker_elk761/files/elk.sh
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: /data/elk
      - file: /data/elk/elasticsearch.yml
      - file: /data/elk/kibana.yml

elk_service:
  cmd.run:
    - name: cd /data/elk && /bin/sh /data/elk/elk.sh
    - unless: docker ps | grep elasticsearch
    - require:
      - service: docker-ce
      - sysctl: vm.max_map_count
      - file: /etc/security/limits.conf
