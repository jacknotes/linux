# Dockerfile for apollo-adminservice
# Build with:
# docker build -t apollo-adminservice .
# Run with:
# docker run -p 8090:8090 -d --name apollo-adminservice apollo-adminservice

FROM java:8-jre
MAINTAINER Jack

ENV VERSION 1.7.0

RUN apt-get install unzip

ADD apollo-adminservice-${VERSION}-github.zip /apollo-adminservice/apollo-adminservice-${VERSION}-github.zip

RUN unzip /apollo-adminservice/apollo-adminservice-${VERSION}-github.zip -d /apollo-adminservice \
    && rm -rf /apollo-adminservice/apollo-adminservice-${VERSION}-github.zip \
    && sed -i '$d' /apollo-adminservice/scripts/startup.sh \
    && echo "tail -f /dev/null" >> /apollo-adminservice/scripts/startup.sh 

ADD application-github.properties /apollo-adminservice/config/

EXPOSE 8090

CMD ["/apollo-adminservice/scripts/startup.sh"]
