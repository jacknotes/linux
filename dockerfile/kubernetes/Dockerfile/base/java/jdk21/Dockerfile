#FROM harbor.homsom.com/java/ops_jdk21-maven3_3_9:v1
FROM harbor.homsom.com/public/alpine:3.20.1

LABEL "Custom_CA"="True"
LABEL "Author"="JackLi"

# jdk and maven environment
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories 
RUN apk add --no-cache busybox-extras && \
	apk add --no-cache bash zsh && \
	apk add --no-cache cmd:bash cmd:zsh && \
	apk add --no-cache openjdk21

ENV PATH=$PATH:/usr/local/maven/bin
ADD file/apache-maven-3.3.9-bin.tar.gz /usr/local/

RUN ln -sv /usr/local/apache-maven-3.3.9 /usr/local/maven && \
	mvn -version


# custom CA certification
ENV FILEDIR="file" TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ADD $FILEDIR/*.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

WORKDIR /


