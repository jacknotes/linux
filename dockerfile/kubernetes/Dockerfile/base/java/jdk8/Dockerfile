#FROM harborrepo.hs.com/base/java/ops_java:8
FROM java:8

LABEL "Custom_CA"="True"
LABEL "Author"="JackLi"


ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV FILEDIR="file" SKYWALKING_DIR="/jar"
ADD $FILEDIR/*.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

WORKDIR /
RUN mkdir -p $SKYWALKING_DIR
ADD $FILEDIR/agent.tar.gz $SKYWALKING_DIR

