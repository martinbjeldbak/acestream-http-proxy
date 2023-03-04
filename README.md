# AceStream HTTP Proxy
[![Build and push Docker image to DockerHub](https://github.com/martinbjeldbak/acestream-http-proxy/actions/workflows/build-and-push-docker.yml/badge.svg?event=release)](https://github.com/martinbjeldbak/acestream-http-proxy/actions/workflows/build-and-push-docker.yml)
[![Lint](https://github.com/martinbjeldbak/acestream-http-proxy/actions/workflows/lint-dockerfile.yml/badge.svg)](https://github.com/martinbjeldbak/acestream-http-proxy/actions/workflows/lint-dockerfile.yml)

This docker image installs and runs the AceStream Engine in Ubuntu and exposes the [HTTP API](https://docs.acestream.net/en/developers/connect-to-engine/).

As a result, you will be able to watch live AceStream sources without needing to install the AceStream player or other dependencies locally.

This is especially useful for MacOS, Raspberry Pi's and XMBC users who want to tune in to AceStream channels.

## Usage

Ensure you have [docker](https://www.docker.com) installed and running. You can then pull down and run the container as shown below.

```console
$ docker run -t -p 6878:6878 ghcr.io/martinbjeldbak/acestream-http-proxy
```

You are then able to access live AceSream content by pointing your favorite media player (VLC, IINA, etc.) to the below network URL

```
http://127.0.0.1:6878/ace/getstream?id=dd1e67078381739d14beca697356ab76d49d1a2d
```

Where `dd1e67078381739d14beca697356ab76d49d1a2d` is the ID of the desired AceStream channel.

## Contributing

Ensure you have docker installed with support for docker-compose.

Dockerfile steps are roughly guided by <https://wiki.acestream.media/Install_Ubuntu> and AUR packages https://aur.archlinux.org/packages/acestream-engine-stable

For a list of AceStream versions, see here: <https://docs.acestream.net/products/#linux>

For convenience of easy image rebuilding, this repository contains a [`docker-compose.yml` ](https://github.com/martinbjeldbak/acestream-http-proxy/blob/master/docker-compose.yml) file. You can then build & run the image locally by running the following command

```console
$ docker-compose up --build
```
