tty-timeout:
  file.append:
    - name: /etc/profile
    - text:
      - export TMOUT=3600
