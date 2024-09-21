#FROM harborrepo.hs.com/base/frontend/ops_node:18.0.0-buster
FROM node:18.0.0-buster

LABEL "Custom_CA"="True"
LABEL "Author"="JackLi"


ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV FILEDIR="file"
ADD $FILEDIR/*.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

WORKDIR /
