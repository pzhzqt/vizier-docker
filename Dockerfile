FROM ubuntu:latest

RUN apt-get update -y
RUN apt-get upgrade -y

RUN apt-get install -y python3 python3-pip openjdk-8-jre

#install Vizier 
RUN pip3 install --system vizier-webapi
RUN ln -s /usr/bin/python3 /usr/bin/python

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

#download Mimir jars (avoid starting the API by passing a dummy argument -- this can be done more cleanly)
RUN COURSIER_CACHE=/usr/local/mimir/cache /usr/local/mimir/mimir-api --hack-to-exit-the-API; exit 0

#patch for dockerized port & volumes
RUN mv /usr/local/bin/vizier /usr/local/bin/vizier.bak \
 && cat /usr/local/bin/vizier.bak | sed '\
       s/flask run/flask run -h 0.0.0.0/; \
       s:${APP_DATA_DIR}mimir/mimir-api:(cd /data; ${APP_DATA_DIR}mimir/mimir-api):\
       ' > /usr/local/bin/vizier \
 && chmod +x /usr/local/bin/vizier

EXPOSE 5000
EXPOSE 8089

ENV COURSIER_CACHE=/usr/local/mimir/cache

RUN mkdir /data
ENV USER_DATA_DIR=/data/

ENTRYPOINT ["/usr/local/bin/vizier"]
