axel-install:
  file.managed:
    - name: /usr/local/src/axel-2.17.8.tar.gz
    - source: salt://init/files/axel-2.17.8.tar.gz
  cmd.run:
    - name: cd /usr/local/src && tar xf axel-2.17.8.tar.gz && cd axel-2.17.8 && ./configure --prefix=/usr/local/axel && make && make install && echo "export PATH=$PATH:/usr/local/axel/bin" >> /etc/profile
    - unless: test -d /usr/local/axel
    - require:
      - file: axel-install

