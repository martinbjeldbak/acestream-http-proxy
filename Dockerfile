# syntax=docker/dockerfile:1

FROM ubuntu:22.04

LABEL \
    maintainer="Martin Bjeldbak Madsen <me@martinbjeldbak.com>" \
    org.opencontainers.image.title="acestream-http-proxy" \
    org.opencontainers.image.description="Stream AceStream sources on macOS and other systems without needing to install AceStream player" \
    org.opencontainers.image.authors="Martin Bjeldbak Madsen <me@martinbjeldbak.com>" \
    org.opencontainers.image.url="https://github.com/martinbjeldbak/acestream-http-proxy" \
    org.opencontainers.image.vendor="https://martinbjeldbak.com"

ENV ACESTREAM_VERSION="3.2.3_ubuntu_22.04_x86_64_py3.10"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install acestream dependencies
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
      python3.10 ca-certificates wget sudo \
  && rm -rf /var/lib/apt/lists/* \
  #
  # Download acestream
  && wget --progress=dot:giga "https://download.acestream.media/linux/acestream_${ACESTREAM_VERSION}.tar.gz" \
  && mkdir acestream \
  && tar zxf "acestream_${ACESTREAM_VERSION}.tar.gz" -C acestream \
  && rm "acestream_${ACESTREAM_VERSION}.tar.gz" \
  && mv acestream /opt/acestream \
  && pushd /opt/acestream || exit \
  && bash ./install_dependencies.sh \
  && popd || exit

RUN apt install -y curl supervisor jq 
COPY supervisor.conf /etc/supervisor/conf.d/
COPY api-configuration.sh /
ENV ALLOW_REMOTE_ACCESS="no"

ENTRYPOINT ["/usr/bin/supervisord"]
CMD ["-n", "-c", "/etc/supervisor/supervisord.conf"]

EXPOSE 6878/tcp

