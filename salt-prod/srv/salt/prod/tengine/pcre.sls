pcre-source-install:
  file.managed:
    - name: /usr/local/src/pcre-8.44.tar.gz
    - source: salt://tengine/files/pcre-8.44.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && tar zxf pcre-8.44.tar.gz 
    - unless: test -d /usr/local/src/pcre-8.44
    - require:
      - file: pcre-source-install
