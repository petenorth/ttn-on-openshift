FROM starter-arbitrary-uid

USER root

RUN yum -y install unzip 
RUN curl https://ttnreleases.blob.core.windows.net/release/master/ttnctl-linux-amd64.zip -o ttnctl-linux-amd64.zip
RUN unzip ttnctl-linux-amd64.zip
RUN chmod +x ttnctl-linux-amd64
RUN cp ttnctl-linux-amd64 /usr/local/bin/ttnctl

RUN mkdir /opt/app-root/data_ttnctl
RUN chgrp -R 0 /opt/app-root/data_ttnctl && \
    chmod -R g=u /opt/app-root/data_ttnctl

USER 10001

