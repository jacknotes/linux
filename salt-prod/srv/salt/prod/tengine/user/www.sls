www-user-group:
  group.present:
    - name: tengine
    - gid: 8080

  user.present:
    - name: tengine
    - fullname: tengine
    - shell: /sbin/nologin
    - uid: 8080
    - gid: 8080
