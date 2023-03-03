FROM ubuntu:bionic

LABEL maintainer="Martin Bjeldbak Madsen <me@martinbjeldbak.com>"

ENV ACESTREAM_VERSION="3.1.75rc4_ubuntu_18.04_x86_64_py3.8"

RUN apt-get update
RUN apt-get install --no-install-recommends -y \
        build-essential \
        wget \
        python3.8 \
        python3-dev \
        python3-pip \
        python3-setuptools \
        libpython3.8-dev \
        libssl-dev \
        swig \
        libffi-dev \
        net-tools

RUN python3.8 -m pip install certifi PyNaCl pycryptodome apsw lxml

RUN wget --progress=dot:giga "https://download.acestream.media/linux/acestream_${ACESTREAM_VERSION}.tar.gz" && \
    mkdir acestream && \
    tar zxf "acestream_${ACESTREAM_VERSION}.tar.gz" -C acestream && \
    mv acestream /opt/acestream

EXPOSE 6878

CMD ["/opt/acestream/start-engine", "--client-console"]
