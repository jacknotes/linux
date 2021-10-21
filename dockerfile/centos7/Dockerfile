# Dcokerfile: openssh-server,nginx-1.16.1,java-1.8.0_231

#Base Images
FROM centos:centos7.6.1810

#annotations
LABEL "BuildDatetime"="20200715"
LABEL "Author"="jack"
LABEL "Email"="jacknotes@163.com"
LABEL "ROOT_PASSWORD"="env,is root password"
LABEL "OpenSSH"="7.4p1"
LABEL "JAVA"="1.8.0_231"
LABEL "PCRE"="8.43"
LABEL "NGINX"="1.16.1"
LABEL "REDIS"="5.0.5"
LABEL "TCL"="8.6.10"

WORKDIR /download
RUN yum install -y gcc gcc-c++ glibc openssl-devel \
	make net-tools wget net-tools nmap-ncat \
	openssh-server lsof iproute telnet vim openssh-clients \
	kde-l10n-Chinese

# source package
ADD *.tar.gz /download/ 

# software links
RUN mv /download/pcre-8.43 /usr/local && \
	ln -sv /usr/local/pcre-8.43/ /usr/local/pcre
RUN mv /download/jdk1.8.0_231 /usr/local && \
	ln -sv /usr/local/jdk1.8.0_231/ /usr/local/jdk

# compile nginx 
RUN useradd -M -s /sbin/nologin nginx && \
	cd /download/nginx-1.16.1 && \
	./configure --user=nginx --group=nginx --prefix=/usr/local/nginx \
	--with-http_stub_status_module --with-http_ssl_module \
	--with-pcre=/usr/local/pcre --sbin-path=/usr/local/nginx/sbin/nginx \
	--conf-path=/usr/local/nginx/conf/nginx.conf --error-log-path=/var/log/nginx/error.log  \
	--http-log-path=/var/log/nginx/access.log  --pid-path=/var/run/nginx/nginx.pid \
	--lock-path=/var/lock/nginx.lock --with-http_gzip_static_module && \
	make && make install 

#compile redis
RUN cd /download/tcl8.6.10/unix/ && \
	./configure && make && make install 
RUN cd /download/redis-5.0.5 && \
	make && \
	make PREFIX=/usr/local/redis install && \
	cp /download/redis-5.0.5/redis.conf /usr/local/redis/ && \
	sed -i '/appendonly no/ s/no/yes/g' /usr/local/redis/redis.conf && \
	sed -i '/daemonize no/ s/no/yes/g' /usr/local/redis/redis.conf && \
	sed -i '/dir .\// s/.\//\/usr\/local\/redis\//g'  /usr/local/redis/redis.conf

#ssh user environment
ENV PATH "$PATH:/usr/local/nginx/sbin/:/usr/local/jdk/bin/:/usr/local/redis/bin/"
#openssh-server require file
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key -q -N ''	&& \
	ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -q -N '' && \
	ssh-keygen -t dsa -f /etc/ssh/ssh_host_ecdsa_key -q -N ''

#set chinese language
RUN localedef -c -f UTF-8 -i zh_CN zh_CN.utf8 && \
	export LANG=zh_CN.UTF-8 && \
	export LC_ALL=zh_CN.utf8 && \
	echo "LANG=zh_CN.UTF-8" > /etc/locale.conf && \
	echo 'export LANG=zh_CN.UTF-8' >> /etc/profile && \
	echo 'export LC_ALL=zh_CN.utf8' >> /etc/profile && \
	echo 'export PATH=$PATH:/usr/local/nginx/sbin/:/usr/local/jdk/bin/:/usr/local/redis/bin/' >> /etc/profile

#add entrypoint.sh
RUN yum clean all && \
	rm -rf /download/*

EXPOSE 22
ADD entrypoint.sh /root
CMD ["/bin/sh","-c","/root/entrypoint.sh"]

