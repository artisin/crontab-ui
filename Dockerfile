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
SHELL ["/bin/bash", "--login", "-i", "-c"]
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.2/install.sh | bash
RUN source /root/.bashrc && nvm install 16.14.0
SHELL ["/bin/bash", "--login", "-c"]


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
