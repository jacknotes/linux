/etc/yum.repos.d/docker-ce.repo:
  file.managed:
    - source: salt://docker/docker_install/files/docker-ce.repo
    - user: root
    - group: root
    - mode: 644
 
docker-ce:
  cmd.run:
    - name: yum install -y yum-utils device-mapper-persistent-data lvm2 container-selinux
    - unless: rpm -qa | grep lvm2 >& /dev/null
  pkg.installed:
    - names: 
      - docker-ce
    - require:
      - file: /etc/yum.repos.d/docker-ce.repo
      - cmd: docker-ce
  service.running:
    - name: docker
    - enable: True
    - require:
      - pkg: docker-ce

/etc/docker:
  file.directory:
    - name: /etc/docker

/etc/docker/daemon.json:
  file.managed:
    - source: salt://docker/docker_install/files/daemon.json
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: /etc/docker
    - watch_in:
      - service: docker-ce

/usr/local/bin/docker-compose:
  file.managed:
    - name: /usr/local/bin/docker-compose
    - source: salt://docker/docker_install/files/docker-compose
    - user: root
    - group: root
    - mode: 755
