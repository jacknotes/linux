#FROM harborrepo.hs.com/base/frontend/ops_node:16
FROM node:16

LABEL "Custom_CA"="True"
LABEL "Author"="JackLi"


ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV FILEDIR="file"
ADD $FILEDIR/*.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

WORKDIR /
