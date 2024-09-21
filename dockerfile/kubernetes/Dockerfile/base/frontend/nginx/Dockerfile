#FROM harborrepo.hs.com/base/frontend/ops_nginx:alpine
FROM nginx:alpine

LABEL "Custom_CA"="True"
LABEL "Author"="JackLi"


ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV FILEDIR="file"
ADD $FILEDIR/*.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

WORKDIR /
