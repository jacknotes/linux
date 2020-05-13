#!/bin/sh

#get mysql general binlog files.
axel -o prod/lnmp/mysql/files/ -n 30 https://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.48-linux-glibc2.12-x86_64.tar.gz
