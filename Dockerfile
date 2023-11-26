# syntax=docker/dockerfile:1

FROM ubuntu:18.04

ARG USERNAME=ace
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

LABEL \
    maintainer="Martin Bjeldbak Madsen <me@martinbjeldbak.com>" \
    org.opencontainers.image.title="acestream-http-proxy" \
    org.opencontainers.image.description="Stream AceStream sources on macOS and other systems without needing to install AceStream player" \
    org.opencontainers.image.authors="Martin Bjeldbak Madsen <me@martinbjeldbak.com>" \
    org.opencontainers.image.url="https://github.com/martinbjeldbak/acestream-http-proxy" \
    org.opencontainers.image.vendor="https://martinbjeldbak.com"

ENV ACESTREAM_VERSION="3.1.75rc4_ubuntu_18.04_x86_64_py3.8"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Create user
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
  #
  # Set up caddy repos
  && apt-get update \
  && apt-get install -y curl debian-keyring debian-archive-keyring apt-transport-https \
  && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg \
  && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list \
  #
  # Install acestream dependencies & caddy
  && apt-get update \
  && apt-get install --no-install-recommends -y \
      gcc \
      python3.8 \
      python3-dev \
      python3-pip \
      python3-setuptools \
      libpython3.8-dev \
      libssl-dev \
      libxml2-dev \
      libxslt-dev \
      swig \
      libffi-dev \
      net-tools \
      caddy \
  && rm -rf /var/lib/apt/lists/* \
  #
  && python3.8 -m pip install --no-cache-dir certifi PyNaCl pycryptodome apsw lxml \
  #
  # Download acestream
  && curl "https://download.acestream.media/linux/acestream_${ACESTREAM_VERSION}.tar.gz" --output "acestream_${ACESTREAM_VERSION}.tar.gz" \
  && mkdir acestream \
  && tar zxf "acestream_${ACESTREAM_VERSION}.tar.gz" -C acestream \
  && rm "acestream_${ACESTREAM_VERSION}.tar.gz" \
  && mv acestream /opt/acestream \
  && usermod -aG caddy ${USERNAME}

# Document that we are exposing this as the HTTP API port
EXPOSE 6878/tcp
EXPOSE 443
EXPOSE 80

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

COPY Caddyfile  /var/www/html/

USER $USERNAME
ENTRYPOINT ["entrypoint.sh"]
CMD ["caddy", "run"]
