/etc/yum.repos.d/kubernetes.repo:
  file.managed:
    - source: salt://init/files/kubernetes.repo
    - user: root
    - group: root
    - mode: 644

import-kubernetes-yum-key:
  cmd.run:
    - name: rpm --import https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg

