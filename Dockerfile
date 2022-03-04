# docker run -d -p 8000:8000 alseambusher/crontab-ui
FROM debian:latest

# replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# update the repository sources list
# and install dependencies
RUN  apt-get update && apt-get install -y \
      git \
      wget \
      curl \
      supervisor \
      cron \
      systemd \
      autoclean \
      vim && \
     rm -rf /var/lib/apt/lists/*

ENV TZ=America/New_York
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y tzdata

RUN systemctl enable cron
RUN echo ALL >> /etc/cron.allow

# nvm environment variables
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 14.16.0

# install nvm
# https://github.com/creationix/nvm#install-script
RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.2/install.sh | bash

# install node, npm and yarn
RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default \
    && npm install --global yarn@1.22.10

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


ENV CRON_PATH=/var/spool/cron/crontabs
RUN  mkdir /crontab-ui;
WORKDIR /crontab-ui

COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY . /crontab-ui

RUN   npm install

ENV   HOST 0.0.0.0

ENV   PORT 8000

ENV   CRON_IN_DOCKER true

EXPOSE $PORT

# Disable the invariant mode (set in base image)
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1


CMD ["supervisord", "-n"]
