# Dcokerfile: openssh-server,nginx-1.16.1,java-1.8.0_231

#Base Images
FROM centos:centos7.6.1810

#annotations
LABEL "Author"="jack"
LABEL "Email"="jacknotes@163.com"
LABEL "ROOT_PASSWORD"="env,root password"
LABEL "OpenSSH"="7.4p1"
LABEL "NGINX"="1.16.1"
LABEL "JAVA"="1.8.0_231"

WORKDIR /download 
RUN yum install -y gcc gcc-c++ glibc openssl-devel  make net-tools wget net-tools nmap-ncat openssh-server 

# source package
ADD pcre-8.43.tar.gz /download 
ADD nginx-1.16.1.tar.gz /download 
ADD jdk-8u231-linux-x64.tar.gz /download 

# pcre config
RUN mv /download/pcre-8.43 /usr/local && ln -sv /usr/local/pcre-8.43/ /usr/local/pcre
RUN mv /download/jdk1.8.0_231 /usr/local && ln -sv /usr/local/jdk1.8.0_231/ /usr/local/jdk

# compile nginx 
RUN useradd -M -s /sbin/nologin nginx &&  cd /download/nginx-1.16.1 && ./configure --user=nginx --group=nginx --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-pcre=/usr/local/pcre --sbin-path=/usr/local/nginx/sbin/nginx --conf-path=/usr/local/nginx/conf/nginx.conf --error-log-path=/var/log/nginx/error.log  --http-log-path=/var/log/nginx/access.log  --pid-path=/var/run/nginx/nginx.pid --lock-path=/var/lock/nginx.lock --with-http_gzip_static_module  && make && make install 

#ssh user environment
ENV PATH "$PATH:/usr/local/nginx/sbin/:/usr/local/jdk/bin/"
#openssh-server require file
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key -q -N ''
RUN ssh-keygen -t rsa -f  /etc/ssh/ssh_host_rsa_key -q -N ''
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_ecdsa_key -q -N ''

#add entrypoint.sh
ADD entrypoint.sh /root
RUN yum clean all && rm -rf /download/*
EXPOSE 22

CMD ["/bin/sh","-c","/root/entrypoint.sh"]

