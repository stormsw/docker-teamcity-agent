FROM stormsw/ubuntu-java
MAINTAINER Alexander Varchenko <alexander.varchenko@gmail.com>
ENV AGENT_DIR="/opt/teamcity/agent"
ENV AGENT_ID=tca3
ENV TEAMCITY_SERVER=http://172.17.0.1:8888/cis
RUN adduser --disabled-password --gecos '' --disabled-login --home $AGENT_DIR teamcity
RUN echo "teamcity ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
WORKDIR $AGENT_DIR
RUN wget $TEAMCITY_SERVER/update/buildAgent.zip &&\
    unzip -q -d $AGENT_DIR buildAgent.zip && \
    rm buildAgent.zip && \
    chmod +x $AGENT_DIR/bin/agent.sh
RUN echo "serverUrl=${TEAMCITY_SERVER}" > $AGENT_DIR/conf/buildAgent.properties
RUN echo "name=${AGENT_ID}" >> $AGENT_DIR/conf/buildAgent.properties
RUN echo "workDir=../work" >> $AGENT_DIR/conf/buildAgent.properties
RUN echo "tempDir=../temp" >> $AGENT_DIR/conf/buildAgent.properties
RUN echo "systemDir=../system" >> $AGENT_DIR/conf/buildAgent.properties
RUN echo "authorizationToken=b2e28d3a893c79e5e03ad14ea1dbe6ce" >> $AGENT_DIR/conf/buildAgent.properties
RUN echo "ownHost=http://${AGENT_ID}" >> $AGENT_DIR/conf/buildAgent.properties
RUN echo "ownPort=9090" >> $AGENT_DIR/conf/buildAgent.properties
RUN sed -r -i 's/^(\s+)(\"\$JRE_.+Launcher.+\$CONFIG_FILE)$/\1exec \2/g' bin/agent.sh
# " #COPY buildAgent.properties conf/
RUN chown teamcity:teamcity -R $AGENT_DIR
EXPOSE 9090
# add docker client there (TODO: remove server parts)
#RUN curl -sSL https://get.docker.com/ | sh
RUN wget https://get.docker.com/builds/Linux/x86_64/docker-latest&& chmod +x docker-latest && mv docker-latest /usr/bin/docker
ENV DOCKER_HOST=tcp://172.17.0.1:2375
RUN usermod -aG root teamcity
USER teamcity
#CMD sudo -u teamcity -s -- sh -c "TEAMCITY_SERVER=$TEAMCITY_SERVER bin/agent.sh run"
CMD bin/agent.sh run
#CMD java -ea -Xmx384m -Dteamcity_logs=$AGENT_DIR/logs/ -Dlog4j.configuration=file:$AGENT_DIR/conf/teamcity-agent-log4j.xml -classpath $(echo lib/*.jar | tr ' ' ':') jetbrains.buildServer.agent.AgentMain -file ../conf/buildAgent.properties -launcher.version 37176
