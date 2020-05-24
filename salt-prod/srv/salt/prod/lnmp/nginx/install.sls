include:
  - lnmp.user.www
  - lnmp.pcre.install  #安装pcre，后面有程序会用到这个包

nginx-source-install:
  file.managed:
    - name: /usr/local/src/nginx-1.9.1.tar.gz
    - source: salt://lnmp/nginx/files/nginx-1.9.1.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && tar zxf nginx-1.9.1.tar.gz && cd nginx-1.9.1&& ./configure --prefix=/usr/local/nginx --user=www --group=www --sbin-path=/usr/local/nginx/sbin/nginx --conf-path=/usr/local/nginx/conf/nginx.conf --error-log-path=/var/log/nginx/error.log  --http-log-path=/var/log/nginx/access.log  --lock-path=/var/lock/nginx.lock --with-http_ssl_module --with-http_stub_status_module --with-http_gzip_static_module --http-client-body-temp-path=/var/tmp/nginx/client/ --http-proxy-temp-path=/var/tmp/nginx/proxy/ --http-fastcgi-temp-path=/var/tmp/nginx/fcgi/ --http-uwsgi-temp-path=/var/tmp/nginx/uwsgi --http-scgi-temp-path=/var/tmp/nginx/scgi --with-file-aio --with-http_dav_module --with-pcre=/usr/local/src/pcre-8.37 && make && make install && chown -R www:www /usr/local/nginx
    - unless: test -d /usr/local/nginx
    - require:
      - user: www-user-group
      - file: nginx-source-install
      - cmd: pcre-source-install 

