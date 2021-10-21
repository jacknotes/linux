jdk-install:
  file.managed:
    - name: /usr/local/src/jdk-8u201-linux-x64.tar.gz
    - source: salt://tomcat/files/jdk-8u201-linux-x64.tar.gz
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - name: cd /usr/local/src && tar xf jdk-8u201-linux-x64.tar.gz && mv jdk1.8.0_201 /usr/local/jdk && echo -e 'export JAVA_HOME=/usr/local/jdk\nexport PATH=$PATH:$JAVA_HOME/bin' > /etc/profile.d/java.sh && source /etc/profile.d/java.sh
    - unless: test -f /etc/profile.d/java.sh
    - require:
      - file: jdk-install

