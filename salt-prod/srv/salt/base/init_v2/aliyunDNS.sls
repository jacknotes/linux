setBootAutoAdd_aliyunDNS:
  file.managed:
    - name: /etc/rc.d/rc.local
    - source: salt://init/files/aliyunDNS_rc.local
    - user: root
    - group: root
    - mode: 755

set_aliyunDNS:
  file.managed:
    - name: /etc/resolv.conf
    - source: salt://init/files/aliyunDNS_resolv.conf
    - user: root
    - group: root
    - mode: 644

