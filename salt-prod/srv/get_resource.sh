#!/bin/sh

#get mysql general binlog files.
axel -o salt/prod/lnmp/mysql/files/ -n 30 https://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.48-linux-glibc2.12-x86_64.tar.gz
axel -o salt/prod/lamp/httpd/files -n 30 http://apache.mirrors.lucidnetworks.net/httpd/httpd-2.4.43.tar.bz2
axel -o salt/prod/tomcat/files -n 30 https://mirror.bit.edu.cn/apache/tomcat/tomcat-8/v8.5.55/bin/apache-tomcat-8.5.55.tar.gz
# axel -o salt/prod/tomcat/files your_java_address
