#This nginx Dcokerfile

#Base Images
FROM centos:centos7.6.1810

#Maintainer
MAINTAINER Jackli5689@gmail.com

#new and change dir
WORKDIR /download 

#init env
RUN yum install -y gcc gcc-c++ glibc openssl-devel  make net-tools wget 

# source package
ADD pcre-8.43.tar.gz /download 
# wget https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz
# tar xf pcre-8.43.tar.gz
ADD nginx-1.16.1.tar.gz /download 
# wget http://nginx.org/download/nginx-1.16.1.tar.gz
# tar xf nginx-1.16.1.tar.gz

# pcre config
RUN mv /download/pcre-8.43 /usr/local && ln -sv /usr/local/pcre-8.43/ /usr/local/pcre

# add user
RUN useradd -M -s /sbin/nologin nginx && cd /download

# compile nginx 
RUN cd /download/nginx-1.16.1 && ./configure --user=nginx --group=nginx --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-pcre=/usr/local/pcre && make && make install 

#add nginx env path
ADD nginx.sh /etc/profile.d/nginx.sh 
RUN chmod +x /etc/profile.d/nginx.sh && source /etc/profile.d/nginx.sh 

#add entrypoint.sh
ADD entrypoint.sh /root
RUN chmod +x /root/entrypoint.sh


#clean 
RUN yum clean all && rm -rf /download/*


#expose port
EXPOSE 80

#Dockerfile volume not mount host and image 
#VOLUME ["/root/nginx/nginx_mount/conf/","/usr/local/nginx/conf/"]
#VOLUME ["/root/nginx/nginx_mount/html/","/usr/local/nginx/html/"]
#VOLUME ["/root/nginx/nginx_mount/logs/","/usr/local/nginx/logs/"]


CMD ["/bin/sh","-c","/root/entrypoint.sh"]



