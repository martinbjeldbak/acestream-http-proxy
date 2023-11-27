# AceStream HTTP Proxy
[![Build and push Docker image to DockerHub](https://github.com/martinbjeldbak/acestream-http-proxy/actions/workflows/build-and-push-docker.yml/badge.svg?event=release)](https://github.com/martinbjeldbak/acestream-http-proxy/actions/workflows/build-and-push-docker.yml)
[![Lint](https://github.com/martinbjeldbak/acestream-http-proxy/actions/workflows/lint-dockerfile.yml/badge.svg)](https://github.com/martinbjeldbak/acestream-http-proxy/actions/workflows/lint-dockerfile.yml)

This docker image installs and runs the AceStream Engine in Ubuntu and exposes the [HTTP API](https://docs.acestream.net/en/developers/connect-to-engine/).

As a result, you will be able to watch live AceStream sources without needing
to install the AceStream player or other dependencies locally.

This is especially useful for Desktop and NAS usage for anyone who wants to
tune in to AceStream channels.

Note: ARM-based CPUs are not currently supported, see issues [#5] and [#13].

## Usage

Ensure you have [Docker](https://www.docker.com) installed and running. You can then pull down and run the container as shown below.

```console
docker run -t -p 80:6878 ghcr.io/martinbjeldbak/acestream-http-proxy
```

You are then able to access AceStreams by pointing your favorite media player
(VLC, IINA, etc.) to the URL

```
http://127.0.0.1/ace/getstream?id=dd1e67078381739d14beca697356ab76d49d1a2
```

Where `dd1e67078381739d14beca697356ab76d49d1a2d` is the ID of the desired AceStream channel.

This image can also be deployed to a server, where it can proxy AceStream
content over HTTP.

## Contributing

Ensure you have Docker installed with support for docker-compose, as outlined
above.

Dockerfile steps are roughly guided by <https://wiki.acestream.media/Install_Ubuntu>.

For a list of AceStream versions, see here: <https://docs.acestream.net/products/#linux>

For convenience of easy image rebuilding, this repository contains a
[`docker-compose.yml`](./docker-compose.yml) file. You can then build & run the
image locally by running the following command:

```console
docker-compose up --build
```

The image will now be running, with the following ports exposed:

- **80**: [Caddy] HTTP reverse proxy, proxying the AceStream HTTP server but with more user friendly paths
- **443**: Ditto, but serving HTTPS requests
- **6878**: AceStream listener for access to the AceStream proxy without going
through Caddy. This is the sever Caddy reverse proxies. This takes the following path:
`/ace/getstream?id=dd1e67078381739d14beca697356ab76d49d1a2d`


[Caddy]: https://caddyserver.com/
[caddy-auto-https]: https://caddyserver.com/docs/automatic-https
[Let's Encrypt]: https://letsencrypt.org/
[#5]: https://github.com/martinbjeldbak/acestream-http-proxy/issues/5
[#13]: https://github.com/martinbjeldbak/acestream-http-proxy/issues/13
