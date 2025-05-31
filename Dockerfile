FROM docker.io/library/python:3.10-bookworm
ARG VERSION

LABEL \
    maintainer="Martin Bjeldbak Madsen <me@martinbjeldbak.com>" \
    org.opencontainers.image.title="acestream-http-proxy" \
    org.opencontainers.image.description="Stream AceStream sources on macOS and other systems without needing to install AceStream player" \
    org.opencontainers.image.authors="Martin Bjeldbak Madsen <me@martinbjeldbak.com>" \
    org.opencontainers.image.url="https://github.com/martinbjeldbak/acestream-http-proxy" \
    org.opencontainers.image.vendor="https://martinbjeldbak.com"

ENV DEBIAN_FRONTEND="noninteractive" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VERSION="3.2.3_ubuntu_22.04_x86_64_py3.10" \
    ALLOW_REMOTE_ACCESS="no" \
    HTTP_PORT=6878 \
    EXTRA_FLAGS=''

USER root
WORKDIR /app

# Install acestream dependencies
RUN \
  apt-get update \
  && \
  apt-get install --no-install-recommends --no-install-suggests -y \
      bash \
      ca-certificates \
      catatonit \
      curl \
      python3-pip libpython3.10 \
      libcairo2-dev libxt-dev libgirepository1.0-dev \
      python3-gi gobject-introspection gir1.2-gtk-3.0

RUN \
  mkdir -p /app \
  && curl -fsSL "https://download.acestream.media/linux/acestream_${VERSION}.tar.gz" \
      | tar xzf - -C /app \
  && pip install --requirement /app/requirements.txt \
  && pip install pycairo "PyGObject<3.51.0" \
  && chown -R root:root /app && chmod -R 755 /app \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/

COPY . /

# USER nobody:nogroup
# WORKDIR /config
# VOLUME [ "/config" ]

ENTRYPOINT ["/usr/bin/catatonit", "--", "/entrypoint.sh"]

EXPOSE 6878/tcp

