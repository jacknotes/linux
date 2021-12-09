include:
  - lnmp.user.www
  - lnmp.pcre.install  #安装pcre，后面有程序会用到这个包

nginx-source-install:
  file.managed:
    - name: /usr/local/src/nginx-1.20.2.tar.gz
    - source: salt://lnmp/nginx/files/nginx-1.20.2.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && tar zxf nginx-1.20.2.tar.gz && cd nginx-1.20.2&& ./configure --prefix=/usr/local/nginx --user=www --group=www --with-http_ssl_module --with-http_stub_status_module --with-http_gzip_static_module --with-file-aio --with-http_dav_module --with-http_sub_module --with-http_realip_module --add-module=/git/ngx_http_substitutions_filter_module --with-stream --with-pcre=/usr/local/src/pcre-8.37 && make && make install && chown -R www:www /usr/local/nginx
    - unless: test -d /usr/local/nginx
    - require:
      - user: www-user-group
      - file: nginx-source-install
      - cmd: pcre-source-install 

