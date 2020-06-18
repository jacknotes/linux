#!/bin/sh

#get mysql general binlog files.
axel -o salt/prod/lnmp/mysql/files/ -n 30 https://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.48-linux-glibc2.12-x86_64.tar.gz
axel -o salt/prod/lamp/httpd/files -n 30 http://apache.mirrors.lucidnetworks.net/httpd/httpd-2.4.43.tar.bz2
axel -o salt/prod/tomcat/files -n 30 https://mirror.bit.edu.cn/apache/tomcat/tomcat-8/v8.5.55/bin/apache-tomcat-8.5.55.tar.gz
# axel -o salt/prod/tomcat/files your_java_address
axel -o salt/prod/prometheus/files -n 30 https://github.com/prometheus/prometheus/releases/download/v2.17.2/prometheus-2.17.2.linux-amd64.tar.gz
axel -o salt/prod/prometheus/files -n 30 https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz
axel -o salt/prod/prometheus/files -n 30 https://dl.grafana.com/oss/release/grafana-7.0.3-1.x86_64.rpm
axel -o salt/prod/prometheus/files -n 30 https://github.com/prometheus/pushgateway/releases/download/v1.0.1/pushgateway-1.0.1.linux-amd64.tar.gz
