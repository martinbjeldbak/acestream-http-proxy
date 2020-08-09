FROM ubuntu:bionic

LABEL maintainer="Martin Bjeldbak Madsen <me@martinbjeldbak.com>"

ENV ACESTREAM_VERSION="3.1.49_ubuntu_18.04_x86_64"

RUN apt-get update && \
      apt-get install --no-install-recommends -y wget libpython2.7 python-setuptools python-m2crypto python-apsw net-tools python-lxml && \
      apt-get clean && rm -rf /var/lib/apt/lists/* && \
      wget "http://acestream.org/downloads/linux/acestream_${ACESTREAM_VERSION}.tar.gz" && \
      mkdir acestream && \
      tar zxf "acestream_${ACESTREAM_VERSION}.tar.gz" -C acestream && \
      mv acestream /opt/acestream

EXPOSE 6878

CMD ["/opt/acestream/start-engine", "--client-console"]
