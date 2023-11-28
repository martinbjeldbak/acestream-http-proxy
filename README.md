# AceStream HTTP Proxy
[![Build and push Docker image to DockerHub](https://github.com/martinbjeldbak/acestream-http-proxy/actions/workflows/build-and-push-docker.yml/badge.svg?event=release)](https://github.com/martinbjeldbak/acestream-http-proxy/actions/workflows/build-and-push-docker.yml)
[![Lint](https://github.com/martinbjeldbak/acestream-http-proxy/actions/workflows/lint-dockerfile.yml/badge.svg)](https://github.com/martinbjeldbak/acestream-http-proxy/actions/workflows/lint-dockerfile.yml)

This Docker image runs the AceStream Engine and exposes its [HTTP
API](https://docs.acestream.net/en/developers/connect-to-engine/).

As a result, you will be able to watch AceStreams over HLS or MPEG-TS, without
needing to install the AceStream player or any other dependencies locally.

This is especially useful for Desktop and NAS usage for anyone who wants to
tune in to AceStream channels, and who don't want to go through the trouble of
installing AceStream and its dependencies natively.

Note: ARM-based CPUs are not currently supported, see issues [#5] and [#13].

## Usage

Ensure you have [Docker](https://www.docker.com) installed and running. You can then pull down and run the container as shown below.

```console
docker run -t -p 80:80 ghcr.io/martinbjeldbak/acestream-http-proxy
```

You are then able to access AceStreams by pointing your favorite media player
(VLC, IINA, etc.) to either of the below URLs, depending on the desired
streaming protocol.

For HLS:
```console
http://127.0.0.1/ace/manifest.m3u8?id=dd1e67078381739d14beca697356ab76d49d1a2
```

For MPEG-TS:

```console
http://127.0.0.1/ace/getstream?id=dd1e67078381739d14beca697356ab76d49d1a2
```

where `dd1e67078381739d14beca697356ab76d49d1a2d` is the ID of the AceStream channel.

This image can also be deployed to a server, where it can proxy AceStream
content over HTTP.

## Contributing

First of all, thanks!

Ensure you have Docker installed with support for docker-compose, as outlined
above. This image is simply a simplified wrapper around the
[AceStream][acestream] HTTP API in order to make it more user friendly to get
running. All options supported by the AceStream Engine are supported in this
project. Any contributions to support more configuration is greatly
appreciated!

Dockerfile steps are roughly guided by <https://wiki.acestream.media/Install_Ubuntu>.

For a list of AceStream versions, see here: <https://docs.acestream.net/products/#linux>

For convenience of easy image rebuilding, this repository contains a
[`docker-compose.yml`](./docker-compose.yml) file. You can then build & run the
image locally by running the following command:

```console
docker-compose up --build
```

The image will now be running, with the following ports exposed:

- **6878**: AceStream engine port. Docs for command line arguments and debugging
can be found [here][acestream]


[acestream]: https://docs.acestream.net/en/developers/
[#5]: https://github.com/martinbjeldbak/acestream-http-proxy/issues/5
[#13]: https://github.com/martinbjeldbak/acestream-http-proxy/issues/13
