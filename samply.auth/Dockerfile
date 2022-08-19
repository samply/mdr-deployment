FROM tomcat:8.5-jre8-alpine

RUN echo H

# Required for config file creation on startup.
RUN apk --no-cache add xmlstarlet openssl && \
    rm -rf /usr/local/tomcat/webapps/* && \
    rm /usr/local/tomcat/conf/tomcat-users.xml

COPY sa_entrypoint.sh /docker/
RUN chmod a+rx /docker/sa_entrypoint.sh
COPY templates/ /docker/templates/

COPY auth-1.12.3.war /usr/local/tomcat/webapps/ROOT.war

COPY certs.sh /docker
RUN cd /docker && sh certs.sh

# Run the Tomcat server on a different port
RUN sed -i 's/8080/8086/' /usr/local/tomcat/conf/server.xml

ENTRYPOINT [ "/docker/sa_entrypoint.sh" ]
