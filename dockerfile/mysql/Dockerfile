#This mysql Dcokerfile
#use software
#	1.mysql-5.6.43-linux-glibc2.12-x86_64.tar.gz
#
#usage:
######################################################################################################################################
#	BEGIN: 
#		1.docker run --name mysql --rm -p 3306:3306 -h mysql -e PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/mysql/bin -d jackidocker/centos_mysql:latest
#		2.docker exec -it mysql /bin/sh;mysql;grant all on *.* to root@'%' identified by 'root';
#		3.docker cp mysql:/data ./data
#		4.chown -R 1000:1000 ./data
#	END:
#		1.docker run --name mysql --rm -p 3306:3306 -h mysql -v /git/Linux/dockerfile/mysql/data:/data -e PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/mysql/bin -d jackidocker/centos_mysql:latest
#		2.mysql -uroot -p -h 127.0.0.1(on local host opretion)
######################################################################################################################################

#Base Images
FROM centos:centos7.6.1810

#Maintainer
MAINTAINER Jackli5689@gmail.com

#new and change dir
WORKDIR /root

#init env
RUN yum install -y perl perl-Data-Dumper libaio* libnuma* net-tools  epel-release

# source package
#ADD mysql-5.6.43-linux-glibc2.12-x86_64.tar.gz /root
RUN curl -o /root/mysql-5.6.43-linux-glibc2.12-x86_64.tar.gz https://cdn.mysql.com/archives/mysql-5.6/mysql-5.6.43-linux-glibc2.12-x86_64.tar.gz && tar xf mysql-5.6.43-linux-glibc2.12-x86_64.tar.gz


# add mysql and supervisor config file
ADD config_file/profile.d_mysql.sh /etc/profile.d/mysql.sh
ADD config_file/supervisord.conf /etc/supervisord.conf
ADD config_file/my.cnf /etc/my.cnf 		
ADD config_file/mysql.ini /etc/supervisord.d/mysql.ini
ADD config_file/entrypoint.sh /root/entrypoint.sh

# init mysql server
RUN	mv mysql-5.6.43-linux-glibc2.12-x86_64 /usr/local/ && ln -sv /usr/local/mysql-5.6.43-linux-glibc2.12-x86_64 /usr/local/mysql&&\
	groupadd -r -g 1000 mysql&&\
	useradd -r -s /sbin/nologin -M -g 1000 -u 1000 mysql&&\
	mkdir /data -p &&\
	chown -R mysql:mysql /data && chmod -R 775 /data &&\
	/usr/local/mysql/scripts/mysql_install_db --user=mysql --datadir=/data --basedir=/usr/local/mysql &&\
	cp /usr/local/mysql/support-files/mysql.server /etc/init.d/ 

# install supervisor
RUN yum install -y supervisor.noarch 
	
#clean 
RUN yum clean all && rm -rf /root/mysql-5.6.43-linux-glibc2.12-x86_64.tar.gz

#expose port
EXPOSE 3306

#start shell
ENTRYPOINT ["/bin/sh","-c","/root/entrypoint.sh"]




