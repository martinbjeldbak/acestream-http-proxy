# syntax=docker/dockerfile:1

FROM docker.io/library/python:3.10-bookworm
ARG VERSION

LABEL \
    maintainer="Martin Bjeldbak Madsen <me@martinbjeldbak.com>" \
    org.opencontainers.image.title="acestream-http-proxy" \
    org.opencontainers.image.description="Stream AceStream sources without needing to install AceStream player" \
    org.opencontainers.image.authors="Martin Bjeldbak Madsen <me@martinbjeldbak.com>" \
    org.opencontainers.image.url="https://github.com/martinbjeldbak/acestream-http-proxy" \
    org.opencontainers.image.vendor="https://martinbjeldbak.com"

ENV DEBIAN_FRONTEND="noninteractive" \
    CRYPTOGRAPHY_DONT_BUILD_RUST=1 \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_ROOT_USER_ACTION=ignore \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_NO_CACHE=true \
    UV_SYSTEM_PYTHON=true

ENV VERSION="3.2.3_ubuntu_22.04_x86_64_py3.10" \
    ALLOW_REMOTE_ACCESS="no" \
    HTTP_PORT=6878 \
    EXTRA_FLAGS=''

USER root
WORKDIR /app

RUN \
  apt-get update \
  && \
  apt-get install --no-install-recommends --no-install-suggests -y \
      bash \
      ca-certificates \
      catatonit \
      nano \
      libgirepository1.0-dev

RUN \
    groupadd --gid 1000 appuser \
    && useradd --uid 1000 --gid 1000 -m appuser \
    && mkdir -p /app \
    && curl -fsSL "https://download.acestream.media/linux/acestream_${VERSION}.tar.gz" \
        | tar xzf - -C /app \
    && pip install uv \
    && uv pip install --requirement /app/requirements.txt \
    && chown -R appuser:appuser /app && chmod -R 755 /app \
    && pip uninstall --yes uv \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/

COPY . /

USER appuser

ENTRYPOINT ["/usr/bin/catatonit", "--", "/entrypoint.sh"]

EXPOSE 6878/tcp

