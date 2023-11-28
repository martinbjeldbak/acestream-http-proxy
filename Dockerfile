# syntax=docker/dockerfile:1

FROM ubuntu:18.04

LABEL \
    maintainer="Martin Bjeldbak Madsen <me@martinbjeldbak.com>" \
    org.opencontainers.image.title="acestream-http-proxy" \
    org.opencontainers.image.description="Stream AceStream sources on macOS and other systems without needing to install AceStream player" \
    org.opencontainers.image.authors="Martin Bjeldbak Madsen <me@martinbjeldbak.com>" \
    org.opencontainers.image.url="https://github.com/martinbjeldbak/acestream-http-proxy" \
    org.opencontainers.image.vendor="https://martinbjeldbak.com"

ENV ACESTREAM_VERSION="3.1.75rc4_ubuntu_18.04_x86_64_py3.8"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install acestream dependencies
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
      python3.8 ca-certificates wget sudo \
  && rm -rf /var/lib/apt/lists/* \
  #
  # Download acestream
  && wget --progress=dot:giga "https://download.acestream.media/linux/acestream_${ACESTREAM_VERSION}.tar.gz" \
  && mkdir acestream \
  && tar zxf "acestream_${ACESTREAM_VERSION}.tar.gz" -C acestream \
  && rm "acestream_${ACESTREAM_VERSION}.tar.gz" \
  && mv acestream /opt/acestream \
  && pushd /opt/acestream \
  && bash ./install_dependencies.sh \
  && popd


EXPOSE 6878/tcp

ENTRYPOINT ["/opt/acestream/start-engine"]
CMD ["--client-console"]
