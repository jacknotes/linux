network-dns-config:
  file.managed:
    - name: /etc/sysconfig/network-scripts/ifcfg-eth0
    - source: salt://init/files/ifcfg-eth0
    - user: root
    - group: root
    - mode: 644
  service.running:
    - name: network
    - enable: True
    - reload: True
    - wathch:
      - file: network-dns-config

