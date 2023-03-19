FROM alpine
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
	apk add curl nmap iproute2 tree nginx  

CMD ["sleep", "999999"]
