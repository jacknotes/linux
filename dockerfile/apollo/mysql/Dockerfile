FROM mysql:5.7
MAINTAINER Jack
 
#设置免密登录
ENV MYSQL_ALLOW_EMPTY_PASSWORD yes
 
#将所需文件放到容器中
COPY setup.sh /mysql/setup.sh
COPY apolloconfigdb.sql /mysql/apolloconfigdb.sql
COPY apolloportaldb.sql /mysql/apolloportaldb.sql
COPY user.sql /mysql/user.sql
  
#设置容器启动时执行的命令
CMD ["sh", "/mysql/setup.sh"]
