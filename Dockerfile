# docker run -d -p 8000:8000 alseambusher/crontab-ui
FROM ubuntu:18.04

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


# Installing Node

ENV NVM_DIR /root/.nvm
ENV NODE_VERSION 16.13.0

# Install nvm with node and npm
RUN curl -sL https://raw.githubusercontent.com/creationix/nvm/v0.35.3/install.sh | bash \
  && . $NVM_DIR/nvm.sh \ 
  && nvm install $NODE_VERSION

RUN systemctl enable cron
RUN echo ALL >> /etc/cron.allow

COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY . /crontab-ui

RUN   npm install

ENV   HOST 0.0.0.0

ENV   PORT 8000

ENV   CRON_IN_DOCKER true

EXPOSE $PORT



CMD ["supervisord", "-n"]
