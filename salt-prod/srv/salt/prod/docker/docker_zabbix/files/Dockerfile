FROM zabbix/zabbix-web-nginx-mysql:centos-3.4.15 


RUN yum -y install kde-l10n-Chinese glibc-common && localedef -c -f UTF-8 -i zh_CN zh_CN.utf8
ENV LC_ALL zh_CN.utf8 
