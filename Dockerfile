FROM openjdk:8-jdk-alpine
MAINTAINER Alexander-Krause <akr@informatik.uni-kiel.de>

# docker build -t alexanderkrause/target-system .
# docker run -t -d --name target1 -p 8088:8080 -p 8089:8081 alexanderkrause/target-system
# docker exec target1 /bin/sh
# docker run -it --name target1 alexanderkrause/target-system /bin/sh

ENV TOMCAT_TGZ_URL=http://ftp.halifax.rwth-aachen.de/apache/tomcat/tomcat-8/v8.5.28/bin/apache-tomcat-8.5.28.tar.gz
ENV AGENT_TGZ_URL=https://github.com/ExplorViz/explorviz-discovery-agent/releases/download/0.1/explorviz-discovery-agent.war
ENV JPETSTORE_WAR_URL=https://github.com/ExplorViz/explorviz-discovery-agent/releases/download/0.1/jpetstore.war
ENV SAMPLE_APP_TGZ_URL=https://github.com/ExplorViz/explorviz-discovery-agent/releases/download/0.1/sampleApplication.tar.gz

RUN apk --no-cache add wget dos2unix

RUN wget -O tomcat.tar.gz "$TOMCAT_TGZ_URL" \
  && mkdir explorviz-discovery-agent \
  && mkdir apache-tomcat \
  && tar -xzf tomcat.tar.gz -C apache-tomcat --strip-components=1 \
  && tar -xzf tomcat.tar.gz -C explorviz-discovery-agent --strip-components=1 \
  && rm apache-tomcat/bin/*.bat \
  && rm explorviz-discovery-agent/bin/*.bat \
  && rm tomcat.tar.gz*

RUN wget "$AGENT_TGZ_URL" \
  && mkdir /explorviz-discovery-agent/webapps/explorviz-discovery-agent \
  && unzip explorviz-discovery-agent.war -d /explorviz-discovery-agent/webapps/explorviz-discovery-agent/ \
  && rm explorviz-discovery-agent.war \
  && wget "$JPETSTORE_WAR_URL" \
  && mkdir /apache-tomcat/webapps/jpetstore \
  && unzip jpetstore.war -d /apache-tomcat/webapps/jpetstore/ \
  && rm jpetstore.war \
  && wget "$SAMPLE_APP_TGZ_URL" \
  && mkdir kiekerSampleApp \
  && tar -xzf sampleApplication.tar.gz -C kiekerSampleApp \
  && rm sampleApplication.tar.gz

COPY agent/explorviz.properties /explorviz-discovery-agent/webapps/explorviz-discovery-agent/WEB-INF/classes/explorviz.properties
COPY tomcat/server-agent.xml /explorviz-discovery-agent/conf/server.xml
COPY tomcat/server-tomcat.xml /apache-tomcat/conf/server.xml

RUN dos2unix /explorviz-discovery-agent/webapps/explorviz-discovery-agent/WEB-INF/classes/explorviz.properties \
  && dos2unix /explorviz-discovery-agent/conf/server.xml \
  && dos2unix /apache-tomcat/conf/server.xml

EXPOSE 8080
EXPOSE 8081

CMD explorviz-discovery-agent/bin/startup.sh && apache-tomcat/bin/startup.sh && cd kiekerSampleApp && ./run.sh && tail -f /dev/null