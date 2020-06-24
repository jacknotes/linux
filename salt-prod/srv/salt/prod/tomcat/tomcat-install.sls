include:
  - tomcat.jdk-install

tomcat-install:
  file.managed:
    - name: /usr/local/src/apache-tomcat-8.5.55.tar.gz
    - source: salt://tomcat/files/apache-tomcat-8.5.55.tar.gz
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - name: cd /usr/local/src && tar xf apache-tomcat-8.5.55.tar.gz && mv apache-tomcat-8.5.55 /usr/local/tomcat && echo -e 'export CATALINA_HOME=/usr/local/tomcat\nexport PATH=$PATH:$CATALINA_HOME/bin' > /etc/profile.d/tomcat.sh && source /etc/profile.d/tomcat.sh
    - unless: test -f /etc/profile.d/tomcat.sh
    - require:
      - cmd: jdk-install
      - file: tomcat-install

tomcat-webroot:
  file.directory:
    - name: /webroot
    - user: www
    - group: www
    - mode: 775

tomcat-webroot/ROOT:
  file.directory:
    - name: /webroot/ROOT
    - user: www
    - group: www
    - mode: 775
    - require:
      - file: tomcat-webroot

tomcat-index:
  file.managed:
    - name: /webroot/ROOT/index.jsp
    - source: salt://tomcat/files/index.jsp
    - user: www
    - group: www
    - mode: 775
    - require:
      - file: tomcat-webroot/ROOT

tomcat-conf:
  file.managed:
    - name: //usr/local/tomcat/conf/server.xml
    - source: salt://tomcat/files/server.xml
    - user: www
    - group: www
    - mode: 775
    - require:
      - cmd: tomcat-install

tomcat-init:
  file.managed:
    - name: /etc/init.d/tomcat
    - source: salt://tomcat/files/tomcat
    - mode: 755
    - user: root
    - group: root
  cmd.run:
    - name: chkconfig --add tomcat
    - unless: chkconfig --list | grep tomcat
    - require:
      - file: tomcat-init

tomcat-service:
  service.running:
    - name: tomcat
    - enable: True
    - require:
      - cmd: tomcat-init
    - watch:
      - file: tomcat-conf

