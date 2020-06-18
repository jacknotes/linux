axel-install:
  file.managed:
    - name: /usr/local/src/axel-2.17.8.tar.gz
    - source: salt://init/files/axel-2.17.8.tar.gz
  cmd.run:
    - name: cd /usr/local/src && tar xf axel-2.17.8.tar.gz && cd axel-2.17.8 && ./configure --prefix=/usr/local/axel && make && make install && echo 'export PATH=$PATH:/usr/local/axel/bin' >> /etc/profile.d/axel.sh 
    - unless: test -f /etc/profile.d/axel.sh
    - require:
      - file: axel-install

