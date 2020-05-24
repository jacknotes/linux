#!/bin/sh

#get mysql general binlog files.
axel -o salt/prod/lnmp/mysql/files/ -n 30 https://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.48-linux-glibc2.12-x86_64.tar.gz
axel -o salt/prod/lamp/httpd/files -n 30 http://apache.mirrors.lucidnetworks.net/httpd/httpd-2.4.43.tar.bz2
