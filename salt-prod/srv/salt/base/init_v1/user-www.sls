base.www-user-group:
  group.present:
    - name: www
    - gid: 2000
  user.present:
    - name: www
    - fullname: www
    - shell: /sbin/bash
    - uid: 2000
    - gid: 2000
