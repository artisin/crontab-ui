# docker run -d -p 8000:8000 alseambusher/crontab-ui
FROM ubuntu:18.04

ENV  CRON_PATH=/var/spool/cron

RUN  mkdir /crontab-ui; touch $CRON_PATH/root; chmod +x $CRON_PATH/root

WORKDIR /crontab-ui

LABEL maintainer "@alseambusher"
LABEL description "Crontab-UI docker"

RUN apt-get update
RUN   apt-get install \
      wget \
      curl \
      nodejs \
      npm \
      supervisor \
      tzdata

COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY . /crontab-ui

RUN   npm install

ENV   HOST 0.0.0.0

ENV   PORT 8000

ENV   CRON_IN_DOCKER true

EXPOSE $PORT

CMD ["supervisord", "-n"]
