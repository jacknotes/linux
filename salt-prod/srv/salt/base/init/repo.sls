/etc/yum.repos.d/epel.repo:
  file.managed:
    - source: salt://init/files/epel.repo
    - user: root
    - group: root
    - mode: 644
/etc/yum.repos.d/Centos-7.repo:
  file.managed:
    - source: salt://init/files/Centos-7.repo
    - user: root
    - group: root
    - mode: 644
/etc/yum.repos.d/salt-py3-CentOS7.repo:
  file.managed:
    - source: salt://init/files/salt-py3-CentOS7.repo
    - user: root
    - group: root
    - mode: 644

/etc/yum.repos.d/zabbix.repo:
  file.managed:
    - source: salt://init/files/zabbix.repo
    - user: root
    - group: root
    - mode: 644
