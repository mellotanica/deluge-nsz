FROM python

ARG branch_name=master

RUN pip3 install --upgrade nsz

RUN apt-get -y update && apt-get -y install inotify-tools && \
    git clone https://github.com/ncopa/su-exec && \
    make -C su-exec && mv su-exec/su-exec /usr/bin && rm -rf su-exec

ENTRYPOINT ["sh", "/entrypoint.sh"]

COPY /entrypoint.sh /
COPY /extract.sh /opt/

RUN chmod +x /entrypoint.sh /opt/extract.sh

