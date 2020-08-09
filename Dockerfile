FROM ubuntu:bionic

LABEL maintainer="Martin Bjeldbak Madsen <me@martinbjeldbak.com>"

ENV ACESTREAM_VERSION="3.1.49_ubuntu_18.04_x86_64"

RUN apt-get update && \
      apt-get install --no-install-recommends -y \
        wget=1.19.4-1ubuntu2.2 libpython2.7=2.7.17-1~18.04ubuntu1.1 python-setuptools=39.0.1-2 \
        python-m2crypto=0.27.0-5 python-apsw=3.16.2-r1-2build2 \
        net-tools=1.60+git20161116.90da8a0-1ubuntu1 python-lxml=4.2.1-1ubuntu0.1 && \
      apt-get clean && rm -rf /var/lib/apt/lists/* && \
      wget "http://acestream.org/downloads/linux/acestream_${ACESTREAM_VERSION}.tar.gz" && \
      mkdir acestream && \
      tar zxf "acestream_${ACESTREAM_VERSION}.tar.gz" -C acestream && \
      mv acestream /opt/acestream

EXPOSE 6878

CMD ["/opt/acestream/start-engine", "--client-console"]
