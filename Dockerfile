# docker run -d -p 8000:8000 alseambusher/crontab-ui
FROM ubuntu:18.04

ENV CRON_PATH=/var/spool/cron/crontabs

RUN  mkdir /crontab-ui;
WORKDIR /crontab-ui

LABEL maintainer "@alseambusher"
LABEL description "Crontab-UI docker"

ENV TZ=America/New_York
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y tzdata

RUN  apt-get update && apt-get install -y \
      wget \
      curl \
      nodejs \
      npm \
      supervisor \
      cron \
      systemd


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
