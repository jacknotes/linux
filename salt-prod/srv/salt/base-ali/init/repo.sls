/etc/yum.repos.d/epel-7.repo:
  file.managed:
    - source: salt://init/files/epel-7.repo
    - user: root
    - group: root
    - mode: 644

/etc/yum.repos.d/Centos-7.repo:
  file.managed:
    - source: salt://init/files/Centos-7.repo
    - user: root
    - group: root
    - mode: 644

/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7:
  file.managed:
    - source: salt://init/files/RPM-GPG-KEY-EPEL-7
    - user: root
    - group: root
    - mode: 644
