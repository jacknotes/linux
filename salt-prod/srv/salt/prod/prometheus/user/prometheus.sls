prometheus-user-group:
  group.present:
    - name: prometheus
    - gid: 9090
  user.present:
    - name: prometheus
    - fullname: prometheus
    - shell: /sbin/nologin
    - uid: 9090	
    - gid: 9090
