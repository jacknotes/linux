pcre-source-install:
  file.managed:
    - name: /usr/local/src/pcre-8.44.tar.gz
    - source: salt://tengine/module/files/pcre-8.44.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && tar zxf pcre-8.44.tar.gz -C /usr/local && ln -s /usr/local/pcre-8.44 /usr/local/pcre
    - unless: test -l /usr/local/pcre
    - require:
      - file: pcre-source-install

ngx_http_substitutions_filter_module-install:
  file.managed:
    - name: /usr/local/src/ngx_http_substitutions_filter_module-master.zip
    - source: salt://tengine/module/files/ngx_http_substitutions_filter_module-master.zip
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && unzip ngx_http_substitutions_filter_module-master.zip 
    - unless: test -d /usr/local/src/ngx_http_substitutions_filter_module-master
    - require:
      - file: ngx_http_substitutions_filter_module-install
