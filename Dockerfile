FROM stormsw/ubuntu-java
# teamcity build agent for NodeJS
MAINTAINER Alexander Varchenko <alexander.varchenko@gmail.com>
ENV DEBIAN_FRONTEND noninteractive
ENV AGENT_DIR="/opt/teamcity/agent"
ENV TEAMCITY_SERVER=http://localhost:8888
ENV NODE_URI https://deb.nodesource.com/setup_4.x
RUN apt-get update && \
    apt-get install -y --force-yes --no-install-recommends\
      apt-transport-https \
      build-essential \
      curl \
      ca-certificates \
      git \
      lsb-release \
      python-all \
      rlwrap && \
      curl -sL \$NODE_URI | bash - && \
      apt-get install -y --force-yes --no-install-recommends nodejs  && \
      rm -rf /var/lib/apt/lists/*;
RUN adduser --disabled-password --gecos '' --disabled-login --home $AGENT_DIR teamcity
RUN echo "teamcity ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
# nodejs build chain
RUN     npm install npm -g &&\
        npm install -g node-gyp &&\
        npm install -g bower &&\
        npm install -g grunt-cli
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
CMD sudo -u teamcity -s -- sh -c "TEAMCITY_SERVER=$TEAMCITY_SERVER bin/agent.sh run"
