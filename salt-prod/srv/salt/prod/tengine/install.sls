include:
  - tengine.user.www
  - tengine.module.install 

nginx-source-install:
  file.managed:
    - name: /usr/local/src/tengine-2.3.2.tar.gz
    - source: salt://tengine/files/tengine-2.3.2.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && tar zxf tengine-2.3.2.tar.gz && cd tengine-2.3.2 && ./configure --prefix=/usr/local/nginx --sbin-path=/usr/local/nginx/sbin/nginx --conf-path=/usr/local/nginx/conf/nginx.conf --error-log-path=/usr/local/nginx/logs/error.log --http-log-path=/usr/local/nginx/logs/access.log --user=tengine --group=tengine --with-pcre=/usr/local/pcre --with-http_ssl_module --with-http_flv_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_sub_module --with-stream --add-module=modules/ngx_http_upstream_session_sticky_module --add-module=/usr/local/src/ngx_http_substitutions_filter_module-master --with-stream_ssl_module --add-module=modules/ngx_http_upstream_check_module --with-http_auth_request_module --with-http_gzip_static_module --with-http_random_index_module --with-http_sub_module && make && make install && chown -R tengine:tengine /usr/local/nginx
    - unless: test -d /usr/local/nginx
    - require:
      - user: www-user-group
      - cmd: pcre-source-install 
      - cmd: ngx_http_substitutions_filter_module-install
      - file: nginx-source-install

