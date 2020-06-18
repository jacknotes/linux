include:
  - lnmp.user.mysql
  - lnmp.pkg.make

remove-mariadb:
   pkg.removed:
    - pkgs:
      - mariadb

data-mysql:
  file.directory:
    - name: /data/mysql
    - user: mysql
    - group: mysql
    - mode: 755
    - makedirs: True

mysql-source-install:
  file.managed:
    - name: /usr/local/src/mysql-5.6.48-linux-glibc2.12-x86_64.tar.gz
    - source: salt://lnmp/mysql/files/mysql-5.6.48-linux-glibc2.12-x86_64.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && tar zxf mysql-5.6.48-linux-glibc2.12-x86_64.tar.gz -C /usr/local && chmod -R 775 /usr/local/mysql-5.6.48-linux-glibc2.12-x86_64 && chown -R root:mysql /usr/local/mysql-5.6.48-linux-glibc2.12-x86_64 && chown -R mysql:mysql /data/mysql && cd /usr/local/mysql-5.6.48-linux-glibc2.12-x86_64 && ./scripts/mysql_install_db --user=mysql --datadir=/data/mysql && ln -sv /usr/local/mysql-5.6.48-linux-glibc2.12-x86_64 /usr/local/mysql && echo /usr/local/mysql/lib/ >> /etc/ld.so.conf.d/mysqld.conf && ldconfig && ln -sv /usr/local/mysql/include /usr/include/mysql && echo PATH=$PATH:/usr/local/mysql/bin/ > /etc/profile.d/mysqld.sh 
    - unless: test -f /etc/profile.d/mysqld.sh
    - require:
      - user: mysql-user-group
      - pkg: make-pkg
      - file: data-mysql
      - file: mysql-source-install

config-mysql:
  file.managed:
    - name: /etc/my.cnf
    - source: salt://lnmp/mysql/files/my.cnf
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: mysql-source-install

init-mysql:
  file.managed:
    - name: /etc/init.d/mysqld
    - source: salt://lnmp/mysql/files/mysqld
    - user: root
    - group: mysql
    - mode: 775
    - require:
      - cmd: mysql-source-install
  cmd.run:
    - name: /usr/sbin/chkconfig --add mysqld
    - unless: chkconfig --list | grep mysqld
    - require:
      - file: init-mysql

serveice-mysql:
  service.running:
    - name: mysqld
    - enable: True
    - require:
      - cmd: init-mysql
    - watch:
      - file: config-mysql
