# Dockerfile for apollo-portal
# Build with:
# docker build -t apollo-portal .
# Run with:
# docker run -p 9090:8080 -d --name apollo-portal apollo-portal

FROM java:8-jre
MAINTAINER Jack

ENV VERSION 1.7.0

RUN apt-get install unzip

ADD apollo-portal-${VERSION}-github.zip /apollo-portal/apollo-portal-${VERSION}-github.zip

RUN unzip /apollo-portal/apollo-portal-${VERSION}-github.zip -d /apollo-portal \
    && rm -rf /apollo-portal/apollo-portal-${VERSION}-github.zip \
    && sed -i '$d' /apollo-portal/scripts/startup.sh \
    && echo "tail -f /dev/null" >> /apollo-portal/scripts/startup.sh

ADD application-github.properties /apollo-portal/config/
ADD apollo-env.properties /apollo-portal/config/

EXPOSE 8070

CMD ["/apollo-portal/scripts/startup.sh"]
