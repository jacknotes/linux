include:
  - lnmp.pkg.make

haproxy-install:
  file.managed:
    - name: /usr/local/src/haproxy-1.9.0.tar.gz
    - source: salt://haproxy/files/haproxy-1.9.0.tar.gz
    - mode: 755
    - user: root
    - group: root
  cmd.run:
    - name: cd /usr/local/src && tar -zxf haproxy-1.9.0.tar.gz && cd haproxy-1.9.0 && make TARGET=linux2628 PREFIX=/usr/local/haproxy-1.9.0 && make install PREFIX=/usr/local/haproxy
    - unless: test -d /usr/local/haproxy
    - require:
      - pkg: make-pkg
      - file: haproxy-install

haproxy-init:
  file.managed:
    - name: /etc/init.d/haproxy
    - source: salt://haproxy/files/haproxy-init
    - mode: 755
    - user: root
    - group: root
    - require_in:
      - file: haproxy-install
  cmd.run:
    - name: chkconfig --add haproxy
    - unless: chkconfig --list | grep haproxy

net.ipv4.ip_nonlocal_bind:
  sysctl.present:
    - value: 1
/etc/haproxy:
  file.directory:
    - user: root
    - group: root
    - mode: 755
