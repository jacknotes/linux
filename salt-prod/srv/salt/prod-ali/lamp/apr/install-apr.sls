include:
  - lnmp.pkg.make

apr-source-install:
  file.managed:
    - name: /usr/local/src/apr-1.6.5.tar.gz
    - source: salt://lamp/apr/files/apr-1.6.5.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && tar zxf apr-1.6.5.tar.gz && cd apr-1.6.5 && ./configure --prefix=/usr/local/apr && make && make install
    - unless: test -d /usr/local/apr
    - require:
      - file: apr-source-install
      - pkg: make-pkg

apr-util-source-install:
  file.managed:
    - name: /usr/local/src/apr-util-1.6.1.tar.gz
    - source: salt://lamp/apr/files/apr-util-1.6.1.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && tar zxf apr-util-1.6.1.tar.gz && cd apr-util-1.6.1 && ./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr && make && make install
    - unless: test -d /usr/local/apr-util
    - require:
      - file: apr-util-source-install
      - pkg: make-pkg

