mysql-user-group:
  group.present:
    - name: mysql
    - gid: 3306

  user.present:
    - name: mysql
    - fullname: mysql 
    - shell: /sbin/nologin
    - uid: 3306
    - gid: 3306
