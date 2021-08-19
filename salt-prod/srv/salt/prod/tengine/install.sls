include:
  - tengine.user
  - tengine.pcre

nginx-source-install:
  file.managed:
    - name: /usr/local/src/tengine-2.3.2.tar.gz
    - source: salt://tengine/files/tengine-2.3.2.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && tar zxf tengine-2.3.2.tar.gz && cd tengine-2.3.2 && ./configure --prefix=/usr/local/nginx  --user=www --group=www --with-pcre=/usr/local/src/pcre-8.44 --with-http_ssl_module --with-http_flv_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_sub_module --with-stream --with-stream_ssl_module  --with-http_auth_request_module --with-http_gzip_static_module --with-http_random_index_module --with-http_sub_module --add-module=modules/ngx_http_upstream_session_sticky_module --add-module=modules/ngx_http_upstream_check_module && make && make install && chown -R www:www /usr/local/nginx
    - unless: test -d /usr/local/nginx
    - require:
      - user: www-user-group
      - file: nginx-source-install
      - cmd: pcre-source-install 
