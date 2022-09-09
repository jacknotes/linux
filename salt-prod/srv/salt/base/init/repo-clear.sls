repo-clear:
  cmd.run:
    - name: rm -rf /etc/yum.repos.d/*
    - unless: [ $(ls -a /etc/yum.repos.d/ | wc -l) -eq 2 ]
