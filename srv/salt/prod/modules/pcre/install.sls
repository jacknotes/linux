pcre-source-install:
  file.managed:
    - name: /usr/local/src/pcre-8.37.tar.gz
    - source: salt://modules/pcre/files/pcre-8.37.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && tar zxf pcre-8.37.tar.gz && cd pcre-8.37 && ./configure --prefix=/usr/local/pcre && make && make install
    - unless: test -d /usr/local/pcre
    - require:
      - file: pcre-source-install
