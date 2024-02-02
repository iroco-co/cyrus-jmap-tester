FROM debian:bookworm-slim
ARG cyrus_version=3.8.1

RUN apt update && apt install -y rsyslog sscg wget rsync git build-essential autoconf automake libtool pkg-config bison flex libssl-dev libjansson-dev  \
    libxml2-dev libsqlite3-dev libical-dev libsasl2-dev uuid-dev libicu-dev libxapian-dev libpq-dev libbrotli-dev  \
    libchardet-dev libical-dev libnghttp2-dev shapelib libwslay-dev zlib1g-dev libclamav-dev libcld2-dev libpcre3-dev \
    sasl2-bin

RUN useradd --home-dir /usr/src -g mail cyrus
RUN cd /usr/src &&  \
    wget "https://github.com/cyrusimap/cyrus-imapd/releases/download/cyrus-imapd-$cyrus_version/cyrus-imapd-$cyrus_version.tar.gz" && \
    tar xzf cyrus-imapd-$cyrus_version.tar.gz && \
    cd cyrus-imapd-$cyrus_version && \
    ./configure --enable-calalarmd --enable-autocreate --enable-nntp --enable-http --enable-jmap --with-openssl=yes  \
    --enable-idled --enable-xapian --with-sphinx-build=no --enable-murder --enable-replication && \
    make && make install

COPY --chmod=755 entrypoint.sh /usr/local/sbin/
COPY --chown=cyrus:mail --chmod=600 imapd.conf /etc/
COPY --chown=cyrus:mail --chmod=600 cyrus.conf /etc/
RUN sed -i '/imklog/s/^/#/' /etc/rsyslog.conf
RUN sed -i '5i START=yes' /etc/default/saslauthd

RUN mkdir -p /var/lib/cyrus && chown cyrus:mail /var/lib/cyrus  && \
  mkdir -p /var/spool/cyrus && chown cyrus:mail /var/spool/cyrus && \
  mkdir -p /var/lib/cyrus/socket && chown cyrus:mail /var/lib/cyrus/socket && \
  mkdir -p /var/lib/cyrus/db && chown cyrus:mail /var/lib/cyrus/db && \
  mkdir -p /var/lib/cyrus/jwt && chown cyrus:mail /var/lib/cyrus/jwt && \
  mkdir -p /var/lib/cyrus/search && chown cyrus:mail /var/lib/cyrus/search && \
  chown cyrus:mail /usr/src

ENV LD_LIBRARY_PATH=/usr/local/lib

EXPOSE 143 993 4190 8080

HEALTHCHECK --interval=5s --retries=10 CMD netstat -ltn | grep -c :143 || exit 1

CMD /usr/local/sbin/entrypoint.sh

LABEL org.opencontainers.image.source "https://github.com/iroco-co/cyrus-jmap-tester"
LABEL org.opencontainers.image.description "Spins up a cyrus-imapd in a container for use with integration testing."