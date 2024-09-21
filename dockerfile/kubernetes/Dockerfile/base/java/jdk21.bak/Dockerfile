# FROM harborrepo.hs.com/base/java/ops_java-alpine:21
FROM harborrepo.hs.com/base/java/java-alpine:21

LABEL "Custom_CA"="True"
LABEL "Author"="JackLi"


ENV FILEDIR="file"
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ADD $FILEDIR/*.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

WORKDIR /

