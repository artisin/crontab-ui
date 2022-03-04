# docker run -d -p 8000:8000 alseambusher/crontab-ui
FROM ubuntu:18.04

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

ENV CRON_PATH=/var/spool/cron/crontabs

RUN  mkdir /crontab-ui;
WORKDIR /crontab-ui

LABEL maintainer "@alseambusher"
LABEL description "Crontab-UI docker"

RUN apt-get update --fix-missing
RUN apt-get install -y build-essential libssl-dev

ENV TZ=America/New_York
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y tzdata

RUN  apt-get update && apt-get install -y \
      wget \
      curl \
      supervisor \
      cron \
      systemd

RUN systemctl enable cron
RUN echo ALL >> /etc/cron.allow

# Installing Node
ENV NVM_DIR /root/.nvm
ENV NODE_VERSION stable

# Install nvm
RUN git clone https://github.com/creationix/nvm.git $NVM_DIR && \
    cd $NVM_DIR && \
    git checkout `git describe --abbrev=0 --tags`

# Install default version of Node.js
RUN source $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default

# Add nvm.sh to .bashrc for startup...
RUN echo "source ${NVM_DIR}/nvm.sh" > $HOME/.bashrc && \
    source $HOME/.bashrc

# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH


# confirm installation
RUN echo latest > ~/TEST_VERSION
RUN node -v
RUN npm -v


COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY . /crontab-ui

RUN   npm install

ENV   HOST 0.0.0.0

ENV   PORT 8000

ENV   CRON_IN_DOCKER true

EXPOSE $PORT



CMD ["supervisord", "-n"]
