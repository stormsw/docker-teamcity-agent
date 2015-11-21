FROM stormsw/ubuntu-java
MAINTAINER Alexander Varchenko <alexander.varchenko@gmail.com>
ENV AGENT_DIR="/opt/teamcity/agent"
ENV TEAMCITY_SERVER=http://localhost:8888
RUN adduser --disabled-password --gecos '' --disabled-login --home $AGENT_DIR teamcity
RUN echo "teamcity ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
WORKDIR $AGENT_DIR
RUN wget $TEAMCITY_SERVER/update/buildAgent.zip &&\
    unzip -q -d $AGENT_DIR buildAgent.zip && \
    rm buildAgent.zip && \
    chmod +x $AGENT_DIR/bin/agent.sh
RUN echo "serverUrl=${TEAMCITY_SERVER}" > $AGENT_DIR/conf/buildAgent.properties
RUN echo "name=" >> $AGENT_DIR/conf/buildAgent.properties
RUN echo "workDir=../work" >> $AGENT_DIR/conf/buildAgent.properties
RUN echo "tempDir=../temp" >> $AGENT_DIR/conf/buildAgent.properties
RUN echo "systemDir=../system" >> $AGENT_DIR/conf/buildAgent.properties
RUN chown teamcity:teamcity -R $AGENT_DIR
EXPOSE 9090
#USER teamcity
# add docker client there (TODO: remove server parts)
RUN curl -sSL https://get.docker.com/ | sh
ENV DOCKER_HOST=tcp://172.17.0.1:2375
RUN usermod -aG docker teamcity
CMD sudo -u teamcity -s -- sh -c "TEAMCITY_SERVER=$TEAMCITY_SERVER bin/agent.sh run"
