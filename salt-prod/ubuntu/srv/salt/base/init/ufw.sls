firewalld-stop:
  service.dead:
    - name: ufw.service
    - enable: False
