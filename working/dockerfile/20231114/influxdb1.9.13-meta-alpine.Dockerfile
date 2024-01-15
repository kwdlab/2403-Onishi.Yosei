FROM alpine:3.17

RUN echo 'hosts: files dns' >> /etc/nsswitch.conf
RUN apk add --no-cache tzdata bash ca-certificates && \
    update-ca-certificates

ENV INFLUXDB_VERSION 1.9.13-c1.9.13
RUN set -ex && \
    apk add --no-cache --virtual .build-deps wget gnupg tar && \
    for key in \
        9D539D90D3328DC7D6C8D3B9D8FF8E1F7DF8B07E ; \
    do \
        gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys "$key" ; \
    done && \
    wget --no-verbose https://dl.influxdata.com/enterprise/releases/influxdb-meta-${INFLUXDB_VERSION}_linux_amd64.tar.gz.asc && \
    wget --no-verbose https://dl.influxdata.com/enterprise/releases/influxdb-meta-${INFLUXDB_VERSION}_linux_amd64.tar.gz && \
    gpg --batch --verify influxdb-meta-${INFLUXDB_VERSION}_linux_amd64.tar.gz.asc influxdb-meta-${INFLUXDB_VERSION}_linux_amd64.tar.gz && \
    mkdir -p /usr/src && \
    tar -C /usr/src -xzf influxdb-meta-${INFLUXDB_VERSION}_linux_amd64.tar.gz && \
    rm -f /usr/src/influxdb-*/etc/influxdb/influxdb-meta.conf && \
    chmod +x /usr/src/influxdb-*/usr/bin/* && \
    cp -a /usr/src/influxdb-*/usr/bin/. /usr/bin/ && \
    gpgconf --kill all && \
    rm -rf *.tar.gz* /usr/src /root/.gnupg && \
    apk del .build-deps
COPY influxdb-meta.conf /etc/influxdb/influxdb-meta.conf

EXPOSE 8091

VOLUME /var/lib/influxdb

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["influxd-meta"]
