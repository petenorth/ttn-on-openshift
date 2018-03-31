FROM ttn

USER root

RUN mkdir -p /root/.env/discovery
RUN mkdir -p /root/.env/router
RUN mkdir -p /root/.env/networkserver
RUN mkdir -p /root/.env/broker
RUN mkdir -p /root/.env/handler

RUN chgrp -R 0 /root && \
    chmod -R g=u /root

USER 10001

